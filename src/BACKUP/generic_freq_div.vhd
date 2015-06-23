library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity generic_freq_div is
  generic( factor : integer := 400); --factor have to be an even number; 1000 for 100kHz at 100MHz
  port( clk_in : in std_logic;		-- 400 for 4us clock at 100MHz
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
