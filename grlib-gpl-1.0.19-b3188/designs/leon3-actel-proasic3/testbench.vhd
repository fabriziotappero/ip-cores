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
use gaisler.jtagtst.all;
library techmap;
use techmap.gencomp.all;
use work.debug.all;
library gsi;
use gsi.all;

use work.config.all;	-- configuration

entity testbench is
  generic (
    fabtech   : integer := CFG_FABTECH;
    memtech   : integer := CFG_MEMTECH;
    padtech   : integer := CFG_PADTECH;
    clktech   : integer := CFG_CLKTECH;
    disas     : integer := CFG_DISAS;	-- Enable disassembly to console
    dbguart   : integer := CFG_DUART;	-- Print UART on console
    pclow     : integer := CFG_PCLOW;

    clkperiod : integer := 20;		-- system clock period
    romwidth  : integer := 32;		-- rom data width (8/32)
    romdepth  : integer := 16;		-- rom address depth
    sramwidth  : integer := 32;		-- ram data width (8/16/32)
    sramdepth  : integer := 18;		-- ram address depth
    srambanks  : integer := 2		-- number of ram banks
  );
end; 

architecture behav of testbench is

constant promfile  : string := "prom.srec";  -- rom contents
constant sramfile  : string := "sram.srec";  -- ram contents
constant sdramfile : string := "sdram.srec"; -- sdram contents

signal clk : std_logic := '0';
signal Rst    : std_logic := '0';			-- Reset
constant ct : integer := clkperiod/2;

signal address  : std_logic_vector(27 downto 0) := (others => '0');
signal data     : std_logic_vector(31 downto 0);

signal ramsn    : std_logic;
signal ramoen   : std_logic;
signal rwen     : std_logic;
signal ramben   : std_logic_vector(3 downto 0);
signal romsn    : std_logic;
signal iosn     : std_ulogic;
signal oen      : std_ulogic;
signal writen   : std_ulogic;
signal brdyn    : std_ulogic;
signal bexcn    : std_ulogic;
signal wdog     : std_ulogic;
signal dsutx, dsurx, dsubre, dsuact : std_ulogic;
signal dsurst   : std_ulogic;
signal test     : std_ulogic;
signal error    : std_logic;
signal gpio	: std_logic_vector(6 downto 0);
signal GND      : std_ulogic := '0';
signal VCC      : std_ulogic := '1';
signal NC       : std_ulogic := 'Z';
signal clk2     : std_ulogic := '1';
    
signal txd1, rxd1 : std_ulogic;       
signal txd2, rxd2 : std_ulogic;       

signal etx_clk, erx_clk, erx_dv, erx_er, erx_col, erx_crs, etx_en, etx_er : std_logic:='0';
signal erxd, etxd: std_logic_vector(3 downto 0):=(others=>'0');
signal erxdt, etxdt: std_logic_vector(7 downto 0):=(others=>'0');  
signal emdc, emdio: std_logic; --dummy signal for the mdc,mdio in the phy which is not used
signal gtx_clk : std_ulogic := '0';

constant lresp : boolean := false;

signal flash_byten : std_logic;
signal flash_rpn   : std_logic;
signal sram_pwrdwn : std_logic;
signal sram_gwen   : std_logic;
signal sram_adsc   : std_logic;
signal sram_adsp   : std_logic;
signal sram_adv    : std_logic;
signal can_txd	: std_logic;
signal can_rxd	: std_logic;
signal ramclk	: std_logic;
signal datazz	: std_logic;
signal tck, trst, tdi, tms, tdo : std_ulogic;


begin

-- clock and reset

  clk <= not clk after ct * 1 ns;
  rst <= dsurst;
  dsubre <= '0';
  rxd1 <= txd1;

  d3 : entity work.leon3mp
        generic map ( fabtech, memtech, padtech, clktech, disas, dbguart, pclow )
        port map (rst, clk, error, address(20 downto 2), data, 
	dsutx, dsurx, dsubre, dsuact, txd1, rxd1,
	ramsn, ramoen, ramben, rwen, oen, writen, romsn, iosn, ramclk, gpio,
	flash_byten, flash_rpn, sram_pwrdwn, sram_gwen,
	sram_adsc, sram_adsp, sram_adv, can_txd, can_rxd, 
        emdio, etx_clk, erx_clk, erxd, erx_dv, erx_er, erx_col, erx_crs,
        etxd, etx_en, etx_er, emdc, open, tck, tms, tdi, trst, tdo);

    prom0 : for i in 0 to (romwidth/8)-1 generate
      sr0 : sram generic map (index => i, abits => romdepth, fname => promfile)
	port map (address(romdepth+1 downto 2), data(31-i*8 downto 24-i*8), romsn,
		  rwen, oen);
    end generate;


    sssram0 : for i in 0 to 1 generate
      u0 : entity gsi.g880e18bt --generic map (fname => sramfile)
      port map(
        A88 => address(18 downto 0), 
        DQa(9) => datazz, DQa(8 downto 1) => data(i*16+7 downto i*16),
        DQb(9) => datazz, DQb(8 downto 1) => data(i*16+15 downto i*16+8),
        nBa => ramben(i*2), nBb => ramben(i*2+1),
        CK => ramclk, nBW => rwen, nGW => sram_gwen, 
        nE1 => ramsn, E2 => '1', nE3 => ramsn, 
        nG => ramoen, nADV => sram_adv, nADSC => sram_adsc,
	nADSP => sram_adsp, Zz => sram_pwrdwn, nFT => '1',
	nLBO => '0');

    end generate;

  phy0 : if (CFG_GRETH = 1) generate
    emdio <= 'H';
    erxd <= erxdt(3 downto 0);
    etxdt <= "0000" & etxd;
    
    p0: phy
      generic map(base1000_t_fd => 0, base1000_t_hd => 0)
      port map(rst, emdio, etx_clk, erx_clk, erxdt, erx_dv,
      erx_er, erx_col, erx_crs, etxdt, etx_en, etx_er, emdc, gtx_clk);
  end generate;
  error <= 'H';			  -- ERROR pull-up

   iuerr : process
   begin
     wait for 2500 ns;
     if to_x01(error) = '1' then wait on error; end if;
     assert (to_x01(error) = '1') 
       report "*** IU in error mode, simulation halted ***"
         severity failure ;
   end process;

  data <= buskeep(data), (others => 'H') after 250 ns;
--  data <= (others => 'Z');

  test0 :  grtestmod
    port map ( rst, clk, error, address(21 downto 2), data,
    	       iosn, oen, writen, brdyn);


  dsucom : process
    procedure dsucfg(signal dsurx : in std_ulogic; signal dsutx : out std_ulogic) is
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
    txa(dsutx, 16#91#, 16#00#, 16#00#, 16#00#, txp);
    txa(dsutx, 16#00#, 16#00#, 16#00#, 16#6f#, txp);
    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#90#, 16#11#, 16#00#, 16#00#, txp);
    txa(dsutx, 16#00#, 16#00#, 16#00#, 16#00#, txp);
    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#90#, 16#40#, 16#00#, 16#04#, txp);
    txa(dsutx, 16#00#, 16#02#, 16#20#, 16#01#, txp);
    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#90#, 16#00#, 16#00#, 16#20#, txp);
    txa(dsutx, 16#00#, 16#00#, 16#00#, 16#02#, txp);

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

  jtagproc : process
  begin
    wait;
    trst <= '1';
    jtagcom(tdo, tck, tms, tdi, 40, 20, 16#40000000#, true);
    wait;
   end process;
  
end ;

