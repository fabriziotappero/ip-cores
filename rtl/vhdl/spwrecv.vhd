--
--  SpaceWire Receiver
--
--  This entity decodes the sequence of incoming data bits into tokens.
--  Data bits are passed to this entity from the Receiver Front-end
--  in groups of rxchunk bits at a time.
--
--  The bitrate of the incoming SpaceWire signal must be strictly less
--  than rxchunk times the system clock frequency. 
--

library ieee;
use ieee.std_logic_1164.all, ieee.numeric_std.all;
use work.spwpkg.all;

entity spwrecv is

    generic (
        -- Disconnect timeout, expressed in system clock cycles.
        -- Should be 850 ns (727 ns .. 1000 ns) according to the standard.
        disconnect_time: integer range 1 to 255;

        -- Nr of bits sampled per system clock.
        rxchunk:        integer range 1 to 4
    );

    port (
        -- System clock.
	clk:        in  std_logic;

        -- High to enable receiver; low to disable and reset receiver.
        rxen:       in  std_logic;

        -- Output signals to spwlink.
        recvo:      out spw_recv_out_type;

        -- High if there has been recent activity on the input lines.
        inact:      in  std_logic;

        -- High if inbits contains a valid group of received bits.
        inbvalid:   in  std_logic;

        -- Received bits from receiver front-end.
        inbits:     in  std_logic_vector(rxchunk-1 downto 0)
    );

end entity spwrecv;

architecture spwrecv_arch of spwrecv is

    -- registers
    type regs_type is record
        -- receiver state
        bit_seen:   std_ulogic;         -- got a bit transition
        null_seen:  std_ulogic;         -- got a NULL token
        -- input shift register
        bitshift:   std_logic_vector(8 downto 0);
        bitcnt:     std_logic_vector(9 downto 0);   -- one-hot counter
        -- parity flag
        parity:     std_ulogic;
        -- decoding
        control:    std_ulogic;         -- next code is control code
        escaped:    std_ulogic;         -- last code was ESC
        -- output registers
        gotfct:     std_ulogic;
        tick_out:   std_ulogic;
        rxchar:     std_ulogic;
        rxflag:     std_ulogic;
        timereg:    std_logic_vector(7 downto 0);
        datareg:    std_logic_vector(7 downto 0);
        -- disconnect timer
        disccnt:    unsigned(7 downto 0);
        -- error flags
        errpar:     std_ulogic;
        erresc:     std_ulogic;
    end record;

    -- Initial state
    constant regs_reset: regs_type := (
        bit_seen    => '0',
        null_seen   => '0',
        bitshift    => (others => '1'),
        bitcnt      => (others => '0'),
        parity      => '0',
        control     => '0',
        escaped     => '0',
        gotfct      => '0',
        tick_out    => '0',
        rxchar      => '0',
        rxflag      => '0',
        timereg     => (others => '0'),
        datareg     => (others => '0'),
        disccnt     => "00000000",
        errpar      => '0',
        erresc      => '0' );

    -- registers
    signal r:       regs_type := regs_reset;
    signal rin:     regs_type;

