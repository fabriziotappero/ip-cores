-- $Id: rlink_cext_vhpi.vhd 649 2015-02-21 21:10:16Z mueller $
--
-- Copyright 2007-2010 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
-- This program is free software; you may redistribute and/or modify it under
-- the terms of the GNU General Public License as published by the Free
-- Software Foundation, either version 2, or at your option any later version.
--
-- This program is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
-- or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
-- for complete details.
-- 
------------------------------------------------------------------------------
-- Package Name:   rlink_cext_vhpi
-- Description:    VHDL procedural interface: VHDL declaration side
--
-- Dependencies:   -
-- Tool versions:  xst 8.1-14.7; ghdl 0.18-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2010-12-29   351   1.1    rename vhpi_rriext->rlink_cext_vhpi; new rbv3 names
-- 2007-08-26    76   1.0    Initial version 
------------------------------------------------------------------------------

package rlink_cext_vhpi is

  impure function rlink_cext_getbyte (
    clk : integer)                      -- clock cycle
    return integer;
  attribute foreign of rlink_cext_getbyte :
    function is "VHPIDIRECT rlink_cext_getbyte";
  
  impure function rlink_cext_putbyte (
    dat : integer)                      -- data byte
    return integer;
  attribute foreign of rlink_cext_putbyte :
    function is "VHPIDIRECT rlink_cext_putbyte";

end package rlink_cext_vhpi;

package body rlink_cext_vhpi is

  impure function rlink_cext_getbyte (
    clk : integer)                      -- clock cycle
    return integer is
  begin
    report "rlink_cext_getbyte not vhpi'ed" severity failure;
  end rlink_cext_getbyte;

  impure function rlink_cext_putbyte (
    dat : integer)                      -- data byte
    return integer is
  begin
    report "rlink_cext_getbyte not vhpi'ed" severity failure;
  end rlink_cext_putbyte;

end package body rlink_cext_vhpi;
