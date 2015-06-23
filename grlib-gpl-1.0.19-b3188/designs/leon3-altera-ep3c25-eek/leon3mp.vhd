------------------------------------------------------------------------------
--  LEON3 Demonstration design
--  Copyright (C) 2008 Jiri Gaisler, Gaisler Research
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
use gaisler.misc.all;
use gaisler.net.all;
use gaisler.ata.all;
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
    freq    : integer := 50000         -- frequency of main clock (used for PLLs)
    );
  port (
    resetn          : in  std_ulogic;
    clk             : in  std_ulogic;
    errorn          : out std_ulogic;

    -- flash/ssram bus
    address         : out   std_logic_vector(25 downto 1);
    data            : inout std_logic_vector(31 downto 0);
    romsn           : out std_ulogic;
    oen             : out std_logic;
    writen          : out std_logic;
    rstoutn         : out std_ulogic;
    ssram_cen  	    : out std_logic;
    ssram_wen 	    : out std_logic;
    ssram_bw   	    : out std_logic_vector (0 to 3);
    ssram_oen       : out std_ulogic;
    ssram_clk  	    : out std_ulogic;
    ssram_adscn     : out std_ulogic;
--    ssram_adsp_n : out std_ulogic;
--    ssram_adv_n : out std_ulogic;

-- pragma translate_off
    iosn            : out   std_ulogic;
-- pragma translate_on

    -- DDR 
    ddr_clk  	    : out std_logic;
    ddr_clkn  	    : out std_logic;
    ddr_cke  	    : out std_logic;
    ddr_csb  	    : out std_logic;
    ddr_web  	    : out std_ulogic;                       -- ddr write enable
    ddr_rasb  	    : out std_ulogic;                       -- ddr ras
    ddr_casb  	    : out std_ulogic;                       -- ddr cas
    ddr_dm   	    : out std_logic_vector (1 downto 0);    -- ddr dm
    ddr_dqs         : inout std_logic_vector (1 downto 0);  -- ddr dqs
    ddr_ad          : out std_logic_vector (12 downto 0);   -- ddr address
    ddr_ba          : out std_logic_vector (1 downto 0);    -- ddr bank address
    ddr_dq  	    : inout std_logic_vector (15 downto 0); -- ddr data

    -- debug support unit
    dsubren         : in  std_ulogic;
    dsuact          : out std_ulogic;
    
    -- I/O port
    gpio            : in std_logic_vector(CFG_GRGPIO_WIDTH-3 downto 0);

    -- Connections over HSMC connector
    -- LCD touch panel display
    hc_vd           : out std_logic;
    hc_hd           : out std_logic;
    hc_den          : out std_logic;
    hc_nclk         : out std_logic;
    hc_lcd_data     : out std_logic_vector(7 downto 0); 
    hc_grest        : out std_logic;
    hc_scen         : out std_logic; 
    hc_sda          : inout std_logic;
    hc_adc_penirq_n : in  std_logic;
    hc_adc_dout     : in  std_logic;
    hc_adc_busy     : in  std_logic;
    hc_adc_din      : out std_logic;
    hc_adc_dclk     : out std_logic;
    hc_adc_cs_n     : out std_logic;    -- Shared with video decoder

    -- Shared by video decoder and audio codec
    hc_i2c_sclk     : out std_logic;
    hc_i2c_sdat     : inout std_logic;

    -- Video decoder
    hc_td_d         : inout std_logic_vector(7 downto 0);
    hc_td_hs        : in  std_logic;
    hc_td_vs        : in  std_logic;
    hc_td_27mhz     : in  std_logic;
    hc_td_reset     : out std_logic;

    -- Audio codec
    hc_aud_adclrck  : out std_logic;
    hc_aud_adcdat   : in std_logic;
    hc_aud_daclrck  : out std_logic;
    hc_aud_dacdat   : out std_logic;
    hc_aud_bclk     : out std_logic;
    hc_aud_xck      : out std_logic;
    
    -- SD card
    hc_sd_dat       : inout std_logic;
    hc_sd_dat3      : inout std_logic;
    hc_sd_cmd       : inout std_logic;
    hc_sd_clk       : inout std_logic;

    -- Ethernet PHY
    hc_tx_d         : out std_logic_vector(3 downto 0);
    hc_rx_d         : in  std_logic_vector(3 downto 0);
    hc_tx_clk       : in  std_logic;
    hc_rx_clk       : in  std_logic;
    hc_tx_en        : out std_logic;
    hc_rx_dv        : in  std_logic;
    hc_rx_crs       : in  std_logic;
    hc_rx_err       : in  std_logic;
    hc_rx_col       : in  std_logic;
    hc_mdio         : inout std_logic;
    hc_mdc          : out std_logic;
    hc_eth_reset_n  : out std_logic;
    
    -- RX232 (console/debug UART)
    hc_uart_rxd     : in  std_logic;       
    hc_uart_txd     : out std_logic;       

    -- PS/2
    hc_ps2_dat      : inout std_logic;
    hc_ps2_clk      : inout std_logic;

    -- VGA/DAC
    hc_vga_data     : out std_logic_vector(9 downto 0);
    hc_vga_clock    : out std_ulogic;
    hc_vga_hs       : out std_ulogic;
    hc_vga_vs       : out std_ulogic;
    hc_vga_blank    : out std_ulogic;
    hc_vga_sync     : out std_ulogic;
    
    -- I2C EEPROM
    hc_id_i2cscl    : out std_logic;
    hc_id_i2cdat    : inout std_logic
    );
