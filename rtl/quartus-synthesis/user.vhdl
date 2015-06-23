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
library ieee; use ieee.std_logic_1164.all, ieee.numeric_std.all; use ieee.math_real.all;
--library tauhop; use tauhop.transactor.all, tauhop.axiTransactor.all;		--TODO just use axiTransactor here as transactor should already be wrapped up.

/* TODO remove once generic packages are supported. */
library tauhop; use tauhop.fsm.all, tauhop.tlm.all, tauhop.axiTLM.all;

/* synthesis translate_off */
library osvvm; use osvvm.RandomPkg.all; use osvvm.CoveragePkg.all;
/* synthesis translate_on */

library altera; use altera.stp;


entity user is port(
	/* Comment-out for simulation. */
	clk,nReset:in std_ulogic;
	
	/* AXI Master interface */
--	axiMaster_in:in t_axi4StreamTransactor_s2m;
	axiMaster_out:buffer t_axi4StreamTransactor_m2s
	
	/* Debug ports. */
--	selTxn:in unsigned(3 downto 0):=x"5"	-- select PRBS by default.
);
end entity user;

architecture rtl of user is
	signal i_reset:std_ulogic:='0';
	signal porCnt:unsigned(3 downto 0);
	
	/* Global counters. */
	constant maxSymbols:positive:=2048;		--maximum number of symbols allowed to be transmitted in a frame. Each symbol's width equals tData's width. 
	
	signal lastTransaction:boolean;
	
	/* BFM signalling. */
	signal readRequest,writeRequest:t_bfm:=(address=>(others=>'X'),message=>(others=>'X'),trigger=>false);
	signal readResponse,writeResponse:t_bfm;
	
	/* Tester signals. */
	/* synthesis translate_off */
	signal clk,nReset:std_ulogic:='0';
	attribute period:time; attribute period of clk:signal is 10 ps;
	/* synthesis translate_on */
	
	signal dbg_axiTxFSM:axiBfmStatesTx;
	signal anlysr_dataIn:std_logic_vector(255 downto 0);
	signal anlysr_trigger:std_ulogic;
	
	signal axiMaster_in:t_axi4StreamTransactor_s2m;
	signal irq_write:std_ulogic;		-- clock gating.
	
	signal selTxn:unsigned(3 downto 0):=4x"5";	-- select PRBS by default.
	--signal selTxn:unsigned(3 downto 0):=4x"0";
	
begin
	/* Bus functional models. */
	axiMaster: entity tauhop.axiBfmMaster(rtl)
		port map(
			aclk=>irq_write, n_areset=>not i_reset,
			
			readRequest=>readRequest,	writeRequest=>writeRequest,
			readResponse=>readResponse,	writeResponse=>writeResponse,
			axiMaster_in=>axiMaster_in,
			axiMaster_out=>axiMaster_out,
			
			lastTransaction=>lastTransaction,
			dbg_axiTxFSM=>dbg_axiTxFSM
	);
	
	/* Clocks and reset. */
	/* Power-on Reset circuitry. */
	por: process(nReset,clk) is begin
		if not nReset then i_reset<='1'; porCnt<=(others=>'1');
		elsif rising_edge(clk) then
			i_reset<='0';
			
			if porCnt>0 then i_reset<='1'; porCnt<=porCnt-1; end if;
		end if;
	end process por;
	
	/* synthesis translate_off */
	clk<=not clk after clk'period/2;
	process is begin
		nReset<='1'; wait for 1 ps;
		nReset<='0'; wait for 500 ps;
		nReset<='1';
		wait;
	end process;
	/* synthesis translate_on */
	
	/* Simulation Tester. */
	
	/* Hardware tester. */
	bist: entity work.tester(cdcrv) port map(
		clk=>clk, reset=>i_reset,
		axiMaster_in=>axiMaster_in,
		axiMaster_out=>axiMaster_out,
		readRequest=>readRequest, writeRequest=>writeRequest,
		readResponse=>readResponse, writeResponse=>writeResponse,
		irq_write=>irq_write,
		lastTransaction=>lastTransaction,
		selTxn=>selTxn
	);
end architecture rtl;
