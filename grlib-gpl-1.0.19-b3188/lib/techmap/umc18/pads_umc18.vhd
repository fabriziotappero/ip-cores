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
-- Package: 	umcpads_gen
-- File:	umcpads_gen.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	UMC pad wrappers
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
package umcpads is
  -- input pad

  component ICMT3V port( A : in std_logic; Z : out std_logic); end component;

  -- input pad with pull-up

  component ICMT3VPU port( A : in std_logic; Z : out std_logic); end component;

  -- input pad with pull-down

  component ICMT3VPD port( A : in std_logic; Z : out std_logic); end component;

  -- schmitt input pad

  component ISTRT3V port( A : in std_logic; Z : out std_logic); end component;

  -- output pads

  component OCM3V4 port( Z : out std_logic; A : in std_logic); end component;
  component OCM3V12 port( Z : out std_logic; A : in std_logic); end component;
  component OCM3V24 port( Z : out std_logic; A : in std_logic); end component;


  -- tri-state output pads

  component OCMTR4 port( EN : in std_logic; A : in std_logic; Z : out std_logic); end component;
  component OCMTR12 port( EN : in std_logic; A : in std_logic; Z : out std_logic); end component;
  component OCMTR24 port( EN : in std_logic; A : in std_logic; Z : out std_logic); end component;

  -- bidirectional pads

  component BICM3V4 port( IO : inout std_logic; EN : in std_logic; A : in std_logic; Z : out std_logic); end component;
  component BICM3V12 port( IO : inout std_logic; EN : in std_logic; A : in std_logic; Z : out std_logic); end component;
  component BICM3V24 port( IO : inout std_logic; EN : in std_logic; A : in std_logic; Z : out std_logic); end component;

end;

library ieee;
use ieee.std_logic_1164.all;
library techmap;
use techmap.gencomp.all;
-- pragma translate_off
library umc18;
use umc18.ICMT3V;
use umc18.ICMT3VPU;
use umc18.ICMT3VPD;
use umc18.ISTRT3V;
-- pragma translate_on

entity umc_inpad is
  generic (level : integer := 0; voltage : integer := 0; filter : integer := 0);
  port (pad : in std_logic; o : out std_logic);
end; 
architecture rtl of umc_inpad is
  component ICMT3V port( A : in std_logic; Z : out std_logic); end component;
  component ICMT3VPU port( A : in std_logic; Z : out std_logic); end component;
  component ICMT3VPD port( A : in std_logic; Z : out std_logic); end component;
  component ISTRT3V port( A : in std_logic; Z : out std_logic); end component;
begin
  norm : if filter = 0 generate
    ip : ICMT3V port map (a => pad, z => o);
  end generate;
  pu : if filter = pullup generate
    ip : ICMT3VPU port map (a => pad, z => o);
  end generate;
  pd : if filter = pulldown generate
    ip : ICMT3VPD port map (a => pad, z => o);
  end generate;
  sch : if filter = schmitt generate
    ip : ISTRT3V port map (a => pad, z => o);
  end generate;
end;

library ieee;
use ieee.std_logic_1164.all;
library techmap;
use techmap.gencomp.all;
-- pragma translate_off
library umc18;
use umc18.BICM3V4;
use umc18.BICM3V12;
use umc18.BICM3V24;
-- pragma translate_on

entity umc_iopad  is
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : inout std_logic; i, en : in std_logic; o : out std_logic);
end ;
architecture rtl of umc_iopad is
  component BICM3V4 port( IO : inout std_logic; EN : in std_logic; A : in std_logic; Z : out std_logic); end component;
  component BICM3V12 port( IO : inout std_logic; EN : in std_logic; A : in std_logic; Z : out std_logic); end component;
  component BICM3V24 port( IO : inout std_logic; EN : in std_logic; A : in std_logic; Z : out std_logic); end component;
begin
  f4 : if (strength <= 4)  generate
      op : BICM3V4 port map (a => i, en => en, io => pad, z => o);
  end generate;
  f12 : if (strength > 4)  and (strength <= 12)  generate
      op : BICM3V12 port map (a => i, en => en, io => pad, z => o);
  end generate;
  f24 : if (strength > 16)  generate
      op : BICM3V24 port map (a => i, en => en, io => pad, z => o);
  end generate;
