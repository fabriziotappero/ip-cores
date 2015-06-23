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
library techmap;
use techmap.gencomp.all;

library gaisler;
use gaisler.memctrl.all;
use gaisler.leon3.all;
use gaisler.uart.all;
use gaisler.misc.all;
use gaisler.can.all;
use gaisler.net.all;
use gaisler.jtag.all;

library esa;
use esa.memoryctrl.all;

use work.config.all;

entity leon3mp is
  generic (
    fabtech   : integer := CFG_FABTECH;
    memtech   : integer := CFG_MEMTECH;
    padtech   : integer := CFG_PADTECH;
    clktech   : integer := CFG_CLKTECH;
    disas     : integer := CFG_DISAS;	-- Enable disassembly to console
    dbguart   : integer := CFG_DUART;	-- Print UART on console
    pclow     : integer := CFG_PCLOW
  );
  port (
    pb_sw  	: in  std_logic_vector (4 downto 1); 	-- push buttons
    pll_clk	: in  std_ulogic;			-- PLL clock
    led    	: out std_logic_vector(8 downto 1);
    flash_a 	: out std_logic_vector(20 downto 0);
    flash_d	: inout std_logic_vector(15 downto 0);
    sdram_a    	: out std_logic_vector(11 downto 0);
    sdram_d   	: inout std_logic_vector(31 downto 0);
    sdram_ba   	: out std_logic_vector(3 downto 0);
    sdram_dqm  	: out std_logic_vector(3 downto 0);
    sdram_clk  	: inout std_ulogic;
    sdram_cke  	: out std_ulogic;    			-- sdram clock enable
    sdram_csn  	: out std_ulogic;    			-- sdram chip select
    sdram_wen  	: out std_ulogic;                       -- sdram write enable
    sdram_rasn  : out std_ulogic;                       -- sdram ras
    sdram_casn  : out std_ulogic;                       -- sdram cas

    uart1_txd  	: out std_ulogic;
    uart1_rxd  	: in  std_ulogic;
    uart1_rts  	: out std_ulogic;
    uart1_cts  	: in  std_ulogic;

    uart2_txd  	: out std_ulogic;
    uart2_rxd  	: in  std_ulogic;
    uart2_rts  	: out std_ulogic;
    uart2_cts  	: in  std_ulogic;

    flash_oen  	: out std_ulogic;
    flash_wen 	: out std_ulogic;
    flash_cen  	: out std_ulogic;
    flash_byte 	: out std_ulogic;
    flash_ready	: in  std_ulogic;
    flash_rpn 	: out std_ulogic;
    flash_wpn 	: out std_ulogic;

    phy_mii_data: inout std_logic;		-- ethernet PHY interface
    phy_tx_clk 	: in std_ulogic;
    phy_rx_clk 	: in std_ulogic;
    phy_rx_data	: in std_logic_vector(3 downto 0);   
    phy_dv  	: in std_ulogic; 
    phy_rx_er  	: in std_ulogic; 
    phy_col 	: in std_ulogic;
    phy_crs 	: in std_ulogic;
    phy_tx_data : out std_logic_vector(3 downto 0);   
    phy_tx_en 	: out std_ulogic; 
    phy_mii_clk : out std_ulogic;
    phy_100 	: in std_ulogic;		-- 100 Mbit indicator
    phy_rst_n 	: out std_ulogic;

    gpio     	: inout std_logic_vector(CFG_GRGPIO_WIDTH-1 downto 0);
--    lcd_data 	: inout std_logic_vector(7 downto 0);
--    lcd_rs	: out std_ulogic;
--    lcd_rw	: out std_ulogic;
--    lcd_en	: out std_ulogic;
--    lcd_backl	: out std_ulogic;

    can_txd	: out std_ulogic;
    can_rxd	: in  std_ulogic;

    smsc_addr 	: out std_logic_vector(14 downto 0);
    smsc_data 	: inout std_logic_vector(31 downto 0);
    smsc_nbe  	: out std_logic_vector(3 downto 0);
    smsc_resetn	: out std_ulogic;
    smsc_ardy  	: in  std_ulogic;
--    smsc_intr  	: in  std_ulogic;
    smsc_nldev 	: in  std_ulogic;
    smsc_nrd   	: out std_ulogic;
    smsc_nwr   	: out std_ulogic;
    smsc_ncs   	: out std_ulogic;
    smsc_aen   	: out std_ulogic;
    smsc_lclk  	: out std_ulogic;
    smsc_wnr   	: out std_ulogic;
    smsc_rdyrtn	: out std_ulogic;
    smsc_cycle 	: out std_ulogic;
    smsc_nads  	: out std_ulogic
	);
