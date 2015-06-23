--
--  SpaceWire Transmitter
--
--  This entity translates outgoing characters and tokens into
--  data-strobe signalling.
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.spwpkg.all;

entity spwxmit is

    port (
        -- System clock.
        clk:        in  std_logic;

        -- Synchronous reset (active-high).
        rst:        in  std_logic;

        -- Scaling factor minus 1, used to scale the system clock into the
        -- transmission bit rate. The system clock is divided by
        -- (unsigned(divcnt) + 1). Changing this signal will immediately
        -- change the transmission rate.
        divcnt:     in  std_logic_vector(7 downto 0);

        -- Input signals from spwlink.
        xmiti:      in  spw_xmit_in_type;

        -- Output signals to spwlink.
        xmito:      out spw_xmit_out_type;

        -- Data Out signal to SpaceWire bus.
        spw_do:     out std_logic;

        -- Strobe Out signal to SpaceWire bus.
        spw_so:     out std_logic
    );

end entity spwxmit;

architecture spwxmit_arch of spwxmit is

    -- Registers
    type regs_type is record
        -- tx clock
        txclken:    std_ulogic;         -- high if a bit must be transmitted
        txclkcnt:   unsigned(7 downto 0);
        -- output shift register
        bitshift:   std_logic_vector(12 downto 0);
        bitcnt:     unsigned(3 downto 0);
        -- output signals
        out_data:   std_ulogic;
        out_strobe: std_ulogic;
        -- parity flag
        parity:     std_ulogic;
        -- pending time tick
        pend_tick:  std_ulogic;
        pend_time:  std_logic_vector(7 downto 0);
        -- transmitter mode
        allow_fct:  std_ulogic;         -- allowed to send FCTs
        allow_char: std_ulogic;         -- allowed to send data and time
        sent_null:  std_ulogic;         -- sent at least one NULL token
        sent_fct:   std_ulogic;         -- sent at least one FCT token
    end record;

    -- Initial state
    constant regs_reset: regs_type := (
        txclken     => '0',
        txclkcnt    => "00000000",
        bitshift    => (others => '0'),
        bitcnt      => "0000",
        out_data    => '0',
        out_strobe  => '0',
        parity      => '0',
        pend_tick   => '0',
        pend_time   => (others => '0'),
        allow_fct   => '0',
        allow_char  => '0',
        sent_null   => '0',
        sent_fct    => '0' );

    -- Registers
    signal r:       regs_type := regs_reset;
    signal rin:     regs_type;

