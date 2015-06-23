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
--* Version 1.0 - 2012/7/22 - LS
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
--* Descrambles encoded data output into proper data stream and buffers data in an FIFO.
--* Note: This unit can accept simulatinous input of body and header data.
--* However there must not be too much data input. The minimum is 16 cycles between
--* two assertions of HeaderStrobexSI. This is due to internal bandwidth
--* limitations. The only exception to this rule is the very last frame. However
--* no additional data is permitted after it until the reset signal was applied
--*
--***************************************************************************************************************

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library UNISIM;
use UNISIM.VComponents.all;


entity outputFIFO is
  
  generic (
    frameSize : integer := 8);          -- must be a multiple of 8

  port (
    ClkxCI          : in  std_logic;
    RstxRI          : in  std_logic;    -- active high
    BodyDataxDI     : in  std_logic_vector(7 downto 0);
    BodyStrobexSI   : in  std_logic;    -- strobe signal for data
    HeaderDataxDI   : in  std_logic_vector(frameSize-1 downto 0);
    HeaderStrobexSI : in  std_logic;
    BuffersEmptyxSO : out std_logic;  -- indicates that the internal data buffers are empty
    BufOutxDO       : out std_logic_vector(7 downto 0);
    OutputValidxSO  : out std_logic;
    RdStrobexSI     : in  std_logic;    -- read next word
    LengthxDO       : out integer range 0 to 1024);  -- number of bytes in the FIFO

end outputFIFO;

architecture Behavorial of outputFIFO is

  constant ADR_BIT_LEN : integer := 10;  -- fifo memory address bus width in bits (for byte addressing)
  constant DEPTH       : integer := 2**ADR_BIT_LEN;  -- Has to match value for range in LengthxDO and the BRam!

  constant TRANS_BUF_LEN : integer := (frameSize*2)+(frameSize/8);  -- we need frameSize/8 bytes for the
                                                                    -- header, plus frameSize*2 for the body

  type inBufType is array (0 to (frameSize*2)-1) of std_logic_vector(7 downto 0);  -- *2 because we can have two bytes per entry
  signal InputBufxDN, InputBufxDP         : inBufType                          := (others => (others => '0'));
  type transBufType is array (0 to TRANS_BUF_LEN-1) of std_logic_vector(7 downto 0);
  signal TransBufxDN, TransBufxDP         : transBufType                       := (others => (others => '0'));
  signal InBufCntxDN, InBufCntxDP         : integer range 0 to (frameSize*2)+1 := 0;  -- number of _bytes_ in buffer
  signal TransBufLenxDN, TransBufLenxDP   : integer range 0 to (frameSize*2)+1 := 0;
  signal TransBufBusyxS                   : std_logic;
  signal CopyReqxSN, CopyReqxSP           : std_logic                          := '0';
  signal HeaderInBufxDN, HeaderInBufxDP   : std_logic_vector(7 downto 0)       := x"00";
  signal BuffersEmptyxSN, BuffersEmptyxSP : std_logic                          := '0';

  signal BRamWexS    : std_logic_vector(3 downto 0);
  signal BRamWrInxD  : std_logic_vector(31 downto 0);
  signal BRamWrAdrxD : std_logic_vector(13 downto 0);
  signal BRamRdAdrxD : std_logic_vector(13 downto 0);
  signal BRamDOutxD  : std_logic_vector(31 downto 0);

  signal DoReadxS, DoWritexS            : std_logic;
  signal ReadLenxS, WriteLenxS          : integer range 0 to 3;  -- 0 -> 1 byte, 1 -> 2 bytes, ...
  signal LengthxDN, LengthxDP           : integer range 0 to DEPTH := 0;  -- count the number of bytes in the FIFO
  signal ReadPtrxDN, ReadPtrxDP         : integer range 0 to DEPTH := 0;
  signal WrPtrxDN, WrPtrxDP             : integer range 0 to DEPTH := 0;
  signal FifoInxD                       : std_logic_vector(15 downto 0);  -- data input to fifo
  signal FifoInSelxD                    : std_logic_vector(1 downto 0);  -- byte select for fifo data input
  signal OutputValidxSN, OutputValidxSP : std_logic                := '0';

  type transferFSMType is (ST_IDLE, ST_FIRST_SINGLE_BYTE, ST_COPY, ST_LAST_SINGLE_BYTE);
  signal StatexSN, StatexSP : transferFSMType := ST_IDLE;

  
