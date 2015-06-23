--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:52:31 12/15/2010
-- Design Name:   
-- Module Name:   /home/vmr/aes_playground/tb_pr_serial.vhd
-- Project Name:  aes_playground
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: pr_serial
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
 
ENTITY tb_ieee_802_15_4_phy IS
END tb_ieee_802_15_4_phy;
 
ARCHITECTURE behavior OF tb_ieee_802_15_4_phy IS 
 
   constant clk_250_khz_period : time := 4 us;
   constant clk_1_mhz_period : time := 1 us;
   constant clk_8_mhz_period : time := 0.125 us;

   signal clk_1_mhz : std_logic := '0'; 
   signal clk_8_mhz : std_logic := '0'; 
        
   signal rst : std_logic := '0';
                
   signal tx_start : std_logic := '0';
   signal tx_symbol : std_logic_vector(3 downto 0) := (others => '0');
   signal tx_i_out : std_logic_vector(9 downto 0);
   signal tx_q_out : std_logic_vector(9 downto 0);
                
   signal rx_start : std_logic := '0';
   signal rx_i_in : std_logic_vector(9 downto 0) := (others => '0');
   signal rx_q_in : std_logic_vector(9 downto 0) := (others => '0');
   signal rx_sym_out : std_logic_vector(3 downto 0) := (others => '0');

BEGIN

   rx_i_in <= tx_i_out;
   rx_q_in <= tx_q_out;
 
	-- Instantiate the Unit Under Test (UUT)
   uut: entity work.ieee_802_15_4_phy(Behavioral) PORT MAP (
    clk_1_mhz,
    clk_8_mhz, 
    rst,
    tx_start,
    tx_symbol, 
    tx_i_out,
    tx_q_out,
    rx_start,
    rx_i_in,
    rx_q_in,
    rx_sym_out);
        

   -- Clock process definitions

   clk_1_mhz_process :process
   begin
		clk_1_mhz <= '0';
		wait for clk_1_mhz_period/2;
		clk_1_mhz <= '1';
		wait for clk_1_mhz_period/2;
   end process;

   clk_8_mhz_process :process
   begin
		clk_8_mhz <= '0';
		wait for clk_8_mhz_period/2;
		clk_8_mhz <= '1';
		wait for clk_8_mhz_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
     
    wait for clk_250_khz_period + clk_250_khz_period/2;

    rst <= '1';
    
    wait for clk_250_khz_period;

    rst <= '0';
    
    tx_symbol <= "1010";

    tx_start <= '1';
    rx_start <= '1';
    
    wait for 16 us;

    tx_symbol <= "0010";

    wait for 16 us;

    tx_symbol <= "0110";

    wait for 16 us;

    tx_symbol <= "1010";

    wait for 16 us;

    tx_symbol <= "0011";
		
    wait;

   end process;

END;
