-- Copyright (c)2006,2013 Jeremy Seth Henry
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
-- VHDL Units :  Open8_CPU
-- Description:  VHDL model of a RISC 8-bit processor core loosely based on the
--            :   V8/ARC uRISC instruction set. Requires Open8_pkg.vhd
--            :
-- Notes      :  Generic definitions
--            :
--            :  Program_Start_Addr - Determines the initial value of the
--            :   program counter.
--            :
--            :  ISR_Start_Addr - determines the location of the interrupt
--            :   service vector table. There are 8 service vectors, or 16
--            :   bytes, which must be allocated to either ROM or RAM.
--            :
--            :  Stack_Start_Address - determines the initial (reset) value of
--            :   the stack pointer. Also used for the RSP instruction if
--            :   Allow_Stack_Address_Move is 0.
--            :
--            :  Allow_Stack_Address_Move - When set to 1, allows the RSP to be
--            :   programmed via thet RSP instruction. If enabled, the contents
--            :   of R1:R0 are used to initialize the stack pointer.
--            :
--            :  The Enable_Auto_Increment generic can be used to modify the
--            :   indexed instructions such that specifying an odd register
--            :   will use the next lower register pair, post-incrementing the
--            :   value in that pair. IOW, specifying STX R1 will instead
--            :   result in STX R0++, or R0 = {R1:R0}; {R1:R0} + 1
--            :
--            :  BRK_Implements_WAI modifies the BRK instruction such that it
--            :   triggers the wait for interrupt state, but without triggering
--            :   a soft interrupt in lieu of its normal behavior, which is to
--            :   insert several dead clock cycles - essentially a long NOP
--            :
--            :  Enable_NMI overrides the mask bit for interrupt 0, creating a
--            :   non-maskable interrupt at the highest priority.
--            :
--            :  Default_Interrupt_Mask - Determines the intial value of the
--            :   interrupt mask. To remain true to the original core, which
--            :   had no interrupt mask, this should be set to x"FF". Otherwise
--            :   it can be initialized to any value. Enable_NMI will logically
--            :   force the LSB high.
--            : 
--            :  Reset_Level - Determines whether the processor registers reset
--            :   on a high or low level from higher logic.
--            :
--            : Architecture notes
--            :  This model deviates from the original ISA in a few important
--            :   ways.
--            :
--            :  First, there is only one set of registers. Interrupt service
--            :   routines must explicitely preserve context since the the
--            :   hardware doesn't. This was done to decrease size and code
--            :   complexity. Older code that assumes this behavior will not
--            :   execute correctly on this processor model.
--            :
--            :  Second, this model adds an additional pipeline stage between
--            :   the instruction decoder and the ALU. Unfortunately, this
--            :   means that the instruction stream has to be restarted after
--            :   any math instruction is executed, implying that any ALU
--            :   instruction now has a latency of 2 instead of 0. The
--            :   advantage is that the maximum frequency has gone up
--            :   significantly, as the ALU code is vastly more efficient.
--            :   As an aside, this now means that all math instructions,
--            :   including MUL (see below) and UPP have the same instruction
--            :   latency.
--            :
--            :  Third, the original ISA, also a soft core, had two reserved
--            :   instructions, USR and USR2. These have been implemented as
--            :   DBNZ, and MUL respectively.
--            :
--            :  DBNZ decrements the specified register and branches if the
--            :   result is non-zero. The instruction effectively executes a
--            :   DEC Rn instruction prior to branching, so the same flags will
--            :   be set.
--            :
--            :  MUL places the result of R0 * Rn into R1:R0. Instruction
--            :   latency is identical to other ALU instructions. Only the Z
--            :   flag is set, since there is no defined overflow or "negative
--            :   16-bit values"
--            :
--            :  Fourth, indexed load/store instructions now have an (optional)
--            :   ability to post-increment their index registers. If enabled,
--            :   using an odd operand for LDO,LDX, STO, STX will cause the
--            :   register pair to be incremented after the storage access.
--            :
--            :  Fifth, the RSP instruction has been (optionally) altered to
--            :   allow the stack pointer to be sourced from R1:R0.
--            :
--            :  Sixth, the BRK instruction can optionally implement a WAI,
--            :   which is the same as the INT instruction without the soft
--            :   interrupt, as a way to put the processor to "sleep" until the
--            :   next interrupt.
--            :
--            :  Seventh, the original CPU model had 8 non-maskable interrupts
--            :   with priority. This model has the same 8 interrupts, but
--            :   allows software to mask them (with an additional option to 
--            :   override the highest priority interrupt, making it the NMI.)
--            :   The interrupt code will retain memory of lower priority
--            :   interrupts, and execute them as it can.
--            :
--            :  Lastly, previous unmapped instructions in the OP_STK opcode
--            :   were repurposed to support a new interrupt mask.
--            :   SMSK and GMSK transfer the contents of R0 (accumulator)
--            :   to/from the interrupt mask register. SMSK is immediate, while
--            :   GMSK has the same overhead as a math instruction.

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
  use ieee.std_logic_misc.all;

library work;
use work.Open8_pkg.all;

entity Open8_CPU is
  generic(
    Program_Start_Addr       : ADDRESS_TYPE := x"0090"; -- Initial PC location
    ISR_Start_Addr           : ADDRESS_TYPE := x"0080"; -- Bottom of ISR vec's
    Stack_Start_Addr         : ADDRESS_TYPE := x"007F"; -- Top of Stack
    Allow_Stack_Address_Move : boolean      := false;   -- Use Normal v8 RSP
    Enable_Auto_Increment    : boolean      := false;   -- Modify indexed instr
    BRK_Implements_WAI       : boolean      := false;   -- BRK -> Wait for Int
    Enable_NMI               : boolean      := true;    -- force mask for int 0
    Default_Interrupt_Mask   : DATA_TYPE    := x"FF";   -- Enable all Ints
    Reset_Level              : std_logic    := '0' );   -- Active reset level
  port(
    Clock                    : in  std_logic;
    Reset                    : in  std_logic;
    Interrupts               : in  INTERRUPT_BUNDLE;
    --
    Address                  : out ADDRESS_TYPE;
    Rd_Data                  : in  DATA_TYPE;
    Rd_Enable                : out std_logic;
    Wr_Data                  : out DATA_TYPE;
    Wr_Enable                : out std_logic );
end entity;

