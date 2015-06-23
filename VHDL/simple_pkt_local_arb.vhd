
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
-- Filename: simple_pkt_local_arb.vhd
-- 
-- Description: nonVC design arbiter
-- 



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


use work.pkg_nocem.all;


entity simple_pkt_local_arb is
    Port ( 

		-- local arb info (should be held constant on incoming signal)
		local_arb_addr : std_logic_vector(NOCEM_AW-1 downto 0);

		-- needed to mux outputs for the accompanying switch
 		arb_grant_output : out arb_decision_array(4 downto 0);
			 

	   n_pkt_cntrl_in : in pkt_cntrl_word;
	   n_pkt_cntrl_out : out pkt_cntrl_word;
	   n_channel_cntrl_in  : in channel_cntrl_word;
	   n_channel_cntrl_out : out channel_cntrl_word;

	   s_pkt_cntrl_in : in pkt_cntrl_word;
	   s_pkt_cntrl_out : out pkt_cntrl_word;
	   s_channel_cntrl_in  : in channel_cntrl_word;
	   s_channel_cntrl_out : out channel_cntrl_word;

	   e_pkt_cntrl_in : in pkt_cntrl_word;
	   e_pkt_cntrl_out : out pkt_cntrl_word;
	   e_channel_cntrl_in  : in channel_cntrl_word;
	   e_channel_cntrl_out : out channel_cntrl_word;

	   w_pkt_cntrl_in : in pkt_cntrl_word;
	   w_pkt_cntrl_out : out pkt_cntrl_word;
	   w_channel_cntrl_in  : in channel_cntrl_word;
	   w_channel_cntrl_out : out channel_cntrl_word;


	   ap_pkt_cntrl_in : in pkt_cntrl_word;
	   ap_pkt_cntrl_out : out pkt_cntrl_word;
	   ap_channel_cntrl_in  : in channel_cntrl_word;
	   ap_channel_cntrl_out : out channel_cntrl_word;
	 
	 	clk : in std_logic;
      rst : in std_logic
		);
end simple_pkt_local_arb;

architecture Behavioral of simple_pkt_local_arb is


signal local_addr_x : std_logic_vector(NOCEM_AW/2 -1 downto 0);
signal local_addr_y : std_logic_vector(NOCEM_AW/2 -1 downto 0);




	-- since much of the work is repetitive, can use looping w/ indexing 
	-- to save massive repetitive coding

		--many operations can be easily written if inputs are in array form
		signal dest_local_port    			: arb_decision_array(4 downto 0);
		signal dest_addr_array    			: node_addr_array(4 downto 0);
		signal datain_valid_array 			: std_logic_vector(4 downto 0);
		signal pkt_cntrl_valid_array 		: std_logic_vector(4 downto 0);
		signal pkt_cntrl_data_array      : pkt_cntrl_array(4 downto 0);
		signal arb_decision_enum     : arb_decision_array(4 downto 0);
		signal channel_cntrl_in_array_i  : channel_cntrl_array(4 downto 0);
		signal channel_cntrl_out_array_i : channel_cntrl_array(4 downto 0);


 --signal srcToDstTimes2 : node_addr_array(4 downto 0);



