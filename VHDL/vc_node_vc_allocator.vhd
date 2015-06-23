
-----------------------------------------------------------------------------
-- NoCem -- Network on Chip Emulation Tool for System on Chip Research 
-- and Implementations
-- 
-- Copyright (C) 2006  Graham Schelle, Dirk Grunwald
-- 
-- This program is free software; you can redistribute it and/or
-- modify it under the terms of the GNU General Public License
-- as published by the Free Software Foundation; either version 2
-- of the License, or (at your option) any later version.
-- 
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  
-- 02110-1301, USA.
-- 
-- The authors can be contacted by email: <schelleg,grunwald>@cs.colorado.edu 
-- 
-- or by mail: Campus Box 430, Department of Computer Science,
-- University of Colorado at Boulder, Boulder, Colorado 80309
-------------------------------------------------------------------------------- 


-- 
-- Filename: vc_node_vc_allocator.vhd
-- 
-- Description: vc_node virtual channel allocator
-- 


--
--VC Allocator will do
--   1. manage vc allocation and deallocation for incoming packets looking for outgoing VC
--
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.pkg_nocem.all;



entity vc_node_vc_allocator is
    Port ( 
		local_ch_addr : in std_logic_vector(4 downto 0);
		outoing_vc_status : in std_logic_vector(NOCEM_NUM_VC-1 downto 0);

	   n_channel_cntrl_in  : in channel_cntrl_word;
	   n_channel_cntrl_out : out channel_cntrl_word;

	   s_channel_cntrl_in  : in channel_cntrl_word;
	   s_channel_cntrl_out : out channel_cntrl_word;

	   e_channel_cntrl_in  : in channel_cntrl_word;
	   e_channel_cntrl_out : out channel_cntrl_word;

	   w_channel_cntrl_in  : in channel_cntrl_word;
	   w_channel_cntrl_out : out channel_cntrl_word;

	   ap_channel_cntrl_in  : in channel_cntrl_word;
	   ap_channel_cntrl_out : out channel_cntrl_word;
	 
	   clk : in std_logic;
      rst : in std_logic
		
		);
end vc_node_vc_allocator;

architecture Behavioral of vc_node_vc_allocator is

   -- determining if there is a valid request on a per INCOMING channel basis
	signal vc_req_array  : std_logic_vector(4 downto 0);

	-- determine the next free outgoing VC
	signal next_free_vc  : std_logic_vector(NOCEM_NUM_VC-1 downto 0);
	signal vc_state : std_logic_Vector(NOCEM_NUM_VC-1 downto 0);   -- 0: free, 1: allocated --
	signal vc_allocate : std_logic;
	signal free_this_vc	 : std_logic_vector(NOCEM_NUM_VC-1 downto 0);
	signal allocated_vc : std_logic_vector(NOCEM_NUM_VC-1 downto 0);


	-- DEBUG SIGNALS
	signal debug_allocated_vc : std_logic_vector(NOCEM_NUM_VC-1 downto 0);

	signal debug_alloc_counter : std_logic_vector(15 downto 0);
	signal debug_dealloc_counter : std_logic_vector(15 downto 0);



