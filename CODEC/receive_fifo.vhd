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
--== Filename ..... receive_fifo.vhd                                    ==--
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


ENTITY receive_fifo IS
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
END receive_fifo;


ARCHITECTURE rtl OF receive_fifo IS

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
CONSTANT zeros			: STD_LOGIC_VECTOR(datawidth-1 DOWNTO 1) := (OTHERS => '0');

---=======================---
--== Signal Declarations ==--
---=======================---

SIGNAL rd_en         : STD_LOGIC;
SIGNAL rd_addr       : STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');
SIGNAL rd_empty_d    : STD_LOGIC;
SIGNAL rd_empty      : STD_LOGIC;
SIGNAL rd_addr_d     : STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL wr_en         : STD_LOGIC;
SIGNAL wr_addr       : STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');
SIGNAL wr_full_d     : STD_LOGIC;
SIGNAL wr_full       : STD_LOGIC;
SIGNAL wr_din        : STD_LOGIC_VECTOR(datawidth DOWNTO 0);
SIGNAL wr_addr_d     : STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL empty_i       : STD_LOGIC;
SIGNAL fct_empty_i_d : STD_LOGIC;
SIGNAL fct_empty_i   : STD_LOGIC;
SIGNAL fct_en        : STD_LOGIC;
SIGNAL credit        : STD_LOGIC_VECTOR(5 DOWNTO 0) := (OTHERS => '0');
SIGNAL credit_d      : STD_LOGIC_VECTOR(5 DOWNTO 0) := (OTHERS => '0');
SIGNAL credit_e      : STD_LOGIC;
SIGNAL vfullness     : STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');
SIGNAL vfullness_d   : STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');
SIGNAL vfullness_e   : STD_LOGIC;
SIGNAL fullness      : STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');
SIGNAL fullness_d    : STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');
SIGNAL fullness_e    : STD_LOGIC;
SIGNAL got_eop       : STD_LOGIC;
SIGNAL empty_i_d     : STD_LOGIC;
SIGNAL rst_fct       : STD_LOGIC;
SIGNAL wr_en_ext     : STD_LOGIC;



---=============================================---
--== Component Instantiations for leaf modules ==--
---=============================================---

COMPONENT dp_ram
  GENERIC(
          datawidth : NATURAL RANGE 8 TO 8192
         );
	PORT(
       --== General Interface ==--

       rst     : IN  STD_LOGIC;
       clk     : IN  STD_LOGIC;

       --== Write Interface ==--

       wr_en   : IN  STD_LOGIC;
       wr_addr : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
       wr_din  : IN  STD_LOGIC_VECTOR(datawidth DOWNTO 0);

       --== Read Interface ==--

       rd_en   : IN  STD_LOGIC;
       rd_addr : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
       rd_dout : OUT STD_LOGIC_VECTOR(datawidth DOWNTO 0)
      );
