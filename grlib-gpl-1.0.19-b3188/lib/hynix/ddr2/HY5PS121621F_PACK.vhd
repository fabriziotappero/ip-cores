------------------------------------------------------
--      Hynix 4BANKS X 8M X 16bits DDR2 SDRAM       --
--                                                  --
--          Packages for HY5PS121621F.vhd           --
--                                                  --
--                 HHHH    HHHH                     --
--                 HHHH    HHHH                     --
--       ,O0O.  ,O0 .HH ,O0 .HH                     --
--      (O000O)(000  )H(000  )H    Hynix            --
--       `O0O'  `O0 'HH `O0 'HH                     -- 
--                 HHHH    HHHH    Semiconductor    --
--                 HHHH    HHHH                     --
------------------------------------------------------

---------------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
library grlib;
use grlib.stdlib.all;
--USE IEEE.STD_LOGIC_ARITH.all;
--USE IEEE.STD_LOGIC_UNSIGNED.all;
---------------------------------------------------------------------------------------------------

package HY5PS121621F_PACK is

---------------------------------------------------------------------------------------------------
  constant NUM_OF_MROPCODE : integer := 13;

  constant NUM_OF_ROW_ADD : integer := 13;

  constant NUM_OF_COL_ADD : integer := 10;

  constant NUM_OF_BANK_ADD : integer := 2;

  constant WORD_SIZE : integer := 16;

  constant NUM_OF_ROWS : integer := 2**NUM_OF_ROW_ADD;

  constant NUM_OF_COLS : integer := 2**NUM_OF_COL_ADD;

  constant NUM_OF_BANKS : integer := 2**NUM_OF_BANK_ADD;

  constant NUM_OF_BUFFERS : integer := 3;

  type PART_NUM_TYPE is (B400, B533, B667, B800);

  type PART_NUM is array (B400 to B800) of time;

  constant tCKmin : PART_NUM := (B400 => 5 ns, B533 => 3.75 ns, B667 => 3 ns, B800 => 2.5 ns);

  constant tCKmax : PART_NUM := (B400 => 8 ns, B533 => 8 ns, B667 => 8 ns, B800 => 8 ns);

  constant tWR : PART_NUM := (B400 => 15 ns, B533 => 15 ns, B667 => 15 ns, B800 => 15 ns);

  constant tDS : PART_NUM := (B400 => 0.4 ns, B533 => 0.35 ns, B667 => 0.3 ns, B800 => 0.3 ns);

  constant tDH : PART_NUM := (B400 => 0.4 ns, B533 => 0.35 ns, B667 => 0.3 ns, B800 => 0.3 ns);

  constant tIS : PART_NUM := (B400 => 0.6 ns, B533 => 0.5 ns, B667 => 0.5 ns, B800 => 0.4 ns);

  constant tIH : PART_NUM := (B400 => 0.6 ns, B533 => 0.5 ns, B667 => 0.5 ns, B800 => 0.4 ns);

  constant tWTR : PART_NUM := (B400 => 10 ns, B533 => 7.5 ns, B667 => 7.5 ns, B800 => 7.5 ns);

  constant tRASmax : PART_NUM := (B400 => 70000 ns, B533 => 70000 ns, B667 => 70000 ns, B800 => 70000 ns);

  constant tRRD : time := 10 ns;

  constant tREF : time := 64 ms;

  constant tRFC : time := 75 ns;

  constant tRTP : time := 7.5 ns;

  constant tXSNR : time := tRFC + 10 ns;
 
  constant tXP : integer := 2;

  constant tCKE : integer := 3;

  constant tXARD : integer := 2;

  constant tXARDS : integer := 2;

  constant tXSRD : integer := 200;

  constant tPUS : time := 200 us;

  type STATE_TYPE is (
    PWRDN,
    PWRUP,
    SLFREF,
    IDLE,
    RACT,
    READ,
    WRITE);

  type COMMAND_TYPE is (
    DSEL,
    NOP,
    MRS,
    EMRS1,
    EMRS2,
    EMRS3,
    ACT,
    RD,
    RDAP,
    WR,
    WRAP,
    PCG,
    PCGA,
    AREF,
    SREF,
    SREX,
    PDEN,
    PDEX,
    ERROR,
    ILLEGAL);

  type BURST_MODE_TYPE is (
    SEQUENTIAL,
    INTERLEAVE);

  type OCD_DRIVE_MODE_TYPE is (
    CAL_EXIT,
    DRIVE1,
    DRIVE0,
    ADJUST,
    CAL_DEFAULT);

  subtype CL_TYPE is integer range 0 to 6;

  subtype BL_TYPE is integer range 4 to 8;
 
  subtype TWR_TYPE is integer range 2 to 6;

  type DLL_RST is (
    RST,
    NORST); 

  type MODE_REGISTER is 
    record
      CAS_LATENCY : CL_TYPE;
      BURST_MODE : BURST_MODE_TYPE;
      BURST_LENGTH : BL_TYPE;
      DLL_STATE : DLL_RST;
      SAPD : std_logic;
      TWR : TWR_TYPE;
    end record;

  type EMR_TYPE is
    record
      DLL_EN : std_logic; 
      AL : CL_TYPE;
      QOFF : std_logic;
      DQSB_ENB : std_logic;
      RDQS_EN : std_logic;
      OCD_PGM : OCD_DRIVE_MODE_TYPE;
    end record;

  type EMR2_TYPE is
    record
      SREF_HOT : std_logic;
    end record;

  type REF_CHECK is array (0 to (NUM_OF_BANKS - 1), 0 to (NUM_OF_ROWS - 1)) of time;

  type COL_ADDR_TYPE is array (0 to 3) of std_logic_vector((NUM_OF_COL_ADD - 1) downto 0);

  type DATA_BUFFER_TYPE is array (0 to 6) of std_logic_vector(8 downto 0);

  subtype COL_DATA_TYPE is integer range 0 to 65535;

  type SA_TYPE is array (0 to (NUM_OF_COLS - 1)) of COL_DATA_TYPE;

  type ROW_DATA_TYPE is array (0 to (NUM_OF_COLS - 1)) of COL_DATA_TYPE;

  type RAM_PNTR is ACCESS ROW_DATA_TYPE;

  type SA_ARRAY_TYPE is array (0 to (NUM_OF_BANKS - 1)) of SA_TYPE;

  type MEM_CELL_TYPE is array (0 to (NUM_OF_ROWS - 1)) of RAM_PNTR;

  subtype DATA_TYPE is std_logic_vector ((WORD_SIZE - 1) downto 0);

  type BUFFER_TYPE is array (0 to NUM_OF_BUFFERS - 1, 0 to 3) of DATA_TYPE;

  type ADD_PIPE_TYPE is array (0 to 12) of std_logic_vector((NUM_OF_COL_ADD + NUM_OF_BANK_ADD - 1) downto 0);

  type CKE_TYPE is array (integer range -1 to 0) of std_logic;

  subtype MROPCODE_TYPE is std_logic_vector ((NUM_OF_MROPCODE - 1) downto 0);

  procedure COMMAND_DECODE (
    variable
      CSB,
      RASB,
      CASB,
      WEB,
      A10 : in std_logic;
    variable
      Bank_Add : in std_logic_vector((NUM_OF_BANK_ADD - 1) downto 0);
    variable
      CKE : in CKE_TYPE;
    variable
      COMMAND : out COMMAND_TYPE;
    variable
      BankState : in std_logic_vector((NUM_OF_BANKS - 1) downto 0);
    variable
      State : in STATE_TYPE);

  procedure MODE_REGISTER_SET (
    MROPCODE : in MROPCODE_TYPE;
    MR : out MODE_REGISTER);

  procedure EXT_MODE_REGISTER_SET (
    MROPCODE : in MROPCODE_TYPE;
    EMR : out EMR_TYPE);

  procedure EXT_MODE_REGISTER_SET2 (
    MROPCODE : in MROPCODE_TYPE;
    EMR : out EMR2_TYPE);

  function REMAINDER (
    val0 : in integer;
    val1 : in integer) return integer;

  function XOR_FUNC (
    val0 : in std_logic_vector;
    val1 : in std_logic_vector) return std_logic_vector;

  function CHAR_TO_STD_LOGIC (
    c : in character)
    return std_logic;

  function STD_LOGIC_TO_BIT (V: STD_LOGIC) return BIT;

