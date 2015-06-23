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
-- G.729A ASIP pipeline-A (dedicated) decoder 
---------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all; 
use IEEE.numeric_std.all;

library WORK;
use WORK.G729A_ASIP_PKG.all;
use work.G729A_ASIP_IDEC_2W_PKG.all;
use WORK.G729A_ASIP_OP_PKG.all;

entity G729A_ASIP_PIPE_A_DEC_2W is
  port(
    INSTR_i : in DEC_INSTR_T;

    FWDE_o : out std_logic;
    SEL_o :  out std_logic_vector(7-1 downto 0)
  );
end G729A_ASIP_PIPE_A_DEC_2W;

architecture ARC of G729A_ASIP_PIPE_A_DEC_2W is

begin

  -- Note:
  -- forward-enable flags account for ld/stpp instructions in
  -- order to correctly handle rA register incrementation
  -- (that is performed by logic inside pipe-A).

  -- Result forward-enable flag

  FWDE_o <= '1' when (
    INSTR_i.IMNMC = IM_ADD or
    INSTR_i.IMNMC = IM_ADDI or
    INSTR_i.IMNMC = IM_SUB or
    INSTR_i.IMNMC = IM_SUBI or
    INSTR_i.IMNMC = IM_MUL or
    INSTR_i.IMNMC = IM_MULI or
    INSTR_i.IMNMC = IM_MOVI or
    INSTR_i.IMNMC = IM_LMAC or
    INSTR_i.IMNMC = IM_LMACI or
    INSTR_i.IMNMC = IM_LMSU or
    INSTR_i.IMNMC = IM_LMSUI or
    INSTR_i.IMNMC = IM_LD
  ) else '0';

  -- pipe-A operation selector

  process(INSTR_i)
  begin
    case INSTR_i.IMNMC is
      when IM_ADD|IM_ADDI => SEL_o <= "0000001";
      when IM_SUB|IM_SUBI => SEL_o <= "0000010";
      when IM_MUL|IM_MULI => SEL_o <= "0000100";
      when IM_MOVI => SEL_o <= "0001000";
      when IM_LMAC|IM_LMACI => SEL_o <= "0010000";
      when IM_LMSU|IM_LMSUI => SEL_o <= "0100000";
      when others => SEL_o <= "1000000"; -- ld/ldpp
    end case;
  end process;

end ARC;

---------------------------------------------------------------
-- A-pipeline 
---------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all; 
use IEEE.numeric_std.all;

library WORK;
use WORK.G729A_ASIP_PKG.all;
use WORK.G729A_ASIP_BASIC_PKG.all;
use WORK.G729A_ASIP_ARITH_PKG.all;
use WORK.G729A_ASIP_OP_PKG.all;

entity G729A_ASIP_PIPE_A_2W is
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
end G729A_ASIP_PIPE_A_2W;

architecture ARC of G729A_ASIP_PIPE_A_2W is

  constant MUL_OVFVAL : LDWORD_T := hex_to_signed("40000000",LDLEN);
  constant ZERO16 : SDWORD_T := (others => '0');

  constant OP_ADD : natural := 0;
  constant OP_SUB : natural := 1;
  constant OP_MUL : natural := 2;
  constant OP_MOV : natural := 3;
  constant OP_LMAC : natural := 4;
  constant OP_LMSU : natural := 5;
  constant OP_LOAD : natural := 6;

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

  signal ZERO : std_logic := '0';
  signal ONE : std_logic := '1';
  signal OPA_SGN,OPB_SGN : std_logic;
  signal OPB_N : SDWORD_T;
  signal ADD_RES : SDWORD_T;
  signal ADD_RES_SGN,ADD_OVF : std_logic;
  signal SUB_RES : SDWORD_T;
  signal SUB_RES_SGN,SUB_OVF : std_logic;
  signal PROD : LDWORD_T;
  signal MUL_RES : SDWORD_T;
  signal MUL_RES_SGN,MUL_OVF : std_logic;
  signal OPA_ZERO,OPB_ZERO : std_logic;
  signal RES_1C,RES_1C_q,RES_1C_NOVF : SDWORD_T;
  signal OVF_1C,OVF_1C_q : std_logic;
  signal SEL_q : std_logic_vector(7-1 downto 0);
  signal MAC_MUL_OVF,MAC_ADD_OVF1,MAC_ADD_OVF2 : std_logic;
  signal MAC_MUL_OVF_q : std_logic;
  signal MAC_PROD,MAC_PROD_OVF : LDWORD_T;
  signal MAC_PROD_q : LDWORD_T;
  signal MAC_SUM1,MAC_SUM2 : LDWORD_T;
  signal MAC_RES : LDWORD_T;
  signal MAC_SA,MAC_SA_q,MAC_OVF : std_logic;
  signal MAC_PROD_SGN,MAC_PROD_SGN_q : std_logic;

