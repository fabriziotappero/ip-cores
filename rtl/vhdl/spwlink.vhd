--
--  SpaceWire Exchange Level Controller.
--
--  This entity implements exchange level aspects of the SpaceWire protocol.
--  It handles connection setup, error detection and flow control.
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.spwpkg.all;

entity spwlink is

    generic (
        -- Reset time expressed in system clock cycles.
        -- Should be 6.4 us (5.82 us .. 7.2 us) according to the standard.
        reset_time:      integer
    );

    port (
        -- System clock.
        clk:        in  std_logic;

        -- Synchronous reset (active-high).
        -- Disconnects, resets error conditions, puts the link state machine
        -- in state ErrorReset.
        rst:        in  std_logic;

        -- Link level inputs.
        linki:      in  spw_link_in_type;

        -- Link level outputs.
        linko:      out spw_link_out_type;

        -- Receiver enable signal to spwrecv.
        rxen:       out std_logic;

        -- Output signals from spwrecv.
        recvo:      in  spw_recv_out_type;

        -- Input signals for spwxmit.
        xmiti:      out spw_xmit_in_type;

        -- Output signals from spwxmit.
        xmito:      in  spw_xmit_out_type
    );

end entity spwlink;

architecture spwlink_arch of spwlink is

    -- Convert boolean to std_logic.
    type bool_to_logic_type is array(boolean) of std_ulogic;
    constant bool_to_logic: bool_to_logic_type := (false => '0', true => '1');

    -- State machine.
    type state_type is (
      S_ErrorReset, S_ErrorWait, S_Ready, S_Started, S_Connecting, S_Run );

    -- Registers
    type regs_type is record
        -- state machine
        state:          state_type;
        -- credit accounting
        tx_credit:  unsigned(5 downto 0);
        rx_credit:  unsigned(5 downto 0);
        errcred:    std_ulogic;
        -- reset timer
        timercnt:   unsigned(10 downto 0);
        timerdone:  std_ulogic;
        -- signal to transmitter
        xmit_fct_in: std_ulogic;
    end record;

    -- Initial state
    constant regs_reset: regs_type := (
        state       => S_ErrorReset,
        tx_credit   => "000000",
        rx_credit   => "000000",
        errcred     => '0',
        timercnt    => to_unsigned(reset_time, 11),
        timerdone   => '0',
        xmit_fct_in => '0' );

    signal r:       regs_type := regs_reset;
    signal rin:     regs_type;

