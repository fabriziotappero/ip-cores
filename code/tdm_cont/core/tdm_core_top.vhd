-------------------------------------------------------------------------------
-- Title      : TDM controller top
-- Project    : TDM controller
-------------------------------------------------------------------------------
-- File       : tdm_cont_top.vhd
-- Author     : Jamil Khatib  <khatib@ieee.org>
-- Organization:  OpenCores.org
-- Created    : 2001/05/14
-- Last update:2001/05/22
-- Platform   : 
-- Simulators  : NC-sim/linux, Modelsim XE/windows98
-- Synthesizers: Leonardo
-- Target      : 
-- Dependency  : ieee.std_logic_1164
--               tdm.components_pkg
-------------------------------------------------------------------------------
-- Description:  tdm controller that reads and writes E1 bit rate through
-- ST-bus interface
-------------------------------------------------------------------------------
-- Copyright (c) 2001  Jamil Khatib
-- 
-- This VHDL design file is an open design; you can redistribute it and/or
-- modify it and/or implement it after contacting the author
-- You can check the draft license at
-- http://www.opencores.org/OIPC/license.shtml
-------------------------------------------------------------------------------
-- Revisions  :
-- Revision Number :   1
-- Version         :   0.1
-- Date            :  2001/05/09
-- Modifier        :  Jamil Khatib  <khatib@ieee.org>
-- Desccription    :  Created
-- ToOptimize      :
-- Known Bugs      : 
-------------------------------------------------------------------------------
-- $Log: not supported by cvs2svn $
-- Revision 1.1  2001/05/24 22:48:56  jamil
-- TDM Initial release
--
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

LIBRARY tdm;
USE tdm.components_pkg.ALL;

ENTITY tdm_cont_top_ent IS

  PORT (
    -- Wishbone Interface
    CLK_I  : IN  STD_LOGIC;             -- system clock
    RST_I  : IN  STD_LOGIC;             -- system reset
    ACK_O  : OUT STD_LOGIC;             -- acknowledge
    ADR_I  : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);  -- address
    CYC_I  : IN  STD_LOGIC;             -- Bus cycle
    DAT_I  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);  -- Input data
    DAT_O  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);  -- Output data
    RTY_O  : OUT STD_LOGIC;             -- retry
    STB_I  : IN  STD_LOGIC;             -- strobe
    WE_I   : IN  STD_LOGIC;             -- Write
    TAG0_O : OUT STD_LOGIC;             -- TAG0 (TxDone)
    TAG1_O : OUT STD_LOGIC;             -- TAG1_O (RxRdy)
-- ST-Bus interface
    C2     : IN  STD_LOGIC;             -- ST-Bus clock
    DSTi   : IN  STD_LOGIC;             -- ST-Bus input Data
    DSTo   : OUT STD_LOGIC;             -- ST-Bus output Data
    F0_n   : IN  STD_LOGIC;             -- St-Bus Framing pulse
    F0od_n : OUT STD_LOGIC              -- ST-Bus Delayed Framing pulse

    );

END tdm_cont_top_ent;


ARCHITECTURE tdm_top_str OF tdm_cont_top_ent IS


  SIGNAL rst_n        : STD_LOGIC;
  SIGNAL NoChannels   : STD_LOGIC_VECTOR(4 DOWNTO 0);
  SIGNAL DropChannels : STD_LOGIC_VECTOR(4 DOWNTO 0);
  SIGNAL RxD          : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL TxD          : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL Tx_en0       : STD_LOGIC;
  SIGNAL Tx_en1       : STD_LOGIC;
  SIGNAL Tx_en2       : STD_LOGIC;
  SIGNAL Rx_en0       : STD_LOGIC;
  SIGNAL Rx_en1       : STD_LOGIC;
  SIGNAL Rx_en2       : STD_LOGIC;
  SIGNAL SerDo        : STD_LOGIC;
  SIGNAL SerDi        : STD_LOGIC;

  SIGNAL TxValidData : STD_LOGIC;
  SIGNAL TxWrite     : STD_LOGIC;
  SIGNAL TxRdy       : STD_LOGIC;

  SIGNAL RxRead          : STD_LOGIC;
  SIGNAL RxRdy           : STD_LOGIC;
  SIGNAL RxValidData     : STD_LOGIC;
  SIGNAL BufferDataAvail : STD_LOGIC;
  SIGNAL RxLineOverflow  : STD_LOGIC;


  SIGNAL TxDone      : STD_LOGIC;
  SIGNAL WrBuff      : STD_LOGIC;
  SIGNAL TxData      : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL TxOverflow  : STD_LOGIC;
  SIGNAL TxUnderflow : STD_LOGIC;
  SIGNAL ReadBuff    : STD_LOGIC;
  SIGNAL RxData      : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL RxOverflow  : STD_LOGIC;
  SIGNAL HDLCen      : STD_LOGIC;


