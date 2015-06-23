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
--== Filename ..... matrix.vhd                                          ==--
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

ENTITY matrix IS
  GENERIC(
          --== Number Of Ports ==--

          datawidth : NATURAL RANGE 8 TO 8192;
          nports : NATURAL RANGE 2 TO 32
         );
  PORT(
       --==  General Inputs ==--

       clk       : IN  STD_LOGIC;
       rst       : IN  STD_LOGIC;

       --== Input Interface ==--

       nwrite    : IN  STD_LOGIC_VECTOR(nports-1 DOWNTO 0);
       full      : OUT STD_LOGIC_VECTOR(nports-1 DOWNTO 0);
       din       : IN  STD_LOGIC_VECTOR((datawidth+1)*nports-1 DOWNTO 0);

       --== Output Interface ==--

       empty     : OUT STD_LOGIC_VECTOR(nports-1 DOWNTO 0);
       nread     : IN  STD_LOGIC_VECTOR(nports-1 DOWNTO 0);
       dout      : OUT STD_LOGIC_VECTOR((datawidth+1)*nports-1 DOWNTO 0);

       --== Vertical Inputs ==--

       op_eop    : IN  STD_LOGIC_VECTOR(nports-1 DOWNTO 0);
       op_active : IN  STD_LOGIC_VECTOR(nports-1 DOWNTO 0);
       op_wanted : IN  STD_LOGIC_VECTOR(nports*nports-1 DOWNTO 0);

       --== Horizontal Inputs ==--

       ip_eop    : IN  STD_LOGIC_VECTOR(nports-1 DOWNTO 0);
       connect   : IN  STD_LOGIC_VECTOR(nports-1 DOWNTO 0)
      );
END matrix;

ARCHITECTURE rtl OF matrix IS

---=========================---
--== Constant Declarations ==--
---=========================---

CONSTANT all_ones  : STD_LOGIC_VECTOR(nports-1 DOWNTO 0) := (OTHERS => '1');
CONSTANT all_zeros : STD_LOGIC_VECTOR(nports-1 DOWNTO 0) := (OTHERS => '0');

---==========================---
--== Component Declarations ==--
---==========================---

COMPONENT cell
  PORT(--==  General Inputs ==--
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
END COMPONENT;


---=======================---
--== Signal Declarations ==--
---=======================---

TYPE MULTIPLEX IS ARRAY(0 TO datawidth+1) OF STD_LOGIC_VECTOR(nports*nports-1 DOWNTO 0);

SIGNAL enable          : STD_LOGIC_VECTOR(nports-1 DOWNTO 0);
SIGNAL op_taken        : STD_LOGIC_VECTOR(nports*nports-1 DOWNTO 0);
SIGNAL ip_taken        : STD_LOGIC_VECTOR(nports*nports-1 DOWNTO 0);
SIGNAL connected       : STD_LOGIC_VECTOR(nports*nports-1 DOWNTO 0);
SIGNAL full_mux        : STD_LOGIC_VECTOR(nports*nports-1 DOWNTO 0);
SIGNAL empty_mux       : STD_LOGIC_VECTOR(nports*nports-1 DOWNTO 0);
SIGNAL dout_mux        : MULTIPLEX;


BEGIN

  ---===========================================---
  --== Data multiplexing and handshake routing ==--
  ---===========================================---

  GH : FOR h IN 0 TO nports-1 GENERATE
    GV : FOR v IN 0 TO nports-1 GENERATE
      full_mux(nports*h + v) <= nread(v) WHEN connected(nports*h + v) = '1' ELSE '1';
      empty_mux(nports*h + v) <= nwrite(v) WHEN connected(nports*v + h) = '1' ELSE '1';
      GI : FOR i IN 0 TO (datawidth) GENERATE
        dout_mux(i)(nports*h + v) <= din((datawidth+1)*v + i) WHEN connected(nports*v + h) = '1' ELSE '0';
      END GENERATE GI;

    END GENERATE GV;
    full(h) <= '1' WHEN (full_mux(nports*(h+1)-1 DOWNTO nports*h)) = all_ones ELSE '0';
    empty(h) <= '1' WHEN (empty_mux(nports*(h+1)-1 DOWNTO nports*h)) = all_ones ELSE '0';
    GJ : FOR j IN 0 TO (datawidth) GENERATE    
    dout((datawidth+1)*h + j) <= '0' WHEN (dout_mux(j)(nports*(h+1)-1 DOWNTO nports*h)) = all_zeros ELSE '1';
    END GENERATE GJ;
  END GENERATE GH;


  ---=========================================---
  --== Connection cell pipeline enable logic ==--
  ---=========================================---

  PROCESS(clk)
  BEGIN
    IF RISING_EDGE(clk) THEN
      IF (rst = '1') THEN
        enable(nports-2 DOWNTO 0) <= (OTHERS => '0');
        enable(nports-1) <= '1';
      ELSE
        enable <= enable(nports-2 DOWNTO 0) & enable(nports-1);
      END IF;
    END IF;
  END PROCESS;

  ---===================---
  --== Connection Cell ==--
  ---===================---

  G0 : FOR h IN 0 TO nports-1 GENERATE
    G1 : FOR v IN 0 TO nports-1 GENERATE
      U0 : cell
        PORT MAP
          (--==  General Inputs ==--
           clk                 => clk,
           rst                 => rst,
           --== Vertical Connectivity ==--
           op_eop              => op_eop(h),
           op_active           => op_active(h),
           op_taken_in         => op_taken(h*nports + (v+nports-1) MOD nports),
           op_taken_out        => op_taken(h*nports + v),
           --== Horizontal Connectivity ==--
           enable              => enable((v + h) MOD nports),
           connect             => connect(v),
           ip_eop              => ip_eop(v),
           op_wanted           => op_wanted(v*nports + h),
           ip_taken_in         => ip_taken(v*nports + (h+nports-1) MOD nports),
           ip_taken_out        => ip_taken(v*nports + h),
           connected           => connected(v*nports + h)
          );
    END GENERATE G1;
  END GENERATE G0;
  

END rtl;
