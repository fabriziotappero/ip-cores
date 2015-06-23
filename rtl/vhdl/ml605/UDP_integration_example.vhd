----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:01:00 06/11/2011 
-- Design Name: 
-- Module Name:    UDP_integration_example - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.axi.all;
use work.ipv4_types.all;
use work.arp_types.all;

entity UDP_integration_example is
    port (
		-- System signals
		------------------
      reset	                      	: in  std_logic;	      				-- asynchronous reset
      clk_in_p              			: in  std_logic;     	 				-- 200MHz clock input from board
      clk_in_n              			: in  std_logic;      

		-- System controls
		------------------
		PBTX									: in std_logic;
		PB_DO_SECOND_TX					: in std_logic;
		DO_SECOND_TX_LED					: out std_logic;
		UDP_RX								: out std_logic;
		UDP_Start							: out std_logic;
		PBTX_LED								: out std_logic;
		TX_Started							: out std_logic;
		TX_Completed						: out std_logic;
		TX_RSLT_0							: out std_logic;
		TX_RSLT_1							: out std_logic;
		reset_leds							: in std_logic;
      display                 		: out std_logic_vector(7 downto 0);
					
      -- GMII Interface
      -----------------     
      phy_resetn            			: out std_logic;
      gmii_txd                      : out std_logic_vector(7 downto 0);
      gmii_tx_en                    : out std_logic;
      gmii_tx_er                    : out std_logic;
      gmii_tx_clk                   : out std_logic;
      gmii_rxd                      : in  std_logic_vector(7 downto 0);
      gmii_rx_dv                    : in  std_logic;
      gmii_rx_er                    : in  std_logic;
      gmii_rx_clk                   : in  std_logic;
      gmii_col                      : in  std_logic;
      gmii_crs                      : in  std_logic;
      mii_tx_clk                    : in  std_logic
    );
end UDP_integration_example;

architecture Behavioral of UDP_integration_example is


  ------------------------------------------------------------------------------
  -- Component Declaration for the complete UDP layer
  ------------------------------------------------------------------------------
component UDP_Complete
	 generic (
			CLOCK_FREQ			: integer := 125000000;							-- freq of data_in_clk -- needed to timout cntr
			ARP_TIMEOUT			: integer := 60;									-- ARP response timeout (s)
			ARP_MAX_PKT_TMO	: integer := 5;									-- # wrong nwk pkts received before set error
			MAX_ARP_ENTRIES 	: integer := 255									-- max entries in the ARP store
			);
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
			clk_in_p             : in  std_logic;     	 				-- 200MHz clock input from board
			clk_in_n             : in  std_logic;
			clk_out					: out std_logic;
			reset 					: in  STD_LOGIC;
			our_ip_address 		: in STD_LOGIC_VECTOR (31 downto 0);
			our_mac_address 		: in std_logic_vector (47 downto 0);
			control					: in udp_control_type;
			-- status signals
			arp_pkt_count			: out STD_LOGIC_VECTOR(7 downto 0);			-- count of arp pkts received
			ip_pkt_count			: out STD_LOGIC_VECTOR(7 downto 0);			-- number of IP pkts received for us
			-- GMII Interface
			phy_resetn           : out std_logic;
			gmii_txd             : out std_logic_vector(7 downto 0);
			gmii_tx_en           : out std_logic;
			gmii_tx_er           : out std_logic;
			gmii_tx_clk          : out std_logic;
			gmii_rxd             : in  std_logic_vector(7 downto 0);
			gmii_rx_dv           : in  std_logic;
			gmii_rx_er           : in  std_logic;
			gmii_rx_clk          : in  std_logic;
			gmii_col             : in  std_logic;
			gmii_crs             : in  std_logic;
			mii_tx_clk           : in  std_logic
			);
end component;

--	for UDP_block : UDP_Complete  use configuration work.UDP_Complete.udpc_multi_slot_arp;


	type state_type is (IDLE, WAIT_RX_DONE, DATA_OUT, PAUSE, CHECK_SECOND_TX, SET_SEC_HDR);
	type count_mode_type is (RST, INCR, HOLD);
	type set_clr_type is (SET, CLR, HOLD);
	type sec_tx_ctrl_type is (CLR,PRIME,DO,HOLD);

	-- system signals
	signal clk_int							: std_logic;
	signal our_mac 						: STD_LOGIC_VECTOR (47 downto 0);
	signal our_ip							: STD_LOGIC_VECTOR (31 downto 0);
	signal udp_tx_int						: udp_tx_type;
	signal udp_tx_result_int			: std_logic_vector (1 downto 0);
	signal udp_tx_data_out_ready_int	: std_logic;
	signal udp_rx_int						: udp_rx_type;
	signal udp_tx_start_int 			: std_logic;
	signal udp_rx_start_int 			: std_logic;
	signal arp_pkt_count_int			: STD_LOGIC_VECTOR(7 downto 0);
	signal ip_pkt_count_int 			: STD_LOGIC_VECTOR(7 downto 0);
	signal ip_rx_hdr_int					: ipv4_rx_header_type;
	
	-- state signals
	signal state							: state_type;
	signal count							: unsigned (7 downto 0);
	signal tx_hdr							: udp_tx_header_type;
	signal tx_start_reg					: std_logic;
	signal tx_started_reg 				: std_logic;
	signal tx_fin_reg						: std_logic;
	signal prime_second_tx				: std_logic; -- if want to do a 2nd tx after the first
	signal do_second_tx					: std_logic; -- if need to do a 2nd tx as next tx
	
	-- control signals
	signal next_state						: state_type;
	signal set_state						: std_logic;
	signal set_count						: count_mode_type;
	signal set_hdr							: std_logic;
	signal set_tx_start					: set_clr_type;
	signal set_last						: std_logic;
	signal set_tx_started				: set_clr_type;
	signal set_tx_fin						: set_clr_type;
	signal first_byte_rx					: STD_LOGIC_VECTOR(7 downto 0);
	signal control_int					: udp_control_type;
	signal set_second_tx					: sec_tx_ctrl_type;

