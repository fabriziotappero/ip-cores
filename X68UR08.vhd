-----------------------------------------------------------------------------------
--  68HC08 microcontroller implementation
--  Ulrich Riedel
--  v1.0  2005.11.24  first version
-----------------------------------------------------------------------------------
-- divider.vhd  parallel division
-- based on non-restoring division, uncorrected remainder
-- Controlled add/subtract "cas" cell (NOT CSA)
-- "T" is sub_add signal in div_ser.vhdl

library IEEE;
use IEEE.std_logic_1164.all;

entity cas is  -- Controlled Add/Subtract cell
  port (
    divisor       : in  std_logic;
    T             : in  std_logic;
    remainder_in  : in  std_logic;
    cin           : in  std_logic;
    remainder_out : out std_logic;
    cout          : out std_logic);
end entity cas;

architecture behavior of cas is
  signal tt : std_logic;
begin
  tt            <= (T   xor divisor) after 1 ns;
  remainder_out <= (tt  xor remainder_in xor cin) after 1 ns;
  cout          <= ((tt and remainder_in) or (tt and cin) or (remainder_in and cin)) after 1 ns;
end architecture behavior;  -- cas

-----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity divcas9 is   -- 17 bit dividend, 9 bit divisor
  port (
    dividend  : in  std_logic_vector(16 downto 0);
    divisor   : in  std_logic_vector(8 downto 0);
    quotient  : out std_logic_vector(8 downto 0);
    remainder : out std_logic_vector(8 downto 0)
  );
end entity divcas9;

architecture behavior of divcas9 is

  component cas port(
    divisor       : in  std_logic;
    T             : in  std_logic;
    remainder_in  : in  std_logic;
    cin           : in  std_logic;
    remainder_out : out std_logic;
    cout          : out std_logic
  );
  end component;
  
  signal T : std_logic_vector(8 downto 0);
  signal c8G, c8F, c8E, c8D, c8C, c8B, c8A, c89, c88 : std_logic;
  signal c7F, c7E, c7D, c7C, c7B, c7A, c79, c78, c77 : std_logic;
  signal c6E, c6D, c6C, c6B, c6A, c69, c68, c67, c66 : std_logic;
  signal c5D, c5C, c5B, c5A, c59, c58, c57, c56, c55 : std_logic;
  signal c4C, c4B, c4A, c49, c48, c47, c46, c45, c44 : std_logic;
  signal c3B, c3A, c39, c38, c37, c36, c35, c34, c33 : std_logic;
  signal c2A, c29, c28, c27, c26, c25, c24, c23, c22 : std_logic;
  signal c19, c18, c17, c16, c15, c14, c13, c12, c11 : std_logic;
  signal c08, c07, c06, c05, c04, c03, c02, c01, c00 : std_logic;
  signal r8G, r8F, r8E, r8D, r8C, r8B, r8A, r89, r88 : std_logic;
  signal r7F, r7E, r7D, r7C, r7B, r7A, r79, r78, r77 : std_logic;
  signal r6E, r6D, r6C, r6B, r6A, r69, r68, r67, r66 : std_logic;
  signal r5D, r5C, r5B, r5A, r59, r58, r57, r56, r55 : std_logic;
  signal r4C, r4B, r4A, r49, r48, r47, r46, r45, r44 : std_logic;
  signal r3B, r3A, r39, r38, r37, r36, r35, r34, r33 : std_logic;
  signal r2A, r29, r28, r27, r26, r25, r24, r23, r22 : std_logic;
  signal r19, r18, r17, r16, r15, r14, r13, r12, r11 : std_logic;
  signal r08, r07, r06, r05, r04, r03, r02, r01, r00 : std_logic;
begin
  -- dividend(16) assumed zero and unused
  T(8) <= '1'; 
  cas8G: cas port map(divisor(8), T(8), dividend(16), c8F,  r8G, c8G); 
  cas8F: cas port map(divisor(7), T(8), dividend(15), c8E,  r8F, c8F); 
  cas8E: cas port map(divisor(6), T(8), dividend(14), c8D,  r8E, c8E); 
  cas8D: cas port map(divisor(5), T(8), dividend(13), c8C,  r8D, c8D); 
  cas8C: cas port map(divisor(4), T(8), dividend(12), c8B,  r8C, c8C);
  cas8B: cas port map(divisor(3), T(8), dividend(11), c8A,  r8B, c8B); 
  cas8A: cas port map(divisor(2), T(8), dividend(10), c89,  r8A, c8A); 
  cas89: cas port map(divisor(1), T(8), dividend(9) , c88,  r89, c89); 
  cas88: cas port map(divisor(0), T(8), dividend(8) , T(8), r88, c88);
  T(7) <= not r8G;

  cas7F: cas port map(divisor(8), T(7), r8F        , c7E,  r7F, c7F); 
  cas7E: cas port map(divisor(7), T(7), r8E        , c7D,  r7E, c7E); 
  cas7D: cas port map(divisor(6), T(7), r8D        , c7C,  r7D, c7D); 
  cas7C: cas port map(divisor(5), T(7), r8C        , c7B,  r7C, c7C); 
  cas7B: cas port map(divisor(4), T(7), r8B        , c7A,  r7B, c7B); 
  cas7A: cas port map(divisor(3), T(7), r8A        , c79,  r7A, c7A); 
  cas79: cas port map(divisor(2), T(7), r89        , c78,  r79, c79); 
  cas78: cas port map(divisor(1), T(7), r88        , c77,  r78, c78); 
  cas77: cas port map(divisor(0), T(7), dividend(7), T(7), r77, c77);
  T(6) <= not r7F;

  cas6E: cas port map(divisor(8), T(6), r7E        , c6D,  r6E, c6E); 
  cas6D: cas port map(divisor(7), T(6), r7D        , c6C,  r6D, c6D); 
  cas6C: cas port map(divisor(6), T(6), r7C        , c6B,  r6C, c6C); 
  cas6B: cas port map(divisor(5), T(6), r7B        , c6A,  r6B, c6B); 
  cas6A: cas port map(divisor(4), T(6), r7A        , c69,  r6A, c6A); 
  cas69: cas port map(divisor(3), T(6), r79        , c68,  r69, c69); 
  cas68: cas port map(divisor(2), T(6), r78        , c67,  r68, c68); 
  cas67: cas port map(divisor(1), T(6), r77        , c66,  r67, c67); 
  cas66: cas port map(divisor(0), T(6), dividend(6), T(6), r66, c66);
  T(5) <= not r6E;

  cas5D: cas port map(divisor(8), T(5), r6D        , c5C,  r5D, c5D); 
  cas5C: cas port map(divisor(7), T(5), r6C        , c5B,  r5C, c5C); 
  cas5B: cas port map(divisor(6), T(5), r6B        , c5A,  r5B, c5B); 
  cas5A: cas port map(divisor(5), T(5), r6A        , c59,  r5A, c5A); 
  cas59: cas port map(divisor(4), T(5), r69        , c58,  r59, c59); 
  cas58: cas port map(divisor(3), T(5), r68        , c57,  r58, c58); 
  cas57: cas port map(divisor(2), T(5), r67        , c56,  r57, c57); 
  cas56: cas port map(divisor(1), T(5), r66        , c55,  r56, c56); 
  cas55: cas port map(divisor(0), T(5), dividend(5), T(5), r55, c55);
  T(4) <= not r5D;

  cas4C: cas port map(divisor(8), T(4), r5C        , c4B,  r4C, c4C); 
  cas4B: cas port map(divisor(7), T(4), r5B        , c4A,  r4B, c4B); 
  cas4A: cas port map(divisor(6), T(4), r5A        , c49,  r4A, c4A); 
  cas49: cas port map(divisor(5), T(4), r59        , c48,  r49, c49); 
  cas48: cas port map(divisor(4), T(4), r58        , c47,  r48, c48); 
  cas47: cas port map(divisor(3), T(4), r57        , c46,  r47, c47); 
  cas46: cas port map(divisor(2), T(4), r56        , c45,  r46, c46); 
  cas45: cas port map(divisor(1), T(4), r55        , c44,  r45, c45); 
  cas44: cas port map(divisor(0), T(4), dividend(4), T(4), r44, c44);
  T(3) <= not r4C;

  cas3B: cas port map(divisor(8), T(3), r4B        , c3A,  r3B, c3B); 
  cas3A: cas port map(divisor(7), T(3), r4A        , c39,  r3A, c3A); 
  cas39: cas port map(divisor(6), T(3), r49        , c38,  r39, c39); 
  cas38: cas port map(divisor(5), T(3), r48        , c37,  r38, c38); 
  cas37: cas port map(divisor(4), T(3), r47        , c36,  r37, c37); 
  cas36: cas port map(divisor(3), T(3), r46        , c35,  r36, c36); 
  cas35: cas port map(divisor(2), T(3), r45        , c34,  r35, c35); 
  cas34: cas port map(divisor(1), T(3), r44        , c33,  r34, c34); 
  cas33: cas port map(divisor(0), T(3), dividend(3), T(3), r33, c33);
  T(2) <= not r3B;
  
  cas2A: cas port map(divisor(8), T(2), r3A        , c29,  r2A, c2A); 
  cas29: cas port map(divisor(7), T(2), r39        , c28,  r29, c29); 
  cas28: cas port map(divisor(6), T(2), r38        , c27,  r28, c28); 
  cas27: cas port map(divisor(5), T(2), r37        , c26,  r27, c27); 
  cas26: cas port map(divisor(4), T(2), r36        , c25,  r26, c26); 
  cas25: cas port map(divisor(3), T(2), r35        , c24,  r25, c25); 
  cas24: cas port map(divisor(2), T(2), r34        , c23,  r24, c24); 
  cas23: cas port map(divisor(1), T(2), r33        , c22,  r23, c23); 
  cas22: cas port map(divisor(0), T(2), dividend(2), T(2), r22, c22);
  T(1) <= not r2A;
  
  cas19: cas port map(divisor(8), T(1), r29        , c18,  r19, c19); 
  cas18: cas port map(divisor(7), T(1), r28        , c17,  r18, c18); 
  cas17: cas port map(divisor(6), T(1), r27        , c16,  r17, c17); 
  cas16: cas port map(divisor(5), T(1), r26        , c15,  r16, c16); 
  cas15: cas port map(divisor(4), T(1), r25        , c14,  r15, c15); 
  cas14: cas port map(divisor(3), T(1), r24        , c13,  r14, c14); 
  cas13: cas port map(divisor(2), T(1), r23        , c12,  r13, c13); 
  cas12: cas port map(divisor(1), T(1), r22        , c11,  r12, c12); 
  cas11: cas port map(divisor(0), T(1), dividend(1), T(1), r11, c11);
  T(0) <= not r19;
  
  cas08: cas port map(divisor(8), T(0), r18        , c07,  r08, c08); 
  cas07: cas port map(divisor(7), T(0), r17        , c06,  r07, c07); 
  cas06: cas port map(divisor(6), T(0), r16        , c05,  r06, c06); 
  cas05: cas port map(divisor(5), T(0), r15        , c04,  r05, c05); 
  cas04: cas port map(divisor(4), T(0), r14        , c03,  r04, c04);
  cas03: cas port map(divisor(3), T(0), r13        , c02,  r03, c03); 
  cas02: cas port map(divisor(2), T(0), r12        , c01,  r02, c02); 
  cas01: cas port map(divisor(1), T(0), r11        , c00,  r01, c01); 
  cas00: cas port map(divisor(0), T(0), dividend(0), T(0), r00, c00);

  quotient(8)  <= T(7);
  quotient(7)  <= T(6);
  quotient(6)  <= T(5);
  quotient(5)  <= T(4);
  quotient(4)  <= T(3);
  quotient(3)  <= T(2);
  quotient(2)  <= T(1);
  quotient(1)  <= T(0);
  quotient(0)  <= not r08;
  remainder(8) <= r08;
  remainder(7) <= r07;
  remainder(6) <= r06;
  remainder(5) <= r05;
  remainder(4) <= r04;
  remainder(3) <= r03;
  remainder(2) <= r02;
  remainder(1) <= r01;
  remainder(0) <= r00;
  
end architecture behavior; -- divcas9
-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity fadd is               -- full adder stage, interface
  port(a    : in  std_logic;
       b    : in  std_logic;
       cin  : in  std_logic;
       s    : out std_logic;
       cout : out std_logic);
end entity fadd;

architecture behavior of fadd is  -- full adder stage, body
begin  -- circuits of fadd
  s <= a xor b xor cin after 1 ns;
  cout <= (a and b) or (a and cin) or (b and cin) after 1 ns;
