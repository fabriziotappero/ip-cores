-----------------------------------------------------------------------------
--  LEON3 Demonstration design
--  Copyright (C) 2004 Jiri Gaisler, Gaisler Research
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;
library techmap;
use techmap.gencomp.all;
library gaisler;
use gaisler.memctrl.all;
use gaisler.leon3.all;
use gaisler.uart.all;
use gaisler.misc.all;
use gaisler.can.all;
use gaisler.pci.all;
use gaisler.net.all;
use gaisler.jtag.all;
use gaisler.spacewire.all;
library esa;
use esa.memoryctrl.all;
use esa.pcicomp.all;

use work.config.all;

entity leon3core is
  generic (
    fabtech   : integer := CFG_FABTECH;
    memtech   : integer := CFG_MEMTECH;
    padtech   : integer := CFG_PADTECH;
    clktech   : integer := CFG_CLKTECH;
    disas     : integer := CFG_DISAS;	-- Enable disassembly to console
    dbguart   : integer := CFG_DUART;	-- Print UART on console
    pclow     : integer := CFG_PCLOW;
    scantest  : integer := 0
  );
  port (
    resetn	: in  std_ulogic;
    clkin	: in  std_ulogic;
    errorn	: out std_ulogic;
    address 	: out std_logic_vector(27 downto 0);
    datain	: in std_logic_vector(31 downto 0);
    dataout	: out std_logic_vector(31 downto 0);
    dataen 	: out std_logic_vector(31 downto 0);
    cbin   	: in std_logic_vector(7 downto 0);
    cbout   	: out std_logic_vector(7 downto 0);
    cben   	: out std_logic_vector(7 downto 0);
    sdcsn  	: out std_logic_vector (1 downto 0);    -- sdram chip select
    sdwen  	: out std_ulogic;                       -- sdram write enable
    sdrasn  	: out std_ulogic;                       -- sdram ras
    sdcasn  	: out std_ulogic;                       -- sdram cas
    sddqm   	: out std_logic_vector (3 downto 0);    -- sdram dqm
    dsutx  	: out std_ulogic; 			-- DSU tx data
    dsurx  	: in  std_ulogic;  			-- DSU rx data
    dsuen   	: in std_ulogic;
    dsubre  	: in std_ulogic;
    dsuact  	: out std_ulogic;
    txd1   	: out std_ulogic; 			-- UART1 tx data
    rxd1   	: in  std_ulogic;  			-- UART1 rx data
    ramsn  	: out std_logic_vector (4 downto 0);
    ramoen 	: out std_logic_vector (4 downto 0);
    rwen   	: out std_logic_vector (3 downto 0);
    oen    	: out std_ulogic;
    writen 	: out std_ulogic;
    read   	: out std_ulogic;
    iosn   	: out std_ulogic;
    romsn  	: out std_logic_vector (1 downto 0);
    brdyn  	: in  std_ulogic;
    bexcn  	: in  std_ulogic;
    wdogn  	: out std_ulogic;
    gpioin      : in std_logic_vector(CFG_GRGPIO_WIDTH-1 downto 0); 	-- I/O port
    gpioout     : out std_logic_vector(CFG_GRGPIO_WIDTH-1 downto 0); 	-- I/O port
    gpioen      : out std_logic_vector(CFG_GRGPIO_WIDTH-1 downto 0); 	-- I/O port
    writefb	: in  std_ulogic;

    emdi     	: in    std_logic;		-- ethernet PHY interface
    emdo     	: out std_logic;		-- ethernet PHY interface
    emden     	: out std_logic;		-- ethernet PHY interface
    etx_clk 	: in std_ulogic;
    erx_clk 	: in std_ulogic;
    erxd    	: in std_logic_vector(3 downto 0);   
    erx_dv  	: in std_ulogic; 
    erx_er  	: in std_ulogic; 
    erx_col 	: in std_ulogic;
    erx_crs 	: in std_ulogic;
    etxd 	: out std_logic_vector(3 downto 0);   
    etx_en 	: out std_ulogic; 
    etx_er 	: out std_ulogic; 
    emdc 	: out std_ulogic;

    pciclk 	: in std_ulogic;
    pcii_rst 	: in std_ulogic;
    pcii_gnt 	: in std_ulogic;
    pcii_idsel 	: in std_ulogic;
    pcii_ad 	: in std_logic_vector(31 downto 0);
    pcii_cbe 	: in std_logic_vector(3 downto 0);
    pcii_frame	: in std_ulogic;
    pcii_irdy   : in std_ulogic;
    pcii_trdy   : in std_ulogic;
    pcii_devsel : in std_ulogic;
    pcii_stop   : in std_ulogic;
    pcii_perr   : in std_ulogic;
    pcii_par 	: in std_ulogic;
    pcii_host   : in std_ulogic;

    pcio_vaden   : out std_logic_vector(31 downto 0);
    pcio_cbeen   : out std_logic_vector(3 downto 0);
    pcio_frameen : out std_ulogic;
    pcio_irdyen  : out std_ulogic;
    pcio_trdyen  : out std_ulogic;
    pcio_devselen:  out std_ulogic;
    pcio_stopen : out std_ulogic;
    pcio_perren : out std_ulogic;
    pcio_paren 	: out std_ulogic;
    pcio_reqen	: out std_ulogic;
    pcio_locken : out std_ulogic;
    pcio_req    : out std_ulogic;
    pcio_ad 	: out std_logic_vector(31 downto 0);
    pcio_cbe 	: out std_logic_vector(3 downto 0);
    pcio_frame  : out std_ulogic;
    pcio_irdy   : out std_ulogic;
    pcio_trdy   : out std_ulogic;
    pcio_devsel : out std_ulogic;
    pcio_stop   : out std_ulogic;
    pcio_perr   : out std_ulogic;
    pcio_par    : out std_ulogic;

    pcii_arb_req: in  std_logic_vector(0 to CFG_PCI_ARB_NGNT-1);
    pcio_arb_gnt: out std_logic_vector(0 to CFG_PCI_ARB_NGNT-1);

    can_tx      : out std_logic_vector(0 to CFG_CAN_NUM-1);
    can_rx      : in  std_logic_vector(0 to CFG_CAN_NUM-1);

    spw_clk	: in  std_ulogic;
    spw_rxd     : in  std_logic_vector(0 to CFG_SPW_NUM-1);
    spw_rxs     : in  std_logic_vector(0 to CFG_SPW_NUM-1);
    spw_txd     : out std_logic_vector(0 to CFG_SPW_NUM-1);
    spw_txs     : out std_logic_vector(0 to CFG_SPW_NUM-1);
    spw_ten     : out std_logic_vector(0 to CFG_SPW_NUM-1);

    tck         : in std_ulogic;
    tms         : in std_ulogic;
    tdi         : in std_ulogic;
    tdo         : out std_ulogic;
    trst        : in std_ulogic;

    scanin	: in  std_ulogic;
    scanenable 	: in  std_ulogic;
    testenable 	: in  std_ulogic;
    testrst    	: in  std_ulogic;
    scanout  	: out std_ulogic;
    sdclk    	: out std_ulogic;
    pllref   	: in std_ulogic
	);