architecture behave of Open8_CPU is

  subtype OPCODE_TYPE  is std_logic_vector(4 downto 0);
  subtype SUBOP_TYPE   is std_logic_vector(2 downto 0);

  -- All opcodes should be identical to the opcode used by the assembler
  -- In this case, they match the original V8/ARC uRISC ISA
  constant OP_INC            : OPCODE_TYPE := "00000";
  constant OP_ADC            : OPCODE_TYPE := "00001";
  constant OP_TX0            : OPCODE_TYPE := "00010";
  constant OP_OR             : OPCODE_TYPE := "00011";
  constant OP_AND            : OPCODE_TYPE := "00100";
  constant OP_XOR            : OPCODE_TYPE := "00101";
  constant OP_ROL            : OPCODE_TYPE := "00110";
  constant OP_ROR            : OPCODE_TYPE := "00111";
  constant OP_DEC            : OPCODE_TYPE := "01000";
  constant OP_SBC            : OPCODE_TYPE := "01001";
  constant OP_ADD            : OPCODE_TYPE := "01010";
  constant OP_STP            : OPCODE_TYPE := "01011";
  constant OP_BTT            : OPCODE_TYPE := "01100";
  constant OP_CLP            : OPCODE_TYPE := "01101";
  constant OP_T0X            : OPCODE_TYPE := "01110";
  constant OP_CMP            : OPCODE_TYPE := "01111";
  constant OP_PSH            : OPCODE_TYPE := "10000";
  constant OP_POP            : OPCODE_TYPE := "10001";
  constant OP_BR0            : OPCODE_TYPE := "10010";
  constant OP_BR1            : OPCODE_TYPE := "10011";
  constant OP_DBNZ           : OPCODE_TYPE := "10100";
  constant OP_INT            : OPCODE_TYPE := "10101";
  constant OP_MUL            : OPCODE_TYPE := "10110";
  constant OP_STK            : OPCODE_TYPE := "10111";
  constant OP_UPP            : OPCODE_TYPE := "11000";
  constant OP_STA            : OPCODE_TYPE := "11001";
  constant OP_STX            : OPCODE_TYPE := "11010";
  constant OP_STO            : OPCODE_TYPE := "11011";
  constant OP_LDI            : OPCODE_TYPE := "11100";
  constant OP_LDA            : OPCODE_TYPE := "11101";
  constant OP_LDX            : OPCODE_TYPE := "11110";
  constant OP_LDO            : OPCODE_TYPE := "11111";

  -- OP_STK uses the lower 3 bits to further refine the instruction by
  --  repurposing the source register field. These "sub opcodes" are
  --  take the place of the register select for the OP_STK opcode
  constant SOP_RSP           : SUBOP_TYPE := "000";
  constant SOP_RTS           : SUBOP_TYPE := "001";
  constant SOP_RTI           : SUBOP_TYPE := "010";
  constant SOP_BRK           : SUBOP_TYPE := "011";
  constant SOP_JMP           : SUBOP_TYPE := "100";
  constant SOP_SMSK          : SUBOP_TYPE := "101";
  constant SOP_GMSK          : SUBOP_TYPE := "110";
  constant SOP_JSR           : SUBOP_TYPE := "111";

  type CPU_STATES is (
      -- Instruction fetch & Decode
    PIPE_FILL_0, PIPE_FILL_1, PIPE_FILL_2, INSTR_DECODE,
    -- Branching
    BRN_C1, DBNZ_C1, DBNZ_C2, JMP_C1, JMP_C2,
    -- Loads
    LDA_C1, LDA_C2, LDA_C3, LDA_C4, LDI_C1,
    LDO_C1, LDX_C1, LDX_C2, LDX_C3, LDX_C4,
    -- Stores
    STA_C1, STA_C2, STO_C1, STO_C2, STX_C1, STX_C2,
    -- math
    MATH_C1, GMSK_C1, MUL_C1, UPP_C1,
    -- Stack
    PSH_C1, POP_C1, POP_C2, POP_C3, POP_C4,
    -- Subroutines & Interrupts
    WAIT_FOR_INT, ISR_C1, ISR_C2, ISR_C3, JSR_C1, JSR_C2,
    RTS_C1, RTS_C2, RTS_C3, RTS_C4, RTS_C5, RTI_C6,
    -- Debugging
    BRK_C1 );

  -- To simplify the logic, the first 16 of these should exactly match their
  --  corresponding Opcodes. This allows the state logic to simply pass the 
  --  opcode field to the ALU for most math operations.
  constant ALU_INC           : OPCODE_TYPE := "00000"; -- x"00"
  constant ALU_UPP1          : OPCODE_TYPE := "00000"; -- Alias of ALU_INC
  constant ALU_ADC           : OPCODE_TYPE := "00001"; -- x"01"
  constant ALU_TX0           : OPCODE_TYPE := "00010"; -- x"02"
  constant ALU_OR            : OPCODE_TYPE := "00011"; -- x"03"
  constant ALU_AND           : OPCODE_TYPE := "00100"; -- x"04"
  constant ALU_XOR           : OPCODE_TYPE := "00101"; -- x"05"
  constant ALU_ROL           : OPCODE_TYPE := "00110"; -- x"06"
  constant ALU_ROR           : OPCODE_TYPE := "00111"; -- x"07"
  constant ALU_DEC           : OPCODE_TYPE := "01000"; -- x"08"
  constant ALU_SBC           : OPCODE_TYPE := "01001"; -- x"09"
  constant ALU_ADD           : OPCODE_TYPE := "01010"; -- x"0A"
  constant ALU_STP           : OPCODE_TYPE := "01011"; -- x"0B"
  constant ALU_BTT           : OPCODE_TYPE := "01100"; -- x"0C"
  constant ALU_CLP           : OPCODE_TYPE := "01101"; -- x"0D"
  constant ALU_T0X           : OPCODE_TYPE := "01110"; -- x"0E"
  constant ALU_CMP           : OPCODE_TYPE := "01111"; -- x"0F"
  constant ALU_IDLE          : OPCODE_TYPE := "10000"; -- x"10"
  constant ALU_UPP2          : OPCODE_TYPE := "10010"; -- x"11"
  constant ALU_RFLG          : OPCODE_TYPE := "10011"; -- x"12"
  constant ALU_MUL           : OPCODE_TYPE := "10110"; -- x"16"
  constant ALU_LDI           : OPCODE_TYPE := "11100"; -- x"1C"

  constant FL_ZERO           : integer := 0;
  constant FL_CARRY          : integer := 1;
  constant FL_NEG            : integer := 2;
  constant FL_INT_EN         : integer := 3;
  constant FL_GP1            : integer := 4;
  constant FL_GP2            : integer := 5;
  constant FL_GP3            : integer := 6;
  constant FL_GP4            : integer := 7;

  constant ACCUM             : SUBOP_TYPE := "000";
  constant INT_FLAG          : SUBOP_TYPE := "011";

  type REGFILE_TYPE is array (0 to 7) of DATA_TYPE;
  subtype FLAG_TYPE is DATA_TYPE;

  constant INT_VECTOR_0      : ADDRESS_TYPE := ISR_Start_Addr +  0;
  constant INT_VECTOR_1      : ADDRESS_TYPE := ISR_Start_Addr +  2;
  constant INT_VECTOR_2      : ADDRESS_TYPE := ISR_Start_Addr +  4;
  constant INT_VECTOR_3      : ADDRESS_TYPE := ISR_Start_Addr +  6;
  constant INT_VECTOR_4      : ADDRESS_TYPE := ISR_Start_Addr +  8;
  constant INT_VECTOR_5      : ADDRESS_TYPE := ISR_Start_Addr + 10;
  constant INT_VECTOR_6      : ADDRESS_TYPE := ISR_Start_Addr + 12;
  constant INT_VECTOR_7      : ADDRESS_TYPE := ISR_Start_Addr + 14;

  type CPU_CTRL_TYPE is record
    State                    : CPU_STATES;
    LS_Address               : ADDRESS_TYPE;
    Program_Ctr              : ADDRESS_TYPE;
    Stack_Ptr                : ADDRESS_TYPE;
    Opcode                   : OPCODE_TYPE;
    SubOp_p0                 : SUBOP_TYPE;
    SubOp_p1                 : SUBOP_TYPE;
    Cache_Valid              : std_logic;
    Prefetch                 : DATA_TYPE;
    Operand1                 : DATA_TYPE;
    Operand2                 : DATA_TYPE;
    AutoIncr                 : std_logic;
    A_Oper                   : OPCODE_TYPE;
    A_Reg                    : SUBOP_TYPE;
    A_Data                   : DATA_TYPE;
    A_NoFlags                : std_logic;
    M_Reg                    : SUBOP_TYPE;
    M_Prod                   : ADDRESS_TYPE;
    Regfile                  : REGFILE_TYPE;
    Flags                    : FLAG_TYPE;
    Int_Mask                 : DATA_TYPE;
    Int_Addr                 : ADDRESS_TYPE;
    Int_Pending              : DATA_TYPE;
    Int_Level                : integer range 0 to 7;
    Wait_for_FSM             : std_logic;
  end record;

  signal CPU                 : CPU_CTRL_TYPE;

  alias  Accumulator         is CPU.Regfile(0);
  alias  Flags               is CPU.Flags;

  signal Ack_Q, Ack_Q1       : std_logic;
  signal Int_Req, Int_Ack    : std_logic;

  type IC_MODES is ( CACHE_IDLE, CACHE_INSTR, CACHE_OPER1, CACHE_OPER2,
                     CACHE_PREFETCH, CACHE_PFFLUSH, CACHE_INVALIDATE );

  type PC_MODES is ( PC_INCR, PC_IDLE, PC_REV1, PC_REV2, PC_REV3,
                     PC_BRANCH, PC_LOAD );

  type SP_MODES is ( SP_IDLE, SP_RSET, SP_POP, SP_PUSH );

  type DP_MODES is ( DATA_BUS_IDLE, DATA_RD_MEM,
                     DATA_WR_REG, DATA_WR_FLAG,
							DATA_WR_PC_LOWER, DATA_WR_PC_UPPER );

  type DP_CTRL_TYPE is record
    Src                      : DP_MODES;
    Reg                      : SUBOP_TYPE;
  end record;

  type INT_CTRL_TYPE is record
    Mask_Set                 : std_logic;
    Soft_Ints                : INTERRUPT_BUNDLE;
    Incr_ISR                 : std_logic;
  end record;

