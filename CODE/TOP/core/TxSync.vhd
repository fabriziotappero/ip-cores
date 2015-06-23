-------------------------------------------------------------------------------
-- Title      : Tx Synchronizer
-- Project    : HDLC controller
-------------------------------------------------------------------------------
-- File       : TxSync.vhd
-- Author     : Jamil Khatib  <khatib@ieee.org>
-- Organization: OpenIPCore Project
-- Created    : 2001/03/22
-- Last update: 2001/03/22
-- Platform   : 
-- Simulators  : Modelsim/Win98 , NC-sim/Linux
-- Synthesizers: 
-- Target      : 
-- Dependency  : ieee.std_logic
-------------------------------------------------------------------------------
-- Description: Tx Synchronizer
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
-- Date            :  2001/03/22
-- Modifier        :  Jamil Khatib  <khatib@ieee.org>
-- Desccription    :  Created
-- ToOptimize      :
-- Known Bugs      :
-------------------------------------------------------------------------------
-- $Log: not supported by cvs2svn $
-- Revision 1.1  2001/03/22 21:58:01  jamil
-- Initial release
--
-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY txSynch_ent IS
  -- D1 Domain 1 = Serial line
  -- D2 Domain 2 = System interface
  PORT (
    rst_n           : IN  std_logic;    -- System reset
    clk_D1          : IN  std_logic;    -- Domain 1 clock
    clk_D2          : IN  std_logic;    -- Domain 2 clock
    rdy_D1          : IN  std_logic;    -- Domain 1 ready
    rdy_D2          : OUT std_logic;    -- Domain 2 ready
    ack             : OUT std_logic;    -- Acknowldege signals
    TXD_D1          : OUT std_logic_vector(7 DOWNTO 0);  -- Domain 1 Tx Data bus
    TXD_D2          : IN  std_logic_vector(7 DOWNTO 0);  -- Domain 2 Tx Data Bus
    ValidFrame_D1   : OUT std_logic;    -- Domain 1 Valid Frame
    ValidFrame_D2   : IN  std_logic;    -- Domain 2 Valid Frame
    AbortedTrans_D1 : IN  std_logic;    -- Domain 1 Aborted Transmission
    AbortedTrans_D2 : OUT std_logic;    -- Domain 2 Aborted Transmission
    AbortFrame_D1   : OUT std_logic;    -- Domain 1 Abort Frame
    AbortFrame_D2   : IN  std_logic;    -- Domain 2 Abort Frame
    WriteByte_D1    : OUT std_logic;    -- Domain 1 Write Byte
    WriteByte_D2    : IN  std_logic     -- Domain 2 Write Byte

    );

END txSynch_ent;
-------------------------------------------------------------------------------

ARCHITECTURE TxSynch_rtl OF txSynch_ent IS
  SIGNAL ack_i : std_logic;                 -- ack signal

BEGIN  -- ARCHITECTURE TxSynch_rtl

-- Data bus does not need synchronization  
  TXD_D1 <= TXD_D2;

  -- purpose: rdy signal
  -- type   : sequential
  -- inputs : clk_D2, rst_n
  -- outputs: 
  Rdy_signal     : PROCESS (clk_D2, rst_n)
    VARIABLE FF1 : std_logic;
  BEGIN  -- PROCESS Rdy_signal
    IF rst_n = '0' THEN                 -- asynchronous reset (active low)
      FF1    := '0';
      rdy_D2 <= '0';
    ELSIF clk_D2'event AND clk_D2 = '1' THEN  -- rising clock edge
      rdy_D2 <= FF1;
      FF1    := rdy_D1;
    END IF;

  END PROCESS Rdy_signal;

  -- purpose: write bytes signal
  -- type   : sequential
  -- inputs : clk_D1, rst_n
  -- outputs: 
  Write_signal   : PROCESS (clk_D1, rst_n)
    VARIABLE FF1 : std_logic;
  BEGIN  -- PROCESS Write_signal
    IF rst_n = '0' THEN                 -- asynchronous reset (active low)
      FF1          := '0';
      WriteByte_D1 <= '0';
      ack_i <= '0';
    ELSIF clk_D1'event AND clk_D1 = '1' THEN  -- rising clock edge
      ack_i <= FF1;
      WriteByte_D1 <= FF1;
      FF1          := WriteByte_D2;
    END IF;
  END PROCESS Write_signal;

    -- purpose: ack signal
  -- type   : sequential
  -- inputs : clk_D2, rst_n
  -- outputs: 
  ack_signal   : PROCESS (clk_D2, rst_n)
    VARIABLE FF1 : std_logic;
  BEGIN  -- PROCESS ack_signal
    IF rst_n = '0' THEN                 -- asynchronous reset (active low)
      FF1          := '0';
      ack <= '0';
    ELSIF clk_D2'event AND clk_D2 = '1' THEN  -- rising clock edge
      ack <= FF1;
      FF1          := ack_i;
    END IF;
  END PROCESS ack_signal;
  
  -- purpose: Abort Frame signal
  -- type   : sequential
  -- inputs : clk_D1, rst_n
  -- outputs: 
  AbortFrame_signal : PROCESS (clk_D1, rst_n)
    VARIABLE FF1    : std_logic;
  BEGIN  -- PROCESS AbortFrame_signal
    IF rst_n = '0' THEN                 -- asynchronous reset (active low)
      FF1           := '0';
      AbortFrame_D1 <= '0';
    ELSIF clk_D1'event AND clk_D1 = '1' THEN  -- rising clock edge
      AbortFrame_D1 <= FF1;
      FF1           := AbortFrame_D2;
    END IF;
  END PROCESS AbortFrame_signal;

  -- purpose: Valid Frame signal
  -- type   : sequential
  -- inputs : clk_D1, rst_n
  -- outputs: 
  ValidFrame_signal : PROCESS (clk_D1, rst_n)
    VARIABLE FF1    : std_logic;
  BEGIN  -- PROCESS ValidFrame_signal
    IF rst_n = '0' THEN                 -- asynchronous reset (active low)
      FF1           := '0';
      ValidFrame_D1 <= '0';
    ELSIF clk_D1'event AND clk_D1 = '1' THEN  -- rising clock edge
      ValidFrame_D1 <= FF1;
      FF1           := ValidFrame_D2;
    END IF;
  END PROCESS ValidFrame_signal;

  -- purpose: Aborted Trans signal
  -- type   : sequential
  -- inputs : clk_D2, rst_n
  -- outputs: 
  AbortedTrans_signal : PROCESS (clk_D2, rst_n)
    VARIABLE FF1      : std_logic;
  BEGIN  -- PROCESS AbortedTrans_signal
    IF rst_n = '0' THEN                 -- asynchronous reset (active low)
      FF1             := '0';
      AbortedTrans_D2 <= '0';
    ELSIF clk_D2'event AND clk_D2 = '1' THEN  -- rising clock edge
      AbortedTrans_D2 <= FF1;
      FF1             := AbortedTrans_D1;
    END IF;
  END PROCESS AbortedTrans_signal;

END TxSynch_rtl;