end;

architecture rtl of leon3core is

constant blength : integer := 12;

constant CFG_NCLKS : integer := 7;
constant maxahbmsp : integer := CFG_NCPU+CFG_AHB_UART+log2x(CFG_PCI)+CFG_AHB_JTAG+CFG_GRETH;
constant maxahbm : integer := (CFG_SPW_NUM*CFG_SPW_EN) + maxahbmsp;

signal vcc, gnd : std_logic_vector(4 downto 0);
signal gclk, grst : std_logic_vector(CFG_NCLKS-1 downto 0);
signal cpuclk, pwd : std_logic_vector(CFG_NCPU-1 downto 0);
signal memi  : memory_in_type;
signal memo  : memory_out_type;
signal wpo   : wprot_out_type;
signal sdi   : sdctrl_in_type;
signal sdo   : sdram_out_type;
signal sdo2, sdo3 : sdctrl_out_type;

signal clkm, lclk, sdclkl, clk2x : std_ulogic;
signal cgi   : clkgen_in_type;
signal cgo   : clkgen_out_type;

signal apbi  : apb_slv_in_type;
signal apbo  : apb_slv_out_vector := (others => apb_none);
signal ahbsi : ahb_slv_in_type;
signal ahbso : ahb_slv_out_vector := (others => ahbs_none);
signal ahbmi : ahb_mst_in_type;
signal ahbmo : ahb_mst_out_vector := (others => ahbm_none);

signal rstn, rstraw : std_ulogic;
signal u1i, u2i, dui : uart_in_type;
signal u1o, u2o, duo : uart_out_type;

signal irqi : irq_in_vector(0 to CFG_NCPU-1);
signal irqo : irq_out_vector(0 to CFG_NCPU-1);

signal dbgi : l3_debug_in_vector(0 to CFG_NCPU-1);
signal dbgo : l3_debug_out_vector(0 to CFG_NCPU-1);

signal dsui : dsu_in_type;
signal dsuo : dsu_out_type; 

