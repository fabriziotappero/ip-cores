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
-- G.729A ASIP ALU, B/J and load/store operations package
---------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library WORK;
use WORK.G729A_ASIP_PKG.all;

package G729A_ASIP_OP_PKG is

  -- Scalar ALU operation type
  type ALU_OP_T is (
    ALU_ABS,
    ALU_ADD,
    ALU_NEG,
    ALU_SUB,
    ALU_LABS,
    ALU_LADD,
    ALU_LNEG,
    ALU_LSUB,
    ALU_LEXT,
    ALU_RND,
    ALU_MUL,
    ALU_LMUL,
    ALU_MULA,
    ALU_SHL,
    ALU_SHR,
    ALU_LSHL,
    ALU_LSHR,
    ALU_NRMS,
    ALU_NRML,
    ALU_LMAC,
    ALU_LMSU,
    ALU_MULR,
    ALU_M32,
    ALU_M3216,
    ALU_AND,
    ALU_ANDL,
    ALU_ANDH,
    ALU_OR,
    ALU_ORL,
    ALU_ORH,
    ALU_ROVF,
    ALU_COVF,
    ALU_RACC,
    ALU_WACC,
    ALU_MOVA,
    ALU_MOVB,
    ALU_INC,
    ALU_DEC,
    ALU_NIL
  );

  type BJ_OP_T is (
    BJ_BEQ,
    BJ_BNE,
    BJ_JI,
    BJ_JIL,
    BJ_JR,
    BJ_JRL,
    BJ_BLEZ,
    BJ_BGTZ,
    BJ_BLTZ,
    BJ_BGEZ,
    BJ_LBLEZ,
    BJ_LBGTZ,
    BJ_LBLTZ,
    BJ_LBGEZ,
    BJ_NIL
  );

  type LS_OP_T is (
    LS_LD,
    LS_ST,
    LS_NIL
  );
  
end package;