BEGIN  -- tdm_top_str

  rst_n <= NOT RST_I;


  tdm_cont : tdm_cont_ent
    PORT MAP (
      rst_n          => rst_n,
      C2             => C2,
      DSTi           => DSTi,
      DSTo           => DSTo,
      F0_n           => F0_n,
      F0od_n         => F0od_n,
      CLK_I          => CLK_I,
      NoChannels     => NoChannels,
      DropChannels   => DropChannels,
      RxD            => RxD,
      RxValidData    => RxValidData,
      FramErr        => RxLineOverflow,
      RxRead         => RxRead,
      RxRdy          => RxRdy,
      TxErr          => TxUnderflow,
      TxD            => TxD,
      TxValidData    => TxValidData,
      TxWrite        => TxWrite,
      TxRdy          => TxRdy,
      EnableSerialIF => HDLCen,
      Tx_en0         => Tx_en0,
      Tx_en1         => Tx_en1,
      Tx_en2         => Tx_en2,
      Rx_en0         => Rx_en0,
      Rx_en1         => Rx_en1,
      Rx_en2         => Rx_en2,
      SerDo          => SerDo,
      SerDi          => SerDi);

  TxBuff : TxTDMBuff
    PORT MAP (
      CLK_I       => CLK_I,
      rst_n       => rst_n,
      TxD         => TxD,
      TxValidData => TxValidData,
      TxWrite     => TxWrite,
      TxRdy       => TxRdy,
      WrBuff      => WrBuff,
      TxData      => TxData,
      NoChannels  => NoChannels,
      DropChannels => DropChannels,
      TxDone      => TxDone,
      TxOverflow  => TxOverflow);

  RxBuff : RxTDMBuff
    PORT MAP (
      CLK_I           => CLK_I,
      rst_n           => rst_n,
      RxD             => RxD,
      RxRead          => RxRead,
      RxRdy           => RxRdy,
      RxValidData     => RxValidData,
      BufferDataAvail => BufferDataAvail,
      ReadBuff        => ReadBuff,
      RxData          => RxData,
      RxError         => RxOverflow);


  wb_if : tdm_wb_if_ent
    PORT MAP (
      CLK_I          => CLK_I,
      RST_I          => RST_I,
      ACK_O          => ACK_O,
      ADR_I          => ADR_I,
      CYC_I          => CYC_I,
      DAT_I          => DAT_I,
      DAT_O          => DAT_O,
      RTY_O          => RTY_O,
      STB_I          => STB_I,
      WE_I           => WE_I,
      TAG0_O         => TAG0_O,
      TAG1_O         => TAG1_O,
      TxDone         => TxDone,
      WrBuff         => WrBuff,
      TxData         => TxData,
      TxOverflow     => TxOverflow,
      TxUnderflow    => TxUnderflow,
      RxRdy          => BufferDataAvail,
      ReadBuff       => ReadBuff,
      RxData         => RxData,
      RxOverflow     => RxOverflow,
      RxLineOverflow => RxLineOverflow,
      HDLCen         => HDLCen,
      NoChannels     => NoChannels,
      DropChannels   => DropChannels);


END tdm_top_str;
