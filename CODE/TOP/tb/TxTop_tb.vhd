-------------------------------------------------------------------------------
-- Title      :  Top Tx test bench
-- Project    :  HDLC controller
-------------------------------------------------------------------------------
-- File        : Txtop_tb.vhd
-- Author      : Jamil Khatib  (khatib@ieee.org)
-- Organization: OpenIPCore Project
-- Created     :2001/03/15
-- Last update: 2001/03/19
-- Platform    : 
-- Simulators  : Modelsim 5.3XE/Windows98,NC-SIM/Linux
-- Synthesizers: 
-- Target      : 
-- Dependency  : ieee.std_logic_1164
-------------------------------------------------------------------------------
-- Description:  Top Tx test bench
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
-- Date            :   15 March 2001
-- Modifier        :   Jamil Khatib (khatib@ieee.org)
-- Desccription    :   Created
-- ToOptimize      :
-- Bugs            :
-------------------------------------------------------------------------------
-- Revision Number :   2
-- Version         :   0.11
-- Date            :   21 March 2001
-- Modifier        :   Jamil Khatib (khatib@ieee.org)
-- Desccription    :   Test ack signal effect
-- ToOptimize      :
-- Bugs            :   
-------------------------------------------------------------------------------
-- $Log: not supported by cvs2svn $
-- Revision 1.2  2001/03/21 22:47:42  jamil
-- ACK signal test added
--
-- Revision 1.1  2001/03/20 19:29:33  jamil
-- Test Bench of Tx FCS and Buffer created
--
-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

-------------------------------------------------------------------------------

ENTITY TxTop_ent_tb IS

END TxTop_ent_tb;

-------------------------------------------------------------------------------

ARCHITECTURE TxTop_beh_tb OF TxTop_ent_tb IS

  COMPONENT Txfcs_ent
    PORT (
      TxClk       : IN  STD_LOGIC;
      rst_n       : IN  STD_LOGIC;
      ValidFrame  : OUT STD_LOGIC;
      WriteByte   : OUT STD_LOGIC;
      rdy         : IN  STD_LOGIC;
      ack         : IN  STD_LOGIC;
      TxData      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      TxDataAvail : IN  STD_LOGIC;
      RdBuff      : OUT STD_LOGIC;
      TxDataBuff  : IN  STD_LOGIC_VECTOR(7 DOWNTO 0));
  END COMPONENT;

  COMPONENT TxBuff_ent
    GENERIC (
      ADD_WIDTH     :     INTEGER);
    PORT (
      TxClk         : IN  STD_LOGIC;
      rst_n         : IN  STD_LOGIC;
      RdBuff        : IN  STD_LOGIC;
      Wr            : IN  STD_LOGIC;
      TxDataAvail   : OUT STD_LOGIC;
      TxEnable      : IN  STD_LOGIC;
      TxDone        : OUT STD_LOGIC;
      TxDataOutBuff : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      TxDataInBuff  : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      Full          : OUT STD_LOGIC);
  END COMPONENT;

  SIGNAL ack           : STD_LOGIC := '0';
  SIGNAL TxClk         : STD_LOGIC := '0';
  SIGNAL rst_n         : STD_LOGIC := '0';
  SIGNAL ValidFrame_i  : STD_LOGIC;
  SIGNAL WriteByte_i   : STD_LOGIC;
  SIGNAL rdy_i         : STD_LOGIC;
  SIGNAL TxData_i      : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL TxDataAvail_i : STD_LOGIC;
  SIGNAL RdBuff_i      : STD_LOGIC;
  SIGNAL TxDataBuff_i  : STD_LOGIC_VECTOR(7 DOWNTO 0);

  SIGNAL Wr_i           : STD_LOGIC;
  SIGNAL TxEnable_i     : STD_LOGIC;
--  signal TxDataOutBuff_i : std_logic_vector(7 downto 0);
  SIGNAL TxDataInBuff_i : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL Full_i         : STD_LOGIC;
  SIGNAL TxDone_i       : STD_LOGIC;

BEGIN  -- Txfcs_beh_tb

  TxClk <= NOT TxClk AFTER 50 NS;
  rst_n <= '1'       AFTER 120 NS;

  write_proc      : PROCESS (TxClk, rst_n)
    VARIABLE flag : STD_LOGIC;          -- Internal flag
  BEGIN  -- process write_proc
    IF rst_n = '0' THEN                 -- asynchronous reset (active low)
      flag           := '1';
      Wr_i           <= '0';
      TxDataInBuff_i <= (OTHERS => '0');
      TxEnable_i     <= '0';

    ELSIF TxClk'event AND TxClk = '0' THEN  -- rising clock edge

      IF TxDone_i'event AND TxDone_i = '1' THEN
        flag := '1';
      END IF;

      IF flag = '1' THEN

        IF TxDataInBuff_i = "0001000" THEN
          TxDataInBuff_i <= (OTHERS => '0');
          TxEnable_i     <= '1';
          Wr_i           <= '0';

          flag           := '0';
        ELSE
          Wr_i           <= '1';
          TxDataInBuff_i <= TxDataInBuff_i + 1;
          TxEnable_i     <= '0';


        END IF;

      ELSE
        Wr_i           <= '0';
        TxDataInBuff_i <= (OTHERS => '0');
        TxEnable_i     <= '0';
      END IF;

    END IF;
  END PROCESS write_proc;


  hdlc_IF_proc       : PROCESS (TxClk, rst_n)
    VARIABLE counter : INTEGER := 0;

  BEGIN  -- process hdlc_IF_proc
    IF rst_n = '0' THEN                     -- asynchronous reset (active low)
      counter   := 0;
    ELSIF TxClk'event AND TxClk = '0' THEN  -- rising clock edge
      IF WriteByte_i = '1' THEN
        -- after 100 ns must be fixed to check two clocks
        ack     <= '1' AFTER 100 NS;
        rdy_i   <= '0' AFTER 100 NS;
        counter := 0;

      ELSIF (counter MOD 8) = 0 THEN
        rdy_i <= '1';
        ack   <= '0';
      END IF;

      counter := counter +1;

    END IF;
  END PROCESS hdlc_IF_proc;


  DUT : Txfcs_ent
    PORT MAP (
      TxClk       => TxClk,
      rst_n       => rst_n,
      ValidFrame  => ValidFrame_i,
      WriteByte   => WriteByte_i,
      rdy         => rdy_i,
      ack         => ack,
      TxData      => TxData_i,
      TxDataAvail => TxDataAvail_i,
      RdBuff      => RdBuff_i,
      TxDataBuff  => TxDataBuff_i);


  DUT2 : TxBuff_ent
    GENERIC MAP (
      ADD_WIDTH     => 7)
    PORT MAP (
      TxClk         => TxClk,
      rst_n         => rst_n,
      RdBuff        => RdBuff_i,
      Wr            => Wr_i,
      TxDataAvail   => TxDataAvail_i,
      TxEnable      => TxEnable_i,
      TxDone        => TxDone_i,
      TxDataOutBuff => TxDataBuff_i,
      TxDataInBuff  => TxDataInBuff_i,
      Full          => Full_i);

END TxTop_beh_tb;

-------------------------------------------------------------------------------
