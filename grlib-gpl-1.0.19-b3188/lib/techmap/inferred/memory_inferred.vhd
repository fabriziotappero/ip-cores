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
-- Entity: 	various
-- File:	mem_gen_gen.vhd
-- Author:	Jiri Gaisler Gaisler Research
-- Description:	Behavioural memory generators
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.stdlib.all;

entity generic_syncram is
  generic ( abits : integer := 10; dbits : integer := 8 );
  port (
    clk      : in std_ulogic;
    address  : in std_logic_vector((abits -1) downto 0);
    datain   : in std_logic_vector((dbits -1) downto 0);
    dataout  : out std_logic_vector((dbits -1) downto 0);
    write    : in std_ulogic
  ); 
end;     

architecture behavioral of generic_syncram is

  type mem is array(0 to (2**abits -1)) 
	of std_logic_vector((dbits -1) downto 0);
  signal memarr : mem;
  signal ra  : std_logic_vector((abits -1) downto 0);

begin

  main : process(clk)
  begin
    if rising_edge(clk) then
      if write = '1' then
        memarr(conv_integer(address)) <= datain;
      end if;
      ra <= address;
    end if;
  end process;

  dataout <= memarr(conv_integer(ra));

end;

-- synchronous 2-port ram, common clock

LIBRARY ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.stdlib.all;

entity generic_syncram_2p is
  generic (
    abits : integer := 8;
    dbits : integer := 32;
    sepclk: integer := 0
  );
  port (
    rclk : in std_ulogic;
    wclk : in std_ulogic;
    rdaddress: in std_logic_vector (abits -1 downto 0);
    wraddress: in std_logic_vector (abits -1 downto 0);
    data: in std_logic_vector (dbits -1 downto 0);
    wren : in std_ulogic;
    q: out std_logic_vector (dbits -1 downto 0)
  );
end;

architecture behav of generic_syncram_2p is
  type dregtype is array (0 to 2**abits - 1) 
	of std_logic_vector(dbits -1 downto 0);
  signal rfd : dregtype;
  signal wa, ra : std_logic_vector (abits -1 downto 0);
begin

  wp : process(wclk)
  begin
    if rising_edge(wclk) then
      if wren = '1' then rfd(conv_integer(wraddress)) <= data; end if;
    end if;
  end process;

  oneclk : if sepclk = 0 generate
    rp : process(wclk) begin
    if rising_edge(wclk) then ra <= rdaddress; end if;
    end process;
  end generate;

  twoclk : if sepclk = 1 generate
    rp : process(rclk) begin
    if rising_edge(rclk) then ra <= rdaddress; end if;
    end process;
  end generate;

  q <= rfd(conv_integer(ra));

end;


library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.stdlib.all;

entity generic_regfile_3p is
  generic (tech : integer := 0; abits : integer := 6; dbits : integer := 32;
           wrfst : integer := 0; numregs : integer := 40);
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
    rdata2 : out std_logic_vector((dbits -1) downto 0)
  );
end;

architecture rtl of generic_regfile_3p is
  type mem is array(0 to numregs-1) 
	of std_logic_vector((dbits -1) downto 0);
  signal memarr : mem;
  signal ra1, ra2, wa  : std_logic_vector((abits -1) downto 0);
  signal din  : std_logic_vector((dbits -1) downto 0);
  signal wr  : std_ulogic;

begin

  main : process(wclk)
  begin
    if rising_edge(wclk) then
      din <= wdata; wr <= we; 
      if (we = '1')
-- pragma translate_off
	and (conv_integer(waddr) < numregs)
-- pragma translate_on
      then wa <= waddr; end if;
      if (re1 = '1') 
-- pragma translate_off
	and (conv_integer(raddr1) < numregs)
-- pragma translate_on
      then ra1 <= raddr1; end if;
      if (re2 = '1') 
-- pragma translate_off
	and (conv_integer(raddr2) < numregs)
-- pragma translate_on
      then ra2 <= raddr2; end if;
      if wr = '1' then
        memarr(conv_integer(wa)) <= din;
      end if;
    end if;
  end process;

  rdata1 <= din when (wr = '1') and (wa = ra1) and (wrfst = 1)
	else memarr(conv_integer(ra1));
  rdata2 <= din when (wr = '1') and (wa = ra2) and (wrfst = 1)
	else memarr(conv_integer(ra2));

end;

