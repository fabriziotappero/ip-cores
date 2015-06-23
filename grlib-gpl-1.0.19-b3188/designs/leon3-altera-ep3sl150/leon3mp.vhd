------------------------------------------------------------------------------
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
use gaisler.net.all;
use gaisler.misc.all;
use gaisler.jtag.all;
library esa;
use esa.memoryctrl.all;
use work.config.all;

entity leon3mp is
  generic (
    fabtech : integer := CFG_FABTECH;
    memtech : integer := CFG_MEMTECH;
    padtech : integer := CFG_PADTECH;
    clktech : integer := CFG_CLKTECH;
    ncpu    : integer := CFG_NCPU;
    disas   : integer := CFG_DISAS;     -- Enable disassembly to console
    dbguart : integer := CFG_DUART;     -- Print UART on console
    pclow   : integer := CFG_PCLOW;
    freq    : integer := 50000;         -- frequency of main clock (used for PLLs)
    dbits   : integer := CFG_DDR2SP_DATAWIDTH 
    );
  port (

    resetn  : in  std_ulogic;
    clk     : in  std_ulogic;
    clk125  : in  std_ulogic;
    errorn  : out   std_ulogic;

    -- debug support unit
    dsubren             : in  std_ulogic;
    dsuact              : out std_ulogic;

    -- console/debug UART
    --rxd1 : in  std_logic;
    --txd1 : out std_logic;

    gpio         : in std_logic_vector(CFG_GRGPIO_WIDTH-1 downto 0); 	-- I/O port
    
    -- flash/ssram bus
    address : out   std_logic_vector(24 downto 0);
    data    : inout std_logic_vector(31 downto 0);
    
    rstoutn     : out std_ulogic;
    sram_advn   : out std_ulogic;
    sram_csn  	: out std_logic;
    sram_wen 	  : out std_logic;
    sram_ben   	: out std_logic_vector (0 to 3);
    sram_oen    : out std_ulogic;
    sram_clk  	: out std_ulogic;
    sram_psn    : out std_ulogic;
    sram_wait   : in std_logic_vector(1 downto 0);

    flash_clk   : out std_ulogic;
    flash_advn  : out std_logic;
    flash_cen   : out std_logic;
    flash_oen   : out std_logic;
    flash_resetn: out std_logic;
    flash_wen   : out std_logic;

    max_csn     : out std_logic;

--    sram_adsp_n : out std_ulogic;

-- pragma translate_off
    iosn    : out   std_ulogic;
-- pragma translate_on

    ddr_clk  	: out std_logic_vector(2 downto 0);
    ddr_clkb  	: out std_logic_vector(2 downto 0);
    ddr_cke  	: out std_logic_vector(1 downto 0);
    ddr_csb  	: out std_logic_vector(1 downto 0);
    ddr_odt  	: out std_logic_vector(1 downto 0);
    ddr_web  	: out std_ulogic;                       -- ddr write enable
    ddr_rasb  	: out std_ulogic;                       -- ddr ras

    ddr_casb  	: out std_ulogic;                       -- ddr cas
    ddr_dm   	: out std_logic_vector (8 downto 0);    -- ddr dm
    ddr_dqsp  	: inout std_logic_vector (8 downto 0);    -- ddr dqs
    ddr_dqsn  	: inout std_logic_vector (8 downto 0);    -- ddr dqs
    ddr_ad      : out std_logic_vector (15 downto 0);   -- ddr address
    ddr_ba      : out std_logic_vector (2 downto 0);    -- ddr bank address
    ddr_dq  	: inout std_logic_vector (71 downto 0); -- ddr data

--    ddra_cke  	: out std_logic;
    ddra_csb  	: out std_logic;
--    ddra_web    : out std_ulogic;                       -- ddr write enable
--    ddra_rasb  	: out std_ulogic;                       -- ddr ras
--    ddra_casb   : out std_ulogic;                       -- ddr cas
--    ddra_ad     : out std_logic_vector (14 downto 0);   -- ddr address
--    ddra_ba     : out std_logic_vector (2 downto 0);    -- ddr bank address
--    
--    ddrb_cke  	: out std_logic;
    ddrb_csb  	: out std_logic;
--    ddrb_web    : out std_ulogic;                       -- ddr write enable
--    ddrb_rasb  	: out std_ulogic;                       -- ddr ras
--    ddrb_casb   : out std_ulogic;                       -- ddr cas
--    ddrb_ad     : out std_logic_vector (14 downto 0);   -- ddr address
--    ddrb_ba     : out std_logic_vector (2 downto 0);    -- ddr bank address
--    
--    ddrab_clk  	: inout std_logic_vector(1 downto 0);
--    ddrab_clkb  : inout std_logic_vector(1 downto 0);
--    ddrab_odt  	: out std_logic_vector(1 downto 0);
--    ddrab_dqsp  : inout std_logic_vector(1 downto 0);   -- ddr dqs
--    ddrab_dqsn  : inout std_logic_vector(1 downto 0);   -- ddr dqs
--    ddrab_dm   	: out std_logic_vector(1 downto 0);     -- ddr dm
--    ddrab_dq    : inout std_logic_vector (15 downto 0);-- ddr data

    phy_gtx_clk : out std_logic;
    phy_mii_data: inout std_logic;		-- ethernet PHY interface
    phy_tx_clk 	: in std_ulogic;
    phy_rx_clk 	: in std_ulogic;
    phy_rx_data	: in std_logic_vector(7 downto 0);   
    phy_dv  	: in std_ulogic; 
    phy_rx_er	: in std_ulogic; 
    phy_col 	: in std_ulogic;
    phy_crs 	: in std_ulogic;
    phy_tx_data : out std_logic_vector(7 downto 0);   
    phy_tx_en 	: out std_ulogic; 
    phy_tx_er 	: out std_ulogic; 
    phy_mii_clk	: out std_ulogic;
    phy_rst_n	: out std_ulogic

    );
