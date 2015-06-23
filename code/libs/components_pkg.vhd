-------------------------------------------------------------------------------
-- Title      : ISDN tdm controller
-- Project    : TDM controller
-------------------------------------------------------------------------------
-- File       : components_pkg.vhd
-- Author     : Jamil Khatib  <khatib@ieee.org>
-- Organization:  OpenCores.org
-- Created    : 2001/05/06
-- Last update:2001/05/22
-- Platform   : 
-- Simulators  : NC-sim/linux, Modelsim XE/windows98
-- Synthesizers: Leonardo
-- Target      : 
-- Dependency  : ieee.std_logic_1164
-------------------------------------------------------------------------------
-- Description:  tdm components
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
-- Date            :  2001/05/06
-- Modifier        :  Jamil Khatib  <khatib@ieee.org>
-- Desccription    :  Created
-- ToOptimize      :
-- Known Bugs      : 
-------------------------------------------------------------------------------
-- $Log: not supported by cvs2svn $
-- Revision 1.3  2001/05/24 22:46:33  jamil
-- TDM components added
--
-- Revision 1.2  2001/05/18 09:09:02  jamil
-- TDM components added
--
--
-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

PACKAGE components_pkg IS

  COMPONENT isdn_cont_ent
    PORT (
      rst_n     : IN  STD_LOGIC;
      C2        : IN  STD_LOGIC;
      DSTi      : IN  STD_LOGIC;
      DSTo      : OUT STD_LOGIC;
      F0_n      : IN  STD_LOGIC;
      F0od_n    : OUT STD_LOGIC;
      HDLCen1   : OUT STD_LOGIC;
      HDLCen2   : OUT STD_LOGIC;
      HDLCen3   : OUT STD_LOGIC;
      HDLCTxen1 : OUT STD_LOGIC;
      HDLCTxen2 : OUT STD_LOGIC;
      HDLCTxen3 : OUT STD_LOGIC;
      Dout      : OUT STD_LOGIC;
      Din1      : IN  STD_LOGIC;
      Din2      : IN  STD_LOGIC;
      Din3      : IN  STD_LOGIC);
  END COMPONENT;



  COMPONENT tdm_cont_ent
    PORT (
      rst_n          : IN  STD_LOGIC;
      C2             : IN  STD_LOGIC;
      DSTi           : IN  STD_LOGIC;
      DSTo           : OUT STD_LOGIC;
      F0_n           : IN  STD_LOGIC;
      F0od_n         : OUT STD_LOGIC;
      CLK_I          : IN  STD_LOGIC;
      NoChannels     : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
      DropChannels   : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
      RxD            : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      RxValidData    : OUT STD_LOGIC;
      FramErr        : OUT STD_LOGIC;
      RxRead         : IN  STD_LOGIC;
      RxRdy          : OUT STD_LOGIC;
      TxErr          : OUT STD_LOGIC;
      TxD            : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      TxValidData    : IN  STD_LOGIC;
      TxWrite        : IN  STD_LOGIC;
      TxRdy          : OUT STD_LOGIC;
      EnableSerialIF : IN  STD_LOGIC;
      Tx_en0         : OUT STD_LOGIC;
      Tx_en1         : OUT STD_LOGIC;
      Tx_en2         : OUT STD_LOGIC;
      Rx_en0         : OUT STD_LOGIC;
      Rx_en1         : OUT STD_LOGIC;
      Rx_en2         : OUT STD_LOGIC;
      SerDo          : OUT STD_LOGIC;
      SerDi          : IN  STD_LOGIC);
  END COMPONENT;


  COMPONENT TxTDMBuff
    PORT (
      CLK_I       : IN  STD_LOGIC;
      rst_n       : IN  STD_LOGIC;
      TxD         : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      TxValidData : OUT STD_LOGIC;
      TxWrite     : OUT STD_LOGIC;
      TxRdy       : IN  STD_LOGIC;
      WrBuff      : IN  STD_LOGIC;
      TxData      : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      DropChannels : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
      NoChannels  : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
      TxDone      : OUT STD_LOGIC;
      TxOverflow  : OUT STD_LOGIC);
  END COMPONENT;

  COMPONENT RxTDMBuff
    PORT (
      CLK_I           : IN  STD_LOGIC;
      rst_n           : IN  STD_LOGIC;
      RxD             : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      RxRead          : OUT STD_LOGIC;
      RxRdy           : IN  STD_LOGIC;
      RxValidData     : IN  STD_LOGIC;
      BufferDataAvail : OUT STD_LOGIC;
      ReadBuff        : IN  STD_LOGIC;
      RxData          : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      RxError         : OUT STD_LOGIC);
  END COMPONENT;


  COMPONENT tdm_cont_top_ent
    PORT (
      CLK_I  : IN  STD_LOGIC;
      RST_I  : IN  STD_LOGIC;
      ACK_O  : OUT STD_LOGIC;
      ADR_I  : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
      CYC_I  : IN  STD_LOGIC;
      DAT_I  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
      DAT_O  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      RTY_O  : OUT STD_LOGIC;
      STB_I  : IN  STD_LOGIC;
      WE_I   : IN  STD_LOGIC;
      TAG0_O : OUT STD_LOGIC;
      TAG1_O : OUT STD_LOGIC;
      C2     : IN  STD_LOGIC;
      DSTi   : IN  STD_LOGIC;
      DSTo   : OUT STD_LOGIC;
      F0_n   : IN  STD_LOGIC;
      F0od_n : OUT STD_LOGIC);
  END COMPONENT;


  COMPONENT tdm_wb_if_ent
    PORT (
      CLK_I          : IN  STD_LOGIC;
      RST_I          : IN  STD_LOGIC;
      ACK_O          : OUT STD_LOGIC;
      ADR_I          : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
      CYC_I          : IN  STD_LOGIC;
      DAT_I          : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
      DAT_O          : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      RTY_O          : OUT STD_LOGIC;
      STB_I          : IN  STD_LOGIC;
      WE_I           : IN  STD_LOGIC;
      TAG0_O         : OUT STD_LOGIC;
      TAG1_O         : OUT STD_LOGIC;
      TxDone         : IN  STD_LOGIC;
      WrBuff         : OUT STD_LOGIC;
      TxData         : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      TxOverflow     : IN  STD_LOGIC;
      TxUnderflow    : IN  STD_LOGIC;
      RxRdy          : IN  STD_LOGIC;
      ReadBuff       : OUT STD_LOGIC;
      RxData         : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      RxOverflow     : IN  STD_LOGIC;
      RxLineOverflow : IN  STD_LOGIC;
      HDLCen         : OUT STD_LOGIC;
      NoChannels     : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
      DropChannels   : OUT STD_LOGIC_VECTOR(4 DOWNTO 0));
  END COMPONENT;

END components_pkg;
