--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:29:53 06/03/2013
-- Design Name:   
-- Module Name:   S:/project/sha256/sha256test.vhd
-- Project Name:  sha256
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: sha256forBTC
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
 
ENTITY sha256test IS
END sha256test;
 
ARCHITECTURE behavior OF sha256test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT sha256forBTC
    PORT(
         reset : IN  std_logic;
         clock : IN  std_logic;
         data : IN  std_logic_vector(511 downto 0);
         enable : IN  std_logic;
         busy : OUT  std_logic;
         digest : OUT  std_logic_vector(255 downto 0);
         ready : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal reset : std_logic := '0';
   signal clock : std_logic := '0';
   signal data : std_logic_vector(511 downto 0) := (others => '0');
   signal enable : std_logic := '0';

 	--Outputs
   signal busy : std_logic;
   signal digest : std_logic_vector(255 downto 0);
   signal ready : std_logic;

   -- Clock period definitions
   constant clock_period : time := 10 ns;
   constant chunk0 : std_logic_vector(511 downto 0) := x"61626380000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000018";
   constant chunk1 : std_logic_vector(511 downto 0) := x"6162636462636465636465666465666765666768666768696768696a68696a6b696a6b6c6a6b6c6d6b6c6d6e6c6d6e6f6d6e6f706e6f70718000000000000000";
   constant chunk2 : std_logic_vector(511 downto 0) := x"000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001c0";
   
   constant hash2b0 : std_logic_vector(255 downto 0) := x"ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad";
   constant hash2b12 : std_logic_vector(255 downto 0) := x"248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419db06c1";
   
   signal allesOK_0,allesOK_12 : std_logic := '0';
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: sha256forBTC PORT MAP (
          reset => reset,
          clock => clock,
          data => data,
          enable => enable,
          busy => busy,
          digest => digest,
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
      wait for clock_period*10;
      --load chunk0: 1 chunk test vector
      reset <= '1';
      wait for clock_period;
      reset <= '0';
      data <= chunk0;
      enable <= '1';
      wait for clock_period;
      enable <= '0';
      wait for clock_period*65;
      --load chunk12: 2 chunks test vector
      reset <= '1';
      wait for clock_period;
      reset <= '0';
      data <= chunk1;
      enable <= '1';
      wait for clock_period;
      enable <= '0';
      wait for clock_period*64;
      data <= chunk2;
      enable <= '1';
      wait for clock_period;
      enable <= '0';
      wait for clock_period*65;
      wait;
   end process;

   allesOK_0 <= '1' when hash2b0 = digest else '0';
   allesOK_12 <= '1' when hash2b12 = digest else '0';

END;
