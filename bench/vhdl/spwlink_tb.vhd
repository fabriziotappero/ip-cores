--
-- Test Bench for Link interface.
--
-- Unfortunately rather incomplete.
-- The following items are verified:
--  * reset;
--  * link start, NULL exchange, FCT exchange;
--  * link autostart on first NULL;
--  * send/receive time codes, data characters, EOP/EEP;
--  * detection of timeout, disconnection, parity error, escape error.
--

library ieee;
use ieee.std_logic_1164.all, ieee.numeric_std.all;
use std.textio.all;
use work.spwpkg.all;

entity spwlink_tb is

    -- Tests should be done with several different combinations
    -- of values for the generics.
    generic (

        -- System clock frequency
        sys_clock_freq: real        := 20.0e6 ;

        -- Receiver sample clock frequency
        rx_clock_freq:  real        := 20.0e6 ;

        -- Transmitter clock frequency
        tx_clock_freq:  real        := 20.0e6 ;

        -- Input bit rate
        input_rate:     real        := 10.0e6 ;

        -- TX clock division factor (actual factor is one tx_clock_div+1)
        tx_clock_div:   integer     := 1 ;

        -- Receiver implementation
        rximpl: spw_implementation_type := impl_generic ;

        -- Bits per sysclk for fast receiver
        rxchunk:        integer     := 1 ;

        -- Transmitter implementation
        tximpl: spw_implementation_type := impl_generic ;

        -- Wait before starting test bench
        startwait:      time        := 0 sec
    );

end spwlink_tb;

architecture tb_arch of spwlink_tb is

    -- Bit periods for incoming / outgoing signal
    constant inbit_period:      time    := (1 sec) / input_rate ;
    constant outbit_period:     time    := (1 sec) * real(tx_clock_div + 1) / tx_clock_freq ;
    constant txclk_period:      time    := (1 sec) / tx_clock_freq ;

    -- clock generation
    signal sys_clock_enable: std_logic := '0';
    signal sysclk:           std_logic;
    signal rxclk:            std_logic;
    signal txclk:            std_logic;

    -- output monitoring
    type t_output_chars is array(natural range <>) of std_logic_vector(9 downto 0);
    signal output_collect:   std_logic;
    signal output_ptr:       integer;
    signal output_bits:      std_logic_vector(0 to 4095);
    signal output_nchars:    integer;
    signal output_chars:     t_output_chars(0 to 4095);

    -- input generation
    signal input_par:        std_logic;
    signal input_idle:       std_logic;
    signal input_pattern:    integer := 0;
    signal input_strobeflip: std_logic := '0';

    -- interconnect signals
    signal s_linki:     spw_link_in_type;
    signal s_linko:     spw_link_out_type;
    signal s_rxen:      std_logic;
    signal s_recvo:     spw_recv_out_type;
    signal s_xmiti:     spw_xmit_in_type;
    signal s_xmito:     spw_xmit_out_type;
    signal s_inact:     std_logic;
    signal s_inbvalid:  std_logic;
    signal s_inbits:    std_logic_vector(rxchunk-1 downto 0);

    -- interface signals
    signal rst:       std_logic := '1';
    signal autostart: std_logic;
    signal linkstart: std_logic;
    signal linkdis:   std_logic;
    signal divcnt:    std_logic_vector(7 downto 0) := (others => '0');
    signal tick_in:   std_logic;
    signal ctrl_in:   std_logic_vector(1 downto 0);
    signal time_in:   std_logic_vector(5 downto 0);
    signal rxroom:    std_logic_vector(5 downto 0);
    signal txwrite:   std_logic;
    signal txflag:    std_logic;
    signal txdata:    std_logic_vector(7 downto 0);
    signal txrdy:     std_logic;
    signal tick_out:  std_logic;
    signal ctrl_out:  std_logic_vector(1 downto 0);
    signal time_out:  std_logic_vector(5 downto 0);
    signal rxchar:    std_logic;
    signal rxflag:    std_logic;
    signal rxdata:    std_logic_vector(7 downto 0);
    signal started:   std_logic;
    signal connecting:std_logic;
    signal running:   std_logic;
    signal errdisc:   std_logic;
    signal errpar:    std_logic;
    signal erresc:    std_logic;
    signal errcred:   std_logic;
    signal spw_di:    std_logic;
    signal spw_si:    std_logic;
    signal spw_do:    std_logic;
    signal spw_so:    std_logic;

    -- misc
    signal errany:    std_logic;

    procedure print(i: integer) is
        variable v: LINE;
    begin
        write(v, i);
        writeline(output, v);
    end procedure;

    procedure print(x: std_logic_vector) is
        variable v: LINE;
    begin
        write(v, to_bitvector(x));
        writeline(output, v);
    end procedure;

    procedure prints(s: string) is
        variable v: LINE;
    begin
        write(v, s);
        writeline(output, v);
    end procedure;

    procedure print(lbl: string; x: integer) is
        variable v: LINE;
    begin
        write(v, lbl & " = ");
        write(v, x);
        writeline(output, v);
    end procedure;

    procedure print(lbl: string; x: real) is
        variable v: LINE;
    begin
        write(v, lbl & " = ");
        write(v, x);
        writeline(output, v);
    end procedure;

