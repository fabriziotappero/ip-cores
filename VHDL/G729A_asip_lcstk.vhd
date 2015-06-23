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
-- G.729a ASIP loop control stack
---------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library WORK;
use WORK.G729A_ASIP_PKG.all;

entity G729A_ASIP_LCSTK is
  generic(
    DEPTH : natural
  );
  port(
    CLK_i : in std_logic;
    RST_i : in std_logic;
    SRST_i : in std_logic;
    PUSH_i : in std_logic;
    POP_i : in std_logic;
    DECR_i : in std_logic;
    LBADR_i : in unsigned(ALEN-1 downto 0); -- loop begin address
    LEADR_i : in unsigned(ALEN-1 downto 0); -- loop end address
    LCNT_i : in unsigned(16-1 downto 0); -- loop count

    SE_o : out std_logic;
    SF_o : out std_logic;
    LBADR_o : out unsigned(ALEN-1 downto 0); -- loop begin address
    LEADR_o : out unsigned(ALEN-1 downto 0); -- loop end address
    LCNT_o : out unsigned(16-1 downto 0) -- loop count
  );
end G729A_ASIP_LCSTK;

architecture ARC of G729A_ASIP_LCSTK is

  type STK_ENTRY_T is record
    LBADR : unsigned(ALEN-1 downto 0);
    LEADR : unsigned(ALEN-1 downto 0);
    LCNT : unsigned(16-1 downto 0);
  end record;

  type LPSTK_T is array (DEPTH-1 downto 0) of STK_ENTRY_T;
  signal LPSTK_q : LPSTK_T;
  signal TOS_q : integer range 0 to DEPTH;
  signal TOSM1_q : integer range 0 to DEPTH;
  signal SE,SF : std_logic;

begin

  -- TOS register (points to bottommost empty entry)
  process(CLK_i)
  begin
    if(CLK_i = '1' and CLK_i'event) then
      if(RST_i = '1' or SRST_i = '1') then
        TOS_q <= 0;
      elsif(POP_i = '1' and SE = '0') then
        TOS_q <= TOS_q - 1;
      elsif(PUSH_i = '1' and SF = '0') then
        TOS_q <= TOS_q + 1;
      end if;
    end if;
  end process;

  -- TOS-1 register
  process(CLK_i)
  begin
    if(CLK_i = '1' and CLK_i'event) then
      if(RST_i = '1' or SRST_i = '1' or (POP_i = '1' and TOS_q  < 2)) then
        TOSM1_q <= 0;
      elsif(POP_i = '1' and SE = '0') then
        TOSM1_q <= TOS_q - 2;
      elsif(PUSH_i = '1' and SF = '0') then
        TOSM1_q <= TOS_q;
      end if;
    end if;
  end process;

  -- Stack Empty flag
  SE <= '1' when TOS_q = 0 else '0';

  -- Stack Full flag
  SF <= '1' when TOS_q = DEPTH else '0';

  -- Stack data registers

  process(CLK_i)
    variable TMP : STK_ENTRY_T;
  begin
    if(CLK_i = '1' and CLK_i'event) then
      if(PUSH_i = '1') then
        LPSTK_q(TOS_q) <= (LBADR_i,LEADR_i,LCNT_i);
      elsif(DECR_i = '1') then
        TMP := LPSTK_q(TOSM1_q);
        LPSTK_q(TOSM1_q) <= (TMP.LBADR,TMP.LEADR,(TMP.LCNT - 1)); 
      end if;      
    end if;
  end process;

  -- Outputs

  process(LPSTK_q,TOSM1_q)
  begin
    LBADR_o <= LPSTK_q(TOSM1_q).LBADR;
    LEADR_o <= LPSTK_q(TOSM1_q).LEADR;
    LCNT_o <= LPSTK_q(TOSM1_q).LCNT;
  end process;

  SE_o <= SE;

  SF_o <= SF;

end ARC;
