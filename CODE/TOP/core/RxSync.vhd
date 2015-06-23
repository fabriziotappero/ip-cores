-------------------------------------------------------------------------------
-- Title      : Rx Synchronizer
-- Project    : HDLC controller
-------------------------------------------------------------------------------
-- File       : RxSync.vhd
-- Author     : Jamil Khatib  <khatib@ieee.org>
-- Organization: OpenCores Project
-- Created    : 2001/04/04
-- Last update: 2001/04/04
-- Platform   : 
-- Simulators  : Modelsim/Win98 , NC-sim/Linux
-- Synthesizers: 
-- Target      : 
-- Dependency  : ieee.std_logic
-------------------------------------------------------------------------------
-- Description: Rx Synchronizer
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
-- Date            :  2001/04/04
-- Modifier        :  Jamil Khatib  <khatib@ieee.org>
-- Desccription    :  Created
-- ToOptimize      :
-- Known Bugs      :
-------------------------------------------------------------------------------
-- $Log: not supported by cvs2svn $
-- Revision 1.1  2001/04/14 15:02:25  jamil
-- Initial Release
--
-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY RxSynch_ent IS
  -- D1 Domain 1 = Serial line
  -- D2 Domain 2 = System interface
  PORT (
    rst_n          : IN  STD_LOGIC;     -- System reset
    clk_D1         : IN  STD_LOGIC;     -- Domain 1 clock
    clk_D2         : IN  STD_LOGIC;     -- Domain 2 clock
    rdy_D1         : IN  STD_LOGIC;     -- Domain 1 ready
    rdy_D2         : OUT STD_LOGIC;     -- Domain 2 ready
    RXD_D1         : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);  -- Domain 1 Rx Data bus
    RXD_D2         : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);  -- Domain 2 Rx Data Bus
    ValidFrame_D1  : IN  STD_LOGIC;     -- Domain 1 Valid Frame
    ValidFrame_D2  : OUT STD_LOGIC;     -- Domain 2 Valid Frame
    AbortSignal_D1 : IN  STD_LOGIC;     -- Domain 1 Abort signal
    AbortSignal_D2 : OUT STD_LOGIC;     -- Domain 2 Abort signal
    FrameError_D1  : IN  STD_LOGIC;     -- Domain 1 Frame Error
    FrameError_D2  : OUT STD_LOGIC;     -- Domain 2 Frame Error
    ReadByte_D1    : OUT STD_LOGIC;     -- Domain 1 Read Byte
    ReadByte_D2    : IN  STD_LOGIC      -- Domain 2 Read Byte

    );

END RxSynch_ent;
-------------------------------------------------------------------------------

ARCHITECTURE RxSynch_rtl OF RxSynch_ent IS

BEGIN  -- ARCHITECTURE RxSynch_rtl

-- Data bus does not need synchronization  
  RXD_D2 <= RXD_D1;

  -- purpose: rdy signal
  -- type   : sequential
  -- inputs : clk_D2, rst_n
  -- outputs: 
  Rdy_signal     : PROCESS (clk_D2, rst_n)
    VARIABLE FF1 : STD_LOGIC;
  BEGIN  -- PROCESS Rdy_signal
    IF rst_n = '0' THEN                 -- asynchronous reset (active low)
      FF1    := '0';
      rdy_D2 <= '0';
    ELSIF clk_D2'event AND clk_D2 = '1' THEN  -- rising clock edge
      rdy_D2 <= FF1;
      FF1    := rdy_D1;
    END IF;

  END PROCESS Rdy_signal;

  -- purpose: Read bytes signal
  -- type   : sequential
  -- inputs : clk_D1, rst_n
  -- outputs: 
  Read_signal    : PROCESS (clk_D1, rst_n)
    VARIABLE FF1 : STD_LOGIC;
  BEGIN  -- PROCESS Read_signal
    IF rst_n = '0' THEN                 -- asynchronous reset (active low)
      FF1         := '0';
      ReadByte_D1 <= '0';
    ELSIF clk_D1'event AND clk_D1 = '1' THEN  -- rising clock edge
      ReadByte_D1 <= FF1;
      FF1         := ReadByte_D2;
    END IF;
  END PROCESS Read_signal;


  -- purpose: Valid Frame signal
  -- type   : sequential
  -- inputs : clk_D2, rst_n
  -- outputs: 
  ValidFrame_signal : PROCESS (clk_D2, rst_n)
    VARIABLE FF1    : STD_LOGIC;
  BEGIN  -- PROCESS ValidFrame_signal
    IF rst_n = '0' THEN                 -- asynchronous reset (active low)
      FF1           := '0';
      ValidFrame_D2 <= '0';
    ELSIF clk_D2'event AND clk_D2 = '1' THEN  -- rising clock edge
      ValidFrame_D2 <= FF1;
      FF1           := ValidFrame_D1;
    END IF;
  END PROCESS ValidFrame_signal;

  -- purpose: Abort  signal
  -- type   : sequential
  -- inputs : clk_D2, rst_n
  -- outputs: 
  Abort_signal   : PROCESS (clk_D2, rst_n)
    VARIABLE FF1 : STD_LOGIC;
  BEGIN  -- PROCESS AbortedTrans_signal
    IF rst_n = '0' THEN                 -- asynchronous reset (active low)
      FF1            := '0';
      AbortSignal_D2 <= '0';
    ELSIF clk_D2'event AND clk_D2 = '1' THEN  -- rising clock edge
      AbortSignal_D2 <= FF1;
      FF1            := AbortSignal_D1;
    END IF;
  END PROCESS Abort_signal;


  -- purpose: Error signal
  -- type   : sequential
  -- inputs : clk_D2, rst_n
  -- outputs: 
  Error_signal   : PROCESS (clk_D2, rst_n)
    VARIABLE FF1 : STD_LOGIC;
  BEGIN  -- PROCESS FrameError_signal
    IF rst_n = '0' THEN                 -- asynchronous reset (active low)
      FF1           := '0';
      FrameError_D2 <= '0';
    ELSIF clk_D2'event AND clk_D2 = '1' THEN  -- rising clock edge
      FrameError_D2 <= FF1;
      FF1           := FrameError_D1;
    END IF;
  END PROCESS Error_signal;

END RxSynch_rtl;
