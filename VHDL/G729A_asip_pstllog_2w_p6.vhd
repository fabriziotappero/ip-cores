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
-- G.729A ASIP Pipeline stall logic 
---------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all; 
use IEEE.numeric_std.all;

library WORK;
use WORK.G729A_ASIP_PKG.all;
--use WORK.G729A_ASIP_BASIC_PKG.all;
--use WORK.G729A_ASIP_ARITH_PKG.all;
use work.G729A_ASIP_IDEC_2W_PKG.all;

entity G729A_ASIP_PSTLLOG_2W_P6 is
  generic(
    SIMULATION_ONLY : std_logic := '0'
  );
  port(
    CLK_i : in std_logic;
    ID_INSTR_i : in DEC_INSTR_T;
    ID_V_i : in std_logic;
    IX1_INSTR0_i : in DEC_INSTR_T;
    IX1_INSTR1_i : in DEC_INSTR_T;
    IX1_V_i : in std_logic_vector(2-1 downto 0);
    IX1_FWDE_i : in std_logic_vector(2-1 downto 0);
    IX2_INSTR0_i : in DEC_INSTR_T;
    IX2_INSTR1_i : in DEC_INSTR_T;
    IX2_V_i : in std_logic_vector(2-1 downto 0);
    IX2_FWDE_i : in std_logic_vector(2-1 downto 0);
    IX3_INSTR0_i : in DEC_INSTR_T;
    IX3_INSTR1_i : in DEC_INSTR_T;
    IX3_V_i : in std_logic_vector(2-1 downto 0);
    IX3_FWDE_i : in std_logic_vector(2-1 downto 0);

    PSTALL_o : out std_logic
  );
end G729A_ASIP_PSTLLOG_2W_P6;

architecture ARC of G729A_ASIP_PSTLLOG_2W_P6 is

  function qmark(C : std_logic; A,B : std_logic) return std_logic is
  begin
    if(C = '1') then
      return(A);
    else
      return(B);
    end if;
  end function;

  function qmark(C : boolean; A,B : std_logic) return std_logic is
  begin
    if(C) then
      return(A);
    else
      return(B);
    end if;
  end function;

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
      (RMTCH = '1') -- and (IDI.RRA = '1') and (IXI.WRD = '1')
    ) then
      return(IDV and IXV and IDI.RRA and IXI.WRD);
    else
      return('0');
    end if;
  end function;

  function dep_b(RMTCH,IDV,IXV : std_logic;IDI,IXI : DEC_INSTR_T)
    return std_logic is
  begin
    if(
      (RMTCH = '1') -- and (IDI.RRB = '1') and (IXI.WRD = '1')
    ) then
      return(IDV and IXV and IDI.RRB and IXI.WRD);
    else
      return('0');
    end if;
  end function;

  function stall_a(DEP,FWDE,IX_2C : std_logic;IDI,IXI : DEC_INSTR_T)
    return std_logic is
  begin
    if(
      (DEP = '1') -- and ((FWDE = '0') or (IX_2C = '1') or (IDI.LA /= IXI.LD))
    ) then
      return(qmark((FWDE = '0') or (IX_2C = '1') or (IDI.LA /= IXI.LD),'1','0'));
    else
      return('0');
    end if;
  end function;

  function stall_b(DEP,FWDE,IX_2C : std_logic;IDI,IXI : DEC_INSTR_T)
    return std_logic is
  begin
    if(
      (DEP = '1') -- and ((FWDE = '0') or (IX_2C = '1') or (IDI.LB /= IXI.LD))
    ) then
      return(qmark((FWDE = '0') or (IX_2C = '1') or (IDI.LB /= IXI.LD),'1','0'));
    else
      return('0');
    end if;
  end function;

  signal IX_2C0,IX_2C1 : std_logic;
  signal DATA_DEPA_IX1_0,DATA_DEPA_IX2_0,DATA_DEPA_IX3_0 : std_logic;
  signal DATA_DEPB_IX1_0,DATA_DEPB_IX2_0,DATA_DEPB_IX3_0 : std_logic;
  signal DATA_DEPA_IX1_1,DATA_DEPA_IX2_1,DATA_DEPA_IX3_1 : std_logic;
  signal DATA_DEPB_IX1_1,DATA_DEPB_IX2_1,DATA_DEPB_IX3_1 : std_logic;
  signal RMTCH_A_IX1_0,RMTCH_A_IX2_0,RMTCH_A_IX3_0 : std_logic;
  signal RMTCH_B_IX1_0,RMTCH_B_IX2_0,RMTCH_B_IX3_0 : std_logic;
  signal RMTCH_A_IX1_1,RMTCH_A_IX2_1,RMTCH_A_IX3_1 : std_logic;
  signal RMTCH_B_IX1_1,RMTCH_B_IX2_1,RMTCH_B_IX3_1 : std_logic;
  signal RAP1,RBP1 : RID_T;
  signal RD1P1_0,RD2P1_0,RD3P1_0 : RID_T;
  signal RD1P1_1,RD2P1_1,RD3P1_1 : RID_T;
  signal STALL_A_IX1_0,STALL_A_IX2_0,STALL_A_IX3_0 : std_logic;
  signal STALL_B_IX1_0,STALL_B_IX2_0,STALL_B_IX3_0 : std_logic;
  signal STALL_A_IX1_1,STALL_A_IX2_1,STALL_A_IX3_1 : std_logic;
  signal STALL_B_IX1_1,STALL_B_IX2_1,STALL_B_IX3_1 : std_logic;

  type NVEC is array (8-1 downto 0) of natural;
  signal STALL_STATS : NVEC := (0,0,0,0,0,0,0,0);

