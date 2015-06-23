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
-- Entity:      atahost_dma_fifo
-- File:        atahost_dma_fifo.vhd
-- Author:      Erik Jagre - Gaisler Research
-- Description: Generic FIFO, based on syncram in grlib
-----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_arith.all;
library techmap;
use techmap.gencomp.all;

entity atahost_dma_fifo is 
  generic(tech  : integer:=0;  abits : integer:=3;
          dbits : integer:=32; depth : integer:=8); 
  port( clk          : in std_logic; 
        reset        : in std_logic; 
        write_enable : in std_logic; 
        read_enable  : in std_logic; 
        data_in      : in std_logic_vector(dbits-1 downto 0);
        data_out     : out std_logic_vector(dbits-1 downto 0);
        write_error  : out std_logic:='0'; 
        read_error   : out std_logic:='0'; 
        level        : out natural range 0 to depth; 
        empty        : out std_logic:='1'; 
        full         : out std_logic:='0'); 
end;

architecture rtl of atahost_dma_fifo is
type state_type is (full_state, empty_state, idle_state);
type reg_type is record
  state      : state_type;
  level      : integer range 0 to depth;
  aw         : integer range 0 to depth;
  ar         : integer range 0 to depth;
  data_o     : std_logic_vector(dbits-1 downto 0);
  rd         : std_logic; 
  wr         : std_logic;
  erd        : std_logic; 
  ewr        : std_logic;
  reset      : std_logic;
  adr        : std_logic_vector(abits-1 downto 0);
end record;

constant RESET_VECTOR : reg_type := (empty_state,0,0,0,
  conv_std_logic_vector(0,dbits),'0','0','0','0','0',(others=>'0'));

signal r,ri : reg_type;
signal s_ram_adr : std_logic_vector(abits-1 downto 0);

begin
--  comb:process(write_enable, read_enable, data_in,reset, r) Erik 2007-02-08
  comb:process(write_enable, read_enable, reset, r)
  variable v : reg_type;
  variable vfull, vempty : std_logic;

  begin
    v:=r;
    v.wr:=write_enable; v.rd:=read_enable; v.reset:=reset;

    case r.state is
      when full_state=>
        if write_enable='1' and read_enable='0' and reset='0' then
          v.ewr:='1'; v.state:=full_state;
        elsif write_enable='0' and read_enable='1' and reset='0' then
          v.adr:=conv_std_logic_vector(r.ar,abits);
          if r.ar=depth-1 then v.ar:=0; else v.ar:=r.ar+1; end if;
          v.level:=r.level-1;
          if r.aw=v.ar then v.state:=empty_state;
          else v.state:=idle_state; end if;
          v.ewr:='0';
        end if;

      when empty_state=>
        if write_enable='1' and read_enable='0' and reset='0' then
          v.adr:=conv_std_logic_vector(r.aw,abits);
          if r.aw=depth-1 then v.aw:=0; else v.aw:=r.aw+1; end if;
          v.level:=r.level+1;
          if v.aw=r.ar then v.state:=full_state;
          else v.state:=idle_state; end if;
          v.erd:='0';
        elsif write_enable='0' and read_enable='1' and reset='0' then
          v.erd:='1'; v.state:=empty_state;
        end if;

      when idle_state=>
        if write_enable='1' and read_enable='0' and reset='0' then
          v.adr:=conv_std_logic_vector(r.aw,abits);
          if r.aw=depth-1 then v.aw:=0; else v.aw:=r.aw+1; end if;
          v.level:=r.level+1;
          if v.level=depth then v.state:=full_state;
          else v.state:=idle_state; end if;
        elsif write_enable='0' and read_enable='1' and reset='0' then
          v.adr:=conv_std_logic_vector(r.ar,abits);
          if r.ar=depth-1 then v.ar:=0; else v.ar:=r.ar+1; end if;
          v.level:=r.level-1;
          if v.level=0 then v.state:=empty_state;
          else v.state:=idle_state; end if;
        end if;
    end case;
  
    if r.level=0 then vempty:='1'; vfull:='0';
    elsif r.level=depth then vempty:='0'; vfull:='1';
    else vempty:='0'; vfull:='0'; end if;

    --reset logic
    if (reset='1') then v:=RESET_VECTOR; end if;

    ri<=v;
    s_ram_adr<=v.adr;

    --assigning outport
    write_error<=v.ewr; read_error<=v.erd; level<=v.level;
    empty<=vempty; full<=vfull;
  end process;
  
  ram : syncram
  generic map(tech=>tech, abits=>abits, dbits=>dbits)
  port map (
    clk     => clk,
    address => s_ram_adr,
    datain  => data_in,
    dataout => data_out,
    enable  => read_enable,
    write   => write_enable
  );

  sync:process(clk)     --Activate on clock & reset
  begin
    if clk'event and clk='1' then r<=ri; end if;
  end process;
end;