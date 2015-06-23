--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:27:09 06/12/2013
-- Design Name:   
-- Module Name:   S:/project/aes/aes/aesKeyTB.vhd
-- Project Name:  aes
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: keyExpansion
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
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY aesKeyTB IS
END aesKeyTB;
 
ARCHITECTURE behavior OF aesKeyTB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT keyExpansion
    PORT(
         reset : IN  std_logic;
         clock : IN  std_logic;
         loadKey : IN  std_logic;
         key : IN  std_logic_vector(31 downto 0);
         subKeyEnable : OUT  std_logic;
         subKeyAddress : OUT  std_logic_vector(3 downto 0);
         subKey : OUT  std_logic_vector(127 downto 0);
         keyExpansionReady : INOUT  std_logic;
         numberOfRounds : OUT  std_logic_vector(3 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal reset : std_logic := '0';
   signal clock : std_logic := '0';
   signal loadKey : std_logic := '0';
   signal key : std_logic_vector(31 downto 0) := (others => '0');

	--BiDirs
   signal keyExpansionReady : std_logic;

 	--Outputs
   signal subKeyEnable : std_logic;
   signal subKeyAddress : std_logic_vector(3 downto 0);
   signal subKey : std_logic_vector(127 downto 0);
   signal numberOfRounds : std_logic_vector(3 downto 0);

   -- Clock period definitions
   constant clock_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: keyExpansion PORT MAP (
          reset => reset,
          clock => clock,
          loadKey => loadKey,
          key => key,
          subKeyEnable => subKeyEnable,
          subKeyAddress => subKeyAddress,
          subKey => subKey,
          keyExpansionReady => keyExpansionReady,
          numberOfRounds => numberOfRounds
        );

   -- Clock process definitions
   clock_process :process
   begin
		clock <= '0';
		wait for clock_period/2;
		clock <= '1';
		wait for clock_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      wait for 100 ns;	
      wait for clock_period*10;
      reset <= '1';
      loadKey <= '1';
      key <= x"09cf4f3c";
      wait for clock_period;
      reset <= '0';
      key <= x"abf71588";
      wait for clock_period;
      key <= x"28aed2a6";
      wait for clock_period;
      key <= x"2b7e1516";
      wait for clock_period;
      loadKey <= '0';
      wait for clock_period*44;
      reset <= '1';
      loadKey <= '1';
      key <= x"522c6b7b";
      wait for clock_period;
      reset <= '0';
      key <= x"62f8ead2";
      wait for clock_period;
      key <= x"809079e5";
      wait for clock_period;
      key <= x"c810f32b";
      wait for clock_period;
      key <= x"da0e6452";
      wait for clock_period;
      key <= x"8e73b0f7";
      wait for clock_period;
      loadKey <= '0';
      wait for clock_period*52;
      reset <= '1';
      loadKey <= '1';
      key <= x"0914dff4";
      wait for clock_period;
      reset <= '0';
      key <= x"2d9810a3";
      wait for clock_period;
      key <= x"3b6108d7";
      wait for clock_period;
      key <= x"1f352c07";
      wait for clock_period;
      key <= x"857d7781";
      wait for clock_period;
      key <= x"2b73aef0";
      wait for clock_period;
      key <= x"15ca71be";
      wait for clock_period;
      key <= x"603deb10";
      wait for clock_period;
      loadKey <= '0';
      wait for clock_period*60;
      wait;
   end process;

END;
