library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity generic_freq_div is
  generic( factor : integer := 400); -- should be an even number (period_of_clk=factor*period_of_clk_in)
  port( clk_in : in std_logic;		
        clk : out std_logic );
end generic_freq_div;


architecture behavioral of generic_freq_div is
begin
div: process(clk_in)
    variable count : integer range 0 to factor/2-1;
    variable tmp : std_logic := '0';
  begin
    if clk_in'event and clk_in='1' then
      if count>=factor/2-1 then
        count := 0;
        tmp := not tmp;
      else
        count := count + 1;
      end if;
    end if;
    clk <= tmp;
  end process;
end behavioral;
