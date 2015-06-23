--
--  This file is part of JOP, the Java Optimized Processor
--
--  Copyright (C) 2007,2008, Christof Pitter
--
--  This program is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program.  If not, see <http://www.gnu.org/licenses/>.
--




-- 150407: first working version with records
-- 170407: produce number of registers depending on the cpu_cnt
-- 110507: * arbiter that can be used with prefered number of masters
--				 * full functional arbiter with two masters
--				 * short modelsim test with 3 masters carried out
-- 190607: Problem found: Both CPU1 and CPU2 start to read cache line!!!
-- 030707: Several bugs are fixed now. CMP with 3 running masters functions!
-- 261107: Fixed Priority Interruptive Arbiter


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.sc_pack.all;
use work.sc_arbiter_pack.all;

entity arbiter is
generic(
			addr_bits : integer;
			cpu_cnt	: integer);		-- number of masters for the arbiter
port (
			clk, reset	: in std_logic;			
			arb_out			: in arb_out_type(0 to cpu_cnt-1);
			arb_in			: out arb_in_type(0 to cpu_cnt-1);
			mem_out			: out sc_out_type;
			mem_in			: in sc_in_type
);
end arbiter;


architecture rtl of arbiter is

-- signals for the input register of each master

	type reg_type is record
		rd : std_logic;
		wr : std_logic;
		wr_data : std_logic_vector(31 downto 0);
		address : std_logic_vector(addr_bits-1 downto 0);
	end record; 
	
	type reg_array_type is array (0 to cpu_cnt-1) of reg_type;
	signal reg_in : reg_array_type;

-- one fsm for each CPU

	type state_type is (idle, read, write, waitingR, sendR, 
	waitingW, sendW, pipeBlocked);
	type state_array is array (0 to cpu_cnt-1) of state_type;
	signal state : state_array;
	signal next_state : state_array;
	
-- one fsm for each serve

	type serve_type is (idl, serv);
	type serve_array is array (0 to cpu_cnt-1) of serve_type;
	signal this_state : serve_array;
	signal follow_state : serve_array;
	
-- arbiter
	
	type set_type is array (0 to cpu_cnt-1) of std_logic;
	signal set : set_type;
	signal waiting : set_type;
	signal masterWaiting : std_logic;
	
	
begin


-- Generates the input register and saves incoming data for each master
gen_register: for i in 0 to cpu_cnt-1 generate
	process(clk, reset)
	begin
		if reset = '1' then
			reg_in(i).rd <= '0';
			reg_in(i).wr <= '0';
			reg_in(i).wr_data <= (others => '0'); 
			reg_in(i).address <= (others => '0');
		elsif rising_edge(clk) then
			if arb_out(i).rd = '1' or arb_out(i).wr = '1' then
		  	reg_in(i).rd <= arb_out(i).rd;
				reg_in(i).wr <= arb_out(i).wr;
				reg_in(i).address <= arb_out(i).address;
				reg_in(i).wr_data <= arb_out(i).wr_data;
			end if;
		end if;
	end process;
end generate;

-- Register for masterWaiting
process(clk, reset)
	begin
		if reset = '1' then
			masterWaiting <= '0';
		elsif rising_edge(clk) then
			for i in 0 to cpu_cnt-1 loop
				if waiting(i) = '1' then
					masterWaiting <= '1';
					exit;
				else
					masterWaiting <= '0';
				end if;
			end loop;
		end if;
	end process;
	
