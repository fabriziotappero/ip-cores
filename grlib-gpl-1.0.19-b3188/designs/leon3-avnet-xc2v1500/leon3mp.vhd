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
library grlib, techmap;
use grlib.amba.all;
use grlib.stdlib.all;
use techmap.gencomp.all;
library gaisler;
use gaisler.memctrl.all;
use gaisler.leon3.all;
use gaisler.uart.all;
use gaisler.misc.all;
use gaisler.pci.all;
use gaisler.jtag.all;
use gaisler.ddrrec.all;

library esa;
use esa.memoryctrl.all;
use esa.pcicomp.all;
use work.config.all;

entity leon3mp is
  generic (
    fabtech   : integer := CFG_FABTECH;
    memtech   : integer := CFG_MEMTECH;
    padtech   : integer := CFG_PADTECH;
    ncpu      : integer := CFG_NCPU;
    disas     : integer := CFG_DISAS;	-- Enable disassembly to console
    dbguart   : integer := CFG_DUART;	-- Print UART on console
    pclow     : integer := CFG_PCLOW
  );
  port (

    resetn	: in  std_logic;
    clk		: in  std_logic;
    clk125	: in  std_logic;
    errorn	: out std_logic;
    flash_rstn	: out std_logic;
    addr     	: out std_logic_vector(27 downto 0);
    data	: inout std_logic_vector(15 downto 0);
    dsuen   	: in std_logic;
    dsubre  	: in std_logic;
    dsuact  	: out std_logic;
    oen    	: out std_logic;
    writen 	: out std_logic;
    read   	: out std_logic;
-- pragma translate_off
    iosn   	: out std_logic;
-- pragma translate_on 
    romsn  	: out std_logic;

    ddr_clk  	: out std_logic_vector(1 downto 0);
    ddr_clkb  	: out std_logic_vector(1 downto 0);
    ddr_clk_fb  : in std_logic;
    ddr_clk_fb_out  : out std_logic;
    ddr_cke  	: out std_logic_vector(1 downto 0);
    ddr_csb  	: out std_logic_vector(1 downto 0);
    ddr_web  	: out std_logic;                       -- ddr write enable
    ddr_rasb  	: out std_logic;                       -- ddr ras
    ddr_casb  	: out std_logic;                       -- ddr cas
    ddr_dm   	: out std_logic_vector (7 downto 0);    -- ddr dm
    ddr_dqs  	: inout std_logic_vector (7 downto 0);    -- ddr dqs
    ddr_ad      : out std_logic_vector (12 downto 0);   -- ddr address
    ddr_ba      : out std_logic_vector (1 downto 0);    -- ddr bank address
    ddr_dq  	: inout std_logic_vector (63 downto 0); -- ddr data

    txd1   	: out std_logic; 			-- UART1 tx data
    rxd1   	: in  std_logic;  			-- UART1 rx data

--    gpio        : inout std_logic_vector(31 downto 0); 	-- I/O port

    pci_rst     : inout std_logic;		-- PCI bus
    pci_clk 	: in std_logic;
    pci_gnt     : in std_logic;
    pci_idsel   : in std_logic; 
    pci_lock    : inout std_logic;
    pci_ad 	: inout std_logic_vector(31 downto 0);
    pci_cbe 	: inout std_logic_vector(3 downto 0);
    pci_frame   : inout std_logic;
    pci_irdy 	: inout std_logic;
    pci_trdy 	: inout std_logic;
    pci_devsel  : inout std_logic;
    pci_stop 	: inout std_logic;
    pci_perr 	: inout std_logic;
    pci_par 	: inout std_logic;    
    pci_req 	: inout std_logic;
    pci_serr    : inout std_logic;
    pci_host   	: in std_logic;
    pci_66	: in std_logic
	);
end;

architecture rtl of leon3mp is

signal gpio        : std_logic_vector(31 downto 0); 	-- I/O port

