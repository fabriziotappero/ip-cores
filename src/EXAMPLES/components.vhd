library ieee;
use ieee.std_logic_1164.all;
use work.asci_types.all;

package components is
  component generic_freq_div is
    port( clk_in : in std_logic; clk : out std_logic);
  end component;
  
  component TopBeat is
    port( clk : in std_logic; Reset_n : in std_logic;
          leds : out std_logic_vector (0 to 3) );
  end component;
  
  component candy_machine is
    port( clk, j_down, j_left, j_up, j_right : in std_logic; 
          led : out std_logic_vector (3 downto 0);
          lcd_print : out lcd_matrix );
  end component;

  component lcd1 is
    port( clk, rst : in std_logic; 
          lcd_data : out std_logic_vector (7 downto 0);
          lcd_ena, lcd_rw, lcd_rs : out std_logic;
          lcd_str : in lcd_matrix );
  end component;  
  
end components;