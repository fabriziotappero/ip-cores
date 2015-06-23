--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:54:32 06/04/2011
-- Design Name:   
-- Module Name:   C:/Users/pjf/Documents/projects/fpga/xilinx/Network/ip1/IP_complete_nomac_tb.vhd
-- Project Name:  ip1
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: IP_complete_nomac
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
use IEEE.NUMERIC_STD.ALL;
use work.axi.all;
use work.ipv4_types.all;
use work.arp_types.all;
 
ENTITY IP_complete_nomac_tb IS
END IP_complete_nomac_tb;
 
ARCHITECTURE behavior OF IP_complete_nomac_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT IP_complete_nomac
    PORT(
			-- IP Layer signals
			ip_tx_start				: in std_logic;
			ip_tx						: in ipv4_tx_type;								-- IP tx cxns
			ip_tx_result			: out std_logic_vector (1 downto 0);		-- tx status (changes during transmission)
			ip_tx_data_out_ready	: out std_logic;									-- indicates IP TX is ready to take data
			ip_rx_start				: out std_logic;									-- indicates receipt of ip frame.
			ip_rx						: out ipv4_rx_type;
			-- system signals
			rx_clk					: in  STD_LOGIC;
			tx_clk					: in  STD_LOGIC;
			reset 					: in  STD_LOGIC;
			our_ip_address 		: in STD_LOGIC_VECTOR (31 downto 0);
			our_mac_address 		: in std_logic_vector (47 downto 0);
			-- status signals
			arp_pkt_count			: out STD_LOGIC_VECTOR(7 downto 0);			-- count of arp pkts received
			ip_pkt_count			: out STD_LOGIC_VECTOR(7 downto 0);			-- number of IP pkts received for us
			-- MAC Transmitter
			mac_tx_tdata         : out  std_logic_vector(7 downto 0);	-- data byte to tx
			mac_tx_tvalid        : out  std_logic;							-- tdata is valid
			mac_tx_tready        : in std_logic;							-- mac is ready to accept data
			mac_tx_tfirst        : out  std_logic;							-- indicates first byte of frame
			mac_tx_tlast         : out  std_logic;							-- indicates last byte of frame
			-- MAC Receiver
			mac_rx_tdata         : in std_logic_vector(7 downto 0);	-- data byte received
			mac_rx_tvalid        : in std_logic;							-- indicates tdata is valid
			mac_rx_tready        : out  std_logic;							-- tells mac that we are ready to take data
			mac_rx_tlast         : in std_logic								-- indicates last byte of the trame
        );
    END COMPONENT;
    

   --Inputs
   signal ip_tx_start : std_logic := '0';
   signal ip_tx : ipv4_tx_type;

   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal our_ip_address : std_logic_vector(31 downto 0) := (others => '0');
   signal our_mac_address : std_logic_vector(47 downto 0) := (others => '0');
   signal mac_tx_tready : std_logic := '0';
   signal mac_rx_tdata : std_logic_vector(7 downto 0) := (others => '0');
   signal mac_rx_tvalid : std_logic := '0';
   signal mac_rx_tlast : std_logic := '0';
 	--Outputs
	signal ip_tx_result : std_logic_vector (1 downto 0);						-- tx status (changes during transmission)
	signal ip_tx_data_out_ready	:  std_logic;									-- indicates IP TX is ready to take data
   signal ip_rx_start : std_logic;
   signal ip_rx : ipv4_rx_type;
   signal arp_pkt_count : std_logic_vector(7 downto 0);
   signal mac_tx_tdata : std_logic_vector(7 downto 0);
   signal mac_tx_tvalid : std_logic;
   signal mac_tx_tfirst : std_logic;
   signal mac_tx_tlast : std_logic;
   signal mac_rx_tready : std_logic;

   -- Clock period definitions
   constant clk_period : time := 8 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: IP_complete_nomac PORT MAP (
          ip_tx_start => ip_tx_start,
          ip_tx => ip_tx,
          ip_tx_result => ip_tx_result,
          ip_tx_data_out_ready => ip_tx_data_out_ready,		 
          ip_rx_start => ip_rx_start,
          ip_rx => ip_rx,
          rx_clk => clk,
          tx_clk => clk,
          reset => reset,
          our_ip_address => our_ip_address,
          our_mac_address => our_mac_address,
          arp_pkt_count => arp_pkt_count,
          mac_tx_tdata => mac_tx_tdata,
          mac_tx_tvalid => mac_tx_tvalid,
          mac_tx_tready => mac_tx_tready,
			 mac_tx_tfirst => mac_tx_tfirst,
          mac_tx_tlast => mac_tx_tlast,
          mac_rx_tdata => mac_rx_tdata,
          mac_rx_tvalid => mac_rx_tvalid,
          mac_rx_tready => mac_rx_tready,
          mac_rx_tlast => mac_rx_tlast
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '1';
		wait for clk_period/2;
		clk <= '0';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 80 ns;	

		our_ip_address <= x"c0a80509";		-- 192.168.5.9
		our_mac_address <= x"002320212223";
		ip_tx_start <= '0';
      mac_tx_tready <= '0';

		reset <= '1';
      wait for clk_period*10;
		reset <= '0';
      wait for clk_period*5;
		
		-- check reset conditions
		assert ip_tx_result = IPTX_RESULT_NONE			report "ip_tx_result not initialised correctly on reset";
		assert ip_tx_data_out_ready = '0' 		report "ip_tx_data_out_ready not initialised correctly on reset";
		assert mac_tx_tvalid = '0' 						report "mac_tx_tvalid not initialised correctly on reset";
		assert mac_tx_tlast = '0' 							report " mac_tx_tlast not initialised correctly on reset";
		assert arp_pkt_count = x"00"						report " arp_pkt_count not initialised correctly on reset";
		assert ip_rx_start = '0' 							report "ip_rx_start not initialised correctly on reset";
		assert ip_rx.hdr.is_valid = '0'					report "ip_rx.hdr.is_valid not initialised correctly on reset";
		assert ip_rx.hdr.protocol = x"00"				report "ip_rx.hdr.protocol not initialised correctly on reset";
		assert ip_rx.hdr.data_length = x"0000"			report "ip_rx.hdr.data_length not initialised correctly on reset";
		assert ip_rx.hdr.src_ip_addr = x"00000000"	report "ip_rx.hdr.src_ip_addr not initialised correctly on reset";
		assert ip_rx.hdr.num_frame_errors = x"00"		report "ip_rx.hdr.num_frame_errors not initialised correctly on reset";
		assert ip_rx.data.data_in = x"00"				report "ip_rx.data.data_in not initialised correctly on reset";
		assert ip_rx.data.data_in_valid = '0'			report "ip_rx.data.data_in_valid not initialised correctly on reset";
		assert ip_rx.data.data_in_last = '0'			report "ip_rx.data.data_in_last not initialised correctly on reset";

      -- insert stimulus here 

		------------
		-- TEST 1 -- basic functional rx test with received ip pkt
		------------

		report "T1: Send an eth frame with IP pkt dst ip_address c0a80509, dst mac 002320212223";

      mac_tx_tready <= '1';
		mac_rx_tvalid <= '1';
		-- dst MAC (bc)
		mac_rx_tdata <= x"00"; wait for clk_period;
		mac_rx_tdata <= x"23"; wait for clk_period;
		mac_rx_tdata <= x"20"; wait for clk_period;
		mac_rx_tdata <= x"21"; wait for clk_period;
		mac_rx_tdata <= x"22"; wait for clk_period;
		mac_rx_tdata <= x"23"; wait for clk_period;
		-- src MAC
		mac_rx_tdata <= x"00"; wait for clk_period;
		mac_rx_tdata <= x"23"; wait for clk_period;
		mac_rx_tdata <= x"18"; wait for clk_period;
		mac_rx_tdata <= x"29"; wait for clk_period;
		mac_rx_tdata <= x"26"; wait for clk_period;
		mac_rx_tdata <= x"7c"; wait for clk_period;
		-- type
		mac_rx_tdata <= x"08"; wait for clk_period;		-- IP pkt
		mac_rx_tdata <= x"00"; wait for clk_period;
		-- ver & HL / service type
		mac_rx_tdata <= x"45"; wait for clk_period;	
		mac_rx_tdata <= x"00"; wait for clk_period;
		-- total len
		mac_rx_tdata <= x"00"; wait for clk_period;
		mac_rx_tdata <= x"18"; wait for clk_period;
		-- ID
		mac_rx_tdata <= x"00"; wait for clk_period;
		mac_rx_tdata <= x"00"; wait for clk_period;
		-- flags & frag
		mac_rx_tdata <= x"00"; wait for clk_period;
		mac_rx_tdata <= x"00"; wait for clk_period;
		-- TTL
		mac_rx_tdata <= x"00"; wait for clk_period;
		-- Protocol
		mac_rx_tdata <= x"11"; wait for clk_period;
		-- Header CKS
		mac_rx_tdata <= x"00"; wait for clk_period;
		mac_rx_tdata <= x"00"; wait for clk_period;
		-- SRC IP
		mac_rx_tdata <= x"c0"; wait for clk_period;
		mac_rx_tdata <= x"a8"; wait for clk_period;
		mac_rx_tdata <= x"05"; wait for clk_period;
		mac_rx_tdata <= x"01"; wait for clk_period;
		-- DST IP
		mac_rx_tdata <= x"c0"; wait for clk_period;
		mac_rx_tdata <= x"a8"; wait for clk_period;
		mac_rx_tdata <= x"05"; wait for clk_period;
		mac_rx_tdata <= x"09"; wait for clk_period;
				
		-- user data
		mac_rx_tdata <= x"24"; wait for clk_period;
		
		-- since we are up to the user data stage, the header should be valid and the data_in_valid should be set
		assert ip_rx.hdr.is_valid = '1'					report "T1: ip_rx.hdr.is_valid not set";
		assert ip_rx.hdr.protocol = x"11"				report "T1: ip_rx.hdr.protocol not set correctly";
		assert ip_rx.hdr.data_length = x"0004"			report "T1: ip_rx.hdr.data_length not set correctly";
		assert ip_rx.hdr.src_ip_addr = x"c0a80501"	report "T1: ip_rx.hdr.src_ip_addr not set correctly";
		assert ip_rx.hdr.num_frame_errors = x"00"		report "T1: ip_rx.hdr.num_frame_errors not set correctly";
		assert ip_rx.hdr.last_error_code = x"0"		report "T1: ip_rx.hdr.last_error_code not set correctly";
		assert ip_rx_start = '1'							report "T1: ip_rx_start not set";
		assert ip_rx.data.data_in_valid = '1'			report "T1: ip_rx.data.data_in_valid not set";

		mac_rx_tdata <= x"25"; wait for clk_period;
		mac_rx_tdata <= x"26"; wait for clk_period;
		mac_rx_tdata <= x"27"; mac_rx_tlast <= '1'; wait for clk_period;

		assert ip_rx.data.data_in_last = '1'			report "T1: ip_rx.data.data_in_last not set";
		
		
		mac_rx_tdata <= x"00";
		mac_rx_tlast <= '0';
		mac_rx_tvalid <= '0';
		wait for clk_period;
		
		assert ip_rx.data.data_in_valid = '0'			report "T1: ip_rx.data.data_in_valid not cleared";
		assert ip_rx.data.data_in_last = '0'			report "T1: ip_rx.data.data_in_last not cleared";
		assert ip_rx.hdr.num_frame_errors = x"00"		report "T1: ip_rx.hdr.num_frame_errors non zero at end of test";
		assert ip_rx.hdr.last_error_code = x"0"		report "T1: ip_rx.hdr.last_error_code indicates error at end of test";
		assert ip_rx_start = '0'							report "T1: ip_rx_start not cleared";

		------------
		-- TEST 2 -- respond with IP TX
		------------
		
		report "T2: respond with IP TX";
		
		ip_tx.hdr.protocol <= x"35";
		ip_tx.hdr.data_length <= x"0006";
		ip_tx.hdr.dst_ip_addr <= x"c0123478";
		ip_tx.data.data_out_valid <= '0';
		ip_tx.data.data_out_last <= '0';
		wait for clk_period;
		
		ip_tx_start <= '1'; wait for clk_period;
		
		ip_tx_start <= '0'; wait for clk_period;
		
		assert ip_tx_result = IPTX_RESULT_SENDING		report "T1: result should be IPTX_RESULT_SENDING";
		
		wait for clk_period*2;
		
		assert ip_tx_data_out_ready = '0'			report "T2: IP data out ready asserted too early";
		
		-- need to wait for ARP tx to complete
		
		wait for clk_period*50;
		
		assert mac_tx_tvalid = '0' 						report "T2: mac_tx_tvalid not cleared after ARP tx";
		assert mac_tx_tlast = '0' 							report "T2: mac_tx_tlast not cleared after ARP tx";

		-- now create the ARP response (rx)

		-- Send the reply
		-- Send an ARP reply: x"c0123478" has mac 02:12:03:23:04:54
		mac_rx_tvalid <= '1';
		-- dst MAC (bc)
		mac_rx_tdata <= x"ff"; wait for clk_period;
		mac_rx_tdata <= x"ff"; wait for clk_period;
		mac_rx_tdata <= x"ff"; wait for clk_period;
		mac_rx_tdata <= x"ff"; wait for clk_period;
		mac_rx_tdata <= x"ff"; wait for clk_period;
		mac_rx_tdata <= x"ff"; wait for clk_period;
		-- src MAC
		mac_rx_tdata <= x"02"; wait for clk_period;
		mac_rx_tdata <= x"12"; wait for clk_period;
		mac_rx_tdata <= x"03"; wait for clk_period;
		mac_rx_tdata <= x"23"; wait for clk_period;
		mac_rx_tdata <= x"04"; wait for clk_period;
		mac_rx_tdata <= x"54"; wait for clk_period;
		-- type
		mac_rx_tdata <= x"08"; wait for clk_period;
		mac_rx_tdata <= x"06"; wait for clk_period;
		-- HW type
		mac_rx_tdata <= x"00"; wait for clk_period;
		mac_rx_tdata <= x"01"; wait for clk_period;
		-- Protocol type
		mac_rx_tdata <= x"08"; wait for clk_period;
		mac_rx_tdata <= x"00"; wait for clk_period;
		-- HW size
		mac_rx_tdata <= x"06"; wait for clk_period;
		-- protocol size
		mac_rx_tdata <= x"04"; wait for clk_period;
		-- Opcode
		mac_rx_tdata <= x"00"; wait for clk_period;
		mac_rx_tdata <= x"02"; wait for clk_period;
		-- Sender MAC
		mac_rx_tdata <= x"02"; wait for clk_period;
		mac_rx_tdata <= x"12"; wait for clk_period;
		mac_rx_tdata <= x"03"; wait for clk_period;
		mac_rx_tdata <= x"23"; wait for clk_period;
		mac_rx_tdata <= x"04"; wait for clk_period;
		mac_rx_tdata <= x"54"; wait for clk_period;
		-- Sender IP
		mac_rx_tdata <= x"c0"; wait for clk_period;
		mac_rx_tdata <= x"12"; wait for clk_period;
		mac_rx_tdata <= x"34"; wait for clk_period;
		mac_rx_tdata <= x"78"; wait for clk_period;
		-- Target MAC
		mac_rx_tdata <= x"00"; wait for clk_period;
		mac_rx_tdata <= x"23"; wait for clk_period;
		mac_rx_tdata <= x"20"; wait for clk_period;
		mac_rx_tdata <= x"21"; wait for clk_period;
		mac_rx_tdata <= x"22"; wait for clk_period;
		mac_rx_tdata <= x"23"; wait for clk_period;
		-- Target IP
		mac_rx_tdata <= x"c0"; wait for clk_period;
		mac_rx_tdata <= x"a8"; wait for clk_period;
		mac_rx_tdata <= x"05"; wait for clk_period;
		mac_rx_tdata <= x"09"; wait for clk_period;
		mac_rx_tdata <= x"00"; wait for clk_period;
		mac_rx_tdata <= x"00"; wait for clk_period;
		mac_rx_tdata <= x"00"; wait for clk_period;
		mac_rx_tlast <= '1';
		mac_rx_tdata <= x"00"; wait for clk_period;
		mac_rx_tlast <= '0';
		mac_rx_tvalid <= '0';
			
		wait until ip_tx_data_out_ready = '1';
		
		-- start to tx IP data
		ip_tx.data.data_out_valid <= '1';
		ip_tx.data.data_out <= x"56"; wait for clk_period;
		ip_tx.data.data_out <= x"57"; wait for clk_period;
		ip_tx.data.data_out <= x"58"; wait for clk_period;
		ip_tx.data.data_out <= x"59"; wait for clk_period;
		ip_tx.data.data_out <= x"5a"; wait for clk_period;
		
		ip_tx.data.data_out <= x"5b";
		ip_tx.data.data_out_last <= '1';
		wait for clk_period;

		assert mac_tx_tlast = '1'			report "T1: mac_tx_tlast not set on last byte";

		wait for clk_period;

		ip_tx.data.data_out_valid <= '0';
		ip_tx.data.data_out_last <= '0';
		wait for clk_period*2;	

		assert ip_tx_result = IPTX_RESULT_SENT	report "T1: result should be SENT";
		wait for clk_period*2;	


		report "-- end of tests --";

      wait;
   end process;

END;
