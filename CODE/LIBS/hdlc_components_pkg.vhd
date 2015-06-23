-------------------------------------------------------------------------------
-- Title      :  HDLC components package
-- Project    :  HDLC controller
-------------------------------------------------------------------------------
-- File        : hdlc_components_pkg.vhd
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
-- Description:  HDLC components package
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
-- Desccription    :   RxEnable bug fixed
--
-------------------------------------------------------------------------------
-- Revisions  :
-- Revision Number :   3
-- Version         :   0.3
-- Date            :   16 Jan 2001
-- Modifier        :   Jamil Khatib (khatib@ieee.org)
-- Desccription    :   TX componentes added
--
-------------------------------------------------------------------------------
-- Revision Number :   4
-- Version         :   0.4
-- Date            :   22 March 2001
-- Modifier        :   Jamil Khatib (khatib@ieee.org)
-- Desccription    :   Tx Top components added
--
-------------------------------------------------------------------------------
-- Revision Number :   5
-- Version         :   0.5
-- Date            :   9 April 2001
-- Modifier        :   Jamil Khatib (khatib@ieee.org)
-- Desccription    :   Rx Top components added
--
-------------------------------------------------------------------------------
-- $Log: not supported by cvs2svn $
-- Revision 1.11  2001/04/27 18:21:59  jamil
-- After Prelimenray simulation
--
-- Revision 1.10  2001/04/22 20:08:16  jamil
-- Top level simulation
--
-- Revision 1.7  2001/04/14 15:23:34  jamil
-- Rx Components added
--
-- Revision 1.6  2001/03/22 21:58:46  jamil
-- Top Tx Components added
--
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package hdlc_components_pkg is

  component hdlc_ent
    generic (
      FCS_TYPE  :     integer;
      ADD_WIDTH :     integer);
    port (
      Txclk     : in  std_logic;
      RxClk     : in  std_logic;
      Tx        : out std_logic;
      Rx        : in  std_logic;
      TxEN      : in  std_logic;
      RxEn      : in  std_logic;
      RST_I     : in  std_logic;
      CLK_I     : in  std_logic;
      ADR_I     : in  std_logic_vector(2 downto 0);
      DAT_O     : out std_logic_vector(31 downto 0);
      DAT_I     : in  std_logic_vector(31 downto 0);
      WE_I      : in  std_logic;
      STB_I     : in  std_logic;
      ACK_O     : out std_logic;
      CYC_I     : in  std_logic;
      RTY_O     : out std_logic;
      TAG0_O    : out std_logic;
      TAG1_O    : out std_logic);
  end component;


  constant ADD_WIDTH :     integer := 7;  -- Internal Buffers address width
  component WB_IF_ent
    generic (
      ADD_WIDTH      :     integer);
    port (
      CLK_I          : in  std_logic;
      RST_I          : in  std_logic;
      ACK_O          : out std_logic;
      ADR_I          : in  std_logic_vector(2 downto 0);
      CYC_I          : in  std_logic;
      DAT_I          : in  std_logic_vector(31 downto 0);
      DAT_O          : out std_logic_vector(31 downto 0);
      RTY_O          : out std_logic;
      STB_I          : in  std_logic;
      WE_I           : in  std_logic;
      TAG0_O         : out std_logic;
      TAG1_O         : out std_logic;
      TxEnable       : out std_logic;
      TxDone         : in  std_logic;
      TxDataInBuff   : out std_logic_vector(7 downto 0);
      Txwr           : out std_logic;
      TxAborted      : in  std_logic;
      TxAbort        : out std_logic;
      TxOverflow     : in  std_logic;
      TxFCSen        : out std_logic;
      RxFrameSize    : in  std_logic_vector(ADD_WIDTH-1 downto 0);
      RxRdy          : in  std_logic;
      RxDataBuffOut  : in  std_logic_vector(7 downto 0);
      RxOverflow     : in  std_logic;
      RxFrameError   : in  std_logic;
      RxFCSErr       : in  std_logic;
      RxRd           : out std_logic;
      RxAbort        : in  std_logic);
  end component;

  component txSynch_ent
    port (
      rst_n           : in  std_logic;
      clk_D1          : in  std_logic;
      clk_D2          : in  std_logic;
      rdy_D1          : in  std_logic;
      rdy_D2          : out std_logic;
      ack             : out std_logic;
      TXD_D1          : out std_logic_vector(7 downto 0);
      TXD_D2          : in  std_logic_vector(7 downto 0);
      ValidFrame_D1   : out std_logic;
      ValidFrame_D2   : in  std_logic;
      AbortedTrans_D1 : in  std_logic;
      AbortedTrans_D2 : out std_logic;
      AbortFrame_D1   : out std_logic;
      AbortFrame_D2   : in  std_logic;
      WriteByte_D1    : out std_logic;
      WriteByte_D2    : in  std_logic);
  end component;

  component Txfcs_ent
    generic (
      FCS_TYPE    :     integer);
    port (
      TxClk       : in  std_logic;
      rst_n       : in  std_logic;
      FCSen       : in  std_logic;
      ValidFrame  : out std_logic;
      WriteByte   : out std_logic;
      rdy         : in  std_logic;
      ack         : in  std_logic;
      TxData      : out std_logic_vector(7 downto 0);
      TxDataAvail : in  std_logic;
      RdBuff      : out std_logic;
      TxDataBuff  : in  std_logic_vector(7 downto 0));
  end component;

  component TxBuff_ent
    generic (
      ADD_WIDTH     :     integer);
    port (
      TxClk         : in  std_logic;
      rst_n         : in  std_logic;
      RdBuff        : in  std_logic;
      Wr            : in  std_logic;
      TxDataAvail   : out std_logic;
      TxEnable      : in  std_logic;
      TxDone        : out std_logic;
      TxDataOutBuff : out std_logic_vector(7 downto 0);
      TxDataInBuff  : in  std_logic_vector(7 downto 0);
      Full          : out std_logic);
  end component;

  component TxChannel_ent
    port (
      TxClk        : in  std_logic;
      rst_n        : in  std_logic;
      TXEN         : in  std_logic;
      Tx           : out std_logic;
      ValidFrame   : in  std_logic;
      AbortFrame   : in  std_logic;
      AbortedTrans : out std_logic;
      WriteByte    : in  std_logic;
      rdy          : out std_logic;
      TxData       : in  std_logic_vector(7 downto 0));
  end component;

  component TxCont_ent
    port (
      TXclk         : in  std_logic;
      rst_n         : in  std_logic;
      TXEN          : in  std_logic;
      enable        : out std_logic;
      BackendEnable : out std_logic;
      abortedTrans  : in  std_logic;
      inProgress    : in  std_logic;
      ValidFrame    : in  std_logic;
      Frame         : out std_logic;
      AbortFrame    : in  std_logic;
      AbortTrans    : out std_logic);
  end component;

  component flag_ins_ent
    port (
      TXclk      : in  std_logic;
      rst_n      : in  std_logic;
      TX         : out std_logic;
      TXEN       : in  std_logic;
      TXD        : in  std_logic;
      AbortFrame : in  std_logic;
      Frame      : in  std_logic);
  end component;

  component ZeroIns_ent
    port (
      TxClk         : in  std_logic;
      rst_n         : in  std_logic;
      enable        : in  std_logic;
      BackendEnable : in  std_logic;
      abortedTrans  : out std_logic;
      inProgress    : out std_logic;
      ValidFrame    : in  std_logic;
      Writebyte     : in  std_logic;
      rdy           : out std_logic;
      TXD           : out std_logic;
      Data          : in  std_logic_vector(7 downto 0));
  end component;

  component rxcont_ent
    port (
      RxClk        : in  std_logic;
      rst          : in  std_logic;
      RxEn         : in  std_logic;
      AbortedFrame : out std_logic;
      Abort        : in  std_logic;
      FlagDetect   : in  std_logic;
      ValidFrame   : out std_logic;
      FrameError   : out std_logic;
      aval         : in  std_logic;
      initzero     : out std_logic;
      enable       : out std_logic);
  end component;


  component ZeroDetect_ent
    port (
      ValidFrame   : in  std_logic;     --New
      Readbyte     : in  std_logic;
      aval         : out std_logic;
      enable       : in  std_logic;
      StartOfFrame : in  std_logic;
      rdy          : out std_logic;
      rst          : in  std_logic;
      RxClk        : in  std_logic;
      RxD          : in  std_logic;
      RxData       : out std_logic_vector(7 downto 0));
  end component;

  component FlagDetect_ent
    port (
      Rxclk      : in  std_logic;
      rst        : in  std_logic;
      FlagDetect : out std_logic;
      Abort      : out std_logic;
      RXEN       : in  std_logic;
      RXEN_O     : out std_logic;
      RXD        : out std_logic;
      RX         : in  std_logic);
  end component;

  component RxChannel_ent
    port (
      Rxclk       : in  std_logic;
      rst         : in  std_logic;
      Rx          : in  std_logic;
      RxData      : out std_logic_vector(7 downto 0);
      ValidFrame  : out std_logic;
      AbortSignal : out std_logic;
      FrameError  : out std_logic;
      Readbyte    : in  std_logic;
      rdy         : out std_logic;
      RxEn        : in  std_logic);
  end component;

  component RxSynch_ent
    port (
      rst_n          : in  std_logic;
      clk_D1         : in  std_logic;
      clk_D2         : in  std_logic;
      rdy_D1         : in  std_logic;
      rdy_D2         : out std_logic;
      RXD_D1         : in  std_logic_vector(7 downto 0);
      RXD_D2         : out std_logic_vector(7 downto 0);
      ValidFrame_D1  : in  std_logic;
      ValidFrame_D2  : out std_logic;
      AbortSignal_D1 : in  std_logic;
      AbortSignal_D2 : out std_logic;
      FrameError_D1  : in  std_logic;
      FrameError_D2  : out std_logic;
      ReadByte_D1    : out std_logic;
      ReadByte_D2    : in  std_logic);
  end component;

  component RxFCS_ent
    generic (
      FCS_TYPE   :     integer);
    port (
      clk        : in  std_logic;
      rst_n      : in  std_logic;
      RxD        : in  std_logic_vector(7 downto 0);
      ValidFrame : in  std_logic;
      rdy        : in  std_logic;
      Readbyte   : out std_logic;
      DataBuff   : out std_logic_vector(7 downto 0);
      WrBuff     : out std_logic;
      EOF        : out std_logic;
      FCSen      : in  std_logic;
      FCSerr     : out std_logic);
  end component;

  component RxBuff_ent
    generic (
      FCS_TYPE      :     integer;
      ADD_WIDTH     :     integer);
    port (
      Clk           : in  std_logic;
      rst_n         : in  std_logic;
      DataBuff      : in  std_logic_vector(7 downto 0);
      EOF           : in  std_logic;
      WrBuff        : in  std_logic;
      FrameSize     : out std_logic_vector(ADD_WIDTH-1 downto 0);
      RxRdy         : out std_logic;
      RxDataBuffOut : out std_logic_vector(7 downto 0);
      Overflow      : out std_logic;
      Rd            : in  std_logic);
  end component;

end hdlc_components_pkg;
