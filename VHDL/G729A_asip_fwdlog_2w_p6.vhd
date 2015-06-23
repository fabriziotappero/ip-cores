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
-- G.729a ASIP result forwarding logic
---------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use STD.textio.all;

library work;
use work.G729A_ASIP_PKG.all;
use work.G729A_ASIP_IDEC_2W_PKG.all;
--use WORK.G729A_ASIP_BASIC_PKG.all;
--use WORK.G729A_ASIP_ARITH_PKG.all;
use WORK.G729A_ASIP_OP_PKG.all;

entity G729A_ASIP_FWDLOG_2W_P6 is
  port(
    ID_RX_i : in RID_T;
    ID_RRX_i : in std_logic;
    IX1_INSTR0_i : in DEC_INSTR_T;
    IX2_INSTR0_i : in DEC_INSTR_T;
    IX3_INSTR0_i : in DEC_INSTR_T;
    IX1_INSTR1_i : in DEC_INSTR_T;
    IX2_INSTR1_i : in DEC_INSTR_T;
    IX3_INSTR1_i : in DEC_INSTR_T;
    IX1_PA_RES0_i : in SDWORD_T;
    IX1_PA_RES1_i : in SDWORD_T;
    IX2_PA_RES0_i : in LDWORD_T;
    IX2_PA_RES1_i : in LDWORD_T;
    IX3_PA_RES0_i : in LDWORD_T;
    IX3_PA_RES1_i : in LDWORD_T;
    ID_OPX_NOFWD_i : in LDWORD_T;
    IX1_V_i : in std_logic_vector(2-1 downto 0);
    IX2_V_i : in std_logic_vector(2-1 downto 0);
    IX3_V_i : in std_logic_vector(2-1 downto 0);
    IX1_FWDE_i : in std_logic_vector(2-1 downto 0);
    IX2_FWDE_i : in std_logic_vector(2-1 downto 0);
    IX3_FWDE_i : in std_logic_vector(2-1 downto 0);
    NOREGS_i : in std_logic;
    NOREGD_i : in LDWORD_T;

    ID_OPX_o : out LDWORD_T
  );
end G729A_ASIP_FWDLOG_2W_P6;

architecture ARC of G729A_ASIP_FWDLOG_2W_P6 is

  constant SZERO : SDWORD_T := (others => '0');
  --signal FWDX : std_logic_vector(3 downto 0);

