-- $Id: rbdlib.vhd 672 2015-05-02 21:58:28Z mueller $
--
-- Copyright 2010-2014 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Package Name:   rbdlib
-- Description:    Definitions for rbus devices
--
-- Dependencies:   -
-- Tool versions:  xst 12.1-14.7; ghdl 0.29-0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2014-09-13   593   4.0    use new rlink v4 iface and 4 bit STAT
-- 2014-08-15   583   3.5    rb_mreq addr now 16 bit
-- 2011-11-19   427   1.2.1  now numeric_std clean
-- 2010-12-29   351   1.2    new address layout; add rbd_timer
-- 2010-12-27   349   1.1    now correct defs for _rbmon and _eyemon
-- 2010-12-04   343   1.0    Initial version
------------------------------------------------------------------------------
--
-- two devices have standard addresses
--   rbd_rbmon     x"ffe8"
--   rbd_tester    x"ffe0"
--


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.rblib.all;

package rbdlib is
  
constant rbaddr_rbmon  : slv16 := x"ffe8"; -- ffe8/8: 1111 1111 1110 1xxx
constant rbaddr_tester : slv16 := x"ffe0"; -- ffe0/8: 1111 1111 1110 0xxx

component rbd_tester is                 -- rbus dev: rbus tester
                                        -- complete rbus_aif interface
  generic (
    RB_ADDR : slv16 := rbaddr_tester);
  port (
    CLK  : in slbit;                    -- clock
    RESET : in slbit;                   -- reset
    RB_MREQ : in rb_mreq_type;          -- rbus: request
    RB_SRES : out rb_sres_type;         -- rbus: response
    RB_LAM : out slv16;                 -- rbus: look at me
    RB_STAT : out slv4                  -- rbus: status flags
  );
end component;

component rbd_rbmon is                  -- rbus dev: rbus monitor
  generic (
    RB_ADDR : slv16 := rbaddr_rbmon;
    AWIDTH : natural := 9);
  port (
    CLK  : in slbit;                    -- clock
    RESET : in slbit;                   -- reset
    RB_MREQ : in rb_mreq_type;          -- rbus: request
    RB_SRES : out rb_sres_type;         -- rbus: response
    RB_SRES_SUM : in rb_sres_type       -- rbus: response (sum for monitor)
  );
end component;

component rbd_eyemon is                 -- rbus dev: eye monitor for serport's
  generic (
    RB_ADDR : slv16 := (others=>'0');
    RDIV : slv8 := (others=>'0'));
  port (
    CLK  : in slbit;                    -- clock
    RESET : in slbit;                   -- reset
    RB_MREQ : in rb_mreq_type;          -- rbus: request
    RB_SRES : out rb_sres_type;         -- rbus: response
    RXSD : in slbit;                    -- rx: serial data
    RXACT : in slbit                    -- rx: active (start seen)
  );
end component;

component rbd_bram is                   -- rbus dev: bram test target
                                        -- incomplete rbus_aif interface
  generic (
    RB_ADDR : slv16 := (others=>'0'));
  port (
    CLK  : in slbit;                    -- clock
    RESET : in slbit;                   -- reset
    RB_MREQ : in rb_mreq_type;          -- rbus: request
    RB_SRES : out rb_sres_type          -- rbus: response
  );
end component;

component rbd_timer is                  -- rbus dev: usec precision timer
  generic (
    RB_ADDR : slv16 := (others=>'0'));
  port (
    CLK  : in slbit;                    -- clock
    CE_USEC : in slbit;                 -- usec pulse
    RESET : in slbit;                   -- reset
    RB_MREQ : in rb_mreq_type;          -- rbus: request
    RB_SRES : out rb_sres_type;         -- rbus: response
    DONE : out slbit;                   -- mark last timer cycle
    BUSY : out slbit                    -- timer running
  );
end component;

end package rbdlib;
