--
-- Run the spwlink test bench in a several configurations.
--

use work.spwpkg.all;

entity spwlink_tb_all is
end entity;

architecture tb_arch of spwlink_tb_all is

    component spwlink_tb is
        generic (
            sys_clock_freq: real        := 20.0e6 ;
            rx_clock_freq:  real        := 20.0e6 ;
            tx_clock_freq:  real        := 20.0e6 ;
            input_rate:     real        := 10.0e6 ;
            tx_clock_div:   integer     := 1 ;
            rximpl: spw_implementation_type := impl_generic ;
            rxchunk:        integer     := 1 ;
            tximpl: spw_implementation_type := impl_generic ;
            startwait:      time        := 0 sec );
    end component;

begin

    -- Test 1: default configuration
    test1: spwlink_tb
        generic map (
            sys_clock_freq  => 20.0e6,
            rx_clock_freq   => 20.0e6,
            tx_clock_freq   => 20.0e6,
            input_rate      => 10.0e6,
            tx_clock_div    => 1,
            rximpl          => impl_generic,
            rxchunk         => 1,
            tximpl          => impl_generic,
            startwait       => 0 ms );

    -- Test 2: 18 Mbit input
    test2: spwlink_tb
        generic map (
            sys_clock_freq  => 20.0e6,
            rx_clock_freq   => 20.0e6,
            tx_clock_freq   => 20.0e6,
            input_rate      => 18.0e6,
            tx_clock_div    => 1,
            rximpl          => impl_generic,
            rxchunk         => 1,
            tximpl          => impl_generic,
            startwait       => 1 ms );

    -- Test 3: 2 Mbit input
    test3: spwlink_tb
        generic map (
            sys_clock_freq  => 20.0e6,
            rx_clock_freq   => 20.0e6,
            tx_clock_freq   => 20.0e6,
            input_rate      => 2.0e6,
            tx_clock_div    => 1,
            rximpl          => impl_generic,
            rxchunk         => 1,
            tximpl          => impl_generic,
            startwait       => 2 ms );

    -- Test 4: 20 Mbit output
    test4: spwlink_tb
        generic map (
            sys_clock_freq  => 20.0e6,
            rx_clock_freq   => 20.0e6,
            tx_clock_freq   => 20.0e6,
            input_rate      => 10.0e6,
            tx_clock_div    => 0,
            rximpl          => impl_generic,
            rxchunk         => 1,
            tximpl          => impl_generic,
            startwait       => 3 ms );

    -- Test 5: fast receiver, 10 Mbit in
    test5: spwlink_tb
        generic map (
            sys_clock_freq  => 20.0e6,
            rx_clock_freq   => 20.0e6,
            tx_clock_freq   => 20.0e6,
            input_rate      => 10.0e6,
            tx_clock_div    => 1,
            rximpl          => impl_fast,
            rxchunk         => 1,
            tximpl          => impl_generic,
            startwait       => 4 ms );

    -- Test 6: fast receiver, 18 Mbit in
    test6: spwlink_tb
        generic map (
            sys_clock_freq  => 20.0e6,
            rx_clock_freq   => 20.0e6,
            tx_clock_freq   => 20.0e6,
            input_rate      => 18.0e6,
            tx_clock_div    => 1,
            rximpl          => impl_fast,
            rxchunk         => 1,
            tximpl          => impl_generic,
            startwait       => 5 ms );

    -- Test 7: fast receiver, 35 Mbit in
    test7: spwlink_tb
        generic map (
            sys_clock_freq  => 20.0e6,
            rx_clock_freq   => 20.0e6,
            tx_clock_freq   => 20.0e6,
            input_rate      => 35.0e6,
            tx_clock_div    => 1,
            rximpl          => impl_fast,
            rxchunk         => 2,
            tximpl          => impl_generic,
            startwait       => 6 ms );

    -- Test 8: fast receiver, 55 Mbit in
    test8: spwlink_tb
        generic map (
            sys_clock_freq  => 20.0e6,
            rx_clock_freq   => 30.0e6,
            tx_clock_freq   => 20.0e6,
            input_rate      => 55.0e6,
            tx_clock_div    => 1,
            rximpl          => impl_fast,
            rxchunk         => 3,
            tximpl          => impl_generic,
            startwait       => 7 ms );

    -- Test 9: fast receiver, 75 Mbit in
    test9: spwlink_tb
        generic map (
            sys_clock_freq  => 20.0e6,
            rx_clock_freq   => 40.0e6,
            tx_clock_freq   => 20.0e6,
            input_rate      => 75.0e6,
            tx_clock_div    => 1,
            rximpl          => impl_fast,
            rxchunk         => 4,
            tximpl          => impl_generic,
            startwait       => 8 ms );

    -- Test 10: fast receiver, 75 Mbit in, 100 MHz sample clock
    test10: spwlink_tb
        generic map (
            sys_clock_freq  => 20.0e6,
            rx_clock_freq   => 100.0e6,
            tx_clock_freq   => 20.0e6,
            input_rate      => 75.0e6,
            tx_clock_div    => 1,
            rximpl          => impl_fast,
            rxchunk         => 4,
            tximpl          => impl_generic,
            startwait       => 9 ms );

    -- Test 11: fast receiver, 2 Mbit in, 100 MHz sample clock
    test11: spwlink_tb
        generic map (
            sys_clock_freq  => 20.0e6,
            rx_clock_freq   => 100.0e6,
            tx_clock_freq   => 20.0e6,
            input_rate      => 2.0e6,
            tx_clock_div    => 1,
            rximpl          => impl_fast,
            rxchunk         => 4,
            tximpl          => impl_generic,
            startwait       => 10 ms );

    -- Test 12: fast receiver, 67.13 Mbit in, 43 MHz sample clock
    test12: spwlink_tb
    generic map (
            sys_clock_freq  => 20.0e6,
            rx_clock_freq   => 43.0e6,
            tx_clock_freq   => 20.0e6,
            input_rate      => 67.13e6,
            tx_clock_div    => 1,
            rximpl          => impl_fast,
            rxchunk         => 4,
            tximpl          => impl_generic,
            startwait       => 11 ms );

    -- Test 13: fast transmitter, 39/2 Mbit out
    test13: spwlink_tb
        generic map (
            sys_clock_freq  => 20.0e6,
            rx_clock_freq   => 20.0e6,
            tx_clock_freq   => 39.0e6,
            input_rate      => 10.0e6,
            tx_clock_div    => 1,
            rximpl          => impl_generic,
            rxchunk         => 1,
            tximpl          => impl_fast,
            startwait       => 12 ms );

    -- Test 14: fast transmitter, 39 Mbit out
    test14: spwlink_tb
        generic map (
            sys_clock_freq  => 20.0e6,
            rx_clock_freq   => 20.0e6,
            tx_clock_freq   => 39.0e6,
            input_rate      => 10.0e6,
            tx_clock_div    => 0,
            rximpl          => impl_generic,
            rxchunk         => 1,
            tximpl          => impl_fast,
            startwait       => 13 ms );

    -- Test 15: fast transmitter, 80 Mbit out
    test15: spwlink_tb
        generic map (
            sys_clock_freq  => 20.0e6,
            rx_clock_freq   => 20.0e6,
            tx_clock_freq   => 80.0e6,
            input_rate      => 10.0e6,
            tx_clock_div    => 0,
            rximpl          => impl_generic,
            rxchunk         => 1,
            tximpl          => impl_fast,
            startwait       => 14 ms );

    -- Test 16: fast transmitter, 20/3 Mbit out
    test16: spwlink_tb
        generic map (
            sys_clock_freq  => 20.0e6,
            rx_clock_freq   => 20.0e6,
            tx_clock_freq   => 20.0e6,
            input_rate      => 10.0e6,
            tx_clock_div    => 2,
            rximpl          => impl_generic,
            rxchunk         => 1,
            tximpl          => impl_fast,
            startwait       => 15 ms );

    -- Test 17: fast transmitter, 80/4 Mbit out
    test17: spwlink_tb
        generic map (
            sys_clock_freq  => 20.0e6,
            rx_clock_freq   => 20.0e6,
            tx_clock_freq   => 80.0e6,
            input_rate      => 10.0e6,
            tx_clock_div    => 3,
            rximpl          => impl_generic,
            rxchunk         => 1,
            tximpl          => impl_fast,
            startwait       => 16 ms );

    -- Test 18: fast transmitter, 80/5 Mbit out
    test18: spwlink_tb
        generic map (
            sys_clock_freq  => 20.0e6,
            rx_clock_freq   => 20.0e6,
            tx_clock_freq   => 80.0e6,
            input_rate      => 10.0e6,
            tx_clock_div    => 4,
            rximpl          => impl_generic,
            rxchunk         => 1,
            tximpl          => impl_fast,
            startwait       => 17 ms );

    -- Test 19: fast transmitter, 80/40 Mbit out
    test19: spwlink_tb
        generic map (
            sys_clock_freq  => 20.0e6,
            rx_clock_freq   => 20.0e6,
            tx_clock_freq   => 80.0e6,
            input_rate      => 10.0e6,
            tx_clock_div    => 39,
            rximpl          => impl_generic,
            rxchunk         => 1,
            tximpl          => impl_fast,
            startwait       => 18 ms );

    -- Test 20: fast transmitter, 200/97 Mbit out
    test20: spwlink_tb
        generic map (
            sys_clock_freq  => 50.0e6,
            rx_clock_freq   => 50.0e6,
            tx_clock_freq   => 200.0e6,
            input_rate      => 10.0e6,
            tx_clock_div    => 96,
            rximpl          => impl_generic,
            rxchunk         => 1,
            tximpl          => impl_fast,
            startwait       => 19 ms );

    -- Test 21: fast transmitter, 78.5/2 Mbit out
    test21: spwlink_tb
        generic map (
            sys_clock_freq  => 20.0e6,
            rx_clock_freq   => 20.0e6,
            tx_clock_freq   => 78.5e6,
            input_rate      => 10.0e6,
            tx_clock_div    => 1,
            rximpl          => impl_generic,
            rxchunk         => 1,
            tximpl          => impl_fast,
            startwait       => 20 ms );

    -- Test 22: fast receiver and fast transmitter, 78.5 Mbit out
    test22: spwlink_tb
        generic map (
            sys_clock_freq  => 20.0e6,
            rx_clock_freq   => 43.0e6,
            tx_clock_freq   => 78.5e6,
            input_rate      => 67.13e6,
            tx_clock_div    => 0,
            rximpl          => impl_fast,
            rxchunk         => 4,
            tximpl          => impl_fast,
            startwait       => 21 ms );

    -- Test 23: fast receiver and fast transmitter, 77.5/2 Mbit out
    test23: spwlink_tb
        generic map (
            sys_clock_freq  => 20.0e6,
            rx_clock_freq   => 43.0e6,
            tx_clock_freq   => 77.5e6,
            input_rate      => 67.13e6,
            tx_clock_div    => 1,
            rximpl          => impl_fast,
            rxchunk         => 4,
            tximpl          => impl_fast,
            startwait       => 22 ms );

end tb_arch;
