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
-- Instruction Fetching Queue
---------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all; 
use IEEE.numeric_std.all;

library WORK;
use WORK.G729A_ASIP_PKG.all;
use WORK.G729A_ASIP_BASIC_PKG.all;
use WORK.G729A_ASIP_ARITH_PKG.all;
use work.G729A_ASIP_IDEC_2W_PKG.all;

entity G729A_ASIP_IFQ is
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
end G729A_ASIP_IFQ;

architecture ARC of G729A_ASIP_IFQ is

  constant IFQ_DEPTH : natural := 3;

  type IFQ_ENTRY_T is record
    DINSTR : DEC_INSTR_T;
    INSTR : std_logic_vector(ILEN-1 downto 0);
    PC : unsigned(ALEN-1 downto 0);
    IMM : std_logic;
    OPB : LDWORD_T;
  end record;

  type IFQ_T is array (natural range<>) of IFQ_ENTRY_T;

  signal IFQ_NEW_1,IFQ_NEW_0 : IFQ_ENTRY_T;
  signal IFQ,IFQ_q : IFQ_T(IFQ_DEPTH-1 downto 0);
  signal IFQV,IFQV_q : std_logic_vector(IFQ_DEPTH-1 downto 0);
  signal STALL,UPDT : std_logic;

begin

  ----------------------------------------------------
  -- Notes:
  -- The queue consists of 3 entries, entry #0 being the
  -- oldest entry and entry #2 being the newest one.
  -- Entries #0,1 act as pipeline registers between
  -- stages IF and ID (so that entries #0,1 are the
  -- currently decoded instructions).
  ----------------------------------------------------

  ----------------------------------------------------
  -- Fetch must stall if the number of empty queue
  -- entrie, plus the number of issued instructions
  -- is lower than two. 
  --
  -- Let's put this condition in truth table format:
  --
  -- 210 issue stall
  -- ---------------
  -- 000    00     0
  -- 001    00     0
  -- 001    01     0
  -- 01x    00     1
  -- 01x    01     0
  -- 01x    11     0
  -- 1xx    00     1
  -- 1xx    01     1
  -- 1xx    11     0 
  ----------------------------------------------------

  -- fetch stall flag

  --STALL <= '1' when (
  --  (IFQV_q(1) = '1' and ID_ISSUE_i = "00") or -- 2 instr. in queue and 0 issue
  --  (IFQV_q(2) = '1' and ID_ISSUE_i = "00") or -- 3 instr. in queue and 0 issue
  --  (IFQV_q(2) = '1' and ID_ISSUE_i = "01")    -- 3 instr. in queue and 1 issue
  --) else '0';

  -- ...re-coded to optimize timing

  STALL <= IFQV_q(2) when (ID_ISSUE_i = "01") else
    (IFQV_q(2) or IFQV_q(1)) when (ID_ISSUE_i = "00") else '0';

  ----------------------------------------------------
  -- Fetch queue data update
  -- 
  -- old       new
  -- 210 issue 210    keep entry
  -- ------------------------
  -- 000    ** 0nn B (keep -)
  -- 001    00 nno A (keep 0)
  -- 001    *1 0nn B (keep -)
  -- 01x    00 ooo - (stall)
  -- 01x    01 nno A (keep 1)
  -- 01x    11 0nn B (keep -)
  -- 1xx    00 ooo - (stall)
  -- 1xx    01 0oo C (stall) <- (*)
  -- 1xx    11 nno A (keep 2)
  --
  -- n = new instruction
  -- o = old instruction
  -- 0 = garbage

  -- (*) this is special case: fetch must be stalled because
  -- there's no room for a new instruction pair in the queue,
  -- but queue data must be updated, because one instruction
  -- is issued.

  ----------------------------------------------------

  -- queue update flag

  UPDT <= '0' when (
    (IFQV_q(1) = '1' and ID_ISSUE_i = "00") or -- 2 instr. in queue and 0 issue
    (IFQV_q(2) = '1' and ID_ISSUE_i = "00") -- 3 instr. in queue and 0 issue
  ) else '1';

  IFQ_NEW_0 <= (
    IF_DEC_INSTR0_i,
    IF_INSTR0_i,
    IF_PC0_i,
    IF_IMM0_i,
    IF_OPB0_i
  );

  IFQ_NEW_1 <= (
    IF_DEC_INSTR1_i,
    IF_INSTR1_i,
    IF_PC1_i,
    IF_IMM1_i,
    IF_OPB1_i
  );

  -- fetch queue data update logic
  process(IFQV_q,IFQ_q,IF_V_i,ID_ISSUE_i,IFQ_NEW_1,IFQ_NEW_0)
    variable KEEP : natural range 2 downto 0;
  begin
    case ID_ISSUE_i is
      when "00" => KEEP := 0;
      when "01" => KEEP := 1;
      when others => KEEP := 2;
    end case;
    if(
      (IFQV_q(2 downto 0) = "001" and ID_ISSUE_i = "00") or
      (IFQV_q(2 downto 1) = "01" and ID_ISSUE_i = "01") or
      (IFQV_q(2) = '1' and ID_ISSUE_i = "11")
    ) then
      -- "A" case (1 old instr. in queue)
      IFQV <= IF_V_i & IFQV_q(KEEP);
      IFQ <= (IFQ_NEW_1,IFQ_NEW_0,IFQ_q(KEEP)); 
    elsif(
      (IFQV_q(2 downto 0) = "000") or
      (IFQV_q(2 downto 0) = "001" and ID_ISSUE_i(0) = '1') or
      (IFQV_q(2 downto 1) = "01" and ID_ISSUE_i = "11")
    ) then
      -- "B" case (no old instr. in queue)
      IFQV <= '0' & IF_V_i; 
      IFQ <= (IFQ_q(2),IFQ_NEW_1,IFQ_NEW_0); 
    else -- if(IFQV_q(2) = '1' and ID_ISSUE_i = "01")
      -- "C" case (2 old instr. in queue)
      IFQV <= '0' & IFQV_q(2 downto 1); 
      IFQ <= (IFQ_q(2),IFQ_q(2),IFQ_q(1)); 
    end if;
  end process;

  -- fetch queue data registers
  process(CLK_i)
  begin
    if(CLK_i = '1' and CLK_i'event) then

      if(RST_i = '1' or IX_BJX_i = '1') then
        IFQV_q <= (others => '0');
      elsif(UPDT = '1' and ID_HALT_i = '0') then
        IFQV_q <= IFQV;
      elsif(ID_HALT_i = '1') then
        IFQV_q <= (others => '0');
      end if;

      if(UPDT = '1') then
        IFQ_q <= IFQ;
      end if;

    end if;
  end process;

  ----------------------------------------------------
  -- outputs
  ----------------------------------------------------

  PSTALL_o <= STALL;

  ID_V_o <= IFQV_q(1 downto 0);
  ID_PC0_o <= IFQ_q(0).PC;
  ID_PC1_o <= IFQ_q(1).PC;
  ID_INSTR0_o <= IFQ_q(0).INSTR;
  ID_INSTR1_o <= IFQ_q(1).INSTR;
  ID_DEC_INSTR0_o <= IFQ_q(0).DINSTR;
  ID_DEC_INSTR1_o <= IFQ_q(1).DINSTR;
  ID_IMM0_o <= IFQ_q(0).IMM;
  ID_IMM1_o <= IFQ_q(1).IMM;
  ID_OPB0_o <= IFQ_q(0).OPB;
  ID_OPB1_o <= IFQ_q(1).OPB;

end;

