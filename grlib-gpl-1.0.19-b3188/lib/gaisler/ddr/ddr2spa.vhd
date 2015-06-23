------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2003, Gaisler Research
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
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 
-----------------------------------------------------------------------------
-- Entity:      ddr2spa
-- File:        ddr2spa.vhd
-- Author:      Nils-Johan Wessman - Gaisler Research
-- Description: 16-, 32- or 64-bit DDR2 memory controller module.
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
library gaisler;
use grlib.devices.all;
use gaisler.memctrl.all;
library techmap;
use techmap.gencomp.all;

entity ddr2spa is
  generic (
    fabtech : integer := virtex4;
    memtech : integer := 0;
    rskew   : integer := 0;
    hindex  : integer := 0;
    haddr   : integer := 0;
    hmask   : integer := 16#f00#;
    ioaddr  : integer := 16#000#;
    iomask  : integer := 16#fff#;
    MHz     : integer := 100;
    TRFC    : integer := 130;
    clkmul  : integer := 2;
    clkdiv  : integer := 2;
    col     : integer := 9;
    Mbyte   : integer := 16;
    rstdel  : integer := 200;
    pwron   : integer := 0;
    oepol   : integer := 0;
    ddrbits : integer := 16;
    ahbfreq : integer := 50;
    readdly : integer := 1; -- 1 added read latency cycle
    ddelayb0 : integer := 0; -- Data delay value (0 - 63)
    ddelayb1 : integer := 0; -- Data delay value (0 - 63)
    ddelayb2 : integer := 0; -- Data delay value (0 - 63)
    ddelayb3 : integer := 0; -- Data delay value (0 - 63)
    ddelayb4 : integer := 0; -- Data delay value (0 - 63)
    ddelayb5 : integer := 0; -- Data delay value (0 - 63)
    ddelayb6 : integer := 0; -- Data delay value (0 - 63)
    ddelayb7 : integer := 0; -- Data delay value (0 - 63)
    numidelctrl : integer := 4; 
    norefclk : integer := 0;
    odten    : integer := 0
  );
  port (
    rst_ddr    : in  std_ulogic;
    rst_ahb    : in  std_ulogic;
    clk_ddr    : in  std_ulogic;
    clk_ahb    : in  std_ulogic;
    clkref200  : in  std_logic;
    lock       : out std_ulogic;    -- DCM locked
    clkddro    : out std_ulogic;    -- DCM locked
    clkddri    : in  std_ulogic;
    ahbsi      : in  ahb_slv_in_type;
    ahbso      : out ahb_slv_out_type;
    ddr_clk        : out std_logic_vector(2 downto 0);
    ddr_clkb       : out std_logic_vector(2 downto 0);
    ddr_clk_fb_out : out   std_logic;
    ddr_clk_fb     : in    std_logic;
    ddr_cke        : out std_logic_vector(1 downto 0);
    ddr_csb        : out std_logic_vector(1 downto 0);
    ddr_web        : out std_ulogic;                       -- ddr write enable
    ddr_rasb       : out std_ulogic;                       -- ddr ras
    ddr_casb       : out std_ulogic;                       -- ddr cas
    ddr_dm         : out std_logic_vector (ddrbits/8-1 downto 0);    -- ddr dm
    ddr_dqs        : inout std_logic_vector (ddrbits/8-1 downto 0);  -- ddr dqs
    ddr_dqsn       : inout std_logic_vector (ddrbits/8-1 downto 0); -- ddr dqsn
    ddr_ad         : out std_logic_vector (13 downto 0);   -- ddr address
    ddr_ba         : out std_logic_vector (1 downto 0);    -- ddr bank address
    ddr_dq         : inout  std_logic_vector (ddrbits-1 downto 0); -- ddr data
    ddr_odt        : out std_logic_vector(1 downto 0)
  );
end;

architecture rtl of ddr2spa is

constant DDR_FREQ : integer := (clkmul * MHz) / clkdiv;
constant FAST_AHB : integer := AHBFREQ / DDR_FREQ;
signal sdi     : sdctrl_in_type;
signal sdo     : sdctrl_out_type;
--signal clkread  : std_ulogic;

begin

  ddr_phy0 : ddr2_phy generic map (tech => fabtech, MHz => MHz,
      dbits => ddrbits, rstdelay => rstdel, clk_mul => clkmul,
      clk_div => clkdiv,
      ddelayb0 => ddelayb0, ddelayb1 => ddelayb1, ddelayb2 => ddelayb2,
      ddelayb3 => ddelayb3, ddelayb4 => ddelayb4, ddelayb5 => ddelayb5,
      ddelayb6 => ddelayb6, ddelayb7 => ddelayb7,
      numidelctrl => numidelctrl, norefclk => norefclk, rskew => rskew)
  port map (rst_ddr, clk_ddr, clkref200, clkddro, lock,
      ddr_clk, ddr_clkb, ddr_clk_fb_out, ddr_clk_fb,
      ddr_cke, ddr_csb, ddr_web, ddr_rasb, ddr_casb, ddr_dm, 
      ddr_dqs, ddr_dqsn, ddr_ad, ddr_ba, ddr_dq, ddr_odt, sdi, sdo);

  ddr16 : if ddrbits = 16 generate
    ddrc : ddr2sp16a generic map (memtech => memtech, hindex => hindex, 
      haddr => haddr, hmask => hmask, ioaddr => ioaddr, iomask => iomask,
      pwron => pwron, MHz => DDR_FREQ, TRFC => TRFC, col => col, Mbyte => Mbyte,
      fast => FAST_AHB, readdly => readdly, odten => odten)
    port map (rst_ahb, clkddri, clk_ahb, ahbsi, ahbso, sdi, sdo);
  end generate;

  ddr32 : if ddrbits = 32 generate
    ddrc : ddr2sp32a generic map (memtech => memtech, hindex => hindex,
      haddr => haddr, hmask => hmask, ioaddr => ioaddr, iomask => iomask,
      pwron => pwron, MHz => DDR_FREQ, TRFC => TRFC, col => col, Mbyte => Mbyte,
      fast => FAST_AHB/2, readdly => readdly, odten => odten)
    port map (rst_ahb, clkddri, clk_ahb, ahbsi, ahbso, sdi, sdo);
  end generate;

  ddr64 : if ddrbits = 64 generate
    ddrc : ddr2sp64a generic map (memtech => memtech, hindex => hindex,
      haddr => haddr, hmask => hmask, ioaddr => ioaddr, iomask => iomask,
      pwron => pwron, MHz => DDR_FREQ, TRFC => TRFC, col => col, Mbyte => Mbyte,
      fast => FAST_AHB/4, readdly => readdly, odten => odten)
    port map (rst_ahb, clkddri, clk_ahb, ahbsi, ahbso, sdi, sdo);
  end generate;
end;
