------------------------------------------------------------------------------
--  LEON3 Demonstration design
--  Copyright (C) 2006 Jiri Gaisler, Gaisler Research
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
use techmap.allclkgen.all;
library gaisler;
use gaisler.memctrl.all;
use gaisler.leon3.all;
use gaisler.uart.all;
use gaisler.misc.all;
use gaisler.net.all;
use gaisler.jtag.all;
library esa;
use esa.memoryctrl.all;
use work.config.all;

entity leon3mp is
  generic (
    fabtech  : integer := CFG_FABTECH;
    memtech  : integer := CFG_MEMTECH;
    padtech  : integer := CFG_PADTECH;
    clktech  : integer := CFG_CLKTECH;
    disas    : integer := CFG_DISAS;     -- Enable disassembly to console
    dbguart  : integer := CFG_DUART;     -- Print UART on console
    pclow    : integer := CFG_PCLOW;
    memmask  : integer := 0;
    ddraddr  : integer := 16#400#;
    ddrdelay : integer := 1;
    ddrskew  : integer := 130
    );
  port (
    reset     : in    std_ulogic;
    reset_o1  : out   std_ulogic;
    reset_o2  : out   std_ulogic;
    clk_in    : in    std_ulogic;
    clk_vga   : in    std_ulogic;
    errorn    : out   std_ulogic;

    -- PROM interface
    address   : out   std_logic_vector(23 downto 0);
    data      : inout std_logic_vector(7 downto 0);
    romsn     : out   std_ulogic;
    oen       : out   std_ulogic;
    writen    : out   std_ulogic;
-- pragma translate_off
    iosn      : out   std_ulogic;
    ramsn     : out   std_ulogic;
    ramoen    : out   std_ulogic;
    ramwrn    : out   std_ulogic;
    testdata  : inout std_logic_vector(23 downto 0);
-- pragma translate_on 

    -- DDR2 memory  
    ddr_clk        : out   std_logic_vector(1 downto 0);
    ddr_clkb       : out   std_logic_vector(1 downto 0);
    ddr_clk_fb_out : out   std_logic;
    ddr_clk_fb     : in    std_logic;
    ddr_cke        : out   std_logic;
    ddr_csb        : out   std_logic;
    ddr_we         : out   std_ulogic;                     -- write enable
    ddr_ras        : out   std_ulogic;                     -- ras
    ddr_cas        : out   std_ulogic;                     -- cas
    ddr_dm         : out   std_logic_vector(3 downto 0);   -- dm
    ddr_dqs        : inout std_logic_vector(3 downto 0);   -- dqs
    ddr_dqsn       : inout std_logic_vector(3 downto 0);   -- dqsn
    ddr_ad         : out   std_logic_vector(12 downto 0);  -- address
    ddr_ba         : out   std_logic_vector(1 downto 0);   -- bank address
    ddr_dq         : inout std_logic_vector(31 downto 0);  -- data
    ddr_odt        : out   std_logic;
    
    -- Debug support unit
    dsubre    : in    std_ulogic;       -- Debug Unit break (connect to button)

    -- AHB Uart
    dsurx     : in    std_ulogic;
    dsutx     : out   std_ulogic;

    -- Ethernet signals
    etx_clk   : in    std_ulogic;
    erx_clk   : in    std_ulogic;
    erxd      : in    std_logic_vector(3 downto 0);
    erx_dv    : in    std_ulogic;
    erx_er    : in    std_ulogic;
    erx_col   : in    std_ulogic;
    erx_crs   : in    std_ulogic;
    etxd      : out   std_logic_vector(3 downto 0);
    etx_en    : out   std_ulogic;
    etx_er    : out   std_ulogic;
    emdc      : out   std_ulogic;
    emdio     : inout std_logic;

    -- SVGA
    vid_hsync : out   std_logic;
    vid_vsync : out   std_logic;
    vid_r     : out   std_logic_vector(3 downto 0);
    vid_g     : out   std_logic_vector(3 downto 0);
    vid_b     : out   std_logic_vector(3 downto 0);

    -- Select signal for SPI flash
    spi       : out   std_ulogic;

    -- Output signals to LEDs
    led       : out   std_logic_vector(2 downto 0)
    );
