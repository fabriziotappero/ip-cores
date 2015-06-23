--+-------------------------------------------------------------------------------------------------+
--|																									|
--|  File:			pciwbsequ.vhd                                                          			|
--|																									|
--|  Project:		pci32tlite_oc																	|
--|																									|
--|  Description: 	FSM controlling PCI to Whisbone sequence. 										|
--|	 																								|
--+-------------------------------------------------------------------------------------------------+
--|																									|
--|  Revision history :																				|
--|  Date 		  Version	Author	Description														|
--|  2005-05-13   R00A00    PAU		First alfa revision	(eng)										|
--|  2006-01-09             MS      added debug signals debug_init, debug_access					|																			|
--|																									|
--|  To do:	 																						|
--|																									|
--+-------------------------------------------------------------------------------------------------+
--+-----------------------------------------------------------------+
--| 																|
--|  Copyright (C) 2005 Peio Azkarate, peio@opencores.org   		| 
--| 																|
--|  This source file may be used and distributed without     		|
--|  restriction provided that this copyright statement is not		|
--|  removed from the file and that any derivative work contains	|
--|  the original copyright notice and the associated disclaimer.	|
--|                                                              	|
--|  This source file is free software; you can redistribute it     |
--|  and/or modify it under the terms of the GNU Lesser General     |
--|  Public License as published by the Free Software Foundation;   |
--|  either version 2.1 of the License, or (at your option) any     |
--|  later version.                                                 |
--| 																|
--|  This source is distributed in the hope that it will be         |
--|  useful, but WITHOUT ANY WARRANTY; without even the implied     |
--|  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR        |
--|  PURPOSE.  See the GNU Lesser General Public License for more   |
--|  details.                                                       |
--| 																|
--|  You should have received a copy of the GNU Lesser General      |
--|  Public License along with this source; if not, download it     |
--|  from http://www.opencores.org/lgpl.shtml                       |
--| 																|
--+-----------------------------------------------------------------+ 


--+-----------------------------------------------------------------------------+
--|									LIBRARIES									|
--+-----------------------------------------------------------------------------+

library ieee;
use ieee.std_logic_1164.all;


--+-----------------------------------------------------------------------------+
--|									ENTITY   									|
--+-----------------------------------------------------------------------------+

entity pciwbsequ is
port (

   	-- General 
    clk_i       	: in std_logic;
   	nrst_i       	: in std_logic;
	-- pci 
	--adr_i
	cmd_i			: in std_logic_vector(3 downto 0);
	cbe_i			: in std_logic_vector(3 downto 0);
	frame_i    	 	: in std_logic;
	irdy_i        	: in std_logic;
	devsel_o		: out std_logic;
	trdy_o        	: out std_logic;
	-- control
	adrcfg_i		: in std_logic;
	adrmem_i 		: in std_logic;
	pciadrLD_o	   	: out std_logic;
	pcidOE_o	   	: out std_logic;
	parOE_o			: out std_logic;
	wbdatLD_o   	: out std_logic;
	wbrgdMX_o   	: out std_logic;
	wbd16MX_o   	: out std_logic;	
	wrcfg_o 		: out std_logic;
	rdcfg_o 		: out std_logic;
	-- whisbone
	wb_sel_o		: out std_logic_vector(1 downto 0);
	wb_we_o			: out std_logic;
	wb_stb_o		: inout std_logic;	
	wb_cyc_o		: out std_logic;
	wb_ack_i		: in std_logic;
	wb_err_i		: in std_logic;	
	-- debug signals
	debug_init	 : out std_logic;
	debug_access : out std_logic 
);   
end pciwbsequ;


architecture rtl of pciwbsequ is


--+-----------------------------------------------------------------------------+
--|									COMPONENTS									|
--+-----------------------------------------------------------------------------+
--+-----------------------------------------------------------------------------+
--|									CONSTANTS  									|
--+-----------------------------------------------------------------------------+
--+-----------------------------------------------------------------------------+
--|									SIGNALS   									|
--+-----------------------------------------------------------------------------+

	type PciFSM is ( PCIIDLE, B_BUSY, S_DATA1, S_DATA2, TURN_AR );	
  	signal pst_pci 		: PciFSM;
  	signal nxt_pci 		: PciFSM;

  	signal sdata1		: std_logic;
  	signal sdata2		: std_logic;
	signal idleNX		: std_logic;
	signal sdata1NX		: std_logic;
	signal sdata2NX		: std_logic;
	signal turnarNX		: std_logic;
	signal idle			: std_logic;
  	signal devselNX_n	: std_logic;
  	signal trdyNX_n		: std_logic;
  	signal devsel		: std_logic;
  	signal trdy			: std_logic;
  	signal adrpci		: std_logic;
  	signal acking		: std_logic;
  	signal rdcfg		: std_logic;
	signal targOE		: std_logic;
	signal pcidOE		: std_logic;


