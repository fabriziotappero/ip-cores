--/////////////////////////LCG BLOCK///////////////////////////////
--Purpose: to produce functionality equivalent to following C code:
--         #define LCG(x) ((69069 * x) + 1) & 0xffffffffUL
--
--Created by: Minzhen Ren
--Last Modified by: Minzhen Ren
--Last Modified Date: November 2, 2010
--Lately Updates: Pipelined
--/////////////////////////////////////////////////////////////////
library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;
	use ieee.numeric_std.all;
	use ieee.math_real.all;
	
entity LCG is
	generic(
		DATA_WIDTH : Natural := 32
	);
	port(
		CLK   : in  std_logic;
		RESET : in  std_logic;
		X_IN  : in  std_logic_vector( DATA_WIDTH-1 downto 0 );
		X_OUT : out std_logic_vector( DATA_WIDTH-1 downto 0 )
	);
end LCG;

architecture BEHAV of LCG is
	
	signal MASK : std_logic_vector( DATA_WIDTH-1 downto 0 );
	signal MULTIPLICAND : std_logic_vector( DATA_WIDTH-1 downto 0 );
	signal OP_Q : std_logic_vector( 2*DATA_WIDTH-1 downto 0 );
	signal OP_D : std_logic_vector( 2*DATA_WIDTH-1 downto 0 );		
	signal OP_TEMP : std_logic_vector( 2*DATA_WIDTH-1 downto 0 );
	
	component REG is 
		generic( BIT_WIDTH  : Natural := 64);   -- Default is 8 bits
		port( 
			CLK       : in  std_logic;
			RESET     : in  std_logic; -- high asserted
			DATA_IN   : in  std_logic_vector( BIT_WIDTH-1 downto 0 );
			DATA_OUT  : out std_logic_vector( BIT_WIDTH-1 downto 0 )
        );
	end component;
	
	begin
	
		MASK <= ( others => '1' ); --0xffffffffUL
		MULTIPLICAND <= "00000000000000010000110111001101"; --69069
		
		OP_D <= X_IN * MULTIPLICAND; -- + 1;
		
		OP_REG : REG
		generic map(
			BIT_WIDTH => 64
		)
		port map(
			CLK => CLK,
			RESET => RESET,
			DATA_IN => OP_D,
			DATA_OUT => OP_Q
		);		
			
		OP_TEMP <= OP_Q + 1;	
		X_OUT <= MASK and OP_TEMP( DATA_WIDTH-1 downto 0);
	
end BEHAV;
	