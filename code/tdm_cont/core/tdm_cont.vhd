-------------------------------------------------------------------------------
-- Title      : TDM controller
-- Project    : TDM controller
-------------------------------------------------------------------------------
-- File       : tdm_cont.vhd
-- Author     : Jamil Khatib  <khatib@ieee.org>
-- Organization:  OpenCores.org
-- Created    : 2001/05/09
-- Last update:2001/05/23
-- Platform   : 
-- Simulators  : NC-sim/linux, Modelsim XE/windows98
-- Synthesizers: Leonardo
-- Target      : 
-- Dependency  : ieee.std_logic_1164
-------------------------------------------------------------------------------
-- Description:  tdm controller that reads and writes E1 bit rate through
-- ST-bis interface
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
-- Date            :  2001/05/09
-- Modifier        :  Jamil Khatib  <khatib@ieee.org>
-- Desccription    :  Created
-- ToOptimize      :
-- Known Bugs      : 
-------------------------------------------------------------------------------
-- $Log: not supported by cvs2svn $
-- Revision 1.3  2001/05/24 22:48:56  jamil
-- TDM Initial release
--
-- Revision 1.2  2001/05/18 08:49:23  jamil
-- Serial interface added
--
-- Revision 1.1  2001/05/13 21:13:35  jamil
-- Initial Release
--
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY tdm_cont_ent IS

  PORT (
    rst_n  : IN  STD_LOGIC;             -- System asynchronous reset
    C2     : IN  STD_LOGIC;             -- ST-Bus clock
    DSTi   : IN  STD_LOGIC;             -- ST-Bus input Data
    DSTo   : OUT STD_LOGIC;             -- ST-Bus output Data
    F0_n   : IN  STD_LOGIC;             -- St-Bus Framing pulse
    F0od_n : OUT STD_LOGIC;             -- ST-Bus Delayed Framing pulse

    CLK_I : IN STD_LOGIC;               -- System clock

--Backend interface
    NoChannels   : IN STD_LOGIC_VECTOR(4 DOWNTO 0);  -- no of Time slots
    DropChannels : IN STD_LOGIC_VECTOR(4 DOWNTO 0);  -- No of channels to be dropped

    RxD         : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);  -- Parellel Rx output
    RxValidData : OUT STD_LOGIC;                     -- Valid Data
    FramErr     : OUT STD_LOGIC;                     -- Frame Error due to
                                                     -- buffer overflow
    RxRead      : IN  STD_LOGIC;                     -- Read Byte
    RxRdy       : OUT STD_LOGIC;                     -- Byte ready
    TxErr       : OUT STD_LOGIC;
                                                     -- Tx Error in transmission due to buffer underflow
    TxD         : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);  -- Parellal Tx Input
    TxValidData : IN  STD_LOGIC;                     -- Tx Valid Data
    TxWrite     : IN  STD_LOGIC;                     -- Write byte
    TxRdy       : OUT STD_LOGIC;                     -- Byte Ready

    -- Serial Interfaces
    EnableSerialIF : IN STD_LOGIC;      -- Enable Serial Interface

    Tx_en0 : OUT STD_LOGIC;             -- Tx enable channel 0
    Tx_en1 : OUT STD_LOGIC;             -- Tx enable channel 1
    Tx_en2 : OUT STD_LOGIC;             -- Tx enable channel 2

    Rx_en0 : OUT STD_LOGIC;             -- Rx enable channel 0
    Rx_en1 : OUT STD_LOGIC;             -- Rx enable channel 1
    Rx_en2 : OUT STD_LOGIC;             -- Rx enable channel 2

    SerDo : OUT STD_LOGIC;              -- serial Data out
    SerDi : IN  STD_LOGIC               -- Serial Data in

    );


END tdm_cont_ent;

