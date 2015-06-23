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
------------------------------------------------------------------------------
--  modified by Thomas Ameseder, Gleichmann Electronics 2004, 2005 to
--  support the use of an external AHB slave and different HPE board versions
------------------------------------------------------------------------------
--  further adapted from Hpe_compact to Hpe_mini (Feb. 2005)
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
use gaisler.net.all;
use gaisler.ata.all;
use gaisler.jtag.all;
library esa;
use esa.memoryctrl.all;
library gleichmann;
use gleichmann.hpi.all;
use gleichmann.dac.all;

use work.config.all;


entity leon3mini is
  generic (
    fabtech : integer := CFG_FABTECH;
    memtech : integer := CFG_MEMTECH;
    padtech : integer := CFG_PADTECH;
    clktech : integer := CFG_CLKTECH;
    disas   : integer := CFG_DISAS;     -- Enable disassembly to console
    dbguart : integer := CFG_DUART;     -- Print UART on console
    pclow   : integer := CFG_PCLOW;
    freq    : integer := 25000          -- frequency of main clock (used for PLLs)
    );
  port (
    resetn  : in  std_ulogic;
    resoutn : out std_logic;
    clk     : in  std_ulogic;

    errorn  : out   std_ulogic;
    address : out   std_logic_vector(15 downto 2);
    data    : inout std_logic_vector(31 downto 0);

-- pragma translate_off
    ramsn  : out std_logic_vector (4 downto 0);
    ramoen : out std_logic_vector (4 downto 0);
    rben   : out std_logic_vector(3 downto 0);
    rwen   : out std_logic_vector(3 downto 0);

    romsn  : out std_logic_vector (1 downto 0);
    iosn   : out std_ulogic;
    oen    : out std_ulogic;
    read   : out std_ulogic;
    writen : out std_ulogic;
-- pragma translate_on

    sdcke  : out std_logic_vector (1 downto 0);  -- sdram clock enable
    sdcsn  : out std_logic_vector (1 downto 0);  -- sdram chip select
    sdwen  : out std_ulogic;                     -- sdram write enable
    sdrasn : out std_ulogic;                     -- sdram ras
    sdcasn : out std_ulogic;                     -- sdram cas
    sddqm  : out std_logic_vector (3 downto 0);  -- sdram dqm
    sdclk  : out std_ulogic;
    sdba   : out std_logic_vector(1 downto 0);   -- sdram bank address

    -- debug support unit
    dsuen   : in  std_ulogic;
    dsubre  : in  std_ulogic;
    dsuactn : out std_ulogic;

    -- UART for serial DCL/console I/O
    serrx     : in  std_ulogic;
    sertx     : out std_ulogic;
    sersrcsel : in  std_ulogic;

--    dsutx   : out std_ulogic;           -- DSU tx data
--    dsurx   : in  std_ulogic;           -- DSU rx data
--    rxd1 : in  std_ulogic;
--    txd1 : out std_ulogic;
--    gpio   : inout std_logic_vector(7 downto 0);  -- I/O port, unused at the moment

    -- ethernet signals
    emdio   : inout std_logic;          -- ethernet PHY interface
    etx_clk : in    std_ulogic;
    erx_clk : in    std_ulogic;
    erxd    : in    std_logic_vector(3 downto 0);
    erx_dv  : in    std_ulogic;
    erx_er  : in    std_ulogic;
    erx_col : in    std_ulogic;
    erx_crs : in    std_ulogic;
    etxd    : out   std_logic_vector(3 downto 0);
    etx_en  : out   std_ulogic;
    etx_er  : out   std_ulogic;
    emdc    : out   std_ulogic;

    ata_rst   : out   std_logic;
    ata_data  : inout std_logic_vector(15 downto 0);
    ata_da    : out   std_logic_vector(2 downto 0);
    ata_cs0   : out   std_logic;
    ata_cs1   : out   std_logic;
    ata_dior  : out   std_logic;
    ata_diow  : out   std_logic;
    ata_iordy : in    std_logic;
    ata_intrq : in    std_logic;
    ata_dmack : out   std_logic;

    sample_clock : out std_ulogic;

-------------------------------------------------------------------------------
-- HPI PORT
-------------------------------------------------------------------------------
    hpiaddr : out   std_logic_vector(1 downto 0);
    hpidata : inout std_logic_vector(15 downto 0);
    hpicsn  : out   std_ulogic;
    hpiwrn  : out   std_ulogic;
    hpirdn  : out   std_ulogic;
    hpiint  : in    std_ulogic;

    -- equality flag for R/W data
    dbg_equal : out std_ulogic;
-------------------------------------------------------------------------------


    dac       : out std_ulogic;
    vga_vsync : out std_ulogic;
    vga_hsync : out std_ulogic;
    vga_rd    : out std_logic_vector(1 downto 0);
    vga_gr    : out std_logic_vector(1 downto 0);
    vga_bl    : out std_logic_vector(1 downto 0)

    );
