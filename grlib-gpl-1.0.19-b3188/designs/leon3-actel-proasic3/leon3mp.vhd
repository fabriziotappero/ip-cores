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
use gaisler.net.all;
use gaisler.can.all;
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
    resetn	: in  std_ulogic;
    clk		: in  std_ulogic;
    errorn	: out std_ulogic;
    address 	: out std_logic_vector(18 downto 0);
    data	: inout std_logic_vector(31 downto 0);
    dsutx  	: out std_ulogic; 			-- DSU tx data
    dsurx  	: in  std_ulogic;  			-- DSU rx data
--    dsuen   	: in std_ulogic;
    dsubre  	: in std_ulogic;
    dsuact  	: out std_ulogic;
    txd1   	: out std_ulogic; 			-- UART1 tx data
    rxd1   	: in  std_ulogic;  			-- UART1 rx data
    ramsn  	: out std_logic;
    ramoen 	: out std_logic;
    ramben 	: out std_logic_vector (3 downto 0);
    rwen   	: out std_logic;
    oen    	: out std_ulogic;
    writen 	: out std_ulogic;
--    read   	: out std_ulogic;
    romsn  	: out std_logic;
    iosn  	: out std_logic;
    ramclk 	: out std_logic;
    gpio        : inout std_logic_vector(6 downto 0); 	-- I/O port

    flash_byten : out std_logic;
    flash_rpn   : out std_logic;
    sram_pwrdwn : out std_logic;
    sram_gwen   : out std_logic;
    sram_adsc   : out std_logic;
    sram_adsp   : out std_logic;
    sram_adv    : out std_logic;

    can_txd	: out std_logic;
    can_rxd	: in  std_logic;

    emdio     	: inout std_logic;		-- ethernet PHY interface
    etx_clk 	: in std_ulogic;
    erx_clk 	: in std_ulogic;
    erxd    	: in std_logic_vector(3 downto 0);   
    erx_dv  	: in std_ulogic; 
    erx_er  	: in std_ulogic; 
    erx_col 	: in std_ulogic;
    erx_crs 	: in std_ulogic;
    etxd 	: out std_logic_vector(3 downto 0);   
    etx_en 	: out std_ulogic; 
    etx_er 	: out std_ulogic; 
    emdc 	: out std_ulogic;
    led         : out std_logic_vector(5 downto 0);
    tck         : in  std_ulogic := '0';
    tms         : in  std_ulogic := '0';
    tdi         : in  std_ulogic := '0'; 
    trst        : in  std_ulogic := '0';
    tdo         : out std_ulogic
	);
end;

architecture rtl of leon3mp is

constant blength : integer := 12;
constant fifodepth : integer := 8;

constant maxahbmsp : integer := CFG_NCPU+CFG_AHB_UART+
	CFG_GRETH+CFG_AHB_JTAG;
constant maxahbm : integer := maxahbmsp;

signal vcc, gnd : std_logic_vector(4 downto 0);
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
signal gpto : gptimer_out_type;

signal gpioi : gpio_in_type;
signal gpioo : gpio_out_type;
signal can_lrx, can_ltx   : std_ulogic;

signal lclk, letx_clk : std_ulogic;

--signal tck, tms, tdi, tdo : std_ulogic;
signal resetnl, clk2x, spw_clkl   : std_ulogic;

constant IOAEN : integer := CFG_CAN;

constant sysfreq : integer := (CFG_CLKMUL/CFG_CLKDIV)*48000;
constant boardfreq : integer := 48000;
begin

  flash_byten <= '1';
  flash_rpn <= rstn;
  sram_pwrdwn <= '0';
  sram_gwen  <= '1';
  sram_adsc <= '0';
  sram_adsp <= '1';

----------------------------------------------------------------------
---  Reset and Clock generation  -------------------------------------
----------------------------------------------------------------------
  
  vcc <= (others => '1'); gnd <= (others => '0');
  cgi.pllctrl <= "00"; cgi.pllrst <= rstraw;

  ramclk <= clkm;
  clk_pad : inpad generic map (tech => 0) port map (clk, lclk); 

  clkgen0 : clkgen  		-- clock generator
    generic map (clktech, CFG_CLKMUL, CFG_CLKDIV, CFG_MCTRL_SDEN, 
	CFG_CLK_NOFB, 0, 0, 0, boardfreq, 0, 0, CFG_OCLKDIV)
    port map (lclk, lclk, clkm, open, clk2x, sdclkl, pciclk, cgi, cgo);

  resetn_pad : inpad generic map (tech => padtech) port map (resetn, resetnl);
  rst0 : rstgen			-- reset generator
  port map (resetnl, clkm, cgo.clklock, rstn, rstraw);
  led(5) <= cgo.clklock;

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
          CFG_LDDEL, disas, CFG_ITBSZ, CFG_PWD, CFG_SVT, CFG_RSTADDR, CFG_NCPU-1)
      port map (clkm, rstn, ahbmi, ahbmo(i), ahbsi, ahbso, 
      		irqi(i), irqo(i), dbgi(i), dbgo(i));
    end generate;
    errorn_pad : outpad generic map (tech => padtech) port map (errorn, dbgo(0).error);
    
    dsugen : if CFG_DSU = 1 generate
      dsu0 : dsu3			-- LEON3 Debug Support Unit
      generic map (hindex => 2, haddr => 16#900#, hmask => 16#F00#, 
         ncpu => CFG_NCPU, tbits => 30, tech => memtech, irq => 0, kbytes => CFG_ATBSZ)
      port map (rstn, clkm, ahbmi, ahbsi, ahbso(2), dbgo, dbgi, dsui, dsuo);
