--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   20:11:59 02/13/2011
-- Design Name:   
-- Module Name:   /home/yann/fpga/work/pdp1/vgatest.vhd
-- Project Name:  pdp1-3
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: vga
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
 
ENTITY vgatest IS
END vgatest;
 
ARCHITECTURE behavior OF vgatest IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT vga
    PORT(
         VGA_R : OUT  std_logic_vector(3 downto 0);
         VGA_G : OUT  std_logic_vector(3 downto 0);
         VGA_B : OUT  std_logic_vector(3 downto 0);
         VGA_HSYNC : OUT  std_logic;
         VGA_VSYNC : OUT  std_logic;
         CLK_50M : IN  std_logic;
         CLK_133M33 : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CLK_50M : std_logic := '0';
   signal CLK_133M33 : std_logic := '0';

 	--Outputs
   signal VGA_R : std_logic_vector(3 downto 0);
   signal VGA_G : std_logic_vector(3 downto 0);
   signal VGA_B : std_logic_vector(3 downto 0);
   signal VGA_HSYNC : std_logic;
   signal VGA_VSYNC : std_logic;

   -- Clock period definitions
   constant CLK_50M_period : time := 20ns;
   constant CLK_133M33_period : time := 7.5ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: vga PORT MAP (
          VGA_R => VGA_R,
          VGA_G => VGA_G,
          VGA_B => VGA_B,
          VGA_HSYNC => VGA_HSYNC,
          VGA_VSYNC => VGA_VSYNC,
          CLK_50M => CLK_50M,
          CLK_133M33 => CLK_133M33
        );

   -- Clock process definitions
   CLK_50M_process :process
   begin
		CLK_50M <= '0';
		wait for CLK_50M_period/2;
		CLK_50M <= '1';
		wait for CLK_50M_period/2;
   end process;
 
   CLK_133M33_process :process
   begin
		CLK_133M33 <= '0';
		wait for CLK_133M33_period/2;
		CLK_133M33 <= '1';
		wait for CLK_133M33_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100ms.
      wait for 100ms;	

      wait for CLK_50M_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
