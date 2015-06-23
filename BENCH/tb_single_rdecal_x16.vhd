--------------------------------------------------------------------------------
-- Company: 
-- Engineer: Léo Germond
--
-- Create Date:   22:18:23 11/04/2009
-- Design Name:   
-- Module Name:   C:/Users/microcon/tb_single_rdecal_x16.vhd
-- Project Name:  microcon
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: single_rdecal_x16
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
 
ENTITY tb_single_rdecal_x16 IS
END tb_single_rdecal_x16;
 
ARCHITECTURE behavior OF tb_single_rdecal_x16 IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT single_rdecal_x16
    PORT(
         data : IN  std_logic_vector(15 downto 0);
         op : IN  std_logic;
         decal : OUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal data : std_logic_vector(15 downto 0) := (others => '0');
   signal op : std_logic := '0';

 	--Outputs
   signal decal : std_logic_vector(15 downto 0);
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: single_rdecal_x16 PORT MAP (
          data => data,
          op => op,
          decal => decal
        );
 

   -- Stimulus process
   stim_proc: process
   begin
		data <= x"ffff";
		op <= '0';
      wait for 100 ns;	
		op <= '1';
      wait for 100 ns;	
		op <= '0';
		
      wait for 100 ns;	
		data <= x"fafb";
		op <= '0';
      wait for 100 ns;	
		op <= '1';
      wait for 100 ns;	
		op <= '0';

      wait;
   end process;

END;