begin

  -- Operand A can be forwarded from stages IX and MA.
  -- When forwarding from IX stage, result can come from
  -- ALU single-cycle result output or from LSU read data output.
  -- When forwarding from MA stage, result can come from
  -- ALU double-cycle result output only.

  -- WARNING: it's assumed that *_INSTR.RD always differs from
  -- *_INSTR_RD2 because a register can be written only once per
  -- cycle. If this condition is not satisfied ASIP behavior is
  -- undefined.

  process(ID_RX_i,ID_RRX_i,
    IX1_INSTR0_i,IX2_INSTR0_i,IX1_INSTR1_i,IX2_INSTR1_i,
    IX3_INSTR0_i,IX3_INSTR1_i,
    IX1_PA_RES0_i,IX1_PA_RES1_i,IX2_PA_RES0_i,IX2_PA_RES1_i,
    IX3_PA_RES0_i,IX3_PA_RES1_i,
    ID_OPX_NOFWD_i,IX1_V_i,IX2_V_i,IX3_V_i,
    IX1_FWDE_i,IX2_FWDE_i,IX3_FWDE_i,
    NOREGS_i,NOREGD_i)
    variable FWD_IX : std_logic_vector(5 downto 0);
  begin

    -- forwarding from IX1 stage occurs if:
    -- 1) ID stage instr. rA matches IX1 stage instr. rD AND
    -- 2) ID stage instr. reads rA AND
    -- 3) IX1 stage instr. writes rD AND
    -- 4) ID stage instr. is valid (IX1 stage one always is), AND
    -- 5) IX1 instr. is forward-enabled

    if(ID_RX_i = IX1_INSTR0_i.RD) then
      FWD_IX(0) := IX1_INSTR0_i.WRD and IX1_V_i(0) and
        IX1_FWDE_i(0); -- and ID_RRX_i;
    else
      FWD_IX(0) := '0';
    end if;

    if(ID_RX_i = IX1_INSTR1_i.RD) then
      FWD_IX(1) := IX1_INSTR1_i.WRD and IX1_V_i(1) and
        IX1_FWDE_i(1); -- and ID_RRX_i;
    else
      FWD_IX(1) := '0';
    end if;

    -- forwarding from IX2 stage occurs if:
    -- 1) ID stage instr. rA matches IX2 stage instr. rD AND
    -- 2) ID stage instr. reads rA AND
    -- 3) IX2 stage instr. writes rD AND
    -- 4) ID stage instr. is valid (IX1 stage one always is), AND
    -- 5) IX2 instr. is forward-enabled

    if(ID_RX_i = IX2_INSTR0_i.RD) then
      FWD_IX(2) := IX2_INSTR0_i.WRD and IX2_V_i(0) and
        IX2_FWDE_i(0); -- and ID_RRX_i;
    else
      FWD_IX(2) := '0';
    end if;

    if(ID_RX_i = IX2_INSTR1_i.RD) then
      FWD_IX(3) := IX2_INSTR1_i.WRD and IX2_V_i(1) and
        IX2_FWDE_i(1); -- and ID_RRX_i;
    else
      FWD_IX(3) := '0';
    end if;

    -- forwarding from IX3 stage occurs if:
    -- 1) ID stage instr. rA matches IX3 stage instr. rD AND
    -- 2) ID stage instr. reads rA AND
    -- 3) IX3 stage instr. writes rD AND
    -- 4) ID stage instr. is valid (IX1 stage one always is), AND
    -- 5) IX3 instr. is forward-enabled

    if(ID_RX_i = IX3_INSTR0_i.RD) then
      FWD_IX(4) := IX3_INSTR0_i.WRD and IX3_V_i(0) and
        IX3_FWDE_i(0); -- and ID_RRX_i;
    else
      FWD_IX(4) := '0';
    end if;

    if(ID_RX_i = IX3_INSTR1_i.RD) then
      FWD_IX(5) := IX3_INSTR1_i.WRD and IX3_V_i(1) and
        IX3_FWDE_i(1); -- and ID_RRX_i;
    else
      FWD_IX(5) := '0';
    end if;

    ---- result forwarding mux
    --if(FWD_IX(0) = '1' and ID_RRX_i = '1') then
    --  ID_OPX_o <= SZERO & IX1_PA_RES0_i;
    --elsif(FWD_IX(1) = '1' and ID_RRX_i = '1') then
    --  ID_OPX_o <= SZERO & IX1_PA_RES1_i;
    --elsif(FWD_IX(2) = '1' and ID_RRX_i = '1') then
    --  ID_OPX_o <= IX2_PA_RES0_i;
    --elsif(FWD_IX(3) = '1' and ID_RRX_i = '1') then
    --  ID_OPX_o <= IX2_PA_RES1_i;
    --elsif((FWD_IX(4) = '0' and FWD_IX(5) = '0') or ID_RRX_i = '0') then
    --  if(NOREGS_i = '0') then
    --    ID_OPX_o <= ID_OPX_NOFWD_i; -- give higher priority to RF output
    --  else
    --    ID_OPX_o <= NOREGD_i;
    --  end if;
    --elsif(FWD_IX(4) = '1' and ID_RRX_i = '1') then
    --  ID_OPX_o <= IX3_PA_RES0_i;
    --else --elsif(FWD_IX(5) = '1' and ID_RRX_i = '1') then
    --  ID_OPX_o <= IX3_PA_RES1_i;
    ----else
    ----  ID_OPX_o <= ID_OPX_NOFWD_i;
    --end if;

    -- result forwarding mux
    if(FWD_IX(1) = '1' and NOREGS_i = '0') then
      ID_OPX_o <= SZERO & IX1_PA_RES1_i;
    elsif(FWD_IX(0) = '1' and NOREGS_i = '0') then
      ID_OPX_o <= SZERO & IX1_PA_RES0_i;
    elsif(FWD_IX(3) = '1' and NOREGS_i = '0') then
      ID_OPX_o <= IX2_PA_RES1_i;
    elsif(FWD_IX(2) = '1' and NOREGS_i = '0') then
      ID_OPX_o <= IX2_PA_RES0_i;
    elsif((FWD_IX(4) = '0' and FWD_IX(5) = '0') and NOREGS_i = '0') then
        ID_OPX_o <= ID_OPX_NOFWD_i; -- give higher priority to RF output
    elsif(NOREGS_i = '1') then
        ID_OPX_o <= NOREGD_i;
    elsif(FWD_IX(5) = '1') then -- and NOREGS_i = '0') then
      ID_OPX_o <= IX3_PA_RES1_i;
    else --elsif(FWD_IX(4) = '1' and NOREGS_i = '0') then
      ID_OPX_o <= IX3_PA_RES0_i;
    --else
    --  ID_OPX_o <= ID_OPX_NOFWD_i;
    end if;

    --FWDX <= FWD_IX;

  end process;

end ARC;