end architecture behavior; -- fadd
-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
entity add8 is             -- simple 8 bit ripple carry adder
  port(a    : in  std_logic_vector(7 downto 0);
       b    : in  std_logic_vector(7 downto 0);
       cin  : in  std_logic; 
       sum  : out std_logic_vector(7 downto 0);
       cout : out std_logic);
end entity add8;

architecture behavior of add8 is
  signal c : std_logic_vector(0 to 6); -- internal carry signals
  component fadd   -- duplicates entity port
  port(a    : in  std_logic;
       b    : in  std_logic;
       cin  : in  std_logic;
       s    : out std_logic;
       cout : out std_logic);
  end component fadd ;
begin
  a0:            fadd port map(a(0), b(0), cin, sum(0), c(0));
  stage: for I in 1 to 6 generate
             as: fadd port map(a(I), b(I), c(I-1) , sum(I), c(I));
         end generate stage;
  a31:           fadd port map(a(7), b(7), c(6) , sum(7), cout);
end architecture behavior;  -- add8

-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity add8c is          -- one stage of carry save adder for multiplier
  port(
    b       : in  std_logic;                     -- a multiplier bit
    a       : in  std_logic_vector(7 downto 0);  -- multiplicand
    sum_in  : in  std_logic_vector(7 downto 0);  -- sums from previous stage
    cin     : in  std_logic_vector(7 downto 0);  -- carrys from previous stage
    sum_out : out std_logic_vector(7 downto 0);  -- sums to next stage
    cout    : out std_logic_vector(7 downto 0)); -- carrys to next stage
end add8c;

architecture behavior of add8c is
  signal zero : std_logic_vector(7 downto 0) := x"00";
  signal aa   : std_logic_vector(7 downto 0) := x"00";
  component fadd
    port(a    : in  std_logic;
         b    : in  std_logic;
         cin  : in  std_logic;
         s    : out std_logic;
         cout : out std_logic);
  end component fadd;
begin
  aa <= a when b = '1' else zero after 1 ns;
  stage: for I in 0 to 7 generate
    sta: fadd port map(aa(I), sum_in(I), cin(I) , sum_out(I), cout(I));
  end generate stage;  
end architecture behavior; -- add8csa

-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity mul8 is  -- 8 x 8 = 16 bit unsigned product multiplier
  port(a    : in  std_logic_vector(7 downto 0);  -- multiplicand
       b    : in  std_logic_vector(7 downto 0);  -- multiplier
       prod : out std_logic_vector(15 downto 0)); -- product
end mul8;

architecture behavior of mul8 is
  signal zero : std_logic_vector(7 downto 0) := x"00";
  signal nc1  : std_logic;
  type arr8 is array(0 to 7) of std_logic_vector(7 downto 0);
  signal s    : arr8; -- partial sums
  signal c    : arr8; -- partial carries
  signal ss   : arr8; -- shifted sums

  component add8c is
    port(b       : in  std_logic;
         a       : in  std_logic_vector(7 downto 0);
         sum_in  : in  std_logic_vector(7 downto 0);
         cin     : in  std_logic_vector(7 downto 0);
         sum_out : out std_logic_vector(7 downto 0);
         cout    : out std_logic_vector(7 downto 0));
  end component add8c;
  component add8
    port(a    : in  std_logic_vector(7 downto 0);
         b    : in  std_logic_vector(7 downto 0);
         cin  : in  std_logic; 
         sum  : out std_logic_vector(7 downto 0);
         cout : out std_logic);
  end component add8;
begin
  st0: add8c port map(b(0), a, zero , zero, s(0), c(0));  -- CSA stage
  ss(0) <= '0' & s(0)(7 downto 1) after 1 ns;
  prod(0) <= s(0)(0) after 1 ns;

  stage: for I in 1 to 7 generate
    st: add8c port map(b(I), a, ss(I-1) , c(I-1), s(I), c(I));  -- CSA stage
    ss(I) <= '0' & s(I)(7 downto 1) after 1 ns;
    prod(I) <= s(I)(0) after 1 ns;
  end generate stage;
  
  add: add8 port map(ss(7), c(7), '0' , prod(15 downto 8), nc1);  -- adder
end architecture behavior; -- mul8
-------------------------------------------------------------------------
-- begin of 68HC08
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.all;

ENTITY X68UR08 IS
   PORT(
     clk     : in  std_logic;
     rst     : in  std_logic;
     irq     : in  std_logic;
     addr    : out std_logic_vector(15 downto 0);
     wr      : out std_logic;
     datain  : in  std_logic_vector(7 downto 0);
     state   : out std_logic_vector(3 downto 0);
     dataout : out std_logic_vector(7 downto 0)
   );
END X68UR08;

ARCHITECTURE behavior OF X68UR08 IS

  component mul8 port(
    a    : in  std_logic_vector(7 downto 0);
    b    : in  std_logic_vector(7 downto 0);
    prod : out std_logic_vector(15 downto 0)
    );
  end component mul8;

  component divcas9 port (
    dividend  : in  std_logic_vector(16 downto 0);
    divisor   : in  std_logic_vector(8 downto 0);
    quotient  : out std_logic_vector(8 downto 0);
    remainder : out std_logic_vector(8 downto 0)
  );
  end component divcas9;
  
  constant CPUread  : std_logic := '1';
  constant CPUwrite : std_logic := '0';
  constant addrPC : std_logic_vector(2 downto 0) := "000";
  constant addrSP : std_logic_vector(2 downto 0) := "001";
  constant addrHX : std_logic_vector(2 downto 0) := "010";
  constant addrTM : std_logic_vector(2 downto 0) := "011";
  constant addrX2 : std_logic_vector(2 downto 0) := "100";
  constant addrS2 : std_logic_vector(2 downto 0) := "101";
  constant addrX1 : std_logic_vector(2 downto 0) := "110";
  constant addrS1 : std_logic_vector(2 downto 0) := "111";
  constant outA    : std_logic_vector(3 downto 0) := "0000";
  constant outH    : std_logic_vector(3 downto 0) := "0001";
  constant outX    : std_logic_vector(3 downto 0) := "0010";
  constant outSPL  : std_logic_vector(3 downto 0) := "0011";
  constant outSPH  : std_logic_vector(3 downto 0) := "0100";
  constant outPCL  : std_logic_vector(3 downto 0) := "0101";
  constant outPCH  : std_logic_vector(3 downto 0) := "0110";
  constant outTL   : std_logic_vector(3 downto 0) := "0111";
  constant outTH   : std_logic_vector(3 downto 0) := "1000";
  constant outHelp : std_logic_vector(3 downto 0) := "1001";
  constant outCode : std_logic_vector(3 downto 0) := "1010";

  type    masker is array (0 to 7) of std_logic_vector(7 downto 0);
  signal mask0  : masker;
  signal mask1  : masker;
  signal regA   : std_logic_vector(7 downto 0);
  signal regHX  : std_logic_vector(15 downto 0);
  signal regSP  : std_logic_vector(15 downto 0);
  signal regPC  : std_logic_vector(15 downto 0);
  signal flagV  : std_logic;
  signal flagH  : std_logic;
  signal flagI  : std_logic;
  signal flagN  : std_logic;
  signal flagZ  : std_logic;
  signal flagC  : std_logic;
  signal help   : std_logic_vector(7 downto 0);
  signal temp   : std_logic_vector(15 downto 0);
  signal mainFSM : std_logic_vector(3 downto 0);
  signal addrMux : std_logic_vector(2 downto 0);
  signal dataMux : std_logic_vector(3 downto 0);
  signal opcode  : std_logic_vector(7 downto 0);
  signal escape9E : std_logic;
  signal prod     : std_logic_vector(15 downto 0);
  signal dividend : std_logic_vector(16 downto 0);
  signal divisor  : std_logic_vector(8 downto 0);
  signal quotient : std_logic_vector(8 downto 0);
  signal remainder: std_logic_vector(8 downto 0);
  signal irq_d      : std_logic;
  signal irqRequest : std_logic;

  signal trace       : std_logic;
  signal trace_i     : std_logic;
  signal traceOpCode : std_logic_vector(7 downto 0);
  
