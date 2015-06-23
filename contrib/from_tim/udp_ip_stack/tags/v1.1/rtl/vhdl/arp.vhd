----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 		Peter Fall
-- 
-- Create Date:    12:00:04 05/31/2011 
-- Design Name: 
-- Module Name:    arp - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description:
--		handle simple IP lookup in cache
--		request cache fill through ARP protocol if required
--		cache is simple 1 deep
--		Handle ARP protocol
--		Respond to ARP requests and replies
--		Ignore pkts that are not ARP
--		Ignore pkts that are not addressed to us
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Revision 0.02 - Added req for mac tx and wait for grant
-- Revision 0.03 - Added data_out_first

-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.arp_types.all;

entity arp is
    Port (
			-- lookup request signals
			arp_req_req			: in arp_req_req_type;
			arp_req_rslt		: out arp_req_rslt_type;
			-- MAC layer RX signals
			data_in_clk 		: in  STD_LOGIC;
			reset 				: in  STD_LOGIC;
			data_in 				: in  STD_LOGIC_VECTOR (7 downto 0);		-- ethernet frame (from dst mac addr through to last byte of frame)
			data_in_valid 		: in  STD_LOGIC;									-- indicates data_in valid on clock
			data_in_last 		: in  STD_LOGIC;									-- indicates last data in frame
			-- MAC layer TX signals
			mac_tx_req			: out std_logic;									-- indicates that ip wants access to channel (stays up for as long as tx)
			mac_tx_granted		: in std_logic;									-- indicates that access to channel has been granted		
			data_out_clk		: in std_logic;
			data_out_ready		: in std_logic;									-- indicates system ready to consume data
			data_out_valid		: out std_logic;									-- indicates data out is valid
			data_out_first		: out std_logic;									-- with data out valid indicates the first byte of a frame
			data_out_last		: out std_logic;									-- with data out valid indicates the last byte of a frame
			data_out				: out std_logic_vector (7 downto 0);		-- ethernet frame (from dst mac addr through to last byte of frame)
			-- system signals
			our_mac_address 	: in STD_LOGIC_VECTOR (47 downto 0);
			our_ip_address 	: in STD_LOGIC_VECTOR (31 downto 0);		  
			req_count			: out STD_LOGIC_VECTOR(7 downto 0)			-- count of arp pkts received
			);
end arp;

architecture Behavioral of arp is

	type req_state_type is (IDLE,LOOKUP,REQUEST,WAIT_REPLY);
	type rx_state_type is (IDLE,PARSE,PROCESS_ARP,WAIT_END);
	type rx_event_type is (NO_EVENT,DATA);
	type count_mode_type is (RST,INCR,HOLD);
	type arp_oper_type is (NOP,REQUEST,REPLY);
	type set_clr_type is (SET, CLR, HOLD);

	type tx_state_type is (IDLE,WAIT_MAC,SEND);
	
	
	type arp_entry_type is record
		ip 				: std_logic_vector (31 downto 0);
		mac 				: std_logic_vector (47 downto 0);
		is_valid			: std_logic;
		reply_required	: std_logic;
	end record;
	
	-- state variables
	signal req_state			: req_state_type;
	signal req_ip_addr		: std_logic_vector (31 downto 0);		-- IP address to lookup
	signal mac_addr_found	: STD_LOGIC_VECTOR (47 downto 0);		-- mac address found
	signal mac_addr_valid_reg: std_logic;
	signal send_request_needed		: std_logic;
	signal tx_mac_chn_reqd	: std_logic;
	
	signal rx_state 			: rx_state_type;
	signal rx_count 			: unsigned (7 downto 0);
	signal arp_operation		: arp_oper_type;
	signal arp_req_count		: unsigned (7 downto 0);
	signal arp_entry			: arp_entry_type;				-- arp entry store
	signal new_arp_entry		: arp_entry_type;
	signal tx_state			: tx_state_type;
	signal tx_count 			: unsigned (7 downto 0);