begin

  ----------------------------------------------------
  -- General rules:
  ----------------------------------------------------
  --
  -- 1) Pipeline stall if ID instruction #0 can't be issued
  -- (if ID instruction #0 can be issued and instruction #1
  -- can't, pipeline is not stalled).
  --
  -- 2) Pipeline must be therefore stalled if oldest 
  -- ID stage instruction #0 needs a
  -- result generated by an instruction in IX1, or IX2, stage,
  -- and this instruction is not enabled to result forwarding
  -- (only add/i, sub/i, mul/i, movi, lmac/i, lmsu/i and ld/pp
  -- instructions are, and the latter three types are 2-cycle
  -- instructions that allow forwarding only from stage IX2).
  --
  -- 3) A long operand can be forwarded only from an instruction
  -- generating a long result, and not from two instructions (one
  -- in stage IX1 and one in stage IX2) generating each a short
  -- result.

  -- As a consequence, pipeline must be stalled (because result
  -- forwarding is not possible) if:
  -- 1) instruction #0 in ID stage needs a result generated by
  -- an instructions in IX1 or IX2 stage, AND [
  -- 2.a) the instruction in IX1, is not enabled to
  -- result forwarding or is a two-cycle instruction, OR
  -- 2.b) the instruction in IX2 stage is not enabled to result
  -- forwarding ] AND
  -- 3) the instruction in ID stage needs a long (short) result,
  -- while the instruction in IX1/2 generates a short (long) one.

  -- NOTE: only stages IF and ID get actually stalled, allowing
  -- following stages to proceed.

  ----------------------------------------------------

  -- two-cycle forward-enabled instruction flags

  IX_2C0 <= '1' when (
   (IX1_INSTR0_i.IMNMC = IM_LMAC) or 
   (IX1_INSTR0_i.IMNMC = IM_LMACI) or 
   (IX1_INSTR0_i.IMNMC = IM_LMSU) or 
   (IX1_INSTR0_i.IMNMC = IM_LMSUI) or
   (IX1_INSTR0_i.IMNMC = IM_LD)
  ) else '0';

  IX_2C1 <= '1' when (
   (IX1_INSTR1_i.IMNMC = IM_LMAC) or 
   (IX1_INSTR1_i.IMNMC = IM_LMACI) or 
   (IX1_INSTR1_i.IMNMC = IM_LMSU) or 
   (IX1_INSTR1_i.IMNMC = IM_LMSUI) or
   (IX1_INSTR1_i.IMNMC = IM_LD)
  ) else '0';

  ----------------------------------------------------

  -- Note: when a long result is needed/generated,
  -- register id. RX is always an even one, and therefore
  -- RX+1 can be generated simply setting LSb to '1'.

  -- ID instr. #0 RA+1
  RAP1 <= plus1(ID_INSTR_i.RA);

  -- ID instr. #0 RB+1
  RBP1 <= plus1(ID_INSTR_i.RB);

  -- IX1 instr. #0 RD+1
  RD1P1_0 <= plus1(IX1_INSTR0_i.RD);

  -- IX2 instr. #0 RD+1
  RD2P1_0 <= plus1(IX2_INSTR0_i.RD);

  -- IX3 instr. #0 RD+1
  RD3P1_0 <= plus1(IX3_INSTR0_i.RD);

  -- IX1 instr. #1 RD+1
  RD1P1_1 <= plus1(IX1_INSTR1_i.RD);

  -- IX2 instr. #1 RD+1
  RD2P1_1 <= plus1(IX2_INSTR1_i.RD);

  -- IX3 instr. #1 RD+1
  RD3P1_1 <= plus1(IX3_INSTR1_i.RD);

  ----------------------------------------------------

  -- ID instr. vs. IX1/2 instr. register match flags 
  -- (when a flag is asserted, there's a mtach between a
  -- register read by ID instruction and the register
  -- written by IX1/2 instruction).
  -- Three possible cases must be checked:
  -- 1) ID instruction needs a short (long) result and 
  -- IX1/2 instruction generates a short (long) one -> 
  -- comparing RA/B to RD is enough.
  -- 2) ID instruction needs a long result and IX1/2
  -- instruction generates a short one -> RD must be
  -- compared to RA/B and (RA/B)+1.
  -- 3) ID instruction needs a short result and IX1/2
  -- instruction generates a long one -> RA/B must be
  -- compared to RD and (RD)+1.

  -- RMTCH_x_IXy_z = '1' when there's a match between ID instruction
  -- operand register id. x and IXy instruction #z destination
  -- register id..

  RMTCH_A_IX1_0 <= rmtch_a(ID_INSTR_i,IX1_INSTR0_i,RAP1,RD1P1_0);
  RMTCH_A_IX2_0 <= rmtch_a(ID_INSTR_i,IX2_INSTR0_i,RAP1,RD2P1_0);
  RMTCH_A_IX3_0 <= rmtch_a(ID_INSTR_i,IX3_INSTR0_i,RAP1,RD3P1_0);
  RMTCH_B_IX1_0 <= rmtch_b(ID_INSTR_i,IX1_INSTR0_i,RBP1,RD1P1_0);
  RMTCH_B_IX2_0 <= rmtch_b(ID_INSTR_i,IX2_INSTR0_i,RBP1,RD2P1_0);
  RMTCH_B_IX3_0 <= rmtch_b(ID_INSTR_i,IX3_INSTR0_i,RBP1,RD3P1_0);
  RMTCH_A_IX1_1 <= rmtch_a(ID_INSTR_i,IX1_INSTR1_i,RAP1,RD1P1_1);
  RMTCH_A_IX2_1 <= rmtch_a(ID_INSTR_i,IX2_INSTR1_i,RAP1,RD2P1_1);
  RMTCH_A_IX3_1 <= rmtch_a(ID_INSTR_i,IX3_INSTR1_i,RAP1,RD3P1_1);
  RMTCH_B_IX1_1 <= rmtch_b(ID_INSTR_i,IX1_INSTR1_i,RBP1,RD1P1_1);
  RMTCH_B_IX2_1 <= rmtch_b(ID_INSTR_i,IX2_INSTR1_i,RBP1,RD2P1_1);
  RMTCH_B_IX3_1 <= rmtch_b(ID_INSTR_i,IX3_INSTR1_i,RBP1,RD3P1_1);

  ----------------------------------------------------

  -- DATA_DEPx_IXy_z = '1' when there's a data dependency between
  -- ID instruction operand x and IXy instruction #z result 

  DATA_DEPA_IX1_0 <=
    dep_a(RMTCH_A_IX1_0,ID_V_i,IX1_V_i(0),ID_INSTR_i,IX1_INSTR0_i);

  DATA_DEPA_IX2_0 <=
    dep_a(RMTCH_A_IX2_0,ID_V_i,IX2_V_i(0),ID_INSTR_i,IX2_INSTR0_i);

  DATA_DEPA_IX3_0 <=
    dep_a(RMTCH_A_IX3_0,ID_V_i,IX3_V_i(0),ID_INSTR_i,IX3_INSTR0_i);

  DATA_DEPB_IX1_0 <=
    dep_b(RMTCH_B_IX1_0,ID_V_i,IX1_V_i(0),ID_INSTR_i,IX1_INSTR0_i);

  DATA_DEPB_IX2_0 <=
    dep_b(RMTCH_B_IX2_0,ID_V_i,IX2_V_i(0),ID_INSTR_i,IX2_INSTR0_i);

  DATA_DEPB_IX3_0 <=
    dep_b(RMTCH_B_IX3_0,ID_V_i,IX3_V_i(0),ID_INSTR_i,IX3_INSTR0_i);

  DATA_DEPA_IX1_1 <=
    dep_a(RMTCH_A_IX1_1,ID_V_i,IX1_V_i(1),ID_INSTR_i,IX1_INSTR1_i);

  DATA_DEPA_IX2_1 <=
    dep_a(RMTCH_A_IX2_1,ID_V_i,IX2_V_i(1),ID_INSTR_i,IX2_INSTR1_i);

  DATA_DEPA_IX3_1 <=
    dep_a(RMTCH_A_IX3_1,ID_V_i,IX3_V_i(1),ID_INSTR_i,IX3_INSTR1_i);

  DATA_DEPB_IX1_1 <=
    dep_b(RMTCH_B_IX1_1,ID_V_i,IX1_V_i(1),ID_INSTR_i,IX1_INSTR1_i);

  DATA_DEPB_IX2_1 <=
    dep_b(RMTCH_B_IX2_1,ID_V_i,IX2_V_i(1),ID_INSTR_i,IX2_INSTR1_i);

  DATA_DEPB_IX3_1 <=
    dep_b(RMTCH_B_IX3_1,ID_V_i,IX3_V_i(1),ID_INSTR_i,IX3_INSTR1_i);

  ----------------------------------------------------

  -- STALL_x_IXy_z = '1' when there's a stall condition caused by
  -- ID instruction operand x and IXy instruction #z result

  STALL_A_IX1_0 <=
    stall_a(DATA_DEPA_IX1_0,IX1_FWDE_i(0),IX_2C0,ID_INSTR_i,IX1_INSTR0_i);

  STALL_A_IX2_0 <=
    stall_a(DATA_DEPA_IX2_0,IX2_FWDE_i(0),'0',ID_INSTR_i,IX2_INSTR0_i);

  STALL_A_IX3_0 <=
    stall_a(DATA_DEPA_IX3_0,IX3_FWDE_i(0),'0',ID_INSTR_i,IX3_INSTR0_i);

  STALL_B_IX1_0 <=
    stall_b(DATA_DEPB_IX1_0,IX1_FWDE_i(0),IX_2C0,ID_INSTR_i,IX1_INSTR0_i);

  STALL_B_IX2_0 <=
    stall_b(DATA_DEPB_IX2_0,IX2_FWDE_i(0),'0',ID_INSTR_i,IX2_INSTR0_i);

  STALL_B_IX3_0 <=
    stall_b(DATA_DEPB_IX3_0,IX3_FWDE_i(0),'0',ID_INSTR_i,IX3_INSTR0_i);

  STALL_A_IX1_1 <=
    stall_a(DATA_DEPA_IX1_1,IX1_FWDE_i(1),IX_2C1,ID_INSTR_i,IX1_INSTR1_i);

  STALL_A_IX2_1 <=
    stall_a(DATA_DEPA_IX2_1,IX2_FWDE_i(1),'0',ID_INSTR_i,IX2_INSTR1_i);

  STALL_A_IX3_1 <=
    stall_a(DATA_DEPA_IX3_1,IX3_FWDE_i(1),'0',ID_INSTR_i,IX3_INSTR1_i);

  STALL_B_IX1_1 <=
    stall_b(DATA_DEPB_IX1_1,IX1_FWDE_i(1),IX_2C1,ID_INSTR_i,IX1_INSTR1_i);

  STALL_B_IX2_1 <=
    stall_b(DATA_DEPB_IX2_1,IX2_FWDE_i(1),'0',ID_INSTR_i,IX2_INSTR1_i);

  STALL_B_IX3_1 <=
    stall_b(DATA_DEPB_IX3_1,IX3_FWDE_i(1),'0',ID_INSTR_i,IX3_INSTR1_i);
  ----------------------------------------------------

  -- pipeline stall flag

  PSTALL_o <=
    STALL_A_IX1_0 or
    STALL_A_IX2_0 or
    STALL_A_IX3_0 or
    STALL_B_IX1_0 or
    STALL_B_IX2_0 or
    STALL_B_IX3_0 or
    STALL_A_IX1_1 or
    STALL_A_IX2_1 or
    STALL_A_IX3_1 or
    STALL_B_IX1_1 or
    STALL_B_IX2_1 or
    STALL_B_IX3_1;


  GSTAT: if(SIMULATION_ONLY = '1') generate

    process(CLK_i)
    begin
      if(CLK_i = '1' and CLK_i'event) then

        --if(ID_V_i = '1') then
  
          if(STALL_A_IX1_0 = '1') then
            STALL_STATS(0) <= STALL_STATS(0) + 1;
          end if;
  
          if(STALL_A_IX2_0 = '1') then
            STALL_STATS(1) <= STALL_STATS(1) + 1;
          end if;
  
          if(STALL_B_IX1_0 = '1') then
            STALL_STATS(2) <= STALL_STATS(2) + 1;
          end if;
  
          if(STALL_B_IX2_0 = '1') then
            STALL_STATS(3) <= STALL_STATS(3) + 1;
          end if;
  
          if(STALL_A_IX1_1 = '1') then
            STALL_STATS(4) <= STALL_STATS(4) + 1;
          end if;
  
          if(STALL_A_IX2_1 = '1') then
            STALL_STATS(5) <= STALL_STATS(5) + 1;
          end if;
  
          if(STALL_B_IX1_1 = '1') then
            STALL_STATS(6) <= STALL_STATS(6) + 1;
          end if;
  
          if(STALL_B_IX2_1 = '1') then
            STALL_STATS(7) <= STALL_STATS(7) + 1;
          end if;
  
        --end if;

      end if;

    end process;

  end generate;

end;

