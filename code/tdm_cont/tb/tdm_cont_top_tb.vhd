-------------------------------------------------------------------------------
-- Title      : TDM controller top test bench
-- Project    : TDM controller
-------------------------------------------------------------------------------
-- File       : tdm_cont_top_tb.vhd
-- Author     : Jamil Khatib  <khatib@ieee.org>
-- Organization:  OpenCores.org
-- Created    : 2001/05/18
-- Last update:2001/05/25
-- Platform   : 
-- Simulators  : NC-sim/linux, Modelsim XE/windows98
-- Synthesizers: Leonardo
-- Target      : 
-- Dependency  : ieee.std_logic_1164,ieee.std_logic_unsigned
--               tdm.components_pkg
-------------------------------------------------------------------------------
-- Description:  tdm controller test bench
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
-- Date            :  2001/05/18
-- Modifier        :  Jamil Khatib  <khatib@ieee.org>
-- Desccription    :  Created
-- ToOptimize      :
-- Known Bugs      : 
-------------------------------------------------------------------------------
-- $Log: not supported by cvs2svn $
-- Revision 1.1  2001/05/24 22:48:56  jamil
-- TDM Initial release
--
------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

LIBRARY tdm;
USE tdm.components_pkg.ALL;

-------------------------------------------------------------------------------

ENTITY tdm_cont_top_tb IS

END tdm_cont_top_tb;

-------------------------------------------------------------------------------

ARCHITECTURE tdm_cont_top_tb_beh OF tdm_cont_top_tb IS


  SIGNAL CLK_I  : STD_LOGIC := '0';
  SIGNAL RST_I  : STD_LOGIC := '1';
  SIGNAL ACK_O  : STD_LOGIC;
  SIGNAL ADR_I  : STD_LOGIC_VECTOR(2 DOWNTO 0);
  SIGNAL CYC_I  : STD_LOGIC;
  SIGNAL DAT_I  : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL DAT_O  : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL RTY_O  : STD_LOGIC;
  SIGNAL STB_I  : STD_LOGIC;
  SIGNAL WE_I   : STD_LOGIC;
  SIGNAL TAG0_O : STD_LOGIC;
  SIGNAL TAG1_O : STD_LOGIC;
  SIGNAL C2     : STD_LOGIC := '0';
  SIGNAL DSTi   : STD_LOGIC;
  SIGNAL DSTo   : STD_LOGIC;
  SIGNAL F0_n   : STD_LOGIC;
  SIGNAL F0od_n : STD_LOGIC;

  SIGNAL NoChannels   : STD_LOGIC_VECTOR(4 DOWNTO 0);  -- Number of TDM channels
  SIGNAL DropChannels : STD_LOGIC_VECTOR(4 DOWNTO 0);
                                        -- Number of TDM channels to be dropped

  TYPE SERIAL_typ IS ARRAY (0 TO 1023) OF STD_LOGIC;  -- Serial Data array

  SIGNAL RxData : SERIAL_typ;           -- Rx Serial Data


BEGIN  -- tdm_cont_top_tb_beh


  CLK_I <= NOT CLK_I AFTER 20 NS;
  RST_I <= '1',
           '0'       AFTER 50 NS;

  C2 <= NOT C2 AFTER 244 NS;

-------------------------------------------------------------------------------
  -- purpose: Initialization
  -- type   : combinational
  -- inputs : rst_I
  -- outputs: 
  INIT               : PROCESS (RST_I)
    VARIABLE counter : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";  -- Internal Counter
  BEGIN  -- PROCESS INIT

    IF (RST_I = '1') THEN

      -- Data pattern
      FOR i IN 0 TO 127 LOOP
        RxData(0+8*i+0) <= Counter(0);
        RxData(0+8*i+1) <= Counter(1);
        RxData(0+8*i+2) <= Counter(2);
        RxData(0+8*i+3) <= Counter(3);
        RxData(0+8*i+4) <= Counter(4);
        RxData(0+8*i+5) <= Counter(5);
        RxData(0+8*i+6) <= Counter(6);
        RxData(0+8*i+7) <= Counter(7);

        Counter := Counter +1;
      END LOOP;  -- i

    END IF;
  END PROCESS INIT;
