--+-------------------------------------------------------------------------------------------------+
--|																									|
--|  File:			pci32tlite.vhd                       		                                   	|
--|																									|
--|  Components:	pcidec_new.vhd																		|
--|		            pciwbsequ.vhd           														|
--|		            pcidmux.vhd           															|
--|		            pciregs.vhd           															|
--|		            pcipargen.vhd          															|
--|		            -- Libs --             															|
--|		            ona.vhd		          															|
--|																									|
--|	 Description:	TARGET PCI :						 							|
--| 				 																				|
--|					* PCI Target 32 Bits															|
--|					* BAR0 32MByte address space													|
--|					* Whisbone compatible: D16, 32MB address space                                  |
--|																									|
--+-------------------------------------------------------------------------------------------------+
--|																									|
--|  Revision history :																				|
--|  Date 		  Version	Author	Description														|
--|  2005-05-13   R00A00	PAU		First alfa revision (eng)										|
--|	 2006-01-05   R00B00    MS      inverted reset nres 											|
--|                                 and added debug signals debug_init and debug_access             |																								|
--|																									|
--|  To do:																 							|
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

entity pci32tlite is
generic (

	vendorID 		: std_logic_vector(15 downto 0) := x"10EE";
	deviceID 		: std_logic_vector(15 downto 0) := x"0100";
	revisionID 		: std_logic_vector(7 downto 0) 	:= x"37";
	subsystemID 	: std_logic_vector(15 downto 0) := x"1558";
   	subsystemvID 	: std_logic_vector(15 downto 0) := x"0480";
		jcarr1ID 		: std_logic_vector(31 downto 0) := x"12345671";
		jcarr2ID 		: std_logic_vector(31 downto 0) := x"12345672";
		jcarr3ID 		: std_logic_vector(31 downto 0) := x"12345673";
		jcarr4ID 		: std_logic_vector(31 downto 0) := x"12345674";
		jcarr5ID 		: std_logic_vector(31 downto 0) := x"12345675";
		jcarr6ID 		: std_logic_vector(31 downto 0) := x"12345676";
		jcarr7ID 		: std_logic_vector(31 downto 0) := x"12345677";
		jcarr8ID 		: std_logic_vector(31 downto 0) := x"12345678";
		jcarr9ID 		: std_logic_vector(31 downto 0) := x"12345679";
		jcarr10ID 		: std_logic_vector(31 downto 0) := x"12345680";
		jcarr11ID 		: std_logic_vector(31 downto 0) := x"12345681";
		jcarr12ID 		: std_logic_vector(31 downto 0) := x"12345682";
		jcarr13ID 		: std_logic_vector(31 downto 0) := x"12345683";
		jcarr14ID 		: std_logic_vector(31 downto 0) := x"12345684";
		jcarr15ID 		: std_logic_vector(31 downto 0) := x"12345685";
		jcarr16ID 		: std_logic_vector(31 downto 0) := x"12345686";
		jcarr17ID 		: std_logic_vector(31 downto 0) := x"12345687";
		jcarr18ID 		: std_logic_vector(31 downto 0) := x"12345688";
		jcarr19ID 		: std_logic_vector(31 downto 0) := x"12345689";
		jcarr20ID 		: std_logic_vector(31 downto 0) := x"12345690";
		jcarr21ID 		: std_logic_vector(31 downto 0) := x"12345691";
		jcarr22ID 		: std_logic_vector(31 downto 0) := x"12345692";
		jcarr23ID 		: std_logic_vector(31 downto 0) := x"12345693";
		jcarr24ID 		: std_logic_vector(31 downto 0) := x"12345694";
		jcarr25ID 		: std_logic_vector(31 downto 0) := x"12345695";
		jcarr26ID 		: std_logic_vector(31 downto 0) := x"12345696";
		jcarr27ID 		: std_logic_vector(31 downto 0) := x"12345697";
		jcarr28ID 		: std_logic_vector(31 downto 0) := x"12345698";
		jcarr29ID 		: std_logic_vector(31 downto 0) := x"12345699";
		jcarr30ID 		: std_logic_vector(31 downto 0) := x"12345700";
		jcarr31ID 		: std_logic_vector(31 downto 0) := x"12345701";
		jcarr32ID 		: std_logic_vector(31 downto 0) := x"12345702";
		jcarr33ID 		: std_logic_vector(31 downto 0) := x"12345703";
		jcarr34ID 		: std_logic_vector(31 downto 0) := x"12345704";
		jcarr35ID 		: std_logic_vector(31 downto 0) := x"12345705";
		jcarr36ID 		: std_logic_vector(31 downto 0) := x"12345706";
		jcarr37ID 		: std_logic_vector(31 downto 0) := x"12345707";
		jcarr38ID 		: std_logic_vector(31 downto 0) := x"12345708";
		jcarr39ID 		: std_logic_vector(31 downto 0) := x"12345709";
		jcarr40ID 		: std_logic_vector(31 downto 0) := x"12345710";
		jcarr41ID 		: std_logic_vector(31 downto 0) := x"12345711";
		jcarr42ID 		: std_logic_vector(31 downto 0) := x"12345712"

);
port (

    -- General 
    clk33       : in std_logic;
    nrst	    : in std_logic;
    
    -- PCI target 32bits
    ad          : inout std_logic_vector(31 downto 0);
    cbe         : in std_logic_vector(3 downto 0);
    par         : out std_logic;  
    frame       : in std_logic;
    irdy        : in std_logic;
    trdy        : out std_logic;
    devsel      : out std_logic;
    stop        : out std_logic;
    idsel       : in std_logic;
    perr        : out std_logic;
    serr        : out std_logic;
    intb        : out std_logic;
      
	-- Master whisbone
    wb_adr_o     : out std_logic_vector(24 downto 1);     
	wb_dat_i     : in std_logic_vector(15 downto 0);
    wb_dat_o     : out std_logic_vector(15 downto 0);
	wb_sel_o     : out std_logic_vector(1 downto 0);
    wb_we_o      : out std_logic;
	wb_stb_o     : inout std_logic;
	wb_cyc_o     : out std_logic;
	wb_ack_i     : in std_logic;
	wb_err_i     : in std_logic;
	wb_int_i     : in std_logic;

	-- debug signals
	debug_init	 : out std_logic;
	debug_access : out std_logic 

);
end pci32tlite;


