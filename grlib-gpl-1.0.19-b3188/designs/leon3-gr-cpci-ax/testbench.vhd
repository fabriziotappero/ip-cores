-----------------------------------------------------------------------------
--  LEON3 Demonstration design test bench
--  Copyright (C) 2004 Jiri Gaisler, Gaisler Research
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library gaisler;
use gaisler.libdcom.all;
use gaisler.sim.all;
use gaisler.ambatest.all;
use gaisler.pcitb.all;
library techmap;
use techmap.gencomp.all;
library grlib;
use grlib.stdlib.all;
library micron;
use micron.components.all;

use work.config.all;	-- configuration
use work.debug.all;
use std.textio.all;

entity testbench is
  generic (
    fabtech   : integer := CFG_FABTECH;
    memtech   : integer := CFG_MEMTECH;
    padtech   : integer := CFG_PADTECH;
    clktech   : integer := CFG_CLKTECH;
    disas     : integer := CFG_DISAS;	-- Enable disassembly to console
    dbguart   : integer := CFG_DUART;	-- Print UART on console
    pclow     : integer := CFG_PCLOW;

    clkperiod : integer := 100;		-- system clock period
    romwidth  : integer := 8;		-- rom data width (8/32)
    romdepth  : integer := 23;		-- rom address depth
    sramwidth  : integer := 32;		-- ram data width (8/16/32)
    sramdepth  : integer := 20;		-- ram address depth
    srambanks  : integer := 2		-- number of ram banks
  );
end;

architecture behav of testbench is

constant promfile  : string := "prom.srec";  -- rom contents
constant sramfile  : string := "sram.srec";  -- ram contents
constant sdramfile : string := "sdram.srec"; -- sdram contents

component leon3ax
--    generic (
--      fabtech  : integer := CFG_FABTECH;
--      memtech  : integer := CFG_MEMTECH;
--      padtech  : integer := CFG_PADTECH;
--      clktech  : integer := CFG_CLKTECH;
--      disas     : integer := CFG_DISAS;	-- Enable disassembly to console
--      dbguart   : integer := CFG_DUART;	-- Print UART on console
--      pclow     : integer := CFG_PCLOW
--    );
  port (
    resetn        : in     std_logic;
    clk           : in     std_logic;

    errorn        : out    std_logic;

    sa            : out    std_logic_vector(15 downto 0);-- {sa(15) unused}
    sd            : inout  std_logic_vector(63 downto 0);
    scb           : inout  std_logic_vector(7 downto 0);
    sdclkfb       : in     std_logic;                   -- {unused by default}
    sdcsn         : out    std_logic_vector(1 downto 0); -- SDRAM chip select
    sdwen         : out    std_logic;                   -- SDRAM write enable
    sdrasn        : out    std_logic;                   -- SDRAM RAS
    sdcasn        : out    std_logic;                   -- SDRAM CAS
    sddqm         : out    std_logic_vector(7 downto 0); -- SDRAM DQM

    dsutx         : out    std_logic;                   -- DSU tx data
    dsurx         : in     std_logic;                   -- DSU rx data
    dsuen         : in     std_logic;
    dsubre        : in     std_logic;
    dsuact        : out    std_logic;
    txd           : out    std_logic_vector(1 to 2);     -- UART tx data
    rxd           : in     std_logic_vector(1 to 2);     -- UART rx data
    rtsn          : out    std_logic_vector(1 to 2);     -- UART rtsn
    ctsn          : in     std_logic_vector(1 to 2);     -- UART ctsn

    address       : out    std_logic_vector(27 downto 0);
    data          : inout  std_logic_vector(31 downto 0);

    ramsn         : out    std_logic_vector(4 downto 0);
    ramoen        : out    std_logic_vector(4 downto 0);
    rwen          : out    std_logic_vector(3 downto 0);
    ramben        : out    std_logic_vector(3 downto 0);
    oen           : out    std_logic;
    writen        : out    std_logic;
    read          : out    std_logic;
    iosn          : out    std_logic;
    romsn         : out    std_logic_vector(1 downto 0);

    cb            : inout  std_logic_vector(7 downto 0); -- {unused by default}
    bexcn         : in     std_logic;                    -- {unused by default}
    brdyn         : in     std_logic;                    -- {unused by default}

    gpio          : inout  std_logic_vector(15 downto 0);-- {unused by default}
    pciio         : inout  std_logic_vector(31 downto 0);-- {unused by default}

    pci_rst       : inout  std_logic;                   -- PCI bus
    pci_clk       : in     std_logic;

    pci_gnt       : in     std_logic;
    pci_idsel     : in     std_logic;
    pci_lock      : inout  std_logic;
    pci_ad        : inout  std_logic_vector(63 downto 0);
    pci_cbe       : inout  std_logic_vector(7 downto 0);
    pci_frame     : inout  std_logic;
    pci_irdy      : inout  std_logic;
    pci_trdy      : inout  std_logic;
    pci_devsel    : inout  std_logic;
    pci_stop      : inout  std_logic;
    pci_perr      : inout  std_logic;
    pci_par       : inout  std_logic;
    pci_req       : inout  std_logic;
    pci_serr      : inout  std_logic;
    pci_host      : in     std_logic;
    pci_66        : in     std_logic;

    --pci_arb_gnt   : out    std_logic_vector(7 downto 0);
    pci_arb_req   : in     std_logic_vector(7 downto 0);

    pci_ack64n    : inout  std_logic;                    -- {unused by default}
    pci_par64     : inout  std_logic;                    -- {unused by default}
    pci_req64n    : inout  std_logic;                    -- {unused by default}
    pci_en64      : in     std_logic                     -- {unused by default}
  );
