-- -------------------------------------------------------------------------
-- -------------------------------------------------------------------------
--
-- Revision Control Information
--
-- $RCSfile: top_ethgen32.v,v $
-- $Source: /ipbu/cvs/sio/projects/TriSpeedEthernet/src/testbench/models/verilog/ethernet_model/gen/top_ethgen8.v,v $
--
-- $Revision: #1 $
-- $Date: 2008/08/09 $
-- Check in by : $Author: sc-build $
-- Author      : SKNg/TTChong
--
-- Project     : Triple Speed Ethernet - 10/100/1000 MAC
--
-- Description : (Simulation only)
--
-- Ethernet Traffic Generator for 8 bit fifoless MAC Atlantic client interface
-- Instantiates VHDL module: ethgenerator (ethgen.vhd)
--                           timing_adapter_8 (timing_adapter_8.vhd) 
-- ALTERA Confidential and Proprietary
-- Copyright 2006 (c) Altera Corporation
-- All rights reserved
--
-- -------------------------------------------------------------------------
-- -------------------------------------------------------------------------

library ieee ;
use     ieee.std_logic_1164.all ;
use     ieee.std_logic_unsigned.all ;
use     ieee.std_logic_arith.all;



entity top_ethgenerator_8 is


    generic (  THOLD           : time    := 1 ns; 
               ENABLE_SHIFT16  : integer := 1;  --0 for false, 1 for true
               ZERO_LATENCY    : integer := 1   --0 for NON-ZERO read latency, etc.

            );

    port (

       reset 		: in 	std_logic;
       clk 			: in 	std_logic;
       enable 		: in 	std_logic;
       dout 		: out 	std_logic_vector(7 downto 0);
       dval 		: out 	std_logic;
       derror		: out 	std_logic;
       sop			: out 	std_logic;
       eop			: out 	std_logic;
       mac_reverse  : in 	std_logic;
       dst			: in 	std_logic_vector (47 downto 0);
       src			: in 	std_logic_vector (47 downto 0);
       prmble_len	: in 	integer range 0 to 40;
       pquant		: in 	std_logic_vector (15 downto 0);
       vlan_ctl		: in 	std_logic_vector (15 downto 0);
       len			: in 	std_logic_vector (15 downto 0);
       frmtype		: in 	std_logic_vector (15 downto 0);
       cntstart		: in 	integer range 0 to 255;
       cntstep		: in 	integer range 0 to 255;
       ipg_len		: in 	integer range 0 to 32768;
       payload_err  : in    std_logic;
       prmbl_err    : in    std_logic;
       crc_err      : in    std_logic;
       vlan_en      : in    std_logic;
       stack_vlan   : in    std_logic;
       pause_gen    : in    std_logic;
       pad_en       : in    std_logic;
       phy_err      : in    std_logic;
       end_err      : in    std_logic;
       data_only    : in    std_logic;
       start        : in    std_logic;
       done         : out   std_logic
     );

end top_ethgenerator_8;

architecture behav of top_ethgenerator_8 is

-- Component instantiated by Turbo autoplace on 21/02/2008 at 10:16:49
COMPONENT timing_adapter_8
port (
    
  -- Interface: clk                     
  clk                  : in std_logic;
  reset                : in std_logic;
  -- Interface: in
  in_ready              : out std_logic;          
  in_valid              : in  std_logic;
  in_data               : in  std_logic_vector (7 downto 0);
  in_startofpacket      : in  std_logic;
  in_endofpacket        : in  std_logic;
  in_error              : in  std_logic;
  -- Interface: out
  out_ready             : in std_logic;
  out_valid             : out std_logic;
  out_data              : out std_logic_vector (7 downto 0);
  out_startofpacket     : out std_logic;
  out_endofpacket       : out std_logic;
  out_error             : out std_logic
);
END COMPONENT;