begin
	
    --+-------------------------------------------------------------------------+
    --|  PCI-Whisbone Sequencer													|
    --+-------------------------------------------------------------------------+
	
	
    --+-------------------------------------------------------------+
	--|  FSM PCI-Whisbone											|
    --+-------------------------------------------------------------+
		
	PCIFSM_CLOCKED: process( nrst_i, clk_i, nxt_pci )
	begin
	
    	if( nrst_i = '0' ) then
			pst_pci <= PCIIDLE;
  		elsif( rising_edge(clk_i) ) then
			pst_pci <= nxt_pci; 
        end if;
    
	end process PCIFSM_CLOCKED;


  	PCIFSM_COMB: process( pst_pci, frame_i, irdy_i, adrcfg_i, adrpci, acking )
	begin
		
		devselNX_n 	<= '1';
		trdyNX_n 	<= '1';	
    	case pst_pci is

	    	when PCIIDLE =>
	       		if ( frame_i = '0' ) then	
					nxt_pci <= B_BUSY; 	
				else
					nxt_pci <= PCIIDLE;
				end if;		
				
            when B_BUSY =>
				if ( adrpci = '0' ) then
					nxt_pci <= TURN_AR;
				else
					nxt_pci <= S_DATA1;
					devselNX_n <= '0'; 
				end if;

		    when S_DATA1 =>
	       		if ( acking = '1' ) then	
					nxt_pci 	<= S_DATA2;
					devselNX_n 	<= '0'; 					
					trdyNX_n 	<= '0';	
				else
					nxt_pci <= S_DATA1;
					devselNX_n <= '0'; 					
				end if;		
								
		    when S_DATA2 => 
	       		if ( frame_i = '1' and irdy_i = '0' ) then	
					nxt_pci <= TURN_AR;
				else
					nxt_pci <= S_DATA2;
					devselNX_n <= '0'; 					
					trdyNX_n <= '0';	
				end if;		
				
			when TURN_AR =>
				if ( frame_i = '1' ) then
					nxt_pci <= PCIIDLE;
				else
					nxt_pci <= TURN_AR;
				end if;
				
	    end case;
        
	end process PCIFSM_COMB;	


    --+-------------------------------------------------------------+
	--|  FSM control signals										|
    --+-------------------------------------------------------------+

	adrpci <= adrmem_i or adrcfg_i;
	acking <= '1' when ( wb_ack_i = '1' or wb_err_i = '1' ) or ( adrcfg_i = '1' and  irdy_i = '0')
				  else '0'; 


    --+-------------------------------------------------------------+
	--|  FSM derived Control signals								|
    --+-------------------------------------------------------------+
	idle 		<= '1' when ( pst_pci = PCIIDLE ) else '0';
	sdata1 		<= '1' when ( pst_pci = S_DATA1 ) else '0';
	sdata2 		<= '1' when ( pst_pci = S_DATA2 ) else '0';
	idleNX 		<= '1' when ( nxt_pci = PCIIDLE ) else '0';
	sdata1NX 	<= '1' when ( nxt_pci = S_DATA1 ) else '0';	
	sdata2NX 	<= '1' when ( nxt_pci = S_DATA2 ) else '0';
	turnarNX 	<= '1' when ( nxt_pci = TURN_AR ) else '0';
	


    --+-------------------------------------------------------------+
	--|  PCI Data Output Enable										|
    --+-------------------------------------------------------------+

	PCIDOE_P: process( nrst_i, clk_i, cmd_i(0), sdata1NX, turnarNX )
	begin

    	if ( nrst_i = '0' ) then 
			pcidOE <= '0';
  		elsif ( rising_edge(clk_i) ) then 

			if ( sdata1NX = '1' and cmd_i(0) = '0' ) then
				pcidOE <= '1';
			elsif ( turnarNX = '1' ) then
				pcidOE <= '0';
			end if;			
			
        end if;

	end process PCIDOE_P;

	pcidOE_o <= pcidOE;


    --+-------------------------------------------------------------+
	--|  PAR Output Enable											|
	--|  PCI Read data phase										|
	--|  PAR is valid 1 cicle after data is valid					|
    --+-------------------------------------------------------------+

	PAROE_P: process( nrst_i, clk_i, cmd_i(0), sdata2NX, turnarNX )
	begin

    	if ( nrst_i = '0' ) then 
			parOE_o <= '0';
  		elsif ( rising_edge(clk_i) ) then 

			if ( ( sdata2NX = '1' or turnarNX = '1' ) and cmd_i(0) = '0' ) then
				parOE_o <= '1';
			else
				parOE_o <= '0';
			end if;			
			
        end if;
		
	end process PAROE_P;

	
    --+-------------------------------------------------------------+
	--|  Target s/t/s signals OE control							|
    --+-------------------------------------------------------------+