end;

architecture rtl of leon3mini is

  constant blength   : integer := 12;
  constant fifodepth : integer := 8;

  signal vcc, gnd   : std_logic_vector(4 downto 0);
  signal memi       : memory_in_type;
  signal memo       : memory_out_type;
  signal wpo        : wprot_out_type;
  signal sdi        : sdctrl_in_type;
  signal sdo        : sdram_out_type;
  signal sdo2, sdo3 : sdctrl_out_type;

  signal apbi  : apb_slv_in_type;
  signal apbo  : apb_slv_out_vector := (others => apb_none);
  signal ahbsi : ahb_slv_in_type;
  signal ahbso : ahb_slv_out_vector := (others => ahbs_none);
  signal ahbmi : ahb_mst_in_type;
  signal ahbmo : ahb_mst_out_vector := (others => ahbm_none);

  signal clkm, rstn, sdclkl : std_ulogic;
  signal cgi                : clkgen_in_type;
  signal cgo                : clkgen_out_type;
  signal u1i, dui           : uart_in_type;
  signal u1o, duo           : uart_out_type;

  signal irqi : irq_in_vector(0 to CFG_NCPU-1);
  signal irqo : irq_out_vector(0 to CFG_NCPU-1);

  signal dbgi : l3_debug_in_vector(0 to CFG_NCPU-1);
  signal dbgo : l3_debug_out_vector(0 to CFG_NCPU-1);

  signal dsui : dsu_in_type;
  signal dsuo : dsu_out_type;

  signal ethi, ethi1, ethi2 : eth_in_type;
  signal etho, etho1, etho2 : eth_out_type;

  signal atai : ata_in_type;
  signal atao : ata_out_type;

  signal gpti : gptimer_in_type;

  signal sa : std_logic_vector(14 downto 0);  -- ?
  signal sd : std_logic_vector(63 downto 0);  -- ?

  signal emddis : std_ulogic;
  signal ereset : std_ulogic;

  signal epwrdwn : std_ulogic;
  signal esleep  : std_ulogic;
  signal epause  : std_ulogic;

  signal tck, tms, tdi, tdo : std_ulogic;

-- Adaptions for HPE Compact

  signal dsuact         : std_logic;
  signal oen_ctrl       : std_logic;
  signal sdram_selected : std_logic;

  signal shortcut : std_logic;
  signal rx       : std_logic;
  signal tx       : std_logic;

  signal rxd1  : std_logic;
  signal txd1  : std_logic;
  signal dsutx : std_ulogic;            -- DSU tx data
  signal dsurx : std_ulogic;            -- DSU rx data

  ---------------------------------------------------------------------------------------
  -- HPI SIGNALS
  ---------------------------------------------------------------------------------------
--  signal hpiaddr      : std_logic_vector(1 downto 0);
--  signal hpidata      : std_logic_vector(15 downto 0);
--  signal hpicsn       : std_ulogic;
--  signal hpiwrn       : std_ulogic;
--  signal hpirdn       : std_ulogic;
--  signal hpiint       : std_ulogic;

  signal hpiwriten : std_ulogic;        -- intermediate signal
  signal hpirdata  : std_logic_vector(15 downto 0);
  signal hpiwdata  : std_logic_vector(15 downto 0);
  signal drive_bus : std_ulogic;

  signal dbg_rdata : std_logic_vector(15 downto 0);
  signal dbg_wdata : std_logic_vector(15 downto 0);
  ---------------------------------------------------------------------------------------

  signal vgao      : apbvga_out_type;
  signal video_clk : std_logic;
  signal clk_sel   : std_logic_vector(1 downto 0);

  constant BOARD_FREQ : integer := freq;  -- input frequency in KHz
  constant CPU_FREQ   : integer := BOARD_FREQ * CFG_CLKMUL / CFG_CLKDIV;  -- cpu frequency in KHz
