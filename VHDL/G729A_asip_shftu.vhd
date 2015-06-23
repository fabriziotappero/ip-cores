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
-- G.729A ASIP shift unit
---------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all; 
use IEEE.numeric_std.all;

library WORK;
use WORK.G729A_ASIP_PKG.all;
use WORK.G729A_ASIP_BASIC_PKG.all;
use WORK.G729A_ASIP_ARITH_PKG.all;

entity G729A_ASIP_SHFT is
  port(
    SI_i : in LDWORD_T;
    SHFT_i : in SDWORD_T;
    --STRT_i : in std_logic;
    CTRL_i : in SHF_CTRL;

    SO_o : out LDWORD_T;
    OVF_o : out std_logic
  );
end G729A_ASIP_SHFT;

architecture ARC of G729A_ASIP_SHFT is

  constant ALL_ZERO_16 : SDWORD_T := (others => '0');
  constant ALL_ZERO_32 : LDWORD_T := (others => '0');

  signal LSO_S,RSO_S : SDWORD_T;
  signal LSO_L,RSO_L : LDWORD_T;
  signal NRMSO : SHORT_SHIFT_T;
  signal NRMLO : LONG_SHIFT_T;
  signal ISHFT : LONG_SHIFT_T;
  signal ISHFT_OVF : LONG_SHIFT_OVF_T;
  signal ICTRL : SHF_CTRL;
  signal SHFT : LONG_SHIFT_OVF_T;

begin

  -- (lower WORD_T) normalization shift amount
  NRMSO <= norm_s(SI_i(SDLEN-1 downto 0));

  -- normalization shift amount
  NRMLO <= norm_l(SI_i);

  SHFT <=
    LDLEN when (SHFT_i >= LDLEN) else
    -LDLEN when (SHFT_i <= -LDLEN) else
    to_integer(SHFT_i(6-1 downto 0));

  -- If shift amount is negative, reverse shift direction 
  -- (and make shift amount positive)
  process(SHFT_i,CTRL_i)
  begin    
    if(SHFT_i < 0) then
      case (CTRL_i) is
        when SC_SHL => ICTRL <= SC_SHR;
        when SC_SHR => ICTRL <= SC_SHL;
        when SC_LSHL => ICTRL <= SC_LSHR;
        when SC_LSHR => ICTRL <= SC_LSHL;
        when others => ICTRL <= CTRL_i;
      end case;
    else
      ICTRL <= CTRL_i;
    end if;
  end process;

  -- check against -32 is needed to avoid invalid shift amount of 32

  --ISHFT <= 0 when (SHFT = -32 or SHFT = 32) else -SHFT when (SHFT_i < 0) else SHFT;

  process(SHFT_i)
    variable TMP : SDWORD_T;
  begin
    if(SHFT_i < 0) then
      TMP := -SHFT_i;
    else
      TMP := SHFT_i;
    end if;
    ISHFT <= to_integer(to_unsigned(TMP(5-1 downto 0))); 
  end process;

  ISHFT_OVF <= -SHFT when (SHFT_i < 0) else SHFT;

  -- 16-bit left shifter
  LSO_S <= shift_left16(SI_i(SDLEN-1 downto 0),ISHFT);
  
  -- 16-bit right shifter
  RSO_S <= shift_right16(SI_i(SDLEN-1 downto 0),ISHFT);

  -- 32-bit left shifter
  LSO_L <= shift_left32(SI_i,ISHFT);
  
  -- 32-bit right shifter
  RSO_L <= shift_right32(SI_i,ISHFT);

  process(ICTRL,SI_i,ISHFT,ISHFT_OVF,LSO_S,RSO_S,LSO_L,RSO_L,NRMSO,NRMLO)
    variable ISO : LDWORD_T;
    variable INRMO : LONG_SHIFT_T;
    variable IOVF : std_logic;
  begin
    case ICTRL is

      when SC_SHL =>
        -- ISO high portion is set to all-0
        ISO(LDLEN-1 downto SDLEN) := (others => '0');
        -- check for overflow
        --if((NRMSO < ISHFT) or ((ISHFT > SDLEN-1) and 
        --  (SI_i(SDLEN-1 downto 0) /= ALL_ZERO_16))
        if((NRMSO < ISHFT) and (SI_i(SDLEN-1 downto 0) /= ALL_ZERO_16)) then
          -- overflow
          IOVF := '1';  
          --if(SI_i(SDLEN-1 downto 0) < 0) then
          if(SI_i(SDLEN-1) = '1') then
            ISO(SDLEN-1 downto 0) := MIN_16;
          else
            ISO(SDLEN-1 downto 0) := MAX_16;
          end if;
        else
          -- regular result
          IOVF := '0';
          ISO(SDLEN-1 downto 0) := LSO_S; --(SDLEN-1 downto 0);
        end if;

      when SC_SHR =>
        -- ISO high portion is set to all-0
        ISO(LDLEN-1 downto SDLEN) := (others => '0');
        -- overflow flag is unchanged 
        IOVF := '0';
        -- check for underflow
        if(ISHFT_OVF >= SDLEN-1) then
          -- underflow
          --if(SI_i(SDLEN-1 downto 0) < 0) then
          if(SI_i(SDLEN-1) = '1') then
            ISO(SDLEN-1 downto 0) := to_signed(-1,SDLEN);
          else
            ISO(SDLEN-1 downto 0) := to_signed(0,SDLEN);
          end if;
        else
          -- regular result
          ISO(SDLEN-1 downto 0) := RSO_S; --(SDLEN-1 downto 0);
        end if;

      when SC_LSHL =>
        -- check for overflow
        if(NRMLO < ISHFT and SI_i /= ALL_ZERO_32) then
          -- overflow
          IOVF := '1';  
          --if(SI_i < 0) then
          if(SI_i(LDLEN-1) = '1') then
            ISO := MIN_32;
          else
            ISO := MAX_32;
          end if;
        else
          -- regular result
          IOVF := '0';
          ISO := LSO_L;
        end if;

      when SC_LSHR =>
        -- overflow flag is unchanged 
        IOVF := '0';
        -- check for underflow
        if(ISHFT_OVF >= LDLEN-1) then
          -- underflow
          --if(SI_i < 0) then
          if(SI_i(LDLEN-1) = '1') then
            ISO := to_signed(-1,LDLEN);
          else
            ISO := to_signed(0,LDLEN);
          end if;
        else
          -- regular result
          ISO := RSO_L;
        end if;

      when SC_NRMS =>
        ISO := to_signed(NRMSO,LDLEN);
        IOVF := '0';

      when SC_NRML =>
        ISO := to_signed(NRMLO,LDLEN);
        IOVF := '0';

      when others => -- SC_NIL
        ISO := SI_i;
        IOVF := '0';

    end case;

    SO_o <= ISO;
    OVF_o <= IOVF;

  end process;
  
end ARC;
