--+-------------------------------------------------------------------------------------------------+
--|																									|
--|  File:			top.vhd                       		                                   	|
--|																									|
--|  Components:	pci32lite.vhd                                                                   |
--|		            pciwbsequ.vhd           														|
--|		            pcidmux.vhd           															|
--|		            pciregs.vhd           															|
--|		            pcipargen.vhd          															|
--|		            -- Libs --             															|
--|		            ona.vhd		          															|
--|																									|
--|	 Description:	RS1 PCI Demo : (TOP) Main file.						 				        |
--| 				 																				|
--|					                														        |
--|																									|
--+-------------------------------------------------------------------------------------------------+
--|																									|
--|  Revision history :																				|
--|  Date 		  Version	Author	Description														|
--|																									|
--|																									|
--|  To do:																 							|
--|																									|
--+-------------------------------------------------------------------------------------------------+


--+-----------------------------------------------------------------------------+
--|									LIBRARIES									|
--+-----------------------------------------------------------------------------+

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

--+-----------------------------------------------------------------------------+
--|									ENTITY   									|
--+-----------------------------------------------------------------------------+

entity pci_7seg is
port (

    -- General 
    PCI_CLK     : in std_logic;
    PCI_nRES    : in std_logic;
    
    -- PCI target 32bits
    PCI_AD      : inout std_logic_vector(31 downto 0);
    PCI_CBE     : in std_logic_vector(3 downto 0);
    PCI_PAR     : out std_logic;  
    PCI_nFRAME  : in std_logic;
    PCI_nIRDY   : in std_logic;
    PCI_nTRDY   : out std_logic;
    PCI_nDEVSEL : out std_logic;
    PCI_nSTOP   : out std_logic;
    PCI_IDSEL   : in std_logic;
    PCI_nPERR   : out std_logic;
    PCI_nSERR   : out std_logic;
    PCI_nINT    : out std_logic;
 
	-- 7seg
    DISP_SEL                : inout std_logic_vector(3 downto 0);
    DISP_LED                : out std_logic_vector(6 downto 0);
	
	-- debug signals
	LED_INIT	 : out std_logic;
	LED_ACCESS	 : out std_logic;
	LED_ALIVE : out std_logic;

	-- vga signals
	hs             : out std_logic;
	vs             : out std_logic;
	red, grn, blu  : out std_logic;
	mclk           : in std_logic

);
end pci_7seg;


--+-----------------------------------------------------------------------------+
--|									ARCHITECTURE								|
--+-----------------------------------------------------------------------------+

architecture pci_7seg_arch of pci_7seg is


--+-----------------------------------------------------------------------------+
--|									COMPONENTS									|
--+-----------------------------------------------------------------------------+

component pci32tlite
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
	wb_stb_o     : out std_logic;
	wb_cyc_o     : out std_logic;
	wb_ack_i     : in std_logic;
	wb_err_i     : in std_logic;
	wb_int_i     : in std_logic;

	-- debug signals
	debug_init	 : out std_logic;
	debug_access : out std_logic 

	);
end component;


component wb_7seg_new
port (
   
   -- General 
    clk_i      : in std_logic;
    nrst_i	   : in std_logic;
    
	-- Master whisbone
    wb_adr_i   : in std_logic_vector(24 downto 1);     
	wb_dat_o   : out std_logic_vector(15 downto 0);
    wb_dat_i   : in std_logic_vector(15 downto 0);
	wb_sel_i   : in std_logic_vector(1 downto 0);
    wb_we_i    : in std_logic;
	wb_stb_i   : in std_logic;
	wb_cyc_i   : in std_logic;
	wb_ack_o   : out std_logic;
	wb_err_o   : out std_logic;
	wb_int_o   : out std_logic;

	-- 7seg
    DISP_SEL   : inout std_logic_vector(3 downto 0);
    DISP_LED   : out std_logic_vector(6 downto 0)

   );
end component;


component vgaController is
        Port ( mclk : in std_logic;
           hs : out std_logic;
           vs : out std_logic;
           red : out std_logic;
           grn : out std_logic;
           blu : out std_logic);
end component;


--+-----------------------------------------------------------------------------+
--|									CONSTANTS  									|
--+-----------------------------------------------------------------------------+
--+-----------------------------------------------------------------------------+
--|									SIGNALS   									|
--+-----------------------------------------------------------------------------+

	signal 	wb_adr :		std_logic_vector(24 downto 1);   
	signal	wb_dat_out :	std_logic_vector(15 downto 0);
 	signal 	wb_dat_in :		std_logic_vector(15 downto 0);
	signal	wb_sel :		std_logic_vector(1 downto 0);
 	signal  wb_we :			std_logic;
	signal	wb_stb :		std_logic;
	signal	wb_cyc :		std_logic;
	signal	wb_ack :		std_logic;
	signal	wb_err :		std_logic;
	signal	wb_int :		std_logic;


begin

			 LED_ALIVE <= '1';
--+-------------------------------------------------------------------------+
--|  Component instances													|
--+-------------------------------------------------------------------------+

	vga1: vgaController port map (mclk => mclk,
		hs => hs,
		vs => vs,
		red => red,
		grn => grn,
		blu => blu);

--+-----------------------------------------+
--|  PCI Target 							|
--+-----------------------------------------+

u_pci: component pci32tlite
port map(
    	clk33 =>		PCI_CLK,
    	nrst =>			PCI_nRES,
    	ad =>			PCI_AD,
    	cbe =>			PCI_CBE,
    	par =>			PCI_PAR,
    	frame =>		PCI_nFRAME,
    	irdy =>     	PCI_nIRDY,
    	trdy =>     	PCI_nTRDY,
    	devsel =>   	PCI_nDEVSEL,
    	stop =>     	PCI_nSTOP,
    	idsel =>    	PCI_IDSEL,
    	perr =>     	PCI_nPERR,
    	serr =>     	PCI_nSERR,
    	intb =>     	PCI_nINT,
    	wb_adr_o =>		wb_adr,	   
		wb_dat_i =>		wb_dat_out,
    	wb_dat_o =>  	wb_dat_in,
		wb_sel_o =>		wb_sel,		
    	wb_we_o =>		wb_we,
		wb_stb_o =>		wb_stb,	
		wb_cyc_o =>		wb_cyc,
		wb_ack_i =>		wb_ack,
		wb_err_i =>		wb_err,
		wb_int_i =>		wb_int,
		debug_init =>	LED_INIT,
		debug_access =>	LED_ACCESS
		);

--+-----------------------------------------+
--|  WB-7seg             					|
--+-----------------------------------------+

u_wb: component wb_7seg_new
port map(
		clk_i    =>		PCI_CLK,
    	nrst_i   =>		PCI_nRES,
    	wb_adr_i =>		wb_adr,   
		wb_dat_o =>		wb_dat_out,
    	wb_dat_i =>		wb_dat_in,
		wb_sel_i =>		wb_sel,
    	wb_we_i  => 	wb_we,
		wb_stb_i =>		wb_stb,
		wb_cyc_i =>		wb_cyc,
		wb_ack_o =>		wb_ack,
		wb_err_o =>		wb_err,
		wb_int_o =>		wb_int,
		DISP_SEL =>		DISP_SEL,
		DISP_LED =>		DISP_LED
);

end pci_7seg_arch;
