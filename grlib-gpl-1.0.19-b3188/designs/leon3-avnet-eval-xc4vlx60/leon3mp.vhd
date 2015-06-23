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
    fabtech : integer := CFG_FABTECH;
    memtech : integer := CFG_MEMTECH;
    padtech : integer := CFG_PADTECH;
    clktech : integer := CFG_CLKTECH;
    disas   : integer := CFG_DISAS;     -- Enable disassembly to console
    dbguart : integer := CFG_DUART;     -- Print UART on console
    pclow   : integer := CFG_PCLOW;
    ddrfreq    : integer := 100000  -- frequency of ddr clock in kHz 
    );
  port (
    resetn  : in  std_ulogic;
    resoutn : out std_logic;
    clk_100mhz : in  std_ulogic;
    clk_50mhz : in  std_ulogic;
    errorn  : out   std_ulogic;

    -- prom interface
    address : out   std_logic_vector(21 downto 0);
    data    : inout std_logic_vector(15 downto 0);
    romsn   : out   std_ulogic;
    oen     : out   std_ulogic;
    writen  : out   std_ulogic;
    romrstn : out   std_ulogic;
-- pragma translate_off
    iosn    : out   std_ulogic;
    testdata  : inout std_logic_vector(15 downto 0);
-- pragma translate_on 

    -- ddr memory  
    ddr_clk0  	: out std_logic;
    ddr_clk0b 	: out std_logic;
    ddr_clk_fb_out  : out std_logic;
    ddr_clk_fb  : in std_logic;
    ddr_cke0  	: out std_logic;
    ddr_cs0b  	: out std_logic;
    ddr_web  	: out std_ulogic;                       -- ddr write enable
    ddr_rasb  	: out std_ulogic;                       -- ddr ras
    ddr_casb  	: out std_ulogic;                       -- ddr cas
    ddr_dm   	: out std_logic_vector (1 downto 0);    -- ddr dm
    ddr_dqs  	: inout std_logic_vector (1 downto 0);    -- ddr dqs
    ddr_ad      : out std_logic_vector (12 downto 0);   -- ddr address
    ddr_ba      : out std_logic_vector (1 downto 0);    -- ddr bank address
    ddr_dq  	: inout std_logic_vector (15 downto 0); -- ddr data
    
	 -- debug support unit
    dsuen   : in  std_ulogic;
    dsubre  : in  std_ulogic;
    dsuact  : out std_ulogic;

    -- UART for serial DCL/console I/O
    serrx : in std_ulogic;
    sertx : out std_ulogic;
    rtsn  : out std_ulogic;
    ctsn  : in std_ulogic;
    led_rx  : out std_ulogic;
    led_tx  : out std_ulogic;

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
    erstn   : out   std_ulogic;

    -- OLED display signals
    disp_dcn  : out    std_ulogic;
    disp_csn  : out    std_ulogic;
    disp_rdn  : out    std_ulogic;
    disp_wrn  : out    std_ulogic;
    disp_d    : inout  std_logic_vector(7 downto 0)
    );
end;

architecture rtl of leon3mp is

  constant blength   : integer := 12;
  constant fifodepth : integer := 8;

  signal vcc, gnd   : std_logic_vector(4 downto 0);
  signal memi       : memory_in_type;
  signal memo       : memory_out_type;
  signal wpo        : wprot_out_type;
  signal sdi        : sdctrl_in_type;
  signal sdo       : sdctrl_out_type;

  signal gpioi : gpio_in_type;
  signal gpioo : gpio_out_type;

  signal apbi  : apb_slv_in_type;
  signal apbo  : apb_slv_out_vector := (others => apb_none);
  signal ahbsi : ahb_slv_in_type;
  signal ahbso : ahb_slv_out_vector := (others => ahbs_none);
  signal ahbmi : ahb_mst_in_type;
  signal ahbmo : ahb_mst_out_vector := (others => ahbm_none);

  signal lclk : std_ulogic;
  signal ddrclk, ddrrst, ddrclkfb : std_ulogic;

  signal clkm, rstn, clkml, clk2x : std_ulogic;
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

  signal gpti : gptimer_in_type;

  signal tck, tms, tdi, tdo : std_ulogic;

  signal fpi : grfpu_in_vector_type;
  signal fpo : grfpu_out_vector_type;


