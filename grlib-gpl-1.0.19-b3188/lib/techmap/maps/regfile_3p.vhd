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
-- Entity: 	regfile_3p
-- File:	regfile_3p.vhd
-- Author:	Jiri Gaisler Gaisler Research
-- Description:	3-port regfile implemented with two 2-port rams
------------------------------------------------------------------------------

library ieee;
library techmap;
use ieee.std_logic_1164.all;
use techmap.gencomp.all;
use techmap.allmem.all;

entity regfile_3p is
  generic (tech : integer := 0; abits : integer := 6; dbits : integer := 8;
           wrfst : integer := 0; numregs : integer := 64);
  port (
    wclk   : in  std_ulogic;
    waddr  : in  std_logic_vector((abits -1) downto 0);
    wdata  : in  std_logic_vector((dbits -1) downto 0);
    we     : in  std_ulogic;
    rclk   : in  std_ulogic;
    raddr1 : in  std_logic_vector((abits -1) downto 0);
    re1    : in  std_ulogic;
    rdata1 : out std_logic_vector((dbits -1) downto 0);
    raddr2 : in  std_logic_vector((abits -1) downto 0);
    re2    : in  std_ulogic;
    rdata2 : out std_logic_vector((dbits -1) downto 0);
    testin   : in std_logic_vector(3 downto 0) := "0000");
end;

architecture rtl of regfile_3p is
  constant rfinfer : boolean := (regfile_3p_infer(tech) = 1) or
	(((tech = spartan3) or (tech = spartan3e) or (tech = virtex2) or (tech = virtex4) or (tech = virtex5)) and (abits <= 5));
begin
  
  s0 : if rfinfer generate
   rhu : generic_regfile_3p generic map (tech, abits, dbits, wrfst, numregs)
   port map ( wclk, waddr, wdata, we, rclk, raddr1, re1, rdata1, raddr2, re2, rdata2);
  end generate;

  s1 : if not rfinfer generate
    pere : if tech = peregrine generate
      rfhard : peregrine_regfile_3p generic map (abits, dbits)
      port map ( wclk, waddr, wdata, we, raddr1, re1, rdata1, raddr2, re2, rdata2);
    end generate;
    dp : if tech /= peregrine generate
      x0 : syncram_2p generic map (tech, abits, dbits, 0, wrfst)
        port map (rclk, re1, raddr1, rdata1, wclk, we, waddr, wdata, testin);
      x1 : syncram_2p generic map (tech, abits, dbits, 0, wrfst)
        port map (rclk, re2, raddr2, rdata2, wclk, we, waddr, wdata, testin);
    end generate;
  end generate;

end;

