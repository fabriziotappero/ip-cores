---====================== Start Software License ========================---
--==                                                                    ==--
--== This license governs the use of this software, and your use of     ==--
--== this software constitutes acceptance of this license. Agreement    ==--
--== with all points is required to use this software.                  ==--
--==                                                                    ==--
--== 1. This source file may be used and distributed without            ==--
--== restriction provided that this software license statement is not   ==--
--== removed from the file and that any derivative work contains the    ==--
--== original software license notice and the associated disclaimer.    ==--
--==                                                                    ==--
--== 2. This source file is free software; you can redistribute it      ==--
--== and/or modify it under the restriction that UNDER NO CIRCUMTANCES  ==--
--== this Software is to be used to CONSTRUCT a SPACEWIRE INTERFACE     ==--
--== This implies modification and/or derivative work of this Software. ==--
--==                                                                    ==--
--== 3. This source is distributed in the hope that it will be useful,  ==--
--== but WITHOUT ANY WARRANTY; without even the implied warranty of     ==--
--== MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.               ==--
--==                                                                    ==--
--== Your rights under this license are terminated immediately if you   ==--
--== breach it in any way.                                              ==--
--==                                                                    ==--
---======================= End Software License =========================---


---====================== Start Copyright Notice ========================---
--==                                                                    ==--
--== Filename ..... socwire_codec.vhd                                   ==--
--== Download ..... http://www.ida.ing.tu-bs.de                         ==--
--== Company ...... IDA TU Braunschweig, Prof. Dr.-Ing. Harald Michalik ==--
--== Authors ...... Björn Osterloh, Karel Kotarowski                    ==--
--== Contact ...... Björn Osterloh (b.osterloh@tu-bs.de)                ==--
--== Copyright .... Copyright (c) 2008 IDA                              ==--
--== Project ...... SoCWire CODEC                                       ==--
--== Version ...... 1.00                                                ==--
--== Conception ... 11 November 2008                                    ==--
--== Modified ..... N/A                                                 ==--
--==                                                                    ==--
---======================= End Copyright Notice =========================---



LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE WORK.ALL;


ENTITY socwire_codec IS
  GENERIC(
	      --== USE GEREIC MAPPING FROM TOPLEVEL!!!             ==--
	      datawidth            : NATURAL RANGE 8 TO 8192:=8;
         speed		            : NATURAL RANGE 1 TO 100:=10;		-- Set CODEC speed to system clock in nanoseconds !
         after64              : NATURAL RANGE 1 TO 6400:=64;   -- Spacewire Standard 6400 = 6.4 us
         after128             : NATURAL RANGE 1 TO 12800:=128; -- Spacewire Standard 12800 = 12.8 us                              
	      disconnect_detection : NATURAL RANGE 1 TO 850:=85     -- Spacewire Standard 850 = 850 ns
         );
  PORT(
       --==  General Interface (Sync Rst, 50MHz Clock) ==--

       rst        : IN  STD_LOGIC;
       clk        : IN  STD_LOGIC;

       --== Link Enable Interface ==--

       socw_en    : IN  STD_LOGIC;
       socw_dis   : IN  STD_LOGIC;

       --== Serial Receive Interface ==--

       rx         : IN  STD_LOGIC_VECTOR(datawidth+1 DOWNTO 0);
       rx_valid   : IN  STD_LOGIC;

       --== Serial Transmit Interface ==--

       tx         : OUT STD_LOGIC_VECTOR(datawidth+1 DOWNTO 0);
       tx_valid	  : OUT STD_LOGIC;       

       --== Data Input Interface ==--

       dat_full   : OUT STD_LOGIC;
       dat_nwrite : IN  STD_LOGIC;
       dat_din    : IN  STD_LOGIC_VECTOR(datawidth DOWNTO 0);

       --== Data Output Interface ==--

       dat_nread  : IN  STD_LOGIC;
       dat_empty  : OUT STD_LOGIC;
       dat_dout   : OUT STD_LOGIC_VECTOR(datawidth DOWNTO 0);

       --== Active Interface ==--

       active     : OUT STD_LOGIC
      );
END socwire_codec;


ARCHITECTURE rtl OF socwire_codec IS

---==========================---
--== Constants Declarations ==--
---==========================---

