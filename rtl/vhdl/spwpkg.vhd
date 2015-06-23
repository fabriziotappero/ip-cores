--
--  SpaceWire VHDL package
--

library ieee;
use ieee.std_logic_1164.all;

package spwpkg is


    -- Indicates a platform-specific implementation.
    type spw_implementation_type is ( impl_generic, impl_fast );


    -- Input signals to spwlink.
    type spw_link_in_type is record

        -- Enables automatic link start on receipt of a NULL character.
        autostart:  std_logic;

        -- Enables link start once the Ready state is reached.
        -- Without either "autostart" or "linkstart", the link remains in
        -- state Ready.
        linkstart:  std_logic;

        -- Do not start link (overrides "linkstart" and "autostart") and/or
        -- disconnect the currently running link.
        linkdis:    std_logic;

        -- Number of bytes available in the receive buffer. Used to for
        -- flow-control operation. At least 8 bytes must be available
        -- initially, otherwise the link can not start. Values larger than 63
        -- are irrelevant and may be presented as 63. The available room may
        -- decrease by one byte due to the reception of an N-Char; in that case
        -- the "rxroom" signal must be updated on the clock following the clock
        -- on which "rxchar" is high. Under no other circumstances may "rxroom"
        -- be decreased.
        rxroom:     std_logic_vector(5 downto 0);

        -- High for one clock cycle to request transmission of a TimeCode.
        -- The request is registered inside spwxmit until it can be processed.
        tick_in:    std_logic;

        -- Control bits of the TimeCode to be sent.
        -- Must be valid while tick_in is high.
        ctrl_in:    std_logic_vector(1 downto 0);

        -- Counter value of the TimeCode to be sent.
        -- Must be valid while tick_in is high.
        time_in:    std_logic_vector(5 downto 0);

        -- Requests transmission of an N-Char.
        -- Keep this signal high until confirmed by "txack".
        txwrite:    std_logic;

        -- Control flag to be sent with the next N-Char.
        -- Must be valid while "txwrite" is high.
        txflag:     std_logic;

        -- Byte to be sent, or "00000000" for EOP or "00000001" for EEP.
        -- Must be valid while "txwrite" is high.
        txdata:     std_logic_vector(7 downto 0);
    end record;


    -- Output signals from spwlink.
    type spw_link_out_type is record

        -- High if the link state machine is currently in state Started.
        started:    std_logic;

        -- High if the link state machine is currently in state Connecting.
        connecting: std_logic;

        -- High if the link state machine is currently in state Run.
        running:    std_logic;

        -- Disconnect detected in state Run. Triggers a reset and reconnect.
        -- This indication is auto-clearing.
        errdisc:    std_logic;

        -- Parity error detected in state Run. Triggers a reset and reconnect.
        -- This indication is auto-clearing.
        errpar:     std_logic;

        -- Invalid escape sequence detected in state Run.
        -- Triggers a reset and reconnect; auto-clearing.
        erresc:     std_logic;

        -- Credit error detected. Triggers a reset and reconnect.
        -- This indication is auto-clearing.
        errcred:    std_logic;

        -- High to confirm the transmission of an N-Char.
        -- This is a Wishbone-style handshake signal. It has a combinatorial
        -- dependency on "txwrite".
        txack:      std_logic;

        -- High for one clock cycle if a TimeCode was just received.
        -- Verification of the TimeCode as described in 8.12.2 of ECSS-E-50
        -- is not implemented; all received timecodes are reported.
        tick_out:   std_logic;

        -- Control bits of last received TimeCode.
        ctrl_out:   std_logic_vector(1 downto 0);

        -- Counter value of last received TimeCode.
        time_out:   std_logic_vector(5 downto 0);

        -- High for one clock cycle if an N-Char (data byte or EOP or EEP) was
        -- just received. The data bits must be accepted immediately from
        -- "rxflag" and "rxdata".
        rxchar:     std_logic;

        -- High if the received character is EOP or EEP, low if it is a data
        -- byte. Valid when "rxchar" is high.
        rxflag:     std_logic;

        -- Received byte, or "00000000" for EOP or "00000001" for EEP.
        -- Valid when "rxchar" is high.
        rxdata:     std_logic_vector(7 downto 0);
    end record;


    -- Output signals from spwrecv to spwlink.
    type spw_recv_out_type is record

        -- High if at least one signal change was seen since enable.
        -- Resets to low when rxen is low.
        gotbit:     std_logic;

        -- High if at least one valid NULL pattern was detected since enable.
        -- Resets to low when rxen is low.
        gotnull:    std_logic;

        -- High for one clock cycle if an FCT token was just received.
        gotfct:     std_logic;

        -- High for one clock cycle if a TimeCode was just received.
        tick_out:   std_logic;

        -- Control bits of last received TimeCode.
        ctrl_out:   std_logic_vector(1 downto 0);

        -- Counter value of last received TimeCode.
        time_out:   std_logic_vector(5 downto 0);

        -- High for one clock cycle if an N-Char (data byte or EOP/EEP) was just received.
        rxchar:     std_logic;

        -- High if rxchar is high and the received character is EOP or EEP.
        -- Low if rxchar is high and the received character is a data byte.
        rxflag:     std_logic;

        -- Received byte, or "00000000" for EOP or "00000001" for EEP.
        -- Valid when "rxchar" is high.
        rxdata:     std_logic_vector(7 downto 0);

        -- Disconnect detected (after a signal change was seen).
        -- Resets to low when rxen is low or when a signal change is seen.
        errdisc:    std_logic;

        -- Parity error detected (after a valid NULL pattern was seen).
        -- Sticky; resets to low when rxen is low.
        errpar:     std_logic;

        -- Escape sequence error detected (after a valid NULL pattern was seen).
        -- Sticky; resets to low when rxen is low.
        erresc:     std_logic;
    end record;


    -- Input signals to spwxmit from spwlink.
    type spw_xmit_in_type is record

        -- High to enable transmitter; low to disable and reset transmitter.
        txen:       std_logic;

        -- Indicates that only NULL characters may be transmitted.
        stnull:     std_logic;

        -- Indicates that only NULL and/or FCT characters may be transmitted.
        stfct:      std_logic;

        -- Requests transmission of an FCT character.
        -- Keep this signal high until confirmed by "fctack".
        fct_in:     std_logic;

        -- High for one clock cycle to request transmission of a TimeCode.
        -- The request is registered inside spwxmit until it can be processed.
        tick_in:    std_logic;

        -- Control bits of the TimeCode to be sent.
        -- Must be valid while "tick_in" is high.
        ctrl_in:    std_logic_vector(1 downto 0);

        -- Counter value of the TimeCode to be sent.
        -- Must be valid while "tick_in" is high.
        time_in:    std_logic_vector(5 downto 0);

        -- Request transmission of an N-Char.
        -- Keep this signal high until confirmed by "txack".
        txwrite:    std_logic;

        -- Control flag to be sent with the next N-Char.
        -- Must be valid while "txwrite" is high.
        txflag:     std_logic;

        -- Byte to send, or "00000000" for EOP or "00000001" for EEP.
        -- Must be valid while "txwrite" is high.
        txdata:     std_logic_vector(7 downto 0);
    end record;


    -- Output signals from spwxmit to spwlink.
    type spw_xmit_out_type is record

        -- High to confirm transmission on an FCT character.
        -- This is a Wishbone-style handshaking signal; it is combinatorially
        -- dependent on "fct_in".
        fctack:     std_logic;

        -- High to confirm transmission of an N-Char.
        -- This is a Wishbone-style handshaking signal; it is combinatorially
        -- dependent on both "fct_in" and "txwrite".
        txack:      std_logic;
    end record;


    -- Character-stream interface
    component spwstream is
        generic (
            sysfreq:        real;                           -- clk freq in Hz
            txclkfreq:      real := 0.0;                    -- txclk freq in Hz
            rximpl:         spw_implementation_type := impl_generic;
            rxchunk:        integer range 1 to 4 := 1;      -- max bits per clk
            tximpl:         spw_implementation_type := impl_generic;
            rxfifosize_bits: integer range 6 to 14 := 11;   -- rx fifo size
            txfifosize_bits: integer range 2 to 14 := 11    -- tx fifo size
        );
        port (
            clk:        in  std_logic;          -- system clock
            rxclk:      in  std_logic;          -- receiver sample clock
            txclk:      in  std_logic;          -- transmit clock
            rst:        in  std_logic;          -- synchronous reset
            autostart:  in  std_logic;          -- automatic link start
            linkstart:  in  std_logic;          -- forced link start
            linkdis:    in  std_logic;          -- stop link
            txdivcnt:   in  std_logic_vector(7 downto 0);   -- tx scale factor
            tick_in:    in  std_logic;          -- request timecode xmit
            ctrl_in:    in  std_logic_vector(1 downto 0);   
            time_in:    in  std_logic_vector(5 downto 0);
            txwrite:    in  std_logic;          -- request character xmit
            txflag:     in  std_logic;          -- control flag of tx char
            txdata:     in  std_logic_vector(7 downto 0);
            txrdy:      out std_logic;          -- room in tx fifo
            txhalff:    out std_logic;          -- tx fifo half full
            tick_out:   out std_logic;          -- timecode received
            ctrl_out:   out std_logic_vector(1 downto 0);
            time_out:   out std_logic_vector(5 downto 0);
            rxvalid:    out std_logic;          -- rx fifo not empty
            rxhalff:    out std_logic;          -- rx fifo half full
            rxflag:     out std_logic;          -- control flag of rx char
            rxdata:     out std_logic_vector(7 downto 0);
            rxread:     in  std_logic;          -- accept rx character
            started:    out std_logic;          -- link in Started state
            connecting: out std_logic;          -- link in Connecting state
            running:    out std_logic;          -- link in Run state
            errdisc:    out std_logic;          -- disconnect error
            errpar:     out std_logic;          -- parity error
            erresc:     out std_logic;          -- escape error
            errcred:    out std_logic;          -- credit error
            spw_di:     in  std_logic;
            spw_si:     in  std_logic;
            spw_do:     out std_logic;
            spw_so:     out std_logic
        );
    end component spwstream;


    -- Link Level Interface
    component spwlink is
        generic (
            reset_time:      integer        -- reset time in clocks (6.4 us)
        );
        port (
            clk:        in  std_logic;      -- system clock
            rst:        in  std_logic;      -- synchronous reset (active-high)
            linki:      in  spw_link_in_type;
            linko:      out spw_link_out_type;
            rxen:       out std_logic;
            recvo:      in  spw_recv_out_type;
            xmiti:      out spw_xmit_in_type;
            xmito:      in  spw_xmit_out_type
        );
    end component spwlink;


    -- Receiver
    component spwrecv is
        generic (
            disconnect_time: integer range 1 to 255;    -- disconnect period in system clock cycles
            rxchunk:        integer range 1 to 4        -- nr of bits per system clock
        );
        port (
            clk:        in  std_logic;      -- system clock
            rxen:       in  std_logic;      -- receiver enabled
            recvo:      out spw_recv_out_type;
            inact:      in  std_logic;
            inbvalid:   in  std_logic;
            inbits:     in  std_logic_vector(rxchunk-1 downto 0)
        );
    end component spwrecv;


    -- Transmitter (generic implementation)
    component spwxmit is
        port (
            clk:        in  std_logic;      -- system clock
            rst:        in  std_logic;      -- synchronous reset (active-high)
            divcnt:     in  std_logic_vector(7 downto 0);
            xmiti:      in  spw_xmit_in_type;
            xmito:      out spw_xmit_out_type;
            spw_do:     out std_logic;      -- tx data to SPW bus
            spw_so:     out std_logic       -- tx strobe to SPW bus
        );
    end component spwxmit;


    -- Transmitter (separate tx clock domain)
    component spwxmit_fast is
        port (
            clk:        in  std_logic;      -- system clock
            txclk:      in  std_logic;      -- transmit clock
            rst:        in  std_logic;      -- synchronous reset (active-high)
            divcnt:     in  std_logic_vector(7 downto 0);
            xmiti:      in  spw_xmit_in_type;
            xmito:      out spw_xmit_out_type;
            spw_do:     out std_logic;      -- tx data to SPW bus
            spw_so:     out std_logic       -- tx strobe to SPW bus
        );
    end component spwxmit_fast;


    -- Front-end for SpaceWire Receiver (generic implementation)
    component spwrecvfront_generic is
        port (
            clk:        in  std_logic;      -- system clock
            rxen:       in  std_logic;      -- high to enable receiver
            inact:      out std_logic;      -- high if activity on input
            inbvalid:   out std_logic;      -- high if inbits contains a valid received bit
            inbits:     out std_logic_vector(0 downto 0);   -- received bit
            spw_di:     in  std_logic;      -- Data In signal from SpaceWire bus
            spw_si:     in  std_logic       -- Strobe In signal from SpaceWire bus
        );
    end component spwrecvfront_generic;


    -- Front-end for SpaceWire Receiver (separate rx clock domain)
    component spwrecvfront_fast is
        generic (
            rxchunk:        integer range 1 to 4    -- max number of bits per system clock
        );
        port (
            clk:        in  std_logic;      -- system clock
            rxclk:      in  std_logic;      -- sample clock (DDR)
            rxen:       in  std_logic;      -- high to enable receiver
            inact:      out std_logic;      -- high if activity on input
            inbvalid:   out std_logic;      -- high if inbits contains a valid group of received bits
            inbits:     out std_logic_vector(rxchunk-1 downto 0);    -- received bits
            spw_di:     in  std_logic;      -- Data In signal from SpaceWire bus
            spw_si:     in  std_logic       -- Strobe In signal from SpaceWire bus
        );
    end component spwrecvfront_fast;


    -- Synchronous two-port memory.
    component spwram is
        generic (
            abits:      integer;
            dbits:      integer );
        port (
            rclk:       in  std_logic;
            wclk:       in  std_logic;
            ren:        in  std_logic;
            raddr:      in  std_logic_vector(abits-1 downto 0);
            rdata:      out std_logic_vector(dbits-1 downto 0);
            wen:        in  std_logic;
            waddr:      in  std_logic_vector(abits-1 downto 0);
            wdata:      in  std_logic_vector(dbits-1 downto 0) );
    end component spwram;


    --  Double flip-flop synchronizer.
    component syncdff is
        port (
            clk:        in  std_logic;          -- clock (destination domain)
            rst:        in  std_logic;          -- asynchronous reset, active-high
            di:         in  std_logic;          -- input data
            do:         out std_logic );        -- output data
    end component syncdff;

end package;
