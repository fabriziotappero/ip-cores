-----------------------------------------------------------------------------
--  LEON3 Demonstration design
--  Copyright (C) 2004 Jiri Gaisler, Gaisler Research
--
--  Modified by Joris van Rantwijk for use with SpaceWire Light.
------------------------------------------------------------------------------
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
use gaisler.can.all;
use gaisler.net.all;
use gaisler.jtag.all;
use gaisler.spacewire.all;
use gaisler.grusb.all;

library esa;
use esa.memoryctrl.all;

library unisim;
use unisim.vcomponents.DCM;

use work.config.all;

-- These statements are used in case SpaceWire Light is synthesized locally,
-- separate from the rest of GRLIB.
use work.spwpkg.all;
use work.spwambapkg.all;
---- The following statements should be used instead if SpaceWire Light
---- has been integrated into GRLIB.
-- library opencores;
-- use opencores.spwpkg.all;
-- use opencores.spwambapkg.all;

entity leon3mp is
  generic (
    fabtech       : integer := CFG_FABTECH;
    memtech       : integer := CFG_MEMTECH;
    padtech       : integer := CFG_PADTECH;
    clktech       : integer := CFG_CLKTECH;
    disas         : integer := CFG_DISAS;	-- Enable disassembly to console
    dbguart       : integer := CFG_DUART;	-- Print UART on console
    pclow         : integer := CFG_PCLOW
  );
  port (
    resetn	  : in  std_ulogic;
    clk		  : in  std_ulogic; 	-- 50 MHz main clock
    clk3	  : in  std_ulogic; 	-- 25 MHz ethernet clock
    pllref 	  : in  std_ulogic; 
    errorn	  : out std_ulogic;
    wdogn  	  : out std_ulogic;
    address 	  : out std_logic_vector(27 downto 0);
    data	  : inout std_logic_vector(31 downto 0);
    ramsn  	  : out std_logic_vector (4 downto 0);
    ramoen 	  : out std_logic_vector (4 downto 0);
    rwen   	  : out std_logic_vector (3 downto 0);
    oen    	  : out std_ulogic;
    writen 	  : out std_ulogic;
    read   	  : out std_ulogic;
    iosn   	  : out std_ulogic;
    bexcn  	  : in  std_ulogic;  			-- DSU rx data
    brdyn  	  : in  std_ulogic;  			-- DSU rx data
    romsn  	  : out std_logic_vector (1 downto 0);
    sdclk  	  : out std_ulogic;
    sdcsn  	  : out std_logic_vector (1 downto 0);    -- sdram chip select
    sdwen  	  : out std_ulogic;                       -- sdram write enable
    sdrasn  	  : out std_ulogic;                       -- sdram ras
    sdcasn  	  : out std_ulogic;                       -- sdram cas
    sddqm   	  : out std_logic_vector (3 downto 0);    -- sdram dqm

    dsuen   	  : in std_ulogic;
    dsubre  	  : in std_ulogic;
    dsuact  	  : out std_ulogic;

    txd1   	  : out std_ulogic; 			-- UART1 tx data
    rxd1   	  : in  std_ulogic;  			-- UART1 rx data
    ctsn1  	  : in  std_ulogic;  			-- UART1 rx data
    rtsn1  	  : out std_ulogic;  			-- UART1 rx data
    txd2   	  : out std_ulogic; 			-- UART2 tx data
    rxd2   	  : in  std_ulogic;  			-- UART2 rx data
    ctsn2  	  : in  std_ulogic;  			-- UART1 rx data
    rtsn2  	  : out std_ulogic;  			-- UART1 rx data

    pio           : inout std_logic_vector(17 downto 0); 	-- I/O port

    emdio     	  : inout std_logic;		-- ethernet PHY interface
    etx_clk 	  : in std_ulogic;
    erx_clk 	  : in std_ulogic;
    erxd    	  : in std_logic_vector(3 downto 0);   
    erx_dv  	  : in std_ulogic; 
    erx_er  	  : in std_ulogic; 
    erx_col 	  : in std_ulogic;
    erx_crs 	  : in std_ulogic;
    emdint        : in std_ulogic;
    etxd 	  : out std_logic_vector(3 downto 0);   
    etx_en 	  : out std_ulogic; 
    etx_er 	  : out std_ulogic; 
    emdc 	  : out std_ulogic;

    ps2clk        : inout std_logic_vector(1 downto 0);
    ps2data       : inout std_logic_vector(1 downto 0);

    vid_clock     : out std_ulogic;
    vid_blankn    : out std_ulogic;
    vid_syncn     : out std_ulogic;
    vid_hsync     : out std_ulogic;
    vid_vsync     : out std_ulogic;
    vid_r         : out std_logic_vector(7 downto 0);
    vid_g         : out std_logic_vector(7 downto 0);
    vid_b         : out std_logic_vector(7 downto 0);

    spw_clk	  : in  std_ulogic;
    spw_rxdp      : in  std_logic_vector(0 to 2);
    spw_rxdn      : in  std_logic_vector(0 to 2);
    spw_rxsp      : in  std_logic_vector(0 to 2);
    spw_rxsn      : in  std_logic_vector(0 to 2);
    spw_txdp      : out std_logic_vector(0 to 2);
    spw_txdn      : out std_logic_vector(0 to 2);
    spw_txsp      : out std_logic_vector(0 to 2);
    spw_txsn      : out std_logic_vector(0 to 2);

    usb_clkout    : in std_ulogic;
    usb_d         : inout std_logic_vector(15 downto 0);
    usb_linestate : in std_logic_vector(1 downto 0);
    usb_opmode    : out std_logic_vector(1 downto 0);
    usb_reset     : out std_ulogic;
    usb_rxactive  : in std_ulogic;
    usb_rxerror   : in std_ulogic;
    usb_rxvalid   : in std_ulogic;
    usb_suspend   : out std_ulogic;
    usb_termsel   : out std_ulogic;
    usb_txready   : in std_ulogic;
    usb_txvalid   : out std_ulogic;
    usb_validh    : inout std_ulogic;
    usb_xcvrsel   : out std_ulogic;
    usb_vbus      : in std_ulogic
	);