begin

  Address_Sel: process( CPU )
    variable Offset_SX       : ADDRESS_TYPE;
  begin
    Offset_SX(15 downto 8)   := (others => CPU.Operand1(7));
    Offset_SX(7 downto 0)    := CPU.Operand1;

    case( CPU.State )is
      when LDO_C1 | LDX_C1 | STO_C1 | STX_C1 =>
        Address              <= CPU.LS_Address + Offset_SX;
      when LDA_C2 | STA_C2 =>
        Address              <= (CPU.Operand2 & CPU.Operand1);
      when PSH_C1 | POP_C1 | ISR_C3 | JSR_C1 | JSR_C2 |
           RTS_C1 | RTS_C2 | RTS_C3 =>
        Address              <= CPU.Stack_Ptr;
      when ISR_C1 | ISR_C2 =>
        Address              <= CPU.Int_Addr;
      when others =>
        Address              <= CPU.Program_Ctr;
    end case;
  end process;

  CPU_Proc: process( Clock, Reset )
    variable IC              : IC_MODES;
    variable PC              : PC_MODES;
    variable SP              : SP_MODES;
    variable DP              : DP_CTRL_TYPE;
    variable INT             : INT_CTRL_TYPE;
    variable RegSel          : integer range 0 to 7;
    variable Reg_l, Reg_u    : integer range 0 to 7;
    variable Ack_D           : std_logic;
    variable Offset_SX       : ADDRESS_TYPE;
    variable Index           : integer range 0 to 7;
    variable Temp            : std_logic_vector(8 downto 0);
  begin
    if( Reset = Reset_Level )then
      CPU.State              <= PIPE_FILL_0;
      CPU.LS_Address         <= (others => '0');
      CPU.Program_Ctr        <= Program_Start_Addr;
      CPU.Stack_Ptr          <= Stack_Start_Addr;
      CPU.Opcode             <= (others => '0');
      CPU.SubOp_p0           <= (others => '0');
      CPU.SubOp_p1           <= (others => '0');
      CPU.Prefetch           <= (others => '0');
      CPU.Operand1           <= (others => '0');
      CPU.Operand2           <= (others => '0');
      CPU.AutoIncr           <= '0';
      CPU.Cache_Valid        <= '0';
      CPU.A_Oper             <= ALU_IDLE;
      CPU.A_Reg              <= ACCUM;
      CPU.A_Data             <= x"00";
      CPU.A_NoFlags          <= '0';
      CPU.M_Reg              <= (others => '0');
      for i in 0 to 7 loop
        CPU.Regfile(i)       <= x"00";
      end loop;
      CPU.Flags              <= (others => '0');
      if( Enable_NMI )then
        CPU.Int_Mask         <= Default_Interrupt_Mask(7 downto 1) & '1';
      else
        CPU.Int_Mask         <= Default_Interrupt_Mask;
      end if;
      CPU.Int_Addr           <= (others => '0');
      CPU.Int_Pending        <= (others => '0');
      CPU.Int_Level          <= 7;
      CPU.Wait_for_FSM       <= '0';

      Ack_Q                  <= '0';
      Ack_Q1                 <= '0';
      Int_Ack                <= '0';
      Int_Req                <= '0';

      Wr_Data                <= x"00";
      Wr_Enable              <= '0';
      Rd_Enable              <= '1';
    elsif( rising_edge(Clock) )then

      IC                     := CACHE_IDLE;
      SP                     := SP_IDLE;
      DP.Src                 := DATA_RD_MEM;
      Ack_D                  := '0';
      INT.Mask_Set           := '0';
      INT.Soft_Ints          := x"00";
      INT.Incr_ISR           := '0';
      RegSel                 := conv_integer(CPU.SubOp_p0);

      if( Enable_Auto_Increment )then
        Reg_l                := conv_integer(CPU.SubOp_p0(2 downto 1) & '0');
        Reg_u                := conv_integer(CPU.SubOp_p0(2 downto 1) & '1');
      else
        Reg_l                := conv_integer(CPU.SubOp_p0);
        Reg_u                := conv_integer(CPU.SubOp_p1);
      end if;

      CPU.LS_Address         <= CPU.Regfile(Reg_u) & CPU.Regfile(Reg_l);

      CPU.AutoIncr           <= '0';
      if( Enable_Auto_Increment  )then
        CPU.AutoIncr         <= CPU.SubOp_p0(0);
      end if;

      CPU.A_Oper             <= ALU_IDLE;
      CPU.A_Reg              <= ACCUM;
      CPU.A_Data             <= x"00";
      CPU.A_NoFlags          <= '0';

      case( CPU.State )is
        when PIPE_FILL_0 =>
          PC                 := PC_INCR;
          CPU.State          <= PIPE_FILL_1;

        when PIPE_FILL_1 =>
          PC                 := PC_INCR;
          CPU.State          <= PIPE_FILL_2;

        when PIPE_FILL_2 =>
          IC                 := CACHE_INSTR;
          PC                 := PC_INCR;
          CPU.State          <= INSTR_DECODE;

