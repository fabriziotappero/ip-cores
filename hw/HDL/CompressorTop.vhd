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
--* Version 1.0 - 2012/10/16 - LS
--*   started file
--*
--* Version 1.0 - 2013/04/05 - LS
--*   released
--*
--***************************************************************************************************************
--*
--* Naming convention:  http://dz.ee.ethz.ch/en/information/hdl-help/vhdl-naming-conventions.html
--*
--***************************************************************************************************************
--*
--* Top level file for data compressor. Implements the wishbone interfaces, a
--* simple DMA controller and some glue logic.
--*
--***************************************************************************************************************
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library UNISIM;
use UNISIM.VComponents.all;

entity CompressorTop is
  port (
    ClkxCI   : in  std_logic;
    RstxRI   : in  std_logic;
    -- wishbone config and data input interface (32 bit access only!!)
    SlCycxSI : in  std_logic;
    SlStbxSI : in  std_logic;
    SlWexSI  : in  std_logic;
    SlSelxDI : in  std_logic_vector(3 downto 0);
    SlAdrxDI : in  std_logic_vector(4 downto 2);
    SlDatxDI : in  std_logic_vector(31 downto 0);
    SlDatxDO : out std_logic_vector(31 downto 0);
    SlAckxSO : out std_logic;
    SlErrxSO : out std_logic;
    IntxSO   : out std_logic;
    -- wishbone dma master interface
    MaCycxSO : out std_logic;
    MaStbxSO : out std_logic;
    MaWexSO  : out std_logic;
    MaSelxDO : out std_logic_vector(3 downto 0);
    MaAdrxDO : out std_logic_vector(31 downto 0);
    MaDatxDO : out std_logic_vector(31 downto 0);
    MaDatxDI : in  std_logic_vector(31 downto 0);
    MaAckxSI : in  std_logic;
    MaErrxSI : in  std_logic
    );  
end CompressorTop;