end;

architecture rtl of leon3mp is

attribute syn_netlist_hierarchy : boolean;
attribute syn_netlist_hierarchy of rtl : architecture is false;

constant blength : integer := 12;
constant fifodepth : integer := 8;
constant maxahbm : integer := CFG_NCPU+CFG_AHB_UART+CFG_GRETH+
	CFG_AHB_JTAG+CFG_SPW_NUM*CFG_SPW_EN+CFG_GRUSB_DCL+CFG_SVGA_ENABLE+
	CFG_GRUSBDC;

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

signal clkm, rstn, rstraw, sdclkl : std_ulogic;
signal cgi, cgi2   : clkgen_in_type;
signal cgo, cgo2   : clkgen_out_type;
signal u1i, u2i, dui : uart_in_type;
signal u1o, u2o, duo : uart_out_type;

signal irqi : irq_in_vector(0 to CFG_NCPU-1);
signal irqo : irq_out_vector(0 to CFG_NCPU-1);

signal dbgi : l3_debug_in_vector(0 to CFG_NCPU-1);
signal dbgo : l3_debug_out_vector(0 to CFG_NCPU-1);

signal dsui : dsu_in_type;
signal dsuo : dsu_out_type; 

signal ethi, ethi1, ethi2 : eth_in_type;
signal etho, etho1, etho2 : eth_out_type;

signal gpti : gptimer_in_type;
signal gpto : gptimer_out_type;

signal gpioi : gpio_in_type;
signal gpioo : gpio_out_type;

signal can_lrx, can_ltx   : std_logic_vector(0 to 7);

signal lclk, rst, ndsuact, wdogl : std_ulogic;
signal tck, tckn, tms, tdi, tdo : std_ulogic;

signal ethclk : std_ulogic;

signal kbdi  : ps2_in_type;
signal kbdo  : ps2_out_type;
signal moui  : ps2_in_type;
signal mouo  : ps2_out_type;
signal vgao  : apbvga_out_type;

constant BOARD_FREQ : integer := 50000;   -- input frequency in KHz
constant CPU_FREQ : integer := BOARD_FREQ * CFG_CLKMUL / CFG_CLKDIV;  -- cpu frequency in KHz
constant IOAEN : integer := CFG_CAN + CFG_GRUSBDC;

signal stati : ahbstat_in_type;

signal spw_clkl   : std_ulogic;
signal spw_tick_in: std_logic;
signal spw_di: std_logic;
signal spw_si: std_logic;
signal spw_do: std_logic;
signal spw_so: std_logic;

signal uclk : std_ulogic;
signal usbi : grusb_in_type;
signal usbo : grusb_out_type;

constant SPW_LOOP_BACK : integer := 0;

signal dac_clk, video_clk, clk50 : std_logic;  -- signals to vga_clkgen.
signal clk_sel : std_logic_vector(1 downto 0);
                         
attribute keep : boolean;
attribute syn_keep : boolean;
attribute syn_preserve : boolean;
attribute syn_keep of clk50 : signal is true;
attribute syn_preserve of clk50 : signal is true;
attribute keep of clk50 : signal is true;
attribute syn_keep of video_clk : signal is true;
attribute syn_preserve of video_clk : signal is true;
attribute keep of video_clk : signal is true;
attribute keep of spw_clkl : signal is true;

begin

