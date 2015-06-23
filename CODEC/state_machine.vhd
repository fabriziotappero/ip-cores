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
--== Filename ..... state_machine.vhd                                   ==--
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
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE WORK.ALL;


ENTITY state_machine IS
  GENERIC(
             speed : NATURAL RANGE 1 TO 100;
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
END state_machine;


ARCHITECTURE rtl OF state_machine IS

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

---=======================---
--== Signal Declarations ==--
---=======================---

SIGNAL state_i    : STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL state_d    : STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL watchdog_r : STD_LOGIC;
SIGNAL watchdog_d : STD_LOGIC_VECTOR(13 DOWNTO 0);
SIGNAL watchdog   : STD_LOGIC_VECTOR(13 DOWNTO 0);


BEGIN

  ---=====================---
  --== Synchronous Logic ==--
  ---=====================---

  PROCESS (clk)
  BEGIN
  IF RISING_EDGE(clk) THEN
  	IF rst = '0' THEN
  		state_i <= state_d;
  		watchdog <= watchdog_d;
  	ELSE
  		state_i <= (others => '0');
  		watchdog <= (others => '0');
  	END IF;
  END IF;
  END PROCESS;
  
  
  ---===========================---
  --== SoCWire State Machine ==--
  ---===========================---

  PROCESS(state_i, watchdog, got_fct, got_nchar, err_par, err_esc, err_dsc, err_fct, err_nchar, socw_en, got_null, socw_dis)
  BEGIN
    CASE state_i IS

      WHEN st_error_reset =>

        IF (watchdog =  after64 / speed - 1) THEN -- 6.4us Passed
          state_d <= st_error_wait;
          watchdog_r <= '1';
        ELSE
          state_d <= st_error_reset;
          watchdog_r <= '0';
        END IF;

      WHEN st_error_wait =>

        IF (got_fct = '1') OR (got_nchar = '1') OR
           (err_par = '1') OR (err_esc = '1') OR (err_dsc = '1') THEN
          state_d <= st_error_reset;
          watchdog_r <= '1';
        ELSIF (watchdog = after128 / speed - 1) THEN -- 12.8us Passed
          state_d <= st_ready;
          watchdog_r <= '0';
        ELSE
          state_d <= st_error_wait;
          watchdog_r <= '0';
        END IF;

      WHEN st_ready =>

        IF (got_fct = '1') OR (got_nchar = '1') OR 
           (err_par = '1') OR (err_esc = '1') OR (err_dsc = '1') THEN
          state_d <= st_error_reset;
          watchdog_r <= '1';
        ELSIF (socw_en = '1') THEN
          state_d <= st_started;
          watchdog_r <= '1';
        ELSE
          state_d <= st_ready;
          watchdog_r <= '0';
        END IF;

      WHEN st_started =>

        IF (got_nchar = '1') OR
           (err_par = '1') OR (err_esc = '1') OR (err_dsc = '1') THEN
          state_d <= st_error_reset;
          watchdog_r <= '1';
        ELSIF (watchdog = after128 / speed - 1) THEN -- 12.8us Passed
          state_d <= st_error_reset;
          watchdog_r <= '1';
        ELSIF (got_null = '1') THEN
          state_d <= st_connecting;
          watchdog_r <= '1';
        ELSE
          state_d <= st_started;
          watchdog_r <= '0';
        END IF;

      WHEN st_connecting =>

        IF (got_nchar = '1') OR 
           (err_par = '1') OR (err_esc = '1') OR (err_dsc = '1') THEN
          state_d <= st_error_reset;
          watchdog_r <= '1';
        ELSIF (watchdog = after128 / speed - 1) THEN -- 12.8us Passed  
          state_d <= st_error_reset;
          watchdog_r <= '1';
        ELSIF (got_fct = '1') THEN
          state_d <= st_run;
          watchdog_r <= '1';
        ELSE
          state_d <= st_connecting;
          watchdog_r <= '0';
        END IF;

      WHEN st_run =>

        IF (err_fct = '1') OR (err_nchar = '1') OR
           (err_par = '1') OR (err_esc = '1') OR
           (err_dsc = '1') OR (socw_dis = '1') THEN
          state_d <= st_error_reset;
          watchdog_r <= '1';
        ELSE
          state_d <= st_run;
          watchdog_r <= '0';
        END IF;

      WHEN OTHERS =>
        state_d <= st_error_reset;
        watchdog_r <= '1';

    END CASE;

  END PROCESS;


    ---====================---
  --== Watchdog Counter ==--
  ---====================---

  PROCESS(watchdog_r, watchdog, state_i)
  BEGIN
    IF (watchdog_r = '1') OR (state_i = st_run) OR (state_i = st_ready) THEN
      watchdog_d <= (others => '0');
    ELSE
      watchdog_d <= watchdog + 1;
    END IF;
  END PROCESS;


  ---======================================---
  --== Shared Internal & External Signals ==--
  ---======================================---

  state <= state_i;

  active <= '1' WHEN (state_i = st_Run) ELSE '0';

END rtl;
