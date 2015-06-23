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
-- Package: 	pad_actel_gen
-- File:	pad_actel_gen.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	Actel pads wrappers
------------------------------------------------------------------------------

-- pragma translate_off
library axcelerator;
use axcelerator.inbuf;
use axcelerator.inbuf_pci;
-- pragma translate_on
library ieee;
use ieee.std_logic_1164.all;
library techmap;
use techmap.gencomp.all;

entity axcel_inpad is
  generic (level : integer := 0; voltage : integer := 0);
  port (pad : in std_ulogic; o : out std_ulogic);
end; 
architecture rtl of axcel_inpad is
  component inbuf port(pad :in std_logic; y : out std_logic); end component;
  component inbuf_pci port(pad :in std_logic; y : out std_logic); end component;
  attribute syn_tpd11 : string; 
  attribute syn_tpd11 of inbuf_pci : component is "pad -> y = 2.0";
begin
  pci0 : if level = pci33 generate
    ip : inbuf_pci port map (pad => pad, y => o);
  end generate;
  gen0 : if level /= pci33 generate
    ip : inbuf port map (pad => pad, y => o);
  end generate;
end;

-- pragma translate_off
library axcelerator;
use axcelerator.bibuf;
use axcelerator.bibuf_pci;
-- pragma translate_on
library ieee;
use ieee.std_logic_1164.all;
library techmap;
use techmap.gencomp.all;

entity axcel_iopad  is
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : inout std_ulogic; i, en : in std_ulogic; o : out std_ulogic);
end ;
architecture rtl of axcel_iopad is
  component bibuf port( 
    d, e : in  std_logic; pad : inout std_logic; y : out std_logic);
  end component;
  component bibuf_pci port( 
    d, e : in  std_logic; pad : inout std_logic; y : out std_logic);
  end component;
  attribute syn_tpd12 : string; 
  attribute syn_tpd12 of bibuf_pci : component is "pad -> y = 2.0";
begin
  pci0 : if level = pci33 generate
    op : bibuf_pci port map (d => i, e => en, pad => pad, y => o);
  end generate;
  gen0 : if level /= pci33 generate
    op : bibuf port map (d => i, e => en, pad => pad, y => o);
  end generate;
end;

-- pragma translate_off
library axcelerator;
use axcelerator.bibuf;
use axcelerator.bibuf_pci;
-- pragma translate_on
library ieee;
use ieee.std_logic_1164.all;
library techmap;
use techmap.gencomp.all;

entity axcel_iodpad  is
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : inout std_ulogic; i, en : in std_ulogic; o : out std_ulogic);
end ;
architecture rtl of axcel_iodpad is
  component bibuf port( 
    d, e : in  std_logic; pad : inout std_logic; y : out std_logic);
  end component;
  component bibuf_pci port( 
    d, e : in  std_logic; pad : inout std_logic; y : out std_logic);
  end component;
  attribute syn_tpd12 : string; 
  attribute syn_tpd12 of bibuf_pci : component is "pad -> y = 2.0";
signal gnd : std_ulogic;
begin
  gnd <= '0';
  pci0 : if level = pci33 generate
    op : bibuf_pci port map (d => gnd, e => en, pad => pad, y => o);
  end generate;
  gen0 : if level /= pci33 generate
    op : bibuf port map (d => gnd, e => en, pad => pad, y => o);
  end generate;
end;

-- pragma translate_off
library axcelerator;
use axcelerator.outbuf;
use axcelerator.outbuf_f_8;
use axcelerator.outbuf_f_12;
use axcelerator.outbuf_f_16;
use axcelerator.outbuf_f_24;
use axcelerator.outbuf_pci;
-- pragma translate_on
library ieee;
use ieee.std_logic_1164.all;
library techmap;
use techmap.gencomp.all;

entity axcel_outpad  is
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : out std_ulogic; i : in std_ulogic);
end ;
architecture rtl of axcel_outpad is
  component outbuf port(d : in std_logic; pad : out std_logic); end component;
  component outbuf_f_8 port(d : in std_logic; pad : out std_logic); end component;
  component outbuf_f_12 port(d : in std_logic; pad : out std_logic); end component;
  component outbuf_f_16 port(d : in std_logic; pad : out std_logic); end component;
  component outbuf_f_24 port(d : in std_logic; pad : out std_logic); end component;
  component outbuf_pci port(d : in std_logic; pad : out std_logic); end component;
  attribute syn_tpd13 : string; 
  attribute syn_tpd13 of outbuf_pci : component is "d -> pad = 2.0";
