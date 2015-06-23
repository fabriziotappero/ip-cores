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
-- Entity:      dcom
-- File:        dcom.vhd
-- Author:      Jiri Gaisler - Gaisler Research
-- Description: DSU Communications module
------------------------------------------------------------------------------  

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
library gaisler;
use gaisler.misc.all;
use gaisler.libdcom.all;

entity dcom is
   port (
      rst    : in  std_ulogic;
      clk    : in  std_ulogic;
      dmai   : out ahb_dma_in_type;
      dmao   : in  ahb_dma_out_type;
      uarti  : out dcom_uart_in_type;
      uarto  : in  dcom_uart_out_type;
      ahbi   : in  ahb_mst_in_type
      );
end;      

architecture struct of dcom is

type dcom_state_type is (idle, addr1, read1, read2, write1, write2);

type reg_type is record
  addr    : std_logic_vector(31 downto 0);
  data    : std_logic_vector(31 downto 0);
  len     : std_logic_vector(5 downto 0);
  write   : std_ulogic;
  clen    : std_logic_vector(1 downto 0);
  state   : dcom_state_type;
  hresp   : std_logic_vector(1 downto 0);
end record;

signal r, rin : reg_type;

begin

  comb : process(dmao, rst, uarto, ahbi, r)
  variable v : reg_type;
  variable enable : std_ulogic;
  variable newlen : std_logic_vector(5 downto 0);
  variable vuarti : dcom_uart_in_type;
  variable vdmai : ahb_dma_in_type;
  variable newaddr : std_logic_vector(31 downto 2);

  begin

    v := r;
    vuarti.read := '0'; vuarti.write := '0'; vuarti.data := r.data(31 downto 24);
    vdmai.start := '0'; vdmai.burst := '0'; vdmai.size := "10"; vdmai.busy := '0';
    vdmai.address := r.addr; vdmai.wdata := r.data;
    vdmai.write := r.write; vdmai.irq := '0';

    -- save hresp
    if dmao.ready = '1' then v.hresp := ahbi.hresp; end if;

    -- address incrementer
    newlen := r.len - 1;
    newaddr := r.addr(31 downto 2) + 1;

    case r.state is
    when idle =>		-- idle state
      v.clen := "00";
      if uarto.dready = '1' then
        if uarto.data(7) = '1' then v.state := addr1; end if;
	v.write := uarto.data(6); v.len := uarto.data(5 downto 0);  
	vuarti.read := '1';
      end if;
    when addr1 =>		-- receive address
      if uarto.dready = '1' then
	v.addr := r.addr(23 downto 0) & uarto.data;  
	vuarti.read := '1'; v.clen := r.clen + 1;
      end if;
      if (r.clen(1) and not v.clen(1)) = '1' then
	if r.write = '1' then v.state := write1; else v.state := read1; end if;
      end if;
    when read1 =>		-- read AHB
      if dmao.active = '1' then
	if dmao.ready = '1' then
	  v.data := dmao.rdata; v.state := read2;
        end if;
      else vdmai.start := '1'; end if;
      v.clen := "00";
    when read2 =>		-- send read-data on uart
      if uarto.thempty = '1' then
	v.data := r.data(23 downto 0) & uarto.data;  
	vuarti.write := '1'; v.clen := r.clen + 1; 
        if (r.clen(1) and not v.clen(1)) = '1' then
	  v.addr(31 downto 2) := newaddr; v.len := newlen;
          if (v.len(5) and not r.len(5)) = '1' then v.state := idle; 
	  else v.state := read1; end if;
        end if;
      end if;
    when write1 =>		-- receive write-data
      if uarto.dready = '1' then
	v.data := r.data(23 downto 0) & uarto.data;  
	vuarti.read := '1'; v.clen := r.clen + 1;
      end if;
      if (r.clen(1) and not v.clen(1)) = '1' then v.state := write2; end if;
    when write2 =>		-- write AHB
      if dmao.active = '1' then
	if dmao.ready = '1' then 
	  v.addr(31 downto 2) := newaddr; v.len := newlen;
          if (v.len(5) and not r.len(5)) = '1' then v.state := idle; 
	  else v.state := write1; end if;
        end if;
      else vdmai.start := '1'; end if;
      v.clen := "00";
    end case;

    if (uarto.lock and rst) = '0' then
      v.state := idle; v.write := '0';
    end if;

    rin <= v; dmai <= vdmai; uarti <= vuarti;

  end process;

  regs : process(clk)
  begin if rising_edge(clk) then r <= rin; end if; end process;

end;
