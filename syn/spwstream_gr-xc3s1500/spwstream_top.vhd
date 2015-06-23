library ieee;
use ieee.std_logic_1164.all, ieee.numeric_std.all;
use work.spwpkg.all;

entity spwstream_top is

    port (
        clk:        in  std_logic;
        fastclk:    in  std_logic;
        rst:        in  std_logic;
        autostart:  in  std_logic;
        linkstart:  in  std_logic;
        linkdis:    in  std_logic;
	txdivcnt:   in  std_logic_vector(7 downto 0);
        tick_in:    in  std_logic;
        ctrl_in:    in  std_logic_vector(1 downto 0);
        time_in:    in  std_logic_vector(5 downto 0);
        txwrite:    in  std_logic;
        txflag:     in  std_logic;
        txdata:     in  std_logic_vector(7 downto 0);
        txrdy:      out std_logic;
        txhalff:    out std_logic;
        tick_out:   out std_logic;
        ctrl_out:   out std_logic_vector(1 downto 0);
        time_out:   out std_logic_vector(5 downto 0);
        rxvalid:    out std_logic;
        rxhalff:    out std_logic;
        rxflag:     out std_logic;
        rxdata:     out std_logic_vector(7 downto 0);
        rxread:     in  std_logic;
        started:    out std_logic;
        connecting: out std_logic;
	running:    out std_logic;
        errdisc:    out std_logic;
	errpar:     out std_logic;
        erresc:     out std_logic;
	errcred:    out std_logic;
        spw_di:     in  std_logic;
        spw_si:     in  std_logic;
        spw_do:     out std_logic;
        spw_so:     out std_logic
    );

end entity spwstream_top;

architecture spwstream_top_arch of spwstream_top is

begin

    spwstream_inst: spwstream
        generic map (
            sysfreq         => 60.0e6,
            txclkfreq       => 240.0e6,
            rximpl          => impl_fast,
            rxchunk         => 4,
            tximpl          => impl_fast,
            rxfifosize_bits => 11,
            txfifosize_bits => 6 )
        port map (
            clk         => clk,
            rxclk       => fastclk,
            txclk       => fastclk,
            rst         => rst,
            autostart   => autostart,
            linkstart   => linkstart,
            linkdis     => linkdis,
            txdivcnt    => txdivcnt,
            tick_in     => tick_in,
            ctrl_in     => ctrl_in,
            time_in     => time_in,
            txwrite     => txwrite,
            txflag      => txflag,
            txdata      => txdata,
            txrdy       => txrdy
,           txhalff     => txhalff,
            tick_out    => tick_out,
            ctrl_out    => ctrl_out,
            time_out    => time_out,
            rxvalid     => rxvalid,
            rxhalff     => rxhalff,
            rxflag      => rxflag,
            rxdata      => rxdata,
            rxread      => rxread,
            started     => started,
            connecting  => connecting,
            running     => running,
            errdisc     => errdisc,
            errpar      => errpar,
            erresc      => erresc,
            errcred     => errcred,
            spw_di      => spw_di,
            spw_si      => spw_si,
            spw_do      => spw_do,
            spw_so      => spw_so );

end architecture spwstream_top_arch;