end;

architecture rtl of leon3mp is

signal vcc, gnd   : std_logic_vector(7 downto 0);
signal wpo   : wprot_out_type;
signal sdi   : sdctrl_in_type;
signal sdo  : sdram_out_type;

signal apbi  : apb_slv_in_type;
signal apbo  : apb_slv_out_vector := (others => apb_none);
signal ahbsi : ahb_slv_in_type;
signal ahbso : ahb_slv_out_vector := (others => ahbs_none);
signal ahbmi : ahb_mst_in_type;
signal ahbmo : ahb_mst_out_vector := (others => ahbm_none);

signal clkm, rstn, rstraw, pciclk, sdclkl : std_ulogic;
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

signal ethi, ethi1, ethi2 : eth_in_type;
signal etho, etho1, etho2 : eth_out_type;

signal gpti : gptimer_in_type;
signal gpioi : gpio_in_type;
signal gpioo : gpio_out_type;

signal can_lrx, can_ltx   : std_ulogic;
signal lclk, pci_lclk, sdfb : std_ulogic;
signal tck, tms, tdi, tdo : std_ulogic;

signal resetn : std_ulogic;
signal pbsw   : std_logic_vector(4 downto 1);
signal ledo   : std_logic_vector(8 downto 1);

signal memi  : memory_in_type;
signal memo  : memory_out_type;

  --for smc lan chip
signal s_eth_aen   : std_logic; 
signal s_eth_readn : std_logic; 
signal s_eth_writen: std_logic; 
signal s_eth_nbe   : std_logic_vector(3 downto 0);
signal s_eth_din   : std_logic_vector(31 downto 0);

constant ahbmmax : integer := CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG+ CFG_GRETH;
constant BOARD_FREQ : integer := 50000; -- board frequency in KHz
constant CPU_FREQ : integer := (BOARD_FREQ*CFG_CLKMUL)/CFG_CLKDIV; -- cpu frequency in KHz
begin

----------------------------------------------------------------------
---  Reset and Clock generation  -------------------------------------
----------------------------------------------------------------------

  vcc <= (others => '1'); gnd <= (others => '0');

  sdram_clk_pad : skew_outpad
    generic map (tech => padtech, slew => 1, strength => 24, skew => -60)
    port map (sdram_clk, sdclkl, rstn);
  cgi.pllctrl <= "00"; cgi.pllrst <= rstraw; 
  resetn <= pbsw(4);
  ledo(2) <= not cgo.clklock;
  ledo(3) <= pbsw(3);

  clk_pad : clkpad generic map (tech => padtech) port map (pll_clk, lclk); 
  clkgen0 : clkgen  		-- clock generator
    generic map (clktech, CFG_CLKMUL, CFG_CLKDIV, CFG_MCTRL_SDEN, 
	CFG_CLK_NOFB, 0, 0, 0, BOARD_FREQ)
    port map (lclk, pci_lclk, clkm, open, open, sdclkl, pciclk, cgi, cgo);

  rst0 : rstgen			-- reset generator
  port map (resetn, clkm, cgo.clklock, rstn, rstraw);

