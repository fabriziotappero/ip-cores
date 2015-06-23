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
-- Entity: 	ddr_phy
-- File:	ddr_phy.vhd
-- Author:	Jiri Gaisler, Gaisler Research
-- Description:	DDR1 PHY for Altera, Virtex-2, Virtex-4, Spartan-3e
--		DDR2 PHY for Virtex-5
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library grlib;
use grlib.stdlib.all;
library techmap;
use techmap.gencomp.all;
library gaisler;
use gaisler.memctrl.all;

------------------------------------------------------------------
-- DDR1 PHY -------------------------------------------------------
------------------------------------------------------------------

entity ddr_phy is
  generic (tech : integer := virtex2; MHz : integer := 100; 
	rstdelay : integer := 200; dbits : integer := 16; 
	clk_mul : integer := 2 ; clk_div : integer := 2;
	rskew : integer :=0; mobile : integer := 0);
  port (
    rst       : in  std_ulogic;
    clk       : in  std_logic;          	-- input clock
    clkout    : out std_ulogic;			-- system clock
    clkread   : out std_ulogic;			-- read clock
    lock      : out std_ulogic;			-- DCM locked

    ddr_clk 	: out std_logic_vector(2 downto 0);
    ddr_clkb	: out std_logic_vector(2 downto 0);
    ddr_clk_fb_out  : out std_logic;
    ddr_clk_fb  : in std_logic;
    ddr_cke  	: out std_logic_vector(1 downto 0);
    ddr_csb  	: out std_logic_vector(1 downto 0);
    ddr_web  	: out std_ulogic;                       -- ddr write enable
    ddr_rasb  	: out std_ulogic;                       -- ddr ras
    ddr_casb  	: out std_ulogic;                       -- ddr cas
    ddr_dm   	: out std_logic_vector (dbits/8-1 downto 0);    -- ddr dm
    ddr_dqs  	: inout std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
    ddr_ad      : out std_logic_vector (13 downto 0);   -- ddr address
    ddr_ba      : out std_logic_vector (1 downto 0);    -- ddr bank address
    ddr_dq    	: inout  std_logic_vector (dbits-1 downto 0); -- ddr data
 
    sdi         : out sdctrl_in_type;
    sdo         : in  sdctrl_out_type);
end;

architecture rtl of ddr_phy is

begin

    ddr_phy0 : ddrphy 
     generic map (tech => tech, MHz => MHz, rstdelay => rstdelay
-- reduce 200 us start-up delay during simulation
-- pragma translate_off
	/ 200
-- pragma translate_on
	, dbits => dbits, clk_mul => clk_mul, clk_div => clk_div, 
	rskew => rskew, mobile => mobile)
     port map (
	rst, clk, clkout, clkread, lock,
	ddr_clk, ddr_clkb, ddr_clk_fb_out, ddr_clk_fb,
	ddr_cke, ddr_csb, ddr_web, ddr_rasb, ddr_casb, 
	ddr_dm, ddr_dqs, ddr_ad, ddr_ba, ddr_dq,
	sdo.address(15 downto 2), sdo.ba,
	sdi.data(dbits*2-1 downto 0), sdo.data(dbits*2-1 downto 0), 
	sdo.dqm(dbits/4-1 downto 0), sdo.bdrive, sdo.bdrive, sdo.qdrive, 
	sdo.rasn, sdo.casn, sdo.sdwen, sdo.sdcsn, sdo.sdcke, sdo.sdck, sdo.moben);

end;

library ieee;
use ieee.std_logic_1164.all;

library grlib;
use grlib.stdlib.all;
library techmap;
use techmap.gencomp.all;
library gaisler;
use gaisler.memctrl.all;

------------------------------------------------------------------
-- DDR2 PHY -------------------------------------------------------
------------------------------------------------------------------

