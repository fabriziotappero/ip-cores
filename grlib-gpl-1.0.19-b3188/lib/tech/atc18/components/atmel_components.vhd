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
-- Package: 	atmel_components
-- File:	atmel_components.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	ATMEL ATC18 component declarations
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package atc18_components is

  -- input pad

  component pc33d00 port (pad : in std_logic; cin : out std_logic); end component; 

  -- input pad with pull-up

  component pc33d00u port (pad : in std_logic; cin : out std_logic); end component; 

  -- schmitt input pad

  component pc33d20 port (pad : in std_logic; cin : out std_logic); end component; 

  -- schmitt input pad with pull-up

  component pt33d20u port (pad : inout std_logic; cin : out std_logic); end component; 

  -- output pads

  component pt33o01 port (i : in std_logic; pad : out std_logic); end component; 
  component pt33o02 port (i : in std_logic; pad : out std_logic); end component; 
  component pt33o03 port (i : in std_logic; pad : out std_logic); end component; 
  component pt33o04 port (i : in std_logic; pad : out std_logic); end component; 

  -- tri-state output pads

  component pt33t01 port (i, oen : in std_logic; pad : out std_logic); end component; 
  component pt33t02 port (i, oen : in std_logic; pad : out std_logic); end component; 
  component pt33t03 port (i, oen : in std_logic; pad : out std_logic); end component; 
  component pt33t04 port (i, oen : in std_logic; pad : out std_logic); end component; 

  -- tri-state output pads with pull-up

  component pt33t01u port (i, oen : in std_logic; pad : out std_logic); end component; 
  component pt33t02u port (i, oen : in std_logic; pad : out std_logic); end component; 
  component pt33t03u port (i, oen : in std_logic; pad : out std_logic); end component; 
  component pt33t04u port (i, oen : in std_logic; pad : out std_logic); end component; 

  -- bidirectional pads

  component pt33b01
    port (i, oen : in std_logic; cin : out std_logic; pad : inout std_logic);
  end component; 
  component pt33b02
    port (i, oen : in std_logic; cin : out std_logic; pad : inout std_logic);
  end component; 
  component pt33b03
    port (i, oen : in std_logic; cin : out std_logic; pad : inout std_logic);
  end component; 
  component pt33b04
    port (i, oen : in std_logic; cin : out std_logic; pad : inout std_logic);
  end component; 

  -- bidirectional pads with pull-up

  component pt33b01u
    port (i, oen : in std_logic; cin : out std_logic; pad : inout std_logic);
  end component; 
  component pt33b02u
    port (i, oen : in std_logic; cin : out std_logic; pad : inout std_logic);
  end component; 
  component pt33b03u
    port (i, oen : in std_logic; cin : out std_logic; pad : inout std_logic);
  end component; 
  component pt33b04u
    port (i, oen : in std_logic; cin : out std_logic; pad : inout std_logic);
  end component; 

--PCI pads

  component pp33o01 
    port (i : in  std_logic; pad : out  std_logic);
  end component; 
  component pp33b015vt 
    port ( i, oen : in std_logic; cin : out std_logic; pad : inout std_logic);
  end component; 
  component pp33t015vt 
    port (i, oen : in  std_logic; pad : out  std_logic);
  end component;

end;

