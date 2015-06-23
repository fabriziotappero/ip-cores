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
-- Entity:      ahbtbs
-- File:        ahbtbs.vhd
-- Author:      Nils-Johan Wessman - Gaisler Research
-- Description: AMBA testbench slave
------------------------------------------------------------------------------  
library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;
library techmap;
use techmap.gencomp.all;

library gaisler;
use gaisler.misc.all;

use work.ahbtbp.all;

entity ahbtbs is
  generic (
    hindex  : integer := 0;
    haddr   : integer := 0;
    hmask   : integer := 16#fff#;
    tech    : integer := DEFMEMTECH;
    kbytes  : integer := 1); 
  port (
    rst     : in  std_ulogic;
    clk     : in  std_ulogic;
    ahbsi   : in  ahb_slv_in_type;
    ahbso   : out ahb_slv_out_type
  );
end;

architecture rtl of ahbtbs is

constant abits : integer := log2(kbytes) + 8;
constant ws : std_logic_vector(7 downto 0) :="00000000";
constant retry : integer := 0;

constant hconfig : ahb_config_type := (
  0 => ahb_device_reg ( VENDOR_GAISLER, 0, 0, abits+2, 0),
  4 => ahb_membar(haddr, '1', '1', hmask),
  others => zero32);


type reg_type is record
  hwrite : std_ulogic;
  hready : std_ulogic;
  hsel   : std_ulogic;
  addr   : std_logic_vector(abits+1 downto 0);
  size   : std_logic_vector(1 downto 0);
  hresp  : std_logic_vector(1 downto 0);
  ws     : std_logic_vector(7 downto 0);
  rty    : std_logic_vector(3 downto 0);
  retry  : std_logic;
end record;

signal r, c : reg_type;
signal ramsel : std_ulogic;
signal write : std_logic_vector(3 downto 0);
signal ramaddr  : std_logic_vector(abits-1 downto 0);
signal ramdata  : std_logic_vector(31 downto 0);
begin

  comb : process (ahbsi, r, rst, ramdata)
  variable bs : std_logic_vector(3 downto 0);
  variable v : reg_type;
  variable haddr  : std_logic_vector(abits-1 downto 0);
  begin
    v := r; v.hready := '1'; bs := (others => '0');
    v.hresp := HRESP_OKAY;
    
    if ahbsi.hready = '1' then 
      v.hsel := ahbsi.hsel(hindex) and ahbsi.htrans(1);
      v.hwrite := ahbsi.hwrite and v.hsel;
      v.addr := ahbsi.haddr(abits+1 downto 0); 
      v.size := ahbsi.hsize(1 downto 0);
      v.ws := ws;
      --v.retry := retry;
      if retry = 1 then
        if v.hsel = '1' then
          v.rty := r.rty - 1;
          if r.rty = "0000" then
            v.retry := '0';
            v.rty := "0010";
          else
            v.retry := '1';
          end if;
        end if;
      else
          v.retry := '0';
      end if;
    end if;
    
    if r.ws /= "00000000" and r.hsel = '1' then
      v.ws := r.ws - 1;
    end if;

    if v.ws /= "00000000" and v.hsel = '1' then
      v.hready := '0';
    elsif v.hsel = '1' and v.retry = '1' then
      if r.hresp = HRESP_OKAY then
        v.hready := '0';
        v.hresp := HRESP_RETRY;
      else
        v.hready := '1';
        v.hresp := HRESP_RETRY;
        v.retry := '0';
      end if;
    end if;

    if (r.hwrite or not r.hready) = '1' then 
      haddr := r.addr(abits+1 downto 2);
    else
      haddr := ahbsi.haddr(abits+1 downto 2); bs := (others => '0'); 
    end if;


    if r.hwrite = '1' and r.hready = '1' then
      case r.size(1 downto 0) is
      when "00" => bs (conv_integer(r.addr(1 downto 0))) := '1';
      when "01" => bs := r.addr(1) & r.addr(1) & not (r.addr(1) & r.addr(1));
      when others => bs := (others => '1');
      end case;
      --v.hready := not (v.hsel and not ahbsi.hwrite);
      --v.hwrite := v.hwrite and v.hready;
    end if;

    if rst = '0' then 
      v.hwrite := '0'; v.hready := '1'; v.ws := ws; 
      v.rty := "0010";
    end if;
    write <= bs; ramsel <= v.hsel or r.hwrite; ahbso.hready <= r.hready; 
    ramaddr <= haddr; c <= v; ahbso.hrdata <= ramdata;

  end process;

  ahbso.hresp   <= r.hresp; --"00"; 
  ahbso.hsplit  <= (others => '0'); 
  ahbso.hirq    <= (others => '0');
  ahbso.hcache  <= '1';
  ahbso.hconfig <= hconfig;
  ahbso.hindex  <= hindex;

  ra : for i in 0 to 3 generate
    aram :  syncram generic map (tech, abits, 8) port map (
	clk, ramaddr, ahbsi.hwdata(i*8+7 downto i*8),
	ramdata(i*8+7 downto i*8), ramsel, write(3-i)); 
  end generate;

  reg : process (clk)
  begin
    if rising_edge(clk ) then r <= c; end if;
  end process;

-- pragma translate_off
    bootmsg : report_version 
    generic map ("ahbram" & tost(hindex) &
    ": AHB SRAM Module rev 1, " & tost(kbytes) & " kbytes");
-- pragma translate_on
end;
