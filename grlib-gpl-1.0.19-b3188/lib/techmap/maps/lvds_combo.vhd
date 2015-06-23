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
-- Entity: 	lvds_combo.vhd
-- File:	lvds_combo.vhd.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	Differential input/output pads with IREF/OREF logic wrapper
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library techmap;
use techmap.gencomp.all;
use techmap.allpads.all;

entity lvds_combo  is
  generic (tech : integer := 0; voltage : integer := 0; width : integer := 1;
		oepol : integer := 0);
  port (odpadp, odpadn, ospadp, ospadn : out std_logic_vector(0 to width-1); 
        odval, osval, en : in std_logic_vector(0 to width-1); 
	idpadp, idpadn, ispadp, ispadn : in std_logic_vector(0 to width-1);
	idval, isval : out std_logic_vector(0 to width-1);
	lvdsref : in std_logic := '1'
);
end ;

architecture rtl of lvds_combo is
signal gnd : std_ulogic;
signal oen : std_logic_vector(0 to width-1);
constant level : integer := lvds;
begin
  gnd <= '0';
  gen0 : if has_ds_combo(tech) = 0 generate
    swloop : for i in 0 to width-1 generate
      od0 : outpad_ds generic map (tech, level, voltage, oepol) port map (odpadp(i), odpadn(i), odval(i), en(i));
      os0 : outpad_ds generic map (tech, level, voltage, oepol) port map (ospadp(i), ospadn(i), osval(i), en(i));
      id0 : inpad_ds generic map (tech, level, voltage) port map (idpadp(i), idpadn(i), idval(i));
      is0 : inpad_ds generic map (tech, level, voltage) port map (ispadp(i), ispadn(i), isval(i));
    end generate;
  end generate;
  combo : if has_ds_combo(tech) /= 0 generate
    oen <= not en when oepol /= padoen_polarity(tech) else en;
    ut025 : if tech = ut25 generate
      u0: ut025crh_lvds_combo generic map (voltage, width)
        port map (odpadp, odpadn, ospadp, ospadn, odval, osval, oen, 
		  idpadp, idpadn, ispadp, ispadn, idval, isval);
    end generate;
    um : if tech = umc generate
      u0: umc_lvds_combo generic map (voltage, width)
        port map (odpadp, odpadn, ospadp, ospadn, odval, osval, oen, 
		  idpadp, idpadn, ispadp, ispadn, idval, isval, lvdsref);
    end generate;
    rhu : if tech = rhumc generate
      u0: rhumc_lvds_combo generic map (voltage, width)
        port map (odpadp, odpadn, ospadp, ospadn, odval, osval, oen, 
		  idpadp, idpadn, ispadp, ispadn, idval, isval, lvdsref);
    end generate;
  end generate;
end;