--	targOE <= '1' when ( idle = '0' and adrpci = '1' ) else '0';
	TARGOE_P: process( nrst_i, clk_i, sdata1NX, idleNX )
	begin

    	if ( nrst_i = '0' ) then 
			targOE <= '0';
  		elsif ( rising_edge(clk_i) ) then 

			if ( sdata1NX = '1' ) then
				targOE <= '1';
			elsif ( idleNX = '1' ) then
				targOE <= '0';
			end if;			
			
        end if;

	end process TARGOE_P;
		

    --+-------------------------------------------------------------------------+
    --|  WHISBONE outs															|
    --+-------------------------------------------------------------------------+
				
	wb_cyc_o <= '1' when ( adrmem_i = '1' and sdata1 = '1' ) else '0';
    wb_stb_o <= '1' when ( adrmem_i = '1' and sdata1 = '1' and irdy_i = '0' ) else '0';

	-- PCI(Little endian) to WB(Big endian)
	wb_sel_o(1) <= (not cbe_i(0)) or (not cbe_i(2));
	wb_sel_o(0) <= (not cbe_i(1)) or (not cbe_i(3));	
	-- 
	wb_we_o <= cmd_i(0);
	

    --+-------------------------------------------------------------------------+
	--|  Syncronized PCI outs													|
    --+-------------------------------------------------------------------------+
	
	PCISIG: process( nrst_i, clk_i, devselNX_n, trdyNX_n)
	begin

		if( nrst_i = '0' ) then 
			devsel 		<= '1';
			trdy 		<= '1';
		elsif( rising_edge(clk_i) ) then 
		
			devsel 		<= devselNX_n;
			trdy 		<= trdyNX_n;
			
		end if;
		
	end process PCISIG;

	devsel_o <= devsel when ( targOE = '1' ) else 'Z';
	trdy_o   <= trdy   when ( targOE = '1' ) else 'Z';
	

    --+-------------------------------------------------------------------------+
	--|  Other outs																|
    --+-------------------------------------------------------------------------+

	--  rd/wr Configuration Space Registers
	wrcfg_o <= '1' when ( adrcfg_i = '1' and cmd_i(0) = '1' and sdata2 = '1' ) else '0';
	rdcfg <= '1' when ( adrcfg_i = '1' and cmd_i(0) = '0' and ( sdata1 = '1' or sdata2 = '1' ) ) else '0';
	rdcfg_o <= rdcfg;
	
	-- LoaD enable signals
	pciadrLD_o <= not frame_i;
	wbdatLD_o  <= wb_ack_i;

	-- Mux control signals
	wbrgdMX_o <= not rdcfg;
	wbd16MX_o <= '1' when ( cbe_i(3) = '0' or cbe_i(2) = '0' ) else '0';
	
    --+-------------------------------------------------------------------------+
	--|  debug outs 															|
    --+-------------------------------------------------------------------------+
	
	process (nrst_i, clk_i)
	begin
		if ( nrst_i = '0' ) then
			debug_init <= '0';
			elsif clk_i'event and clk_i = '1' then
				if devsel = '0' then
					debug_init <= '1';
				end if;
		end if;
	end process;	
	
	process (nrst_i, clk_i)
	begin
		if ( nrst_i = '0' ) then
			debug_access <= '0';
			elsif clk_i'event and clk_i = '1' then
				if wb_stb_o = '1' then
					debug_access <= '1';
				end if;
		end if;
	end process; 

end rtl;
