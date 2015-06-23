--
--  SpaceWire core with character-stream interface.
--
--  This entity provides a SpaceWire core with a character-stream interface.
--  The interface provides means for connection initiation, sending and
--  receiving of N-Chars and TimeCodes, and error reporting.
--
--  This entity instantiates spwlink, spwrecv, spwxmit and one of the
--  spwrecvfront implementations. It also implements a receive FIFO and
--  a transmit FIFO.
--
--  The SpaceWire standard requires that each transceiver use an initial
--  signalling rate of 10 Mbit/s. This implies that the system clock frequency
--  must be a multiple of 10 MHz. See the manual for further details on
--  bitrates and clocking.
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.spwpkg.all;

entity spwstream is

    generic (
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

        -- Size of the receive FIFO as the 2-logarithm of the number of bytes.
        -- Must be at least 6 (64 bytes).
        rxfifosize_bits: integer range 6 to 14 := 11;

        -- Size of the transmit FIFO as the 2-logarithm of the number of bytes.
        txfifosize_bits: integer range 2 to 14 := 11
    );

    port (
        -- System clock.
        clk:        in  std_logic;

        -- Receiver sample clock (only for impl_fast)
        rxclk:      in  std_logic;

        -- Transmit clock (only for impl_fast)
        txclk:      in  std_logic;

        -- Synchronous reset (active-high).
        rst:        in  std_logic;

        -- Enables automatic link start on receipt of a NULL character.
        autostart:  in  std_logic;

        -- Enables link start once the Ready state is reached.
        -- Without autostart or linkstart, the link remains in state Ready.
        linkstart:  in  std_logic;

        -- Do not start link (overrides linkstart and autostart) and/or
        -- disconnect a running link.
        linkdis:    in  std_logic;

        -- Scaling factor minus 1, used to scale the transmit base clock into
        -- the transmission bit rate. The system clock (for impl_generic) or
        -- the txclk (for impl_fast) is divided by (unsigned(txdivcnt) + 1).
        -- Changing this signal will immediately change the transmission rate.
        -- During link setup, the transmission rate is always 10 Mbit/s.
        txdivcnt:   in  std_logic_vector(7 downto 0);

        -- High for one clock cycle to request transmission of a TimeCode.
        -- The request is registered inside the entity until it can be processed.
        tick_in:    in  std_logic;

        -- Control bits of the TimeCode to be sent. Must be valid while tick_in is high.
        ctrl_in:    in  std_logic_vector(1 downto 0);

        -- Counter value of the TimeCode to be sent. Must be valid while tick_in is high.
        time_in:    in  std_logic_vector(5 downto 0);

        -- Pulled high by the application to write an N-Char to the transmit
        -- queue. If "txwrite" and "txrdy" are both high on the rising edge
        -- of "clk", a character is added to the transmit queue.
        -- This signal has no effect if "txrdy" is low.
        txwrite:    in  std_logic;

        -- Control flag to be sent with the next N_Char.
        -- Must be valid while txwrite is high.
        txflag:     in  std_logic;

        -- Byte to be sent, or "00000000" for EOP or "00000001" for EEP.
        -- Must be valid while txwrite is high.
        txdata:     in  std_logic_vector(7 downto 0);

        -- High if the entity is ready to accept an N-Char for transmission.
        txrdy:      out std_logic;

        -- High if the transmission queue is at least half full.
        txhalff:    out std_logic;

        -- High for one clock cycle if a TimeCode was just received.
        tick_out:   out std_logic;

        -- Control bits of the last received TimeCode.
        ctrl_out:   out std_logic_vector(1 downto 0);

        -- Counter value of the last received TimeCode.
        time_out:   out std_logic_vector(5 downto 0);

        -- High if "rxflag" and "rxdata" contain valid data.
        -- This signal is high unless the receive FIFO is empty.
        rxvalid:    out std_logic;

        -- High if the receive FIFO is at least half full.
        rxhalff:    out std_logic;

        -- High if the received character is EOP or EEP; low if the received
        -- character is a data byte. Valid if "rxvalid" is high.
        rxflag:     out std_logic;

        -- Received byte, or "00000000" for EOP or "00000001" for EEP.
        -- Valid if "rxvalid" is high.
        rxdata:     out std_logic_vector(7 downto 0);

        -- Pulled high by the application to accept a received character.
        -- If "rxvalid" and "rxread" are both high on the rising edge of "clk",
        -- a character is removed from the receive FIFO and "rxvalid", "rxflag"
        -- and "rxdata" are updated.
        -- This signal has no effect if "rxvalid" is low.
        rxread:     in  std_logic;

        -- High if the link state machine is currently in the Started state.
        started:    out std_logic;

        -- High if the link state machine is currently in the Connecting state.
        connecting: out std_logic;

        -- High if the link state machine is currently in the Run state, indicating
        -- that the link is fully operational. If none of started, connecting or running
        -- is high, the link is in an initial state and the transmitter is not yet enabled.
        running:    out std_logic;

        -- Disconnect detected in state Run. Triggers a reset and reconnect of the link.
        -- This indication is auto-clearing.
        errdisc:    out std_logic;

        -- Parity error detected in state Run. Triggers a reset and reconnect of the link.
        -- This indication is auto-clearing.
        errpar:     out std_logic;

        -- Invalid escape sequence detected in state Run. Triggers a reset and reconnect of
        -- the link. This indication is auto-clearing.
        erresc:     out std_logic;

        -- Credit error detected. Triggers a reset and reconnect of the link.
        -- This indication is auto-clearing.
        errcred:    out std_logic;

        -- Data In signal from SpaceWire bus.
        spw_di:     in  std_logic;

        -- Strobe In signal from SpaceWire bus.
        spw_si:     in  std_logic;

        -- Data Out signal to SpaceWire bus.
        spw_do:     out std_logic;

        -- Strobe Out signal to SpaceWire bus.
        spw_so:     out std_logic
    );

