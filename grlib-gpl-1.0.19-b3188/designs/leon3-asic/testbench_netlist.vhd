------------------------------------------------------------------------------
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
use work.debug.all;
library techmap;
use techmap.gencomp.all;
library micron;
use micron.components.all;
use gaisler.jtagtst.all;
library dare;

use work.config.all;	-- configuration

entity testbench_netlist is
  generic (
    fabtech   : integer := CFG_FABTECH;
    memtech   : integer := CFG_MEMTECH;
    padtech   : integer := CFG_PADTECH;
    clktech   : integer := CFG_CLKTECH;
    disas     : integer := CFG_DISAS;	-- Enable disassembly to console
    dbguart   : integer := CFG_DUART;	-- Print UART on console
    pclow     : integer := CFG_PCLOW;

    clkperiod : integer := 1000;		-- system clock period
    romwidth  : integer := 32;		-- rom data width (8/32)
    romdepth  : integer := 16;		-- rom address depth
    sramwidth  : integer := 32;		-- ram data width (8/16/32)
    sramdepth  : integer := 18;		-- ram address depth
    srambanks  : integer := 2;		-- number of ram banks
    testen  : integer := 0;
    scanen  : integer := 0;
    testrst : integer := 0;
    testoen : integer := 0
  );
end; 

architecture behav of testbench_netlist is

constant promfile  : string := "prom.srec";  -- rom contents
constant sramfile  : string := "sram.srec";  -- ram contents
constant sdramfile : string := "sdram.srec"; -- sdram contents
signal clk : std_logic := '0';
signal Rst    : std_logic := '0';			-- Reset
constant ct : integer := clkperiod/2;

signal address  : std_logic_vector(27 downto 0);
signal data     : std_logic_vector(31 downto 0);
signal cb  : std_logic_vector(15 downto 0);

signal ramsn    : std_logic_vector(4 downto 0);
signal ramoen   : std_logic_vector(4 downto 0);
signal rwen     : std_logic_vector(3 downto 0);
signal rwenx    : std_logic_vector(3 downto 0);
signal romsn    : std_logic_vector(1 downto 0);
signal iosn     : std_ulogic;
signal oen      : std_ulogic;
signal read     : std_ulogic;
signal writen   : std_ulogic;
signal brdyn    : std_ulogic;
signal bexcn    : std_ulogic;
signal wdogn    : std_logic;
signal dsuen, dsutx, dsurx, dsubre, dsuact : std_ulogic;
signal dsurst   : std_ulogic;
signal test     : std_ulogic;
signal error    : std_logic;
signal gpio	: std_logic_vector(CFG_GRGPIO_WIDTH-1 downto 0);
signal VCC      : std_ulogic := '1';
signal NC       : std_ulogic := 'Z';
signal clk2     : std_ulogic := '1';
    
signal sdcke    : std_logic_vector ( 1 downto 0);  -- clk en
signal sdcsn    : std_logic_vector ( 1 downto 0);  -- chip sel
signal sdwen    : std_ulogic;                       -- write en
signal sdrasn   : std_ulogic;                       -- row addr stb
signal sdcasn   : std_ulogic;                       -- col addr stb
signal sddqm    : std_logic_vector ( 3 downto 0);  -- data i/o mask
signal sdclk    : std_ulogic := '0';
signal plllock    : std_ulogic;       
signal txd1, rxd1 : std_ulogic;       
signal txd2, rxd2 : std_ulogic;       
signal roen, roout, nandout, promedac : std_ulogic;       

constant lresp : boolean := false;

signal gnd   	: std_logic_vector(3 downto 0);
signal clksel   : std_logic_vector(1 downto 0);
signal promwidth: std_logic_vector(1 downto 0);
signal spw_clksel : std_logic_vector(1 downto 0);

signal spw_clk	: std_ulogic := '0';
signal spw_rxdp : std_logic_vector(0 to CFG_SPW_NUM-1);
signal spw_rxsp : std_logic_vector(0 to CFG_SPW_NUM-1);
signal spw_txdp : std_logic_vector(0 to CFG_SPW_NUM-1);
signal spw_txsp : std_logic_vector(0 to CFG_SPW_NUM-1);
signal spw_rxdn : std_logic_vector(0 to CFG_SPW_NUM-1);
signal spw_rxsn : std_logic_vector(0 to CFG_SPW_NUM-1);
signal spw_txdn : std_logic_vector(0 to CFG_SPW_NUM-1);
signal spw_txsn : std_logic_vector(0 to CFG_SPW_NUM-1);

begin

