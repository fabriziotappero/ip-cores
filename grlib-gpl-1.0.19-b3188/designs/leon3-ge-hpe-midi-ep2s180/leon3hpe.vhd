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
--  maintained by Florian Wex, Gleichmann Electronics 2007
--  updated to grlib-eval-1.0.16 in , September 2007
------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------

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
use gaisler.net.all;
use gaisler.grusb.all;
use gaisler.jtag.all;
library esa;
use esa.memoryctrl.all;
library gleichmann;
use gleichmann.hpi.all;
use gleichmann.miscellaneous.all;
use gleichmann.multiio.all;
use gleichmann.dac.all;
use gleichmann.sspi.all;
use gleichmann.ge_clkgen.all;
use gleichmann.ac97.all;
library work;
use work.config.all;



entity leon3hpe is
  generic (
    fabtech : integer := CFG_FABTECH;
    memtech : integer := CFG_MEMTECH;
    padtech : integer := CFG_PADTECH;
    clktech : integer := CFG_CLKTECH;
    disas   : integer := CFG_DISAS;     -- Enable disassembly to console
    dbguart : integer := CFG_DUART;     -- Print UART on console
    pclow   : integer := CFG_PCLOW
    );
  port (
    resetn  : in  std_logic;
    resoutn : out std_logic;

    clk : in std_logic;

    errorn  : out   std_logic;
    address : out   std_logic_vector(27 downto 0);
    data    : inout std_logic_vector(31 downto 0);
    ramsn   : out   std_logic_vector (4 downto 0);
    ramoen  : out   std_logic_vector (4 downto 0);
    rwen    : inout std_logic_vector (3 downto 0);
    -- ram byte enable for hpe board
    -- necessary because individual bytes have to
    -- be selected for reading as well
    rben    : out   std_logic_vector(3 downto 0);
    romsn   : out   std_logic_vector (1 downto 0);
    iosn    : out   std_logic;
    oen     : out   std_logic;
    read    : out   std_logic;
    writen  : out   std_logic;

    -- SDRAM interface
    sdclk  : out   std_logic_vector(1 downto 0);
    sdcke  : out   std_logic_vector(1 downto 0);   -- sdram clock enable
    sdaddr : out   std_logic_vector(12 downto 0);
    sddq   : inout std_logic_vector(63 downto 0);
    sddqm  : out   std_logic_vector(7 downto 0);   -- sdram dqm
    sdwen  : out   std_logic;                     -- sdram write enable
    sdcasn : out   std_logic;                     -- sdram cas
    sdrasn : out   std_logic;                     -- sdram ras
    sdcsn  : out   std_logic_vector (1 downto 0);  -- sdram chip select
    sdba   : out   std_logic_vector(1 downto 0);   -- sdram bank address

    -- debug support unit
    dsutx   : out std_logic;           -- DSU tx data
    dsurx   : in  std_logic;           -- DSU rx data
    dsubre  : in  std_logic;
    dsuactn : out std_logic;

    -- console UART
    rxd1 : in  std_logic;
    txd1 : out std_logic;

    -- ethernet signals
    emdio   : inout std_logic;          -- ethernet PHY interface
    etx_clk : in    std_logic;
    erx_clk : in    std_logic;
    erxd    : in    std_logic_vector(3 downto 0);
    erx_dv  : in    std_logic;
    erx_er  : in    std_logic;
    erx_col : in    std_logic;
    erx_crs : in    std_logic;
    etxd    : out   std_logic_vector(3 downto 0);
    etx_en  : out   std_logic;
    etx_er  : out   std_logic;
    emdc    : out   std_logic;
    ereset  : out   std_logic;

    --  CAN receive and transmit signals
    can_txd : out std_logic;
    can_rxd : in  std_logic;
    can_stb : out std_logic;

    -------------------------------------------------------------------------------------
    -- IO SECTION
    -------------------------------------------------------------------------------------
    dsw : in std_logic_vector(7 downto 0);

    led_enable : out std_logic;

    sevensegment : out std_logic_vector(9 downto 0);  -- 7-segments and 2 strobes

    lcd_enable : out std_logic;
    lcd_regsel : out std_logic;
    lcd_rw     : out std_logic;

    -- keyboard
    tst_col : out std_logic_vector(2 downto 0);  -- column outputs
    tst_row : in  std_logic_vector(3 downto 0);  -- row inputs

    -- only one PS/2 interface possible due to routing problems
    -- see instantiation of the interface below
    ps2_clk  : inout std_logic_vector(1 downto 0);
    ps2_data : inout std_logic_vector(1 downto 0);

    -- expansion connector signals
    exp_datao : out std_logic_vector(19 downto 0);
    exp_datai : in  std_logic_vector(19 downto 0);

    ---------------------------------------------------------------------------
    -- VGA interface
    ---------------------------------------------------------------------------
    vga_clk    : out std_logic;
    vga_syncn  : out std_logic;
    vga_blankn : out std_logic;
    vga_vsync  : out std_logic;
    vga_hsync  : out std_logic;
    vga_rd     : out std_logic_vector(7 downto 0);
    vga_gr     : out std_logic_vector(7 downto 0);
    vga_bl     : out std_logic_vector(7 downto 0);

    ---------------------------------------------------------------------------
    -- AC97 AUDIO CODEC
    ---------------------------------------------------------------------------

    ac97_bit_clk   : in  std_logic;
    ac97_sync      : out std_logic;
    ac97_sdata_out : out std_logic;
    ac97_sdata_in  : in  std_logic;
    -- when no crystal is assembled, drive this signal with a 24.5 (or 25) MHz clock
    ac97_ext_clk   : out std_logic;
    ac97_resetn    : out std_logic;

    -------------------------------------------------------------------------------------
    -- USB DEBUG INTERFACE
    -------------------------------------------------------------------------------------
    usb_clkout    : in    std_logic;
    usb_d         : inout std_logic_vector(15 downto 0);
    usb_linestate : in    std_logic_vector(1 downto 0);
    usb_opmode    : out   std_logic_vector(1 downto 0);
    usb_reset     : out   std_logic;
    usb_rxactive  : in    std_logic;
    usb_rxerror   : in    std_logic;
    usb_rxvalid   : in    std_logic;
    usb_suspend   : out   std_logic;
    usb_termsel   : out   std_logic;
    usb_txready   : in    std_logic;
    usb_txvalid   : out   std_logic;
    usb_validh    : inout std_logic;
    usb_xcvrsel   : out   std_logic;
    usb_vbus      : in    std_logic;
    usb_dbus16    : out   std_logic;
    usb_unidir    : out   std_logic;

    ---------------------------------------------------------------------------
    -- ADC/DAC INTERFACE
    ---------------------------------------------------------------------------
    adc_dout : in  std_logic;
    adc_ain  : out std_logic;
    dac_out  : out std_logic;

    -------------------------------------------------------------------------------------
    -- SDCARD interface (SPI mode)
    -------------------------------------------------------------------------------------
    sdcard_cs   : out std_logic;
    sdcard_di   : out std_logic;
    sdcard_sclk : out std_logic;
    sdcard_do   : in  std_logic;

    -------------------------------------------------------------------------------
    -- HPI PORT
    -------------------------------------------------------------------------------
    hpiaddr : out   std_logic_vector(1 downto 0);
    hpidata : inout std_logic_vector(15 downto 0);
    hpicsn  : out   std_logic;
    hpiwrn  : out   std_logic;
    hpirdn  : out   std_logic;
    hpiint  : in    std_logic
    );
