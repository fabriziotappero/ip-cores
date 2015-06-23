library ieee;
use ieee.std_logic_1164.all;

entity testbench is
end entity testbench;

architecture RTL of testbench is

	component lcd162b is
		port (
			rs : in std_logic;
			rw : in std_logic;
			e  : in std_logic;
			db : inout std_logic_vector(7 downto 0);
			
			line1 : out string(1 to 16);
			line2 : out string(1 to 16) 
		);
	end component lcd162b;
	
	signal disp1 : string(1 to 16);
	signal disp2 : string(1 to 16);

begin

uut : lcd162b
	port map(
		rs => '0',
		rw => '0',
		e  => '0',
		db => open,
		line1 => disp1,
		line2 => disp2
	);

end architecture RTL;
