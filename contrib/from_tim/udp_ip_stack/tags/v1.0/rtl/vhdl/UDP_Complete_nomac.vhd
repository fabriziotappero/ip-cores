----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:38:49 06/13/2011 
-- Design Name: 
-- Module Name:    UDP_Complete_nomac - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Revision 0.02 - separated RX and TX clocks
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.axi.all;
use work.ipv4_types.all;
use work.arp_types.all;

entity UDP_Complete_nomac is
    Port (
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
			mac_tx_tlast         : out  std_logic;							-- indicates last byte of frame
			-- MAC Receiver
			mac_rx_tdata         : in std_logic_vector(7 downto 0);	-- data byte received
			mac_rx_tvalid        : in std_logic;							-- indicates tdata is valid
			mac_rx_tready        : out  std_logic;							-- tells mac that we are ready to take data
			mac_rx_tlast         : in std_logic								-- indicates last byte of the trame
			);
end UDP_Complete_nomac;


architecture structural of UDP_Complete_nomac is

  ------------------------------------------------------------------------------
  -- Component Declaration for UDP TX
  ------------------------------------------------------------------------------

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

  ------------------------------------------------------------------------------
  -- Component Declaration for UDP RX
  ------------------------------------------------------------------------------

    COMPONENT UDP_RX
    PORT(
			-- UDP Layer signals
			udp_rx_start			: out std_logic;							-- indicates receipt of udp header
			udp_rxo					: out udp_rx_type;
			-- system signals
			clk 						: in  STD_LOGIC;
			reset 					: in  STD_LOGIC;
			-- IP layer RX signals
			ip_rx_start				: in std_logic;							-- indicates receipt of ip header
			ip_rx						: in ipv4_rx_type
			);			
    END COMPONENT;

  ------------------------------------------------------------------------------
  -- Component Declaration for the IP layer
  ------------------------------------------------------------------------------

component IP_complete_nomac
    Port (
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
			arp_pkt_count			: out STD_LOGIC_VECTOR(7 downto 0);		-- count of arp pkts received
			ip_pkt_count			: out STD_LOGIC_VECTOR(7 downto 0);		-- number of IP pkts received for us
			-- MAC Transmitter
			mac_tx_tdata         : out  std_logic_vector(7 downto 0);	-- data byte to tx
			mac_tx_tvalid        : out  std_logic;								-- tdata is valid
			mac_tx_tready        : in std_logic;								-- mac is ready to accept data
			mac_tx_tlast         : out  std_logic;								-- indicates last byte of frame
			-- MAC Receiver
			mac_rx_tdata         : in std_logic_vector(7 downto 0);		-- data byte received
			mac_rx_tvalid        : in std_logic;								-- indicates tdata is valid
			mac_rx_tready        : out  std_logic;								-- tells mac that we are ready to take data
			mac_rx_tlast         : in std_logic									-- indicates last byte of the trame
			);
end component;

	-- IP TX connectivity
   signal ip_tx_int 						: ipv4_tx_type;
   signal ip_tx_start_int 				: std_logic;
	signal ip_tx_result_int				: std_logic_vector (1 downto 0);
	signal ip_tx_data_out_ready_int	: std_logic;

	-- IP RX connectivity
   signal ip_rx_int 			: ipv4_rx_type;
   signal ip_rx_start_int	: std_logic := '0';


begin

	-- output followers
	ip_rx_hdr <= ip_rx_int.hdr;

	-- Instantiate the UDP TX block
   udp_tx_block: UDP_TX PORT MAP (
				-- UDP Layer signals
				udp_tx_start 			=> udp_tx_start,
				udp_txi 					=> udp_txi,
				udp_tx_result			=> udp_tx_result,
				udp_tx_data_out_ready=> udp_tx_data_out_ready,
				-- system signals
				clk 						=> tx_clk,
				reset 					=> reset,
				-- IP layer TX signals
				ip_tx_start 			=> ip_tx_start_int,
				ip_tx 					=> ip_tx_int,
				ip_tx_result			=> ip_tx_result_int,
				ip_tx_data_out_ready	=> ip_tx_data_out_ready_int
        );

	-- Instantiate the UDP RX block
   udp_rx_block: UDP_RX PORT MAP (
				 -- UDP Layer signals
				 udp_rxo 				=> udp_rxo,
				 udp_rx_start 			=> udp_rx_start,
				 -- system signals
				 clk 						=> rx_clk,
				 reset 					=> reset,
				 -- IP layer RX signals
				 ip_rx_start 			=> ip_rx_start_int,
				 ip_rx 					=> ip_rx_int
        );

   ------------------------------------------------------------------------------
   -- Instantiate the IP layer
   ------------------------------------------------------------------------------
    IP_block : IP_complete_nomac PORT MAP 
		(
				-- IP interface
				ip_tx_start 			=> ip_tx_start_int,
				ip_tx 					=> ip_tx_int,
				ip_tx_result			=> ip_tx_result_int,
				ip_tx_data_out_ready	=> ip_tx_data_out_ready_int,
				ip_rx_start 			=> ip_rx_start_int,
				ip_rx 					=> ip_rx_int,
				-- System interface
				rx_clk 					=> rx_clk,
				tx_clk 					=> tx_clk,
				reset 					=> reset,
				our_ip_address 		=> our_ip_address,
				our_mac_address 		=> our_mac_address,
				-- status signals
				arp_pkt_count 			=> arp_pkt_count,
				ip_pkt_count			=> ip_pkt_count,
				-- MAC Transmitter
				mac_tx_tdata 			=> mac_tx_tdata,
				mac_tx_tvalid 			=> mac_tx_tvalid,
				mac_tx_tready 			=> mac_tx_tready,
				mac_tx_tlast 			=> mac_tx_tlast,
				-- MAC Receiver
				mac_rx_tdata 			=> mac_rx_tdata,
				mac_rx_tvalid 			=> mac_rx_tvalid,
				mac_rx_tready 			=> mac_rx_tready,
				mac_rx_tlast 			=> mac_rx_tlast
        );


end structural;

