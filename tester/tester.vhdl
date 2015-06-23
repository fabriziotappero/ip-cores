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
library tauhop; use tauhop.transactor.all, tauhop.axiTransactor.all;		--TODO just use axiTransactor here as transactor should already be wrapped up.

/* TODO remove once generic packages are supported. */
--library tauhop; use tauhop.tlm.all, tauhop.axiTLM.all;

/* synthesis translate_off */
library osvvm; use osvvm.RandomPkg.all, osvvm.CoveragePkg.all;
/* synthesis translate_on */

--library altera; use altera.stp;


entity tester is port(
	clk,reset:in std_ulogic;
	
	/* AXI Master interface */
	axiMaster_in:buffer t_axi4StreamTransactor_s2m;
	axiMaster_out:in t_axi4StreamTransactor_m2s;
	
	/* BFM signalling. */
	readRequest,writeRequest:buffer t_bfm;
	readResponse,writeResponse:in t_bfm;
	
	irq_write:buffer std_ulogic;		-- clock gating.
	
	lastTransaction:out boolean;
	
	/* Debug ports. */
	selTxn:in unsigned(3 downto 0)
);
end entity tester;

architecture rtl of tester is
	signal locked:std_ulogic;
	signal porCnt:unsigned(3 downto 0);
	signal trigger:boolean;
	
	/* Global counters. */
	constant maxSymbols:positive:=2048;		--maximum number of symbols allowed to be transmitted in a frame. Each symbol's width equals tData's width. 
--	signal symbolsPerTransfer:t_cnt;
--	signal outstandingTransactions:t_cnt;
	
--	/* BFM signalling. */
--	signal readRequest,writeRequest:t_bfm:=(address=>(others=>'X'),message=>(others=>'X'),trigger=>false);
--	signal readResponse,writeResponse:t_bfm;
	
	type txStates is (idle,transmitting);
	signal txFSM,i_txFSM:txStates;
	
	/* Tester signals. */
	/* synthesis translate_off */
	attribute period:time; attribute period of clk:signal is 10 ps;
	/* synthesis translate_on */
	
	signal testerClk:std_ulogic;
	signal dbg_axiTxFSM:axiBfmStatesTx;
	signal anlysr_dataIn:std_logic_vector(127 downto 0);
	signal anlysr_trigger:std_ulogic;
	
--	signal axiMaster_in:t_axi4StreamTransactor_s2m;
--	signal irq_write:std_ulogic;		-- clock gating.
	
	signal prbs:t_msg;
	
	/* Coverage-driven randomisation. */
	/* synthesis translate_off */
	shared variable rv0:covPType;
	/* synthesis translate_on */
	signal rv:integer;
	signal pctCovered:real;
	signal isCovered,i_isCovered:boolean;
	
begin
	/* PLL to generate tester's clock. */
/*    f100MHz: entity altera.pll(syn) port map(
        areset=>'0',    --not nReset,
        inclk0=>clk,
        c0=>testerClk,
        locked=>locked
    );
*/	
	/* Interrupt-request generator. */
	trigger<=txFSM/=i_txFSM or writeResponse.trigger;
