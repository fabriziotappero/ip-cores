----------------------------------------------------------------------------
--  This file is a part of the LEON VHDL model
--  Copyright (C) 2003  Gaisler Research, all rights reserved
--
--  This library is free software; you can redistribute it and/or
--  modify it under the terms of the GNU Lesser General Public
--  License as published by the Free Software Foundation; either
--  version 2 of the License, or (at your option) any later version.
--
--  See the file COPYING.LGPL for the full details of the license.
----------------------------------------------------------------------------

-- Konrad Eisele<eiselekd@web.de> ,2002  

library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned."+";
use work.leon_iface.all;
use work.mmuconfig.all;
use work.macro.all;

entity mmutlbcam is  
  port (
      rst     : in std_logic;
      clk     : in clk_type;
      tlbcami : in mmutlbcam_in_type;
      tlbcamo : out mmutlbcam_out_type
  );
end mmutlbcam;

architecture rtl of mmutlbcam is

  type tlbcam_rtype is record
    btag     : tlbcam_reg;
  end record;
  signal r,c : tlbcam_rtype;

begin  

  p0: process (clk, rst, r, tlbcami)
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
    
    -- pragma translate_off
    if not (is_x(r.btag.I1) or is_x(r.btag.I2) or is_x(r.btag.I3) or is_x(r.btag.CTX) or
            is_x(tlbcami.tagin.I1) or is_x(tlbcami.tagin.I2) or is_x(tlbcami.tagin.I3) or is_x(tlbcami.tagin.CTX)) then
    -- pragma translate_on
    -- prepare tag comparision
    if (r.btag.I1  = tlbcami.tagin.I1)  then h_i1 := '1';  else h_i1 := '0'; end if;
    if (r.btag.I2  = tlbcami.tagin.I2)  then h_i2 := '1';  else h_i2 := '0'; end if;
    if (r.btag.I3  = tlbcami.tagin.I3)  then h_i3 := '1';  else h_i3 := '0'; end if;
    if (r.btag.CTX = tlbcami.tagin.CTX) then h_c  := '1';  else h_c  := '0'; end if;
    -- pragma translate_off
    end if;
    -- pragma translate_on
    
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
    tlbcamo.hit      <= (tlbcami.trans_op and hm) or (tlbcami.flush_op and hf);
    tlbcamo.ctx      <= r.btag.CTX;       -- for diagnostic only
    tlbcamo.valid    <= r.btag.VALID;     -- for diagnostic only
    tlbcamo.vaddr    <= r.btag.I1 & r.btag.I2 & r.btag.I3 & "000000000000"; -- for diagnostic only
    tlbcamo.NEEDSYNC <= tlbcamo_NEEDSYNC;
    
    --#dump
    -- pragma translate_off
    -- pragma translate_on
    
    c <= v;
  end process p0;
  
  p1: process (clk, c)
  begin if rising_edge(clk) then r <= c; end if;
  end process p1;
  
end rtl;