begin

----------------------------------------------------------------------
---  Reset and Clock generation  -------------------------------------
----------------------------------------------------------------------

  vcc         <= (others => '1'); gnd <= (others => '0');
  cgi.pllctrl <= "00"; cgi.pllrst <= not resetn; cgi.pllref <= clk;  --'0'; --pllref;

  clkgen0 : clkgen                      -- clock generator using toplevel generic 'freq'
    generic map (tech    => CFG_CLKTECH, clk_mul => CFG_CLKMUL,
                 clk_div => CFG_CLKDIV, sdramen => CFG_MCTRL_SDEN,
                 noclkfb => CFG_CLK_NOFB, freq => freq)
    port map (clkin => clk, pciclkin => gnd(0), clk => clkm, clkn => open,
              clk2x => open, sdclk => sdclkl, pciclk => open,
              cgi   => cgi, cgo => cgo);

  rst0 : rstgen                         -- reset generator
    port map (resetn, clkm, cgo.clklock, rstn);

---------------------------------------------------------------------- 
---  AHB CONTROLLER --------------------------------------------------
----------------------------------------------------------------------

  ahb0 : ahbctrl                        -- AHB arbiter/multiplexer
    generic map (defmast => CFG_DEFMST, split => CFG_SPLIT,
                 rrobin  => CFG_RROBIN, ioaddr => CFG_AHBIO,
                 nahbm   => 8, nahbs => 8)
    port map (rstn, clkm, ahbmi, ahbmo, ahbsi, ahbso);

----------------------------------------------------------------------
---  LEON3 processor and DSU -----------------------------------------
----------------------------------------------------------------------

  l3 : if CFG_LEON3 = 1 generate
    cpu : for i in 0 to CFG_NCPU-1 generate
      u0 : leon3s                       -- LEON3 processor
        generic map (i, fabtech, memtech, CFG_NWIN, CFG_DSU, CFG_FPU, CFG_V8,
                     0, CFG_MAC, pclow, 0, CFG_NWP, CFG_ICEN, CFG_IREPL, CFG_ISETS, CFG_ILINE,
                     CFG_ISETSZ, CFG_ILOCK, CFG_DCEN, CFG_DREPL, CFG_DSETS, CFG_DLINE, CFG_DSETSZ,
                     CFG_DLOCK, CFG_DSNOOP, CFG_ILRAMEN, CFG_ILRAMSZ, CFG_ILRAMADDR, CFG_DLRAMEN,
                     CFG_DLRAMSZ, CFG_DLRAMADDR, CFG_MMUEN, CFG_ITLBNUM, CFG_DTLBNUM, CFG_TLB_TYPE, CFG_TLB_REP,
                     CFG_LDDEL, disas, CFG_ITBSZ, CFG_PWD, CFG_SVT, CFG_RSTADDR,
                     CFG_NCPU-1)
        port map (clkm, rstn, ahbmi, ahbmo(i), ahbsi, ahbso,
                  irqi(i), irqo(i), dbgi(i), dbgo(i));
    end generate;
    errorn_pad : odpad generic map (tech => padtech) port map (errorn, dbgo(0).error);

    dsugen : if CFG_DSU = 1 generate
      dsu0 : dsu3                       -- LEON3 Debug Support Unit
        generic map (hindex => 2, haddr => 16#900#, hmask => 16#F00#,
                     ncpu   => CFG_NCPU, tbits => 30, tech => memtech, irq => 0, kbytes => CFG_ATBSZ)
        port map (rstn, clkm, ahbmi, ahbsi, ahbso(2), dbgo, dbgi, dsui, dsuo);
      dsuen_pad  : inpad generic map (tech  => padtech) port map (dsuen, dsui.enable);
      --    **** tame: do not use inversion
      dsubre_pad : inpad generic map (tech  => padtech) port map (dsubre, dsui.break);
      dsuact_pad : outpad generic map (tech => padtech) port map (dsuact, dsuo.active);
    end generate;
  end generate;
  nodcom : if CFG_DSU = 0 generate ahbso(2) <= ahbs_none; end generate;

  dcomgen : if CFG_AHB_UART = 1 generate
    dcom0 : ahbuart                     -- Debug UART
      generic map (hindex => CFG_NCPU, pindex => 4, paddr => 7)
      port map (rstn, clkm, dui, duo, apbi, apbo(4), ahbmi, ahbmo(CFG_NCPU));
    dsurx_pad : inpad generic map (tech  => padtech) port map (dsurx, dui.rxd);
    dsutx_pad : outpad generic map (tech => padtech) port map (dsutx, duo.txd);
  end generate;
  nouah : if CFG_AHB_UART = 0 generate apbo(4) <= apb_none; end generate;

  ahbjtaggen0 : if CFG_AHB_JTAG = 1 generate
    ahbjtag0 : ahbjtag generic map(tech => fabtech, hindex => CFG_NCPU+CFG_AHB_UART)
      port map(rstn, clkm, tck, tms, tdi, tdo, ahbmi, ahbmo(CFG_NCPU+CFG_AHB_UART),
               open, open, open, open, open, open, open, gnd(0));
  end generate;

