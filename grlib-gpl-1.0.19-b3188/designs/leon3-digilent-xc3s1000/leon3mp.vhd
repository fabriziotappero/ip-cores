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
library grlib, techmap;
use grlib.amba.all;
use grlib.stdlib.all;
use techmap.gencomp.all;
library gaisler;
use gaisler.memctrl.all;
use gaisler.leon3.all;
use gaisler.uart.all;
use gaisler.misc.all;
use gaisler.jtag.all;
-- pragma translate_off
use gaisler.sim.all;
-- pragma translate_on

library esa;
use esa.memoryctrl.all;

use work.config.all;

entity leon3mp is
  generic (
    fabtech       : integer := CFG_FABTECH;
    memtech       : integer := CFG_MEMTECH;
    padtech       : integer := CFG_PADTECH;
    clktech       : integer := CFG_CLKTECH;
    disas         : integer := CFG_DISAS;	-- Enable disassembly to console
    dbguart       : integer := CFG_DUART;	-- Print UART on console
    pclow         : integer := CFG_PCLOW
  );
  port (
    reset	  : in  std_ulogic;
    clk		  : in  std_ulogic; 	-- 50 MHz main clock
    error	  : out std_ulogic;
    address 	  : out std_logic_vector(19 downto 2);
    data	  : inout std_logic_vector(31 downto 0);
    ramsn   	  : out std_logic_vector (1 downto 0);
    mben   	  : out std_logic_vector (3 downto 0);
    oen    	  : out std_ulogic;
    writen 	  : out std_ulogic;

    dsubre  	  : in std_ulogic;
    dsuact  	  : out std_ulogic;

    txd1   	  : out std_ulogic; 			-- UART1 tx data
    rxd1   	  : in  std_ulogic;  			-- UART1 rx data

    pio           : inout std_logic_vector(17 downto 0); 	-- I/O port
--    switch        : in std_logic_vector(7 downto 0); 	-- switches
--    button        : in std_logic_vector(2 downto 0); 	-- buttons

    ps2clk        : inout std_logic;
    ps2data       : inout std_logic;

    vid_hsync     : out std_ulogic;
    vid_vsync     : out std_ulogic;
    vid_r         : out std_logic;
    vid_g         : out std_logic;
    vid_b         : out std_logic

	);
end;

architecture rtl of leon3mp is

constant blength : integer := 12;
constant fifodepth : integer := 8;
constant maxahbm : integer := CFG_NCPU+
	CFG_AHB_JTAG+CFG_SVGA_ENABLE;

signal vcc, gnd   : std_logic_vector(4 downto 0);
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

signal clkm, rstn, rstraw, nerror : std_ulogic;
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

signal gpti : gptimer_in_type;

signal gpioi : gpio_in_type;
signal gpioo : gpio_out_type;

signal lclk, rst : std_ulogic;
signal tck, tckn, tms, tdi, tdo : std_ulogic;

signal kbdi  : ps2_in_type;
signal kbdo  : ps2_out_type;
signal vgao  : apbvga_out_type;
signal clkval : std_logic_vector(1 downto 0);


constant BOARD_FREQ : integer := 50000;   -- input frequency in KHz
constant CPU_FREQ : integer := BOARD_FREQ * CFG_CLKMUL / CFG_CLKDIV;  -- cpu frequency in KHz
constant IOAEN : integer := 0;

signal stati : ahbstat_in_type;

signal dac_clk, clk1x, vid_clock, video_clk, clkvga : std_logic;  -- signals to vga_clkgen.
signal clk_sel : std_logic_vector(1 downto 0);
                         
attribute keep : boolean;
attribute syn_keep : boolean;
attribute syn_preserve : boolean;
attribute syn_keep of video_clk : signal is true;
attribute syn_preserve of video_clk : signal is true;
attribute keep of video_clk : signal is true;

begin