-------------------------------------------------------------------------------
-- Instruction Decode and dispatch
-------------------------------------------------------------------------------

        when INSTR_DECODE =>
          IC                 := CACHE_INSTR;
          PC                 := PC_INCR;
          case CPU.Opcode is
            when OP_PSH =>
              IC             := CACHE_PREFETCH;
              PC             := PC_IDLE;
              DP.Src         := DATA_WR_REG;
              DP.Reg         := CPU.SubOp_p0;
              CPU.State      <= PSH_C1;

            when OP_POP =>
              IC             := CACHE_PREFETCH;
              PC             := PC_REV2;
              SP             := SP_POP;
              CPU.State      <= POP_C1;

            when OP_BR0 | OP_BR1 =>
              IC             := CACHE_OPER1;
              CPU.State      <= BRN_C1;

            when OP_DBNZ =>
              IC             := CACHE_OPER1;
              CPU.A_Oper     <= ALU_DEC;
              CPU.A_Reg      <= CPU.SubOp_p0;
              CPU.A_Data     <= CPU.Regfile(RegSel);
              CPU.State      <= DBNZ_C1;

            when OP_INT =>
              if( CPU.Int_Mask(RegSel) = '1' )then
                CPU.State    <= WAIT_FOR_INT;
                INT.Soft_Ints(RegSel) := '1';
              end if;

            when OP_STK =>
              case CPU.SubOp_p0 is
                when SOP_RSP  =>
                  SP         := SP_RSET;

                when SOP_RTS | SOP_RTI =>
                  IC         := CACHE_IDLE;
                  PC         := PC_IDLE;
                  SP         := SP_POP;
                  CPU.State  <= RTS_C1;

                when SOP_BRK  =>
                  if( BRK_Implements_WAI )then
                    CPU.State<= WAIT_FOR_INT;
                  else
                    PC       := PC_REV2;
                    CPU.State<= BRK_C1;
                  end if;

                when SOP_JMP  =>
                  IC         := CACHE_OPER1;
                  PC         := PC_IDLE;
                  CPU.State  <= JMP_C1;

                when SOP_SMSK =>
                  INT.Mask_Set := '1';

                when SOP_GMSK =>
                  IC         := CACHE_PREFETCH;
                  PC         := PC_REV1;
                  CPU.State  <= GMSK_C1;

                when SOP_JSR =>
                  IC         := CACHE_OPER1;
                  PC         := PC_IDLE;
                  DP.Src     := DATA_WR_PC_UPPER;
                  CPU.State  <= JSR_C1;

                when others => null;
              end case;

            when OP_MUL =>
              IC             := CACHE_PREFETCH;
              PC             := PC_REV1;
              CPU.M_Reg      <= CPU.SubOp_p0;
              CPU.State      <= MUL_C1;

            when OP_UPP =>
              IC             := CACHE_PREFETCH;
              PC             := PC_REV1;
              CPU.A_Oper     <= ALU_UPP1;
              CPU.A_NoFlags  <= '1';
              CPU.A_Reg      <= CPU.SubOp_p0;
              CPU.A_Data     <= CPU.Regfile(RegSel);
              CPU.State      <= UPP_C1;

            when OP_LDA =>
              IC             := CACHE_OPER1;
              PC             := PC_IDLE;
              CPU.State      <= LDA_C1;

            when OP_LDI =>
              IC             := CACHE_OPER1;
              PC             := PC_IDLE;
              CPU.State      <= LDI_C1;

            when OP_LDO =>
              IC             := CACHE_OPER1;
              PC             := PC_IDLE;
              CPU.State      <= LDO_C1;

            when OP_LDX =>
              IC             := CACHE_PFFLUSH;
              PC             := PC_REV1;
              CPU.State      <= LDX_C1;

            when OP_STA =>
              IC             := CACHE_OPER1;
              PC             := PC_IDLE;
              CPU.State      <= STA_C1;

            when OP_STO =>
              IC             := CACHE_OPER1;
              PC             := PC_REV2;
              DP.Src         := DATA_WR_REG;
              DP.Reg         := ACCUM;
              CPU.State      <= STO_C1;

            when OP_STX =>
              IC             := CACHE_PFFLUSH;
              PC             := PC_REV2;
              DP.Src         := DATA_WR_REG;
              DP.Reg         := ACCUM;
              CPU.State      <= STX_C1;

            when others =>
              IC             := CACHE_PREFETCH;
              PC             := PC_REV1;
              CPU.State      <= MATH_C1;

          end case;

-------------------------------------------------------------------------------
-- Program Control (BR0_C1, BR1_C1, DBNZ_C1, JMP )
-------------------------------------------------------------------------------

        when BRN_C1 =>
          if( Flags(RegSel) = CPU.Opcode(0) )then
            IC               := CACHE_IDLE;
            PC               := PC_BRANCH;
            CPU.State        <= PIPE_FILL_0;
          else
            IC               := CACHE_INSTR;
            CPU.State        <= INSTR_DECODE;
          end if;

        when DBNZ_C1 =>
          IC                 := CACHE_PREFETCH;
          PC                 := PC_IDLE;
          CPU.State          <= DBNZ_C2;

        when DBNZ_C2 =>
          if( Flags(FL_ZERO) = '0' )then
            IC               := CACHE_INVALIDATE;
            PC               := PC_BRANCH;
            CPU.State        <= PIPE_FILL_0;
          else
            PC               := PC_REV1;
            CPU.State        <= PIPE_FILL_1;
          end if;

        when JMP_C1 =>
          IC                 := CACHE_OPER2;
          PC                 := PC_IDLE;
          CPU.State          <= JMP_C2;

        when JMP_C2 =>
          PC                 := PC_LOAD;
          CPU.State          <= PIPE_FILL_0;

