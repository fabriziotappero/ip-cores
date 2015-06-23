-------------------------------------------------------------------------------
-- Title      :  TX controller
-- Project    :  HDLC controller
-------------------------------------------------------------------------------
-- File        : TxCont.vhd
-- Author      : Jamil Khatib  (khatib@ieee.org)
-- Organization: OpenIPCore Project
-- Created     :2001/01/15
-- Last update:2001/10/26
-- Platform    : 
-- Simulators  : Modelsim 5.3XE/Windows98
-- Synthesizers: 
-- Target      : 
-- Dependency  : ieee.std_logic_1164
--
-------------------------------------------------------------------------------
-- Description:  Transmit controller
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
-- Date            :   15 Jan 2001
-- Modifier        :   Jamil Khatib (khatib@ieee.org)
-- Desccription    :   Created
-- ToOptimize      :
-- Bugs            :   
-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY TxCont_ent IS

  PORT (
    TXclk         : IN  STD_LOGIC;      -- TX clock
    rst_n         : IN  STD_LOGIC;      -- System Reset
    TXEN          : IN  STD_LOGIC;      -- TX enable
    enable        : OUT STD_LOGIC;      -- Enable control
    BackendEnable : OUT STD_LOGIC;      -- Backend Enable
    abortedTrans  : IN  STD_LOGIC;      -- No Valid data from the backend
    inProgress    : IN  STD_LOGIC;      -- Data in progress
    ValidFrame    : IN  STD_LOGIC;      -- Valid Frame
    Frame         : OUT STD_LOGIC;      -- Frame strobe
    AbortFrame    : IN  STD_LOGIC;      -- AbortFrame
    AbortTrans    : OUT STD_LOGIC);     -- Abort data transmission

END TxCont_ent;
-------------------------------------------------------------------------------
ARCHITECTURE TxCont_beh OF TxCont_ent IS

BEGIN  -- TxCont_beh

-- purpose: Abort Machine
-- type   : sequential
-- inputs : Txclk, rst_n
-- outputs: 
  abort_proc : PROCESS (Txclk, rst_n)

    VARIABLE counter : INTEGER RANGE 0 TO 14;  -- Counter

    VARIABLE state : STD_LOGIC;             -- Internal State
    -- state ==> '0' No abort signal
    -- state ==> '1' Abort signal
  BEGIN  -- process abort_proc
    IF rst_n = '0' THEN                     -- asynchronous reset (active low)
      AbortTrans <= '0';
      Counter    := 0;
      enable     <= '1';
      state      := '0';
    ELSIF Txclk'event AND Txclk = '1' THEN  -- rising clock edge
      IF TXEN = '1' THEN

        CASE state IS

          WHEN '0' =>
            IF abortedTrans = '1' OR AbortFrame = '1' THEN
              state    := '1';
              Counter  := 0;
            END IF;
            AbortTrans <= '0';

          WHEN '1' =>
            IF counter = 8 THEN
              counter := 0;
              IF abortedTrans = '0' AND AbortFrame = '0' THEN

                state      := '0';
                AbortTrans <= '0';
              ELSE
                AbortTrans <= '1';
              END IF;

            ELSE
              counter := counter +1;
            END IF;  -- counter

          WHEN OTHERS => NULL;

        END CASE;
      END IF;  -- TXEN
      enable <= TXEN;

    END IF;  -- TXclk
  END PROCESS abort_proc;

  -- purpose: Flag Controller 
  -- type   : sequential
  -- inputs : Txclk, rst_n
  -- outputs: 
  Flag_proc : PROCESS (Txclk, rst_n)

    VARIABLE state   : STD_LOGIC_VECTOR(2 DOWNTO 0);  -- Internal State machine
    VARIABLE counter : INTEGER RANGE 0 TO 16;         -- Internal counter

  BEGIN  -- process Flag_proc
    IF rst_n = '0' THEN                     -- asynchronous reset (active low)
      Frame         <= '0';
      state         := (OTHERS => '0');
      counter       := 0;
      BackendEnable <= '0';
    ELSIF Txclk'event AND Txclk = '1' THEN  -- rising clock edge
      IF TXEN = '1' THEN

        CASE state IS
          WHEN "000" =>                 -- Check Valid Frame
            Frame           <= '0';
            IF ValidFrame = '1' THEN
              state         := "001";
              BackendEnable <= '1';
            ELSE
              BackendEnable <= '0';
            END IF;
            counter         := 0;

          WHEN "001" =>

            IF counter > 1 AND inProgress = '0' THEN
              state := "010";
              Frame <= '1';
            ELSE
              Frame <= '0';
            END IF;

            IF inProgress = '0' THEN
              counter := counter +1;
            END IF;

            BackendEnable <= '1';

          WHEN "010" =>                 -- Check ValidFrame

            Frame <= '1';

            IF ValidFrame = '0' THEN
              state         := "011";
              BackendEnable <= '0';
            ELSE
              BackendEnable <= '1';
            END IF;

            counter := 0;

          WHEN "011" =>
            IF counter > 2 AND inProgress = '0' THEN
              state := "100";
            END IF;
            Frame   <= '1';

            IF inProgress = '0' THEN
              counter := counter +1;
            END IF;

            BackendEnable <= '0';

          WHEN "100" =>

            IF counter = 10 THEN
              counter := 0;
              state   := "000";
              Frame   <= '0';
            ELSE
              counter := counter + 1;
              Frame   <= '1';
            END IF;

            BackendEnable <= '0';

          WHEN OTHERS => NULL;
        END CASE;
      END IF;  -- TXEN
    END IF;
  END PROCESS Flag_proc;
-------------------------------------------------------------------------------
END TxCont_beh;
