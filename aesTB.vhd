--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:23:44 06/23/2013
-- Design Name:   
-- Module Name:   S:/project/aes/aes/aesTest.vhd
-- Project Name:  aes
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: aes
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
 
ENTITY aesTB IS
END aesTB;
 
ARCHITECTURE behavior OF aesTB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT aes
    PORT(
         reset : IN  std_logic;
         clock : IN  std_logic;
         key : IN  std_logic_vector(31 downto 0);
         keynew : IN  std_logic;
         keyload : IN  std_logic;
         keyexpansionready : OUT  std_logic;
         text : IN  std_logic_vector(127 downto 0);
         empty : OUT  std_logic;
         enable : IN  std_logic;
         ciphertext : OUT  std_logic_vector(127 downto 0);
         ready : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal reset : std_logic := '0';
   signal clock : std_logic := '0';
   signal key : std_logic_vector(31 downto 0) := (others => '0');
   signal keynew : std_logic := '0';
   signal keyload : std_logic := '0';
   signal text : std_logic_vector(127 downto 0) := (others => '0');
   signal enable : std_logic := '0';

 	--Outputs
   signal keyexpansionready : std_logic;
   signal empty : std_logic;
   signal ciphertext : std_logic_vector(127 downto 0);
   signal ready : std_logic;

   -- Clock period definitions
   constant clock_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: aes PORT MAP (
          reset => reset,
          clock => clock,
          key => key,
          keynew => keynew,
          keyload => keyload,
          keyexpansionready => keyexpansionready,
          text => text,
          empty => empty,
          enable => enable,
          ciphertext => ciphertext,
          ready => ready
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
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      reset <= '1';
      wait for clock_period*10;
      reset <= '0';
      wait for clock_period;

      -- insert stimulus here 
      --testing for FIPS-197 specified test vectors with 128 bits key TEST PASSED
      keyNew <= '1';
      keyLoad <= '1';
      key <= x"0c0d0e0f";
      wait for clock_period;
      keyNew <= '0';
      key <= x"08090a0b";
      wait for clock_period;
      key <= x"04050607";
      wait for clock_period;
      key <= x"00010203";
      wait for clock_period;
      keyLoad <= '0';
      wait for clock_period*44;
      text <= x"00112233445566778899aabbccddeeff";
      wait for clock_period;
      enable <= '1';
      wait for clock_period;
      enable <= '0';
      wait for clock_period*44;

      --testing for FIPS-197 specified test vectors with 192 bits key TEST PASSED
      keyNew <= '1';
      keyLoad <= '1';
      key <= x"14151617";
      wait for clock_period;
      keyNew <= '0';
      key <= x"10111213";
      wait for clock_period;
      key <= x"0c0d0e0f";
      wait for clock_period;
      key <= x"08090a0b";
      wait for clock_period;
      key <= x"04050607";
      wait for clock_period;
      key <= x"00010203";
      wait for clock_period;
      keyLoad <= '0';
      wait for clock_period*52;
      text <= x"00112233445566778899aabbccddeeff";
      wait for clock_period;
      enable <= '1';
      wait for clock_period;
      enable <= '0';
      wait for clock_period*100;

      --testing for FIPS-197 specified test vectors with 256 bits key TEST PASSED
      keyNew <= '1';
      keyLoad <= '1';
      key <= x"1c1d1e1f";
      wait for clock_period;
      keyNew <= '0';
      key <= x"18191a1b";
      wait for clock_period;
      key <= x"14151617";
      wait for clock_period;
      key <= x"10111213";
      wait for clock_period;
      key <= x"0c0d0e0f";
      wait for clock_period;
      key <= x"08090a0b";
      wait for clock_period;
      key <= x"04050607";
      wait for clock_period;
      key <= x"00010203";
      wait for clock_period;
      keyLoad <= '0';
      wait for clock_period*60;
      text <= x"00112233445566778899aabbccddeeff";
      wait for clock_period;
      enable <= '1';
      wait for clock_period;
      enable <= '0';
      wait for clock_period*100;

      --key:                  0123456789abcdef0123456789abcdef
      --text0:                12300000000000000000000000000000
      --expected ciphertext0: a090f740e440bd3ca1225646926784f5 TEST PASSED
      --text1:                45600000000000000000000000000000
      --expected ciphertext1: ee6a61afb526be826365dd4bf809462d TEST PASSED
      --text2:                78900000000000000000000000000000    
      --expected ciphertext2: 1fa44b5078cfcb7de28018075a9b4e9f TEST PASSED
      --text3:                abc00000000000000000000000000000
      --expected ciphertext3: 5da0d16aba72dd33e973d95337f2e88d TEST PASSED
      keyNew <= '1';
      keyLoad <= '1';
      key <= x"89abcdef";
      wait for clock_period;
      keyNew <= '0';
      key <= x"01234567";
      wait for clock_period;
      key <= x"89abcdef";
      wait for clock_period;
      key <= x"01234567";
      wait for clock_period;
      keyLoad <= '0';
      wait for clock_period*44;
      text <= x"12300000000000000000000000000000";
      enable <= '1';
      wait for clock_period;
      text <= x"45600000000000000000000000000000";
      wait for clock_period;
      text <= x"78900000000000000000000000000000";
      wait for clock_period;
      text <= x"abc00000000000000000000000000000";
      wait for clock_period;
      enable <= '0';
      wait for clock_period*44;

      --key:                  0123456789abcdef0123456789abcdef
      --text4:                def00000000000000000000000000000
      --expected ciphertext4: 1499e53e8b0105164d61665d793bd665 TEST PASSED
      text <= x"def00000000000000000000000000000";
      enable <= '1';
      wait for clock_period;
      enable <= '0';
      wait for clock_period;
      text <= x"12300000000000000000000000000000";
      enable <= '1';
      wait for clock_period;
      enable <= '0';
      wait for clock_period*44;

      wait;
   end process;

END;
