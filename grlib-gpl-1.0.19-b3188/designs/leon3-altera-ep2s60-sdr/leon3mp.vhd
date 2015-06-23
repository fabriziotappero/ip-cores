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
use gaisler.misc.all;
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

    resetn  : in  std_ulogic;
    clk     : in  std_ulogic;
    errorn   : out   std_ulogic;

    -- Shared bus
    address : out   std_logic_vector(23 downto 0);
    data    : inout std_logic_vector(31 downto 0);

    -- SRAM
    ramsn   : out   std_ulogic;
    ramoen  : out   std_ulogic;
    rwen    : out   std_ulogic;
    mben    : out   std_logic_vector(3 downto 0);
-- pragma translate_off
    iosn    : out   std_ulogic;
-- pragma translate_on

    -- FLASH
    romsn   : out   std_ulogic;
    oen     : out   std_ulogic;
    writen  : out   std_ulogic;
    byten   : out   std_ulogic;
    wpn     : out   std_ulogic;

    sa     : out std_logic_vector(11 downto 0);
    sd     : inout std_logic_vector(31 downto 0);
    sdclk  : out std_ulogic;
    sdcke  : out std_logic;                      -- sdram clock enable
    sdcsn  : out std_logic;                      -- sdram chip select
    sdwen  : out std_ulogic;                     -- sdram write enable
    sdrasn : out std_ulogic;                     -- sdram ras
    sdcasn : out std_ulogic;                     -- sdram cas
    sddqm  : out std_logic_vector (3 downto 0);  -- sdram dqm
    sdba   : out std_logic_vector(1 downto 0);   -- sdram bank address

    -- debug support unit
    dsutx               : out std_ulogic;           -- DSU tx data
    dsurx               : in  std_ulogic;           -- DSU rx data
    dsubren             : in  std_ulogic;
    dsuact              : out std_ulogic;

    -- console UART
    rxd1 : in  std_ulogic;
    txd1 : out std_ulogic;

    -- ATA signals
-- pragma translate_off
    ata_rst   : out std_logic; 
-- pragma translate_on
    ata_data  : inout std_logic_vector(15 downto 0);
    ata_da    : out std_logic_vector(2 downto 0);  
    ata_cs0   : out std_logic;
    ata_cs1   : out std_logic;
    ata_dior  : out std_logic;
    ata_diow  : out std_logic;
    ata_iordy : in std_logic;
    ata_intrq : in std_logic;
    ata_dmack : out std_logic;
    
    -- Signals nedded to use CompactFlash with ATA controller
    cf_power   : out std_logic; -- To turn on power to the CompactFlash 
    cf_gnd_da  : out std_logic_vector(10 downto 3); -- grounded address lines
    cf_atasel  : out std_logic; -- grounded to select true IDE mode
    cf_we      : out std_logic; -- should be connected to VCC in true IDE mode
    cf_csel    : out std_logic;
    
    -- for smsc lan chip
    eth_aen   : out std_logic; 
    eth_readn : out std_logic; 
    eth_writen: out std_logic; 
    eth_nbe   : out std_logic_vector(3 downto 0);
    
    eth_lclk     : out std_ulogic;
    eth_nads     : out std_logic;
    eth_ncycle   : out std_logic;
    eth_wnr      : out std_logic;
    eth_nvlbus   : out std_logic;
    eth_nrdyrtn  : out std_logic;
    eth_ndatacs  : out std_logic;

    gpio         : inout std_logic_vector(CFG_GRGPIO_WIDTH-1 downto 0) 	-- I/O port
    );
end;

