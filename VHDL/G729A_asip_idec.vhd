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
-- Instruction decoder (stage 2)
---------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.G729A_ASIP_PKG.all;
use work.G729A_ASIP_OP_PKG.all;

entity G729A_ASIP_IDEC2 is
  port(
    INSTR_i : in std_logic_vector(ILEN-1 downto 0);
    DRA_i : in std_logic_vector(LDLEN-1 downto 0);
    DRB_i : in std_logic_vector(LDLEN-1 downto 0);
    PCP1_i : in std_logic_vector(ALEN-1 downto 0);
    OPB_IMM_i : in std_logic;
    OPB_i : in LDWORD_T;
    ID_V_i : in std_logic;

    OPA_o : out LDWORD_T;
    OPB_o : out LDWORD_T;
    OPC_o : out SDWORD_T;
    IMM_o : out SDWORD_T;
    JL_o : out std_logic;
    HALT_o : out std_logic
  );
end G729A_ASIP_IDEC2;

architecture ARC of G729A_ASIP_IDEC2 is

  signal OP1 : integer range 0 to 16-1;
  signal OP2 : integer range 0 to 16-1;
  signal OP2_RRR : integer range 0 to 256-1;
  signal IMM8,IMM8_S : std_logic_vector(8-1 downto 0);
  signal IMM12,IMM12_S : std_logic_vector(12-1 downto 0);
  signal IMM16,IMM16_S : std_logic_vector(16-1 downto 0);
  signal IMM : signed(16-1 downto 0);
  signal JL : std_logic;

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

  function to_signed(U : unsigned) return signed is
    variable S : signed(U'HIGH downto U'LOW);
  begin
    for i in U'HIGH downto U'LOW loop
      S(i) := U(i);
    end loop;
    return(S);
  end function;

begin
 
  -- instruction subfields extraction
  process(INSTR_i)
    --variable B0,B1,B2,B3,B4,B5 : std_logic_vector(4-1 downto 0);
    variable B0,B1,B5 : std_logic_vector(4-1 downto 0);
    variable TMP : std_logic_vector(8-1 downto 0);
  begin

    B0 := INSTR_i(4*1-1 downto 4*0);
    B1 := INSTR_i(4*2-1 downto 4*1);
    --B2 := INSTR_i(4*3-1 downto 4*2);
    --B3 := INSTR_i(4*4-1 downto 4*3);
    --B4 := INSTR_i(4*5-1 downto 4*4);
    B5 := INSTR_i(4*6-1 downto 4*5);

    -- major opcode
    OP1 <= to_integer(to_unsigned(B5));

    -- minor opcode
    OP2 <= to_integer(to_unsigned(B0));

    -- minor opcode for RRR type instructions

    -- WARNING: this extra step is needed to
    -- insure correct ordering!
    TMP := (B1 & B0);

    OP2_RRR <= to_integer(to_unsigned(TMP));

    -- immediate operands
    IMM8 <= INSTR_i(12-1 downto 4);
    IMM8_S <= INSTR_i(20-1 downto 16) & INSTR_i(8-1 downto 4);
    IMM12 <= INSTR_i(12-1 downto 0);
    IMM12_S <= INSTR_i(20-1 downto 16) & INSTR_i(12-1 downto 4);
    IMM16 <= INSTR_i(16-1 downto 0);
    IMM16_S <= INSTR_i(20-1 downto 4);

  end process;

  -- jump & link instruction flag
  JL <= '1' when ((OP1 = 0 and OP2_RRR = 27) or (OP1 = 11)) else '0';

  JL_o <= JL;

  -- operand A is supplied by register file, unless
  -- instruction is a jump & link one (operand value
  -- is return address).

  OPA_o <= EXTS32(PCP1_i) when (JL = '1') else to_signed(DRA_i);

  -- operand B is supplied by register file, unless
  -- instruction takes an immediate operand.

  OPB_o <= OPB_i when OPB_IMM_i = '1' else to_signed(DRB_i);

  -- Operand C (actually used only by beq, bne, st and stpp instructions)
  OPC_o <= EXTS16(IMM8_S);

  -- immediate value selector
  process(OP1,OP2,IMM8,IMM8_S,IMM12,IMM12_S,IMM16,IMM16_S)
  begin
    case OP1 is
      when 8 =>
        if(OP2 = 8 or OP2 = 9 or OP2 = 11 or OP2 = 13) then
          IMM <= EXTS16(IMM8_S);
        else
          IMM <= EXTS16(IMM8);
        end if;
      when 12 =>
        if(OP2 = 8 or OP2 = 9 or OP2 = 10 or OP2 = 11) then
          IMM <= to_signed(IMM16_S);
        else
          IMM <= EXTS16(IMM12_S);
        end if;
      when 11|13 =>
        IMM <= to_signed(IMM16);
      when others =>
        IMM <= EXTS16(IMM12);
    end case;
  end process;

  IMM_o <= IMM;

  -- increment-rA flag generation
  HALT_o <= ID_V_i when (OP1 = 0 and OP2_RRR = 29) else '0';

end ARC;
