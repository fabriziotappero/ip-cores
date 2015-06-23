------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2003, Gaisler Research
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
--============================================================================--
-- Design unit  : WildCard FPGA (entity and architecture declarations)
--
-- File name    : wildfpga.vhd
--
-- Purpose      : WildCard FPGA design
--
-- Library      : Work
--
-- Authors      : Mr Sandi Alexander Habinc
--                Gaisler Research
--
-- Contact      : mailto:support@gaisler.com
--                http://www.gaisler.com
--
-- Disclaimer   : All information is provided "as is", there is no warranty that
--                the information is correct or suitable for any purpose,
--                neither implicit nor explicit.
--============================================================================--

----------------------------------- Glossary -----------------------------------
--
--  Name Key:
--  =========
--  _AS       : Address Strobe
--  _CE       : Clock Enable
--  _CS       : Chip Select
--  _DS       : Data Strobe
--  _EN       : Enable
--  _OE       : Output Enable
--  _RD       : Read Select
--  _WE       : Write Enable
--  _WR       : Write Select
--  _d[d...]  : Delayed (registered) signal (each 'd' denotes one
--              level of delay)
--  _n        : Active low signals (must be last part of name)
--
--  Port Name                      Dir  Description
--  ============================   ===  ================================
--  Clocks_F_Clk                    I   Frequency synthesizer clock
--  Clocks_M_Clk                    I   Memory clock
--  Clocks_P_Clk                    I   Processor clock
--  Clocks_K_Clk                    I   LAD-bus clock
--  Clocks_IO_Clk                   I   External I/O connector clock
--  Clocks_M_Clk_Out_Pe             O   M_Clk to the PE
--  Clocks_M_Clk_Out_CB_Ctrl        O   M_Clk to the CardBus controller
--  Clocks_M_Clk_Out_Right_Mem      O   M_Clk to the right memory bank
--  Clocks_M_Clk_Out_Left_Mem       O   M_Clk to the left memory bank
--  Clocks_P_Clk_Out_Pe             O   P_Clk to the PE
--  Clocks_P_Clk_Out_CB_Ctrl        O   P_Clk to the CardBus controller
--  Reset_Reset                     I   Global PE reset
--  Audio_Audio                     O   Pulse-width modulated audio pad
--  LAD_Bus_Addr_Data               B   LAD-bus shared address/data bus
--  LAD_Bus_AS_n                    I   LAD-bus address strobe
--  LAD_Bus_DS_n                    I   LAD-bus data strobe
--  LAD_Bus_WR_n                    I   LAD-bus write select
--  LAD_Bus_CS_n                    I   LAD-bus chip select
--  LAD_Bus_Reg_n                   I   LAD-bus register select
--  LAD_Bus_Ack_n                   O   LAD-bus acknowledge strobe
--  LAD_Bus_Int_Req_n               O   LAD-bus interrupt request
--  LAD_Bus_DMA_0_Data_OK_n         O   LAD-bus DMA chan 0 data OK flag
--  LAD_Bus_DMA_0_Burst_OK_n        O   LAD-bus DMA chan 0 burst OK flag
--  LAD_Bus_DMA_1_Data_OK_n         O   LAD-bus DMA chan 1 data OK flag
--  LAD_Bus_DMA_1_Burst_OK_n        O   LAD-bus DMA chan 1 burst OK flag
--  LAD_Bus_Reg_Data_OK_n           O   LAD-bus reg space data OK flag
--  LAD_Bus_Reg_Burst_OK_n          O   LAD-bus reg space burst OK flag
--  LAD_Bus_Force_K_Clk_n           O   LAD-bus K_Clk forced-run select
--  LAD_Bus_Reserved                -   Reserved for future use
--  Left_Mem_Addr                   O   Left memory address bus
--  Left_Mem_Data                   B   Left memory data bus
--  Left_Mem_Byte_WR_n              O   Left memory byte write select
--  Left_Mem_CS_n                   O   Left memory chip select
--  Left_Mem_CE_n                   O   Left memory clock enable
--  Left_Mem_WE_n                   O   Left memory write enable
--  Left_Mem_OE_n                   O   Left memory output enable
--  Left_Mem_Sleep_EN               O   Left memory sleep enable
--  Left_Mem_Load_EN_n              O   Left memory load enable
--  Left_Mem_Burst_Mode             O   Left memory burst mode select
--  Right_Mem_Addr                  O   Right memory address bus
--  Right_Mem_Data                  B   Right memory data bus
--  Right_Mem_Byte_WR_n             O   Right memory byte write select
--  Right_Mem_CS_n                  O   Right memory chip select
--  Right_Mem_CE_n                  O   Right memory clock enable
--  Right_Mem_WE_n                  O   Right memory write enable
--  Right_Mem_OE_n                  O   Right memory output enable
--  Right_Mem_Sleep_EN              O   Right memory sleep enable
--  Right_Mem_Load_EN_n             O   Right memory load enable
--  Left_Mem_Burst_Mode             O   Right memory burst mode select
--  Left_IO                         B   Left external I/O connector
--  Right_IO                        B   Right external I/O connector
--============================================================================--