-- clock and reset

  test <= '0' when testen  = 0 else '1';
  rxd1 <= '1' when (testen = 1) and (testoen = 1) else
          '0' when (testen = 1) and (testoen = 0) else txd1;
  dsuen <= '1' when (testen = 1) and (testrst = 1) else
          '0' when (testen = 1) and (testrst = 0) else '1';
  dsubre <= '1' when (testen = 1) and (scanen = 1) else
          '0' when (testen = 1) and (scanen = 0) else '0';

  clksel <= "00";
  spw_clksel <= "00";
  error <= 'H';
  gnd <= "0000";
  clk <= not clk after ct * 1 ns;
  spw_clk <= not spw_clk after 10 ns;
  rst <= dsurst;
  bexcn <= '1'; wdogn <= 'H';
  gpio(2 downto 0) <= "HHL"; 
--  gpio(CFG_GRGPIO_WIDTH-1 downto 3) <= (others => 'H');
  gpio(15 downto 11) <= "HLLHH"; --19
  gpio(10 downto 8) <= "HLL"; --4
  gpio(7 downto 0) <= (others => 'L');
  cb(15 downto 8) <= "HHHHHHHH";
  spw_rxdp <= spw_txdp; spw_rxsp <= spw_txsp;
  spw_rxdn <= spw_txdn; spw_rxsn <= spw_txsn;
  roen <= '0';
  promedac <= '0';
  promwidth <= "10";
  rxd2 <= txd2;

  d3 : entity dare.leon3mp
        port map (rst, clksel, clk, error, wdogn, address, data, 
	cb(7 downto 0), sdclk, sdcsn, sdwen, 
	sdrasn, sdcasn, sddqm, dsutx, dsurx, dsuen, dsubre, dsuact, 
	txd1, rxd1, txd2, rxd2,
	ramsn, ramoen, rwen, oen, writen, read, iosn, romsn, brdyn, bexcn, gpio,
	promwidth, promedac,
	spw_clksel, spw_clk, spw_rxdp, spw_rxdn, spw_rxsp, spw_rxsn, spw_txdp, spw_txdn,
        spw_txsp, spw_txsn, gnd(0), roen, roout, nandout, test);