--  signal dsubre         : std_logic;
  signal duart, ldsuen   : std_logic;
  signal rsertx, rserrx, rdsuen   : std_logic;

  signal rstraw : std_logic;
  signal rstneg : std_logic;
  signal rxd1 : std_logic;
  signal txd1 : std_logic;
  signal lock : std_logic;
  signal lclk50 : std_logic;

  signal ddr_clk 	: std_logic_vector(2 downto 0);
  signal ddr_clkb	: std_logic_vector(2 downto 0);
  signal ddr_cke  	: std_logic_vector(1 downto 0);
  signal ddr_csb  	: std_logic_vector(1 downto 0);
  signal ddr_adl        : std_logic_vector(13 downto 0);   -- ddr address

  attribute keep : boolean;
  attribute syn_keep : boolean;
  attribute syn_preserve : boolean;
  attribute syn_keep of lock : signal is true;
  attribute syn_keep of clkml : signal is true;
  attribute syn_preserve of clkml : signal is true;
  attribute keep of lock : signal is true;
  attribute keep of clkml : signal is true;
  attribute keep of clkm : signal is true;


  constant BOARD_FREQ : integer := 50000;   -- input frequency in KHz
  constant CPU_FREQ : integer := BOARD_FREQ * CFG_CLKMUL / CFG_CLKDIV;  -- cpu frequency in KHz

begin

  romrstn <= rstn;

----------------------------------------------------------------------
---  Reset and Clock generation  -------------------------------------
----------------------------------------------------------------------

  vcc <= (others => '1'); gnd <= (others => '0');
  cgi.pllctrl <= "00"; cgi.pllrst <= rstraw;
  rstneg <= not resetn;
	
  rst0 : rstgen port map (rstneg, clkm, lock, rstn, rstraw);
  
  clk_pad : clkpad generic map (tech => padtech) port map (clk_100mhz, lclk); 
  clk50_pad : clkpad generic map (tech => padtech) port map (clk_50mhz, lclk50); 

  clkgen0 : clkgen  		-- clock generator
    generic map (clktech, CFG_CLKMUL, CFG_CLKDIV, 0, 1, 0, 0, 0, BOARD_FREQ, 0)
    port map (lclk50, gnd(0), clkm, open, open, open, open, cgi, cgo);

---------------------------------------------------------------------- 
---  AHB CONTROLLER --------------------------------------------------
----------------------------------------------------------------------

  ahb0 : ahbctrl                        -- AHB arbiter/multiplexer
    generic map (defmast => CFG_DEFMST, split => CFG_SPLIT,
                 rrobin  => CFG_RROBIN, ioaddr => CFG_AHBIO, ioen => 1, 
		nahbm => CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG+CFG_GRETH+1, 
	        nahbs => 8)
    port map (rstn, clkm, ahbmi, ahbmo, ahbsi, ahbso);

