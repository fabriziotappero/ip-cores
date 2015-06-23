library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity graphical_lcd_tb is

end graphical_lcd_tb;

-------------------------------------------------------------------------------
architecture testbench of graphical_lcd_tb is
  component graphical_lcd
    port (
      E     : out   std_logic;
      R_W   : out   std_logic;
      CS1   : out   std_logic;
      CS2   : out   std_logic;
      D_I   : out   std_logic;
      DB    : inout std_logic_vector(7 downto 0);
      CLK_I : in    std_logic;
      RST_I : in    std_logic;
      DAT_I : in    std_logic_vector(7 downto 0);
      DAT_O : out   std_logic_vector;
      ACK_O : out   std_logic;
      STB_I : in    std_logic;
      WE_I  : in    std_logic;
      TGD_I : in    std_logic_vector(2 downto 0));
  end component;
  
  signal E_i     : std_logic;
  signal R_W_i   : std_logic;
  signal CS1_i   : std_logic;
  signal CS2_i   : std_logic;
  signal D_I_i   : std_logic;
  signal DB_i    : std_logic_vector(7 downto 0);
  signal CLK_I_i : std_logic;
  signal RST_I_i : std_logic;
  signal DAT_I_i : std_logic_vector(7 downto 0);
  signal DAT_O_i : std_logic_vector(7 downto 0);
  signal ACK_O_i : std_logic;
  signal STB_I_i : std_logic;
  signal WE_I_i  : std_logic;
  signal TGD_I_i : std_logic_vector(2 downto 0);

  constant clock_period : delay_length := 20 ns;
  
begin  -- testbench

  -- Unit under test
  UUT: graphical_lcd
    port map (
        E     => E_i,
        R_W   => R_W_i,
        CS1   => CS1_i,
        CS2   => CS2_i,
        D_I   => D_I_i,
        DB    => DB_i,
        CLK_I => CLK_I_i,
        RST_I => RST_I_i,
        DAT_I => DAT_I_i,
        DAT_O => DAT_O_i,
        ACK_O => ACK_O_i,
        STB_I => STB_I_i,
        WE_I  => WE_I_i,
        TGD_I => TGD_I_i);
        
  -- Simulate fake data reads
  DB_i <= "ZZZZZZZZ" when R_W_i = '0' else
          "00001111";

  -- Reset driver
  RST_I_i <= '1', '0' after 2.5 * clock_period;
  
  -- Generate the testbench clock
  clk_gen: process
  begin  -- process clk_gen
    CLK_I_i <= '0';
    wait for clock_period/2;
    loop
      CLK_I_i <= '1';
      wait for clock_period/2;
      CLK_I_i <= '0';
      wait for clock_period/2;
    end loop;  -- clock_period/2;
  end process clk_gen;
  
  stimulus: process
  begin  -- process stimulus
    wait until RST_I_i = '0';

    wait until CLK_I_i = '1';
    -- Turn the display on
    DAT_I_i <= "00111111";
    TGD_I_i <= "000";
    WE_I_i <= '1';
    wait until CLK_I_i = '1';
    STB_I_i <= '1';
    wait until ACK_O_i = '1';
    wait until CLK_I_i = '1';
    STB_I_i <= '0';
    
    -- Read until the busy is gone
    wait until CLK_I_i = '1';
    TGD_I_i <= "100";
    WE_I_i <= '0';
    wait until CLK_I_i = '1';
    STB_I_i <= '1';
    wait until ACK_O_i = '1';
    wait until CLK_I_i = '1';
    STB_I_i <= '0';
    -- Send some data
    wait until CLK_I_i = '1';
    DAT_I_i <= "10101100";
    TGD_I_i <= "011";
    WE_I_i <= '1';
    wait until CLK_I_i = '1';
    STB_I_i <= '1';
    wait until ACK_O_i = '1';
    wait until CLK_I_i = '1';
    STB_I_i <= '0';
    wait;
    
  end process stimulus;

end testbench;