CONSTANT st_error_reset : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
CONSTANT st_error_wait  : STD_LOGIC_VECTOR(2 DOWNTO 0) := "001";
CONSTANT st_ready       : STD_LOGIC_VECTOR(2 DOWNTO 0) := "010";
CONSTANT st_started     : STD_LOGIC_VECTOR(2 DOWNTO 0) := "011";
CONSTANT st_connecting  : STD_LOGIC_VECTOR(2 DOWNTO 0) := "100";
CONSTANT st_run         : STD_LOGIC_VECTOR(2 DOWNTO 0) := "101";
CONSTANT st_unknown_1   : STD_LOGIC_VECTOR(2 DOWNTO 0) := "110";
CONSTANT st_unknown_2   : STD_LOGIC_VECTOR(2 DOWNTO 0) := "111";

---===================================---
--== Signal Declarations (SM to All) ==--
---===================================---

SIGNAL state : STD_LOGIC_VECTOR(2 DOWNTO 0);

---==================================---
--== Signal Declarations (Rx to SM) ==--
---==================================---

SIGNAL got_null  : STD_LOGIC;
SIGNAL got_fct   : STD_LOGIC;
SIGNAL got_nchar : STD_LOGIC;
SIGNAL err_par   : STD_LOGIC;
SIGNAL err_esc   : STD_LOGIC;
SIGNAL err_dsc   : STD_LOGIC;
SIGNAL err_fct   : STD_LOGIC;
SIGNAL err_nchar : STD_LOGIC;

---=======================================---
--== Signal Declarations (Rx to Rx FIFO) ==--
---=======================================---

SIGNAL dat_full_i   : STD_LOGIC;
SIGNAL dat_nwrite_i : STD_LOGIC;
SIGNAL dat_din_i    : STD_LOGIC_VECTOR(datawidth DOWNTO 0);

---=======================================---
--== Signal Declarations (Rx FIFO to Tx) ==--
---=======================================---

SIGNAL fct_nread_i : STD_LOGIC;
SIGNAL fct_empty_i : STD_LOGIC;

---=======================================---
--== Signal Declarations (Rx to Tx FIFO) ==--
---=======================================---

SIGNAL fct_full_i   : STD_LOGIC;
SIGNAL fct_nwrite_i : STD_LOGIC;

---=======================================---
--== Signal Declarations (Tx FIFO to Tx) ==--
---=======================================---

SIGNAL dat_nread_i : STD_LOGIC;
SIGNAL dat_empty_i : STD_LOGIC;
SIGNAL dat_dout_i  : STD_LOGIC_VECTOR(datawidth DOWNTO 0);

---=============================================---
--== TESTBENCH : Type Declarations : TESTBENCH ==--
---=============================================---

TYPE ss IS
  (
   error_reset,
   error_wait,
   ready,
   started,
   connecting,
   run,
   unknown_1,
   unknown_2,
   baffled
  );

---===============================================---
--== TESTBENCH : Signal Declarations : TESTBENCH ==--
---===============================================---

SIGNAL codec_state : ss;


---=============================================---
--== Component Instantiations for leaf modules ==--
---=============================================---

COMPONENT receiver
  GENERIC(
            datawidth : NATURAL RANGE 8 TO 8192;
            speed	 : NATURAL RANGE 1 TO 100;
			disconnect_detection : NATURAL RANGE 1 TO 850
         );
	PORT( 
       --== General Interface (Sync Rst, 50MHz Clock) ==--

       rst       : IN  STD_LOGIC;
       clk       : IN  STD_LOGIC;

       --== SoCWire Interface ==--

       state     : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);

       --== External Receive Interface ==--

       rx		 : IN  STD_LOGIC_VECTOR(datawidth+1 DOWNTO 0);
       rx_valid	 : IN  STD_LOGIC;

       --== Character Interface ==--

       got_null  : OUT STD_LOGIC;
       got_fct   : OUT STD_LOGIC;
       got_nchar : OUT STD_LOGIC;

       --== Error Interface ==--

       err_par   : OUT STD_LOGIC;
       err_esc   : OUT STD_LOGIC;
       err_dsc   : OUT STD_LOGIC;
       err_fct   : OUT STD_LOGIC;
       err_nchar : OUT STD_LOGIC;

       --== Data Output Interface ==--

       dat_nread : IN  STD_LOGIC;
       dat_empty : OUT STD_LOGIC;
       dat_dout  : OUT STD_LOGIC_VECTOR(datawidth DOWNTO 0);

       --== FCT Output Interface ==--

       fct_nread : IN  STD_LOGIC;
       fct_empty : OUT STD_LOGIC
      );
END COMPONENT;

