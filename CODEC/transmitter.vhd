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
--== Filename ..... transmitter.vhd                                     ==--
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


ENTITY transmitter IS
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
       tx_valid	  : OUT STD_LOGIC;

       --== Data Input Interface ==--

       dat_full   : OUT STD_LOGIC;
       dat_nwrite : IN  STD_LOGIC;
       dat_din    : IN  STD_LOGIC_VECTOR(datawidth DOWNTO 0);

       --== FCT Input Interface ==--

       fct_full   : OUT STD_LOGIC;
       fct_nwrite : IN  STD_LOGIC
      );
END transmitter;


ARCHITECTURE rtl OF transmitter IS

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
CONSTANT zeros			: STD_LOGIC_VECTOR(datawidth DOWNTO 5) := (others => '0');

---=======================---
--== Signal Declarations ==--
---=======================---

SIGNAL tx_rst       : STD_LOGIC;
SIGNAL clk_en       : STD_LOGIC;
SIGNAL load_d       : STD_LOGIC;
SIGNAL load         : STD_LOGIC;
SIGNAL bit_array_d  : STD_LOGIC_VECTOR(datawidth DOWNTO 0);
SIGNAL bit_array    : STD_LOGIC_VECTOR(datawidth DOWNTO 0);
SIGNAL parity_d     : STD_LOGIC;
SIGNAL parity       : STD_LOGIC;
SIGNAL fct_en       : STD_LOGIC;
SIGNAL dat_en       : STD_LOGIC;
SIGNAL fct_full_i   : STD_LOGIC;
SIGNAL dat_full_i   : STD_LOGIC;



BEGIN


  ---=========================================================---
  --== Generate Tx Reset Signal to hold Transmitter in Reset ==--
  ---=========================================================---

  tx_rst <= '1' WHEN ((state /= st_Started) AND (state /= st_connecting) AND
                      (state /= st_run)) OR (rst = '1') ELSE '0';


                      
  ---=====================---
  --== Synchronous Logic ==--
  ---=====================---

  PROCESS (clk)
  BEGIN
  IF RISING_EDGE(clk) THEN
  	IF tx_rst = '0' THEN
  	  	clk_en <= NOT clk_en;
  	  	load <= load_d;
  	  	IF load = '1' THEN
  	  		parity <= parity_d;
  	  		bit_array <= bit_array_d;
  	  	END IF;
  	ELSE 
  		clk_en <= '0';
  		load <= '0';
  		parity <= '1';
  		bit_array <= (others => '0');
  	END IF;
  END IF;
  END PROCESS;
  

  ---===========================================================---
  --== Generate pulse for cycle where shift register is loaded ==--
  ---===========================================================---

  load_d <= NOT tx_rst;

  ---===========================================================---
  --== FCT & NChar Input Interfaces (pre-sniff then handshake) ==--
  ---===========================================================---

  PROCESS(load_d, state, fct_nwrite, dat_nwrite)
  BEGIN
    IF (load_d = '1') THEN   
      IF ((state = st_connecting) OR (state = st_run)) AND (fct_nwrite = '0') THEN
        fct_full_i <= '0';
        dat_full_i <= '1';
      ELSIF (state = st_run) AND (dat_nwrite = '0') THEN
        fct_full_i <= '1';
        dat_full_i <= '0';
      ELSE
        fct_full_i <= '1';
        dat_full_i <= '1';
      END IF;
    ELSE
      fct_full_i <= '1';
      dat_full_i <= '1';
    END IF;
  END PROCESS;

  fct_en <= NOT(fct_full_i) AND NOT(fct_nwrite);
  dat_en <= NOT(dat_full_i) AND NOT(dat_nwrite);


  ---==================================---
  --== Character Priority Multiplexor ==--
  ---==================================---

  PROCESS(load, bit_array, fct_en, dat_en, parity, dat_din)
  BEGIN
    IF (load = '1') THEN
     IF (fct_en = '1') THEN
        bit_array_d <= zeros & "00001";
      ELSIF (dat_en = '1') THEN
        IF (dat_din(datawidth) = '1') THEN
          bit_array_d <= zeros & "00" & NOT(dat_din(0)) & dat_din(0) & '1';
        ELSE
          bit_array_d <= dat_din(datawidth-1 DOWNTO 0) & '0';
        END IF;
      ELSE
         bit_array_d <= zeros & "10111";
      END IF;
    ELSE
      bit_array_d <= (others => '0');
    END IF;
  END PROCESS;
    
  
  PROCESS(bit_array_d, bit_array)
  VARIABLE temp : STD_LOGIC;
  BEGIN
    temp := '0' XOR bit_array_d(0);
    FOR i IN 1 TO datawidth LOOP
     temp := temp XOR bit_array(i);
    END LOOP;  
    parity_d <= NOT temp; 
  END PROCESS;

  
  ---===================================---
  --== Drive Tx Data Output (NONE-TMR) ==--
  ---===================================---

  tx <= bit_array & parity;
  tx_valid <= load;

  ---======================================---
  --== Shared Internal & External Signals ==--
  ---======================================---

  fct_full <= fct_full_i;
  dat_full <= dat_full_i;

END rtl;
