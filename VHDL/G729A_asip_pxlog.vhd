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

---------------------------------------------------------
-- G.729A ASIP Pipeline eXecution logic 
---------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all; 
use IEEE.numeric_std.all;

library WORK;
use WORK.G729A_ASIP_PKG.all;
--use WORK.G729A_ASIP_BASIC_PKG.all;
--use WORK.G729A_ASIP_ARITH_PKG.all;
use work.G729A_ASIP_IDEC_2W_PKG.all;

entity G729A_ASIP_PXLOG is
  port(
    ID_INSTR0_i : in DEC_INSTR_T;
    ID_INSTR1_i : in DEC_INSTR_T;
    ID_V_i : in std_logic_vector(2-1 downto 0);
    ID_FWDE_i : in std_logic_vector(2-1 downto 0);

    PXE1_o : out std_logic
  );
end G729A_ASIP_PXLOG;

architecture ARC of G729A_ASIP_PXLOG is

  function plus1(A : RID_T) return RID_T is
    variable UA1,UA2 : unsigned(4-1 downto 0);
  begin
    UA1 := to_unsigned(A,4);
    UA2 := UA1(4-1 downto 1) & '1';
    return(to_integer(UA2));
  end function;

  function rmtch_a(IDI,IXI : DEC_INSTR_T; RAP1,RDP1 : RID_T) return std_logic is
  begin
    if(
      (IDI.RA = IXI.RD) or
      (IDI.LA = '1' and (RAP1 = IXI.RD)) or
      (IXI.LD = '1' and (IDI.RA = RDP1))
    ) then
      return('1');
    else
      return('0');
    end if;
  end function;

  function rmtch_b(IDI,IXI : DEC_INSTR_T; RBP1,RDP1 : RID_T)
    return std_logic is
  begin
    if(
      (IDI.RB = IXI.RD) or
      (IDI.LB = '1' and (RBP1 = IXI.RD)) or
      (IXI.LD = '1' and (IDI.RB = RDP1))
    ) then
      return('1');
    else
      return('0');
    end if;
  end function;

  function dep_a(RMTCH,IDV,IXV : std_logic;IDI,IXI : DEC_INSTR_T)
    return std_logic is
  begin
    if(
      (RMTCH = '1') and (IDI.RRA = '1') and (IXI.WRD = '1')
    ) then
      return(IDV and IXV);
    else
      return('0');
    end if;
  end function;

  function dep_b(RMTCH,IDV,IXV : std_logic;IDI,IXI : DEC_INSTR_T)
    return std_logic is
  begin
    if(
      (RMTCH = '1') and (IDI.RRB = '1') and (IXI.WRD = '1')
    ) then
      return(IDV and IXV);
    else
      return('0');
    end if;
  end function;

  function stall_a(DEP,FWDE,IX_2C : std_logic;IDI,IXI : DEC_INSTR_T)
    return std_logic is
  begin
    if(
      (DEP = '1') and ((FWDE = '0') or (IX_2C = '1') or (IDI.LA /= IXI.LD))
    ) then
      return('1');
    else
      return('0');
    end if;
  end function;

  function stall_b(DEP,FWDE,IX_2C : std_logic;IDI,IXI : DEC_INSTR_T)
    return std_logic is
  begin
    if(
      (DEP = '1') and ((FWDE = '0') or (IX_2C = '1') or (IDI.LB /= IXI.LD))
    ) then
      return('1');
    else
      return('0');
    end if;
  end function;

  signal RAP1,RBP1 : RID_T;
  signal RDP1 : RID_T;
  signal DATA_DEPA : std_logic;
  signal DATA_DEPB : std_logic;
  signal RMTCH_A_ID0 : std_logic;
  signal RMTCH_B_ID0 : std_logic;
  signal MAC0,MAC1 : std_logic;

