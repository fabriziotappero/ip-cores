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
--library tauhop; use tauhop.axiTransactor.all;

/* TODO remove once generic packages are supported. */
library tauhop; use tauhop.fsm.all, tauhop.tlm.all, tauhop.axiTLM.all;

entity axiBfmMaster is
	port(aclk,n_areset:in std_ulogic;
		/* BFM signalling. */
		readRequest,writeRequest:in t_bfm:=(address=>(others=>'X'), message=>(others=>'X'), trigger=>false);
		readResponse,writeResponse:buffer t_bfm;									-- use buffer until synthesis tools support reading from out ports.
		
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
--	signal i_readRequest,i_writeRequest:t_bfm:=(address=>(others=>'X'),message=>(others=>'X'),trigger=>false);
--	signal i_readResponse,i_writeResponse:t_bfm;
	signal i_writeRequest:t_bfm:=(address=>(others=>'X'),message=>(others=>'X'),trigger=>false);
	signal i_writeResponse:t_bfm;
	
	/* DDR Pipelines. */
	signal next_axiTxState_rise,next_axiTxState_fall:axiBfmStatesTx;
	signal i_writeRequest_rise,i_writeRequest_fall:t_bfm;
	signal writeResponse_rise,writeResponse_fall:t_bfm;
	signal axiMaster_out_rise,axiMaster_out_fall:t_axi4StreamTransactor_m2s;
	signal trigger_rise,trigger_fall:boolean;
	
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
		if not n_areset then
			next_axiTxState<=idle;
			i_writeRequest<=(address=>(others=>'0'),message=>(others=>'0'),trigger=>false);
			writeResponse<=(address=>(others=>'0'),message=>(others=>'0'),trigger=>false);
			--axiMaster_out<=(others=>'0');
			trigger<=false;
--		elsif rising_edge(aclk) then
--			next_axiTxState<=axiTxState;
--			i_writeRequest<=writeRequest;
--			writeResponse<=i_writeResponse;
--			axiMaster_out<=i_axiMaster_out;
--			trigger<=i_trigger;
		elsif falling_edge(aclk) then
			next_axiTxState<=axiTxState;
			i_writeRequest<=writeRequest;
			writeResponse<=i_writeResponse;
			axiMaster_out<=i_axiMaster_out;
			trigger<=i_trigger;
		end if;
	end process;
	
	/*
	process(n_areset,aclk) is begin
		if not n_areset then
			next_axiTxState_rise<=idle;
		elsif rising_edge(aclk) then
			next_axiTxState_rise<=axiTxState;
			i_writeRequest_rise<=writeRequest;
			writeResponse_rise<=i_writeResponse;
			axiMaster_out_rise<=i_axiMaster_out;
			trigger_rise<=i_trigger;
		end if;
	end process;
	
	process(n_areset,aclk) is begin
		if not n_areset then
			next_axiTxState_fall<=idle;
		elsif falling_edge(aclk) then
			next_axiTxState_fall<=axiTxState;
			i_writeRequest_fall<=writeRequest;
			writeResponse_fall<=i_writeResponse;
			axiMaster_out_fall<=i_axiMaster_out;
			trigger_fall<=i_trigger;
		end if;
	end process;
	
	next_axiTxState<=idle when not n_areset else next_axiTxState_rise xor next_axiTxState_fall;
	*/
	
--	pseudo dual-edge-triggered D-Flip-Flop (Refer Ralf Hildebrant's paper: http://www.ralf-hildebrandt.de/publication/pdf_dff/pde_dff.pdf).
	/*
	process(async_clr,clk)
	begin
		if impl_rp=0 and async_clr='0' then ff_rise<='0';
		elsif impl_rp=1 and async_clr='0' then ff_rise<='1';
		elsif rising_edge(clk) then
			if d='1' then ff_rise<=not ff_fall;
			else ff_rise<=ff_fall;
			end if;
		end if;
	end process;
	
	process(async_clr,clk)
	begin
		if impl_rp=0 and async_clr='0' then ff_fall<='0';
		elsif impl_rp=1 and async_clr='0' then ff_fall<='1';
		elsif falling_edge(clk) then
			if d='1' then ff_fall<=not ff_rise;
			else ff_fall<=ff_rise;
			end if;
		end if;
	end process;
	
	q<='0' when impl_rp=0 and async_clr='0' else
		'1' when impl_rp=1 and async_clr='0' else
		ff_rise xor ff_fall;
	*/
-- end pseudo dual-edge-triggered DFF
	
/*	
--	process(n_areset,aclk) is
	process(aclk) is
--		variable q1,q2:std_ulogic_vector(q'length-1 downto 0);
		variable q_a1,q_a2:axiBfmStatesTx;		--std_ulogic_vector(axiTxState'range);
		variable q_b1,q_b2:t_bfm;				--std_ulogic_vector(writeRequest'range);
		variable q_c1,q_c2:t_bfm;
		variable q_d1,q_d2:t_axi4StreamTransactor_m2s;
		variable q_e1,q_e2:boolean;
	begin
--		if not n_areset then
--			q_a1:=idle; q_a2:=idle;
--			q_b1:=(others=>'0'); q_b2:=(others=>'0');
--			q_c1:=(others=>'0'); q_c2:=(others=>'0');
--			q_d1:=(others=>'0'); q_d2:=(others=>'0');
--			q_e1:=(others=>'0'); q_e2:=(others=>'0');
		if rising_edge(aclk) then
			q_a1:=axiTxState xor q_a2;
			q_b1:=writeRequest xor q_b2;
			q_c1:=i_writeResponse xor q_c2;
			q_d1:=i_axiMaster_out xor q_d2;
			q_e1:=i_trigger xor q_e2;
		elsif falling_edge(aclk) then
			q_a2:=axiTxState xor q_a1;
			q_b2:=writeRequest xor q_b1;
			q_c2:=i_writeResponse xor q_c1;
			q_d2:=i_axiMaster_out xor q_d1;
			q_e2:=i_trigger xor q_e1;
		end if;
		
		next_axiTxState<=q_a1 xor q_a2;
		i_writeRequest<=q_b1 xor q_b2;
		writeResponse<=q_c1 xor q_c2;
		axiMaster_out<=q_d1 xor q_d2;
		trigger<=q_e1 xor q_e2;
	end process;
*/	
	
	dbg_axiTxFSM<=axiTxState;
end architecture rtl;