----------------------------------------------------------------------
---  LEON3 processor and DSU -----------------------------------------
----------------------------------------------------------------------

  leon3gen : if CFG_LEON3 = 1 generate
    cpu : for i in 0 to CFG_NCPU-1 generate
      nosh : if CFG_GRFPUSH = 0 generate    
        u0 : leon3s                         -- LEON3 processor
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

      sh : if CFG_GRFPUSH = 1 generate
        u0 : leon3sh 		-- LEON3 processor      
        generic map (i, fabtech, memtech, CFG_NWIN, CFG_DSU, CFG_FPU, CFG_V8, 
		0, CFG_MAC, pclow, 0, CFG_NWP, CFG_ICEN, CFG_IREPL, CFG_ISETS, CFG_ILINE, 
		CFG_ISETSZ, CFG_ILOCK, CFG_DCEN, CFG_DREPL, CFG_DSETS, CFG_DLINE, CFG_DSETSZ,
		CFG_DLOCK, CFG_DSNOOP, CFG_ILRAMEN, CFG_ILRAMSZ, CFG_ILRAMADDR, CFG_DLRAMEN,
        	CFG_DLRAMSZ, CFG_DLRAMADDR, CFG_MMUEN, CFG_ITLBNUM, CFG_DTLBNUM, CFG_TLB_TYPE, CFG_TLB_REP, 
        	CFG_LDDEL, disas, CFG_ITBSZ, CFG_PWD, CFG_SVT, CFG_RSTADDR, CFG_NCPU-1)
        port map (clkm, rstn, ahbmi, ahbmo(i), ahbsi, ahbso, 
    		irqi(i), irqo(i), dbgi(i), dbgo(i), fpi(i), fpo(i));
      end generate;
    end generate;

    sh : if CFG_GRFPUSH = 1 generate
     grfpush0 : grfpushwx generic map ((CFG_FPU-1), CFG_NCPU)
      port map (clkm, rstn, fpi, fpo);
    end generate;

    error_pad : odpad generic map (tech => padtech) port map (errorn, dbgo(0).error);

    dsugen : if CFG_DSU = 1 generate
      dsu0 : dsu3                         -- LEON3 Debug Support Unit
        generic map (hindex => 2, haddr => 16#900#, hmask => 16#F00#,
                   ncpu   => CFG_NCPU, tbits => 30, tech => memtech, irq => 0, kbytes => CFG_ATBSZ)
        port map (rstn, clkm, ahbmi, ahbsi, ahbso(2), dbgo, dbgi, dsui, dsuo);
--    dsuen_pad  : inpad generic map (tech  => padtech) port map (dsuen, dsui.enable);
        dsui.enable <= '1';
      dsubre_pad : inpad generic map (tech  => padtech) port map (dsubre, dsui.break);
      dsuact_pad : outpad generic map (tech => padtech) port map (dsuact, dsuo.active);
    end generate;
  end generate;
  nodcom : if CFG_DSU = 0 generate ahbso(2) <= ahbs_none; end generate;

  dcomgen : if CFG_AHB_UART = 1 generate
    dcom0 : ahbuart                     -- Debug UART
      generic map (hindex => CFG_NCPU, pindex => 4, paddr => 7)
      port map (rstn, clkm, dui, duo, apbi, apbo(4), ahbmi, ahbmo(CFG_NCPU));
  end generate;
  nouah : if CFG_AHB_UART = 0 generate apbo(4) <= apb_none; end generate;

  ahbjtaggen0 :if CFG_AHB_JTAG = 1 generate
    ahbjtag0 : ahbjtag generic map(tech => fabtech, hindex => CFG_NCPU+CFG_AHB_UART)
      port map(rstn, clkm, tck, tms, tdi, tdo, ahbmi, ahbmo(CFG_NCPU+CFG_AHB_UART),
               open, open, open, open, open, open, open, gnd(0));
  end generate;