----------------------------------------------------------------------
---  AHB CONTROLLER --------------------------------------------------
----------------------------------------------------------------------

  ahb0 : ahbctrl 		-- AHB arbiter/multiplexer
  generic map (defmast => CFG_DEFMST, split => CFG_SPLIT, 
	rrobin => CFG_RROBIN, ioaddr => CFG_AHBIO,
	nahbm => ahbmmax, nahbs => 8)
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
          CFG_LDDEL, disas, CFG_ITBSZ, CFG_PWD, CFG_SVT, CFG_RSTADDR, CFG_NCPU-1)
      port map (clkm, rstn, ahbmi, ahbmo(i), ahbsi, ahbso, 
      		irqi(i), irqo(i), dbgi(i), dbgo(i));
    end generate;
    ledo(8) <= dbgo(0).error;
  
    dsugen : if CFG_DSU = 1 generate
      dsu0 : dsu3			-- LEON3 Debug Support Unit
      generic map (hindex => 2, haddr => 16#900#, hmask => 16#F00#, 
         ncpu => CFG_NCPU, tbits => 30, tech => memtech, irq => 0, kbytes => CFG_ATBSZ)
      port map (rstn, clkm, ahbmi, ahbsi, ahbso(2), dbgo, dbgi, dsui, dsuo);
      dsui.enable <= '1'; dsui.break <= pbsw(1); ledo(1) <= not dsuo.active;
    end generate;
  end generate;

  nodcom : if CFG_DSU = 0 generate 
    ahbso(2) <= ahbs_none; dsuo.tstop <= '0'; dsuo.active <= '0';
  end generate;

  dcomgen : if CFG_AHB_UART = 1 generate
    dcom0: ahbuart		-- Debug UART
    generic map (hindex => CFG_NCPU, pindex => 7, paddr => 7)
    port map (rstn, clkm, dui, duo, apbi, apbo(7), ahbmi, ahbmo(CFG_NCPU));
    dui.rxd <= u2i.rxd; u2o.txd <= duo.txd; u2o.rtsn <= gnd(0);
  end generate;
  nouah : if CFG_AHB_UART = 0 generate apbo(7) <= apb_none; end generate;

  ahbjtaggen0 :if CFG_AHB_JTAG = 1 generate
    ahbjtag0 : ahbjtag generic map(tech => fabtech, hindex => CFG_NCPU+CFG_AHB_UART)
      port map(rstn, clkm, tck, tms, tdi, tdo, ahbmi, ahbmo(CFG_NCPU+CFG_AHB_UART),
               open, open, open, open, open, open, open, gnd(0));
  end generate;

----------------------------------------------------------------------
---  PROM/SDRAM Memory controller ------------------------------------
----------------------------------------------------------------------

  memi.brdyn <= '1'; memi.bexcn <= '1';
  memi.writen <= '1'; memi.wrn <= "1111"; memi.bwidth <= "00";

  mg2 : if CFG_MCTRL_LEON2 = 1 generate 	-- LEON2 memory controller
    sr1 : entity work.smc_mctrl generic map (hindex => 0, pindex => 0, paddr => 0, 
	srbanks => 4+CFG_MCTRL_5CS, sden => CFG_MCTRL_SDEN, 
	ram8 => CFG_MCTRL_RAM8BIT, ram16 => CFG_MCTRL_RAM16BIT, 
	invclk => CFG_MCTRL_INVCLK, sepbus => CFG_MCTRL_SEPBUS, 
	sdbits => 32 + 32*CFG_MCTRL_SD64)
    port map (rstn, clkm, memi, memo, ahbsi, ahbso(0), apbi, apbo(0), 
	wpo, sdo, s_eth_aen, s_eth_readn, s_eth_writen, s_eth_nbe, s_eth_din);

    addr_pad : outpadv generic map (width => 21, tech => padtech) 
	port map (flash_a(20 downto 0), memo.address(21 downto 1)); 
    roms_pad : outpad generic map (tech => padtech) 
	port map (flash_cen, memo.romsn(0)); 
    oen_pad  : outpad generic map (tech => padtech) 
	port map (flash_oen, memo.oen);
    wri_pad  : outpad generic map (tech => padtech) 
	port map (flash_wen, memo.writen);
    data_pad : iopadv generic map (tech => padtech, width => 8)
      port map (flash_d(7 downto 0), memo.data(31 downto 24),
	memo.bdrive(0), memi.data(31 downto 24));
    data15_pad : iopad generic map (tech => padtech)
      port map (flash_d(15), memo.address(0), gnd(0), open);


      sa_pad : outpadv generic map (width => 12, tech => padtech) 
	   port map (sdram_a, memo.sa(11 downto 0));
      sba1_pad : outpadv generic map (width => 2, tech => padtech) 
	   port map (sdram_ba(1 downto 0), memo.sa(14 downto 13));
      sba2_pad : outpadv generic map (width => 2, tech => padtech) 
	   port map (sdram_ba(3 downto 2), memo.sa(14 downto 13));

      bdr : for i in 0 to 3 generate
          sd_pad : iopadv generic map (tech => padtech, width => 8)
          port map (sdram_d(31-i*8 downto 24-i*8), memo.data(31-i*8 downto 24-i*8),
		memo.bdrive(i), memi.sd(31-i*8 downto 24-i*8));
      end generate;

      sdcke_pad : outpad generic map (tech => padtech) 
	   port map (sdram_cke, sdo.sdcke(0)); 
      sdwen_pad : outpad generic map (tech => padtech) 
	   port map (sdram_wen, sdo.sdwen);
      sdcsn_pad : outpad generic map (tech => padtech) 
	   port map (sdram_csn, sdo.sdcsn(0)); 
      sdras_pad : outpad generic map (tech => padtech) 
	   port map (sdram_rasn, sdo.rasn);
      sdcas_pad : outpad generic map (tech => padtech) 
	   port map (sdram_casn, sdo.casn);
      sddqm_pad : outpadv generic map (width => 4, tech => padtech) 
	   port map (sdram_dqm, sdo.dqm(3 downto 0));

  end generate;

  nosd0 : if (CFG_MCTRL_SDEN = 0) generate 		-- no SDRAM controller
      sdcke_pad : outpad generic map (tech => padtech) 
	   port map (sdram_cke, gnd(0)); 
      sdcsn_pad : outpad generic map (tech => padtech) 
	   port map (sdram_csn, vcc(0)); 
  end generate;