-- Component instantiated by Turbo autoplace on 21/02/2008 at 10:16:17
COMPONENT ETHGENERATOR

    generic (  THOLD          : time    := 1 ns;
			   ENABLE_SHIFT16 : integer := 0  --0 for false, 1 for true
			);
    port (

      reset       : in std_logic ;     -- active high

        -- GMII receive interface: To be connected to MAC RX

      rx_clk      : in std_logic ;
      enable      : in std_logic ;
      rxd         : out std_logic_vector(7 downto 0);
      rx_dv       : out std_logic;
      rx_er       : out std_logic;
      
        -- Additional FIFO controls for FIFO test scenarios
                
      sop         : out std_logic;   -- pulse with first character
      eop         : out std_logic;   -- pulse with last  character

        -- Frame Contents definitions

      mac_reverse   : in std_logic;                     -- 1: dst/src are sent MSB first
      dst           : in std_logic_vector(47 downto 0); -- destination address
      src           : in std_logic_vector(47 downto 0); -- source address
      
      prmble_len    : in integer range 0 to 40;         -- length of preamble
      pquant        : in std_logic_vector(15 downto 0); -- Pause Quanta value
      vlan_ctl      : in std_logic_vector(15 downto 0); -- VLAN control info
      len           : in std_logic_vector(15 downto 0); -- Length of payload
      frmtype       : in std_logic_vector(15 downto 0); -- if non-null: type field instead length
      
      cntstart      : in integer range 0 to 255;  -- payload data counter start (first byte of payload)
      cntstep       : in integer range 0 to 255;  -- payload counter step (2nd byte in paylaod)

      ipg_len       : in integer range 0 to 32768;  -- inter packet gap (delay after CRC)
      wrong_pause_op : in std_logic ;                    -- Generate Pause Frame with Wrong Opcode       
      wrong_pause_lgth : in std_logic ;                    -- Generate Pause Frame with Wrong Opcode       
       -- Control
       
      payload_err   : in std_logic;  -- generate payload pattern error (last payload byte is wrong)
      prmbl_err     : in std_logic;
      crc_err       : in std_logic;
      vlan_en       : in std_logic;
      pause_gen     : in std_logic;
      pad_en        : in std_logic;
      phy_err       : in std_logic;
      end_err       : in std_logic;  -- keep rx_dv high one cycle after end of frame
      magic         : in std_logic;  
      stack_vlan    : in std_logic;   
                
      data_only     : in std_logic;  -- if set omits preamble, padding, CRC
            
      start         : in  std_logic;
      done          : out std_logic );
      
END COMPONENT;


--  internal GMII from generator
signal    rxd     	: std_logic_vector (7 downto 0); 
signal    rx_dv   	: std_logic; 
signal    rx_er   	: std_logic; 
signal    sop_gen 	: std_logic; 
signal    eop_gen 	: std_logic; 
signal    start_gen : std_logic; 
signal    done_gen 	: std_logic; 
--  captured signals from generator (lasting 1 word clock cycle)
signal    enable_int: std_logic; 
signal    enable_reg: std_logic; 
signal    sop_int 	: std_logic; --  captured sop_gen
signal    sop_int_d : std_logic; --  captured sop_gen
signal    eop_int 	: std_logic; --  captured eop_gen
signal    eop_i 	: std_logic; --  captured eop_gen
signal    rx_er_int : std_logic; --  captured rx_er
--  external signals
signal    sop_ex    : std_logic; 
signal    eop_ex    : std_logic; 
--  captured command signals 
signal  ipg_len_i       :  integer range 0 to 32768; -- inter packet gap
--  internal
signal    data8     : std_logic_vector(7 downto 0); 
signal    clkcnt	: std_logic_vector(2 downto 0); 
signal    bytecnt_eop: std_logic_vector(1 downto 0); --  captured count for last word
signal    count 	: integer; 

--assign output
signal dout_reg       : std_logic_vector(7 downto 0);
signal dval_reg       : std_logic;
signal derror_reg     : std_logic;
signal done_reg       : std_logic;

signal  dout_temp   : std_logic_vector (7 downto 0); 
signal  dval_temp   : std_logic; 
signal  derror_temp : std_logic; 
signal  sop_temp    : std_logic; 
signal  eop_temp    : std_logic; 
signal  done_temp   : std_logic;    

signal  dout_before_delay	: std_logic_vector (7 downto 0); 
signal  dval_before_delay	: std_logic; 
signal  derror_before_delay	: std_logic; 
signal  sop_before_delay	: std_logic; 
signal  eop_before_delay	: std_logic; 
signal  done_before_delay	: std_logic;    


-- TYPE stm_typ:
type  stm_typ is (S_IDLE, S_DATA, S_IPG, S_IPG0, S_WAIT);
    
signal  state          : stm_typ;
signal  last_state     : stm_typ;

signal  clk_d          : std_logic; 
signal  fast_clk       : std_logic; 
signal  fast_clk_gate  : std_logic; 
signal  bytecnt        : std_logic_vector(2 downto 0); 
signal  tx_clk         : std_logic; 

begin
	


--  ---------------------------------------
--  Generate internal fast clock synchronized to external input clock
--  ---------------------------------------

