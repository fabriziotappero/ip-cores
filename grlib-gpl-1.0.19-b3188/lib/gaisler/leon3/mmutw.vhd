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
-- Entity: 	mmutw
-- File:	mmutw.vhd
-- Author:	Konrad Eisele, Jiri Gaisler, Gaisler Research
-- Description:	MMU table-walk logic
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
library gaisler;
use gaisler.libiu.all;
use gaisler.libcache.all;
use gaisler.leon3.all;
use gaisler.mmuconfig.all;
use gaisler.mmuiface.all;

entity mmutw is
  port (
    rst     : in  std_logic;
    clk     : in  std_logic;
    mmctrl1 : in  mmctrl_type1;
    twi     : in  mmutw_in_type;
    two     : out mmutw_out_type;
    mcmmo   : in  memory_mm_out_type;
    mcmmi   : out memory_mm_in_type
    );
end mmutw;

architecture rtl of mmutw is

  type write_buffer_type is record			-- write buffer 
    addr, data  : std_logic_vector(31 downto 0);
    read        : std_logic;
  end record;

  type states is (idle, waitm, pte, lv1, lv2, lv3, lv4);
  type tw_rtype is record
    state       : states;
    wb          : write_buffer_type;
    req         : std_logic;
    walk_op     : std_logic;
    
    --#dump
    -- pragma translate_off
    finish      : std_logic;
    index       : std_logic_vector(31-2 downto 0);
    lvl         : std_logic_vector(1 downto 0);
    fault_mexc  : std_logic;
    fault_trans : std_logic;
    fault_lvl   : std_logic_vector(1 downto 0);
    pte,ptd,inv,rvd : std_logic;
    goon, found : std_logic;
    base        : std_logic_vector(31 downto 0);
    -- pragma translate_on
  end record;
  signal c,r : tw_rtype;
  