constant blength : integer := 12;
constant fifodepth : integer := 8;
constant maxahbm : integer := NCPU+CFG_AHB_UART+CFG_AHB_JTAG+1+CFG_PCI;

signal vcc, gnd   : std_logic_vector(4 downto 0);
signal memi  : memory_in_type;
signal memo  : memory_out_type;
signal wpo   : wprot_out_type;
signal sdi   : sdctrl_in_type;
signal sdo   : sdram_out_type;
signal sdo2, sdo3 : sdctrl_out_type;

signal apbi  : apb_slv_in_type;
signal apbo  : apb_slv_out_vector := (others => apb_none);
signal ahbsi : ahb_slv_in_type;
signal ahbso : ahb_slv_out_vector := (others => ahbs_none);
signal ahbmi : ahb_mst_in_type;
signal ahbmo : ahb_mst_out_vector := (others => ahbm_none);

signal clkm, clkml,  rstn, rstraw, pciclk, clkddr, ddrlock : std_logic;

signal cgi   : clkgen_in_type;
signal cgo   : clkgen_out_type;
signal u1i, u2i, dui : uart_in_type;
signal u1o, u2o, duo : uart_out_type;

signal irqi : irq_in_vector(0 to NCPU-1);
signal irqo : irq_out_vector(0 to NCPU-1);

signal dbgi : l3_debug_in_vector(0 to NCPU-1);
signal dbgo : l3_debug_out_vector(0 to NCPU-1);

signal dsui : dsu_in_type;
signal dsuo : dsu_out_type; 

signal gpti : gptimer_in_type;

signal gpioi : gpio_in_type;
signal gpioo : gpio_out_type;

signal lclk, rst, ndsuact : std_logic;
signal tck, tckn, tms, tdi, tdo : std_logic;

signal pcii : pci_in_type;
signal pcio : pci_out_type;

signal ddr_clkv 	: std_logic_vector(2 downto 0);
signal ddr_clkbv	: std_logic_vector(2 downto 0);
signal ddr_adl      	: std_logic_vector (13 downto 0);

attribute keep : boolean;
attribute syn_keep : boolean;
attribute syn_preserve : boolean;
attribute keep of ddrlock : signal is true;
attribute keep of clkml : signal is true;
attribute keep of clkm : signal is true;
attribute syn_keep of clkml : signal is true;
attribute syn_preserve of clkml : signal is true;

signal lresetn, lclk125, lock : std_logic;

constant BOARD_FREQ : integer := 40000;   -- input frequency in KHz
constant CPU_FREQ : integer := BOARD_FREQ * CFG_CLKMUL / CFG_CLKDIV;  -- cpu frequency in KHz
constant IOAEN : integer := 1;
constant DDR_FREQ : integer := 125; --(CFG_DDRSP_FREQ/10)*10; -- DDR frequency in MHz


signal stati : ahbstat_in_type;

begin

----------------------------------------------------------------------
---  Reset and Clock generation  -------------------------------------
----------------------------------------------------------------------
  
  vcc <= (others => '1'); gnd <= (others => '0');
  cgi.pllctrl <= "00"; cgi.pllrst <= rstraw;
  lock <= ddrlock and cgo.clklock;

  clk_pad : clkpad generic map (tech => padtech) port map (clk, lclk); 

  clkgen0 : clkgen  		-- clock generator
    generic map (fabtech, CFG_CLKMUL, CFG_CLKDIV, 0, 0, CFG_PCI, 
	CFG_PCIDLL, CFG_PCISYSCLK, BOARD_FREQ, 0)
    port map (lclk, pci_clk, clkm, open, open, open, pciclk, cgi, cgo);

  resetn_pad : clkpad generic map (tech => padtech) port map (resetn, lresetn); 
  rst0 : rstgen			-- reset generator
  port map (lresetn, clkm, lock, rstn, rstraw);

  flash_rstn_pad : outpad generic map (tech => padtech) 
	port map (flash_rstn, rstn);