library  IEEE;
use      IEEE.Std_Logic_1164.all;

entity WildFpga is
   generic (
      fabtech:                            integer := 1;
      memtech:                            integer := 1;
      padtech:                            integer := 1;
      clktech:                            integer := 1;
      netlist:                            integer := 1);
   port (
      Clocks_F_Clk:                in     std_logic;
      Clocks_M_Clk:                in     std_logic;
      Clocks_P_Clk:                in     std_logic;
      Clocks_K_Clk:                in     std_logic;
      Clocks_IO_Clk:               in     std_logic;

      Clocks_M_Clk_Out_PE:         out    std_logic;
      Clocks_M_Clk_Out_CB_Ctrl:    out    std_logic;
      Clocks_M_Clk_Out_Right_Mem:  out    std_logic;
      Clocks_M_Clk_Out_Left_Mem:   out    std_logic;
      Clocks_P_Clk_Out_PE:         out    std_logic;
      Clocks_P_Clk_Out_CB_Ctrl:    out    std_logic;

      Reset_Reset:                 in     std_logic;
      Audio_Audio:                 out    std_logic;

      LAD_Bus_Addr_Data:           inout  std_logic_vector (31 downto 0);
      LAD_Bus_AS_n:                in     std_logic;
      LAD_Bus_DS_n:                in     std_logic;
      LAD_Bus_WR_n:                in     std_logic;
      LAD_Bus_CS_n:                in     std_logic;
      LAD_Bus_Reg_n:               in     std_logic;
      LAD_Bus_Ack_n:               out    std_logic;
      LAD_Bus_Int_Req_n:           out    std_logic;
      LAD_Bus_DMA_0_Data_OK_n:     out    std_logic;
      LAD_Bus_DMA_0_Burst_OK:      out    std_logic;
      LAD_Bus_DMA_1_Data_OK_n:     out    std_logic;
      LAD_Bus_DMA_1_Burst_OK:      out    std_logic;
      LAD_Bus_Reg_Data_OK_n:       out    std_logic;
      LAD_Bus_Reg_Burst_OK:        out    std_logic;
      LAD_Bus_Force_K_Clk_n:       out    std_logic;
      LAD_Bus_Reserved:            out    std_logic;

      Left_Mem_Addr:               out    std_logic_vector (18 downto 0);
      Left_Mem_Data:               inout  std_logic_vector (35 downto 0);
      Left_Mem_Byte_WR_n:          out    std_logic_vector (3 downto 0);
      Left_Mem_CS_n:               out    std_logic;
      Left_Mem_CE_n:               out    std_logic;
      Left_Mem_WE_n:               out    std_logic;
      Left_Mem_OE_n:               out    std_logic;
      Left_Mem_Sleep_EN:           out    std_logic;
      Left_Mem_Load_EN_n:          out    std_logic;
      Left_Mem_Burst_Mode:         out    std_logic;

      Right_Mem_Addr:              out    std_logic_vector (18 downto 0);
      Right_Mem_Data:              inout  std_logic_vector (35 downto 0);
      Right_Mem_Byte_WR_n:         out    std_logic_vector (3 downto 0);
      Right_Mem_CS_n:              out    std_logic;
      Right_Mem_CE_n:              out    std_logic;
      Right_Mem_WE_n:              out    std_logic;
      Right_Mem_OE_n:              out    std_logic;
      Right_Mem_Sleep_EN:          out    std_logic;
      Right_Mem_Load_EN_n:         out    std_logic;
      Right_Mem_Burst_Mode:        out    std_logic;

      Left_IO:                     inout  std_logic_vector (12 downto 0);
      Right_IO:                    inout  std_logic_vector (12 downto 0));
