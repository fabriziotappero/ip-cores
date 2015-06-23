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
library esa;
use esa.memoryctrl.all;
library gleichmann;
use gleichmann.hpi.all;
use gleichmann.multiio.all;
use gleichmann.dac.all;
use gleichmann.ge_clkgen.all;
library ec;
use ec.components.all;

use work.config.all;


entity leon3mini is
  generic (
    fabtech   : integer := CFG_FABTECH;
    memtech   : integer := CFG_MEMTECH;
    padtech   : integer := CFG_PADTECH;
    clktech   : integer := CFG_CLKTECH;
    disas     : integer := CFG_DISAS;   -- Enable disassembly to console
    dbguart   : integer := CFG_DUART;   -- Print UART on console
    pclow     : integer := CFG_PCLOW;
    ddrfreq   : integer := 100000;      -- frequency of ddr clock in kHz 
    cpufreq   : integer := 50000;       -- frequency of cpu/ahb clock in kHz
    boardfreq : string  := "25"         -- frequency of ddr clock in MHz 
    );
  port (
    resetn  : in  std_ulogic;
    resoutn : out std_logic;
    clk     : in  std_ulogic;

    errorn  : out   std_ulogic;
    address : out   std_logic_vector(24 downto 2);
    data    : inout std_logic_vector(31 downto 0);

    ramsn : out std_ulogic;
    rben  : out std_logic_vector(3 downto 0);

    romsn   : out std_ulogic;
--    iosn    : out   std_ulogic;
    oen     : out std_ulogic;
    --   read    : out   std_ulogic;
    writen  : out std_ulogic;
    romwpn  : out std_ulogic;
    romrstn : out std_ulogic;

    -- ddr memory  
    ddr_clk0   : out   std_logic;
    ddr_clk0b  : out   std_logic;
    ddr_clk_fb : in    std_logic;
    ddr_cke0   : out   std_logic;
    ddr_cs0b   : out   std_logic;
    ddr_web    : out   std_ulogic;                      -- ddr write enable
    ddr_rasb   : out   std_ulogic;                      -- ddr ras
    ddr_casb   : out   std_ulogic;                      -- ddr cas
    ddr_dm     : out   std_logic_vector (3 downto 0);   -- ddr dm
    ddr_dqs    : inout std_logic_vector (3 downto 0);   -- ddr dqs
    ddr_ad     : out   std_logic_vector (12 downto 0);  -- ddr address
    ddr_ba     : out   std_logic_vector (1 downto 0);   -- ddr bank address
    ddr_dq     : inout std_logic_vector (31 downto 0);  -- ddr data
    ddr_clk1   : out   std_logic;                       -- ddr module 1
    ddr_clk1b  : out   std_logic;                       -- ddr module 1
    ddr_cke1   : out   std_logic;                       -- ddr module 1
    ddr_cs1b   : out   std_logic;                       -- ddr module 1

    -- debug support unit
    -- dsuen   : in  std_ulogic;
    dsubre : in std_ulogic;
    -- dsuactn : out std_ulogic;

    -- UART for serial DCL/console I/O
    serrx : in  std_ulogic;
    sertx : out std_ulogic;

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

--    sample_clock : out std_ulogic;

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
--    dbg_equal : out std_ulogic;
-------------------------------------------------------------------------------

    -------------------------------------------------------------------------------------
    -- IO SECTION
    -------------------------------------------------------------------------------------
    dsw : in  std_logic_vector(3 downto 0);
    led : out std_logic_vector(7 downto 0);  -- 8 leds

    sevensegment : out std_logic_vector(9 downto 0);  -- 7-segments and 2 strobes

    lcd_enable : out std_logic;
    lcd_regsel : out std_logic;
    lcd_rw     : out std_logic;

    -- keyboard
    tst_col : out std_logic_vector(2 downto 0);  -- column outputs
    tst_row : in  std_logic_vector(3 downto 0);  -- row inputs

    -- expansion connector signals
    exp_datao : out std_logic_vector(19 downto 0);
    exp_datai : in  std_logic_vector(19 downto 0);

    -- audio codec
    codec_mode   : out std_ulogic;
    codec_mclk   : out std_ulogic;
    codec_sclk   : out std_ulogic;
    codec_cs     : out std_ulogic;
    codec_sdin   : out std_ulogic;
    codec_din    : out std_ulogic;  -- I2S format serial data input to the sigma-delta stereo DAC
    codec_bclk   : out std_ulogic;      -- I2S serial-bit clock
--  codec_dout   : in  std_ulogic;         -- I2S format serial data output from the sigma-delta stereo ADC
    codec_lrcin  : out std_ulogic;      -- I2S DAC-word clock signal
    codec_lrcout : out std_ulogic;      -- I2S ADC-word clock signal

    dac       : out std_ulogic;
    vga_vsync : out std_ulogic;
    vga_hsync : out std_ulogic;
    vga_rd    : out std_logic_vector(1 downto 0);
    vga_gr    : out std_logic_vector(1 downto 0);
    vga_bl    : out std_logic_vector(1 downto 0)

    );
