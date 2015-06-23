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
-- G.729a ASIP Instruction Fecthing Logic
---------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.G729A_ASIP_PKG.all;
use work.G729A_ASIP_CFG_PKG.all;

entity G729A_ASIP_FTCHLOG_2W is
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
end G729A_ASIP_FTCHLOG_2W;

architecture ARC of G729A_ASIP_FTCHLOG_2W is

  component G729A_ASIP_ADDERU is
    generic(
      WIDTH : integer := 16
    );
    port(
      OPA_i : in unsigned(WIDTH-1 downto 0);
      OPB_i : in unsigned(WIDTH-1 downto 0);
      CI_i : in std_logic;

      SUM_o : out unsigned(WIDTH-1 downto 0)
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

  signal SZERO : unsigned(ALEN-1 downto 0) := (others => '0');
  signal ONE : std_logic := '1';
  signal PC,PC_q : unsigned(ALEN-2 downto 0);
  signal PC_NS : unsigned(ALEN-2 downto 0);
  signal PCP1,PCP1_q : unsigned(ALEN-2 downto 0);
  signal HALT_q : std_logic;
  signal EVEN_PC : std_logic;
  signal EVEN_PC_NS : std_logic;

begin

  -- Halt flag register
  process(CLK_i)
  begin
    if(CLK_i = '1' and CLK_i'event) then
      if(RST_i = '1' or HALT_i = '1') then
        HALT_q <= '1';
      elsif(STRT_i = '1') then
        HALT_q <= '0';
      end if;
    end if;
  end process;

  BSY_o <= not(HALT_q);

  -- Fetched instruction #0 is always valid, unless processor is
  -- halted or fetch address is odd.

  IFV_o(0) <= (not(HALT_q) or STRT_i) and EVEN_PC;

  -- Fetched instruction #1 is always valid, unless processor is
  -- halted.

  IFV_o(1) <= (not(HALT_q) or STRT_i);

  -- Program Counter register
  process(CLK_i)
  begin
    if(CLK_i = '1' and CLK_i'event) then
      if(RST_i = '1') then
        PC_q <= (others => '0');
        PCP1_q <= (1 => '1',others => '0');
      elsif(PC_q < ((IMEM_SIZE/2)-2) or STRT_i = '1') then
        PC_q <= PC;
        PCP1_q <= PCP1;
      end if;
    end if;
  end process;

  PCP1 <= PC_NS + 1 when (PSTALL_i = '0') else PCP1_q;

  -- Note: a branch/jump in IX stage is older than a loop closing
  -- instruction in IF stage and therefore takes priority over it.

  -- PC is a double word address, and therefore is one bit shorter
  -- than actual fetch addresses.

  process(STRT_i,BJX_i,BJTA_i,LBX_i,SADR_i,LBTA_i,PCP1_q)
  begin
    if(BJX_i = '1') then -- and PSTALL_i = '0') then
      PC_NS <= BJTA_i(ALEN-1 downto 1);
      EVEN_PC_NS <= not(BJTA_i(0));
    elsif(LBX_i = '1') then --  and PSTALL_i = '0') then
      PC_NS <= LBTA_i(ALEN-1 downto 1);
      EVEN_PC_NS <= not(LBTA_i(0));
    elsif(STRT_i = '1') then
      PC_NS <= SADR_i(ALEN-1 downto 1);
      EVEN_PC_NS <= not(SADR_i(0));
    else
      PC_NS <= PCP1_q;
      EVEN_PC_NS <= '1';
    end if;
  end process;

  PC <= PC_NS when (PSTALL_i = '0') else PC_q;
  EVEN_PC <= EVEN_PC_NS when (PSTALL_i = '0') else '1';

  -- Fetch addresses

  -- instruction #0 address is always an even address, while
  -- instruction #1 address is always an odd one.

  IADR0_o <= PC & '0';
  IADR1_o <= PC & '1';

end ARC;
