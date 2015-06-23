-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

-------------------------------------------------------------------------------

entity test_lcd_tb is
end test_lcd_tb;

-------------------------------------------------------------------------------

architecture behavioral of test_lcd_tb is
  component test_lcd
    port (
      DONE : out   std_logic;
      E    : out   std_logic;
      R_W  : out   std_logic;
      CS1  : out   std_logic;
      CS2  : out   std_logic;
      D_I  : out   std_logic;
      DB   : inout std_logic_vector(7 downto 0);
      CLK  : in    std_logic;
      RST  : in    std_logic;
	 RAM_DIS : out std_logic);
  end component;

  signal DONE_i : std_logic;
  signal E_i    : std_logic;
  signal R_W_i  : std_logic;
  signal CS1_i  : std_logic;
  signal CS2_i  : std_logic;
  signal D_I_i  : std_logic;
  signal DB_i   : std_logic_vector(7 downto 0);
  signal CLK_i  : std_logic;
  signal RST_i  : std_logic;
  signal RAM_DIS_i : std_logic;
  
  constant clock_period : delay_length := 20 ns;
  
begin  -- testbench
  UUT: test_lcd
    port map (
        DONE => DONE_i,
        E    => E_i,
        R_W  => R_W_i,
        CS1  => CS1_i,
        CS2  => CS2_i,
        D_I  => D_I_i,
        DB   => DB_i,
        CLK  => CLK_i,
        RST  => RST_i,
	   RAM_DIS => RAM_DIS_i);
        
  -- Simulate the LCD
  DB_i <= "ZZZZZZZZ" when (R_W_i = '0') else "00000000";
  
  -- Generate the testbench clock
  clk_gen: process
  begin  -- process clk_gen
    CLK_i <= '0';
    wait for clock_period/2;
    loop
      CLK_i <= '1';
      wait for clock_period/2;
      CLK_i <= '0';
      wait for clock_period/2;
    end loop;  -- clock_period/2;
  end process clk_gen;
  
  -- Reset driver
  RST_i <= '1', '0' after 2.5 * clock_period;
             
end behavioral;

