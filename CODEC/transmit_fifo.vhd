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
--== Filename ..... transmit_fifo.vhd                                   ==--
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


ENTITY transmit_fifo IS
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
END transmit_fifo;



ARCHITECTURE rtl OF transmit_fifo IS

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

SIGNAL rst_fct     : STD_LOGIC;
SIGNAL fct_full_d  : STD_LOGIC;
SIGNAL fct_full_i  : STD_LOGIC;
SIGNAL fct_en      : STD_LOGIC;
SIGNAL dat_en      : STD_LOGIC;
SIGNAL dat2_en     : STD_LOGIC;
SIGNAL credit      : STD_LOGIC_VECTOR(5 DOWNTO 0) := (OTHERS => '0');
SIGNAL credit_d    : STD_LOGIC_VECTOR(5 DOWNTO 0);
SIGNAL credit_e    : STD_LOGIC;
SIGNAL dat_full_d  : STD_LOGIC;
SIGNAL dat_full_i  : STD_LOGIC;
SIGNAL dat_empty_d : STD_LOGIC;
SIGNAL dat_empty_i : STD_LOGIC;
SIGNAL store_e     : STD_LOGIC;
SIGNAL store       : STD_LOGIC_VECTOR(datawidth DOWNTO 0);
SIGNAL got_eop     : STD_LOGIC;
SIGNAL swallow_d   : STD_LOGIC;
SIGNAL swallow     : STD_LOGIC;
SIGNAL dat_dout_e  : STD_LOGIC;
SIGNAL dat_dout_d  : STD_LOGIC_VECTOR(datawidth DOWNTO 0);