end entity WildFpga; --=======================================================--

library  IEEE;
use      IEEE.Std_Logic_1164.all;

library  Work;
use      Work.config.all;

library  grlib;
use      grlib.amba.all;

library  gaisler;
use      gaisler.memctrl.all;
use      gaisler.misc.all;
use      gaisler.uart.all;
use      gaisler.leon3.all;
use      gaisler.haps.all;
use      gaisler.wild.all;

library  techmap;
use      techmap.gencomp.all;

architecture RTL of WildFpga is

   -- clock generation
   signal   rst, rstn:       Std_ULogic;

   signal   kclk, clkk, clkkn,  rstkn, rstkraw: Std_ULogic;
   signal   cgik:             clkgen_in_type;
   signal   cgok:             clkgen_out_type;

   signal   fclk, clkf1, clkf, rstfn, rstfraw: Std_ULogic;
   signal   cgif:             clkgen_in_type;
   signal   cgof:             clkgen_out_type;

   signal   vcc, gnd:         Std_ULogic;

   -- gpio
   signal   gpioi:            gpio_in_type;
   signal   gpioo:            gpio_out_type;

   -- uarts
   signal   u1i, u2i:         uart_in_type;
   signal   u1o, u2o:         uart_out_type;

   -- timers
   signal   gpti:             gptimer_in_type;

   -- memory interface
   signal   memir, memil:     memory_in_type;
   signal   memor, memol:     memory_out_type;

   -- LEON3 debug interface
   signal   dbgi:             l3_debug_in_vector(0 to 0);
   signal   dbgo:             l3_debug_out_vector(0 to 0);

   signal   dsui:             dsu_in_type;
   signal   dsuo:             dsu_out_type;

   -- interrupt controller
   signal   irqi:             irq_in_vector(0 to 0);
   signal   irqo:             irq_out_vector(0 to 0);

   -- local address and data bus
   signal   ladi:             lad_in_type;
   signal   lado:             lad_out_type;

   -- amba apb interface
   signal   apbi:             APB_Slv_In_Type;
   signal   apbo:             APB_Slv_Out_Vector := (others => apb_none);
   signal   ahbsi:            AHB_Slv_In_Type;
   signal   ahbso:            AHB_Slv_Out_Vector := (others => ahbs_none);
   signal   ahbmi:            AHB_Mst_In_Type;
   signal   ahbmo:            AHB_Mst_Out_Vector := (others => ahbm_none);