----------------------------------------------------------------------
---  Reset and Clock generation  -------------------------------------
----------------------------------------------------------------------
  
  vcc <= (others => '1'); gnd <= (others => '0');
  cgi.pllctrl <= "00"; cgi.pllrst <= rstraw;

  pllref_pad : clkpad generic map (tech => padtech) port map (pllref, cgi.pllref); 
  ethclk_pad : inpad generic map (tech => padtech) port map(clk3, ethclk);
  clk_pad : clkpad generic map (tech => padtech) port map (clk, lclk); 
  clkgen0 : clkgen  		-- clock generator
    generic map (clktech, CFG_CLKMUL, CFG_CLKDIV, CFG_MCTRL_SDEN,
	CFG_CLK_NOFB, 0, 0, 0, BOARD_FREQ)
    port map (lclk, lclk, clkm, open, open, sdclkl, open, cgi, cgo, open, clk50);

  sdclk_pad : outpad generic map (tech => padtech, slew => 1, strength => 24) 
	port map (sdclk, sdclkl);

  resetn_pad : inpad generic map (tech => padtech) port map (resetn, rst); 
  rst0 : rstgen			-- reset generator
  port map (rst, clkm, cgo.clklock, rstn, rstraw);

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
    cpu : for i in 0 to CFG_NCPU-1 generate
      u0 : leon3s			-- LEON3 processor      
      generic map (i, fabtech, memtech, CFG_NWIN, CFG_DSU, CFG_FPU, CFG_V8, 
  	0, CFG_MAC, pclow, 0, CFG_NWP, CFG_ICEN, CFG_IREPL, CFG_ISETS, CFG_ILINE, 
  	CFG_ISETSZ, CFG_ILOCK, CFG_DCEN, CFG_DREPL, CFG_DSETS, CFG_DLINE, CFG_DSETSZ,
  	CFG_DLOCK, CFG_DSNOOP, CFG_ILRAMEN, CFG_ILRAMSZ, CFG_ILRAMADDR, CFG_DLRAMEN,
        CFG_DLRAMSZ, CFG_DLRAMADDR, CFG_MMUEN, CFG_ITLBNUM, CFG_DTLBNUM, CFG_TLB_TYPE, CFG_TLB_REP, 
        CFG_LDDEL, disas, CFG_ITBSZ, CFG_PWD, CFG_SVT, CFG_RSTADDR, CFG_NCPU-1, 0, 0,
	CFG_MMU_PAGE, CFG_BP)
      port map (clkm, rstn, ahbmi, ahbmo(i), ahbsi, ahbso, 
      		irqi(i), irqo(i), dbgi(i), dbgo(i));
    end generate;
    errorn_pad : odpad generic map (tech => padtech) port map (errorn, dbgo(0).error);
    
    dsugen : if CFG_DSU = 1 generate
      dsu0 : dsu3			-- LEON3 Debug Support Unit
      generic map (hindex => 2, haddr => 16#900#, hmask => 16#F00#, 
         ncpu => CFG_NCPU, tbits => 30, tech => memtech, irq => 0, kbytes => CFG_ATBSZ)
      port map (rstn, clkm, ahbmi, ahbsi, ahbso(2), dbgo, dbgi, dsui, dsuo);
      dsuen_pad : inpad generic map (tech => padtech) port map (dsuen, dsui.enable); 
      dsubre_pad : inpad generic map (tech => padtech) port map (dsubre, dsui.break); 
      dsuact_pad : outpad generic map (tech => padtech) port map (dsuact, ndsuact);
      ndsuact <= not dsuo.active;
    end generate;
  end generate;
  nodsu : if CFG_DSU = 0 generate 
    dsuo.tstop <= '0'; dsuo.active <= '0';
  end generate;

  dcomgen : if CFG_AHB_UART = 1 generate
    dcom0: ahbuart		-- Debug UART
    generic map (hindex => CFG_NCPU, pindex => 7, paddr => 7)
    port map (rstn, clkm, dui, duo, apbi, apbo(7), ahbmi, ahbmo(CFG_NCPU));
    dsurx_pad : inpad generic map (tech => padtech) port map (rxd2, dui.rxd); 
    dsutx_pad : outpad generic map (tech => padtech) port map (txd2, duo.txd);
  end generate;
  nouah : if CFG_AHB_UART = 0 generate apbo(7) <= apb_none; end generate;

  ahbjtaggen0 :if CFG_AHB_JTAG = 1 generate
    ahbjtag0 : ahbjtag generic map(tech => fabtech, hindex => CFG_NCPU+CFG_AHB_UART)
      port map(rstn, clkm, tck, tms, tdi, tdo, ahbmi, ahbmo(CFG_NCPU+CFG_AHB_UART),
               open, open, open, open, open, open, open, gnd(0));
  end generate;
  
