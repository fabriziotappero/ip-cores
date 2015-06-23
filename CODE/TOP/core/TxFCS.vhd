-------------------------------------------------------------------------------
-- Title      :  Tx FCS
-- Project    :  HDLC controller
-------------------------------------------------------------------------------
-- File        : TxFCS.vhd
-- Author      : Jamil Khatib  (khatib@ieee.org)
-- Organization: OpenIPCore Project
-- Created     :2001/03/09
-- Last update: 2001/04/24
-- Platform    : 
-- Simulators  : Modelsim 5.3XE/Windows98,NC-SIM/Linux
-- Synthesizers: 
-- Target      : 
-- Dependency  : ieee.std_logic_1164
--               hdlc.PCK_CRC16_D8
-------------------------------------------------------------------------------
-- Description:  HDLC TX FCS-16 generation
-------------------------------------------------------------------------------
-- Copyright (c) 2001 Jamil Khatib
-- 
-- This VHDL design file is an open design; you can redistribute it and/or
-- modify it and/or implement it after contacting the author
-- You can check the draft license at
-- http://www.opencores.org/OIPC/license.shtml

-------------------------------------------------------------------------------
-- Revisions  :
-- Revision Number :   1
-- Version         :   0.1
-- Date            :   9 March 2001
-- Modifier        :   Jamil Khatib (khatib@ieee.org)
-- Desccription    :   Created
-- ToOptimize      :
-- Bugs            :
-------------------------------------------------------------------------------
-- Revisions  :
-- Revision Number :   2
-- Version         :   0.11
-- Date            :   21 March 2001
-- Modifier        :   Jamil Khatib (khatib@ieee.org)
-- Desccription    :   Ack signal added to fix any possible handshake error on
--                     slow devices
--                     slow hdlc controller can cause rdy signal to be asserted
--                     for long time so ack signal indicates that the
--                     controller has accepted the new data
-- ToOptimize      :   Reduce number of states
-- Bugs            :
-------------------------------------------------------------------------------
-- Revision Number :   3
-- Version         :   0.2
-- Date            :   9 April 2001
-- Modifier        :   Jamil Khatib (khatib@ieee.org)
-- Desccription    :   Added FCS enable (to tranmist FCS or not)
--                     FCS bit inversion fixed
-- ToOptimize      :   Reduce number of states, Check the FCSen operation
-- Bugs            :
-------------------------------------------------------------------------------
-- $Log: not supported by cvs2svn $
-- Revision 1.5  2001/04/27 18:21:59  jamil
-- After Prelimenray simulation
--
-- Revision 1.4  2001/04/14 15:18:05  jamil
-- Generic FCS added
--
-- Revision 1.3  2001/04/08 21:03:31  jamil
--  Added FCS enable (to tranmist FCS or not)
--  FCS bit inversion fixed
--
-- Revision 1.2  2001/03/21 22:47:05  jamil
-- ACK slow devices bug fixed
--
-- Revision 1.1  2001/03/21 20:19:43  jamil
-- Initial Release
--
-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

LIBRARY hdlc;
USE hdlc.PCK_CRC16_D8.ALL;

ENTITY Txfcs_ent IS
  GENERIC (
    FCS_TYPE   :     INTEGER := 2);                 -- 2= FCS 16
                                                    -- 4= FCS 32
                                                    -- 0= Disable FCS
  PORT (
    TxClk      : IN  STD_LOGIC;                     -- Tx Clock
    rst_n      : IN  STD_LOGIC;                     -- System Reset
    FCSen      : IN  STD_LOGIC;                     -- FCS enable
    ValidFrame : OUT STD_LOGIC;                     -- Valid Frame
    WriteByte  : OUT STD_LOGIC;                     -- Write Byte
    rdy        : IN  STD_LOGIC;                     -- Ready to send data
    ack        : IN  STD_LOGIC;                     -- Acknowlege
    TxData     : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);  -- Tx Data

    TxDataAvail : IN  STD_LOGIC;        -- Tx Data is available in the buffer
                                        -- (reflected from TxEnable bit in Tx register)
    RdBuff      : OUT STD_LOGIC;        -- Read Tx data buffer
    TxDataBuff  : IN  STD_LOGIC_VECTOR(7 DOWNTO 0));  -- Tx Data buffer


END Txfcs_ent;


ARCHITECTURE Txfcs_beh OF Txfcs_ent IS

BEGIN  -- Txfcs_sync_beh
-------------------------------------------------------------------------------
-- purpose: Main State machine
-- type   : sequential
-- inputs : TxClk, rst_n
-- outputs: 
  FSM_proc           : PROCESS (TxClk, rst_n)
    VARIABLE FCS_reg : STD_LOGIC_VECTOR(15 DOWNTO 0);  -- FCS register
    TYPE States_types IS (IDLE_st, READ_st, WRITE_st, WAIT_st, SETZ1_st, WRITEZ1_st, SETZ2_st, WAIT2_st, WAIT_STATE1_st, WAIT_STATE2_st, WAIT_STATE3_st);
                                                       -- Internal states
    VARIABLE state   : States_types;                   -- State register

    VARIABLE Data2FCS : STD_LOGIC_VECTOR(7 DOWNTO 0);  -- Input data to FCS reg

  BEGIN  -- process FSM_proc
    IF rst_n = '0' THEN                 -- asynchronous reset (active low)
      Data2FCS := (OTHERS => '0');
      FCS_reg  := (OTHERS => '1');

      ValidFrame <= '0';
      WriteByte  <= '0';
      TxData     <= (OTHERS => '0');

      RdBuff <= '0';

      state := IDLE_st;

    ELSIF TxClk'event AND TxClk = '1' THEN  -- rising clock edge



      CASE state IS
        WHEN IDLE_st =>

          FCS_reg  := (OTHERS => '1');
          Data2FCS := (OTHERS => '1');

          ValidFrame <= TxDataAvail;--'0';

          WriteByte <= '0';
          TxData    <= (OTHERS => '0');

          IF rdy = '1' then --AND TxDataAvail = '1' THEN
            state  := READ_st;
            RdBuff <= '1';

          ELSE
            state  := IDLE_st;
            RdBuff <= '0';

          END IF;
