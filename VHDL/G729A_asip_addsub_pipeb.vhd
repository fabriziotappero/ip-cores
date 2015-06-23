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
-- Pipe-B adder/subtractor
---------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all; 
use IEEE.numeric_std.all;

library WORK;
use WORK.G729A_ASIP_PKG.all;
use WORK.G729A_ASIP_BASIC_PKG.all;
use WORK.G729A_ASIP_ARITH_PKG.all;

entity G729A_ASIP_ADDSUB_PIPEB is
  port(
    OPA_i : in LDWORD_T;
    OPB_i : in LDWORD_T;
    CTRL_i : in ADD_CTRL;

    RES_o : out LDWORD_T;
    OVF_o : out std_logic
  );
end G729A_ASIP_ADDSUB_PIPEB;

architecture ARC of G729A_ASIP_ADDSUB_PIPEB is

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

  function EXTS(S : signed; L : natural) return signed is
    variable XS : signed(L-1 downto 0);
  begin
    XS(S'HIGH downto 0) := S;
    XS(L-1 downto S'HIGH+1) := (others => S(S'HIGH));
    return(XS);
  end function;

  signal IOPA,IOPB,SUM : LDWORD_T;
  signal CI : std_logic;

begin

  -- adder operands selection
  process(CTRL_i,OPB_i,OPA_i)
  begin
    case CTRL_i is
      when AC_ABS|AC_NEG =>
        -- tmp = -opa_i
        IOPA <= not(EXTS(OPA_i(SDLEN-1 downto 0),LDLEN));
        IOPB <= (others => '0');
        CI <= '1';
      when AC_LABS|AC_LNEG =>
        -- tmp = -opa_i
        IOPA <= not(OPA_i);
        IOPB <= (others => '0');
        CI <= '1';
      --when AC_ADD =>
      --  -- tmp = opa_i + opb_i
      --  IOPA <= EXTS(OPA_i(SDLEN-1 downto 0),LDLEN);
      --  IOPB <= EXTS(OPB_i(SDLEN-1 downto 0),LDLEN);
      --  CI <= '0';
      when AC_LADD =>
        -- tmp = opa_i + opb_i
        IOPA <= OPA_i;
        IOPB <= OPB_i;
        CI <= '0';
      --when AC_SUB =>
      --  -- tmp = opa_i - opb_i
      --  IOPA <= EXTS(OPA_i(SDLEN-1 downto 0),LDLEN);
      --  IOPB <= not(EXTS(OPB_i(SDLEN-1 downto 0),LDLEN));
      --  CI <= '1';
      when AC_LSUB =>
        -- tmp = opa_i - opb_i
        IOPA <= OPA_i;
        IOPB <= not(OPB_i);
        CI <= '1';
      when AC_LEXT =>
        -- tmp = opa_i - (opa_i(31:16)<<16)
        IOPA <= OPA_i;
        IOPB <= not(OPA_i(LDLEN-1 downto SDLEN) & to_signed(0,SDLEN));
        CI <= '1';
      when others => -- RND
        -- tmp = opa_i + 0x00008000 
        IOPA <= OPA_i;
        IOPB <= (SDLEN-1 => '1',others => '0');
        CI <= '0';
      --when AC_INC =>
      --  -- tmp = opa_i + 1 
      --  IOPA <= EXTS(OPA_i(SDLEN-1 downto 0),LDLEN);
      --  IOPB <= (0 => '1',others => '0');
      --  CI <= '0';
      --when others => -- DEC
      --  -- tmp = opa_i - 1 
      --  IOPA <= EXTS(OPA_i(SDLEN-1 downto 0),LDLEN);
      --  IOPB <= (others => '1');
      --  CI <= '0';
    end case;
  end process;

  -- adder

  U_ADDF : G729A_ASIP_ADDER_F
    generic map(
      LEN1 => SDLEN,
      LEN2 => SDLEN
    )
    port map(
      OPA_i => IOPA,
      OPB_i => IOPB,
      CI_i => CI,
      SUM_o => SUM
    );

  -- result and overflow flag generation
  process(CTRL_i,OPA_i,OPB_i,SUM)
    variable SA,LSA,LSB,IOVF : std_logic;
    variable IRES,TMP : LDWORD_T;
  begin

    SA := OPA_i(SDLEN-1);
    LSA := OPA_i(LDLEN-1);
    LSB := OPB_i(LDLEN-1);

    case CTRL_i is

      when AC_ABS =>
        -- IRES upper half is set to all-0
        IRES(LDLEN-1 downto SDLEN) := (others => '0');
        -- overflow flag is unchanged
        IOVF := '0';
        -- check if input is min. signed integer
        if(OPA_i(SDLEN-1 downto 0) = MIN_16) then
          IRES(SDLEN-1 downto 0) := MAX_16;
        elsif(SA = '1') then
          IRES(SDLEN-1 downto 0) := SUM(SDLEN-1 downto 0);
        else
          IRES(SDLEN-1 downto 0) := OPA_i(SDLEN-1 downto 0);
        end if;

      --when AC_ADD =>
      --  -- IRES upper half is set to all-0
      --  IRES(LDLEN-1 downto SDLEN) := (others => '0');
      --  sature(SUM,IRES(SDLEN-1 downto 0),IOVF);

      when AC_NEG =>
        -- IRES upper half is set to all-0
        IRES(LDLEN-1 downto SDLEN) := (others => '0');
        if(OPA_i(SDLEN-1 downto 0) = MIN_16) then
          IRES(SDLEN-1 downto 0) := MAX_16;
        else
          IRES(SDLEN-1 downto 0) := SUM(SDLEN-1 downto 0);
        end if;
        IOVF := '0';

      --when AC_SUB =>
      --  -- IRES upper half is set to all-0
      --  IRES(LDLEN-1 downto SDLEN) := (others => '0');
      --  sature(SUM,IRES(SDLEN-1 downto 0),IOVF);

      when AC_LABS =>
        if(OPB_i = MIN_32) then
          IRES := MAX_32;
        elsif(LSA = '1') then
          IRES := SUM;
        else
          IRES := OPA_i;
        end if;
        IOVF := '0';

      when AC_LADD =>
        L_add_sub(SUM,'1',LSA,LSB,IRES,IOVF);

      when AC_LSUB =>
        L_add_sub(SUM,'0',LSA,LSB,IRES,IOVF);

      when AC_LNEG =>
        if(OPA_i = MIN_32) then
          IRES := MAX_32;
        else
          IRES := SUM;
        end if;
        IOVF := '0';

      when AC_LEXT =>
        IRES(LDLEN-1 downto SDLEN) := OPA_i(LDLEN-1 downto SDLEN);
        IRES(SDLEN-1 downto 0) := SUM(SDLEN downto 1);
        IOVF := '0';

      when others => -- AC_RND
        L_add_sub(SUM,'1',LSA,'0',TMP,IOVF);
        IRES(LDLEN-1 downto SDLEN) := (others => '0'); --TMP(LDLEN-1));
        IRES(SDLEN-1 downto 0) := TMP(LDLEN-1 downto SDLEN);

      --when others => -- AC_NIL
      --  IRES := SUM;
      --  IOVF := '0';

    end case;

    RES_o <= IRES;
    OVF_o <= IOVF;

  end process;

end ARC;
