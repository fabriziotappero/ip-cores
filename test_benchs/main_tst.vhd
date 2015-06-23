--------------------------------------------------------------------------------
-- Company: 
-- Engineer:      Lazaridis Dimitris
--
-- Create Date:   19:35:47 06/27/2012
-- Design Name:   
-- Module Name:   C:/temp/MipsR2/main_tst.vhd
-- Project Name:  Mips
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: main
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
 
ENTITY main_tst IS
END main_tst;
 
ARCHITECTURE behavior OF main_tst IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT main
    PORT(
         Clk : IN  std_logic;
         Rst : IN  std_logic;
			vector_on : in std_logic_vector(2 downto 0);
			Err : OUT  std_logic;
         Bus_r : out std_logic_vector(31 downto 0)
        );
    END COMPONENT;
	 
   --Inputs
   signal Clk : std_logic := '0';
   signal Rst : std_logic := '0';
	signal vector_on : std_logic_vector(2 downto 0) := "000";
	--signal rs_t,rt_t,rd_t : std_logic_vector(4 downto 0) := "00000";
   signal Bus_r : std_logic_vector(31 downto 0);
 	--Outputs
   signal Err : std_logic:= '0';  
      
   -- Clock period definitions
   constant Clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: main PORT MAP (
          Clk => Clk,
          Rst => Rst,
			 vector_on => vector_on,
			 Err => Err,
			 Bus_r => Bus_r
                      );
	
   -- Clock process definitions
   Clk_process :process
   begin
		Clk <= '0';
		wait for Clk_period/2;
		Clk <= '1';
		wait for Clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
				
      wait for 100 ns;
	   -- insert stimulus here
		
		rst <= '0';
      vector_on <= "001";		
	
      wait for Clk_period;
		rst <= '0';
      vector_on <= "011";
		wait for Clk_period;
		rst <= '0';
      vector_on <= "101";
		wait for Clk_period;
		rst <= '0';
      vector_on <= "111";
		wait for Clk_period;
		rst <= '0';
		vector_on <= "000";
		wait for 10 ns;
		
		rst <= '1';
		   
     
      -- insert stimulus here
      wait for 1440 ns;		
      --program_on <= '1';
		wait for Clk_period*3; --fib begin
      wait for 1400 ns;  
		wait;
   end process;

END;
