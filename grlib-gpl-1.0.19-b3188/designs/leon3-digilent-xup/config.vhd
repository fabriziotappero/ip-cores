-----------------------------------------------------------------------------
-- LEON3 Demonstration design test bench configuration
-- Copyright (C) 2004 Jiri Gaisler, Gaisler Research
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
-- GNU General Public License for more details.
------------------------------------------------------------------------------


library techmap;
use techmap.gencomp.all;

package config is


-- Technology and synthesis options
  constant CFG_FABTECH : integer := virtex2;
  constant CFG_MEMTECH : integer := virtex2;
  constant CFG_PADTECH : integer := virtex2;
  constant CFG_NOASYNC : integer := 0;
  constant CFG_SCAN : integer := 0;

-- Clock generator
  constant CFG_CLKTECH : integer := virtex2;
  constant CFG_CLKMUL : integer := (13);
  constant CFG_CLKDIV : integer := (20);
  constant CFG_OCLKDIV : integer := 2;
  constant CFG_PCIDLL : integer := 0;
  constant CFG_PCISYSCLK: integer := 0;
  constant CFG_CLK_NOFB : integer := 1;

-- LEON3 processor core
  constant CFG_LEON3 : integer := 1;
  constant CFG_NCPU : integer := (1);
  constant CFG_NWIN : integer := (8);
  constant CFG_V8 : integer := 2;
  constant CFG_MAC : integer := 0;
  constant CFG_SVT : integer := 1;
  constant CFG_RSTADDR : integer := 16#00000#;
  constant CFG_LDDEL : integer := (1);
  constant CFG_NWP : integer := (2);
  constant CFG_PWD : integer := 0*2;
  constant CFG_FPU : integer := 0 + 16*0;
  constant CFG_GRFPUSH : integer := 0;
  constant CFG_ICEN : integer := 1;
  constant CFG_ISETS : integer := 2;
  constant CFG_ISETSZ : integer := 8;
  constant CFG_ILINE : integer := 8;
  constant CFG_IREPL : integer := 0;
  constant CFG_ILOCK : integer := 0;
  constant CFG_ILRAMEN : integer := 0;
  constant CFG_ILRAMADDR: integer := 16#8E#;
  constant CFG_ILRAMSZ : integer := 1;
  constant CFG_DCEN : integer := 1;
  constant CFG_DSETS : integer := 2;
  constant CFG_DSETSZ : integer := 4;
  constant CFG_DLINE : integer := 8;
  constant CFG_DREPL : integer := 0;
  constant CFG_DLOCK : integer := 0;
  constant CFG_DSNOOP : integer := 1 + 0 + 4*0;
  constant CFG_DFIXED : integer := 16#0#;
  constant CFG_DLRAMEN : integer := 0;
  constant CFG_DLRAMADDR: integer := 16#8F#;
  constant CFG_DLRAMSZ : integer := 1;
  constant CFG_MMUEN : integer := 1;
  constant CFG_ITLBNUM : integer := 8;
  constant CFG_DTLBNUM : integer := 8;
  constant CFG_TLB_TYPE : integer := 0 + 1*2;
  constant CFG_TLB_REP : integer := 0;
  constant CFG_DSU : integer := 1;
  constant CFG_ITBSZ : integer := 2;
  constant CFG_ATBSZ : integer := 2;
  constant CFG_LEON3FT_EN : integer := 0;
  constant CFG_IUFT_EN : integer := 0;
  constant CFG_FPUFT_EN : integer := 0;
  constant CFG_RF_ERRINJ : integer := 0;
  constant CFG_CACHE_FT_EN : integer := 0;
  constant CFG_CACHE_ERRINJ : integer := 0;
  constant CFG_LEON3_NETLIST: integer := 0;
  constant CFG_DISAS : integer := 0 + 0;
  constant CFG_PCLOW : integer := 2;

-- AMBA settings
  constant CFG_DEFMST : integer := (0);
  constant CFG_RROBIN : integer := 1;
  constant CFG_SPLIT : integer := 0;
  constant CFG_AHBIO : integer := 16#FFF#;
  constant CFG_APBADDR : integer := 16#800#;
  constant CFG_AHB_MON : integer := 0;
  constant CFG_AHB_MONERR : integer := 0;
  constant CFG_AHB_MONWAR : integer := 0;

-- DSU UART
  constant CFG_AHB_UART : integer := 1;

-- JTAG based DSU interface
  constant CFG_AHB_JTAG : integer := 1;

-- Ethernet DSU
  constant CFG_DSU_ETH : integer := 1 + 0;
  constant CFG_ETH_BUF : integer := 2;
  constant CFG_ETH_IPM : integer := 16#C0A8#;
  constant CFG_ETH_IPL : integer := 16#0033#;
  constant CFG_ETH_ENM : integer := 16#00007A#;
  constant CFG_ETH_ENL : integer := 16#CC0009#;

-- DDR controller
  constant CFG_DDRSP : integer := 1;
  constant CFG_DDRSP_INIT : integer := 1;
  constant CFG_DDRSP_FREQ : integer := (90);
  constant CFG_DDRSP_COL : integer := (9);
  constant CFG_DDRSP_SIZE : integer := (256);
  constant CFG_DDRSP_RSKEW : integer := (0);

-- AHB ROM
  constant CFG_AHBROMEN : integer := 1;
  constant CFG_AHBROPIP : integer := 1;
  constant CFG_AHBRODDR : integer := 16#000#;
  constant CFG_ROMADDR : integer := 16#100#;
  constant CFG_ROMMASK : integer := 16#E00# + 16#100#;

-- AHB RAM
  constant CFG_AHBRAMEN : integer := 0;
  constant CFG_AHBRSZ : integer := 1;
  constant CFG_AHBRADDR : integer := 16#A00#;

-- Gaisler Ethernet core
  constant CFG_GRETH : integer := 1;
  constant CFG_GRETH1G : integer := 0;
  constant CFG_ETH_FIFO : integer := 32;

-- UART 1
  constant CFG_UART1_ENABLE : integer := 1;
  constant CFG_UART1_FIFO : integer := 8;

-- LEON3 interrupt controller
  constant CFG_IRQ3_ENABLE : integer := 1;

-- Modular timer
  constant CFG_GPT_ENABLE : integer := 1;
  constant CFG_GPT_NTIM : integer := (2);
  constant CFG_GPT_SW : integer := (8);
  constant CFG_GPT_TW : integer := (32);
  constant CFG_GPT_IRQ : integer := (8);
  constant CFG_GPT_SEPIRQ : integer := 1;
  constant CFG_GPT_WDOGEN : integer := 0;
  constant CFG_GPT_WDOG : integer := 16#0#;

-- VGA and PS2/ interface
  constant CFG_KBD_ENABLE : integer := 1;
  constant CFG_VGA_ENABLE : integer := 0;
  constant CFG_SVGA_ENABLE : integer := 1;

-- GRLIB debugging
  constant CFG_DUART : integer := 0;


end;