begin

   -----------------------------------------------------------------------------
   -- Reset and Clock generation
   -----------------------------------------------------------------------------
   vcc <= '1';
   gnd <= '0';

   -- Reset input
   rst_pad : inpad
      port map(Reset_Reset, rst);

   rstn <= not rst;


   -- PCI clock domain, 33 MHz, Clk_K
   cgik.pllctrl <= "00";
   cgik.pllrst  <= rstkraw;
   cgik.pllref  <= '0';

   clkk_pad : clkpad
      generic map (tech => padtech)
      port map (Clocks_K_Clk, kclk);

   clkgenk : clkgen                                      -- clock generator
      generic map (0, 2, 2, 0, 0, 0, 0, 0)
      port map (kclk, kclk, clkk, clkkn, open, open, open, cgik, cgok);

   rstgenk : rstgen                                      -- reset generator
      port map (rstn, clkkn, cgok.clklock, rstkn, rstkraw);

   -- Main clock domain, X MHz, Clk_F
   cgif.pllctrl <= "00";
   cgif.pllrst  <= rstfraw;

   clkfk_pad : clkpad
      generic map (tech => padtech)
      port map (Clocks_F_Clk, fclk);

   pllref_pad : clkpad
      generic map (tech => padtech)
      port map (Clocks_M_Clk, cgif.pllref);

   clkgenf : clkgen                                      -- clock generator
      generic map (clktech, 2, 2, 1, 0, 0, 0, 0, 10000, 0)
      port map (fclk, gnd, clkf, open, open, clkf1, open, cgif, cgof);

   rstgenf : rstgen                                      -- reset generator
      port map (rstn, clkf, cgof.clklock, rstfn, rstfraw);


   Clocks_P_Clk_Out_PE_PAD: outpad
      generic map (tech => padtech, slew => 1, strength => 24)
      port map(Clocks_P_Clk_Out_PE, clkf1);

   Clocks_P_Clk_Out_CB_Ctrl_PAD: outpad
      generic map (tech => padtech, slew => 1, strength => 24)
      port map(Clocks_P_Clk_Out_CB_Ctrl, clkf1);

   Clocks_M_Clk_Out_PE_PAD: outpad
      generic map (tech => padtech, slew => 1, strength => 24)
      port map(Clocks_M_Clk_Out_PE, clkf1);

   Clocks_M_Clk_Out_CB_Ctrl_PAD: outpad
      generic map (tech => padtech, slew => 1, strength => 24)
      port map(Clocks_M_Clk_Out_CB_Ctrl, clkf1);

   Clocks_M_Clk_Out_Right_Mem_PAD: outpad
      generic map (tech => padtech, slew => 1, strength => 24)
      port map(Clocks_M_Clk_Out_Right_Mem, clkf1);

   Clocks_M_Clk_Out_Left_Mem_PAD: outpad
      generic map (tech => padtech, slew => 1, strength => 24)
      port map(Clocks_M_Clk_Out_Left_Mem, clkf1);

   -----------------------------------------------------------------------------
   -- AMBA AHB Controller
   -----------------------------------------------------------------------------
   ahb0 : ahbctrl       -- AHB arbiter/multiplexer
      generic map (
         nahbm          => 1+CFG_LEON3,
         nahbs          => 3+CFG_DSU+CFG_AHBRAMEN,
         fpnpen         => 1)
      port map (rstfn, clkf, ahbmi, ahbmo, ahbsi, ahbso);

   -----------------------------------------------------------------------------
   -- LEON3 processor with Debug Support Unit
   -----------------------------------------------------------------------------
   leongen : if CFG_LEON3=1 and CFG_NCPU=1 generate
      u0 : leon3s
         generic map (0, fabtech, memtech,
             CFG_NWIN, CFG_DSU, CFG_FPU, CFG_V8, 0, CFG_MAC, CFG_PCLOW, 0, CFG_NWP,
             CFG_ICEN, CFG_IREPL, CFG_ISETS, CFG_ILINE, CFG_ISETSZ, CFG_ILOCK,
             CFG_DCEN, CFG_DREPL, CFG_DSETS, CFG_DLINE, CFG_DSETSZ, CFG_DLOCK, CFG_DSNOOP,
             CFG_ILRAMEN, CFG_ILRAMSZ, CFG_ILRAMADDR,
             CFG_DLRAMEN, CFG_DLRAMSZ, CFG_DLRAMADDR,
             CFG_MMUEN, CFG_ITLBNUM, CFG_DTLBNUM, CFG_TLB_TYPE, CFG_TLB_REP,
             CFG_LDDEL, CFG_DISAS, CFG_ITBSZ, CFG_PWD, CFG_SVT, CFG_RSTADDR, 0, CFG_DFIXED)
         port map (clkf, rstfn, ahbmi, ahbmo(0), ahbsi, ahbso,
             irqi(0), irqo(0), dbgi(0), dbgo(0));
   end generate;

   dsugen : if CFG_DSU=1 generate
      dsu0 : dsu3
         generic map (hindex => 1, haddr => 16#900#, hmask => 16#F00#,
            ncpu => 1, tbits => 30, tech => memtech, irq => 0, kbytes => CFG_ATBSZ)
         port map (rstfn, clkf, ahbmi, ahbsi, ahbso(1), dbgo, dbgi, dsui, dsuo);

      dsui.enable <= '1'; dsui.break <= '0';
   end generate;

   -----------------------------------------------------------------------------
   -- Local Address and Data Bus to AMBA AHB bus DMA interface
   -----------------------------------------------------------------------------
   wild2ahb0: wild2ahb
      generic map (
         hindex   => CFG_LEON3,
         burst    => 5,
         syncrst  => 1)
      port map(rstkn, clkk, rstfn, clkf, ahbmi, ahbmo(CFG_LEON3), ladi, lado);

   -----------------------------------------------------------------------------
   -- AHB/APB Bridge
   -----------------------------------------------------------------------------
   apb0 : apbctrl       -- AHB/APB bridge
      generic map (
         hindex         => 0,
         haddr          => 16#800#,
         hmask          => 16#FFF#,
         nslaves        => 16)
      port map (rstfn, clkf, ahbsi, ahbso(0), apbi, apbo);