COMPONENT receive_fifo

  GENERIC(
          datawidth : NATURAL RANGE 8 TO 8192
         );

	PORT(
       --== General Interface (Sync Rst, 50MHz Clock) ==--

       rst        : IN  STD_LOGIC;
       clk        : IN  STD_LOGIC;

       --== SoCWire Interface ==--

       state      : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);

       --== Data Input Interface ==--

       dat_full   : OUT STD_LOGIC;
       dat_nwrite : IN  STD_LOGIC;
       dat_din    : IN  STD_LOGIC_VECTOR(datawidth DOWNTO 0);

       --== Data Output Interface ==--

       dat_nread  : IN  STD_LOGIC;
       dat_empty  : OUT STD_LOGIC;
       dat_dout   : OUT STD_LOGIC_VECTOR(datawidth DOWNTO 0);

       --== FCT Output Interface ==--

       fct_nread  : IN  STD_LOGIC;
       fct_empty  : OUT STD_LOGIC
      );
END COMPONENT receive_fifo;

COMPONENT state_machine
    GENERIC(  
             speed	 : NATURAL RANGE 1 TO 100;
			 after64   : NATURAL RANGE 1 TO 6400;
			 after128  : NATURAL RANGE 1 TO 12800
           );
	PORT(
       --==  General Interface (Sync Rst, 50MHz Clock) ==--

       rst       : IN  STD_LOGIC;
       clk       : IN  STD_LOGIC;

       --== Link Enable Interface ==--

       socw_en    : IN  STD_LOGIC;
       socw_dis   : IN  STD_LOGIC;

       --== SoCWire Interface ==--

       state     : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);

       --== Character Interface ==--

       got_null  : IN  STD_LOGIC;
       got_fct   : IN  STD_LOGIC;
       got_nchar : IN  STD_LOGIC;

       --== Error Interface ==--

       err_par   : IN  STD_LOGIC;
       err_esc   : IN  STD_LOGIC;
       err_dsc   : IN  STD_LOGIC;
       err_fct   : IN  STD_LOGIC;
       err_nchar : IN  STD_LOGIC;

       --== Active Interface ==--

       active    : OUT STD_LOGIC
      );
END COMPONENT state_machine;

COMPONENT transmitter
  GENERIC(
          datawidth : NATURAL RANGE 8 TO 8192
         );
	PORT(

       --== General Interface (Sync Rst, 50MHz Clock) ==--

       rst        : IN  STD_LOGIC;
       clk        : IN  STD_LOGIC;

       --== SoCWire Interface ==--

       state      : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);

       --== External Transmit Interface ==--

       tx		  : OUT STD_LOGIC_VECTOR(datawidth+1 DOWNTO 0);
       tx_valid   : OUT STD_LOGIC;

       --== Data Input Interface ==--

       dat_full   : OUT STD_LOGIC;
       dat_nwrite : IN  STD_LOGIC;
       dat_din    : IN  STD_LOGIC_VECTOR(datawidth DOWNTO 0);

       --== FCT Input Interface ==--

       fct_full   : OUT STD_LOGIC;
       fct_nwrite : IN  STD_LOGIC
      );
END COMPONENT transmitter;

COMPONENT transmit_fifo
  GENERIC(
          datawidth : NATURAL RANGE 8 TO 8192
         );
	PORT(
       --== General Interface (Sync Rst, 50MHz Clock) ==--

       rst        : IN  STD_LOGIC;
       clk        : IN  STD_LOGIC;

       --== SoCWire Interface ==--

       state      : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);

       --== Data Input Interface ==--

       dat_full   : OUT STD_LOGIC;
       dat_nwrite : IN  STD_LOGIC;
       dat_din    : IN  STD_LOGIC_VECTOR(datawidth DOWNTO 0);

       --== Data Output Interface ==--

       dat_nread  : IN  STD_LOGIC;
       dat_empty  : OUT STD_LOGIC;
       dat_dout   : OUT STD_LOGIC_VECTOR(datawidth DOWNTO 0);

       --== FCT Input Interface ==--

       fct_full   : OUT STD_LOGIC;
       fct_nwrite : IN  STD_LOGIC
      );
END COMPONENT transmit_fifo;

