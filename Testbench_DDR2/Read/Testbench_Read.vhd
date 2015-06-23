--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:44:10 06/03/2012
-- Design Name:   
-- Module Name:   F:/Data_Temp_Ordner/Xilinx/Projekte/Test_Prj22/test_prj22/Testbench_Read.vhd
-- Project Name:  test_prj22
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: DDR2_Read_VHDL
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
 
ENTITY Testbench_Read IS
END Testbench_Read;
 
ARCHITECTURE behavior OF Testbench_Read IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT DDR2_Read_VHDL
    PORT(
         reset_in : IN  std_logic;
         clk_in : IN  std_logic;
         clk90_in : IN  std_logic;
         r_command_register : OUT  std_logic_vector(2 downto 0);
         r_cmd_ack : IN  std_logic;
         r_burst_done : OUT  std_logic;
         r_data_valid : IN  std_logic;
         read_en : IN  std_logic;
         read_busy : OUT  std_logic;
         output_data : IN  std_logic_vector(31 downto 0);
         read_data : OUT  std_logic_vector(63 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal reset_in : std_logic := '0';
   signal clk_in : std_logic := '0';
   signal clk90_in : std_logic := '0';
   signal r_cmd_ack : std_logic := '0';
   signal r_data_valid : std_logic := '0';
   signal read_en : std_logic := '0';
   signal output_data : std_logic_vector(31 downto 0) := (others => '0');

 	--Outputs
   signal r_command_register : std_logic_vector(2 downto 0);
   signal r_burst_done : std_logic;
   signal read_busy : std_logic;
   signal read_data : std_logic_vector(63 downto 0);

   -- Clock period definitions
   constant clk_in_period : time := 7.5 ns;    -- 133.33 MHz
   constant clk90_in_period : time := 7.5 ns;  -- 133.33 MHz
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: DDR2_Read_VHDL PORT MAP (
          reset_in => reset_in,
          clk_in => clk_in,
          clk90_in => clk90_in,
          r_command_register => r_command_register,
          r_cmd_ack => r_cmd_ack,
          r_burst_done => r_burst_done,
          r_data_valid => r_data_valid,
          read_en => read_en,
          read_busy => read_busy,
          output_data => output_data,
          read_data => read_data
        );

   -- Clock process definitions
   clk_in_process :process
   begin
		clk_in <= '0';
		wait for clk_in_period/2;
		clk_in <= '1';
		wait for clk_in_period/2;
   end process;
 
   -- Clk 90Phase shift
   clk90_in_process :process
   begin
		clk90_in <= '1';
		wait for clk90_in_period/4;
		clk90_in <= '0';
		wait for clk90_in_period/2;
		clk90_in <= '1';
		wait for clk90_in_period/4;		
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 50 ns.
      wait for 50 ns;	

      -- insert stimulus here 
		reset_in <= '1' , '0' after 10 ns; -- kurzer Reset Impuls
		
		--read enable (from Control-Unit)
		read_en <= '0' , '1' after 50 ns, '0' after 60 ns;

      wait;
   end process;
	
	ack_proc : process
	begin

		--wait until READ-Command
		wait until r_command_register="110";
		
		--falling edge (clk)
		wait for clk90_in_period;
		
		--user_cmd_ack (from RAM)
		r_cmd_ack <= '1';	
		
		--read latency = 17-1 = 16		
		wait for clk90_in_period*16;
		
		--rising edge (ckl90)
		wait for clk90_in_period/4;
		wait for clk90_in_period/4;
		wait for clk90_in_period/4;
		
		--data (LSB)
		output_data <= x"639CC639";
		
		-- user_data_valid (from RAM)
		r_data_valid <= '1';
		
		--1clk pause
		wait for clk90_in_period;
		
		--data (MSB)
		output_data <= x"8C7318E7";

		--1clk pause
		wait for clk90_in_period;

		-- user_data_valid (from RAM)
		r_data_valid <= '0';		
		
		--data (default)
		output_data <= x"00000000";

		--1clk pause
		wait for clk90_in_period;		

		--user_cmd_ack (from RAM)
		r_cmd_ack <= '0';			
	
		wait;
	end process;

END;