end component;

signal clk    : std_logic := '0';
signal Rst    : std_logic := '0';			-- Reset
constant ct     : integer := clkperiod/2;

signal address  : std_logic_vector(27 downto 0);
signal data     : std_logic_vector(31 downto 0);

signal ramsn    : std_logic_vector(4 downto 0);
signal ramoen   : std_logic_vector(4 downto 0);
signal rwen     : std_logic_vector(3 downto 0);
signal romsn    : std_logic_vector(1 downto 0);
signal iosn     : std_logic;
signal oen      : std_logic;
signal read     : std_logic;
signal writen   : std_logic;
signal brdyn    : std_logic;
signal bexcn    : std_logic;
signal dsuen, dsutx, dsurx, dsubre, dsuact : std_logic;
signal dsurst   : std_logic;
signal error    : std_logic;
signal GND      : std_logic := '0';
signal VCC      : std_logic := '1';

signal sdcke    : std_logic_vector ( 1 downto 0);  -- clk en
signal sdcsn    : std_logic_vector ( 1 downto 0);  -- chip sel
signal sdwen    : std_logic;                       -- write en
signal sdrasn   : std_logic;                       -- row addr stb
signal sdcasn   : std_logic;                       -- col addr stb
signal sddqm    : std_logic_vector ( 7 downto 0);  -- data i/o mask

signal pci_rst  : Std_Logic := '0';	-- PCI bus
signal pci_clk 	: std_logic := '0';

constant lresp : boolean := false;

signal sa      	: std_logic_vector(15 downto 0);
signal sd   	: std_logic_vector(63 downto 0);

signal   sdclkfb       : Std_ULogic;                   -- {unused by default}

signal txd, rxd : std_logic_vector(1 to 2);
signal rtsn, ctsn : std_logic_vector(1 to 2);

signal   ramben        : std_logic_vector(3 downto 0); -- {unused by default}
signal   cb            : std_logic_vector(7 downto 0); -- {unused by default}
signal   gpio          : std_logic_vector(15 downto 0);-- {unused by default}
signal   pciio         : std_logic_vector(31 downto 0);-- {unused by default}

-- PCI signals

constant tval : time := 7 ns;
constant slots : integer := 1;