--+-----------------------------------------------------------------------------+
--|									ARCHITECTURE								|
--+-----------------------------------------------------------------------------+

architecture rtl of pci32tlite is


--+-----------------------------------------------------------------------------+
--|									COMPONENTS									|
--+-----------------------------------------------------------------------------+


	component pcidec_new
	port (
	
	    clk_i       	: in std_logic;
   		nrst_i       	: in std_logic;
		--
		ad_i			: in std_logic_vector(31 downto 0);
		cbe_i			: in std_logic_vector(3 downto 0);
		idsel_i    	 	: in std_logic;
		bar0_i        	: in std_logic_vector(31 downto 25);
		memEN_i			: in std_logic;
		pciadrLD_i	   	: in std_logic;
		adrcfg_o		: out std_logic;
		adrmem_o		: out std_logic;
		adr_o			: out std_logic_vector(24 downto 1);
		cmd_o			: out std_logic_vector(3 downto 0)
		
	);
	end component;

	
	component pciwbsequ
	port (
	
   		-- General 
	    clk_i       	: in std_logic;
   		nrst_i       	: in std_logic;
		-- pci 
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
		pcidOE_o		: out std_logic;
		parOE_o			: out std_logic;		
		wbdatLD_o   	: out std_logic;
		wbrgdMX_o		: out std_logic;
		wbd16MX_o		: out std_logic;
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
		debug_init	 	: out std_logic;
		debug_access 	: out std_logic
	);
	end component;


	component pcidmux
	port (
	
	    clk_i       	: in std_logic;
   		nrst_i       	: in std_logic;
		--
		d_io			: inout std_logic_vector(31 downto 0);
		pcidatout_o		: out std_logic_vector(31 downto 0);
		pcidOE_i		: in std_logic;
		wbdatLD_i		: in std_logic;
		wbrgdMX_i		: in std_logic;
		wbd16MX_i		: in std_logic;
		wb_dat_i		: in std_logic_vector(15 downto 0);
		wb_dat_o		: out std_logic_vector(15 downto 0);
		rg_dat_i		: in std_logic_vector(31 downto 0);
		rg_dat_o		: out std_logic_vector(31 downto 0)
				
	);
	end component;


	component pciregs
	generic (

		vendorID : std_logic_vector(15 downto 0);
		deviceID : std_logic_vector(15 downto 0);
		revisionID : std_logic_vector(7 downto 0);
		subsystemID : std_logic_vector(15 downto 0);
    	subsystemvID : std_logic_vector(15 downto 0);
		jcarr1ID 	: std_logic_vector(31 downto 0);
		jcarr2ID 	: std_logic_vector(31 downto 0);
		jcarr3ID 	: std_logic_vector(31 downto 0);
		jcarr4ID 	: std_logic_vector(31 downto 0);
		jcarr5ID 	: std_logic_vector(31 downto 0);
		jcarr6ID 	: std_logic_vector(31 downto 0);
		jcarr7ID 	: std_logic_vector(31 downto 0);
		jcarr8ID 	: std_logic_vector(31 downto 0);
		jcarr9ID 	: std_logic_vector(31 downto 0);
		jcarr10ID 	: std_logic_vector(31 downto 0);
		jcarr11ID 	: std_logic_vector(31 downto 0);
		jcarr12ID 	: std_logic_vector(31 downto 0);
		jcarr13ID 	: std_logic_vector(31 downto 0);
		jcarr14ID 	: std_logic_vector(31 downto 0);
		jcarr15ID 	: std_logic_vector(31 downto 0);
		jcarr16ID 	: std_logic_vector(31 downto 0);
		jcarr17ID 	: std_logic_vector(31 downto 0);
		jcarr18ID 	: std_logic_vector(31 downto 0);
		jcarr19ID 	: std_logic_vector(31 downto 0);
		jcarr20ID 	: std_logic_vector(31 downto 0);
		jcarr21ID 	: std_logic_vector(31 downto 0);
		jcarr22ID 	: std_logic_vector(31 downto 0);
		jcarr23ID 	: std_logic_vector(31 downto 0);
		jcarr24ID 	: std_logic_vector(31 downto 0);
		jcarr25ID 	: std_logic_vector(31 downto 0);
		jcarr26ID 	: std_logic_vector(31 downto 0);
		jcarr27ID 	: std_logic_vector(31 downto 0);
		jcarr28ID 	: std_logic_vector(31 downto 0);
		jcarr29ID 	: std_logic_vector(31 downto 0);
		jcarr30ID 	: std_logic_vector(31 downto 0);
		jcarr31ID 	: std_logic_vector(31 downto 0);
		jcarr32ID 	: std_logic_vector(31 downto 0);
		jcarr33ID 	: std_logic_vector(31 downto 0);
		jcarr34ID 	: std_logic_vector(31 downto 0);
		jcarr35ID 	: std_logic_vector(31 downto 0);
		jcarr36ID 	: std_logic_vector(31 downto 0);
		jcarr37ID 	: std_logic_vector(31 downto 0);
		jcarr38ID 	: std_logic_vector(31 downto 0);
		jcarr39ID 	: std_logic_vector(31 downto 0);
		jcarr40ID 	: std_logic_vector(31 downto 0);
		jcarr41ID 	: std_logic_vector(31 downto 0);
		jcarr42ID 	: std_logic_vector(31 downto 0)

	);
	port (
	
	    clk_i       	: in std_logic;
   		nrst_i       	: in std_logic;
		--
		adr_i			: in std_logic_vector(7 downto 2);
		cbe_i			: in std_logic_vector(3 downto 0);
		dat_i			: in std_logic_vector(31 downto 0);
		dat_o			: out std_logic_vector(31 downto 0);
   		wrcfg_i       	: in std_logic;
   		rdcfg_i       	: in std_logic;
   		perr_i       	: in std_logic;
   		serr_i       	: in std_logic;
   		tabort_i       	: in std_logic;
		bar0_o			: out std_logic_vector(31 downto 25);
		perrEN_o		: out std_logic;
		serrEN_o		: out std_logic;
		memEN_o			: out std_logic
				
	);
	end component;


	component pcipargen
	port (

		clk_i			: in std_logic;
		pcidatout_i		: in std_logic_vector(31 downto 0);
		cbe_i			: in std_logic_vector(3 downto 0);
		parOE_i 		: in std_logic;
		par_o			: out std_logic
	
	);   
	end component;


