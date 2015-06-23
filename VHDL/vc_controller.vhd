
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
-- Filename: vc_controller.vhd
-- 
-- Description: vc controller -- state, allocation status, etc.
-- 


--The VC controller is instantiated on a per VC basis and keeps track 
--of the state of the VC and outputs the appropriate signals to the node 
--that is switching this data and the node that originally provided the data.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.pkg_nocem.all;

entity vc_controller is
    Port ( 

		-- id's for this vc and its node (for routing)
		vc_my_id : in std_logic_vector(NOCEM_VC_ID_WIDTH-1 downto 0); -- should be tied to constant
		node_my_id : in std_logic_vector(NOCEM_AW-1 downto 0);

		-- packet fields from/to FIFO that are being snooped 
		pkt_cntrl_rd : in pkt_cntrl_word;
		pkt_cntrl_wr : in pkt_cntrl_word;
		pkt_re : in std_logic;
		pkt_we : in std_logic;
		vc_fifo_empty : in std_logic;

		-- this VC's status
		vc_eop_rd_status : out std_logic;		  -- 0: no eop with rden, 1: eop and rden
 		vc_eop_wr_status  : out std_logic;		  -- 0: no eop with wren, 1: eop and wren


		-- requesting a outgoing VC
		vc_allocation_req : out std_logic;
		vc_req_id : out std_logic_vector(NOCEM_VC_ID_WIDTH-1 downto 0);

		-- virtual channel request RESPONSE SIGNALS
		vc_allocate_from_node : in std_logic_vector(NOCEM_VC_ID_WIDTH-1 downto 0);
		vc_requester_from_node : in std_logic_vector(NOCEM_VC_ID_WIDTH-1 downto 0);

		-- destination signals (channel,VC) for packet transmission
		channel_dest : out arb_decision;
		vc_dest : out std_logic_vector(NOCEM_VC_ID_WIDTH-1 downto 0);
		vc_switch_req : out std_logic;
	
		rst : in std_logic;
	 	clk : in std_logic
	 );
end vc_controller;

architecture Behavioral of vc_controller is

--STATE MACHINE SUMMARY --
--
--will see the SOP and then attempt to get a virtual channel on 
--the outgoing physical CHANNEL.  Once we have a vc, we can start 
--to send the packet, waiting for a EOP to show up/be read out.  Once we do, 
--will signal back to previous router that channel is now deallocated.
--

  type stateType is (idle_st,getting_vc_st,sending_st);
  signal state,nextState : stateType;

	signal local_addr_x : std_logic_vector(NOCEM_AW/2 -1 downto 0);
	signal local_addr_y : std_logic_vector(NOCEM_AW/2 -1 downto 0);

	signal channel_dest_routed,channel_dest_reg  : arb_decision;

	signal final_dest_addr : std_logic_vector(NOCEM_AW-1 downto 0);

	signal vc_allocated_reg : std_logic_vector(NOCEM_VC_ID_WIDTH-1 downto 0);
	signal sop_wr : std_logic;
	signal eop_rd,eop_wr : std_logic;

   -- register the incoming cntrl_wr signal for performance reasons (higher clock speed)
	signal pkt_cntrl_wr_1stword : pkt_cntrl_word;


