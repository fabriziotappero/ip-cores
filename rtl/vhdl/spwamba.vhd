--
--  SpaceWire core with AMBA interface.
--
--  APB registers:
--
--      Address 0x00: Control Register
--          bit 0     Reset spwamba core (auto-clear)
--          bit 1     Reset DMA engines (auto-clear)
--          bit 2     Link start
--          bit 3     Link autostart
--          bit 4     Link disable
--          bit 5     Enable timecode transmission through tick_in signal
--          bit 6     Start RX DMA (auto-clear)
--          bit 7     Start TX DMA (auto-clear)
--          bit 8     Cancel TX DMA and discard TX data queue (auto-clear)
--          bit 9     Enable interrupt on link up/down
--          bit 10    Enable interrupt on time code received
--          bit 11    Enable interrupt on RX descriptor
--          bit 12    Enable interrupt on TX descriptor
--          bit 13    Enable interrupt on RX packet
--          bit 27:24 desctablesize (read-only)
--
--      Address 0x04: Status Register
--          bit 1:0   Link status: 0=off, 1=started, 2=connecting, 3=run
--          bit 2     Got disconnect error (sticky)
--          bit 3     Got parity error (sticky)
--          bit 4     Got escape error (sticky)
--          bit 5     Got credit error (sticky)
--          bit 6     RX DMA enabled
--          bit 7     TX DMA enabled
--          bit 8     AHB error occurred (reset DMA engine to clear)
--          bit 9     Reserved
--          bit 10    Received timecode (sticky)
--          bit 11    Finished RX descriptor with IE='1' (sticky)
--          bit 12    Finished TX descriptor with IE='1' (sticky)
--          bit 13    Received packet (sticky)
--          bit 14    RX buffer empty after packet
--
--          Sticky bits are reset by writing a '1' bit to the corresponding
--          bit position(s).
--
--      Address 0x08: Transmission Clock Scaler
--          bit 7:0   txclk division factor minus 1
--
--      Address 0x0c: Timecode Register
--          bit 5:0   Last received timecode value (read-only)
--          bit 7:6   Control bits received with last timecode (read-only)
--          bit 13:8  Timecode value to send on next tick_in (auto-increment)
--          bit 15:14 Reserved (write as zero)
--          bit 16    Write '1' to send a timecode (auto-clear)
--
--      Address 0x10: Descriptor pointer for RX DMA
--          bit 2:0                 Reserved, write as zero
--          bit desctablesize+2:3   Descriptor index (auto-increment)
--          bit 31:desctablesize+3  Fixed address bits of descriptor table
--
--          For example, if desctablesize = 10, a 8192-byte area is
--          determined by bits 31:13. This area has room for 1024 descriptors
--          of 8 bytes each. Bits 12:3 point to the current descriptor within
--          the table.
--      
--      Address 0x14: Descriptor pointer for TX DMA
--          bit 2:0                 Reserved, write as zero
--          bit desctablesize+2:3   Descriptor index (auto-increment)
--          bit 31:desctablesize+3  Fixed address bits of descriptor table
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library techmap;
use techmap.gencomp.all;
library grlib;
use grlib.amba.all;
use grlib.devices.all;
use grlib.stdlib.all;
use work.spwpkg.all;
use work.spwambapkg.all;