-- FIXME	- remove these debug state signals
	signal arp_err_data		: std_logic_vector (7 downto 0);
	signal set_err_data		: std_logic;
	
  attribute keep : string;
  attribute keep of arp_err_data             : signal is "true";

	-- requester control signals
	signal next_req_state	: req_state_type;
	signal set_req_state		: std_logic;
	signal set_req_ip			: std_logic;
	signal set_mac_addr		: std_logic;
	signal set_mac_addr_invalid : std_logic;
	signal set_send_req		: std_logic;
	signal clear_send_req	: std_logic;
	
	
	-- rx control signals
	signal next_rx_state 	: rx_state_type;
	signal set_rx_state 		: std_logic;
	signal rx_event 			: rx_event_type;
	signal rx_count_mode 	: count_mode_type;
	signal set_arp_oper		: std_logic;
	signal arp_oper_set_val	: arp_oper_type;
	signal dataval 			: std_logic_vector (7 downto 0);
	signal set_arp_entry_request		: std_logic;
	
	signal set_mac5 			: std_logic;
	signal set_mac4 			: std_logic;
	signal set_mac3 			: std_logic;
	signal set_mac2 			: std_logic;
	signal set_mac1 			: std_logic;
	signal set_mac0 			: std_logic;
	
	signal set_ip3 			: std_logic;
	signal set_ip2 			: std_logic;
	signal set_ip1 			: std_logic;
	signal set_ip0 			: std_logic;

	-- tx control signals
	signal next_tx_state 	: tx_state_type;
	signal set_tx_state 		: std_logic;
	signal tx_count_mode		: count_mode_type;
	signal clear_reply_req	: std_logic;
	signal set_chn_reqd		: set_clr_type;
	signal kill_data_out_valid	: std_logic;
	

	-- function to determine whether the rx pkt is an arp pkt and whether we want to process it
	-- Returns 1 if we should discard
	-- The following will make us ignore the frame (all values hexadecimal):
	-- PDU type /= 0806
	-- Protocol Type /= 0800
	-- Hardware Type /= 1
	-- Hardware Length /= 6
	-- Protocol Length /= 4
	-- Operation /= 1 or 2
	-- Target IP /= our IP (i.er. message is not meant for us)
	--
	function not_our_arp(data : STD_LOGIC_VECTOR; count : unsigned; our_ip : std_logic_vector) return std_logic is
	begin
		if 
			(count = 12 and data /= x"08") or						-- PDU type 0806 : ARP
			(count = 13 and data /= x"06") or
			(count = 14 and data /= x"00") or						-- HW type 1 : eth
			(count = 15 and data /= x"01") or
			(count = 16 and data /= x"08") or						-- Protocol 0800 : IP
			(count = 17 and data /= x"00") or
			(count = 18 and data /= x"06") or						-- HW Length 6
			(count = 19 and data /= x"04") or						-- protocol length 4
			(count = 20 and data /= x"00") or						-- operation 1 or 2 (req or reply)
			(count = 21 and data /= x"01" and data /= x"02") or
			(count = 38 and data /= our_ip(31 downto 24)) or	-- target IP is ours
			(count = 39 and data /= our_ip(23 downto 16)) or
			(count = 40 and data /= our_ip(15 downto 8)) or
			(count = 41 and data /= our_ip(7 downto 0))	
		then
			return '1';
		else
			return '0';
		end if;
	end function not_our_arp;

