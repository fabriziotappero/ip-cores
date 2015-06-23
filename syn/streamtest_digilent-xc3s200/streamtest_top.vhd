--
--  Test of spwstream on Digilent XC3S200 board.
--  60 MHz system clock, 200 MHz receive clock and transmit clock.
--
--  LED 0 = link started
--  LED 1 = link connecting
--  LED 2 = link run
--  LED 3 = link error (sticky until clear button)
--  LED 4 = gotdata
--  LED 5 = off
--  LED 6 = data error (sticky until reset)
--  LED 7 = time code error (sticky until reset)
--
--  Button 0 = reset
--  Button 1 = clear LED 3
--
--  Switch 0 = link autostart
--  Switch 1 = link start
--  Switch 2 = link disable
--  Switch 3 = send data and time codes
--  Switch 4-7 = bits 0-3 of tx bit rate scale factor
--
--  SpaceWire signals on A2 expansion connector:
--    Data In    pos,neg  =  B5,C5  =  pin 19,6
--    Strobe In  pos,neg  =  D6,E6  =  pin 7,4
--    Data Out   pos,neg  =  B6,C6  =  pin 21,8
--    Strobe Out pos,neg  =  D7,E7  =  pin 11,9
--
--  Note: these are not true LVDS signals; they are configured as LVDS25
--  but powered from 3.3V instead of 2.5V, not differentially routed and
--  not properly terminated.
--
--  The SpaceWire port should be looped back to itself with wires from
--  outputs to corresponding inputs.
--

library ieee;
use ieee.std_logic_1164.all, ieee.numeric_std.all;
library unisim;
use unisim.vcomponents.all;
use work.spwpkg.all;

entity streamtest_top is

    port (
        clk50:      in  std_logic;
        button:     in  std_logic_vector(3 downto 0);
        switch:     in  std_logic_vector(7 downto 0);
        led:        out std_logic_vector(7 downto 0);
        spw_di_p:   in  std_logic;
        spw_di_n:   in  std_logic;
        spw_si_p:   in  std_logic;
        spw_si_n:   in  std_logic;
        spw_do_p:   out std_logic;
        spw_do_n:   out std_logic;
        spw_so_p:   out std_logic;
        spw_so_n:   out std_logic );

end entity streamtest_top;

architecture streamtest_top_arch of streamtest_top is

    -- Clock generation.
    signal boardclk:        std_logic;
    signal sysclk:          std_logic;
    signal fastclk:         std_logic;

    -- Synchronize buttons
    signal s_resetbtn:      std_logic := '0';
    signal s_clearbtn:      std_logic := '0';

    -- Sticky LED
    signal s_linkerrorled:  std_logic := '0';

    -- Interface signals.
    signal s_rst:           std_logic := '1';
    signal s_linkstart:     std_logic := '0';
    signal s_autostart:     std_logic := '0';
    signal s_linkdisable:   std_logic := '0';
    signal s_senddata:      std_logic := '0';
    signal s_txdivcnt:      std_logic_vector(7 downto 0) := "00000000";
    signal s_linkstarted:   std_logic;
    signal s_linkconnecting: std_logic;
    signal s_linkrun:       std_logic;
    signal s_linkerror:     std_logic;
    signal s_gotdata:       std_logic;
    signal s_dataerror:     std_logic;
    signal s_tickerror:     std_logic;
    signal s_spwdi:         std_logic;
    signal s_spwsi:         std_logic;
    signal s_spwdo:         std_logic;
    signal s_spwso:         std_logic;

    -- Make clock nets visible to UCF file.
    attribute KEEP: string;
    attribute KEEP of sysclk: signal is "SOFT";
    attribute KEEP of fastclk: signal is "SOFT";

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