signal pcii : pci_in_type;
signal pcio : pci_out_type;

signal ethi, ethi1, ethi2 : eth_in_type;
signal etho, etho1, etho2 : eth_out_type;

signal gpti : gptimer_in_type;
signal gpto : gptimer_out_type;

signal gpioi, gpioi2 : gpio_in_type;
signal gpioo, gpioo2 : gpio_out_type;

--signal tck, tms, tdi, tdo : std_ulogic;

signal spwi : grspw_in_type_vector(0 to CFG_SPW_NUM-1);
signal spwo : grspw_out_type_vector(0 to CFG_SPW_NUM-1);
signal stati : ahbstat_in_type;
signal can_lrx, can_ltx   : std_logic_vector(0 to 7);
signal clk   : std_ulogic;
signal clklock	: std_ulogic;

constant IOAEN : integer := CFG_CAN;
constant CFG_SDEN : integer := CFG_MCTRLFT_SDEN + CFG_MCTRL_SDEN;
constant CFG_INVCLK : integer := CFG_MCTRLFT_INVCLK + CFG_MCTRL_INVCLK;

constant BOARD_FREQ : integer := 50000;	-- Board frequency in KHz

constant sysfreq : integer := (CFG_CLKMUL*50000/CFG_CLKDIV);
constant OEPOL : integer := padoen_polarity(padtech);
constant notag : integer := 0;
constant CPU_FREQ : integer := 100000;

attribute sync_set_reset : string;
attribute sync_set_reset of rstn : signal is "true";

attribute syn_keep : boolean;
attribute syn_preserve : boolean;
attribute syn_keep of clk2x : signal is true;
attribute syn_preserve of clk2x : signal is true;
attribute syn_keep of clkm : signal is true;
attribute syn_preserve of clkm : signal is true;

begin

--  scan : entity work.scan_dummy
--      port map (scanin, scanenable, scanout);

----------------------------------------------------------------------
---  Reset and Clock generation  -------------------------------------
----------------------------------------------------------------------
  
  vcc <= (others => '1'); gnd <= (others => '0');
  memi.edac <= gpioo.val(2);  -- PROM EDAC
  memi.bwidth <= gpioo.val(1 downto 0); -- 32-bit PROM
  wpo.wprothit <= '0'; -- no write protection

  rstgen0 : rstgen			-- reset generator
  generic map (syncrst => CFG_NOASYNC)
  port map (resetn, clk, clklock, rstn, rstraw);

----------------------------------------------------------------------
---  AHB CONTROLLER --------------------------------------------------
----------------------------------------------------------------------

  ahbctrl0 : ahbctrl 		-- AHB arbiter/multiplexer
  generic map (defmast => CFG_DEFMST, split => CFG_SPLIT, 
	rrobin => CFG_RROBIN, ioaddr => CFG_AHBIO, devid => AEROFLEX_UT699,
	ioen => IOAEN, nahbm => maxahbm, nahbs => 8)
  port map (rstn, clk, ahbmi, ahbmo, ahbsi, ahbso, 
		testenable, testrst, scanenable);