end;

architecture rtl of leon3mp is
  
  constant blength   : integer := 12;
  constant fifodepth : integer := 8;

  constant maxahbm : integer := NCPU+CFG_AHB_UART+CFG_AHB_JTAG+CFG_GRETH;

  signal vcc, gnd    : std_logic_vector(7 downto 0);
  signal memi, smemi : memory_in_type;
  signal memo, smemo : memory_out_type;
  signal wpo         : wprot_out_type;
  
  signal ddsi  : ddrmem_in_type;
  signal ddso  : ddrmem_out_type;

  signal ddrclkfb, ssrclkfb, ddr_clkl, ddr_clk90l, ddr_clknl, ddr_clk270l : std_ulogic;
  signal ddr_clkv 	: std_logic_vector(2 downto 0);
  signal ddr_clkbv	: std_logic_vector(2 downto 0);
  signal ddr_ckev  	: std_logic_vector(1 downto 0);
  signal ddr_csbv  	: std_logic_vector(1 downto 0);
  signal ddr_adl      	: std_logic_vector (13 downto 0);
  signal clklock, lock, clkml, rst, ndsuact : std_ulogic;
  signal tck, tckn, tms, tdi, tdo : std_ulogic;
  signal ddrclk, ddrrst : std_ulogic;
  signal ddr_clk_fb     : std_ulogic;
  
--  -- DDR2 Device A&B
--  signal ddrab_clkv 	: std_logic_vector(2 downto 0);
--  signal ddrab_clkbv	: std_logic_vector(2 downto 0);
--  signal ddra_ckev  	: std_logic_vector(1 downto 0);
--  signal ddra_csbv  	: std_logic_vector(1 downto 0);
--  signal ddrb_ckev  	: std_logic_vector(1 downto 0);
--  signal ddrb_csbv  	: std_logic_vector(1 downto 0);
--  signal lockab       : std_logic;
--  signal clkmlab      : std_logic;

