-------------------------------------------------------------------------------
-- Title      : ISDN tdm controller
-- Project    : TDM controller
-------------------------------------------------------------------------------
-- File       : ISDN_cont_tb.vhd
-- Author     : Jamil Khatib  <khatib@ieee.org>
-- Organization:  OpenCores.org
-- Created    : 2001/04/30
-- Last update:2001/04/30
-- Platform   : 
-- Simulators  : NC-sim/linux, Modelsim XE/windows98
-- Synthesizers: Leonardo
-- Target      : 
-- Dependency  : ieee.std_logic_1164, ieee.std_logic_unsigned.
--               HDLC.hdlc_components_pkg
-------------------------------------------------------------------------------
-- Description:  ISDN tdm controller that extracts 2B+D channels from 3 time
-- slots of the incoming streem
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
-- Date            :  2001/04/30
-- Modifier        :  Jamil Khatib  <khatib@ieee.org>
-- Desccription    :  Created
-- ToOptimize      :
-- Known Bugs      :
-------------------------------------------------------------------------------
-- $Log: not supported by cvs2svn $
-- Revision 1.1  2001/05/06 17:55:23  jamil
-- Initial Release
--
------------------------------------------------------------------------------
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library HDLC;
use HDLC.hdlc_components_pkg.all;

-------------------------------------------------------------------------------

entity isdn_cont_tb is

end isdn_cont_tb;

-------------------------------------------------------------------------------

architecture isdn_cont_tb of isdn_cont_tb is

  component isdn_cont_ent
    port (
      rst_n     : in  std_logic;
      C2        : in  std_logic;
      DSTi      : in  std_logic;
      DSTo      : out std_logic;
      F0_n      : in  std_logic;
      F0od_n    : out std_logic;
      HDLCen1   : out std_logic;
      HDLCen2   : out std_logic;
      HDLCen3   : out std_logic;
      HDLCTxen1 : out std_logic;
      HDLCTxen2 : out std_logic;
      HDLCTxen3 : out std_logic;
      Dout      : out std_logic;
      Din1      : in  std_logic;
      Din2      : in  std_logic;
      Din3      : in  std_logic);
  end component;

  signal rst_n     : std_logic := '0';
  signal C2        : std_logic := '0';
  signal DSTi      : std_logic;
  signal DSTo      : std_logic;
  signal F0_n      : std_logic;
  signal F0od_n    : std_logic;
  signal HDLCen1   : std_logic;
  signal HDLCen2   : std_logic;
  signal HDLCen3   : std_logic;
  signal HDLCTxen1 : std_logic;
  signal HDLCTxen2 : std_logic;
  signal HDLCTxen3 : std_logic;
  signal Dout      : std_logic;
  signal Din1      : std_logic;
  signal Din2      : std_logic;
  signal Din3      : std_logic;

  --Rx HDLC
  signal RxData_o      : std_logic_vector(7 downto 0);
  signal ValidFrame    : std_logic;
  signal FrameError_i  : std_logic;
  signal AbortSignal_i : std_logic;
  signal Rx_Readbyte   : std_logic;
  signal Rx_rdy        : std_logic;

  --Tx HDLC
  signal Tx_ValidFrame   : std_logic;
  signal Tx_AbortFrame   : std_logic;
  signal Tx_AbortedTrans : std_logic;
  signal Tx_WriteByte    : std_logic;
  signal Tx_rdy          : std_logic;
  signal TxData          : std_logic_vector(7 downto 0);

  type SERIAL_typ is array (0 to 511) of std_logic;  -- Serial Data array

  signal RxData : SERIAL_typ;           -- Rx Serial Data

begin  -- isdn_cont_tb

  C2    <= not C2 after 244 ns;
  rst_n <= '0',
           '1'    after 730 ns;


-------------------------------------------------------------------------------
  -- purpose: Initialization
  -- type   : combinational
  -- inputs : rst_n
  -- outputs: 
  INIT               : process (rst_n)
    variable counter : std_logic_vector(7 downto 0) := "00000000";  -- Internal Counter
  begin  -- PROCESS INIT

    if (rst_n = '0') then

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
      for i in 0 to 5 loop
        RxData(32+8*i+0) <= Counter(0);
        RxData(32+8*i+1) <= Counter(1);
        RxData(32+8*i+2) <= Counter(2);
        RxData(32+8*i+3) <= Counter(3);
        RxData(32+8*i+4) <= Counter(4);
        RxData(32+8*i+5) <= Counter(5);
        RxData(32+8*i+6) <= Counter(6);
        RxData(32+8*i+7) <= Counter(7);

        Counter := Counter +1;
      end loop;  -- i






      -- Data pattern
