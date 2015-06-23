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
--== Filename ..... cell.vhd                                            ==--
--== Download ..... http://www.ida.ing.tu-bs.de                         ==--
--== Company ...... IDA TU Braunschweig, Prof. Dr.-Ing. Harald Michalik ==--
--== Authors ...... Björn Osterloh, Karel Kotarowski                    ==--
--== Contact ...... Björn Osterloh (b.osterloh@tu-bs.de)                ==--
--== Copyright .... Copyright (c) 2008 IDA                              ==--
--== Project ...... SoCWire Switch                                      ==--
--== Version ...... 1.00                                                ==--
--== Conception ... 11 November 2008                                    ==--
--== Modified ..... N/A                                                 ==--
--==                                                                    ==--
---======================= End Copyright Notice =========================---
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY cell IS
  PORT(
       --==  General Inputs ==--

       clk                 : IN  STD_LOGIC;
       rst                 : IN  STD_LOGIC;

       --== Vertical Connectivity ==--

       op_eop              : IN  STD_LOGIC;
       op_active           : IN  STD_LOGIC;
       op_taken_in         : IN  STD_LOGIC;
       op_taken_out        : OUT STD_LOGIC;

       --== Horizontal Connectivity ==--

       enable              : IN  STD_LOGIC;
       connect             : IN  STD_LOGIC;
       ip_eop              : IN  STD_LOGIC;
       op_wanted           : IN  STD_LOGIC;
       ip_taken_in         : IN  STD_LOGIC;
       ip_taken_out        : OUT STD_LOGIC;
       connected           : OUT STD_LOGIC
      );
END cell;


ARCHITECTURE rtl OF cell IS

---=======================---
--== Signal Declarations ==--
---=======================---

SIGNAL rst_int               : STD_LOGIC;
SIGNAL rst_held              : STD_LOGIC;
SIGNAL connected_int         : STD_LOGIC;
SIGNAL connect_cell          : STD_LOGIC;
SIGNAL connected_i           : STD_LOGIC;

BEGIN

  ---=======================---
  --== Delayed reset logic ==--
  ---=======================---

  PROCESS(clk)
  BEGIN
    IF RISING_EDGE(clk) THEN
      IF (rst = '1') OR (rst_int = '1') THEN
        rst_held <= '0';
      ELSE
        rst_held <= (connected_int AND op_eop) OR rst_held;
      END IF;
    END IF;
  END PROCESS;

  rst_int <= enable AND connected_int AND (op_eop OR rst_held);

   ---==============================---
  --== Determine connection logic ==--
  ---==============================---

  connect_cell <= NOT(ip_taken_in) AND NOT(op_taken_in) AND op_wanted AND
                  op_active AND NOT(rst_int) AND connect;

  ---====================---
  --== Connection logic ==--
  ---====================---

  PROCESS(clk)
  BEGIN
    IF RISING_EDGE(clk) THEN
      IF (rst = '1') OR (rst_int = '1') THEN
        connected_int <= '0';
      ELSIF (enable = '1') THEN
        connected_int <= connect_cell OR connected_int;
      END IF;
    END IF;
  END PROCESS;

  ---===================---
  --== Connected logic ==--
  ---===================---

  PROCESS(clk)
  BEGIN
    IF RISING_EDGE(clk) THEN
      IF (rst = '1') OR (op_eop = '1') THEN
        connected_i <= '0';
      ELSIF (enable = '1') THEN
        connected_i <= connect_cell OR connected_i;
      END IF;
    END IF;
  END PROCESS;

  connected <= connected_i;

  ---=====================---
  --== Input taken logic ==--
  ---=====================---

  PROCESS(clk)
  BEGIN
    IF RISING_EDGE(clk) THEN
      IF (rst = '1') OR (ip_eop = '1') THEN
        ip_taken_out <= '0';
      ELSIF (enable = '1') THEN
        ip_taken_out <= connect_cell OR ip_taken_in;
      END IF;
    END IF;
  END PROCESS;

  ---======================---
  --== Output taken logic ==--
  ---======================---

  PROCESS(clk)
  BEGIN
    IF RISING_EDGE(clk) THEN
      IF (rst = '1') OR (rst_int = '1') THEN
        op_taken_out <= '0';
      ELSIF (enable = '1') THEN
        op_taken_out <= connect_cell OR op_taken_in;
      END IF;
    END IF;
  END PROCESS;

END rtl;