--  attribute syn_keep : boolean;
--  attribute syn_preserve : boolean;
--  attribute syn_keep of clkml : signal is true;
--  attribute syn_preserve of clkml : signal is true;

  signal apbi  : apb_slv_in_type;
  signal apbo  : apb_slv_out_vector := (others => apb_none);
  signal ahbsi : ahb_slv_in_type;
  signal ahbso : ahb_slv_out_vector := (others => ahbs_none);
  signal ahbmi : ahb_mst_in_type;
  signal ahbmo : ahb_mst_out_vector := (others => ahbm_none);

  signal clkm, rstn, sram_clkl : std_ulogic;
  signal cgi,cgi2           : clkgen_in_type;
  signal cgo,cgo2           : clkgen_out_type;
  signal u1i, dui           : uart_in_type;
  signal u1o, duo           : uart_out_type;

  signal irqi : irq_in_vector(0 to NCPU-1);
  signal irqo : irq_out_vector(0 to NCPU-1);

  signal dbgi : l3_debug_in_vector(0 to NCPU-1);
  signal dbgo : l3_debug_out_vector(0 to NCPU-1);

  signal dsui : dsu_in_type;
  signal dsuo : dsu_out_type;

  signal ethi, ethi1, ethi2 : eth_in_type;
  signal etho, etho1, etho2 : eth_out_type;
  signal ethclk, egtx_clk_fb : std_ulogic;
  signal egtx_clk, legtx_clk, l2egtx_clk : std_ulogic;

  signal gpti : gptimer_in_type;
  signal gpioi : gpio_in_type;
  signal gpioo : gpio_out_type;

  constant IOAEN : integer := 1;
  constant BOARD_FREQ : integer := 50000;   -- input frequency in KHz
  constant CPU_FREQ : integer := BOARD_FREQ * CFG_CLKMUL / CFG_CLKDIV;  -- cpu frequency in KHz

  signal lclk, lclkout, lclk125, clkm125  : std_ulogic;
  
  signal dsubre : std_ulogic;

begin

----------------------------------------------------------------------
---  Reset and Clock generation  -------------------------------------
----------------------------------------------------------------------

  vcc <= (others => '1'); gnd <= (others => '0');
  cgi.pllctrl <= "00"; cgi.pllrst <= not resetn; cgi.pllref <= '0'; 
  cgi2.pllctrl <= "00"; cgi2.pllrst <= not resetn; cgi2.pllref <= '0'; 

  clklock <=  cgo.clklock and lock;
  clk_pad : clkpad generic map (tech => padtech) port map (clk, lclk);
  
  clk125_pad : clkpad generic map (tech => padtech) port map (clk125, lclk125);

  clkgen0 : clkgen  -- clock generator using toplevel generic 'freq'
    generic map (tech => CFG_CLKTECH, clk_mul => CFG_CLKMUL,
                 clk_div => CFG_CLKDIV, sdramen => 1,
                 freq => freq)
    port map (clkin => lclk, pciclkin => gnd(0), clk => clkm, clkn => open,
              clk2x => open, sdclk => sram_clkl, pciclk => open,
              cgi => cgi, cgo => cgo);
  clkm125 <= lclk125;
  phy_gtx_clk <= lclk125; 

  ssrclk_pad : outpad generic map (tech => padtech, slew => 1, strength => 24) 
    port map (sram_clk, sram_clkl);
  
  flashclk_pad : outpad generic map (tech => padtech, slew => 1, strength => 24) 
    port map (flash_clk, sram_clkl);
  
  rst0 : rstgen                         -- reset generator
    port map (resetn, clkm, clklock, rstn);

  rstoutn <= resetn;

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
      u0 : leon3s                         -- LEON3 processor
        generic map (i, fabtech, memtech, CFG_NWIN, CFG_DSU, CFG_FPU, CFG_V8,
                   0, CFG_MAC, pclow, 0, CFG_NWP, CFG_ICEN, CFG_IREPL, CFG_ISETS, CFG_ILINE,
                   CFG_ISETSZ, CFG_ILOCK, CFG_DCEN, CFG_DREPL, CFG_DSETS, CFG_DLINE, CFG_DSETSZ,
                   CFG_DLOCK, CFG_DSNOOP, CFG_ILRAMEN, CFG_ILRAMSZ, CFG_ILRAMADDR, CFG_DLRAMEN,
                   CFG_DLRAMSZ, CFG_DLRAMADDR, CFG_MMUEN, CFG_ITLBNUM, CFG_DTLBNUM, CFG_TLB_TYPE, CFG_TLB_REP,
                   CFG_LDDEL, disas, CFG_ITBSZ, CFG_PWD, CFG_SVT, CFG_RSTADDR, NCPU-1)
        port map (clkm, rstn, ahbmi, ahbmo(i), ahbsi, ahbso,
                irqi(i), irqo(i), dbgi(i), dbgo(i));
    end generate;
    errorn_pad : outpad generic map (tech => padtech) port map (errorn, dbgo(0).error);

    dsugen : if CFG_DSU = 1 generate
      dsu0 : dsu3                         -- LEON3 Debug Support Unit
        generic map (hindex => 2, haddr => 16#900#, hmask => 16#F00#,
                   ncpu   => NCPU, tbits => 30, tech => memtech, irq => 0, kbytes => CFG_ATBSZ)
        port map (rstn, clkm, ahbmi, ahbsi, ahbso(2), dbgo, dbgi, dsui, dsuo);
    
      dsui.enable <= '1';
    
      dsubre_pad : inpad generic map (tech  => padtech) port map (dsubre, dsui.break);
      dsuact_pad : outpad generic map (tech => padtech) port map (dsuact, dsuo.active);
    end generate;
  end generate;
  nodcom : if CFG_DSU = 0 generate ahbso(2) <= ahbs_none; end generate;