end;

architecture rtl of leon3hpe is

  constant blength   : integer := 12;
  constant fifodepth : integer := 8;

  signal reset    : std_logic;
  signal vcc, gnd : std_logic_vector(4 downto 0);
  signal memi     : memory_in_type;
  signal memo     : memory_out_type;
  signal wpo      : wprot_out_type;

  signal sdi  : sdctrl_in_type;
  signal sdo  : sdram_out_type;
  signal sdo2 : sdctrl_out_type;
  signal sdo3 : sdctrl_out_type;

  signal apbi  : apb_slv_in_type;
  signal apbo  : apb_slv_out_vector := (others => apb_none);
  signal ahbsi : ahb_slv_in_type;
  signal ahbso : ahb_slv_out_vector := (others => ahbs_none);
  signal ahbmi : ahb_mst_in_type;
  signal ahbmo : ahb_mst_out_vector := (others => ahbm_none);

  signal clkm, clk_25MHz, rstn, sdclkl : std_logic;
  -- signal clkvga             : std_logic;
  signal cgi                           : clkgen_in_type;
  signal cgo                           : clkgen_out_type;
  signal u1i, dui                      : uart_in_type;
  signal u1o, duo                      : uart_out_type;

  signal irqi : irq_in_vector(0 to CFG_NCPU-1);
  signal irqo : irq_out_vector(0 to CFG_NCPU-1);

  signal dbgi : l3_debug_in_vector(0 to CFG_NCPU-1);
  signal dbgo : l3_debug_out_vector(0 to CFG_NCPU-1);

  signal dsui : dsu_in_type;
  signal dsuo : dsu_out_type;

  signal ethi, ethi1, ethi2 : eth_in_type;
  signal etho, etho1, etho2 : eth_out_type;

  signal gpti : gptimer_in_type;

  signal emddis  : std_logic;
  signal epwrdwn : std_logic;
  signal esleep  : std_logic;
  signal epause  : std_logic;



-- Adaptions for HPE Compact

  signal dsuact         : std_logic;
  signal oen_ctrl       : std_logic;
  signal sdram_selected : std_logic;
  signal sd_clk         : std_logic;
  signal s_ramsn        : std_logic_vector (4 downto 0);
  signal s_sddqm        : std_logic_vector (7 downto 0);

  signal shortcut : std_logic;
  signal rx       : std_logic;
  signal tx       : std_logic;


  constant BOARD_FREQ : integer := 100_000;  -- input frequency in KHz
  constant CPU_FREQ   : integer := BOARD_FREQ * CFG_CLKMUL / CFG_CLKDIV * 1_000;  -- cpu frequency in KHz
  constant PS2_SCALER : integer := CPU_FREQ / 10_000;  -- PS2 Freq = 10 kHz
  constant IOAEN      : integer := 1;   --CFG_ETH + CFG_CAN;

  signal mioi : MultiIO_in_type;
  signal mioo : MultiIO_out_type;

  signal kbdi0, kbdi1 : ps2_in_type;
  signal kbdo0, kbdo1 : ps2_out_type;

  -- VGA interface
  signal vgao : apbvga_out_type;

  signal uclk : std_logic;
  signal usbi : grusb_in_type;
  signal usbo : grusb_out_type;

  -- simple SPI controller
  signal spii  : sspi_in_type;
  signal spio  : sspi_out_type;
  signal gspii : spi_in_type;
  signal gspio : spi_out_type;

  -- ADC/DAC
  signal adcdaci : adcdac_in_type;
  signal adcdaco : adcdac_out_type;

  ---------------------------------------------------------------------------------------
  -- AC97 AUDIO CODEC
  ---------------------------------------------------------------------------------------

  signal dma_ack   : std_logic_vector(8 downto 0);
  signal int       : std_logic;
  signal dma_req   : std_logic_vector(8 downto 0);
  signal suspended : std_logic;

  -- intermediate signals for outputs in order to be able
  -- to propagate to two signal sinks
  signal ac97_int_sync      : std_logic;
  signal ac97_int_sdata_out : std_logic;
  signal ac97_int_resetn    : std_logic;
  signal ac97_int_irq       : std_logic;

  ---------------------------------------------------------------------------------------
  -- HPI SIGNALS
  ---------------------------------------------------------------------------------------
  signal hpiwriten : std_logic;        -- intermediate signal
  signal hpirdata  : std_logic_vector(15 downto 0);
  signal hpiwdata  : std_logic_vector(15 downto 0);
  signal drive_bus : std_logic;

  signal dbg_equal  : std_logic;
  signal sample_clk : std_logic;

  ---------------------------------------------------------------------------------------

