--/////////////////////////MAGIC BLOCK///////////////////////////////
--Purpose: to produce the equivalent funtionality of following C code
--				#define MAGIC(y) (((y)&0x1) ? 0x9908b0dfUL : 0)
--Created by: Minzhen Ren
--Last Modified by: Minzhen Ren
--Last Modified Date: Auguest 28, 2010
--Lately Updates: 
--/////////////////////////////////////////////////////////////////
library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;
	use ieee.numeric_std.all;
	use ieee.math_real.all;
	
entity MAGIC is
	generic(
		DATA_WIDTH : Natural := 32
	);
	port(
		Y_IN  : in  std_logic_vector( DATA_WIDTH-1 downto 0 );
		Y_OUT : out std_logic_vector( DATA_WIDTH-1 downto 0 )
	);
end MAGIC;

architecture BEHAVE of MAGIC is 
		
	begin
	
	WHOLE : process(Y_IN)
	begin
		if (Y_IN(0) and '1') = '1' then
			Y_OUT <= "10011001000010001011000011011111"; -- 0x9908b0dfUL
		else
			Y_OUT <= ( others => '0' );
		end if;
	end process;
	
	
end BEHAVE;