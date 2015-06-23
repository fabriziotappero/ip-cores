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
-- G.729a ASIP loop control stack management logic (IX1 stage)
---------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library WORK;
use WORK.G729A_ASIP_PKG.all;
use work.G729A_ASIP_IDEC_2W_PKG.all;

entity G729A_ASIP_LCSTKLOG_IX is
  port(
    IX_V_i : in std_logic;
    IX_INSTR_i : in DEC_INSTR_T;
    IX_OPA_i : in LDWORD_T;

    SRST_o : out std_logic;
    LLBRX_o : out std_logic; -- llbri eXecute flag
    LLERX_o : out std_logic; -- lleri eXecute flag
    LLCRX_o : out std_logic; -- llcnt/llcnti eXecute flag
    IMM_o : out unsigned(ALEN-1 downto 0) -- loop count
  );
end G729A_ASIP_LCSTKLOG_IX;

architecture ARC of G729A_ASIP_LCSTKLOG_IX is

  function to_unsigned(S : signed) return unsigned is
    variable U : unsigned(S'high downto S'low);
  begin
    for i in S'low to S'high loop
      U(i) := S(i);
    end loop;
    return(U);
  end function;

begin

  SRST_o <= IX_V_i when 
    (IX_INSTR_i.IMNMC = IM_LCLR) else '0';

  LLCRX_o <= IX_V_i when 
    (IX_INSTR_i.IMNMC = IM_LLCR) or (IX_INSTR_i.IMNMC = IM_LLCRI) else '0';

  LLBRX_o <= IX_V_i when 
    (IX_INSTR_i.IMNMC = IM_LLBRI) else '0';

  LLERX_o <= IX_V_i when 
    (IX_INSTR_i.IMNMC = IM_LLERI) else '0';

  IMM_o <= to_unsigned(IX_OPA_i(ALEN-1 downto 0)) when
    (IX_INSTR_i.IMNMC = IM_LLCR) else to_unsigned(IX_INSTR_i.IMM);

end ARC;