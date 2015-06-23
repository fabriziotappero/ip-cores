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
--== Filename ..... entrance.vhd                                        ==--
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
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY entrance IS
  GENERIC(
          --== Number Of Ports ==--

          datawidth : NATURAL RANGE 8 TO 8192;
          nports : NATURAL RANGE 2 TO 32
         );
  PORT(
       --==  General Interface ==--

       clk     : IN  STD_LOGIC;
       rst     : IN  STD_LOGIC;

       --== Input Interface ==--

       nwrite  : IN  STD_LOGIC;
       full    : OUT STD_LOGIC;
       din     : IN  STD_LOGIC_VECTOR(datawidth DOWNTO 0);

       --== Connection Interface ==--

       full_in : IN  STD_LOGIC;
       connect : OUT STD_LOGIC;
       wanted  : OUT STD_LOGIC_VECTOR(nports-1 DOWNTO 0)
      );
END entrance;


ARCHITECTURE rtl OF entrance IS

---=========================---
--== Function Declarations ==--
---=========================---

FUNCTION ports2bus(nports : NATURAL RANGE 2 TO 32) RETURN NATURAL IS
BEGIN
  CASE nports IS
    WHEN 2        => RETURN 1;
    WHEN 3  TO  4 => RETURN 2;
    WHEN 5  TO  8 => RETURN 3;
    WHEN 9  TO 16 => RETURN 4;
    WHEN 17 TO 32 => RETURN 5;
  END CASE;
END ports2bus;

---=====================---
--== Type Declarations ==--
---=====================---

TYPE states IS
  (wait4hdr,
   transfer
  );

---=======================---
--== Signal Declarations ==--
---=======================---

SIGNAL state         : states;
SIGNAL ditch_data    : STD_LOGIC;
SIGNAL hw_addr       : STD_LOGIC_VECTOR(nports-1 DOWNTO 0);
SIGNAL wanted_int    : STD_LOGIC_VECTOR(nports-1 DOWNTO 0);
SIGNAL full_i        : STD_LOGIC;

BEGIN

  ---===========================---
  --== Create Hardware Address ==--
  ---===========================---

  G0 : FOR i IN 0 TO nports-1 GENERATE
    hw_addr(i) <= '1' WHEN (din(ports2bus(nports)-1 DOWNTO 0) = i) ELSE '0';
  END GENERATE G0;


  ---================================---
  --== Desired connection selection ==--
  ---================================---

  wanted_int <= hw_addr WHEN (state = wait4hdr) ELSE (others => '0');

  ---============================---
  --== Desired connection logic ==--
  ---============================---

  PROCESS(clk)
  BEGIN
    IF RISING_EDGE(clk) THEN
      IF (rst = '1') THEN
        wanted <= (OTHERS => '0');
      ELSIF (state = wait4hdr) THEN
        wanted <= wanted_int;       
      END IF;
    END IF;
  END PROCESS;

  
  ---=================---
  --== State Machine ==--
  ---=================---

  PROCESS(clk)
  BEGIN
    IF RISING_EDGE(clk) THEN
      IF (rst = '1') THEN
        state <= wait4hdr;
        ditch_data <= '0';
        connect <= '0';
      ELSE
        CASE state IS

          WHEN wait4hdr =>
            IF (nwrite = '0') THEN
                ditch_data <= '1';
                connect <= '1';
                state <= transfer;
            END IF;

          WHEN transfer =>
            ditch_data <= '0';
            IF (nwrite = '0') AND (full_i = '0') AND (din(datawidth) = '1') THEN
              connect <= '0';
              state <= wait4hdr;
            END IF;

        END CASE;
      END IF;
    END IF;
  END PROCESS;

  ---========================---
  --== Drive output signals ==--
  ---========================---

  full_i <= '0' WHEN (ditch_data = '1') OR (full_in = '0') ELSE '1';
  full <= full_i;

END rtl;