begin

----------------------------------------------------------------------
---  Reset and Clock generation  -------------------------------------
----------------------------------------------------------------------

  reset <= not resetn;

  vcc         <= (others => '1'); gnd <= (others => '0');
  cgi.pllctrl <= "00"; cgi.pllrst <= resetn;
  cgi.pllref  <= clk;

  vga_clk_gen : if (CFG_VGA_ENABLE /= 0) generate
    no_vga_clk_gen : if ((CFG_CLKDIV/CFG_CLKMUL) = 4) generate
      clk_25MHz <= clkm;
    end generate;
    vga_clk_gen : if ((CFG_CLKDIV/CFG_CLKMUL) /= 4) generate
      vga_clk_gen_inst : clkgen
        generic map (
          tech      => clktech,
          clk_mul   => 1,
          clk_div   => 4,
          sdramen   => 0,
          noclkfb   => 1,
          pcien     => 0,
          pcidll    => 0,
          pcisysclk => 0,
          freq      => BOARD_FREQ,
          clk2xen   => 0)
        port map (
          clkin    => clk,
          clk      => clk_25MHz,
          pciclkin => gnd(0),
          cgi      => cgi,
          cgo      => open);
    end generate;
  end generate;

  clkgen_1 : clkgen
    generic map (
      tech      => clktech,
      clk_mul   => CFG_CLKMUL,
      clk_div   => CFG_CLKDIV,
      sdramen   => CFG_SDCTRL + CFG_MCTRL_SDEN,
      noclkfb   => CFG_CLK_NOFB,
      pcien     => 0,
      pcidll    => 0,
      pcisysclk => 0,
      freq      => BOARD_FREQ,
      clk2xen   => 1)
    port map (
      clkin    => clk,
      pciclkin => gnd(0),
      clk      => clkm,
      clkn     => open,
      clk2x    => sample_clk,
      sdclk    => sdclkl,
      pciclk   => open,
      cgi      => cgi,
      cgo      => cgo,
      clk4x    => open);

  rst0 : rstgen                         -- reset generator
    port map (resetn, clkm, cgo.clklock, rstn);

---------------------------------------------------------------------- 
---  AHB CONTROLLER --------------------------------------------------
----------------------------------------------------------------------

  ahb0 : ahbctrl                        -- AHB arbiter/multiplexer
    generic map (defmast => CFG_DEFMST, split => CFG_SPLIT,
                 rrobin  => CFG_RROBIN, ioaddr => CFG_AHBIO, ioen => IOAEN,
                 nahbm   => CFG_NCPU+CFG_AHB_UART+CFG_GRETH+CFG_GRUSB_DCL+CFG_AHB_JTAG,
                 nahbs   => 9)
    port map (rstn, clkm, ahbmi, ahbmo, ahbsi, ahbso);

----------------------------------------------------------------------
---  LEON3 processor and DSU -----------------------------------------
----------------------------------------------------------------------

  cpu : for i in 0 to CFG_NCPU-1 generate
    u0 : leon3s                         -- LEON3 processor
      generic map (i, fabtech, memtech, CFG_NWIN, CFG_DSU, CFG_FPU, CFG_V8,
                   0, CFG_MAC, pclow, 0, CFG_NWP, CFG_ICEN, CFG_IREPL, CFG_ISETS, CFG_ILINE,
                   CFG_ISETSZ, CFG_ILOCK, CFG_DCEN, CFG_DREPL, CFG_DSETS, CFG_DLINE, CFG_DSETSZ,
                   CFG_DLOCK, CFG_DSNOOP, CFG_ILRAMEN, CFG_ILRAMSZ, CFG_ILRAMADDR, CFG_DLRAMEN,
                   CFG_DLRAMSZ, CFG_DLRAMADDR, CFG_MMUEN, CFG_ITLBNUM, CFG_DTLBNUM, CFG_TLB_TYPE, CFG_TLB_REP,
                   CFG_LDDEL, disas, CFG_ITBSZ, CFG_PWD, CFG_SVT, CFG_RSTADDR, CFG_NCPU-1)
      port map (clkm, rstn, ahbmi, ahbmo(i), ahbsi, ahbso,
                irqi(i), irqo(i), dbgi(i), dbgo(i));
  end generate;
  errorn_pad : odpad generic map (tech => padtech) port map (errorn, dbgo(0).error);

  dsugen : if CFG_DSU = 1 generate
    dsu0 : dsu3                         -- LEON3 Debug Support Unit
      generic map (hindex => 2, haddr => 16#900#, hmask => 16#F00#,
                   ncpu   => CFG_NCPU, tbits => 30, tech => memtech, irq => 0, kbytes => CFG_ATBSZ)
      port map (rstn, clkm, ahbmi, ahbsi, ahbso(2), dbgo, dbgi, dsui, dsuo);
    dsuen_pad  : inpad generic map (tech  => padtech) port map (vcc(0), dsui.enable);
    dsubre_pad : inpad generic map (tech  => padtech) port map (dsubre, dsui.break);
    dsuact_pad : outpad generic map (tech => padtech) port map (dsuact, dsuo.active);
  end generate;
  nodsu : if CFG_DSU = 0 generate
    ahbso(2) <= ahbs_none; dsuo.tstop <= '0'; dsuo.active <= '0';
  end generate;

  dcomgen : if CFG_AHB_UART = 1 generate
    dcom0 : ahbuart                     -- Debug UART
      generic map (hindex => CFG_NCPU, pindex => 7, paddr => 7)
      port map (rstn, clkm, dui, duo, apbi, apbo(7), ahbmi, ahbmo(CFG_NCPU));
    dsurx_pad : inpad generic map (tech  => padtech) port map (dsurx, dui.rxd);
    dsutx_pad : outpad generic map (tech => padtech) port map (dsutx, duo.txd);
  end generate;
  nouah : if CFG_AHB_UART = 0 generate apbo(7) <= apb_none; end generate;

  ahbjtaggen0 : if CFG_AHB_JTAG = 1 generate
    ahbjtag0 : ahbjtag generic map(tech => fabtech, hindex => CFG_NCPU+CFG_AHB_UART)
      port map(rstn, clkm, gnd(0), gnd(0), gnd(0), open, ahbmi, ahbmo(CFG_NCPU+CFG_AHB_UART),
               open, open, open, open, open, open, open, gnd(0));
  end generate;