----------------------------------------------------------------------
---  AHB CONTROLLER --------------------------------------------------
----------------------------------------------------------------------

  ahb0 : ahbctrl 		-- AHB arbiter/multiplexer
  generic map (defmast => CFG_DEFMST, split => CFG_SPLIT, 
	rrobin => CFG_RROBIN, ioaddr => CFG_AHBIO,
	ioen => IOAEN, nahbm => maxahbm, nahbs => 8)
  port map (rstn, clkm, ahbmi, ahbmo, ahbsi, ahbso);

----------------------------------------------------------------------
---  LEON3 processor and DSU -----------------------------------------
----------------------------------------------------------------------

  l3 : if CFG_LEON3 = 1 generate
    cpu : for i in 0 to NCPU-1 generate
      u0 : leon3s			-- LEON3 processor      
      generic map (i, fabtech, memtech, CFG_NWIN, CFG_DSU, CFG_FPU, CFG_V8, 
	0, CFG_MAC, pclow, 0, CFG_NWP, CFG_ICEN, CFG_IREPL, CFG_ISETS, CFG_ILINE, 
	CFG_ISETSZ, CFG_ILOCK, CFG_DCEN, CFG_DREPL, CFG_DSETS, CFG_DLINE, CFG_DSETSZ,
	CFG_DLOCK, CFG_DSNOOP, CFG_ILRAMEN, CFG_ILRAMSZ, CFG_ILRAMADDR, CFG_DLRAMEN,
        CFG_DLRAMSZ, CFG_DLRAMADDR, CFG_MMUEN, CFG_ITLBNUM, CFG_DTLBNUM, CFG_TLB_TYPE, CFG_TLB_REP, 
        CFG_LDDEL, disas, CFG_ITBSZ, CFG_PWD, CFG_SVT, CFG_RSTADDR, NCPU-1)
      port map (clkm, rstn, ahbmi, ahbmo(i), ahbsi, ahbso, 
    		irqi(i), irqo(i), dbgi(i), dbgo(i));
    end generate;
    errorn_pad : odpad generic map (tech => padtech) port map (errorn, dbgo(0).error);
  
    dsugen : if CFG_DSU = 1 generate
      dsu0 : dsu3			-- LEON3 Debug Support Unit
      generic map (hindex => 2, haddr => 16#900#, hmask => 16#F00#, 
         ncpu => NCPU, tbits => 30, tech => memtech, irq => 0, kbytes => CFG_ATBSZ)
      port map (rstn, clkm, ahbmi, ahbsi, ahbso(2), dbgo, dbgi, dsui, dsuo);
      dsuen_pad : inpad generic map (tech => padtech) port map (dsuen, dsui.enable); 
      dsubre_pad : inpad generic map (tech => padtech) port map (dsubre, dsui.break); 
      dsuact_pad : outpad generic map (tech => padtech) port map (dsuact, ndsuact);
    end generate;
  end generate;

  nodsu : if CFG_DSU = 0 generate 
    dsuo.tstop <= '0'; dsuo.active <= '0';
  end generate;

--  dcomgen : if CFG_AHB_UART = 1 generate
--    dcom0: ahbuart		-- Debug UART
--    generic map (hindex => NCPU, pindex => 7, paddr => 7)
--    port map (rstn, clkm, dui, duo, apbi, apbo(7), ahbmi, ahbmo(NCPU));
--    dsurx_pad : inpad generic map (tech => padtech) port map (rxd1, dui.rxd); 
--    dsutx_pad : outpad generic map (tech => padtech) port map (txd1, duo.txd);
--  end generate;

  ahbjtaggen0 :if CFG_AHB_JTAG = 1 generate
    ahbjtag0 : ahbjtag generic map(tech => fabtech, hindex => NCPU+CFG_AHB_UART)
      port map(rstn, clkm, tck, tms, tdi, tdo, ahbmi, ahbmo(NCPU+CFG_AHB_UART),
               open, open, open, open, open, open, open, gnd(0));
  end generate;
  