begin

    -- Buffer incoming clock.
    bufg0: BUFG port map ( I => clk50, O => boardclk );

    -- Generate 60 MHz system clock.
    dcm0: DCM
        generic map (
            CLKFX_DIVIDE        => 5,
            CLKFX_MULTIPLY      => 6,
            CLK_FEEDBACK      => "NONE",
            CLKIN_DIVIDE_BY_2   => false,
            CLKIN_PERIOD        => 20.0,
            CLKOUT_PHASE_SHIFT  => "NONE",
            DESKEW_ADJUST       => "SYSTEM_SYNCHRONOUS",
            DFS_FREQUENCY_MODE  => "LOW",
            DUTY_CYCLE_CORRECTION => true,
            STARTUP_WAIT        => true )
        port map (
            CLKIN       => boardclk,
            RST         => '0',
            CLKFX       => sysclk );

    -- Generate 200 MHz fast clock.
    dcm1: DCM
        generic map (
            CLKFX_DIVIDE        => 1,
            CLKFX_MULTIPLY      => 4,
            CLK_FEEDBACK        => "NONE",
            CLKIN_DIVIDE_BY_2   => false,
            CLKIN_PERIOD        => 20.0,
            CLKOUT_PHASE_SHIFT  => "NONE",
            DESKEW_ADJUST       => "SYSTEM_SYNCHRONOUS",
            DFS_FREQUENCY_MODE  => "LOW",
            DUTY_CYCLE_CORRECTION => true,
            STARTUP_WAIT        => true )
        port map (
            CLKIN       => boardclk,
            RST         => '0',
            CLKFX       => fastclk );

    -- Streamtest instance
    streamtest_inst: streamtest
        generic map (
            sysfreq     => 60.0e6,
            txclkfreq   => 200.0e6,
            tickdiv     => 22,
            rximpl      => impl_fast,
            rxchunk     => 4,
            tximpl      => impl_fast,
            rxfifosize_bits => 11,
            txfifosize_bits => 10 )
        port map (
            clk         => sysclk,
            rxclk       => fastclk,
            txclk       => fastclk,
            rst         => s_rst,
            linkstart   => s_linkstart,
            autostart   => s_autostart,
            linkdisable => s_linkdisable,
            senddata    => s_senddata,
            sendtick    => s_senddata,
            txdivcnt    => s_txdivcnt,
            linkstarted => s_linkstarted,
            linkconnecting => s_linkconnecting,
            linkrun     => s_linkrun,
            linkerror   => s_linkerror,
            gotdata     => s_gotdata,
            dataerror   => s_dataerror,
            tickerror   => s_tickerror,
            spw_di      => s_spwdi,
            spw_si      => s_spwsi,
            spw_do      => s_spwdo,
            spw_so      => s_spwso );

    -- LVDS buffers
    spwdi_pad: IBUFDS
        generic map ( IOSTANDARD => "LVDS_25" )
        port map ( O => s_spwdi, I => spw_di_p, IB => spw_di_n );
    spwsi_pad: IBUFDS
        generic map ( IOSTANDARD => "LVDS_25" )
        port map ( O => s_spwsi, I => spw_si_p, IB => spw_si_n );
    spwdo_pad: OBUFDS
        generic map ( IOSTANDARD => "LVDS_25" )
        port map ( O => spw_do_p, OB => spw_do_n, I => s_spwdo );
    spwso_pad: OBUFDS
        generic map ( IOSTANDARD => "LVDS_25" )
        port map ( O => spw_so_p, OB => spw_so_n, I => s_spwso );

    process (sysclk) is
    begin
        if rising_edge(sysclk) then

            -- Synchronize buttons
            s_resetbtn  <= button(0);
            s_rst       <= s_resetbtn;
            s_clearbtn  <= button(1);

            -- Synchronize switch settings
            s_autostart <= switch(0);
            s_linkstart <= switch(1);
            s_linkdisable <= switch(2);
            s_senddata  <= switch(3);
            s_txdivcnt(7 downto 4) <= "0000";
            s_txdivcnt(3 downto 0) <= switch(7 downto 4);

            -- Sticky link error LED
            s_linkerrorled <= (s_linkerrorled or s_linkerror) and
                              (not s_clearbtn) and
                              (not s_resetbtn);

            -- Drive LEDs
            led(0)  <= s_linkstarted;
            led(1)  <= s_linkconnecting;
            led(2)  <= s_linkrun;
            led(3)  <= s_linkerrorled;
            led(4)  <= s_gotdata;
            led(5)  <= '0';
            led(6)  <= s_dataerror;
            led(7)  <= s_tickerror;

        end if;
    end process;

end architecture streamtest_top_arch;