end;

architecture rtl of leon3mp is

  component serializer
    generic (
      length : integer := 8             -- vector length
      );
    port (
      clk   : in  std_ulogic;
      sync  : in  std_ulogic;
      ivec0 : in  std_logic_vector((length-1) downto 0);
      ivec1 : in  std_logic_vector((length-1) downto 0);
      ivec2 : in  std_logic_vector((length-1) downto 0);
      ovec  : out std_logic_vector((length-1) downto 0)
      );
  end component;
  
  component altera_eek_clkgen
    generic (
      clk0_mul  : integer := 1; 
      clk0_div  : integer := 1;
      clk1_mul  : integer := 1;
      clk1_div  : integer := 1;
      clk_freq : integer := 25000);
    port (
      inclk0 : in  std_ulogic;
      clk0   : out std_ulogic;
      clk0x3 : out std_ulogic;
      clksel : in  std_logic_vector(1 downto 0);
      locked : out std_ulogic);
  end component;
    
  constant blength   : integer := 12;
  constant fifodepth : integer := 8;

  constant maxahbm : integer := NCPU+CFG_AHB_UART+CFG_AHB_JTAG+CFG_LCD_ENABLE+
                                CFG_SVGA_ENABLE+CFG_GRETH;
  
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
  
  signal apbi  : apb_slv_in_type;
  signal apbo  : apb_slv_out_vector := (others => apb_none);
  signal ahbsi : ahb_slv_in_type;
  signal ahbso : ahb_slv_out_vector := (others => ahbs_none);
  signal ahbmi : ahb_mst_in_type;
  signal ahbmo : ahb_mst_out_vector := (others => ahbm_none);

  signal clkm, rstn, rawrstn, ssram_clkl : std_ulogic;
  signal cgi                : clkgen_in_type;
  signal cgo                : clkgen_out_type;
  signal u1i, dui           : uart_in_type;
  signal u1o, duo           : uart_out_type;
  
  signal irqi : irq_in_vector(0 to NCPU-1);
  signal irqo : irq_out_vector(0 to NCPU-1);

  signal dbgi : l3_debug_in_vector(0 to NCPU-1);
  signal dbgo : l3_debug_out_vector(0 to NCPU-1);

  signal dsui : dsu_in_type;
  signal dsuo : dsu_out_type;

  signal gpti : gptimer_in_type;
  signal gpioi : gpio_in_type;
  signal gpioo : gpio_out_type;

  signal ps2i  : ps2_in_type;
  signal ps2o  : ps2_out_type;

  signal i2ci : i2c_in_type;
  signal i2co : i2c_out_type;
  
  signal spii : spi_in_type;
  signal spio : spi_out_type;
  signal slvsel : std_logic_vector(CFG_SPICTRL_SLVS-1 downto 0);

  signal spmi : spimctrl_in_type;
  signal spmo : spimctrl_out_type;

  signal ethi : eth_in_type;
  signal etho : eth_out_type;
  
  signal lcdo       : apbvga_out_type;
  signal lcd_data   : std_logic_vector(7 downto 0);
  signal lcd_den    : std_ulogic;
  signal lcd_grest  : std_ulogic;
  signal lcdspii    : spi_in_type;
  signal lcdspio    : spi_out_type;
  signal lcdslvsel  : std_logic_vector(1 downto 0);
  signal lcdclksel  : std_logic_vector(1 downto 0);
  signal lcdclk     : std_ulogic;
  signal lcdclk3x   : std_ulogic;
  signal lcdclklck  : std_ulogic;
  
  signal vgao       : apbvga_out_type;
  signal vga_data   : std_logic_vector(9 downto 0);
  signal vgaclksel  : std_logic_vector(1 downto 0);
  signal vgaclk     : std_ulogic;
  signal vgaclk3x   : std_ulogic;
  signal vgaclklck  : std_ulogic;

  constant IOAEN : integer := 1;
  constant BOARD_FREQ : integer := 50000;   -- input frequency in KHz
  constant CPU_FREQ : integer := BOARD_FREQ * CFG_CLKMUL / CFG_CLKDIV;  -- cpu frequency in KHz

  signal lclk, lclkout  : std_ulogic;
  
  signal dsubre : std_ulogic;

  attribute syn_keep : boolean;
  attribute syn_keep of clkm : signal is true;
  attribute syn_keep of clkml : signal is true;
  attribute syn_keep of lcdclk : signal is true;
  attribute syn_keep of lcdclk3x : signal is true;
  attribute syn_keep of vgaclk : signal is true;
  attribute syn_keep of vgaclk3x : signal is true;
  
