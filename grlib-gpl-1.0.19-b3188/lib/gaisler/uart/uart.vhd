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
-----------------------------------------------------------------------------
-- package: 	uart
-- File:	uart.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	UART types and components
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;

package uart is

type uart_in_type is record
  rxd   	: std_ulogic;
  ctsn   	: std_ulogic;
  extclk	: std_ulogic;
end record;

type uart_out_type is record
  rtsn   	: std_ulogic;
  txd   	: std_ulogic;
  scaler	: std_logic_vector(17 downto 0);
  txen     	: std_ulogic;
  flow   	: std_ulogic;
  rxen     	: std_ulogic;
end record;

component apbuart
  generic (
    pindex   : integer := 0; 
    paddr    : integer := 0;
    pmask    : integer := 16#fff#;
    console  : integer := 0; 
    pirq     : integer := 0;
    parity   : integer := 1; 
    flow     : integer := 1;
    fifosize : integer range 1 to 32 := 1;
    abits    : integer := 8);
  port (
    rst    : in  std_ulogic;
    clk    : in  std_ulogic;
    apbi   : in  apb_slv_in_type;
    apbo   : out apb_slv_out_type;
    uarti  : in  uart_in_type;
    uarto  : out uart_out_type);
end component;

component ahbuart
  generic (
    hindex  : integer := 0;
    pindex  : integer := 0;
    paddr : integer := 0;
    pmask : integer := 16#fff#
  );
  port (
    rst     : in  std_ulogic;
    clk     : in  std_ulogic;
    uarti   : in  uart_in_type;
    uarto   : out uart_out_type;
    apbi    : in  apb_slv_in_type;
    apbo    : out apb_slv_out_type;
    ahbi    : in  ahb_mst_in_type;
    ahbo    : out ahb_mst_out_type );
end component;      

end;
