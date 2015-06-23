library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
Library UNISIM;
use UNISIM.vcomponents.all;

entity ucecho is
   port(
      pd        : in unsigned(7 downto 0);
      pb        : out unsigned(7 downto 0);
      fxclk     : in std_logic
   );
end ucecho;


architecture RTL of ucecho is

--signal declaration
signal pb_buf : unsigned(7 downto 0);

begin
    pb <= pb_buf;

    dpUCECHO: process(fxclk)
    begin
         if fxclk' event and fxclk = '1' then
	    if ( pd >= 97 ) and ( pd <= 122)
	    then
		pb_buf <= pd - 32;
	    else
		pb_buf <= pd;
	    end if;
	end if;
    end process dpUCECHO;
    
end RTL;