entity spwamba is

    generic (
        -- Technology selection for FIFO memories.
        tech:           integer range 0 to NTECH := DEFFABTECH;

        -- AHB master index.
        hindex:         integer;

        -- APB slave index.
        pindex:         integer;

        -- Bits 19 to 8 of the APB address range.
        paddr:          integer;

        -- Mask for APB address bits 19 to 8.
        pmask:          integer := 16#fff#;

        -- Index of the interrupt request line.
        pirq:           integer;

        -- System clock frequency in Hz.
        -- This must be set to the frequency of "clk". It is used to setup
        -- counters for reset timing, disconnect timeout and to transmit
        -- at 10 Mbit/s during the link handshake.
        sysfreq:        real;

        -- Transmit clock frequency in Hz (only if tximpl = impl_fast).
        -- This must be set to the frequency of "txclk". It is used to
        -- transmit at 10 Mbit/s during the link handshake.
        txclkfreq:      real := 0.0;

        -- Selection of a receiver front-end implementation.
        rximpl:         spw_implementation_type := impl_generic;

        -- Maximum number of bits received per system clock
        -- (must be 1 in case of impl_generic).
        rxchunk:        integer range 1 to 4 := 1;

        -- Selection of a transmitter implementation.
        tximpl:         spw_implementation_type := impl_generic;

        -- Enable capability to generate time-codes.
        timecodegen:    boolean := true;

        -- Size of the receive FIFO as the 2-logarithm of the number of words.
        -- Must be at least 6 (64 words = 256 bytes).
        rxfifosize:     integer range 6 to 12 := 8;

        -- Size of the transmit FIFO as the 2-logarithm of the number of words.
        txfifosize:     integer range 2 to 12 := 8;

        -- Size of the DMA descriptor tables as the 2-logarithm of the number
        -- of descriptors.
        desctablesize:  integer range 4 to 14 := 10;

        -- Maximum burst length as the 2-logarithm of the number of words (default 8 words).
        maxburst:       integer range 1 to 8 := 3
    );

    port (
        -- System clock.
        clk:        in  std_logic;

        -- Receiver sample clock (only for impl_fast)
        rxclk:      in  std_logic;

        -- Transmit clock (only for impl_fast)
        txclk:      in  std_logic;

        -- Synchronous reset (active-low).
        rstn:       in  std_logic;

        -- APB slave input signals.
        apbi:       in  apb_slv_in_type;

        -- APB slave output signals.
        apbo:       out apb_slv_out_type;

        -- AHB master input signals.
        ahbi:       in  ahb_mst_in_type;

        -- AHB master output signals.
        ahbo:       out ahb_mst_out_type;

        -- Pulse for TimeCode generation.
        tick_in:    in  std_logic;

        -- High for one clock cycle if a TimeCode was just received.
        tick_out:   out std_logic;

        -- Data In signal from SpaceWire bus.
        spw_di:     in  std_logic;

        -- Strobe In signal from SpaceWire bus.
        spw_si:     in  std_logic;

        -- Data Out signal to SpaceWire bus.
        spw_do:     out std_logic;

        -- Strobe Out signal to SpaceWire bus.
        spw_so:     out std_logic
    );

end entity spwamba;

