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
-- G.729a ASIP Branch/Jump eXecute Logic
---------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.G729A_ASIP_PKG.all;
use work.G729A_ASIP_OP_PKG.all;

entity G729A_ASIP_BJXLOG is
  port(
    CLK_i : in std_logic;
    RST_i : in std_logic;
    BJ_OP : in BJ_OP_T;
    PC0P1_i : in unsigned(ALEN-1 downto 0);
    PC1P1_i : in unsigned(ALEN-1 downto 0);
    PC0_i : in unsigned(ALEN-1 downto 0);
    PCSEL_i : in std_logic;
    OPA_i : in LDWORD_T;
    OPB_i : in LDWORD_T;
    OPC_i : in SDWORD_T;
    IV_i : in std_logic;
    LLCRX_i : in std_logic;
    FSTLL_i : in std_logic;

    BJX_o : out std_logic;
    BJTA_o : out unsigned(ALEN-1 downto 0)
  );
end G729A_ASIP_BJXLOG;

architecture ARC of G729A_ASIP_BJXLOG is

  constant SZERO : SDWORD_T := (others => '0');
  constant LZERO : LDWORD_T := (others => '0');

  signal BJX : std_logic;
  signal BJTA,BJTA_q : unsigned(SDLEN-1 downto 0);
  signal BJX_q : std_logic;
  signal BJTA1,BJTA2,BJTA3,BJTA4 : unsigned(SDLEN-1 downto 0);

  function to_unsigned(S : signed) return unsigned is
    variable U : unsigned(S'HIGH downto S'LOW);
  begin
    for i in S'HIGH downto S'LOW loop
      U(i) := S(i);
    end loop;
    return(U);
  end function;

  function to_signed(U : unsigned) return signed is
    variable S : signed(U'HIGH downto U'LOW);
  begin
    for i in U'HIGH downto U'LOW loop
      S(i) := U(i);
    end loop;
    return(S);
  end function;

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

  function wrap_sum(A,B : unsigned(SDLEN-1 downto 0)) return unsigned is
    variable TMP : unsigned(SDLEN downto 0);
  begin
    -- A is an unsigned value and thus is zero-extended
    -- B has to be instead treated as a signed value and thus is sign-extended
    TMP := ('0' & A) + (B(SDLEN-1) & B);
    -- result is TMP with MSb removed (wrap-up)
    return(TMP(SDLEN-1 downto 0));
  end function;

begin 

  -- Note:
  -- llcr and llcri instructions are treated ad unconditional
  -- jumps to address PC+1. This is needed to insure that
  -- a possible loop closing instruction located at PC+1 or
  -- PC+2 is properly handled (such instruction would leave
  -- IF stage before llcr* instruction is executed). The
  -- "ad-hoc" jump to PC+1 essentially re-fetches the two
  -- instructions at risk.

  -- Pre-calculate all possible target addresses

  -- TA for LLCRX "unconditional jump"
  BJTA1 <= PC0P1_i when PCSEL_i = '0' else PC1P1_i;

  -- TA for beq/bne
  BJTA2 <= wrap_sum(PC0_i,to_unsigned(OPC_i));

  -- TA for branches
  BJTA3 <= wrap_sum(PC0_i,to_unsigned(OPB_i(SDLEN-1 downto 0)));

  -- TA for jumps
  BJTA4 <= to_unsigned(OPA_i(SDLEN-1 downto 0))
    when ((BJ_OP = BJ_JR) or (BJ_OP = BJ_JRL))
    else to_unsigned(OPB_i(SDLEN-1 downto 0));

  -- Select target address

  process(LLCRX_i,BJ_OP,BJTA1,BJTA2,BJTA3,BJTA4)
  begin
    if(LLCRX_i = '1') then
      BJTA <= BJTA1;
    elsif((BJ_OP = BJ_BEQ) or (BJ_OP = BJ_BNE)) then
      BJTA <= BJTA2;
    elsif((BJ_OP /= BJ_JI) and (BJ_OP /= BJ_JIL) and (BJ_OP /= BJ_JR) and (BJ_OP /= BJ_JRL)) then
      BJTA <= BJTA3;
    else
      BJTA <= BJTA4;
    end if;
  end process;

  -- Set branch/jump execute flag

  process(BJ_OP,OPA_i,OPB_i,OPC_i,LLCRX_i)
    variable OPA_LO : SDWORD_T;
    variable OPB_LO : SDWORD_T;
    variable AEQB_S : std_logic;
    variable AEQ0_S : std_logic;
    variable ALT0_S : std_logic;
    variable AEQ0_L : std_logic;
    variable ALT0_L : std_logic;
  begin

    OPA_LO := OPA_i(SDLEN-1 downto 0);
    OPB_LO := OPB_i(SDLEN-1 downto 0);

    -- Generate comparison flags

    AEQB_S := qmark(OPA_LO = OPB_LO,'1','0'); 

    AEQ0_S := qmark(OPA_LO = 0,'1','0'); 

    ALT0_S := OPA_LO(SDLEN-1); 

    AEQ0_L := qmark(OPA_i = 0,'1','0'); 

    ALT0_L := OPA_i(LDLEN-1);

    -- B/J instructions involving comparison of long-type data
    -- (LBLEZ or LBGTZ) or between two non-constant values
    -- (BEQ or BNE) are given priority to improve timing.

    if(BJ_OP = BJ_LBLEZ or BJ_OP = BJ_LBGTZ or BJ_OP = BJ_BEQ or BJ_OP = BJ_BNE) then

      BJX <=
        qmark(BJ_OP = BJ_LBLEZ,ALT0_L or AEQ0_L,'0') or
        qmark(BJ_OP = BJ_LBGTZ,not(ALT0_L) and not(AEQ0_L),'0') or
        qmark(BJ_OP = BJ_BEQ,AEQB_S,'0') or
        qmark(BJ_OP = BJ_BNE,not(AEQB_S),'0');

    else

    case BJ_OP is

      when BJ_JI|BJ_JIL|BJ_JR|BJ_JRL  =>
        BJX <= '1';

      when BJ_BLEZ =>
        BJX <= ALT0_S or AEQ0_S;

      when BJ_BGTZ =>
        BJX <= not(ALT0_S) and not(AEQ0_S);

      when BJ_BLTZ =>
        BJX <= ALT0_S;

      when BJ_BGEZ =>
        BJX <= not(ALT0_S);

      when BJ_LBLTZ =>
        BJX <= ALT0_L;

      when BJ_LBGEZ =>
        BJX <= not(ALT0_L);

      when others =>
        BJX <= LLCRX_i; --'0';

    end case;

    end if;

  end process;

  -- B/J execute flag and target address register.
  -- These registers are needed when a B/J is taken
  -- while fecth is stalled: in such condition B/J
  -- must deferred to first un-stalled cycle.

  process(CLK_i)
  begin
    if(CLK_i = '1' and CLK_i'event) then
      if(FSTLL_i = '1') then
        BJTA_q <= BJTA;
      end if;
      if(RST_i = '1' or FSTLL_i = '0') then
        BJX_q <= '0';
      elsif(FSTLL_i = '1') then
        BJX_q <= (BJX and IV_i);
      end if;
    end if;
  end process;

  -- A branch/jump is actually executed if:
  -- 1) there's a valid B/J instruction in IX1 stage, OR
  -- 2) there's a pending B/J.

  BJX_o <= (BJX and IV_i) or (BJX_q);

  BJTA_o <= BJTA_q when (BJX_q = '1') else BJTA;

end ARC;
