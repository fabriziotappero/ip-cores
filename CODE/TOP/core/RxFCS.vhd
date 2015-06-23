-------------------------------------------------------------------------------
-- Title      :  Rx FCS
-- Project    :  HDLC controller
-------------------------------------------------------------------------------
-- File        : RxFCS.vhd
-- Author      : Jamil Khatib  (khatib@ieee.org)
-- Organization: OpenIPCore Project
-- Created     :2001/04/05
-- Last update: 2001/04/20
-- Platform    : 
-- Simulators  : Modelsim 5.3XE/Windows98,NC-SIM/Linux
-- Synthesizers: 
-- Target      : 
-- Dependency  : ieee.std_logic_1164, ieee.std_logic_unsigned
--               hdlc.PCK_CRC16_D8
-------------------------------------------------------------------------------
-- Description:  HDLC RX FCS-16 checking
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
-- Date            :   5 April 2001
-- Modifier        :   Jamil Khatib (khatib@ieee.org)
-- Desccription    :   Created
-- ToOptimize      :
-- Bugs            :
-------------------------------------------------------------------------------
-- $Log: not supported by cvs2svn $
-- Revision 1.2  2001/04/20 18:29:01  jamil
-- Sencetivity list bug fixed
--
-- Revision 1.1  2001/04/14 15:02:25  jamil
-- Initial Release
--
-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

LIBRARY hdlc;
USE hdlc.PCK_CRC16_D8.ALL;


ENTITY RxFCS_ent IS
  GENERIC (
    FCS_TYPE   :     INTEGER := 2);                 -- 2= FCS 16
                                                    -- 4= FCS 32
                                                    -- 0= disable FCS
  PORT (
    clk        : IN  STD_LOGIC;                     -- system clock
    rst_n      : IN  STD_LOGIC;                     -- system reset
    RxD        : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);  -- Rx Data bus
    ValidFrame : IN  STD_LOGIC;                     -- Frame Strobe
    rdy        : IN  STD_LOGIC;                     -- rdy to send byte
    Readbyte   : OUT STD_LOGIC;                     -- Read byte
    DataBuff   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);  -- Rx output data
    WrBuff     : OUT STD_LOGIC;                     -- Write to buffer
    EOF        : OUT STD_LOGIC;                     -- End of Frame pulse
    FCSen      : IN  STD_LOGIC;                     -- FCs enable
    FCSerr     : OUT STD_LOGIC);                    -- FCS error

END RxFCS_ent;

ARCHITECTURE RxFCS_rtl OF RxFCS_ent IS

  TYPE STATES_typ IS (IDLE_st, RUN_st, READ_st, EOF_st);  -- Internal states
  SIGNAL p_state : STATES_typ;                            -- Present state
  SIGNAL n_state : STATES_typ;                            -- Next state

  SIGNAL FCS_reg   : STD_LOGIC_VECTOR(15 DOWNTO 0);  -- FCS register
  SIGNAL FCS_value : STD_LOGIC_VECTOR(15 DOWNTO 0);  -- FCS value

  SIGNAL WrBuff_i : STD_LOGIC;          -- Internal WrBuff
  SIGNAL EOF_i    : STD_LOGIC;          -- Internal EOF

BEGIN  -- RxFCS_rtl
-- purpose: FSM 
-- type   : sequential
-- inputs : clk, rst_n
-- outputs: 
  fsm : PROCESS (clk, rst_n)

  BEGIN  -- PROCESS fsm

    IF rst_n = '0' THEN                 -- asynchronous reset (active low)
      p_state  <= IDLE_st;
      FCS_reg  <= (OTHERS => '1');
      WrBuff   <= '0';
      DataBuff <= (OTHERS => '1');
      EOF      <= '0';
    ELSIF clk'event AND clk = '1' THEN  -- rising clock edge
      p_state  <= n_state;
      FCS_reg  <= FCS_value;
      DataBuff <= RxD;
      WrBuff   <= WrBuff_i;
      EOF      <= EOF_i;
    END IF;

  END PROCESS fsm;


-- purpose: fsm combination input/output logic
-- type   : combinational
-- inputs : p_state,ValidFrame,rdy
-- outputs: 
  fsm_logic : PROCESS (p_state, ValidFrame, rdy, FCS_reg, FCSen,RxD)

  BEGIN  -- PROCESS fsm_logic

    CASE p_state IS

      WHEN IDLE_st =>

        FCSerr    <= '0';
        WrBuff_i  <= '0';
        FCS_value <= (OTHERS => '1');
        Readbyte  <= '0';
        EOF_i     <= '0';
        IF (ValidFrame = '1') THEN
          n_state <= RUN_st;
        ELSE
          n_state <= IDLE_st;
        END IF;

      WHEN RUN_st =>
        FCSerr   <= '0';
        WrBuff_i <= '0';
        IF (ValidFrame = '1') THEN

          FCS_value <= FCS_reg;
          EOF_i     <= '0';

          IF (rdy = '1') THEN
            n_state  <= READ_st;
            Readbyte <= '0';
          ELSE
            n_state  <= RUN_st;
            Readbyte <= '0';
          END IF;

        ELSE
          n_state   <= EOF_st;
          Readbyte  <= '0';
          FCS_value <= FCS_reg;
          EOF_i     <= '1';

        END IF;

      WHEN EOF_st =>

        n_state  <= IDLE_st;
        Readbyte <= '0';
        WrBuff_i <= '0';
        FCSerr   <= FCSen AND
                    NOT (NOT FCS_reg(15) AND NOT FCS_reg(14)AND NOT FCS_reg(13) AND FCS_reg(12)
                         AND FCS_reg(11) AND FCS_reg(10) AND NOT FCS_reg(9) AND FCS_reg(8)
                         AND NOT FCS_reg(7) AND NOT FCS_reg(6) AND NOT FCS_reg(5) AND NOT FCS_reg(4)
                         AND FCS_reg(3) AND FCS_reg(2) AND FCS_reg(1) AND FCS_reg(0)
                         );
--                    0001 1101 0000 1111

        FCS_value <= (OTHERS => '1');
        EOF_i     <= '0';

      WHEN READ_st =>

        FCSerr <= '0';
        EOF_i  <= '0';

        IF (rdy = '1') THEN

          n_state   <= READ_st;
          FCS_value <= FCS_reg;
          WrBuff_i  <= '0';
          Readbyte  <= '1';

        ELSE                            -- Data valid

          n_state   <= RUN_st;
          FCS_value <= nextCRC16_D8 ( RxD, FCS_reg );  --FCS_reg;
          WrBuff_i  <= '1';
          Readbyte  <= '0';

        END IF;

      WHEN OTHERS => NULL;
    END CASE;

  END PROCESS fsm_logic;



END RxFCS_rtl;
