--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:23:22 06/03/2012
-- Design Name:   
-- Module Name:   F:/Data_Temp_Ordner/Xilinx/Projekte/Test_Prj22/test_prj22/Testbench_Write.vhd
-- Project Name:  test_prj22
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: DDR2_Write_VHDL
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
 
ENTITY Testbench_Write IS
END Testbench_Write;
 
ARCHITECTURE behavior OF Testbench_Write IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT DDR2_Write_VHDL
    PORT(
         reset_in : IN  std_logic;
         clk_in : IN  std_logic;
         clk90_in : IN  std_logic;
         w_command_register : OUT  std_logic_vector(2 downto 0);
         w_cmd_ack : IN  std_logic;
         w_burst_done : OUT  std_logic;
         write_en : IN  std_logic;
         write_busy : OUT  std_logic;
         input_data : OUT  std_logic_vector(31 downto 0);
         write_data : IN  std_logic_vector(63 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal reset_in : std_logic := '0';
   signal clk_in : std_logic := '0';
   signal clk90_in : std_logic := '0';
   signal w_cmd_ack : std_logic := '0';
   signal write_en : std_logic := '0';
   signal write_data : std_logic_vector(63 downto 0) := (others => '0');

 	--Outputs
   signal w_command_register : std_logic_vector(2 downto 0);
   signal w_burst_done : std_logic;
   signal write_busy : std_logic;
   signal input_data : std_logic_vector(31 downto 0);

   -- Clock period definitions
   constant clk_in_period : time := 7.5 ns;    -- 133.33 MHz
   constant clk90_in_period : time := 7.5 ns;    -- 133.33 MHz
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: DDR2_Write_VHDL PORT MAP (
          reset_in => reset_in,
          clk_in => clk_in,
          clk90_in => clk90_in,
          w_command_register => w_command_register,
          w_cmd_ack => w_cmd_ack,
          w_burst_done => w_burst_done,
          write_en => write_en,
          write_busy => write_busy,
          input_data => input_data,
          write_data => write_data
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

		--write enable (from Control-Unit)
		write_en <= '0' , '1' after 50 ns, '0' after 60 ns;
		
		--Data to Write (from Control-Unit)
		write_data <= x"0000000000000000", x"8C7318E7639CC639" after 50 ns;

      wait;
   end process;
	
	ack_proc : process
	begin

		--wait until READ-Command
		wait until w_command_register="100";
		
		--falling edge (clk)
		wait for clk90_in_period;
		
		--user_cmd_ack (from RAM)
		w_cmd_ack <= '1';
		
		--write latency = 23		
		wait for clk90_in_period*23;
		
		--user_cmd_ack (from RAM)
		w_cmd_ack <= '0';			
		
		
		wait;		
	end process;

END;