constant ad_const2 : pci_ad_type := (
          ad => (others => 'Z'),
          cbe => (others => 'L'),
          par => 'Z');
constant pci_idle2 : pci_type := ( ad_const2, ifc_const, err_const, arb_const,
  syst_const, ext64_const, int_const, cache_const);

signal pci     : pci_type;
signal rsttrig : std_logic;
signal tbi     : tbi_array_type;
signal tbo     : tbo_array_type;

signal pci_cbe  : std_logic_vector(7 downto 4);
signal pci_ad   : std_logic_vector(63 downto 32);
signal pci_host : std_logic;
signal pci_66   : std_logic;
signal pci_en64 : std_logic;

begin

-- clock and reset

  clk <= not clk after ct * 1 ns;
  rst <= dsurst;
  dsuen <= '1'; dsubre <= '0'; rxd(1) <= '1';
  sdcke <= "11";
  pci_clk <= not pci_clk after 25 ns;
  pci_rst <= '0', '1' after 500 ns;

  data <= buskeep(data) after 5 ns;

  leon3ax_0 : leon3ax
   port map(
   resetn     => rst,
   clk        => clk,
   errorn     => error,            --##errorn
   sa         => sa,
   sd         => sd(63 downto 0),
   scb        => cb(7 downto 0),
   sdclkfb    => sdclkfb,
   sdcsn      => sdcsn,
   sdwen      => sdwen,
   sdrasn     => sdrasn,
   sdcasn     => sdcasn,
   sddqm      => sddqm,
   dsutx      => dsutx,
   dsurx      => dsurx,
   dsuen      => dsuen,
   dsubre     => dsubre,
   dsuact     => dsuact,
   txd        => txd,
   rxd        => rxd,
   rtsn       => rtsn,
   ctsn       => ctsn,
   address    => address(27 downto 0),
   data       => data,
   ramsn      => ramsn,
   ramoen     => ramoen,
   rwen       => rwen,
   ramben     => ramben,
   oen        => oen,
   writen     => writen,
   read       => read,
   iosn       => iosn,
   romsn      => romsn,
   cb         => cb,
   bexcn      => bexcn,
   brdyn      => brdyn,
   gpio       => gpio,
   pciio      => pciio,
   pci_rst    => pci.syst.rst,
   pci_clk    => pci.syst.clk,
   pci_gnt    => pci.arb.gnt(20),
   pci_idsel            => pci.ifc.idsel(0),
   pci_lock             => pci.ifc.lock,
   pci_ad(31 downto 0)  => pci.ad.ad,
   pci_ad(63 downto 32) => pci_ad,
   pci_cbe(3 downto 0)  => pci.ad.cbe,
   pci_cbe(7 downto 4)  => pci_cbe,
   pci_frame            => pci.ifc.frame,
   pci_irdy             => pci.ifc.irdy,
   pci_trdy             => pci.ifc.trdy,
   pci_devsel           => pci.ifc.devsel,
   pci_stop             => pci.ifc.stop,
   pci_perr             => pci.err.perr,
   pci_par              => pci.ad.par,
   pci_req              => pci.arb.req(20),
   pci_serr             => pci.err.serr,
   pci_host             => pci_host,
   pci_66               => pci_66,
   --pci_arb_gnt,
   pci_arb_req          => pci.arb.req(7 downto 0),
   pci_ack64n           => pci.ext64.ack64,
   pci_par64            => pci.ext64.par64,
   pci_req64n           => pci.ext64.req64,
   pci_en64             => pci_en64);

-- testmodule

  test0 :  grtestmod
    port map ( rst, clk, error, address(21 downto 2), data,
               iosn, oen, writen, brdyn);

