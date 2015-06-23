-------------------------------------------------------------------------------
-- Title      : ISDN tdm controller
-- Project    : TDM controller
-------------------------------------------------------------------------------
-- File       : ISDN_cont_top.vhd
-- Author     : Jamil Khatib  <khatib@ieee.org>
-- Organization:  OpenCores.org
-- Created    : 2001/05/06
-- Last update:2001/05/06
-- Platform   : 
-- Simulators  : NC-sim/linux, Modelsim XE/windows98
-- Synthesizers: Leonardo
-- Target      : 
-- Dependency  : ieee.std_logic_1164
--               tdm.components_pkg
--               hdlc.hdlc_components_pkg
-------------------------------------------------------------------------------
-- Description:  ISDN tdm controller that extracts 2B+D channels from 3 time
-- slots of the incoming streem (Top Block)
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
-- Revision 1.2  2001/05/08 21:10:41  jamil
-- Initial release
--
--
-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

LIBRARY hdlc;
USE hdlc.hdlc_components_pkg.ALL;

LIBRARY tdm;
USE tdm.components_pkg.ALL;

ENTITY isdn_cont_top_ent IS

  PORT (
    C2     : IN  STD_LOGIC;             -- ST-Bus clock
    DSTi   : IN  STD_LOGIC;             -- ST-Bus input Data
    DSTo   : OUT STD_LOGIC;             -- ST-Bus output Data
    F0_n   : IN  STD_LOGIC;             -- St-Bus Framing pulse
    F0od_n : OUT STD_LOGIC;             -- ST-Bus Delayed Framing pulse
    RST_I  : IN  STD_LOGIC;
    CLK_I  : IN  STD_LOGIC;

-- B1      Channel
    ADR_I_B1  : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
    DAT_O_B1  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    DAT_I_B1  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
    WE_I_B1   : IN  STD_LOGIC;
    STB_I_B1  : IN  STD_LOGIC;
    ACK_O_B1  : OUT STD_LOGIC;
    CYC_I_B1  : IN  STD_LOGIC;
    RTY_O_B1  : OUT STD_LOGIC;
    TAG0_O_B1 : OUT STD_LOGIC;
    TAG1_O_B1 : OUT STD_LOGIC;

-- B2     Channel
    ADR_I_B2  : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
    DAT_O_B2  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    DAT_I_B2  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
    WE_I_B2   : IN  STD_LOGIC;
    STB_I_B2  : IN  STD_LOGIC;
    ACK_O_B2  : OUT STD_LOGIC;
    CYC_I_B2  : IN  STD_LOGIC;
    RTY_O_B2  : OUT STD_LOGIC;
    TAG0_O_B2 : OUT STD_LOGIC;
    TAG1_O_B2 : OUT STD_LOGIC;

-- D     Channel
    ADR_I_D  : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
    DAT_O_D  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    DAT_I_D  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
    WE_I_D   : IN  STD_LOGIC;
    STB_I_D  : IN  STD_LOGIC;
    ACK_O_D  : OUT STD_LOGIC;
    CYC_I_D  : IN  STD_LOGIC;
    RTY_O_D  : OUT STD_LOGIC;
    TAG0_O_D : OUT STD_LOGIC;
    TAG1_O_D : OUT STD_LOGIC

    );

END isdn_cont_top_ent;

-------------------------------------------------------------------------------

ARCHITECTURE isdn_cont_top_str OF isdn_cont_top_ent IS

  SIGNAL HDLCen1   : STD_LOGIC;
  SIGNAL HDLCen2   : STD_LOGIC;
  SIGNAL HDLCen3   : STD_LOGIC;
  SIGNAL HDLCTxen1 : STD_LOGIC;
  SIGNAL HDLCTxen2 : STD_LOGIC;
  SIGNAL HDLCTxen3 : STD_LOGIC;
  SIGNAL Dout      : STD_LOGIC;
  SIGNAL Din1      : STD_LOGIC;
  SIGNAL Din2      : STD_LOGIC;
  SIGNAL Din3      : STD_LOGIC;

BEGIN  -- isdn_cont_top_str
-------------------------------------------------------------------------------


  ST_IF : isdn_cont_ent
    PORT MAP (
      rst_n     => RST_I,
      C2        => C2,
      DSTi      => DSTi,
      DSTo      => DSTo,
      F0_n      => F0_n,
      F0od_n    => F0od_n,
      HDLCen1   => HDLCen1,
      HDLCen2   => HDLCen2,
      HDLCen3   => HDLCen3,
      HDLCTxen1 => HDLCTxen1,
      HDLCTxen2 => HDLCTxen2,
      HDLCTxen3 => HDLCTxen3,
      Dout      => Dout,
      Din1      => Din1,
      Din2      => Din2,
      Din3      => Din3);

  B1_Channel : hdlc_ent
    GENERIC MAP (
      FCS_TYPE  => 2,
      ADD_WIDTH => 7)
    PORT MAP (
      Txclk     => C2,
      RxClk     => C2,
      Tx        => Din1,
      Rx        => Dout,
      TxEN      => HDLCTxen1,
      RxEn      => HDLCen1,
      RST_I     => RST_I,
      CLK_I     => CLK_I,
      ADR_I     => ADR_I_B1,
      DAT_O     => DAT_O_B1,
      DAT_I     => DAT_I_B1,
      WE_I      => WE_I_B1,
      STB_I     => STB_I_B1,
      ACK_O     => ACK_O_B1,
      CYC_I     => CYC_I_B1,
      RTY_O     => RTY_O_B1,
      TAG0_O    => TAG0_O_B1,
      TAG1_O    => TAG1_O_B1);


  B2_Channel : hdlc_ent
    GENERIC MAP (
      FCS_TYPE  => 2,
      ADD_WIDTH => 7)
    PORT MAP (
      Txclk     => c2,
      RxClk     => c2,
      Tx        => Din2,
      Rx        => Dout,
      TxEN      => HDLCTxen2,
      RxEn      => HDLCen2,
      RST_I     => RST_I,
      CLK_I     => CLK_I,
      ADR_I     => ADR_I_B2,
      DAT_O     => DAT_O_B2,
      DAT_I     => DAT_I_B2,
      WE_I      => WE_I_B2,
      STB_I     => STB_I_B2,
      ACK_O     => ACK_O_B2,
      CYC_I     => CYC_I_B2,
      RTY_O     => RTY_O_B2,
      TAG0_O    => TAG0_O_B2,
      TAG1_O    => TAG1_O_B2);


  D_Channel : hdlc_ent
    GENERIC MAP (
      FCS_TYPE  => 2,
      ADD_WIDTH => 7)
    PORT MAP (
      Txclk     => c2,
      RxClk     => c2,
      Tx        => Din3,
      Rx        => Dout,
      TxEN      => HDLCTxen3,
      RxEn      => HDLCen3,
      RST_I     => RST_I,
      CLK_I     => CLK_I,
      ADR_I     => ADR_I_D,
      DAT_O     => DAT_O_D,
      DAT_I     => DAT_I_D,
      WE_I      => WE_I_D,
      STB_I     => STB_I_D,
      ACK_O     => ACK_O_D,
      CYC_I     => CYC_I_D,
      RTY_O     => RTY_O_D,
      TAG0_O    => TAG0_O_D,
      TAG1_O    => TAG1_O_D);

-------------------------------------------------------------------------------
END isdn_cont_top_str;
