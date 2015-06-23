--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:35:50 05/31/2011
-- Design Name:   
-- Module Name:   C:/Users/pjf/Documents/projects/fpga/xilinx/Network/arp1/arp_tb.vhd
-- Project Name:  arp1
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: arp
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
USE ieee.numeric_std.ALL;
use work.arp_types.all;
 
ENTITY arp_tb IS
END arp_tb;
 
ARCHITECTURE behavior OF arp_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT arp
    PORT(
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
    END COMPONENT;
    

   --Inputs
   signal clk 					: std_logic := '0';
   signal reset 				: std_logic := '0';
   signal data_in 			: std_logic_vector(7 downto 0) := (others => '0');
   signal data_in_valid 	: std_logic := '0';
   signal data_in_last 		: std_logic := '0';
   signal our_mac_address 	: std_logic_vector(47 downto 0) := (others => '0');
   signal our_ip_address 	: std_logic_vector(31 downto 0) := (others => '0');
	signal data_out_ready	: std_logic;									
	signal data_out_valid	: std_logic;									
	signal data_out_first	: std_logic;									
	signal data_out_last		: std_logic;									
	signal data_out			: std_logic_vector (7 downto 0);	
	signal req_count			: STD_LOGIC_VECTOR(7 downto 0);
	signal arp_req_req  		: arp_req_req_type;			
	signal arp_req_rslt 		: arp_req_rslt_type;			
	signal mac_tx_req			: std_logic;
	signal mac_tx_granted	: std_logic;

	
   -- Clock period definitions
   constant clk_period : time := 8 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: arp PORT MAP (
			-- lookup request mappings
			 arp_req_req		=> arp_req_req,
			 arp_req_rslt		=> arp_req_rslt,
			-- rx mappings
          data_in_clk 		=> clk,
          reset 				=> reset,
          data_in 			=> data_in,
          data_in_valid 	=> data_in_valid,
          data_in_last		=> data_in_last,
			 -- tx mappings
			 mac_tx_req			=> mac_tx_req,
			 mac_tx_granted	=> mac_tx_granted,
			 data_out_clk 		=> clk,
			 data_out_ready 	=> data_out_ready,
			 data_out_valid 	=> data_out_valid,
			 data_out_first	=> data_out_first,
			 data_out_last		=> data_out_last,
			 data_out 			=> data_out,
			 -- system mappings
          our_mac_address 	=> our_mac_address,
          our_ip_address 	=> our_ip_address,
			 req_count 			=> req_count
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
		our_mac_address <= x"002320212223";
		mac_tx_granted <= '1'; -- FIXME 0

		reset <= '1';
      wait for clk_period*10;
		reset <= '0';
      wait for clk_period*5;
		
		assert mac_tx_req = '0'					report "mac_tx_req asserted on reset";

      -- insert stimulus here
		arp_req_req.lookup_req <= '0';
		arp_req_req.ip <= (others => '0');
		data_out_ready <= '1';

		report "T1:  Send an ARP request: who has 192.168.5.8? Tell 192.168.5.1";
		data_in_valid <= '1';
		-- dst MAC (bc)
		data_in <= x"ff"; wait for clk_period;
		data_in <= x"ff"; wait for clk_period;
		data_in <= x"ff"; wait for clk_period;
		data_in <= x"ff"; wait for clk_period;
		data_in <= x"ff"; wait for clk_period;
		data_in <= x"ff"; wait for clk_period;
		-- src MAC
		data_in <= x"00"; wait for clk_period;
		data_in <= x"23"; wait for clk_period;
		data_in <= x"18"; wait for clk_period;
		data_in <= x"29"; wait for clk_period;
		data_in <= x"26"; wait for clk_period;
		data_in <= x"7c"; wait for clk_period;
		-- type
		data_in <= x"08"; wait for clk_period;
		data_in <= x"06"; wait for clk_period;
		-- HW type
		data_in <= x"00"; wait for clk_period;
		data_in <= x"01"; wait for clk_period;
		-- Protocol type
		data_in <= x"08"; wait for clk_period;
		data_in <= x"00"; wait for clk_period;
		-- HW size
		data_in <= x"06"; wait for clk_period;
		-- protocol size
		data_in <= x"04"; wait for clk_period;
		-- Opcode
		data_in <= x"00"; wait for clk_period;
		data_in <= x"01"; wait for clk_period;
		-- Sender MAC
		data_in <= x"00"; wait for clk_period;
		data_in <= x"23"; wait for clk_period;
		data_in <= x"18"; wait for clk_period;
		data_in <= x"29"; wait for clk_period;
		data_in <= x"26"; wait for clk_period;
		data_in <= x"7c"; wait for clk_period;
		-- Sender IP
		data_in <= x"c0"; wait for clk_period;
		data_in <= x"a8"; wait for clk_period;
		data_in <= x"05"; wait for clk_period;
		data_in <= x"01"; wait for clk_period;
		-- Target MAC
		data_in <= x"00"; wait for clk_period;
		data_in <= x"00"; wait for clk_period;
		data_in <= x"00"; wait for clk_period;
		data_in <= x"00"; wait for clk_period;
		data_in <= x"00"; wait for clk_period;
		data_in <= x"00"; wait for clk_period;
		-- Target IP
		data_in <= x"c0"; wait for clk_period;
		data_in <= x"a8"; wait for clk_period;
		data_in <= x"05"; wait for clk_period;
		data_in <= x"09"; wait for clk_period;
		data_in <= x"00"; wait for clk_period;
		data_in <= x"00"; wait for clk_period;
		data_in <= x"00"; wait for clk_period;
		data_in_last <= '1';
		data_in <= x"00"; wait for clk_period;
		data_in_last <= '0';
		data_in_valid <= '0';
		
		-- check tx arbitration signals
		
		assert mac_tx_req = '1'					report "T1: mac_tx_req not set";
		
		-- ready to tx
		data_out_ready <= '1';
		mac_tx_granted <= '1';
		wait for clk_period*10;
		data_out_ready <= '0';
		wait for clk_period*2;
		data_out_ready <= '1';
		wait for clk_period*50;
		
		report "T2: Send another ARP request: who has 192.168.5.8? Tell 192.168.5.1, holding off transmitter";
		data_out_ready <= '0';
		data_in_valid <= '1';
		-- dst MAC (bc)
		data_in <= x"ff"; wait for clk_period;
		data_in <= x"ff"; wait for clk_period;
		data_in <= x"ff"; wait for clk_period;
		data_in <= x"ff"; wait for clk_period;
		data_in <= x"ff"; wait for clk_period;
		data_in <= x"ff"; wait for clk_period;
		-- src MAC
		data_in <= x"00"; wait for clk_period;
		data_in <= x"23"; wait for clk_period;
		data_in <= x"18"; wait for clk_period;
		data_in <= x"29"; wait for clk_period;
		data_in <= x"26"; wait for clk_period;
		data_in <= x"7c"; wait for clk_period;
		-- type
		data_in <= x"08"; wait for clk_period;
		data_in <= x"06"; wait for clk_period;
		-- HW type
		data_in <= x"00"; wait for clk_period;
		data_in <= x"01"; wait for clk_period;
		-- Protocol type
		data_in <= x"08"; wait for clk_period;
		data_in <= x"00"; wait for clk_period;
		-- HW size
		data_in <= x"06"; wait for clk_period;
		-- protocol size
		data_in <= x"04"; wait for clk_period;
		-- Opcode
		data_in <= x"00"; wait for clk_period;
		data_in <= x"01"; wait for clk_period;
		-- Sender MAC
		data_in <= x"00"; wait for clk_period;
		data_in <= x"23"; wait for clk_period;
		data_in <= x"18"; wait for clk_period;
		data_in <= x"29"; wait for clk_period;
		data_in <= x"26"; wait for clk_period;
		data_in <= x"7c"; wait for clk_period;
		-- Sender IP
		data_in <= x"c0"; wait for clk_period;
		data_in <= x"a8"; wait for clk_period;
		data_in <= x"05"; wait for clk_period;
		data_in <= x"01"; wait for clk_period;
		-- Target MAC
		data_in <= x"00"; wait for clk_period;
		data_in <= x"00"; wait for clk_period;
		data_in <= x"00"; wait for clk_period;
		data_in <= x"00"; wait for clk_period;
		data_in <= x"00"; wait for clk_period;
		data_in <= x"00"; wait for clk_period;
		-- Target IP
		data_in <= x"c0"; wait for clk_period;
		data_in <= x"a8"; wait for clk_period;
		data_in <= x"05"; wait for clk_period;
		data_in <= x"09"; wait for clk_period;
		data_in <= x"00"; wait for clk_period;
		data_in <= x"00"; wait for clk_period;
		data_in <= x"00"; wait for clk_period;
		data_in_last <= '1';
		data_in <= x"00"; wait for clk_period;
		data_in_last <= '0';
		data_in_valid <= '0';
		
		-- ready to tx
		wait for clk_period*10;
		data_out_ready <= '1';
		
		wait for clk_period*50;
		
		-- Send a request for the IP that is already cached
		arp_req_req.ip <= x"c0a80501";
		arp_req_req.lookup_req <= '1';
		wait for clk_period;
		arp_req_req.lookup_req <= '0';

		wait for clk_period*50;
		
		-- Send a request for the IP that is not cached
		arp_req_req.ip <= x"c0a80503";
		arp_req_req.lookup_req <= '1';
		wait for clk_period;
		arp_req_req.lookup_req <= '0';
		wait for clk_period*80;
		-- Send the reply
		data_out_ready <= '1';

		report "T3: Send an ARP reply: 192.168.5.3 has mac 02:12:03:23:04:54";
		data_in_valid <= '1';
		-- dst MAC (bc)
		data_in <= x"ff"; wait for clk_period;
		data_in <= x"ff"; wait for clk_period;
		data_in <= x"ff"; wait for clk_period;
		data_in <= x"ff"; wait for clk_period;
		data_in <= x"ff"; wait for clk_period;
		data_in <= x"ff"; wait for clk_period;
		-- src MAC
		data_in <= x"02"; wait for clk_period;
		data_in <= x"12"; wait for clk_period;
		data_in <= x"03"; wait for clk_period;
		data_in <= x"23"; wait for clk_period;
		data_in <= x"04"; wait for clk_period;
		data_in <= x"54"; wait for clk_period;
		-- type
		data_in <= x"08"; wait for clk_period;
		data_in <= x"06"; wait for clk_period;
		-- HW type
		data_in <= x"00"; wait for clk_period;
		data_in <= x"01"; wait for clk_period;
		-- Protocol type
		data_in <= x"08"; wait for clk_period;
		data_in <= x"00"; wait for clk_period;
		-- HW size
		data_in <= x"06"; wait for clk_period;
		-- protocol size
		data_in <= x"04"; wait for clk_period;
		-- Opcode
		data_in <= x"00"; wait for clk_period;
		data_in <= x"02"; wait for clk_period;
		-- Sender MAC
		data_in <= x"02"; wait for clk_period;
		data_in <= x"12"; wait for clk_period;
		data_in <= x"03"; wait for clk_period;
		data_in <= x"23"; wait for clk_period;
		data_in <= x"04"; wait for clk_period;
		data_in <= x"54"; wait for clk_period;
		-- Sender IP
		data_in <= x"c0"; wait for clk_period;
		data_in <= x"a8"; wait for clk_period;
		data_in <= x"05"; wait for clk_period;
		data_in <= x"03"; wait for clk_period;
		-- Target MAC
		data_in <= x"00"; wait for clk_period;
		data_in <= x"23"; wait for clk_period;
		data_in <= x"20"; wait for clk_period;
		data_in <= x"21"; wait for clk_period;
		data_in <= x"22"; wait for clk_period;
		data_in <= x"23"; wait for clk_period;
		-- Target IP
		data_in <= x"c0"; wait for clk_period;
		data_in <= x"a8"; wait for clk_period;
		data_in <= x"05"; wait for clk_period;
		data_in <= x"09"; wait for clk_period;
		data_in <= x"00"; wait for clk_period;
		data_in <= x"00"; wait for clk_period;
		data_in <= x"00"; wait for clk_period;
		data_in_last <= '1';
		data_in <= x"00"; wait for clk_period;
		data_in_last <= '0';
		data_in_valid <= '0';

		report "--- end of tests ---";
      wait;
   end process;

END;