-------------------------------------------------------------------------------
-- Data Storage - Load from memory (LDA, LDI, LDO, LDX)
-------------------------------------------------------------------------------

        when LDA_C1 =>
          IC                 := CACHE_OPER2;
          PC                 := PC_IDLE;
          CPU.State          <= LDA_C2;

        when LDA_C2 =>
          PC                 := PC_IDLE;
          CPU.State          <= LDA_C3;

        when LDA_C3 =>
          PC                 := PC_IDLE;
          CPU.State          <= LDA_C4;

        when LDA_C4 =>
          IC                 := CACHE_OPER1;
          PC                 := PC_INCR;
          CPU.State          <= LDI_C1;

        when LDI_C1 =>
          IC                 := CACHE_PREFETCH;
          PC                 := PC_INCR;
          CPU.A_Oper         <= ALU_LDI;
          CPU.A_Reg          <= CPU.SubOp_p0;
          CPU.A_Data         <= CPU.Operand1;
          CPU.State          <= PIPE_FILL_2;

        when LDO_C1 =>
          IC                 := CACHE_PREFETCH;
          PC                 := PC_REV2;
          RegSel             := conv_integer(CPU.SubOp_p0(2 downto 1) & '0');
          if( Enable_Auto_Increment and CPU.AutoIncr = '1' )then
            CPU.A_Oper       <= ALU_UPP1;
            CPU.A_Reg        <= CPU.SubOp_p0(2 downto 1) & '0';
            CPU.A_NoFlags    <= '1';
            CPU.A_Data       <= CPU.RegFile(RegSel);
          end if;
          CPU.State          <= LDX_C2;

        when LDX_C1 =>
          PC                 := PC_REV2;
          RegSel             := conv_integer(CPU.SubOp_p0(2 downto 1) & '0');
          if( Enable_Auto_Increment and CPU.AutoIncr = '1' )then
            CPU.A_Oper       <= ALU_UPP1;
            CPU.A_Reg        <= CPU.SubOp_p0(2 downto 1) & '0';
            CPU.A_NoFlags    <= '1';
            CPU.A_Data       <= CPU.Regfile(RegSel);
          end if;
          CPU.State          <= LDX_C2;

        when LDX_C2 =>
          PC                 := PC_INCR;
          RegSel             := conv_integer(CPU.SubOp_p0(2 downto 1) & '1');
          if( Enable_Auto_Increment and CPU.AutoIncr = '1' )then
            CPU.A_Oper       <= ALU_UPP2;
            CPU.A_Reg        <= CPU.SubOp_p0(2 downto 1) & '1';
            CPU.A_Data       <= CPU.Regfile(RegSel);
          end if;
          CPU.State          <= LDX_C3;

        when LDX_C3 =>
          IC                 := CACHE_OPER1;
          PC                 := PC_INCR;
          CPU.State          <= LDX_C4;

        when LDX_C4 =>
          PC                 := PC_INCR;
          CPU.A_Oper         <= ALU_LDI;
          CPU.A_Reg          <= ACCUM;
          CPU.A_Data         <= CPU.Operand1;
          CPU.State          <= PIPE_FILL_2;

-------------------------------------------------------------------------------
-- Data Storage - Store to memory (STA, STO, STX)
-------------------------------------------------------------------------------
        when STA_C1 =>
          IC                 := CACHE_OPER2;
          PC                 := PC_IDLE;
          DP.Src             := DATA_WR_REG;
          DP.Reg             := CPU.SubOp_p0;
          CPU.State          <= STA_C2;

        when STA_C2 =>
          IC                 := CACHE_PREFETCH;
          PC                 := PC_INCR;
          CPU.State          <= PIPE_FILL_1;

        when STO_C1 =>
          IC                 := CACHE_PREFETCH;
          PC                 := PC_INCR;
          RegSel             := conv_integer(CPU.SubOp_p0(2 downto 1) & '0');
          if( not Enable_Auto_Increment )then
            CPU.State        <= PIPE_FILL_1;
          else
            CPU.State        <= PIPE_FILL_0;
            if( CPU.AutoIncr = '1' )then
              CPU.A_Oper     <= ALU_UPP1;
              CPU.A_Reg      <= CPU.SubOp_p0(2 downto 1) & '0';
              CPU.A_NoFlags  <= '1';
              CPU.A_Data     <= CPU.Regfile(RegSel);
              CPU.State      <= STO_C2;
            end if;
          end if;

        when STO_C2 =>
          PC                 := PC_INCR;
          RegSel             := conv_integer(CPU.SubOp_p0(2 downto 1) & '1');
          CPU.A_Oper         <= ALU_UPP2;
          CPU.A_Reg          <= CPU.SubOp_p0(2 downto 1) & '1';
          CPU.A_Data         <= CPU.Regfile(RegSel);
          CPU.State          <= PIPE_FILL_1;

        when STX_C1 =>
          PC                 := PC_INCR;
          if( not Enable_Auto_Increment )then
            CPU.State        <= PIPE_FILL_1;
          else
            RegSel           := conv_integer(CPU.SubOp_p0(2 downto 1) & '0');
            CPU.State        <= PIPE_FILL_1;
            if( CPU.AutoIncr = '1' )then
              CPU.A_Oper     <= ALU_UPP1;
              CPU.A_Reg      <= CPU.SubOp_p0(2 downto 1) & '0';
              CPU.A_NoFlags  <= '1';
              CPU.A_Data     <= CPU.Regfile(RegSel);
              CPU.State      <= STX_C2;
            end if;
          end if;

        when STX_C2 =>
          PC                 := PC_INCR;
          RegSel             := conv_integer(CPU.SubOp_p0(2 downto 1) & '1');
          CPU.A_Oper         <= ALU_UPP2;
          CPU.A_Reg          <= CPU.SubOp_p0(2 downto 1) & '1';
          CPU.A_Data         <= CPU.Regfile(RegSel);
          CPU.State          <= PIPE_FILL_2;