----------------------------------------------------------------------
---  Memory controllers ----------------------------------------------
----------------------------------------------------------------------

  memi.writen <= '1'; memi.wrn <= "1111"; memi.bwidth <= "01";
  memi.brdyn <= '1'; memi.bexcn <= '1';

  mctrl0 : mctrl generic map (hindex => 0, pindex => 0,
	paddr => 0, srbanks => 1, ram8 => CFG_MCTRL_RAM8BIT, 
	ramaddr => 16#C00#, rammask => 16#FFF#,
	ram16 => CFG_MCTRL_RAM16BIT, sden => CFG_MCTRL_SDEN, 
	invclk => CFG_MCTRL_INVCLK, sepbus => CFG_MCTRL_SEPBUS)
  port map (rstn, clkm, memi, memo, ahbsi, ahbso(0), apbi, apbo(0), wpo, sdo);

  addr_pad : outpadv generic map (width => 28, tech => padtech) 
	port map (addr, memo.address(28 downto 1)); 
  roms_pad : outpad generic map (tech => padtech) 
	port map (romsn, memo.romsn(0)); 
  oen_pad  : outpad generic map (tech => padtech) 
	port map (oen, memo.oen);
  writen_pad  : outpad generic map (tech => padtech) 
	port map (writen, memo.writen);
  bdr : for i in 0 to 1 generate
      data_pad : iopadv generic map (tech => padtech, width => 8)
      port map (data(15-i*8 downto 8-i*8), memo.data(31-i*8 downto 24-i*8),
	memo.bdrive(i), memi.data(31-i*8 downto 24-i*8));
  end generate;

  -- DDR RAM

  ddrsp0 : if (CFG_DDRSP /= 0) generate 

    clk_pad : clkpad generic map (tech => padtech, arch => 2) 
	port map (clk125, lclk125); 

    ddr0 : ddrspa generic map (
	fabtech => virtex2, memtech => 0, ddrbits => 64,
	hindex => 3, haddr => 16#400#, hmask => 16#C00#, ioaddr => 1, 
	pwron => CFG_DDRSP_INIT, MHz => DDR_FREQ,
	clkmul => CFG_DDRSP_FREQ/5, clkdiv => 20, col => CFG_DDRSP_COL,
	Mbyte => CFG_DDRSP_SIZE, ahbfreq => CPU_FREQ/1000 )
    port map (lresetn, rstn, lclk125, clkm, ddrlock, clkml, clkml, 
	ahbsi, ahbso(3),
	ddr_clkv, ddr_clkbv, ddr_clk_fb_out, ddr_clk_fb,
	ddr_cke, ddr_csb, ddr_web, ddr_rasb, ddr_casb, 
	ddr_dm, ddr_dqs, ddr_adl, ddr_ba, ddr_dq);

        ddr_clk <= ddr_clkv(1 downto 0); ddr_clkb <= ddr_clkbv(1 downto 0);
        ddr_ad <= ddr_adl(12 downto 0);


  end generate;

-----------------------------------------------------------------------
---  AHB DMA ----------------------------------------------------------
-----------------------------------------------------------------------

--  dma0 : ahbdma
--    generic map (hindex => CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG,
--	pindex => 13, paddr => 13, dbuf => 16)
--    port map (rstn, clkm, apbi, apbo(13), ahbmi, 
--	ahbmo(CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG));
--
--  at0 : ahbtrace
--  generic map ( hindex  => 7, ioaddr => 16#200#, iomask => 16#E00#,
--    tech    => memtech, irq     => 0, kbytes  => 8) 
--  port map ( rstn, clkm, ahbmi, ahbsi, ahbso(7));

