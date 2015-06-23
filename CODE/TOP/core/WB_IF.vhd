-------------------------------------------------------------------------------
-- Title      :  WISHBONE bus interface
-- Project    :  HDLC controller
-------------------------------------------------------------------------------
-- File        : WB_IF.vhd
-- Author      : Jamil Khatib  (khatib@ieee.org)
-- Organization: OpenIPCore Project
-- Created     :2001/04/11
-- Last update:2001/04/18
-- Platform :
-- Simulators  : Modelsim 5.3XE/Windows98,NC-SIM/Linux
-- Synthesizers: 
-- Target      : 
-- Dependency  : ieee.std_logic_1164
-------------------------------------------------------------------------------
-- Description:  Wishbone bus interface
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
-- Date            :  11 April 2001
-- Modifier        :   Jamil Khatib (khatib@ieee.org)
-- Desccription    :   Created
-- ToOptimize      :
-- Bugs            :   
-------------------------------------------------------------------------------
-- $Log: not supported by cvs2svn $
-- Revision 1.3  2001/04/27 18:21:59  jamil
-- After Prelimenray simulation
--
-- Revision 1.2  2001/04/22 20:08:16  jamil
-- Top level simulation
--
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY WB_IF_ent IS
  GENERIC (
    ADD_WIDTH : integer := 7);          -- Address width

  PORT (
    -- WB Bus ports
    CLK_I  : IN  std_logic;                      -- System Clock
    RST_I  : IN  std_logic;                      -- System Reset
    ACK_O  : OUT std_logic;                      -- acknowledge
    ADR_I  : IN  std_logic_vector(2 DOWNTO 0);   -- address
    CYC_I  : IN  std_logic;                      -- Bus cycle
    DAT_I  : IN  std_logic_vector(31 DOWNTO 0);  -- Input data
    DAT_O  : OUT std_logic_vector(31 DOWNTO 0);  -- Output data
    RTY_O  : OUT std_logic;                      -- retry
    STB_I  : IN  std_logic;                      -- strobe
    WE_I   : IN  std_logic;                      -- Write
    TAG0_O : OUT std_logic;                      -- TAG0 (TxDone)
    TAG1_O : OUT std_logic;                      -- TAG1_O (RxRdy)

-- Internal ports
    -- Tx
    TxEnable     : OUT std_logic;       -- TxEnable (Write Frame completed)
    TxDone       : IN  std_logic;       -- Transmission Done (Read Frame completed)
    TxDataInBuff : OUT std_logic_vector(7 DOWNTO 0);  -- Input Data
    Txwr         : OUT std_logic;       -- Tx Write Buffer
    TxAborted    : IN  std_logic;       -- Aborted Frame
    TxAbort      : OUT std_logic;       -- Abort Transmission
    TxOverflow   : IN  std_logic;       -- Tx Buffer Overflow
    TxFCSen      : OUT std_logic;       -- FCS enable;

    -- Rx
    RxFrameSize   : IN  std_logic_vector(ADD_WIDTH-1 DOWNTO 0);  -- Frame Length
    RxRdy         : IN  std_logic;      -- Rx Ready
    RxDataBuffOut : IN  std_logic_vector(7 DOWNTO 0);  -- Output Rx Buffer
    RxOverflow    : IN  std_logic;      -- Rx Buffer Overflow
    RxFrameError  : IN  std_logic;      -- Frame Error
    RxFCSErr      : IN  std_logic;      -- Rx FCS Error
    RxRd          : OUT std_logic;      -- Rx Read data
    RxAbort       : IN  std_logic       -- Received Abort signal

    );

END WB_IF_ent;

