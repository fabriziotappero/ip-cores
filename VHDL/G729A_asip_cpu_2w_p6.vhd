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
-- G.729a ASIP CPU module
---------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use STD.textio.all;

library work;
use work.G729A_ASIP_PKG.all;
use work.G729A_ASIP_IDEC_2W_PKG.all;
use WORK.G729A_ASIP_BASIC_PKG.all;
use WORK.G729A_ASIP_ARITH_PKG.all;
use WORK.G729A_ASIP_OP_PKG.all;

entity G729A_ASIP_CPU_2W is
  generic(
    -- synthesis translate_off
    ST_FILENAME : string := "NONE";
    WB_FILENAME : string := "NONE";
    -- synthesis translate_on
    SIMULATION_ONLY : std_logic := '1'
  );
  port(
    CLK_i : in std_logic;
    RST_i : in std_logic;
    STRT_i : in std_logic;
    SADR_i : in unsigned(ALEN-1 downto 0);
    -- instruction memory interface
    INSTR_i : in std_logic_vector(ILEN*2-1 downto 0); -- two instructions!
    -- data memory interface
    DDAT0_i : in std_logic_vector(SDLEN-1 downto 0);
    DDAT1_i : in std_logic_vector(SDLEN-1 downto 0);
    -- check interface
    CHK_ENB_i : in std_logic;
    
    BSY_o : out std_logic;
    -- instruction memory interface
    IADR_o : out unsigned(ALEN-2 downto 0);
    -- data memory interface
    DRE_o : out std_logic_vector(2-1 downto 0);
    DWE0_o : out std_logic;
    DADR0_o : out unsigned(ALEN-1 downto 0);
    DADR1_o : out unsigned(ALEN-1 downto 0);
    DDAT0_o : out std_logic_vector(SDLEN-1 downto 0)
  );
end G729A_ASIP_CPU_2W;

