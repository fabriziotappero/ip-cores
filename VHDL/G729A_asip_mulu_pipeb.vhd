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
-- G.729A ASIP Two-cycle multiply unit
---------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all; 
use IEEE.numeric_std.all;

library WORK;
use WORK.G729A_ASIP_PKG.all;
use WORK.G729A_ASIP_BASIC_PKG.all;
use WORK.G729A_ASIP_ARITH_PKG.all;
use WORK.G729A_ASIP_OP_PKG.all;

entity G729A_ASIP_MULU_PIPEB is
  port(
    CLK_i : in std_logic;
    CTRL_i : in MUL_CTRL;
    OPA_i : in LDWORD_T;
    OPB_i : in LDWORD_T;

    RES_o : out LDWORD_T;
    OVF_o : out std_logic
  );
end G729A_ASIP_MULU_PIPEB;

architecture ARC of G729A_ASIP_MULU_PIPEB is

  constant ZERO32 : LDWORD_T := hex_to_signed("00000000",LDLEN);

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

  function "not"(S : signed) return signed is
    variable NOTS : signed(S'high downto S'low);
  begin
    for k in S'low to S'high loop
      NOTS(k) := not(S(k));
    end loop;
    return(NOTS);
  end function;

  signal PROD1,PROD2 : LDWORD_T;
  signal MULA_RES : LDWORD_T;
  signal MULA_RES_q : LDWORD_T;
  signal LMUL_PROD_q : LDWORD_T;
  signal LMUL_RES : LDWORD_T;
  signal LMUL_OVF : std_logic;
  signal MULR_PROD_q,MULR_SUM1,MULR_SUM2 : LDWORD_T;
  signal MULR_RES : LDWORD_T;
  signal MULR_OVF : std_logic;
  signal M3216_PRODHI,M3216_PRODLO2 : LDWORD_T;
  signal M3216_PRODLO1 : SDWORD_T;
  signal M3216_PRODHI_q,M3216_PRODLO_q : LDWORD_T;
  signal M3216_MUL_OVFHI,M3216_MUL_OVFLO : std_logic;
  signal M3216_MUL_OVF_q : std_logic;
  signal M3216_SUM,M3216_RES : LDWORD_T;
  signal M3216_ADD_OVF,M3216_OVF : std_logic;
  signal CTRL_q : MUL_CTRL;