--      dsuen_pad : inpad generic map (tech => padtech) port map (dsuen, dsui.enable); 
	dsui.enable <= '1';
      dsubre_pad : inpad generic map (tech => padtech) port map (dsubre, dsui.break); 
      dsuact_pad : outpad generic map (tech => padtech) port map (dsuact, dsuo.active);
    end generate;
  end generate;

  nodsu : if CFG_DSU = 0 generate 
    ahbso(2) <= ahbs_none; dsuo.tstop <= '0'; dsuo.active <= '0';
  end generate;

  dcomgen : if CFG_AHB_UART = 1 generate
    dcom0: ahbuart		-- Debug UART
    generic map (hindex => CFG_NCPU, pindex => 7, paddr => 7)
    port map (rstn, clkm, dui, duo, apbi, apbo(7), ahbmi, ahbmo(CFG_NCPU));
    dsurx_pad : inpad generic map (tech => padtech) port map (dsurx, dui.rxd); 
    dsutx_pad : outpad generic map (tech => padtech) port map (dsutx, duo.txd);
    led(0) <= not dui.rxd; led(1) <= not duo.txd;
  end generate;
  nouah : if CFG_AHB_UART = 0 generate apbo(7) <= apb_none; end generate;

  ahbjtaggen0 :if CFG_AHB_JTAG = 1 generate
    ahbjtag0 : ahbjtag generic map(tech => fabtech, hindex => CFG_NCPU+CFG_AHB_UART,
                                   ainst => 16, dinst => 17)
      port map(rstn, clkm, tck, tms, tdi, tdo, ahbmi, ahbmo(CFG_NCPU+CFG_AHB_UART),
               open, open, open, open, open, open, open, gnd(0), trst);
  end generate;
  
----------------------------------------------------------------------
---  Memory controllers ----------------------------------------------
----------------------------------------------------------------------

  ssr0 : if CFG_SSCTRL = 1 generate
    ssrctrl0 : ssrctrl generic map (hindex => 0, pindex => 0, bus16 => CFG_SSCTRLP16)
    port map (rstn, clkm, ahbsi, ahbso(0), apbi, apbo(0), memi, memo);
    sram_adv <= '0';
    ramben_pads : for i in 0 to 3 generate
      x : outpad generic map (tech => padtech) 
	port map (ramben(i), memo.wrn(3-i));
    end generate;
  end generate;

  mctrl2 : if (CFG_MCTRL_LEON2 = 1) and (CFG_SSCTRL = 0) generate 	-- LEON2 memory controller
    sr1 : mctrl generic map (hindex => 0, pindex => 0, paddr => 0, 
	srbanks => 2, sden => CFG_MCTRL_SDEN, ram8 => CFG_MCTRL_RAM8BIT,
	ram16 => CFG_MCTRL_RAM16BIT, invclk => CFG_MCTRL_INVCLK)
    port map (rstn, clkm, memi, memo, ahbsi, ahbso(0), apbi, apbo(0), wpo, sdo);
    sram_adv <= '1';
    ramben_pads : for i in 0 to 3 generate
      x : outpad generic map (tech => padtech) 
	port map (ramben(i), memo.mben(3-i));
    end generate;
  end generate;

  mempads : if (CFG_MCTRL_LEON2 = 1) or (CFG_SSCTRL = 1) generate 	-- LEON2 memory controller
    addr_pad : outpadv generic map (width => 19, tech => padtech) 
	port map (address, memo.address(20 downto 2)); 
    rams_pad : outpad generic map (tech => padtech) 
	port map (ramsn, memo.ramsn(0)); 
    roms_pad : outpad generic map (tech => padtech) 
	port map (romsn, memo.romsn(0)); 
    iosn_pad : outpad generic map (tech => padtech) 
	port map (iosn, memo.iosn); 
    oen_pad  : outpad generic map (tech => padtech) 
	port map (oen, memo.oen);
    rwen_pad : outpad generic map (tech => padtech) 
	port map (rwen, memo.writen); 
    roen_pad : outpad generic map (tech => padtech) 
	port map (ramoen, memo.ramoen(0));
    wri_pad  : outpad generic map (tech => padtech) 
	port map (writen, memo.writen);
