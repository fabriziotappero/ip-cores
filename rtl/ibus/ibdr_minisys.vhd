-- $Id: ibdr_minisys.vhd 676 2015-05-09 16:31:54Z mueller $
--
-- Copyright 2008-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    ibdr_minisys - syn
-- Description:    ibus(rem) devices for minimal system:SDR+KW+DL+RK
--
-- Dependencies:   ibdr_sdreg
--                 ibd_kw11l
--                 ibdr_dl11
--                 ibdr_rk11
--                 ib_sres_or_4
--                 ib_intmap
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  ise 8.2-14.7; viv 2014.4; ghdl 0.18-0.31
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2010-10-17   333 12.1    M53d xc3s1000-4   128  469   16  265 s  7.8
-- 2010-10-17   314 12.1    M53d xc3s1000-4   122  472   16  269 s  7.6
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-11-18   427   1.1.2  now numeric_std clean
-- 2010-10-23   335   1.1.1  rename RRI_LAM->RB_LAM;
-- 2010-06-11   303   1.1    use IB_MREQ.racc instead of RRI_REQ
-- 2009-07-12   233   1.0.7  reorder ports, add CE_USEC; add RESET and CE_USEC
--                           to _dl11
-- 2009-05-31   221   1.0.6  add RESET to kw11l;
-- 2009-05-24   219   1.0.5  _rk11 uses now CE_MSEC
-- 2008-08-22   161   1.0.4  use iblib, ibdlib
-- 2008-05-09   144   1.0.3  use EI_ACK with _kw11l, _dl11
-- 2008-04-18   136   1.0.2  add RESET port, use for ibdr_sdreg
-- 2008-01-20   113   1.0.1  RRI_LAM now vector
-- 2008-01-20   112   1.0    Initial version 
------------------------------------------------------------------------------
-- 
-- mini system setup
--
-- ibbase  vec  pri slot attn  device name
-- 
-- 177546  100    6    4    -  KW11-L
-- 177400  220    5    3    4  RK11
-- 177560  060    4    2    1  DL11-RX  1st
--         064    4    1    ^  DL11-TX  1st
-- 177570    -    -    -    -  sdreg
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.iblib.all;
use work.ibdlib.all;

-- ----------------------------------------------------------------------------
entity ibdr_minisys is                  -- ibus(rem) minimal sys:SDR+KW+DL+RK
  port (
    CLK : in slbit;                     -- clock
    CE_USEC : in slbit;                 -- usec pulse
    CE_MSEC : in slbit;                 -- msec pulse
    RESET : in slbit;                   -- reset
    BRESET : in slbit;                  -- ibus reset
    RB_LAM : out slv16_1;               -- remote attention vector
    IB_MREQ : in ib_mreq_type;          -- ibus request
    IB_SRES : out ib_sres_type;         -- ibus response
    EI_ACKM : in slbit;                 -- interrupt acknowledge (from master)
    EI_PRI : out slv3;                  -- interrupt priority (to cpu)
    EI_VECT : out slv9_2;               -- interrupt vector   (to cpu)
    DISPREG : out slv16                 -- display register
  );
end ibdr_minisys;

