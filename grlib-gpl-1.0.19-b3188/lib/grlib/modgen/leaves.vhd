-----------------------------------------------------------------------------
-- File:	leaves.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	A set of multipliers generated from the Arithmetic Module
--		Generator at Norwegian University of Science and Technology.
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package blocks is
  component FLIPFLOP
  port (
	DIN, CLK: in std_logic;
	DOUT: out std_logic
  );
  end component;
  component DBLCADDER_32_32
    port(OPA: in std_logic_vector(0 to 31);
         OPB: in std_logic_vector(0 to 31);
         CIN: in std_logic;
         PHI: in std_logic;
         SUM: out std_logic_vector(0 to 31);
         COUT: out std_logic);
  end component;
component FULL_ADDER
port
(
	DATA_A, DATA_B, DATA_C: in std_logic;
	SAVE, CARRY: out std_logic
);
end component;
component HALF_ADDER
port
(
	DATA_A, DATA_B: in std_logic;
	SAVE, CARRY: out std_logic
);
end component;
component R_GATE
port
(
		INA, INB, INC: in std_logic;
		PPBIT: out std_logic
);

end component;
component DECODER
port
(
		INA, INB, INC: in std_logic;
		TWOPOS, TWONEG, ONEPOS, ONENEG: out std_logic
);

end component;
component PP_LOW
port
(
		ONEPOS, ONENEG, TWONEG: in std_logic;
		INA, INB: in std_logic;
		PPBIT: out std_logic
);

end component;
component PP_MIDDLE
port
(
		ONEPOS, ONENEG, TWOPOS, TWONEG: in std_logic;
		INA, INB, INC, IND: in std_logic;
		PPBIT: out std_logic
);

end component;
component PP_HIGH
port
(
		ONEPOS, ONENEG, TWOPOS, TWONEG: in std_logic;
		INA, INB: in std_logic;
		PPBIT: out std_logic
);

end component;
component BLOCK0
port
(
	A,B,PHI: in std_logic;
	POUT,GOUT: out std_logic
);
end component;
component INVBLOCK
port
(
	GIN,PHI:in std_logic;
	GOUT:out std_logic
);
end component;

component BLOCK1
port
(
	PIN1,PIN2,GIN1,GIN2,PHI:in std_logic;
	POUT,GOUT:out std_logic
);
end component;

component BLOCK1A 
port
(
	PIN2,GIN1,GIN2,PHI:in std_logic;
	GOUT:out std_logic
);
end component;

component BLOCK2 
port
(
	PIN1,PIN2,GIN1,GIN2,PHI:in std_logic;
	POUT,GOUT:out std_logic
);
end component;

component BLOCK2A 
port
(
	PIN2,GIN1,GIN2,PHI:in std_logic;
	GOUT:out std_logic
);
end component;

component PRESTAGE_32
port
(
	A: in std_logic_vector(0 to 31);
	B: in std_logic_vector(0 to 31);
	CIN: in std_logic;
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 31);
	GOUT: out std_logic_vector(0 to 32)
);
end component;

component XXOR1
port
(
	A,B,GIN,PHI:in std_logic;
	SUM:out std_logic
);
end component;
component XXOR2
port
(
	A,B,GIN,PHI:in std_logic;
	SUM:out std_logic
);
end component;
component DBLCTREE_32
port
(
	PIN:in std_logic_vector(0 to 31);
	GIN:in std_logic_vector(0 to 32);
	PHI:in std_logic;
	GOUT:out std_logic_vector(0 to 32);
	POUT:out std_logic_vector(0 to 0)
);
end component;

component XORSTAGE_32
port
(
	A: in std_logic_vector(0 to 31);
	B: in std_logic_vector(0 to 31);
	PBIT: in std_logic;
	PHI: in std_logic;
	CARRY: in std_logic_vector(0 to 32);
	SUM: out std_logic_vector(0 to 31);
	COUT: out std_logic
);
end component;

component DBLC_0_32
port
(
	PIN: in std_logic_vector(0 to 31);
	GIN: in std_logic_vector(0 to 32);
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 30);
	GOUT: out std_logic_vector(0 to 32)
);
end component;

component DBLC_1_32
port
(
	PIN: in std_logic_vector(0 to 30);
	GIN: in std_logic_vector(0 to 32);
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 28);
	GOUT: out std_logic_vector(0 to 32)
);
end component;

component DBLC_2_32
port
(
	PIN: in std_logic_vector(0 to 28);
	GIN: in std_logic_vector(0 to 32);
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 24);
	GOUT: out std_logic_vector(0 to 32)
);
end component;

component DBLC_3_32
port
(
	PIN: in std_logic_vector(0 to 24);
	GIN: in std_logic_vector(0 to 32);
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 16);
	GOUT: out std_logic_vector(0 to 32)
);
end component;

component DBLC_4_32
port
(
	PIN: in std_logic_vector(0 to 16);
	GIN: in std_logic_vector(0 to 32);
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 0);
	GOUT: out std_logic_vector(0 to 32)
);
end component;
component PRESTAGE_64
port
(
	A: in std_logic_vector(0 to 63);
	B: in std_logic_vector(0 to 63);
	CIN: in std_logic;
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 63);
	GOUT: out std_logic_vector(0 to 64)
);
end component;

component DBLCTREE_64
port
(
	PIN:in std_logic_vector(0 to 63);
	GIN:in std_logic_vector(0 to 64);
	PHI:in std_logic;
	GOUT:out std_logic_vector(0 to 64);
	POUT:out std_logic_vector(0 to 0)
);
end component;

component XORSTAGE_64
port
(
	A: in std_logic_vector(0 to 63);
	B: in std_logic_vector(0 to 63);
	PBIT: in std_logic;
	PHI: in std_logic;
	CARRY: in std_logic_vector(0 to 64);
	SUM: out std_logic_vector(0 to 63);
	COUT: out std_logic
);
end component;
component DBLC_0_64
port
(
	PIN: in std_logic_vector(0 to 63);
	GIN: in std_logic_vector(0 to 64);
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 62);
	GOUT: out std_logic_vector(0 to 64)
);
end component;

component DBLC_1_64
port
(
	PIN: in std_logic_vector(0 to 62);
	GIN: in std_logic_vector(0 to 64);
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 60);
	GOUT: out std_logic_vector(0 to 64)
);
end component;

component DBLC_2_64
port
(
	PIN: in std_logic_vector(0 to 60);
	GIN: in std_logic_vector(0 to 64);
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 56);
	GOUT: out std_logic_vector(0 to 64)
);
end component;

component DBLC_3_64
port
(
	PIN: in std_logic_vector(0 to 56);
	GIN: in std_logic_vector(0 to 64);
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 48);
	GOUT: out std_logic_vector(0 to 64)
);
end component;

component DBLC_4_64
port
(
	PIN: in std_logic_vector(0 to 48);
	GIN: in std_logic_vector(0 to 64);
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 32);
	GOUT: out std_logic_vector(0 to 64)
);
end component;

component DBLC_5_64
port
(
	PIN: in std_logic_vector(0 to 32);
	GIN: in std_logic_vector(0 to 64);
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 0);
	GOUT: out std_logic_vector(0 to 64)
);
end component;
component DBLC_0_128
port
(
	PIN: in std_logic_vector(0 to 127);
	GIN: in std_logic_vector(0 to 128);
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 126);
	GOUT: out std_logic_vector(0 to 128)
);
end component;

component DBLC_1_128
port
(
	PIN: in std_logic_vector(0 to 126);
	GIN: in std_logic_vector(0 to 128);
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 124);
	GOUT: out std_logic_vector(0 to 128)
);
end component;

component DBLC_2_128
port
(
	PIN: in std_logic_vector(0 to 124);
	GIN: in std_logic_vector(0 to 128);
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 120);
	GOUT: out std_logic_vector(0 to 128)
);
end component;

component DBLC_3_128
port
(
	PIN: in std_logic_vector(0 to 120);
	GIN: in std_logic_vector(0 to 128);
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 112);
	GOUT: out std_logic_vector(0 to 128)
);
end component;

component DBLC_4_128
port
(
	PIN: in std_logic_vector(0 to 112);
	GIN: in std_logic_vector(0 to 128);
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 96);
	GOUT: out std_logic_vector(0 to 128)
);
end component;

component DBLC_5_128
port
(
	PIN: in std_logic_vector(0 to 96);
	GIN: in std_logic_vector(0 to 128);
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 64);
	GOUT: out std_logic_vector(0 to 128)
);
end component;

component DBLC_6_128
port
(
	PIN: in std_logic_vector(0 to 64);
	GIN: in std_logic_vector(0 to 128);
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 0);
	GOUT: out std_logic_vector(0 to 128)
);
end component;
component PRESTAGE_128
port
(
	A: in std_logic_vector(0 to 127);
	B: in std_logic_vector(0 to 127);
	CIN: in std_logic;
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 127);
	GOUT: out std_logic_vector(0 to 128)
);
end component;

component DBLCTREE_128
port
(
	PIN:in std_logic_vector(0 to 127);
	GIN:in std_logic_vector(0 to 128);
	PHI:in std_logic;
	GOUT:out std_logic_vector(0 to 128);
	POUT:out std_logic_vector(0 to 0)
);
end component;

component XORSTAGE_128
port
(
	A: in std_logic_vector(0 to 127);
	B: in std_logic_vector(0 to 127);
	PBIT: in std_logic;
	PHI: in std_logic;
	CARRY: in std_logic_vector(0 to 128);
	SUM: out std_logic_vector(0 to 127);
	COUT: out std_logic
);
end component;
component BOOTHCODER_18_18 
port
(
	OPA: in std_logic_vector(0 to 17);
	OPB: in std_logic_vector(0 to 17);
	SUMMAND: out std_logic_vector(0 to 188)
);
end component;
component WALLACE_18_18
port
(
	SUMMAND: in std_logic_vector(0 to 188);
	CARRY: out std_logic_vector(0 to 33);
	SUM: out std_logic_vector(0 to 34)
);
end component;
component DBLCADDER_64_64
port
(
	OPA:in std_logic_vector(0 to 63);
	OPB:in std_logic_vector(0 to 63);
	CIN:in std_logic;
	PHI:in std_logic;
	SUM:out std_logic_vector(0 to 63);
	COUT:out std_logic
);
end component;
component BOOTHCODER_34_10 
port
(
	OPA: in std_logic_vector(0 to 33);
	OPB: in std_logic_vector(0 to 9);
	SUMMAND: out std_logic_vector(0 to 184)
);
end component;
component WALLACE_34_10
port
(
	SUMMAND: in std_logic_vector(0 to 184);
	CARRY: out std_logic_vector(0 to 41);
	SUM: out std_logic_vector(0 to 42)
);
end component;
component BOOTHCODER_34_18 
port
(
	OPA: in std_logic_vector(0 to 33);
	OPB: in std_logic_vector(0 to 17);
	SUMMAND: out std_logic_vector(0 to 332)
);
end component;
component WALLACE_34_18
port
(
	SUMMAND: in std_logic_vector(0 to 332);
	CARRY: out std_logic_vector(0 to 49);
	SUM: out std_logic_vector(0 to 50)
);
end component;
component BOOTHCODER_34_34 
port
(
	OPA: in std_logic_vector(0 to 33);
	OPB: in std_logic_vector(0 to 33);
	SUMMAND: out std_logic_vector(0 to 628)
);
end component;
component WALLACE_34_34
port
(
	SUMMAND: in std_logic_vector(0 to 628);
	CARRY: out std_logic_vector(0 to 65);
	SUM: out std_logic_vector(0 to 66)
);
end component;
component DBLCADDER_128_128
port
(
	OPA:in std_logic_vector(0 to 127);
	OPB:in std_logic_vector(0 to 127);
	CIN:in std_logic;
	PHI:in std_logic;
	SUM:out std_logic_vector(0 to 127);
	COUT:out std_logic
);
end component;
  component MULTIPLIER_18_18
    generic (mulpipe : integer := 0);
    port(MULTIPLICAND: in std_logic_vector(0 to 17);
         MULTIPLIER: in std_logic_vector(0 to 17);
         PHI: in std_ulogic;
	 holdn: in std_ulogic;
         RESULT: out std_logic_vector(0 to 63));
  end component;
  component MULTIPLIER_34_10
    port(MULTIPLICAND: in std_logic_vector(0 to 33);
         MULTIPLIER: in std_logic_vector(0 to 9);
         PHI: in std_logic;
         RESULT: out std_logic_vector(0 to 63));
  end component;
  component MULTIPLIER_34_18
    port(MULTIPLICAND: in std_logic_vector(0 to 33);
         MULTIPLIER: in std_logic_vector(0 to 17);
         PHI: in std_logic;
         RESULT: out std_logic_vector(0 to 63));
  end component;
  component MULTIPLIER_34_34
    generic (mulpipe : integer := 0);
    port(MULTIPLICAND: in std_logic_vector(0 to 33);
         MULTIPLIER: in std_logic_vector(0 to 33);
         PHI: in std_logic;
	 holdn: in std_ulogic;
         RESULT: out std_logic_vector(0 to 127));
  end component;
end;
------------------------------------------------------------
-- START: Entities used within the Modified Booth Recoding
------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
entity FLIPFLOP is
port
(
	DIN: in std_logic;
	CLK: in std_logic;
	DOUT: out std_logic
);
end FLIPFLOP;

architecture FLIPFLOP of FLIPFLOP is
begin
process(CLK)
begin
	if(CLK='1')and(CLK'event)then
		DOUT <= DIN;
	end if;
end process;
end FLIPFLOP;

library ieee;
use ieee.std_logic_1164.all;
entity PP_LOW is
port
(
		ONEPOS, ONENEG, TWONEG: in std_logic;
		INA, INB: in std_logic;
		PPBIT: out std_logic
);
end PP_LOW;

architecture PP_LOW of PP_LOW is
begin
	PPBIT <= (ONEPOS and INA) or (ONENEG and INB) or TWONEG;
end PP_LOW;

library ieee;
use ieee.std_logic_1164.all;
entity PP_MIDDLE is
port
(
		ONEPOS, ONENEG, TWOPOS, TWONEG: in std_logic;
		INA, INB, INC, IND: in std_logic;
		PPBIT: out std_logic
);
end PP_MIDDLE;
architecture PP_MIDDLE of PP_MIDDLE is
begin
	PPBIT <= not((not(INA and TWOPOS)) and (not(INB and TWONEG)) and (not(INC and ONEPOS)) and (not(IND and ONENEG)));
end PP_MIDDLE;

library ieee;
use ieee.std_logic_1164.all;
entity PP_HIGH is
port
(
		ONEPOS, ONENEG, TWOPOS, TWONEG: in std_logic;
		INA, INB: in std_logic;
		PPBIT: out std_logic
);
end PP_HIGH;
architecture PP_HIGH of PP_HIGH is
begin
	PPBIT <= not ((INA and ONEPOS) or (INB and ONENEG) or (INA and TWOPOS) or (INB and TWONEG));
end PP_HIGH;

library ieee;
use ieee.std_logic_1164.all;
entity R_GATE is
port
(
		INA, INB, INC: in std_logic;
		PPBIT: out std_logic
);
end R_GATE;
architecture R_GATE of R_GATE is
begin
	PPBIT <= (not(INA and INB)) and INC;
end R_GATE;

library ieee;
use ieee.std_logic_1164.all;
entity DECODER is
port
(
		INA, INB, INC: in std_logic;
		TWOPOS, TWONEG, ONEPOS, ONENEG: out std_logic
);
end DECODER;
architecture DECODER of DECODER is
begin
	TWOPOS <= not(not(INA and INB and (not INC)));
	TWONEG <= not(not((not INA) and (not INB) and INC));
	ONEPOS <= ((not INA) and INB and (not INC)) or ((not INC) and (not INB) and INA);
	ONENEG <= (INA and (not INB) and INC) or (INC and INB and (not INA));
end DECODER;

library ieee;
use ieee.std_logic_1164.all;
entity FULL_ADDER is
port
(
	DATA_A, DATA_B, DATA_C: in std_logic;
	SAVE, CARRY: out std_logic
);
end FULL_ADDER;
architecture FULL_ADDER of FULL_ADDER is
	signal TMP: std_logic;
begin
	TMP <= DATA_A xor DATA_B;
	SAVE <= TMP xor DATA_C;
	CARRY <= not((not (TMP and DATA_C)) and (not (DATA_A and DATA_B)));
end FULL_ADDER;

library ieee;
use ieee.std_logic_1164.all;
entity HALF_ADDER is
port
(
	DATA_A, DATA_B: in std_logic;
	SAVE, CARRY: out std_logic
);
end HALF_ADDER;
architecture HALF_ADDER of HALF_ADDER is
begin
	SAVE <= DATA_A xor DATA_B;
	CARRY <= DATA_A and DATA_B;
end HALF_ADDER;

library ieee;
use ieee.std_logic_1164.all;
entity INVBLOCK is
port
(
	GIN,PHI:in std_logic;
	GOUT:out std_logic
);
end INVBLOCK;
architecture INVBLOCK_regular of INVBLOCK is
begin
	GOUT <= not GIN;
end INVBLOCK_regular;

library ieee;
use ieee.std_logic_1164.all;
entity XXOR1 is
port
(
	A,B,GIN,PHI:in std_logic;
	SUM:out std_logic
);
end XXOR1;
architecture XXOR_regular of XXOR1 is
begin
	SUM <= (not (A xor B)) xor GIN;
end XXOR_regular;

library ieee;
use ieee.std_logic_1164.all;
entity BLOCK0 is
port
(
	A,B,PHI:in std_logic;
	POUT,GOUT:out std_logic
);
end BLOCK0;
architecture BLOCK0_regular of BLOCK0 is
begin
	POUT <= not(A or B);
	GOUT <= not(A and B);
end BLOCK0_regular;

library ieee;
use ieee.std_logic_1164.all;
entity BLOCK1 is
port
(
	PIN1,PIN2,GIN1,GIN2,PHI:in std_logic;
	POUT,GOUT:out std_logic
);
end BLOCK1;
architecture BLOCK1_regular of BLOCK1 is
begin
	POUT <= not(PIN1 or PIN2);
	GOUT <= not(GIN2 and (PIN2 or GIN1));
end BLOCK1_regular;

library ieee;
use ieee.std_logic_1164.all;
entity BLOCK2 is
port
(
	PIN1,PIN2,GIN1,GIN2,PHI:in std_logic;
	POUT,GOUT:out std_logic
);
end BLOCK2;
architecture BLOCK2_regular of BLOCK2 is
begin
	POUT <= not(PIN1 and PIN2);
	GOUT <= not(GIN2 or (PIN2 and GIN1));
end BLOCK2_regular;

library ieee;
use ieee.std_logic_1164.all;
entity BLOCK1A is
port
(
	PIN2,GIN1,GIN2,PHI:in std_logic;
	GOUT:out std_logic
);
end BLOCK1A;
architecture BLOCK1A_regular of BLOCK1A is
begin
	GOUT <= not(GIN2 and (PIN2 or GIN1));
end BLOCK1A_regular;

library ieee;
use ieee.std_logic_1164.all;
entity BLOCK2A is
port
(
	PIN2,GIN1,GIN2,PHI:in std_logic;
	GOUT:out std_logic
);
end BLOCK2A;
architecture BLOCK2A_regular of BLOCK2A is
begin
	GOUT <= not(GIN2 or (PIN2 and GIN1));
end BLOCK2A_regular;

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.blocks.all;
entity PRESTAGE_64 is
port
(
	A: in std_logic_vector(0 to 63);
	B: in std_logic_vector(0 to 63);
	CIN: in std_logic;
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 63);
	GOUT: out std_logic_vector(0 to 64)
);
end PRESTAGE_64;
architecture PRESTAGE of PRESTAGE_64 is
begin  -- PRESTAGE
U1:for I in 0 to 63 generate
	U11: BLOCK0 port map(A(I),B(I),PHI,POUT(I),GOUT(I+1));
end generate U1;
U2: INVBLOCK port map(CIN,PHI,GOUT(0));
end PRESTAGE;
-- The DBLC-tree: Level 0

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.blocks.all;
entity DBLC_0_64 is
port
(
	PIN: in std_logic_vector(0 to 63);
	GIN: in std_logic_vector(0 to 64);
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 62);
	GOUT: out std_logic_vector(0 to 64)
);
end DBLC_0_64;

architecture DBLC_0 of DBLC_0_64 is

begin -- Architecture DBLC_0
U1: for I in 0 to 0 generate
	U11: INVBLOCK port map(GIN(I),PHI,GOUT(I));
end generate U1;
U2: for I in 1 to 1 generate
	U21: BLOCK1A port map(PIN(I-1),GIN(I-1),GIN(I),PHI,GOUT(I));
end generate U2;
U3: for I in 2 to 64 generate
	U31: BLOCK1 port map(PIN(I-2),PIN(I-1),GIN(I-1),GIN(I),PHI,POUT(I-2),GOUT(I));
end generate U3;
end DBLC_0;

-- The DBLC-tree: Level 1

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.blocks.all;
entity DBLC_1_64 is
port
(
	PIN: in std_logic_vector(0 to 62);
	GIN: in std_logic_vector(0 to 64);
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 60);
	GOUT: out std_logic_vector(0 to 64)
);
end DBLC_1_64;

architecture DBLC_1 of DBLC_1_64 is

begin -- Architecture DBLC_1
U1: for I in 0 to 1 generate
	U11: INVBLOCK port map(GIN(I),PHI,GOUT(I));
end generate U1;
U2: for I in 2 to 3 generate
	U21: BLOCK2A port map(PIN(I-2),GIN(I-2),GIN(I),PHI,GOUT(I));
end generate U2;
U3: for I in 4 to 64 generate
	U31: BLOCK2 port map(PIN(I-4),PIN(I-2),GIN(I-2),GIN(I),PHI,POUT(I-4),GOUT(I));
end generate U3;
end DBLC_1;

-- The DBLC-tree: Level 2


library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.blocks.all;
entity DBLC_2_64 is
port
(
	PIN: in std_logic_vector(0 to 60);
	GIN: in std_logic_vector(0 to 64);
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 56);
	GOUT: out std_logic_vector(0 to 64)
);
end DBLC_2_64;

architecture DBLC_2 of DBLC_2_64 is

begin -- Architecture DBLC_2
U1: for I in 0 to 3 generate
	U11: INVBLOCK port map(GIN(I),PHI,GOUT(I));
end generate U1;
U2: for I in 4 to 7 generate
	U21: BLOCK1A port map(PIN(I-4),GIN(I-4),GIN(I),PHI,GOUT(I));
end generate U2;
U3: for I in 8 to 64 generate
	U31: BLOCK1 port map(PIN(I-8),PIN(I-4),GIN(I-4),GIN(I),PHI,POUT(I-8),GOUT(I));
end generate U3;
end DBLC_2;

-- The DBLC-tree: Level 3

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.blocks.all;
entity DBLC_3_64 is
port
(
	PIN: in std_logic_vector(0 to 56);
	GIN: in std_logic_vector(0 to 64);
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 48);
	GOUT: out std_logic_vector(0 to 64)
);
end DBLC_3_64;

architecture DBLC_3 of DBLC_3_64 is

begin -- Architecture DBLC_3
U1: for I in 0 to 7 generate
	U11: INVBLOCK port map(GIN(I),PHI,GOUT(I));
end generate U1;
U2: for I in 8 to 15 generate
	U21: BLOCK2A port map(PIN(I-8),GIN(I-8),GIN(I),PHI,GOUT(I));
end generate U2;
U3: for I in 16 to 64 generate
	U31: BLOCK2 port map(PIN(I-16),PIN(I-8),GIN(I-8),GIN(I),PHI,POUT(I-16),GOUT(I));
end generate U3;
end DBLC_3;

-- The DBLC-tree: Level 4

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.blocks.all;
entity DBLC_4_64 is
port
(
	PIN: in std_logic_vector(0 to 48);
	GIN: in std_logic_vector(0 to 64);
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 32);
	GOUT: out std_logic_vector(0 to 64)
);
end DBLC_4_64;

architecture DBLC_4 of DBLC_4_64 is

begin -- Architecture DBLC_4
U1: for I in 0 to 15 generate
	U11: INVBLOCK port map(GIN(I),PHI,GOUT(I));
end generate U1;
U2: for I in 16 to 31 generate
	U21: BLOCK1A port map(PIN(I-16),GIN(I-16),GIN(I),PHI,GOUT(I));
end generate U2;
U3: for I in 32 to 64 generate
	U31: BLOCK1 port map(PIN(I-32),PIN(I-16),GIN(I-16),GIN(I),PHI,POUT(I-32),GOUT(I));
end generate U3;
end DBLC_4;

-- The DBLC-tree: Level 5

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.blocks.all;
entity DBLC_5_64 is
port
(
	PIN: in std_logic_vector(0 to 32);
	GIN: in std_logic_vector(0 to 64);
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 0);
	GOUT: out std_logic_vector(0 to 64)
);
end DBLC_5_64;

architecture DBLC_5 of DBLC_5_64 is

begin -- Architecture DBLC_5
U1: for I in 0 to 31 generate
	U11: INVBLOCK port map(GIN(I),PHI,GOUT(I));
end generate U1;
U2: for I in 32 to 63 generate
	U21: BLOCK2A port map(PIN(I-32),GIN(I-32),GIN(I),PHI,GOUT(I));
end generate U2;
U3: for I in 64 to 64 generate
	U31: BLOCK2 port map(PIN(I-64),PIN(I-32),GIN(I-32),GIN(I),PHI,POUT(I-64),GOUT(I));
end generate U3;
end DBLC_5;

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.blocks.all;
entity XORSTAGE_64 is
port
(
	A: in std_logic_vector(0 to 63);
	B: in std_logic_vector(0 to 63);
	PBIT, PHI: in std_logic;
	CARRY: in std_logic_vector(0 to 64);
	SUM: out std_logic_vector(0 to 63);
	COUT: out std_logic
);
end XORSTAGE_64;
architecture XORSTAGE of XORSTAGE_64 is

begin -- XORSTAGE
U2:for I in 0 to 63 generate
	U22: XXOR1 port map(A(I),B(I),CARRY(I),PHI,SUM(I));
end generate U2;
U1: BLOCK1A port map(PBIT,CARRY(0),CARRY(64),PHI,COUT);
end XORSTAGE;

-- The DBLC-tree: All levels encapsulated

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.blocks.all;
entity DBLCTREE_64 is
port
(
	PIN:in std_logic_vector(0 to 63);
	GIN:in std_logic_vector(0 to 64);
	PHI:in std_logic;
	GOUT:out std_logic_vector(0 to 64);
	POUT:out std_logic_vector(0 to 0)
);
end DBLCTREE_64;

architecture DBLCTREE of DBLCTREE_64 is

signal INTPROP_0: std_logic_vector(0 to 62);
signal INTGEN_0: std_logic_vector(0 to 64);
signal INTPROP_1: std_logic_vector(0 to 60);
signal INTGEN_1: std_logic_vector(0 to 64);
signal INTPROP_2: std_logic_vector(0 to 56);
signal INTGEN_2: std_logic_vector(0 to 64);
signal INTPROP_3: std_logic_vector(0 to 48);
signal INTGEN_3: std_logic_vector(0 to 64);
signal INTPROP_4: std_logic_vector(0 to 32);
signal INTGEN_4: std_logic_vector(0 to 64);
begin -- Architecture DBLCTREE
U_0: DBLC_0_64 port map(PIN=>PIN,GIN=>GIN,PHI=>PHI,POUT=>INTPROP_0,GOUT=>INTGEN_0);
U_1: DBLC_1_64 port map(PIN=>INTPROP_0,GIN=>INTGEN_0,PHI=>PHI,POUT=>INTPROP_1,GOUT=>INTGEN_1);
U_2: DBLC_2_64 port map(PIN=>INTPROP_1,GIN=>INTGEN_1,PHI=>PHI,POUT=>INTPROP_2,GOUT=>INTGEN_2);
U_3: DBLC_3_64 port map(PIN=>INTPROP_2,GIN=>INTGEN_2,PHI=>PHI,POUT=>INTPROP_3,GOUT=>INTGEN_3);
U_4: DBLC_4_64 port map(PIN=>INTPROP_3,GIN=>INTGEN_3,PHI=>PHI,POUT=>INTPROP_4,GOUT=>INTGEN_4);
U_5: DBLC_5_64 port map(PIN=>INTPROP_4,GIN=>INTGEN_4,PHI=>PHI,POUT=>POUT,GOUT=>GOUT);
end DBLCTREE;

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.blocks.all;
entity DBLCADDER_64_64 is
port
(
	OPA:in std_logic_vector(0 to 63);
	OPB:in std_logic_vector(0 to 63);
	CIN:in std_logic;
	PHI:in std_logic;
	SUM:out std_logic_vector(0 to 63);
	COUT:out std_logic
);
end DBLCADDER_64_64;
architecture DBLCADDER of DBLCADDER_64_64 is

signal INTPROP: std_logic_vector(0 to 63);
signal INTGEN: std_logic_vector(0 to 64);
signal PBIT:std_logic_vector(0 to 0);
signal CARRY: std_logic_vector(0 to 64);

begin -- Architecture DBLCADDER

U1: PRESTAGE_64 port map(OPA,OPB,CIN,PHI,INTPROP,INTGEN);
U2: DBLCTREE_64 port map(INTPROP,INTGEN,PHI,CARRY,PBIT);
U3: XORSTAGE_64 port map(OPA(0 to 63),OPB(0 to 63),PBIT(0),PHI,CARRY(0 to 64),SUM,COUT);
end DBLCADDER;
------------------------------------------------------------
-- END: Architectures used with the DBLC adder
------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
entity XXOR2 is
port
(
	A,B,GIN,PHI:in std_logic;
	SUM:out std_logic
);
end XXOR2;
architecture XXOR_true of XXOR2 is
begin
	SUM <= (A xor B) xor GIN;
end XXOR_true;



--
-- Modgen adder created Fri Aug 16 14:47:23 2002
--


library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.blocks.all;
entity DBLC_0_32 is
port
(
	PIN: in std_logic_vector(0 to 31);
	GIN: in std_logic_vector(0 to 32);
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 30);
	GOUT: out std_logic_vector(0 to 32)
);
end DBLC_0_32;

architecture DBLC_0 of DBLC_0_32 is

begin -- Architecture DBLC_0
U1: for I in 0 to 0 generate
	U11: INVBLOCK port map(GIN(I),PHI,GOUT(I));
end generate U1;
U2: for I in 1 to 1 generate
	U21: BLOCK1A port map(PIN(I-1),GIN(I-1),GIN(I),PHI,GOUT(I));
end generate U2;
U3: for I in 2 to 32 generate
	U31: BLOCK1 port map(PIN(I-2),PIN(I-1),GIN(I-1),GIN(I),PHI,POUT(I-2),GOUT(I));
end generate U3;
end DBLC_0;

-- The DBLC-tree: Level 1

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.blocks.all;
entity DBLC_1_32 is
port
(
	PIN: in std_logic_vector(0 to 30);
	GIN: in std_logic_vector(0 to 32);
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 28);
	GOUT: out std_logic_vector(0 to 32)
);
end DBLC_1_32;

architecture DBLC_1 of DBLC_1_32 is

begin -- Architecture DBLC_1
U1: for I in 0 to 1 generate
	U11: INVBLOCK port map(GIN(I),PHI,GOUT(I));
end generate U1;
U2: for I in 2 to 3 generate
	U21: BLOCK2A port map(PIN(I-2),GIN(I-2),GIN(I),PHI,GOUT(I));
end generate U2;
U3: for I in 4 to 32 generate
	U31: BLOCK2 port map(PIN(I-4),PIN(I-2),GIN(I-2),GIN(I),PHI,POUT(I-4),GOUT(I));
end generate U3;
end DBLC_1;

-- The DBLC-tree: Level 2

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.blocks.all;
entity DBLC_2_32 is
port
(
	PIN: in std_logic_vector(0 to 28);
	GIN: in std_logic_vector(0 to 32);
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 24);
	GOUT: out std_logic_vector(0 to 32)
);
end DBLC_2_32;

architecture DBLC_2 of DBLC_2_32 is

begin -- Architecture DBLC_2
U1: for I in 0 to 3 generate
	U11: INVBLOCK port map(GIN(I),PHI,GOUT(I));
end generate U1;
U2: for I in 4 to 7 generate
	U21: BLOCK1A port map(PIN(I-4),GIN(I-4),GIN(I),PHI,GOUT(I));
end generate U2;
U3: for I in 8 to 32 generate
	U31: BLOCK1 port map(PIN(I-8),PIN(I-4),GIN(I-4),GIN(I),PHI,POUT(I-8),GOUT(I));
end generate U3;
end DBLC_2;

-- The DBLC-tree: Level 3

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.blocks.all;
entity DBLC_3_32 is
port
(
	PIN: in std_logic_vector(0 to 24);
	GIN: in std_logic_vector(0 to 32);
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 16);
	GOUT: out std_logic_vector(0 to 32)
);
end DBLC_3_32;

architecture DBLC_3 of DBLC_3_32 is

begin -- Architecture DBLC_3
U1: for I in 0 to 7 generate
	U11: INVBLOCK port map(GIN(I),PHI,GOUT(I));
end generate U1;
U2: for I in 8 to 15 generate
	U21: BLOCK2A port map(PIN(I-8),GIN(I-8),GIN(I),PHI,GOUT(I));
end generate U2;
U3: for I in 16 to 32 generate
	U31: BLOCK2 port map(PIN(I-16),PIN(I-8),GIN(I-8),GIN(I),PHI,POUT(I-16),GOUT(I));
end generate U3;
end DBLC_3;

-- The DBLC-tree: Level 4

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.blocks.all;
entity DBLC_4_32 is
port
(
	PIN: in std_logic_vector(0 to 16);
	GIN: in std_logic_vector(0 to 32);
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 0);
	GOUT: out std_logic_vector(0 to 32)
);
end DBLC_4_32;

architecture DBLC_4 of DBLC_4_32 is

begin -- Architecture DBLC_4
	GOUT(0 to 15) <= GIN(0 to 15);
U2: for I in 16 to 31 generate
	U21: BLOCK1A port map(PIN(I-16),GIN(I-16),GIN(I),PHI,GOUT(I));
end generate U2;
U3: for I in 32 to 32 generate
	U31: BLOCK1 port map(PIN(I-32),PIN(I-16),GIN(I-16),GIN(I),PHI,POUT(I-32),GOUT(I));
end generate U3;
end DBLC_4;


library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.blocks.all;
entity XORSTAGE_32 is
port
(
	A: in std_logic_vector(0 to 31);
	B: in std_logic_vector(0 to 31);
	PBIT, PHI: in std_logic;
	CARRY: in std_logic_vector(0 to 32);
	SUM: out std_logic_vector(0 to 31);
	COUT: out std_logic
);
end XORSTAGE_32;
architecture XORSTAGE of XORSTAGE_32 is
begin -- XORSTAGE
U2:for I in 0 to 15 generate
	U22: XXOR1 port map(A(I),B(I),CARRY(I),PHI,SUM(I));
end generate U2;
U3:for I in 16 to 31 generate
	U33: XXOR2 port map(A(I),B(I),CARRY(I),PHI,SUM(I));
end generate U3;
U1: BLOCK2A port map(PBIT,CARRY(0),CARRY(32),PHI,COUT);
end XORSTAGE;

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.blocks.all;
entity PRESTAGE_32 is
port
(
	A: in std_logic_vector(0 to 31);
	B: in std_logic_vector(0 to 31);
	CIN: in std_logic;
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 31);
	GOUT: out std_logic_vector(0 to 32)
);
end PRESTAGE_32;
architecture PRESTAGE of PRESTAGE_32 is
begin  -- PRESTAGE
U1:for I in 0 to 31 generate
	U11: BLOCK0 port map(A(I),B(I),PHI,POUT(I),GOUT(I+1));
end generate U1;
U2: INVBLOCK port map(CIN,PHI,GOUT(0));
end PRESTAGE;

-- The DBLC-tree: All levels encapsulated
library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.blocks.all;
entity DBLCTREE_32 is
port
(
	PIN:in std_logic_vector(0 to 31);
	GIN:in std_logic_vector(0 to 32);
	PHI:in std_logic;
	GOUT:out std_logic_vector(0 to 32);
	POUT:out std_logic_vector(0 to 0)
);
end DBLCTREE_32;

architecture DBLCTREE of DBLCTREE_32 is

signal INTPROP_0: std_logic_vector(0 to 30);
signal INTGEN_0: std_logic_vector(0 to 32);
signal INTPROP_1: std_logic_vector(0 to 28);
signal INTGEN_1: std_logic_vector(0 to 32);
signal INTPROP_2: std_logic_vector(0 to 24);
signal INTGEN_2: std_logic_vector(0 to 32);
signal INTPROP_3: std_logic_vector(0 to 16);
signal INTGEN_3: std_logic_vector(0 to 32);
begin -- Architecture DBLCTREE
U_0: DBLC_0_32 port map(PIN=>PIN,GIN=>GIN,PHI=>PHI,POUT=>INTPROP_0,GOUT=>INTGEN_0);
U_1: DBLC_1_32 port map(PIN=>INTPROP_0,GIN=>INTGEN_0,PHI=>PHI,POUT=>INTPROP_1,GOUT=>INTGEN_1);
U_2: DBLC_2_32 port map(PIN=>INTPROP_1,GIN=>INTGEN_1,PHI=>PHI,POUT=>INTPROP_2,GOUT=>INTGEN_2);
U_3: DBLC_3_32 port map(PIN=>INTPROP_2,GIN=>INTGEN_2,PHI=>PHI,POUT=>INTPROP_3,GOUT=>INTGEN_3);
U_4: DBLC_4_32 port map(PIN=>INTPROP_3,GIN=>INTGEN_3,PHI=>PHI,POUT=>POUT,GOUT=>GOUT);
end DBLCTREE;

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.blocks.all;
entity DBLCADDER_32_32 is
port
(
	OPA:in std_logic_vector(0 to 31);
	OPB:in std_logic_vector(0 to 31);
	CIN:in std_logic;
	PHI:in std_logic;
	SUM:out std_logic_vector(0 to 31);
	COUT:out std_logic
);
end DBLCADDER_32_32;
architecture DBLCADDER of DBLCADDER_32_32 is

signal INTPROP: std_logic_vector(0 to 31);
signal INTGEN: std_logic_vector(0 to 32);
signal PBIT:std_logic_vector(0 to 0);
signal CARRY: std_logic_vector(0 to 32);

begin -- Architecture DBLCADDER

U1: PRESTAGE_32 port map(OPA,OPB,CIN,PHI,INTPROP,INTGEN);
U2: DBLCTREE_32 port map(INTPROP,INTGEN,PHI,CARRY,PBIT);
U3: XORSTAGE_32 port map(OPA(0 to 31),OPB(0 to 31),PBIT(0),PHI,CARRY(0 to 32),SUM,COUT);
end DBLCADDER;
------------------------------------------------------------
-- END: Architectures used with the DBLC adder
------------------------------------------------------------



library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.blocks.all;
entity PRESTAGE_128 is
port
(
	A: in std_logic_vector(0 to 127);
	B: in std_logic_vector(0 to 127);
	CIN: in std_logic;
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 127);
	GOUT: out std_logic_vector(0 to 128)
);
end PRESTAGE_128;
architecture PRESTAGE of PRESTAGE_128 is

begin  -- PRESTAGE
U1:for I in 0 to 127 generate
	U11: BLOCK0 port map(A(I),B(I),PHI,POUT(I),GOUT(I+1));
end generate U1;
U2: INVBLOCK port map(CIN,PHI,GOUT(0));
end PRESTAGE;
-- The DBLC-tree: Level 0

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.blocks.all;
entity DBLC_0_128 is
port
(
	PIN: in std_logic_vector(0 to 127);
	GIN: in std_logic_vector(0 to 128);
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 126);
	GOUT: out std_logic_vector(0 to 128)
);
end DBLC_0_128;

architecture DBLC_0 of DBLC_0_128 is

begin -- Architecture DBLC_0
U1: for I in 0 to 0 generate
	U11: INVBLOCK port map(GIN(I),PHI,GOUT(I));
end generate U1;
U2: for I in 1 to 1 generate
	U21: BLOCK1A port map(PIN(I-1),GIN(I-1),GIN(I),PHI,GOUT(I));
end generate U2;
U3: for I in 2 to 128 generate
	U31: BLOCK1 port map(PIN(I-2),PIN(I-1),GIN(I-1),GIN(I),PHI,POUT(I-2),GOUT(I));
end generate U3;
end DBLC_0;

-- The DBLC-tree: Level 1

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.blocks.all;
entity DBLC_1_128 is
port
(
	PIN: in std_logic_vector(0 to 126);
	GIN: in std_logic_vector(0 to 128);
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 124);
	GOUT: out std_logic_vector(0 to 128)
);
end DBLC_1_128;

architecture DBLC_1 of DBLC_1_128 is

begin -- Architecture DBLC_1
U1: for I in 0 to 1 generate
	U11: INVBLOCK port map(GIN(I),PHI,GOUT(I));
end generate U1;
U2: for I in 2 to 3 generate
	U21: BLOCK2A port map(PIN(I-2),GIN(I-2),GIN(I),PHI,GOUT(I));
end generate U2;
U3: for I in 4 to 128 generate
	U31: BLOCK2 port map(PIN(I-4),PIN(I-2),GIN(I-2),GIN(I),PHI,POUT(I-4),GOUT(I));
end generate U3;
end DBLC_1;

-- The DBLC-tree: Level 2

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.blocks.all;
entity DBLC_2_128 is
port
(
	PIN: in std_logic_vector(0 to 124);
	GIN: in std_logic_vector(0 to 128);
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 120);
	GOUT: out std_logic_vector(0 to 128)
);
end DBLC_2_128;

architecture DBLC_2 of DBLC_2_128 is

begin -- Architecture DBLC_2
U1: for I in 0 to 3 generate
	U11: INVBLOCK port map(GIN(I),PHI,GOUT(I));
end generate U1;
U2: for I in 4 to 7 generate
	U21: BLOCK1A port map(PIN(I-4),GIN(I-4),GIN(I),PHI,GOUT(I));
end generate U2;
U3: for I in 8 to 128 generate
	U31: BLOCK1 port map(PIN(I-8),PIN(I-4),GIN(I-4),GIN(I),PHI,POUT(I-8),GOUT(I));
end generate U3;
end DBLC_2;

-- The DBLC-tree: Level 3

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.blocks.all;
entity DBLC_3_128 is
port
(
	PIN: in std_logic_vector(0 to 120);
	GIN: in std_logic_vector(0 to 128);
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 112);
	GOUT: out std_logic_vector(0 to 128)
);
end DBLC_3_128;

architecture DBLC_3 of DBLC_3_128 is

begin -- Architecture DBLC_3
U1: for I in 0 to 7 generate
	U11: INVBLOCK port map(GIN(I),PHI,GOUT(I));
end generate U1;
U2: for I in 8 to 15 generate
	U21: BLOCK2A port map(PIN(I-8),GIN(I-8),GIN(I),PHI,GOUT(I));
end generate U2;
U3: for I in 16 to 128 generate
	U31: BLOCK2 port map(PIN(I-16),PIN(I-8),GIN(I-8),GIN(I),PHI,POUT(I-16),GOUT(I));
end generate U3;
end DBLC_3;

-- The DBLC-tree: Level 4

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.blocks.all;
entity DBLC_4_128 is
port
(
	PIN: in std_logic_vector(0 to 112);
	GIN: in std_logic_vector(0 to 128);
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 96);
	GOUT: out std_logic_vector(0 to 128)
);
end DBLC_4_128;

architecture DBLC_4 of DBLC_4_128 is

begin -- Architecture DBLC_4
U1: for I in 0 to 15 generate
	U11: INVBLOCK port map(GIN(I),PHI,GOUT(I));
end generate U1;
U2: for I in 16 to 31 generate
	U21: BLOCK1A port map(PIN(I-16),GIN(I-16),GIN(I),PHI,GOUT(I));
end generate U2;
U3: for I in 32 to 128 generate
	U31: BLOCK1 port map(PIN(I-32),PIN(I-16),GIN(I-16),GIN(I),PHI,POUT(I-32),GOUT(I));
end generate U3;
end DBLC_4;

-- The DBLC-tree: Level 5

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.blocks.all;
entity DBLC_5_128 is
port
(
	PIN: in std_logic_vector(0 to 96);
	GIN: in std_logic_vector(0 to 128);
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 64);
	GOUT: out std_logic_vector(0 to 128)
);
end DBLC_5_128;

architecture DBLC_5 of DBLC_5_128 is

begin -- Architecture DBLC_5
U1: for I in 0 to 31 generate
	U11: INVBLOCK port map(GIN(I),PHI,GOUT(I));
end generate U1;
U2: for I in 32 to 63 generate
	U21: BLOCK2A port map(PIN(I-32),GIN(I-32),GIN(I),PHI,GOUT(I));
end generate U2;
U3: for I in 64 to 128 generate
	U31: BLOCK2 port map(PIN(I-64),PIN(I-32),GIN(I-32),GIN(I),PHI,POUT(I-64),GOUT(I));
end generate U3;
end DBLC_5;

-- The DBLC-tree: Level 6

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.blocks.all;
entity DBLC_6_128 is
port
(
	PIN: in std_logic_vector(0 to 64);
	GIN: in std_logic_vector(0 to 128);
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 0);
	GOUT: out std_logic_vector(0 to 128)
);
end DBLC_6_128;

architecture DBLC_6 of DBLC_6_128 is

begin -- Architecture DBLC_6
	GOUT(0 to 63) <= GIN(0 to 63);
U2: for I in 64 to 127 generate
	U21: BLOCK1A port map(PIN(I-64),GIN(I-64),GIN(I),PHI,GOUT(I));
end generate U2;
U3: for I in 128 to 128 generate
	U31: BLOCK1 port map(PIN(I-128),PIN(I-64),GIN(I-64),GIN(I),PHI,POUT(I-128),GOUT(I));
end generate U3;
end DBLC_6;

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.blocks.all;
entity XORSTAGE_128 is
port
(
	A: in std_logic_vector(0 to 127);
	B: in std_logic_vector(0 to 127);
	PBIT, PHI: in std_logic;
	CARRY: in std_logic_vector(0 to 128);
	SUM: out std_logic_vector(0 to 127);
	COUT: out std_logic
);
end XORSTAGE_128;
architecture XORSTAGE of XORSTAGE_128 is

begin -- XORSTAGE
U2:for I in 0 to 63 generate
	U22: XXOR1 port map(A(I),B(I),CARRY(I),PHI,SUM(I));
end generate U2;
U3:for I in 64 to 127 generate
	U33: XXOR2 port map(A(I),B(I),CARRY(I),PHI,SUM(I));
end generate U3;
U1: BLOCK2A port map(PBIT,CARRY(0),CARRY(128),PHI,COUT);
end XORSTAGE;

-- The DBLC-tree: All levels encapsulated

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.blocks.all;
entity DBLCTREE_128 is
port
(
	PIN:in std_logic_vector(0 to 127);
	GIN:in std_logic_vector(0 to 128);
	PHI:in std_logic;
	GOUT:out std_logic_vector(0 to 128);
	POUT:out std_logic_vector(0 to 0)
);
end DBLCTREE_128;

architecture DBLCTREE of DBLCTREE_128 is

signal INTPROP_0: std_logic_vector(0 to 126);
signal INTGEN_0: std_logic_vector(0 to 128);
signal INTPROP_1: std_logic_vector(0 to 124);
signal INTGEN_1: std_logic_vector(0 to 128);
signal INTPROP_2: std_logic_vector(0 to 120);
signal INTGEN_2: std_logic_vector(0 to 128);
signal INTPROP_3: std_logic_vector(0 to 112);
signal INTGEN_3: std_logic_vector(0 to 128);
signal INTPROP_4: std_logic_vector(0 to 96);
signal INTGEN_4: std_logic_vector(0 to 128);
signal INTPROP_5: std_logic_vector(0 to 64);
signal INTGEN_5: std_logic_vector(0 to 128);
begin -- Architecture DBLCTREE
U_0: DBLC_0_128 port map(PIN=>PIN,GIN=>GIN,PHI=>PHI,POUT=>INTPROP_0,GOUT=>INTGEN_0);
U_1: DBLC_1_128 port map(PIN=>INTPROP_0,GIN=>INTGEN_0,PHI=>PHI,POUT=>INTPROP_1,GOUT=>INTGEN_1);
U_2: DBLC_2_128 port map(PIN=>INTPROP_1,GIN=>INTGEN_1,PHI=>PHI,POUT=>INTPROP_2,GOUT=>INTGEN_2);
U_3: DBLC_3_128 port map(PIN=>INTPROP_2,GIN=>INTGEN_2,PHI=>PHI,POUT=>INTPROP_3,GOUT=>INTGEN_3);
U_4: DBLC_4_128 port map(PIN=>INTPROP_3,GIN=>INTGEN_3,PHI=>PHI,POUT=>INTPROP_4,GOUT=>INTGEN_4);
U_5: DBLC_5_128 port map(PIN=>INTPROP_4,GIN=>INTGEN_4,PHI=>PHI,POUT=>INTPROP_5,GOUT=>INTGEN_5);
U_6: DBLC_6_128 port map(PIN=>INTPROP_5,GIN=>INTGEN_5,PHI=>PHI,POUT=>POUT,GOUT=>GOUT);
end DBLCTREE;

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.blocks.all;
entity DBLCADDER_128_128 is
port
(
	OPA:in std_logic_vector(0 to 127);
	OPB:in std_logic_vector(0 to 127);
	CIN:in std_logic;
	PHI:in std_logic;
	SUM:out std_logic_vector(0 to 127);
	COUT:out std_logic
);
end DBLCADDER_128_128;
architecture DBLCADDER of DBLCADDER_128_128 is

signal INTPROP: std_logic_vector(0 to 127);
signal INTGEN: std_logic_vector(0 to 128);
signal PBIT:std_logic_vector(0 to 0);
signal CARRY: std_logic_vector(0 to 128);

begin -- Architecture DBLCADDER

U1: PRESTAGE_128 port map(OPA,OPB,CIN,PHI,INTPROP,INTGEN);
U2: DBLCTREE_128 port map(INTPROP,INTGEN,PHI,CARRY,PBIT);
U3: XORSTAGE_128 port map(OPA(0 to 127),OPB(0 to 127),PBIT(0),PHI,CARRY(0 to 128),SUM,COUT);
end DBLCADDER;




--
-- Modified Booth algorithm architecture
--
library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.blocks.all;
entity BOOTHCODER_18_18 is
port
(
		OPA: in std_logic_vector(0 to 17);
		OPB: in std_logic_vector(0 to 17);
		SUMMAND: out std_logic_vector(0 to 188)
);
end BOOTHCODER_18_18;
------------------------------------------------------------
-- END: Entities used within the Modified Booth Recoding
------------------------------------------------------------
architecture BOOTHCODER of BOOTHCODER_18_18 is

-- Components used in the architecture

-- Internal signal in Booth structure

signal INV_MULTIPLICAND: std_logic_vector(0 to 17);
signal INT_MULTIPLIER: std_logic_vector(0 to 35);
signal LOGIC_ONE, LOGIC_ZERO: std_logic;
begin
LOGIC_ONE <= '1';
LOGIC_ZERO <= '0';
-- Begin decoder block 1
DEC_0:DECODER -- Decoder of multiplier operand
	port map
	(
		INA => LOGIC_ZERO,INB => OPB(0),INC => OPB(1),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3)
	);
-- End decoder block 1
-- Begin partial product 1
INV_MULTIPLICAND(0) <= NOT OPA(0);
PPL_0:PP_LOW
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(0)
	);
RGATE_0:R_GATE
	port map
	(
		INA => LOGIC_ZERO,INB => OPB(0),INC => OPB(1),
		PPBIT => SUMMAND(1)
	);
INV_MULTIPLICAND(1) <= NOT OPA(1);
PPM_0:PP_MIDDLE
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		INC => OPA(1),IND => INV_MULTIPLICAND(1),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(2)
	);
INV_MULTIPLICAND(2) <= NOT OPA(2);
PPM_1:PP_MIDDLE
	port map
	(
		INA => OPA(1),INB => INV_MULTIPLICAND(1),
		INC => OPA(2),IND => INV_MULTIPLICAND(2),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(3)
	);
INV_MULTIPLICAND(3) <= NOT OPA(3);
PPM_2:PP_MIDDLE
	port map
	(
		INA => OPA(2),INB => INV_MULTIPLICAND(2),
		INC => OPA(3),IND => INV_MULTIPLICAND(3),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(6)
	);
INV_MULTIPLICAND(4) <= NOT OPA(4);
PPM_3:PP_MIDDLE
	port map
	(
		INA => OPA(3),INB => INV_MULTIPLICAND(3),
		INC => OPA(4),IND => INV_MULTIPLICAND(4),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(8)
	);
INV_MULTIPLICAND(5) <= NOT OPA(5);
PPM_4:PP_MIDDLE
	port map
	(
		INA => OPA(4),INB => INV_MULTIPLICAND(4),
		INC => OPA(5),IND => INV_MULTIPLICAND(5),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(12)
	);
INV_MULTIPLICAND(6) <= NOT OPA(6);
PPM_5:PP_MIDDLE
	port map
	(
		INA => OPA(5),INB => INV_MULTIPLICAND(5),
		INC => OPA(6),IND => INV_MULTIPLICAND(6),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(15)
	);
INV_MULTIPLICAND(7) <= NOT OPA(7);
PPM_6:PP_MIDDLE
	port map
	(
		INA => OPA(6),INB => INV_MULTIPLICAND(6),
		INC => OPA(7),IND => INV_MULTIPLICAND(7),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(20)
	);
INV_MULTIPLICAND(8) <= NOT OPA(8);
PPM_7:PP_MIDDLE
	port map
	(
		INA => OPA(7),INB => INV_MULTIPLICAND(7),
		INC => OPA(8),IND => INV_MULTIPLICAND(8),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(24)
	);
INV_MULTIPLICAND(9) <= NOT OPA(9);
PPM_8:PP_MIDDLE
	port map
	(
		INA => OPA(8),INB => INV_MULTIPLICAND(8),
		INC => OPA(9),IND => INV_MULTIPLICAND(9),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(30)
	);
INV_MULTIPLICAND(10) <= NOT OPA(10);
PPM_9:PP_MIDDLE
	port map
	(
		INA => OPA(9),INB => INV_MULTIPLICAND(9),
		INC => OPA(10),IND => INV_MULTIPLICAND(10),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(35)
	);
INV_MULTIPLICAND(11) <= NOT OPA(11);
PPM_10:PP_MIDDLE
	port map
	(
		INA => OPA(10),INB => INV_MULTIPLICAND(10),
		INC => OPA(11),IND => INV_MULTIPLICAND(11),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(42)
	);
INV_MULTIPLICAND(12) <= NOT OPA(12);
PPM_11:PP_MIDDLE
	port map
	(
		INA => OPA(11),INB => INV_MULTIPLICAND(11),
		INC => OPA(12),IND => INV_MULTIPLICAND(12),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(48)
	);
INV_MULTIPLICAND(13) <= NOT OPA(13);
PPM_12:PP_MIDDLE
	port map
	(
		INA => OPA(12),INB => INV_MULTIPLICAND(12),
		INC => OPA(13),IND => INV_MULTIPLICAND(13),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(56)
	);
INV_MULTIPLICAND(14) <= NOT OPA(14);
PPM_13:PP_MIDDLE
	port map
	(
		INA => OPA(13),INB => INV_MULTIPLICAND(13),
		INC => OPA(14),IND => INV_MULTIPLICAND(14),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(63)
	);
INV_MULTIPLICAND(15) <= NOT OPA(15);
PPM_14:PP_MIDDLE
	port map
	(
		INA => OPA(14),INB => INV_MULTIPLICAND(14),
		INC => OPA(15),IND => INV_MULTIPLICAND(15),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(72)
	);
INV_MULTIPLICAND(16) <= NOT OPA(16);
PPM_15:PP_MIDDLE
	port map
	(
		INA => OPA(15),INB => INV_MULTIPLICAND(15),
		INC => OPA(16),IND => INV_MULTIPLICAND(16),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(80)
	);
INV_MULTIPLICAND(17) <= NOT OPA(17);
PPM_16:PP_MIDDLE
	port map
	(
		INA => OPA(16),INB => INV_MULTIPLICAND(16),
		INC => OPA(17),IND => INV_MULTIPLICAND(17),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(90)
	);
PPH_0:PP_HIGH
	port map
	(
		INA => OPA(17),INB => INV_MULTIPLICAND(17),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(99)
	);
SUMMAND(100) <= '1';
-- Begin partial product 1
-- Begin decoder block 2
DEC_1:DECODER -- Decoder of multiplier operand
	port map
	(
		INA => OPB(1),INB => OPB(2),INC => OPB(3),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7)
	);
-- End decoder block 2
-- Begin partial product 2
PPL_1:PP_LOW
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(4)
	);
RGATE_1:R_GATE
	port map
	(
		INA => OPB(1),INB => OPB(2),INC => OPB(3),
		PPBIT => SUMMAND(5)
	);
PPM_17:PP_MIDDLE
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		INC => OPA(1),IND => INV_MULTIPLICAND(1),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(7)
	);
PPM_18:PP_MIDDLE
	port map
	(
		INA => OPA(1),INB => INV_MULTIPLICAND(1),
		INC => OPA(2),IND => INV_MULTIPLICAND(2),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(9)
	);
PPM_19:PP_MIDDLE
	port map
	(
		INA => OPA(2),INB => INV_MULTIPLICAND(2),
		INC => OPA(3),IND => INV_MULTIPLICAND(3),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(13)
	);
PPM_20:PP_MIDDLE
	port map
	(
		INA => OPA(3),INB => INV_MULTIPLICAND(3),
		INC => OPA(4),IND => INV_MULTIPLICAND(4),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(16)
	);
PPM_21:PP_MIDDLE
	port map
	(
		INA => OPA(4),INB => INV_MULTIPLICAND(4),
		INC => OPA(5),IND => INV_MULTIPLICAND(5),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(21)
	);
PPM_22:PP_MIDDLE
	port map
	(
		INA => OPA(5),INB => INV_MULTIPLICAND(5),
		INC => OPA(6),IND => INV_MULTIPLICAND(6),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(25)
	);
PPM_23:PP_MIDDLE
	port map
	(
		INA => OPA(6),INB => INV_MULTIPLICAND(6),
		INC => OPA(7),IND => INV_MULTIPLICAND(7),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(31)
	);
PPM_24:PP_MIDDLE
	port map
	(
		INA => OPA(7),INB => INV_MULTIPLICAND(7),
		INC => OPA(8),IND => INV_MULTIPLICAND(8),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(36)
	);
PPM_25:PP_MIDDLE
	port map
	(
		INA => OPA(8),INB => INV_MULTIPLICAND(8),
		INC => OPA(9),IND => INV_MULTIPLICAND(9),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(43)
	);
PPM_26:PP_MIDDLE
	port map
	(
		INA => OPA(9),INB => INV_MULTIPLICAND(9),
		INC => OPA(10),IND => INV_MULTIPLICAND(10),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(49)
	);
PPM_27:PP_MIDDLE
	port map
	(
		INA => OPA(10),INB => INV_MULTIPLICAND(10),
		INC => OPA(11),IND => INV_MULTIPLICAND(11),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(57)
	);
PPM_28:PP_MIDDLE
	port map
	(
		INA => OPA(11),INB => INV_MULTIPLICAND(11),
		INC => OPA(12),IND => INV_MULTIPLICAND(12),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(64)
	);
PPM_29:PP_MIDDLE
	port map
	(
		INA => OPA(12),INB => INV_MULTIPLICAND(12),
		INC => OPA(13),IND => INV_MULTIPLICAND(13),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(73)
	);
PPM_30:PP_MIDDLE
	port map
	(
		INA => OPA(13),INB => INV_MULTIPLICAND(13),
		INC => OPA(14),IND => INV_MULTIPLICAND(14),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(81)
	);
PPM_31:PP_MIDDLE
	port map
	(
		INA => OPA(14),INB => INV_MULTIPLICAND(14),
		INC => OPA(15),IND => INV_MULTIPLICAND(15),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(91)
	);
PPM_32:PP_MIDDLE
	port map
	(
		INA => OPA(15),INB => INV_MULTIPLICAND(15),
		INC => OPA(16),IND => INV_MULTIPLICAND(16),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(101)
	);
PPM_33:PP_MIDDLE
	port map
	(
		INA => OPA(16),INB => INV_MULTIPLICAND(16),
		INC => OPA(17),IND => INV_MULTIPLICAND(17),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(109)
	);
SUMMAND(110) <= LOGIC_ONE;
PPH_1:PP_HIGH
	port map
	(
		INA => OPA(17),INB => INV_MULTIPLICAND(17),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(118)
	);
-- Begin partial product 2
-- Begin decoder block 3
DEC_2:DECODER -- Decoder of multiplier operand
	port map
	(
		INA => OPB(3),INB => OPB(4),INC => OPB(5),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11)
	);
-- End decoder block 3
-- Begin partial product 3
PPL_2:PP_LOW
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(10)
	);
RGATE_2:R_GATE
	port map
	(
		INA => OPB(3),INB => OPB(4),INC => OPB(5),
		PPBIT => SUMMAND(11)
	);
PPM_34:PP_MIDDLE
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		INC => OPA(1),IND => INV_MULTIPLICAND(1),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(14)
	);
PPM_35:PP_MIDDLE
	port map
	(
		INA => OPA(1),INB => INV_MULTIPLICAND(1),
		INC => OPA(2),IND => INV_MULTIPLICAND(2),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(17)
	);
PPM_36:PP_MIDDLE
	port map
	(
		INA => OPA(2),INB => INV_MULTIPLICAND(2),
		INC => OPA(3),IND => INV_MULTIPLICAND(3),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(22)
	);
PPM_37:PP_MIDDLE
	port map
	(
		INA => OPA(3),INB => INV_MULTIPLICAND(3),
		INC => OPA(4),IND => INV_MULTIPLICAND(4),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(26)
	);
PPM_38:PP_MIDDLE
	port map
	(
		INA => OPA(4),INB => INV_MULTIPLICAND(4),
		INC => OPA(5),IND => INV_MULTIPLICAND(5),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(32)
	);
PPM_39:PP_MIDDLE
	port map
	(
		INA => OPA(5),INB => INV_MULTIPLICAND(5),
		INC => OPA(6),IND => INV_MULTIPLICAND(6),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(37)
	);
PPM_40:PP_MIDDLE
	port map
	(
		INA => OPA(6),INB => INV_MULTIPLICAND(6),
		INC => OPA(7),IND => INV_MULTIPLICAND(7),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(44)
	);
PPM_41:PP_MIDDLE
	port map
	(
		INA => OPA(7),INB => INV_MULTIPLICAND(7),
		INC => OPA(8),IND => INV_MULTIPLICAND(8),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(50)
	);
PPM_42:PP_MIDDLE
	port map
	(
		INA => OPA(8),INB => INV_MULTIPLICAND(8),
		INC => OPA(9),IND => INV_MULTIPLICAND(9),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(58)
	);
PPM_43:PP_MIDDLE
	port map
	(
		INA => OPA(9),INB => INV_MULTIPLICAND(9),
		INC => OPA(10),IND => INV_MULTIPLICAND(10),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(65)
	);
PPM_44:PP_MIDDLE
	port map
	(
		INA => OPA(10),INB => INV_MULTIPLICAND(10),
		INC => OPA(11),IND => INV_MULTIPLICAND(11),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(74)
	);
PPM_45:PP_MIDDLE
	port map
	(
		INA => OPA(11),INB => INV_MULTIPLICAND(11),
		INC => OPA(12),IND => INV_MULTIPLICAND(12),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(82)
	);
PPM_46:PP_MIDDLE
	port map
	(
		INA => OPA(12),INB => INV_MULTIPLICAND(12),
		INC => OPA(13),IND => INV_MULTIPLICAND(13),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(92)
	);
PPM_47:PP_MIDDLE
	port map
	(
		INA => OPA(13),INB => INV_MULTIPLICAND(13),
		INC => OPA(14),IND => INV_MULTIPLICAND(14),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(102)
	);
PPM_48:PP_MIDDLE
	port map
	(
		INA => OPA(14),INB => INV_MULTIPLICAND(14),
		INC => OPA(15),IND => INV_MULTIPLICAND(15),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(111)
	);
PPM_49:PP_MIDDLE
	port map
	(
		INA => OPA(15),INB => INV_MULTIPLICAND(15),
		INC => OPA(16),IND => INV_MULTIPLICAND(16),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(119)
	);
PPM_50:PP_MIDDLE
	port map
	(
		INA => OPA(16),INB => INV_MULTIPLICAND(16),
		INC => OPA(17),IND => INV_MULTIPLICAND(17),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(126)
	);
SUMMAND(127) <= LOGIC_ONE;
PPH_2:PP_HIGH
	port map
	(
		INA => OPA(17),INB => INV_MULTIPLICAND(17),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(134)
	);
-- Begin partial product 3
-- Begin decoder block 4
DEC_3:DECODER -- Decoder of multiplier operand
	port map
	(
		INA => OPB(5),INB => OPB(6),INC => OPB(7),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15)
	);
-- End decoder block 4
-- Begin partial product 4
PPL_3:PP_LOW
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(18)
	);
RGATE_3:R_GATE
	port map
	(
		INA => OPB(5),INB => OPB(6),INC => OPB(7),
		PPBIT => SUMMAND(19)
	);
PPM_51:PP_MIDDLE
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		INC => OPA(1),IND => INV_MULTIPLICAND(1),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(23)
	);
PPM_52:PP_MIDDLE
	port map
	(
		INA => OPA(1),INB => INV_MULTIPLICAND(1),
		INC => OPA(2),IND => INV_MULTIPLICAND(2),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(27)
	);
PPM_53:PP_MIDDLE
	port map
	(
		INA => OPA(2),INB => INV_MULTIPLICAND(2),
		INC => OPA(3),IND => INV_MULTIPLICAND(3),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(33)
	);
PPM_54:PP_MIDDLE
	port map
	(
		INA => OPA(3),INB => INV_MULTIPLICAND(3),
		INC => OPA(4),IND => INV_MULTIPLICAND(4),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(38)
	);
PPM_55:PP_MIDDLE
	port map
	(
		INA => OPA(4),INB => INV_MULTIPLICAND(4),
		INC => OPA(5),IND => INV_MULTIPLICAND(5),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(45)
	);
PPM_56:PP_MIDDLE
	port map
	(
		INA => OPA(5),INB => INV_MULTIPLICAND(5),
		INC => OPA(6),IND => INV_MULTIPLICAND(6),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(51)
	);
PPM_57:PP_MIDDLE
	port map
	(
		INA => OPA(6),INB => INV_MULTIPLICAND(6),
		INC => OPA(7),IND => INV_MULTIPLICAND(7),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(59)
	);
PPM_58:PP_MIDDLE
	port map
	(
		INA => OPA(7),INB => INV_MULTIPLICAND(7),
		INC => OPA(8),IND => INV_MULTIPLICAND(8),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(66)
	);
PPM_59:PP_MIDDLE
	port map
	(
		INA => OPA(8),INB => INV_MULTIPLICAND(8),
		INC => OPA(9),IND => INV_MULTIPLICAND(9),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(75)
	);
PPM_60:PP_MIDDLE
	port map
	(
		INA => OPA(9),INB => INV_MULTIPLICAND(9),
		INC => OPA(10),IND => INV_MULTIPLICAND(10),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(83)
	);
PPM_61:PP_MIDDLE
	port map
	(
		INA => OPA(10),INB => INV_MULTIPLICAND(10),
		INC => OPA(11),IND => INV_MULTIPLICAND(11),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(93)
	);
PPM_62:PP_MIDDLE
	port map
	(
		INA => OPA(11),INB => INV_MULTIPLICAND(11),
		INC => OPA(12),IND => INV_MULTIPLICAND(12),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(103)
	);
PPM_63:PP_MIDDLE
	port map
	(
		INA => OPA(12),INB => INV_MULTIPLICAND(12),
		INC => OPA(13),IND => INV_MULTIPLICAND(13),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(112)
	);
PPM_64:PP_MIDDLE
	port map
	(
		INA => OPA(13),INB => INV_MULTIPLICAND(13),
		INC => OPA(14),IND => INV_MULTIPLICAND(14),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(120)
	);
PPM_65:PP_MIDDLE
	port map
	(
		INA => OPA(14),INB => INV_MULTIPLICAND(14),
		INC => OPA(15),IND => INV_MULTIPLICAND(15),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(128)
	);
PPM_66:PP_MIDDLE
	port map
	(
		INA => OPA(15),INB => INV_MULTIPLICAND(15),
		INC => OPA(16),IND => INV_MULTIPLICAND(16),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(135)
	);
PPM_67:PP_MIDDLE
	port map
	(
		INA => OPA(16),INB => INV_MULTIPLICAND(16),
		INC => OPA(17),IND => INV_MULTIPLICAND(17),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(141)
	);
SUMMAND(142) <= LOGIC_ONE;
PPH_3:PP_HIGH
	port map
	(
		INA => OPA(17),INB => INV_MULTIPLICAND(17),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(148)
	);
-- Begin partial product 4
-- Begin decoder block 5
DEC_4:DECODER -- Decoder of multiplier operand
	port map
	(
		INA => OPB(7),INB => OPB(8),INC => OPB(9),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19)
	);
-- End decoder block 5
-- Begin partial product 5
PPL_4:PP_LOW
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(28)
	);
RGATE_4:R_GATE
	port map
	(
		INA => OPB(7),INB => OPB(8),INC => OPB(9),
		PPBIT => SUMMAND(29)
	);
PPM_68:PP_MIDDLE
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		INC => OPA(1),IND => INV_MULTIPLICAND(1),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(34)
	);
PPM_69:PP_MIDDLE
	port map
	(
		INA => OPA(1),INB => INV_MULTIPLICAND(1),
		INC => OPA(2),IND => INV_MULTIPLICAND(2),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(39)
	);
PPM_70:PP_MIDDLE
	port map
	(
		INA => OPA(2),INB => INV_MULTIPLICAND(2),
		INC => OPA(3),IND => INV_MULTIPLICAND(3),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(46)
	);
PPM_71:PP_MIDDLE
	port map
	(
		INA => OPA(3),INB => INV_MULTIPLICAND(3),
		INC => OPA(4),IND => INV_MULTIPLICAND(4),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(52)
	);
PPM_72:PP_MIDDLE
	port map
	(
		INA => OPA(4),INB => INV_MULTIPLICAND(4),
		INC => OPA(5),IND => INV_MULTIPLICAND(5),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(60)
	);
PPM_73:PP_MIDDLE
	port map
	(
		INA => OPA(5),INB => INV_MULTIPLICAND(5),
		INC => OPA(6),IND => INV_MULTIPLICAND(6),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(67)
	);
PPM_74:PP_MIDDLE
	port map
	(
		INA => OPA(6),INB => INV_MULTIPLICAND(6),
		INC => OPA(7),IND => INV_MULTIPLICAND(7),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(76)
	);
PPM_75:PP_MIDDLE
	port map
	(
		INA => OPA(7),INB => INV_MULTIPLICAND(7),
		INC => OPA(8),IND => INV_MULTIPLICAND(8),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(84)
	);
PPM_76:PP_MIDDLE
	port map
	(
		INA => OPA(8),INB => INV_MULTIPLICAND(8),
		INC => OPA(9),IND => INV_MULTIPLICAND(9),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(94)
	);
PPM_77:PP_MIDDLE
	port map
	(
		INA => OPA(9),INB => INV_MULTIPLICAND(9),
		INC => OPA(10),IND => INV_MULTIPLICAND(10),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(104)
	);
PPM_78:PP_MIDDLE
	port map
	(
		INA => OPA(10),INB => INV_MULTIPLICAND(10),
		INC => OPA(11),IND => INV_MULTIPLICAND(11),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(113)
	);
PPM_79:PP_MIDDLE
	port map
	(
		INA => OPA(11),INB => INV_MULTIPLICAND(11),
		INC => OPA(12),IND => INV_MULTIPLICAND(12),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(121)
	);
PPM_80:PP_MIDDLE
	port map
	(
		INA => OPA(12),INB => INV_MULTIPLICAND(12),
		INC => OPA(13),IND => INV_MULTIPLICAND(13),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(129)
	);
PPM_81:PP_MIDDLE
	port map
	(
		INA => OPA(13),INB => INV_MULTIPLICAND(13),
		INC => OPA(14),IND => INV_MULTIPLICAND(14),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(136)
	);
PPM_82:PP_MIDDLE
	port map
	(
		INA => OPA(14),INB => INV_MULTIPLICAND(14),
		INC => OPA(15),IND => INV_MULTIPLICAND(15),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(143)
	);
PPM_83:PP_MIDDLE
	port map
	(
		INA => OPA(15),INB => INV_MULTIPLICAND(15),
		INC => OPA(16),IND => INV_MULTIPLICAND(16),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(149)
	);
PPM_84:PP_MIDDLE
	port map
	(
		INA => OPA(16),INB => INV_MULTIPLICAND(16),
		INC => OPA(17),IND => INV_MULTIPLICAND(17),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(154)
	);
SUMMAND(155) <= LOGIC_ONE;
PPH_4:PP_HIGH
	port map
	(
		INA => OPA(17),INB => INV_MULTIPLICAND(17),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(160)
	);
-- Begin partial product 5
-- Begin decoder block 6
DEC_5:DECODER -- Decoder of multiplier operand
	port map
	(
		INA => OPB(9),INB => OPB(10),INC => OPB(11),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23)
	);
-- End decoder block 6
-- Begin partial product 6
PPL_5:PP_LOW
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(40)
	);
RGATE_5:R_GATE
	port map
	(
		INA => OPB(9),INB => OPB(10),INC => OPB(11),
		PPBIT => SUMMAND(41)
	);
PPM_85:PP_MIDDLE
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		INC => OPA(1),IND => INV_MULTIPLICAND(1),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(47)
	);
PPM_86:PP_MIDDLE
	port map
	(
		INA => OPA(1),INB => INV_MULTIPLICAND(1),
		INC => OPA(2),IND => INV_MULTIPLICAND(2),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(53)
	);
PPM_87:PP_MIDDLE
	port map
	(
		INA => OPA(2),INB => INV_MULTIPLICAND(2),
		INC => OPA(3),IND => INV_MULTIPLICAND(3),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(61)
	);
PPM_88:PP_MIDDLE
	port map
	(
		INA => OPA(3),INB => INV_MULTIPLICAND(3),
		INC => OPA(4),IND => INV_MULTIPLICAND(4),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(68)
	);
PPM_89:PP_MIDDLE
	port map
	(
		INA => OPA(4),INB => INV_MULTIPLICAND(4),
		INC => OPA(5),IND => INV_MULTIPLICAND(5),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(77)
	);
PPM_90:PP_MIDDLE
	port map
	(
		INA => OPA(5),INB => INV_MULTIPLICAND(5),
		INC => OPA(6),IND => INV_MULTIPLICAND(6),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(85)
	);
PPM_91:PP_MIDDLE
	port map
	(
		INA => OPA(6),INB => INV_MULTIPLICAND(6),
		INC => OPA(7),IND => INV_MULTIPLICAND(7),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(95)
	);
PPM_92:PP_MIDDLE
	port map
	(
		INA => OPA(7),INB => INV_MULTIPLICAND(7),
		INC => OPA(8),IND => INV_MULTIPLICAND(8),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(105)
	);
PPM_93:PP_MIDDLE
	port map
	(
		INA => OPA(8),INB => INV_MULTIPLICAND(8),
		INC => OPA(9),IND => INV_MULTIPLICAND(9),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(114)
	);
PPM_94:PP_MIDDLE
	port map
	(
		INA => OPA(9),INB => INV_MULTIPLICAND(9),
		INC => OPA(10),IND => INV_MULTIPLICAND(10),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(122)
	);
PPM_95:PP_MIDDLE
	port map
	(
		INA => OPA(10),INB => INV_MULTIPLICAND(10),
		INC => OPA(11),IND => INV_MULTIPLICAND(11),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(130)
	);
PPM_96:PP_MIDDLE
	port map
	(
		INA => OPA(11),INB => INV_MULTIPLICAND(11),
		INC => OPA(12),IND => INV_MULTIPLICAND(12),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(137)
	);
PPM_97:PP_MIDDLE
	port map
	(
		INA => OPA(12),INB => INV_MULTIPLICAND(12),
		INC => OPA(13),IND => INV_MULTIPLICAND(13),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(144)
	);
PPM_98:PP_MIDDLE
	port map
	(
		INA => OPA(13),INB => INV_MULTIPLICAND(13),
		INC => OPA(14),IND => INV_MULTIPLICAND(14),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(150)
	);
PPM_99:PP_MIDDLE
	port map
	(
		INA => OPA(14),INB => INV_MULTIPLICAND(14),
		INC => OPA(15),IND => INV_MULTIPLICAND(15),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(156)
	);
PPM_100:PP_MIDDLE
	port map
	(
		INA => OPA(15),INB => INV_MULTIPLICAND(15),
		INC => OPA(16),IND => INV_MULTIPLICAND(16),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(161)
	);
PPM_101:PP_MIDDLE
	port map
	(
		INA => OPA(16),INB => INV_MULTIPLICAND(16),
		INC => OPA(17),IND => INV_MULTIPLICAND(17),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(165)
	);
SUMMAND(166) <= LOGIC_ONE;
PPH_5:PP_HIGH
	port map
	(
		INA => OPA(17),INB => INV_MULTIPLICAND(17),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(170)
	);
-- Begin partial product 6
-- Begin decoder block 7
DEC_6:DECODER -- Decoder of multiplier operand
	port map
	(
		INA => OPB(11),INB => OPB(12),INC => OPB(13),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27)
	);
-- End decoder block 7
-- Begin partial product 7
PPL_6:PP_LOW
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(54)
	);
RGATE_6:R_GATE
	port map
	(
		INA => OPB(11),INB => OPB(12),INC => OPB(13),
		PPBIT => SUMMAND(55)
	);
PPM_102:PP_MIDDLE
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		INC => OPA(1),IND => INV_MULTIPLICAND(1),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(62)
	);
PPM_103:PP_MIDDLE
	port map
	(
		INA => OPA(1),INB => INV_MULTIPLICAND(1),
		INC => OPA(2),IND => INV_MULTIPLICAND(2),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(69)
	);
PPM_104:PP_MIDDLE
	port map
	(
		INA => OPA(2),INB => INV_MULTIPLICAND(2),
		INC => OPA(3),IND => INV_MULTIPLICAND(3),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(78)
	);
PPM_105:PP_MIDDLE
	port map
	(
		INA => OPA(3),INB => INV_MULTIPLICAND(3),
		INC => OPA(4),IND => INV_MULTIPLICAND(4),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(86)
	);
PPM_106:PP_MIDDLE
	port map
	(
		INA => OPA(4),INB => INV_MULTIPLICAND(4),
		INC => OPA(5),IND => INV_MULTIPLICAND(5),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(96)
	);
PPM_107:PP_MIDDLE
	port map
	(
		INA => OPA(5),INB => INV_MULTIPLICAND(5),
		INC => OPA(6),IND => INV_MULTIPLICAND(6),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(106)
	);
PPM_108:PP_MIDDLE
	port map
	(
		INA => OPA(6),INB => INV_MULTIPLICAND(6),
		INC => OPA(7),IND => INV_MULTIPLICAND(7),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(115)
	);
PPM_109:PP_MIDDLE
	port map
	(
		INA => OPA(7),INB => INV_MULTIPLICAND(7),
		INC => OPA(8),IND => INV_MULTIPLICAND(8),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(123)
	);
PPM_110:PP_MIDDLE
	port map
	(
		INA => OPA(8),INB => INV_MULTIPLICAND(8),
		INC => OPA(9),IND => INV_MULTIPLICAND(9),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(131)
	);
PPM_111:PP_MIDDLE
	port map
	(
		INA => OPA(9),INB => INV_MULTIPLICAND(9),
		INC => OPA(10),IND => INV_MULTIPLICAND(10),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(138)
	);
PPM_112:PP_MIDDLE
	port map
	(
		INA => OPA(10),INB => INV_MULTIPLICAND(10),
		INC => OPA(11),IND => INV_MULTIPLICAND(11),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(145)
	);
PPM_113:PP_MIDDLE
	port map
	(
		INA => OPA(11),INB => INV_MULTIPLICAND(11),
		INC => OPA(12),IND => INV_MULTIPLICAND(12),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(151)
	);
PPM_114:PP_MIDDLE
	port map
	(
		INA => OPA(12),INB => INV_MULTIPLICAND(12),
		INC => OPA(13),IND => INV_MULTIPLICAND(13),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(157)
	);
PPM_115:PP_MIDDLE
	port map
	(
		INA => OPA(13),INB => INV_MULTIPLICAND(13),
		INC => OPA(14),IND => INV_MULTIPLICAND(14),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(162)
	);
PPM_116:PP_MIDDLE
	port map
	(
		INA => OPA(14),INB => INV_MULTIPLICAND(14),
		INC => OPA(15),IND => INV_MULTIPLICAND(15),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(167)
	);
PPM_117:PP_MIDDLE
	port map
	(
		INA => OPA(15),INB => INV_MULTIPLICAND(15),
		INC => OPA(16),IND => INV_MULTIPLICAND(16),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(171)
	);
PPM_118:PP_MIDDLE
	port map
	(
		INA => OPA(16),INB => INV_MULTIPLICAND(16),
		INC => OPA(17),IND => INV_MULTIPLICAND(17),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(174)
	);
SUMMAND(175) <= LOGIC_ONE;
PPH_6:PP_HIGH
	port map
	(
		INA => OPA(17),INB => INV_MULTIPLICAND(17),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(178)
	);
-- Begin partial product 7
-- Begin decoder block 8
DEC_7:DECODER -- Decoder of multiplier operand
	port map
	(
		INA => OPB(13),INB => OPB(14),INC => OPB(15),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31)
	);
-- End decoder block 8
-- Begin partial product 8
PPL_7:PP_LOW
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(70)
	);
RGATE_7:R_GATE
	port map
	(
		INA => OPB(13),INB => OPB(14),INC => OPB(15),
		PPBIT => SUMMAND(71)
	);
PPM_119:PP_MIDDLE
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		INC => OPA(1),IND => INV_MULTIPLICAND(1),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(79)
	);
PPM_120:PP_MIDDLE
	port map
	(
		INA => OPA(1),INB => INV_MULTIPLICAND(1),
		INC => OPA(2),IND => INV_MULTIPLICAND(2),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(87)
	);
PPM_121:PP_MIDDLE
	port map
	(
		INA => OPA(2),INB => INV_MULTIPLICAND(2),
		INC => OPA(3),IND => INV_MULTIPLICAND(3),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(97)
	);
PPM_122:PP_MIDDLE
	port map
	(
		INA => OPA(3),INB => INV_MULTIPLICAND(3),
		INC => OPA(4),IND => INV_MULTIPLICAND(4),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(107)
	);
PPM_123:PP_MIDDLE
	port map
	(
		INA => OPA(4),INB => INV_MULTIPLICAND(4),
		INC => OPA(5),IND => INV_MULTIPLICAND(5),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(116)
	);
PPM_124:PP_MIDDLE
	port map
	(
		INA => OPA(5),INB => INV_MULTIPLICAND(5),
		INC => OPA(6),IND => INV_MULTIPLICAND(6),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(124)
	);
PPM_125:PP_MIDDLE
	port map
	(
		INA => OPA(6),INB => INV_MULTIPLICAND(6),
		INC => OPA(7),IND => INV_MULTIPLICAND(7),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(132)
	);
PPM_126:PP_MIDDLE
	port map
	(
		INA => OPA(7),INB => INV_MULTIPLICAND(7),
		INC => OPA(8),IND => INV_MULTIPLICAND(8),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(139)
	);
PPM_127:PP_MIDDLE
	port map
	(
		INA => OPA(8),INB => INV_MULTIPLICAND(8),
		INC => OPA(9),IND => INV_MULTIPLICAND(9),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(146)
	);
PPM_128:PP_MIDDLE
	port map
	(
		INA => OPA(9),INB => INV_MULTIPLICAND(9),
		INC => OPA(10),IND => INV_MULTIPLICAND(10),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(152)
	);
PPM_129:PP_MIDDLE
	port map
	(
		INA => OPA(10),INB => INV_MULTIPLICAND(10),
		INC => OPA(11),IND => INV_MULTIPLICAND(11),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(158)
	);
PPM_130:PP_MIDDLE
	port map
	(
		INA => OPA(11),INB => INV_MULTIPLICAND(11),
		INC => OPA(12),IND => INV_MULTIPLICAND(12),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(163)
	);
PPM_131:PP_MIDDLE
	port map
	(
		INA => OPA(12),INB => INV_MULTIPLICAND(12),
		INC => OPA(13),IND => INV_MULTIPLICAND(13),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(168)
	);
PPM_132:PP_MIDDLE
	port map
	(
		INA => OPA(13),INB => INV_MULTIPLICAND(13),
		INC => OPA(14),IND => INV_MULTIPLICAND(14),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(172)
	);
PPM_133:PP_MIDDLE
	port map
	(
		INA => OPA(14),INB => INV_MULTIPLICAND(14),
		INC => OPA(15),IND => INV_MULTIPLICAND(15),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(176)
	);
PPM_134:PP_MIDDLE
	port map
	(
		INA => OPA(15),INB => INV_MULTIPLICAND(15),
		INC => OPA(16),IND => INV_MULTIPLICAND(16),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(179)
	);
PPM_135:PP_MIDDLE
	port map
	(
		INA => OPA(16),INB => INV_MULTIPLICAND(16),
		INC => OPA(17),IND => INV_MULTIPLICAND(17),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(181)
	);
SUMMAND(182) <= LOGIC_ONE;
PPH_7:PP_HIGH
	port map
	(
		INA => OPA(17),INB => INV_MULTIPLICAND(17),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(184)
	);
-- Begin partial product 8
-- Begin decoder block 9
DEC_8:DECODER -- Decoder of multiplier operand
	port map
	(
		INA => OPB(15),INB => OPB(16),INC => OPB(17),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35)
	);
-- End decoder block 9
-- Begin partial product 9
PPL_8:PP_LOW
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(88)
	);
RGATE_8:R_GATE
	port map
	(
		INA => OPB(15),INB => OPB(16),INC => OPB(17),
		PPBIT => SUMMAND(89)
	);
PPM_136:PP_MIDDLE
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		INC => OPA(1),IND => INV_MULTIPLICAND(1),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(98)
	);
PPM_137:PP_MIDDLE
	port map
	(
		INA => OPA(1),INB => INV_MULTIPLICAND(1),
		INC => OPA(2),IND => INV_MULTIPLICAND(2),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(108)
	);
PPM_138:PP_MIDDLE
	port map
	(
		INA => OPA(2),INB => INV_MULTIPLICAND(2),
		INC => OPA(3),IND => INV_MULTIPLICAND(3),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(117)
	);
PPM_139:PP_MIDDLE
	port map
	(
		INA => OPA(3),INB => INV_MULTIPLICAND(3),
		INC => OPA(4),IND => INV_MULTIPLICAND(4),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(125)
	);
PPM_140:PP_MIDDLE
	port map
	(
		INA => OPA(4),INB => INV_MULTIPLICAND(4),
		INC => OPA(5),IND => INV_MULTIPLICAND(5),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(133)
	);
PPM_141:PP_MIDDLE
	port map
	(
		INA => OPA(5),INB => INV_MULTIPLICAND(5),
		INC => OPA(6),IND => INV_MULTIPLICAND(6),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(140)
	);
PPM_142:PP_MIDDLE
	port map
	(
		INA => OPA(6),INB => INV_MULTIPLICAND(6),
		INC => OPA(7),IND => INV_MULTIPLICAND(7),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(147)
	);
PPM_143:PP_MIDDLE
	port map
	(
		INA => OPA(7),INB => INV_MULTIPLICAND(7),
		INC => OPA(8),IND => INV_MULTIPLICAND(8),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(153)
	);
PPM_144:PP_MIDDLE
	port map
	(
		INA => OPA(8),INB => INV_MULTIPLICAND(8),
		INC => OPA(9),IND => INV_MULTIPLICAND(9),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(159)
	);
PPM_145:PP_MIDDLE
	port map
	(
		INA => OPA(9),INB => INV_MULTIPLICAND(9),
		INC => OPA(10),IND => INV_MULTIPLICAND(10),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(164)
	);
PPM_146:PP_MIDDLE
	port map
	(
		INA => OPA(10),INB => INV_MULTIPLICAND(10),
		INC => OPA(11),IND => INV_MULTIPLICAND(11),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(169)
	);
PPM_147:PP_MIDDLE
	port map
	(
		INA => OPA(11),INB => INV_MULTIPLICAND(11),
		INC => OPA(12),IND => INV_MULTIPLICAND(12),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(173)
	);
PPM_148:PP_MIDDLE
	port map
	(
		INA => OPA(12),INB => INV_MULTIPLICAND(12),
		INC => OPA(13),IND => INV_MULTIPLICAND(13),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(177)
	);
PPM_149:PP_MIDDLE
	port map
	(
		INA => OPA(13),INB => INV_MULTIPLICAND(13),
		INC => OPA(14),IND => INV_MULTIPLICAND(14),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(180)
	);
PPM_150:PP_MIDDLE
	port map
	(
		INA => OPA(14),INB => INV_MULTIPLICAND(14),
		INC => OPA(15),IND => INV_MULTIPLICAND(15),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(183)
	);
PPM_151:PP_MIDDLE
	port map
	(
		INA => OPA(15),INB => INV_MULTIPLICAND(15),
		INC => OPA(16),IND => INV_MULTIPLICAND(16),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(185)
	);
PPM_152:PP_MIDDLE
	port map
	(
		INA => OPA(16),INB => INV_MULTIPLICAND(16),
		INC => OPA(17),IND => INV_MULTIPLICAND(17),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(186)
	);
SUMMAND(187) <= LOGIC_ONE;
PPH_8:PP_HIGH
	port map
	(
		INA => OPA(17),INB => INV_MULTIPLICAND(17),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(188)
	);
-- Begin partial product 9
end BOOTHCODER;
------------------------------------------------------------
-- END: Architectures used with the Modified Booth recoding
------------------------------------------------------------


--
-- Wallace tree architecture
--
library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.blocks.all;
entity WALLACE_18_18 is
port
(
	SUMMAND: in std_logic_vector(0 to 188);
	CARRY: out std_logic_vector(0 to 33);
	SUM: out std_logic_vector(0 to 34)
);
end WALLACE_18_18;
------------------------------------------------------------
-- END: Entities within the Wallace-tree
------------------------------------------------------------
architecture WALLACE of WALLACE_18_18 is

-- Components used in the netlist


-- Signals used inside the wallace trees

	signal INT_CARRY: std_logic_vector(0 to 114);
	signal INT_SUM: std_logic_vector(0 to 158);

begin -- netlist

-- Begin WT-branch 1
---- Begin HA stage
HA_0:HALF_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(0), DATA_B => SUMMAND(1), 
		SAVE => SUM(0), CARRY => CARRY(0)
	);
---- End HA stage
-- End WT-branch 1

-- Begin WT-branch 2
---- Begin NO stage
SUM(1) <= SUMMAND(2); -- At Level 1
CARRY(1) <= '0';
---- End NO stage
-- End WT-branch 2

-- Begin WT-branch 3
---- Begin FA stage
FA_0:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(3), DATA_B => SUMMAND(4), DATA_C => SUMMAND(5), 
		SAVE => SUM(2), CARRY => CARRY(2)
	);
---- End FA stage
-- End WT-branch 3

-- Begin WT-branch 4
---- Begin HA stage
HA_1:HALF_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(6), DATA_B => SUMMAND(7), 
		SAVE => SUM(3), CARRY => CARRY(3)
	);
---- End HA stage
-- End WT-branch 4

-- Begin WT-branch 5
---- Begin FA stage
FA_1:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(8), DATA_B => SUMMAND(9), DATA_C => SUMMAND(10), 
		SAVE => INT_SUM(0), CARRY => INT_CARRY(0)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(1) <= SUMMAND(11); -- At Level 1
---- End NO stage
---- Begin HA stage
HA_2:HALF_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(0), DATA_B => INT_SUM(1), 
		SAVE => SUM(4), CARRY => CARRY(4)
	);
---- End HA stage
-- End WT-branch 5

-- Begin WT-branch 6
---- Begin FA stage
FA_2:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(12), DATA_B => SUMMAND(13), DATA_C => SUMMAND(14), 
		SAVE => INT_SUM(2), CARRY => INT_CARRY(1)
	);
---- End FA stage
---- Begin HA stage
HA_3:HALF_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(2), DATA_B => INT_CARRY(0), 
		SAVE => SUM(5), CARRY => CARRY(5)
	);
---- End HA stage
-- End WT-branch 6

-- Begin WT-branch 7
---- Begin FA stage
FA_3:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(15), DATA_B => SUMMAND(16), DATA_C => SUMMAND(17), 
		SAVE => INT_SUM(3), CARRY => INT_CARRY(2)
	);
---- End FA stage
---- Begin HA stage
HA_4:HALF_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(18), DATA_B => SUMMAND(19), 
		SAVE => INT_SUM(4), CARRY => INT_CARRY(3)
	);
---- End HA stage
---- Begin FA stage
FA_4:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(3), DATA_B => INT_SUM(4), DATA_C => INT_CARRY(1), 
		SAVE => SUM(6), CARRY => CARRY(6)
	);
---- End FA stage
-- End WT-branch 7

-- Begin WT-branch 8
---- Begin FA stage
FA_5:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(20), DATA_B => SUMMAND(21), DATA_C => SUMMAND(22), 
		SAVE => INT_SUM(5), CARRY => INT_CARRY(4)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(6) <= SUMMAND(23); -- At Level 1
---- End NO stage
---- Begin FA stage
FA_6:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(5), DATA_B => INT_SUM(6), DATA_C => INT_CARRY(2), 
		SAVE => INT_SUM(7), CARRY => INT_CARRY(5)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(8) <= INT_CARRY(3); -- At Level 2
---- End NO stage
---- Begin HA stage
HA_5:HALF_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(7), DATA_B => INT_SUM(8), 
		SAVE => SUM(7), CARRY => CARRY(7)
	);
---- End HA stage
-- End WT-branch 8

-- Begin WT-branch 9
---- Begin FA stage
FA_7:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(24), DATA_B => SUMMAND(25), DATA_C => SUMMAND(26), 
		SAVE => INT_SUM(9), CARRY => INT_CARRY(6)
	);
---- End FA stage
---- Begin FA stage
FA_8:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(27), DATA_B => SUMMAND(28), DATA_C => SUMMAND(29), 
		SAVE => INT_SUM(10), CARRY => INT_CARRY(7)
	);
---- End FA stage
---- Begin FA stage
FA_9:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(9), DATA_B => INT_SUM(10), DATA_C => INT_CARRY(4), 
		SAVE => INT_SUM(11), CARRY => INT_CARRY(8)
	);
---- End FA stage
---- Begin HA stage
HA_6:HALF_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(11), DATA_B => INT_CARRY(5), 
		SAVE => SUM(8), CARRY => CARRY(8)
	);
---- End HA stage
-- End WT-branch 9

-- Begin WT-branch 10
---- Begin FA stage
FA_10:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(30), DATA_B => SUMMAND(31), DATA_C => SUMMAND(32), 
		SAVE => INT_SUM(12), CARRY => INT_CARRY(9)
	);
---- End FA stage
---- Begin HA stage
HA_7:HALF_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(33), DATA_B => SUMMAND(34), 
		SAVE => INT_SUM(13), CARRY => INT_CARRY(10)
	);
---- End HA stage
---- Begin FA stage
FA_11:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(12), DATA_B => INT_SUM(13), DATA_C => INT_CARRY(6), 
		SAVE => INT_SUM(14), CARRY => INT_CARRY(11)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(15) <= INT_CARRY(7); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_12:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(14), DATA_B => INT_SUM(15), DATA_C => INT_CARRY(8), 
		SAVE => SUM(9), CARRY => CARRY(9)
	);
---- End FA stage
-- End WT-branch 10

-- Begin WT-branch 11
---- Begin FA stage
FA_13:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(35), DATA_B => SUMMAND(36), DATA_C => SUMMAND(37), 
		SAVE => INT_SUM(16), CARRY => INT_CARRY(12)
	);
---- End FA stage
---- Begin FA stage
FA_14:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(38), DATA_B => SUMMAND(39), DATA_C => SUMMAND(40), 
		SAVE => INT_SUM(17), CARRY => INT_CARRY(13)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(18) <= SUMMAND(41); -- At Level 1
---- End NO stage
---- Begin FA stage
FA_15:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(16), DATA_B => INT_SUM(17), DATA_C => INT_SUM(18), 
		SAVE => INT_SUM(19), CARRY => INT_CARRY(14)
	);
---- End FA stage
---- Begin HA stage
HA_8:HALF_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(9), DATA_B => INT_CARRY(10), 
		SAVE => INT_SUM(20), CARRY => INT_CARRY(15)
	);
---- End HA stage
---- Begin FA stage
FA_16:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(19), DATA_B => INT_SUM(20), DATA_C => INT_CARRY(11), 
		SAVE => SUM(10), CARRY => CARRY(10)
	);
---- End FA stage
-- End WT-branch 11

-- Begin WT-branch 12
---- Begin FA stage
FA_17:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(42), DATA_B => SUMMAND(43), DATA_C => SUMMAND(44), 
		SAVE => INT_SUM(21), CARRY => INT_CARRY(16)
	);
---- End FA stage
---- Begin FA stage
FA_18:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(45), DATA_B => SUMMAND(46), DATA_C => SUMMAND(47), 
		SAVE => INT_SUM(22), CARRY => INT_CARRY(17)
	);
---- End FA stage
---- Begin FA stage
FA_19:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(21), DATA_B => INT_SUM(22), DATA_C => INT_CARRY(12), 
		SAVE => INT_SUM(23), CARRY => INT_CARRY(18)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(24) <= INT_CARRY(13); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_20:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(23), DATA_B => INT_SUM(24), DATA_C => INT_CARRY(14), 
		SAVE => INT_SUM(25), CARRY => INT_CARRY(19)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(26) <= INT_CARRY(15); -- At Level 3
---- End NO stage
---- Begin HA stage
HA_9:HALF_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(25), DATA_B => INT_SUM(26), 
		SAVE => SUM(11), CARRY => CARRY(11)
	);
---- End HA stage
-- End WT-branch 12

-- Begin WT-branch 13
---- Begin FA stage
FA_21:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(48), DATA_B => SUMMAND(49), DATA_C => SUMMAND(50), 
		SAVE => INT_SUM(27), CARRY => INT_CARRY(20)
	);
---- End FA stage
---- Begin FA stage
FA_22:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(51), DATA_B => SUMMAND(52), DATA_C => SUMMAND(53), 
		SAVE => INT_SUM(28), CARRY => INT_CARRY(21)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(29) <= SUMMAND(54); -- At Level 1
---- End NO stage
---- Begin NO stage
INT_SUM(30) <= SUMMAND(55); -- At Level 1
---- End NO stage
---- Begin FA stage
FA_23:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(27), DATA_B => INT_SUM(28), DATA_C => INT_SUM(29), 
		SAVE => INT_SUM(31), CARRY => INT_CARRY(22)
	);
---- End FA stage
---- Begin FA stage
FA_24:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(30), DATA_B => INT_CARRY(16), DATA_C => INT_CARRY(17), 
		SAVE => INT_SUM(32), CARRY => INT_CARRY(23)
	);
---- End FA stage
---- Begin FA stage
FA_25:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(31), DATA_B => INT_SUM(32), DATA_C => INT_CARRY(18), 
		SAVE => INT_SUM(33), CARRY => INT_CARRY(24)
	);
---- End FA stage
---- Begin HA stage
HA_10:HALF_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(33), DATA_B => INT_CARRY(19), 
		SAVE => SUM(12), CARRY => CARRY(12)
	);
---- End HA stage
-- End WT-branch 13

-- Begin WT-branch 14
---- Begin FA stage
FA_26:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(56), DATA_B => SUMMAND(57), DATA_C => SUMMAND(58), 
		SAVE => INT_SUM(34), CARRY => INT_CARRY(25)
	);
---- End FA stage
---- Begin FA stage
FA_27:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(59), DATA_B => SUMMAND(60), DATA_C => SUMMAND(61), 
		SAVE => INT_SUM(35), CARRY => INT_CARRY(26)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(36) <= SUMMAND(62); -- At Level 1
---- End NO stage
---- Begin FA stage
FA_28:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(34), DATA_B => INT_SUM(35), DATA_C => INT_SUM(36), 
		SAVE => INT_SUM(37), CARRY => INT_CARRY(27)
	);
---- End FA stage
---- Begin HA stage
HA_11:HALF_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(20), DATA_B => INT_CARRY(21), 
		SAVE => INT_SUM(38), CARRY => INT_CARRY(28)
	);
---- End HA stage
---- Begin FA stage
FA_29:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(37), DATA_B => INT_SUM(38), DATA_C => INT_CARRY(22), 
		SAVE => INT_SUM(39), CARRY => INT_CARRY(29)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(40) <= INT_CARRY(23); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_30:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(39), DATA_B => INT_SUM(40), DATA_C => INT_CARRY(24), 
		SAVE => SUM(13), CARRY => CARRY(13)
	);
---- End FA stage
-- End WT-branch 14

-- Begin WT-branch 15
---- Begin FA stage
FA_31:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(63), DATA_B => SUMMAND(64), DATA_C => SUMMAND(65), 
		SAVE => INT_SUM(41), CARRY => INT_CARRY(30)
	);
---- End FA stage
---- Begin FA stage
FA_32:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(66), DATA_B => SUMMAND(67), DATA_C => SUMMAND(68), 
		SAVE => INT_SUM(42), CARRY => INT_CARRY(31)
	);
---- End FA stage
---- Begin FA stage
FA_33:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(69), DATA_B => SUMMAND(70), DATA_C => SUMMAND(71), 
		SAVE => INT_SUM(43), CARRY => INT_CARRY(32)
	);
---- End FA stage
---- Begin FA stage
FA_34:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(41), DATA_B => INT_SUM(42), DATA_C => INT_SUM(43), 
		SAVE => INT_SUM(44), CARRY => INT_CARRY(33)
	);
---- End FA stage
---- Begin HA stage
HA_12:HALF_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(25), DATA_B => INT_CARRY(26), 
		SAVE => INT_SUM(45), CARRY => INT_CARRY(34)
	);
---- End HA stage
---- Begin FA stage
FA_35:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(44), DATA_B => INT_SUM(45), DATA_C => INT_CARRY(27), 
		SAVE => INT_SUM(46), CARRY => INT_CARRY(35)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(47) <= INT_CARRY(28); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_36:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(46), DATA_B => INT_SUM(47), DATA_C => INT_CARRY(29), 
		SAVE => SUM(14), CARRY => CARRY(14)
	);
---- End FA stage
-- End WT-branch 15

-- Begin WT-branch 16
---- Begin FA stage
FA_37:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(72), DATA_B => SUMMAND(73), DATA_C => SUMMAND(74), 
		SAVE => INT_SUM(48), CARRY => INT_CARRY(36)
	);
---- End FA stage
---- Begin FA stage
FA_38:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(75), DATA_B => SUMMAND(76), DATA_C => SUMMAND(77), 
		SAVE => INT_SUM(49), CARRY => INT_CARRY(37)
	);
---- End FA stage
---- Begin HA stage
HA_13:HALF_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(78), DATA_B => SUMMAND(79), 
		SAVE => INT_SUM(50), CARRY => INT_CARRY(38)
	);
---- End HA stage
---- Begin FA stage
FA_39:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(48), DATA_B => INT_SUM(49), DATA_C => INT_SUM(50), 
		SAVE => INT_SUM(51), CARRY => INT_CARRY(39)
	);
---- End FA stage
---- Begin FA stage
FA_40:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(30), DATA_B => INT_CARRY(31), DATA_C => INT_CARRY(32), 
		SAVE => INT_SUM(52), CARRY => INT_CARRY(40)
	);
---- End FA stage
---- Begin FA stage
FA_41:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(51), DATA_B => INT_SUM(52), DATA_C => INT_CARRY(33), 
		SAVE => INT_SUM(53), CARRY => INT_CARRY(41)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(54) <= INT_CARRY(34); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_42:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(53), DATA_B => INT_SUM(54), DATA_C => INT_CARRY(35), 
		SAVE => SUM(15), CARRY => CARRY(15)
	);
---- End FA stage
-- End WT-branch 16

-- Begin WT-branch 17
---- Begin FA stage
FA_43:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(80), DATA_B => SUMMAND(81), DATA_C => SUMMAND(82), 
		SAVE => INT_SUM(55), CARRY => INT_CARRY(42)
	);
---- End FA stage
---- Begin FA stage
FA_44:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(83), DATA_B => SUMMAND(84), DATA_C => SUMMAND(85), 
		SAVE => INT_SUM(56), CARRY => INT_CARRY(43)
	);
---- End FA stage
---- Begin FA stage
FA_45:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(86), DATA_B => SUMMAND(87), DATA_C => SUMMAND(88), 
		SAVE => INT_SUM(57), CARRY => INT_CARRY(44)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(58) <= SUMMAND(89); -- At Level 1
---- End NO stage
---- Begin FA stage
FA_46:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(55), DATA_B => INT_SUM(56), DATA_C => INT_SUM(57), 
		SAVE => INT_SUM(59), CARRY => INT_CARRY(45)
	);
---- End FA stage
---- Begin FA stage
FA_47:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(58), DATA_B => INT_CARRY(36), DATA_C => INT_CARRY(37), 
		SAVE => INT_SUM(60), CARRY => INT_CARRY(46)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(61) <= INT_CARRY(38); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_48:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(59), DATA_B => INT_SUM(60), DATA_C => INT_SUM(61), 
		SAVE => INT_SUM(62), CARRY => INT_CARRY(47)
	);
---- End FA stage
---- Begin HA stage
HA_14:HALF_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_CARRY(39), DATA_B => INT_CARRY(40), 
		SAVE => INT_SUM(63), CARRY => INT_CARRY(48)
	);
---- End HA stage
---- Begin FA stage
FA_49:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(62), DATA_B => INT_SUM(63), DATA_C => INT_CARRY(41), 
		SAVE => SUM(16), CARRY => CARRY(16)
	);
---- End FA stage
-- End WT-branch 17

-- Begin WT-branch 18
---- Begin FA stage
FA_50:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(90), DATA_B => SUMMAND(91), DATA_C => SUMMAND(92), 
		SAVE => INT_SUM(64), CARRY => INT_CARRY(49)
	);
---- End FA stage
---- Begin FA stage
FA_51:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(93), DATA_B => SUMMAND(94), DATA_C => SUMMAND(95), 
		SAVE => INT_SUM(65), CARRY => INT_CARRY(50)
	);
---- End FA stage
---- Begin FA stage
FA_52:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(96), DATA_B => SUMMAND(97), DATA_C => SUMMAND(98), 
		SAVE => INT_SUM(66), CARRY => INT_CARRY(51)
	);
---- End FA stage
---- Begin FA stage
FA_53:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(64), DATA_B => INT_SUM(65), DATA_C => INT_SUM(66), 
		SAVE => INT_SUM(67), CARRY => INT_CARRY(52)
	);
---- End FA stage
---- Begin FA stage
FA_54:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(42), DATA_B => INT_CARRY(43), DATA_C => INT_CARRY(44), 
		SAVE => INT_SUM(68), CARRY => INT_CARRY(53)
	);
---- End FA stage
---- Begin FA stage
FA_55:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(67), DATA_B => INT_SUM(68), DATA_C => INT_CARRY(45), 
		SAVE => INT_SUM(69), CARRY => INT_CARRY(54)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(70) <= INT_CARRY(46); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_56:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(69), DATA_B => INT_SUM(70), DATA_C => INT_CARRY(47), 
		SAVE => INT_SUM(71), CARRY => INT_CARRY(55)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(72) <= INT_CARRY(48); -- At Level 4
---- End NO stage
---- Begin HA stage
HA_15:HALF_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(71), DATA_B => INT_SUM(72), 
		SAVE => SUM(17), CARRY => CARRY(17)
	);
---- End HA stage
-- End WT-branch 18

-- Begin WT-branch 19
---- Begin FA stage
FA_57:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(99), DATA_B => SUMMAND(100), DATA_C => SUMMAND(101), 
		SAVE => INT_SUM(73), CARRY => INT_CARRY(56)
	);
---- End FA stage
---- Begin FA stage
FA_58:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(102), DATA_B => SUMMAND(103), DATA_C => SUMMAND(104), 
		SAVE => INT_SUM(74), CARRY => INT_CARRY(57)
	);
---- End FA stage
---- Begin FA stage
FA_59:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(105), DATA_B => SUMMAND(106), DATA_C => SUMMAND(107), 
		SAVE => INT_SUM(75), CARRY => INT_CARRY(58)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(76) <= SUMMAND(108); -- At Level 1
---- End NO stage
---- Begin FA stage
FA_60:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(73), DATA_B => INT_SUM(74), DATA_C => INT_SUM(75), 
		SAVE => INT_SUM(77), CARRY => INT_CARRY(59)
	);
---- End FA stage
---- Begin FA stage
FA_61:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(76), DATA_B => INT_CARRY(49), DATA_C => INT_CARRY(50), 
		SAVE => INT_SUM(78), CARRY => INT_CARRY(60)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(79) <= INT_CARRY(51); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_62:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(77), DATA_B => INT_SUM(78), DATA_C => INT_SUM(79), 
		SAVE => INT_SUM(80), CARRY => INT_CARRY(61)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(81) <= INT_CARRY(52); -- At Level 3
---- End NO stage
---- Begin NO stage
INT_SUM(82) <= INT_CARRY(53); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_63:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(80), DATA_B => INT_SUM(81), DATA_C => INT_SUM(82), 
		SAVE => INT_SUM(83), CARRY => INT_CARRY(62)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(84) <= INT_CARRY(54); -- At Level 4
---- End NO stage
---- Begin FA stage
FA_64:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(83), DATA_B => INT_SUM(84), DATA_C => INT_CARRY(55), 
		SAVE => SUM(18), CARRY => CARRY(18)
	);
---- End FA stage
-- End WT-branch 19

-- Begin WT-branch 20
---- Begin FA stage
FA_65:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(109), DATA_B => SUMMAND(110), DATA_C => SUMMAND(111), 
		SAVE => INT_SUM(85), CARRY => INT_CARRY(63)
	);
---- End FA stage
---- Begin FA stage
FA_66:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(112), DATA_B => SUMMAND(113), DATA_C => SUMMAND(114), 
		SAVE => INT_SUM(86), CARRY => INT_CARRY(64)
	);
---- End FA stage
---- Begin FA stage
FA_67:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(115), DATA_B => SUMMAND(116), DATA_C => SUMMAND(117), 
		SAVE => INT_SUM(87), CARRY => INT_CARRY(65)
	);
---- End FA stage
---- Begin FA stage
FA_68:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(56), DATA_B => INT_CARRY(57), DATA_C => INT_CARRY(58), 
		SAVE => INT_SUM(88), CARRY => INT_CARRY(66)
	);
---- End FA stage
---- Begin FA stage
FA_69:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(85), DATA_B => INT_SUM(86), DATA_C => INT_SUM(87), 
		SAVE => INT_SUM(89), CARRY => INT_CARRY(67)
	);
---- End FA stage
---- Begin FA stage
FA_70:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(88), DATA_B => INT_CARRY(59), DATA_C => INT_CARRY(60), 
		SAVE => INT_SUM(90), CARRY => INT_CARRY(68)
	);
---- End FA stage
---- Begin FA stage
FA_71:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(89), DATA_B => INT_SUM(90), DATA_C => INT_CARRY(61), 
		SAVE => INT_SUM(91), CARRY => INT_CARRY(69)
	);
---- End FA stage
---- Begin HA stage
HA_16:HALF_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(91), DATA_B => INT_CARRY(62), 
		SAVE => SUM(19), CARRY => CARRY(19)
	);
---- End HA stage
-- End WT-branch 20

-- Begin WT-branch 21
---- Begin FA stage
FA_72:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(118), DATA_B => SUMMAND(119), DATA_C => SUMMAND(120), 
		SAVE => INT_SUM(92), CARRY => INT_CARRY(70)
	);
---- End FA stage
---- Begin FA stage
FA_73:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(121), DATA_B => SUMMAND(122), DATA_C => SUMMAND(123), 
		SAVE => INT_SUM(93), CARRY => INT_CARRY(71)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(94) <= SUMMAND(124); -- At Level 1
---- End NO stage
---- Begin NO stage
INT_SUM(95) <= SUMMAND(125); -- At Level 1
---- End NO stage
---- Begin FA stage
FA_74:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(92), DATA_B => INT_SUM(93), DATA_C => INT_SUM(94), 
		SAVE => INT_SUM(96), CARRY => INT_CARRY(72)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(97) <= INT_SUM(95); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_75:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(96), DATA_B => INT_SUM(97), DATA_C => INT_CARRY(63), 
		SAVE => INT_SUM(98), CARRY => INT_CARRY(73)
	);
---- End FA stage
---- Begin FA stage
FA_76:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_CARRY(64), DATA_B => INT_CARRY(65), DATA_C => INT_CARRY(66), 
		SAVE => INT_SUM(99), CARRY => INT_CARRY(74)
	);
---- End FA stage
---- Begin FA stage
FA_77:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(98), DATA_B => INT_SUM(99), DATA_C => INT_CARRY(67), 
		SAVE => INT_SUM(100), CARRY => INT_CARRY(75)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(101) <= INT_CARRY(68); -- At Level 4
---- End NO stage
---- Begin FA stage
FA_78:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(100), DATA_B => INT_SUM(101), DATA_C => INT_CARRY(69), 
		SAVE => SUM(20), CARRY => CARRY(20)
	);
---- End FA stage
-- End WT-branch 21

-- Begin WT-branch 22
---- Begin FA stage
FA_79:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(126), DATA_B => SUMMAND(127), DATA_C => SUMMAND(128), 
		SAVE => INT_SUM(102), CARRY => INT_CARRY(76)
	);
---- End FA stage
---- Begin FA stage
FA_80:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(129), DATA_B => SUMMAND(130), DATA_C => SUMMAND(131), 
		SAVE => INT_SUM(103), CARRY => INT_CARRY(77)
	);
---- End FA stage
---- Begin FA stage
FA_81:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(132), DATA_B => SUMMAND(133), DATA_C => INT_CARRY(70), 
		SAVE => INT_SUM(104), CARRY => INT_CARRY(78)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(105) <= INT_CARRY(71); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_82:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(102), DATA_B => INT_SUM(103), DATA_C => INT_SUM(104), 
		SAVE => INT_SUM(106), CARRY => INT_CARRY(79)
	);
---- End FA stage
---- Begin HA stage
HA_17:HALF_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(105), DATA_B => INT_CARRY(72), 
		SAVE => INT_SUM(107), CARRY => INT_CARRY(80)
	);
---- End HA stage
---- Begin FA stage
FA_83:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(106), DATA_B => INT_SUM(107), DATA_C => INT_CARRY(73), 
		SAVE => INT_SUM(108), CARRY => INT_CARRY(81)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(109) <= INT_CARRY(74); -- At Level 4
---- End NO stage
---- Begin FA stage
FA_84:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(108), DATA_B => INT_SUM(109), DATA_C => INT_CARRY(75), 
		SAVE => SUM(21), CARRY => CARRY(21)
	);
---- End FA stage
-- End WT-branch 22

-- Begin WT-branch 23
---- Begin FA stage
FA_85:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(134), DATA_B => SUMMAND(135), DATA_C => SUMMAND(136), 
		SAVE => INT_SUM(110), CARRY => INT_CARRY(82)
	);
---- End FA stage
---- Begin FA stage
FA_86:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(137), DATA_B => SUMMAND(138), DATA_C => SUMMAND(139), 
		SAVE => INT_SUM(111), CARRY => INT_CARRY(83)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(112) <= SUMMAND(140); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_87:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(110), DATA_B => INT_SUM(111), DATA_C => INT_SUM(112), 
		SAVE => INT_SUM(113), CARRY => INT_CARRY(84)
	);
---- End FA stage
---- Begin FA stage
FA_88:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_CARRY(76), DATA_B => INT_CARRY(77), DATA_C => INT_CARRY(78), 
		SAVE => INT_SUM(114), CARRY => INT_CARRY(85)
	);
---- End FA stage
---- Begin FA stage
FA_89:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(113), DATA_B => INT_SUM(114), DATA_C => INT_CARRY(79), 
		SAVE => INT_SUM(115), CARRY => INT_CARRY(86)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(116) <= INT_CARRY(80); -- At Level 4
---- End NO stage
---- Begin FA stage
FA_90:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(115), DATA_B => INT_SUM(116), DATA_C => INT_CARRY(81), 
		SAVE => SUM(22), CARRY => CARRY(22)
	);
---- End FA stage
-- End WT-branch 23

-- Begin WT-branch 24
---- Begin FA stage
FA_91:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(141), DATA_B => SUMMAND(142), DATA_C => SUMMAND(143), 
		SAVE => INT_SUM(117), CARRY => INT_CARRY(87)
	);
---- End FA stage
---- Begin FA stage
FA_92:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(144), DATA_B => SUMMAND(145), DATA_C => SUMMAND(146), 
		SAVE => INT_SUM(118), CARRY => INT_CARRY(88)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(119) <= SUMMAND(147); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_93:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(117), DATA_B => INT_SUM(118), DATA_C => INT_SUM(119), 
		SAVE => INT_SUM(120), CARRY => INT_CARRY(89)
	);
---- End FA stage
---- Begin HA stage
HA_18:HALF_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_CARRY(82), DATA_B => INT_CARRY(83), 
		SAVE => INT_SUM(121), CARRY => INT_CARRY(90)
	);
---- End HA stage
---- Begin FA stage
FA_94:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(120), DATA_B => INT_SUM(121), DATA_C => INT_CARRY(84), 
		SAVE => INT_SUM(122), CARRY => INT_CARRY(91)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(123) <= INT_CARRY(85); -- At Level 4
---- End NO stage
---- Begin FA stage
FA_95:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(122), DATA_B => INT_SUM(123), DATA_C => INT_CARRY(86), 
		SAVE => SUM(23), CARRY => CARRY(23)
	);
---- End FA stage
-- End WT-branch 24

-- Begin WT-branch 25
---- Begin FA stage
FA_96:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(148), DATA_B => SUMMAND(149), DATA_C => SUMMAND(150), 
		SAVE => INT_SUM(124), CARRY => INT_CARRY(92)
	);
---- End FA stage
---- Begin FA stage
FA_97:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(151), DATA_B => SUMMAND(152), DATA_C => SUMMAND(153), 
		SAVE => INT_SUM(125), CARRY => INT_CARRY(93)
	);
---- End FA stage
---- Begin FA stage
FA_98:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(124), DATA_B => INT_SUM(125), DATA_C => INT_CARRY(87), 
		SAVE => INT_SUM(126), CARRY => INT_CARRY(94)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(127) <= INT_CARRY(88); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_99:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(126), DATA_B => INT_SUM(127), DATA_C => INT_CARRY(89), 
		SAVE => INT_SUM(128), CARRY => INT_CARRY(95)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(129) <= INT_CARRY(90); -- At Level 4
---- End NO stage
---- Begin FA stage
FA_100:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(128), DATA_B => INT_SUM(129), DATA_C => INT_CARRY(91), 
		SAVE => SUM(24), CARRY => CARRY(24)
	);
---- End FA stage
-- End WT-branch 25

-- Begin WT-branch 26
---- Begin FA stage
FA_101:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(154), DATA_B => SUMMAND(155), DATA_C => SUMMAND(156), 
		SAVE => INT_SUM(130), CARRY => INT_CARRY(96)
	);
---- End FA stage
---- Begin FA stage
FA_102:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(157), DATA_B => SUMMAND(158), DATA_C => SUMMAND(159), 
		SAVE => INT_SUM(131), CARRY => INT_CARRY(97)
	);
---- End FA stage
---- Begin FA stage
FA_103:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(130), DATA_B => INT_SUM(131), DATA_C => INT_CARRY(92), 
		SAVE => INT_SUM(132), CARRY => INT_CARRY(98)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(133) <= INT_CARRY(93); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_104:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(132), DATA_B => INT_SUM(133), DATA_C => INT_CARRY(94), 
		SAVE => INT_SUM(134), CARRY => INT_CARRY(99)
	);
---- End FA stage
---- Begin HA stage
HA_19:HALF_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(134), DATA_B => INT_CARRY(95), 
		SAVE => SUM(25), CARRY => CARRY(25)
	);
---- End HA stage
-- End WT-branch 26

-- Begin WT-branch 27
---- Begin FA stage
FA_105:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(160), DATA_B => SUMMAND(161), DATA_C => SUMMAND(162), 
		SAVE => INT_SUM(135), CARRY => INT_CARRY(100)
	);
---- End FA stage
---- Begin HA stage
HA_20:HALF_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(163), DATA_B => SUMMAND(164), 
		SAVE => INT_SUM(136), CARRY => INT_CARRY(101)
	);
---- End HA stage
---- Begin FA stage
FA_106:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(135), DATA_B => INT_SUM(136), DATA_C => INT_CARRY(96), 
		SAVE => INT_SUM(137), CARRY => INT_CARRY(102)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(138) <= INT_CARRY(97); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_107:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(137), DATA_B => INT_SUM(138), DATA_C => INT_CARRY(98), 
		SAVE => INT_SUM(139), CARRY => INT_CARRY(103)
	);
---- End FA stage
---- Begin HA stage
HA_21:HALF_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(139), DATA_B => INT_CARRY(99), 
		SAVE => SUM(26), CARRY => CARRY(26)
	);
---- End HA stage
-- End WT-branch 27

-- Begin WT-branch 28
---- Begin FA stage
FA_108:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(165), DATA_B => SUMMAND(166), DATA_C => SUMMAND(167), 
		SAVE => INT_SUM(140), CARRY => INT_CARRY(104)
	);
---- End FA stage
---- Begin HA stage
HA_22:HALF_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(168), DATA_B => SUMMAND(169), 
		SAVE => INT_SUM(141), CARRY => INT_CARRY(105)
	);
---- End HA stage
---- Begin FA stage
FA_109:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(140), DATA_B => INT_SUM(141), DATA_C => INT_CARRY(100), 
		SAVE => INT_SUM(142), CARRY => INT_CARRY(106)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(143) <= INT_CARRY(101); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_110:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(142), DATA_B => INT_SUM(143), DATA_C => INT_CARRY(102), 
		SAVE => INT_SUM(144), CARRY => INT_CARRY(107)
	);
---- End FA stage
---- Begin HA stage
HA_23:HALF_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(144), DATA_B => INT_CARRY(103), 
		SAVE => SUM(27), CARRY => CARRY(27)
	);
---- End HA stage
-- End WT-branch 28

-- Begin WT-branch 29
---- Begin FA stage
FA_111:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => SUMMAND(170), DATA_B => SUMMAND(171), DATA_C => SUMMAND(172), 
		SAVE => INT_SUM(145), CARRY => INT_CARRY(108)
	);
---- End FA stage
---- Begin FA stage
FA_112:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => SUMMAND(173), DATA_B => INT_CARRY(104), DATA_C => INT_CARRY(105), 
		SAVE => INT_SUM(146), CARRY => INT_CARRY(109)
	);
---- End FA stage
---- Begin FA stage
FA_113:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(145), DATA_B => INT_SUM(146), DATA_C => INT_CARRY(106), 
		SAVE => INT_SUM(147), CARRY => INT_CARRY(110)
	);
---- End FA stage
---- Begin HA stage
HA_24:HALF_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(147), DATA_B => INT_CARRY(107), 
		SAVE => SUM(28), CARRY => CARRY(28)
	);
---- End HA stage
-- End WT-branch 29

-- Begin WT-branch 30
---- Begin FA stage
FA_114:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => SUMMAND(174), DATA_B => SUMMAND(175), DATA_C => SUMMAND(176), 
		SAVE => INT_SUM(148), CARRY => INT_CARRY(111)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(149) <= SUMMAND(177); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_115:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(148), DATA_B => INT_SUM(149), DATA_C => INT_CARRY(108), 
		SAVE => INT_SUM(150), CARRY => INT_CARRY(112)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(151) <= INT_CARRY(109); -- At Level 4
---- End NO stage
---- Begin FA stage
FA_116:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(150), DATA_B => INT_SUM(151), DATA_C => INT_CARRY(110), 
		SAVE => SUM(29), CARRY => CARRY(29)
	);
---- End FA stage
-- End WT-branch 30

-- Begin WT-branch 31
---- Begin FA stage
FA_117:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => SUMMAND(178), DATA_B => SUMMAND(179), DATA_C => SUMMAND(180), 
		SAVE => INT_SUM(152), CARRY => INT_CARRY(113)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(153) <= INT_SUM(152); -- At Level 4
---- End NO stage
---- Begin NO stage
INT_SUM(154) <= INT_CARRY(111); -- At Level 4
---- End NO stage
---- Begin FA stage
FA_118:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(153), DATA_B => INT_SUM(154), DATA_C => INT_CARRY(112), 
		SAVE => SUM(30), CARRY => CARRY(30)
	);
---- End FA stage
-- End WT-branch 31

-- Begin WT-branch 32
---- Begin FA stage
FA_119:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => SUMMAND(181), DATA_B => SUMMAND(182), DATA_C => SUMMAND(183), 
		SAVE => INT_SUM(155), CARRY => INT_CARRY(114)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(156) <= INT_CARRY(113); -- At Level 4
---- End NO stage
---- Begin HA stage
HA_25:HALF_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(155), DATA_B => INT_SUM(156), 
		SAVE => SUM(31), CARRY => CARRY(31)
	);
---- End HA stage
-- End WT-branch 32

-- Begin WT-branch 33
---- Begin NO stage
INT_SUM(157) <= SUMMAND(184); -- At Level 4
---- End NO stage
---- Begin NO stage
INT_SUM(158) <= SUMMAND(185); -- At Level 4
---- End NO stage
---- Begin FA stage
FA_120:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(157), DATA_B => INT_SUM(158), DATA_C => INT_CARRY(114), 
		SAVE => SUM(32), CARRY => CARRY(32)
	);
---- End FA stage
-- End WT-branch 33

-- Begin WT-branch 34
---- Begin HA stage
HA_26:HALF_ADDER -- At Level 5
	port map
	(
		DATA_A => SUMMAND(186), DATA_B => SUMMAND(187), 
		SAVE => SUM(33), CARRY => CARRY(33)
	);
---- End HA stage
-- End WT-branch 34

-- Begin WT-branch 35
---- Begin NO stage
SUM(34) <= SUMMAND(188); -- At Level 5
---- End NO stage
-- End WT-branch 35

end WALLACE;
------------------------------------------------------------
-- END: Architectures used with the Wallace-tree
------------------------------------------------------------

------------------------------------------------------------
-- START: Architectures used with the multiplier
------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.blocks.all;
entity MULTIPLIER_18_18 is
generic (mulpipe : integer := 0);
port
(
	MULTIPLICAND: in std_logic_vector(0 to 17);
	MULTIPLIER: in std_logic_vector(0 to 17);
	PHI: in std_ulogic;
	holdn: in std_ulogic;
	RESULT: out std_logic_vector(0 to 63)
);
end MULTIPLIER_18_18;

architecture MULTIPLIER of MULTIPLIER_18_18 is

signal PPBIT:std_logic_vector(0 to 188);
signal INT_CARRY: std_logic_vector(0 to 64);
signal INT_CARRYR: std_logic_vector(0 to 64);
signal INT_SUM: std_logic_vector(0 to 63);
signal INT_SUMR: std_logic_vector(0 to 63);
signal LOGIC_ZERO: std_logic;

begin -- Architecture

LOGIC_ZERO <= '0';
B:BOOTHCODER_18_18
	port map
	(
		OPA(0 to 17) => MULTIPLICAND(0 to 17),
		OPB(0 to 17) => MULTIPLIER(0 to 17),
		SUMMAND(0 to 188) => PPBIT(0 to 188)
	);
W:WALLACE_18_18
	port map
	(
		SUMMAND(0 to 188) => PPBIT(0 to 188),
		CARRY(0 to 33) => INT_CARRY(1 to 34),
		SUM(0 to 34) => INT_SUM(0 to 34)
	);
INT_CARRY(0) <= LOGIC_ZERO;
INT_CARRY(35) <= LOGIC_ZERO;
INT_CARRY(36) <= LOGIC_ZERO;
INT_CARRY(37) <= LOGIC_ZERO;
INT_CARRY(38) <= LOGIC_ZERO;
INT_CARRY(39) <= LOGIC_ZERO;
INT_CARRY(40) <= LOGIC_ZERO;
INT_CARRY(41) <= LOGIC_ZERO;
INT_CARRY(42) <= LOGIC_ZERO;
INT_CARRY(43) <= LOGIC_ZERO;
INT_CARRY(44) <= LOGIC_ZERO;
INT_CARRY(45) <= LOGIC_ZERO;
INT_CARRY(46) <= LOGIC_ZERO;
INT_CARRY(47) <= LOGIC_ZERO;
INT_CARRY(48) <= LOGIC_ZERO;
INT_CARRY(49) <= LOGIC_ZERO;
INT_CARRY(50) <= LOGIC_ZERO;
INT_CARRY(51) <= LOGIC_ZERO;
INT_CARRY(52) <= LOGIC_ZERO;
INT_CARRY(53) <= LOGIC_ZERO;
INT_CARRY(54) <= LOGIC_ZERO;
INT_CARRY(55) <= LOGIC_ZERO;
INT_CARRY(56) <= LOGIC_ZERO;
INT_CARRY(57) <= LOGIC_ZERO;
INT_CARRY(58) <= LOGIC_ZERO;
INT_CARRY(59) <= LOGIC_ZERO;
INT_CARRY(60) <= LOGIC_ZERO;
INT_CARRY(61) <= LOGIC_ZERO;
INT_CARRY(62) <= LOGIC_ZERO;
INT_CARRY(63) <= LOGIC_ZERO;
INT_SUM(35) <= LOGIC_ZERO;
INT_SUM(36) <= LOGIC_ZERO;
INT_SUM(37) <= LOGIC_ZERO;
INT_SUM(38) <= LOGIC_ZERO;
INT_SUM(39) <= LOGIC_ZERO;
INT_SUM(40) <= LOGIC_ZERO;
INT_SUM(41) <= LOGIC_ZERO;
INT_SUM(42) <= LOGIC_ZERO;
INT_SUM(43) <= LOGIC_ZERO;
INT_SUM(44) <= LOGIC_ZERO;
INT_SUM(45) <= LOGIC_ZERO;
INT_SUM(46) <= LOGIC_ZERO;
INT_SUM(47) <= LOGIC_ZERO;
INT_SUM(48) <= LOGIC_ZERO;
INT_SUM(49) <= LOGIC_ZERO;
INT_SUM(50) <= LOGIC_ZERO;
INT_SUM(51) <= LOGIC_ZERO;
INT_SUM(52) <= LOGIC_ZERO;
INT_SUM(53) <= LOGIC_ZERO;
INT_SUM(54) <= LOGIC_ZERO;
INT_SUM(55) <= LOGIC_ZERO;
INT_SUM(56) <= LOGIC_ZERO;
INT_SUM(57) <= LOGIC_ZERO;
INT_SUM(58) <= LOGIC_ZERO;
INT_SUM(59) <= LOGIC_ZERO;
INT_SUM(60) <= LOGIC_ZERO;
INT_SUM(61) <= LOGIC_ZERO;
INT_SUM(62) <= LOGIC_ZERO;
INT_SUM(63) <= LOGIC_ZERO;

  INT_SUMR(35 to 63) <= INT_SUM(35 to 63);
  INT_CARRYR(35 to 63) <= INT_CARRY(35 to 63);
  INT_CARRYR(0) <= INT_CARRY(0);
  reg : if MULPIPE /= 0 generate



      process (PHI) begin 
        if rising_edge(PHI ) then
          if (holdn = '1') then 
	    INT_SUMR(0 to 34) <= INT_SUM(0 to 34);
	    INT_CARRYR(1 to 34) <= INT_CARRY(1 to 34);
          end if;
        end if;
      end process;

  end generate;
    
  noreg : if MULPIPE = 0 generate
	INT_SUMR(0 to 34) <= INT_SUM(0 to 34);
	INT_CARRYR(1 to 34) <= INT_CARRY(1 to 34);
  end generate;

D:DBLCADDER_64_64
	port map
	(
		OPA(0 to 63) => INT_SUMR(0 to 63),
		OPB(0 to 63) => INT_CARRYR(0 to 63),
		CIN => LOGIC_ZERO,
		PHI => PHI ,
		SUM(0 to 63) => RESULT(0 to 63)
	);
end MULTIPLIER;



library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.blocks.all;
entity BOOTHCODER_34_10 is
port
(
		OPA: in std_logic_vector(0 to 33);
		OPB: in std_logic_vector(0 to 9);
		SUMMAND: out std_logic_vector(0 to 184)
);
end BOOTHCODER_34_10;
architecture BOOTHCODER of BOOTHCODER_34_10 is

-- Internal signal in Booth structure

signal INV_MULTIPLICAND: std_logic_vector(0 to 33);
signal INT_MULTIPLIER: std_logic_vector(0 to 19);
signal LOGIC_ONE, LOGIC_ZERO: std_logic;
begin
LOGIC_ONE <= '1';
LOGIC_ZERO <= '0';
-- Begin decoder block 1
DEC_0:DECODER -- Decoder of multiplier operand
	port map
	(
		INA => LOGIC_ZERO,INB => OPB(0),INC => OPB(1),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3)
	);
-- End decoder block 1
-- Begin partial product 1
INV_MULTIPLICAND(0) <= NOT OPA(0);
PPL_0:PP_LOW
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(0)
	);
RGATE_0:R_GATE
	port map
	(
		INA => LOGIC_ZERO,INB => OPB(0),INC => OPB(1),
		PPBIT => SUMMAND(1)
	);
INV_MULTIPLICAND(1) <= NOT OPA(1);
PPM_0:PP_MIDDLE
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		INC => OPA(1),IND => INV_MULTIPLICAND(1),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(2)
	);
INV_MULTIPLICAND(2) <= NOT OPA(2);
PPM_1:PP_MIDDLE
	port map
	(
		INA => OPA(1),INB => INV_MULTIPLICAND(1),
		INC => OPA(2),IND => INV_MULTIPLICAND(2),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(3)
	);
INV_MULTIPLICAND(3) <= NOT OPA(3);
PPM_2:PP_MIDDLE
	port map
	(
		INA => OPA(2),INB => INV_MULTIPLICAND(2),
		INC => OPA(3),IND => INV_MULTIPLICAND(3),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(6)
	);
INV_MULTIPLICAND(4) <= NOT OPA(4);
PPM_3:PP_MIDDLE
	port map
	(
		INA => OPA(3),INB => INV_MULTIPLICAND(3),
		INC => OPA(4),IND => INV_MULTIPLICAND(4),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(8)
	);
INV_MULTIPLICAND(5) <= NOT OPA(5);
PPM_4:PP_MIDDLE
	port map
	(
		INA => OPA(4),INB => INV_MULTIPLICAND(4),
		INC => OPA(5),IND => INV_MULTIPLICAND(5),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(12)
	);
INV_MULTIPLICAND(6) <= NOT OPA(6);
PPM_5:PP_MIDDLE
	port map
	(
		INA => OPA(5),INB => INV_MULTIPLICAND(5),
		INC => OPA(6),IND => INV_MULTIPLICAND(6),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(15)
	);
INV_MULTIPLICAND(7) <= NOT OPA(7);
PPM_6:PP_MIDDLE
	port map
	(
		INA => OPA(6),INB => INV_MULTIPLICAND(6),
		INC => OPA(7),IND => INV_MULTIPLICAND(7),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(20)
	);
INV_MULTIPLICAND(8) <= NOT OPA(8);
PPM_7:PP_MIDDLE
	port map
	(
		INA => OPA(7),INB => INV_MULTIPLICAND(7),
		INC => OPA(8),IND => INV_MULTIPLICAND(8),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(24)
	);
INV_MULTIPLICAND(9) <= NOT OPA(9);
PPM_8:PP_MIDDLE
	port map
	(
		INA => OPA(8),INB => INV_MULTIPLICAND(8),
		INC => OPA(9),IND => INV_MULTIPLICAND(9),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(30)
	);
INV_MULTIPLICAND(10) <= NOT OPA(10);
PPM_9:PP_MIDDLE
	port map
	(
		INA => OPA(9),INB => INV_MULTIPLICAND(9),
		INC => OPA(10),IND => INV_MULTIPLICAND(10),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(35)
	);
INV_MULTIPLICAND(11) <= NOT OPA(11);
PPM_10:PP_MIDDLE
	port map
	(
		INA => OPA(10),INB => INV_MULTIPLICAND(10),
		INC => OPA(11),IND => INV_MULTIPLICAND(11),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(40)
	);
INV_MULTIPLICAND(12) <= NOT OPA(12);
PPM_11:PP_MIDDLE
	port map
	(
		INA => OPA(11),INB => INV_MULTIPLICAND(11),
		INC => OPA(12),IND => INV_MULTIPLICAND(12),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(45)
	);
INV_MULTIPLICAND(13) <= NOT OPA(13);
PPM_12:PP_MIDDLE
	port map
	(
		INA => OPA(12),INB => INV_MULTIPLICAND(12),
		INC => OPA(13),IND => INV_MULTIPLICAND(13),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(50)
	);
INV_MULTIPLICAND(14) <= NOT OPA(14);
PPM_13:PP_MIDDLE
	port map
	(
		INA => OPA(13),INB => INV_MULTIPLICAND(13),
		INC => OPA(14),IND => INV_MULTIPLICAND(14),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(55)
	);
INV_MULTIPLICAND(15) <= NOT OPA(15);
PPM_14:PP_MIDDLE
	port map
	(
		INA => OPA(14),INB => INV_MULTIPLICAND(14),
		INC => OPA(15),IND => INV_MULTIPLICAND(15),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(60)
	);
INV_MULTIPLICAND(16) <= NOT OPA(16);
PPM_15:PP_MIDDLE
	port map
	(
		INA => OPA(15),INB => INV_MULTIPLICAND(15),
		INC => OPA(16),IND => INV_MULTIPLICAND(16),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(65)
	);
INV_MULTIPLICAND(17) <= NOT OPA(17);
PPM_16:PP_MIDDLE
	port map
	(
		INA => OPA(16),INB => INV_MULTIPLICAND(16),
		INC => OPA(17),IND => INV_MULTIPLICAND(17),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(70)
	);
INV_MULTIPLICAND(18) <= NOT OPA(18);
PPM_17:PP_MIDDLE
	port map
	(
		INA => OPA(17),INB => INV_MULTIPLICAND(17),
		INC => OPA(18),IND => INV_MULTIPLICAND(18),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(75)
	);
INV_MULTIPLICAND(19) <= NOT OPA(19);
PPM_18:PP_MIDDLE
	port map
	(
		INA => OPA(18),INB => INV_MULTIPLICAND(18),
		INC => OPA(19),IND => INV_MULTIPLICAND(19),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(80)
	);
INV_MULTIPLICAND(20) <= NOT OPA(20);
PPM_19:PP_MIDDLE
	port map
	(
		INA => OPA(19),INB => INV_MULTIPLICAND(19),
		INC => OPA(20),IND => INV_MULTIPLICAND(20),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(85)
	);
INV_MULTIPLICAND(21) <= NOT OPA(21);
PPM_20:PP_MIDDLE
	port map
	(
		INA => OPA(20),INB => INV_MULTIPLICAND(20),
		INC => OPA(21),IND => INV_MULTIPLICAND(21),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(90)
	);
INV_MULTIPLICAND(22) <= NOT OPA(22);
PPM_21:PP_MIDDLE
	port map
	(
		INA => OPA(21),INB => INV_MULTIPLICAND(21),
		INC => OPA(22),IND => INV_MULTIPLICAND(22),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(95)
	);
INV_MULTIPLICAND(23) <= NOT OPA(23);
PPM_22:PP_MIDDLE
	port map
	(
		INA => OPA(22),INB => INV_MULTIPLICAND(22),
		INC => OPA(23),IND => INV_MULTIPLICAND(23),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(100)
	);
INV_MULTIPLICAND(24) <= NOT OPA(24);
PPM_23:PP_MIDDLE
	port map
	(
		INA => OPA(23),INB => INV_MULTIPLICAND(23),
		INC => OPA(24),IND => INV_MULTIPLICAND(24),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(105)
	);
INV_MULTIPLICAND(25) <= NOT OPA(25);
PPM_24:PP_MIDDLE
	port map
	(
		INA => OPA(24),INB => INV_MULTIPLICAND(24),
		INC => OPA(25),IND => INV_MULTIPLICAND(25),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(110)
	);
INV_MULTIPLICAND(26) <= NOT OPA(26);
PPM_25:PP_MIDDLE
	port map
	(
		INA => OPA(25),INB => INV_MULTIPLICAND(25),
		INC => OPA(26),IND => INV_MULTIPLICAND(26),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(115)
	);
INV_MULTIPLICAND(27) <= NOT OPA(27);
PPM_26:PP_MIDDLE
	port map
	(
		INA => OPA(26),INB => INV_MULTIPLICAND(26),
		INC => OPA(27),IND => INV_MULTIPLICAND(27),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(120)
	);
INV_MULTIPLICAND(28) <= NOT OPA(28);
PPM_27:PP_MIDDLE
	port map
	(
		INA => OPA(27),INB => INV_MULTIPLICAND(27),
		INC => OPA(28),IND => INV_MULTIPLICAND(28),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(125)
	);
INV_MULTIPLICAND(29) <= NOT OPA(29);
PPM_28:PP_MIDDLE
	port map
	(
		INA => OPA(28),INB => INV_MULTIPLICAND(28),
		INC => OPA(29),IND => INV_MULTIPLICAND(29),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(130)
	);
INV_MULTIPLICAND(30) <= NOT OPA(30);
PPM_29:PP_MIDDLE
	port map
	(
		INA => OPA(29),INB => INV_MULTIPLICAND(29),
		INC => OPA(30),IND => INV_MULTIPLICAND(30),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(135)
	);
INV_MULTIPLICAND(31) <= NOT OPA(31);
PPM_30:PP_MIDDLE
	port map
	(
		INA => OPA(30),INB => INV_MULTIPLICAND(30),
		INC => OPA(31),IND => INV_MULTIPLICAND(31),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(140)
	);
INV_MULTIPLICAND(32) <= NOT OPA(32);
PPM_31:PP_MIDDLE
	port map
	(
		INA => OPA(31),INB => INV_MULTIPLICAND(31),
		INC => OPA(32),IND => INV_MULTIPLICAND(32),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(145)
	);
INV_MULTIPLICAND(33) <= NOT OPA(33);
PPM_32:PP_MIDDLE
	port map
	(
		INA => OPA(32),INB => INV_MULTIPLICAND(32),
		INC => OPA(33),IND => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(150)
	);
PPH_0:PP_HIGH
	port map
	(
		INA => OPA(33),INB => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(155)
	);
SUMMAND(156) <= '1';
-- Begin partial product 1
-- Begin decoder block 2
DEC_1:DECODER -- Decoder of multiplier operand
	port map
	(
		INA => OPB(1),INB => OPB(2),INC => OPB(3),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7)
	);
-- End decoder block 2
-- Begin partial product 2
PPL_1:PP_LOW
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(4)
	);
RGATE_1:R_GATE
	port map
	(
		INA => OPB(1),INB => OPB(2),INC => OPB(3),
		PPBIT => SUMMAND(5)
	);
PPM_33:PP_MIDDLE
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		INC => OPA(1),IND => INV_MULTIPLICAND(1),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(7)
	);
PPM_34:PP_MIDDLE
	port map
	(
		INA => OPA(1),INB => INV_MULTIPLICAND(1),
		INC => OPA(2),IND => INV_MULTIPLICAND(2),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(9)
	);
PPM_35:PP_MIDDLE
	port map
	(
		INA => OPA(2),INB => INV_MULTIPLICAND(2),
		INC => OPA(3),IND => INV_MULTIPLICAND(3),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(13)
	);
PPM_36:PP_MIDDLE
	port map
	(
		INA => OPA(3),INB => INV_MULTIPLICAND(3),
		INC => OPA(4),IND => INV_MULTIPLICAND(4),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(16)
	);
PPM_37:PP_MIDDLE
	port map
	(
		INA => OPA(4),INB => INV_MULTIPLICAND(4),
		INC => OPA(5),IND => INV_MULTIPLICAND(5),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(21)
	);
PPM_38:PP_MIDDLE
	port map
	(
		INA => OPA(5),INB => INV_MULTIPLICAND(5),
		INC => OPA(6),IND => INV_MULTIPLICAND(6),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(25)
	);
PPM_39:PP_MIDDLE
	port map
	(
		INA => OPA(6),INB => INV_MULTIPLICAND(6),
		INC => OPA(7),IND => INV_MULTIPLICAND(7),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(31)
	);
PPM_40:PP_MIDDLE
	port map
	(
		INA => OPA(7),INB => INV_MULTIPLICAND(7),
		INC => OPA(8),IND => INV_MULTIPLICAND(8),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(36)
	);
PPM_41:PP_MIDDLE
	port map
	(
		INA => OPA(8),INB => INV_MULTIPLICAND(8),
		INC => OPA(9),IND => INV_MULTIPLICAND(9),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(41)
	);
PPM_42:PP_MIDDLE
	port map
	(
		INA => OPA(9),INB => INV_MULTIPLICAND(9),
		INC => OPA(10),IND => INV_MULTIPLICAND(10),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(46)
	);
PPM_43:PP_MIDDLE
	port map
	(
		INA => OPA(10),INB => INV_MULTIPLICAND(10),
		INC => OPA(11),IND => INV_MULTIPLICAND(11),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(51)
	);
PPM_44:PP_MIDDLE
	port map
	(
		INA => OPA(11),INB => INV_MULTIPLICAND(11),
		INC => OPA(12),IND => INV_MULTIPLICAND(12),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(56)
	);
PPM_45:PP_MIDDLE
	port map
	(
		INA => OPA(12),INB => INV_MULTIPLICAND(12),
		INC => OPA(13),IND => INV_MULTIPLICAND(13),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(61)
	);
PPM_46:PP_MIDDLE
	port map
	(
		INA => OPA(13),INB => INV_MULTIPLICAND(13),
		INC => OPA(14),IND => INV_MULTIPLICAND(14),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(66)
	);
PPM_47:PP_MIDDLE
	port map
	(
		INA => OPA(14),INB => INV_MULTIPLICAND(14),
		INC => OPA(15),IND => INV_MULTIPLICAND(15),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(71)
	);
PPM_48:PP_MIDDLE
	port map
	(
		INA => OPA(15),INB => INV_MULTIPLICAND(15),
		INC => OPA(16),IND => INV_MULTIPLICAND(16),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(76)
	);
PPM_49:PP_MIDDLE
	port map
	(
		INA => OPA(16),INB => INV_MULTIPLICAND(16),
		INC => OPA(17),IND => INV_MULTIPLICAND(17),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(81)
	);
PPM_50:PP_MIDDLE
	port map
	(
		INA => OPA(17),INB => INV_MULTIPLICAND(17),
		INC => OPA(18),IND => INV_MULTIPLICAND(18),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(86)
	);
PPM_51:PP_MIDDLE
	port map
	(
		INA => OPA(18),INB => INV_MULTIPLICAND(18),
		INC => OPA(19),IND => INV_MULTIPLICAND(19),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(91)
	);
PPM_52:PP_MIDDLE
	port map
	(
		INA => OPA(19),INB => INV_MULTIPLICAND(19),
		INC => OPA(20),IND => INV_MULTIPLICAND(20),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(96)
	);
PPM_53:PP_MIDDLE
	port map
	(
		INA => OPA(20),INB => INV_MULTIPLICAND(20),
		INC => OPA(21),IND => INV_MULTIPLICAND(21),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(101)
	);
PPM_54:PP_MIDDLE
	port map
	(
		INA => OPA(21),INB => INV_MULTIPLICAND(21),
		INC => OPA(22),IND => INV_MULTIPLICAND(22),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(106)
	);
PPM_55:PP_MIDDLE
	port map
	(
		INA => OPA(22),INB => INV_MULTIPLICAND(22),
		INC => OPA(23),IND => INV_MULTIPLICAND(23),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(111)
	);
PPM_56:PP_MIDDLE
	port map
	(
		INA => OPA(23),INB => INV_MULTIPLICAND(23),
		INC => OPA(24),IND => INV_MULTIPLICAND(24),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(116)
	);
PPM_57:PP_MIDDLE
	port map
	(
		INA => OPA(24),INB => INV_MULTIPLICAND(24),
		INC => OPA(25),IND => INV_MULTIPLICAND(25),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(121)
	);
PPM_58:PP_MIDDLE
	port map
	(
		INA => OPA(25),INB => INV_MULTIPLICAND(25),
		INC => OPA(26),IND => INV_MULTIPLICAND(26),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(126)
	);
PPM_59:PP_MIDDLE
	port map
	(
		INA => OPA(26),INB => INV_MULTIPLICAND(26),
		INC => OPA(27),IND => INV_MULTIPLICAND(27),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(131)
	);
PPM_60:PP_MIDDLE
	port map
	(
		INA => OPA(27),INB => INV_MULTIPLICAND(27),
		INC => OPA(28),IND => INV_MULTIPLICAND(28),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(136)
	);
PPM_61:PP_MIDDLE
	port map
	(
		INA => OPA(28),INB => INV_MULTIPLICAND(28),
		INC => OPA(29),IND => INV_MULTIPLICAND(29),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(141)
	);
PPM_62:PP_MIDDLE
	port map
	(
		INA => OPA(29),INB => INV_MULTIPLICAND(29),
		INC => OPA(30),IND => INV_MULTIPLICAND(30),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(146)
	);
PPM_63:PP_MIDDLE
	port map
	(
		INA => OPA(30),INB => INV_MULTIPLICAND(30),
		INC => OPA(31),IND => INV_MULTIPLICAND(31),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(151)
	);
PPM_64:PP_MIDDLE
	port map
	(
		INA => OPA(31),INB => INV_MULTIPLICAND(31),
		INC => OPA(32),IND => INV_MULTIPLICAND(32),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(157)
	);
PPM_65:PP_MIDDLE
	port map
	(
		INA => OPA(32),INB => INV_MULTIPLICAND(32),
		INC => OPA(33),IND => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(161)
	);
SUMMAND(162) <= LOGIC_ONE;
PPH_1:PP_HIGH
	port map
	(
		INA => OPA(33),INB => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(166)
	);
-- Begin partial product 2
-- Begin decoder block 3
DEC_2:DECODER -- Decoder of multiplier operand
	port map
	(
		INA => OPB(3),INB => OPB(4),INC => OPB(5),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11)
	);
-- End decoder block 3
-- Begin partial product 3
PPL_2:PP_LOW
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(10)
	);
RGATE_2:R_GATE
	port map
	(
		INA => OPB(3),INB => OPB(4),INC => OPB(5),
		PPBIT => SUMMAND(11)
	);
PPM_66:PP_MIDDLE
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		INC => OPA(1),IND => INV_MULTIPLICAND(1),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(14)
	);
PPM_67:PP_MIDDLE
	port map
	(
		INA => OPA(1),INB => INV_MULTIPLICAND(1),
		INC => OPA(2),IND => INV_MULTIPLICAND(2),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(17)
	);
PPM_68:PP_MIDDLE
	port map
	(
		INA => OPA(2),INB => INV_MULTIPLICAND(2),
		INC => OPA(3),IND => INV_MULTIPLICAND(3),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(22)
	);
PPM_69:PP_MIDDLE
	port map
	(
		INA => OPA(3),INB => INV_MULTIPLICAND(3),
		INC => OPA(4),IND => INV_MULTIPLICAND(4),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(26)
	);
PPM_70:PP_MIDDLE
	port map
	(
		INA => OPA(4),INB => INV_MULTIPLICAND(4),
		INC => OPA(5),IND => INV_MULTIPLICAND(5),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(32)
	);
PPM_71:PP_MIDDLE
	port map
	(
		INA => OPA(5),INB => INV_MULTIPLICAND(5),
		INC => OPA(6),IND => INV_MULTIPLICAND(6),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(37)
	);
PPM_72:PP_MIDDLE
	port map
	(
		INA => OPA(6),INB => INV_MULTIPLICAND(6),
		INC => OPA(7),IND => INV_MULTIPLICAND(7),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(42)
	);
PPM_73:PP_MIDDLE
	port map
	(
		INA => OPA(7),INB => INV_MULTIPLICAND(7),
		INC => OPA(8),IND => INV_MULTIPLICAND(8),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(47)
	);
PPM_74:PP_MIDDLE
	port map
	(
		INA => OPA(8),INB => INV_MULTIPLICAND(8),
		INC => OPA(9),IND => INV_MULTIPLICAND(9),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(52)
	);
PPM_75:PP_MIDDLE
	port map
	(
		INA => OPA(9),INB => INV_MULTIPLICAND(9),
		INC => OPA(10),IND => INV_MULTIPLICAND(10),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(57)
	);
PPM_76:PP_MIDDLE
	port map
	(
		INA => OPA(10),INB => INV_MULTIPLICAND(10),
		INC => OPA(11),IND => INV_MULTIPLICAND(11),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(62)
	);
PPM_77:PP_MIDDLE
	port map
	(
		INA => OPA(11),INB => INV_MULTIPLICAND(11),
		INC => OPA(12),IND => INV_MULTIPLICAND(12),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(67)
	);
PPM_78:PP_MIDDLE
	port map
	(
		INA => OPA(12),INB => INV_MULTIPLICAND(12),
		INC => OPA(13),IND => INV_MULTIPLICAND(13),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(72)
	);
PPM_79:PP_MIDDLE
	port map
	(
		INA => OPA(13),INB => INV_MULTIPLICAND(13),
		INC => OPA(14),IND => INV_MULTIPLICAND(14),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(77)
	);
PPM_80:PP_MIDDLE
	port map
	(
		INA => OPA(14),INB => INV_MULTIPLICAND(14),
		INC => OPA(15),IND => INV_MULTIPLICAND(15),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(82)
	);
PPM_81:PP_MIDDLE
	port map
	(
		INA => OPA(15),INB => INV_MULTIPLICAND(15),
		INC => OPA(16),IND => INV_MULTIPLICAND(16),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(87)
	);
PPM_82:PP_MIDDLE
	port map
	(
		INA => OPA(16),INB => INV_MULTIPLICAND(16),
		INC => OPA(17),IND => INV_MULTIPLICAND(17),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(92)
	);
PPM_83:PP_MIDDLE
	port map
	(
		INA => OPA(17),INB => INV_MULTIPLICAND(17),
		INC => OPA(18),IND => INV_MULTIPLICAND(18),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(97)
	);
PPM_84:PP_MIDDLE
	port map
	(
		INA => OPA(18),INB => INV_MULTIPLICAND(18),
		INC => OPA(19),IND => INV_MULTIPLICAND(19),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(102)
	);
PPM_85:PP_MIDDLE
	port map
	(
		INA => OPA(19),INB => INV_MULTIPLICAND(19),
		INC => OPA(20),IND => INV_MULTIPLICAND(20),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(107)
	);
PPM_86:PP_MIDDLE
	port map
	(
		INA => OPA(20),INB => INV_MULTIPLICAND(20),
		INC => OPA(21),IND => INV_MULTIPLICAND(21),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(112)
	);
PPM_87:PP_MIDDLE
	port map
	(
		INA => OPA(21),INB => INV_MULTIPLICAND(21),
		INC => OPA(22),IND => INV_MULTIPLICAND(22),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(117)
	);
PPM_88:PP_MIDDLE
	port map
	(
		INA => OPA(22),INB => INV_MULTIPLICAND(22),
		INC => OPA(23),IND => INV_MULTIPLICAND(23),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(122)
	);
PPM_89:PP_MIDDLE
	port map
	(
		INA => OPA(23),INB => INV_MULTIPLICAND(23),
		INC => OPA(24),IND => INV_MULTIPLICAND(24),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(127)
	);
PPM_90:PP_MIDDLE
	port map
	(
		INA => OPA(24),INB => INV_MULTIPLICAND(24),
		INC => OPA(25),IND => INV_MULTIPLICAND(25),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(132)
	);
PPM_91:PP_MIDDLE
	port map
	(
		INA => OPA(25),INB => INV_MULTIPLICAND(25),
		INC => OPA(26),IND => INV_MULTIPLICAND(26),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(137)
	);
PPM_92:PP_MIDDLE
	port map
	(
		INA => OPA(26),INB => INV_MULTIPLICAND(26),
		INC => OPA(27),IND => INV_MULTIPLICAND(27),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(142)
	);
PPM_93:PP_MIDDLE
	port map
	(
		INA => OPA(27),INB => INV_MULTIPLICAND(27),
		INC => OPA(28),IND => INV_MULTIPLICAND(28),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(147)
	);
PPM_94:PP_MIDDLE
	port map
	(
		INA => OPA(28),INB => INV_MULTIPLICAND(28),
		INC => OPA(29),IND => INV_MULTIPLICAND(29),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(152)
	);
PPM_95:PP_MIDDLE
	port map
	(
		INA => OPA(29),INB => INV_MULTIPLICAND(29),
		INC => OPA(30),IND => INV_MULTIPLICAND(30),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(158)
	);
PPM_96:PP_MIDDLE
	port map
	(
		INA => OPA(30),INB => INV_MULTIPLICAND(30),
		INC => OPA(31),IND => INV_MULTIPLICAND(31),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(163)
	);
PPM_97:PP_MIDDLE
	port map
	(
		INA => OPA(31),INB => INV_MULTIPLICAND(31),
		INC => OPA(32),IND => INV_MULTIPLICAND(32),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(167)
	);
PPM_98:PP_MIDDLE
	port map
	(
		INA => OPA(32),INB => INV_MULTIPLICAND(32),
		INC => OPA(33),IND => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(170)
	);
SUMMAND(171) <= LOGIC_ONE;
PPH_2:PP_HIGH
	port map
	(
		INA => OPA(33),INB => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(174)
	);
-- Begin partial product 3
-- Begin decoder block 4
DEC_3:DECODER -- Decoder of multiplier operand
	port map
	(
		INA => OPB(5),INB => OPB(6),INC => OPB(7),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15)
	);
-- End decoder block 4
-- Begin partial product 4
PPL_3:PP_LOW
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(18)
	);
RGATE_3:R_GATE
	port map
	(
		INA => OPB(5),INB => OPB(6),INC => OPB(7),
		PPBIT => SUMMAND(19)
	);
PPM_99:PP_MIDDLE
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		INC => OPA(1),IND => INV_MULTIPLICAND(1),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(23)
	);
PPM_100:PP_MIDDLE
	port map
	(
		INA => OPA(1),INB => INV_MULTIPLICAND(1),
		INC => OPA(2),IND => INV_MULTIPLICAND(2),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(27)
	);
PPM_101:PP_MIDDLE
	port map
	(
		INA => OPA(2),INB => INV_MULTIPLICAND(2),
		INC => OPA(3),IND => INV_MULTIPLICAND(3),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(33)
	);
PPM_102:PP_MIDDLE
	port map
	(
		INA => OPA(3),INB => INV_MULTIPLICAND(3),
		INC => OPA(4),IND => INV_MULTIPLICAND(4),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(38)
	);
PPM_103:PP_MIDDLE
	port map
	(
		INA => OPA(4),INB => INV_MULTIPLICAND(4),
		INC => OPA(5),IND => INV_MULTIPLICAND(5),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(43)
	);
PPM_104:PP_MIDDLE
	port map
	(
		INA => OPA(5),INB => INV_MULTIPLICAND(5),
		INC => OPA(6),IND => INV_MULTIPLICAND(6),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(48)
	);
PPM_105:PP_MIDDLE
	port map
	(
		INA => OPA(6),INB => INV_MULTIPLICAND(6),
		INC => OPA(7),IND => INV_MULTIPLICAND(7),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(53)
	);
PPM_106:PP_MIDDLE
	port map
	(
		INA => OPA(7),INB => INV_MULTIPLICAND(7),
		INC => OPA(8),IND => INV_MULTIPLICAND(8),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(58)
	);
PPM_107:PP_MIDDLE
	port map
	(
		INA => OPA(8),INB => INV_MULTIPLICAND(8),
		INC => OPA(9),IND => INV_MULTIPLICAND(9),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(63)
	);
PPM_108:PP_MIDDLE
	port map
	(
		INA => OPA(9),INB => INV_MULTIPLICAND(9),
		INC => OPA(10),IND => INV_MULTIPLICAND(10),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(68)
	);
PPM_109:PP_MIDDLE
	port map
	(
		INA => OPA(10),INB => INV_MULTIPLICAND(10),
		INC => OPA(11),IND => INV_MULTIPLICAND(11),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(73)
	);
PPM_110:PP_MIDDLE
	port map
	(
		INA => OPA(11),INB => INV_MULTIPLICAND(11),
		INC => OPA(12),IND => INV_MULTIPLICAND(12),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(78)
	);
PPM_111:PP_MIDDLE
	port map
	(
		INA => OPA(12),INB => INV_MULTIPLICAND(12),
		INC => OPA(13),IND => INV_MULTIPLICAND(13),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(83)
	);
PPM_112:PP_MIDDLE
	port map
	(
		INA => OPA(13),INB => INV_MULTIPLICAND(13),
		INC => OPA(14),IND => INV_MULTIPLICAND(14),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(88)
	);
PPM_113:PP_MIDDLE
	port map
	(
		INA => OPA(14),INB => INV_MULTIPLICAND(14),
		INC => OPA(15),IND => INV_MULTIPLICAND(15),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(93)
	);
PPM_114:PP_MIDDLE
	port map
	(
		INA => OPA(15),INB => INV_MULTIPLICAND(15),
		INC => OPA(16),IND => INV_MULTIPLICAND(16),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(98)
	);
PPM_115:PP_MIDDLE
	port map
	(
		INA => OPA(16),INB => INV_MULTIPLICAND(16),
		INC => OPA(17),IND => INV_MULTIPLICAND(17),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(103)
	);
PPM_116:PP_MIDDLE
	port map
	(
		INA => OPA(17),INB => INV_MULTIPLICAND(17),
		INC => OPA(18),IND => INV_MULTIPLICAND(18),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(108)
	);
PPM_117:PP_MIDDLE
	port map
	(
		INA => OPA(18),INB => INV_MULTIPLICAND(18),
		INC => OPA(19),IND => INV_MULTIPLICAND(19),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(113)
	);
PPM_118:PP_MIDDLE
	port map
	(
		INA => OPA(19),INB => INV_MULTIPLICAND(19),
		INC => OPA(20),IND => INV_MULTIPLICAND(20),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(118)
	);
PPM_119:PP_MIDDLE
	port map
	(
		INA => OPA(20),INB => INV_MULTIPLICAND(20),
		INC => OPA(21),IND => INV_MULTIPLICAND(21),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(123)
	);
PPM_120:PP_MIDDLE
	port map
	(
		INA => OPA(21),INB => INV_MULTIPLICAND(21),
		INC => OPA(22),IND => INV_MULTIPLICAND(22),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(128)
	);
PPM_121:PP_MIDDLE
	port map
	(
		INA => OPA(22),INB => INV_MULTIPLICAND(22),
		INC => OPA(23),IND => INV_MULTIPLICAND(23),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(133)
	);
PPM_122:PP_MIDDLE
	port map
	(
		INA => OPA(23),INB => INV_MULTIPLICAND(23),
		INC => OPA(24),IND => INV_MULTIPLICAND(24),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(138)
	);
PPM_123:PP_MIDDLE
	port map
	(
		INA => OPA(24),INB => INV_MULTIPLICAND(24),
		INC => OPA(25),IND => INV_MULTIPLICAND(25),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(143)
	);
PPM_124:PP_MIDDLE
	port map
	(
		INA => OPA(25),INB => INV_MULTIPLICAND(25),
		INC => OPA(26),IND => INV_MULTIPLICAND(26),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(148)
	);
PPM_125:PP_MIDDLE
	port map
	(
		INA => OPA(26),INB => INV_MULTIPLICAND(26),
		INC => OPA(27),IND => INV_MULTIPLICAND(27),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(153)
	);
PPM_126:PP_MIDDLE
	port map
	(
		INA => OPA(27),INB => INV_MULTIPLICAND(27),
		INC => OPA(28),IND => INV_MULTIPLICAND(28),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(159)
	);
PPM_127:PP_MIDDLE
	port map
	(
		INA => OPA(28),INB => INV_MULTIPLICAND(28),
		INC => OPA(29),IND => INV_MULTIPLICAND(29),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(164)
	);
PPM_128:PP_MIDDLE
	port map
	(
		INA => OPA(29),INB => INV_MULTIPLICAND(29),
		INC => OPA(30),IND => INV_MULTIPLICAND(30),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(168)
	);
PPM_129:PP_MIDDLE
	port map
	(
		INA => OPA(30),INB => INV_MULTIPLICAND(30),
		INC => OPA(31),IND => INV_MULTIPLICAND(31),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(172)
	);
PPM_130:PP_MIDDLE
	port map
	(
		INA => OPA(31),INB => INV_MULTIPLICAND(31),
		INC => OPA(32),IND => INV_MULTIPLICAND(32),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(175)
	);
PPM_131:PP_MIDDLE
	port map
	(
		INA => OPA(32),INB => INV_MULTIPLICAND(32),
		INC => OPA(33),IND => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(177)
	);
SUMMAND(178) <= LOGIC_ONE;
PPH_3:PP_HIGH
	port map
	(
		INA => OPA(33),INB => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(180)
	);
-- Begin partial product 4
-- Begin decoder block 5
DEC_4:DECODER -- Decoder of multiplier operand
	port map
	(
		INA => OPB(7),INB => OPB(8),INC => OPB(9),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19)
	);
-- End decoder block 5
-- Begin partial product 5
PPL_4:PP_LOW
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(28)
	);
RGATE_4:R_GATE
	port map
	(
		INA => OPB(7),INB => OPB(8),INC => OPB(9),
		PPBIT => SUMMAND(29)
	);
PPM_132:PP_MIDDLE
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		INC => OPA(1),IND => INV_MULTIPLICAND(1),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(34)
	);
PPM_133:PP_MIDDLE
	port map
	(
		INA => OPA(1),INB => INV_MULTIPLICAND(1),
		INC => OPA(2),IND => INV_MULTIPLICAND(2),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(39)
	);
PPM_134:PP_MIDDLE
	port map
	(
		INA => OPA(2),INB => INV_MULTIPLICAND(2),
		INC => OPA(3),IND => INV_MULTIPLICAND(3),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(44)
	);
PPM_135:PP_MIDDLE
	port map
	(
		INA => OPA(3),INB => INV_MULTIPLICAND(3),
		INC => OPA(4),IND => INV_MULTIPLICAND(4),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(49)
	);
PPM_136:PP_MIDDLE
	port map
	(
		INA => OPA(4),INB => INV_MULTIPLICAND(4),
		INC => OPA(5),IND => INV_MULTIPLICAND(5),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(54)
	);
PPM_137:PP_MIDDLE
	port map
	(
		INA => OPA(5),INB => INV_MULTIPLICAND(5),
		INC => OPA(6),IND => INV_MULTIPLICAND(6),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(59)
	);
PPM_138:PP_MIDDLE
	port map
	(
		INA => OPA(6),INB => INV_MULTIPLICAND(6),
		INC => OPA(7),IND => INV_MULTIPLICAND(7),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(64)
	);
PPM_139:PP_MIDDLE
	port map
	(
		INA => OPA(7),INB => INV_MULTIPLICAND(7),
		INC => OPA(8),IND => INV_MULTIPLICAND(8),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(69)
	);
PPM_140:PP_MIDDLE
	port map
	(
		INA => OPA(8),INB => INV_MULTIPLICAND(8),
		INC => OPA(9),IND => INV_MULTIPLICAND(9),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(74)
	);
PPM_141:PP_MIDDLE
	port map
	(
		INA => OPA(9),INB => INV_MULTIPLICAND(9),
		INC => OPA(10),IND => INV_MULTIPLICAND(10),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(79)
	);
PPM_142:PP_MIDDLE
	port map
	(
		INA => OPA(10),INB => INV_MULTIPLICAND(10),
		INC => OPA(11),IND => INV_MULTIPLICAND(11),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(84)
	);
PPM_143:PP_MIDDLE
	port map
	(
		INA => OPA(11),INB => INV_MULTIPLICAND(11),
		INC => OPA(12),IND => INV_MULTIPLICAND(12),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(89)
	);
PPM_144:PP_MIDDLE
	port map
	(
		INA => OPA(12),INB => INV_MULTIPLICAND(12),
		INC => OPA(13),IND => INV_MULTIPLICAND(13),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(94)
	);
PPM_145:PP_MIDDLE
	port map
	(
		INA => OPA(13),INB => INV_MULTIPLICAND(13),
		INC => OPA(14),IND => INV_MULTIPLICAND(14),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(99)
	);
PPM_146:PP_MIDDLE
	port map
	(
		INA => OPA(14),INB => INV_MULTIPLICAND(14),
		INC => OPA(15),IND => INV_MULTIPLICAND(15),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(104)
	);
PPM_147:PP_MIDDLE
	port map
	(
		INA => OPA(15),INB => INV_MULTIPLICAND(15),
		INC => OPA(16),IND => INV_MULTIPLICAND(16),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(109)
	);
PPM_148:PP_MIDDLE
	port map
	(
		INA => OPA(16),INB => INV_MULTIPLICAND(16),
		INC => OPA(17),IND => INV_MULTIPLICAND(17),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(114)
	);
PPM_149:PP_MIDDLE
	port map
	(
		INA => OPA(17),INB => INV_MULTIPLICAND(17),
		INC => OPA(18),IND => INV_MULTIPLICAND(18),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(119)
	);
PPM_150:PP_MIDDLE
	port map
	(
		INA => OPA(18),INB => INV_MULTIPLICAND(18),
		INC => OPA(19),IND => INV_MULTIPLICAND(19),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(124)
	);
PPM_151:PP_MIDDLE
	port map
	(
		INA => OPA(19),INB => INV_MULTIPLICAND(19),
		INC => OPA(20),IND => INV_MULTIPLICAND(20),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(129)
	);
PPM_152:PP_MIDDLE
	port map
	(
		INA => OPA(20),INB => INV_MULTIPLICAND(20),
		INC => OPA(21),IND => INV_MULTIPLICAND(21),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(134)
	);
PPM_153:PP_MIDDLE
	port map
	(
		INA => OPA(21),INB => INV_MULTIPLICAND(21),
		INC => OPA(22),IND => INV_MULTIPLICAND(22),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(139)
	);
PPM_154:PP_MIDDLE
	port map
	(
		INA => OPA(22),INB => INV_MULTIPLICAND(22),
		INC => OPA(23),IND => INV_MULTIPLICAND(23),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(144)
	);
PPM_155:PP_MIDDLE
	port map
	(
		INA => OPA(23),INB => INV_MULTIPLICAND(23),
		INC => OPA(24),IND => INV_MULTIPLICAND(24),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(149)
	);
PPM_156:PP_MIDDLE
	port map
	(
		INA => OPA(24),INB => INV_MULTIPLICAND(24),
		INC => OPA(25),IND => INV_MULTIPLICAND(25),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(154)
	);
PPM_157:PP_MIDDLE
	port map
	(
		INA => OPA(25),INB => INV_MULTIPLICAND(25),
		INC => OPA(26),IND => INV_MULTIPLICAND(26),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(160)
	);
PPM_158:PP_MIDDLE
	port map
	(
		INA => OPA(26),INB => INV_MULTIPLICAND(26),
		INC => OPA(27),IND => INV_MULTIPLICAND(27),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(165)
	);
PPM_159:PP_MIDDLE
	port map
	(
		INA => OPA(27),INB => INV_MULTIPLICAND(27),
		INC => OPA(28),IND => INV_MULTIPLICAND(28),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(169)
	);
PPM_160:PP_MIDDLE
	port map
	(
		INA => OPA(28),INB => INV_MULTIPLICAND(28),
		INC => OPA(29),IND => INV_MULTIPLICAND(29),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(173)
	);
PPM_161:PP_MIDDLE
	port map
	(
		INA => OPA(29),INB => INV_MULTIPLICAND(29),
		INC => OPA(30),IND => INV_MULTIPLICAND(30),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(176)
	);
PPM_162:PP_MIDDLE
	port map
	(
		INA => OPA(30),INB => INV_MULTIPLICAND(30),
		INC => OPA(31),IND => INV_MULTIPLICAND(31),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(179)
	);
PPM_163:PP_MIDDLE
	port map
	(
		INA => OPA(31),INB => INV_MULTIPLICAND(31),
		INC => OPA(32),IND => INV_MULTIPLICAND(32),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(181)
	);
PPM_164:PP_MIDDLE
	port map
	(
		INA => OPA(32),INB => INV_MULTIPLICAND(32),
		INC => OPA(33),IND => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(182)
	);
SUMMAND(183) <= LOGIC_ONE;
PPH_4:PP_HIGH
	port map
	(
		INA => OPA(33),INB => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(184)
	);
-- Begin partial product 5
end BOOTHCODER;
------------------------------------------------------------
-- END: Architectures used with the Modified Booth recoding
------------------------------------------------------------

------------------------------------------------------------
-- START: Architectures used with the Wallace-tree
------------------------------------------------------------
--
-- Wallace tree architecture
--
library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.blocks.all;
entity WALLACE_34_10 is
port
(
	SUMMAND: in std_logic_vector(0 to 184);
	CARRY: out std_logic_vector(0 to 41);
	SUM: out std_logic_vector(0 to 42)
);
end WALLACE_34_10;
architecture WALLACE of WALLACE_34_10 is

	signal INT_CARRY: std_logic_vector(0 to 95);
	signal INT_SUM: std_logic_vector(0 to 133);

begin -- netlist

-- Begin WT-branch 1
---- Begin HA stage
HA_0:HALF_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(0), DATA_B => SUMMAND(1), 
		SAVE => SUM(0), CARRY => CARRY(0)
	);
---- End HA stage
-- End WT-branch 1

-- Begin WT-branch 2
---- Begin NO stage
SUM(1) <= SUMMAND(2); -- At Level 1
CARRY(1) <= '0';
---- End NO stage
-- End WT-branch 2

-- Begin WT-branch 3
---- Begin FA stage
FA_0:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(3), DATA_B => SUMMAND(4), DATA_C => SUMMAND(5), 
		SAVE => SUM(2), CARRY => CARRY(2)
	);
---- End FA stage
-- End WT-branch 3

-- Begin WT-branch 4
---- Begin HA stage
HA_1:HALF_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(6), DATA_B => SUMMAND(7), 
		SAVE => SUM(3), CARRY => CARRY(3)
	);
---- End HA stage
-- End WT-branch 4

-- Begin WT-branch 5
---- Begin FA stage
FA_1:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(8), DATA_B => SUMMAND(9), DATA_C => SUMMAND(10), 
		SAVE => INT_SUM(0), CARRY => INT_CARRY(0)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(1) <= SUMMAND(11); -- At Level 1
---- End NO stage
---- Begin HA stage
HA_2:HALF_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(0), DATA_B => INT_SUM(1), 
		SAVE => SUM(4), CARRY => CARRY(4)
	);
---- End HA stage
-- End WT-branch 5

-- Begin WT-branch 6
---- Begin FA stage
FA_2:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(12), DATA_B => SUMMAND(13), DATA_C => SUMMAND(14), 
		SAVE => INT_SUM(2), CARRY => INT_CARRY(1)
	);
---- End FA stage
---- Begin HA stage
HA_3:HALF_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(2), DATA_B => INT_CARRY(0), 
		SAVE => SUM(5), CARRY => CARRY(5)
	);
---- End HA stage
-- End WT-branch 6

-- Begin WT-branch 7
---- Begin FA stage
FA_3:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(15), DATA_B => SUMMAND(16), DATA_C => SUMMAND(17), 
		SAVE => INT_SUM(3), CARRY => INT_CARRY(2)
	);
---- End FA stage
---- Begin HA stage
HA_4:HALF_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(18), DATA_B => SUMMAND(19), 
		SAVE => INT_SUM(4), CARRY => INT_CARRY(3)
	);
---- End HA stage
---- Begin FA stage
FA_4:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(3), DATA_B => INT_SUM(4), DATA_C => INT_CARRY(1), 
		SAVE => SUM(6), CARRY => CARRY(6)
	);
---- End FA stage
-- End WT-branch 7

-- Begin WT-branch 8
---- Begin FA stage
FA_5:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(20), DATA_B => SUMMAND(21), DATA_C => SUMMAND(22), 
		SAVE => INT_SUM(5), CARRY => INT_CARRY(4)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(6) <= SUMMAND(23); -- At Level 1
---- End NO stage
---- Begin FA stage
FA_6:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(5), DATA_B => INT_SUM(6), DATA_C => INT_CARRY(2), 
		SAVE => INT_SUM(7), CARRY => INT_CARRY(5)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(8) <= INT_CARRY(3); -- At Level 2
---- End NO stage
---- Begin HA stage
HA_5:HALF_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(7), DATA_B => INT_SUM(8), 
		SAVE => SUM(7), CARRY => CARRY(7)
	);
---- End HA stage
-- End WT-branch 8

-- Begin WT-branch 9
---- Begin FA stage
FA_7:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(24), DATA_B => SUMMAND(25), DATA_C => SUMMAND(26), 
		SAVE => INT_SUM(9), CARRY => INT_CARRY(6)
	);
---- End FA stage
---- Begin FA stage
FA_8:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(27), DATA_B => SUMMAND(28), DATA_C => SUMMAND(29), 
		SAVE => INT_SUM(10), CARRY => INT_CARRY(7)
	);
---- End FA stage
---- Begin FA stage
FA_9:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(9), DATA_B => INT_SUM(10), DATA_C => INT_CARRY(4), 
		SAVE => INT_SUM(11), CARRY => INT_CARRY(8)
	);
---- End FA stage
---- Begin HA stage
HA_6:HALF_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(11), DATA_B => INT_CARRY(5), 
		SAVE => SUM(8), CARRY => CARRY(8)
	);
---- End HA stage
-- End WT-branch 9

-- Begin WT-branch 10
---- Begin FA stage
FA_10:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(30), DATA_B => SUMMAND(31), DATA_C => SUMMAND(32), 
		SAVE => INT_SUM(12), CARRY => INT_CARRY(9)
	);
---- End FA stage
---- Begin HA stage
HA_7:HALF_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(33), DATA_B => SUMMAND(34), 
		SAVE => INT_SUM(13), CARRY => INT_CARRY(10)
	);
---- End HA stage
---- Begin FA stage
FA_11:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(12), DATA_B => INT_SUM(13), DATA_C => INT_CARRY(6), 
		SAVE => INT_SUM(14), CARRY => INT_CARRY(11)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(15) <= INT_CARRY(7); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_12:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(14), DATA_B => INT_SUM(15), DATA_C => INT_CARRY(8), 
		SAVE => SUM(9), CARRY => CARRY(9)
	);
---- End FA stage
-- End WT-branch 10

-- Begin WT-branch 11
---- Begin FA stage
FA_13:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(35), DATA_B => SUMMAND(36), DATA_C => SUMMAND(37), 
		SAVE => INT_SUM(16), CARRY => INT_CARRY(12)
	);
---- End FA stage
---- Begin HA stage
HA_8:HALF_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(38), DATA_B => SUMMAND(39), 
		SAVE => INT_SUM(17), CARRY => INT_CARRY(13)
	);
---- End HA stage
---- Begin FA stage
FA_14:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(16), DATA_B => INT_SUM(17), DATA_C => INT_CARRY(9), 
		SAVE => INT_SUM(18), CARRY => INT_CARRY(14)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(19) <= INT_CARRY(10); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_15:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(18), DATA_B => INT_SUM(19), DATA_C => INT_CARRY(11), 
		SAVE => SUM(10), CARRY => CARRY(10)
	);
---- End FA stage
-- End WT-branch 11

-- Begin WT-branch 12
---- Begin FA stage
FA_16:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(40), DATA_B => SUMMAND(41), DATA_C => SUMMAND(42), 
		SAVE => INT_SUM(20), CARRY => INT_CARRY(15)
	);
---- End FA stage
---- Begin HA stage
HA_9:HALF_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(43), DATA_B => SUMMAND(44), 
		SAVE => INT_SUM(21), CARRY => INT_CARRY(16)
	);
---- End HA stage
---- Begin FA stage
FA_17:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(20), DATA_B => INT_SUM(21), DATA_C => INT_CARRY(12), 
		SAVE => INT_SUM(22), CARRY => INT_CARRY(17)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(23) <= INT_CARRY(13); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_18:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(22), DATA_B => INT_SUM(23), DATA_C => INT_CARRY(14), 
		SAVE => SUM(11), CARRY => CARRY(11)
	);
---- End FA stage
-- End WT-branch 12

-- Begin WT-branch 13
---- Begin FA stage
FA_19:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(45), DATA_B => SUMMAND(46), DATA_C => SUMMAND(47), 
		SAVE => INT_SUM(24), CARRY => INT_CARRY(18)
	);
---- End FA stage
---- Begin HA stage
HA_10:HALF_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(48), DATA_B => SUMMAND(49), 
		SAVE => INT_SUM(25), CARRY => INT_CARRY(19)
	);
---- End HA stage
---- Begin FA stage
FA_20:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(24), DATA_B => INT_SUM(25), DATA_C => INT_CARRY(15), 
		SAVE => INT_SUM(26), CARRY => INT_CARRY(20)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(27) <= INT_CARRY(16); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_21:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(26), DATA_B => INT_SUM(27), DATA_C => INT_CARRY(17), 
		SAVE => SUM(12), CARRY => CARRY(12)
	);
---- End FA stage
-- End WT-branch 13

-- Begin WT-branch 14
---- Begin FA stage
FA_22:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(50), DATA_B => SUMMAND(51), DATA_C => SUMMAND(52), 
		SAVE => INT_SUM(28), CARRY => INT_CARRY(21)
	);
---- End FA stage
---- Begin HA stage
HA_11:HALF_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(53), DATA_B => SUMMAND(54), 
		SAVE => INT_SUM(29), CARRY => INT_CARRY(22)
	);
---- End HA stage
---- Begin FA stage
FA_23:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(28), DATA_B => INT_SUM(29), DATA_C => INT_CARRY(18), 
		SAVE => INT_SUM(30), CARRY => INT_CARRY(23)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(31) <= INT_CARRY(19); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_24:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(30), DATA_B => INT_SUM(31), DATA_C => INT_CARRY(20), 
		SAVE => SUM(13), CARRY => CARRY(13)
	);
---- End FA stage
-- End WT-branch 14

-- Begin WT-branch 15
---- Begin FA stage
FA_25:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(55), DATA_B => SUMMAND(56), DATA_C => SUMMAND(57), 
		SAVE => INT_SUM(32), CARRY => INT_CARRY(24)
	);
---- End FA stage
---- Begin HA stage
HA_12:HALF_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(58), DATA_B => SUMMAND(59), 
		SAVE => INT_SUM(33), CARRY => INT_CARRY(25)
	);
---- End HA stage
---- Begin FA stage
FA_26:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(32), DATA_B => INT_SUM(33), DATA_C => INT_CARRY(21), 
		SAVE => INT_SUM(34), CARRY => INT_CARRY(26)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(35) <= INT_CARRY(22); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_27:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(34), DATA_B => INT_SUM(35), DATA_C => INT_CARRY(23), 
		SAVE => SUM(14), CARRY => CARRY(14)
	);
---- End FA stage
-- End WT-branch 15

-- Begin WT-branch 16
---- Begin FA stage
FA_28:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(60), DATA_B => SUMMAND(61), DATA_C => SUMMAND(62), 
		SAVE => INT_SUM(36), CARRY => INT_CARRY(27)
	);
---- End FA stage
---- Begin HA stage
HA_13:HALF_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(63), DATA_B => SUMMAND(64), 
		SAVE => INT_SUM(37), CARRY => INT_CARRY(28)
	);
---- End HA stage
---- Begin FA stage
FA_29:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(36), DATA_B => INT_SUM(37), DATA_C => INT_CARRY(24), 
		SAVE => INT_SUM(38), CARRY => INT_CARRY(29)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(39) <= INT_CARRY(25); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_30:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(38), DATA_B => INT_SUM(39), DATA_C => INT_CARRY(26), 
		SAVE => SUM(15), CARRY => CARRY(15)
	);
---- End FA stage
-- End WT-branch 16

-- Begin WT-branch 17
---- Begin FA stage
FA_31:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(65), DATA_B => SUMMAND(66), DATA_C => SUMMAND(67), 
		SAVE => INT_SUM(40), CARRY => INT_CARRY(30)
	);
---- End FA stage
---- Begin HA stage
HA_14:HALF_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(68), DATA_B => SUMMAND(69), 
		SAVE => INT_SUM(41), CARRY => INT_CARRY(31)
	);
---- End HA stage
---- Begin FA stage
FA_32:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(40), DATA_B => INT_SUM(41), DATA_C => INT_CARRY(27), 
		SAVE => INT_SUM(42), CARRY => INT_CARRY(32)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(43) <= INT_CARRY(28); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_33:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(42), DATA_B => INT_SUM(43), DATA_C => INT_CARRY(29), 
		SAVE => SUM(16), CARRY => CARRY(16)
	);
---- End FA stage
-- End WT-branch 17

-- Begin WT-branch 18
---- Begin FA stage
FA_34:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(70), DATA_B => SUMMAND(71), DATA_C => SUMMAND(72), 
		SAVE => INT_SUM(44), CARRY => INT_CARRY(33)
	);
---- End FA stage
---- Begin HA stage
HA_15:HALF_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(73), DATA_B => SUMMAND(74), 
		SAVE => INT_SUM(45), CARRY => INT_CARRY(34)
	);
---- End HA stage
---- Begin FA stage
FA_35:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(44), DATA_B => INT_SUM(45), DATA_C => INT_CARRY(30), 
		SAVE => INT_SUM(46), CARRY => INT_CARRY(35)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(47) <= INT_CARRY(31); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_36:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(46), DATA_B => INT_SUM(47), DATA_C => INT_CARRY(32), 
		SAVE => SUM(17), CARRY => CARRY(17)
	);
---- End FA stage
-- End WT-branch 18

-- Begin WT-branch 19
---- Begin FA stage
FA_37:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(75), DATA_B => SUMMAND(76), DATA_C => SUMMAND(77), 
		SAVE => INT_SUM(48), CARRY => INT_CARRY(36)
	);
---- End FA stage
---- Begin HA stage
HA_16:HALF_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(78), DATA_B => SUMMAND(79), 
		SAVE => INT_SUM(49), CARRY => INT_CARRY(37)
	);
---- End HA stage
---- Begin FA stage
FA_38:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(48), DATA_B => INT_SUM(49), DATA_C => INT_CARRY(33), 
		SAVE => INT_SUM(50), CARRY => INT_CARRY(38)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(51) <= INT_CARRY(34); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_39:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(50), DATA_B => INT_SUM(51), DATA_C => INT_CARRY(35), 
		SAVE => SUM(18), CARRY => CARRY(18)
	);
---- End FA stage
-- End WT-branch 19

-- Begin WT-branch 20
---- Begin FA stage
FA_40:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(80), DATA_B => SUMMAND(81), DATA_C => SUMMAND(82), 
		SAVE => INT_SUM(52), CARRY => INT_CARRY(39)
	);
---- End FA stage
---- Begin HA stage
HA_17:HALF_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(83), DATA_B => SUMMAND(84), 
		SAVE => INT_SUM(53), CARRY => INT_CARRY(40)
	);
---- End HA stage
---- Begin FA stage
FA_41:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(52), DATA_B => INT_SUM(53), DATA_C => INT_CARRY(36), 
		SAVE => INT_SUM(54), CARRY => INT_CARRY(41)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(55) <= INT_CARRY(37); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_42:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(54), DATA_B => INT_SUM(55), DATA_C => INT_CARRY(38), 
		SAVE => SUM(19), CARRY => CARRY(19)
	);
---- End FA stage
-- End WT-branch 20

-- Begin WT-branch 21
---- Begin FA stage
FA_43:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(85), DATA_B => SUMMAND(86), DATA_C => SUMMAND(87), 
		SAVE => INT_SUM(56), CARRY => INT_CARRY(42)
	);
---- End FA stage
---- Begin HA stage
HA_18:HALF_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(88), DATA_B => SUMMAND(89), 
		SAVE => INT_SUM(57), CARRY => INT_CARRY(43)
	);
---- End HA stage
---- Begin FA stage
FA_44:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(56), DATA_B => INT_SUM(57), DATA_C => INT_CARRY(39), 
		SAVE => INT_SUM(58), CARRY => INT_CARRY(44)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(59) <= INT_CARRY(40); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_45:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(58), DATA_B => INT_SUM(59), DATA_C => INT_CARRY(41), 
		SAVE => SUM(20), CARRY => CARRY(20)
	);
---- End FA stage
-- End WT-branch 21

-- Begin WT-branch 22
---- Begin FA stage
FA_46:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(90), DATA_B => SUMMAND(91), DATA_C => SUMMAND(92), 
		SAVE => INT_SUM(60), CARRY => INT_CARRY(45)
	);
---- End FA stage
---- Begin HA stage
HA_19:HALF_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(93), DATA_B => SUMMAND(94), 
		SAVE => INT_SUM(61), CARRY => INT_CARRY(46)
	);
---- End HA stage
---- Begin FA stage
FA_47:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(60), DATA_B => INT_SUM(61), DATA_C => INT_CARRY(42), 
		SAVE => INT_SUM(62), CARRY => INT_CARRY(47)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(63) <= INT_CARRY(43); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_48:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(62), DATA_B => INT_SUM(63), DATA_C => INT_CARRY(44), 
		SAVE => SUM(21), CARRY => CARRY(21)
	);
---- End FA stage
-- End WT-branch 22

-- Begin WT-branch 23
---- Begin FA stage
FA_49:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(95), DATA_B => SUMMAND(96), DATA_C => SUMMAND(97), 
		SAVE => INT_SUM(64), CARRY => INT_CARRY(48)
	);
---- End FA stage
---- Begin HA stage
HA_20:HALF_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(98), DATA_B => SUMMAND(99), 
		SAVE => INT_SUM(65), CARRY => INT_CARRY(49)
	);
---- End HA stage
---- Begin FA stage
FA_50:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(64), DATA_B => INT_SUM(65), DATA_C => INT_CARRY(45), 
		SAVE => INT_SUM(66), CARRY => INT_CARRY(50)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(67) <= INT_CARRY(46); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_51:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(66), DATA_B => INT_SUM(67), DATA_C => INT_CARRY(47), 
		SAVE => SUM(22), CARRY => CARRY(22)
	);
---- End FA stage
-- End WT-branch 23

-- Begin WT-branch 24
---- Begin FA stage
FA_52:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(100), DATA_B => SUMMAND(101), DATA_C => SUMMAND(102), 
		SAVE => INT_SUM(68), CARRY => INT_CARRY(51)
	);
---- End FA stage
---- Begin HA stage
HA_21:HALF_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(103), DATA_B => SUMMAND(104), 
		SAVE => INT_SUM(69), CARRY => INT_CARRY(52)
	);
---- End HA stage
---- Begin FA stage
FA_53:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(68), DATA_B => INT_SUM(69), DATA_C => INT_CARRY(48), 
		SAVE => INT_SUM(70), CARRY => INT_CARRY(53)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(71) <= INT_CARRY(49); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_54:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(70), DATA_B => INT_SUM(71), DATA_C => INT_CARRY(50), 
		SAVE => SUM(23), CARRY => CARRY(23)
	);
---- End FA stage
-- End WT-branch 24

-- Begin WT-branch 25
---- Begin FA stage
FA_55:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(105), DATA_B => SUMMAND(106), DATA_C => SUMMAND(107), 
		SAVE => INT_SUM(72), CARRY => INT_CARRY(54)
	);
---- End FA stage
---- Begin HA stage
HA_22:HALF_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(108), DATA_B => SUMMAND(109), 
		SAVE => INT_SUM(73), CARRY => INT_CARRY(55)
	);
---- End HA stage
---- Begin FA stage
FA_56:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(72), DATA_B => INT_SUM(73), DATA_C => INT_CARRY(51), 
		SAVE => INT_SUM(74), CARRY => INT_CARRY(56)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(75) <= INT_CARRY(52); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_57:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(74), DATA_B => INT_SUM(75), DATA_C => INT_CARRY(53), 
		SAVE => SUM(24), CARRY => CARRY(24)
	);
---- End FA stage
-- End WT-branch 25

-- Begin WT-branch 26
---- Begin FA stage
FA_58:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(110), DATA_B => SUMMAND(111), DATA_C => SUMMAND(112), 
		SAVE => INT_SUM(76), CARRY => INT_CARRY(57)
	);
---- End FA stage
---- Begin HA stage
HA_23:HALF_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(113), DATA_B => SUMMAND(114), 
		SAVE => INT_SUM(77), CARRY => INT_CARRY(58)
	);
---- End HA stage
---- Begin FA stage
FA_59:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(76), DATA_B => INT_SUM(77), DATA_C => INT_CARRY(54), 
		SAVE => INT_SUM(78), CARRY => INT_CARRY(59)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(79) <= INT_CARRY(55); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_60:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(78), DATA_B => INT_SUM(79), DATA_C => INT_CARRY(56), 
		SAVE => SUM(25), CARRY => CARRY(25)
	);
---- End FA stage
-- End WT-branch 26

-- Begin WT-branch 27
---- Begin FA stage
FA_61:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(115), DATA_B => SUMMAND(116), DATA_C => SUMMAND(117), 
		SAVE => INT_SUM(80), CARRY => INT_CARRY(60)
	);
---- End FA stage
---- Begin HA stage
HA_24:HALF_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(118), DATA_B => SUMMAND(119), 
		SAVE => INT_SUM(81), CARRY => INT_CARRY(61)
	);
---- End HA stage
---- Begin FA stage
FA_62:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(80), DATA_B => INT_SUM(81), DATA_C => INT_CARRY(57), 
		SAVE => INT_SUM(82), CARRY => INT_CARRY(62)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(83) <= INT_CARRY(58); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_63:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(82), DATA_B => INT_SUM(83), DATA_C => INT_CARRY(59), 
		SAVE => SUM(26), CARRY => CARRY(26)
	);
---- End FA stage
-- End WT-branch 27

-- Begin WT-branch 28
---- Begin FA stage
FA_64:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(120), DATA_B => SUMMAND(121), DATA_C => SUMMAND(122), 
		SAVE => INT_SUM(84), CARRY => INT_CARRY(63)
	);
---- End FA stage
---- Begin HA stage
HA_25:HALF_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(123), DATA_B => SUMMAND(124), 
		SAVE => INT_SUM(85), CARRY => INT_CARRY(64)
	);
---- End HA stage
---- Begin FA stage
FA_65:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(84), DATA_B => INT_SUM(85), DATA_C => INT_CARRY(60), 
		SAVE => INT_SUM(86), CARRY => INT_CARRY(65)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(87) <= INT_CARRY(61); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_66:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(86), DATA_B => INT_SUM(87), DATA_C => INT_CARRY(62), 
		SAVE => SUM(27), CARRY => CARRY(27)
	);
---- End FA stage
-- End WT-branch 28

-- Begin WT-branch 29
---- Begin FA stage
FA_67:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(125), DATA_B => SUMMAND(126), DATA_C => SUMMAND(127), 
		SAVE => INT_SUM(88), CARRY => INT_CARRY(66)
	);
---- End FA stage
---- Begin HA stage
HA_26:HALF_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(128), DATA_B => SUMMAND(129), 
		SAVE => INT_SUM(89), CARRY => INT_CARRY(67)
	);
---- End HA stage
---- Begin FA stage
FA_68:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(88), DATA_B => INT_SUM(89), DATA_C => INT_CARRY(63), 
		SAVE => INT_SUM(90), CARRY => INT_CARRY(68)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(91) <= INT_CARRY(64); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_69:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(90), DATA_B => INT_SUM(91), DATA_C => INT_CARRY(65), 
		SAVE => SUM(28), CARRY => CARRY(28)
	);
---- End FA stage
-- End WT-branch 29

-- Begin WT-branch 30
---- Begin FA stage
FA_70:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(130), DATA_B => SUMMAND(131), DATA_C => SUMMAND(132), 
		SAVE => INT_SUM(92), CARRY => INT_CARRY(69)
	);
---- End FA stage
---- Begin HA stage
HA_27:HALF_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(133), DATA_B => SUMMAND(134), 
		SAVE => INT_SUM(93), CARRY => INT_CARRY(70)
	);
---- End HA stage
---- Begin FA stage
FA_71:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(92), DATA_B => INT_SUM(93), DATA_C => INT_CARRY(66), 
		SAVE => INT_SUM(94), CARRY => INT_CARRY(71)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(95) <= INT_CARRY(67); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_72:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(94), DATA_B => INT_SUM(95), DATA_C => INT_CARRY(68), 
		SAVE => SUM(29), CARRY => CARRY(29)
	);
---- End FA stage
-- End WT-branch 30

-- Begin WT-branch 31
---- Begin FA stage
FA_73:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(135), DATA_B => SUMMAND(136), DATA_C => SUMMAND(137), 
		SAVE => INT_SUM(96), CARRY => INT_CARRY(72)
	);
---- End FA stage
---- Begin HA stage
HA_28:HALF_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(138), DATA_B => SUMMAND(139), 
		SAVE => INT_SUM(97), CARRY => INT_CARRY(73)
	);
---- End HA stage
---- Begin FA stage
FA_74:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(96), DATA_B => INT_SUM(97), DATA_C => INT_CARRY(69), 
		SAVE => INT_SUM(98), CARRY => INT_CARRY(74)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(99) <= INT_CARRY(70); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_75:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(98), DATA_B => INT_SUM(99), DATA_C => INT_CARRY(71), 
		SAVE => SUM(30), CARRY => CARRY(30)
	);
---- End FA stage
-- End WT-branch 31

-- Begin WT-branch 32
---- Begin FA stage
FA_76:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(140), DATA_B => SUMMAND(141), DATA_C => SUMMAND(142), 
		SAVE => INT_SUM(100), CARRY => INT_CARRY(75)
	);
---- End FA stage
---- Begin HA stage
HA_29:HALF_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(143), DATA_B => SUMMAND(144), 
		SAVE => INT_SUM(101), CARRY => INT_CARRY(76)
	);
---- End HA stage
---- Begin FA stage
FA_77:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(100), DATA_B => INT_SUM(101), DATA_C => INT_CARRY(72), 
		SAVE => INT_SUM(102), CARRY => INT_CARRY(77)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(103) <= INT_CARRY(73); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_78:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(102), DATA_B => INT_SUM(103), DATA_C => INT_CARRY(74), 
		SAVE => SUM(31), CARRY => CARRY(31)
	);
---- End FA stage
-- End WT-branch 32

-- Begin WT-branch 33
---- Begin FA stage
FA_79:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(145), DATA_B => SUMMAND(146), DATA_C => SUMMAND(147), 
		SAVE => INT_SUM(104), CARRY => INT_CARRY(78)
	);
---- End FA stage
---- Begin HA stage
HA_30:HALF_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(148), DATA_B => SUMMAND(149), 
		SAVE => INT_SUM(105), CARRY => INT_CARRY(79)
	);
---- End HA stage
---- Begin FA stage
FA_80:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(104), DATA_B => INT_SUM(105), DATA_C => INT_CARRY(75), 
		SAVE => INT_SUM(106), CARRY => INT_CARRY(80)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(107) <= INT_CARRY(76); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_81:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(106), DATA_B => INT_SUM(107), DATA_C => INT_CARRY(77), 
		SAVE => SUM(32), CARRY => CARRY(32)
	);
---- End FA stage
-- End WT-branch 33

-- Begin WT-branch 34
---- Begin FA stage
FA_82:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(150), DATA_B => SUMMAND(151), DATA_C => SUMMAND(152), 
		SAVE => INT_SUM(108), CARRY => INT_CARRY(81)
	);
---- End FA stage
---- Begin HA stage
HA_31:HALF_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(153), DATA_B => SUMMAND(154), 
		SAVE => INT_SUM(109), CARRY => INT_CARRY(82)
	);
---- End HA stage
---- Begin FA stage
FA_83:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(108), DATA_B => INT_SUM(109), DATA_C => INT_CARRY(78), 
		SAVE => INT_SUM(110), CARRY => INT_CARRY(83)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(111) <= INT_CARRY(79); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_84:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(110), DATA_B => INT_SUM(111), DATA_C => INT_CARRY(80), 
		SAVE => SUM(33), CARRY => CARRY(33)
	);
---- End FA stage
-- End WT-branch 34

-- Begin WT-branch 35
---- Begin FA stage
FA_85:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(155), DATA_B => SUMMAND(156), DATA_C => SUMMAND(157), 
		SAVE => INT_SUM(112), CARRY => INT_CARRY(84)
	);
---- End FA stage
---- Begin FA stage
FA_86:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(158), DATA_B => SUMMAND(159), DATA_C => SUMMAND(160), 
		SAVE => INT_SUM(113), CARRY => INT_CARRY(85)
	);
---- End FA stage
---- Begin FA stage
FA_87:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(112), DATA_B => INT_SUM(113), DATA_C => INT_CARRY(81), 
		SAVE => INT_SUM(114), CARRY => INT_CARRY(86)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(115) <= INT_CARRY(82); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_88:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(114), DATA_B => INT_SUM(115), DATA_C => INT_CARRY(83), 
		SAVE => SUM(34), CARRY => CARRY(34)
	);
---- End FA stage
-- End WT-branch 35

-- Begin WT-branch 36
---- Begin FA stage
FA_89:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(161), DATA_B => SUMMAND(162), DATA_C => SUMMAND(163), 
		SAVE => INT_SUM(116), CARRY => INT_CARRY(87)
	);
---- End FA stage
---- Begin HA stage
HA_32:HALF_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(164), DATA_B => SUMMAND(165), 
		SAVE => INT_SUM(117), CARRY => INT_CARRY(88)
	);
---- End HA stage
---- Begin FA stage
FA_90:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(116), DATA_B => INT_SUM(117), DATA_C => INT_CARRY(84), 
		SAVE => INT_SUM(118), CARRY => INT_CARRY(89)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(119) <= INT_CARRY(85); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_91:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(118), DATA_B => INT_SUM(119), DATA_C => INT_CARRY(86), 
		SAVE => SUM(35), CARRY => CARRY(35)
	);
---- End FA stage
-- End WT-branch 36

-- Begin WT-branch 37
---- Begin FA stage
FA_92:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(166), DATA_B => SUMMAND(167), DATA_C => SUMMAND(168), 
		SAVE => INT_SUM(120), CARRY => INT_CARRY(90)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(121) <= SUMMAND(169); -- At Level 1
---- End NO stage
---- Begin FA stage
FA_93:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(120), DATA_B => INT_SUM(121), DATA_C => INT_CARRY(87), 
		SAVE => INT_SUM(122), CARRY => INT_CARRY(91)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(123) <= INT_CARRY(88); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_94:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(122), DATA_B => INT_SUM(123), DATA_C => INT_CARRY(89), 
		SAVE => SUM(36), CARRY => CARRY(36)
	);
---- End FA stage
-- End WT-branch 37

-- Begin WT-branch 38
---- Begin FA stage
FA_95:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(170), DATA_B => SUMMAND(171), DATA_C => SUMMAND(172), 
		SAVE => INT_SUM(124), CARRY => INT_CARRY(92)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(125) <= SUMMAND(173); -- At Level 1
---- End NO stage
---- Begin FA stage
FA_96:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(124), DATA_B => INT_SUM(125), DATA_C => INT_CARRY(90), 
		SAVE => INT_SUM(126), CARRY => INT_CARRY(93)
	);
---- End FA stage
---- Begin HA stage
HA_33:HALF_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(126), DATA_B => INT_CARRY(91), 
		SAVE => SUM(37), CARRY => CARRY(37)
	);
---- End HA stage
-- End WT-branch 38

-- Begin WT-branch 39
---- Begin FA stage
FA_97:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(174), DATA_B => SUMMAND(175), DATA_C => SUMMAND(176), 
		SAVE => INT_SUM(127), CARRY => INT_CARRY(94)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(128) <= INT_SUM(127); -- At Level 2
---- End NO stage
---- Begin NO stage
INT_SUM(129) <= INT_CARRY(92); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_98:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(128), DATA_B => INT_SUM(129), DATA_C => INT_CARRY(93), 
		SAVE => SUM(38), CARRY => CARRY(38)
	);
---- End FA stage
-- End WT-branch 39

-- Begin WT-branch 40
---- Begin FA stage
FA_99:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(177), DATA_B => SUMMAND(178), DATA_C => SUMMAND(179), 
		SAVE => INT_SUM(130), CARRY => INT_CARRY(95)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(131) <= INT_CARRY(94); -- At Level 2
---- End NO stage
---- Begin HA stage
HA_34:HALF_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(130), DATA_B => INT_SUM(131), 
		SAVE => SUM(39), CARRY => CARRY(39)
	);
---- End HA stage
-- End WT-branch 40

-- Begin WT-branch 41
---- Begin NO stage
INT_SUM(132) <= SUMMAND(180); -- At Level 2
---- End NO stage
---- Begin NO stage
INT_SUM(133) <= SUMMAND(181); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_100:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(132), DATA_B => INT_SUM(133), DATA_C => INT_CARRY(95), 
		SAVE => SUM(40), CARRY => CARRY(40)
	);
---- End FA stage
-- End WT-branch 41

-- Begin WT-branch 42
---- Begin HA stage
HA_35:HALF_ADDER -- At Level 3
	port map
	(
		DATA_A => SUMMAND(182), DATA_B => SUMMAND(183), 
		SAVE => SUM(41), CARRY => CARRY(41)
	);
---- End HA stage
-- End WT-branch 42

-- Begin WT-branch 43
---- Begin NO stage
SUM(42) <= SUMMAND(184); -- At Level 3
---- End NO stage
-- End WT-branch 43

end WALLACE;
------------------------------------------------------------
-- END: Architectures used with the Wallace-tree
------------------------------------------------------------

------------------------------------------------------------
-- START: Architectures used with the multiplier
------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.blocks.all;
entity MULTIPLIER_34_10 is
port
(
	MULTIPLICAND: in std_logic_vector(0 to 33);
	MULTIPLIER: in std_logic_vector(0 to 9);
	PHI: in std_logic;
	RESULT: out std_logic_vector(0 to 63)
);
end MULTIPLIER_34_10;
------------------------------------------------------------
-- End: Multiplier Entitiy
architecture MULTIPLIER of MULTIPLIER_34_10 is

signal PPBIT:std_logic_vector(0 to 184);
signal INT_CARRY: std_logic_vector(0 to 64);
signal INT_SUM: std_logic_vector(0 to 63);
signal LOGIC_ZERO: std_logic;

begin -- Architecture

LOGIC_ZERO <= '0';
B:BOOTHCODER_34_10
	port map
	(
		OPA(0 to 33) => MULTIPLICAND(0 to 33),
		OPB(0 to 9) => MULTIPLIER(0 to 9),
		SUMMAND(0 to 184) => PPBIT(0 to 184)
	);
W:WALLACE_34_10
	port map
	(
		SUMMAND(0 to 184) => PPBIT(0 to 184),
		CARRY(0 to 41) => INT_CARRY(1 to 42),
		SUM(0 to 42) => INT_SUM(0 to 42)
	);
INT_CARRY(0) <= LOGIC_ZERO;
INT_CARRY(43) <= LOGIC_ZERO;
INT_CARRY(44) <= LOGIC_ZERO;
INT_CARRY(45) <= LOGIC_ZERO;
INT_CARRY(46) <= LOGIC_ZERO;
INT_CARRY(47) <= LOGIC_ZERO;
INT_CARRY(48) <= LOGIC_ZERO;
INT_CARRY(49) <= LOGIC_ZERO;
INT_CARRY(50) <= LOGIC_ZERO;
INT_CARRY(51) <= LOGIC_ZERO;
INT_CARRY(52) <= LOGIC_ZERO;
INT_CARRY(53) <= LOGIC_ZERO;
INT_CARRY(54) <= LOGIC_ZERO;
INT_CARRY(55) <= LOGIC_ZERO;
INT_CARRY(56) <= LOGIC_ZERO;
INT_CARRY(57) <= LOGIC_ZERO;
INT_CARRY(58) <= LOGIC_ZERO;
INT_CARRY(59) <= LOGIC_ZERO;
INT_CARRY(60) <= LOGIC_ZERO;
INT_CARRY(61) <= LOGIC_ZERO;
INT_CARRY(62) <= LOGIC_ZERO;
INT_CARRY(63) <= LOGIC_ZERO;
INT_SUM(43) <= LOGIC_ZERO;
INT_SUM(44) <= LOGIC_ZERO;
INT_SUM(45) <= LOGIC_ZERO;
INT_SUM(46) <= LOGIC_ZERO;
INT_SUM(47) <= LOGIC_ZERO;
INT_SUM(48) <= LOGIC_ZERO;
INT_SUM(49) <= LOGIC_ZERO;
INT_SUM(50) <= LOGIC_ZERO;
INT_SUM(51) <= LOGIC_ZERO;
INT_SUM(52) <= LOGIC_ZERO;
INT_SUM(53) <= LOGIC_ZERO;
INT_SUM(54) <= LOGIC_ZERO;
INT_SUM(55) <= LOGIC_ZERO;
INT_SUM(56) <= LOGIC_ZERO;
INT_SUM(57) <= LOGIC_ZERO;
INT_SUM(58) <= LOGIC_ZERO;
INT_SUM(59) <= LOGIC_ZERO;
INT_SUM(60) <= LOGIC_ZERO;
INT_SUM(61) <= LOGIC_ZERO;
INT_SUM(62) <= LOGIC_ZERO;
INT_SUM(63) <= LOGIC_ZERO;
D:DBLCADDER_64_64
	port map
	(
		OPA(0 to 63) => INT_SUM(0 to 63),
		OPB(0 to 63) => INT_CARRY(0 to 63),
		CIN => LOGIC_ZERO,
		PHI => PHI,
		SUM(0 to 63) => RESULT(0 to 63)
	);
end MULTIPLIER;
------------------------------------------------------------
-- END: Architectures used with the multiplier
------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.blocks.all;
entity MUL_33_9 is
  port(X: in std_logic_vector(32 downto 0);
       Y: in std_logic_vector(8 downto 0);
       P: out std_logic_vector(41 downto 0));
end MUL_33_9;

library ieee;
use ieee.std_logic_1164.all;
architecture A of MUL_33_9 is
  signal A: std_logic_vector(0 to 33);
  signal B: std_logic_vector(0 to 9);
  signal Q: std_logic_vector(0 to 63);
  signal CLK: std_logic;
begin
  U1: MULTIPLIER_34_10 port map(A,B,CLK,Q);
  -- std_logic_vector reversals to incorporate decreasing vectors
  A(0) <= X(0);
  A(1) <= X(1);
  A(2) <= X(2);
  A(3) <= X(3);
  A(4) <= X(4);
  A(5) <= X(5);
  A(6) <= X(6);
  A(7) <= X(7);
  A(8) <= X(8);
  A(9) <= X(9);
  A(10) <= X(10);
  A(11) <= X(11);
  A(12) <= X(12);
  A(13) <= X(13);
  A(14) <= X(14);
  A(15) <= X(15);
  A(16) <= X(16);
  A(17) <= X(17);
  A(18) <= X(18);
  A(19) <= X(19);
  A(20) <= X(20);
  A(21) <= X(21);
  A(22) <= X(22);
  A(23) <= X(23);
  A(24) <= X(24);
  A(25) <= X(25);
  A(26) <= X(26);
  A(27) <= X(27);
  A(28) <= X(28);
  A(29) <= X(29);
  A(30) <= X(30);
  A(31) <= X(31);
  A(32) <= X(32);
  A(33) <= X(32);
  B(0) <= Y(0);
  B(1) <= Y(1);
  B(2) <= Y(2);
  B(3) <= Y(3);
  B(4) <= Y(4);
  B(5) <= Y(5);
  B(6) <= Y(6);
  B(7) <= Y(7);
  B(8) <= Y(8);
  B(9) <= Y(8);
  P(0) <= Q(0);
  P(1) <= Q(1);
  P(2) <= Q(2);
  P(3) <= Q(3);
  P(4) <= Q(4);
  P(5) <= Q(5);
  P(6) <= Q(6);
  P(7) <= Q(7);
  P(8) <= Q(8);
  P(9) <= Q(9);
  P(10) <= Q(10);
  P(11) <= Q(11);
  P(12) <= Q(12);
  P(13) <= Q(13);
  P(14) <= Q(14);
  P(15) <= Q(15);
  P(16) <= Q(16);
  P(17) <= Q(17);
  P(18) <= Q(18);
  P(19) <= Q(19);
  P(20) <= Q(20);
  P(21) <= Q(21);
  P(22) <= Q(22);
  P(23) <= Q(23);
  P(24) <= Q(24);
  P(25) <= Q(25);
  P(26) <= Q(26);
  P(27) <= Q(27);
  P(28) <= Q(28);
  P(29) <= Q(29);
  P(30) <= Q(30);
  P(31) <= Q(31);
  P(32) <= Q(32);
  P(33) <= Q(33);
  P(34) <= Q(34);
  P(35) <= Q(35);
  P(36) <= Q(36);
  P(37) <= Q(37);
  P(38) <= Q(38);
  P(39) <= Q(39);
  P(40) <= Q(40);
  P(41) <= Q(41);
end A;



------------------------------------------------------------
-- START: Entities within the Wallace-tree
------------------------------------------------------------



--
-- Modified Booth algorithm architecture
--
library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.blocks.all;
entity BOOTHCODER_34_18 is
port
(
		OPA: in std_logic_vector(0 to 33);
		OPB: in std_logic_vector(0 to 17);
		SUMMAND: out std_logic_vector(0 to 332)
);
end BOOTHCODER_34_18;
architecture BOOTHCODER of BOOTHCODER_34_18 is

-- Internal signal in Booth structure

signal INV_MULTIPLICAND: std_logic_vector(0 to 33);
signal INT_MULTIPLIER: std_logic_vector(0 to 35);
signal LOGIC_ONE, LOGIC_ZERO: std_logic;
begin
LOGIC_ONE <= '1';
LOGIC_ZERO <= '0';
-- Begin decoder block 1
DEC_0:DECODER -- Decoder of multiplier operand
	port map
	(
		INA => LOGIC_ZERO,INB => OPB(0),INC => OPB(1),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3)
	);
-- End decoder block 1
-- Begin partial product 1
INV_MULTIPLICAND(0) <= NOT OPA(0);
PPL_0:PP_LOW
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(0)
	);
RGATE_0:R_GATE
	port map
	(
		INA => LOGIC_ZERO,INB => OPB(0),INC => OPB(1),
		PPBIT => SUMMAND(1)
	);
INV_MULTIPLICAND(1) <= NOT OPA(1);
PPM_0:PP_MIDDLE
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		INC => OPA(1),IND => INV_MULTIPLICAND(1),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(2)
	);
INV_MULTIPLICAND(2) <= NOT OPA(2);
PPM_1:PP_MIDDLE
	port map
	(
		INA => OPA(1),INB => INV_MULTIPLICAND(1),
		INC => OPA(2),IND => INV_MULTIPLICAND(2),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(3)
	);
INV_MULTIPLICAND(3) <= NOT OPA(3);
PPM_2:PP_MIDDLE
	port map
	(
		INA => OPA(2),INB => INV_MULTIPLICAND(2),
		INC => OPA(3),IND => INV_MULTIPLICAND(3),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(6)
	);
INV_MULTIPLICAND(4) <= NOT OPA(4);
PPM_3:PP_MIDDLE
	port map
	(
		INA => OPA(3),INB => INV_MULTIPLICAND(3),
		INC => OPA(4),IND => INV_MULTIPLICAND(4),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(8)
	);
INV_MULTIPLICAND(5) <= NOT OPA(5);
PPM_4:PP_MIDDLE
	port map
	(
		INA => OPA(4),INB => INV_MULTIPLICAND(4),
		INC => OPA(5),IND => INV_MULTIPLICAND(5),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(12)
	);
INV_MULTIPLICAND(6) <= NOT OPA(6);
PPM_5:PP_MIDDLE
	port map
	(
		INA => OPA(5),INB => INV_MULTIPLICAND(5),
		INC => OPA(6),IND => INV_MULTIPLICAND(6),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(15)
	);
INV_MULTIPLICAND(7) <= NOT OPA(7);
PPM_6:PP_MIDDLE
	port map
	(
		INA => OPA(6),INB => INV_MULTIPLICAND(6),
		INC => OPA(7),IND => INV_MULTIPLICAND(7),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(20)
	);
INV_MULTIPLICAND(8) <= NOT OPA(8);
PPM_7:PP_MIDDLE
	port map
	(
		INA => OPA(7),INB => INV_MULTIPLICAND(7),
		INC => OPA(8),IND => INV_MULTIPLICAND(8),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(24)
	);
INV_MULTIPLICAND(9) <= NOT OPA(9);
PPM_8:PP_MIDDLE
	port map
	(
		INA => OPA(8),INB => INV_MULTIPLICAND(8),
		INC => OPA(9),IND => INV_MULTIPLICAND(9),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(30)
	);
INV_MULTIPLICAND(10) <= NOT OPA(10);
PPM_9:PP_MIDDLE
	port map
	(
		INA => OPA(9),INB => INV_MULTIPLICAND(9),
		INC => OPA(10),IND => INV_MULTIPLICAND(10),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(35)
	);
INV_MULTIPLICAND(11) <= NOT OPA(11);
PPM_10:PP_MIDDLE
	port map
	(
		INA => OPA(10),INB => INV_MULTIPLICAND(10),
		INC => OPA(11),IND => INV_MULTIPLICAND(11),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(42)
	);
INV_MULTIPLICAND(12) <= NOT OPA(12);
PPM_11:PP_MIDDLE
	port map
	(
		INA => OPA(11),INB => INV_MULTIPLICAND(11),
		INC => OPA(12),IND => INV_MULTIPLICAND(12),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(48)
	);
INV_MULTIPLICAND(13) <= NOT OPA(13);
PPM_12:PP_MIDDLE
	port map
	(
		INA => OPA(12),INB => INV_MULTIPLICAND(12),
		INC => OPA(13),IND => INV_MULTIPLICAND(13),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(56)
	);
INV_MULTIPLICAND(14) <= NOT OPA(14);
PPM_13:PP_MIDDLE
	port map
	(
		INA => OPA(13),INB => INV_MULTIPLICAND(13),
		INC => OPA(14),IND => INV_MULTIPLICAND(14),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(63)
	);
INV_MULTIPLICAND(15) <= NOT OPA(15);
PPM_14:PP_MIDDLE
	port map
	(
		INA => OPA(14),INB => INV_MULTIPLICAND(14),
		INC => OPA(15),IND => INV_MULTIPLICAND(15),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(72)
	);
INV_MULTIPLICAND(16) <= NOT OPA(16);
PPM_15:PP_MIDDLE
	port map
	(
		INA => OPA(15),INB => INV_MULTIPLICAND(15),
		INC => OPA(16),IND => INV_MULTIPLICAND(16),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(80)
	);
INV_MULTIPLICAND(17) <= NOT OPA(17);
PPM_16:PP_MIDDLE
	port map
	(
		INA => OPA(16),INB => INV_MULTIPLICAND(16),
		INC => OPA(17),IND => INV_MULTIPLICAND(17),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(90)
	);
INV_MULTIPLICAND(18) <= NOT OPA(18);
PPM_17:PP_MIDDLE
	port map
	(
		INA => OPA(17),INB => INV_MULTIPLICAND(17),
		INC => OPA(18),IND => INV_MULTIPLICAND(18),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(99)
	);
INV_MULTIPLICAND(19) <= NOT OPA(19);
PPM_18:PP_MIDDLE
	port map
	(
		INA => OPA(18),INB => INV_MULTIPLICAND(18),
		INC => OPA(19),IND => INV_MULTIPLICAND(19),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(108)
	);
INV_MULTIPLICAND(20) <= NOT OPA(20);
PPM_19:PP_MIDDLE
	port map
	(
		INA => OPA(19),INB => INV_MULTIPLICAND(19),
		INC => OPA(20),IND => INV_MULTIPLICAND(20),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(117)
	);
INV_MULTIPLICAND(21) <= NOT OPA(21);
PPM_20:PP_MIDDLE
	port map
	(
		INA => OPA(20),INB => INV_MULTIPLICAND(20),
		INC => OPA(21),IND => INV_MULTIPLICAND(21),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(126)
	);
INV_MULTIPLICAND(22) <= NOT OPA(22);
PPM_21:PP_MIDDLE
	port map
	(
		INA => OPA(21),INB => INV_MULTIPLICAND(21),
		INC => OPA(22),IND => INV_MULTIPLICAND(22),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(135)
	);
INV_MULTIPLICAND(23) <= NOT OPA(23);
PPM_22:PP_MIDDLE
	port map
	(
		INA => OPA(22),INB => INV_MULTIPLICAND(22),
		INC => OPA(23),IND => INV_MULTIPLICAND(23),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(144)
	);
INV_MULTIPLICAND(24) <= NOT OPA(24);
PPM_23:PP_MIDDLE
	port map
	(
		INA => OPA(23),INB => INV_MULTIPLICAND(23),
		INC => OPA(24),IND => INV_MULTIPLICAND(24),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(153)
	);
INV_MULTIPLICAND(25) <= NOT OPA(25);
PPM_24:PP_MIDDLE
	port map
	(
		INA => OPA(24),INB => INV_MULTIPLICAND(24),
		INC => OPA(25),IND => INV_MULTIPLICAND(25),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(162)
	);
INV_MULTIPLICAND(26) <= NOT OPA(26);
PPM_25:PP_MIDDLE
	port map
	(
		INA => OPA(25),INB => INV_MULTIPLICAND(25),
		INC => OPA(26),IND => INV_MULTIPLICAND(26),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(171)
	);
INV_MULTIPLICAND(27) <= NOT OPA(27);
PPM_26:PP_MIDDLE
	port map
	(
		INA => OPA(26),INB => INV_MULTIPLICAND(26),
		INC => OPA(27),IND => INV_MULTIPLICAND(27),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(180)
	);
INV_MULTIPLICAND(28) <= NOT OPA(28);
PPM_27:PP_MIDDLE
	port map
	(
		INA => OPA(27),INB => INV_MULTIPLICAND(27),
		INC => OPA(28),IND => INV_MULTIPLICAND(28),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(189)
	);
INV_MULTIPLICAND(29) <= NOT OPA(29);
PPM_28:PP_MIDDLE
	port map
	(
		INA => OPA(28),INB => INV_MULTIPLICAND(28),
		INC => OPA(29),IND => INV_MULTIPLICAND(29),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(198)
	);
INV_MULTIPLICAND(30) <= NOT OPA(30);
PPM_29:PP_MIDDLE
	port map
	(
		INA => OPA(29),INB => INV_MULTIPLICAND(29),
		INC => OPA(30),IND => INV_MULTIPLICAND(30),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(207)
	);
INV_MULTIPLICAND(31) <= NOT OPA(31);
PPM_30:PP_MIDDLE
	port map
	(
		INA => OPA(30),INB => INV_MULTIPLICAND(30),
		INC => OPA(31),IND => INV_MULTIPLICAND(31),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(216)
	);
INV_MULTIPLICAND(32) <= NOT OPA(32);
PPM_31:PP_MIDDLE
	port map
	(
		INA => OPA(31),INB => INV_MULTIPLICAND(31),
		INC => OPA(32),IND => INV_MULTIPLICAND(32),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(225)
	);
INV_MULTIPLICAND(33) <= NOT OPA(33);
PPM_32:PP_MIDDLE
	port map
	(
		INA => OPA(32),INB => INV_MULTIPLICAND(32),
		INC => OPA(33),IND => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(234)
	);
PPH_0:PP_HIGH
	port map
	(
		INA => OPA(33),INB => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(243)
	);
SUMMAND(244) <= '1';
-- Begin partial product 1
-- Begin decoder block 2
DEC_1:DECODER -- Decoder of multiplier operand
	port map
	(
		INA => OPB(1),INB => OPB(2),INC => OPB(3),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7)
	);
-- End decoder block 2
-- Begin partial product 2
PPL_1:PP_LOW
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(4)
	);
RGATE_1:R_GATE
	port map
	(
		INA => OPB(1),INB => OPB(2),INC => OPB(3),
		PPBIT => SUMMAND(5)
	);
PPM_33:PP_MIDDLE
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		INC => OPA(1),IND => INV_MULTIPLICAND(1),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(7)
	);
PPM_34:PP_MIDDLE
	port map
	(
		INA => OPA(1),INB => INV_MULTIPLICAND(1),
		INC => OPA(2),IND => INV_MULTIPLICAND(2),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(9)
	);
PPM_35:PP_MIDDLE
	port map
	(
		INA => OPA(2),INB => INV_MULTIPLICAND(2),
		INC => OPA(3),IND => INV_MULTIPLICAND(3),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(13)
	);
PPM_36:PP_MIDDLE
	port map
	(
		INA => OPA(3),INB => INV_MULTIPLICAND(3),
		INC => OPA(4),IND => INV_MULTIPLICAND(4),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(16)
	);
PPM_37:PP_MIDDLE
	port map
	(
		INA => OPA(4),INB => INV_MULTIPLICAND(4),
		INC => OPA(5),IND => INV_MULTIPLICAND(5),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(21)
	);
PPM_38:PP_MIDDLE
	port map
	(
		INA => OPA(5),INB => INV_MULTIPLICAND(5),
		INC => OPA(6),IND => INV_MULTIPLICAND(6),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(25)
	);
PPM_39:PP_MIDDLE
	port map
	(
		INA => OPA(6),INB => INV_MULTIPLICAND(6),
		INC => OPA(7),IND => INV_MULTIPLICAND(7),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(31)
	);
PPM_40:PP_MIDDLE
	port map
	(
		INA => OPA(7),INB => INV_MULTIPLICAND(7),
		INC => OPA(8),IND => INV_MULTIPLICAND(8),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(36)
	);
PPM_41:PP_MIDDLE
	port map
	(
		INA => OPA(8),INB => INV_MULTIPLICAND(8),
		INC => OPA(9),IND => INV_MULTIPLICAND(9),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(43)
	);
PPM_42:PP_MIDDLE
	port map
	(
		INA => OPA(9),INB => INV_MULTIPLICAND(9),
		INC => OPA(10),IND => INV_MULTIPLICAND(10),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(49)
	);
PPM_43:PP_MIDDLE
	port map
	(
		INA => OPA(10),INB => INV_MULTIPLICAND(10),
		INC => OPA(11),IND => INV_MULTIPLICAND(11),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(57)
	);
PPM_44:PP_MIDDLE
	port map
	(
		INA => OPA(11),INB => INV_MULTIPLICAND(11),
		INC => OPA(12),IND => INV_MULTIPLICAND(12),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(64)
	);
PPM_45:PP_MIDDLE
	port map
	(
		INA => OPA(12),INB => INV_MULTIPLICAND(12),
		INC => OPA(13),IND => INV_MULTIPLICAND(13),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(73)
	);
PPM_46:PP_MIDDLE
	port map
	(
		INA => OPA(13),INB => INV_MULTIPLICAND(13),
		INC => OPA(14),IND => INV_MULTIPLICAND(14),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(81)
	);
PPM_47:PP_MIDDLE
	port map
	(
		INA => OPA(14),INB => INV_MULTIPLICAND(14),
		INC => OPA(15),IND => INV_MULTIPLICAND(15),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(91)
	);
PPM_48:PP_MIDDLE
	port map
	(
		INA => OPA(15),INB => INV_MULTIPLICAND(15),
		INC => OPA(16),IND => INV_MULTIPLICAND(16),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(100)
	);
PPM_49:PP_MIDDLE
	port map
	(
		INA => OPA(16),INB => INV_MULTIPLICAND(16),
		INC => OPA(17),IND => INV_MULTIPLICAND(17),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(109)
	);
PPM_50:PP_MIDDLE
	port map
	(
		INA => OPA(17),INB => INV_MULTIPLICAND(17),
		INC => OPA(18),IND => INV_MULTIPLICAND(18),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(118)
	);
PPM_51:PP_MIDDLE
	port map
	(
		INA => OPA(18),INB => INV_MULTIPLICAND(18),
		INC => OPA(19),IND => INV_MULTIPLICAND(19),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(127)
	);
PPM_52:PP_MIDDLE
	port map
	(
		INA => OPA(19),INB => INV_MULTIPLICAND(19),
		INC => OPA(20),IND => INV_MULTIPLICAND(20),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(136)
	);
PPM_53:PP_MIDDLE
	port map
	(
		INA => OPA(20),INB => INV_MULTIPLICAND(20),
		INC => OPA(21),IND => INV_MULTIPLICAND(21),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(145)
	);
PPM_54:PP_MIDDLE
	port map
	(
		INA => OPA(21),INB => INV_MULTIPLICAND(21),
		INC => OPA(22),IND => INV_MULTIPLICAND(22),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(154)
	);
PPM_55:PP_MIDDLE
	port map
	(
		INA => OPA(22),INB => INV_MULTIPLICAND(22),
		INC => OPA(23),IND => INV_MULTIPLICAND(23),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(163)
	);
PPM_56:PP_MIDDLE
	port map
	(
		INA => OPA(23),INB => INV_MULTIPLICAND(23),
		INC => OPA(24),IND => INV_MULTIPLICAND(24),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(172)
	);
PPM_57:PP_MIDDLE
	port map
	(
		INA => OPA(24),INB => INV_MULTIPLICAND(24),
		INC => OPA(25),IND => INV_MULTIPLICAND(25),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(181)
	);
PPM_58:PP_MIDDLE
	port map
	(
		INA => OPA(25),INB => INV_MULTIPLICAND(25),
		INC => OPA(26),IND => INV_MULTIPLICAND(26),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(190)
	);
PPM_59:PP_MIDDLE
	port map
	(
		INA => OPA(26),INB => INV_MULTIPLICAND(26),
		INC => OPA(27),IND => INV_MULTIPLICAND(27),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(199)
	);
PPM_60:PP_MIDDLE
	port map
	(
		INA => OPA(27),INB => INV_MULTIPLICAND(27),
		INC => OPA(28),IND => INV_MULTIPLICAND(28),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(208)
	);
PPM_61:PP_MIDDLE
	port map
	(
		INA => OPA(28),INB => INV_MULTIPLICAND(28),
		INC => OPA(29),IND => INV_MULTIPLICAND(29),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(217)
	);
PPM_62:PP_MIDDLE
	port map
	(
		INA => OPA(29),INB => INV_MULTIPLICAND(29),
		INC => OPA(30),IND => INV_MULTIPLICAND(30),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(226)
	);
PPM_63:PP_MIDDLE
	port map
	(
		INA => OPA(30),INB => INV_MULTIPLICAND(30),
		INC => OPA(31),IND => INV_MULTIPLICAND(31),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(235)
	);
PPM_64:PP_MIDDLE
	port map
	(
		INA => OPA(31),INB => INV_MULTIPLICAND(31),
		INC => OPA(32),IND => INV_MULTIPLICAND(32),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(245)
	);
PPM_65:PP_MIDDLE
	port map
	(
		INA => OPA(32),INB => INV_MULTIPLICAND(32),
		INC => OPA(33),IND => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(253)
	);
SUMMAND(254) <= LOGIC_ONE;
PPH_1:PP_HIGH
	port map
	(
		INA => OPA(33),INB => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(262)
	);
-- Begin partial product 2
-- Begin decoder block 3
DEC_2:DECODER -- Decoder of multiplier operand
	port map
	(
		INA => OPB(3),INB => OPB(4),INC => OPB(5),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11)
	);
-- End decoder block 3
-- Begin partial product 3
PPL_2:PP_LOW
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(10)
	);
RGATE_2:R_GATE
	port map
	(
		INA => OPB(3),INB => OPB(4),INC => OPB(5),
		PPBIT => SUMMAND(11)
	);
PPM_66:PP_MIDDLE
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		INC => OPA(1),IND => INV_MULTIPLICAND(1),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(14)
	);
PPM_67:PP_MIDDLE
	port map
	(
		INA => OPA(1),INB => INV_MULTIPLICAND(1),
		INC => OPA(2),IND => INV_MULTIPLICAND(2),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(17)
	);
PPM_68:PP_MIDDLE
	port map
	(
		INA => OPA(2),INB => INV_MULTIPLICAND(2),
		INC => OPA(3),IND => INV_MULTIPLICAND(3),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(22)
	);
PPM_69:PP_MIDDLE
	port map
	(
		INA => OPA(3),INB => INV_MULTIPLICAND(3),
		INC => OPA(4),IND => INV_MULTIPLICAND(4),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(26)
	);
PPM_70:PP_MIDDLE
	port map
	(
		INA => OPA(4),INB => INV_MULTIPLICAND(4),
		INC => OPA(5),IND => INV_MULTIPLICAND(5),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(32)
	);
PPM_71:PP_MIDDLE
	port map
	(
		INA => OPA(5),INB => INV_MULTIPLICAND(5),
		INC => OPA(6),IND => INV_MULTIPLICAND(6),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(37)
	);
PPM_72:PP_MIDDLE
	port map
	(
		INA => OPA(6),INB => INV_MULTIPLICAND(6),
		INC => OPA(7),IND => INV_MULTIPLICAND(7),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(44)
	);
PPM_73:PP_MIDDLE
	port map
	(
		INA => OPA(7),INB => INV_MULTIPLICAND(7),
		INC => OPA(8),IND => INV_MULTIPLICAND(8),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(50)
	);
PPM_74:PP_MIDDLE
	port map
	(
		INA => OPA(8),INB => INV_MULTIPLICAND(8),
		INC => OPA(9),IND => INV_MULTIPLICAND(9),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(58)
	);
PPM_75:PP_MIDDLE
	port map
	(
		INA => OPA(9),INB => INV_MULTIPLICAND(9),
		INC => OPA(10),IND => INV_MULTIPLICAND(10),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(65)
	);
PPM_76:PP_MIDDLE
	port map
	(
		INA => OPA(10),INB => INV_MULTIPLICAND(10),
		INC => OPA(11),IND => INV_MULTIPLICAND(11),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(74)
	);
PPM_77:PP_MIDDLE
	port map
	(
		INA => OPA(11),INB => INV_MULTIPLICAND(11),
		INC => OPA(12),IND => INV_MULTIPLICAND(12),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(82)
	);
PPM_78:PP_MIDDLE
	port map
	(
		INA => OPA(12),INB => INV_MULTIPLICAND(12),
		INC => OPA(13),IND => INV_MULTIPLICAND(13),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(92)
	);
PPM_79:PP_MIDDLE
	port map
	(
		INA => OPA(13),INB => INV_MULTIPLICAND(13),
		INC => OPA(14),IND => INV_MULTIPLICAND(14),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(101)
	);
PPM_80:PP_MIDDLE
	port map
	(
		INA => OPA(14),INB => INV_MULTIPLICAND(14),
		INC => OPA(15),IND => INV_MULTIPLICAND(15),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(110)
	);
PPM_81:PP_MIDDLE
	port map
	(
		INA => OPA(15),INB => INV_MULTIPLICAND(15),
		INC => OPA(16),IND => INV_MULTIPLICAND(16),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(119)
	);
PPM_82:PP_MIDDLE
	port map
	(
		INA => OPA(16),INB => INV_MULTIPLICAND(16),
		INC => OPA(17),IND => INV_MULTIPLICAND(17),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(128)
	);
PPM_83:PP_MIDDLE
	port map
	(
		INA => OPA(17),INB => INV_MULTIPLICAND(17),
		INC => OPA(18),IND => INV_MULTIPLICAND(18),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(137)
	);
PPM_84:PP_MIDDLE
	port map
	(
		INA => OPA(18),INB => INV_MULTIPLICAND(18),
		INC => OPA(19),IND => INV_MULTIPLICAND(19),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(146)
	);
PPM_85:PP_MIDDLE
	port map
	(
		INA => OPA(19),INB => INV_MULTIPLICAND(19),
		INC => OPA(20),IND => INV_MULTIPLICAND(20),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(155)
	);
PPM_86:PP_MIDDLE
	port map
	(
		INA => OPA(20),INB => INV_MULTIPLICAND(20),
		INC => OPA(21),IND => INV_MULTIPLICAND(21),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(164)
	);
PPM_87:PP_MIDDLE
	port map
	(
		INA => OPA(21),INB => INV_MULTIPLICAND(21),
		INC => OPA(22),IND => INV_MULTIPLICAND(22),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(173)
	);
PPM_88:PP_MIDDLE
	port map
	(
		INA => OPA(22),INB => INV_MULTIPLICAND(22),
		INC => OPA(23),IND => INV_MULTIPLICAND(23),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(182)
	);
PPM_89:PP_MIDDLE
	port map
	(
		INA => OPA(23),INB => INV_MULTIPLICAND(23),
		INC => OPA(24),IND => INV_MULTIPLICAND(24),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(191)
	);
PPM_90:PP_MIDDLE
	port map
	(
		INA => OPA(24),INB => INV_MULTIPLICAND(24),
		INC => OPA(25),IND => INV_MULTIPLICAND(25),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(200)
	);
PPM_91:PP_MIDDLE
	port map
	(
		INA => OPA(25),INB => INV_MULTIPLICAND(25),
		INC => OPA(26),IND => INV_MULTIPLICAND(26),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(209)
	);
PPM_92:PP_MIDDLE
	port map
	(
		INA => OPA(26),INB => INV_MULTIPLICAND(26),
		INC => OPA(27),IND => INV_MULTIPLICAND(27),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(218)
	);
PPM_93:PP_MIDDLE
	port map
	(
		INA => OPA(27),INB => INV_MULTIPLICAND(27),
		INC => OPA(28),IND => INV_MULTIPLICAND(28),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(227)
	);
PPM_94:PP_MIDDLE
	port map
	(
		INA => OPA(28),INB => INV_MULTIPLICAND(28),
		INC => OPA(29),IND => INV_MULTIPLICAND(29),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(236)
	);
PPM_95:PP_MIDDLE
	port map
	(
		INA => OPA(29),INB => INV_MULTIPLICAND(29),
		INC => OPA(30),IND => INV_MULTIPLICAND(30),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(246)
	);
PPM_96:PP_MIDDLE
	port map
	(
		INA => OPA(30),INB => INV_MULTIPLICAND(30),
		INC => OPA(31),IND => INV_MULTIPLICAND(31),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(255)
	);
PPM_97:PP_MIDDLE
	port map
	(
		INA => OPA(31),INB => INV_MULTIPLICAND(31),
		INC => OPA(32),IND => INV_MULTIPLICAND(32),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(263)
	);
PPM_98:PP_MIDDLE
	port map
	(
		INA => OPA(32),INB => INV_MULTIPLICAND(32),
		INC => OPA(33),IND => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(270)
	);
SUMMAND(271) <= LOGIC_ONE;
PPH_2:PP_HIGH
	port map
	(
		INA => OPA(33),INB => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(278)
	);
-- Begin partial product 3
-- Begin decoder block 4
DEC_3:DECODER -- Decoder of multiplier operand
	port map
	(
		INA => OPB(5),INB => OPB(6),INC => OPB(7),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15)
	);
-- End decoder block 4
-- Begin partial product 4
PPL_3:PP_LOW
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(18)
	);
RGATE_3:R_GATE
	port map
	(
		INA => OPB(5),INB => OPB(6),INC => OPB(7),
		PPBIT => SUMMAND(19)
	);
PPM_99:PP_MIDDLE
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		INC => OPA(1),IND => INV_MULTIPLICAND(1),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(23)
	);
PPM_100:PP_MIDDLE
	port map
	(
		INA => OPA(1),INB => INV_MULTIPLICAND(1),
		INC => OPA(2),IND => INV_MULTIPLICAND(2),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(27)
	);
PPM_101:PP_MIDDLE
	port map
	(
		INA => OPA(2),INB => INV_MULTIPLICAND(2),
		INC => OPA(3),IND => INV_MULTIPLICAND(3),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(33)
	);
PPM_102:PP_MIDDLE
	port map
	(
		INA => OPA(3),INB => INV_MULTIPLICAND(3),
		INC => OPA(4),IND => INV_MULTIPLICAND(4),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(38)
	);
PPM_103:PP_MIDDLE
	port map
	(
		INA => OPA(4),INB => INV_MULTIPLICAND(4),
		INC => OPA(5),IND => INV_MULTIPLICAND(5),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(45)
	);
PPM_104:PP_MIDDLE
	port map
	(
		INA => OPA(5),INB => INV_MULTIPLICAND(5),
		INC => OPA(6),IND => INV_MULTIPLICAND(6),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(51)
	);
PPM_105:PP_MIDDLE
	port map
	(
		INA => OPA(6),INB => INV_MULTIPLICAND(6),
		INC => OPA(7),IND => INV_MULTIPLICAND(7),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(59)
	);
PPM_106:PP_MIDDLE
	port map
	(
		INA => OPA(7),INB => INV_MULTIPLICAND(7),
		INC => OPA(8),IND => INV_MULTIPLICAND(8),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(66)
	);
PPM_107:PP_MIDDLE
	port map
	(
		INA => OPA(8),INB => INV_MULTIPLICAND(8),
		INC => OPA(9),IND => INV_MULTIPLICAND(9),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(75)
	);
PPM_108:PP_MIDDLE
	port map
	(
		INA => OPA(9),INB => INV_MULTIPLICAND(9),
		INC => OPA(10),IND => INV_MULTIPLICAND(10),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(83)
	);
PPM_109:PP_MIDDLE
	port map
	(
		INA => OPA(10),INB => INV_MULTIPLICAND(10),
		INC => OPA(11),IND => INV_MULTIPLICAND(11),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(93)
	);
PPM_110:PP_MIDDLE
	port map
	(
		INA => OPA(11),INB => INV_MULTIPLICAND(11),
		INC => OPA(12),IND => INV_MULTIPLICAND(12),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(102)
	);
PPM_111:PP_MIDDLE
	port map
	(
		INA => OPA(12),INB => INV_MULTIPLICAND(12),
		INC => OPA(13),IND => INV_MULTIPLICAND(13),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(111)
	);
PPM_112:PP_MIDDLE
	port map
	(
		INA => OPA(13),INB => INV_MULTIPLICAND(13),
		INC => OPA(14),IND => INV_MULTIPLICAND(14),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(120)
	);
PPM_113:PP_MIDDLE
	port map
	(
		INA => OPA(14),INB => INV_MULTIPLICAND(14),
		INC => OPA(15),IND => INV_MULTIPLICAND(15),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(129)
	);
PPM_114:PP_MIDDLE
	port map
	(
		INA => OPA(15),INB => INV_MULTIPLICAND(15),
		INC => OPA(16),IND => INV_MULTIPLICAND(16),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(138)
	);
PPM_115:PP_MIDDLE
	port map
	(
		INA => OPA(16),INB => INV_MULTIPLICAND(16),
		INC => OPA(17),IND => INV_MULTIPLICAND(17),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(147)
	);
PPM_116:PP_MIDDLE
	port map
	(
		INA => OPA(17),INB => INV_MULTIPLICAND(17),
		INC => OPA(18),IND => INV_MULTIPLICAND(18),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(156)
	);
PPM_117:PP_MIDDLE
	port map
	(
		INA => OPA(18),INB => INV_MULTIPLICAND(18),
		INC => OPA(19),IND => INV_MULTIPLICAND(19),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(165)
	);
PPM_118:PP_MIDDLE
	port map
	(
		INA => OPA(19),INB => INV_MULTIPLICAND(19),
		INC => OPA(20),IND => INV_MULTIPLICAND(20),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(174)
	);
PPM_119:PP_MIDDLE
	port map
	(
		INA => OPA(20),INB => INV_MULTIPLICAND(20),
		INC => OPA(21),IND => INV_MULTIPLICAND(21),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(183)
	);
PPM_120:PP_MIDDLE
	port map
	(
		INA => OPA(21),INB => INV_MULTIPLICAND(21),
		INC => OPA(22),IND => INV_MULTIPLICAND(22),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(192)
	);
PPM_121:PP_MIDDLE
	port map
	(
		INA => OPA(22),INB => INV_MULTIPLICAND(22),
		INC => OPA(23),IND => INV_MULTIPLICAND(23),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(201)
	);
PPM_122:PP_MIDDLE
	port map
	(
		INA => OPA(23),INB => INV_MULTIPLICAND(23),
		INC => OPA(24),IND => INV_MULTIPLICAND(24),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(210)
	);
PPM_123:PP_MIDDLE
	port map
	(
		INA => OPA(24),INB => INV_MULTIPLICAND(24),
		INC => OPA(25),IND => INV_MULTIPLICAND(25),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(219)
	);
PPM_124:PP_MIDDLE
	port map
	(
		INA => OPA(25),INB => INV_MULTIPLICAND(25),
		INC => OPA(26),IND => INV_MULTIPLICAND(26),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(228)
	);
PPM_125:PP_MIDDLE
	port map
	(
		INA => OPA(26),INB => INV_MULTIPLICAND(26),
		INC => OPA(27),IND => INV_MULTIPLICAND(27),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(237)
	);
PPM_126:PP_MIDDLE
	port map
	(
		INA => OPA(27),INB => INV_MULTIPLICAND(27),
		INC => OPA(28),IND => INV_MULTIPLICAND(28),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(247)
	);
PPM_127:PP_MIDDLE
	port map
	(
		INA => OPA(28),INB => INV_MULTIPLICAND(28),
		INC => OPA(29),IND => INV_MULTIPLICAND(29),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(256)
	);
PPM_128:PP_MIDDLE
	port map
	(
		INA => OPA(29),INB => INV_MULTIPLICAND(29),
		INC => OPA(30),IND => INV_MULTIPLICAND(30),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(264)
	);
PPM_129:PP_MIDDLE
	port map
	(
		INA => OPA(30),INB => INV_MULTIPLICAND(30),
		INC => OPA(31),IND => INV_MULTIPLICAND(31),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(272)
	);
PPM_130:PP_MIDDLE
	port map
	(
		INA => OPA(31),INB => INV_MULTIPLICAND(31),
		INC => OPA(32),IND => INV_MULTIPLICAND(32),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(279)
	);
PPM_131:PP_MIDDLE
	port map
	(
		INA => OPA(32),INB => INV_MULTIPLICAND(32),
		INC => OPA(33),IND => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(285)
	);
SUMMAND(286) <= LOGIC_ONE;
PPH_3:PP_HIGH
	port map
	(
		INA => OPA(33),INB => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(292)
	);
-- Begin partial product 4
-- Begin decoder block 5
DEC_4:DECODER -- Decoder of multiplier operand
	port map
	(
		INA => OPB(7),INB => OPB(8),INC => OPB(9),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19)
	);
-- End decoder block 5
-- Begin partial product 5
PPL_4:PP_LOW
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(28)
	);
RGATE_4:R_GATE
	port map
	(
		INA => OPB(7),INB => OPB(8),INC => OPB(9),
		PPBIT => SUMMAND(29)
	);
PPM_132:PP_MIDDLE
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		INC => OPA(1),IND => INV_MULTIPLICAND(1),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(34)
	);
PPM_133:PP_MIDDLE
	port map
	(
		INA => OPA(1),INB => INV_MULTIPLICAND(1),
		INC => OPA(2),IND => INV_MULTIPLICAND(2),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(39)
	);
PPM_134:PP_MIDDLE
	port map
	(
		INA => OPA(2),INB => INV_MULTIPLICAND(2),
		INC => OPA(3),IND => INV_MULTIPLICAND(3),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(46)
	);
PPM_135:PP_MIDDLE
	port map
	(
		INA => OPA(3),INB => INV_MULTIPLICAND(3),
		INC => OPA(4),IND => INV_MULTIPLICAND(4),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(52)
	);
PPM_136:PP_MIDDLE
	port map
	(
		INA => OPA(4),INB => INV_MULTIPLICAND(4),
		INC => OPA(5),IND => INV_MULTIPLICAND(5),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(60)
	);
PPM_137:PP_MIDDLE
	port map
	(
		INA => OPA(5),INB => INV_MULTIPLICAND(5),
		INC => OPA(6),IND => INV_MULTIPLICAND(6),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(67)
	);
PPM_138:PP_MIDDLE
	port map
	(
		INA => OPA(6),INB => INV_MULTIPLICAND(6),
		INC => OPA(7),IND => INV_MULTIPLICAND(7),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(76)
	);
PPM_139:PP_MIDDLE
	port map
	(
		INA => OPA(7),INB => INV_MULTIPLICAND(7),
		INC => OPA(8),IND => INV_MULTIPLICAND(8),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(84)
	);
PPM_140:PP_MIDDLE
	port map
	(
		INA => OPA(8),INB => INV_MULTIPLICAND(8),
		INC => OPA(9),IND => INV_MULTIPLICAND(9),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(94)
	);
PPM_141:PP_MIDDLE
	port map
	(
		INA => OPA(9),INB => INV_MULTIPLICAND(9),
		INC => OPA(10),IND => INV_MULTIPLICAND(10),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(103)
	);
PPM_142:PP_MIDDLE
	port map
	(
		INA => OPA(10),INB => INV_MULTIPLICAND(10),
		INC => OPA(11),IND => INV_MULTIPLICAND(11),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(112)
	);
PPM_143:PP_MIDDLE
	port map
	(
		INA => OPA(11),INB => INV_MULTIPLICAND(11),
		INC => OPA(12),IND => INV_MULTIPLICAND(12),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(121)
	);
PPM_144:PP_MIDDLE
	port map
	(
		INA => OPA(12),INB => INV_MULTIPLICAND(12),
		INC => OPA(13),IND => INV_MULTIPLICAND(13),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(130)
	);
PPM_145:PP_MIDDLE
	port map
	(
		INA => OPA(13),INB => INV_MULTIPLICAND(13),
		INC => OPA(14),IND => INV_MULTIPLICAND(14),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(139)
	);
PPM_146:PP_MIDDLE
	port map
	(
		INA => OPA(14),INB => INV_MULTIPLICAND(14),
		INC => OPA(15),IND => INV_MULTIPLICAND(15),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(148)
	);
PPM_147:PP_MIDDLE
	port map
	(
		INA => OPA(15),INB => INV_MULTIPLICAND(15),
		INC => OPA(16),IND => INV_MULTIPLICAND(16),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(157)
	);
PPM_148:PP_MIDDLE
	port map
	(
		INA => OPA(16),INB => INV_MULTIPLICAND(16),
		INC => OPA(17),IND => INV_MULTIPLICAND(17),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(166)
	);
PPM_149:PP_MIDDLE
	port map
	(
		INA => OPA(17),INB => INV_MULTIPLICAND(17),
		INC => OPA(18),IND => INV_MULTIPLICAND(18),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(175)
	);
PPM_150:PP_MIDDLE
	port map
	(
		INA => OPA(18),INB => INV_MULTIPLICAND(18),
		INC => OPA(19),IND => INV_MULTIPLICAND(19),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(184)
	);
PPM_151:PP_MIDDLE
	port map
	(
		INA => OPA(19),INB => INV_MULTIPLICAND(19),
		INC => OPA(20),IND => INV_MULTIPLICAND(20),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(193)
	);
PPM_152:PP_MIDDLE
	port map
	(
		INA => OPA(20),INB => INV_MULTIPLICAND(20),
		INC => OPA(21),IND => INV_MULTIPLICAND(21),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(202)
	);
PPM_153:PP_MIDDLE
	port map
	(
		INA => OPA(21),INB => INV_MULTIPLICAND(21),
		INC => OPA(22),IND => INV_MULTIPLICAND(22),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(211)
	);
PPM_154:PP_MIDDLE
	port map
	(
		INA => OPA(22),INB => INV_MULTIPLICAND(22),
		INC => OPA(23),IND => INV_MULTIPLICAND(23),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(220)
	);
PPM_155:PP_MIDDLE
	port map
	(
		INA => OPA(23),INB => INV_MULTIPLICAND(23),
		INC => OPA(24),IND => INV_MULTIPLICAND(24),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(229)
	);
PPM_156:PP_MIDDLE
	port map
	(
		INA => OPA(24),INB => INV_MULTIPLICAND(24),
		INC => OPA(25),IND => INV_MULTIPLICAND(25),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(238)
	);
PPM_157:PP_MIDDLE
	port map
	(
		INA => OPA(25),INB => INV_MULTIPLICAND(25),
		INC => OPA(26),IND => INV_MULTIPLICAND(26),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(248)
	);
PPM_158:PP_MIDDLE
	port map
	(
		INA => OPA(26),INB => INV_MULTIPLICAND(26),
		INC => OPA(27),IND => INV_MULTIPLICAND(27),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(257)
	);
PPM_159:PP_MIDDLE
	port map
	(
		INA => OPA(27),INB => INV_MULTIPLICAND(27),
		INC => OPA(28),IND => INV_MULTIPLICAND(28),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(265)
	);
PPM_160:PP_MIDDLE
	port map
	(
		INA => OPA(28),INB => INV_MULTIPLICAND(28),
		INC => OPA(29),IND => INV_MULTIPLICAND(29),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(273)
	);
PPM_161:PP_MIDDLE
	port map
	(
		INA => OPA(29),INB => INV_MULTIPLICAND(29),
		INC => OPA(30),IND => INV_MULTIPLICAND(30),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(280)
	);
PPM_162:PP_MIDDLE
	port map
	(
		INA => OPA(30),INB => INV_MULTIPLICAND(30),
		INC => OPA(31),IND => INV_MULTIPLICAND(31),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(287)
	);
PPM_163:PP_MIDDLE
	port map
	(
		INA => OPA(31),INB => INV_MULTIPLICAND(31),
		INC => OPA(32),IND => INV_MULTIPLICAND(32),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(293)
	);
PPM_164:PP_MIDDLE
	port map
	(
		INA => OPA(32),INB => INV_MULTIPLICAND(32),
		INC => OPA(33),IND => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(298)
	);
SUMMAND(299) <= LOGIC_ONE;
PPH_4:PP_HIGH
	port map
	(
		INA => OPA(33),INB => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(304)
	);
-- Begin partial product 5
-- Begin decoder block 6
DEC_5:DECODER -- Decoder of multiplier operand
	port map
	(
		INA => OPB(9),INB => OPB(10),INC => OPB(11),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23)
	);
-- End decoder block 6
-- Begin partial product 6
PPL_5:PP_LOW
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(40)
	);
RGATE_5:R_GATE
	port map
	(
		INA => OPB(9),INB => OPB(10),INC => OPB(11),
		PPBIT => SUMMAND(41)
	);
PPM_165:PP_MIDDLE
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		INC => OPA(1),IND => INV_MULTIPLICAND(1),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(47)
	);
PPM_166:PP_MIDDLE
	port map
	(
		INA => OPA(1),INB => INV_MULTIPLICAND(1),
		INC => OPA(2),IND => INV_MULTIPLICAND(2),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(53)
	);
PPM_167:PP_MIDDLE
	port map
	(
		INA => OPA(2),INB => INV_MULTIPLICAND(2),
		INC => OPA(3),IND => INV_MULTIPLICAND(3),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(61)
	);
PPM_168:PP_MIDDLE
	port map
	(
		INA => OPA(3),INB => INV_MULTIPLICAND(3),
		INC => OPA(4),IND => INV_MULTIPLICAND(4),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(68)
	);
PPM_169:PP_MIDDLE
	port map
	(
		INA => OPA(4),INB => INV_MULTIPLICAND(4),
		INC => OPA(5),IND => INV_MULTIPLICAND(5),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(77)
	);
PPM_170:PP_MIDDLE
	port map
	(
		INA => OPA(5),INB => INV_MULTIPLICAND(5),
		INC => OPA(6),IND => INV_MULTIPLICAND(6),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(85)
	);
PPM_171:PP_MIDDLE
	port map
	(
		INA => OPA(6),INB => INV_MULTIPLICAND(6),
		INC => OPA(7),IND => INV_MULTIPLICAND(7),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(95)
	);
PPM_172:PP_MIDDLE
	port map
	(
		INA => OPA(7),INB => INV_MULTIPLICAND(7),
		INC => OPA(8),IND => INV_MULTIPLICAND(8),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(104)
	);
PPM_173:PP_MIDDLE
	port map
	(
		INA => OPA(8),INB => INV_MULTIPLICAND(8),
		INC => OPA(9),IND => INV_MULTIPLICAND(9),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(113)
	);
PPM_174:PP_MIDDLE
	port map
	(
		INA => OPA(9),INB => INV_MULTIPLICAND(9),
		INC => OPA(10),IND => INV_MULTIPLICAND(10),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(122)
	);
PPM_175:PP_MIDDLE
	port map
	(
		INA => OPA(10),INB => INV_MULTIPLICAND(10),
		INC => OPA(11),IND => INV_MULTIPLICAND(11),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(131)
	);
PPM_176:PP_MIDDLE
	port map
	(
		INA => OPA(11),INB => INV_MULTIPLICAND(11),
		INC => OPA(12),IND => INV_MULTIPLICAND(12),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(140)
	);
PPM_177:PP_MIDDLE
	port map
	(
		INA => OPA(12),INB => INV_MULTIPLICAND(12),
		INC => OPA(13),IND => INV_MULTIPLICAND(13),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(149)
	);
PPM_178:PP_MIDDLE
	port map
	(
		INA => OPA(13),INB => INV_MULTIPLICAND(13),
		INC => OPA(14),IND => INV_MULTIPLICAND(14),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(158)
	);
PPM_179:PP_MIDDLE
	port map
	(
		INA => OPA(14),INB => INV_MULTIPLICAND(14),
		INC => OPA(15),IND => INV_MULTIPLICAND(15),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(167)
	);
PPM_180:PP_MIDDLE
	port map
	(
		INA => OPA(15),INB => INV_MULTIPLICAND(15),
		INC => OPA(16),IND => INV_MULTIPLICAND(16),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(176)
	);
PPM_181:PP_MIDDLE
	port map
	(
		INA => OPA(16),INB => INV_MULTIPLICAND(16),
		INC => OPA(17),IND => INV_MULTIPLICAND(17),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(185)
	);
PPM_182:PP_MIDDLE
	port map
	(
		INA => OPA(17),INB => INV_MULTIPLICAND(17),
		INC => OPA(18),IND => INV_MULTIPLICAND(18),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(194)
	);
PPM_183:PP_MIDDLE
	port map
	(
		INA => OPA(18),INB => INV_MULTIPLICAND(18),
		INC => OPA(19),IND => INV_MULTIPLICAND(19),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(203)
	);
PPM_184:PP_MIDDLE
	port map
	(
		INA => OPA(19),INB => INV_MULTIPLICAND(19),
		INC => OPA(20),IND => INV_MULTIPLICAND(20),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(212)
	);
PPM_185:PP_MIDDLE
	port map
	(
		INA => OPA(20),INB => INV_MULTIPLICAND(20),
		INC => OPA(21),IND => INV_MULTIPLICAND(21),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(221)
	);
PPM_186:PP_MIDDLE
	port map
	(
		INA => OPA(21),INB => INV_MULTIPLICAND(21),
		INC => OPA(22),IND => INV_MULTIPLICAND(22),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(230)
	);
PPM_187:PP_MIDDLE
	port map
	(
		INA => OPA(22),INB => INV_MULTIPLICAND(22),
		INC => OPA(23),IND => INV_MULTIPLICAND(23),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(239)
	);
PPM_188:PP_MIDDLE
	port map
	(
		INA => OPA(23),INB => INV_MULTIPLICAND(23),
		INC => OPA(24),IND => INV_MULTIPLICAND(24),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(249)
	);
PPM_189:PP_MIDDLE
	port map
	(
		INA => OPA(24),INB => INV_MULTIPLICAND(24),
		INC => OPA(25),IND => INV_MULTIPLICAND(25),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(258)
	);
PPM_190:PP_MIDDLE
	port map
	(
		INA => OPA(25),INB => INV_MULTIPLICAND(25),
		INC => OPA(26),IND => INV_MULTIPLICAND(26),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(266)
	);
PPM_191:PP_MIDDLE
	port map
	(
		INA => OPA(26),INB => INV_MULTIPLICAND(26),
		INC => OPA(27),IND => INV_MULTIPLICAND(27),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(274)
	);
PPM_192:PP_MIDDLE
	port map
	(
		INA => OPA(27),INB => INV_MULTIPLICAND(27),
		INC => OPA(28),IND => INV_MULTIPLICAND(28),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(281)
	);
PPM_193:PP_MIDDLE
	port map
	(
		INA => OPA(28),INB => INV_MULTIPLICAND(28),
		INC => OPA(29),IND => INV_MULTIPLICAND(29),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(288)
	);
PPM_194:PP_MIDDLE
	port map
	(
		INA => OPA(29),INB => INV_MULTIPLICAND(29),
		INC => OPA(30),IND => INV_MULTIPLICAND(30),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(294)
	);
PPM_195:PP_MIDDLE
	port map
	(
		INA => OPA(30),INB => INV_MULTIPLICAND(30),
		INC => OPA(31),IND => INV_MULTIPLICAND(31),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(300)
	);
PPM_196:PP_MIDDLE
	port map
	(
		INA => OPA(31),INB => INV_MULTIPLICAND(31),
		INC => OPA(32),IND => INV_MULTIPLICAND(32),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(305)
	);
PPM_197:PP_MIDDLE
	port map
	(
		INA => OPA(32),INB => INV_MULTIPLICAND(32),
		INC => OPA(33),IND => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(309)
	);
SUMMAND(310) <= LOGIC_ONE;
PPH_5:PP_HIGH
	port map
	(
		INA => OPA(33),INB => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(314)
	);
-- Begin partial product 6
-- Begin decoder block 7
DEC_6:DECODER -- Decoder of multiplier operand
	port map
	(
		INA => OPB(11),INB => OPB(12),INC => OPB(13),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27)
	);
-- End decoder block 7
-- Begin partial product 7
PPL_6:PP_LOW
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(54)
	);
RGATE_6:R_GATE
	port map
	(
		INA => OPB(11),INB => OPB(12),INC => OPB(13),
		PPBIT => SUMMAND(55)
	);
PPM_198:PP_MIDDLE
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		INC => OPA(1),IND => INV_MULTIPLICAND(1),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(62)
	);
PPM_199:PP_MIDDLE
	port map
	(
		INA => OPA(1),INB => INV_MULTIPLICAND(1),
		INC => OPA(2),IND => INV_MULTIPLICAND(2),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(69)
	);
PPM_200:PP_MIDDLE
	port map
	(
		INA => OPA(2),INB => INV_MULTIPLICAND(2),
		INC => OPA(3),IND => INV_MULTIPLICAND(3),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(78)
	);
PPM_201:PP_MIDDLE
	port map
	(
		INA => OPA(3),INB => INV_MULTIPLICAND(3),
		INC => OPA(4),IND => INV_MULTIPLICAND(4),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(86)
	);
PPM_202:PP_MIDDLE
	port map
	(
		INA => OPA(4),INB => INV_MULTIPLICAND(4),
		INC => OPA(5),IND => INV_MULTIPLICAND(5),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(96)
	);
PPM_203:PP_MIDDLE
	port map
	(
		INA => OPA(5),INB => INV_MULTIPLICAND(5),
		INC => OPA(6),IND => INV_MULTIPLICAND(6),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(105)
	);
PPM_204:PP_MIDDLE
	port map
	(
		INA => OPA(6),INB => INV_MULTIPLICAND(6),
		INC => OPA(7),IND => INV_MULTIPLICAND(7),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(114)
	);
PPM_205:PP_MIDDLE
	port map
	(
		INA => OPA(7),INB => INV_MULTIPLICAND(7),
		INC => OPA(8),IND => INV_MULTIPLICAND(8),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(123)
	);
PPM_206:PP_MIDDLE
	port map
	(
		INA => OPA(8),INB => INV_MULTIPLICAND(8),
		INC => OPA(9),IND => INV_MULTIPLICAND(9),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(132)
	);
PPM_207:PP_MIDDLE
	port map
	(
		INA => OPA(9),INB => INV_MULTIPLICAND(9),
		INC => OPA(10),IND => INV_MULTIPLICAND(10),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(141)
	);
PPM_208:PP_MIDDLE
	port map
	(
		INA => OPA(10),INB => INV_MULTIPLICAND(10),
		INC => OPA(11),IND => INV_MULTIPLICAND(11),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(150)
	);
PPM_209:PP_MIDDLE
	port map
	(
		INA => OPA(11),INB => INV_MULTIPLICAND(11),
		INC => OPA(12),IND => INV_MULTIPLICAND(12),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(159)
	);
PPM_210:PP_MIDDLE
	port map
	(
		INA => OPA(12),INB => INV_MULTIPLICAND(12),
		INC => OPA(13),IND => INV_MULTIPLICAND(13),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(168)
	);
PPM_211:PP_MIDDLE
	port map
	(
		INA => OPA(13),INB => INV_MULTIPLICAND(13),
		INC => OPA(14),IND => INV_MULTIPLICAND(14),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(177)
	);
PPM_212:PP_MIDDLE
	port map
	(
		INA => OPA(14),INB => INV_MULTIPLICAND(14),
		INC => OPA(15),IND => INV_MULTIPLICAND(15),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(186)
	);
PPM_213:PP_MIDDLE
	port map
	(
		INA => OPA(15),INB => INV_MULTIPLICAND(15),
		INC => OPA(16),IND => INV_MULTIPLICAND(16),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(195)
	);
PPM_214:PP_MIDDLE
	port map
	(
		INA => OPA(16),INB => INV_MULTIPLICAND(16),
		INC => OPA(17),IND => INV_MULTIPLICAND(17),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(204)
	);
PPM_215:PP_MIDDLE
	port map
	(
		INA => OPA(17),INB => INV_MULTIPLICAND(17),
		INC => OPA(18),IND => INV_MULTIPLICAND(18),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(213)
	);
PPM_216:PP_MIDDLE
	port map
	(
		INA => OPA(18),INB => INV_MULTIPLICAND(18),
		INC => OPA(19),IND => INV_MULTIPLICAND(19),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(222)
	);
PPM_217:PP_MIDDLE
	port map
	(
		INA => OPA(19),INB => INV_MULTIPLICAND(19),
		INC => OPA(20),IND => INV_MULTIPLICAND(20),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(231)
	);
PPM_218:PP_MIDDLE
	port map
	(
		INA => OPA(20),INB => INV_MULTIPLICAND(20),
		INC => OPA(21),IND => INV_MULTIPLICAND(21),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(240)
	);
PPM_219:PP_MIDDLE
	port map
	(
		INA => OPA(21),INB => INV_MULTIPLICAND(21),
		INC => OPA(22),IND => INV_MULTIPLICAND(22),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(250)
	);
PPM_220:PP_MIDDLE
	port map
	(
		INA => OPA(22),INB => INV_MULTIPLICAND(22),
		INC => OPA(23),IND => INV_MULTIPLICAND(23),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(259)
	);
PPM_221:PP_MIDDLE
	port map
	(
		INA => OPA(23),INB => INV_MULTIPLICAND(23),
		INC => OPA(24),IND => INV_MULTIPLICAND(24),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(267)
	);
PPM_222:PP_MIDDLE
	port map
	(
		INA => OPA(24),INB => INV_MULTIPLICAND(24),
		INC => OPA(25),IND => INV_MULTIPLICAND(25),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(275)
	);
PPM_223:PP_MIDDLE
	port map
	(
		INA => OPA(25),INB => INV_MULTIPLICAND(25),
		INC => OPA(26),IND => INV_MULTIPLICAND(26),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(282)
	);
PPM_224:PP_MIDDLE
	port map
	(
		INA => OPA(26),INB => INV_MULTIPLICAND(26),
		INC => OPA(27),IND => INV_MULTIPLICAND(27),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(289)
	);
PPM_225:PP_MIDDLE
	port map
	(
		INA => OPA(27),INB => INV_MULTIPLICAND(27),
		INC => OPA(28),IND => INV_MULTIPLICAND(28),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(295)
	);
PPM_226:PP_MIDDLE
	port map
	(
		INA => OPA(28),INB => INV_MULTIPLICAND(28),
		INC => OPA(29),IND => INV_MULTIPLICAND(29),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(301)
	);
PPM_227:PP_MIDDLE
	port map
	(
		INA => OPA(29),INB => INV_MULTIPLICAND(29),
		INC => OPA(30),IND => INV_MULTIPLICAND(30),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(306)
	);
PPM_228:PP_MIDDLE
	port map
	(
		INA => OPA(30),INB => INV_MULTIPLICAND(30),
		INC => OPA(31),IND => INV_MULTIPLICAND(31),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(311)
	);
PPM_229:PP_MIDDLE
	port map
	(
		INA => OPA(31),INB => INV_MULTIPLICAND(31),
		INC => OPA(32),IND => INV_MULTIPLICAND(32),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(315)
	);
PPM_230:PP_MIDDLE
	port map
	(
		INA => OPA(32),INB => INV_MULTIPLICAND(32),
		INC => OPA(33),IND => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(318)
	);
SUMMAND(319) <= LOGIC_ONE;
PPH_6:PP_HIGH
	port map
	(
		INA => OPA(33),INB => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(322)
	);
-- Begin partial product 7
-- Begin decoder block 8
DEC_7:DECODER -- Decoder of multiplier operand
	port map
	(
		INA => OPB(13),INB => OPB(14),INC => OPB(15),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31)
	);
-- End decoder block 8
-- Begin partial product 8
PPL_7:PP_LOW
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(70)
	);
RGATE_7:R_GATE
	port map
	(
		INA => OPB(13),INB => OPB(14),INC => OPB(15),
		PPBIT => SUMMAND(71)
	);
PPM_231:PP_MIDDLE
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		INC => OPA(1),IND => INV_MULTIPLICAND(1),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(79)
	);
PPM_232:PP_MIDDLE
	port map
	(
		INA => OPA(1),INB => INV_MULTIPLICAND(1),
		INC => OPA(2),IND => INV_MULTIPLICAND(2),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(87)
	);
PPM_233:PP_MIDDLE
	port map
	(
		INA => OPA(2),INB => INV_MULTIPLICAND(2),
		INC => OPA(3),IND => INV_MULTIPLICAND(3),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(97)
	);
PPM_234:PP_MIDDLE
	port map
	(
		INA => OPA(3),INB => INV_MULTIPLICAND(3),
		INC => OPA(4),IND => INV_MULTIPLICAND(4),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(106)
	);
PPM_235:PP_MIDDLE
	port map
	(
		INA => OPA(4),INB => INV_MULTIPLICAND(4),
		INC => OPA(5),IND => INV_MULTIPLICAND(5),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(115)
	);
PPM_236:PP_MIDDLE
	port map
	(
		INA => OPA(5),INB => INV_MULTIPLICAND(5),
		INC => OPA(6),IND => INV_MULTIPLICAND(6),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(124)
	);
PPM_237:PP_MIDDLE
	port map
	(
		INA => OPA(6),INB => INV_MULTIPLICAND(6),
		INC => OPA(7),IND => INV_MULTIPLICAND(7),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(133)
	);
PPM_238:PP_MIDDLE
	port map
	(
		INA => OPA(7),INB => INV_MULTIPLICAND(7),
		INC => OPA(8),IND => INV_MULTIPLICAND(8),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(142)
	);
PPM_239:PP_MIDDLE
	port map
	(
		INA => OPA(8),INB => INV_MULTIPLICAND(8),
		INC => OPA(9),IND => INV_MULTIPLICAND(9),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(151)
	);
PPM_240:PP_MIDDLE
	port map
	(
		INA => OPA(9),INB => INV_MULTIPLICAND(9),
		INC => OPA(10),IND => INV_MULTIPLICAND(10),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(160)
	);
PPM_241:PP_MIDDLE
	port map
	(
		INA => OPA(10),INB => INV_MULTIPLICAND(10),
		INC => OPA(11),IND => INV_MULTIPLICAND(11),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(169)
	);
PPM_242:PP_MIDDLE
	port map
	(
		INA => OPA(11),INB => INV_MULTIPLICAND(11),
		INC => OPA(12),IND => INV_MULTIPLICAND(12),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(178)
	);
PPM_243:PP_MIDDLE
	port map
	(
		INA => OPA(12),INB => INV_MULTIPLICAND(12),
		INC => OPA(13),IND => INV_MULTIPLICAND(13),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(187)
	);
PPM_244:PP_MIDDLE
	port map
	(
		INA => OPA(13),INB => INV_MULTIPLICAND(13),
		INC => OPA(14),IND => INV_MULTIPLICAND(14),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(196)
	);
PPM_245:PP_MIDDLE
	port map
	(
		INA => OPA(14),INB => INV_MULTIPLICAND(14),
		INC => OPA(15),IND => INV_MULTIPLICAND(15),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(205)
	);
PPM_246:PP_MIDDLE
	port map
	(
		INA => OPA(15),INB => INV_MULTIPLICAND(15),
		INC => OPA(16),IND => INV_MULTIPLICAND(16),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(214)
	);
PPM_247:PP_MIDDLE
	port map
	(
		INA => OPA(16),INB => INV_MULTIPLICAND(16),
		INC => OPA(17),IND => INV_MULTIPLICAND(17),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(223)
	);
PPM_248:PP_MIDDLE
	port map
	(
		INA => OPA(17),INB => INV_MULTIPLICAND(17),
		INC => OPA(18),IND => INV_MULTIPLICAND(18),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(232)
	);
PPM_249:PP_MIDDLE
	port map
	(
		INA => OPA(18),INB => INV_MULTIPLICAND(18),
		INC => OPA(19),IND => INV_MULTIPLICAND(19),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(241)
	);
PPM_250:PP_MIDDLE
	port map
	(
		INA => OPA(19),INB => INV_MULTIPLICAND(19),
		INC => OPA(20),IND => INV_MULTIPLICAND(20),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(251)
	);
PPM_251:PP_MIDDLE
	port map
	(
		INA => OPA(20),INB => INV_MULTIPLICAND(20),
		INC => OPA(21),IND => INV_MULTIPLICAND(21),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(260)
	);
PPM_252:PP_MIDDLE
	port map
	(
		INA => OPA(21),INB => INV_MULTIPLICAND(21),
		INC => OPA(22),IND => INV_MULTIPLICAND(22),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(268)
	);
PPM_253:PP_MIDDLE
	port map
	(
		INA => OPA(22),INB => INV_MULTIPLICAND(22),
		INC => OPA(23),IND => INV_MULTIPLICAND(23),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(276)
	);
PPM_254:PP_MIDDLE
	port map
	(
		INA => OPA(23),INB => INV_MULTIPLICAND(23),
		INC => OPA(24),IND => INV_MULTIPLICAND(24),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(283)
	);
PPM_255:PP_MIDDLE
	port map
	(
		INA => OPA(24),INB => INV_MULTIPLICAND(24),
		INC => OPA(25),IND => INV_MULTIPLICAND(25),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(290)
	);
PPM_256:PP_MIDDLE
	port map
	(
		INA => OPA(25),INB => INV_MULTIPLICAND(25),
		INC => OPA(26),IND => INV_MULTIPLICAND(26),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(296)
	);
PPM_257:PP_MIDDLE
	port map
	(
		INA => OPA(26),INB => INV_MULTIPLICAND(26),
		INC => OPA(27),IND => INV_MULTIPLICAND(27),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(302)
	);
PPM_258:PP_MIDDLE
	port map
	(
		INA => OPA(27),INB => INV_MULTIPLICAND(27),
		INC => OPA(28),IND => INV_MULTIPLICAND(28),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(307)
	);
PPM_259:PP_MIDDLE
	port map
	(
		INA => OPA(28),INB => INV_MULTIPLICAND(28),
		INC => OPA(29),IND => INV_MULTIPLICAND(29),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(312)
	);
PPM_260:PP_MIDDLE
	port map
	(
		INA => OPA(29),INB => INV_MULTIPLICAND(29),
		INC => OPA(30),IND => INV_MULTIPLICAND(30),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(316)
	);
PPM_261:PP_MIDDLE
	port map
	(
		INA => OPA(30),INB => INV_MULTIPLICAND(30),
		INC => OPA(31),IND => INV_MULTIPLICAND(31),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(320)
	);
PPM_262:PP_MIDDLE
	port map
	(
		INA => OPA(31),INB => INV_MULTIPLICAND(31),
		INC => OPA(32),IND => INV_MULTIPLICAND(32),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(323)
	);
PPM_263:PP_MIDDLE
	port map
	(
		INA => OPA(32),INB => INV_MULTIPLICAND(32),
		INC => OPA(33),IND => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(325)
	);
SUMMAND(326) <= LOGIC_ONE;
PPH_7:PP_HIGH
	port map
	(
		INA => OPA(33),INB => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(328)
	);
-- Begin partial product 8
-- Begin decoder block 9
DEC_8:DECODER -- Decoder of multiplier operand
	port map
	(
		INA => OPB(15),INB => OPB(16),INC => OPB(17),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35)
	);
-- End decoder block 9
-- Begin partial product 9
PPL_8:PP_LOW
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(88)
	);
RGATE_8:R_GATE
	port map
	(
		INA => OPB(15),INB => OPB(16),INC => OPB(17),
		PPBIT => SUMMAND(89)
	);
PPM_264:PP_MIDDLE
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		INC => OPA(1),IND => INV_MULTIPLICAND(1),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(98)
	);
PPM_265:PP_MIDDLE
	port map
	(
		INA => OPA(1),INB => INV_MULTIPLICAND(1),
		INC => OPA(2),IND => INV_MULTIPLICAND(2),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(107)
	);
PPM_266:PP_MIDDLE
	port map
	(
		INA => OPA(2),INB => INV_MULTIPLICAND(2),
		INC => OPA(3),IND => INV_MULTIPLICAND(3),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(116)
	);
PPM_267:PP_MIDDLE
	port map
	(
		INA => OPA(3),INB => INV_MULTIPLICAND(3),
		INC => OPA(4),IND => INV_MULTIPLICAND(4),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(125)
	);
PPM_268:PP_MIDDLE
	port map
	(
		INA => OPA(4),INB => INV_MULTIPLICAND(4),
		INC => OPA(5),IND => INV_MULTIPLICAND(5),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(134)
	);
PPM_269:PP_MIDDLE
	port map
	(
		INA => OPA(5),INB => INV_MULTIPLICAND(5),
		INC => OPA(6),IND => INV_MULTIPLICAND(6),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(143)
	);
PPM_270:PP_MIDDLE
	port map
	(
		INA => OPA(6),INB => INV_MULTIPLICAND(6),
		INC => OPA(7),IND => INV_MULTIPLICAND(7),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(152)
	);
PPM_271:PP_MIDDLE
	port map
	(
		INA => OPA(7),INB => INV_MULTIPLICAND(7),
		INC => OPA(8),IND => INV_MULTIPLICAND(8),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(161)
	);
PPM_272:PP_MIDDLE
	port map
	(
		INA => OPA(8),INB => INV_MULTIPLICAND(8),
		INC => OPA(9),IND => INV_MULTIPLICAND(9),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(170)
	);
PPM_273:PP_MIDDLE
	port map
	(
		INA => OPA(9),INB => INV_MULTIPLICAND(9),
		INC => OPA(10),IND => INV_MULTIPLICAND(10),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(179)
	);
PPM_274:PP_MIDDLE
	port map
	(
		INA => OPA(10),INB => INV_MULTIPLICAND(10),
		INC => OPA(11),IND => INV_MULTIPLICAND(11),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(188)
	);
PPM_275:PP_MIDDLE
	port map
	(
		INA => OPA(11),INB => INV_MULTIPLICAND(11),
		INC => OPA(12),IND => INV_MULTIPLICAND(12),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(197)
	);
PPM_276:PP_MIDDLE
	port map
	(
		INA => OPA(12),INB => INV_MULTIPLICAND(12),
		INC => OPA(13),IND => INV_MULTIPLICAND(13),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(206)
	);
PPM_277:PP_MIDDLE
	port map
	(
		INA => OPA(13),INB => INV_MULTIPLICAND(13),
		INC => OPA(14),IND => INV_MULTIPLICAND(14),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(215)
	);
PPM_278:PP_MIDDLE
	port map
	(
		INA => OPA(14),INB => INV_MULTIPLICAND(14),
		INC => OPA(15),IND => INV_MULTIPLICAND(15),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(224)
	);
PPM_279:PP_MIDDLE
	port map
	(
		INA => OPA(15),INB => INV_MULTIPLICAND(15),
		INC => OPA(16),IND => INV_MULTIPLICAND(16),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(233)
	);
PPM_280:PP_MIDDLE
	port map
	(
		INA => OPA(16),INB => INV_MULTIPLICAND(16),
		INC => OPA(17),IND => INV_MULTIPLICAND(17),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(242)
	);
PPM_281:PP_MIDDLE
	port map
	(
		INA => OPA(17),INB => INV_MULTIPLICAND(17),
		INC => OPA(18),IND => INV_MULTIPLICAND(18),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(252)
	);
PPM_282:PP_MIDDLE
	port map
	(
		INA => OPA(18),INB => INV_MULTIPLICAND(18),
		INC => OPA(19),IND => INV_MULTIPLICAND(19),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(261)
	);
PPM_283:PP_MIDDLE
	port map
	(
		INA => OPA(19),INB => INV_MULTIPLICAND(19),
		INC => OPA(20),IND => INV_MULTIPLICAND(20),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(269)
	);
PPM_284:PP_MIDDLE
	port map
	(
		INA => OPA(20),INB => INV_MULTIPLICAND(20),
		INC => OPA(21),IND => INV_MULTIPLICAND(21),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(277)
	);
PPM_285:PP_MIDDLE
	port map
	(
		INA => OPA(21),INB => INV_MULTIPLICAND(21),
		INC => OPA(22),IND => INV_MULTIPLICAND(22),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(284)
	);
PPM_286:PP_MIDDLE
	port map
	(
		INA => OPA(22),INB => INV_MULTIPLICAND(22),
		INC => OPA(23),IND => INV_MULTIPLICAND(23),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(291)
	);
PPM_287:PP_MIDDLE
	port map
	(
		INA => OPA(23),INB => INV_MULTIPLICAND(23),
		INC => OPA(24),IND => INV_MULTIPLICAND(24),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(297)
	);
PPM_288:PP_MIDDLE
	port map
	(
		INA => OPA(24),INB => INV_MULTIPLICAND(24),
		INC => OPA(25),IND => INV_MULTIPLICAND(25),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(303)
	);
PPM_289:PP_MIDDLE
	port map
	(
		INA => OPA(25),INB => INV_MULTIPLICAND(25),
		INC => OPA(26),IND => INV_MULTIPLICAND(26),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(308)
	);
PPM_290:PP_MIDDLE
	port map
	(
		INA => OPA(26),INB => INV_MULTIPLICAND(26),
		INC => OPA(27),IND => INV_MULTIPLICAND(27),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(313)
	);
PPM_291:PP_MIDDLE
	port map
	(
		INA => OPA(27),INB => INV_MULTIPLICAND(27),
		INC => OPA(28),IND => INV_MULTIPLICAND(28),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(317)
	);
PPM_292:PP_MIDDLE
	port map
	(
		INA => OPA(28),INB => INV_MULTIPLICAND(28),
		INC => OPA(29),IND => INV_MULTIPLICAND(29),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(321)
	);
PPM_293:PP_MIDDLE
	port map
	(
		INA => OPA(29),INB => INV_MULTIPLICAND(29),
		INC => OPA(30),IND => INV_MULTIPLICAND(30),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(324)
	);
PPM_294:PP_MIDDLE
	port map
	(
		INA => OPA(30),INB => INV_MULTIPLICAND(30),
		INC => OPA(31),IND => INV_MULTIPLICAND(31),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(327)
	);
PPM_295:PP_MIDDLE
	port map
	(
		INA => OPA(31),INB => INV_MULTIPLICAND(31),
		INC => OPA(32),IND => INV_MULTIPLICAND(32),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(329)
	);
PPM_296:PP_MIDDLE
	port map
	(
		INA => OPA(32),INB => INV_MULTIPLICAND(32),
		INC => OPA(33),IND => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(330)
	);
SUMMAND(331) <= LOGIC_ONE;
PPH_8:PP_HIGH
	port map
	(
		INA => OPA(33),INB => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(332)
	);
-- Begin partial product 9
end BOOTHCODER;

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.blocks.all;
entity WALLACE_34_18 is
port
(
	SUMMAND: in std_logic_vector(0 to 332);
	CARRY: out std_logic_vector(0 to 49);
	SUM: out std_logic_vector(0 to 50)
);
end WALLACE_34_18;
architecture WALLACE of WALLACE_34_18 is

-- Signals used inside the wallace trees

	signal INT_CARRY: std_logic_vector(0 to 226);
	signal INT_SUM: std_logic_vector(0 to 286);

begin -- netlist

-- Begin WT-branch 1
---- Begin HA stage
HA_0:HALF_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(0), DATA_B => SUMMAND(1), 
		SAVE => SUM(0), CARRY => CARRY(0)
	);
---- End HA stage
-- End WT-branch 1

-- Begin WT-branch 2
---- Begin NO stage
SUM(1) <= SUMMAND(2); -- At Level 1
CARRY(1) <= '0';
---- End NO stage
-- End WT-branch 2

-- Begin WT-branch 3
---- Begin FA stage
FA_0:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(3), DATA_B => SUMMAND(4), DATA_C => SUMMAND(5), 
		SAVE => SUM(2), CARRY => CARRY(2)
	);
---- End FA stage
-- End WT-branch 3

-- Begin WT-branch 4
---- Begin HA stage
HA_1:HALF_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(6), DATA_B => SUMMAND(7), 
		SAVE => SUM(3), CARRY => CARRY(3)
	);
---- End HA stage
-- End WT-branch 4

-- Begin WT-branch 5
---- Begin FA stage
FA_1:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(8), DATA_B => SUMMAND(9), DATA_C => SUMMAND(10), 
		SAVE => INT_SUM(0), CARRY => INT_CARRY(0)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(1) <= SUMMAND(11); -- At Level 1
---- End NO stage
---- Begin HA stage
HA_2:HALF_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(0), DATA_B => INT_SUM(1), 
		SAVE => SUM(4), CARRY => CARRY(4)
	);
---- End HA stage
-- End WT-branch 5

-- Begin WT-branch 6
---- Begin FA stage
FA_2:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(12), DATA_B => SUMMAND(13), DATA_C => SUMMAND(14), 
		SAVE => INT_SUM(2), CARRY => INT_CARRY(1)
	);
---- End FA stage
---- Begin HA stage
HA_3:HALF_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(2), DATA_B => INT_CARRY(0), 
		SAVE => SUM(5), CARRY => CARRY(5)
	);
---- End HA stage
-- End WT-branch 6

-- Begin WT-branch 7
---- Begin FA stage
FA_3:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(15), DATA_B => SUMMAND(16), DATA_C => SUMMAND(17), 
		SAVE => INT_SUM(3), CARRY => INT_CARRY(2)
	);
---- End FA stage
---- Begin HA stage
HA_4:HALF_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(18), DATA_B => SUMMAND(19), 
		SAVE => INT_SUM(4), CARRY => INT_CARRY(3)
	);
---- End HA stage
---- Begin FA stage
FA_4:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(3), DATA_B => INT_SUM(4), DATA_C => INT_CARRY(1), 
		SAVE => SUM(6), CARRY => CARRY(6)
	);
---- End FA stage
-- End WT-branch 7

-- Begin WT-branch 8
---- Begin FA stage
FA_5:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(20), DATA_B => SUMMAND(21), DATA_C => SUMMAND(22), 
		SAVE => INT_SUM(5), CARRY => INT_CARRY(4)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(6) <= SUMMAND(23); -- At Level 1
---- End NO stage
---- Begin FA stage
FA_6:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(5), DATA_B => INT_SUM(6), DATA_C => INT_CARRY(2), 
		SAVE => INT_SUM(7), CARRY => INT_CARRY(5)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(8) <= INT_CARRY(3); -- At Level 2
---- End NO stage
---- Begin HA stage
HA_5:HALF_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(7), DATA_B => INT_SUM(8), 
		SAVE => SUM(7), CARRY => CARRY(7)
	);
---- End HA stage
-- End WT-branch 8

-- Begin WT-branch 9
---- Begin FA stage
FA_7:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(24), DATA_B => SUMMAND(25), DATA_C => SUMMAND(26), 
		SAVE => INT_SUM(9), CARRY => INT_CARRY(6)
	);
---- End FA stage
---- Begin FA stage
FA_8:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(27), DATA_B => SUMMAND(28), DATA_C => SUMMAND(29), 
		SAVE => INT_SUM(10), CARRY => INT_CARRY(7)
	);
---- End FA stage
---- Begin FA stage
FA_9:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(9), DATA_B => INT_SUM(10), DATA_C => INT_CARRY(4), 
		SAVE => INT_SUM(11), CARRY => INT_CARRY(8)
	);
---- End FA stage
---- Begin HA stage
HA_6:HALF_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(11), DATA_B => INT_CARRY(5), 
		SAVE => SUM(8), CARRY => CARRY(8)
	);
---- End HA stage
-- End WT-branch 9

-- Begin WT-branch 10
---- Begin FA stage
FA_10:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(30), DATA_B => SUMMAND(31), DATA_C => SUMMAND(32), 
		SAVE => INT_SUM(12), CARRY => INT_CARRY(9)
	);
---- End FA stage
---- Begin HA stage
HA_7:HALF_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(33), DATA_B => SUMMAND(34), 
		SAVE => INT_SUM(13), CARRY => INT_CARRY(10)
	);
---- End HA stage
---- Begin FA stage
FA_11:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(12), DATA_B => INT_SUM(13), DATA_C => INT_CARRY(6), 
		SAVE => INT_SUM(14), CARRY => INT_CARRY(11)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(15) <= INT_CARRY(7); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_12:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(14), DATA_B => INT_SUM(15), DATA_C => INT_CARRY(8), 
		SAVE => SUM(9), CARRY => CARRY(9)
	);
---- End FA stage
-- End WT-branch 10

-- Begin WT-branch 11
---- Begin FA stage
FA_13:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(35), DATA_B => SUMMAND(36), DATA_C => SUMMAND(37), 
		SAVE => INT_SUM(16), CARRY => INT_CARRY(12)
	);
---- End FA stage
---- Begin FA stage
FA_14:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(38), DATA_B => SUMMAND(39), DATA_C => SUMMAND(40), 
		SAVE => INT_SUM(17), CARRY => INT_CARRY(13)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(18) <= SUMMAND(41); -- At Level 1
---- End NO stage
---- Begin FA stage
FA_15:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(16), DATA_B => INT_SUM(17), DATA_C => INT_SUM(18), 
		SAVE => INT_SUM(19), CARRY => INT_CARRY(14)
	);
---- End FA stage
---- Begin HA stage
HA_8:HALF_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(9), DATA_B => INT_CARRY(10), 
		SAVE => INT_SUM(20), CARRY => INT_CARRY(15)
	);
---- End HA stage
---- Begin FA stage
FA_16:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(19), DATA_B => INT_SUM(20), DATA_C => INT_CARRY(11), 
		SAVE => SUM(10), CARRY => CARRY(10)
	);
---- End FA stage
-- End WT-branch 11

-- Begin WT-branch 12
---- Begin FA stage
FA_17:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(42), DATA_B => SUMMAND(43), DATA_C => SUMMAND(44), 
		SAVE => INT_SUM(21), CARRY => INT_CARRY(16)
	);
---- End FA stage
---- Begin FA stage
FA_18:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(45), DATA_B => SUMMAND(46), DATA_C => SUMMAND(47), 
		SAVE => INT_SUM(22), CARRY => INT_CARRY(17)
	);
---- End FA stage
---- Begin FA stage
FA_19:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(21), DATA_B => INT_SUM(22), DATA_C => INT_CARRY(12), 
		SAVE => INT_SUM(23), CARRY => INT_CARRY(18)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(24) <= INT_CARRY(13); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_20:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(23), DATA_B => INT_SUM(24), DATA_C => INT_CARRY(14), 
		SAVE => INT_SUM(25), CARRY => INT_CARRY(19)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(26) <= INT_CARRY(15); -- At Level 3
---- End NO stage
---- Begin HA stage
HA_9:HALF_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(25), DATA_B => INT_SUM(26), 
		SAVE => SUM(11), CARRY => CARRY(11)
	);
---- End HA stage
-- End WT-branch 12

-- Begin WT-branch 13
---- Begin FA stage
FA_21:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(48), DATA_B => SUMMAND(49), DATA_C => SUMMAND(50), 
		SAVE => INT_SUM(27), CARRY => INT_CARRY(20)
	);
---- End FA stage
---- Begin FA stage
FA_22:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(51), DATA_B => SUMMAND(52), DATA_C => SUMMAND(53), 
		SAVE => INT_SUM(28), CARRY => INT_CARRY(21)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(29) <= SUMMAND(54); -- At Level 1
---- End NO stage
---- Begin NO stage
INT_SUM(30) <= SUMMAND(55); -- At Level 1
---- End NO stage
---- Begin FA stage
FA_23:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(27), DATA_B => INT_SUM(28), DATA_C => INT_SUM(29), 
		SAVE => INT_SUM(31), CARRY => INT_CARRY(22)
	);
---- End FA stage
---- Begin FA stage
FA_24:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(30), DATA_B => INT_CARRY(16), DATA_C => INT_CARRY(17), 
		SAVE => INT_SUM(32), CARRY => INT_CARRY(23)
	);
---- End FA stage
---- Begin FA stage
FA_25:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(31), DATA_B => INT_SUM(32), DATA_C => INT_CARRY(18), 
		SAVE => INT_SUM(33), CARRY => INT_CARRY(24)
	);
---- End FA stage
---- Begin HA stage
HA_10:HALF_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(33), DATA_B => INT_CARRY(19), 
		SAVE => SUM(12), CARRY => CARRY(12)
	);
---- End HA stage
-- End WT-branch 13

-- Begin WT-branch 14
---- Begin FA stage
FA_26:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(56), DATA_B => SUMMAND(57), DATA_C => SUMMAND(58), 
		SAVE => INT_SUM(34), CARRY => INT_CARRY(25)
	);
---- End FA stage
---- Begin FA stage
FA_27:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(59), DATA_B => SUMMAND(60), DATA_C => SUMMAND(61), 
		SAVE => INT_SUM(35), CARRY => INT_CARRY(26)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(36) <= SUMMAND(62); -- At Level 1
---- End NO stage
---- Begin FA stage
FA_28:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(34), DATA_B => INT_SUM(35), DATA_C => INT_SUM(36), 
		SAVE => INT_SUM(37), CARRY => INT_CARRY(27)
	);
---- End FA stage
---- Begin HA stage
HA_11:HALF_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(20), DATA_B => INT_CARRY(21), 
		SAVE => INT_SUM(38), CARRY => INT_CARRY(28)
	);
---- End HA stage
---- Begin FA stage
FA_29:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(37), DATA_B => INT_SUM(38), DATA_C => INT_CARRY(22), 
		SAVE => INT_SUM(39), CARRY => INT_CARRY(29)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(40) <= INT_CARRY(23); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_30:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(39), DATA_B => INT_SUM(40), DATA_C => INT_CARRY(24), 
		SAVE => SUM(13), CARRY => CARRY(13)
	);
---- End FA stage
-- End WT-branch 14

-- Begin WT-branch 15
---- Begin FA stage
FA_31:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(63), DATA_B => SUMMAND(64), DATA_C => SUMMAND(65), 
		SAVE => INT_SUM(41), CARRY => INT_CARRY(30)
	);
---- End FA stage
---- Begin FA stage
FA_32:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(66), DATA_B => SUMMAND(67), DATA_C => SUMMAND(68), 
		SAVE => INT_SUM(42), CARRY => INT_CARRY(31)
	);
---- End FA stage
---- Begin FA stage
FA_33:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(69), DATA_B => SUMMAND(70), DATA_C => SUMMAND(71), 
		SAVE => INT_SUM(43), CARRY => INT_CARRY(32)
	);
---- End FA stage
---- Begin FA stage
FA_34:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(41), DATA_B => INT_SUM(42), DATA_C => INT_SUM(43), 
		SAVE => INT_SUM(44), CARRY => INT_CARRY(33)
	);
---- End FA stage
---- Begin HA stage
HA_12:HALF_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(25), DATA_B => INT_CARRY(26), 
		SAVE => INT_SUM(45), CARRY => INT_CARRY(34)
	);
---- End HA stage
---- Begin FA stage
FA_35:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(44), DATA_B => INT_SUM(45), DATA_C => INT_CARRY(27), 
		SAVE => INT_SUM(46), CARRY => INT_CARRY(35)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(47) <= INT_CARRY(28); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_36:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(46), DATA_B => INT_SUM(47), DATA_C => INT_CARRY(29), 
		SAVE => SUM(14), CARRY => CARRY(14)
	);
---- End FA stage
-- End WT-branch 15

-- Begin WT-branch 16
---- Begin FA stage
FA_37:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(72), DATA_B => SUMMAND(73), DATA_C => SUMMAND(74), 
		SAVE => INT_SUM(48), CARRY => INT_CARRY(36)
	);
---- End FA stage
---- Begin FA stage
FA_38:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(75), DATA_B => SUMMAND(76), DATA_C => SUMMAND(77), 
		SAVE => INT_SUM(49), CARRY => INT_CARRY(37)
	);
---- End FA stage
---- Begin HA stage
HA_13:HALF_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(78), DATA_B => SUMMAND(79), 
		SAVE => INT_SUM(50), CARRY => INT_CARRY(38)
	);
---- End HA stage
---- Begin FA stage
FA_39:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(48), DATA_B => INT_SUM(49), DATA_C => INT_SUM(50), 
		SAVE => INT_SUM(51), CARRY => INT_CARRY(39)
	);
---- End FA stage
---- Begin FA stage
FA_40:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(30), DATA_B => INT_CARRY(31), DATA_C => INT_CARRY(32), 
		SAVE => INT_SUM(52), CARRY => INT_CARRY(40)
	);
---- End FA stage
---- Begin FA stage
FA_41:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(51), DATA_B => INT_SUM(52), DATA_C => INT_CARRY(33), 
		SAVE => INT_SUM(53), CARRY => INT_CARRY(41)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(54) <= INT_CARRY(34); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_42:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(53), DATA_B => INT_SUM(54), DATA_C => INT_CARRY(35), 
		SAVE => SUM(15), CARRY => CARRY(15)
	);
---- End FA stage
-- End WT-branch 16

-- Begin WT-branch 17
---- Begin FA stage
FA_43:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(80), DATA_B => SUMMAND(81), DATA_C => SUMMAND(82), 
		SAVE => INT_SUM(55), CARRY => INT_CARRY(42)
	);
---- End FA stage
---- Begin FA stage
FA_44:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(83), DATA_B => SUMMAND(84), DATA_C => SUMMAND(85), 
		SAVE => INT_SUM(56), CARRY => INT_CARRY(43)
	);
---- End FA stage
---- Begin FA stage
FA_45:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(86), DATA_B => SUMMAND(87), DATA_C => SUMMAND(88), 
		SAVE => INT_SUM(57), CARRY => INT_CARRY(44)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(58) <= SUMMAND(89); -- At Level 1
---- End NO stage
---- Begin FA stage
FA_46:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(55), DATA_B => INT_SUM(56), DATA_C => INT_SUM(57), 
		SAVE => INT_SUM(59), CARRY => INT_CARRY(45)
	);
---- End FA stage
---- Begin FA stage
FA_47:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(58), DATA_B => INT_CARRY(36), DATA_C => INT_CARRY(37), 
		SAVE => INT_SUM(60), CARRY => INT_CARRY(46)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(61) <= INT_CARRY(38); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_48:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(59), DATA_B => INT_SUM(60), DATA_C => INT_SUM(61), 
		SAVE => INT_SUM(62), CARRY => INT_CARRY(47)
	);
---- End FA stage
---- Begin HA stage
HA_14:HALF_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_CARRY(39), DATA_B => INT_CARRY(40), 
		SAVE => INT_SUM(63), CARRY => INT_CARRY(48)
	);
---- End HA stage
---- Begin FA stage
FA_49:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(62), DATA_B => INT_SUM(63), DATA_C => INT_CARRY(41), 
		SAVE => SUM(16), CARRY => CARRY(16)
	);
---- End FA stage
-- End WT-branch 17

-- Begin WT-branch 18
---- Begin FA stage
FA_50:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(90), DATA_B => SUMMAND(91), DATA_C => SUMMAND(92), 
		SAVE => INT_SUM(64), CARRY => INT_CARRY(49)
	);
---- End FA stage
---- Begin FA stage
FA_51:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(93), DATA_B => SUMMAND(94), DATA_C => SUMMAND(95), 
		SAVE => INT_SUM(65), CARRY => INT_CARRY(50)
	);
---- End FA stage
---- Begin FA stage
FA_52:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(96), DATA_B => SUMMAND(97), DATA_C => SUMMAND(98), 
		SAVE => INT_SUM(66), CARRY => INT_CARRY(51)
	);
---- End FA stage
---- Begin FA stage
FA_53:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(64), DATA_B => INT_SUM(65), DATA_C => INT_SUM(66), 
		SAVE => INT_SUM(67), CARRY => INT_CARRY(52)
	);
---- End FA stage
---- Begin FA stage
FA_54:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(42), DATA_B => INT_CARRY(43), DATA_C => INT_CARRY(44), 
		SAVE => INT_SUM(68), CARRY => INT_CARRY(53)
	);
---- End FA stage
---- Begin FA stage
FA_55:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(67), DATA_B => INT_SUM(68), DATA_C => INT_CARRY(45), 
		SAVE => INT_SUM(69), CARRY => INT_CARRY(54)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(70) <= INT_CARRY(46); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_56:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(69), DATA_B => INT_SUM(70), DATA_C => INT_CARRY(47), 
		SAVE => INT_SUM(71), CARRY => INT_CARRY(55)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(72) <= INT_CARRY(48); -- At Level 4
---- End NO stage
---- Begin HA stage
HA_15:HALF_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(71), DATA_B => INT_SUM(72), 
		SAVE => SUM(17), CARRY => CARRY(17)
	);
---- End HA stage
-- End WT-branch 18

-- Begin WT-branch 19
---- Begin FA stage
FA_57:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(99), DATA_B => SUMMAND(100), DATA_C => SUMMAND(101), 
		SAVE => INT_SUM(73), CARRY => INT_CARRY(56)
	);
---- End FA stage
---- Begin FA stage
FA_58:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(102), DATA_B => SUMMAND(103), DATA_C => SUMMAND(104), 
		SAVE => INT_SUM(74), CARRY => INT_CARRY(57)
	);
---- End FA stage
---- Begin FA stage
FA_59:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(105), DATA_B => SUMMAND(106), DATA_C => SUMMAND(107), 
		SAVE => INT_SUM(75), CARRY => INT_CARRY(58)
	);
---- End FA stage
---- Begin FA stage
FA_60:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(73), DATA_B => INT_SUM(74), DATA_C => INT_SUM(75), 
		SAVE => INT_SUM(76), CARRY => INT_CARRY(59)
	);
---- End FA stage
---- Begin FA stage
FA_61:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(49), DATA_B => INT_CARRY(50), DATA_C => INT_CARRY(51), 
		SAVE => INT_SUM(77), CARRY => INT_CARRY(60)
	);
---- End FA stage
---- Begin FA stage
FA_62:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(76), DATA_B => INT_SUM(77), DATA_C => INT_CARRY(52), 
		SAVE => INT_SUM(78), CARRY => INT_CARRY(61)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(79) <= INT_CARRY(53); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_63:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(78), DATA_B => INT_SUM(79), DATA_C => INT_CARRY(54), 
		SAVE => INT_SUM(80), CARRY => INT_CARRY(62)
	);
---- End FA stage
---- Begin HA stage
HA_16:HALF_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(80), DATA_B => INT_CARRY(55), 
		SAVE => SUM(18), CARRY => CARRY(18)
	);
---- End HA stage
-- End WT-branch 19

-- Begin WT-branch 20
---- Begin FA stage
FA_64:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(108), DATA_B => SUMMAND(109), DATA_C => SUMMAND(110), 
		SAVE => INT_SUM(81), CARRY => INT_CARRY(63)
	);
---- End FA stage
---- Begin FA stage
FA_65:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(111), DATA_B => SUMMAND(112), DATA_C => SUMMAND(113), 
		SAVE => INT_SUM(82), CARRY => INT_CARRY(64)
	);
---- End FA stage
---- Begin FA stage
FA_66:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(114), DATA_B => SUMMAND(115), DATA_C => SUMMAND(116), 
		SAVE => INT_SUM(83), CARRY => INT_CARRY(65)
	);
---- End FA stage
---- Begin FA stage
FA_67:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(81), DATA_B => INT_SUM(82), DATA_C => INT_SUM(83), 
		SAVE => INT_SUM(84), CARRY => INT_CARRY(66)
	);
---- End FA stage
---- Begin FA stage
FA_68:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(56), DATA_B => INT_CARRY(57), DATA_C => INT_CARRY(58), 
		SAVE => INT_SUM(85), CARRY => INT_CARRY(67)
	);
---- End FA stage
---- Begin FA stage
FA_69:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(84), DATA_B => INT_SUM(85), DATA_C => INT_CARRY(59), 
		SAVE => INT_SUM(86), CARRY => INT_CARRY(68)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(87) <= INT_CARRY(60); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_70:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(86), DATA_B => INT_SUM(87), DATA_C => INT_CARRY(61), 
		SAVE => INT_SUM(88), CARRY => INT_CARRY(69)
	);
---- End FA stage
---- Begin HA stage
HA_17:HALF_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(88), DATA_B => INT_CARRY(62), 
		SAVE => SUM(19), CARRY => CARRY(19)
	);
---- End HA stage
-- End WT-branch 20

-- Begin WT-branch 21
---- Begin FA stage
FA_71:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(117), DATA_B => SUMMAND(118), DATA_C => SUMMAND(119), 
		SAVE => INT_SUM(89), CARRY => INT_CARRY(70)
	);
---- End FA stage
---- Begin FA stage
FA_72:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(120), DATA_B => SUMMAND(121), DATA_C => SUMMAND(122), 
		SAVE => INT_SUM(90), CARRY => INT_CARRY(71)
	);
---- End FA stage
---- Begin FA stage
FA_73:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(123), DATA_B => SUMMAND(124), DATA_C => SUMMAND(125), 
		SAVE => INT_SUM(91), CARRY => INT_CARRY(72)
	);
---- End FA stage
---- Begin FA stage
FA_74:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(89), DATA_B => INT_SUM(90), DATA_C => INT_SUM(91), 
		SAVE => INT_SUM(92), CARRY => INT_CARRY(73)
	);
---- End FA stage
---- Begin FA stage
FA_75:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(63), DATA_B => INT_CARRY(64), DATA_C => INT_CARRY(65), 
		SAVE => INT_SUM(93), CARRY => INT_CARRY(74)
	);
---- End FA stage
---- Begin FA stage
FA_76:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(92), DATA_B => INT_SUM(93), DATA_C => INT_CARRY(66), 
		SAVE => INT_SUM(94), CARRY => INT_CARRY(75)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(95) <= INT_CARRY(67); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_77:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(94), DATA_B => INT_SUM(95), DATA_C => INT_CARRY(68), 
		SAVE => INT_SUM(96), CARRY => INT_CARRY(76)
	);
---- End FA stage
---- Begin HA stage
HA_18:HALF_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(96), DATA_B => INT_CARRY(69), 
		SAVE => SUM(20), CARRY => CARRY(20)
	);
---- End HA stage
-- End WT-branch 21

-- Begin WT-branch 22
---- Begin FA stage
FA_78:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(126), DATA_B => SUMMAND(127), DATA_C => SUMMAND(128), 
		SAVE => INT_SUM(97), CARRY => INT_CARRY(77)
	);
---- End FA stage
---- Begin FA stage
FA_79:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(129), DATA_B => SUMMAND(130), DATA_C => SUMMAND(131), 
		SAVE => INT_SUM(98), CARRY => INT_CARRY(78)
	);
---- End FA stage
---- Begin FA stage
FA_80:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(132), DATA_B => SUMMAND(133), DATA_C => SUMMAND(134), 
		SAVE => INT_SUM(99), CARRY => INT_CARRY(79)
	);
---- End FA stage
---- Begin FA stage
FA_81:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(97), DATA_B => INT_SUM(98), DATA_C => INT_SUM(99), 
		SAVE => INT_SUM(100), CARRY => INT_CARRY(80)
	);
---- End FA stage
---- Begin FA stage
FA_82:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(70), DATA_B => INT_CARRY(71), DATA_C => INT_CARRY(72), 
		SAVE => INT_SUM(101), CARRY => INT_CARRY(81)
	);
---- End FA stage
---- Begin FA stage
FA_83:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(100), DATA_B => INT_SUM(101), DATA_C => INT_CARRY(73), 
		SAVE => INT_SUM(102), CARRY => INT_CARRY(82)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(103) <= INT_CARRY(74); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_84:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(102), DATA_B => INT_SUM(103), DATA_C => INT_CARRY(75), 
		SAVE => INT_SUM(104), CARRY => INT_CARRY(83)
	);
---- End FA stage
---- Begin HA stage
HA_19:HALF_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(104), DATA_B => INT_CARRY(76), 
		SAVE => SUM(21), CARRY => CARRY(21)
	);
---- End HA stage
-- End WT-branch 22

-- Begin WT-branch 23
---- Begin FA stage
FA_85:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(135), DATA_B => SUMMAND(136), DATA_C => SUMMAND(137), 
		SAVE => INT_SUM(105), CARRY => INT_CARRY(84)
	);
---- End FA stage
---- Begin FA stage
FA_86:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(138), DATA_B => SUMMAND(139), DATA_C => SUMMAND(140), 
		SAVE => INT_SUM(106), CARRY => INT_CARRY(85)
	);
---- End FA stage
---- Begin FA stage
FA_87:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(141), DATA_B => SUMMAND(142), DATA_C => SUMMAND(143), 
		SAVE => INT_SUM(107), CARRY => INT_CARRY(86)
	);
---- End FA stage
---- Begin FA stage
FA_88:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(105), DATA_B => INT_SUM(106), DATA_C => INT_SUM(107), 
		SAVE => INT_SUM(108), CARRY => INT_CARRY(87)
	);
---- End FA stage
---- Begin FA stage
FA_89:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(77), DATA_B => INT_CARRY(78), DATA_C => INT_CARRY(79), 
		SAVE => INT_SUM(109), CARRY => INT_CARRY(88)
	);
---- End FA stage
---- Begin FA stage
FA_90:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(108), DATA_B => INT_SUM(109), DATA_C => INT_CARRY(80), 
		SAVE => INT_SUM(110), CARRY => INT_CARRY(89)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(111) <= INT_CARRY(81); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_91:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(110), DATA_B => INT_SUM(111), DATA_C => INT_CARRY(82), 
		SAVE => INT_SUM(112), CARRY => INT_CARRY(90)
	);
---- End FA stage
---- Begin HA stage
HA_20:HALF_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(112), DATA_B => INT_CARRY(83), 
		SAVE => SUM(22), CARRY => CARRY(22)
	);
---- End HA stage
-- End WT-branch 23

-- Begin WT-branch 24
---- Begin FA stage
FA_92:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(144), DATA_B => SUMMAND(145), DATA_C => SUMMAND(146), 
		SAVE => INT_SUM(113), CARRY => INT_CARRY(91)
	);
---- End FA stage
---- Begin FA stage
FA_93:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(147), DATA_B => SUMMAND(148), DATA_C => SUMMAND(149), 
		SAVE => INT_SUM(114), CARRY => INT_CARRY(92)
	);
---- End FA stage
---- Begin FA stage
FA_94:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(150), DATA_B => SUMMAND(151), DATA_C => SUMMAND(152), 
		SAVE => INT_SUM(115), CARRY => INT_CARRY(93)
	);
---- End FA stage
---- Begin FA stage
FA_95:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(113), DATA_B => INT_SUM(114), DATA_C => INT_SUM(115), 
		SAVE => INT_SUM(116), CARRY => INT_CARRY(94)
	);
---- End FA stage
---- Begin FA stage
FA_96:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(84), DATA_B => INT_CARRY(85), DATA_C => INT_CARRY(86), 
		SAVE => INT_SUM(117), CARRY => INT_CARRY(95)
	);
---- End FA stage
---- Begin FA stage
FA_97:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(116), DATA_B => INT_SUM(117), DATA_C => INT_CARRY(87), 
		SAVE => INT_SUM(118), CARRY => INT_CARRY(96)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(119) <= INT_CARRY(88); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_98:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(118), DATA_B => INT_SUM(119), DATA_C => INT_CARRY(89), 
		SAVE => INT_SUM(120), CARRY => INT_CARRY(97)
	);
---- End FA stage
---- Begin HA stage
HA_21:HALF_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(120), DATA_B => INT_CARRY(90), 
		SAVE => SUM(23), CARRY => CARRY(23)
	);
---- End HA stage
-- End WT-branch 24

-- Begin WT-branch 25
---- Begin FA stage
FA_99:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(153), DATA_B => SUMMAND(154), DATA_C => SUMMAND(155), 
		SAVE => INT_SUM(121), CARRY => INT_CARRY(98)
	);
---- End FA stage
---- Begin FA stage
FA_100:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(156), DATA_B => SUMMAND(157), DATA_C => SUMMAND(158), 
		SAVE => INT_SUM(122), CARRY => INT_CARRY(99)
	);
---- End FA stage
---- Begin FA stage
FA_101:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(159), DATA_B => SUMMAND(160), DATA_C => SUMMAND(161), 
		SAVE => INT_SUM(123), CARRY => INT_CARRY(100)
	);
---- End FA stage
---- Begin FA stage
FA_102:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(121), DATA_B => INT_SUM(122), DATA_C => INT_SUM(123), 
		SAVE => INT_SUM(124), CARRY => INT_CARRY(101)
	);
---- End FA stage
---- Begin FA stage
FA_103:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(91), DATA_B => INT_CARRY(92), DATA_C => INT_CARRY(93), 
		SAVE => INT_SUM(125), CARRY => INT_CARRY(102)
	);
---- End FA stage
---- Begin FA stage
FA_104:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(124), DATA_B => INT_SUM(125), DATA_C => INT_CARRY(94), 
		SAVE => INT_SUM(126), CARRY => INT_CARRY(103)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(127) <= INT_CARRY(95); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_105:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(126), DATA_B => INT_SUM(127), DATA_C => INT_CARRY(96), 
		SAVE => INT_SUM(128), CARRY => INT_CARRY(104)
	);
---- End FA stage
---- Begin HA stage
HA_22:HALF_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(128), DATA_B => INT_CARRY(97), 
		SAVE => SUM(24), CARRY => CARRY(24)
	);
---- End HA stage
-- End WT-branch 25

-- Begin WT-branch 26
---- Begin FA stage
FA_106:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(162), DATA_B => SUMMAND(163), DATA_C => SUMMAND(164), 
		SAVE => INT_SUM(129), CARRY => INT_CARRY(105)
	);
---- End FA stage
---- Begin FA stage
FA_107:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(165), DATA_B => SUMMAND(166), DATA_C => SUMMAND(167), 
		SAVE => INT_SUM(130), CARRY => INT_CARRY(106)
	);
---- End FA stage
---- Begin FA stage
FA_108:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(168), DATA_B => SUMMAND(169), DATA_C => SUMMAND(170), 
		SAVE => INT_SUM(131), CARRY => INT_CARRY(107)
	);
---- End FA stage
---- Begin FA stage
FA_109:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(129), DATA_B => INT_SUM(130), DATA_C => INT_SUM(131), 
		SAVE => INT_SUM(132), CARRY => INT_CARRY(108)
	);
---- End FA stage
---- Begin FA stage
FA_110:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(98), DATA_B => INT_CARRY(99), DATA_C => INT_CARRY(100), 
		SAVE => INT_SUM(133), CARRY => INT_CARRY(109)
	);
---- End FA stage
---- Begin FA stage
FA_111:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(132), DATA_B => INT_SUM(133), DATA_C => INT_CARRY(101), 
		SAVE => INT_SUM(134), CARRY => INT_CARRY(110)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(135) <= INT_CARRY(102); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_112:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(134), DATA_B => INT_SUM(135), DATA_C => INT_CARRY(103), 
		SAVE => INT_SUM(136), CARRY => INT_CARRY(111)
	);
---- End FA stage
---- Begin HA stage
HA_23:HALF_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(136), DATA_B => INT_CARRY(104), 
		SAVE => SUM(25), CARRY => CARRY(25)
	);
---- End HA stage
-- End WT-branch 26

-- Begin WT-branch 27
---- Begin FA stage
FA_113:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(171), DATA_B => SUMMAND(172), DATA_C => SUMMAND(173), 
		SAVE => INT_SUM(137), CARRY => INT_CARRY(112)
	);
---- End FA stage
---- Begin FA stage
FA_114:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(174), DATA_B => SUMMAND(175), DATA_C => SUMMAND(176), 
		SAVE => INT_SUM(138), CARRY => INT_CARRY(113)
	);
---- End FA stage
---- Begin FA stage
FA_115:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(177), DATA_B => SUMMAND(178), DATA_C => SUMMAND(179), 
		SAVE => INT_SUM(139), CARRY => INT_CARRY(114)
	);
---- End FA stage
---- Begin FA stage
FA_116:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(137), DATA_B => INT_SUM(138), DATA_C => INT_SUM(139), 
		SAVE => INT_SUM(140), CARRY => INT_CARRY(115)
	);
---- End FA stage
---- Begin FA stage
FA_117:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(105), DATA_B => INT_CARRY(106), DATA_C => INT_CARRY(107), 
		SAVE => INT_SUM(141), CARRY => INT_CARRY(116)
	);
---- End FA stage
---- Begin FA stage
FA_118:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(140), DATA_B => INT_SUM(141), DATA_C => INT_CARRY(108), 
		SAVE => INT_SUM(142), CARRY => INT_CARRY(117)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(143) <= INT_CARRY(109); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_119:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(142), DATA_B => INT_SUM(143), DATA_C => INT_CARRY(110), 
		SAVE => INT_SUM(144), CARRY => INT_CARRY(118)
	);
---- End FA stage
---- Begin HA stage
HA_24:HALF_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(144), DATA_B => INT_CARRY(111), 
		SAVE => SUM(26), CARRY => CARRY(26)
	);
---- End HA stage
-- End WT-branch 27

-- Begin WT-branch 28
---- Begin FA stage
FA_120:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(180), DATA_B => SUMMAND(181), DATA_C => SUMMAND(182), 
		SAVE => INT_SUM(145), CARRY => INT_CARRY(119)
	);
---- End FA stage
---- Begin FA stage
FA_121:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(183), DATA_B => SUMMAND(184), DATA_C => SUMMAND(185), 
		SAVE => INT_SUM(146), CARRY => INT_CARRY(120)
	);
---- End FA stage
---- Begin FA stage
FA_122:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(186), DATA_B => SUMMAND(187), DATA_C => SUMMAND(188), 
		SAVE => INT_SUM(147), CARRY => INT_CARRY(121)
	);
---- End FA stage
---- Begin FA stage
FA_123:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(145), DATA_B => INT_SUM(146), DATA_C => INT_SUM(147), 
		SAVE => INT_SUM(148), CARRY => INT_CARRY(122)
	);
---- End FA stage
---- Begin FA stage
FA_124:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(112), DATA_B => INT_CARRY(113), DATA_C => INT_CARRY(114), 
		SAVE => INT_SUM(149), CARRY => INT_CARRY(123)
	);
---- End FA stage
---- Begin FA stage
FA_125:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(148), DATA_B => INT_SUM(149), DATA_C => INT_CARRY(115), 
		SAVE => INT_SUM(150), CARRY => INT_CARRY(124)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(151) <= INT_CARRY(116); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_126:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(150), DATA_B => INT_SUM(151), DATA_C => INT_CARRY(117), 
		SAVE => INT_SUM(152), CARRY => INT_CARRY(125)
	);
---- End FA stage
---- Begin HA stage
HA_25:HALF_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(152), DATA_B => INT_CARRY(118), 
		SAVE => SUM(27), CARRY => CARRY(27)
	);
---- End HA stage
-- End WT-branch 28

-- Begin WT-branch 29
---- Begin FA stage
FA_127:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(189), DATA_B => SUMMAND(190), DATA_C => SUMMAND(191), 
		SAVE => INT_SUM(153), CARRY => INT_CARRY(126)
	);
---- End FA stage
---- Begin FA stage
FA_128:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(192), DATA_B => SUMMAND(193), DATA_C => SUMMAND(194), 
		SAVE => INT_SUM(154), CARRY => INT_CARRY(127)
	);
---- End FA stage
---- Begin FA stage
FA_129:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(195), DATA_B => SUMMAND(196), DATA_C => SUMMAND(197), 
		SAVE => INT_SUM(155), CARRY => INT_CARRY(128)
	);
---- End FA stage
---- Begin FA stage
FA_130:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(153), DATA_B => INT_SUM(154), DATA_C => INT_SUM(155), 
		SAVE => INT_SUM(156), CARRY => INT_CARRY(129)
	);
---- End FA stage
---- Begin FA stage
FA_131:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(119), DATA_B => INT_CARRY(120), DATA_C => INT_CARRY(121), 
		SAVE => INT_SUM(157), CARRY => INT_CARRY(130)
	);
---- End FA stage
---- Begin FA stage
FA_132:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(156), DATA_B => INT_SUM(157), DATA_C => INT_CARRY(122), 
		SAVE => INT_SUM(158), CARRY => INT_CARRY(131)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(159) <= INT_CARRY(123); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_133:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(158), DATA_B => INT_SUM(159), DATA_C => INT_CARRY(124), 
		SAVE => INT_SUM(160), CARRY => INT_CARRY(132)
	);
---- End FA stage
---- Begin HA stage
HA_26:HALF_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(160), DATA_B => INT_CARRY(125), 
		SAVE => SUM(28), CARRY => CARRY(28)
	);
---- End HA stage
-- End WT-branch 29

-- Begin WT-branch 30
---- Begin FA stage
FA_134:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(198), DATA_B => SUMMAND(199), DATA_C => SUMMAND(200), 
		SAVE => INT_SUM(161), CARRY => INT_CARRY(133)
	);
---- End FA stage
---- Begin FA stage
FA_135:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(201), DATA_B => SUMMAND(202), DATA_C => SUMMAND(203), 
		SAVE => INT_SUM(162), CARRY => INT_CARRY(134)
	);
---- End FA stage
---- Begin FA stage
FA_136:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(204), DATA_B => SUMMAND(205), DATA_C => SUMMAND(206), 
		SAVE => INT_SUM(163), CARRY => INT_CARRY(135)
	);
---- End FA stage
---- Begin FA stage
FA_137:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(161), DATA_B => INT_SUM(162), DATA_C => INT_SUM(163), 
		SAVE => INT_SUM(164), CARRY => INT_CARRY(136)
	);
---- End FA stage
---- Begin FA stage
FA_138:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(126), DATA_B => INT_CARRY(127), DATA_C => INT_CARRY(128), 
		SAVE => INT_SUM(165), CARRY => INT_CARRY(137)
	);
---- End FA stage
---- Begin FA stage
FA_139:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(164), DATA_B => INT_SUM(165), DATA_C => INT_CARRY(129), 
		SAVE => INT_SUM(166), CARRY => INT_CARRY(138)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(167) <= INT_CARRY(130); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_140:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(166), DATA_B => INT_SUM(167), DATA_C => INT_CARRY(131), 
		SAVE => INT_SUM(168), CARRY => INT_CARRY(139)
	);
---- End FA stage
---- Begin HA stage
HA_27:HALF_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(168), DATA_B => INT_CARRY(132), 
		SAVE => SUM(29), CARRY => CARRY(29)
	);
---- End HA stage
-- End WT-branch 30

-- Begin WT-branch 31
---- Begin FA stage
FA_141:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(207), DATA_B => SUMMAND(208), DATA_C => SUMMAND(209), 
		SAVE => INT_SUM(169), CARRY => INT_CARRY(140)
	);
---- End FA stage
---- Begin FA stage
FA_142:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(210), DATA_B => SUMMAND(211), DATA_C => SUMMAND(212), 
		SAVE => INT_SUM(170), CARRY => INT_CARRY(141)
	);
---- End FA stage
---- Begin FA stage
FA_143:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(213), DATA_B => SUMMAND(214), DATA_C => SUMMAND(215), 
		SAVE => INT_SUM(171), CARRY => INT_CARRY(142)
	);
---- End FA stage
---- Begin FA stage
FA_144:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(169), DATA_B => INT_SUM(170), DATA_C => INT_SUM(171), 
		SAVE => INT_SUM(172), CARRY => INT_CARRY(143)
	);
---- End FA stage
---- Begin FA stage
FA_145:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(133), DATA_B => INT_CARRY(134), DATA_C => INT_CARRY(135), 
		SAVE => INT_SUM(173), CARRY => INT_CARRY(144)
	);
---- End FA stage
---- Begin FA stage
FA_146:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(172), DATA_B => INT_SUM(173), DATA_C => INT_CARRY(136), 
		SAVE => INT_SUM(174), CARRY => INT_CARRY(145)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(175) <= INT_CARRY(137); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_147:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(174), DATA_B => INT_SUM(175), DATA_C => INT_CARRY(138), 
		SAVE => INT_SUM(176), CARRY => INT_CARRY(146)
	);
---- End FA stage
---- Begin HA stage
HA_28:HALF_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(176), DATA_B => INT_CARRY(139), 
		SAVE => SUM(30), CARRY => CARRY(30)
	);
---- End HA stage
-- End WT-branch 31

-- Begin WT-branch 32
---- Begin FA stage
FA_148:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(216), DATA_B => SUMMAND(217), DATA_C => SUMMAND(218), 
		SAVE => INT_SUM(177), CARRY => INT_CARRY(147)
	);
---- End FA stage
---- Begin FA stage
FA_149:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(219), DATA_B => SUMMAND(220), DATA_C => SUMMAND(221), 
		SAVE => INT_SUM(178), CARRY => INT_CARRY(148)
	);
---- End FA stage
---- Begin FA stage
FA_150:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(222), DATA_B => SUMMAND(223), DATA_C => SUMMAND(224), 
		SAVE => INT_SUM(179), CARRY => INT_CARRY(149)
	);
---- End FA stage
---- Begin FA stage
FA_151:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(177), DATA_B => INT_SUM(178), DATA_C => INT_SUM(179), 
		SAVE => INT_SUM(180), CARRY => INT_CARRY(150)
	);
---- End FA stage
---- Begin FA stage
FA_152:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(140), DATA_B => INT_CARRY(141), DATA_C => INT_CARRY(142), 
		SAVE => INT_SUM(181), CARRY => INT_CARRY(151)
	);
---- End FA stage
---- Begin FA stage
FA_153:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(180), DATA_B => INT_SUM(181), DATA_C => INT_CARRY(143), 
		SAVE => INT_SUM(182), CARRY => INT_CARRY(152)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(183) <= INT_CARRY(144); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_154:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(182), DATA_B => INT_SUM(183), DATA_C => INT_CARRY(145), 
		SAVE => INT_SUM(184), CARRY => INT_CARRY(153)
	);
---- End FA stage
---- Begin HA stage
HA_29:HALF_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(184), DATA_B => INT_CARRY(146), 
		SAVE => SUM(31), CARRY => CARRY(31)
	);
---- End HA stage
-- End WT-branch 32

-- Begin WT-branch 33
---- Begin FA stage
FA_155:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(225), DATA_B => SUMMAND(226), DATA_C => SUMMAND(227), 
		SAVE => INT_SUM(185), CARRY => INT_CARRY(154)
	);
---- End FA stage
---- Begin FA stage
FA_156:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(228), DATA_B => SUMMAND(229), DATA_C => SUMMAND(230), 
		SAVE => INT_SUM(186), CARRY => INT_CARRY(155)
	);
---- End FA stage
---- Begin FA stage
FA_157:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(231), DATA_B => SUMMAND(232), DATA_C => SUMMAND(233), 
		SAVE => INT_SUM(187), CARRY => INT_CARRY(156)
	);
---- End FA stage
---- Begin FA stage
FA_158:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(185), DATA_B => INT_SUM(186), DATA_C => INT_SUM(187), 
		SAVE => INT_SUM(188), CARRY => INT_CARRY(157)
	);
---- End FA stage
---- Begin FA stage
FA_159:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(147), DATA_B => INT_CARRY(148), DATA_C => INT_CARRY(149), 
		SAVE => INT_SUM(189), CARRY => INT_CARRY(158)
	);
---- End FA stage
---- Begin FA stage
FA_160:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(188), DATA_B => INT_SUM(189), DATA_C => INT_CARRY(150), 
		SAVE => INT_SUM(190), CARRY => INT_CARRY(159)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(191) <= INT_CARRY(151); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_161:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(190), DATA_B => INT_SUM(191), DATA_C => INT_CARRY(152), 
		SAVE => INT_SUM(192), CARRY => INT_CARRY(160)
	);
---- End FA stage
---- Begin HA stage
HA_30:HALF_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(192), DATA_B => INT_CARRY(153), 
		SAVE => SUM(32), CARRY => CARRY(32)
	);
---- End HA stage
-- End WT-branch 33

-- Begin WT-branch 34
---- Begin FA stage
FA_162:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(234), DATA_B => SUMMAND(235), DATA_C => SUMMAND(236), 
		SAVE => INT_SUM(193), CARRY => INT_CARRY(161)
	);
---- End FA stage
---- Begin FA stage
FA_163:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(237), DATA_B => SUMMAND(238), DATA_C => SUMMAND(239), 
		SAVE => INT_SUM(194), CARRY => INT_CARRY(162)
	);
---- End FA stage
---- Begin FA stage
FA_164:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(240), DATA_B => SUMMAND(241), DATA_C => SUMMAND(242), 
		SAVE => INT_SUM(195), CARRY => INT_CARRY(163)
	);
---- End FA stage
---- Begin FA stage
FA_165:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(193), DATA_B => INT_SUM(194), DATA_C => INT_SUM(195), 
		SAVE => INT_SUM(196), CARRY => INT_CARRY(164)
	);
---- End FA stage
---- Begin FA stage
FA_166:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(154), DATA_B => INT_CARRY(155), DATA_C => INT_CARRY(156), 
		SAVE => INT_SUM(197), CARRY => INT_CARRY(165)
	);
---- End FA stage
---- Begin FA stage
FA_167:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(196), DATA_B => INT_SUM(197), DATA_C => INT_CARRY(157), 
		SAVE => INT_SUM(198), CARRY => INT_CARRY(166)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(199) <= INT_CARRY(158); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_168:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(198), DATA_B => INT_SUM(199), DATA_C => INT_CARRY(159), 
		SAVE => INT_SUM(200), CARRY => INT_CARRY(167)
	);
---- End FA stage
---- Begin HA stage
HA_31:HALF_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(200), DATA_B => INT_CARRY(160), 
		SAVE => SUM(33), CARRY => CARRY(33)
	);
---- End HA stage
-- End WT-branch 34

-- Begin WT-branch 35
---- Begin FA stage
FA_169:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(243), DATA_B => SUMMAND(244), DATA_C => SUMMAND(245), 
		SAVE => INT_SUM(201), CARRY => INT_CARRY(168)
	);
---- End FA stage
---- Begin FA stage
FA_170:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(246), DATA_B => SUMMAND(247), DATA_C => SUMMAND(248), 
		SAVE => INT_SUM(202), CARRY => INT_CARRY(169)
	);
---- End FA stage
---- Begin FA stage
FA_171:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(249), DATA_B => SUMMAND(250), DATA_C => SUMMAND(251), 
		SAVE => INT_SUM(203), CARRY => INT_CARRY(170)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(204) <= SUMMAND(252); -- At Level 1
---- End NO stage
---- Begin FA stage
FA_172:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(201), DATA_B => INT_SUM(202), DATA_C => INT_SUM(203), 
		SAVE => INT_SUM(205), CARRY => INT_CARRY(171)
	);
---- End FA stage
---- Begin FA stage
FA_173:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(204), DATA_B => INT_CARRY(161), DATA_C => INT_CARRY(162), 
		SAVE => INT_SUM(206), CARRY => INT_CARRY(172)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(207) <= INT_CARRY(163); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_174:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(205), DATA_B => INT_SUM(206), DATA_C => INT_SUM(207), 
		SAVE => INT_SUM(208), CARRY => INT_CARRY(173)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(209) <= INT_CARRY(164); -- At Level 3
---- End NO stage
---- Begin NO stage
INT_SUM(210) <= INT_CARRY(165); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_175:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(208), DATA_B => INT_SUM(209), DATA_C => INT_SUM(210), 
		SAVE => INT_SUM(211), CARRY => INT_CARRY(174)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(212) <= INT_CARRY(166); -- At Level 4
---- End NO stage
---- Begin FA stage
FA_176:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(211), DATA_B => INT_SUM(212), DATA_C => INT_CARRY(167), 
		SAVE => SUM(34), CARRY => CARRY(34)
	);
---- End FA stage
-- End WT-branch 35

-- Begin WT-branch 36
---- Begin FA stage
FA_177:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(253), DATA_B => SUMMAND(254), DATA_C => SUMMAND(255), 
		SAVE => INT_SUM(213), CARRY => INT_CARRY(175)
	);
---- End FA stage
---- Begin FA stage
FA_178:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(256), DATA_B => SUMMAND(257), DATA_C => SUMMAND(258), 
		SAVE => INT_SUM(214), CARRY => INT_CARRY(176)
	);
---- End FA stage
---- Begin FA stage
FA_179:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(259), DATA_B => SUMMAND(260), DATA_C => SUMMAND(261), 
		SAVE => INT_SUM(215), CARRY => INT_CARRY(177)
	);
---- End FA stage
---- Begin FA stage
FA_180:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(168), DATA_B => INT_CARRY(169), DATA_C => INT_CARRY(170), 
		SAVE => INT_SUM(216), CARRY => INT_CARRY(178)
	);
---- End FA stage
---- Begin FA stage
FA_181:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(213), DATA_B => INT_SUM(214), DATA_C => INT_SUM(215), 
		SAVE => INT_SUM(217), CARRY => INT_CARRY(179)
	);
---- End FA stage
---- Begin FA stage
FA_182:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(216), DATA_B => INT_CARRY(171), DATA_C => INT_CARRY(172), 
		SAVE => INT_SUM(218), CARRY => INT_CARRY(180)
	);
---- End FA stage
---- Begin FA stage
FA_183:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(217), DATA_B => INT_SUM(218), DATA_C => INT_CARRY(173), 
		SAVE => INT_SUM(219), CARRY => INT_CARRY(181)
	);
---- End FA stage
---- Begin HA stage
HA_32:HALF_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(219), DATA_B => INT_CARRY(174), 
		SAVE => SUM(35), CARRY => CARRY(35)
	);
---- End HA stage
-- End WT-branch 36

-- Begin WT-branch 37
---- Begin FA stage
FA_184:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(262), DATA_B => SUMMAND(263), DATA_C => SUMMAND(264), 
		SAVE => INT_SUM(220), CARRY => INT_CARRY(182)
	);
---- End FA stage
---- Begin FA stage
FA_185:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(265), DATA_B => SUMMAND(266), DATA_C => SUMMAND(267), 
		SAVE => INT_SUM(221), CARRY => INT_CARRY(183)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(222) <= SUMMAND(268); -- At Level 1
---- End NO stage
---- Begin NO stage
INT_SUM(223) <= SUMMAND(269); -- At Level 1
---- End NO stage
---- Begin FA stage
FA_186:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(220), DATA_B => INT_SUM(221), DATA_C => INT_SUM(222), 
		SAVE => INT_SUM(224), CARRY => INT_CARRY(184)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(225) <= INT_SUM(223); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_187:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(224), DATA_B => INT_SUM(225), DATA_C => INT_CARRY(175), 
		SAVE => INT_SUM(226), CARRY => INT_CARRY(185)
	);
---- End FA stage
---- Begin FA stage
FA_188:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_CARRY(176), DATA_B => INT_CARRY(177), DATA_C => INT_CARRY(178), 
		SAVE => INT_SUM(227), CARRY => INT_CARRY(186)
	);
---- End FA stage
---- Begin FA stage
FA_189:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(226), DATA_B => INT_SUM(227), DATA_C => INT_CARRY(179), 
		SAVE => INT_SUM(228), CARRY => INT_CARRY(187)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(229) <= INT_CARRY(180); -- At Level 4
---- End NO stage
---- Begin FA stage
FA_190:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(228), DATA_B => INT_SUM(229), DATA_C => INT_CARRY(181), 
		SAVE => SUM(36), CARRY => CARRY(36)
	);
---- End FA stage
-- End WT-branch 37

-- Begin WT-branch 38
---- Begin FA stage
FA_191:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(270), DATA_B => SUMMAND(271), DATA_C => SUMMAND(272), 
		SAVE => INT_SUM(230), CARRY => INT_CARRY(188)
	);
---- End FA stage
---- Begin FA stage
FA_192:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(273), DATA_B => SUMMAND(274), DATA_C => SUMMAND(275), 
		SAVE => INT_SUM(231), CARRY => INT_CARRY(189)
	);
---- End FA stage
---- Begin FA stage
FA_193:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(276), DATA_B => SUMMAND(277), DATA_C => INT_CARRY(182), 
		SAVE => INT_SUM(232), CARRY => INT_CARRY(190)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(233) <= INT_CARRY(183); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_194:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(230), DATA_B => INT_SUM(231), DATA_C => INT_SUM(232), 
		SAVE => INT_SUM(234), CARRY => INT_CARRY(191)
	);
---- End FA stage
---- Begin HA stage
HA_33:HALF_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(233), DATA_B => INT_CARRY(184), 
		SAVE => INT_SUM(235), CARRY => INT_CARRY(192)
	);
---- End HA stage
---- Begin FA stage
FA_195:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(234), DATA_B => INT_SUM(235), DATA_C => INT_CARRY(185), 
		SAVE => INT_SUM(236), CARRY => INT_CARRY(193)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(237) <= INT_CARRY(186); -- At Level 4
---- End NO stage
---- Begin FA stage
FA_196:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(236), DATA_B => INT_SUM(237), DATA_C => INT_CARRY(187), 
		SAVE => SUM(37), CARRY => CARRY(37)
	);
---- End FA stage
-- End WT-branch 38

-- Begin WT-branch 39
---- Begin FA stage
FA_197:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(278), DATA_B => SUMMAND(279), DATA_C => SUMMAND(280), 
		SAVE => INT_SUM(238), CARRY => INT_CARRY(194)
	);
---- End FA stage
---- Begin FA stage
FA_198:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(281), DATA_B => SUMMAND(282), DATA_C => SUMMAND(283), 
		SAVE => INT_SUM(239), CARRY => INT_CARRY(195)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(240) <= SUMMAND(284); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_199:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(238), DATA_B => INT_SUM(239), DATA_C => INT_SUM(240), 
		SAVE => INT_SUM(241), CARRY => INT_CARRY(196)
	);
---- End FA stage
---- Begin FA stage
FA_200:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_CARRY(188), DATA_B => INT_CARRY(189), DATA_C => INT_CARRY(190), 
		SAVE => INT_SUM(242), CARRY => INT_CARRY(197)
	);
---- End FA stage
---- Begin FA stage
FA_201:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(241), DATA_B => INT_SUM(242), DATA_C => INT_CARRY(191), 
		SAVE => INT_SUM(243), CARRY => INT_CARRY(198)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(244) <= INT_CARRY(192); -- At Level 4
---- End NO stage
---- Begin FA stage
FA_202:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(243), DATA_B => INT_SUM(244), DATA_C => INT_CARRY(193), 
		SAVE => SUM(38), CARRY => CARRY(38)
	);
---- End FA stage
-- End WT-branch 39

-- Begin WT-branch 40
---- Begin FA stage
FA_203:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(285), DATA_B => SUMMAND(286), DATA_C => SUMMAND(287), 
		SAVE => INT_SUM(245), CARRY => INT_CARRY(199)
	);
---- End FA stage
---- Begin FA stage
FA_204:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(288), DATA_B => SUMMAND(289), DATA_C => SUMMAND(290), 
		SAVE => INT_SUM(246), CARRY => INT_CARRY(200)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(247) <= SUMMAND(291); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_205:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(245), DATA_B => INT_SUM(246), DATA_C => INT_SUM(247), 
		SAVE => INT_SUM(248), CARRY => INT_CARRY(201)
	);
---- End FA stage
---- Begin HA stage
HA_34:HALF_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_CARRY(194), DATA_B => INT_CARRY(195), 
		SAVE => INT_SUM(249), CARRY => INT_CARRY(202)
	);
---- End HA stage
---- Begin FA stage
FA_206:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(248), DATA_B => INT_SUM(249), DATA_C => INT_CARRY(196), 
		SAVE => INT_SUM(250), CARRY => INT_CARRY(203)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(251) <= INT_CARRY(197); -- At Level 4
---- End NO stage
---- Begin FA stage
FA_207:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(250), DATA_B => INT_SUM(251), DATA_C => INT_CARRY(198), 
		SAVE => SUM(39), CARRY => CARRY(39)
	);
---- End FA stage
-- End WT-branch 40

-- Begin WT-branch 41
---- Begin FA stage
FA_208:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(292), DATA_B => SUMMAND(293), DATA_C => SUMMAND(294), 
		SAVE => INT_SUM(252), CARRY => INT_CARRY(204)
	);
---- End FA stage
---- Begin FA stage
FA_209:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(295), DATA_B => SUMMAND(296), DATA_C => SUMMAND(297), 
		SAVE => INT_SUM(253), CARRY => INT_CARRY(205)
	);
---- End FA stage
---- Begin FA stage
FA_210:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(252), DATA_B => INT_SUM(253), DATA_C => INT_CARRY(199), 
		SAVE => INT_SUM(254), CARRY => INT_CARRY(206)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(255) <= INT_CARRY(200); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_211:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(254), DATA_B => INT_SUM(255), DATA_C => INT_CARRY(201), 
		SAVE => INT_SUM(256), CARRY => INT_CARRY(207)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(257) <= INT_CARRY(202); -- At Level 4
---- End NO stage
---- Begin FA stage
FA_212:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(256), DATA_B => INT_SUM(257), DATA_C => INT_CARRY(203), 
		SAVE => SUM(40), CARRY => CARRY(40)
	);
---- End FA stage
-- End WT-branch 41

-- Begin WT-branch 42
---- Begin FA stage
FA_213:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(298), DATA_B => SUMMAND(299), DATA_C => SUMMAND(300), 
		SAVE => INT_SUM(258), CARRY => INT_CARRY(208)
	);
---- End FA stage
---- Begin FA stage
FA_214:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(301), DATA_B => SUMMAND(302), DATA_C => SUMMAND(303), 
		SAVE => INT_SUM(259), CARRY => INT_CARRY(209)
	);
---- End FA stage
---- Begin FA stage
FA_215:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(258), DATA_B => INT_SUM(259), DATA_C => INT_CARRY(204), 
		SAVE => INT_SUM(260), CARRY => INT_CARRY(210)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(261) <= INT_CARRY(205); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_216:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(260), DATA_B => INT_SUM(261), DATA_C => INT_CARRY(206), 
		SAVE => INT_SUM(262), CARRY => INT_CARRY(211)
	);
---- End FA stage
---- Begin HA stage
HA_35:HALF_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(262), DATA_B => INT_CARRY(207), 
		SAVE => SUM(41), CARRY => CARRY(41)
	);
---- End HA stage
-- End WT-branch 42

-- Begin WT-branch 43
---- Begin FA stage
FA_217:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(304), DATA_B => SUMMAND(305), DATA_C => SUMMAND(306), 
		SAVE => INT_SUM(263), CARRY => INT_CARRY(212)
	);
---- End FA stage
---- Begin HA stage
HA_36:HALF_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(307), DATA_B => SUMMAND(308), 
		SAVE => INT_SUM(264), CARRY => INT_CARRY(213)
	);
---- End HA stage
---- Begin FA stage
FA_218:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(263), DATA_B => INT_SUM(264), DATA_C => INT_CARRY(208), 
		SAVE => INT_SUM(265), CARRY => INT_CARRY(214)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(266) <= INT_CARRY(209); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_219:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(265), DATA_B => INT_SUM(266), DATA_C => INT_CARRY(210), 
		SAVE => INT_SUM(267), CARRY => INT_CARRY(215)
	);
---- End FA stage
---- Begin HA stage
HA_37:HALF_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(267), DATA_B => INT_CARRY(211), 
		SAVE => SUM(42), CARRY => CARRY(42)
	);
---- End HA stage
-- End WT-branch 43

-- Begin WT-branch 44
---- Begin FA stage
FA_220:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(309), DATA_B => SUMMAND(310), DATA_C => SUMMAND(311), 
		SAVE => INT_SUM(268), CARRY => INT_CARRY(216)
	);
---- End FA stage
---- Begin HA stage
HA_38:HALF_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(312), DATA_B => SUMMAND(313), 
		SAVE => INT_SUM(269), CARRY => INT_CARRY(217)
	);
---- End HA stage
---- Begin FA stage
FA_221:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(268), DATA_B => INT_SUM(269), DATA_C => INT_CARRY(212), 
		SAVE => INT_SUM(270), CARRY => INT_CARRY(218)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(271) <= INT_CARRY(213); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_222:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(270), DATA_B => INT_SUM(271), DATA_C => INT_CARRY(214), 
		SAVE => INT_SUM(272), CARRY => INT_CARRY(219)
	);
---- End FA stage
---- Begin HA stage
HA_39:HALF_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(272), DATA_B => INT_CARRY(215), 
		SAVE => SUM(43), CARRY => CARRY(43)
	);
---- End HA stage
-- End WT-branch 44

-- Begin WT-branch 45
---- Begin FA stage
FA_223:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => SUMMAND(314), DATA_B => SUMMAND(315), DATA_C => SUMMAND(316), 
		SAVE => INT_SUM(273), CARRY => INT_CARRY(220)
	);
---- End FA stage
---- Begin FA stage
FA_224:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => SUMMAND(317), DATA_B => INT_CARRY(216), DATA_C => INT_CARRY(217), 
		SAVE => INT_SUM(274), CARRY => INT_CARRY(221)
	);
---- End FA stage
---- Begin FA stage
FA_225:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(273), DATA_B => INT_SUM(274), DATA_C => INT_CARRY(218), 
		SAVE => INT_SUM(275), CARRY => INT_CARRY(222)
	);
---- End FA stage
---- Begin HA stage
HA_40:HALF_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(275), DATA_B => INT_CARRY(219), 
		SAVE => SUM(44), CARRY => CARRY(44)
	);
---- End HA stage
-- End WT-branch 45

-- Begin WT-branch 46
---- Begin FA stage
FA_226:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => SUMMAND(318), DATA_B => SUMMAND(319), DATA_C => SUMMAND(320), 
		SAVE => INT_SUM(276), CARRY => INT_CARRY(223)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(277) <= SUMMAND(321); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_227:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(276), DATA_B => INT_SUM(277), DATA_C => INT_CARRY(220), 
		SAVE => INT_SUM(278), CARRY => INT_CARRY(224)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(279) <= INT_CARRY(221); -- At Level 4
---- End NO stage
---- Begin FA stage
FA_228:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(278), DATA_B => INT_SUM(279), DATA_C => INT_CARRY(222), 
		SAVE => SUM(45), CARRY => CARRY(45)
	);
---- End FA stage
-- End WT-branch 46

-- Begin WT-branch 47
---- Begin FA stage
FA_229:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => SUMMAND(322), DATA_B => SUMMAND(323), DATA_C => SUMMAND(324), 
		SAVE => INT_SUM(280), CARRY => INT_CARRY(225)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(281) <= INT_SUM(280); -- At Level 4
---- End NO stage
---- Begin NO stage
INT_SUM(282) <= INT_CARRY(223); -- At Level 4
---- End NO stage
---- Begin FA stage
FA_230:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(281), DATA_B => INT_SUM(282), DATA_C => INT_CARRY(224), 
		SAVE => SUM(46), CARRY => CARRY(46)
	);
---- End FA stage
-- End WT-branch 47

-- Begin WT-branch 48
---- Begin FA stage
FA_231:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => SUMMAND(325), DATA_B => SUMMAND(326), DATA_C => SUMMAND(327), 
		SAVE => INT_SUM(283), CARRY => INT_CARRY(226)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(284) <= INT_CARRY(225); -- At Level 4
---- End NO stage
---- Begin HA stage
HA_41:HALF_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(283), DATA_B => INT_SUM(284), 
		SAVE => SUM(47), CARRY => CARRY(47)
	);
---- End HA stage
-- End WT-branch 48

-- Begin WT-branch 49
---- Begin NO stage
INT_SUM(285) <= SUMMAND(328); -- At Level 4
---- End NO stage
---- Begin NO stage
INT_SUM(286) <= SUMMAND(329); -- At Level 4
---- End NO stage
---- Begin FA stage
FA_232:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(285), DATA_B => INT_SUM(286), DATA_C => INT_CARRY(226), 
		SAVE => SUM(48), CARRY => CARRY(48)
	);
---- End FA stage
-- End WT-branch 49

-- Begin WT-branch 50
---- Begin HA stage
HA_42:HALF_ADDER -- At Level 5
	port map
	(
		DATA_A => SUMMAND(330), DATA_B => SUMMAND(331), 
		SAVE => SUM(49), CARRY => CARRY(49)
	);
---- End HA stage
-- End WT-branch 50

-- Begin WT-branch 51
---- Begin NO stage
SUM(50) <= SUMMAND(332); -- At Level 5
---- End NO stage
-- End WT-branch 51

end WALLACE;
------------------------------------------------------------
-- END: Architectures used with the Wallace-tree
------------------------------------------------------------


------------------------------------------------------------
-- START: Architectures used with the multiplier
------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.blocks.all;
entity MULTIPLIER_34_18 is
port
(
	MULTIPLICAND: in std_logic_vector(0 to 33);
	MULTIPLIER: in std_logic_vector(0 to 17);
	PHI: in std_logic;
	RESULT: out std_logic_vector(0 to 63)
);
end MULTIPLIER_34_18;
------------------------------------------------------------
-- End: Multiplier Entitiy
architecture MULTIPLIER of MULTIPLIER_34_18 is

signal PPBIT:std_logic_vector(0 to 332);
signal INT_CARRY: std_logic_vector(0 to 64);
signal INT_SUM: std_logic_vector(0 to 63);
signal LOGIC_ZERO: std_logic;

begin -- Architecture

LOGIC_ZERO <= '0';
B:BOOTHCODER_34_18
	port map
	(
		OPA(0 to 33) => MULTIPLICAND(0 to 33),
		OPB(0 to 17) => MULTIPLIER(0 to 17),
		SUMMAND(0 to 332) => PPBIT(0 to 332)
	);
W:WALLACE_34_18
	port map
	(
		SUMMAND(0 to 332) => PPBIT(0 to 332),
		CARRY(0 to 49) => INT_CARRY(1 to 50),
		SUM(0 to 50) => INT_SUM(0 to 50)
	);
INT_CARRY(0) <= LOGIC_ZERO;
INT_CARRY(51) <= LOGIC_ZERO;
INT_CARRY(52) <= LOGIC_ZERO;
INT_CARRY(53) <= LOGIC_ZERO;
INT_CARRY(54) <= LOGIC_ZERO;
INT_CARRY(55) <= LOGIC_ZERO;
INT_CARRY(56) <= LOGIC_ZERO;
INT_CARRY(57) <= LOGIC_ZERO;
INT_CARRY(58) <= LOGIC_ZERO;
INT_CARRY(59) <= LOGIC_ZERO;
INT_CARRY(60) <= LOGIC_ZERO;
INT_CARRY(61) <= LOGIC_ZERO;
INT_CARRY(62) <= LOGIC_ZERO;
INT_CARRY(63) <= LOGIC_ZERO;
INT_SUM(51) <= LOGIC_ZERO;
INT_SUM(52) <= LOGIC_ZERO;
INT_SUM(53) <= LOGIC_ZERO;
INT_SUM(54) <= LOGIC_ZERO;
INT_SUM(55) <= LOGIC_ZERO;
INT_SUM(56) <= LOGIC_ZERO;
INT_SUM(57) <= LOGIC_ZERO;
INT_SUM(58) <= LOGIC_ZERO;
INT_SUM(59) <= LOGIC_ZERO;
INT_SUM(60) <= LOGIC_ZERO;
INT_SUM(61) <= LOGIC_ZERO;
INT_SUM(62) <= LOGIC_ZERO;
INT_SUM(63) <= LOGIC_ZERO;
D:DBLCADDER_64_64
	port map
	(
		OPA(0 to 63) => INT_SUM(0 to 63),
		OPB(0 to 63) => INT_CARRY(0 to 63),
		CIN => LOGIC_ZERO,
		PHI => PHI,
		SUM(0 to 63) => RESULT(0 to 63)
	);
end MULTIPLIER;
------------------------------------------------------------
-- END: Architectures used with the multiplier
------------------------------------------------------------

--
-- Modgen multiplier created Fri Aug 16 16:29:15 2002
--
------------------------------------------------------------
-- START: Multiplier Entitiy
------------------------------------------------------------

------------------------------------------------------------
------------------------------------------------------------
-- START: Top entity
------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.blocks.all;
entity MUL_33_17 is
  port(X: in std_logic_vector(32 downto 0);
       Y: in std_logic_vector(16 downto 0);
       P: out std_logic_vector(49 downto 0));
end MUL_33_17;

library ieee;
use ieee.std_logic_1164.all;
architecture A of MUL_33_17 is
  signal A: std_logic_vector(0 to 33);
  signal B: std_logic_vector(0 to 17);
  signal Q: std_logic_vector(0 to 63);
  signal CLK: std_logic;
begin
  U1: MULTIPLIER_34_18 port map(A,B,CLK,Q);
  -- std_logic_vector reversals to incorporate decreasing vectors
  A(0) <= X(0);
  A(1) <= X(1);
  A(2) <= X(2);
  A(3) <= X(3);
  A(4) <= X(4);
  A(5) <= X(5);
  A(6) <= X(6);
  A(7) <= X(7);
  A(8) <= X(8);
  A(9) <= X(9);
  A(10) <= X(10);
  A(11) <= X(11);
  A(12) <= X(12);
  A(13) <= X(13);
  A(14) <= X(14);
  A(15) <= X(15);
  A(16) <= X(16);
  A(17) <= X(17);
  A(18) <= X(18);
  A(19) <= X(19);
  A(20) <= X(20);
  A(21) <= X(21);
  A(22) <= X(22);
  A(23) <= X(23);
  A(24) <= X(24);
  A(25) <= X(25);
  A(26) <= X(26);
  A(27) <= X(27);
  A(28) <= X(28);
  A(29) <= X(29);
  A(30) <= X(30);
  A(31) <= X(31);
  A(32) <= X(32);
  A(33) <= X(32);
  B(0) <= Y(0);
  B(1) <= Y(1);
  B(2) <= Y(2);
  B(3) <= Y(3);
  B(4) <= Y(4);
  B(5) <= Y(5);
  B(6) <= Y(6);
  B(7) <= Y(7);
  B(8) <= Y(8);
  B(9) <= Y(9);
  B(10) <= Y(10);
  B(11) <= Y(11);
  B(12) <= Y(12);
  B(13) <= Y(13);
  B(14) <= Y(14);
  B(15) <= Y(15);
  B(16) <= Y(16);
  B(17) <= Y(16);
  P(0) <= Q(0);
  P(1) <= Q(1);
  P(2) <= Q(2);
  P(3) <= Q(3);
  P(4) <= Q(4);
  P(5) <= Q(5);
  P(6) <= Q(6);
  P(7) <= Q(7);
  P(8) <= Q(8);
  P(9) <= Q(9);
  P(10) <= Q(10);
  P(11) <= Q(11);
  P(12) <= Q(12);
  P(13) <= Q(13);
  P(14) <= Q(14);
  P(15) <= Q(15);
  P(16) <= Q(16);
  P(17) <= Q(17);
  P(18) <= Q(18);
  P(19) <= Q(19);
  P(20) <= Q(20);
  P(21) <= Q(21);
  P(22) <= Q(22);
  P(23) <= Q(23);
  P(24) <= Q(24);
  P(25) <= Q(25);
  P(26) <= Q(26);
  P(27) <= Q(27);
  P(28) <= Q(28);
  P(29) <= Q(29);
  P(30) <= Q(30);
  P(31) <= Q(31);
  P(32) <= Q(32);
  P(33) <= Q(33);
  P(34) <= Q(34);
  P(35) <= Q(35);
  P(36) <= Q(36);
  P(37) <= Q(37);
  P(38) <= Q(38);
  P(39) <= Q(39);
  P(40) <= Q(40);
  P(41) <= Q(41);
  P(42) <= Q(42);
  P(43) <= Q(43);
  P(44) <= Q(44);
  P(45) <= Q(45);
  P(46) <= Q(46);
  P(47) <= Q(47);
  P(48) <= Q(48);
  P(49) <= Q(49);
end A;




library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.blocks.all;
entity BOOTHCODER_34_34 is
port
(
		OPA: in std_logic_vector(0 to 33);
		OPB: in std_logic_vector(0 to 33);
		SUMMAND: out std_logic_vector(0 to 628)
);
end BOOTHCODER_34_34;
architecture BOOTHCODER of BOOTHCODER_34_34 is

-- Internal signal in Booth structure

signal INV_MULTIPLICAND: std_logic_vector(0 to 33);
signal INT_MULTIPLIER: std_logic_vector(0 to 67);
signal LOGIC_ONE, LOGIC_ZERO: std_logic;
begin
LOGIC_ONE <= '1';
LOGIC_ZERO <= '0';
-- Begin decoder block 1
DEC_0:DECODER -- Decoder of multiplier operand
	port map
	(
		INA => LOGIC_ZERO,INB => OPB(0),INC => OPB(1),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3)
	);
-- End decoder block 1
-- Begin partial product 1
INV_MULTIPLICAND(0) <= NOT OPA(0);
PPL_0:PP_LOW
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(0)
	);
RGATE_0:R_GATE
	port map
	(
		INA => LOGIC_ZERO,INB => OPB(0),INC => OPB(1),
		PPBIT => SUMMAND(1)
	);
INV_MULTIPLICAND(1) <= NOT OPA(1);
PPM_0:PP_MIDDLE
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		INC => OPA(1),IND => INV_MULTIPLICAND(1),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(2)
	);
INV_MULTIPLICAND(2) <= NOT OPA(2);
PPM_1:PP_MIDDLE
	port map
	(
		INA => OPA(1),INB => INV_MULTIPLICAND(1),
		INC => OPA(2),IND => INV_MULTIPLICAND(2),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(3)
	);
INV_MULTIPLICAND(3) <= NOT OPA(3);
PPM_2:PP_MIDDLE
	port map
	(
		INA => OPA(2),INB => INV_MULTIPLICAND(2),
		INC => OPA(3),IND => INV_MULTIPLICAND(3),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(6)
	);
INV_MULTIPLICAND(4) <= NOT OPA(4);
PPM_3:PP_MIDDLE
	port map
	(
		INA => OPA(3),INB => INV_MULTIPLICAND(3),
		INC => OPA(4),IND => INV_MULTIPLICAND(4),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(8)
	);
INV_MULTIPLICAND(5) <= NOT OPA(5);
PPM_4:PP_MIDDLE
	port map
	(
		INA => OPA(4),INB => INV_MULTIPLICAND(4),
		INC => OPA(5),IND => INV_MULTIPLICAND(5),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(12)
	);
INV_MULTIPLICAND(6) <= NOT OPA(6);
PPM_5:PP_MIDDLE
	port map
	(
		INA => OPA(5),INB => INV_MULTIPLICAND(5),
		INC => OPA(6),IND => INV_MULTIPLICAND(6),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(15)
	);
INV_MULTIPLICAND(7) <= NOT OPA(7);
PPM_6:PP_MIDDLE
	port map
	(
		INA => OPA(6),INB => INV_MULTIPLICAND(6),
		INC => OPA(7),IND => INV_MULTIPLICAND(7),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(20)
	);
INV_MULTIPLICAND(8) <= NOT OPA(8);
PPM_7:PP_MIDDLE
	port map
	(
		INA => OPA(7),INB => INV_MULTIPLICAND(7),
		INC => OPA(8),IND => INV_MULTIPLICAND(8),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(24)
	);
INV_MULTIPLICAND(9) <= NOT OPA(9);
PPM_8:PP_MIDDLE
	port map
	(
		INA => OPA(8),INB => INV_MULTIPLICAND(8),
		INC => OPA(9),IND => INV_MULTIPLICAND(9),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(30)
	);
INV_MULTIPLICAND(10) <= NOT OPA(10);
PPM_9:PP_MIDDLE
	port map
	(
		INA => OPA(9),INB => INV_MULTIPLICAND(9),
		INC => OPA(10),IND => INV_MULTIPLICAND(10),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(35)
	);
INV_MULTIPLICAND(11) <= NOT OPA(11);
PPM_10:PP_MIDDLE
	port map
	(
		INA => OPA(10),INB => INV_MULTIPLICAND(10),
		INC => OPA(11),IND => INV_MULTIPLICAND(11),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(42)
	);
INV_MULTIPLICAND(12) <= NOT OPA(12);
PPM_11:PP_MIDDLE
	port map
	(
		INA => OPA(11),INB => INV_MULTIPLICAND(11),
		INC => OPA(12),IND => INV_MULTIPLICAND(12),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(48)
	);
INV_MULTIPLICAND(13) <= NOT OPA(13);
PPM_12:PP_MIDDLE
	port map
	(
		INA => OPA(12),INB => INV_MULTIPLICAND(12),
		INC => OPA(13),IND => INV_MULTIPLICAND(13),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(56)
	);
INV_MULTIPLICAND(14) <= NOT OPA(14);
PPM_13:PP_MIDDLE
	port map
	(
		INA => OPA(13),INB => INV_MULTIPLICAND(13),
		INC => OPA(14),IND => INV_MULTIPLICAND(14),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(63)
	);
INV_MULTIPLICAND(15) <= NOT OPA(15);
PPM_14:PP_MIDDLE
	port map
	(
		INA => OPA(14),INB => INV_MULTIPLICAND(14),
		INC => OPA(15),IND => INV_MULTIPLICAND(15),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(72)
	);
INV_MULTIPLICAND(16) <= NOT OPA(16);
PPM_15:PP_MIDDLE
	port map
	(
		INA => OPA(15),INB => INV_MULTIPLICAND(15),
		INC => OPA(16),IND => INV_MULTIPLICAND(16),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(80)
	);
INV_MULTIPLICAND(17) <= NOT OPA(17);
PPM_16:PP_MIDDLE
	port map
	(
		INA => OPA(16),INB => INV_MULTIPLICAND(16),
		INC => OPA(17),IND => INV_MULTIPLICAND(17),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(90)
	);
INV_MULTIPLICAND(18) <= NOT OPA(18);
PPM_17:PP_MIDDLE
	port map
	(
		INA => OPA(17),INB => INV_MULTIPLICAND(17),
		INC => OPA(18),IND => INV_MULTIPLICAND(18),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(99)
	);
INV_MULTIPLICAND(19) <= NOT OPA(19);
PPM_18:PP_MIDDLE
	port map
	(
		INA => OPA(18),INB => INV_MULTIPLICAND(18),
		INC => OPA(19),IND => INV_MULTIPLICAND(19),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(110)
	);
INV_MULTIPLICAND(20) <= NOT OPA(20);
PPM_19:PP_MIDDLE
	port map
	(
		INA => OPA(19),INB => INV_MULTIPLICAND(19),
		INC => OPA(20),IND => INV_MULTIPLICAND(20),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(120)
	);
INV_MULTIPLICAND(21) <= NOT OPA(21);
PPM_20:PP_MIDDLE
	port map
	(
		INA => OPA(20),INB => INV_MULTIPLICAND(20),
		INC => OPA(21),IND => INV_MULTIPLICAND(21),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(132)
	);
INV_MULTIPLICAND(22) <= NOT OPA(22);
PPM_21:PP_MIDDLE
	port map
	(
		INA => OPA(21),INB => INV_MULTIPLICAND(21),
		INC => OPA(22),IND => INV_MULTIPLICAND(22),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(143)
	);
INV_MULTIPLICAND(23) <= NOT OPA(23);
PPM_22:PP_MIDDLE
	port map
	(
		INA => OPA(22),INB => INV_MULTIPLICAND(22),
		INC => OPA(23),IND => INV_MULTIPLICAND(23),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(156)
	);
INV_MULTIPLICAND(24) <= NOT OPA(24);
PPM_23:PP_MIDDLE
	port map
	(
		INA => OPA(23),INB => INV_MULTIPLICAND(23),
		INC => OPA(24),IND => INV_MULTIPLICAND(24),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(168)
	);
INV_MULTIPLICAND(25) <= NOT OPA(25);
PPM_24:PP_MIDDLE
	port map
	(
		INA => OPA(24),INB => INV_MULTIPLICAND(24),
		INC => OPA(25),IND => INV_MULTIPLICAND(25),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(182)
	);
INV_MULTIPLICAND(26) <= NOT OPA(26);
PPM_25:PP_MIDDLE
	port map
	(
		INA => OPA(25),INB => INV_MULTIPLICAND(25),
		INC => OPA(26),IND => INV_MULTIPLICAND(26),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(195)
	);
INV_MULTIPLICAND(27) <= NOT OPA(27);
PPM_26:PP_MIDDLE
	port map
	(
		INA => OPA(26),INB => INV_MULTIPLICAND(26),
		INC => OPA(27),IND => INV_MULTIPLICAND(27),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(210)
	);
INV_MULTIPLICAND(28) <= NOT OPA(28);
PPM_27:PP_MIDDLE
	port map
	(
		INA => OPA(27),INB => INV_MULTIPLICAND(27),
		INC => OPA(28),IND => INV_MULTIPLICAND(28),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(224)
	);
INV_MULTIPLICAND(29) <= NOT OPA(29);
PPM_28:PP_MIDDLE
	port map
	(
		INA => OPA(28),INB => INV_MULTIPLICAND(28),
		INC => OPA(29),IND => INV_MULTIPLICAND(29),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(240)
	);
INV_MULTIPLICAND(30) <= NOT OPA(30);
PPM_29:PP_MIDDLE
	port map
	(
		INA => OPA(29),INB => INV_MULTIPLICAND(29),
		INC => OPA(30),IND => INV_MULTIPLICAND(30),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(255)
	);
INV_MULTIPLICAND(31) <= NOT OPA(31);
PPM_30:PP_MIDDLE
	port map
	(
		INA => OPA(30),INB => INV_MULTIPLICAND(30),
		INC => OPA(31),IND => INV_MULTIPLICAND(31),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(272)
	);
INV_MULTIPLICAND(32) <= NOT OPA(32);
PPM_31:PP_MIDDLE
	port map
	(
		INA => OPA(31),INB => INV_MULTIPLICAND(31),
		INC => OPA(32),IND => INV_MULTIPLICAND(32),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(288)
	);
INV_MULTIPLICAND(33) <= NOT OPA(33);
PPM_32:PP_MIDDLE
	port map
	(
		INA => OPA(32),INB => INV_MULTIPLICAND(32),
		INC => OPA(33),IND => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(306)
	);
PPH_0:PP_HIGH
	port map
	(
		INA => OPA(33),INB => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(0),TWONEG => INT_MULTIPLIER(1),ONEPOS => INT_MULTIPLIER(2),ONENEG => INT_MULTIPLIER(3),
		PPBIT => SUMMAND(323)
	);
SUMMAND(324) <= '1';
-- Begin partial product 1
-- Begin decoder block 2
DEC_1:DECODER -- Decoder of multiplier operand
	port map
	(
		INA => OPB(1),INB => OPB(2),INC => OPB(3),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7)
	);
-- End decoder block 2
-- Begin partial product 2
PPL_1:PP_LOW
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(4)
	);
RGATE_1:R_GATE
	port map
	(
		INA => OPB(1),INB => OPB(2),INC => OPB(3),
		PPBIT => SUMMAND(5)
	);
PPM_33:PP_MIDDLE
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		INC => OPA(1),IND => INV_MULTIPLICAND(1),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(7)
	);
PPM_34:PP_MIDDLE
	port map
	(
		INA => OPA(1),INB => INV_MULTIPLICAND(1),
		INC => OPA(2),IND => INV_MULTIPLICAND(2),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(9)
	);
PPM_35:PP_MIDDLE
	port map
	(
		INA => OPA(2),INB => INV_MULTIPLICAND(2),
		INC => OPA(3),IND => INV_MULTIPLICAND(3),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(13)
	);
PPM_36:PP_MIDDLE
	port map
	(
		INA => OPA(3),INB => INV_MULTIPLICAND(3),
		INC => OPA(4),IND => INV_MULTIPLICAND(4),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(16)
	);
PPM_37:PP_MIDDLE
	port map
	(
		INA => OPA(4),INB => INV_MULTIPLICAND(4),
		INC => OPA(5),IND => INV_MULTIPLICAND(5),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(21)
	);
PPM_38:PP_MIDDLE
	port map
	(
		INA => OPA(5),INB => INV_MULTIPLICAND(5),
		INC => OPA(6),IND => INV_MULTIPLICAND(6),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(25)
	);
PPM_39:PP_MIDDLE
	port map
	(
		INA => OPA(6),INB => INV_MULTIPLICAND(6),
		INC => OPA(7),IND => INV_MULTIPLICAND(7),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(31)
	);
PPM_40:PP_MIDDLE
	port map
	(
		INA => OPA(7),INB => INV_MULTIPLICAND(7),
		INC => OPA(8),IND => INV_MULTIPLICAND(8),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(36)
	);
PPM_41:PP_MIDDLE
	port map
	(
		INA => OPA(8),INB => INV_MULTIPLICAND(8),
		INC => OPA(9),IND => INV_MULTIPLICAND(9),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(43)
	);
PPM_42:PP_MIDDLE
	port map
	(
		INA => OPA(9),INB => INV_MULTIPLICAND(9),
		INC => OPA(10),IND => INV_MULTIPLICAND(10),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(49)
	);
PPM_43:PP_MIDDLE
	port map
	(
		INA => OPA(10),INB => INV_MULTIPLICAND(10),
		INC => OPA(11),IND => INV_MULTIPLICAND(11),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(57)
	);
PPM_44:PP_MIDDLE
	port map
	(
		INA => OPA(11),INB => INV_MULTIPLICAND(11),
		INC => OPA(12),IND => INV_MULTIPLICAND(12),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(64)
	);
PPM_45:PP_MIDDLE
	port map
	(
		INA => OPA(12),INB => INV_MULTIPLICAND(12),
		INC => OPA(13),IND => INV_MULTIPLICAND(13),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(73)
	);
PPM_46:PP_MIDDLE
	port map
	(
		INA => OPA(13),INB => INV_MULTIPLICAND(13),
		INC => OPA(14),IND => INV_MULTIPLICAND(14),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(81)
	);
PPM_47:PP_MIDDLE
	port map
	(
		INA => OPA(14),INB => INV_MULTIPLICAND(14),
		INC => OPA(15),IND => INV_MULTIPLICAND(15),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(91)
	);
PPM_48:PP_MIDDLE
	port map
	(
		INA => OPA(15),INB => INV_MULTIPLICAND(15),
		INC => OPA(16),IND => INV_MULTIPLICAND(16),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(100)
	);
PPM_49:PP_MIDDLE
	port map
	(
		INA => OPA(16),INB => INV_MULTIPLICAND(16),
		INC => OPA(17),IND => INV_MULTIPLICAND(17),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(111)
	);
PPM_50:PP_MIDDLE
	port map
	(
		INA => OPA(17),INB => INV_MULTIPLICAND(17),
		INC => OPA(18),IND => INV_MULTIPLICAND(18),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(121)
	);
PPM_51:PP_MIDDLE
	port map
	(
		INA => OPA(18),INB => INV_MULTIPLICAND(18),
		INC => OPA(19),IND => INV_MULTIPLICAND(19),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(133)
	);
PPM_52:PP_MIDDLE
	port map
	(
		INA => OPA(19),INB => INV_MULTIPLICAND(19),
		INC => OPA(20),IND => INV_MULTIPLICAND(20),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(144)
	);
PPM_53:PP_MIDDLE
	port map
	(
		INA => OPA(20),INB => INV_MULTIPLICAND(20),
		INC => OPA(21),IND => INV_MULTIPLICAND(21),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(157)
	);
PPM_54:PP_MIDDLE
	port map
	(
		INA => OPA(21),INB => INV_MULTIPLICAND(21),
		INC => OPA(22),IND => INV_MULTIPLICAND(22),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(169)
	);
PPM_55:PP_MIDDLE
	port map
	(
		INA => OPA(22),INB => INV_MULTIPLICAND(22),
		INC => OPA(23),IND => INV_MULTIPLICAND(23),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(183)
	);
PPM_56:PP_MIDDLE
	port map
	(
		INA => OPA(23),INB => INV_MULTIPLICAND(23),
		INC => OPA(24),IND => INV_MULTIPLICAND(24),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(196)
	);
PPM_57:PP_MIDDLE
	port map
	(
		INA => OPA(24),INB => INV_MULTIPLICAND(24),
		INC => OPA(25),IND => INV_MULTIPLICAND(25),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(211)
	);
PPM_58:PP_MIDDLE
	port map
	(
		INA => OPA(25),INB => INV_MULTIPLICAND(25),
		INC => OPA(26),IND => INV_MULTIPLICAND(26),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(225)
	);
PPM_59:PP_MIDDLE
	port map
	(
		INA => OPA(26),INB => INV_MULTIPLICAND(26),
		INC => OPA(27),IND => INV_MULTIPLICAND(27),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(241)
	);
PPM_60:PP_MIDDLE
	port map
	(
		INA => OPA(27),INB => INV_MULTIPLICAND(27),
		INC => OPA(28),IND => INV_MULTIPLICAND(28),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(256)
	);
PPM_61:PP_MIDDLE
	port map
	(
		INA => OPA(28),INB => INV_MULTIPLICAND(28),
		INC => OPA(29),IND => INV_MULTIPLICAND(29),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(273)
	);
PPM_62:PP_MIDDLE
	port map
	(
		INA => OPA(29),INB => INV_MULTIPLICAND(29),
		INC => OPA(30),IND => INV_MULTIPLICAND(30),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(289)
	);
PPM_63:PP_MIDDLE
	port map
	(
		INA => OPA(30),INB => INV_MULTIPLICAND(30),
		INC => OPA(31),IND => INV_MULTIPLICAND(31),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(307)
	);
PPM_64:PP_MIDDLE
	port map
	(
		INA => OPA(31),INB => INV_MULTIPLICAND(31),
		INC => OPA(32),IND => INV_MULTIPLICAND(32),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(325)
	);
PPM_65:PP_MIDDLE
	port map
	(
		INA => OPA(32),INB => INV_MULTIPLICAND(32),
		INC => OPA(33),IND => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(341)
	);
SUMMAND(342) <= LOGIC_ONE;
PPH_1:PP_HIGH
	port map
	(
		INA => OPA(33),INB => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(4),TWONEG => INT_MULTIPLIER(5),ONEPOS => INT_MULTIPLIER(6),ONENEG => INT_MULTIPLIER(7),
		PPBIT => SUMMAND(358)
	);
-- Begin partial product 2
-- Begin decoder block 3
DEC_2:DECODER -- Decoder of multiplier operand
	port map
	(
		INA => OPB(3),INB => OPB(4),INC => OPB(5),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11)
	);
-- End decoder block 3
-- Begin partial product 3
PPL_2:PP_LOW
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(10)
	);
RGATE_2:R_GATE
	port map
	(
		INA => OPB(3),INB => OPB(4),INC => OPB(5),
		PPBIT => SUMMAND(11)
	);
PPM_66:PP_MIDDLE
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		INC => OPA(1),IND => INV_MULTIPLICAND(1),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(14)
	);
PPM_67:PP_MIDDLE
	port map
	(
		INA => OPA(1),INB => INV_MULTIPLICAND(1),
		INC => OPA(2),IND => INV_MULTIPLICAND(2),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(17)
	);
PPM_68:PP_MIDDLE
	port map
	(
		INA => OPA(2),INB => INV_MULTIPLICAND(2),
		INC => OPA(3),IND => INV_MULTIPLICAND(3),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(22)
	);
PPM_69:PP_MIDDLE
	port map
	(
		INA => OPA(3),INB => INV_MULTIPLICAND(3),
		INC => OPA(4),IND => INV_MULTIPLICAND(4),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(26)
	);
PPM_70:PP_MIDDLE
	port map
	(
		INA => OPA(4),INB => INV_MULTIPLICAND(4),
		INC => OPA(5),IND => INV_MULTIPLICAND(5),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(32)
	);
PPM_71:PP_MIDDLE
	port map
	(
		INA => OPA(5),INB => INV_MULTIPLICAND(5),
		INC => OPA(6),IND => INV_MULTIPLICAND(6),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(37)
	);
PPM_72:PP_MIDDLE
	port map
	(
		INA => OPA(6),INB => INV_MULTIPLICAND(6),
		INC => OPA(7),IND => INV_MULTIPLICAND(7),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(44)
	);
PPM_73:PP_MIDDLE
	port map
	(
		INA => OPA(7),INB => INV_MULTIPLICAND(7),
		INC => OPA(8),IND => INV_MULTIPLICAND(8),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(50)
	);
PPM_74:PP_MIDDLE
	port map
	(
		INA => OPA(8),INB => INV_MULTIPLICAND(8),
		INC => OPA(9),IND => INV_MULTIPLICAND(9),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(58)
	);
PPM_75:PP_MIDDLE
	port map
	(
		INA => OPA(9),INB => INV_MULTIPLICAND(9),
		INC => OPA(10),IND => INV_MULTIPLICAND(10),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(65)
	);
PPM_76:PP_MIDDLE
	port map
	(
		INA => OPA(10),INB => INV_MULTIPLICAND(10),
		INC => OPA(11),IND => INV_MULTIPLICAND(11),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(74)
	);
PPM_77:PP_MIDDLE
	port map
	(
		INA => OPA(11),INB => INV_MULTIPLICAND(11),
		INC => OPA(12),IND => INV_MULTIPLICAND(12),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(82)
	);
PPM_78:PP_MIDDLE
	port map
	(
		INA => OPA(12),INB => INV_MULTIPLICAND(12),
		INC => OPA(13),IND => INV_MULTIPLICAND(13),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(92)
	);
PPM_79:PP_MIDDLE
	port map
	(
		INA => OPA(13),INB => INV_MULTIPLICAND(13),
		INC => OPA(14),IND => INV_MULTIPLICAND(14),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(101)
	);
PPM_80:PP_MIDDLE
	port map
	(
		INA => OPA(14),INB => INV_MULTIPLICAND(14),
		INC => OPA(15),IND => INV_MULTIPLICAND(15),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(112)
	);
PPM_81:PP_MIDDLE
	port map
	(
		INA => OPA(15),INB => INV_MULTIPLICAND(15),
		INC => OPA(16),IND => INV_MULTIPLICAND(16),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(122)
	);
PPM_82:PP_MIDDLE
	port map
	(
		INA => OPA(16),INB => INV_MULTIPLICAND(16),
		INC => OPA(17),IND => INV_MULTIPLICAND(17),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(134)
	);
PPM_83:PP_MIDDLE
	port map
	(
		INA => OPA(17),INB => INV_MULTIPLICAND(17),
		INC => OPA(18),IND => INV_MULTIPLICAND(18),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(145)
	);
PPM_84:PP_MIDDLE
	port map
	(
		INA => OPA(18),INB => INV_MULTIPLICAND(18),
		INC => OPA(19),IND => INV_MULTIPLICAND(19),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(158)
	);
PPM_85:PP_MIDDLE
	port map
	(
		INA => OPA(19),INB => INV_MULTIPLICAND(19),
		INC => OPA(20),IND => INV_MULTIPLICAND(20),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(170)
	);
PPM_86:PP_MIDDLE
	port map
	(
		INA => OPA(20),INB => INV_MULTIPLICAND(20),
		INC => OPA(21),IND => INV_MULTIPLICAND(21),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(184)
	);
PPM_87:PP_MIDDLE
	port map
	(
		INA => OPA(21),INB => INV_MULTIPLICAND(21),
		INC => OPA(22),IND => INV_MULTIPLICAND(22),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(197)
	);
PPM_88:PP_MIDDLE
	port map
	(
		INA => OPA(22),INB => INV_MULTIPLICAND(22),
		INC => OPA(23),IND => INV_MULTIPLICAND(23),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(212)
	);
PPM_89:PP_MIDDLE
	port map
	(
		INA => OPA(23),INB => INV_MULTIPLICAND(23),
		INC => OPA(24),IND => INV_MULTIPLICAND(24),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(226)
	);
PPM_90:PP_MIDDLE
	port map
	(
		INA => OPA(24),INB => INV_MULTIPLICAND(24),
		INC => OPA(25),IND => INV_MULTIPLICAND(25),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(242)
	);
PPM_91:PP_MIDDLE
	port map
	(
		INA => OPA(25),INB => INV_MULTIPLICAND(25),
		INC => OPA(26),IND => INV_MULTIPLICAND(26),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(257)
	);
PPM_92:PP_MIDDLE
	port map
	(
		INA => OPA(26),INB => INV_MULTIPLICAND(26),
		INC => OPA(27),IND => INV_MULTIPLICAND(27),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(274)
	);
PPM_93:PP_MIDDLE
	port map
	(
		INA => OPA(27),INB => INV_MULTIPLICAND(27),
		INC => OPA(28),IND => INV_MULTIPLICAND(28),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(290)
	);
PPM_94:PP_MIDDLE
	port map
	(
		INA => OPA(28),INB => INV_MULTIPLICAND(28),
		INC => OPA(29),IND => INV_MULTIPLICAND(29),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(308)
	);
PPM_95:PP_MIDDLE
	port map
	(
		INA => OPA(29),INB => INV_MULTIPLICAND(29),
		INC => OPA(30),IND => INV_MULTIPLICAND(30),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(326)
	);
PPM_96:PP_MIDDLE
	port map
	(
		INA => OPA(30),INB => INV_MULTIPLICAND(30),
		INC => OPA(31),IND => INV_MULTIPLICAND(31),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(343)
	);
PPM_97:PP_MIDDLE
	port map
	(
		INA => OPA(31),INB => INV_MULTIPLICAND(31),
		INC => OPA(32),IND => INV_MULTIPLICAND(32),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(359)
	);
PPM_98:PP_MIDDLE
	port map
	(
		INA => OPA(32),INB => INV_MULTIPLICAND(32),
		INC => OPA(33),IND => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(374)
	);
SUMMAND(375) <= LOGIC_ONE;
PPH_2:PP_HIGH
	port map
	(
		INA => OPA(33),INB => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(8),TWONEG => INT_MULTIPLIER(9),ONEPOS => INT_MULTIPLIER(10),ONENEG => INT_MULTIPLIER(11),
		PPBIT => SUMMAND(390)
	);
-- Begin partial product 3
-- Begin decoder block 4
DEC_3:DECODER -- Decoder of multiplier operand
	port map
	(
		INA => OPB(5),INB => OPB(6),INC => OPB(7),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15)
	);
-- End decoder block 4
-- Begin partial product 4
PPL_3:PP_LOW
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(18)
	);
RGATE_3:R_GATE
	port map
	(
		INA => OPB(5),INB => OPB(6),INC => OPB(7),
		PPBIT => SUMMAND(19)
	);
PPM_99:PP_MIDDLE
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		INC => OPA(1),IND => INV_MULTIPLICAND(1),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(23)
	);
PPM_100:PP_MIDDLE
	port map
	(
		INA => OPA(1),INB => INV_MULTIPLICAND(1),
		INC => OPA(2),IND => INV_MULTIPLICAND(2),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(27)
	);
PPM_101:PP_MIDDLE
	port map
	(
		INA => OPA(2),INB => INV_MULTIPLICAND(2),
		INC => OPA(3),IND => INV_MULTIPLICAND(3),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(33)
	);
PPM_102:PP_MIDDLE
	port map
	(
		INA => OPA(3),INB => INV_MULTIPLICAND(3),
		INC => OPA(4),IND => INV_MULTIPLICAND(4),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(38)
	);
PPM_103:PP_MIDDLE
	port map
	(
		INA => OPA(4),INB => INV_MULTIPLICAND(4),
		INC => OPA(5),IND => INV_MULTIPLICAND(5),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(45)
	);
PPM_104:PP_MIDDLE
	port map
	(
		INA => OPA(5),INB => INV_MULTIPLICAND(5),
		INC => OPA(6),IND => INV_MULTIPLICAND(6),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(51)
	);
PPM_105:PP_MIDDLE
	port map
	(
		INA => OPA(6),INB => INV_MULTIPLICAND(6),
		INC => OPA(7),IND => INV_MULTIPLICAND(7),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(59)
	);
PPM_106:PP_MIDDLE
	port map
	(
		INA => OPA(7),INB => INV_MULTIPLICAND(7),
		INC => OPA(8),IND => INV_MULTIPLICAND(8),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(66)
	);
PPM_107:PP_MIDDLE
	port map
	(
		INA => OPA(8),INB => INV_MULTIPLICAND(8),
		INC => OPA(9),IND => INV_MULTIPLICAND(9),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(75)
	);
PPM_108:PP_MIDDLE
	port map
	(
		INA => OPA(9),INB => INV_MULTIPLICAND(9),
		INC => OPA(10),IND => INV_MULTIPLICAND(10),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(83)
	);
PPM_109:PP_MIDDLE
	port map
	(
		INA => OPA(10),INB => INV_MULTIPLICAND(10),
		INC => OPA(11),IND => INV_MULTIPLICAND(11),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(93)
	);
PPM_110:PP_MIDDLE
	port map
	(
		INA => OPA(11),INB => INV_MULTIPLICAND(11),
		INC => OPA(12),IND => INV_MULTIPLICAND(12),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(102)
	);
PPM_111:PP_MIDDLE
	port map
	(
		INA => OPA(12),INB => INV_MULTIPLICAND(12),
		INC => OPA(13),IND => INV_MULTIPLICAND(13),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(113)
	);
PPM_112:PP_MIDDLE
	port map
	(
		INA => OPA(13),INB => INV_MULTIPLICAND(13),
		INC => OPA(14),IND => INV_MULTIPLICAND(14),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(123)
	);
PPM_113:PP_MIDDLE
	port map
	(
		INA => OPA(14),INB => INV_MULTIPLICAND(14),
		INC => OPA(15),IND => INV_MULTIPLICAND(15),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(135)
	);
PPM_114:PP_MIDDLE
	port map
	(
		INA => OPA(15),INB => INV_MULTIPLICAND(15),
		INC => OPA(16),IND => INV_MULTIPLICAND(16),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(146)
	);
PPM_115:PP_MIDDLE
	port map
	(
		INA => OPA(16),INB => INV_MULTIPLICAND(16),
		INC => OPA(17),IND => INV_MULTIPLICAND(17),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(159)
	);
PPM_116:PP_MIDDLE
	port map
	(
		INA => OPA(17),INB => INV_MULTIPLICAND(17),
		INC => OPA(18),IND => INV_MULTIPLICAND(18),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(171)
	);
PPM_117:PP_MIDDLE
	port map
	(
		INA => OPA(18),INB => INV_MULTIPLICAND(18),
		INC => OPA(19),IND => INV_MULTIPLICAND(19),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(185)
	);
PPM_118:PP_MIDDLE
	port map
	(
		INA => OPA(19),INB => INV_MULTIPLICAND(19),
		INC => OPA(20),IND => INV_MULTIPLICAND(20),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(198)
	);
PPM_119:PP_MIDDLE
	port map
	(
		INA => OPA(20),INB => INV_MULTIPLICAND(20),
		INC => OPA(21),IND => INV_MULTIPLICAND(21),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(213)
	);
PPM_120:PP_MIDDLE
	port map
	(
		INA => OPA(21),INB => INV_MULTIPLICAND(21),
		INC => OPA(22),IND => INV_MULTIPLICAND(22),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(227)
	);
PPM_121:PP_MIDDLE
	port map
	(
		INA => OPA(22),INB => INV_MULTIPLICAND(22),
		INC => OPA(23),IND => INV_MULTIPLICAND(23),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(243)
	);
PPM_122:PP_MIDDLE
	port map
	(
		INA => OPA(23),INB => INV_MULTIPLICAND(23),
		INC => OPA(24),IND => INV_MULTIPLICAND(24),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(258)
	);
PPM_123:PP_MIDDLE
	port map
	(
		INA => OPA(24),INB => INV_MULTIPLICAND(24),
		INC => OPA(25),IND => INV_MULTIPLICAND(25),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(275)
	);
PPM_124:PP_MIDDLE
	port map
	(
		INA => OPA(25),INB => INV_MULTIPLICAND(25),
		INC => OPA(26),IND => INV_MULTIPLICAND(26),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(291)
	);
PPM_125:PP_MIDDLE
	port map
	(
		INA => OPA(26),INB => INV_MULTIPLICAND(26),
		INC => OPA(27),IND => INV_MULTIPLICAND(27),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(309)
	);
PPM_126:PP_MIDDLE
	port map
	(
		INA => OPA(27),INB => INV_MULTIPLICAND(27),
		INC => OPA(28),IND => INV_MULTIPLICAND(28),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(327)
	);
PPM_127:PP_MIDDLE
	port map
	(
		INA => OPA(28),INB => INV_MULTIPLICAND(28),
		INC => OPA(29),IND => INV_MULTIPLICAND(29),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(344)
	);
PPM_128:PP_MIDDLE
	port map
	(
		INA => OPA(29),INB => INV_MULTIPLICAND(29),
		INC => OPA(30),IND => INV_MULTIPLICAND(30),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(360)
	);
PPM_129:PP_MIDDLE
	port map
	(
		INA => OPA(30),INB => INV_MULTIPLICAND(30),
		INC => OPA(31),IND => INV_MULTIPLICAND(31),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(376)
	);
PPM_130:PP_MIDDLE
	port map
	(
		INA => OPA(31),INB => INV_MULTIPLICAND(31),
		INC => OPA(32),IND => INV_MULTIPLICAND(32),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(391)
	);
PPM_131:PP_MIDDLE
	port map
	(
		INA => OPA(32),INB => INV_MULTIPLICAND(32),
		INC => OPA(33),IND => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(405)
	);
SUMMAND(406) <= LOGIC_ONE;
PPH_3:PP_HIGH
	port map
	(
		INA => OPA(33),INB => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(12),TWONEG => INT_MULTIPLIER(13),ONEPOS => INT_MULTIPLIER(14),ONENEG => INT_MULTIPLIER(15),
		PPBIT => SUMMAND(420)
	);
-- Begin partial product 4
-- Begin decoder block 5
DEC_4:DECODER -- Decoder of multiplier operand
	port map
	(
		INA => OPB(7),INB => OPB(8),INC => OPB(9),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19)
	);
-- End decoder block 5
-- Begin partial product 5
PPL_4:PP_LOW
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(28)
	);
RGATE_4:R_GATE
	port map
	(
		INA => OPB(7),INB => OPB(8),INC => OPB(9),
		PPBIT => SUMMAND(29)
	);
PPM_132:PP_MIDDLE
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		INC => OPA(1),IND => INV_MULTIPLICAND(1),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(34)
	);
PPM_133:PP_MIDDLE
	port map
	(
		INA => OPA(1),INB => INV_MULTIPLICAND(1),
		INC => OPA(2),IND => INV_MULTIPLICAND(2),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(39)
	);
PPM_134:PP_MIDDLE
	port map
	(
		INA => OPA(2),INB => INV_MULTIPLICAND(2),
		INC => OPA(3),IND => INV_MULTIPLICAND(3),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(46)
	);
PPM_135:PP_MIDDLE
	port map
	(
		INA => OPA(3),INB => INV_MULTIPLICAND(3),
		INC => OPA(4),IND => INV_MULTIPLICAND(4),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(52)
	);
PPM_136:PP_MIDDLE
	port map
	(
		INA => OPA(4),INB => INV_MULTIPLICAND(4),
		INC => OPA(5),IND => INV_MULTIPLICAND(5),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(60)
	);
PPM_137:PP_MIDDLE
	port map
	(
		INA => OPA(5),INB => INV_MULTIPLICAND(5),
		INC => OPA(6),IND => INV_MULTIPLICAND(6),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(67)
	);
PPM_138:PP_MIDDLE
	port map
	(
		INA => OPA(6),INB => INV_MULTIPLICAND(6),
		INC => OPA(7),IND => INV_MULTIPLICAND(7),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(76)
	);
PPM_139:PP_MIDDLE
	port map
	(
		INA => OPA(7),INB => INV_MULTIPLICAND(7),
		INC => OPA(8),IND => INV_MULTIPLICAND(8),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(84)
	);
PPM_140:PP_MIDDLE
	port map
	(
		INA => OPA(8),INB => INV_MULTIPLICAND(8),
		INC => OPA(9),IND => INV_MULTIPLICAND(9),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(94)
	);
PPM_141:PP_MIDDLE
	port map
	(
		INA => OPA(9),INB => INV_MULTIPLICAND(9),
		INC => OPA(10),IND => INV_MULTIPLICAND(10),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(103)
	);
PPM_142:PP_MIDDLE
	port map
	(
		INA => OPA(10),INB => INV_MULTIPLICAND(10),
		INC => OPA(11),IND => INV_MULTIPLICAND(11),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(114)
	);
PPM_143:PP_MIDDLE
	port map
	(
		INA => OPA(11),INB => INV_MULTIPLICAND(11),
		INC => OPA(12),IND => INV_MULTIPLICAND(12),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(124)
	);
PPM_144:PP_MIDDLE
	port map
	(
		INA => OPA(12),INB => INV_MULTIPLICAND(12),
		INC => OPA(13),IND => INV_MULTIPLICAND(13),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(136)
	);
PPM_145:PP_MIDDLE
	port map
	(
		INA => OPA(13),INB => INV_MULTIPLICAND(13),
		INC => OPA(14),IND => INV_MULTIPLICAND(14),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(147)
	);
PPM_146:PP_MIDDLE
	port map
	(
		INA => OPA(14),INB => INV_MULTIPLICAND(14),
		INC => OPA(15),IND => INV_MULTIPLICAND(15),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(160)
	);
PPM_147:PP_MIDDLE
	port map
	(
		INA => OPA(15),INB => INV_MULTIPLICAND(15),
		INC => OPA(16),IND => INV_MULTIPLICAND(16),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(172)
	);
PPM_148:PP_MIDDLE
	port map
	(
		INA => OPA(16),INB => INV_MULTIPLICAND(16),
		INC => OPA(17),IND => INV_MULTIPLICAND(17),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(186)
	);
PPM_149:PP_MIDDLE
	port map
	(
		INA => OPA(17),INB => INV_MULTIPLICAND(17),
		INC => OPA(18),IND => INV_MULTIPLICAND(18),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(199)
	);
PPM_150:PP_MIDDLE
	port map
	(
		INA => OPA(18),INB => INV_MULTIPLICAND(18),
		INC => OPA(19),IND => INV_MULTIPLICAND(19),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(214)
	);
PPM_151:PP_MIDDLE
	port map
	(
		INA => OPA(19),INB => INV_MULTIPLICAND(19),
		INC => OPA(20),IND => INV_MULTIPLICAND(20),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(228)
	);
PPM_152:PP_MIDDLE
	port map
	(
		INA => OPA(20),INB => INV_MULTIPLICAND(20),
		INC => OPA(21),IND => INV_MULTIPLICAND(21),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(244)
	);
PPM_153:PP_MIDDLE
	port map
	(
		INA => OPA(21),INB => INV_MULTIPLICAND(21),
		INC => OPA(22),IND => INV_MULTIPLICAND(22),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(259)
	);
PPM_154:PP_MIDDLE
	port map
	(
		INA => OPA(22),INB => INV_MULTIPLICAND(22),
		INC => OPA(23),IND => INV_MULTIPLICAND(23),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(276)
	);
PPM_155:PP_MIDDLE
	port map
	(
		INA => OPA(23),INB => INV_MULTIPLICAND(23),
		INC => OPA(24),IND => INV_MULTIPLICAND(24),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(292)
	);
PPM_156:PP_MIDDLE
	port map
	(
		INA => OPA(24),INB => INV_MULTIPLICAND(24),
		INC => OPA(25),IND => INV_MULTIPLICAND(25),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(310)
	);
PPM_157:PP_MIDDLE
	port map
	(
		INA => OPA(25),INB => INV_MULTIPLICAND(25),
		INC => OPA(26),IND => INV_MULTIPLICAND(26),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(328)
	);
PPM_158:PP_MIDDLE
	port map
	(
		INA => OPA(26),INB => INV_MULTIPLICAND(26),
		INC => OPA(27),IND => INV_MULTIPLICAND(27),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(345)
	);
PPM_159:PP_MIDDLE
	port map
	(
		INA => OPA(27),INB => INV_MULTIPLICAND(27),
		INC => OPA(28),IND => INV_MULTIPLICAND(28),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(361)
	);
PPM_160:PP_MIDDLE
	port map
	(
		INA => OPA(28),INB => INV_MULTIPLICAND(28),
		INC => OPA(29),IND => INV_MULTIPLICAND(29),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(377)
	);
PPM_161:PP_MIDDLE
	port map
	(
		INA => OPA(29),INB => INV_MULTIPLICAND(29),
		INC => OPA(30),IND => INV_MULTIPLICAND(30),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(392)
	);
PPM_162:PP_MIDDLE
	port map
	(
		INA => OPA(30),INB => INV_MULTIPLICAND(30),
		INC => OPA(31),IND => INV_MULTIPLICAND(31),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(407)
	);
PPM_163:PP_MIDDLE
	port map
	(
		INA => OPA(31),INB => INV_MULTIPLICAND(31),
		INC => OPA(32),IND => INV_MULTIPLICAND(32),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(421)
	);
PPM_164:PP_MIDDLE
	port map
	(
		INA => OPA(32),INB => INV_MULTIPLICAND(32),
		INC => OPA(33),IND => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(434)
	);
SUMMAND(435) <= LOGIC_ONE;
PPH_4:PP_HIGH
	port map
	(
		INA => OPA(33),INB => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(16),TWONEG => INT_MULTIPLIER(17),ONEPOS => INT_MULTIPLIER(18),ONENEG => INT_MULTIPLIER(19),
		PPBIT => SUMMAND(448)
	);
-- Begin partial product 5
-- Begin decoder block 6
DEC_5:DECODER -- Decoder of multiplier operand
	port map
	(
		INA => OPB(9),INB => OPB(10),INC => OPB(11),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23)
	);
-- End decoder block 6
-- Begin partial product 6
PPL_5:PP_LOW
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(40)
	);
RGATE_5:R_GATE
	port map
	(
		INA => OPB(9),INB => OPB(10),INC => OPB(11),
		PPBIT => SUMMAND(41)
	);
PPM_165:PP_MIDDLE
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		INC => OPA(1),IND => INV_MULTIPLICAND(1),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(47)
	);
PPM_166:PP_MIDDLE
	port map
	(
		INA => OPA(1),INB => INV_MULTIPLICAND(1),
		INC => OPA(2),IND => INV_MULTIPLICAND(2),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(53)
	);
PPM_167:PP_MIDDLE
	port map
	(
		INA => OPA(2),INB => INV_MULTIPLICAND(2),
		INC => OPA(3),IND => INV_MULTIPLICAND(3),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(61)
	);
PPM_168:PP_MIDDLE
	port map
	(
		INA => OPA(3),INB => INV_MULTIPLICAND(3),
		INC => OPA(4),IND => INV_MULTIPLICAND(4),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(68)
	);
PPM_169:PP_MIDDLE
	port map
	(
		INA => OPA(4),INB => INV_MULTIPLICAND(4),
		INC => OPA(5),IND => INV_MULTIPLICAND(5),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(77)
	);
PPM_170:PP_MIDDLE
	port map
	(
		INA => OPA(5),INB => INV_MULTIPLICAND(5),
		INC => OPA(6),IND => INV_MULTIPLICAND(6),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(85)
	);
PPM_171:PP_MIDDLE
	port map
	(
		INA => OPA(6),INB => INV_MULTIPLICAND(6),
		INC => OPA(7),IND => INV_MULTIPLICAND(7),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(95)
	);
PPM_172:PP_MIDDLE
	port map
	(
		INA => OPA(7),INB => INV_MULTIPLICAND(7),
		INC => OPA(8),IND => INV_MULTIPLICAND(8),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(104)
	);
PPM_173:PP_MIDDLE
	port map
	(
		INA => OPA(8),INB => INV_MULTIPLICAND(8),
		INC => OPA(9),IND => INV_MULTIPLICAND(9),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(115)
	);
PPM_174:PP_MIDDLE
	port map
	(
		INA => OPA(9),INB => INV_MULTIPLICAND(9),
		INC => OPA(10),IND => INV_MULTIPLICAND(10),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(125)
	);
PPM_175:PP_MIDDLE
	port map
	(
		INA => OPA(10),INB => INV_MULTIPLICAND(10),
		INC => OPA(11),IND => INV_MULTIPLICAND(11),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(137)
	);
PPM_176:PP_MIDDLE
	port map
	(
		INA => OPA(11),INB => INV_MULTIPLICAND(11),
		INC => OPA(12),IND => INV_MULTIPLICAND(12),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(148)
	);
PPM_177:PP_MIDDLE
	port map
	(
		INA => OPA(12),INB => INV_MULTIPLICAND(12),
		INC => OPA(13),IND => INV_MULTIPLICAND(13),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(161)
	);
PPM_178:PP_MIDDLE
	port map
	(
		INA => OPA(13),INB => INV_MULTIPLICAND(13),
		INC => OPA(14),IND => INV_MULTIPLICAND(14),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(173)
	);
PPM_179:PP_MIDDLE
	port map
	(
		INA => OPA(14),INB => INV_MULTIPLICAND(14),
		INC => OPA(15),IND => INV_MULTIPLICAND(15),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(187)
	);
PPM_180:PP_MIDDLE
	port map
	(
		INA => OPA(15),INB => INV_MULTIPLICAND(15),
		INC => OPA(16),IND => INV_MULTIPLICAND(16),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(200)
	);
PPM_181:PP_MIDDLE
	port map
	(
		INA => OPA(16),INB => INV_MULTIPLICAND(16),
		INC => OPA(17),IND => INV_MULTIPLICAND(17),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(215)
	);
PPM_182:PP_MIDDLE
	port map
	(
		INA => OPA(17),INB => INV_MULTIPLICAND(17),
		INC => OPA(18),IND => INV_MULTIPLICAND(18),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(229)
	);
PPM_183:PP_MIDDLE
	port map
	(
		INA => OPA(18),INB => INV_MULTIPLICAND(18),
		INC => OPA(19),IND => INV_MULTIPLICAND(19),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(245)
	);
PPM_184:PP_MIDDLE
	port map
	(
		INA => OPA(19),INB => INV_MULTIPLICAND(19),
		INC => OPA(20),IND => INV_MULTIPLICAND(20),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(260)
	);
PPM_185:PP_MIDDLE
	port map
	(
		INA => OPA(20),INB => INV_MULTIPLICAND(20),
		INC => OPA(21),IND => INV_MULTIPLICAND(21),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(277)
	);
PPM_186:PP_MIDDLE
	port map
	(
		INA => OPA(21),INB => INV_MULTIPLICAND(21),
		INC => OPA(22),IND => INV_MULTIPLICAND(22),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(293)
	);
PPM_187:PP_MIDDLE
	port map
	(
		INA => OPA(22),INB => INV_MULTIPLICAND(22),
		INC => OPA(23),IND => INV_MULTIPLICAND(23),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(311)
	);
PPM_188:PP_MIDDLE
	port map
	(
		INA => OPA(23),INB => INV_MULTIPLICAND(23),
		INC => OPA(24),IND => INV_MULTIPLICAND(24),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(329)
	);
PPM_189:PP_MIDDLE
	port map
	(
		INA => OPA(24),INB => INV_MULTIPLICAND(24),
		INC => OPA(25),IND => INV_MULTIPLICAND(25),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(346)
	);
PPM_190:PP_MIDDLE
	port map
	(
		INA => OPA(25),INB => INV_MULTIPLICAND(25),
		INC => OPA(26),IND => INV_MULTIPLICAND(26),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(362)
	);
PPM_191:PP_MIDDLE
	port map
	(
		INA => OPA(26),INB => INV_MULTIPLICAND(26),
		INC => OPA(27),IND => INV_MULTIPLICAND(27),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(378)
	);
PPM_192:PP_MIDDLE
	port map
	(
		INA => OPA(27),INB => INV_MULTIPLICAND(27),
		INC => OPA(28),IND => INV_MULTIPLICAND(28),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(393)
	);
PPM_193:PP_MIDDLE
	port map
	(
		INA => OPA(28),INB => INV_MULTIPLICAND(28),
		INC => OPA(29),IND => INV_MULTIPLICAND(29),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(408)
	);
PPM_194:PP_MIDDLE
	port map
	(
		INA => OPA(29),INB => INV_MULTIPLICAND(29),
		INC => OPA(30),IND => INV_MULTIPLICAND(30),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(422)
	);
PPM_195:PP_MIDDLE
	port map
	(
		INA => OPA(30),INB => INV_MULTIPLICAND(30),
		INC => OPA(31),IND => INV_MULTIPLICAND(31),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(436)
	);
PPM_196:PP_MIDDLE
	port map
	(
		INA => OPA(31),INB => INV_MULTIPLICAND(31),
		INC => OPA(32),IND => INV_MULTIPLICAND(32),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(449)
	);
PPM_197:PP_MIDDLE
	port map
	(
		INA => OPA(32),INB => INV_MULTIPLICAND(32),
		INC => OPA(33),IND => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(461)
	);
SUMMAND(462) <= LOGIC_ONE;
PPH_5:PP_HIGH
	port map
	(
		INA => OPA(33),INB => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(20),TWONEG => INT_MULTIPLIER(21),ONEPOS => INT_MULTIPLIER(22),ONENEG => INT_MULTIPLIER(23),
		PPBIT => SUMMAND(474)
	);
-- Begin partial product 6
-- Begin decoder block 7
DEC_6:DECODER -- Decoder of multiplier operand
	port map
	(
		INA => OPB(11),INB => OPB(12),INC => OPB(13),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27)
	);
-- End decoder block 7
-- Begin partial product 7
PPL_6:PP_LOW
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(54)
	);
RGATE_6:R_GATE
	port map
	(
		INA => OPB(11),INB => OPB(12),INC => OPB(13),
		PPBIT => SUMMAND(55)
	);
PPM_198:PP_MIDDLE
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		INC => OPA(1),IND => INV_MULTIPLICAND(1),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(62)
	);
PPM_199:PP_MIDDLE
	port map
	(
		INA => OPA(1),INB => INV_MULTIPLICAND(1),
		INC => OPA(2),IND => INV_MULTIPLICAND(2),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(69)
	);
PPM_200:PP_MIDDLE
	port map
	(
		INA => OPA(2),INB => INV_MULTIPLICAND(2),
		INC => OPA(3),IND => INV_MULTIPLICAND(3),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(78)
	);
PPM_201:PP_MIDDLE
	port map
	(
		INA => OPA(3),INB => INV_MULTIPLICAND(3),
		INC => OPA(4),IND => INV_MULTIPLICAND(4),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(86)
	);
PPM_202:PP_MIDDLE
	port map
	(
		INA => OPA(4),INB => INV_MULTIPLICAND(4),
		INC => OPA(5),IND => INV_MULTIPLICAND(5),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(96)
	);
PPM_203:PP_MIDDLE
	port map
	(
		INA => OPA(5),INB => INV_MULTIPLICAND(5),
		INC => OPA(6),IND => INV_MULTIPLICAND(6),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(105)
	);
PPM_204:PP_MIDDLE
	port map
	(
		INA => OPA(6),INB => INV_MULTIPLICAND(6),
		INC => OPA(7),IND => INV_MULTIPLICAND(7),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(116)
	);
PPM_205:PP_MIDDLE
	port map
	(
		INA => OPA(7),INB => INV_MULTIPLICAND(7),
		INC => OPA(8),IND => INV_MULTIPLICAND(8),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(126)
	);
PPM_206:PP_MIDDLE
	port map
	(
		INA => OPA(8),INB => INV_MULTIPLICAND(8),
		INC => OPA(9),IND => INV_MULTIPLICAND(9),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(138)
	);
PPM_207:PP_MIDDLE
	port map
	(
		INA => OPA(9),INB => INV_MULTIPLICAND(9),
		INC => OPA(10),IND => INV_MULTIPLICAND(10),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(149)
	);
PPM_208:PP_MIDDLE
	port map
	(
		INA => OPA(10),INB => INV_MULTIPLICAND(10),
		INC => OPA(11),IND => INV_MULTIPLICAND(11),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(162)
	);
PPM_209:PP_MIDDLE
	port map
	(
		INA => OPA(11),INB => INV_MULTIPLICAND(11),
		INC => OPA(12),IND => INV_MULTIPLICAND(12),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(174)
	);
PPM_210:PP_MIDDLE
	port map
	(
		INA => OPA(12),INB => INV_MULTIPLICAND(12),
		INC => OPA(13),IND => INV_MULTIPLICAND(13),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(188)
	);
PPM_211:PP_MIDDLE
	port map
	(
		INA => OPA(13),INB => INV_MULTIPLICAND(13),
		INC => OPA(14),IND => INV_MULTIPLICAND(14),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(201)
	);
PPM_212:PP_MIDDLE
	port map
	(
		INA => OPA(14),INB => INV_MULTIPLICAND(14),
		INC => OPA(15),IND => INV_MULTIPLICAND(15),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(216)
	);
PPM_213:PP_MIDDLE
	port map
	(
		INA => OPA(15),INB => INV_MULTIPLICAND(15),
		INC => OPA(16),IND => INV_MULTIPLICAND(16),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(230)
	);
PPM_214:PP_MIDDLE
	port map
	(
		INA => OPA(16),INB => INV_MULTIPLICAND(16),
		INC => OPA(17),IND => INV_MULTIPLICAND(17),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(246)
	);
PPM_215:PP_MIDDLE
	port map
	(
		INA => OPA(17),INB => INV_MULTIPLICAND(17),
		INC => OPA(18),IND => INV_MULTIPLICAND(18),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(261)
	);
PPM_216:PP_MIDDLE
	port map
	(
		INA => OPA(18),INB => INV_MULTIPLICAND(18),
		INC => OPA(19),IND => INV_MULTIPLICAND(19),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(278)
	);
PPM_217:PP_MIDDLE
	port map
	(
		INA => OPA(19),INB => INV_MULTIPLICAND(19),
		INC => OPA(20),IND => INV_MULTIPLICAND(20),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(294)
	);
PPM_218:PP_MIDDLE
	port map
	(
		INA => OPA(20),INB => INV_MULTIPLICAND(20),
		INC => OPA(21),IND => INV_MULTIPLICAND(21),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(312)
	);
PPM_219:PP_MIDDLE
	port map
	(
		INA => OPA(21),INB => INV_MULTIPLICAND(21),
		INC => OPA(22),IND => INV_MULTIPLICAND(22),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(330)
	);
PPM_220:PP_MIDDLE
	port map
	(
		INA => OPA(22),INB => INV_MULTIPLICAND(22),
		INC => OPA(23),IND => INV_MULTIPLICAND(23),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(347)
	);
PPM_221:PP_MIDDLE
	port map
	(
		INA => OPA(23),INB => INV_MULTIPLICAND(23),
		INC => OPA(24),IND => INV_MULTIPLICAND(24),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(363)
	);
PPM_222:PP_MIDDLE
	port map
	(
		INA => OPA(24),INB => INV_MULTIPLICAND(24),
		INC => OPA(25),IND => INV_MULTIPLICAND(25),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(379)
	);
PPM_223:PP_MIDDLE
	port map
	(
		INA => OPA(25),INB => INV_MULTIPLICAND(25),
		INC => OPA(26),IND => INV_MULTIPLICAND(26),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(394)
	);
PPM_224:PP_MIDDLE
	port map
	(
		INA => OPA(26),INB => INV_MULTIPLICAND(26),
		INC => OPA(27),IND => INV_MULTIPLICAND(27),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(409)
	);
PPM_225:PP_MIDDLE
	port map
	(
		INA => OPA(27),INB => INV_MULTIPLICAND(27),
		INC => OPA(28),IND => INV_MULTIPLICAND(28),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(423)
	);
PPM_226:PP_MIDDLE
	port map
	(
		INA => OPA(28),INB => INV_MULTIPLICAND(28),
		INC => OPA(29),IND => INV_MULTIPLICAND(29),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(437)
	);
PPM_227:PP_MIDDLE
	port map
	(
		INA => OPA(29),INB => INV_MULTIPLICAND(29),
		INC => OPA(30),IND => INV_MULTIPLICAND(30),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(450)
	);
PPM_228:PP_MIDDLE
	port map
	(
		INA => OPA(30),INB => INV_MULTIPLICAND(30),
		INC => OPA(31),IND => INV_MULTIPLICAND(31),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(463)
	);
PPM_229:PP_MIDDLE
	port map
	(
		INA => OPA(31),INB => INV_MULTIPLICAND(31),
		INC => OPA(32),IND => INV_MULTIPLICAND(32),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(475)
	);
PPM_230:PP_MIDDLE
	port map
	(
		INA => OPA(32),INB => INV_MULTIPLICAND(32),
		INC => OPA(33),IND => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(486)
	);
SUMMAND(487) <= LOGIC_ONE;
PPH_6:PP_HIGH
	port map
	(
		INA => OPA(33),INB => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(24),TWONEG => INT_MULTIPLIER(25),ONEPOS => INT_MULTIPLIER(26),ONENEG => INT_MULTIPLIER(27),
		PPBIT => SUMMAND(498)
	);
-- Begin partial product 7
-- Begin decoder block 8
DEC_7:DECODER -- Decoder of multiplier operand
	port map
	(
		INA => OPB(13),INB => OPB(14),INC => OPB(15),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31)
	);
-- End decoder block 8
-- Begin partial product 8
PPL_7:PP_LOW
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(70)
	);
RGATE_7:R_GATE
	port map
	(
		INA => OPB(13),INB => OPB(14),INC => OPB(15),
		PPBIT => SUMMAND(71)
	);
PPM_231:PP_MIDDLE
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		INC => OPA(1),IND => INV_MULTIPLICAND(1),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(79)
	);
PPM_232:PP_MIDDLE
	port map
	(
		INA => OPA(1),INB => INV_MULTIPLICAND(1),
		INC => OPA(2),IND => INV_MULTIPLICAND(2),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(87)
	);
PPM_233:PP_MIDDLE
	port map
	(
		INA => OPA(2),INB => INV_MULTIPLICAND(2),
		INC => OPA(3),IND => INV_MULTIPLICAND(3),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(97)
	);
PPM_234:PP_MIDDLE
	port map
	(
		INA => OPA(3),INB => INV_MULTIPLICAND(3),
		INC => OPA(4),IND => INV_MULTIPLICAND(4),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(106)
	);
PPM_235:PP_MIDDLE
	port map
	(
		INA => OPA(4),INB => INV_MULTIPLICAND(4),
		INC => OPA(5),IND => INV_MULTIPLICAND(5),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(117)
	);
PPM_236:PP_MIDDLE
	port map
	(
		INA => OPA(5),INB => INV_MULTIPLICAND(5),
		INC => OPA(6),IND => INV_MULTIPLICAND(6),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(127)
	);
PPM_237:PP_MIDDLE
	port map
	(
		INA => OPA(6),INB => INV_MULTIPLICAND(6),
		INC => OPA(7),IND => INV_MULTIPLICAND(7),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(139)
	);
PPM_238:PP_MIDDLE
	port map
	(
		INA => OPA(7),INB => INV_MULTIPLICAND(7),
		INC => OPA(8),IND => INV_MULTIPLICAND(8),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(150)
	);
PPM_239:PP_MIDDLE
	port map
	(
		INA => OPA(8),INB => INV_MULTIPLICAND(8),
		INC => OPA(9),IND => INV_MULTIPLICAND(9),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(163)
	);
PPM_240:PP_MIDDLE
	port map
	(
		INA => OPA(9),INB => INV_MULTIPLICAND(9),
		INC => OPA(10),IND => INV_MULTIPLICAND(10),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(175)
	);
PPM_241:PP_MIDDLE
	port map
	(
		INA => OPA(10),INB => INV_MULTIPLICAND(10),
		INC => OPA(11),IND => INV_MULTIPLICAND(11),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(189)
	);
PPM_242:PP_MIDDLE
	port map
	(
		INA => OPA(11),INB => INV_MULTIPLICAND(11),
		INC => OPA(12),IND => INV_MULTIPLICAND(12),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(202)
	);
PPM_243:PP_MIDDLE
	port map
	(
		INA => OPA(12),INB => INV_MULTIPLICAND(12),
		INC => OPA(13),IND => INV_MULTIPLICAND(13),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(217)
	);
PPM_244:PP_MIDDLE
	port map
	(
		INA => OPA(13),INB => INV_MULTIPLICAND(13),
		INC => OPA(14),IND => INV_MULTIPLICAND(14),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(231)
	);
PPM_245:PP_MIDDLE
	port map
	(
		INA => OPA(14),INB => INV_MULTIPLICAND(14),
		INC => OPA(15),IND => INV_MULTIPLICAND(15),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(247)
	);
PPM_246:PP_MIDDLE
	port map
	(
		INA => OPA(15),INB => INV_MULTIPLICAND(15),
		INC => OPA(16),IND => INV_MULTIPLICAND(16),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(262)
	);
PPM_247:PP_MIDDLE
	port map
	(
		INA => OPA(16),INB => INV_MULTIPLICAND(16),
		INC => OPA(17),IND => INV_MULTIPLICAND(17),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(279)
	);
PPM_248:PP_MIDDLE
	port map
	(
		INA => OPA(17),INB => INV_MULTIPLICAND(17),
		INC => OPA(18),IND => INV_MULTIPLICAND(18),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(295)
	);
PPM_249:PP_MIDDLE
	port map
	(
		INA => OPA(18),INB => INV_MULTIPLICAND(18),
		INC => OPA(19),IND => INV_MULTIPLICAND(19),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(313)
	);
PPM_250:PP_MIDDLE
	port map
	(
		INA => OPA(19),INB => INV_MULTIPLICAND(19),
		INC => OPA(20),IND => INV_MULTIPLICAND(20),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(331)
	);
PPM_251:PP_MIDDLE
	port map
	(
		INA => OPA(20),INB => INV_MULTIPLICAND(20),
		INC => OPA(21),IND => INV_MULTIPLICAND(21),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(348)
	);
PPM_252:PP_MIDDLE
	port map
	(
		INA => OPA(21),INB => INV_MULTIPLICAND(21),
		INC => OPA(22),IND => INV_MULTIPLICAND(22),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(364)
	);
PPM_253:PP_MIDDLE
	port map
	(
		INA => OPA(22),INB => INV_MULTIPLICAND(22),
		INC => OPA(23),IND => INV_MULTIPLICAND(23),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(380)
	);
PPM_254:PP_MIDDLE
	port map
	(
		INA => OPA(23),INB => INV_MULTIPLICAND(23),
		INC => OPA(24),IND => INV_MULTIPLICAND(24),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(395)
	);
PPM_255:PP_MIDDLE
	port map
	(
		INA => OPA(24),INB => INV_MULTIPLICAND(24),
		INC => OPA(25),IND => INV_MULTIPLICAND(25),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(410)
	);
PPM_256:PP_MIDDLE
	port map
	(
		INA => OPA(25),INB => INV_MULTIPLICAND(25),
		INC => OPA(26),IND => INV_MULTIPLICAND(26),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(424)
	);
PPM_257:PP_MIDDLE
	port map
	(
		INA => OPA(26),INB => INV_MULTIPLICAND(26),
		INC => OPA(27),IND => INV_MULTIPLICAND(27),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(438)
	);
PPM_258:PP_MIDDLE
	port map
	(
		INA => OPA(27),INB => INV_MULTIPLICAND(27),
		INC => OPA(28),IND => INV_MULTIPLICAND(28),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(451)
	);
PPM_259:PP_MIDDLE
	port map
	(
		INA => OPA(28),INB => INV_MULTIPLICAND(28),
		INC => OPA(29),IND => INV_MULTIPLICAND(29),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(464)
	);
PPM_260:PP_MIDDLE
	port map
	(
		INA => OPA(29),INB => INV_MULTIPLICAND(29),
		INC => OPA(30),IND => INV_MULTIPLICAND(30),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(476)
	);
PPM_261:PP_MIDDLE
	port map
	(
		INA => OPA(30),INB => INV_MULTIPLICAND(30),
		INC => OPA(31),IND => INV_MULTIPLICAND(31),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(488)
	);
PPM_262:PP_MIDDLE
	port map
	(
		INA => OPA(31),INB => INV_MULTIPLICAND(31),
		INC => OPA(32),IND => INV_MULTIPLICAND(32),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(499)
	);
PPM_263:PP_MIDDLE
	port map
	(
		INA => OPA(32),INB => INV_MULTIPLICAND(32),
		INC => OPA(33),IND => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(509)
	);
SUMMAND(510) <= LOGIC_ONE;
PPH_7:PP_HIGH
	port map
	(
		INA => OPA(33),INB => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(28),TWONEG => INT_MULTIPLIER(29),ONEPOS => INT_MULTIPLIER(30),ONENEG => INT_MULTIPLIER(31),
		PPBIT => SUMMAND(520)
	);
-- Begin partial product 8
-- Begin decoder block 9
DEC_8:DECODER -- Decoder of multiplier operand
	port map
	(
		INA => OPB(15),INB => OPB(16),INC => OPB(17),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35)
	);
-- End decoder block 9
-- Begin partial product 9
PPL_8:PP_LOW
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(88)
	);
RGATE_8:R_GATE
	port map
	(
		INA => OPB(15),INB => OPB(16),INC => OPB(17),
		PPBIT => SUMMAND(89)
	);
PPM_264:PP_MIDDLE
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		INC => OPA(1),IND => INV_MULTIPLICAND(1),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(98)
	);
PPM_265:PP_MIDDLE
	port map
	(
		INA => OPA(1),INB => INV_MULTIPLICAND(1),
		INC => OPA(2),IND => INV_MULTIPLICAND(2),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(107)
	);
PPM_266:PP_MIDDLE
	port map
	(
		INA => OPA(2),INB => INV_MULTIPLICAND(2),
		INC => OPA(3),IND => INV_MULTIPLICAND(3),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(118)
	);
PPM_267:PP_MIDDLE
	port map
	(
		INA => OPA(3),INB => INV_MULTIPLICAND(3),
		INC => OPA(4),IND => INV_MULTIPLICAND(4),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(128)
	);
PPM_268:PP_MIDDLE
	port map
	(
		INA => OPA(4),INB => INV_MULTIPLICAND(4),
		INC => OPA(5),IND => INV_MULTIPLICAND(5),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(140)
	);
PPM_269:PP_MIDDLE
	port map
	(
		INA => OPA(5),INB => INV_MULTIPLICAND(5),
		INC => OPA(6),IND => INV_MULTIPLICAND(6),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(151)
	);
PPM_270:PP_MIDDLE
	port map
	(
		INA => OPA(6),INB => INV_MULTIPLICAND(6),
		INC => OPA(7),IND => INV_MULTIPLICAND(7),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(164)
	);
PPM_271:PP_MIDDLE
	port map
	(
		INA => OPA(7),INB => INV_MULTIPLICAND(7),
		INC => OPA(8),IND => INV_MULTIPLICAND(8),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(176)
	);
PPM_272:PP_MIDDLE
	port map
	(
		INA => OPA(8),INB => INV_MULTIPLICAND(8),
		INC => OPA(9),IND => INV_MULTIPLICAND(9),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(190)
	);
PPM_273:PP_MIDDLE
	port map
	(
		INA => OPA(9),INB => INV_MULTIPLICAND(9),
		INC => OPA(10),IND => INV_MULTIPLICAND(10),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(203)
	);
PPM_274:PP_MIDDLE
	port map
	(
		INA => OPA(10),INB => INV_MULTIPLICAND(10),
		INC => OPA(11),IND => INV_MULTIPLICAND(11),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(218)
	);
PPM_275:PP_MIDDLE
	port map
	(
		INA => OPA(11),INB => INV_MULTIPLICAND(11),
		INC => OPA(12),IND => INV_MULTIPLICAND(12),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(232)
	);
PPM_276:PP_MIDDLE
	port map
	(
		INA => OPA(12),INB => INV_MULTIPLICAND(12),
		INC => OPA(13),IND => INV_MULTIPLICAND(13),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(248)
	);
PPM_277:PP_MIDDLE
	port map
	(
		INA => OPA(13),INB => INV_MULTIPLICAND(13),
		INC => OPA(14),IND => INV_MULTIPLICAND(14),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(263)
	);
PPM_278:PP_MIDDLE
	port map
	(
		INA => OPA(14),INB => INV_MULTIPLICAND(14),
		INC => OPA(15),IND => INV_MULTIPLICAND(15),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(280)
	);
PPM_279:PP_MIDDLE
	port map
	(
		INA => OPA(15),INB => INV_MULTIPLICAND(15),
		INC => OPA(16),IND => INV_MULTIPLICAND(16),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(296)
	);
PPM_280:PP_MIDDLE
	port map
	(
		INA => OPA(16),INB => INV_MULTIPLICAND(16),
		INC => OPA(17),IND => INV_MULTIPLICAND(17),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(314)
	);
PPM_281:PP_MIDDLE
	port map
	(
		INA => OPA(17),INB => INV_MULTIPLICAND(17),
		INC => OPA(18),IND => INV_MULTIPLICAND(18),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(332)
	);
PPM_282:PP_MIDDLE
	port map
	(
		INA => OPA(18),INB => INV_MULTIPLICAND(18),
		INC => OPA(19),IND => INV_MULTIPLICAND(19),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(349)
	);
PPM_283:PP_MIDDLE
	port map
	(
		INA => OPA(19),INB => INV_MULTIPLICAND(19),
		INC => OPA(20),IND => INV_MULTIPLICAND(20),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(365)
	);
PPM_284:PP_MIDDLE
	port map
	(
		INA => OPA(20),INB => INV_MULTIPLICAND(20),
		INC => OPA(21),IND => INV_MULTIPLICAND(21),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(381)
	);
PPM_285:PP_MIDDLE
	port map
	(
		INA => OPA(21),INB => INV_MULTIPLICAND(21),
		INC => OPA(22),IND => INV_MULTIPLICAND(22),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(396)
	);
PPM_286:PP_MIDDLE
	port map
	(
		INA => OPA(22),INB => INV_MULTIPLICAND(22),
		INC => OPA(23),IND => INV_MULTIPLICAND(23),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(411)
	);
PPM_287:PP_MIDDLE
	port map
	(
		INA => OPA(23),INB => INV_MULTIPLICAND(23),
		INC => OPA(24),IND => INV_MULTIPLICAND(24),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(425)
	);
PPM_288:PP_MIDDLE
	port map
	(
		INA => OPA(24),INB => INV_MULTIPLICAND(24),
		INC => OPA(25),IND => INV_MULTIPLICAND(25),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(439)
	);
PPM_289:PP_MIDDLE
	port map
	(
		INA => OPA(25),INB => INV_MULTIPLICAND(25),
		INC => OPA(26),IND => INV_MULTIPLICAND(26),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(452)
	);
PPM_290:PP_MIDDLE
	port map
	(
		INA => OPA(26),INB => INV_MULTIPLICAND(26),
		INC => OPA(27),IND => INV_MULTIPLICAND(27),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(465)
	);
PPM_291:PP_MIDDLE
	port map
	(
		INA => OPA(27),INB => INV_MULTIPLICAND(27),
		INC => OPA(28),IND => INV_MULTIPLICAND(28),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(477)
	);
PPM_292:PP_MIDDLE
	port map
	(
		INA => OPA(28),INB => INV_MULTIPLICAND(28),
		INC => OPA(29),IND => INV_MULTIPLICAND(29),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(489)
	);
PPM_293:PP_MIDDLE
	port map
	(
		INA => OPA(29),INB => INV_MULTIPLICAND(29),
		INC => OPA(30),IND => INV_MULTIPLICAND(30),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(500)
	);
PPM_294:PP_MIDDLE
	port map
	(
		INA => OPA(30),INB => INV_MULTIPLICAND(30),
		INC => OPA(31),IND => INV_MULTIPLICAND(31),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(511)
	);
PPM_295:PP_MIDDLE
	port map
	(
		INA => OPA(31),INB => INV_MULTIPLICAND(31),
		INC => OPA(32),IND => INV_MULTIPLICAND(32),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(521)
	);
PPM_296:PP_MIDDLE
	port map
	(
		INA => OPA(32),INB => INV_MULTIPLICAND(32),
		INC => OPA(33),IND => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(530)
	);
SUMMAND(531) <= LOGIC_ONE;
PPH_8:PP_HIGH
	port map
	(
		INA => OPA(33),INB => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(32),TWONEG => INT_MULTIPLIER(33),ONEPOS => INT_MULTIPLIER(34),ONENEG => INT_MULTIPLIER(35),
		PPBIT => SUMMAND(540)
	);
-- Begin partial product 9
-- Begin decoder block 10
DEC_9:DECODER -- Decoder of multiplier operand
	port map
	(
		INA => OPB(17),INB => OPB(18),INC => OPB(19),
		TWOPOS => INT_MULTIPLIER(36),TWONEG => INT_MULTIPLIER(37),ONEPOS => INT_MULTIPLIER(38),ONENEG => INT_MULTIPLIER(39)
	);
-- End decoder block 10
-- Begin partial product 10
PPL_9:PP_LOW
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		TWONEG => INT_MULTIPLIER(37),ONEPOS => INT_MULTIPLIER(38),ONENEG => INT_MULTIPLIER(39),
		PPBIT => SUMMAND(108)
	);
RGATE_9:R_GATE
	port map
	(
		INA => OPB(17),INB => OPB(18),INC => OPB(19),
		PPBIT => SUMMAND(109)
	);
PPM_297:PP_MIDDLE
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		INC => OPA(1),IND => INV_MULTIPLICAND(1),
		TWOPOS => INT_MULTIPLIER(36),TWONEG => INT_MULTIPLIER(37),ONEPOS => INT_MULTIPLIER(38),ONENEG => INT_MULTIPLIER(39),
		PPBIT => SUMMAND(119)
	);
PPM_298:PP_MIDDLE
	port map
	(
		INA => OPA(1),INB => INV_MULTIPLICAND(1),
		INC => OPA(2),IND => INV_MULTIPLICAND(2),
		TWOPOS => INT_MULTIPLIER(36),TWONEG => INT_MULTIPLIER(37),ONEPOS => INT_MULTIPLIER(38),ONENEG => INT_MULTIPLIER(39),
		PPBIT => SUMMAND(129)
	);
PPM_299:PP_MIDDLE
	port map
	(
		INA => OPA(2),INB => INV_MULTIPLICAND(2),
		INC => OPA(3),IND => INV_MULTIPLICAND(3),
		TWOPOS => INT_MULTIPLIER(36),TWONEG => INT_MULTIPLIER(37),ONEPOS => INT_MULTIPLIER(38),ONENEG => INT_MULTIPLIER(39),
		PPBIT => SUMMAND(141)
	);
PPM_300:PP_MIDDLE
	port map
	(
		INA => OPA(3),INB => INV_MULTIPLICAND(3),
		INC => OPA(4),IND => INV_MULTIPLICAND(4),
		TWOPOS => INT_MULTIPLIER(36),TWONEG => INT_MULTIPLIER(37),ONEPOS => INT_MULTIPLIER(38),ONENEG => INT_MULTIPLIER(39),
		PPBIT => SUMMAND(152)
	);
PPM_301:PP_MIDDLE
	port map
	(
		INA => OPA(4),INB => INV_MULTIPLICAND(4),
		INC => OPA(5),IND => INV_MULTIPLICAND(5),
		TWOPOS => INT_MULTIPLIER(36),TWONEG => INT_MULTIPLIER(37),ONEPOS => INT_MULTIPLIER(38),ONENEG => INT_MULTIPLIER(39),
		PPBIT => SUMMAND(165)
	);
PPM_302:PP_MIDDLE
	port map
	(
		INA => OPA(5),INB => INV_MULTIPLICAND(5),
		INC => OPA(6),IND => INV_MULTIPLICAND(6),
		TWOPOS => INT_MULTIPLIER(36),TWONEG => INT_MULTIPLIER(37),ONEPOS => INT_MULTIPLIER(38),ONENEG => INT_MULTIPLIER(39),
		PPBIT => SUMMAND(177)
	);
PPM_303:PP_MIDDLE
	port map
	(
		INA => OPA(6),INB => INV_MULTIPLICAND(6),
		INC => OPA(7),IND => INV_MULTIPLICAND(7),
		TWOPOS => INT_MULTIPLIER(36),TWONEG => INT_MULTIPLIER(37),ONEPOS => INT_MULTIPLIER(38),ONENEG => INT_MULTIPLIER(39),
		PPBIT => SUMMAND(191)
	);
PPM_304:PP_MIDDLE
	port map
	(
		INA => OPA(7),INB => INV_MULTIPLICAND(7),
		INC => OPA(8),IND => INV_MULTIPLICAND(8),
		TWOPOS => INT_MULTIPLIER(36),TWONEG => INT_MULTIPLIER(37),ONEPOS => INT_MULTIPLIER(38),ONENEG => INT_MULTIPLIER(39),
		PPBIT => SUMMAND(204)
	);
PPM_305:PP_MIDDLE
	port map
	(
		INA => OPA(8),INB => INV_MULTIPLICAND(8),
		INC => OPA(9),IND => INV_MULTIPLICAND(9),
		TWOPOS => INT_MULTIPLIER(36),TWONEG => INT_MULTIPLIER(37),ONEPOS => INT_MULTIPLIER(38),ONENEG => INT_MULTIPLIER(39),
		PPBIT => SUMMAND(219)
	);
PPM_306:PP_MIDDLE
	port map
	(
		INA => OPA(9),INB => INV_MULTIPLICAND(9),
		INC => OPA(10),IND => INV_MULTIPLICAND(10),
		TWOPOS => INT_MULTIPLIER(36),TWONEG => INT_MULTIPLIER(37),ONEPOS => INT_MULTIPLIER(38),ONENEG => INT_MULTIPLIER(39),
		PPBIT => SUMMAND(233)
	);
PPM_307:PP_MIDDLE
	port map
	(
		INA => OPA(10),INB => INV_MULTIPLICAND(10),
		INC => OPA(11),IND => INV_MULTIPLICAND(11),
		TWOPOS => INT_MULTIPLIER(36),TWONEG => INT_MULTIPLIER(37),ONEPOS => INT_MULTIPLIER(38),ONENEG => INT_MULTIPLIER(39),
		PPBIT => SUMMAND(249)
	);
PPM_308:PP_MIDDLE
	port map
	(
		INA => OPA(11),INB => INV_MULTIPLICAND(11),
		INC => OPA(12),IND => INV_MULTIPLICAND(12),
		TWOPOS => INT_MULTIPLIER(36),TWONEG => INT_MULTIPLIER(37),ONEPOS => INT_MULTIPLIER(38),ONENEG => INT_MULTIPLIER(39),
		PPBIT => SUMMAND(264)
	);
PPM_309:PP_MIDDLE
	port map
	(
		INA => OPA(12),INB => INV_MULTIPLICAND(12),
		INC => OPA(13),IND => INV_MULTIPLICAND(13),
		TWOPOS => INT_MULTIPLIER(36),TWONEG => INT_MULTIPLIER(37),ONEPOS => INT_MULTIPLIER(38),ONENEG => INT_MULTIPLIER(39),
		PPBIT => SUMMAND(281)
	);
PPM_310:PP_MIDDLE
	port map
	(
		INA => OPA(13),INB => INV_MULTIPLICAND(13),
		INC => OPA(14),IND => INV_MULTIPLICAND(14),
		TWOPOS => INT_MULTIPLIER(36),TWONEG => INT_MULTIPLIER(37),ONEPOS => INT_MULTIPLIER(38),ONENEG => INT_MULTIPLIER(39),
		PPBIT => SUMMAND(297)
	);
PPM_311:PP_MIDDLE
	port map
	(
		INA => OPA(14),INB => INV_MULTIPLICAND(14),
		INC => OPA(15),IND => INV_MULTIPLICAND(15),
		TWOPOS => INT_MULTIPLIER(36),TWONEG => INT_MULTIPLIER(37),ONEPOS => INT_MULTIPLIER(38),ONENEG => INT_MULTIPLIER(39),
		PPBIT => SUMMAND(315)
	);
PPM_312:PP_MIDDLE
	port map
	(
		INA => OPA(15),INB => INV_MULTIPLICAND(15),
		INC => OPA(16),IND => INV_MULTIPLICAND(16),
		TWOPOS => INT_MULTIPLIER(36),TWONEG => INT_MULTIPLIER(37),ONEPOS => INT_MULTIPLIER(38),ONENEG => INT_MULTIPLIER(39),
		PPBIT => SUMMAND(333)
	);
PPM_313:PP_MIDDLE
	port map
	(
		INA => OPA(16),INB => INV_MULTIPLICAND(16),
		INC => OPA(17),IND => INV_MULTIPLICAND(17),
		TWOPOS => INT_MULTIPLIER(36),TWONEG => INT_MULTIPLIER(37),ONEPOS => INT_MULTIPLIER(38),ONENEG => INT_MULTIPLIER(39),
		PPBIT => SUMMAND(350)
	);
PPM_314:PP_MIDDLE
	port map
	(
		INA => OPA(17),INB => INV_MULTIPLICAND(17),
		INC => OPA(18),IND => INV_MULTIPLICAND(18),
		TWOPOS => INT_MULTIPLIER(36),TWONEG => INT_MULTIPLIER(37),ONEPOS => INT_MULTIPLIER(38),ONENEG => INT_MULTIPLIER(39),
		PPBIT => SUMMAND(366)
	);
PPM_315:PP_MIDDLE
	port map
	(
		INA => OPA(18),INB => INV_MULTIPLICAND(18),
		INC => OPA(19),IND => INV_MULTIPLICAND(19),
		TWOPOS => INT_MULTIPLIER(36),TWONEG => INT_MULTIPLIER(37),ONEPOS => INT_MULTIPLIER(38),ONENEG => INT_MULTIPLIER(39),
		PPBIT => SUMMAND(382)
	);
PPM_316:PP_MIDDLE
	port map
	(
		INA => OPA(19),INB => INV_MULTIPLICAND(19),
		INC => OPA(20),IND => INV_MULTIPLICAND(20),
		TWOPOS => INT_MULTIPLIER(36),TWONEG => INT_MULTIPLIER(37),ONEPOS => INT_MULTIPLIER(38),ONENEG => INT_MULTIPLIER(39),
		PPBIT => SUMMAND(397)
	);
PPM_317:PP_MIDDLE
	port map
	(
		INA => OPA(20),INB => INV_MULTIPLICAND(20),
		INC => OPA(21),IND => INV_MULTIPLICAND(21),
		TWOPOS => INT_MULTIPLIER(36),TWONEG => INT_MULTIPLIER(37),ONEPOS => INT_MULTIPLIER(38),ONENEG => INT_MULTIPLIER(39),
		PPBIT => SUMMAND(412)
	);
PPM_318:PP_MIDDLE
	port map
	(
		INA => OPA(21),INB => INV_MULTIPLICAND(21),
		INC => OPA(22),IND => INV_MULTIPLICAND(22),
		TWOPOS => INT_MULTIPLIER(36),TWONEG => INT_MULTIPLIER(37),ONEPOS => INT_MULTIPLIER(38),ONENEG => INT_MULTIPLIER(39),
		PPBIT => SUMMAND(426)
	);
PPM_319:PP_MIDDLE
	port map
	(
		INA => OPA(22),INB => INV_MULTIPLICAND(22),
		INC => OPA(23),IND => INV_MULTIPLICAND(23),
		TWOPOS => INT_MULTIPLIER(36),TWONEG => INT_MULTIPLIER(37),ONEPOS => INT_MULTIPLIER(38),ONENEG => INT_MULTIPLIER(39),
		PPBIT => SUMMAND(440)
	);
PPM_320:PP_MIDDLE
	port map
	(
		INA => OPA(23),INB => INV_MULTIPLICAND(23),
		INC => OPA(24),IND => INV_MULTIPLICAND(24),
		TWOPOS => INT_MULTIPLIER(36),TWONEG => INT_MULTIPLIER(37),ONEPOS => INT_MULTIPLIER(38),ONENEG => INT_MULTIPLIER(39),
		PPBIT => SUMMAND(453)
	);
PPM_321:PP_MIDDLE
	port map
	(
		INA => OPA(24),INB => INV_MULTIPLICAND(24),
		INC => OPA(25),IND => INV_MULTIPLICAND(25),
		TWOPOS => INT_MULTIPLIER(36),TWONEG => INT_MULTIPLIER(37),ONEPOS => INT_MULTIPLIER(38),ONENEG => INT_MULTIPLIER(39),
		PPBIT => SUMMAND(466)
	);
PPM_322:PP_MIDDLE
	port map
	(
		INA => OPA(25),INB => INV_MULTIPLICAND(25),
		INC => OPA(26),IND => INV_MULTIPLICAND(26),
		TWOPOS => INT_MULTIPLIER(36),TWONEG => INT_MULTIPLIER(37),ONEPOS => INT_MULTIPLIER(38),ONENEG => INT_MULTIPLIER(39),
		PPBIT => SUMMAND(478)
	);
PPM_323:PP_MIDDLE
	port map
	(
		INA => OPA(26),INB => INV_MULTIPLICAND(26),
		INC => OPA(27),IND => INV_MULTIPLICAND(27),
		TWOPOS => INT_MULTIPLIER(36),TWONEG => INT_MULTIPLIER(37),ONEPOS => INT_MULTIPLIER(38),ONENEG => INT_MULTIPLIER(39),
		PPBIT => SUMMAND(490)
	);
PPM_324:PP_MIDDLE
	port map
	(
		INA => OPA(27),INB => INV_MULTIPLICAND(27),
		INC => OPA(28),IND => INV_MULTIPLICAND(28),
		TWOPOS => INT_MULTIPLIER(36),TWONEG => INT_MULTIPLIER(37),ONEPOS => INT_MULTIPLIER(38),ONENEG => INT_MULTIPLIER(39),
		PPBIT => SUMMAND(501)
	);
PPM_325:PP_MIDDLE
	port map
	(
		INA => OPA(28),INB => INV_MULTIPLICAND(28),
		INC => OPA(29),IND => INV_MULTIPLICAND(29),
		TWOPOS => INT_MULTIPLIER(36),TWONEG => INT_MULTIPLIER(37),ONEPOS => INT_MULTIPLIER(38),ONENEG => INT_MULTIPLIER(39),
		PPBIT => SUMMAND(512)
	);
PPM_326:PP_MIDDLE
	port map
	(
		INA => OPA(29),INB => INV_MULTIPLICAND(29),
		INC => OPA(30),IND => INV_MULTIPLICAND(30),
		TWOPOS => INT_MULTIPLIER(36),TWONEG => INT_MULTIPLIER(37),ONEPOS => INT_MULTIPLIER(38),ONENEG => INT_MULTIPLIER(39),
		PPBIT => SUMMAND(522)
	);
PPM_327:PP_MIDDLE
	port map
	(
		INA => OPA(30),INB => INV_MULTIPLICAND(30),
		INC => OPA(31),IND => INV_MULTIPLICAND(31),
		TWOPOS => INT_MULTIPLIER(36),TWONEG => INT_MULTIPLIER(37),ONEPOS => INT_MULTIPLIER(38),ONENEG => INT_MULTIPLIER(39),
		PPBIT => SUMMAND(532)
	);
PPM_328:PP_MIDDLE
	port map
	(
		INA => OPA(31),INB => INV_MULTIPLICAND(31),
		INC => OPA(32),IND => INV_MULTIPLICAND(32),
		TWOPOS => INT_MULTIPLIER(36),TWONEG => INT_MULTIPLIER(37),ONEPOS => INT_MULTIPLIER(38),ONENEG => INT_MULTIPLIER(39),
		PPBIT => SUMMAND(541)
	);
PPM_329:PP_MIDDLE
	port map
	(
		INA => OPA(32),INB => INV_MULTIPLICAND(32),
		INC => OPA(33),IND => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(36),TWONEG => INT_MULTIPLIER(37),ONEPOS => INT_MULTIPLIER(38),ONENEG => INT_MULTIPLIER(39),
		PPBIT => SUMMAND(549)
	);
SUMMAND(550) <= LOGIC_ONE;
PPH_9:PP_HIGH
	port map
	(
		INA => OPA(33),INB => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(36),TWONEG => INT_MULTIPLIER(37),ONEPOS => INT_MULTIPLIER(38),ONENEG => INT_MULTIPLIER(39),
		PPBIT => SUMMAND(558)
	);
-- Begin partial product 10
-- Begin decoder block 11
DEC_10:DECODER -- Decoder of multiplier operand
	port map
	(
		INA => OPB(19),INB => OPB(20),INC => OPB(21),
		TWOPOS => INT_MULTIPLIER(40),TWONEG => INT_MULTIPLIER(41),ONEPOS => INT_MULTIPLIER(42),ONENEG => INT_MULTIPLIER(43)
	);
-- End decoder block 11
-- Begin partial product 11
PPL_10:PP_LOW
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		TWONEG => INT_MULTIPLIER(41),ONEPOS => INT_MULTIPLIER(42),ONENEG => INT_MULTIPLIER(43),
		PPBIT => SUMMAND(130)
	);
RGATE_10:R_GATE
	port map
	(
		INA => OPB(19),INB => OPB(20),INC => OPB(21),
		PPBIT => SUMMAND(131)
	);
PPM_330:PP_MIDDLE
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		INC => OPA(1),IND => INV_MULTIPLICAND(1),
		TWOPOS => INT_MULTIPLIER(40),TWONEG => INT_MULTIPLIER(41),ONEPOS => INT_MULTIPLIER(42),ONENEG => INT_MULTIPLIER(43),
		PPBIT => SUMMAND(142)
	);
PPM_331:PP_MIDDLE
	port map
	(
		INA => OPA(1),INB => INV_MULTIPLICAND(1),
		INC => OPA(2),IND => INV_MULTIPLICAND(2),
		TWOPOS => INT_MULTIPLIER(40),TWONEG => INT_MULTIPLIER(41),ONEPOS => INT_MULTIPLIER(42),ONENEG => INT_MULTIPLIER(43),
		PPBIT => SUMMAND(153)
	);
PPM_332:PP_MIDDLE
	port map
	(
		INA => OPA(2),INB => INV_MULTIPLICAND(2),
		INC => OPA(3),IND => INV_MULTIPLICAND(3),
		TWOPOS => INT_MULTIPLIER(40),TWONEG => INT_MULTIPLIER(41),ONEPOS => INT_MULTIPLIER(42),ONENEG => INT_MULTIPLIER(43),
		PPBIT => SUMMAND(166)
	);
PPM_333:PP_MIDDLE
	port map
	(
		INA => OPA(3),INB => INV_MULTIPLICAND(3),
		INC => OPA(4),IND => INV_MULTIPLICAND(4),
		TWOPOS => INT_MULTIPLIER(40),TWONEG => INT_MULTIPLIER(41),ONEPOS => INT_MULTIPLIER(42),ONENEG => INT_MULTIPLIER(43),
		PPBIT => SUMMAND(178)
	);
PPM_334:PP_MIDDLE
	port map
	(
		INA => OPA(4),INB => INV_MULTIPLICAND(4),
		INC => OPA(5),IND => INV_MULTIPLICAND(5),
		TWOPOS => INT_MULTIPLIER(40),TWONEG => INT_MULTIPLIER(41),ONEPOS => INT_MULTIPLIER(42),ONENEG => INT_MULTIPLIER(43),
		PPBIT => SUMMAND(192)
	);
PPM_335:PP_MIDDLE
	port map
	(
		INA => OPA(5),INB => INV_MULTIPLICAND(5),
		INC => OPA(6),IND => INV_MULTIPLICAND(6),
		TWOPOS => INT_MULTIPLIER(40),TWONEG => INT_MULTIPLIER(41),ONEPOS => INT_MULTIPLIER(42),ONENEG => INT_MULTIPLIER(43),
		PPBIT => SUMMAND(205)
	);
PPM_336:PP_MIDDLE
	port map
	(
		INA => OPA(6),INB => INV_MULTIPLICAND(6),
		INC => OPA(7),IND => INV_MULTIPLICAND(7),
		TWOPOS => INT_MULTIPLIER(40),TWONEG => INT_MULTIPLIER(41),ONEPOS => INT_MULTIPLIER(42),ONENEG => INT_MULTIPLIER(43),
		PPBIT => SUMMAND(220)
	);
PPM_337:PP_MIDDLE
	port map
	(
		INA => OPA(7),INB => INV_MULTIPLICAND(7),
		INC => OPA(8),IND => INV_MULTIPLICAND(8),
		TWOPOS => INT_MULTIPLIER(40),TWONEG => INT_MULTIPLIER(41),ONEPOS => INT_MULTIPLIER(42),ONENEG => INT_MULTIPLIER(43),
		PPBIT => SUMMAND(234)
	);
PPM_338:PP_MIDDLE
	port map
	(
		INA => OPA(8),INB => INV_MULTIPLICAND(8),
		INC => OPA(9),IND => INV_MULTIPLICAND(9),
		TWOPOS => INT_MULTIPLIER(40),TWONEG => INT_MULTIPLIER(41),ONEPOS => INT_MULTIPLIER(42),ONENEG => INT_MULTIPLIER(43),
		PPBIT => SUMMAND(250)
	);
PPM_339:PP_MIDDLE
	port map
	(
		INA => OPA(9),INB => INV_MULTIPLICAND(9),
		INC => OPA(10),IND => INV_MULTIPLICAND(10),
		TWOPOS => INT_MULTIPLIER(40),TWONEG => INT_MULTIPLIER(41),ONEPOS => INT_MULTIPLIER(42),ONENEG => INT_MULTIPLIER(43),
		PPBIT => SUMMAND(265)
	);
PPM_340:PP_MIDDLE
	port map
	(
		INA => OPA(10),INB => INV_MULTIPLICAND(10),
		INC => OPA(11),IND => INV_MULTIPLICAND(11),
		TWOPOS => INT_MULTIPLIER(40),TWONEG => INT_MULTIPLIER(41),ONEPOS => INT_MULTIPLIER(42),ONENEG => INT_MULTIPLIER(43),
		PPBIT => SUMMAND(282)
	);
PPM_341:PP_MIDDLE
	port map
	(
		INA => OPA(11),INB => INV_MULTIPLICAND(11),
		INC => OPA(12),IND => INV_MULTIPLICAND(12),
		TWOPOS => INT_MULTIPLIER(40),TWONEG => INT_MULTIPLIER(41),ONEPOS => INT_MULTIPLIER(42),ONENEG => INT_MULTIPLIER(43),
		PPBIT => SUMMAND(298)
	);
PPM_342:PP_MIDDLE
	port map
	(
		INA => OPA(12),INB => INV_MULTIPLICAND(12),
		INC => OPA(13),IND => INV_MULTIPLICAND(13),
		TWOPOS => INT_MULTIPLIER(40),TWONEG => INT_MULTIPLIER(41),ONEPOS => INT_MULTIPLIER(42),ONENEG => INT_MULTIPLIER(43),
		PPBIT => SUMMAND(316)
	);
PPM_343:PP_MIDDLE
	port map
	(
		INA => OPA(13),INB => INV_MULTIPLICAND(13),
		INC => OPA(14),IND => INV_MULTIPLICAND(14),
		TWOPOS => INT_MULTIPLIER(40),TWONEG => INT_MULTIPLIER(41),ONEPOS => INT_MULTIPLIER(42),ONENEG => INT_MULTIPLIER(43),
		PPBIT => SUMMAND(334)
	);
PPM_344:PP_MIDDLE
	port map
	(
		INA => OPA(14),INB => INV_MULTIPLICAND(14),
		INC => OPA(15),IND => INV_MULTIPLICAND(15),
		TWOPOS => INT_MULTIPLIER(40),TWONEG => INT_MULTIPLIER(41),ONEPOS => INT_MULTIPLIER(42),ONENEG => INT_MULTIPLIER(43),
		PPBIT => SUMMAND(351)
	);
PPM_345:PP_MIDDLE
	port map
	(
		INA => OPA(15),INB => INV_MULTIPLICAND(15),
		INC => OPA(16),IND => INV_MULTIPLICAND(16),
		TWOPOS => INT_MULTIPLIER(40),TWONEG => INT_MULTIPLIER(41),ONEPOS => INT_MULTIPLIER(42),ONENEG => INT_MULTIPLIER(43),
		PPBIT => SUMMAND(367)
	);
PPM_346:PP_MIDDLE
	port map
	(
		INA => OPA(16),INB => INV_MULTIPLICAND(16),
		INC => OPA(17),IND => INV_MULTIPLICAND(17),
		TWOPOS => INT_MULTIPLIER(40),TWONEG => INT_MULTIPLIER(41),ONEPOS => INT_MULTIPLIER(42),ONENEG => INT_MULTIPLIER(43),
		PPBIT => SUMMAND(383)
	);
PPM_347:PP_MIDDLE
	port map
	(
		INA => OPA(17),INB => INV_MULTIPLICAND(17),
		INC => OPA(18),IND => INV_MULTIPLICAND(18),
		TWOPOS => INT_MULTIPLIER(40),TWONEG => INT_MULTIPLIER(41),ONEPOS => INT_MULTIPLIER(42),ONENEG => INT_MULTIPLIER(43),
		PPBIT => SUMMAND(398)
	);
PPM_348:PP_MIDDLE
	port map
	(
		INA => OPA(18),INB => INV_MULTIPLICAND(18),
		INC => OPA(19),IND => INV_MULTIPLICAND(19),
		TWOPOS => INT_MULTIPLIER(40),TWONEG => INT_MULTIPLIER(41),ONEPOS => INT_MULTIPLIER(42),ONENEG => INT_MULTIPLIER(43),
		PPBIT => SUMMAND(413)
	);
PPM_349:PP_MIDDLE
	port map
	(
		INA => OPA(19),INB => INV_MULTIPLICAND(19),
		INC => OPA(20),IND => INV_MULTIPLICAND(20),
		TWOPOS => INT_MULTIPLIER(40),TWONEG => INT_MULTIPLIER(41),ONEPOS => INT_MULTIPLIER(42),ONENEG => INT_MULTIPLIER(43),
		PPBIT => SUMMAND(427)
	);
PPM_350:PP_MIDDLE
	port map
	(
		INA => OPA(20),INB => INV_MULTIPLICAND(20),
		INC => OPA(21),IND => INV_MULTIPLICAND(21),
		TWOPOS => INT_MULTIPLIER(40),TWONEG => INT_MULTIPLIER(41),ONEPOS => INT_MULTIPLIER(42),ONENEG => INT_MULTIPLIER(43),
		PPBIT => SUMMAND(441)
	);
PPM_351:PP_MIDDLE
	port map
	(
		INA => OPA(21),INB => INV_MULTIPLICAND(21),
		INC => OPA(22),IND => INV_MULTIPLICAND(22),
		TWOPOS => INT_MULTIPLIER(40),TWONEG => INT_MULTIPLIER(41),ONEPOS => INT_MULTIPLIER(42),ONENEG => INT_MULTIPLIER(43),
		PPBIT => SUMMAND(454)
	);
PPM_352:PP_MIDDLE
	port map
	(
		INA => OPA(22),INB => INV_MULTIPLICAND(22),
		INC => OPA(23),IND => INV_MULTIPLICAND(23),
		TWOPOS => INT_MULTIPLIER(40),TWONEG => INT_MULTIPLIER(41),ONEPOS => INT_MULTIPLIER(42),ONENEG => INT_MULTIPLIER(43),
		PPBIT => SUMMAND(467)
	);
PPM_353:PP_MIDDLE
	port map
	(
		INA => OPA(23),INB => INV_MULTIPLICAND(23),
		INC => OPA(24),IND => INV_MULTIPLICAND(24),
		TWOPOS => INT_MULTIPLIER(40),TWONEG => INT_MULTIPLIER(41),ONEPOS => INT_MULTIPLIER(42),ONENEG => INT_MULTIPLIER(43),
		PPBIT => SUMMAND(479)
	);
PPM_354:PP_MIDDLE
	port map
	(
		INA => OPA(24),INB => INV_MULTIPLICAND(24),
		INC => OPA(25),IND => INV_MULTIPLICAND(25),
		TWOPOS => INT_MULTIPLIER(40),TWONEG => INT_MULTIPLIER(41),ONEPOS => INT_MULTIPLIER(42),ONENEG => INT_MULTIPLIER(43),
		PPBIT => SUMMAND(491)
	);
PPM_355:PP_MIDDLE
	port map
	(
		INA => OPA(25),INB => INV_MULTIPLICAND(25),
		INC => OPA(26),IND => INV_MULTIPLICAND(26),
		TWOPOS => INT_MULTIPLIER(40),TWONEG => INT_MULTIPLIER(41),ONEPOS => INT_MULTIPLIER(42),ONENEG => INT_MULTIPLIER(43),
		PPBIT => SUMMAND(502)
	);
PPM_356:PP_MIDDLE
	port map
	(
		INA => OPA(26),INB => INV_MULTIPLICAND(26),
		INC => OPA(27),IND => INV_MULTIPLICAND(27),
		TWOPOS => INT_MULTIPLIER(40),TWONEG => INT_MULTIPLIER(41),ONEPOS => INT_MULTIPLIER(42),ONENEG => INT_MULTIPLIER(43),
		PPBIT => SUMMAND(513)
	);
PPM_357:PP_MIDDLE
	port map
	(
		INA => OPA(27),INB => INV_MULTIPLICAND(27),
		INC => OPA(28),IND => INV_MULTIPLICAND(28),
		TWOPOS => INT_MULTIPLIER(40),TWONEG => INT_MULTIPLIER(41),ONEPOS => INT_MULTIPLIER(42),ONENEG => INT_MULTIPLIER(43),
		PPBIT => SUMMAND(523)
	);
PPM_358:PP_MIDDLE
	port map
	(
		INA => OPA(28),INB => INV_MULTIPLICAND(28),
		INC => OPA(29),IND => INV_MULTIPLICAND(29),
		TWOPOS => INT_MULTIPLIER(40),TWONEG => INT_MULTIPLIER(41),ONEPOS => INT_MULTIPLIER(42),ONENEG => INT_MULTIPLIER(43),
		PPBIT => SUMMAND(533)
	);
PPM_359:PP_MIDDLE
	port map
	(
		INA => OPA(29),INB => INV_MULTIPLICAND(29),
		INC => OPA(30),IND => INV_MULTIPLICAND(30),
		TWOPOS => INT_MULTIPLIER(40),TWONEG => INT_MULTIPLIER(41),ONEPOS => INT_MULTIPLIER(42),ONENEG => INT_MULTIPLIER(43),
		PPBIT => SUMMAND(542)
	);
PPM_360:PP_MIDDLE
	port map
	(
		INA => OPA(30),INB => INV_MULTIPLICAND(30),
		INC => OPA(31),IND => INV_MULTIPLICAND(31),
		TWOPOS => INT_MULTIPLIER(40),TWONEG => INT_MULTIPLIER(41),ONEPOS => INT_MULTIPLIER(42),ONENEG => INT_MULTIPLIER(43),
		PPBIT => SUMMAND(551)
	);
PPM_361:PP_MIDDLE
	port map
	(
		INA => OPA(31),INB => INV_MULTIPLICAND(31),
		INC => OPA(32),IND => INV_MULTIPLICAND(32),
		TWOPOS => INT_MULTIPLIER(40),TWONEG => INT_MULTIPLIER(41),ONEPOS => INT_MULTIPLIER(42),ONENEG => INT_MULTIPLIER(43),
		PPBIT => SUMMAND(559)
	);
PPM_362:PP_MIDDLE
	port map
	(
		INA => OPA(32),INB => INV_MULTIPLICAND(32),
		INC => OPA(33),IND => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(40),TWONEG => INT_MULTIPLIER(41),ONEPOS => INT_MULTIPLIER(42),ONENEG => INT_MULTIPLIER(43),
		PPBIT => SUMMAND(566)
	);
SUMMAND(567) <= LOGIC_ONE;
PPH_10:PP_HIGH
	port map
	(
		INA => OPA(33),INB => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(40),TWONEG => INT_MULTIPLIER(41),ONEPOS => INT_MULTIPLIER(42),ONENEG => INT_MULTIPLIER(43),
		PPBIT => SUMMAND(574)
	);
-- Begin partial product 11
-- Begin decoder block 12
DEC_11:DECODER -- Decoder of multiplier operand
	port map
	(
		INA => OPB(21),INB => OPB(22),INC => OPB(23),
		TWOPOS => INT_MULTIPLIER(44),TWONEG => INT_MULTIPLIER(45),ONEPOS => INT_MULTIPLIER(46),ONENEG => INT_MULTIPLIER(47)
	);
-- End decoder block 12
-- Begin partial product 12
PPL_11:PP_LOW
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		TWONEG => INT_MULTIPLIER(45),ONEPOS => INT_MULTIPLIER(46),ONENEG => INT_MULTIPLIER(47),
		PPBIT => SUMMAND(154)
	);
RGATE_11:R_GATE
	port map
	(
		INA => OPB(21),INB => OPB(22),INC => OPB(23),
		PPBIT => SUMMAND(155)
	);
PPM_363:PP_MIDDLE
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		INC => OPA(1),IND => INV_MULTIPLICAND(1),
		TWOPOS => INT_MULTIPLIER(44),TWONEG => INT_MULTIPLIER(45),ONEPOS => INT_MULTIPLIER(46),ONENEG => INT_MULTIPLIER(47),
		PPBIT => SUMMAND(167)
	);
PPM_364:PP_MIDDLE
	port map
	(
		INA => OPA(1),INB => INV_MULTIPLICAND(1),
		INC => OPA(2),IND => INV_MULTIPLICAND(2),
		TWOPOS => INT_MULTIPLIER(44),TWONEG => INT_MULTIPLIER(45),ONEPOS => INT_MULTIPLIER(46),ONENEG => INT_MULTIPLIER(47),
		PPBIT => SUMMAND(179)
	);
PPM_365:PP_MIDDLE
	port map
	(
		INA => OPA(2),INB => INV_MULTIPLICAND(2),
		INC => OPA(3),IND => INV_MULTIPLICAND(3),
		TWOPOS => INT_MULTIPLIER(44),TWONEG => INT_MULTIPLIER(45),ONEPOS => INT_MULTIPLIER(46),ONENEG => INT_MULTIPLIER(47),
		PPBIT => SUMMAND(193)
	);
PPM_366:PP_MIDDLE
	port map
	(
		INA => OPA(3),INB => INV_MULTIPLICAND(3),
		INC => OPA(4),IND => INV_MULTIPLICAND(4),
		TWOPOS => INT_MULTIPLIER(44),TWONEG => INT_MULTIPLIER(45),ONEPOS => INT_MULTIPLIER(46),ONENEG => INT_MULTIPLIER(47),
		PPBIT => SUMMAND(206)
	);
PPM_367:PP_MIDDLE
	port map
	(
		INA => OPA(4),INB => INV_MULTIPLICAND(4),
		INC => OPA(5),IND => INV_MULTIPLICAND(5),
		TWOPOS => INT_MULTIPLIER(44),TWONEG => INT_MULTIPLIER(45),ONEPOS => INT_MULTIPLIER(46),ONENEG => INT_MULTIPLIER(47),
		PPBIT => SUMMAND(221)
	);
PPM_368:PP_MIDDLE
	port map
	(
		INA => OPA(5),INB => INV_MULTIPLICAND(5),
		INC => OPA(6),IND => INV_MULTIPLICAND(6),
		TWOPOS => INT_MULTIPLIER(44),TWONEG => INT_MULTIPLIER(45),ONEPOS => INT_MULTIPLIER(46),ONENEG => INT_MULTIPLIER(47),
		PPBIT => SUMMAND(235)
	);
PPM_369:PP_MIDDLE
	port map
	(
		INA => OPA(6),INB => INV_MULTIPLICAND(6),
		INC => OPA(7),IND => INV_MULTIPLICAND(7),
		TWOPOS => INT_MULTIPLIER(44),TWONEG => INT_MULTIPLIER(45),ONEPOS => INT_MULTIPLIER(46),ONENEG => INT_MULTIPLIER(47),
		PPBIT => SUMMAND(251)
	);
PPM_370:PP_MIDDLE
	port map
	(
		INA => OPA(7),INB => INV_MULTIPLICAND(7),
		INC => OPA(8),IND => INV_MULTIPLICAND(8),
		TWOPOS => INT_MULTIPLIER(44),TWONEG => INT_MULTIPLIER(45),ONEPOS => INT_MULTIPLIER(46),ONENEG => INT_MULTIPLIER(47),
		PPBIT => SUMMAND(266)
	);
PPM_371:PP_MIDDLE
	port map
	(
		INA => OPA(8),INB => INV_MULTIPLICAND(8),
		INC => OPA(9),IND => INV_MULTIPLICAND(9),
		TWOPOS => INT_MULTIPLIER(44),TWONEG => INT_MULTIPLIER(45),ONEPOS => INT_MULTIPLIER(46),ONENEG => INT_MULTIPLIER(47),
		PPBIT => SUMMAND(283)
	);
PPM_372:PP_MIDDLE
	port map
	(
		INA => OPA(9),INB => INV_MULTIPLICAND(9),
		INC => OPA(10),IND => INV_MULTIPLICAND(10),
		TWOPOS => INT_MULTIPLIER(44),TWONEG => INT_MULTIPLIER(45),ONEPOS => INT_MULTIPLIER(46),ONENEG => INT_MULTIPLIER(47),
		PPBIT => SUMMAND(299)
	);
PPM_373:PP_MIDDLE
	port map
	(
		INA => OPA(10),INB => INV_MULTIPLICAND(10),
		INC => OPA(11),IND => INV_MULTIPLICAND(11),
		TWOPOS => INT_MULTIPLIER(44),TWONEG => INT_MULTIPLIER(45),ONEPOS => INT_MULTIPLIER(46),ONENEG => INT_MULTIPLIER(47),
		PPBIT => SUMMAND(317)
	);
PPM_374:PP_MIDDLE
	port map
	(
		INA => OPA(11),INB => INV_MULTIPLICAND(11),
		INC => OPA(12),IND => INV_MULTIPLICAND(12),
		TWOPOS => INT_MULTIPLIER(44),TWONEG => INT_MULTIPLIER(45),ONEPOS => INT_MULTIPLIER(46),ONENEG => INT_MULTIPLIER(47),
		PPBIT => SUMMAND(335)
	);
PPM_375:PP_MIDDLE
	port map
	(
		INA => OPA(12),INB => INV_MULTIPLICAND(12),
		INC => OPA(13),IND => INV_MULTIPLICAND(13),
		TWOPOS => INT_MULTIPLIER(44),TWONEG => INT_MULTIPLIER(45),ONEPOS => INT_MULTIPLIER(46),ONENEG => INT_MULTIPLIER(47),
		PPBIT => SUMMAND(352)
	);
PPM_376:PP_MIDDLE
	port map
	(
		INA => OPA(13),INB => INV_MULTIPLICAND(13),
		INC => OPA(14),IND => INV_MULTIPLICAND(14),
		TWOPOS => INT_MULTIPLIER(44),TWONEG => INT_MULTIPLIER(45),ONEPOS => INT_MULTIPLIER(46),ONENEG => INT_MULTIPLIER(47),
		PPBIT => SUMMAND(368)
	);
PPM_377:PP_MIDDLE
	port map
	(
		INA => OPA(14),INB => INV_MULTIPLICAND(14),
		INC => OPA(15),IND => INV_MULTIPLICAND(15),
		TWOPOS => INT_MULTIPLIER(44),TWONEG => INT_MULTIPLIER(45),ONEPOS => INT_MULTIPLIER(46),ONENEG => INT_MULTIPLIER(47),
		PPBIT => SUMMAND(384)
	);
PPM_378:PP_MIDDLE
	port map
	(
		INA => OPA(15),INB => INV_MULTIPLICAND(15),
		INC => OPA(16),IND => INV_MULTIPLICAND(16),
		TWOPOS => INT_MULTIPLIER(44),TWONEG => INT_MULTIPLIER(45),ONEPOS => INT_MULTIPLIER(46),ONENEG => INT_MULTIPLIER(47),
		PPBIT => SUMMAND(399)
	);
PPM_379:PP_MIDDLE
	port map
	(
		INA => OPA(16),INB => INV_MULTIPLICAND(16),
		INC => OPA(17),IND => INV_MULTIPLICAND(17),
		TWOPOS => INT_MULTIPLIER(44),TWONEG => INT_MULTIPLIER(45),ONEPOS => INT_MULTIPLIER(46),ONENEG => INT_MULTIPLIER(47),
		PPBIT => SUMMAND(414)
	);
PPM_380:PP_MIDDLE
	port map
	(
		INA => OPA(17),INB => INV_MULTIPLICAND(17),
		INC => OPA(18),IND => INV_MULTIPLICAND(18),
		TWOPOS => INT_MULTIPLIER(44),TWONEG => INT_MULTIPLIER(45),ONEPOS => INT_MULTIPLIER(46),ONENEG => INT_MULTIPLIER(47),
		PPBIT => SUMMAND(428)
	);
PPM_381:PP_MIDDLE
	port map
	(
		INA => OPA(18),INB => INV_MULTIPLICAND(18),
		INC => OPA(19),IND => INV_MULTIPLICAND(19),
		TWOPOS => INT_MULTIPLIER(44),TWONEG => INT_MULTIPLIER(45),ONEPOS => INT_MULTIPLIER(46),ONENEG => INT_MULTIPLIER(47),
		PPBIT => SUMMAND(442)
	);
PPM_382:PP_MIDDLE
	port map
	(
		INA => OPA(19),INB => INV_MULTIPLICAND(19),
		INC => OPA(20),IND => INV_MULTIPLICAND(20),
		TWOPOS => INT_MULTIPLIER(44),TWONEG => INT_MULTIPLIER(45),ONEPOS => INT_MULTIPLIER(46),ONENEG => INT_MULTIPLIER(47),
		PPBIT => SUMMAND(455)
	);
PPM_383:PP_MIDDLE
	port map
	(
		INA => OPA(20),INB => INV_MULTIPLICAND(20),
		INC => OPA(21),IND => INV_MULTIPLICAND(21),
		TWOPOS => INT_MULTIPLIER(44),TWONEG => INT_MULTIPLIER(45),ONEPOS => INT_MULTIPLIER(46),ONENEG => INT_MULTIPLIER(47),
		PPBIT => SUMMAND(468)
	);
PPM_384:PP_MIDDLE
	port map
	(
		INA => OPA(21),INB => INV_MULTIPLICAND(21),
		INC => OPA(22),IND => INV_MULTIPLICAND(22),
		TWOPOS => INT_MULTIPLIER(44),TWONEG => INT_MULTIPLIER(45),ONEPOS => INT_MULTIPLIER(46),ONENEG => INT_MULTIPLIER(47),
		PPBIT => SUMMAND(480)
	);
PPM_385:PP_MIDDLE
	port map
	(
		INA => OPA(22),INB => INV_MULTIPLICAND(22),
		INC => OPA(23),IND => INV_MULTIPLICAND(23),
		TWOPOS => INT_MULTIPLIER(44),TWONEG => INT_MULTIPLIER(45),ONEPOS => INT_MULTIPLIER(46),ONENEG => INT_MULTIPLIER(47),
		PPBIT => SUMMAND(492)
	);
PPM_386:PP_MIDDLE
	port map
	(
		INA => OPA(23),INB => INV_MULTIPLICAND(23),
		INC => OPA(24),IND => INV_MULTIPLICAND(24),
		TWOPOS => INT_MULTIPLIER(44),TWONEG => INT_MULTIPLIER(45),ONEPOS => INT_MULTIPLIER(46),ONENEG => INT_MULTIPLIER(47),
		PPBIT => SUMMAND(503)
	);
PPM_387:PP_MIDDLE
	port map
	(
		INA => OPA(24),INB => INV_MULTIPLICAND(24),
		INC => OPA(25),IND => INV_MULTIPLICAND(25),
		TWOPOS => INT_MULTIPLIER(44),TWONEG => INT_MULTIPLIER(45),ONEPOS => INT_MULTIPLIER(46),ONENEG => INT_MULTIPLIER(47),
		PPBIT => SUMMAND(514)
	);
PPM_388:PP_MIDDLE
	port map
	(
		INA => OPA(25),INB => INV_MULTIPLICAND(25),
		INC => OPA(26),IND => INV_MULTIPLICAND(26),
		TWOPOS => INT_MULTIPLIER(44),TWONEG => INT_MULTIPLIER(45),ONEPOS => INT_MULTIPLIER(46),ONENEG => INT_MULTIPLIER(47),
		PPBIT => SUMMAND(524)
	);
PPM_389:PP_MIDDLE
	port map
	(
		INA => OPA(26),INB => INV_MULTIPLICAND(26),
		INC => OPA(27),IND => INV_MULTIPLICAND(27),
		TWOPOS => INT_MULTIPLIER(44),TWONEG => INT_MULTIPLIER(45),ONEPOS => INT_MULTIPLIER(46),ONENEG => INT_MULTIPLIER(47),
		PPBIT => SUMMAND(534)
	);
PPM_390:PP_MIDDLE
	port map
	(
		INA => OPA(27),INB => INV_MULTIPLICAND(27),
		INC => OPA(28),IND => INV_MULTIPLICAND(28),
		TWOPOS => INT_MULTIPLIER(44),TWONEG => INT_MULTIPLIER(45),ONEPOS => INT_MULTIPLIER(46),ONENEG => INT_MULTIPLIER(47),
		PPBIT => SUMMAND(543)
	);
PPM_391:PP_MIDDLE
	port map
	(
		INA => OPA(28),INB => INV_MULTIPLICAND(28),
		INC => OPA(29),IND => INV_MULTIPLICAND(29),
		TWOPOS => INT_MULTIPLIER(44),TWONEG => INT_MULTIPLIER(45),ONEPOS => INT_MULTIPLIER(46),ONENEG => INT_MULTIPLIER(47),
		PPBIT => SUMMAND(552)
	);
PPM_392:PP_MIDDLE
	port map
	(
		INA => OPA(29),INB => INV_MULTIPLICAND(29),
		INC => OPA(30),IND => INV_MULTIPLICAND(30),
		TWOPOS => INT_MULTIPLIER(44),TWONEG => INT_MULTIPLIER(45),ONEPOS => INT_MULTIPLIER(46),ONENEG => INT_MULTIPLIER(47),
		PPBIT => SUMMAND(560)
	);
PPM_393:PP_MIDDLE
	port map
	(
		INA => OPA(30),INB => INV_MULTIPLICAND(30),
		INC => OPA(31),IND => INV_MULTIPLICAND(31),
		TWOPOS => INT_MULTIPLIER(44),TWONEG => INT_MULTIPLIER(45),ONEPOS => INT_MULTIPLIER(46),ONENEG => INT_MULTIPLIER(47),
		PPBIT => SUMMAND(568)
	);
PPM_394:PP_MIDDLE
	port map
	(
		INA => OPA(31),INB => INV_MULTIPLICAND(31),
		INC => OPA(32),IND => INV_MULTIPLICAND(32),
		TWOPOS => INT_MULTIPLIER(44),TWONEG => INT_MULTIPLIER(45),ONEPOS => INT_MULTIPLIER(46),ONENEG => INT_MULTIPLIER(47),
		PPBIT => SUMMAND(575)
	);
PPM_395:PP_MIDDLE
	port map
	(
		INA => OPA(32),INB => INV_MULTIPLICAND(32),
		INC => OPA(33),IND => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(44),TWONEG => INT_MULTIPLIER(45),ONEPOS => INT_MULTIPLIER(46),ONENEG => INT_MULTIPLIER(47),
		PPBIT => SUMMAND(581)
	);
SUMMAND(582) <= LOGIC_ONE;
PPH_11:PP_HIGH
	port map
	(
		INA => OPA(33),INB => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(44),TWONEG => INT_MULTIPLIER(45),ONEPOS => INT_MULTIPLIER(46),ONENEG => INT_MULTIPLIER(47),
		PPBIT => SUMMAND(588)
	);
-- Begin partial product 12
-- Begin decoder block 13
DEC_12:DECODER -- Decoder of multiplier operand
	port map
	(
		INA => OPB(23),INB => OPB(24),INC => OPB(25),
		TWOPOS => INT_MULTIPLIER(48),TWONEG => INT_MULTIPLIER(49),ONEPOS => INT_MULTIPLIER(50),ONENEG => INT_MULTIPLIER(51)
	);
-- End decoder block 13
-- Begin partial product 13
PPL_12:PP_LOW
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		TWONEG => INT_MULTIPLIER(49),ONEPOS => INT_MULTIPLIER(50),ONENEG => INT_MULTIPLIER(51),
		PPBIT => SUMMAND(180)
	);
RGATE_12:R_GATE
	port map
	(
		INA => OPB(23),INB => OPB(24),INC => OPB(25),
		PPBIT => SUMMAND(181)
	);
PPM_396:PP_MIDDLE
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		INC => OPA(1),IND => INV_MULTIPLICAND(1),
		TWOPOS => INT_MULTIPLIER(48),TWONEG => INT_MULTIPLIER(49),ONEPOS => INT_MULTIPLIER(50),ONENEG => INT_MULTIPLIER(51),
		PPBIT => SUMMAND(194)
	);
PPM_397:PP_MIDDLE
	port map
	(
		INA => OPA(1),INB => INV_MULTIPLICAND(1),
		INC => OPA(2),IND => INV_MULTIPLICAND(2),
		TWOPOS => INT_MULTIPLIER(48),TWONEG => INT_MULTIPLIER(49),ONEPOS => INT_MULTIPLIER(50),ONENEG => INT_MULTIPLIER(51),
		PPBIT => SUMMAND(207)
	);
PPM_398:PP_MIDDLE
	port map
	(
		INA => OPA(2),INB => INV_MULTIPLICAND(2),
		INC => OPA(3),IND => INV_MULTIPLICAND(3),
		TWOPOS => INT_MULTIPLIER(48),TWONEG => INT_MULTIPLIER(49),ONEPOS => INT_MULTIPLIER(50),ONENEG => INT_MULTIPLIER(51),
		PPBIT => SUMMAND(222)
	);
PPM_399:PP_MIDDLE
	port map
	(
		INA => OPA(3),INB => INV_MULTIPLICAND(3),
		INC => OPA(4),IND => INV_MULTIPLICAND(4),
		TWOPOS => INT_MULTIPLIER(48),TWONEG => INT_MULTIPLIER(49),ONEPOS => INT_MULTIPLIER(50),ONENEG => INT_MULTIPLIER(51),
		PPBIT => SUMMAND(236)
	);
PPM_400:PP_MIDDLE
	port map
	(
		INA => OPA(4),INB => INV_MULTIPLICAND(4),
		INC => OPA(5),IND => INV_MULTIPLICAND(5),
		TWOPOS => INT_MULTIPLIER(48),TWONEG => INT_MULTIPLIER(49),ONEPOS => INT_MULTIPLIER(50),ONENEG => INT_MULTIPLIER(51),
		PPBIT => SUMMAND(252)
	);
PPM_401:PP_MIDDLE
	port map
	(
		INA => OPA(5),INB => INV_MULTIPLICAND(5),
		INC => OPA(6),IND => INV_MULTIPLICAND(6),
		TWOPOS => INT_MULTIPLIER(48),TWONEG => INT_MULTIPLIER(49),ONEPOS => INT_MULTIPLIER(50),ONENEG => INT_MULTIPLIER(51),
		PPBIT => SUMMAND(267)
	);
PPM_402:PP_MIDDLE
	port map
	(
		INA => OPA(6),INB => INV_MULTIPLICAND(6),
		INC => OPA(7),IND => INV_MULTIPLICAND(7),
		TWOPOS => INT_MULTIPLIER(48),TWONEG => INT_MULTIPLIER(49),ONEPOS => INT_MULTIPLIER(50),ONENEG => INT_MULTIPLIER(51),
		PPBIT => SUMMAND(284)
	);
PPM_403:PP_MIDDLE
	port map
	(
		INA => OPA(7),INB => INV_MULTIPLICAND(7),
		INC => OPA(8),IND => INV_MULTIPLICAND(8),
		TWOPOS => INT_MULTIPLIER(48),TWONEG => INT_MULTIPLIER(49),ONEPOS => INT_MULTIPLIER(50),ONENEG => INT_MULTIPLIER(51),
		PPBIT => SUMMAND(300)
	);
PPM_404:PP_MIDDLE
	port map
	(
		INA => OPA(8),INB => INV_MULTIPLICAND(8),
		INC => OPA(9),IND => INV_MULTIPLICAND(9),
		TWOPOS => INT_MULTIPLIER(48),TWONEG => INT_MULTIPLIER(49),ONEPOS => INT_MULTIPLIER(50),ONENEG => INT_MULTIPLIER(51),
		PPBIT => SUMMAND(318)
	);
PPM_405:PP_MIDDLE
	port map
	(
		INA => OPA(9),INB => INV_MULTIPLICAND(9),
		INC => OPA(10),IND => INV_MULTIPLICAND(10),
		TWOPOS => INT_MULTIPLIER(48),TWONEG => INT_MULTIPLIER(49),ONEPOS => INT_MULTIPLIER(50),ONENEG => INT_MULTIPLIER(51),
		PPBIT => SUMMAND(336)
	);
PPM_406:PP_MIDDLE
	port map
	(
		INA => OPA(10),INB => INV_MULTIPLICAND(10),
		INC => OPA(11),IND => INV_MULTIPLICAND(11),
		TWOPOS => INT_MULTIPLIER(48),TWONEG => INT_MULTIPLIER(49),ONEPOS => INT_MULTIPLIER(50),ONENEG => INT_MULTIPLIER(51),
		PPBIT => SUMMAND(353)
	);
PPM_407:PP_MIDDLE
	port map
	(
		INA => OPA(11),INB => INV_MULTIPLICAND(11),
		INC => OPA(12),IND => INV_MULTIPLICAND(12),
		TWOPOS => INT_MULTIPLIER(48),TWONEG => INT_MULTIPLIER(49),ONEPOS => INT_MULTIPLIER(50),ONENEG => INT_MULTIPLIER(51),
		PPBIT => SUMMAND(369)
	);
PPM_408:PP_MIDDLE
	port map
	(
		INA => OPA(12),INB => INV_MULTIPLICAND(12),
		INC => OPA(13),IND => INV_MULTIPLICAND(13),
		TWOPOS => INT_MULTIPLIER(48),TWONEG => INT_MULTIPLIER(49),ONEPOS => INT_MULTIPLIER(50),ONENEG => INT_MULTIPLIER(51),
		PPBIT => SUMMAND(385)
	);
PPM_409:PP_MIDDLE
	port map
	(
		INA => OPA(13),INB => INV_MULTIPLICAND(13),
		INC => OPA(14),IND => INV_MULTIPLICAND(14),
		TWOPOS => INT_MULTIPLIER(48),TWONEG => INT_MULTIPLIER(49),ONEPOS => INT_MULTIPLIER(50),ONENEG => INT_MULTIPLIER(51),
		PPBIT => SUMMAND(400)
	);
PPM_410:PP_MIDDLE
	port map
	(
		INA => OPA(14),INB => INV_MULTIPLICAND(14),
		INC => OPA(15),IND => INV_MULTIPLICAND(15),
		TWOPOS => INT_MULTIPLIER(48),TWONEG => INT_MULTIPLIER(49),ONEPOS => INT_MULTIPLIER(50),ONENEG => INT_MULTIPLIER(51),
		PPBIT => SUMMAND(415)
	);
PPM_411:PP_MIDDLE
	port map
	(
		INA => OPA(15),INB => INV_MULTIPLICAND(15),
		INC => OPA(16),IND => INV_MULTIPLICAND(16),
		TWOPOS => INT_MULTIPLIER(48),TWONEG => INT_MULTIPLIER(49),ONEPOS => INT_MULTIPLIER(50),ONENEG => INT_MULTIPLIER(51),
		PPBIT => SUMMAND(429)
	);
PPM_412:PP_MIDDLE
	port map
	(
		INA => OPA(16),INB => INV_MULTIPLICAND(16),
		INC => OPA(17),IND => INV_MULTIPLICAND(17),
		TWOPOS => INT_MULTIPLIER(48),TWONEG => INT_MULTIPLIER(49),ONEPOS => INT_MULTIPLIER(50),ONENEG => INT_MULTIPLIER(51),
		PPBIT => SUMMAND(443)
	);
PPM_413:PP_MIDDLE
	port map
	(
		INA => OPA(17),INB => INV_MULTIPLICAND(17),
		INC => OPA(18),IND => INV_MULTIPLICAND(18),
		TWOPOS => INT_MULTIPLIER(48),TWONEG => INT_MULTIPLIER(49),ONEPOS => INT_MULTIPLIER(50),ONENEG => INT_MULTIPLIER(51),
		PPBIT => SUMMAND(456)
	);
PPM_414:PP_MIDDLE
	port map
	(
		INA => OPA(18),INB => INV_MULTIPLICAND(18),
		INC => OPA(19),IND => INV_MULTIPLICAND(19),
		TWOPOS => INT_MULTIPLIER(48),TWONEG => INT_MULTIPLIER(49),ONEPOS => INT_MULTIPLIER(50),ONENEG => INT_MULTIPLIER(51),
		PPBIT => SUMMAND(469)
	);
PPM_415:PP_MIDDLE
	port map
	(
		INA => OPA(19),INB => INV_MULTIPLICAND(19),
		INC => OPA(20),IND => INV_MULTIPLICAND(20),
		TWOPOS => INT_MULTIPLIER(48),TWONEG => INT_MULTIPLIER(49),ONEPOS => INT_MULTIPLIER(50),ONENEG => INT_MULTIPLIER(51),
		PPBIT => SUMMAND(481)
	);
PPM_416:PP_MIDDLE
	port map
	(
		INA => OPA(20),INB => INV_MULTIPLICAND(20),
		INC => OPA(21),IND => INV_MULTIPLICAND(21),
		TWOPOS => INT_MULTIPLIER(48),TWONEG => INT_MULTIPLIER(49),ONEPOS => INT_MULTIPLIER(50),ONENEG => INT_MULTIPLIER(51),
		PPBIT => SUMMAND(493)
	);
PPM_417:PP_MIDDLE
	port map
	(
		INA => OPA(21),INB => INV_MULTIPLICAND(21),
		INC => OPA(22),IND => INV_MULTIPLICAND(22),
		TWOPOS => INT_MULTIPLIER(48),TWONEG => INT_MULTIPLIER(49),ONEPOS => INT_MULTIPLIER(50),ONENEG => INT_MULTIPLIER(51),
		PPBIT => SUMMAND(504)
	);
PPM_418:PP_MIDDLE
	port map
	(
		INA => OPA(22),INB => INV_MULTIPLICAND(22),
		INC => OPA(23),IND => INV_MULTIPLICAND(23),
		TWOPOS => INT_MULTIPLIER(48),TWONEG => INT_MULTIPLIER(49),ONEPOS => INT_MULTIPLIER(50),ONENEG => INT_MULTIPLIER(51),
		PPBIT => SUMMAND(515)
	);
PPM_419:PP_MIDDLE
	port map
	(
		INA => OPA(23),INB => INV_MULTIPLICAND(23),
		INC => OPA(24),IND => INV_MULTIPLICAND(24),
		TWOPOS => INT_MULTIPLIER(48),TWONEG => INT_MULTIPLIER(49),ONEPOS => INT_MULTIPLIER(50),ONENEG => INT_MULTIPLIER(51),
		PPBIT => SUMMAND(525)
	);
PPM_420:PP_MIDDLE
	port map
	(
		INA => OPA(24),INB => INV_MULTIPLICAND(24),
		INC => OPA(25),IND => INV_MULTIPLICAND(25),
		TWOPOS => INT_MULTIPLIER(48),TWONEG => INT_MULTIPLIER(49),ONEPOS => INT_MULTIPLIER(50),ONENEG => INT_MULTIPLIER(51),
		PPBIT => SUMMAND(535)
	);
PPM_421:PP_MIDDLE
	port map
	(
		INA => OPA(25),INB => INV_MULTIPLICAND(25),
		INC => OPA(26),IND => INV_MULTIPLICAND(26),
		TWOPOS => INT_MULTIPLIER(48),TWONEG => INT_MULTIPLIER(49),ONEPOS => INT_MULTIPLIER(50),ONENEG => INT_MULTIPLIER(51),
		PPBIT => SUMMAND(544)
	);
PPM_422:PP_MIDDLE
	port map
	(
		INA => OPA(26),INB => INV_MULTIPLICAND(26),
		INC => OPA(27),IND => INV_MULTIPLICAND(27),
		TWOPOS => INT_MULTIPLIER(48),TWONEG => INT_MULTIPLIER(49),ONEPOS => INT_MULTIPLIER(50),ONENEG => INT_MULTIPLIER(51),
		PPBIT => SUMMAND(553)
	);
PPM_423:PP_MIDDLE
	port map
	(
		INA => OPA(27),INB => INV_MULTIPLICAND(27),
		INC => OPA(28),IND => INV_MULTIPLICAND(28),
		TWOPOS => INT_MULTIPLIER(48),TWONEG => INT_MULTIPLIER(49),ONEPOS => INT_MULTIPLIER(50),ONENEG => INT_MULTIPLIER(51),
		PPBIT => SUMMAND(561)
	);
PPM_424:PP_MIDDLE
	port map
	(
		INA => OPA(28),INB => INV_MULTIPLICAND(28),
		INC => OPA(29),IND => INV_MULTIPLICAND(29),
		TWOPOS => INT_MULTIPLIER(48),TWONEG => INT_MULTIPLIER(49),ONEPOS => INT_MULTIPLIER(50),ONENEG => INT_MULTIPLIER(51),
		PPBIT => SUMMAND(569)
	);
PPM_425:PP_MIDDLE
	port map
	(
		INA => OPA(29),INB => INV_MULTIPLICAND(29),
		INC => OPA(30),IND => INV_MULTIPLICAND(30),
		TWOPOS => INT_MULTIPLIER(48),TWONEG => INT_MULTIPLIER(49),ONEPOS => INT_MULTIPLIER(50),ONENEG => INT_MULTIPLIER(51),
		PPBIT => SUMMAND(576)
	);
PPM_426:PP_MIDDLE
	port map
	(
		INA => OPA(30),INB => INV_MULTIPLICAND(30),
		INC => OPA(31),IND => INV_MULTIPLICAND(31),
		TWOPOS => INT_MULTIPLIER(48),TWONEG => INT_MULTIPLIER(49),ONEPOS => INT_MULTIPLIER(50),ONENEG => INT_MULTIPLIER(51),
		PPBIT => SUMMAND(583)
	);
PPM_427:PP_MIDDLE
	port map
	(
		INA => OPA(31),INB => INV_MULTIPLICAND(31),
		INC => OPA(32),IND => INV_MULTIPLICAND(32),
		TWOPOS => INT_MULTIPLIER(48),TWONEG => INT_MULTIPLIER(49),ONEPOS => INT_MULTIPLIER(50),ONENEG => INT_MULTIPLIER(51),
		PPBIT => SUMMAND(589)
	);
PPM_428:PP_MIDDLE
	port map
	(
		INA => OPA(32),INB => INV_MULTIPLICAND(32),
		INC => OPA(33),IND => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(48),TWONEG => INT_MULTIPLIER(49),ONEPOS => INT_MULTIPLIER(50),ONENEG => INT_MULTIPLIER(51),
		PPBIT => SUMMAND(594)
	);
SUMMAND(595) <= LOGIC_ONE;
PPH_12:PP_HIGH
	port map
	(
		INA => OPA(33),INB => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(48),TWONEG => INT_MULTIPLIER(49),ONEPOS => INT_MULTIPLIER(50),ONENEG => INT_MULTIPLIER(51),
		PPBIT => SUMMAND(600)
	);
-- Begin partial product 13
-- Begin decoder block 14
DEC_13:DECODER -- Decoder of multiplier operand
	port map
	(
		INA => OPB(25),INB => OPB(26),INC => OPB(27),
		TWOPOS => INT_MULTIPLIER(52),TWONEG => INT_MULTIPLIER(53),ONEPOS => INT_MULTIPLIER(54),ONENEG => INT_MULTIPLIER(55)
	);
-- End decoder block 14
-- Begin partial product 14
PPL_13:PP_LOW
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		TWONEG => INT_MULTIPLIER(53),ONEPOS => INT_MULTIPLIER(54),ONENEG => INT_MULTIPLIER(55),
		PPBIT => SUMMAND(208)
	);
RGATE_13:R_GATE
	port map
	(
		INA => OPB(25),INB => OPB(26),INC => OPB(27),
		PPBIT => SUMMAND(209)
	);
PPM_429:PP_MIDDLE
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		INC => OPA(1),IND => INV_MULTIPLICAND(1),
		TWOPOS => INT_MULTIPLIER(52),TWONEG => INT_MULTIPLIER(53),ONEPOS => INT_MULTIPLIER(54),ONENEG => INT_MULTIPLIER(55),
		PPBIT => SUMMAND(223)
	);
PPM_430:PP_MIDDLE
	port map
	(
		INA => OPA(1),INB => INV_MULTIPLICAND(1),
		INC => OPA(2),IND => INV_MULTIPLICAND(2),
		TWOPOS => INT_MULTIPLIER(52),TWONEG => INT_MULTIPLIER(53),ONEPOS => INT_MULTIPLIER(54),ONENEG => INT_MULTIPLIER(55),
		PPBIT => SUMMAND(237)
	);
PPM_431:PP_MIDDLE
	port map
	(
		INA => OPA(2),INB => INV_MULTIPLICAND(2),
		INC => OPA(3),IND => INV_MULTIPLICAND(3),
		TWOPOS => INT_MULTIPLIER(52),TWONEG => INT_MULTIPLIER(53),ONEPOS => INT_MULTIPLIER(54),ONENEG => INT_MULTIPLIER(55),
		PPBIT => SUMMAND(253)
	);
PPM_432:PP_MIDDLE
	port map
	(
		INA => OPA(3),INB => INV_MULTIPLICAND(3),
		INC => OPA(4),IND => INV_MULTIPLICAND(4),
		TWOPOS => INT_MULTIPLIER(52),TWONEG => INT_MULTIPLIER(53),ONEPOS => INT_MULTIPLIER(54),ONENEG => INT_MULTIPLIER(55),
		PPBIT => SUMMAND(268)
	);
PPM_433:PP_MIDDLE
	port map
	(
		INA => OPA(4),INB => INV_MULTIPLICAND(4),
		INC => OPA(5),IND => INV_MULTIPLICAND(5),
		TWOPOS => INT_MULTIPLIER(52),TWONEG => INT_MULTIPLIER(53),ONEPOS => INT_MULTIPLIER(54),ONENEG => INT_MULTIPLIER(55),
		PPBIT => SUMMAND(285)
	);
PPM_434:PP_MIDDLE
	port map
	(
		INA => OPA(5),INB => INV_MULTIPLICAND(5),
		INC => OPA(6),IND => INV_MULTIPLICAND(6),
		TWOPOS => INT_MULTIPLIER(52),TWONEG => INT_MULTIPLIER(53),ONEPOS => INT_MULTIPLIER(54),ONENEG => INT_MULTIPLIER(55),
		PPBIT => SUMMAND(301)
	);
PPM_435:PP_MIDDLE
	port map
	(
		INA => OPA(6),INB => INV_MULTIPLICAND(6),
		INC => OPA(7),IND => INV_MULTIPLICAND(7),
		TWOPOS => INT_MULTIPLIER(52),TWONEG => INT_MULTIPLIER(53),ONEPOS => INT_MULTIPLIER(54),ONENEG => INT_MULTIPLIER(55),
		PPBIT => SUMMAND(319)
	);
PPM_436:PP_MIDDLE
	port map
	(
		INA => OPA(7),INB => INV_MULTIPLICAND(7),
		INC => OPA(8),IND => INV_MULTIPLICAND(8),
		TWOPOS => INT_MULTIPLIER(52),TWONEG => INT_MULTIPLIER(53),ONEPOS => INT_MULTIPLIER(54),ONENEG => INT_MULTIPLIER(55),
		PPBIT => SUMMAND(337)
	);
PPM_437:PP_MIDDLE
	port map
	(
		INA => OPA(8),INB => INV_MULTIPLICAND(8),
		INC => OPA(9),IND => INV_MULTIPLICAND(9),
		TWOPOS => INT_MULTIPLIER(52),TWONEG => INT_MULTIPLIER(53),ONEPOS => INT_MULTIPLIER(54),ONENEG => INT_MULTIPLIER(55),
		PPBIT => SUMMAND(354)
	);
PPM_438:PP_MIDDLE
	port map
	(
		INA => OPA(9),INB => INV_MULTIPLICAND(9),
		INC => OPA(10),IND => INV_MULTIPLICAND(10),
		TWOPOS => INT_MULTIPLIER(52),TWONEG => INT_MULTIPLIER(53),ONEPOS => INT_MULTIPLIER(54),ONENEG => INT_MULTIPLIER(55),
		PPBIT => SUMMAND(370)
	);
PPM_439:PP_MIDDLE
	port map
	(
		INA => OPA(10),INB => INV_MULTIPLICAND(10),
		INC => OPA(11),IND => INV_MULTIPLICAND(11),
		TWOPOS => INT_MULTIPLIER(52),TWONEG => INT_MULTIPLIER(53),ONEPOS => INT_MULTIPLIER(54),ONENEG => INT_MULTIPLIER(55),
		PPBIT => SUMMAND(386)
	);
PPM_440:PP_MIDDLE
	port map
	(
		INA => OPA(11),INB => INV_MULTIPLICAND(11),
		INC => OPA(12),IND => INV_MULTIPLICAND(12),
		TWOPOS => INT_MULTIPLIER(52),TWONEG => INT_MULTIPLIER(53),ONEPOS => INT_MULTIPLIER(54),ONENEG => INT_MULTIPLIER(55),
		PPBIT => SUMMAND(401)
	);
PPM_441:PP_MIDDLE
	port map
	(
		INA => OPA(12),INB => INV_MULTIPLICAND(12),
		INC => OPA(13),IND => INV_MULTIPLICAND(13),
		TWOPOS => INT_MULTIPLIER(52),TWONEG => INT_MULTIPLIER(53),ONEPOS => INT_MULTIPLIER(54),ONENEG => INT_MULTIPLIER(55),
		PPBIT => SUMMAND(416)
	);
PPM_442:PP_MIDDLE
	port map
	(
		INA => OPA(13),INB => INV_MULTIPLICAND(13),
		INC => OPA(14),IND => INV_MULTIPLICAND(14),
		TWOPOS => INT_MULTIPLIER(52),TWONEG => INT_MULTIPLIER(53),ONEPOS => INT_MULTIPLIER(54),ONENEG => INT_MULTIPLIER(55),
		PPBIT => SUMMAND(430)
	);
PPM_443:PP_MIDDLE
	port map
	(
		INA => OPA(14),INB => INV_MULTIPLICAND(14),
		INC => OPA(15),IND => INV_MULTIPLICAND(15),
		TWOPOS => INT_MULTIPLIER(52),TWONEG => INT_MULTIPLIER(53),ONEPOS => INT_MULTIPLIER(54),ONENEG => INT_MULTIPLIER(55),
		PPBIT => SUMMAND(444)
	);
PPM_444:PP_MIDDLE
	port map
	(
		INA => OPA(15),INB => INV_MULTIPLICAND(15),
		INC => OPA(16),IND => INV_MULTIPLICAND(16),
		TWOPOS => INT_MULTIPLIER(52),TWONEG => INT_MULTIPLIER(53),ONEPOS => INT_MULTIPLIER(54),ONENEG => INT_MULTIPLIER(55),
		PPBIT => SUMMAND(457)
	);
PPM_445:PP_MIDDLE
	port map
	(
		INA => OPA(16),INB => INV_MULTIPLICAND(16),
		INC => OPA(17),IND => INV_MULTIPLICAND(17),
		TWOPOS => INT_MULTIPLIER(52),TWONEG => INT_MULTIPLIER(53),ONEPOS => INT_MULTIPLIER(54),ONENEG => INT_MULTIPLIER(55),
		PPBIT => SUMMAND(470)
	);
PPM_446:PP_MIDDLE
	port map
	(
		INA => OPA(17),INB => INV_MULTIPLICAND(17),
		INC => OPA(18),IND => INV_MULTIPLICAND(18),
		TWOPOS => INT_MULTIPLIER(52),TWONEG => INT_MULTIPLIER(53),ONEPOS => INT_MULTIPLIER(54),ONENEG => INT_MULTIPLIER(55),
		PPBIT => SUMMAND(482)
	);
PPM_447:PP_MIDDLE
	port map
	(
		INA => OPA(18),INB => INV_MULTIPLICAND(18),
		INC => OPA(19),IND => INV_MULTIPLICAND(19),
		TWOPOS => INT_MULTIPLIER(52),TWONEG => INT_MULTIPLIER(53),ONEPOS => INT_MULTIPLIER(54),ONENEG => INT_MULTIPLIER(55),
		PPBIT => SUMMAND(494)
	);
PPM_448:PP_MIDDLE
	port map
	(
		INA => OPA(19),INB => INV_MULTIPLICAND(19),
		INC => OPA(20),IND => INV_MULTIPLICAND(20),
		TWOPOS => INT_MULTIPLIER(52),TWONEG => INT_MULTIPLIER(53),ONEPOS => INT_MULTIPLIER(54),ONENEG => INT_MULTIPLIER(55),
		PPBIT => SUMMAND(505)
	);
PPM_449:PP_MIDDLE
	port map
	(
		INA => OPA(20),INB => INV_MULTIPLICAND(20),
		INC => OPA(21),IND => INV_MULTIPLICAND(21),
		TWOPOS => INT_MULTIPLIER(52),TWONEG => INT_MULTIPLIER(53),ONEPOS => INT_MULTIPLIER(54),ONENEG => INT_MULTIPLIER(55),
		PPBIT => SUMMAND(516)
	);
PPM_450:PP_MIDDLE
	port map
	(
		INA => OPA(21),INB => INV_MULTIPLICAND(21),
		INC => OPA(22),IND => INV_MULTIPLICAND(22),
		TWOPOS => INT_MULTIPLIER(52),TWONEG => INT_MULTIPLIER(53),ONEPOS => INT_MULTIPLIER(54),ONENEG => INT_MULTIPLIER(55),
		PPBIT => SUMMAND(526)
	);
PPM_451:PP_MIDDLE
	port map
	(
		INA => OPA(22),INB => INV_MULTIPLICAND(22),
		INC => OPA(23),IND => INV_MULTIPLICAND(23),
		TWOPOS => INT_MULTIPLIER(52),TWONEG => INT_MULTIPLIER(53),ONEPOS => INT_MULTIPLIER(54),ONENEG => INT_MULTIPLIER(55),
		PPBIT => SUMMAND(536)
	);
PPM_452:PP_MIDDLE
	port map
	(
		INA => OPA(23),INB => INV_MULTIPLICAND(23),
		INC => OPA(24),IND => INV_MULTIPLICAND(24),
		TWOPOS => INT_MULTIPLIER(52),TWONEG => INT_MULTIPLIER(53),ONEPOS => INT_MULTIPLIER(54),ONENEG => INT_MULTIPLIER(55),
		PPBIT => SUMMAND(545)
	);
PPM_453:PP_MIDDLE
	port map
	(
		INA => OPA(24),INB => INV_MULTIPLICAND(24),
		INC => OPA(25),IND => INV_MULTIPLICAND(25),
		TWOPOS => INT_MULTIPLIER(52),TWONEG => INT_MULTIPLIER(53),ONEPOS => INT_MULTIPLIER(54),ONENEG => INT_MULTIPLIER(55),
		PPBIT => SUMMAND(554)
	);
PPM_454:PP_MIDDLE
	port map
	(
		INA => OPA(25),INB => INV_MULTIPLICAND(25),
		INC => OPA(26),IND => INV_MULTIPLICAND(26),
		TWOPOS => INT_MULTIPLIER(52),TWONEG => INT_MULTIPLIER(53),ONEPOS => INT_MULTIPLIER(54),ONENEG => INT_MULTIPLIER(55),
		PPBIT => SUMMAND(562)
	);
PPM_455:PP_MIDDLE
	port map
	(
		INA => OPA(26),INB => INV_MULTIPLICAND(26),
		INC => OPA(27),IND => INV_MULTIPLICAND(27),
		TWOPOS => INT_MULTIPLIER(52),TWONEG => INT_MULTIPLIER(53),ONEPOS => INT_MULTIPLIER(54),ONENEG => INT_MULTIPLIER(55),
		PPBIT => SUMMAND(570)
	);
PPM_456:PP_MIDDLE
	port map
	(
		INA => OPA(27),INB => INV_MULTIPLICAND(27),
		INC => OPA(28),IND => INV_MULTIPLICAND(28),
		TWOPOS => INT_MULTIPLIER(52),TWONEG => INT_MULTIPLIER(53),ONEPOS => INT_MULTIPLIER(54),ONENEG => INT_MULTIPLIER(55),
		PPBIT => SUMMAND(577)
	);
PPM_457:PP_MIDDLE
	port map
	(
		INA => OPA(28),INB => INV_MULTIPLICAND(28),
		INC => OPA(29),IND => INV_MULTIPLICAND(29),
		TWOPOS => INT_MULTIPLIER(52),TWONEG => INT_MULTIPLIER(53),ONEPOS => INT_MULTIPLIER(54),ONENEG => INT_MULTIPLIER(55),
		PPBIT => SUMMAND(584)
	);
PPM_458:PP_MIDDLE
	port map
	(
		INA => OPA(29),INB => INV_MULTIPLICAND(29),
		INC => OPA(30),IND => INV_MULTIPLICAND(30),
		TWOPOS => INT_MULTIPLIER(52),TWONEG => INT_MULTIPLIER(53),ONEPOS => INT_MULTIPLIER(54),ONENEG => INT_MULTIPLIER(55),
		PPBIT => SUMMAND(590)
	);
PPM_459:PP_MIDDLE
	port map
	(
		INA => OPA(30),INB => INV_MULTIPLICAND(30),
		INC => OPA(31),IND => INV_MULTIPLICAND(31),
		TWOPOS => INT_MULTIPLIER(52),TWONEG => INT_MULTIPLIER(53),ONEPOS => INT_MULTIPLIER(54),ONENEG => INT_MULTIPLIER(55),
		PPBIT => SUMMAND(596)
	);
PPM_460:PP_MIDDLE
	port map
	(
		INA => OPA(31),INB => INV_MULTIPLICAND(31),
		INC => OPA(32),IND => INV_MULTIPLICAND(32),
		TWOPOS => INT_MULTIPLIER(52),TWONEG => INT_MULTIPLIER(53),ONEPOS => INT_MULTIPLIER(54),ONENEG => INT_MULTIPLIER(55),
		PPBIT => SUMMAND(601)
	);
PPM_461:PP_MIDDLE
	port map
	(
		INA => OPA(32),INB => INV_MULTIPLICAND(32),
		INC => OPA(33),IND => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(52),TWONEG => INT_MULTIPLIER(53),ONEPOS => INT_MULTIPLIER(54),ONENEG => INT_MULTIPLIER(55),
		PPBIT => SUMMAND(605)
	);
SUMMAND(606) <= LOGIC_ONE;
PPH_13:PP_HIGH
	port map
	(
		INA => OPA(33),INB => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(52),TWONEG => INT_MULTIPLIER(53),ONEPOS => INT_MULTIPLIER(54),ONENEG => INT_MULTIPLIER(55),
		PPBIT => SUMMAND(610)
	);
-- Begin partial product 14
-- Begin decoder block 15
DEC_14:DECODER -- Decoder of multiplier operand
	port map
	(
		INA => OPB(27),INB => OPB(28),INC => OPB(29),
		TWOPOS => INT_MULTIPLIER(56),TWONEG => INT_MULTIPLIER(57),ONEPOS => INT_MULTIPLIER(58),ONENEG => INT_MULTIPLIER(59)
	);
-- End decoder block 15
-- Begin partial product 15
PPL_14:PP_LOW
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		TWONEG => INT_MULTIPLIER(57),ONEPOS => INT_MULTIPLIER(58),ONENEG => INT_MULTIPLIER(59),
		PPBIT => SUMMAND(238)
	);
RGATE_14:R_GATE
	port map
	(
		INA => OPB(27),INB => OPB(28),INC => OPB(29),
		PPBIT => SUMMAND(239)
	);
PPM_462:PP_MIDDLE
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		INC => OPA(1),IND => INV_MULTIPLICAND(1),
		TWOPOS => INT_MULTIPLIER(56),TWONEG => INT_MULTIPLIER(57),ONEPOS => INT_MULTIPLIER(58),ONENEG => INT_MULTIPLIER(59),
		PPBIT => SUMMAND(254)
	);
PPM_463:PP_MIDDLE
	port map
	(
		INA => OPA(1),INB => INV_MULTIPLICAND(1),
		INC => OPA(2),IND => INV_MULTIPLICAND(2),
		TWOPOS => INT_MULTIPLIER(56),TWONEG => INT_MULTIPLIER(57),ONEPOS => INT_MULTIPLIER(58),ONENEG => INT_MULTIPLIER(59),
		PPBIT => SUMMAND(269)
	);
PPM_464:PP_MIDDLE
	port map
	(
		INA => OPA(2),INB => INV_MULTIPLICAND(2),
		INC => OPA(3),IND => INV_MULTIPLICAND(3),
		TWOPOS => INT_MULTIPLIER(56),TWONEG => INT_MULTIPLIER(57),ONEPOS => INT_MULTIPLIER(58),ONENEG => INT_MULTIPLIER(59),
		PPBIT => SUMMAND(286)
	);
PPM_465:PP_MIDDLE
	port map
	(
		INA => OPA(3),INB => INV_MULTIPLICAND(3),
		INC => OPA(4),IND => INV_MULTIPLICAND(4),
		TWOPOS => INT_MULTIPLIER(56),TWONEG => INT_MULTIPLIER(57),ONEPOS => INT_MULTIPLIER(58),ONENEG => INT_MULTIPLIER(59),
		PPBIT => SUMMAND(302)
	);
PPM_466:PP_MIDDLE
	port map
	(
		INA => OPA(4),INB => INV_MULTIPLICAND(4),
		INC => OPA(5),IND => INV_MULTIPLICAND(5),
		TWOPOS => INT_MULTIPLIER(56),TWONEG => INT_MULTIPLIER(57),ONEPOS => INT_MULTIPLIER(58),ONENEG => INT_MULTIPLIER(59),
		PPBIT => SUMMAND(320)
	);
PPM_467:PP_MIDDLE
	port map
	(
		INA => OPA(5),INB => INV_MULTIPLICAND(5),
		INC => OPA(6),IND => INV_MULTIPLICAND(6),
		TWOPOS => INT_MULTIPLIER(56),TWONEG => INT_MULTIPLIER(57),ONEPOS => INT_MULTIPLIER(58),ONENEG => INT_MULTIPLIER(59),
		PPBIT => SUMMAND(338)
	);
PPM_468:PP_MIDDLE
	port map
	(
		INA => OPA(6),INB => INV_MULTIPLICAND(6),
		INC => OPA(7),IND => INV_MULTIPLICAND(7),
		TWOPOS => INT_MULTIPLIER(56),TWONEG => INT_MULTIPLIER(57),ONEPOS => INT_MULTIPLIER(58),ONENEG => INT_MULTIPLIER(59),
		PPBIT => SUMMAND(355)
	);
PPM_469:PP_MIDDLE
	port map
	(
		INA => OPA(7),INB => INV_MULTIPLICAND(7),
		INC => OPA(8),IND => INV_MULTIPLICAND(8),
		TWOPOS => INT_MULTIPLIER(56),TWONEG => INT_MULTIPLIER(57),ONEPOS => INT_MULTIPLIER(58),ONENEG => INT_MULTIPLIER(59),
		PPBIT => SUMMAND(371)
	);
PPM_470:PP_MIDDLE
	port map
	(
		INA => OPA(8),INB => INV_MULTIPLICAND(8),
		INC => OPA(9),IND => INV_MULTIPLICAND(9),
		TWOPOS => INT_MULTIPLIER(56),TWONEG => INT_MULTIPLIER(57),ONEPOS => INT_MULTIPLIER(58),ONENEG => INT_MULTIPLIER(59),
		PPBIT => SUMMAND(387)
	);
PPM_471:PP_MIDDLE
	port map
	(
		INA => OPA(9),INB => INV_MULTIPLICAND(9),
		INC => OPA(10),IND => INV_MULTIPLICAND(10),
		TWOPOS => INT_MULTIPLIER(56),TWONEG => INT_MULTIPLIER(57),ONEPOS => INT_MULTIPLIER(58),ONENEG => INT_MULTIPLIER(59),
		PPBIT => SUMMAND(402)
	);
PPM_472:PP_MIDDLE
	port map
	(
		INA => OPA(10),INB => INV_MULTIPLICAND(10),
		INC => OPA(11),IND => INV_MULTIPLICAND(11),
		TWOPOS => INT_MULTIPLIER(56),TWONEG => INT_MULTIPLIER(57),ONEPOS => INT_MULTIPLIER(58),ONENEG => INT_MULTIPLIER(59),
		PPBIT => SUMMAND(417)
	);
PPM_473:PP_MIDDLE
	port map
	(
		INA => OPA(11),INB => INV_MULTIPLICAND(11),
		INC => OPA(12),IND => INV_MULTIPLICAND(12),
		TWOPOS => INT_MULTIPLIER(56),TWONEG => INT_MULTIPLIER(57),ONEPOS => INT_MULTIPLIER(58),ONENEG => INT_MULTIPLIER(59),
		PPBIT => SUMMAND(431)
	);
PPM_474:PP_MIDDLE
	port map
	(
		INA => OPA(12),INB => INV_MULTIPLICAND(12),
		INC => OPA(13),IND => INV_MULTIPLICAND(13),
		TWOPOS => INT_MULTIPLIER(56),TWONEG => INT_MULTIPLIER(57),ONEPOS => INT_MULTIPLIER(58),ONENEG => INT_MULTIPLIER(59),
		PPBIT => SUMMAND(445)
	);
PPM_475:PP_MIDDLE
	port map
	(
		INA => OPA(13),INB => INV_MULTIPLICAND(13),
		INC => OPA(14),IND => INV_MULTIPLICAND(14),
		TWOPOS => INT_MULTIPLIER(56),TWONEG => INT_MULTIPLIER(57),ONEPOS => INT_MULTIPLIER(58),ONENEG => INT_MULTIPLIER(59),
		PPBIT => SUMMAND(458)
	);
PPM_476:PP_MIDDLE
	port map
	(
		INA => OPA(14),INB => INV_MULTIPLICAND(14),
		INC => OPA(15),IND => INV_MULTIPLICAND(15),
		TWOPOS => INT_MULTIPLIER(56),TWONEG => INT_MULTIPLIER(57),ONEPOS => INT_MULTIPLIER(58),ONENEG => INT_MULTIPLIER(59),
		PPBIT => SUMMAND(471)
	);
PPM_477:PP_MIDDLE
	port map
	(
		INA => OPA(15),INB => INV_MULTIPLICAND(15),
		INC => OPA(16),IND => INV_MULTIPLICAND(16),
		TWOPOS => INT_MULTIPLIER(56),TWONEG => INT_MULTIPLIER(57),ONEPOS => INT_MULTIPLIER(58),ONENEG => INT_MULTIPLIER(59),
		PPBIT => SUMMAND(483)
	);
PPM_478:PP_MIDDLE
	port map
	(
		INA => OPA(16),INB => INV_MULTIPLICAND(16),
		INC => OPA(17),IND => INV_MULTIPLICAND(17),
		TWOPOS => INT_MULTIPLIER(56),TWONEG => INT_MULTIPLIER(57),ONEPOS => INT_MULTIPLIER(58),ONENEG => INT_MULTIPLIER(59),
		PPBIT => SUMMAND(495)
	);
PPM_479:PP_MIDDLE
	port map
	(
		INA => OPA(17),INB => INV_MULTIPLICAND(17),
		INC => OPA(18),IND => INV_MULTIPLICAND(18),
		TWOPOS => INT_MULTIPLIER(56),TWONEG => INT_MULTIPLIER(57),ONEPOS => INT_MULTIPLIER(58),ONENEG => INT_MULTIPLIER(59),
		PPBIT => SUMMAND(506)
	);
PPM_480:PP_MIDDLE
	port map
	(
		INA => OPA(18),INB => INV_MULTIPLICAND(18),
		INC => OPA(19),IND => INV_MULTIPLICAND(19),
		TWOPOS => INT_MULTIPLIER(56),TWONEG => INT_MULTIPLIER(57),ONEPOS => INT_MULTIPLIER(58),ONENEG => INT_MULTIPLIER(59),
		PPBIT => SUMMAND(517)
	);
PPM_481:PP_MIDDLE
	port map
	(
		INA => OPA(19),INB => INV_MULTIPLICAND(19),
		INC => OPA(20),IND => INV_MULTIPLICAND(20),
		TWOPOS => INT_MULTIPLIER(56),TWONEG => INT_MULTIPLIER(57),ONEPOS => INT_MULTIPLIER(58),ONENEG => INT_MULTIPLIER(59),
		PPBIT => SUMMAND(527)
	);
PPM_482:PP_MIDDLE
	port map
	(
		INA => OPA(20),INB => INV_MULTIPLICAND(20),
		INC => OPA(21),IND => INV_MULTIPLICAND(21),
		TWOPOS => INT_MULTIPLIER(56),TWONEG => INT_MULTIPLIER(57),ONEPOS => INT_MULTIPLIER(58),ONENEG => INT_MULTIPLIER(59),
		PPBIT => SUMMAND(537)
	);
PPM_483:PP_MIDDLE
	port map
	(
		INA => OPA(21),INB => INV_MULTIPLICAND(21),
		INC => OPA(22),IND => INV_MULTIPLICAND(22),
		TWOPOS => INT_MULTIPLIER(56),TWONEG => INT_MULTIPLIER(57),ONEPOS => INT_MULTIPLIER(58),ONENEG => INT_MULTIPLIER(59),
		PPBIT => SUMMAND(546)
	);
PPM_484:PP_MIDDLE
	port map
	(
		INA => OPA(22),INB => INV_MULTIPLICAND(22),
		INC => OPA(23),IND => INV_MULTIPLICAND(23),
		TWOPOS => INT_MULTIPLIER(56),TWONEG => INT_MULTIPLIER(57),ONEPOS => INT_MULTIPLIER(58),ONENEG => INT_MULTIPLIER(59),
		PPBIT => SUMMAND(555)
	);
PPM_485:PP_MIDDLE
	port map
	(
		INA => OPA(23),INB => INV_MULTIPLICAND(23),
		INC => OPA(24),IND => INV_MULTIPLICAND(24),
		TWOPOS => INT_MULTIPLIER(56),TWONEG => INT_MULTIPLIER(57),ONEPOS => INT_MULTIPLIER(58),ONENEG => INT_MULTIPLIER(59),
		PPBIT => SUMMAND(563)
	);
PPM_486:PP_MIDDLE
	port map
	(
		INA => OPA(24),INB => INV_MULTIPLICAND(24),
		INC => OPA(25),IND => INV_MULTIPLICAND(25),
		TWOPOS => INT_MULTIPLIER(56),TWONEG => INT_MULTIPLIER(57),ONEPOS => INT_MULTIPLIER(58),ONENEG => INT_MULTIPLIER(59),
		PPBIT => SUMMAND(571)
	);
PPM_487:PP_MIDDLE
	port map
	(
		INA => OPA(25),INB => INV_MULTIPLICAND(25),
		INC => OPA(26),IND => INV_MULTIPLICAND(26),
		TWOPOS => INT_MULTIPLIER(56),TWONEG => INT_MULTIPLIER(57),ONEPOS => INT_MULTIPLIER(58),ONENEG => INT_MULTIPLIER(59),
		PPBIT => SUMMAND(578)
	);
PPM_488:PP_MIDDLE
	port map
	(
		INA => OPA(26),INB => INV_MULTIPLICAND(26),
		INC => OPA(27),IND => INV_MULTIPLICAND(27),
		TWOPOS => INT_MULTIPLIER(56),TWONEG => INT_MULTIPLIER(57),ONEPOS => INT_MULTIPLIER(58),ONENEG => INT_MULTIPLIER(59),
		PPBIT => SUMMAND(585)
	);
PPM_489:PP_MIDDLE
	port map
	(
		INA => OPA(27),INB => INV_MULTIPLICAND(27),
		INC => OPA(28),IND => INV_MULTIPLICAND(28),
		TWOPOS => INT_MULTIPLIER(56),TWONEG => INT_MULTIPLIER(57),ONEPOS => INT_MULTIPLIER(58),ONENEG => INT_MULTIPLIER(59),
		PPBIT => SUMMAND(591)
	);
PPM_490:PP_MIDDLE
	port map
	(
		INA => OPA(28),INB => INV_MULTIPLICAND(28),
		INC => OPA(29),IND => INV_MULTIPLICAND(29),
		TWOPOS => INT_MULTIPLIER(56),TWONEG => INT_MULTIPLIER(57),ONEPOS => INT_MULTIPLIER(58),ONENEG => INT_MULTIPLIER(59),
		PPBIT => SUMMAND(597)
	);
PPM_491:PP_MIDDLE
	port map
	(
		INA => OPA(29),INB => INV_MULTIPLICAND(29),
		INC => OPA(30),IND => INV_MULTIPLICAND(30),
		TWOPOS => INT_MULTIPLIER(56),TWONEG => INT_MULTIPLIER(57),ONEPOS => INT_MULTIPLIER(58),ONENEG => INT_MULTIPLIER(59),
		PPBIT => SUMMAND(602)
	);
PPM_492:PP_MIDDLE
	port map
	(
		INA => OPA(30),INB => INV_MULTIPLICAND(30),
		INC => OPA(31),IND => INV_MULTIPLICAND(31),
		TWOPOS => INT_MULTIPLIER(56),TWONEG => INT_MULTIPLIER(57),ONEPOS => INT_MULTIPLIER(58),ONENEG => INT_MULTIPLIER(59),
		PPBIT => SUMMAND(607)
	);
PPM_493:PP_MIDDLE
	port map
	(
		INA => OPA(31),INB => INV_MULTIPLICAND(31),
		INC => OPA(32),IND => INV_MULTIPLICAND(32),
		TWOPOS => INT_MULTIPLIER(56),TWONEG => INT_MULTIPLIER(57),ONEPOS => INT_MULTIPLIER(58),ONENEG => INT_MULTIPLIER(59),
		PPBIT => SUMMAND(611)
	);
PPM_494:PP_MIDDLE
	port map
	(
		INA => OPA(32),INB => INV_MULTIPLICAND(32),
		INC => OPA(33),IND => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(56),TWONEG => INT_MULTIPLIER(57),ONEPOS => INT_MULTIPLIER(58),ONENEG => INT_MULTIPLIER(59),
		PPBIT => SUMMAND(614)
	);
SUMMAND(615) <= LOGIC_ONE;
PPH_14:PP_HIGH
	port map
	(
		INA => OPA(33),INB => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(56),TWONEG => INT_MULTIPLIER(57),ONEPOS => INT_MULTIPLIER(58),ONENEG => INT_MULTIPLIER(59),
		PPBIT => SUMMAND(618)
	);
-- Begin partial product 15
-- Begin decoder block 16
DEC_15:DECODER -- Decoder of multiplier operand
	port map
	(
		INA => OPB(29),INB => OPB(30),INC => OPB(31),
		TWOPOS => INT_MULTIPLIER(60),TWONEG => INT_MULTIPLIER(61),ONEPOS => INT_MULTIPLIER(62),ONENEG => INT_MULTIPLIER(63)
	);
-- End decoder block 16
-- Begin partial product 16
PPL_15:PP_LOW
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		TWONEG => INT_MULTIPLIER(61),ONEPOS => INT_MULTIPLIER(62),ONENEG => INT_MULTIPLIER(63),
		PPBIT => SUMMAND(270)
	);
RGATE_15:R_GATE
	port map
	(
		INA => OPB(29),INB => OPB(30),INC => OPB(31),
		PPBIT => SUMMAND(271)
	);
PPM_495:PP_MIDDLE
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		INC => OPA(1),IND => INV_MULTIPLICAND(1),
		TWOPOS => INT_MULTIPLIER(60),TWONEG => INT_MULTIPLIER(61),ONEPOS => INT_MULTIPLIER(62),ONENEG => INT_MULTIPLIER(63),
		PPBIT => SUMMAND(287)
	);
PPM_496:PP_MIDDLE
	port map
	(
		INA => OPA(1),INB => INV_MULTIPLICAND(1),
		INC => OPA(2),IND => INV_MULTIPLICAND(2),
		TWOPOS => INT_MULTIPLIER(60),TWONEG => INT_MULTIPLIER(61),ONEPOS => INT_MULTIPLIER(62),ONENEG => INT_MULTIPLIER(63),
		PPBIT => SUMMAND(303)
	);
PPM_497:PP_MIDDLE
	port map
	(
		INA => OPA(2),INB => INV_MULTIPLICAND(2),
		INC => OPA(3),IND => INV_MULTIPLICAND(3),
		TWOPOS => INT_MULTIPLIER(60),TWONEG => INT_MULTIPLIER(61),ONEPOS => INT_MULTIPLIER(62),ONENEG => INT_MULTIPLIER(63),
		PPBIT => SUMMAND(321)
	);
PPM_498:PP_MIDDLE
	port map
	(
		INA => OPA(3),INB => INV_MULTIPLICAND(3),
		INC => OPA(4),IND => INV_MULTIPLICAND(4),
		TWOPOS => INT_MULTIPLIER(60),TWONEG => INT_MULTIPLIER(61),ONEPOS => INT_MULTIPLIER(62),ONENEG => INT_MULTIPLIER(63),
		PPBIT => SUMMAND(339)
	);
PPM_499:PP_MIDDLE
	port map
	(
		INA => OPA(4),INB => INV_MULTIPLICAND(4),
		INC => OPA(5),IND => INV_MULTIPLICAND(5),
		TWOPOS => INT_MULTIPLIER(60),TWONEG => INT_MULTIPLIER(61),ONEPOS => INT_MULTIPLIER(62),ONENEG => INT_MULTIPLIER(63),
		PPBIT => SUMMAND(356)
	);
PPM_500:PP_MIDDLE
	port map
	(
		INA => OPA(5),INB => INV_MULTIPLICAND(5),
		INC => OPA(6),IND => INV_MULTIPLICAND(6),
		TWOPOS => INT_MULTIPLIER(60),TWONEG => INT_MULTIPLIER(61),ONEPOS => INT_MULTIPLIER(62),ONENEG => INT_MULTIPLIER(63),
		PPBIT => SUMMAND(372)
	);
PPM_501:PP_MIDDLE
	port map
	(
		INA => OPA(6),INB => INV_MULTIPLICAND(6),
		INC => OPA(7),IND => INV_MULTIPLICAND(7),
		TWOPOS => INT_MULTIPLIER(60),TWONEG => INT_MULTIPLIER(61),ONEPOS => INT_MULTIPLIER(62),ONENEG => INT_MULTIPLIER(63),
		PPBIT => SUMMAND(388)
	);
PPM_502:PP_MIDDLE
	port map
	(
		INA => OPA(7),INB => INV_MULTIPLICAND(7),
		INC => OPA(8),IND => INV_MULTIPLICAND(8),
		TWOPOS => INT_MULTIPLIER(60),TWONEG => INT_MULTIPLIER(61),ONEPOS => INT_MULTIPLIER(62),ONENEG => INT_MULTIPLIER(63),
		PPBIT => SUMMAND(403)
	);
PPM_503:PP_MIDDLE
	port map
	(
		INA => OPA(8),INB => INV_MULTIPLICAND(8),
		INC => OPA(9),IND => INV_MULTIPLICAND(9),
		TWOPOS => INT_MULTIPLIER(60),TWONEG => INT_MULTIPLIER(61),ONEPOS => INT_MULTIPLIER(62),ONENEG => INT_MULTIPLIER(63),
		PPBIT => SUMMAND(418)
	);
PPM_504:PP_MIDDLE
	port map
	(
		INA => OPA(9),INB => INV_MULTIPLICAND(9),
		INC => OPA(10),IND => INV_MULTIPLICAND(10),
		TWOPOS => INT_MULTIPLIER(60),TWONEG => INT_MULTIPLIER(61),ONEPOS => INT_MULTIPLIER(62),ONENEG => INT_MULTIPLIER(63),
		PPBIT => SUMMAND(432)
	);
PPM_505:PP_MIDDLE
	port map
	(
		INA => OPA(10),INB => INV_MULTIPLICAND(10),
		INC => OPA(11),IND => INV_MULTIPLICAND(11),
		TWOPOS => INT_MULTIPLIER(60),TWONEG => INT_MULTIPLIER(61),ONEPOS => INT_MULTIPLIER(62),ONENEG => INT_MULTIPLIER(63),
		PPBIT => SUMMAND(446)
	);
PPM_506:PP_MIDDLE
	port map
	(
		INA => OPA(11),INB => INV_MULTIPLICAND(11),
		INC => OPA(12),IND => INV_MULTIPLICAND(12),
		TWOPOS => INT_MULTIPLIER(60),TWONEG => INT_MULTIPLIER(61),ONEPOS => INT_MULTIPLIER(62),ONENEG => INT_MULTIPLIER(63),
		PPBIT => SUMMAND(459)
	);
PPM_507:PP_MIDDLE
	port map
	(
		INA => OPA(12),INB => INV_MULTIPLICAND(12),
		INC => OPA(13),IND => INV_MULTIPLICAND(13),
		TWOPOS => INT_MULTIPLIER(60),TWONEG => INT_MULTIPLIER(61),ONEPOS => INT_MULTIPLIER(62),ONENEG => INT_MULTIPLIER(63),
		PPBIT => SUMMAND(472)
	);
PPM_508:PP_MIDDLE
	port map
	(
		INA => OPA(13),INB => INV_MULTIPLICAND(13),
		INC => OPA(14),IND => INV_MULTIPLICAND(14),
		TWOPOS => INT_MULTIPLIER(60),TWONEG => INT_MULTIPLIER(61),ONEPOS => INT_MULTIPLIER(62),ONENEG => INT_MULTIPLIER(63),
		PPBIT => SUMMAND(484)
	);
PPM_509:PP_MIDDLE
	port map
	(
		INA => OPA(14),INB => INV_MULTIPLICAND(14),
		INC => OPA(15),IND => INV_MULTIPLICAND(15),
		TWOPOS => INT_MULTIPLIER(60),TWONEG => INT_MULTIPLIER(61),ONEPOS => INT_MULTIPLIER(62),ONENEG => INT_MULTIPLIER(63),
		PPBIT => SUMMAND(496)
	);
PPM_510:PP_MIDDLE
	port map
	(
		INA => OPA(15),INB => INV_MULTIPLICAND(15),
		INC => OPA(16),IND => INV_MULTIPLICAND(16),
		TWOPOS => INT_MULTIPLIER(60),TWONEG => INT_MULTIPLIER(61),ONEPOS => INT_MULTIPLIER(62),ONENEG => INT_MULTIPLIER(63),
		PPBIT => SUMMAND(507)
	);
PPM_511:PP_MIDDLE
	port map
	(
		INA => OPA(16),INB => INV_MULTIPLICAND(16),
		INC => OPA(17),IND => INV_MULTIPLICAND(17),
		TWOPOS => INT_MULTIPLIER(60),TWONEG => INT_MULTIPLIER(61),ONEPOS => INT_MULTIPLIER(62),ONENEG => INT_MULTIPLIER(63),
		PPBIT => SUMMAND(518)
	);
PPM_512:PP_MIDDLE
	port map
	(
		INA => OPA(17),INB => INV_MULTIPLICAND(17),
		INC => OPA(18),IND => INV_MULTIPLICAND(18),
		TWOPOS => INT_MULTIPLIER(60),TWONEG => INT_MULTIPLIER(61),ONEPOS => INT_MULTIPLIER(62),ONENEG => INT_MULTIPLIER(63),
		PPBIT => SUMMAND(528)
	);
PPM_513:PP_MIDDLE
	port map
	(
		INA => OPA(18),INB => INV_MULTIPLICAND(18),
		INC => OPA(19),IND => INV_MULTIPLICAND(19),
		TWOPOS => INT_MULTIPLIER(60),TWONEG => INT_MULTIPLIER(61),ONEPOS => INT_MULTIPLIER(62),ONENEG => INT_MULTIPLIER(63),
		PPBIT => SUMMAND(538)
	);
PPM_514:PP_MIDDLE
	port map
	(
		INA => OPA(19),INB => INV_MULTIPLICAND(19),
		INC => OPA(20),IND => INV_MULTIPLICAND(20),
		TWOPOS => INT_MULTIPLIER(60),TWONEG => INT_MULTIPLIER(61),ONEPOS => INT_MULTIPLIER(62),ONENEG => INT_MULTIPLIER(63),
		PPBIT => SUMMAND(547)
	);
PPM_515:PP_MIDDLE
	port map
	(
		INA => OPA(20),INB => INV_MULTIPLICAND(20),
		INC => OPA(21),IND => INV_MULTIPLICAND(21),
		TWOPOS => INT_MULTIPLIER(60),TWONEG => INT_MULTIPLIER(61),ONEPOS => INT_MULTIPLIER(62),ONENEG => INT_MULTIPLIER(63),
		PPBIT => SUMMAND(556)
	);
PPM_516:PP_MIDDLE
	port map
	(
		INA => OPA(21),INB => INV_MULTIPLICAND(21),
		INC => OPA(22),IND => INV_MULTIPLICAND(22),
		TWOPOS => INT_MULTIPLIER(60),TWONEG => INT_MULTIPLIER(61),ONEPOS => INT_MULTIPLIER(62),ONENEG => INT_MULTIPLIER(63),
		PPBIT => SUMMAND(564)
	);
PPM_517:PP_MIDDLE
	port map
	(
		INA => OPA(22),INB => INV_MULTIPLICAND(22),
		INC => OPA(23),IND => INV_MULTIPLICAND(23),
		TWOPOS => INT_MULTIPLIER(60),TWONEG => INT_MULTIPLIER(61),ONEPOS => INT_MULTIPLIER(62),ONENEG => INT_MULTIPLIER(63),
		PPBIT => SUMMAND(572)
	);
PPM_518:PP_MIDDLE
	port map
	(
		INA => OPA(23),INB => INV_MULTIPLICAND(23),
		INC => OPA(24),IND => INV_MULTIPLICAND(24),
		TWOPOS => INT_MULTIPLIER(60),TWONEG => INT_MULTIPLIER(61),ONEPOS => INT_MULTIPLIER(62),ONENEG => INT_MULTIPLIER(63),
		PPBIT => SUMMAND(579)
	);
PPM_519:PP_MIDDLE
	port map
	(
		INA => OPA(24),INB => INV_MULTIPLICAND(24),
		INC => OPA(25),IND => INV_MULTIPLICAND(25),
		TWOPOS => INT_MULTIPLIER(60),TWONEG => INT_MULTIPLIER(61),ONEPOS => INT_MULTIPLIER(62),ONENEG => INT_MULTIPLIER(63),
		PPBIT => SUMMAND(586)
	);
PPM_520:PP_MIDDLE
	port map
	(
		INA => OPA(25),INB => INV_MULTIPLICAND(25),
		INC => OPA(26),IND => INV_MULTIPLICAND(26),
		TWOPOS => INT_MULTIPLIER(60),TWONEG => INT_MULTIPLIER(61),ONEPOS => INT_MULTIPLIER(62),ONENEG => INT_MULTIPLIER(63),
		PPBIT => SUMMAND(592)
	);
PPM_521:PP_MIDDLE
	port map
	(
		INA => OPA(26),INB => INV_MULTIPLICAND(26),
		INC => OPA(27),IND => INV_MULTIPLICAND(27),
		TWOPOS => INT_MULTIPLIER(60),TWONEG => INT_MULTIPLIER(61),ONEPOS => INT_MULTIPLIER(62),ONENEG => INT_MULTIPLIER(63),
		PPBIT => SUMMAND(598)
	);
PPM_522:PP_MIDDLE
	port map
	(
		INA => OPA(27),INB => INV_MULTIPLICAND(27),
		INC => OPA(28),IND => INV_MULTIPLICAND(28),
		TWOPOS => INT_MULTIPLIER(60),TWONEG => INT_MULTIPLIER(61),ONEPOS => INT_MULTIPLIER(62),ONENEG => INT_MULTIPLIER(63),
		PPBIT => SUMMAND(603)
	);
PPM_523:PP_MIDDLE
	port map
	(
		INA => OPA(28),INB => INV_MULTIPLICAND(28),
		INC => OPA(29),IND => INV_MULTIPLICAND(29),
		TWOPOS => INT_MULTIPLIER(60),TWONEG => INT_MULTIPLIER(61),ONEPOS => INT_MULTIPLIER(62),ONENEG => INT_MULTIPLIER(63),
		PPBIT => SUMMAND(608)
	);
PPM_524:PP_MIDDLE
	port map
	(
		INA => OPA(29),INB => INV_MULTIPLICAND(29),
		INC => OPA(30),IND => INV_MULTIPLICAND(30),
		TWOPOS => INT_MULTIPLIER(60),TWONEG => INT_MULTIPLIER(61),ONEPOS => INT_MULTIPLIER(62),ONENEG => INT_MULTIPLIER(63),
		PPBIT => SUMMAND(612)
	);
PPM_525:PP_MIDDLE
	port map
	(
		INA => OPA(30),INB => INV_MULTIPLICAND(30),
		INC => OPA(31),IND => INV_MULTIPLICAND(31),
		TWOPOS => INT_MULTIPLIER(60),TWONEG => INT_MULTIPLIER(61),ONEPOS => INT_MULTIPLIER(62),ONENEG => INT_MULTIPLIER(63),
		PPBIT => SUMMAND(616)
	);
PPM_526:PP_MIDDLE
	port map
	(
		INA => OPA(31),INB => INV_MULTIPLICAND(31),
		INC => OPA(32),IND => INV_MULTIPLICAND(32),
		TWOPOS => INT_MULTIPLIER(60),TWONEG => INT_MULTIPLIER(61),ONEPOS => INT_MULTIPLIER(62),ONENEG => INT_MULTIPLIER(63),
		PPBIT => SUMMAND(619)
	);
PPM_527:PP_MIDDLE
	port map
	(
		INA => OPA(32),INB => INV_MULTIPLICAND(32),
		INC => OPA(33),IND => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(60),TWONEG => INT_MULTIPLIER(61),ONEPOS => INT_MULTIPLIER(62),ONENEG => INT_MULTIPLIER(63),
		PPBIT => SUMMAND(621)
	);
SUMMAND(622) <= LOGIC_ONE;
PPH_15:PP_HIGH
	port map
	(
		INA => OPA(33),INB => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(60),TWONEG => INT_MULTIPLIER(61),ONEPOS => INT_MULTIPLIER(62),ONENEG => INT_MULTIPLIER(63),
		PPBIT => SUMMAND(624)
	);
-- Begin partial product 16
-- Begin decoder block 17
DEC_16:DECODER -- Decoder of multiplier operand
	port map
	(
		INA => OPB(31),INB => OPB(32),INC => OPB(33),
		TWOPOS => INT_MULTIPLIER(64),TWONEG => INT_MULTIPLIER(65),ONEPOS => INT_MULTIPLIER(66),ONENEG => INT_MULTIPLIER(67)
	);
-- End decoder block 17
-- Begin partial product 17
PPL_16:PP_LOW
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		TWONEG => INT_MULTIPLIER(65),ONEPOS => INT_MULTIPLIER(66),ONENEG => INT_MULTIPLIER(67),
		PPBIT => SUMMAND(304)
	);
RGATE_16:R_GATE
	port map
	(
		INA => OPB(31),INB => OPB(32),INC => OPB(33),
		PPBIT => SUMMAND(305)
	);
PPM_528:PP_MIDDLE
	port map
	(
		INA => OPA(0),INB => INV_MULTIPLICAND(0),
		INC => OPA(1),IND => INV_MULTIPLICAND(1),
		TWOPOS => INT_MULTIPLIER(64),TWONEG => INT_MULTIPLIER(65),ONEPOS => INT_MULTIPLIER(66),ONENEG => INT_MULTIPLIER(67),
		PPBIT => SUMMAND(322)
	);
PPM_529:PP_MIDDLE
	port map
	(
		INA => OPA(1),INB => INV_MULTIPLICAND(1),
		INC => OPA(2),IND => INV_MULTIPLICAND(2),
		TWOPOS => INT_MULTIPLIER(64),TWONEG => INT_MULTIPLIER(65),ONEPOS => INT_MULTIPLIER(66),ONENEG => INT_MULTIPLIER(67),
		PPBIT => SUMMAND(340)
	);
PPM_530:PP_MIDDLE
	port map
	(
		INA => OPA(2),INB => INV_MULTIPLICAND(2),
		INC => OPA(3),IND => INV_MULTIPLICAND(3),
		TWOPOS => INT_MULTIPLIER(64),TWONEG => INT_MULTIPLIER(65),ONEPOS => INT_MULTIPLIER(66),ONENEG => INT_MULTIPLIER(67),
		PPBIT => SUMMAND(357)
	);
PPM_531:PP_MIDDLE
	port map
	(
		INA => OPA(3),INB => INV_MULTIPLICAND(3),
		INC => OPA(4),IND => INV_MULTIPLICAND(4),
		TWOPOS => INT_MULTIPLIER(64),TWONEG => INT_MULTIPLIER(65),ONEPOS => INT_MULTIPLIER(66),ONENEG => INT_MULTIPLIER(67),
		PPBIT => SUMMAND(373)
	);
PPM_532:PP_MIDDLE
	port map
	(
		INA => OPA(4),INB => INV_MULTIPLICAND(4),
		INC => OPA(5),IND => INV_MULTIPLICAND(5),
		TWOPOS => INT_MULTIPLIER(64),TWONEG => INT_MULTIPLIER(65),ONEPOS => INT_MULTIPLIER(66),ONENEG => INT_MULTIPLIER(67),
		PPBIT => SUMMAND(389)
	);
PPM_533:PP_MIDDLE
	port map
	(
		INA => OPA(5),INB => INV_MULTIPLICAND(5),
		INC => OPA(6),IND => INV_MULTIPLICAND(6),
		TWOPOS => INT_MULTIPLIER(64),TWONEG => INT_MULTIPLIER(65),ONEPOS => INT_MULTIPLIER(66),ONENEG => INT_MULTIPLIER(67),
		PPBIT => SUMMAND(404)
	);
PPM_534:PP_MIDDLE
	port map
	(
		INA => OPA(6),INB => INV_MULTIPLICAND(6),
		INC => OPA(7),IND => INV_MULTIPLICAND(7),
		TWOPOS => INT_MULTIPLIER(64),TWONEG => INT_MULTIPLIER(65),ONEPOS => INT_MULTIPLIER(66),ONENEG => INT_MULTIPLIER(67),
		PPBIT => SUMMAND(419)
	);
PPM_535:PP_MIDDLE
	port map
	(
		INA => OPA(7),INB => INV_MULTIPLICAND(7),
		INC => OPA(8),IND => INV_MULTIPLICAND(8),
		TWOPOS => INT_MULTIPLIER(64),TWONEG => INT_MULTIPLIER(65),ONEPOS => INT_MULTIPLIER(66),ONENEG => INT_MULTIPLIER(67),
		PPBIT => SUMMAND(433)
	);
PPM_536:PP_MIDDLE
	port map
	(
		INA => OPA(8),INB => INV_MULTIPLICAND(8),
		INC => OPA(9),IND => INV_MULTIPLICAND(9),
		TWOPOS => INT_MULTIPLIER(64),TWONEG => INT_MULTIPLIER(65),ONEPOS => INT_MULTIPLIER(66),ONENEG => INT_MULTIPLIER(67),
		PPBIT => SUMMAND(447)
	);
PPM_537:PP_MIDDLE
	port map
	(
		INA => OPA(9),INB => INV_MULTIPLICAND(9),
		INC => OPA(10),IND => INV_MULTIPLICAND(10),
		TWOPOS => INT_MULTIPLIER(64),TWONEG => INT_MULTIPLIER(65),ONEPOS => INT_MULTIPLIER(66),ONENEG => INT_MULTIPLIER(67),
		PPBIT => SUMMAND(460)
	);
PPM_538:PP_MIDDLE
	port map
	(
		INA => OPA(10),INB => INV_MULTIPLICAND(10),
		INC => OPA(11),IND => INV_MULTIPLICAND(11),
		TWOPOS => INT_MULTIPLIER(64),TWONEG => INT_MULTIPLIER(65),ONEPOS => INT_MULTIPLIER(66),ONENEG => INT_MULTIPLIER(67),
		PPBIT => SUMMAND(473)
	);
PPM_539:PP_MIDDLE
	port map
	(
		INA => OPA(11),INB => INV_MULTIPLICAND(11),
		INC => OPA(12),IND => INV_MULTIPLICAND(12),
		TWOPOS => INT_MULTIPLIER(64),TWONEG => INT_MULTIPLIER(65),ONEPOS => INT_MULTIPLIER(66),ONENEG => INT_MULTIPLIER(67),
		PPBIT => SUMMAND(485)
	);
PPM_540:PP_MIDDLE
	port map
	(
		INA => OPA(12),INB => INV_MULTIPLICAND(12),
		INC => OPA(13),IND => INV_MULTIPLICAND(13),
		TWOPOS => INT_MULTIPLIER(64),TWONEG => INT_MULTIPLIER(65),ONEPOS => INT_MULTIPLIER(66),ONENEG => INT_MULTIPLIER(67),
		PPBIT => SUMMAND(497)
	);
PPM_541:PP_MIDDLE
	port map
	(
		INA => OPA(13),INB => INV_MULTIPLICAND(13),
		INC => OPA(14),IND => INV_MULTIPLICAND(14),
		TWOPOS => INT_MULTIPLIER(64),TWONEG => INT_MULTIPLIER(65),ONEPOS => INT_MULTIPLIER(66),ONENEG => INT_MULTIPLIER(67),
		PPBIT => SUMMAND(508)
	);
PPM_542:PP_MIDDLE
	port map
	(
		INA => OPA(14),INB => INV_MULTIPLICAND(14),
		INC => OPA(15),IND => INV_MULTIPLICAND(15),
		TWOPOS => INT_MULTIPLIER(64),TWONEG => INT_MULTIPLIER(65),ONEPOS => INT_MULTIPLIER(66),ONENEG => INT_MULTIPLIER(67),
		PPBIT => SUMMAND(519)
	);
PPM_543:PP_MIDDLE
	port map
	(
		INA => OPA(15),INB => INV_MULTIPLICAND(15),
		INC => OPA(16),IND => INV_MULTIPLICAND(16),
		TWOPOS => INT_MULTIPLIER(64),TWONEG => INT_MULTIPLIER(65),ONEPOS => INT_MULTIPLIER(66),ONENEG => INT_MULTIPLIER(67),
		PPBIT => SUMMAND(529)
	);
PPM_544:PP_MIDDLE
	port map
	(
		INA => OPA(16),INB => INV_MULTIPLICAND(16),
		INC => OPA(17),IND => INV_MULTIPLICAND(17),
		TWOPOS => INT_MULTIPLIER(64),TWONEG => INT_MULTIPLIER(65),ONEPOS => INT_MULTIPLIER(66),ONENEG => INT_MULTIPLIER(67),
		PPBIT => SUMMAND(539)
	);
PPM_545:PP_MIDDLE
	port map
	(
		INA => OPA(17),INB => INV_MULTIPLICAND(17),
		INC => OPA(18),IND => INV_MULTIPLICAND(18),
		TWOPOS => INT_MULTIPLIER(64),TWONEG => INT_MULTIPLIER(65),ONEPOS => INT_MULTIPLIER(66),ONENEG => INT_MULTIPLIER(67),
		PPBIT => SUMMAND(548)
	);
PPM_546:PP_MIDDLE
	port map
	(
		INA => OPA(18),INB => INV_MULTIPLICAND(18),
		INC => OPA(19),IND => INV_MULTIPLICAND(19),
		TWOPOS => INT_MULTIPLIER(64),TWONEG => INT_MULTIPLIER(65),ONEPOS => INT_MULTIPLIER(66),ONENEG => INT_MULTIPLIER(67),
		PPBIT => SUMMAND(557)
	);
PPM_547:PP_MIDDLE
	port map
	(
		INA => OPA(19),INB => INV_MULTIPLICAND(19),
		INC => OPA(20),IND => INV_MULTIPLICAND(20),
		TWOPOS => INT_MULTIPLIER(64),TWONEG => INT_MULTIPLIER(65),ONEPOS => INT_MULTIPLIER(66),ONENEG => INT_MULTIPLIER(67),
		PPBIT => SUMMAND(565)
	);
PPM_548:PP_MIDDLE
	port map
	(
		INA => OPA(20),INB => INV_MULTIPLICAND(20),
		INC => OPA(21),IND => INV_MULTIPLICAND(21),
		TWOPOS => INT_MULTIPLIER(64),TWONEG => INT_MULTIPLIER(65),ONEPOS => INT_MULTIPLIER(66),ONENEG => INT_MULTIPLIER(67),
		PPBIT => SUMMAND(573)
	);
PPM_549:PP_MIDDLE
	port map
	(
		INA => OPA(21),INB => INV_MULTIPLICAND(21),
		INC => OPA(22),IND => INV_MULTIPLICAND(22),
		TWOPOS => INT_MULTIPLIER(64),TWONEG => INT_MULTIPLIER(65),ONEPOS => INT_MULTIPLIER(66),ONENEG => INT_MULTIPLIER(67),
		PPBIT => SUMMAND(580)
	);
PPM_550:PP_MIDDLE
	port map
	(
		INA => OPA(22),INB => INV_MULTIPLICAND(22),
		INC => OPA(23),IND => INV_MULTIPLICAND(23),
		TWOPOS => INT_MULTIPLIER(64),TWONEG => INT_MULTIPLIER(65),ONEPOS => INT_MULTIPLIER(66),ONENEG => INT_MULTIPLIER(67),
		PPBIT => SUMMAND(587)
	);
PPM_551:PP_MIDDLE
	port map
	(
		INA => OPA(23),INB => INV_MULTIPLICAND(23),
		INC => OPA(24),IND => INV_MULTIPLICAND(24),
		TWOPOS => INT_MULTIPLIER(64),TWONEG => INT_MULTIPLIER(65),ONEPOS => INT_MULTIPLIER(66),ONENEG => INT_MULTIPLIER(67),
		PPBIT => SUMMAND(593)
	);
PPM_552:PP_MIDDLE
	port map
	(
		INA => OPA(24),INB => INV_MULTIPLICAND(24),
		INC => OPA(25),IND => INV_MULTIPLICAND(25),
		TWOPOS => INT_MULTIPLIER(64),TWONEG => INT_MULTIPLIER(65),ONEPOS => INT_MULTIPLIER(66),ONENEG => INT_MULTIPLIER(67),
		PPBIT => SUMMAND(599)
	);
PPM_553:PP_MIDDLE
	port map
	(
		INA => OPA(25),INB => INV_MULTIPLICAND(25),
		INC => OPA(26),IND => INV_MULTIPLICAND(26),
		TWOPOS => INT_MULTIPLIER(64),TWONEG => INT_MULTIPLIER(65),ONEPOS => INT_MULTIPLIER(66),ONENEG => INT_MULTIPLIER(67),
		PPBIT => SUMMAND(604)
	);
PPM_554:PP_MIDDLE
	port map
	(
		INA => OPA(26),INB => INV_MULTIPLICAND(26),
		INC => OPA(27),IND => INV_MULTIPLICAND(27),
		TWOPOS => INT_MULTIPLIER(64),TWONEG => INT_MULTIPLIER(65),ONEPOS => INT_MULTIPLIER(66),ONENEG => INT_MULTIPLIER(67),
		PPBIT => SUMMAND(609)
	);
PPM_555:PP_MIDDLE
	port map
	(
		INA => OPA(27),INB => INV_MULTIPLICAND(27),
		INC => OPA(28),IND => INV_MULTIPLICAND(28),
		TWOPOS => INT_MULTIPLIER(64),TWONEG => INT_MULTIPLIER(65),ONEPOS => INT_MULTIPLIER(66),ONENEG => INT_MULTIPLIER(67),
		PPBIT => SUMMAND(613)
	);
PPM_556:PP_MIDDLE
	port map
	(
		INA => OPA(28),INB => INV_MULTIPLICAND(28),
		INC => OPA(29),IND => INV_MULTIPLICAND(29),
		TWOPOS => INT_MULTIPLIER(64),TWONEG => INT_MULTIPLIER(65),ONEPOS => INT_MULTIPLIER(66),ONENEG => INT_MULTIPLIER(67),
		PPBIT => SUMMAND(617)
	);
PPM_557:PP_MIDDLE
	port map
	(
		INA => OPA(29),INB => INV_MULTIPLICAND(29),
		INC => OPA(30),IND => INV_MULTIPLICAND(30),
		TWOPOS => INT_MULTIPLIER(64),TWONEG => INT_MULTIPLIER(65),ONEPOS => INT_MULTIPLIER(66),ONENEG => INT_MULTIPLIER(67),
		PPBIT => SUMMAND(620)
	);
PPM_558:PP_MIDDLE
	port map
	(
		INA => OPA(30),INB => INV_MULTIPLICAND(30),
		INC => OPA(31),IND => INV_MULTIPLICAND(31),
		TWOPOS => INT_MULTIPLIER(64),TWONEG => INT_MULTIPLIER(65),ONEPOS => INT_MULTIPLIER(66),ONENEG => INT_MULTIPLIER(67),
		PPBIT => SUMMAND(623)
	);
PPM_559:PP_MIDDLE
	port map
	(
		INA => OPA(31),INB => INV_MULTIPLICAND(31),
		INC => OPA(32),IND => INV_MULTIPLICAND(32),
		TWOPOS => INT_MULTIPLIER(64),TWONEG => INT_MULTIPLIER(65),ONEPOS => INT_MULTIPLIER(66),ONENEG => INT_MULTIPLIER(67),
		PPBIT => SUMMAND(625)
	);
PPM_560:PP_MIDDLE
	port map
	(
		INA => OPA(32),INB => INV_MULTIPLICAND(32),
		INC => OPA(33),IND => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(64),TWONEG => INT_MULTIPLIER(65),ONEPOS => INT_MULTIPLIER(66),ONENEG => INT_MULTIPLIER(67),
		PPBIT => SUMMAND(626)
	);
SUMMAND(627) <= LOGIC_ONE;
PPH_16:PP_HIGH
	port map
	(
		INA => OPA(33),INB => INV_MULTIPLICAND(33),
		TWOPOS => INT_MULTIPLIER(64),TWONEG => INT_MULTIPLIER(65),ONEPOS => INT_MULTIPLIER(66),ONENEG => INT_MULTIPLIER(67),
		PPBIT => SUMMAND(628)
	);
-- Begin partial product 17
end BOOTHCODER;

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.blocks.all;
entity WALLACE_34_34 is
port
(
	SUMMAND: in std_logic_vector(0 to 628);
	CARRY: out std_logic_vector(0 to 65);
	SUM: out std_logic_vector(0 to 66)
);
end WALLACE_34_34;

architecture WALLACE of WALLACE_34_34 is

-- Signals used inside the wallace trees

	signal INT_CARRY: std_logic_vector(0 to 486);
	signal INT_SUM: std_logic_vector(0 to 620);

begin -- netlist

-- Begin WT-branch 1
---- Begin HA stage
HA_0:HALF_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(0), DATA_B => SUMMAND(1), 
		SAVE => SUM(0), CARRY => CARRY(0)
	);
---- End HA stage
-- End WT-branch 1

-- Begin WT-branch 2
---- Begin NO stage
SUM(1) <= SUMMAND(2); -- At Level 1
CARRY(1) <= '0';
---- End NO stage
-- End WT-branch 2

-- Begin WT-branch 3
---- Begin FA stage
FA_0:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(3), DATA_B => SUMMAND(4), DATA_C => SUMMAND(5), 
		SAVE => SUM(2), CARRY => CARRY(2)
	);
---- End FA stage
-- End WT-branch 3

-- Begin WT-branch 4
---- Begin HA stage
HA_1:HALF_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(6), DATA_B => SUMMAND(7), 
		SAVE => SUM(3), CARRY => CARRY(3)
	);
---- End HA stage
-- End WT-branch 4

-- Begin WT-branch 5
---- Begin FA stage
FA_1:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(8), DATA_B => SUMMAND(9), DATA_C => SUMMAND(10), 
		SAVE => INT_SUM(0), CARRY => INT_CARRY(0)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(1) <= SUMMAND(11); -- At Level 1
---- End NO stage
---- Begin HA stage
HA_2:HALF_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(0), DATA_B => INT_SUM(1), 
		SAVE => SUM(4), CARRY => CARRY(4)
	);
---- End HA stage
-- End WT-branch 5

-- Begin WT-branch 6
---- Begin FA stage
FA_2:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(12), DATA_B => SUMMAND(13), DATA_C => SUMMAND(14), 
		SAVE => INT_SUM(2), CARRY => INT_CARRY(1)
	);
---- End FA stage
---- Begin HA stage
HA_3:HALF_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(2), DATA_B => INT_CARRY(0), 
		SAVE => SUM(5), CARRY => CARRY(5)
	);
---- End HA stage
-- End WT-branch 6

-- Begin WT-branch 7
---- Begin FA stage
FA_3:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(15), DATA_B => SUMMAND(16), DATA_C => SUMMAND(17), 
		SAVE => INT_SUM(3), CARRY => INT_CARRY(2)
	);
---- End FA stage
---- Begin HA stage
HA_4:HALF_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(18), DATA_B => SUMMAND(19), 
		SAVE => INT_SUM(4), CARRY => INT_CARRY(3)
	);
---- End HA stage
---- Begin FA stage
FA_4:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(3), DATA_B => INT_SUM(4), DATA_C => INT_CARRY(1), 
		SAVE => SUM(6), CARRY => CARRY(6)
	);
---- End FA stage
-- End WT-branch 7

-- Begin WT-branch 8
---- Begin FA stage
FA_5:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(20), DATA_B => SUMMAND(21), DATA_C => SUMMAND(22), 
		SAVE => INT_SUM(5), CARRY => INT_CARRY(4)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(6) <= SUMMAND(23); -- At Level 1
---- End NO stage
---- Begin FA stage
FA_6:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(5), DATA_B => INT_SUM(6), DATA_C => INT_CARRY(2), 
		SAVE => INT_SUM(7), CARRY => INT_CARRY(5)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(8) <= INT_CARRY(3); -- At Level 2
---- End NO stage
---- Begin HA stage
HA_5:HALF_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(7), DATA_B => INT_SUM(8), 
		SAVE => SUM(7), CARRY => CARRY(7)
	);
---- End HA stage
-- End WT-branch 8

-- Begin WT-branch 9
---- Begin FA stage
FA_7:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(24), DATA_B => SUMMAND(25), DATA_C => SUMMAND(26), 
		SAVE => INT_SUM(9), CARRY => INT_CARRY(6)
	);
---- End FA stage
---- Begin FA stage
FA_8:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(27), DATA_B => SUMMAND(28), DATA_C => SUMMAND(29), 
		SAVE => INT_SUM(10), CARRY => INT_CARRY(7)
	);
---- End FA stage
---- Begin FA stage
FA_9:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(9), DATA_B => INT_SUM(10), DATA_C => INT_CARRY(4), 
		SAVE => INT_SUM(11), CARRY => INT_CARRY(8)
	);
---- End FA stage
---- Begin HA stage
HA_6:HALF_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(11), DATA_B => INT_CARRY(5), 
		SAVE => SUM(8), CARRY => CARRY(8)
	);
---- End HA stage
-- End WT-branch 9

-- Begin WT-branch 10
---- Begin FA stage
FA_10:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(30), DATA_B => SUMMAND(31), DATA_C => SUMMAND(32), 
		SAVE => INT_SUM(12), CARRY => INT_CARRY(9)
	);
---- End FA stage
---- Begin HA stage
HA_7:HALF_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(33), DATA_B => SUMMAND(34), 
		SAVE => INT_SUM(13), CARRY => INT_CARRY(10)
	);
---- End HA stage
---- Begin FA stage
FA_11:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(12), DATA_B => INT_SUM(13), DATA_C => INT_CARRY(6), 
		SAVE => INT_SUM(14), CARRY => INT_CARRY(11)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(15) <= INT_CARRY(7); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_12:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(14), DATA_B => INT_SUM(15), DATA_C => INT_CARRY(8), 
		SAVE => SUM(9), CARRY => CARRY(9)
	);
---- End FA stage
-- End WT-branch 10

-- Begin WT-branch 11
---- Begin FA stage
FA_13:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(35), DATA_B => SUMMAND(36), DATA_C => SUMMAND(37), 
		SAVE => INT_SUM(16), CARRY => INT_CARRY(12)
	);
---- End FA stage
---- Begin FA stage
FA_14:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(38), DATA_B => SUMMAND(39), DATA_C => SUMMAND(40), 
		SAVE => INT_SUM(17), CARRY => INT_CARRY(13)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(18) <= SUMMAND(41); -- At Level 1
---- End NO stage
---- Begin FA stage
FA_15:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(16), DATA_B => INT_SUM(17), DATA_C => INT_SUM(18), 
		SAVE => INT_SUM(19), CARRY => INT_CARRY(14)
	);
---- End FA stage
---- Begin HA stage
HA_8:HALF_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(9), DATA_B => INT_CARRY(10), 
		SAVE => INT_SUM(20), CARRY => INT_CARRY(15)
	);
---- End HA stage
---- Begin FA stage
FA_16:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(19), DATA_B => INT_SUM(20), DATA_C => INT_CARRY(11), 
		SAVE => SUM(10), CARRY => CARRY(10)
	);
---- End FA stage
-- End WT-branch 11

-- Begin WT-branch 12
---- Begin FA stage
FA_17:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(42), DATA_B => SUMMAND(43), DATA_C => SUMMAND(44), 
		SAVE => INT_SUM(21), CARRY => INT_CARRY(16)
	);
---- End FA stage
---- Begin FA stage
FA_18:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(45), DATA_B => SUMMAND(46), DATA_C => SUMMAND(47), 
		SAVE => INT_SUM(22), CARRY => INT_CARRY(17)
	);
---- End FA stage
---- Begin FA stage
FA_19:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(21), DATA_B => INT_SUM(22), DATA_C => INT_CARRY(12), 
		SAVE => INT_SUM(23), CARRY => INT_CARRY(18)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(24) <= INT_CARRY(13); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_20:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(23), DATA_B => INT_SUM(24), DATA_C => INT_CARRY(14), 
		SAVE => INT_SUM(25), CARRY => INT_CARRY(19)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(26) <= INT_CARRY(15); -- At Level 3
---- End NO stage
---- Begin HA stage
HA_9:HALF_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(25), DATA_B => INT_SUM(26), 
		SAVE => SUM(11), CARRY => CARRY(11)
	);
---- End HA stage
-- End WT-branch 12

-- Begin WT-branch 13
---- Begin FA stage
FA_21:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(48), DATA_B => SUMMAND(49), DATA_C => SUMMAND(50), 
		SAVE => INT_SUM(27), CARRY => INT_CARRY(20)
	);
---- End FA stage
---- Begin FA stage
FA_22:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(51), DATA_B => SUMMAND(52), DATA_C => SUMMAND(53), 
		SAVE => INT_SUM(28), CARRY => INT_CARRY(21)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(29) <= SUMMAND(54); -- At Level 1
---- End NO stage
---- Begin NO stage
INT_SUM(30) <= SUMMAND(55); -- At Level 1
---- End NO stage
---- Begin FA stage
FA_23:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(27), DATA_B => INT_SUM(28), DATA_C => INT_SUM(29), 
		SAVE => INT_SUM(31), CARRY => INT_CARRY(22)
	);
---- End FA stage
---- Begin FA stage
FA_24:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(30), DATA_B => INT_CARRY(16), DATA_C => INT_CARRY(17), 
		SAVE => INT_SUM(32), CARRY => INT_CARRY(23)
	);
---- End FA stage
---- Begin FA stage
FA_25:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(31), DATA_B => INT_SUM(32), DATA_C => INT_CARRY(18), 
		SAVE => INT_SUM(33), CARRY => INT_CARRY(24)
	);
---- End FA stage
---- Begin HA stage
HA_10:HALF_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(33), DATA_B => INT_CARRY(19), 
		SAVE => SUM(12), CARRY => CARRY(12)
	);
---- End HA stage
-- End WT-branch 13

-- Begin WT-branch 14
---- Begin FA stage
FA_26:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(56), DATA_B => SUMMAND(57), DATA_C => SUMMAND(58), 
		SAVE => INT_SUM(34), CARRY => INT_CARRY(25)
	);
---- End FA stage
---- Begin FA stage
FA_27:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(59), DATA_B => SUMMAND(60), DATA_C => SUMMAND(61), 
		SAVE => INT_SUM(35), CARRY => INT_CARRY(26)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(36) <= SUMMAND(62); -- At Level 1
---- End NO stage
---- Begin FA stage
FA_28:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(34), DATA_B => INT_SUM(35), DATA_C => INT_SUM(36), 
		SAVE => INT_SUM(37), CARRY => INT_CARRY(27)
	);
---- End FA stage
---- Begin HA stage
HA_11:HALF_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(20), DATA_B => INT_CARRY(21), 
		SAVE => INT_SUM(38), CARRY => INT_CARRY(28)
	);
---- End HA stage
---- Begin FA stage
FA_29:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(37), DATA_B => INT_SUM(38), DATA_C => INT_CARRY(22), 
		SAVE => INT_SUM(39), CARRY => INT_CARRY(29)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(40) <= INT_CARRY(23); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_30:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(39), DATA_B => INT_SUM(40), DATA_C => INT_CARRY(24), 
		SAVE => SUM(13), CARRY => CARRY(13)
	);
---- End FA stage
-- End WT-branch 14

-- Begin WT-branch 15
---- Begin FA stage
FA_31:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(63), DATA_B => SUMMAND(64), DATA_C => SUMMAND(65), 
		SAVE => INT_SUM(41), CARRY => INT_CARRY(30)
	);
---- End FA stage
---- Begin FA stage
FA_32:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(66), DATA_B => SUMMAND(67), DATA_C => SUMMAND(68), 
		SAVE => INT_SUM(42), CARRY => INT_CARRY(31)
	);
---- End FA stage
---- Begin FA stage
FA_33:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(69), DATA_B => SUMMAND(70), DATA_C => SUMMAND(71), 
		SAVE => INT_SUM(43), CARRY => INT_CARRY(32)
	);
---- End FA stage
---- Begin FA stage
FA_34:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(41), DATA_B => INT_SUM(42), DATA_C => INT_SUM(43), 
		SAVE => INT_SUM(44), CARRY => INT_CARRY(33)
	);
---- End FA stage
---- Begin HA stage
HA_12:HALF_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(25), DATA_B => INT_CARRY(26), 
		SAVE => INT_SUM(45), CARRY => INT_CARRY(34)
	);
---- End HA stage
---- Begin FA stage
FA_35:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(44), DATA_B => INT_SUM(45), DATA_C => INT_CARRY(27), 
		SAVE => INT_SUM(46), CARRY => INT_CARRY(35)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(47) <= INT_CARRY(28); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_36:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(46), DATA_B => INT_SUM(47), DATA_C => INT_CARRY(29), 
		SAVE => SUM(14), CARRY => CARRY(14)
	);
---- End FA stage
-- End WT-branch 15

-- Begin WT-branch 16
---- Begin FA stage
FA_37:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(72), DATA_B => SUMMAND(73), DATA_C => SUMMAND(74), 
		SAVE => INT_SUM(48), CARRY => INT_CARRY(36)
	);
---- End FA stage
---- Begin FA stage
FA_38:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(75), DATA_B => SUMMAND(76), DATA_C => SUMMAND(77), 
		SAVE => INT_SUM(49), CARRY => INT_CARRY(37)
	);
---- End FA stage
---- Begin HA stage
HA_13:HALF_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(78), DATA_B => SUMMAND(79), 
		SAVE => INT_SUM(50), CARRY => INT_CARRY(38)
	);
---- End HA stage
---- Begin FA stage
FA_39:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(48), DATA_B => INT_SUM(49), DATA_C => INT_SUM(50), 
		SAVE => INT_SUM(51), CARRY => INT_CARRY(39)
	);
---- End FA stage
---- Begin FA stage
FA_40:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(30), DATA_B => INT_CARRY(31), DATA_C => INT_CARRY(32), 
		SAVE => INT_SUM(52), CARRY => INT_CARRY(40)
	);
---- End FA stage
---- Begin FA stage
FA_41:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(51), DATA_B => INT_SUM(52), DATA_C => INT_CARRY(33), 
		SAVE => INT_SUM(53), CARRY => INT_CARRY(41)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(54) <= INT_CARRY(34); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_42:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(53), DATA_B => INT_SUM(54), DATA_C => INT_CARRY(35), 
		SAVE => SUM(15), CARRY => CARRY(15)
	);
---- End FA stage
-- End WT-branch 16

-- Begin WT-branch 17
---- Begin FA stage
FA_43:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(80), DATA_B => SUMMAND(81), DATA_C => SUMMAND(82), 
		SAVE => INT_SUM(55), CARRY => INT_CARRY(42)
	);
---- End FA stage
---- Begin FA stage
FA_44:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(83), DATA_B => SUMMAND(84), DATA_C => SUMMAND(85), 
		SAVE => INT_SUM(56), CARRY => INT_CARRY(43)
	);
---- End FA stage
---- Begin FA stage
FA_45:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(86), DATA_B => SUMMAND(87), DATA_C => SUMMAND(88), 
		SAVE => INT_SUM(57), CARRY => INT_CARRY(44)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(58) <= SUMMAND(89); -- At Level 1
---- End NO stage
---- Begin FA stage
FA_46:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(55), DATA_B => INT_SUM(56), DATA_C => INT_SUM(57), 
		SAVE => INT_SUM(59), CARRY => INT_CARRY(45)
	);
---- End FA stage
---- Begin FA stage
FA_47:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(58), DATA_B => INT_CARRY(36), DATA_C => INT_CARRY(37), 
		SAVE => INT_SUM(60), CARRY => INT_CARRY(46)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(61) <= INT_CARRY(38); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_48:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(59), DATA_B => INT_SUM(60), DATA_C => INT_SUM(61), 
		SAVE => INT_SUM(62), CARRY => INT_CARRY(47)
	);
---- End FA stage
---- Begin HA stage
HA_14:HALF_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_CARRY(39), DATA_B => INT_CARRY(40), 
		SAVE => INT_SUM(63), CARRY => INT_CARRY(48)
	);
---- End HA stage
---- Begin FA stage
FA_49:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(62), DATA_B => INT_SUM(63), DATA_C => INT_CARRY(41), 
		SAVE => SUM(16), CARRY => CARRY(16)
	);
---- End FA stage
-- End WT-branch 17

-- Begin WT-branch 18
---- Begin FA stage
FA_50:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(90), DATA_B => SUMMAND(91), DATA_C => SUMMAND(92), 
		SAVE => INT_SUM(64), CARRY => INT_CARRY(49)
	);
---- End FA stage
---- Begin FA stage
FA_51:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(93), DATA_B => SUMMAND(94), DATA_C => SUMMAND(95), 
		SAVE => INT_SUM(65), CARRY => INT_CARRY(50)
	);
---- End FA stage
---- Begin FA stage
FA_52:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(96), DATA_B => SUMMAND(97), DATA_C => SUMMAND(98), 
		SAVE => INT_SUM(66), CARRY => INT_CARRY(51)
	);
---- End FA stage
---- Begin FA stage
FA_53:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(64), DATA_B => INT_SUM(65), DATA_C => INT_SUM(66), 
		SAVE => INT_SUM(67), CARRY => INT_CARRY(52)
	);
---- End FA stage
---- Begin FA stage
FA_54:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(42), DATA_B => INT_CARRY(43), DATA_C => INT_CARRY(44), 
		SAVE => INT_SUM(68), CARRY => INT_CARRY(53)
	);
---- End FA stage
---- Begin FA stage
FA_55:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(67), DATA_B => INT_SUM(68), DATA_C => INT_CARRY(45), 
		SAVE => INT_SUM(69), CARRY => INT_CARRY(54)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(70) <= INT_CARRY(46); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_56:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(69), DATA_B => INT_SUM(70), DATA_C => INT_CARRY(47), 
		SAVE => INT_SUM(71), CARRY => INT_CARRY(55)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(72) <= INT_CARRY(48); -- At Level 4
---- End NO stage
---- Begin HA stage
HA_15:HALF_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(71), DATA_B => INT_SUM(72), 
		SAVE => SUM(17), CARRY => CARRY(17)
	);
---- End HA stage
-- End WT-branch 18

-- Begin WT-branch 19
---- Begin FA stage
FA_57:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(99), DATA_B => SUMMAND(100), DATA_C => SUMMAND(101), 
		SAVE => INT_SUM(73), CARRY => INT_CARRY(56)
	);
---- End FA stage
---- Begin FA stage
FA_58:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(102), DATA_B => SUMMAND(103), DATA_C => SUMMAND(104), 
		SAVE => INT_SUM(74), CARRY => INT_CARRY(57)
	);
---- End FA stage
---- Begin FA stage
FA_59:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(105), DATA_B => SUMMAND(106), DATA_C => SUMMAND(107), 
		SAVE => INT_SUM(75), CARRY => INT_CARRY(58)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(76) <= SUMMAND(108); -- At Level 1
---- End NO stage
---- Begin NO stage
INT_SUM(77) <= SUMMAND(109); -- At Level 1
---- End NO stage
---- Begin FA stage
FA_60:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(73), DATA_B => INT_SUM(74), DATA_C => INT_SUM(75), 
		SAVE => INT_SUM(78), CARRY => INT_CARRY(59)
	);
---- End FA stage
---- Begin FA stage
FA_61:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(76), DATA_B => INT_SUM(77), DATA_C => INT_CARRY(49), 
		SAVE => INT_SUM(79), CARRY => INT_CARRY(60)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(80) <= INT_CARRY(50); -- At Level 2
---- End NO stage
---- Begin NO stage
INT_SUM(81) <= INT_CARRY(51); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_62:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(78), DATA_B => INT_SUM(79), DATA_C => INT_SUM(80), 
		SAVE => INT_SUM(82), CARRY => INT_CARRY(61)
	);
---- End FA stage
---- Begin FA stage
FA_63:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(81), DATA_B => INT_CARRY(52), DATA_C => INT_CARRY(53), 
		SAVE => INT_SUM(83), CARRY => INT_CARRY(62)
	);
---- End FA stage
---- Begin FA stage
FA_64:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(82), DATA_B => INT_SUM(83), DATA_C => INT_CARRY(54), 
		SAVE => INT_SUM(84), CARRY => INT_CARRY(63)
	);
---- End FA stage
---- Begin HA stage
HA_16:HALF_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(84), DATA_B => INT_CARRY(55), 
		SAVE => SUM(18), CARRY => CARRY(18)
	);
---- End HA stage
-- End WT-branch 19

-- Begin WT-branch 20
---- Begin FA stage
FA_65:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(110), DATA_B => SUMMAND(111), DATA_C => SUMMAND(112), 
		SAVE => INT_SUM(85), CARRY => INT_CARRY(64)
	);
---- End FA stage
---- Begin FA stage
FA_66:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(113), DATA_B => SUMMAND(114), DATA_C => SUMMAND(115), 
		SAVE => INT_SUM(86), CARRY => INT_CARRY(65)
	);
---- End FA stage
---- Begin FA stage
FA_67:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(116), DATA_B => SUMMAND(117), DATA_C => SUMMAND(118), 
		SAVE => INT_SUM(87), CARRY => INT_CARRY(66)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(88) <= SUMMAND(119); -- At Level 1
---- End NO stage
---- Begin FA stage
FA_68:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(85), DATA_B => INT_SUM(86), DATA_C => INT_SUM(87), 
		SAVE => INT_SUM(89), CARRY => INT_CARRY(67)
	);
---- End FA stage
---- Begin FA stage
FA_69:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(88), DATA_B => INT_CARRY(56), DATA_C => INT_CARRY(57), 
		SAVE => INT_SUM(90), CARRY => INT_CARRY(68)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(91) <= INT_CARRY(58); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_70:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(89), DATA_B => INT_SUM(90), DATA_C => INT_SUM(91), 
		SAVE => INT_SUM(92), CARRY => INT_CARRY(69)
	);
---- End FA stage
---- Begin HA stage
HA_17:HALF_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_CARRY(59), DATA_B => INT_CARRY(60), 
		SAVE => INT_SUM(93), CARRY => INT_CARRY(70)
	);
---- End HA stage
---- Begin FA stage
FA_71:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(92), DATA_B => INT_SUM(93), DATA_C => INT_CARRY(61), 
		SAVE => INT_SUM(94), CARRY => INT_CARRY(71)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(95) <= INT_CARRY(62); -- At Level 4
---- End NO stage
---- Begin FA stage
FA_72:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(94), DATA_B => INT_SUM(95), DATA_C => INT_CARRY(63), 
		SAVE => SUM(19), CARRY => CARRY(19)
	);
---- End FA stage
-- End WT-branch 20

-- Begin WT-branch 21
---- Begin FA stage
FA_73:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(120), DATA_B => SUMMAND(121), DATA_C => SUMMAND(122), 
		SAVE => INT_SUM(96), CARRY => INT_CARRY(72)
	);
---- End FA stage
---- Begin FA stage
FA_74:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(123), DATA_B => SUMMAND(124), DATA_C => SUMMAND(125), 
		SAVE => INT_SUM(97), CARRY => INT_CARRY(73)
	);
---- End FA stage
---- Begin FA stage
FA_75:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(126), DATA_B => SUMMAND(127), DATA_C => SUMMAND(128), 
		SAVE => INT_SUM(98), CARRY => INT_CARRY(74)
	);
---- End FA stage
---- Begin FA stage
FA_76:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(129), DATA_B => SUMMAND(130), DATA_C => SUMMAND(131), 
		SAVE => INT_SUM(99), CARRY => INT_CARRY(75)
	);
---- End FA stage
---- Begin FA stage
FA_77:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(96), DATA_B => INT_SUM(97), DATA_C => INT_SUM(98), 
		SAVE => INT_SUM(100), CARRY => INT_CARRY(76)
	);
---- End FA stage
---- Begin FA stage
FA_78:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(99), DATA_B => INT_CARRY(64), DATA_C => INT_CARRY(65), 
		SAVE => INT_SUM(101), CARRY => INT_CARRY(77)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(102) <= INT_CARRY(66); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_79:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(100), DATA_B => INT_SUM(101), DATA_C => INT_SUM(102), 
		SAVE => INT_SUM(103), CARRY => INT_CARRY(78)
	);
---- End FA stage
---- Begin HA stage
HA_18:HALF_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_CARRY(67), DATA_B => INT_CARRY(68), 
		SAVE => INT_SUM(104), CARRY => INT_CARRY(79)
	);
---- End HA stage
---- Begin FA stage
FA_80:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(103), DATA_B => INT_SUM(104), DATA_C => INT_CARRY(69), 
		SAVE => INT_SUM(105), CARRY => INT_CARRY(80)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(106) <= INT_CARRY(70); -- At Level 4
---- End NO stage
---- Begin FA stage
FA_81:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(105), DATA_B => INT_SUM(106), DATA_C => INT_CARRY(71), 
		SAVE => SUM(20), CARRY => CARRY(20)
	);
---- End FA stage
-- End WT-branch 21

-- Begin WT-branch 22
---- Begin FA stage
FA_82:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(132), DATA_B => SUMMAND(133), DATA_C => SUMMAND(134), 
		SAVE => INT_SUM(107), CARRY => INT_CARRY(81)
	);
---- End FA stage
---- Begin FA stage
FA_83:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(135), DATA_B => SUMMAND(136), DATA_C => SUMMAND(137), 
		SAVE => INT_SUM(108), CARRY => INT_CARRY(82)
	);
---- End FA stage
---- Begin FA stage
FA_84:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(138), DATA_B => SUMMAND(139), DATA_C => SUMMAND(140), 
		SAVE => INT_SUM(109), CARRY => INT_CARRY(83)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(110) <= SUMMAND(141); -- At Level 1
---- End NO stage
---- Begin NO stage
INT_SUM(111) <= SUMMAND(142); -- At Level 1
---- End NO stage
---- Begin FA stage
FA_85:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(107), DATA_B => INT_SUM(108), DATA_C => INT_SUM(109), 
		SAVE => INT_SUM(112), CARRY => INT_CARRY(84)
	);
---- End FA stage
---- Begin FA stage
FA_86:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(110), DATA_B => INT_SUM(111), DATA_C => INT_CARRY(72), 
		SAVE => INT_SUM(113), CARRY => INT_CARRY(85)
	);
---- End FA stage
---- Begin FA stage
FA_87:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(73), DATA_B => INT_CARRY(74), DATA_C => INT_CARRY(75), 
		SAVE => INT_SUM(114), CARRY => INT_CARRY(86)
	);
---- End FA stage
---- Begin FA stage
FA_88:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(112), DATA_B => INT_SUM(113), DATA_C => INT_SUM(114), 
		SAVE => INT_SUM(115), CARRY => INT_CARRY(87)
	);
---- End FA stage
---- Begin HA stage
HA_19:HALF_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_CARRY(76), DATA_B => INT_CARRY(77), 
		SAVE => INT_SUM(116), CARRY => INT_CARRY(88)
	);
---- End HA stage
---- Begin FA stage
FA_89:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(115), DATA_B => INT_SUM(116), DATA_C => INT_CARRY(78), 
		SAVE => INT_SUM(117), CARRY => INT_CARRY(89)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(118) <= INT_CARRY(79); -- At Level 4
---- End NO stage
---- Begin FA stage
FA_90:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(117), DATA_B => INT_SUM(118), DATA_C => INT_CARRY(80), 
		SAVE => SUM(21), CARRY => CARRY(21)
	);
---- End FA stage
-- End WT-branch 22

-- Begin WT-branch 23
---- Begin FA stage
FA_91:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(143), DATA_B => SUMMAND(144), DATA_C => SUMMAND(145), 
		SAVE => INT_SUM(119), CARRY => INT_CARRY(90)
	);
---- End FA stage
---- Begin FA stage
FA_92:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(146), DATA_B => SUMMAND(147), DATA_C => SUMMAND(148), 
		SAVE => INT_SUM(120), CARRY => INT_CARRY(91)
	);
---- End FA stage
---- Begin FA stage
FA_93:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(149), DATA_B => SUMMAND(150), DATA_C => SUMMAND(151), 
		SAVE => INT_SUM(121), CARRY => INT_CARRY(92)
	);
---- End FA stage
---- Begin FA stage
FA_94:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(152), DATA_B => SUMMAND(153), DATA_C => SUMMAND(154), 
		SAVE => INT_SUM(122), CARRY => INT_CARRY(93)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(123) <= SUMMAND(155); -- At Level 1
---- End NO stage
---- Begin FA stage
FA_95:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(119), DATA_B => INT_SUM(120), DATA_C => INT_SUM(121), 
		SAVE => INT_SUM(124), CARRY => INT_CARRY(94)
	);
---- End FA stage
---- Begin FA stage
FA_96:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(122), DATA_B => INT_SUM(123), DATA_C => INT_CARRY(81), 
		SAVE => INT_SUM(125), CARRY => INT_CARRY(95)
	);
---- End FA stage
---- Begin HA stage
HA_20:HALF_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(82), DATA_B => INT_CARRY(83), 
		SAVE => INT_SUM(126), CARRY => INT_CARRY(96)
	);
---- End HA stage
---- Begin FA stage
FA_97:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(124), DATA_B => INT_SUM(125), DATA_C => INT_SUM(126), 
		SAVE => INT_SUM(127), CARRY => INT_CARRY(97)
	);
---- End FA stage
---- Begin FA stage
FA_98:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_CARRY(84), DATA_B => INT_CARRY(85), DATA_C => INT_CARRY(86), 
		SAVE => INT_SUM(128), CARRY => INT_CARRY(98)
	);
---- End FA stage
---- Begin FA stage
FA_99:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(127), DATA_B => INT_SUM(128), DATA_C => INT_CARRY(87), 
		SAVE => INT_SUM(129), CARRY => INT_CARRY(99)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(130) <= INT_CARRY(88); -- At Level 4
---- End NO stage
---- Begin FA stage
FA_100:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(129), DATA_B => INT_SUM(130), DATA_C => INT_CARRY(89), 
		SAVE => SUM(22), CARRY => CARRY(22)
	);
---- End FA stage
-- End WT-branch 23

-- Begin WT-branch 24
---- Begin FA stage
FA_101:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(156), DATA_B => SUMMAND(157), DATA_C => SUMMAND(158), 
		SAVE => INT_SUM(131), CARRY => INT_CARRY(100)
	);
---- End FA stage
---- Begin FA stage
FA_102:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(159), DATA_B => SUMMAND(160), DATA_C => SUMMAND(161), 
		SAVE => INT_SUM(132), CARRY => INT_CARRY(101)
	);
---- End FA stage
---- Begin FA stage
FA_103:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(162), DATA_B => SUMMAND(163), DATA_C => SUMMAND(164), 
		SAVE => INT_SUM(133), CARRY => INT_CARRY(102)
	);
---- End FA stage
---- Begin FA stage
FA_104:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(165), DATA_B => SUMMAND(166), DATA_C => SUMMAND(167), 
		SAVE => INT_SUM(134), CARRY => INT_CARRY(103)
	);
---- End FA stage
---- Begin FA stage
FA_105:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(131), DATA_B => INT_SUM(132), DATA_C => INT_SUM(133), 
		SAVE => INT_SUM(135), CARRY => INT_CARRY(104)
	);
---- End FA stage
---- Begin FA stage
FA_106:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(134), DATA_B => INT_CARRY(90), DATA_C => INT_CARRY(91), 
		SAVE => INT_SUM(136), CARRY => INT_CARRY(105)
	);
---- End FA stage
---- Begin HA stage
HA_21:HALF_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(92), DATA_B => INT_CARRY(93), 
		SAVE => INT_SUM(137), CARRY => INT_CARRY(106)
	);
---- End HA stage
---- Begin FA stage
FA_107:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(135), DATA_B => INT_SUM(136), DATA_C => INT_SUM(137), 
		SAVE => INT_SUM(138), CARRY => INT_CARRY(107)
	);
---- End FA stage
---- Begin FA stage
FA_108:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_CARRY(94), DATA_B => INT_CARRY(95), DATA_C => INT_CARRY(96), 
		SAVE => INT_SUM(139), CARRY => INT_CARRY(108)
	);
---- End FA stage
---- Begin FA stage
FA_109:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(138), DATA_B => INT_SUM(139), DATA_C => INT_CARRY(97), 
		SAVE => INT_SUM(140), CARRY => INT_CARRY(109)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(141) <= INT_CARRY(98); -- At Level 4
---- End NO stage
---- Begin FA stage
FA_110:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(140), DATA_B => INT_SUM(141), DATA_C => INT_CARRY(99), 
		SAVE => SUM(23), CARRY => CARRY(23)
	);
---- End FA stage
-- End WT-branch 24

-- Begin WT-branch 25
---- Begin FA stage
FA_111:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(168), DATA_B => SUMMAND(169), DATA_C => SUMMAND(170), 
		SAVE => INT_SUM(142), CARRY => INT_CARRY(110)
	);
---- End FA stage
---- Begin FA stage
FA_112:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(171), DATA_B => SUMMAND(172), DATA_C => SUMMAND(173), 
		SAVE => INT_SUM(143), CARRY => INT_CARRY(111)
	);
---- End FA stage
---- Begin FA stage
FA_113:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(174), DATA_B => SUMMAND(175), DATA_C => SUMMAND(176), 
		SAVE => INT_SUM(144), CARRY => INT_CARRY(112)
	);
---- End FA stage
---- Begin FA stage
FA_114:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(177), DATA_B => SUMMAND(178), DATA_C => SUMMAND(179), 
		SAVE => INT_SUM(145), CARRY => INT_CARRY(113)
	);
---- End FA stage
---- Begin HA stage
HA_22:HALF_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(180), DATA_B => SUMMAND(181), 
		SAVE => INT_SUM(146), CARRY => INT_CARRY(114)
	);
---- End HA stage
---- Begin FA stage
FA_115:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(142), DATA_B => INT_SUM(143), DATA_C => INT_SUM(144), 
		SAVE => INT_SUM(147), CARRY => INT_CARRY(115)
	);
---- End FA stage
---- Begin FA stage
FA_116:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(145), DATA_B => INT_SUM(146), DATA_C => INT_CARRY(100), 
		SAVE => INT_SUM(148), CARRY => INT_CARRY(116)
	);
---- End FA stage
---- Begin FA stage
FA_117:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(101), DATA_B => INT_CARRY(102), DATA_C => INT_CARRY(103), 
		SAVE => INT_SUM(149), CARRY => INT_CARRY(117)
	);
---- End FA stage
---- Begin FA stage
FA_118:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(147), DATA_B => INT_SUM(148), DATA_C => INT_SUM(149), 
		SAVE => INT_SUM(150), CARRY => INT_CARRY(118)
	);
---- End FA stage
---- Begin FA stage
FA_119:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_CARRY(104), DATA_B => INT_CARRY(105), DATA_C => INT_CARRY(106), 
		SAVE => INT_SUM(151), CARRY => INT_CARRY(119)
	);
---- End FA stage
---- Begin FA stage
FA_120:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(150), DATA_B => INT_SUM(151), DATA_C => INT_CARRY(107), 
		SAVE => INT_SUM(152), CARRY => INT_CARRY(120)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(153) <= INT_CARRY(108); -- At Level 4
---- End NO stage
---- Begin FA stage
FA_121:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(152), DATA_B => INT_SUM(153), DATA_C => INT_CARRY(109), 
		SAVE => SUM(24), CARRY => CARRY(24)
	);
---- End FA stage
-- End WT-branch 25

-- Begin WT-branch 26
---- Begin FA stage
FA_122:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(182), DATA_B => SUMMAND(183), DATA_C => SUMMAND(184), 
		SAVE => INT_SUM(154), CARRY => INT_CARRY(121)
	);
---- End FA stage
---- Begin FA stage
FA_123:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(185), DATA_B => SUMMAND(186), DATA_C => SUMMAND(187), 
		SAVE => INT_SUM(155), CARRY => INT_CARRY(122)
	);
---- End FA stage
---- Begin FA stage
FA_124:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(188), DATA_B => SUMMAND(189), DATA_C => SUMMAND(190), 
		SAVE => INT_SUM(156), CARRY => INT_CARRY(123)
	);
---- End FA stage
---- Begin FA stage
FA_125:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(191), DATA_B => SUMMAND(192), DATA_C => SUMMAND(193), 
		SAVE => INT_SUM(157), CARRY => INT_CARRY(124)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(158) <= SUMMAND(194); -- At Level 1
---- End NO stage
---- Begin FA stage
FA_126:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(154), DATA_B => INT_SUM(155), DATA_C => INT_SUM(156), 
		SAVE => INT_SUM(159), CARRY => INT_CARRY(125)
	);
---- End FA stage
---- Begin FA stage
FA_127:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(157), DATA_B => INT_SUM(158), DATA_C => INT_CARRY(110), 
		SAVE => INT_SUM(160), CARRY => INT_CARRY(126)
	);
---- End FA stage
---- Begin FA stage
FA_128:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(111), DATA_B => INT_CARRY(112), DATA_C => INT_CARRY(113), 
		SAVE => INT_SUM(161), CARRY => INT_CARRY(127)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(162) <= INT_CARRY(114); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_129:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(159), DATA_B => INT_SUM(160), DATA_C => INT_SUM(161), 
		SAVE => INT_SUM(163), CARRY => INT_CARRY(128)
	);
---- End FA stage
---- Begin FA stage
FA_130:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(162), DATA_B => INT_CARRY(115), DATA_C => INT_CARRY(116), 
		SAVE => INT_SUM(164), CARRY => INT_CARRY(129)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(165) <= INT_CARRY(117); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_131:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(163), DATA_B => INT_SUM(164), DATA_C => INT_SUM(165), 
		SAVE => INT_SUM(166), CARRY => INT_CARRY(130)
	);
---- End FA stage
---- Begin HA stage
HA_23:HALF_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_CARRY(118), DATA_B => INT_CARRY(119), 
		SAVE => INT_SUM(167), CARRY => INT_CARRY(131)
	);
---- End HA stage
---- Begin FA stage
FA_132:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(166), DATA_B => INT_SUM(167), DATA_C => INT_CARRY(120), 
		SAVE => SUM(25), CARRY => CARRY(25)
	);
---- End FA stage
-- End WT-branch 26

-- Begin WT-branch 27
---- Begin FA stage
FA_133:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(195), DATA_B => SUMMAND(196), DATA_C => SUMMAND(197), 
		SAVE => INT_SUM(168), CARRY => INT_CARRY(132)
	);
---- End FA stage
---- Begin FA stage
FA_134:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(198), DATA_B => SUMMAND(199), DATA_C => SUMMAND(200), 
		SAVE => INT_SUM(169), CARRY => INT_CARRY(133)
	);
---- End FA stage
---- Begin FA stage
FA_135:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(201), DATA_B => SUMMAND(202), DATA_C => SUMMAND(203), 
		SAVE => INT_SUM(170), CARRY => INT_CARRY(134)
	);
---- End FA stage
---- Begin FA stage
FA_136:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(204), DATA_B => SUMMAND(205), DATA_C => SUMMAND(206), 
		SAVE => INT_SUM(171), CARRY => INT_CARRY(135)
	);
---- End FA stage
---- Begin FA stage
FA_137:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(207), DATA_B => SUMMAND(208), DATA_C => SUMMAND(209), 
		SAVE => INT_SUM(172), CARRY => INT_CARRY(136)
	);
---- End FA stage
---- Begin FA stage
FA_138:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(168), DATA_B => INT_SUM(169), DATA_C => INT_SUM(170), 
		SAVE => INT_SUM(173), CARRY => INT_CARRY(137)
	);
---- End FA stage
---- Begin FA stage
FA_139:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(171), DATA_B => INT_SUM(172), DATA_C => INT_CARRY(121), 
		SAVE => INT_SUM(174), CARRY => INT_CARRY(138)
	);
---- End FA stage
---- Begin FA stage
FA_140:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(122), DATA_B => INT_CARRY(123), DATA_C => INT_CARRY(124), 
		SAVE => INT_SUM(175), CARRY => INT_CARRY(139)
	);
---- End FA stage
---- Begin FA stage
FA_141:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(173), DATA_B => INT_SUM(174), DATA_C => INT_SUM(175), 
		SAVE => INT_SUM(176), CARRY => INT_CARRY(140)
	);
---- End FA stage
---- Begin FA stage
FA_142:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_CARRY(125), DATA_B => INT_CARRY(126), DATA_C => INT_CARRY(127), 
		SAVE => INT_SUM(177), CARRY => INT_CARRY(141)
	);
---- End FA stage
---- Begin FA stage
FA_143:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(176), DATA_B => INT_SUM(177), DATA_C => INT_CARRY(128), 
		SAVE => INT_SUM(178), CARRY => INT_CARRY(142)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(179) <= INT_CARRY(129); -- At Level 4
---- End NO stage
---- Begin FA stage
FA_144:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(178), DATA_B => INT_SUM(179), DATA_C => INT_CARRY(130), 
		SAVE => INT_SUM(180), CARRY => INT_CARRY(143)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(181) <= INT_CARRY(131); -- At Level 5
---- End NO stage
---- Begin HA stage
HA_24:HALF_ADDER -- At Level 6
	port map
	(
		DATA_A => INT_SUM(180), DATA_B => INT_SUM(181), 
		SAVE => SUM(26), CARRY => CARRY(26)
	);
---- End HA stage
-- End WT-branch 27

-- Begin WT-branch 28
---- Begin FA stage
FA_145:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(210), DATA_B => SUMMAND(211), DATA_C => SUMMAND(212), 
		SAVE => INT_SUM(182), CARRY => INT_CARRY(144)
	);
---- End FA stage
---- Begin FA stage
FA_146:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(213), DATA_B => SUMMAND(214), DATA_C => SUMMAND(215), 
		SAVE => INT_SUM(183), CARRY => INT_CARRY(145)
	);
---- End FA stage
---- Begin FA stage
FA_147:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(216), DATA_B => SUMMAND(217), DATA_C => SUMMAND(218), 
		SAVE => INT_SUM(184), CARRY => INT_CARRY(146)
	);
---- End FA stage
---- Begin FA stage
FA_148:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(219), DATA_B => SUMMAND(220), DATA_C => SUMMAND(221), 
		SAVE => INT_SUM(185), CARRY => INT_CARRY(147)
	);
---- End FA stage
---- Begin HA stage
HA_25:HALF_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(222), DATA_B => SUMMAND(223), 
		SAVE => INT_SUM(186), CARRY => INT_CARRY(148)
	);
---- End HA stage
---- Begin FA stage
FA_149:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(182), DATA_B => INT_SUM(183), DATA_C => INT_SUM(184), 
		SAVE => INT_SUM(187), CARRY => INT_CARRY(149)
	);
---- End FA stage
---- Begin FA stage
FA_150:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(185), DATA_B => INT_SUM(186), DATA_C => INT_CARRY(132), 
		SAVE => INT_SUM(188), CARRY => INT_CARRY(150)
	);
---- End FA stage
---- Begin FA stage
FA_151:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(133), DATA_B => INT_CARRY(134), DATA_C => INT_CARRY(135), 
		SAVE => INT_SUM(189), CARRY => INT_CARRY(151)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(190) <= INT_CARRY(136); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_152:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(187), DATA_B => INT_SUM(188), DATA_C => INT_SUM(189), 
		SAVE => INT_SUM(191), CARRY => INT_CARRY(152)
	);
---- End FA stage
---- Begin FA stage
FA_153:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(190), DATA_B => INT_CARRY(137), DATA_C => INT_CARRY(138), 
		SAVE => INT_SUM(192), CARRY => INT_CARRY(153)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(193) <= INT_CARRY(139); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_154:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(191), DATA_B => INT_SUM(192), DATA_C => INT_SUM(193), 
		SAVE => INT_SUM(194), CARRY => INT_CARRY(154)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(195) <= INT_CARRY(140); -- At Level 4
---- End NO stage
---- Begin NO stage
INT_SUM(196) <= INT_CARRY(141); -- At Level 4
---- End NO stage
---- Begin FA stage
FA_155:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(194), DATA_B => INT_SUM(195), DATA_C => INT_SUM(196), 
		SAVE => INT_SUM(197), CARRY => INT_CARRY(155)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(198) <= INT_CARRY(142); -- At Level 5
---- End NO stage
---- Begin FA stage
FA_156:FULL_ADDER -- At Level 6
	port map
	(
		DATA_A => INT_SUM(197), DATA_B => INT_SUM(198), DATA_C => INT_CARRY(143), 
		SAVE => SUM(27), CARRY => CARRY(27)
	);
---- End FA stage
-- End WT-branch 28

-- Begin WT-branch 29
---- Begin FA stage
FA_157:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(224), DATA_B => SUMMAND(225), DATA_C => SUMMAND(226), 
		SAVE => INT_SUM(199), CARRY => INT_CARRY(156)
	);
---- End FA stage
---- Begin FA stage
FA_158:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(227), DATA_B => SUMMAND(228), DATA_C => SUMMAND(229), 
		SAVE => INT_SUM(200), CARRY => INT_CARRY(157)
	);
---- End FA stage
---- Begin FA stage
FA_159:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(230), DATA_B => SUMMAND(231), DATA_C => SUMMAND(232), 
		SAVE => INT_SUM(201), CARRY => INT_CARRY(158)
	);
---- End FA stage
---- Begin FA stage
FA_160:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(233), DATA_B => SUMMAND(234), DATA_C => SUMMAND(235), 
		SAVE => INT_SUM(202), CARRY => INT_CARRY(159)
	);
---- End FA stage
---- Begin FA stage
FA_161:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(236), DATA_B => SUMMAND(237), DATA_C => SUMMAND(238), 
		SAVE => INT_SUM(203), CARRY => INT_CARRY(160)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(204) <= SUMMAND(239); -- At Level 1
---- End NO stage
---- Begin FA stage
FA_162:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(199), DATA_B => INT_SUM(200), DATA_C => INT_SUM(201), 
		SAVE => INT_SUM(205), CARRY => INT_CARRY(161)
	);
---- End FA stage
---- Begin FA stage
FA_163:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(202), DATA_B => INT_SUM(203), DATA_C => INT_SUM(204), 
		SAVE => INT_SUM(206), CARRY => INT_CARRY(162)
	);
---- End FA stage
---- Begin FA stage
FA_164:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(144), DATA_B => INT_CARRY(145), DATA_C => INT_CARRY(146), 
		SAVE => INT_SUM(207), CARRY => INT_CARRY(163)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(208) <= INT_CARRY(147); -- At Level 2
---- End NO stage
---- Begin NO stage
INT_SUM(209) <= INT_CARRY(148); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_165:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(205), DATA_B => INT_SUM(206), DATA_C => INT_SUM(207), 
		SAVE => INT_SUM(210), CARRY => INT_CARRY(164)
	);
---- End FA stage
---- Begin FA stage
FA_166:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(208), DATA_B => INT_SUM(209), DATA_C => INT_CARRY(149), 
		SAVE => INT_SUM(211), CARRY => INT_CARRY(165)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(212) <= INT_CARRY(150); -- At Level 3
---- End NO stage
---- Begin NO stage
INT_SUM(213) <= INT_CARRY(151); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_167:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(210), DATA_B => INT_SUM(211), DATA_C => INT_SUM(212), 
		SAVE => INT_SUM(214), CARRY => INT_CARRY(166)
	);
---- End FA stage
---- Begin FA stage
FA_168:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(213), DATA_B => INT_CARRY(152), DATA_C => INT_CARRY(153), 
		SAVE => INT_SUM(215), CARRY => INT_CARRY(167)
	);
---- End FA stage
---- Begin FA stage
FA_169:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(214), DATA_B => INT_SUM(215), DATA_C => INT_CARRY(154), 
		SAVE => INT_SUM(216), CARRY => INT_CARRY(168)
	);
---- End FA stage
---- Begin HA stage
HA_26:HALF_ADDER -- At Level 6
	port map
	(
		DATA_A => INT_SUM(216), DATA_B => INT_CARRY(155), 
		SAVE => SUM(28), CARRY => CARRY(28)
	);
---- End HA stage
-- End WT-branch 29

-- Begin WT-branch 30
---- Begin FA stage
FA_170:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(240), DATA_B => SUMMAND(241), DATA_C => SUMMAND(242), 
		SAVE => INT_SUM(217), CARRY => INT_CARRY(169)
	);
---- End FA stage
---- Begin FA stage
FA_171:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(243), DATA_B => SUMMAND(244), DATA_C => SUMMAND(245), 
		SAVE => INT_SUM(218), CARRY => INT_CARRY(170)
	);
---- End FA stage
---- Begin FA stage
FA_172:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(246), DATA_B => SUMMAND(247), DATA_C => SUMMAND(248), 
		SAVE => INT_SUM(219), CARRY => INT_CARRY(171)
	);
---- End FA stage
---- Begin FA stage
FA_173:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(249), DATA_B => SUMMAND(250), DATA_C => SUMMAND(251), 
		SAVE => INT_SUM(220), CARRY => INT_CARRY(172)
	);
---- End FA stage
---- Begin FA stage
FA_174:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(252), DATA_B => SUMMAND(253), DATA_C => SUMMAND(254), 
		SAVE => INT_SUM(221), CARRY => INT_CARRY(173)
	);
---- End FA stage
---- Begin FA stage
FA_175:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(217), DATA_B => INT_SUM(218), DATA_C => INT_SUM(219), 
		SAVE => INT_SUM(222), CARRY => INT_CARRY(174)
	);
---- End FA stage
---- Begin FA stage
FA_176:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(220), DATA_B => INT_SUM(221), DATA_C => INT_CARRY(156), 
		SAVE => INT_SUM(223), CARRY => INT_CARRY(175)
	);
---- End FA stage
---- Begin FA stage
FA_177:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(157), DATA_B => INT_CARRY(158), DATA_C => INT_CARRY(159), 
		SAVE => INT_SUM(224), CARRY => INT_CARRY(176)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(225) <= INT_CARRY(160); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_178:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(222), DATA_B => INT_SUM(223), DATA_C => INT_SUM(224), 
		SAVE => INT_SUM(226), CARRY => INT_CARRY(177)
	);
---- End FA stage
---- Begin FA stage
FA_179:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(225), DATA_B => INT_CARRY(161), DATA_C => INT_CARRY(162), 
		SAVE => INT_SUM(227), CARRY => INT_CARRY(178)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(228) <= INT_CARRY(163); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_180:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(226), DATA_B => INT_SUM(227), DATA_C => INT_SUM(228), 
		SAVE => INT_SUM(229), CARRY => INT_CARRY(179)
	);
---- End FA stage
---- Begin HA stage
HA_27:HALF_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_CARRY(164), DATA_B => INT_CARRY(165), 
		SAVE => INT_SUM(230), CARRY => INT_CARRY(180)
	);
---- End HA stage
---- Begin FA stage
FA_181:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(229), DATA_B => INT_SUM(230), DATA_C => INT_CARRY(166), 
		SAVE => INT_SUM(231), CARRY => INT_CARRY(181)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(232) <= INT_CARRY(167); -- At Level 5
---- End NO stage
---- Begin FA stage
FA_182:FULL_ADDER -- At Level 6
	port map
	(
		DATA_A => INT_SUM(231), DATA_B => INT_SUM(232), DATA_C => INT_CARRY(168), 
		SAVE => SUM(29), CARRY => CARRY(29)
	);
---- End FA stage
-- End WT-branch 30

-- Begin WT-branch 31
---- Begin FA stage
FA_183:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(255), DATA_B => SUMMAND(256), DATA_C => SUMMAND(257), 
		SAVE => INT_SUM(233), CARRY => INT_CARRY(182)
	);
---- End FA stage
---- Begin FA stage
FA_184:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(258), DATA_B => SUMMAND(259), DATA_C => SUMMAND(260), 
		SAVE => INT_SUM(234), CARRY => INT_CARRY(183)
	);
---- End FA stage
---- Begin FA stage
FA_185:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(261), DATA_B => SUMMAND(262), DATA_C => SUMMAND(263), 
		SAVE => INT_SUM(235), CARRY => INT_CARRY(184)
	);
---- End FA stage
---- Begin FA stage
FA_186:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(264), DATA_B => SUMMAND(265), DATA_C => SUMMAND(266), 
		SAVE => INT_SUM(236), CARRY => INT_CARRY(185)
	);
---- End FA stage
---- Begin FA stage
FA_187:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(267), DATA_B => SUMMAND(268), DATA_C => SUMMAND(269), 
		SAVE => INT_SUM(237), CARRY => INT_CARRY(186)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(238) <= SUMMAND(270); -- At Level 1
---- End NO stage
---- Begin NO stage
INT_SUM(239) <= SUMMAND(271); -- At Level 1
---- End NO stage
---- Begin FA stage
FA_188:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(233), DATA_B => INT_SUM(234), DATA_C => INT_SUM(235), 
		SAVE => INT_SUM(240), CARRY => INT_CARRY(187)
	);
---- End FA stage
---- Begin FA stage
FA_189:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(236), DATA_B => INT_SUM(237), DATA_C => INT_SUM(238), 
		SAVE => INT_SUM(241), CARRY => INT_CARRY(188)
	);
---- End FA stage
---- Begin FA stage
FA_190:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(239), DATA_B => INT_CARRY(169), DATA_C => INT_CARRY(170), 
		SAVE => INT_SUM(242), CARRY => INT_CARRY(189)
	);
---- End FA stage
---- Begin FA stage
FA_191:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(171), DATA_B => INT_CARRY(172), DATA_C => INT_CARRY(173), 
		SAVE => INT_SUM(243), CARRY => INT_CARRY(190)
	);
---- End FA stage
---- Begin FA stage
FA_192:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(240), DATA_B => INT_SUM(241), DATA_C => INT_SUM(242), 
		SAVE => INT_SUM(244), CARRY => INT_CARRY(191)
	);
---- End FA stage
---- Begin FA stage
FA_193:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(243), DATA_B => INT_CARRY(174), DATA_C => INT_CARRY(175), 
		SAVE => INT_SUM(245), CARRY => INT_CARRY(192)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(246) <= INT_CARRY(176); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_194:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(244), DATA_B => INT_SUM(245), DATA_C => INT_SUM(246), 
		SAVE => INT_SUM(247), CARRY => INT_CARRY(193)
	);
---- End FA stage
---- Begin HA stage
HA_28:HALF_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_CARRY(177), DATA_B => INT_CARRY(178), 
		SAVE => INT_SUM(248), CARRY => INT_CARRY(194)
	);
---- End HA stage
---- Begin FA stage
FA_195:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(247), DATA_B => INT_SUM(248), DATA_C => INT_CARRY(179), 
		SAVE => INT_SUM(249), CARRY => INT_CARRY(195)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(250) <= INT_CARRY(180); -- At Level 5
---- End NO stage
---- Begin FA stage
FA_196:FULL_ADDER -- At Level 6
	port map
	(
		DATA_A => INT_SUM(249), DATA_B => INT_SUM(250), DATA_C => INT_CARRY(181), 
		SAVE => SUM(30), CARRY => CARRY(30)
	);
---- End FA stage
-- End WT-branch 31

-- Begin WT-branch 32
---- Begin FA stage
FA_197:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(272), DATA_B => SUMMAND(273), DATA_C => SUMMAND(274), 
		SAVE => INT_SUM(251), CARRY => INT_CARRY(196)
	);
---- End FA stage
---- Begin FA stage
FA_198:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(275), DATA_B => SUMMAND(276), DATA_C => SUMMAND(277), 
		SAVE => INT_SUM(252), CARRY => INT_CARRY(197)
	);
---- End FA stage
---- Begin FA stage
FA_199:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(278), DATA_B => SUMMAND(279), DATA_C => SUMMAND(280), 
		SAVE => INT_SUM(253), CARRY => INT_CARRY(198)
	);
---- End FA stage
---- Begin FA stage
FA_200:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(281), DATA_B => SUMMAND(282), DATA_C => SUMMAND(283), 
		SAVE => INT_SUM(254), CARRY => INT_CARRY(199)
	);
---- End FA stage
---- Begin FA stage
FA_201:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(284), DATA_B => SUMMAND(285), DATA_C => SUMMAND(286), 
		SAVE => INT_SUM(255), CARRY => INT_CARRY(200)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(256) <= SUMMAND(287); -- At Level 1
---- End NO stage
---- Begin FA stage
FA_202:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(251), DATA_B => INT_SUM(252), DATA_C => INT_SUM(253), 
		SAVE => INT_SUM(257), CARRY => INT_CARRY(201)
	);
---- End FA stage
---- Begin FA stage
FA_203:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(254), DATA_B => INT_SUM(255), DATA_C => INT_SUM(256), 
		SAVE => INT_SUM(258), CARRY => INT_CARRY(202)
	);
---- End FA stage
---- Begin FA stage
FA_204:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(182), DATA_B => INT_CARRY(183), DATA_C => INT_CARRY(184), 
		SAVE => INT_SUM(259), CARRY => INT_CARRY(203)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(260) <= INT_CARRY(185); -- At Level 2
---- End NO stage
---- Begin NO stage
INT_SUM(261) <= INT_CARRY(186); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_205:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(257), DATA_B => INT_SUM(258), DATA_C => INT_SUM(259), 
		SAVE => INT_SUM(262), CARRY => INT_CARRY(204)
	);
---- End FA stage
---- Begin FA stage
FA_206:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(260), DATA_B => INT_SUM(261), DATA_C => INT_CARRY(187), 
		SAVE => INT_SUM(263), CARRY => INT_CARRY(205)
	);
---- End FA stage
---- Begin FA stage
FA_207:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_CARRY(188), DATA_B => INT_CARRY(189), DATA_C => INT_CARRY(190), 
		SAVE => INT_SUM(264), CARRY => INT_CARRY(206)
	);
---- End FA stage
---- Begin FA stage
FA_208:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(262), DATA_B => INT_SUM(263), DATA_C => INT_SUM(264), 
		SAVE => INT_SUM(265), CARRY => INT_CARRY(207)
	);
---- End FA stage
---- Begin HA stage
HA_29:HALF_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_CARRY(191), DATA_B => INT_CARRY(192), 
		SAVE => INT_SUM(266), CARRY => INT_CARRY(208)
	);
---- End HA stage
---- Begin FA stage
FA_209:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(265), DATA_B => INT_SUM(266), DATA_C => INT_CARRY(193), 
		SAVE => INT_SUM(267), CARRY => INT_CARRY(209)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(268) <= INT_CARRY(194); -- At Level 5
---- End NO stage
---- Begin FA stage
FA_210:FULL_ADDER -- At Level 6
	port map
	(
		DATA_A => INT_SUM(267), DATA_B => INT_SUM(268), DATA_C => INT_CARRY(195), 
		SAVE => SUM(31), CARRY => CARRY(31)
	);
---- End FA stage
-- End WT-branch 32

-- Begin WT-branch 33
---- Begin FA stage
FA_211:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(288), DATA_B => SUMMAND(289), DATA_C => SUMMAND(290), 
		SAVE => INT_SUM(269), CARRY => INT_CARRY(210)
	);
---- End FA stage
---- Begin FA stage
FA_212:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(291), DATA_B => SUMMAND(292), DATA_C => SUMMAND(293), 
		SAVE => INT_SUM(270), CARRY => INT_CARRY(211)
	);
---- End FA stage
---- Begin FA stage
FA_213:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(294), DATA_B => SUMMAND(295), DATA_C => SUMMAND(296), 
		SAVE => INT_SUM(271), CARRY => INT_CARRY(212)
	);
---- End FA stage
---- Begin FA stage
FA_214:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(297), DATA_B => SUMMAND(298), DATA_C => SUMMAND(299), 
		SAVE => INT_SUM(272), CARRY => INT_CARRY(213)
	);
---- End FA stage
---- Begin FA stage
FA_215:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(300), DATA_B => SUMMAND(301), DATA_C => SUMMAND(302), 
		SAVE => INT_SUM(273), CARRY => INT_CARRY(214)
	);
---- End FA stage
---- Begin FA stage
FA_216:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(303), DATA_B => SUMMAND(304), DATA_C => SUMMAND(305), 
		SAVE => INT_SUM(274), CARRY => INT_CARRY(215)
	);
---- End FA stage
---- Begin FA stage
FA_217:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(269), DATA_B => INT_SUM(270), DATA_C => INT_SUM(271), 
		SAVE => INT_SUM(275), CARRY => INT_CARRY(216)
	);
---- End FA stage
---- Begin FA stage
FA_218:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(272), DATA_B => INT_SUM(273), DATA_C => INT_SUM(274), 
		SAVE => INT_SUM(276), CARRY => INT_CARRY(217)
	);
---- End FA stage
---- Begin FA stage
FA_219:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(196), DATA_B => INT_CARRY(197), DATA_C => INT_CARRY(198), 
		SAVE => INT_SUM(277), CARRY => INT_CARRY(218)
	);
---- End FA stage
---- Begin HA stage
HA_30:HALF_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(199), DATA_B => INT_CARRY(200), 
		SAVE => INT_SUM(278), CARRY => INT_CARRY(219)
	);
---- End HA stage
---- Begin FA stage
FA_220:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(275), DATA_B => INT_SUM(276), DATA_C => INT_SUM(277), 
		SAVE => INT_SUM(279), CARRY => INT_CARRY(220)
	);
---- End FA stage
---- Begin FA stage
FA_221:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(278), DATA_B => INT_CARRY(201), DATA_C => INT_CARRY(202), 
		SAVE => INT_SUM(280), CARRY => INT_CARRY(221)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(281) <= INT_CARRY(203); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_222:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(279), DATA_B => INT_SUM(280), DATA_C => INT_SUM(281), 
		SAVE => INT_SUM(282), CARRY => INT_CARRY(222)
	);
---- End FA stage
---- Begin FA stage
FA_223:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_CARRY(204), DATA_B => INT_CARRY(205), DATA_C => INT_CARRY(206), 
		SAVE => INT_SUM(283), CARRY => INT_CARRY(223)
	);
---- End FA stage
---- Begin FA stage
FA_224:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(282), DATA_B => INT_SUM(283), DATA_C => INT_CARRY(207), 
		SAVE => INT_SUM(284), CARRY => INT_CARRY(224)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(285) <= INT_CARRY(208); -- At Level 5
---- End NO stage
---- Begin FA stage
FA_225:FULL_ADDER -- At Level 6
	port map
	(
		DATA_A => INT_SUM(284), DATA_B => INT_SUM(285), DATA_C => INT_CARRY(209), 
		SAVE => SUM(32), CARRY => CARRY(32)
	);
---- End FA stage
-- End WT-branch 33

-- Begin WT-branch 34
---- Begin FA stage
FA_226:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(306), DATA_B => SUMMAND(307), DATA_C => SUMMAND(308), 
		SAVE => INT_SUM(286), CARRY => INT_CARRY(225)
	);
---- End FA stage
---- Begin FA stage
FA_227:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(309), DATA_B => SUMMAND(310), DATA_C => SUMMAND(311), 
		SAVE => INT_SUM(287), CARRY => INT_CARRY(226)
	);
---- End FA stage
---- Begin FA stage
FA_228:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(312), DATA_B => SUMMAND(313), DATA_C => SUMMAND(314), 
		SAVE => INT_SUM(288), CARRY => INT_CARRY(227)
	);
---- End FA stage
---- Begin FA stage
FA_229:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(315), DATA_B => SUMMAND(316), DATA_C => SUMMAND(317), 
		SAVE => INT_SUM(289), CARRY => INT_CARRY(228)
	);
---- End FA stage
---- Begin FA stage
FA_230:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(318), DATA_B => SUMMAND(319), DATA_C => SUMMAND(320), 
		SAVE => INT_SUM(290), CARRY => INT_CARRY(229)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(291) <= SUMMAND(321); -- At Level 1
---- End NO stage
---- Begin NO stage
INT_SUM(292) <= SUMMAND(322); -- At Level 1
---- End NO stage
---- Begin FA stage
FA_231:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(286), DATA_B => INT_SUM(287), DATA_C => INT_SUM(288), 
		SAVE => INT_SUM(293), CARRY => INT_CARRY(230)
	);
---- End FA stage
---- Begin FA stage
FA_232:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(289), DATA_B => INT_SUM(290), DATA_C => INT_SUM(291), 
		SAVE => INT_SUM(294), CARRY => INT_CARRY(231)
	);
---- End FA stage
---- Begin FA stage
FA_233:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(292), DATA_B => INT_CARRY(210), DATA_C => INT_CARRY(211), 
		SAVE => INT_SUM(295), CARRY => INT_CARRY(232)
	);
---- End FA stage
---- Begin FA stage
FA_234:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(212), DATA_B => INT_CARRY(213), DATA_C => INT_CARRY(214), 
		SAVE => INT_SUM(296), CARRY => INT_CARRY(233)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(297) <= INT_CARRY(215); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_235:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(293), DATA_B => INT_SUM(294), DATA_C => INT_SUM(295), 
		SAVE => INT_SUM(298), CARRY => INT_CARRY(234)
	);
---- End FA stage
---- Begin FA stage
FA_236:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(296), DATA_B => INT_SUM(297), DATA_C => INT_CARRY(216), 
		SAVE => INT_SUM(299), CARRY => INT_CARRY(235)
	);
---- End FA stage
---- Begin FA stage
FA_237:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_CARRY(217), DATA_B => INT_CARRY(218), DATA_C => INT_CARRY(219), 
		SAVE => INT_SUM(300), CARRY => INT_CARRY(236)
	);
---- End FA stage
---- Begin FA stage
FA_238:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(298), DATA_B => INT_SUM(299), DATA_C => INT_SUM(300), 
		SAVE => INT_SUM(301), CARRY => INT_CARRY(237)
	);
---- End FA stage
---- Begin HA stage
HA_31:HALF_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_CARRY(220), DATA_B => INT_CARRY(221), 
		SAVE => INT_SUM(302), CARRY => INT_CARRY(238)
	);
---- End HA stage
---- Begin FA stage
FA_239:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(301), DATA_B => INT_SUM(302), DATA_C => INT_CARRY(222), 
		SAVE => INT_SUM(303), CARRY => INT_CARRY(239)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(304) <= INT_CARRY(223); -- At Level 5
---- End NO stage
---- Begin FA stage
FA_240:FULL_ADDER -- At Level 6
	port map
	(
		DATA_A => INT_SUM(303), DATA_B => INT_SUM(304), DATA_C => INT_CARRY(224), 
		SAVE => SUM(33), CARRY => CARRY(33)
	);
---- End FA stage
-- End WT-branch 34

-- Begin WT-branch 35
---- Begin FA stage
FA_241:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(323), DATA_B => SUMMAND(324), DATA_C => SUMMAND(325), 
		SAVE => INT_SUM(305), CARRY => INT_CARRY(240)
	);
---- End FA stage
---- Begin FA stage
FA_242:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(326), DATA_B => SUMMAND(327), DATA_C => SUMMAND(328), 
		SAVE => INT_SUM(306), CARRY => INT_CARRY(241)
	);
---- End FA stage
---- Begin FA stage
FA_243:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(329), DATA_B => SUMMAND(330), DATA_C => SUMMAND(331), 
		SAVE => INT_SUM(307), CARRY => INT_CARRY(242)
	);
---- End FA stage
---- Begin FA stage
FA_244:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(332), DATA_B => SUMMAND(333), DATA_C => SUMMAND(334), 
		SAVE => INT_SUM(308), CARRY => INT_CARRY(243)
	);
---- End FA stage
---- Begin FA stage
FA_245:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(335), DATA_B => SUMMAND(336), DATA_C => SUMMAND(337), 
		SAVE => INT_SUM(309), CARRY => INT_CARRY(244)
	);
---- End FA stage
---- Begin FA stage
FA_246:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(338), DATA_B => SUMMAND(339), DATA_C => SUMMAND(340), 
		SAVE => INT_SUM(310), CARRY => INT_CARRY(245)
	);
---- End FA stage
---- Begin FA stage
FA_247:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(305), DATA_B => INT_SUM(306), DATA_C => INT_SUM(307), 
		SAVE => INT_SUM(311), CARRY => INT_CARRY(246)
	);
---- End FA stage
---- Begin FA stage
FA_248:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(308), DATA_B => INT_SUM(309), DATA_C => INT_SUM(310), 
		SAVE => INT_SUM(312), CARRY => INT_CARRY(247)
	);
---- End FA stage
---- Begin FA stage
FA_249:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(225), DATA_B => INT_CARRY(226), DATA_C => INT_CARRY(227), 
		SAVE => INT_SUM(313), CARRY => INT_CARRY(248)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(314) <= INT_CARRY(228); -- At Level 2
---- End NO stage
---- Begin NO stage
INT_SUM(315) <= INT_CARRY(229); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_250:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(311), DATA_B => INT_SUM(312), DATA_C => INT_SUM(313), 
		SAVE => INT_SUM(316), CARRY => INT_CARRY(249)
	);
---- End FA stage
---- Begin FA stage
FA_251:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(314), DATA_B => INT_SUM(315), DATA_C => INT_CARRY(230), 
		SAVE => INT_SUM(317), CARRY => INT_CARRY(250)
	);
---- End FA stage
---- Begin FA stage
FA_252:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_CARRY(231), DATA_B => INT_CARRY(232), DATA_C => INT_CARRY(233), 
		SAVE => INT_SUM(318), CARRY => INT_CARRY(251)
	);
---- End FA stage
---- Begin FA stage
FA_253:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(316), DATA_B => INT_SUM(317), DATA_C => INT_SUM(318), 
		SAVE => INT_SUM(319), CARRY => INT_CARRY(252)
	);
---- End FA stage
---- Begin FA stage
FA_254:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_CARRY(234), DATA_B => INT_CARRY(235), DATA_C => INT_CARRY(236), 
		SAVE => INT_SUM(320), CARRY => INT_CARRY(253)
	);
---- End FA stage
---- Begin FA stage
FA_255:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(319), DATA_B => INT_SUM(320), DATA_C => INT_CARRY(237), 
		SAVE => INT_SUM(321), CARRY => INT_CARRY(254)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(322) <= INT_CARRY(238); -- At Level 5
---- End NO stage
---- Begin FA stage
FA_256:FULL_ADDER -- At Level 6
	port map
	(
		DATA_A => INT_SUM(321), DATA_B => INT_SUM(322), DATA_C => INT_CARRY(239), 
		SAVE => SUM(34), CARRY => CARRY(34)
	);
---- End FA stage
-- End WT-branch 35

-- Begin WT-branch 36
---- Begin FA stage
FA_257:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(341), DATA_B => SUMMAND(342), DATA_C => SUMMAND(343), 
		SAVE => INT_SUM(323), CARRY => INT_CARRY(255)
	);
---- End FA stage
---- Begin FA stage
FA_258:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(344), DATA_B => SUMMAND(345), DATA_C => SUMMAND(346), 
		SAVE => INT_SUM(324), CARRY => INT_CARRY(256)
	);
---- End FA stage
---- Begin FA stage
FA_259:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(347), DATA_B => SUMMAND(348), DATA_C => SUMMAND(349), 
		SAVE => INT_SUM(325), CARRY => INT_CARRY(257)
	);
---- End FA stage
---- Begin FA stage
FA_260:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(350), DATA_B => SUMMAND(351), DATA_C => SUMMAND(352), 
		SAVE => INT_SUM(326), CARRY => INT_CARRY(258)
	);
---- End FA stage
---- Begin FA stage
FA_261:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(353), DATA_B => SUMMAND(354), DATA_C => SUMMAND(355), 
		SAVE => INT_SUM(327), CARRY => INT_CARRY(259)
	);
---- End FA stage
---- Begin HA stage
HA_32:HALF_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(356), DATA_B => SUMMAND(357), 
		SAVE => INT_SUM(328), CARRY => INT_CARRY(260)
	);
---- End HA stage
---- Begin FA stage
FA_262:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(323), DATA_B => INT_SUM(324), DATA_C => INT_SUM(325), 
		SAVE => INT_SUM(329), CARRY => INT_CARRY(261)
	);
---- End FA stage
---- Begin FA stage
FA_263:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(326), DATA_B => INT_SUM(327), DATA_C => INT_SUM(328), 
		SAVE => INT_SUM(330), CARRY => INT_CARRY(262)
	);
---- End FA stage
---- Begin FA stage
FA_264:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(240), DATA_B => INT_CARRY(241), DATA_C => INT_CARRY(242), 
		SAVE => INT_SUM(331), CARRY => INT_CARRY(263)
	);
---- End FA stage
---- Begin FA stage
FA_265:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(243), DATA_B => INT_CARRY(244), DATA_C => INT_CARRY(245), 
		SAVE => INT_SUM(332), CARRY => INT_CARRY(264)
	);
---- End FA stage
---- Begin FA stage
FA_266:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(329), DATA_B => INT_SUM(330), DATA_C => INT_SUM(331), 
		SAVE => INT_SUM(333), CARRY => INT_CARRY(265)
	);
---- End FA stage
---- Begin FA stage
FA_267:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(332), DATA_B => INT_CARRY(246), DATA_C => INT_CARRY(247), 
		SAVE => INT_SUM(334), CARRY => INT_CARRY(266)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(335) <= INT_CARRY(248); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_268:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(333), DATA_B => INT_SUM(334), DATA_C => INT_SUM(335), 
		SAVE => INT_SUM(336), CARRY => INT_CARRY(267)
	);
---- End FA stage
---- Begin FA stage
FA_269:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_CARRY(249), DATA_B => INT_CARRY(250), DATA_C => INT_CARRY(251), 
		SAVE => INT_SUM(337), CARRY => INT_CARRY(268)
	);
---- End FA stage
---- Begin FA stage
FA_270:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(336), DATA_B => INT_SUM(337), DATA_C => INT_CARRY(252), 
		SAVE => INT_SUM(338), CARRY => INT_CARRY(269)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(339) <= INT_CARRY(253); -- At Level 5
---- End NO stage
---- Begin FA stage
FA_271:FULL_ADDER -- At Level 6
	port map
	(
		DATA_A => INT_SUM(338), DATA_B => INT_SUM(339), DATA_C => INT_CARRY(254), 
		SAVE => SUM(35), CARRY => CARRY(35)
	);
---- End FA stage
-- End WT-branch 36

-- Begin WT-branch 37
---- Begin FA stage
FA_272:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(358), DATA_B => SUMMAND(359), DATA_C => SUMMAND(360), 
		SAVE => INT_SUM(340), CARRY => INT_CARRY(270)
	);
---- End FA stage
---- Begin FA stage
FA_273:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(361), DATA_B => SUMMAND(362), DATA_C => SUMMAND(363), 
		SAVE => INT_SUM(341), CARRY => INT_CARRY(271)
	);
---- End FA stage
---- Begin FA stage
FA_274:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(364), DATA_B => SUMMAND(365), DATA_C => SUMMAND(366), 
		SAVE => INT_SUM(342), CARRY => INT_CARRY(272)
	);
---- End FA stage
---- Begin FA stage
FA_275:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(367), DATA_B => SUMMAND(368), DATA_C => SUMMAND(369), 
		SAVE => INT_SUM(343), CARRY => INT_CARRY(273)
	);
---- End FA stage
---- Begin FA stage
FA_276:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(370), DATA_B => SUMMAND(371), DATA_C => SUMMAND(372), 
		SAVE => INT_SUM(344), CARRY => INT_CARRY(274)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(345) <= SUMMAND(373); -- At Level 1
---- End NO stage
---- Begin FA stage
FA_277:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(340), DATA_B => INT_SUM(341), DATA_C => INT_SUM(342), 
		SAVE => INT_SUM(346), CARRY => INT_CARRY(275)
	);
---- End FA stage
---- Begin FA stage
FA_278:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(343), DATA_B => INT_SUM(344), DATA_C => INT_SUM(345), 
		SAVE => INT_SUM(347), CARRY => INT_CARRY(276)
	);
---- End FA stage
---- Begin FA stage
FA_279:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(255), DATA_B => INT_CARRY(256), DATA_C => INT_CARRY(257), 
		SAVE => INT_SUM(348), CARRY => INT_CARRY(277)
	);
---- End FA stage
---- Begin FA stage
FA_280:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(258), DATA_B => INT_CARRY(259), DATA_C => INT_CARRY(260), 
		SAVE => INT_SUM(349), CARRY => INT_CARRY(278)
	);
---- End FA stage
---- Begin FA stage
FA_281:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(346), DATA_B => INT_SUM(347), DATA_C => INT_SUM(348), 
		SAVE => INT_SUM(350), CARRY => INT_CARRY(279)
	);
---- End FA stage
---- Begin FA stage
FA_282:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(349), DATA_B => INT_CARRY(261), DATA_C => INT_CARRY(262), 
		SAVE => INT_SUM(351), CARRY => INT_CARRY(280)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(352) <= INT_CARRY(263); -- At Level 3
---- End NO stage
---- Begin NO stage
INT_SUM(353) <= INT_CARRY(264); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_283:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(350), DATA_B => INT_SUM(351), DATA_C => INT_SUM(352), 
		SAVE => INT_SUM(354), CARRY => INT_CARRY(281)
	);
---- End FA stage
---- Begin FA stage
FA_284:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(353), DATA_B => INT_CARRY(265), DATA_C => INT_CARRY(266), 
		SAVE => INT_SUM(355), CARRY => INT_CARRY(282)
	);
---- End FA stage
---- Begin FA stage
FA_285:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(354), DATA_B => INT_SUM(355), DATA_C => INT_CARRY(267), 
		SAVE => INT_SUM(356), CARRY => INT_CARRY(283)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(357) <= INT_CARRY(268); -- At Level 5
---- End NO stage
---- Begin FA stage
FA_286:FULL_ADDER -- At Level 6
	port map
	(
		DATA_A => INT_SUM(356), DATA_B => INT_SUM(357), DATA_C => INT_CARRY(269), 
		SAVE => SUM(36), CARRY => CARRY(36)
	);
---- End FA stage
-- End WT-branch 37

-- Begin WT-branch 38
---- Begin FA stage
FA_287:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(374), DATA_B => SUMMAND(375), DATA_C => SUMMAND(376), 
		SAVE => INT_SUM(358), CARRY => INT_CARRY(284)
	);
---- End FA stage
---- Begin FA stage
FA_288:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(377), DATA_B => SUMMAND(378), DATA_C => SUMMAND(379), 
		SAVE => INT_SUM(359), CARRY => INT_CARRY(285)
	);
---- End FA stage
---- Begin FA stage
FA_289:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(380), DATA_B => SUMMAND(381), DATA_C => SUMMAND(382), 
		SAVE => INT_SUM(360), CARRY => INT_CARRY(286)
	);
---- End FA stage
---- Begin FA stage
FA_290:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(383), DATA_B => SUMMAND(384), DATA_C => SUMMAND(385), 
		SAVE => INT_SUM(361), CARRY => INT_CARRY(287)
	);
---- End FA stage
---- Begin FA stage
FA_291:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(386), DATA_B => SUMMAND(387), DATA_C => SUMMAND(388), 
		SAVE => INT_SUM(362), CARRY => INT_CARRY(288)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(363) <= SUMMAND(389); -- At Level 1
---- End NO stage
---- Begin FA stage
FA_292:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(358), DATA_B => INT_SUM(359), DATA_C => INT_SUM(360), 
		SAVE => INT_SUM(364), CARRY => INT_CARRY(289)
	);
---- End FA stage
---- Begin FA stage
FA_293:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(361), DATA_B => INT_SUM(362), DATA_C => INT_SUM(363), 
		SAVE => INT_SUM(365), CARRY => INT_CARRY(290)
	);
---- End FA stage
---- Begin FA stage
FA_294:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(270), DATA_B => INT_CARRY(271), DATA_C => INT_CARRY(272), 
		SAVE => INT_SUM(366), CARRY => INT_CARRY(291)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(367) <= INT_CARRY(273); -- At Level 2
---- End NO stage
---- Begin NO stage
INT_SUM(368) <= INT_CARRY(274); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_295:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(364), DATA_B => INT_SUM(365), DATA_C => INT_SUM(366), 
		SAVE => INT_SUM(369), CARRY => INT_CARRY(292)
	);
---- End FA stage
---- Begin FA stage
FA_296:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(367), DATA_B => INT_SUM(368), DATA_C => INT_CARRY(275), 
		SAVE => INT_SUM(370), CARRY => INT_CARRY(293)
	);
---- End FA stage
---- Begin FA stage
FA_297:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_CARRY(276), DATA_B => INT_CARRY(277), DATA_C => INT_CARRY(278), 
		SAVE => INT_SUM(371), CARRY => INT_CARRY(294)
	);
---- End FA stage
---- Begin FA stage
FA_298:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(369), DATA_B => INT_SUM(370), DATA_C => INT_SUM(371), 
		SAVE => INT_SUM(372), CARRY => INT_CARRY(295)
	);
---- End FA stage
---- Begin HA stage
HA_33:HALF_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_CARRY(279), DATA_B => INT_CARRY(280), 
		SAVE => INT_SUM(373), CARRY => INT_CARRY(296)
	);
---- End HA stage
---- Begin FA stage
FA_299:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(372), DATA_B => INT_SUM(373), DATA_C => INT_CARRY(281), 
		SAVE => INT_SUM(374), CARRY => INT_CARRY(297)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(375) <= INT_CARRY(282); -- At Level 5
---- End NO stage
---- Begin FA stage
FA_300:FULL_ADDER -- At Level 6
	port map
	(
		DATA_A => INT_SUM(374), DATA_B => INT_SUM(375), DATA_C => INT_CARRY(283), 
		SAVE => SUM(37), CARRY => CARRY(37)
	);
---- End FA stage
-- End WT-branch 38

-- Begin WT-branch 39
---- Begin FA stage
FA_301:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(390), DATA_B => SUMMAND(391), DATA_C => SUMMAND(392), 
		SAVE => INT_SUM(376), CARRY => INT_CARRY(298)
	);
---- End FA stage
---- Begin FA stage
FA_302:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(393), DATA_B => SUMMAND(394), DATA_C => SUMMAND(395), 
		SAVE => INT_SUM(377), CARRY => INT_CARRY(299)
	);
---- End FA stage
---- Begin FA stage
FA_303:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(396), DATA_B => SUMMAND(397), DATA_C => SUMMAND(398), 
		SAVE => INT_SUM(378), CARRY => INT_CARRY(300)
	);
---- End FA stage
---- Begin FA stage
FA_304:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(399), DATA_B => SUMMAND(400), DATA_C => SUMMAND(401), 
		SAVE => INT_SUM(379), CARRY => INT_CARRY(301)
	);
---- End FA stage
---- Begin FA stage
FA_305:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(402), DATA_B => SUMMAND(403), DATA_C => SUMMAND(404), 
		SAVE => INT_SUM(380), CARRY => INT_CARRY(302)
	);
---- End FA stage
---- Begin FA stage
FA_306:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(376), DATA_B => INT_SUM(377), DATA_C => INT_SUM(378), 
		SAVE => INT_SUM(381), CARRY => INT_CARRY(303)
	);
---- End FA stage
---- Begin FA stage
FA_307:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(379), DATA_B => INT_SUM(380), DATA_C => INT_CARRY(284), 
		SAVE => INT_SUM(382), CARRY => INT_CARRY(304)
	);
---- End FA stage
---- Begin FA stage
FA_308:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(285), DATA_B => INT_CARRY(286), DATA_C => INT_CARRY(287), 
		SAVE => INT_SUM(383), CARRY => INT_CARRY(305)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(384) <= INT_CARRY(288); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_309:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(381), DATA_B => INT_SUM(382), DATA_C => INT_SUM(383), 
		SAVE => INT_SUM(385), CARRY => INT_CARRY(306)
	);
---- End FA stage
---- Begin FA stage
FA_310:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(384), DATA_B => INT_CARRY(289), DATA_C => INT_CARRY(290), 
		SAVE => INT_SUM(386), CARRY => INT_CARRY(307)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(387) <= INT_CARRY(291); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_311:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(385), DATA_B => INT_SUM(386), DATA_C => INT_SUM(387), 
		SAVE => INT_SUM(388), CARRY => INT_CARRY(308)
	);
---- End FA stage
---- Begin FA stage
FA_312:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_CARRY(292), DATA_B => INT_CARRY(293), DATA_C => INT_CARRY(294), 
		SAVE => INT_SUM(389), CARRY => INT_CARRY(309)
	);
---- End FA stage
---- Begin FA stage
FA_313:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(388), DATA_B => INT_SUM(389), DATA_C => INT_CARRY(295), 
		SAVE => INT_SUM(390), CARRY => INT_CARRY(310)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(391) <= INT_CARRY(296); -- At Level 5
---- End NO stage
---- Begin FA stage
FA_314:FULL_ADDER -- At Level 6
	port map
	(
		DATA_A => INT_SUM(390), DATA_B => INT_SUM(391), DATA_C => INT_CARRY(297), 
		SAVE => SUM(38), CARRY => CARRY(38)
	);
---- End FA stage
-- End WT-branch 39

-- Begin WT-branch 40
---- Begin FA stage
FA_315:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(405), DATA_B => SUMMAND(406), DATA_C => SUMMAND(407), 
		SAVE => INT_SUM(392), CARRY => INT_CARRY(311)
	);
---- End FA stage
---- Begin FA stage
FA_316:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(408), DATA_B => SUMMAND(409), DATA_C => SUMMAND(410), 
		SAVE => INT_SUM(393), CARRY => INT_CARRY(312)
	);
---- End FA stage
---- Begin FA stage
FA_317:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(411), DATA_B => SUMMAND(412), DATA_C => SUMMAND(413), 
		SAVE => INT_SUM(394), CARRY => INT_CARRY(313)
	);
---- End FA stage
---- Begin FA stage
FA_318:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(414), DATA_B => SUMMAND(415), DATA_C => SUMMAND(416), 
		SAVE => INT_SUM(395), CARRY => INT_CARRY(314)
	);
---- End FA stage
---- Begin FA stage
FA_319:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(417), DATA_B => SUMMAND(418), DATA_C => SUMMAND(419), 
		SAVE => INT_SUM(396), CARRY => INT_CARRY(315)
	);
---- End FA stage
---- Begin FA stage
FA_320:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(392), DATA_B => INT_SUM(393), DATA_C => INT_SUM(394), 
		SAVE => INT_SUM(397), CARRY => INT_CARRY(316)
	);
---- End FA stage
---- Begin FA stage
FA_321:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(395), DATA_B => INT_SUM(396), DATA_C => INT_CARRY(298), 
		SAVE => INT_SUM(398), CARRY => INT_CARRY(317)
	);
---- End FA stage
---- Begin FA stage
FA_322:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(299), DATA_B => INT_CARRY(300), DATA_C => INT_CARRY(301), 
		SAVE => INT_SUM(399), CARRY => INT_CARRY(318)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(400) <= INT_CARRY(302); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_323:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(397), DATA_B => INT_SUM(398), DATA_C => INT_SUM(399), 
		SAVE => INT_SUM(401), CARRY => INT_CARRY(319)
	);
---- End FA stage
---- Begin FA stage
FA_324:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(400), DATA_B => INT_CARRY(303), DATA_C => INT_CARRY(304), 
		SAVE => INT_SUM(402), CARRY => INT_CARRY(320)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(403) <= INT_CARRY(305); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_325:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(401), DATA_B => INT_SUM(402), DATA_C => INT_SUM(403), 
		SAVE => INT_SUM(404), CARRY => INT_CARRY(321)
	);
---- End FA stage
---- Begin HA stage
HA_34:HALF_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_CARRY(306), DATA_B => INT_CARRY(307), 
		SAVE => INT_SUM(405), CARRY => INT_CARRY(322)
	);
---- End HA stage
---- Begin FA stage
FA_326:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(404), DATA_B => INT_SUM(405), DATA_C => INT_CARRY(308), 
		SAVE => INT_SUM(406), CARRY => INT_CARRY(323)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(407) <= INT_CARRY(309); -- At Level 5
---- End NO stage
---- Begin FA stage
FA_327:FULL_ADDER -- At Level 6
	port map
	(
		DATA_A => INT_SUM(406), DATA_B => INT_SUM(407), DATA_C => INT_CARRY(310), 
		SAVE => SUM(39), CARRY => CARRY(39)
	);
---- End FA stage
-- End WT-branch 40

-- Begin WT-branch 41
---- Begin FA stage
FA_328:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(420), DATA_B => SUMMAND(421), DATA_C => SUMMAND(422), 
		SAVE => INT_SUM(408), CARRY => INT_CARRY(324)
	);
---- End FA stage
---- Begin FA stage
FA_329:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(423), DATA_B => SUMMAND(424), DATA_C => SUMMAND(425), 
		SAVE => INT_SUM(409), CARRY => INT_CARRY(325)
	);
---- End FA stage
---- Begin FA stage
FA_330:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(426), DATA_B => SUMMAND(427), DATA_C => SUMMAND(428), 
		SAVE => INT_SUM(410), CARRY => INT_CARRY(326)
	);
---- End FA stage
---- Begin FA stage
FA_331:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(429), DATA_B => SUMMAND(430), DATA_C => SUMMAND(431), 
		SAVE => INT_SUM(411), CARRY => INT_CARRY(327)
	);
---- End FA stage
---- Begin HA stage
HA_35:HALF_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(432), DATA_B => SUMMAND(433), 
		SAVE => INT_SUM(412), CARRY => INT_CARRY(328)
	);
---- End HA stage
---- Begin FA stage
FA_332:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(408), DATA_B => INT_SUM(409), DATA_C => INT_SUM(410), 
		SAVE => INT_SUM(413), CARRY => INT_CARRY(329)
	);
---- End FA stage
---- Begin FA stage
FA_333:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(411), DATA_B => INT_SUM(412), DATA_C => INT_CARRY(311), 
		SAVE => INT_SUM(414), CARRY => INT_CARRY(330)
	);
---- End FA stage
---- Begin FA stage
FA_334:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(312), DATA_B => INT_CARRY(313), DATA_C => INT_CARRY(314), 
		SAVE => INT_SUM(415), CARRY => INT_CARRY(331)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(416) <= INT_CARRY(315); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_335:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(413), DATA_B => INT_SUM(414), DATA_C => INT_SUM(415), 
		SAVE => INT_SUM(417), CARRY => INT_CARRY(332)
	);
---- End FA stage
---- Begin FA stage
FA_336:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(416), DATA_B => INT_CARRY(316), DATA_C => INT_CARRY(317), 
		SAVE => INT_SUM(418), CARRY => INT_CARRY(333)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(419) <= INT_CARRY(318); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_337:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(417), DATA_B => INT_SUM(418), DATA_C => INT_SUM(419), 
		SAVE => INT_SUM(420), CARRY => INT_CARRY(334)
	);
---- End FA stage
---- Begin HA stage
HA_36:HALF_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_CARRY(319), DATA_B => INT_CARRY(320), 
		SAVE => INT_SUM(421), CARRY => INT_CARRY(335)
	);
---- End HA stage
---- Begin FA stage
FA_338:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(420), DATA_B => INT_SUM(421), DATA_C => INT_CARRY(321), 
		SAVE => INT_SUM(422), CARRY => INT_CARRY(336)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(423) <= INT_CARRY(322); -- At Level 5
---- End NO stage
---- Begin FA stage
FA_339:FULL_ADDER -- At Level 6
	port map
	(
		DATA_A => INT_SUM(422), DATA_B => INT_SUM(423), DATA_C => INT_CARRY(323), 
		SAVE => SUM(40), CARRY => CARRY(40)
	);
---- End FA stage
-- End WT-branch 41

-- Begin WT-branch 42
---- Begin FA stage
FA_340:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(434), DATA_B => SUMMAND(435), DATA_C => SUMMAND(436), 
		SAVE => INT_SUM(424), CARRY => INT_CARRY(337)
	);
---- End FA stage
---- Begin FA stage
FA_341:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(437), DATA_B => SUMMAND(438), DATA_C => SUMMAND(439), 
		SAVE => INT_SUM(425), CARRY => INT_CARRY(338)
	);
---- End FA stage
---- Begin FA stage
FA_342:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(440), DATA_B => SUMMAND(441), DATA_C => SUMMAND(442), 
		SAVE => INT_SUM(426), CARRY => INT_CARRY(339)
	);
---- End FA stage
---- Begin FA stage
FA_343:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(443), DATA_B => SUMMAND(444), DATA_C => SUMMAND(445), 
		SAVE => INT_SUM(427), CARRY => INT_CARRY(340)
	);
---- End FA stage
---- Begin HA stage
HA_37:HALF_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(446), DATA_B => SUMMAND(447), 
		SAVE => INT_SUM(428), CARRY => INT_CARRY(341)
	);
---- End HA stage
---- Begin FA stage
FA_344:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(424), DATA_B => INT_SUM(425), DATA_C => INT_SUM(426), 
		SAVE => INT_SUM(429), CARRY => INT_CARRY(342)
	);
---- End FA stage
---- Begin FA stage
FA_345:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(427), DATA_B => INT_SUM(428), DATA_C => INT_CARRY(324), 
		SAVE => INT_SUM(430), CARRY => INT_CARRY(343)
	);
---- End FA stage
---- Begin FA stage
FA_346:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(325), DATA_B => INT_CARRY(326), DATA_C => INT_CARRY(327), 
		SAVE => INT_SUM(431), CARRY => INT_CARRY(344)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(432) <= INT_CARRY(328); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_347:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(429), DATA_B => INT_SUM(430), DATA_C => INT_SUM(431), 
		SAVE => INT_SUM(433), CARRY => INT_CARRY(345)
	);
---- End FA stage
---- Begin FA stage
FA_348:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(432), DATA_B => INT_CARRY(329), DATA_C => INT_CARRY(330), 
		SAVE => INT_SUM(434), CARRY => INT_CARRY(346)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(435) <= INT_CARRY(331); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_349:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(433), DATA_B => INT_SUM(434), DATA_C => INT_SUM(435), 
		SAVE => INT_SUM(436), CARRY => INT_CARRY(347)
	);
---- End FA stage
---- Begin HA stage
HA_38:HALF_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_CARRY(332), DATA_B => INT_CARRY(333), 
		SAVE => INT_SUM(437), CARRY => INT_CARRY(348)
	);
---- End HA stage
---- Begin FA stage
FA_350:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(436), DATA_B => INT_SUM(437), DATA_C => INT_CARRY(334), 
		SAVE => INT_SUM(438), CARRY => INT_CARRY(349)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(439) <= INT_CARRY(335); -- At Level 5
---- End NO stage
---- Begin FA stage
FA_351:FULL_ADDER -- At Level 6
	port map
	(
		DATA_A => INT_SUM(438), DATA_B => INT_SUM(439), DATA_C => INT_CARRY(336), 
		SAVE => SUM(41), CARRY => CARRY(41)
	);
---- End FA stage
-- End WT-branch 42

-- Begin WT-branch 43
---- Begin FA stage
FA_352:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(448), DATA_B => SUMMAND(449), DATA_C => SUMMAND(450), 
		SAVE => INT_SUM(440), CARRY => INT_CARRY(350)
	);
---- End FA stage
---- Begin FA stage
FA_353:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(451), DATA_B => SUMMAND(452), DATA_C => SUMMAND(453), 
		SAVE => INT_SUM(441), CARRY => INT_CARRY(351)
	);
---- End FA stage
---- Begin FA stage
FA_354:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(454), DATA_B => SUMMAND(455), DATA_C => SUMMAND(456), 
		SAVE => INT_SUM(442), CARRY => INT_CARRY(352)
	);
---- End FA stage
---- Begin FA stage
FA_355:FULL_ADDER -- At Level 1
	port map
	(
		DATA_A => SUMMAND(457), DATA_B => SUMMAND(458), DATA_C => SUMMAND(459), 
		SAVE => INT_SUM(443), CARRY => INT_CARRY(353)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(444) <= SUMMAND(460); -- At Level 1
---- End NO stage
---- Begin FA stage
FA_356:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(440), DATA_B => INT_SUM(441), DATA_C => INT_SUM(442), 
		SAVE => INT_SUM(445), CARRY => INT_CARRY(354)
	);
---- End FA stage
---- Begin FA stage
FA_357:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_SUM(443), DATA_B => INT_SUM(444), DATA_C => INT_CARRY(337), 
		SAVE => INT_SUM(446), CARRY => INT_CARRY(355)
	);
---- End FA stage
---- Begin FA stage
FA_358:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => INT_CARRY(338), DATA_B => INT_CARRY(339), DATA_C => INT_CARRY(340), 
		SAVE => INT_SUM(447), CARRY => INT_CARRY(356)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(448) <= INT_CARRY(341); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_359:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(445), DATA_B => INT_SUM(446), DATA_C => INT_SUM(447), 
		SAVE => INT_SUM(449), CARRY => INT_CARRY(357)
	);
---- End FA stage
---- Begin FA stage
FA_360:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(448), DATA_B => INT_CARRY(342), DATA_C => INT_CARRY(343), 
		SAVE => INT_SUM(450), CARRY => INT_CARRY(358)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(451) <= INT_CARRY(344); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_361:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(449), DATA_B => INT_SUM(450), DATA_C => INT_SUM(451), 
		SAVE => INT_SUM(452), CARRY => INT_CARRY(359)
	);
---- End FA stage
---- Begin HA stage
HA_39:HALF_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_CARRY(345), DATA_B => INT_CARRY(346), 
		SAVE => INT_SUM(453), CARRY => INT_CARRY(360)
	);
---- End HA stage
---- Begin FA stage
FA_362:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(452), DATA_B => INT_SUM(453), DATA_C => INT_CARRY(347), 
		SAVE => INT_SUM(454), CARRY => INT_CARRY(361)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(455) <= INT_CARRY(348); -- At Level 5
---- End NO stage
---- Begin FA stage
FA_363:FULL_ADDER -- At Level 6
	port map
	(
		DATA_A => INT_SUM(454), DATA_B => INT_SUM(455), DATA_C => INT_CARRY(349), 
		SAVE => SUM(42), CARRY => CARRY(42)
	);
---- End FA stage
-- End WT-branch 43

-- Begin WT-branch 44
---- Begin FA stage
FA_364:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(461), DATA_B => SUMMAND(462), DATA_C => SUMMAND(463), 
		SAVE => INT_SUM(456), CARRY => INT_CARRY(362)
	);
---- End FA stage
---- Begin FA stage
FA_365:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(464), DATA_B => SUMMAND(465), DATA_C => SUMMAND(466), 
		SAVE => INT_SUM(457), CARRY => INT_CARRY(363)
	);
---- End FA stage
---- Begin FA stage
FA_366:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(467), DATA_B => SUMMAND(468), DATA_C => SUMMAND(469), 
		SAVE => INT_SUM(458), CARRY => INT_CARRY(364)
	);
---- End FA stage
---- Begin FA stage
FA_367:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(470), DATA_B => SUMMAND(471), DATA_C => SUMMAND(472), 
		SAVE => INT_SUM(459), CARRY => INT_CARRY(365)
	);
---- End FA stage
---- Begin FA stage
FA_368:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(473), DATA_B => INT_CARRY(350), DATA_C => INT_CARRY(351), 
		SAVE => INT_SUM(460), CARRY => INT_CARRY(366)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(461) <= INT_CARRY(352); -- At Level 2
---- End NO stage
---- Begin NO stage
INT_SUM(462) <= INT_CARRY(353); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_369:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(456), DATA_B => INT_SUM(457), DATA_C => INT_SUM(458), 
		SAVE => INT_SUM(463), CARRY => INT_CARRY(367)
	);
---- End FA stage
---- Begin FA stage
FA_370:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(459), DATA_B => INT_SUM(460), DATA_C => INT_SUM(461), 
		SAVE => INT_SUM(464), CARRY => INT_CARRY(368)
	);
---- End FA stage
---- Begin FA stage
FA_371:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(462), DATA_B => INT_CARRY(354), DATA_C => INT_CARRY(355), 
		SAVE => INT_SUM(465), CARRY => INT_CARRY(369)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(466) <= INT_CARRY(356); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_372:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(463), DATA_B => INT_SUM(464), DATA_C => INT_SUM(465), 
		SAVE => INT_SUM(467), CARRY => INT_CARRY(370)
	);
---- End FA stage
---- Begin FA stage
FA_373:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(466), DATA_B => INT_CARRY(357), DATA_C => INT_CARRY(358), 
		SAVE => INT_SUM(468), CARRY => INT_CARRY(371)
	);
---- End FA stage
---- Begin FA stage
FA_374:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(467), DATA_B => INT_SUM(468), DATA_C => INT_CARRY(359), 
		SAVE => INT_SUM(469), CARRY => INT_CARRY(372)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(470) <= INT_CARRY(360); -- At Level 5
---- End NO stage
---- Begin FA stage
FA_375:FULL_ADDER -- At Level 6
	port map
	(
		DATA_A => INT_SUM(469), DATA_B => INT_SUM(470), DATA_C => INT_CARRY(361), 
		SAVE => SUM(43), CARRY => CARRY(43)
	);
---- End FA stage
-- End WT-branch 44

-- Begin WT-branch 45
---- Begin FA stage
FA_376:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(474), DATA_B => SUMMAND(475), DATA_C => SUMMAND(476), 
		SAVE => INT_SUM(471), CARRY => INT_CARRY(373)
	);
---- End FA stage
---- Begin FA stage
FA_377:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(477), DATA_B => SUMMAND(478), DATA_C => SUMMAND(479), 
		SAVE => INT_SUM(472), CARRY => INT_CARRY(374)
	);
---- End FA stage
---- Begin FA stage
FA_378:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(480), DATA_B => SUMMAND(481), DATA_C => SUMMAND(482), 
		SAVE => INT_SUM(473), CARRY => INT_CARRY(375)
	);
---- End FA stage
---- Begin FA stage
FA_379:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(483), DATA_B => SUMMAND(484), DATA_C => SUMMAND(485), 
		SAVE => INT_SUM(474), CARRY => INT_CARRY(376)
	);
---- End FA stage
---- Begin FA stage
FA_380:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(471), DATA_B => INT_SUM(472), DATA_C => INT_SUM(473), 
		SAVE => INT_SUM(475), CARRY => INT_CARRY(377)
	);
---- End FA stage
---- Begin FA stage
FA_381:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(474), DATA_B => INT_CARRY(362), DATA_C => INT_CARRY(363), 
		SAVE => INT_SUM(476), CARRY => INT_CARRY(378)
	);
---- End FA stage
---- Begin FA stage
FA_382:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_CARRY(364), DATA_B => INT_CARRY(365), DATA_C => INT_CARRY(366), 
		SAVE => INT_SUM(477), CARRY => INT_CARRY(379)
	);
---- End FA stage
---- Begin FA stage
FA_383:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(475), DATA_B => INT_SUM(476), DATA_C => INT_SUM(477), 
		SAVE => INT_SUM(478), CARRY => INT_CARRY(380)
	);
---- End FA stage
---- Begin FA stage
FA_384:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_CARRY(367), DATA_B => INT_CARRY(368), DATA_C => INT_CARRY(369), 
		SAVE => INT_SUM(479), CARRY => INT_CARRY(381)
	);
---- End FA stage
---- Begin FA stage
FA_385:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(478), DATA_B => INT_SUM(479), DATA_C => INT_CARRY(370), 
		SAVE => INT_SUM(480), CARRY => INT_CARRY(382)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(481) <= INT_CARRY(371); -- At Level 5
---- End NO stage
---- Begin FA stage
FA_386:FULL_ADDER -- At Level 6
	port map
	(
		DATA_A => INT_SUM(480), DATA_B => INT_SUM(481), DATA_C => INT_CARRY(372), 
		SAVE => SUM(44), CARRY => CARRY(44)
	);
---- End FA stage
-- End WT-branch 45

-- Begin WT-branch 46
---- Begin FA stage
FA_387:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(486), DATA_B => SUMMAND(487), DATA_C => SUMMAND(488), 
		SAVE => INT_SUM(482), CARRY => INT_CARRY(383)
	);
---- End FA stage
---- Begin FA stage
FA_388:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(489), DATA_B => SUMMAND(490), DATA_C => SUMMAND(491), 
		SAVE => INT_SUM(483), CARRY => INT_CARRY(384)
	);
---- End FA stage
---- Begin FA stage
FA_389:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(492), DATA_B => SUMMAND(493), DATA_C => SUMMAND(494), 
		SAVE => INT_SUM(484), CARRY => INT_CARRY(385)
	);
---- End FA stage
---- Begin FA stage
FA_390:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(495), DATA_B => SUMMAND(496), DATA_C => SUMMAND(497), 
		SAVE => INT_SUM(485), CARRY => INT_CARRY(386)
	);
---- End FA stage
---- Begin FA stage
FA_391:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(482), DATA_B => INT_SUM(483), DATA_C => INT_SUM(484), 
		SAVE => INT_SUM(486), CARRY => INT_CARRY(387)
	);
---- End FA stage
---- Begin FA stage
FA_392:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(485), DATA_B => INT_CARRY(373), DATA_C => INT_CARRY(374), 
		SAVE => INT_SUM(487), CARRY => INT_CARRY(388)
	);
---- End FA stage
---- Begin HA stage
HA_40:HALF_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_CARRY(375), DATA_B => INT_CARRY(376), 
		SAVE => INT_SUM(488), CARRY => INT_CARRY(389)
	);
---- End HA stage
---- Begin FA stage
FA_393:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(486), DATA_B => INT_SUM(487), DATA_C => INT_SUM(488), 
		SAVE => INT_SUM(489), CARRY => INT_CARRY(390)
	);
---- End FA stage
---- Begin FA stage
FA_394:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_CARRY(377), DATA_B => INT_CARRY(378), DATA_C => INT_CARRY(379), 
		SAVE => INT_SUM(490), CARRY => INT_CARRY(391)
	);
---- End FA stage
---- Begin FA stage
FA_395:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(489), DATA_B => INT_SUM(490), DATA_C => INT_CARRY(380), 
		SAVE => INT_SUM(491), CARRY => INT_CARRY(392)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(492) <= INT_CARRY(381); -- At Level 5
---- End NO stage
---- Begin FA stage
FA_396:FULL_ADDER -- At Level 6
	port map
	(
		DATA_A => INT_SUM(491), DATA_B => INT_SUM(492), DATA_C => INT_CARRY(382), 
		SAVE => SUM(45), CARRY => CARRY(45)
	);
---- End FA stage
-- End WT-branch 46

-- Begin WT-branch 47
---- Begin FA stage
FA_397:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(498), DATA_B => SUMMAND(499), DATA_C => SUMMAND(500), 
		SAVE => INT_SUM(493), CARRY => INT_CARRY(393)
	);
---- End FA stage
---- Begin FA stage
FA_398:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(501), DATA_B => SUMMAND(502), DATA_C => SUMMAND(503), 
		SAVE => INT_SUM(494), CARRY => INT_CARRY(394)
	);
---- End FA stage
---- Begin FA stage
FA_399:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(504), DATA_B => SUMMAND(505), DATA_C => SUMMAND(506), 
		SAVE => INT_SUM(495), CARRY => INT_CARRY(395)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(496) <= SUMMAND(507); -- At Level 2
---- End NO stage
---- Begin NO stage
INT_SUM(497) <= SUMMAND(508); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_400:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(493), DATA_B => INT_SUM(494), DATA_C => INT_SUM(495), 
		SAVE => INT_SUM(498), CARRY => INT_CARRY(396)
	);
---- End FA stage
---- Begin FA stage
FA_401:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(496), DATA_B => INT_SUM(497), DATA_C => INT_CARRY(383), 
		SAVE => INT_SUM(499), CARRY => INT_CARRY(397)
	);
---- End FA stage
---- Begin FA stage
FA_402:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_CARRY(384), DATA_B => INT_CARRY(385), DATA_C => INT_CARRY(386), 
		SAVE => INT_SUM(500), CARRY => INT_CARRY(398)
	);
---- End FA stage
---- Begin FA stage
FA_403:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(498), DATA_B => INT_SUM(499), DATA_C => INT_SUM(500), 
		SAVE => INT_SUM(501), CARRY => INT_CARRY(399)
	);
---- End FA stage
---- Begin FA stage
FA_404:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_CARRY(387), DATA_B => INT_CARRY(388), DATA_C => INT_CARRY(389), 
		SAVE => INT_SUM(502), CARRY => INT_CARRY(400)
	);
---- End FA stage
---- Begin FA stage
FA_405:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(501), DATA_B => INT_SUM(502), DATA_C => INT_CARRY(390), 
		SAVE => INT_SUM(503), CARRY => INT_CARRY(401)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(504) <= INT_CARRY(391); -- At Level 5
---- End NO stage
---- Begin FA stage
FA_406:FULL_ADDER -- At Level 6
	port map
	(
		DATA_A => INT_SUM(503), DATA_B => INT_SUM(504), DATA_C => INT_CARRY(392), 
		SAVE => SUM(46), CARRY => CARRY(46)
	);
---- End FA stage
-- End WT-branch 47

-- Begin WT-branch 48
---- Begin FA stage
FA_407:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(509), DATA_B => SUMMAND(510), DATA_C => SUMMAND(511), 
		SAVE => INT_SUM(505), CARRY => INT_CARRY(402)
	);
---- End FA stage
---- Begin FA stage
FA_408:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(512), DATA_B => SUMMAND(513), DATA_C => SUMMAND(514), 
		SAVE => INT_SUM(506), CARRY => INT_CARRY(403)
	);
---- End FA stage
---- Begin FA stage
FA_409:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(515), DATA_B => SUMMAND(516), DATA_C => SUMMAND(517), 
		SAVE => INT_SUM(507), CARRY => INT_CARRY(404)
	);
---- End FA stage
---- Begin HA stage
HA_41:HALF_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(518), DATA_B => SUMMAND(519), 
		SAVE => INT_SUM(508), CARRY => INT_CARRY(405)
	);
---- End HA stage
---- Begin FA stage
FA_410:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(505), DATA_B => INT_SUM(506), DATA_C => INT_SUM(507), 
		SAVE => INT_SUM(509), CARRY => INT_CARRY(406)
	);
---- End FA stage
---- Begin FA stage
FA_411:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(508), DATA_B => INT_CARRY(393), DATA_C => INT_CARRY(394), 
		SAVE => INT_SUM(510), CARRY => INT_CARRY(407)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(511) <= INT_CARRY(395); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_412:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(509), DATA_B => INT_SUM(510), DATA_C => INT_SUM(511), 
		SAVE => INT_SUM(512), CARRY => INT_CARRY(408)
	);
---- End FA stage
---- Begin FA stage
FA_413:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_CARRY(396), DATA_B => INT_CARRY(397), DATA_C => INT_CARRY(398), 
		SAVE => INT_SUM(513), CARRY => INT_CARRY(409)
	);
---- End FA stage
---- Begin FA stage
FA_414:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(512), DATA_B => INT_SUM(513), DATA_C => INT_CARRY(399), 
		SAVE => INT_SUM(514), CARRY => INT_CARRY(410)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(515) <= INT_CARRY(400); -- At Level 5
---- End NO stage
---- Begin FA stage
FA_415:FULL_ADDER -- At Level 6
	port map
	(
		DATA_A => INT_SUM(514), DATA_B => INT_SUM(515), DATA_C => INT_CARRY(401), 
		SAVE => SUM(47), CARRY => CARRY(47)
	);
---- End FA stage
-- End WT-branch 48

-- Begin WT-branch 49
---- Begin FA stage
FA_416:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(520), DATA_B => SUMMAND(521), DATA_C => SUMMAND(522), 
		SAVE => INT_SUM(516), CARRY => INT_CARRY(411)
	);
---- End FA stage
---- Begin FA stage
FA_417:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(523), DATA_B => SUMMAND(524), DATA_C => SUMMAND(525), 
		SAVE => INT_SUM(517), CARRY => INT_CARRY(412)
	);
---- End FA stage
---- Begin FA stage
FA_418:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(526), DATA_B => SUMMAND(527), DATA_C => SUMMAND(528), 
		SAVE => INT_SUM(518), CARRY => INT_CARRY(413)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(519) <= SUMMAND(529); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_419:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(516), DATA_B => INT_SUM(517), DATA_C => INT_SUM(518), 
		SAVE => INT_SUM(520), CARRY => INT_CARRY(414)
	);
---- End FA stage
---- Begin FA stage
FA_420:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(519), DATA_B => INT_CARRY(402), DATA_C => INT_CARRY(403), 
		SAVE => INT_SUM(521), CARRY => INT_CARRY(415)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(522) <= INT_CARRY(404); -- At Level 3
---- End NO stage
---- Begin NO stage
INT_SUM(523) <= INT_CARRY(405); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_421:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(520), DATA_B => INT_SUM(521), DATA_C => INT_SUM(522), 
		SAVE => INT_SUM(524), CARRY => INT_CARRY(416)
	);
---- End FA stage
---- Begin FA stage
FA_422:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(523), DATA_B => INT_CARRY(406), DATA_C => INT_CARRY(407), 
		SAVE => INT_SUM(525), CARRY => INT_CARRY(417)
	);
---- End FA stage
---- Begin FA stage
FA_423:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(524), DATA_B => INT_SUM(525), DATA_C => INT_CARRY(408), 
		SAVE => INT_SUM(526), CARRY => INT_CARRY(418)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(527) <= INT_CARRY(409); -- At Level 5
---- End NO stage
---- Begin FA stage
FA_424:FULL_ADDER -- At Level 6
	port map
	(
		DATA_A => INT_SUM(526), DATA_B => INT_SUM(527), DATA_C => INT_CARRY(410), 
		SAVE => SUM(48), CARRY => CARRY(48)
	);
---- End FA stage
-- End WT-branch 49

-- Begin WT-branch 50
---- Begin FA stage
FA_425:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(530), DATA_B => SUMMAND(531), DATA_C => SUMMAND(532), 
		SAVE => INT_SUM(528), CARRY => INT_CARRY(419)
	);
---- End FA stage
---- Begin FA stage
FA_426:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(533), DATA_B => SUMMAND(534), DATA_C => SUMMAND(535), 
		SAVE => INT_SUM(529), CARRY => INT_CARRY(420)
	);
---- End FA stage
---- Begin FA stage
FA_427:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(536), DATA_B => SUMMAND(537), DATA_C => SUMMAND(538), 
		SAVE => INT_SUM(530), CARRY => INT_CARRY(421)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(531) <= SUMMAND(539); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_428:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(528), DATA_B => INT_SUM(529), DATA_C => INT_SUM(530), 
		SAVE => INT_SUM(532), CARRY => INT_CARRY(422)
	);
---- End FA stage
---- Begin FA stage
FA_429:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(531), DATA_B => INT_CARRY(411), DATA_C => INT_CARRY(412), 
		SAVE => INT_SUM(533), CARRY => INT_CARRY(423)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(534) <= INT_CARRY(413); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_430:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(532), DATA_B => INT_SUM(533), DATA_C => INT_SUM(534), 
		SAVE => INT_SUM(535), CARRY => INT_CARRY(424)
	);
---- End FA stage
---- Begin HA stage
HA_42:HALF_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_CARRY(414), DATA_B => INT_CARRY(415), 
		SAVE => INT_SUM(536), CARRY => INT_CARRY(425)
	);
---- End HA stage
---- Begin FA stage
FA_431:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(535), DATA_B => INT_SUM(536), DATA_C => INT_CARRY(416), 
		SAVE => INT_SUM(537), CARRY => INT_CARRY(426)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(538) <= INT_CARRY(417); -- At Level 5
---- End NO stage
---- Begin FA stage
FA_432:FULL_ADDER -- At Level 6
	port map
	(
		DATA_A => INT_SUM(537), DATA_B => INT_SUM(538), DATA_C => INT_CARRY(418), 
		SAVE => SUM(49), CARRY => CARRY(49)
	);
---- End FA stage
-- End WT-branch 50

-- Begin WT-branch 51
---- Begin FA stage
FA_433:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(540), DATA_B => SUMMAND(541), DATA_C => SUMMAND(542), 
		SAVE => INT_SUM(539), CARRY => INT_CARRY(427)
	);
---- End FA stage
---- Begin FA stage
FA_434:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(543), DATA_B => SUMMAND(544), DATA_C => SUMMAND(545), 
		SAVE => INT_SUM(540), CARRY => INT_CARRY(428)
	);
---- End FA stage
---- Begin FA stage
FA_435:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(546), DATA_B => SUMMAND(547), DATA_C => SUMMAND(548), 
		SAVE => INT_SUM(541), CARRY => INT_CARRY(429)
	);
---- End FA stage
---- Begin FA stage
FA_436:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(539), DATA_B => INT_SUM(540), DATA_C => INT_SUM(541), 
		SAVE => INT_SUM(542), CARRY => INT_CARRY(430)
	);
---- End FA stage
---- Begin FA stage
FA_437:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_CARRY(419), DATA_B => INT_CARRY(420), DATA_C => INT_CARRY(421), 
		SAVE => INT_SUM(543), CARRY => INT_CARRY(431)
	);
---- End FA stage
---- Begin FA stage
FA_438:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(542), DATA_B => INT_SUM(543), DATA_C => INT_CARRY(422), 
		SAVE => INT_SUM(544), CARRY => INT_CARRY(432)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(545) <= INT_CARRY(423); -- At Level 4
---- End NO stage
---- Begin FA stage
FA_439:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(544), DATA_B => INT_SUM(545), DATA_C => INT_CARRY(424), 
		SAVE => INT_SUM(546), CARRY => INT_CARRY(433)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(547) <= INT_CARRY(425); -- At Level 5
---- End NO stage
---- Begin FA stage
FA_440:FULL_ADDER -- At Level 6
	port map
	(
		DATA_A => INT_SUM(546), DATA_B => INT_SUM(547), DATA_C => INT_CARRY(426), 
		SAVE => SUM(50), CARRY => CARRY(50)
	);
---- End FA stage
-- End WT-branch 51

-- Begin WT-branch 52
---- Begin FA stage
FA_441:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(549), DATA_B => SUMMAND(550), DATA_C => SUMMAND(551), 
		SAVE => INT_SUM(548), CARRY => INT_CARRY(434)
	);
---- End FA stage
---- Begin FA stage
FA_442:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(552), DATA_B => SUMMAND(553), DATA_C => SUMMAND(554), 
		SAVE => INT_SUM(549), CARRY => INT_CARRY(435)
	);
---- End FA stage
---- Begin FA stage
FA_443:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(555), DATA_B => SUMMAND(556), DATA_C => SUMMAND(557), 
		SAVE => INT_SUM(550), CARRY => INT_CARRY(436)
	);
---- End FA stage
---- Begin FA stage
FA_444:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(548), DATA_B => INT_SUM(549), DATA_C => INT_SUM(550), 
		SAVE => INT_SUM(551), CARRY => INT_CARRY(437)
	);
---- End FA stage
---- Begin FA stage
FA_445:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_CARRY(427), DATA_B => INT_CARRY(428), DATA_C => INT_CARRY(429), 
		SAVE => INT_SUM(552), CARRY => INT_CARRY(438)
	);
---- End FA stage
---- Begin FA stage
FA_446:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(551), DATA_B => INT_SUM(552), DATA_C => INT_CARRY(430), 
		SAVE => INT_SUM(553), CARRY => INT_CARRY(439)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(554) <= INT_CARRY(431); -- At Level 4
---- End NO stage
---- Begin FA stage
FA_447:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(553), DATA_B => INT_SUM(554), DATA_C => INT_CARRY(432), 
		SAVE => INT_SUM(555), CARRY => INT_CARRY(440)
	);
---- End FA stage
---- Begin HA stage
HA_43:HALF_ADDER -- At Level 6
	port map
	(
		DATA_A => INT_SUM(555), DATA_B => INT_CARRY(433), 
		SAVE => SUM(51), CARRY => CARRY(51)
	);
---- End HA stage
-- End WT-branch 52

-- Begin WT-branch 53
---- Begin FA stage
FA_448:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => SUMMAND(558), DATA_B => SUMMAND(559), DATA_C => SUMMAND(560), 
		SAVE => INT_SUM(556), CARRY => INT_CARRY(441)
	);
---- End FA stage
---- Begin FA stage
FA_449:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => SUMMAND(561), DATA_B => SUMMAND(562), DATA_C => SUMMAND(563), 
		SAVE => INT_SUM(557), CARRY => INT_CARRY(442)
	);
---- End FA stage
---- Begin FA stage
FA_450:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => SUMMAND(564), DATA_B => SUMMAND(565), DATA_C => INT_CARRY(434), 
		SAVE => INT_SUM(558), CARRY => INT_CARRY(443)
	);
---- End FA stage
---- Begin HA stage
HA_44:HALF_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_CARRY(435), DATA_B => INT_CARRY(436), 
		SAVE => INT_SUM(559), CARRY => INT_CARRY(444)
	);
---- End HA stage
---- Begin FA stage
FA_451:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(556), DATA_B => INT_SUM(557), DATA_C => INT_SUM(558), 
		SAVE => INT_SUM(560), CARRY => INT_CARRY(445)
	);
---- End FA stage
---- Begin FA stage
FA_452:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(559), DATA_B => INT_CARRY(437), DATA_C => INT_CARRY(438), 
		SAVE => INT_SUM(561), CARRY => INT_CARRY(446)
	);
---- End FA stage
---- Begin FA stage
FA_453:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(560), DATA_B => INT_SUM(561), DATA_C => INT_CARRY(439), 
		SAVE => INT_SUM(562), CARRY => INT_CARRY(447)
	);
---- End FA stage
---- Begin HA stage
HA_45:HALF_ADDER -- At Level 6
	port map
	(
		DATA_A => INT_SUM(562), DATA_B => INT_CARRY(440), 
		SAVE => SUM(52), CARRY => CARRY(52)
	);
---- End HA stage
-- End WT-branch 53

-- Begin WT-branch 54
---- Begin FA stage
FA_454:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(566), DATA_B => SUMMAND(567), DATA_C => SUMMAND(568), 
		SAVE => INT_SUM(563), CARRY => INT_CARRY(448)
	);
---- End FA stage
---- Begin FA stage
FA_455:FULL_ADDER -- At Level 2
	port map
	(
		DATA_A => SUMMAND(569), DATA_B => SUMMAND(570), DATA_C => SUMMAND(571), 
		SAVE => INT_SUM(564), CARRY => INT_CARRY(449)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(565) <= SUMMAND(572); -- At Level 2
---- End NO stage
---- Begin NO stage
INT_SUM(566) <= SUMMAND(573); -- At Level 2
---- End NO stage
---- Begin FA stage
FA_456:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => INT_SUM(563), DATA_B => INT_SUM(564), DATA_C => INT_SUM(565), 
		SAVE => INT_SUM(567), CARRY => INT_CARRY(450)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(568) <= INT_SUM(566); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_457:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(567), DATA_B => INT_SUM(568), DATA_C => INT_CARRY(441), 
		SAVE => INT_SUM(569), CARRY => INT_CARRY(451)
	);
---- End FA stage
---- Begin FA stage
FA_458:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_CARRY(442), DATA_B => INT_CARRY(443), DATA_C => INT_CARRY(444), 
		SAVE => INT_SUM(570), CARRY => INT_CARRY(452)
	);
---- End FA stage
---- Begin FA stage
FA_459:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(569), DATA_B => INT_SUM(570), DATA_C => INT_CARRY(445), 
		SAVE => INT_SUM(571), CARRY => INT_CARRY(453)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(572) <= INT_CARRY(446); -- At Level 5
---- End NO stage
---- Begin FA stage
FA_460:FULL_ADDER -- At Level 6
	port map
	(
		DATA_A => INT_SUM(571), DATA_B => INT_SUM(572), DATA_C => INT_CARRY(447), 
		SAVE => SUM(53), CARRY => CARRY(53)
	);
---- End FA stage
-- End WT-branch 54

-- Begin WT-branch 55
---- Begin FA stage
FA_461:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => SUMMAND(574), DATA_B => SUMMAND(575), DATA_C => SUMMAND(576), 
		SAVE => INT_SUM(573), CARRY => INT_CARRY(454)
	);
---- End FA stage
---- Begin FA stage
FA_462:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => SUMMAND(577), DATA_B => SUMMAND(578), DATA_C => SUMMAND(579), 
		SAVE => INT_SUM(574), CARRY => INT_CARRY(455)
	);
---- End FA stage
---- Begin FA stage
FA_463:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => SUMMAND(580), DATA_B => INT_CARRY(448), DATA_C => INT_CARRY(449), 
		SAVE => INT_SUM(575), CARRY => INT_CARRY(456)
	);
---- End FA stage
---- Begin FA stage
FA_464:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(573), DATA_B => INT_SUM(574), DATA_C => INT_SUM(575), 
		SAVE => INT_SUM(576), CARRY => INT_CARRY(457)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(577) <= INT_CARRY(450); -- At Level 4
---- End NO stage
---- Begin FA stage
FA_465:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(576), DATA_B => INT_SUM(577), DATA_C => INT_CARRY(451), 
		SAVE => INT_SUM(578), CARRY => INT_CARRY(458)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(579) <= INT_CARRY(452); -- At Level 5
---- End NO stage
---- Begin FA stage
FA_466:FULL_ADDER -- At Level 6
	port map
	(
		DATA_A => INT_SUM(578), DATA_B => INT_SUM(579), DATA_C => INT_CARRY(453), 
		SAVE => SUM(54), CARRY => CARRY(54)
	);
---- End FA stage
-- End WT-branch 55

-- Begin WT-branch 56
---- Begin FA stage
FA_467:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => SUMMAND(581), DATA_B => SUMMAND(582), DATA_C => SUMMAND(583), 
		SAVE => INT_SUM(580), CARRY => INT_CARRY(459)
	);
---- End FA stage
---- Begin FA stage
FA_468:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => SUMMAND(584), DATA_B => SUMMAND(585), DATA_C => SUMMAND(586), 
		SAVE => INT_SUM(581), CARRY => INT_CARRY(460)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(582) <= SUMMAND(587); -- At Level 3
---- End NO stage
---- Begin FA stage
FA_469:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(580), DATA_B => INT_SUM(581), DATA_C => INT_SUM(582), 
		SAVE => INT_SUM(583), CARRY => INT_CARRY(461)
	);
---- End FA stage
---- Begin FA stage
FA_470:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_CARRY(454), DATA_B => INT_CARRY(455), DATA_C => INT_CARRY(456), 
		SAVE => INT_SUM(584), CARRY => INT_CARRY(462)
	);
---- End FA stage
---- Begin FA stage
FA_471:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(583), DATA_B => INT_SUM(584), DATA_C => INT_CARRY(457), 
		SAVE => INT_SUM(585), CARRY => INT_CARRY(463)
	);
---- End FA stage
---- Begin HA stage
HA_46:HALF_ADDER -- At Level 6
	port map
	(
		DATA_A => INT_SUM(585), DATA_B => INT_CARRY(458), 
		SAVE => SUM(55), CARRY => CARRY(55)
	);
---- End HA stage
-- End WT-branch 56

-- Begin WT-branch 57
---- Begin FA stage
FA_472:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => SUMMAND(588), DATA_B => SUMMAND(589), DATA_C => SUMMAND(590), 
		SAVE => INT_SUM(586), CARRY => INT_CARRY(464)
	);
---- End FA stage
---- Begin FA stage
FA_473:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => SUMMAND(591), DATA_B => SUMMAND(592), DATA_C => SUMMAND(593), 
		SAVE => INT_SUM(587), CARRY => INT_CARRY(465)
	);
---- End FA stage
---- Begin FA stage
FA_474:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(586), DATA_B => INT_SUM(587), DATA_C => INT_CARRY(459), 
		SAVE => INT_SUM(588), CARRY => INT_CARRY(466)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(589) <= INT_CARRY(460); -- At Level 4
---- End NO stage
---- Begin FA stage
FA_475:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(588), DATA_B => INT_SUM(589), DATA_C => INT_CARRY(461), 
		SAVE => INT_SUM(590), CARRY => INT_CARRY(467)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(591) <= INT_CARRY(462); -- At Level 5
---- End NO stage
---- Begin FA stage
FA_476:FULL_ADDER -- At Level 6
	port map
	(
		DATA_A => INT_SUM(590), DATA_B => INT_SUM(591), DATA_C => INT_CARRY(463), 
		SAVE => SUM(56), CARRY => CARRY(56)
	);
---- End FA stage
-- End WT-branch 57

-- Begin WT-branch 58
---- Begin FA stage
FA_477:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => SUMMAND(594), DATA_B => SUMMAND(595), DATA_C => SUMMAND(596), 
		SAVE => INT_SUM(592), CARRY => INT_CARRY(468)
	);
---- End FA stage
---- Begin FA stage
FA_478:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => SUMMAND(597), DATA_B => SUMMAND(598), DATA_C => SUMMAND(599), 
		SAVE => INT_SUM(593), CARRY => INT_CARRY(469)
	);
---- End FA stage
---- Begin FA stage
FA_479:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(592), DATA_B => INT_SUM(593), DATA_C => INT_CARRY(464), 
		SAVE => INT_SUM(594), CARRY => INT_CARRY(470)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(595) <= INT_CARRY(465); -- At Level 4
---- End NO stage
---- Begin FA stage
FA_480:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(594), DATA_B => INT_SUM(595), DATA_C => INT_CARRY(466), 
		SAVE => INT_SUM(596), CARRY => INT_CARRY(471)
	);
---- End FA stage
---- Begin HA stage
HA_47:HALF_ADDER -- At Level 6
	port map
	(
		DATA_A => INT_SUM(596), DATA_B => INT_CARRY(467), 
		SAVE => SUM(57), CARRY => CARRY(57)
	);
---- End HA stage
-- End WT-branch 58

-- Begin WT-branch 59
---- Begin FA stage
FA_481:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => SUMMAND(600), DATA_B => SUMMAND(601), DATA_C => SUMMAND(602), 
		SAVE => INT_SUM(597), CARRY => INT_CARRY(472)
	);
---- End FA stage
---- Begin HA stage
HA_48:HALF_ADDER -- At Level 3
	port map
	(
		DATA_A => SUMMAND(603), DATA_B => SUMMAND(604), 
		SAVE => INT_SUM(598), CARRY => INT_CARRY(473)
	);
---- End HA stage
---- Begin FA stage
FA_482:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(597), DATA_B => INT_SUM(598), DATA_C => INT_CARRY(468), 
		SAVE => INT_SUM(599), CARRY => INT_CARRY(474)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(600) <= INT_CARRY(469); -- At Level 4
---- End NO stage
---- Begin FA stage
FA_483:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(599), DATA_B => INT_SUM(600), DATA_C => INT_CARRY(470), 
		SAVE => INT_SUM(601), CARRY => INT_CARRY(475)
	);
---- End FA stage
---- Begin HA stage
HA_49:HALF_ADDER -- At Level 6
	port map
	(
		DATA_A => INT_SUM(601), DATA_B => INT_CARRY(471), 
		SAVE => SUM(58), CARRY => CARRY(58)
	);
---- End HA stage
-- End WT-branch 59

-- Begin WT-branch 60
---- Begin FA stage
FA_484:FULL_ADDER -- At Level 3
	port map
	(
		DATA_A => SUMMAND(605), DATA_B => SUMMAND(606), DATA_C => SUMMAND(607), 
		SAVE => INT_SUM(602), CARRY => INT_CARRY(476)
	);
---- End FA stage
---- Begin HA stage
HA_50:HALF_ADDER -- At Level 3
	port map
	(
		DATA_A => SUMMAND(608), DATA_B => SUMMAND(609), 
		SAVE => INT_SUM(603), CARRY => INT_CARRY(477)
	);
---- End HA stage
---- Begin FA stage
FA_485:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => INT_SUM(602), DATA_B => INT_SUM(603), DATA_C => INT_CARRY(472), 
		SAVE => INT_SUM(604), CARRY => INT_CARRY(478)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(605) <= INT_CARRY(473); -- At Level 4
---- End NO stage
---- Begin FA stage
FA_486:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(604), DATA_B => INT_SUM(605), DATA_C => INT_CARRY(474), 
		SAVE => INT_SUM(606), CARRY => INT_CARRY(479)
	);
---- End FA stage
---- Begin HA stage
HA_51:HALF_ADDER -- At Level 6
	port map
	(
		DATA_A => INT_SUM(606), DATA_B => INT_CARRY(475), 
		SAVE => SUM(59), CARRY => CARRY(59)
	);
---- End HA stage
-- End WT-branch 60

-- Begin WT-branch 61
---- Begin FA stage
FA_487:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => SUMMAND(610), DATA_B => SUMMAND(611), DATA_C => SUMMAND(612), 
		SAVE => INT_SUM(607), CARRY => INT_CARRY(480)
	);
---- End FA stage
---- Begin FA stage
FA_488:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => SUMMAND(613), DATA_B => INT_CARRY(476), DATA_C => INT_CARRY(477), 
		SAVE => INT_SUM(608), CARRY => INT_CARRY(481)
	);
---- End FA stage
---- Begin FA stage
FA_489:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(607), DATA_B => INT_SUM(608), DATA_C => INT_CARRY(478), 
		SAVE => INT_SUM(609), CARRY => INT_CARRY(482)
	);
---- End FA stage
---- Begin HA stage
HA_52:HALF_ADDER -- At Level 6
	port map
	(
		DATA_A => INT_SUM(609), DATA_B => INT_CARRY(479), 
		SAVE => SUM(60), CARRY => CARRY(60)
	);
---- End HA stage
-- End WT-branch 61

-- Begin WT-branch 62
---- Begin FA stage
FA_490:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => SUMMAND(614), DATA_B => SUMMAND(615), DATA_C => SUMMAND(616), 
		SAVE => INT_SUM(610), CARRY => INT_CARRY(483)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(611) <= SUMMAND(617); -- At Level 4
---- End NO stage
---- Begin FA stage
FA_491:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => INT_SUM(610), DATA_B => INT_SUM(611), DATA_C => INT_CARRY(480), 
		SAVE => INT_SUM(612), CARRY => INT_CARRY(484)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(613) <= INT_CARRY(481); -- At Level 5
---- End NO stage
---- Begin FA stage
FA_492:FULL_ADDER -- At Level 6
	port map
	(
		DATA_A => INT_SUM(612), DATA_B => INT_SUM(613), DATA_C => INT_CARRY(482), 
		SAVE => SUM(61), CARRY => CARRY(61)
	);
---- End FA stage
-- End WT-branch 62

-- Begin WT-branch 63
---- Begin FA stage
FA_493:FULL_ADDER -- At Level 4
	port map
	(
		DATA_A => SUMMAND(618), DATA_B => SUMMAND(619), DATA_C => SUMMAND(620), 
		SAVE => INT_SUM(614), CARRY => INT_CARRY(485)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(615) <= INT_SUM(614); -- At Level 5
---- End NO stage
---- Begin NO stage
INT_SUM(616) <= INT_CARRY(483); -- At Level 5
---- End NO stage
---- Begin FA stage
FA_494:FULL_ADDER -- At Level 6
	port map
	(
		DATA_A => INT_SUM(615), DATA_B => INT_SUM(616), DATA_C => INT_CARRY(484), 
		SAVE => SUM(62), CARRY => CARRY(62)
	);
---- End FA stage
-- End WT-branch 63

-- Begin WT-branch 64
---- Begin FA stage
FA_495:FULL_ADDER -- At Level 5
	port map
	(
		DATA_A => SUMMAND(621), DATA_B => SUMMAND(622), DATA_C => SUMMAND(623), 
		SAVE => INT_SUM(617), CARRY => INT_CARRY(486)
	);
---- End FA stage
---- Begin NO stage
INT_SUM(618) <= INT_CARRY(485); -- At Level 5
---- End NO stage
---- Begin HA stage
HA_53:HALF_ADDER -- At Level 6
	port map
	(
		DATA_A => INT_SUM(617), DATA_B => INT_SUM(618), 
		SAVE => SUM(63), CARRY => CARRY(63)
	);
---- End HA stage
-- End WT-branch 64

-- Begin WT-branch 65
---- Begin NO stage
INT_SUM(619) <= SUMMAND(624); -- At Level 5
---- End NO stage
---- Begin NO stage
INT_SUM(620) <= SUMMAND(625); -- At Level 5
---- End NO stage
---- Begin FA stage
FA_496:FULL_ADDER -- At Level 6
	port map
	(
		DATA_A => INT_SUM(619), DATA_B => INT_SUM(620), DATA_C => INT_CARRY(486), 
		SAVE => SUM(64), CARRY => CARRY(64)
	);
---- End FA stage
-- End WT-branch 65

-- Begin WT-branch 66
---- Begin HA stage
HA_54:HALF_ADDER -- At Level 6
	port map
	(
		DATA_A => SUMMAND(626), DATA_B => SUMMAND(627), 
		SAVE => SUM(65), CARRY => CARRY(65)
	);
---- End HA stage
-- End WT-branch 66

-- Begin WT-branch 67
---- Begin NO stage
SUM(66) <= SUMMAND(628); -- At Level 6
---- End NO stage
-- End WT-branch 67

end WALLACE;

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.blocks.all;
entity MULTIPLIER_34_34 is
generic (mulpipe : integer := 0);
port
(
	MULTIPLICAND: in std_logic_vector(0 to 33);
	MULTIPLIER: in std_logic_vector(0 to 33);
	PHI: in std_logic;
	holdn: in std_logic;
	RESULT: out std_logic_vector(0 to 127)
);
end MULTIPLIER_34_34;
architecture MULTIPLIER of MULTIPLIER_34_34 is

signal PPBIT:std_logic_vector(0 to 628);
signal INT_CARRY: std_logic_vector(0 to 128);
signal INT_SUM: std_logic_vector(0 to 127);
signal LOGIC_ZERO: std_logic;

signal INT_CARRYR: std_logic_vector(0 to 128);
signal INT_SUMR: std_logic_vector(0 to 127);

begin -- Architecture

LOGIC_ZERO <= '0';
B:BOOTHCODER_34_34
	port map
	(
		OPA(0 to 33) => MULTIPLICAND(0 to 33),
		OPB(0 to 33) => MULTIPLIER(0 to 33),
		SUMMAND(0 to 628) => PPBIT(0 to 628)
	);
W:WALLACE_34_34
	port map
	(
		SUMMAND(0 to 628) => PPBIT(0 to 628),
		CARRY(0 to 65) => INT_CARRY(1 to 66),
		SUM(0 to 66) => INT_SUM(0 to 66)
	);
INT_CARRY(0) <= LOGIC_ZERO;
INT_CARRY(67) <= LOGIC_ZERO;
INT_CARRY(68) <= LOGIC_ZERO;
INT_CARRY(69) <= LOGIC_ZERO;
INT_CARRY(70) <= LOGIC_ZERO;
INT_CARRY(71) <= LOGIC_ZERO;
INT_CARRY(72) <= LOGIC_ZERO;
INT_CARRY(73) <= LOGIC_ZERO;
INT_CARRY(74) <= LOGIC_ZERO;
INT_CARRY(75) <= LOGIC_ZERO;
INT_CARRY(76) <= LOGIC_ZERO;
INT_CARRY(77) <= LOGIC_ZERO;
INT_CARRY(78) <= LOGIC_ZERO;
INT_CARRY(79) <= LOGIC_ZERO;
INT_CARRY(80) <= LOGIC_ZERO;
INT_CARRY(81) <= LOGIC_ZERO;
INT_CARRY(82) <= LOGIC_ZERO;
INT_CARRY(83) <= LOGIC_ZERO;
INT_CARRY(84) <= LOGIC_ZERO;
INT_CARRY(85) <= LOGIC_ZERO;
INT_CARRY(86) <= LOGIC_ZERO;
INT_CARRY(87) <= LOGIC_ZERO;
INT_CARRY(88) <= LOGIC_ZERO;
INT_CARRY(89) <= LOGIC_ZERO;
INT_CARRY(90) <= LOGIC_ZERO;
INT_CARRY(91) <= LOGIC_ZERO;
INT_CARRY(92) <= LOGIC_ZERO;
INT_CARRY(93) <= LOGIC_ZERO;
INT_CARRY(94) <= LOGIC_ZERO;
INT_CARRY(95) <= LOGIC_ZERO;
INT_CARRY(96) <= LOGIC_ZERO;
INT_CARRY(97) <= LOGIC_ZERO;
INT_CARRY(98) <= LOGIC_ZERO;
INT_CARRY(99) <= LOGIC_ZERO;
INT_CARRY(100) <= LOGIC_ZERO;
INT_CARRY(101) <= LOGIC_ZERO;
INT_CARRY(102) <= LOGIC_ZERO;
INT_CARRY(103) <= LOGIC_ZERO;
INT_CARRY(104) <= LOGIC_ZERO;
INT_CARRY(105) <= LOGIC_ZERO;
INT_CARRY(106) <= LOGIC_ZERO;
INT_CARRY(107) <= LOGIC_ZERO;
INT_CARRY(108) <= LOGIC_ZERO;
INT_CARRY(109) <= LOGIC_ZERO;
INT_CARRY(110) <= LOGIC_ZERO;
INT_CARRY(111) <= LOGIC_ZERO;
INT_CARRY(112) <= LOGIC_ZERO;
INT_CARRY(113) <= LOGIC_ZERO;
INT_CARRY(114) <= LOGIC_ZERO;
INT_CARRY(115) <= LOGIC_ZERO;
INT_CARRY(116) <= LOGIC_ZERO;
INT_CARRY(117) <= LOGIC_ZERO;
INT_CARRY(118) <= LOGIC_ZERO;
INT_CARRY(119) <= LOGIC_ZERO;
INT_CARRY(120) <= LOGIC_ZERO;
INT_CARRY(121) <= LOGIC_ZERO;
INT_CARRY(122) <= LOGIC_ZERO;
INT_CARRY(123) <= LOGIC_ZERO;
INT_CARRY(124) <= LOGIC_ZERO;
INT_CARRY(125) <= LOGIC_ZERO;
INT_CARRY(126) <= LOGIC_ZERO;
INT_CARRY(127) <= LOGIC_ZERO;
INT_SUM(67) <= LOGIC_ZERO;
INT_SUM(68) <= LOGIC_ZERO;
INT_SUM(69) <= LOGIC_ZERO;
INT_SUM(70) <= LOGIC_ZERO;
INT_SUM(71) <= LOGIC_ZERO;
INT_SUM(72) <= LOGIC_ZERO;
INT_SUM(73) <= LOGIC_ZERO;
INT_SUM(74) <= LOGIC_ZERO;
INT_SUM(75) <= LOGIC_ZERO;
INT_SUM(76) <= LOGIC_ZERO;
INT_SUM(77) <= LOGIC_ZERO;
INT_SUM(78) <= LOGIC_ZERO;
INT_SUM(79) <= LOGIC_ZERO;
INT_SUM(80) <= LOGIC_ZERO;
INT_SUM(81) <= LOGIC_ZERO;
INT_SUM(82) <= LOGIC_ZERO;
INT_SUM(83) <= LOGIC_ZERO;
INT_SUM(84) <= LOGIC_ZERO;
INT_SUM(85) <= LOGIC_ZERO;
INT_SUM(86) <= LOGIC_ZERO;
INT_SUM(87) <= LOGIC_ZERO;
INT_SUM(88) <= LOGIC_ZERO;
INT_SUM(89) <= LOGIC_ZERO;
INT_SUM(90) <= LOGIC_ZERO;
INT_SUM(91) <= LOGIC_ZERO;
INT_SUM(92) <= LOGIC_ZERO;
INT_SUM(93) <= LOGIC_ZERO;
INT_SUM(94) <= LOGIC_ZERO;
INT_SUM(95) <= LOGIC_ZERO;
INT_SUM(96) <= LOGIC_ZERO;
INT_SUM(97) <= LOGIC_ZERO;
INT_SUM(98) <= LOGIC_ZERO;
INT_SUM(99) <= LOGIC_ZERO;
INT_SUM(100) <= LOGIC_ZERO;
INT_SUM(101) <= LOGIC_ZERO;
INT_SUM(102) <= LOGIC_ZERO;
INT_SUM(103) <= LOGIC_ZERO;
INT_SUM(104) <= LOGIC_ZERO;
INT_SUM(105) <= LOGIC_ZERO;
INT_SUM(106) <= LOGIC_ZERO;
INT_SUM(107) <= LOGIC_ZERO;
INT_SUM(108) <= LOGIC_ZERO;
INT_SUM(109) <= LOGIC_ZERO;
INT_SUM(110) <= LOGIC_ZERO;
INT_SUM(111) <= LOGIC_ZERO;
INT_SUM(112) <= LOGIC_ZERO;
INT_SUM(113) <= LOGIC_ZERO;
INT_SUM(114) <= LOGIC_ZERO;
INT_SUM(115) <= LOGIC_ZERO;
INT_SUM(116) <= LOGIC_ZERO;
INT_SUM(117) <= LOGIC_ZERO;
INT_SUM(118) <= LOGIC_ZERO;
INT_SUM(119) <= LOGIC_ZERO;
INT_SUM(120) <= LOGIC_ZERO;
INT_SUM(121) <= LOGIC_ZERO;
INT_SUM(122) <= LOGIC_ZERO;
INT_SUM(123) <= LOGIC_ZERO;
INT_SUM(124) <= LOGIC_ZERO;
INT_SUM(125) <= LOGIC_ZERO;
INT_SUM(126) <= LOGIC_ZERO;
INT_SUM(127) <= LOGIC_ZERO;

  INT_SUMR(67 to 127) <= INT_SUM(67 to 127);
  INT_CARRYR(67 to 127) <= INT_CARRY(67 to 127);
  INT_CARRYR(0) <= INT_CARRY(0);

  reg : if MULPIPE /= 0 generate

      process (PHI) begin 
        if rising_edge(PHI ) then
          if (holdn = '1') then 
	    INT_SUMR(0 to 66) <= INT_SUM(0 to 66);
	    INT_CARRYR(1 to 66) <= INT_CARRY(1 to 66);
          end if;
        end if;
      end process;

  end generate;
    
  noreg : if MULPIPE = 0 generate
	INT_SUMR(0 to 66) <= INT_SUM(0 to 66);
	INT_CARRYR(1 to 66) <= INT_CARRY(1 to 66);
  end generate;


D:DBLCADDER_128_128
	port map
	(
		OPA(0 to 127) => INT_SUMR(0 to 127),
		OPB(0 to 127) => INT_CARRYR(0 to 127),
		CIN => LOGIC_ZERO,
		PHI => PHI,
		SUM(0 to 127) => RESULT(0 to 127)
	);
end MULTIPLIER;
------------------------------------------------------------
-- END: Architectures used with the multiplier
------------------------------------------------------------

--
-- Modgen multiplier created Fri Aug 16 16:35:11 2002
--
------------------------------------------------------------
-- START: Multiplier Entitiy
------------------------------------------------------------

------------------------------------------------------------
------------------------------------------------------------
-- START: Top entity
------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.blocks.all;
entity MUL_33_33 is
  generic (mulpipe : integer := 0);
  port(clk : in std_ulogic;
       holdn: in std_ulogic;
       X: in std_logic_vector(32 downto 0);
       Y: in std_logic_vector(32 downto 0);
       P: out std_logic_vector(65 downto 0));
end MUL_33_33;
architecture A of MUL_33_33 is
  signal A: std_logic_vector(0 to 33);
  signal B: std_logic_vector(0 to 33);
  signal Q: std_logic_vector(0 to 127);
begin
  U1: MULTIPLIER_34_34 generic map (mulpipe) port map(A,B,CLK, holdn ,Q);
  -- std_logic_vector reversals to incorporate decreasing vectors
  A(0) <= X(0);
  A(1) <= X(1);
  A(2) <= X(2);
  A(3) <= X(3);
  A(4) <= X(4);
  A(5) <= X(5);
  A(6) <= X(6);
  A(7) <= X(7);
  A(8) <= X(8);
  A(9) <= X(9);
  A(10) <= X(10);
  A(11) <= X(11);
  A(12) <= X(12);
  A(13) <= X(13);
  A(14) <= X(14);
  A(15) <= X(15);
  A(16) <= X(16);
  A(17) <= X(17);
  A(18) <= X(18);
  A(19) <= X(19);
  A(20) <= X(20);
  A(21) <= X(21);
  A(22) <= X(22);
  A(23) <= X(23);
  A(24) <= X(24);
  A(25) <= X(25);
  A(26) <= X(26);
  A(27) <= X(27);
  A(28) <= X(28);
  A(29) <= X(29);
  A(30) <= X(30);
  A(31) <= X(31);
  A(32) <= X(32);
  A(33) <= X(32);
  B(0) <= Y(0);
  B(1) <= Y(1);
  B(2) <= Y(2);
  B(3) <= Y(3);
  B(4) <= Y(4);
  B(5) <= Y(5);
  B(6) <= Y(6);
  B(7) <= Y(7);
  B(8) <= Y(8);
  B(9) <= Y(9);
  B(10) <= Y(10);
  B(11) <= Y(11);
  B(12) <= Y(12);
  B(13) <= Y(13);
  B(14) <= Y(14);
  B(15) <= Y(15);
  B(16) <= Y(16);
  B(17) <= Y(17);
  B(18) <= Y(18);
  B(19) <= Y(19);
  B(20) <= Y(20);
  B(21) <= Y(21);
  B(22) <= Y(22);
  B(23) <= Y(23);
  B(24) <= Y(24);
  B(25) <= Y(25);
  B(26) <= Y(26);
  B(27) <= Y(27);
  B(28) <= Y(28);
  B(29) <= Y(29);
  B(30) <= Y(30);
  B(31) <= Y(31);
  B(32) <= Y(32);
  B(33) <= Y(32);
  P(0) <= Q(0);
  P(1) <= Q(1);
  P(2) <= Q(2);
  P(3) <= Q(3);
  P(4) <= Q(4);
  P(5) <= Q(5);
  P(6) <= Q(6);
  P(7) <= Q(7);
  P(8) <= Q(8);
  P(9) <= Q(9);
  P(10) <= Q(10);
  P(11) <= Q(11);
  P(12) <= Q(12);
  P(13) <= Q(13);
  P(14) <= Q(14);
  P(15) <= Q(15);
  P(16) <= Q(16);
  P(17) <= Q(17);
  P(18) <= Q(18);
  P(19) <= Q(19);
  P(20) <= Q(20);
  P(21) <= Q(21);
  P(22) <= Q(22);
  P(23) <= Q(23);
  P(24) <= Q(24);
  P(25) <= Q(25);
  P(26) <= Q(26);
  P(27) <= Q(27);
  P(28) <= Q(28);
  P(29) <= Q(29);
  P(30) <= Q(30);
  P(31) <= Q(31);
  P(32) <= Q(32);
  P(33) <= Q(33);
  P(34) <= Q(34);
  P(35) <= Q(35);
  P(36) <= Q(36);
  P(37) <= Q(37);
  P(38) <= Q(38);
  P(39) <= Q(39);
  P(40) <= Q(40);
  P(41) <= Q(41);
  P(42) <= Q(42);
  P(43) <= Q(43);
  P(44) <= Q(44);
  P(45) <= Q(45);
  P(46) <= Q(46);
  P(47) <= Q(47);
  P(48) <= Q(48);
  P(49) <= Q(49);
  P(50) <= Q(50);
  P(51) <= Q(51);
  P(52) <= Q(52);
  P(53) <= Q(53);
  P(54) <= Q(54);
  P(55) <= Q(55);
  P(56) <= Q(56);
  P(57) <= Q(57);
  P(58) <= Q(58);
  P(59) <= Q(59);
  P(60) <= Q(60);
  P(61) <= Q(61);
  P(62) <= Q(62);
  P(63) <= Q(63);
  P(64) <= Q(64);
  P(65) <= Q(65);
end A;

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.blocks.all;
entity ADD32 is
  port(X: in std_logic_vector(31 downto 0);
       Y: in std_logic_vector(31 downto 0);
       CI: in std_logic;
       S: out std_logic_vector(31 downto 0);
       CO: out std_logic);
end ADD32;
architecture A of ADD32 is
  signal A,B,Q: std_logic_vector(0 to 31);
  signal CLK: std_logic;
begin
  U1: DBLCADDER_32_32 port map(A,B,CI,CLK,Q,CO);
  -- std_logic_vector reversals to incorporate decreasing vectors
  A(0) <= X(0);
  B(0) <= Y(0);
  A(1) <= X(1);
  B(1) <= Y(1);
  A(2) <= X(2);
  B(2) <= Y(2);
  A(3) <= X(3);
  B(3) <= Y(3);
  A(4) <= X(4);
  B(4) <= Y(4);
  A(5) <= X(5);
  B(5) <= Y(5);
  A(6) <= X(6);
  B(6) <= Y(6);
  A(7) <= X(7);
  B(7) <= Y(7);
  A(8) <= X(8);
  B(8) <= Y(8);
  A(9) <= X(9);
  B(9) <= Y(9);
  A(10) <= X(10);
  B(10) <= Y(10);
  A(11) <= X(11);
  B(11) <= Y(11);
  A(12) <= X(12);
  B(12) <= Y(12);
  A(13) <= X(13);
  B(13) <= Y(13);
  A(14) <= X(14);
  B(14) <= Y(14);
  A(15) <= X(15);
  B(15) <= Y(15);
  A(16) <= X(16);
  B(16) <= Y(16);
  A(17) <= X(17);
  B(17) <= Y(17);
  A(18) <= X(18);
  B(18) <= Y(18);
  A(19) <= X(19);
  B(19) <= Y(19);
  A(20) <= X(20);
  B(20) <= Y(20);
  A(21) <= X(21);
  B(21) <= Y(21);
  A(22) <= X(22);
  B(22) <= Y(22);
  A(23) <= X(23);
  B(23) <= Y(23);
  A(24) <= X(24);
  B(24) <= Y(24);
  A(25) <= X(25);
  B(25) <= Y(25);
  A(26) <= X(26);
  B(26) <= Y(26);
  A(27) <= X(27);
  B(27) <= Y(27);
  A(28) <= X(28);
  B(28) <= Y(28);
  A(29) <= X(29);
  B(29) <= Y(29);
  A(30) <= X(30);
  B(30) <= Y(30);
  A(31) <= X(31);
  B(31) <= Y(31);
  S(0) <= Q(0);
  S(1) <= Q(1);
  S(2) <= Q(2);
  S(3) <= Q(3);
  S(4) <= Q(4);
  S(5) <= Q(5);
  S(6) <= Q(6);
  S(7) <= Q(7);
  S(8) <= Q(8);
  S(9) <= Q(9);
  S(10) <= Q(10);
  S(11) <= Q(11);
  S(12) <= Q(12);
  S(13) <= Q(13);
  S(14) <= Q(14);
  S(15) <= Q(15);
  S(16) <= Q(16);
  S(17) <= Q(17);
  S(18) <= Q(18);
  S(19) <= Q(19);
  S(20) <= Q(20);
  S(21) <= Q(21);
  S(22) <= Q(22);
  S(23) <= Q(23);
  S(24) <= Q(24);
  S(25) <= Q(25);
  S(26) <= Q(26);
  S(27) <= Q(27);
  S(28) <= Q(28);
  S(29) <= Q(29);
  S(30) <= Q(30);
  S(31) <= Q(31);
end A;

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.blocks.all;
entity MUL_17_17 is
  generic (mulpipe : integer := 0);
  port(clk : in std_ulogic;
       holdn: in std_ulogic;
       X: in std_logic_vector(16 downto 0);
       Y: in std_logic_vector(16 downto 0);
       P: out std_logic_vector(33 downto 0));
end MUL_17_17;

architecture A of MUL_17_17 is
  signal A: std_logic_vector(0 to 17);
  signal B: std_logic_vector(0 to 17);
  signal Q: std_logic_vector(0 to 63);
begin
  U1: MULTIPLIER_18_18 generic map (mulpipe) port map(A,B,CLK, holdn, Q);
  -- std_logic_vector reversals to incorporate decreasing vectors
  A(0) <= X(0);
  A(1) <= X(1);
  A(2) <= X(2);
  A(3) <= X(3);
  A(4) <= X(4);
  A(5) <= X(5);
  A(6) <= X(6);
  A(7) <= X(7);
  A(8) <= X(8);
  A(9) <= X(9);
  A(10) <= X(10);
  A(11) <= X(11);
  A(12) <= X(12);
  A(13) <= X(13);
  A(14) <= X(14);
  A(15) <= X(15);
  A(16) <= X(16);
  A(17) <= X(16);
  B(0) <= Y(0);
  B(1) <= Y(1);
  B(2) <= Y(2);
  B(3) <= Y(3);
  B(4) <= Y(4);
  B(5) <= Y(5);
  B(6) <= Y(6);
  B(7) <= Y(7);
  B(8) <= Y(8);
  B(9) <= Y(9);
  B(10) <= Y(10);
  B(11) <= Y(11);
  B(12) <= Y(12);
  B(13) <= Y(13);
  B(14) <= Y(14);
  B(15) <= Y(15);
  B(16) <= Y(16);
  B(17) <= Y(16);
  P(0) <= Q(0);
  P(1) <= Q(1);
  P(2) <= Q(2);
  P(3) <= Q(3);
  P(4) <= Q(4);
  P(5) <= Q(5);
  P(6) <= Q(6);
  P(7) <= Q(7);
  P(8) <= Q(8);
  P(9) <= Q(9);
  P(10) <= Q(10);
  P(11) <= Q(11);
  P(12) <= Q(12);
  P(13) <= Q(13);
  P(14) <= Q(14);
  P(15) <= Q(15);
  P(16) <= Q(16);
  P(17) <= Q(17);
  P(18) <= Q(18);
  P(19) <= Q(19);
  P(20) <= Q(20);
  P(21) <= Q(21);
  P(22) <= Q(22);
  P(23) <= Q(23);
  P(24) <= Q(24);
  P(25) <= Q(25);
  P(26) <= Q(26);
  P(27) <= Q(27);
  P(28) <= Q(28);
  P(29) <= Q(29);
  P(30) <= Q(30);
  P(31) <= Q(31);
  P(32) <= Q(32);
  P(33) <= Q(33);
end A;




