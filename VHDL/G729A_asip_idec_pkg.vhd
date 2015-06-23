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
-- Instruction decoding data types
---------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.G729A_ASIP_PKG.all;
use work.G729A_ASIP_OP_PKG.all;

package G729A_ASIP_IDEC_PKG is

  type INST_MNEMONIC_T is (
    IM_ABS,
    IM_LABS,
    IM_ADD,
    IM_LADD,
    IM_ADDI,
    IM_LADDI,
    IM_NEG,
    IM_LNEG,
    IM_SUB,
    IM_LSUB,
    IM_SUBI,
    IM_LSUBI,
    IM_LEXT,
    IM_RND,
    IM_MUL,
    IM_LMUL,
    IM_MULI,
    IM_LMULI,
    IM_MULA,
    IM_MULAI,
    IM_SHL,
    IM_LSHL,
    IM_SHLI,
    IM_LSHLI,
    IM_SHR,
    IM_LSHR,
    IM_SHRI,
    IM_LSHRI,
    IM_NRMS,
    IM_NRML,
    IM_LMAC,
    IM_LMACI,
    IM_LMSU,
    IM_LMSUI,
    IM_MULR,
    IM_M32, -- not implemented
    IM_M3216,
    IM_AND,
    IM_ANDLI, -- not implemented
    IM_ANDHI, -- not implemented
    IM_OR,
    IM_ORLI, -- not implemented
    IM_ORHI, -- not implemented
    IM_JMP,
    IM_JMPI,
    IM_JMPL,
    IM_JMPLI,
    IM_BEQ,
    IM_BNE,
    IM_BLEZ,
    IM_LBLEZ,
    IM_BGTZ,
    IM_LBGTZ,
    IM_BLTZ,
    IM_LBLTZ,
    IM_BGEZ,
    IM_LBGEZ,
    IM_HALT,
    IM_LLBRI,
    IM_LLERI,
    IM_LLCR,
    IM_LLCRI,
    IM_LCLR,
    IM_LD,
    IM_ST,
    IM_LDPP, -- not implemented
    IM_STPP, -- not implemented
    IM_ROVF,
    IM_COVF,
    IM_RACC,
    IM_WACC,
    IM_MOVI,
    IM_NOP,
    IM_PXON,
    IM_PXOFF,
    IM_BAD_INSTR -- this is not a valid instruction!
  );

  type DEC_INSTR_T is record
    IMNMC : INST_MNEMONIC_T;
    WRD : std_logic;
    WRD2 : std_logic;
    RRA : std_logic;
    RRB : std_logic;
    RD : RID_T;
    RD2 : RID_T;
    RA : RID_T;
    RB : RID_T;
    IMM : signed(16-1 downto 0);
    LD : std_logic;
    LD2 : std_logic;
    LA : std_logic;
    LB : std_logic;
    INCA : std_logic;
    ALU_OP : ALU_OP_T;
    BJ_OP : BJ_OP_T;
    LS_OP : LS_OP_T;
    WOVF : std_logic;
    WACC : std_logic;
    SC : std_logic;
  end record;

end package;