----------------------------------------------------------------------
---  Memory controllers ----------------------------------------------
----------------------------------------------------------------------

  mg2 : if CFG_MCTRL_LEON2 = 1 generate      -- LEON2 memory controller
    sr1 : mctrl generic map (hindex => 0, pindex => 0,
                             paddr  => 0, fast => 0, srbanks => 1, sden => CFG_MCTRL_SDEN)
      port map (rstn, clkm, memi, memo, ahbsi, ahbso(0), apbi, apbo(0), wpo, sdo);
    sdpads : if CFG_MCTRL_SDEN = 1 generate  -- SDRAM pads
      sdwen_pad : outpad generic map (tech => padtech)
        port map (sdwen, sdo.sdwen);
      sdras_pad : outpad generic map (tech => padtech)
        port map (sdrasn, sdo.rasn);
      sdcas_pad : outpad generic map (tech => padtech)
        port map (sdcasn, sdo.casn);
      sddqm_pad : outpadv generic map (width => 4, tech => padtech)
        port map (sddqm, sdo.dqm(3 downto 0));
      sdclk_pad : outpad generic map (tech   => padtech, slew => 1) port map (sdclk, sdclkl);
      sdcke_pad : outpadv generic map (width => 2, tech => padtech)
        port map (sdcke, sdo.sdcke);
      sdcsn_pad : outpadv generic map (width => 2, tech => padtech)
        port map (sdcsn, sdo.sdcsn);
    end generate;
    addr_pad : outpadv generic map (width => 14, tech => padtech)
      port map (address, memo.address(15 downto 2));
    bdr : for i in 0 to 3 generate
      data_pad : iopadv generic map (tech => padtech, width => 8)
        port map (data(31-i*8 downto 24-i*8), memo.data(31-i*8 downto 24-i*8),
                  memo.bdrive(i), memi.data(31-i*8 downto 24-i*8));
    end generate;
  end generate;

  nosd0 : if (CFG_MCTRL_SDEN = 0) generate  -- no SDRAM controller
    sdclk_pad : outpad generic map (tech   => padtech, slew => 1) port map (sdclk, sdclkl);
    sdcke_pad : outpadv generic map (width => 2, tech => padtech)
      port map (sdcke, sdo3.sdcke);
    sdcsn_pad : outpadv generic map (width => 2, tech => padtech)
      port map (sdcsn, sdo3.sdcsn);
  end generate;

  memi.brdyn  <= '1'; memi.bexcn <= '1';
  memi.writen <= '1'; memi.wrn <= "1111"; memi.bwidth <= "10";


-- pragma translate_off
  mgpads : if CFG_MCTRL_LEON2 = 1 generate
    rams_pad : outpadv generic map (width => 5, tech => padtech)
      port map (ramsn, memo.ramsn(4 downto 0));
    roms_pad : outpadv generic map (width => 2, tech => padtech)
      port map (romsn, memo.romsn(1 downto 0));
    oen_pad : outpad generic map (tech => padtech)
      port map (oen, memo.oen);
    rwen_pad : outpadv generic map (width => 4, tech => padtech)
      port map (rwen, memo.wrn);
    roen_pad : outpadv generic map (width => 5, tech => padtech)
      port map (ramoen, memo.ramoen(4 downto 0));
    wri_pad : outpad generic map (tech => padtech)
      port map (writen, memo.writen);
    read_pad : outpad generic map (tech => padtech)
      port map (read, memo.read);
    iosn_pad : outpad generic map (tech => padtech)
      port map (iosn, memo.iosn);
  end generate;
