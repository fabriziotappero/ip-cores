------------------------------------------------------------------------------
--  LEON3 Demonstration design
--  Copyright (C) 2004, Gaisler Research
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
use gaisler.pci.all;
use gaisler.net.all;
library esa;
use esa.memoryctrl.all;
use esa.pcicomp.all;
use work.config.all;

entity leon3ax is
  generic (
    fabtech       : integer := CFG_FABTECH;
    memtech       : integer := CFG_MEMTECH;
    padtech       : integer := CFG_PADTECH;
    clktech       : integer := CFG_CLKTECH;
    disas         : integer := CFG_DISAS;                -- Disassembly to console
    dbguart       : integer := CFG_DUART;                -- Print UART on console
    pclow         : integer := CFG_PCLOW);
  port (
    resetn        : in     std_logic;
    clk           : in     std_logic;
    errorn        : out    std_logic;

    sa            : out    std_logic_vector(15 downto 0);-- {sa(15) unused}
    sd            : inout  std_logic_vector(63 downto 0);
    scb           : inout  std_logic_vector(7 downto 0); -- {unused by default}
    sdclkfb       : in     std_logic;                   -- {unused by default}
    sdcsn         : out    std_logic_vector(1 downto 0); -- SDRAM chip select
    sdwen         : out    std_logic;                   -- SDRAM write enable
    sdrasn        : out    std_logic;                   -- SDRAM RAS
    sdcasn        : out    std_logic;                   -- SDRAM CAS
    sddqm         : out    std_logic_vector(7 downto 0); -- SDRAM DQM

    dsutx         : out    std_logic;                   -- DSU tx data
    dsurx         : in     std_logic;                   -- DSU rx data
    dsuen         : in     std_logic;
    dsubre        : in     std_logic;
    dsuact        : out    std_logic;

    txd           : out    std_logic_vector(1 to 2);     -- UART tx data
    rxd           : in     std_logic_vector(1 to 2);     -- UART rx data
    rtsn          : out    std_logic_vector(1 to 2);     -- UART rtsn
    ctsn          : in     std_logic_vector(1 to 2);     -- UART ctsn

    address       : out    std_logic_vector(27 downto 0);
    data          : inout  std_logic_vector(31 downto 0);

    ramsn         : out    std_logic_vector(4 downto 0);
    ramoen        : out    std_logic_vector(4 downto 0);
    rwen          : out    std_logic_vector(3 downto 0);
    ramben        : out    std_logic_vector(3 downto 0);
    oen           : out    std_logic;
    writen        : out    std_logic;
    read          : out    std_logic;
    iosn          : out    std_logic;
    romsn         : out    std_logic_vector(1 downto 0);

    cb            : inout  std_logic_vector(7 downto 0); -- {unused by default}
    bexcn         : in     std_logic;                    -- {unused by default}
    brdyn         : in     std_logic;                    -- {unused by default}

    gpio          : inout  std_logic_vector(15 downto 0);-- {unused by default}
    pciio         : inout  std_logic_vector(31 downto 0);-- {unused by default}

    pci_rst       : inout  std_logic;                   -- PCI bus
    pci_clk       : in     std_logic;

    pci_gnt       : in     std_logic;
    pci_idsel     : in     std_logic;
    pci_lock      : inout  std_logic;
    pci_ad        : inout  std_logic_vector(63 downto 0);
    pci_cbe       : inout  std_logic_vector(7 downto 0);
    pci_frame     : inout  std_logic;
    pci_irdy      : inout  std_logic;
    pci_trdy      : inout  std_logic;
    pci_devsel    : inout  std_logic;
    pci_stop      : inout  std_logic;
    pci_perr      : inout  std_logic;
    pci_par       : inout  std_logic;
    pci_req       : inout  std_logic;
    pci_serr      : inout  std_logic;
    pci_host      : in     std_logic;
    pci_66        : in     std_logic;

    --pci_arb_gnt   : out    std_logic_vector(7 downto 0);
    pci_arb_req   : in     std_logic_vector(7 downto 0);

    pci_ack64n    : inout  std_logic;                    -- {unused by default}
    pci_par64     : inout  std_logic;                    -- {unused by default}
    pci_req64n    : inout  std_logic;                    -- {unused by default}
    pci_en64      : in     std_logic);                   -- {unused by default}