end;

library ieee;
use ieee.std_logic_1164.all;
library techmap;
use techmap.gencomp.all;
-- pragma translate_off
library umc18;
use umc18.OCM3V4;
use umc18.OCM3V12;
use umc18.OCM3V24;
-- pragma translate_on

entity umc_outpad  is
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : out std_logic; i : in std_logic);
end ;
architecture rtl of umc_outpad is
  component OCM3V4 port( Z : out std_logic; A : in std_logic); end component;
  component OCM3V12 port( Z : out std_logic; A : in std_logic); end component;
  component OCM3V24 port( Z : out std_logic; A : in std_logic); end component;
begin
  f4 : if (strength <= 4)  generate
      op : OCM3V4 port map (a => i, z => pad);
  end generate;
  f12 : if (strength > 4) and (strength <= 12)  generate
      op : OCM3V12 port map (a => i, z => pad);
  end generate;
  f24 : if (strength > 12) generate
      op : OCM3V24 port map (a => i, z => pad);
  end generate;
end;

library ieee;
use ieee.std_logic_1164.all;
library techmap;
use techmap.gencomp.all;
-- pragma translate_off
library umc18;
use umc18.OCMTR4;
use umc18.OCMTR12;
use umc18.OCMTR24;
-- pragma translate_on

entity umc_toutpad  is
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : out std_logic; i, en : in std_logic);
end ;
architecture rtl of umc_toutpad is
  component OCMTR4 port( EN : in std_logic; A : in std_logic; Z : out std_logic); end component;
  component OCMTR12 port( EN : in std_logic; A : in std_logic; Z : out std_logic); end component;
  component OCMTR24 port( EN : in std_logic; A : in std_logic; Z : out std_logic); end component;
begin
  f4 : if (strength <= 4)  generate
      op : OCMTR4 port map (a => i, en => en, z => pad);
  end generate;
  f12  : if (strength > 4) and (strength <= 12)  generate
      op : OCMTR12 port map (a => i, en => en, z => pad);
  end generate;
  f24 : if (strength > 12) generate
      op : OCMTR24 port map (a => i, en => en, z => pad);
  end generate;
end;

library umc18;
-- pragma translate_off
use umc18.LVDS_Driver;
use umc18.LVDS_Receiver;
use umc18.LVDS_Biasmodule;
-- pragma translate_on

library ieee;
use ieee.std_logic_1164.all;
library techmap;
use techmap.gencomp.all;

entity umc_lvds_combo  is
  generic (voltage : integer := 0; width : integer := 1);
  port (odpadp, odpadn, ospadp, ospadn : out std_logic_vector(0 to width-1); 
        odval, osval, en : in std_logic_vector(0 to width-1); 
	idpadp, idpadn, ispadp, ispadn : in std_logic_vector(0 to width-1);
	idval, isval : out std_logic_vector(0 to width-1);
	lvdsref : in std_logic);
end ;

architecture rtl of umc_lvds_combo is
  component LVDS_Driver port ( A, Vref, HI : in std_logic; Z, ZN : out std_logic); end component;
  component LVDS_Receiver port ( A, AN : in std_logic; Z : out std_logic); end component;
  component LVDS_Biasmodule port ( RefR : in std_logic; Vref, HI : out std_logic); end component;
  signal vref,  hi : std_logic; 
begin

  lvds_bias:  LVDS_Biasmodule port map (lvdsref, vref, hi); 
  swloop : for i in 0 to width-1 generate
    spw_rxd_pad : LVDS_Receiver port map (idpadp(i), idpadn(i), idval(i));
    spw_rxs_pad : LVDS_Receiver port map (ispadp(i), ispadn(i), isval(i));
    spw_txd_pad : LVDS_Driver port map (odval(i), vref, hi, odpadp(i), odpadn(i));
    spw_txs_pad : LVDS_Driver port map (osval(i), vref, hi, ospadp(i), ospadn(i));
  end generate;

end;

