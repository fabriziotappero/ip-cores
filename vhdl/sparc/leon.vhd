



----------------------------------------------------------------------------
--  This file is a part of the LEON VHDL model
--  Copyright (C) 1999  European Space Agency (ESA)
--
--  This library is free software; you can redistribute it and/or
--  modify it under the terms of the GNU Lesser General Public
--  License as published by the Free Software Foundation; either
--  version 2 of the License, or (at your option) any later version.
--
--  See the file COPYING.LGPL for the full details of the license.


-----------------------------------------------------------------------------
-- Entity: 	leon
-- File:	leon.vhd
-- Author:	Jiri Gaisler - ESA/ESTEC
-- Description:	Complete processor
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.leon_target.all;
use work.leon_config.all;
use work.leon_iface.all;
use work.peri_io_comp.all;
use work.peri_mem_comp.all;
use work.tech_map.all;
-- pragma translate_off
use work.debug.all;
-- pragma translate_on

entity leon is
  port (
    resetn   : in    std_logic; 			-- system signals
    clk      : in    std_logic;
    pllref   : in    std_logic;
    plllock  : out   std_logic;

    errorn   : out   std_logic;
    address  : out   std_logic_vector(27 downto 0); 	-- memory bus

    data     : inout std_logic_vector(31 downto 0);

    ramsn    : out   std_logic_vector(4 downto 0);
    ramoen   : out   std_logic_vector(4 downto 0);
    rwen     : inout std_logic_vector(3 downto 0);
    romsn    : out   std_logic_vector(1 downto 0);
    iosn     : out   std_logic;
    oen      : out   std_logic;
    read     : out   std_logic;
    writen   : inout std_logic;

    brdyn    : in    std_logic;
    bexcn    : in    std_logic;

-- sdram i/f
    sdcke    : out std_logic_vector ( 1 downto 0);  -- clk en
    sdcsn    : out std_logic_vector ( 1 downto 0);  -- chip sel
    sdwen    : out std_logic;                       -- write en
    sdrasn   : out std_logic;                       -- row addr stb
    sdcasn   : out std_logic;                       -- col addr stb
    sddqm    : out std_logic_vector ( 3 downto 0);  -- data i/o mask
    sdclk    : out std_logic;                       -- sdram clk output

    pio      : inout std_logic_vector(15 downto 0); 	-- I/O port

    wdogn    : out   std_logic;				-- watchdog output

    dsuen    : in    std_logic;
    dsutx    : out   std_logic;
    dsurx    : in    std_logic;
    dsubre   : in    std_logic;
    dsuact   : out   std_logic;
    test     : in    std_logic
  );
end;

architecture rtl of leon is

component mcore
  port (
    resetn   : in  std_logic;
    clk      : in  clk_type;
    clkn     : in  clk_type;
    pciclk   : in  clk_type;
    memi     : in  memory_in_type;
    memo     : out memory_out_type;
    ioi      : in  io_in_type;
    ioo      : out io_out_type;
    pcii     : in  pci_in_type;
    pcio     : out pci_out_type;
    dsi      : in  dsuif_in_type;
    dso      : out dsuif_out_type;
    sdo      : out sdram_out_type;
    ethi     : in  eth_in_type;
    etho     : out eth_out_type;
    cgo      : in  clkgen_out_type;

    test     : in    std_logic
);
end component;

signal gnd, clko, sdclkl, resetno : std_logic;
signal clkm, clkn, pciclk : clk_type;
signal memi     : memory_in_type;
signal memo     : memory_out_type;
signal ioi      : io_in_type;
signal ioo      : io_out_type;
signal pcii     : pci_in_type;
signal pcio     : pci_out_type;
signal dsi      : dsuif_in_type;
signal dso      : dsuif_out_type;
signal sdo      : sdram_out_type;
signal ethi     : eth_in_type;
signal etho     : eth_out_type;
signal cgi      : clkgen_in_type;
signal cgo      : clkgen_out_type;

--attribute keep_hierarchy : String;
--attribute keep_hierarchy of rtl : architecture is "yes";

begin

  gnd <= '0'; 
  cgi.pllctrl <= "00"; cgi.pllrst <= resetno; cgi.pllref <= pllref;

-- main processor core

  mcore0  : mcore
  port map (
    resetn => resetno, clk => clkm, clkn => clkn, pciclk => pciclk,
    memi => memi, memo => memo, ioi => ioi, ioo => ioo,
    pcii => pcii, pcio => pcio, dsi => dsi, dso => dso, sdo => sdo,
    ethi => ethi, etho => etho, cgo => cgo, test => test);