end;

architecture rtl of leon3ax is

   --attribute syn_hier : string;
   --attribute syn_hier of rtl : architecture is "hard";

   --attribute syn_preserve_sr_priority : boolean;
   --attribute syn_preserve_sr_priority of rtl : architecture is true;

   constant    blength        : Integer := 12;
   constant    fifodepth      : integer := 8;

   constant    sdbits         : Integer := 64;

   signal      vcc, gnd       : std_logic_vector(4 downto 0);
   signal      memi           : memory_in_type;
   signal      memo           : memory_out_type;
   signal      wpo            : wprot_out_type;
   signal      sdi            : sdctrl_in_type;
   signal      sdo            : sdram_out_type;
   signal      sdo2, sdo3     : sdctrl_out_type;

   signal      apbi           : apb_slv_in_type;
   signal      apbo           : apb_slv_out_vector := (others => apb_none);
   signal      ahbsi          : ahb_slv_in_type;
   signal      ahbso          : ahb_slv_out_vector := (others => ahbs_none);
   signal      ahbmi          : ahb_mst_in_type;
   signal      ahbmo          : ahb_mst_out_vector := (others => ahbm_none);

   signal      clki, rstn, rstraw, pciclk, sdclkl : std_logic;
   signal      cgi            : clkgen_in_type;
   signal      cgo            : clkgen_out_type;

   signal      u1i, u2i, dui  : uart_in_type;
   signal      u1o, u2o, duo  : uart_out_type;

   signal      irqi           : irq_in_vector(0 to CFG_NCPU-1);
   signal      irqo           : irq_out_vector(0 to CFG_NCPU-1);

   signal      dbgi           : l3_debug_in_vector(0 to CFG_NCPU-1);
   signal      dbgo           : l3_debug_out_vector(0 to CFG_NCPU-1);

   signal      dsui           : dsu_in_type;
   signal      dsuo           : dsu_out_type;

   signal      pcii           : pci_in_type;
   signal      pcio           : pci_out_type;

   signal      ethi, ethi1, ethi2   : eth_in_type;
   signal      etho, etho1, etho2   : eth_out_type;

   signal      gpti                 : gptimer_in_type;

   signal      pci_arb_req_n        : std_logic_vector(0 to 7);
   signal      pci_arb_gnt_n        : std_logic_vector(0 to 7);

   signal      rben                 : std_logic_vector(3 downto 0);

   signal      lclk, lpci_clk       : Std_ULogic;

   signal      gpioi                : gpio_in_type;
   signal      gpioo                : gpio_out_type;

   --dummy signals to iopads for unused ports
   signal      cbin, cbout    : std_logic_vector(7 downto 0);

begin

----------------------------------------------------------------------
---  Reset and Clock generation  -------------------------------------
----------------------------------------------------------------------

   vcc         <= (others => '1');
   gnd         <= (others => '0');
   cgi.pllctrl <= "00";
   cgi.pllrst  <= rstraw;

   cgi.pllref  <= '0';

   clk_pad : clkpad
      generic map (tech => clktech, level => ttl)
      port map (clk, lclk);

   pci_clk_pad : clkpad
      generic map (tech => clktech, level => pci33)
      port map (pci_clk, lpci_clk);

   clkgen0 : clkgen        -- clock generator
      generic map (
         tech        => clktech,
         clk_mul     => CFG_CLKMUL,
         clk_div     => CFG_CLKDIV,
         sdramen     => CFG_SDEN,
         noclkfb     => CFG_CLK_NOFB,
         pcien       => CFG_PCI,
         pcidll      => CFG_PCIDLL,
         pcisysclk   => CFG_PCISYSCLK)
      port map (
         clkin       => lclk,
         pciclkin    => lpci_clk,
         clk         => clki,
         clkn        => open,
         clk2x       => open,
         sdclk       => open,
         pciclk      => pciclk,
         cgi         => cgi,
         cgo         => cgo);

   rst0: rstgen             -- reset generator
      -- generic map (
      --   acthigh     => 0);
      port map(
         rstin       => resetn,
         clk         => clki,
         clklock     => cgo.clklock,
         rstout      => rstn,
         rstoutraw   => rstraw);