--+-----------------------------------------------------------------------------+
--|									CONSTANTS  									|
--+-----------------------------------------------------------------------------+
--+-----------------------------------------------------------------------------+
--|									SIGNALS   									|
--+-----------------------------------------------------------------------------+

	signal bar0			: std_logic_vector(31 downto 25);
	signal memEN		: std_logic;
	signal pciadrLD		: std_logic;
	signal adrcfg		: std_logic;
	signal adrmem		: std_logic;
	signal adr			: std_logic_vector(24 downto 1);
	signal cmd			: std_logic_vector(3 downto 0);
	signal pcidOE		: std_logic;
	signal parOE		: std_logic;	
	signal wbdatLD		: std_logic;
	signal wbrgdMX		: std_logic;
	signal wbd16MX		: std_logic;
	signal wrcfg		: std_logic;
	signal rdcfg		: std_logic;
	signal pcidatread	: std_logic_vector(31 downto 0);
	signal pcidatwrite	: std_logic_vector(31 downto 0);
	signal pcidatout	: std_logic_vector(31 downto 0);	
	signal parerr		: std_logic;
	signal syserr		: std_logic;
	signal tabort		: std_logic;
	signal perrEN		: std_logic;
	signal serrEN		: std_logic;
			
begin


    --+-------------------------------------------------------------------------+
    --|  Component instances													|
    --+-------------------------------------------------------------------------+

	--+-----------------------------------------+
	--|  PCI decoder							|
	--+-----------------------------------------+

	u1: component pcidec_new
	port map (

	    clk_i   	=> clk33,
   		nrst_i 		=> nrst,
		--
		ad_i		=> ad,
		cbe_i		=> cbe,
		idsel_i    	=> idsel,
		bar0_i      => bar0,
		memEN_i		=> memEN,
		pciadrLD_i	=> pciadrLD,	
		adrcfg_o	=> adrcfg,
		adrmem_o	=> adrmem,
		adr_o		=> adr,
		cmd_o		=> cmd
		
	);


	--+-----------------------------------------+
	--|  PCI-WB Sequencer						|
	--+-----------------------------------------+

	u2: component pciwbsequ 
	port map (

   		-- General 
	    clk_i 		=> clk33,     	
   		nrst_i      => nrst,
		-- pci 
		cmd_i			=> cmd,
		cbe_i			=> cbe,
		frame_i    		=> frame,
		irdy_i      	=> irdy,	
		devsel_o		=> devsel,
		trdy_o      	=> trdy, 	
		-- control
		adrcfg_i		=> adrcfg,
		adrmem_i 		=> adrmem,
		pciadrLD_o		=> pciadrLD,
		pcidOE_o		=> pcidOE,
		parOE_o			=> parOE,    
		wbdatLD_o   	=> wbdatLD,
		wbrgdMX_o		=> wbrgdMX,
		wbd16MX_o		=> wbd16MX,
		wrcfg_o 		=> wrcfg,
		rdcfg_o 		=> rdcfg,
		-- whisbone
		wb_sel_o		=> wb_sel_o,
		wb_we_o			=> wb_we_o,
		wb_stb_o		=> wb_stb_o,
		wb_cyc_o		=> wb_cyc_o,
		wb_ack_i		=> wb_ack_i,
		wb_err_i		=> wb_err_i,
		-- debug signals
		debug_init		=> debug_init, 
		debug_access 	=> debug_access
	);
   

	--+-----------------------------------------+
	--|  PCI-wb datamultiplexer					|
	--+-----------------------------------------+

	u3: component pcidmux
	port map (

	    clk_i   	=> clk33,
   		nrst_i  	=> nrst,
		--
		d_io		=> ad,	
		pcidatout_o	=> pcidatout,	
		pcidOE_i	=> pcidOE,
		wbdatLD_i	=> wbdatLD,
		wbrgdMX_i	=> wbrgdMX,
		wbd16MX_i	=> wbd16MX,
		wb_dat_i	=> wb_dat_i,
		wb_dat_o	=> wb_dat_o,
		rg_dat_i	=> pcidatread,
		rg_dat_o	=> pcidatwrite
			
	);


	--+-----------------------------------------+
	--|  PCI registers							|
	--+-----------------------------------------+

	u4: component pciregs
	generic map (

		vendorID 		=> vendorID,
		deviceID 		=> deviceID,
		revisionID 		=> revisionID,
		subsystemID 	=> subsystemID,
    	subsystemvID 	=> subsystemvID,
		jcarr1ID 	=> jcarr1ID,
		jcarr2ID 	=> jcarr2ID,
		jcarr3ID 	=> jcarr3ID,
		jcarr4ID 	=> jcarr4ID,
		jcarr5ID 	=> jcarr5ID,
		jcarr6ID 	=> jcarr6ID,
		jcarr7ID 	=> jcarr7ID,
		jcarr8ID 	=> jcarr8ID,
		jcarr9ID 	=> jcarr9ID,
		jcarr10ID 	=> jcarr10ID,
		jcarr11ID 	=> jcarr11ID,
		jcarr12ID 	=> jcarr12ID,
		jcarr13ID 	=> jcarr13ID,
		jcarr14ID 	=> jcarr14ID,
		jcarr15ID 	=> jcarr15ID,
		jcarr16ID 	=> jcarr16ID,
		jcarr17ID 	=> jcarr17ID,
		jcarr18ID 	=> jcarr18ID,
		jcarr19ID 	=> jcarr19ID,
		jcarr20ID 	=> jcarr20ID,
		jcarr21ID 	=> jcarr21ID,
		jcarr22ID 	=> jcarr22ID,
		jcarr23ID 	=> jcarr23ID,
		jcarr24ID 	=> jcarr24ID,
		jcarr25ID 	=> jcarr25ID,
		jcarr26ID 	=> jcarr26ID,
		jcarr27ID 	=> jcarr27ID,
		jcarr28ID 	=> jcarr28ID,
		jcarr29ID 	=> jcarr29ID,
		jcarr30ID 	=> jcarr30ID,
		jcarr31ID 	=> jcarr31ID,
		jcarr32ID 	=> jcarr32ID,
		jcarr33ID 	=> jcarr33ID,
		jcarr34ID 	=> jcarr34ID,
		jcarr35ID 	=> jcarr35ID,
		jcarr36ID 	=> jcarr36ID,
		jcarr37ID 	=> jcarr37ID,
		jcarr38ID 	=> jcarr38ID,
		jcarr39ID 	=> jcarr39ID,
		jcarr40ID 	=> jcarr40ID,
		jcarr41ID 	=> jcarr41ID,
		jcarr42ID 	=> jcarr42ID

	)
	port map (

	    clk_i   	=> clk33,
   		nrst_i  	=> nrst,
		--
		adr_i		=> adr(7 downto 2),
		cbe_i		=> cbe,
		dat_i		=> pcidatwrite,
		dat_o		=> pcidatread,
   		wrcfg_i     => wrcfg,
   		rdcfg_i     => rdcfg,
   		perr_i      => parerr,
   		serr_i      => syserr,
   		tabort_i    => tabort,
		bar0_o		=> bar0,
		perrEN_o	=> perrEN,
		serrEN_o	=> serrEN,
		memEN_o		=> memEN
					
	);
	
	--+-----------------------------------------+
	--|  PCI Parity Gnerator					|
	--+-----------------------------------------+

	u5: component pcipargen
	port map (

	    clk_i   	=> clk33,
		pcidatout_i	=> pcidatout,	
		cbe_i		=> cbe,
		parOE_i		=> parOE,	
		par_o		=> par
					
	);


	--+-----------------------------------------+
	--|  Whisbone Address bus					|
	--+-----------------------------------------+
	
	wb_adr_o <= adr;


	--+-----------------------------------------+
	--|  unimplemented							|
	--+-----------------------------------------+

	parerr 	<= '0';
	syserr 	<= '0';
	tabort 	<= '0';


	--+-----------------------------------------+
	--|  unused outputs							|
	--+-----------------------------------------+
	-- #stop: Curret TARGET indicates to Master stop current transaction
	-- #perr:
	-- #serr:
	
	perr 	<= 'Z';
	serr	<= 'Z';
	stop	<= 'Z';
	intb	<= '0' when ( wb_int_i = '1' ) else 'Z';

		
end rtl;


