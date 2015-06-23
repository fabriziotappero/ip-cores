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
-- Entity: 	Various
-- File:	atmel_simprims.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	ATMEL ATC18 behavioural models
--		Modelled after IO33/PCILIB data sheets
------------------------------------------------------------------------------

-- pragma translate_off
-- input pad

library ieee;
use ieee.std_logic_1164.all;

entity pc33d00z is port (pad : in std_logic; cin : out std_logic); end; 
architecture rtl of pc33d00z is begin cin <= to_x01(pad) after 1 ns; end;

-- input pad with pull-up

library ieee;
use ieee.std_logic_1164.all;

entity pc33d00uz is port (pad : inout std_logic; cin : out std_logic); end; 
architecture rtl of pc33d00uz is 
begin cin <= to_x01(pad) after 1 ns; pad <= 'H'; end;

-- input schmitt pad

library ieee;
use ieee.std_logic_1164.all;

entity pc33d20z is port (pad : in std_logic; cin : out std_logic); end; 
architecture rtl of pc33d20z is begin cin <= to_x01(pad) after 1 ns; end;

-- input schmitt pad with pull-up

library ieee;
use ieee.std_logic_1164.all;

entity pc33d20uz is port (pad : inout std_logic; cin : out std_logic); end; 
architecture rtl of pc33d20uz is 
begin cin <= to_x01(pad) after 1 ns; pad <= 'H'; end;

-- output pads

library ieee; use ieee.std_logic_1164.all;

entity pt33o01z is port (i : in  std_logic; pad : out  std_logic); end; 
architecture rtl of pt33o01z is begin pad <= to_x01(i) after 2 ns; end;

library ieee; use ieee.std_logic_1164.all;

entity pt33o02z is port (i : in  std_logic; pad : out  std_logic); end; 
architecture rtl of pt33o02z is begin pad <= to_x01(i) after 2 ns; end;

library ieee; use ieee.std_logic_1164.all;

entity pt33o04z is port (i : in  std_logic; pad : out  std_logic); end; 
architecture rtl of pt33o04z is begin pad <= to_x01(i) after 2 ns; end;

library ieee; use ieee.std_logic_1164.all;

entity pt33o08z is port (i : in  std_logic; pad : out  std_logic); end; 
architecture rtl of pt33o08z is begin pad <= to_x01(i) after 2 ns; end;

-- output tri-state pads

library ieee; use ieee.std_logic_1164.all;

entity pt33t01z is port (i, oen : in  std_logic; pad : out  std_logic); end; 
architecture rtl of pt33t01z is
begin pad <= to_x01(i) after 2 ns when oen = '0' else 'H' after 2 ns; end; 

library ieee; use ieee.std_logic_1164.all;

entity pt33t02z is port (i, oen : in  std_logic; pad : out  std_logic); end; 
architecture rtl of pt33t02z is
begin pad <= to_x01(i) after 2 ns when oen = '0' else 'H' after 2 ns; end; 

library ieee; use ieee.std_logic_1164.all;

entity pt33t04z is port (i, oen : in  std_logic; pad : out  std_logic); end; 
architecture rtl of pt33t04z is
begin pad <= to_x01(i) after 2 ns when oen = '0' else 'H' after 2 ns; end; 

library ieee; use ieee.std_logic_1164.all;

entity pt33t08z is port (i, oen : in  std_logic; pad : out  std_logic); end; 
architecture rtl of pt33t08z is
begin pad <= to_x01(i) after 2 ns when oen = '0' else 'H' after 2 ns; end; 

-- output tri-state pads with pull-up

library ieee; use ieee.std_logic_1164.all;

entity pt33t01uz is port (i, oen : in  std_logic; pad : out  std_logic); end; 
architecture rtl of pt33t01uz is
begin pad <= to_x01(i) after 2 ns when oen = '0' else 'H' after 2 ns; end; 

library ieee; use ieee.std_logic_1164.all;

entity pt33t02uz is port (i, oen : in  std_logic; pad : out  std_logic); end; 
architecture rtl of pt33t02uz is
begin pad <= to_x01(i) after 2 ns when oen = '0' else 'H' after 2 ns; end; 

library ieee; use ieee.std_logic_1164.all;

