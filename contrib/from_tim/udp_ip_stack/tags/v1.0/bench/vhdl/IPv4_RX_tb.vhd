--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:32:02 06/03/2011
-- Design Name:   
-- Module Name:   C:/Users/pjf/Documents/projects/fpga/xilinx/Network/ip1/IPv4_RX_tb.vhd
-- Project Name:  ip1
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: IPv4_RX
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
 
 
ENTITY IPv4_RX_tb IS
END IPv4_RX_tb;
 
ARCHITECTURE behavior OF IPv4_RX_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT IPv4_RX
    PORT(
			-- IP Layer signals
			ip_rx						: out ipv4_rx_type;
			ip_rx_start				: out std_logic;									-- indicates receipt of ip frame.
			-- system signals
			clk 						: in  STD_LOGIC;									-- same clock used to clock mac data and ip data
			reset 					: in  STD_LOGIC;
			our_ip_address 		: in STD_LOGIC_VECTOR (31 downto 0);
			-- MAC layer RX signals
			mac_data_in 			: in  STD_LOGIC_VECTOR (7 downto 0);		-- ethernet frame (from dst mac addr through to last byte of frame)
			mac_data_in_valid 	: in  STD_LOGIC;									-- indicates data_in valid on clock
			mac_data_in_last 		: in  STD_LOGIC									-- indicates last data in frame
       );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal our_ip_address : std_logic_vector(31 downto 0) := (others => '0');
   signal mac_data_in : std_logic_vector(7 downto 0) := (others => '0');
   signal mac_data_in_valid : std_logic := '0';
   signal mac_data_in_last : std_logic := '0';

 	--Outputs
   signal ip_rx_start : std_logic;
   signal ip_rx : ipv4_rx_type;

   -- Clock period definitions
   constant clk_period : time := 8 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: IPv4_RX PORT MAP (
          ip_rx 				=> ip_rx,
          ip_rx_start 		=> ip_rx_start,
          clk 					=> clk,
          reset 				=> reset,
          our_ip_address 	=> our_ip_address,
          mac_data_in 		=> mac_data_in,
          mac_data_in_valid => mac_data_in_valid,
          mac_data_in_last => mac_data_in_last
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

		our_ip_address <= x"c0a80509";		-- 192.168.5.9
		mac_data_in_valid <= '0';
      mac_data_in_last <= '0';

		reset <= '1';
      wait for clk_period*10;
		reset <= '0';
      wait for clk_period*5;
		
		-- check reset conditions
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

		mac_data_in_valid <= '1';
		-- dst MAC (bc)
		mac_data_in <= x"00"; wait for clk_period;
		mac_data_in <= x"23"; wait for clk_period;
		mac_data_in <= x"20"; wait for clk_period;
		mac_data_in <= x"21"; wait for clk_period;
		mac_data_in <= x"22"; wait for clk_period;
		mac_data_in <= x"23"; wait for clk_period;
		-- src MAC
		mac_data_in <= x"00"; wait for clk_period;
		mac_data_in <= x"23"; wait for clk_period;
		mac_data_in <= x"18"; wait for clk_period;
		mac_data_in <= x"29"; wait for clk_period;
		mac_data_in <= x"26"; wait for clk_period;
		mac_data_in <= x"7c"; wait for clk_period;
		-- type
		mac_data_in <= x"08"; wait for clk_period;		-- IP pkt
		mac_data_in <= x"00"; wait for clk_period;
		-- ver & HL / service type
		mac_data_in <= x"45"; wait for clk_period;	
		mac_data_in <= x"00"; wait for clk_period;
		-- total len
		mac_data_in <= x"00"; wait for clk_period;
		mac_data_in <= x"18"; wait for clk_period;
		-- ID
		mac_data_in <= x"00"; wait for clk_period;
		mac_data_in <= x"00"; wait for clk_period;
		-- flags & frag
		mac_data_in <= x"00"; wait for clk_period;
		mac_data_in <= x"00"; wait for clk_period;
		-- TTL
		mac_data_in <= x"00"; wait for clk_period;
		-- Protocol
		mac_data_in <= x"11"; wait for clk_period;
		-- Header CKS
		mac_data_in <= x"00"; wait for clk_period;
		mac_data_in <= x"00"; wait for clk_period;
		-- SRC IP
		mac_data_in <= x"c0"; wait for clk_period;
		mac_data_in <= x"a8"; wait for clk_period;
		mac_data_in <= x"05"; wait for clk_period;
		mac_data_in <= x"01"; wait for clk_period;
		-- DST IP
		mac_data_in <= x"c0"; wait for clk_period;
		mac_data_in <= x"a8"; wait for clk_period;
		mac_data_in <= x"05"; wait for clk_period;
		mac_data_in <= x"09"; wait for clk_period;
				
		-- user data
		mac_data_in <= x"24"; wait for clk_period;
		
		assert ip_rx.hdr.is_valid = '1'					report "T1: ip_rx.hdr.is_valid not set";
		assert ip_rx.hdr.protocol = x"11"				report "T1: ip_rx.hdr.protocol not set correctly";
		assert ip_rx.hdr.data_length = x"0004"			report "T1: ip_rx.hdr.data_length not set correctly";
		assert ip_rx.hdr.src_ip_addr = x"c0a80501"	report "T1: ip_rx.hdr.src_ip_addr not set correctly";
		assert ip_rx.hdr.num_frame_errors = x"00"		report "T1: ip_rx.hdr.num_frame_errors not set correctly";
		assert ip_rx.hdr.last_error_code = x"0"		report "T1: ip_rx.hdr.last_error_code not set correctly";
		assert ip_rx_start = '1'							report "T1: ip_rx_start not set";
		assert ip_rx.data.data_in_valid = '1'			report "T1: ip_rx.data.data_in_valid not set";

		mac_data_in <= x"25"; wait for clk_period;
		mac_data_in <= x"26"; wait for clk_period;
		mac_data_in <= x"27"; mac_data_in_last <= '1';wait for clk_period;

		assert ip_rx.data.data_in_last = '1'			report "T1: ip_rx.data.data_in_last not set";
		
		mac_data_in <= x"00";
		mac_data_in_last <= '0';
		mac_data_in_valid <= '0';
		wait for clk_period;
		
		assert ip_rx.data.data_in_valid = '0'			report "T1: ip_rx.data.data_in_valid not cleared";
		assert ip_rx.data.data_in_last = '0'			report "T1: ip_rx.data.data_in_last not cleared";
		assert ip_rx.hdr.num_frame_errors = x"00"		report "T1: ip_rx.hdr.num_frame_errors non zero at end of test";
		assert ip_rx.hdr.last_error_code = x"0"		report "T1: ip_rx.hdr.last_error_code indicates error at end of test";
		assert ip_rx_start = '0'							report "T1: ip_rx_start not cleared";

		------------
		-- TEST 2 -- basic functional rx test with received ip pkt that is not for us
		------------

		report "T2: Send an eth frame with IP pkt dst ip_address c0a80507, dst mac 002320212223";

		mac_data_in_valid <= '1';
		-- dst MAC (bc)
		mac_data_in <= x"00"; wait for clk_period;
		mac_data_in <= x"23"; wait for clk_period;
		mac_data_in <= x"20"; wait for clk_period;
		mac_data_in <= x"21"; wait for clk_period;
		mac_data_in <= x"22"; wait for clk_period;
		mac_data_in <= x"23"; wait for clk_period;

		assert ip_rx.hdr.is_valid = '0'					report "T2: ip_rx.hdr.is_valid remains set";

		-- src MAC
		mac_data_in <= x"00"; wait for clk_period;
		mac_data_in <= x"23"; wait for clk_period;
		mac_data_in <= x"18"; wait for clk_period;
		mac_data_in <= x"29"; wait for clk_period;
		mac_data_in <= x"26"; wait for clk_period;
		mac_data_in <= x"7c"; wait for clk_period;
		-- type
		mac_data_in <= x"08"; wait for clk_period;		-- IP pkt
		mac_data_in <= x"00"; wait for clk_period;
		-- ver & HL / service type
		mac_data_in <= x"45"; wait for clk_period;	
		mac_data_in <= x"00"; wait for clk_period;
		-- total len
		mac_data_in <= x"00"; wait for clk_period;
		mac_data_in <= x"18"; wait for clk_period;
		-- ID
		mac_data_in <= x"00"; wait for clk_period;
		mac_data_in <= x"00"; wait for clk_period;
		-- flags & frag
		mac_data_in <= x"00"; wait for clk_period;
		mac_data_in <= x"00"; wait for clk_period;
		-- TTL
		mac_data_in <= x"00"; wait for clk_period;
		-- Protocol
		mac_data_in <= x"11"; wait for clk_period;
		-- Header CKS
		mac_data_in <= x"00"; wait for clk_period;
		mac_data_in <= x"00"; wait for clk_period;
		-- SRC IP
		mac_data_in <= x"c0"; wait for clk_period;
		mac_data_in <= x"a8"; wait for clk_period;
		mac_data_in <= x"05"; wait for clk_period;
		mac_data_in <= x"02"; wait for clk_period;
		-- DST IP
		mac_data_in <= x"c0"; wait for clk_period;
		mac_data_in <= x"a8"; wait for clk_period;
		mac_data_in <= x"05"; wait for clk_period;
		mac_data_in <= x"07"; wait for clk_period;
				
		-- user data
		mac_data_in <= x"24"; wait for clk_period;
		
		assert ip_rx.hdr.is_valid = '1'					report "T2: ip_rx.hdr.is_valid not set";
		assert ip_rx.hdr.protocol = x"11"				report "T2: ip_rx.hdr.protocol not set correctly";
		assert ip_rx.hdr.data_length = x"0004"			report "T2: ip_rx.hdr.data_length not set correctly";
		assert ip_rx.hdr.src_ip_addr = x"c0a80502"	report "T2: ip_rx.hdr.src_ip_addr not set correctly";
		assert ip_rx.hdr.num_frame_errors = x"00"		report "T2: ip_rx.hdr.num_frame_errors not set correctly";
		assert ip_rx.hdr.last_error_code = x"0"		report "T2: ip_rx.hdr.last_error_code not set correctly";
		assert ip_rx_start = '0'							report "T2: ip_rx_start set when pkt not for us";
		assert ip_rx.data.data_in_valid = '0'			report "T2: ip_rx.data.data_in_valid set when pkt not for us";

		mac_data_in <= x"25"; wait for clk_period;
		mac_data_in <= x"26"; wait for clk_period;
		mac_data_in <= x"27"; mac_data_in_last <= '1';wait for clk_period;

		assert ip_rx.data.data_in_last = '0'			report "T2: ip_rx.data.data_in_last set";
		
		mac_data_in <= x"00";
		mac_data_in_last <= '0';
		mac_data_in_valid <= '0';
		wait for clk_period;
		
		assert ip_rx.data.data_in_valid = '0'			report "T2: ip_rx.data.data_in_valid not cleared";
		assert ip_rx.data.data_in_last = '0'			report "T2: ip_rx.data.data_in_last not cleared";
		assert ip_rx.hdr.num_frame_errors = x"00"		report "T2: ip_rx.hdr.num_frame_errors non zero at end of test";
		assert ip_rx.hdr.last_error_code = x"0"		report "T2: ip_rx.hdr.last_error_code indicates error at end of test";
		assert ip_rx_start = '0'							report "T2: ip_rx_start not cleared";
		
		report "--- end of tests ---";
		
      wait;
   end process;

END;
