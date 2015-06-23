-------------------------------------------------------------------------------
-- Title      :  Rx Channel
-- Project    :  HDLC controller
-------------------------------------------------------------------------------
-- File        : RxChannel.vhd
-- Author      : Jamil Khatib  (khatib@ieee.org)
-- Organization: OpenIPCore Project
-- Created     : 2000/12/30
-- Last update: 2001/04/27
-- Platform    : 
-- Simulators  : Modelsim 5.3XE/Windows98
-- Synthesizers: 
-- Target      : 
-- Dependency  : ieee.std_logic_1164
--
-------------------------------------------------------------------------------
-- Description:  receive Channel
-------------------------------------------------------------------------------
-- Copyright (c) 2000 Jamil Khatib
-- 
-- This VHDL design file is an open design; you can redistribute it and/or
-- modify it and/or implement it after contacting the author
-- You can check the draft license at
-- http://www.opencores.org/OIPC/license.shtml

-------------------------------------------------------------------------------
-- Revisions  :
-- Revision Number :   1
-- Version         :   0.1
-- Date            :   30 Dec 2000
-- Modifier        :   Jamil Khatib (khatib@ieee.org)
-- Desccription    :   Created
-- ToOptimize      :
-- Bugs            :  
-------------------------------------------------------------------------------
-- Revisions  :
-- Revision Number :   2
-- Version         :   0.2
-- Date            :   12 Jan 2001
-- Modifier        :   Jamil Khatib (khatib@ieee.org)
-- Desccription    :   RXEN bug fixed
--
-------------------------------------------------------------------------------
-- Revisions  :
-- Revision Number :   3
-- Version         :   0.3
-- Date            :   27 April 2001
-- Modifier        :   Jamil Khatib (khatib@ieee.org)
-- Desccription    :   FrameAvailable port added to Zero_detect 
--
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
LIBRARY hdlc;
use hdlc.hdlc_components_pkg.all;

entity RxChannel_ent is

  port (
    Rxclk       : in  std_logic;        -- Rx Clock
    rst         : in  std_logic;        -- system reset
    Rx          : in  std_logic;        -- RX input serial data
    RxData      : out std_logic_vector(7 downto 0);  -- Rx backedn Data bus
    ValidFrame  : out std_logic;        -- Valid Frame
    FrameError  : out std_logic;        -- Frame Error (Indicates error in the
                                        -- next byte at the backend
    AbortSignal : out std_logic;        -- Abort signal
    Readbyte    : in  std_logic;        -- backend read byte
    rdy         : out std_logic;        -- backend ready signal
    RxEn        : in  std_logic);       -- Rx Enable (Flow control)

end RxChannel_ent;

architecture RxChannel_beh of RxChannel_ent is

  signal RxD_i        : std_logic;      -- RXD internal signal
  signal enable_i     : std_logic;      -- Internal enable signal
  signal aval_i       : std_logic;      -- Available internal signal
  signal FlagDetect_i : std_logic;      -- flag Detect internal
  signal Abort_i      : std_logic;      -- Internal Abort signal
  signal initzero_i   : std_logic;      -- Init Zero detect block
  signal rxen_i       : std_logic;      -- RXenable internal

  -- New
  signal ValidFrame_i : std_logic;        -- Internal Valid Frame
  
begin  -- RxChannel_beh

-------------------------------------------------------------------------------
ValidFrame <= ValidFrame_i;

  Controller   : rxcont_ent
    port map (
      RxClk        => RxClk,
      rst          => rst,
      RxEn         => RxEn_i,
      AbortedFrame => AbortSignal,
      Abort        => Abort_i,
      FlagDetect   => FlagDetect_i,
      ValidFrame   => ValidFrame_i,     --New
      FrameError   => FrameError,
      aval         => aval_i,
      initzero     => initzero_i,
      enable       => enable_i);
-------------------------------------------------------------------------------
  zero_backend : ZeroDetect_ent
    port map (
      ValidFrame => ValidFrame_i,       --New
      Readbyte     => Readbyte,
      aval         => aval_i,
      enable       => enable_i,
      StartofFrame => initzero_i,
      rdy          => rdy,
      rst          => rst,
      RxClk        => RxClk,
      RxD          => RxD_i,
      RxData       => RxData);
-------------------------------------------------------------------------------
  flag_detect  : FlagDetect_ent
    port map (
      Rxclk        => Rxclk,
      rst          => rst,
      FlagDetect   => FlagDetect_i,
      Abort        => Abort_i,
      RXEN         => RXEN,
      RxEN_o       => RXEN_i,
      RXD          => RXD_i,
      RX           => RX);
-------------------------------------------------------------------------------


end RxChannel_beh;
