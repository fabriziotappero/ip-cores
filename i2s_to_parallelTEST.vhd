
--------------------------------------------------------------------------------
-- Engineer: Primiano Tucci
--
-- Create Date:   17:26:41 12/19/2008
-- Design Name:   i2s_to_parallel
-- Description:   
-- 
-- VHDL Test Bench for module: i2s_to_parallel
--
--
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;

ENTITY i2s_to_parallel_tb_vhd IS
END i2s_to_parallel_tb_vhd;

ARCHITECTURE behavior OF i2s_to_parallel_tb_vhd IS 
	constant width : integer := 24;
	-- Component Declaration for the Unit Under Test (UUT)
	COMPONENT i2s_to_parallel
	generic(width : integer := width);
	PORT(
		LR_CK : IN std_logic;
		BIT_CK : IN std_logic;
		DIN : IN std_logic;
		RESET : IN std_logic;          
		DATA_L : OUT std_logic_vector(width-1 downto 0);
		DATA_R : OUT std_logic_vector(width-1 downto 0);
		STROBE : OUT std_logic;
		STROBE_LR : OUT std_logic		
		);
	END COMPONENT;

	--Inputs
	SIGNAL LR_CK :  std_logic := '0';
	SIGNAL BIT_CK :  std_logic := '0';
	SIGNAL DIN :  std_logic := '0';
	SIGNAL RESET :  std_logic := '0';

	--Outputs
	SIGNAL DATA_L :  std_logic_vector(width-1 downto 0);
	SIGNAL DATA_R :  std_logic_vector(width-1 downto 0);
	SIGNAL STROBE_LR :  std_logic;
	SIGNAL STROBE :  std_logic;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut: i2s_to_parallel PORT MAP(
		LR_CK => LR_CK,
		BIT_CK => BIT_CK,
		DIN => DIN,
		RESET => RESET,
		DATA_L => DATA_L,
		DATA_R => DATA_R,
		STROBE_LR => STROBE_LR,
		STROBE => STROBE
	);

	tb : PROCESS
	subtype test_record is std_logic_vector(23 downto 0);
	type test_array is array(positive range<>) of test_record;
	constant test_vectors : test_array:= (
		"000000000000000000000000",
		"111100000000000000000000",
		"101010101010101010101010",
		"010101010101010101010101",
		"111100001111000011110000",
		"000011110000111100001111",
		"111111110000000011111111",
		"111111111111111111111111",
		"000000000000000000000000"
	) ;
	
	constant frequency : integer := 48000;

	constant bit_clock : integer := 64 * 48000;
	constant bit_count: integer := 32;
	constant Tbcdo : time := 1 ns;
	constant Tcklr : time := 500 ps;
	variable cur_lrck : boolean := true;
	variable cur_bit : std_logic;
	variable vector :  test_record;
	
	BEGIN
		RESET <= '0';
		LR_CK <= '1';
		wait for 100 ns;
		RESET <= '1';
		-- Reset finished
		wait for 100 ns;
		BIT_CK <= '1';
		wait for 10 ns;
		LR_CK <= '0';
		
		for vector_index in test_vectors'range loop
			vector := test_vectors(vector_index);
		
			--for bit_index in -1 to bit_count-2 loop
			--for bit_index in 24 downto -7 loop
			for bit_index in vector'length downto (0-bit_count+(vector'length)+1) loop
			
				-- Determine bit to send
				if(bit_index >=0 and bit_index < vector'length) then
					cur_bit := vector(bit_index);
				else
					cur_bit := '0';
				end if;
				
				
				--Bit Clock falling edge
				BIT_CK <= '0';
				--Simulate Delay time of BCKO falling edge to DOUT valid
				wait for Tbcdo;
				--Output current data bit
				DIN <= cur_bit;
				--Wait for remaining clock time
				wait for (1000000000 ns / bit_clock / 2) - Tbcdo;
				--Bit CLock rising edge
				BIT_CK <= '1';
				wait for 1000000000 ns / bit_clock / 2;
			end loop;
			
			--Delay time of BCKO falling edge to LRCKO valid
			wait for Tcklr;
			-- Update RL_CK
			if cur_lrck = true then
				LR_CK <= '1';
				assert STROBE_LR = '0' report "Bad STROBE_LR signal" severity FAILURE;
				
				assert DATA_L(width-1 downto 0) = vector((vector'length-1) downto (vector'length-width)) report "DATA_L is incorrect" severity FAILURE;
				--assert DATA_L(width-1 downto 0) = vector(width-1 downto 0) report "DATA_L is incorrect" severity FAILURE;
			else
				LR_CK <= '0';
				assert STROBE_LR = '1' report "Bad STROBE_LR signal" severity FAILURE;
				--assert DATA_R(width-1 downto 0) = vector(width-1 downto 0) report "DATA_R is incorrect" severity FAILURE;
				assert DATA_R(width-1 downto 0) = vector((vector'length-1) downto (vector'length-width)) report "DATA_R is incorrect" severity FAILURE;
			end if;
			
			cur_lrck := not cur_lrck;			
		end loop;

		report "Testbench of I2S to Parallel completed successfully!" ;

		wait;
	END PROCESS;

END;
