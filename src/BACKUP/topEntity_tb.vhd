
--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   09:44:54 03/26/2008
-- Design Name:   counter
-- Module Name:   counter_tb.vhd
-- Project Name:  clk_tb
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: counter
--
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends 
-- that these types always be used for the top-level I/O of a design in order 
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY topEntity_tb IS
END topEntity_tb;

ARCHITECTURE behavior OF topEntity_tb IS 

	-- Component Declaration for the Unit Under Test (UUT)
	COMPONENT topEntity
	PORT(
		clk : IN std_logic;
		j_down, j_left, j_right, j_up : IN std_logic;          
		led : OUT std_logic_vector(3 downto 0) );
	END COMPONENT;

	--Inputs
	SIGNAL clk :  std_logic := '0';
	signal j_down : std_logic := '1';
	SIGNAL j_right : std_logic := '1';
	SIGNAL j_left : std_logic := '1';
	signal j_up : std_logic := '1';
	
	--Outputs
	SIGNAL led :  std_logic_vector(3 downto 0);

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut: topEntity PORT MAP(
		clk => clk,
		j_down => j_down, j_left => j_left, j_right => j_right, j_up => j_up,
		led => led
	);

	tb_clk : PROCESS
	BEGIN

		-- Wait 100 ns for global reset to finish
		--wait for 100 ns;

		clk <= not clk;
		wait for 5 ns;
		-- Place stimulus here
	END PROCESS;

	tb_s: PROCESS
	BEGIN
		wait for 15 ms;
		j_down <= '0';
                wait for 25 ms; 
                j_down <= '1';
                wait for 150 ms;
                j_left <= '0';
                wait for 35 ms;
                j_left <= '1';
                wait for 100 ms;
                j_right <= '0';
                wait for 30 ms;
                j_right <= '1';
--                wait for 70 ms;
--                j_left <= '0';
--                wait for 30 ms ;
--                j_left <= '1';
--                wait for 100 ms;
--                j_up <= '0';
--                wait for 40 ms;
--                j_up <= '1';
--                wait for 120 ms;
--                j_right <= '0';
--                wait for 35 ms;
--                j_right <= '1';
		wait;

	END PROCESS;
END;
