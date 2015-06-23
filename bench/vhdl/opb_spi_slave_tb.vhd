-------------------------------------------------------------------------------
-- Title      : Testbench for design "opb_spi_slave"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : opb_spi_slave_tb.vhd
-- Author     : 
-- Company    : 
-- Created    : 2007-09-02
-- Last update: 2008-05-15
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2007 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2007-09-02  1.0      d.koethe        Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;               -- conv_integer()

library work;
use work.opb_spi_slave_pack.all;
-------------------------------------------------------------------------------

entity opb_spi_slave_tb is
  generic (
    -- 0: simple transfer 1 byte transmit/receive
    -- 1: transfer 4 bytes and check flags
    -- 2: write until TX-FIFO asserts full, read until RX-FIFO asserts full, read
    --    and compare data
    -- 3: check FIFO Reset form underflow condition
    -- 4: check FIFO Flags IRQ Generation
    -- 5: check Slave select IRQ Generation
    -- 6: test opb Master Transfer
    test : std_logic_vector(7 downto 0) := "01000000");
end opb_spi_slave_tb;

-------------------------------------------------------------------------------

architecture behavior of opb_spi_slave_tb is
  constant C_BASEADDR        : std_logic_vector(0 to 31) := X"00000000";
  constant C_HIGHADDR        : std_logic_vector(0 to 31) := X"FFFFFFFF";
  constant C_USER_ID_CODE    : integer                   := 0;
  constant C_OPB_AWIDTH      : integer                   := 32;
  constant C_OPB_DWIDTH      : integer                   := 32;
  constant C_FAMILY          : string                    := "virtex-4";
  --
  -- constant C_SR_WIDTH        : integer                   := 8;
  constant C_SR_WIDTH        : integer                   := 32;
  -- 
  constant C_MSB_FIRST       : boolean                   := true;
  constant C_CPOL            : integer range 0 to 1      := 0;
  constant C_PHA             : integer range 0 to 1      := 0;
  constant C_FIFO_SIZE_WIDTH : integer range 4 to 7      := 7;
  constant C_DMA_EN          : boolean                   := true;
  constant C_CRC_EN          : boolean                   := true;

  component opb_spi_slave
    generic (
      C_BASEADDR        : std_logic_vector(0 to 31);
      C_HIGHADDR        : std_logic_vector(0 to 31);
      C_USER_ID_CODE    : integer;
      C_OPB_AWIDTH      : integer;
      C_OPB_DWIDTH      : integer;
      C_FAMILY          : string;
      C_SR_WIDTH        : integer;
      C_MSB_FIRST       : boolean;
      C_CPOL            : integer range 0 to 1;
      C_PHA             : integer range 0 to 1;
      C_FIFO_SIZE_WIDTH : integer range 4 to 7;
      C_DMA_EN          : boolean;
      C_CRC_EN          : boolean);
    port (
      OPB_ABus     : in  std_logic_vector(0 to C_OPB_AWIDTH-1);
      OPB_BE       : in  std_logic_vector(0 to C_OPB_DWIDTH/8-1);
      OPB_Clk      : in  std_logic;
      OPB_DBus     : in  std_logic_vector(0 to C_OPB_DWIDTH-1);
      OPB_RNW      : in  std_logic;
      OPB_Rst      : in  std_logic;
      OPB_select   : in  std_logic;
      OPB_seqAddr  : in  std_logic;
      Sln_DBus     : out std_logic_vector(0 to C_OPB_DWIDTH-1);
      Sln_errAck   : out std_logic;
      Sln_retry    : out std_logic;
      Sln_toutSup  : out std_logic;
      Sln_xferAck  : out std_logic;
      M_request    : out std_logic;
      MOPB_MGrant  : in  std_logic;
      M_busLock    : out std_logic;
      M_ABus       : out std_logic_vector(0 to C_OPB_AWIDTH-1);
      M_BE         : out std_logic_vector(0 to C_OPB_DWIDTH/8-1);
      M_DBus       : out std_logic_vector(0 to C_OPB_DWIDTH-1);
      M_RNW        : out std_logic;
      M_select     : out std_logic;
      M_seqAddr    : out std_logic;
      MOPB_errAck  : in  std_logic;
      MOPB_retry   : in  std_logic;
      MOPB_timeout : in  std_logic;
      MOPB_xferAck : in  std_logic;
      sclk         : in  std_logic;
      ss_n         : in  std_logic;
      mosi         : in  std_logic;
      miso_o       : out std_logic;
      miso_i       : in  std_logic;
      miso_t       : out std_logic;
      opb_irq      : out std_logic);
  end component;

  signal OPB_ABus     : std_logic_vector(0 to C_OPB_AWIDTH-1);
  signal OPB_BE       : std_logic_vector(0 to C_OPB_DWIDTH/8-1);
  signal OPB_Clk      : std_logic;
  signal OPB_DBus     : std_logic_vector(0 to C_OPB_DWIDTH-1);
  signal OPB_RNW      : std_logic;
  signal OPB_Rst      : std_logic;
  signal OPB_select   : std_logic;
  signal OPB_seqAddr  : std_logic;
  signal Sln_DBus     : std_logic_vector(0 to C_OPB_DWIDTH-1);
  signal Sln_errAck   : std_logic;
  signal Sln_retry    : std_logic;
  signal Sln_toutSup  : std_logic;
  signal Sln_xferAck  : std_logic;
  signal M_request    : std_logic;
  signal MOPB_MGrant  : std_logic;
  signal M_busLock    : std_logic;
  signal M_ABus       : std_logic_vector(0 to C_OPB_AWIDTH-1);
  signal M_BE         : std_logic_vector(0 to C_OPB_DWIDTH/8-1);
  signal M_DBus       : std_logic_vector(0 to C_OPB_DWIDTH-1);
  signal M_RNW        : std_logic;
  signal M_select     : std_logic;
  signal M_seqAddr    : std_logic;
  signal MOPB_errAck  : std_logic;
  signal MOPB_retry   : std_logic;
  signal MOPB_timeout : std_logic;
  signal MOPB_xferAck : std_logic;
  signal sclk         : std_logic;
  signal ss_n         : std_logic;
  signal mosi         : std_logic;
  signal miso_o       : std_logic;
  signal miso_i       : std_logic;
  signal miso_t       : std_logic;
  signal opb_irq      : std_logic;