----------------------------------------------------------------------
---  AHB CONTROLLER --------------------------------------------------
----------------------------------------------------------------------
   ahb0: ahbctrl           -- AHB arbiter/multiplexer
      generic map (
        defmast      => CFG_DEFMST,
        split        => CFG_SPLIT,
        rrobin       => CFG_RROBIN,
        -- timeout      => 0,
        ioaddr       => CFG_AHBIO,
        ioen         => CFG_SDCTRL,
        nahbs        => 8,
        nahbm        => 8)
        -- iomask       => 16#fff#,
        -- cfgaddr      => 16#ff0#,
        -- cfgmask      => 16#ff0#,
      port map(
        rst          => rstn,
        clk          => clki,
        msti         => ahbmi,
        msto         => ahbmo,
        slvi         => ahbsi,
        slvo         => ahbso);

----------------------------------------------------------------------
---  LEON3 processor and DSU -----------------------------------------
----------------------------------------------------------------------

  l3 : if CFG_LEON3 = 1 generate
    cpu : for i in 0 to CFG_NCPU-1 generate
        u0: leon3s           -- LEON3 processor
           generic map(
              hindex         => i,
              fabtech        => fabtech,
              memtech        => memtech,
              nwindows       => CFG_NWIN,
              dsu            => CFG_DSU,
              fpu            => CFG_FPU,
              v8             => CFG_V8,
              cp             => 0,
              mac            => CFG_MAC,
              pclow          => pclow,
              smp            => CFG_NCPU-1,
              nwp            => CFG_NWP,
              icen           => CFG_ICEN,
              irepl          => CFG_IREPL,
              isets          => CFG_ISETS,
              ilinesize      => CFG_ILINE,
              isetsize       => CFG_ISETSZ,
              isetlock       => CFG_ILOCK,
              dcen           => CFG_DCEN,
              drepl          => CFG_DREPL,
              dsets          => CFG_DSETS,
              dlinesize      => CFG_DLINE,
              dsetsize       => CFG_DSETSZ,
              dsetlock       => CFG_DLOCK,
              dsnoop         => CFG_DSNOOP,
              ilram          => CFG_ILRAMEN,
              ilramsize      => CFG_ILRAMSZ,
              ilramstart     => CFG_ILRAMADDR,
              dlram          => CFG_DLRAMEN,
              dlramsize      => CFG_DLRAMSZ,
              dlramstart     => CFG_DLRAMADDR,
              mmuen          => CFG_MMUEN,
              itlbnum        => CFG_ITLBNUM,
              dtlbnum        => CFG_DTLBNUM,
              tlb_type       => CFG_TLB_TYPE,
              TLB_REP        => CFG_TLB_REP,
              lddel          => CFG_LDDEL,
              disas          => disas,
              tbuf           => CFG_ITBSZ,
              pwd            => CFG_PWD)
           port map(
              clk            => clki,
              rstn           => rstn,
              ahbi           => ahbmi,
              ahbo           => ahbmo(i),
              ahbsi          => ahbsi,
              ahbso          => ahbso,
              irqi           => irqi(i),
              irqo           => irqo(i),
              dbgi           => dbgi(i),
              dbgo           => dbgo(i));
    end generate;

    errorn_pad : odpad
       generic map (tech => padtech)
      port map (errorn, dbgo(0).error);

    dcomgen : if CFG_DSU = 1 generate
      dsu0: dsu3                 -- LEON3 Debug Support Unit
         generic map(
            hindex         => 2,
            haddr          => 16#900#,
            hmask          => 16#F00#,
            ncpu           => CFG_NCPU,
            tbits          => 30,
            tech           => memtech,
            irq            => 0,
            kbytes         => CFG_ATBSZ)
         port map(
            rst            => rstn,
            clk            => clki,
            ahbmi          => ahbmi,
            ahbsi          => ahbsi,
            ahbso          => ahbso(2),
            dbgi           => dbgo,
            dbgo           => dbgi,
            dsui           => dsui,
            dsuo           => dsuo);

      dsuen_pad : inpad
         generic map (tech => padtech)
         port map (dsuen, dsui.enable);
      dsubre_pad : inpad
         generic map (tech => padtech)
         port map (dsubre, dsui.break);
      dsuact_pad : outpad
         generic map (tech => padtech)
         port map (dsuact, dsuo.active);

    end generate;
  end generate;

  nodsu : if CFG_DSU = 0 generate
      ahbso(2) <= ahbs_none; dsuo.tstop <= '0'; dsuo.active <= '0';
  end generate;


  ahbuart0 : if CFG_AHB_UART = 1 generate
      dcom0: ahbuart       -- Debug UART
         generic map(
             hindex        => CFG_NCPU,
             pindex        => 7,
             paddr         => 7)
             --pmask         => 16#fff#,
             --debug         => 0)
         port map(
             rst           => rstn,
             clk           => clki,
             uarti         => dui,
             uarto         => duo,
             apbi          => apbi,
             apbo          => apbo(7),
             ahbi          => ahbmi,
             ahbo          => ahbmo(CFG_NCPU));

      dsurx_pad : inpad
         generic map (tech => padtech)
         port map (dsurx, dui.rxd);
      dsutx_pad : outpad
         generic map (tech => padtech)
         port map (dsutx, duo.txd);

   end generate;

