--------------------------------------------------------------------------------
-- Company: TU Chemnitz, SSE
-- Engineer: Dimo Pepelyashev
--
-- Create Date:   17:08:23 03/13/2008
-- Design Name:   dff
-- Module Name:   dff_tb.vhd
-- Project Name:  dff
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- Test Bench for module: dff
--
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY tlc_tb IS
END tcl_tb;

ARCHITECTURE behavior OF tlc_tb IS 

	type sample is record
		clk : std_logic;
		rst : std_logic;
		j-left, j_right : std_logic;
		led : std_logic_vector (2 downto 0);
	end record;

	type sample_array is array(natural range <>) of sample;

	constant test_data : sample_array :=
	(	('1','0','1', '0'),
		('0','0','1', '0'),               
	        ('1','0','0', '0'),               
	        ('0','0','1', '0'),               
	        ('1','0','1', '0'),               
	        ('0','0','1', '0'),               
	        ('1','0','1', '0'),               
	        ('0','0','1', '0'),               
	        ('1','0','1', '1'),               
 	        ('0','1','1', '0'),               
 	        ('1','1','0', '0'),               
  	        ('0','0','1', '0'),               
	        ('1','0','1', '0'),               
	        ('0','0','1', '0'),               
	        ('1','0','0', '0'), 
	        ('0','0','0', '0'),
                ('1','0','0', '1'),
                ('0','0','0', '0'),                    
                ('1','0','0', '0'),                      
                ('0','0','1', '0'),       
                ('1','0','1', '0'),      
                ('0','0','1', '0'),      
                ('1','0','1', '0')
 	);
	
	-- Component Declaration for the Unit Under Test (UUT)
	COMPONENT fsm_detector
	PORT(
		clk : IN std_logic;
		rst : in std_logic;
		d : in std_logic;
		output : out std_logic );
	END COMPONENT;

	--Inputs
	SIGNAL clk : std_logic := '0';
	SIGNAL rst : std_logic := '0';
	signal d : std_logic := '0';
	--Outputs
	SIGNAL output :  std_logic;

	
BEGIN
uut: fsm_detector			-- Instantiate the Unit Under Test (UUT)
	PORT MAP(	clk => clk,
			rst => rst,
			d => d,
			output => output );

tb: PROCESS
	BEGIN
		wait for 100 ns;	-- Wait 100 ns for global reset to finish
		for i in test_data'range loop
			clk <= test_data(i).clk;
			rst <= test_data(i).rst;
			d <= test_data(i).d;
--			wait for 1 ns;	--dimo
			wait for 2 ns;
			assert output = test_data(i).output
				report "wrong output!"
				severity error;
		end loop;
		wait;					-- will wait forever
	END PROCESS;
END;
