--
-- Test Bench for SpaceWire AMBA interface.
--
-- Instantiate a minimal LEON3 system with SPWAMBA core.
-- At the start of the simulation, a software image is loaded into memory
-- from an external file spwamba_test.srec.
--

library ieee;
use ieee.std_logic_1164.all, ieee.numeric_std.all;
use std.textio.all;
library techmap;
use techmap.gencomp.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
library gaisler;
use gaisler.leon3.all;
use gaisler.uart.all;
use gaisler.misc.all;
use work.spwpkg.all;
use work.spwambapkg.all;

entity spwamba_tb is

end spwamba_tb;

architecture tb_arch of spwamba_tb is

    -- 40 MHz system clock
    constant sys_clock_freq: real := 40.0e6;

    signal clkm:    std_ulogic := '0';
    signal rstn:    std_ulogic := '0';

    signal apbi:    apb_slv_in_type;
    signal apbo:    apb_slv_out_vector := (others => apb_none);
    signal ahbsi:   ahb_slv_in_type;
    signal ahbso:   ahb_slv_out_vector := (others => ahbs_none);
    signal ahbmi:   ahb_mst_in_type;
    signal ahbmo:   ahb_mst_out_vector := (others => ahbm_none);

    signal irqi:    irq_in_vector(0 to 0);
    signal irqo:    irq_out_vector(0 to 0);
    signal dbgi:    l3_debug_in_type;
    signal dbgo:    l3_debug_out_type;

    signal uarti:   uart_in_type;
    signal uarto:   uart_out_type;
    signal gpti:    gptimer_in_type;
    signal gpto:    gptimer_out_type;

    signal spw_tick_in: std_logic;
    signal spw_di:      std_logic;
    signal spw_si:      std_logic;
    signal spw_do:      std_logic;
    signal spw_so:      std_logic;

    component ahbram_loadfile is
        generic (
            hindex: integer;
            haddr:  integer;
            hmask:  integer := 16#fff#;
            abits:  integer range 10 to 24;
            fname:  string );
        port (
            rstn:   in  std_logic;
            clk:    in  std_logic;
            ahbi:   in  ahb_slv_in_type;
            ahbo:   out ahb_slv_out_type );
    end component;

