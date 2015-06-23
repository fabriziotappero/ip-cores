--
-- synthesis test 4:
--  * without clock enable
--  * fast
--
-- Altera EP2C-8, Quartus 8.0: (same as hw3_grain)



library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity hw4_grain is
port (
	CLK_I : in std_logic;	
	ARESET_I : in std_logic;

	KEY_I : in std_logic;
	IV_I  : in std_logic;
	INIT_I: in std_logic;
	
	KEYSTREAM_O : out std_logic;
	KEYSTREAM_VALID_O : out std_logic	
);
end entity;


architecture behav of hw4_grain is
begin

	top: entity work.grain
	generic map ( 
		DEBUG => false,
		FAST  => true
	)
	port map (
		CLK_I => CLK_I,
		CLKEN_I => '1',
		ARESET_I => ARESET_I,
	
		KEY_I => KEY_I,
		IV_I  => IV_I,
		INIT_I=> INIT_I,
		
		KEYSTREAM_O => KEYSTREAM_O,
		KEYSTREAM_VALID_O => KEYSTREAM_VALID_O
	);

	
end behav;