architecture spwamba_arch of spwamba is

    -- Reset time (6.4 us) in system clocks
    constant reset_time:        integer := integer(sysfreq * 6.4e-6);

    -- Disconnect time (850 ns) in system clocks
    constant disconnect_time:   integer := integer(sysfreq * 850.0e-9);

    -- Initial tx clock scaler (10 Mbit).
    type impl_to_real_type is array(spw_implementation_type) of real;
    constant tximpl_to_txclk_freq: impl_to_real_type :=
        (impl_generic => sysfreq, impl_fast => txclkfreq);
    constant effective_txclk_freq: real := tximpl_to_txclk_freq(tximpl);
    constant default_divcnt:    std_logic_vector(7 downto 0) :=
        std_logic_vector(to_unsigned(integer(effective_txclk_freq / 10.0e6 - 1.0), 8));

    -- Registers.
    type regs_type is record
        -- packet state
        rxpacket:       std_logic;      -- '1' when receiving a packet
        rxeep:          std_logic;      -- '1' when rx EEP character pending
        txpacket:       std_logic;      -- '1' when transmitting a packet
        txdiscard:      std_logic;      -- '1' when discarding a tx packet
        -- RX fifo state
        rxfifo_raddr:   std_logic_vector(rxfifosize-1 downto 0);
        rxfifo_waddr:   std_logic_vector(rxfifosize-1 downto 0);
        rxfifo_wdata:   std_logic_vector(35 downto 0);
        rxfifo_write:   std_ulogic;
        rxfifo_empty:   std_ulogic;
        rxfifo_bytemsk: std_logic_vector(2 downto 0);
        rxroom:         std_logic_vector(5 downto 0);
        -- TX fifo state
        txfifo_raddr:   std_logic_vector(txfifosize-1 downto 0);
        txfifo_waddr:   std_logic_vector(txfifosize-1 downto 0);
        txfifo_empty:   std_ulogic;
        txfifo_nxfull:  std_ulogic;
        txfifo_highw:   std_ulogic;
        txfifo_bytepos: std_logic_vector(1 downto 0);
        -- APB registers
        ctl_reset:      std_ulogic;
        ctl_resetdma:   std_ulogic;
        ctl_linkstart:  std_ulogic;
        ctl_autostart:  std_ulogic;
        ctl_linkdis:    std_ulogic;
        ctl_ticken:     std_ulogic;
        ctl_rxstart:    std_ulogic;
        ctl_txstart:    std_ulogic;
        ctl_txcancel:   std_ulogic;
        ctl_ielink:     std_ulogic;
        ctl_ietick:     std_ulogic;
        ctl_ierxdesc:   std_ulogic;
        ctl_ietxdesc:   std_ulogic;
        ctl_ierxpacket: std_ulogic;
        sta_link:       std_logic_vector(1 downto 0);
        sta_errdisc:    std_ulogic;
        sta_errpar:     std_ulogic;
        sta_erresc:     std_ulogic;
        sta_errcred:    std_ulogic;
        sta_gottick:    std_ulogic;
        sta_rxdesc:     std_ulogic;
        sta_txdesc:     std_ulogic;
        sta_rxpacket:   std_ulogic;
        sta_rxempty:    std_ulogic;
        txdivcnt:       std_logic_vector(7 downto 0);
        time_in:        std_logic_vector(5 downto 0);
        tick_in:        std_ulogic;
        rxdesc_ptr:     std_logic_vector(31 downto 3);
        txdesc_ptr:     std_logic_vector(31 downto 3);
        -- APB interrupt request
        irq:            std_ulogic;
    end record;

    constant regs_reset: regs_type := (
        rxpacket        => '0',
        rxeep           => '0',
        txpacket        => '0',
        txdiscard       => '0',
        rxfifo_raddr    => (others => '0'),
        rxfifo_waddr    => (others => '0'),
        rxfifo_wdata    => (others => '0'),
        rxfifo_write    => '0',
        rxfifo_empty    => '1',
        rxfifo_bytemsk  => "111",
        rxroom          => (others => '1'),
        txfifo_raddr    => (others => '0'),
        txfifo_waddr    => (others => '0'),
        txfifo_empty    => '1',
        txfifo_nxfull   => '0',
        txfifo_highw    => '0',
        txfifo_bytepos  => "00",
        ctl_reset       => '0',
        ctl_resetdma    => '0',
        ctl_linkstart   => '0',
        ctl_autostart   => '0',
        ctl_linkdis     => '0',
        ctl_ticken      => '0',
        ctl_rxstart     => '0',
        ctl_txstart     => '0',
        ctl_txcancel    => '0',
        ctl_ielink      => '0',
        ctl_ietick      => '0',
        ctl_ierxdesc    => '0',
        ctl_ietxdesc    => '0',
        ctl_ierxpacket  => '0',
        sta_link        => "00",
        sta_errdisc     => '0',
        sta_errpar      => '0',
        sta_erresc      => '0',
        sta_errcred     => '0',
        sta_gottick     => '0',
        sta_rxdesc      => '0',
        sta_txdesc      => '0',
        sta_rxpacket    => '0',
        sta_rxempty     => '1',
        txdivcnt        => default_divcnt,
        time_in         => (others => '0'),
        tick_in         => '0',
        rxdesc_ptr      => (others => '0'),
        txdesc_ptr      => (others => '0'),
        irq             => '0' );

    signal r: regs_type := regs_reset;
    signal rin: regs_type;

    -- Component interface signals.
    signal recv_rxen:       std_logic;
    signal recvo:           spw_recv_out_type;
    signal recv_inact:      std_logic;
    signal recv_inbvalid:   std_logic;
    signal recv_inbits:     std_logic_vector(rxchunk-1 downto 0);
    signal xmit_rst:        std_logic;
    signal xmiti:           spw_xmit_in_type;
    signal xmito:           spw_xmit_out_type;
    signal xmit_divcnt:     std_logic_vector(7 downto 0);
    signal link_rst:        std_logic;
    signal linki:           spw_link_in_type;
    signal linko:           spw_link_out_type;
    signal msti:            spw_ahbmst_in_type;
    signal msto:            spw_ahbmst_out_type;
    signal ahbmst_rstn:     std_logic;

    -- Memory interface signals.
    signal s_rxfifo_raddr:  std_logic_vector(rxfifosize-1 downto 0);
    signal s_rxfifo_rdata:  std_logic_vector(35 downto 0);
    signal s_rxfifo_wen:    std_logic;
    signal s_rxfifo_waddr:  std_logic_vector(rxfifosize-1 downto 0);
    signal s_rxfifo_wdata:  std_logic_vector(35 downto 0);
    signal s_txfifo_raddr:  std_logic_vector(txfifosize-1 downto 0);
    signal s_txfifo_rdata:  std_logic_vector(35 downto 0);
    signal s_txfifo_wen:    std_logic;
    signal s_txfifo_waddr:  std_logic_vector(txfifosize-1 downto 0);
    signal s_txfifo_wdata:  std_logic_vector(35 downto 0);


    -- APB slave plug&play configuration
    constant REVISION:      integer := 0;
    constant pconfig:       apb_config_type := (
        0 => ahb_device_reg(VENDOR_OPENCORES, DEVICE_SPACEWIRELIGHT, 0, REVISION, pirq),
        1 => apb_iobar(paddr, pmask) );

    -- AHB master plug&play configuration
    constant hconfig:       ahb_config_type := (
        0 => ahb_device_reg(VENDOR_OPENCORES, DEVICE_SPACEWIRELIGHT, 0, REVISION, 0),
        others => zero32 );

