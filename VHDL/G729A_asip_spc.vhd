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
-- G.729a ASIP Sub-Program Controller
---------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.G729A_ASIP_PKG.all;
use work.G729A_CODEC_INTF_PKG.all;

entity G729A_ASIP_SPC is
  generic(
    SIMULATION_ONLY : std_logic := '1'
  );
  port(
    CLK_i : in std_logic;
    RST_i : in std_logic;
    STRT_i : in std_logic;
    OPS_i : in std_logic_vector(3-1 downto 0);
    A_BSY_i : in std_logic;
    D_BSY_i : in std_logic;

    SADR_o : out unsigned(ALEN-1 downto 0);
    A_STRT_o : out std_logic;
    A_DMAE_o : out std_logic;
    A_ADR_o : out unsigned(ALEN-1 downto 0);
    D_STRT_o : out std_logic;
    D_WE_o : out std_logic;
    ASEL_o : out std_logic_vector(3-1 downto 0);
    BLEN_o : out natural range 0 to 2048-1;
    BSY_o : out std_logic;
    STS_o : out std_logic_vector(3-1 downto 0);
    CHKE_o : out std_logic
  );
end G729A_ASIP_SPC;

architecture ARC of G729A_ASIP_SPC is

  -- sub-program starting addresses

  constant INIT_DEC : natural := 2412;
  constant DECOD_LD8A_LOOPINIT : natural := 2971;
  constant DECOD_LD8A_LOOPUPDT : natural := 3001;
  constant DECOD_LD8A_LOOPEND : natural := 3005;
  constant DECOD_LD8A_LOOPBODY : natural := 3015;
  constant MAIN_DEC1 : natural := 3361;
  constant MAIN_DEC3 : natural := 3374;
  constant INIT_COD : natural := 3455;
  constant MAIN_COD1 : natural := 8459;
  constant BIG_LOOP_INIT : natural := 5140;
  constant BIG_LOOP_UPDT : natural := 5146;
  constant BIG_LOOP : natural := 5155;
  constant UPDATE : natural := 5495;
  constant MAIN_COD3 : natural := 8644;
  constant DATA_IN : natural := 7645;
  constant DEC_DATA_IN : natural := 8695;
  constant COD_DATA_OUT : natural := 8663;
  constant DEC_DATA_OUT : natural := 8679;
  constant STATE_IN : natural := 8719;
  constant STATE_OUT : natural := 8743;

  -- operation  I/O type

  constant IO_NONE : std_logic_vector(2-1 downto 0) := "00";
  constant IO_READ : std_logic_vector(2-1 downto 0) := "01";
  constant IO_WRITE : std_logic_vector(2-1 downto 0) := "10";

  constant MAX_IO_COUNT : natural := 2048;

  -- sequencer "instruction" type

  type PROG_T is record
    -- sub-program starting address
    SADR : natural range 0 to 65536-1;
    -- I/O mode selector
    IO_MODE : std_logic_vector(2-1 downto 0);
    -- number of words to transfer when in read/write mode
    IO_COUNT : natural range 0 to MAX_IO_COUNT-1;
    -- I/O address selector
    IO_ASEL : std_logic_vector(3-1 downto 0);
    -- halt when sub-program ends
    HALT : std_logic;
  end record;

  -- sequencer "program" type

  type PROG_SEQ_T is array (integer range <>) of PROG_T;

  -- sequencer "program" list

  -- The following sub-programs are available:
  -- a) "init only" initializes channel state.
  -- b) "restore state" restore channel state from ext. memory.
  -- c) "run decoding only" performs encoding/decoding of a single packet,
  -- and save channel state to ext. memory.
  -- d) "run encoding only" performs encoding/decoding of a single packet,
  -- and save channel state to ext. memory.
  -- e) "run" performs encoding/decoding of a single packet,
  -- and save channel state to ext. memory.
  -- f) "save state" save channel state to ext. memory.
  --
  -- Sub-programs "a" and "b" are mutually exclusive: "a" must
  -- be used before encoding/decoding the first packet of a  
  -- conversation, while "b" must be used on following packets.

  constant MAX_PROG : natural := 40;

  constant PROG_SEQ_q : PROG_SEQ_T(0 to MAX_PROG-1) := (
    --
    -- "init only" sub-program
    --
    (INIT_DEC,IO_NONE,0,"000",'0'),
    (INIT_COD,IO_NONE,0,"000",'1'),
    --
    -- "restore state" sub-program
    --
    (STATE_IN,IO_WRITE,1679,"100",'1'), -- write-in channel state
    --
    -- "run decoding-only" sub-program
    --
    (DEC_DATA_IN,IO_WRITE,5,"010",'0'), -- write-in encoded frame
    (MAIN_DEC1,IO_NONE,0,"000",'0'),
    (DECOD_LD8A_LOOPINIT,IO_NONE,0,"000",'0'),
    (DECOD_LD8A_LOOPBODY,IO_NONE,0,"000",'0'),
    (DECOD_LD8A_LOOPUPDT,IO_NONE,0,"000",'0'),
    (DECOD_LD8A_LOOPBODY,IO_NONE,0,"000",'0'),
    (DECOD_LD8A_LOOPEND,IO_NONE,0,"000",'0'),
    (MAIN_DEC3,IO_NONE,0,"000",'0'),
    (DEC_DATA_OUT,IO_READ,80,"011",'1'), -- read-out output samples
    --
    -- "run encoding-only" sub-program
    --
    (DATA_IN,IO_WRITE,80,"000",'0'), -- write-in input samples
    (MAIN_COD1,IO_NONE,0,"000",'0'),
    (BIG_LOOP_INIT,IO_NONE,0,"000",'0'),
    (BIG_LOOP,IO_NONE,0,"000",'0'),
    (BIG_LOOP_UPDT,IO_NONE,0,"000",'0'),
    (BIG_LOOP,IO_NONE,0,"000",'0'),
    (UPDATE,IO_NONE,0,"000",'0'),
    (MAIN_COD3,IO_NONE,0,"000",'0'),
    (COD_DATA_OUT,IO_READ,5,"001",'1'), -- read-out encoded frame
    --
    -- "run" sub-program
    --
    (DEC_DATA_IN,IO_WRITE,5,"010",'0'), -- write-in encoded frame
    (MAIN_DEC1,IO_NONE,0,"000",'0'),
    (DECOD_LD8A_LOOPINIT,IO_NONE,0,"000",'0'),
    (DECOD_LD8A_LOOPBODY,IO_NONE,0,"000",'0'),
    (DECOD_LD8A_LOOPUPDT,IO_NONE,0,"000",'0'),
    (DECOD_LD8A_LOOPBODY,IO_NONE,0,"000",'0'),
    (DECOD_LD8A_LOOPEND,IO_NONE,0,"000",'0'),
    (MAIN_DEC3,IO_NONE,0,"000",'0'),
    (DEC_DATA_OUT,IO_READ,80,"011",'0'), -- read-out output samples
    (DATA_IN,IO_WRITE,80,"000",'0'), -- write-in input samples
    (MAIN_COD1,IO_NONE,0,"000",'0'),
    (BIG_LOOP_INIT,IO_NONE,0,"000",'0'),
    (BIG_LOOP,IO_NONE,0,"000",'0'),
    (BIG_LOOP_UPDT,IO_NONE,0,"000",'0'),
    (BIG_LOOP,IO_NONE,0,"000",'0'),
    (UPDATE,IO_NONE,0,"000",'0'),
    (MAIN_COD3,IO_NONE,0,"000",'0'),
    (COD_DATA_OUT,IO_READ,5,"001",'1'), -- read-out encoded frame
    --
    -- "save state" sub-program
    --
    (STATE_OUT,IO_READ,1679,"100",'1') -- read-out channel state
  );

  -- ASIP memory data-in/out and state buffers address
  constant STATE_ADR : natural := 0;
  constant DEC_SADR : natural := 1692; -- dec_datain
  constant DEC_DADR : natural := 1547; -- dec_synth
  constant COD_SADR : natural := 160; -- new_speech
  constant COD_DADR : natural := 1692; -- dec_datain

  -- Controller state type

  type TEST_STATE_T is (
    TS_IDLE,
    TS_NEXT,
    TS_WAIT1,
    TS_READ,
    TS_WRITE,
    TS_RUN,
    TS_WAIT2,
    TS_WAIT3,
    TS_WAIT4,
    TS_WAIT5,
    TS_WAIT6
  );

  signal TS,TS_q : TEST_STATE_T;
  signal PROG_CNT_q : natural range 0 to MAX_PROG-1;
  signal PROG_FIRST : natural range 0 to MAX_PROG-1;
  signal PROG_NEXT : std_logic;
  signal PROG_LAST : std_logic;
  signal IO_MODE : std_logic_vector(2-1 downto 0);
  signal IO_COUNT : natural range 0 to MAX_IO_COUNT-1;
  signal IO_ASEL : std_logic_vector(3-1 downto 0);
  signal A_STRT,A_STRT_q : std_logic;
  signal D_STRT,D_STRT_q : std_logic;
  signal BSY,BSY_q : std_logic;
  signal D_WE : std_logic;
  signal A_DMAE : std_logic;
  signal A_ADR : unsigned(ALEN-1 downto 0);
  signal PROG_SUB : PROG_T;
  signal STS,STS_q : std_logic_vector(3-1 downto 0);

