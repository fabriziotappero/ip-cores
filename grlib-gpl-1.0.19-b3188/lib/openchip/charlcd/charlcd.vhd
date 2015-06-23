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
-- package: 	charlcd
-- File:	charlcd.vhd
-- Author:	Antti Lukats, OpenChip
-- Description:	Character LCD types and components
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;

package charlcd is

type charlcd_in_type is record
  d_in  	: std_logic_vector(7 downto 0);
end record;

type charlcd_out_type is record
  d_out   	: std_logic_vector(7 downto 0);
  d_out_oe   	: std_logic;  
  en	   	: std_logic_vector(3 downto 0);
  rs  	 	: std_logic;  
  r_wn   	: std_logic;  
  backlight_en 	: std_logic;  
  
end record;

component apbcharlcd
  generic (
    pindex  : integer := 0; 
    paddr   : integer := 0;
    pmask   : integer := 16#fff#;
    pirq    : integer := 0);
  port (
    rst     : in  std_ulogic;
    clk     : in  std_ulogic;
    apbi    : in  apb_slv_in_type;
    apbo    : out apb_slv_out_type;
    lcdi   : in  charlcd_in_type;
    lcdo   : out charlcd_out_type);
end component; 

end;