----------------------------------------------------------------------
---  APB Bridge and various periherals -------------------------------
----------------------------------------------------------------------

  bpromgen : if CFG_AHBROMEN /= 0 generate
    brom : entity work.ahbrom
      generic map (hindex => 4, haddr => CFG_AHBRODDR, pipe => CFG_AHBROPIP)
      port map ( rstn, clkm, ahbsi, ahbso(4));
  end generate;
  nobpromgen : if CFG_AHBROMEN = 0 generate
     ahbso(4) <= ahbs_none;
  end generate;

----------------------------------------------------------------------
---  APB Bridge and various periherals -------------------------------
----------------------------------------------------------------------

  apb0 : apbctrl				-- AHB/APB bridge
  generic map (hindex => 1, haddr => CFG_APBADDR)
  port map (rstn, clkm, ahbsi, ahbso(1), apbi, apbo );

  ua1 : if CFG_UART1_ENABLE /= 0 generate
    uart1 : apbuart			-- UART 1
    generic map (pindex => 1, paddr => 1,  pirq => 2, console => dbguart,
	fifosize => CFG_UART1_FIFO)
    port map (rstn, clkm, apbi, apbo(1), u1i, u1o);
    u1i.extclk <= '0';
  end generate;
  noua0 : if CFG_UART1_ENABLE = 0 generate apbo(1) <= apb_none; end generate;
  ua1rx_pad : inpad generic map (tech => padtech) port map (uart1_rxd, u1i.rxd); 
  ua1tx_pad : outpad generic map (tech => padtech) port map (uart1_txd, u1o.txd);
  ua1cts_pad : inpad generic map (tech => padtech) port map (uart1_cts, u1i.ctsn); 
  ua1rts_pad : outpad generic map (tech => padtech) port map (uart1_rts, u1o.rtsn);

  ua2 : if (CFG_UART2_ENABLE /= 0) and (CFG_AHB_UART = 0) generate
    uart2 : apbuart			-- UART 2
    generic map (pindex => 9, paddr => 9,  pirq => 3, fifosize => CFG_UART2_FIFO)
    port map (rstn, clkm, apbi, apbo(9), u2i, u2o);
    u2i.extclk <= '0';
  end generate;
  noua1 : if CFG_UART2_ENABLE = 0 generate apbo(9) <= apb_none; end generate;
  ua2rx_pad : inpad generic map (tech => padtech) port map (uart2_rxd, u2i.rxd); 
  ua2tx_pad : outpad generic map (tech => padtech) port map (uart2_txd, u2o.txd);
  ua2cts_pad : inpad generic map (tech => padtech) port map (uart2_cts, u2i.ctsn); 
  ua2rts_pad : outpad generic map (tech => padtech) port map (uart2_rts, u2o.rtsn);

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
	nbits => CFG_GPT_TW, wdog => CFG_GPT_WDOG)
    port map (rstn, clkm, apbi, apbo(3), gpti, open);
    gpti.dhalt <= dsuo.tstop; gpti.extclk <= '0';
  end generate;
  notim : if CFG_GPT_ENABLE = 0 generate apbo(3) <= apb_none; end generate;

  gpio0 : if CFG_GRGPIO_ENABLE /= 0 generate     -- GPIO unit
    grgpio0: grgpio
    generic map(pindex => 5, paddr => 5, imask => CFG_GRGPIO_IMASK, nbits => CFG_GRGPIO_WIDTH)
    port map(rst => rstn, clk => clkm, apbi => apbi, apbo => apbo(5),
    gpioi => gpioi, gpioo => gpioo);
    pio_pads : for i in 0 to CFG_GRGPIO_WIDTH-1 generate
        pio_pad : iopad generic map (tech => padtech)
            port map (gpio(i), gpioo.dout(i), gpioo.oen(i), gpioi.din(i));
    end generate;
  end generate;