begin

    -- Combinatorial process
    process (r, rst, divcnt, xmiti) is
        variable v: regs_type;
    begin
        v := r;

        -- Generate TX clock.
        if r.txclkcnt = 0 then
            v.txclkcnt  := unsigned(divcnt);
            v.txclken   := '1';
        else
            v.txclkcnt  := r.txclkcnt - 1;
            v.txclken   := '0';
        end if;

        if xmiti.txen = '0' then

            -- Transmitter disabled; reset state.
            v.bitcnt     := "0000";
            v.parity     := '0';
            v.pend_tick  := '0';
            v.allow_fct  := '0';
            v.allow_char := '0';
            v.sent_null  := '0';
            v.sent_fct   := '0';

            -- Gentle reset of spacewire bus signals
            if r.txclken = '1' then
                v.out_data   := r.out_data and r.out_strobe;
                v.out_strobe := '0';
            end if;

        else
            -- Transmitter enabled.

            v.allow_fct  := (not xmiti.stnull) and r.sent_null;
            v.allow_char := (not xmiti.stnull) and r.sent_null and
                            (not xmiti.stfct) and r.sent_fct;

            -- On tick of transmission clock, put next bit on the output.
            if r.txclken = '1' then

                if r.bitcnt = 0 then

                    -- Need to start a new character.
                    if (r.allow_char = '1') and (r.pend_tick = '1') then
                        -- Send Time-Code.
                        v.out_data  := r.parity;
                        v.bitshift(12 downto 5) := r.pend_time;
                        v.bitshift(4 downto 0)  := "01111";
                        v.bitcnt    := to_unsigned(13, v.bitcnt'length);
                        v.parity    := '0';
                        v.pend_tick := '0';
                    elsif (r.allow_fct = '1') and (xmiti.fct_in = '1') then
                        -- Send FCT.
                        v.out_data  := r.parity;
                        v.bitshift(2 downto 0)  := "001";
                        v.bitcnt    := to_unsigned(3, v.bitcnt'length);
                        v.parity    := '1';
                        v.sent_fct  := '1';
                    elsif (r.allow_char = '1') and (xmiti.txwrite = '1') then
                        -- Send N-Char.
                        v.bitshift(0) := xmiti.txflag;
                        v.parity    := xmiti.txflag;
                        if xmiti.txflag = '0' then
                            -- Data byte
                            v.out_data  := not r.parity;
                            v.bitshift(8 downto 1) := xmiti.txdata;
                            v.bitcnt    := to_unsigned(9, v.bitcnt'length);
                        else
                            -- EOP or EEP
                            v.out_data  := r.parity;
                            v.bitshift(1) := xmiti.txdata(0);
                            v.bitshift(2) := not xmiti.txdata(0);
                            v.bitcnt    := to_unsigned(3, v.bitcnt'length);
                        end if;
                    else
                        -- Send NULL.
                        v.out_data  := r.parity;
                        v.bitshift(6 downto 0) := "0010111";
                        v.bitcnt    := to_unsigned(7, v.bitcnt'length);
                        v.parity    := '0';
                        v.sent_null := '1';
                    end if;

                else

                    -- Shift next bit to the output.
                    v.out_data  := r.bitshift(0);
                    v.parity    := r.parity xor r.bitshift(0);
                    v.bitshift(r.bitshift'high-1 downto 0) := r.bitshift(r.bitshift'high downto 1);
                    v.bitcnt    := r.bitcnt - 1;

                end if;

                -- Data-Strobe encoding.
                v.out_strobe := not (r.out_strobe xor r.out_data xor v.out_data);

            end if;

            -- Store requests for time tick transmission.
            if xmiti.tick_in = '1' then
                v.pend_tick := '1';
                v.pend_time := xmiti.ctrl_in & xmiti.time_in;
            end if;

        end if;

        -- Synchronous reset
        if rst = '1' then
            v := regs_reset;
        end if;

        -- Drive outputs.
        -- Note: the outputs are combinatorially dependent on certain inputs.

        -- Set fctack high if (transmitter enabled) AND
        -- (ready for token) AND (FCTs allowed) AND
        -- ((characters not allowed) OR (no timecode pending)) AND
        -- (FCT requested)
        if (xmiti.txen = '1') and
           (r.txclken = '1') and (r.bitcnt = 0) and (r.allow_fct = '1') and
           ((r.allow_char = '0') or (r.pend_tick = '0')) then
            xmito.fctack  <= xmiti.fct_in;
        else
            xmito.fctack  <= '0';
        end if;

        -- Set txrdy high if (transmitter enabled) AND
        -- (ready for token) AND (characters enabled) AND
        -- (no timecode pending) AND (no FCT requested) AND
        -- (character requested)
        if (xmiti.txen = '1') and
           (r.txclken = '1') and (r.bitcnt = 0) and (r.allow_char = '1') and
           (r.pend_tick = '0') and (xmiti.fct_in = '0') then
            xmito.txack   <= xmiti.txwrite;
        else
            xmito.txack   <= '0';
        end if;

        -- Update registers
        rin <= v;
    end process;

    -- Synchronous process
    process (clk) is
    begin
        if rising_edge(clk) then

            -- Update registers
            r <= rin;

            -- Drive spacewire output signals
            spw_do  <= r.out_data;
            spw_so  <= r.out_strobe;

        end if;
    end process;

end architecture spwxmit_arch;
