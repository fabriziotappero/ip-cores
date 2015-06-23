-----------------------------------------------------------------
--                                                             --
-----------------------------------------------------------------
--                                                             --
-- Copyright (C) 2013 Stefano Tonello                          --
--                                                             --
-- This source file may be used and distributed without        --
-- restriction provided that this copyright statement is not   --
-- removed from the file and that any derivative work contains --
-- the original copyright notice and the associated disclaimer.--
--                                                             --
-- THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY         --
-- EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   --
-- TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   --
-- FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      --
-- OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         --
-- INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    --
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   --
-- GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        --
-- BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  --
-- LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  --
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  --
-- OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         --
-- POSSIBILITY OF SUCH DAMAGE.                                 --
--                                                             --
-----------------------------------------------------------------

---------------------------------------------------------------
-- Instruction decoder (stage 1)
---------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.G729A_ASIP_PKG.all;
use work.G729A_ASIP_IDEC_2W_PKG.all;
use work.G729A_ASIP_OP_PKG.all;

entity G729A_ASIP_IDEC1_2W is
  port(
    INSTR_i : in std_logic_vector(ILEN-1 downto 0);

    OPB_IMM_o : out std_logic;
    OPB_o : out LDWORD_T;
    DEC_INSTR_o : out DEC_INSTR_T
  );
end G729A_ASIP_IDEC1_2W;

architecture ARC of G729A_ASIP_IDEC1_2W is

  function EXTS16(V : std_logic_vector) return signed is
    variable S : signed(SDLEN-1 downto 0);
  begin
    S(V'HIGH downto 0) := to_signed(V);
    S(SDLEN-1 downto V'HIGH+1) := (others => V(V'HIGH));
    return(S);
  end function;

  function EXTS32(V : std_logic_vector) return signed is
    variable S : signed(LDLEN-1 downto 0);
  begin
    S(V'HIGH downto 0) := to_signed(V);
    S(LDLEN-1 downto V'HIGH+1) := (others => V(V'HIGH));
    return(S);
  end function;

  signal OP1 : integer range 0 to 16-1;
  signal OP2 : integer range 0 to 16-1;
  signal OP2_RRR : integer range 0 to 256-1;
  signal RD,RA,RB,RDF : RID_T;
  signal IMNMC : INST_MNEMONIC_T;
  signal WRD,RRA,RRB : std_logic;
  signal LD,LA,LB : std_logic;
  signal IMM : signed(16-1 downto 0);
  signal ALU_OP : ALU_OP_T;
  signal BJ_OP : BJ_OP_T;
  signal LS_OP : LS_OP_T;
  signal WOVF : std_logic;
  signal WACC : std_logic;
  signal IMM8 : std_logic_vector(8-1 downto 0);
  signal IMM12,IMM12_S : std_logic_vector(12-1 downto 0);
  signal IMM16,IMM16_S : std_logic_vector(16-1 downto 0);
  signal P0_ONLY : std_logic;