begin  

  p0: process (rst, r, c, twi, mcmmo, mmctrl1)
  variable v           : tw_rtype;
  variable finish      : std_logic;
  variable index       : std_logic_vector(31-2 downto 0);
  variable lvl         : std_logic_vector(1 downto 0);
  variable fault_mexc  : std_logic;
  variable fault_trans : std_logic;
  variable fault_inv   : std_logic;
  variable fault_lvl   : std_logic_vector(1 downto 0);
  variable pte,ptd,inv,rvd : std_logic;
  variable goon, found : std_logic;
  variable base        : std_logic_vector(31 downto 0);
  
  begin 
    v := r;
    
    --#init
    finish := '0'; 
    index := (others => '0');
    lvl := (others => '0');
    fault_mexc := '0';
    fault_trans := '0';
    fault_inv := '0';
    fault_lvl := (others => '0');
    pte := '0';ptd := '0';inv := '0';rvd := '0';
    goon := '0'; found := '0';
    base := (others => '0'); 
    base(PADDR_PTD_U downto PADDR_PTD_D) := mcmmo.data(PTD_PTP32_U downto PTD_PTP32_D);
 
    if mcmmo.grant = '1' then
      v.req := '0';
    end if;

    if mcmmo.retry = '1' then v.req := '1'; end if;
    
    -- # pte/ptd
    if ((mcmmo.ready and not r.req)= '1') then -- context
      case mcmmo.data(PT_ET_U downto PT_ET_D) is
        when ET_INV => inv := '1';
        when ET_PTD => ptd := '1'; goon := '1';
        when ET_PTE => pte := '1'; found := '1';
        when ET_RVD => rvd := '1'; null;
        when others => null;
      end case;
    end if;      
    fault_trans := (rvd);
    fault_inv := inv;
    
    -- # state machine
    case r.state is
      when idle =>
        if (twi.walk_op_ur) = '1' then
          v.walk_op := '1';
          index(M_CTX_SZ-1 downto 0) := mmctrl1.ctx;
          base := (others => '0');                              
          base(PADDR_PTD_U downto PADDR_PTD_D) := mmctrl1.ctxp(MMCTRL_PTP32_U downto MMCTRL_PTP32_D); 
          v.wb.addr := base or (index&"00");
          v.wb.read := '1';
          v.req := '1';
          v.state := lv1;
        elsif (twi.areq_ur) = '1' then
          index := (others => '0');
          v.wb.addr := twi.aaddr;
          v.wb.data := twi.adata;
          v.wb.read := '0';
          v.req := '1';
          v.state := waitm;
        end if;
      when waitm =>
        if ((mcmmo.ready and not r.req)= '1') then          -- amba: result ready current cycle
          fault_mexc := mcmmo.mexc;
          v.state := idle;
          finish := '1';
        end if;
      when lv1 =>                                               
                                                                
        if ((mcmmo.ready and not r.req)= '1') then          
          lvl := LVL_CTX; fault_lvl := FS_L_CTX;                
          index(VA_I1_SZ-1 downto 0) := twi.data(VA_I1_U downto VA_I1_D);       
          v.state := lv2;
        end if;
      when lv2 =>                                               
                                                                
        if ((mcmmo.ready and not r.req)= '1') then          
          lvl := LVL_REGION; fault_lvl :=  FS_L_L1;             
          index(VA_I2_SZ-1 downto 0) := twi.data(VA_I2_U downto VA_I2_D);       
          v.state := lv3;
        end if;
      when lv3 =>                                               
                                                                
        if ((mcmmo.ready and not r.req)= '1') then          
          lvl := LVL_SEGMENT; fault_lvl := FS_L_L2;             
          index(VA_I3_SZ-1 downto 0) := twi.data(VA_I3_U downto VA_I3_D);
          v.state := lv4;
        end if;
      when lv4 =>                                               
                                                                
        if ((mcmmo.ready and not r.req)= '1') then          
          lvl := LVL_PAGE; fault_lvl := FS_L_L3;                
          fault_trans := fault_trans or ptd;
          v.state := idle;
          finish := '1';                                          
        end if;
      when others =>
        v.state := idle;
        finish := '0';

    end case;
    base := base or (index&"00");

    if r.walk_op = '1' then
      if (mcmmo.ready and (not r.req)) = '1' then
        fault_mexc := mcmmo.mexc;
        if (( ptd and
              (not fault_mexc ) and
              (not fault_trans) and
              (not fault_inv  )) = '1') then -- tw  : break table walk?
          v.wb.addr := base;
          v.req := '1';
        else
          v.walk_op := '0';
          finish := '1';
          v.state := idle;
        end if;
      end if;
    end if;
        
    -- # reset
    if ( rst = '0' ) then
      v.state := idle;
      v.req := '0';
      v.walk_op := '0';
      v.wb.read := '0';
    end if;

    --# drive signals
    two.finish      <= finish;
    two.data        <= mcmmo.data;
    two.addr        <= r.wb.addr(31 downto 0);
    two.lvl         <= lvl;
    two.fault_mexc  <= fault_mexc;
    two.fault_trans <= fault_trans;
    two.fault_inv   <= fault_inv;
    two.fault_lvl   <= fault_lvl;
    
    mcmmi.address  <= r.wb.addr;
    mcmmi.data     <= r.wb.data;
    mcmmi.burst    <= '0';
    mcmmi.size     <= "10";
    mcmmi.read     <= r.wb.read;
    mcmmi.lock     <= '0';
    mcmmi.req      <= r.req;
    
    --#dump
    -- pragma translate_off
    v.finish := finish;
    v.index := index;
    v.lvl   := lvl;
    v.fault_mexc := fault_mexc;
    v.fault_trans := fault_trans;
    v.fault_lvl := fault_lvl;
    v.pte   := pte;
    v.ptd   := ptd;
    v.inv   := inv;
    v.rvd   := rvd;
    v.goon  := goon;
    v.found := found;
    v.base  := base;
    -- pragma translate_on

    c <= v;
  end process p0;

  p1: process (clk)
  begin if rising_edge(clk) then r <= c; end if;
  end process p1;
    
end rtl;