end entity spwstream;

architecture spwstream_arch of spwstream is

    -- Convert boolean to std_logic.
    type bool_to_logic_type is array(boolean) of std_ulogic;
    constant bool_to_logic: bool_to_logic_type := (false => '0', true => '1');

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
        -- FIFO pointers
        rxfifo_raddr:   std_logic_vector(rxfifosize_bits-1 downto 0);
        rxfifo_waddr:   std_logic_vector(rxfifosize_bits-1 downto 0);
        txfifo_raddr:   std_logic_vector(txfifosize_bits-1 downto 0);
        txfifo_waddr:   std_logic_vector(txfifosize_bits-1 downto 0);
        -- FIFO state
        rxfifo_rvalid:  std_logic;      -- '1' if s_rxfifo_rdata is valid
        txfifo_rvalid:  std_logic;      -- '1' if s_txfifo_rdata is valid
        rxfull:         std_logic;      -- '1' if RX fifo is full
        rxhalff:        std_logic;      -- '1' if RX fifo is at least half full
        txfull:         std_logic;      -- '1' if TX fifo is full
        txhalff:        std_logic;      -- '1' if TX fifo is at least half full
        rxroom:         std_logic_vector(5 downto 0);
    end record;

    constant regs_reset: regs_type := (
        rxpacket        => '0',
        rxeep           => '0',
        txpacket        => '0',
        txdiscard       => '0',
        rxfifo_raddr    => (others => '0'),
        rxfifo_waddr    => (others => '0'),
        txfifo_raddr    => (others => '0'),
        txfifo_waddr    => (others => '0'),
        rxfifo_rvalid   => '0',
        txfifo_rvalid   => '0',
        rxfull          => '0',
        rxhalff         => '0',
        txfull          => '0',
        txhalff         => '0',
        rxroom          => (others => '0') );

    signal r: regs_type := regs_reset;
    signal rin: regs_type;

    -- Interface signals to components.
    signal recv_rxen:       std_logic;
    signal recvo:           spw_recv_out_type;
    signal recv_inact:      std_logic;
    signal recv_inbvalid:   std_logic;
    signal recv_inbits:     std_logic_vector(rxchunk-1 downto 0);
    signal xmiti:           spw_xmit_in_type;
    signal xmito:           spw_xmit_out_type;
    signal xmit_divcnt:     std_logic_vector(7 downto 0);
    signal linki:           spw_link_in_type;
    signal linko:           spw_link_out_type;

    -- Memory interface signals.
    signal s_rxfifo_raddr:  std_logic_vector(rxfifosize_bits-1 downto 0);
    signal s_rxfifo_rdata:  std_logic_vector(8 downto 0);
    signal s_rxfifo_wen:    std_logic;
    signal s_rxfifo_waddr:  std_logic_vector(rxfifosize_bits-1 downto 0);
    signal s_rxfifo_wdata:  std_logic_vector(8 downto 0);
    signal s_txfifo_raddr:  std_logic_vector(txfifosize_bits-1 downto 0);
    signal s_txfifo_rdata:  std_logic_vector(8 downto 0);
    signal s_txfifo_wen:    std_logic;
    signal s_txfifo_waddr:  std_logic_vector(txfifosize_bits-1 downto 0);
    signal s_txfifo_wdata:  std_logic_vector(8 downto 0);