-----------------------------------------------------------------------
---  USB DEBUG LINK  --------------------------------------------------
-----------------------------------------------------------------------

  usb0 : if CFG_GRUSB_DCL = 1 generate
    usb_d_pads : for i in 0 to 15 generate
      usb_d_pad : iopad generic map(tech => padtech)
        port map (usb_d(i), usbo.dataout(i), usbo.oen, usbi.datain(i));
    end generate;

    usb_h_pad : iopad generic map(tech => padtech)
      port map (usb_validh, usbo.txvalidh, usbo.oen, usbi.rxvalidh);
    
    usb_i0_pad : inpad generic map (tech => padtech) port map (usb_txready, usbi.txready);
    usb_i1_pad : inpad generic map (tech => padtech) port map (usb_rxvalid, usbi.rxvalid);
    usb_i2_pad : inpad generic map (tech => padtech) port map (usb_rxerror, usbi.rxerror);
    usb_i3_pad : inpad generic map (tech => padtech) port map (usb_rxactive, usbi.rxactive);
    usb_i4_pad : inpad generic map (tech => padtech) port map (usb_linestate(0), usbi.linestate(0));
    usb_i5_pad : inpad generic map (tech => padtech) port map (usb_linestate(1), usbi.linestate(1));

    usb_i6_pad : inpad generic map (tech  => padtech) port map (usb_vbus, usbi.vbusvalid);
    usb_o0_pad : outpad generic map (tech => padtech) port map (usb_reset, usbo.reset);

    usb_o1_pad : outpad generic map (tech => padtech) port map (usb_suspend, usbo.suspendm);
    usb_o2_pad : outpad generic map (tech => padtech) port map (usb_termsel, usbo.termselect);
    usb_o3_pad : outpad generic map (tech => padtech) port map (usb_xcvrsel, usbo.xcvrselect(0));
    usb_o4_pad : outpad generic map (tech => padtech) port map (usb_opmode(0), usbo.opmode(0));
    usb_o5_pad : outpad generic map (tech => padtech) port map (usb_opmode(1), usbo.opmode(1));
    usb_o6_pad : outpad generic map (tech => padtech) port map (usb_txvalid, usbo.txvalid);

    usb_clk_pad : clkpad generic map (tech => padtech) port map (usb_clkout, uclk);

    -- USB transceiver shall operate in 8-bit mode
    usb_dbus16 <= not dsw(1);
    -- USB transceiver shall use 8-bit data bus bidirectionally
    -- (bits 15 downto 8 are undriven)
    usb_unidir <= not dsw(2);

    usb_ctrl : grusb_dcl
      generic map (hindex => CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG, memtech => memtech)
      port map (uclk, usbi, usbo, clkm, rstn, ahbmi, ahbmo(CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG));
  end generate;

