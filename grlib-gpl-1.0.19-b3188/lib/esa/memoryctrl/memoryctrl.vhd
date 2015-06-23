----------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2004 GAISLER RESEARCH
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  See the file COPYING for the full details of the license.
--
------------------------------------------------------------------------------
-- Entity: 	memctrl
-- File:	memctrl.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	Memory controller package
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
library gaisler;
use gaisler.memctrl.all;

package memoryctrl is

component mctrl
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
    syncrst   : integer := 0;
    pageburst : integer := 0;
    mobile    : integer := 0
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
    sdo       : out sdram_out_type
  );

end component; 

end;
