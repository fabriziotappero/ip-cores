-- Copyright (c)2013 Jeremy Seth Henry
-- All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:
--     * Redistributions of source code must retain the above copyright
--       notice, this list of conditions and the following disclaimer.
--     * Redistributions in binary form must reproduce the above copyright
--       notice, this list of conditions and the following disclaimer in the
--       documentation and/or other materials provided with the distribution,
--       where applicable (as part of a user interface, debugging port, etc.)
--
-- THIS SOFTWARE IS PROVIDED BY JEREMY SETH HENRY ``AS IS'' AND ANY
-- EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL JEREMY SETH HENRY BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--
-- VHDL Units :  o8_alu16
-- Description:  Provides a mix of common 16-bit math functions to accelerate
--            :   math operations on the Open8 microprocessor core.
--
-- Notes      :  All output registers are updated by writing an instruction to
--            :   offset 0x1F.
--            :  The math unit is busy when the MSB of the status
--            :   register is high, and done/ready when it reads low.
--            :  Almost Equal checks to see if Addend 1 is no more, or less
--            :   addend 2 within the specified tolerance. For example,
--            :   addend_1 = 2 is almost equal to addend_2 = -1 with a
--            :   tolerance of 3, but not a tolerance of 1. Actual function is
--            :   AE = '1' when (A1 <= A2 + T) and (A1 >= A2 - T) else '0'
--            :   This is an inherently signed function.
--            : Signed Overflow/Underflow is logically equivalent to
--            :  S_Sum/Dif(16) xor S_Sum/Dif(15), since the apparent result
--            :  changes sign while the internal sign bit does not. For example
--            :  |8000| will result in (-)8000 due to the way the internal
--            :  logic handles sign extension. Thus, the O bit should be
--            :  checked when performing signed math
--            : Decimal Adjust converts the contents of a register into its BCD
--            :  equivalent. This can be used to get the base 10 representation
--            :  of a value for conversion to ASCII. There are two variants,
--            :  Byte and Word. Note that conversion times are fairly long,
--            :  since we are repeatedly issuing division commands, but it is
--            :  still faster than software emulation.
--            : The Byte conversion only operates on the lower 8 bits, and sets
--            :  the Z and N flags. The N flag is only set when SDAB is used
--            :  and the signed value of the register is negative. The O bit is
--            :  set if the upper byte of the register is non-zero, but does
--            :  not actually result in an calculation error.
--            :  Examples:
--            :  UDAB 0x00FE -> 0x0254, Flags -> 0x0
--            :  SDAB 0x00FE -> 0x0002, Flags -> 0x4
--            : The Word conversion uses the entire 16-bit word, and uses the
--            :  Flags register to hold the Tens of Thousands place. Note that
--            :  the N flag is still used for signed conversions, while it may
--            :  be used as a data bit for unsigned conversions.
--            :  Examples:
--            :  UDAW 0xD431 -> 0x4321, Flags -> 0x5 ('0', MSB, MSB-1, MSB-2)
--            :  SDAW 0xD431 -> 0x1216, Flags -> 0x5 ('0', N  , MSB  , MSB-1)

