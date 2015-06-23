--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   09:57:01 06/13/2011
-- Design Name:   
-- Module Name:   C:/Users/pjf/Documents/projects/fpga/xilinx/Network/udp1/UDP_complete_nomac_tb.vhd
-- Project Name:  udp1
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: UDP_Complete_nomac
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
use work.arp_types.all;
 
ENTITY UDP_complete_nomac_tb IS
END UDP_complete_nomac_tb;
 
ARCHITECTURE behavior OF UDP_complete_nomac_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT UDP_Complete_nomac
    PORT(
			-- UDP TX signals
			udp_tx_start			: in std_logic;							-- indicates req to tx UDP
			udp_txi					: in udp_tx_type;							-- UDP tx cxns
			udp_tx_result			: out std_logic_vector (1 downto 0);-- tx status (changes during transmission)
			udp_tx_data_out_ready: out std_logic;							-- indicates udp_tx is ready to take data
			-- UDP RX signals
			udp_rx_start			: out std_logic;							-- indicates receipt of udp header
			udp_rxo					: out udp_rx_type;
			-- IP RX signals
			ip_rx_hdr				: out ipv4_rx_header_type;
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
    
	 

	type state_type is (IDLE, DATA_OUT);
	type count_mode_type is (RST, INCR, HOLD);
	type set_clr_type is (SET, CLR, HOLD);


   --Inputs
   signal udp_tx_start_int : std_logic := '0';
   signal udp_tx_int : udp_tx_type;
   signal clk_int : std_logic := '0';
   signal reset : std_logic := '0';
   signal our_ip_address : std_logic_vector(31 downto 0) := (others => '0');
   signal our_mac_address : std_logic_vector(47 downto 0) := (others => '0');
   signal mac_tx_tready : std_logic := '0';
   signal mac_rx_tdata : std_logic_vector(7 downto 0) := (others => '0');
   signal mac_rx_tvalid : std_logic := '0';
   signal mac_rx_tlast : std_logic := '0';

 	--Outputs
   signal udp_rx_start_int : std_logic;
   signal udp_rx_int : udp_rx_type;
   signal ip_rx_hdr : ipv4_rx_header_type;
	signal udp_tx_result	: std_logic_vector (1 downto 0);
	signal udp_tx_data_out_ready_int: std_logic;

   signal arp_pkt_count : std_logic_vector(7 downto 0);
   signal ip_pkt_count : std_logic_vector(7 downto 0);
   signal mac_tx_tdata : std_logic_vector(7 downto 0);
   signal mac_tx_tvalid : std_logic;
   signal mac_tx_tfirst : std_logic;
   signal mac_tx_tlast : std_logic;
   signal mac_rx_tready : std_logic;

	signal pbtx_led : std_logic;
	signal pbtx : std_logic := '0';
	
	-- state signals
	signal state			: state_type;
	signal count			: unsigned (7 downto 0);
	signal tx_hdr			: udp_tx_header_type;
	signal tx_start_reg	: std_logic;
	signal tx_started_reg : std_logic;
	signal tx_fin_reg		: std_logic;
	
		
	-- control signals
	signal next_state		: state_type;
	signal set_state		: std_logic;
	signal set_count		: count_mode_type;
	signal set_hdr			: std_logic;
	signal set_tx_start	: set_clr_type;
	signal tx_data			: std_logic_vector (7 downto 0);
	signal set_last		: std_logic;
	signal set_tx_started : set_clr_type;
	signal set_tx_fin 	: set_clr_type;
	


   -- Clock period definitions
   constant clk_period : time := 8 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: UDP_Complete_nomac PORT MAP (
          udp_tx_start => udp_tx_start_int,
          udp_txi => udp_tx_int,
          udp_tx_result => udp_tx_result,
          udp_tx_data_out_ready => udp_tx_data_out_ready_int,
          udp_rx_start => udp_rx_start_int,
          udp_rxo => udp_rx_int,
          ip_rx_hdr => ip_rx_hdr,
          rx_clk => clk_int,
			 tx_clk => clk_int,
          reset => reset,
          our_ip_address => our_ip_address,
          our_mac_address => our_mac_address,
          arp_pkt_count => arp_pkt_count,
          ip_pkt_count => ip_pkt_count,
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
		clk_int <= '0';
		wait for clk_period/2;
		clk_int <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

		our_ip_address <= x"c0a80509";		-- 192.168.5.9
		our_mac_address <= x"002320212223";
      mac_tx_tready <= '0';

		reset <= '1';
      wait for clk_period*10;
		reset <= '0';
      wait for clk_period*5;
		
		-- check reset conditions
		assert udp_tx_result = UDPTX_RESULT_NONE		report "udp_tx_result not initialised correctly on reset";
		assert udp_tx_data_out_ready_int = '0' 		report "ip_udp_txitx.data.data_out_ready not initialised correctly on reset";
		assert mac_tx_tvalid = '0' 						report "mac_tx_tvalid not initialised correctly on reset";
		assert mac_tx_tlast = '0' 							report "mac_tx_tlast not initialised correctly on reset";
		assert arp_pkt_count = x"00"						report "arp_pkt_count not initialised correctly on reset";
		assert ip_pkt_count = x"00"						report "ip_pkt_count not initialised correctly on reset";
		assert udp_rx_start_int = '0' 							report "udp_rx_start not initialised correctly on reset";
		assert udp_rx_int.hdr.is_valid = '0'				report "udp_rx_int.hdr.is_valid not initialised correctly on reset";
		assert udp_rx_int.hdr.data_length = x"0000"		report "udp_rx_int.hdr.data_length not initialised correctly on reset";
		assert udp_rx_int.hdr.src_ip_addr = x"00000000"	report "udp_rx_int.hdr.src_ip_addr not initialised correctly on reset";
		assert udp_rx_int.hdr.src_port = x"0000"			report "udp_rx_int.hdr.src_port not initialised correctly on reset";
		assert udp_rx_int.hdr.dst_port = x"0000"			report "udp_rx_int.hdr.dst_port not initialised correctly on reset";
		assert udp_rx_int.data.data_in = x"00"				report "udp_rx_start.data.data_in not initialised correctly on reset";
		assert udp_rx_int.data.data_in_valid = '0'		report "udp_rx_start.data.data_in_valid not initialised correctly on reset";
		assert udp_rx_int.data.data_in_last = '0'			report "udp_rx_start.data.data_in_last not initialised correctly on reset";
		assert ip_rx_hdr.is_valid = '0'					report "ip_rx_hdr.is_valid not initialised correctly on reset";
		assert ip_rx_hdr.protocol = x"00"				report "ip_rx_hdr.protocol not initialised correctly on reset";
		assert ip_rx_hdr.data_length = x"0000"			report "ip_rx_hdr.data_length not initialised correctly on reset";
		assert ip_rx_hdr.src_ip_addr = x"00000000"	report "ip_rx_hdr.src_ip_addr not initialised correctly on reset";
		assert ip_rx_hdr.num_frame_errors = x"00"		report "ip_rx_hdr.num_frame_errors not initialised correctly on reset";


      -- insert stimulus here 
		
		------------
		-- TEST 1 -- send ARP request
		------------

		report "T1: Send an ARP request: who has 192.168.5.9? Tell 192.168.5.1";

      mac_tx_tready <= '1';

		mac_rx_tvalid <= '1';
		-- dst MAC (bc)
		mac_rx_tdata <= x"ff"; wait for clk_period;
		mac_rx_tdata <= x"ff"; wait for clk_period;
		mac_rx_tdata <= x"ff"; wait for clk_period;
		mac_rx_tdata <= x"ff"; wait for clk_period;
		mac_rx_tdata <= x"ff"; wait for clk_period;
		mac_rx_tdata <= x"ff"; wait for clk_period;
		-- src MAC
		mac_rx_tdata <= x"00"; wait for clk_period;
		mac_rx_tdata <= x"23"; wait for clk_period;
		mac_rx_tdata <= x"18"; wait for clk_period;
		mac_rx_tdata <= x"29"; wait for clk_period;
		mac_rx_tdata <= x"26"; wait for clk_period;
		mac_rx_tdata <= x"7c"; wait for clk_period;
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
		mac_rx_tdata <= x"01"; wait for clk_period;
		-- Sender MAC
		mac_rx_tdata <= x"00"; wait for clk_period;
		mac_rx_tdata <= x"23"; wait for clk_period;
		mac_rx_tdata <= x"18"; wait for clk_period;
		mac_rx_tdata <= x"29"; wait for clk_period;
		mac_rx_tdata <= x"26"; wait for clk_period;
		mac_rx_tdata <= x"7c"; wait for clk_period;
		-- Sender IP
		mac_rx_tdata <= x"c0"; wait for clk_period;
		mac_rx_tdata <= x"a8"; wait for clk_period;
		mac_rx_tdata <= x"05"; wait for clk_period;
		mac_rx_tdata <= x"01"; wait for clk_period;
		-- Target MAC
		mac_rx_tdata <= x"00"; wait for clk_period;
		mac_rx_tdata <= x"00"; wait for clk_period;
		mac_rx_tdata <= x"00"; wait for clk_period;
		mac_rx_tdata <= x"00"; wait for clk_period;
		mac_rx_tdata <= x"00"; wait for clk_period;
		mac_rx_tdata <= x"00"; wait for clk_period;
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
		
		-- check we got the ARP pkt
		assert arp_pkt_count = x"01"						report "T1: arp_pkt_count wrong value";
		assert ip_pkt_count = x"00"						report "T1: ip_pkt_count wrong value";
		assert udp_tx_result = UDPTX_RESULT_NONE		report "T1: udp_tx_result wrong value";
		assert udp_tx_data_out_ready_int = '0' 		report "T1: ip_udp_txitx.data.data_out_ready wrong value";
		assert udp_rx_start_int = '0' 							report "T1: udp_rx_start wrong value";
		assert udp_rx_int.hdr.is_valid = '0'				report "T1: udp_rx_int.hdr.is_valid wrong value";
		assert ip_rx_hdr.is_valid = '0'					report "T1: ip_rx_hdr.is_valid wrong value";

		-- check we tx a response
		
		wait for clk_period*25;
		assert mac_tx_tvalid = '1'							report "T1: not transmitting a response";
		wait for clk_period*25;
		assert mac_tx_tvalid = '0'							report "T1: tx held on for too long";
		
		------------
		-- TEST 2 -- send UDP pkt (same as sample from Java program
		------------
		
		report "T2: Send UDP IP pkt dst ip_address c0a80509, from port f49a to port 2694";

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
		mac_rx_tdata <= x"21"; wait for clk_period;
		-- ID
		mac_rx_tdata <= x"00"; wait for clk_period;
		mac_rx_tdata <= x"7a"; wait for clk_period;
		-- flags & frag
		mac_rx_tdata <= x"00"; wait for clk_period;
		mac_rx_tdata <= x"00"; wait for clk_period;
		-- TTL
		mac_rx_tdata <= x"80"; wait for clk_period;
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
		-- SRC port
		mac_rx_tdata <= x"f4"; wait for clk_period;
		mac_rx_tdata <= x"9a"; wait for clk_period;
		-- DST port
		mac_rx_tdata <= x"26"; wait for clk_period;
		mac_rx_tdata <= x"94"; wait for clk_period;
		-- length
		mac_rx_tdata <= x"00"; wait for clk_period;
		mac_rx_tdata <= x"0d"; wait for clk_period;
		-- cks
		mac_rx_tdata <= x"8b"; wait for clk_period;
		mac_rx_tdata <= x"79"; wait for clk_period;
		-- user data
		mac_rx_tdata <= x"68"; wait for clk_period;

		-- since we are up to the user data stage, the header should be valid and the data_in_valid should be set
		assert udp_rx_int.hdr.is_valid = '1'				report "T2: udp_rx_int.hdr.is_valid not set";
		assert udp_rx_int.hdr.data_length = x"0005"		report "T2: udp_rx_int.hdr.data_length not set correctly";
		assert udp_rx_int.hdr.src_ip_addr = x"c0a80501"	report "T2: udp_rx_int.hdr.src_ip_addr not set correctly";
		assert udp_rx_int.hdr.src_port = x"f49a"			report "T2: udp_rx_int.hdr.src_port not set correctly";
		assert udp_rx_int.hdr.dst_port = x"2694"			report "T2: udp_rx_int.hdr.dst_port not set correctly";

		assert udp_rx_start_int = '1'							report "T2: udp_rx_start not set";
		assert udp_rx_int.data.data_in_valid = '1'		report "T2: udp_rx_int.data.data_in_valid not set";

		assert ip_rx_hdr.is_valid = '1'					report "T2: ip_rx_hdr.is_valid not set";
		assert ip_rx_hdr.protocol = x"11"				report "T2: ip_rx_hdr.protocol not set correctly";
		assert ip_rx_hdr.src_ip_addr = x"c0a80501"	report "T2: ip_rx.hdr.src_ip_addr not set correctly";
		assert ip_rx_hdr.num_frame_errors = x"00"   	report "T2: ip_rx.hdr.num_frame_errors not set correctly";
		assert ip_rx_hdr.last_error_code = x"0"		report "T2: ip_rx.hdr.last_error_code not set correctly";

		-- put the rest of the user data
		mac_rx_tdata <= x"65"; wait for clk_period;
		mac_rx_tdata <= x"6c"; wait for clk_period;
		mac_rx_tdata <= x"6c"; wait for clk_period;
		mac_rx_tdata <= x"6f"; mac_rx_tlast <= '1'; wait for clk_period;

		assert udp_rx_int.data.data_in_last = '1'			report "T2: udp_rx_int.data.data_in_last not set";		
		
		mac_rx_tdata <= x"00";
		mac_rx_tlast <= '0';
		mac_rx_tvalid <= '0';
		wait for clk_period;
		
		assert udp_rx_int.data.data_in_valid = '0'		report "T2: udp_rx_int.data.data_in_valid not cleared";
		assert udp_rx_int.data.data_in_last = '0'			report "T2: udp_rx_int.data.data_in_last not cleared";
		assert udp_rx_start_int = '0'							report "T2: udp_rx_start not cleared";
		assert ip_rx_hdr.num_frame_errors = x"00"		report "T2: ip_rx_hdr.num_frame_errors non zero at end of test";
		assert ip_rx_hdr.last_error_code = x"0"		report "T2: ip_rx_hdr.last_error_code indicates error at end of test";
		assert ip_pkt_count = x"01"						report "T2: ip pkt cnt incorrect";

		wait for clk_period*20;

		------------
		-- TEST 3 -- send UDP pkt again (same as sample from Java program
		------------
		
		report "T3: Send UDP IP pkt dst ip_address c0a80509, from port f49a to port 2694";

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
		mac_rx_tdata <= x"21"; wait for clk_period;
		-- ID
		mac_rx_tdata <= x"00"; wait for clk_period;
		mac_rx_tdata <= x"7a"; wait for clk_period;
		-- flags & frag
		mac_rx_tdata <= x"00"; wait for clk_period;
		mac_rx_tdata <= x"00"; wait for clk_period;
		-- TTL
		mac_rx_tdata <= x"80"; wait for clk_period;
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
		-- SRC port
		mac_rx_tdata <= x"f4"; wait for clk_period;
		mac_rx_tdata <= x"9a"; wait for clk_period;
		-- DST port
		mac_rx_tdata <= x"26"; wait for clk_period;
		mac_rx_tdata <= x"94"; wait for clk_period;
		-- length
		mac_rx_tdata <= x"00"; wait for clk_period;
		mac_rx_tdata <= x"0d"; wait for clk_period;
		-- cks
		mac_rx_tdata <= x"8b"; wait for clk_period;
		mac_rx_tdata <= x"79"; wait for clk_period;
		-- user data
		mac_rx_tdata <= x"68"; wait for clk_period;

		-- since we are up to the user data stage, the header should be valid and the data_in_valid should be set
		assert udp_rx_int.hdr.is_valid = '1'				report "T3: udp_rx_int.hdr.is_valid not set";
		assert udp_rx_int.hdr.data_length = x"0005"		report "T3: udp_rx_int.hdr.data_length not set correctly";
		assert udp_rx_int.hdr.src_ip_addr = x"c0a80501"	report "T3: udp_rx_int.hdr.src_ip_addr not set correctly";
		assert udp_rx_int.hdr.src_port = x"f49a"			report "T3: udp_rx_int.hdr.src_port not set correctly";
		assert udp_rx_int.hdr.dst_port = x"2694"			report "T3: udp_rx_int.hdr.dst_port not set correctly";

		assert udp_rx_start_int = '1'							report "T3: udp_rx_start not set";
		assert udp_rx_int.data.data_in_valid = '1'		report "T3: udp_rx_int.data.data_in_valid not set";

		assert ip_rx_hdr.is_valid = '1'					report "T3: ip_rx_hdr.is_valid not set";
		assert ip_rx_hdr.protocol = x"11"				report "T3: ip_rx_hdr.protocol not set correctly";
		assert ip_rx_hdr.src_ip_addr = x"c0a80501"	report "T3: ip_rx.hdr.src_ip_addr not set correctly";
		assert ip_rx_hdr.num_frame_errors = x"00"   	report "T3: ip_rx.hdr.num_frame_errors not set correctly";
		assert ip_rx_hdr.last_error_code = x"0"		report "T3: ip_rx.hdr.last_error_code not set correctly";

		-- put the rest of the user data
		mac_rx_tdata <= x"65"; wait for clk_period;
		mac_rx_tdata <= x"6c"; wait for clk_period;
		mac_rx_tdata <= x"6c"; wait for clk_period;
		mac_rx_tdata <= x"6f"; mac_rx_tlast <= '1'; wait for clk_period;

		assert udp_rx_int.data.data_in_last = '1'			report "T3: udp_rx_int.data.data_in_last not set";		
		
		mac_rx_tdata <= x"00";
		mac_rx_tlast <= '0';
		mac_rx_tvalid <= '0';
		wait for clk_period;
		
		assert udp_rx_int.data.data_in_valid = '0'		report "T3: udp_rx_int.data.data_in_valid not cleared";
		assert udp_rx_int.data.data_in_last = '0'			report "T3: udp_rx_int.data.data_in_last not cleared";
		assert udp_rx_start_int = '0'							report "T3: udp_rx_start not cleared";
		assert ip_rx_hdr.num_frame_errors = x"00"		report "T3: ip_rx_hdr.num_frame_errors non zero at end of test";
		assert ip_rx_hdr.last_error_code = x"0"		report "T3: ip_rx_hdr.last_error_code indicates error at end of test";
		assert ip_pkt_count = x"02"						report "T3: ip pkt cnt incorrect";

		report "--- end of tests ---";
      wait;
   end process;
	
	-- AUTO TX process - on receipt of any UDP pkt, send a response
	
		-- TX response process - COMB
   tx_proc_combinatorial: process(
		-- inputs
		udp_rx_start_int, udp_tx_data_out_ready_int, udp_tx_int.data.data_out_valid, PBTX,
		-- state
		state, count, tx_hdr, tx_start_reg, tx_started_reg, tx_fin_reg, 
		-- controls
		next_state, set_state, set_count, set_hdr, set_tx_start, set_last, 
		set_tx_started, set_tx_fin
		)
   begin
		-- set output_followers
		udp_tx_int.hdr <= tx_hdr;
		udp_tx_int.data.data_out_last <= set_last;
		udp_tx_start_int <= tx_start_reg;

		-- set control signal defaults
		next_state <= IDLE;
		set_state <= '0';
		set_count <= HOLD;
		set_hdr <= '0';
		set_tx_start <= HOLD;
		set_last <= '0';
		set_tx_started <= HOLD;
		set_tx_fin <= HOLD;
		
		-- FSM
		case state is
		
			when IDLE =>
				udp_tx_int.data.data_out <= (others => '0');
				udp_tx_int.data.data_out_valid <= '0';
				if udp_rx_start_int = '1' or PBTX = '1' then
					set_tx_started <= SET;
					set_hdr <= '1';
					set_tx_start <= SET;
					set_tx_fin <= CLR;
					set_count <= RST;
					next_state <= DATA_OUT;
					set_state <= '1';
				end if;
						
			when DATA_OUT =>
				udp_tx_int.data.data_out <= std_logic_vector(count) or x"40";
				udp_tx_int.data.data_out_valid <= udp_tx_data_out_ready_int;
				if udp_tx_data_out_ready_int = '1' then
					set_tx_start <= CLR;
					if unsigned(count) = x"03" then						
						set_last <= '1';
						set_tx_fin <= SET;
						set_tx_started <= CLR;
						next_state <= IDLE;
						set_state <= '1';
					else
						set_count <= INCR;
					end if;
				end if;
				
		end case;
	end process;

	
	
   -- TX response process - SEQ
   tx_proc_sequential: process(clk_int)
   begin		
		if rising_edge(clk_int) then
			if reset = '1' then
				-- reset state variables
				state <= IDLE;
				count <= x"00";
				tx_start_reg <= '0';
				tx_hdr.dst_ip_addr <= (others => '0');
				tx_hdr.dst_port <= (others => '0');
				tx_hdr.src_port <= (others => '0');
				tx_hdr.data_length <= (others => '0');
				tx_hdr.checksum <= (others => '0');
				tx_started_reg <= '0';
				tx_fin_reg <= '0';
				PBTX_LED <= '0';
			else
				PBTX_LED <= PBTX;
				
				-- Next rx_state processing
				if set_state = '1' then
					state <= next_state;
				else
					state <= state;
				end if;
				
				-- count processing
				case set_count is
					when RST =>  		count <= x"00";
					when INCR => 		count <= count + 1;
					when HOLD => 		count <= count;
				end case;
				
				-- set tx hdr
				if set_hdr = '1' then
					tx_hdr.dst_ip_addr <= udp_rx_int.hdr.src_ip_addr;
					tx_hdr.dst_port <= udp_rx_int.hdr.src_port;
					tx_hdr.src_port <= udp_rx_int.hdr.dst_port;
					tx_hdr.data_length <= x"0004";
					tx_hdr.checksum <= x"0000";
				else
					tx_hdr <= tx_hdr;
				end if;
				
				-- set tx start signal
				case set_tx_start is
					when SET  => tx_start_reg <= '1';
					when CLR  => tx_start_reg <= '0';
					when HOLD => tx_start_reg <= tx_start_reg;
				end case;

				-- set tx started signal
				case set_tx_started is
					when SET  => tx_started_reg <= '1';
					when CLR  => tx_started_reg <= '0';
					when HOLD => tx_started_reg <= tx_started_reg;
				end case;

				-- set tx finished signal
				case set_tx_fin is
					when SET  => tx_fin_reg <= '1';
					when CLR  => tx_fin_reg <= '0';
					when HOLD => tx_fin_reg <= tx_fin_reg;
				end case;
				
				
			end if;
		end if;

	end process;

END;
