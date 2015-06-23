--------------------------------------------------------------------------------
-- Company: 
-- Engineer: Léo Germond
--
-- Create Date:   22:06:57 11/04/2009
-- Design Name:   
-- Module Name:   C:/Users/microcon/tb_rdcal_x16.vhd
-- Project Name:  microcon
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: rdecal_x16
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
 
ENTITY tb_rdecal_x16 IS
END tb_rdecal_x16;
 
ARCHITECTURE behavior OF tb_rdecal_x16 IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT rdecal_x16
    PORT(
         data : IN  std_logic_vector(15 downto 0);
         decal_lvl : IN  std_logic_vector(3 downto 0);
         decal : OUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal data : std_logic_vector(15 downto 0) := (others => '0');
   signal decal_lvl : std_logic_vector(3 downto 0) := (others => '0');

 	--Outputs
   signal decal : std_logic_vector(15 downto 0);
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: rdecal_x16 PORT MAP (
          data => data,
          decal_lvl => decal_lvl,
          decal => decal
        );
 
 
   stim_proc: process
   begin		
		data <= x"fafb";
		decal_lvl <= x"0";
      wait for 100 ns;	
		decal_lvl <= x"0";
      wait for 100 ns;	
		decal_lvl <= x"1";
      wait for 100 ns;	
		decal_lvl <= x"2";
      wait for 100 ns;	
		decal_lvl <= x"3";
      wait for 100 ns;	
		decal_lvl <= x"4";
      wait for 100 ns;	
		decal_lvl <= x"5";
      wait for 100 ns;	
		decal_lvl <= x"6";
      wait for 100 ns;	
		decal_lvl <= x"7";
      wait for 100 ns;	
		decal_lvl <= x"8";
      wait for 100 ns;	
		decal_lvl <= x"9";
      wait for 100 ns;	
		decal_lvl <= x"a";
      wait for 100 ns;	
		decal_lvl <= x"b";
      wait for 100 ns;	
		decal_lvl <= x"c";
      wait for 100 ns;	
		decal_lvl <= x"d";
      wait for 100 ns;	
		decal_lvl <= x"e";
      wait for 100 ns;	
		decal_lvl <= x"f";

      wait;
   end process;

END;