process 
 begin
   fast_clk <= '0' after 0.1 ns;    
   wait for 0.4 ns; 
   fast_clk <= '1' after 0.1 ns;    
   wait for 0.4 ns; 
end process;


process (fast_clk,reset)
begin
   if (reset = '1') then
      fast_clk_gate <= '0';   
      clk_d         <= '0';   
   elsif (falling_edge(fast_clk)) then
--  work on neg edge
      clk_d <= clk; 
      if ((rx_dv = '0' or done_gen = '1') and 
		    (enable_int = '1' or start_gen = '1')) then

--  generator not running, enable it permanently
         fast_clk_gate <= '1';    
      elsif (clk_d = '0' and clk = '1' and 
			    state /= S_WAIT and (enable_int = '1' or 
			    state = S_IPG0) ) then
--  wait for rising edge
         fast_clk_gate <= '1';    
      else
         fast_clk_gate <= '0';    
      end if;
   end if;
end process;


--  DDR process to generate gated clock
process (fast_clk,reset)
   begin
	   if (reset = '1') then
	      tx_clk <= '0';  
	   elsif ( fast_clk = '1' ) then
	      if (fast_clk_gate ='1') then
	         tx_clk <= '1';   
	      end if;
	   elsif ( fast_clk = '0' ) then
	      tx_clk <= '0';  
	   end if;

end process;



--  capture generator signals with word clock domain handshake
--  ----------------------------------------------------------
process (tx_clk,reset)
  begin
   if (reset = '1') then
      eop_int   <= '0'; 
      sop_int   <= '0'; 
      rx_er_int <= '0';   

   elsif (rising_edge(tx_clk)) then
      
      if (sop_gen = '1') then
         sop_int <= '1';  
      elsif (sop_ex = '1' ) then
         sop_int <= '0';
      end if;
        
      if (eop_gen = '1') then
         eop_int <= '1';  
      elsif (eop_ex = '1' ) then
         eop_int <= '0';  
 	  end if;

      if (rx_er = '1') then
         rx_er_int <= '1';    
      elsif (eop_ex = '1' ) then
         rx_er_int <= '0';    
      end if;

   end if;
end process;


--  word clock, external signal generation
--  --------------------------------------
process (clk,reset)
   begin
   if (reset = '1') then
      eop_ex <= '0';  
      sop_ex <= '0';  
      dval_reg <= '0';    
      dout_reg <= (others => '0');  
      derror_reg <= '0';  
      start_gen <= '0';   
      ipg_len_i <= 0;   
      done_reg <= '0';    
   elsif (rising_edge(clk)) then
      eop_ex 		<= eop_int;    
      sop_ex 		<= sop_int;    
      dout_reg 		<= data8 after THOLD;  
      derror_reg 	<= rx_er_int after THOLD; 

     if( done_gen='1' and ((state=S_IDLE or state=S_IPG0) or
                                      (state=S_DATA and eop_int='1' and ipg_len_i<4 and start='1')) ) then  -- nextstate=S_IPG0
--  nextstate=S_IPG0
         start_gen <= start;    
      else
         start_gen <= '0';    
      end if;


      if( (state = S_DATA or state=S_IPG0 or sop_int='1') and enable_int='1') then
         dval_reg <= '1' after THOLD;    
      else
         dval_reg <= '0' after THOLD;    
      end if;

--  store input variables that could change until end of frame
      if (sop_int = '1') then
         ipg_len_i <= ipg_len;  
      end if;

      done_reg <= done_gen; 
   end if;
end process;


--  ------------------------
--  capture GMII data bytes
--  ------------------------
process (tx_clk,reset)
 begin
   if (reset = '1') then
      data8 <= (others => '0');    
   elsif (rising_edge (tx_clk)) then 
      if (sop_gen = '1' and rx_dv = '1') then
--  first byte
         data8 <= rxd; 
      elsif (rx_dv = '1' ) then
--  during frame
         data8 <= rxd;  
      end if;
   end if;   
end process;