end;

architecture rtl of leon3mp is
  signal vcc : std_logic;
  signal gnd : std_logic;

  signal memi : memory_in_type;
  signal memo : memory_out_type;
  signal wpo  : wprot_out_type;

  signal gpioi : gpio_in_type;
  signal gpioo : gpio_out_type;

  signal apbi  : apb_slv_in_type;
  signal apbo  : apb_slv_out_vector := (others => apb_none);
  signal ahbsi : ahb_slv_in_type;
  signal ahbso : ahb_slv_out_vector := (others => ahbs_none);
  signal ahbmi : ahb_mst_in_type;
  signal ahbmo : ahb_mst_out_vector := (others => ahbm_none);

  signal cgi : clkgen_in_type;
  signal cgo : clkgen_out_type;

  signal u1i, dui : uart_in_type;
  signal u1o, duo : uart_out_type;

  signal irqi : irq_in_vector(0 to CFG_NCPU-1);
  signal irqo : irq_out_vector(0 to CFG_NCPU-1);

  signal dbgi : l3_debug_in_vector(0 to CFG_NCPU-1);
  signal dbgo : l3_debug_out_vector(0 to CFG_NCPU-1);

  signal dsui : dsu_in_type;
  signal dsuo : dsu_out_type;

  signal ethi : eth_in_type;
  signal etho : eth_out_type;

  signal gpti : gptimer_in_type;

  signal vgao : apbvga_out_type;

  signal lclk               : std_ulogic;
  signal lclk_vga           : std_ulogic;
  signal clkm, rstn, clkml  : std_ulogic;
  signal tck, tms, tdi, tdo : std_ulogic;
  signal rstraw             : std_logic;
  signal lock               : std_logic;

  -- RS232 APB Uart
  signal rxd1 : std_logic;
  signal txd1 : std_logic;

  
  -- Used for connecting input/output signals to the DDR2 controller
  signal core_ddr_clk  : std_logic_vector(2 downto 0);
  signal core_ddr_clkb : std_logic_vector(2 downto 0);
  signal core_ddr_cke  : std_logic_vector(1 downto 0);
  signal core_ddr_csb  : std_logic_vector(1 downto 0);
  signal core_ddr_ad   : std_logic_vector(13 downto 0);
  signal core_ddr_odt  : std_logic_vector(1 downto 0);

  attribute keep                     : boolean;
  attribute syn_keep                 : boolean;
  attribute syn_preserve             : boolean;
  attribute syn_keep of lock         : signal is true;
  attribute syn_keep of clkml        : signal is true;
  attribute syn_keep of clkm         : signal is true;
  attribute syn_preserve of clkml    : signal is true;
  attribute syn_preserve of clkm     : signal is true;
  attribute syn_keep of lclk_vga     : signal is true;
  attribute syn_preserve of lclk_vga : signal is true;
  attribute keep of lock             : signal is true;
  attribute keep of clkml            : signal is true;
  attribute keep of clkm             : signal is true;

  constant BOARD_FREQ : integer := 125000;                                -- input frequency in KHz
  constant CPU_FREQ   : integer := BOARD_FREQ * CFG_CLKMUL / CFG_CLKDIV;  -- cpu frequency in KHz
begin

----------------------------------------------------------------------
---  Reset and Clock generation  -------------------------------------
----------------------------------------------------------------------

  vcc <= '1';
  gnd <= '0';
  cgi.pllctrl <= "00";
  cgi.pllrst <= rstraw;
  spi <= '1';                   -- Deselects SPI flash

  -- Glitch free reset that can be used for the Eth Phy and flash memory
  reset_o1 <= rstn;
  reset_o2 <= rstn;

  rst0 : rstgen generic map (acthigh => 1)
    port map (reset, clkm, lock, rstn, rstraw);
  
  clk_pad : clkpad generic map (tech => padtech) port map (clk_in,  lclk); 
  clk_vga_pad : clkpad generic map (tech => padtech) port map (clk_vga, lclk_vga); 

  -- clock generator
  clkgen0 : clkgen
    generic map (fabtech, CFG_CLKMUL, CFG_CLKDIV, 0, 0, 0, 0, 0, BOARD_FREQ, 0)
    port map (lclk, gnd, clkm, open, open, open, open, cgi, cgo, open, open, open);

