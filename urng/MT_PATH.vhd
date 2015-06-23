--/////////////////////////MT_PATH BLOCK///////////////////////////////
--Purpose: to produce functionality equivalent to following C code:
--         
--
--Created by: Minzhen Ren
--Last Modified by: Minzhen Ren
--Last Modified Date: Auguest 29, 2010
--Lately Updates: 
--////////////////////////////////////////////////////////////////////
library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;
	use ieee.numeric_std.all;
	use ieee.math_real.all;
	
entity MT_PATH is
	generic(
		DATA_WIDTH : Natural := 32
	);
	port(
		signal OPRAND1 : in  std_logic_vector( DATA_WIDTH-1 downto 0 );
		signal OPRAND2 : in  std_logic_vector( DATA_WIDTH-1 downto 0 );
		signal OPRAND3 : in  std_logic_vector( DATA_WIDTH-1 downto 0 );
		signal CLK     : in  std_logic;
		signal RESET   : in  std_logic;
		signal OUTPUT : out std_logic_vector( DATA_WIDTH-1 downto 0 )
	);
end MT_PATH;

architecture BEHAVE of MT_PATH is
	
	--constant
	signal UPPER_MASK : std_logic_vector( DATA_WIDTH-1 downto 0 );
	signal LOWER_MASK : std_logic_vector( DATA_WIDTH-1 downto 0 );
	
	--Y calculation
	signal Y_OP1 : std_logic_vector( DATA_WIDTH-1 downto 0 );
	signal Y_OP2 : std_logic_vector( DATA_WIDTH-1 downto 0 );
	signal Y_D 	 : std_logic_vector( DATA_WIDTH-1 downto 0 );
	signal Y_Q   : std_logic_vector( DATA_WIDTH-1 downto 0 );
	
	signal Y_MAGIC   : std_logic_vector( DATA_WIDTH-1 downto 0 );
	
	component REG is
		generic( BIT_WIDTH  : Natural := 32);   -- Default is 8 bits
		port( CLK       	: in  std_logic;
			  RESET     	: in  std_logic; -- high asserted
			  DATA_IN   	: in  std_logic_vector( BIT_WIDTH-1 downto 0 );
			  DATA_OUT  	: out std_logic_vector( BIT_WIDTH-1 downto 0 )
			);
	end component;
	
	component MAGIC is
		generic(
		DATA_WIDTH : Natural := 32
		);
		port(
			Y_IN  : in  std_logic_vector( DATA_WIDTH-1 downto 0 );
			Y_OUT : out std_logic_vector( DATA_WIDTH-1 downto 0 )
		);
	end component;
	
	begin
	
	--constant
	UPPER_MASK <= "10000000000000000000000000000000"; --0x80000000UL
	LOWER_MASK <= "01111111111111111111111111111111"; --0x7fffffffUL
	
	Y_OP1 <= OPRAND1 and UPPER_MASK;
	Y_OP2 <= OPRAND2 and LOWER_MASK;
	Y_D <= Y_OP1 or Y_OP2;
	
	Y_REG : REG
	port map(
		CLK => CLK,
		RESET => RESET,
		DATA_IN => Y_D,
		DATA_OUT => Y_Q
	);
		
	MAGIC_Y : MAGIC
	port map(
		Y_IN => Y_Q,
		Y_OUT => Y_MAGIC
	);
	
	OUTPUT <= (OPRAND3 xor ('0' & Y_Q(DATA_WIDTH-1 downto 1))) xor Y_MAGIC;
	
end BEHAVE;