----------------------------------------------------------------------
---  Memory controllers ----------------------------------------------
----------------------------------------------------------------------

  mg2 : if CFG_MCTRL_LEON2 = 1 generate        -- LEON2 memory controller
    sr1 : mctrl generic map (hindex => 5, pindex => 0, 
	paddr => 0, srbanks => 1, ramaddr => 16#600#, rammask => 16#F00#, ram16 => 1 )
      port map (rstn, clkm, memi, memo, ahbsi, ahbso(5), apbi, apbo(0), wpo, open);
  end generate;

  memi.brdyn  <= '1'; memi.bexcn <= '1';
  memi.writen <= '1'; memi.wrn <= "1111"; memi.bwidth <= "01";

  mg0 : if (CFG_MCTRL_LEON2 = 0) generate 
    apbo(0) <= apb_none; ahbso(0) <= ahbs_none;
    roms_pad : outpad generic map (tech => padtech)
      port map (romsn, vcc(0));
  end generate;

  mgpads : if (CFG_MCTRL_LEON2 /= 0) generate 
    addr_pad : outpadv generic map (width => 22, tech => padtech)
      port map (address, memo.address(22 downto 1));
    roms_pad : outpad generic map (tech => padtech)
      port map (romsn, memo.romsn(0));
    oen_pad : outpad generic map (tech => padtech)
      port map (oen, memo.oen);
    wri_pad : outpad generic map (tech => padtech)
      port map (writen, memo.writen);

-- pragma translate_off
    iosn_pad : outpad generic map (tech => padtech) 
	port map (iosn, memo.iosn);
    tbdr : for i in 0 to 1 generate
      data_pad : iopadv generic map (tech => padtech, width => 8)
        port map (testdata(15-i*8 downto 8-i*8), memo.data(15-i*8 downto 8-i*8),
                  memo.bdrive(i+2), memi.data(15-i*8 downto 8-i*8));
    end generate;
-- pragma translate_on

    bdr : for i in 0 to 1 generate
      data_pad : iopadv generic map (tech => padtech, width => 8)
        port map (data(15-i*8 downto 8-i*8), memo.data(31-i*8 downto 24-i*8),
                  memo.bdrive(i), memi.data(31-i*8 downto 24-i*8));
    end generate;
  end generate;

----------------------------------------------------------------------
---  DDR memory controller -------------------------------------------
----------------------------------------------------------------------

  ddrsp0 : if (CFG_DDRSP /= 0) generate 

    ddrc : ddrspa generic map ( fabtech => virtex4, memtech => memtech, 
	hindex => 4, haddr => 16#400#, hmask => 16#F00#, ioaddr => 1, 
	pwron => CFG_DDRSP_INIT, MHz => 100, rskew => -95
-- pragma translate_off
	* 0	-- disable clock skew during simulation
-- pragma translate_on
	, clkmul => CFG_DDRSP_FREQ/5, clkdiv => 20, col => CFG_DDRSP_COL, 
	Mbyte => CFG_DDRSP_SIZE, ahbfreq => CPU_FREQ/1000, ddrbits => 16)
     port map (
	rstneg, rstn, lclk, clkm, lock, clkml, clkml,  ahbsi, ahbso(4),
	ddr_clk, ddr_clkb, ddr_clk_fb_out, ddr_clk_fb,
	ddr_cke, ddr_csb, ddr_web, ddr_rasb, ddr_casb, 
	ddr_dm, ddr_dqs, ddr_adl, ddr_ba, ddr_dq);

        ddr_clk0 <= ddr_clk(0); ddr_clk0b <= ddr_clkb(0);
        ddr_cke0 <= ddr_cke(0); ddr_cs0b <= ddr_csb(0);
        ddr_ad <= ddr_adl(12 downto 0);
  end generate;

  noddr :  if (CFG_DDRSP = 0) generate lock <= '1'; end generate;

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

  gpio0 : if CFG_GRGPIO_ENABLE /= 0 generate     -- GR GPIO unit
    grgpio0: grgpio
      generic map( pindex => 11, paddr => 11, imask => CFG_GRGPIO_IMASK, 
	nbits => 12 --CFG_GRGPIO_WIDTH
      )
      port map( rstn, clkm, apbi, apbo(11), gpioi, gpioo);

      disp_csn_pad : outpad generic map (tech => padtech)
        port map (disp_csn, gpioo.dout(8));
      disp_dcn_pad : outpad generic map (tech => padtech)
        port map (disp_dcn, gpioo.dout(9));
      disp_rdn_pad : outpad generic map (tech => padtech)
        port map (disp_rdn, gpioo.dout(10));
      disp_wrn_pad : outpad generic map (tech => padtech)
        port map (disp_wrn, gpioo.dout(11));
      disp_d_pads : for i in 0 to 7 generate
        pio_pad : iopad generic map (tech => padtech)
            port map (disp_d(i), gpioo.dout(i), gpioo.oen(i), gpioi.din(i));
      end generate;
   end generate;

-----------------------------------------------------------------------
---  ETHERNET ---------------------------------------------------------
-----------------------------------------------------------------------

  eth0 : if CFG_GRETH = 1 generate -- Gaisler ethernet MAC
      e1 : grethm generic map(hindex => CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG,
	pindex => 15, paddr => 15, pirq => 12, memtech => memtech,
        mdcscaler => CPU_FREQ/1000, enable_mdio => 1, fifosize => CFG_ETH_FIFO,
        nsync => 1, edcl => CFG_DSU_ETH, edclbufsz => CFG_ETH_BUF,
        macaddrh => CFG_ETH_ENM, macaddrl => CFG_ETH_ENL, 
	ipaddrh => CFG_ETH_IPM, ipaddrl => CFG_ETH_IPL,
	phyrstadr => 3, giga => CFG_GRETH1G)
     port map( rst => rstn, clk => clkm, ahbmi => ahbmi,
       ahbmo => ahbmo(CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG), apbi => apbi,
       apbo => apbo(15), ethi => ethi, etho => etho); 

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
    erstn_pad : outpad generic map (tech => padtech)
      port map (erstn, rstn);

  end generate;

-----------------------------------------------------------------------
---  AHB DMA ----------------------------------------------------------
-----------------------------------------------------------------------

--  dma0 : ahbdma
--    generic map (hindex => CFG_NCPU+CFG_AHB_UART+CFG_GRETH,
--	pindex => 12, paddr => 12, dbuf => 32)
--    port map (rstn, clkm, apbi, apbo(12), ahbmi, 
--	ahbmo(CFG_NCPU+CFG_AHB_UART+CFG_GRETH));
--
--  at0 : ahbtrace
--  generic map ( hindex  => 7, ioaddr => 16#200#, iomask => 16#E00#,
--    tech    => memtech, irq     => 0, kbytes  => 8) 
--  port map ( rstn, clkm, ahbmi, ahbsi, ahbso(7));

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

  nam1 : for i in (CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG+CFG_GRETH+1) to NAHBMST-1 generate
    ahbmo(i) <= ahbm_none;
  end generate;
--  nap0 : for i in 9 to NAPBSLV-1-CFG_GRETH generate apbo(i) <= apb_none; end generate;
--  nah0 : for i in 8 to NAHBSLV-1 generate ahbso(i) <= ahbs_none; end generate;

  resoutn <= rstn;

-----------------------------------------------------------------------
---  Boot message  ----------------------------------------------------
-----------------------------------------------------------------------

-- pragma translate_off
  x : report_version
    generic map (
   msg1 => "LEON3 MP Demonstration design for Avnet Virtex4 Eval board",
   msg2 => "GRLIB Version " & tost(LIBVHDL_VERSION/1000) & "." & tost((LIBVHDL_VERSION mod 1000)/100)
      & "." & tost(LIBVHDL_VERSION mod 100) & ", build " & tost(LIBVHDL_BUILD),
   msg3 => "Target technology: " & tech_table(fabtech) & ",  memory library: " & tech_table(memtech),
   mdel => 1
      );
-- pragma translate_on

-- use switch 1 to multiplex DSU UART and UART1

  dsuen_pad  : inpad generic map (tech  => padtech) port map (dsuen, ldsuen);
  duart <= rdsuen when  CFG_AHB_UART /= 0 else '0';
  rxd1 <= txd1 when duart = '1' else rserrx;
  rsertx <= duo.txd when duart = '1' else txd1; 
  dui.rxd <= rserrx when duart = '1' else '1';

  led_rx <= not rserrx;
  p1 : process(clkm) 
  begin
    if rising_edge(clkm) then
      sertx <= rsertx; rserrx <= serrx; rdsuen <= ldsuen;
      rtsn <= '0';
      led_tx <= not rsertx;
    end if;
  end process;

end rtl;