begin

  ---------------------------------------------------
  -- Control FSM
  ---------------------------------------------------

  process(CLK_i)
  begin
    if(CLK_i = '1' and CLK_i'event) then
      if(RST_i = '1') then
        TS_q <= TS_IDLE;
        A_STRT_q <= '0';
        D_STRT_q <= '0';
        BSY_q <= '0';
        STS_q <= STS_IDLE;
      else
        TS_q <= TS;
        A_STRT_q <= A_STRT;
        D_STRT_q <= D_STRT;
        BSY_q <= BSY;
        STS_q <= STS;
      end if;
    end if;
  end process;

  process(TS_q,STRT_i,A_BSY_i,PROG_LAST,D_BSY_i,IO_MODE,IO_ASEL)
  begin

    A_STRT <= '0';
    D_STRT <= '0';
    PROG_NEXT <= '0';
    BSY <= '1';
    STS <= STS_IDLE;

    case TS_q is

      -- wait for a new packet to be processed
      when TS_IDLE =>  
        if(STRT_i = '1') then
          TS <= TS_WAIT4;
        else
          -- do nothing
          BSY <= '0';
          TS <= TS_IDLE;
        end if;

      -- 1-cycle delay to init. sub-program counter
      when TS_WAIT4 =>  
        TS <= TS_WAIT5;

      -- 1-cycle delay to read sub-prog. ROM
      when TS_WAIT5 =>  
        -- check if first sub-prog. is of I/O-type
        if(IO_MODE /= IO_NONE) then
           -- start avalon data port operations
           D_STRT <= '1';
        else
          -- start ASIP execution
          A_STRT <= '1';
        end if;
        TS <= TS_WAIT1;

      -- start next sub-program execution
      when TS_NEXT =>  
        if(IO_MODE /= IO_NONE) then
           -- start avalon data port operations
           D_STRT <= '1';
        else
          -- start ASIP execution
          A_STRT <= '1';
        end if;
        TS <= TS_WAIT1;

      -- it takes one cycle to get info about
      -- sub-program to be executed, so that
      -- checks are delayed to TS_WAIT1 state.

      -- check I/O mode
      when TS_WAIT1 =>  
        if(IO_MODE = IO_READ) then
          -- sub-program is of READ type
          TS <= TS_READ;
        elsif(IO_MODE = IO_WRITE) then
          -- sub-program is of WRITE type
          TS <= TS_WRITE;
        else
          -- sub-program is if computing type
          TS <= TS_WAIT3;
        end if;

      when TS_WAIT3 =>
        TS <= TS_RUN;

      -- read data out of ASIP memory
      when TS_READ =>
        if(D_BSY_i = '0') then
          TS <= TS_WAIT2;
        else
          if(IO_ASEL = "001") then
            STS <= STS_COD_DOUT;
          elsif(IO_ASEL = "011") then
            STS <= STS_DEC_DOUT;
          else
            STS <= STS_STT_DOUT;
          end if;
          TS <= TS_READ;
        end if;

      -- write data into ASIP memory
      when TS_WRITE => 
        if(D_BSY_i = '0') then
          TS <= TS_WAIT2;
        else
          if(IO_ASEL = "000") then
            STS <= STS_COD_DIN;
          elsif(IO_ASEL = "010") then
            STS <= STS_DEC_DIN;
          else
            STS <= STS_STT_DIN;
          end if;
          TS <= TS_WRITE;
        end if;

      -- run sub-program not performing I/O
      when TS_RUN =>
        if(A_BSY_i = '0') then
          TS <= TS_WAIT2;
        else
          STS <= STS_PRUN;
          TS <= TS_RUN;
        end if;

      when TS_WAIT2 =>
        PROG_NEXT <= '1';
        if(PROG_LAST = '1') then
          TS <= TS_IDLE;
        else
          TS <= TS_WAIT6;
        end if;

      when TS_WAIT6 =>
        TS <= TS_NEXT;

    end case;
  end process;

  ---------------------------------------------------
  -- Program sequencer
  ---------------------------------------------------

  -- index of first sub-program to be executed
  -- (used to initialize sub-program counter).

  process(OPS_i)
  begin
    case OPS_i is
      when INIT => PROG_FIRST <= 0;
      when RUND => PROG_FIRST <= 3;
      when RUNC => PROG_FIRST <= 12;
      when RUNF => PROG_FIRST <= 21;
      when SAVS => PROG_FIRST <= 39;
      when others => PROG_FIRST <= 2;
    end case;
  end process;

  -- sub-program counter
  process(CLK_i)
  begin
    if(CLK_i = '1' and CLK_i'event) then
      if(RST_i = '1') then
        PROG_CNT_q <= 0;
      elsif(STRT_i = '1') then
        PROG_CNT_q <= PROG_FIRST;
      elsif(PROG_NEXT = '1' and PROG_LAST = '0') then
        PROG_CNT_q <= PROG_CNT_q + 1;
      end if;
    end if;
  end process;

  -- "program" memory is used as a sync. ROM indexed
  -- by sub-program counter.

  process(CLK_i)
  begin
    if(CLK_i = '1' and CLK_i'event) then
      PROG_SUB <= PROG_SEQ_q(PROG_CNT_q); 
    end if;
  end process;

  -- extract sub-program info

  process(PROG_SUB)
  begin
    SADR_o <= to_unsigned(PROG_SUB.SADR,ALEN);
    IO_MODE <= PROG_SUB.IO_MODE;
    IO_COUNT <= PROG_SUB.IO_COUNT;
    IO_ASEL <= PROG_SUB.IO_ASEL;
    PROG_LAST <= PROG_SUB.HALT;
    if(PROG_SUB.IO_MODE = IO_WRITE) then
      D_WE <= '1';
    else
      D_WE <= '0';
    end if;
    if(PROG_SUB.IO_MODE /= IO_NONE) then
      A_DMAE <= '1';
    else
      A_DMAE <= '0';
    end if;
  end process;

  -- burst length (for ASIP DMA operations)
  BLEN_o <= IO_COUNT;

  -- address selector (for ASIP DMA operations)
  ASEL_o <= IO_ASEL;

  -- check enable flag (for ASIP)
  CHKE_o <= SIMULATION_ONLY when (IO_MODE = IO_NONE) else '0';

  D_WE_o <= D_WE;

  -- DMA-enable flag
  A_DMAE_o <= A_DMAE;

  -- select source/destination (ASIP memory) address for DMA transfers
  process(PROG_SUB)
    variable N : natural;
  begin
    case PROG_SUB.IO_ASEL is
      when "000" => N := COD_SADR;
      when "001" => N := COD_DADR;
      when "010" => N := DEC_SADR;
      when "011" => N := DEC_DADR;
      when others =>  N := STATE_ADR;
    end case;
    A_ADR <= to_unsigned(N,ALEN);
  end process;

  ---------------------------------------------------
  -- outputs
  ---------------------------------------------------

  A_STRT_o <= A_STRT_q;
  A_ADR_o <= A_ADR;
  D_STRT_o <= D_STRT_q;
  BSY_o <= BSY_q;
  STS_o <= STS_q;

end ARC;
