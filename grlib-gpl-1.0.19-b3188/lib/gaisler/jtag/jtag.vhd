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
-- package: 	jtag
-- File:	jtag.vhd
-- Author:	Edvin Catovic - Gaisler Research
-- Description:	JTAG components
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
library techmap;
use techmap.gencomp.all;

package jtag is

constant JTAG_MANF_ID_GR : integer range 0 to 2047 := 804;
constant JTAG_IHP25RH1   : integer range 0 to 65535 := 16#251#;
constant JTAG_UT699RH    : integer range 0 to 65535 := 16#699#;
constant JTAG_GR702      : integer range 0 to 65535 := 16#702#;
  
component ahbjtag 
  generic (
    tech    : integer range 0 to NTECH := 0;
    hindex  : integer := 0;
    nsync : integer range 1 to 2 := 1;
    idcode : integer range 0 to 255 := 9;
    manf   : integer range 0 to 2047 := 804;
    part   : integer range 0 to 65535 := 0;
    ver    : integer range 0 to 15 := 0;
    ainst   : integer range 0 to 255 := 2;
    dinst   : integer range 0 to 255 := 3;
    scantest : integer := 0);
  port (
    rst     : in  std_ulogic;
    clk     : in  std_ulogic;
    tck     : in  std_ulogic;
    tms     : in  std_ulogic;
    tdi     : in  std_ulogic;
    tdo     : out std_ulogic;
    ahbi    : in  ahb_mst_in_type;
    ahbo    : out ahb_mst_out_type;
    tapo_tck    : out std_ulogic;
    tapo_tdi    : out std_ulogic;
    tapo_inst   : out std_logic_vector(7 downto 0);
    tapo_rst    : out std_ulogic;
    tapo_capt   : out std_ulogic;
    tapo_shft   : out std_ulogic;
    tapo_upd    : out std_ulogic;
    tapi_tdo    : in std_ulogic;
    trst        : in std_ulogic := '1';
    tdoen   : out std_ulogic
    );
end component;      


component ahbjtag_bsd 
  generic (
    tech    : integer range 0 to NTECH := 0;
    hindex  : integer := 0;
    nsync : integer range 1 to 2 := 1;
    ainst   : integer range 0 to 255 := 2;
    dinst   : integer range 0 to 255 := 3);
  port (
    rst         : in  std_ulogic;
    clk         : in  std_ulogic;
    ahbi        : in  ahb_mst_in_type;
    ahbo        : out ahb_mst_out_type;
    asel        : in  std_ulogic;
    dsel        : in  std_ulogic;
    tck         : in  std_ulogic;
    regi        : in  std_ulogic;
    shift       : in  std_ulogic;
    rego        : out std_ulogic
    );
end component;

end;
