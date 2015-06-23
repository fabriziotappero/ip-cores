library ieee;
use ieee.std_logic_1164.all;

package components is
  component generic_freq_div is
    port( clk_in : in std_logic; clk : out std_logic);
  end component;
  
  component lcd1 is
    port( clk_400, clk, rst : in std_logic; 
          lcd_data : out std_logic_vector (7 downto 0);
          lcd_ena, lcd_rw, lcd_rs : out std_logic  );
  end component;
  
end components;