begin  -- Behavorial

  -- implement data input buffer
  inBufPrcs : process (BodyDataxDI, BodyStrobexSI, CopyReqxSP, HeaderDataxDI,
                       HeaderInBufxDP, HeaderStrobexSI, InBufCntxDP,
                       InputBufxDP, StatexSP, TransBufBusyxS) 
  begin
    InBufCntxDN    <= InBufCntxDP;
    InputBufxDN    <= InputBufxDP;
    CopyReqxSN     <= CopyReqxSP and TransBufBusyxS;
    HeaderInBufxDN <= HeaderInBufxDP;
    if BodyStrobexSI = '1' then
      if InBufCntxDP < (frameSize*2) then
        InBufCntxDN              <= InBufCntxDP + 1;
        InputBufxDN(InBufCntxDP) <= BodyDataxDI;
      else
        assert false report "Buffer overflow in data input buffer of output FIFO" severity error;
      end if;
    end if;
    if HeaderStrobexSI = '1' then
      if TransBufBusyxS = '0' then
        InBufCntxDN <= 0;               -- reset for next frame
      else
        CopyReqxSN     <= '1';  -- can't copy right now, remember to do that
        HeaderInBufxDN <= HeaderDataxDI;
      end if;
    end if;
    if StatexSP = ST_IDLE and CopyReqxSP = '1' then
      -- the requested copy operation starts now, reset counter
      InBufCntxDN <= 0;
    end if;
  end process inBufPrcs;

  -- purpose: implement transfer buffer (shift reg) and the state machine which copies the
  -- data into the fifo.
  transBufPrcs : process (BodyStrobexSI, CopyReqxSP, HeaderDataxDI,
                          HeaderInBufxDP, HeaderStrobexSI, InBufCntxDP,
                          InputBufxDP, LengthxDP, StatexSP, TransBufLenxDP,
                          TransBufxDP, WrPtrxDP)
  begin
    TransBufxDN    <= TransBufxDP;
    TransBufLenxDN <= TransBufLenxDP;
    StatexSN       <= StatexSP;         -- default: keep current state
    DoWritexS      <= '0';              -- default: do nothing
    FifoInxD       <= (others => '-');
    FifoInSelxD    <= "00";
    WriteLenxS     <= 0;
    TransBufBusyxS <= '0';

    case StatexSP is
      when ST_IDLE =>
        if (HeaderStrobexSI = '1' or CopyReqxSP = '1') and InBufCntxDP > 1 then
          -- we must have at least one data byte in the frame
          -- assert InBufCntxDN > 0 report "Transfer FSM: Atempted illegal transfer of frame without data" severity warning;
          -- copy data from the input buffer into transfer buffer
          for i in 1 to TRANS_BUF_LEN-1 loop
            TransBufxDN(i) <= InputBufxDP(i-1);
          end loop;  -- i
          if HeaderStrobexSI = '1' then
            -- the header is coming in right now -> copy from input signal
            TransBufxDN(0) <= HeaderDataxDI;
          else
            -- this must be an transfer requested earlier -> copy header from buffer
            TransBufxDN(0) <= HeaderInBufxDP;
          end if;
          if BodyStrobexSI = '0' then
            TransBufLenxDN <= InBufCntxDP + (frameSize/8);  -- frameSize / 8 is the header length
          else
            TransBufLenxDN <= InBufCntxDP + (frameSize/8) + 1;  -- frameSize / 8 is the header length
          end if;
          -- Note: we know we have at least two bytes (header + data) therefore
          -- it is save to move to ST_COPY
          if WrPtrxDP mod 2 = 1 then
            -- we have an odd byte location -> transfer single byte first
            StatexSN <= ST_FIRST_SINGLE_BYTE;
          else
            StatexSN <= ST_COPY;
          end if;
        end if;

      when ST_FIRST_SINGLE_BYTE =>
        TransBufBusyxS <= '1';
        if LengthxDP < DEPTH-1 then  -- make sure we have enough space for 2 bytes in fifo
          -- copy one byte from the transfer buffer to the fifo
          FifoInxD    <= TransBufxDP(0) & x"00";
          FifoInSelxD <= "10";
          DoWritexS   <= '1';
          WriteLenxS  <= 1;
          if TransBufLenxDP > 2 then
            StatexSN <= ST_COPY;  -- we have more than one byte left, do dual byte copy
          else
            StatexSN <= ST_LAST_SINGLE_BYTE;  -- only one byte left in frame
          end if;
          -- shift the transfer buffer one byte
          for i in 0 to TRANS_BUF_LEN-2 loop
            TransBufxDN(i) <= TransBufxDP(i+1);
          end loop;  -- i
          TransBufxDN(TRANS_BUF_LEN-1) <= x"00";  -- to make simulation look nice :)
          TransBufLenxDN               <= TransBufLenxDP - 1;
        end if;
        
      when ST_COPY =>
        TransBufBusyxS <= '1';
        if LengthxDP < DEPTH-1 then  -- make sure we have enough space for 2 bytes in fifo
          assert TransBufLenxDP >= 2 report "ST_COPY: not enough data in transfer buffer to perform copy operation" severity error;
          FifoInxD       <= TransBufxDP(1) & TransBufxDP(0);
          FifoInSelxD    <= "11";
          DoWritexS      <= '1';
          WriteLenxS     <= 2;
          TransBufLenxDN <= TransBufLenxDP - 2;  -- we copy two bytes here
          for i in 0 to TRANS_BUF_LEN-3 loop
            -- shift buffer two bytes 
            TransBufxDN(i) <= TransBufxDP(i+2);
          end loop;  -- i
          if TransBufLenxDP = 2 then
            StatexSN <= ST_IDLE;  -- this were the last two bytes -> we are done
          elsif TransBufLenxDP = 3 then
            StatexSN <= ST_LAST_SINGLE_BYTE;  -- handle last byte as special case
          end if;
        end if;

      when ST_LAST_SINGLE_BYTE =>
        TransBufBusyxS <= '1';
        if LengthxDP < DEPTH-1 then  -- make sure we have enough space for 2 bytes in fifo
          assert TransBufLenxDP = 1 report "ST_LAST_SINGLE_BYTE: TransBufLenxDP is not 1" severity error;
          FifoInxD       <= x"00" & TransBufxDP(0);  -- copy last byte
          FifoInSelxD    <= "01";
          TransBufLenxDN <= 0;
          DoWritexS      <= '1';
          WriteLenxS     <= 1;
          StatexSN       <= ST_IDLE;    -- transfer is done
        end if;
      when others => null;
    end case;
  end process transBufPrcs;

  BuffersEmptyxSN <= '1' when InBufCntxDP = 0 and TransBufLenxDP = 0 else '0';
  BuffersEmptyxSO <= BuffersEmptyxSP;

  -- implement write pointer counter
  wrPortDemuxPrcs : process (DoWritexS, FifoInSelxD, FifoInxD, WrPtrxDP,
                             WriteLenxS)
  begin
    WrPtrxDN    <= WrPtrxDP;
    BRamWrInxD  <= x"0000" & FifoInxD;
    BRamWrAdrxD <= "0" & std_logic_vector(to_unsigned(WrPtrxDP/2, ADR_BIT_LEN-1)) & "0000";
    BRamWexS    <= "00" & FifoInSelxD;
    -- implement a write pointer that overflows when we reach the end of the fifo memory
    if DoWritexS = '1' then
      if (WrPtrxDP + WriteLenxS) < DEPTH then
        WrPtrxDN <= WrPtrxDP + WriteLenxS;
      else
        WrPtrxDN <= WrPtrxDP + WriteLenxS - DEPTH;
      end if;
    end if;
  end process wrPortDemuxPrcs;


  -- purpose: implement read port related logic
  readPrcs : process (LengthxDP, RdStrobexSI, ReadPtrxDP)
  begin
    ReadPtrxDN     <= ReadPtrxDP;
    DoReadxS       <= '0';
    ReadLenxS      <= 0;
    OutputValidxSN <= '0';
    BRamRdAdrxD    <= "0" & std_logic_vector(to_unsigned(ReadPtrxDP, ADR_BIT_LEN)) & "000";
    -- suppress illeagal read attempts (when the fifo is empty)
    if RdStrobexSI = '1' and LengthxDP > 0 then
      DoReadxS       <= '1';
      ReadLenxS      <= 1;
      OutputValidxSN <= '1';            -- read takes one cycle
      -- implement read pointer
      if ReadPtrxDP < DEPTH-1 then
        ReadPtrxDN <= ReadPtrxDP + 1;
      else
        ReadPtrxDN <= 0;
      end if;
    end if;
  end process readPrcs;

  -- purpose: Count the number of _bytes_ currently stored in the FIFO
  lenCntPrcs : process (DoReadxS, DoWritexS, LengthxDP, ReadLenxS, WriteLenxS)
  begin  -- process LenCntPrcs
    LengthxDN <= LengthxDP;             -- default: do nothing
    if DoReadxS = '1' and DoWritexS = '0' and LengthxDP > 0 then
      LengthxDN <= LengthxDP - ReadLenxS;
      -- byte -> different encoding for ReadLen, see signal definition
    end if;
    if DoReadxS = '0' and DoWritexS = '1' and LengthxDP < DEPTH then
      LengthxDN <= LengthxDP + WriteLenxS;
    end if;
    if DoReadxS = '1' and DoWritexS = '1' then
      LengthxDN <= LengthxDP + WriteLenxS - ReadLenxS;
    end if;
    
  end process LenCntPrcs;

  BufOutxDO      <= BRamDOutxD(7 downto 0);
  LengthxDO      <= LengthxDP;
  OutputValidxSO <= OutputValidxSP;
  --SelxSO    <= ReadSelxS;


  -- purpose: implement the registers
  -- type   : sequential
  process (ClkxCI, RstxRI)
  begin  -- process
    if ClkxCI'event and ClkxCI = '1' then  -- rising clock edge then
      if RstxRI = '1' then

        InBufCntxDP     <= 0;
        LengthxDP       <= 0;
        TransBufLenxDP  <= 0;
        CopyReqxSP      <= '0';
        LengthxDP       <= 0;
        WrPtrxDP        <= 0;
        ReadPtrxDP      <= 0;
        OutputValidxSP  <= '0';
        BuffersEmptyxSP <= '0';
        StatexSP        <= ST_IDLE;
      else
        InputBufxDP     <= InputBufxDN;
        InBufCntxDP     <= InBufCntxDN;
        TransBufxDP     <= TransBufxDN;
        TransBufLenxDP  <= TransBufLenxDN;
        CopyReqxSP      <= CopyReqxSN;
        HeaderInBufxDP  <= HeaderInBufxDN;
        LengthxDP       <= LengthxDN;
        WrPtrxDP        <= WrPtrxDN;
        ReadPtrxDP      <= ReadPtrxDN;
        OutputValidxSP  <= OutputValidxSN;
        BuffersEmptyxSP <= BuffersEmptyxSN;
        StatexSP        <= StatexSN;
      end if;
    end if;
  end process;


  FifoBRam : RAMB16BWER
    generic map (
      -- DATA_WIDTH_A/DATA_WIDTH_B: 0, 1, 2, 4, 9, 18, or 36
      DATA_WIDTH_A        => 18,
      DATA_WIDTH_B        => 9,
      -- DOA_REG/DOB_REG: Optional output register (0 or 1)
      DOA_REG             => 0,
      DOB_REG             => 0,
      -- EN_RSTRAM_A/EN_RSTRAM_B: Enable/disable RST
      EN_RSTRAM_A         => true,
      EN_RSTRAM_B         => true,
      -- INIT_A/INIT_B: Initial values on output port
      INIT_A              => X"000000000",
      INIT_B              => X"000000000",
      -- INIT_FILE: Optional file used to specify initial RAM contents
      INIT_FILE           => "NONE",
      -- RSTTYPE: "SYNC" or "ASYNC" 
      RSTTYPE             => "SYNC",
      -- RST_PRIORITY_A/RST_PRIORITY_B: "CE" or "SR" 
      RST_PRIORITY_A      => "CE",
      RST_PRIORITY_B      => "CE",
      -- SIM_COLLISION_CHECK: Collision check enable "ALL", "WARNING_ONLY", "GENERATE_X_ONLY" or "NONE" 
      SIM_COLLISION_CHECK => "ALL",
      -- SIM_DEVICE: Must be set to "SPARTAN6" for proper simulation behavior
      SIM_DEVICE          => "SPARTAN6",
      -- SRVAL_A/SRVAL_B: Set/Reset value for RAM output
      SRVAL_A             => X"000000000",
      SRVAL_B             => X"000000000",
      -- WRITE_MODE_A/WRITE_MODE_B: "WRITE_FIRST", "READ_FIRST", or "NO_CHANGE" 
      WRITE_MODE_A        => "WRITE_FIRST",
      WRITE_MODE_B        => "WRITE_FIRST"
      )
    port map (
      -- Port A Data: 32-bit (each) Port A data
      DOA    => open,                   -- 32-bit A port data output
      DOPA   => open,                   -- 4-bit A port parity output
      -- Port B Data: 32-bit (each) Port B data
      DOB    => BRamDOutxD,             -- 32-bit B port data output
      DOPB   => open,                   -- 4-bit B port parity output
      -- Port A Address/Control Signals: 14-bit (each) Port A address and control signals
      ADDRA  => BRamWrAdrxD,            -- 14-bit A port address input
      CLKA   => ClkxCI,                 -- 1-bit A port clock input
      ENA    => DoWritexS,              -- 1-bit A port enable input
      REGCEA => '1',          -- 1-bit A port register clock enable input
      RSTA   => RstxRI,       -- 1-bit A port register set/reset input
      WEA    => BRamWexS,     -- 4-bit Port A byte-wide write enable input
      -- Port A Data: 32-bit (each) Port A data
      DIA    => BRamWrInxD,             -- 32-bit A port data input
      DIPA   => "0000",                 -- 4-bit A port parity input
      -- Port B Address/Control Signals: 14-bit (each) Port B address and control signals
      ADDRB  => BRamRdAdrxD,            -- 14-bit B port address input
      CLKB   => ClkxCI,                 -- 1-bit B port clock input
      ENB    => DoReadxS,               -- 1-bit B port enable input
      REGCEB => '1',          -- 1-bit B port register clock enable input
      RSTB   => RstxRI,       -- 1-bit B port register set/reset input
      WEB    => "0000",       -- 4-bit Port B byte-wide write enable input
      -- Port B Data: 32-bit (each) Port B data
      DIB    => x"00000000",            -- 32-bit B port data input
      DIPB   => "0000"                  -- 4-bit B port parity input
      );


end Behavorial;
