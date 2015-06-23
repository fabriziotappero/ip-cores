----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 		Peter Fall
-- 
-- Create Date:    5 June 2011 
-- Design Name: 
-- Module Name:    UDP_TX - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--		handle simple UDP TX
--		doesnt generate the checksum(supposedly optional)
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Revision 0.02 - Added abort of tx when receive last from upstream
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.axi.all;
use work.ipv4_types.all;

entity UDP_TX is
    Port (
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
end UDP_TX;

architecture Behavioral of UDP_TX is
	type tx_state_type is (IDLE,	PAUSE, SEND_UDP_HDR, SEND_USER_DATA);
			
	type count_mode_type is (RST, INCR, HOLD);
	type settable_cnt_type is (RST, SET, INCR, HOLD);
	type set_clr_type is (SET, CLR, HOLD);

	-- TX state variables
	signal udp_tx_state		: tx_state_type;
	signal tx_count 			: unsigned (15 downto 0);
	signal tx_result_reg		: std_logic_vector (1 downto 0);
	signal ip_tx_start_reg	: std_logic;
	signal data_out_ready_reg	: std_logic;

	-- tx control signals
	signal next_tx_state 	: tx_state_type;
	signal set_tx_state 		: std_logic;
	signal next_tx_result 	: std_logic_vector (1 downto 0);
	signal set_tx_result		: std_logic;
	signal tx_count_val		: unsigned (15 downto 0);
	signal tx_count_mode		: settable_cnt_type;
	signal tx_data				: std_logic_vector (7 downto 0);
	signal set_last			: std_logic;
	signal set_ip_tx_start	: set_clr_type;
	signal tx_data_valid		: std_logic;			-- indicates whether data is valid to tx or not
	
	-- tx temp signals
	signal total_length		: std_logic_vector (15 downto 0);	-- computed combinatorially from header size
	

-- IP datagram header format
--
--	0          4          8                      16      19             24                    31
--	--------------------------------------------------------------------------------------------
--	|              source port number            |              dest port number               |
--	|                                            |                                             |
--	--------------------------------------------------------------------------------------------
--	|                length (bytes)              |                checksum                     |
--	|          (header and data combined)        |                                             |
--	--------------------------------------------------------------------------------------------
--	|                                          Data                                            |
--	|                                                                                          |
--	--------------------------------------------------------------------------------------------
--	|                                          ....                                            |
--	|                                                                                          |
--	--------------------------------------------------------------------------------------------
		
begin
	-----------------------------------------------------------------------
	-- combinatorial process to implement FSM and determine control signals
	-----------------------------------------------------------------------

	tx_combinatorial : process(
		-- input signals
		udp_tx_start, udp_txi, clk, ip_tx_result, ip_tx_data_out_ready, 
		-- state variables
		udp_tx_state, tx_count, tx_result_reg, ip_tx_start_reg, data_out_ready_reg, 
		-- control signals
		next_tx_state, set_tx_state, next_tx_result, set_tx_result, tx_count_mode, tx_count_val, 
		tx_data, set_last, total_length, set_ip_tx_start, tx_data_valid 
		)
		
	begin
		-- set output followers
		ip_tx_start <= ip_tx_start_reg;
		ip_tx.hdr.protocol <= x"11";	-- UDP protocol
		ip_tx.hdr.data_length <= total_length;
		ip_tx.hdr.dst_ip_addr <= udp_txi.hdr.dst_ip_addr;
		if udp_tx_start = '1' and ip_tx_start_reg = '0' then
			udp_tx_result <= UDPTX_RESULT_NONE;		-- kill the result until have started the IP layer
		else
			udp_tx_result <= tx_result_reg;
		end if;
		
		case udp_tx_state is
			when SEND_USER_DATA =>
				ip_tx.data.data_out <= udp_txi.data.data_out;
				tx_data_valid <= udp_txi.data.data_out_valid;
				ip_tx.data.data_out_last <= udp_txi.data.data_out_last;
				
			when SEND_UDP_HDR =>
				ip_tx.data.data_out <= tx_data;
				tx_data_valid <= ip_tx_data_out_ready;
				ip_tx.data.data_out_last <= set_last;
			
			when others =>
				ip_tx.data.data_out <= (others => '0');
				tx_data_valid <= '0';
				ip_tx.data.data_out_last <= set_last;
		end case;
		
		ip_tx.data.data_out_valid <= tx_data_valid and ip_tx_data_out_ready;
			
		-- set signal defaults
		next_tx_state <= IDLE;
		set_tx_state <= '0';
		tx_count_mode <= HOLD;
		tx_data <= x"00";
		set_last <= '0';
		next_tx_result <= UDPTX_RESULT_NONE;
		set_tx_result <= '0';
		set_ip_tx_start <= HOLD;
		tx_count_val <= (others => '0');
		udp_tx_data_out_ready <= '0';
		
		-- set temp signals
		total_length <= std_logic_vector(unsigned(udp_txi.hdr.data_length) + 8);		-- total length = user data length + header length (bytes)
		
		-- TX FSM
		case udp_tx_state is
			when IDLE =>
				udp_tx_data_out_ready <= '0';		-- in this state, we are unable to accept user data for tx
				tx_count_mode <= RST;
				if udp_tx_start = '1' then
					-- check header count for error if too high
					if unsigned(udp_txi.hdr.data_length) > 1472 then
						next_tx_result <= UDPTX_RESULT_ERR;
						set_tx_result <= '1';
					else
						-- start to send UDP header
						tx_count_mode <= RST;
						next_tx_result <= UDPTX_RESULT_SENDING;
						set_ip_tx_start <= SET;
						set_tx_result <= '1';
						next_tx_state <= PAUSE;
						set_tx_state <= '1';
					end if;
				end if;

			when PAUSE =>
				-- delay one clock for IP layer to respond to ip_tx_start and remove any tx error result
				next_tx_state <= SEND_UDP_HDR;
				set_tx_state <= '1';
				
			when SEND_UDP_HDR =>
				udp_tx_data_out_ready <= '0';		-- in this state, we are unable to accept user data for tx
				if ip_tx_result = IPTX_RESULT_ERR then
					set_ip_tx_start <= CLR;
					next_tx_result <= UDPTX_RESULT_ERR;
					set_tx_result <= '1';
					next_tx_state <= IDLE;
					set_tx_state <= '1';
				elsif ip_tx_data_out_ready = '1' then
					if tx_count = x"0007" then
						tx_count_val <= x"0001";
						tx_count_mode <= SET;
						next_tx_state <= SEND_USER_DATA;
						set_tx_state <= '1';
					else
						tx_count_mode <= INCR;
					end if;
					case tx_count is
						when x"0000"  => tx_data <= udp_txi.hdr.src_port (15 downto 8);	-- src port
						when x"0001"  => tx_data <= udp_txi.hdr.src_port (7 downto 0);
						when x"0002"  => tx_data <= udp_txi.hdr.dst_port (15 downto 8);	-- dst port
						when x"0003"  => tx_data <= udp_txi.hdr.dst_port (7 downto 0);
						when x"0004"  => tx_data <= total_length (15 downto 8);				-- length
						when x"0005"  => tx_data <= total_length (7 downto 0);
						when x"0006"  => tx_data <= udp_txi.hdr.checksum (15 downto 8);	-- checksum (set by upstream)
						when x"0007"  => tx_data <= udp_txi.hdr.checksum (7 downto 0);
						when others =>
							-- shouldnt get here - handle as error
							next_tx_result <= UDPTX_RESULT_ERR;
							set_tx_result <= '1';
					end case;
				end if;
				
			when SEND_USER_DATA =>
				udp_tx_data_out_ready <= ip_tx_data_out_ready;	-- in this state, we can accept user data if IP TX rdy
				if ip_tx_data_out_ready = '1' then
					if udp_txi.data.data_out_valid = '1' or tx_count = x"000" then
						-- only increment if ready and valid has been subsequently established, otherwise data count moves on too fast
						if unsigned(tx_count) = unsigned(udp_txi.hdr.data_length) then						
							-- TX terminated due to count - end normally
							set_last <= '1';
							tx_data <= udp_txi.data.data_out;
							next_tx_result <= UDPTX_RESULT_SENT;
							set_ip_tx_start <= CLR;
							set_tx_result <= '1';
							next_tx_state <= IDLE;
							set_tx_state <= '1';
						elsif udp_txi.data.data_out_last = '1' then
							-- terminate tx with error as got last from upstream before exhausting count
							set_last <= '1';
							tx_data <= udp_txi.data.data_out;
							next_tx_result <= UDPTX_RESULT_ERR;
							set_ip_tx_start <= CLR;
							set_tx_result <= '1';
							next_tx_state <= IDLE;
							set_tx_state <= '1';						
						else
							-- TX continues
							tx_count_mode <= INCR;
							tx_data <= udp_txi.data.data_out;
						end if;
					end if;
				end if;

		end case;
	end process;

	-----------------------------------------------------------------------------
	-- sequential process to action control signals and change states and outputs
	-----------------------------------------------------------------------------

	tx_sequential : process (clk,reset,data_out_ready_reg)
	begin
		if rising_edge(clk) then
			data_out_ready_reg <= ip_tx_data_out_ready;
		else
			data_out_ready_reg <= data_out_ready_reg;
		end if;

		if rising_edge(clk) then
			if reset = '1' then
				-- reset state variables
				udp_tx_state <= IDLE;
				tx_count <= x"0000";
				tx_result_reg <= IPTX_RESULT_NONE;
				ip_tx_start_reg <= '0';
			else
				-- Next udp_tx_state processing
				if set_tx_state = '1' then
					udp_tx_state <= next_tx_state;
				else
					udp_tx_state <= udp_tx_state;
				end if;
				
				-- ip_tx_start_reg processing
				case set_ip_tx_start is
					when SET  => ip_tx_start_reg <= '1';
					when CLR  => ip_tx_start_reg <= '0';
					when HOLD => ip_tx_start_reg <= ip_tx_start_reg;
				end case;

				-- tx result processing
				if set_tx_result = '1' then
					tx_result_reg <= next_tx_result;
				else
					tx_result_reg <= tx_result_reg;
				end if;
								
				-- tx_count processing
				case tx_count_mode is
					when RST  =>	tx_count <= x"0000";
					when SET  =>	tx_count <= tx_count_val;
					when INCR =>	tx_count <= tx_count + 1;
					when HOLD => 	tx_count <= tx_count;
				end case;
				
			end if;
		end if;
	end process;


end Behavioral;