begin

    -- Instantiate link controller.
    link_inst: spwlink
        generic map (
            reset_time  => reset_time )
        port map (
            clk         => clk,
            rst         => rst,
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

    -- Instantiate transmitter.
    xmit_sel0: if tximpl = impl_generic generate
        xmit_inst: spwxmit
            port map (
                clk     => clk,
                rst     => rst,
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
                rst     => rst,
                divcnt  => xmit_divcnt,
                xmiti   => xmiti,
                xmito   => xmito,
                spw_do  => spw_do,
                spw_so  => spw_so );
    end generate;

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

    -- Instantiate RX memory.
    rxmem: spwram
        generic map (
            abits       => rxfifosize_bits,
            dbits       => 9 )
        port map (
            rclk        => clk,
            wclk        => clk,
            ren         => '1',
            raddr       => s_rxfifo_raddr,
            rdata       => s_rxfifo_rdata,
            wen         => s_rxfifo_wen,
            waddr       => s_rxfifo_waddr,
            wdata       => s_rxfifo_wdata );

    -- Instantiate TX memory.
    txmem: spwram
        generic map (
            abits       => txfifosize_bits,
            dbits       => 9 )
        port map (
            rclk        => clk,
            wclk        => clk,
            ren         => '1',
            raddr       => s_txfifo_raddr,
            rdata       => s_txfifo_rdata,
            wen         => s_txfifo_wen,
            waddr       => s_txfifo_waddr,
            wdata       => s_txfifo_wdata );

    -- Combinatorial process
    process (r, linko, s_rxfifo_rdata, s_txfifo_rdata, rst, autostart, linkstart, linkdis, txdivcnt, tick_in, ctrl_in, time_in, txwrite, txflag, txdata, rxread)  is
        variable v:             regs_type;
        variable v_tmprxroom:   unsigned(rxfifosize_bits-1 downto 0);
        variable v_tmptxroom:   unsigned(txfifosize_bits-1 downto 0);
    begin
        v           := r;
        v_tmprxroom := to_unsigned(0, v_tmprxroom'length);
        v_tmptxroom := to_unsigned(0, v_tmptxroom'length);

        -- Keep track of whether we are sending and/or receiving a packet.
        if linko.rxchar = '1' then
            -- got character
            v.rxpacket  := not linko.rxflag;
        end if;
        if linko.txack = '1' then
            -- send character
            v.txpacket  := not s_txfifo_rdata(8);
        end if;

        -- Update RX fifo pointers.
        if (rxread = '1') and (r.rxfifo_rvalid = '1') then
            -- read from fifo
            v.rxfifo_raddr  := std_logic_vector(unsigned(r.rxfifo_raddr) + 1);
        end if;
        if r.rxfull = '0' then
            if (linko.rxchar = '1') or (r.rxeep = '1') then
                -- write to fifo (received char or pending EEP)
                v.rxfifo_waddr  := std_logic_vector(unsigned(r.rxfifo_waddr) + 1);
            end if;
            v.rxeep         := '0';
        end if;

        -- Keep track of whether the RX fifo contains valid data.
        -- (use new value of rxfifo_raddr)
        v.rxfifo_rvalid := bool_to_logic(v.rxfifo_raddr /= r.rxfifo_waddr);

        -- Update room in RX fifo (use new value of rxfifo_waddr).
        v_tmprxroom := unsigned(r.rxfifo_raddr) - unsigned(v.rxfifo_waddr) - 1;
        v.rxfull    := bool_to_logic(v_tmprxroom = 0);
        v.rxhalff   := not v_tmprxroom(v_tmprxroom'high);
        if v_tmprxroom > 63 then
            v.rxroom    := (others => '1');
        else
            v.rxroom    := std_logic_vector(v_tmprxroom(5 downto 0));
        end if;

        -- Update TX fifo pointers.
        if (r.txfifo_rvalid = '1') and ((linko.txack = '1') or (r.txdiscard = '1')) then
            -- read from fifo
            v.txfifo_raddr  := std_logic_vector(unsigned(r.txfifo_raddr) + 1);
            if s_txfifo_rdata(8) = '1' then
                v.txdiscard := '0';     -- got EOP/EEP, stop discarding data
            end if;
        end if;
        if (r.txfull = '0') and (txwrite = '1') then
            -- write to fifo
            v.txfifo_waddr  := std_logic_vector(unsigned(r.txfifo_waddr) + 1);
        end if;

        -- Keep track of whether the TX fifo contains valid data.
        -- (use new value of txfifo_raddr)
        v.txfifo_rvalid := bool_to_logic(v.txfifo_raddr /= r.txfifo_waddr);

        -- Update room in TX fifo (use new value of txfifo_waddr).
        v_tmptxroom := unsigned(r.txfifo_raddr) - unsigned(v.txfifo_waddr) - 1;
        v.txfull    := bool_to_logic(v_tmptxroom = 0);
        v.txhalff   := not v_tmptxroom(v_tmptxroom'high);
 
        -- If the link is lost, set a flag to discard the current packet.
        if linko.running = '0' then
            v.rxeep     := v.rxeep or v.rxpacket;       -- use new value of rxpacket
            v.txdiscard := v.txdiscard or v.txpacket;   -- use new value of txpacket
            v.rxpacket  := '0';
            v.txpacket  := '0';
        end if;

        -- Clear the discard flag when the link is explicitly disabled.
        if linkdis = '1' then
            v.txdiscard := '0';
        end if;

        -- Drive control signals to RX fifo.
        s_rxfifo_raddr  <= v.rxfifo_raddr;  -- using new value of rxfifo_raddr
        s_rxfifo_wen    <= (not r.rxfull) and (linko.rxchar or r.rxeep);
        s_rxfifo_waddr  <= r.rxfifo_waddr;
        if r.rxeep = '1' then
            s_rxfifo_wdata  <= "100000001";
        else
            s_rxfifo_wdata  <= linko.rxflag & linko.rxdata;
        end if;

        -- Drive control signals to TX fifo.
        s_txfifo_raddr  <= v.txfifo_raddr;  -- using new value of txfifo_raddr
        s_txfifo_wen    <= (not r.txfull) and txwrite;
        s_txfifo_waddr  <= r.txfifo_waddr;
        s_txfifo_wdata  <= txflag & txdata;

        -- Drive inputs to spwlink.
        linki.autostart <= autostart;
        linki.linkstart <= linkstart;
        linki.linkdis   <= linkdis;
        linki.rxroom    <= r.rxroom;
        linki.tick_in   <= tick_in;
        linki.ctrl_in   <= ctrl_in;
        linki.time_in   <= time_in;
        linki.txwrite   <= r.txfifo_rvalid and not r.txdiscard;
        linki.txflag    <= s_txfifo_rdata(8);
        linki.txdata    <= s_txfifo_rdata(7 downto 0);

        -- Drive divcnt input to spwxmit.
        if linko.running = '1' then
            xmit_divcnt <= txdivcnt;
        else
            xmit_divcnt <= default_divcnt;
        end if;

        -- Drive outputs.
        txrdy       <= not r.txfull;
        txhalff     <= r.txhalff;
        tick_out    <= linko.tick_out;
        ctrl_out    <= linko.ctrl_out;
        time_out    <= linko.time_out;
        rxvalid     <= r.rxfifo_rvalid;
        rxhalff     <= r.rxhalff;
        rxflag      <= s_rxfifo_rdata(8);
        rxdata      <= s_rxfifo_rdata(7 downto 0);
        started     <= linko.started;
        connecting  <= linko.connecting;
        running     <= linko.running;
        errdisc     <= linko.errdisc;
        errpar      <= linko.errpar;
        erresc      <= linko.erresc;
        errcred     <= linko.errcred;

        -- Reset.
        if rst = '1' then
            v.rxpacket      := '0';
            v.rxeep         := '0';
            v.txpacket      := '0';
            v.txdiscard     := '0';
            v.rxfifo_raddr  := (others => '0');
            v.rxfifo_waddr  := (others => '0');
            v.txfifo_raddr  := (others => '0');
            v.txfifo_waddr  := (others => '0');
            v.rxfifo_rvalid := '0';
            v.txfifo_rvalid := '0';
        end if;

        -- Update registers.
        rin <= v;
    end process;

    -- Update registers.
    process (clk) is
    begin
        if rising_edge(clk) then
            r <= rin;
        end if;
    end process;

end architecture spwstream_arch;
