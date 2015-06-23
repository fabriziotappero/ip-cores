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
--== Filename ..... switch.vhd                                          ==--
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

ENTITY switch IS
  GENERIC(
          --== Number Of Ports ==--

          datawidth : NATURAL RANGE 8 TO 8192;
          nports   : NATURAL RANGE 2 TO 32
         );
  PORT(
       --==  General Interface (Sync Rst) ==--

       clk    : IN  STD_LOGIC;
       rst    : IN  STD_LOGIC;

       --== Input Interface ==--

       nwrite : IN  STD_LOGIC_VECTOR(nports-1 DOWNTO 0);
       full   : OUT STD_LOGIC_VECTOR(nports-1 DOWNTO 0);
       din    : IN  STD_LOGIC_VECTOR((datawidth+1)*nports-1 DOWNTO 0);

       --== Output Interface ==--

       empty  : OUT STD_LOGIC_VECTOR(nports-1 DOWNTO 0);
       nread  : IN  STD_LOGIC_VECTOR(nports-1 DOWNTO 0);
       dout   : OUT STD_LOGIC_VECTOR((datawidth+1)*nports-1 DOWNTO 0);

       --== Activity Interface ==--

       active : IN  STD_LOGIC_VECTOR(nports-1 DOWNTO 0)
      );
END switch;


ARCHITECTURE rtl OF switch IS

---==========================---
--== Component Declarations ==--
---==========================---

COMPONENT entrance
  GENERIC(--== Number Of Ports ==--
          datawidth : NATURAL RANGE 8 TO 8192;
          nports : NATURAL RANGE 2 TO 32
         );
  PORT(--==  General Interface ==--
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
END COMPONENT;

COMPONENT matrix
  GENERIC(--== Number Of Ports ==--
          datawidth : NATURAL RANGE 8 TO 8192;
          nports : NATURAL RANGE 2 TO 32
         );
  PORT(--==  General Inputs ==--
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
END COMPONENT;

     
---=======================---
--== Signal Declarations ==--
---=======================---

SIGNAL connect  : STD_LOGIC_VECTOR(nports-1 DOWNTO 0);
SIGNAL wanted   : STD_LOGIC_VECTOR(nports*nports-1 DOWNTO 0);
SIGNAL op_eop   : STD_LOGIC_VECTOR(nports-1 DOWNTO 0);
SIGNAL ip_eop   : STD_LOGIC_VECTOR(nports-1 DOWNTO 0);
SIGNAL full_ii  : STD_LOGIC_VECTOR(nports-1 DOWNTO 0);
SIGNAL din_i    : STD_LOGIC_VECTOR((datawidth+1)*nports-1 DOWNTO 0);
SIGNAL full_i   : STD_LOGIC_VECTOR(nports-1 DOWNTO 0);
SIGNAL nwrite_i : STD_LOGIC_VECTOR(nports-1 DOWNTO 0);
SIGNAL empty_i  : STD_LOGIC_VECTOR(nports-1 DOWNTO 0);
SIGNAL nread_i  : STD_LOGIC_VECTOR(nports-1 DOWNTO 0);
SIGNAL dout_i   : STD_LOGIC_VECTOR((datawidth+1)*nports-1 DOWNTO 0);
SIGNAL active_i : STD_LOGIC_VECTOR(nports-1 DOWNTO 0);

BEGIN

  ---================================---
  --== Create port active signals.   ==--
  ---================================---

  active_i <= active(nports-1 DOWNTO 0);

  ---===============================================================---
  --== Detect EOP's & EEP's has they enter and leave switch matrix ==--
  ---===============================================================---

  G0 : FOR i IN 0 TO nports-1 GENERATE
    ip_eop(i) <= NOT(nwrite_i(i)) AND NOT(full_ii(i)) AND din_i((datawidth+1)*(i+1)-1);
    op_eop(i) <= NOT(empty_i(i)) AND NOT(nread_i(i)) AND dout_i((datawidth+1)*(i+1)-1);
  END GENERATE G0;

 
  ---================================================---
  --== Switch Matrix entrance & Hardware Addressing ==--
  ---================================================---

  G1 : FOR i IN 0 TO nports-1 GENERATE
    entr0 : entrance
      GENERIC MAP
        (--== Number Of Ports ==--
         datawidth => datawidth,
         nports => nports
        )
      PORT MAP
        (--==  General Interface ==--
         clk     => clk,
         rst     => rst,
         --== Input Interface ==--
         nwrite  => nwrite_i(i),
         full    => full_i(i),
         din     => din_i((datawidth+1)*(i+1)-1 DOWNTO (datawidth+1)*i),
         --== Connection Interface ==--
         full_in => full_ii(i),
         connect => connect(i),
         wanted  => wanted(nports*(i+1)-1 DOWNTO nports*i)
        );
  END GENERATE G1;

  ---=================---
  --== Switch Matrix ==--
  ---=================---

  matrix0 : matrix
    GENERIC MAP
      (--== Number Of Ports ==--
       datawidth => datawidth,
       nports => nports
      )
    PORT MAP
      (--==  General Inputs ==--
       clk       => clk,
       rst       => rst,
       --== Input Interface ==--
       nwrite    => nwrite_i,
       full      => full_ii,
       din       => din_i,
       --== Output Interface ==--
       empty     => empty_i,
       nread     => nread_i,
       dout      => dout_i,
       --== Vertical Inputs ==--
       op_eop    => op_eop,
       op_active => active_i,
       op_wanted => wanted,
       --== Horizontal Inputs ==--
       ip_eop    => ip_eop,
       connect   => connect
      );


    din_i((datawidth+1)*nports-1 DOWNTO 0) <= din;
    full <= full_i;
    nwrite_i(nports-1 DOWNTO 0) <= nwrite;
    empty <= empty_i(nports-1 DOWNTO 0);
    nread_i(nports-1 DOWNTO 0) <= nread;
    dout <= dout_i((datawidth+1)*nports-1 DOWNTO 0);


END rtl;
