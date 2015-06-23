/*
	This file is part of the AXI4 Transactor and Bus Functional Model 
	(axi4_tlm_bfm) project:
		http://www.opencores.org/project,axi4_tlm_bfm

	Description
	Synthesisable use case for AXI4 on-chip messaging.
	
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
library ieee; use ieee.std_logic_1164.all, ieee.numeric_std.all, ieee.math_real.all;
--library tauhop; use tauhop.transactor.all, tauhop.axiTransactor.all;		--TODO just use axiTransactor here as transactor should already be wrapped up.

/* TODO remove once generic packages are supported. */
library tauhop; use tauhop.tlm.all, tauhop.axiTLM.all;

/* synthesis translate_off */
library osvvm; use osvvm.RandomPkg.all, osvvm.CoveragePkg.all;
/* synthesis translate_on */

library altera; use altera.stp;


entity tester is port(
	/* Comment-out for simulation. */
	clk,reset:in std_ulogic;
	
	/* AXI Master interface */
	axiMaster_in:buffer t_axi4StreamTransactor_s2m;
	axiMaster_out:in t_axi4StreamTransactor_m2s;
	
	/* BFM signalling. */
--	readRequest,writeRequest:t_bfm:=(address=>(others=>'X'),message=>(others=>'X'),trigger=>false);
--	readResponse,writeResponse:t_bfm;
	readRequest,writeRequest:buffer t_bfm;
	readResponse,writeResponse:in t_bfm;
	
	irq_write:buffer std_ulogic;		-- clock gating.
	
	lastTransaction:buffer boolean;
	
	/* Debug ports. */
--	dataIn:in t_msg;
	selTxn:in unsigned(3 downto 0)
);
end entity tester;
