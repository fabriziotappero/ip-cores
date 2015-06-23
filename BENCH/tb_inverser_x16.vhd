--------------------------------------------------------------------------------
-- Company: 
-- Engineer: Léo Germond
--
-- Create Date:   21:54:24 11/04/2009
-- Design Name:   
-- Module Name:   C:/Users/microcon/tb_inverser_x16.vhd
-- Project Name:  microcon
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: inverser_x16
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
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
 
ENTITY tb_inverser_x16 IS
END tb_inverser_x16;
 
ARCHITECTURE behavior OF tb_inverser_x16 IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT inverser_x16
    PORT(
         data : IN  std_logic_vector(15 downto 0);
         inverse : IN  std_logic;
         data_out : OUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal data : std_logic_vector(15 downto 0) := (others => '0');
   signal inverse : std_logic := '0';

 	--Outputs
   signal data_out : std_logic_vector(15 downto 0);
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: inverser_x16 PORT MAP (
          data => data,
          inverse => inverse,
          data_out => data_out
        );

   -- Stimulus process
   stim_proc: process
   begin
	
		data <= x"ff00";
		inverse <= '0';
		-- Init: 100 ns
      wait for 100 ns;	
		inverse <= '1';
      wait for 100 ns;	
		inverse <= '0';
		
      wait for 100 ns;
		data <= x"afaf";
		inverse <= '0';
      wait for 100 ns;	
		inverse <= '1';
      wait for 100 ns;	
		inverse <= '0';
      -- insert stimulus here 

      wait;
   end process;

END;