begin

    -- Combinatorial process
    process (r, rst, linki, recvo, xmito) is
        variable v: regs_type;
        variable v_timerrst: std_logic;
    begin
        v := r;
        v_timerrst := '0';

        -- State machine.
        case r.state is

            when S_ErrorReset =>
                -- Wait for timer.
                if r.timercnt = 0 then
                    v.state     := S_ErrorWait;
                    v_timerrst  := '1';
                end if;
                v.errcred   := '0';
                v.xmit_fct_in := '0';

            when S_ErrorWait =>
                -- Wait for 2 timer periods.
                if ((recvo.errdisc or recvo.errpar or recvo.erresc) = '1') or
                   ((recvo.gotfct or recvo.tick_out or recvo.rxchar) = '1') then
                    -- Note: spwrecv will never issue errpar, erresc, gotfct,
                    -- tick_out or rxchar before the first NULL has been seen.
                    -- Therefore it's ok here to bail on those conditions
                    -- without explicitly testing got_null.
                    v.state     := S_ErrorReset;    -- error, go back to reset
                    v_timerrst  := '1';
                elsif r.timercnt = 0 then
                    if r.timerdone = '1' then
                        v.state     := S_Ready;
                        v_timerrst  := '1';
                    end if;
                end if;

            when S_Ready =>
                -- Wait for link start.
                if ((recvo.errdisc or recvo.errpar or recvo.erresc) = '1') or
                   ((recvo.gotfct or recvo.tick_out or recvo.rxchar) = '1') then
                    v.state     := S_ErrorReset;    -- error, go back to reset
                    v_timerrst  := '1';
                elsif (linki.linkdis = '0') and (r.xmit_fct_in = '1') and
                      ((linki.linkstart or (linki.autostart and recvo.gotnull)) = '1') then
                    v.state     := S_Started;       -- link enabled; start sending NULL
                    v_timerrst  := '1';
                end if;

            when S_Started =>
                -- Wait for NULL.
                if ((recvo.errdisc or recvo.errpar or recvo.erresc) = '1') or
                   ((recvo.gotfct or recvo.tick_out or recvo.rxchar) = '1') or
                   ((r.timercnt = 0) and r.timerdone = '1') then
                    v.state     := S_ErrorReset;    -- error, go back to reset
                    v_timerrst  := '1';
                elsif recvo.gotnull = '1' then
                    v.state     := S_Connecting;    -- received null, continue
                    v_timerrst  := '1';
                end if;

            when S_Connecting =>
                -- Wait for FCT.
                if ((recvo.errdisc or recvo.errpar or recvo.erresc) = '1') or
                   ((recvo.tick_out or recvo.rxchar) = '1') or
                   ((r.timercnt = 0) and r.timerdone = '1') then
                    v.state     := S_ErrorReset;    -- error, go back to reset
                    v_timerrst  := '1';
                elsif recvo.gotfct = '1' then
                    v.state     := S_Run;           -- got FCT, init completed
                end if;

            when S_Run =>
                -- All is well.
                if ((recvo.errdisc or recvo.errpar or recvo.erresc) = '1') or
                   (r.errcred = '1') or
                   (linki.linkdis = '1') then
                    v.state     := S_ErrorReset;    -- error, go back to reset
                    v_timerrst  := '1';
                end if;

            when others =>
                v.state     := S_ErrorReset;        -- recover from invalid state
                v_timerrst  := '1';

        end case;

        -- Update credit counters.
        if r.state = S_ErrorReset then

            -- reset credit
            v.tx_credit := to_unsigned(0, v.tx_credit'length);
            v.rx_credit := to_unsigned(0, v.rx_credit'length);

        else

            -- update TX credit
            if recvo.gotfct = '1' then
                -- just received a FCT token
                v.tx_credit := v.tx_credit + to_unsigned(8, v.tx_credit'length);
                if r.tx_credit > 48 then
                    -- received too many FCT tokens
                    v.errcred   := '1';
                end if;
            end if;
            if xmito.txack = '1' then
                -- just sent one byte
                v.tx_credit := v.tx_credit - to_unsigned(1, v.tx_credit'length);
            end if;

            -- update RX credit after sending FCT
            if xmito.fctack = '1' then
               -- just sent a FCT token
                v.rx_credit := v.rx_credit + to_unsigned(8, v.rx_credit'length);
            end if;

            -- decide about sending FCT tokens
            v.xmit_fct_in := bool_to_logic( (v.rx_credit <= 48) and
                                            (v.rx_credit + to_unsigned(8, v.rx_credit'length) <= unsigned(linki.rxroom)) );

            -- update RX credit after receiving character
            if recvo.rxchar = '1' then
                -- just received a character
                v.rx_credit := v.rx_credit - to_unsigned(1, v.rx_credit'length);
                if r.rx_credit = 0 then
                    -- remote transmitter violated its credit
                    v.errcred   := '1';
                end if;
            end if;

        end if;

        -- Update the initializaton reset timer.
        if v_timerrst = '1' then
            v.timercnt  := to_unsigned(reset_time, v.timercnt'length);
            v.timerdone := '0';
        else
            if r.timercnt = 0 then
                v.timercnt  := to_unsigned(reset_time, v.timercnt'length);
                v.timerdone := '1';
            else
                v.timercnt  := r.timercnt - 1;
            end if;
        end if;

        -- Reset
        if rst = '1' then
            v := regs_reset;
        end if;

        -- Drive link level outputs.
        linko.started   <= bool_to_logic(r.state = S_Started);
        linko.connecting <= bool_to_logic(r.state = S_Connecting);
        linko.running   <= bool_to_logic(r.state = S_Run);
        linko.errdisc   <= recvo.errdisc and bool_to_logic(r.state = S_Run);
        linko.errpar    <= recvo.errpar  and bool_to_logic(r.state = S_Run);
        linko.erresc    <= recvo.erresc  and bool_to_logic(r.state = S_Run);
        linko.errcred   <= r.errcred;
        linko.txack     <= xmito.txack;
        linko.tick_out  <= recvo.tick_out and bool_to_logic(r.state = S_Run);
        linko.ctrl_out  <= recvo.ctrl_out;
        linko.time_out  <= recvo.time_out;
        linko.rxchar    <= recvo.rxchar  and bool_to_logic(r.state = S_Run);
        linko.rxflag    <= recvo.rxflag;
        linko.rxdata    <= recvo.rxdata;

        -- Drive receiver inputs.
        rxen            <= bool_to_logic(r.state /= S_ErrorReset);

        -- Drive transmitter input signals.
        xmiti.txen      <= bool_to_logic(r.state = S_Started or
                                         r.state = S_Connecting or
                                         r.state = S_Run);
        xmiti.stnull    <= bool_to_logic(r.state = S_Started);
        xmiti.stfct     <= bool_to_logic(r.state = S_Connecting);
        xmiti.fct_in    <= r.xmit_fct_in;
        xmiti.tick_in   <= linki.tick_in and bool_to_logic(r.state = S_Run);
        xmiti.ctrl_in   <= linki.ctrl_in;
        xmiti.time_in   <= linki.time_in;
        xmiti.txwrite   <= linki.txwrite and bool_to_logic(r.tx_credit /= 0);
        xmiti.txflag    <= linki.txflag;
        xmiti.txdata    <= linki.txdata;

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

end architecture spwlink_arch;