-- pragma translate_on

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
    u1i.rxd <= rxd1; u1i.ctsn <= '0'; u1i.extclk <= '0'; txd1 <= u1o.txd;
  end generate;
  noua0 : if CFG_UART1_ENABLE = 0 generate apbo(1) <= apb_none; end generate;

  irqctrl : if CFG_IRQ3_ENABLE /= 0 generate
    irqctrl0 : irqmp                    -- interrupt controller
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
    timer0 : gptimer                    -- timer unit
      generic map (pindex => 3, paddr => 3, pirq => CFG_GPT_IRQ,
                   sepirq => CFG_GPT_SEPIRQ, sbits => CFG_GPT_SW, ntimers => CFG_GPT_NTIM,
                   nbits  => CFG_GPT_TW)
      port map (rstn, clkm, apbi, apbo(3), gpti, open);
    gpti.dhalt <= dsuo.active; gpti.extclk <= '0';
  end generate;
  notim : if CFG_GPT_ENABLE = 0 generate apbo(3) <= apb_none; end generate;

  vga : if CFG_VGA_ENABLE /= 0 generate
    vga0 : apbvga generic map(memtech => memtech, pindex => 5, paddr => 6)
      port map(rstn, clkm, clk, apbi, apbo(5), vgao);
  end generate;
  vert_sync_pad : outpad generic map (tech => padtech)
    port map (vga_vsync, vgao.vsync);
  horiz_sync_pad : outpad generic map (tech => padtech)
    port map (vga_hsync, vgao.hsync);
  video_out_r_pad : outpadv generic map (width => 2, tech => padtech)
    port map (vga_rd, vgao.video_out_r(7 downto 6));
  video_out_g_pad : outpadv generic map (width => 2, tech => padtech)
    port map (vga_gr, vgao.video_out_g(7 downto 6));
  video_out_b_pad : outpadv generic map (width => 2, tech => padtech)
    port map (vga_bl, vgao.video_out_b(7 downto 6));

  svga : if CFG_SVGA_ENABLE /= 0 generate
    svga0 : svgactrl generic map(memtech => memtech, pindex => 6, paddr => 6,
                                 hindex  => CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG,
                                 clk0    => 40000, clk1 => 1000000000/((BOARD_FREQ * CFG_CLKMUL)/CFG_CLKDIV),
                                 clk2    => 20000, clk3 => 15385, burstlen => 6)
      port map(rstn, clkm, video_clk, apbi, apbo(6), vgao, ahbmi,
               ahbmo(CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG), clk_sel);
    video_clk <= clk when clk_sel = "00" else clkm;
  end generate;

  novga : if CFG_VGA_ENABLE+CFG_SVGA_ENABLE = 0 generate
    apbo(6) <= apb_none; vgao <= vgao_none;
  end generate;

-----------------------------------------------------------------------
---  ETHERNET ---------------------------------------------------------
-----------------------------------------------------------------------

  eth0 : if CFG_GRETH = 1 generate      -- Gaisler ethernet MAC
    e1 : greth generic map(hindex    => CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG+CFG_SVGA_ENABLE,
                           pindex    => 15, paddr => 15, pirq => 12, memtech => memtech,
                           mdcscaler => CPU_FREQ/1000, enable_mdio => 1, fifosize => CFG_ETH_FIFO,
                           nsync     => 1, edcl => CFG_DSU_ETH, edclbufsz => CFG_ETH_BUF,
                           macaddrh  => CFG_ETH_ENM, macaddrl => CFG_ETH_ENL,
                           ipaddrh   => CFG_ETH_IPM, ipaddrl => CFG_ETH_IPL)
      port map(rst    => rstn, clk => clkm, ahbmi => ahbmi,
                ahbmo => ahbmo(CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG+CFG_SVGA_ENABLE), apbi => apbi,
                apbo  => apbo(15), ethi => ethi, etho => etho); 

    emdio_pad : iopad generic map (tech => padtech)
      port map (emdio, etho.mdio_o, etho.mdio_oe, ethi.mdio_i);
    etxc_pad : inpad generic map (tech => padtech)
      port map (etx_clk, ethi.tx_clk);
    erxc_pad : inpad generic map (tech => padtech)
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

    etxd_pad : outpadv generic map (tech => padtech, width => 4)
      port map (etxd, etho.txd(3 downto 0));
    etxen_pad : outpad generic map (tech => padtech)
      port map (etx_en, etho.tx_en);
    etxer_pad : outpad generic map (tech => padtech)
      port map (etx_er, etho.tx_er);
    emdc_pad : outpad generic map (tech => padtech)
      port map (emdc, etho.mdc);

    emdis_pad : outpad generic map (tech => padtech)
      port map (emddis, vcc(0));
    eepwrdwn_pad : outpad generic map (tech => padtech)
      port map (epwrdwn, gnd(0));
    esleep_pad : outpad generic map (tech => padtech)
      port map (esleep, gnd(0));
    epause_pad : outpad generic map (tech => padtech)
      port map (epause, gnd(0));
    ereset_pad : outpad generic map (tech => padtech)
      port map (ereset, gnd(0));

  end generate;