architecture Behavioral of CompressorTop is

  component InputFIFO
    port (
      ClkxCI        : in  std_logic;
      RstxRI        : in  std_logic;
      DInxDI        : in  std_logic_vector(31 downto 0);
      WExSI         : in  std_logic;
      StopOutputxSI : in  std_logic;
      BusyxSO       : out std_logic;
      DOutxDO       : out std_logic_vector(7 downto 0);
      OutStrobexSO  : out std_logic;
      LengthxDO     : out integer range 0 to 2048);
  end component;

  component LZRWcompressor
    port (
      ClkxCI         : in  std_logic;
      RstxRI         : in  std_logic;
      DataInxDI      : in  std_logic_vector(7 downto 0);
      StrobexSI      : in  std_logic;
      FlushBufxSI    : in  std_logic;
      BusyxSO        : out std_logic;
      DonexSO        : out std_logic;
      BufOutxDO      : out std_logic_vector(7 downto 0);
      OutputValidxSO : out std_logic;
      RdStrobexSI    : in  std_logic;
      LengthxDO      : out integer range 0 to 1024);
  end component;

  constant INPUT_FIFO_SIZE : integer := 1024;  -- length of input fifo in bytes
  constant DMA_LEN_SIZE    : integer := 16;  -- size of dma len counter in bits
  --constant MAX_DMA_LEN_VALUE : integer := 2**16-1;  -- maximum value of the dma length counter

  signal RstCorexSN, RstCorexSP : std_logic := '1';
  signal WeInFIFOxS             : std_logic;
  signal InFIFOLenxD            : integer range 0 to INPUT_FIFO_SIZE;

  signal CoreBusyxS                 : std_logic;
  signal CoreDonexS                 : std_logic;
  signal CoreDatInxD                : std_logic_vector(7 downto 0);
  signal CoreStbxS                  : std_logic;
  signal FIFOBusyxS                 : std_logic;
  signal FlushxSN, FlushxSP         : std_logic := '0';
  signal FlushCorexSN, FlushCorexSP : std_logic := '0';
  signal CoreRdStbxS                : std_logic;
  signal OutFIFOLenxD               : integer range 0 to 1024;
  signal CoreDatOutxD               : std_logic_vector(7 downto 0);
  signal CoreOutValidxS             : std_logic;

  signal ClearIntFlagsxSN, ClearIntFlagsxSP      : std_logic                     := '0';
  signal ClearInFIFOFlagsxS, ClearOutFIFOFlagsxS : std_logic;
  signal InFIFOEmptyFlgxSN, InFIFOEmptyFlgxSP    : std_logic                     := '0';
  signal InFIFOFullFlgxSN, InFIFOFullFlgxSP      : std_logic                     := '0';
  signal OutFIFOEmptyFlgxSN, OutFIFOEmptyFlgxSP  : std_logic                     := '0';
  signal OutFIFOFullFlgxSN, OutFIFOFullFlgxSP    : std_logic                     := '0';
  signal IEInFIFOEmptyxSN, IEInFIFOEmptyxSP      : std_logic                     := '0';
  signal IEInFIFOFullxSN, IEInFIFOFullxSP        : std_logic                     := '0';
  signal IEOutFIFOEmptyxSN, IEOutFIFOEmptyxSP    : std_logic                     := '0';
  signal IEOutFIFOFullxSN, IEOutFIFOFullxSP      : std_logic                     := '0';
  signal IEDmaErrxSN, IEDmaErrxSP                : std_logic                     := '0';
  signal IECoreDonexSN, IECoreDonexSP            : std_logic                     := '0';
  signal IRQxSN, IRQxSP                          : std_logic                     := '0';
  signal InFIFOEmptyThrxDN, InFIFOEmptyThrxDP    : std_logic_vector(15 downto 0) := (others => '0');
  signal InFIFOFullThrxDN, InFIFOFullThrxDP      : std_logic_vector(15 downto 0) := (others => '1');
  signal OutFIFOEmptyThrxDN, OutFIFOEmptyThrxDP  : std_logic_vector(15 downto 0) := (others => '0');
  signal OutFIFOFullThrxDN, OutFIFOFullThrxDP    : std_logic_vector(15 downto 0) := (others => '1');

  signal IncDestAdrFlgxSN, IncDestAdrFlgxSP : std_logic                            := '0';
  signal DmaErrFlgxSN, DmaErrFlgxSP         : std_logic                            := '0';
  signal WrDmaDestAdrxS                     : std_logic;
  signal WrDmaLenxS                         : std_logic;
  signal DmaBusyxSN, DmaBusyxSP             : std_logic                            := '0';
  signal DmaDestAdrxDN, DmaDestAdrxDP       : std_logic_vector(31 downto 0)        := (others => '0');
  signal XferByteCntxDN, XferByteCntxDP     : integer range 0 to 4                 := 0;
  signal DmaLenxDN, DmaLenxDP               : integer range 0 to 2**DMA_LEN_SIZE-1 := 0;
  signal DmaDataOutxDN, DmaDataOutxDP       : std_logic_vector(31 downto 0)        := (others => '0');
  signal DmaSelxSN, DmaSelxSP               : std_logic_vector(3 downto 0)         := (others => '0');
  signal MaCycxSN, MaCycxSP                 : std_logic                            := '0';
  signal MaStbxSN, MaStbxSP                 : std_logic                            := '0';
  