----------------------------------------------------------------------
---  APB Bridge and various periherals -------------------------------
----------------------------------------------------------------------

  apb0 : apbctrl				-- AHB/APB bridge
  generic map (hindex => 1, haddr => CFG_APBADDR, nslaves => 16)
  port map (rstn, clkm, ahbsi, ahbso(1), apbi, apbo );

  ua1 : if CFG_UART1_ENABLE /= 0 generate
    uart1 : apbuart			-- UART 1
    generic map (pindex => 1, paddr => 1,  pirq => 2, console => dbguart,
	fifosize => CFG_UART1_FIFO)
    port map (rstn, clkm, apbi, apbo(1), u1i, u1o);
    u1i.extclk <= '0'; u1i.ctsn <= '0';
    nopads : if CFG_AHB_UART = 0 generate
      rxd1_pad : inpad generic map (tech => padtech) port map (rxd1, u1i.rxd); 
      txd1_pad : outpad generic map (tech => padtech) port map (txd1, u1o.txd);
    end generate;
    upads : if CFG_AHB_UART = 1 generate
      u1i.rxd <= u1o.txd;
    end generate;
  end generate;

  irqctrl : if CFG_IRQ3_ENABLE /= 0 generate
    irqctrl0 : irqmp			-- interrupt controller
    generic map (pindex => 2, paddr => 2, ncpu => NCPU)
    port map (rstn, clkm, apbi, apbo(2), irqo, irqi);
  end generate;
  irq3 : if CFG_IRQ3_ENABLE = 0 generate
    x : for i in 0 to NCPU-1 generate
      irqi(i).irl <= "0000";
    end generate;
    apbo(2) <= apb_none;
  end generate;

  gpt : if CFG_GPT_ENABLE /= 0 generate
    timer0 : gptimer 			-- timer unit
    generic map (pindex => 3, paddr => 3, pirq => CFG_GPT_IRQ, 
	sepirq => CFG_GPT_SEPIRQ, sbits => CFG_GPT_SW, ntimers => CFG_GPT_NTIM, 
	nbits => CFG_GPT_TW)
    port map (rstn, clkm, apbi, apbo(3), gpti, open);
    gpti.dhalt <= dsuo.tstop; gpti.extclk <= '0';
  end generate;

  nogpt : if CFG_GPT_ENABLE = 0 generate apbo(3) <= apb_none; end generate;

  gpio0 : if CFG_GRGPIO_ENABLE /= 0 generate     -- GR GPIO unit
    grgpio0: grgpio
      generic map( pindex => 11, paddr => 11, imask => CFG_GRGPIO_IMASK, 
	nbits => CFG_GRGPIO_WIDTH)
      port map( rstn, clkm, apbi, apbo(11), gpioi, gpioo);

      pio_pads : for i in 0 to CFG_GRGPIO_WIDTH-1 generate
        pio_pad : iopad generic map (tech => padtech)
            port map (gpio(i), gpioo.dout(i), gpioo.oen(i), gpioi.din(i));
      end generate;
   end generate;

  ahbs : if CFG_AHBSTAT = 1 generate	-- AHB status register
    ahbstat0 : ahbstat generic map (pindex => 15, paddr => 15, pirq => 7,
	nftslv => CFG_AHBSTATN)
      port map (rstn, clkm, ahbmi, ahbsi, stati, apbi, apbo(15));
  end generate;

-----------------------------------------------------------------------
---  AHB RAM ----------------------------------------------------------
-----------------------------------------------------------------------

  ocram : if CFG_AHBRAMEN = 1 generate 
    ahbram0 : ahbram generic map (hindex => 7, haddr => CFG_AHBRADDR, 
	tech => CFG_MEMTECH, kbytes => CFG_AHBRSZ)
    port map ( rstn, clkm, ahbsi, ahbso(7));
  end generate;

-----------------------------------------------------------------------
---  PCI   ------------------------------------------------------------
-----------------------------------------------------------------------

  pp : if CFG_PCI /= 0 generate