-- Register Map:
-- Offset  Bitfield Description                        Read/Write
--   0x00   AAAAAAAA Register 0 ( 7:0)                  (RW)
--   0x01   AAAAAAAA Register 0 (15:8)                  (RW)
--   0x02   AAAAAAAA Register 1 ( 7:0)                  (RW)
--   0x03   AAAAAAAA Register 1 (15:8)                  (RW)
--   0x04   AAAAAAAA Register 2 ( 7:0)                  (RW)
--   0x05   AAAAAAAA Register 2 (15:8)                  (RW)
--   0x06   AAAAAAAA Register 3 ( 7:0)                  (RW)
--   0x07   AAAAAAAA Register 3 (15:8)                  (RW)
--   0x08   AAAAAAAA Register 4 ( 7:0)                  (RW)
--   0x09   AAAAAAAA Register 4 (15:8)                  (RW)
--   0x0A   AAAAAAAA Register 5 ( 7:0)                  (RW)
--   0x0B   AAAAAAAA Register 5 (15:8)                  (RW)
--   0x0C   AAAAAAAA Register 6 ( 7:0)                  (RW)
--   0x0D   AAAAAAAA Register 6 (15:8)                  (RW)
--   0x0E   AAAAAAAA Register 7 ( 7:0)                  (RW)
--   0x0F   AAAAAAAA Register 7 (15:8)                  (RW)
--   0x10   -------- Reserved                           (--)
--   0x11   -------- Reserved                           (--)
--   0x12   -------- Reserved                           (--)
--   0x13   -------- Reserved                           (--)
--   0x14   -------- Reserved                           (--)
--   0x15   -------- Reserved                           (--)
--   0x16   -------- Reserved                           (--)
--   0x17   -------- Reserved                           (--)
--   0x18   -------- Reserved                           (--)
--   0x19   -------- Reserved                           (--)
--   0x1A   -------- Reserved                           (--)
--   0x1B   -------- Reserved                           (--)
--   0x1C   AAAAAAAA Tolerance  ( 7:0)                  (RW)
--   0x1D   AAAAAAAA Tolerance  (15:8)                  (RW)
--   0x1E   E---DCBA Status & Flags                     (RW)
--                   A = Zero Flag
--                   B = Carry Flag 
--                   C = Negative Flag
--                   D = Overflow / Error Flag
--                   E = Busy Flag (1 = busy, 0 = idle)
--   0x1F   BBBBBAAA Instruction Register               (RW)
--                   A = Operand (register select)
--                   B = Opcode  (instruction select)
--
-- Instruction Map:
-- OP_T0X  "0000 0xxx" : Transfer R0 to Rx    R0      -> Rx (Sets Z,N)
-- OP_TX0  "0000 1xxx" : Transfer Rx to R0    Rx      -> R0 (Sets Z,N)
-- OP_CLR  "0001 0xxx" : Set Rx to 0          0x00    -> Rx (Sets Z,N)
--
-- OP_IDIV "0001 1xxx" : Integer Division     R0/Rx   -> Q:R0, R:Rx
--
-- OP_UMUL "0010 0xxx" : Unsigned Multiply    R0*Rx   -> R1:R0 (Sets Z)
-- OP_UADD "0010 1xxx" : Unsigned Addition    R0+Rx   -> R0 (Sets N,Z,C)
-- OP_UADC "0011 0xxx" : Unsigned Add w/Carry R0+Rx+C -> R0 (Sets N,Z,C)
-- OP_USUB "0011 1xxx" : Unsigned Subtraction R0-Rx   -> R0 (Sets N,Z,C)
-- OP_USBC "0100 0xxx" : Unsigned Sub w/Carry R0-Rx-C -> R0 (Sets N,Z,C)
-- OP_UCMP "0100 1xxx" : Unsigned Compare     R0-Rx - Sets N,Z,C only
--
-- OP_SMUL "0101 0xxx" : Signed Multiply      R0*Rx   -> R1:R0 (Sets N,Z)
-- OP_SADD "0101 1xxx" : Signed Addition      R0+Rx   -> R0 (Sets N,Z,O)
-- OP_SSUB "0110 0xxx" : Signed Subtraction   R0-Rx   -> R0 (Sets N,Z,O)
-- OP_SCMP "0110 1xxx" : Signed Compare       R0-Rx - Sets N,Z,O only
-- OP_SMAG "0111 0xxx" : Signed Magnitude     |Rx|    -> R0 (Sets Z,O)
-- OP_SNEG "0111 1xxx" : Signed Negation      -Rx     -> R0 (Sets N,Z,O)
--
-- OP_ACMP "1000 0xxx" : Signed Almost Equal (see description)
-- OP_SCRY "1000 1---" : Set the carry bit   (ignores operand)
--
-- OP_UDAB "1001 0xxx" : Decimal Adjust Byte (see description)
-- OP_SDAB "1001 1xxx" : Decimal Adjust Byte (see description)
-- OP_UDAW "1010 0xxx" : Decimal Adjust Word (see description)
-- OP_SDAW "1010 1xxx" : Decimal Adjust Word (see description)

-- OP_RSVD "1011 0---" : Reserved

-- OP_BSWP "1011 1xxx" : Byte Swap (Swaps upper and lower bytes)