--    read_pad : outpad generic map (tech => padtech) 
--	port map (read, memo.read); 

    bdr : for i in 0 to 3 generate
      data_pad : iopadv generic map (tech => padtech, width => 8)
      port map (data(31-i*8 downto 24-i*8), memo.data(31-i*8 downto 24-i*8),
	memo.bdrive(i), memi.data(31-i*8 downto 24-i*8));
    end generate;

  end generate;

  memi.brdyn <= '1'; memi.bexcn <= '1';
  memi.writen <= '1'; memi.wrn <= "1111"; memi.bwidth <= "10";

----------------------------------------------------------------------
---  APB Bridge and various periherals -------------------------------
----------------------------------------------------------------------

  bpromgen : if CFG_AHBROMEN /= 0 generate
    brom : entity work.ahbrom
      generic map (hindex => 8, haddr => CFG_AHBRODDR, pipe => CFG_AHBROPIP)
      port map ( rstn, clkm, ahbsi, ahbso(8));
  end generate;
  nobpromgen : if CFG_AHBROMEN = 0 generate
     ahbso(8) <= ahbs_none;
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
    u1i.rxd <= rxd1; u1i.extclk <= '0'; txd1 <= u1o.txd;
    u1i.ctsn <= '0'; --rtsn1 <= u1o.rtsn;
    led(2) <= not u1i.rxd; led(3) <= not u1o.txd;
  end generate;
  noua0 : if CFG_UART1_ENABLE = 0 generate apbo(1) <= apb_none; end generate;

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
	nbits => CFG_GPT_TW)
    port map (rstn, clkm, apbi, apbo(3), gpti, gpto);
    gpti.dhalt <= dsuo.tstop; gpti.extclk <= '0';
    led(4) <= gpto.wdog;
  end generate;
  notim : if CFG_GPT_ENABLE = 0 generate apbo(3) <= apb_none; end generate;

  gpio0 : if CFG_GRGPIO_ENABLE /= 0 generate     -- GR GPIO unit
    grgpio0: grgpio
      generic map( pindex => 11, paddr => 11, imask => CFG_GRGPIO_IMASK, nbits => 7)
      port map( rstn, clkm, apbi, apbo(11), gpioi, gpioo);

      pio_pads : for i in 0 to 6 generate
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
        mdcscaler => sysfreq/1000, enable_mdio => 1, fifosize => CFG_ETH_FIFO,
        nsync => 1, edcl => CFG_DSU_ETH, edclbufsz => CFG_ETH_BUF,
        macaddrh => CFG_ETH_ENM, macaddrl => CFG_ETH_ENL, 
	ipaddrh => CFG_ETH_IPM, ipaddrl => CFG_ETH_IPL)
     port map( rst => rstn, clk => clkm, ahbmi => ahbmi,
       ahbmo => ahbmo(CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG), apbi => apbi,
       apbo => apbo(15), ethi => ethi, etho => etho); 

      emdio_pad : iopad generic map (tech => padtech) 
      port map (emdio, etho.mdio_o, etho.mdio_oe, ethi.mdio_i);
      xx : techbuf generic map (tech => fabtech, buftype => 2) port map (etx_clk, letx_clk);
      etxc_pad : inpad generic map (tech => padtech) 
	port map (letx_clk, ethi.tx_clk);
      erxc_pad : clkpad generic map (tech => padtech, arch => 1) 
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
	port map ( etx_en, etho.tx_en);
      etxer_pad : outpad generic map (tech => padtech) 
	port map (etx_er, etho.tx_er);
      emdc_pad : outpad generic map (tech => padtech) 
	port map (emdc, etho.mdc);

  end generate;

-----------------------------------------------------------------------
---  CAN --------------------------------------------------------------
-----------------------------------------------------------------------
   can0 : if CFG_CAN = 1 generate 
     can0 : can_oc generic map (slvndx => 6, ioaddr => CFG_CANIO,
    	iomask => 16#FF0#, irq => CFG_CANIRQ, memtech => memtech)
      port map (rstn, clkm, ahbsi, ahbso(6), can_lrx, can_ltx );
   end generate;
--   ncan : if CFG_CAN = 0 generate ahbso(6) <= ahbs_none; end generate;

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
---  Boot message  ----------------------------------------------------
-----------------------------------------------------------------------

-- pragma translate_off
  x : report_version 
  generic map (
   msg1 => "LEON3 Actel PROASIC3-1000 Demonstration design",
   msg2 => "GRLIB Version " & tost(LIBVHDL_VERSION/1000) & "." & tost((LIBVHDL_VERSION mod 1000)/100)
        & "." & tost(LIBVHDL_VERSION mod 100) & ", build " & tost(LIBVHDL_BUILD),
   msg3 => "Target technology: " & tech_table(fabtech) & ",  memory library: " & tech_table(memtech),
   mdel => 1
  );
-- pragma translate_on
end;
