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
-- G.729A ASIP pipeline-B
---------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all; 
use IEEE.numeric_std.all;

library WORK;
use WORK.G729A_ASIP_PKG.all;
use WORK.G729A_ASIP_BASIC_PKG.all;
use WORK.G729A_ASIP_ARITH_PKG.all;
use WORK.G729A_ASIP_OP_PKG.all;

entity G729A_ASIP_PIPE_B is
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
end G729A_ASIP_PIPE_B;

architecture ARC of G729A_ASIP_PIPE_B is

  constant MUL_OVFVAL : LDWORD_T := hex_to_signed("40000000",LDLEN);
  constant ZERO16 : SDWORD_T := (others => '0');

  constant OP_ADD : natural := 0;
  constant OP_SUB : natural := 1;
  constant OP_MUL : natural := 2;
  constant OP_MOV : natural := 3;
  constant OP_LOAD : natural := 4;
  constant OP_LMAC : natural := 5;
  constant OP_LMSU : natural := 6;

  component G729A_ASIP_ADDER is
    generic(
      WIDTH : integer := 16
    );
    port(
      OPA_i : in signed(WIDTH-1 downto 0);
      OPB_i : in signed(WIDTH-1 downto 0);
      CI_i : in std_logic;

      SUM_o : out signed(WIDTH-1 downto 0)
    );
  end component;

  component G729A_ASIP_ADDER_F is
    generic(
      LEN1 : integer := 16;
      LEN2 : integer := 16
    );
    port(
      OPA_i : in signed(LEN1+LEN2-1 downto 0);
      OPB_i : in signed(LEN1+LEN2-1 downto 0);
      CI_i : in std_logic;

      SUM_o : out signed(LEN1+LEN2-1 downto 0)
    );
  end component;

  component G729A_ASIP_ADDSUB_PIPEB is
    port(
      CTRL_i : in ADD_CTRL;
      OPA_i : in LDWORD_T;
      OPB_i : in LDWORD_T;
  
      RES_o : out LDWORD_T;
      OVF_o : out std_logic
    );
  end component;

  component G729A_ASIP_MULU_PIPEB is
    port(
      CLK_i : in std_logic;
      CTRL_i : in MUL_CTRL;
      OPA_i : in LDWORD_T;
      OPB_i : in LDWORD_T;

      RES_o : out LDWORD_T;
      OVF_o : out std_logic
    );
  end component;

  component G729A_ASIP_SHFT is
    port(
      CTRL_i : in SHF_CTRL;
      SI_i : in LDWORD_T;
      SHFT_i : in SDWORD_T; --LONG_SHIFT_OVF_T;
  
      SO_o : out LDWORD_T;
      OVF_o : out std_logic
    );
  end component;

  component G729A_ASIP_LOGIC is
    port(
      CTRL_i : in LOG_CTRL;
      OPA_i : in LDWORD_T;
      OPB_i : in LDWORD_T;
  
      RES_o : out LDWORD_T
    );
  end component;

  -- check for overflow in addition/subtraction
  function overflow(
    SA : std_logic;
    SGNA : std_logic;
    SGNB : std_logic;
    SGNR : std_logic
  ) return std_logic is
  variable OVF : std_logic;
  begin
    -- overflow flag
    if(SA = '0') then
      -- addition
      if(SGNR = '1') then
        OVF := not(SGNA or SGNB);
      else
        OVF := (SGNA and SGNB);
      end if;
    else
      -- subtraction
      if(SGNR = '1') then
        OVF := (not(SGNA) and SGNB);
      else
        OVF := (SGNA and not(SGNB));
      end if;
    end if;
    return(OVF);
  end function;

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

  signal OP_q :  ALU_OP_T;
  signal OPA_q : LDWORD_T;
  signal OPB_q : LDWORD_T;
  signal OVF,ADD_OVF,MUL_OVF,SHF_OVF : std_logic;
  signal ADD_OVF_q,SHF_OVF_q : std_logic;
  signal RES,ADD_RES,MUL_RES,SHF_RES,LOG_RES : LDWORD_T;
  signal ADD_RES_q,SHF_RES_q,LOG_RES_q : LDWORD_T;
  signal AC : ADD_CTRL;
  signal MC : MUL_CTRL;
  signal SC : SHF_CTRL;
  signal LC : LOG_CTRL;
  signal ADD_SEL,MUL_SEL,SHF_SEL,LOG_SEL : std_logic;
  signal ADD_SEL_q,MUL_SEL_q,SHF_SEL_q,LOG_SEL_q : std_logic;
  signal SHFT : LONG_SHIFT_OVF_T;