--  dcomgen : if CFG_AHB_UART = 1 generate
--    dcom0 : ahbuart                     -- Debug UART
--      generic map (hindex => NCPU, pindex => 4, paddr => 7)
--      port map (rstn, clkm, dui, duo, apbi, apbo(4), ahbmi, ahbmo(NCPU));
--    dsurx_pad : inpad generic map (tech  => padtech) port map (rxd1, dui.rxd);
--    dsutx_pad : outpad generic map (tech => padtech) port map (txd1, duo.txd);
--  end generate;
--  nouah : if CFG_AHB_UART = 0 generate apbo(4) <= apb_none; end generate;

  ahbjtaggen0 :if CFG_AHB_JTAG = 1 generate
    ahbjtag0 : ahbjtag generic map(tech => fabtech, hindex => NCPU+CFG_AHB_UART)
      port map(rstn, clkm, tck, tms, tdi, tdo, ahbmi, ahbmo(NCPU+CFG_AHB_UART),
               open, open, open, open, open, open, open, gnd(0));
  end generate;

----------------------------------------------------------------------
---  Memory controllers ----------------------------------------------
----------------------------------------------------------------------

  mg2 : if CFG_MCTRL_LEON2 = 1 generate 	-- LEON2 memory controller
    sr1 :mctrl generic map (hindex => 0, pindex => 0, paddr => 0, 
	ramaddr => 16#a00#, rammask =>16#F00#, srbanks => 1, 
	sden => 0, ram16 => 1)
    port map (rstn, clkm, memi, memo, ahbsi, ahbso(0), apbi, apbo(0), wpo);
  end generate;

  memi.brdyn  <= '1'; memi.bexcn <= '1';
  memi.writen <= '1'; memi.wrn <= "1111"; memi.bwidth <= "01";

  mg0 : if (CFG_MCTRL_LEON2 + CFG_SSCTRL) = 0 generate	-- no prom/sram pads
    apbo(0) <= apb_none; ahbso(0) <= ahbs_none;
    srams_pad : outpad generic map ( tech => padtech) 
      port map (sram_csn, vcc(0)); 
    flash_cen_pad : outpad generic map (tech => padtech) 
	    port map (flash_cen, vcc(0)); 
  end generate;

  mgpads : if (CFG_MCTRL_LEON2 + CFG_SSCTRL) /= 0 generate	-- prom/sram pads
    addr_pad : outpadv generic map (width => 25, tech => padtech)
      port map (address, memo.address(25 downto 1));
    srams_pad : outpad generic map ( tech => padtech) 
      port map (sram_csn, memo.ramsn(0)); 
    sram_oen_pad  : outpad generic map (tech => padtech) 
      port map (sram_oen, memo.oen);
    sram_rwen_pad : outpadv generic map (width => 4, tech => padtech) 
      port map (sram_ben, memo.wrn); 
    sram_wri_pad  : outpad generic map (tech => padtech) 
      port map (sram_wen, memo.writen);
    data_pad : iopadvv generic map (tech => padtech, width => 32)
        port map (data(31 downto 0), memo.data(31 downto 0),
                  memo.vbdrive, memi.data(31 downto 0));
    sram_advn_pad : outpad generic map (tech => padtech) 
	    port map (sram_advn, gnd(0)); 
    sram_psn_pad : outpad generic map (tech => padtech) 
	    port map (sram_psn, vcc(0)); 
    flash_advn_pad : outpad generic map (tech => padtech) 
	    port map (flash_advn, gnd(0)); 
    flash_cen_pad : outpad generic map (tech => padtech) 
	    port map (flash_cen, memo.romsn(0)); 
    flash_oen_pad  : outpad generic map (tech => padtech) 
      port map (flash_oen, memo.oen);
    flash_wri_pad  : outpad generic map (tech => padtech) 
      port map (flash_wen, memo.writen);
    flash_reset_pad  : outpad generic map (tech => padtech) 
      port map (flash_resetn, resetn);
    