-- clock generator

  clkgen0 : clkgen  
  port map ( clko, clko, clkm, clkn, sdclkl, pciclk, cgi, cgo);

-- pads

--  clk_pad   : inpad port map (clk, clko);	-- clock
  clko <= clk;					-- avoid buffering during synthesis
  reset_pad   : smpad port map (resetn, resetno);	-- reset
  brdyn_pad   : inpad port map (brdyn, memi.brdyn);	-- bus ready
  bexcn_pad   : inpad port map (bexcn, memi.bexcn);	-- bus exception


    error_pad   : outpad generic map (2) port map (ioo.errorn, errorn);	-- cpu error mode

    d_pads: for i in 0 to 31 generate			-- data bus
      d_pad : iopad generic map (3) port map (memo.data(i), memo.bdrive((31-i)/8), memi.data(i), data(i));
    end generate;


    pio_pads : for i in 0 to 15 generate		-- parallel I/O port
      pio_pad : smiopad generic map (2) port map (ioo.piol(i), ioo.piodir(i), ioi.piol(i), pio(i));
    end generate;

    rwen_pads : for i in 0 to 3 generate			-- ram write strobe
      rwen_pad : iopad generic map (2) port map (memo.wrn(i), gnd, memi.wrn(i), rwen(i));
    end generate;

     							-- I/O write strobe
    writen_pad : iopad generic map (2) port map (memo.writen, gnd, memi.writen, writen);

    a_pads: for i in 0 to 27 generate			-- memory address
      a_pad : outpad generic map (3) port map (memo.address(i), address(i));
    end generate;

    ramsn_pads : for i in 0 to 4 generate		-- ram oen/rasn
      ramsn_pad : outpad generic map (2) port map (memo.ramsn(i), ramsn(i));
    end generate;

    ramoen_pads : for i in 0 to 4 generate		-- ram chip select
      ramoen_pad : outpad generic map (2) port map (memo.ramoen(i), ramoen(i));
    end generate;

    romsn_pads : for i in 0 to 1 generate			-- rom chip select
      romsn_pad : outpad generic map (2) port map (memo.romsn(i), romsn(i));
    end generate;

    read_pad : outpad generic map (2) port map (memo.read, read);	-- memory read
    oen_pad  : outpad generic map (2) port map (memo.oen, oen);	-- memory oen
    iosn_pad : outpad generic map (2) port map (memo.iosn, iosn);	-- I/O select

    wd : if WDOGEN generate
      wdogn_pad : odpad generic map (2) port map (ioo.wdog, wdogn);	-- watchdog output
    end generate;

    ds : if DEBUG_UNIT generate
      dsuen_pad   : inpad port map (dsuen, dsi.dsui.dsuen);	-- DSU enable
      dsutx_pad   : outpad generic map (1) port map (dso.dcomo.dsutx, dsutx);
      dsurx_pad   : inpad port map (dsurx, dsi.dcomi.dsurx);	-- DSU receive data
      dsubre_pad  : inpad port map (dsubre, dsi.dsui.dsubre);	-- DSU break
      dsuact_pad  : outpad generic map (1) port map (dso.dsuo.dsuact, dsuact);
    end generate;

    sd : if SDRAMEN generate
      cs_pads: for i in 0 to 1 generate
        sdcke_pad  : outpad generic map (2) port map (sdo.sdcke(i), sdcke(i));
        sdcsn_pad  : outpad generic map (2) port map (sdo.sdcsn(i), sdcsn(i));
      end generate;
      sdwen_pad  : outpad generic map (2) port map (sdo.sdwen, sdwen);
      sdrasn_pad : outpad generic map (2) port map (sdo.rasn, sdrasn);
      sdcasn_pad : outpad generic map (2) port map (sdo.casn, sdcasn);
--      sdclk_pad : outpad generic map (2) port map (sdclkl, sdclk);
      sdclk <= sdclkl;  -- disable pad for simulation
      dqm_pads: for i in 0 to 3 generate
        sddqm_pad   : outpad generic map (2) port map (sdo.dqm(i), sddqm(i));
      end generate;
    end generate;

    pl : if TARGET_CLK /= gen generate
      plllock_pad : outpad generic map (2) port map (cgo.clklock, plllock);
    end generate;

end ;

