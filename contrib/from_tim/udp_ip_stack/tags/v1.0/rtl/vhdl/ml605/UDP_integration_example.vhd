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
		UDP_RX								: out std_logic;
		UDP_Start							: out std_logic;
		PBTX_LED								: out std_logic;
		TX_Started							: out std_logic;
		TX_Completed						: out std_logic;
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
  -- Component Declaration for the complete IP layer
  ------------------------------------------------------------------------------
component UDP_Complete
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


	type state_type is (IDLE, DATA_OUT);
	type count_mode_type is (RST, INCR, HOLD);
	type set_clr_type is (SET, CLR, HOLD);

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
	signal udp_rx_start_reg				: std_logic;
		
	-- control signals
	signal next_state						: state_type;
	signal set_state						: std_logic;
	signal set_count						: count_mode_type;
	signal set_hdr							: std_logic;
	signal set_tx_start					: set_clr_type;
	signal set_last						: std_logic;
	signal set_tx_started				: set_clr_type;
	signal set_tx_fin						: set_clr_type;
	signal set_udp_rx_start_reg		: set_clr_type;
	
begin

	process (
		our_ip, our_mac, udp_rx_int, udp_tx_start_int, udp_rx_start_int, ip_rx_hdr_int, udp_rx_start_reg, 
		udp_tx_int, count, clk_int, ip_pkt_count_int, arp_pkt_count_int,
		reset, tx_started_reg, tx_fin_reg, tx_start_reg
		)
	begin
		-- set up our local addresses
		our_ip 	<= x"c0a80509";		-- 192.168.5.9
		our_mac 	<= x"002320212223";
			
		-- determine RX good and error LEDs
		if udp_rx_int.hdr.is_valid = '1' then
			UDP_RX <= '1';
		else
			UDP_RX <= '0';
		end if;
		
		UDP_Start <= udp_rx_start_reg;
		TX_Started <= tx_start_reg; --tx_started_reg;
		TX_Completed <= tx_fin_reg;
				
		-- set display leds to show IP pkt rx count on 7..4 and arp rx count on 3..0
		display (7 downto 4) <= ip_pkt_count_int (3 downto 0);
		display (3 downto 0) <= arp_pkt_count_int (3 downto 0);
				
	end process;
	
	-- AUTO TX process - on receipt of any UDP pkt, send a response
	
	-- TX response process - COMB
   tx_proc_combinatorial: process(
		-- inputs
		udp_rx_start_int, udp_tx_data_out_ready_int, udp_tx_int.data.data_out_valid, PBTX, reset_leds, 
		-- state
		state, count, tx_hdr, tx_start_reg, tx_started_reg, tx_fin_reg, udp_rx_start_reg, 
		-- controls
		next_state, set_state, set_count, set_hdr, set_tx_start, set_last, 
		set_tx_started, set_tx_fin, set_udp_rx_start_reg
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
		set_udp_rx_start_reg <= HOLD;
		
		-- FSM
		case state is
		
			when IDLE =>
				udp_tx_int.data.data_out <= (others => '0');
				udp_tx_int.data.data_out_valid <= '0';
				if udp_rx_start_int = '1' or PBTX = '1' then
					set_udp_rx_start_reg <= SET;
					set_tx_started <= SET;
					set_hdr <= '1';
					set_tx_start <= SET;
					set_tx_fin <= CLR;
					set_count <= RST;
					next_state <= DATA_OUT;
					set_state <= '1';
				elsif reset_leds = '1' then
					set_udp_rx_start_reg <= CLR;
					set_tx_started <= CLR;
					set_tx_fin <= CLR;
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

				-- set UDP START signal
				case set_udp_rx_start_reg is
					when SET  => udp_rx_start_reg <= '1';
					when CLR  => udp_rx_start_reg <= '0';
					when HOLD => udp_rx_start_reg <= udp_rx_start_reg;
				end case;
				
				
			end if;
		end if;

	end process;
	
	
   ------------------------------------------------------------------------------
   -- Instantiate the UDP layer
   ------------------------------------------------------------------------------
    UDP_block : UDP_Complete PORT MAP 
		(
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

