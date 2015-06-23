--##############################################################################
--
--  programRom
--      NanoBlaze instruction ROM
--
--      The architecture is created by the assembler.
--      The systhesiser maps it into a Block RAM.
--
--------------------------------------------------------------------------------
--
--  Versions / Authors
--      1.0 Francois Corthay    first implementation
--
--  Provided under GNU LGPL licence: <http://www.gnu.org/copyleft/lesser.html>
--
--  by the electronics group of "HES-SO//Valais Wallis", in Switzerland:
--  <http://www.hevs.ch/en/rad-instituts/institut-systemes-industriels/>.
--
--------------------------------------------------------------------------------
--
--  Hierarchy
--      Used by "nanoblaze".
--
--##############################################################################

LIBRARY ieee;
  USE ieee.std_logic_1164.all;
  USE ieee.numeric_std.all;

ENTITY programRom IS
  GENERIC( 
      addressBitNb : positive := 8;
      dataBitNb    : positive := 8
  );
  PORT( 
    reset   : IN  std_uLogic;
    clock   : IN  std_uLogic;
    en      : IN  std_uLogic;
    address : IN  unsigned(addressBitNb-1 DOWNTO 0);
    dataOut : OUT std_ulogic_vector(dataBitNb-1 DOWNTO 0)
  );
END programRom ;

--==============================================================================