BEGIN

  ---===================================================---
  --== TESTBENCH : Show State more clearly : TESTBENCH ==--
  ---===================================================---

  codec_state <= error_reset WHEN (state = st_error_reset) ELSE
                 error_wait  WHEN (state = st_error_wait) ELSE
                 ready       WHEN (state = st_ready) ELSE
                 started     WHEN (state = st_started) ELSE
                 connecting  WHEN (state = st_connecting) ELSE
                 run         WHEN (state = st_run) ELSE
                 unknown_1   WHEN (state = st_unknown_1) ELSE
                 unknown_2   WHEN (state = st_unknown_2) ELSE
                 baffled;


  ---======================---
  --== SoCWire Receiver ==--
  ---======================---

  rx0 : receiver
    GENERIC MAP
	  ( speed => speed,
	    datawidth => datawidth,
		disconnect_detection=>disconnect_detection) 
    PORT MAP
      (--==  General Interface (Sync Rst) ==--
       rst       => rst,
       clk       => clk,
       --== SoCWire Interface ==--
       state     => state,
       --== External Receive Interface ==--
       rx		 => rx,
       rx_valid  => rx_valid,
       --== Character Interface ==--
       got_null  => got_null,
       got_fct   => got_fct,
       got_nchar => got_nchar,
       --== Error Interface ==--
       err_par   => err_par,
       err_esc   => err_esc,
       err_dsc   => err_dsc,
       err_fct   => err_fct,
       err_nchar => err_nchar,
       --== Data Output Interface ==--
       dat_nread => dat_full_i,
       dat_empty => dat_nwrite_i,
       dat_dout  => dat_din_i,
       --== FCT Output Interface ==--
       fct_nread => fct_full_i,
       fct_empty => fct_nwrite_i
      );


  ---================---
  --== Receive FIFO ==--
  ---================---

  rx_fifo : receive_fifo
      GENERIC MAP
	  ( datawidth => datawidth ) 
    PORT MAP
      (--==  General Interface (Sync Rst) ==--
       rst        => rst,
       clk        => clk,
       --== SoCWire Interface ==--
       state      => state,
       --== Data Input Interface ==--
       dat_full   => dat_full_i,
       dat_nwrite => dat_nwrite_i,
       dat_din    => dat_din_i,
       --== Data Output Interface ==--
       dat_nread  => dat_nread,
       dat_empty  => dat_empty,
       dat_dout   => dat_dout,
       --== FCT Output Interface ==--
       fct_nread  => fct_nread_i,
       fct_empty  => fct_empty_i
      );


  ---===========================---
  --== SoCWire State Machine ==--
  ---===========================---

  statem : state_machine
    GENERIC MAP
	  (  speed =>  speed,
		 after64 =>after64,
		 after128=>after128) 
    PORT MAP
      (--==  General Interface (Sync Rst, 50MHz Clock) ==--
       rst       => rst,
       clk       => clk,
       --== Link Enable Interface ==--
       socw_en    => socw_en,
       socw_dis   => socw_dis,
       --== SoCWire Interface ==--
       state     => state,
       --== Character Interface ==--
       got_null  => got_null,
       got_fct   => got_fct,
       got_nchar => got_nchar,
       --== Error Interface ==--
       err_par   => err_par,
       err_esc   => err_esc,
       err_dsc   => err_dsc,
       err_fct   => err_fct,
       err_nchar => err_nchar,
       --== Active Interface ==--
       active    => active
      );


  ---=========================---
  --== SoCWire Transmitter ==--
  ---=========================---

  tx0 : transmitter
    GENERIC MAP
	  ( datawidth =>  datawidth )   
    PORT MAP
      (--== General Interface (Sync Rst, 50MHz Clock) ==--
       rst        => rst,
       clk        => clk,
       --== SoCWire Interface ==--
       state      => state,
       --== External Transmit Interface ==--
       tx		  => tx,
       tx_valid   => tx_valid,
       --== Data Input Interface ==--
       dat_full   => dat_nread_i,
       dat_nwrite => dat_empty_i,
       dat_din    => dat_dout_i,
       --== FCT Input Interface ==--
       fct_full   => fct_nread_i,
       fct_nwrite => fct_empty_i
      );


  ---====================---
  --== Transmitter FIFO ==--
  ---====================---

  tx_fifo : transmit_fifo
    GENERIC MAP
	  ( datawidth =>  datawidth )   
    PORT MAP
      (--== General Interface (Sync Rst, 50MHz Clock) ==--
       rst        => rst,
       clk        => clk,
       --== SoCWire Interface ==--
       state      => state,
       --== Data Input Interface ==--
       dat_full   => dat_full,
       dat_nwrite => dat_nwrite,
       dat_din    => dat_din,
       --== Data Output Interface ==--
       dat_nread  => dat_nread_i,
       dat_empty  => dat_empty_i,
       dat_dout   => dat_dout_i,
       --== FCT Input Interface ==--
       fct_full   => fct_full_i,
       fct_nwrite => fct_nwrite_i
      );
      
END rtl;