begin

	

  	datain_valid_array(NOCEM_NORTH_IX) <= n_channel_cntrl_in(NOCEM_CHFIFO_DATA_EMPTY_N_IX);
  	datain_valid_array(NOCEM_SOUTH_IX) <= s_channel_cntrl_in(NOCEM_CHFIFO_DATA_EMPTY_N_IX);
	datain_valid_array(NOCEM_EAST_IX)  <= e_channel_cntrl_in(NOCEM_CHFIFO_DATA_EMPTY_N_IX);
	datain_valid_array(NOCEM_WEST_IX)  <= w_channel_cntrl_in(NOCEM_CHFIFO_DATA_EMPTY_N_IX);
	datain_valid_array(NOCEM_AP_IX)    <= ap_channel_cntrl_in(NOCEM_CHFIFO_DATA_EMPTY_N_IX);

  	channel_cntrl_in_array_i(NOCEM_NORTH_IX) <= n_channel_cntrl_in;
  	channel_cntrl_in_array_i(NOCEM_SOUTH_IX) <= s_channel_cntrl_in;
	channel_cntrl_in_array_i(NOCEM_EAST_IX)  <= e_channel_cntrl_in;
	channel_cntrl_in_array_i(NOCEM_WEST_IX)  <= w_channel_cntrl_in;
	channel_cntrl_in_array_i(NOCEM_AP_IX)    <= ap_channel_cntrl_in;

  	n_channel_cntrl_out  <= channel_cntrl_out_array_i(NOCEM_NORTH_IX);
  	s_channel_cntrl_out  <= channel_cntrl_out_array_i(NOCEM_SOUTH_IX);
	e_channel_cntrl_out  <= channel_cntrl_out_array_i(NOCEM_EAST_IX);
	w_channel_cntrl_out  <= channel_cntrl_out_array_i(NOCEM_WEST_IX);
	ap_channel_cntrl_out <= channel_cntrl_out_array_i(NOCEM_AP_IX);

  	pkt_cntrl_valid_array(NOCEM_NORTH_IX) <= n_channel_cntrl_in(NOCEM_CHFIFO_CNTRL_EMPTY_N_IX);
  	pkt_cntrl_valid_array(NOCEM_SOUTH_IX) <= s_channel_cntrl_in(NOCEM_CHFIFO_CNTRL_EMPTY_N_IX);
	pkt_cntrl_valid_array(NOCEM_EAST_IX)  <= e_channel_cntrl_in(NOCEM_CHFIFO_CNTRL_EMPTY_N_IX);
	pkt_cntrl_valid_array(NOCEM_WEST_IX)  <= w_channel_cntrl_in(NOCEM_CHFIFO_CNTRL_EMPTY_N_IX);
	pkt_cntrl_valid_array(NOCEM_AP_IX)    <= ap_channel_cntrl_in(NOCEM_CHFIFO_CNTRL_EMPTY_N_IX);

  	pkt_cntrl_data_array(NOCEM_NORTH_IX) <= n_pkt_cntrl_in;
  	pkt_cntrl_data_array(NOCEM_SOUTH_IX) <= s_pkt_cntrl_in;
	pkt_cntrl_data_array(NOCEM_EAST_IX)  <= e_pkt_cntrl_in;
	pkt_cntrl_data_array(NOCEM_WEST_IX)  <= w_pkt_cntrl_in;
	pkt_cntrl_data_array(NOCEM_AP_IX)    <= ap_pkt_cntrl_in;

	arb_decision_enum(NOCEM_AP_IX) <= ARB_AP;
	arb_decision_enum(NOCEM_NORTH_IX) <= ARB_NORTH;
	arb_decision_enum(NOCEM_SOUTH_IX) <= ARB_SOUTH;
	arb_decision_enum(NOCEM_EAST_IX) <= ARB_EAST;
	arb_decision_enum(NOCEM_WEST_IX) <= ARB_WEST;




	--local address breakdown for readibility....
	local_addr_x <= local_arb_addr(NOCEM_AW-1 downto NOCEM_AW/2);
	local_addr_y <= local_arb_addr(NOCEM_AW/2 -1 downto 0);

	-- simply pass on the pkt_cntrl signals to the switch 
	-- (may modify in other configs)
   n_pkt_cntrl_out <= n_pkt_cntrl_in;
	s_pkt_cntrl_out <= s_pkt_cntrl_in;
	e_pkt_cntrl_out <= e_pkt_cntrl_in;
	w_pkt_cntrl_out <= w_pkt_cntrl_in;
	ap_pkt_cntrl_out <= ap_pkt_cntrl_in;




-- process to generate destination address from pkt_cntrl line

dest_addr_gen_process : process (pkt_cntrl_valid_array, pkt_cntrl_data_array)
begin

	l1: for I in 4 downto 0 loop
		if pkt_cntrl_valid_array(I) = '1' then
			 dest_addr_array(I) <= pkt_cntrl_data_array(I)(NOCEM_PKTCNTRL_DEST_ADDR_HIX downto NOCEM_PKTCNTRL_DEST_ADDR_LIX);
		else
			 dest_addr_array(I) <= (others => '0');
		end if;	
	end loop;

 
