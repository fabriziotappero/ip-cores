-------------------------------------------------------------------------------
-- Title      : TDM controller test bench
-- Project    : TDM controller
-------------------------------------------------------------------------------
-- File       : tdm_cont_tb.vhd
-- Author     : Jamil Khatib  <khatib@ieee.org>
-- Organization:  OpenCores.org
-- Created    : 2001/05/09
-- Last update:2001/05/18
-- Platform   : 
-- Simulators  : NC-sim/linux, Modelsim XE/windows98
-- Synthesizers: Leonardo
-- Target      : 
-- Dependency  : ieee.std_logic_1164, ieee.std_logic_unsigned
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
-- Date            :  2001/05/09
-- Modifier        :  Jamil Khatib  <khatib@ieee.org>
-- Desccription    :  Created
-- ToOptimize      :
-- Known Bugs      : 
-------------------------------------------------------------------------------
-- $Log: not supported by cvs2svn $
-- Revision 1.2  2001/05/18 16:56:16  jamil
-- Serial Data added
--
-- Revision 1.1  2001/05/13 21:13:54  jamil
-- Initial Release
--
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

LIBRARY TDM;
USE TDM.components_pkg.ALL;

-------------------------------------------------------------------------------

ENTITY tdm_cont_tb IS

END tdm_cont_tb;

-------------------------------------------------------------------------------

ARCHITECTURE tdm_cont_beh OF tdm_cont_tb IS


  SIGNAL rst_n        : STD_LOGIC := '0';
  SIGNAL C2           : STD_LOGIC := '0';
  SIGNAL DSTi         : STD_LOGIC;
  SIGNAL DSTo         : STD_LOGIC;
  SIGNAL F0_n         : STD_LOGIC;
  SIGNAL F0od_n       : STD_LOGIC;
  SIGNAL CLK_I        : STD_LOGIC := '0';
  SIGNAL RST_I        : STD_LOGIC;
  SIGNAL NoChannels   : STD_LOGIC_VECTOR(4 DOWNTO 0);
  SIGNAL DropChannels : STD_LOGIC_VECTOR(4 DOWNTO 0);
  SIGNAL RxD          : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL RxValidData  : STD_LOGIC;
  SIGNAL FramErr      : STD_LOGIC;
  SIGNAL RxRead       : STD_LOGIC;
  SIGNAL RxRdy        : STD_LOGIC;
  SIGNAL TxErr        : STD_LOGIC;
  SIGNAL TxD          : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL TxValidData  : STD_LOGIC;
  SIGNAL TxWrite      : STD_LOGIC;
  SIGNAL TxRdy        : STD_LOGIC;

  SIGNAL EnableSerialIF : STD_LOGIC := '0';    -- Enable Serial Interface

  SIGNAL Tx_en0 : STD_LOGIC;            -- Tx enable channel 0
  SIGNAL Tx_en1 : STD_LOGIC;            -- Tx enable channel 1
  SIGNAL Tx_en2 : STD_LOGIC;            -- Tx enable channel 2

  SIGNAL Rx_en0 : STD_LOGIC;            -- Rx enable channel 0
  SIGNAL Rx_en1 : STD_LOGIC;            -- Rx enable channel 1
  SIGNAL Rx_en2 : STD_LOGIC;            -- Rx enable channel 2

  SIGNAL SerDo : STD_LOGIC;             -- serial Data out
  SIGNAL SerDi : STD_LOGIC := '0';              -- Serial Data in


    TYPE SERIAL_typ IS ARRAY (0 TO 1023) OF STD_LOGIC;  -- Serial Data array

  SIGNAL RxData : SERIAL_typ;           -- Rx Serial Data
BEGIN  -- tdm_cont_beh

  NoChannels   <= "00101";
  DropChannels <= "00011";

  CLK_I <= NOT CLK_I AFTER 20 NS;
  C2    <= NOT C2    AFTER 244 NS;
  rst_n <= '0',
           '1'       AFTER 730 NS;


