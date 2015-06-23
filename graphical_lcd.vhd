-------------------------------------------------------------------------------
-- WISHBONE DATASHEET
-- WISHBONE SoC Architecture Specification, Revision B.3
--
-- General Description        : graphical LCD interface for KS0108b controllers
--
-- Supported Cycles           : SLAVE, READ/WRITE
--
-- Data Port Size             : 8-bit
-- Data Port Granularity      : 8-bit
-- Data Port Max Operand Size : 8-bit
-- Data Transfer Ordering     : Big endian and/or little endian
-- Data Transfer Sequence     : Undefined
--
-- Supported Signal List
-- Signal Name                WISHBONE Equiv
--  ACK_O                       ACK_O
--  CLK_I                       CLK_I
--  DAT_I(7 downto 0)           DAT_I()
--  DAT_O(7 downto 0)           DAT_O()
--  RST_I                       RST_I
--  STB_I                       STB_I
--  WE_I                        WE_I
--  D/I_F                       TGD(0)
--  CS1                         TGD(1)
--  CS2                         TGD(2)
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity graphical_lcd is
  port (
    -- LCD interface
    E     : out   std_logic;                     -- enable signal
    R_W   : out   std_logic;                     -- Read High / Write Low
    CS1   : out   std_logic;                     -- CS1
    CS2   : out   std_logic;                     -- CS2
    D_I   : out   std_logic;                     -- data high / instruction low
    DB    : inout std_logic_vector(7 downto 0);  -- data byte
    -- Wishbone interface
    CLK_I : in    std_logic;                     -- The Sytem Clock
    RST_I : in    std_logic;                     -- Async. Reset
    DAT_I : in    std_logic_vector(7 downto 0);
    DAT_O : out   std_logic_vector(7 downto 0);
    ACK_O : out   std_logic;
    STB_I : in    std_logic;
    WE_I  : in    std_logic;
    TGD_I : in    std_logic_vector(2 downto 0));
end graphical_lcd;

-------------------------------------------------------------------------------
-- ARCHITECTURE
-------------------------------------------------------------------------------
architecture ks0108b of graphical_lcd is
  type state is (IDLE, WR_SETUP, WR_HOLD, RD_SETUP, RD_HOLD, ACK);
  
  signal DB_en : std_logic := '0';        -- enable the DB lines
  signal cur_state : state := idle;       -- current state

  signal data_in : std_logic_vector(7 downto 0) := "XXXXXXXX";
  signal data_out : std_logic_vector(7 downto 0) := "XXXXXXXX";

  signal e_cnt : std_logic_vector(7 downto 0);
  signal e_int : std_logic;
  signal e_en : std_logic;
begin  -- behavioral

  -----------------------------------------------------------------------------
  -- WISHBONE STUFF
  -----------------------------------------------------------------------------
  DAT_O <= data_out;
  
  ACK_O <= '1' when (cur_state = ACK) else
           '0';

  wishbone_dat_in: process (CLK_I, RST_I)
  begin  -- process wishbone_dat_in
    if RST_I = '1' then                 -- asynchronous reset
      data_in <= "00000000";
    elsif CLK_I'event and CLK_I = '1' then  -- rising clock edge
      if (STB_I = '1') and (WE_I = '1') then
        data_in <= DAT_I;
      end if;
    else
      data_in <= data_in;
    end if;
  end process wishbone_dat_in;

  -----------------------------------------------------------------------------
  -- LCD STUFF
  -----------------------------------------------------------------------------

  E <= e_int;
  
  D_I <= TGD_I(0);
  
  CS1 <= TGD_I(1);
  
  CS2 <= TGD_I(2);

  R_W <= '0' when (cur_state = WR_SETUP) or (cur_state = WR_HOLD) else
         '1' when (cur_state = RD_SETUP) or (cur_state = RD_HOLD) else
         '1';
  
  e_en <= '1' when (cur_state = WR_SETUP) or (cur_state = WR_HOLD) else
          '1' when (cur_state = RD_SETUP) or (cur_state = RD_HOLD) else
          '0';
  
  DB <= data_in when (cur_state = WR_SETUP) or (cur_state = WR_HOLD) else
        "ZZZZZZZZ";

  data_out <= DB when (e_int'event) and (e_int = '0') else
              data_out;
  
  -- purpose: creates the enable signal which is at least a 500ns period clock
  e_gen: process (CLK_I, RST_I, e_en)
  begin  -- process e_gen
    if (RST_I = '1') or (e_en = '0') then
      e_cnt <= "00000000";
      e_int <= '0';
    elsif CLK_I'event and CLK_I = '1' then
      e_cnt <= e_cnt + 1;
      if (e_cnt = X"19") then
        e_cnt <= "00000000";
        e_int <= not e_int;
      end if;
    end if;
  end process e_gen;

  state_machine: process (CLK_I, RST_I)
  begin  -- process state_machine
    if RST_I = '1' then 
      cur_state <= idle;
    elsif CLK_I'event and CLK_I = '1' then
      case cur_state is
        when IDLE =>
          if (STB_I = '1') then
            if (WE_I = '1') then
              cur_state <= WR_SETUP;
            else
              cur_state <= RD_SETUP;
            end if;
          else
            cur_state <= IDLE;
          end if;
          
        when WR_SETUP =>
          if (e_int = '1') then
            cur_state <= WR_HOLD;
          else
            cur_state <= WR_SETUP;
          end if;

        when WR_HOLD =>
          if (e_int = '0') and (e_cnt = X"03") then
            cur_state <= ACK;
          else
            cur_state <= WR_HOLD;
          end if;

        when RD_SETUP =>
          if (e_int = '1') then
            cur_state <= RD_HOLD;
          else
            cur_state <= RD_SETUP;
          end if;

        when RD_HOLD =>
          if (e_int = '0') and (e_cnt = X"03") then
            cur_state <= ACK;
          else
            cur_state <= RD_HOLD;
          end if;
          
        when ACK =>
          if (STB_I = '0') then
            cur_state <= IDLE;
          end if;
          
        when others => null;
                       
      end case;
    end if;
  end process state_machine;

end ks0108b;