begin
 
  -- instruction subfields extraction
  process(INSTR_i)
    variable B0,B1,B2,B3,B4,B5 : std_logic_vector(4-1 downto 0);
    variable TMP : std_logic_vector(8-1 downto 0);
  begin
    B0 := INSTR_i(4*1-1 downto 4*0);
    B1 := INSTR_i(4*2-1 downto 4*1);
    B2 := INSTR_i(4*3-1 downto 4*2);
    B3 := INSTR_i(4*4-1 downto 4*3);
    B4 := INSTR_i(4*5-1 downto 4*4);
    B5 := INSTR_i(4*6-1 downto 4*5);

    -- major opcode
    OP1 <= to_integer(to_unsigned(B5));

    -- minor opcode
    OP2 <= to_integer(to_unsigned(B0));

    -- minor opcode for RRR type instructions

    -- WARNING: this extra step is needed to
    --insure correct ordering!

    TMP := (B1 & B0);

    OP2_RRR <= to_integer(to_unsigned(TMP));

    -- register identifiers
    RD <= to_integer(to_unsigned(B4));
    --RD2 <= to_integer(to_unsigned(B3)); -- for ldpp/stpp
    RA <= to_integer(to_unsigned(B3));
    RB <= to_integer(to_unsigned(B2));

    -- immediate operands
    IMM8 <= INSTR_i(12-1 downto 4);
    IMM12 <= INSTR_i(12-1 downto 0);
    IMM12_S <= INSTR_i(20-1 downto 16) & INSTR_i(12-1 downto 4);
    IMM16 <= INSTR_i(16-1 downto 0);
    IMM16_S <= INSTR_i(20-1 downto 4);

  end process;

  -- instruction mnemonic and operand flags extraction
  process(OP1,OP2,OP2_RRR)
  begin
    WRD <= '0';
    RRA <= '0';
    RRB <= '0';
    LD <= '0';
    LA <= '0';
    LB <= '0';
    ALU_OP <= ALU_NIL;
    BJ_OP <= BJ_NIL;
    LS_OP <= LS_NIL;
    WACC <= '0';
    WOVF <= '0';
    P0_ONLY <= '0';
    case OP1 is
      when 0 =>
        -- RRR instruction
        case OP2_RRR is
          when 0 =>
            -- abs rD,rA
            IMNMC <= IM_ABS;
            WRD <= '1';
            RRA <= '1';
            ALU_OP <= ALU_ABS;
          when 1 =>
            -- labs rD,rA
            IMNMC <= IM_LABS;
            WRD <= '1';
            RRA <= '1';
            LD <= '1';
            LA <= '1';
            ALU_OP <= ALU_LABS;
          when 2 =>
            -- add rD,rA,rB
            IMNMC <= IM_ADD;
            WRD <= '1';
            RRA <= '1';
            RRB <= '1';
            WOVF <= '1';
            ALU_OP <= ALU_ADD;
          when 3 =>
            -- ladd rD,rA,rB
            IMNMC <= IM_LADD;
            WRD <= '1';
            RRA <= '1';
            RRB <= '1';
            LD <= '1';
            LA <= '1';
            LB <= '1';
            WOVF <= '1';
            ALU_OP <= ALU_LADD;
          when 4 =>
            -- neg rD,rA
            IMNMC <= IM_NEG;
            WRD <= '1';
            RRA <= '1';
            WOVF <= '1';
            ALU_OP <= ALU_NEG;
          when 5 =>
            -- lneg rD,rA
            IMNMC <= IM_LNEG;
            WRD <= '1';
            RRA <= '1';
            LD <= '1';
            LA <= '1';
            WOVF <= '1';
            ALU_OP <= ALU_LNEG;
          when 6 =>
            -- sub rD,rA,rB
            IMNMC <= IM_SUB;
            WRD <= '1';
            RRA <= '1';
            RRB <= '1';
            WOVF <= '1';
            ALU_OP <= ALU_SUB;
          when 7 =>
            -- lsub rD,rA,rB
            IMNMC <= IM_LSUB;
            WRD <= '1';
            RRA <= '1';
            RRB <= '1';
            LD <= '1';
            LA <= '1';
            LB <= '1';
            WOVF <= '1';
            ALU_OP <= ALU_LSUB;
          when 8 =>
            -- lext rD,rA
            IMNMC <= IM_LEXT;
            WRD <= '1';
            RRA <= '1';
            LD <= '1';
            LA <= '1';
            ALU_OP <= ALU_LEXT;
          when 9 =>
            -- rnd rD,rA
            IMNMC <= IM_RND;
            WRD <= '1';
            RRA <= '1';
            --LD <= '1';
            LA <= '1';
            WOVF <= '1';
            ALU_OP <= ALU_RND;
          when 10 =>
            -- mul rD,rA,rB
            IMNMC <= IM_MUL;
            WRD <= '1';
            RRA <= '1';
            RRB <= '1';
            WOVF <= '1';
            ALU_OP <= ALU_MUL;
          when 11 =>
            -- lmul rD,rA,rB
            IMNMC <= IM_LMUL;
            WRD <= '1';
            RRA <= '1';
            RRB <= '1';
            LD <= '1';
            --LA <= '1';
            --LB <= '1';
            WOVF <= '1';
            ALU_OP <= ALU_LMUL;
          when 12 =>
            -- mula rD,rA,rB
            IMNMC <= IM_MULA;
            WRD <= '1';
            RRA <= '1';
            RRB <= '1';
            ALU_OP <= ALU_MULA;
          when 13 =>
            -- shl rD,rA,rB
            IMNMC <= IM_SHL;
            WRD <= '1';
            RRA <= '1';
            RRB <= '1';
            WOVF <= '1';
            ALU_OP <= ALU_SHL;
          when 14 =>
            -- lshl rD,rA,rB
            IMNMC <= IM_LSHL;
            WRD <= '1';
            RRA <= '1';
            RRB <= '1';
            LD <= '1';
            LA <= '1';
            WOVF <= '1';
            ALU_OP <= ALU_LSHL;
          when 15 =>
            -- shr rD,rA,rB
            IMNMC <= IM_SHR;
            WRD <= '1';
            RRA <= '1';
            RRB <= '1';
            ALU_OP <= ALU_SHR;
          when 16 =>
            --lshr rD,rA,rB
            IMNMC <= IM_LSHR;
            WRD <= '1';
            RRA <= '1';
            RRB <= '1';
            LD <= '1';
            LA <= '1';
            ALU_OP <= ALU_LSHR;
          when 17 =>
            -- nrms rD,rA
            IMNMC <= IM_NRMS;
            WRD <= '1';
            RRA <= '1';
            ALU_OP <= ALU_NRMS;
          when 18 =>
            -- nrml rD,rA
            IMNMC <= IM_NRML;
            WRD <= '1';
            RRA <= '1';
            LA <= '1';
            ALU_OP <= ALU_NRML;
          when 19 =>
            -- lmac rD,rA,rB
            IMNMC <= IM_LMAC;
            WRD <= '1';
            RRA <= '1';
            RRB <= '1';
            LD <= '1';
            WACC <= '1';
            WOVF <= '1';
            ALU_OP <= ALU_LMAC;
            --SC <= '0';
          when 20 =>
            -- lmsu rD,rA,rB
            IMNMC <= IM_LMSU;
            WRD <= '1';
            RRA <= '1';
            RRB <= '1';
            LD <= '1';
            WACC <= '1';
            WOVF <= '1';
            ALU_OP <= ALU_LMSU;
            --SC <= '0';
          when 21 =>
            -- mulr rD,rA,rB
            IMNMC <= IM_MULR;
            WRD <= '1';
            RRA <= '1';
            RRB <= '1';
            WOVF <= '1';
            ALU_OP <= ALU_MULR;
            --SC <= '0';
          --when 22 =>
          --  -- m32 rD,rA,rB
          --  IMNMC <= IM_M32;
          --  WRD <= '1';
          --  RRA <= '1';
          --  RRB <= '1';
          --  LD <= '1';
          --  LA <= '1';
          --  LB <= '1';
          --  WOVF <= '1';
          --  ALU_OP <= ALU_M32;
          --  --SC <= '0';
          when 23 =>
            -- m3216 rD,rA,rB
            IMNMC <= IM_M3216;
            WRD <= '1';
            RRA <= '1';
            RRB <= '1';
            LD <= '1';
            LA <= '1';
            WOVF <= '1';
            ALU_OP <= ALU_M3216;
            --SC <= '0';
          when 24 =>
            -- and rD,rA,rB
            IMNMC <= IM_AND;
            WRD <= '1';
            RRA <= '1';
            RRB <= '1';
            ALU_OP <= ALU_AND;
          when 25 =>
            -- or rD,rA,rB
            IMNMC <= IM_OR;
            WRD <= '1';
            RRA <= '1';
            RRB <= '1';
            ALU_OP <= ALU_OR;
          when 26 =>
            -- jmp rA
            IMNMC <= IM_JMP;
            RRA <= '1';
            BJ_OP <= BJ_JR;
            P0_ONLY <= '1';
          when 27 =>
            -- jmp rD,rA
            IMNMC <= IM_JMPL;
            WRD <= '1';
            RRA <= '1';
            BJ_OP <= BJ_JRL;
            ALU_OP <= ALU_MOVA;
            P0_ONLY <= '1';
          when 29 =>
            -- halt
            IMNMC <= IM_HALT;
            P0_ONLY <= '1';
          when 30 =>
            -- llcr rA
            IMNMC <= IM_LLCR;
            RRA <= '1';
            P0_ONLY <= '1';
          when 31 =>
            -- lclr
            IMNMC <= IM_LCLR;
            P0_ONLY <= '1';
          when 32 =>
            -- rovf rD
            IMNMC <= IM_ROVF;
            WRD <= '1';
            ALU_OP <= ALU_ROVF;
          when 33 =>
            -- covf
            IMNMC <= IM_COVF;
            WOVF <= '1';
            ALU_OP <= ALU_COVF;
          when 34 =>
            -- racc rD
            IMNMC <= IM_RACC;
            WRD <= '1';
            LD <= '1';
            ALU_OP <= ALU_RACC;
          when 35 =>
            -- wacc rA
            IMNMC <= IM_WACC;
            RRA <= '1';
            LA <= '1';
            WACC <= '1';
            ALU_OP <= ALU_MOVA; --ALU_WACC;
          when 36 =>
            -- nop
            IMNMC <= IM_NOP;
          when 37 =>
            -- pxon
            IMNMC <= IM_PXON;
            P0_ONLY <= '1';
          when 38 =>
            -- pxoff
            IMNMC <= IM_PXOFF;
            P0_ONLY <= '1';
          when others =>
            IMNMC <= IM_BAD_INSTR;
        end case;

      when 1 =>
        -- addi rD,rA,imm12
        IMNMC <= IM_ADDI;
        WRD <= '1';
        RRA <= '1';
        WOVF <= '1';
        ALU_OP <= ALU_ADD;

      when 2 =>
        -- laddi rD,rA,imm12
        IMNMC <= IM_LADDI;
        WRD <= '1';
        RRA <= '1';
        LD <= '1';
        LA <= '1';
        LB <= '1';
        WOVF <= '1';
        ALU_OP <= ALU_LADD;

      when 3 =>
        -- subi rD,rA,imm12
        IMNMC <= IM_SUBI;
        WRD <= '1';
        RRA <= '1';
        WOVF <= '1';
        ALU_OP <= ALU_SUB;

      when 4 =>
        -- lsubi rD,rA,imm12
        IMNMC <= IM_LSUBI;
        WRD <= '1';
        RRA <= '1';
        LD <= '1';
        LA <= '1';
        LB <= '1';
        WOVF <= '1';
        ALU_OP <= ALU_LSUB;

      when 5 =>
        -- muli rD,rA,imm12
        IMNMC <= IM_MULI;
        WRD <= '1';
        RRA <= '1';
        WOVF <= '1';
        ALU_OP <= ALU_MUL;

      when 6 =>
        -- lmuli rD,rA,imm12
        IMNMC <= IM_LMULI;
        WRD <= '1';
        RRA <= '1';
        LD <= '1';
        --LA <= '1';
        --LB <= '1';
        WOVF <= '1';
        ALU_OP <= ALU_LMUL;

      when 7 =>
        -- lmulai rD,rA,imm12
        IMNMC <= IM_MULAI;
        WRD <= '1';
        RRA <= '1';
        ALU_OP <= ALU_MULA;

      when 8 =>
        -- RRI8 instructions
        case OP2 is
          when 0 =>
            -- shli rD,rA,imm8
            IMNMC <= IM_SHLI;
            WRD <= '1';
            RRA <= '1';
            WOVF <= '1';
            ALU_OP <= ALU_SHL;
          when 1 =>
            -- lshli rD,rA,imm8
            IMNMC <= IM_LSHLI;
            WRD <= '1';
            RRA <= '1';
            LD <= '1';
            LA <= '1';
            WOVF <= '1';
            ALU_OP <= ALU_LSHL;
          when 2 =>
            -- shri rD,rA,imm8
            IMNMC <= IM_SHRI;
            WRD <= '1';
            RRA <= '1';
            ALU_OP <= ALU_SHR;
          when 3 =>
            -- lshri rD,rA,imm8
            IMNMC <= IM_LSHRI;
            WRD <= '1';
            RRA <= '1';
            LD <= '1';
            LA <= '1';
            ALU_OP <= ALU_LSHR;
          --when 4 =>
          --  -- andli rD,rA,imm8
          --  IMNMC <= IM_ANDLI;
          --  WRD <= '1';
          --  RRA <= '1';
          --  ALU_OP <= ALU_ANDL;
          --when 5 =>
          --  -- andhi rD,rA,imm8
          --  IMNMC <= IM_ANDHI;
          --  WRD <= '1';
          --  RRA <= '1';
          -- ALU_OP <= ALU_ANDH;
          --when 6 =>
          --  -- orli rD,rA,imm8
          --  IMNMC <= IM_ORLI;
          --  WRD <= '1';
          --  RRA <= '1';
          --  ALU_OP <= ALU_ORL;
          --when 7 =>
          --  -- orhi rD,rA,imm8
          --  IMNMC <= IM_ORHI;
          --  WRD <= '1';
          --  RRA <= '1';
          --  ALU_OP <= ALU_ORH;
          when 8 =>
            -- beq rA,rB,imm8
            IMNMC <= IM_BEQ;
            RRA <= '1';
            RRB <= '1';
            IMNMC <= IM_BEQ;
            BJ_OP <= BJ_BEQ;
            P0_ONLY <= '1';
          when 9 =>
            -- bne rA,rB,imm8
            IMNMC <= IM_BNE;
            RRA <= '1';
            RRB <= '1';
            BJ_OP <= BJ_BNE;
            P0_ONLY <= '1';
          when 10 =>
            -- ld rD,rA,imm8
            IMNMC <= IM_LD;
            WRD <= '1';
            RRA <= '1';
            LS_OP <= LS_LD;
          when 11 =>
            -- st rA,rB,imm8
            IMNMC <= IM_ST;
            RRA <= '1';
            RRB <= '1';
            LS_OP <= LS_ST;
            P0_ONLY <= '1';
          --when 12 =>
          --  -- ldpp rD,rA,imm8
          --  IMNMC <= IM_LDPP;
          --  WRD <= '1';
          --  WRD2 <= '1';
          --  RRA <= '1';
          --  ALU_OP <= ALU_INC;
          --  LS_OP <= LS_LD;
          --  --SC <= '0';
          --when 13 =>
          --  -- stpp rA,rB,imm8
          --  IMNMC <= IM_STPP;
          --  WRD2 <= '1';
          --  RRA <= '1';
          --  RRB <= '1';
          --  ALU_OP <= ALU_INC;
          --  LS_OP <= LS_ST;
          when others =>
            IMNMC <= IM_BAD_INSTR;
        end case;

      when 9 =>
        -- lmaci rD,rA,imm12
        IMNMC <= IM_LMACI;
        WRD <= '1';
        RRA <= '1';
        LD <= '1';
        WACC <= '1';
        WOVF <= '1';
        ALU_OP <= ALU_LMAC;

      when 10 =>
        -- lmsui rD,rA,imm12
        IMNMC <= IM_LMSUI;
        WRD <= '1';
        RRA <= '1';
        LD <= '1';
        WACC <= '1';
        WOVF <= '1';
        ALU_OP <= ALU_LMSU;

      when 11 =>
        -- jmpli rD,imm16
        IMNMC <= IM_JMPLI;
        WRD <= '1';
        BJ_OP <= BJ_JIL;
        ALU_OP <= ALU_MOVA;
        P0_ONLY <= '1';

      when 12 =>
        -- RI12 or I16 instruction
        case OP2 is
          when 0 =>
            -- blez rA,imm12
            IMNMC <= IM_BLEZ;
            RRA <= '1';
            BJ_OP <= BJ_BLEZ;
            P0_ONLY <= '1';
          when 1 =>
            -- lblez rA,imm12
            IMNMC <= IM_LBLEZ;
            RRA <= '1';
            LA <= '1';
            BJ_OP <= BJ_LBLEZ;
            P0_ONLY <= '1';
          when 2 =>
            -- bgtz rA,imm12
            IMNMC <= IM_BGTZ;
            RRA <= '1';
            BJ_OP <= BJ_BGTZ;
            P0_ONLY <= '1';
          when 3 =>
            -- lbgtz rA,imm12
            IMNMC <= IM_LBGTZ;
            RRA <= '1';
            LA <= '1';
            BJ_OP <= BJ_LBGTZ;
            P0_ONLY <= '1';
          when 4 =>
            -- bltz rA,imm12
            IMNMC <= IM_BLTZ;
            RRA <= '1';
            BJ_OP <= BJ_BLTZ;
            P0_ONLY <= '1';
          when 5 =>
            -- lbltz rA,imm12
            IMNMC <= IM_LBLTZ;
            RRA <= '1';
            LA <= '1';
            BJ_OP <= BJ_LBLTZ;
            P0_ONLY <= '1';
          when 6 =>
            -- bgez rA,imm12
            IMNMC <= IM_BGEZ;
            RRA <= '1';
            BJ_OP <= BJ_BGEZ;
            P0_ONLY <= '1';
          when 7 =>
            -- lbgez rA,imm12
            IMNMC <= IM_LBGEZ;
            RRA <= '1';
            LA <= '1';
            BJ_OP <= BJ_LBGEZ;
            P0_ONLY <= '1';
          when 8 =>
            -- jmpi imm16
            IMNMC <= IM_JMPI;
            BJ_OP <= BJ_JI;
            P0_ONLY <= '1';
          when 9 =>
            -- llbri imm16
            IMNMC <= IM_LLBRI;
            P0_ONLY <= '1';
          when 10 =>
            -- lleri imm16
            IMNMC <= IM_LLERI;
            P0_ONLY <= '1';
          when 11 =>
            -- llcri imm16
            IMNMC <= IM_LLCRI;
            P0_ONLY <= '1';
          when others =>
            IMNMC <= IM_BAD_INSTR;
        end case;

      when 13 =>
        -- movi rD,imm16
        IMNMC <= IM_MOVI;
        WRD <= '1';
        ALU_OP <= ALU_MOVB;

      when others =>
        -- invalid instruction
        IMNMC <= IM_BAD_INSTR;

    end case;
  end process;

  OPB_IMM_o <= '0' when
    (OP1 = 0) or 
    ((OP1 = 8) and (OP2 = 8 or OP2 = 9 or OP2 = 11 or OP2 = 13))
    else '1';

  -- Operand B selector
  process(OP1,OP2,OP2_RRR,IMM8,IMM12,IMM12_S,IMM16,IMM16_S)
  begin
    case OP1 is
      when 1|2|3|4|5|6|7|9|10 =>
        OPB_o <= EXTS32(IMM12);
      when 8 =>
        OPB_o <= EXTS32(IMM8);
      when 11|13 =>
        OPB_o <= EXTS32(IMM16);
      when 12 =>
        if(OP2 = 8 or OP2 = 9 or OP2 = 10 or OP2 = 11) then
          OPB_o <= EXTS32(IMM16_S);
        else
          OPB_o <= EXTS32(IMM12_S);
        end if;
      when others =>
        OPB_o <= (others => '0');
    end case;
  end process;

  IMM <= (others => '0');

  -- decoded instruction
  DEC_INSTR_o <= (
    IMNMC,
    WRD,
    RRA,
    RRB,
    RD,
    RA,
    RB,
    IMM,
    LD,
    LA,
    LB,
    ALU_OP,
    BJ_OP,
    LS_OP,
    WOVF,
    WACC,
    P0_ONLY
  );

end ARC;