---------------------------------------------------------------------- 
---  AHB CONTROLLER --------------------------------------------------
----------------------------------------------------------------------

  ahb0 : ahbctrl
    generic map (defmast => CFG_DEFMST, split => CFG_SPLIT,
                 rrobin  => CFG_RROBIN, ioaddr => CFG_AHBIO, ioen => 1, 
                 nahbm => CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG+CFG_GRETH+CFG_SVGA_ENABLE, 
                 nahbs => 8)
    port map (rstn, clkm, ahbmi, ahbmo, ahbsi, ahbso);

----------------------------------------------------------------------
---  LEON3 processor and DSU -----------------------------------------
----------------------------------------------------------------------

  -- LEON3 processor
  leon3gen : if CFG_LEON3 = 1 generate
    cpu : for i in 0 to CFG_NCPU-1 generate
      u0 : leon3s
        generic map (i, fabtech, memtech, CFG_NWIN, CFG_DSU, CFG_FPU, CFG_V8,
                     0, CFG_MAC, pclow, 0, CFG_NWP, CFG_ICEN, CFG_IREPL, CFG_ISETS, CFG_ILINE,
                     CFG_ISETSZ, CFG_ILOCK, CFG_DCEN, CFG_DREPL, CFG_DSETS, CFG_DLINE, CFG_DSETSZ,
                     CFG_DLOCK, CFG_DSNOOP, CFG_ILRAMEN, CFG_ILRAMSZ, CFG_ILRAMADDR, CFG_DLRAMEN,
                     CFG_DLRAMSZ, CFG_DLRAMADDR, CFG_MMUEN, CFG_ITLBNUM, CFG_DTLBNUM, CFG_TLB_TYPE, CFG_TLB_REP,
                     CFG_LDDEL, disas, CFG_ITBSZ, CFG_PWD, CFG_SVT, CFG_RSTADDR,
                     CFG_NCPU-1)
        port map (clkm, rstn, ahbmi, ahbmo(i), ahbsi, ahbso, irqi(i), irqo(i), dbgi(i), dbgo(i));
    end generate;

    error_pad : odpad generic map (tech => padtech) port map (errorn, dbgo(0).error);

    -- LEON3 Debug Support Unit    
    dsugen : if CFG_DSU = 1 generate
      dsu0 : dsu3
        generic map (hindex => 2, haddr => 16#900#, hmask => 16#F00#,
                     ncpu   => CFG_NCPU, tbits => 30, tech => memtech, irq => 0, kbytes => CFG_ATBSZ)
        port map (rstn, clkm, ahbmi, ahbsi, ahbso(2), dbgo, dbgi, dsui, dsuo);

      dsubre_pad : inpad generic map (tech  => padtech) port map (dsubre, dsui.break);

      dsui.enable <= '1';
      led(2) <= dsuo.active;
    end generate;
  end generate;
  nodcom : if CFG_DSU = 0 generate ahbso(2) <= ahbs_none; end generate;

  -- Debug UART
  dcomgen : if CFG_AHB_UART = 1 generate
    dcom0 : ahbuart
      generic map (hindex => CFG_NCPU, pindex => 4, paddr => 7)
      port map (rstn, clkm, dui, duo, apbi, apbo(4), ahbmi, ahbmo(CFG_NCPU));
    dsurx_pad : inpad generic map (tech  => padtech) port map (dsurx, dui.rxd);
    dsutx_pad : outpad generic map (tech => padtech) port map (dsutx, duo.txd);
    led(0) <= not dui.rxd;
    led(1) <= not duo.txd;
  end generate;
  nouah : if CFG_AHB_UART = 0 generate apbo(4) <= apb_none; end generate;

  ahbjtaggen0 :if CFG_AHB_JTAG = 1 generate
    ahbjtag0 : ahbjtag generic map(tech => fabtech, hindex => CFG_NCPU+CFG_AHB_UART)
      port map(rstn, clkm, tck, tms, tdi, tdo, ahbmi, ahbmo(CFG_NCPU+CFG_AHB_UART),
               open, open, open, open, open, open, open, gnd);
  end generate;