BEGIN

  ---============================================---
  --== Reset for non-Connecting & non-Run logic ==--
  ---============================================---

  rst_fct <= '1' WHEN (rst = '1') OR NOT((state = st_connecting) OR (state = st_run)) ELSE '0';

  
  ---=====================---
  --== Synchronous Logic ==--
  ---=====================---

  PROCESS (clk)
  BEGIN
  IF RISING_EDGE(clk) THEN
  	IF rst_fct = '0' THEN
  	  	fct_full_i <= fct_full_d;
  	  	IF credit_e = '1' THEN
  	  		credit <= credit_d;
  	  	END IF;
  	ELSE 
  		credit <= (others => '0');
  		fct_full_i <= '1';
  	END IF;
  	
  	IF rst = '0' THEN
  		swallow <= swallow_d;
  		dat_full_i <= dat_full_d;
  		dat_empty_i <= dat_empty_d;
  		IF dat2_en = '1' THEN
  	  		got_eop <= dat_din(datawidth);
  	  	END IF; 
  	  	IF store_e = '1' THEN
  	  		store <= dat_din;
  	  	END IF; 
  	  	IF dat_dout_e = '1' THEN
  	  		dat_dout <= dat_dout_d;
  	  	END IF;   	  	
  	ELSE
  		got_eop <= '1';
  		swallow <= '1';
  		dat_full_i <= '1';
  		dat_empty_i <= '1';
  		store <= (others => '0');
  		dat_dout <= (others => '0');
  	END IF;
  END IF;
  END PROCESS;
    

  ---====================---
  --== FCT Write Enable ==--
  ---====================---

  fct_en <= NOT(fct_full_i) AND NOT(fct_nwrite);


  ---========================---
  --== Data Out Read Enable ==--
  ---========================---

  dat_en <= NOT(dat_empty_i) AND NOT(dat_nread);


  ---========================---
  --== Data In Write Enable ==--
  ---========================---

  dat2_en <= NOT(dat_full_i) AND NOT(dat_nwrite);


  ---===========================---
  --== Transmit Credit Counter ==--
  ---===========================---

  PROCESS(fct_en, dat_en, credit)
  VARIABLE tmp : STD_LOGIC_VECTOR(1 DOWNTO 0);
  BEGIN
    tmp := fct_en & dat_en;
    CASE tmp IS
      WHEN "11"   => credit_d <= credit + 7;
      WHEN "10"   => credit_d <= credit + 8;
      WHEN "01"   => credit_d <= credit - 1;
      WHEN OTHERS => credit_d <= credit;
    END CASE;
  END PROCESS;

  credit_e <= fct_en OR dat_en;

  
    ---=======================---
  --== FCT Handshake Logic ==--
  ---=======================---

  PROCESS(credit, fct_en)
  BEGIN
    IF (credit <= '1' & NOT(fct_en) & fct_en & "000") THEN
      fct_full_d <= '0';
    ELSE
      fct_full_d <= '1';
    END IF;
  END PROCESS;


  ---========================---
  --== Packet swallow logic ==--
  ---========================---

  PROCESS(state, swallow, dat_full_i, dat_nwrite, dat_din, got_eop)
  BEGIN
    IF (state /= st_Run) THEN
      swallow_d <= '1';
    ELSE
      IF (swallow = '1') THEN
        IF ((dat_full_i = '0') AND (dat_nwrite = '0') AND (dat_din(datawidth) = '1')) OR (got_eop = '1') THEN
          swallow_d <= '0';
        ELSE
          swallow_d <= '1';
        END IF;
      ELSE
        swallow_d <= '0';
      END IF;
    END IF;
  END PROCESS;


  ---========================---
  --== FIFO full flag logic ==--
  ---========================---

  PROCESS(state, swallow, got_eop, dat_full_i, dat_nwrite, dat_din, credit, dat_en, dat_empty_i, dat_nread)
  BEGIN
    IF (state /= st_Run) THEN
      dat_full_d <= '0';
    ELSE
      IF (swallow = '1') THEN
        IF (got_eop = '1') AND (dat_full_i = '0') AND (dat_nwrite = '0') AND (dat_din(datawidth) = '0') THEN
          dat_full_d <= '1';
        ELSE
          dat_full_d <= '0';
        END IF;
      ELSE
        IF (credit(5 DOWNTO 1) = "000000") AND ((credit(0) = '0') OR (dat_en = '1')) THEN
          dat_full_d <= dat_full_i OR NOT(dat_nwrite);
        ELSE
          dat_full_d <= NOT(dat_empty_i) AND dat_nread AND (dat_full_i OR NOT(dat_nwrite));
        END IF;
      END IF;
    END IF;
  END PROCESS;


  ---=========================---
  --== FIFO empty flag logic ==--
  ---=========================---

  PROCESS(state, swallow, credit, dat_en, dat_full_i, dat_nwrite, dat_empty_i, dat_nread)
  BEGIN
    IF (state /= st_Run) OR (swallow = '1') THEN
      dat_empty_d <= '1';
    ELSE
      IF (credit(5 DOWNTO 1) = "000000") AND ((credit(0) = '0') OR (dat_en = '1')) THEN
        dat_empty_d <= '1';
      ELSE
        dat_empty_d <= NOT(dat_full_i) AND dat_nwrite AND (dat_empty_i OR NOT(dat_nread));
      END IF;
    END IF;
  END PROCESS;


  ---===============---
  --== FIFO memory ==--
  ---===============---

  store_e <= NOT(dat_full_i);


  ---=======================---
  --== FIFO data out logic ==--
  ---=======================---

  PROCESS(dat_full_i, dat_din, store)
  BEGIN
    CASE dat_full_i IS
      WHEN '0' => dat_dout_d <= dat_din;
      WHEN '1' => dat_dout_d <= store;
      WHEN OTHERS => NULL;
    END CASE;
  END PROCESS;

  dat_dout_e <= '1' WHEN (dat_empty_i = '1') OR (dat_nread = '0') ELSE '0';

  ---======================================---
  --== Shared Internal & External Signals ==--
  ---======================================---

  dat_full <= dat_full_i;
  fct_full <= fct_full_i;
  dat_empty <= dat_empty_i;

END rtl;
