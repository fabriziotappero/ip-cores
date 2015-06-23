--/*
--	This file is part of the AXI4 Transactor and Bus Functional Model 
--	(axi4_tlm_bfm) project:
--		http://www.opencores.org/project,axi4_tlm_bfm

--	Description
--	Implementation of AXI4 transactor data structures and high-level API.
	
--	To Do: 
	
--	Author(s): 
--	- Daniel C.K. Kho, daniel.kho@opencores.org | daniel.kho@tauhop.com
	
--	Copyright (C) 2012-2013 Authors and OPENCORES.ORG
	
--	This source file may be used and distributed without 
--	restriction provided that this copyright statement is not 
--	removed from the file and that any derivative work contains 
--	the original copyright notice and the associated disclaimer.
	
--	This source file is free software; you can redistribute it 
--	and/or modify it under the terms of the GNU Lesser General 
--	Public License as published by the Free Software Foundation; 
--	either version 2.1 of the License, or (at your option) any 
--	later version.
	
--	This source is distributed in the hope that it will be 
--	useful, but WITHOUT ANY WARRANTY; without even the implied 
--	warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR 
--	PURPOSE. See the GNU Lesser General Public License for more 
--	details.
	
--	You should have received a copy of the GNU Lesser General 
--	Public License along with this source; if not, download it 
--	from http://www.opencores.org/lgpl.shtml.
--*/
--/* FIXME VHDL-2008 instantiated package. Unsupported by VCS-MX, Quartus, and Vivado. QuestaSim/ModelSim supports well. */
library ieee; use ieee.std_logic_1164.all, ieee.numeric_std.all;
--use std.textio.all;
library tauhop;

--/* Record I/O data structures for AXI interface transactor (block interface). */
package axiTLM is
--	generic(
--		type t_qualifier; type t_id; type t_dest; type t_user; type t_resp;
--		package transactor is new tauhop.tlm generic map(<>)
--	);
--	/* Makes transactor.t_addr and transactor.t_msg visible. */
--	use transactor.all;
	
--	/* TODO remove once generic packages are supported. */
	use tauhop.tlm.all;
	--type boolean_vector is array(natural range<>) of boolean;
	--subtype t_qualifier is boolean_vector(32/8-1 downto 0);
	subtype t_qualifier is std_ulogic_vector(32/8-1 downto 0);
	subtype t_id is unsigned(31 downto 0);
	subtype t_dest is unsigned(3 downto 0);
	subtype t_user is unsigned(7 downto 0);
	subtype t_resp is unsigned(1 downto 0);		--2 bits. b"00" = OKAY, b"01" = ExOKAY, b"10" = SLVERR (slave error), b"11" = DECERR (decode error).
	
--	/* AXI Transactor block interfaces. */
	type t_axi4Transactor_m2s is record
--		/* Address must be unresolved, because you need to drive the read address only when read is asserted, and 
--			drive the write address when write is asserted. Resolution functions are not expected to know how to decide this.
--		*/
--		/* Write address channel. */
		awId:t_id;
--		awLen:unsigned(7 downto 0);		--8 bits as defined by the standard.
--		awSize:unsigned(2 downto 0);	--3 bits as defined by the standard. Burst size for write transfers.
--		awBurst:
--		awLock:
--		awCache:
--		awQoS:
--		awRegion:
--		awUser:
		-- AXI4-Lite required signals.
		awAddr:t_addr;
		awProt:boolean;
		awValid:boolean;
		
--		/* Write data channel. */
		wId:t_id;
--		wLast:
--		wUser:
		-- AXI4-Lite required signals.
		wValid:boolean;
		wData:t_msg;