-----------------------------------------------------------------------
---  ATA Controller ---------------------------------------------------
-----------------------------------------------------------------------
  atac : if CFG_ATA = 1 generate
    atac0 : atactrl
      generic map(
        shindex => 5,
        haddr   => CFG_ATAIO,
        hmask   => 16#fff#,
        pirq    => CFG_ATAIRQ,

        TWIDTH => 8,                    -- counter width

        -- PIO mode 0 settings (@100MHz clock)
        PIO_mode0_T1   => 6,            -- 70ns
        PIO_mode0_T2   => 28,           -- 290ns
        PIO_mode0_T4   => 2,            -- 30ns
        PIO_mode0_Teoc => 23            -- 240ns ==> T0 - T1 - T2 = 600 - 70 - 290 = 240
        )
      port map(
        rst   => rstn,
        arst  => '1',
        clk   => clkm,
        ahbsi => ahbsi,
        ahbso => ahbso(5),
        ahbmo => open,
        ahbmi => ahbmi,

        -- ATA signals
        atai => atai,
        atao => atao
        );

    ata_rst_pad : outpad generic map (tech => padtech)
      port map (ata_rst, atao.rstn);
    ata_data_pad : iopadv generic map (tech => padtech, width => 16, oepol => 1)
      port map (ata_data, atao.ddo, atao.oen, atai.ddi);
    ata_da_pad : outpadv generic map (tech => padtech, width => 3)
      port map (ata_da, atao.da);
    ata_cs0_pad : outpad generic map (tech => padtech)
      port map (ata_cs0, atao.cs0);
    ata_cs1_pad : outpad generic map (tech => padtech)
      port map (ata_cs1, atao.cs1);
    ata_dior_pad : outpad generic map (tech => padtech)
      port map (ata_dior, atao.dior);
    ata_diow_pad : outpad generic map (tech => padtech)
      port map (ata_diow, atao.diow);
    iordy_pad : inpad generic map (tech => padtech)
      port map (ata_iordy, atai.iordy);
    intrq_pad : inpad generic map (tech => padtech)
      port map (ata_intrq, atai.intrq);
    dmack_pad : outpad generic map (tech => padtech)
      port map (ata_dmack, atao.dmack);
  end generate;

-----------------------------------------------------------------------
---  AHB ROM ----------------------------------------------------------
-----------------------------------------------------------------------

  bpromgen : if CFG_AHBROMEN /= 0 generate
    brom : entity work.ahbrom
      generic map (hindex => 6, haddr => CFG_AHBRODDR, pipe => CFG_AHBROPIP)
      port map (rstn, clkm, ahbsi, ahbso(6));
  end generate;
  nobpromgen : if CFG_AHBROMEN = 0 generate
    ahbso(6) <= ahbs_none;
  end generate;

-----------------------------------------------------------------------
---  AHB RAM ----------------------------------------------------------
-----------------------------------------------------------------------

  ahbramgen : if CFG_AHBRAMEN = 1 generate
    ahbram0 : ahbram generic map (hindex => 3, haddr => CFG_AHBRADDR,
                                  tech   => CFG_MEMTECH, kbytes => CFG_AHBRSZ)
      port map (rstn, clkm, ahbsi, ahbso(3));
  end generate;
  nram : if CFG_AHBRAMEN = 0 generate ahbso(3) <= ahbs_none; end generate;