----------------------------------------------------------------------
---  LEON3 processor and DSU -----------------------------------------
----------------------------------------------------------------------

  cpu : for i in 0 to CFG_NCPU-1 generate
    l3ft : if CFG_LEON3FT_EN /= 0 generate
      leon3ft0 : leon3ft		-- LEON3 processor      
      generic map (i, fabtech, memtech, CFG_NWIN, CFG_DSU, CFG_FPU, CFG_V8, 
	0, CFG_MAC, pclow, notag, CFG_NWP, CFG_ICEN, CFG_IREPL, CFG_ISETS, CFG_ILINE, 
	CFG_ISETSZ, CFG_ILOCK, CFG_DCEN, CFG_DREPL, CFG_DSETS, CFG_DLINE, CFG_DSETSZ,
	CFG_DLOCK, CFG_DSNOOP, CFG_ILRAMEN, CFG_ILRAMSZ, CFG_ILRAMADDR, CFG_DLRAMEN,
        CFG_DLRAMSZ, CFG_DLRAMADDR, CFG_MMUEN, CFG_ITLBNUM, CFG_DTLBNUM, CFG_TLB_TYPE, CFG_TLB_REP, 
        CFG_LDDEL, disas, CFG_ITBSZ, CFG_PWD, CFG_SVT, CFG_RSTADDR, CFG_NCPU-1,
	CFG_IUFT_EN, CFG_FPUFT_EN, CFG_CACHE_FT_EN, CFG_RF_ERRINJ, 
	CFG_CACHE_ERRINJ, 0, 0, scantest)
      port map (clk, rstn, ahbmi, ahbmo(i), ahbsi, ahbso, 
    		irqi(i), irqo(i), dbgi(i), dbgo(i), cpuclk(i));
    end generate;
    l3s  : if CFG_LEON3FT_EN = 0 generate
      leon3s0 : leon3cg 		-- LEON3 processor      
      generic map (i, fabtech, memtech, CFG_NWIN, CFG_DSU, CFG_FPU, CFG_V8, 
	0, CFG_MAC, pclow, 0, CFG_NWP, CFG_ICEN, CFG_IREPL, CFG_ISETS, CFG_ILINE, 
	CFG_ISETSZ, CFG_ILOCK, CFG_DCEN, CFG_DREPL, CFG_DSETS, CFG_DLINE, CFG_DSETSZ,
	CFG_DLOCK, CFG_DSNOOP, CFG_ILRAMEN, CFG_ILRAMSZ, CFG_ILRAMADDR, CFG_DLRAMEN,
        CFG_DLRAMSZ, CFG_DLRAMADDR, CFG_MMUEN, CFG_ITLBNUM, CFG_DTLBNUM, CFG_TLB_TYPE, CFG_TLB_REP, 
        CFG_LDDEL, disas, CFG_ITBSZ, CFG_PWD, CFG_SVT, CFG_RSTADDR, CFG_NCPU-1)
      port map (clk, rstn, ahbmi, ahbmo(i), ahbsi, ahbso, 
    		irqi(i), irqo(i), dbgi(i), dbgo(i), cpuclk(i));
    end generate;
    pwd(i) <= dsuo.pwd(i);
  end generate;
  errorn <= dbgo(0).error when OEPOL = 0 else not dbgo(0).error;
  
  dsugen : if CFG_DSU = 1 generate
    dsu0 : dsu3			-- LEON3 Debug Support Unit
    generic map (hindex => 2, haddr => 16#900#, hmask => 16#F00#, 
       ncpu => CFG_NCPU, tbits => 30, tech => memtech, irq => 0, kbytes => CFG_ATBSZ)
    port map (rstn, clk, ahbmi, ahbsi, ahbso(2), dbgo, dbgi, dsui, dsuo);
    dsui.enable <= dsuen; dsui.break <= dsubre; dsuact <= dsuo.active;
  end generate;
  nodsu : if CFG_DSU = 0 generate 
    ahbso(2) <= ahbs_none; dsuo.tstop <= '0'; dsuo.active <= '0';
  end generate;

  dcomgen : if CFG_AHB_UART = 1 generate
    ahbuart0: ahbuart		-- Debug UART
    generic map (hindex => CFG_NCPU, pindex => 7, paddr => 7)
    port map (rstn, clk, dui, duo, apbi, apbo(7), ahbmi, ahbmo(CFG_NCPU));
    dui.rxd <= dsurx; dsutx <= duo.txd;
  end generate;
  nouah : if CFG_AHB_UART = 0 generate apbo(7) <= apb_none; end generate;

  ahbjtaggen0 :if CFG_AHB_JTAG = 1 generate
    ahbjtag0 : ahbjtag generic map(tech => fabtech, part => JTAG_UT699RH,
	hindex => CFG_NCPU+CFG_AHB_UART, scantest => scantest)
      port map(rstn, clk, tck, tms, tdi, tdo, ahbmi, ahbmo(CFG_NCPU+CFG_AHB_UART),
               open, open, open, open, open, open, open, gnd(0), trst);
  end generate;
  