entity ddr2_phy is
  generic (tech     : integer := virtex2; MHz      : integer := 100; 
	rstdelay    : integer := 200;     dbits    : integer := 16; 
	clk_mul     : integer := 2 ;      clk_div  : integer := 2;
	ddelayb0    : integer := 0;       ddelayb1 : integer := 0; ddelayb2 : integer := 0;
	ddelayb3    : integer := 0;       ddelayb4 : integer := 0; ddelayb5 : integer := 0;
	ddelayb6    : integer := 0;       ddelayb7 : integer := 0;
        numidelctrl : integer := 4;       norefclk : integer := 0; odten    : integer := 0;
        rskew       : integer := 0);
  port (
    rst            : in    std_ulogic;
    clk            : in    std_logic;   -- input clock
    clkref200      : in    std_logic;   -- input 200MHz clock
    clkout         : out   std_ulogic;  -- system clock
    lock           : out   std_ulogic;  -- DCM locked

    ddr_clk        : out   std_logic_vector(2 downto 0);
    ddr_clkb       : out   std_logic_vector(2 downto 0);
    ddr_clk_fb_out : out   std_logic;
    ddr_clk_fb     : in    std_logic;
    ddr_cke        : out   std_logic_vector(1 downto 0);
    ddr_csb        : out   std_logic_vector(1 downto 0);
    ddr_web        : out   std_ulogic;  -- ddr write enable
    ddr_rasb       : out   std_ulogic;  -- ddr ras
    ddr_casb       : out   std_ulogic;  -- ddr cas
    ddr_dm         : out   std_logic_vector (dbits/8-1 downto 0);  -- ddr dm
    ddr_dqs        : inout std_logic_vector (dbits/8-1 downto 0);  -- ddr dqs
    ddr_dqsn       : inout std_logic_vector (dbits/8-1 downto 0);  -- ddr dqs
    ddr_ad         : out   std_logic_vector (13 downto 0);         -- ddr address
    ddr_ba         : out   std_logic_vector (1 downto 0);          -- ddr bank address
    ddr_dq         : inout std_logic_vector (dbits-1 downto 0);    -- ddr data
    ddr_odt        : out   std_logic_vector(1 downto 0);

    sdi            : out   sdctrl_in_type;
    sdo            : in    sdctrl_out_type
    );
end;

architecture rtl of ddr2_phy is

begin

    ddr_phy0 : ddr2phy 
     generic map (tech => tech, MHz => MHz, rstdelay => rstdelay
-- reduce 200 us start-up delay during simulation
-- pragma translate_off
	/ 200
-- pragma translate_on
	, dbits => dbits, clk_mul => clk_mul, clk_div => clk_div, 
	ddelayb0 => ddelayb0, ddelayb1 => ddelayb1, ddelayb2 => ddelayb2,
	ddelayb3 => ddelayb3, ddelayb4 => ddelayb4, ddelayb5 => ddelayb5,
	ddelayb6 => ddelayb6, ddelayb7 => ddelayb7,
        numidelctrl => numidelctrl, norefclk => norefclk, rskew => rskew)
     port map (
	rst, clk, clkref200, clkout, lock,
	ddr_clk, ddr_clkb, ddr_clk_fb_out, ddr_clk_fb,
	ddr_cke, ddr_csb, ddr_web, ddr_rasb, ddr_casb, 
	ddr_dm, ddr_dqs, ddr_dqsn, ddr_ad, ddr_ba, ddr_dq, ddr_odt,
	sdo.address(15 downto 2), sdo.ba,
	sdi.data(dbits*2-1 downto 0), sdo.data(dbits*2-1 downto 0), 
	sdo.dqm(dbits/4-1 downto 0), sdo.bdrive, sdo.bdrive, sdo.qdrive, 
	sdo.rasn, sdo.casn, sdo.sdwen, sdo.sdcsn, sdo.sdcke, 
	sdo.cal_en(dbits/8-1 downto 0), sdo.cal_inc(dbits/8-1 downto 0), 
        sdo.cal_pll, sdo.cal_rst, sdo.odt 
        );
end;