begin
	req_combinatorial : process (
		-- input signals
		arp_req_req,
		-- state variables
		req_state, req_ip_addr, mac_addr_found, mac_addr_valid_reg, send_request_needed, arp_entry,
		-- control signals
		next_req_state, set_req_state, set_req_ip, set_mac_addr,set_mac_addr_invalid,set_send_req, clear_send_req)
	begin
		-- set output followers
		arp_req_rslt.got_err <= '0';	-- errors not returned in this version
		-- zero time response to lookup request if already in cache
		if arp_req_req.lookup_req = '1' and arp_req_req.ip = arp_entry.ip and arp_entry.is_valid = '1' then
			arp_req_rslt.got_mac <= '1';
			arp_req_rslt.mac <= arp_entry.mac;
		else
			arp_req_rslt.got_mac <= mac_addr_valid_reg;
			arp_req_rslt.mac <= mac_addr_found;
		end if;
		
		-- set signal defaults
		next_req_state <= IDLE;
		set_req_state <= '0';
		set_req_ip <= '0';
		set_mac_addr <= '0';
		set_mac_addr_invalid <= '0';
		set_send_req <= '0';
		clear_send_req <= '0';
				
		-- REQ FSM
		case req_state is
			when IDLE =>
				if arp_req_req.lookup_req = '1' then
					-- check if we already have the info in cache
					if arp_req_req.ip = arp_entry.ip and arp_entry.is_valid = '1' then
						-- already have this IP
						set_mac_addr <= '1';
					else				
						next_req_state <= LOOKUP;
						set_req_state <= '1'; 
						set_req_ip <= '1';
						set_mac_addr_invalid <= '1';
					end if;
				end if;

			when LOOKUP =>
				if arp_entry.ip = req_ip_addr and arp_entry.is_valid = '1' then
					-- already have this IP
					next_req_state <= IDLE;
					set_req_state <= '1'; 
					set_mac_addr <= '1';
				else
					-- need to request mac for this IP
					next_req_state <= REQUEST;
					set_req_state <= '1'; 
					set_send_req <= '1';
				end if;
					
			when REQUEST =>
					clear_send_req <= '1';
					next_req_state <= WAIT_REPLY;
					set_req_state <= '1'; 				
				
			when WAIT_REPLY =>
				if arp_entry.is_valid = '1' then
					-- have reply, go back to LOOKUP state to see if it is the right one
					next_req_state <= LOOKUP;
					set_req_state <= '1'; 
				end if;
				-- TODO: add timeout here				

		end case;		
	end process;

	req_sequential : process (data_in_clk,reset)
	begin
		if rising_edge(data_in_clk) then
			if reset = '1' then
				-- reset state variables
				req_state <= IDLE;
				req_ip_addr <= (others => '0');
				mac_addr_found <= (others => '0');
				mac_addr_valid_reg <= '0';
				send_request_needed <= '0';
			else
				-- Next req_state processing
				if set_req_state = '1' then
					req_state <= next_req_state;
				else
					req_state <= req_state;
				end if;

				-- Latch the requested IP address
				if set_req_ip = '1' then
					req_ip_addr <= arp_req_req.ip;
				else
					req_ip_addr <= req_ip_addr;
				end if;
				
				-- send request to TX&RX FSMs to send an ARP request
				if set_send_req = '1' then
					send_request_needed <= '1';
				elsif clear_send_req = '1' then
					send_request_needed <= '0';
				else
					send_request_needed <= send_request_needed;
				end if;
				
				-- Set the found mac address
				if set_mac_addr = '1' then
					mac_addr_found <= arp_entry.mac;
					mac_addr_valid_reg <= '1';
				elsif set_mac_addr_invalid = '1' then
					mac_addr_found <= (others => '0');
					mac_addr_valid_reg <= '0';
				else
					mac_addr_found <= mac_addr_found;
					mac_addr_valid_reg <= mac_addr_valid_reg;
				end if;
				
			end if;
		end if;
	end process;


	rx_combinatorial : process (
		-- input signals
		data_in, data_in_valid, data_in_last, our_ip_address,
		-- state variables
		rx_state, rx_count, arp_operation, arp_req_count, arp_err_data,
		-- control signals
		next_rx_state, set_rx_state, rx_event, rx_count_mode, set_arp_oper, arp_oper_set_val,
		dataval,set_mac5,set_mac4,set_mac3,set_mac2,set_mac1,set_mac0,set_ip3,set_ip2,set_ip1,set_ip0, set_err_data, 
		set_arp_entry_request)
	begin
		-- set output followers
		req_count <= STD_LOGIC_VECTOR(arp_req_count);
		
		-- set signal defaults
		next_rx_state <= IDLE;
		set_rx_state <= '0';
		rx_event <= NO_EVENT;
		rx_count_mode <= HOLD;
		set_arp_oper <= '0';
		arp_oper_set_val <= NOP;
		dataval <= (others => '0');
		set_mac5 <= '0';
		set_mac4 <= '0';
		set_mac3 <= '0';
		set_mac2 <= '0';
		set_mac1 <= '0';
		set_mac0 <= '0';
		set_ip3 <= '0';
		set_ip2 <= '0';
		set_ip1 <= '0';
		set_ip0 <= '0';
		set_arp_entry_request <= '0';
		set_err_data <= '0';
		
		-- determine event (if any)
		if data_in_valid = '1' then
			rx_event <= DATA;
		end if;
		
		-- RX FSM
		case rx_state is
			when IDLE =>
				rx_count_mode <= RST;
				case rx_event is
					when NO_EVENT => -- (nothing to do)
					when DATA =>
						next_rx_state <= PARSE;
						set_rx_state <= '1'; 
						rx_count_mode <= INCR;
				end case;

			when PARSE =>
				case rx_event is
					when NO_EVENT => -- (nothing to do)
					when DATA =>
						rx_count_mode <= INCR;
						-- handle early frame termination
						if data_in_last = '1' then
							next_rx_state <= IDLE;
							set_rx_state <= '1'; 
						else
							-- check for end of frame. Also, detect and discard if not our frame
							if rx_count = 42 then
								next_rx_state <= PROCESS_ARP;
								set_rx_state <= '1';								
							elsif not_our_arp(data_in,rx_count,our_ip_address) = '1' then
								dataval <= data_in;
								set_err_data <= '1';
								next_rx_state <= WAIT_END;
								set_rx_state <= '1';
							elsif rx_count = 21 then
								-- capture ARP operation
								case data_in is
									when x"01" =>
										arp_oper_set_val <= REQUEST;
										set_arp_oper <= '1';
									when x"02" =>
										arp_oper_set_val <= REPLY;
										set_arp_oper <= '1';
									when others =>	-- ignore other values
								end case;
							-- capture source mac addr
							elsif rx_count = 22 then
								set_mac5 <= '1';
								dataval <= data_in;
							elsif rx_count = 23 then
								set_mac4 <= '1';
								dataval <= data_in;
							elsif rx_count = 24 then
								set_mac3 <= '1';
								dataval <= data_in;
							elsif rx_count = 25 then
								set_mac2 <= '1';
								dataval <= data_in;
							elsif rx_count = 26 then
								set_mac1 <= '1';
								dataval <= data_in;
							elsif rx_count = 27 then
								set_mac0 <= '1';
								dataval <= data_in;
							-- capture source ip addr
							elsif rx_count = 28 then
								set_ip3 <= '1';
								dataval <= data_in;
							elsif rx_count = 29 then
								set_ip2 <= '1';
								dataval <= data_in;
							elsif rx_count = 30 then
								set_ip1 <= '1';
								dataval <= data_in;
							elsif rx_count = 31 then
								set_ip0 <= '1';
								dataval <= data_in;
							end if;							
						end if;							
				end case;

			when PROCESS_ARP =>
				next_rx_state <= WAIT_END;
				set_rx_state <= '1'; 
				case arp_operation is
					when NOP => -- (nothing to do)
					when REQUEST =>
							set_arp_entry_request <= '1';
							arp_oper_set_val <= NOP;
							set_arp_oper <= '1';
					when REPLY =>
							set_arp_entry_request <= '1';
							arp_oper_set_val <= NOP;
							set_arp_oper <= '1';
				end case;

			when WAIT_END =>
				case rx_event is
					when NO_EVENT => -- (nothing to do)
					when DATA =>
						if data_in_last = '1' then
							next_rx_state <= IDLE;
							set_rx_state <= '1'; 
						end if;
				end case;
				
		end case;
		
	end process;

	rx_sequential : process (data_in_clk)
	begin
		if rising_edge(data_in_clk) then
			if reset = '1' then
				-- reset state variables
				rx_state <= IDLE;
				rx_count <= x"00";
				arp_operation <= NOP;
				arp_req_count <= x"00";
				-- reset arp entry store
				arp_entry.ip <= x"00000000";
				arp_entry.mac <= x"000000000000";
				arp_entry.is_valid <= '0';
				arp_entry.reply_required <= '0';
				arp_err_data <= (others => '0');
			else
				-- Next rx_state processing
				if set_rx_state = '1' then
					rx_state <= next_rx_state;
				else
					rx_state <= rx_state;
				end if;
				
				-- rx_count processing
				case rx_count_mode is
					when RST =>
						rx_count <= x"00";
					when INCR =>
						rx_count <= rx_count + 1;
					when HOLD =>
						rx_count <= rx_count;
				end case;
				
				-- err data
				if set_err_data = '1' then
					arp_err_data <= data_in;
				else
					arp_err_data <= arp_err_data;
				end if;
				
				-- arp operation processing
				if set_arp_oper = '1' then
					arp_operation <= arp_oper_set_val;
				else
					arp_operation <= arp_operation;
				end if;
				
				-- source mac capture
				if (set_mac5 = '1') then new_arp_entry.mac(47 downto 40) <= dataval; end if;
				if (set_mac4 = '1') then new_arp_entry.mac(39 downto 32) <= dataval; end if;
				if (set_mac3 = '1') then new_arp_entry.mac(31 downto 24) <= dataval; end if;
				if (set_mac2 = '1') then new_arp_entry.mac(23 downto 16) <= dataval; end if;
				if (set_mac1 = '1') then new_arp_entry.mac(15 downto 8) <= dataval; end if;
				if (set_mac0 = '1') then new_arp_entry.mac(7 downto 0) <= dataval; end if;

				-- source ip capture
				if (set_ip3 = '1') then new_arp_entry.ip(31 downto 24) <= dataval; end if;
				if (set_ip2 = '1') then new_arp_entry.ip(23 downto 16) <= dataval; end if;
				if (set_ip1 = '1') then new_arp_entry.ip(15 downto 8) <= dataval; end if;
				if (set_ip0 = '1') then new_arp_entry.ip(7 downto 0) <= dataval; end if;
				
				-- set arp entry request
				if set_arp_entry_request = '1' then
					-- copy info from new entry to arp_entry and set reply required
					arp_entry.mac <= new_arp_entry.mac;
					arp_entry.ip <= new_arp_entry.ip;
					arp_entry.is_valid <= '1';
					if arp_operation = REQUEST then
						arp_entry.reply_required <= '1';
					else
						arp_entry.reply_required <= '0';
					end if;
					-- count another ARP pkt received
					arp_req_count <= arp_req_count + 1;
				elsif clear_reply_req = '1' then
					-- note: clear_reply_req is set by tx logic, but handled in the clk domain of the rx
					-- maintain arp entry state, but reset the reply required flag
					arp_entry.mac <= arp_entry.mac;
					arp_entry.ip <= arp_entry.ip;
					arp_entry.is_valid <= arp_entry.is_valid;
					arp_entry.reply_required <= '0';
					arp_req_count <= arp_req_count;
				elsif send_request_needed = '1' then
					-- set up the arp entry to take the request to be transmitted out by the TX FSM
					arp_entry.ip <= req_ip_addr;
					arp_entry.mac <= (others => '0');
					arp_entry.is_valid <= '0';
					arp_entry.reply_required <= '0';
				else
					arp_entry <= arp_entry;
					arp_req_count <= arp_req_count;
				end if;
				
			end if;
		end if;
	end process;

	tx_combinatorial : process (
		-- input signals
		data_out_ready, send_request_needed, mac_tx_granted, our_mac_address, our_ip_address,
		-- state variables
		tx_state, tx_count, tx_mac_chn_reqd, arp_entry,
		-- control signals
		next_rx_state, set_rx_state, tx_count_mode, kill_data_out_valid, 
		set_chn_reqd, clear_reply_req)
	begin
		-- set output followers
		mac_tx_req <= tx_mac_chn_reqd;	
		
		-- set initial values for combinatorial outputs
		data_out_first <= '0';
		
		case tx_state is
			when SEND   =>
				if data_out_ready = '1' and kill_data_out_valid = '0' then
					data_out_valid <= '1';
				else
					data_out_valid <= '0';
				end if;
			when OTHERS =>	data_out_valid <= '0';				
		end case;
				
		-- set signal defaults
		next_tx_state <= IDLE;
		set_tx_state <= '0';
		tx_count_mode <= HOLD;
		data_out <= x"00";
		data_out_last <= '0';
		clear_reply_req <= '0';
		set_chn_reqd <= HOLD;
		kill_data_out_valid <= '0';
				
		-- TX FSM
		case tx_state is
			when IDLE =>
				tx_count_mode <= RST;
				if arp_entry.reply_required = '1' then
					set_chn_reqd <= SET;
					next_tx_state <= WAIT_MAC;
					set_tx_state <= '1';
				elsif send_request_needed = '1' then
					set_chn_reqd <= SET;
					next_tx_state <= WAIT_MAC;
					set_tx_state <= '1';
				else
					set_chn_reqd <= CLR;
				end if;

			when WAIT_MAC =>
				tx_count_mode <= RST;
				if mac_tx_granted = '1' then
					next_tx_state <= SEND;
					set_tx_state <= '1';
				end if;
				-- TODO - should handle timeout here
					
			when SEND =>
				if data_out_ready = '1' then
						tx_count_mode <= INCR;
				end if;
				case tx_count is
					when x"00"  => 
						data_out_first <= data_out_ready;
						data_out <= x"ff";								-- dst = broadcast
						
					when x"01"  => data_out <= x"ff";
					when x"02"  => data_out <= x"ff";
					when x"03"  => data_out <= x"ff";
					when x"04"  => data_out <= x"ff"; 
					when x"05"  => data_out <= x"ff"; 
					when x"06"  => data_out <= our_mac_address (47 downto 40); 	-- src = our mac
					when x"07"  => data_out <= our_mac_address (39 downto 32); 
					when x"08"  => data_out <= our_mac_address (31 downto 24); 
					when x"09"  => data_out <= our_mac_address (23 downto 16); 
					when x"0a"  => data_out <= our_mac_address (15 downto 8); 
					when x"0b"  => data_out <= our_mac_address (7 downto 0); 
					when x"0c"  => data_out <= x"08"; 									-- pkt type = 0806 : ARP
					when x"0d"  => data_out <= x"06"; 
					when x"0e"  => data_out <= x"00"; 									-- HW type = 0001 : eth
					when x"0f"  => data_out <= x"01"; 
					when x"10"  => data_out <= x"08"; 									-- protocol = 0800 : ip
					when x"11"  => data_out <= x"00"; 
					when x"12"  => data_out <= x"06"; 									-- HW size = 06
					when x"13"  => data_out <= x"04"; 									-- prot size = 04
					
					when x"14"  =>	data_out <= x"00"; 									-- opcode =		
					when x"15"  =>
						if arp_entry.is_valid = '1' then
							data_out <= x"02";																			-- 02 : REPLY if arp_entry valid
						else
							data_out <= x"01";																			-- 01 : REQ if arp_entry invalid
						end if;
						
					when x"16" => data_out <= our_mac_address (47 downto 40); 	-- sender mac
					when x"17" => data_out <= our_mac_address (39 downto 32); 
					when x"18" => data_out <= our_mac_address (31 downto 24); 
					when x"19" => data_out <= our_mac_address (23 downto 16); 
					when x"1a" => data_out <= our_mac_address (15 downto 8); 
					when x"1b" => data_out <= our_mac_address (7 downto 0); 
					when x"1c" => data_out <= our_ip_address (31 downto 24); 	-- sender ip
					when x"1d" => data_out <= our_ip_address (23 downto 16); 
					when x"1e" => data_out <= our_ip_address (15 downto 8); 
					when x"1f" => data_out <= our_ip_address (7 downto 0); 
					when x"20" => data_out <= arp_entry.mac (47 downto 40); 	-- target mac
					when x"21" => data_out <= arp_entry.mac (39 downto 32); 
					when x"22" => data_out <= arp_entry.mac (31 downto 24); 
					when x"23" => data_out <= arp_entry.mac (23 downto 16); 
					when x"24" => data_out <= arp_entry.mac (15 downto 8); 
					when x"25" => data_out <= arp_entry.mac (7 downto 0); 
					when x"26" => data_out <= arp_entry.ip  (31 downto 24); 	-- target ip
					when x"27" => data_out <= arp_entry.ip   (23 downto 16); 
					when x"28" => data_out <= arp_entry.ip   (15 downto 8);
					
					when x"29" =>
						data_out <= arp_entry.ip(7 downto 0); 
						data_out_last <= '1';
					
					when x"2a" =>
						clear_reply_req <= '1';			-- reset the reply request (done in the rx clk process domain)
						kill_data_out_valid <= '1';	-- data is no longer valid
						next_tx_state <= IDLE;
						set_tx_state <= '1';	

					when others =>
						next_tx_state <= IDLE;
						set_tx_state <= '1';	
				end case;
		end case;
	end process;

	tx_sequential : process (data_out_clk,reset)
	begin
		if rising_edge(data_out_clk) then
			if reset = '1' then
				-- reset state variables
				tx_state <= IDLE;
				tx_mac_chn_reqd <= '0';
			else
				-- Next rx_state processing
				if set_tx_state = '1' then
					tx_state <= next_tx_state;
				else
					tx_state <= tx_state;
				end if;
				
				-- tx_count processing
				case tx_count_mode is
					when RST =>
						tx_count <= x"00";
					when INCR =>
						tx_count <= tx_count + 1;
					when HOLD =>
						tx_count <= tx_count;
				end case;

				-- control access request to mac tx chn
				case set_chn_reqd is
					when SET => tx_mac_chn_reqd <= '1';
					when CLR => tx_mac_chn_reqd <= '0';
					when HOLD => tx_mac_chn_reqd <= tx_mac_chn_reqd;
				end case;
				
			end if;
		end if;
	end process;


end Behavioral;

