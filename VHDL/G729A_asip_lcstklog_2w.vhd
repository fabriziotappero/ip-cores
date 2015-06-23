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
-- G.729a ASIP loop control stack management logic
---------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library WORK;
use WORK.G729A_ASIP_PKG.all;

entity G729A_ASIP_LCSTKLOG_2W is
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
    IMM_i : in unsigned(ALEN-1 downto 0); -- loop begin address
    PCF0_i : in unsigned(ALEN-1 downto 0); -- IF program counter
    PCF1_i : in unsigned(ALEN-1 downto 0); -- IF program counter
    PCX0_i : in unsigned(ALEN-1 downto 0); -- IX program counter
    PCX1_i : in unsigned(ALEN-1 downto 0); -- IX program counter
    IXV_i : in std_logic_vector(2-1 downto 0);

    KLL1_o : out std_logic;
    LEND_o : out std_logic;
    LEIS_o : out std_logic;
    LBX_o : out std_logic; -- loop-back jump eXecute flag
    LBTA_o : out unsigned(16-1 downto 0) -- loop-back target address
  );
end G729A_ASIP_LCSTKLOG_2W;

architecture ARC of G729A_ASIP_LCSTKLOG_2W is

  component G729A_ASIP_LCSTK is
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
  end component;

  type STK_ENTRY_T is record
    LBADR : unsigned(ALEN-1 downto 0);
    LEADR : unsigned(ALEN-1 downto 0);
    LCNT : unsigned(16-1 downto 0);
  end record;

  signal PUSH,POP,DECR,SE,SF : std_logic;
  signal LLBRX,LLERX : std_logic;
  signal STK_LBADR : unsigned(ALEN-1 downto 0);
  signal STK_LEADR : unsigned(ALEN-1 downto 0);
  signal STK_LCNT : unsigned(16-1 downto 0);
  signal LBADR_q : unsigned(ALEN-1 downto 0);
  signal LEADR_q : unsigned(ALEN-1 downto 0);
  signal LCNT : unsigned(16-1 downto 0);
  signal PCF_MTCH,PCX_MTCH : std_logic;

begin

  -- The loop control stack is composed of DEPTH entries, each
  -- one consisting of 3 fields:
  -- 1) loop begin address (specified by llbri instruction)
  -- 2) loop end address (specified by lleri instruction)
  -- 3) loop iterations count (specified by llcnt/llcnti instruction)

  -- When a llbri/lleri instruction is executed, the related operand
  -- is saved into a temporary register.
  -- When a llcnt/llcnti instruction is executed, the related operand
  -- plus the saved operands of most recent llbri and lleri instructions
  -- are pushed on the stack.
  -- Note: instruction execution is used to trigger saving/pushing, 
  -- rather than fetching, to avoid issues with instructions laying
  -- in the 'shadow' of a branch/jump.

  U_STK : G729A_ASIP_LCSTK
    generic map(
      DEPTH => 2 --DEPTH
    )
    port map(
      CLK_i => CLK_i,
      RST_i => RST_i,
      SRST_i => SRST_i,
      PUSH_i => PUSH,
      POP_i => POP,
      DECR_i => DECR,
      LBADR_i => LBADR_q,
      LEADR_i => LEADR_q,
      LCNT_i => LCNT,
  
      SE_o => SE,
      SF_o => SF,
      LBADR_o => STK_LBADR,
      LEADR_o => STK_LEADR,
      LCNT_o => STK_LCNT
    );

  LCNT <= (IMM_i - 1);

  -- llbri, lleri and llcr* instructions can issued only to pipe #0.
  LLBRX <= (LLBRX_i and IXV_i(0));
  LLERX <= (LLERX_i and IXV_i(0));

  -- IX PC match flag
  PCX_MTCH <= '1' when (
    ((IXV_i(0) = '1') and (PCX0_i = STK_LEADR)) or
    ((IXV_i(1) = '1') and (PCX1_i = STK_LEADR))
  ) else '0';

  -- Stack push flag (stack is pushed whenever a llcnt/llcnti
  -- instruction is executed).

  PUSH <= LLCRX_i;

  -- Stack pop flag (stack is popped whenever loop closing
  -- instruction is executed and loop count is zero). 

  POP <= ((not SE) and PCX_MTCH) when (STK_LCNT = 0) else '0'; 

  -- loop end

  LEND_o <= POP;

  LEIS_o <= '1' when ((IXV_i(1) = '1') and (PCX1_i = STK_LEADR) and (STK_LCNT = 0)) else '0';

  -- Loop count is decremented when loop closing instruction is executed

  DECR <= PCX_MTCH when (STK_LCNT > 0)  else '0'; 

  -- loop begin/end address temporary registers
  process(CLK_i)
  begin
    if(CLK_i = '1' and CLK_i'event) then
      if(LLBRX = '1') then
        LBADR_q <= IMM_i;
      end if;
      if(LLERX = '1') then
        LEADR_q <= IMM_i;
      end if;
    end if;
  end process;

  -- IF PC match flag
  PCF_MTCH <= '1' when ((PCF0_i = STK_LEADR) or (PCF1_i = STK_LEADR)) else '0';

  -- loop-back flag
  LBX_o <= not(SE) when ((PCF_MTCH = '1') and (STK_LCNT > 0)) else '0';

  -- loop-back target address
  LBTA_o <= STK_LBADR;

  -- Kill-instruction-in-slot-#1 flag
  KLL1_o <= '1' when (PCF0_i = STK_LEADR) else '0';

end ARC;