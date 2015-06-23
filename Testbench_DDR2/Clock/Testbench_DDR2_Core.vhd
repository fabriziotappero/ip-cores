--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:51:05 06/03/2012
-- Design Name:   
-- Module Name:   F:/Data_Temp_Ordner/Xilinx/Projekte/Test_Prj22/test_prj22/Testbench_DDR2_Core.vhd
-- Project Name:  test_prj22
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: DDR2_Ram_Core
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
 
ENTITY Testbench_DDR2_Core IS
END Testbench_DDR2_Core;
 
ARCHITECTURE behavior OF Testbench_DDR2_Core IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT DDR2_Ram_Core
    PORT(
         cntrl0_ddr2_dq : INOUT  std_logic_vector(15 downto 0);
         cntrl0_ddr2_a : OUT  std_logic_vector(12 downto 0);
         cntrl0_ddr2_ba : OUT  std_logic_vector(1 downto 0);
         cntrl0_ddr2_cke : OUT  std_logic;
         cntrl0_ddr2_cs_n : OUT  std_logic;
         cntrl0_ddr2_ras_n : OUT  std_logic;
         cntrl0_ddr2_cas_n : OUT  std_logic;
         cntrl0_ddr2_we_n : OUT  std_logic;
         cntrl0_ddr2_odt : OUT  std_logic;
         cntrl0_ddr2_dm : OUT  std_logic_vector(1 downto 0);
         cntrl0_rst_dqs_div_in : IN  std_logic;
         cntrl0_rst_dqs_div_out : OUT  std_logic;
         sys_clk_in : IN  std_logic;
         reset_in_n : IN  std_logic;
         cntrl0_burst_done : IN  std_logic;
         cntrl0_init_done : OUT  std_logic;
         cntrl0_ar_done : OUT  std_logic;
         cntrl0_user_data_valid : OUT  std_logic;
         cntrl0_auto_ref_req : OUT  std_logic;
         cntrl0_user_cmd_ack : OUT  std_logic;
         cntrl0_user_command_register : IN  std_logic_vector(2 downto 0);
         cntrl0_clk_tb : OUT  std_logic;
         cntrl0_clk90_tb : OUT  std_logic;
         cntrl0_sys_rst_tb : OUT  std_logic;
         cntrl0_sys_rst90_tb : OUT  std_logic;
         cntrl0_sys_rst180_tb : OUT  std_logic;
         cntrl0_user_output_data : OUT  std_logic_vector(31 downto 0);
         cntrl0_user_input_data : IN  std_logic_vector(31 downto 0);
         cntrl0_user_data_mask : IN  std_logic_vector(3 downto 0);
         cntrl0_user_input_address : IN  std_logic_vector(24 downto 0);
         cntrl0_ddr2_dqs : INOUT  std_logic_vector(1 downto 0);
         cntrl0_ddr2_dqs_n : INOUT  std_logic_vector(1 downto 0);
         cntrl0_ddr2_ck : OUT  std_logic_vector(0 downto 0);
         cntrl0_ddr2_ck_n : OUT  std_logic_vector(0 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal cntrl0_rst_dqs_div_in : std_logic := '0';
   signal sys_clk_in : std_logic := '0';
   signal reset_in_n : std_logic := '0';
   signal cntrl0_burst_done : std_logic := '0';
   signal cntrl0_user_command_register : std_logic_vector(2 downto 0) := (others => '0');
   signal cntrl0_user_input_data : std_logic_vector(31 downto 0) := (others => '0');
   signal cntrl0_user_data_mask : std_logic_vector(3 downto 0) := (others => '0');
   signal cntrl0_user_input_address : std_logic_vector(24 downto 0) := (others => '0');

	--BiDirs
   signal cntrl0_ddr2_dq : std_logic_vector(15 downto 0);
   signal cntrl0_ddr2_dqs : std_logic_vector(1 downto 0);
   signal cntrl0_ddr2_dqs_n : std_logic_vector(1 downto 0);

 	--Outputs
   signal cntrl0_ddr2_a : std_logic_vector(12 downto 0);
   signal cntrl0_ddr2_ba : std_logic_vector(1 downto 0);
   signal cntrl0_ddr2_cke : std_logic;
   signal cntrl0_ddr2_cs_n : std_logic;
   signal cntrl0_ddr2_ras_n : std_logic;
   signal cntrl0_ddr2_cas_n : std_logic;
   signal cntrl0_ddr2_we_n : std_logic;
   signal cntrl0_ddr2_odt : std_logic;
   signal cntrl0_ddr2_dm : std_logic_vector(1 downto 0);
   signal cntrl0_rst_dqs_div_out : std_logic;
   signal cntrl0_init_done : std_logic;
   signal cntrl0_ar_done : std_logic;
   signal cntrl0_user_data_valid : std_logic;
   signal cntrl0_auto_ref_req : std_logic;
   signal cntrl0_user_cmd_ack : std_logic;
   signal cntrl0_clk_tb : std_logic;
   signal cntrl0_clk90_tb : std_logic;
   signal cntrl0_sys_rst_tb : std_logic;
   signal cntrl0_sys_rst90_tb : std_logic;
   signal cntrl0_sys_rst180_tb : std_logic;
   signal cntrl0_user_output_data : std_logic_vector(31 downto 0);
   signal cntrl0_ddr2_ck : std_logic_vector(0 downto 0);
   signal cntrl0_ddr2_ck_n : std_logic_vector(0 downto 0);
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
   constant sys_clk_in_period : time := 7.5 ns; -- 133.33MHz
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: DDR2_Ram_Core PORT MAP (
          cntrl0_ddr2_dq => cntrl0_ddr2_dq,
          cntrl0_ddr2_a => cntrl0_ddr2_a,
          cntrl0_ddr2_ba => cntrl0_ddr2_ba,
          cntrl0_ddr2_cke => cntrl0_ddr2_cke,
          cntrl0_ddr2_cs_n => cntrl0_ddr2_cs_n,
          cntrl0_ddr2_ras_n => cntrl0_ddr2_ras_n,
          cntrl0_ddr2_cas_n => cntrl0_ddr2_cas_n,
          cntrl0_ddr2_we_n => cntrl0_ddr2_we_n,
          cntrl0_ddr2_odt => cntrl0_ddr2_odt,
          cntrl0_ddr2_dm => cntrl0_ddr2_dm,
          cntrl0_rst_dqs_div_in => cntrl0_rst_dqs_div_in,
          cntrl0_rst_dqs_div_out => cntrl0_rst_dqs_div_out,
          sys_clk_in => sys_clk_in,
          reset_in_n => reset_in_n,
          cntrl0_burst_done => cntrl0_burst_done,
          cntrl0_init_done => cntrl0_init_done,
          cntrl0_ar_done => cntrl0_ar_done,
          cntrl0_user_data_valid => cntrl0_user_data_valid,
          cntrl0_auto_ref_req => cntrl0_auto_ref_req,
          cntrl0_user_cmd_ack => cntrl0_user_cmd_ack,
          cntrl0_user_command_register => cntrl0_user_command_register,
          cntrl0_clk_tb => cntrl0_clk_tb,
          cntrl0_clk90_tb => cntrl0_clk90_tb,
          cntrl0_sys_rst_tb => cntrl0_sys_rst_tb,
          cntrl0_sys_rst90_tb => cntrl0_sys_rst90_tb,
          cntrl0_sys_rst180_tb => cntrl0_sys_rst180_tb,
          cntrl0_user_output_data => cntrl0_user_output_data,
          cntrl0_user_input_data => cntrl0_user_input_data,
          cntrl0_user_data_mask => cntrl0_user_data_mask,
          cntrl0_user_input_address => cntrl0_user_input_address,
          cntrl0_ddr2_dqs => cntrl0_ddr2_dqs,
          cntrl0_ddr2_dqs_n => cntrl0_ddr2_dqs_n,
          cntrl0_ddr2_ck => cntrl0_ddr2_ck,
          cntrl0_ddr2_ck_n => cntrl0_ddr2_ck_n
        );

   -- Clock process definitions
   sys_clk_in_process :process
   begin
		sys_clk_in <= '0';
		wait for sys_clk_in_period/2;
		sys_clk_in <= '1';
		wait for sys_clk_in_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 50 ns.
      wait for 50 ns;	

      -- insert stimulus here 
		reset_in_n <= '1'; -- reset disable

      wait;
   end process;

END;
