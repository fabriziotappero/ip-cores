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
--== Filename ..... socwire_switch.vhd                                  ==--
--== Download ..... http://www.ida.ing.tu-bs.de                         ==--
--== Company ...... IDA TU Braunschweig, Prof. Dr.-Ing. Harald Michalik ==--
--== Authors .......Björn Osterloh, Karel Kotarowski                    ==--
--== Contact .......Björn Osterloh (b.osterloh@tu-bs.de)                ==--
--== Copyright .... Copyright (c) 2008 IDA                              ==--
--== Project ...... SoCWire Switch                                      ==--
--== Version ...... 1.00                                                ==--
--== Conception ... 11 November 2008                                    ==--
--== Modified ..... N/A                                                 ==--
--==                                                                    ==--
---======================= End Copyright Notice =========================---


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE WORK.ALL;


ENTITY SoCWire_switch IS
  GENERIC(
          datawidth            : NATURAL RANGE 8 TO 8192:=16;
          nports               : NATURAL RANGE 2 TO 32:=32;
          speed	             : NATURAL RANGE 1 TO 100:=10;
	       after64              : NATURAL RANGE 1 TO 6400:=6400;   -- Spacewire Standard 6400 = 6.4 us
          after128             : NATURAL RANGE 1 TO 12800:=12800; -- Spacewire Standard 12800 = 12.8 us
          disconnect_detection : NATURAL RANGE 1 TO 850:=850     -- Spacewire Standard 850 = 850 ns
         );
  PORT(
       --==  General Interface (Sync Rst, 50MHz Clock) ==--

       rst        : IN  STD_LOGIC;
       clk        : IN  STD_LOGIC;

       --== Serial Receive Interface ==--

       rx         : IN  STD_LOGIC_VECTOR((datawidth+2)*nports-1 DOWNTO 0);
       rx_valid   : IN  STD_LOGIC_VECTOR(nports-1 DOWNTO 0);

       --== Serial Transmit Interface ==--

       tx         : OUT STD_LOGIC_VECTOR((datawidth+2)*nports-1 DOWNTO 0);
       tx_valid   : OUT STD_LOGIC_VECTOR(nports-1 DOWNTO 0);

       --== Active Interface ==--

       active     : OUT STD_LOGIC_VECTOR(nports-1 DOWNTO 0)
      );
END SoCWire_switch;


ARCHITECTURE rtl OF SoCWire_switch IS

---=====================================---
--== Signal Declarations (Link Enable) ==--
---=====================================---

SIGNAL socw_en  : STD_LOGIC;
SIGNAL socw_dis : STD_LOGIC;

---================================---
--== Signal Declarations (Active) ==--
---================================---

SIGNAL active_i : STD_LOGIC_VECTOR(nports-1 DOWNTO 0);

---=====================================================---
--== Signal Declarations (Data : CODEC to Switch Core) ==--
---=====================================================---

SIGNAL dat_full   : STD_LOGIC_VECTOR(nports-1 DOWNTO 0);
SIGNAL dat_nwrite : STD_LOGIC_VECTOR(nports-1 DOWNTO 0);
SIGNAL dat_din    : STD_LOGIC_VECTOR((datawidth+1)*nports-1 DOWNTO 0);

---=====================================================---
--== Signal Declarations (Data : Switch Core to CODEC) ==--
---=====================================================---

SIGNAL dat_nread : STD_LOGIC_VECTOR(nports-1 DOWNTO 0);
SIGNAL dat_empty : STD_LOGIC_VECTOR(nports-1 DOWNTO 0);
SIGNAL dat_dout  : STD_LOGIC_VECTOR((datawidth+1)*nports-1 DOWNTO 0);


---=============================================---
--== Component Instantiations for leaf modules ==--
---=============================================---

COMPONENT socwire_codec
  GENERIC(
          datawidth             : NATURAL RANGE 8 TO 8192;
          speed                : NATURAL RANGE 1 TO 100;
	       after64              : NATURAL RANGE 1 TO 6400;    
	       after128             : NATURAL RANGE 1 TO 12800;   
          disconnect_detection : NATURAL RANGE 1 TO 850   
         );

  PORT(
       --==  General Interface (Sync Rst, 50MHz Clock) ==--

       rst        : IN  STD_LOGIC;
       clk        : IN  STD_LOGIC;

       --== Link Enable Interface ==--

       socw_en   : IN  STD_LOGIC;
       socw_dis   : IN  STD_LOGIC;

       --== Serial Receive Interface ==--

       rx	      : IN  STD_LOGIC_VECTOR(datawidth+1 downto 0);
       rx_valid   : IN  STD_LOGIC;

       --== Serial Transmit Interface ==--

       tx		  : OUT STD_LOGIC_VECTOR(datawidth+1 downto 0);
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
END COMPONENT;


COMPONENT switch
  GENERIC(
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
END COMPONENT;


BEGIN

  ---=====================================---
  --== Enable All CODEC's for Auto-Start ==--
  ---=====================================---

   socw_en  <= '1';
   socw_dis <= '0';


  ---=====================---
  --== SoCWire CODEC's ==--
  ---=====================---

  G0 : FOR i IN 0 TO nports-1 GENERATE 
    socw_codec : socwire_codec
      GENERIC MAP
        (
          datawidth => datawidth,
          speed => speed,
          after64=> after64,              
          after128=>after128,             
          disconnect_detection=>disconnect_detection 
        )
      PORT MAP
        (--==  General Interface (Sync Rst, 50MHz Clock) ==--
         rst        => rst,
         clk        => clk,
         --== Link Enable Interface ==--
         socw_en     => socw_en,
         socw_dis    => socw_dis,
         --== Serial Receive Interface ==--
         rx         => rx((i+1)*(datawidth+2)-1 DOWNTO i*(datawidth+2)),
         rx_valid   => rx_valid(i),
         --== Serial Transmit Interface ==--
         tx         => tx((i+1)*(datawidth+2)-1 DOWNTO i*(datawidth+2)),
		 tx_valid   => tx_valid(i),
         --== Data Input Interface ==--
         dat_full   => dat_full(i),
         dat_nwrite => dat_nwrite(i),
         dat_din    => dat_din((i+1)*(datawidth+1)-1 DOWNTO i*(datawidth+1)),
         --== Data Output Interface ==--
         dat_nread  => dat_nread(i),
         dat_empty  => dat_empty(i),
         dat_dout   => dat_dout((i+1)*(datawidth+1)-1 DOWNTO i*(datawidth+1)),
         --== Active Interface ==--
         active     => active_i(i)
        );
  END GENERATE G0;


  ---==============================---
  --== SoCWire Data Switch Core ==--
  ---==============================---

  socw_switch : switch
    GENERIC MAP
      (
       datawidth => datawidth,
       nports   => nports
      )
    PORT MAP
      (--==  General Interface (Sync Rst) ==--
       clk    => clk,
       rst    => rst,
       --== Input Interface ==--
       nwrite => dat_empty,
       full   => dat_nread,
       din    => dat_dout,
       --== Output Interface ==--
       empty  => dat_nwrite,
       nread  => dat_full,
       dout   => dat_din,
       --== Activity Interface ==--
       active => active_i
      );

  ---======================================---
  --== Shared Internal & External Signals ==--
  ---======================================---

  active <= active_i;

END rtl;