begin
				  
	-- setting up incoming request signals
	vc_req_array(NOCEM_NORTH_IX) <= '1' when n_channel_cntrl_in(NOCEM_CHFIFO_VC_REQER_VCID_HIX downto NOCEM_CHFIFO_VC_REQER_VCID_LIX) /= 0 and n_channel_cntrl_in(NOCEM_CHFIFO_VC_REQER_DEST_CH_HIX downto NOCEM_CHFIFO_VC_REQER_DEST_CH_LIX) = local_ch_addr  else '0';
	vc_req_array(NOCEM_SOUTH_IX) <= '1' when s_channel_cntrl_in(NOCEM_CHFIFO_VC_REQER_VCID_HIX downto NOCEM_CHFIFO_VC_REQER_VCID_LIX) /= 0 and s_channel_cntrl_in(NOCEM_CHFIFO_VC_REQER_DEST_CH_HIX downto NOCEM_CHFIFO_VC_REQER_DEST_CH_LIX) = local_ch_addr  else '0';
	vc_req_array(NOCEM_WEST_IX) <= '1' when w_channel_cntrl_in(NOCEM_CHFIFO_VC_REQER_VCID_HIX downto NOCEM_CHFIFO_VC_REQER_VCID_LIX) /= 0 and w_channel_cntrl_in(NOCEM_CHFIFO_VC_REQER_DEST_CH_HIX downto NOCEM_CHFIFO_VC_REQER_DEST_CH_LIX) = local_ch_addr  else '0';
	vc_req_array(NOCEM_EAST_IX) <= '1' when e_channel_cntrl_in(NOCEM_CHFIFO_VC_REQER_VCID_HIX downto NOCEM_CHFIFO_VC_REQER_VCID_LIX) /= 0 and e_channel_cntrl_in(NOCEM_CHFIFO_VC_REQER_DEST_CH_HIX downto NOCEM_CHFIFO_VC_REQER_DEST_CH_LIX) = local_ch_addr  else '0';
	vc_req_array(NOCEM_AP_IX) <= '1' when ap_channel_cntrl_in(NOCEM_CHFIFO_VC_REQER_VCID_HIX downto NOCEM_CHFIFO_VC_REQER_VCID_LIX) /= 0 and ap_channel_cntrl_in(NOCEM_CHFIFO_VC_REQER_DEST_CH_HIX downto NOCEM_CHFIFO_VC_REQER_DEST_CH_LIX) = local_ch_addr  else '0';

	-- currently, vc status is '1' when eop is read out of VC
	free_this_vc  <= outoing_vc_status;



----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------


vc_state_gen_clkd : process (clk,rst)
begin

	if rst='1' then
		vc_state <= (others => '0');
	elsif clk'event and clk='1' then
	
		-- an interesting bit play that should work to keep vc_state happy....
		vc_state <= (allocated_vc or vc_state) xor free_this_vc;	

	end if;


end process;





gen_vc_status_uclkd : process (vc_state)
begin
		next_free_vc <= (others => '0');

		l2: for I in NOCEM_NUM_VC-1 downto 0 loop
			if vc_state(I) = '0' then
				next_free_vc <= CONV_STD_LOGIC_VECTOR(2**I,NOCEM_NUM_VC);
			end if;											  	

		end loop;
		
end process;