architecture ARC of G729A_ASIP_CPU_2W is

  constant LCSTK_DEPTH : natural := 4;
  constant SZERO : SDWORD_T := (others => '0');
  constant LZERO : LDWORD_T := (others => '0');

  constant NW : natural := 2;
  constant NWX2M1 : natural := NW*2-1;

  component G729A_ASIP_LCSTKLOG_2W is
    generic(
      DEPTH : natural
    );
    port(
      CLK_i : in std_logic;
      RST_i : in std_logic;
      SRST_i : in std_logic;
      LLBRX_i : in std_logic; -- llbri eXecute flag
      LLERX_i : in std_logic; -- lleri eXecute flag
      LLCRX_i : in std_logic; -- llcnt/llcnti eXecute flag
      IMM_i : in unsigned(16-1 downto 0); -- loop count
      PCF0_i : in unsigned(ALEN-1 downto 0); -- IF program counter
      PCF1_i : in unsigned(ALEN-1 downto 0); -- IF program counter
      PCX0_i : in unsigned(ALEN-1 downto 0); -- IX1 program counter
      PCX1_i : in unsigned(ALEN-1 downto 0); -- IX1 program counter
      IXV_i : in std_logic_vector(2-1 downto 0);
  
      KLL1_o : out std_logic;
      LEND_o : out std_logic;
      LEIS_o : out std_logic;
      LBX_o : out std_logic; -- loop-back jump eXecute flag
      LBTA_o : out unsigned(16-1 downto 0) -- loop-back target address
    );
  end component;
  
  component G729A_ASIP_FTCHLOG_2W is
    port(
      CLK_i : in std_logic;
      RST_i : in std_logic;
      STRT_i : in std_logic;
      HALT_i : in std_logic;
      SADR_i : in unsigned(ALEN-1 downto 0);
      BJX_i : in std_logic;
      BJTA_i : in unsigned(ALEN-1 downto 0);
      LBX_i : in std_logic;
      LBTA_i : in unsigned(ALEN-1 downto 0);
      PSTALL_i : in std_logic;
  
      IFV_o : out std_logic_vector(2-1 downto 0);
      IADR0_o : out unsigned(ALEN-1 downto 0);
      IADR1_o : out unsigned(ALEN-1 downto 0);
      BSY_o : out std_logic
    );
  end component;

  component G729A_ASIP_IFQ is
    port(
      CLK_i : in std_logic;
      RST_i : in std_logic;
      ID_HALT_i : in std_logic;
      IX_BJX_i : in std_logic;
      ID_ISSUE_i : in std_logic_vector(2-1 downto 0);
      IF_V_i : in std_logic_vector(2-1 downto 0);
      IF_PC0_i : in unsigned(ALEN-1 downto 0);
      IF_PC1_i : in unsigned(ALEN-1 downto 0);
      IF_INSTR0_i : in std_logic_vector(ILEN-1 downto 0);
      IF_INSTR1_i : in std_logic_vector(ILEN-1 downto 0);
      IF_DEC_INSTR0_i : in DEC_INSTR_T;
      IF_DEC_INSTR1_i : in DEC_INSTR_T;
      IF_IMM0_i : in std_logic;
      IF_IMM1_i : in std_logic;
      IF_OPB0_i : in LDWORD_T;
      IF_OPB1_i : in LDWORD_T;
  
      PSTALL_o : out std_logic;
      ID_V_o : out std_logic_vector(2-1 downto 0);
      ID_PC0_o : out unsigned(ALEN-1 downto 0);
      ID_PC1_o : out unsigned(ALEN-1 downto 0);
      ID_INSTR0_o : out std_logic_vector(ILEN-1 downto 0);
      ID_INSTR1_o : out std_logic_vector(ILEN-1 downto 0);
      ID_DEC_INSTR0_o : out DEC_INSTR_T;
      ID_DEC_INSTR1_o : out DEC_INSTR_T;
      ID_IMM0_o : out std_logic;
      ID_IMM1_o : out std_logic;
      ID_OPB0_o : out LDWORD_T;
      ID_OPB1_o : out LDWORD_T
    );
  end component;

  component G729A_ASIP_IDEC1_2W is
    port(
      INSTR_i : in std_logic_vector(ILEN-1 downto 0);

      OPB_IMM_o : out std_logic;
      OPB_o : out LDWORD_T;
      DEC_INSTR_o : out DEC_INSTR_T
    );
  end component;

  component G729A_ASIP_IDEC2 is
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
  end component;

  component G729A_ASIP_PSTLLOG_2W is
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

      PSTALL_o : out std_logic
    );
  end component;

  component G729A_ASIP_PSTLLOG_2W_P6 is
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
  end component;

  component G729A_ASIP_PXLOG is
    port(
      ID_INSTR0_i : in DEC_INSTR_T;
      ID_INSTR1_i : in DEC_INSTR_T;
      ID_V_i : in std_logic_vector(2-1 downto 0);
      ID_FWDE_i : in std_logic_vector(2-1 downto 0);

      PXE1_o : out std_logic
    );
  end component;


  component G729A_ASIP_PIPE_A_DEC_2W is
    port(
      INSTR_i : in DEC_INSTR_T;

      FWDE_o : out std_logic;
      SEL_o :  out std_logic_vector(7-1 downto 0)
    );
  end component;

  component G729A_ASIP_FWDLOG_2W is
    port(
      ID_RX_i : in RID_T;
      ID_RRX_i : in std_logic;
      IX1_INSTR0_i : in DEC_INSTR_T;
      IX2_INSTR0_i : in DEC_INSTR_T;
      IX1_INSTR1_i : in DEC_INSTR_T;
      IX2_INSTR1_i : in DEC_INSTR_T;
      IX1_PA_RES0_i : in SDWORD_T;
      IX1_PA_RES1_i : in SDWORD_T;
      IX2_PA_RES0_i : in LDWORD_T;
      IX2_PA_RES1_i : in LDWORD_T;
      ID_OPX_NOFWD_i : in LDWORD_T;
      IX1_V_i : in std_logic_vector(2-1 downto 0);
      IX2_V_i : in std_logic_vector(2-1 downto 0);
      IX1_FWDE_i : in std_logic_vector(2-1 downto 0);
      IX2_FWDE_i : in std_logic_vector(2-1 downto 0);
  
      ID_OPX_o : out LDWORD_T
    );
  end component;

  component G729A_ASIP_FWDLOG_2W_P6 is
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
  end component;

  component G729A_ASIP_PIPE_A_2W is
    port(
      CLK_i : in std_logic;
      SEL_i :  in std_logic_vector(7-1 downto 0);
      OPA_i : in SDWORD_T;
      OPB_i : in SDWORD_T;
      ACC_i : in LDWORD_T;
      LDAT_i : in std_logic_vector(SDLEN-1 downto 0);

      RES_1C_o : out SDWORD_T; --  port #0 1-cycle result
      RES_o : out LDWORD_T; -- port #0 result
      ACC_o : out LDWORD_T; -- updated accumulator
      OVF_o : out std_logic -- port #0 overflow flag
    );
  end component;

  component G729A_ASIP_PIPE_B is
    port(
      CLK_i : in std_logic;
      OP_i :  in ALU_OP_T;
      OPA_i : in LDWORD_T;
      OPB_i : in LDWORD_T;
      OVF_i : in std_logic;
      ACC_i : in LDWORD_T;

      RES_o : out LDWORD_T;
      OVF_o : out std_logic
    );
  end component;

  component G729A_ASIP_BJXLOG is
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
  end component;

  component G729A_ASIP_LSU is
    port(
      IV_i : in std_logic;
      LS_OP_i : in LS_OP_T;
      OPA_i : in LDWORD_T;
      OPB_i : in LDWORD_T;
      OPC_i : in SDWORD_T;

      DRE_o : out std_logic;
      DWE_o : out std_logic;
      DADR_o : out unsigned(ALEN-1 downto 0);
      DDAT_o : out std_logic_vector(SDLEN-1 downto 0)
    );
  end component;

  component G729A_ASIP_LU is
    port(
      IV_i : in std_logic;
      LS_OP_i : in LS_OP_T;
      OPA_i : in LDWORD_T;
      OPB_i : in LDWORD_T;

      DRE_o : out std_logic;
      DADR_o : out unsigned(ALEN-1 downto 0)
    );
  end component;

  component G729A_ASIP_LCSTKLOG_IX is
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
  end component;

  component G729A_ASIP_REGFILE_16X16_2W is
    port(
      CLK_i : in std_logic;
      RA0_i : in RID_T;
      RA1_i : in RID_T;
      RA2_i : in RID_T;
      RA3_i : in RID_T;
      WA0_i : in RID_T;
      WA1_i : in RID_T;
      LR0_i : in std_logic;
      LR1_i : in std_logic;
      LR2_i : in std_logic;
      LR3_i : in std_logic;
      LW0_i : in std_logic;
      LW1_i : in std_logic;
      WE0_i : in std_logic;
      WE1_i : in std_logic;
      D0_i : in std_logic_vector(LDLEN-1 downto 0);
      D1_i : in std_logic_vector(LDLEN-1 downto 0);
  
      Q0_o : out std_logic_vector(LDLEN-1 downto 0);
      Q1_o : out std_logic_vector(LDLEN-1 downto 0);
      Q2_o : out std_logic_vector(LDLEN-1 downto 0);
      Q3_o : out std_logic_vector(LDLEN-1 downto 0)
    );
  end component;

  component G729A_ASIP_STATS is
    port(
      CLK_i : in std_logic;
      RST_i : in std_logic;
      ID_V_i : in std_logic_vector(2-1 downto 0);
      ID_PS_i : in std_logic_vector(2-1 downto 0);
      ID_PXE1_i : std_logic;
      IX2_V_i : in std_logic_vector(2-1 downto 0);
      STRT_i : in std_logic;
      HALT_i : in std_logic
    );
  end component;

  function to_unsigned(S : signed) return unsigned is
    variable U : unsigned(S'high downto S'low);
  begin
    for i in S'low to S'high loop
      U(i) := S(i);
    end loop;
    return(U);
  end function;

  function to_signed(U : unsigned) return signed is
    variable S : signed(U'high downto U'low);
  begin
    for i in U'low to U'high loop
      S(i) := U(i);
    end loop;
    return(S);
  end function;

  function EXTS16(V : std_logic_vector) return signed is
    variable S : signed(SDLEN-1 downto 0);
  begin
    S(V'HIGH downto 0) := to_signed(V);
    S(SDLEN-1 downto V'HIGH+1) := (others => V(V'HIGH));
    return(S);
  end function;

  function EXTS32(S : signed) return signed is
    variable XS : signed(LDLEN-1 downto 0);
  begin
    XS(S'HIGH downto 0) := S;
    XS(LDLEN-1 downto S'HIGH+1) := (others => S(S'HIGH));
    return(XS);
  end function;

  type DEC_INSTR_VEC_T is array (natural range<>) of DEC_INSTR_T;
  type LDWORD_VEC_T is array (natural range<>) of LDWORD_T;
  subtype ADR_T is unsigned(ALEN-1 downto 0);
  type ADR_VEC_T is array (natural range<>) of ADR_T;

  signal ZERO : std_logic := '0';
  signal ONE : std_logic := '1';

  signal IF_INSTR0,IF_INSTR1 : std_logic_vector(ILEN-1 downto 0);
  signal IF_INSTR_q : std_logic_vector(ILEN*NW-1 downto 0);
  signal IF_V,IF_V_q : std_logic_vector(NW-1 downto 0);
  signal IF_V_KLL1 : std_logic_vector(NW-1 downto 0);
  signal IF_V_q2 : std_logic_vector(NW-1 downto 0);
  signal IF_PC0,IF_PC1 : ADR_T;
  signal IF_PC_q : ADR_VEC_T(NW-1 downto 0);
  signal IF_PC_q2 : ADR_VEC_T(NW-1 downto 0);
  signal IF_KLL1 : std_logic;
  signal IF_LBX : std_logic;
  signal IF_LBTA : unsigned(ALEN-1 downto 0);
  signal IF_DEC_INSTR0,IF_DEC_INSTR1 : DEC_INSTR_T;
  signal IF_DEC_INSTR_q : DEC_INSTR_VEC_T(NW-1 downto 0);
  signal IF_OPB_IMM0,IF_OPB_IMM1 : std_logic;
  signal IF_OPB_IMM_q : std_logic_vector(NW-1 downto 0);
  signal IF_OPB0,IF_OPB1 : LDWORD_T;
  signal IF_OPB_q : LDWORD_VEC_T(NW-1 downto 0);

  signal ID_INSTR0,ID_INSTR1 : DEC_INSTR_T;
  signal ID_INSTR_q : DEC_INSTR_VEC_T(NW-1 downto 0);
  signal ID_IMM0,ID_IMM1 : signed(SDLEN-1 downto 0);
  signal ID_V,ID_V_q : std_logic_vector(NW-1 downto 0);
  signal ID_ISSUE : std_logic_vector(NW-1 downto 0);
  signal ID_PC_q : ADR_VEC_T(NW-1 downto 0);
  signal ID_PCP1_q : ADR_VEC_T(NW-1 downto 0);
  signal ID_OPA0,ID_OPA0_q : LDWORD_T;
  signal ID_OPB0,ID_OPB0_q : LDWORD_T;
  signal ID_OPA1,ID_OPA1_q : LDWORD_T;
  signal ID_OPB1,ID_OPB1_q : LDWORD_T;
  signal ID_OPC0,ID_OPC0_q : SDWORD_T;
  signal ID_HALT0,ID_HALT1,ID_HALT : std_logic;
  signal ID_PSTALL : std_logic;
  signal ID_PS0,ID_PS1 : std_logic;
  signal ID_PXE1 : std_logic;
  signal ID_JLRA0,ID_JLRA1 : unsigned(ALEN-1 downto 0);
  signal ID_JLRA0_S,ID_JLRA1_S : LDWORD_T;
  signal ID_FWDE : std_logic_vector(NW-1 downto 0);
  signal ID_FWDE_q : std_logic_vector(NW-1 downto 0);
  signal ID_PASEL0,ID_PASEL1 :  std_logic_vector(7-1 downto 0);
  signal ID_PASEL0_q,ID_PASEL1_q :  std_logic_vector(7-1 downto 0);
  signal ID_JL0,ID_JL1 : std_logic;

  signal IX1_INSTR0_q,IX1_INSTR1_q : DEC_INSTR_T;
  signal IX1_SRST : std_logic;
  signal IX1_LLBR,IX1_LLER,IX1_LLCR : std_logic;
  signal IX1_BJX : std_logic;
  signal IX1_BJTA : unsigned(ALEN-1 downto 0);
  signal IX1_IMM : unsigned(ALEN-1 downto 0);
  signal IX1_ALUV : std_logic;
  signal IX1_ALUOVF : std_logic;
  signal IX1_LDV : std_logic;
  signal IX1_DWE : std_logic;
  signal IX1_DDATO : std_logic_vector(SDLEN-1 downto 0);
  signal IX1_DADR : unsigned(ALEN-1 downto 0);
  signal UNUSED1 : std_logic := '0';
  signal IX1_MC : MUL_CTRL;
  signal IX1_V,IX1_V_q : std_logic_vector(NW-1 downto 0);
  signal IX1_FWDE_q : std_logic_vector(NW-1 downto 0);
  signal IX1_PA0_RES : SDWORD_T;
  signal IX1_PA1_RES : SDWORD_T;
  signal IX1_LEND : std_logic;
  signal IX1_LEIS : std_logic;
  signal IX1_PCLN : std_logic;
  signal IX1_PCLN_PC : unsigned(ALEN-1 downto 0);

  signal IX2_OVF0 : std_logic;
  signal IX2_OVF1 : std_logic;
  signal IX2_DRD0,IX2_DRD1 : signed(LDLEN-1 downto 0);
  signal IX2_PA0_RES : LDWORD_T;
  signal IX2_PA1_RES : LDWORD_T;
  signal IX2_PA0_OVF : std_logic;
  signal IX2_PA1_OVF : std_logic;
  signal IX2_PB0_RES : LDWORD_T;
  signal IX2_PB0_OVF : std_logic;

  signal IX2_INSTR0_q,IX2_INSTR1_q : DEC_INSTR_T;
  signal IX2_DRD0_q,IX2_DRD1_q : signed(LDLEN-1 downto 0);
  signal IX3_DRD0,IX3_DRD1 : signed(LDLEN-1 downto 0);
  signal IX2_OVF0_q,IX2_OVF1_q : std_logic;
  signal IX3_OVF0,IX3_OVF1 : std_logic;
  signal IX2_V_q : std_logic_vector(NW-1 downto 0);
  signal IX2_FWDE : std_logic_vector(NW-1 downto 0);
  signal IX2_FWDE_q : std_logic_vector(NW-1 downto 0);

  signal WB_WE0,WB_WE1 : std_logic;
  signal WB_WA1 : RID_T;
  signal WB_RDA0,WB_RDB0 : std_logic_vector(LDLEN-1 downto 0);
  signal WB_RDA1,WB_RDB1 : std_logic_vector(LDLEN-1 downto 0);
  signal WB_OVF,WB_OVF_q : std_logic;
  signal WB_ACC_q : signed(LDLEN-1 downto 0);
  signal WB_PXE_q : std_logic;

  -- debug-only signals

  component G729A_ASIP_ST_CHECKER is
    generic(
      ST_FILENAME : string := "NONE"
    );
    port(
      CLK_i : in std_logic;
    ENB_i : in std_logic;
      DWE_i : in std_logic;
      DADR_i : in unsigned(ALEN-1 downto 0);
      DDATO_i : in std_logic_vector(SDLEN-1 downto 0)
    );
  end component;

  component G729A_ASIP_WB_CHECKER is
    generic(
      WB_FILENAME : string := "NONE"
    );
    port(
      CLK_i : in std_logic;
      ENB_i : in std_logic;
      WE0_i : in std_logic;
      WE1_i : in std_logic;
      IX_INSTR0_i : in DEC_INSTR_T; 
      IX_INSTR1_i : in DEC_INSTR_T;
      IX_DRD0_i : in LDWORD_T;
      IX_DRD1_i : in LDWORD_T 
    );
  end component;