begin

    -- combinatorial process
    process  (r, rxen, inact, inbvalid, inbits)
        variable v:         regs_type;
        variable v_inbit:   std_ulogic;
    begin
        v           := r;
        v_inbit     := '0';

        -- disconnect timer
        if inact = '1' then
            -- activity on input; reset timer
            v.disccnt   := to_unsigned(disconnect_time, v.disccnt'length);
        elsif r.disccnt /= 0 then
            -- count down
            v.disccnt   := r.disccnt - 1;
        end if;

        -- assume no new token
        v.gotfct    := '0';
        v.tick_out  := '0';
        v.rxchar    := '0';

        if inbvalid = '1' then

            -- process incoming bits
            for i in 0 to rxchunk-1 loop
                v_inbit     := inbits(i);

                -- got a bit transition
                v.bit_seen  := '1';

                if v.bitcnt(0) = '1' then
                    -- received new token
                    -- note that this will not happen before null_seen='1'
                    if (v.parity xor v_inbit) = '0' then
                        -- Parity check failed.
                        v.errpar    := '1';
                    else
                        if v.control = '1' then
                            -- received control code
                            case v.bitshift(7 downto 6) is
                                when "00" => -- FCT or NULL
                                    v.gotfct    := not r.escaped;
                                    v.escaped   := '0';
                                when "10" => -- EOP
                                    if r.escaped = '1' then
                                        v.erresc    := '1';
                                    end if;
                                    v.escaped   := '0';
                                    v.rxchar    := not r.escaped;
                                    v.rxflag    := '1';
                                    v.datareg   := "00000000";
                                when "01" => -- EEP
                                    if r.escaped = '1' then
                                        v.erresc    := '1';
                                    end if;
                                    v.escaped   := '0';
                                    v.rxchar    := not r.escaped;
                                    v.rxflag    := '1';
                                    v.datareg   := "00000001";
                                when others => -- ESC
                                    if r.escaped = '1' then
                                        v.erresc    := '1';
                                    end if;
                                    v.escaped   := '1';
                            end case;
                        else
                            -- received 8-bit character
                            if r.escaped = '1' then
                                -- received Time-Code
                                v.tick_out  := '1';
                                v.timereg   := v.bitshift(7 downto 0);
                            else
                                -- received data character
                                v.rxflag    := '0';
                                v.rxchar    := '1';
                                v.datareg   := v.bitshift(7 downto 0);
                            end if;
                            v.escaped   := '0';
                        end if;
                    end if;
                    -- prepare for next code
                    v.parity    := '0';
                    v.control   := v_inbit;
                    if v_inbit = '1' then
                        -- next word will be control code.
                        v.bitcnt    := (3 => '1', others => '0');
                    else
                        -- next word will be a data byte.
                        v.bitcnt    := (9 => '1', others => '0');
                    end if;
                else
                    -- wait until next code is completely received;
                    -- accumulate parity
                    v.bitcnt    := '0' & v.bitcnt(9 downto 1);
                    v.parity    := v.parity xor v_inbit;
                end if;

                -- detect first NULL
                if v.null_seen = '0' then
                    if v.bitshift = "000101110" then
                        -- got first NULL pattern
                        v.null_seen := '1';
                        v.control   := v_inbit; -- should always be '1'
                        v.parity    := '0';
                        v.bitcnt    := (3 => '1', others => '0');
                    end if;
                end if;

                -- shift new bit into register.
                v.bitshift  := v_inbit & v.bitshift(v.bitshift'high downto 1);

            end loop;
        end if;

        -- synchronous reset
        if rxen = '0' then
            v.bit_seen  := '0';
            v.null_seen := '0';
            v.bitshift  := "111111111";
            v.bitcnt    := (others => '0');
            v.gotfct    := '0';
            v.tick_out  := '0';
            v.rxchar    := '0';
            v.rxflag    := '0';
            v.escaped   := '0';
            v.timereg   := "00000000";
            v.datareg   := "00000000";
            v.disccnt   := to_unsigned(0, v.disccnt'length);
            v.errpar    := '0';
            v.erresc    := '0';
        end if;

        -- drive outputs
        recvo.gotbit    <= r.bit_seen;
        recvo.gotnull   <= r.null_seen;
        recvo.gotfct    <= r.gotfct;
        recvo.tick_out  <= r.tick_out;
        recvo.ctrl_out  <= r.timereg(7 downto 6);
        recvo.time_out  <= r.timereg(5 downto 0);
        recvo.rxchar    <= r.rxchar;
        recvo.rxflag    <= r.rxflag;
        recvo.rxdata    <= r.datareg;
        if r.bit_seen = '1' and r.disccnt = 0 then
            recvo.errdisc   <= '1';
        else
            recvo.errdisc   <= '0';
        end if;
        recvo.errpar    <= r.errpar;
        recvo.erresc    <= r.erresc;

        -- update registers
        rin         <= v;

    end process;

    -- update registers on rising edge of system clock
    process (clk) is
    begin
        if rising_edge(clk) then
            r <= rin;
        end if;
    end process;

end architecture spwrecv_arch;