-- pragma translate_off
   iosn_pad : outpad generic map (tech => padtech)
      port map (iosn, memo.iosn);
-- pragma translate_on
   
  end generate;
  
  max_csn_pad : outpad generic map (tech => padtech) 
	  port map (max_csn, vcc(0)); 

  ddrsp0 : if (CFG_DDR2SP /= 0) generate 
    ddrc0 : ddr2spa generic map ( fabtech => fabtech, 
                                  memtech => memtech, 
      hindex => 3, haddr => 16#400#, hmask => 16#C00#, ioaddr => 1, 
      pwron => CFG_DDR2SP_INIT, MHz => 125000/1000, rskew => 0, TRFC => CFG_DDR2SP_TRFC,
      clkmul => (CFG_DDR2SP_FREQ*5)/125, clkdiv => 5, ahbfreq => CPU_FREQ/1000,
      col => CFG_DDR2SP_COL, Mbyte => CFG_DDR2SP_SIZE, ddrbits => dbits,
      ddelayb0 => CFG_DDR2SP_DELAY0, ddelayb1 => CFG_DDR2SP_DELAY1, 
      ddelayb2 => CFG_DDR2SP_DELAY2, ddelayb3 => CFG_DDR2SP_DELAY3, 
      ddelayb4 => CFG_DDR2SP_DELAY4, ddelayb5 => CFG_DDR2SP_DELAY5,
      ddelayb6 => CFG_DDR2SP_DELAY6, ddelayb7 => CFG_DDR2SP_DELAY7,
      numidelctrl => 3, norefclk => 0, odten => 3, readdly => 1)
    port map ( resetn, rstn, clkm125, clkm, clkm125, lock, clkml, clkml, ahbsi, ahbso(3),
               ddr_clkv, ddr_clkbv, ddr_clk_fb, ddr_clk_fb, ddr_ckev, ddr_csbv, ddr_web, ddr_rasb, ddr_casb, 
               ddr_dm(dbits/8-1 downto 0), ddr_dqsp(dbits/8-1 downto 0), ddr_dqsn(dbits/8-1 downto 0), 
               ddr_ad(13 downto 0), ddr_ba(1 downto 0), ddr_dq(dbits-1 downto 0), ddr_odt);
    ddr_clk <= ddr_clkv(2 downto 0); ddr_clkb <= ddr_clkbv(2 downto 0);
    ddr_cke <= ddr_ckev(1 downto 0); ddr_csb <= ddr_csbv(1 downto 0);
    ddr_ad(15 downto 14) <= (others => '0');
    ddr_ba(2) <= '0';
  end generate;

  noddr :  if (CFG_DDR2SP = 0) generate lock <= '1'; end generate;
  
  -- Disable DDR2 Device A and B
  ddra_csb <= '1';
  ddrb_csb <= '1';

