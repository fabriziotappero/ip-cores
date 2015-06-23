-------------------------------------------------------------------------------
-- Title      :  Zero Insertion
-- Project    :  HDLC controller
-------------------------------------------------------------------------------
-- File        : zero_ins.vhd
-- Author      : Jamil Khatib  (khatib@ieee.org)
-- Organization: OpenIPCore Project
-- Created     : 2001/01/12
-- Last update:2001/10/20
-- Platform    : 
-- Simulators  : Modelsim 5.3XE/Windows98
-- Synthesizers: 
-- Target      : 
-- Dependency  : ieee.std_logic_1164
--
-------------------------------------------------------------------------------
-- Description:  Zero Insertion
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
-- Date            :   12 Jan 2001
-- Modifier        :   Jamil Khatib (khatib@ieee.org)
-- Desccription    :   Created
-------------------------------------------------------------------------------
-- Revisions  :
-- Revision Number :   2
-- Version         :   0.2
-- Date            :   27 May 2001
-- Modifier        :   Jamil Khatib (khatib@ieee.org)
-- Desccription    :   Tx zero insertion bug fixed
--                     Zero is inserted after 5 sequence of 1's insted of 6 1's
-------------------------------------------------------------------------------
-- $Log: not supported by cvs2svn $
-- Revision 1.2  2001/05/28 19:14:22  khatib
-- TX zero insertion bug fixed
--
-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY ZeroIns_ent IS

  PORT (
    TxClk         : IN  STD_LOGIC;      -- Tx clock
    rst_n         : IN  STD_LOGIC;      -- system reset
    enable        : IN  STD_LOGIC;      -- enable (Driven by controller)
    inProgress    : OUT STD_LOGIC;      -- Data in progress
    BackendEnable : IN  STD_LOGIC;      -- Backend Enable
    -- backend interface
    abortedTrans  : OUT STD_LOGIC;      -- aborted Transmission
    ValidFrame    : IN  STD_LOGIC;      -- Valid Frame signal
    Writebyte     : IN  STD_LOGIC;      -- Back end write byte
    rdy           : OUT STD_LOGIC;      -- data ready
    TXD           : OUT STD_LOGIC;      -- TX serial data
    Data          : IN  STD_LOGIC_VECTOR(7 DOWNTO 0));  -- TX data bus

END ZeroIns_ent;
-------------------------------------------------------------------------------
ARCHITECTURE zero_ins_beh OF ZeroIns_ent IS

  SIGNAL data_reg : STD_LOGIC_VECTOR(7 DOWNTO 0);  -- Data register (used as
                                        -- internal buffer)
  SIGNAL flag     : STD_LOGIC;          -- control signal between processes
  SIGNAL delay_TX : STD_LOGIC;          -- Delayed output

BEGIN  -- zero_ins_beh


  -- purpose: Parallel to Serial
  -- type   : sequential
  -- inputs : TxClk, rst_n
  -- outputs: 
  P2S_proc                : PROCESS (TxClk, rst_n)
    VARIABLE tmp_reg      : STD_LOGIC_VECTOR(15 DOWNTO 0);  -- Temp Shift register
    VARIABLE counter      : INTEGER RANGE 0 TO 8;  -- Counter
    VARIABLE OnesDetected : STD_LOGIC;  -- 6 ones detected

  BEGIN  -- process P2S_proc
    IF rst_n = '0' THEN                 -- asynchronous reset (active low)

      tmp_reg      := (OTHERS => '0');
      Counter      := 0;
      flag         <= '1';
      OnesDetected := '0';
      TXD          <= '1';
      delay_TX     <= '1';
      inProgress   <= '0';

    ELSIF TxClk'event AND TxClk = '1' THEN  -- rising clock edge
      IF enable = '1' THEN

        OnesDetected := tmp_reg(0) AND tmp_reg(1) AND tmp_reg(2) AND tmp_reg(3) AND tmp_reg(4);

        delay_TX <= tmp_reg(0);
        TXD      <= delay_TX;

        IF OnesDetected = '1' THEN
          -- Zero insertion 
          tmp_reg(4 DOWNTO 0) := '0' & tmp_reg(4 DOWNTO 1);

        ELSE
          -- Total Shift
          tmp_reg(15 DOWNTO 0) := '0' & tmp_reg(15 DOWNTO 1);

          Counter := Counter +1;

        END IF;  -- ones detected

        IF counter = 8 THEN

          counter    := 0;
          flag       <= '1';
          inProgress <= '0';

          tmp_reg(15 DOWNTO 8) := data_reg;
        ELSE
          inProgress           <= '1';
          flag                 <= '0';
        END IF;  -- counter
      END IF;  -- enable
    END IF;  -- clk
  END PROCESS P2S_proc;
-------------------------------------------------------------------------------

  -- purpose: Backend Interface
  -- type   : sequential
  -- inputs : TxClk, rst_n
  -- outputs:   
  Backend_proc     : PROCESS (TxClk, rst_n)
    VARIABLE state : STD_LOGIC;         -- Backend state

  BEGIN  -- process Backend_proc
    IF rst_n = '0' THEN                     -- asynchronous reset (active low)
      state              := '0';
      data_reg           <= (OTHERS => '0');
      rdy                <= '0';
      abortedTrans       <= '0';
    ELSIF TxClk'event AND TxClk = '1' THEN  -- rising clock edge
      IF enable = '1' THEN
        IF BackendEnable = '1' THEN
          CASE state IS
            WHEN '0'                =>      -- wait for reading the register
              IF flag = '1' THEN            -- Register has been read
                state    := '1';
                rdy      <= '1';
                data_reg <= "00000000";     -- set register to known pattern to
                                            -- avoid invalid read (upon valid
                                            -- read this value will be overwritten)
              END IF;

            WHEN '1' =>
              IF WriteByte = '1' THEN
                state        := '0';
                rdy          <= '0';
                data_reg     <= Data;
              ELSIF flag = '1' THEN     -- Another flag but without read
                state        := '0';
                rdy          <= '0';
                data_reg     <= "00000000";
                abortedTrans <= '1';
              END IF;

            WHEN OTHERS => NULL;
          END CASE;

        ELSE
          rdy          <= '0';
          state        := '0';
          abortedTrans <= '0';
        END IF;  -- Backend enable

      END IF;  -- enable
    END IF;  -- Txclk
  END PROCESS Backend_proc;


END zero_ins_beh;
