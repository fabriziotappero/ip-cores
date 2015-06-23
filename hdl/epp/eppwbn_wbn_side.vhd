----------------------------------------------------------------------------------------------------
--| Modular Oscilloscope
--| UNSL - Argentine
--|
--| File: eppwbn_wbn_side.vhd
--| Version: 0.5
--| Tested in: Actel APA300
--| Tested in: Actel A3PE1500
--|   Board: RVI Prototype Board + LP Data Conversion Daughter Board
--|-------------------------------------------------------------------------------------------------
--| Description:
--|   EPP - Wishbone bridge. 
--|   This module is in the wishbone side (IEEE Std. 1284-2000).
--|-------------------------------------------------------------------------------------------------
--| File history:
--|   0.01  | nov-2008 | First release
--|   0.1   | jan-2009 | Sinc reset
--|   0.2   | feb-2009 | Some improvements
--|   0.5   | sep-2009 | New design, full sincronous
----------------------------------------------------------------------------------------------------
--| Copyright © 2008, Facundo Aguilera.
--|
--| This VHDL design file is an open design; you can redistribute it and/or
--| modify it and/or implement it after contacting the author.
----------------------------------------------------------------------------------------------------



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity eppwbn_wbn_side is
--   generic(
--     WAIT_DELAY : integer := 4  -- min value: 3
--   ); 
  port(
    inStrobe: in std_logic;                     --  HostClk/nWrite 
    iData: inout std_logic_vector (7 downto 0); --  AD8..1/AD8..1 (Data1..Data8)
    iBusy: out std_logic;                       --  PtrBusy/PeriphAck/nWait
    inAutoFd: in std_logic;                     --  HostBusy/HostAck/nDStrb
    inSelectIn: in std_logic;                   --  1284 Active/nAStrb
    RST_I: in std_logic;  
    CLK_I: in std_logic;  
    DAT_I: in std_logic_vector (7 downto 0);
    DAT_O: out std_logic_vector (7 downto 0);
    ADR_O: out std_logic_vector (7 downto 0);
    CYC_O: out std_logic;  
    STB_O: out std_logic;  
    ACK_I: in std_logic ;
    WE_O: out std_logic;

    rst_pp: in std_logic  -- reset from pp
  );
end eppwbn_wbn_side;

architecture bridge2 of eppwbn_wbn_side is  

  type StateType is (
      ST_IDLE,
      ST_ADDR,  
      ST_WRITING_D1,  
      ST_WRITING_D2,
      ST_READING_D1,
      ST_READING_D2
      );
  signal next_state, present_state: StateType;

  signal nWrite: std_logic;                   
  signal nWait:  std_logic;                   
  signal nDStrb: std_logic;                   
  signal nAStrb: std_logic;                   
  signal strb_hist: std_logic_vector(4 downto 0);
  signal strb_ris: std_logic;
  signal strb_fall: std_logic;
  signal strb_wb: std_logic;
  signal ack_pp: std_logic;

  signal adr_reg, data_reg: std_logic_vector (7 downto 0); -- registros internos temporales
  --signal waiting: std_logic_vector(WAIT_DELAY-1 downto 0);
  