-----------------------------------------------------------------------
---  ETHERNET ---------------------------------------------------------
-----------------------------------------------------------------------

    eth1 : if CFG_GRETH = 1 generate -- Gaisler ethernet MAC
      e1 : grethm generic map(hindex => NCPU+CFG_AHB_UART+CFG_AHB_JTAG, 
	pindex => 11, paddr => 11, pirq => 12, memtech => memtech,
        mdcscaler => CPU_FREQ/1000, enable_mdio => 1, fifosize => CFG_ETH_FIFO,
        nsync => 2, edcl => CFG_DSU_ETH, edclbufsz => CFG_ETH_BUF,
        macaddrh => CFG_ETH_ENM, macaddrl => CFG_ETH_ENL, phyrstadr => 18,
	ipaddrh => CFG_ETH_IPM, ipaddrl => CFG_ETH_IPL, giga => CFG_GRETH1G)
      port map( rst => rstn, clk => clkm, ahbmi => ahbmi,
        ahbmo => ahbmo(NCPU+CFG_AHB_UART+CFG_AHB_JTAG), 
	apbi => apbi, apbo => apbo(11), ethi => ethi, etho => etho); 

      emdio_pad : iopad generic map (tech => padtech) 
      port map (phy_mii_data, etho.mdio_o, etho.mdio_oe, ethi.mdio_i);
      etxc_pad : clkpad generic map (tech => padtech, arch => 2) 
	port map (phy_tx_clk, ethi.tx_clk);
      erxc_pad : clkpad generic map (tech => padtech, arch => 2) 
	port map (phy_rx_clk, ethi.rx_clk);
      erxd_pad : inpadv generic map (tech => padtech, width => 8) 
	port map (phy_rx_data, ethi.rxd(7 downto 0));
      erxdv_pad : inpad generic map (tech => padtech) 
	port map (phy_dv, ethi.rx_dv);
      erxer_pad : inpad generic map (tech => padtech) 
	port map (phy_rx_er, ethi.rx_er);
      erxco_pad : inpad generic map (tech => padtech) 
	port map (phy_col, ethi.rx_col);
      erxcr_pad : inpad generic map (tech => padtech) 
	port map (phy_crs, ethi.rx_crs);

      etxd_pad : outpadv generic map (tech => padtech, width => 8) 
	port map (phy_tx_data, etho.txd(7 downto 0));
      etxen_pad : outpad generic map (tech => padtech) 
	port map ( phy_tx_en, etho.tx_en);
      etxer_pad : outpad generic map (tech => padtech) 
	port map (phy_tx_er, etho.tx_er);
      emdc_pad : outpad generic map (tech => padtech) 
	port map (phy_mii_clk, etho.mdc);
      erst_pad : outpad generic map (tech => padtech) 
	port map (phy_rst_n, rstn);

      ethi.gtx_clk <= egtx_clk;

    end generate;