architecture syn of ibdr_minisys is

  constant conf_intmap : intmap_array_type :=
    (intmap_init,                       -- line 15
     intmap_init,                       -- line 14
     intmap_init,                       -- line 13
     intmap_init,                       -- line 12
     intmap_init,                       -- line 11
     intmap_init,                       -- line 10
     intmap_init,                       -- line  9
     intmap_init,                       -- line  8
     intmap_init,                       -- line  7
     intmap_init,                       -- line  6
     intmap_init,                       -- line  5
     (8#100#,6),                        -- line  4  KW11-L
     (8#220#,5),                        -- line  3  RK11
     (8#060#,4),                        -- line  2  DL11-RX
     (8#064#,4),                        -- line  1  DL11-TX
     intmap_init                        -- line  0
     );

  signal RB_LAM_DL11 : slbit := '0';
  signal RB_LAM_RK11 : slbit := '0';

  signal IB_SRES_SDREG : ib_sres_type := ib_sres_init;
  signal IB_SRES_KW11L : ib_sres_type := ib_sres_init;
  signal IB_SRES_DL11  : ib_sres_type := ib_sres_init;
  signal IB_SRES_RK11  : ib_sres_type := ib_sres_init;

  signal EI_REQ  : slv16_1 := (others=>'0');
  signal EI_ACK  : slv16_1 := (others=>'0');

  signal EI_REQ_KW11L : slbit := '0';
  signal EI_REQ_DL11RX : slbit := '0';
  signal EI_REQ_DL11TX : slbit := '0';
  signal EI_REQ_RK11 : slbit := '0';
  
  signal EI_ACK_KW11L : slbit := '0';
  signal EI_ACK_DL11RX : slbit := '0';
  signal EI_ACK_DL11TX : slbit := '0';
  signal EI_ACK_RK11 : slbit := '0';

begin

  SDREG : ibdr_sdreg
    port map (
      CLK     => CLK,
      RESET   => RESET,
      IB_MREQ => IB_MREQ,
      IB_SRES => IB_SRES_SDREG,
      DISPREG => DISPREG
    );

  KW11L : ibd_kw11l
    port map (
      CLK     => CLK,
      CE_MSEC => CE_MSEC,
      RESET   => RESET,
      BRESET  => BRESET,
      CPUSUSP => '0',
      IB_MREQ => IB_MREQ,
      IB_SRES => IB_SRES_KW11L,
      EI_REQ  => EI_REQ_KW11L,
      EI_ACK  => EI_ACK_KW11L
    );

  DL11 : ibdr_dl11
    port map (
      CLK       => CLK,
      CE_USEC   => CE_USEC,
      RESET     => RESET,
      BRESET    => BRESET,
      RB_LAM    => RB_LAM_DL11,
      IB_MREQ   => IB_MREQ,
      IB_SRES   => IB_SRES_DL11,
      EI_REQ_RX => EI_REQ_DL11RX,
      EI_REQ_TX => EI_REQ_DL11TX,
      EI_ACK_RX => EI_ACK_DL11RX,
      EI_ACK_TX => EI_ACK_DL11TX
    );
  
  RK11 : ibdr_rk11
    port map (
      CLK     => CLK,
      CE_MSEC => CE_MSEC,
      BRESET  => BRESET,
      RB_LAM  => RB_LAM_RK11,
      IB_MREQ => IB_MREQ,
      IB_SRES => IB_SRES_RK11,
      EI_REQ  => EI_REQ_RK11,
      EI_ACK  => EI_ACK_RK11
    );

  SRES_OR : ib_sres_or_4
    port map (
      IB_SRES_1  => IB_SRES_SDREG,
      IB_SRES_2  => IB_SRES_KW11L,
      IB_SRES_3  => IB_SRES_DL11,
      IB_SRES_4  => IB_SRES_RK11,
      IB_SRES_OR => IB_SRES
    );

  INTMAP : ib_intmap
    generic map (
      INTMAP => conf_intmap)
    port map (
      EI_REQ  => EI_REQ,
      EI_ACKM => EI_ACKM,
      EI_ACK  => EI_ACK,
      EI_PRI  => EI_PRI,
      EI_VECT => EI_VECT
    );
  
  EI_REQ(4) <= EI_REQ_KW11L;
  EI_REQ(3) <= EI_REQ_RK11;
  EI_REQ(2) <= EI_REQ_DL11RX;
  EI_REQ(1) <= EI_REQ_DL11TX;

  EI_ACK_KW11L  <= EI_ACK(4);
  EI_ACK_RK11   <= EI_ACK(3);
  EI_ACK_DL11RX <= EI_ACK(2);
  EI_ACK_DL11TX <= EI_ACK(1);

  RB_LAM(1) <= RB_LAM_DL11;
  RB_LAM(2) <= '0';                  -- for 2nd DL11
  RB_LAM(3) <= '0';                  -- for DZ11
  RB_LAM(4) <= RB_LAM_RK11;
  RB_LAM(15 downto 5) <= (others=>'0');        
    
end syn;