ARCHITECTURE WB_IF_rtl OF WB_IF_ent IS
  SIGNAL ack_0 : std_logic;             -- ack Reg 0
  SIGNAL ack_1 : std_logic;             -- ack Reg 1
  SIGNAL ack_2 : std_logic;             -- ack Reg 2
  SIGNAL ack_3 : std_logic;             -- ack Reg 3
  SIGNAL ack_4 : std_logic;             -- ack Reg 4

  SIGNAL DATO_0 : std_logic_vector(31 DOWNTO 0);  -- data out 0
  SIGNAL DATO_1 : std_logic_vector(31 DOWNTO 0);  -- data out 1
  SIGNAL DATO_2 : std_logic_vector(31 DOWNTO 0);  -- data out 2
  SIGNAL DATO_3 : std_logic_vector(31 DOWNTO 0);  -- data out 3
  SIGNAL DATO_4 : std_logic_vector(31 DOWNTO 0);  -- data out 4

  SIGNAL en_0 : std_logic;              -- Enable reg 0
  SIGNAL en_1 : std_logic;              -- Enable reg 1
  SIGNAL en_2 : std_logic;              -- Enable reg 2
  SIGNAL en_3 : std_logic;              -- Enable reg 3
  SIGNAL en_4 : std_logic;              -- Enable reg 4

  SIGNAL counter   : integer RANGE 0 TO 7;  -- System counter
  SIGNAL rst_count : std_logic;             -- Reset counter

BEGIN  -- WB_IF_rtl