----------------------------------------------------------------------
---  Memory controllers ----------------------------------------------
----------------------------------------------------------------------

   mg1 : if CFG_SRCTRL = 1 generate  -- 32-bit PROM/SRAM controller
      sr0: srctrl
         generic map(
             hindex     => 0,
             --romaddr    => 0,
             --rommask    => 16#ff0#,
             ramaddr    => 16#400#,
             --rammask    => 16#ff0#,
             ramws      => CFG_SRCTRL_RAMWS,
             romws      => CFG_SRCTRL_PROMWS,
             rmw        => 0,
             prom8en    => 1,
             oepol      => 1)
         port map(
             rst        => rstn,
             clk        => clki,
             ahbsi      => ahbsi,
             ahbso      => ahbso(0),
             sri        => memi,
             sro        => memo,
             sdo        => sdo3);
   end generate;

   sd1 : if CFG_SDCTRL = 1 generate
         sdc : sdctrl
            generic map(
                hindex  => 3,
                haddr   => 16#600#,
                hmask   => 16#E00#,
                ioaddr  => 1,
                -- iomask  => 16#fff#,
                -- wprot   => 0,
                invclk  => CFG_INVCLK,
                fast    => 0,
                pwron   => 0,
                sdbits  => sdbits,
                oepol   => 1)
            port map(
                rst     => rstn,
                clk     => clki,
                ahbsi   => ahbsi,
                ahbso   => ahbso(3),
                sdi     => sdi,
                sdo     => sdo2);

         --sdclk_pad : outpad
         --   generic map (tech => padtech)
         --   port map (sdclk, sdclkl);

         sa_pad : outpadv
            generic map (width => 15, tech => padtech)
            port map (sa(14 downto 0), sdo2.address);
         sa(15) <= '0';

         sd_pad : iopadvv
            generic map (width => 32, tech => padtech, oepol => 1)
            port map (sd(31 downto 0), sdo2.data(31 downto 0),
               sdo2.vbdrive, sdi.data(31 downto 0));

         byteenable_pads : outpadv
            generic map (width =>4, tech => padtech)
            port map (ramben, memo.mben);

         sdwen_pad : outpad
            generic map (tech => padtech)
            port map (sdwen, sdo2.sdwen);
         sdcsn_pad : outpadv
            generic map (width =>2, tech => padtech)
            port map (sdcsn, sdo2.sdcsn);
         sdras_pad : outpad
            generic map (tech => padtech)
            port map (sdrasn, sdo2.rasn);
         sdcas_pad : outpad
            generic map (tech => padtech)
            port map (sdcasn, sdo2.casn);
         sddqm_pad : outpadv
            generic map (width =>8, tech => padtech)
            port map (sddqm, sdo2.dqm);
   end generate;

   mg2 : if CFG_MCTRL_LEON2 = 1 generate   -- LEON2 memory controller
      sr1: mctrl
         generic map(
            hindex      => 0,
            pindex      => 0,
            --romaddr     => 16#000#,
            --rommask     => 16#E00#,
            --ioaddr      => 16#200#,
            --iomask      => 16#E00#,
            --ramaddr     => 16#400#,
            --rammask     => 16#C00#,
            paddr       => 0,
            --pmask       => 16#fff#,
            --wprot       => 0,
            invclk      => 0,
            fast        => 0,
            --romasel     => 28,
            --sdrasel     => 30,
            srbanks     => 4,
            ram8        => 1,
            ram16       => 1,
            sden        => CFG_MCTRL_SDEN,
            sepbus      => 1,
            sdbits      => sdbits,
            oepol       => 1)
         port map(
            rst         => rstn,
            clk         => clki,
            memi        => memi,
            memo        => memo,
            ahbsi       => ahbsi,
            ahbso       => ahbso(0),
            apbi        => apbi,
            apbo        => apbo(0),
            wpo         => wpo,
            sdo         => sdo);

         brdyn_pad : inpad generic map (tech => padtech) port map (brdyn, memi.brdyn);
         bexcn_pad : inpad generic map (tech => padtech) port map (bexcn, memi.bexcn);

         sdpads : if CFG_SDEN = 1 generate     -- SDRAM controller
            sd2 : if CFG_MCTRL_SEPBUS = 1 generate
               sa_pad : outpadv generic map (width => 15)
                  port map (sa(14 downto 0), memo.sa);
               sa(15) <= '0';
               sd_pad : iopadvv
                 generic map (tech => padtech, width => 32, oepol => 1)
                 port map (
                   sd(31 downto 0),
                   memo.sddata(31 downto 0),
                   memo.svbdrive(31 downto 0),
                   memi.sd(31 downto 0));
               sd2 : if CFG_MCTRL_SD64 = 1 generate
                 sd_pad2 : iopadvv
                   generic map (tech => padtech, width => 32, oepol => 1)
                   port map (
                     sd(63 downto 32),
                     memo.sddata(63 downto 32),
                     memo.svbdrive(63 downto 32),
                     memi.sd(63 downto 32));
               end generate;
            end generate;

         sdwen_pad : outpad
            generic map (tech => padtech)
            port map (sdwen, sdo.sdwen);
         sdras_pad : outpad
            generic map (tech => padtech)
            port map (sdrasn, sdo.rasn);
         sdcas_pad : outpad
            generic map (tech => padtech)
            port map (sdcasn, sdo.casn);
         sddqm_pad : outpadv
            generic map (width =>8, tech => padtech)
         port map (sddqm, sdo.dqm);

         sdcsn_pad : outpadv generic map (width =>2, tech => padtech)
         port map (sdcsn, sdo.sdcsn);
      end generate;
   end generate;

   --dummy pads for cb signals. used in ft version
   cbout <= (others => '0');

   cb_pad : iopadv
      generic map(width => 8, tech => padtech, oepol => 0)
      port map(cb, cbout, vcc(0), cbin);


   nosd0 : if (CFG_SDEN = 0) generate     -- no SDRAM controller
      --sdclk_pad : outpad
      --   generic map (tech => padtech)
      --   port map (sdclk, sdclkl);
      sdcsn_pad : outpadv
         generic map (width =>2, tech => padtech)
         port map (sdcsn, sdo3.sdcsn);
   end generate;

   memi.writen <= '1';
   memi.wrn    <= "1111";
   memi.bwidth <= "00";

   mg0 : if (CFG_MCTRL_LEON2 + CFG_SRCTRL) = 0 generate  -- no prom/sram controller
      rams_pad : outpadv
         generic map (width => 5, tech => padtech)
         port map (ramsn, vcc);
      roms_pad : outpadv
         generic map (width => 2, tech => padtech)
         port map (romsn, vcc(1 downto 0));
   end generate;

   mgpads : if (CFG_MCTRL_LEON2 + CFG_SRCTRL) /= 0 generate  -- prom/sram controller
      addr_pad : outpadv
         generic map (width => 28, tech => padtech)
         port map (address, memo.address(27 downto 0));
      rams_pad : outpadv
         generic map (width => 5, tech => padtech)
         port map (ramsn, memo.ramsn(4 downto 0));
      roms_pad : outpadv
         generic map (width => 2, tech => padtech)
         port map (romsn, memo.romsn(1 downto 0));
      oen_pad  : outpad
         generic map (tech => padtech)
         port map (oen, memo.oen);
      rwen_pad : outpadv
         generic map (width => 4, tech => padtech)
         port map (rwen, memo.wrn);
      roen_pad : outpadv
         generic map (width => 5, tech => padtech)
         port map (ramoen, memo.ramoen(4 downto 0));
      wri_pad  : outpad
         generic map (tech => padtech)
         port map (writen, memo.writen);
      read_pad : outpad
         generic map (tech => padtech)
         port map (read, memo.read);
      iosn_pad : outpad
         generic map (tech => padtech)
         port map (iosn, memo.iosn);
      byteenable_pads : outpadv
         generic map (width =>4, tech => padtech)
         port map (ramben, memo.mben);

      bdr : for i in 0 to 3 generate
         data_pad : iopadvv
            generic map (tech => padtech, width => 8, oepol => 1)
            port map (
         data(31-i*8 downto 24-i*8),
         memo.data(31-i*8 downto 24-i*8),
         memo.vbdrive(31-i*8 downto 24-i*8),
         memi.data(31-i*8 downto 24-i*8));
      end generate;
   end generate;

