--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   18:43:49 06/10/2011
-- Design Name:   
-- Module Name:   C:/Users/pjf/Documents/projects/fpga/xilinx/Network/ip1/UDP_TX_tb.vhd
-- Project Name:  ip1
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: UDP_TX
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
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.axi.all;
use work.ipv4_types.all;
 
ENTITY UDP_TX_tb IS
END UDP_TX_tb;
 
ARCHITECTURE behavior OF UDP_TX_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT UDP_TX
    PORT(
			-- UDP Layer signals
			udp_tx_start			: in std_logic;							-- indicates req to tx UDP
			udp_txi					: in udp_tx_type;							-- UDP tx cxns
			udp_tx_result			: out std_logic_vector (1 downto 0);-- tx status (changes during transmission)
			udp_tx_data_out_ready: out std_logic;							-- indicates udp_tx is ready to take data
			-- system signals
			clk 						: in  STD_LOGIC;							-- same clock used to clock mac data and ip data
			reset 					: in  STD_LOGIC;
			-- IP layer TX signals
			ip_tx_start				: out std_logic;
			ip_tx						: out ipv4_tx_type;							-- IP tx cxns
			ip_tx_result			: in std_logic_vector (1 downto 0);		-- tx status (changes during transmission)
			ip_tx_data_out_ready	: in std_logic									-- indicates IP TX is ready to take data
        );
    END COMPONENT;
    

   --Inputs
   signal udp_tx_start : std_logic := '0';
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal udp_txi : udp_tx_type;
	signal ip_tx_result			: std_logic_vector (1 downto 0);		-- tx status (changes during transmission)
	signal ip_tx_data_out_ready : std_logic;								-- indicates IP TX is ready to take data
	
	--Outputs
   signal ip_tx_start : std_logic := '0';
   signal ip_tx : ipv4_tx_type;
   signal udp_tx_result : std_logic_vector (1 downto 0);
   signal udp_tx_data_out_ready : std_logic;

   -- Clock period definitions
   constant clk_period : time := 8 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: UDP_TX PORT MAP (
          udp_tx_start => udp_tx_start,
          udp_txi => udp_txi,
          udp_tx_result => udp_tx_result,
          udp_tx_data_out_ready => udp_tx_data_out_ready,
          clk => clk,
          reset => reset,
          ip_tx_start => ip_tx_start,
          ip_tx => ip_tx,
          ip_tx_result => ip_tx_result,
          ip_tx_data_out_ready => ip_tx_data_out_ready
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
      -- hold reset state for 100 ns.
      wait for 100 ns;	

		udp_tx_start <= '0';

		udp_txi.hdr.dst_ip_addr <= (others => '0');
		udp_txi.hdr.dst_port <= (others => '0');
		udp_txi.hdr.src_port <= (others => '0');
		udp_txi.hdr.data_length <= (others => '0');
		udp_txi.hdr.checksum <= (others => '0');
      udp_txi.data.data_out_last <= '0';

		reset <= '1';
      wait for clk_period*10;
		reset <= '0';
      wait for clk_period*5;
		
		-- check reset conditions
		
		assert ip_tx_start = '0' 						report "ip_tx_start not initialised correctly on reset";
		assert ip_tx.data.data_out_valid = '0' 	report "ip_tx.data.data_out_valid not initialised correctly on reset";
		assert ip_tx.data.data_out_last = '0' 		report "ip_tx.data.data_out_last not initialised correctly on reset";
		assert udp_tx_result = UDPTX_RESULT_NONE	report "udp_tx_result not initialised correctly on reset";

      -- insert stimulus here 

      wait for clk_period*5;
		
		------------
		-- TEST 1 -- basic functional tx test 
		------------
		
		report "T1: basic functional tx test - send 56, 57, 58 to port 8532";
		
		udp_txi.hdr.dst_ip_addr <= x"c0123478";
		udp_txi.hdr.dst_port <= x"1467";
		udp_txi.hdr.src_port <= x"8532";
		udp_txi.hdr.data_length <= x"0003";

		udp_tx_start <= '1';
		ip_tx_data_out_ready <= '1';		-- IP layer can accept data
		wait for clk_period;
		udp_tx_start <= '0'; wait for clk_period;
		ip_tx_result <= IPTX_RESULT_NONE;
		
		assert udp_tx_result = UDPTX_RESULT_SENDING		report "T1: result should be UDPTX_RESULT_SENDING";
			
		wait until udp_tx_data_out_ready = '1';
		
		-- start to tx IP data
		udp_txi.data.data_out_valid <= '1';
		udp_txi.data.data_out <= x"56"; wait for clk_period;
		udp_txi.data.data_out <= x"57"; wait for clk_period;
		
		udp_txi.data.data_out <= x"58";
		udp_txi.data.data_out_last <= '1';
		wait for clk_period;

		assert ip_tx.data.data_out_last = '1'			report "T1: ip_tx.datda_out_last not set on last byte";

		udp_txi.data.data_out_valid <= '0';
		udp_txi.data.data_out_last <= '0';
		wait for clk_period*2;	
		ip_tx_result <= IPTX_RESULT_SENT;

		assert udp_tx_result = UDPTX_RESULT_SENT	report "T1: result should be UDPTX_RESULT_SENT";
		wait for clk_period*2;	

		------------
		-- TEST 2 -- 2nd pkt
		------------
		
		report "T2: send a second pkt - 56,57,58,59 to port 8532";
		
		udp_txi.hdr.dst_ip_addr <= x"c0123475";
		udp_txi.hdr.dst_port <= x"1467";
		udp_txi.hdr.src_port <= x"8532";
		udp_txi.hdr.data_length <= x"0005";

		udp_tx_start <= '1';
		ip_tx_data_out_ready <= '1';		-- IP layer can accept data
		wait for clk_period;
		udp_tx_start <= '0'; wait for clk_period;
		
		assert udp_tx_result = UDPTX_RESULT_SENDING		report "T1: result should be UDPTX_RESULT_SENDING";
			
		wait until udp_tx_data_out_ready = '1';
		
		-- start to tx IP data
		udp_txi.data.data_out_valid <= '1';
		udp_txi.data.data_out <= x"56"; wait for clk_period;
		udp_txi.data.data_out <= x"57"; wait for clk_period;
		udp_txi.data.data_out <= x"58"; wait for clk_period;
		udp_txi.data.data_out <= x"59"; wait for clk_period;
		
		udp_txi.data.data_out <= x"5a";
		udp_txi.data.data_out_last <= '1';
		wait for clk_period;
		assert ip_tx.data.data_out_last = '1'			report "T1: ip_tx.datda_out_last not set on last byte";

		udp_txi.data.data_out_valid <= '0';
		udp_txi.data.data_out_last <= '0';
		wait for clk_period*2;	

		assert udp_tx_result = UDPTX_RESULT_SENT	report "T1: result should be UDPTX_RESULT_SENT";
		wait for clk_period*2;	

		report "--- end of tests ---";

      wait;
   end process;

END;
