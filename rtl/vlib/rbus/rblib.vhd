-- $Id: rblib.vhd 641 2015-02-01 22:12:15Z mueller $
--
-- Copyright 2007-2014 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Package Name:   rblib
-- Description:    Definitions for rbus interface and bus entities
--
-- Dependencies:   -
-- Tool versions:  ise 8.2-14.7; viv 2014.4; ghdl 0.18-0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2014-09-14   593   4.0    use new rlink v4 iface and 4 bit STAT
-- 2014-08-15   583   3.5    rb_mreq addr now 16 bit
-- 2011-12-23   444   3.1    CLK_CYCLE now integer
-- 2011-08-13   405   3.0.3  add in direction for  FADDR,SEL ports
-- 2010-12-26   349   3.0.2  add rb_sel
-- 2010-12-22   346   3.0.1  add rb_mon and rb_mon_sb;
-- 2010-12-04   343   3.0    extracted from rrilib and rritblib;
--                           rbus V3 interface: use aval,re,we
--                           ... rrilib history removed ...
-- 2007-09-09    81   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

package rblib is

type rb_mreq_type is record             -- rbus - master request
  aval : slbit;                         -- address valid
  re   : slbit;                         -- read enable
  we   : slbit;                         -- write enable
  init : slbit;                         -- init
  addr : slv16;                         -- address
  din  : slv16;                         -- data (input to slave)
end record rb_mreq_type;

constant rb_mreq_init : rb_mreq_type :=
  ('0','0','0','0',                     -- aval, re, we, init
   (others=>'0'),                       -- addr
   (others=>'0'));                      -- din

type rb_sres_type is record             -- rbus - slave response
  ack  : slbit;                         -- acknowledge
  busy : slbit;                         -- busy
  err  : slbit;                         -- error
  dout : slv16;                         -- data (output from slave)
end record rb_sres_type;

constant rb_sres_init : rb_sres_type :=
  ('0','0','0',                         -- ack, busy, err
   (others=>'0'));                      -- dout

component rb_sel is                     -- rbus address select logic
  generic (
    RB_ADDR : slv16;                    -- rbus address base
    SAWIDTH : natural := 0);            -- device subaddress space width
  port (
    CLK : in slbit;                     -- clock
    RB_MREQ : in rb_mreq_type;          -- rbus request
    SEL : out slbit                     -- select state bit
  );
end component;

component rb_sres_or_2 is               -- rbus result or, 2 input
  port (
    RB_SRES_1  :  in rb_sres_type;                 -- rb_sres input 1
    RB_SRES_2  :  in rb_sres_type := rb_sres_init; -- rb_sres input 2
    RB_SRES_OR : out rb_sres_type       -- rb_sres or'ed output
  );
end component;
component rb_sres_or_3 is               -- rbus result or, 3 input
  port (
    RB_SRES_1  :  in rb_sres_type;                 -- rb_sres input 1
    RB_SRES_2  :  in rb_sres_type := rb_sres_init; -- rb_sres input 2
    RB_SRES_3  :  in rb_sres_type := rb_sres_init; -- rb_sres input 3
    RB_SRES_OR : out rb_sres_type       -- rb_sres or'ed output
  );
end component;
component rb_sres_or_4 is               -- rbus result or, 4 input
  port (
    RB_SRES_1  :  in rb_sres_type;                 -- rb_sres input 1
    RB_SRES_2  :  in rb_sres_type := rb_sres_init; -- rb_sres input 2
    RB_SRES_3  :  in rb_sres_type := rb_sres_init; -- rb_sres input 3
    RB_SRES_4  :  in rb_sres_type := rb_sres_init; -- rb_sres input 4
    RB_SRES_OR : out rb_sres_type       -- rb_sres or'ed output
  );
end component;

component rbus_aif is                   -- rbus, abstract interface
  port (
    CLK  : in slbit;                    -- clock
    RESET  : in slbit := '0';           -- reset
    RB_MREQ : in rb_mreq_type;          -- rbus: request
    RB_SRES : out rb_sres_type;         -- rbus: response
    RB_LAM : out slv16;                 -- rbus: look at me
    RB_STAT : out slv4                  -- rbus: status flags
  );
end component;

component rb_wreg_rw_3 is               -- rbus: wide register r/w 3 bit select
  generic (
    DWIDTH : positive := 16);
  port (
    CLK  : in slbit;                    -- clock
    RESET  : in slbit;                  -- reset
    FADDR : in slv3;                    -- field address
    SEL : in slbit;                     -- select
    DATA : out slv(DWIDTH-1 downto 0);  -- data
    RB_MREQ :  in rb_mreq_type;         -- rbus request
    RB_SRES : out rb_sres_type          -- rbus response
  );
end component;

component rb_wreg_w_3 is                -- rbus: wide register w-o 3 bit select
  generic (
    DWIDTH : positive := 16);
  port (
    CLK  : in slbit;                    -- clock
    RESET  : in slbit;                  -- reset
    FADDR : in slv3;                    -- field address
    SEL : in slbit;                     -- select
    DATA : out slv(DWIDTH-1 downto 0);  -- data
    RB_MREQ :  in rb_mreq_type;         -- rbus request
    RB_SRES : out rb_sres_type          -- rbus response
  );
end component;

component rb_wreg_r_3 is                -- rbus: wide register r-o 3 bit select
  generic (
    DWIDTH : positive := 16);
  port (
    FADDR : in slv3;                    -- field address
    SEL : in slbit;                     -- select
    DATA : in slv(DWIDTH-1 downto 0);   -- data
    RB_SRES : out rb_sres_type          -- rbus response
  );
end component;

--
-- components for use in test benches (not synthesizable)
--

component rb_sres_or_mon is             -- rbus result or monitor
  port (
    RB_SRES_1  :  in rb_sres_type;      -- rb_sres input 1
    RB_SRES_2  :  in rb_sres_type;      -- rb_sres input 2
    RB_SRES_3  :  in rb_sres_type := rb_sres_init; -- rb_sres input 3
    RB_SRES_4  :  in rb_sres_type := rb_sres_init  -- rb_sres input 4
  );
end component;

-- simbus sb_cntl field usage for rbus
constant sbcntl_sbf_rbmon : integer := 13;

component rb_mon is                     -- rbus monitor
  generic (
    DBASE : positive :=  2);            -- base for writing data values
  port (
    CLK  : in slbit;                    -- clock
    CLK_CYCLE : in integer := 0;        -- clock cycle number
    ENA  : in slbit := '1';             -- enable monitor output
    RB_MREQ : in rb_mreq_type;          -- rbus: request
    RB_SRES : in rb_sres_type;          -- rbus: response
    RB_LAM : in slv16 := (others=>'0'); -- rbus: look at me
    RB_STAT : in slv4                   -- rbus: status flags
  ); 
end component;

component rb_mon_sb is                  -- simbus wrapper for rbus monitor
  generic (
    DBASE : positive :=  2;             -- base for writing data values
    ENAPIN : integer := sbcntl_sbf_rbmon); -- SB_CNTL signal to use for enable
  port (
    CLK  : in slbit;                    -- clock
    RB_MREQ : in rb_mreq_type;          -- rbus: request
    RB_SRES : in rb_sres_type;          -- rbus: response
    RB_LAM : in slv16 := (others=>'0'); -- rbus: look at me
    RB_STAT : in slv4                   -- rbus: status flags
  );
end component;

end package rblib;