----------------------------------------------------------------------
---  APB Bridge and various periherals -------------------------------
----------------------------------------------------------------------

  apb0 : apbctrl                        -- AHB/APB bridge
    generic map (hindex => 1, haddr => CFG_APBADDR)
    port map (rstn, clkm, ahbsi, ahbso(1), apbi, apbo);

  ua1 : if CFG_UART1_ENABLE /= 0 generate
    uart1 : apbuart                     -- UART 1
      generic map (pindex   => 1, paddr => 1, pirq => 2, console => dbguart,
                   fifosize => CFG_UART1_FIFO)
      port map (rstn, clkm, apbi, apbo(1), u1i, u1o);
    u1i.ctsn <= '0'; u1i.extclk <= '0';
    -- loopback
    u1i.rxd <= u1o.txd;
    --upads : if CFG_AHB_UART = 0 generate
    --  u1i.rxd <= rxd1; txd1 <= u1o.txd;
    --end generate;
  end generate;
  noua0 : if CFG_UART1_ENABLE = 0 generate apbo(1) <= apb_none; end generate;

  irqctrl : if CFG_IRQ3_ENABLE /= 0 generate
    irqctrl0 : irqmp                    -- interrupt controller
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
    timer0 : gptimer                    -- timer unit
      generic map (pindex => 3, paddr => 3, pirq => CFG_GPT_IRQ,
        sepirq => CFG_GPT_SEPIRQ, sbits => CFG_GPT_SW, ntimers => CFG_GPT_NTIM,
        nbits  => CFG_GPT_TW)
      port map (rstn, clkm, apbi, apbo(3), gpti, open);
    gpti.dhalt <= dsuo.active; gpti.extclk <= '0';
  end generate;
  notim : if CFG_GPT_ENABLE = 0 generate apbo(3) <= apb_none; end generate;
  
  gpio0 : if CFG_GRGPIO_ENABLE /= 0 generate     -- GPIO unit
    grgpio0: grgpio
    generic map(pindex => 5, paddr => 5, imask => CFG_GRGPIO_IMASK, nbits => CFG_GRGPIO_WIDTH)
    port map(rst => rstn, clk => clkm, apbi => apbi, apbo => apbo(5),
    gpioi => gpioi, gpioo => gpioo);
    pio_pads : for i in 0 to CFG_GRGPIO_WIDTH-1 generate
	gpioi.din(i) <= gpio(i);
    end generate;
  end generate;

-----------------------------------------------------------------------
---  AHB ROM ----------------------------------------------------------
-----------------------------------------------------------------------

  bpromgen : if CFG_AHBROMEN /= 0 generate
    brom : entity work.ahbrom
      generic map (hindex => 6, haddr => CFG_AHBRODDR, pipe => CFG_AHBROPIP)
      port map ( rstn, clkm, ahbsi, ahbso(6));
  end generate;
  nobpromgen : if CFG_AHBROMEN = 0 generate
     ahbso(6) <= ahbs_none;
  end generate;

-----------------------------------------------------------------------
---  AHB RAM ----------------------------------------------------------
-----------------------------------------------------------------------

  ahbramgen : if CFG_AHBRAMEN = 1 generate
    ahbram0 : ahbram generic map (hindex => 7, haddr => CFG_AHBRADDR,
                                  tech   => CFG_MEMTECH, kbytes => CFG_AHBRSZ)
      port map (rstn, clkm, ahbsi, ahbso(7));
  end generate;
  nram : if CFG_AHBRAMEN = 0 generate ahbso(7) <= ahbs_none; end generate;

-----------------------------------------------------------------------
---  Drive unused bus elements  ---------------------------------------
-----------------------------------------------------------------------

  nam1 : for i in (NCPU+CFG_AHB_UART+CFG_AHB_JTAG+CFG_GRETH) to NAHBMST-1 generate
    ahbmo(i) <= ahbm_none;
  end generate;
--  nap0 : for i in 6 to NAPBSLV-1 generate apbo(i) <= apb_none; end generate;
--  nah0 : for i in 7 to NAHBSLV-1 generate ahbso(i) <= ahbs_none; end generate;

  -- invert signal for input via a key
  dsubre  <= not dsubren;

-----------------------------------------------------------------------
---  Boot message  ----------------------------------------------------
-----------------------------------------------------------------------

-- pragma translate_off
  x : report_version 
  generic map (
   msg1 => "LEON3 Altera EP3SL150 PSRAM/DDR Demonstration design",
   msg2 => "GRLIB Version " & tost(LIBVHDL_VERSION/1000) & "." & tost((LIBVHDL_VERSION mod 1000)/100)
      & "." & tost(LIBVHDL_VERSION mod 100) & ", build " & tost(LIBVHDL_BUILD),
   msg3 => "Target technology: " & tech_table(fabtech) & ",  memory library: " & tech_table(memtech),
   mdel => 1
  );
-- pragma translate_on

end;