end HY5PS121621F_PACK; ------------------------------------------------------HY5DU121622T Package

---------------------------------------------------------------------------------------------------

package body HY5PS121621F_PACK is

---------------------------------------------------------------------------------------------------
  procedure COMMAND_DECODE (
    variable
      CSB,
      RASB,
      CASB,
      WEB,
      A10 : in std_logic;
    variable
      Bank_Add : in std_logic_vector((NUM_OF_BANK_ADD - 1) downto 0);
    variable
      CKE : in CKE_TYPE;
    variable
      COMMAND : out COMMAND_TYPE;
    variable
      BankState : in std_logic_vector((NUM_OF_BANKS - 1) downto 0);
    variable 
      State : in STATE_TYPE) Is
 
    begin
      case CKE (-1) is
        when '1' =>
          case CKE (0) is
            when '0' =>
              if (BankState = "0000") then
                if (CSB = '0' and RASB = '0' and CASB = '0' and WEB = '1') then
                  COMMAND := SREF;
                elsif ((CSB = '1') or (CSB = '0' and RASB = '1' and CASB = '1' and WEB = '1')) then
                  COMMAND := PDEN;
                else
                  COMMAND := ILLEGAL;
                end if;
              elsif ((CSB = '1') or (CSB = '0' and RASB = '1' and CASB = '1' and WEB = '1')) then
                COMMAND := PDEN;
              else
                COMMAND := ILLEGAL;
              end if;
            when '1' =>
              if (CSB = '1') then
                COMMAND := DSEL;
              elsif (CSB = '0' and RASB = '1' and CASB = '1' and WEB ='1') then
                COMMAND := NOP;
              elsif (CSB = '0' and RASB = '1' and CASB = '0' and WEB ='1') then
                if (A10 = '0') then
                  COMMAND := RD;
                else
                  COMMAND := RDAP;
                end if;
              elsif (CSB = '0' and RASB = '1' and CASB = '0' and WEB ='0') then 
                if (A10 = '0') then
                  COMMAND := WR;
                else
                  COMMAND := WRAP;
                end if;
              elsif (CSB = '0' and RASB = '0' and CASB = '1' and WEB ='1') then
                COMMAND := ACT;
              elsif (CSB = '0' and RASB = '0' and CASB = '1' and WEB ='0') then
                if (A10 = '0') then
                  COMMAND := PCG;
                else
                  COMMAND := PCGA;
                end if;
              elsif (CSB = '0' and RASB = '0' and CASB = '0' and WEB ='1') then
                COMMAND := AREF;
              elsif (CSB = '0' and RASB = '0' and CASB = '0' and WEB ='0') then
                if (BankState = "0000") then
		  if (Bank_Add = "00") then
                    COMMAND := MRS;
		  elsif (Bank_Add = "01") then
                    COMMAND := EMRS1;
		  elsif (Bank_Add = "10") then
                    COMMAND := EMRS2;
		  elsif (Bank_Add = "11") then
                    COMMAND := EMRS3;
		  end if;
                else
                  COMMAND := ILLEGAL;
                end if;
              end if;
            when others =>
              COMMAND := ERROR;
            end case;
        when '0' =>
          case CKE (0) is
            when '0' =>
              COMMAND := NOP;
            when '1' =>
              if (State = PWRUP) then
                COMMAND := NOP;
              elsif (CSB = '1') then
                if (State = SLFREF) then
                  COMMAND := SREX;
                elsif (State = PWRDN) then
                  COMMAND := PDEX;
                end if;
              elsif (CSB = '0' and RASB = '1' and CASB = '1' and WEB ='1') then
                if (State = SLFREF) then
                  COMMAND := SREX;
                elsif (State = PWRDN) then
                  COMMAND := PDEX;
                end if;
              else
                COMMAND := ERROR;
              end if;
            when others =>
              COMMAND := ERROR;
          end case;
        when others =>
          COMMAND := ERROR;
        end case;
    end COMMAND_DECODE;