----------------------------------------------------------------------
---  Memory controllers ----------------------------------------------
----------------------------------------------------------------------

  memi.writen <= '1'; memi.wrn <= "1111"; memi.bwidth <= "00";
  brdyn_pad : inpad generic map (tech => padtech) port map (brdyn, memi.brdyn);
  bexcn_pad : inpad generic map (tech => padtech) port map (bexcn, memi.bexcn);

  mctrl0 : mctrl generic map (hindex => 0, pindex => 0,
	paddr => 0, srbanks => 2, ram8 => CFG_MCTRL_RAM8BIT, 
	ram16 => CFG_MCTRL_RAM16BIT, sden => CFG_MCTRL_SDEN, 
	invclk => CFG_CLK_NOFB, sepbus => CFG_MCTRL_SEPBUS,
	pageburst => CFG_MCTRL_PAGE)
  port map (rstn, clkm, memi, memo, ahbsi, ahbso(0), apbi, apbo(0), wpo, sdo);
  sdpads : if CFG_MCTRL_SDEN = 1 generate 		-- SDRAM controller
      sdwen_pad : outpad generic map (tech => padtech) 
	   port map (sdwen, sdo.sdwen);
      sdras_pad : outpad generic map (tech => padtech) 
	   port map (sdrasn, sdo.rasn);
      sdcas_pad : outpad generic map (tech => padtech) 
	   port map (sdcasn, sdo.casn);
      sddqm_pad : outpadv generic map (width =>4, tech => padtech) 
	   port map (sddqm, sdo.dqm(3 downto 0));
  end generate;
  sdcsn_pad : outpadv generic map (width =>2, tech => padtech) 
	   port map (sdcsn, sdo.sdcsn); 

  addr_pad : outpadv generic map (width => 28, tech => padtech) 
	port map (address, memo.address(27 downto 0)); 
  rams_pad : outpadv generic map (width => 5, tech => padtech) 
	port map (ramsn, memo.ramsn(4 downto 0)); 
  roms_pad : outpadv generic map (width => 2, tech => padtech) 
	port map (romsn, memo.romsn(1 downto 0)); 
  oen_pad  : outpad generic map (tech => padtech) 
	port map (oen, memo.oen);
  rwen_pad : outpadv generic map (width => 4, tech => padtech) 
	port map (rwen, memo.wrn); 
  roen_pad : outpadv generic map (width => 5, tech => padtech) 
	port map (ramoen, memo.ramoen(4 downto 0));
  wri_pad  : outpad generic map (tech => padtech) 
	port map (writen, memo.writen);
  read_pad : outpad generic map (tech => padtech) 
	port map (read, memo.read); 
  iosn_pad : outpad generic map (tech => padtech) 
	port map (iosn, memo.iosn);
  bdr : for i in 0 to 3 generate
      data_pad : iopadv generic map (tech => padtech, width => 8)
      port map (data(31-i*8 downto 24-i*8), memo.data(31-i*8 downto 24-i*8),
	memo.bdrive(i), memi.data(31-i*8 downto 24-i*8));
  end generate;

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
    u1i.extclk <= '0';
    rxd1_pad : inpad generic map (tech => padtech) port map (rxd1, u1i.rxd); 
    txd1_pad : outpad generic map (tech => padtech) port map (txd1, u1o.txd);
    cts1_pad : inpad generic map (tech => padtech) port map (ctsn1, u1i.ctsn); 
    rts1_pad : outpad generic map (tech => padtech) port map (rtsn1, u1o.rtsn);
  end generate;
  noua0 : if CFG_UART1_ENABLE = 0 generate apbo(1) <= apb_none; end generate;

  ua2 : if CFG_UART2_ENABLE /= 0 generate
    uart2 : apbuart			-- UART 2
    generic map (pindex => 9, paddr => 9,  pirq => 3, fifosize => CFG_UART2_FIFO)
    port map (rstn, clkm, apbi, apbo(9), u2i, u2o);
    u2i.extclk <= '0';
    rxd2_pad : inpad generic map (tech => padtech) port map (rxd2, u2i.rxd); 
    txd2_pad : outpad generic map (tech => padtech) port map (txd2, u2o.txd);
    cts2_pad : inpad generic map (tech => padtech) port map (ctsn2, u2i.ctsn); 
    rts2_pad : outpad generic map (tech => padtech) port map (rtsn2, u2o.rtsn);
  end generate;
  noua1 : if CFG_UART2_ENABLE = 0 generate 
    apbo(9) <= apb_none;  rtsn2 <= '0';
  end generate;

  irqctrl : if CFG_IRQ3_ENABLE /= 0 generate
    irqctrl0 : irqmp			-- interrupt controller
    generic map (pindex => 2, paddr => 2, ncpu => CFG_NCPU)
    port map (rstn, clkm, apbi, apbo(2), irqo, irqi);
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
	nbits => CFG_GPT_TW, wdog => CFG_GPT_WDOGEN*CFG_GPT_WDOG)
    port map (rstn, clkm, apbi, apbo(3), gpti, gpto);
    gpti.dhalt <= dsuo.tstop; gpti.extclk <= '0';
  end generate;
  wden : if CFG_GPT_WDOGEN /= 0 generate
    wdogl <= gpto.wdogn or not rstn;
    wdogn_pad : odpad generic map (tech => padtech) port map (wdogn, wdogl);
  end generate;
  wddis : if CFG_GPT_WDOGEN = 0 generate
    wdogn_pad : odpad generic map (tech => padtech) port map (wdogn, vcc(0));
  end generate;

  nogpt : if CFG_GPT_ENABLE = 0 generate apbo(3) <= apb_none; end generate;

  kbd : if CFG_KBD_ENABLE /= 0 generate
    ps21 : apbps2 generic map(pindex => 4, paddr => 4, pirq => 4)
      port map(rstn, clkm, apbi, apbo(4), moui, mouo);
    ps20 : apbps2 generic map(pindex => 5, paddr => 5, pirq => 5)
      port map(rstn, clkm, apbi, apbo(5), kbdi, kbdo);
  end generate;
  nokbd : if CFG_KBD_ENABLE = 0 generate 
	apbo(4) <= apb_none; mouo <= ps2o_none;
	apbo(5) <= apb_none; kbdo <= ps2o_none;
  end generate;
  kbdclk_pad : iopad generic map (tech => padtech)
      port map (ps2clk(0),kbdo.ps2_clk_o, kbdo.ps2_clk_oe, kbdi.ps2_clk_i);
  kbdata_pad : iopad generic map (tech => padtech)
        port map (ps2data(0), kbdo.ps2_data_o, kbdo.ps2_data_oe, kbdi.ps2_data_i);
  mouclk_pad : iopad generic map (tech => padtech)
      port map (ps2clk(1),mouo.ps2_clk_o, mouo.ps2_clk_oe, moui.ps2_clk_i);
  mouata_pad : iopad generic map (tech => padtech)
        port map (ps2data(1), mouo.ps2_data_o, mouo.ps2_data_oe, moui.ps2_data_i);

  vga : if CFG_VGA_ENABLE /= 0 generate
    vga0 : apbvga generic map(memtech => memtech, pindex => 6, paddr => 6)
       port map(rstn, clkm, ethclk, apbi, apbo(6), vgao);
    video_clock_pad : outpad generic map ( tech => padtech)
        port map (vid_clock, video_clk);
    video_clk <= not ethclk;
   end generate;
 
  -- Note: SVGA graphics support removed to make room for SpaceWire Light
  assert CFG_SVGA_ENABLE = 0 report "SVGA graphics not supported";
  svga : if CFG_SVGA_ENABLE /= 0 generate
    ahbmo(CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG) <= ahbm_none;
    apbo(6) <= apb_none;
    vgao <= vgao_none;
    video_clk <= not clkm;
    video_clock_pad : outpad generic map ( tech => padtech)
        port map (vid_clock, video_clk);
  end generate;

  novga : if (CFG_VGA_ENABLE = 0 and CFG_SVGA_ENABLE = 0) generate
    apbo(6) <= apb_none; vgao <= vgao_none;
    video_clk <= not clkm;
    video_clock_pad : outpad generic map ( tech => padtech)
        port map (vid_clock, video_clk);
  end generate;
  
  blank_pad : outpad generic map (tech => padtech)
        port map (vid_blankn, vgao.blank);
  comp_sync_pad : outpad generic map (tech => padtech)
        port map (vid_syncn, vgao.comp_sync);
  vert_sync_pad : outpad generic map (tech => padtech)
        port map (vid_vsync, vgao.vsync);
  horiz_sync_pad : outpad generic map (tech => padtech)
        port map (vid_hsync, vgao.hsync);
  video_out_r_pad : outpadv generic map (width => 8, tech => padtech)
        port map (vid_r, vgao.video_out_r);
  video_out_g_pad : outpadv generic map (width => 8, tech => padtech)
        port map (vid_g, vgao.video_out_g);
  video_out_b_pad : outpadv generic map (width => 8, tech => padtech)
        port map (vid_b, vgao.video_out_b); 

  gpio0 : if CFG_GRGPIO_ENABLE /= 0 generate     -- GPIO unit
    grgpio0: grgpio
    generic map(pindex => 8, paddr => 8, imask => CFG_GRGPIO_IMASK, nbits => 18)
    port map(rst => rstn, clk => clkm, apbi => apbi, apbo => apbo(8),
    gpioi => gpioi, gpioo => gpioo);
    p0 : if (CFG_CAN = 0) or (CFG_CAN_NUM = 1) generate
      pio_pads : for i in 1 to 2 generate
        pio_pad : iopad generic map (tech => padtech)
            port map (pio(i), gpioo.dout(i), gpioo.oen(i), gpioi.din(i));
      end generate;
    end generate;
    p1 : if (CFG_CAN = 0) generate
      pio_pads : for i in 4 to 5 generate
        pio_pad : iopad generic map (tech => padtech)
            port map (pio(i), gpioo.dout(i), gpioo.oen(i), gpioi.din(i));
      end generate;
    end generate;
    pio_pad0 : iopad generic map (tech => padtech)
            port map (pio(0), gpioo.dout(0), gpioo.oen(0), gpioi.din(0));
    pio_pad1 : iopad generic map (tech => padtech)
            port map (pio(3), gpioo.dout(3), gpioo.oen(3), gpioi.din(3));
    pio_pads : for i in 6 to 17 generate
        pio_pad : iopad generic map (tech => padtech)
            port map (pio(i), gpioo.dout(i), gpioo.oen(i), gpioi.din(i));
    end generate;

  end generate;

  ahbs : if CFG_AHBSTAT = 1 generate	-- AHB status register
    ahbstat0 : ahbstat generic map (pindex => 15, paddr => 15, pirq => 7,
	nftslv => CFG_AHBSTATN)
      port map (rstn, clkm, ahbmi, ahbsi, stati, apbi, apbo(15));
  end generate;