begin

----------------------------------------------------------------------
---  Reset and Clock generation  -------------------------------------
----------------------------------------------------------------------

  vcc <= (others => '1'); gnd <= (others => '0');
  cgi.pllctrl <= "00"; cgi.pllrst <= not resetn; cgi.pllref <= '0'; 

  clklock <=  cgo.clklock and lock and lcdclklck and vgaclklck;
  clk_pad : clkpad generic map (tech => padtech) port map (clk, lclk);

  clkgen0 : clkgen  -- clock generator using toplevel generic 'freq'
    generic map (tech => CFG_CLKTECH, clk_mul => CFG_CLKMUL,
                 clk_div => CFG_CLKDIV, sdramen => 1,
                 freq => freq)
    port map (clkin => lclk, pciclkin => gnd(0), clk => clkm, clkn => open,
              clk2x => open, sdclk => ssram_clkl, pciclk => open,
              cgi => cgi, cgo => cgo);

  ssrclk_pad : outpad generic map (tech => padtech, slew => 1, strength => 24) 
	port map (ssram_clk, ssram_clkl);
  
  rst0 : rstgen                         -- reset generator
    port map (resetn, clkm, clklock, rstn, rawrstn);

  rstoutn <= resetn;

---------------------------------------------------------------------- 
---  AVOID BUS CONTENTION --------------------------------------------
----------------------------------------------------------------------
  -- This design uses the ethernet PHY and we must therefore disable the
  -- video decoder and stay away from the touch panel.
  -- Video coder
  hc_td_reset <= '0';                   -- Video Decoder Reset
  
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

  dcomgen : if CFG_AHB_UART = 1 generate
    dcom0 : ahbuart                     -- Debug UART
      generic map (hindex => NCPU, pindex => 7, paddr => 7)
      port map (rstn, clkm, dui, duo, apbi, apbo(7), ahbmi, ahbmo(NCPU));
    dsurx_pad : inpad generic map (tech  => padtech) port map (hc_uart_rxd, dui.rxd);
    dsutx_pad : outpad generic map (tech => padtech) port map (hc_uart_txd, duo.txd);
  end generate;
  nouah : if CFG_AHB_UART = 0 generate apbo(7) <= apb_none; end generate;

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
	ramaddr => 16#400#+16#600#*CFG_DDRSP, rammask =>16#F00#, srbanks => 1, 
	sden => 0, ram16 => 1)
    port map (rstn, clkm, memi, memo, ahbsi, ahbso(0), apbi, apbo(0), wpo);
  end generate;

  memi.brdyn  <= '1'; memi.bexcn <= '1';
  memi.writen <= '1'; memi.wrn <= "1111"; memi.bwidth <= "01";

  ssr0 : if CFG_SSCTRL = 1 generate
    ssrctrl0 : ssrctrl generic map (hindex => 0, pindex => 0, 
	iomask => 0, ramaddr => 16#400#+16#600#*CFG_DDRSP,
	bus16 => CFG_SSCTRLP16)
    port map (rstn, clkm, ahbsi, ahbso(0), apbi, apbo(0), memi, memo);
  end generate;

  mg0 : if (CFG_MCTRL_LEON2 + CFG_SSCTRL) = 0 generate	-- no prom/sram pads
    apbo(0) <= apb_none; ahbso(0) <= ahbs_none;
    roms_pad : outpad generic map (tech => padtech) port map (romsn, vcc(0));
  end generate;

  mgpads : if (CFG_MCTRL_LEON2 + CFG_SSCTRL) /= 0 generate	-- prom/sram pads
    addr_pad : outpadv generic map (width => 25, tech => padtech)
      port map (address, memo.address(25 downto 1));
    roms_pad : outpad generic map (tech => padtech)
      port map (romsn, memo.romsn(0));
    oen_pad : outpad generic map (tech => padtech)
      port map (oen, memo.oen);
    wri_pad : outpad generic map (tech => padtech)
      port map (writen, memo.writen);