-----------------------------------------------------------------------
---  ETHERNET ---------------------------------------------------------
-----------------------------------------------------------------------

  eth0 : if CFG_GRETH = 1 generate -- Gaisler ethernet MAC
      e1 : greth generic map(hindex => CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG,
	pindex => 15, paddr => 15, pirq => 12, memtech => memtech,
        mdcscaler => CPU_FREQ/1000, enable_mdio => 1, fifosize => CFG_ETH_FIFO,
        nsync => 1, edcl => CFG_DSU_ETH, edclbufsz => CFG_ETH_BUF,
        macaddrh => CFG_ETH_ENM, macaddrl => CFG_ETH_ENL, 
	ipaddrh => CFG_ETH_IPM, ipaddrl => CFG_ETH_IPL)
     port map( rst => rstn, clk => clkm, ahbmi => ahbmi,
       ahbmo => ahbmo(CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG), apbi => apbi,
       apbo => apbo(15), ethi => ethi, etho => etho); 
  end generate;

    ethpads : if CFG_GRETH = 0 generate -- no eth 
      etho <= ('0', "00000000", '0', '0', '0', '0', '1');
    end generate;

    emdio_pad : iopad generic map (tech => padtech) 
      port map (phy_mii_data, etho.mdio_o, etho.mdio_oe, ethi.mdio_i);
    etxc_pad : clkpad generic map (tech => padtech, arch => 0) 
	port map (phy_tx_clk, ethi.tx_clk);
    erxc_pad : clkpad generic map (tech => padtech, arch => 0) 
	port map (phy_rx_clk, ethi.rx_clk);
    erxd_pad : inpadv generic map (tech => padtech, width => 4) 
	port map (phy_rx_data, ethi.rxd(3 downto 0));
    erxdv_pad : inpad generic map (tech => padtech) 
	port map (phy_dv, ethi.rx_dv);
    erxer_pad : inpad generic map (tech => padtech) 
	port map (phy_rx_er, ethi.rx_er);
    erxco_pad : inpad generic map (tech => padtech) 
	port map (phy_col, ethi.rx_col);
    erxcr_pad : inpad generic map (tech => padtech) 
	port map (phy_crs, ethi.rx_crs);

    etxd_pad : outpadv generic map (tech => padtech, width => 4) 
	port map (phy_tx_data, etho.txd(3 downto 0));
    etxen_pad : outpad generic map (tech => padtech) 
	port map ( phy_tx_en, etho.tx_en);
    emdc_pad : outpad generic map (tech => padtech) 
	port map (phy_mii_clk, etho.mdc);

    ereset_pad : outpad generic map (tech => padtech) 
	port map (phy_rst_n, rstn);