end;

architecture rtl of leon3mini is

  
  component clkgen_lattice
    generic (
      clk_mul    : string := "2";
      clk_div    : string := "1";
      freq       : string := "25";      -- clock frequency in MHz
      ddrclk_mul : string := "4";
      ddrclk_div : string := "1");
    port (
      clkin   : in  std_logic;
      clk0    : out std_logic;          -- main clock
      clk180  : out std_logic;          -- main clock phase 180
      clk270  : out std_logic;          -- main clock phase 270
      ddrclk  : out std_logic;
      ddrclkb : out std_logic;
      clkm    : out std_logic;
      cgi     : in  clkgen_in_type;
      cgo     : out clkgen_out_type);
  end component;


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

  signal ddrclk0, ddrclk90, ddrclk180, ddrclk270, ddrclk, ddrclkb : std_ulogic;
  signal clkm, rstn, sdclkl                                       : std_ulogic;
  signal cgi                                                      : clkgen_in_type;
  signal cgo                                                      : clkgen_out_type;
  signal u1i, dui                                                 : uart_in_type;
  signal u1o, duo                                                 : uart_out_type;

  signal irqi : irq_in_vector(0 to CFG_NCPU-1);
  signal irqo : irq_out_vector(0 to CFG_NCPU-1);

  signal dbgi : l3_debug_in_vector(0 to CFG_NCPU-1);
  signal dbgo : l3_debug_out_vector(0 to CFG_NCPU-1);

  signal dsui : dsu_in_type;
  signal dsuo : dsu_out_type;

  signal ethi, ethi1, ethi2 : eth_in_type;
  signal etho, etho1, etho2 : eth_out_type;

  signal gpti : gptimer_in_type;


-- Adaptions for HPE Compact

--  signal dsubre         : std_logic;
  signal dsuact   : std_logic;
  signal oen_ctrl : std_logic;

  signal shortcut               : std_logic;
  signal rx                     : std_logic;
  signal tx                     : std_logic;
  signal duart, ldsuen          : std_logic;
  signal rsertx, rserrx, rdsuen : std_logic;

  -- ram write enable, not needed on the port
  signal rwen : std_logic_vector(3 downto 0);

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

  signal vgao : apbvga_out_type;
  signal ddsi : ddrmem_in_type;
  signal ddso : ddrmem_out_type;

  constant modbanks : integer := CFG_DDRMP_NCS;    -- Allowed: 1,2 (banks on module)
  constant numchips : integer := CFG_DDRMP_NDEV;   -- Allowed: 1, 2, 4, 8, 16
  constant chipbits : integer := CFG_DDRMP_NBITS;  -- Allowed: 4, 8, 16
  constant chipsize : integer := CFG_DDRMP_MBITS;  -- Allowed: 64, 128, 256, 512, 1024 (Mbit)

