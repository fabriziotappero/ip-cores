--
--  Test of spwstream on Pender GR-XC3S-1500 board.
--  60 MHz system clock; 200 MHz receive clock and transmit clock.
--
--  LED 0 = link run
--  LED 1 = link error (sticky until clear button)
--  LED 2 = gotdata
--  LED 3 = data/timecode error (sticky until reset)
--
--  Button S2 = reset
--  Button S3 = clear LED 1
--
--  Switch 0 = link start
--  Switch 1 = link disable
--  Switch 2 = send data
--  Switch 3 = send time codes
--  Switch 4-7 = bits 0-3 of tx bit rate scale factor
--
--  SpaceWire signals on expansion connector J12:
--    Data In    pos,neg  =  m1,m2  =  pin 3,2
--    Strobe In  pos,neg  =  m3,m4  =  pin 6,5
--    Data Out   pos,neg  =  n1,n2  =  pin 9,8
--    Strobe Out pos,neg  =  n3,n4  =  pin 12,11
--
--  To get proper LVDS signals from connector J12, the voltage on I/O bank 6
--  must be set to 2.5V. This is the default on GR-XC3S-1500-rev2, but on
--  GR-XC3S-1500-rev1 a change is required on the board (described in
--  the board manual).
--
--  To terminate the incoming LVDS signals, 100 Ohm termination resistors
--  must be installed on the board in positions R120 and R121.
--
--  The SpaceWire port should be looped back to itself, either directly
--  or via an other SpaceWire device. For a direct loopback, place 4 wires
--  from the output pins to the corresponding input pins. For an indirect
--  loopback, connect the SpaceWire signals to an additional SpaceWire device
--  which is programmed to echo everything it receives (characters, packets,
--  time codes). See the datasheet for a wiring diagram from J12 to MDM9.
--

library ieee;
use ieee.std_logic_1164.all, ieee.numeric_std.all;
library unisim;
use unisim.vcomponents.all;
use work.spwpkg.all;

entity streamtest_top is

    port (
        clk:        in  std_logic;
        btn_reset:  in  std_logic;
        btn_clear:  in  std_logic;
        switch:     in  std_logic_vector(7 downto 0);
        led:        out std_logic_vector(3 downto 0);
        spw_rxdp:   in  std_logic;
        spw_rxdn:   in  std_logic;
        spw_rxsp:   in  std_logic;
        spw_rxsn:   in  std_logic;
        spw_txdp:   out std_logic;
        spw_txdn:   out std_logic;
        spw_txsp:   out std_logic;
        spw_txsn:   out std_logic );

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
    signal s_sendtick:      std_logic := '0';
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
    bufg0: BUFG port map ( I => clk, O => boardclk );

    -- Generate 60 MHz system clock.
    dcm0: DCM
        generic map (
            CLKFX_DIVIDE        => 5,
            CLKFX_MULTIPLY      => 6,
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
            sendtick    => s_sendtick,
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
        port map ( O => s_spwdi, I => spw_rxdp, IB => spw_rxdn );
    spwsi_pad: IBUFDS
        generic map ( IOSTANDARD => "LVDS_25" )
        port map ( O => s_spwsi, I => spw_rxsp, IB => spw_rxsn );
    spwdo_pad: OBUFDS
        generic map ( IOSTANDARD => "LVDS_25" )
        port map ( O => spw_txdp, OB => spw_txdn, I => s_spwdo );
    spwso_pad: OBUFDS
        generic map ( IOSTANDARD => "LVDS_25" )
        port map ( O => spw_txsp, OB => spw_txsn, I => s_spwso );

    process (sysclk) is
    begin
        if rising_edge(sysclk) then

            -- Synchronize buttons
            s_resetbtn  <= btn_reset;
            s_rst       <= s_resetbtn;
            s_clearbtn  <= btn_clear;

            -- Synchronize switch settings
            s_autostart <= '0';
            s_linkstart <= switch(0);
            s_linkdisable <= switch(1);
            s_senddata  <= switch(2);
            s_sendtick  <= switch(3);
            s_txdivcnt(7 downto 4) <= "0000";
            s_txdivcnt(3 downto 0) <= switch(7 downto 4);

            -- Sticky link error LED
            s_linkerrorled <= (s_linkerrorled or s_linkerror) and
                              (not s_clearbtn) and
                              (not s_resetbtn);

            -- Drive LEDs (inverted logic)
            led(0)  <= not s_linkrun;
            led(1)  <= not s_linkerrorled;
            led(2)  <= not s_gotdata;
            led(3)  <= not (s_dataerror or s_tickerror);

        end if;
    end process;

end architecture streamtest_top_arch;