-----------------------------------------------------------------------
---  ETHERNET ---------------------------------------------------------
-----------------------------------------------------------------------

    eth0 : if CFG_GRETH = 1 generate -- Gaisler ethernet MAC
      e1 : grethm generic map(
	hindex => CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG+CFG_SVGA_ENABLE, 
	pindex => 13, paddr => 13, pirq => 13, memtech => memtech,
        mdcscaler => CPU_FREQ/1000, enable_mdio => 1, fifosize => CFG_ETH_FIFO,
        nsync => 1, edcl => CFG_DSU_ETH, edclbufsz => CFG_ETH_BUF,
        macaddrh => CFG_ETH_ENM, macaddrl => CFG_ETH_ENL, enable_mdint => 1,
	ipaddrh => CFG_ETH_IPM, ipaddrl => CFG_ETH_IPL, giga => CFG_GRETH1G)
      port map( rst => rstn, clk => clkm, ahbmi => ahbmi,
        ahbmo => ahbmo(CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG+CFG_SVGA_ENABLE), 
	apbi => apbi, apbo => apbo(13), ethi => ethi, etho => etho); 
    end generate;

    ethpads : if (CFG_GRETH = 1) generate -- eth pads
      emdio_pad : iopad generic map (tech => padtech) 
      port map (emdio, etho.mdio_o, etho.mdio_oe, ethi.mdio_i);
      etxc_pad : clkpad generic map (tech => padtech, arch => 2) 
	port map (etx_clk, ethi.tx_clk);
      erxc_pad : clkpad generic map (tech => padtech, arch => 2) 
	port map (erx_clk, ethi.rx_clk);
      erxd_pad : inpadv generic map (tech => padtech, width => 4) 
	port map (erxd, ethi.rxd(3 downto 0));
      erxdv_pad : inpad generic map (tech => padtech) 
	port map (erx_dv, ethi.rx_dv);
      erxer_pad : inpad generic map (tech => padtech) 
	port map (erx_er, ethi.rx_er);
      erxco_pad : inpad generic map (tech => padtech) 
	port map (erx_col, ethi.rx_col);
      erxcr_pad : inpad generic map (tech => padtech) 
	port map (erx_crs, ethi.rx_crs);
      emdint_pad : inpad generic map (tech => padtech) 
	port map (emdint, ethi.mdint);

      etxd_pad : outpadv generic map (tech => padtech, width => 4) 
	port map (etxd, etho.txd(3 downto 0));
      etxen_pad : outpad generic map (tech => padtech) 
	port map ( etx_en, etho.tx_en);
      etxer_pad : outpad generic map (tech => padtech) 
	port map (etx_er, etho.tx_er);
      emdc_pad : outpad generic map (tech => padtech) 
	port map (emdc, etho.mdc);
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
---  Multi-core CAN ---------------------------------------------------
-----------------------------------------------------------------------

   can0 : if CFG_CAN = 1 generate 
     can0 : can_mc generic map (slvndx => 4, ioaddr => CFG_CANIO,
    	iomask => 16#FF0#, irq => CFG_CANIRQ, memtech => memtech,
	ncores => CFG_CAN_NUM, sepirq => CFG_CANSEPIRQ)
      port map (rstn, clkm, ahbsi, ahbso(4), can_lrx, can_ltx );
      can_tx_pad1 : iopad generic map (tech => padtech)
            port map (pio(5), can_ltx(0), gnd(0), gpioi.din(5));
      can_rx_pad1 : iopad generic map (tech => padtech)
            port map (pio(4), gnd(0), vcc(0), can_lrx(0));
      canpas : if CFG_CAN_NUM = 2 generate 
        can_tx_pad2 : iopad generic map (tech => padtech)
            port map (pio(2), can_ltx(1), gnd(0), gpioi.din(2));
        can_rx_pad2 : iopad generic map (tech => padtech)
            port map (pio(1), gnd(0), vcc(0), can_lrx(1));
      end generate;
   end generate;

   -- standby controlled by pio(3) and pio(0)