----------------------------------------------------------------------
---  Memory controllers ----------------------------------------------
----------------------------------------------------------------------

  mg1 : if CFG_SRCTRL = 1 generate      -- 32-bit PROM/SRAM controller
    sr0 : srctrl generic map (hindex  => 0,
                              ramws   => CFG_SRCTRL_RAMWS, romws => CFG_SRCTRL_PROMWS,
                              ramaddr => 16#400#, rmw => 1)
      port map (rstn, clkm, ahbsi, ahbso(0), memi, memo, sdo3);
    apbo(0) <= apb_none;
  end generate;

  mg2 : if CFG_MCTRL_LEON2 = 1 generate  -- LEON2 memory controller
    sr1 : mctrl generic map (
      hindex => 0, pindex => 0,
      paddr  => 0, srbanks => 2, sden => CFG_MCTRL_SDEN,
      invclk => CFG_MCTRL_INVCLK, sdlsb => CFG_SDSHIFT,
      sepbus => CFG_MCTRL_SEPBUS, sdbits => 32 + 32*CFG_MCTRL_SD64
      )
      port map (rstn, clkm, memi, memo, ahbsi, ahbso(0), apbi, apbo(0), wpo, sdo);

    sdpads : if CFG_MCTRL_SDEN = 1 generate  -- SDRAM controller
      sd2 : if CFG_MCTRL_SEPBUS = 1 generate
        sa_pad : outpadv generic map (width => 13) port map (sdaddr, memo.sa(12 downto 0));
        ba_pad : outpadv generic map (width => 2) port map (sdba, memo.sa(14 downto 13));
        bdr    : for i in 0 to 3 generate
          sddq_pad : iopadv generic map (tech => padtech, width => 8)
            port map (sddq(31-i*8 downto 24-i*8), memo.data(31-i*8 downto 24-i*8),
                      memo.bdrive(i), memi.sd(31-i*8 downto 24-i*8));
          sddq2 : if CFG_MCTRL_SD64 = 1 generate
            sddq_pad2 : iopadv generic map (tech => padtech, width => 8)
              port map (sddq(31-i*8+32 downto 24-i*8+32), memo.data(31-i*8 downto 24-i*8),
                        memo.bdrive(i), memi.sd(31-i*8+32 downto 24-i*8+32));
          end generate;
        end generate;
      end generate;
      sdwen_pad : outpad generic map (tech => padtech)
        port map (sdwen, sdo.sdwen);
      sdras_pad : outpad generic map (tech => padtech)
        port map (sdrasn, sdo.rasn);
      sdcas_pad : outpad generic map (tech => padtech)
        port map (sdcasn, sdo.casn);
      sddqm_pad : outpadv generic map (width => 8, tech => padtech)
        port map (sddqm, sdo.dqm);
      sdcke_pad : outpadv generic map (width => 2, tech => padtech)
        port map (sdcke, sdo.sdcke);
      sdcsn_pad : outpadv generic map (width => 2, tech => padtech)
        port map (sdcsn, sdo.sdcsn);
    end generate;
  end generate;


  sdclk_pad  : outpad generic map (tech => padtech, slew => 1) port map (sdclk(0), sdclkl);
  sdclk_pad2 : outpad generic map (tech => padtech, slew => 1) port map (sdclk(1), gnd(0));

  sd_controller : if CFG_SDCTRL /= 0 generate
    sdctrl_1 : sdctrl
      generic map (
        hindex => 5,
        haddr  => 16#600#,
        hmask  => 16#F00#,
        ioaddr => 16#500#,
        iomask => 16#FFF#,
        wprot  => 0,
        invclk => CFG_SDCTRL_INVCLK,
        fast   => 0,
        pwron  => 0,
        sdbits => 32 + 32*CFG_SDCTRL_SD64)
      port map (
        rst   => rstn,
        clk   => clkm,
        ahbsi => ahbsi,
        ahbso => ahbso(5),
        sdi   => sdi,
        sdo   => sdo2);

    -- output signals
    sdaddr <= sdo2.address(14 downto 2);
    sdba   <= sdo2.address(16 downto 15);
    sdcke  <= sdo2.sdcke;
    sdwen  <= sdo2.sdwen;
    sdcsn  <= sdo2.sdcsn;
    sdrasn <= sdo2.rasn;
    sdcasn <= sdo2.casn;
    sddqm  <= sdo2.dqm(7 downto 0);

    query_64_bit : if (CFG_SDCTRL_SD64 /= 0) generate
      sd_pad : iopadv generic map (width => 32)
        port map (sddq(63 downto 32),
                  sdo2.data(63 downto 32),
                  sdo2.bdrive,
                  sdi.data(63 downto 32));
    end generate;

    sd_pad2 : iopadv generic map (width => 32)
      port map (sddq(31 downto 0),
                sdo2.data(31 downto 0),
                sdo2.bdrive,
                sdi.data(31 downto 0));
  end generate sd_controller;

  nosd0 : if (CFG_MCTRL_SDEN = 0 and CFG_SDCTRL = 0) generate  -- no SDRAM controller
    sdclk_pad : outpad generic map (tech   => padtech, slew => 1) port map (sd_clk, sdclkl);
    sdcke_pad : outpadv generic map (width => 2, tech => padtech)
      port map (sdcke, sdo3.sdcke);
    sdcsn_pad : outpadv generic map (width => 2, tech => padtech)
      port map (sdcsn, sdo3.sdcsn);
  end generate;

  memi.brdyn  <= '1'; memi.bexcn <= '1';
  memi.writen <= '1'; memi.wrn <= "1111"; memi.bwidth <= "10";

  mg0 : if (CFG_MCTRL_LEON2 = 0) and (CFG_SRCTRL = 0) generate  -- no prom/sram controller
    apbo(0) <= apb_none; ahbso(0) <= ahbs_none;
    rams_pad : outpadv generic map (width => 5, tech => padtech)
      port map (ramsn, vcc);
    roms_pad : outpadv generic map (width => 2, tech => padtech)
      port map (romsn, vcc(1 downto 0));
  end generate;

  mgpads : if not ((CFG_MCTRL_LEON2 = 0) and (CFG_SRCTRL = 0)) generate  -- prom/sram controller
    addr_pad : outpadv generic map (width => 28, tech => padtech)
      port map (address, memo.address(27 downto 0));
    rams_pad : outpadv generic map (width => 5, tech => padtech)
      port map (ramsn, s_ramsn);
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
    bdr : for i in 0 to 3 generate
      data_pad : iopadv generic map (tech => padtech, width => 8)
        port map (data(31-i*8 downto 24-i*8), memo.data(31-i*8 downto 24-i*8),
                  memo.bdrive(i), memi.data(31-i*8 downto 24-i*8));
    end generate;
  end generate;

----------------------------------------------------------------------
---  APB Bridge and various peripherals -------------------------------
----------------------------------------------------------------------

  bpromgen : if CFG_AHBROMEN /= 0 generate
    brom : entity work.ahbrom
      generic map (hindex => 3, haddr => CFG_AHBRODDR, pipe => CFG_AHBROPIP)
      port map (rstn, clkm, ahbsi, ahbso(3));
  end generate;
  nobpromgen : if CFG_AHBROMEN = 0 generate
    ahbso(3) <= ahbs_none;
  end generate;

----------------------------------------------------------------------
---  APB Bridge and various periherals -------------------------------
----------------------------------------------------------------------

  apb0 : apbctrl                        -- AHB/APB bridge
    generic map (hindex => 1, haddr => CFG_APBADDR)
    port map (rstn, clkm, ahbsi, ahbso(1), apbi, apbo);

  -- APB uart
  ua1 : if CFG_UART1_ENABLE /= 0 generate
    uart1 : apbuart                     -- UART 1
      generic map (pindex   => 1, paddr => 1, pirq => 2, console => dbguart,
                   fifosize => CFG_UART1_FIFO)
      port map (rstn, clkm, apbi, apbo(1), u1i, u1o);
    u1i.rxd <= rxd1; u1i.ctsn <= '0'; u1i.extclk <= '0'; txd1 <= u1o.txd;
  end generate;
  noua0 : if CFG_UART1_ENABLE = 0 generate apbo(1) <= apb_none; end generate;

  -- interrupt controller
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

  -- general purpose timer
  gpt : if CFG_GPT_ENABLE /= 0 generate
    timer0 : gptimer                    -- timer unit
      generic map (pindex => 3, paddr => 3, pirq => CFG_GPT_IRQ,
                   sepirq => CFG_GPT_SEPIRQ, sbits => CFG_GPT_SW, ntimers => CFG_GPT_NTIM,
                   nbits  => CFG_GPT_TW)
      port map (rstn, clkm, apbi, apbo(3), gpti, open);
    gpti.dhalt <= dsuo.tstop; gpti.extclk <= '0';
  end generate;
  notim : if CFG_GPT_ENABLE = 0 generate apbo(3) <= apb_none; end generate;

  -- VGA interface
  vga : if CFG_VGA_ENABLE /= 0 generate
    vga0 : apbvga generic map(memtech => memtech, pindex => 4, paddr => 4)
      port map(rstn, clkm, clk_25MHz, apbi, apbo(4), vgao);
    -- port map(rstn, clkm, clkm, apbi, apbo(4), vgao);
  end generate;

  novga : if CFG_VGA_ENABLE = 0 generate apbo(4) <= apb_none; vgao <= vgao_none; end generate;

  vert_sync_pad : outpad generic map (tech => padtech)
    port map (vga_vsync, vgao.vsync);
  horiz_sync_pad : outpad generic map (tech => padtech)
    port map (vga_hsync, vgao.hsync);
  video_out_r_pad : outpadv generic map (width => 8, tech => padtech)
    port map (vga_rd, vgao.video_out_r(7 downto 0));
  video_out_g_pad : outpadv generic map (width => 8, tech => padtech)
    port map (vga_gr, vgao.video_out_g(7 downto 0));
  video_out_b_pad : outpadv generic map (width => 8, tech => padtech)
    port map (vga_bl, vgao.video_out_b(7 downto 0));
  -- pixel clock = system clock
  vga_clk_pad : outpad generic map (tech => padtech)
    port map (vga_clk, clk_25MHz);
  -- port map (vga_clk, clkm);
  -- via syncn, additional sync information could be transported
  -- on the green colour channel
  -- connecting it to ground disables this feature
  vga_syncn_pad : outpad generic map (tech => padtech)
    port map (vga_syncn, gnd(0));
  -- don't disable output
  vga_blankn_pad : outpad generic map (tech => padtech)
    port map (vga_blankn, vcc(0));

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
        clk_freq_in => CPU_FREQ,
        hpe_version => midi,
        led7act     => '0',
        ledact      => '0',
        switchact   => '0',  -- switch polarity is inverse to Hpe_compact
        buttonact   => '1')
      port map (
        rst_n       => rstn,
        clk         => clkm,
        apbi        => apbi,
        apbo        => apbo(6),
        MultiIO_in  => mioi,
        MultiIO_out => mioo);

    mioi.switch_in <= dsw;
    mioi.row_in    <= tst_row;

    -- expansion connector
    mioi.exp_in <= exp_datai;
    exp_datao   <= mioo.exp_out;

    sevensegment <= mioo.led_ca_out(1) &  -- 9
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

    lcd_regsel <= mioo.lcd_regsel;
    lcd_rw     <= mioo.lcd_rw;
    lcd_enable <= mioo.lcd_enable;
    
  end generate;

  nMULTIIO : if CFG_MULTIIO = 0 generate
    apbo(6) <= apb_none;
  end generate;