begin

	-- setup signals coming/going to FIFO
	sop_wr  <= pkt_cntrl_wr(NOCEM_PKTCNTRL_SOP_IX) when pkt_we = '1' else '0';
	eop_wr  <= pkt_cntrl_wr(NOCEM_PKTCNTRL_EOP_IX) when pkt_we = '1' else '0';
	eop_rd  <= pkt_cntrl_rd(NOCEM_PKTCNTRL_EOP_IX) when pkt_re = '1' else '0';


	vc_eop_rd_status <= eop_rd;		  -- 0: no eop with rden, 1: eop and rden
	vc_eop_wr_status <= eop_wr;


	--local address breakdown for readibility....
	local_addr_x <= node_my_id(NOCEM_AW-1 downto NOCEM_AW/2);
	local_addr_y <= node_my_id(NOCEM_AW/2 -1 downto 0);
	final_dest_addr <= pkt_cntrl_wr_1stword(NOCEM_PKTCNTRL_DEST_ADDR_HIX downto NOCEM_PKTCNTRL_DEST_ADDR_LIX);


	state_clkd : process (clk,rst,nextState)
	begin
		if rst = '1' then
			 state 						<= idle_st;
			 channel_dest_reg 		<= ARB_NODECISION;
			 vc_allocated_reg 		<= (others => '0');
			 pkt_cntrl_wr_1stword 	<= (others => '0');
		elsif clk'event and clk='1' then
			state <= nextState;
	   	case state is
			
				when idle_st =>
					
					vc_allocated_reg 		<= (others => '0');

					if sop_wr='1' then
						pkt_cntrl_wr_1stword <= pkt_cntrl_wr;						
					end if;
				when getting_vc_st =>
					channel_dest_reg <= channel_dest_routed;
					if vc_allocate_from_node /= 0 and vc_requester_from_node = vc_my_id then
						vc_allocated_reg <= vc_allocate_from_node;							
					else
						null;
					end if;
				when sending_st =>
				when others =>
					null;
			
			
			end case;
		end if;
	end process;		



	state_uclkd : process (vc_fifo_empty,eop_rd,state, sop_wr, vc_my_id, channel_dest_routed, vc_requester_from_node, channel_dest_reg, vc_allocate_from_node, pkt_re, eop_wr, vc_allocated_reg)
	begin

			vc_allocation_req	 <= '0';
			vc_switch_req <= '0';
			vc_dest <= (others => '0');
			channel_dest <= ARB_NODECISION;
			vc_req_id	<= (others => '0');


	   	case state is
			
				when idle_st =>
					vc_dest <= (others => '0');
					if sop_wr = '1' then
						nextState <= getting_vc_st;					
					else
						nextState <= idle_st;
					end if;

				when getting_vc_st =>
					
					channel_dest <= channel_dest_routed;
					vc_dest <= vc_allocate_from_node;

					if vc_allocate_from_node /= 0 and vc_requester_from_node = vc_my_id then
						
						-- requesting switch signals
						if vc_fifo_empty='0' then
							vc_switch_req <= '1';														
						end if;						

						-- single word packet handling
						if eop_rd = '1' then
							nextState <= idle_st;
						else
							nextState <= sending_st;
						end if;

								
					else
						
						-- requesting vc signals...
						vc_allocation_req <= '1';
						vc_req_id <= vc_my_id;						

						nextState <= getting_vc_st;
					end if;
		
		
						

				when sending_st =>
						
						channel_dest <= channel_dest_routed;
						vc_dest <= vc_allocated_reg;
						-- requesting switch signals
						if vc_fifo_empty = '0' then
							vc_switch_req <= '1';														
						end if;

						-- waiting for packet to be completed read
						if eop_rd = '1' then
							nextState <= idle_st;
						else
							nextState <= sending_st;
						end if;

				when others =>
					null;
			
			
			end case;
	end process;





