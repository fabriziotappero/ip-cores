/*
	This file is part of the AXI4 Transactor and Bus Functional Model 
	(axi4_tlm_bfm) project:
		http://www.opencores.org/project,axi4_tlm_bfm

	Description
	This implements a generic interface for transactors, and has a set 
	of reusable procedures to read and write from / to a bus. This 
	interface can be used in many different bus protocols, by means of 
	instantiating this package. An example implementation for the AXI4 
	protocol can be found at 
		pkg-axi-tlm.vhdl
	under the axi4_tlm_bfm project.
	
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

package tlm is
	generic(type t_addr; type t_msg; type t_cnt);
	
--	/* TODO remove once generic packages are supported. */
--	subtype t_addr is unsigned(31 downto 0);
--	subtype t_msg is signed(63 downto 0);
	
	/* BFM control interface. */
	type t_bfm is record
		address:t_addr;
		message:t_msg;
		trigger:boolean;
	end record t_bfm;
	
	procedure write(
		signal request:out t_bfm;		--FIXME use inout because Quartus doesn't yet allow reading of "out" within a procedure. VHDL-2008 allows this, and QuestaSim works fine.
		address:in t_addr;				-- used only for non-stream interfaces.
		data:in t_msg
	);
	
	procedure read(
		signal request:out t_bfm;		--FIXME use inout because Quartus doesn't yet allow reading of "out" within a procedure. VHDL-2008 allows this, and QuestaSim works fine.
		address:in t_addr				-- used only for non-stream interfaces.
	);
end package tlm;

package body tlm is
	procedure write(
		signal request:out t_bfm;		--FIXME use inout because Quartus doesn't yet allow reading of "out" within a procedure. VHDL-2008 allows this, and QuestaSim works fine.
		address:in t_addr;				-- used only for non-stream interfaces.
		data:in t_msg
	) is begin
		request.address<=address;
		request.message<=data;
		request.trigger<=not request.trigger;
	end procedure write;
	
	procedure read(
		signal request:out t_bfm;		--FIXME use inout because Quartus doesn't yet allow reading of "out" within a procedure. VHDL-2008 allows this, and QuestaSim works fine.
		address:in t_addr				-- used only for non-stream interfaces.
	) is begin
		request.address<=address;
		request.trigger<=not request.trigger;
		--report "request.address: " & to_hstring(request.address);
	end procedure read;
end package body tlm;