----------------------------------------------------------------------
---  Memory controllers ----------------------------------------------
----------------------------------------------------------------------

  address <= memo.address(27 downto 0); 
  ramsn <= memo.ramsn(4 downto 0); romsn <= memo.romsn(1 downto 0); 
  oen <= memo.oen; rwen <= memo.wrn; ramoen <= memo.ramoen(4 downto 0);
  writen <= memo.writen; read <= memo.read; iosn <= memo.iosn;
  dataout <= memo.data(31 downto 0); dataen <= memo.vbdrive(31 downto 0);
  memi.data(31 downto 0) <= datain;
  sdwen <= sdo.sdwen; sdrasn <= sdo.rasn; sdcasn <= sdo.casn;
  sddqm <= sdo.dqm(3 downto 0); sdcsn <= sdo.sdcsn; 
  cbout <= memo.cb(7 downto 0); cben <= memo.vcdrive(7 downto 0);
  memi.cb(7 downto 0) <= cbin;

  mg2 : if CFG_MCTRLFT = 1 generate 	-- FT memory controller
    ftmctrl0 : ftmctrl generic map (hindex => 0, pindex => 0, 
	paddr => 0, srbanks => 4 + CFG_MCTRLFT_5CS, sden => CFG_MCTRLFT_SDEN, 
	ram8 => CFG_MCTRLFT_RAM8BIT, ram16 => CFG_MCTRLFT_RAM16BIT, 
	invclk => CFG_MCTRLFT_INVCLK, sepbus => CFG_MCTRLFT_SEPBUS, 
	oepol => OEPOL, edac => CFG_MCTRLFT_EDAC, syncrst => CFG_NOASYNC,
	pageburst => CFG_MCTRLFT_PAGE, writefb => CFG_MCTRLFT_WFB)
    port map (rstn, clk, memi, memo, ahbsi, ahbso(0), apbi, apbo(0), wpo, sdo);
  end generate;

  mg1 : if CFG_MCTRL_LEON2 = 1 generate 	-- STD memory controller
    mctrl0 : mctrl generic map (hindex => 0, pindex => 0, 
	paddr => 0, srbanks => 4 + CFG_MCTRL_5CS, sden => CFG_MCTRL_SDEN, 
	ram8 => CFG_MCTRL_RAM8BIT, ram16 => CFG_MCTRL_RAM16BIT, 
	invclk => CFG_MCTRL_INVCLK, sepbus => CFG_MCTRL_SEPBUS, 
	oepol => OEPOL, syncrst => CFG_NOASYNC,
	pageburst => CFG_MCTRL_PAGE) --, writefb => CFG_MCTRL_WFB)
    port map (rstn, clk, memi, memo, ahbsi, ahbso(0), apbi, apbo(0), wpo, sdo);
  end generate;

  nosd0 : if (CFG_SDEN = 0) generate	-- no SDRAM controller
    sdo.sdcsn <= (others => '1');
  end generate;

  memi.writen <= writefb; memi.wrn <= "1111"; 
  memi.brdyn <= brdyn; memi.bexcn <= bexcn;

  mg0 : if (CFG_MCTRLFT + CFG_MCTRL_LEON2) = 0 generate	-- None PROM/SRAM controller
    apbo(0) <= apb_none; ahbso(0) <= ahbs_none;
    memo.ramsn <= (others => '1'); memo.romsn <= (others => '1');
  end generate;


----------------------------------------------------------------------
---  APB Bridge and various periherals -------------------------------
----------------------------------------------------------------------

  apbctrl0 : apbctrl				-- AHB/APB bridge
  generic map (hindex => 1, haddr => CFG_APBADDR)
  port map (rstn, clk, ahbsi, ahbso(1), apbi, apbo );

  ua1 : if CFG_UART1_ENABLE /= 0 generate
    apbuart0 : apbuart			-- UART 1
    generic map (pindex => 1, paddr => 1,  pirq => 2, console => dbguart,
	fifosize => CFG_UART1_FIFO)
    port map (rstn, clk, apbi, apbo(1), u1i, u1o);
    u1i.ctsn <= '0'; u1i.extclk <= '0';
    txd1 <= u1o.txd; u1i.rxd <= rxd1;
  end generate;
  noua0 : if CFG_UART1_ENABLE = 0 generate apbo(1) <= apb_none; end generate;

  irqctrl : if CFG_IRQ3_ENABLE /= 0 generate
    irqctrl0 : irqmp			-- interrupt controller
    generic map (pindex => 2, paddr => 2, ncpu => CFG_NCPU)
    port map (rstn, clk, apbi, apbo(2), irqo, irqi);
  end generate;
  irq3 : if CFG_IRQ3_ENABLE = 0 generate
    x : for i in 0 to CFG_NCPU-1 generate
      irqi(i).irl <= "0000";
    end generate;
    apbo(2) <= apb_none;
  end generate;

  gpt : if CFG_GPT_ENABLE /= 0 generate
    gptimer0 : gptimer 			-- timer unit
    generic map (pindex => 3, paddr => 3, pirq => CFG_GPT_IRQ, 
	sepirq => CFG_GPT_SEPIRQ, sbits => CFG_GPT_SW, ntimers => CFG_GPT_NTIM, 
	nbits => CFG_GPT_TW, wdog => CFG_GPT_WDOGEN*CFG_GPT_WDOG)
    port map (rstn, clk, apbi, apbo(3), gpti, gpto);
    gpti.dhalt <= dsuo.tstop; gpti.extclk <= '0';
    wdogn <= gpto.wdogn when OEPOL = 0 else gpto.wdog;
  end generate;
  notim : if CFG_GPT_ENABLE = 0 generate apbo(3) <= apb_none; end generate;

  gpio0 : if CFG_GRGPIO_ENABLE /= 0 generate     -- GR GPIO unit
    grgpio0: grgpio
      generic map( pindex => 9, paddr => 9, imask => CFG_GRGPIO_IMASK, 
	nbits => CFG_GRGPIO_WIDTH, oepol => OEPOL, syncrst => CFG_NOASYNC)
      port map( rstn, clk, apbi, apbo(9), gpioi, gpioo);
    gpioout <= gpioo.dout(CFG_GRGPIO_WIDTH-1 downto 0); 
    gpioen <= gpioo.oen(CFG_GRGPIO_WIDTH-1 downto 0);
    gpioi.din(CFG_GRGPIO_WIDTH-1 downto 0) <= gpioin;
  end generate;
  nogpio : if CFG_GRGPIO_ENABLE = 0 generate apbo(5) <= apb_none; end generate;

    cgi.pllctrl <= "00"; cgi.pllrst <= resetn;
    pllref_pad : clkpad generic map (tech => padtech) port map (pllref, cgi.pllref); 