--  attribute syn_useioff : boolean; 
--  attribute syn_useioff of rtl : architecture is false;

  ---------------------------------------------------------------------------------------
  -- IO SECTION
  ---------------------------------------------------------------------------------------

  signal mioi : MultiIO_in_type;
  signal mioo : MultiIO_out_type;

  signal dsuactn : std_ulogic;
--  signal errorn : std_ulogic;

  -- synplify attribute to flatten netlist
  attribute syn_netlist_hierarchy        : boolean;
  attribute syn_netlist_hierarchy of rtl : architecture is false;

begin

  romwpn  <= '1';
  romrstn <= rstn;

----------------------------------------------------------------------
---  Reset and Clock generation  -------------------------------------
----------------------------------------------------------------------

  vcc         <= (others => '1'); gnd <= (others => '0');
  cgi.pllctrl <= "00"; cgi.pllrst <= not resetn;
  ddrclk90    <= '0'; sdclkl <= clkm;

  -- do not change the generics (ddr requirements)
  clkgen0 : clkgen_lattice              -- clock generator
    generic map (freq       => boardfreq,
                 clk_mul    => "1",
                 clk_div    => "1",
                 ddrclk_mul => "4",
                 ddrclk_div => "1")     -- 25 MHz cpu clock and 100 MHz DDR clock
    port map (clkin  => clk, clkm => clkm, clk0 => ddrclk0, clk180 => ddrclk180,
              clk270 => ddrclk270, ddrclk => ddrclk, ddrclkb => ddrclkb,
              cgi    => cgi, cgo => cgo);

  ddrclk_pad : outpad generic map (tech => padtech, level => sstl2_i)
    port map (ddr_clk0, ddrclk);
  ddrclkn_pad : outpad generic map (tech => padtech, level => sstl2_i)
    port map (ddr_clk0b, ddrclkb);

  rst0 : rstgen port map (resetn, clkm, cgo.clklock, rstn);

---------------------------------------------------------------------- 
---  AHB CONTROLLER --------------------------------------------------
----------------------------------------------------------------------

  ahb0 : ahbctrl                        -- AHB arbiter/multiplexer
    generic map (defmast => CFG_DEFMST, split => CFG_SPLIT,
                 rrobin  => CFG_RROBIN, ioaddr => CFG_AHBIO,
                 ioen    => 1, nahbm => 4, nahbs => 8)
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
      --    dsuen_pad  : inpad generic map (tech  => padtech) port map (dsuen, dsui.enable);
      dsui.enable <= '1';
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