----------------------------------------------------------------------
---  Memory controllers ----------------------------------------------
----------------------------------------------------------------------

  mg2 : if CFG_MCTRL_LEON2 = 1 generate        -- LEON2 memory controller
    sr1 : mctrl generic map (hindex => 5, pindex => 0, paddr => 0, ram8 => CFG_MCTRL_RAM8BIT, ram16 => CFG_MCTRL_RAM16BIT, rammask => memmask) --16#F80# )
      port map (rstn, clkm, memi, memo, ahbsi, ahbso(5), apbi, apbo(0), wpo, open);
  end generate;

  memi.brdyn  <= '1';
  memi.bexcn  <= '1';
  memi.writen <= '1';
  memi.wrn    <= "1111";
  memi.bwidth <= "00";

  mg0 : if (CFG_MCTRL_LEON2 = 0) generate 
    apbo(0) <= apb_none;
    ahbso(0) <= ahbs_none;
    roms_pad : outpad generic map (tech => padtech)
      port map (romsn, vcc);
  end generate;

  mgpads : if (CFG_MCTRL_LEON2 /= 0) generate 
    addr_pad : outpadv generic map (tech => padtech, width => 24)
      port map (address, memo.address(23 downto 0));
    roms_pad : outpad generic map (tech => padtech)
      port map (romsn, memo.romsn(0));
    oen_pad : outpad generic map (tech => padtech)
      port map (oen, memo.oen);
    wri_pad : outpad generic map (tech => padtech)
      port map (writen, memo.writen);

-- pragma translate_off
    ramsn_pad : outpad generic map (tech => padtech)
      port map (ramsn, memo.ramsn(0));
    ramoen_pad : outpad generic map (tech => padtech)
      port map (ramoen, memo.ramoen(0));
    ramen_pad : outpad generic map (tech => padtech)
      port map (ramwrn, memo.wrn(0));
    
    iosn_pad : outpad generic map (tech => padtech) 
	port map (iosn, memo.iosn);
    tbdr : iopadv generic map (tech => padtech, width => 24)
        port map (testdata(23 downto 0), memo.data(23 downto 0),
                  memo.bdrive(1), memi.data(23 downto 0));
-- pragma translate_on

    bdr : iopadv generic map (tech => padtech, width => 8)
        port map (data(7 downto 0), memo.data(31 downto 24),
                  memo.bdrive(0), memi.data(31 downto 24));
  end generate;

----------------------------------------------------------------------
---  DDR2 memory controller ------------------------------------------
----------------------------------------------------------------------
  
  ddr2sp0 : if (CFG_DDR2SP /= 0) generate 
    ddrc0 : ddr2spa generic map ( fabtech => spartan3, memtech => memtech,
      hindex => 4, haddr => ddraddr, hmask => 16#F80#, ioaddr => 1, 
      pwron => CFG_DDR2SP_INIT, MHz => BOARD_FREQ/1000, clkmul => 2, clkdiv => 2,
      TRFC => CFG_DDR2SP_TRFC,
      ahbfreq => CPU_FREQ/1000, col => CFG_DDR2SP_COL, Mbyte => CFG_DDR2SP_SIZE,
      ddrbits => CFG_DDR2SP_DATAWIDTH, odten => 0, readdly => ddrdelay, rskew => ddrskew)
    port map ( cgo.clklock, rstn, lclk, clkm, vcc, lock, clkml, clkml, ahbsi, ahbso(4),
        core_ddr_clk, core_ddr_clkb, ddr_clk_fb_out, ddr_clk_fb, core_ddr_cke,
        core_ddr_csb, ddr_we, ddr_ras, ddr_cas, ddr_dm, ddr_dqs, ddr_dqsn,
        core_ddr_ad, ddr_ba, ddr_dq, core_ddr_odt);

    ddr_clk(1 downto 0)  <= core_ddr_clk(1 downto 0);
    ddr_clkb(1 downto 0) <= core_ddr_clkb(1 downto 0);
    ddr_cke              <= core_ddr_cke(0);
    ddr_csb              <= core_ddr_csb(0);
    ddr_ad               <= core_ddr_ad(12 downto 0);
    ddr_odt              <= core_ddr_odt(0);
  end generate;

  noddr : if (CFG_DDR2SP = 0) generate lock <= '1'; end generate;