-------------------------------------------------------------------------------
  -- purpose: Tx Taskes generation
  -- type   : combinational
  -- inputs : 
  -- outputs: 
  Tasks              : PROCESS
    VARIABLE counter : STD_LOGIC_VECTOR(7 DOWNTO 0);  -- Internal counter
  BEGIN  -- PROCESS TxTasks

    NoChannels   <= "00110";
    DropChannels <= "00000";
    WAIT UNTIL CLK_I = '0';

    WE_I <= '0';

    STB_I <= '0';
    CYC_I <= '0';
    ADR_I <= "100";
    DAT_I <= (OTHERS => '0');

    WAIT UNTIL CLK_I = '0';

    STB_I <= '1';
    CYC_I <= '1';
    WE_I  <= '1';
    ADR_I <= "100";                     -- Channels
    DAT_I <= "0000000000000000" & "000" & DropChannels & "000" & NoChannels;

    WAIT UNTIL ACK_O = '1';
    WAIT UNTIL CLK_I = '0';

    WE_I <= '0';

    STB_I <= '0';
    CYC_I <= '0';
    ADR_I <= "010";

    WAIT UNTIL TAG1_O = '1';            -- wait for RxRdy
    STB_I <= '1';
    CYC_I <= '1';
    ADR_I <= "010";                     -- Rx_Sc

    WAIT UNTIL ACK_O = '1';
    WAIT UNTIL CLK_I = '0';

    STB_I <= '0';
    CYC_I <= '0';

    ADR_I <= "011";                     -- Rx_Buff

--    wait until CLK_I = '0';
    WAIT UNTIL CLK_I = '1';
    WAIT UNTIL CLK_I = '0';

    STB_I <= '1';
    CYC_I <= '1';

    Counter := (OTHERS => '0');


    FOR i IN 0 TO conv_integer(NoChannels - DropChannels) LOOP


      WAIT UNTIL ACK_O = '1';

      ASSERT (DAT_O(7 DOWNTO 0) = counter)
        REPORT "Data byte 1 missmatch"
        SEVERITY WARNING;


      IF (counter = (NoChannels - DropChannels) ) THEN
        EXIT;
      END IF;

      counter := counter +1;
      ASSERT (DAT_O(15 DOWNTO 8) = counter)
        REPORT "Data byte 2 missmatch"
        SEVERITY WARNING;


      IF (counter = (NoChannels - DropChannels) ) THEN
        EXIT;
      END IF;

      counter := counter +1;
      ASSERT (DAT_O(23 DOWNTO 16) = counter)
        REPORT "Data byte 3 missmatch"
        SEVERITY WARNING;

      IF (counter = (NoChannels - DropChannels) ) THEN
        EXIT;
      END IF;

      counter := counter +1;
      ASSERT (DAT_O(31 DOWNTO 24) = counter)
        REPORT "Data byte 4 missmatch"
        SEVERITY WARNING;


      counter := counter +1;

    END LOOP;  -- i


    WAIT UNTIL CLK_I = '0';

    STB_I <= '0';
    CYC_I <= '0';
    ADR_I <= "000";