-- OP_BOR  "1100 0xxx" : Bitwise Logical OR   Rx or  R0 -> R0
-- OP_BAND "1100 1xxx" : Bitwise Logical AND  Rx and R0 -> R0
-- OP_BXOR "1101 0xxx" : Bitwise Logical XOR  Rx xor R0 -> R0
--
-- OP_BINV "1101 1xxx" : Bitwise logical NOT #Rx      -> Rx
-- OP_BSFL "1110 0xxx" : Logical Shift Left   Rx<<1,0 -> Rx
-- OP_BROL "1110 1xxx" : Logical Rotate Left  Rx<<1,C -> Rx,C
-- OP_BSFR "1111 0xxx" : Logical Shift Right  0,Rx>>1 -> Rx
-- OP_BROR "1111 1xxx" : Logical Rotate Right C,Rx>>1 -> Rx,C

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;

library work;
  use work.open8_pkg.all;

entity o8_alu16 is
generic(
  Reset_Level           : std_logic;
  Address               : ADDRESS_TYPE
);
port(
  Clock                 : in  std_logic;
  Reset                 : in  std_logic;
  --
  Bus_Address           : in  ADDRESS_TYPE;
  Wr_Enable             : in  std_logic;
  Wr_Data               : in  DATA_TYPE;
  Rd_Enable             : in  std_logic;
  Rd_Data               : out DATA_TYPE;
  Interrupt             : out std_logic
);
end entity;

