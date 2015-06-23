--
-- synthesis test 3:
--  * with clock enable
--  * fast
--  
--
-- Altera EP2C-8, Quartus 8.0: 286 LEs,0 bits mem, fmax = 295 MHz (320 requested)





library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity hw3_grain128 is
port (
	CLK_I : in std_logic;
	CLKEN_I : in std_logic := '1';
	ARESET_I : in std_logic;

	KEY_I : in std_logic;
	IV_I  : in std_logic;
	INIT_I: in std_logic;
	
	KEYSTREAM_O : out std_logic;
	KEYSTREAM_VALID_O : out std_logic	
);
end entity;


architecture behav of hw3_grain128 is
begin

	top: entity work.grain128
	generic map ( 
		DEBUG => false,
		FAST => true
	)
	port map (
		CLK_I => CLK_I,
		CLKEN_I => CLKEN_I,
		ARESET_I => ARESET_I,
	
		KEY_I => KEY_I,
		IV_I  => IV_I,
		INIT_I=> INIT_I,
		
		KEYSTREAM_O => KEYSTREAM_O,
		KEYSTREAM_VALID_O => KEYSTREAM_VALID_O
	);

	
end behav;

