
-- VHDL Test Bench Created from source file test_lcd.vhd -- 14:39:34 12/15/2003
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

ENTITY testbench IS
END testbench;

ARCHITECTURE behavior OF testbench IS 

	COMPONENT test_lcd
	PORT(
		clk : IN std_logic;
		rst : IN std_logic;    
		db : INOUT std_logic_vector(7 downto 0);      
		done : OUT std_logic;
		e : OUT std_logic;
		r_w : OUT std_logic;
		cs1 : OUT std_logic;
		cs2 : OUT std_logic;
		d_i : OUT std_logic;
		ram_dis : OUT std_logic
		);
	END COMPONENT;

	SIGNAL done :  std_logic;
	SIGNAL e :  std_logic;
	SIGNAL r_w :  std_logic;
	SIGNAL cs1 :  std_logic;
	SIGNAL cs2 :  std_logic;
	SIGNAL d_i :  std_logic;
	SIGNAL db :  std_logic_vector(7 downto 0);
	SIGNAL clk :  std_logic;
	SIGNAL rst :  std_logic;
	SIGNAL ram_dis :  std_logic;

BEGIN

	uut: test_lcd PORT MAP(
		done => done,
		e => e,
		r_w => r_w,
		cs1 => cs1,
		cs2 => cs2,
		d_i => d_i,
		db => db,
		clk => clk,
		rst => rst,
		ram_dis => ram_dis
	);


-- *** Test Bench - User Defined Section ***
   tb : PROCESS
   BEGIN
      wait; -- will wait forever
   END PROCESS;
-- *** End Test Bench - User Defined Section ***

END;