-----------------------------------------------------------------------
---  SpaceWire Light --------------------------------------------------
-----------------------------------------------------------------------

   spw0: spwamba
      generic map (
         tech        => memtech,
         hindex      => CFG_NCPU+CFG_AHB_UART+CFG_GRETH+CFG_AHB_JTAG+CFG_SVGA_ENABLE,
         pindex      => 10,
         paddr       => 10,
         pirq        => 10,
         sysfreq     => real(CPU_FREQ) * 1000.0,
         txclkfreq   => 200.0e6,
         rximpl      => impl_fast,
         rxchunk     => 4,
         tximpl      => impl_fast,
         timecodegen => true,
         rxfifosize  => 8,
         txfifosize  => 8,
         desctablesize => 10,
         maxburst    => 3 )
      port map (
         clk     => clkm,
         rxclk   => spw_clkl,
         txclk   => spw_clkl,
         rstn    => rstn,
         apbi    => apbi,
         apbo    => apbo(10),
         ahbi    => ahbmi,
         ahbo    => ahbmo(CFG_NCPU+CFG_AHB_UART+CFG_GRETH+CFG_AHB_JTAG+CFG_SVGA_ENABLE),
         tick_in => spw_tick_in,
         tick_out => open,
         spw_di  => spw_di,
         spw_si  => spw_si,
         spw_do  => spw_do,
         spw_so  => spw_so );

   spw_rxd_pad: inpad_ds
      generic map (padtech, lvds, x25v)
      port map (spw_rxdp(0), spw_rxdn(0), spw_di);
   spw_rxs_pad: inpad_ds
      generic map (padtech, lvds, x25v)
      port map (spw_rxsp(0), spw_rxsn(0), spw_si);
   spw_txd_pad: outpad_ds
      generic map (padtech, lvds, x25v)
      port map (spw_txdp(0), spw_txdn(0), spw_do, '0');
   spw_txs_pad: outpad_ds
      generic map (padtech, lvds, x25v)
      port map (spw_txsp(0), spw_txsn(0), spw_so, '0');

   -- Use 2nd GPTIMER unit to generate external tick_in signal.
   spw_tick_in <= gpto.tick(2) when CFG_GPT_ENABLE /= 0 else '0';

   -- Generate 200 MHz clock for fast receiver/transmitter.
   spwclk0: DCM
      generic map (
         CLKFX_DIVIDE       => 1,
         CLKFX_MULTIPLY     => 4,
         CLK_FEEDBACK       => "NONE",
         CLKIN_DIVIDE_BY_2  => false,
         CLKIN_PERIOD       => 20.0,
         CLKOUT_PHASE_SHIFT => "NONE",
         DESKEW_ADJUST      => "SYSTEM_SYNCHRONOUS",
         DFS_FREQUENCY_MODE => "LOW",
         DUTY_CYCLE_CORRECTION => true,
         STARTUP_WAIT       => false )
      port map (
         CLKIN      => lclk,
         RST        => not rstraw,
         CLKFX      => spw_clkl );