--	trigger<=(txFSM/=i_txFSM and txFSM=transmitting) or writeResponse.trigger;	-- fixes bug when multiple transactions occur during endOfTx (this should be illegal).
	irq_write<=clk when not reset else '0';
	
	/* SignalTap II embedded logic analyser. Included as part of BiST architecture. */
	--anlysr_trigger<='1' when writeRequest.trigger else '0';
	anlysr_trigger<='1' when reset else '0';
	
	/* Disable this for synthesis as this is not currently synthesisable.
		Pull the framerFSM statemachine signal from lower down the hierarchy to this level instead.
	*/
	/* synthesis translate_off */
	--framerFSM<=to_unsigned(<<signal framers_txs(0).i_framer.framerFSM: framerFsmStates>>,framerFSM'length);
	/* synthesis translate_on */
	
--	anlysr_dataIn(7 downto 0)<=std_logic_vector(symbolsPerTransfer(7 downto 0));
--	anlysr_dataIn(15 downto 8)<=std_logic_vector(outstandingTransactions(7 downto 0));
	--anlysr_dataIn(2 downto 0) <= <<signal axiMaster.axiTxState:axiBfmStatesTx>>;
	anlysr_dataIn(17 downto 16)<=to_std_logic_vector(dbg_axiTxFSM);
	anlysr_dataIn(18)<='1' when clk else '0';
	anlysr_dataIn(19)<='1' when reset else '0';
	anlysr_dataIn(20)<='1' when irq_write else '0';
	anlysr_dataIn(21)<='1' when axiMaster_in.tReady else '0';
	anlysr_dataIn(22)<='1' when axiMaster_out.tValid else '0';
	anlysr_dataIn(54 downto 23)<=std_logic_vector(axiMaster_out.tData);
	anlysr_dataIn(86 downto 55)<=std_logic_vector(prbs);
	--anlysr_dataIn(90 downto 87)<=std_logic_vector(axiMaster_out.tStrb);
	--anlysr_dataIn(94 downto 91)<=std_logic_vector(axiMaster_out.tKeep);
	anlysr_dataIn(95)<='1' when axiMaster_out.tLast else '0';
	anlysr_dataIn(96)<='1' when writeRequest.trigger else '0';
	anlysr_dataIn(97)<='1' when writeResponse.trigger else '0';
	anlysr_dataIn(99 downto 98)<=to_std_logic_vector(dbg_axiTxFSM);
	anlysr_dataIn(101 downto 98)<=std_logic_vector(porCnt);
--	anlysr_dataIn(102)<='1' when locked else '0';
--	anlysr_dataIn(102)<=locked;
	
	anlysr_dataIn(anlysr_dataIn'high downto 102)<=(others=>'0');
	
	
	/* Simulate only if you have compiled Altera's simulation libraries. */
/*	i_bist_logicAnalyser: entity altera.stp(syn) port map(
		acq_clk=>testerClk,
		acq_data_in=>anlysr_dataIn,
		acq_trigger_in=>"1",
		trigger_in=>anlysr_trigger
	);
*/	
	
	
	/* Stimuli sequencer. TODO move to tester/stimuli.
		This emulates the AXI4-Stream Slave.
	*/
	/* Simulation-only stimuli sequencer. */
	/* synthesis translate_off */
	process is begin
		/* Fast read. */
		report "Performing fast read..." severity note;
		while not axiMaster_out.tLast loop
			/* Wait for tValid to assert. */
			while not axiMaster_out.tValid loop
				wait until falling_edge(clk);
			end loop;
			
			axiMaster_in.tReady<=true;
			
			wait until falling_edge(clk);
			axiMaster_in.tReady<=false;
			
			report "coverage: " & to_string(pctCovered) severity note;
		end loop;
		report "coverage: " & to_string(pctCovered) severity note;
		report "Completed fast read." severity note;
		
		wait until falling_edge(clk);
		
		/* Normal read. */
		report "Performing normal read..." severity note;
		while not axiMaster_out.tLast loop
			wait until falling_edge(clk);
			
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
			
			report "coverage: " & to_string(pctCovered) severity note;
		end loop;
		report "coverage: " & to_string(pctCovered) severity note;
		report "Completed normal read." severity note;
		
		for i in 0 to 10 loop
			wait until falling_edge(clk);
		end loop;
		
		/* One-shot read. */
		report "Performing one-shot read..." severity note;
		axiMaster_in.tReady<=true;
		
		wait until falling_edge(clk);
		axiMaster_in.tReady<=false;
		
		report "coverage: " & to_string(pctCovered) severity note;
		report "Completed one-shot read." severity note;
		
		wait;
	end process;
	/* synthesis translate_on */
	
	/* Synthesisable stimuli sequencer. */
/*	process(clk) is begin
		if falling_edge(clk) then
			axiMaster_in.tReady<=false;
			--if axiMaster_out.tValid and not axiMaster_out.tLast then
			if not axiMaster_in.tReady and axiMaster_out.tValid and not axiMaster_out.tLast then
				axiMaster_in.tReady<=true;
			end if;
		end if;
	end process;
*/	
	
	/* Data transmitter. */
	/* Use either PRBS (LFSR) stimuli, or OSVVM randomisation stimuli, not both. */
	i_prbs: entity tauhop.prbs31(rtl)
		generic map(
			isParallelLoad=>true,
			tapVector=>(
				/* Example polynomial from Wikipedia:
					http://en.wikipedia.org/wiki/Computation_of_cyclic_redundancy_checks
				*/
				0|3|31=>true, 1|2|30 downto 4=>false
			)
		)
		port map(
			/* Comment-out for simulation. */
			clk=>irq_write, reset=>reset,
			en=>trigger,
			seed=>32x"ace1",
			prbs=>prbs
		);
	
	sequencer_ns: process(all) is
		variable last:boolean;
	begin
		txFSM<=i_txFSM;
		
		if reset then txFSM<=idle;
		else
			case i_txFSM is
				when idle=>
					if not lastTransaction then txFSM<=transmitting; end if;
					last:=false;
				when transmitting=>
					--if axiMaster_out.tLast then
					--	txFSM<=idle;
					--end if;
					
					/* Fixes multiple transactions when axiTxState=endOfTx. Do not allow 
						txFSM to enter idle until a tReady has been received after the 
						last transaction.
					*/
					if lastTransaction then last:=true; end if;
					if axiMaster_in.tReady and last then txFSM<=idle; end if;
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
		
	begin
		/* Asynchronous reset. */
		if reset then rv<=rv0.randCovPoint; rv0.iCover(rv);
		elsif falling_edge(irq_write) then
			if reset then
				rv<=rv0.randCovPoint;
				rv0.iCover(rv);
			end if;
			
			case txFSM is
				when transmitting=>
					if trigger and not isCovered then
						/* Pseudorandom stimuli generation using OS-VVM. */
						/* synthesis translate_off */
						rv<=rv0.randCovPoint;
						rv0.iCover(rv);
						
						write(to_signed(rv, axiMaster_out.tData'length));
						/* synthesis translate_on */
						
						/* Pseudorandom stimuli generation using LFSR. */
						/*
						case selTxn is
							when x"1"=> write(32x"12ab34cd");
							when x"2"=> write(32x"12345678");
							when x"3"=> write(32x"87654321");
							when x"4"=> write(32x"abcd1234");
							when others=> write(prbs);
						end case;
						*/
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
    
	
	/* simulation only. */
	/* synthesis translate_off */
	coverageMonitor: process is
		procedure initialise is begin
			rv0.deallocate;			--destroy rv0 and all bins.
			rv0.initSeed(rv0'instance_name);
		end procedure initialise;
		
	begin
		/* Fast- and normal-reads. */
		for i in 0 to 1 loop
			initialise;
			rv0.addBins(genBin(integer'low,integer'high,512));
			
			wait until isCovered;
--			rv0.writeBin;
			rv0.setCovZero;		-- reset all coverage counts to zero.
		end loop;
		
		/* One-shot read. */
		initialise;
		rv0.addBins(genBin(integer'low,integer'high,1));
		
		wait until isCovered;
--		rv0.writeBin;
		rv0.setCovZero;
		
        wait for 500 ps;
        std.env.stop;
    end process coverageMonitor;
	
	process(irq_write) is begin
		if falling_edge(irq_write) then
			pctCovered<=rv0.getCov;
			isCovered<=rv0.isCovered;
			i_isCovered<=isCovered;
		end if;
	end process;
	/* synthesis translate_on */
	
	
	lastTransaction<=true when isCovered else false;
	
	checker: process(clk) is begin
		if rising_edge(clk) then
			if axiMaster_in.tReady then
				assert axiMaster_out.tData/="ZZZZZZZZ"
					report "[Error]: tData must be valid when tReady is asserted at the rising edge of the clock." severity error;
			end if;
		end if;
	end process checker;
end architecture rtl;