begin
  pci0 : if level = pci33 generate
    op : outbuf_pci port map (d => i, pad => pad);
  end generate;
  gen0 : if level /= pci33 generate
    x0 : if slew = 0 generate
      op : outbuf port map (d => i, pad => pad);
    end generate;
    x1 : if slew = 1 generate
      f0 : if (strength = 0)  generate
        op : outbuf port map (d => i, pad => pad);
      end generate;
      f8  : if (strength > 0) and (strength <= 8)  generate
        op : outbuf_f_8 port map (d => i, pad => pad);
      end generate;
      f12 : if (strength > 8) and (strength <= 12)  generate
        op : outbuf_f_12 port map (d => i, pad => pad);
      end generate;
      f16 : if (strength > 12) and (strength <= 16)  generate
        op : outbuf_f_16 port map (d => i, pad => pad);
      end generate;
      f24 : if (strength > 16) generate
        op : outbuf_f_24 port map (d => i, pad => pad);
      end generate;
    end generate;
  end generate;
end;

-- pragma translate_off
library axcelerator;
use axcelerator.tribuff;
use axcelerator.tribuff_pci;
-- pragma translate_on
library ieee;
use ieee.std_logic_1164.all;
library techmap;
use techmap.gencomp.all;

entity axcel_odpad  is
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : out std_ulogic; i : in std_ulogic);
end ;
architecture rtl of axcel_odpad is
  component tribuff port(d, e : in std_logic; pad : out std_logic); end component;
  component tribuff_pci port(d, e : in std_logic; pad : out std_logic); end component;
  attribute syn_tpd14 : string; 
  attribute syn_tpd14 of tribuff_pci : component is "d,e -> pad = 2.0";
signal gnd : std_ulogic;
begin
  gnd <= '0';
  pci0 : if level = pci33 generate
    op : tribuff_pci port map (d => gnd, e => i, pad => pad);
  end generate;
  gen0 : if level /= pci33 generate
    op : tribuff port map (d => gnd, e => i, pad => pad);
  end generate;
end;

-- pragma translate_off
library axcelerator;
use axcelerator.tribuff;
use axcelerator.tribuff_pci;
-- pragma translate_on
library ieee;
use ieee.std_logic_1164.all;
library techmap;
use techmap.gencomp.all;

entity axcel_toutpad  is
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : out std_ulogic; i, en : in std_ulogic);
end ;
architecture rtl of axcel_toutpad is
  component tribuff port(d, e : in std_logic; pad : out std_logic); end component;
  component tribuff_pci port(d, e : in std_logic; pad : out std_logic); end component;
  attribute syn_tpd14 : string; 
  attribute syn_tpd14 of tribuff_pci : component is "d,e -> pad = 2.0";
begin
  pci0 : if level = pci33 generate
    op : tribuff_pci port map (d => i, e => en, pad => pad);
  end generate;
  gen0 : if level /= pci33 generate
    op : tribuff port map (d => i, e => en, pad => pad);
  end generate;
end;

-- pragma translate_off
library axcelerator;
use axcelerator.hclkbuf;
use axcelerator.hclkbuf_pci;
-- pragma translate_on
library ieee;
use ieee.std_logic_1164.all;
library techmap;
use techmap.gencomp.all;

entity axcel_clkpad is
  generic (level : integer := 0; voltage : integer := 0);
  port (pad : in std_ulogic; o : out std_ulogic);
end; 
architecture rtl of axcel_clkpad is
  component hclkbuf
  port( pad : in  std_logic; y   : out std_logic); end component; 
  component hclkbuf_pci
  port( pad : in  std_logic; y   : out std_logic); end component; 
begin
  pci0 : if level = pci33 generate
    cp : hclkbuf_pci port map (pad => pad, y => o);
  end generate;
  gen0 : if level /= pci33 generate
    cp : hclkbuf port map (pad => pad, y => o);
  end generate;
end;

-- pragma translate_off
library axcelerator;
use axcelerator.inbuf_lvds;
-- pragma translate_on
library ieee;
use ieee.std_logic_1164.all;
library techmap;
use techmap.gencomp.all;

entity axcel_inpad_ds is
  generic (level : integer := lvds; voltage : integer := x33v);
  port (padp, padn : in std_ulogic; o : out std_ulogic);
end;
architecture rtl of axcel_inpad_ds is 
  component inbuf_lvds port(Y : out std_logic; PADP : in std_logic; PADN : in std_logic); end component;
begin
 u0: inbuf_lvds port map (y => o, padp => padp, padn => padn);
end; 

-- pragma translate_off
library axcelerator;
use axcelerator.outbuf_lvds;
-- pragma translate_on
library ieee;
use ieee.std_logic_1164.all;
library techmap;
use techmap.gencomp.all;

entity axcel_outpad_ds is
  generic (level : integer := lvds; voltage : integer := x33v);
  port (padp, padn : out std_ulogic; i : in std_ulogic);
end;
architecture rtl of axcel_outpad_ds is 
  component outbuf_lvds port(D : in std_logic; PADP : out std_logic; PADN : out std_logic); end component;
begin
  u0 : outbuf_lvds port map (d => i, padp => padp, padn => padn);
end;