----------------------------------------------------------------------
---  APB Bridge and various periherals -------------------------------
----------------------------------------------------------------------
   apb0: apbctrl              -- AHB/APB bridge
   generic map(
      hindex   => 1,
      haddr    => CFG_APBADDR)
      -- hmask    => 16#fff#
   port map(
      rst      => rstn,
      clk      => clki,
      ahbi     => ahbsi,
      ahbo     => ahbso(1),
      apbi     => apbi,
      apbo     => apbo);

   ua1 : if CFG_UART1_ENABLE /= 0 generate
      uart1 : apbuart         -- UART 1
         generic map(
            pindex      => 1,
            paddr       => 1,
            --pmask       => 16#fff#,
            console     => dbguart,
            pirq        => 2,
            --parity      => 0,
            --flow        => 0,
            fifosize    => CFG_UART1_FIFO)
         port map(
            rst         => rstn,
            clk         => clki,
            apbi        => apbi,
            apbo        => apbo(1),
            uarti       => u1i,
            uarto       => u1o);
      u1i.rxd     <= rxd(1);
      u1i.ctsn    <= ctsn(1);
      u1i.extclk  <= '0';
      txd(1)      <= u1o.txd;
      rtsn(1)     <= u1o.rtsn;
   end generate;

   ua2 : if CFG_UART2_ENABLE /= 0 generate
      uart2 : apbuart           -- UART 2
         generic map(
            pindex      => 9,
            paddr       => 9,
            --pmask       => 16#fff#,
            console     => dbguart,
            pirq        => 3,
            --parity      => 0,
            --flow        => 0,
            fifosize    => CFG_UART2_FIFO)
         port map(
            rst         => rstn,
            clk         => clki,
            apbi        => apbi,
            apbo        => apbo(9),
            uarti       => u2i,
            uarto       => u2o);

      u2i.rxd     <= rxd(2);
      u2i.ctsn    <= ctsn(2);
      u2i.extclk  <= '0';
      txd(2)      <= u2o.txd;
      rtsn(2)     <= u2o.rtsn;
   end generate;

   irqctrl : if CFG_IRQ3_ENABLE /= 0 generate  -- interrupt controller
      irqctrl0: irqmp
         generic map(
            pindex      => 2,
            paddr       => 2,
            --pmask       => 16#fff#,
            ncpu        => CFG_NCPU)
         port map(
            rst         => rstn,
            clk         => clki,
            apbi        => apbi,
            apbo        => apbo(2),
            irqi        => irqo,
            irqo        => irqi);
   end generate;

   irq3 : if CFG_IRQ3_ENABLE = 0 generate
      x : for i in 0 to CFG_NCPU-1 generate
         irqi(i).irl <= "0000";
      end generate;
   end generate;

   gpt : if CFG_GPT_ENABLE /= 0 generate     -- timer unit
      timer0: gptimer
         generic map(
             pindex     => 3,
             paddr      => 3,
             -- pmask      => 16#fff#,
             pirq       => CFG_GPT_IRQ,
             sepirq     => CFG_GPT_SEPIRQ,
             sbits      => CFG_GPT_SW,
             ntimers    => CFG_GPT_NTIM,
             nbits      => CFG_GPT_TW)
         port map(
             rst        => rstn,
             clk        => clki,
             apbi       => apbi,
             apbo       => apbo(3),
             gpti       => gpti,
             gpto       => open);

      gpti.dhalt  <= dsuo.tstop;
      gpti.extclk <= '0';
   end generate;

   gpio0 : if CFG_GRGPIO_ENABLE /= 0 generate     -- GPIO unit
      grgpio0: grgpio
         generic map(
             pindex     => 8,
             paddr      => 8,
             -- pmask      => 16#fff#,
             imask      => CFG_GRGPIO_IMASK,
             nbits      => 16,
             oepol      => 1)
         port map(
             rst        => rstn,
             clk        => clki,
             apbi       => apbi,
             apbo       => apbo(8),
             gpioi      => gpioi,
             gpioo      => gpioo);

      pio_pads : for i in 0 to 15 generate
        pio_pad : iopad generic map (tech => padtech, oepol => 1)
            port map (gpio(i), gpioo.dout(i), gpioo.oen(i), gpioi.din(i));
      end generate;
   end generate;

