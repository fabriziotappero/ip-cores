-----------------------------------------------------------------------------
--  LEON3 Demonstration design for AVNET Spartan3 Evaluation Board
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
library techmap;
use techmap.gencomp.all;
use techmap.allclkgen.all;

library gaisler;
use gaisler.memctrl.all;
use gaisler.leon3.all;
use gaisler.uart.all;
use gaisler.misc.all;
use gaisler.pci.all;
use gaisler.net.all;
use gaisler.jtag.all;
use gaisler.can.all;
library esa;
use esa.memoryctrl.all;
use esa.pcicomp.all;
use work.config.all;

entity leon3mp is
  generic (
    fabtech   : integer := CFG_FABTECH;
    memtech   : integer := CFG_MEMTECH;
    padtech   : integer := CFG_PADTECH;
    clktech   : integer := CFG_CLKTECH;
    disas     : integer := CFG_DISAS;	-- Enable disassembly to console
    dbguart   : integer := CFG_DUART;	-- Print UART on console
    pclow     : integer := CFG_PCLOW;
    mezz      : integer := CFG_ADS_DAU_MEZZ
  );
  port (
    clk_66mhz	: in  std_logic;
    clk_socket	: in  std_logic;
    leds	: out std_logic_vector(7 downto 0);
    switches	: in  std_logic_vector(5 downto 0);

    sram_a	: out std_logic_vector(24 downto 0);
    sram_ben_l	: out std_logic_vector(0 to 3);
    sram_cs_l   : out std_logic_vector(1 downto 0);
    sram_oe_l   : out std_logic;
    sram_we_l   : out std_logic;
    sram_dq	: inout std_logic_vector(31 downto 0);
    flash_cs_l  : out std_logic;
    flash_rst_l : out std_logic;
    iosn        : out std_logic;
    sdclk       : out std_logic;
    rasn        : out std_logic;
    casn        : out std_logic;
    sdcke       : out std_logic;
    sdcsn       : out std_logic;

    tx          : out std_logic;
    rx          : in  std_logic;

    can_txd     : out std_logic;
    can_rxd     : in  std_logic;

    phy_txck 	: in std_logic;
    phy_rxck 	: in std_logic;
    phy_rxd    	: in std_logic_vector(3 downto 0);   
    phy_rxdv  	: in std_logic; 
    phy_rxer  	: in std_logic; 
    phy_col 	: in std_logic;
    phy_crs 	: in std_logic;
    phy_txd 	: out std_logic_vector(3 downto 0);   
    phy_txen 	: out std_logic; 
    phy_txer 	: out std_logic; 
    phy_mdc 	: out std_logic;
    phy_mdio   	: inout std_logic;		-- ethernet PHY interface
    phy_reset_l	: inout std_logic;

    video_clk 	: in std_logic;
    comp_sync 	: out std_logic;
    horiz_sync 	: out std_logic;
    vert_sync 	: out std_logic;
    blank 	: out std_logic;
    video_out 	: out std_logic_vector(23 downto 0);   

    msclk   	: inout std_logic;
    msdata  	: inout std_logic;
    kbclk   	: inout std_logic;
    kbdata  	: inout std_logic;

    disp_seg1 	: out std_logic_vector(7 downto 0);   
    disp_seg2 	: out std_logic_vector(7 downto 0);   

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

constant blength : integer := 12;
constant fifodepth : integer := 8;
constant mahbmax : integer := CFG_NCPU+CFG_AHB_UART+CFG_PCI+
	CFG_SVGA_ENABLE + CFG_GRETH+CFG_AHB_JTAG;

signal vcc, gnd   : std_logic_vector(23 downto 0);
signal memi  : memory_in_type;
signal memo  : memory_out_type;
signal wpo   : wprot_out_type;
signal sdi   : sdctrl_in_type;
signal sdo   : sdram_out_type;
signal sdo2, sdo3 : sdctrl_out_type;
signal abus  : std_logic_vector(17 downto 0);

signal apbi  : apb_slv_in_type;
signal apbo  : apb_slv_out_vector := (others => apb_none);
signal ahbsi : ahb_slv_in_type;
signal ahbso : ahb_slv_out_vector := (others => ahbs_none);
signal ahbmi : ahb_mst_in_type;
signal ahbmo : ahb_mst_out_vector := (others => ahbm_none);

signal clk, rstn, rstraw, pciclk, sdclkl : std_logic;
signal cgi   : clkgen_in_type;
signal cgo   : clkgen_out_type;
signal u1i, u2i, dui : uart_in_type;
signal u1o, u2o, duo : uart_out_type;

signal irqi : irq_in_vector(0 to CFG_NCPU-1);
signal irqo : irq_out_vector(0 to CFG_NCPU-1);

signal dbgi : l3_debug_in_vector(0 to CFG_NCPU-1);
signal dbgo : l3_debug_out_vector(0 to CFG_NCPU-1);

signal dsui : dsu_in_type;
signal dsuo : dsu_out_type; 

signal kbdi  : ps2_in_type;
signal kbdo  : ps2_out_type;
signal moui  : ps2_in_type;
signal mouo  : ps2_out_type;
signal vgao  : apbvga_out_type;

signal pcii : pci_in_type;
signal pcio : pci_out_type;

signal ethi, ethi1, ethi2 : eth_in_type;
signal etho, etho1, etho2 : eth_out_type;

signal gpti : gptimer_in_type;
signal tck, tms, tdi, tdo : std_logic;

signal pllref, errorn, pci_rst   : std_logic;
signal pci_arb_req_n, pci_arb_gnt_n   : std_logic_vector(0 to 3);

signal dac_clk, clk25, clk_66mhzl, pci_lclk   : std_logic;
signal can_ltx, can_lrx  : std_logic;

attribute keep : boolean;
attribute syn_keep : boolean;
attribute syn_preserve : boolean;
attribute syn_keep of clk : signal is true;
attribute syn_preserve of clk : signal is true;
attribute keep of clk : signal is true;

signal switchesl  : std_logic_vector(5 downto 0);
constant padlevel : integer := 0;
constant IOAEN : integer := CFG_CAN;
constant BOARD_FREQ : integer := 66667;   -- input frequency in KHz
constant CPU_FREQ : integer := (BOARD_FREQ * CFG_CLKMUL) / CFG_CLKDIV;

begin

----------------------------------------------------------------------
---  Reset and Clock generation  -------------------------------------
---------------------------------------------------------------------

  vcc <= (others => '1'); gnd <= (others => '0'); pllref <= '0';
  cgi.pllctrl <= "00"; cgi.pllrst <= rstraw; cgi.pllref <= pllref;

  clkgen0 : clkgen  		-- clock generator
    generic map (clktech, CFG_CLKMUL, CFG_CLKDIV, CFG_MCTRL_SDEN, 
	CFG_CLK_NOFB, CFG_PCI, CFG_PCIDLL, CFG_PCISYSCLK, 66000)
    port map (clk_66mhzl, pci_lclk, clk, open, open, sdclkl, pciclk, cgi, cgo);
  sdclk_pad : outpad generic map (tech => padtech, slew => 1, strength => 8) 
	port map (sdclk, sdclkl);

  clk_pad : clkpad generic map (tech => padtech, level => padlevel) 
	    port map (clk_66mhz, clk_66mhzl); 
  clk2_pad : clkpad generic map (tech => padtech, level => padlevel) 
	    port map (clk_socket, open); 
  pci_clk_pad : clkpad generic map (tech => padtech, level => pci33) 
	    port map (pci_clk, pci_lclk); 
  rst0 : rstgen	generic map (acthigh => 1) 
  	 port map (switchesl(4), clk, cgo.clklock, rstn, rstraw);
  flash_rst_l_pad : outpad generic map (level => padlevel, tech => padtech) 
	port map (flash_rst_l, rstraw); 

----------------------------------------------------------------------
---  AHB CONTROLLER --------------------------------------------------
----------------------------------------------------------------------

  ahb0 : ahbctrl 		-- AHB arbiter/multiplexer
  generic map (defmast => CFG_DEFMST, split => CFG_SPLIT, 
	rrobin => CFG_RROBIN, ioaddr => CFG_AHBIO,
	nahbm => mahbmax, nahbs => 8, ioen => IOAEN)
  port map (rstn, clk, ahbmi, ahbmo, ahbsi, ahbso);

----------------------------------------------------------------------
---  LEON3 processor and DSU -----------------------------------------
----------------------------------------------------------------------

  l3 : if CFG_LEON3 = 1 generate
    cpu : for i in 0 to CFG_NCPU-1 generate
    u0 : leon3s			-- LEON3 processor
    generic map (i, fabtech, memtech, CFG_NWIN, CFG_DSU, CFG_FPU, CFG_V8, 
	0, CFG_MAC, pclow, 0, CFG_NWP, CFG_ICEN, CFG_IREPL, CFG_ISETS, CFG_ILINE, 
	CFG_ISETSZ, CFG_ILOCK, CFG_DCEN, CFG_DREPL, CFG_DSETS, CFG_DLINE, CFG_DSETSZ,
	CFG_DLOCK, CFG_DSNOOP, CFG_ILRAMEN, CFG_ILRAMSZ, CFG_ILRAMADDR, CFG_DLRAMEN,
        CFG_DLRAMSZ, CFG_DLRAMADDR, CFG_MMUEN, CFG_ITLBNUM, CFG_DTLBNUM, CFG_TLB_TYPE, CFG_TLB_REP, 
        CFG_LDDEL, disas, CFG_ITBSZ, CFG_PWD, CFG_SVT, CFG_RSTADDR, CFG_NCPU-1)
    port map (clk, rstn, ahbmi, ahbmo(i), ahbsi, ahbso,
    		irqi(i), irqo(i), dbgi(i), dbgo(i));

    dsugen : if CFG_DSU = 1 generate
      dsu0 : dsu3			-- LEON3 Debug Support Unit
      generic map (hindex => 2, haddr => 16#900#, hmask => 16#F00#, 
       ncpu => CFG_NCPU, tbits => 30, tech => memtech, irq => 0, kbytes => CFG_ATBSZ)
      port map (rstn, clk, ahbmi, ahbsi, ahbso(2), dbgo, dbgi, dsui, dsuo);
    end generate;
    dsui.break <= switchesl(5);
    dsui.enable <= '1';
    dsuact_pad : outpad generic map (tech => padtech, level => padlevel) 
	port map (leds(1), dsuo.active);
    end generate;
  end generate;
  nodsu  : if CFG_DSU = 0 generate 
    ahbso(2) <= ahbs_none; dsuo.tstop <= '0'; dsuo.active <= '0';
  end generate;

  dcomgen : if CFG_AHB_UART = 1 generate
    dcom0: ahbuart		-- Debug UART
    generic map (hindex => CFG_NCPU, pindex => 7, paddr => 7)
    port map (rstn, clk, dui, duo, apbi, apbo(7), ahbmi, ahbmo(CFG_NCPU));
  end generate;
  nouah : if CFG_AHB_UART = 0 generate apbo(7) <= apb_none; end generate;

  ahbjtaggen0 :if CFG_AHB_JTAG = 1 generate
    ahbjtag0 : ahbjtag generic map(tech => fabtech, hindex => CFG_NCPU+CFG_AHB_UART)
      port map(rstn, clk, tck, tms, tdi, tdo, ahbmi, ahbmo(CFG_NCPU+CFG_AHB_UART),
               open, open, open, open, open, open, open, gnd(0));
  end generate;

  dcompads : if CFG_AHB_UART = 1 generate
    dsurx_pad : inpad generic map (tech => padtech, level => padlevel) 
	port map (rx, dui.rxd); 
    dsutx_pad : outpad generic map (tech => padtech, level => padlevel) 
	port map (tx, duo.txd);
    u1i.rxd  <= '1';
  end generate;

----------------------------------------------------------------------
---  Memory controllers ----------------------------------------------
----------------------------------------------------------------------

  mg2 : if CFG_MCTRL_LEON2 = 1 generate 	-- LEON2 memory controller
    sr1 : entity work.mctrl_avnet generic map (hindex => 0, pindex => 0, paddr => 0, 
	srbanks => 4, sden => CFG_MCTRL_SDEN, invclk => CFG_MCTRL_INVCLK,
	pageburst => CFG_MCTRL_PAGE, avnetmezz => mezz)
    port map (rstn, clk, memi, memo, ahbsi, ahbso(0), apbi, apbo(0), wpo, sdo);
    sdpads : if CFG_MCTRL_SDEN = 1 generate 		-- no SDRAM controller
--      sdwen_pad : outpad generic map (tech => padtech) 
--	   port map (sdwen, sdo.sdwen);
      sdras_pad : outpad generic map (tech => padtech) 
	   port map (rasn, sdo.rasn);
      sdcas_pad : outpad generic map (tech => padtech) 
	   port map (casn, sdo.casn);
--      sddqm_pad : outpadv generic map (width =>4, tech => padtech) 
--	   port map (sddqm, sdo.dqm);
    end generate;
    sdcke_pad : outpad generic map (tech => padtech) 
	   port map (sdcke, sdo.sdcke(0)); 
    sdcsn_pad : outpad generic map (tech => padtech) 
	   port map (sdcsn, sdo.sdcsn(0)); 
  end generate;

  nosd0 : if (CFG_MCTRL_SDEN = 0) generate 	-- no SDRAM controller
      sdcke_pad : outpad generic map (tech => padtech) 
	   port map (sdcke, vcc(0)); 
      sdcsn_pad : outpad generic map (tech => padtech) 
	   port map (sdcsn, vcc(0)); 
  end generate;

  memi.brdyn <= '1'; memi.bexcn <= '1';
  memi.writen <= '1'; memi.wrn <= "1111"; memi.bwidth <= "10";

  mg0 : if CFG_MCTRL_LEON2 = 0 generate	-- None PROM/SRAM controller
    apbo(0) <= apb_none; ahbso(0) <= ahbs_none;
    rams_pad : outpadv generic map (level => padlevel, tech => padtech, width => 2) 
	port map (sram_cs_l, vcc(1 downto 0)); 
  end generate;

  mgpads : if CFG_MCTRL_LEON2 /= 0 generate	-- prom/sram pads
    addr_pad : outpadv generic map (level => padlevel, width => 25, tech => padtech) 
	port map (sram_a, memo.address(24 downto 0)); 
    rams_pad : outpadv generic map (level => padlevel, tech => padtech, width => 2) 
	port map (sram_cs_l, memo.ramsn(1 downto 0)); 
    flash_pad : outpad generic map (level => padlevel, tech => padtech) 
	port map (flash_cs_l, memo.romsn(0)); 
    oen_pad  : outpad generic map (level => padlevel, tech => padtech) 
	port map (sram_oe_l, memo.oen);
    iosn_pad  : outpad generic map (level => padlevel, tech => padtech) 
	port map (iosn, memo.iosn);
    wri_pad  : outpad generic map (level => padlevel, tech => padtech) 
	port map (sram_we_l, memo.writen);
    bdr : for i in 0 to 3 generate
      data_pad : iopadv generic map (level => padlevel, tech => padtech, width => 8)
      port map (sram_dq(31-i*8 downto 24-i*8), memo.data(31-i*8 downto 24-i*8),
	memo.bdrive(i), memi.data(31-i*8 downto 24-i*8));
    end generate;
    ben_pad : outpadv generic map (level => padlevel, width => 4, tech => padtech) 
	port map (sram_ben_l, memo.mben); 
  end generate;

----------------------------------------------------------------------
---  APB Bridge and various periherals -------------------------------
----------------------------------------------------------------------

  apb0 : apbctrl				-- AHB/APB bridge
  generic map (hindex => 1, haddr => CFG_APBADDR)
  port map (rstn, clk, ahbsi, ahbso(1), apbi, apbo );

  ua1 : if CFG_UART1_ENABLE /= 0 generate
    uart1 : apbuart			-- UART 1
    generic map (pindex => 1, paddr => 1,  pirq => 2, console => dbguart,
	fifosize => CFG_UART1_FIFO)
    port map (rstn, clk, apbi, apbo(1), u1i, u1o);
    u1i.ctsn <= '0'; u1i.extclk <= '0';
  end generate;
  noua0 : if CFG_UART1_ENABLE = 0 generate apbo(1) <= apb_none; end generate;
  ua1pads : if CFG_AHB_UART = 0 generate
    rx_pad : inpad generic map (tech => padtech, level => padlevel) 
	port map (rx, u1i.rxd); 
    tx_pad : outpad generic map (tech => padtech, level => padlevel) 
	port map (tx, u1o.txd);
  end generate;

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
    timer0 : gptimer 			-- timer unit
    generic map (pindex => 3, paddr => 3, pirq => CFG_GPT_IRQ, 
	sepirq => CFG_GPT_SEPIRQ, sbits => CFG_GPT_SW, ntimers => CFG_GPT_NTIM, 
	nbits => CFG_GPT_TW)
    port map (rstn, clk, apbi, apbo(3), gpti, open);
    gpti.dhalt <= dsuo.tstop; gpti.extclk <= '0';
  end generate;
  notim : if CFG_GPT_ENABLE = 0 generate apbo(3) <= apb_none; end generate;

 kbd : if CFG_KBD_ENABLE /= 0 generate
    ps21 : apbps2 generic map(pindex => 4, paddr => 4, pirq => 4)
      port map(rstn, clk, apbi, apbo(4), moui, mouo);
    ps20 : apbps2 generic map(pindex => 5, paddr => 5, pirq => 5)
      port map(rstn, clk, apbi, apbo(5), kbdi, kbdo);
  end generate;
  nokbd : if CFG_KBD_ENABLE = 0 generate 
	apbo(4) <= apb_none; mouo <= ps2o_none;
	apbo(5) <= apb_none; kbdo <= ps2o_none;
  end generate;
  kbdclk_pad : iopad generic map (tech => padtech)
      port map (kbclk,kbdo.ps2_clk_o, kbdo.ps2_clk_oe, kbdi.ps2_clk_i);
  kbdata_pad : iopad generic map (tech => padtech)
        port map (kbdata, kbdo.ps2_data_o, kbdo.ps2_data_oe, kbdi.ps2_data_i);
  mouclk_pad : iopad generic map (tech => padtech)
      port map (msclk,mouo.ps2_clk_o, mouo.ps2_clk_oe, moui.ps2_clk_i);
  mouata_pad : iopad generic map (tech => padtech)
        port map (msdata, mouo.ps2_data_o, mouo.ps2_data_oe, moui.ps2_data_i);

  vga : if CFG_VGA_ENABLE /= 0 generate
    vga0 : apbvga generic map(memtech => memtech, pindex => 6, paddr => 6)
       port map(rstn, clk, clk25, apbi, apbo(6), vgao);
    vgaclk0 : entity techmap.clkmul_virtex2 generic map (3, 8)  -- 25 MHz video clock
       port map (rstn, clk, dac_clk, open);
   end generate;
  
  svga : if CFG_SVGA_ENABLE /= 0 generate
    svga0 : svgactrl generic map(memtech => memtech, pindex => 6, paddr => 6,
        hindex => CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG, 
	clk0 => 39722, clk1 => 0, clk2 => 0, clk3 => 0, burstlen => 5)
       port map(rstn, clk, clk25, apbi, apbo(6), vgao, ahbmi, 
		ahbmo(CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG), open);
       clk25 <= not dac_clk;
  end generate;

  novga : if (CFG_VGA_ENABLE = 0 and CFG_SVGA_ENABLE = 0) generate
    apbo(6) <= apb_none; vgao <= vgao_none;
  end generate;

  video_clk_pad : inpad generic map (tech => padtech)
        port map (video_clk, dac_clk);
  blank_pad : outpad generic map (tech => padtech)
        port map (blank, vgao.blank);
  comp_sync_pad : outpad generic map (tech => padtech)
        port map (comp_sync, vgao.comp_sync);
  vert_sync_pad : outpad generic map (tech => padtech)
        port map (vert_sync, vgao.vsync);
  horiz_sync_pad : outpad generic map (tech => padtech)
        port map (horiz_sync, vgao.hsync);
  video_out_r_pad : outpadv generic map (width => 8, tech => padtech)
        port map (video_out(23 downto 16), vgao.video_out_r);
  video_out_g_pad : outpadv generic map (width => 8, tech => padtech)
        port map (video_out(15 downto 8), vgao.video_out_g);
  video_out_b_pad : outpadv generic map (width => 8, tech => padtech)
        port map (video_out(7 downto 0), vgao.video_out_b); 

-----------------------------------------------------------------------
---  PCI   ------------------------------------------------------------
-----------------------------------------------------------------------

  pp : if CFG_PCI /= 0 generate

    pci_gr0 : if CFG_PCI = 1 generate	-- simple target-only
      pci0 : pci_target generic map (hindex => CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG+CFG_SVGA_ENABLE,
	device_id => CFG_PCIDID, vendor_id => CFG_PCIVID)
      port map (rstn, clk, pciclk, pcii, pcio, ahbmi, ahbmo(CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG+CFG_SVGA_ENABLE));
    end generate;

    pci_mtf0 : if CFG_PCI = 2 generate	-- master/target with fifo
      pci0 : pci_mtf generic map (memtech => memtech, hmstndx => CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG+CFG_SVGA_ENABLE, 
	  fifodepth => log2(CFG_PCIDEPTH), device_id => CFG_PCIDID, vendor_id => CFG_PCIVID,
	  hslvndx => 4, pindex => 9, paddr => 4, haddr => 16#E00#,
	  ioaddr => 16#400#, nsync => 2)
      port map (rstn, clk, pciclk, pcii, pcio, apbi, apbo(9),
	ahbmi, ahbmo(CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG+CFG_SVGA_ENABLE), ahbsi, ahbso(4));
    end generate;

    pci_mtf1 : if CFG_PCI = 3 generate	-- master/target with fifo and DMA
      dma : pcidma generic map (memtech => memtech, dmstndx => CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG+1+CFG_SVGA_ENABLE, 
	  dapbndx => 5, dapbaddr => 5, blength => blength, mstndx => CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG+CFG_SVGA_ENABLE,
	  fifodepth => log2(fifodepth), device_id => CFG_PCIDID, vendor_id => CFG_PCIVID,
	  slvndx => 4, apbndx => 4, apbaddr => 4, haddr => 16#E00#, ioaddr => 16#800#, 
	  nsync => 1)
      	port map (rstn, clk, pciclk, pcii, pcio, apbo(5),  ahbmo(CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG+1+CFG_SVGA_ENABLE), 
 	  apbi, apbo(4), ahbmi, ahbmo(CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG+CFG_SVGA_ENABLE), ahbsi, ahbso(4));
    end generate;

    pci_trc0 : if CFG_PCITBUFEN /= 0 generate	-- PCI trace buffer
      pt0 : pcitrace generic map (depth => (6 + log2(CFG_PCITBUF/256)), 
	memtech => memtech, pindex  => 8, paddr => 16#100#, pmask => 16#f00#)
        port map ( rstn, clk, pciclk, pcii, apbi, apbo(8));
    end generate;

  end generate;

  pcipads0 : pcipads 
  generic map (padtech => padtech, noreset => 1, host => 0)-- PCI pads
  port map ( pci_rst, pci_gnt, pci_idsel, pci_lock, pci_ad, pci_cbe,
      pci_frame, pci_irdy, pci_trdy, pci_devsel, pci_stop, pci_perr,
      pci_par, pci_req, pci_serr, pci_host, pci_66, pcii, pcio );

-----------------------------------------------------------------------
---  ETHERNET ---------------------------------------------------------
-----------------------------------------------------------------------

  eth0 : if CFG_GRETH = 1 generate -- Gaisler ethernet MAC
      e1 : greth generic map(hindex => CFG_NCPU+CFG_AHB_UART+CFG_PCI+CFG_AHB_JTAG+CFG_SVGA_ENABLE,
	pindex => 11, paddr => 11, pirq => 12, memtech => memtech,
        mdcscaler => CPU_FREQ/1000, enable_mdio => 1, fifosize => CFG_ETH_FIFO,
        nsync => 1, edcl => CFG_DSU_ETH, edclbufsz => CFG_ETH_BUF,
        macaddrh => CFG_ETH_ENM, macaddrl => CFG_ETH_ENL, 
	ipaddrh => CFG_ETH_IPM, ipaddrl => CFG_ETH_IPL)
     port map( rst => rstn, clk => clk, ahbmi => ahbmi,
       ahbmo => ahbmo(CFG_NCPU+CFG_AHB_UART+CFG_PCI+CFG_AHB_JTAG+CFG_SVGA_ENABLE), apbi => apbi,
       apbo => apbo(11), ethi => ethi, etho => etho); 
  end generate;


  ethpads : if (CFG_GRETH = 0) generate -- no eth 
      etho <= ('0', "00000000", '0', '0', '0', '0', '1');
  end generate;

  emdio_pad : iopad generic map (tech => padtech, level => padlevel) 
      port map (phy_mdio, etho.mdio_o, etho.mdio_oe, ethi.mdio_i);
  etxc_pad : clkpad generic map (tech => padtech, level => padlevel, arch => 1) 
	port map (phy_txck, ethi.tx_clk);
  erxc_pad : clkpad generic map (tech => padtech, level => padlevel, arch => 1) 
	port map (phy_rxck, ethi.rx_clk);
  erxd_pad : inpadv generic map (tech => padtech, level => padlevel, width => 4) 
	port map (phy_rxd, ethi.rxd(3 downto 0));
  erxdv_pad : inpad generic map (tech => padtech, level => padlevel) 
	port map (phy_rxdv, ethi.rx_dv);
  erxer_pad : inpad generic map (tech => padtech, level => padlevel) 
	port map (phy_rxer, ethi.rx_er);
  erxco_pad : inpad generic map (tech => padtech, level => padlevel) 
	port map (phy_col, ethi.rx_col);
  erxcr_pad : inpad generic map (tech => padtech, level => padlevel) 
	port map (phy_crs, ethi.rx_crs);

  etxd_pad : outpadv generic map (tech => padtech, level => padlevel, width => 4) 
	port map (phy_txd, etho.txd(3 downto 0));
  etxen_pad : outpad generic map (tech => padtech, level => padlevel) 
	port map ( phy_txen, etho.tx_en);
  etxer_pad : outpad generic map (tech => padtech, level => padlevel) 
	port map (phy_txer, etho.tx_er);
  emdc_pad : outpad generic map (tech => padtech, level => padlevel) 
	port map (phy_mdc, etho.mdc);


  phy_reset_pad : iodpad generic map (tech => padtech, level => padlevel) 
	port map (phy_reset_l, rstn, pci_rst);

   can0 : if CFG_CAN = 1 generate 
     can0 : can_oc generic map (slvndx => 6, ioaddr => CFG_CANIO,
    	iomask => 16#FF0#, irq => CFG_CANIRQ, memtech => memtech)
      port map (rstn, clk, ahbsi, ahbso(6), can_lrx, can_ltx );

      can_tx_pad : outpad generic map (tech => padtech) 
	port map (can_txd, can_ltx);
      can_rx_pad : inpad generic map (tech => padtech) 
	port map (can_rxd, can_lrx);
   end generate;

  ncan : if CFG_CAN = 0 generate ahbso(6) <= ahbs_none; end generate;

-----------------------------------------------------------------------
---  AHB RAM ----------------------------------------------------------
-----------------------------------------------------------------------

  ocram : if CFG_AHBRAMEN = 1 generate 
    ahbram0 : ahbram generic map (hindex => 7, haddr => CFG_AHBRADDR, 
	tech => CFG_MEMTECH, kbytes => CFG_AHBRSZ)
    port map (rstn, clk, ahbsi, ahbso(7));
  end generate;
  nram : if CFG_AHBRAMEN = 0 generate ahbso(7) <= ahbs_none; end generate;

-----------------------------------------------------------------------
---  Misc    ----------------------------------------------------------
-----------------------------------------------------------------------

  errorn <= not dbgo(0).error;
  led0_pad : outpad generic map (level => padlevel, tech => padtech) 
	port map (leds(0), errorn); 
  led2_7_pad : outpadv generic map (level => padlevel, width => 6, tech => padtech) 
	port map (leds(7 downto 2), gnd(5 downto 0)); 

  disp_seg1_pad : outpadv generic map (level => padlevel, width => 8, tech => padtech) 
	port map (disp_seg1, gnd(7 downto 0)); 
  disp_seg2_pad : outpadv generic map (level => padlevel, width => 8, tech => padtech) 
	port map (disp_seg2, gnd(7 downto 0)); 
  switche_pad : inpadv generic map (tech => padtech, level => padlevel, width => 6) 
	port map (switches, switchesl);

-----------------------------------------------------------------------
---  Drive unused bus elements  ---------------------------------------
-----------------------------------------------------------------------

  nam1 : for i in (CFG_NCPU+CFG_AHB_UART+CFG_PCI+ CFG_AHB_JTAG+CFG_GRETH+CFG_SVGA_ENABLE) to NAHBMST-1 generate
    ahbmo(i) <= ahbm_none;
  end generate;
  nam2 : if CFG_PCI > 1 generate
    ahbmo(CFG_NCPU+CFG_AHB_UART+CFG_PCI+CFG_AHB_JTAG-1+CFG_SVGA_ENABLE) <= ahbm_none;
  end generate;
  nap0 : for i in 12 to NAPBSLV-1 generate apbo(i) <= apb_none; end generate;
--  nah0 : for i in 8 to NAHBSLV-1 generate ahbso(i) <= ahbs_none; end generate;

-----------------------------------------------------------------------
---  Boot message  ----------------------------------------------------
-----------------------------------------------------------------------

-- pragma translate_off
  x : report_version 
  generic map (
   msg1 => "LEON3 Avnet Spartan3-1500 Demonstration design",
   msg2 => "GRLIB Version " & tost(LIBVHDL_VERSION/1000) & "." & tost((LIBVHDL_VERSION mod 1000)/100)
      & "." & tost(LIBVHDL_VERSION mod 100) & ", build " & tost(LIBVHDL_BUILD),
   msg3 => "Target technology: " & tech_table(fabtech) & ",  memory library: " & tech_table(memtech),
   mdel => 1
  );
-- pragma translate_on
end;
