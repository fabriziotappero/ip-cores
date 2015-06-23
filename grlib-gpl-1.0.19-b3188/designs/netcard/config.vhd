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

-- Clock generator
  constant CFG_CLKTECH : integer := virtex2;
  constant CFG_CLKMUL : integer := (2);
  constant CFG_CLKDIV : integer := (2);
  constant CFG_PCIDLL : integer := 0;
  constant CFG_PCISYSCLK: integer := 0;
  constant CFG_CLK_NOFB : integer := 1;

-- AMBA settings
  constant CFG_DEFMST : integer := (0);
  constant CFG_RROBIN : integer := 1;
  constant CFG_SPLIT : integer := 0;
  constant CFG_AHBIO : integer := 16#FFF#;
  constant CFG_APBADDR : integer := 16#800#;

-- DSU UART
  constant CFG_AHB_UART : integer := 1;

-- JTAG based DSU interface
  constant CFG_AHB_JTAG : integer := 0;

-- AHB RAM
  constant CFG_AHBRAMEN : integer := 0;
  constant CFG_AHBRSZ : integer := 1;
  constant CFG_AHBRADDR : integer := 16#A00#;

-- Gaisler Ethernet core
  constant CFG_GRETH : integer := 1;
  constant CFG_GRETH1G : integer := 0;
  constant CFG_ETH_FIFO : integer := 32;

-- PCI interface
  constant CFG_PCI : integer := 2;
  constant CFG_PCIVID : integer := 16#16E3#;
  constant CFG_PCIDID : integer := 16#0210#;
  constant CFG_PCIDEPTH : integer := 8;
  constant CFG_PCI_MTF : integer := 1;

-- PCI trace buffer
  constant CFG_PCITBUFEN: integer := 1;
  constant CFG_PCITBUF : integer := 256;


end;
