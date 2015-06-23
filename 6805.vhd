-----------------------------------------------------------------------------------
--  68HC05 microcontroller implementation
--  Ulrich Riedel
--  v1.0  2006.01.21  first version
-----------------------------------------------------------------------------------
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
-- begin of 6805
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.all;

ENTITY UR6805 IS
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
END UR6805;

ARCHITECTURE behavior OF UR6805 IS

  component mul8 port(
    a    : in  std_logic_vector(7 downto 0);
    b    : in  std_logic_vector(7 downto 0);
    prod : out std_logic_vector(15 downto 0)
    );
  end component mul8;
  
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
  signal regX   : std_logic_vector(7 downto 0);
  signal regSP  : std_logic_vector(15 downto 0);
  signal regPC  : std_logic_vector(15 downto 0);
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
  signal prod     : std_logic_vector(15 downto 0);
  signal irq_d      : std_logic;
  signal irqRequest : std_logic;

  signal trace       : std_logic;
  signal trace_i     : std_logic;
  signal traceOpCode : std_logic_vector(7 downto 0);
  
begin

  mul: mul8 port map(
    a    => regA,
    b    => regX,
    prod => prod
  );
  
  addr <= regPC          when addrMux = addrPC else
          regSP          when addrMux = addrSP else
          x"00" & regX   when addrMux = addrHX else
          temp           when addrMux = addrTM else
          ((x"00" & regX) + temp) when addrMux = addrX2 else
          (regSP + temp) when addrMux = addrS2 else
          ((x"00" & regX) + (x"00" & temp(7 downto 0))) when addrMux = addrX1 else
          (regSP + (x"00" & temp(7 downto 0)));
  dataout <= regA               when dataMux = outA else
             regX               when dataMux = outH else
             regX               when dataMux = outX else
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
      flagH <= '0';
      flagI <= '1'; -- irq disabled
      flagN <= '0';
      flagZ <= '0';
      flagC <= '0';
      regA    <= x"00";
      regX    <= x"00";
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
        if (irq <= '0') and (irq_d = '1') and (flagI = '0') then -- irq falling edge ?
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
                when x"00" | x"02" | x"04" | x"06" | x"08" | x"0A" | x"0C" | x"0E" |   -- BRSET n,opr8a,rel
                     x"01" | x"03" | x"05" | x"07" | x"09" | x"0B" | x"0D" | x"0F" |   -- BRCLR n,opr8a,rel
                     x"10" | x"12" | x"14" | x"16" | x"18" | x"1A" | x"1C" | x"1E" |   -- BSET n,opr8a
                     x"11" | x"13" | x"15" | x"17" | x"19" | x"1B" | x"1D" | x"1F" |   -- BCLR n,opr8a
                     x"30" | x"33" | x"34" |   -- NEG opr8a, COM opr8a, LSR opr8a
                     x"36" | x"37" | x"38" |   -- ROR opr8a, ASR opr8a, LSL opr8a
                     x"39" | x"3A" | x"3C" |   -- ROL opr8a, DEC opr8a, INC opr8a
                     x"3D" | x"3F" |  -- TST opr8a, CLR opr8a
                     x"B0" | x"B1" | x"B2" | x"B3" |  -- SUB opr8a, CMP opr8a, SBC opr8a, CPX opr8a
                     x"B4" | x"B5" | x"B6" | x"B7" |  -- AND opr8a, BIT opr8a, LDA opr8a, STA opr8a
                     x"B8" | x"B9" | x"BA" | x"BB" |  -- EOR opr8a, ADC opr8a, ORA opr8a, ADD opr8a
                     x"BC" | x"BE" | x"BF" =>         -- JMP opr8a, LDX opr8a, STX opr8a
                  temp    <= x"0000";
                  regPC   <= regPC + 1;
                  mainFSM <= "0011";
                when x"20" | x"21" | x"22" | x"23" | x"24" | x"25" | x"26" | x"27" |
                     x"28" | x"29" | x"2A" | x"2B" | x"2C" | x"2D" | x"2E" | x"2F" |   -- branches
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
                when x"70" | x"73" | x"74" | x"76" | x"77" |  -- NEG ,X, COM ,X, LSR ,X, ROR ,X, ASR ,X
                     x"78" | x"79" | x"7A" | x"7C" | x"7D" =>  -- LSL ,X, ROL ,X, DEC ,X, INC ,X, TXT ,X
                  addrMux <= addrHX;
                  regPC   <= regPC + 1;
                  mainFSM <= "0100";
                when x"A0" | x"A1" | x"A2" | x"A3" |  -- SUB #opr8i, CMP #opr8i, SBC #opr8i, CPX #opr8i
                     x"A4" | x"A5" | x"A6" |  -- AND #opr8i, BIT #opr8i, LDA #opr8i
                     x"A8" | x"A9" | x"AA" | x"AB" |  -- EOR #opr8i, ADC #opr8i, ORA #opr8i, ADD #opr8i
                     x"AE"  =>  -- LDX #opr8i
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
                  regPC <= x"00" & regX;
                  mainFSM <= "0010";
                when x"F7" =>  -- STA ,X
                  wr <= CPUwrite;
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
                  flagN <= regX(7);
                  if regX = x"00" then
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
                  regA  <= prod(7 downto 0);
                  regX  <= prod(15 downto 8);
                  regPC <= regPC + 1;
                  mainFSM <= "0010";
                when x"43" =>  -- COMA
                  regA    <= regA xor x"FF";
                  tres    := regA xor x"FF";
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
                  if tres = x"00" then
                    flagZ <= '1';
                  else
                    flagZ <= '0';
                  end if;
                  regPC <= regPC + 1;
                  mainFSM <= "0010";
                when x"4C" =>  -- INCA
                  regA    <= regA + 1;
                  tres    := regA + 1;
                  flagN   <= tres(7);
                  if tres = x"00" then
                    flagZ <= '1';
                  else
                    flagZ <= '0';
                  end if;
                  regPC <= regPC + 1;
                  mainFSM <= "0010";
                when x"4D" =>  -- TSTA
                  flagN   <= regA(7);
                  if regA = x"00" then
                    flagZ <= '1';
                  else
                    flagZ <= '0';
                  end if;
                  regPC <= regPC + 1;
                  mainFSM <= "0010";
                when x"4F" =>  -- CLRA
                  regA <= x"00";
                  flagN <= '0';
                  flagZ <= '1';
                  regPC <= regPC + 1;
                  mainFSM <= "0010";
                when x"50" =>  -- NEGX
                  regX <= x"00" - regX;
                  tres := x"00" - regX;
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
                when x"53" =>  -- COMX
                  regX <= regX xor x"FF";
                  tres := regX xor x"FF";
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
                  regX <= "0" & regX(7 downto 1);
                  tres := "0" & regX(7 downto 1);
                  flagN   <= '0';
                  flagC   <= regX(0);
                  if tres = x"00" then
                    flagZ <= '1';
                  else
                    flagZ <= '0';
                  end if;
                  regPC <= regPC + 1;
                  mainFSM <= "0010";
                when x"56" =>  -- RORX
                  regX <= flagC & regX(7 downto 1);
                  tres := flagC & regX(7 downto 1);
                  flagN   <= flagC;
                  flagC   <= regX(0);
                  if tres = x"00" then
                    flagZ <= '1';
                  else
                    flagZ <= '0';
                  end if;
                  regPC <= regPC + 1;
                  mainFSM <= "0010";
                when x"57" =>  -- ASRX
                  regX <= regX(7) & regX(7 downto 1);
                  tres := regX(7) & regX(7 downto 1);
                  flagN   <= regX(7);
                  flagC   <= regX(0);
                  if tres = x"00" then
                    flagZ <= '1';
                  else
                    flagZ <= '0';
                  end if;
                  regPC <= regPC + 1;
                  mainFSM <= "0010";
                when x"58" =>  -- LSLX
                  regX <= regX(6 downto 0) & "0";
                  tres := regX(6 downto 0) & "0";
                  flagN   <= regX(6);
                  flagC   <= regX(7);
                  if tres = x"00" then
                    flagZ <= '1';
                  else
                    flagZ <= '0';
                  end if;
                  regPC <= regPC + 1;
                  mainFSM <= "0010";
                when x"59" =>  -- ROLX
                  regX <= regX(6 downto 0) & flagC;
                  tres := regX(6 downto 0) & flagC;
                  flagN   <= regX(6);
                  flagC   <= regX(7);
                  if tres = x"00" then
                    flagZ <= '1';
                  else
                    flagZ <= '0';
                  end if;
                  regPC <= regPC + 1;
                  mainFSM <= "0010";
                when x"5A" =>  -- DECX
                  regX <= regX(7 downto 0) - 1;
                  tres := regX(7 downto 0) - 1;
                  flagN   <= tres(7);
                  if tres = x"00" then
                    flagZ <= '1';
                  else
                    flagZ <= '0';
                  end if;
                  regPC <= regPC + 1;
                  mainFSM <= "0010";
                when x"5C" =>  -- INCX
                  regX <= regX(7 downto 0) + 1;
                  tres := regX(7 downto 0) + 1;
                  flagN   <= tres(7);
                  if tres = x"00" then
                    flagZ <= '1';
                  else
                    flagZ <= '0';
                  end if;
                  regPC <= regPC + 1;
                  mainFSM <= "0010";
                when x"5D" =>  -- TSTX
                  flagN   <= regX(7);
                  if regX = x"00" then
                    flagZ <= '1';
                  else
                    flagZ <= '0';
                  end if;
                  regPC <= regPC + 1;
                  mainFSM <= "0010";
                when x"5F" =>  -- CLRX
                  regX <= x"00";
                  flagN <= '0';
                  flagZ <= '1';
                  regPC <= regPC + 1;
                  mainFSM <= "0010";
                when x"60" | x"63" | x"64" | x"66" | -- NEG oprx8,X, COM oprx8,X, LSR oprx8,X, ROR oprx8,X
                     x"67" | x"68" | x"69" | x"6A" | -- ASR oprx8,X, LSL oprx8,X, ROL oprx8,X, DEC oprx8,X
                     x"6C" | x"6D" | x"6F" =>  -- INC oprx8,X, TST oprx8,X, CLR oprx8,X
                  temp <= x"00" & regX;
                  regPC   <= regPC + 1;
                  mainFSM <= "0011";
                when x"7F" =>  -- CLR ,X
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
                when x"8E" =>  -- STOP currently unsupported
                  regPC   <= regPC + 1;
                  mainFSM <= "0010";
                when x"8F" =>  -- WAIT currently unsupported
                  regPC   <= regPC + 1;
                  mainFSM <= "0010";
                when x"97" =>  -- TAX
                  regX <= regA;
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
                when x"31" | x"41" | x"35" | x"3B" | x"45" |
                     x"4B" | x"4E" | x"51" | x"52" | x"55" |
                     x"5B" | x"5E" | x"61" | x"62" | x"65" |
                     x"6B" | x"6E" | x"71" | x"72" | x"75" | x"7B" | x"7E" |
                     x"84" | x"85" | x"86" | x"87" | x"88" |
                     x"89" | x"8A" | x"8B" | x"8C" | x"8D" |
                     x"90" | x"91" | x"92" | x"93" | x"94" | x"95" | x"9D" | x"9E" |
                     x"A7" | x"AC" | x"AF" =>  -- NOP
                  regPC   <= regPC + 1;
                  mainFSM <= "0010";
                when x"9F" =>  -- TXA
                  regA <= regX;
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
                   x"30" | x"33" | x"34" | x"36" |          -- NEG opr8a, COM opr8a, LSR opr8a, ROR opr8a
                   x"37" | x"38" | x"39" | x"3A" | x"3C" |  -- ASR opr8a, LSL opr8a, ROL opr8a, DEC opr8a, INC opr8a
                   x"3D"  =>         -- TST opr8a
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
              
              when x"20" =>  -- BRA
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
                flagN   <= '0';
                help    <= x"00";
                regPC   <= regPC + 1;
                mainFSM <= "0100";
              when x"60" | x"63" | x"64" | x"66" |  -- NEG oprx8,X, COM oprx8,X, LSR oprx8,X, ROR oprx8,X
                   x"67" | x"68" | x"69" | x"6A" |  -- ASR oprx8,X, LSL oprx8,X, ROL oprx8,X, DEC oprx8,X
                   x"6C" | x"6D" =>  -- INC oprx8,X, TST oprx8,X
                temp    <= temp + (x"00" & datain);
                regPC   <= regPC + 1;
                addrMux <= addrTM;
                mainFSM <= "0100";
              when x"7F" =>  -- CLR ,X
                wr <= CPUread;
                addrMux <= addrPC;
                mainFSM <= "0010";
              when x"80" | x"82" =>  -- RTI, RTT
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
                    addrMux <= addrX2;
                  when x"E" =>
                    addrMux <= addrX1;
                  when others =>
                    null;
                end case;
                regPC <= regPC + 1;
                mainFSM <= "0101"; 
              when x"CC" =>  -- JMP opr16a
                regPC <= temp(15 downto 8) & datain;
                mainFSM <= "0010";   
              when x"DC" =>  -- JMP oprx16,X
                regPC <= (temp(15 downto 8) & datain) + (x"00" & regX);
                mainFSM <= "0010";   
              when x"EC" =>  -- JMP oprx8,X
                regPC <= (x"00" & datain) + (x"00" & regX);
                mainFSM <= "0010";   
              when x"C7" =>  -- STA opr16a
                wr <= CPUwrite;
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
                flagN <= regA(7);
                if regA = x"00" then
                  flagZ <= '1';
                else
                  flagZ <= '0';
                end if;
                dataMux <= outA;
                temp(7 downto 0) <= datain;
                addrMux <= addrX2;
                regPC <= regPC + 1;
                mainFSM <= "0101"; 
              when x"E7" =>  -- STA oprx8,X
                wr <= CPUwrite;
                flagN <= regA(7);
                if regA = x"00" then
                  flagZ <= '1';
                else
                  flagZ <= '0';
                end if;
                dataMux <= outA;
                temp(7 downto 0) <= datain;
                addrMux <= addrX1;
                regPC <= regPC + 1;
                mainFSM <= "0101"; 
              when x"CF" =>  -- STX opr16a
                wr <= CPUwrite;
                flagN <= regX(7);
                if regX = x"00" then
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
                flagN <= regX(7);
                if regX = x"00" then
                  flagZ <= '1';
                else
                  flagZ <= '0';
                end if;
                dataMux <= outX;
                temp(7 downto 0) <= datain;
                addrMux <= addrX2;
                regPC <= regPC + 1;
                mainFSM <= "0101"; 
              when x"EF" =>  -- STX oprx8,X
                wr <= CPUwrite;
                flagN <= regX(7);
                if regX = x"00" then
                  flagZ <= '1';
                else
                  flagZ <= '0';
                end if;
                dataMux <= outX;
                temp(7 downto 0) <= datain;
                addrMux <= addrX1;
                regPC <= regPC + 1;
                mainFSM <= "0101"; 
              when x"30" | x"60" | x"70" =>  -- NEG opr8a, NEG oprx8,X, NEG ,X
                wr      <= CPUwrite;
                dataMux <= outHelp;
                help    <= x"00" - datain;
                tres    := x"00" - datain;
                flagN   <= tres(7);
                if tres = x"00" then
                  flagZ <= '1';
                  flagC <= '0';
                else
                  flagC <= '1';
                  flagZ <= '0';
                end if;
                mainFSM <= "0101";
              when x"33" | x"63" | x"73" =>  -- COM opr8a, COM oprx8,X, COM ,X
                wr      <= CPUwrite;
                dataMux <= outHelp;
                help    <= datain xor x"FF";
                tres    := datain xor x"FF";
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
                flagN   <= '0';
                flagC   <= datain(0);
                if tres = x"00" then
                  flagZ <= '1';
                else
                  flagZ <= '0';
                end if;
                mainFSM <= "0101";
              when x"36" | x"66" | x"76" =>  -- ROR opr8a, ROR oprx8,X, ROR ,X
                wr      <= CPUwrite;
                dataMux <= outHelp;
                help    <= flagC & datain(7 downto 1);
                tres    := flagC & datain(7 downto 1);
                flagN   <= flagC;
                flagC   <= datain(0);
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
                if tres = x"00" then
                  flagZ <= '1';
                else
                  flagZ <= '0';
                end if;
                mainFSM <= "0101";
              when x"3C" | x"6C" | x"7C" =>  -- INC opr8a, INC oprx8,X, INC ,X
                wr      <= CPUwrite;
                dataMux <= outHelp;
                help    <= datain + 1;
                tres    := datain + 1;
                flagN   <= tres(7);
                if tres = x"00" then
                  flagZ <= '1';
                else
                  flagZ <= '0';
                end if;
                mainFSM <= "0101";
              when x"3D" | x"6D" | x"7D" =>  -- TST opr8a, TST oprx8,X, TST ,X
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
                   x"30" | x"33" | x"34" | x"36" |  -- NEG opr8a, COM opr8a, LSR opr8a, ROR opr8a
                   x"37" | x"38" | x"39" | x"3A" | x"3C" |  -- ASR opr8a, LSL opr8a, ROL opr8a, DEC opr8a, INC opr8a
                   x"60" | x"63" | x"64" | x"66" | x"67" |  -- NEG oprx8,X, COM oprx8,X, LSR oprx8,X, ROR oprx8,X, ASR oprx8,X
                   x"68" | x"69" | x"6A" | x"6C" |  -- LSL oprx8,X, ROL oprx8,X, DEC oprx8,X, INC oprx8,X
                   x"70" | x"73" | x"74" | x"76" | x"77" | x"78" | x"79" | -- NEG ,X, COM ,X, LSR ,X, ROR ,X, ASR ,X, LSL ,X, ROL ,X
                   x"7A" | x"7C" |   -- DEC ,X, INC ,X
                   x"B7" | x"BF" | x"C7" | x"CF" |  -- STA opr8a, STX opr8a, STA opr16a, STX opr16a
                   x"D7" | x"DF" | x"E7" | x"EF" |  -- STA oprx16,X, STX oprx16,X, STA oprx8,X, STX oprx8,X
                   x"F7" | x"FF" =>  -- STA ,X, STX ,X
                wr      <= CPUread;
                addrMux <= addrPC;
                mainFSM <= "0010";
              when x"80" | x"82" =>  -- RTI, RTT
                regX  <= datain;
                regSP <= regSP + 1;
                mainFSM <= "0110";
              when x"83" =>  -- SWI
                regSP <= regSP - 1;
                dataMux <= outX;
                help(7) <= '1';
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
                flagC <= ((not regA(7)) and datain(7)) or
                         (datain(7) and tres(7)) or
                         (tres(7) and (not regA(7)));
                if opcode = x"A2" then
                  regPC <= regPC + 1;
                end if;
                mainFSM <= "0010";
              when x"A3" | x"B3" | x"C3" | x"D3" | x"E3" | x"F3" =>  -- CPX #opr8i, CPX opr8a, CPX opr16a, CPX oprx16,X, CPX oprx8,X, CPX ,X
                addrMux <= addrPC;
                tres := regX - datain;
                flagN <= tres(7);
                if tres = x"00" then
                  flagZ <= '1';
                else
                  flagZ <= '0';
                end if;
                flagC <= ((not regX(7)) and datain(7)) or
                         (datain(7) and tres(7)) or
                         (tres(7) and (not regX(7)));
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
                if opcode = x"A6" then
                  regPC <= regPC + 1;
                end if;
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
                flagC <= (regA(7) and datain(7)) or
                         (datain(7) and (not tres(7))) or
                         ((not tres(7)) and regA(7));
                if opcode = x"AB" then
                  regPC <= regPC + 1;
                end if;
                mainFSM <= "0010";
              when x"AE" | x"BE" | x"CE" | x"DE" | x"EE" | x"FE" =>  -- LDX #opr8i, LDX opr8a, LDX opr16a, LDX oprx16,X, LDX oprx8,X, LDX ,X
                addrMux <= addrPC;
                regX <= datain;
                flagN <= datain(7);
                if datain = x"00" then
                  flagZ <= '1';
                else
                  flagZ <= '0';
                end if;
                if opcode = x"AE" then
                  regPC <= regPC + 1;
                end if;
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
                regPC <= (x"00" & help) + (x"00" & regX);
                regSP <= regSP - 1;
                mainFSM <= "0010";
              when x"FD" =>  -- JSR ,X
                wr <= CPUread;
                addrMux <= addrPC;
                regPC <= (x"00" & regX);
                regSP <= regSP - 1;
                mainFSM <= "0010";
                
              when others =>
                mainFSM <= "0000";
            end case; -- opcode
          
          when "0110" => --##################### instruction cycle 5
            case opcode is
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
                regPC <= temp + (x"00" & regX);
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
