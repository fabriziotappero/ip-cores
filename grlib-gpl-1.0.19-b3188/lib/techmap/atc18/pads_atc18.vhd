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
-- Package: 	atcpads_gen
-- File:	atcpads_gen.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	Atmel ATC18 pad wrappers
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
package atcpads is
  -- input pad
  component pc33d00z port (pad : in std_logic; cin : out std_logic); end component; 
  -- input pad with pull-up
  component pc33d00uz port (pad : in std_logic; cin : out std_logic); end component; 
  -- schmitt input pad
  component pc33d20z port (pad : in std_logic; cin : out std_logic); end component; 
  -- schmitt input pad with pull-up
  component pt33d20uz port (pad : inout std_logic; cin : out std_logic); end component; 
  -- output pads
  component pt33o01z port (i : in std_logic; pad : out std_logic); end component; 
  component pt33o02z port (i : in std_logic; pad : out std_logic); end component; 
  component pt33o04z port (i : in std_logic; pad : out std_logic); end component; 
  component pt33o08z port (i : in std_logic; pad : out std_logic); end component; 
  -- tri-state output pads
  component pt33t01z port (i, oen : in std_logic; pad : out std_logic); end component; 
  component pt33t02z port (i, oen : in std_logic; pad : out std_logic); end component; 
  component pt33t04z port (i, oen : in std_logic; pad : out std_logic); end component; 
  component pt33t08z port (i, oen : in std_logic; pad : out std_logic); end component; 
  -- tri-state output pads with pull-up
  component pt33t01uz port (i, oen : in std_logic; pad : out std_logic); end component; 
  component pt33t02uz port (i, oen : in std_logic; pad : out std_logic); end component; 
  component pt33t04uz port (i, oen : in std_logic; pad : out std_logic); end component; 
  component pt33t08uz port (i, oen : in std_logic; pad : out std_logic); end component; 
  -- bidirectional pads
  component pt33b01z
    port (i, oen : in std_logic; cin : out std_logic; pad : inout std_logic);
  end component; 
  component pt33b02z
    port (i, oen : in std_logic; cin : out std_logic; pad : inout std_logic);
  end component; 
  component pt33b08z
    port (i, oen : in std_logic; cin : out std_logic; pad : inout std_logic);
  end component; 
  component pt33b04z
    port (i, oen : in std_logic; cin : out std_logic; pad : inout std_logic);
  end component; 
  -- bidirectional pads with pull-up
  component pt33b01uz
    port (i, oen : in std_logic; cin : out std_logic; pad : inout std_logic);
  end component; 
  component pt33b02uz
    port (i, oen : in std_logic; cin : out std_logic; pad : inout std_logic);
  end component; 
  component pt33b08uz
    port (i, oen : in std_logic; cin : out std_logic; pad : inout std_logic);
  end component; 
  component pt33b04uz
    port (i, oen : in std_logic; cin : out std_logic; pad : inout std_logic);
  end component; 
--PCI pads
  component pp33o01z 
    port (i : in  std_logic; pad : out  std_logic);
  end component; 
  component pp33b01z 
    port ( i, oen : in std_logic; cin : out std_logic; pad : inout std_logic);
  end component; 
  component pp33t01z 
    port (i, oen : in  std_logic; pad : out  std_logic);
  end component;
end;

library ieee;
library techmap;
use ieee.std_logic_1164.all;
use techmap.gencomp.all;
-- pragma translate_off
library atc18;
use atc18.pc33d00z;
-- pragma translate_on

entity atc18_inpad is
  generic (level : integer := 0; voltage : integer := 0);
  port (pad : in std_logic; o : out std_logic);
end; 
architecture rtl of atc18_inpad is
  component pc33d00z port (pad : in std_logic; cin : out std_logic); end component; 
begin
  pci0 : if level = pci33 generate
    ip : pc33d00z port map (pad => pad, cin => o);
  end generate;
  gen0 : if level /= pci33 generate
    ip : pc33d00z port map (pad => pad, cin => o);
  end generate;
end;

library ieee;
use ieee.std_logic_1164.all;
library techmap;
use techmap.gencomp.all;
-- pragma translate_off
library atc18;
use atc18.pp33b01z;
use atc18.pt33b01z;
use atc18.pt33b02z;
use atc18.pt33b08z;
use atc18.pt33b04z;
-- pragma translate_on

entity atc18_iopad  is
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : inout std_logic; i, en : in std_logic; o : out std_logic);
end ;
architecture rtl of atc18_iopad is
  component pp33b01z 
    port ( i, oen : in std_logic; cin : out std_logic; pad : inout std_logic);
  end component; 
  component pt33b01z
    port (i, oen : in std_logic; cin : out std_logic; pad : inout std_logic);
  end component; 
  component pt33b02z
    port (i, oen : in std_logic; cin : out std_logic; pad : inout std_logic);
  end component; 
  component pt33b08z
    port (i, oen : in std_logic; cin : out std_logic; pad : inout std_logic);
  end component; 
  component pt33b04z
    port (i, oen : in std_logic; cin : out std_logic; pad : inout std_logic);
  end component; 