ARCHITECTURE mapped OF programRom IS

  subtype opCodeType is std_ulogic_vector(5 downto 0);
  constant opLoadC   : opCodeType := "000000";
  constant opLoadR   : opCodeType := "000001";
  constant opInputC  : opCodeType := "000100";
  constant opInputR  : opCodeType := "000101";
  constant opFetchC  : opCodeType := "000110";
  constant opFetchR  : opCodeType := "000111";
  constant opAndC    : opCodeType := "001010";
  constant opAndR    : opCodeType := "001011";
  constant opOrC     : opCodeType := "001100";
  constant opOrR     : opCodeType := "001101";
  constant opXorC    : opCodeType := "001110";
  constant opXorR    : opCodeType := "001111";
  constant opTestC   : opCodeType := "010010";
  constant opTestR   : opCodeType := "010011";
  constant opCompC   : opCodeType := "010100";
  constant opCompR   : opCodeType := "010101";
  constant opAddC    : opCodeType := "011000";
  constant opAddR    : opCodeType := "011001";
  constant opAddCyC  : opCodeType := "011010";
  constant opAddCyR  : opCodeType := "011011";
  constant opSubC    : opCodeType := "011100";
  constant opSubR    : opCodeType := "011101";
  constant opSubCyC  : opCodeType := "011110";
  constant opSubCyR  : opCodeType := "011111";
  constant opShRot   : opCodeType := "100000";
  constant opOutputC : opCodeType := "101100";
  constant opOutputR : opCodeType := "101101";
  constant opStoreC  : opCodeType := "101110";
  constant opStoreR  : opCodeType := "101111";

  subtype shRotCinType is std_ulogic_vector(2 downto 0);
  constant shRotLdC : shRotCinType := "00-";
  constant shRotLdM : shRotCinType := "01-";
  constant shRotLdL : shRotCinType := "10-";
  constant shRotLd0 : shRotCinType := "110";
  constant shRotLd1 : shRotCinType := "111";

  constant registerAddressBitNb : positive := 4;
  constant shRotPadLength : positive
    := dataOut'length - opCodeType'length - registerAddressBitNb
     - 1 - shRotCinType'length;
  subtype shRotDirType is std_ulogic_vector(1+shRotPadLength-1 downto 0);
  constant shRotL : shRotDirType := (0 => '0', others => '-');
  constant shRotR : shRotDirType := (0 => '1', others => '-');

  subtype branchCodeType is std_ulogic_vector(4 downto 0);
  constant brRet  : branchCodeType := "10101";
  constant brCall : branchCodeType := "11000";
  constant brJump : branchCodeType := "11010";
  constant brReti : branchCodeType := "11100";
  constant brEni  : branchCodeType := "11110";

  subtype branchConditionType is std_ulogic_vector(2 downto 0);
  constant brDo : branchConditionType := "000";
  constant brZ  : branchConditionType := "100";
  constant brNZ : branchConditionType := "101";
  constant brC  : branchConditionType := "110";
  constant brNC : branchConditionType := "111";

  subtype memoryWordType is std_ulogic_vector(dataOut'range);
  type memoryArrayType is array (0 to 2**address'length-1) of memoryWordType;

  signal memoryArray : memoryArrayType := (
                                                  --===============================================================
                                                  -- 1) Test logical operations with direct values
                                                  -----------------------------------------------------------------
    16#000# => opLoadC   & "0111" & "00000001",   -- LOAD      s7, 01
                                                  -----------------------------------------------------------------
                                                  -- Test "LOAD", "AND"
                                                  -----------------------------------------------------------------
    16#001# => opLoadC   & "0000" & "00001111",   -- LOAD      s0, 0F
    16#002# => opAndC    & "0000" & "00110011",   -- AND       s0, 33
    16#003# => opCompC   & "0000" & "00000011",   -- COMPARE   s0, 03
    16#004# => brJump    & brNZ   & "1111111101", -- JUMP      NZ, 3FD
                                                  -----------------------------------------------------------------
                                                  -- Test "OR"
                                                  -----------------------------------------------------------------
    16#005# => opLoadC   & "0001" & "00001111",   -- LOAD      s1, 0F
    16#006# => opOrC     & "0001" & "00110011",   -- OR        s1, 33
    16#007# => opCompC   & "0001" & "00111111",   -- COMPARE   s1, 3F
    16#008# => brJump    & brNZ   & "1111111101", -- JUMP      NZ, 3FD
                                                  -----------------------------------------------------------------
                                                  -- Test "XOR"
                                                  -----------------------------------------------------------------
    16#009# => opLoadC   & "0010" & "00001111",   -- LOAD      s2, 0F
    16#00A# => opXorC    & "0010" & "00110011",   -- XOR       s2, 33
    16#00B# => opCompC   & "0010" & "00111100",   -- COMPARE   s2, 3C
    16#00C# => brJump    & brNZ   & "1111111101", -- JUMP      NZ, 3FD
                                                  --===============================================================
                                                  -- 2) Test logical operations with registers
                                                  -----------------------------------------------------------------
    16#00D# => opAddC    & "0111" & "00000001",   -- ADD       s7, 01
                                                  -----------------------------------------------------------------
                                                  -- Test "LOAD"
                                                  -----------------------------------------------------------------
    16#00E# => opLoadC   & "0000" & "00110011",   -- LOAD      s0, 33
    16#00F# => opLoadR   & "0011" & "0000----",   -- LOAD      s3, s0
    16#010# => opCompC   & "0011" & "00110011",   -- COMPARE   s3, 33
    16#011# => brJump    & brNZ   & "1111111101", -- JUMP      NZ, 3FD
                                                  -----------------------------------------------------------------
                                                  -- Test "AND"
                                                  -----------------------------------------------------------------
    16#012# => opLoadC   & "0000" & "00001111",   -- LOAD      s0, 0F
    16#013# => opAndR    & "0000" & "0011----",   -- AND       s0, s3
    16#014# => opCompC   & "0000" & "00000011",   -- COMPARE   s0, 03
    16#015# => brJump    & brNZ   & "1111111101", -- JUMP      NZ, 3FD
                                                  -----------------------------------------------------------------
                                                  -- Test "OR"
                                                  -----------------------------------------------------------------
    16#016# => opLoadC   & "0001" & "00001111",   -- LOAD      s1, 0F
    16#017# => opOrR     & "0001" & "0011----",   -- OR        s1, s3
    16#018# => opCompC   & "0001" & "00111111",   -- COMPARE   s1, 3F
    16#019# => brJump    & brNZ   & "1111111101", -- JUMP      NZ, 3FD
                                                  -----------------------------------------------------------------
                                                  -- Test "XOR"
                                                  -----------------------------------------------------------------
    16#01A# => opLoadC   & "0010" & "00001111",   -- LOAD      s2, 0F
    16#01B# => opXorR    & "0010" & "0011----",   -- XOR       s2, s3
    16#01C# => opCompC   & "0010" & "00111100",   -- COMPARE   s2, 3C
    16#01D# => brJump    & brNZ   & "1111111101", -- JUMP      NZ, 3FD
                                                  --===============================================================
                                                  -- 3) Test arithmetic operations with constants
                                                  -----------------------------------------------------------------
    16#01E# => opAddC    & "0111" & "00000001",   -- ADD       s7, 01
                                                  -----------------------------------------------------------------
                                                  -- Test "ADD" and "ADDCY"
                                                  -----------------------------------------------------------------
    16#01F# => opLoadC   & "0000" & "00001111",   -- LOAD      s0, 0F
    16#020# => opAddC    & "0000" & "00110001",   -- ADD       s0, 31   ;  40
    16#021# => opAddCyC  & "0000" & "11110000",   -- ADDCY     s0, F0   ; 130
    16#022# => opAddCyC  & "0000" & "11110000",   -- ADDCY     s0, F0   ; 121
    16#023# => opAddC    & "0000" & "00001111",   -- ADD       s0, 0F   ;  30
    16#024# => opCompC   & "0000" & "00110000",   -- COMPARE   s0, 30
    16#025# => brJump    & brNZ   & "1111111101", -- JUMP      NZ, 3FD
                                                  -----------------------------------------------------------------
                                                  -- Test "SUB" and "SUBCY"
                                                  -----------------------------------------------------------------
    16#026# => opLoadC   & "0001" & "00001111",   -- LOAD      s1, 0F
    16#027# => opSubC    & "0001" & "00001100",   -- SUB       s1, 0C   ;  03
    16#028# => opSubCyC  & "0001" & "11110000",   -- SUBCY     s1, F0   ; 113
    16#029# => opSubCyC  & "0001" & "11110000",   -- SUBCY     s1, F0   ;  22
    16#02A# => opSubC    & "0001" & "00000001",   -- SUB       s1, 01   ;  21
    16#02B# => opCompC   & "0001" & "00100001",   -- COMPARE   s1, 21
    16#02C# => brJump    & brNZ   & "1111111101", -- JUMP      NZ, 3FD
                                                  --===============================================================
                                                  -- 4) Test arithmetic operations with registers
                                                  -----------------------------------------------------------------
    16#02D# => opAddC    & "0111" & "00000001",   -- ADD       s7, 01
                                                  -----------------------------------------------------------------
                                                  -- Test "ADD" and "ADDCY"
                                                  -----------------------------------------------------------------
    16#02E# => opLoadC   & "0000" & "00001111",   -- LOAD      s0, 0F
    16#02F# => opLoadC   & "0001" & "00110001",   -- LOAD      s1, 31
    16#030# => opLoadC   & "0010" & "11110000",   -- LOAD      s2, F0
    16#031# => opLoadC   & "0011" & "00001111",   -- LOAD      s3, 0F
    16#032# => opAddR    & "0000" & "0001----",   -- ADD       s0, s1   ;  40
    16#033# => opAddCyR  & "0000" & "0010----",   -- ADDCY     s0, s2   ; 130
    16#034# => opAddCyR  & "0000" & "0010----",   -- ADDCY     s0, s2   ; 121
    16#035# => opAddR    & "0000" & "0011----",   -- ADD       s0, s3   ;  30
    16#036# => opCompC   & "0000" & "00110000",   -- COMPARE   s0, 30
    16#037# => brJump    & brNZ   & "1111111101", -- JUMP      NZ, 3FD
                                                  -----------------------------------------------------------------
                                                  -- Test "SUB" and "SUBCY"
                                                  -----------------------------------------------------------------
    16#038# => opLoadC   & "0001" & "00001111",   -- LOAD      s1, 0F
    16#039# => opLoadC   & "0000" & "00001100",   -- LOAD      s0, 0C
    16#03A# => opLoadC   & "0010" & "11110000",   -- LOAD      s2, F0
    16#03B# => opLoadC   & "0011" & "00000001",   -- LOAD      s3, 01
    16#03C# => opSubR    & "0001" & "0000----",   -- SUB       s1, s0   ;  03
    16#03D# => opSubCyR  & "0001" & "0010----",   -- SUBCY     s1, s2   ; 113
    16#03E# => opSubCyR  & "0001" & "0010----",   -- SUBCY     s1, s2   ;  22
    16#03F# => opSubR    & "0001" & "0011----",   -- SUB       s1, s3   ;  21
    16#040# => opCompC   & "0001" & "00100001",   -- COMPARE   s1, 21
    16#041# => brJump    & brNZ   & "1111111101", -- JUMP      NZ, 3FD
                                                  --===============================================================
                                                  -- 5) Test shifts
                                                  -----------------------------------------------------------------
    16#042# => opAddC    & "0111" & "00000001",   -- ADD       s7, 01
                                                  -----------------------------------------------------------------
                                                  -- Test shift right
                                                  -----------------------------------------------------------------
    16#043# => opLoadC   & "0000" & "00001111",   -- LOAD      s0, 0F   ; 0F
    16#044# => opShRot   & "0000" & shRotR & shRotLd0,-- SR0       s0       ; 07
    16#045# => opShRot   & "0000" & shRotR & shRotLdM,-- SRX       s0       ; 03
    16#046# => opShRot   & "0000" & shRotR & shRotLd1,-- SR1       s0       ; 81
    16#047# => opShRot   & "0000" & shRotR & shRotLdM,-- SRX       s0       ; C0, C=1
    16#048# => opShRot   & "0000" & shRotR & shRotLdC,-- SRA       s0       ; E0, C=0
    16#049# => opShRot   & "0000" & shRotR & shRotLdC,-- SRA       s0       ; 70
    16#04A# => opCompC   & "0000" & "01110000",   -- COMPARE   s0, 70
    16#04B# => brJump    & brNZ   & "1111111101", -- JUMP      NZ, 3FD
                                                  -----------------------------------------------------------------
                                                  -- Test shift left
                                                  -----------------------------------------------------------------
    16#04C# => opLoadC   & "0001" & "11110000",   -- LOAD      s1, F0   ; FO
    16#04D# => opShRot   & "0001" & shRotL & shRotLd0,-- SL0       s1       ; E0
    16#04E# => opShRot   & "0001" & shRotL & shRotLdL,-- SLX       s1       ; C0
    16#04F# => opShRot   & "0001" & shRotL & shRotLd1,-- SL1       s1       ; 81
    16#050# => opShRot   & "0001" & shRotL & shRotLdL,-- SLX       s1       ; 03, C=1
    16#051# => opShRot   & "0001" & shRotL & shRotLdC,-- SLA       s1       ; 07, C=0
    16#052# => opShRot   & "0001" & shRotL & shRotLdC,-- SLA       s1       ; 0E
    16#053# => opCompC   & "0001" & "00001110",   -- COMPARE   s1, 0E
    16#054# => brJump    & brNZ   & "1111111101", -- JUMP      NZ, 3FD
                                                  --===============================================================
                                                  -- 6) Test comparison operators
                                                  -----------------------------------------------------------------
    16#055# => opAddC    & "0111" & "00000001",   -- ADD       s7, 01
                                                  -----------------------------------------------------------------
                                                  -- Test "COMPARE"
                                                  -----------------------------------------------------------------
    16#056# => opLoadC   & "0000" & "00001111",   -- LOAD      s0, 0F
    16#057# => opCompC   & "0000" & "11110000",   -- COMPARE   s0, F0   ; A < B => C=1
    16#058# => brJump    & brNC   & "1111111101", -- JUMP      NC, 3FD
    16#059# => opCompC   & "0000" & "11110000",   -- COMPARE   s0, F0   ; A < B => Z=0
    16#05A# => brJump    & brZ    & "1111111101", -- JUMP      Z, 3FD
    16#05B# => opCompR   & "0000" & "0000----",   -- COMPARE   s0, s0   ; A = B => Z=1
    16#05C# => brJump    & brNZ   & "1111111101", -- JUMP      NZ, 3FD
    16#05D# => opCompC   & "0000" & "00001000",   -- COMPARE   s0, 08   ; A > B => C=0
    16#05E# => brJump    & brC    & "1111111101", -- JUMP      C, 3FD
    16#05F# => opCompC   & "0000" & "00001000",   -- COMPARE   s0, 08   ; A > B => Z=0
    16#060# => brJump    & brZ    & "1111111101", -- JUMP      Z, 3FD
                                                  -----------------------------------------------------------------
                                                  -- Test "TEST"
                                                  -----------------------------------------------------------------
    16#061# => opLoadC   & "0000" & "00001111",   -- LOAD      s0, 0F
    16#062# => opTestC   & "0000" & "11110000",   -- TEST      s0, F0   ; AND is 00 => Z=1
    16#063# => brJump    & brNZ   & "1111111101", -- JUMP      NZ, 3FD
    16#064# => opTestC   & "0000" & "11111111",   -- TEST      s0, FF   ; AND is 0F => Z=0
    16#065# => brJump    & brZ    & "1111111101", -- JUMP      Z, 3FD
                                                  --===============================================================
                                                  -- 7) Test INPUT and OUTPUT operators
                                                  -----------------------------------------------------------------
    16#066# => opAddC    & "0111" & "00000001",   -- ADD       s7, 01
                                                  -----------------------------------------------------------------
                                                  -- Test "INPUT" and "OUTPUT" direct
                                                  --
                                                  -- The testbench should invert the word written at address FC.
                                                  -----------------------------------------------------------------
    16#067# => opLoadC   & "0000" & "10101010",   -- LOAD      s0, AA
    16#068# => opOutputC & "0000" & "11111100",   -- OUTPUT    s0, FC
    16#069# => opInputC  & "0001" & "11111100",   -- INPUT     s1, FC
    16#06A# => opCompC   & "0001" & "01010101",   -- COMPARE   s1, 55
    16#06B# => brJump    & brNZ   & "1111111101", -- JUMP      NZ, 3FD
                                                  -----------------------------------------------------------------
                                                  -- Test "INPUT" and "OUTPUT" indexed
                                                  -----------------------------------------------------------------
    16#06C# => opLoadC   & "0000" & "11001100",   -- LOAD      s0, CC
    16#06D# => opLoadC   & "0010" & "11111100",   -- LOAD      s2, FC
    16#06E# => opOutputR & "0000" & "0010----",   -- OUTPUT    s0, (S2)
    16#06F# => opInputR  & "0001" & "0010----",   -- INPUT     s1, (S2)
    16#070# => opCompC   & "0001" & "00110011",   -- COMPARE   s1, 33
    16#071# => brJump    & brNZ   & "1111111101", -- JUMP      NZ, 3FD
                                                  --===============================================================
                                                  -- 8) Test STORE and FETCH operators
                                                  -----------------------------------------------------------------
    16#072# => opAddC    & "0111" & "00000001",   -- ADD       s7, 01
                                                  -----------------------------------------------------------------
                                                  -- Test "STORE" and "FETCH" direct
                                                  -----------------------------------------------------------------
    16#073# => opLoadC   & "0000" & "00001111",   -- LOAD      s0, 0F
    16#074# => opStoreC  & "0000" & "00000011",   -- STORE     s0, 03
    16#075# => opFetchC  & "0001" & "00000011",   -- FETCH     s1, 03
    16#076# => opCompC   & "0001" & "00001111",   -- COMPARE   s1, 0F
    16#077# => brJump    & brNZ   & "1111111101", -- JUMP      NZ, 3FD
                                                  -----------------------------------------------------------------
                                                  -- Test "STORE" and "FETCH" indexed
                                                  -----------------------------------------------------------------
    16#078# => opLoadC   & "0000" & "11110000",   -- LOAD      s0, F0
    16#079# => opLoadC   & "0010" & "00000100",   -- LOAD      s2, 04
    16#07A# => opStoreR  & "0000" & "0010----",   -- STORE     s0, (S2)
    16#07B# => opFetchR  & "0001" & "0010----",   -- FETCH     s1, (S2)
    16#07C# => opCompC   & "0001" & "11110000",   -- COMPARE   s1, F0
    16#07D# => brJump    & brNZ   & "1111111101", -- JUMP      NZ, 3FD
                                                  --===============================================================
                                                  -- 9) Test JUMP instructions
                                                  -----------------------------------------------------------------
    16#07E# => opAddC    & "0111" & "00000001",   -- ADD       s7, 01
                                                  -----------------------------------------------------------------
                                                  -- Test "JUMP NC"
                                                  -----------------------------------------------------------------
    16#07F# => opLoadC   & "0000" & "11110000",   -- LOAD      s0, F0
    16#080# => opAddC    & "0000" & "00000000",   -- ADD       s0, 00   ; s0=F0, C=0, Z=0
    16#081# => brJump    & brNC   & "0010000011", -- JUMP      NC, 083
    16#082# => brJump    & brDo   & "1111111101", -- JUMP      3FD
                                                  -----------------------------------------------------------------
                                                  -- Test "JUMP NZ"
                                                  -----------------------------------------------------------------
                                                  -- _continue1_:
    16#083# => opAddC    & "0000" & "00000000",   -- ADD       s0, 00   ; s0=F0, C=0, Z=0
    16#084# => brJump    & brNZ   & "0010000110", -- JUMP      NZ, 086
    16#085# => brJump    & brDo   & "1111111101", -- JUMP      3FD
                                                  -----------------------------------------------------------------
                                                  -- Test "JUMP C"
                                                  -----------------------------------------------------------------
                                                  -- _continue2_:
    16#086# => opAddC    & "0000" & "11110000",   -- ADD       s0, F0   ; s0=E0, C=1, Z=0
    16#087# => brJump    & brC    & "0010001001", -- JUMP      C, 089
    16#088# => brJump    & brDo   & "1111111101", -- JUMP      3FD
                                                  -----------------------------------------------------------------
                                                  -- Test "JUMP Z"
                                                  -----------------------------------------------------------------
                                                  -- _continue3_:
    16#089# => opSubC    & "0000" & "11100000",   -- SUB       s0, E0   ; s0=00, C=0, Z=1
    16#08A# => brJump    & brZ    & "0010001100", -- JUMP      Z, 08C
    16#08B# => brJump    & brDo   & "1111111101", -- JUMP      3FD
                                                  -- _continue4_:
    16#08C# => opLoadR   & "0000" & "0000----",   -- NOP
                                                  --===============================================================
                                                  -- 10) Test call instructions
                                                  -----------------------------------------------------------------
    16#08D# => opAddC    & "0111" & "00000001",   -- ADD       s7, 01
                                                  -----------------------------------------------------------------
                                                  -- define subroutine
                                                  -----------------------------------------------------------------
    16#08E# => brJump    & brDo   & "0010010010", -- JUMP      092
                                                  -- _subRetDo_:
    16#08F# => opAddC    & "0000" & "00000001",   -- ADD       s0, 01
    16#090# => brRet     & brDo   & "----------", -- RETURN
    16#091# => brJump    & brDo   & "1111111101", -- JUMP      3FD
                                                  -----------------------------------------------------------------
                                                  -- Test "CALL"
                                                  -----------------------------------------------------------------
                                                  -- _continue5_:
    16#092# => opLoadC   & "0000" & "00000000",   -- LOAD      s0, 00
    16#093# => opLoadC   & "0001" & "11110000",   -- LOAD      s1, F0
    16#094# => brCall    & brDo   & "0010001111", -- CALL      08F      ; s0=01
                                                  -----------------------------------------------------------------
                                                  -- Test "CALL NC"
                                                  -----------------------------------------------------------------
    16#095# => opAddC    & "0001" & "00000000",   -- ADD       s1, 00   ; s1=F0, C=0, Z=0
    16#096# => brCall    & brNC   & "0010001111", -- CALL      NC, 08F  ; s0=02
                                                  -----------------------------------------------------------------
                                                  -- Test "CALL NZ"
                                                  -----------------------------------------------------------------
    16#097# => opAddC    & "0001" & "00000000",   -- ADD       s1, 00   ; s1=F0, C=0, Z=0
    16#098# => brCall    & brNZ   & "0010001111", -- CALL      NZ, 08F  ; s0=03
                                                  -----------------------------------------------------------------
                                                  -- Test "CALL C"
                                                  -----------------------------------------------------------------
    16#099# => opAddC    & "0001" & "11110000",   -- ADD       s1, F0   ; s0=E0, C=1, Z=0
    16#09A# => brCall    & brC    & "0010001111", -- CALL      C, 08F   ; s0=04
                                                  -----------------------------------------------------------------
                                                  -- Test "CALL Z"
                                                  -----------------------------------------------------------------
    16#09B# => opSubC    & "0001" & "11100000",   -- SUB       s1, E0   ; s0=00, C=0, Z=1
    16#09C# => brCall    & brZ    & "0010001111", -- CALL      Z, 08F   ; s0=05
    16#09D# => opCompC   & "0000" & "00000101",   -- COMPARE   s0, 05
    16#09E# => brJump    & brNZ   & "1111111101", -- JUMP      NZ, 3FD
                                                  --===============================================================
                                                  -- 11) Test call return instructions
                                                  -----------------------------------------------------------------
    16#09F# => opAddC    & "0111" & "00000001",   -- ADD       s7, 01
                                                  -----------------------------------------------------------------
                                                  -- define subroutines
                                                  -----------------------------------------------------------------
    16#0A0# => brJump    & brDo   & "0010101101", -- JUMP      0AD
                                                  -- _subRetNC_:
    16#0A1# => opAddC    & "0000" & "00000001",   -- ADD       s0, 01
    16#0A2# => brRet     & brDo   & "----------", -- RETURN    NC
    16#0A3# => brJump    & brDo   & "1111111101", -- JUMP      3FD
                                                  -- _subRetNZ_:
    16#0A4# => opAddC    & "0000" & "00000001",   -- ADD       s0, 01
    16#0A5# => brRet     & brDo   & "----------", -- RETURN    NZ
    16#0A6# => brJump    & brDo   & "1111111101", -- JUMP      3FD
                                                  -- _subRetC_:
    16#0A7# => opAddC    & "0000" & "00000001",   -- ADD       s0, 01
    16#0A8# => brRet     & brDo   & "----------", -- RETURN    C
    16#0A9# => brJump    & brDo   & "1111111101", -- JUMP      3FD
                                                  -- _subRetZ_:
    16#0AA# => opAddC    & "0000" & "00000001",   -- ADD       s0, 01
    16#0AB# => brRet     & brDo   & "----------", -- RETURN    Z
    16#0AC# => brJump    & brDo   & "1111111101", -- JUMP      3FD
                                                  -----------------------------------------------------------------
                                                  -- Test "RETURN NC"
                                                  -----------------------------------------------------------------
                                                  -- _continue6_:
    16#0AD# => opLoadC   & "0000" & "00000000",   -- LOAD      s0, 00   ; increment will give C=0, Z=0
    16#0AE# => brCall    & brNC   & "0010100001", -- CALL      NC, 0A1
                                                  -----------------------------------------------------------------
                                                  -- Test "RETURN NZ"
                                                  -----------------------------------------------------------------
    16#0AF# => opLoadC   & "0000" & "00000000",   -- LOAD      s0, 00   ; increment will give C=0, Z=0
    16#0B0# => brCall    & brNZ   & "0010100100", -- CALL      NZ, 0A4
                                                  -----------------------------------------------------------------
                                                  -- Test "RETURN C"
                                                  -----------------------------------------------------------------
    16#0B1# => opLoadC   & "0000" & "11111111",   -- LOAD      s0, FF   ; increment will give C=1, Z=1
    16#0B2# => brCall    & brC    & "0010100111", -- CALL      C, 0A7
                                                  -----------------------------------------------------------------
                                                  -- Test "RETURN Z"
                                                  -----------------------------------------------------------------
    16#0B3# => opLoadC   & "0000" & "11111111",   -- LOAD      s0, FF   ; increment will give C=1, Z=1
    16#0B4# => brCall    & brZ    & "0010101010", -- CALL      Z, 0AA
                                                  --===============================================================
                                                  -- End of tests
                                                  --
                                                  -- The testbench should react if value 1 is written to address 00.
                                                  -----------------------------------------------------------------
    16#0B5# => opLoadC   & "0000" & "00000001",   -- LOAD      s0, 01
    16#0B6# => opOutputC & "0000" & "00000000",   -- OUTPUT    s0, 00
    16#0B7# => brJump    & brDo   & "1111111111", -- JUMP      3FF
                                                  --===============================================================
                                                  -- Assert error
                                                  --
                                                  -- The testbench should react if value 0 is written to address 00.
                                                  -----------------------------------------------------------------
                                                  -- _error_:
    16#3FD# => opLoadC   & "0000" & "00000000",   -- LOAD      s0, 00
    16#3FE# => opOutputC & "0000" & "00000000",   -- OUTPUT    s0, 00
                                                  --===============================================================
                                                  -- End of instruction memory
                                                  -----------------------------------------------------------------
                                                  -- _endOfMemory_:
    16#3FF# => brJump    & brDo   & "1111111111", -- JUMP      3FF
    others => (others => '0')
  );

BEGIN

  process (clock)
  begin
    if rising_edge(clock) then
      if en = '1' then
        dataOut <= memoryArray(to_integer(address));
      end if;
    end if;
  end process;

END ARCHITECTURE mapped;
