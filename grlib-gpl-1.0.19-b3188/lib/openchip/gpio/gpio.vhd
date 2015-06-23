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
-- package: 	gpio
-- File:	gpio.vhd
-- Author:	Antti Lukats, OpenChip
-- Description:	GPIO types and components
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;

package gpio is

type gpio_in_type is record
  d_in  	: std_logic_vector(31 downto 0);
end record;

type gpio_out_type is record
  d_out   	: std_logic_vector(31 downto 0);
  t_out   	: std_logic_vector(31 downto 0);
end record;

component apbgpio
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
    gpioi   : in  gpio_in_type;
    gpioo   : out gpio_out_type);
end component; 

end;