begin

  ------------------------------------
  -- Notes
  ------------------------------------

  -- This pipeline executes only the following high-frequency
  -- instructions:
  -- add/addi,
  -- sub/subi,
  -- mul/muli,
  -- lmac/lmaci/lmsu/lmsui and
  -- movi.
  -- Additionally, the pipeline merges load data to 

  -- Instructions add/addi, sub/subi, mul/muli and movi
  -- are executed in one cycle (their results being muxed and
  -- registed after first cycle), while instructions lmac/lmaci/
  -- lmsu/lmsui are executed in two cycles.

  ------------------------------------
  -- operands sign
  ------------------------------------

  OPA_SGN <= OPA_i(SDLEN-1);

  OPB_SGN <= OPB_i(SDLEN-1);

  ------------------------------------
  -- operand zero flags
  ------------------------------------

  OPA_ZERO <= '1' when (OPA_i = 0) else '0';

  OPB_ZERO <= '1' when (OPB_i = 0) else '0';

  ------------------------------------
  -- addition
  ------------------------------------

  -- addition result
  --ADD_RES <= OPA_i + OPB_i;

  -- carry-select adder (to improve timing)

  U_ADD : G729A_ASIP_ADDER_F
    generic map(
      LEN1 => SDLEN/2,
      LEN2 => SDLEN/2
    )
    port map(
      OPA_i => OPA_i,
      OPB_i => OPB_i,
      CI_i => ZERO,
      SUM_o => ADD_RES
    );

  -- addition result sign
  ADD_RES_SGN <= ADD_RES(SDLEN-1);

  -- Addition overflow flag
  ADD_OVF <= overflow('0',OPA_SGN,OPB_SGN,ADD_RES_SGN);

  ------------------------------------
  -- subtraction
  ------------------------------------

  -- addition result
  --SUB_RES <= OPA_i - OPB_i;

  OPB_N <= not(OPB_i);

  -- carry-select adder (to improve timing)

  U_SUB : G729A_ASIP_ADDER_F
    generic map(
      LEN1 => SDLEN/2,
      LEN2 => SDLEN/2
    )
    port map(
      OPA_i => OPA_i,
      OPB_i => OPB_N,
      CI_i => ONE,
      SUM_o => SUB_RES
    );

  -- subtraction result sign
  SUB_RES_SGN <= SUB_RES(SDLEN-1);

  -- subtraction overflow flag
  SUB_OVF <= overflow('1',OPA_SGN,OPB_SGN,SUB_RES_SGN);

  ------------------------------------
  -- 16x16 multiplication
  -- (result is shared by mul,lmac/i
  -- and lmsu/i instructions)
  ------------------------------------

  PROD <= OPA_i * OPB_i;

  -- multiplication result
  process(PROD)
    variable TMP : LDWORD_T;
  begin
    TMP := shift_right(PROD,SDLEN-1);
    MUL_RES <= TMP(SDLEN-1 downto 0); 
  end process;

  -- multiplication result sign
  MUL_RES_SGN <= OPA_i(SDLEN-1) xor OPB_i(SDLEN-1) when
    (OPA_ZERO = '0' and OPB_ZERO = '0') else '0';

  -- multiplication overflow flag
  MUL_OVF <= PROD(LDLEN-1) xor MUL_RES_SGN;

  ------------------------------------
  -- port #0 result and overflow flag
  -- (1-cycle instructions only)
  ------------------------------------

  -- Overflow flag mux

  process(SEL_i,ADD_OVF,ADD_RES_SGN,SUB_OVF,SUB_RES_SGN,MUL_OVF,MUL_RES_SGN)
  begin
    if(SEL_i(OP_MUL) = '1') then
      OVF_1C <= MUL_OVF;
    elsif(SEL_i(OP_ADD) = '1') then
      OVF_1C <= ADD_OVF;
    elsif(SEL_i(OP_SUB) = '1') then
      OVF_1C <= SUB_OVF;
    else
      OVF_1C <= '0';
    end if;
  end process;

  -- Result mux

  process(SEL_i,ADD_RES,SUB_RES,MUL_RES,OPB_i,OVF_1C,MUL_OVF,
    ADD_OVF,SUB_OVF,ADD_RES_SGN,SUB_RES_SGN,MUL_RES_SGN)
  begin
    if(SEL_i(OP_MUL) = '1') then
      if(MUL_OVF = '0') then
        RES_1C <= MUL_RES;
      elsif(MUL_RES_SGN = '1') then
        RES_1C <= MIN_16;
      else
        RES_1C <= MAX_16;
      end if;
    elsif(SEL_i(OP_ADD) = '1') then
      if(ADD_OVF = '0') then
        RES_1C <= ADD_RES;
      elsif(ADD_RES_SGN = '1') then
        RES_1C <= MIN_16;
      else
        RES_1C <= MAX_16;
      end if;
    elsif(SEL_i(OP_SUB) = '1') then
      if(SUB_OVF = '0') then
        RES_1C <= SUB_RES;
      elsif(SUB_RES_SGN = '1') then
        RES_1C <= MIN_16;
      else
        RES_1C <= MAX_16;
      end if;
    else
      RES_1C <= OPB_i;
    end if;
  end process;

  ------------------------------------
  -- pipe stage 1 outputs
  ------------------------------------

  RES_1C_o <= RES_1C;

  ------------------------------------
  -- pipe register
  ------------------------------------

  process(CLK_i)
  begin
    if(CLK_i = '1' and CLK_i'event) then
      SEL_q <= SEL_i;
      RES_1C_q <= RES_1C;
      OVF_1C_q <= OVF_1C;
    end if;
  end process;

  ------------------------------------
  -- lmac/i and lmsu/i
  ------------------------------------

  -- lmac/lmsu result is selected from three different sources:
  -- 1) multiplication actual result plus accumulator content, when
  -- nor multiplication and neither addition result in overflow.
  -- 2) multiplication overflow result (either MAX32 or -MAX32) plus
  -- accumulator content, when multiplication results in overflow but
  -- addition doesn't. 
  -- 3) addition overflow result, when addition results in overflow
  -- (multiplication result is do-not-care in this case).

  -- Source #1

  -- subtract/add selector
  MAC_SA <= SEL_i(OP_LMSU);

  -- (32-bit) Multiplication overflow flag
  MAC_MUL_OVF <= '1' when PROD = MUL_OVFVAL else '0';

  -- shift PROD left by 1 bit, and negate result if operation
  -- is of MSU type.

  MAC_PROD <= shift_left(PROD,1) when MAC_SA = '0' else 
    not(shift_left(PROD,1));

  -- sign of MAC_PROD (before negation)
  MAC_PROD_SGN <= PROD(LDLEN-1);

  -- pipe register
  process(CLK_i)
  begin
    if(CLK_i = '1' and CLK_i'event) then
      MAC_PROD_q <= MAC_PROD;
      MAC_MUL_OVF_q <= MAC_MUL_OVF;
      MAC_SA_q <= MAC_SA;
      MAC_PROD_SGN_q <= MAC_PROD_SGN;
    end if;
  end process;

  -- MAC_SUM1 is MAC/MSU result assuming overflow occurs nor in
  -- multiplication and neither in addition/subtraction.

  U_ADD1 : G729A_ASIP_ADDER_F
    generic map(
      LEN1 => SDLEN,
      LEN2 => SDLEN
    )
    port map(
      OPA_i => ACC_i,
      OPB_i => MAC_PROD_q,
      CI_i => MAC_SA_q,
      SUM_o => MAC_SUM1
    );

  -- Addition #1 overflow flag
  MAC_ADD_OVF1 <= overflow(
    MAC_SA_q,
    ACC_i(LDLEN-1),
    MAC_PROD_SGN_q,
    MAC_SUM1(LDLEN-1)
  );

  -- Source #2

  -- MAC_PROD_OVF is multiplication result assuming this operation
  -- results in overflow (MAX_32 for lmac* and -MAX_32 for lmsu*,
  -- latter value being generated negating MAX_32 and then add 1 
  -- in addition to accumulator).

  MAC_PROD_OVF <= MAX_32 when MAC_SA_q = '0' else not(MAX_32);

  -- MAC_SUM2 is MAC/MSU result when overflow occurs in multiplication, but
  -- not in addition/subtraction

  U_ADD2 : G729A_ASIP_ADDER_F
    generic map(
      LEN1 => SDLEN,
      LEN2 => SDLEN
    )
    port map(
      OPA_i => ACC_i,
      OPB_i => MAC_PROD_OVF,
      CI_i => MAC_SA_q,
      SUM_o => MAC_SUM2
    );

  -- Addition #2 overflow flag
  MAC_ADD_OVF2 <= overflow(
    MAC_SA_q,
    ACC_i(LDLEN-1),
    MAC_PROD_OVF(LDLEN-1),
    MAC_SUM2(LDLEN-1)
  );

  -- Final MAC/MSU overflow flag
  MAC_OVF <= MAC_MUL_OVF_q or MAC_ADD_OVF1;

  -- Select lmac*/lmsu* result

  -- Note: MAC_SUM1 has the longest timing path, in order
  -- to improve timing it's removed from this mux and fed
  -- directly to the main result mux (see below).

  process(MAC_OVF,MAC_MUL_OVF_q,ACC_i,MAC_SUM1,MAC_SUM2,MAC_ADD_OVF2)
  begin
    --if(MAC_OVF = '0') then
    --  -- no overflow
    --  MAC_RES <= MAC_SUM1;
    --elsif(MAC_MUL_OVF_q = '1' and MAC_ADD_OVF2 = '0') then
    if(MAC_MUL_OVF_q = '1' and MAC_ADD_OVF2 = '0') then
      -- overflow in multiplication, but not in addition
      MAC_RES <= MAC_SUM2;
    elsif(ACC_i(LDLEN-1) = '0') then
      -- positive overflow in addition
      MAC_RES <= MAX_32;   
    else
      -- negative overflow in addition
      MAC_RES <= MIN_32;   
    end if;
  end process;

  ------------------------------------
  -- pipe stage 2 outputs
  ------------------------------------

  process(SEL_q,MAC_SUM1,MAC_OVF,MAC_RES,LDAT_i,RES_1C_q)
  begin
    if(MAC_OVF = '0' and (SEL_q(OP_LMAC) = '1' or SEL_q(OP_LMSU) = '1')) then
      RES_o(SDLEN-1 downto 0) <= MAC_SUM1(SDLEN-1 downto 0);
    elsif(SEL_q(OP_LOAD) = '1') then
      RES_o(SDLEN-1 downto 0) <= to_signed(LDAT_i);
    elsif((SEL_q(OP_LMAC) = '1' or SEL_q(OP_LMSU) = '1')) then
      RES_o(SDLEN-1 downto 0) <= MAC_RES(SDLEN-1 downto 0);
    else
      RES_o(SDLEN-1 downto 0) <= RES_1C_q;
    end if;
  end process;

  RES_o(LDLEN-1 downto SDLEN) <= MAC_SUM1(LDLEN-1 downto SDLEN) when
    (MAC_OVF = '0') else MAC_RES(LDLEN-1 downto SDLEN);

  OVF_o <= MAC_OVF when (SEL_q(OP_LMAC) = '1' or SEL_q(OP_LMSU) = '1')
    else '0' when (SEL_q(OP_LOAD) = '1') 
    else OVF_1C_q;

  ACC_o <= MAC_RES;

end ARC;