END COMPONENT dp_ram;


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
  	  	fct_empty_i <= fct_empty_i_d;
  	  	IF credit_e = '1' THEN
  	  		credit <= credit_d;
  	  	END IF;
  	ELSE 
  		credit <= (others => '0');
  		fct_empty_i <= '1';
  	END IF;
  	
  	IF rst = '0' THEN
  		wr_full <= wr_full_d;
  		rd_empty <= rd_empty_d;
  		empty_i <= empty_i_d;

  		IF wr_en = '1' THEN
  	  		got_eop <= wr_din(datawidth);
  	  		wr_addr <= wr_addr_d;
  	  	END IF; 
  		IF rd_en = '1' THEN
  	  		rd_addr <= rd_addr_d;
  	  	END IF;   	 
  		IF fullness_e = '1' THEN
  	  		fullness <= fullness_d;
  	  	END IF;    	
  		IF vfullness_e = '1' THEN
  	  		vfullness <= vfullness_d;
  	  	END IF;    	  	  	 	
   	  	
  	ELSE
  		got_eop <= '1';
  		wr_addr <= (others => '0');
 		rd_addr <= (others => '0');
  		wr_full <= '1';
  		rd_empty <= '1';
  		fullness <= (others => '0');
  		empty_i <= '1';
  		vfullness <= (others => '0');

  	END IF;
  END IF;
  END PROCESS;
  

  ---=================---
  --== EEP Generator ==--
  ---=================---

  wr_din <= dat_din WHEN (dat_nwrite = '0') AND (wr_full = '0') ELSE '1' & zeros & '1';


  ---===========================================---
  --== FIFO Write Enable & EEP Insertion Logic ==--
  ---===========================================---

  wr_en <= '1' WHEN ((dat_nwrite = '0') AND (wr_full = '0')) OR ((got_eop = '0') AND (state /= st_connecting) AND (state /= st_run)) ELSE '0';


  ---======================---
  --== FIFO Write Address ==--
  ---======================---

  wr_addr_d <= wr_addr + 1;


  ---==================---
  --== FIFO Full Flag ==--
  ---==================---

  wr_full_d <= '1' WHEN ((credit(5 DOWNTO 1) = 0) AND ((credit(0) = '0') OR (wr_en_ext = '1')) AND
                         (fct_en = '0')) OR (state /= st_run) ELSE '0';


  ---===========================---
  --== FIFO (Auto) Read Enable ==--
  ---===========================---

  rd_en <=  NOT(rd_empty) AND (empty_i OR NOT(dat_nread));


  ---=====================---
  --== FIFO Read Address ==--
  ---=====================---

  rd_addr_d <= rd_addr + 1;


  ---===================---
  --== FIFO Empty Flag ==--
  ---===================---

  rd_empty_d <= '1' WHEN (fullness(9 DOWNTO 1) = 0) AND (wr_en = '0') AND
                         ((fullness(0) = '0') OR (rd_en = '1')) ELSE '0';


  ---==================================---
  --== FIFO (Actual) Fullness Counter ==--
  ---==================================---

  PROCESS(wr_en, rd_en, fullness)
  BEGIN
    IF (wr_en = '1') THEN
      fullness_d <= fullness + 1;
    ELSIF (rd_en = '1') THEN
      fullness_d <= fullness - 1;
    ELSE
      fullness_d <= fullness;
    END IF;
  END PROCESS;

  fullness_e <= rd_en XOR wr_en;


    ---===============================---
  --== Data Output Handshake Logic ==--
  ---===============================---

  empty_i_d <= rd_empty AND (empty_i OR NOT(dat_nread));


  ---===================================---
  --== FIFO (Virtual) Fullness Counter ==--
  ---===================================---

  PROCESS(vfullness, fct_en, rd_en, fullness_d)
  VARIABLE tmp : STD_LOGIC_VECTOR(1 DOWNTO 0);
  BEGIN
    tmp := fct_en & rd_en;
    CASE tmp IS
      WHEN "00" => vfullness_d <= fullness_d;
      WHEN "01" => vfullness_d <= vfullness - 1;
      WHEN "10" => vfullness_d <= vfullness + 8;
      WHEN "11" => vfullness_d <= vfullness + 7;
      WHEN OTHERS => NULL;
    END CASE;
  END PROCESS;

  vfullness_e <= (fct_en OR rd_en) WHEN (state = st_connecting) OR (state = st_run) ELSE '1';

  
  ---===================---
  --== FCT Read Enable ==--
  ---===================---

  fct_en <= NOT(fct_nread) AND NOT(fct_empty_i);


  ---==========================---
  --== Receive Credit Counter ==--
  ---==========================---

  wr_en_ext <= '1' WHEN ((dat_nwrite = '0') AND (wr_full = '0')) ELSE '0';

  PROCESS(credit, fct_en, wr_en_ext)
  VARIABLE tmp : STD_LOGIC_VECTOR(1 DOWNTO 0);
  BEGIN
    tmp := fct_en & wr_en_ext;
    CASE tmp IS
      WHEN "11"   => credit_d <= credit + 7;
      WHEN "10"   => credit_d <= credit + 8;
      WHEN OTHERS => credit_d <= credit - 1;
    END CASE;
  END PROCESS;

  credit_e <= fct_en OR wr_en_ext;

  ---=======================---
  --== FCT Handshake Logic ==--
  ---=======================---

  PROCESS(fct_empty_i, fct_nread, credit, vfullness)
  BEGIN
    CASE fct_empty_i IS
      WHEN '0' => IF (fct_nread = '0') THEN
                    fct_empty_i_d <= '1';
                  ELSE
                    fct_empty_i_d <= '0';
                  END IF;
      WHEN '1' => IF (credit <= 48) AND (vfullness <= 1014) THEN
                    fct_empty_i_d <= '0';
                  ELSE
                    fct_empty_i_d <= '1';
                  END IF;
      WHEN OTHERS => NULL;
    END CASE;
  END PROCESS;


  ---=================---
  --== Dual Port RAM ==--
  ---=================---

  dp_ram0 : dp_ram
    GENERIC MAP
	  ( datawidth =>  datawidth )
    PORT MAP
      (--== General Interface ==--
       rst     => rst,
       clk     => clk,
       --== Write Interface ==--
       wr_en   => wr_en,
       wr_addr => wr_addr,
       wr_din  => wr_din,
       --== Read Interface ==--
       rd_en   => rd_en,
       rd_addr => rd_addr,
       rd_dout => dat_dout
      );


  ---======================================---
  --== Shared Internal & External Signals ==--
  ---======================================---

  fct_empty <= fct_empty_i;
  dat_empty <= empty_i;
  dat_full  <= wr_full;
END rtl;