--  pci_clk_pad : clkpad generic map (tech => padtech, level => pci33) 
--	    port map (pci_clk, pciclk); 

    pci_gr0 : if CFG_PCI = 1 generate	-- simple target-only
      pci0 : pci_target generic map (hindex => NCPU+CFG_AHB_UART+CFG_AHB_JTAG,
	device_id => CFG_PCIDID, vendor_id => CFG_PCIVID)
      port map (rstn, clkm, pciclk, pcii, pcio, ahbmi, ahbmo(NCPU+CFG_AHB_UART+CFG_AHB_JTAG));
    end generate;

    pci_mtf0 : if CFG_PCI = 2 generate	-- master/target with fifo
      pci0 : pci_mtf generic map (memtech => memtech, hmstndx => NCPU+CFG_AHB_UART+CFG_AHB_JTAG, 
	  fifodepth => log2(CFG_PCIDEPTH), device_id => CFG_PCIDID, vendor_id => CFG_PCIVID,
	  hslvndx => 4, pindex => 4, paddr => 4, haddr => 16#E00#,
	  ioaddr => 16#400#, nsync => 2)
      port map (rstn, clkm, pciclk, pcii, pcio, apbi, apbo(4),
	ahbmi, ahbmo(NCPU+CFG_AHB_UART+CFG_AHB_JTAG), ahbsi, ahbso(4));
    end generate;

    pci_mtf1 : if CFG_PCI = 3 generate	-- master/target with fifo and DMA
      dma : pcidma generic map (memtech => memtech, dmstndx => NCPU+CFG_AHB_UART+CFG_AHB_JTAG+1, 
	  dapbndx => 5, dapbaddr => 5, blength => blength, mstndx => NCPU+CFG_AHB_UART+CFG_AHB_JTAG,
	  fifodepth => log2(fifodepth), device_id => CFG_PCIDID, vendor_id => CFG_PCIVID,
	  slvndx => 4, apbndx => 4, apbaddr => 4, haddr => 16#E00#, ioaddr => 16#800#, 
	  nsync => 2)
      	port map (rstn, clkm, pciclk, pcii, pcio, apbo(5),  ahbmo(NCPU+CFG_AHB_UART+CFG_AHB_JTAG+1), 
 	  apbi, apbo(4), ahbmi, ahbmo(NCPU+CFG_AHB_UART+CFG_AHB_JTAG), ahbsi, ahbso(4));
    end generate;

    pci_trc0 : if CFG_PCITBUFEN /= 0 generate	-- PCI trace buffer
      pt0 : pcitrace generic map (depth => (6 + log2(CFG_PCITBUF/256)), 
	memtech => memtech, pindex  => 8, paddr => 16#100#, pmask => 16#f00#)
        port map ( rstn, clkm, pciclk, pcii, apbi, apbo(8));
    end generate;

    pcipads0 : pcipads generic map (padtech => padtech, host => 0)-- PCI pads
    port map ( pci_rst, pci_gnt, pci_idsel, pci_lock, pci_ad, pci_cbe,
      pci_frame, pci_irdy, pci_trdy, pci_devsel, pci_stop, pci_perr,
      pci_par, pci_req, pci_serr, pci_host, pci_66, pcii, pcio );

  end generate;

-----------------------------------------------------------------------
---  Boot message  ----------------------------------------------------
-----------------------------------------------------------------------

-- pragma translate_off
  x : report_version 
  generic map (
   msg1 => "LEON3 Avnet Virtex2 XC2V1500 Demonstration design",
   msg2 => "GRLIB Version " & tost(LIBVHDL_VERSION/1000) & "." & tost((LIBVHDL_VERSION mod 1000)/100)
      & "." & tost(LIBVHDL_VERSION mod 100) & ", build " & tost(LIBVHDL_BUILD),
   msg3 => "Target technology: " & tech_table(fabtech) & ",  memory library: " & tech_table(memtech),
   mdel => 1
  );
-- pragma translate_on
end;