-------------------------------------------------------------------------------
--- USB -----------------------------------------------------------------------
-------------------------------------------------------------------------------
  -- Note that the GRUSBDC and GRUSB_DCL can not be instantiated at the same
  -- time (board has only one USB transceiver), therefore they share AHB
  -- master/slave indexes
  -----------------------------------------------------------------------------
  -- Shared pads
  -----------------------------------------------------------------------------
  usbpads: if (CFG_GRUSBDC + CFG_GRUSB_DCL) /= 0 generate
    usb_clk_pad : clkpad generic map (tech => padtech, arch => 2)
      port map (usb_clkout, uclk);
    
    usb_d_pad: iopadv generic map(tech => padtech, width => 16, slew => 1)
      port map (usb_d, usbo.dataout, usbo.oen, usbi.datain);
  
    usb_txready_pad : inpad generic map (tech => padtech)
      port map (usb_txready,usbi.txready);
    usb_rxvalid_pad : inpad generic map (tech => padtech)
      port map (usb_rxvalid,usbi.rxvalid);
    usb_rxerror_pad : inpad generic map (tech => padtech)
      port map (usb_rxerror,usbi.rxerror);
    usb_rxactive_pad : inpad generic map (tech => padtech)
      port map (usb_rxactive,usbi.rxactive);
    usb_linestate_pad : inpadv generic map (tech => padtech, width => 2)
      port map (usb_linestate,usbi.linestate);
    usb_vbus_pad : inpad generic map (tech => padtech)
      port map (usb_vbus, usbi.vbusvalid);
    
    usb_reset_pad : outpad generic map (tech => padtech, slew => 1)
      port map (usb_reset,usbo.reset);
    usb_suspend_pad : outpad generic map (tech => padtech, slew => 1)
      port map (usb_suspend,usbo.suspendm);
    usb_termsel_pad : outpad generic map (tech => padtech, slew => 1)
      port map (usb_termsel,usbo.termselect);
    usb_xcvrsel_pad : outpad generic map (tech => padtech, slew => 1)
      port map (usb_xcvrsel,usbo.xcvrselect(0));
    usb_txvalid_pad : outpad generic map (tech => padtech, slew => 1)
      port map (usb_txvalid,usbo.txvalid);
    usb_opmode_pad : outpadv generic map (tech =>padtech ,width =>2, slew =>1)
      port map (usb_opmode,usbo.opmode);

    usb_validh_pad:iopad generic map(tech => padtech, slew => 1)
      port map (usb_validh, usbo.txvalidh, usbo.oen, usbi.rxvalidh);

  end generate;
  
  -----------------------------------------------------------------------------
  -- USB 2.0 Device Controller
  -----------------------------------------------------------------------------
  usbdc0: if CFG_GRUSBDC = 1 generate
    usbdc0: grusbdc
      generic map(
        hsindex => 5, hirq => 9, haddr => 16#004#, hmask => 16#FFC#,        
        hmindex => CFG_NCPU+CFG_AHB_UART+CFG_GRETH+CFG_AHB_JTAG+
        CFG_SVGA_ENABLE+CFG_SPW_NUM*CFG_SPW_EN,
        aiface => CFG_GRUSBDC_AIFACE, uiface => 0, dwidth => CFG_GRUSBDC_DW,
        nepi => CFG_GRUSBDC_NEPI, nepo => CFG_GRUSBDC_NEPO,
        i0 => CFG_GRUSBDC_I0, i1 => CFG_GRUSBDC_I1,
        i2 => CFG_GRUSBDC_I2, i3 => CFG_GRUSBDC_I3,
        i4 => CFG_GRUSBDC_I4, i5 => CFG_GRUSBDC_I5,
        i6 => CFG_GRUSBDC_I6, i7 => CFG_GRUSBDC_I7,
        i8 => CFG_GRUSBDC_I8, i9 => CFG_GRUSBDC_I9,
        i10 => CFG_GRUSBDC_I10, i11 => CFG_GRUSBDC_I11,
        i12 => CFG_GRUSBDC_I12, i13 => CFG_GRUSBDC_I13,
        i14 => CFG_GRUSBDC_I14, i15 => CFG_GRUSBDC_I15,
        o0 => CFG_GRUSBDC_O0, o1 => CFG_GRUSBDC_O1,
        o2 => CFG_GRUSBDC_O2, o3 => CFG_GRUSBDC_O3,
        o4 => CFG_GRUSBDC_O4, o5 => CFG_GRUSBDC_O5,
        o6 => CFG_GRUSBDC_O6, o7 => CFG_GRUSBDC_O7,
        o8 => CFG_GRUSBDC_O8, o9 => CFG_GRUSBDC_O9,
        o10 => CFG_GRUSBDC_O10, o11 => CFG_GRUSBDC_O11,
        o12 => CFG_GRUSBDC_O12, o13 => CFG_GRUSBDC_O13,
        o14 => CFG_GRUSBDC_O14, o15 => CFG_GRUSBDC_O15,
        memtech => memtech)
      port map(
        uclk  => uclk,
        usbi  => usbi,
        usbo  => usbo,
        hclk  => clkm,
        hrst  => rstn,
        ahbmi => ahbmi,
        ahbmo => ahbmo(CFG_NCPU+CFG_AHB_UART+CFG_GRETH+CFG_AHB_JTAG+
                       CFG_SVGA_ENABLE+CFG_SPW_NUM*CFG_SPW_EN),
        ahbsi => ahbsi,
        ahbso => ahbso(5)
        );
  end generate usbdc0;

  -----------------------------------------------------------------------------
  -- USB DCL
  -----------------------------------------------------------------------------
  usb_dcl0: if CFG_GRUSB_DCL = 1 generate
    usb_dcl0: grusb_dcl
      generic map (
        hindex => CFG_NCPU+CFG_AHB_UART+CFG_GRETH+CFG_AHB_JTAG+
        CFG_SVGA_ENABLE+CFG_SPW_NUM*CFG_SPW_EN,
        memtech => memtech, uiface => 0, dwidth => CFG_GRUSB_DCL_DW)
      port map (
        uclk, usbi, usbo, clkm, rstn, ahbmi,
        ahbmo(CFG_NCPU+CFG_AHB_UART+CFG_GRETH+CFG_AHB_JTAG+CFG_SVGA_ENABLE+
              CFG_SPW_NUM*CFG_SPW_EN));
  end generate usb_dcl0;
  
