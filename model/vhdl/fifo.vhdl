/*
	This file is part of the Memories project:
		http://opencores.org/project,wb_fifo
		
	Description
	FIFO memory model.
	
	To Do: 
	
	Author(s): 
	- Daniel C.K. Kho, daniel.kho@opencores.org | daniel.kho@tauhop.com
	
	Copyright (C) 2012-2013 Authors and OPENCORES.ORG.
	
	This source file may be used and distributed without 
	restriction provided that this copyright statement is not 
	removed from the file and that any derivative work contains 
	the original copyright notice and the associated disclaimer.
	
	This source file is free software; you can redistribute it 
	and/or modify it under the terms of the GNU Lesser General 
	Public License as published by the Free Software Foundation; 
	either version 2.1 of the License, or (at your option) any 
	later version.
	
	This source is distributed in the hope that it will be 
	useful, but WITHOUT ANY WARRANTY; without even the implied 
	warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR 
	PURPOSE. See the GNU Lesser General Public License for more 
	details.
	
	You should have received a copy of the GNU Lesser General 
	Public License along with this source; if not, download it 
	from http://www.opencores.org/lgpl.shtml.
*/
library ieee; use ieee.std_logic_1164.all, ieee.numeric_std.all;
library tauhop;
--package fifoTypes is new tauhop.types generic map(t_data=>unsigned(31 downto 0));
use tauhop.fifoTransactor.all;

--library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;
--library tauhop; use tauhop.fifoTypes.all;
entity fifo is
	generic(memoryDepth:positive);
	port(clk,reset:in std_ulogic;
		fifoInterface:inout t_fifoTransactor
	);
end entity fifo;

architecture rtl of fifo is
	type t_memory is array(memoryDepth-1 downto 0) of i_transactor.t_msg;
	signal memory:t_memory;
	signal ptr:natural range 0 to memoryDepth-1;
	
	/* FIFO control signalling. */
	signal fifoCtrl:t_fifo;
	
	/*
		writeRequest and readRequest are inputs. This indicate that a block is requesting to write to or 
			read from the FIFO.
			For write requests, the external block requests to write some data into the FIFO. The data 
			is attached as part of the write request (writeRequest.message).
			For read requests, the external block requests to read some data from the FIFO. The data will 
			later be attached in the read response (readResponse.message).
			
		There is no such concept as messages attached to a write response (no writeResponse.message) or 
			read request (no readRequest.message).
			
		To generate a write response, the FIFO can assert an acknowledge signal, which could be part of 
			the response (writeResponse.trigger). The acknowledge is generated only when the FIFO is not 
			full. The requester can check this flag so that it will not continue requesting a write when 
			the FIFO is full.
			When generating a read response, the FIFO can assert an acknowledge signal as part of the 
			response (readResponse.trigger), while at the same time, sending data back to the external 
			requester (readResponse.message). The acknowledge signal is generated only when the FIFO is 
			not empty. The requester can check this flag so that it will not continue requesting a read 
			when the FIFO is empty.
	*/
	signal i_writeRequest,i_readRequest:i_transactor.t_bfm;
	signal i_full,i_empty:boolean;
	signal write,read:boolean;
	
	signal writeRequested, readRequested: boolean;
begin
	/* Registers and pipelines. */
	/* TODO recheck pipelining. */
	process(clk) is begin
		if falling_edge(clk) then
			/* TODO add buffers for pipelined request signals,
				i.e., add a flip-flop and a buffer.
			*/
			i_writeRequest <= fifoInterface.writeRequest after 1 ps;
			i_readRequest <= fifoInterface.readRequest after 1 ps;
			
			i_full <= fifoCtrl.full;
			i_empty <= fifoCtrl.empty;
		end if;
	end process;
	
	/* Synchronous FIFO. */
	controller: process(reset,clk) is begin
		--if reset then
		--	fifoInterface.readResponse.message<=(others=>'Z');
		--	fifoInterface.readResponse.trigger<=false;
		if falling_edge(clk) then
			/* Default assignments. */
			fifoInterface.readResponse.trigger<=false;
			fifoInterface.writeResponse.trigger<=false;
			
			/* Write request.
				Safety control: allow writing only when FIFO is not full.
			*/
			--if i_pctFilled<d"100" and (fifoInterface.writeRequest.trigger xor i_writeRequest.trigger) then
			--if not i_full and (fifoInterface.writeRequest.trigger xor i_writeRequest.trigger) then		-- TODO change to write
			if not i_full and write then
				fifoInterface.writeResponse.trigger<=true;
				memory(ptr)<=fifoInterface.writeRequest.message;
			end if;
			
			/* Read request.
				Safety control: allow reading only when FIFO is not empty.
			*/
			--if not i_empty and (fifoInterface.readRequest.trigger xor i_readRequest.trigger) then		-- TODO change to read
			if not i_empty and read then
				fifoInterface.readResponse.trigger<=true;
				fifoInterface.readResponse.message<=memory(ptr);
			end if;
			
			/* Synchronous reset. */
			if reset then
				fifoInterface.readResponse.message<=(others=>'Z');
				fifoInterface.readResponse.trigger<=false;
			end if;
		end if;
	end process controller;
	
	write <= fifoInterface.writeRequest.trigger xor i_writeRequest.trigger;
	read <= fifoInterface.readRequest.trigger xor i_readRequest.trigger;
	
	/* Request indicator. Derived from fifoInterface.writeRequest.trigger 
		and fifoInterface.readRequest.trigger.
		Asserts when there are incoming requests.
	*/
	process(clk) is begin
		if falling_edge(clk) then
			writeRequested <= fifoInterface.writeRequest.trigger xor i_writeRequest.trigger;
			readRequested <= fifoInterface.readRequest.trigger xor i_readRequest.trigger;
		end if;
	end process;
	
	addrPointer: process(reset,clk) is begin
		if reset then ptr<=0;
		elsif falling_edge(clk) then
			/* Increment or decrement the address pointer only when write or read is HIGH;
				do nothing when both are HIGH or when both are LOW.
			*/
			if write xor read then
				if write then
					if ptr<memoryDepth-1 then ptr<=ptr+1; end if;
				end if;
				if read then
					if ptr>0 then ptr<=ptr-1; end if;
				end if;
			end if;
		end if;
	end process addrPointer;
	
	fifoCtrl.pctFilled<=to_unsigned(ptr*100/(memoryDepth-1), fifoCtrl.pctFilled'length);
	
	process(clk) is begin
		if rising_edge(clk) then
			fifoCtrl.nearFull<=true when fifoCtrl.pctFilled>=d"75" and fifoCtrl.pctFilled<d"100" else false;
			fifoCtrl.full<=true when fifoCtrl.pctFilled=d"100" else false;
			fifoCtrl.nearEmpty<=true when fifoCtrl.pctFilled<=d"25" and fifoCtrl.pctFilled>d"0" else false;
			fifoCtrl.empty<=true when fifoCtrl.pctFilled=d"0" else false;
		end if;
	end process;
	
	process(clk) is begin
		if falling_edge(clk) then
			fifoCtrl.overflow<=fifoCtrl.full and write;
			fifoCtrl.underflow<=fifoCtrl.empty and read;
		end if;
	end process;
end architecture rtl;