-- Generates next state of the FSM for each master
gen_next_state: for i in 0 to cpu_cnt-1 generate
	process(reset, state, arb_out, mem_in, this_state, reg_in, masterWaiting)	 
	begin

		next_state(i) <= state(i);
		waiting(i) <= '0';

		case state(i) is
			when idle =>
			
				-- checks if this CPU is on turn (pipelined access)
				if this_state(i) = serv then
						 	
					if mem_in.rdy_cnt = 1 and arb_out(i).rd = '1' then
						-- check if higher priority CPU wants to access and blocks pipelined access
						next_state(i) <= read;
						
						if arb_out(i).atomic = '1' then
							for j in 0 to cpu_cnt-1 loop
								if arb_out(j).rd = '1' or arb_out(j).wr = '1' then
									if j<i then
										next_state(i) <= pipeBlocked;
										--wait_cycles <= 1;
										exit;
									end if;
								end if;
						 	end loop;
						end if;					
						
					elsif (mem_in.rdy_cnt = 0 and (arb_out(i).rd = '1' or arb_out(i).wr = '1')) then
						
						-- check if some master is waiting
						if masterWaiting = '1' then
							if arb_out(i).rd = '1' then
								next_state(i) <= waitingR;
								waiting(i) <= '1';
							elsif arb_out(i).wr = '1' then
								next_state(i) <= waitingW;
								waiting(i) <= '1';
							end if;
								
						-- check if parallel access		
						else
							for j in 0 to cpu_cnt-1 loop
								if arb_out(j).rd = '1' or arb_out(j).wr = '1' then
									if i<=j then
										if arb_out(i).rd = '1' then
											next_state(i) <= read;
											exit;
										elsif arb_out(i).wr = '1' then
											next_state(i) <= write;				
											exit;
										end if;
									else
										if arb_out(i).rd = '1' then
											next_state(i) <= waitingR;
											waiting(i) <= '1';
											exit;
										elsif arb_out(i).wr = '1' then
											next_state(i) <= waitingW;
											waiting(i) <= '1';
											exit;
										end if;
									end if;
								end if;
							end loop;
						end if;
							
					-- all other kinds of rdy_cnt
					else
						if arb_out(i).rd = '1' then
							next_state(i) <= waitingR;
							waiting(i) <= '1';
						elsif arb_out(i).wr = '1' then
							next_state(i) <= waitingW;
							waiting(i) <= '1';
						end if;
					end if;

				-- CPU is not already pipelined accessing the memory
				else
					if (mem_in.rdy_cnt = 0 and (arb_out(i).rd = '1' or arb_out(i).wr = '1')) then
						-- check if some master is waiting
						if masterWaiting = '1' then
							if arb_out(i).rd = '1' then
								next_state(i) <= waitingR;
								waiting(i) <= '1';
							elsif arb_out(i).wr = '1' then
								next_state(i) <= waitingW;
								waiting(i) <= '1';
							end if;
								
						-- check if another CPU wants to access in parallel
						else
							for j in 0 to cpu_cnt-1 loop
								if arb_out(j).rd = '1' or arb_out(j).wr = '1' then
									if i<=j then
										if arb_out(i).rd = '1' then
											next_state(i) <= read;
											exit;
										elsif arb_out(i).wr = '1' then
											next_state(i) <= write;				
											exit;
										end if;
									else
										if arb_out(i).rd = '1' then
											next_state(i) <= waitingR;
											waiting(i) <= '1';
											exit;
										elsif arb_out(i).wr = '1' then
											next_state(i) <= waitingW;
											waiting(i) <= '1';
											exit;
										end if;
									end if;
								-- ** cannot ever happen!!!!!!! **
								-- if no parallel access, master can access
								--else
								--	if arb_out(i).rd = '1' then
								--		next_state(i) <= read;
								--	elsif arb_out(i).wr = '1' then
								--		next_state(i) <= write;	
								--	end if;
								end if;
							end loop;
						end if;
					
					-- rdy_cnt != 0	
					else
						if arb_out(i).rd = '1' then
							next_state(i) <= waitingR;
							waiting(i) <= '1';
						elsif arb_out(i).wr = '1' then
							next_state(i) <= waitingW;
							waiting(i) <= '1';
						end if;	
					end if;
				end if;
						
				
			when read =>
				next_state(i) <= idle;
					
				-- pipelined gets blocked
				if mem_in.rdy_cnt = 2 and arb_out(i).atomic = '1' then
					 for j in 0 to cpu_cnt-1 loop
							if arb_out(j).rd = '1' or arb_out(j).wr = '1' then
								if j<i then
									next_state(i) <= pipeBlocked;
									--wait_cycles <= 3;
									exit;	
								end if;
							end if;
					 end loop;
				end if;	
				
			when write =>
				next_state(i) <= idle;
			
			when waitingR =>				
				if mem_in.rdy_cnt = 0 then				
				-- checks which CPU in waitingR has highest priority
					for j in 0 to cpu_cnt-1 loop
						if (state(j) = waitingR) or (state(j) = waitingW) then
							if j<i then
								next_state(i) <= waitingR;
								waiting(i) <= '1';
								exit;
							else
								next_state(i) <= sendR;
								exit;
							end if;
						else
							next_state(i) <= sendR;
						end if;
					end loop;
				else
					next_state(i) <= waitingR;
					waiting(i) <= '1';
				end if;
			
			when sendR =>
				next_state(i) <= idle;
				
			when waitingW =>

				if mem_in.rdy_cnt = 0 then 
					for j in 0 to cpu_cnt-1 loop
						if (state(j) = waitingR) or (state(j) = waitingW) then
							if j<i then
								next_state(i) <= waitingW;
								waiting(i) <= '1';
								exit;
							else
								next_state(i) <= sendW;
								exit;
							end if;
						else
							next_state(i) <= sendW;
						end if;
					end loop;
				else
					next_state(i) <= waitingW;
					waiting(i) <= '1';
				end if;
			
			when sendW =>
				next_state(i) <= idle;
					
			when pipeBlocked =>
				if mem_in.rdy_cnt = 0 then -- to be in serv Mode until request done
					next_state(i) <= waitingR; --no waitingW possible because we don't use pipelined write!!!!!
				else
					next_state(i) <= pipeBlocked;
				end if;
		
		end case;
	end process;