architecture behave of o8_alu16 is

  -------------------------------------------------------------------
  -- Opcode Definitions (should match the table above)
  -- Register Manipulation
  constant OP_T0X       : std_logic_vector(4 downto 0) := "00000";
  constant OP_TX0       : std_logic_vector(4 downto 0) := "00001";
  constant OP_CLR       : std_logic_vector(4 downto 0) := "00010";

  -- Integer Division
  constant OP_IDIV      : std_logic_vector(4 downto 0) := "00011";

  -- Unsigned Math Operations
  constant OP_UMUL      : std_logic_vector(4 downto 0) := "00100";
  constant OP_UADD      : std_logic_vector(4 downto 0) := "00101";
  constant OP_UADC      : std_logic_vector(4 downto 0) := "00110";
  constant OP_USUB      : std_logic_vector(4 downto 0) := "00111";
  constant OP_USBC      : std_logic_vector(4 downto 0) := "01000";
  constant OP_UCMP      : std_logic_vector(4 downto 0) := "01001";

  -- Signed Math Operations
  constant OP_SMUL      : std_logic_vector(4 downto 0) := "01010";
  constant OP_SADD      : std_logic_vector(4 downto 0) := "01011";
  constant OP_SSUB      : std_logic_vector(4 downto 0) := "01100";
  constant OP_SCMP      : std_logic_vector(4 downto 0) := "01101";
  constant OP_SMAG      : std_logic_vector(4 downto 0) := "01110";
  constant OP_SNEG      : std_logic_vector(4 downto 0) := "01111";

  -- Signed Almost Equal
  constant OP_ACMP      : std_logic_vector(4 downto 0) := "10000";

  -- Carry Flag set/clear
  constant OP_SCRY      : std_logic_vector(4 downto 0) := "10001";

  -- (Un)Signed Decimal Adjust Byte
  constant OP_UDAB      : std_logic_vector(4 downto 0) := "10010";
  constant OP_SDAB      : std_logic_vector(4 downto 0) := "10011";

  -- (Un)Signed Decimal Adjust Word
  constant OP_UDAW      : std_logic_vector(4 downto 0) := "10100";
  constant OP_SDAW      : std_logic_vector(4 downto 0) := "10101";

  -- Reserved for future use
  constant OP_RSVD      : std_logic_vector(4 downto 0) := "10110";
  
  -- Byte Swap ( U <> L )
  constant OP_BSWP      : std_logic_vector(4 downto 0) := "10111";

  -- Bitwise Boolean Operations (two operand)
  constant OP_BOR       : std_logic_vector(4 downto 0) := "11000";
  constant OP_BAND      : std_logic_vector(4 downto 0) := "11001";
  constant OP_BXOR      : std_logic_vector(4 downto 0) := "11010";

  -- In-place Bitwise Boolean Operations (single operand)
  constant OP_BINV      : std_logic_vector(4 downto 0) := "11011";
  constant OP_BSFL      : std_logic_vector(4 downto 0) := "11100";
  constant OP_BROL      : std_logic_vector(4 downto 0) := "11101";
  constant OP_BSFR      : std_logic_vector(4 downto 0) := "11110";
  constant OP_BROR      : std_logic_vector(4 downto 0) := "11111";
  -------------------------------------------------------------------

  constant User_Addr    : std_logic_vector(15 downto 5):= Address(15 downto 5);
  alias Comp_Addr       is Bus_Address(15 downto 5);
  signal Reg_Addr       : std_logic_vector(4 downto 0);

  signal Addr_Match     : std_logic;
  signal Wr_En          : std_logic;
  signal Wr_Data_q      : DATA_TYPE;
  signal Rd_En          : std_logic;

  type REG_ARRAY is array( 0 to 7 ) of std_logic_vector(15 downto 0);
  signal regfile        : REG_ARRAY;

  signal Start          : std_logic;
  signal Opcode         : std_logic_vector(4 downto 0);
  signal Operand_Sel    : std_logic_vector(2 downto 0);

  signal Tolerance      : std_logic_vector(15 downto 0);
  signal High_Tol       : signed(16 downto 0);
  signal Low_Tol        : signed(16 downto 0);
  signal Almost_Equal   : std_logic;

  constant FLAG_Z       : integer := 0;
  constant FLAG_C       : integer := 1;
  constant FLAG_N       : integer := 2;
  constant FLAG_O       : integer := 3;

  signal Flags          : std_logic_vector(3 downto 0);

  type ALU_STATES is ( IDLE, LOAD, EXECUTE,   IDIV_INIT, IDIV_WAIT,
                       DAW_INIT,   DAB_INIT,  DAA_WAIT1, DAA_STEP2,
                       DAA_WAIT2,  DAA_STEP3, DAA_WAIT3, DAA_STEP4,
                       STORE );
  signal alu_ctrl       : ALU_STATES;

  signal Busy           : std_logic;
  signal Busy_q         : std_logic;

  signal Operand_1      : std_logic_vector(15 downto 0);
  signal Operand_2      : std_logic_vector(15 downto 0);

  alias  Dividend       is Operand_1;
  alias  Divisor        is Operand_2;

  alias  u_Operand_1    is Operand_1;
  alias  u_Operand_2    is Operand_2;

  alias  u_Addend_1     is Operand_1;
  alias  u_Addend_2     is Operand_2;

  signal s_Operand_1    : signed(16 downto 0);
  signal s_Operand_2    : signed(16 downto 0);

  alias  s_Addend_1     is S_Operand_1;
  alias  s_Addend_2     is S_Operand_2;

  signal u_accum        : std_logic_vector(16 downto 0);
  alias  u_data         is u_accum(15 downto 0);
  alias  u_sign         is u_accum(15);
  alias  u_carry        is u_accum(16);

  signal u_prod         : std_logic_vector(31 downto 0);

  signal s_accum        : signed(16 downto 0);
  alias  s_data         is s_accum(15 downto 0);
  alias  s_sign         is s_accum(15);
  alias  s_ovf          is s_accum(16);

  signal s_prod         : signed(33 downto 0);

  signal IDIV_Start     : std_logic;
  signal IDIV_Busy      : std_logic;

  constant N            : integer := 16; -- Width of Operands

  signal q              : std_logic_vector(N*2-1 downto 0);
  signal diff           : std_logic_vector(N downto 0);
  signal count          : integer range 0 to N + 1;

  signal Quotient_i     : std_logic_vector(15 downto 0);
  signal Quotient       : std_logic_vector(15 downto 0);

  signal Remainder_i    : std_logic_vector(15 downto 0);
  signal Remainder      : std_logic_vector(15 downto 0);

  signal DAA_intreg     : std_logic_vector(15 downto 0);
  signal DAA_mode       : std_logic;
  signal DAA_sign       : std_logic;
  signal DAA_p4         : std_logic_vector(3 downto 0);
  signal DAA_p3         : std_logic_vector(3 downto 0);
  signal DAA_p2         : std_logic_vector(3 downto 0);
  alias  DAA_p1         is Quotient(3 downto 0);
  alias  DAA_p0         is Remainder(3 downto 0);
  signal DAA_result     : std_logic_vector(19 downto 0);

