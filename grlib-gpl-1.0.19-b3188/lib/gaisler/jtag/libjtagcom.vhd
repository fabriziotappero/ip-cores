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
-- Package: 	libjtagcom
-- File:	libjtagcom.vhd
-- Author:	Edvin Catovic - Gaisler Research
-- Description:	JTAG Commulnications link signal and component declarations
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
library gaisler;
use gaisler.misc.all;

package libjtagcom is

  type tap_in_type is record
    en   : std_ulogic;
    tdo  : std_ulogic;
  end record;

  type tap_out_type is record                            
    tck   : std_ulogic;
    tdi   : std_ulogic;
    inst  : std_logic_vector(7 downto 0);
    asel  : std_ulogic;
    dsel  : std_ulogic;
    reset : std_ulogic;
    capt  : std_ulogic;
    shift : std_ulogic;
    upd   : std_ulogic;      
  end record;
  
  component jtagcom 
  generic (
    isel   : integer range 0 to 1 := 0;
    nsync : integer range 1 to 2 := 2;
    ainst  : integer range 0 to 255 := 2;
    dinst  : integer range 0 to 255 := 3);
  port (
    rst  : in std_ulogic;
    clk  : in std_ulogic;
    tapo : in tap_out_type;
    tapi : out tap_in_type;
    dmao : in  ahb_dma_out_type;    
    dmai : out ahb_dma_in_type
    );
  end component;

end;  
  
