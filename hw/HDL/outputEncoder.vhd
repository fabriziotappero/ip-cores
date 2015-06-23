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
--* Version 1.0 - 2012/6/30 - LS
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
--* Encodes the length/distance pair or the literal to the output data stream
--*
--***************************************************************************************************************

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library UNISIM;
use UNISIM.VComponents.all;

entity outputEncoder is
  
  generic (
    frameSize   : integer := 8;         -- number of data items per frame
    minMatchLen : integer := 3;  -- minimal match length that will be encoded as length/offset pair
    maxMatchLen : integer := 16);  -- max allowed value for length (must not be bigger than 16)

  port (
    ClkxCI          : in  std_logic;
    RstxRI          : in  std_logic;    -- Active high sync reset
    OffsetxDI       : in  std_logic_vector(11 downto 0);  -- stream history offset for matches
    MatchLengthxDI  : in  integer range 0 to maxMatchLen;  -- stream match length in bytes
    EnxSI           : in  std_logic;    -- Process input data if high
    EndOfDataxSI    : in  std_logic;  -- flushes internal buffers and creates an end-of-data symbol
    LiteralxDI      : in  std_logic_vector(7 downto 0);  -- literal byte from the data stream to be encoded (needed if there was no match)
    BodyStrobexSO   : out std_logic;  -- strobe signal: is assert when a new item is available
    BodyOutxDO      : out std_logic_vector(7 downto 0);  -- encoded data output
    HeaderStrobexSO : out std_logic;
    HeaderOutxDO    : out std_logic_vector(frameSize-1 downto 0);
    DonexSO         : out std_logic);  -- indicates that the end of data symbol has been created

end outputEncoder;

architecture Behavorial of outputEncoder is

  
  signal suppressCntxDN, suppressCntxDP   : integer range 0 to maxMatchLen := 0;  -- data output supression for bytes that have already been encoded
  signal FlagBytexDN, FlagBytexDP         : std_logic_vector(frameSize-1 downto 0);  -- stores the literal / pair flags for 8 output bytes
  signal FlagCntxDN, FlagCntxDP           : integer range 0 to frameSize   := 0;  -- number of bytes in the output buffer
  signal HeaderStrobexSN, HeaderStrobexSP : std_logic                      := '0';
  signal DonexSN, DonexSP                 : std_logic                      := '0';

  signal suppressBytexS : std_logic := '0';
  signal EncodeAsPairxS : std_logic := '0';  -- signals that this match will be encoded as offset/length pair
  signal PairxD         : std_logic_vector(15 downto 0);  -- offset/length pair represented in two bytes

-- type outputBufferType is array (frameSize downto 0) of std_logic_vector(7 downto 0);  -- one more byte to store the overflow byte if we have a pair
--  signal OutBufxDN, OutBufxDP           : outputBufferType := (others => (others => '0'));  -- buffer to assemble compressed data blocks
  signal OutBufInxD                     : std_logic_vector(7 downto 0);  -- input byte for output buffer
  signal ShiftOutBufxS                  : std_logic;
  signal OverflowBufxDN, OverflowBufxDP : std_logic_vector(7 downto 0);
  signal OvfValidxSN, OvfValidxSP       : std_logic;
  --signal FlushxSN, FlushxSP             : std_logic;  -- indicates that buffers should be flushed (end of data processing)
  signal EndOfDataxSN, EndOfDataxSP     : std_logic := '0';  -- set when an end of data condition is detected

  
