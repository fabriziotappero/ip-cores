library ieee;
use ieee.std_logic_1164.all;
use work.components.all;

entity topEntity is
port( clk, rst : in std_logic;
      lcd_data : out std_logic_vector (7 downto 0);
      lcd_rs, lcd_rw, lcd_ena : out std_logic;
      led : out std_logic_vector (0 downto 0) ); -- used for debug purposes
end topEntity;

architecture structural of topEntity is
  signal clk_400 : std_logic;           -- clock with 4us period, used for debug
begin
div1000: generic_freq_div
  port map (clk_in => clk, clk => clk_400);

lcd_1: lcd1
  port map (clk => clk, rst => rst, clk_400 => clk_400, lcd_rs => lcd_rs, 
            lcd_ena => lcd_ena, lcd_rw => lcd_rw,
            lcd_data (7 downto 0) => lcd_data (7 downto 0), led(0) => led(0) );
end structural;