begin

    -- Instantiate components.

    spwlink_inst: spwlink
        generic map (
            reset_time =>      integer(sys_clock_freq * 0.0000064) )  -- 6.4 us
        port map (
            clk     => sysclk,
            rst     => rst,
            linki   => s_linki,
            linko   => s_linko,
            rxen    => s_rxen,
            recvo   => s_recvo,
            xmiti   => s_xmiti,
            xmito   => s_xmito );

    spwrecv_inst: spwrecv
        generic map (
            disconnect_time => integer(sys_clock_freq * 0.00000085),   -- 850 ns
            rxchunk => rxchunk )
        port map (
            clk     => sysclk,
            rxen    => s_rxen,
            recvo   => s_recvo,
            inact   => s_inact,
            inbvalid => s_inbvalid,
            inbits  => s_inbits );

    spwxmit_if: if tximpl = impl_generic generate
        spwxmit_inst: spwxmit
            port map (
                clk     => sysclk,
                rst     => rst,
                divcnt  => divcnt,
                xmiti   => s_xmiti,
                xmito   => s_xmito,
                spw_so  => spw_so,
                spw_do  => spw_do );
    end generate;
    spwxmit_fast_if: if tximpl = impl_fast generate
        spwxmit_fast_inst: spwxmit_fast
            port map (
                clk     => sysclk,
                txclk   => txclk,
                rst     => rst,
                divcnt  => divcnt,
                xmiti   => s_xmiti,
                xmito   => s_xmito,
                spw_so  => spw_so,
                spw_do  => spw_do );
    end generate;

    spwrecvfront_generic_if: if rximpl = impl_generic generate
        spwrecvfront_generic_inst: spwrecvfront_generic
            port map (
                clk     => sysclk,
                rxen    => s_rxen,
                inact   => s_inact,
                inbvalid => s_inbvalid,
                inbits  => s_inbits,
                spw_di  => spw_di,
                spw_si  => spw_si );
    end generate;
    spwrecvfront_fast_if: if rximpl = impl_fast generate
        spwrecvfront_fast_inst: spwrecvfront_fast
            generic map (
                rxchunk => rxchunk )
            port map (
                clk     => sysclk,
                rxclk   => rxclk,
                rxen    => s_rxen,
                inact   => s_inact,
                inbvalid => s_inbvalid,
                inbits  => s_inbits,
                spw_di  => spw_di,
                spw_si  => spw_si );
    end generate;

    s_linki <= ( autostart  => autostart,
                 linkstart  => linkstart,
                 linkdis    => linkdis,
                 rxroom     => rxroom,
                 tick_in    => tick_in,
                 ctrl_in    => ctrl_in,
                 time_in    => time_in,
                 txwrite    => txwrite,
                 txflag     => txflag,
                 txdata     => txdata );
    started     <= s_linko.started;
    connecting  <= s_linko.connecting;
    running     <= s_linko.running;
    errdisc     <= s_linko.errdisc;
    errpar      <= s_linko.errpar;
    erresc      <= s_linko.erresc;
    errcred     <= s_linko.errcred;
    txrdy       <= s_linko.txack;
    tick_out    <= s_linko.tick_out;
    ctrl_out    <= s_linko.ctrl_out;
    time_out    <= s_linko.time_out;
    rxchar      <= s_linko.rxchar;
    rxflag      <= s_linko.rxflag;
    rxdata      <= s_linko.rxdata;

    -- Logic OR of all error signals.
    errany <= errdisc or errpar or erresc or errcred;

    -- Generate system clock.
    process is
    begin
        if sys_clock_enable /= '1' then
            wait until sys_clock_enable = '1';
        end if;
        sysclk <= '1';
        wait for (0.5 sec) / sys_clock_freq;
        sysclk <= '0';
        wait for (0.5 sec) / sys_clock_freq;
    end process;

    -- Generate rx sample clock.
    process is
    begin
        if sys_clock_enable /= '1' then
            wait until sys_clock_enable = '1';
        end if;
        rxclk <= '1';
        wait for (0.5 sec) / rx_clock_freq;
        rxclk <= '0';
        wait for (0.5 sec) / rx_clock_freq;
    end process;

    -- Generate tx clock.
    process is
    begin
        if sys_clock_enable /= '1' then
            wait until sys_clock_enable = '1';
        end if;
        txclk <= '1';
        wait for (0.5 sec) / tx_clock_freq;
        txclk <= '0';
        wait for (0.5 sec) / tx_clock_freq;
    end process;

    -- Collect output bits on SPW_DO and SPW_SO.
    process is
        variable t_last: time;
        variable output_last_do: std_logic;
        variable output_last_so: std_logic;
    begin
        if output_collect = '1' then
            -- wait for next bit
            if output_ptr <= output_bits'high then
                output_bits(output_ptr) <= spw_do;
                output_ptr <= output_ptr + 1;
            end if;
            output_last_do := spw_do;
            output_last_so := spw_so;
            t_last := now;
            wait until (output_collect = '0') or (output_last_do /= spw_do) or (output_last_so /= spw_so);
            if output_collect = '1' and output_ptr > 1 then
                assert now > t_last + outbit_period - 1 ns
                    report "output bit period too short";
                assert now < t_last + outbit_period + 1 ns
                    report "output bit period too long";
            end if;
        else
            -- reset
            output_ptr <= 0;
            output_last_do := '0';
            output_last_so := '0';
            wait until output_collect = '1';
        end if;
    end process;

    -- Collect received data on rxdata and tick_out.
    process is
    begin
        wait until ((output_collect = '1') and rising_edge(sysclk)) or
                   ((output_collect = '0') and (output_nchars /= 0));
        if output_collect = '0' then
            output_nchars <= 0;
        elsif rising_edge(sysclk) and (output_nchars <= output_chars'high) then
            assert (rxchar = '0') or (tick_out = '0');
            if tick_out = '1' then
                output_chars(output_nchars) <= "10" & ctrl_out & time_out;
                output_nchars <= output_nchars + 1;
            elsif rxchar = '1' then
                output_chars(output_nchars) <= "0" & (rxflag) & rxdata;
                output_nchars <= output_nchars + 1;
            end if;
        end if;
    end process;

    -- Generate input data.
    process is
        procedure input_reset is
        begin
            spw_di <= '0';
            spw_si <= input_strobeflip;
            input_par <= '0';
        end procedure;
        procedure genbit(b: std_logic) is
        begin
            spw_si <= not (spw_si xor spw_di xor b);
            spw_di <= b;
            wait for inbit_period;
        end procedure;
        procedure genfct is
        begin
            genbit(input_par);
            genbit('1');
            genbit('0');
            input_par <= '0';
            genbit('0');
        end procedure;
        procedure genesc is
        begin
            genbit(input_par);
            genbit('1');
            genbit('1');
            input_par <= '0';
            genbit('1');
        end procedure;
        procedure geneop(e: std_logic) is
        begin
            genbit(input_par);
            genbit('1');
            genbit(e);
            input_par <= '1';
            genbit(not e);
        end procedure;
        procedure gendat(dat: std_logic_vector(7 downto 0)) is
        begin
            genbit(not input_par);
            genbit('0');
            genbit(dat(0)); genbit(dat(1)); genbit(dat(2)); genbit(dat(3));
            genbit(dat(4)); genbit(dat(5)); genbit(dat(6));
            input_par <= dat(0) xor dat(1) xor dat(2) xor dat(3) xor
                         dat(4) xor dat(5) xor dat(6) xor dat(7);
            genbit(dat(7));
        end procedure;
    begin
        input_idle <= '1';
        input_reset;
        wait until input_pattern /= 0;
        input_idle <= '0';
        while input_pattern /= 0 loop
            if input_pattern = 1 then
                -- NULL tokens
                genesc; genfct;
            elsif input_pattern = 2 then
                -- FCT tokens
                genfct;
            elsif input_pattern = 3 then
                -- invalid bit pattern
                genbit('0');
                genbit('1');
            elsif input_pattern = 4 then
                -- EOP token
                geneop('0');
            elsif input_pattern = 5 then
                -- FCT, TIME, 8 chars, NULLs
                genfct;
                genesc; gendat("00111000");
                gendat("01010101");
                gendat("10101010");
                gendat("01010101");
                gendat("10101010");
                gendat("01010101");
                gendat("10101010");
                gendat("01010101");
                gendat("10101010");
                while input_pattern = 5 loop
                    genesc; genfct;
                end loop;
            elsif input_pattern = 6 then
                -- ESC tokens
                genesc;
            elsif input_pattern = 7 then
                -- FCT, NULL, NULL, EOP, EEP, NULLs
                genfct;
                genesc; genfct;
                genesc; genfct;
                geneop('0');
                geneop('1');
                while input_pattern = 7 loop
                    genesc; genfct;
                end loop;
            elsif input_pattern = 8 then
                -- FCT, NULL, NULL, NULL, NULL, NULL, char, parity error
                genfct;
                genesc; genfct;
                genesc; genfct;
                genesc; genfct;
                genesc; genfct;
                genesc; genfct;
                gendat("01010101");
                genbit(not input_par);
                genbit('0');
                genbit('1'); genbit('0'); genbit('1'); genbit('0');
                genbit('1'); genbit('0'); genbit('1');
                input_par <= '1'; -- wrong parity !!
                genbit('0');
                while input_pattern = 8 loop
                    genesc; genfct;
                end loop;
            elsif input_pattern = 9 then
                -- FCT, FCT, NULLs
                genfct;
                genfct;
                while input_pattern = 9 loop
                    genesc; genfct;
                end loop;
            elsif input_pattern = 10 then
                -- data and strobe both high
                spw_di <= '1';
                spw_si <= not input_strobeflip;
                wait until input_pattern /= 10;
             else
                assert false;
            end if;
        end loop;
    end process;

    -- Main process.
    process is

        -- Skip NULL tokens and return position of first non-NULL.
        function skip_null(data: in std_logic_vector; start: in integer; len: in integer) return integer is
            variable i: integer;
        begin
            i := start;
            if (i + 7 < len) and (data((i+1) to (i+7)) = "1110100") then
                i := i + 8;
            end if;
            while (i + 7 < len) and (data(i to (i+7)) = "01110100") loop
                i := i + 8;
            end loop;
            return i;
        end function;

        function check_parity(data: in std_logic_vector; start: in integer; len: in integer) return boolean is
            variable i: integer;
            variable p: std_logic;
        begin
            i := start;
            p := data(start);
            while i + 3 < len loop
                if data(i+1) = '1' then
                    if data(0) /= p then return false; end if;
                    p := data(2) xor data(3);
                    i := i + 4;
                else
                    if i + 9 < len then return true; end if;
                    if data(0) /= not p then return false; end if;
                    p := not (data(2) xor data(3) xor data(4) xor data(5) xor
                              data(6) xor data(7) xor data(8) xor data(9));
                    i := i + 10;
                end if;
            end loop;
            return true;
        end function;

        variable i: integer;

    begin

        -- Wait for start of test.
        wait for startwait;

        -- Initialize.
        rst <= '1';
        input_pattern <= 0;
        input_strobeflip <= '0';
        sys_clock_enable <= '1';
        output_collect <= '0';

        -- Say hello
        report "Starting spwlink test bench";
        print("  sys_clock_freq", sys_clock_freq);
        print("  rx_clock_freq ", rx_clock_freq);
        print("  tx_clock_freq ", tx_clock_freq);
        print("  input_rate    ", input_rate);
        print("  tx_clock_div  ", tx_clock_div);
        case rximpl is
            when impl_generic => prints("  rximpl         = impl_generic");
            when impl_fast =>    prints("  rximpl         = impl_fast");
        end case;
        print("  rxchunk       ", rxchunk);
        case tximpl is
            when impl_generic => prints("  tximpl         = impl_generic");
            when impl_fast =>    prints("  tximpl         = impl_fast");
        end case;

        -- Test 1: Reset.
        autostart <= '0'; linkstart <= '0'; linkdis <= '0';
        divcnt <= std_logic_vector(to_unsigned(tx_clock_div, divcnt'length));
        tick_in <= '0'; ctrl_in <= "00"; time_in <= "000000"; rxroom <= "000000";
        txwrite <= '0'; txflag <= '0'; txdata <= "00000000";
        wait until rising_edge(sysclk);
        wait until rising_edge(sysclk);
        wait for 1 ns;
        rst <= '0';
        assert (txrdy = '0')        report " 1. reset (txrdy = 0)";
        assert (tick_out = '0')     report " 1. reset (tick_out = 0)";
        assert (rxchar = '0')       report " 1. reset (rxchar = 0)";
        assert (started = '0')      report " 1. reset (started = 0)";
        assert (connecting = '0')   report " 1. reset (connecting = 0)";
        assert (running = '0')      report " 1. reset (running = 0)";
        assert (errdisc = '0')      report " 1. reset (errdisc = 0)";
        assert (errpar = '0')       report " 1. reset (errpar = 0)";
        assert (erresc = '0')       report " 1. reset (erresc = 0)";
        assert (errcred = '0')      report " 1. reset (errcred = 0)";
        assert (spw_do = '0')       report " 1. reset (spw_do = 0)";
        assert (spw_so = '0')       report " 1. reset (spw_so = 0)";

        -- Test 2: Remain idle after one clock cycle.
        wait until rising_edge(sysclk);
        wait until falling_edge(sysclk);
        assert (started = '0') and (running = '0')
            report " 2. init (state)";
        assert (spw_do =  '0') and (spw_so = '0')
            report " 2. init (SPW idle)";

        -- Test 3: Move to Ready state.
        wait on started, running, spw_do, spw_so for 50 us;
        assert (started = '0') and (running = '0')
            report " 3. ready (state)";
        assert (spw_do = '0') and (spw_so = '0')
            report " 3. ready (SPW idle)";

        -- Test 4: Start link; wait for NULL patterns.
        linkstart <= '1';
        rxroom <= "001111";
        wait on started, connecting, running, spw_do, spw_so for 1 us;
        assert (started = '1') and (running = '0')
            report " 4. nullgen (started)";
        if spw_so = '0' then
            wait on started, connecting, running, spw_do, spw_so for 1.2 us;
        end if;
        assert (started = '1') and (connecting = '0') and (running = '0') and
               (spw_do = '0') and (spw_so = '1')
            report " 4. nullgen (SPW strobe)";
        output_collect <= '1';
        wait on started, connecting, running for (7.1 * outbit_period);
        assert (started = '1') and (running = '0')
            report " 4. nullgen (state 2)";
        assert (output_ptr = 8) and (output_bits(0 to 7) = "01110100")
            report " 4. nullgen (NULL 1)";
        -- got the first NULL, wait for the second one ...
        wait on started, connecting, running for (8.0 * outbit_period);
        assert (started = '1') and (running = '0')
            report " 4. nullgen (state 3)";
        assert (output_ptr = 16) and (output_bits(8 to 15) = "01110100")
            report " 4. nullgen (NULL 2)";
        output_collect <= '0';

        -- Test 5: Timeout in Started state.
        wait on started, connecting, running, errany for 9.5 us - (15.0 * outbit_period);
        assert (started = '1') and (running = '0') and (errany = '0')
            report " 5. started_timeout (wait)";
        wait on started, connecting, running, errany for 4 us;
        assert (started = '0') and (connecting = '0') and (running = '0') and (errany = '0')
            report " 5. started_timeout (trigger)";
        wait for (3.1 * outbit_period + 20 * txclk_period);
        assert (spw_do = '0') and (spw_so = '0')
            report " 5. started_timeout (SPW to zero)";

        -- Test 6: Start link; simulate NULL pattern; wait for FCT pattern.
        wait on started, connecting, running, spw_so for 18 us - (3.1 * outbit_period + 20 * txclk_period);
        assert (started = '0') and (connecting = '0') and (running = '0') and (spw_so = '0')
            report " 6. fctgen (SPW idle)";
        wait on started, connecting, running, spw_so for 2 us;
        assert (started = '1') and (connecting = '0') and (running = '0')
            report " 6. fctgen (started)";
        if spw_so = '0' then
            wait on started, connecting, running, spw_do, spw_so for 1.2 us;
        end if;
        assert (spw_do = '0') and (spw_so = '1')
            report " 6. fctgen (SPW strobe)";
        output_collect <= '1';
        input_pattern <= 1;
        wait on started, connecting, running for 8 us;
        assert (started = '0') and (connecting = '1') and (running = '0')
            report " 6. fctgen (detect NULL)";
        wait for (1.1 sec) / sys_clock_freq;
        wait on started, connecting, running, errany for 12 us;
        assert (started = '0') and (connecting = '1') and (running = '0') and (errany = '0')
            report " 6. fctgen (connecting failed early)";
        assert (output_ptr > 7) and (output_bits(0 to 7) = "01110100")
            report " 6. fctgen (gen NULL)";
        i := skip_null(output_bits, 0, output_ptr);
        assert (i > 0) and (i + 11 < output_ptr) and (output_bits(i to (i+11)) = "010001110100")
            report " 6. fctgen (gen FCT NULL)";
        output_collect <= '0';

        -- Test 7: Timeout in Connecting state.
        wait on started, connecting, running, errany for 4 us;
        assert (started = '0') and (connecting = '0') and (running = '0') and (errany = '0')
            report " 7. connecting_timeout";
        input_pattern <= 0;
        wait until rising_edge(sysclk);

        -- Test 8: Autostart link; simulate NULL and FCT; move to Run state; disconnect.
        linkstart <= '0';
        autostart <= '1';
        rxroom <= "010000";
        wait on started, connecting, running, errany for 50 us;
        assert (started = '0') and (connecting = '0') and (running = '0') and (errany = '0')
            report " 8. autostart (wait)";
        output_collect <= '1';
        input_pattern <= 1;
        wait on started, connecting, running for 200 ns + 24 * inbit_period;
        assert (started = '1') and (connecting = '0') and (running = '0')
            report " 8. autostart (Started)";
        input_pattern <= 9;
        wait on started, connecting, running for 1 us;
        assert (started = '0') and (connecting = '1') and (running = '0')
            report " 8. autostart (Connecting)";
        wait on started, connecting, running, errany for 200 ns + 24 * inbit_period;
        assert (started = '0') and (connecting = '0') and (running = '1') and (errany = '0')
            report " 8. autostart (Run)";
        input_pattern <= 1;
        txwrite <= '1';
        if txrdy = '0' then
            wait on running, errany, txrdy for (20 * outbit_period);
        end if;
        assert (running = '1') and (errany = '0') and (txrdy = '1')
            report " 8. running (txrdy = 1)";
        txwrite <= '0';
        wait on running, errany for 50 us;
        assert (running = '1') and (errany = '0')
            report " 8. running stable";
        assert output_bits(1 to 24) = "011101000100010001110100"
            report " 8. NULL FCT FCT NULL";
        output_collect <= '0';
        linkdis <= '1';
        wait on started, running, errany for (2.1 sec) / sys_clock_freq;
        assert (started = '0') and (running = '0') and (errany = '0')
            report " 8. link disable";
        autostart <= '0';
        linkdis <= '0';
        input_pattern <= 0;
        wait until rising_edge(sysclk);

        -- Test 9: Start link until Run state; disconnect.
        linkstart <= '1';
        rxroom <= "001000";
        input_pattern <= 1;
        wait on started, connecting, running for 20 us;
        assert (started = '1') and (connecting = '0') and (running = '0')
            report " 9. running_disconnect (Started)";
        linkstart <= '0';
        wait until rising_edge(sysclk);
        input_pattern <= 9;
        wait on started, connecting, running, errany for 20 * inbit_period;
        assert (started = '0') and (connecting = '1') and (running = '0') and (errany = '0')
            report " 9. running_disconnect (Connecting)";
        wait on started, connecting, running, errany for 200 ns + 24 * inbit_period;
        assert (started = '0') and (connecting = '0') and (running = '1') and (errany = '0')
            report " 9. running_disconnect (Run)";
        input_pattern <= 0;
        wait until input_idle = '1';
        wait on started, connecting, running, errany for 1500 ns;
        assert errdisc = '1'
            report " 9. running_disconnect (errdisc = 1)";
        if running = '1' then
            wait on started, connecting, running for (1.1 sec) / sys_clock_freq;
        end if;
        assert (started = '0') and (connecting = '0') and (running = '0')
            report " 9. running_disconnect (running = 0)";
        wait until rising_edge(sysclk);
        assert (started = '0') and (connecting = '0') and (running = '0') and (errany = '0')
            report " 9. running_disconnect (reset)";
        wait until rising_edge(sysclk);

        -- Test 10: Junk signal before starting link.
        autostart <= '1';
        input_pattern <= 3;
        wait on started, errany for 6 us;
        assert (started = '0') and (errany = '0')
            report "10. junk signal (ignore noise)";
        input_pattern <= 2;
        wait on started, errany for 4 us;
        assert (started = '0') and (errany = '0')
            report "10. junk signal (ignore FCT)";
        input_pattern <= 0;
        wait until input_idle = '1';
        input_pattern <= 1; -- send NULL
        wait until input_idle = '0';
        input_pattern <= 3; -- send invalid pattern; spw should now reset
        wait on started, errany for 8 us;
        assert (started = '0') and (errany = '0')
            report "10. junk signal (hidden reset)";
        input_pattern <= 1; -- send NULL
        wait on started, errany for 10 us;
        assert (started = '0') and (errany = '0')
            report "10. junk signal (waiting)";
        wait on started, errany for 10 us;
        assert (started = '1') and (errany = '0')
            report "10. junk signal (Started)";
        autostart <= '0';
        rst <= '1';
        wait until rising_edge(sysclk);
        rst <= '0';
        wait until rising_edge(sysclk);
        assert (started = '0') and (errany = '0')
            report "10. junk signal (rst)";
        wait until rising_edge(sysclk);

        -- Test 11: Incoming EOP before first FCT.
        linkstart <= '1';
        rxroom <= "001000";
        input_pattern <= 1;
        wait on connecting, running, errany for 21 us;
        assert (connecting = '1') and (errany = '0')
            report "11. unexpected EOP (Connecting)";
        input_pattern <= 4;
        linkstart <= '0';
        wait on connecting, running, errany for 200 ns + 24 * inbit_period;
        assert (connecting = '0') and (running = '0') and (errany = '0')
            report "11. unexpected EOP (reset on EOP)";
        input_pattern <= 0;
        wait for (10 * outbit_period);

        -- Test 12: Send and receive characters, time codes, abort on double ESC.
        wait until falling_edge(sysclk);
        linkstart <= '1';
        wait on started, errany for 21 us;
        assert (started = '1') and (errany = '0')
            report "12. characters (Started)";
        rxroom <= "001000";
        input_pattern <= 1;
        output_collect <= '1';
        tick_in <= '1';
        wait on connecting, running, errany for 21 us;
        assert (connecting = '1') and (errany = '0')
            report "12. characters (Connecting)";
        wait until output_ptr > 9 for 2 us;
        input_pattern <= 5; -- FCT, TIME, 8 chars, NULLs
        time_in <= "000111";
        txwrite <= '1';
        txflag <= '0';
        txdata <= "01101100";
        wait on connecting, running, errany for 200 ns + (24 * inbit_period);
        assert (running = '1') and (errany = '0')
            report "12. characters (Run)";
        wait until rising_edge(sysclk);
        assert (running = '1') and (errany = '0')
            report "12. characters (running = 1)";
        tick_in <= '0';
        wait for 4 * outbit_period;   -- wait until first FCT sent
        rxroom <= "000111";
        wait until txrdy = '1' for 200 ns + (20 * outbit_period);
        assert (running = '1') and (txrdy = '1')
            report "12. characters (txrdy = 1)";
        wait on running, errany for 50 us + (80 * outbit_period);
        assert (running = '1') and (errany = '0')
            report "12. characters (stable)";
        input_pattern <= 6; -- just ESC tokens
        wait on running, errany for 200 ns + (32 * inbit_period);
        assert erresc = '1'
            report "12. characters (erresc = 1)";
        wait until rising_edge(sysclk);
        wait for 1 ns;
        assert (started = '0') and (connecting = '0') and (running = '0')
            report "12. characters (reset)";
        assert (output_ptr > 8) and (output_bits(1 to 8) = "01110100")
            report "12. characters (gen NULL 1)";
        i := skip_null(output_bits, 1, output_ptr);
        assert (i > 0) and (output_bits(i to (i+3)) = "0100")
            report "12. characters (gen FCT)";
        i := skip_null(output_bits, i + 4, output_ptr);
        assert (i + 13 < output_ptr) and (output_bits(i to (i+13)) = "01111011100000")
            report "12. characters (gen TimeCode)";
        i := i + 14;
        assert (i + 79 < output_ptr) and (output_bits(i to (i+79)) = "00001101101000110110100011011010001101101000110110100011011010001101101000110110")
            report "12. characters (gen Data)";
        i := i + 80;
        assert (i + 7 < output_ptr) and (output_bits(i to (i+7)) = "01110100")
            report "12. characters (gen NULL 2)";
        assert (output_nchars > 0) and (output_chars(0) = "1000111000")
            report "12. characters (got TimeCode)";
        assert (output_nchars > 1) and (output_chars(1) = "0001010101")
            report "12. characters (got byte 1)";
        assert (output_nchars > 2) and (output_chars(2) = "0010101010")
            report "12. characters (got byte 2)";
        assert (output_nchars > 3) and (output_chars(3) = "0001010101")
            report "12. characters (got byte 3)";
        assert (output_nchars > 4) and (output_chars(4) = "0010101010")
            report "12. characters (got byte 4)";
        assert check_parity(output_bits, 1, output_ptr)
            report "12. parity of output bits";
        output_collect <= '0';
        input_pattern <= 0;
        txwrite <= '0';
        linkstart <= '0';
        wait for (20 * outbit_period);

        -- Test 13: Send and receive EOP, EEP, abort on credit error.
        linkstart <= '1';
        rxroom <= "001000";
        input_pattern <= 1;
        output_collect <= '1';
        wait on connecting, running, errany for 21 us;
        assert (connecting = '1') and (errany = '0')
            report "13. eop, eep (Connecting)";
        wait until output_ptr > 9 for 2 us;
        input_pattern <= 7; -- FCT, NULL, NULL, EOP, EEP, NULLs
        wait for (1.1 sec) / sys_clock_freq;
        wait on connecting, running, errany for 12 us;
        assert (running = '1') and (errany = '0')
            report "13. eop, eep (Run)";
        wait for 1 ns;
        txwrite <= '1';
        txflag <= '1';
        txdata <= "01101100";
        wait until rising_edge(sysclk) and txrdy = '1' for 1 us + (14 * outbit_period);
        assert (txrdy = '1') and (running = '1') and (errany = '0')
            report "13. eop, eep (txrdy 1)";
        rxroom <= "000111" after 1 ns;
        txdata <= "00000001" after 1 ns;
        wait until rising_edge(sysclk) and txrdy = '1' for 1 us + (14 * outbit_period);
        assert (txrdy = '1') and (running = '1') and (errany = '0')
            report "13. eop, eep (txrdy 2)";
        txdata <= "00000000" after 1 ns;
        wait until rising_edge(sysclk) and txrdy = '1' for (14 * outbit_period);
        assert (txrdy = '1') and (running = '1') and (errany = '0')
            report "13. eop, eep (txrdy 3)";
        txdata <= "11111111" after 1 ns;
        wait until rising_edge(sysclk) and txrdy = '1' for (14 * outbit_period);
        assert (txrdy = '1') and (running = '1') and (errany = '0')
            report "13. eop, eep (txrdy 4)";
        txdata <= "11111110" after 1 ns;
        wait until rising_edge(sysclk) and txrdy = '1' for (14 * outbit_period);
        assert (txrdy = '1') and (running = '1') and (errany = '0')
            report "13. eop, eep (txrdy 5)";
        txdata <= "01010101" after 1 ns;
        wait until rising_edge(sysclk) and txrdy = '1' for (14 * outbit_period);
        assert (txrdy = '1') and (running = '1') and (errany = '0')
            report "13. eop, eep (txrdy 6)";
        txdata <= "10101010" after 1 ns;
        wait until rising_edge(sysclk) and txrdy = '1' for (14 * outbit_period);
        assert (txrdy = '1') and (running = '1') and (errany = '0')
            report "13. eop, eep (txrdy 7)";
        txdata <= "01010101" after 1 ns;
        wait until rising_edge(sysclk) and txrdy = '1' for (14 * outbit_period);
        assert (txrdy = '1') and (running = '1') and (errany = '0')
            report "13. eop, eep (txrdy 8)";
        txdata <= "10101010" after 1 ns;
        wait until rising_edge(sysclk) and (txrdy = '1') for (14 * outbit_period);
        assert (txrdy = '0') and (running = '1') and (errany = '0')
            report "13. eop, eep (txrdy 9)";
        txwrite <= '0';
        txflag <= '0';
        wait on running, errany for (10 * outbit_period);
        assert (running = '1') and (errany = '0')
            report "13. eop, eep (flush out)";
        input_pattern <= 2; -- FCT tokens
        wait on running, errany for (80 * inbit_period);
        assert errcred = '1'
            report "13. eop, eep (errcred = 1)";
        wait until running = '0';
        assert (output_ptr > 8) and (output_bits(1 to 8) = "01110100")
            report "13. eop, eep (gen NULL 1)";
        i := skip_null(output_bits, 1, output_ptr);
        assert (i > 0) and (output_bits(i to (i+3)) = "0100")
            report "13. eop, eep (gen FCT)";
        i := i + 4;
        for j in 0 to 3 loop
            i := skip_null(output_bits, i, output_ptr);
            assert (i + 3 < output_ptr) and (output_bits(i+1 to (i+3)) = "101")
                report "13. eop, eep (eop)";
            i := skip_null(output_bits, i + 4, output_ptr);
            assert (i + 3 < output_ptr) and (output_bits(i+1 to (i+3)) = "110")
                report "13. eop, eep (eep)";
            i := i + 4;
        end loop;
        assert (i + 8 < output_ptr) and (output_bits(i to (i+8)) = "111101000")
            report "13. eop, eep (gen NULL 2)";
        assert check_parity(output_bits, 1, output_ptr)
            report "12. parity of output bits";
        assert (output_nchars > 0) and (output_chars(0) = "0100000000")
            report "13. eop, eep (got EOP)";
        assert (output_nchars = 2) and (output_chars(1) = "0100000001")
            report "13. eop, eep (got EEP)";
        output_collect <= '0';
        input_pattern <= 0;
        linkstart <= '0';
        wait until rising_edge(sysclk);

        -- Test 14: Abort on parity error.
        wait for 10 us;
        assert spw_do = '0' and spw_so = '0'
            report "14. output still babbling";
        linkstart <= '1';
        rxroom <= "001000";
        input_pattern <= 1;
        output_collect <= '1';
        wait for 1 ns; -- ghdl is totally fucked up
        wait on connecting, running, errany for 21 us;
        assert (connecting = '1') and (errany = '0')
            report "14. partity (Connecting)";
        input_pattern <= 8; -- FCT, NULL, NULL, NULL, NULL, NULL, char, error
        wait for (1.1 sec) / sys_clock_freq;
        wait on running, errany for 12 us;
        assert (running = '1') and (errany = '0')
            report "14. parity (Run)";
        wait on running, errany for 150 ns + (84 * inbit_period);
        assert errpar = '1'
            report "14. parity (errpar = 1)";
        wait until running = '0';
        assert (output_nchars = 1) and (output_chars(0) = "0001010101")
            report "14. parity (received char)";
        output_collect <= '0';
        input_pattern <= 0;
        linkstart <= '0';
        wait until rising_edge(sysclk);

        -- Test 15: start with wrong strobe polarity.
        input_strobeflip <= '1';
        linkstart <= '1';
        rxroom <= "001000";
        input_pattern <= 1;
        wait on started, connecting, running for 20 us;
        assert (started = '1') and (connecting = '0') and (running = '0')
            report " 15. weird_strobe (Started)";
        linkstart <= '0';
        wait until rising_edge(sysclk);
        input_pattern <= 9;
        wait on started, connecting, running, errany for 20 * inbit_period;
        assert (started = '0') and (connecting = '1') and (running = '0') and (errany = '0')
            report " 15. weird_strobe (Connecting)";
        wait on started, connecting, running, errany for 200 ns + 24 * inbit_period;
        assert (started = '0') and (connecting = '0') and (running = '1') and (errany = '0')
            report " 15. weird_strobe (Run)";
        linkdis <= '1';
        wait until rising_edge(sysclk);
        input_pattern <= 0;
        input_strobeflip <= '0';
        wait until input_idle = '1';
        linkdis <= '0';
        wait until rising_edge(sysclk);

        -- Test 16: start with wrong data polarity.
        input_pattern <= 10;
        linkstart <= '1';
        rxroom <= "001111";
        wait on started, connecting, running for 25 us;
        assert (started = '1') and (running = '0')
            report " 16. weird_data (started)";
        if spw_so = '0' then
            wait on started, connecting, running, spw_do, spw_so for 1.2 us;
        end if;
        assert (started = '1') and (connecting = '0') and (running = '0') and
               (spw_do = '0') and (spw_so = '1')
            report " 16. weird_data (SPW strobe)";
        output_collect <= '1';
        wait on started, connecting, running for (7.1 * outbit_period);
        assert (started = '1') and (running = '0')
            report " 16. weird_data (state 2)";
        assert (output_ptr = 8) and (output_bits(0 to 7) = "01110100")
            report " 16. weird_data (NULL 1)";
        -- got the first NULL, wait for the second one ...
        wait on started, connecting, running for (8.0 * outbit_period);
        assert (started = '1') and (running = '0')
            report " 16. weird_data (state 3)";
        assert (output_ptr = 16) and (output_bits(8 to 15) = "01110100")
            report " 16. weird_data (NULL 2)";
        output_collect <= '0';
        linkstart <= '0';
        linkdis <= '1';
        input_pattern <= 0;
        wait until rising_edge(sysclk);
        linkdis <= '0';
        wait until rising_edge(sysclk);

        -- Stop simulation
        input_pattern <= 0;
        wait for 100 us;
        sys_clock_enable <= '0';
        report "Done.";
        wait;

    end process;

end tb_arch;