-----------------------------------------------------------------------
---  ETHERNET ---------------------------------------------------------
-----------------------------------------------------------------------

  eth0 : if CFG_GRETH = 1 generate      -- Gaisler ethernet MAC
    e1 : greth generic map(hindex    => CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG+CFG_GRUSB_DCL,
                           pindex    => 15, paddr => 15, pirq => 12, memtech => memtech,
                           mdcscaler => CPU_FREQ/1000000, enable_mdio => 1, fifosize => CFG_ETH_FIFO,
                           nsync     => 1, edcl => CFG_DSU_ETH, edclbufsz => CFG_ETH_BUF,
                           macaddrh  => CFG_ETH_ENM, macaddrl => CFG_ETH_ENL,
                           ipaddrh   => CFG_ETH_IPM, ipaddrl => CFG_ETH_IPL)
      port map(rst   => rstn, clk => clkm, ahbmi => ahbmi,
               ahbmo => ahbmo(CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG+CFG_GRUSB_DCL), apbi => apbi,
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
      port map (ereset, rstn);

  end generate;


-----------------------------------------------------------------------
---  CAN --------------------------------------------------------------
-----------------------------------------------------------------------

  can1 : if CFG_CAN /= 0 generate       -- Opencores can MAC
    can0 : can_oc
      generic map (
        slvndx => 6,
        ioaddr => CFG_CANIO,
        iomask => 16#FF0#,
        irq    => 13)
      port map (
        resetn  => rstn,
        clk     => clkm,
        ahbsi   => ahbsi,
        ahbso   => ahbso(6),
        can_rxi => rx,
        can_txo => tx
        );
  end generate;

  ncan : if CFG_CAN = 0 generate
    ahbso(6) <= ahbs_none;
  end generate;

  -- CAN Transceiver mode (phy)
  -- Can stb = 0  operating
  -- Can stb = 1  standby
  CAN_STB <= '0';

  -- Can rx and tx must be hot-wired in case of testing can
  test_can : if CFG_CANLOOP = 1 generate
    rx <= tx;
  end generate;

  normal_can : if CFG_CANLOOP = 0 generate
    rx      <= CAN_RXD;
    CAN_TXD <= tx;
  end generate;

-----------------------------------------------------------------------
---  AHB RAM ----------------------------------------------------------
-----------------------------------------------------------------------

  ocram : if CFG_AHBRAMEN = 1 generate
    ahbram0 : ahbram generic map (hindex => 7, haddr => CFG_AHBRADDR,
                                  tech   => CFG_MEMTECH, kbytes => CFG_AHBRSZ)
      port map (rstn, clkm, ahbsi, ahbso(7));
  end generate;
  nram : if CFG_AHBRAMEN = 0 generate ahbso(7) <= ahbs_none; end generate;

-----------------------------------------------------------------------
---  Drive unused bus elements  ---------------------------------------
-----------------------------------------------------------------------

  nam1 : for i in (CFG_NCPU+CFG_AHB_UART+CFG_GRETH+CFG_GRUSB_DCL+CFG_AHB_JTAG) to NAHBMST-1 generate
    ahbmo(i) <= ahbm_none;
  end generate;

  nap0 : for i in 11 to NAPBSLV-1-CFG_GRETH generate apbo(i) <= apb_none; end generate;

  nah0 : for i in 9 to NAHBSLV-1 generate ahbso(i) <= ahbs_none; end generate;

-----------------------------------------------------------------------
---  Adaptions for HPE midi ----------------------------------------
-----------------------------------------------------------------------

  -- rben vector is pulled down entirely while reading,
  -- selected vector elements pulled down while writing
  rben <= (others => '0') when memo.ramoen(0) = '0' else
          memo.wrn;
  -- invert signal for input via a key
  -- invert dsuact signal for output on LED
  dsuactn <= not dsuact;

  s_ramsn <= memo.ramsn(4 downto 0);

  -- drive reset signal for peripherals like ethernet, flash etc.
  -- use USB reset for USB DCL (experimental)
  -- USB reset needs to be decoupled from general resout signal
  resoutn <= rstn;                      -- reset signal for USB host chip, exp.
                                        -- connector


  ---------------------------------------------------------------------------------------
  -- PS/2 interface
  ---------------------------------------------------------------------------------------

  -- INTERFACE 0 CANNOT BE USED, SINCE THE OUTPUT SIGNAL PS2CLOCK(0)
  -- WOULD HAVE TO BE ASSIGNED TO FPGA INPUT PIN U30!!

  ps2_0if : if CFG_KBD_ENABLE /= 0 generate
    -- PS/2 interface 0 (keyboard, bottom connector)
    apbps2_0 : apbps2
      generic map (
        pindex => 10,
        paddr  => 10,
        pirq   => 4,
        fKHz   => PS2_SCALER,  --CPU_FREQ/15,  -- clock divider for APB clock (13.3 kHz selected)
        fixed  => 0)  -- clock can be programmed via timer reload reg
      port map (
        rst  => rstn,
        clk  => clkm,
        apbi => apbi,
        apbo => apbo(10),
        ps2i => kbdi0,
        ps2o => kbdo0);
  end generate ps2_0if;

  no_ps2_1if : if CFG_KBD_ENABLE = 0 generate
    apbo(10) <= apb_none;
    kbdo0    <= ps2o_none;
  end generate no_ps2_1if;

  kbd0_clk_pad : iopad generic map (tech => padtech)
    port map (ps2_clk(0), kbdo0.ps2_clk_o, kbdo0.ps2_clk_oe, kbdi0.ps2_clk_i);

  kbd0_data_pad : iopad generic map (tech => padtech)
    port map (ps2_data(0), kbdo0.ps2_data_o, kbdo0.ps2_data_oe, kbdi0.ps2_data_i);


  ps2_1if : if CFG_KBD_ENABLE /= 0 generate
    -- PS/2 interface 1 (keyboard, top connector)
    apbps2_1 : apbps2
      generic map (
        pindex => 5,
        paddr  => 5,
        pirq   => 4,
        fKHz   => PS2_SCALER,           -- CPU_FREQ/15,
        fixed  => 0)
      port map (
        rst  => rstn,
        clk  => clkm,
        apbi => apbi,
        apbo => apbo(5),
        ps2i => kbdi1,
        ps2o => kbdo1);
  end generate ps2_1if;

  no_ps2_if : if CFG_KBD_ENABLE = 0 generate
    apbo(5) <= apb_none;
    kbdo1   <= ps2o_none;
  end generate no_ps2_if;

  kbd1_clk_pad : iopad generic map (tech => padtech)
    port map (ps2_clk(1), kbdo1.ps2_clk_o, kbdo1.ps2_clk_oe, kbdi1.ps2_clk_i);

  kbd1_data_pad : iopad generic map (tech => padtech)
    port map (ps2_data(1), kbdo1.ps2_data_o, kbdo1.ps2_data_oe, kbdi1.ps2_data_i);

  -----------------------------------------------------------------------------
  -- ADC/DAC interface
  -----------------------------------------------------------------------------

  adcdac_inst : if CFG_ADCDAC /= 0 generate
    adcdac_1 : adcdac
      generic map (
        pindex => 9,
        paddr  => 9,
        pmask  => 16#FFF#,
        nbits  => 10)
      port map (
        rst     => rstn,
        clk     => clkm,
        apbi    => apbi,
        apbo    => apbo(9),
        adcdaci => adcdaci,
        adcdaco => adcdaco);

    adcdaci.adc_in <= adc_dout;
    adc_ain        <= adcdaco.adc_fb;
    dac_out        <= adcdaco.dac_out;

  end generate;

  nadcdac_inst : if CFG_ADCDAC = 0 generate
    apbo(9) <= apb_none;
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
        drive_bus => drive_bus,
        dbg_equal => dbg_equal
        );

    hpidata <= hpiwdata when drive_bus = '1' else
               (others => 'Z');

    hpirdata <= hpidata;

    hpiwrn <= hpiwriten;

  end generate;
  nahb2hpi_inst : if CFG_AHB2HPI = 0 generate
    ahbso(8) <= ahbs_none;
  end generate;

  ---------------------------------------------------------------------------------------
  -- Simple SPI Controller
  ---------------------------------------------------------------------------------------
  spi_oc_inst : if CFG_SPI_OC /= 0 generate
    spi_oc_1 : spi_oc
      generic map (
        pindex => 8,
        paddr  => 8,
        pmask  => 16#FFF#,
        pirq   => 5)
      port map (
        rstn    => rstn,
        clk     => clkm,
        apbi    => apbi,
        apbo    => apbo(8),
        spi_in  => spii,
        spi_out => spio);

    -- inputs from SD card
    spii.miso <= sdcard_do;

    -- outputs to SD card
    sdcard_cs   <= spio.ssn(0);
    sdcard_di   <= spio.mosi;
    sdcard_sclk <= spio.sck;

  end generate;

  gspi_inst : if CFG_SPICTRL_ENABLE /= 0 and CFG_SPI_OC = 0 generate
    gspi_1 : spictrl
      generic map (
        pindex   => 8,
        paddr    => 8,
        pmask    => 16#FFF#,
        pirq     => 5,
        fdepth   => CFG_SPICTRL_FIFO,                  -- FIFO depth is 2^fdepth
        slvselen => CFG_SPICTRL_SLVREG,                  -- Slave select register enable
        slvselsz => CFG_SPICTRL_SLVS)                  -- Number of slave select signal
      port map (
        rstn => rstn,
        clk  => clkm,
        apbi => apbi,
        apbo => apbo(8),
        spii => gspii,
        spio => gspio);

    -- inputs from SD card
    gspii.miso <= sdcard_do;

    -- outputs to SD card
    sdcard_cs   <= gspio.ssn(0);
    sdcard_di   <= gspio.mosi;
    sdcard_sclk <= gspio.sck;

  end generate;

  nspi_inst : if CFG_SPI_OC = 0 and CFG_SPICTRL_ENABLE = 0 generate
    apbo(8) <= apb_none;
  end generate;


  -----------------------------------------------------------------------------
  -- AUDIO CODEC
  -----------------------------------------------------------------------------
  ac97_oc_inst : if CFG_AC97_OC /= 0 generate

    -- DMA not used at the moment
    dma_ack <= (others => '0');

    -- drive AC97 external clock with 25 MHz
    ac97_ext_clk <= clk_25MHz;

    ac97_oc_1 : ac97_oc
      generic map (
        slvndx => 4,
        ioaddr => 16#300#,
        iomask => 16#FFF#,
        irq    => 7)
      port map (
        resetn => rstn,
        clk    => clkm,
        ahbsi  => ahbsi,
        ahbso  => ahbso(4),

        -- AC97 interface
        bit_clk_pad_i     => ac97_bit_clk,
        sdata_pad_i       => ac97_sdata_in,
        -- output signals have to go via
        -- intermediate signals
        sync_pad_o        => ac97_int_sync,
        sdata_pad_o       => ac97_int_sdata_out,
        ac97_reset_padn_o => ac97_int_resetn,

        int_o       => ac97_int_irq,
        dma_req_o   => open,
        dma_ack_i   => dma_ack,
        suspended_o => open,
        int_pol     => vcc(0)           -- interrupts active high
        );

    -- drive AC97 outputs from intermediate signals
    ac97_sync      <= ac97_int_sync;
    ac97_sdata_out <= ac97_int_sdata_out;
    ac97_resetn    <= ac97_int_resetn;

  end generate;
  nac97_oc_inst : if CFG_AC97_OC = 0 generate
    ahbso(4) <= ahbs_none;
  end generate;


-----------------------------------------------------------------------
---  Boot message  ----------------------------------------------------
-----------------------------------------------------------------------

-- pragma translate_off
  x : report_version
    generic map (
      msg1 => "LEON3 Demonstration design for Hpe-midi with module AS1-180",
      msg2 => "GRLIB Version " & tost(LIBVHDL_VERSION/100) & "." & tost((LIBVHDL_VERSION mod 10)/10)
      & "." & tost(LIBVHDL_VERSION mod 100),
      msg3 => "Target technology: " & tech_table(fabtech) & ",  memory library: " & tech_table(memtech),
      mdel => 1
      );
-- pragma translate_on
end;
