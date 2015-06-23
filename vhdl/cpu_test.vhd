
-- VHDL Test Bench Created from source file cpu_engine.vhd -- 12:41:11 06/20/2003
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends 
-- that these types always be used for the top-level I/O of a design in order 
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

use work.cpu_pack.ALL;

ENTITY testbench IS
END testbench;

ARCHITECTURE behavior OF testbench IS 

	COMPONENT cpu16
	PORT(
		clk_i : IN std_logic;
		switch : IN std_logic_vector(9 downto 0);
		ser_in : IN std_logic;
		temp_spo : IN std_logic;
		xm_rdat : IN std_logic_vector(7 downto 0);          
		ser_out : OUT std_logic;
		temp_spi : OUT std_logic;
		temp_ce : OUT std_logic;
		temp_sclk : OUT std_logic;
		seg1 : OUT std_logic_vector(7 downto 0);
		seg2 : OUT std_logic_vector(7 downto 0);
		led : OUT std_logic_vector(7 downto 0);
		xm_adr : OUT std_logic_vector(15 downto 0);
		xm_wdat : OUT std_logic_vector(7 downto 0);
		xm_we : OUT std_logic;
		xm_ce : OUT std_logic
		);
	END COMPONENT;

	signal	clk_i :  std_logic;
	signal	switch :  std_logic_vector(9 downto 0) := "0000000000";
	signal	ser_in :  std_logic := '0';
	signal	temp_spo :  std_logic := '0';
	signal	xm_rdat : std_logic_vector(7 downto 0) := X"33";          
	signal	ser_out : std_logic;
	signal	temp_spi : std_logic := '0';
	signal	temp_ce : std_logic;
	signal	temp_sclk : std_logic;
	signal	seg1 : std_logic_vector(7 downto 0) := X"00";
	signal	seg2 : std_logic_vector(7 downto 0) := X"00";
	signal	led : std_logic_vector(7 downto 0);
	signal	xm_adr : std_logic_vector(15 downto 0);
	signal	xm_wdat : std_logic_vector(7 downto 0);
	signal	xm_we : std_logic;
	signal	xm_ce : std_logic;

	signal clk_counter : INTEGER := 0;

BEGIN

	uut: cpu16 PORT MAP(
		clk_i => clk_i,
		switch => switch,
		ser_in => ser_in,
		ser_out => ser_out,
		temp_spo => temp_spo,
		temp_spi => temp_spi,
		temp_ce => temp_ce,
		temp_sclk => temp_sclk,
		seg1 => seg1,
		seg2 => seg2,
		led => led,
		xm_adr => xm_adr,
		xm_rdat => xm_rdat,
		xm_wdat => xm_wdat,
		xm_we => xm_we,
		xm_ce => xm_ce
	);

-- *** Test Bench - User Defined Section ***
	PROCESS -- clock process for CLK,
	BEGIN
		CLOCK_LOOP : LOOP
			CLK_I <= transport '0';
			WAIT FOR 1 ns;
			CLK_I <= transport '1';
			WAIT FOR 1 ns;
			WAIT FOR 11 ns;
			CLK_I <= transport '0';
			WAIT FOR 12 ns;
		END LOOP CLOCK_LOOP;
	END PROCESS;

	PROCESS(CLK_I)
	BEGIN
		if (rising_edge(CLK_I)) then
			CLK_COUNTER <= CLK_COUNTER + 1;

			case CLK_COUNTER is
				when 0		=>	switch(9 downto 8) <= "11";
				when 1		=>	switch(9 downto 8) <= "00";


				when 1000	=>	CLK_COUNTER <= 0;
								ASSERT (FALSE) REPORT
									"simulation done (no error)"
									SEVERITY FAILURE;
				when others	=>
			end case;
		end if;
	END PROCESS;

END;
