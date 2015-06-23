--/**************************************************************************************************************
--*
--*    L Z R W 1   E N C O D E R   C O R E
--*
--*  A high throughput loss less data compression core.
--* 
--* Copyright 2012-2013   Lukas Schrittwieser (LS)
--*
--*    This program is free software: you can redistribute it and/or modify
--*    it under the terms of the GNU General Public License as published by
--*    the Free Software Foundation, either version 2 of the License, or
--*    (at your option) any later version.
--*
--*    This program is distributed in the hope that it will be useful,
--*    but WITHOUT ANY WARRANTY; without even the implied warranty of
--*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--*    GNU General Public License for more details.
--*
--*    You should have received a copy of the GNU General Public License
--*    along with this program; if not, write to the Free Software
--*    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
--*    Or see <http://www.gnu.org/licenses/>
--*
--***************************************************************************************************************
--*
--* Change Log:
--*
--* Version 1.0 - 2012/6/17 - LS
--*   started file
--*
--* Version 1.0 - 2013/04/05 - LS
--*   release
--*
--***************************************************************************************************************
--*
--* Naming convention:  http://dz.ee.ethz.ch/en/information/hdl-help/vhdl-naming-conventions.html
--*
--***************************************************************************************************************
--* 
--* This is the main file of the compression core. It connects several
--* sub-cores in a pipeline. Data IO is bytewise.
--*
--***************************************************************************************************************
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library UNISIM;
use UNISIM.VComponents.all;

entity LZRWcompressor is
  port (
    ClkxCI         : in  std_logic;
    RstxRI         : in  std_logic;
    DataInxDI      : in  std_logic_vector(7 downto 0);  -- uncompressed data input
    StrobexSI      : in  std_logic;     -- strobe for input data
    FlushBufxSI    : in  std_logic;
    BusyxSO        : out std_logic;  -- data can only be strobed in if this is low
    DonexSO        : out std_logic;  -- flush is done, all data has been processed
    BufOutxDO      : out std_logic_vector(7 downto 0);
    OutputValidxSO : out std_logic;
    RdStrobexSI    : in  std_logic;
    LengthxDO      : out integer range 0 to 1024
    );
end LZRWcompressor;

architecture Behavioral of LZRWcompressor is

  
  component HashTable
    generic (
      entryBitWidth : integer);
    port (
      ClkxCI      : in  std_logic;
      RstxRI      : in  std_logic;
      NewEntryxDI : in  std_logic_vector(entryBitWidth-1 downto 0);
      EnWrxSI     : in  std_logic;
      Key0xDI     : in  std_logic_vector(7 downto 0);
      Key1xDI     : in  std_logic_vector(7 downto 0);
      Key2xDI     : in  std_logic_vector(7 downto 0);
      OldEntryxDO : out std_logic_vector(entryBitWidth-1 downto 0));
  end component;

  component historyBuffer
    port (
      ClkxCI          : in  std_logic;
      RstxRI          : in  std_logic;
      WriteInxDI      : in  std_logic_vector(7 downto 0);
      WExSI           : in  std_logic;
      NextWrAdrxDO    : out std_logic_vector(11 downto 0);
      RExSI           : in  std_logic;
      ReadBackAdrxDI  : in  std_logic_vector(11 downto 2);
      ReadBackxDO     : out std_logic_vector(16*8-1 downto 0);
      ReadBackDonexSO : out std_logic);
  end component;

  component comparator
    port (
      LookAheadxDI    : in  std_logic_vector(16*8-1 downto 0);
      LookAheadLenxDI : in  integer range 0 to 16;
      CandidatexDI    : in  std_logic_vector(16*8-1 downto 0);
      CandidateLenxDI : in  integer range 0 to 16;
      MatchLenxDO     : out integer range 0 to 16);
  end component;

  component outputEncoder
    generic (
      frameSize   : integer;
      minMatchLen : integer;
      maxMatchLen : integer);
    port (
      ClkxCI          : in  std_logic;
      RstxRI          : in  std_logic;
      OffsetxDI       : in  std_logic_vector(11 downto 0);
      MatchLengthxDI  : in  integer range 0 to maxMatchLen;
      EnxSI           : in  std_logic;
      EndOfDataxSI    : in  std_logic;
      LiteralxDI      : in  std_logic_vector(7 downto 0);
      BodyStrobexSO   : out std_logic;
      BodyOutxDO      : out std_logic_vector(7 downto 0);
      HeaderStrobexSO : out std_logic;
      HeaderOutxDO    : out std_logic_vector(frameSize-1 downto 0);
      DonexSO         : out std_logic);
  end component;

  component outputFIFO
    generic (
      frameSize : integer);
    port (
      ClkxCI          : in  std_logic;
      RstxRI          : in  std_logic;
      BodyDataxDI     : in  std_logic_vector(7 downto 0);
      BodyStrobexSI   : in  std_logic;
      HeaderDataxDI   : in  std_logic_vector(frameSize-1 downto 0);
      HeaderStrobexSI : in  std_logic;
      BuffersEmptyxSO : out std_logic;
      BufOutxDO       : out std_logic_vector(7 downto 0);
      OutputValidxSO  : out std_logic;
      RdStrobexSI     : in  std_logic;
      LengthxDO       : out integer range 0 to 1024);
  end component;

  constant HIST_BUF_LEN   : integer := 4096;  -- length of the history buffer in bytes (DO NOT CHANGE!!)
  constant LOOK_AHEAD_LEN : integer := 16;  -- length of the look ahead buffer in bytes (DO NOT CHANGE!!)
  constant OUT_FIFO_THR   : integer := 1000;  -- output length at which we set busy high. Should be at least one max frame size below 1024

  type lookAheadBufType is array (LOOK_AHEAD_LEN-1 downto 0) of std_logic_vector(7 downto 0);
  type ctrlFSMType is (ST_FILL_LOOK_AHEAD, ST_RUN, ST_DRAIN_LOOK_AHEAD, ST_DONE);

  signal LookAheadBufxDN, LookAheadBufxDP     : lookAheadBufType                  := (others => (others => '0'));
  signal LookAheadLenxDN, LookAheadLenxDP     : integer range 0 to LOOK_AHEAD_LEN := 0;
  signal ShiftLookAheadxSN, ShiftLookAheadxSP : std_logic                         := '0';
  signal Strobe0xSN, Strobe0xSP               : std_logic                         := '0';
  signal HistBufLen0xDN, HistBufLen0xDP       : integer range 0 to HIST_BUF_LEN   := 0;  -- count history buffer length at startup
  signal HistBufOutxD                         : std_logic_vector(LOOK_AHEAD_LEN*8-1 downto 0);
  signal EndOfData0xSN, EndOfData0xSP         : std_logic                         := '0';
  signal DataIn0xDN, DataIn0xDP               : std_logic_vector(7 downto 0)      := x"00";
  signal WrHistBufxS                          : std_logic;
  signal LookAheadPtr0xD                      : std_logic_vector(11 downto 0);
  signal NextWrAdrxD                          : std_logic_vector(11 downto 0);
  signal BusyxSN, BusyxSP                     : std_logic                         := '0';
  signal StatexSN, StatexSP                   : ctrlFSMType                       := ST_FILL_LOOK_AHEAD;

  signal HashTableEntryxD                   : std_logic_vector(11 downto 0);  -- entry found by the hash table
  signal LookAheadLen1xDN, LookAheadLen1xDP : integer range 0 to LOOK_AHEAD_LEN := 0;
  signal Strobe1xSN, Strobe1xSP             : std_logic                         := '0';
  signal HistBufLen1xDN, HistBufLen1xDP     : integer range 0 to HIST_BUF_LEN   := 0;
  signal EndOfData1xSN, EndOfData1xSP       : std_logic                         := '0';
  signal LookAheadBuf1xDN, LookAheadBuf1xDP : lookAheadBufType                  := (others => (others => '0'));
  signal WrAdr1xDN, WrAdr1xDP               : std_logic_vector(11 downto 0)     := (others => '0');
  signal LookAheadPtr1xDN, LookAheadPtr1xDP : std_logic_vector(11 downto 0)     := (others => '0');
  signal CandAddr1xDN, CandAddr1xDP         : std_logic_vector(11 downto 0)     := (others => '0');

  signal LookAheadLen2xDN, LookAheadLen2xDP     : integer range 0 to LOOK_AHEAD_LEN             := 0;
  signal LookAheadBuf2xDN, LookAheadBuf2xDP     : lookAheadBufType                              := (others => (others => '0'));
  signal Strobe2xSN, Strobe2xSP                 : std_logic                                     := '0';
  signal HistBufLen2xDN, HistBufLen2xDP         : integer range 0 to HIST_BUF_LEN               := 0;
  signal Candidate2xDN, Candidate2xDP           : std_logic_vector(LOOK_AHEAD_LEN*8-1 downto 0) := (others => '0');
  signal NextWrAdr2xDN, NextWrAdr2xDP           : integer range 0 to LOOK_AHEAD_LEN             := 0;
  signal CandAddr2xDN, CandAddr2xDP             : std_logic_vector(11 downto 0)                 := (others => '0');
  signal CandLen2xDN, CandLen2xDP               : integer range 0 to LOOK_AHEAD_LEN;
  signal EndOfData2xSN, EndOfData2xSP           : std_logic                                     := '0';
  signal OffsetIntxD                            : integer range -HIST_BUF_LEN to HIST_BUF_LEN;
  signal OffsetxD                               : std_logic_vector(11 downto 0);
  signal HashTableEntry2xDN, HashTableEntry2xDP : std_logic_vector(11 downto 0)                 := (others => '0');
  signal MaxCandLenxD                           : integer range 0 to LOOK_AHEAD_LEN;

  signal MatchLenxD, MatchLenLimitedxD      : integer range 0 to LOOK_AHEAD_LEN := 0;
  signal LookAheadPtr2xDN, LookAheadPtr2xDP : std_logic_vector(11 downto 0)     := (others => '0');
  signal CompLAIn3xD                        : std_logic_vector(LOOK_AHEAD_LEN*8-1 downto 0);
  signal HeaderStrobexS                     : std_logic;
  signal HeaderDataxD                       : std_logic_vector(7 downto 0);
  signal BodyStrobexS                       : std_logic;
  signal BodyDataxD                         : std_logic_vector(7 downto 0);
  signal FifoBuffersEmptyxS                 : std_logic;
  signal OutFIFOLengthxD                    : integer range 0 to 1024;
  signal EncDonexS                          : std_logic;
  signal Done3xSN, Done3xSP                 : std_logic                         := '0';
  
begin

  -----------------------------------------------------------------------------
  -- Pipeline stage 0
  -----------------------------------------------------------------------------

  -- control FSM for look ahead buffer
  process (DataIn0xDP, DataInxDI, FlushBufxSI, LookAheadLenxDP,
           OutFIFOLengthxD, StatexSP, Strobe0xSP, StrobexSI)
  begin
    StatexSN          <= StatexSP;
    ShiftLookAheadxSN <= '0';
    WrHistBufxS       <= '0';
    Strobe0xSN        <= '0';
    EndOfData0xSN     <= '0';
    DataIn0xDN        <= DataIn0xDP;
    BusyxSN           <= '0';

    case StatexSP is
      when ST_FILL_LOOK_AHEAD =>
        -- don't shift here, we are still loading data
        --ShiftLookAheadxSN <= StrobexSI;  -- the shift is delayed by one cycle because we have to process the byte first
        WrHistBufxS <= StrobexSI;
        DataIn0xDN  <= DataInxDI;
        if FlushBufxSI = '1' then
          StatexSN <= ST_DRAIN_LOOK_AHEAD;
        elsif LookAheadLenxDP = LOOK_AHEAD_LEN-1 then
          -- this byte is number look_ahead_len-1, so it is the last one before the buffer is full
          -- the buffer will be full with the next incoming byte, so the next
          -- one can be processed regularely
          StatexSN <= ST_RUN;
        end if;

      when ST_RUN =>
        ShiftLookAheadxSN <= StrobexSI;
        Strobe0xSN        <= StrobexSI;  -- pass on strobe to pipeline
        WrHistBufxS       <= StrobexSI;
        DataIn0xDN        <= DataInxDI;
        if FlushBufxSI = '1' then
          StatexSN <= ST_DRAIN_LOOK_AHEAD;
        end if;

      when ST_DRAIN_LOOK_AHEAD =>
        -- create a strobe every second cycle
        if LookAheadLenxDP > 0 and Strobe0xSP = '0' then
          ShiftLookAheadxSN <= '1';
          Strobe0xSN        <= '1';
        end if;
        if LookAheadLenxDP = 0 then
          EndOfData0xSN <= '1';
          StatexSN      <= ST_DONE;
        end if;

      when ST_DONE => null;

      when others => StatexSN <= ST_DONE;  -- fail save, just block
    end case;

    if OutFIFOLengthxD > OUT_FIFO_THR then
      BusyxSN <= '1';  -- request stop of data input if output FIFO is full
    end if;
  end process;

  -- we can accept data only every second clock cycle -> feed strobe back as
  -- busy signal
  BusyxSO <= BusyxSP or StrobexSI;

  -- implement a shift register for the look ahead buffer
  lookAheadProc : process (DataInxDI, ShiftLookAheadxSP, StatexSP, StrobexSI,
                           lookAheadBufxDP, lookAheadLenxDP)
  begin  -- process lookAheadProc
    lookAheadLenxDN <= lookAheadLenxDP;

    if StrobexSI = '1' then
      -- load new data into MSB
      --lookAheadBufxDN(LOOK_AHEAD_LEN-1) <= DataInxDI;
      -- increase length counter if it is below the top 
      if lookAheadLenxDP < LOOK_AHEAD_LEN then
        lookAheadLenxDN <= lookAheadLenxDP + 1;
      end if;
    end if;

    if ShiftLookAheadxSP = '1' then
      -- decrease buffer length counter if there is no valid input data
      if lookAheadLenxDP > 0 and StrobexSI = '0' and StatexSP /= ST_FILL_LOOK_AHEAD then
        lookAheadLenxDN <= lookAheadLenxDP - 1;
      end if;
    end if;
    
  end process lookAheadProc;

  -- implement actual shift register
  lookAheadShiftReg : for i in 0 to LOOK_AHEAD_LEN-2 generate
    process (DataInxDI, LookAheadLenxDP, ShiftLookAheadxSP, StrobexSI,
             lookAheadBufxDP)
    begin  -- process
      lookAheadBufxDN(i) <= lookAheadBufxDP(i);      -- default: do nothing
      if ShiftLookAheadxSP = '1' then
        lookAheadBufxDN(i) <= lookAheadBufxDP(i+1);  -- shift done one entry
      elsif LookAheadLenxDP = i and StrobexSI = '1' then
        lookAheadBufxDN(i) <= DataInxDI;  -- load new byte into shift register
      end if;
    end process;
  end generate lookAheadShiftReg;
  -- implement the top most byte of the shift register
  lookAheadBufxDN(LOOK_AHEAD_LEN-1) <= DataInxDI when lookAheadLenxDP >= LOOK_AHEAD_LEN-1 and StrobexSI = '1' else lookAheadBufxDP(LOOK_AHEAD_LEN-1);

  HashTableInst : HashTable
    generic map (
      entryBitWidth => 12)
    port map (
      ClkxCI      => ClkxCI,
      RstxRI      => RstxRI,
      NewEntryxDI => LookAheadPtr0xD,
      EnWrxSI     => Strobe0xSP,  -- delay write by one cycle because we have to read first
      Key0xDI     => lookAheadBufxDP(0),
      Key1xDI     => lookAheadBufxDP(1),
      Key2xDI     => lookAheadBufxDP(2),
      OldEntryxDO => HashTableEntryxD);

  historyBufferInst : historyBuffer
    port map (
      ClkxCI          => ClkxCI,
      RstxRI          => RstxRI,
      WriteInxDI      => DataInxDI,
      WExSI           => WrHistBufxS,
      NextWrAdrxDO    => NextWrAdrxD,
      RExSI           => Strobe0xSP,  -- delay read by one cycle (we write first)
      ReadBackAdrxDI  => HashTableEntryxD(11 downto 2),
      ReadBackxDO     => HistBufOutxD,
      ReadBackDonexSO => open);

-- calculate a pointer to the beginning of the look ahead section in the
-- history buffer
  process (LookAheadLenxDP, NextWrAdrxD)
  begin  -- process
    if LookAheadLenxDP <= to_integer(unsigned(NextWrAdrxD)) then
      -- this is the regular case, write index is bigger than look ahead len ->
      -- no wrap around in buffer
      LookAheadPtr0xD <= std_logic_vector(to_unsigned(to_integer(unsigned(NextWrAdrxD))-LookAheadLenxDP, 12));
    else
      -- wrap around -> add history buffer length to get a pos value
      LookAheadPtr0xD <= std_logic_vector(to_unsigned(HIST_BUF_LEN + to_integer(unsigned(NextWrAdrxD)) - LookAheadLenxDP, 12));
    end if;
  end process;


-- count the number of bytes in the history buffer. Note that we only count
-- the _history_ so only bytes which have already been processed.
  process (HistBufLen0xDP, Strobe0xSP)
  begin
    HistBufLen0xDN <= HistBufLen0xDP;
    -- count the number of processed bytes
    if Strobe0xSP = '1' then
      if HistBufLen0xDP < HIST_BUF_LEN - LOOK_AHEAD_LEN then
        HistBufLen0xDN <= HistBufLen0xDP + 1;
      end if;
    end if;
  end process;


-----------------------------------------------------------------------------
-- pipeline stage 1
--
-- wait for data from histroy buffer
-----------------------------------------------------------------------------

  process (CandAddr1xDP, HashTableEntryxD, HistBufLen0xDP, HistBufLen1xDP,
           LookAheadBuf1xDP, LookAheadLen1xDP, LookAheadPtr0xD,
           LookAheadPtr1xDP, Strobe0xSP, lookAheadBufxDP, lookAheadLenxDP)
  begin
    LookAheadLen1xDN <= LookAheadLen1xDP;
    LookAheadBuf1xDN <= LookAheadBuf1xDP;
    LookAheadPtr1xDN <= LookAheadPtr1xDP;
    HistBufLen1xDN   <= HistBufLen1xDP;
    CandAddr1xDN     <= CandAddr1xDP;

    if Strobe0xSP = '1' then
      LookAheadLen1xDN <= lookAheadLenxDP;
      LookAheadBuf1xDN <= lookAheadBufxDP;
      CandAddr1xDN     <= HashTableEntryxD;
      LookAheadPtr1xDN <= LookAheadPtr0xD;
      HistBufLen1xDN   <= HistBufLen0xDP;
    end if;
    
  end process;

-- signals to be passed on
  Strobe1xSN    <= Strobe0xSP;
  EndOfData1xSN <= EndOfData0xSP;



-----------------------------------------------------------------------------
-- pipeline stage 2
--
-- shift history buffer output
-----------------------------------------------------------------------------

-- limit the max candidate length
  MaxCandLenxD <= LOOK_AHEAD_LEN;

-- use a shifter to implement the last two bytes of the address
  process (CandAddr1xDP, CandAddr2xDP, CandLen2xDP, Candidate2xDP,
           HistBufLen1xDP, HistBufLen2xDP, HistBufOutxD, LookAheadBuf1xDP,
           LookAheadBuf2xDP, LookAheadLen1xDP, LookAheadLen2xDP,
           LookAheadPtr1xDP, LookAheadPtr2xDP, MaxCandLenxD, Strobe1xSP)
  begin
    Candidate2xDN    <= Candidate2xDP;
    LookAheadBuf2xDN <= LookAheadBuf2xDP;
    LookAheadLen2xDN <= LookAheadLen2xDP;
    CandAddr2xDN     <= CandAddr2xDP;
    LookAheadPtr2xDN <= LookAheadPtr2xDP;
    HistBufLen2xDN   <= HistBufLen2xDP;
    CandLen2xDN      <= CandLen2xDP;
    -- send data through pipeline when strobe is high
    if Strobe1xSP = '1' then
      -- note: the history buffer can't load data only from addresses where the
      -- last two bits are zero. If this was not the case we shift the candidate
      -- (which makes it shorter) to correct that
      case CandAddr1xDP(1 downto 0) is
        when "00" => Candidate2xDN <= HistBufOutxD;  -- no shifting
                     CandLen2xDN <= MaxCandLenxD;
        when "01" => Candidate2xDN <= x"00" & HistBufOutxD(LOOK_AHEAD_LEN*8-1 downto 8);  -- shift one byte
                     CandLen2xDN <= MaxCandLenxD-1;  -- we shifted one byte out -> candidate is one byte shorter
        when "10" => Candidate2xDN <= x"0000" & HistBufOutxD(LOOK_AHEAD_LEN*8-1 downto 16);  -- shift 2 bytes
                     CandLen2xDN <= MaxCandLenxD-2;
        when "11" => Candidate2xDN <= x"000000" & HistBufOutxD(LOOK_AHEAD_LEN*8-1 downto 24);  -- shift 3 bytes
                     CandLen2xDN <= MaxCandLenxD-3;
        when others => null;
      end case;

      LookAheadBuf2xDN <= LookAheadBuf1xDP;
      LookAheadLen2xDN <= LookAheadLen1xDP;
      CandAddr2xDN     <= CandAddr1xDP;
      --   NextWrAdr2xDN    <= NextWrAdr1xDP;
      LookAheadPtr2xDN <= LookAheadPtr1xDP;
      HistBufLen2xDN   <= HistBufLen1xDP;
    end if;
  end process;

-- signals to be passed on to next stage
  HashTableEntry2xDN <= HashTableEntryxD;
  Strobe2xSN         <= Strobe1xSP;
  EndOfData2xSN      <= EndOfData1xSP;


-------------------------------------------------------------------------------
-- Pipeline Stage 3
--
-- Comparator, Offset Calculation and Data Output
-------------------------------------------------------------------------------

-- reformat two dimensional look ahead buffer into one dimensional array
-- not nice, I know. We should have a package defining proper types and use
-- them consistently...
  arrayReformatter : for i in 0 to LOOK_AHEAD_LEN-1 generate
    CompLAIn3xD((i+1)*8-1 downto i*8) <= LookAheadBuf2xDP(i);
  end generate arrayReformatter;

  comparatorInst : comparator
    port map (
      LookAheadxDI    => CompLAIn3xD,
      LookAheadLenxDI => LookAheadLen2xDP,
      CandidatexDI    => Candidate2xDP,
      CandidateLenxDI => CandLen2xDP,
      MatchLenxDO     => MatchLenxD);

  -- calculate the offset
  process (CandAddr2xDP, LookAheadPtr2xDP, OffsetIntxD)
  begin
    OffsetIntxD <= -1;                  -- default: illegal offset
    if to_integer(unsigned(LookAheadPtr2xDP)) > to_integer(unsigned(CandAddr2xDP)) then
      -- this is the regular case, the candidate address is smaller (ie in the
      -- past) than the byte to be encoded (which is at index given by lookAheadPtr)
      OffsetIntxD <= to_integer(unsigned(LookAheadPtr2xDP)) - to_integer(unsigned(CandAddr2xDP)) - 1;
    elsif to_integer(unsigned(LookAheadPtr2xDP)) < to_integer(unsigned(CandAddr2xDP)) then
      -- there is a buffer wrap around between the two pointers, the offset
      -- would be negative -> add buffer length
      OffsetIntxD <= HIST_BUF_LEN + to_integer(unsigned(LookAheadPtr2xDP)) - to_integer(unsigned(CandAddr2xDP)) - 1;
    else
      -- this means that the candidate and the history buffer (byte to be
      -- encoded) are on the same location. This is invalid as the candidate can't be
      -- in the future -> create an illeagal negative offset to invalidate this match
      OffsetIntxD <= -1;
    end if;
    OffsetxD <= std_logic_vector(to_unsigned(OffsetIntxD, 12));
  end process;

  Done3xSN <= EncDonexS and FifoBuffersEmptyxS;

  -- note: the offset can't be longer than the history buffer length 
  -- if the offset is too long we disable the match by setting the length to 0
  -- we also check for illegal negative offsets
  MatchLenLimitedxD <= MatchLenxD when OffsetIntxD < (HistBufLen2xDP) and OffsetIntxD >= 0 else 0;

  outputEncoderInst : outputEncoder
    generic map (
      frameSize   => 8,
      minMatchLen => 3,
      maxMatchLen => LOOK_AHEAD_LEN)
    port map (
      ClkxCI          => ClkxCI,
      RstxRI          => RstxRI,
      OffsetxDI       => OffsetxD,
      MatchLengthxDI  => MatchLenLimitedxD,
      EnxSI           => Strobe2xSP,
      EndOfDataxSI    => EndOfData2xSP,
      LiteralxDI      => LookAheadBuf2xDP(0),
      BodyStrobexSO   => BodyStrobexS,
      BodyOutxDO      => BodyDataxD,
      HeaderStrobexSO => HeaderStrobexS,
      HeaderOutxDO    => HeaderDataxD,
      DonexSO         => EncDonexS);


  outputFIFOInst : outputFIFO
    generic map (
      frameSize => 8)  -- number of elements (pairs or literals) per frame
    port map (
      ClkxCI          => ClkxCI,
      RstxRI          => RstxRI,
      BodyDataxDI     => BodyDataxD,
      BodyStrobexSI   => BodyStrobexS,
      HeaderDataxDI   => HeaderDataxD,
      HeaderStrobexSI => HeaderStrobexS,
      BuffersEmptyxSO => FifoBuffersEmptyxS,
      BufOutxDO       => BufOutxDO,
      OutputValidxSO  => OutputValidxSO,
      RdStrobexSI     => RdStrobexSI,
      LengthxDO       => OutFIFOLengthxD);

  LengthxDO <= OutFIFOLengthxD;
  DonexSO   <= Done3xSP;

  -----------------------------------------------------------------------------
  -- GENERAL STUFF
  -----------------------------------------------------------------------------

  registers : process (ClkxCI)
  begin  -- process registers
    if ClkxCI'event and ClkxCI = '1' then
      if RstxRI = '1' then
        StatexSP          <= ST_FILL_LOOK_AHEAD;
        BusyxSP           <= '0';
        ShiftLookAheadxSP <= '0';
        lookAheadLenxDP   <= 0;
        Strobe0xSP        <= '0';
        LookAheadLen1xDP  <= 0;
        Strobe1xSP        <= '0';
        WrAdr1xDP         <= (others => '0');
        LookAheadLen2xDP  <= 0;
        Strobe2xSP        <= '0';
        HistBufLen0xDP    <= 0;
        EndOfData0xSP     <= '0';
        EndOfData1xSP     <= '0';
        EndOfData2xSP     <= '0';
        Done3xSP          <= '0';
      else
        StatexSP           <= StatexSN;
        BusyxSP            <= BusyxSN;
        ShiftLookAheadxSP  <= ShiftLookAheadxSN;
        lookAheadLenxDP    <= lookAheadLenxDN;
        lookAheadBufxDP    <= lookAheadBufxDN;
        Strobe0xSP         <= Strobe0xSN;
        HistBufLen0xDP     <= HistBufLen0xDN;
        DataIn0xDP         <= DataIn0xDN;
        lookAheadLen1xDP   <= lookAheadLen1xDN;
        Strobe1xSP         <= Strobe1xSN;
        HistBufLen1xDP     <= HistBufLen1xDN;
        WrAdr1xDP          <= WrAdr1xDN;
        LookAheadPtr1xDP   <= LookAheadPtr1xDN;
        LookAheadBuf1xDP   <= LookAheadBuf1xDN;
        LookAheadLen2xDP   <= LookAheadLen2xDN;
        LookAheadBuf2xDP   <= LookAheadBuf2xDN;
        CandAddr1xDP       <= CandAddr1xDN;
        Strobe2xSP         <= Strobe2xSN;
        HistBufLen2xDP     <= HistBufLen2xDN;
        NextWrAdr2xDP      <= NextWrAdr2xDN;
        LookAheadPtr2xDP   <= LookAheadPtr2xDN;
        CandAddr2xDP       <= CandAddr2xDN;
        Candidate2xDP      <= Candidate2xDN;
        CandLen2xDP        <= CandLen2xDN;
        HashTableEntry2xDP <= HashTableEntry2xDN;
        EndOfData0xSP      <= EndOfData0xSN;
        EndOfData1xSP      <= EndOfData1xSN;
        EndOfData2xSP      <= EndOfData2xSN;
        Done3xSP           <= Done3xSN;
        
      end if;
    end if;
  end process registers;

end Behavioral;