----------------------------------------------------------------------
---  Reset and Clock generation  -------------------------------------
----------------------------------------------------------------------
  
  vcc <= (others => '1'); gnd <= (others => '0');
  cgi.pllctrl <= "00"; cgi.pllrst <= rstraw;

  clk_pad : clkpad generic map (tech => padtech) port map (clk, lclk); 
  clkgen0 : clkgen  		-- clock generator
    generic map (clktech, CFG_CLKMUL, CFG_CLKDIV, CFG_MCTRL_SDEN,
	CFG_CLK_NOFB, 0, 0, 0, BOARD_FREQ)
    port map (lclk, lclk, clkm, open, open, open, open, cgi, cgo, open, clk1x);

  resetn_pad : inpad generic map (tech => padtech) port map (reset, rst); 
  rst0 : rstgen			-- reset generator
  generic map (acthigh => 1)
  port map (rst, clkm, cgo.clklock, rstn, rstraw);

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
    nerror <= not dbgo(0).error;
    error_pad : outpad generic map (tech => padtech) port map (error, nerror);
    
    dsugen : if CFG_DSU = 1 generate
      dsu0 : dsu3			-- LEON3 Debug Support Unit
      generic map (hindex => 2, haddr => 16#900#, hmask => 16#F00#, 
         ncpu => CFG_NCPU, tbits => 30, tech => memtech, irq => 0, kbytes => CFG_ATBSZ)
      port map (rstn, clkm, ahbmi, ahbsi, ahbso(2), dbgo, dbgi, dsui, dsuo);
      dsui.enable <= '1'; 
      dsubre_pad : inpad generic map (tech => padtech) port map (dsubre, dsui.break); 
      dsuact_pad : outpad generic map (tech => padtech) port map (dsuact, dsuo.active);
    end generate;
  end generate;
  nodsu : if CFG_DSU = 0 generate 
    dsuo.tstop <= '0'; dsuo.active <= '0';
  end generate;

--  dcomgen : if CFG_AHB_UART = 1 generate
--    dcom0: ahbuart		-- Debug UART
--    generic map (hindex => CFG_NCPU, pindex => 7, paddr => 7)
--    port map (rstn, clkm, dui, duo, apbi, apbo(7), ahbmi, ahbmo(CFG_NCPU));
--    dsurx_pad : inpad generic map (tech => padtech) port map (rxd2, dui.rxd); 
--    dsutx_pad : outpad generic map (tech => padtech) port map (txd2, duo.txd);
--  end generate;
--  nouah : if CFG_AHB_UART = 0 generate apbo(7) <= apb_none; end generate;

  ahbjtaggen0 :if CFG_AHB_JTAG = 1 generate
    ahbjtag0 : ahbjtag generic map(tech => fabtech, hindex => CFG_NCPU)
      port map(rstn, clkm, tck, tms, tdi, tdo, ahbmi, ahbmo(CFG_NCPU),
               open, open, open, open, open, open, open, gnd(0));
  end generate;
  
----------------------------------------------------------------------
---  Memory controllers ----------------------------------------------
----------------------------------------------------------------------

  memi.writen <= '1'; memi.wrn <= "1111"; memi.bwidth <= "00";

  mctrl0 : mctrl generic map (hindex => 0, pindex => 0,
	rommask => 16#000#, iomask => 16#000#,
	paddr => 0, srbanks => 1, ram8 => CFG_MCTRL_RAM8BIT, 
	ram16 => CFG_MCTRL_RAM16BIT, sden => CFG_MCTRL_SDEN, 
	invclk => CFG_CLK_NOFB, sepbus => CFG_MCTRL_SEPBUS)
  port map (rstn, clkm, memi, memo, ahbsi, ahbso(0), apbi, apbo(0), wpo, sdo);

  addr_pad : outpadv generic map (width => 18, tech => padtech) 
	port map (address, memo.address(19 downto 2));
  ramsa_pad : outpad generic map (tech => padtech) 
	port map (ramsn(0), memo.ramsn(0)); 
  ramsb_pad : outpad generic map (tech => padtech) 
	port map (ramsn(1), memo.ramsn(0)); 
  oen_pad  : outpad generic map (tech => padtech) 
	port map (oen, memo.oen);
  wri_pad  : outpad generic map (tech => padtech) 
	port map (writen, memo.writen);
  mben_pads : outpadv generic map (tech => padtech, width => 4)
        port map (mben, memo.mben);

  data_pads : iopadvv generic map (tech => padtech, width => 32)
      port map (data, memo.data(31 downto 0),
	memo.vbdrive(31 downto 0), memi.data(31 downto 0));

