--
-- Test bench for spwstream.
--
-- Tests:
--  * one spwstream instance with SpaceWire signals looped back to itself
--  * sending of bytes, packets and time codes through the SpaceWire link
--  * handling of link disabling and link disconnection
--
-- This test bench is intended to test the buffering logic in spwstream.
-- It does not thoroughly verify behaviour of the receiver, transmitter,
-- signal patterns etc. Please use spwlink_tb.vhd to test those aspects.
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.spwpkg.all;

entity streamtest_tb is
end entity;

architecture tb_arch of streamtest_tb is

    -- Parameters.
    constant sys_clock_freq: real   := 20.0e6;

    component streamtest is
        generic (
            sysfreq:    real;
            txclkfreq:  real;
            tickdiv:    integer range 12 to 24 := 20;
            rximpl:     spw_implementation_type := impl_generic;
            rxchunk:    integer range 1 to 4 := 1;
            tximpl:     spw_implementation_type := impl_generic;
            rxfifosize_bits: integer range 6 to 14 := 11;
            txfifosize_bits: integer range 2 to 14 := 11 );
        port (
            clk:        in  std_logic;
            rxclk:      in  std_logic;
            txclk:      in  std_logic;
            rst:        in  std_logic;
            linkstart:  in  std_logic;
            autostart:  in  std_logic;
            linkdisable: in std_logic;
            senddata:   in  std_logic;
            sendtick:   in  std_logic;
            txdivcnt:   in  std_logic_vector(7 downto 0);
            linkstarted: out std_logic;
            linkconnecting: out std_logic;
            linkrun:    out std_logic;
            linkerror:  out std_logic;
            gotdata:    out std_logic;
            dataerror:  out std_logic;
            tickerror:  out std_logic;
            spw_di:     in  std_logic;
            spw_si:     in  std_logic;
            spw_do:     out std_logic;
            spw_so:     out std_logic );
    end component;

    signal sys_clock_enable: std_logic := '0';
    signal sysclk:      std_logic := '0';
    signal s_loopback:  std_logic := '0';
    signal s_nreceived: integer := 0;

    signal s_rst:       std_logic := '1';
    signal s_linkstart: std_logic;
    signal s_autostart: std_logic;
    signal s_linkdisable: std_logic;
    signal s_divcnt:    std_logic_vector(7 downto 0);
    signal s_linkrun:   std_logic;
    signal s_linkerror: std_logic;
    signal s_gotdata:   std_logic;
    signal s_dataerror: std_logic;
    signal s_tickerror: std_logic;
    signal s_spwdi:     std_logic;
    signal s_spwsi:     std_logic;
    signal s_spwdo:     std_logic;
    signal s_spwso:     std_logic;

begin

    -- streamtest instance
    streamtest_inst: streamtest
        generic map (
            sysfreq     => sys_clock_freq,
            txclkfreq   => sys_clock_freq,
            tickdiv     => 16,
            rximpl      => impl_generic,
            rxchunk     => 1,
            tximpl      => impl_generic,
            rxfifosize_bits => 9,
            txfifosize_bits => 8 )
        port map (
            clk         => sysclk,
            rxclk       => sysclk,
            txclk       => sysclk,
            rst         => s_rst,
            linkstart   => s_linkstart,
            autostart   => s_autostart,
            linkdisable => s_linkdisable,
            senddata    => '1',
            sendtick    => '1',
            txdivcnt    => s_divcnt,
            linkstarted => open,
            linkconnecting => open,
            linkrun     => s_linkrun,
            linkerror   => s_linkerror,
            gotdata     => s_gotdata,
            dataerror   => s_dataerror,
            tickerror   => s_tickerror,
            spw_di      => s_spwdi,
            spw_si      => s_spwsi,
            spw_do      => s_spwdo,
            spw_so      => s_spwso );

    -- Conditional loopback of SpaceWire signals.
    s_spwdi <= s_spwdo when (s_loopback = '1') else '0';
    s_spwsi <= s_spwso when (s_loopback = '1') else '0';

    -- Generate system clock.
    process is
    begin
        if sys_clock_enable /= '1' then
            wait until sys_clock_enable = '1';
        end if;
        sysclk  <= '1';
        wait for (0.5 sec) / sys_clock_freq;
        sysclk  <= '0';
        wait for (0.5 sec) / sys_clock_freq;
    end process;

    -- Verify that error indications remain off.
    process is
    begin
        wait on s_linkerror, s_dataerror, s_tickerror;
        assert s_dataerror = '0' report "Detected data error";
        assert s_tickerror = '0' report "Detected time code error";
        if s_loopback = '1' then
            assert s_linkerror /= '1' report "Unexpected link error";
        end if;
    end process;

    -- Verify that data is received regularly when the link is up.
    process is
    begin
        if s_linkrun = '0' or s_gotdata = '1' then
            wait until s_linkrun = '1' and s_gotdata = '0';
        end if;
        wait until s_gotdata = '1' or s_linkrun = '0' for 3 ms;
        if s_linkrun = '1' then
            assert s_gotdata = '1' report "Link running but no data received";
        end if;
    end process;

    -- Count number of received characters.
    process is
    begin
        wait until rising_edge(sysclk);
        if s_gotdata = '1' then
            s_nreceived <= s_nreceived + 1;
        end if;
    end process;

    -- Main process.
    process is
        variable vline: LINE;
    begin
        report "Starting streamtest test bench";

        -- Initialize.
        s_loopback  <= '1';
        s_rst       <= '1';
        s_linkstart <= '0';
        s_autostart <= '0';
        s_linkdisable <= '0';
        s_divcnt    <= "00000001";
        sys_clock_enable <= '1';
        wait for 1 us;

        -- Test link and data transmission.
        report "Testing txdivcnt = 1";
        s_rst       <= '0';
        s_linkstart <= '1';
        wait for 100 us;
        assert s_linkrun = '1' report "Link failed to start";
        wait for 50 ms;

        -- Check number of received characters.
        write(vline, string'("Received "));
        write(vline, s_nreceived);
        write(vline, string'(" characters in 50 ms."));
        writeline(output, vline);
        assert s_nreceived > 24000 report "Too few characters received";

        -- Test switching to different transmission rate.
        report "Testing txdivcnt = 2";
        s_divcnt    <= "00000010";
        wait for 10 ms;
        report "Testing txdivcnt = 3";
        s_divcnt    <= "00000011";
        wait for 10 ms;

        -- Disable and re-enable link.
        report "Testing link disable/re-enable";
        s_linkdisable <= '1';
        s_divcnt    <= "00000001";
        wait for 2 ms;
        s_linkdisable <= '0';
        wait for 100 us;
        assert s_linkrun = '1' report "Link failed to start after re-enable";
        wait for 10 ms;

        -- Cut and reconnect loopback wiring.
        report "Testing physical disconnect/reconnect";
        s_loopback  <= '0';
        wait for 2 ms;
        s_loopback  <= '1';
        wait for 100 us;
        assert s_linkrun = '1' report "Link failed to start after reconnect";
        wait for 10 ms;
        s_loopback  <= '0';
        wait for 2 ms;
        s_loopback  <= '1';
        wait for 100 us;
        assert s_linkrun = '1' report "Link failed to start after reconnect (2)";
        wait for 10 ms;

        -- Shut down.
        s_rst   <= '1';
        wait for 1 us;
        sys_clock_enable <= '0';

        write(vline, string'("Received "));
        write(vline, s_nreceived);
        write(vline, string'(" characters."));
        writeline(output, vline);

        report "Done";
        wait;
    end process;

end architecture tb_arch;