----------------------------------------------------------------------
---  APB Bridge and various periherals -------------------------------
----------------------------------------------------------------------

  -- APB Bridge
  apb0 : apbctrl
    generic map (hindex => 1, haddr => CFG_APBADDR)
    port map (rstn, clkm, ahbsi, ahbso(1), apbi, apbo);

  -- Interrupt controller
  irqctrl : if CFG_IRQ3_ENABLE /= 0 generate
    irqctrl0 : irqmp
      generic map (pindex => 2, paddr => 2, ncpu => CFG_NCPU)
      port map (rstn, clkm, apbi, apbo(2), irqo, irqi);
  end generate;
  irq3 : if CFG_IRQ3_ENABLE = 0 generate
    x : for i in 0 to CFG_NCPU-1 generate
      irqi(i).irl <= "0000";
    end generate;
    apbo(2) <= apb_none;
  end generate;

  -- Time Unit
  gpt : if CFG_GPT_ENABLE /= 0 generate
    timer0 : gptimer
      generic map (pindex => 3, paddr => 3, pirq => CFG_GPT_IRQ,
                   sepirq => CFG_GPT_SEPIRQ, sbits => CFG_GPT_SW,
                   ntimers => CFG_GPT_NTIM, nbits  => CFG_GPT_TW)
      port map (rstn, clkm, apbi, apbo(3), gpti, open);
    gpti.dhalt  <= dsuo.active;
    gpti.extclk <= '0';
  end generate;
  notim : if CFG_GPT_ENABLE = 0 generate apbo(3) <= apb_none; end generate;

  -- GPIO Unit
  gpio0 : if CFG_GRGPIO_ENABLE /= 0 generate
    grgpio0: grgpio
      generic map(pindex => 11, paddr => 11, imask => CFG_GRGPIO_IMASK, nbits => 12)
      port map(rstn, clkm, apbi, apbo(11), gpioi, gpioo);
  end generate;

  ua1 : if CFG_UART1_ENABLE /= 0 generate
    uart1 : apbuart                     -- UART 1
      generic map (pindex   => 1, paddr => 1, pirq => 2, console => dbguart, fifosize => CFG_UART1_FIFO)
      port map (rstn, clkm, apbi, apbo(1), u1i, u1o);
    u1i.rxd    <= rxd1;
    u1i.ctsn   <= '0';
    u1i.extclk <= '0';
    txd1       <= u1o.txd;
    serrx_pad : inpad generic map (tech  => padtech) port map (dsurx, rxd1);
    sertx_pad : outpad generic map (tech => padtech) port map (dsutx, txd1);
    led(0) <= not rxd1;
    led(1) <= not txd1;
  end generate;
  noua0 : if CFG_UART1_ENABLE = 0 generate apbo(1) <= apb_none; end generate;

  -- There is no PS/2 port
  apbo(5) <= apb_none;