entity pt33t04uz is port (i, oen : in  std_logic; pad : out  std_logic); end; 
architecture rtl of pt33t04uz is
begin pad <= to_x01(i) after 2 ns when oen = '0' else 'H' after 2 ns; end; 

-- bidirectional pad

library ieee; use ieee.std_logic_1164.all;

entity pt33b01z is
  port ( i, oen : in std_logic; cin : out std_logic; pad : inout std_logic);
end; 
architecture rtl of pt33b01z is
begin 
  pad <= to_x01(i) after 2 ns when oen = '0' else 'Z' after 2 ns;
  cin <= to_x01(pad) after 1 ns;
end;

library ieee; use ieee.std_logic_1164.all;
entity pt33b02z is
  port ( i, oen : in std_logic; cin : out std_logic; pad : inout std_logic);
end; 
architecture rtl of pt33b02z is
begin 
  pad <= to_x01(i) after 2 ns when oen = '0' else 'Z' after 2 ns;
  cin <= to_x01(pad) after 1 ns;
end;

library ieee; use ieee.std_logic_1164.all;

entity pt33b08z is
  port ( i, oen : in std_logic; cin : out std_logic; pad : inout std_logic);
end; 
architecture rtl of pt33b08z is
begin 
  pad <= to_x01(i) after 2 ns when oen = '0' else 'Z' after 2 ns;
  cin <= to_x01(pad) after 1 ns;
end;

library ieee; use ieee.std_logic_1164.all;

entity pt33b04z is
  port ( i, oen : in std_logic; cin : out std_logic; pad : inout std_logic);
end; 
architecture rtl of pt33b04z is
begin 
  pad <= to_x01(i) after 2 ns when oen = '0' else 'Z' after 2 ns;
  cin <= to_x01(pad) after 1 ns;
end;

-- bidirectional pads with pull-up

library ieee;
use ieee.std_logic_1164.all;

entity pt33b01uz is
  port ( i, oen : in std_logic; cin : out std_logic; pad : inout std_logic);
end; 

architecture rtl of pt33b01uz is
begin 
  pad <= to_x01(i) after 2 ns when oen = '0' else 'H' after 2 ns;
  cin <= to_x01(pad) after 1 ns;
end;

library ieee;
use ieee.std_logic_1164.all;

entity pt33b02uz is
  port ( i, oen : in std_logic; cin : out std_logic; pad : inout std_logic);
end; 
architecture rtl of pt33b02uz is
begin 
  pad <= to_x01(i) after 2 ns when oen = '0' else 'H' after 2 ns;
  cin <= to_x01(pad) after 1 ns;
end;

library ieee;
use ieee.std_logic_1164.all;

entity pt33b08uz is
  port ( i, oen : in std_logic; cin : out std_logic; pad : inout std_logic);
end; 
architecture rtl of pt33b08uz is
begin 
  pad <= to_x01(i) after 2 ns when oen = '0' else 'H' after 2 ns;
  cin <= to_x01(pad) after 1 ns;
end;

library ieee;
use ieee.std_logic_1164.all;

entity pt33b04uz is
  port ( i, oen : in std_logic; cin : out std_logic; pad : inout std_logic);
end; 
architecture rtl of pt33b04uz is
begin 
  pad <= to_x01(i) after 2 ns when oen = '0' else 'H' after 2 ns;
  cin <= to_x01(pad) after 1 ns;
end;

-- PCI output pad

library ieee; use ieee.std_logic_1164.all;
entity pp33o01z is port (i : in  std_logic; pad : out  std_logic); end; 
architecture rtl of pp33o01z is begin pad <= to_x01(i) after 2 ns; end;

-- PCI bidirectional pad

library ieee; use ieee.std_logic_1164.all;
entity pp33b01z is
  port ( i, oen : in std_logic; cin : out std_logic; pad : inout std_logic);
end; 
architecture rtl of pp33b01z is
begin 
  pad <= to_x01(i) after 2 ns when oen = '0' else 'Z' after 2 ns;
  cin <= to_x01(pad) after 1 ns;
end;

-- PCI output tri-state pad

library ieee; use ieee.std_logic_1164.all;
entity pp33t01z is port (i, oen : in  std_logic; pad : out  std_logic); end; 
architecture rtl of pp33t01z is
begin pad <= to_x01(i) after 2 ns when oen = '0' else 'Z' after 2 ns; end; 
-- pragma translate_on
