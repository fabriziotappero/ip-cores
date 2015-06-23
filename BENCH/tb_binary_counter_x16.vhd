--------------------------------------------------------------------------------
-- Company: 
-- Engineer: Léo Germond
--
-- Create Date:   17:02:27 11/08/2009
-- Design Name:   
-- Module Name:   C:/Users/microcon/tb_binary_counter_x16.vhd
-- Project Name:  microcon
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: binary_counter_x16
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
 
ENTITY tb_binary_counter_x16 IS
END tb_binary_counter_x16;
 
ARCHITECTURE behavior OF tb_binary_counter_x16 IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT binary_counter_x16
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         set : IN  std_logic;
         inc : IN  std_logic;
         set_value : IN  std_logic_vector(15 downto 0);
         count : OUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal set : std_logic := '0';
   signal inc : std_logic := '0';
   signal set_value : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
   signal count : std_logic_vector(15 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 us;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: binary_counter_x16 PORT MAP (
          clk => clk,
          reset => reset,
          set => set,
          inc => inc,
          set_value => set_value,
          count => count
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin	
		reset <= '0';
      -- hold reset state for 10us.
      wait for 10 us;	
		reset <= '1';
		inc <= '1';
      wait for clk_period*10;
		
		inc <= '0';
      wait for clk_period*10;
		
		set_value <= std_logic_vector(to_unsigned(2**16 - 1, 16)); 
		set <= '1';
      wait for clk_period;
		set <= '0';
		
		inc <= '1';
      wait;
   end process;

END;