--   apbo(0)  <= apb_none;
--   apbo(1)  <= apb_none;
--   apbo(2)  <= apb_none;
--   apbo(3)  <= apb_none;
--   apbo(4)  <= apb_none;
--   apbo(5)  <= apb_none;
   apbo(6)  <= apb_none;
   apbo(7)  <= apb_none;
   apbo(8)  <= apb_none;
   apbo(9)  <= apb_none;
   apbo(10) <= apb_none;
   apbo(11) <= apb_none;
   apbo(12) <= apb_none;
   apbo(13) <= apb_none;
   apbo(14) <= apb_none;
   apbo(15) <= apb_none;

   -----------------------------------------------------------------------------
   -- Interrupt controller, timer and uart
   -----------------------------------------------------------------------------
   irqctrl0 : irqmp           -- interrupt controller
      generic map (pindex => 0, paddr => 2, ncpu => 1)
      port map (rstfn, clkf, apbi, apbo(0), irqo, irqi);

   timer0: gptimer            -- timers
      generic map (pindex => 1, paddr => 3, pirq => 8, sepirq => 1,
         sbits => 8, ntimers => 2, nbits => 32, wdog => 0)
      port map (rstfn, clkf, apbi, apbo(1), gpti, open);
   gpti.dhalt <= dsuo.tstop; gpti.extclk <= '0';

   uart1: apbuart             -- uart
      generic map (pindex => 2, paddr => 1,  pirq => 2, console => 0, fifosize => 2)
      port map (rstfn, clkf, apbi, apbo(2), u1i, u1o);
      u1i.extclk <= '0'; u1i.ctsn <= '0'; u1i.rxd <= u1o.txd;

   -----------------------------------------------------------------------------
   -- General Purpose Input Output with pads
   -----------------------------------------------------------------------------
   grgpio0: grgpio
      generic map(pindex => 3, paddr => 11, imask => 0, nbits => 27, oepol => 0, syncrst =>0)
      port map(rstfn, clkf, apbi, apbo(3), gpioi, gpioo);

   left_io_pads : for i in 12 downto 0 generate
      left_io_pad : iopad
         generic map (tech => padtech)
         port map (Left_IO(i), gpioo.dout(i+13), gpioo.oen(i+13), gpioi.din(i+13));
   end generate;

   right_io_pads : for i in 12 downto 0 generate
      right_io_pad : iopad
         generic map (tech => padtech)
         port map (Right_IO(i), gpioo.dout(i), gpioo.oen(i), gpioi.din(i));
   end generate;

   -----------------------------------------------------------------------------
   -- Audio pad
   -----------------------------------------------------------------------------
   audio_io_pad : toutpad
      generic map (tech => padtech)
      port map (Audio_Audio, gpioo.dout(26), gpioo.oen(26));

   -----------------------------------------------------------------------------
   -- SSRAM controller - left
   -----------------------------------------------------------------------------
   ssraml : sram_1x1
      generic map (hindex => 1+CFG_DSU, pindex => 4, paddr => 4,
                   romaddr => 16#100#, rommask => 0,
                   ioaddr => 16#200#, iomask => 0,
                   ramaddr => 16#400#, rammask => 16#FFF#,
                   bus16 => netlist, netlist => netlist, tech => 2)
      port map (rstfn, clkf, ahbsi, ahbso(1+CFG_DSU), apbi, apbo(4), memil, memol);

   memil.writen <= '1'; memil.wrn <= "1111"; memil.bwidth <= "10";
   memil.brdyn <= '1'; memil.bexcn <= '1';

   -- ssram pads
   addr_l_pad : outpadv
      generic map (width => 19, tech => padtech, slew => 1)
      port map (Left_Mem_Addr, memol.address(20 downto 2));
   rams_l_pad : outpad
      generic map (tech => padtech, slew => 1)
      port map (Left_Mem_CS_n, memol.ramsn(0));
   oen_l_pad  : outpad
      generic map (tech => padtech, slew => 1)
      port map (Left_Mem_OE_n, memol.oen);
   write_l_pad  : outpad
      generic map (tech => padtech, slew => 1)
      port map (Left_Mem_WE_n, memol.writen);
   rwen_l_pad0 : outpad
      generic map (tech => padtech, slew => 1)
      port map (Left_Mem_Byte_WR_n(0), memol.wrn(3));
   rwen_l_pad1 : outpad
      generic map (tech => padtech, slew => 1)
      port map (Left_Mem_Byte_WR_n(1), memol.wrn(2));
   rwen_l_pad2 : outpad
      generic map (tech => padtech, slew => 1)
      port map (Left_Mem_Byte_WR_n(2), memol.wrn(1));
   rwen_l_pad3 : outpad
      generic map (tech => padtech, slew => 1)
      port map (Left_Mem_Byte_WR_n(3), memol.wrn(0));
   data_l_pads : iopadvv
      generic map (tech => padtech, width => 32, slew => 1)
      port map (Left_Mem_Data(31 downto 0), memol.data(31 downto 0),
                memol.vbdrive(31 downto 0), memil.data(31 downto 0));

   Left_Mem_Sleep_EN             <= '0';
   Left_Mem_Burst_Mode           <= '0';
   Left_Mem_Load_EN_n            <= '0';
   Left_Mem_CE_n                 <= '0';
   Left_Mem_Data(35 downto 32)   <= (others => 'Z');

   -----------------------------------------------------------------------------
   -- SSRAM controller - right
   -----------------------------------------------------------------------------
   ssramr : sram_1x1
      generic map (hindex => 2+CFG_DSU, pindex => 5, paddr => 5,
                   romaddr => 16#300#, rommask => 0,
                   ioaddr => 16#500#, iomask => 0,
                   ramaddr => 16#600#, rammask => 16#FFF#,
                   bus16 => netlist, netlist => netlist, tech => 2)
      port map (rstfn, clkf, ahbsi, ahbso(2+CFG_DSU), apbi, apbo(5), memir, memor);

   memir.writen <= '1'; memir.wrn <= "1111"; memir.bwidth <= "10";
   memir.brdyn <= '1'; memir.bexcn <= '1';

   -- ssram pads
   addr_r_pad : outpadv
      generic map (width => 19, tech => padtech, slew => 1)
      port map (Right_Mem_Addr, memor.address(20 downto 2));
   rams_r_pad : outpad
      generic map (tech => padtech, slew => 1)
      port map (Right_Mem_CS_n, memor.ramsn(0));
   oen_r_pad  : outpad
      generic map (tech => padtech, slew => 1)
      port map (Right_Mem_OE_n, memor.oen);
   write_r_pad  : outpad
      generic map (tech => padtech, slew => 1)
      port map (Right_Mem_WE_n, memor.writen);
   rwen_r_pad0 : outpad
      generic map (tech => padtech, slew => 1)
      port map (Right_Mem_Byte_WR_n(0), memor.wrn(3));
   rwen_r_pad1 : outpad
      generic map (tech => padtech, slew => 1)
      port map (Right_Mem_Byte_WR_n(1), memor.wrn(2));
   rwen_r_pad2 : outpad
      generic map (tech => padtech, slew => 1)
      port map (Right_Mem_Byte_WR_n(2), memor.wrn(1));
   rwen_r_pad3 : outpad
      generic map (tech => padtech, slew => 1)
      port map (Right_Mem_Byte_WR_n(3), memor.wrn(0));
   data_r_pads : iopadvv
      generic map (tech => padtech, width => 32, slew => 1)
      port map (Right_Mem_Data(31 downto 0), memor.data(31 downto 0),
                memor.vbdrive(31 downto 0), memir.data(31 downto 0));

   Right_Mem_Sleep_EN             <= '0';
   Right_Mem_Burst_Mode           <= '0';
   Right_Mem_Load_EN_n            <= '0';
   Right_Mem_CE_n                 <= '0';
   Right_Mem_Data(35 downto 32)   <= (others => 'Z');

   -----------------------------------------------------------------------------
   -- On-chip memory
   -----------------------------------------------------------------------------
   memgen : if CFG_AHBRAMEN=1 generate
      mem0: ahbram
         generic map (hindex => 3+CFG_DSU, haddr => CFG_AHBRADDR, hmask => 16#FFF#,
                      tech => memtech, kbytes => CFG_AHBRSZ)
         port map (rstfn, clkf, ahbsi, ahbso(3+CFG_DSU));
   end generate;

   -----------------------------------------------------------------------------
   -- Local Address and Data Bus pads
   -----------------------------------------------------------------------------
   addr_data_pad : for i in LAD_Bus_Addr_Data'range generate
    ad_pad : iopad
      generic map(
         slew     => 1,
         strength => 24)
      port map(
         pad      => LAD_Bus_Addr_Data(i),
         i        => lado.Addr_Data(i),
         en       => lado.Addr_Data_OE_n(i),
         o        => ladi.Addr_Data(i));
   end generate;

   ladi.AS_n                  <= LAD_Bus_AS_n;
   ladi.DS_n                  <= LAD_Bus_DS_n;
   ladi.WR_n                  <= LAD_Bus_WR_n;
   ladi.CS_n                  <= LAD_Bus_CS_n;
   ladi.Reg_n                 <= LAD_Bus_Reg_n;

   LAD_Bus_Ack_n              <= lado.Ack_n;
   LAD_Bus_Int_Req_n          <= lado.Int_Req_n;
   LAD_Bus_DMA_0_Data_OK_n    <= lado.DMA_0_Data_OK_n;
   LAD_Bus_DMA_0_Burst_OK     <= lado.DMA_0_Burst_OK;
   LAD_Bus_DMA_1_Data_OK_n    <= lado.DMA_1_Data_OK_n;
   LAD_Bus_DMA_1_Burst_OK     <= lado.DMA_1_Burst_OK;
   LAD_Bus_Reg_Data_OK_n      <= lado.Reg_Data_OK_n;
   LAD_Bus_Reg_Burst_OK       <= lado.Reg_Burst_OK;
   LAD_Bus_Force_K_Clk_n      <= lado.Force_K_Clk_n;
   LAD_Bus_Reserved           <= lado.Reserved;

end architecture RTL; --======================================================--
