-------------------------------------------------------------------------------
-- Title      :  Tx Channel
-- Project    :  HDLC controller
-------------------------------------------------------------------------------
-- File        : Txchannel.vhd
-- Author      : Jamil Khatib  (khatib@ieee.org)
-- Organization: OpenIPCore Project
-- Created     :2001/01/11
-- Last update: 2001/01/26
-- Platform    : 
-- Simulators  : Modelsim 5.3XE/Windows98
-- Synthesizers: 
-- Target      : 
-- Dependency  : ieee.std_logic_1164
--
-------------------------------------------------------------------------------
-- Description:  Transmit Channel
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
-- Date            :   16 Jan 2001
-- Modifier        :   Jamil Khatib (khatib@ieee.org)
-- Desccription    :   Created
-- ToOptimize      :
-- Bugs            :   
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library hdlc;
use hdlc.hdlc_components_pkg.all;

entity TxChannel_ent is

  port (
    TxClk        : in  std_logic;       -- Tx Clock
    rst_n        : in  std_logic;       -- System Reset
    TXEN         : in  std_logic;       -- Tx Enable
    Tx           : out std_logic;       -- Tx serial Output
    ValidFrame   : in  std_logic;       -- Valid Frame
    AbortFrame   : in  std_logic;       -- Abort Frame
    AbortedTrans : out std_logic;       -- Aborted transmission
    WriteByte    : in  std_logic;       -- Write byte
    rdy          : out std_logic;       -- Ready signal
    TxData       : in  std_logic_vector(7 downto 0));  -- Tx Data bus

end TxChannel_ent;


architecture Txchannel_str of TxChannel_ent is

  signal TXD_i          : std_logic;    -- Internal TX signal
  signal enable_i       : std_logic;    -- Internal Enable
  signal abortedTrans_i : std_logic;    -- Backend no valid data
  signal AbortTrans_i   : std_logic;    -- Internal Abort transmission signal
  signal Frame_i        : std_logic;
                                        -- Internal Frame strobe to flag insert block
  signal inProgress_i   : std_logic;    -- In progress internal signal

  signal BackendEnable_i : std_logic;   -- Backend Enable
begin  -- Txchannel_str

  AbortedTrans <= abortedTrans_i;

  FlagMachine : flag_ins_ent
    port map (
      TXclk      => TXclk,
      rst_n      => rst_n,
      TX         => TX,
      TXEN       => TXEN,
      TXD        => TXD_i,
      AbortFrame => AbortTrans_i,
      Frame      => Frame_i);

  BackendMachine : ZeroIns_ent
    port map (
      TxClk         => TxClk,
      rst_n         => rst_n,
      enable        => TXEN,
      BackendEnable => BackendEnable_i,
      abortedTrans  => abortedTrans_i,
      inProgress    => inProgress_i,
      ValidFrame    => ValidFrame,
      Writebyte     => Writebyte,
      rdy           => rdy,
      TXD           => TXD_i,
      Data          => TxData);

  Txcontroller : TxCont_ent
    port map (
      TXclk         => TXclk,
      rst_n         => rst_n,
      TXEN          => TXEN,
      enable        => enable_i,
      BackendEnable => BackendEnable_i,
      abortedTrans  => abortedTrans_i,
      inProgress    => inProgress_i,
      Frame         => Frame_i,
      ValidFrame    => ValidFrame,
      AbortFrame    => AbortFrame,
      AbortTrans    => AbortTrans_i);

end Txchannel_str;