ARCHITECTURE tdm_cont_rtl OF tdm_cont_ent IS
  SIGNAL Tot_count  : STD_LOGIC_VECTOR(7 DOWNTO 0);  -- total store counter
  SIGNAL drop_count : STD_LOGIC_VECTOR(7 DOWNTO 0);  -- total droped counter

  TYPE States_type IS (IDLE_st, WRITE_st, READ_st);  --States type

  SIGNAL state : States_type;           -- FSM state

  SIGNAL DSTi_reg : STD_LOGIC;          -- DSTi register  

  SIGNAL Tx_reg   : STD_LOGIC_VECTOR(7 DOWNTO 0);  -- Tx Data register
  SIGNAL Tx_reg_i : STD_LOGIC_VECTOR(7 DOWNTO 0);  -- Tx Data register
  SIGNAL Tx_En    : STD_LOGIC;                     -- Tx Enable
  SIGNAL Rx_En    : STD_LOGIC;                     -- Rx Enable
  SIGNAL Rx_Reg   : STD_LOGIC_VECTOR(7 DOWNTO 0);  -- Rx Data register

  SIGNAL RxFrame : STD_LOGIC;           -- Rx Frame Valid
  SIGNAL RxFlag  : STD_LOGIC;           -- Rx Flag

  SIGNAL TxFlag    : STD_LOGIC;         -- Tx Flag
  SIGNAL TxDisable : STD_LOGIC;         -- disable Tx from Backend

  SIGNAL GetNew : STD_LOGIC;            -- Get New byte

  SIGNAL EnableRegister : STD_LOGIC_VECTOR(31 DOWNTO 0);
                                        -- Enable register
  SIGNAL EnShift        : STD_LOGIC;    -- Enable shift

BEGIN  -- tdm_cont_rtl
-------------------------------------------------------------------------------
-- Global constants
-------------------------------------------------------------------------------
  Tot_count  <= NoChannels & "111";
  drop_count <= DropChannels & "000";
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Main machine
-------------------------------------------------------------------------------
-- purpose: FSM
-- type   : sequential
-- inputs : CLK_I, rst_n
-- outputs: 
  fsm : PROCESS (CLK_I, rst_n)

    VARIABLE counter     : STD_LOGIC_VECTOR(7 DOWNTO 0);  -- Bit counter
    VARIABLE Drop        : STD_LOGIC;   -- Drop bit
    VARIABLE ExtendFrame : STD_LOGIC;   -- Extend Delayed Frame pulse
  BEGIN  -- process fsm
    IF rst_n = '0' THEN                 -- asynchronous reset (active low)
      state       <= IDLE_st;
      counter     := (OTHERS => '0');
      Tx_En       <= '0';
      Rx_en       <= '0';
      DSTi_reg    <= '1';
      Drop        := '0';
      DSTo        <= 'Z';
      TxDisable   <= '1';
      F0od_n      <= '1';
      RxFrame     <= '0';
      GetNew      <= '0';
      ExtendFrame := '0';
      SerDo <= '1';
    ELSIF CLK_I'event AND CLK_I = '1' THEN  -- rising clock edge

      CASE State IS
        WHEN IDLE_st =>
          DSTo <= 'Z';
          Drop := '0';

          Tx_En <= '0';
          Rx_en <= '0';

          IF F0_n = '0' THEN

            State     <= WRITE_st;
            counter   := (OTHERS => '0');
            TxDisable <= NOT TxValidData;
            GetNew    <= '1';

          END IF;

          RxFrame <= '0';

          IF ExtendFrame = '1' AND C2 = '0' THEN
            F0od_n <= '1';
          END IF;

          IF C2 = '1' THEN
            ExtendFrame := '1';
          END IF;


        WHEN WRITE_st =>
          ExtendFrame := '0';
          GetNew      <= '0';
          RxFrame     <= '1';

          F0od_n <= '1';
          Rx_en  <= '0';

          IF C2 = '1' THEN

            IF counter >= drop_count THEN
              IF TxDisable = '1' THEN
                DSTo  <= '1';
                Tx_En <= '0';
              ELSE

                IF (EnableSerialIF = '1') THEN
                  DSTo <= SerDi;
                ELSE
                  DSTo <= Tx_reg(7);
                END IF;

                Tx_En <= '1';
              END IF;

              Drop := '0';

            ELSE
              DSTo  <= 'Z';
              Tx_En <= '0';
              Drop  := '1';
            END IF;

            State <= READ_st;

          ELSE

            Tx_En <= '0';

          END IF;

        WHEN READ_st =>
          ExtendFrame := '0';
          GetNew      <= '0';
          RxFrame     <= '1';
          Tx_En       <= '0';

          IF C2 = '0' THEN

            DSTi_reg <= DSTi;
            SerDo    <= DSTi;

            IF counter = Tot_count THEN

              State  <= IDLE_st;
              F0od_n <= '0';

            ELSE
              State  <= WRITE_st;
              F0od_n <= '1';

            END IF;

            counter := counter + 1;

            Rx_En <= NOT Drop;
          ELSE
            Rx_En <= '0';
          END IF;

      END CASE;

    END IF;
  END PROCESS fsm;
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Rx Machines
-------------------------------------------------------------------------------
  -- purpose: Rx Serial To parellel
  -- type   : sequential
  RxS2P               : PROCESS (CLK_I, rst_n)
    VARIABLE Rx_count : STD_LOGIC_VECTOR(2 DOWNTO 0);  -- Rx Internal bit counter

  BEGIN  -- process RxS2P
    IF rst_n = '0' THEN                     -- asynchronous reset (active low)
      Rx_count := "000";
      RxFlag   <= '0';
      Rx_Reg   <= (OTHERS => '1');
      EnShift  <= '0';
    ELSIF CLK_I'event AND CLK_I = '1' THEN  -- rising clock edge

      IF Rx_En = '1' THEN

        Rx_Reg <= Rx_Reg(6 DOWNTO 0) & DSTi_reg;

        IF Rx_count = "111" THEN
          Rx_count := "000";

          RxFlag <= '1';

          EnShift  <= '1';
        ELSE
          Rx_count := Rx_count + 1;
          RxFlag   <= '0';
          EnShift  <= '0';
        END IF;
      ELSE
        RxFlag     <= '0';
        EnShift    <= '0';
      END IF;

    END IF;
  END PROCESS RxS2P;
