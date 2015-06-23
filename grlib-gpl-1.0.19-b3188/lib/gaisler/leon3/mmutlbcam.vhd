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
-- Entity: 	mmutlbcam
-- File:	mmutlbcam.vhd
-- Author:	Konrad Eisele, Jiri Gaisler, Gaisler Research
-- Description:	MMU TLB logic
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

entity mmutlbcam is  
  generic ( 
    tlb_type  : integer range 0 to 3 := 1
  );
  port (
      rst     : in std_logic;
      clk     : in std_logic;
      tlbcami : in mmutlbcam_in_type;
      tlbcamo : out mmutlbcam_out_type
  );
end mmutlbcam;

architecture rtl of mmutlbcam is
  
  constant M_TLB_FASTWRITE : integer range 0 to 3 := conv_integer(conv_std_logic_vector(tlb_type,2) and conv_std_logic_vector(2,2));   -- fast writebuffer

  type tlbcam_rtype is record
    btag     : tlbcam_reg;
  end record;
  signal r,c : tlbcam_rtype;

begin  

  p0: process (rst, r, tlbcami)
  variable v : tlbcam_rtype;
  variable hm, hf                : std_logic;
  variable h_i1, h_i2, h_i3, h_c : std_logic;
  variable h_l2, h_l3            : std_logic;
  variable h_su_cnt              : std_logic;
  variable blvl                  : std_logic_vector(1 downto 0);
  variable bet                   : std_logic_vector(1 downto 0);
  variable bsu                   : std_logic;
  variable blvl_decode           : std_logic_vector(3 downto 0);
  variable bet_decode            : std_logic_vector(3 downto 0);
  variable ref, modified         : std_logic;
  variable tlbcamo_pteout        : std_logic_vector(31 downto 0);
  variable tlbcamo_LVL           : std_logic_vector(1 downto 0);
  variable tlbcamo_NEEDSYNC      : std_logic;
  variable tlbcamo_WBNEEDSYNC    : std_logic;
  begin

    v := r;
    --#init
    h_i1 := '0'; h_i2 := '0'; h_i3 := '0'; h_c := '0';
    hm := '0';
    hf := r.btag.VALID;
    
    blvl := r.btag.LVL;
    bet  := r.btag.ET;
    bsu  := r.btag.SU;
    bet_decode  := decode(bet);
    blvl_decode  := decode(blvl);
    ref := r.btag.R;
    modified := r.btag.M;

    tlbcamo_pteout := (others => '0');
    tlbcamo_lvl := (others => '0'); 
    
    -- prepare tag comparision
    if (r.btag.I1  = tlbcami.tagin.I1)  then h_i1 := '1';  else h_i1 := '0'; end if;
    if (r.btag.I2  = tlbcami.tagin.I2)  then h_i2 := '1';  else h_i2 := '0'; end if;
    if (r.btag.I3  = tlbcami.tagin.I3)  then h_i3 := '1';  else h_i3 := '0'; end if;
    if (r.btag.CTX = tlbcami.tagin.CTX) then h_c  := '1';  else h_c  := '0'; end if;
    
    -- #level 2 hit (segment)
    h_l2 := h_i1 and h_i2 ;
    -- #level 3 hit (page)
    h_l3 := h_i1 and h_i2 and h_i3;
    -- # context + su
    h_su_cnt := h_c or bsu;
    
    --# translation (match) op
    case blvl is
      when LVL_PAGE    => hm := h_l3 and h_c and r.btag.VALID;
      when LVL_SEGMENT => hm := h_l2 and h_c and r.btag.VALID;
      when LVL_REGION  => hm := h_i1 and h_c and r.btag.VALID;
      when LVL_CTX     => hm :=          h_c and r.btag.VALID;
      when others      => hm := 'X';
    end case;
    
    --# translation: update ref/mod bit
    tlbcamo_NEEDSYNC := '0';
    if (tlbcami.trans_op and hm  ) = '1' then
      v.btag.R := '1';
      v.btag.M := r.btag.M or tlbcami.tagin.M;
      tlbcamo_NEEDSYNC := (not r.btag.R) or (tlbcami.tagin.M and (not r.btag.M));  -- cam: ref/modified changed, write back synchronously
    end if;
    tlbcamo_WBNEEDSYNC := '0';
    if ( hm  ) = '1' then
      tlbcamo_WBNEEDSYNC := (not r.btag.R) or (tlbcami.tagin.M and (not r.btag.M));  -- cam: ref/modified changed, write back synchronously
    end if;
    
    --# flush operation
    -- tlbcam only stores PTEs, tlb does not store PTDs
    case tlbcami.tagin.TYP is                        
      when FPTY_PAGE =>                        -- page
        hf := hf and h_su_cnt and h_l3 and (blvl_decode(0));  -- only level 3 (page)
      when FPTY_SEGMENT =>                     -- segment
        hf := hf and h_su_cnt and h_l2 and (blvl_decode(0) or blvl_decode(1));  -- only level 2+3 (segment,page)
      when FPTY_REGION =>                      -- region
        hf := hf and h_su_cnt and h_i1 and (not blvl_decode(3));  -- only level 1+2+3 (region,segment,page)
      when FPTY_CTX =>                         -- context
        hf := hf and (h_c and (not bsu)); 
      when FPTY_N  =>                          -- entire
      when others =>
        hf := '0';
    end case;
    
    --# flush: invalidate on flush hit
    --if (tlbcami.flush_op and hf ) = '1' then
    if (tlbcami.flush_op  ) = '1' then
      v.btag.VALID := '0';
    end if;
    
    --# write op
    if ( tlbcami.write_op  = '1' ) then
      v.btag := tlbcami.tagwrite;
    end if;

    --# reset
    if (rst = '0' or tlbcami.mmuen = '0') then
      v.btag.VALID := '0';
    end if;
    
    tlbcamo_pteout(PTE_PPN_U downto PTE_PPN_D) := r.btag.PPN;
    tlbcamo_pteout(PTE_C) := r.btag.C;
    tlbcamo_pteout(PTE_M) := r.btag.M;
    tlbcamo_pteout(PTE_R) := r.btag.R;
    tlbcamo_pteout(PTE_ACC_U downto PTE_ACC_D) := r.btag.ACC;
    tlbcamo_pteout(PT_ET_U downto PT_ET_D) := r.btag.ET;
    tlbcamo_LVL(1 downto 0) := r.btag.LVL;
    
    --# drive signals
    tlbcamo.pteout   <= tlbcamo_pteout;
    tlbcamo.LVL      <= tlbcamo_LVL;
    --tlbcamo.hit      <= (tlbcami.trans_op and hm) or (tlbcami.flush_op and hf);
    tlbcamo.hit      <= (hm) or (tlbcami.flush_op and hf);
    tlbcamo.ctx      <= r.btag.CTX;       -- for diagnostic only
    tlbcamo.valid    <= r.btag.VALID;     -- for diagnostic only
    tlbcamo.vaddr    <= r.btag.I1 & r.btag.I2 & r.btag.I3 & "000000000000"; -- for diagnostic only
    tlbcamo.NEEDSYNC <= tlbcamo_NEEDSYNC;
    tlbcamo.WBNEEDSYNC <= tlbcamo_WBNEEDSYNC;
    
    
    c <= v;
  end process p0;
  
  p1: process (clk, c)
  begin if rising_edge(clk) then r <= c; end if;
  end process p1;
  
end rtl;