-----------------------------------------------------------------------
---  AHB DAC IF -------------------------------------------------------
-----------------------------------------------------------------------

  dac_ahb_inst : if CFG_DAC_AHB /= 0 generate
    dac_ahb_1 : dac_ahb
      generic map(length => 16, hindex => 4, haddr => 16#010#, hmask => 16#FFF#, tech => fabtech, kbytes => 1)
      port map(rst       => rstn, clk => clkm, ahbsi => ahbsi, ahbso => ahbso(4), dac_out => dac);
  end generate;
  ndac_ahb_inst : if CFG_DAC_AHB = 0 generate
    ahbso(4) <= ahbs_none;
  end generate;

  -----------------------------------------------------------------------------
  -- HPI SECTION
  -----------------------------------------------------------------------------

  ahb2hpi_inst : if CFG_AHB2HPI /= 0 generate
    ahb2hpi2_1 : ahb2hpi2
      generic map (
        counter_width => 4,
        data_width    => 16,
        address_width => 2,
        hindex        => 7,
        haddr         => 16#240#,
        hmask         => 16#fff#)
      port map (
        HCLK      => clkm,
        HRESETn   => rstn,
        ahbso     => ahbso(7),
        ahbsi     => ahbsi,
        ADDR      => hpiaddr,
        WDATA     => hpiwdata,
        RDATA     => hpirdata,
        nCS       => hpicsn,
        nWR       => hpiwriten,
        nRD       => hpirdn,
        INT       => hpiint,
        drive_bus => drive_bus,
        dbg_equal => dbg_equal
        );

    hpidata <= hpiwdata when drive_bus = '1' else
               (others => 'Z');

    hpirdata <= hpidata;

    hpiwrn <= hpiwriten;

  end generate;
  nahb2hpi_inst : if CFG_AHB2HPI = 0 generate
    ahbso(7) <= ahbs_none;
  end generate;


-----------------------------------------------------------------------
---  Drive unused bus elements  ---------------------------------------
-----------------------------------------------------------------------

  nam1 : for i in (CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG+CFG_SVGA_ENABLE+CFG_GRETH) to NAHBMST-1 generate
    ahbmo(i) <= ahbm_none;
  end generate;
  nap0 : for i in 7 to NAPBSLV-1-CFG_GRETH generate apbo(i) <= apb_none; end generate;
  nah0 : for i in 8 to NAHBSLV-1 generate ahbso(i)          <= ahbs_none; end generate;


-----------------------------------------------------------------------
---  Adaptions for HPE Mini -- ----------------------------------------
-----------------------------------------------------------------------

  dsuactn <= not dsuact;

  sdba <= memo.address(16 downto 15);   -- the bank address

  resoutn <= rstn;
  dual_uart : if CFG_AHB_UART /= 0 and CFG_UART1_ENABLE /= 0 generate
    with sersrcsel select
      sertx <= txd1 when '1', dsutx when others;

    rxd1  <= serrx when sersrcsel = '1' else '-';
    dsurx <= serrx when sersrcsel = '0' else '-';
  end generate dual_uart;

  console_uart : if CFG_AHB_UART = 0 and CFG_UART1_ENABLE /= 0 generate
    sertx <= txd1;
    rxd1  <= serrx;
  end generate console_uart;

  dcl_uart : if CFG_AHB_UART /= 0 and CFG_UART1_ENABLE = 0 generate
    sertx <= dsutx;
    dsurx <= serrx;
  end generate dcl_uart;

  no_uart : if CFG_AHB_UART = 0 and CFG_UART1_ENABLE = 0 generate
    sertx <= '-';
    dsurx <= '-';
    rxd1  <= '-';
  end generate no_uart;

-----------------------------------------------------------------------
---  Boot message  ----------------------------------------------------
-----------------------------------------------------------------------

-- pragma translate_off
  x : report_version
    generic map (
      msg1 => "LEON3 Demonstration design for HPE_mini board",
      msg2 => "GRLIB Version " & tost(LIBVHDL_VERSION/1000) & "." & tost((LIBVHDL_VERSION mod 1000)/100)
      & "." & tost(LIBVHDL_VERSION mod 100) & ", build " & tost(LIBVHDL_BUILD),
      msg3 => "Target technology: " & tech_table(fabtech) & ",  memory library: " & tech_table(memtech),
      mdel => 1
      );
-- pragma translate_on



end rtl;
