library ieee;
use ieee.std_logic_1164.all;
use work.components.all;
use work.asci_types.all;

entity topEntity is
port( clk, j_up, j_left, j_right, j_down : in std_logic;
      led : out std_logic_vector (3 downto 0);
      leds : out std_logic_vector (0 to 3);
      lcd_rs, lcd_ena, lcd_rw : out std_logic;
      lcd_data : out std_logic_vector (7 downto 0) );
end topEntity;

architecture structural of topEntity is
  signal clk_1000 : std_logic;
  signal lcd_intermediate : lcd_matrix;
begin
div1000: generic_freq_div
  port map (clk_in => clk, clk => clk_1000);

flash: TopBeat 
  port map (clk => clk_1000, Reset_n => j_down, leds(0 to 3) => leds(0 to 3) );

candy_m: candy_machine
  port map (clk => clk, j_down => j_down, j_left => j_left, j_up => j_up,
            j_right => j_right, led (3 downto 0) => led (3 downto 0),
            lcd_print => lcd_intermediate );

lcd_1: lcd1
  port map (clk => clk, rst => j_down, lcd_rs => lcd_rs, 
            lcd_ena => lcd_ena, lcd_rw => lcd_rw,
            lcd_data (7 downto 0) => lcd_data (7 downto 0),
            lcd_str => lcd_intermediate );
  
end structural;