begin

  ----------------------------------------------------
  -- Notes:
  ----------------------------------------------------

  -- *** Pipeline ***
  -- ASIP employs the following 7-stage pipeline:
  -- 1) Instruction Fetch (IF1)
  -- 2) Instruction Fetch (IF2)
  -- 3) Instruction Decode (ID)
  -- 4) Instruction Execute (IX1)
  -- 5) Instruction Execute (IX2)
  -- 6) Instruction Execute (IX3)
  -- 7) Write Back (WB)

  -- *** Branch processing ***
  -- There's no branch prediction: branches are processed
  -- in IX1 stage, like other instructions, as a consequence
  -- there's a fixed branch penalty of 2 cycles.
  
  -- *** Loop Control Stack management ***
  -- 1) Loop control stack is pushed when a llcnt/llcnti
  -- instruction enters IX1 stage. 
  -- 2) Loop count is decremented
  -- every time the first loop instruction enters IX1 stage.
  -- 3) loop-back implicit jump is performed when last
  -- loop instruction is fetched, in order to avoid the
  -- 2-cycle penalty imposed by the pipeline. First/last
  -- loop instruction CAN'T be a conditionally executed
  -- instruction!

  ----------------------------------------------------
  -- IF1 Stage:
  ----------------------------------------------------

  -- Loop Control Stack Logic

  U_LCSTK : G729A_ASIP_LCSTKLOG_2W
    generic map(
      DEPTH => LCSTK_DEPTH
    )
    port map(
      CLK_i => CLK_i,
      RST_i => RST_i,
      SRST_i => IX1_SRST,
      LLBRX_i => IX1_LLBR,
      LLERX_i => IX1_LLER,
      LLCRX_i => IX1_LLCR,
      IMM_i => IX1_IMM,
      PCF0_i => IF_PC_q(0),
      PCF1_i => IF_PC_q(1),
      PCX0_i => ID_PC_q(0),
      PCX1_i => ID_PC_q(1),
      IXV_i => ID_V_q,
 
      KLL1_o => IF_KLL1,
      LEND_o => IX1_LEND,
      LEIS_o => IX1_LEIS,
      LBX_o => IF_LBX,
      LBTA_o => IF_LBTA
    );
  
  -- Instruction Fetch Logic 

  -- This logic fetches instruction pairs, so that
  -- fetch address LSb is always zero

  U_FTCH : G729A_ASIP_FTCHLOG_2W
    port map(
      CLK_i => CLK_i,
      RST_i => RST_i,
      STRT_i => STRT_i,
      HALT_i => ID_HALT,
      SADR_i => SADR_i,
      BJX_i => IX1_BJX,
      BJTA_i => IX1_BJTA,
      LBX_i => IF_LBX,
      LBTA_i => IF_LBTA,
      PSTALL_i => ID_PSTALL,
  
      IFV_o => IF_V,
      IADR0_o => IF_PC0,
      IADR1_o => IF_PC1,
      BSY_o => BSY_o
    );

  -- Instruction memory address is a two-word address and
  -- therefore is one bit-shorter than individual instruction
  -- addresses.
 
  IADR_o <= IF_PC0(ALEN-1 downto 1);

  -- Pipeline Registers

  process(CLK_i)
  begin
    if(CLK_i = '1' and CLK_i'event) then

      if(RST_i = '1') then
        IF_V_q <= "00";
      elsif(ID_HALT = '1') then
        IF_V_q <= "00";
      elsif(ID_PSTALL = '0') then
        IF_V_q <= IF_V;
      end if;

      IF_PC_q(0) <= IF_PC0;
      IF_PC_q(1) <= IF_PC1;

    end if;
  end process;

  ----------------------------------------------------
  -- IF2 Stage
  ----------------------------------------------------

  -- Split instruction memory output into two individual instructions

  IF_INSTR0 <= INSTR_i(ILEN*1-1 downto ILEN*0);
  IF_INSTR1 <= INSTR_i(ILEN*2-1 downto ILEN*1);

  -- Pre-decode individual instructions

  U_IDEC10 : G729A_ASIP_IDEC1_2W
    port map(
      INSTR_i => IF_INSTR0,

      OPB_IMM_o => IF_OPB_IMM0,
      OPB_o => IF_OPB0,
      DEC_INSTR_o => IF_DEC_INSTR0
    );

  U_IDEC11 : G729A_ASIP_IDEC1_2W
    port map(
      INSTR_i => IF_INSTR1,

      OPB_IMM_o => IF_OPB_IMM1,
      OPB_o => IF_OPB1,
      DEC_INSTR_o => IF_DEC_INSTR1
    );

  -- IF2 stage instruction valid flags (accounting for KILL flag).
  -- Instruction slot #1 gets "killed" (invalidated) if slot #0
  -- instruction is a B/J one.

  IF_V_KLL1 <= ((IF_V_q(1) and not (IF_KLL1 and IF_LBX)) & IF_V_q(0));

  -- Instruction queue

  -- Note: IFQ includes pipeline registers between IF2 and ID stages.

  U_IFQ : G729A_ASIP_IFQ
    port map(
      CLK_i => CLK_i,
      RST_i => RST_i,
      ID_HALT_i => ID_HALT,
      IX_BJX_i => IX1_BJX,
      ID_ISSUE_i => ID_ISSUE, 
      IF_V_i => IF_V_KLL1, --IF_V_q,
      IF_PC0_i => IF_PC_q(0),
      IF_PC1_i => IF_PC_q(1),
      IF_INSTR0_i => IF_INSTR0,
      IF_INSTR1_i => IF_INSTR1,
      IF_DEC_INSTR0_i => IF_DEC_INSTR0,
      IF_DEC_INSTR1_i => IF_DEC_INSTR1,
      IF_IMM0_i => IF_OPB_IMM0,
      IF_IMM1_i => IF_OPB_IMM1,
      IF_OPB0_i => IF_OPB0,
      IF_OPB1_i => IF_OPB1,
  
      PSTALL_o => ID_PSTALL,
      ID_V_o => IF_V_q2,
      ID_PC0_o => IF_PC_q2(0),
      ID_PC1_o => IF_PC_q2(1),
      ID_INSTR0_o => IF_INSTR_q(ILEN*1-1 downto ILEN*0),
      ID_INSTR1_o => IF_INSTR_q(ILEN*2-1 downto ILEN*1),
      ID_DEC_INSTR0_o => IF_DEC_INSTR_q(0),
      ID_DEC_INSTR1_o => IF_DEC_INSTR_q(1),
      ID_IMM0_o => IF_OPB_IMM_q(0),
      ID_IMM1_o => IF_OPB_IMM_q(1),
      ID_OPB0_o => IF_OPB_q(0),
      ID_OPB1_o => IF_OPB_q(1)
    );

  ----------------------------------------------------
  -- ID Stage
  ----------------------------------------------------

  -- jump & link instructions return address

  ID_JLRA0 <= IF_PC_q2(1);
  ID_JLRA1 <= (IF_PC_q2(1) + 1);

  -- If there's a taken branch, or a jump, in IX1,
  -- instructions in ID are nullified.

  ID_V(0) <= IF_V_q2(0) and not(IX1_BJX) and ID_ISSUE(0);
  ID_V(1) <= IF_V_q2(1) and not(IX1_BJX) and ID_ISSUE(1);

  -- Instruction Decoder

  U_IDEC20 : G729A_ASIP_IDEC2
    port map(
      INSTR_i => IF_INSTR_q(ILEN*1-1 downto ILEN*0),
      DRA_i => WB_RDA0,
      DRB_i => WB_RDB0,
      PCP1_i => to_std_logic_vector(ID_JLRA0),
      OPB_IMM_i => IF_OPB_IMM_q(0),
      OPB_i => IF_OPB_q(0),
      ID_V_i => ID_V(0),

      OPA_o => open, --ID_OPA0_NOFWD,
      OPB_o => open, --ID_OPB0_NOFWD,
      OPC_o => ID_OPC0,
      IMM_o => ID_IMM0,
      JL_o => ID_JL0,
      HALT_o => ID_HALT0
    );

  U_IDEC21 : G729A_ASIP_IDEC2
    port map(
      INSTR_i => IF_INSTR_q(ILEN*2-1 downto ILEN*1),
      DRA_i => WB_RDA1,
      DRB_i => WB_RDB1,
      PCP1_i => to_std_logic_vector(ID_JLRA1),
      OPB_IMM_i => IF_OPB_IMM_q(1),
      OPB_i => IF_OPB_q(1),
      ID_V_i => ID_V(1),

      OPA_o => open, --ID_OPA1_NOFWD,
      OPB_o => open, --ID_OPB1_NOFWD,
      OPC_o => open, --ID_OPC1,
      IMM_o => ID_IMM1,
      JL_o => ID_JL1,
      HALT_o => ID_HALT1
    );

  -- execution must be halted if either instr. #0 or instr. #1 is a halt
  ID_HALT <= (ID_HALT0 or ID_HALT1);

  -- update decoded instr. immediate field

  process(IF_DEC_INSTR_q,ID_IMM0,ID_IMM1)
    variable TMP : DEC_INSTR_T;
  begin

    TMP := IF_DEC_INSTR_q(0);
    TMP.IMM := ID_IMM0;
    ID_INSTR0 <= TMP;

    TMP := IF_DEC_INSTR_q(1);
    TMP.IMM := ID_IMM1;
    ID_INSTR1 <= TMP;

  end process;

  -- Pipeline stall logic

  U_PSTL0 : G729A_ASIP_PSTLLOG_2W_P6
    generic map(
      SIMULATION_ONLY => SIMULATION_ONLY
    )
    port map(
      CLK_i => CLK_i,
      ID_INSTR_i => ID_INSTR0,
      ID_V_i => IF_V_q2(0),
      IX1_INSTR0_i => ID_INSTR_q(0),
      IX1_INSTR1_i => ID_INSTR_q(1),
      IX1_V_i => ID_V_q,
      IX1_FWDE_i => ID_FWDE_q,
      IX2_INSTR0_i => IX1_INSTR0_q,
      IX2_INSTR1_i => IX1_INSTR1_q,
      IX2_V_i => IX1_V_q,
      IX2_FWDE_i => IX1_FWDE_q,
      IX3_INSTR0_i => IX2_INSTR0_q,
      IX3_INSTR1_i => IX2_INSTR1_q,
      IX3_V_i => IX2_V_q,
      IX3_FWDE_i => IX2_FWDE_q,

      PSTALL_o => ID_PS0
    );

  U_PSTL1 : G729A_ASIP_PSTLLOG_2W_P6
    generic map(
      SIMULATION_ONLY => SIMULATION_ONLY
    )
    port map(
      CLK_i => CLK_i,
      ID_INSTR_i => ID_INSTR1,
      ID_V_i => IF_V_q2(1),
      IX1_INSTR0_i => ID_INSTR_q(0),
      IX1_INSTR1_i => ID_INSTR_q(1),
      IX1_V_i => ID_V_q,
      IX1_FWDE_i => ID_FWDE_q,
      IX2_INSTR0_i => IX1_INSTR0_q,
      IX2_INSTR1_i => IX1_INSTR1_q,
      IX2_V_i => IX1_V_q,
      IX2_FWDE_i => IX1_FWDE_q,
      IX3_INSTR0_i => IX2_INSTR0_q,
      IX3_INSTR1_i => IX2_INSTR1_q,
      IX3_V_i => IX2_V_q,
      IX3_FWDE_i => IX2_FWDE_q,

      PSTALL_o => ID_PS1
    );

  -- Parallel eXecution logic

  U_PXLOG : G729A_ASIP_PXLOG
    port map(
      ID_INSTR0_i => IF_DEC_INSTR_q(0), 
      ID_INSTR1_i => IF_DEC_INSTR_q(1), 
      ID_V_i => IF_V_q2(2-1 downto 0),
      ID_FWDE_i => ID_FWDE, 

      PXE1_o => ID_PXE1
    );

  -- Instruction issue flags

  -- instr. #0 is issued if there's no stall due to a data dependency.

  ID_ISSUE(0) <=
     not(ID_PS0); -- instr. #0 can be issued

  -- instr. #1 is issued if:
  -- 1) there's no stall due to data dependency AND
  -- 2) isntr. #0 is isseud too (in-order issue rule)
  -- AND instr #1 can execute in parallel with instr. #1.

  --ID_ISSUE(1) <= 
  --   not(ID_PS1) and -- instr. #1 can be issued
  --   not(ID_PS0) and -- instr. #0 is issued too (in-order issue)
  --   ID_PXE1 and  -- instr. #1 can execute in parallel with #0
  --   WB_PXE_q; -- parallel execution is enabled

  -- ...same code of above, but restructured to improve timing.
  ID_ISSUE(1) <= (ID_PXE1 and WB_PXE_q) when
    (ID_PS1 = '0' and ID_PS0 = '0') else '0';

  -- Extend Jump & Link instruction return address to 32 bits.
  ID_JLRA0_S <= EXTS32(to_signed(ID_JLRA0));
  ID_JLRA1_S <= EXTS32(to_signed(ID_JLRA1));

  -- Instruction #0 Operand A forward logic

  U_FWDLOGA0 : G729A_ASIP_FWDLOG_2W_P6
    port map(
      ID_RX_i => ID_INSTR0.RA,
      ID_RRX_i => ID_INSTR0.RRA,
      IX1_INSTR0_i => ID_INSTR_q(0),
      IX2_INSTR0_i => IX1_INSTR0_q,
      IX3_INSTR0_i => IX2_INSTR0_q,
      IX1_INSTR1_i => ID_INSTR_q(1),
      IX2_INSTR1_i => IX1_INSTR1_q,
      IX3_INSTR1_i => IX2_INSTR1_q,
      IX1_PA_RES0_i => IX1_PA0_RES, 
      IX1_PA_RES1_i => IX1_PA1_RES,
      IX2_PA_RES0_i => IX2_PA0_RES,
      IX2_PA_RES1_i => IX2_PA1_RES,
      IX3_PA_RES0_i => IX3_DRD0,
      IX3_PA_RES1_i => IX3_DRD1,
      ID_OPX_NOFWD_i => to_signed(WB_RDA0), --ID_OPA0_NOFWD,
      IX1_V_i => ID_V_q,
      IX2_V_i => IX1_V_q,
      IX3_V_i => IX2_V_q,
      IX1_FWDE_i => ID_FWDE_q,
      IX2_FWDE_i => IX1_FWDE_q,
      IX3_FWDE_i => IX2_FWDE_q,
      NOREGS_i => ID_JL0,
      NOREGD_i => ID_JLRA0_S,
  
      ID_OPX_o => ID_OPA0
    );

  -- Instruction #1 Operand A forward logic

  U_FWDLOGA1 : G729A_ASIP_FWDLOG_2W_P6
    port map(
      ID_RX_i => ID_INSTR1.RA,
      ID_RRX_i => ID_INSTR1.RRA,
      IX1_INSTR0_i => ID_INSTR_q(0),
      IX2_INSTR0_i => IX1_INSTR0_q,
      IX3_INSTR0_i => IX2_INSTR0_q,
      IX1_INSTR1_i => ID_INSTR_q(1),
      IX2_INSTR1_i => IX1_INSTR1_q,
      IX3_INSTR1_i => IX2_INSTR1_q,
      IX1_PA_RES0_i => IX1_PA0_RES, 
      IX1_PA_RES1_i => IX1_PA1_RES,
      IX2_PA_RES0_i => IX2_PA0_RES,
      IX2_PA_RES1_i => IX2_PA1_RES,
      IX3_PA_RES0_i => IX3_DRD0,
      IX3_PA_RES1_i => IX3_DRD1,
      ID_OPX_NOFWD_i => to_signed(WB_RDA1), --ID_OPA1_NOFWD,
      IX1_V_i => ID_V_q,
      IX2_V_i => IX1_V_q,
      IX3_V_i => IX2_V_q,
      IX1_FWDE_i => ID_FWDE_q,
      IX2_FWDE_i => IX1_FWDE_q,
      IX3_FWDE_i => IX2_FWDE_q,
      NOREGS_i => ID_JL1,
      NOREGD_i => ID_JLRA1_S,
  
      ID_OPX_o => ID_OPA1
    );

  -- Instruction #0 Operand B forward logic

  U_FWDLOGB0 : G729A_ASIP_FWDLOG_2W_P6
    port map(
      ID_RX_i => ID_INSTR0.RB,
      ID_RRX_i => ID_INSTR0.RRB,
      IX1_INSTR0_i => ID_INSTR_q(0),
      IX2_INSTR0_i => IX1_INSTR0_q,
      IX3_INSTR0_i => IX2_INSTR0_q,
      IX1_INSTR1_i => ID_INSTR_q(1),
      IX2_INSTR1_i => IX1_INSTR1_q,
      IX3_INSTR1_i => IX2_INSTR1_q,
      IX1_PA_RES0_i => IX1_PA0_RES, 
      IX1_PA_RES1_i => IX1_PA1_RES,
      IX2_PA_RES0_i => IX2_PA0_RES,
      IX2_PA_RES1_i => IX2_PA1_RES,
      IX3_PA_RES0_i => IX3_DRD0,
      IX3_PA_RES1_i => IX3_DRD1,
      ID_OPX_NOFWD_i => to_signed(WB_RDB0), --ID_OPB0_NOFWD,
      IX1_V_i => ID_V_q,
      IX2_V_i => IX1_V_q,
      IX3_V_i => IX2_V_q,
      IX1_FWDE_i => ID_FWDE_q,
      IX2_FWDE_i => IX1_FWDE_q,
      IX3_FWDE_i => IX2_FWDE_q,
      NOREGS_i => IF_OPB_IMM_q(0),
      NOREGD_i => IF_OPB_q(0),
  
      ID_OPX_o => ID_OPB0
    );

  -- Instruction #1 Operand B forward logic

  U_FWDLOGB1 : G729A_ASIP_FWDLOG_2W_P6
    port map(
      ID_RX_i => ID_INSTR1.RB,
      ID_RRX_i => ID_INSTR1.RRB,
      IX1_INSTR0_i => ID_INSTR_q(0),
      IX2_INSTR0_i => IX1_INSTR0_q,
      IX3_INSTR0_i => IX2_INSTR0_q,
      IX1_INSTR1_i => ID_INSTR_q(1),
      IX2_INSTR1_i => IX1_INSTR1_q,
      IX3_INSTR1_i => IX2_INSTR1_q,
      IX1_PA_RES0_i => IX1_PA0_RES, 
      IX1_PA_RES1_i => IX1_PA1_RES,
      IX2_PA_RES0_i => IX2_PA0_RES,
      IX2_PA_RES1_i => IX2_PA1_RES,
      IX3_PA_RES0_i => IX3_DRD0,
      IX3_PA_RES1_i => IX3_DRD1,
      ID_OPX_NOFWD_i => to_signed(WB_RDB1), --ID_OPB1_NOFWD,
      IX1_V_i => ID_V_q,
      IX2_V_i => IX1_V_q,
      IX3_V_i => IX2_V_q,
      IX1_FWDE_i => ID_FWDE_q,
      IX2_FWDE_i => IX1_FWDE_q,
      IX3_FWDE_i => IX2_FWDE_q,
      NOREGS_i => IF_OPB_IMM_q(1),
      NOREGD_i => IF_OPB_q(1),
  
      ID_OPX_o => ID_OPB1
    );
  -- Pipeline-A (dedicated) pre-decoder

  U_PADEC0 : G729A_ASIP_PIPE_A_DEC_2W
    port map(
      INSTR_i => ID_INSTR0,

      FWDE_o => ID_FWDE(0),
      SEL_o => ID_PASEL0
    );

  U_PADEC1 : G729A_ASIP_PIPE_A_DEC_2W
    port map(
      INSTR_i => ID_INSTR1,

      FWDE_o => ID_FWDE(1),
      SEL_o => ID_PASEL1
    );

  -- Pipeline Registers

  process(CLK_i)
  begin
    if(CLK_i = '1' and CLK_i'event) then
      if(RST_i = '1') then
        ID_V_q <= "00";
      else
        ID_V_q(0) <= ID_V(0) and not(ID_HALT0);
        ID_V_q(1) <= ID_V(1) and not(ID_HALT);
      end if;
      ID_PC_q <= IF_PC_q2(2-1 downto 0);      
      ID_INSTR_q(0) <= ID_INSTR0;      
      ID_INSTR_q(1) <= ID_INSTR1;      
      ID_OPA0_q <= ID_OPA0;
      ID_OPB0_q <= ID_OPB0;
      ID_OPA1_q <= ID_OPA1;
      ID_OPB1_q <= ID_OPB1;
      ID_OPC0_q <= ID_OPC0;
      --ID_OPC1_q <= ID_OPC1;
      ID_FWDE_q <= ID_FWDE;
      ID_PASEL0_q <= ID_PASEL0;
      ID_PASEL1_q <= ID_PASEL1;

      ID_PCP1_q <= (IF_PC_q2(1) + 1,IF_PC_q2(0) + 1);      

    end if;
  end process;

  ----------------------------------------------------
  -- IX1 Stage
  ----------------------------------------------------

  -- Pipeline-A

  U_PIPEA0 : G729A_ASIP_PIPE_A_2W
    port map(
      CLK_i => CLK_i,
      SEL_i => ID_PASEL0_q,
      OPA_i => ID_OPA0_q(SDLEN-1 downto 0),
      OPB_i => ID_OPB0_q(SDLEN-1 downto 0),
      ACC_i => WB_ACC_q,
      LDAT_i => DDAT0_i,

      RES_1C_o => IX1_PA0_RES,
      RES_o => IX2_PA0_RES,
      ACC_o => open, --IX2_PA0_ACC,
      OVF_o => IX2_PA0_OVF
    );

  U_PIPEA1 : G729A_ASIP_PIPE_A_2W
    port map(
      CLK_i => CLK_i,
      SEL_i => ID_PASEL1_q,
      OPA_i => ID_OPA1_q(SDLEN-1 downto 0),
      OPB_i => ID_OPB1_q(SDLEN-1 downto 0),
      ACC_i => WB_ACC_q,
      LDAT_i => DDAT1_i,

      RES_1C_o => IX1_PA1_RES,
      RES_o => IX2_PA1_RES,
      ACC_o => open, --IX2_PA1_ACC,
      OVF_o => IX2_PA1_OVF
    );

  U_PIPEB : G729A_ASIP_PIPE_B
    port map(
      CLK_i => CLK_i,
      OP_i => ID_INSTR_q(0).ALU_OP,
      OPA_i => ID_OPA0_q,
      OPB_i => ID_OPB0_q,
      OVF_i => WB_OVF_q,
      ACC_i => WB_ACC_q,

      RES_o => IX2_PB0_RES,
      OVF_o => IX2_PB0_OVF
    );

  -- Pipe-A/B result selection

  IX2_DRD0 <= IX2_PA0_RES when IX1_FWDE_q(0) = '1' else IX2_PB0_RES;
  IX2_OVF0 <= IX2_PA0_OVF when IX1_FWDE_q(0) = '1' else IX2_PB0_OVF;
    
  IX2_DRD1 <= IX2_PA1_RES;
  IX2_OVF1 <= IX2_PA1_OVF;

  -- Branch/Jump processing logic (pipe #0)

  -- Note: loop count setting instructions (LLCR*) are handled
  -- like un-conditional jumps to the following instruction.
  -- This is needed because LLCR* are processed in IX1 stage
  -- when some instruction affecting loop count may have been
  -- already fetched and improperly processed by loop stack
  -- logic.
  -- Loop last instruction is treated in the following way,
  -- to nullify any loop instruction which may be have been
  -- fetched incorrectly.

  IX1_PCLN <= IX1_LLCR or IX1_LEND;

  U_BJXLOG : G729A_ASIP_BJXLOG
    port map(
      CLK_i => CLK_i,
      RST_i => RST_i,
      BJ_OP => ID_INSTR_q(0).BJ_OP,
      PC0P1_i => ID_PCP1_q(0),
      PC1P1_i => ID_PCP1_q(1),
      PC0_i => ID_PC_q(0),
      PCSEL_i => IX1_LEIS,
      OPA_i => ID_OPA0_q,
      OPB_i => ID_OPB0_q,
      OPC_i => ID_OPC0_q,
      IV_i => ID_V_q(0),
      LLCRX_i => IX1_PCLN,
      FSTLL_i => ID_PSTALL,
  
      BJX_o => IX1_BJX,
      BJTA_o => IX1_BJTA
    );

  IX1_V(0) <= ID_V_q(0);

  -- Instr. #1 must be invalidated when:
  -- 1) instr. #0 is a regular branch/jump, OR
  -- 2) instr. #0 is a loop closing instruction.
  --
  -- Both cases trigger IV1_BJX and therefore are distinguished
  -- by checking loop-end instruction selector IX1_LEIS).

  IX1_V(1) <= '0' when (
    (IX1_BJX = '1') and not(IX1_LEIS = '1')
  ) else ID_V_q(1);

  -- Load/Store logic

  U_LSU0 : G729A_ASIP_LSU
    port map(
      IV_i => ID_V_q(0),
      LS_OP_i => ID_INSTR_q(0).LS_OP,
      OPA_i => ID_OPA0_q,
      OPB_i => ID_OPB0_q,
      OPC_i => ID_OPC0_q,

      DRE_o => DRE_o(0),
      DWE_o => IX1_DWE,
      DADR_o => IX1_DADR,
      DDAT_o => IX1_DDATO
    );

  DWE0_o <= IX1_DWE;
  DADR0_o <= IX1_DADR;
  DDAT0_o <= IX1_DDATO;

  U_LU1 : G729A_ASIP_LU
    port map(
      IV_i => ID_V_q(1),
      LS_OP_i => ID_INSTR_q(1).LS_OP,
      OPA_i => ID_OPA1_q,
      OPB_i => ID_OPB1_q,

      DRE_o => DRE_o(1),
      DADR_o => DADR1_o
    );

  ----------------------------------------------------
  -- Store Checker
  ----------------------------------------------------

  -- synthesis translate_off

  G_ST : if(SIMULATION_ONLY = '1') generate

  U_STCHK : G729A_ASIP_ST_CHECKER
    generic map(
      ST_FILENAME => ST_FILENAME
    )
    port map(
      CLK_i => CLK_i,
      ENB_i => CHK_ENB_i,
      DWE_i => IX1_DWE,
      DADR_i => IX1_DADR,
      DDATO_i => IX1_DDATO
    );

  end generate;

  -- synthesis translate_on

  -- Loop Stack control logic

  U_LCSTK_IX : G729A_ASIP_LCSTKLOG_IX
    port map(
      IX_V_i => ID_V_q(0), 
      IX_INSTR_i => ID_INSTR_q(0),
      IX_OPA_i => ID_OPA0_q,

      SRST_o => IX1_SRST,
      LLBRX_o => IX1_LLBR,
      LLERX_o => IX1_LLER,
      LLCRX_o => IX1_LLCR,
      IMM_o => IX1_IMM
    );

  -- Overflow result selection
  -- 1) OVF_q or (instruction #0 OVF) or (instruction #1 OVF)
  -- 2) OVF_q or (instruction #0 OVF)
  -- 3) OVF_q or (instruction #1 OVF)
  -- 4) (instruction #1 OVF)
  -- 5) OVF_q

  -- Pipeline Registers

  process(CLK_i)
  begin
    if(CLK_i = '1' and CLK_i'event) then
      if(RST_i = '1') then
        IX1_V_q <= "00";
      else
        IX1_V_q <= IX1_V;
      end if;
      IX1_INSTR0_q <= ID_INSTR_q(0);      
      IX1_INSTR1_q <= ID_INSTR_q(1);      
      IX1_FWDE_q <= ID_FWDE_q;
    end if;
  end process;

  ----------------------------------------------------
  -- IX3 Stage
  ----------------------------------------------------

  IX2_FWDE(0) <= '1'; 
  IX2_FWDE(1) <= IX1_FWDE_q(1); 

  -- Pipeline Registers

  process(CLK_i)
  begin
    if(CLK_i = '1' and CLK_i'event) then
      if(RST_i = '1') then
        IX2_V_q <= "00";
      else
        IX2_V_q <= IX1_V_q;
      end if;
      IX2_INSTR0_q <= IX1_INSTR0_q;      
      IX2_INSTR1_q <= IX1_INSTR1_q;      
      IX2_FWDE_q <= IX2_FWDE;
      IX2_DRD0_q <= IX2_DRD0;
      IX2_DRD1_q <= IX2_DRD1;
      IX2_OVF0_q <= IX2_OVF0;
      IX2_OVF1_q <= IX2_OVF1;
    end if;
  end process;

  IX3_DRD0 <= IX2_DRD0_q;
  IX3_DRD1 <= IX2_DRD1_q;
  IX3_OVF0 <= IX2_OVF0_q;
  IX3_OVF1 <= IX2_OVF1_q;

  ----------------------------------------------------
  -- WB Stage
  ----------------------------------------------------

  -- Register File

  WB_WE0 <= IX2_V_q(0) and IX2_INSTR0_q.WRD;
  WB_WE1 <= IX2_V_q(1) and IX2_INSTR1_q.WRD;

  U_REGF : G729A_ASIP_REGFILE_16X16_2W
    port map(
      CLK_i => CLK_i,
      RA0_i => ID_INSTR0.RA,
      RA1_i => ID_INSTR0.RB,
      RA2_i => ID_INSTR1.RA,
      RA3_i => ID_INSTR1.RB,
      WA0_i => IX2_INSTR0_q.RD,
      WA1_i => IX2_INSTR1_q.RD,
      LR0_i => ID_INSTR0.LA,
      LR1_i => ID_INSTR0.LB,
      LR2_i => ID_INSTR1.LA,
      LR3_i => ID_INSTR1.LB,
      LW0_i => IX2_INSTR0_q.LD,
      LW1_i => IX2_INSTR1_q.LD,
      WE0_i => WB_WE0,
      WE1_i => WB_WE1,
      D0_i => to_std_logic_vector(IX3_DRD0),
      D1_i => to_std_logic_vector(IX3_DRD1),
  
      Q0_o => WB_RDA0,
      Q1_o => WB_RDB0,
      Q2_o => WB_RDA1,
      Q3_o => WB_RDB1
    );

  -- Overflow register

  -- It's allowed to execute in parallel two instructions
  -- writing overflow register.

  process(CLK_i)
  begin
    if(CLK_i = '1' and CLK_i'event) then
      if(RST_i = '1') then
        WB_OVF_q <= '0';
      elsif(IX2_INSTR0_q.WOVF = '1' and IX2_INSTR0_q.WOVF = '1') then
        -- both instr. #0 and #1 write OVF flag
        if(IX2_INSTR0_q.IMNMC = IM_COVF) then
          -- instr. #0 is covf
          WB_OVF_q <= IX3_OVF1;
        else
          WB_OVF_q <= WB_OVF_q or IX3_OVF0 or IX3_OVF1;
        end if;
      elsif(IX2_INSTR0_q.WOVF = '1') then
        -- only instr. #0 write OVF flag
        if(IX2_INSTR0_q.IMNMC = IM_COVF) then
          -- instr. #0 is covf
          WB_OVF_q <= '0';
        else
          WB_OVF_q <= WB_OVF_q or IX3_OVF0;
        end if;
      elsif(IX2_INSTR1_q.WOVF = '1') then
        -- only instr. #1 write OVF flag
        WB_OVF_q <= WB_OVF_q or IX3_OVF1;
      end if;
    end if;
  end process;

  -- Accumulator register

  -- WARNING: it's not possible to execute in parallel two
  -- instructions writing accumulator register!

  process(CLK_i)
  begin
    if(CLK_i = '1' and CLK_i'event) then
      if(RST_i = '1') then
        WB_ACC_q <= to_signed(0,LDLEN);
      elsif(IX1_V_q(0) = '1' and IX1_INSTR0_q.WACC = '1') then
        WB_ACC_q <= IX2_DRD0;
      elsif(IX1_V_q(1) = '1' and IX1_INSTR1_q.WACC = '1') then
        WB_ACC_q <= IX2_DRD1;
      end if;
    end if;
  end process;

  -- Parallel eXecution Enable register

  process(CLK_i)
  begin
    if(CLK_i = '1' and CLK_i'event) then
      if(RST_i = '1') then
        WB_PXE_q <= '1'; -- PXE is on at reset
      elsif(IX2_V_q(0) = '1' and IX2_INSTR0_q.IMNMC = IM_PXON) then
        WB_PXE_q <= '1';
      elsif(
        (IX2_V_q(0) = '1' and IX2_INSTR0_q.IMNMC = IM_PXOFF) or
        (IX2_V_q(1) = '1' and IX2_INSTR1_q.IMNMC = IM_PXOFF)
      ) then
        WB_PXE_q <= '0';
      end if;
    end if;
  end process;

  ----------------------------------------------------
  -- Write-Back Checker
  ----------------------------------------------------

  -- synthesis translate_off

  G_WB : if(SIMULATION_ONLY = '1') generate

  U_WBCHK : G729A_ASIP_WB_CHECKER
    generic map(
      WB_FILENAME => WB_FILENAME
    )
    port map(
      CLK_i => CLK_i,
      ENB_i => CHK_ENB_i,
      WE0_i => WB_WE0,
      WE1_i => WB_WE1,
      IX_INSTR0_i => IX2_INSTR0_q,
      IX_INSTR1_i => IX2_INSTR1_q,
      IX_DRD0_i => IX3_DRD0,
      IX_DRD1_i => IX3_DRD1
    );

  end generate;

  -- synthesis translate_on

  ----------------------------------------------------
  -- Statistics
  ----------------------------------------------------

  G_STAT : if(SIMULATION_ONLY = '1') generate

  U_STAT : G729A_ASIP_STATS
    port map(
      CLK_i => CLK_i,
      RST_i => RST_i,
      ID_V_i => IF_V_q2,
      ID_PS_i(0) => ID_PS0,
      ID_PS_i(1) => ID_PS1,
      ID_PXE1_i => ID_PXE1,
      IX2_V_i => IX2_V_q,
      STRT_i => STRT_i,
      HALT_i => ID_HALT
    );

  end generate;

end ARC;
