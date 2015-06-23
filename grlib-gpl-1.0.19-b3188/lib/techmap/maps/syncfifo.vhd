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
-- Entity: 	syncfifo
-- File:	syncfifo.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	syncronous fifo using syncram_2p
------------------------------------------------------------------------------

library ieee;
library techmap;
use ieee.std_logic_1164.all;
use techmap.gencomp.all;
library grlib;
use grlib.stdlib.all;

entity syncfifo is
  generic (tech : integer := 0; abits : integer := 6; dbits : integer := 8;
	sepclk : integer := 0; wrfst : integer := 0);
  port (
    rst      : in std_ulogic;
    rclk     : in std_ulogic;
    renable  : in std_ulogic;
    dataout  : out std_logic_vector((dbits -1) downto 0);
    wclk     : in std_ulogic;
    write    : in std_ulogic;
    datain   : in std_logic_vector((dbits -1) downto 0);
    full     : out std_ulogic;
    empty    : out std_ulogic
  );
end;

architecture rtl of syncfifo is

type reg_type is record
  raddr, waddr : std_logic_vector(abits downto 0);
  full, empty, notempty : std_ulogic;
end record;

signal r, rin : reg_type;
begin

  comb : process (rst, write, renable, r)
  variable v : reg_type;
  begin

    v := r;

    if renable = '1' then v.raddr := r.raddr + 1; end if;
    if write = '1' then v.waddr := r.waddr + 1; end if;

    if (v.raddr(abits-1) = v.waddr(abits-1)) then
      if (v.raddr(abits) = v.waddr(abits)) then 
	v.full := '0'; v.empty := '1';
      else v.full := '1'; v.empty := '0'; end if;
    else v.full := '0'; v.empty := '0'; end if;

    if rst = '0' then
      v.raddr := (others => '0'); v.waddr := (others => '0');
      v.full := '0'; v.empty := '1';
    end if;
    rin <= v;
  end process;

  full <= r.full; empty <= r.empty;

  regs : process (rclk)
  begin
    if rising_edge(rclk) then
      r <= rin;
    end if;
  end process;

  x0 : syncram_2p generic map (tech, abits, dbits, sepclk)
       port map (rclk, renable, r.raddr(abits-1 downto 0), dataout, 
	         wclk, write, r.waddr(abits-1 downto 0), datain);

end;