begin
  pci0 : if level = pci33 generate
    op : pp33b01z port map (i => i, oen => en, pad => pad, cin => o);
  end generate;
  gen0 : if level /= pci33 generate
    f1 : if (strength <= 4)  generate
      op : pt33b01z port map (i => i, oen => en, pad => pad, cin => o);
    end generate;
    f2 : if (strength > 4)  and (strength <= 8)  generate
      op : pt33b02z port map (i => i, oen => en, pad => pad, cin => o);
    end generate;
    f3 : if (strength > 8)  and (strength <= 16)  generate
      op : pt33b04z port map (i => i, oen => en, pad => pad, cin => o);
    end generate;
    f4 : if (strength > 16)  generate
      op : pt33b08z port map (i => i, oen => en, pad => pad, cin => o);
    end generate;
  end generate;
end;

library ieee;
use ieee.std_logic_1164.all;
library techmap;
use techmap.gencomp.all;
-- pragma translate_off
library atc18;
use atc18.pp33t01z;
use atc18.pt33o01z;
use atc18.pt33o02z;
use atc18.pt33o04z;
use atc18.pt33o08z;
-- pragma translate_on

entity atc18_outpad  is
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : out std_logic; i : in std_logic);
end ;
architecture rtl of atc18_outpad is
  component pp33t01z 
    port (i, oen : in  std_logic; pad : out  std_logic);
  end component;
  component pt33o01z port (i : in std_logic; pad : out std_logic); end component; 
  component pt33o02z port (i : in std_logic; pad : out std_logic); end component; 
  component pt33o04z port (i : in std_logic; pad : out std_logic); end component; 
  component pt33o08z port (i : in std_logic; pad : out std_logic); end component; 
signal gnd : std_logic;
begin

  gnd <= '0';

  pci0 : if level = pci33 generate
    op : pp33t01z port map (i => i, oen => gnd, pad => pad);
  end generate;
  gen0 : if level /= pci33 generate
    f4 : if (strength <= 4)  generate
      op : pt33o01z port map (i => i, pad => pad);
    end generate;
    f8  : if (strength > 4) and (strength <= 8)  generate
      op : pt33o02z port map (i => i, pad => pad);
    end generate;
    f16 : if (strength > 8) and (strength <= 16)  generate
      op : pt33o04z port map (i => i, pad => pad);
    end generate;
    f32 : if (strength > 16) generate
      op : pt33o08z port map (i => i, pad => pad);
    end generate;
  end generate;
end;

library ieee;
use ieee.std_logic_1164.all;
library techmap;
use techmap.gencomp.all;
-- pragma translate_off
library atc18;
use atc18.pp33t01z;
use atc18.pt33t01z;
use atc18.pt33t02z;
use atc18.pt33t04z;
use atc18.pt33t08z;
-- pragma translate_on

entity atc18_toutpad  is
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 0);
  port (pad : out std_logic; i, en : in std_logic);
end ;
architecture rtl of atc18_toutpad is
  component pp33t01z 
    port (i, oen : in  std_logic; pad : out  std_logic);
  end component;
  component pt33t01z port (i, oen : in std_logic; pad : out std_logic); end component; 
  component pt33t02z port (i, oen : in std_logic; pad : out std_logic); end component; 
  component pt33t04z port (i, oen : in std_logic; pad : out std_logic); end component; 
  component pt33t08z port (i, oen : in std_logic; pad : out std_logic); end component; 
begin

  pci0 : if level = pci33 generate
    op : pp33t01z port map (i => i, oen => en, pad => pad);
  end generate;
  gen0 : if level /= pci33 generate
    f4 : if (strength <= 4)  generate
      op : pt33t01z port map (i => i, oen => en, pad => pad);
    end generate;
    f8  : if (strength > 4) and (strength <= 8)  generate
      op : pt33t02z port map (i => i, oen => en, pad => pad);
    end generate;
    f16 : if (strength > 8) and (strength <= 16)  generate
      op : pt33t04z port map (i => i, oen => en, pad => pad);
    end generate;
    f32 : if (strength > 16) generate
      op : pt33t08z port map (i => i, oen => en, pad => pad);
    end generate;
  end generate;

end;

library ieee;
use ieee.std_logic_1164.all;

entity atc18_clkpad is
  generic (level : integer := 0; voltage : integer := 0);
  port (pad : in std_logic; o : out std_logic);
end; 
architecture rtl of atc18_clkpad is
begin
  o <= pad;
end;