begin

    -- Instantiate link controller.
    link_inst: spwlink
        generic map (
            reset_time  => reset_time )
        port map (
            clk         => clk,
            rst         => link_rst,
            linki       => linki,
            linko       => linko,
            rxen        => recv_rxen,
            recvo       => recvo,
            xmiti       => xmiti,
            xmito       => xmito );

    -- Instantiate receiver.
    recv_inst: spwrecv
        generic map(
            disconnect_time => disconnect_time,
            rxchunk     => rxchunk )
        port map (
            clk         => clk,
            rxen        => recv_rxen,
            recvo       => recvo,
            inact       => recv_inact,
            inbvalid    => recv_inbvalid,
            inbits      => recv_inbits );

    -- Instantiate receiver front-end.
    recvfront_sel0: if rximpl = impl_generic generate
        recvfront_generic_inst: spwrecvfront_generic
            port map (
                clk         => clk,
                rxen        => recv_rxen,
                inact       => recv_inact,
                inbvalid    => recv_inbvalid,
                inbits      => recv_inbits,
                spw_di      => spw_di,
                spw_si      => spw_si );
    end generate;
    recvfront_sel1: if rximpl = impl_fast generate
        recvfront_fast_inst: spwrecvfront_fast
            generic map (
                rxchunk     => rxchunk )
            port map (
                clk         => clk,
                rxclk       => rxclk,
                rxen        => recv_rxen,
                inact       => recv_inact,
                inbvalid    => recv_inbvalid,
                inbits      => recv_inbits,
                spw_di      => spw_di,
                spw_si      => spw_si );
    end generate;

    -- Instantiate transmitter.
    xmit_sel0: if tximpl = impl_generic generate
        xmit_inst: spwxmit
            port map (
                clk     => clk,
                rst     => xmit_rst,
                divcnt  => xmit_divcnt,
                xmiti   => xmiti,
                xmito   => xmito,
                spw_do  => spw_do,
                spw_so  => spw_so );
    end generate;
    xmit_sel1: if tximpl = impl_fast generate
        xmit_fast_inst: spwxmit_fast
            port map (
                clk     => clk,
                txclk   => txclk,
                rst     => xmit_rst,
                divcnt  => xmit_divcnt,
                xmiti   => xmiti,
                xmito   => xmito,
                spw_do  => spw_do,
                spw_so  => spw_so );
    end generate;

    -- Instantiate RX FIFO.
    rxfifo: syncram_2p
        generic map (
            tech        => tech,
            abits       => rxfifosize,
            dbits       => 36,
            sepclk      => 0 )
        port map (
            rclk        => clk,
            renable     => '1',
            raddress    => s_rxfifo_raddr,
            dataout     => s_rxfifo_rdata,
            wclk        => clk,
            write       => s_rxfifo_wen,
            waddress    => s_rxfifo_waddr,
            datain      => s_rxfifo_wdata );

    -- Instantiate TX FIFO.
    txfifo: syncram_2p
        generic map (
            tech        => tech,
            abits       => txfifosize,
            dbits       => 36,
            sepclk      => 0 )
        port map (
            rclk        => clk,
            renable     => '1',
            raddress    => s_txfifo_raddr,
            dataout     => s_txfifo_rdata,
            wclk        => clk,
            write       => s_txfifo_wen,
            waddress    => s_txfifo_waddr,
            datain      => s_txfifo_wdata );

    -- Instantiate AHB master.
    ahbmst: spwahbmst
        generic map (
            hindex      => hindex,
            hconfig     => hconfig,
            maxburst    => maxburst )
        port map (
            clk         => clk,
            rstn        => ahbmst_rstn,
            msti        => msti,
            msto        => msto,
            ahbi        => ahbi,
            ahbo        => ahbo );


    --
    -- Combinatorial process
    --
    process (r, linko, msto, s_rxfifo_rdata, s_txfifo_rdata, rstn, apbi, tick_in)  is
        variable v:             regs_type;
        variable v_tmprxroom:   unsigned(rxfifosize-1 downto 0);
        variable v_prdata:      std_logic_vector(31 downto 0);
        variable v_irq:         std_logic_vector(NAHBIRQ-1 downto 0);
        variable v_txfifo_bytepos: integer range 0 to 3;
    begin
        v           := r;
        v_tmprxroom := to_unsigned(0, rxfifosize);
        v_prdata    := (others => '0');
        v_irq           := (others => '0');
        v_irq(pirq)     := r.irq;

        -- Convert RX/TX byte index to integer.
        v_txfifo_bytepos := to_integer(unsigned(r.txfifo_bytepos));

        -- Reset auto-clearing registers.
        v.ctl_reset     := '0';
        v.ctl_resetdma  := '0';
        v.ctl_rxstart   := '0';
        v.ctl_txstart   := '0';

        -- Register external timecode trigger (if enabled).
        if timecodegen and r.ctl_ticken = '1' then
            v.tick_in   := tick_in;
        else
            v.tick_in   := '0';
        end if;

        -- Auto-increment timecode counter.
        if r.tick_in = '1' then
            v.time_in   := std_logic_vector(unsigned(r.time_in) + 1);
        end if;

        -- Keep track of whether we are sending and/or receiving a packet.
        if linko.rxchar = '1' then
            -- got character
            v.rxpacket  := not linko.rxflag;
        end if;
        if linko.txack = '1' then
            -- send character
            v.txpacket  := not s_txfifo_rdata(35-v_txfifo_bytepos);
        end if;

        -- Accumulate a word to write to the RX fifo.
        -- Note: If the EOP/EEP marker falls in the middle of a word,
        -- subsequent bytes must be a copy of the marker, otherwise
        -- the AHB master may not work correctly.
        v.rxfifo_write  := '0';
        for i in 3 downto 0 loop
            if (i = 0) or (r.rxfifo_bytemsk(i-1) = '1') then
                if r.rxeep = '1' then
                    v.rxfifo_wdata(32+i)             := '1';
                    v.rxfifo_wdata(7+8*i downto 8*i) := "00000001";
                else
                    v.rxfifo_wdata(32+i)             := linko.rxflag;
                    v.rxfifo_wdata(7+8*i downto 8*i) := linko.rxdata;
                end if;
            end if;
        end loop;
        if linko.rxchar = '1' or (r.rxeep = '1' and unsigned(r.rxroom) /= 0) then
            v.rxeep     := '0';
            if r.rxfifo_bytemsk(0) = '0' or linko.rxflag = '1' or r.rxeep = '1' then
                -- Flush the current word to the FIFO.
                v.rxfifo_write   := '1';
                v.rxfifo_bytemsk := "111";
            else
                -- Store one byte.
                v.rxfifo_bytemsk := '0' & r.rxfifo_bytemsk(2 downto 1);
            end if;
        end if;

        -- Read from TX fifo.
        if (r.txfifo_empty = '0') and (linko.txack = '1' or r.txdiscard = '1') then
            -- Update byte pointer.
            if r.txfifo_bytepos = "11" or
               s_txfifo_rdata(35-v_txfifo_bytepos) = '1' or
               (v_txfifo_bytepos < 3 and
                s_txfifo_rdata(34-v_txfifo_bytepos) = '1' and
                s_txfifo_rdata(23-8*v_txfifo_bytepos) = '1') then
                -- This is the last byte in the current word;
                -- OR the current byte is an EOP/EEP marker;
                -- OR the next byte in the current word is a non-EOP end-of-frame marker.
                v.txfifo_bytepos := "00";
                v.txfifo_raddr  := std_logic_vector(unsigned(r.txfifo_raddr) + 1);
            else
                -- Move to next byte.
                v.txfifo_bytepos := std_logic_vector(unsigned(r.txfifo_bytepos) + 1);
            end if;
            -- Clear discard flag when past EOP.
            if s_txfifo_rdata(35-v_txfifo_bytepos) = '1' then
                v.txdiscard := '0';
            end if;
        end if;

        -- Update RX fifo pointers.
        if msto.rxfifo_read = '1' then
            -- Read one word.
            v.rxfifo_raddr  := std_logic_vector(unsigned(r.rxfifo_raddr) + 1);
        end if;
        if r.rxfifo_write = '1' then
            -- Write one word.
            v.rxfifo_waddr  := std_logic_vector(unsigned(r.rxfifo_waddr) + 1);
        end if;

        -- Detect RX fifo empty (using new value of rxfifo_raddr).
        -- Note: The FIFO is empty if head and tail pointer are equal.
        v.rxfifo_empty  := conv_std_logic(v.rxfifo_raddr = r.rxfifo_waddr);

        -- Indicate RX fifo room for SpaceWire flow control.
        -- The flow control window is normally expressed as a number of bytes,
        -- but we don't know how many bytes we can fit in each word because
        -- some words are only partially used. So we report FIFO room as if
        -- each FIFO word can hold only one byte, which is an overly
        -- pessimistic estimate.
        -- (Use the new value of rxfifo_waddr.)
        v_tmprxroom     := unsigned(r.rxfifo_raddr) - unsigned(v.rxfifo_waddr) - 1;
        if v_tmprxroom > 63 then
            -- at least 64 bytes room.
            v.rxroom    := "111111";
        else
            -- less than 64 bytes room.
            -- If linko.rxchar = '1', decrease rxroom by one to account for
            -- the pipeline delay through r.rxfifo_write.
            v.rxroom    := std_logic_vector(v_tmprxroom(5 downto 0) - 
                             to_unsigned(conv_integer(linko.rxchar), 6));
        end if;

        -- Update TX fifo write pointer.
        if msto.txfifo_write = '1' then
            -- write one word.
            v.txfifo_waddr  := std_logic_vector(unsigned(r.txfifo_waddr) + 1);
        end if;

        -- Detect TX fifo empty.
        -- Note: The FIFO may be either full or empty if head and tail pointer
        -- are equal, hence the additional test for txfifo_nxfull.
        v.txfifo_empty  := conv_std_logic(v.txfifo_raddr = r.txfifo_waddr) and not r.txfifo_nxfull;

        -- Detect TX fifo full after one more write.
        if unsigned(r.txfifo_raddr) - unsigned(r.txfifo_waddr) = to_unsigned(2, txfifosize) then
            -- currently exactly 2 words left.
            v.txfifo_nxfull := msto.txfifo_write;
        end if;

        -- Detect TX fifo high water mark.
        if txfifosize > maxburst then
            -- Indicate high water when there is no room for a maximum burst.
            if unsigned(r.txfifo_raddr) - unsigned(r.txfifo_waddr) = to_unsigned(2**maxburst + 1, txfifosize) then
                -- currently room for exactly one maximum burst.
                v.txfifo_highw  := msto.txfifo_write;
            end if;
        else
            -- Indicate high water when more than half full.
            if unsigned(r.txfifo_raddr) - unsigned(r.txfifo_waddr) = to_unsigned(2**(txfifosize-1), txfifosize) then
                -- currently exactly half full.
                v.txfifo_highw  := msto.txfifo_write;
            end if;
        end if;

        -- Update descriptor pointers.
        if msto.rxdesc_next = '1' then
            if msto.rxdesc_wrap = '1' then
                v.rxdesc_ptr(desctablesize+2 downto 3) := (others => '0');
            else
                v.rxdesc_ptr(desctablesize+2 downto 3) :=
                    std_logic_vector(unsigned(r.rxdesc_ptr(desctablesize+2 downto 3)) + 1);
            end if;
        end if;
        if msto.txdesc_next = '1' then
            if msto.txdesc_wrap = '1' then
                v.txdesc_ptr(desctablesize+2 downto 3) := (others => '0');
            else
                v.txdesc_ptr(desctablesize+2 downto 3) :=
                    std_logic_vector(unsigned(r.txdesc_ptr(desctablesize+2 downto 3)) + 1);
            end if;
        end if;

        -- If the link is lost, set a flag to discard the current packet.
        if linko.running = '0' then
            v.rxeep     := v.rxeep or v.rxpacket;       -- use new value of rxpacket
            v.txdiscard := v.txdiscard or v.txpacket;   -- use new value of txpacket
            v.rxpacket  := '0';
            v.txpacket  := '0';
        end if;

        -- Clear the discard flag when the link is explicitly disabled.
        if r.ctl_linkdis = '1' then
            v.txdiscard := '0';
        end if;

        -- Extend TX cancel command until TX DMA has stopped.
        if msto.txdma_act = '0' then
            v.ctl_txcancel  := '0';
        end if;

        -- Update status registers.
        v.sta_link(0)   := linko.running or linko.started;
        v.sta_link(1)   := linko.running or linko.connecting;
        if linko.errdisc  = '1' then v.sta_errdisc := '1'; end if;
        if linko.errpar   = '1' then v.sta_errpar  := '1'; end if;
        if linko.erresc   = '1' then v.sta_erresc  := '1'; end if;
        if linko.errcred  = '1' then v.sta_errcred := '1'; end if;
        if linko.tick_out = '1' then v.sta_gottick := '1'; end if;
        if msto.int_rxdesc   = '1' then v.sta_rxdesc   := '1'; end if;
        if msto.int_txdesc   = '1' then v.sta_txdesc   := '1'; end if;
        if msto.int_rxpacket = '1' then v.sta_rxpacket := '1'; end if;
        if msto.int_rxpacket = '1' and r.rxfifo_empty = '1' then
            v.sta_rxempty   := '1';
        elsif r.rxfifo_empty = '0' then
            v.sta_rxempty   := '0';
        end if;

        -- Generate interrupt requests.
        v.irq       :=
            (r.ctl_ielink     and (linko.running xor (r.sta_link(0) and r.sta_link(1)))) or
            (r.ctl_ietick     and linko.tick_out) or
            (r.ctl_ierxdesc   and msto.int_rxdesc) or
            (r.ctl_ietxdesc   and msto.int_txdesc) or
            (r.ctl_ierxpacket and msto.int_rxpacket);

        -- APB read access.
        if apbi.psel(pindex) = '1' then
            case apbi.paddr(4 downto 2) is
                when "000" =>   -- read control register
                    v_prdata(0)     := '0';
                    v_prdata(1)     := '0';
                    v_prdata(2)     := r.ctl_linkstart;
                    v_prdata(3)     := r.ctl_autostart;
                    v_prdata(4)     := r.ctl_linkdis;
                    v_prdata(5)     := r.ctl_ticken;
                    v_prdata(6)     := '0';
                    v_prdata(7)     := '0';
                    v_prdata(8)     := r.ctl_txcancel;
                    v_prdata(9)     := r.ctl_ielink;
                    v_prdata(10)    := r.ctl_ietick;
                    v_prdata(11)    := r.ctl_ierxdesc;
                    v_prdata(12)    := r.ctl_ietxdesc;
                    v_prdata(13)    := r.ctl_ierxpacket;
                    v_prdata(27 downto 24) := std_logic_vector(to_unsigned(desctablesize, 4));
                when "001" =>   -- read status register
                    v_prdata(1 downto 0)    := r.sta_link;
                    v_prdata(2)     := r.sta_errdisc;
                    v_prdata(3)     := r.sta_errpar;
                    v_prdata(4)     := r.sta_erresc;
                    v_prdata(5)     := r.sta_errcred;
                    v_prdata(6)     := msto.rxdma_act;
                    v_prdata(7)     := msto.txdma_act;
                    v_prdata(8)     := msto.ahberror;
                    v_prdata(10)    := r.sta_gottick;
                    v_prdata(11)    := r.sta_rxdesc;
                    v_prdata(12)    := r.sta_txdesc;
                    v_prdata(13)    := r.sta_rxpacket;
                    v_prdata(14)    := r.sta_rxempty;
                when "010" =>   -- read transmission clock scaler
                    v_prdata(7 downto 0)    := r.txdivcnt;
                when "011" =>   -- read timecode register
                    v_prdata(5 downto 0)    := linko.time_out;
                    v_prdata(7 downto 6)    := linko.ctrl_out;
                    v_prdata(13 downto 8)   := r.time_in;
                    v_prdata(16 downto 14)  := "000";
                when "100" =>   -- read rx descriptor pointer
                    v_prdata(2 downto 0)    := (others => '0');
                    v_prdata(31 downto 3)   := r.rxdesc_ptr;
                when "101" =>   -- read tx descriptor pointer
                    v_prdata(2 downto 0)    := (others => '0');
                    v_prdata(31 downto 3)   := r.txdesc_ptr;
                when others =>
                    null;
            end case;
        end if;

        -- APB write access.
        if (apbi.psel(pindex) and apbi.penable and apbi.pwrite) = '1' then
            case apbi.paddr(4 downto 2) is
                when "000" =>   -- write control register
                    v.ctl_reset     := apbi.pwdata(0);
                    v.ctl_resetdma  := apbi.pwdata(1);
                    v.ctl_linkstart := apbi.pwdata(2);
                    v.ctl_autostart := apbi.pwdata(3);
                    v.ctl_linkdis   := apbi.pwdata(4);
                    v.ctl_ticken    := apbi.pwdata(5);
                    v.ctl_rxstart   := apbi.pwdata(6);
                    v.ctl_txstart   := apbi.pwdata(7);
                    if apbi.pwdata(8) = '1' then v.ctl_txcancel := '1'; end if;
                    v.ctl_ielink    := apbi.pwdata(9);
                    v.ctl_ietick    := apbi.pwdata(10);
                    v.ctl_ierxdesc  := apbi.pwdata(11);
                    v.ctl_ietxdesc  := apbi.pwdata(12);
                    v.ctl_ierxpacket := apbi.pwdata(13);
                when "001" =>   -- write status register
                    if apbi.pwdata(2) = '1' then v.sta_errdisc := '0'; end if;
                    if apbi.pwdata(3) = '1' then v.sta_errpar  := '0'; end if;
                    if apbi.pwdata(4) = '1' then v.sta_erresc  := '0'; end if;
                    if apbi.pwdata(5) = '1' then v.sta_errcred := '0'; end if;
                    if apbi.pwdata(10) = '1' then v.sta_gottick := '0'; end if;
                    if apbi.pwdata(11) = '1' then v.sta_rxdesc := '0'; end if;
                    if apbi.pwdata(12) = '1' then v.sta_txdesc := '0'; end if;
                    if apbi.pwdata(13) = '1' then v.sta_rxpacket := '0'; end if;
                when "010" =>   -- write transmission clock scaler
                    v.txdivcnt      := apbi.pwdata(7 downto 0);
                when "011" =>   -- write timecode register
                    v.time_in       := apbi.pwdata(13 downto 8);
                    if apbi.pwdata(16) = '1' then v.tick_in := '1'; end if;
                when "100" =>   -- write rx descriptor pointer
                    v.rxdesc_ptr    := apbi.pwdata(31 downto 3);
                when "101" =>   -- write tx descriptor pointer
                    v.txdesc_ptr    := apbi.pwdata(31 downto 3);
                when others =>
                    null;
            end case;
        end if;

        -- Drive control signals to RX fifo.
        s_rxfifo_raddr  <= v.rxfifo_raddr;      -- new value of rxfifo_raddr
        s_rxfifo_wen    <= r.rxfifo_write;
        s_rxfifo_waddr  <= r.rxfifo_waddr;
        s_rxfifo_wdata  <= r.rxfifo_wdata;

        -- Drive control signals to TX fifo.
        s_txfifo_raddr  <= v.txfifo_raddr;      -- new value of txfifo_raddr
        s_txfifo_wen    <= msto.txfifo_write;
        s_txfifo_waddr  <= r.txfifo_waddr;
        s_txfifo_wdata  <= msto.txfifo_wdata;

        -- Drive inputs to spwlink.
        linki.autostart <= r.ctl_autostart;
        linki.linkstart <= r.ctl_linkstart;
        linki.linkdis   <= r.ctl_linkdis;
        linki.rxroom    <= r.rxroom;
        linki.tick_in   <= r.tick_in;
        linki.ctrl_in   <= "00";
        linki.time_in   <= r.time_in;
        linki.txwrite   <= (not r.txfifo_empty) and (not r.txdiscard);
        linki.txflag    <= s_txfifo_rdata(35-v_txfifo_bytepos);
        linki.txdata    <= s_txfifo_rdata(31-8*v_txfifo_bytepos downto 24-8*v_txfifo_bytepos);

        -- Drive divcnt input to spwxmit.
        if linko.running = '1' then
            xmit_divcnt <= r.txdivcnt;
        else
            xmit_divcnt <= default_divcnt;
        end if;

        -- Drive inputs to AHB master.
        msti.rxdma_start    <= r.ctl_rxstart;
        msti.txdma_start    <= r.ctl_txstart;
        msti.txdma_cancel   <= r.ctl_txcancel;
        msti.rxdesc_ptr     <= r.rxdesc_ptr;
        msti.txdesc_ptr     <= r.txdesc_ptr;
        msti.rxfifo_rdata   <= s_rxfifo_rdata;
        msti.rxfifo_empty   <= r.rxfifo_empty;
        msti.rxfifo_nxempty <= v.rxfifo_empty;  -- new value of rxfifo_empty
        msti.txfifo_nxfull  <= r.txfifo_nxfull;
        msti.txfifo_highw   <= r.txfifo_highw;

        -- Pass tick_out signal to output port.
        tick_out        <= linko.tick_out;

        -- Drive APB output signals.
        apbo.prdata     <= v_prdata;
        apbo.pirq       <= v_irq;
        apbo.pconfig    <= pconfig;
        apbo.pindex     <= pindex;

        -- Reset components.
        ahbmst_rstn     <= rstn and (not r.ctl_reset) and (not r.ctl_resetdma);
        link_rst        <= (not rstn) or r.ctl_reset;
        xmit_rst        <= not rstn;

        -- Clear TX fifo on cancel request.
        if r.ctl_txcancel = '1' then
            v.txfifo_raddr  := (others => '0');
            v.txfifo_waddr  := (others => '0');
            v.txfifo_empty  := '1';
            v.txfifo_nxfull := '0';
            v.txfifo_highw  := '0';
            v.txfifo_bytepos := "00";
            v.txpacket      := '0';
            v.txdiscard     := '0';
        end if;

        -- Reset registers.
        if rstn = '0' or r.ctl_reset = '1' then
            v   := regs_reset;
        end if;

        -- Update registers.
        rin <= v;
    end process;


    --
    -- Update registers.
    --
    process (clk) is
    begin
        if rising_edge(clk) then
            r <= rin;
        end if;
    end process;

end architecture spwamba_arch;