-------------------------------------------------------------------------------
-- Multi-Cycle Math Operations
-------------------------------------------------------------------------------

        when MATH_C1 =>
          PC                 := PC_INCR;
          CPU.A_Oper         <= CPU.Opcode;
          CPU.A_Reg          <= CPU.SubOp_p0;
          CPU.A_Data         <= CPU.Regfile(RegSel);
          CPU.State          <= PIPE_FILL_2;

        when GMSK_C1 =>
          PC                 := PC_INCR;
          CPU.A_Oper         <= ALU_LDI;
          CPU.A_Data         <= CPU.Int_Mask;
          CPU.State          <= PIPE_FILL_2;

        when MUL_C1 =>
          PC                 := PC_INCR;
          CPU.A_Oper         <= ALU_MUL;
          CPU.State          <= PIPE_FILL_2;

        when UPP_C1 =>
          PC                 := PC_INCR;
          RegSel             := conv_integer(CPU.SubOp_p1);
          CPU.A_Oper         <= ALU_UPP2;
          CPU.A_Reg          <= CPU.SubOp_p1;
          CPU.A_Data         <= CPU.Regfile(RegSel);
          CPU.State          <= PIPE_FILL_2;

-------------------------------------------------------------------------------
-- Basic Stack Manipulation (PSH, POP, RSP)
-------------------------------------------------------------------------------
        when PSH_C1 =>
          PC                 := PC_REV1;
          SP                 := SP_PUSH;
          CPU.State          <= PIPE_FILL_1;

        when POP_C1 =>
          PC                 := PC_IDLE;
          CPU.State          <= POP_C2;

        when POP_C2 =>
          PC                 := PC_IDLE;
          CPU.State          <= POP_C3;

        when POP_C3 =>
          IC                 := CACHE_OPER1;
          PC                 := PC_INCR;
          CPU.State          <= POP_C4;

        when POP_C4 =>
          PC                 := PC_INCR;
          CPU.A_Oper         <= ALU_LDI;
          CPU.A_Reg          <= CPU.SubOp_p0;
          CPU.A_NoFlags      <= '1';
          CPU.A_Data         <= CPU.Operand1;
          CPU.State          <= PIPE_FILL_2;

-------------------------------------------------------------------------------
-- Subroutines & Interrupts (RTS, JSR)
-------------------------------------------------------------------------------
        when WAIT_FOR_INT =>
          PC                 := PC_IDLE;
          DP.Src             := DATA_BUS_IDLE;
          CPU.State          <= WAIT_FOR_INT;

        when ISR_C1 =>
          PC                 := PC_IDLE;
          INT.Incr_ISR       := '1';
          CPU.State          <= ISR_C2;

        when ISR_C2 =>
          PC                 := PC_IDLE;
          DP.Src             := DATA_WR_FLAG;
          CPU.State          <= ISR_C3;

        when ISR_C3 =>
          IC                 := CACHE_OPER1;
          PC                 := PC_IDLE;
          SP                 := SP_PUSH;
          DP.Src             := DATA_WR_PC_UPPER;
          Ack_D              := '1';
          CPU.A_Oper         <= ALU_STP;
          CPU.A_Reg          <= INT_FLAG;
          CPU.State          <= JSR_C1;

        when JSR_C1 =>
          IC                 := CACHE_OPER2;
          PC                 := PC_IDLE;
          SP                 := SP_PUSH;
          DP.Src             := DATA_WR_PC_LOWER;
          CPU.State          <= JSR_C2;

        when JSR_C2 =>
          SP                 := SP_PUSH;
          PC                 := PC_LOAD;
          CPU.State          <= PIPE_FILL_0;

        when RTS_C1 =>
          PC                 := PC_IDLE;
          SP                 := SP_POP;
          CPU.State          <= RTS_C2;

        when RTS_C2 =>
          PC                 := PC_IDLE;
          if( CPU.SubOp_p0 = SOP_RTI )then
            SP               := SP_POP;
          end if;
          CPU.State          <= RTS_C3;

        when RTS_C3 =>
          IC                 := CACHE_OPER1;
          PC                 := PC_IDLE;
          CPU.State          <= RTS_C4;

        when RTS_C4 =>
          IC                 := CACHE_OPER2;
          PC                 := PC_IDLE;
          CPU.State          <= RTS_C5;

        when RTS_C5 =>
          PC                 := PC_LOAD;
          CPU.State          <= PIPE_FILL_0;
          if( CPU.SubOp_p0 = SOP_RTI )then
            IC               := CACHE_OPER1;
            CPU.State        <= RTI_C6;
          end if;

        when RTI_C6 =>
          PC                 := PC_INCR;
          CPU.Int_Level      <= 7;
          CPU.A_Oper         <= ALU_RFLG;
          CPU.A_Data         <= CPU.Operand1;
          CPU.State          <= PIPE_FILL_1;

-------------------------------------------------------------------------------
-- Debugging (BRK) Performs a 5-clock NOP
-------------------------------------------------------------------------------

        when BRK_C1 =>
          PC                 := PC_IDLE;
          CPU.State          <= PIPE_FILL_0;

        when others =>
          null;

      end case;

-------------------------------------------------------------------------------
-- Interrupt Override Logic
-------------------------------------------------------------------------------

    if( Int_Req = '1' )then
      if( CPU.State = INSTR_DECODE or CPU.State = WAIT_FOR_INT )then
        IC                   := CACHE_IDLE;
        PC                   := PC_REV3;
        SP                   := SP_IDLE;
        DP.Src               := DATA_RD_MEM;
        INT.Soft_Ints        := (others => '0');
        CPU.A_Oper           <= ALU_IDLE;
        CPU.State            <= ISR_C1;

      end if;
    end if;

