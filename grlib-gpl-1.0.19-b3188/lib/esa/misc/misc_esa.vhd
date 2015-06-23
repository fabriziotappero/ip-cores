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
-----------------------------------------------------------------------------
-- package: 	misc
-- File:	misc.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	Misc cores from LEON2
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
library gaisler;
use gaisler.uart.all;

package misc_esa is

component l2uart
  generic (
    pindex  : integer := 0; 
    paddr   : integer := 0;
    pmask   : integer := 16#fff#;
    console : integer := 0; 
    pirq    : integer := 0
  );
  port (
    rst     : in  std_ulogic;
    clk     : in  std_ulogic;
    apbi    : in  apb_slv_in_type;
    apbo    : out apb_slv_out_type;
    uarti   : in  uart_in_type;
    uarto   : out uart_out_type);
end component; 

end;