-------------------------------------------------------------------------------
  -- purpose: Rx Backend
  -- type   : sequential
  -- inputs : CLK_I, rst_n
  -- outputs: 
  RxBackend        : PROCESS (CLK_I, rst_n)
    VARIABLE state : STD_LOGIC;         -- Internal State
  BEGIN  -- process RxBackend
    IF rst_n = '0' THEN                 -- asynchronous reset (active low)
      State       := '0';
      RxD         <= (OTHERS => '0');
      RxRdy       <= '0';
      FramErr     <= '0';
      RxValidData <= '0';

    ELSIF CLK_I'event AND CLK_I = '1' THEN  -- rising clock edge

      CASE State IS

        WHEN '0' =>
          RxRdy   <= '0';
          FramErr <= '0';

          IF RxFlag = '1' THEN
            RxD   <= Rx_Reg;
            State := '1';
          END IF;

        WHEN '1' =>
          RxRdy <= '1';
 RxValidData <= RxFrame;
          IF RxFlag = '1' THEN
            State       := '0';
            FramErr     <= '1';
--            RxValidData <= RxFrame;
          ELSIF RxRead = '1' THEN

--            RxValidData <= RxFrame;

            State   := '0';
            FramErr <= '0';
          END IF;

        WHEN OTHERS              =>
          RxRdy       <= '0';
          State       := '0';
          FramErr     <= '1';
          RxValidData <= RxFrame;
      END CASE;
    END IF;
  END PROCESS RxBackend;