--    clk_pad : clkpad generic map (tech => padtech) port map (clk, lclk); 
    lclk <= clkin;
    clkgen0 : clkgen  		-- clock generator
      generic map (clktech, CFG_CLKMUL, CFG_CLKDIV, CFG_SDEN, 
  	CFG_INVCLK, 0, CFG_PCIDLL, CFG_PCISYSCLK, BOARD_FREQ)
      port map (lclk, lclk, clkm, open, clk2x, sdclk, open, cgi, cgo);
--    sdclk_pad : outpad generic map (tech => padtech) 
--	port map (sdclk, sdclkl);
    gclk <= (others => clkm); grst <= (others => rstn);
    clk <= clkm; cpuclk <= (others => clkm);
    clklock <= cgo.clklock;

  ahbs : if CFG_AHBSTAT = 1 generate	-- AHB status register
    stati.cerror(0) <= memo.ce;
    ahbstat0 : ahbstat generic map (pindex => 15, paddr => 15, pirq => 1,
	nftslv => CFG_AHBSTATN)
      port map (rstn, clk, ahbmi, ahbsi, stati, apbi, apbo(15));
  end generate;
  nop2 : if CFG_AHBSTAT = 0 generate apbo(15) <= apb_none; end generate;

-----------------------------------------------------------------------
---  PCI   ------------------------------------------------------------
-----------------------------------------------------------------------

  pp : if CFG_PCI /= 0 generate

    pci_gr0 : if CFG_PCI = 1 generate	-- simple target-only
      pci0 : pci_target generic map (hindex => CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG,
	device_id => CFG_PCIDID, vendor_id => CFG_PCIVID)
      port map (rstn, clk, pciclk, pcii, pcio, ahbmi, ahbmo(CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG));
    end generate;

    pci_mtf0 : if CFG_PCI = 2 generate	-- master/target with fifo
      pci0 : pci_mtf generic map (memtech => memtech, hmstndx => CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG, 
	  fifodepth => log2(CFG_PCIDEPTH), device_id => CFG_PCIDID, vendor_id => CFG_PCIVID,
	  hslvndx => 4, pindex => 4, paddr => 4, haddr => 16#E00#,
	  ioaddr => 16#400#, nsync => 2, oepol => oepol)
     port map (grst(CFG_SPW_EN*CFG_SPW_NUM+CFG_CAN+CFG_GRETH), 
	gclk(CFG_SPW_EN*CFG_SPW_NUM+CFG_CAN+CFG_GRETH), 
	pciclk, pcii, pcio, apbi, apbo(4),
	ahbmi, ahbmo(CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG), ahbsi, ahbso(4));
    end generate;

    pci_mtf1 : if CFG_PCI = 3 generate	-- master/target with fifo and DMA
      pcidma0 : pcidma generic map (memtech => 0, dmstndx => CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG+1, 
	  dapbndx => 5, dapbaddr => 5, blength => blength, mstndx => CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG,
	  fifodepth => log2(CFG_PCIDEPTH), device_id => CFG_PCIDID, vendor_id => CFG_PCIVID,
	  slvndx => 4, apbndx => 4, apbaddr => 4, haddr => 16#C00#, 
	  hmask => 16#C00#, ioaddr => 16#000#, 
	  nsync => 2, oepol => oepol, irq => 3, scanen => scantest)
        port map (grst(CFG_SPW_EN*CFG_SPW_NUM+CFG_CAN+CFG_GRETH), 
	  gclk(CFG_SPW_EN*CFG_SPW_NUM+CFG_CAN+CFG_GRETH), 
	  pciclk, pcii, pcio, apbo(5),  ahbmo(CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG+1), 
 	  apbi, apbo(4), ahbmi, ahbmo(CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG), ahbsi, ahbso(4));
    end generate;

    pci_trc0 : if CFG_PCITBUFEN /= 0 generate	-- PCI trace buffer
      pt0 : pcitrace generic map (depth => (6 + log2(CFG_PCITBUF/256)), 
	memtech => memtech, pindex => 6, paddr => 16#100#, pmask => 16#f00#)
        port map ( rstn, clk, pciclk, pcii, apbi, apbo(6));
    end generate;

     pcii.rst <=  pcii_rst; pcii.gnt <= pcii_gnt; pcii.host <=  pcii_host;
     pcii.idsel <=  pcii_idsel; 
     pcii.ad <= pcii_ad; pcio_vaden <= pcio.vaden; pcio_ad <= pcio.ad;
     pcii.cbe <= pcii_cbe; pcio_cbeen <= pcio.cbeen; pcio_cbe <= pcio.cbe;
     pcii.frame <= pcii_frame; pcio_frameen <= pcio.frameen; pcio_frame <= pcio.frame;
     pcii.trdy <= pcii_trdy; pcio_trdyen <= pcio.trdyen; pcio_trdy <= pcio.trdy;
     pcii.irdy <= pcii_irdy; pcio_irdyen <= pcio.irdyen; pcio_irdy <= pcio.irdy;
     pcii.devsel <= pcii_devsel; pcio_devselen <= pcio.devselen; pcio_devsel <= pcio.devsel;
     pcii.stop <= pcii_stop; pcio_stopen <= pcio.stopen; pcio_stop <= pcio.stop;
     pcii.perr <= pcii_perr; pcio_perren <= pcio.perren; pcio_perr <= pcio.perr;
     pcii.par <= pcii_par; pcio_paren <= pcio.paren; pcio_par <= pcio.par;
     pcio_req <= pcio.req; pcio_reqen <= pcio.reqen;
  end generate;

  pcia0 : if CFG_PCI_ARB = 1 generate	-- PCI arbiter
      pciarb0 : pciarb generic map (pindex => 8, paddr => 8, 
	apb_en => CFG_PCI_ARBAPB, NB_AGENTS => CFG_PCI_ARB_NGNT)
       port map ( clk => pciclk, rst_n => pcii.rst,
         req_n => pcii_arb_req, frame_n => pcii.frame,
         gnt_n => pcio_arb_gnt, pclk => clk, 
         prst_n => rstn, apbi => apbi, apbo => apbo(8)
       );
  end generate;

--  nop1 : if CFG_PCI <= 1 generate apbo(4) <= apb_none; end generate;
--  nop2 : if CFG_PCI <= 2 generate apbo(5) <= apb_none; end generate;
--  nop3 : if CFG_PCI <= 1 generate ahbso(4) <= ahbs_none; end generate;
--  notrc : if CFG_PCITBUFEN = 0 generate apbo(8) <= apb_none; end generate;
--  noarb : if CFG_PCI_ARB = 0 generate apbo(10) <= apb_none; end generate;

-----------------------------------------------------------------------
---  ETHERNET ---------------------------------------------------------
-----------------------------------------------------------------------

  eth0 : if CFG_GRETH = 1 generate -- Gaisler ethernet MAC
      greth0 : greth generic map(hindex => CFG_NCPU+CFG_AHB_UART+log2x(CFG_PCI)+CFG_AHB_JTAG,
	pindex => 14, paddr => 14, pirq => 14, memtech => 0,
        mdcscaler => CPU_FREQ/1000, enable_mdio => 1, fifosize => CFG_ETH_FIFO,
        nsync => 1, edcl => CFG_DSU_ETH, edclbufsz => CFG_ETH_BUF,
        macaddrh => CFG_ETH_ENM, macaddrl => CFG_ETH_ENL, 
	ipaddrh => CFG_ETH_IPM, ipaddrl => CFG_ETH_IPL,
	oepol => OEPOL, scanen => scantest)
     port map (rst => grst(CFG_SPW_EN*CFG_SPW_NUM+CFG_CAN), 
	clk => gclk(CFG_SPW_EN*CFG_SPW_NUM+CFG_CAN), ahbmi => ahbmi,
       ahbmo => ahbmo(CFG_NCPU+CFG_AHB_UART+log2x(CFG_PCI)+CFG_AHB_JTAG), apbi => apbi,
       apbo => apbo(14), ethi => ethi, etho => etho); 

    emdo <= etho.mdio_o; emden <= etho.mdio_oe; ethi.mdio_i <= emdi;
    ethi.tx_clk <= etx_clk; ethi.rx_clk <= erx_clk;
    ethi.rxd(3 downto 0) <= erxd;
    ethi.rx_dv <= erx_dv; ethi.rx_er <= erx_er;
    ethi.rx_col <= erx_col; ethi.rx_crs <= erx_crs;
    etxd <= etho.txd(3 downto 0); etx_en <= etho.tx_en;
    etx_er <= etho.tx_er; emdc <= etho.mdc;

  end generate;

-----------------------------------------------------------------------
---  SPACEWIRE  -------------------------------------------------------
-----------------------------------------------------------------------

  spw : if CFG_SPW_EN > 0 generate
    swloop : for i in 0 to CFG_SPW_NUM-1 generate
     grspw0 : grspw generic map(tech => fabtech,
       	hindex => maxahbmsp+i, pindex => 10+i, paddr => 10+i, pirq => 10+i, 
       	sysfreq => sysfreq, nsync => 1, rmap => CFG_SPW_RMAP*i/2, 
	rmapcrc => CFG_SPW_RMAPCRC, fifosize1 => CFG_SPW_AHBFIFO, 
        fifosize2 => CFG_SPW_RXFIFO, rxclkbuftype => 1, 
	rmapbufs => CFG_SPW_RMAPBUF, ft => CFG_SPW_FT,
	scantest => scantest, techfifo => 0, ports => 1, memtech => 0*memtech)
     port map(grst(i), gclk(i), clk2x, --spw_clk, 
	ahbmi, ahbmo(maxahbmsp+i), apbi, apbo(10+i), spwi(i), spwo(i));
     spwi(i).tickin <= '0'; spwi(i).rmapen <= '1'; 
     spwi(i).clkdiv10 <= conv_std_logic_vector(100000/10000-1, 8);
     spwi(i).d(0) <= spw_rxd(i); spwi(i).s(0) <= spw_rxs(i);
     spw_txd(i) <= spwo(i).d(0); spw_txs(i) <= spwo(i).s(0);
     spw_ten(i) <= spwo(i).linkdis when OEPOL = 0 else not spwo(i).linkdis;
    end generate;
  end generate;

-----------------------------------------------------------------------
---  CAN --------------------------------------------------------------
-----------------------------------------------------------------------

   can0 : if CFG_CAN = 1 generate 
     can_mc0 : can_mc generic map (slvndx => 6, ioaddr => CFG_CANIO,
    	iomask => 16#FF0#, irq => CFG_CANIRQ, memtech => 0,
	ncores => CFG_CAN_NUM, sepirq => CFG_CANSEPIRQ,
	syncrst => CFG_NOASYNC)
        port map (grst(CFG_SPW_EN*CFG_SPW_NUM), gclk(CFG_SPW_EN*CFG_SPW_NUM), 
		ahbsi, ahbso(6), can_lrx, can_ltx );
   end generate;

   can_lrx(0 to CFG_CAN_NUM-1) <= can_rx; can_lrx(CFG_CAN_NUM to 7) <= (others => '0');
   can_tx <= can_ltx(0 to CFG_CAN_NUM-1);

   ncan : if CFG_CAN = 0 generate ahbso(6) <= ahbs_none; end generate;

-----------------------------------------------------------------------
---  Drive unused bus elements  ---------------------------------------
-----------------------------------------------------------------------

  noam1 : for i in maxahbm to NAHBMST-1 generate
    ahbmo(i) <= ahbm_none;
  end generate;
--  noap0 : for i in 12+(CFG_SPW_NUM*CFG_SPW_EN) to NAPBSLV-1-CFG_AHBSTAT 
--	generate apbo(i) <= apb_none; end generate;
  noah0 : for i in 9 to NAHBSLV-1 generate ahbso(i) <= ahbs_none; end generate;

-----------------------------------------------------------------------
---  Boot message  ----------------------------------------------------
-----------------------------------------------------------------------

-- pragma translate_off
  x : report_version 
  generic map (
   msg1 => "LEON3 Aeroflex UT699RH design",
   msg2 => "GRLIB Version " & tost(LIBVHDL_VERSION/1000) & "." & tost((LIBVHDL_VERSION mod 1000)/100)
      & "." & tost(LIBVHDL_VERSION mod 100) & ", build " & tost(LIBVHDL_BUILD),
   msg3 => "Target technology: " & tech_table(fabtech) & ",  memory library: " & tech_table(memtech),
   mdel => 1
  );
-- pragma translate_on
end;
