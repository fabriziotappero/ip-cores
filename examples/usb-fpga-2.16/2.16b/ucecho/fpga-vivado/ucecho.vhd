library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
Library UNISIM;
use UNISIM.vcomponents.all;

entity ucecho is
   port(
      pd        : in unsigned(7 downto 0);
      pb        : out unsigned(7 downto 0);
      fxclk_in  : in std_logic
   );
end ucecho;


architecture RTL of ucecho is

--signal declaration
signal pb_buf : unsigned(7 downto 0);
signal clk : std_logic;

begin
    clk_buf : IBUFG
    port map (
        I => fxclk_in,
        O => clk
     );

    dpUCECHO: process(CLK)
    begin
         if CLK' event and CLK = '1' then
	    if ( pd >= 97 ) and ( pd <= 122)
	    then
		pb_buf <= pd - 32;
	    else
		pb_buf <= pd;
	    end if;
	    pb <= pb_buf;
	end if;
    end process dpUCECHO;
    
end RTL;