end process;

  





-- process to determine routing based on incoming addr and data valid
-- decision determined by topology and datain destination address

port_dest_gen_process : process (datain_valid_array, local_addr_x, local_addr_y, dest_addr_array)
begin



		-- DOUBLE TORUS: north/south have loop around, east/west have looparound....
		if NOCEM_TOPOLOGY_TYPE = NOCEM_TOPOLOGY_DTORUS then 
			l20 : for I in 4 downto 0 loop 
				dest_local_port(I) <= ARB_NODECISION;

				if datain_valid_array(I) = '1' then

					-- src > dst address. go east if ROWS >= 2(SRC-DST) . go west if ROWS < 2(SRC-DST)
					if dest_addr_array(I)(NOCEM_AW-1 downto NOCEM_AW/2) < local_addr_x then							

							if NOCEM_NUM_ROWS >= TO_STDLOGICVECTOR(TO_BITVECTOR(local_addr_x - dest_addr_array(I)(NOCEM_AW-1 downto NOCEM_AW/2)) sll 1) then				
								dest_local_port(I) <= ARB_EAST;	
							else
								dest_local_port(I) <= ARB_WEST;
							end if;
					end if;
			
					-- dst > src address. go east if ROWS >= 2(DST-SRC) . go west if ROWS < 2(DST-SRC)
					if dest_addr_array(I)(NOCEM_AW-1 downto NOCEM_AW/2) > local_addr_x then
							
							if NOCEM_NUM_ROWS >= TO_STDLOGICVECTOR(TO_BITVECTOR(dest_addr_array(I)(NOCEM_AW-1 downto NOCEM_AW/2)- local_addr_x) sll 1) then				
								dest_local_port(I) <= ARB_EAST;	
							else
								dest_local_port(I) <= ARB_WEST;
							end if;
							
					end if;	
						
					-- src > dst address. go north if ROWS >= 2(SRC-DST) . go south if ROWS < 2(SRC-DST)  
					if dest_addr_array(I)(NOCEM_AW/2 -1 downto 0) < local_addr_y  and 
						dest_addr_array(I)(NOCEM_AW-1 downto NOCEM_AW/2) = local_addr_x then

							if NOCEM_NUM_ROWS >= TO_STDLOGICVECTOR(TO_BITVECTOR(local_addr_y - dest_addr_array(I)(NOCEM_AW/2 -1 downto 0)) sll 1) then				
								dest_local_port(I) <= ARB_NORTH;	
							else
								dest_local_port(I) <= ARB_SOUTH;
							end if;						
					end if;
			
					if dest_addr_array(I)(NOCEM_AW/2 -1 downto 0) > local_addr_y and 
						dest_addr_array(I)(NOCEM_AW-1 downto NOCEM_AW/2) = local_addr_x then

							-- dst > src address. go north if ROWS >= 2(DST-SRC) . go south if ROWS < 2(DST-SRC) 
							if NOCEM_NUM_ROWS >= TO_STDLOGICVECTOR(TO_BITVECTOR(dest_addr_array(I)(NOCEM_AW/2 -1 downto 0) - local_addr_y) sll 1) then				
								dest_local_port(I) <= ARB_NORTH;	
							else
								dest_local_port(I) <= ARB_SOUTH;
							end if;
					end if;			
			
					if dest_addr_array(I)(NOCEM_AW/2 -1 downto 0) = local_addr_y and 
						dest_addr_array(I)(NOCEM_AW-1 downto NOCEM_AW/2) = local_addr_x then			
			
							dest_local_port(I) <= ARB_AP;				
					end if;
		
				else
					dest_local_port(I) <= ARB_NODECISION;
							
				end if;
				
			end loop;

		end if;

		-- TORUS: north/south have loop around, east/west do not....
		if NOCEM_TOPOLOGY_TYPE = NOCEM_TOPOLOGY_TORUS then 
			l21 : for I in 4 downto 0 loop 
				dest_local_port(I) <= ARB_NODECISION;

				if datain_valid_array(I) = '1' then
			
					if dest_addr_array(I)(NOCEM_AW-1 downto NOCEM_AW/2) < local_addr_x then
						dest_local_port(I) <= ARB_WEST;
					end if;
			
					if dest_addr_array(I)(NOCEM_AW-1 downto NOCEM_AW/2) > local_addr_x then
						dest_local_port(I) <= ARB_EAST;
					end if;	
						
					-- src > dst address. go north if ROWS >= 2(SRC-DST) . go south if ROWS < 2(SRC-DST)  
					if dest_addr_array(I)(NOCEM_AW/2 -1 downto 0) < local_addr_y  and 
						dest_addr_array(I)(NOCEM_AW-1 downto NOCEM_AW/2) = local_addr_x then

							if NOCEM_NUM_ROWS >= TO_STDLOGICVECTOR(TO_BITVECTOR(local_addr_y - dest_addr_array(I)(NOCEM_AW/2 -1 downto 0)) sll 1) then				
								dest_local_port(I) <= ARB_NORTH;	
							else
								dest_local_port(I) <= ARB_SOUTH;
							end if;						
					end if;
			
					if dest_addr_array(I)(NOCEM_AW/2 -1 downto 0) > local_addr_y and 
						dest_addr_array(I)(NOCEM_AW-1 downto NOCEM_AW/2) = local_addr_x then

							-- dst > src address. go north if ROWS >= 2(DST-SRC) . go south if ROWS < 2(DST-SRC) 
							if NOCEM_NUM_ROWS >= TO_STDLOGICVECTOR(TO_BITVECTOR(dest_addr_array(I)(NOCEM_AW/2 -1 downto 0) - local_addr_y) sll 1) then				
								dest_local_port(I) <= ARB_NORTH;	
							else
								dest_local_port(I) <= ARB_SOUTH;
							end if;
					end if;			
			
					if dest_addr_array(I)(NOCEM_AW/2 -1 downto 0) = local_addr_y and 
						dest_addr_array(I)(NOCEM_AW-1 downto NOCEM_AW/2) = local_addr_x then			
			
							dest_local_port(I) <= ARB_AP;				
					end if;
		
				else
					dest_local_port(I) <= ARB_NODECISION;
							
				end if;
				
			end loop;

		end if;



		-- MESH: simple deterministic routing....
		if NOCEM_TOPOLOGY_TYPE = NOCEM_TOPOLOGY_MESH then 
			l22 : for I in 4 downto 0 loop 

				dest_local_port(I) <= ARB_NODECISION;
				if datain_valid_array(I) = '1' then
			
					if dest_addr_array(I)(NOCEM_AW-1 downto NOCEM_AW/2) < local_addr_x then
						dest_local_port(I) <= ARB_WEST;
					end if;
			
					if dest_addr_array(I)(NOCEM_AW-1 downto NOCEM_AW/2) > local_addr_x then
						dest_local_port(I) <= ARB_EAST;
					end if;	
						
					if dest_addr_array(I)(NOCEM_AW/2 -1 downto 0) < local_addr_y  and 
						dest_addr_array(I)(NOCEM_AW-1 downto NOCEM_AW/2) = local_addr_x then

						dest_local_port(I) <= ARB_SOUTH;
					end if;
			
					if dest_addr_array(I)(NOCEM_AW/2 -1 downto 0) > local_addr_y and 
						dest_addr_array(I)(NOCEM_AW-1 downto NOCEM_AW/2) = local_addr_x then

						dest_local_port(I) <= ARB_NORTH;
					end if;			
			
					if dest_addr_array(I)(NOCEM_AW/2 -1 downto 0) = local_addr_y and 
						dest_addr_array(I)(NOCEM_AW-1 downto NOCEM_AW/2) = local_addr_x then			
			
						dest_local_port(I) <= ARB_AP;				
					end if;
		
				else
					dest_local_port(I) <= ARB_NODECISION;
							
				end if;
		
		
			end loop;

		end if;