-------------------------------------------------------------------------------
-- Tx Machines
-------------------------------------------------------------------------------
  -- purpose: Tx Parellel to serial
  -- type   : sequential
  -- inputs : CLK_I, rst_n
  -- outputs: 
  TxP2S               : PROCESS (CLK_I, rst_n)
    VARIABLE Tx_Count : STD_LOGIC_VECTOR(2 DOWNTO 0);  -- Tx Bit counter
  BEGIN  -- process TxP2S
    IF rst_n = '0' THEN                 -- asynchronous reset (active low)
      Tx_Count        := "000";
      Tx_reg          <= (OTHERS => '1');
      TxFlag          <= '0';

    ELSIF CLK_I'event AND CLK_I = '1' THEN  -- rising clock edge

      IF TxDisable = '0' AND GetNew = '1' THEN
        Tx_reg <= Tx_reg_i;
        TxFlag <= '1';

      ELSE
        IF Tx_En = '1' THEN

          IF Tx_count = "111" THEN
            Tx_count := "000";

            Tx_Reg   <= Tx_Reg_i;
            TxFlag   <= '1';
          ELSE
            Tx_count := Tx_count + 1;
            TxFlag   <= '0';
            Tx_Reg   <= Tx_Reg(6 DOWNTO 0) & '1';

          END IF;

        ELSE
          TxFlag <= '0';
        END IF;
      END IF;
    END IF;
  END PROCESS TxP2S;
-------------------------------------------------------------------------------
  -- purpose: Tx Backend machine
  -- type   : sequential
  -- inputs : CLK_I, rst_n
  -- outputs: 
  TxBackend        : PROCESS (CLK_I, rst_n)
    VARIABLE state : STD_LOGIC_VECTOR(1 DOWNTO 0);  -- Internal State
  BEGIN  -- process TxBackend
    IF rst_n = '0' THEN                 -- asynchronous reset (active low)

      State    := "11";                 -- Wait for NewValidFrame
      TxRdy    <= '0';
      TxErr    <= '0';
      Tx_Reg_i <= (OTHERS => '1');

    ELSIF CLK_I'event AND CLK_I = '1' THEN  -- rising clock edge

      CASE State IS
        WHEN"11" =>
          TxRdy <= '1';

        IF TxValidData = '1' THEN
          State := "01";                -- Get New byte
        END IF;

        WHEN "00" =>
        TxRdy <= '0';

        IF TxFlag = '1' THEN            -- and TxDisable = '0' then

          State := "01";                -- Get New Byte
        END IF;

        WHEN "01" =>
        TxRdy <= '1';

        IF TxFlag = '1' OR TxValidData = '0' THEN
          State    := "11";             -- Wait for New frame
          TxErr    <= '1';
          Tx_Reg_i <= (OTHERS => '1');
        ELSIF TxWrite = '1' THEN
          State    := "00";
          TxErr    <= '0';
          Tx_Reg_i <= TxD;
        END IF;

        WHEN OTHERS         =>
        TxRdy    <= '0';
        State    := "11";
        TxErr    <= '1';
        Tx_Reg_i <= (OTHERS => '1');
      END CASE;
    END IF;
  END PROCESS TxBackend;
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Serial Interface logic
-------------------------------------------------------------------------------
  Tx_en0         <= EnableRegister(0) AND Tx_En;
  Tx_en1         <= EnableRegister(1) AND Tx_En;
  Tx_en2         <= EnableRegister(2) AND Tx_En;
  Rx_en0         <= EnableRegister(0) AND Rx_En;
  Rx_en1         <= EnableRegister(1) AND Rx_En;
  Rx_en2         <= EnableRegister(2) AND Rx_En;
-------------------------------------------------------------------------------
  -- purpose: Serial Enable shift register
  -- type   : sequential
  -- inputs : clock, rst_n
  -- outputs: 
  SerialEnShift : PROCESS (CLK_I, rst_n)

  BEGIN  -- PROCESS SerialEnShift

    IF rst_n = '0' THEN                     -- asynchronous reset (active low)
      EnableRegister <= "00000000000000000000000000000001";
    ELSIF CLK_I'event AND CLK_I = '1' THEN  -- rising clock edge

      IF (EnShift = '1') THEN
        EnableRegister <= EnableRegister(30 DOWNTO 0) & EnableRegister(31);
      END IF;
    END IF;

  END PROCESS SerialEnShift;
END tdm_cont_rtl;