-------------------------------------------------------------------------------
  -- purpose: Initialization
  -- type   : combinational
  -- inputs : rst_n
  -- outputs: 
  INIT               : PROCESS (rst_n)
    VARIABLE counter : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";  -- Internal Counter
  BEGIN  -- PROCESS INIT

    IF (rst_n = '0') THEN

      RxData(0) <= '1';
      RxData(1) <= '1';
      RxData(2) <= '1';
      RxData(3) <= '1';
      RxData(4) <= '1';
      RxData(5) <= '1';
      RxData(6) <= '1';
      RxData(7) <= '1';

      RxData(8)  <= '1';
      RxData(9)  <= '1';
      RxData(10) <= '1';
      RxData(11) <= '1';
      RxData(12) <= '1';
      RxData(13) <= '1';
      RxData(14) <= '1';
      RxData(15) <= '1';

      RxData(16) <= '1';
      RxData(17) <= '1';
      RxData(18) <= '1';
      RxData(19) <= '1';
      RxData(20) <= '1';
      RxData(21) <= '1';
      RxData(22) <= '1';
      RxData(23) <= '1';

      -- Idle
      RxData(24) <= '0';
      RxData(25) <= '1';
      RxData(26) <= '1';
      RxData(27) <= '1';
      RxData(28) <= '1';
      RxData(29) <= '1';
      RxData(30) <= '1';
      RxData(31) <= '0';
      -- Opening Flag

      -- Data pattern
      FOR i IN 0 TO 59 LOOP
        RxData(32+8*i+0) <= Counter(0);
        RxData(32+8*i+1) <= Counter(1);
        RxData(32+8*i+2) <= Counter(2);
        RxData(32+8*i+3) <= Counter(3);
        RxData(32+8*i+4) <= Counter(4);
        RxData(32+8*i+5) <= Counter(5);
        RxData(32+8*i+6) <= Counter(6);
        RxData(32+8*i+7) <= Counter(7);

        Counter := Counter +1;
      END LOOP;  -- i

    END IF;
  END PROCESS INIT;
-------------------------------------------------------------------------------

  Frame_gen : PROCESS

  BEGIN  -- process Frame_gen
    F0_n <= '1';
    WAIT UNTIL rst_n = '1';
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
  -- inputs : C2, rst_n
  -- outputs: 
  Rx_gen       : PROCESS
    VARIABLE i : INTEGER := 0;
  BEGIN  -- PROCESS Rx_gen
    DSTi                 <= '1';

    WAIT UNTIL rst_n = '1';
    WHILE (TRUE) LOOP

      WAIT UNTIL F0_n = '0';

      FOR counter IN 0 TO 255 LOOP

        DSTi <= RxData(i);              --(counter+i*8);

        WAIT UNTIL C2 = '1';

        i := i +1;

      END LOOP;  -- counter

    END LOOP;  -- while

  END PROCESS Rx_gen;
-------------------------------------------------------------------------------  

  read_backend : PROCESS

  BEGIN  -- PROCESS HDLC_read
    RxRead <= '0';

    WHILE (TRUE) LOOP
      WAIT UNTIL Rxrdy = '1';
      WAIT UNTIL CLK_I = '1';
      WAIT UNTIL CLK_I = '0';
      RxRead <= '1';
      WAIT UNTIL Rxrdy = '0';
      WAIT UNTIL CLK_I = '0';
      RxRead <= '0';

    END LOOP;

  END PROCESS read_backend;
-------------------------------------------------------------------------------
  -- purpose: Tx Data generation
  -- type   : combinational
  -- inputs : 
  -- outputs: 
  Tx_gen             : PROCESS
    VARIABLE counter : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";  -- Interal counter
  BEGIN  -- process Tx_gen

    TxWrite <= '0';

    WHILE TRUE LOOP
      WAIT UNTIL TxRdy = '1';
      WAIT UNTIL CLK_I = '1';
      WAIT UNTIL CLK_I = '0';
      TxD     <= counter;
      TxWrite <= '1';
      counter := counter + 1;
      WAIT UNTIL TxRdy = '0';
      WAIT UNTIL CLK_I = '0';
      TxWrite <= '0';
    END LOOP;

  END PROCESS Tx_gen;
-------------------------------------------------------------------------------
  TxValidData <= '0',
                 '1' AFTER 20000 NS,
                 '0' AFTER 144000 NS;
-------------------------------------------------------------------------------

  DUT: tdm_cont_ent
    PORT MAP (
      rst_n          => rst_n,
      C2             => C2,
      DSTi           => DSTi,
      DSTo           => DSTo,
      F0_n           => F0_n,
      F0od_n         => F0od_n,
      CLK_I          => CLK_I,
      NoChannels     => NoChannels,
      DropChannels   => DropChannels,
      RxD            => RxD,
      RxValidData    => RxValidData,
      FramErr        => FramErr,
      RxRead         => RxRead,
      RxRdy          => RxRdy,
      TxErr          => TxErr,
      TxD            => TxD,
      TxValidData    => TxValidData,
      TxWrite        => TxWrite,
      TxRdy          => TxRdy,
      EnableSerialIF => EnableSerialIF,
      Tx_en0         => Tx_en0,
      Tx_en1         => Tx_en1,
      Tx_en2         => Tx_en2,
      Rx_en0         => Rx_en0,
      Rx_en1         => Rx_en1,
      Rx_en2         => Rx_en2,
      SerDo          => SerDo,
      SerDi          => SerDi);

END tdm_cont_beh;

-------------------------------------------------------------------------------