end process;


arb_gen_process : process (channel_cntrl_in_array_i, dest_local_port)
begin



	arb_grant_output <= (others => ARB_NODECISION);
	channel_cntrl_out_array_i <= (others => (others => '0'));



l3: for I in 4 downto 0 loop

	-- I iterates over the OUTPUT ports
	if channel_cntrl_in_array_i(I)(NOCEM_CHFIFO_DATA_FULL_N_IX) = '1' then
		
		if dest_local_port(NOCEM_AP_IX) = arb_decision_enum(I) then
			--arb grant will push data through switch
			arb_grant_output(I) <= ARB_AP;

			-- do read enable for selected incoming data
			channel_cntrl_out_array_i(NOCEM_AP_IX)(NOCEM_CHFIFO_DATA_RE_IX) <= '1';
			channel_cntrl_out_array_i(NOCEM_AP_IX)(NOCEM_CHFIFO_CNTRL_RE_IX) <= '1';

			-- do write enable for outgoing port
		   channel_cntrl_out_array_i(I)(NOCEM_CHFIFO_DATA_WE_IX) <= '1';
		   channel_cntrl_out_array_i(I)(NOCEM_CHFIFO_CNTRL_WE_IX) <= '1';

		elsif dest_local_port(NOCEM_NORTH_IX) = arb_decision_enum(I) then
			arb_grant_output(I) <= ARB_NORTH;
			channel_cntrl_out_array_i(NOCEM_NORTH_IX)(NOCEM_CHFIFO_DATA_RE_IX) <= '1';
			channel_cntrl_out_array_i(NOCEM_NORTH_IX)(NOCEM_CHFIFO_CNTRL_RE_IX) <= '1';
		   channel_cntrl_out_array_i(I)(NOCEM_CHFIFO_DATA_WE_IX) <= '1';
		   channel_cntrl_out_array_i(I)(NOCEM_CHFIFO_CNTRL_WE_IX) <= '1';


		elsif dest_local_port(NOCEM_SOUTH_IX) = arb_decision_enum(I) then
			arb_grant_output(I) <= ARB_SOUTH;
			channel_cntrl_out_array_i(NOCEM_SOUTH_IX)(NOCEM_CHFIFO_DATA_RE_IX) <= '1';
			channel_cntrl_out_array_i(NOCEM_SOUTH_IX)(NOCEM_CHFIFO_CNTRL_RE_IX) <= '1';
		   channel_cntrl_out_array_i(I)(NOCEM_CHFIFO_DATA_WE_IX) <= '1';
		   channel_cntrl_out_array_i(I)(NOCEM_CHFIFO_CNTRL_WE_IX) <= '1';

		elsif dest_local_port(NOCEM_EAST_IX) = arb_decision_enum(I) then
			arb_grant_output(I) <= ARB_EAST;
			channel_cntrl_out_array_i(NOCEM_EAST_IX)(NOCEM_CHFIFO_DATA_RE_IX) <= '1';
			channel_cntrl_out_array_i(NOCEM_EAST_IX)(NOCEM_CHFIFO_CNTRL_RE_IX) <= '1';
		   channel_cntrl_out_array_i(I)(NOCEM_CHFIFO_DATA_WE_IX) <= '1';
		   channel_cntrl_out_array_i(I)(NOCEM_CHFIFO_CNTRL_WE_IX) <= '1';

		elsif dest_local_port(NOCEM_WEST_IX) = arb_decision_enum(I) then
			arb_grant_output(I) <= ARB_WEST;	 			
			channel_cntrl_out_array_i(NOCEM_WEST_IX)(NOCEM_CHFIFO_DATA_RE_IX) <= '1';
			channel_cntrl_out_array_i(NOCEM_WEST_IX)(NOCEM_CHFIFO_CNTRL_RE_IX) <= '1';
		   channel_cntrl_out_array_i(I)(NOCEM_CHFIFO_DATA_WE_IX) <= '1';
		   channel_cntrl_out_array_i(I)(NOCEM_CHFIFO_CNTRL_WE_IX) <= '1';

		end if;
	end if;




end loop;



end process;


end Behavioral;
