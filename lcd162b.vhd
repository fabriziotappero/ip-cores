library ieee;
use ieee.std_logic_1164.all;

entity lcd162b is
	port (
		rs : in std_logic;
		rw : in std_logic;
		e  : in std_logic;
		db : inout std_logic_vector(7 downto 0);
		
		line1 : out string(1 to 16);
		line2 : out string(1 to 16) 
	);
end entity lcd162b;

architecture RTL of lcd162b is
	
begin

	line1(1 to 5) <= "hallo";
	line2(1 to 2) <= "du";

end architecture RTL;
