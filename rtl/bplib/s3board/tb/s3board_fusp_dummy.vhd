-- $Id: s3board_fusp_dummy.vhd 649 2015-02-21 21:10:16Z mueller $
--
-- Copyright 2010- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    s3board_fusp_dummy - syn
-- Description:    s3board minimal target (base+fusp; serport loopback)
--
-- Dependencies:   -
-- To test:        tb_s3board_fusp
-- Target Devices: generic
-- Tool versions:  xst 11.4-14.7; ghdl 0.26-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2010-11-06   336   1.0.3  rename input pin CLK -> I_CLK50
-- 2010-05-21   292   1.0.2  rename _PM1_ -> _FUSP_
-- 2010-05-16   291   1.0.1  rename s3board_usp_dummy->s3board_fusp_dummy
-- 2010-05-01   286   1.0    Initial version (derived from s3board_dummy)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;
use work.s3boardlib.all;

entity s3board_fusp_dummy is            -- S3BOARD dummy (base+fusp; loopback)
                                        -- implements s3board_fusp_aif
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
end s3board_fusp_dummy;

architecture syn of s3board_fusp_dummy is
  
begin

  O_TXD        <= I_RXD;
  O_FUSP_TXD   <= I_FUSP_RXD;
  O_FUSP_RTS_N <= I_FUSP_CTS_N;

  SRAM : s3_sram_dummy                  -- connect SRAM to protection dummy
    port map (
      O_MEM_CE_N => O_MEM_CE_N,
      O_MEM_BE_N => O_MEM_BE_N,
      O_MEM_WE_N => O_MEM_WE_N,
      O_MEM_OE_N => O_MEM_OE_N,
      O_MEM_ADDR  => O_MEM_ADDR,
      IO_MEM_DATA => IO_MEM_DATA
    );
  
end syn;