-------------------------------------------------------------------------------
-- -- -- --
-------------------------------------------------------------------------------
    -- Transmit
    IF TAG0_O = '0' THEN
      WAIT UNTIL TAG0_O = '1';
    END IF;

    WAIT UNTIL CLK_I = '0';
    counter := (OTHERS => '0');

    STB_I <= '1';
    CYC_I <= '1';
    ADR_I <= "001";                     -- Tx_Buff
    WE_I  <= '1';                       -- Write


    FOR i IN 0 TO conv_integer(NoChannels - DropChannels)/4 LOOP

      DAT_I(7 DOWNTO 0)   <= counter;
      counter             := counter +1;
      DAT_I(15 DOWNTO 8)  <= counter;
      counter             := counter +1;
      DAT_I(23 DOWNTO 16) <= counter;
      counter             := counter +1;
      DAT_I(31 DOWNTO 24) <= counter;
      counter             := counter +1;

      WAIT UNTIL ACK_O = '1';

      WAIT UNTIL CLK_I = '0';

    END LOOP;  -- i


    STB_I <= '0';
    CYC_I <= '0';
    WE_I  <= '0';

    WAIT UNTIL CLK_I = '1';
    WAIT UNTIL CLK_I = '0';
    STB_I <= '1';
    CYC_I <= '1';
    WE_I  <= '0';
    ADR_I <= "000";                     -- Tx_Sc

    WAIT UNTIL ACK_O = '1';
    WAIT UNTIL CLK_I = '0';

    STB_I <= '0';
    CYC_I <= '0';
    WE_I  <= '0';

  END PROCESS Tasks;

-------------------------------------------------------------------------------
  Frame_gen : PROCESS
  BEGIN  -- process Frame_gen
    F0_n <= '1';
    WAIT UNTIL RST_I = '0';
    WAIT UNTIL C2 = '0';

    WHILE TRUE LOOP

      F0_n <= '0';
      WAIT UNTIL C2 = '1';
      WAIT UNTIL C2 = '0';
      F0_n <= '1';

      FOR i IN 0 TO 254 LOOP
        WAIT UNTIL C2 = '1';
        WAIT UNTIL C2 = '0';

      END LOOP;  -- i 
    END LOOP;

  END PROCESS Frame_gen;
-------------------------------------------------------------------------------
  -- purpose: Rx Data generator
  -- type   : combinational
  -- inputs : C2, RST_I
  -- outputs: 
  Rx_gen : PROCESS
--    VARIABLE i : INTEGER := 0;
  BEGIN  -- PROCESS Rx_gen
    DSTi <= '1';

    WAIT UNTIL RST_I = '0';
    WHILE (TRUE) LOOP

      WAIT UNTIL F0_n = '0';
      WAIT UNTIL C2 = '1';

      FOR i IN 0 TO 127 LOOP
        DSTi <= RxData(0+8*i+7);
        WAIT UNTIL C2 = '1';
        DSTi <= RxData(0+8*i+6);
        WAIT UNTIL C2 = '1';
        DSTi <= RxData(0+8*i+5);
        WAIT UNTIL C2 = '1';
        DSTi <= RxData(0+8*i+4);
        WAIT UNTIL C2 = '1';
        DSTi <= RxData(0+8*i+3);
        WAIT UNTIL C2 = '1';
        DSTi <= RxData(0+8*i+2);
        WAIT UNTIL C2 = '1';
        DSTi <= RxData(0+8*i+1);
        WAIT UNTIL C2 = '1';
        DSTi <= RxData(0+8*i+0);
        WAIT UNTIL C2 = '1';
      END LOOP;  -- i

    END LOOP;  -- while

  END PROCESS Rx_gen;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
  DUT : tdm_cont_top_ent
    PORT MAP (
      CLK_I  => CLK_I,
      RST_I  => RST_I,
      ACK_O  => ACK_O,
      ADR_I  => ADR_I,
      CYC_I  => CYC_I,
      DAT_I  => DAT_I,
      DAT_O  => DAT_O,
      RTY_O  => RTY_O,
      STB_I  => STB_I,
      WE_I   => WE_I,
      TAG0_O => TAG0_O,
      TAG1_O => TAG1_O,
      C2     => C2,
      DSTi   => DSTi,
      DSTo   => DSTo,
      F0_n   => F0_n,
      F0od_n => F0od_n);



END tdm_cont_top_tb_beh;

-------------------------------------------------------------------------------