begin
  
  -- Equal
  nWrite <= inStrobe;
  nAStrb <= inSelectIn;
  nDStrb <= inAutoFd;
  iBusy  <= nWait;
  
  STB_O <= strb_wb;
  CYC_O <= strb_wb;
  ADR_O <= adr_reg;
  DAT_O <= data_reg;
  
  -- Thanks fpga4fun
  P_strobes: process(nAStrb, nDStrb, CLK_I, strb_hist, RST_I, rst_pp)
  begin
    if CLK_I 'event and CLK_I = '1' then
      if RST_I = '1' or rst_pp = '1' then
        strb_hist <= (others => '1' );
      else
        strb_hist <= strb_hist(3 downto 0) & (nAStrb and nDStrb); -- only one is zero at a time
      end if;
    end if;
  end process;
  strb_ris  <= '1' when strb_hist(4 downto 1) = "0111" else '0';
  strb_fall <= '1' when strb_hist(4 downto 1) = "0000" else '0';
  
  
  P_next_st: process(strb_ris, strb_fall, ACK_I, nAStrb, nDStrb, nWrite, present_state) 
  begin
  
      case present_state is
        when ST_ADDR => 
          strb_wb <= '0'; 
          ack_pp <= '1';
          WE_O <= '0';
          -- >>> --
        if strb_ris = '1' then
          next_state <= ST_IDLE;
        else 
          next_state <= present_state;
        end if;
      
      when ST_WRITING_D1 =>
        strb_wb <= '0'; 
        ack_pp <= '1';
        WE_O <= '0';
        -- >>> --
        if strb_ris = '1' then
          next_state <= ST_WRITING_D2;
        else 
          next_state <= present_state;
        end if;
      
      when ST_WRITING_D2 =>
        strb_wb <= '1'; 
        ack_pp <= '0';
        WE_O <= '1';
        -- >>> --
        if ACK_I = '1' then
          next_state <= ST_IDLE;
        else 
          next_state <= present_state;
        end if;
        
      when ST_READING_D1 =>
        strb_wb <= '1'; 
        ack_pp <= '0';
        WE_O <= '0';
        -- >>> --
        if strb_ris = '1' then
          next_state <= ST_IDLE;
        elsif ACK_I = '1' then
          next_state <= ST_READING_D2;
        else 
          next_state <= present_state;
        end if;
        
      when ST_READING_D2 =>
        strb_wb <= '0'; 
        ack_pp <= '1';
        WE_O <= '0';
        -- >>> --
        if strb_ris = '1' then
          next_state <= ST_IDLE;
        else 
          next_state <= present_state;
        end if;

      when others =>  -- ST_IDLE
        strb_wb <= '0'; 
        ack_pp <= '0';
        WE_O <= '0';
        -- >>> --
        if strb_fall = '1' then
          if    nWrite = '0' and nDStrb = '0' then
            next_state <= ST_WRITING_D1;
          elsif nWrite = '1' and nDStrb = '0' then
            next_state <= ST_READING_D1;
          elsif nAStrb = '0' then
            next_state <= ST_ADDR;
          else 
            next_state <= present_state;
          end if;
        else 
          next_state <= present_state;
        end if;
    end case;  
  end process;
  
  P_act_st: process(CLK_I, RST_I, rst_pp, next_state, iData, DAT_I, present_state, nWrite)
  begin
    if (CLK_I'event and CLK_I='1') then
      if RST_I = '1' or rst_pp = '1' then
        present_state <= ST_IDLE;
        data_reg <= (others => '0');
        adr_reg <= (others => '0');
      else
        present_state <= next_state;
        case present_state is
          when ST_ADDR => 
            --if next_state = ST_IDLE and nWrite = '0' then
            if strb_hist(0) = '0' and nWrite = '0' then
              adr_reg <= iData;
            end if;
          when ST_WRITING_D1 =>
            --if next_state = ST_WRITING_D2 then
            if strb_hist(0) = '0' then
              data_reg <= iData;
            end if;
          when ST_READING_D1 =>
            if next_state = ST_READING_D2 then
              data_reg <= DAT_I;
            end if; 
          when others =>
        end case; 
      end if;
    end if; 
  end process;
  
  nWait <= ack_pp;
  
  iData <= data_reg when (nWrite = '1' and nDStrb = '0' ) else 
           adr_reg  when (nWrite = '1' and nAStrb = '0' ) else 
           (others => 'Z');
  
--   P_delay: process(ack_pp, CLK_I, rst_pp, RST_I, waiting)
--   begin
--     if CLK_I'event and CLK_I = '1' then
--       if rst_pp = '1' or RST_I = '1' then
--         waiting <= (others => '0');
--       else 
--         waiting <= waiting(WAIT_DELAY-2 downto 0) & ack_pp;
--       end if;
--     end if;
--   end process;
  
  
end architecture bridge2;