begin  -- Behavioral

  WbSlInPrcs : process (DmaBusyxSP, FlushCorexSP, FlushxSP, IECoreDonexSP,
                        IEDmaErrxSP, IEInFIFOEmptyxSP, IEInFIFOFullxSP,
                        IEOutFIFOEmptyxSP, IEOutFIFOFullxSP, InFIFOEmptyThrxDP,
                        InFIFOFullThrxDP, IncDestAdrFlgxSP, OutFIFOEmptyThrxDP,
                        OutFIFOFullThrxDP, SlAdrxDI, SlCycxSI, SlDatxDI,
                        SlStbxSI, SlWexSI)
  begin
    WeInFIFOxS          <= '0';
    RstCorexSN          <= '0';
    FlushxSN            <= FlushxSP and not FlushCorexSP;  -- clear flush flag when core is flushed
    ClearInFIFOFlagsxS  <= '0';
    ClearOutFIFOFlagsxS <= '0';
    ClearIntFlagsxSN    <= '0';
    IEInFIFOEmptyxSN    <= IEInFIFOEmptyxSP;
    IEInFIFOFullxSN     <= IEInFIFOFullxSP;
    IEOutFIFOEmptyxSN   <= IEOutFIFOEmptyxSP;
    IEOutFIFOFullxSN    <= IEOutFIFOFullxSP;
    IEDmaErrxSN         <= IEDmaErrxSP;
    IECoreDonexSN       <= IECoreDonexSP;
    IncDestAdrFlgxSN    <= IncDestAdrFlgxSP;
    InFIFOEmptyThrxDN   <= InFIFOEmptyThrxDP;
    InFIFOFullThrxDN    <= InFIFOFullThrxDP;
    OutFIFOFullThrxDN   <= OutFIFOFullThrxDP;
    OutFIFOEmptyThrxDN  <= OutFIFOEmptyThrxDP;
    WrDmaDestAdrxS      <= '0';
    WrDmaLenxS          <= '0';

    -- decode write commands
    if SlCycxSI = '1' and SlStbxSI = '1' and SlWexSI = '1' then
      case SlAdrxDI is
        when "000" =>                   -- data input register
          if FlushxSP = '0' then        -- ignore all data after flush command was sent
            WeInFIFOxS <= '1';
          end if;
          
        when "001" =>                   -- config flags
          if DmaBusyxSP = '0' then
            IncDestAdrFlgxSN <= SlDatxDI(8);
          end if;
          IEInFIFOEmptyxSN  <= SlDatxDI(16);
          IEInFIFOFullxSN   <= SlDatxDI(17);
          IEOutFIFOEmptyxSN <= SlDatxDI(18);
          IEOutFIFOFullxSN  <= SlDatxDI(19);
          IEDmaErrxSN       <= SlDatxDI(20);
          IECoreDonexSN     <= SlDatxDI(21);
          ClearIntFlagsxSN  <= '1';
          
        when "010" =>
          InFIFOFullThrxDN   <= SlDatxDI(31 downto 16);
          InFIFOEmptyThrxDN  <= SlDatxDI(15 downto 0);
          ClearInFIFOFlagsxS <= '1';

        when "011" =>
          OutFIFOFullThrxDN   <= SlDatxDI(31 downto 16);
          OutFIFOEmptyThrxDN  <= SlDatxDI(15 downto 0);
          ClearOutFIFOFlagsxS <= '1';

        when "100" =>
          -- may only be written if dma unit is not busy
          if DmaBusyxSP = '0' then
            WrDmaDestAdrxS <= '1';
          end if;
          
        when "101" =>
          if DmaBusyxSP = '0' then
            WrDmaLenxS <= '1';
          end if;

        when "111" =>                   -- command register
          if SlDatxDI(0) = '1' then
            -- reset command
            RstCorexSN          <= SlDatxDI(0);
            ClearInFIFOFlagsxS  <= '1';
            ClearOutFIFOFlagsxS <= '1';
          end if;
          FlushxSN <= SlDatxDI(1) or FlushxSP;
          
        when others => null;
      end case;
    end if;
  end process WbSlInPrcs;

  -- we flush the core if a flush was requested and the intput fifo is empty
  FlushCorexSN <= '1' when FlushxSP = '1' and InFIFOLenxD = 0 else '0';
  

  process (CoreDonexS, DmaBusyxSP, DmaDestAdrxDP, DmaErrFlgxSP, DmaLenxDP,
           IECoreDonexSP, IEDmaErrxSP, IEInFIFOEmptyxSP, IEInFIFOFullxSP,
           IEOutFIFOEmptyxSP, IEOutFIFOFullxSP, InFIFOEmptyFlgxSP,
           InFIFOEmptyThrxDP, InFIFOFullFlgxSP, InFIFOFullThrxDP, InFIFOLenxD,
           IncDestAdrFlgxSP, OutFIFOEmptyFlgxSP, OutFIFOEmptyThrxDP,
           OutFIFOFullFlgxSP, OutFIFOFullThrxDN, OutFIFOLenxD, SlAdrxDI,
           SlCycxSI, SlStbxSI, SlWexSI, XferByteCntxDP)
  begin  --
    
    SlDatxDO <= x"00000000";
    -- decode read commands
    if SlCycxSI = '1' and SlStbxSI = '1' and SlWexSI = '0' then
      case SlAdrxDI is
        when "000" => null;             -- data input, no read access

        when "001" =>                         -- config and status reg
          SlDatxDO(3)  <= DmaBusyxSP;
          SlDatxDO(8)  <= IncDestAdrFlgxSP;   -- config flags
          SlDatxDO(16) <= IEInFIFOEmptyxSP;   -- interrupt enables
          SlDatxDO(17) <= IEInFIFOFullxSP;
          SlDatxDO(18) <= IEOutFIFOEmptyxSP;
          SlDatxDO(19) <= IEOutFIFOFullxSP;
          SlDatxDO(20) <= IEDmaErrxSP;
          SlDatxDO(21) <= IECoreDonexSP;
          SlDatxDO(24) <= InFIFOEmptyFlgxSP;  -- interrupt flags
          SlDatxDO(25) <= InFIFOFullFlgxSP;
          SlDatxDO(26) <= OutFIFOEmptyFlgxSP;
          SlDatxDO(27) <= OutFIFOFullFlgxSP;
          SlDatxDO(28) <= DmaErrFlgxSP;
          SlDatxDO(29) <= CoreDonexS;
          --ClearIntFlagsxSN <= '1';

        when "010" => SlDatxDO <= InFIFOFullThrxDP & InFIFOEmptyThrxDP;

        when "011" => SlDatxDO <= OutFIFOFullThrxDN & OutFIFOEmptyThrxDP;

        when "100" => SlDatxDO <= DmaDestAdrxDP(31 downto 2) & std_logic_vector(to_unsigned(XferByteCntxDP, 2));

        when "101" => SlDatxDO <= x"0000" & std_logic_vector(to_unsigned(DmaLenxDP, DMA_LEN_SIZE));

        when "110" => SlDatxDO <= std_logic_vector(to_unsigned(OutFIFOLenxD, 16)) & std_logic_vector(to_unsigned(InFIFOLenxD, 16));

        when others => null;
      end case;
    end if;
    
  end process;


  -- create an ACK on slave bus for all 32bits accesses. Other types of
  -- accesses are not possible -> terminate with error signal
  SlAckxSO <= SlCycxSI and SlStbxSI when SlSelxDI = "1111" else '0';
  SlErrxSO <= SlCycxSI and SlStbxSI when SlSelxDI /= "1111" else '0';
  

  InterruptsPrcs : process (ClearInFIFOFlagsxS, ClearIntFlagsxSP,
                            ClearOutFIFOFlagsxS, CoreDonexS, DmaErrFlgxSP,
                            IECoreDonexSP, IEDmaErrxSP, IEInFIFOEmptyxSP,
                            IEInFIFOFullxSP, IEOutFIFOEmptyxSP,
                            IEOutFIFOFullxSP, InFIFOEmptyFlgxSP,
                            InFIFOEmptyThrxDP, InFIFOFullFlgxSP,
                            InFIFOFullThrxDP, InFIFOLenxD, OutFIFOEmptyFlgxSP,
                            OutFIFOEmptyThrxDP, OutFIFOFullFlgxSP,
                            OutFIFOFullThrxDP, OutFIFOLenxD)
  begin
    InFIFOEmptyFlgxSN  <= InFIFOEmptyFlgxSP;
    InFIFOFullFlgxSN   <= InFIFOFullFlgxSP;
    OutFIFOEmptyFlgxSN <= OutFIFOEmptyFlgxSP;
    OutFIFOFullFlgxSN  <= OutFIFOFullFlgxSP;

    if ClearInFIFOFlagsxS = '0' then
      if InFIFOLenxD < to_integer(unsigned(InFIFOEmptyThrxDP)) then
        InFIFOEmptyFlgxSN <= '1';
      end if;

      if InFIFOLenxD >= to_integer(unsigned(InFIFOFullThrxDP)) then
        InFIFOFullFlgxSN <= '1';
      end if;
    else
      InFIFOEmptyFlgxSN <= '0';
      InFIFOFullFlgxSN  <= '0';
    end if;

    if ClearOutFIFOFlagsxS = '0' then
      if OutFIFOLenxD < to_integer(unsigned(OutFIFOEmptyThrxDP)) then
        OutFIFOEmptyFlgxSN <= '1';
      end if;

      if OutFIFOLenxD >= to_integer(unsigned(OutFIFOFullThrxDP)) then
        OutFIFOFullFlgxSN <= '1';
      end if;
    else
      OutFIFOEmptyFlgxSN <= '0';
      OutFIFOFullFlgxSN  <= '0';
    end if;

    if ClearIntFlagsxSP = '1' then
      InFIFOEmptyFlgxSN  <= '0';
      InFIFOFullFlgxSN   <= '0';
      OutFIFOEmptyFlgxSN <= '0';
      OutFIFOFullFlgxSN  <= '0';
    end if;

    IRQxSN <= (InFIFOEmptyFlgxSP and IEInFIFOEmptyxSP) or
              (InFIFOFullFlgxSP and IEInFIFOFullxSP) or
              (OutFIFOEmptyFlgxSP and IEOutFIFOEmptyxSP) or
              (OutFIFOFullFlgxSP and IEOutFIFOFullxSP) or
              (DmaErrFlgxSP and IEDmaErrxSP) or
              (CoreDonexS and IECoreDonexSP);
  end process InterruptsPrcs;

  IntxSO <= IRQxSP;
  

  DmaPrcs : process (ClearIntFlagsxSP, CoreDatOutxD, CoreOutValidxS,
                     DmaDataOutxDP, DmaDestAdrxDP, DmaErrFlgxSP, DmaLenxDP,
                     DmaSelxSP, IncDestAdrFlgxSP, MaAckxSI, MaCycxSP, MaErrxSI,
                     MaStbxSP, OutFIFOLenxD, RstCorexSP, SlDatxDI,
                     WrDmaDestAdrxS, WrDmaLenxS, XferByteCntxDP)
  begin
    DmaLenxDN      <= DmaLenxDP;
    DmaDestAdrxDN  <= DmaDestAdrxDP;
    XferByteCntxDN <= XferByteCntxDP;
    DmaDataOutxDN  <= DmaDataOutxDP;
    DmaSelxSN      <= DmaSelxSP;
    CoreRdStbxS    <= '0';
    MaCycxSN       <= MaCycxSP;
    MaStbxSN       <= MaStbxSP;
    DmaErrFlgxSN   <= DmaErrFlgxSP;

    -- if len is not zero dma unit is busy with a transfer
    if DmaLenxDP = 0 then
      DmaBusyxSN <= '0';
      if WrDmaDestAdrxS = '1' then
        -- the last two bits specify at which byte within the 4 byte wide bus
        -- we start -> load them into the transfer byte counter
        DmaDestAdrxDN  <= SlDatxDI(31 downto 2) & "00";
        XferByteCntxDN <= to_integer(unsigned(SlDatxDI(1 downto 0)));
        DmaSelxSN      <= (others => '0');
      end if;
      if WrDmaLenxS = '1' then
        DmaLenxDN <= to_integer(unsigned(SlDatxDI(DMA_LEN_SIZE-1 downto 0)));
      end if;
      
    else
      if RstCorexSP = '1' then
        -- abort the dma operation
        DmaLenxDN  <= 0;
        MaCycxSN   <= '0';
        MaStbxSN   <= '0';
        DmaBusyxSN <= '0';
      else
        
        DmaBusyxSN <= '1';

        -- wait until the last wishbone transfer is done
        if MaCycxSP = '0' then
          -- read data from output fifo when it becomes available
          if OutFIFOLenxD > 0 then
            -- output a read strobe if there is room for more than one byte
            -- (check dma length counter and transfer byte counter). This condition is
            -- loosened if there is no byte comming in this cycle
            if (XferByteCntxDP < 3 and DmaLenxDP > 1) or CoreOutValidxS = '0' then
              -- send read request to core
              CoreRdStbxS <= '1';
            end if;
          end if;

          if CoreOutValidxS = '1' then
            -- copy byte from core into output buffer
            DmaLenxDN <= DmaLenxDP - 1;
            if IncDestAdrFlgxSP = '1' and XferByteCntxDP < 4 then
              XferByteCntxDN <= XferByteCntxDP + 1;
            end if;
            DmaDataOutxDN((XferByteCntxDP+1)*8-1 downto XferByteCntxDP*8) <= CoreDatOutxD;
            DmaSelxSN(XferByteCntxDP)                                     <= '1';
            -- if we write the last byte (end of buffer or end of fifo or end of dma len) address or we have a don't inc
            -- transfer we create a whishbone cycle
            if XferByteCntxDP = 3 or IncDestAdrFlgxSP = '0' or DmaLenxDP = 1 or OutFIFOLenxD = 0 then
              MaCycxSN <= '1';
              MaStbxSN <= '1';
            end if;
          end if;
        end if;
      end if;
    end if;

    -- wait for an ack or err from the slave
    if MaAckxSI = '1' then
      -- transfer is done, deassert signals
      MaCycxSN  <= '0';
      MaStbxSN  <= '0';
      DmaSelxSN <= (others => '0');     -- reset sel signals for next transfer
      if XferByteCntxDP = 4 then
        XferByteCntxDN <= 0;
        -- inc destination address to the next word
        if IncDestAdrFlgxSP = '1' then
          DmaDestAdrxDN <= std_logic_vector(to_unsigned(to_integer(unsigned(DmaDestAdrxDP))+4, 32));
        end if;
      end if;
    end if;
    if MaErrxSI = '1' then
      -- transfer is done, deassert signals
      MaCycxSN     <= '0';
      MaStbxSN     <= '0';
      -- an whishbone error occured, abort dma transfer
      DmaLenxDN    <= 0;
      DmaErrFlgxSN <= '1';
    end if;

    if ClearIntFlagsxSP = '1' then
      DmaErrFlgxSN <= '0';
    end if;
  end process DmaPrcs;

  MaCycxSO <= MaCycxSP;
  MaStbxSO <= MaStbxSP;
  MaSelxDO <= DmaSelxSP;
  MaDatxDO <= DmaDataOutxDP;
  MaAdrxDO <= DmaDestAdrxDP;
  MaWexSO  <= '1';  -- we don't do any reads on the dma interface

  -- registers
  process (ClkxCI)
  begin
    
    if ClkxCI'event and ClkxCI = '1' then  -- rising clock edge

      if RstxRI = '1' then
        RstCorexSP         <= '1';
        FlushxSP           <= '0';
        FlushCorexSP       <= '0';
        ClearIntFlagsxSP   <= '0';
        InFIFOEmptyFlgxSP  <= '0';
        InFIFOFullFlgxSP   <= '0';
        OutFIFOEmptyFlgxSP <= '0';
        OutFIFOFullFlgxSP  <= '0';
        IEInFIFOEmptyxSP   <= '0';
        IEInFIFOFullxSP    <= '0';
        IEOutFIFOEmptyxSP  <= '0';
        IEOutFIFOFullxSP   <= '0';
        IEDmaErrxSP        <= '0';
        IECoreDonexSP      <= '0';
        IRQxSP             <= '0';
        InFIFOEmptyThrxDP  <= (others => '0');
        InFIFOFullThrxDP   <= (others => '1');
        OutFIFOEmptyThrxDP <= (others => '0');
        OutFIFOFullThrxDP  <= (others => '1');
        IncDestAdrFlgxSP   <= '0';
        DmaErrFlgxSP       <= '0';
        DmaBusyxSP         <= '0';
        DmaDestAdrxDP      <= (others => '0');
        XferByteCntxDP     <= 0;
        DmaLenxDP          <= 0;
        DmaDataOutxDP      <= (others => '0');
        DmaSelxSP          <= (others => '0');
        MaCycxSP           <= '0';
        MaStbxSP           <= '0';
      else
        RstCorexSP         <= RstCorexSN;
        FlushxSP           <= FlushxSN;
        FlushCorexSP       <= FlushCorexSN;
        ClearIntFlagsxSP   <= ClearIntFlagsxSN;
        InFIFOEmptyFlgxSP  <= InFIFOEmptyFlgxSN;
        InFIFOFullFlgxSP   <= InFIFOFullFlgxSN;
        OutFIFOEmptyFlgxSP <= OutFIFOEmptyFlgxSN;
        OutFIFOFullFlgxSP  <= OutFIFOFullFlgxSN;
        IEInFIFOEmptyxSP   <= IEInFIFOEmptyxSN;
        IEInFIFOFullxSP    <= IEInFIFOFullxSN;
        IEOutFIFOEmptyxSP  <= IEOutFIFOEmptyxSN;
        IEOutFIFOFullxSP   <= IEOutFIFOFullxSN;
        IEDmaErrxSP        <= IEDmaErrxSN;
        IECoreDonexSP      <= IECoreDonexSN;
        IRQxSP             <= IRQxSN;
        InFIFOEmptyThrxDP  <= InFIFOEmptyThrxDN;
        InFIFOFullThrxDP   <= InFIFOFullThrxDN;
        OutFIFOEmptyThrxDP <= OutFIFOEmptyThrxDN;
        OutFIFOFullThrxDP  <= OutFIFOFullThrxDN;
        IncDestAdrFlgxSP   <= IncDestAdrFlgxSN;
        DmaErrFlgxSP       <= DmaErrFlgxSN;
        DmaBusyxSP         <= DmaBusyxSP;
        DmaDestAdrxDP      <= DmaDestAdrxDN;
        XferByteCntxDP     <= XferByteCntxDN;
        DmaLenxDP          <= DmaLenxDN;
        DmaDataOutxDP      <= DmaDataOutxDN;
        DmaSelxSP          <= DmaSelxSN;
        MaCycxSP           <= MaCycxSN;
        MaStbxSP           <= MaStbxSN;
      end if;
      
    end if;
  end process;


  -- input data FIFO buffer
  InputFIFOInst : InputFIFO
    port map (
      ClkxCI        => ClkxCI,
      RstxRI        => RstCorexSP,
      DInxDI        => SlDatxDI,
      WExSI         => WeInFIFOxS,
      StopOutputxSI => CoreBusyxS,
      BusyxSO       => FIFOBusyxS,
      DOutxDO       => CoreDatInxD,
      OutStrobexSO  => CoreStbxS,
      LengthxDO     => InFIFOLenxD);


  LZRWcompressorInst : LZRWcompressor
    port map (
      ClkxCI         => ClkxCI,
      RstxRI         => RstCorexSP,
      DataInxDI      => CoreDatInxD,
      StrobexSI      => CoreStbxS,
      FlushBufxSI    => FlushCorexSP,
      BusyxSO        => CoreBusyxS,
      DonexSO        => CoreDonexS,
      BufOutxDO      => CoreDatOutxD,
      OutputValidxSO => CoreOutValidxS,
      RdStrobexSI    => CoreRdStbxS,
      LengthxDO      => OutFIFOLenxD);

end Behavioral;