-------------------------------------------------------------------------------
-- Vectored Interrupt Controller
-------------------------------------------------------------------------------

      CPU.Int_Pending        <= ((Interrupts or INT.Soft_Ints) and
                                 CPU.Int_Mask) or CPU.Int_Pending;

      if( CPU.Wait_for_FSM = '0' )then
        if( CPU.Int_Pending(0) = '1' )then
          CPU.Int_Addr       <= INT_VECTOR_0;
          CPU.Int_Level      <= 0;
          CPU.Int_Pending(0) <= '0';
          CPU.Wait_for_FSM   <= '1';
        elsif( CPU.Int_Pending(1) = '1' and CPU.Int_Level > 0 )then
          CPU.Int_Addr       <= INT_VECTOR_1;
          CPU.Int_Level      <= 1;
          CPU.Int_Pending(1) <= '0';
          CPU.Wait_for_FSM   <= '1';
        elsif( CPU.Int_Pending(2) = '1' and CPU.Int_Level > 1 )then
          CPU.Int_Addr       <= INT_VECTOR_2;
          CPU.Int_Level      <= 2;
          CPU.Int_Pending(2) <= '0';
          CPU.Wait_for_FSM   <= '1';
        elsif( CPU.Int_Pending(3) = '1' and CPU.Int_Level > 2 )then
          CPU.Int_Addr       <= INT_VECTOR_3;
          CPU.Int_Level      <= 3;
          CPU.Int_Pending(3) <= '0';
          CPU.Wait_for_FSM   <= '1';
        elsif( CPU.Int_Pending(4) = '1' and CPU.Int_Level > 3 )then
          CPU.Int_Addr       <= INT_VECTOR_4;
          CPU.Int_Level      <= 4;          
          CPU.Int_Pending(4) <= '0';
          CPU.Wait_for_FSM   <= '1';
        elsif( CPU.Int_Pending(5) = '1' and CPU.Int_Level > 4 )then
          CPU.Int_Addr       <= INT_VECTOR_5;
          CPU.Int_Level      <= 5;
          CPU.Int_Pending(5) <= '0';
          CPU.Wait_for_FSM   <= '1';
        elsif( CPU.Int_Pending(6) = '1' and CPU.Int_Level > 6 )then
          CPU.Int_Addr       <= INT_VECTOR_6;
          CPU.Int_Level      <= 6;
          CPU.Int_Pending(6) <= '0';
          CPU.Wait_for_FSM   <= '1';
        elsif( CPU.Int_Pending(7) = '1' )then
          CPU.Int_Addr       <= INT_VECTOR_7;
          CPU.Int_Level      <= 7;
          CPU.Int_Pending(7) <= '0';
          CPU.Wait_for_FSM   <= '1';
        end if;
      end if;

      Ack_Q                  <= Ack_D;
      Ack_Q1                 <= Ack_Q;
      Int_Ack                <= Ack_Q1;
      if( Int_Ack = '1' )then
        CPU.Wait_for_FSM     <= '0';
      end if;

      Int_Req                <= CPU.Wait_for_FSM and (not Int_Ack);

      if( INT.Mask_Set = '1' )then
        if( Enable_NMI )then
          CPU.Int_Mask       <= Accumulator(7 downto 1) & '1';
        else -- Disable NMI override
          CPU.Int_Mask       <= Accumulator;
        end if;
      end if;

      if( INT.Incr_ISR = '1' )then
        CPU.Int_Addr         <= CPU.Int_Addr + 1;
      end if;

-------------------------------------------------------------------------------
-- ALU (Arithmetic / Logic Unit)
-------------------------------------------------------------------------------
      Index                  := conv_integer(CPU.A_Reg);

      CPU.M_Prod             <= Accumulator *
                                CPU.Regfile(conv_integer(CPU.M_Reg));

      case( CPU.A_Oper )is
        when ALU_INC => -- Rn = Rn + 1 : CPU.Flags N,C,Z
          Temp               := ("0" & x"01") +
                                ("0" & CPU.A_Data);
          Flags(FL_CARRY)    <= Temp(8);
          CPU.Regfile(Index) <= Temp(7 downto 0);
          if( CPU.A_NoFlags = '0' )then
            Flags(FL_ZERO)   <= nor_reduce(Temp(7 downto 0));
            Flags(FL_NEG)    <= Temp(7);
          end if;

        when ALU_UPP2 => -- Rn = Rn + C : Flags C
          Temp               := ("0" & x"00") +
                                ("0" & CPU.A_Data) +
                                 Flags(FL_CARRY);
          Flags(FL_CARRY)    <= Temp(8);
          CPU.Regfile(Index) <= Temp(7 downto 0);

        when ALU_ADC => -- R0 = R0 + Rn + C :  N,C,Z
          Temp               := ("0" & Accumulator) +
                                ("0" & CPU.A_Data) +
                                Flags(FL_CARRY);
          Flags(FL_ZERO)     <= nor_reduce(Temp(7 downto 0));
          Flags(FL_CARRY)    <= Temp(8);
          Flags(FL_NEG)      <= Temp(7);
          Accumulator        <= Temp(7 downto 0);

        when ALU_TX0 => -- R0 = Rn : Flags N,Z
          Temp               := "0" & CPU.A_Data;
          Flags(FL_ZERO)     <= nor_reduce(Temp(7 downto 0));
          Flags(FL_NEG)      <= Temp(7);
          Accumulator        <= Temp(7 downto 0);

        when ALU_OR  => -- R0 = R0 | Rn : Flags N,Z
          Temp(7 downto 0)   := Accumulator or CPU.A_Data;
          Flags(FL_ZERO)     <= nor_reduce(Temp(7 downto 0));
          Flags(FL_NEG)      <= Temp(7);
          Accumulator        <= Temp(7 downto 0);

        when ALU_AND => -- R0 = R0 & Rn : Flags N,Z
          Temp(7 downto 0)   := Accumulator and CPU.A_Data;
          Flags(FL_ZERO)     <= nor_reduce(Temp(7 downto 0));
          Flags(FL_NEG)      <= Temp(7);
          Accumulator        <= Temp(7 downto 0);

        when ALU_XOR => -- R0 = R0 ^ Rn : Flags N,Z
          Temp(7 downto 0)   := Accumulator xor CPU.A_Data;
          Flags(FL_ZERO)     <= nor_reduce(Temp(7 downto 0));
          Flags(FL_NEG)      <= Temp(7);
          Accumulator        <= Temp(7 downto 0);

        when ALU_ROL => -- Rn = Rn<<1,C : Flags N,C,Z
          Temp               := CPU.A_Data & Flags(FL_CARRY);
          Flags(FL_ZERO)     <= nor_reduce(Temp(7 downto 0));
          Flags(FL_CARRY)    <= Temp(8);
          Flags(FL_NEG)      <= Temp(7);
          CPU.Regfile(Index) <= Temp(7 downto 0);

        when ALU_ROR => -- Rn = C,Rn>>1 : Flags N,C,Z
          Temp               := CPU.A_Data(0) & Flags(FL_CARRY) &
                                CPU.A_Data(7 downto 1);
          Flags(FL_ZERO)     <= nor_reduce(Temp(7 downto 0));
          Flags(FL_CARRY)    <= Temp(8);
          Flags(FL_NEG)      <= Temp(7);
          CPU.Regfile(Index) <= Temp(7 downto 0);

        when ALU_DEC => -- Rn = Rn - 1 : Flags N,C,Z
          Temp               := ("0" & CPU.A_Data) +
                                ("0" & x"FF");
          Flags(FL_ZERO)     <= nor_reduce(Temp(7 downto 0));
          Flags(FL_CARRY)    <= Temp(8);
          Flags(FL_NEG)      <= Temp(7);
          CPU.Regfile(Index) <= Temp(7 downto 0);

        when ALU_SBC => -- Rn = R0 - Rn - C : Flags N,C,Z
          Temp               := ("0" & Accumulator) +
                                ("0" & (not CPU.A_Data)) +
                                     Flags(FL_CARRY);
          Flags(FL_ZERO)     <= nor_reduce(Temp(7 downto 0));
          Flags(FL_CARRY)    <= Temp(8);
          Flags(FL_NEG)      <= Temp(7);
          Accumulator        <= Temp(7 downto 0);

        when ALU_ADD => -- R0 = R0 + Rn : Flags N,C,Z
          Temp               := ("0" & Accumulator) +
                                ("0" & CPU.A_Data);
          Flags(FL_CARRY)    <= Temp(8);
          Accumulator        <= Temp(7 downto 0);
          Flags(FL_ZERO)     <= nor_reduce(Temp(7 downto 0));
          Flags(FL_NEG)      <= Temp(7);

        when ALU_STP => -- Sets bit(n) in the CPU.Flags register
          Flags(Index)       <= '1';

        when ALU_BTT => -- Z = !R0(N), N = R0(7)
          Flags(FL_ZERO)     <= not Accumulator(Index);
          Flags(FL_NEG)      <= Accumulator(7);

        when ALU_CLP => -- Clears bit(n) in the Flags register
          Flags(Index)       <= '0';

        when ALU_T0X => -- Rn = R0 : Flags N,Z
          Temp               := "0" & Accumulator;
          Flags(FL_ZERO)     <= nor_reduce(Temp(7 downto 0));
          Flags(FL_NEG)      <= Temp(7);
          CPU.Regfile(Index) <= Temp(7 downto 0);

        when ALU_CMP => -- Sets CPU.Flags on R0 - Rn : Flags N,C,Z
          Temp               := ("0" & Accumulator) +
                                ("0" & (not CPU.A_Data)) +
                                 '1';
          Flags(FL_ZERO)     <= nor_reduce(Temp(7 downto 0));
          Flags(FL_CARRY)    <= Temp(8);
          Flags(FL_NEG)      <= Temp(7);

        when ALU_MUL => -- Stage 1 of 2 {R1:R0} = R0 * Rn : Flags Z
          CPU.Regfile(0)     <= CPU.M_Prod(7 downto 0);
          CPU.Regfile(1)     <= CPU.M_Prod(15 downto 8);
          Flags(FL_ZERO)     <= nor_reduce(CPU.M_Prod);

        when ALU_LDI => -- Rn <= Data : Flags N,Z
          if( CPU.A_NoFlags = '0' )then
            Flags(FL_ZERO)   <= nor_reduce(CPU.A_Data);
            Flags(FL_NEG)    <= CPU.A_Data(7);
          end if;
          CPU.Regfile(Index) <= CPU.A_Data;

        when ALU_RFLG =>
          Flags              <= CPU.A_Data;

        when others =>
          null;
      end case;