-- pragma translate_off
    iosn_pad : outpad generic map (tech => padtech)
      port map (iosn, memo.iosn);
-- pragma translate_on
   
--    ssram_adv_n_pad : outpad generic map (tech => padtech) 
--	port map (ssram_adv_n, vcc(0)); 
--    ssram_adsp_n_pad : outpad generic map (tech => padtech) 
--	port map (ssram_adsp_n, gnd(0)); 
    ssram_adscn_pad : outpad generic map (tech => padtech) 
	port map (ssram_adscn, gnd(0)); 
    ssrams_pad : outpad generic map ( tech => padtech) 
	port map (ssram_cen, memo.ramsn(0)); 
    ssram_oen_pad  : outpad generic map (tech => padtech) 
	port map (ssram_oen, memo.oen);
    ssram_rwen_pad : outpadv generic map (width => 4, tech => padtech) 
	port map (ssram_bw, memo.wrn); 
    ssram_wri_pad  : outpad generic map (tech => padtech) 
	port map (ssram_wen, memo.writen);
    data_pad : iopadvv generic map (tech => padtech, width => 32)
        port map (data(31 downto 0), memo.data(31 downto 0),
                  memo.vbdrive, memi.data(31 downto 0));
  end generate;

  ddrsp0 : if (CFG_DDRSP /= 0) generate 
    ddrc0 : ddrspa generic map ( fabtech => fabtech, memtech => memtech, 
	hindex => 3, haddr => 16#400#, hmask => 16#F00#, ioaddr => 1, 
	pwron => CFG_DDRSP_INIT, MHz => BOARD_FREQ/1000, rskew => CFG_DDRSP_RSKEW,
	clkmul => CFG_DDRSP_FREQ/5, clkdiv => 10, ahbfreq => CPU_FREQ/1000,
	col => CFG_DDRSP_COL, Mbyte => CFG_DDRSP_SIZE, ddrbits => 16, regoutput => 1)
     port map (
	resetn, rstn, lclk, clkm, lock, clkml, clkml, ahbsi, ahbso(3),
	ddr_clkv, ddr_clkbv, open, gnd(0),
	ddr_ckev, ddr_csbv, ddr_web, ddr_rasb, ddr_casb, 
	ddr_dm, ddr_dqs, ddr_adl, ddr_ba, ddr_dq);
        ddr_ad <= ddr_adl(12 downto 0);
        ddr_clk <= ddr_clkv(0); ddr_clkn <= ddr_clkbv(0);
        ddr_cke <= ddr_ckev(0); ddr_csb <= ddr_csbv(0);
  end generate;

  ddrsp1 : if (CFG_DDRSP = 0) generate 
    ddr_cke <= '0'; ddr_csb <= '1'; lock <= '1';
  end generate;

  spimc: if CFG_SPIMCTRL = 1 generate -- SPI Memory Controller
    spimctrl0 : spimctrl
      generic map (hindex => 4,
                   hirq => 9,
                   faddr => 16#b00#,
                   fmask  => 16#f00#,
                   ioaddr => 16#002#,
                   iomask => 16#fff#,
                   spliten => CFG_SPLIT,
                   oepol   => 0,
                   sdcard => CFG_SPIMCTRL_SDCARD,
                   readcmd => CFG_SPIMCTRL_READCMD,
                   dummybyte => CFG_SPIMCTRL_DUMMYBYTE,
                   dualoutput => CFG_SPIMCTRL_DUALOUTPUT,
                   scaler => CFG_SPIMCTRL_SCALER,
                   altscaler => CFG_SPIMCTRL_ASCALER,
                   pwrupcnt => CFG_SPIMCTRL_PWRUPCNT)
      port map (rstn, clkm, ahbsi, ahbso(4), spmi, spmo);

    miso_pad : inpad generic map (tech => padtech)
      port map (hc_sd_dat, spmi.miso);
    mosi_pad : outpad generic map (tech => padtech)
      port map (hc_sd_cmd, spmo.mosi);
    sck_pad  : outpad generic map (tech => padtech)
      port map (hc_sd_clk, spmo.sck);
    slvsel0_pad : iopad generic map (tech => padtech)
      port map (hc_sd_dat3, spmo.csn, spmo.cdcsnoen, spmi.cd);  
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
    upads : if CFG_AHB_UART = 0 generate
      u1i.rxd <= hc_uart_rxd; hc_uart_txd <= u1o.txd;
    end generate;
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
    timer0 : gptimer                    -- Timer unit
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
    pio_pads : for i in 0 to CFG_GRGPIO_WIDTH-3 generate
	gpioi.din(i) <= gpio(i);
    end generate;
    gpioi.din(3) <= hc_adc_penirq_n;
    gpioi.din(4) <= hc_adc_busy;
  end generate;

  ps2 : if CFG_PS2_ENABLE /= 0 generate  -- PS/2 unit
    ps20 : apbps2 generic map(pindex => 6, paddr => 6, pirq => 6)
    port map(rstn, clkm, apbi, apbo(6), ps2i, ps2o);
  end generate;
  nops2 : if CFG_PS2_ENABLE = 0 generate 
    apbo(4) <= apb_none; ps2o <= ps2o_none;
  end generate;
  ps2clk_pad : iopad generic map (tech => padtech)
      port map (hc_ps2_clk, ps2o.ps2_clk_o, ps2o.ps2_clk_oe, ps2i.ps2_clk_i);
  ps2data_pad : iopad generic map (tech => padtech)
        port map (hc_ps2_dat, ps2o.ps2_data_o, ps2o.ps2_data_oe, ps2i.ps2_data_i);

  i2cm: if CFG_I2C_ENABLE = 1 generate  -- I2C master
    i2c0 : i2cmst
      generic map (pindex => 8, paddr => 8, pmask => 16#FFF#, pirq => 11)
      port map (rstn, clkm, apbi, apbo(8), i2ci, i2co);
    -- The EEK does not use a bi-directional line for the I2C clock
    i2ci.scl <= i2co.scloen;            -- No clock stretch possible
    -- When SCL output enable is activated the line should go low
    i2c_scl_pad : outpad generic map (tech => padtech)
      port map (hc_id_i2cscl, i2co.scloen);
    i2c_sda_pad : iopad generic map (tech => padtech)
      port map (hc_id_i2cdat, i2co.sda, i2co.sdaoen, i2ci.sda);
  end generate i2cm;

  spic: if CFG_SPICTRL_ENABLE = 1 generate  -- SPI controller
    spi1 : spictrl
    generic map (pindex => 9, paddr  => 9, pmask  => 16#fff#, pirq => 9,
                 fdepth => CFG_SPICTRL_FIFO, slvselen => CFG_SPICTRL_SLVREG,
                 slvselsz => CFG_SPICTRL_SLVS)
    port map (rstn, clkm, apbi, apbo(9), spii, spio, slvsel);
   miso_pad : iopad generic map (tech => padtech)
     port map (hc_sd_dat, spio.miso, spio.misooen, spii.miso);
   mosi_pad : iopad generic map (tech => padtech)
     port map (hc_sd_cmd, spio.mosi, spio.mosioen, spii.mosi);
   sck_pad  : iopad generic map (tech => padtech)
     port map (hc_sd_clk, spio.sck, spio.sckoen, spii.sck);
   slvsel_pad : outpad generic map (tech => padtech)
     port map (hc_sd_dat3, slvsel(0));
    spii.spisel <= '1';                 -- Master only
  end generate spic;

-----------------------------------------------------------------------
-- LCD touch panel  ---------------------------------------------------
----------------------------------------------------------------------- 

  lcd: if CFG_LCD_ENABLE /= 0 generate  -- LCD
    lcd0 : svgactrl generic map(memtech => memtech, pindex => 11, paddr => 11,
        hindex => CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG,
	clk0 => 30120, clk1 => 0, clk2 => 0, clk3 => 0, burstlen => 4)
      port map(rstn, clkm, lcdclk, apbi, apbo(11), lcdo, ahbmi, 
               ahbmo(CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG), open);
    
    lcdser0: serializer generic map (length => 8)
      port map (lcdclk3x, lcdo.hsync, lcdo.video_out_b, lcdo.video_out_g,
                lcdo.video_out_r, lcd_data);

    lcdclksel <= "00";
    
    lcdclkgen : altera_eek_clkgen
      generic map (clk0_mul => 166, clk0_div => 250, clk1_mul  => 9,
                   clk1_div  => 50, clk_freq => BOARD_FREQ)
      port map (lclk, lcdclk, lcdclk3x, lcdclksel, lcdclklck);
    
    lcd_vert_sync_pad : outpad generic map (tech => padtech)
      port map (hc_vd, lcdo.vsync);
    lcd_horiz_sync_pad : outpad generic map (tech => padtech)
      port map (hc_hd, lcdo.hsync);
    lcd_video_out_pad : outpadv generic map (width => 8, tech => padtech)
      port map (hc_lcd_data, lcd_data);
    lcd_video_clock_pad : outpad generic map (tech => padtech)
      port map (hc_nclk, lcdclk3x);
    lcd_den <= lcdo.blank;
  end generate;

  nolcd : if CFG_LCD_ENABLE = 0 generate
    apbo(11) <= apb_none; lcdo <= vgao_none;
    lcd_den <= '0';              -- LCD RGB Data Enable
    lcdclk <= '0'; lcdclk3x <= '0'; lcdclklck <= '1';
  end generate;

  lcd_den_pad : outpad generic map (tech => padtech)
        port map (hc_den, lcd_den);

  lcdsysreset: if CFG_LCD_ENABLE /= 0 or CFG_LCD3T_ENABLE /= 0 generate
    lcd_grest <= rstn;
  end generate;

  lcdalwaysreset: if CFG_LCD_ENABLE = 0 and CFG_LCD3T_ENABLE = 0 generate
    lcd_grest <= '0';            
  end generate lcdalwaysreset;

  lcd_reset_pad : outpad  generic map (tech => padtech) -- LCD Global Reset, active low
       port map (hc_grest, lcd_grest);

  touch3wire: if CFG_LCD3T_ENABLE /= 0 generate  -- LCD 3-wire and touch panel interface
    -- TODO:
    -- Interrupt and busy signals not connected
    touch3spi1 : spictrl
      generic map (pindex => 12, paddr  => 12, pmask  => 16#fff#, pirq => 12,
                   fdepth => 2, slvselen => 1, slvselsz => 2)
      port map (rstn, clkm, apbi, apbo(12), lcdspii, lcdspio, lcdslvsel);
    adc_miso_pad : inpad generic map (tech => padtech)
      port map (hc_adc_dout, lcdspii.miso);
    adc_mosi_pad : outpad generic map (tech => padtech)
      port map (hc_adc_din, lcdspio.mosi);
    lcd_adc_dclk_pad : outpad generic map (tech => padtech)
       port map (hc_adc_dclk, lcdspio.sck);
    hcd_sda_pad : iopad generic map (tech => padtech)
       port map (hc_sda, lcdspio.mosi, lcdspio.mosioen, lcdspii.mosi);
    
    lcdspii.spisel <= '1';                 -- Master only
  end generate;

  notouch3wire: if CFG_LCD3T_ENABLE = 0 generate
    lcdslvsel <= (others => '1');
    apbo(12) <= apb_none;
  end generate;

  hc_adc_cs_n_pad : outpad generic map (tech => padtech)
        port map (hc_adc_cs_n, lcdslvsel(0));  
  hc_scen_pad : outpad generic map (tech => padtech)
    port map (hc_scen, lcdslvsel(1));

-----------------------------------------------------------------------
-- SVGA controller ----------------------------------------------------
-----------------------------------------------------------------------  
  
  svga : if CFG_SVGA_ENABLE /= 0 generate  -- VGA DAC
    svga0 : svgactrl generic map(memtech => memtech, pindex => 13, paddr => 13,
        hindex => CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG+CFG_LCD_ENABLE, 
	clk0 => 40000, clk1 => 25000, clk2 => 0, clk3 => 0, burstlen => 4)
       port map(rstn, clkm, vgaclk, apbi, apbo(13), vgao, ahbmi, 
		ahbmo(CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG+CFG_LCD_ENABLE),
                vgaclksel);

    svgaser0: serializer generic map (length => 8)
      port map (vgaclk3x, vgao.hsync, vgao.video_out_b, vgao.video_out_g,
                vgao.video_out_r, vga_data(9 downto 2));
    vga_data(1 downto 0) <= (others => '0');
    
    vgaclkgen : altera_eek_clkgen
      generic map (clk0_mul => 1, clk0_div => 2, clk1_mul  => 4,
                   clk1_div  => 5, clk_freq => BOARD_FREQ)
      port map (lclk, vgaclk, vgaclk3x, vgaclksel, vgaclklck);
    
    vga_blank_pad : outpad generic map (tech => padtech)
      port map (hc_vga_blank, vgao.blank);
    vga_comp_sync_pad : outpad generic map (tech => padtech)
      port map (hc_vga_sync, vgao.comp_sync);
    vga_vert_sync_pad : outpad generic map (tech => padtech)
      port map (hc_vga_vs, vgao.vsync);
    vga_horiz_sync_pad : outpad generic map (tech => padtech)
      port map (hc_vga_hs, vgao.hsync);
    vga_video_out_pad : outpadv generic map (width => 10, tech => padtech)
      port map (hc_vga_data, vga_data);
    vga_video_clock_pad : outpad generic map (tech => padtech)
      port map (hc_vga_clock, vgaclk3x);
  end generate svga;
  
  nosvga : if CFG_SVGA_ENABLE = 0 generate
    apbo(13) <= apb_none; vgao <= vgao_none;
    vgaclk <= '0'; vgaclk3x <= '0'; vgaclklck <= '1';
  end generate;
  
-----------------------------------------------------------------------
---  ETHERNET ---------------------------------------------------------
-----------------------------------------------------------------------

  eth0 : if CFG_GRETH /= 0 generate -- Gaisler ethernet MAC
    e1 : grethm generic map(
      hindex => CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG+CFG_LCD_ENABLE+CFG_SVGA_ENABLE,
      pindex => 10, paddr => 10, pirq => 10, memtech => memtech,
      mdcscaler => CPU_FREQ/1000, enable_mdio => 1, fifosize => CFG_ETH_FIFO,
      nsync => 1, edcl => CFG_DSU_ETH, edclbufsz => CFG_ETH_BUF,
      macaddrh => CFG_ETH_ENM, macaddrl => CFG_ETH_ENL, phyrstadr => 1,
      ipaddrh => CFG_ETH_IPM, ipaddrl => CFG_ETH_IPL, giga => CFG_GRETH1G)
      port map( rst => rstn, clk => clkm, ahbmi => ahbmi,
                ahbmo => ahbmo(CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG+CFG_LCD_ENABLE+CFG_SVGA_ENABLE),
                apbi => apbi, apbo => apbo(10), ethi => ethi, etho => etho); 

    emdio_pad : iopad generic map (tech => padtech) 
      port map (hc_mdio, etho.mdio_o, etho.mdio_oe, ethi.mdio_i);
    etxc_pad : clkpad generic map (tech => padtech, arch => 2) 
      port map (hc_tx_clk, ethi.tx_clk);
    erxc_pad : clkpad generic map (tech => padtech, arch => 2) 
      port map (hc_rx_clk, ethi.rx_clk);
    erxd_pad : inpadv generic map (tech => padtech, width => 4) 
      port map (hc_rx_d, ethi.rxd(3 downto 0));
    erxdv_pad : inpad generic map (tech => padtech) 
      port map (hc_rx_dv, ethi.rx_dv);
    erxer_pad : inpad generic map (tech => padtech) 
      port map (hc_rx_err, ethi.rx_er);
    erxco_pad : inpad generic map (tech => padtech) 
      port map (hc_rx_col, ethi.rx_col);
    erxcr_pad : inpad generic map (tech => padtech) 
      port map (hc_rx_crs, ethi.rx_crs);
    
    etxd_pad : outpadv generic map (tech => padtech, width => 4) 
      port map (hc_tx_d, etho.txd(3 downto 0));
    etxen_pad : outpad generic map (tech => padtech) 
      port map (hc_tx_en, etho.tx_en);
    emdc_pad : outpad generic map (tech => padtech) 
      port map (hc_mdc, etho.mdc);
    erst_pad : outpad generic map (tech => padtech) 
      port map (hc_eth_reset_n, rawrstn);
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

  nam1 : for i in (CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG+CFG_LCD_ENABLE+CFG_SVGA_ENABLE+CFG_GRETH) to NAHBMST-1 generate
    ahbmo(i) <= ahbm_none;
  end generate;

  -- invert signal for input via a key
  dsubre  <= not dsubren;

-----------------------------------------------------------------------
---  Boot message  ----------------------------------------------------
-----------------------------------------------------------------------

-- pragma translate_off
  x : report_version 
  generic map (
   msg1 => "LEON3 Altera Embedded Evaluation Kit Demonstration Design",
   msg2 => "GRLIB Version " & tost(LIBVHDL_VERSION/1000) & "." & tost((LIBVHDL_VERSION mod 1000)/100)
      & "." & tost(LIBVHDL_VERSION mod 100) & ", build " & tost(LIBVHDL_BUILD),
   msg3 => "Target technology: " & tech_table(fabtech) & ",  memory library: " & tech_table(memtech),
   mdel => 1
  );
-- pragma translate_on

end;