-----------------------------------------------------------------------
---  SVGA -------------------------------------------------------------
-----------------------------------------------------------------------

  svga : if CFG_SVGA_ENABLE /= 0 generate
    svga0 : svgactrl
      generic map(memtech => memtech, pindex => 6, paddr => 6,
                  hindex => CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG, 
                  clk0 => 40000,clk1 => 0, clk2 => 0, burstlen => 5)
      port map(rstn, clkm, lclk_vga, apbi, apbo(6), vgao, ahbmi, 
               ahbmo(CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG), open);

    vert_sync_pad : outpad generic map (tech => padtech)
      port map (vid_vsync, vgao.vsync);
    horiz_sync_pad : outpad generic map (tech => padtech)
      port map (vid_hsync, vgao.hsync);
    video_out_r_pad : outpadv generic map (tech => padtech, width => 4)
      port map (vid_r, vgao.video_out_r(7 downto 4));
    video_out_g_pad : outpadv generic map (tech => padtech, width => 4)
      port map (vid_g, vgao.video_out_g(7 downto 4));
    video_out_b_pad : outpadv generic map (tech => padtech, width => 4)
      port map (vid_b, vgao.video_out_b(7 downto 4)); 
  end generate;

-----------------------------------------------------------------------
---  ETHERNET ---------------------------------------------------------
-----------------------------------------------------------------------

  eth0 : if CFG_GRETH = 1 generate -- Gaisler ethernet MAC
    e1 : grethm
      generic map(hindex => CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG+CFG_SVGA_ENABLE,
                  pindex => 15, paddr => 15, pirq => 12, memtech => memtech,
                  mdcscaler => CPU_FREQ/1000, enable_mdio => 1, fifosize => CFG_ETH_FIFO,
                  nsync => 1, edcl => CFG_DSU_ETH, edclbufsz => CFG_ETH_BUF,
                  macaddrh => CFG_ETH_ENM, macaddrl => CFG_ETH_ENL, 
                  ipaddrh => CFG_ETH_IPM, ipaddrl => CFG_ETH_IPL, giga => CFG_GRETH1G)
      port map(rst => rstn, clk => clkm, ahbmi => ahbmi,
               ahbmo => ahbmo(CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG+CFG_SVGA_ENABLE), 
               apbi => apbi, apbo => apbo(15), ethi => ethi, etho => etho); 
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

    etxd_pad : outpadv generic map (tech => padtech, width => 4)
      port map (etxd, etho.txd(3 downto 0));
    etxen_pad : outpad generic map (tech => padtech)
      port map (etx_en, etho.tx_en);
    etxer_pad : outpad generic map (tech => padtech)
      port map (etx_er, etho.tx_er);
    emdc_pad : outpad generic map (tech => padtech)
      port map (emdc, etho.mdc);
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
    ahbram0 : ahbram
      generic map (hindex => 3, haddr => CFG_AHBRADDR, tech => CFG_MEMTECH, kbytes => CFG_AHBRSZ)
      port map (rstn, clkm, ahbsi, ahbso(3));
  end generate;
  nram : if CFG_AHBRAMEN = 0 generate ahbso(3) <= ahbs_none; end generate;

-----------------------------------------------------------------------
---  Drive unused bus elements  ---------------------------------------
-----------------------------------------------------------------------

  nam1 : for i in (CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG+CFG_GRETH+CFG_SVGA_ENABLE+1) to NAHBMST-1 generate
    ahbmo(i) <= ahbm_none;
  end generate;

-----------------------------------------------------------------------
---  Boot message  ----------------------------------------------------
-----------------------------------------------------------------------

-- pragma translate_off
  x : report_version
    generic map (
      msg1 => "LEON3 Demonstration design for Xilinx Spartan3A DSP 1800A board",
      msg2 => "GRLIB Version " & tost(LIBVHDL_VERSION/1000) & "." & tost((LIBVHDL_VERSION mod 1000)/100)
        & "." & tost(LIBVHDL_VERSION mod 100) & ", build " & tost(LIBVHDL_BUILD),
      msg3 => "Target technology: " & tech_table(fabtech) & ",  memory library: " & tech_table(memtech),
      mdel => 1
      );
-- pragma translate_on

end rtl;