begin

  ------------------------------------
  -- Add/subtract unit operation selection
  ------------------------------------

  process(OP_i)
  begin
    ADD_SEL <= '1';
    case OP_i is
      when ALU_ABS =>
        AC <= AC_ABS;
      --when ALU_ADD =>
      --  AC <= AC_ADD;
      when ALU_NEG =>
        AC <= AC_NEG;
      --when ALU_SUB =>
      --  AC <= AC_SUB;
      when ALU_LABS =>
        AC <= AC_LABS;
      when ALU_LADD =>
        AC <= AC_LADD;
      when ALU_LNEG =>
        AC <= AC_LNEG;
      when ALU_LSUB =>
        AC <= AC_LSUB;
      when ALU_LEXT =>
        AC <= AC_LEXT;
      when ALU_RND =>
        AC <= AC_RND;
      --when ALU_INC =>
      --  ADD_SEL <= '0'; -- ALU result is load data
      --  AC <= AC_INC;
      --when ALU_DEC =>
      --  ADD_SEL <= '0'; -- ALU result is load data
      -- -AC <= AC_DEC;
      when others =>
        ADD_SEL <= '0';
        AC <= AC_NIL;
    end case;
  end process;

  ------------------------------------
  -- Multiply unit operation selection
  ------------------------------------

  process(OP_i)
  begin
    MUL_SEL <= '1';
    case OP_i is
      --when ALU_MUL =>
      --  MC <= MC_MUL;
      when ALU_LMUL =>
        MC <= MC_LMUL;
      when ALU_MULA =>
        MC <= MC_MULA;
      when ALU_MULR =>
        MC <= MC_MULR;
      --when ALU_LMAC =>
      --  MC <= MC_LMAC;
      --when ALU_LMSU =>
      --  MC <= MC_LMSU;
      when ALU_M3216 =>
        MC <= MC_M3216;
      when others =>
        MUL_SEL <= '0';
        MC <= MC_NIL;
    end case;
  end process;

  ------------------------------------
  -- Shift/normalize unit operation selection
  ------------------------------------

  process(OP_i)
  begin
    SHF_SEL <= '1';
    case OP_i is
      when ALU_SHL =>
        SC <= SC_SHL;
      when ALU_SHR =>
        SC <= SC_SHR;
      when ALU_LSHL =>
        SC <= SC_LSHL;
      when ALU_LSHR =>
        SC <= SC_LSHR;
      when ALU_NRMS =>
        SC <= SC_NRMS;
      when ALU_NRML =>
        SC <= SC_NRML;
      when others =>
        SHF_SEL <= '0';
        SC <= SC_NIL;
    end case;
  end process;

  ------------------------------------
  -- Logic unit operation selection
  ------------------------------------

  process(OP_i)
  begin
    LOG_SEL <= '1';
    case OP_i is
      when ALU_AND =>
        LC <= LC_AND;
      when ALU_OR =>
        LC <= LC_OR;
      when others =>
        LOG_SEL <= '0';
        LC <= LC_NIL;
    end case;
  end process;

  ------------------------------------
  -- Add/Subtract unit
  ------------------------------------

  U_ADD : G729A_ASIP_ADDSUB_PIPEB
    port map(
      CTRL_i => AC,
      OPA_i => OPA_i,
      OPB_i => OPB_i,
  
      RES_o => ADD_RES,
      OVF_o => ADD_OVF
    );

  -- pipe register
  process(CLK_i)
  begin
    if(CLK_i = '1' and CLK_i'event) then
      ADD_RES_q <= ADD_RES;
      ADD_OVF_q <= ADD_OVF;
      ADD_SEL_q <= ADD_SEL;
    end if;
  end process;

  ------------------------------------
  -- Multiply unit
  ------------------------------------

  U_MUL : G729A_ASIP_MULU_PIPEB
    port map(
      CLK_i => CLK_i,
      CTRL_i  => MC,
      OPA_i => OPA_i,
      OPB_i => OPB_i,

      RES_o => MUL_RES,
      OVF_o => MUL_OVF
    );

  -- pipe register
  process(CLK_i)
  begin
    if(CLK_i = '1' and CLK_i'event) then
      MUL_SEL_q <= MUL_SEL;
    end if;
  end process;

  ------------------------------------
  -- Shift/Normalize unit
  ------------------------------------

  U_SHF : G729A_ASIP_SHFT
    port map(
      CTRL_i => SC,
      SI_i => OPA_i,
      SHFT_i => OPB_i(SDLEN-1 downto 0),
  
      SO_o => SHF_RES,
      OVF_o => SHF_OVF
    );

  -- pipe register
  process(CLK_i)
  begin
    if(CLK_i = '1' and CLK_i'event) then
      SHF_RES_q <= SHF_RES;
      SHF_OVF_q <= SHF_OVF;
      SHF_SEL_q <= SHF_SEL;
    end if;
  end process;

  ------------------------------------
  -- Logic unit
  ------------------------------------

  U_LOG : G729A_ASIP_LOGIC
    port map(
      CTRL_i => LC,
      OPA_i => OPA_i,
      OPB_i => OPB_i,
  
      RES_o => LOG_RES
    );

  -- pipe register
  process(CLK_i)
  begin
    if(CLK_i = '1' and CLK_i'event) then
      LOG_RES_q <= LOG_RES;
      LOG_SEL_q <= LOG_SEL;
    end if;
  end process;

  ------------------------------------
  -- output flags and result mux
  ------------------------------------

  -- pipe register
  process(CLK_i)
  begin
    if(CLK_i = '1' and CLK_i'event) then
      OPA_q <= OPA_i;
      OPB_q <= OPB_i;
      OP_q <= OP_i;
    end if;
  end process;

  -- This encoding allows to set relative priority among the
  -- functional unit according to timing requirements.

  process(OP_q,ADD_SEL_q,ADD_RES_q,ADD_OVF_q,MUL_SEL_q,MUL_RES,MUL_OVF,
    SHF_SEL_q,SHF_RES_q,SHF_OVF_q,LOG_SEL_q,LOG_RES_q,OPA_q,OPB_q,ACC_i,OVF_i)
    variable ZERO_PAD : SDWORD_T := (others => '0');
  begin
    if(MUL_SEL_q = '1') then
      RES <= MUL_RES;
      OVF <= MUL_OVF;
    elsif(ADD_SEL_q = '1') then
      RES <= ADD_RES_q;
      OVF <= ADD_OVF_q;
    elsif(SHF_SEL_q = '1') then
      RES <= SHF_RES_q;
      OVF <= SHF_OVF_q;
    elsif(LOG_SEL_q = '1') then
      RES <= LOG_RES_q;
      OVF <= '0';
    elsif(OP_q = ALU_MOVA) then
      RES <= OPA_q;
      OVF <= '0';
    elsif(OP_q = ALU_MOVB) then
      RES <= OPB_q;
      OVF <= '0';
    elsif(OP_q = ALU_RACC) then
      RES <= ACC_i;
      OVF <= '0';
    else -- ALU_OVF
      RES <= (0 => OVF_i,others => '0');
      OVF <= '0';
    end if;
  end process;

  -- "main" result
  RES_o <= RES;

  -- overflow flag
  OVF_o <= OVF;

end ARC;