----------------------------------------------------------------------
---  APB Bridge and various periherals -------------------------------
----------------------------------------------------------------------

  bpromgen : if CFG_AHBROMEN /= 0 generate
    brom : entity work.ahbrom
      generic map (hindex => 6, haddr => CFG_AHBRODDR, pipe => CFG_AHBROPIP)
      port map ( rstn, clkm, ahbsi, ahbso(6));
  end generate;

----------------------------------------------------------------------
---  APB Bridge and various periherals -------------------------------
----------------------------------------------------------------------

  apb0 : apbctrl				-- AHB/APB bridge
  generic map (hindex => 1, haddr => CFG_APBADDR, nslaves => 16)
  port map (rstn, clkm, ahbsi, ahbso(1), apbi, apbo );

  ua1 : if CFG_UART1_ENABLE /= 0 generate
    uart1 : apbuart			-- UART 1
    generic map (pindex => 1, paddr => 1,  pirq => 2, console => dbguart,
	fifosize => CFG_UART1_FIFO)
    port map (rstn, clkm, apbi, apbo(1), u1i, u1o);
    u1i.extclk <= '0';
    rxd1_pad : inpad generic map (tech => padtech) port map (rxd1, u1i.rxd); 
    txd1_pad : outpad generic map (tech => padtech) port map (txd1, u1o.txd);
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
    port map (rstn, clkm, apbi, apbo(3), gpti, open);
    gpti.dhalt <= dsuo.tstop; gpti.extclk <= '0';
  end generate;

  nogpt : if CFG_GPT_ENABLE = 0 generate apbo(3) <= apb_none; end generate;

  kbd : if CFG_KBD_ENABLE /= 0 generate
    ps20 : apbps2 generic map(pindex => 5, paddr => 5, pirq => 5)
      port map(rstn, clkm, apbi, apbo(5), kbdi, kbdo);
  end generate;
  nokbd : if CFG_KBD_ENABLE = 0 generate 
	apbo(5) <= apb_none; kbdo <= ps2o_none;
  end generate;
  kbdclk_pad : iopad generic map (tech => padtech)
      port map (ps2clk,kbdo.ps2_clk_o, kbdo.ps2_clk_oe, kbdi.ps2_clk_i);
  kbdata_pad : iopad generic map (tech => padtech)
        port map (ps2data, kbdo.ps2_data_o, kbdo.ps2_data_oe, kbdi.ps2_data_i);

  clkdiv : process(clk1x, rstn)
    begin
	if rstn = '0' then clkval <= "00";
        elsif rising_edge(clk1x) then
	  clkval <= clkval + 1;
	end if;
  end process;

  vga : if CFG_VGA_ENABLE /= 0 generate
    vga0 : apbvga generic map(memtech => memtech, pindex => 6, paddr => 6)
       port map(rstn, clkm, video_clk, apbi, apbo(6), vgao);
    video_clock_pad : outpad generic map ( tech => padtech)
        port map (vid_clock, dac_clk);
    dac_clk <= not video_clk;
    b1 : techbuf generic map (2, virtex2) port map (clkval(0), video_clk);
   end generate;
  
  svga : if CFG_SVGA_ENABLE /= 0 generate
    clkvga <= clkval(1) when clk_sel = "00" else clkval(0) when clk_sel = "01" else clkm;
    b1 : techbuf generic map (2, virtex2) port map (clkvga, video_clk);
    svga0 : svgactrl generic map(memtech => memtech, pindex => 6, paddr => 6,
                hindex => CFG_NCPU+CFG_AHB_JTAG, 
		clk0 => 40000, clk1 => 20000, clk2 => 25000)
       port map(rstn, clkm, video_clk, apbi, apbo(6), vgao, ahbmi, 
		ahbmo(CFG_NCPU+CFG_AHB_JTAG), clk_sel);
    dac_clk <= not video_clk;
    video_clock_pad : outpad generic map ( tech => padtech)
        port map (vid_clock, dac_clk);
  end generate;

  novga : if (CFG_VGA_ENABLE = 0 and CFG_SVGA_ENABLE = 0) generate
    apbo(6) <= apb_none; vgao <= vgao_none;
  end generate;
  
  vert_sync_pad : outpad generic map (tech => padtech)
        port map (vid_vsync, vgao.vsync);
  horiz_sync_pad : outpad generic map (tech => padtech)
        port map (vid_hsync, vgao.hsync);
  video_out_r_pad : outpad generic map (tech => padtech)
        port map (vid_r, vgao.video_out_r(7));
  video_out_g_pad : outpad generic map (tech => padtech)
        port map (vid_g, vgao.video_out_g(7));
  video_out_b_pad : outpad generic map (tech => padtech)
        port map (vid_b, vgao.video_out_b(7)); 

  gpio0 : if CFG_GRGPIO_ENABLE /= 0 generate     -- GPIO unit
    grgpio0: grgpio
    generic map(pindex => 8, paddr => 8, imask => CFG_GRGPIO_IMASK, nbits => 18)
    port map(rst => rstn, clk => clkm, apbi => apbi, apbo => apbo(8),
    gpioi => gpioi, gpioo => gpioo);
    pio_pads : iopadvv generic map (width => 18, tech => padtech)
            port map (pio, gpioo.dout(17 downto 0), gpioo.oen(17 downto 0), 
	gpioi.din(17 downto 0));

  end generate;

