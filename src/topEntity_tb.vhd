
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
		rst : IN std_logic;          
		lcd_data : OUT std_logic_vector(7 downto 0);
		lcd_ena, lcd_rs, lcd_rw : out std_logic;
		led : out std_logic_vector (0 downto 0) );

	END COMPONENT;

	--Inputs
	SIGNAL clk :  std_logic := '0';
	signal rst : std_logic := '1'; -- low active reset
	
	--Outputs
	SIGNAL lcd_data :  std_logic_vector(7 downto 0);
	signal lcd_ena, lcd_rs, lcd_rw : std_logic;
	signal led : std_logic_vector (0 downto 0);

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut: topEntity PORT MAP(
		clk => clk,
		rst => rst, lcd_ena => lcd_ena, lcd_rs => lcd_rs, lcd_rw => lcd_rw,
		lcd_data => lcd_data, led => led
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
		rst <= '0';
                wait for 25 ms; 
                rst <= '1';
		wait;

	END PROCESS;
END;