------------------------------------------------------------------------------------------------
  procedure MODE_REGISTER_SET (
    MROPCODE : in MROPCODE_TYPE;
    MR : out MODE_REGISTER) is
  begin
    if (MROPCODE(6) = '0' and MROPCODE(5) = '1' and MROPCODE(4) = '0')then
      MR.CAS_LATENCY := 2;
    elsif (MROPCODE(6) = '0' and MROPCODE(5) = '1' and MROPCODE(4) = '1')then
      MR.CAS_LATENCY := 3;
    elsif (MROPCODE(6) = '1' and MROPCODE(5) = '0' and MROPCODE(4) = '0')then
      MR.CAS_LATENCY := 4;
    elsif (MROPCODE(6) = '1' and MROPCODE(5) = '0' and MROPCODE(4) = '1')then
      MR.CAS_LATENCY := 5;
    elsif (MROPCODE(6) = '1' and MROPCODE(5) = '1' and MROPCODE(4) = '0')then
      MR.CAS_LATENCY := 6;
    else
      assert false report
      "ERROR : (MODE_REGISTER_SET_PROCEDURE) : Invalid Cas_Latency Encountered!"
      severity WARNING;
    end if;
    if MROPCODE(3) = '0' then
      MR.BURST_MODE := SEQUENTIAL;
    elsif MROPCODE(3) = '1' then
      MR.BURST_MODE := INTERLEAVE;
    end if;
    if MROPCODE(8) = '0' then
      MR.DLL_STATE := NORST;
    elsif MROPCODE(8) = '1' then
      MR.DLL_STATE := RST;
    end if;
    if MROPCODE(2) = '0' and MROPCODE(1) = '1' and MROPCODE(0) = '0' then
      MR.BURST_LENGTH := 4;
    elsif MROPCODE(2) = '0' and MROPCODE(1) = '1' and MROPCODE(0) = '1' then
      MR.BURST_LENGTH := 8;
    else
      assert false report
      "ERROR : (MODE_REGISTER_SET_PROCEDURE) : Invalid Burst_Length Encountered!"
      severity ERROR;
    end if;
    if MROPCODE(12) = '0' then
      MR.SAPD := '0';
    elsif MROPCODE(12) = '1' then
      MR.SAPD := '1';
    end if;
    if MROPCODE(11) = '0' and MROPCODE(10) = '0' and MROPCODE(9) = '1' then
      MR.TWR := 2;
    elsif MROPCODE(11) = '0' and MROPCODE(10) = '1' and MROPCODE(9) = '0' then
      MR.TWR := 3;
    elsif MROPCODE(11) = '0' and MROPCODE(10) = '1' and MROPCODE(9) = '1' then
      MR.TWR := 4;
    elsif MROPCODE(11) = '1' and MROPCODE(10) = '0' and MROPCODE(9) = '0' then
      MR.TWR := 5;
    elsif MROPCODE(11) = '1' and MROPCODE(10) = '0' and MROPCODE(9) = '1' then
      MR.TWR := 6;
    else
      assert false report
      "ERROR : (MODE_REGISTER_SET_PROCEDURE) : Invalid Write Recovery Value Encountered!"
      severity ERROR;
    end if;
  end MODE_REGISTER_SET;