begin  -- Behavorial


  -- every match that is long enough will be encoded as offset/length pair
  EncodeAsPairxS <= '1' when MatchLengthxDI >= minMatchLen or EndOfDataxSI = '1' else '0';

  process (EndOfDataxSI, MatchLengthxDI, OffsetxDI)
  begin  -- process
    PairxD <= std_logic_vector(to_unsigned(MatchLengthxDI-1, 4)) & OffsetxDI;
  end process;

  -- purpose: implements an output data suppress counter for bytes which have already been encoded in a previous match
  suppressCntPrcs : process (EncodeAsPairxS, EnxSI, MatchLengthxDI,
                             suppressCntxDP)
  begin  -- process suppressCntPrcs
    suppressCntxDN <= suppressCntxDP;   -- default: do nothing
    suppressBytexS <= '0';
    if EnxSI = '1' then
      if suppressCntxDP > 0 then
        -- this byte has already been encoded -> suppress it
        suppressBytexS <= '1';
        suppressCntxDN <= suppressCntxDP - 1;
      else
        -- check if have to reload the counter
        if EncodeAsPairxS = '1' then
          suppressCntxDN <= MatchLengthxDI - 1;  -- -1 because this one byte is processed now, we suppress (discard) the next length-1 bytes
        end if;
      end if;
    end if;
  end process suppressCntPrcs;
  
  bufCntPrcs : process (DonexSP, EncodeAsPairxS, EndOfDataxSI, EndOfDataxSP,
                        EnxSI, FlagBytexDP, FlagCntxDP, LiteralxDI,
                        OverflowBufxDP, OvfValidxSP, PairxD, suppressBytexS)
  begin  -- process bufCntPrcs
    OutBufInxD      <= (others => '-');  -- use - to improve optimization
    OverflowBufxDN  <= OverflowBufxDP;
    FlagBytexDN     <= FlagBytexDP;
    OvfValidxSN     <= '0';
    ShiftOutBufxS   <= '0';
    FlagCntxDN      <= FlagCntxDP;
    HeaderStrobexSN <= '0';
    DonexSN         <= DonexSP;
    EndOfDataxSN    <= EndOfDataxSP or EndOfDataxSI;  -- remember an end-of-data condition
    if EnxSI = '1' and suppressBytexS = '0' and EndOfDataxSP = '0' then
      ShiftOutBufxS <= '1';
      if EncodeAsPairxS = '1' then
        -- we encode data as a pair, this means we have two bytes
        OverflowBufxDN          <= PairxD(7 downto 0);  -- save second byte in overflow buffer
        OutBufInxD              <= PairxD(15 downto 8);  -- big endian encoding
        FlagBytexDN(FlagCntxDP) <= '1';  -- mark bytes as offset/length pair
        OvfValidxSN             <= '1';  -- mark that we have a byte in the overflow buffer
        -- note: we don't check for end of frame here as the frame isn't over
        -- now (there is a second byte in the overflow buffer)
      else
        -- encode data as literal
        OutBufInxD              <= LiteralxDI;
        FlagBytexDN(FlagCntxDP) <= '0';
        -- check for end of frame
        if FlagCntxDP = frameSize-1 then
          FlagCntxDN      <= 0;
          HeaderStrobexSN <= '1';
        else
          FlagCntxDN <= FlagCntxDP + 1;
        end if;
      end if;
    end if;

    if OvfValidxSP = '1' then  -- this is ok, as we can not have two pairs on consecutive clock cycles (one pair encodes >= 3 bytes)
      -- copy byte from overflow buffer into output shift register
      OutBufInxD    <= OverflowBufxDP;
      ShiftOutBufxS <= '1';
      -- check for the end of a frame
      if FlagCntxDP = frameSize-1 then
        FlagCntxDN      <= 0;
        HeaderStrobexSN <= '1';
      else
        FlagCntxDN <= FlagCntxDP + 1;
      end if;
      if EndOfDataxSP = '1' then
        -- this is the very last byte in the stream
        HeaderStrobexSN <= '1';         -- send the last header byte(s)
        EndOfDataxSN    <= '0';  -- transmission of end of data flag is done
        DonexSN         <= '1';
      end if;
    end if;

    if EndOfDataxSP = '1' and OvfValidxSP = '0' and EnxSI = '0' then
      -- an end of data was requested, insert the eof symbol (length/offset pair with a length of zero)
      OverflowBufxDN          <= x"00";
      OvfValidxSN             <= '1';
      FlagBytexDN(FlagCntxDP) <= '1';
      OutBufInxD              <= x"00";
      ShiftOutBufxS           <= '1';
      
    end if;
    
  end process bufCntPrcs;

  BodyOutxDO      <= OutBufInxD;
  BodyStrobexSO   <= ShiftOutBufxS;
  HeaderOutxDO    <= FlagBytexDP;
  HeaderStrobexSO <= HeaderStrobexSP;
  DonexSO         <= DonexSP;

  -- purpose: implements the flip flops
  -- type   : sequential
  regs : process (ClkxCI)
  begin  -- process regs
    if ClkxCI'event and ClkxCI = '1' then  -- rising clock edge
      if RstxRI = '1' then
        suppressCntxDP  <= 0;
        FlagCntxDP      <= 0;
        OvfValidxSP     <= '0';
        OverflowBufxDP  <= (others => '0');
        EndOfDataxSP    <= '0';
        FlagBytexDP     <= (others => '0');
        HeaderStrobexSP <= '0';
        DonexSP         <= '0';
      else
        suppressCntxDP  <= suppressCntxDN;
        FlagCntxDP      <= FlagCntxDN;
        OvfValidxSP     <= OvfValidxSN;
        OverflowBufxDP  <= OverflowBufxDN;
        EndOfDataxSP    <= EndOfDataxSN;
        FlagBytexDP     <= FlagBytexDN;
        HeaderStrobexSP <= HeaderStrobexSN;
        DonexSP         <= DonexSN;
      end if;
    end if;
  end process regs;
  

end Behavorial;