-- -- -- -- -- 
        WHEN READ_st =>
          Data2FCS := TxDataBuff;
-- FCS calculation
          FCS_reg  := nextCRC16_D8 ( Data2FCS, FCS_reg );

          ValidFrame <= '1';
          WriteByte  <= '1';
          TxData     <= TxDataBuff;

          RdBuff <= '0';

          state   := WAIT_STATE1_st;
-- -- -- -- --
        WHEN WAIT_STATE1_st =>
-- this state does nothing but registers all output signals till ack is valid
--          IF ( ack = '1') THEN
          IF ( rdy = '0') THEN
            state := WAIT_st;
          ELSE
            state := WAIT_STATE1_st;
          END IF;

-- -- -- -- -- 
        WHEN WAIT_st =>

          ValidFrame <= '1';
          WriteByte  <= '0';

          IF TxDataAvail = '1' THEN     -- Data Available (wait for rdy)
            TxData   <= TxDataBuff;
            Data2FCS := TxDataBuff;
            IF rdy = '1' THEN           -- ready to accept new data

              RdBuff <= '1';
              state  := READ_st;

            ELSE
              RdBuff <= '0';
              state  := WAIT_st;

            END IF;

          ELSE
            -- No data is available
            IF (FCSen = '1') THEN
              TxData   <= (OTHERS => '1');
              Data2FCS := (OTHERS => '1');
              FCS_reg  := nextCRC16_D8 ( Data2FCS, FCS_reg );

              RdBuff   <= '0';
              state    := SETZ1_st;
            ELSE
              TxData   <= (OTHERS => '1');
              Data2FCS := (OTHERS => '1');
              FCS_reg  := (OTHERS => '1');

              RdBuff <= '0';
              state  := IDLE_st;

            END IF;

          END IF;

-- -- -- -- --
        WHEN SETZ1_st           =>
          Data2FCS   := (OTHERS => '1');
          -- FCS calculation
          FCS_reg    := nextCRC16_D8 ( Data2FCS, FCS_reg );
          ValidFrame <= '1';

          WriteByte <= '0';
          TxData    <= (OTHERS => '1');

          RdBuff <= '0';
          state  := SETZ2_st;
-- -- -- -- --
        WHEN SETZ2_st =>

          Data2FCS := (OTHERS => '1');

          ValidFrame <= '1';
          RdBuff     <= '0';

          IF rdy = '1' THEN

            WriteByte <= '1';

            TxData(7) <= NOT FCS_reg(8);
            TxData(6) <= NOT FCS_reg(9);
            TxData(5) <= NOT FCS_reg(10);
            TxData(4) <= NOT FCS_reg(11);
            TxData(3) <= NOT FCS_reg(12);
            TxData(2) <= NOT FCS_reg(13);
            TxData(1) <= NOT FCS_reg(14);
            TxData(0) <= NOT FCS_reg(15);


            state := WAIT_STATE2_st;

          ELSE
            -- This the normal case when the other device reply to write
            -- signals by deasserting rdy signal
            TxData    <= (OTHERS => '1');
            WriteByte <= '0';
            state     := SETZ2_st;
          END IF;
-- -- -- -- --

        WHEN WAIT_STATE2_st =>
-- this state does nothing but registers all output signals till ack is valid
--          IF (ack = '1') THEN
          IF ( rdy = '0') THEN
            state := WAIT2_st;
          ELSE
            state := WAIT_STATE2_st;
          END IF;

-- -- -- -- --
        WHEN WAIT2_st         =>
          Data2FCS := (OTHERS => '1');

          ValidFrame <= '1';
          RdBuff     <= '0';

          IF rdy = '1' THEN

            WriteByte <= '1';

            TxData(7) <= NOT FCS_reg(0);
            TxData(6) <= NOT FCS_reg(1);
            TxData(5) <= NOT FCS_reg(2);
            TxData(4) <= NOT FCS_reg(3);
            TxData(3) <= NOT FCS_reg(4);
            TxData(2) <= NOT FCS_reg(5);
            TxData(1) <= NOT FCS_reg(6);
            TxData(0) <= NOT FCS_reg(7);


            state := WAIT_STATE3_st;

          ELSE
            TxData    <= (OTHERS => '1');
            WriteByte <= '0';
            state     := WAIT2_st;
          END IF;
-- -- -- -- --

        WHEN WAIT_STATE3_st =>
-- this state does nothing but registers all output signals till ack is valid
--          IF (ack = '1') THEN
          IF ( rdy = '0') THEN
            state := IDLE_st;
          ELSE
            state := WAIT_STATE3_st;
          END IF;
-- -- -- -- --

        WHEN OTHERS => NULL;
      END CASE;


    END IF;
  END PROCESS FSM_proc;


END Txfcs_beh;