------------------------------------------------------------------------------------------------
  procedure EXT_MODE_REGISTER_SET (
    MROPCODE : in MROPCODE_TYPE;
    EMR : out EMR_TYPE) is
  begin
    if (MROPCODE(0) = '0') then
      EMR.DLL_EN := '1';
    elsif (MROPCODE(0) = '1') then
      EMR.DLL_EN := '0';
    end if;
    if (MROPCODE(5) = '0' and MROPCODE(4) = '0' and MROPCODE(3) = '0')then
      EMR.AL := 0;
    elsif (MROPCODE(5) = '0' and MROPCODE(4) = '0' and MROPCODE(3) = '1')then
      EMR.AL := 1;
    elsif (MROPCODE(5) = '0' and MROPCODE(4) = '1' and MROPCODE(3) = '0')then
      EMR.AL := 2;
    elsif (MROPCODE(5) = '0' and MROPCODE(4) = '1' and MROPCODE(3) = '1')then
      EMR.AL := 3;
    elsif (MROPCODE(5) = '1' and MROPCODE(4) = '0' and MROPCODE(3) = '0')then
      EMR.AL := 4;
    elsif (MROPCODE(5) = '1' and MROPCODE(4) = '0' and MROPCODE(3) = '1')then
      EMR.AL := 5;
    else
      assert false report
      "ERROR : (EXT_MODE_REGISTER_SET_PROCEDURE) : Invalid Additive_Latency Encountered!"
      severity WARNING;
    end if;
    if MROPCODE(12) = '0' then
      EMR.QOFF := '0';
    elsif MROPCODE(12) = '1' then
      EMR.QOFF := '1';
    end if;
    if MROPCODE(10) = '0' then
      EMR.DQSB_ENB := '0';
    elsif MROPCODE(10) = '1' then
      EMR.DQSB_ENB := '1';
    end if;
    if MROPCODE(11) = '0' then
      EMR.RDQS_EN := '0';
    elsif MROPCODE(11) = '1' then
      EMR.RDQS_EN := '1';
    end if;
    if MROPCODE(9) = '0' and MROPCODE(8) = '0' and MROPCODE(7) = '0' then
      EMR.OCD_PGM := CAL_EXIT;
    elsif MROPCODE(9) = '0' and MROPCODE(8) = '0' and MROPCODE(7) = '1' then
      EMR.OCD_PGM := DRIVE1;
    elsif MROPCODE(9) = '0' and MROPCODE(8) = '1' and MROPCODE(7) = '0' then
      EMR.OCD_PGM := DRIVE0;
    elsif MROPCODE(9) = '1' and MROPCODE(8) = '0' and MROPCODE(7) = '0' then
      EMR.OCD_PGM := ADJUST;
    elsif MROPCODE(9) = '1' and MROPCODE(8) = '1' and MROPCODE(7) = '1' then
      EMR.OCD_PGM := CAL_DEFAULT;
    else
      assert false report
      "ERROR : (EXT_MODE_REGISTER_SET_PROCEDURE) : Invalid OCD Calibration Program Encountered!"
      severity ERROR;
    end if;
  end EXT_MODE_REGISTER_SET;
