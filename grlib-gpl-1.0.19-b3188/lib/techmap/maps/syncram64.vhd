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
-- Entity: 	syncram64
-- File:	syncram64.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	64-bit syncronous 1-port ram with 32-bit write strobes
--		and tech selection
------------------------------------------------------------------------------

library ieee;
library techmap;
use ieee.std_logic_1164.all;
use techmap.gencomp.all;
  
entity syncram64 is
  generic (tech : integer := 0; abits : integer := 6);
  port (
    clk     : in  std_ulogic;
    address : in  std_logic_vector (abits -1 downto 0);
    datain  : in  std_logic_vector (63 downto 0);
    dataout : out std_logic_vector (63 downto 0);
    enable  : in  std_logic_vector (1 downto 0);
    write   : in  std_logic_vector (1 downto 0);
    testin  : in  std_logic_vector (3 downto 0) := "0000");
end;

architecture rtl of syncram64 is
  component virtex2_syncram64
  generic ( abits : integer := 9);
  port (
    clk     : in  std_ulogic;
    address : in  std_logic_vector (abits -1 downto 0);
    datain  : in  std_logic_vector (63 downto 0);
    dataout : out std_logic_vector (63 downto 0);
    enable  : in  std_logic_vector (1 downto 0);
    write   : in  std_logic_vector (1 downto 0)
  );
  end component;

  component artisan_syncram64
  generic ( abits : integer := 9);
  port (
    clk     : in  std_ulogic;
    address : in  std_logic_vector (abits -1 downto 0);
    datain  : in  std_logic_vector (63 downto 0);
    dataout : out std_logic_vector (63 downto 0);
    enable  : in  std_logic_vector (1 downto 0);
    write   : in  std_logic_vector (1 downto 0)
  );
  end component;

  component custom1_syncram64
  generic ( abits : integer := 9);
  port (
    clk     : in  std_ulogic;
    address : in  std_logic_vector (abits -1 downto 0);
    datain  : in  std_logic_vector (63 downto 0);
    dataout : out std_logic_vector (63 downto 0);
    enable  : in  std_logic_vector (1 downto 0);
    write   : in  std_logic_vector (1 downto 0)
  );
  end component;

begin

  s64 : if has_sram64(tech) = 1 generate
    xc2v : if (tech = virtex2) or (tech = spartan3) or (tech = virtex4) 
	or (tech = spartan3e) or (tech = virtex5) 
    generate 
      x0 : virtex2_syncram64 generic map (abits)
         port map (clk, address, datain, dataout, enable, write);
    end generate;
    arti : if tech = memartisan generate
      x0 : artisan_syncram64 generic map (abits)
         port map (clk, address, datain, dataout, enable, write);
    end generate;
    cust1: if tech = custom1 generate
      x0 : custom1_syncram64 generic map (abits)
         port map (clk, address, datain, dataout, enable, write);
    end generate;
  end generate;

  nos64 : if has_sram64(tech) = 0 generate
    x0 : syncram generic map (tech, abits, 32)
         port map (clk, address, datain(63 downto 32), dataout(63 downto 32), 
	           enable(1), write(1), testin);
    x1 : syncram generic map (tech, abits, 32)
         port map (clk, address, datain(31 downto 0), dataout(31 downto 0), 
	           enable(0), write(0), testin);
  end generate;

end;