begin

    --
    -- Reset and clock generation.
    --
    process is
    begin
        -- Reset (APBUART needs 2 reset cycles)
        rstn    <= '0';
        for i in 0 to 1 loop
            wait for (0.5 sec) / sys_clock_freq;
            clkm    <= '1';
            wait for (0.5 sec) / sys_clock_freq;
            clkm    <= '0';
        end loop;
        rstn    <= '1';
        report "Start simulation";
        -- Main loop
        loop
            wait for (0.5 sec) / sys_clock_freq;
            clkm    <= '1';
            wait for (0.5 sec) / sys_clock_freq;
            clkm    <= '0';
            -- Check LEON3 error signal.
            assert dbgo.error = '1' report "LEON3 in error mode";
            exit when dbgo.error = '0';
            -- End simulation when LEON3 is in power down mode.
            exit when dbgo.pwd = '1';
        end loop;
        -- End simulation.
        report "End of simulation";
        wait;
    end process;

    --
    -- AHB controller.
    --
    ahb0: ahbctrl
        generic map (defmast => 0, split => 0, rrobin => 1,
                     ioaddr => 16#fff#, ioen => 0, nahbm => 2, nahbs => 4)
        port map (rstn, clkm, ahbmi, ahbmo, ahbsi, ahbso);

    --
    -- LEON3 processor.
    --
    cpu: leon3s
        generic map (hindex => 0, fabtech => inferred, memtech => inferred,
                     nwindows => 8, dsu => 0, fpu => 0, v8 => 0, cp => 0, mac => 0,
                     pclow => 2, notag => 0, nwp => 4,
                     icen => 1, irepl => 0, isets => 1, ilinesize => 8, isetsize => 4, isetlock => 0,
                     dcen => 0, drepl => 0, dsets => 1, dlinesize => 4, dsetsize => 4, dsetlock => 0, dsnoop => 1,
                     ilram => 0, ilramsize => 1, ilramstart => 16#8E#,
                     dlram => 0, dlramsize => 1, dlramstart => 16#8F#,
                     mmuen => 0, itlbnum => 8, dtlbnum => 8, tlb_type => 2, tlb_rep => 0,
                     lddel => 1, disas => 0, tbuf => 2, pwd => 2, svt => 1,
                     rstaddr => 16#40000#, smp => 0, cached => 0, scantest => 0, mmupgsz => 4, bp => 1)
        port map (clkm, rstn, ahbmi, ahbmo(0), ahbsi, ahbso, irqi(0), irqo(0), dbgi, dbgo);
    dbgi <= (dsuen => '0', denable => '0', dbreak => '0', step => '0', halt => '0', reset => '0', dwrite => '0', daddr => (others => '0'), ddata => (others => '0'), btrapa => '0', btrape => '0', berror => '0',bwatch => '0', bsoft => '0', tenable => '0', timer => (others => '0')); 

    --
    -- APB bridge.
    --
    apb0: apbctrl
        generic map (hindex => 1, haddr => 16#800#, nslaves => 8)
        port map (rstn, clkm, ahbsi, ahbso(1), apbi, apbo);

    --
    -- Console UART.
    --
    uart1: apbuart
        generic map (pindex => 1, paddr => 1, pirq => 2, console => 1, fifosize => 1)
        port map (rstn, clkm, apbi, apbo(1), uarti, uarto);
    uarti.rxd       <= '0';
    uarti.ctsn      <= '0';
    uarti.extclk    <= '0';

    --
    -- Interrupt controller.
    --
    irqctrl0 : irqmp
        generic map (pindex => 2, paddr => 2, ncpu => 1)
        port map (rstn, clkm, apbi, apbo(2), irqo, irqi);

    --
    -- Timer.
    --
    timer0: gptimer
        generic map (pindex => 3, paddr => 3, pirq => 8, sepirq => 0,
                     sbits => 8, ntimers => 2, nbits => 32, wdog => 0)
        port map (rstn, clkm, apbi, apbo(3), gpti, gpto);
    gpti.dhalt  <= '0';
    gpti.extclk <= '0';

    --
    -- AHB RAM (128 kByte)
    --
    ahbram0: ahbram_loadfile
        generic map (hindex => 3, haddr => 16#400#, abits => 17, fname => "spwamba_test.srec")
        port map (rstn, clkm, ahbsi, ahbso(3));

    --
    -- SpaceWire Light
    --
    spw0: spwamba
        generic map (
            tech        => inferred,
            hindex      => 1,
            pindex      => 4,
            paddr       => 4,
            pirq        => 4,
            sysfreq     => sys_clock_freq,
            txclkfreq   => sys_clock_freq,
            rximpl      => impl_generic,
            rxchunk     => 1,
            tximpl      => impl_generic,
            timecodegen => true,
            rxfifosize  => 7,
            txfifosize  => 6,
            desctablesize => 5,
            maxburst    => 3 )
        port map (
            clk     => clkm,
            rxclk   => clkm,
            txclk   => clkm,
            rstn    => rstn,
            apbi    => apbi,
            apbo    => apbo(4),
            ahbi    => ahbmi,
            ahbo    => ahbmo(1),
            tick_in => spw_tick_in,
            tick_out => open,
            spw_di  => spw_di,
            spw_si  => spw_si,
            spw_do  => spw_do,
            spw_so  => spw_so );

    -- Loopback SpaceWire signals.
    -- Loopback can be controlled from software through the RXEN bit of
    -- the APBUART control register.
    spw_di  <= spw_do when (uarto.rxen = '1') else '0';
    spw_si  <= spw_so when (uarto.rxen = '1') else '0';

    -- Take external timecode tick from second GPTIMER.
    spw_tick_in <= gpto.tick(2);

end tb_arch;
