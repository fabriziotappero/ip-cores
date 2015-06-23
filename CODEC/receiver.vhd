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
--== Filename ..... receiver.vhd                                        ==--
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


ENTITY receiver IS
  GENERIC(

  		  datawidth : NATURAL RANGE 8 TO 8192;
          speed : NATURAL RANGE 1 TO 100;
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
END receiver;


ARCHITECTURE rtl OF receiver IS

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
CONSTANT zeros			: STD_LOGIC_VECTOR(datawidth+1 downto 9) := (others => '0');


---=======================---
--== Signal Declarations ==--
---=======================---

SIGNAL rx_rst         : STD_LOGIC;
SIGNAL dsc_count_d    : STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL dsc_count      : STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL bit_array      : STD_LOGIC_VECTOR(datawidth+1 DOWNTO 0);
SIGNAL got_char  	  : STD_LOGIC;
SIGNAL got_null_d     : STD_LOGIC;
SIGNAL got_fct_d      : STD_LOGIC;
SIGNAL got_eop_d      : STD_LOGIC;
SIGNAL got_esc_d      : STD_LOGIC;
SIGNAL got_data_d     : STD_LOGIC;
SIGNAL got_nchar_d    : STD_LOGIC;
SIGNAL err_par_d      : STD_LOGIC;
SIGNAL err_esc_d      : STD_LOGIC;
SIGNAL par_ok	      : STD_LOGIC;
SIGNAL got_null_i     : STD_LOGIC;
SIGNAL got_esc_dd     : STD_LOGIC;
SIGNAL got_esc        : STD_LOGIC;
SIGNAL dat_empty_d    : STD_LOGIC;
SIGNAL dat_empty_i    : STD_LOGIC;
SIGNAL fct_empty_d    : STD_LOGIC;
SIGNAL fct_empty_i    : STD_LOGIC;
SIGNAL err_dsc_d      : STD_LOGIC;
SIGNAL dat_dout_d     : STD_LOGIC_VECTOR(datawidth DOWNTO 0);
SIGNAL x			  : STD_LOGIC;



BEGIN

  ---======================================================---
  --== Generate Tx Reset Signal to hold Receiver in Reset ==--
  ---======================================================---

  rx_rst <= '1' WHEN (rst = '1') OR (state = st_error_reset) ELSE '0';
 

  ---=====================---
  --== Synchronous Logic ==--
  ---=====================---

  PROCESS (clk)
  VARIABLE par_temp : STD_LOGIC;
  BEGIN
  IF RISING_EDGE(clk) THEN
  	IF rx_rst = '0' THEN
  	    par_temp := '0';
        FOR i IN 2 TO datawidth+1 LOOP
          par_temp := par_temp XOR bit_array(i);
        END LOOP;  	    
  	    par_ok <= rx(0) XOR rx(1) XOR par_temp;
  		err_dsc <= err_dsc_d;
  	  	dsc_count <= dsc_count_d;
  	  	bit_array <= rx;
  	  	dat_dout <= dat_dout_d;
  	  	dat_empty_i <= dat_empty_d;  	  	
  	  	fct_empty_i <= fct_empty_d;  	
  	  	got_esc <= got_esc_dd;
  	  	err_par <= err_par_d;
  	  	err_esc <= err_esc_d;
  	  	got_fct <= got_fct_d;
  	  	got_nchar <= got_nchar_d;  	
  	ELSE
  		par_ok <= '0';
  		par_temp := '0';
  		err_dsc <= '0';
  		dsc_count <= (others => '0');
  		bit_array <= zeros & "000000001";
  		dat_dout <= (others => '0');
  		fct_empty_i <= '1'; 
 		dat_empty_i <= '1';  
 		got_esc <= '0';
  		err_par <= '0';
  		err_esc <= '0';
  		got_fct <= '0';
  		got_nchar <= '0';	
  	END IF;
  END IF;	
  END PROCESS;  
  
  
  ---===========================---
  --== Rx Disconnect Detection ==--
  ---===========================---

  
  err_dsc_d <= '1' WHEN (dsc_count = disconnect_detection / speed) ELSE '0';
  
  PROCESS(rx_valid, dsc_count)
  BEGIN
    IF (rx_valid = '1') THEN
      dsc_count_d <= "0000000001";
    ELSIF (dsc_count /= "0000000000") THEN
      dsc_count_d <= dsc_count + 1;
    ELSE
      dsc_count_d <= dsc_count; -- could be all 0's, if so add it to reset!!
    END IF;
  END PROCESS;

  
  ---===============================---
  --== Rx Character Identification ==--
  ---===============================---

  got_char <= '1' WHEN (rx_valid = '1') AND (rx /= zeros & "000101110")
                        AND (got_null_i = '1') ELSE '0';

  got_null_d <= '1' WHEN (rx_valid = '1') AND (rx(9 downto 1) = "000010111") AND (rx(datawidth+1 downto 9) = zeros) 
                          AND (par_ok = '1') ELSE '0';

  got_fct_d <= '1' WHEN (got_char = '1') AND
                        (got_esc = '0') AND
                        (rx(9 downto 1) = "000000001") AND (rx(datawidth+1 downto 9) = zeros)
                         AND (par_ok = '1') ELSE '0';

  got_eop_d <= '1' WHEN (got_char = '1') AND (rx(datawidth+1 downto 9) = zeros) AND
                        (got_esc = '0') AND
                        ((rx(9 downto 1) = "000000011") OR
                         (rx(9 downto 1) = "000000101")) AND
                        (par_ok = '1') ELSE '0';

  got_esc_d <= '1' WHEN (got_char = '1') AND (rx(datawidth+1 downto 9) = zeros) AND
                        (rx(9 downto 1) = "000000111") AND 
                        (par_ok = '1') ELSE '0';

  got_data_d <= '1' WHEN (got_char = '1') AND        
                         (rx(1) = '0') AND
  						 (got_esc = '0') AND
                         (par_ok = '1') ELSE '0';

  err_esc_d <= got_esc AND got_char AND ((rx(3) OR rx(2)) AND rx(1));

  err_par_d <= NOT par_ok AND rx_valid;

  got_nchar_d <= got_eop_d OR got_data_d;
  
  got_nchar_d <= got_eop_d OR got_data_d;
  
  x <= got_null_d NOR got_null_i;
  got_null_i <= rx_rst NOR x;
  
  PROCESS(rx_valid, got_esc_d, got_char, got_esc)
  BEGIN
    IF (rx_valid = '1') AND (got_esc_d = '1') THEN
      got_esc_dd <= '1';
    ELSIF (got_char = '1')  THEN
      got_esc_dd <= '0';
    ELSE
      got_esc_dd <= got_esc;
    END IF;
  END PROCESS;

  fct_empty_d <= NOT(got_fct_d);
  dat_empty_d <= NOT(got_nchar_d);

                
  PROCESS(rx, got_eop_d)
   BEGIN
    IF(got_eop_d = '1') THEN
      dat_dout_d(datawidth) <= '1';
      dat_dout_d(datawidth-1 downto 1) <= (others => '0');
      dat_dout_d(0) <= rx(2);
    ELSE
      dat_dout_d(datawidth) <= '0';
      FOR i IN 0 TO datawidth-1 LOOP
       dat_dout_d(i) <= rx(i+2);
    END LOOP;
  END IF;
  END PROCESS;


  ---===============================================---
  --== Generate error for too much data comming in ==--
  ---===============================================---

  err_nchar <= NOT(dat_empty_i) AND dat_nread;


  ---================================================---
  --== Generate error for too many FCT's comming in ==--
  ---================================================---

  err_fct <= NOT(fct_empty_i) AND fct_nread;


  ---======================================---
  --== Shared Internal & External Signals ==--
  ---======================================---

  got_null  <= got_null_i;
  dat_empty <= dat_empty_i;
  fct_empty <= fct_empty_i;

END rtl;