--  ------------------------
--  state machine
--  ------------------------
process (clk, reset)
   begin
   if (reset = '1') then
      state <= S_IDLE;  
      count <= 8;   
   elsif (rising_edge(clk)) then
      if (state = S_IPG) then
         count <= count + 4;  
      else
         count <= 8;
      end if;
             
	      case (state) is
		      when S_idle =>
		         if (done_gen = '0') then
		            state <= s_data;    
		         else
		            state <= s_idle;    
		         end if;
		      when s_data =>
		         if (eop_int = '0' and enable_int = '1') then
		            state <= s_data;    
		         elsif (eop_int = '0' and enable_int = '0' ) then
		            state <= s_wait;    
		         elsif (eop_int = '1') then
		            if (ipg_len_i < 4 and start = '1') then
		               state <= s_ipg0; --  no IPG
		            elsif (ipg_len_i < 8 ) then
		               state <= s_idle; 
		            else
		               state <= s_ipg;  
		            end if;
		         else
		            state <= s_data;    
		         end if;
		      when s_ipg =>
		         if (count < ipg_len_i) then
		            state <= s_ipg; 
		         else
		            state <= s_idle;    
		         end if;
		      when s_ipg0 =>
		         state <= s_data;   

		      when s_wait =>
		         if (enable_int = '1') then
		            state <= s_data;    
		         else
		            state <= s_wait;    
		         end if;
		      when others =>
		         state <= s_idle;   
	      end case;
   
   end if;
end process;



process (clk,reset)
 begin 
   if (reset = '1') then
          dout_temp  <= (others => '0'); 
          dval_temp  <= '0'; 
          derror_temp<= '0'; 
          sop_temp   <= '0'; 
          eop_temp   <= '0'; 
          done_temp  <= '0';    
   elsif (rising_edge(clk)) then
             dout_temp     <= dout_reg after THOLD; 
             dval_temp     <= dval_reg after THOLD; 
             derror_temp   <= derror_reg after THOLD; 
             sop_temp      <= sop_ex after THOLD; 
             eop_temp      <= eop_ex after THOLD; 
             done_temp     <= done_reg after THOLD;    
    end if;
end process;

GMII_ADAPTER_BLOCK: if (ZERO_LATENCY = 1) generate
    
    tb_adapter: timing_adapter_8  
    port map(

          -- Interface: clk
          clk 				=> clk,
          reset				=> reset,
          -- Interface: in 
          in_ready			=> enable_int,
          in_valid			=> dval_temp,
          in_data			=> dout_temp,
          in_startofpacket	=> sop_temp,
          in_endofpacket	=> eop_temp,
          in_error			=> derror_temp,
          -- Interface: out
          out_ready			=> enable,
          out_valid			=> dval,
          out_data			=> dout,
          out_startofpacket => sop,
          out_endofpacket	=> eop,
          out_error			=> derror

    );
  
    done <= done_temp;   
end generate;

NO_ADAPTER_BLOCK: if (ZERO_LATENCY = 0) generate
 
     process (clk,reset)
       begin
         if (reset = '1')  then
           enable_reg <= '0';  
         elsif (rising_edge(clk)) then
           enable_reg <= enable;
        end if;
	end process;

  	enable_int  <=  enable_reg;
    dout     	<=  dout_temp; 
    dval     	<=  dval_temp; 
    derror   	<=  derror_temp; 
    sop      	<=  sop_temp; 
    eop      	<=  eop_temp; 
    done     	<=  done_temp;    
end generate;


--  Generator
--  ---------
gen1g : ethgenerator  
generic map (
			ENABLE_SHIFT16 => ENABLE_SHIFT16,
			THOLD          => 0.1 ns
         )

port map (

          reset					=>	reset,
          rx_clk				=>	tx_clk,
          enable				=>	'1',
          rxd					=>	rxd,
          rx_dv					=>	rx_dv,
          rx_er					=>	rx_er,
          sop					=>	sop_gen,
          eop					=>	eop_gen,
          mac_reverse			=>	mac_reverse,
          dst					=>	dst,
          src					=>	src,
          prmble_len			=>	prmble_len,
          pquant				=>	pquant,
          vlan_ctl				=>	vlan_ctl,
          len					=>	len,
          frmtype				=>	frmtype,
          cntstart				=>	cntstart,
          cntstep				=>	cntstep,
          ipg_len				=>	4,
          wrong_pause_op        => '0',
          wrong_pause_lgth      => '0',
          payload_err			=>	payload_err,
          prmbl_err				=>	prmbl_err,
          crc_err				=>	crc_err,
          vlan_en				=>	vlan_en,
          stack_vlan			=>	stack_vlan,
          pause_gen				=>	pause_gen,
          pad_en				=>	pad_en,
          phy_err				=>	phy_err,
          magic                =>      '0',
          end_err				=>	end_err,
          data_only				=>	data_only,
          start					=>	start_gen,
          done					=>	done_gen
        );

end behav;


