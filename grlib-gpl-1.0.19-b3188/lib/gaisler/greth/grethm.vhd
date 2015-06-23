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
-- Entity: 	grethm
-- File:	grethm.vhd
-- Author:	Jiri Gaisler
-- Description:	Module to select between greth and greth1g
------------------------------------------------------------------------------
library ieee;
library grlib;
library gaisler; 
use ieee.std_logic_1164.all;
use grlib.stdlib.all;
use grlib.amba.all;
library techmap;
use techmap.gencomp.all;
use gaisler.net.all;

entity grethm is
  generic(
    hindex         : integer := 0;
    pindex         : integer := 0;
    paddr          : integer := 0;
    pmask          : integer := 16#FFF#;
    pirq           : integer := 0;
    memtech        : integer := 0;
    ifg_gap        : integer := 24; 
    attempt_limit  : integer := 16;
    backoff_limit  : integer := 10;
    slot_time      : integer := 128;
    mdcscaler      : integer range 0 to 255 := 25; 
    enable_mdio    : integer range 0 to 1 := 0;
    fifosize       : integer range 4 to 64 := 8;
    nsync          : integer range 1 to 2 := 2;
    edcl           : integer range 0 to 1 := 0;
    edclbufsz      : integer range 1 to 64 := 1;
    burstlength    : integer range 4 to 128 := 32;
    macaddrh       : integer := 16#00005E#;
    macaddrl       : integer := 16#000000#;
    ipaddrh        : integer := 16#c0a8#;
    ipaddrl        : integer := 16#0035#;
    phyrstadr      : integer range 0 to 32 := 0;
    rmii           : integer range 0 to 1 := 0;
    sim            : integer range 0 to 1 := 0;
    giga           : integer range 0 to 1  := 0;
    oepol          : integer range 0 to 1  := 0;
    scanen         : integer range 0 to 1  := 0
  ); 
  port(
    rst            : in  std_ulogic;
    clk            : in  std_ulogic;
    ahbmi          : in  ahb_mst_in_type;
    ahbmo          : out ahb_mst_out_type;
    apbi           : in  apb_slv_in_type;
    apbo           : out apb_slv_out_type;
    ethi           : in  eth_in_type;
    etho           : out eth_out_type
  );
end entity;
  
architecture rtl of grethm is
begin

  m100 : if giga = 0 generate
    u0 : greth generic map ( hindex, pindex, paddr, pmask, pirq, 
    	memtech, ifg_gap, attempt_limit, backoff_limit, slot_time, mdcscaler, 
    	enable_mdio, fifosize, nsync, edcl, edclbufsz, macaddrh, macaddrl, 
    	ipaddrh, ipaddrl, phyrstadr, rmii, oepol, scanen)
    port map ( rst, clk, ahbmi, ahbmo, apbi, apbo, ethi, etho);

  end generate;

  m1000 : if giga = 1 generate
    u0 : greth_gbit generic map ( hindex, pindex, paddr, pmask, pirq, 
    	memtech, ifg_gap, attempt_limit, backoff_limit, slot_time, mdcscaler, 
    	nsync, edcl, edclbufsz, burstlength, macaddrh, macaddrl, ipaddrh,
	ipaddrl, phyrstadr, sim, oepol, scanen)
    port map ( rst, clk, ahbmi, ahbmo, apbi, apbo, ethi, etho);
  end generate;

end architecture;

