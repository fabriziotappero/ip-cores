--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   07:38:43 02/13/2012
-- Design Name:   
-- Module Name:   arp_STORE_tb.vhd
-- Project Name:  udp3
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: arp_STORE_br
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
use ieee.std_logic_unsigned.all;
use work.arp_types.all;
 
ENTITY arp_STORE_tb IS
END arp_STORE_tb;
 
ARCHITECTURE behavior OF arp_STORE_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT arp_STORE_br
	 generic (
			MAX_ARP_ENTRIES : integer := 256							-- max entries in the store
			);
    PORT(
			-- read signals
			read_req				: in arp_store_rdrequest_t;		-- requesting a '1' or store
			read_result			: out arp_store_result_t;			-- the result
			-- write signals
			write_req			: in arp_store_wrrequest_t;		-- requesting a '1' or store
			-- control and status signals
			clear_store			: in std_logic;						-- erase all entries
			entry_count			: out unsigned(7 downto 0);		-- how many entries currently in store
			-- system signals
			clk					: in std_logic;
			reset 				: in  STD_LOGIC
        );
    END COMPONENT;
    

   --Inputs
   signal read_req : arp_store_rdrequest_t;
   signal write_req : arp_store_wrrequest_t;
   signal clear_store : std_logic := '0';
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';

 	--Outputs
   signal read_result : arp_store_result_t;
	signal entry_count : unsigned(7 downto 0);		-- how many entries currently in store

   -- Clock period definitions
   constant clk_period : time := 8 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: arp_STORE_br 
			generic map (
				MAX_ARP_ENTRIES => 4
				)
			PORT MAP (
          read_req => read_req,
          read_result => read_result,
          write_req => write_req,
			 clear_store => clear_store,
			 entry_count => entry_count,
          clk => clk,
          reset => reset
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
		read_req.req <= '0';
		read_req.ip <= (others => '0');
		write_req.req <= '0';
		write_req.entry.ip <= (others => '0');
		write_req.entry.mac <= (others => '0');
		reset <= '1';
      -- hold reset state
      wait for clk_period*10;
		reset <= '0';

      -- insert stimulus here 
		report "T1 - look for something when store is empty";
		read_req.ip <= x"12345678";
		read_req.req <= '1';
      wait for clk_period*4;
		assert read_result.status = NOT_FOUND		report "T1: expected NOT_FOUND";
		wait for clk_period;
		read_req.req <= '0';
		wait for clk_period;
		assert read_result.status = IDLE		report "T1: expected IDLE";
		assert entry_count = x"00"				report "T1: wrong entry count";

		report "T2 - insert first entry into store";
		write_req.entry.ip <= x"12345678";
		write_req.entry.mac <= x"002398127645";
		write_req.req <= '1';
      wait for clk_period;
		write_req.req <= '0';
		wait until read_result.status = IDLE;
      wait for clk_period;
		assert entry_count = x"01"				report "T2: wrong entry count";
		
		report "T3 - check if can find this single entry";
		read_req.ip <= x"12345678";
		read_req.req <= '1';
      wait until read_result.status = FOUND or read_result.status = NOT_FOUND;
      wait for clk_period;		
		assert read_result.status = FOUND						report "T3: expected FOUND";
		assert read_result.entry.ip = x"12345678"				report "T3: wrong ip addr";
		assert read_result.entry.mac = x"002398127645"		report "T3: wrong mac addr";
		wait for clk_period;
		read_req.req <= '0';
		wait for clk_period*2;
		assert read_result.status = IDLE		report "T3: expected IDLE";

		report "T4 - check unable to find missing entry with one entry in store";
		read_req.ip <= x"12345679";
		read_req.req <= '1';
      wait until read_result.status = FOUND or read_result.status = NOT_FOUND;
      wait for clk_period;		
		assert read_result.status = NOT_FOUND		report "T4: expected NOT_FOUND";
		wait for clk_period;
		read_req.req <= '0';
		wait for clk_period*2;
		assert read_result.status = IDLE		report "T4: expected IDLE";

		report "T5 - insert 2nd entry into store and check can find both entries";
		write_req.entry.ip <= x"12345679";
		write_req.entry.mac <= x"101202303404";
		write_req.req <= '1';
      wait for clk_period;
		write_req.req <= '0';
		wait until read_result.status = IDLE;
      wait for clk_period;
		assert entry_count = x"02"				report "T4: wrong entry count";
		read_req.ip <= x"12345678";
		read_req.req <= '1';
      wait until read_result.status = FOUND or read_result.status = NOT_FOUND;
      wait for clk_period;		
		assert read_result.status = FOUND						report "T5.1: expected FOUND";
		assert read_result.entry.ip = x"12345678"				report "T5.1: wrong ip addr";
		assert read_result.entry.mac = x"002398127645"		report "T5.1: wrong mac addr";
		read_req.req <= '0';
		wait for clk_period*2;
		assert read_result.status = IDLE		report "T5.1: expected IDLE";
		read_req.ip <= x"12345679";
		read_req.req <= '1';
      wait until read_result.status = FOUND or read_result.status = NOT_FOUND;
      wait for clk_period;		
		assert read_result.status = FOUND						report "T5.2: expected FOUND";
		assert read_result.entry.ip = x"12345679"				report "T5.2: wrong ip addr";
		assert read_result.entry.mac = x"101202303404"		report "T5.2: wrong mac addr";
		read_req.req <= '0';
		wait for clk_period*2;
		assert read_result.status = IDLE		report "T5.2: expected IDLE";

		report "T6 - insert 2 more entries so that the store is full. check can find all";
		write_req.entry.ip <= x"1234567a";
		write_req.entry.mac <= x"10120230340a";
		write_req.req <= '1';
      wait for clk_period;
		write_req.req <= '0';
		wait until read_result.status = IDLE;
      wait for clk_period;
		write_req.entry.ip <= x"1234567b";
		write_req.entry.mac <= x"10120230340b";
		write_req.req <= '1';
      wait for clk_period;
		write_req.req <= '0';
		wait until read_result.status = IDLE;
      wait for clk_period;
		assert entry_count = x"04"				report "T6: wrong entry count";
		read_req.ip <= x"12345678";
		read_req.req <= '1';
      wait until read_result.status = FOUND or read_result.status = NOT_FOUND;
      wait for clk_period;		
		assert read_result.status = FOUND						report "T6.1: expected FOUND";
		assert read_result.entry.ip = x"12345678"				report "T6.1: wrong ip addr";
		assert read_result.entry.mac = x"002398127645"		report "T6.1: wrong mac addr";
		read_req.req <= '0';
		wait for clk_period*2;
		assert read_result.status = IDLE							report "T6.1: expected IDLE";
		read_req.ip <= x"12345679";
		read_req.req <= '1';
      wait until read_result.status = FOUND or read_result.status = NOT_FOUND;
      wait for clk_period;		
		assert read_result.status = FOUND						report "T6.2: expected FOUND";
		assert read_result.entry.ip = x"12345679"				report "T6.2: wrong ip addr";
		assert read_result.entry.mac = x"101202303404"		report "T6.2: wrong mac addr";
		read_req.req <= '0';
		wait for clk_period*2;
		assert read_result.status = IDLE							report "T6.2: expected IDLE";
		read_req.ip <= x"1234567a";
		read_req.req <= '1';
      wait until read_result.status = FOUND or read_result.status = NOT_FOUND;
      wait for clk_period;		
		assert read_result.status = FOUND						report "T6.3: expected FOUND";
		assert read_result.entry.ip = x"1234567a"				report "T6.3: wrong ip addr";
		assert read_result.entry.mac = x"10120230340a"		report "T6.3: wrong mac addr";
		read_req.req <= '0';
		wait for clk_period*2;
		assert read_result.status = IDLE							report "T6.3: expected IDLE";
		read_req.ip <= x"1234567b";
		read_req.req <= '1';
      wait until read_result.status = FOUND or read_result.status = NOT_FOUND;
      wait for clk_period;		
		assert read_result.status = FOUND						report "T6.4: expected FOUND";
		assert read_result.entry.ip = x"1234567b"				report "T6.4: wrong ip addr";
		assert read_result.entry.mac = x"10120230340b"		report "T6.4: wrong mac addr";
		read_req.req <= '0';
		wait for clk_period*2;
		assert read_result.status = IDLE							report "T6.4: expected IDLE";

		report "T7 - with store full, check that we dont find missing item";
		read_req.ip <= x"1233367b";
		read_req.req <= '1';
      wait until read_result.status = FOUND or read_result.status = NOT_FOUND;
      wait for clk_period;		
		assert read_result.status = NOT_FOUND					report "T7: expected NOT_FOUND";
		read_req.req <= '0';
		wait for clk_period*2;
		assert read_result.status = IDLE							report "T7: expected IDLE";

		report "T8 - insert additional entry into store - will erase one of the others";
		write_req.entry.ip <= x"12345699";
		write_req.entry.mac <= x"992398127699";
		write_req.req <= '1';
      wait for clk_period;
		write_req.req <= '0';
		wait until read_result.status = IDLE;
      wait for clk_period;
		assert entry_count = x"04"									report "T8: wrong entry count";
		read_req.ip <= x"12345699";
		read_req.req <= '1';
      wait until read_result.status = FOUND or read_result.status = NOT_FOUND;
      wait for clk_period;		
		assert read_result.status = FOUND						report "T8: expected FOUND";
		assert read_result.entry.ip = x"12345699"				report "T8: wrong ip addr";
		assert read_result.entry.mac = x"992398127699"		report "T8: wrong mac addr";
		read_req.req <= '0';
		wait for clk_period*2;
		assert read_result.status = IDLE							report "T8: expected IDLE";

		report "T9 - clear the store and ensure cant find something that was there";
		clear_store <= '1';
      wait for clk_period;
		clear_store <= '0';
      wait for clk_period;
		assert entry_count = x"00"									report "T9: wrong entry count";
		read_req.ip <= x"12345699";
		read_req.req <= '1';
      wait until read_result.status = FOUND or read_result.status = NOT_FOUND;
      wait for clk_period;		
		assert read_result.status = NOT_FOUND					report "T9: expected NOT_FOUND";
		read_req.req <= '0';
		wait for clk_period*2;
		assert read_result.status = IDLE							report "T9: expected IDLE";

		report "T10 - refill the store with three entries";
		write_req.entry.ip <= x"12345675";
		write_req.entry.mac <= x"10120230340a";
		write_req.req <= '1';
      wait for clk_period;
		write_req.req <= '0';
		wait until read_result.status = IDLE;
      wait for clk_period;
		write_req.entry.ip <= x"12345676";
		write_req.entry.mac <= x"10120230340b";
		write_req.req <= '1';
      wait for clk_period;
		write_req.req <= '0';
		wait until read_result.status = IDLE;
      wait for clk_period;
		write_req.entry.ip <= x"12345677";
		write_req.entry.mac <= x"10120230340c";
		write_req.req <= '1';
      wait for clk_period;
		write_req.req <= '0';
		wait until read_result.status = IDLE;
      wait for clk_period;
		assert entry_count = x"03"									report "T10: wrong entry count";

		report "T11 - check middle entry, then change it and check again";
		read_req.ip <= x"12345676";
		read_req.req <= '1';
      wait until read_result.status = FOUND or read_result.status = NOT_FOUND;
      wait for clk_period;		
		assert read_result.status = FOUND						report "T11.1: expected FOUND";
		assert read_result.entry.ip = x"12345676"				report "T11.1: wrong ip addr";
		assert read_result.entry.mac = x"10120230340b"		report "T11.1: wrong mac addr";
		read_req.req <= '0';
		wait for clk_period*2;
		assert read_result.status = IDLE							report "T11.1: expected IDLE";
		write_req.entry.ip <= x"12345676";
		write_req.entry.mac <= x"10120990340b";
		write_req.req <= '1';
      wait for clk_period;
		write_req.req <= '0';
      wait for clk_period;
		assert entry_count = x"03"									report "T11: wrong entry count";
		read_req.ip <= x"12345676";
		read_req.req <= '1';
      wait until read_result.status = FOUND or read_result.status = NOT_FOUND;
      wait for clk_period;		
		assert read_result.status = FOUND						report "T11.2: expected FOUND";
		assert read_result.entry.ip = x"12345676"				report "T11.2: wrong ip addr";
		assert read_result.entry.mac = x"10120990340b"		report "T11.2: wrong mac addr";
		read_req.req <= '0';
		wait for clk_period*2;
		assert read_result.status = IDLE							report "T11.2: expected IDLE";

		report "T12 - check 2nd write at beginning";
		-- clear store, write 1st entry, overwrite the entry, and check
		clear_store <= '1';
      wait for clk_period;
		clear_store <= '0';
      wait for clk_period;
		assert entry_count = x"00"									report "T12.1: wrong entry count";
		write_req.entry.ip <= x"12345678";
		write_req.entry.mac <= x"002398127645";
		write_req.req <= '1';
      wait for clk_period;
		write_req.req <= '0';
		wait until read_result.status = IDLE;
      wait for clk_period;
		assert entry_count = x"01"									report "T12.2: wrong entry count";
		write_req.entry.ip <= x"12345678";
		write_req.entry.mac <= x"002398127647";
		write_req.req <= '1';
      wait for clk_period;
		write_req.req <= '0';
		wait until read_result.status = IDLE;
      wait for clk_period;
		assert entry_count = x"01"									report "T12.3: wrong entry count";
		read_req.ip <= x"12345678";
		read_req.req <= '1';
      wait until read_result.status = FOUND or read_result.status = NOT_FOUND;
      wait for clk_period;		
		assert read_result.status = FOUND						report "T12.4: expected FOUND";
		assert read_result.entry.ip = x"12345678"				report "T12.4: wrong ip addr";
		assert read_result.entry.mac = x"002398127647"		report "T12.4: wrong mac addr";
		read_req.req <= '0';
		wait for clk_period*2;
		assert read_result.status = IDLE							report "T12.5: expected IDLE";

		report "--- end of tests ---";
      wait;
   end process;

END;