begin

	process (
		our_ip, our_mac, udp_tx_result_int, udp_rx_int, udp_tx_start_int, udp_rx_start_int, ip_rx_hdr_int,  
		udp_tx_int, count, clk_int, ip_pkt_count_int, arp_pkt_count_int,
		reset, tx_started_reg, tx_fin_reg, tx_start_reg, state, prime_second_tx, do_second_tx, set_second_tx,
		PB_DO_SECOND_TX, do_second_tx
		)
	begin
		-- set up our local addresses and default controls
		our_ip 	<= x"c0a80119";		-- 192.168.1.25
		our_mac 	<= x"002320212223";
		control_int.ip_controls.arp_controls.clear_cache <= '0';
			
		-- determine RX good and error LEDs
		if udp_rx_int.hdr.is_valid = '1' then
			UDP_RX <= '1';
		else
			UDP_RX <= '0';
		end if;
		
		UDP_Start <= udp_rx_start_int;
		TX_Started <= tx_start_reg; --tx_started_reg;
		TX_Completed <= tx_fin_reg;
		TX_RSLT_0 <= udp_tx_result_int(0);
		TX_RSLT_1 <= udp_tx_result_int(1);
		DO_SECOND_TX_LED <= prime_second_tx;
				
		-- set display leds to show IP pkt rx count on 7..4 and arp rx count on 3..0
		display (7 downto 4) <= ip_pkt_count_int (3 downto 0);
		
