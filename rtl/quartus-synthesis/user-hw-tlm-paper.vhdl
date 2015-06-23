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
library tauhop; use tauhop.tlm.all, tauhop.axiTLM.all;

/* synthesis translate_off */
library osvvm; use osvvm.RandomPkg.all; use osvvm.CoveragePkg.all;
/* synthesis translate_on */

library altera; use altera.stp;


entity user is port(
	/* Comment-out for simulation. */
	clk,nReset:in std_ulogic;
	
	/* AXI Master interface */
	axiMaster_in:in t_axi4StreamTransactor_s2m;
	axiMaster_out:buffer t_axi4StreamTransactor_m2s;
	
	/* Debug ports. */
	dataIn:in t_msg;
	selTxn:in unsigned(3 downto 0)
);
end entity user;

architecture rtl of user is
	signal reset:std_ulogic:='0';
	signal locked:std_ulogic;
	signal porCnt:unsigned(3 downto 0);
	signal trigger:boolean;
	
	/* Global counters. */
	constant maxSymbols:positive:=2048;		--maximum number of symbols allowed to be transmitted in a frame. Each symbol's width equals tData's width. 
	signal symbolsPerTransfer:t_cnt;
	signal outstandingTransactions:t_cnt;
	
	/* BFM signalling. */
	signal readRequest,writeRequest:t_bfm:=(address=>(others=>'X'),message=>(others=>'X'),trigger=>false);
	signal readResponse,writeResponse:t_bfm;
	
	type txStates is (idle,transmitting);
	signal txFSM,i_txFSM:txStates;
	
	/* Tester signals. */
	/* synthesis translate_off */
	signal clk,nReset:std_ulogic:='0';
	attribute period:time; attribute period of clk:signal is 10 ps;
	/* synthesis translate_on */
	
	signal testerClk:std_ulogic;
	signal dbg_axiTxFSM:axiBfmStatesTx;
	signal anlysr_dataIn:std_logic_vector(255 downto 0);
	signal anlysr_trigger:std_ulogic;
	
	signal irq_write:std_ulogic;		-- clock gating.
	
	
begin
	/* Bus functional models. */
	axiMaster: entity tauhop.axiBfmMaster(rtl)
		port map(
			aclk=>irq_write, n_areset=>not reset,
			
			readRequest=>readRequest,	writeRequest=>writeRequest,
			readResponse=>readResponse,	writeResponse=>writeResponse,
			axiMaster_in=>axiMaster_in,
			axiMaster_out=>axiMaster_out,
			
			symbolsPerTransfer=>symbolsPerTransfer,
			outstandingTransactions=>outstandingTransactions,
			dbg_axiTxFSM=>dbg_axiTxFSM
	);
	
	/* Interrupt-request generator. */
	trigger<=txFSM/=i_txFSM or writeResponse.trigger;
	irq_write<=clk when not reset else '0';
	
	/* Simulation Tester. */
	/* PLL to generate tester's clock. */
	f100MHz: entity altera.pll(syn) port map(
		areset=>'0',	--not nReset,
		inclk0=>clk,
		c0=>testerClk,
		locked=>locked
	);
	
	/* synthesis translate_off */
	clk<=not clk after clk'period/2;
	process is begin
		nReset<='1'; wait for 1 ps;
		nReset<='0'; wait for 500 ps;
		nReset<='1';
		wait;
	end process;
	/* synthesis translate_on */
	
	
	/* Hardware tester. */
	/* Power-on Reset circuitry. */
	por: process(nReset,clk) is
		--variable porCnt:unsigned(7 downto 0):=(others=>'1');
	begin
		if not nReset then reset<='1'; porCnt<=(others=>'1');
		elsif rising_edge(clk) then
			reset<='0';
			
			if porCnt>0 then reset<='1'; porCnt<=porCnt-1; end if;
		end if;
	end process por;
	
	
	/* Stimuli sequencer. TODO move to tester/stimuli.
		This emulates the AXI4-Stream Slave.
	*/
	/* Simulation-only stimuli sequencer. */
	/* synthesis translate_off */
	process is begin
		report "Performing fast read..." severity note;
		
		/* Fast read. */
		while not axiMaster_out.tLast loop
			/* Wait for tValid to assert. */
			while not axiMaster_out.tValid loop
				wait until falling_edge(clk);
			end loop;
			
			axiMaster_in.tReady<=true;
			
			wait until falling_edge(clk);
			axiMaster_in.tReady<=false;
		end loop;
		
		wait until falling_edge(clk);
		report "Performing normal read..." severity note;
		
		/* Normal read. */
		while not axiMaster_out.tLast loop
			/* Wait for tValid to assert. */
			while not axiMaster_out.tValid loop
				wait until falling_edge(clk);
			end loop;
			
			wait until falling_edge(clk);
			wait until falling_edge(clk);
			axiMaster_in.tReady<=true;
			
			wait until falling_edge(clk);
			axiMaster_in.tReady<=false;
			
			wait until falling_edge(clk);
		end loop;
		
		report "Completed normal read." severity note;
		
		for i in 0 to 10 loop
			wait until falling_edge(clk);
		end loop;
		
		/* One-shot read. */
		axiMaster_in.tReady<=true;
		
		wait until falling_edge(clk);
		axiMaster_in.tReady<=false;
		
		report "Completed one-shot read." severity note;
		
		wait;
	end process;
	/* synthesis translate_on */
	
	
	sequencer_ns: process(all) is begin
		txFSM<=i_txFSM;
		if reset then txFSM<=idle;
		else
			case i_txFSM is
				when idle=>
					if outstandingTransactions>0 then txFSM<=transmitting; end if;
				when transmitting=>
					if axiMaster_out.tLast then
						txFSM<=idle;
					end if;
				when others=> null;
			end case;
		end if;
	end process sequencer_ns;
	
	sequencer_op: process(reset,irq_write) is
		/* Local procedures to map BFM signals with the package procedure. */
		procedure read(address:in t_addr) is begin
			read(readRequest,address);
		end procedure read;
		
		procedure write(data:in t_msg) is begin
			write(request=>writeRequest, address=>(others=>'-'), data=>data);
		end procedure write;
		
		variable isPktError:boolean;
		
		/* Tester variables. */
		/* Synthesis-only randomisation. */
		
		/* Simulation-only randomisation. */
		/* synthesis translate_off */
		variable rv0:RandomPType;
		/* synthesis translate_on */
		
	begin
		if falling_edge(irq_write) then
			case txFSM is
				when transmitting=>
					if trigger then
						/* synthesis translate_off */
						write(rv0.RandSigned(axiMaster_out.tData'length));
						/* synthesis translate_on */
						
						case selTxn is
							when x"0"=> write(dataIn);
							when x"1"=> write(32x"12345678");
							when x"2"=> write(32x"87654321");
							when x"3"=> write(32x"abcd1234");
							when others=> write(32x"12ab34cd");
						end case;
					end if;
				when others=>null;
			end case;
		end if;
	end process sequencer_op;
	
	sequencer_regs: process(irq_write) is begin
		if falling_edge(irq_write) then
			i_txFSM<=txFSM;
		end if;
	end process sequencer_regs;
	
	outstandingTransactions<=128x"fc";
end architecture rtl;