-- testbench
  constant clk_period     : time := 10 ns;
  constant spi_clk_period : time := 50 ns;

  signal miso : std_logic;

  signal opb_read_data : std_logic_vector(31 downto 0);
  signal spi_value_in  : std_logic_vector(C_SR_WIDTH-1 downto 0);

  signal OPB_Transfer_Abort : boolean;
  signal OPB_DBus0          : std_logic_vector(0 to C_OPB_DWIDTH-1);
  signal OPB_DBus1          : std_logic_vector(0 to C_OPB_DWIDTH-1);
  
begin  -- behavior

  -- component instantiation
  DUT : opb_spi_slave
    generic map (
      C_BASEADDR        => C_BASEADDR,
      C_HIGHADDR        => C_HIGHADDR,
      C_USER_ID_CODE    => C_USER_ID_CODE,
      C_OPB_AWIDTH      => C_OPB_AWIDTH,
      C_OPB_DWIDTH      => C_OPB_DWIDTH,
      C_FAMILY          => C_FAMILY,
      C_SR_WIDTH        => C_SR_WIDTH,
      C_MSB_FIRST       => C_MSB_FIRST,
      C_CPOL            => C_CPOL,
      C_PHA             => C_PHA,
      C_FIFO_SIZE_WIDTH => C_FIFO_SIZE_WIDTH,
      C_DMA_EN          => C_DMA_EN,
      C_CRC_EN          => C_CRC_EN)
    port map (
      OPB_ABus     => OPB_ABus,
      OPB_BE       => OPB_BE,
      OPB_Clk      => OPB_Clk,
      OPB_DBus     => OPB_DBus,
      OPB_RNW      => OPB_RNW,
      OPB_Rst      => OPB_Rst,
      OPB_select   => OPB_select,
      OPB_seqAddr  => OPB_seqAddr,
      Sln_DBus     => Sln_DBus,
      Sln_errAck   => Sln_errAck,
      Sln_retry    => Sln_retry,
      Sln_toutSup  => Sln_toutSup,
      Sln_xferAck  => Sln_xferAck,
      M_request    => M_request,
      MOPB_MGrant  => MOPB_MGrant,
      M_busLock    => M_busLock,
      M_ABus       => M_ABus,
      M_BE         => M_BE,
      M_DBus       => M_DBus,
      M_RNW        => M_RNW,
      M_select     => M_select,
      M_seqAddr    => M_seqAddr,
      MOPB_errAck  => MOPB_errAck,
      MOPB_retry   => MOPB_retry,
      MOPB_timeout => MOPB_timeout,
      MOPB_xferAck => MOPB_xferAck,
      sclk         => sclk,
      ss_n         => ss_n,
      mosi         => mosi,
      miso_o       => miso_o,
      miso_i       => miso_i,
      miso_t       => miso_t,
      opb_irq      => opb_irq);



  -- clock generation
  process
  begin
    OPB_Clk <= '0';
    wait for clk_period;
    OPB_Clk <= '1';
    wait for clk_period;
  end process;

  -- IOB-Buffer
  miso <= miso_o when (miso_t = '0') else
          'Z';
  miso_i <= miso;

  -- OPB-Master arbiter/xferack generation
  process(OPB_Rst, OPB_Clk)
  begin
    if (OPB_Rst = '1') then
      MOPB_MGrant  <= '0';
      MOPB_xferAck <= '0';
      MOPB_errAck  <= '0';
    elsif rising_edge(OPB_Clk) then
      -- arbiter
      if (M_request = '1') then
        MOPB_MGrant <= '1';
      else
        MOPB_MGrant <= '0';
      end if;

      -- xfer_Ack
      if (M_select = '1') then
        if (OPB_Transfer_Abort) then
          MOPB_errAck <= '1';
        else
          if (conv_integer(M_ABus) >= 16#24000000#) then
            if (M_RNW = '1') then
              -- read
              OPB_DBus0(C_OPB_DWIDTH-C_SR_WIDTH to C_OPB_DWIDTH-1) <= "0000000000000000" & "00" & M_ABus(16 to C_OPB_DWIDTH-3);
            end if;
            MOPB_xferAck <= not MOPB_xferAck;
          end if;

        end if;


      else
        OPB_DBus0    <= (others => '0');
        MOPB_errAck  <= '0';
        MOPB_xferAck <= '0';
      end if;
      
    end if;
  end process;
  -------------------------------------------------------------------------------
  u1 : for i in 0 to 31 generate
    OPB_DBus(i) <= OPB_DBus0(i) or OPB_DBus1(i);
  end generate u1;

  ------------------------------------------------------------------------------
  -- waveform generation
  WaveGen_Proc : process
    variable temp  : std_logic_vector(31 downto 0);
    variable first : std_logic_vector(7 downto 0) := (others => '0');

    ---------------------------------------------------------------------------
    procedure opb_write (
      constant adr  : in std_logic_vector(7 downto 2);
      constant data : in integer) is 
    begin
      -- write transmit data
      wait until rising_edge(OPB_Clk);
      OPB_ABus   <= transport conv_std_logic_vector(conv_integer(adr & "00"), 32) after 2 ns;
      OPB_select <= transport '1' after 2 ns;
      OPB_RNW    <= transport '0' after 2 ns;
      OPB_DBus1  <= transport conv_std_logic_vector(data, 32)                     after 2 ns;

      for i in 0 to 3 loop
        wait until rising_edge(OPB_Clk);
        if (Sln_xferAck = '1') then
          exit;
        end if;
      end loop;  -- i
      OPB_DBus1  <= transport X"00000000" after 2 ns;
      OPB_ABus   <= transport X"00000000" after 2 ns;
      OPB_select <= '0';
    end procedure opb_write;
    -------------------------------------------------------------------------------
    procedure opb_read (
      constant adr : in std_logic_vector(7 downto 2)) is
    begin
      wait until rising_edge(OPB_Clk);
      OPB_ABus   <= transport conv_std_logic_vector(conv_integer(adr & "00"), 32) after 2 ns;
      OPB_select <= transport '1' after 2 ns;
      OPB_RNW    <= transport '1' after 2 ns;
      OPB_DBus1  <= transport conv_std_logic_vector(0, 32)                        after 2 ns;

      for i in 0 to 3 loop
        wait until rising_edge(OPB_Clk);
        if (Sln_xferAck = '1') then
          opb_read_data <= Sln_DBus;
          exit;
        end if;
      end loop;  -- i
      OPB_ABus   <= transport X"00000000" after 2 ns;
      OPB_select <= transport '0' after 2 ns;
      wait until rising_edge(OPB_Clk);
    end procedure opb_read;
    -------------------------------------------------------------------------------
    procedure spi_transfer(
      constant spi_value_out : in std_logic_vector(C_SR_WIDTH-1 downto 0)) is
    begin
      -- CPHA=0 CPOL=0 C_MSB_FIRST=TRUE
      ss_n <= '0';
      for i in C_SR_WIDTH-1 downto 0 loop
        mosi            <= spi_value_out(i);
        wait for spi_clk_period/2;
        sclk            <= '1';
        spi_value_in(i) <= miso;
        wait for spi_clk_period/2;
        sclk            <= '0';
      end loop;  -- i
      mosi <= 'Z';
      wait for clk_period/2;
      ss_n <= '1';
      wait for clk_period/2;
    end procedure spi_transfer;
    -------------------------------------------------------------------------------
    
  begin
    sclk   <= '0';
    ss_n   <= '1';
    mosi   <= 'Z';
    miso_i <= '0';

    -- init OPB-Slave
    OPB_ABus    <= (others => '0');
    OPB_BE      <= (others => '0');
    OPB_RNW     <= '0';
    OPB_select  <= '0';
    OPB_seqAddr <= '0';

    -- int opb_master
    MOPB_retry   <= '0';
    MOPB_timeout <= '0';

    OPB_Transfer_Abort <= false;

    -- reset active
    OPB_Rst <= '1';
    wait for 100 ns;
    -- reset inactive
    OPB_Rst <= '0';


    for i in 0 to 7 loop
      wait until rising_edge(OPB_Clk);
    end loop;  -- i 

    -- write TX Threshold
    -- Bit [15:00] Prog Full Threshold
    -- Bit [31:16] Prog Empty Threshold   
    opb_write(C_ADR_TX_THRESH, 16#0005000B#);

    -- write RX Threshold
    -- Bit [15:00] Prog Full Threshold
    -- Bit [31:16] Prog Empty Threshold   
    opb_write(C_ADR_RX_THRESH, 16#0006000C#);


    ---------------------------------------------------------------------------
    -- simple transfer 1 byte transmit/receive
    if (test(0) = '1') then
      -- write transmit data
      opb_write(C_ADR_TX_DATA, 16#78#);

      -- enable GDE and TX_EN and RX_EN
      opb_write(C_ADR_CTL, 16#7#);

      -- send/receive 8bit
      spi_transfer(conv_std_logic_vector(16#B5#, C_SR_WIDTH));

      -- compare transmit data
      assert (spi_value_in = conv_std_logic_vector(16#78#, C_SR_WIDTH)) report "Master Receive Failure" severity failure;

      -- read RX-Data Value
      opb_read(C_ADR_RX_DATA);

      -- compare receive data
      assert (opb_read_data = conv_std_logic_vector(16#B5#, C_SR_WIDTH)) report "Master Transfer Failure" severity failure;
      
    end if;
    ---------------------------------------------------------------------------
    -- transfer 4 bytes and check flags
    if (test(1) = '1') then
      opb_read(C_ADR_STATUS);
      -- only empty Bit and prog_empty set

      temp                           := (others => '0');
      temp(SPI_SR_Bit_TX_Prog_empty) := '1';
      temp(SPI_SR_Bit_TX_Empty)      := '1';
      temp(SPI_SR_Bit_RX_Prog_empty) := '1';
      temp(SPI_SR_Bit_RX_Empty)      := '1';
      temp(SPI_SR_Bit_SS_n)          := '1';

      assert (opb_read_data = temp) report "Check Status Bits: TX: 0, RX: 0" severity failure;

      -- write transmit data
      opb_write(C_ADR_TX_DATA, 16#01#);


      opb_read(C_ADR_STATUS);
      temp                           := (others => '0');
      temp(SPI_SR_Bit_TX_Prog_empty) := '1';
      temp(SPI_SR_Bit_RX_Prog_empty) := '1';
      temp(SPI_SR_Bit_RX_Empty)      := '1';
      temp(SPI_SR_Bit_SS_n)          := '1';

      assert (opb_read_data = temp) report "Check Status Bits: TX: 1, RX:0" severity failure;
    end if;
---------------------------------------------------------------------------
-- write until TX-FIFO asserts full, read until RX-FIFO asserts full, read an
-- compare data
    if (test(2) = '1') then
      for i in 2 to 255 loop
        opb_write(C_ADR_TX_DATA, i);
        opb_read(C_ADR_STATUS);
        -- check TX prog_empty deassert
        if ((opb_read_data(SPI_SR_Bit_TX_Prog_empty) = '0') and first(0) = '0') then
          assert (false) report "TX prog_emtpy deassert after " & integer'image(i) & " writes." severity warning;
          first(0) := '1';
        end if;

        -- check TX prog_full assert
        if ((opb_read_data(SPI_SR_Bit_TX_Prog_Full) = '1') and first(1) = '0') then
          assert (false) report "TX prog_full assert after " & integer'image(i) & " writes." severity warning;
          first(1) := '1';
        end if;

        -- check TX full assert
        if ((opb_read_data(SPI_SR_Bit_TX_Full) = '1') and first(2) = '0') then
          assert (false) report "TX full assert after " & integer'image(i) & " writes." severity warning;
          first(2) := '1';
          exit;
        end if;
        
      end loop;  -- i

      ---------------------------------------------------------------------------
      first := (others => '0');

      -- 16 spi transfer
      for i in 1 to 255 loop
        spi_transfer(conv_std_logic_vector(i, C_SR_WIDTH));
        opb_read(C_ADR_STATUS);

        -------------------------------------------------------------------------
        -- check TX FIFO flags
        -- check TX full deassert
        if ((opb_read_data(SPI_SR_Bit_TX_Full) = '0') and first(0) = '0') then
          assert (false) report "TX full deassert after " & integer'image(i) & " transfers." severity warning;
          first(0) := '1';
        end if;

        -- check TX prog_full deassert
        if ((opb_read_data(SPI_SR_Bit_TX_Prog_Full) = '0') and first(1) = '0') then
          assert (false) report "TX prog_full deassert after " & integer'image(i) & " transfers." severity warning;
          first(1) := '1';
        end if;

        -- check TX prog_emtpy assert
        if ((opb_read_data(SPI_SR_Bit_TX_Prog_empty) = '1') and first(2) = '0') then
          assert (false) report "TX prog_empty assert after " & integer'image(i) & " transfers." severity warning;
          first(2) := '1';
        end if;

        -- check TX emtpy assert
        if ((opb_read_data(SPI_SR_Bit_TX_Empty) = '1') and first(3) = '0') then
          assert (false) report "TX empty assert after " & integer'image(i) & " transfers." severity warning;
          first(3) := '1';
        end if;

        -------------------------------------------------------------------------
        -- check RX FIFO flags
        -- check RX empty deassert
        if ((opb_read_data(SPI_SR_Bit_RX_Empty) = '0') and first(4) = '0') then
          assert (false) report "RX empty deassert after " & integer'image(i) & " transfers." severity warning;
          first(4) := '1';
        end if;

        -- check RX prog_empty deassert
        if ((opb_read_data(SPI_SR_Bit_RX_Prog_empty) = '0') and first(5) = '0') then
          assert (false) report "RX prog_empty deassert after " & integer'image(i) & " transfers." severity warning;
          first(5) := '1';
        end if;

        -- check RX prog_full deassert
        if ((opb_read_data(SPI_SR_Bit_RX_Prog_Full) = '1') and first(6) = '0') then
          assert (false) report "RX prog_full assert after " & integer'image(i) & " transfers." severity warning;
          first(6) := '1';
        end if;

        -- check RX full deassert
        if ((opb_read_data(SPI_SR_Bit_RX_Full) = '1') and first(7) = '0') then
          assert (false) report "RX full assert after " & integer'image(i) & " transfers." severity warning;
          first(7) := '1';
          exit;
        end if;
      end loop;  -- i    


      ---------------------------------------------------------------------------
      -- read data from fifo
      first := (others => '0');

      for i in 1 to 255 loop
        opb_read(C_ADR_RX_DATA);

        -- check data
        assert (i = conv_integer(opb_read_data)) report "Read data failure at " & integer'image(i) severity failure;

        opb_read(C_ADR_STATUS);
        -- check RX FIFO flags

        -- check RX full deassert
        if ((opb_read_data(SPI_SR_Bit_RX_Full) = '0') and first(0) = '0') then
          assert (false) report "RX full deassert after " & integer'image(i) & " transfers." severity warning;
          first(0) := '1';
        end if;

        -- check RX prog_full deassert
        if ((opb_read_data(SPI_SR_Bit_RX_Prog_Full) = '0') and first(1) = '0') then
          assert (false) report "RX prog_full deassert after " & integer'image(i) & " transfers." severity warning;
          first(1) := '1';
        end if;

        -- check RX prog_empty assert
        if ((opb_read_data(SPI_SR_Bit_RX_Prog_empty) = '1') and first(2) = '0') then
          assert (false) report "RX prog_empty assert after " & integer'image(i) & " transfers." severity warning;
          first(2) := '1';
        end if;


        -- check RX empty assert
        if ((opb_read_data(SPI_SR_Bit_RX_Empty) = '1') and first(3) = '0') then
          assert (false) report "RX empty assert after " & integer'image(i) & " transfers." severity warning;
          first(3) := '1';
          exit;
        end if;
      end loop;  -- i        
    end if;

---------------------------------------------------------------------------
-- check FIFO Reset form underflow condition
    if (test(3) = '1') then
      -- add transfer to go in underflow condition
      spi_transfer(conv_std_logic_vector(0, C_SR_WIDTH));

      -- reset core (Bit 4)
      opb_write(C_ADR_CTL, 16#F#);

      --Check flags
      temp                           := (others => '0');
      temp(SPI_SR_Bit_TX_Prog_empty) := '1';
      temp(SPI_SR_Bit_TX_Empty)      := '1';
      temp(SPI_SR_Bit_RX_Prog_empty) := '1';
      temp(SPI_SR_Bit_RX_Empty)      := '1';
      temp(SPI_SR_Bit_SS_n)          := '1';

      assert (opb_read_data = temp) report "Status Bits after Reset failure" severity failure;
    end if;
-------------------------------------------------------------------------------    
-- check FIFO Flags IRQ Generation
    if (test(4) = '1') then
      -- enable all IRQ except Chip select
      opb_write(C_ADR_IER, 16#3F#);
      -- global irq enable
      opb_write(C_ADR_DGIE, 16#1#);

      -- fill transmit buffer
      for i in 1 to 255 loop
        opb_write(C_ADR_TX_DATA, i);
        opb_read(C_ADR_STATUS);
        -- check TX full assert
        if ((opb_read_data(SPI_SR_Bit_TX_Full) = '1')) then
          assert (false) report "TX full assert after " & integer'image(i) & " writes." severity warning;
          exit;
        end if;
      end loop;  -- i

      -- SPI-Data Transfers an Check TX Prog_Empty and TX Empty IRQ Generation
      for i in 1 to 255 loop
        spi_transfer(conv_std_logic_vector(0, C_SR_WIDTH));
        wait until rising_edge(OPB_Clk);
        wait until rising_edge(OPB_Clk);
        wait until rising_edge(OPB_Clk);
        if (opb_irq = '1') then
          opb_read(C_ADR_ISR);
          -- TX Prog Empty
          if ((opb_read_data(SPI_ISR_Bit_TX_Prog_Empty) = '1')) then
            report "TX prog empty irq after " & integer'image(i) & " transfers.";
            -- clear_irq
            opb_write(C_ADR_ISR, 16#1#);
            wait until rising_edge(OPB_Clk);
            assert (opb_irq = '0') report "TX Prog Empty not cleared" severity warning;
          end if;

          -- TX EMPTY
          if ((opb_read_data(SPI_ISR_Bit_TX_Empty) = '1')) then
            report "TX empty irq after " & integer'image(i) & " transfers.";
            -- clear_irq
            opb_write(C_ADR_ISR, 16#2#);
            wait until rising_edge(OPB_Clk);
            assert (opb_irq = '0') report "IRQ TX Empty not cleared" severity warning;
          end if;

          -- TX Underflow
          if ((opb_read_data(SPI_ISR_Bit_TX_Underflow) = '1')) then
            report "TX underflow irq after " & integer'image(i) & " transfers.";
            -- clear_irq
            opb_write(C_ADR_ISR, 16#4#);
            wait until rising_edge(OPB_Clk);
            assert (opb_irq = '0') report "IRQ TX underflow not cleared" severity warning;
          end if;

          -- RX Prog Full
          if ((opb_read_data(SPI_ISR_Bit_RX_Prog_Full) = '1')) then
            report "RX prog full irq after " & integer'image(i) & " transfers.";
            -- clear_irq
            opb_write(C_ADR_ISR, 16#8#);
            wait until rising_edge(OPB_Clk);
            assert (opb_irq = '0') report "RX Prog Full not cleared" severity warning;
          end if;

          -- RX Full
          if ((opb_read_data(SPI_ISR_Bit_RX_Full) = '1')) then
            report "RX full irq after " & integer'image(i) & " transfers.";
            -- clear_irq
            opb_write(C_ADR_ISR, 16#10#);
            wait until rising_edge(OPB_Clk);
            assert (opb_irq = '0') report "RX Full not cleared" severity warning;
          end if;

          -- RX Overflow
          if ((opb_read_data(SPI_ISR_Bit_RX_Overflow) = '1')) then
            report "RX overflow irq after " & integer'image(i) & " transfers.";
            -- clear_irq
            opb_write(C_ADR_ISR, 2**SPI_ISR_Bit_RX_Overflow);
            wait until rising_edge(OPB_Clk);
            assert (opb_irq = '0') report "RX Overflow not cleared" severity warning;
            exit;
          end if;
          
        end if;

      end loop;  -- i    
    end if;
---------------------------------------------------------------------------
    -- check slave select irq
    if (test(5) = '1') then
      -- reset core
      opb_write(C_ADR_CTL, 16#F#);

      -- eable Chip select fall/rise IRQ
      opb_write(C_ADR_IER, 16#C0#);

      ss_n <= '0';
      wait until rising_edge(OPB_Clk);
      wait until rising_edge(OPB_Clk);
      wait until rising_edge(OPB_Clk);
      if (opb_irq = '1') then
        opb_read(C_ADR_ISR);
        if ((opb_read_data(SPI_ISR_Bit_SS_Fall) = '1')) then
          report "SS Fall irq found";
          -- clear_irq
          opb_write(C_ADR_ISR, 2**SPI_ISR_Bit_SS_Fall);
          wait until rising_edge(OPB_Clk);
          assert (opb_irq = '0') report "SS_Fall IRQ  not cleared" severity warning;
        end if;
      end if;

      ss_n <= '1';
      wait until rising_edge(OPB_Clk);
      wait until rising_edge(OPB_Clk);
      wait until rising_edge(OPB_Clk);
      if (opb_irq = '1') then
        opb_read(C_ADR_ISR);
        if ((opb_read_data(SPI_ISR_Bit_SS_Rise) = '1')) then
          report "SS Rise irq found";
          -- clear_irq
          opb_write(C_ADR_ISR, 2**SPI_ISR_Bit_SS_Rise);
          wait until rising_edge(OPB_Clk);
          assert (opb_irq = '0') report "SS_Rise IRQ  not cleared" severity warning;
        end if;
      end if;
    end if;
-------------------------------------------------------------------------------
    -- test opb Master Transfer
    if (test(6) = '1') then

      -- enable SPI and CRC
      opb_write(C_ADR_CTL, 2**C_OPB_CTL_REG_DGE+2**C_OPB_CTL_REG_TX_EN+2**C_OPB_CTL_REG_RX_EN+2**C_OPB_CTL_REG_CRC_EN);
      -- write TX Threshold
      -- Bit [15:00] Prog Full Threshold
      -- Bit [31:16] Prog Empty Threshold   
      opb_write(C_ADR_TX_THRESH, 16#0005000B#);

      -- write RX Threshold
      -- Bit [15:00] Prog Full Threshold
      -- Bit [31:16] Prog Empty Threshold   

      -- Pog full must greater or equal than 16(Block Transfer Size)! 
      opb_write(C_ADR_RX_THRESH, 16#0006000F#);

      -- set transmit buffer Base Adress
      opb_write(C_ADR_TX_DMA_ADDR, 16#24000000#);
      -- set block number
      opb_write(C_ADR_TX_DMA_NUM, 1);

      -- set RX-Buffer base adress
      opb_write(C_ADR_RX_DMA_ADDR, 16#25000000#);
      -- set block number
      opb_write(C_ADR_RX_DMA_NUM, 1);

      -- enable dma write transfer
      opb_write(C_ADR_RX_DMA_CTL, 1);

      -- enable dma read transfer
      opb_write(C_ADR_TX_DMA_CTL, 1);

      -- time to fill fifo from ram
      for i in 0 to 15 loop
        wait until rising_edge(OPB_Clk);
      end loop;  -- i

      -- transfer 16 bytes
      -- data block
      for i in 0 to 15 loop
        spi_transfer(conv_std_logic_vector(i, C_SR_WIDTH));
        assert (conv_integer(spi_value_in) = i) report "DMA Transfer 1 read data failure" severity failure;
      end loop;  -- i

      -- crc_block
      for i in 16 to 31 loop
        spi_transfer(conv_std_logic_vector(i, C_SR_WIDTH));
        if (i = 16) then
          assert (conv_integer(spi_value_in) = 16#e4ea78bf#) report "DMA-block CRC failure" severity failure;          
        else
          assert (conv_integer(spi_value_in) = i) report "DMA Transfer 1 read data failure" severity failure;
        end if;
      end loop;  -- i

      -- wait until RX transfer done
      for i in 0 to 15 loop
        opb_read(C_ADR_STATUS);
        if (opb_read_data(SPI_SR_Bit_RX_DMA_Done) = '1') then
          exit;
        end if;
        wait for 1 us;
      end loop;  -- i

      -- check TX CRC Register
      opb_read(C_ADR_TX_CRC);
      assert (conv_integer(opb_read_data) = 16#e4ea78bf#) report "TX Register CRC Failure" severity failure;

      -- check RX CRC Register
      opb_read(C_ADR_RX_CRC);
      assert (conv_integer(opb_read_data) = 16#e4ea78bf#) report "RX Register CRC Failure" severity failure;

      wait for 1 us;
    end if;
---------------------------------------------------------------------------



    assert false report "Simulation sucessful" severity failure;
  end process WaveGen_Proc;

  

end behavior;

-------------------------------------------------------------------------------

configuration opb_spi_slave_tb_behavior_cfg of opb_spi_slave_tb is
  for behavior
  end for;
end opb_spi_slave_tb_behavior_cfg;

-------------------------------------------------------------------------------
