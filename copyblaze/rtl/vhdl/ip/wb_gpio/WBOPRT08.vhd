library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity WBOPRT08 is
	port(
		-- WISHBONE SLAVE interface:
		ACK_O	: out std_ulogic;
		CLK_I	: in std_ulogic;
		DAT_I	: in std_ulogic_vector( 7 downto 0 );
		DAT_O	: out std_ulogic_vector( 7 downto 0 );
		RST_I	: in std_ulogic;
		STB_I	: in std_ulogic;
		WE_I	: in std_ulogic;
		-- Output port (non-WISHBONE signals):
		PRT_O	: out std_ulogic_vector( 7 downto 0 )
	);
end entity WBOPRT08;
architecture WBOPRT081 of WBOPRT08 is
	signal Q: std_ulogic_vector( 7 downto 0 );
begin
	REG: process( CLK_I )
	begin
		if( rising_edge( CLK_I ) ) then
			if( RST_I = '1' ) then
				Q <= B"00000000";
			elsif( (STB_I and WE_I) = '1' ) then
				Q <= DAT_I( 7 downto 0 );
			else
				Q <= Q;
			end if;
		end if;
	end process REG;
	
	ACK_O <= STB_I;
	DAT_O <= Q;
	PRT_O <= Q;

end architecture WBOPRT081;