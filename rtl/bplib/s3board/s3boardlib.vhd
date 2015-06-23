-- $Id: s3boardlib.vhd 649 2015-02-21 21:10:16Z mueller $
--
-- Copyright 2007-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Package Name:   s3boardlib
-- Description:    S3BOARD components
-- 
-- Dependencies:   -
-- Tool versions:  xst 8.1-14.7; ghdl 0.18-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-07-09   391   1.3.5  move s3_rs232_iob_int_ext to bpgenlib
-- 2011-07-08   390   1.3.4  move s3_(dispdrv|humanio*) to bpgenlib
-- 2011-07-03   387   1.3.3  move s3_rs232_iob_(int|ext) to bpgenlib
-- 2010-12-30   351   1.3.2  use rblib; rename human s3_humanio_rri -> _rbus
-- 2010-11-06   336   1.3.1  rename input pin CLK -> I_CLK50
-- 2010-06-03   300   1.3    add s3_humanio_rri (now needs rrilib)
-- 2010-05-21   292   1.2.2  rename _PM1_ -> _FUSP_
-- 2010-05-16   291   1.2.1  rename memctl_s3sram -> s3_sram_memctl; _usp->_fusp
-- 2010-05-01   286   1.2    added s3board_usp_aif (base+pm1_rs232)
-- 2010-04-17   278   1.1.6  rename, prefix dispdrv,sram_summy with s3_;
--                           add s3_rs232_iob_(int|ext|int_ext)
-- 2010-04-11   276   1.1.5  add DEBOUNCE for s3_humanio
-- 2010-04-10   275   1.1.4  add s3_humanio
-- 2008-02-17   117   1.1.3  memctl_s3sram: use req,we interface
-- 2008-01-20   113   1.1.2  rename memdrv -> memctl_s3sram
-- 2007-12-16   101   1.1.1  use _N for active low
-- 2007-12-09   100   1.1    add sram memory signals; sram_dummy; memdrv
-- 2007-09-23    84   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

package s3boardlib is

component s3board_aif is                -- S3BOARD, abstract iface, base
  port (
    I_CLK50 : in slbit;                 -- 50 MHz board clock
    I_RXD : in slbit;                   -- receive data (board view)
    O_TXD : out slbit;                  -- transmit data (board view)
    I_SWI : in slv8;                    -- s3 switches
    I_BTN : in slv4;                    -- s3 buttons
    O_LED : out slv8;                   -- s3 leds
    O_ANO_N : out slv4;                 -- 7 segment disp: anodes   (act.low)
    O_SEG_N : out slv8;                 -- 7 segment disp: segments (act.low)
    O_MEM_CE_N : out slv2;              -- sram: chip enables  (act.low)
    O_MEM_BE_N : out slv4;              -- sram: byte enables  (act.low)
    O_MEM_WE_N : out slbit;             -- sram: write enable  (act.low)
    O_MEM_OE_N : out slbit;             -- sram: output enable (act.low)
    O_MEM_ADDR  : out slv18;            -- sram: address lines
    IO_MEM_DATA : inout slv32           -- sram: data lines
  );
end component;

component s3board_fusp_aif is           -- S3BOARD, abstract iface, base+fusp
  port (
    I_CLK50 : in slbit;                 -- 50 MHz board clock
    I_RXD : in slbit;                   -- receive data (board view)
    O_TXD : out slbit;                  -- transmit data (board view)
    I_SWI : in slv8;                    -- s3 switches
    I_BTN : in slv4;                    -- s3 buttons
    O_LED : out slv8;                   -- s3 leds
    O_ANO_N : out slv4;                 -- 7 segment disp: anodes   (act.low)
    O_SEG_N : out slv8;                 -- 7 segment disp: segments (act.low)
    O_MEM_CE_N : out slv2;              -- sram: chip enables  (act.low)
    O_MEM_BE_N : out slv4;              -- sram: byte enables  (act.low)
    O_MEM_WE_N : out slbit;             -- sram: write enable  (act.low)
    O_MEM_OE_N : out slbit;             -- sram: output enable (act.low)
    O_MEM_ADDR  : out slv18;            -- sram: address lines
    IO_MEM_DATA : inout slv32;          -- sram: data lines
    O_FUSP_RTS_N : out slbit;           -- fusp: rs232 rts_n
    I_FUSP_CTS_N : in slbit;            -- fusp: rs232 cts_n
    I_FUSP_RXD : in slbit;              -- fusp: rs232 rx
    O_FUSP_TXD : out slbit              -- fusp: rs232 tx
  );
end component;

component s3_sram_dummy is              -- SRAM protection dummy 
  port (
    O_MEM_CE_N : out slv2;              -- sram: chip enables  (act.low)
    O_MEM_BE_N : out slv4;              -- sram: byte enables  (act.low)
    O_MEM_WE_N : out slbit;             -- sram: write enable  (act.low)
    O_MEM_OE_N : out slbit;             -- sram: output enable (act.low)
    O_MEM_ADDR  : out slv18;            -- sram: address lines
    IO_MEM_DATA : inout slv32           -- sram: data lines
  );
end component;

component s3_sram_memctl is             -- SRAM driver
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    REQ   : in slbit;                   -- request
    WE    : in slbit;                   -- write enable
    BUSY : out slbit;                   -- controller busy
    ACK_R : out slbit;                  -- acknowledge read
    ACK_W : out slbit;                  -- acknowledge write
    ACT_R : out slbit;                  -- signal active read
    ACT_W : out slbit;                  -- signal active write
    ADDR : in slv18;                    -- address
    BE : in slv4;                       -- byte enable
    DI : in slv32;                      -- data in  (memory view)
    DO : out slv32;                     -- data out (memory view)
    O_MEM_CE_N : out slv2;              -- sram: chip enables  (act.low)
    O_MEM_BE_N : out slv4;              -- sram: byte enables  (act.low)
    O_MEM_WE_N : out slbit;             -- sram: write enable  (act.low)
    O_MEM_OE_N : out slbit;             -- sram: output enable (act.low)
    O_MEM_ADDR  : out slv18;            -- sram: address lines
    IO_MEM_DATA : inout slv32           -- sram: data lines
  );
end component;

end package s3boardlib;