begin

  mul: mul8 port map(
    a    => regA,
    b    => regHX(7 downto 0),
    prod => prod
  );
  
  dividend <= "0" & regHX(15 downto 8) & regA;
  divisor  <= "0" & regHX(7 downto 0);
  div: divcas9 port map(
    dividend  => dividend,
    divisor   => divisor,
    quotient  => quotient,
    remainder => remainder
  );

  addr <= regPC          when addrMux = addrPC else
          regSP          when addrMux = addrSP else
          regHX          when addrMux = addrHX else
          temp           when addrMux = addrTM else
          (regHX + temp) when addrMux = addrX2 else
          (regSP + temp) when addrMux = addrS2 else
          (regHX + (x"00" & temp(7 downto 0))) when addrMux = addrX1 else
          (regSP + (x"00" & temp(7 downto 0)));
  dataout <= regA               when dataMux = outA else
             regHX(15 downto 8) when dataMux = outH else
             regHX( 7 downto 0) when dataMux = outX else
             regSP( 7 downto 0) when dataMux = outSPL else
             regSP(15 downto 8) when dataMux = outSPH else
             regPC( 7 downto 0) when dataMux = outPCL else
             regPC(15 downto 8) when dataMux = outPCH else
             temp ( 7 downto 0) when dataMux = outTL  else
             temp (15 downto 8) when dataMux = outTH  else
             help               when dataMux = outHelp else
             traceOpCode;

  state <= mainFSM;
  process(clk, rst)
    variable tres : std_logic_vector(7 downto 0);
    variable lres : std_logic_vector(15 downto 0);
  begin
    if rst = '0' then
      trace    <= '0';
      trace_i  <= '0';
      escape9E <= '0';
      mask0(0) <= "11111110";
      mask0(1) <= "11111101";
      mask0(2) <= "11111011";
      mask0(3) <= "11110111";
      mask0(4) <= "11101111";
      mask0(5) <= "11011111";
      mask0(6) <= "10111111";
      mask0(7) <= "01111111";
      mask1(0) <= "00000001";
      mask1(1) <= "00000010";
      mask1(2) <= "00000100";
      mask1(3) <= "00001000";
      mask1(4) <= "00010000";
      mask1(5) <= "00100000";
      mask1(6) <= "01000000";
      mask1(7) <= "10000000";
      wr <= CPUread;
      flagV <= '0';
      flagH <= '0';
      flagI <= '1'; -- irq disabled
      flagN <= '0';
      flagZ <= '0';
      flagC <= '0';
      regA    <= x"00";
      regHX   <= x"0000";  -- clear H register for 6805 compatible mode
      regSP   <= x"00FF";
      regPC   <= x"FFFE";
      temp    <= x"FFFE";
      help    <= x"00";
      dataMux <= outA;
      addrMux <= addrTM;
      irq_d   <= '1';
      irqRequest <= '0';
      mainFSM <= "0000";
    else
      if rising_edge(clk) then
        irq_d <= irq;
        if (irq = '0') and (irq_d = '1') and (flagI = '0') then -- irq falling edge ?
          irqRequest <= '1';
        end if;
        case mainFSM is
          when "0000" => --############# reset fetch PCH from FFFE
            regPC(15 downto 8) <= datain;
            temp    <= temp + 1;
            mainFSM <= "0001";
          when "0001" => --############# reset fetch PCL from FFFF
            regPC(7 downto 0)  <= datain;
            addrMux <= addrPC;
            mainFSM <= "0010";
            
          when "0010" => --##################### fetch opcode, instruction cycle 1
            trace <= trace_i;
            if trace = '1' then
              opcode      <= x"83"; -- special SWI trace
              traceOpCode <= datain;
              addrMux     <= addrSP;
              mainFSM     <= "0011";              
            elsif irqRequest = '1' then
              opcode      <= x"83"; -- special SWI interrupt
              addrMux     <= addrSP;
              mainFSM     <= "0011";              
            else
              opcode <= datain;
              case datain is
                when x"82" =>  -- RTT return trace special propietary instruction
                  trace_i <= '1';  -- arm trace for next instruction
                  regSP   <= regSP + 1;
                  addrMux <= addrSP;
                  mainFSM <= "0011";
                when x"9E" =>  -- escape byte for SP address
                  escape9E <= '1';
                  regPC    <= regPC + 1;
                  mainFSM  <= "0010";
                when x"00" | x"02" | x"04" | x"06" | x"08" | x"0A" | x"0C" | x"0E" |   -- BRSET n,opr8a,rel
                     x"01" | x"03" | x"05" | x"07" | x"09" | x"0B" | x"0D" | x"0F" |   -- BRCLR n,opr8a,rel
                     x"10" | x"12" | x"14" | x"16" | x"18" | x"1A" | x"1C" | x"1E" |   -- BSET n,opr8a
                     x"11" | x"13" | x"15" | x"17" | x"19" | x"1B" | x"1D" | x"1F" |   -- BCLR n,opr8a
                     x"30" | x"31" | x"33" | x"34" |   -- NEG opr8a, CBEQ opr8a,rel, COM opr8a, LSR opr8a
                     x"35" | x"36" | x"37" | x"38" |   -- STHX opr8a, ROR opr8a, ASR opr8a, LSL opr8a
                     x"39" | x"3A" | x"3B" | x"3C" |   -- ROL opr8a, DEC opr8a, DBNZ opr8a,rel, INC opr8a
                     x"3D" | x"3F" | x"4E" | x"55" |  -- TST opr8a, CLR opr8a, MOV opr8a,opr8a, LDHX opr
                     x"5E" | x"6E" | x"75" |  -- MOV opr8a,X+, MOV #opr8i,opr8a, CPHX opr
                     x"B0" | x"B1" | x"B2" | x"B3" |  -- SUB opr8a, CMP opr8a, SBC opr8a, CPX opr8a
                     x"B4" | x"B5" | x"B6" | x"B7" |  -- AND opr8a, BIT opr8a, LDA opr8a, STA opr8a
                     x"B8" | x"B9" | x"BA" | x"BB" |  -- EOR opr8a, ADC opr8a, ORA opr8a, ADD opr8a
                     x"BC" | x"BE" | x"BF" =>         -- JMP opr8a, LDX opr8a, STX opr8a
                  temp    <= x"0000";
                  regPC   <= regPC + 1;
                  mainFSM <= "0011";
                when x"20" | x"21" | x"22" | x"23" | x"24" | x"25" | x"26" | x"27" |
                     x"28" | x"29" | x"2A" | x"2B" | x"2C" | x"2D" | x"2E" | x"2F" |   -- branches
                     x"41" | x"45" | x"51" | x"65" |  -- CBEQA #opr8i,rel, LDHX #opr, CBEQX #opr8i,rel, CPHX #opr
                     x"90" | x"91" | x"92" | x"93" |  -- branches
                     x"C0" | x"C1" | x"C2" | x"C3" |  -- SUB opr16a, CMP opr16a, SBC opr16a, CPX opr16a
                     x"C4" | x"C5" | x"C6" | x"C7" |  -- AND opr16a, BIT opr16a, LDA opr16a, STA opr16a
                     x"C8" | x"C9" | x"CA" | x"CB" |  -- EOR opr16a, ADC opr16a, ORA opr16a, ADD opr16a
                     x"CC" | x"CE" | x"CF" |          -- JMP opr16a, LDX opr16a, STX opr16a
                     x"D0" | x"D1" | x"D2" | x"D3" |  -- SUB oprx16,X, CMP oprx16,X, SBC oprx16,X, CPX oprx16,X
                     x"D4" | x"D5" | x"D6" | x"D7" |  -- AND oprx16,X, BIT oprx16,X, LDA oprx16,X, STA oprx16,X
                     x"D8" | x"D9" | x"DA" | x"DB" |  -- EOR oprx16,X, ADC oprx16,X, ORA oprx16,X, ADD oprx16,X
                     x"DC" | x"DE" | x"DF" =>         -- JMP oprx16,X, LDX oprx16,X, STX oprx16,X
                  regPC <= regPC + 1;
                  mainFSM <= "0011";
                when x"70" | x"71" | x"73" | x"74" | x"76" | x"77" |  -- NEG ,X, CBEQ ,X+,rel, COM ,X, LSR ,X, ROR ,X, ASR ,X
                     x"78" | x"79" | x"7A" | x"7B" | x"7C" | x"7D" |  -- LSL ,X, ROL ,X, DEC ,X, DBNZ ,X,rel, INC ,X, TXT ,X
                     x"7E" =>  -- MOV ,X+,opr8a
                  addrMux <= addrHX;
                  regPC   <= regPC + 1;
                  mainFSM <= "0100";
                when x"A0" | x"A1" | x"A2" | x"A3" |  -- SUB #opr8i, CMP #opr8i, SBC #opr8i, CPX #opr8i
                     x"A4" | x"A5" | x"A6" | x"A7" |  -- AND #opr8i, BIT #opr8i, LDA #opr8i, AIS
                     x"A8" | x"A9" | x"AA" | x"AB" |  -- EOR #opr8i, ADC #opr8i, ORA #opr8i, ADD #opr8i
                     x"AE" | x"AF" =>  -- LDX #opr8i, AIX
                  regPC <= regPC + 1;
                  mainFSM <= "0101";
                when x"E0" | x"E1" | x"E2" | x"E3" |  -- SUB oprx8,X, CMP oprx8,X, SBC oprx8,X, CPX oprx8,X
                     x"E4" | x"E5" | x"E6" | x"E7" |  -- AND oprx8,X, BIT oprx8,X, LDA oprx8,X, STA oprx8,X
                     x"E8" | x"E9" | x"EA" | x"EB" |  -- EOR oprx8,X, ADC oprx8,X, ORA oprx8,X, ADD oprx8,X
                     x"EC" | x"EE" | x"EF" =>         -- JMP oprx8,X, LDX oprx8,X, STX oprx8,X
                  regPC <= regPC + 1;
                  mainFSM <= "0100";
                when x"F0" | x"F1" | x"F2" | x"F3" |  -- SUB ,X, CMP ,X, SBC ,X, CPX ,X
                     x"F4" | x"F5" | x"F6" |          -- AND ,X, BIT ,X, LDA ,X
                     x"F8" | x"F9" | x"FA" | x"FB" |  -- EOR ,X, ADC ,X, ORA ,X, ADD ,X
                     x"FE" =>                         -- LDX ,X
                  addrMux <= addrHX;
                  regPC   <= regPC + 1;
                  mainFSM <= "0101";
                when x"FC" =>  -- JMP ,X
                  regPC <= regHX;
                  mainFSM <= "0010";
                when x"F7" =>  -- STA ,X
                  wr <= CPUwrite;
                  flagV <= '0';
                  flagN <= regA(7);
                  if regA = x"00" then
                    flagZ <= '1';
                  else
                    flagZ <= '0';
                  end if;
                  dataMux <= outA;
                  addrMux <= addrHX;
                  regPC <= regPC + 1;
                  mainFSM <= "0101";
                when x"FF" =>  -- STX ,X
                  wr <= CPUwrite;
                  flagV <= '0';
                  flagN <= regHX(7);
                  if regHX(7 downto 0) = x"00" then
                    flagZ <= '1';
                  else
                    flagZ <= '0';
                  end if;
                  dataMux <= outX;
                  addrMux <= addrHX;
                  regPC <= regPC + 1;
                  mainFSM <= "0101";    
                when x"40" =>  -- NEGA
                  regA    <= x"00" - regA;
                  tres    := x"00" - regA;
                  flagV   <= tres(7) and regA(7);
                  flagN   <= tres(7);
                  if tres = x"00" then
                    flagZ <= '1';
                    flagC <= '0';
                  else
                    flagC <= '1';
                    flagZ <= '0';
                  end if;
                  regPC <= regPC + 1;
                  mainFSM <= "0010";
                when x"42" =>  -- MUL
                  flagH <= '0';
                  flagC <= '0';
                  regA              <= prod(7 downto 0);
                  regHX(7 downto 0) <= prod(15 downto 8);
                  regPC <= regPC + 1;
                  mainFSM <= "0010";
                when x"43" =>  -- COMA
                  regA    <= regA xor x"FF";
                  tres    := regA xor x"FF";
                  flagV   <= '0';
                  flagC   <= '1';
                  flagN   <= tres(7);
                  if tres = x"00" then
                    flagZ <= '1';
                  else
                    flagZ <= '0';
                  end if;
                  regPC <= regPC + 1;
                  mainFSM <= "0010";
                when x"44" =>  -- LSRA
                  regA    <= "0" & regA(7 downto 1);
                  tres    := "0" & regA(7 downto 1);
                  flagV   <= regA(0);
                  flagN   <= '0';
                  flagC   <= regA(0);
                  if tres = x"00" then
                    flagZ <= '1';
                  else
                    flagZ <= '0';
                  end if;
                  regPC <= regPC + 1;
                  mainFSM <= "0010";
                when x"46" =>  -- RORA
                  regA    <= flagC & regA(7 downto 1);
                  tres    := flagC & regA(7 downto 1);
                  flagN   <= flagC;
                  flagC   <= regA(0);
                  flagV   <= flagC xor regA(0);
                  if tres = x"00" then
                    flagZ <= '1';
                  else
                    flagZ <= '0';
                  end if;
                  regPC <= regPC + 1;
                  mainFSM <= "0010";
                when x"47" =>  -- ASRA
                  regA    <= regA(7) & regA(7 downto 1);
                  tres    := regA(7) & regA(7 downto 1);
                  flagN   <= regA(7);
                  flagC   <= regA(0);
                  flagV   <= regA(7) xor regA(0);
                  if tres = x"00" then
                    flagZ <= '1';
                  else
                    flagZ <= '0';
                  end if;
                  regPC <= regPC + 1;
                  mainFSM <= "0010";
                when x"48" =>  -- LSLA
                  regA    <= regA(6 downto 0) & "0";
                  tres    := regA(6 downto 0) & "0";
                  flagN   <= regA(6);
                  flagC   <= regA(7);
                  flagV   <= regA(7) xor regA(6);
                  if tres = x"00" then
                    flagZ <= '1';
                  else
                    flagZ <= '0';
                  end if;
                  regPC <= regPC + 1;
                  mainFSM <= "0010";
                when x"49" =>  -- ROLA
                  regA    <= regA(6 downto 0) & flagC;
                  tres    := regA(6 downto 0) & flagC;
                  flagN   <= regA(6);
                  flagC   <= regA(7);
                  flagV   <= regA(7) xor regA(6);
                  if tres = x"00" then
                    flagZ <= '1';
                  else
                    flagZ <= '0';
                  end if;
                  regPC <= regPC + 1;
                  mainFSM <= "0010";
                when x"4A" =>  -- DECA
                  regA    <= regA - 1;
                  tres    := regA - 1;
                  flagN   <= tres(7);
                  if regA = x"80" then
                    flagV <= '1';
                  else
                    flagV <= '0';
                  end if;
                  if tres = x"00" then
                    flagZ <= '1';
                  else
                    flagZ <= '0';
                  end if;
                  regPC <= regPC + 1;
                  mainFSM <= "0010";
                when x"4B" =>  -- DBNZA rel
                  regA <= regA - 1;
                  tres := regA - 1;
                  if tres = x"00" then
                    regPC <= regPC + 2;
                    mainFSM <= "0010";
                  else
                    regPC <= regPC + 1;
                    mainFSM <= "0011";
                  end if;
                when x"4C" =>  -- INCA
                  regA    <= regA + 1;
                  tres    := regA + 1;
                  flagN   <= tres(7);
                  if regA = x"7F" then
                    flagV <= '1';
                  else
                    flagV <= '0';
                  end if;
                  if tres = x"00" then
                    flagZ <= '1';
                  else
                    flagZ <= '0';
                  end if;
                  regPC <= regPC + 1;
                  mainFSM <= "0010";
                when x"4D" =>  -- TSTA
                  flagN   <= regA(7);
                  flagV   <= '0';
                  if regA = x"00" then
                    flagZ <= '1';
                  else
                    flagZ <= '0';
                  end if;
                  regPC <= regPC + 1;
                  mainFSM <= "0010";
                when x"4F" =>  -- CLRA
                  regA <= x"00";
                  flagV <= '0';
                  flagN <= '0';
                  flagZ <= '1';
                  regPC <= regPC + 1;
                  mainFSM <= "0010";
                when x"50" =>  -- NEGX
                  regHX(7 downto 0) <= x"00" - regHX(7 downto 0);
                  tres    := x"00" - regHX(7 downto 0);
                  flagV   <= tres(7) and regHX(7);
                  flagN   <= tres(7);
                  if tres = x"00" then
                    flagZ <= '1';
                    flagC <= '0';
                  else
                    flagC <= '1';
                    flagZ <= '0';
                  end if;
                  regPC <= regPC + 1;
                  mainFSM <= "0010";
                when x"52" =>  -- DIV
                  regPC <= regPC + 1;
                  mainFSM <= "0011";
                when x"53" =>  -- COMX
                  regHX(7 downto 0) <= regHX(7 downto 0) xor x"FF";
                  tres    := regHX(7 downto 0) xor x"FF";
                  flagV   <= '0';
                  flagC   <= '1';
                  flagN   <= tres(7);
                  if tres = x"00" then
                    flagZ <= '1';
                  else
                    flagZ <= '0';
                  end if;
                  regPC <= regPC + 1;
                  mainFSM <= "0010";
                when x"54" =>  -- LSRX
                  regHX(7 downto 0) <= "0" & regHX(7 downto 0)(7 downto 1);
                  tres    := "0" & regHX(7 downto 0)(7 downto 1);
                  flagV   <= regHX(0);
                  flagN   <= '0';
                  flagC   <= regHX(0);
                  if tres = x"00" then
                    flagZ <= '1';
                  else
                    flagZ <= '0';
                  end if;
                  regPC <= regPC + 1;
                  mainFSM <= "0010";
                when x"56" =>  -- RORX
                  regHX(7 downto 0) <= flagC & regHX(7 downto 1);
                  tres    := flagC & regHX(7 downto 1);
                  flagN   <= flagC;
                  flagC   <= regHX(0);
                  flagV   <= flagC xor regHX(0);
                  if tres = x"00" then
                    flagZ <= '1';
                  else
                    flagZ <= '0';
                  end if;
                  regPC <= regPC + 1;
                  mainFSM <= "0010";
                when x"57" =>  -- ASRX
                  regHX(7 downto 0) <= regHX(7) & regHX(7 downto 1);
                  tres    := regHX(7) & regHX(7 downto 1);
                  flagN   <= regHX(7);
                  flagC   <= regHX(0);
                  flagV   <= regHX(7) xor regHX(0);
                  if tres = x"00" then
                    flagZ <= '1';
                  else
                    flagZ <= '0';
                  end if;
                  regPC <= regPC + 1;
                  mainFSM <= "0010";
                when x"58" =>  -- LSLX
                  regHX(7 downto 0) <= regHX(6 downto 0) & "0";
                  tres    := regHX(6 downto 0) & "0";
                  flagN   <= regHX(6);
                  flagC   <= regHX(7);
                  flagV   <= regHX(7) xor regHX(6);
                  if tres = x"00" then
                    flagZ <= '1';
                  else
                    flagZ <= '0';
                  end if;
                  regPC <= regPC + 1;
                  mainFSM <= "0010";
                when x"59" =>  -- ROLX
                  regHX(7 downto 0) <= regHX(6 downto 0) & flagC;
                  tres    := regHX(6 downto 0) & flagC;
                  flagN   <= regHX(6);
                  flagC   <= regHX(7);
                  flagV   <= regHX(7) xor regHX(6);
                  if tres = x"00" then
                    flagZ <= '1';
                  else
                    flagZ <= '0';
                  end if;
                  regPC <= regPC + 1;
                  mainFSM <= "0010";
                when x"5A" =>  -- DECX
                  regHX(7 downto 0) <= regHX(7 downto 0) - 1;
                  tres    := regHX(7 downto 0) - 1;
                  flagN   <= tres(7);
                  if regHX(7 downto 0) = x"80" then
                    flagV <= '1';
                  else
                    flagV <= '0';
                  end if;
                  if tres = x"00" then
                    flagZ <= '1';
                  else
                    flagZ <= '0';
                  end if;
                  regPC <= regPC + 1;
                  mainFSM <= "0010";
                when x"5B" =>  -- DBNZX rel
                  regHX(7 downto 0) <= regHX(7 downto 0) - 1;
                  tres := regHX(7 downto 0) - 1;
                  if tres = x"00" then
                    regPC <= regPC + 2;
                    mainFSM <= "0010";
                  else
                    regPC <= regPC + 1;
                    mainFSM <= "0011";
                  end if;
                when x"5C" =>  -- INCX
                  regHX(7 downto 0) <= regHX(7 downto 0) + 1;
                  tres    := regHX(7 downto 0) + 1;
                  flagN   <= tres(7);
                  if regHX(7 downto 0) = x"7F" then
                    flagV <= '1';
                  else
                    flagV <= '0';
                  end if;
                  if tres = x"00" then
                    flagZ <= '1';
                  else
                    flagZ <= '0';
                  end if;
                  regPC <= regPC + 1;
                  mainFSM <= "0010";
                when x"5D" =>  -- TSTX
                  flagN   <= regHX(7);
                  flagV   <= '0';
                  if regHX(7 downto 0) = x"00" then
                    flagZ <= '1';
                  else
                    flagZ <= '0';
                  end if;
                  regPC <= regPC + 1;
                  mainFSM <= "0010";
                when x"5F" =>  -- CLRX
                  regHX(7 downto 0) <= x"00";
                  flagV <= '0';
                  flagN <= '0';
                  flagZ <= '1';
                  regPC <= regPC + 1;
                  mainFSM <= "0010";
                when x"60" | x"61" | x"63" | x"64" | x"66" | -- NEG oprx8,X, CBEQ oprx8,X+,rel, COM oprx8,X, LSR oprx8,X, ROR oprx8,X
                     x"67" | x"68" | x"69" | x"6A" | x"6B" |  -- ASR oprx8,X, LSL oprx8,X, ROL oprx8,X, DEC oprx8,X, DBNZ oprx8,X,rel
                     x"6C" | x"6D" | x"6F" =>  -- INC oprx8,X, TST oprx8,X, CLR oprx8,X
                  if escape9E = '1' then
                    if datain /= x"61" then
                      escape9E <= '0';
                    end if;
                    temp <= regSP;
                  else
                    temp <= regHX;
                  end if;
                  regPC   <= regPC + 1;
                  mainFSM <= "0011";
                when x"62" =>  -- NSA
                  escape9E <= '0';
                  regA <= regA(3 downto 0) & regA(7 downto 4);
                  regPC   <= regPC + 1;
                  mainFSM <= "0010";
                when x"72" =>  -- DAA
                  if flagC = '0' then
                    if flagH = '0' then
                      if (regA(7 downto 4) < 10) and (regA(3 downto 0) < 10) then
                        if regA = x"00" then
                          flagZ <= '1';
                        else
                          flagZ <= '0';
                        end if;
                        flagN <= regA(7);
                      elsif (regA(7 downto 4) < 9) and (regA(3 downto 0) > 9) then
                        regA <= regA + x"06";
                        tres := regA + x"06";
                        flagN <= tres(7);
                        if tres = x"00" then
                          flagZ <= '1';
                        else
                          flagZ <= '0';
                        end if;
                      elsif (regA(7 downto 4) > 9) and (regA(3 downto 0) < 10) then
                        regA <= regA + x"60";
                        tres := regA + x"60";
                        flagC <= '1';
                        flagN <= tres(7);
                        if tres = x"00" then
                          flagZ <= '1';
                        else
                          flagZ <= '0';
                        end if;
                      elsif (regA(7 downto 4) > 8) and (regA(3 downto 0) > 9) then
                        regA <= regA + x"66";
                        tres := regA + x"66";
                        flagC <= '1';
                        flagN <= tres(7);
                        if tres = x"00" then
                          flagZ <= '1';
                        else
                          flagZ <= '0';
                        end if;
                      end if;
                    else
                      if (regA(7 downto 4) < 10) and (regA(3 downto 0) < 4) then
                        regA <= regA + x"06";
                        tres := regA + x"06";
                        flagN <= tres(7);
                        if tres = x"00" then
                          flagZ <= '1';
                        else
                          flagZ <= '0';
                        end if;
                      elsif (regA(7 downto 4) > 9) and (regA(3 downto 0) < 4) then
                        regA <= regA + x"66";
                        tres := regA + x"66";
                        flagC <= '1';
                        flagN <= tres(7);
                        if tres = x"00" then
                          flagZ <= '1';
                        else
                          flagZ <= '0';
                        end if;                    
                      end if;
                    end if;
                  else
                    if flagH = '0' then
                      if (regA(7 downto 3) < 3) and (regA(3 downto 0) < 10) then
                        regA <= regA + x"60";
                        tres := regA + x"60";
                        flagC <= '1';
                        flagN <= tres(7);
                        if tres = x"00" then
                          flagZ <= '1';
                        else
                          flagZ <= '0';
                        end if;                    
                      elsif (regA(7 downto 3) < 3) and (regA(3 downto 0) > 9) then
                        regA <= regA + x"66";
                        tres := regA + x"66";
                        flagC <= '1';
                        flagN <= tres(7);
                        if tres = x"00" then
                          flagZ <= '1';
                        else
                          flagZ <= '0';
                        end if;                    
                      end if;
                    else
                      if (regA(7 downto 3) < 4) and (regA(3 downto 0) < 4) then
                        regA <= regA + x"66";
                        tres := regA + x"66";
                        flagC <= '1';
                        flagN <= tres(7);
                        if tres = x"00" then
                          flagZ <= '1';
                        else
                          flagZ <= '0';
                        end if;                    
                      end if;                    
                    end if;
                  end if;
                  regPC   <= regPC + 1;
                  mainFSM <= "0010";
                when x"7F" =>  -- CLR ,X
                  flagV <= '0';
                  flagN <= '0';
                  flagZ <= '1';
                  addrMux <= addrHX;
                  dataMux <= outHelp;
                  wr <= CPUwrite;
                  help <= x"00";
                  regPC <= regPC + 1;
                  mainFSM <= "0011";
                when x"80" | x"81" =>  -- RTI, RTS
                  regSP   <= regSP + 1;
                  addrMux <= addrSP;
                  mainFSM <= "0011";
                when x"83" =>  -- SWI
                  regPC   <= regPC + 1;
                  addrMux <= addrSP;
                  mainFSM <= "0011";
                when x"84" =>  -- TAP
                  flagN <= regA(7);
                  flagH <= regA(4);
                  flagI <= regA(3);
                  flagN <= regA(2);
                  flagZ <= regA(1);
                  flagC <= regA(0);
                  regPC   <= regPC + 1;
                  mainFSM <= "0010";
                when x"85" =>  -- TPA
                  regA(7) <= flagN;
                  regA(6) <= '1';
                  regA(5) <= '1';
                  regA(4) <= flagH;
                  regA(3) <= flagI;
                  regA(2) <= flagN;
                  regA(1) <= flagZ;
                  regA(0) <= flagC;
                  regPC   <= regPC + 1;
                  mainFSM <= "0010";
                when x"86" | x"88" | x"8A" =>  -- PULA, PULX, PULH
                  addrMux <= addrSP;
                  regSP   <= regSP + 1;
                  regPC   <= regPC + 1;
                  mainFSM <= "0011";
                when x"87" =>  -- PSHA
                  wr <= CPUwrite;
                  dataMux <= outA;
                  addrMux <= addrSP;
                  regPC   <= regPC + 1;
                  mainFSM <= "0011";
                when x"89" =>  -- PSHX
                  wr <= CPUwrite;
                  dataMux <= outX;
                  addrMux <= addrSP;
                  regPC   <= regPC + 1;
                  mainFSM <= "0011";
                when x"8B" =>  -- PSHH
                  wr <= CPUwrite;
                  dataMux <= outH;
                  addrMux <= addrSP;
                  regPC   <= regPC + 1;
                  mainFSM <= "0011";
                when x"8C" =>  -- CLRH
                  regHX(15 downto 8) <= x"00";
                  flagV <= '0';
                  flagN <= '0';
                  flagZ <= '1';
                  regPC   <= regPC + 1;
                  mainFSM <= "0010";
                when x"8E" =>  -- STOP currently unsupported
                  regPC   <= regPC + 1;
                  mainFSM <= "0010";
                when x"8F" =>  -- WAIT currently unsupported
                  regPC   <= regPC + 1;
                  mainFSM <= "0010";
                when x"94" =>  -- TXS   
                  regSP <= regHX - 1; 
                  regPC   <= regPC + 1;
                  mainFSM <= "0010";
                when x"95" =>  -- TSX   
                  regHX <= regSP + 1; 
                  regPC   <= regPC + 1;
                  mainFSM <= "0010";
                when x"97" =>  -- TAX
                  regHX(7 downto 0) <= regA;
                  regPC   <= regPC + 1;
                  mainFSM <= "0010";
                when x"98" | x"99" =>  -- CLC, SEC
                  flagC <= datain(0);
                  regPC   <= regPC + 1;
                  mainFSM <= "0010";
                when x"9A" | x"9B" =>  -- CLI, SEI  ATTENTION!!!
                  flagI <= datain(0);
                  regPC   <= regPC + 1;
                  mainFSM <= "0010";
                when x"9C" =>  -- RSP
                  regSP <= x"00FF";
                  regPC   <= regPC + 1;
                  mainFSM <= "0010";                
                when x"9D" =>  -- NOP
                  regPC   <= regPC + 1;
                  mainFSM <= "0010";
                when x"9F" =>  -- TXA
                  regA <= regHX(7 downto 0);
                  regPC   <= regPC + 1;
                  mainFSM <= "0010";
                when x"AD" | x"BD" | x"ED" =>  -- BSR rel, JSR opr8a, JSR oprx8,X
                  temp    <= regPC + 2;
                  regPC   <= regPC + 1;
                  mainFSM <= "0011";
                when x"CD" | x"DD" =>  -- JSR opr16a, JSR oprx16,X
                  temp    <= regPC + 3;
                  regPC   <= regPC + 1;
                  mainFSM <= "0011";
                when x"FD" =>  -- JSR ,X
                  temp    <= regPC + 1;
                  wr      <= CPUwrite;
                  addrMux <= addrSP;
                  dataMux <= outTL;
                  regPC   <= regPC + 1;
                  mainFSM <= "0100";
                

                when others =>
                  mainFSM <= "0000";
              end case; -- datain
            end if; -- trace = '1'
            
          when "0011" => --##################### instruction cycle 2  
            case opcode is
              when x"00" | x"02" | x"04" | x"06" | x"08" | x"0A" | x"0C" | x"0E" |   -- BRSET n,opr8a,rel
                   x"01" | x"03" | x"05" | x"07" | x"09" | x"0B" | x"0D" | x"0F" |   -- BRCLR n,opr8a,rel
                   x"10" | x"12" | x"14" | x"16" | x"18" | x"1A" | x"1C" | x"1E" |   -- BSET n,opr8a
                   x"11" | x"13" | x"15" | x"17" | x"19" | x"1B" | x"1D" | x"1F" |   -- BCLR n,opr8a
                   x"30" | x"31" | x"33" | x"34" | x"36" |          -- NEG opr8a, CBEQ opr8a,rel, COM opr8a, LSR opr8a, ROR opr8a
                   x"37" | x"38" | x"39" | x"3A" | x"3B" | x"3C" |  -- ASR opr8a, LSL opr8a, ROL opr8a, DEC opr8a, DBNZ opr8a,rel, INC opr8a
                   x"3D" | x"4E" | x"55" | x"5E" | x"75" =>         -- TST opr8a, MOV opr8a,opr8a, LDHX opr, MOV opr8a,X+, CPHX opr
                temp(7 downto 0) <= datain;
                addrMux <= addrTM;
                regPC <= regPC + 1;
                mainFSM <= "0100";
              when x"C0" | x"C1" | x"C2" | x"C3" |  -- SUB opr16a, CMP opr16a, SBC opr16a, CPX opr16a
                   x"C4" | x"C5" | x"C6" | x"C7" |  -- AND opr16a, BIT opr16a, LDA opr16a, STA opr16a
                   x"C8" | x"C9" | x"CA" | x"CB" |  -- EOR opr16a, ADC opr16a, ORA opr16a, ADD opr16a
                   x"CC" | x"CE" | x"CF" |          -- JMP opr16a, LDX opr16a, STX opr16a
                   x"D0" | x"D1" | x"D2" | x"D3" |  -- SUB oprx16,X, CMP oprx16,X, SBC oprx16,X, CPX oprx16,X
                   x"D4" | x"D5" | x"D6" | x"D7" |  -- AND oprx16,X, BIT oprx16,X, LDA oprx16,X, STA oprx16,X
                   x"D8" | x"D9" | x"DA" | x"DB" |  -- EOR oprx16,X, ADC oprx16,X, ORA oprx16,X, ADD oprx16,X
                   x"DC" | x"DE" | x"DF" =>         -- JMP oprx16,X, LDX oprx16,X, STX oprx16,X
                temp(15 downto 8) <= datain;
                regPC <= regPC + 1;
                mainFSM <= "0100";                
              when x"52" =>  -- DIV
                if quotient(7 downto 0) = x"00" then
                  flagZ <= '1';
                else
                  flagZ <= '0';
                end if;
                if regHX(7 downto 0) = x"00" then -- divide by zero
                  flagC <= '1';
                else
                  if regHX(15 downto 8) < regHX(7 downto 0) then
                    flagC <= '0';
                    regA  <= quotient(7 downto 0);
                    if remainder(8) = '1' then
                      lres  := ("0000000" & remainder) + (x"00" & regHX(7 downto 0));
                    else
                      lres  :=  "0000000" & remainder;
                    end if;
                    regHX(15 downto 8) <= lres(7 downto 0);
                  else
                    flagC <= '1';
                  end if;
                end if;
                mainFsm <= "0010";
              when x"B7" =>  -- STA opr8a
                wr <= CPUwrite;
                dataMux <= outA;
                temp(7 downto 0) <= datain;
                addrMux <= addrTM;
                regPC <= regPC + 1;
                mainFSM <= "0101";
              when x"BF" =>  -- STX opr8a
                wr <= CPUwrite;
                dataMux <= outX;
                temp(7 downto 0) <= datain;
                addrMux <= addrTM;
                regPC <= regPC + 1;
                mainFSM <= "0101";
              when x"B0" | x"B1" | x"B2" | x"B3" |  -- SUB opr8a, CMP opr8a, SBC opr8a, CPX opr8a
                   x"B4" | x"B5" | x"B6" |          -- AND opr8a, BIT opr8a, LDA opr8a
                   x"B8" | x"B9" | x"BA" | x"BB" |  -- EOR opr8a, ADC opr8a, ORA opr8a, ADD opr8a
                   x"BE" =>                         -- LDX opr8a
                temp(7 downto 0) <= datain;
                addrMux <= addrTM;
                regPC <= regPC + 1;
                mainFSM <= "0101";
              
              when x"20" | x"4B" | x"5B" =>  -- BRA, DBNZA rel, DBNZX rel
                if datain(7) = '0' then
                  regPC <= regPC + (x"00" & datain) + x"0001";
                else
                  regPC <= regPC + (x"FF" & datain) + x"0001";
                end if;
                mainFSM <= "0010";
              when x"21" =>  -- BRN
                regPC <= regPC + 1;
                mainFSM <= "0010";
              when x"22" | x"23" =>  -- BHI, BLS
                if (flagC or flagZ) = opcode(0) then
                  if datain(7) = '0' then
                    regPC <= regPC + (x"00" & datain) + x"0001";
                  else
                    regPC <= regPC + (x"FF" & datain) + x"0001";
                  end if;
                else
                  regPC <= regPC + 1;
                end if;
                mainFSM <= "0010";
              when x"24" | x"25" =>  -- BCC, BCS
                if (flagC = opcode(0)) then
                  if datain(7) = '0' then
                    regPC <= regPC + (x"00" & datain) + x"0001";
                  else
                    regPC <= regPC + (x"FF" & datain) + x"0001";
                  end if;
                else
                  regPC <= regPC + 1;
                end if;
                mainFSM <= "0010";
              when x"26" | x"27" =>  -- BNE, BEQ
                if (flagZ = opcode(0)) then
                  if datain(7) = '0' then
                    regPC <= regPC + (x"00" & datain) + x"0001";
                  else
                    regPC <= regPC + (x"FF" & datain) + x"0001";
                  end if;
                else
                  regPC <= regPC + 1;
                end if;
                mainFSM <= "0010";
              when x"28" | x"29" =>  -- BHCC, BHCS
                if (flagH = opcode(0)) then
                  if datain(7) = '0' then
                    regPC <= regPC + (x"00" & datain) + x"0001";
                  else
                    regPC <= regPC + (x"FF" & datain) + x"0001";
                  end if;
                else
                  regPC <= regPC + 1;
                end if;
                mainFSM <= "0010";
              when x"2A" | x"2B" =>  -- BPL, BMI
                if (flagN = opcode(0)) then
                  if datain(7) = '0' then
                    regPC <= regPC + (x"00" & datain) + x"0001";
                  else
                    regPC <= regPC + (x"FF" & datain) + x"0001";
                  end if;
                else
                  regPC <= regPC + 1;
                end if;
                mainFSM <= "0010";
              when x"2C" | x"2D" =>  -- BMC, BMS
                if (flagI = opcode(0)) then
                  if datain(7) = '0' then
                    regPC <= regPC + (x"00" & datain) + x"0001";
                  else
                    regPC <= regPC + (x"FF" & datain) + x"0001";
                  end if;
                else
                  regPC <= regPC + 1;
                end if;
                mainFSM <= "0010";
              when x"2E" | x"2F" =>  -- BIL, BIH
                if (irq = opcode(0)) then
                  if datain(7) = '0' then
                    regPC <= regPC + (x"00" & datain) + x"0001";
                  else
                    regPC <= regPC + (x"FF" & datain) + x"0001";
                  end if;
                else
                  regPC <= regPC + 1;
                end if;
                mainFSM <= "0010";
              when x"35" =>  -- STHX opr8a
                wr <= CPUwrite;
                dataMux <= outH;
                temp(7 downto 0) <= datain;
                addrMux <= addrTM;
                regPC <= regPC + 1;
                flagV <= '0';
                flagN <= regHX(15);
                if regHX = x"0000" then
                  flagZ <= '1';
                else
                  flagZ <= '0';
                end if;
                mainFSM <= "0100";
              when x"3F" | x"6F" =>  -- CLR opr8a, CLR oprx8,X
                wr <= CPUwrite;
                case opcode is
                  when x"3F" =>
                    temp(7 downto 0) <= datain;
                  when x"6F" =>
                    temp    <= temp + (x"00" & datain);                    
                  when others =>
                    temp <= x"0000";
                end case;
                addrMux <= addrTM;
                dataMux <= outHelp;
                flagZ   <= '1';
                flagV   <= '0';
                flagN   <= '0';
                help    <= x"00";
                regPC   <= regPC + 1;
                mainFSM <= "0100";
              when x"41" =>  -- CBEQA #opr8i,rel
                if datain = regA then
                  regPC <= regPC + 1;
                  mainFSM <= "0100";
                else
                  regPC <= regPC + 2;
                  mainFSM <= "0010";
                end if;
              when x"45" =>  -- LDHX #opr
                regHX(15 downto 8) <= datain;
                flagN   <= datain(7);
                flagV   <= '0';
                regPC   <= regPC + 1;
                mainFSM <= "0100";
              when x"51" =>  -- CBEQA #opr8i,rel
                if datain = regHX(7 downto 0) then
                  regPC <= regPC + 1;
                  mainFSM <= "0100";
                else
                  regPC <= regPC + 2;
                  mainFSM <= "0010";
                end if;
              when x"60" | x"61" | x"63" | x"64" | x"66" |  -- NEG oprx8,X, CBEQ oprx8,X+,rel, COM oprx8,X, LSR oprx8,X, ROR oprx8,X
                   x"67" | x"68" | x"69" | x"6A" | x"6B" |  -- ASR oprx8,X, LSL oprx8,X, ROL oprx8,X, DEC oprx8,X, DBNZ oprx8,X,rel
                   x"6C" | x"6D" =>  -- INC oprx8,X, TST oprx8,X
                temp    <= temp + (x"00" & datain);
                regPC   <= regPC + 1;
                addrMux <= addrTM;
                mainFSM <= "0100";
              when x"65" | x"6E" =>  -- CPHX #opr, MOV #opr8i,opr8a
                escape9E <= '0';
                help    <= datain;
                regPC   <= regPC + 1;
                mainFSM <= "0100";
              when x"7F" =>  -- CLR ,X
                wr <= CPUread;
                addrMux <= addrPC;
                mainFSM <= "0010";
              when x"80" | x"82" =>  -- RTI, RTT
                flagV <= datain(7);
                flagH <= datain(4);
                flagI <= datain(3);  ------- PLEASE RESTORE AT LATER TIME
                flagN <= datain(2);
                flagZ <= datain(1);
                flagC <= datain(0);
                regSP <= regSP + 1;
                mainFSM <= "0100";
              when x"81" =>  -- RTS
                regPC(15 downto 8) <= datain;
                regSP <= regSP + 1;
                mainFSM <= "0100";
              when x"83" =>  -- SWI
                wr <= CPUwrite;
                dataMux <= outPCL;
                mainFSM <= "0100";
              when x"86" =>  -- PULA
                regA <= datain;
                addrMux <= addrPC;
                mainFSM <= "0010";
              when x"87" | x"89" | x"8B" =>  -- PSHA, PSHX, PSHH
                wr <= CPUread;
                regSP <= regSP - 1;
                addrMux <= addrPC;
                mainFSM <= "0010";
              when x"88" =>  -- PULX
                regHX(7 downto 0) <= datain;
                addrMux <= addrPC;
                mainFSM <= "0010";
              when x"8A" =>  -- PULH
                regHX(15 downto 8) <= datain;
                addrMux <= addrPC;
                mainFSM <= "0010";
              when x"90" | x"91" =>  -- BGE, BLT
                if ((flagN xor flagV) = opcode(0)) then
                  if datain(7) = '0' then
                    regPC <= regPC + (x"00" & datain) + x"0001";
                  else
                    regPC <= regPC + (x"FF" & datain) + x"0001";
                  end if;
                else
                  regPC <= regPC + 1;
                end if;
                mainFSM <= "0010";
              when x"92" | x"93" =>  -- BGT, BLE
                if ((flagZ or (flagN xor flagV)) = opcode(0)) then
                  if datain(7) = '0' then
                    regPC <= regPC + (x"00" & datain) + x"0001";
                  else
                    regPC <= regPC + (x"FF" & datain) + x"0001";
                  end if;
                else
                  regPC <= regPC + 1;
                end if;
                mainFSM <= "0010";
              when x"AD" | x"BD" | x"ED" =>  -- BSR rel, JSR opr8a, JSR oprx8,X
                regPC <= regPC + 1;
                wr   <= CPUwrite;
                help <= datain;
                addrMux <= addrSP;
                dataMux <= outPCL;
                mainFSM <= "0100";
              when x"BC" =>  -- JMP opr8a
                regPC <= (x"00" & datain);
                mainFSM <= "0010";
              when x"CD" | x"DD" =>  -- JSR opr16a, JSR oprx16,X
                temp(15 downto 8) <= datain;
                regPC <= regPC + 1;
                mainFSM <= "0100";
                
              when others =>
                mainFSM <= "0000";
            end case; -- opcode
          
          when "0100" => --##################### instruction cycle 3
            case opcode is
              when x"00" | x"02" | x"04" | x"06" | x"08" | x"0A" | x"0C" | x"0E" |   -- BRSET n,opr8a,rel
                   x"01" | x"03" | x"05" | x"07" | x"09" | x"0B" | x"0D" | x"0F" =>  -- BRCLR n,opr8a,rel
                if (datain and mask1(conv_integer(opcode(3 downto 1)))) /= x"00" then
                  flagC <= '1';
                else
                  flagC <= '0';
                end if;
                addrMux <= addrPC;
                mainFSM <= "0101";
              when x"10" | x"12" | x"14" | x"16" | x"18" | x"1A" | x"1C" | x"1E" |   -- BSET n,opr8a
                   x"11" | x"13" | x"15" | x"17" | x"19" | x"1B" | x"1D" | x"1F" =>  -- BCLR n,opr8a
                wr <= CPUwrite;
                dataMux <= outHelp;
                if opcode(0) = '0' then
                  help <= datain or  mask1(conv_integer(opcode(3 downto 1)));
                else
                  help <= datain and mask0(conv_integer(opcode(3 downto 1)));
                end if;
                mainFSM <= "0101";
              when x"C0" | x"C1" | x"C2" | x"C3" |  -- SUB opr16a, CMP opr16a, SBC opr16a, CPX opr16a
                   x"C4" | x"C5" | x"C6" |          -- AND opr16a, BIT opr16a, LDA opr16a
                   x"C8" | x"C9" | x"CA" | x"CB" |  -- EOR opr16a, ADC opr16a, ORA opr16a, ADD opr16a
                   x"CE" |                          -- LDX opr16a
                   x"D0" | x"D1" | x"D2" | x"D3" |  -- SUB oprx16,X, CMP oprx16,X, SBC oprx16,X, CPX oprx16,X
                   x"D4" | x"D5" | x"D6" |          -- AND oprx16,X, BIT oprx16,X, LDA oprx16,X
                   x"D8" | x"D9" | x"DA" | x"DB" |  -- EOR oprx16,X, ADC oprx16,X, ORA oprx16,X, ADD oprx16,X
                   x"DE" |                          -- LDX oprx16,X
                   x"E0" | x"E1" | x"E2" | x"E3" |  -- SUB oprx8,X, CMP oprx8,X, SBC oprx8,X, CPX oprx8,X
                   x"E4" | x"E5" | x"E6" |          -- AND oprx8,X, BIT oprx8,X, LDA oprx8,X
                   x"E8" | x"E9" | x"EA" | x"EB" |  -- EOR oprx8,X, ADC oprx8,X, ORA oprx8,X, ADD oprx8,X
                   x"EE" =>                         -- LDX oprx8,X
                temp(7 downto 0) <= datain;
                case opcode(7 downto 4) is
                  when x"C" =>
                    addrMux <= addrTM;
                  when x"D" =>
                    if escape9E = '0' then
                      addrMux <= addrX2;
                    else
                      escape9E <= '0';
                      addrMux <= addrS2;
                    end if;                  
                  when x"E" =>
                    if escape9E = '0' then
                      addrMux <= addrX1;
                    else
                      escape9E <= '0';
                      addrMux <= addrS1;
                    end if;                  
                  when others =>
                    null;
                end case;
                regPC <= regPC + 1;
                mainFSM <= "0101"; 
              when x"CC" =>  -- JMP opr16a
                regPC <= temp(15 downto 8) & datain;
                mainFSM <= "0010";   
              when x"DC" =>  -- JMP oprx16,X
                regPC <= (temp(15 downto 8) & datain) + regHX;
                mainFSM <= "0010";   
              when x"EC" =>  -- JMP oprx8,X
                regPC <= (x"00" & datain) + regHX;
                mainFSM <= "0010";   
              when x"C7" =>  -- STA opr16a
                wr <= CPUwrite;
                flagV <= '0';
                flagN <= regA(7);
                if regA = x"00" then
                  flagZ <= '1';
                else
                  flagZ <= '0';
                end if;
                dataMux <= outA;
                temp(7 downto 0) <= datain;
                addrMux <= addrTM;
                regPC <= regPC + 1;
                mainFSM <= "0101"; 
              when x"D7" =>  -- STA oprx16,X
                wr <= CPUwrite;
                flagV <= '0';
                flagN <= regA(7);
                if regA = x"00" then
                  flagZ <= '1';
                else
                  flagZ <= '0';
                end if;
                dataMux <= outA;
                temp(7 downto 0) <= datain;
                if escape9E = '0' then
                  addrMux <= addrX2;
                else
                  escape9E <= '0';
                  addrMux <= addrS2;
                end if;
                regPC <= regPC + 1;
                mainFSM <= "0101"; 
              when x"E7" =>  -- STA oprx8,X
                wr <= CPUwrite;
                flagV <= '0';
                flagN <= regA(7);
                if regA = x"00" then
                  flagZ <= '1';
                else
                  flagZ <= '0';
                end if;
                dataMux <= outA;
                temp(7 downto 0) <= datain;
                if escape9E = '0' then
                  addrMux <= addrX1;
                else
                  escape9E <= '0';
                  addrMux <= addrS1;
                end if;
                regPC <= regPC + 1;
                mainFSM <= "0101"; 
              when x"CF" =>  -- STX opr16a
                wr <= CPUwrite;
                flagV <= '0';
                flagN <= regHX(7);
                if regHX(7 downto 0) = x"00" then
                  flagZ <= '1';
                else
                  flagZ <= '0';
                end if;
                dataMux <= outX;
                temp(7 downto 0) <= datain;
                addrMux <= addrTM;
                regPC <= regPC + 1;
                mainFSM <= "0101"; 
              when x"DF" =>  -- STX oprx16,X
                wr <= CPUwrite;
                flagV <= '0';
                flagN <= regHX(7);
                if regHX(7 downto 0) = x"00" then
                  flagZ <= '1';
                else
                  flagZ <= '0';
                end if;
                dataMux <= outX;
                temp(7 downto 0) <= datain;
                if escape9E = '0' then
                  addrMux <= addrX2;
                else
                  escape9E <= '0';
                  addrMux <= addrS2;
                end if;
                regPC <= regPC + 1;
                mainFSM <= "0101"; 
              when x"EF" =>  -- STX oprx8,X
                wr <= CPUwrite;
                flagV <= '0';
                flagN <= regHX(7);
                if regHX(7 downto 0) = x"00" then
                  flagZ <= '1';
                else
                  flagZ <= '0';
                end if;
                dataMux <= outX;
                temp(7 downto 0) <= datain;
                if escape9E = '0' then
                  addrMux <= addrX1;
                else
                  escape9E <= '0';
                  addrMux <= addrS1;
                end if;
                regPC <= regPC + 1;
                mainFSM <= "0101"; 
              when x"30" | x"60" | x"70" =>  -- NEG opr8a, NEG oprx8,X, NEG ,X
                wr      <= CPUwrite;
                dataMux <= outHelp;
                help    <= x"00" - datain;
                tres    := x"00" - datain;
                flagV   <= tres(7) and datain(7);
                flagN   <= tres(7);
                if tres = x"00" then
                  flagZ <= '1';
                  flagC <= '0';
                else
                  flagC <= '1';
                  flagZ <= '0';
                end if;
                mainFSM <= "0101";
              when x"31" =>  -- CBEQ opr8a,rel
                help    <= datain;
                addrMux <= addrPC;
                mainFSM <= "0101";
              when x"33" | x"63" | x"73" =>  -- COM opr8a, COM oprx8,X, COM ,X
                wr      <= CPUwrite;
                dataMux <= outHelp;
                help    <= datain xor x"FF";
                tres    := datain xor x"FF";
                flagV   <= '0';
                flagC   <= '1';
                flagN   <= tres(7);
                if tres = x"00" then
                  flagZ <= '1';
                else
                  flagZ <= '0';
                end if;
                mainFSM <= "0101";
              when x"34" | x"64" | x"74" =>  -- LSR opr8a, LSR oprx8,X, LSR ,X
                wr      <= CPUwrite;
                dataMux <= outHelp;
                help    <= "0" & datain(7 downto 1);
                tres    := "0" & datain(7 downto 1);
                flagV   <= datain(0);
                flagN   <= '0';
                flagC   <= datain(0);
                if tres = x"00" then
                  flagZ <= '1';
                else
                  flagZ <= '0';
                end if;
                mainFSM <= "0101";
              when x"35" =>  -- STHX opr8a
                dataMux <= outX;
                temp <= temp + 1;
                mainFSM <= "0101";
              when x"36" | x"66" | x"76" =>  -- ROR opr8a, ROR oprx8,X, ROR ,X
                wr      <= CPUwrite;
                dataMux <= outHelp;
                help    <= flagC & datain(7 downto 1);
                tres    := flagC & datain(7 downto 1);
                flagN   <= flagC;
                flagC   <= datain(0);
                flagV   <= flagC xor datain(0);
                if tres = x"00" then
                  flagZ <= '1';
                else
                  flagZ <= '0';
                end if;
                mainFSM <= "0101";
              when x"37" | x"67" | x"77" =>  -- ASR opr8a, ASR oprx8,X, ASR ,X
                wr      <= CPUwrite;
                dataMux <= outHelp;
                help    <= datain(7) & datain(7 downto 1);
                tres    := datain(7) & datain(7 downto 1);
                flagN   <= datain(7);
                flagC   <= datain(0);
                flagV   <= datain(7) xor datain(0);
                if tres = x"00" then
                  flagZ <= '1';
                else
                  flagZ <= '0';
                end if;
                mainFSM <= "0101";
              when x"38" | x"68" | x"78" =>  -- LSL opr8a, LSL oprx8,X, LSL ,X
                wr      <= CPUwrite;
                dataMux <= outHelp;
                help    <= datain(6 downto 0) & "0";
                tres    := datain(6 downto 0) & "0";
                flagN   <= datain(6);
                flagC   <= datain(7);
                flagV   <= datain(7) xor datain(6);
                if tres = x"00" then
                  flagZ <= '1';
                else
                  flagZ <= '0';
                end if;
                mainFSM <= "0101";
              when x"39" | x"69" | x"79" =>  -- ROL opr8a, ROL oprx8,X, ROL ,X
                wr      <= CPUwrite;
                dataMux <= outHelp;
                help    <= datain(6 downto 0) & flagC;
                tres    := datain(6 downto 0) & flagC;
                flagN   <= datain(6);
                flagC   <= datain(7);
                flagV   <= datain(7) xor datain(6);
                if tres = x"00" then
                  flagZ <= '1';
                else
                  flagZ <= '0';
                end if;
                mainFSM <= "0101";
              when x"3A" | x"6A" | x"7A" =>  -- DEC opr8a, DEC oprx8,X, DEC ,X
                wr      <= CPUwrite;
                dataMux <= outHelp;
                help    <= datain - 1;
                tres    := datain - 1;
                flagN   <= tres(7);
                if datain = x"80" then
                  flagV <= '1';
                else
                  flagV <= '0';
                end if;
                if tres = x"00" then
                  flagZ <= '1';
                else
                  flagZ <= '0';
                end if;
                mainFSM <= "0101";
              when x"3B" | x"6B" | x"7B" =>  -- DBNZ opr8a,rel, DBNZ oprx8,X,rel, DBNZ ,X,rel
                wr      <= CPUwrite;
                dataMux <= outHelp;
                help    <= datain - 1;
                mainFSM <= "0101";
              when x"3C" | x"6C" | x"7C" =>  -- INC opr8a, INC oprx8,X, INC ,X
                wr      <= CPUwrite;
                dataMux <= outHelp;
                help    <= datain + 1;
                tres    := datain + 1;
                flagN   <= tres(7);
                if datain = x"7F" then
                  flagV <= '1';
                else
                  flagV <= '0';
                end if;
                if tres = x"00" then
                  flagZ <= '1';
                else
                  flagZ <= '0';
                end if;
                mainFSM <= "0101";
              when x"3D" | x"6D" | x"7D" =>  -- TST opr8a, TST oprx8,X, TST ,X
                flagV   <= '0';
                flagN   <= datain(7);
                if datain = x"00" then
                  flagZ <= '1';
                else
                  flagZ <= '0';
                end if;
                addrMux <= addrPC;
                mainFSM <= "0010";
              when x"3F" | x"6F" =>  -- CLR opr8a, CLR oprx8,X
                wr <= CPUread;
                addrMux <= addrPC;
                mainFSM <= "0010";
              when x"41" =>  -- CBEQA #opr8i,rel
                if datain(7) = '0' then
                  regPC <= regPC + (x"00" & datain) + x"0001";
                else
                  regPC <= regPC + (x"FF" & datain) + x"0001";
                end if;
                mainFSM <= "0010";
              when x"45" =>  -- LDHX #opr
                regHX(7 downto 0) <= datain;
                if regHX(15 downto 8) = x"00" and datain = x"00" then
                  flagZ <= '1';
                else
                  flagZ <= '0';
                end if;
                regPC <= regPC + 1;
                mainFSM <= "0010";
              when x"4E" =>  -- MOV opr8a,opr8a
                help    <= datain;
                flagV   <= '0';
                flagN   <= datain(7);
                if datain = x"00" then
                  flagZ <= '1';
                else
                  flagZ <= '0';
                end if;
                addrMux <= addrPC;
                mainFSM <= "0101";
              when x"55" =>  -- LDHX opr
                regHX(15 downto 8) <= datain;
                temp <= temp + 1;
                mainFSM <= "0101";
              when x"5E" =>  -- MOV opr8a,X+
                help  <= datain;
                flagV <= '0';
                flagN <= datain(7);
                if datain = x"00" then
                  flagZ <= '1';
                else
                  flagZ <= '0';
                end if;
                dataMux <= outHelp;
                addrMux <= addrHX;
                wr      <= CPUwrite;
                mainFSM <= "0101";
              when x"61" =>  -- CBEQ oprx8,X+,rel
                if escape9E = '0' then
                  regHX   <= regHX + 1;
                else
                  escape9E <= '0';
                end if;
                addrMux <= addrPC;
                if datain = regA then
                  mainFSM <= "0101";
                else
                  regPC <= regPC + 2;
                  mainFSM <= "0010";
                end if;
              when x"65" =>  -- CPHX #opr
                lres := regHX - (help & datain);
                flagN <= lres(15);
                if lres = x"0000" then
                  flagZ <= '1';
                else
                  flagZ <= '0';
                end if;
                flagV <= (regHX(15) and (not help(7)) and (not lres(15))) or
                         ((not regHX(15)) and help(7) and lres(15));
                flagC <= ((not regHX(15)) and help(7)) or
                         (help(7) and lres(15)) or
                         (lres(15) and (not help(7)));
                regPC <= regPC + 1;
                mainFSM <= "0010";
              when x"6E" =>  -- MOV #opr8i,opr8a
                temp(7 downto 0) <= datain;
                flagV <= '0';
                flagN <= help(7);
                if help = x"00" then
                  flagZ <= '1';
                else
                  flagZ <= '0';
                end if;
                wr      <= CPUwrite;
                dataMux <= outHelp;
                addrMux <= addrTM;
                regPC   <= regPC + 1;
                mainFSM <= "0101";
              when x"71" =>  -- CBEQ ,X+,rel
                addrMux <= addrPC;
                regHX <= regHX + 1;
                if datain = regA then
                  mainFSM <= "0101";
                else
                  regPC <= regPC + 2;
                  mainFSM <= "0010";
                end if;
              when x"75" =>  -- CPHX opr
                help <= datain;
                temp <= temp + 1;
                mainFSM <= "0101";
              when x"7E" =>  -- MOV ,X+,opr8a
                help <= datain;
                temp <= x"0000";
                addrMux <= addrPC;
                mainFSM <= "0101";
              when x"80" | x"82" =>  -- RTI, RTT
                regA  <= datain;
                regSP <= regSP + 1;
                mainFSM <= "0101";
              when x"81" =>  -- RTS
                regPC(7 downto 0) <= datain;
                addrMux <= addrPC;
                mainFSM <= "0010";
              when x"83" =>  -- SWI
                regSP <= regSP - 1;
                dataMux <= outPCH;
                mainFSM <= "0101";
              when x"AD" | x"BD" | x"ED" =>  -- BSR rel, JSR opr8a, JSR oprx8,X
                regSP <= regSP - 1;
                dataMux <= outPCH;
                mainFSM <= "0101";
              when x"FD" =>  -- JSR ,X
                regSP <= regSP - 1;
                dataMux <= outTH;
                mainFSM <= "0101";
              when x"CD" | x"DD" =>  -- JSR opr16a, JSR oprx16,X
                wr   <= CPUwrite;
                temp(7 downto 0) <= datain;
                regPC   <= regPC + 1;
                addrMux <= addrSP;
                dataMux <= outPCL;
                mainFSM <= "0101";
                
              when others =>
                mainFSM <= "0000";
            end case; -- opcode
            
          when "0101" => --##################### instruction cycle 4
            case opcode is
              when x"00" | x"02" | x"04" | x"06" | x"08" | x"0A" | x"0C" | x"0E" |   -- BRSET n,opr8a,rel
                   x"01" | x"03" | x"05" | x"07" | x"09" | x"0B" | x"0D" | x"0F" =>  -- BRCLR n,opr8a,rel
                if (opcode(0) xor flagC) = '1' then
                  if datain(7) = '0' then
                    regPC <= regPC + (x"00" & datain) + x"0001";
                  else
                    regPC <= regPC + (x"FF" & datain) + x"0001";
                  end if;
                else
                  regPC <= regPC + 1;
                end if;
                addrMux <= addrPC;
                mainFSM <= "0010";
              when x"10" | x"12" | x"14" | x"16" | x"18" | x"1A" | x"1C" | x"1E" |   -- BSET n,opr8a
                   x"11" | x"13" | x"15" | x"17" | x"19" | x"1B" | x"1D" | x"1F" |   -- BCLR n,opr8a
                   x"30" | x"33" | x"34" | x"35" | x"36" |  -- NEG opr8a, COM opr8a, LSR opr8a, STHX opr8a, ROR opr8a
                   x"37" | x"38" | x"39" | x"3A" | x"3C" |  -- ASR opr8a, LSL opr8a, ROL opr8a, DEC opr8a, INC opr8a
                   x"60" | x"63" | x"64" | x"66" | x"67" |  -- NEG oprx8,X, COM oprx8,X, LSR oprx8,X, ROR oprx8,X, ASR oprx8,X
                   x"68" | x"69" | x"6A" | x"6C" | x"6E" |  -- LSL oprx8,X, ROL oprx8,X, DEC oprx8,X, INC oprx8,X, MOV #opr8i,opr8a
                   x"70" | x"73" | x"74" | x"76" | x"77" | x"78" | x"79" | -- NEG ,X, COM ,X, LSR ,X, ROR ,X, ASR ,X, LSL ,X, ROL ,X
                   x"7A" | x"7C" |   -- DEC ,X, INC ,X
                   x"B7" | x"BF" | x"C7" | x"CF" |  -- STA opr8a, STX opr8a, STA opr16a, STX opr16a
                   x"D7" | x"DF" | x"E7" | x"EF" |  -- STA oprx16,X, STX oprx16,X, STA oprx8,X, STX oprx8,X
                   x"F7" | x"FF" =>  -- STA ,X, STX ,X
                wr      <= CPUread;
                addrMux <= addrPC;
                mainFSM <= "0010";
              when x"31" =>  -- CBEQ opr8a,rel
                if regA = help then
                  if datain(7) = '0' then
                    regPC <= regPC + (x"00" & datain) + x"0001";
                  else
                    regPC <= regPC + (x"FF" & datain) + x"0001";
                  end if;
                else
                  regPC <= regPC + 1;
                end if;
                mainFSM <= "0010";
              when x"3B" | x"6B" | x"7B" =>  -- DBNZ opr8a,rel, DBNZ oprx8,X,rel, DBNZ ,X,rel
                wr      <= CPUread;
                addrMux <= addrPC;
                mainFSM <= "0110";
              when x"4E" =>  -- MOV opr8a,opr8a
                temp(7 downto 0) <= datain;
                regPC <= regPC + 1;
                wr <= CPUwrite;
                addrMux <= addrTM;
                dataMux <= outHelp;
                mainFSM <= "0110";
              when x"55" =>  -- LDHX opr
                regHX(7 downto 0) <= datain;
                flagV <= '0';
                flagN <= regHX(15);
                if (datain = x"00") and (regHX(15 downto 8) = x"00") then
                  flagZ <= '1';
                else
                  flagZ <= '0';
                end if;
                addrMux <= addrPC;
                mainFSM <= "0010";
              when x"5E" =>  -- MOV opr8a,X+
                wr      <= CPUread;
                addrMux <= addrPC;
                regHX   <= regHX + 1;
                mainFSM <= "0010";
              when x"61" | x"71" =>  -- CBEQ oprx8,X+,rel, CBEQ ,X+,rel
                if datain(7) = '0' then
                  regPC <= regPC + (x"00" & datain) + x"0001";
                else
                  regPC <= regPC + (x"FF" & datain) + x"0001";
                end if;                
                mainFSM <= "0010";
              when x"75" =>  -- CPHX opr
                lres := regHX - (help & datain);
                flagN <= lres(15);
                if lres = x"0000" then
                  flagZ <= '1';
                else
                  flagZ <= '0';
                end if;
                flagV <= (regHX(15) and (not help(7)) and (not lres(15))) or
                         ((not regHX(15)) and help(7) and lres(15));
                flagC <= ((not regHX(15)) and help(7)) or
                         (help(7) and lres(15)) or
                         (lres(15) and (not help(7)));
                addrMux <= addrPC;
                mainFSM <= "0010";
              when x"7E" =>  -- MOV ,X+,opr8a
                flagV <= '0';
                flagN <= help(7);
                if help = x"00" then
                  flagZ <= '1';
                else
                  flagZ <= '0';
                end if;
                temp(7 downto 0) <= datain;
                wr <= CPUwrite;
                dataMux <= outHelp;
                addrMux <= addrTM;
                regPC   <= regPC + 1;
                regHX   <= regHX + 1;
                mainFSM <= "0110";
              when x"80" | x"82" =>  -- RTI, RTT
                regHX(7 downto 0) <= datain;
                regSP <= regSP + 1;
                mainFSM <= "0110";
              when x"83" =>  -- SWI
                regSP <= regSP - 1;
                dataMux <= outX;
                help(7) <= flagV;
                help(6) <= '1';
                help(5) <= '1';
                help(4) <= flagH;
                help(3) <= flagI;
                help(2) <= flagN;
                help(1) <= flagZ;
                help(0) <= flagC;
                mainFSM <= "0110";
              when x"A0" | x"B0" | x"C0" | x"D0" | x"E0" | x"F0" =>  -- SUB #opr8i, SUB opr8a, SUB opr16a, SUB oprx16,X, SUB oprx8,X, SUB ,X
                addrMux <= addrPC;
                regA <= regA - datain;
                tres := regA - datain;
                flagN <= tres(7);
                if tres = x"00" then
                  flagZ <= '1';
                else
                  flagZ <= '0';
                end if;
                flagV <= (regA(7) and (not datain(7)) and (not tres(7))) or
                         ((not regA(7)) and datain(7) and tres(7));
                flagC <= ((not regA(7)) and datain(7)) or
                         (datain(7) and tres(7)) or
                         (tres(7) and (not regA(7)));
                if opcode = x"A0" then
                  regPC <= regPC + 1;
                end if;
                mainFSM <= "0010";
              when x"A1" | x"B1" | x"C1" | x"D1" | x"E1" | x"F1" =>  -- CMP #opr8i, CMP opr8a, CMP opr16a, CMP oprx16,X, CMP oprx8,X, CMP ,X
                addrMux <= addrPC;
                tres := regA - datain;
                flagN <= tres(7);
                if tres = x"00" then
                  flagZ <= '1';
                else
                  flagZ <= '0';
                end if;
                flagV <= (regA(7) and (not datain(7)) and (not tres(7))) or
                         ((not regA(7)) and datain(7) and tres(7));
                flagC <= ((not regA(7)) and datain(7)) or
                         (datain(7) and tres(7)) or
                         (tres(7) and (not regA(7)));
                if opcode = x"A1" then
                  regPC <= regPC + 1;
                end if;
                mainFSM <= "0010";
              when x"A2" | x"B2" | x"C2" | x"D2" | x"E2" | x"F2" =>  -- SBC #opr8i, SBC opr8a, SBC opr16a, SBC oprx16,X, SBC oprx8,X, SBC ,X
                addrMux <= addrPC;
                regA <= regA - datain - ("0000000" & flagC);
                tres := regA - datain - ("0000000" & flagC);
                flagN <= tres(7);
                if tres = x"00" then
                  flagZ <= '1';
                else
                  flagZ <= '0';
                end if;
                flagV <= (regA(7) and (not datain(7)) and (not tres(7))) or
                         ((not regA(7)) and datain(7) and tres(7));
                flagC <= ((not regA(7)) and datain(7)) or
                         (datain(7) and tres(7)) or
                         (tres(7) and (not regA(7)));
                if opcode = x"A2" then
                  regPC <= regPC + 1;
                end if;
                mainFSM <= "0010";
              when x"A3" | x"B3" | x"C3" | x"D3" | x"E3" | x"F3" =>  -- CPX #opr8i, CPX opr8a, CPX opr16a, CPX oprx16,X, CPX oprx8,X, CPX ,X
                addrMux <= addrPC;
                tres := regHX(7 downto 0) - datain;
                flagN <= tres(7);
                if tres = x"00" then
                  flagZ <= '1';
                else
                  flagZ <= '0';
                end if;
                flagV <= (regHX(7) and (not datain(7)) and (not tres(7))) or
                         ((not regHX(7)) and datain(7) and tres(7));
                flagC <= ((not regHX(7)) and datain(7)) or
                         (datain(7) and tres(7)) or
                         (tres(7) and (not regHX(7)));
                if opcode = x"A3" then
                  regPC <= regPC + 1;
                end if;
                mainFSM <= "0010";
              when x"A4" | x"B4" | x"C4" | x"D4" | x"E4" | x"F4" =>  -- AND #opr8i, AND opr8a, AND opr16a, AND oprx16,X, AND oprx8,X, AND ,X
                addrMux <= addrPC;
                regA <= regA and datain;
                tres := regA and datain;
                flagN <= tres(7);
                if tres = x"00" then
                  flagZ <= '1';
                else
                  flagZ <= '0';
                end if;
                flagV <= '0';
                if opcode = x"A4" then
                  regPC <= regPC + 1;
                end if;
                mainFSM <= "0010";
              when x"A5" | x"B5" | x"C5" | x"D5" | x"E5" | x"F5" =>  -- BIT #opr8i, BIT opr8a, BIT opr16a, BIT oprx16,X, BIT oprx8,X, BIT ,X
                addrMux <= addrPC;
                tres := regA and datain;
                flagN <= tres(7);
                if tres = x"00" then
                  flagZ <= '1';
                else
                  flagZ <= '0';
                end if;
                flagV <= '0';
                if opcode = x"A5" then
                  regPC <= regPC + 1;
                end if;
                mainFSM <= "0010";
              when x"A6" | x"B6" | x"C6" | x"D6" | x"E6" | x"F6" =>  -- LDA #opr8i, LDA opr8a, LDA opr16a, LDA oprx16,X, LDA oprx8,X, LDA ,X
                addrMux <= addrPC;
                regA <= datain;
                flagN <= datain(7);
                if datain = x"00" then
                  flagZ <= '1';
                else
                  flagZ <= '0';
                end if;
                flagV <= '0';
                if opcode = x"A6" then
                  regPC <= regPC + 1;
                end if;
                mainFSM <= "0010";
              when x"A7" =>  -- AIS
                if datain(7) = '0' then
                  regSP <= regSP + (x"00" & datain);
                else
                  regSP <= regSP + (x"FF" & datain);
                end if;
                regPC <= regPC + 1;
                mainFSM <= "0010";
              when x"A8" | x"B8" | x"C8" | x"D8" | x"E8" | x"F8" =>  -- EOR #opr8i, EOR opr8a, EOR opr16a, EOR oprx16,X, EOR oprx8,X, EOR ,X
                addrMux <= addrPC;
                regA <= regA xor datain;
                tres := regA xor datain;
                flagN <= tres(7);
                if tres = x"00" then
                  flagZ <= '1';
                else
                  flagZ <= '0';
                end if;
                flagV <= '0';
                if opcode = x"A8" then
                  regPC <= regPC + 1;
                end if;
                mainFSM <= "0010";
              when x"A9" | x"B9" | x"C9" | x"D9" | x"E9" | x"F9" =>  -- ADC #opr8i, ADC opr8a, ADC opr16a, ADC oprx16,X, ADC oprx8,X, ADC ,X
                addrMux <= addrPC;
                regA <= regA + datain + ("0000000" & flagC);
                tres := regA + datain + ("0000000" & flagC);
                flagN <= tres(7);
                if tres = x"00" then
                  flagZ <= '1';
                else
                  flagZ <= '0';
                end if;
                flagH <= (regA(3) and datain(3)) or
                         (datain(3) and (not tres(3))) or
                         ((not tres(3)) and regA(3));
                flagV <= (regA(7) and datain(7) and (not tres(7))) or
                         ((not regA(7)) and (not datain(7)) and tres(7));
                flagC <= (regA(7) and datain(7)) or
                         (datain(7) and (not tres(7))) or
                         ((not tres(7)) and regA(7));
                if opcode = x"A9" then
                  regPC <= regPC + 1;
                end if;
                mainFSM <= "0010";
              when x"AA" | x"BA" | x"CA" | x"DA" | x"EA" | x"FA" =>  -- ORA #opr8i, ORA opr8a, ORA opr16a, ORA oprx16,X, ORA oprx8,X, ORA ,X
                addrMux <= addrPC;
                regA <= regA or datain;
                tres := regA or datain;
                flagN <= tres(7);
                if tres = x"00" then
                  flagZ <= '1';
                else
                  flagZ <= '0';
                end if;
                flagV <= '0';
                if opcode = x"AA" then
                  regPC <= regPC + 1;
                end if;
                mainFSM <= "0010";
              when x"AB" | x"BB" | x"CB" | x"DB" | x"EB" | x"FB" =>  -- ADD #opr8i, ADD opr8a, ADD opr16a, ADD oprx16,X, ADD oprx8,X, ADD ,X
                addrMux <= addrPC;
                regA <= regA + datain;
                tres := regA + datain;
                flagN <= tres(7);
                if tres = x"00" then
                  flagZ <= '1';
                else
                  flagZ <= '0';
                end if;
                flagH <= (regA(3) and datain(3)) or
                         (datain(3) and (not tres(3))) or
                         ((not tres(3)) and regA(3));
                flagV <= (regA(7) and datain(7) and (not tres(7))) or
                         ((not regA(7)) and (not datain(7)) and tres(7));
                flagC <= (regA(7) and datain(7)) or
                         (datain(7) and (not tres(7))) or
                         ((not tres(7)) and regA(7));
                if opcode = x"AB" then
                  regPC <= regPC + 1;
                end if;
                mainFSM <= "0010";
              when x"AE" | x"BE" | x"CE" | x"DE" | x"EE" | x"FE" =>  -- LDX #opr8i, LDX opr8a, LDX opr16a, LDX oprx16,X, LDX oprx8,X, LDX ,X
                addrMux <= addrPC;
                regHX(7 downto 0) <= datain;
                flagN <= datain(7);
                if datain = x"00" then
                  flagZ <= '1';
                else
                  flagZ <= '0';
                end if;
                flagV <= '0';
                if opcode = x"AE" then
                  regPC <= regPC + 1;
                end if;
                mainFSM <= "0010";
              when x"AF" =>  -- AIX
                if datain(7) = '0' then
                  regHX <= regHX + (x"00" & datain);
                else
                  regHX <= regHX + (x"FF" & datain);
                end if;
                regPC <= regPC + 1;
                mainFSM <= "0010";
              when x"AD" =>  -- BSR rel
                wr <= CPUread;
                addrMux <= addrPC;
                if help(7) = '0' then
                  regPC <= regPC + (x"00" & help);
                else
                  regPC <= regPC + (x"FF" & help);
                end if;
                regSP <= regSP - 1;
                mainFSM <= "0010";
              when x"BD" =>  -- JSR opr8a
                wr <= CPUread;
                addrMux <= addrPC;
                regPC <= x"00" & help;
                regSP <= regSP - 1;
                mainFSM <= "0010";
              when x"CD" | x"DD" =>  -- JSR opr16a, JSR oprx16,X
                regSP <= regSP - 1;
                dataMux <= outPCH;
                mainFSM <= "0110";
              when x"ED" =>  -- JSR oprx8,X
                wr <= CPUread;
                addrMux <= addrPC;
                regPC <= (x"00" & help) + regHX;
                regSP <= regSP - 1;
                mainFSM <= "0010";
              when x"FD" =>  -- JSR ,X
                wr <= CPUread;
                addrMux <= addrPC;
                regPC <= regHX;
                regSP <= regSP - 1;
                mainFSM <= "0010";
                
              when others =>
                mainFSM <= "0000";
            end case; -- opcode
          
          when "0110" => --##################### instruction cycle 5
            case opcode is
              when x"3B" | x"6B" | x"7B" => -- DBNZ opr8a,rel, DBNZ oprx8,X,rel, DBNZ ,X,rel
                if help = x"00" then
                  regPC <= regPC + 1;
                else
                  if datain(7) = '0' then
                    regPC <= regPC + (x"00" & datain) + x"0001";
                  else
                    regPC <= regPC + (x"FF" & datain) + x"0001";
                  end if;
                end if;
                mainFSM <= "0010";
              when x"4E" | x"7E" =>  -- MOV opr8a,opr8a, MOV ,X+,opr8a
                wr <= CPUread;
                addrMux <= addrPC;
                mainFSM <= "0010";
              when x"80" | x"82" =>  -- RTI, RTT
                regPC(15 downto 8) <= datain;
                regSP <= regSP + 1;
                mainFSM <= "0111";
              when x"83" =>  -- SWI
                regSP <= regSP - 1;
                dataMux <= outA;
                mainFSM <= "0111";
              when x"CD" =>  -- JSR opr16a
                wr <= CPUread;
                addrMUX <= addrPC;
                regSP <= regSP - 1;
                regPC <= temp;
                mainFSM <= "0010";
              when x"DD" =>  -- JSR oprx16,X
                wr <= CPUread;
                addrMUX <= addrPC;
                regSP <= regSP - 1;
                regPC <= temp + regHX;
                mainFSM <= "0010";
            
              when others =>
                mainFSM <= "0000";
            end case; -- opcode
          
          when "0111" => --##################### instruction cycle 6
            case opcode is
              when x"80" | x"82" =>  -- RTI, RTT
                regPC(7 downto 0) <= datain;
                addrMux <= addrPC;
                mainFSM <= "0010";
              when x"83" =>  -- SWI
                regSP   <= regSP - 1;
                dataMux <= outHelp;
                flagI   <= '1';
                if trace = '0' then
                  if irqRequest = '0' then
                    temp    <= x"FFFC"; -- SWI vector
                  else
                    irqRequest <= '0';
                    temp    <= x"FFFA"; -- IRQ vector
                  end if;
                  mainFSM <= "1000";
                else
                  temp    <= x"FFF8"; -- trace vector
                  mainFSM <= "1011";
                end if;
              
              when others =>
                mainFSM <= "0000";
            end case; -- opcode
          when "1000" => --##################### instruction cycle 7
            case opcode is
              when x"83" =>  -- SWI
                wr <= CPUread;
                addrMux <= addrTM;
                regSP   <= regSP - 1;
                mainFSM <= "1001";
              
              when others =>
                mainFSM <= "0000";
            end case;
          when "1001" => --##################### instruction cycle 8
            case opcode is
              when x"83" =>  -- SWI
                regPC(15 downto 8) <= datain;
                temp <= temp + 1;
                mainFSM <= "1010";
              
              when others =>
                mainFSM <= "0000";
            end case;
          when "1010" => --##################### instruction cycle 9
            case opcode is
              when x"83" =>  -- SWI
                regPC(7 downto 0) <= datain;
                addrMux <= addrPC;
                mainFSM <= "0010";
              
              when others =>
                mainFSM <= "0000";
            end case;
          when "1011" => --##################### instruction cycle 6a, trace
            regSP   <= regSP - 1;
            dataMux <= outCode;
            trace   <= '0';
            trace_i <= '0';
            mainFSM <= "1000";
            
          when others =>
            mainFSM <= "0000";
        end case; -- mainFSM
      end if;
    end if;
  end process;
  
end behavior;