-----------------------------------------------------------------------
---  PCI   ------------------------------------------------------------
-----------------------------------------------------------------------

   pp : if CFG_PCI /= 0 generate
      pci_gr0 : if CFG_PCI = 1 generate      -- simple target-only
         pci_gr0: pci_target
            generic map(
               hindex      => CFG_NCPU+CFG_AHB_UART,
               -- abits       => 21,
               device_id   => CFG_PCIDID,
               vendor_id   => CFG_PCIVID,
               oepol       => 1)
               -- nsync       => 1)
            port map(
               rst         => rstn,
               clk         => clki,
               pciclk      => pciclk,
               pcii        => pcii,
               pcio        => pcio,
               ahbmi       => ahbmi,
               ahbmo       => ahbmo(CFG_NCPU+CFG_AHB_UART));
      end generate;

      pci_mtf0 : if CFG_PCI = 2 generate     -- master/target with fifo
         pci0: pci_mtf
            generic map(
                memtech    => memtech,
                hmstndx    => CFG_NCPU+CFG_AHB_UART,
                dmamst     => NAHBMST,
                --readpref   => 0,
                --abits      => 21,
                --dmaabits   => 26,
                fifodepth  => log2(CFG_PCIDEPTH),
                device_id  => CFG_PCIDID,
                vendor_id  => CFG_PCIVID,
                --master     => 1;
                hslvndx    => 4,
                pindex     => 6,
                paddr      => 6,
                --pmask      => 16#fff#,
                haddr      => 16#E00#,
                --hmask      => 16#F00#,
                ioaddr     => 16#400#,
                nsync      => 2,
                oepol      => 1)
             port map(
                rst        => rstn,
                clk        => clki,
                pciclk     => pciclk,
                pcii       => pcii,
                pcio       => pcio,
                apbi       => apbi,
                apbo       => apbo(6),
                ahbmi      => ahbmi,
                ahbmo      => ahbmo(CFG_NCPU+CFG_AHB_UART),
                ahbsi      => ahbsi,
                ahbso      => ahbso(4));
      end generate;

      pci_mtf1 : if CFG_PCI = 3 generate  -- master/target with fifo and DMA
         dma: pcidma
            generic map(
               memtech     => memtech,
               dmstndx     => CFG_NCPU+CFG_AHB_UART+1,
               dapbndx     => 5,
               dapbaddr    => 5,
               --dapbmask    => 16#fff#,
               blength     => blength,
               mstndx      => CFG_NCPU+CFG_AHB_UART,
               --abits       => 21,
               --dmaabits    => 26,
               fifodepth   => log2(fifodepth),
               device_id   => CFG_PCIDID,
               vendor_id   => CFG_PCIVID,
               slvndx      => 4,
               apbndx      => 4,
               apbaddr     => 4,
               --apbmask     => 16#fff#,
               haddr       => 16#E00#,
               --hmask       => 16#F00#,
               ioaddr      => 16#800#,
               nsync       => 1)
            port map(
               rst         => rstn,
               clk         => clki,
               pciclk      => pciclk,
               pcii        => pcii,
               pcio        => pcio,
               dapbo       => apbo(5),
               dahbmo      => ahbmo(CFG_NCPU+CFG_AHB_UART+1),
               apbi        => apbi,
               apbo        => apbo(4),
               ahbmi       => ahbmi,
               ahbmo       => ahbmo(CFG_NCPU+CFG_AHB_UART),
               ahbsi       => ahbsi,
               ahbso       => ahbso(4));
      end generate;

      pci_trc0 : if CFG_PCITBUFEN /= 0 generate  -- PCI trace buffer
         pt0: pcitrace
            generic map(
               depth       => (6 + log2(CFG_PCITBUF/256)),
               --iregs       => 1,
               memtech     => memtech,
               pindex      => 11,
               paddr       => 16#100#,
               pmask       => 16#f00#)
            port map(
               rst         => rstn,
               clk         => clki,
               pciclk      => pciclk,
               pcii        => pcii,
               apbi        => apbi,
               apbo        => apbo(11));
      end generate;

      pcia0 : if CFG_PCI_ARB = 1 generate   -- PCI arbiter
         pciarb0: pciarb
            generic map(
               pindex      => 10,
               paddr       => 10,
               --pmask       => 16#FFF#,
               nb_agents   => 8,
               apb_en      => CFG_PCI_ARBAPB)
            port map(
               clk         => pciclk,
               rst_n       => pcii.rst,
               req_n       => pci_arb_req_n,
               frame_n     => pcii.frame,
               gnt_n       => pci_arb_gnt_n,
               pclk        => clki,
               prst_n      => rstn,
               apbi        => apbi,
               apbo        => apbo(10));

         --pgnt_pad : outpadv
         --   generic map (tech => padtech, width => 8)
         --   port map (pci_arb_gnt, pci_arb_gnt_n);
         preq_pad : inpadv
            generic map (tech => padtech, width => 8)
            port map (pci_arb_req, pci_arb_req_n);
      end generate;

      pcipads0 : pcipads      -- PCI pads
         generic map (
            padtech     => padtech,
            oepol       => 1)
         port map (
            pci_rst     => pci_rst,
            pci_gnt     => pci_gnt,
            pci_idsel   => pci_idsel,
            pci_lock    => pci_lock,
            pci_ad      => pci_ad(31 downto 0),
            pci_cbe     => pci_cbe(3 downto 0),
            pci_frame   => pci_frame,
            pci_irdy    => pci_irdy,
            pci_trdy    => pci_trdy,
            pci_devsel  => pci_devsel,
            pci_stop    => pci_stop,
            pci_perr    => pci_perr,
            pci_par     => pci_par,
            pci_req     => pci_req,
            pci_serr    => pci_serr,
            pci_host    => pci_host,
            pci_66      => pci_66,
            pcii        => pcii,
            pcio        => pcio);
   end generate;

-----------------------------------------------------------------------
---  AHB RAM ----------------------------------------------------------
-----------------------------------------------------------------------
   ocram : if CFG_AHBRAMEN = 1 generate
      ahbram0: ahbram
         generic map(
            hindex   => 7,
            haddr    => CFG_AHBRADDR,
            hmask    => 16#fff#,
            tech     => CFG_MEMTECH,
            kbytes   => CFG_AHBRSZ)
         port map(
            rst      => rstn,
            clk      => clki,
            ahbsi    => ahbsi,
            ahbso    => ahbso(7));
   end generate;

-----------------------------------------------------------------------
---  Boot message  ----------------------------------------------------
-----------------------------------------------------------------------

-- pragma translate_off
   x : report_version
      generic map (
         msg1 => "LEON3 GR-CPCI-AX Demonstration design",
         msg2 => "GRLIB Version " & tost(LIBVHDL_VERSION/1000) & "." & tost((LIBVHDL_VERSION mod 1000)/100)
           & "." & tost(LIBVHDL_VERSION mod 100) & ", build " & tost(LIBVHDL_BUILD),
         msg3 => "Target technology: " & tech_table(fabtech) &
                 ",  memory library: " & tech_table(memtech),
         mdel => 1);
-- pragma translate_on
end;