begin

  ------------------------------------
  -- Notes
  ------------------------------------
  -- 1) The scalar multiply unit employs a two-stage pipeline:
  -- instructions mul, lmul and mula execute in one cycle, while 
  -- lmac, lmsu, mulr and m3216 one executes in two cycles.
  -- Result and overflow flag from single-cycle instructions are
  -- available at the end of first stage for forwarding.

  ------------------------------------
  -- 16x16 multipliers
  ------------------------------------

  PROD1 <= OPA_i(SDLEN-1 downto 0) * OPB_i(SDLEN-1 downto 0);

  PROD2 <= OPA_i(LDLEN-1 downto SDLEN) * OPB_i(SDLEN-1 downto 0);

  ------------------------------------
  -- mula
  ------------------------------------

  -- mul-address, is a normal 16x16 multiplication, used
  -- for address arithmetic.

  MULA_RES(SDLEN-1 downto 0) <= PROD1(SDLEN-1 downto 0);
  MULA_RES(LDLEN-1 downto SDLEN) <= (others => '0');

  -- pipe register
  process(CLK_i)
  begin
    if(CLK_i = '1' and CLK_i'event) then
      MULA_RES_q <= MULA_RES;
    end if;
  end process;

--  ------------------------------------
--  -- L_mac() & L_msu()
--  ------------------------------------
--
--  -- L_mac(L_var3,var1,var2)
--  -- L_produit = L_mult(var1,var2);
--  -- L_var_out = L_add(L_var3,L_produit);
--  --
--  -- L_mult(var1,var2)
--  -- L_var_out = (WORD_T32)var1 * (WORD_T32)var2;
--  -- if (L_var_out != (WORD_T32)0x40000000L)
--  --   L_var_out *= 2;
--  -- else{
--  --   Overflow = 1;
--  --   L_var_out = MAX_32;
--  -- }
--  --
--  -- L_add(L_var1,L_var2)
--  -- L_var_out = L_var1 + L_var2;
--  -- if (((L_var1 ^ L_var2) & MIN_32) == 0)
--  --   if ((L_var_out ^ L_var1) & MIN_32){
--  --     L_var_out = (L_var1 < 0) ? MIN_32 : MAX_32;
--  --     Overflow = 1;
--  --   }
--
--  -- lmac/lmsu result is selected from three different sources:
--  -- 1) multiplication actual result plus accumulator content, when
--  -- nor multiplication and neither addition result in overflow.
--  -- 2) multiplication overflow result (either MAX32 or -MAX32) plus
--  -- accumulator content, when multiplication results in overflow but
--  -- addition doesn't. 
--  -- 3) addition overflow result, when addition results in overflow
--  -- (multiplication result is do-not-care in this case).
--
--  -- Source #1
--
--  -- subtract/add selector
--  MAC_SA <= '1' when CTRL_i = MC_LMSU else '0';
--
--  -- Multiplication overflow flag
--  MAC_MUL_OVF <= '1' when PROD1 = MUL_OVFVAL else '0';
--
--  -- shift PROD left by 1 bit, and negate result if operation
--  -- is of MSU type.
--
--  MAC_PROD1 <= shift_left(PROD1,1) when MAC_SA = '0' else 
--    not(shift_left(PROD1,1));
--
--  -- pipe register
--  process(CLK_i)
--  begin
--    if(CLK_i = '1' and CLK_i'event) then
--      MAC_PROD1_q <= MAC_PROD1;
--      MAC_MUL_OVF_q <= MAC_MUL_OVF;
--      MAC_SA_q <= MAC_SA;
--    end if;
--  end process;
--
--  -- MAC_SUM1 is MAC/MSU result assuming overflow occurs nor in
--  -- multiplication and neither in addition/subtraction.
--
--  U_ADD1 : G729A_ASIP_ADDER -- _F
--    generic map(
--      --LEN1 => SDLEN,
--      --LEN2 => SDLEN
--      WIDTH => LDLEN
--    )
--    port map(
--      OPA_i => ACC_i,
--      OPB_i => MAC_PROD1_q,
--      CI_i => MAC_SA_q,
--      SUM_o => MAC_SUM1
--    );
--
--  -- Addition #1 overflow flag
--  MAC_ADD_OVF1 <= overflow(
--    MAC_SA_q,
--    ACC_i(LDLEN-1),
--    MAC_PROD1_q(LDLEN-1),
--    MAC_SUM1(LDLEN-1)
--  );
--
--  -- Source #2
--
--  -- MAC_PROD2 is multiplication result assuming this operation
--  -- results in overflow (MAX_32 for lmac* and -MAX_32 for lmsu*,
--  -- latter value being generated negating MAX_32 and then add 1 
--  -- in addition to accumulator).
--
--  MAC_PROD2 <= MAX_32 when MAC_SA_q = '0' else not(MAX_32);
--
--  -- MAC_SUM2 is MAC/MSU result when overflow occurs in multiplication, but
--  -- not in addition/subtraction
--
--  U_ADD2 : G729A_ASIP_ADDER
--    generic map(
--      WIDTH => LDLEN
--    )
--    port map(
--      OPA_i => ACC_i,
--      OPB_i => MAC_PROD2,
--      CI_i => MAC_SA_q,
--      SUM_o => MAC_SUM2
--    );
--
--  -- Addition #2 overflow flag
--  MAC_ADD_OVF2 <= overflow(
--    MAC_SA_q,
--    ACC_i(LDLEN-1),
--    MAC_PROD2(LDLEN-1),
--    MAC_SUM2(LDLEN-1)
--  );
--
--  -- Final MAC/MSU overflow flag
--  MAC_OVF <= MAC_MUL_OVF_q or MAC_ADD_OVF1;
--
--  -- Select lmac*/lmsu* result
--  -- (coded to minimize MAC_SUM1 path delay)
--
--  process(MAC_OVF,MAC_MUL_OVF_q,ACC_i,MAC_SUM1,MAC_SUM2,MAC_ADD_OVF2)
--  begin
--    if(MAC_OVF = '0') then
--      -- no overflow
--      MAC_RES <= MAC_SUM1;
--    elsif(MAC_MUL_OVF_q = '1' and MAC_ADD_OVF2 = '0') then
--      -- overflow in multiplication, but not in addition
--      MAC_RES <= MAC_SUM2;
--    elsif(ACC_i(LDLEN-1) = '0') then
--      -- positive overflow in addition
--      MAC_RES <= MAX_32;   
--    else
--      -- negative overflow in addition
--      MAC_RES <= MIN_32;   
--    end if;
--  end process;

  ------------------------------------
  -- L_mult()
  ------------------------------------

  -- pipe register
  process(CLK_i)
  begin
    if(CLK_i = '1' and CLK_i'event) then
      LMUL_PROD_q <= PROD1;
    end if;
  end process;

  process(LMUL_PROD_q)
    variable IRES : LDWORD_T;
    variable IOVF : std_logic;
  begin
    L_mult(LMUL_PROD_q,IRES,IOVF);
    LMUL_RES <= IRES;
    LMUL_OVF <= IOVF;
  end process;
  
  ------------------------------------
  -- mult_r()
  ------------------------------------

  -- mult_r() is performed in two cycles:
  -- cycle #1: a standard mult() is executed, its result being
  -- stored in a pipe register
  -- cycle #2: pipe register content is added 0x00004000 and
  -- result is saturated.

  -- pipe register
  process(CLK_i)
  begin
    if(CLK_i = '1' and CLK_i'event) then
      MULR_PROD_q <= PROD1;
    end if;
  end process;

  MULR_SUM1 <= MULR_PROD_q + hex_to_signed("00004000",LDLEN); 

  MULR_SUM2 <= shift_right(MULR_SUM1,SDLEN-1);

  process(MULR_SUM2)
    variable IRES : SDWORD_T;
    variable IOVF : std_logic;
  begin
    sature(MULR_SUM2,IRES,IOVF);
    MULR_RES(SDLEN-1 downto 0) <= IRES;
    MULR_RES(LDLEN-1 downto SDLEN) <= (others => '0');
    MULR_OVF <= IOVF;
  end process;
  
  ------------------------------------
  -- Mpy_32_16()
  ------------------------------------

  -- Mpy_32_16() is performed in two cycles:
  -- cycle #1: L_mult(hi,n) and L_mult(mult(lo,n),1) are
  -- calculated in parallel, their results being stored in
  -- pipe registers.
  -- cycle #2: pipe registers are long-added.

  process(PROD2)
    variable IRES : LDWORD_T;
    variable IOVF : std_logic;
  begin
    L_mult(PROD2,IRES,IOVF);
    M3216_PRODHI <= IRES;
    M3216_MUL_OVFHI <= IOVF;
  end process;

  process(PROD1)
    variable IRES : SDWORD_T;
    variable IOVF : std_logic;
  begin
    mult(PROD1,IRES,IOVF);
    M3216_PRODLO1 <= IRES;
    M3216_MUL_OVFLO <= IOVF;
  end process;

  -- L_mult(mult(lo,n),1) : shift PROD_LO left by 1 bit,
  -- and sign-extend result to LDLEN bits.

  M3216_PRODLO2(0) <= '0';
  M3216_PRODLO2(SDLEN downto 1) <= M3216_PRODLO1(SDLEN-1 downto 0);
  M3216_PRODLO2(LDLEN-1 downto SDLEN+1) <= (others => M3216_PRODLO1(SDLEN-1));

  -- pipe registers
  process(CLK_i)
  begin
    if(CLK_i = '1' and CLK_i'event) then
      M3216_PRODLO_q <= M3216_PRODLO2;
      M3216_PRODHI_q <= M3216_PRODHI;
      M3216_MUL_OVF_q <= (M3216_MUL_OVFHI or M3216_MUL_OVFLO);
    end if;
  end process;

  M3216_SUM <= (M3216_PRODHI_q + M3216_PRODLO_q);

  process(M3216_SUM,M3216_PRODLO_q,M3216_PRODHI_q)
    variable IRES : LDWORD_T;
    variable IOVF : std_logic;
  begin
    L_add_sub(
      M3216_SUM,
      '1',
      M3216_PRODLO_q(LDLEN-1),
      M3216_PRODHI_q(LDLEN-1),
      IRES,    
      IOVF
    );
    M3216_RES <= IRES;  
    M3216_ADD_OVF <= IOVF;
  end process;

  -- Final Mpy_32_16 overflow flag
  M3216_OVF <= (M3216_ADD_OVF or M3216_MUL_OVF_q);

  ------------------------------------
  -- Result mux
  ------------------------------------

  -- pipe register
  process(CLK_i)
  begin
    if(CLK_i = '1' and CLK_i'event) then
      CTRL_q <= CTRL_i;
    end if;
  end process;

  --process(CTRL_q,MAC_RES_q,MAC_OVF_q,MULR_RES,MULR_OVF,LMUL_RES,LMUL_OVF,
  --  M3216_RES,M3216_OVF)
  process(CTRL_q,MULA_RES_q,MULR_RES,MULR_OVF,LMUL_RES,LMUL_OVF,
    M3216_RES,M3216_OVF)
  begin
    case CTRL_q is
      when MC_MULA =>
        RES_o <= MULA_RES_q;
        OVF_o <= '0';
      --when MC_LMAC|MC_LMSU =>
      --  RES_o <= MAC_RES;
      --  OVF_o <= MAC_OVF;
      when MC_MULR =>
        RES_o <= MULR_RES;
        OVF_o <= MULR_OVF;
      when MC_LMUL =>
        RES_o <= LMUL_RES;
        OVF_o <= LMUL_OVF;
      when others => -- MC_M3216 =>
        RES_o <= M3216_RES;
        OVF_o <= M3216_OVF;
    end case;
  end process;

end ARC;