end generate;


-- Generates the FSM state for each master
gen_state: for i in 0 to cpu_cnt-1 generate
	process (clk, reset)
	begin
		if (reset = '1') then
			state(i) <= idle;
  	elsif (rising_edge(clk)) then
			state(i) <= next_state(i);	
		end if;
	end process;
end generate;


-- The arbiter output
process (arb_out, reg_in, next_state)
begin

	mem_out.rd <= '0';
	mem_out.wr <= '0';
	mem_out.address <= (others => '0');
	mem_out.wr_data <= (others => '0');
	mem_out.atomic <= '0';
	
	for i in 0 to cpu_cnt-1 loop
		set(i) <= '0';
		
		case next_state(i) is
			when idle =>
				
			when read =>
				set(i) <= '1';
				mem_out.rd <= arb_out(i).rd;
				mem_out.address <= arb_out(i).address;
			
			when write =>
				set(i) <= '1';
				mem_out.wr <= arb_out(i).wr;
				mem_out.address <= arb_out(i).address;
				mem_out.wr_data <= arb_out(i).wr_data;			
			
			when waitingR =>
				
			when sendR =>
				set(i) <= '1';
				mem_out.rd <= reg_in(i).rd;
				mem_out.address <= reg_in(i).address;
			
			when waitingW =>
			
			when sendW =>
				set(i) <= '1';
				mem_out.wr <= reg_in(i).wr;
				mem_out.address <= reg_in(i).address;
				mem_out.wr_data <= reg_in(i).wr_data;
					
			when pipeBlocked =>
				set(i) <= '1';
				
		end case;
	end loop;
end process;

-- generation of follow_state
gen_serve: for i in 0 to cpu_cnt-1 generate
	process(mem_in, set, this_state)
	begin
		case this_state(i) is
			when idl =>
				follow_state(i) <= idl;
				if set(i) = '1' then 
					follow_state(i) <= serv;
				end if;
			when serv =>
				follow_state(i) <= serv;
				if mem_in.rdy_cnt = 0 and set(i) = '0' then
					follow_state(i) <= idl;
				end if;
		end case;
	end process;
end generate;
	
gen_serve2: for i in 0 to cpu_cnt-1 generate
	process (clk, reset)
	begin
		if (reset = '1') then
			this_state(i) <= idl;
  	elsif (rising_edge(clk)) then
			this_state(i) <= follow_state(i);	
		end if;
	end process;
end generate;
				 
gen_rdy_cnt: for i in 0 to cpu_cnt-1 generate
	process (mem_in, state, this_state)
	begin  
		arb_in(i).rdy_cnt <= mem_in.rdy_cnt;
		arb_in(i).rd_data <= mem_in.rd_data;
		
		case state(i) is
			when idle =>
				case this_state(i) is
					when idl =>
						arb_in(i).rdy_cnt <= "00";
					when serv =>
				end case;
				
			when read =>
			
			when write =>		
			
			when waitingR =>
				arb_in(i).rdy_cnt <= "11";
				
			when sendR =>
			
			when waitingW =>
				arb_in(i).rdy_cnt <= "11";
			
			when sendW =>
				
			when pipeBlocked =>
				arb_in(i).rdy_cnt <= "11";
				
		end case;
	end process;
end generate;

end rtl;
