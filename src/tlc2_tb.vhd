
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

ENTITY tlc2_tb IS
END tlc2_tb;

ARCHITECTURE behavior OF tlc2_tb IS 

	-- Component Declaration for the Unit Under Test (UUT)
	COMPONENT tlc2
	PORT(
		clk : IN std_logic;
		rst, j_left, j_right : IN std_logic;          
		led : OUT std_logic_vector(2 downto 0) );
	END COMPONENT;

	--Inputs
	SIGNAL clk :  std_logic := '0';
	SIGNAL rst :  std_logic := '0';
	SIGNAL j_right : std_logic := '1';
	SIGNAL j_left : std_logic := '1';
	
	--Outputs
	SIGNAL led :  std_logic_vector(2 downto 0);

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut: tlc2 PORT MAP(
		clk => clk,
		rst => rst, j_left => j_left, j_right => j_right,
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
		wait for 15 ns;
		rst <= '0';
                wait for 25 ns; 
                rst <= '1';
                wait for 15 ns;
                j_left <= '0';
                wait for 30 ns;
                j_left <= '1';
                wait for 13000 ns;
                j_right <= '0';
                wait for 100 ns;
                j_right <= '1';
    --            wait for 1000 ns;
      --          j_left <= '0';
        --        wait for 100 ns ;
          --      j_left <= '1';
            --    wait for 1500 ns;
              --  j_right <= '0';
              --  wait for 50 ns;
              ---  j_right <= '1';
		wait;

	END PROCESS;
END;
