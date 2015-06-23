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
-- Entity:      jtagcom
-- File:        jtagcom.vhd
-- Author:      Edvin Catovic - Gaisler Research
-- Description: JTAG Debug Interface with AHB master interface 
------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
library techmap;
use techmap.gencomp.all;
library gaisler;
use gaisler.libjtagcom.all;
use gaisler.misc.all;

entity jtagcom is
  generic (
    isel   : integer range 0 to 1 := 0;
    nsync  : integer range 1 to 2 := 2;
    ainst  : integer range 0 to 255 := 2;
    dinst  : integer range 0 to 255 := 3);
  port (
    rst  : in std_ulogic;
    clk  : in std_ulogic;
    tapo : in tap_out_type;
    tapi : out tap_in_type;
    dmao : in  ahb_dma_out_type;    
    dmai : out ahb_dma_in_type
    );
end;


architecture rtl of jtagcom is

  constant ADDBITS : integer := 10;
  constant NOCMP : boolean := (isel /= 0);

  
  type state_type is (shft, ahb);  
  
  type reg_type is record
    addr  : std_logic_vector(34 downto 0);
    data  : std_logic_vector(32 downto 0);
    state : state_type;
    tck   : std_logic_vector(nsync-1 downto 0);
    tck2  : std_ulogic;    
    trst  : std_logic_vector(nsync-1 downto 0);
    tdi   : std_logic_vector(nsync-1 downto 0);
    shift : std_logic_vector(nsync-1 downto 0);
    shift2: std_ulogic;
    shift3: std_ulogic;    
    asel  : std_logic_vector(nsync-1 downto 0);
    dsel  : std_logic_vector(nsync-1 downto 0);
    tdi2  : std_ulogic;
  end record;

  signal r, rin : reg_type;
  
begin  

  comb : process (rst, r, tapo, dmao)
    variable v : reg_type;
    variable redge  : std_ulogic;
    variable vdmai : ahb_dma_in_type;
    variable asel, dsel : std_ulogic;
    variable vtapi : tap_in_type;
    variable write, seq : std_ulogic;
  begin

    v := r;

    if NOCMP then
      asel := tapo.asel; dsel := tapo.dsel;      
    else
      if tapo.inst = conv_std_logic_vector(ainst, 8) then asel := '1'; else asel := '0'; end if;
      if tapo.inst = conv_std_logic_vector(dinst, 8) then dsel := '1'; else dsel := '0'; end if;
    end if;
    write := r.addr(34); seq := r.data(32);
    
    v.tck(0) := r.tck(nsync-1); v.tck(nsync-1) := tapo.tck; v.tck2 := r.tck(0); v.shift2 := r.shift(0); v.shift3 := r.shift2;
    v.trst(0) := r.trst(nsync-1); v.trst(nsync-1) := tapo.reset;
    v.tdi(0) := r.tdi(nsync-1); v.tdi(nsync-1) := tapo.tdi;
    v.shift(0) := r.shift(nsync-1); v.shift(nsync-1) := tapo.shift;
    v.asel(0) := r.asel(nsync-1); v.asel(nsync-1) := asel;
    v.dsel(0) := r.dsel(nsync-1); v.dsel(nsync-1) := dsel;
    v.tdi2 := r.tdi(0);
    redge := not r.tck2 and r.tck(0);
    vdmai.address := r.addr(31 downto 0); vdmai.wdata := r.data(31 downto 0);
    vdmai.start := '0'; vdmai.burst := '0'; vdmai.write := write;
    vdmai.busy := '0'; vdmai.irq := '0'; vdmai.size := r.addr(33 downto 32);

    vtapi.en := r.asel(0) or r.dsel(0);
    if r.asel(0) = '1' then vtapi.tdo := r.addr(0); else vtapi.tdo := r.data(0); end if;
    
    case r.state is
      when shft =>
        if (r.asel(0) or r.dsel(0)) = '1' then
        if r.shift2 = '1' then
          if redge = '1' then
            if r.asel(0) = '1' then v.addr := r.tdi2 & r.addr(34 downto 1); end if;
            if r.dsel(0) = '1' then v.data := r.tdi2 & r.data(32 downto 1); end if;
          end if;        
        elsif r.shift3 = '1' then          
          if (r.asel(0) and not write) = '1' then v.state := ahb; end if;
          if (r.dsel(0) and (write or (not write and seq))) = '1' then -- data register
            v.state := ahb;
            if (seq and not write) = '1' then 
              v.addr(ADDBITS-1 downto 2) := r.addr(ADDBITS-1 downto 2) + 1;
            end if;
          end if;
          end if;
        end if;
        vdmai.size := "00";
      when ahb =>
        if dmao.active = '1' then
          if dmao.ready = '1' then
            v.data(31 downto 0) := dmao.rdata;
            v.state := shft;
            if (write and seq) = '1' then
              v.addr(ADDBITS-1 downto 2) := r.addr(ADDBITS-1 downto 2) + 1;
            end if;
          end if;
        else
          vdmai.start := '1';
        end if;
    end case;

    if (rst = '0') or (r.trst(0) = '1') then
      v.state := shft; v.addr(34) := '0'; v.data(32) := '0';
    end if;

    rin <= v; dmai <= vdmai; tapi <= vtapi;
    
    
  end process;

  reg : process (clk)
  begin
    if rising_edge(clk) then r <= rin; end if;
  end process;
  
  
end;  