-------------------------------------------------------------------------------
-- Instruction/Operand caching for pipelined memory access
-------------------------------------------------------------------------------

      case( IC )is
        when CACHE_INSTR =>
          CPU.Opcode         <= Rd_Data(7 downto 3);
          CPU.SubOp_p0       <= Rd_Data(2 downto 0);
          CPU.SubOp_p1       <= Rd_Data(2 downto 0) + 1;
          if( CPU.Cache_Valid = '1' )then
            CPU.Opcode       <= CPU.Prefetch(7 downto 3);
            CPU.SubOp_p0     <= CPU.Prefetch(2 downto 0);
            CPU.SubOp_p1     <= CPU.Prefetch(2 downto 0) + 1;
            CPU.Cache_Valid  <= '0';
          end if;

        when CACHE_OPER1 =>
          CPU.Operand1       <= Rd_Data;

        when CACHE_OPER2 =>
          CPU.Operand2       <= Rd_Data;

        when CACHE_PREFETCH =>
          CPU.Prefetch       <= Rd_Data;
          CPU.Cache_Valid    <= '1';

        when CACHE_PFFLUSH =>
          CPU.Prefetch       <= Rd_Data;
          CPU.Operand1       <= x"00";
          CPU.Operand2       <= x"00";
          CPU.Cache_Valid    <= '1';

        when CACHE_INVALIDATE =>
          CPU.Cache_Valid    <= '0';

        when CACHE_IDLE =>
          null;
      end case;

-------------------------------------------------------------------------------
-- Program Counter
-------------------------------------------------------------------------------

      Offset_SX(15 downto 8) := (others => CPU.Operand1(7));
      Offset_SX(7 downto 0)  := CPU.Operand1;

      case( PC )is

        when PC_INCR =>
          CPU.Program_Ctr    <= CPU.Program_ctr + 1;
        
        when PC_IDLE =>
        --CPU.Program_Ctr    <= CPU.Program_Ctr + 0;
          null;

        when PC_REV1 =>
          CPU.Program_Ctr    <= CPU.Program_Ctr - 1;

        when PC_REV2 =>
          CPU.Program_Ctr    <= CPU.Program_Ctr - 2;

        when PC_REV3 =>
          CPU.Program_Ctr    <= CPU.Program_Ctr - 3;

        when PC_BRANCH =>
          CPU.Program_Ctr    <= CPU.Program_Ctr + Offset_SX - 2;

        when PC_LOAD =>
          CPU.Program_Ctr    <= CPU.Operand2 & CPU.Operand1;

        when others =>
          null;
      end case;

-------------------------------------------------------------------------------
-- (Write) Data Path
-------------------------------------------------------------------------------

      Wr_Data                <= x"00";
      Wr_Enable              <= '0';
      Rd_Enable              <= '0';

      case( DP.Src )is
        when DATA_BUS_IDLE =>
          null;

        when DATA_RD_MEM =>
          Rd_Enable          <= '1';

        when DATA_WR_REG =>
          Wr_Enable          <= '1';
          Wr_Data            <= CPU.Regfile(conv_integer(DP.Reg));

        when DATA_WR_FLAG =>
          Wr_Enable          <= '1';
          Wr_Data            <= Flags;

        when DATA_WR_PC_LOWER =>
          Wr_Enable          <= '1';
          Wr_Data            <= CPU.Program_Ctr(7 downto 0);

		  when DATA_WR_PC_UPPER =>
          Wr_Enable          <= '1';
          Wr_Data            <= CPU.Program_Ctr(15 downto 8);

        when others =>
          null;
      end case;

-------------------------------------------------------------------------------
-- Stack Pointer
-------------------------------------------------------------------------------
      case( SP )is
        when SP_IDLE =>
          null;

        when SP_RSET =>
          CPU.Stack_Ptr      <= Stack_Start_Addr;
          if( Allow_Stack_Address_Move )then
            CPU.Stack_Ptr    <= CPU.Regfile(1) & CPU.Regfile(0);
          end if;

        when SP_POP  =>
          CPU.Stack_Ptr      <= CPU.Stack_Ptr + 1;

        when SP_PUSH =>
          CPU.Stack_Ptr      <= CPU.Stack_Ptr - 1;

        when others =>
          null;

      end case;

    end if;
  end process;

end architecture;