--		display (3 downto 0) <= arp_pkt_count_int (3 downto 0);
		case state is
			when IDLE 			=> display (3 downto 0) <= "0001";
			when WAIT_RX_DONE => display (3 downto 0) <= "0010";
			when DATA_OUT 		=> display (3 downto 0) <= "0011";
			when PAUSE	 		=> display (3 downto 0) <= "0100";
			when CHECK_SECOND_TX	=> display (3 downto 0) <= "0101";
			when SET_SEC_HDR => display (3 downto 0) <= "0110";
		end case;

	end process;
	
	-- AUTO TX process - on receipt of any UDP pkt, send a response. data sent is modified if a broadcast was received.
	
		-- TX response process - COMB
   tx_proc_combinatorial: process(
		-- inputs
		udp_rx_start_int, udp_rx_int, udp_tx_data_out_ready_int, udp_tx_result_int, ip_rx_hdr_int, 
		udp_tx_int.data.data_out_valid, PBTX, PB_DO_SECOND_TX, 
		-- state
		state, count, tx_hdr, tx_start_reg, tx_started_reg, tx_fin_reg, prime_second_tx, do_second_tx, 
		-- controls
		next_state, set_state, set_count, set_hdr, set_tx_start, set_last, 
		set_tx_started, set_tx_fin, first_byte_rx, set_second_tx
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
		first_byte_rx <= (others => '0');
		udp_tx_int.data.data_out <= (others => '0');
		udp_tx_int.data.data_out_valid <= '0';
		set_second_tx <= HOLD;
		
		if PB_DO_SECOND_TX = '1' then
			set_second_tx <= PRIME;
		end if;
		
		-- FSM
		case state is
		
			when IDLE =>
				udp_tx_int.data.data_out_valid <= '0';
				if udp_rx_start_int = '1' or PBTX = '1' then
					if udp_rx_start_int = '1' then
						first_byte_rx <= udp_rx_int.data.data_in;
					else
						first_byte_rx <= x"00";
					end if;
					set_tx_fin <= CLR;
					set_count <= RST;
					set_hdr <= '1';
					if udp_rx_int.data.data_in_last = '1' then
						set_tx_started <= SET;
						set_tx_start <= SET;
						next_state <= DATA_OUT;
						set_state <= '1';
					else
						next_state <= WAIT_RX_DONE;
						set_state <= '1';
					end if;
				end if;
					
			when WAIT_RX_DONE =>
				-- wait until RX pkt fully received
				if udp_rx_int.data.data_in_last = '1' then
					set_tx_started <= SET;
					set_tx_start <= SET;
					next_state <= DATA_OUT;
					set_state <= '1';
				end if;
			
			when DATA_OUT =>
				if udp_tx_result_int = UDPTX_RESULT_ERR then
					-- have an error from the IP TX layer, clear down the TX
					set_tx_start <= CLR;	
					set_tx_fin <= SET;
					set_tx_started <= CLR;
					set_second_tx <= CLR;
					next_state <= IDLE;
					set_state <= '1';
				else
					if udp_tx_result_int = UDPTX_RESULT_SENDING then
						set_tx_start <= CLR;		-- reset out start req as soon as we know we are sending
					end if;
					if ip_rx_hdr_int.is_broadcast = '1' then
						udp_tx_int.data.data_out <= std_logic_vector(count) or x"50";
					else
						udp_tx_int.data.data_out <= std_logic_vector(count) or x"40";
					end if;
					udp_tx_int.data.data_out_valid <= udp_tx_data_out_ready_int;
					if udp_tx_data_out_ready_int = '1' then
						if unsigned(count) = x"03" then						
							set_last <= '1';
							set_tx_fin <= SET;
							set_tx_started <= CLR;
							next_state <= PAUSE;
							set_state <= '1';
						else
							set_count <= INCR;
						end if;
					end if;
				end if;

			when PAUSE =>
				next_state <= CHECK_SECOND_TX;
				set_state <= '1';


			when CHECK_SECOND_TX =>
				if prime_second_tx = '1' then
					set_second_tx <= DO;
					next_state <= SET_SEC_HDR;
					set_state <= '1';
				else
					set_second_tx <= CLR;
					next_state <= IDLE;
					set_state <= '1';
				end if;
				
			when SET_SEC_HDR =>
				set_hdr <= '1';
					set_tx_started <= SET;
					set_tx_start <= SET;
					next_state <= DATA_OUT;
					set_state <= '1';
				
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
				do_second_tx <= '0';
				prime_second_tx <= '0';
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
					-- select the dst addr of the tx:
					-- if do_second_tx, to solaris box
					-- otherwise control according to first byte of received data:
					--   B = broadcast
					--   C = to dummy address to test timeout
					--   D to solaris box
					--   otherwise, direct to sender
					if do_second_tx = '1' then
						tx_hdr.dst_ip_addr <= x"c0a80005";	-- set dst to solaris box at 192.168.0.5
					elsif first_byte_rx = x"42" then
						tx_hdr.dst_ip_addr <= IP_BC_ADDR;	-- send to Broadcast addr
					elsif first_byte_rx = x"43" then
						tx_hdr.dst_ip_addr <= x"c0bbccdd";	-- set dst unknown so get ARP timeout
					elsif first_byte_rx = x"44" then
						tx_hdr.dst_ip_addr <= x"c0a80005";	-- set dst to solaris box at 192.168.0.5
					else
						tx_hdr.dst_ip_addr <= udp_rx_int.hdr.src_ip_addr;	-- reply to sender
					end if;
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

				-- set do_second_tx
				case set_second_tx is
					when PRIME  =>
						prime_second_tx <= '1';
					when DO =>
						prime_second_tx <= '0';
						do_second_tx <= '1';
					when CLR  =>
						prime_second_tx <= '0';
						do_second_tx <= '0';
					when HOLD =>
						prime_second_tx <= prime_second_tx;
						do_second_tx <= do_second_tx;					
				end case;
				
			end if;
		end if;

	end process;

	
	
   ------------------------------------------------------------------------------
   -- Instantiate the UDP layer
   ------------------------------------------------------------------------------
    UDP_block : UDP_Complete 
		generic map (
				ARP_TIMEOUT		=> 10		-- timeout in seconds
			 )
		PORT MAP (
				-- UDP interface
				udp_tx_start 			=> udp_tx_start_int,
				udp_txi 					=> udp_tx_int,				
				udp_tx_result			=> udp_tx_result_int,
				udp_tx_data_out_ready=> udp_tx_data_out_ready_int,
				udp_rx_start 			=> udp_rx_start_int,
				udp_rxo 					=> udp_rx_int,
				-- IP RX signals
				ip_rx_hdr				=> ip_rx_hdr_int,
				-- System interface
				clk_in_p             => clk_in_p,
				clk_in_n             => clk_in_n,
				clk_out					=> clk_int,
				reset 					=> reset,
				our_ip_address 		=> our_ip,
				our_mac_address 		=> our_mac,
				control					=> control_int,
				-- status signals
				arp_pkt_count			=> arp_pkt_count_int,
				ip_pkt_count			=> ip_pkt_count_int,
				-- GMII Interface
				-----------------     
				phy_resetn        => phy_resetn,
				gmii_txd        	=> gmii_txd,
				gmii_tx_en        => gmii_tx_en,
				gmii_tx_er        => gmii_tx_er,
				gmii_tx_clk       => gmii_tx_clk,
				gmii_rxd        	=> gmii_rxd,
				gmii_rx_dv        => gmii_rx_dv,
				gmii_rx_er        => gmii_rx_er,
				gmii_rx_clk       => gmii_rx_clk,
				gmii_col       	=> gmii_col,
				gmii_crs        	=> gmii_crs,
				mii_tx_clk        => mii_tx_clk
        );


end Behavioral;