--		wStrb:std_ulogic_vector(wData'length/8-1 downto 0);	--default is all ones if master always performs full datawidth write transactions.
		wStrb:t_qualifier;	--default is all ones if master always performs full datawidth write transactions.
		
--		/* Write response channel. */
		bReady:boolean;
		
--		/* Read address channel. */
		arId:t_id;
--		arLen:unsigned(7 downto 0);		--8 bits as defined by the standard.
--		arSize:unsigned(2 downto 0);	--3 bits as defined by the standard.
--		arBurst:
--		arLock:
--		arCache:
--		arQoS:
--		arRegion:
--		arUser:
		-- AXI4-Lite required signals.
		arValid:boolean;
		arAddr:t_addr;
		arProt:boolean;
		
--		/* Read data channel. */
		rReady:boolean;
	end record t_axi4Transactor_m2s;
	
	type t_axi4Transactor_s2m is record
--		/* Write address channel. */
		awReady:boolean;
		
--		/* Write data channel. */
		wReady:boolean;
		
--		/* Write response channel. */
		bId:t_id;
--		bUser:
		-- AXI4-Lite required signals.
		bValid:boolean;
		bResp:t_resp;
		
--		/* Read address channel. */
		arReady:boolean;
		
--		/* Read data channel. */
		rId:t_id;
--		rLast:
--		rUser:
		-- AXI4-Lite required signals.
		rValid:boolean;
		rData:t_msg;
		rResp:t_resp;
	end record t_axi4Transactor_s2m;
	
	type t_axi4StreamTransactor_m2s is record
--		/* AXI4 streaming interface. */
		tValid:boolean;
		tData:t_msg;
		tStrb:t_qualifier;
		tKeep:t_qualifier;
		tLast:boolean;
		tId:t_id;
		tDest:t_dest;
		tUser:t_user;
	end record t_axi4StreamTransactor_m2s;
	
	type t_axi4StreamTransactor_s2m is record
		tReady:boolean;
	end record t_axi4StreamTransactor_s2m;
	
--	/* AXI Low-power interface. */
--	type tAxiTransactor_lp is record
--		cSysReq:
--		cSysAck:
--		cActive:
--	end record tAxiTransactor_lp;
	
	type t_fsm is (idle,sendAddr,startOfPacket,payload,endOfPacket,endOfTx);
	type axiBfmStatesTx is (idle,payload,endOfTx);
	type axiBfmStatesRx is (idle,checkAddr,startOfPacket,payload);
	
	attribute enum_encoding:string;
	attribute enum_encoding of axiBfmStatesTx:type is "00 01 10";
	
	function to_std_logic_vector(fsm:axiBfmStatesTx) return std_logic_vector;
end package axiTLM;

package body axiTLM is
	function to_std_logic_vector(fsm:axiBfmStatesTx) return std_logic_vector is
		variable r:std_logic_vector(1 downto 0);
	begin
		case fsm is
			when idle=>		r:=2x"0";
			when payload=>	r:=2x"1";
			when endOfTx=>	r:=2x"2";
			when others=>	null;
		end case;
		return r;
	end function to_std_logic_vector;
end package body axiTLM;


--/* AXI Transactor API.
-- * 	Generally, transactors are high-level bus interface models that perform 
-- * 		read/write transactions to/from the bus. These models are not concerned 
-- * 		with the low-level implementation of the bus protocol. However, the 
-- * 		TLM models encapsulate the lower-level models known as the BFM.
-- * 	axiTLM uses generic package tauhop.tlm, hence inherits basic TLM types and 
-- * 		procedures generally used in any messaging system (i.e. address and message 
-- * 		information, and bus read/write methods). It also extends the tauhop.tlm 
-- * 		package with application-specific types, such as record structures specific
-- * 		to the AXI protocol.
-- * 	axiTransactor instantiates the axiTLM, and assigns specific types to the 
-- * 		transactor model.
-- */
--/*library ieee; use ieee.std_logic_1164.all, ieee.numeric_std.all;
--library tauhop;
--package transactor is new tauhop.tlm generic map(
--	t_addr=>unsigned(31 downto 0),		-- default assignment. Used only for non-stream interfaces.
--	t_msg=>signed(63 downto 0),
--	t_cnt=>unsigned(127 downto 0)
--);

--library ieee; use ieee.std_logic_1164.all, ieee.numeric_std.all;
--library tauhop; use tauhop.transactor.all;
--package axiTransactor is new tauhop.axiTLM generic map(
--	t_qualifier=>boolean_vector(32/8-1 downto 0),
--	t_id=>unsigned(7 downto 0),
--	t_dest=>unsigned(3 downto 0),
--	t_user=>unsigned(7 downto 0),	--unsigned(86*2-1 downto 0),
--	t_resp=>unsigned(1 downto 0),	--only used for AXI4-Lite (non-streaming).
--	transactor=>tauhop.transactor
--);
--*/