-- optional sdram

  sd0 : if (CFG_MCTRLFT_SDEN = 1) and (CFG_MCTRLFT_SEPBUS = 0) generate
    u0: mt48lc16m16a2 generic map (index => 0, fname => sdramfile)
	PORT MAP(
            Dq => data(31 downto 16), Addr => address(14 downto 2),
            Ba => address(16 downto 15), Clk => sdclk, Cke => sdcke(0),
            Cs_n => sdcsn(0), Ras_n => sdrasn, Cas_n => sdcasn, We_n => sdwen,
            Dqm => sddqm(3 downto 2));
    u1: mt48lc16m16a2 generic map (index => 16, fname => sdramfile)
	PORT MAP(
            Dq => data(15 downto 0), Addr => address(14 downto 2),
            Ba => address(16 downto 15), Clk => sdclk, Cke => sdcke(0),
            Cs_n => sdcsn(0), Ras_n => sdrasn, Cas_n => sdcasn, We_n => sdwen,
            Dqm => sddqm(1 downto 0));
    cb0: ftmt48lc16m16a2 generic map (index => 8, fname => sdramfile)
	PORT MAP(
            Dq => cb(15 downto 0), Addr => address(14 downto 2),
            Ba => address(16 downto 15), Clk => sdclk, Cke => sdcke(0),
            Cs_n => sdcsn(0), Ras_n => sdrasn, Cas_n => sdcasn, We_n => sdwen,
            Dqm => sddqm(1 downto 0));
    u2: mt48lc16m16a2 generic map (index => 0, fname => sdramfile)
	PORT MAP(
            Dq => data(31 downto 16), Addr => address(14 downto 2),
            Ba => address(16 downto 15), Clk => sdclk, Cke => sdcke(0),
            Cs_n => sdcsn(1), Ras_n => sdrasn, Cas_n => sdcasn, We_n => sdwen,
            Dqm => sddqm(3 downto 2));
    u3: mt48lc16m16a2 generic map (index => 16, fname => sdramfile)
	PORT MAP(
            Dq => data(15 downto 0), Addr => address(14 downto 2),
            Ba => address(16 downto 15), Clk => sdclk, Cke => sdcke(0),
            Cs_n => sdcsn(1), Ras_n => sdrasn, Cas_n => sdcasn, We_n => sdwen,
            Dqm => sddqm(1 downto 0));
    cb1: ftmt48lc16m16a2 generic map (index => 8, fname => sdramfile)
	PORT MAP(
            Dq => cb(15 downto 0), Addr => address(14 downto 2),
            Ba => address(16 downto 15), Clk => sdclk, Cke => sdcke(0),
            Cs_n => sdcsn(1), Ras_n => sdrasn, Cas_n => sdcasn, We_n => sdwen,
            Dqm => sddqm(1 downto 0));
  end generate;

  prom0 : for i in 0 to (romwidth/8)-1 generate
      sr0 : sram generic map (index => i, abits => romdepth, fname => promfile)
	port map (address(romdepth+1 downto 2), data(31-i*8 downto 24-i*8), romsn(0),
		  rwen(i), oen);
  end generate;

  promcb0 : sramft generic map (index => 7, abits => romdepth, fname => promfile)
	port map (address(romdepth+1 downto 2), cb(7 downto 0), romsn(0), writen, oen);

  sram0 : for i in 0 to (sramwidth/8)-1 generate
      sr0 : sram generic map (index => i, abits => sramdepth, fname => sramfile)
	port map (address(sramdepth+1 downto 2), data(31-i*8 downto 24-i*8), ramsn(0),
		  rwen(0), ramoen(0));
  end generate;

  sramcb0 : sramft generic map (index => 7, abits => sramdepth, fname => sramfile)
	port map (address(sramdepth+1 downto 2), cb(7 downto 0), ramsn(0), rwen(0), ramoen(0));

   iuerr : process
   begin
     wait for (100*clkperiod) * 1 ns;
     if to_x01(error) = '1' then wait on error; end if;
     assert (to_x01(error) = '1') 
       report "*** IU in error mode, simulation halted ***"
         severity failure ;
   end process;

  test0 :  grtestmod
    port map ( rst, clk, error, address(21 downto 2), data,
    	       iosn, oen, writen, brdyn);

  data <= buskeep(data), (others => 'H') after 250 ns;
  cb <= buskeep(cb), (others => 'H') after 250 ns;

  dsucom : process
    procedure dsucfg(signal dsurx : in std_ulogic; signal dsutx : out std_ulogic) is
    variable w32 : std_logic_vector(31 downto 0);
    variable c8  : std_logic_vector(7 downto 0);
    constant txp : time := clkperiod*16 * 1 ns;
    begin
    dsutx <= '1';
    dsurst <= '0';
    wait for 500 ns;
    dsurst <= '1';
    wait;	-- remove to run the DSU UART
    wait for 5010 ns;
    txc(dsutx, 16#55#, txp);		-- sync uart

--    txc(dsutx, 16#c0#, txp);
--    txa(dsutx, 16#90#, 16#00#, 16#00#, 16#00#, txp);
--    txa(dsutx, 16#00#, 16#00#, 16#02#, 16#ae#, txp);
--    txc(dsutx, 16#c0#, txp);
--    txa(dsutx, 16#91#, 16#00#, 16#00#, 16#00#, txp);
--    txa(dsutx, 16#00#, 16#00#, 16#06#, 16#ae#, txp);
--    txc(dsutx, 16#c0#, txp);
--    txa(dsutx, 16#90#, 16#00#, 16#00#, 16#24#, txp);
--    txa(dsutx, 16#00#, 16#00#, 16#06#, 16#03#, txp);
--    txc(dsutx, 16#c0#, txp);
--    txa(dsutx, 16#90#, 16#00#, 16#00#, 16#20#, txp);
--    txa(dsutx, 16#00#, 16#00#, 16#06#, 16#fc#, txp);

    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#90#, 16#00#, 16#00#, 16#00#, txp);
    txa(dsutx, 16#00#, 16#00#, 16#00#, 16#2f#, txp);
    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#90#, 16#00#, 16#00#, 16#20#, txp);
    txa(dsutx, 16#00#, 16#00#, 16#00#, 16#01#, txp);
    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#90#, 16#40#, 16#00#, 16#40#, txp);
    txa(dsutx, 16#00#, 16#00#, 16#00#, 16#0e#, txp);
    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#90#, 16#30#, 16#00#, 16#00#, txp);
    txa(dsutx, 16#00#, 16#00#, 16#00#, 16#00#, txp);
    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#90#, 16#40#, 16#00#, 16#40#, txp);
    txa(dsutx, 16#00#, 16#00#, 16#00#, 16#06#, txp);
    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#90#, 16#30#, 16#00#, 16#00#, txp);
    txa(dsutx, 16#00#, 16#00#, 16#00#, 16#00#, txp);
    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#90#, 16#40#, 16#00#, 16#40#, txp);
    txa(dsutx, 16#00#, 16#00#, 16#00#, 16#02#, txp);
    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#90#, 16#30#, 16#00#, 16#00#, txp);
    txa(dsutx, 16#00#, 16#00#, 16#00#, 16#00#, txp);

    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#90#, 16#00#, 16#00#, 16#20#, txp);
    txa(dsutx, 16#00#, 16#00#, 16#00#, 16#0f#, txp);

    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#40#, 16#00#, 16#43#, 16#10#, txp);
    txa(dsutx, 16#00#, 16#00#, 16#00#, 16#0f#, txp);

    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#91#, 16#40#, 16#00#, 16#24#, txp);
    txa(dsutx, 16#00#, 16#00#, 16#00#, 16#24#, txp);
    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#91#, 16#70#, 16#00#, 16#00#, txp);
    txa(dsutx, 16#00#, 16#00#, 16#00#, 16#03#, txp);





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

end ;