-- process to determine routing based on incoming addr 
-- decision determined by topology and datain destination address
	channel_dest_gen : process (pkt_cntrl_wr,final_dest_addr, local_addr_x, local_addr_y)
	begin
	
	


		-- DOUBLE TORUS: north/south have loop around, east/west have looparound....
		if NOCEM_TOPOLOGY_TYPE = NOCEM_TOPOLOGY_DTORUS then 

				channel_dest_routed <= ARB_NODECISION;



					-- src > dst address. go east if ROWS >= 2(SRC-DST) . go west if ROWS < 2(SRC-DST)
					if final_dest_addr(NOCEM_AW-1 downto NOCEM_AW/2) < local_addr_x then							

							if NOCEM_NUM_ROWS >= TO_STDLOGICVECTOR(TO_BITVECTOR(local_addr_x - final_dest_addr(NOCEM_AW-1 downto NOCEM_AW/2)) sll 1) then				
								channel_dest_routed <= ARB_EAST;	
							else
								channel_dest_routed <= ARB_WEST;
							end if;
					end if;
			
					-- dst > src address. go east if ROWS >= 2(DST-SRC) . go west if ROWS < 2(DST-SRC)
					if final_dest_addr(NOCEM_AW-1 downto NOCEM_AW/2) > local_addr_x then
							
							if NOCEM_NUM_ROWS >= TO_STDLOGICVECTOR(TO_BITVECTOR(final_dest_addr(NOCEM_AW-1 downto NOCEM_AW/2)- local_addr_x) sll 1) then				
								channel_dest_routed <= ARB_EAST;	
							else
								channel_dest_routed <= ARB_WEST;
							end if;
							
					end if;	
						
					-- src > dst address. go north if ROWS >= 2(SRC-DST) . go south if ROWS < 2(SRC-DST)  
					if final_dest_addr(NOCEM_AW/2 -1 downto 0) < local_addr_y  and 
						final_dest_addr(NOCEM_AW-1 downto NOCEM_AW/2) = local_addr_x then

							if NOCEM_NUM_ROWS >= TO_STDLOGICVECTOR(TO_BITVECTOR(local_addr_y - final_dest_addr(NOCEM_AW/2 -1 downto 0)) sll 1) then				
								channel_dest_routed <= ARB_NORTH;	
							else
								channel_dest_routed <= ARB_SOUTH;
							end if;						
					end if;
			
					if final_dest_addr(NOCEM_AW/2 -1 downto 0) > local_addr_y and 
						final_dest_addr(NOCEM_AW-1 downto NOCEM_AW/2) = local_addr_x then

							-- dst > src address. go north if ROWS >= 2(DST-SRC) . go south if ROWS < 2(DST-SRC) 
							if NOCEM_NUM_ROWS >= TO_STDLOGICVECTOR(TO_BITVECTOR(final_dest_addr(NOCEM_AW/2 -1 downto 0) - local_addr_y) sll 1) then				
								channel_dest_routed <= ARB_NORTH;	
							else
								channel_dest_routed <= ARB_SOUTH;
							end if;
					end if;			
			
					if final_dest_addr(NOCEM_AW/2 -1 downto 0) = local_addr_y and 
						final_dest_addr(NOCEM_AW-1 downto NOCEM_AW/2) = local_addr_x then			
			
							channel_dest_routed <= ARB_AP;				
					end if;


		end if; -- DTORUS


		-- TORUS: north/south have loop around, east/west do not....
		if NOCEM_TOPOLOGY_TYPE = NOCEM_TOPOLOGY_TORUS then 

				channel_dest_routed <= ARB_NODECISION;

			
					if final_dest_addr(NOCEM_AW-1 downto NOCEM_AW/2) < local_addr_x then
						channel_dest_routed <= ARB_WEST;
					end if;
			
					if final_dest_addr(NOCEM_AW-1 downto NOCEM_AW/2) > local_addr_x then
						channel_dest_routed <= ARB_EAST;
					end if;	
						
					-- src > dst address. go north if ROWS >= 2(SRC-DST) . go south if ROWS < 2(SRC-DST)  
					if final_dest_addr(NOCEM_AW/2 -1 downto 0) < local_addr_y  and 
						final_dest_addr(NOCEM_AW-1 downto NOCEM_AW/2) = local_addr_x then

							if NOCEM_NUM_ROWS >= TO_STDLOGICVECTOR(TO_BITVECTOR(local_addr_y - final_dest_addr(NOCEM_AW/2 -1 downto 0)) sll 1) then				
								channel_dest_routed <= ARB_NORTH;	
							else
								channel_dest_routed <= ARB_SOUTH;
							end if;						
					end if;
			
					if final_dest_addr(NOCEM_AW/2 -1 downto 0) > local_addr_y and 
						final_dest_addr(NOCEM_AW-1 downto NOCEM_AW/2) = local_addr_x then

							-- dst > src address. go north if ROWS >= 2(DST-SRC) . go south if ROWS < 2(DST-SRC) 
							if NOCEM_NUM_ROWS >= TO_STDLOGICVECTOR(TO_BITVECTOR(final_dest_addr(NOCEM_AW/2 -1 downto 0) - local_addr_y) sll 1) then				
								channel_dest_routed <= ARB_NORTH;	
							else
								channel_dest_routed <= ARB_SOUTH;
							end if;
					end if;			
			
					if final_dest_addr(NOCEM_AW/2 -1 downto 0) = local_addr_y and 
						final_dest_addr(NOCEM_AW-1 downto NOCEM_AW/2) = local_addr_x then			
			
							channel_dest_routed <= ARB_AP;				
					end if;


		end if;




		-- MESH: simple deterministic routing....
		if NOCEM_TOPOLOGY_TYPE = NOCEM_TOPOLOGY_MESH then 


				channel_dest_routed <= ARB_NODECISION;

			
					if final_dest_addr(NOCEM_AW-1 downto NOCEM_AW/2) < local_addr_x then
						channel_dest_routed <= ARB_WEST;
					end if;
			
					if final_dest_addr(NOCEM_AW-1 downto NOCEM_AW/2) > local_addr_x then
						channel_dest_routed <= ARB_EAST;
					end if;	
						
					if final_dest_addr(NOCEM_AW/2 -1 downto 0) < local_addr_y  and 
						final_dest_addr(NOCEM_AW-1 downto NOCEM_AW/2) = local_addr_x then

						channel_dest_routed <= ARB_SOUTH;
					end if;
			
					if final_dest_addr(NOCEM_AW/2 -1 downto 0) > local_addr_y and 
						final_dest_addr(NOCEM_AW-1 downto NOCEM_AW/2) = local_addr_x then

						channel_dest_routed <= ARB_NORTH;
					end if;			
			
					if final_dest_addr(NOCEM_AW/2 -1 downto 0) = local_addr_y and 
						final_dest_addr(NOCEM_AW-1 downto NOCEM_AW/2) = local_addr_x then			
			
						channel_dest_routed <= ARB_AP;				
					end if;


		end if;



end process;	
	
	
	
	
	
	 




end Behavioral;
