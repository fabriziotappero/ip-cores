/*
	This file is part of the Memories project:
		http://www.opencores.org/project,wb_fifo
		
	Description
	Implementation of FIFO transactor data structures and high-level API.
	
	To Do: 
	
	Author(s): 
	- Daniel C.K. Kho, daniel.kho@opencores.org | daniel.kho@tauhop.com
	
	Copyright (C) 2012-2013 Authors and OPENCORES.ORG
	
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
/* FIXME VHDL-2008 instantiated package. Unsupported by VCS-MX, Quartus, and Vivado. QuestaSim/ModelSim supports well. */
library ieee; use ieee.std_logic_1164.all, ieee.numeric_std.all;
--use std.textio.all;
library tauhop; --use tauhop.transactor.all;

package fifoTLM is
	generic(
		package i_transactor is new tauhop.tlm generic map(<>)
	);
	/* Makes i_transactor.t_addr, i_transactor.t_msg, and i_transactor.t_cnt visible. */
	use i_transactor.all;
	
	/* FIFO Transactor block interface. */
	type t_fifoTransactor is record
		writeRequest,readRequest:t_bfm;
		writeResponse,readResponse:t_bfm;
	end record t_fifoTransactor;
	
	/* Use separate record for FIFO signalling.
		This will make it easier when we need to split up the request and response 
		structures into separate records (for different directions).
	*/
	type t_fifo is record
		pctFilled:unsigned(7 downto 0);
		nearFull,full:boolean;
		nearEmpty,empty:boolean;
		overflow,underflow:boolean;
	end record t_fifo;
end package fifoTLM;

package body fifoTLM is
end package body fifoTLM;


/* FIFO Transactor API.
 * 	Generally, transactors are high-level bus interface models that perform 
 * 		read/write transactions to/from the bus. These models are not concerned 
 * 		with the low-level implementation of the bus protocol. However, the 
 * 		TLM models encapsulate the lower-level models known as the BFM.
 * 	fifoTLM uses generic package tauhop.tlm, hence inherits basic TLM types and 
 * 		procedures generally used in any messaging system (i.e. address and message 
 * 		information, and bus read/write methods). It also extends the tauhop.tlm 
 * 		package with application-specific types, such as record structures specific
 * 		to the AXI protocol.
 * 	fifoTransactor instantiates the fifoTLM, and assigns specific types to the 
 * 		transactor model.
 */
library ieee; use ieee.std_logic_1164.all, ieee.numeric_std.all;
library tauhop;
package transactor is new tauhop.tlm generic map(
	t_addr=>unsigned(31 downto 0),		-- default assignment. Used only for non-stream interfaces.
	t_msg=>unsigned(63 downto 0),
	t_cnt=>unsigned(127 downto 0)
);

library ieee; use ieee.std_logic_1164.all, ieee.numeric_std.all;
library tauhop; use tauhop.transactor.all;
package fifoTransactor is new tauhop.fifoTLM generic map(
	--t_data=>unsigned(31 downto 0),
	i_transactor=>tauhop.transactor
);