-- PCI tests

  pci <= pci_idle2;

  pci_66 <= '1'; pci_host <= '1'; pci_en64 <= '1';
  pci.ifc.idsel(slots-1 downto 0) <= pci.ad.ad(31 downto (32-slots));
  pci_cbe <= (others => 'Z'); pci_ad <= (others => 'Z');

  clkgen : pcitb_clkgen
    generic map(mhz66 => false, rstclocks => 20)
    port map(rsttrig => rsttrig, systclk => pci.syst);

  arbiter : pcitb_arb
    generic map(slots => slots, tval => tval)
    port map(systclk => pci.syst, ifcin => pci.ifc, arbin => pci.arb, arbout => pci.arb);

  monitor : pcitb_monitor
    generic map(dbglevel => 5)
    port map(pciin => pci);

  master : pcitb_master
    generic map(tval => tval, dbglevel => 5)
    port map(pciin => pci, pciout => pci, tbi => tbi(0), tbo => tbo(0));

  stimgen : pcitb_stimgen
    generic map(slots => slots, dbglevel => 5)
    port map(rsttrig => rsttrig, tbi => tbi, tbo => tbo);


-- optional sdram

  sd1 : if (CFG_SDEN = 1) generate
    u0: mt48lc16m16a2 generic map (index => 0, fname => sdramfile)
	PORT MAP(
            Dq => sd(31 downto 16), Addr => sa(12 downto 0),
            Ba => sa(14 downto 13), Clk => clk, Cke => sdcke(0),
            Cs_n => sdcsn(0), Ras_n => sdrasn, Cas_n => sdcasn, We_n => sdwen,
            Dqm => sddqm(3 downto 2));
    u1: mt48lc16m16a2 generic map (index => 16, fname => sdramfile)
	PORT MAP(
            Dq => sd(15 downto 0), Addr => sa(12 downto 0),
            Ba => sa(14 downto 13), Clk => clk, Cke => sdcke(0),
            Cs_n => sdcsn(0), Ras_n => sdrasn, Cas_n => sdcasn, We_n => sdwen,
            Dqm => sddqm(1 downto 0));
    u2: mt48lc16m16a2 generic map (index => 0, fname => sdramfile)
	PORT MAP(
            Dq => sd(31 downto 16), Addr => sa(12 downto 0),
            Ba => sa(14 downto 13), Clk => clk, Cke => sdcke(0),
            Cs_n => sdcsn(1), Ras_n => sdrasn, Cas_n => sdcasn, We_n => sdwen,
            Dqm => sddqm(3 downto 2));
    u3: mt48lc16m16a2 generic map (index => 16, fname => sdramfile)
	PORT MAP(
            Dq => sd(15 downto 0), Addr => sa(12 downto 0),
            Ba => sa(14 downto 13), Clk => clk, Cke => sdcke(0),
            Cs_n => sdcsn(1), Ras_n => sdrasn, Cas_n => sdcasn, We_n => sdwen,
            Dqm => sddqm(1 downto 0));
    u4: mt48lc16m16a2 generic map (index => 0, fname => sdramfile)
	PORT MAP(
            Dq => sd(63 downto 48), Addr => sa(12 downto 0),
            Ba => sa(14 downto 13), Clk => clk, Cke => sdcke(0),
            Cs_n => sdcsn(0), Ras_n => sdrasn, Cas_n => sdcasn, We_n => sdwen,
            Dqm => sddqm(7 downto 6));
    u5: mt48lc16m16a2 generic map (index => 16, fname => sdramfile)
	PORT MAP(
            Dq => sd(47 downto 32), Addr => sa(12 downto 0),
            Ba => sa(14 downto 13), Clk => clk, Cke => sdcke(0),
            Cs_n => sdcsn(0), Ras_n => sdrasn, Cas_n => sdcasn, We_n => sdwen,
            Dqm => sddqm(5 downto 4));
    u6: mt48lc16m16a2 generic map (index => 0, fname => sdramfile)
	PORT MAP(
            Dq => sd(63 downto 48), Addr => sa(12 downto 0),
            Ba => sa(14 downto 13), Clk => clk, Cke => sdcke(0),
            Cs_n => sdcsn(1), Ras_n => sdrasn, Cas_n => sdcasn, We_n => sdwen,
            Dqm => sddqm(7 downto 6));
    u7: mt48lc16m16a2 generic map (index => 16, fname => sdramfile)
	PORT MAP(
            Dq => sd(47 downto 32), Addr => sa(12 downto 0),
            Ba => sa(14 downto 13), Clk => clk, Cke => sdcke(0),
            Cs_n => sdcsn(1), Ras_n => sdrasn, Cas_n => sdcasn, We_n => sdwen,
            Dqm => sddqm(5 downto 4));
  end generate;

  prom0 : sram generic map (index => 6, abits => romdepth, fname => promfile)
	port map (address(romdepth-1 downto 0), data(31 downto 24),
		  romsn(0), rwen(0), oen);

  sram0 : sram16 generic map (index => 0, abits => sramdepth, fname => sramfile)
	port map (address(sramdepth+1 downto 2), data(31 downto 16),
		ramben(0), ramben(1), ramsn(0), writen, ramoen(0));
  sram1 : sram16 generic map (index => 2, abits => sramdepth, fname => sramfile)
	port map (address(sramdepth+1 downto 2), data(15 downto 0),
		ramben(2), ramben(3), ramsn(0), writen, ramoen(0));
  sram2 : sram16 generic map (index => 0, abits => sramdepth, fname => sramfile)
	port map (address(sramdepth+1 downto 2), data(31 downto 16),
		ramben(0), ramben(1), ramsn(1), writen, ramoen(1));
  sram3 : sram16 generic map (index => 2, abits => sramdepth, fname => sramfile)
	port map (address(sramdepth+1 downto 2), data(15 downto 0),
		ramben(2), ramben(3), ramsn(1), writen, ramoen(1));



   error <= 'H';			  -- ERROR pull-up

   iuerr : process
   begin
     wait for 2000 ns;
     if to_x01(error) = '1' then wait on error; end if;
     assert (to_x01(error) = '1')
       report "*** IU in error mode, simulation halted ***"
         severity failure ;
   end process;

  data <= buskeep(data), (others => 'H') after 25 ns;
  sd <= buskeep(sd), (others => 'H') after 25 ns;

  dsucom : process
    procedure dsucfg(signal dsurx : in std_logic; signal dsutx : out std_logic) is
    variable w32 : std_logic_vector(31 downto 0);
    variable c8  : std_logic_vector(7 downto 0);
    constant txp : time := 160 * 1 ns;
    begin
    dsutx <= '1';
    dsurst <= '0';
    wait for 500 ns;
    dsurst <= '1';
    wait;
    wait for 5000 ns;
    txc(dsutx, 16#55#, txp);		-- sync uart

    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#90#, 16#00#, 16#00#, 16#00#, txp);
    txa(dsutx, 16#00#, 16#00#, 16#00#, 16#ef#, txp);

    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#90#, 16#00#, 16#00#, 16#20#, txp);
    txa(dsutx, 16#00#, 16#00#, 16#ff#, 16#ff#, txp);

    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#90#, 16#40#, 16#00#, 16#48#, txp);
    txa(dsutx, 16#00#, 16#00#, 16#00#, 16#12#, txp);

    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#90#, 16#40#, 16#00#, 16#60#, txp);
    txa(dsutx, 16#00#, 16#00#, 16#12#, 16#10#, txp);

    txc(dsutx, 16#80#, txp);
    txa(dsutx, 16#90#, 16#00#, 16#00#, 16#00#, txp);
    rxi(dsurx, w32, txp, lresp);

    txc(dsutx, 16#a0#, txp);
    txa(dsutx, 16#40#, 16#00#, 16#00#, 16#00#, txp);
    rxi(dsurx, w32, txp, lresp);

    end;

  begin

    dsucfg(dsutx, dsurx);

    wait;
  end process;

    sdclkfb       <= clk;

    rxd(2)        <= '1';
    ctsn(1)       <= '0';
    ctsn(2)       <= '0';

    cb            <= (others => 'H');
    bexcn         <= '1';

    gpio          <= (others => 'H');
    pciio         <= (others => 'H');

end;