architecture rtl of leon3mp is
  
  constant blength   : integer := 12;
  constant fifodepth : integer := 8;

  constant maxahbm : integer := NCPU+CFG_AHB_UART+CFG_AHB_JTAG+CFG_ATA;

  signal vcc, gnd   : std_logic_vector(7 downto 0);
  signal memi       : memory_in_type;
  signal memo       : memory_out_type;
  signal wpo        : wprot_out_type;
  signal sdi        : sdctrl_in_type;
  signal sdo        : sdram_out_type;
  signal sdo2, sdo3 : sdctrl_out_type;
  
  --for smc lan chip
  signal s_eth_aen   : std_logic; 
  signal s_eth_readn : std_logic; 
  signal s_eth_writen: std_logic; 
  signal s_eth_nbe   : std_logic_vector(3 downto 0);

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

  signal irqi : irq_in_vector(0 to NCPU-1);
  signal irqo : irq_out_vector(0 to NCPU-1);

  signal dbgi : l3_debug_in_vector(0 to NCPU-1);
  signal dbgo : l3_debug_out_vector(0 to NCPU-1);

  signal dsui : dsu_in_type;
  signal dsuo : dsu_out_type;

  signal cf  : cf_out_type;
  signal atai : ata_in_type;
  signal atao : ata_out_type;

  signal gpti : gptimer_in_type;
  signal gpioi : gpio_in_type;
  signal gpioo : gpio_out_type;

  constant IOAEN : integer := 1;
  constant CFG_SDEN : integer := CFG_MCTRL_SDEN ;
  constant CFG_INVCLK : integer := CFG_MCTRL_INVCLK;
  
  signal dsubre : std_ulogic;

  component smc_mctrl
  generic (
    hindex    : integer := 0;
    pindex    : integer := 0;
    romaddr   : integer := 16#000#;
    rommask   : integer := 16#E00#;
    ioaddr    : integer := 16#200#;
    iomask    : integer := 16#E00#;
    ramaddr   : integer := 16#400#;
    rammask   : integer := 16#C00#;
    paddr     : integer := 0;
    pmask     : integer := 16#fff#;
    wprot     : integer := 0;
    invclk    : integer := 0; 
    fast      : integer := 0; 
    romasel   : integer := 28;
    sdrasel   : integer := 29;
    srbanks   : integer := 4;
    ram8      : integer := 0;
    ram16     : integer := 0;
    sden      : integer := 0;
    sepbus    : integer := 0;
    sdbits    : integer := 32;
    sdlsb     : integer := 2;
    oepol     : integer := 0;
    syncrst   : integer := 0
  );
  port (
    rst       : in  std_ulogic;
    clk       : in  std_ulogic;
    memi      : in  memory_in_type;
    memo      : out memory_out_type;
    ahbsi     : in  ahb_slv_in_type;
    ahbso     : out ahb_slv_out_type;
    apbi      : in  apb_slv_in_type;
    apbo      : out apb_slv_out_type;
    wpo       : in  wprot_out_type;
    sdo       : out sdram_out_type;
    eth_aen   : out std_ulogic; -- for smsc lan chip
    eth_readn : out std_ulogic; -- for smsc lan chip
    eth_writen: out std_ulogic;  -- for smsc lan chip
    eth_nbe   : out std_logic_vector(3 downto 0) -- for smsc lan chip
  );
  end component; 

begin

----------------------------------------------------------------------
---  Reset and Clock generation  -------------------------------------
----------------------------------------------------------------------

  vcc <= (others => '1'); gnd <= (others => '0');
  cgi.pllctrl <= "00"; cgi.pllrst <= not resetn; cgi.pllref <= '0'; 

  clkgen0 : clkgen  -- clock generator using toplevel generic 'freq'
    generic map (tech => CFG_CLKTECH, clk_mul => CFG_CLKMUL,
                 clk_div => CFG_CLKDIV, sdramen => CFG_MCTRL_SDEN,
                 noclkfb => CFG_CLK_NOFB,  freq => freq)
    port map (clkin => clk, pciclkin => gnd(0), clk => clkm, clkn => open,
              clk2x => open, sdclk => sdclkl, pciclk => open,
              cgi => cgi, cgo => cgo);

  sdclk_pad : outpad generic map (tech => padtech, slew => 1, strength => 24) port map (sdclk, sdclkl);
  
  rst0 : rstgen                         -- reset generator
    port map (resetn, clkm, cgo.clklock, rstn);

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
    errorn_pad : odpad generic map (tech => padtech) port map (errorn, dbgo(0).error);

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
      generic map (hindex => NCPU, pindex => 4, paddr => 7)
      port map (rstn, clkm, dui, duo, apbi, apbo(4), ahbmi, ahbmo(NCPU));
    dsurx_pad : inpad generic map (tech  => padtech) port map (dsurx, dui.rxd);
    dsutx_pad : outpad generic map (tech => padtech) port map (dsutx, duo.txd);
  end generate;
  nouah : if CFG_AHB_UART = 0 generate apbo(7) <= apb_none; end generate;

  ahbjtaggen0 : if CFG_AHB_JTAG = 1 generate
    ahbjtag0 : ahbjtag generic map(tech => fabtech, hindex => CFG_NCPU+CFG_AHB_UART)
      port map(rstn, clkm, gnd(0), gnd(0), gnd(0), open, ahbmi, ahbmo(CFG_NCPU+CFG_AHB_UART),
               open, open, open, open, open, open, open, gnd(0));
  end generate;

  