-----------------------------------------------------------------------
---  Drive unused bus elements  ---------------------------------------
-----------------------------------------------------------------------

--  nam1 : for i in (CFG_NCPU+CFG_AHB_UART+CFG_GRETH+CFG_AHB_JTAG) to NAHBMST-1 generate
--    ahbmo(i) <= ahbm_none;
--  end generate;
--  nap0 : for i in 11 to NAPBSLV-1 generate apbo(i) <= apb_none; end generate;
--  nah0 : for i in 8 to NAHBSLV-1 generate ahbso(i) <= ahbs_none; end generate;

-----------------------------------------------------------------------
---  Boot message  ----------------------------------------------------
-----------------------------------------------------------------------

-- pragma translate_off
  x : report_version 
  generic map (
   msg1 => "LEON3 GR-XC3S-1500 Demonstration design",
      msg2 => "GRLIB Version " & tost(LIBVHDL_VERSION/1000) & "." & tost((LIBVHDL_VERSION mod 1000)/100)
        & "." & tost(LIBVHDL_VERSION mod 100) & ", build " & tost(LIBVHDL_BUILD),
   msg3 => "Target technology: " & tech_table(fabtech) & ",  memory library: " & tech_table(memtech),
   mdel => 1
  );
-- pragma translate_on
end;