begin

  Addr_Match            <= '1' when Comp_Addr = User_Addr else '0';

  -- Sign-extend the base operands to created operands for signed math
  S_Operand_1           <= signed(Operand_1(15) & Operand_1);
  S_Operand_2           <= signed(Operand_2(15) & Operand_2);

  -- Compute the tolerance bounds for the Almost Equal function
  High_Tol              <= S_Operand_2 + signed('0' & Tolerance);
  Low_Tol               <= S_Operand_2 - signed('0' & Tolerance);

  -- Combinational logic for the Decimal Adjust logic
  DAA_result            <= DAA_p4 & DAA_p3 & DAA_p2 & DAA_p1 & DAA_p0;

  -- Combinational logic for the division logic
  diff                  <= ('0' & Q(N*2-2 downto N-1)) - ('0' & Divisor);
  Quotient_i            <= q(N-1 downto 0);
  Remainder_i           <= q(N*2-1 downto N);

  ALU_proc: process( Clock, Reset )
    variable Reg_Sel    : integer;
    variable Oper_Sel   : integer;
  begin
    if( Reset = Reset_Level )then
      Wr_En             <= '0';
      Wr_Data_q         <= (others => '0');
      Rd_En             <= '0';
      Rd_Data           <= (others => '0');
      Reg_Addr          <= (others => '0');
      Opcode            <= (others => '0');
      Operand_Sel       <= (others => '0');
      Tolerance         <= (others => '0');
      Start             <= '0';
      Busy_q            <= '0';
      Interrupt         <= '0';
      for i in 0 to 7 loop
        regfile(i)      <= (others => '0');
      end loop;
      alu_ctrl          <= IDLE;
      Operand_1         <= (others => '0');
      Operand_2         <= (others => '0');
      u_accum           <= (others => '0');
      u_prod            <= (others => '0');
      s_accum           <= (others => '0');
      s_prod            <= (others => '0');
      Quotient          <= (others => '0');
      Remainder         <= (others => '0');
      Flags             <= (others => '0');
      Almost_Equal      <= '0';
      Busy              <= '0';
      DAA_mode          <= '0';
      DAA_sign          <= '0';
      DAA_intreg        <= (others => '0');
      DAA_p4            <= (others => '0');
      DAA_p3            <= (others => '0');
      DAA_p2            <= (others => '0');
      IDIV_Start        <= '0';
      q                 <= (others => '0');
      count             <= N;
      IDIV_Busy         <= '0';
    elsif( rising_edge(Clock) )then
      -- For convenience, convert these to integers and assign them to
      --  variables
      Reg_Sel           := conv_integer(Reg_Addr(3 downto 1));
      Oper_Sel          := conv_integer(Operand_Sel);

      Wr_En             <= Addr_Match and Wr_Enable;
      Wr_Data_q         <= Wr_Data;
      Reg_Addr          <= Bus_Address(4 downto 0);

      Start             <= '0';
      if( Wr_En = '1' )then
        case( Reg_Addr )is
          -- Even addresses go to the lower byte of the register
          when "00000" | "00010" | "00100" | "00110" |
               "01000" | "01010" | "01100" | "01110" =>
            regfile(Reg_Sel)(7 downto 0) <= Wr_Data_q;

          -- Odd addresses go to the upper byte of the register
          when "00001" | "00011" | "00101" | "00111" |
               "01001" | "01011" | "01101" | "01111" =>
            regfile(Reg_Sel)(15 downto 8)<= Wr_Data_q;

          when "11100" => -- 0x1C -> Tolerance.l
            Tolerance(7 downto 0) <= Wr_Data_q;

          when "11101" => -- 0x1D -> Tolerance.u
            Tolerance(15 downto 8) <= Wr_Data_q;

          when "11110" => -- 0x1E -> Status register
            null;

          when "11111" => -- 0x1F -> Control register
            Start       <= '1';
            Opcode      <= Wr_Data_q(7 downto 3);
            Operand_Sel <= Wr_Data_q(2 downto 0);

          when others => null;
        end case;
      end if;

      Rd_Data           <= (others => '0');
      Rd_En             <= Addr_Match and Rd_Enable;

      if( Rd_En = '1' )then
        case( Reg_Addr )is
          when "00000" | "00010" | "00100" | "00110" |
               "01000" | "01010" | "01100" | "01110" =>
            Rd_Data  <= regfile(Reg_Sel)(7 downto 0);
          when "00001" | "00011" | "00101" | "00111" |
               "01001" | "01011" | "01101" | "01111" =>
            Rd_Data  <= regfile(Reg_Sel)(15 downto 8);
          when "11100" => -- 0x1C -> Tolerance.l
            Rd_Data  <= Tolerance(7 downto 0);
          when "11101" => -- 0x1D -> Tolerance.u
            Rd_Data  <= Tolerance(15 downto 8);
          when "11110" => -- 0x1E -> Flags & Status register
            Rd_Data  <= Busy & "000" & Flags;
          when "11111" => -- 0x1F -> Control register
            Rd_Data  <= Opcode & Operand_Sel;
          when others => null;
        end case;
      end if;

      Busy              <= '1';
      IDIV_Start        <= '0';
      case( alu_ctrl )is
        when IDLE =>
          Busy          <= '0';
          if( Start = '1' )then
            alu_ctrl    <= LOAD;
          end if;

        -- Load the operands from the register file. We also check for specific
        --  opcodes to set the DAA mode (signed vs unsigned). This is the only
        --  place where we READ the register file outside of the bus interface
        when LOAD =>
          Operand_1     <= regfile(0);
          Operand_2     <= regfile(Oper_Sel);
          DAA_mode      <= '0';
          if( Opcode = OP_SDAW or Opcode = OP_SDAB )then
            DAA_mode    <= '1';
          end if;
          alu_ctrl      <= EXECUTE;

        -- Now that the operands are loaded, we can execute the actual math
        --  operations. We do it with separate operand registers to pipeline
        --  the logic.
        when EXECUTE =>
          alu_ctrl      <= STORE;
          case( Opcode)is
            when OP_T0X =>
              u_accum   <= '0' & Operand_1;

            when OP_TX0 =>
              u_accum   <= '0' & Operand_2;

            when OP_CLR | OP_SCRY =>
              u_accum   <= (others => '0');

            when OP_BSWP =>
              u_accum   <= '0' &
                           Operand_2(7 downto 0) &
                           Operand_2(15 downto 8);
          
            when OP_SMAG =>
              s_accum   <= S_Operand_2;
              if( S_Operand_2 < 0)then
                s_accum <= -S_Operand_2;
              end if;

            when OP_SNEG =>
              s_accum   <= -S_Operand_2;

            when OP_SMUL =>
              s_prod    <= S_Operand_1 * S_Operand_2;

            when OP_UMUL =>
              u_prod    <= U_Operand_1 * U_Operand_2;

            when OP_SADD =>
              s_accum   <= S_Addend_1  + S_Addend_2;

            when OP_UADD =>
              u_accum   <= ('0' & Operand_1) + ('0' & Operand_2);

            when OP_UADC =>
              u_accum   <= ('0' & Operand_1) + ('0' & Operand_2) + Flags(FLAG_C);

            when OP_SSUB | OP_SCMP =>
              s_accum   <= S_Addend_1  - S_Addend_2;

            when OP_USUB | OP_UCMP =>
              u_accum   <= ('0' & U_Addend_1)  - ('0' & U_Addend_2);

            when OP_USBC =>
              u_accum   <= ('0' & U_Addend_1)  - ('0' & U_Addend_2) - Flags(FLAG_C);

            when OP_ACMP =>
              -- Perform the function
              -- AE = '1' when (A1 <= A2 + T) and (A1 >= A2 - T) else '0'
              Almost_Equal    <= '0';
              if( (S_Addend_1 <= High_Tol) and
                  (S_Addend_1 >= Low_Tol) )then
                Almost_Equal  <= '1';
              end if;

            when OP_BINV =>
              u_accum    <= '0' & (not U_Operand_1);

            when OP_BSFL =>
              u_accum    <= U_Operand_1 & '0';

            when OP_BROL =>
              u_accum    <= U_Operand_1 & Flags(FLAG_C);

            when OP_BSFR =>
              u_accum    <= "00" & U_Operand_1(15 downto 1);

            when OP_BROR =>
              u_accum    <= U_Operand_1(0) & Flags(FLAG_C) &
                            U_Operand_1(15 downto 1);

            when OP_BOR  =>
              u_accum    <= '0' & (U_Operand_1 or U_Operand_2);

            when OP_BAND =>
              u_accum    <= '0' & (U_Operand_1 and U_Operand_2);

            when OP_BXOR =>
              u_accum    <= '0' & (U_Operand_1 xor U_Operand_2);

         -- Division unit has a longer latency, so we need to wait for its busy
         --  signal to return low before storing results. Trigger the engine,
         --  and then jump to the wait state for it to finish
            when OP_IDIV =>
              IDIV_Start<= '1';
              alu_ctrl  <= IDIV_INIT;

        -- Decimal Adjust Word initialization
        --  Stores the sign bit for later use setting the N flag
        --  Assigns Operand_1 to register as-is
        --  If the sign bit is set, do a 2's complement of the register
            when OP_UDAW | OP_SDAW =>
              IDIV_Start<= '1';
              DAA_sign  <= Operand_2(15);
              Operand_1 <= Operand_2;
              if( (Operand_2(15) and DAA_mode) = '1' )then
                Operand_1 <= (not Operand_2) + 1;
              end if;
              Operand_2 <= x"2710";
              alu_ctrl  <= DAW_INIT;

        -- Decimal Adjust Byte initialization
        --  Stores the sign bit for later use setting the N flag
        --  Assigns Operand_1 to the lower byte of the register
        --  If the sign bit is set, do a 2's complement of the register
            when OP_UDAB | OP_SDAB =>
              IDIV_Start<= '1';
              DAA_p4    <= (others => '0');
              DAA_p3    <= (others => '0');
              DAA_sign  <= Operand_2(7);
              Operand_1 <= x"00" & Operand_2(7 downto 0);
              if( (Operand_2(7) and DAA_mode) = '1' )then
                Operand_1 <= ((not Operand_2) + 1) and x"00FF";
              end if;
              Operand_2 <= x"0064";
              alu_ctrl  <= DAB_INIT;

            when others => null;
          end case;

        -- These three states look superfluous, but simplify the state machine
        --  logic enough to improve performance. Leave them.
        when IDIV_INIT =>
          if( IDIV_Busy = '1' )then
            alu_ctrl    <= IDIV_WAIT;
          end if;

        when DAW_INIT =>
          if( IDIV_Busy = '1' )then
            alu_ctrl    <= DAA_WAIT1;
          end if;

        when DAB_INIT =>
          if( IDIV_Busy = '1' )then
            alu_ctrl    <= DAA_WAIT3;
          end if;

        when DAA_WAIT1 =>
          if( IDIV_Busy = '0' )then
            DAA_p4      <= Quotient_i(3 downto 0);
            DAA_intreg  <= Remainder_i;
            alu_ctrl    <= DAA_STEP2;
          end if;

        when DAA_STEP2 =>
          Operand_1     <= DAA_intreg;
          Operand_2     <= x"03E8";
          IDIV_Start    <= '1';
          if( IDIV_Busy = '1' )then
            alu_ctrl    <= DAA_WAIT2;
          end if;

        when DAA_WAIT2 =>
          if( IDIV_Busy = '0' )then
            DAA_p3      <= Quotient_i(3 downto 0);
            DAA_intreg  <= Remainder_i;
            alu_ctrl    <= DAA_STEP3;
          end if;

        when DAA_STEP3 =>
          Operand_1     <= DAA_intreg;
          Operand_2     <= x"0064";
          IDIV_Start    <= '1';
          if( IDIV_Busy = '1' )then
            alu_ctrl    <= DAA_WAIT3;
          end if;

        when DAA_WAIT3 =>
          if( IDIV_Busy = '0' )then
            DAA_p2      <= Quotient_i(3 downto 0);
            DAA_intreg  <= Remainder_i;
            alu_ctrl    <= DAA_STEP4;
          end if;

        when DAA_STEP4 =>
          Operand_1     <= DAA_intreg;
          Operand_2     <= x"000A";
          IDIV_Start    <= '1';
          if( IDIV_Busy = '1' )then
            alu_ctrl    <= IDIV_WAIT;
          end if;

        when IDIV_WAIT =>
          if( IDIV_Busy = '0' )then
            Quotient    <= Quotient_i;
            Remainder   <= Remainder_i;
            alu_ctrl    <= STORE;
          end if;

        -- All ALU writes to the register file go through here. This is also
        --  where the flag register gets updated. This should be the only
        --  place where the register file gets WRITTEN outside of the bus
        --  interface.
        when STORE =>
          Flags          <= (others => '0');
          case( Opcode)is
            when OP_T0X | OP_CLR | OP_BSWP =>
              regfile(Oper_Sel) <= u_data;
              Flags(FLAG_Z) <= nor_reduce(u_data);
              Flags(FLAG_N) <= u_sign;

            when OP_TX0  =>
              regfile(0) <= u_data;
              Flags(FLAG_Z) <= nor_reduce(u_data);
              Flags(FLAG_N) <= u_sign;

            when OP_SCRY =>
              Flags(FLAG_C) <= '0';
              if( Oper_Sel > 0 )then
                Flags(FLAG_C)<= '1';
              end if;

            when OP_IDIV =>
              regfile(0) <= Quotient;
              regfile(Oper_Sel) <= Remainder;
              Flags(FLAG_Z) <= nor_reduce(Quotient);

            when OP_SMAG | OP_SNEG | OP_SADD | OP_SSUB =>
              regfile(0) <= std_logic_vector(s_data);
              Flags(FLAG_N) <= s_sign;
              Flags(FLAG_Z) <= nor_reduce(std_logic_vector(s_data));
              Flags(FLAG_O) <= s_ovf xor s_sign;

            when OP_SMUL =>
              regfile(0) <= std_logic_vector(s_prod(15 downto 0));
              regfile(1) <= std_logic_vector(s_prod(31 downto 16));
              Flags(FLAG_N) <= s_prod(33) or s_prod(32);
              Flags(FLAG_Z) <= nor_reduce(std_logic_vector(s_prod));

            when OP_UMUL =>
              regfile(0) <= u_prod(15 downto 0);
              regfile(1) <= u_prod(31 downto 16);
              Flags(FLAG_N) <= u_prod(31);
              Flags(FLAG_Z) <= nor_reduce(u_prod);

            when OP_UADD | OP_USUB =>
              regfile(0) <= u_data;
              Flags(FLAG_Z) <= nor_reduce(u_data);
              Flags(FLAG_N) <= u_sign;
              Flags(FLAG_C) <= u_carry;

            when OP_SCMP =>
              Flags(FLAG_N) <= s_ovf;
              Flags(FLAG_Z) <= nor_reduce(std_logic_vector(s_data));
              Flags(FLAG_O) <= s_accum(16) xor s_accum(15);

            when OP_UCMP =>
              Flags(FLAG_Z) <= nor_reduce(u_data);
              Flags(FLAG_C) <= u_carry;

            when OP_ACMP =>
              Flags(FLAG_Z) <= Almost_Equal;

            when OP_UDAB | OP_SDAB =>
              regfile(Oper_Sel) <= DAA_result(15 downto 0);
              Flags(FLAG_Z) <= nor_reduce(DAA_result);
              Flags(FLAG_N) <= DAA_sign;

            when OP_UDAW | OP_SDAW =>
              regfile(Oper_Sel) <= DAA_result(15 downto 0);
              Flags(3 downto 0) <= DAA_result(19 downto 16);
              if( DAA_mode = '1' )then
                Flags(FLAG_N) <= DAA_sign;
              end if;

            when OP_BOR  | OP_BAND | OP_BXOR =>
              regfile(0) <= u_data;
              Flags(FLAG_Z) <= nor_reduce(u_data);
              Flags(FLAG_N) <= u_sign;

            when OP_BINV =>
              regfile(Oper_Sel) <= u_data;
              Flags(FLAG_Z) <= nor_reduce(u_data);
              Flags(FLAG_N) <= u_sign;

            when OP_BSFL | OP_BROL | OP_BSFR | OP_BROR =>
              regfile(Oper_Sel) <= u_data;
              Flags(FLAG_Z) <= nor_reduce(u_data);
              Flags(FLAG_N) <= u_sign;
              Flags(FLAG_C) <= u_carry;

            when others => null;
          end case;
          alu_ctrl      <= IDLE;

        when others =>
          null;

      end case;

      IDIV_Busy         <= '0';
      if( IDIV_Start = '1' )then
        IDIV_Busy       <= '1';
        count           <= 0;
        q               <= conv_std_logic_vector(0,N) & Dividend;
      elsif( count < N )then
        IDIV_Busy       <= '1';
        count           <= count + 1;
        q               <= diff(N-1 downto 0) & q(N-2 downto 0) & '1';
        if( diff(N) = '1' )then
          q             <= q(N*2-2 downto 0) & '0';
        end if;
      end if;

      -- Fire on the falling edge of Busy
      Busy_q            <= Busy;
      Interrupt         <= not Busy and Busy_q;

    end if;
  end process;

end architecture;