----------------------------------------------------------------------
---  Memory controllers ----------------------------------------------
----------------------------------------------------------------------

  src : if CFG_SRCTRL = 1 generate	-- 32-bit PROM/SRAM controller
    sr0 : srctrl generic map (hindex => 0, ramws => CFG_SRCTRL_RAMWS, 
	romws => CFG_SRCTRL_PROMWS, ramaddr => 16#400#, 
	prom8en => CFG_SRCTRL_8BIT, rmw => CFG_SRCTRL_RMW)
    port map (rstn, clkm, ahbsi, ahbso(0), memi, memo, sdo3);
    apbo(0) <= apb_none;
  end generate;

  mg2 : if CFG_MCTRL_LEON2 = 1 generate 	-- LEON2 memory controller
    sr1 : smc_mctrl generic map (hindex => 0, pindex => 0, paddr => 0, 
	srbanks => 2, sden => CFG_MCTRL_SDEN, ram8 => CFG_MCTRL_RAM8BIT,
	ram16 => CFG_MCTRL_RAM16BIT, invclk => CFG_MCTRL_INVCLK, 
	sepbus => CFG_MCTRL_SEPBUS, sdbits => 32 + 32*CFG_MCTRL_SD64)
    port map (rstn, clkm, memi, memo, ahbsi, ahbso(0), apbi, apbo(0), wpo, sdo,
             s_eth_aen, s_eth_readn, s_eth_writen, s_eth_nbe);
    sdpads : if CFG_MCTRL_SDEN = 1 generate 	-- SDRAM controller
      sd2 : if CFG_MCTRL_SEPBUS = 1 generate
        sa_pad : outpadv generic map (width => 12) port map (sa, memo.sa(11 downto 0));
        sdba_pad : outpadv generic map (width => 2) port map (sdba, memo.sa(14 downto 13));
        bdr : for i in 0 to 3 generate
          sd_pad : iopadv generic map (tech => padtech, width => 8)
          port map (sd(31-i*8 downto 24-i*8), memo.data(31-i*8 downto 24-i*8),
		memo.bdrive(i), memi.sd(31-i*8 downto 24-i*8));
          sd2 : if CFG_MCTRL_SD64 = 1 generate
            sd_pad2 : iopadv generic map (tech => padtech, width => 8)
            port map (sd(31-i*8+32 downto 24-i*8+32), memo.data(31-i*8 downto 24-i*8),
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
      sddqm_pad : outpadv generic map (width =>4, tech => padtech) 
	   port map (sddqm, sdo.dqm(3 downto 0));
    end generate;
    sdcke_pad : outpad generic map (tech => padtech) port map (sdcke, sdo.sdcke(0));
    sdcsn_pad : outpad generic map (tech => padtech) port map (sdcsn, sdo.sdcsn(0));
  end generate;

  wpn <= '1'; byten <= '0';

  nosd0 : if (CFG_MCTRL_LEON2 = 0) generate 	-- no SDRAM controller
     sdcke_pad : outpad generic map (tech => padtech) port map (sdcke, sdo3.sdcke(0));
     sdcsn_pad : outpad generic map (tech => padtech) port map (sdcsn, sdo3.sdcsn(0));
  end generate;

  memi.brdyn  <= '1'; memi.bexcn <= '1';
  memi.writen <= '1'; memi.wrn <= "1111"; memi.bwidth <= "00";

  mg0 : if not ((CFG_SRCTRL = 1) or (CFG_MCTRL_LEON2 = 1)) generate	-- no prom/sram pads
    apbo(0) <= apb_none; ahbso(0) <= ahbs_none;
    rams_pad : outpad generic map (tech => padtech)
      port map (ramsn, vcc(0));
    roms_pad : outpad generic map (tech => padtech)
      port map (romsn, vcc(0));
  end generate;

  mgpads : if (CFG_SRCTRL = 1) or (CFG_MCTRL_LEON2 = 1) generate	-- prom/sram pads
    addr_pad : outpadv generic map (width => 24, tech => padtech)
      port map (address, memo.address(23 downto 0));
    memb_pad : outpadv generic map (width => 4, tech => padtech)
      port map (mben, memo.mben);
    rams_pad : outpad generic map (tech => padtech)
      port map (ramsn, memo.ramsn(0));
    roms_pad : outpad generic map (tech => padtech)
      port map (romsn, memo.romsn(0));
    oen_pad : outpad generic map (tech => padtech)
      port map (oen, memo.oen);
    rwen_pad : outpad generic map (tech => padtech)
      port map (rwen, memo.wrn(0));
    roen_pad : outpad generic map (tech => padtech)
      port map (ramoen, memo.ramoen(0));
    wri_pad : outpad generic map (tech => padtech)
      port map (writen, memo.writen);
-- pragma translate_off
   iosn_pad : outpad generic map (tech => padtech)
      port map (iosn, memo.iosn);
-- pragma translate_on
   
   -- for smc lan chip
   eth_aen_pad : outpad generic map (tech => padtech)  
      port map (eth_aen, s_eth_aen);
   eth_readn_pad : outpad generic map (tech => padtech) 
      port map (eth_readn, s_eth_readn);
   eth_writen_pad : outpad generic map (tech => padtech) 
      port map (eth_writen, s_eth_writen);
   eth_nbe_pad : outpadv generic map (width => 4, tech => padtech) 
      port map (eth_nbe, s_eth_nbe);

    bdr : for i in 0 to 3 generate
      data_pad : iopadv generic map (tech => padtech, width => 8)
        port map (data(31-i*8 downto 24-i*8), memo.data(31-i*8 downto 24-i*8),
                  memo.bdrive(i), memi.data(31-i*8 downto 24-i*8));
    end generate;
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
        pio_pad : iopad generic map (tech => padtech)
            port map (gpio(i), gpioo.dout(i), gpioo.oen(i), gpioi.din(i));
    end generate;
  end generate;

  
-----------------------------------------------------------------------
---  ATA Controller ---------------------------------------------------
-----------------------------------------------------------------------
  atac : if CFG_ATA = 1 generate
     atac0 : atactrl
      generic map(tech => 0, fdepth => CFG_ATAFIFO,
      	mhindex => CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG,
        shindex => 5, haddr => CFG_ATAIO, hmask => 16#fff#, pirq => CFG_ATAIRQ,
        mwdma => CFG_ATADMA, TWIDTH => 8, 
         -- PIO mode 0 settings (@100MHz clock)
         PIO_mode0_T1   => 6,   -- 70ns
         PIO_mode0_T2   => 28,  -- 290ns
         PIO_mode0_T4   => 2,   -- 30ns
         PIO_mode0_Teoc => 23   -- 240ns ==> T0 - T1 - T2 = 600 - 70 - 290 = 240
      )
      port map(rst => rstn, arst  => vcc(0), clk => clkm, ahbsi => ahbsi,
         ahbso => ahbso(5), ahbmi => ahbmi, ahbmo => ahbmo(NCPU+CFG_AHB_UART+CFG_AHB_JTAG),
         cfo => cf, atai => atai, atao => atao);
      
-- pragma translate_off
       ata_rst_pad : outpad generic map (tech => padtech)
         port map (ata_rst, atao.rstn);
-- pragma translate_on
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
--       dmarq_pad : inpad generic map (tech => padtech)
--         port map (ata_dmarq, ata.dmarq);
       dmack_pad : outpad generic map (tech => padtech)
         port map (ata_dmack, atao.dmack);
       
       -- for CompactFlach mode selection
       cf_gnd_da_pad : outpadv generic map (tech => padtech, width => 8)
         port map (cf_gnd_da, cf.da);
       cf_atasel_pad : outpad generic map (tech => padtech)
         port map (cf_atasel, cf.atasel);
       cf_we_pad : outpad generic map (tech => padtech)
         port map (cf_we, cf.we);
       cf_power_pad : outpad generic map (tech => padtech)
         port map (cf_power, cf.power);
       cf_csel_pad : outpad generic map (tech => padtech)
         port map (cf_csel, cf.csel);
    
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
    ahbram0 : ahbram generic map (hindex => 3, haddr => CFG_AHBRADDR,
                                  tech   => CFG_MEMTECH, kbytes => CFG_AHBRSZ)
      port map (rstn, clkm, ahbsi, ahbso(3));
  end generate;
  nram : if CFG_AHBRAMEN = 0 generate ahbso(3) <= ahbs_none; end generate;

-----------------------------------------------------------------------
---  Drive unused bus elements  ---------------------------------------
-----------------------------------------------------------------------

  nam1 : for i in (NCPU+CFG_AHB_UART+CFG_AHB_JTAG+CFG_ATA) to NAHBMST-1 generate
    ahbmo(i) <= ahbm_none;
  end generate;
  nap0 : for i in 6 to NAPBSLV-1 generate apbo(i) <= apb_none; end generate;
  nah0 : for i in 7 to NAHBSLV-1 generate ahbso(i) <= ahbs_none; end generate;

  -- invert signal for input via a key
  dsubre  <= not dsubren;

  -- for smc lan chip
  eth_lclk     <= vcc(0);
  eth_nads     <= gnd(0);
  eth_ncycle   <= vcc(0);
  eth_wnr      <= vcc(0);
  eth_nvlbus   <= vcc(0);
  eth_nrdyrtn  <= vcc(0);
  eth_ndatacs  <= vcc(0);

-----------------------------------------------------------------------
---  Boot message  ----------------------------------------------------
-----------------------------------------------------------------------

-- pragma translate_off
  x : report_version 
  generic map (
   msg1 => "LEON3 Altera EP2C60 SDR Demonstration design",
   msg2 => "GRLIB Version " & tost(LIBVHDL_VERSION/1000) & "." & tost((LIBVHDL_VERSION mod 1000)/100)
      & "." & tost(LIBVHDL_VERSION mod 100) & ", build " & tost(LIBVHDL_BUILD),
   msg3 => "Target technology: " & tech_table(fabtech) & ",  memory library: " & tech_table(memtech),
   mdel => 1
  );
-- pragma translate_on

end;
