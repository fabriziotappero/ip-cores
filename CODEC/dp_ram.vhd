
---====================== Start Copyright Notice ========================---
--==                                                                    ==--
--== Filename ..... dp_ram.vhd                                   ==--
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

LIBRARY UNISIM;
USE UNISIM.ALL;


ENTITY dp_ram IS
  GENERIC( datawidth : NATURAL RANGE 8 TO 8192);
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
END dp_ram;


ARCHITECTURE rtl OF dp_ram IS

---==========================---
--== Component Declarations ==--
---==========================---

COMPONENT RAMB16_S18_S18
port (
      DOA 	 : out STD_LOGIC_VECTOR (15 downto 0);
	  DOB 	 : out STD_LOGIC_VECTOR (15 downto 0);
	  DOPA 	 : out STD_LOGIC_VECTOR (1 downto 0);
	  DOPB 	 : out STD_LOGIC_VECTOR (1 downto 0);
	  ADDRA  : in  STD_LOGIC_VECTOR (9 downto 0);
	  ADDRB  : in  STD_LOGIC_VECTOR (9 downto 0);
	  CLKA   : in  STD_LOGIC;
	  CLKB   : in  STD_LOGIC;
	  DIA 	 : in  STD_LOGIC_VECTOR (15 downto 0);
	  DIB 	 : in  STD_LOGIC_VECTOR (15 downto 0);
	  DIPA   : in  STD_LOGIC_VECTOR (1 downto 0);
	  DIPB   : in  STD_LOGIC_VECTOR (1 downto 0);
	  ENA 	 : in  STD_LOGIC;
	  ENB 	 : in  STD_LOGIC;
	  SSRA	 : in  STD_LOGIC;
	  SSRB   : in  STD_LOGIC;
	  WEA    : in  STD_LOGIC;
	  WEB    : in  STD_LOGIC
	 );
END COMPONENT;

---=======================---
--== Signal Declarations ==--
---=======================---

SIGNAL logic_0      : STD_LOGIC;
SIGNAL logic_1      : STD_LOGIC;
SIGNAL logic_0_bus  : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL addra_i		: STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL addrb_i		: STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL logic_00		: STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL ramin		: STD_LOGIC_VECTOR(((datawidth / 16) + 1)*16-1 DOWNTO 0) := (others => '0');
SIGNAL ramout		: STD_LOGIC_VECTOR(((datawidth / 16) + 1)*16-1 DOWNTO 0) := (others => '0');
SIGNAL ENA			: STD_LOGIC;
SIGNAL ENB			: STD_LOGIC;
SIGNAL rst_buf		: STD_LOGIC;
BEGIN

  ---===================---
  --== Tie-Off Signals ==--
  ---===================---

  logic_0     <= '0';
  logic_1     <= '1';
  logic_0_bus <= (OTHERS => '0');
  logic_00    <= (OTHERS => '0');

  ---=================---
  --== Dual Port RAM ==--
  ---=================---
  

  addra_i <= wr_addr;
  addrb_i <= rd_addr;
  ena <= wr_en;
  enb <= rd_en OR rst;


  G0 : FOR a IN 0 TO (datawidth) GENERATE
    ramin(a) <= wr_din(a);
  END GENERATE G0;
  
  G1 : FOR b IN 0 TO (datawidth) GENERATE
    rd_dout(b) <= ramout(b);
  END GENERATE G1;
    
  G2 : FOR i IN 0 TO (datawidth / 16) GENERATE
  U0 : RAMB16_S18_S18
    port map(
             DOA => OPEN, -- Port A 16-bit Data Output
			 DOB => ramout((i+1)*16-1 DOWNTO i*16), -- Port B 16-bit Data Output
			 DOPA => OPEN, -- Port A 2-bit Parity Output
			 DOPB => OPEN, -- Port B 2-bit Parity Output
			 ADDRA => addra_i, -- Port A 10-bit Address Input
			 ADDRB => addrb_i, -- Port B 10-bit Address Input
			 CLKA => clk, -- Port A Clock
			 CLKB => clk, -- Port B Clock
			 DIA => ramin((i+1)*16-1 DOWNTO i*16), -- Port A 16-bit Data Input
			 DIB => logic_0_bus, -- Port B 16-bit Data Input
			 DIPA => logic_00, -- Port A 2-bit parity Input
			 DIPB => logic_00, -- Port-B 2-bit parity Input
			 ENA => ena, -- Port A RAM Enable Input
			 ENB => enb, -- PortB RAM Enable Input
			 SSRA => rst, -- Port A Synchronous Set/Reset Input
			 SSRB => rst, -- Port B Synchronous Set/Reset Input
			 WEA => logic_1, -- Port A Write Enable Input
			 WEB => logic_0  -- Port B Write Enable Input
);            

END GENERATE G2;

END rtl;




