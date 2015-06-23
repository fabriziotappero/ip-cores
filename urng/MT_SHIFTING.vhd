--/////////////////////////MT_SHIFTING BLOCK///////////////////////////////
--Purpose: to produce functionality equivalent to following C code:
--       k = mt[state->mti];
-- 		 k ^= (k >> 11);
-- 	     k ^= (k << 7) & 0x9d2c5680UL;
--       k ^= (k << 15) & 0xefc60000UL;
--       k ^= (k >> 18); 
--
--Created by: Minzhen Ren
--Last Modified by: Minzhen Ren
--Last Modified Date: Auguest 30, 2010
--Lately Updates: 
--/////////////////////////////////////////////////////////////////
library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;
	use ieee.numeric_std.all;
	use ieee.math_real.all;
	
entity MT_SHIFTING is
	generic(
		DATA_WIDTH : Natural := 32
	);
	port(
		signal INPUT  : in  std_logic_vector( DATA_WIDTH-1 downto 0 );
		signal OUTPUT : out std_logic_vector( DATA_WIDTH-1 downto 0 )
	);
end MT_SHIFTING;

architecture BEHAVE of MT_SHIFTING is
	
	--constant
	signal MASK1 : std_logic_vector( DATA_WIDTH-1 downto 0 );
	signal MASK2 : std_logic_vector( DATA_WIDTH-1 downto 0 );
	--internal signals
	signal SIGNAL_S1 : std_logic_vector( DATA_WIDTH-1 downto 0 );
	signal SIGNAL_I1 : std_logic_vector( DATA_WIDTH-1 downto 0 );
	signal SIGNAL_S2 : std_logic_vector( DATA_WIDTH-1 downto 0 );
	signal SIGNAL_I2 : std_logic_vector( DATA_WIDTH-1 downto 0 );
	signal SIGNAL_S3 : std_logic_vector( DATA_WIDTH-1 downto 0 );
	signal SIGNAL_I3 : std_logic_vector( DATA_WIDTH-1 downto 0 );
	signal SIGNAL_S4 : std_logic_vector( DATA_WIDTH-1 downto 0 );
	
	begin
	--constant
	MASK1 <= "10011101001011000101011010000000"; -- Ox9d2c5680UL
	MASK2 <= "11101111110001100000000000000000"; -- Oxefc60000UL
	
	SIGNAL_S1 <= "00000000000" & INPUT(DATA_WIDTH-1 downto 11);
	SIGNAL_I1 <= INPUT xor SIGNAL_S1;
	SIGNAL_S2 <= SIGNAL_I1(DATA_WIDTH-8 downto 0) & "0000000";
	SIGNAL_I2 <= SIGNAL_I1 xor (SIGNAL_S2 and MASK1);
	SIGNAL_S3 <= SIGNAL_I2(DATA_WIDTH-16 downto 0) & "000000000000000";
	SIGNAL_I3 <= SIGNAL_I2 xor (SIGNAL_S3 and MASK2);
	SIGNAL_S4 <= "000000000000000000" & SIGNAL_I3(DATA_WIDTH-1 downto 18);
	
	OUTPUT <= SIGNAL_I3 xor SIGNAL_S4;
	
end BEHAVE;