-----------------------------------------------------------------------
---  CAN --------------------------------------------------------------
-----------------------------------------------------------------------
   can0 : if CFG_CAN = 1 generate 
     can0 : can_oc generic map (slvndx => 6, ioaddr => CFG_CANIO,
    	iomask => 16#FF0#, irq => CFG_CANIRQ, memtech => memtech)
      port map (rstn, clkm, ahbsi, ahbso(6), can_lrx, can_ltx );
   end generate;
   ncan : if CFG_CAN = 0 generate ahbso(6) <= ahbs_none; end generate;

   can_loopback : if CFG_CANLOOP = 1 generate 
     can_lrx <= can_ltx;
   end generate;

   can_pads : if CFG_CANLOOP = 0 generate 
      can_tx_pad : outpad generic map (tech => padtech) 
	port map (can_txd, can_ltx);
      can_rx_pad : inpad generic map (tech => padtech) 
	port map (can_rxd, can_lrx);
    end generate;

-----------------------------------------------------------------------
---  AHB RAM ----------------------------------------------------------
-----------------------------------------------------------------------

  ocram : if CFG_AHBRAMEN = 1 generate 
    ahbram0 : ahbram generic map (hindex => 7, haddr => CFG_AHBRADDR, 
	tech => CFG_MEMTECH, kbytes => CFG_AHBRSZ)
    port map ( rstn, clkm, ahbsi, ahbso(7));
  end generate;
  nram : if CFG_AHBRAMEN = 0 generate ahbso(7) <= ahbs_none; end generate;

-----------------------------------------------------------------------
---  I/O interface  ---------------------------------------------------
-----------------------------------------------------------------------

  pb_sw_pad : inpadv generic map (width => 4, tech => padtech) 
    port map (pb_sw, pbsw); 
  led_pad : outpadv generic map (width => 8, tech => padtech) 
    port map (led, ledo);

  byte_pad  : outpad generic map (tech => padtech) port map (flash_byte, gnd(0));
  rpn_pad   : outpad generic map (tech => padtech) port map (flash_rpn, rstn);
  wpn_pad   : outpad generic map (tech => padtech) port map (flash_wpn, vcc(0));
  ready_pad : inpad generic map (tech => padtech) port map (flash_ready, open); 

  smsc_data_pads : for i in 0 to 3 generate
      data_pad : iopadv generic map (tech => padtech, width => 8)
        port map (smsc_data(31-i*8 downto 24-i*8), memo.data(31-i*8 downto 24-i*8),
                  memo.bdrive(i), s_eth_din(31-i*8 downto 24-i*8));
  end generate;

  smsc_addr_pad : outpadv generic map (tech => padtech, width => 15) 
    port map (smsc_addr, memo.address(15 downto 1));
  smsc_nbe_pad : outpadv generic map (tech => padtech, width => 4) 
    port map (smsc_nbe, s_eth_nbe);
  smsc_reset_pad : outpad generic map (tech => padtech) 
    port map (smsc_resetn, rstn);
  smsc_nrd_pad : outpad generic map (tech => padtech) 
    port map (smsc_nrd, s_eth_readn);
  smsc_nwr_pad : outpad generic map (tech => padtech) 
    port map (smsc_nwr, s_eth_writen);
  smsc_ncs_pad : outpad generic map (tech => padtech) 
    port map (smsc_ncs, memo.iosn);
  smsc_aen_pad : outpad generic map (tech => padtech) 
    port map (smsc_aen, s_eth_aen);
  smsc_lclk_pad : outpad generic map (tech => padtech) 
    port map (smsc_lclk, vcc(0));
  smsc_wnr_pad : outpad generic map (tech => padtech) 
    port map (smsc_wnr, vcc(0));
  smsc_rdyrtn_pad : outpad generic map (tech => padtech) 
    port map (smsc_rdyrtn, vcc(0));
  smsc_cycle_pad : outpad generic map (tech => padtech) 
    port map (smsc_cycle, vcc(0));
  smsc_nads_pad : outpad generic map (tech => padtech) 
    port map (smsc_nads, gnd(0));

--  lcd_data_pad : iopadv generic map (width => 8, tech => padtech) 
--    port map (lcd_data, nuo.lcd_data, nuo.lcd_ben, nui.lcd_data);
--  lcd_rs_pad : outpad generic map (tech => padtech) 
--    port map (lcd_rs, nuo.lcd_rs);
--  lcd_rw_pad : outpad generic map (tech => padtech) 
--    port map (lcd_rw, nuo.lcd_rw );
--  lcd_en_pad : outpad generic map (tech => padtech)
--    port map (lcd_en, nuo.lcd_en);
--  lcd_backl_pad : outpad generic map (tech => padtech) 
--    port map (lcd_backl, nuo.lcd_backl);

-----------------------------------------------------------------------
---  Drive unused bus elements  ---------------------------------------
-----------------------------------------------------------------------

--  nam1 : for i in (CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG) to NAHBMST-1 generate
--    ahbmo(i) <= ahbm_none;
--  end generate;
--  nap0 : for i in 11 to NAPBSLV-1-CFG_GRETH generate apbo(i) <= apb_none; end generate;
  apbo(6) <= apb_none;

-----------------------------------------------------------------------
---  Boot message  ----------------------------------------------------
-----------------------------------------------------------------------

-- pragma translate_off
  x : report_version 
  generic map (
   msg1 => "LEON3 Demonstration design for Nuhorizon SP3 board",
   msg2 => "GRLIB Version " & tost(LIBVHDL_VERSION/1000) & "." & tost((LIBVHDL_VERSION mod 1000)/100)
        & "." & tost(LIBVHDL_VERSION mod 100) & ", build " & tost(LIBVHDL_BUILD),
   msg3 => "Target technology: " & tech_table(fabtech) & ",  memory library: " & tech_table(memtech),
   mdel => 1
  );
-- pragma translate_on
end;
