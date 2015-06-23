--------------------------------------------------------------------------------
-- Company: 
-- Engineer: Léo Germond
--
-- Create Date:   22:18:23 11/04/2009
-- Design Name:   
-- Module Name:   C:/Users/microcon/tb_generic_const_rdecal_x16.vhd
-- Project Name:  microcon
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: generic_const_rdecal_x16
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
 
ENTITY tb_generic_const_rdecal_x16 IS
END tb_generic_const_rdecal_x16;
 
ARCHITECTURE behavior OF tb_generic_const_rdecal_x16 IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT generic_const_rdecal_x16
	 GENERIC( BIT_DECAL: natural range 0 to 15);
    PORT(
         data : IN  std_logic_vector(15 downto 0);
         en : IN  std_logic;
         decal : OUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal data : std_logic_vector(15 downto 0) := (others => '0');
   signal en : std_logic := '0';

 	--Outputs
   signal decal1 : std_logic_vector(15 downto 0);
   signal decal2 : std_logic_vector(15 downto 0);
   signal decal3 : std_logic_vector(15 downto 0);
   signal decal4 : std_logic_vector(15 downto 0);
   signal decal5 : std_logic_vector(15 downto 0);
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: generic_const_rdecal_x16 generic map(BIT_DECAL => 1) PORT MAP (
          data => data,
          en => en,
          decal => decal1
        );
   uut2: generic_const_rdecal_x16 generic map(BIT_DECAL => 2) PORT MAP (
          data => data,
          en => en,
          decal => decal2
        );
   uut3: generic_const_rdecal_x16 generic map(BIT_DECAL => 3) PORT MAP (
          data => data,
          en => en,
          decal => decal3
        );
   uut4: generic_const_rdecal_x16 generic map(BIT_DECAL => 4) PORT MAP (
          data => data,
          en => en,
          decal => decal4
        );
   uut5: generic_const_rdecal_x16 generic map(BIT_DECAL => 5) PORT MAP (
          data => data,
          en => en,
          decal => decal5
        );
 

   -- Stimulus process
   stim_proc: process
   begin
		data <= x"ffff";
		en <= '0';
      wait for 100 ns;	
		en <= '1';
      wait for 100 ns;	
		en <= '0';
		
      wait for 100 ns;	
		data <= x"fafb";
		en <= '0';
      wait for 100 ns;	
		en <= '1';
      wait for 100 ns;	
		en <= '0';

      wait;
   end process;

END;