-- purpose: WB fsm
-- type   : sequential
-- inputs : CLK_I, RST_I
-- outputs: 
  WB_fsm : PROCESS (CLK_I, RST_I)

  BEGIN  -- PROCESS WB_fsm
    IF (CLK_I'event AND CLK_I = '1') THEN
      RTY_O <= '0';

      IF (RST_I = '1') THEN             -- synchronous reset

        ACK_O  <= '0';
        DAT_O  <= (OTHERS => '0');
        RTY_O  <= '0';
        TAG0_O <= '0';
        TAG1_O <= '0';

        en_0      <= '0';
        en_1      <= '0';
        en_2      <= '0';
        en_3      <= '0';
        en_4      <= '0';
        rst_count <= '1';

      ELSE
        TAG0_O <= TxDone;
        TAG1_O <= RxRdy;

        IF (CYC_I = '1' AND STB_I = '1') THEN

          CASE ADR_I IS
            WHEN "000" =>               -- Tx_SC
              ACK_O <= ack_0;
              DAT_O <= DATO_0;

              en_0      <= '1';
              en_1      <= '0';
              en_2      <= '0';
              en_3      <= '0';
              en_4      <= '0';
              rst_count <= '1';

            WHEN "001" =>               -- Tx_Buff
              ACK_O <= ack_1;
              DAT_O <= DATO_1;

              en_0 <= '0';
              en_1 <= '1' and not ack_1;
              en_2 <= '0';
              en_3 <= '0';
              en_4 <= '0';

              IF counter = 4 THEN
                rst_count <= '1';
                else
                  rst_count <= '0';
              END IF;

            WHEN "010" =>               -- Rx_SC
              ACK_O <= ack_2;
              DAT_O <= DATO_2;

              en_0 <= '0';
              en_1 <= '0';
              en_2 <= '1';
              en_3 <= '0';
              en_4 <= '0';

            WHEN "011" =>               -- Rx_Buff
              ACK_O <= ack_3;
              DAT_O <= DATO_3;

              en_0 <= '0';
              en_1 <= '0';
              en_2 <= '0';
              en_3 <= '1' and not ack_3;
              en_4 <= '0';

              IF counter = 7 THEN
                rst_count <= '1';
                else
                  rst_count <= '0';
              END IF;
              
            WHEN "100" =>               -- Rx_len
              ACK_O <= ack_4;
              DAT_O <= DATO_4;

              en_0 <= '0';
              en_1 <= '0';
              en_2 <= '0';
              en_3 <= '0';
              en_4 <= '1';

            WHEN OTHERS        =>
              DAT_O <= (OTHERS => '0');
              ACK_O <= '1';

              en_0 <= '0';
              en_1 <= '0';
              en_2 <= '0';
              en_3 <= '0';
              en_4 <= '0';

          END CASE;

        ELSE

          DAT_O <= (OTHERS => '0');
          ACK_O <= '0';

          en_0 <= '0';
          en_1 <= '0';
          en_2 <= '0';
          en_3 <= '0';
          en_4 <= '0';

        END IF;  -- cycle

      END IF;  --clock

    END IF;  -- reset

  END PROCESS WB_fsm;

-------------------------------------------------------------------------------
  -- purpose: Register0
  -- type   : sequential
  -- inputs : CLK_I, RST_I
  -- outputs: 
  reg0 : PROCESS (CLK_I, RST_I)

  BEGIN  -- PROCESS reg0
    IF (CLK_I'event AND CLK_I = '1') THEN

      IF (RST_I = '1') THEN
        ack_0    <= '0';
        DATO_0   <= (OTHERS => '0');
        TxEnable <= '0';
        TxAbort  <= '0';
        TxFCSen  <= '1';

      ELSE
        DATO_0 <= "000000000000000000000000"&
                  "00" & '0'& TxOverflow & TxAborted & "00" & TxDone;
        ack_0  <= en_0;

        IF (en_0 = '1' AND WE_I = '1') THEN

          TxEnable <= DAT_I(1);
          TxAbort  <= DAT_I(2);
          TxFCSen  <= DAT_I(5);

        END IF;  -- Write and en_0


      END IF;  -- rst
    END IF;  -- clk

  END PROCESS reg0;
-------------------------------------------------------------------------------
  -- purpose: Register1
  -- type   : sequential
  -- inputs : CLK_I, RST_I
  -- outputs: 
  reg1 : PROCESS (CLK_I, RST_I)

--    VARIABLE counter : integer RANGE 0 TO 3;  -- Internal counter

  BEGIN  -- PROCESS reg1
    IF (CLK_I'event AND CLK_I = '1') THEN

      IF (RST_I = '1') THEN
        ack_1   <= '0';
        DATO_1  <= (OTHERS => '0');
--        counter := 0;

      ELSE                              -- reset
        DATO_1 <= (OTHERS => '0');

        IF (WE_I = '1' AND en_1 = '1') THEN

--          Txwr             <= '1';
          CASE counter IS
            WHEN 0      =>
          Txwr             <= '1';
              TxDataInBuff <= DAT_I(7 DOWNTO 0);
              ack_1        <= '0';
--              counter      := counter + 1;
            WHEN 1      =>
          Txwr             <= '1';
              TxDataInBuff <= DAT_I(15 DOWNTO 8);
              ack_1        <= '0';
--              counter      := counter + 1;
            WHEN 2      =>
          Txwr             <= '1';
              TxDataInBuff <= DAT_I(23 DOWNTO 16);
              ack_1        <= '0';
--              counter      := counter + 1;
            WHEN 3      =>
          Txwr             <= '1';
              TxDataInBuff <= DAT_I(31 DOWNTO 24);
              ack_1        <= '1';
--              counter      := 0;
            WHEN OTHERS => 
          Txwr             <= '0';
		TxDataInBuff <= (others=> '0');
              ack_1        <= '0';
          END CASE;

        ELSE                            -- WE_I

          TxDataInBuff <= (OTHERS => '0');
--          counter      := 0;
          Txwr         <= '0';
          ack_1        <= '0';
        END IF;  -- WE_I and en_1


      END IF;  -- rst
    END IF;  -- clk

  END PROCESS reg1;

-------------------------------------------------------------------------------
  -- purpose: Register2
  -- type   : sequential
  -- inputs : CLK_I, RST_I
  -- outputs: 
  reg2 : PROCESS (CLK_I, RST_I)

  BEGIN  -- PROCESS reg3
    IF (CLK_I'event AND CLK_I = '1') THEN

      IF (RST_I = '1') THEN
        ack_2  <= '0';
        DATO_2 <= (OTHERS => '0');

      ELSE
        DATO_2 <= "000000000000000000000000"&
                  "000"& RxOverflow & RxAbort & RxFrameError & RxFCSErr & RxRdy;
        ack_2  <= en_2;

      END IF;  -- rst
    END IF;  -- clk

  END PROCESS reg2;
-------------------------------------------------------------------------------
  -- purpose: Register3
  -- type   : sequential
  -- inputs : CLK_I, RST_I
  -- outputs: 
  reg3 : PROCESS (CLK_I, RST_I)

--    VARIABLE count : integer RANGE 0 TO 5;  -- Internal counter

  BEGIN  -- PROCESS reg1
    IF (CLK_I'event AND CLK_I = '1') THEN

      IF (RST_I = '1') THEN
        ack_3   <= '0';
        DATO_3  <= (OTHERS => '0');
  --      count := 0;

      ELSE

        IF (en_3 = '1' AND WE_I = '0') THEN

--          if (WE_I = '0') then

          CASE counter IS
            WHEN 0               =>
              RxRd    <= '1';
              DATO_3  <= (OTHERS => '0');
              ack_3   <= '0';
--              count := count + 1;

            WHEN 1               =>
              RxRd    <= '1';
--                DATO_3  <= "000000000000000000000000" & RxDataBuffOut;
              DATO_3  <= RxDataBuffOut & DATO_3(31 downto 8);
--              DATO_3  <= (OTHERS => '0');
              ack_3   <= '0';
--              count := count + 1;

            WHEN 2 =>
              RxRd    <= '1';
              DATO_3  <= RxDataBuffOut & DATO_3(31 DOWNTO 8);
              ack_3   <= '0';
--              count := count + 1;

            WHEN 3 =>
              RxRd <= '0';

              DATO_3  <= RxDataBuffOut & DATO_3(31 DOWNTO 8);
              ack_3   <= '0';
--              count := count + 1;
            WHEN 4 =>
              RxRd    <= '0';

              DATO_3  <= RxDataBuffOut & DATO_3(31 DOWNTO 8);
              ack_3   <= '0';
--              count := count +1;
            WHEN 5 =>
              RxRd    <= '0';

              DATO_3  <= RxDataBuffOut & DATO_3(31 DOWNTO 8);
              ack_3   <= '1';
----              count := 0;

            WHEN OTHERS => 
              RxRd    <= '0';

              DATO_3  <= (others=>'0');
              ack_3   <= '0';
          END CASE;

--          else
--            DATO_3  <= (others => '0');
--            counter := 0;
--            RxRd    <= '0';
--            ack_3   <= '0';

--          end if;                     -- Write

        ELSE
          DATO_3  <= (OTHERS => '0');
--          count := 0;
          RxRd    <= '0';
          ack_3   <= '0';

        END IF;  -- en

      END IF;  -- rst
    END IF;  -- clk

  END PROCESS reg3;

  -----------------------------------------------------------------------------
  -- purpose: Register4
  -- type   : sequential
  -- inputs : CLK_I, RST_I
  -- outputs: 
  reg4 : PROCESS (CLK_I, RST_I)

  BEGIN  -- PROCESS reg4
    IF (CLK_I'event AND CLK_I = '1') THEN

      IF (RST_I = '1') THEN
        ack_4  <= '0';
        DATO_4 <= (OTHERS => '0');

      ELSE
        DATO_4 <= "000000000000000000000000"&
                  '0' & RxFrameSize;
        ack_4  <= en_4;

      END IF;  -- rst
    END IF;  -- clk

  END PROCESS reg4;
  -----------------------------------------------------------------------------

-- purpose: system counter
-- type   : sequential
-- inputs : CLK_I
-- outputs: 
  sys_counter : PROCESS (CLK_I)
  BEGIN  -- process sys_counter

    IF CLK_I'event AND CLK_I = '1' THEN  -- rising clock edge
      
      IF rst_count = '1' THEN
        
        counter <= 0;
        
      ELSIF en_1 = '1' OR en_3 = '1' THEN
        
        counter <= counter +1;

	ELSE
        counter <= 0;
      END IF;
    END IF;
  END PROCESS sys_counter;
  -----------------------------------------------------------------------------
  
END WB_IF_rtl;
