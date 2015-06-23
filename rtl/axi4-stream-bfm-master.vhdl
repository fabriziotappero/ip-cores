/*
	This file is part of the AXI4 Transactor and Bus Functional Model 
	(axi4_tlm_bfm) project:
		http://www.opencores.org/project,axi4_tlm_bfm

	Description
	Implementation of AXI4 Master BFM core according to AXI4 protocol 
	specification document.
	
	To Do: Implement AXI4-Lite and full AXI4 protocols.
	
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
library ieee; use ieee.std_logic_1164.all, ieee.numeric_std.all;
library tauhop; use tauhop.axiTransactor.all;

--/* TODO remove once generic packages are supported. */
--library tauhop; use tauhop.tlm.all, tauhop.axiTLM.all;

entity axiBfmMaster is
	port(aclk,n_areset:in std_ulogic;
		/* BFM signalling. */
		readRequest,writeRequest:in i_transactor.t_bfm:=(address=>(others=>'X'), message=>(others=>'X'), trigger=>false);
		readResponse,writeResponse:buffer i_transactor.t_bfm;									-- use buffer until synthesis tools support reading from out ports.
		
		/* AXI Master interface */
		axiMaster_in:in t_axi4StreamTransactor_s2m;
		axiMaster_out:buffer t_axi4StreamTransactor_m2s;
		
--		/* AXI Slave interface */
--		axiSlave_in:in tAxi4Transactor_m2s;
--		axiSlave_out:buffer tAxi4Transactor_s2m;
		
		lastTransaction:in boolean;
		
		/* Debug ports. */
--		dbg_cnt:out unsigned(9 downto 0);
--		dbg_axiRxFsm:out axiBfmStatesRx:=idle;
		dbg_axiTxFsm:out axiBfmStatesTx:=idle
	);
end entity axiBfmMaster;

architecture rtl of axiBfmMaster is
	/* Finite-state Machines. */
	signal axiTxState,next_axiTxState:axiBfmStatesTx:=idle;
	
	signal i_axiMaster_out:t_axi4StreamTransactor_m2s;
	signal i_trigger,trigger:boolean;
	
	/* BFM signalling. */
	signal i_writeRequest:i_transactor.t_bfm:=(address=>(others=>'X'),message=>(others=>'X'),trigger=>false);
	signal i_writeResponse:i_transactor.t_bfm;
	
begin
	i_trigger<=writeRequest.trigger xor i_writeRequest.trigger;
	
	/* next-state logic for AXI4-Stream Master Tx BFM. */
	axi_bfmTx_ns: process(all) is begin
		axiTxState<=next_axiTxState;
		
		if not n_areset then axiTxState<=idle;
		else
			case next_axiTxState is
				when idle=>
					if i_trigger then axiTxState<=payload; end if;
				when payload=>
					if lastTransaction then axiTxState<=endOfTx; end if;
				when endOfTx=>
					if axiMaster_in.tReady then axiTxState<=idle; end if;
				when others=>axiTxState<=idle;
			end case;
		end if;
	end process axi_bfmTx_ns;
	
	/* output logic for AXI4-Stream Master Tx BFM. */
	axi_bfmTx_op: process(all) is begin
		i_writeResponse<=writeResponse;
		
		i_axiMaster_out<=axiMaster_out;
		i_axiMaster_out.tLast<=false;
		i_writeResponse.trigger<=false;
		
		case next_axiTxState is
			when idle=>
				i_axiMaster_out.tValid<=false;
				i_axiMaster_out.tData<=(others=>'Z');
				
				if i_trigger then
					i_axiMaster_out.tData<=writeRequest.message;
					i_axiMaster_out.tValid<=true;
				end if;
			when payload | endOfTx =>
				if i_trigger then
					i_axiMaster_out.tData<=writeRequest.message;
					i_axiMaster_out.tValid<=true;
				end if;
				
				if axiMaster_in.tReady then
					i_writeResponse.trigger<=true;
				end if;
				
				if lastTransaction then i_axiMaster_out.tLast<=true; end if;
			when others=> null;
		end case;
	end process axi_bfmTx_op;
	
	/* state registers and pipelines for AXI4-Stream Tx BFM. */
	process(aclk) is begin
		if rising_edge(aclk) or falling_edge(aclk) then
			next_axiTxState<=axiTxState;
			i_writeRequest<=writeRequest;
			writeResponse<=i_writeResponse;
			axiMaster_out<=i_axiMaster_out;
			trigger<=i_trigger;
		end if;
	end process;
	
	/*
	fastPipelines: entity work.ddr(rtl) generic map(busWidth=>8)
		port map(reset=>reset,
			clk=>aclk,
			d=>next_axiTxState,
			q=>axiTxState
		);
	*/
	
	dbg_axiTxFSM<=axiTxState;
end architecture rtl;