------------------------------------------------------------------------------------------------
  procedure EXT_MODE_REGISTER_SET2 (
    MROPCODE : in MROPCODE_TYPE;
    EMR : out EMR2_TYPE) is
  begin
    if (MROPCODE(7) = '0') then
      EMR.SREF_HOT := '0';
    elsif (MROPCODE(7) = '1') then
      EMR.SREF_HOT := '1';
    end if;
  end EXT_MODE_REGISTER_SET2;
------------------------------------------------------------------------------------------------
  function REMAINDER (val0 : in integer; val1 : in integer) return integer is
    variable Result : integer;
  begin
    Result := val0;
    loop
      exit when Result < val1;
      Result := Result - val1;
    end loop;
    return Result;
  end REMAINDER;
------------------------------------------------------------------------------------------------
  function XOR_FUNC (val0 : in std_logic_vector; val1 : in std_logic_vector) return std_logic_vector is
    variable Result : std_logic_vector(2 downto 0);
    variable j : integer := 0;
  begin
    for i in val0'RANGE LOOP
      if (val0(i) /= val1(i)) then
        Result(i) := '1';
      else
        Result(i) := '0';
      end if;
      j := j + 1;
    end loop;
    return Result((j - 1) downto 0);
  end XOR_FUNC;
------------------------------------------------------------------------------------------------
  function CHAR_TO_STD_LOGIC (
    c : in character)
    return std_logic is
    variable r : std_logic;
  begin
    case c is
      when '0' => r := '0';
      when 'L' => r := 'L';
      when '1' => r := '1';
      when 'H' => r := 'H';
      when 'W' => r := 'W';
      when 'Z' => r := 'Z';
      when 'U' => r := 'U';
      when '-' => r := '-';
      when others => r := 'X';
    end case;
    return r;
  end CHAR_TO_STD_LOGIC;
------------------------------------------------------------------------------------------------
  function STD_LOGIC_TO_BIT (V: STD_LOGIC) return BIT is
    variable Result: BIT;
  begin
    case V is
      when '0' | 'L' =>
        Result := '0';
      when '1' | 'H' =>
        Result := '1';
      when 'X' | 'W' | 'Z' | 'U' | '-' =>
        Result := '0';
    end case;
    return Result;
  end STD_LOGIC_TO_BIT;
------------------------------------------------------------------------------------------------ 
end HY5PS121621F_PACK;
