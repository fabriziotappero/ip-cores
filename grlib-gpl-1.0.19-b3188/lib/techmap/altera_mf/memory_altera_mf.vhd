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
-- File:	mem_altera_gen.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	Memory generators for Altera altsynram
------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
-- pragma translate_off
library altera_mf;
use altera_mf.altsyncram;
-- pragma translate_on

entity altera_syncram_dp is
  generic ( 
    abits : integer := 4; dbits : integer := 32
  );
  port (
    clk1     : in std_ulogic;
    address1 : in std_logic_vector((abits -1) downto 0);
    datain1  : in std_logic_vector((dbits -1) downto 0);
    dataout1 : out std_logic_vector((dbits -1) downto 0);
    enable1  : in std_ulogic;
    write1   : in std_ulogic;
    clk2     : in std_ulogic;
    address2 : in std_logic_vector((abits -1) downto 0);
    datain2  : in std_logic_vector((dbits -1) downto 0);
    dataout2 : out std_logic_vector((dbits -1) downto 0);
    enable2  : in std_ulogic;
    write2   : in std_ulogic);
end;

architecture behav of altera_syncram_dp is

  component altsyncram
  generic (
    width_a	: natural;
    width_b	: natural := 1;
    widthad_a	: natural;
    widthad_b	: natural := 1);
  port(
    address_a	: in std_logic_vector(widthad_a-1 downto 0);
    address_b	: in std_logic_vector(widthad_b-1 downto 0);
    clock0	: in std_logic;
    clock1	: in std_logic;
    data_a	: in std_logic_vector(width_a-1 downto 0);
    data_b	: in std_logic_vector(width_b-1 downto 0);
    q_a		: out std_logic_vector(width_a-1 downto 0);
    q_b		: out std_logic_vector(width_b-1 downto 0);
    rden_b	: in std_logic;
    wren_a	: in std_logic;
    wren_b	: in std_logic
    );
end component;

begin

  u0 : altsyncram 
    generic map (
      WIDTH_A => dbits, WIDTHAD_A => abits,
      WIDTH_B => dbits, WIDTHAD_B => abits)
    port map ( 
      address_a => address1, address_b => address2, clock0 => clk1, 
      clock1 => clk2, data_a => datain1, data_b => datain2, 
      q_a => dataout1, q_b => dataout2, rden_b => enable2,
      wren_a => write1, wren_b => write2);
end;

library ieee;
use ieee.std_logic_1164.all;
library techmap;

entity altera_syncram is
  generic ( abits : integer := 9; dbits : integer := 32);
  port (
    clk     : in std_ulogic;
    address : in std_logic_vector (abits -1 downto 0);
    datain  : in std_logic_vector (dbits -1 downto 0);
    dataout : out std_logic_vector (dbits -1 downto 0);
    enable  : in std_ulogic;
    write   : in std_ulogic
  );
end;

architecture behav of altera_syncram is
component altera_syncram_dp
  generic ( abits : integer := 10; dbits : integer := 8 );
  port (
    clk1     : in std_ulogic;
    address1 : in std_logic_vector((abits -1) downto 0);
    datain1  : in std_logic_vector((dbits -1) downto 0);
    dataout1 : out std_logic_vector((dbits -1) downto 0);
    enable1  : in std_ulogic;
    write1   : in std_ulogic;
    clk2     : in std_ulogic;
    address2 : in std_logic_vector((abits -1) downto 0);
    datain2  : in std_logic_vector((dbits -1) downto 0);
    dataout2 : out std_logic_vector((dbits -1) downto 0);
    enable2  : in std_ulogic;
    write2   : in std_ulogic
   ); 
end component;

signal agnd : std_logic_vector(abits-1 downto 0);
signal dgnd : std_logic_vector(dbits-1 downto 0);
begin
  
 agnd <= (others => '0'); dgnd <= (others => '0');

 u0: altera_syncram_dp
  generic map (abits, dbits)
  port map (
    clk1 => clk, address1 => address, datain1 => datain,
    dataout1 => dataout, enable1 => enable, write1 => write,
    clk2 => clk, address2 => agnd, datain2 => dgnd,
    dataout2 => open, enable2 => agnd(0), write2 => agnd(0));
end;