gen_grant_clkd : process (clk,rst)
begin

	if rst='1' then
	
		
		n_channel_cntrl_out <= (others => '0');
		e_channel_cntrl_out <= (others => '0');
		s_channel_cntrl_out <= (others => '0');
		w_channel_cntrl_out <= (others => '0');
		ap_channel_cntrl_out <= (others => '0');
		vc_allocate <= '0';

		allocated_vc <= (others => '0');


	elsif clk'event and clk='1' then
	
		allocated_vc <= (others => '0');
		
		
		-- zero them out if nothing is happening
		n_channel_cntrl_out <= (others => '0');
		e_channel_cntrl_out <= (others => '0');
		s_channel_cntrl_out <= (others => '0');
		w_channel_cntrl_out <= (others => '0');
		ap_channel_cntrl_out <= (others => '0');
		vc_allocate <= '0';

		-- go through requests and satisfy one of them per cycle
		if vc_req_array(NOCEM_NORTH_IX) = '1' and vc_allocate = '0' then
			n_channel_cntrl_out(NOCEM_CHFIFO_VC_ALLOC_FROMNODE_HIX downto NOCEM_CHFIFO_VC_ALLOC_FROMNODE_LIX) <= next_free_vc;
			n_channel_cntrl_out(NOCEM_CHFIFO_VC_REQER_FROMNODE_HIX downto NOCEM_CHFIFO_VC_REQER_FROMNODE_LIX) <= n_channel_cntrl_in(NOCEM_CHFIFO_VC_REQER_VCID_HIX downto NOCEM_CHFIFO_VC_REQER_VCID_LIX);
			if next_free_vc /= 0 then
				vc_allocate <= '1';
				allocated_vc <= next_free_vc;
			end if;
		elsif	vc_req_array(NOCEM_SOUTH_IX) = '1' and vc_allocate = '0' then
			s_channel_cntrl_out(NOCEM_CHFIFO_VC_ALLOC_FROMNODE_HIX downto NOCEM_CHFIFO_VC_ALLOC_FROMNODE_LIX) <= next_free_vc;
			s_channel_cntrl_out(NOCEM_CHFIFO_VC_REQER_FROMNODE_HIX downto NOCEM_CHFIFO_VC_REQER_FROMNODE_LIX) <= s_channel_cntrl_in(NOCEM_CHFIFO_VC_REQER_VCID_HIX downto NOCEM_CHFIFO_VC_REQER_VCID_LIX);
			if next_free_vc /= 0 then
				vc_allocate <= '1';
				allocated_vc <= next_free_vc;
			end if;
		elsif	vc_req_array(NOCEM_EAST_IX) = '1' and vc_allocate = '0' then
			e_channel_cntrl_out(NOCEM_CHFIFO_VC_ALLOC_FROMNODE_HIX downto NOCEM_CHFIFO_VC_ALLOC_FROMNODE_LIX) <= next_free_vc;
			e_channel_cntrl_out(NOCEM_CHFIFO_VC_REQER_FROMNODE_HIX downto NOCEM_CHFIFO_VC_REQER_FROMNODE_LIX) <= e_channel_cntrl_in(NOCEM_CHFIFO_VC_REQER_VCID_HIX downto NOCEM_CHFIFO_VC_REQER_VCID_LIX);
			if next_free_vc /= 0 then
				vc_allocate <= '1';
				allocated_vc <= next_free_vc;
			end if;
		elsif	vc_req_array(NOCEM_WEST_IX) = '1' and vc_allocate = '0' then
			w_channel_cntrl_out(NOCEM_CHFIFO_VC_ALLOC_FROMNODE_HIX downto NOCEM_CHFIFO_VC_ALLOC_FROMNODE_LIX) <= next_free_vc;
			w_channel_cntrl_out(NOCEM_CHFIFO_VC_REQER_FROMNODE_HIX downto NOCEM_CHFIFO_VC_REQER_FROMNODE_LIX) <= w_channel_cntrl_in(NOCEM_CHFIFO_VC_REQER_VCID_HIX downto NOCEM_CHFIFO_VC_REQER_VCID_LIX);
			if next_free_vc /= 0 then
				vc_allocate <= '1';
				allocated_vc <= next_free_vc;
			end if;
		elsif	vc_req_array(NOCEM_AP_IX) = '1' and vc_allocate = '0' then
			ap_channel_cntrl_out(NOCEM_CHFIFO_VC_ALLOC_FROMNODE_HIX downto NOCEM_CHFIFO_VC_ALLOC_FROMNODE_LIX) <= next_free_vc;
			ap_channel_cntrl_out(NOCEM_CHFIFO_VC_REQER_FROMNODE_HIX downto NOCEM_CHFIFO_VC_REQER_FROMNODE_LIX) <= ap_channel_cntrl_in(NOCEM_CHFIFO_VC_REQER_VCID_HIX downto NOCEM_CHFIFO_VC_REQER_VCID_LIX);
			if next_free_vc /= 0 then
				vc_allocate <= '1';
				allocated_vc <= next_free_vc;
			end if;
		else
			null;
		end if;
	end if;



end process;