begin

  ----------------------------------------------------
  -- General rules:
  ----------------------------------------------------

  -- Instruction #0 is executed if:
  -- 1) there's no data dependency from instructions
  -- in IX1 and IX2 stages.

  -- Instruction #1 is executed if:
  -- 1) there's no data dependency from instructions
  -- in IX1 and IX2 stages.
  -- 2) it's doesn't need instruction #0 result, AND
  -- 3) it can be executed by pipeline "A" (i.e. it's
  -- a forward-enabled instruction) AND
  -- 4) instruction #0 is executed (in-order issue!).

  -- Condition 1) is checked by pipe stalling logic
  -- and therefore this module assumes no stall occurs.

  ----------------------------------------------------

  -- Note: when a long result is needed/generated,
  -- register id. RX is always an even one, and therefore
  -- RX+1 can be generated simply setting LSb to '1'.

  -- ID instr. #1 RA+1
  RAP1 <= plus1(ID_INSTR1_i.RA);

  -- ID instr. #1 RB+1
  RBP1 <= plus1(ID_INSTR1_i.RB);

  -- IX1 instr. #0 RD+1
  RDP1 <= plus1(ID_INSTR0_i.RD);

  ----------------------------------------------------

  -- Register match flags

  -- ID instr. #0 vs. ID instr. #1 register match flags 
  -- (when a flag is asserted, there's a match between a
  -- register read by ID instruction #1 and the register
  -- written by ID instruction #0).
  -- Three possible cases must be checked:
  -- 1) ID instruction #1 needs a short (long) result and 
  -- ID instruction #0 generates a short (long) one -> 
  -- comparing RA/B to RD is enough.
  -- 2) ID instruction #1 needs a long result and ID
  -- instruction #0 generates a short one -> RD must be
  -- compared to RA/B and (RA/B)+1.
  -- 3) ID instruction #1 needs a short result and ID
  -- instruction #0 generates a long one -> RA/B must be
  -- compared to RD and (RD)+1.

  RMTCH_A_ID0 <= rmtch_a(ID_INSTR1_i,ID_INSTR0_i,RAP1,RDP1);
  RMTCH_B_ID0 <= rmtch_b(ID_INSTR1_i,ID_INSTR0_i,RBP1,RDP1);

  ----------------------------------------------------

  -- Data dependence flags

  DATA_DEPA <=
    dep_a(RMTCH_A_ID0,ID_V_i(1),ID_V_i(1),ID_INSTR1_i,ID_INSTR0_i);

  DATA_DEPB <=
    dep_b(RMTCH_B_ID0,ID_V_i(1),ID_V_i(1),ID_INSTR1_i,ID_INSTR0_i);

  ----------------------------------------------------

  -- MAC instruction flags

  MAC0 <= '1' when(
    (ID_INSTR0_i.IMNMC = IM_LMAC) or
    (ID_INSTR0_i.IMNMC = IM_LMACI) or
    (ID_INSTR0_i.IMNMC = IM_LMSU) or
    (ID_INSTR0_i.IMNMC = IM_LMSUI) or
    (ID_INSTR0_i.IMNMC = IM_WACC)
  ) else '0';

  MAC1 <= '1' when(
    (ID_INSTR1_i.IMNMC = IM_LMAC) or
    (ID_INSTR1_i.IMNMC = IM_LMACI) or
    (ID_INSTR1_i.IMNMC = IM_LMSU) or
    (ID_INSTR1_i.IMNMC = IM_LMSUI) or
    (ID_INSTR0_i.IMNMC = IM_WACC)
  ) else '0';

  ----------------------------------------------------

  -- parallel execution (of instr. #1) flag

  PXE1_o <=
    not(DATA_DEPA or DATA_DEPB) and -- instr. #1 doesn't depend from #0
    ID_FWDE_i(1) and -- instr. #1 can execute on pipe #1
    not(MAC0 and MAC1); -- instr. #0 and #1 are not both of MAC-type

end;