----------------------------------------------------------------------
---  Memory controllers ----------------------------------------------
----------------------------------------------------------------------

  mg1 : if CFG_SRCTRL = 1 generate      -- 32-bit PROM/SRAM controller
    sr0 : srctrl generic map (hindex => 5, ramws => CFG_SRCTRL_RAMWS,
                              romws  => CFG_SRCTRL_PROMWS, ramaddr => 16#400#, rmw => 1)
      port map (rstn, clkm, ahbsi, ahbso(5), memi, memo, sdo3);
    apbo(0) <= apb_none;
  end generate;

  mg2 : if CFG_MCTRL_LEON2 = 1 generate  -- LEON2 memory controller
    sr1 : mctrl generic map (hindex => 5, pindex => 0,
                             paddr  => 0, srbanks => 1, ramaddr => 16#600#, sden => 0)
      port map (rstn, clkm, memi, memo, ahbsi, ahbso(5), apbi, apbo(0), wpo, sdo);
  end generate;

  memi.brdyn  <= '1'; memi.bexcn <= '1';
  memi.writen <= '1'; memi.wrn <= "1111"; memi.bwidth <= "10";

  mg0 : if (CFG_MCTRL_LEON2 = 0) and (CFG_SRCTRL = 0) generate
    apbo(0) <= apb_none; ahbso(0) <= ahbs_none;
    rams_pad : outpad generic map (tech => padtech)
      port map (ramsn, vcc(0));
    roms_pad : outpad generic map (tech => padtech)
      port map (romsn, vcc(0));
  end generate;

  mgpads : if not ((CFG_MCTRL_LEON2 = 0) and (CFG_SRCTRL = 0)) generate
    addr_pad : outpadv generic map (width => 23, tech => padtech)
      port map (address, memo.address(24 downto 2));
    rams_pad : outpad generic map (tech => padtech)
      port map (ramsn, memo.ramsn(0));
    roms_pad : outpad generic map (tech => padtech)
      port map (romsn, memo.romsn(0));
    oen_pad : outpad generic map (tech => padtech)
      port map (oen, memo.oen);
    rwen_pad : outpadv generic map (width => 4, tech => padtech)
      port map (rwen, memo.wrn);
    rben_pad : outpadv generic map (width => 4, tech => padtech)
      port map (rben, memo.mben);
--    roen_pad : outpad generic map (tech => padtech)
--      port map (ramoen, memo.ramoen(0));
    wri_pad : outpad generic map (tech => padtech)
      port map (writen, memo.writen);
    --   read_pad : outpad generic map (tech => padtech)
    --     port map (read, memo.read);
    -- iosn_pad : outpad generic map (tech => padtech)
    -- port map (iosn, memo.iosn);
    bdr : for i in 0 to 3 generate
      data_pad : iopadv generic map (tech => padtech, width => 8)
        port map (data(31-i*8 downto 24-i*8), memo.data(31-i*8 downto 24-i*8),
                  memo.bdrive(i), memi.data(31-i*8 downto 24-i*8));
    end generate;
  end generate;

----------------------------------------------------------------------
---  DDR memory controller -------------------------------------------
----------------------------------------------------------------------

  -- not tested/working at the moment

  ddr0 : if CFG_DDRMP_EN = 1 generate
    ddrc : ddrctrl
      generic map(
        hindex1    => 0, haddr1 => 16#600#, hmask1 => 16#FC0#,
        hindex2    => 7, haddr2 => 16#D00#, hmask2 => 16#FC0#,
        pindex     => 8, paddr => 8, numahb => 1,
        ahb1sepclk => 1, ahb2sepclk => 1, modbanks => modbanks,
        numchips   => numchips, chipbits => chipbits, chipsize => chipsize,
        plldelay   => 1, tech => fabtech, clkperiod => (1000000/ddrfreq))
      port map(rst    => rstn, clk0 => ddrclk0, clk90 => ddrclk90,
               clk180 => ddrclk180, clk270 => ddrclk270, hclk1 => clkm, hclk2 => clkm,
               pclk   => clkm, ahb1si => ahbsi, ahb1so => ahbso(0), ahb2si => ahbsi,
               ahb2so => open, apbsi => apbi, apbso => apbo(8), ddsi => ddsi,
               ddso   => ddso);

    -- Outpads
    ddr_cke_pad  : outpad generic map (tech  => padtech, level => sstl2_i) port map (ddr_cke0, ddsi.cke);
    ddr_csb_pad  : outpad generic map (tech  => padtech, level => sstl2_i) port map (ddr_cs0b, ddsi.cs(0));
    ddr_web_pad  : outpad generic map (tech  => padtech, level => sstl2_i) port map (ddr_web, ddsi.control(0));
    ddr_casb_pad : outpad generic map (tech  => padtech, level => sstl2_i) port map (ddr_casb, ddsi.control(1));
    ddr_rasb_pad : outpad generic map (tech  => padtech, level => sstl2_i) port map (ddr_rasb, ddsi.control(2));
    ddr_dm_pad   : outpadv generic map (tech => padtech, level => sstl2_i, width => 4) port map (ddr_dm, ddsi.dm(3 downto 0));
    ddr_ad_pad   : outpadv generic map (tech => padtech, level => sstl2_i, width => 13) port map (ddr_ad, ddsi.adr(12 downto 0));
    ddr_ba_pad   : outpadv generic map (tech => padtech, level => sstl2_i, width => 2) port map (ddr_ba, ddsi.ba);

    -- InOut-pads

    ddr_dq_pad : for i in 0 to 31 generate
      dq_pad : iopad generic map (tech => padtech, level => sstl2_ii)
        port map (pad => ddr_dq(i), i => ddsi.dq(i), en => ddsi.dq_oe(i), o => ddso.dq(i));
    end generate;


    ddr_dqs_pad : for i in 0 to 3 generate
      dqs_pad : iopad generic map (tech => padtech, level => sstl2_ii)
        port map (pad => ddr_dqs(i), i => ddsi.dqs(i), en => ddsi.dqs_oe(i), o => ddso.dqs(i));
    end generate;

    -- ddr module 1
    ddr_clk1 <= '0'; ddr_clk1b <= '0'; ddr_cke1 <= '0'; ddr_cs1b <= '1';
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
    vga0 : apbvga generic map(memtech => memtech, pindex => 5, paddr => 5)
      port map(rstn, clkm, clk, apbi, apbo(5), vgao);
  end generate;
  novga         : if CFG_VGA_ENABLE = 0 generate apbo(5) <= apb_none; vgao <= vgao_none; end generate;
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

-----------------------------------------------------------------------
---  MULTIIO SECTION --------------------------------------------------
-----------------------------------------------------------------------
  MULTIIO : if CFG_MULTIIO /= 0 generate
    -- human interface controller
    mio : MultiIO_APB
      generic map (
        pindex      => 6,
        paddr       => 6,
        pmask       => 16#fff#,
        pirq        => 6,
        clk_freq_in => cpufreq,
        led7act     => '0',
        ledact      => '0',
        switchact   => '0',             -- switch polarity is inverse to Hpe_compact
        buttonact   => '1')
      port map (
        rst_n       => rstn,
        clk         => clkm,
        apbi        => apbi,
        apbo        => apbo(6),
        MultiIO_in  => mioi,
        MultiIO_out => mioo);

    mioi.switch_in <= "0000" & dsw;
    mioi.row_in    <= tst_row;
    sevensegment   <= mioo.led_ca_out(1) &  -- 9
                      mioo.led_ca_out(0) &  -- 8
                      mioo.led_dp_out &     -- .
                      mioo.led_g_out &      -- .
                      mioo.led_f_out &      -- .
                      mioo.led_e_out &
                      mioo.led_d_out &
                      mioo.led_c_out &
                      mioo.led_b_out &
                      mioo.led_a_out;       -- 0
    tst_col <= mioo.column_out;
    led     <= mioo.led_out when dsubre = '0' else
               vcc(4 downto 0) & vcc(0) & (not dsuact) & dbgo(0).error;

    lcd_regsel <= mioo.lcd_regsel;
    lcd_rw     <= mioo.lcd_rw;
    lcd_enable <= mioo.lcd_enable;

    -- expansion connector
    exp_datao   <= mioo.exp_out;
    mioi.exp_in <= exp_datai;

    codec_mode   <= mioo.codec_mode;
    codec_mclk   <= mioo.codec_mclk;
    codec_sclk   <= mioo.codec_sclk;
    codec_sdin   <= mioo.codec_sdin;
    codec_cs     <= mioo.codec_cs;
    codec_din    <= mioo.codec_din;
    codec_bclk   <= mioo.codec_bclk;
    codec_lrcin  <= mioo.codec_lrcin;
    codec_lrcout <= mioo.codec_lrcout;
    
  end generate;

  nMULTIIO : if CFG_MULTIIO = 0 generate
    apbo(6) <= apb_none;
  end generate;

-----------------------------------------------------------------------
---  ETHERNET ---------------------------------------------------------
-----------------------------------------------------------------------

  eth0 : if CFG_GRETH = 1 generate      -- Gaisler ethernet MAC
    e1 : greth generic map(hindex    => CFG_NCPU+CFG_AHB_UART,
                           pindex    => 15, paddr => 15, pirq => 12, memtech => memtech,
                           mdcscaler => cpufreq/1000, enable_mdio => 1, fifosize => CFG_ETH_FIFO,
                           nsync     => 1, edcl => CFG_DSU_ETH, edclbufsz => CFG_ETH_BUF,
                           macaddrh  => CFG_ETH_ENM, macaddrl => CFG_ETH_ENL,
                           ipaddrh   => CFG_ETH_IPM, ipaddrl => CFG_ETH_IPL)
      port map(rst   => rstn, clk => clkm, ahbmi => ahbmi,
               ahbmo => ahbmo(CFG_NCPU+CFG_AHB_UART), apbi => apbi,
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
        hindex        => 8,
        haddr         => 16#240#,
        hmask         => 16#fff#)
      port map (
        HCLK      => clkm,
        HRESETn   => rstn,
        ahbso     => ahbso(8),
        ahbsi     => ahbsi,
        ADDR      => hpiaddr,
        WDATA     => hpiwdata,
        RDATA     => hpirdata,
        nCS       => hpicsn,
        nWR       => hpiwriten,
        nRD       => hpirdn,
        INT       => hpiint,
        drive_bus => drive_bus);

    hpidata <= hpiwdata when drive_bus = '1' else
               (others => 'Z');

    hpirdata <= hpidata;

    hpiwrn <= hpiwriten;

  end generate;
  nahb2hpi_inst : if CFG_AHB2HPI = 0 generate
    ahbso(8) <= ahbs_none;
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


-----------------------------------------------------------------------
---  Drive unused bus elements  ---------------------------------------
-----------------------------------------------------------------------

  nam1 : for i in (CFG_NCPU+CFG_AHB_UART+CFG_GRETH) to NAHBMST-1 generate
    ahbmo(i) <= ahbm_none;
  end generate;
  nap0 : for i in 9 to NAPBSLV-1-CFG_GRETH generate apbo(i) <= apb_none; end generate;
  nah0 : for i in 8 to NAHBSLV-1 generate ahbso(i)          <= ahbs_none; end generate;

-----------------------------------------------------------------------
---  Adaptions for HPE Mini    ----------------------------------------
-----------------------------------------------------------------------

  -- invert dsuact signal for output on LED
  dsuactn <= not dsuact;

  resoutn <= rstn;

-----------------------------------------------------------------------
---  Boot message  ----------------------------------------------------
-----------------------------------------------------------------------

-- pragma translate_off
  x : report_version
    generic map (
      msg1 => "LEON3 Demonstration design for HPE_mini board",
      msg2 => "GRLIB Version " & tost(LIBVHDL_VERSION/100) & "." & tost((LIBVHDL_VERSION mod 10)/10)
      & "." & tost(LIBVHDL_VERSION mod 100),
      msg3 => "Target technology: " & tech_table(fabtech) & ",  memory library: " & tech_table(memtech),
      mdel => 1
      );
-- pragma translate_on

  dsuen_pad : inpad generic map (tech => padtech) port map ('1', ldsuen);
  duart  <= rdsuen when CFG_AHB_UART /= 0 else '0';
  rxd1   <= txd1   when duart = '1'       else rserrx;
  rsertx <= dsutx  when duart = '1'       else txd1;
  dsurx  <= rserrx when duart = '1'       else '1';

  p1 : process(clkm)
  begin
    if rising_edge(clkm) then
      sertx <= rsertx; rserrx <= serrx; rdsuen <= ldsuen;
    end if;
  end process;

end rtl;