----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------
--
--gen_vc_status_clkd : process (clk,rst)
--begin
--
--	if rst='1' then
--		--next_free_vc <= ('1',others => '0');	
--		vc_state <= (others => '0');
--		
--	elsif clk'event and clk='1' then
--
--	
--
--
--
----		if vc_state = "11" then
----			next_free_vc <= (others => '0');
----		end if;
--
--
--		 l1: for I in NOCEM_NUM_VC-1 downto 0 loop
--		 	if vc_state(I) = '0' and next_free_vc(I) = '1' and vc_allocate = '1' then -- free going to allocated
--				vc_state(I) <= '1';
--			elsif vc_state(I) = '1' and free_this_vc(I) = '1' then -- allocated going to free
--				vc_state(I) <= '0';
--			end if;		 
--		 end loop;
--
--	end if;
--end process;
--
----gen_vc_status_cclkd : process (clk,rst)
----begin
----
----	if rst='1' then
----		next_free_vc <= (others => '0');
----	elsif clk'event and clk='1' then
----		l2: for I in NOCEM_NUM_VC-1 downto 0 loop
----			if vc_state(I) = '0' then
----				next_free_vc <= CONV_STD_LOGIC_VECTOR(2**I,NOCEM_NUM_VC);
----			end if;											  	
----
----		end loop;
----	end if;
----
----end process;
--
--
--gen_vc_status_uclkd : process (vc_state)
--begin
--		next_free_vc <= (others => '0');
--
--		l2: for I in NOCEM_NUM_VC-1 downto 0 loop
--			if vc_state(I) = '0' then
--				next_free_vc <= CONV_STD_LOGIC_VECTOR(2**I,NOCEM_NUM_VC);
--			end if;											  	
--
--		end loop;
--end process;
--
--
--
--
--
--
--
--gen_grant_clkd : process (clk,rst)
--begin
--
--	if rst='1' then
--	
--		
--		n_channel_cntrl_out <= (others => '0');
--		e_channel_cntrl_out <= (others => '0');
--		s_channel_cntrl_out <= (others => '0');
--		w_channel_cntrl_out <= (others => '0');
--		ap_channel_cntrl_out <= (others => '0');
--		vc_allocate <= '0';
--
--	debug_allocated_vc <= (others => '0');
--
--
--	elsif clk'event and clk='1' then
--	
--		debug_allocated_vc <= (others => '0');
--		
--		
--		-- zero them out if nothing is happening
--		n_channel_cntrl_out <= (others => '0');
--		e_channel_cntrl_out <= (others => '0');
--		s_channel_cntrl_out <= (others => '0');
--		w_channel_cntrl_out <= (others => '0');
--		ap_channel_cntrl_out <= (others => '0');
--		vc_allocate <= '0';
--
--		-- go through requests and satisfy one of them per cycle
--		if vc_req_array(NOCEM_NORTH_IX) = '1' and vc_allocate = '0' then
--			n_channel_cntrl_out(NOCEM_CHFIFO_VC_ALLOC_FROMNODE_HIX downto NOCEM_CHFIFO_VC_ALLOC_FROMNODE_LIX) <= next_free_vc;
--			n_channel_cntrl_out(NOCEM_CHFIFO_VC_REQER_FROMNODE_HIX downto NOCEM_CHFIFO_VC_REQER_FROMNODE_LIX) <= n_channel_cntrl_in(NOCEM_CHFIFO_VC_REQER_VCID_HIX downto NOCEM_CHFIFO_VC_REQER_VCID_LIX);
--			if next_free_vc /= 0 then
--				vc_allocate <= '1';
--				debug_allocated_vc <= next_free_vc;
--			end if;
--		elsif	vc_req_array(NOCEM_SOUTH_IX) = '1' and vc_allocate = '0' then
--			s_channel_cntrl_out(NOCEM_CHFIFO_VC_ALLOC_FROMNODE_HIX downto NOCEM_CHFIFO_VC_ALLOC_FROMNODE_LIX) <= next_free_vc;
--			s_channel_cntrl_out(NOCEM_CHFIFO_VC_REQER_FROMNODE_HIX downto NOCEM_CHFIFO_VC_REQER_FROMNODE_LIX) <= s_channel_cntrl_in(NOCEM_CHFIFO_VC_REQER_VCID_HIX downto NOCEM_CHFIFO_VC_REQER_VCID_LIX);
--			if next_free_vc /= 0 then
--				vc_allocate <= '1';
--				debug_allocated_vc <= next_free_vc;
--			end if;
--		elsif	vc_req_array(NOCEM_EAST_IX) = '1' and vc_allocate = '0' then
--			e_channel_cntrl_out(NOCEM_CHFIFO_VC_ALLOC_FROMNODE_HIX downto NOCEM_CHFIFO_VC_ALLOC_FROMNODE_LIX) <= next_free_vc;
--			e_channel_cntrl_out(NOCEM_CHFIFO_VC_REQER_FROMNODE_HIX downto NOCEM_CHFIFO_VC_REQER_FROMNODE_LIX) <= e_channel_cntrl_in(NOCEM_CHFIFO_VC_REQER_VCID_HIX downto NOCEM_CHFIFO_VC_REQER_VCID_LIX);
--			if next_free_vc /= 0 then
--				vc_allocate <= '1';
--				debug_allocated_vc <= next_free_vc;
--			end if;
--		elsif	vc_req_array(NOCEM_WEST_IX) = '1' and vc_allocate = '0' then
--			w_channel_cntrl_out(NOCEM_CHFIFO_VC_ALLOC_FROMNODE_HIX downto NOCEM_CHFIFO_VC_ALLOC_FROMNODE_LIX) <= next_free_vc;
--			w_channel_cntrl_out(NOCEM_CHFIFO_VC_REQER_FROMNODE_HIX downto NOCEM_CHFIFO_VC_REQER_FROMNODE_LIX) <= w_channel_cntrl_in(NOCEM_CHFIFO_VC_REQER_VCID_HIX downto NOCEM_CHFIFO_VC_REQER_VCID_LIX);
--			if next_free_vc /= 0 then
--				vc_allocate <= '1';
--				debug_allocated_vc <= next_free_vc;
--			end if;
--		elsif	vc_req_array(NOCEM_AP_IX) = '1' and vc_allocate = '0' then
--			ap_channel_cntrl_out(NOCEM_CHFIFO_VC_ALLOC_FROMNODE_HIX downto NOCEM_CHFIFO_VC_ALLOC_FROMNODE_LIX) <= next_free_vc;
--			ap_channel_cntrl_out(NOCEM_CHFIFO_VC_REQER_FROMNODE_HIX downto NOCEM_CHFIFO_VC_REQER_FROMNODE_LIX) <= ap_channel_cntrl_in(NOCEM_CHFIFO_VC_REQER_VCID_HIX downto NOCEM_CHFIFO_VC_REQER_VCID_LIX);
--			if next_free_vc /= 0 then
--				vc_allocate <= '1';
--				debug_allocated_vc <= next_free_vc;
--			end if;
--		else
--			null;
--		end if;
--	end if;
--
--
--
--end process;
--



--	signal debug_alloc_counter : std_logic_vector(15 downto 0);
--	signal debug_dealloc_counter : std_logic_vector(15 downto 0);
debug_proc : process (clk,rst)
begin

	if rst='1' then
		debug_alloc_counter   <= (others => '0');
		debug_dealloc_counter <= (others => '0');
	elsif clk'event and clk='1' then
		if vc_allocate = '1' then
			debug_alloc_counter   <= debug_alloc_counter+1;
		end if;

		if free_this_vc /= 0 then
			debug_dealloc_counter <= debug_dealloc_counter+1;
		end if;
	
	
	end if;

end process;





end Behavioral;