--      FOR i IN 0 TO 31 LOOP
--        RxData(8*i+0) <= Counter(0);
--        RxData(8*i+1) <= Counter(1);
--        RxData(8*i+2) <= Counter(2);
--        RxData(8*i+3) <= Counter(3);
--        RxData(8*i+4) <= Counter(4);
--        RxData(8*i+5) <= Counter(5);
--        RxData(8*i+6) <= Counter(6);
--        RxData(8*i+7) <= Counter(7);

--        Counter := Counter +1;
--      END LOOP;                       -- i

    end if;
  end process INIT;
-- purpose: Framing pulse genertor
-- type   : combinational
-- inputs : 
-- outputs: 
--  F0_gen : process
--  begin                               -- process F0_gen

  F0_n <= '1',
--    wait until rst_n = '1';

          '0' after 970 ns,
          '1' after 1464 ns,
          '0' after 12200 ns,
          '1' after 12688 ns,
          '0' after 25367 ns,
          '1' after 25864 ns;

--    wait until C2 = '0';
--    F0_n <= '0' after 15130 ns,
--            '1' after 15500 ns;
--  end process F0_gen;
-------------------------------------------------------------------------------
  -- purpose: Rx Data generator
  -- type   : combinational
  -- inputs : C2, rst_n
  -- outputs: 
  Rx_gen       : process
    variable i : integer := 0;
  begin  -- PROCESS Rx_gen
    DSTi                 <= '1';

    wait until rst_n = '1';
    while (true) loop

      wait until F0_n = '0';

      for counter in 0 to 31 loop

        DSTi <= RxData(i);              --(counter+i*8);

        wait until C2 = '1';

        i := i +1;

      end loop;  -- counter

    end loop;  -- while

  end process Rx_gen;

-------------------------------------------------------------------------------
  -- purpose: Tx generator for serial backend data
  -- type   : combinational
  -- inputs : 
  -- outputs: 
--  Tx_gen                 : PROCESS
--    VARIABLE count_index : INTEGER := 0;  --

--  BEGIN                               -- PROCESS Tx_gen
--    Din1 <= '0';
--    Din2 <= '0';
--    Din3 <= '0';

--    WAIT UNTIL rst_n = '1';

----    wait until C2 = '0';
--    WAIT UNTIL HDLCTxen1 = '1' AND C2 = '0';

--    WHILE HDLCTxen1 = '1' LOOP
--      Din1        <= RxData(count_index);
--      count_index := count_index + 1;
--      WAIT UNTIL C2 = '1';
--    END LOOP;

--    WHILE HDLCTxen2 = '1' LOOP
--      Din2        <= RxData(count_index);
--      count_index := count_index + 1;
--      WAIT UNTIL C2 = '1';
--    END LOOP;

--    WHILE HDLCTxen3 = '1' LOOP
--      Din3        <= RxData(count_index);
--      count_index := count_index + 1;
--      WAIT UNTIL C2 = '1';
--    END LOOP;

--  END PROCESS Tx_gen;
-------------------------------------------------------------------------------
  HDLC_read : process

  begin  -- PROCESS HDLC_read
    Rx_Readbyte <= '0';

    while (true) loop
      wait until Rx_rdy = '1';
      Rx_Readbyte <= '1';
      wait until Rx_rdy = '0';
      Rx_Readbyte <= '0';

    end loop;

  end process HDLC_read;
  DUT : isdn_cont_ent
    port map (
      rst_n     => rst_n,
      C2        => C2,
      DSTi      => DSTi,
      DSTo      => DSTo,
      F0_n      => F0_n,
      F0od_n    => F0od_n,
      HDLCen1   => HDLCen1,
      HDLCen2   => HDLCen2,
      HDLCen3   => HDLCen3,
      HDLCTxen1 => HDLCTxen1,
      HDLCTxen2 => HDLCTxen2,
      HDLCTxen3 => HDLCTxen3,
      Dout      => Dout,
      Din1      => Din1,
      Din2      => Din2,
      Din3      => Din3);


  RxChannel : RxChannel_ent
    port map (
      Rxclk       => C2,
      rst         => rst_n,
      Rx          => Dout,
      RxData      => RxData_o,
      ValidFrame  => ValidFrame,
      FrameError  => FrameError_i,
      AbortSignal => AbortSignal_i,
      Readbyte    => Rx_Readbyte,
      rdy         => Rx_rdy,
      RxEn        => HDLCen1);


  TxChannel : TxChannel_ent
    port map (
      TxClk        => C2,
      rst_n        => rst_n,
      TXEN         => HDLCTxen1,
      Tx           => Din1,
      ValidFrame   => Tx_ValidFrame,
      AbortFrame   => Tx_AbortFrame,
      AbortedTrans => Tx_AbortedTrans,
      WriteByte    => Tx_WriteByte,
      rdy          => Tx_rdy,
      TxData       => TxData);

end isdn_cont_tb;

-------------------------------------------------------------------------------
