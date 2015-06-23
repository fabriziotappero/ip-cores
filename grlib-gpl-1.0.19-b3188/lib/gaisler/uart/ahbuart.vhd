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
-- Entity:      ahbuart
-- File:        ahbuart.vhd
-- Author:      Jiri Gaisler - Gaisler Research
-- Description: UART with AHB master interface
------------------------------------------------------------------------------  

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;
library gaisler;
use gaisler.misc.all;
use gaisler.uart.all;
use gaisler.libdcom.all;

entity ahbuart is
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
end;      

architecture struct of ahbuart is

constant REVISION : integer := 0;

signal dmai : ahb_dma_in_type;
signal dmao : ahb_dma_out_type;
signal duarti : dcom_uart_in_type;
signal duarto : dcom_uart_out_type;

begin

  ahbmst0 : ahbmst 
    generic map (hindex => hindex, venid => VENDOR_GAISLER, devid => GAISLER_AHBUART) 
    port map (rst, clk, dmai, dmao, ahbi, ahbo);

  dcom_uart0 : dcom_uart generic map (pindex, paddr, pmask)
    port map (rst, clk, uarti, uarto, apbi, apbo, duarti, duarto);

  dcom0 : dcom port map (rst, clk, dmai, dmao, duarti, duarto, ahbi);

-- pragma translate_off
    bootmsg : report_version 
    generic map ("ahbuart" & tost(pindex) & 
	": AHB Debug UART rev " & tost(REVISION));
-- pragma translate_on

end;