-----------------------------------------------------------------------
---  AHB RAM ----------------------------------------------------------
-----------------------------------------------------------------------

  ocram : if CFG_AHBRAMEN = 1 generate 
    ahbram0 : ahbram generic map (hindex => 7, haddr => CFG_AHBRADDR, 
	tech => CFG_MEMTECH, kbytes => CFG_AHBRSZ)
    port map ( rstn, clkm, ahbsi, ahbso(7));
  end generate;

-----------------------------------------------------------------------
---  Drive unused bus elements  ---------------------------------------
-----------------------------------------------------------------------

--  nam1 : for i in (CFG_NCPU+FG_AHB_UART+CFG_GRETH+CFG_AHB_JTAG) to NAHBMST-1 generate
--    ahbmo(i) <= ahbm_none;
--  end generate;
--  nap0 : for i in 11 to NAPBSLV-1 generate apbo(i) <= apb_none; end generate;
--  nah0 : for i in 8 to NAHBSLV-1 generate ahbso(i) <= ahbs_none; end generate;

-----------------------------------------------------------------------
---  Test report module  ----------------------------------------------
-----------------------------------------------------------------------

-- pragma translate_off

  test0 : ahbrep generic map (hindex => 4, haddr => 16#200#)
	port map (rstn, clkm, ahbsi, ahbso(4));

-- pragma translate_on

-----------------------------------------------------------------------
---  Boot message  ----------------------------------------------------
-----------------------------------------------------------------------

-- pragma translate_off
  x : report_version 
  generic map (
   msg1 => "LEON3 Digilent XC3S1000 Demonstration design",
      msg2 => "GRLIB Version " & tost(LIBVHDL_VERSION/1000) & "." & tost((LIBVHDL_VERSION mod 1000)/100)
        & "." & tost(LIBVHDL_VERSION mod 100) & ", build " & tost(LIBVHDL_BUILD),
   msg3 => "Target technology: " & tech_table(fabtech) & ",  memory library: " & tech_table(memtech),
   mdel => 1
  );
-- pragma translate_on
end;
