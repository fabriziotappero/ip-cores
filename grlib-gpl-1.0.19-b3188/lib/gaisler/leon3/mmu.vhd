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
-- Entity: 	MMU
-- File:	mmu.vhd
-- Author:	Konrad Eisele, Jiri Gaisler, Gaisler Research
-- Description:	Leon3 MMU top level entity
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.stdlib.all;
library techmap;
use techmap.gencomp.all;
library gaisler;
use gaisler.mmuconfig.all;
use gaisler.mmuiface.all;
use gaisler.libmmu.all;

entity mmu is
  generic (
    tech      : integer range 0 to NTECH := 0;
    itlbnum   : integer range 2 to 64 := 8;
    dtlbnum   : integer range 2 to 64 := 8;
    tlb_type  : integer range 0 to 3 := 1;
    tlb_rep   : integer range 0 to 1 := 0
    );
  port (
    rst  : in std_logic;
    clk  : in std_logic;
    
    mmudci : in  mmudc_in_type;
    mmudco : out mmudc_out_type;

    mmuici : in  mmuic_in_type;
    mmuico : out mmuic_out_type;
    
    mcmmo  : in  memory_mm_out_type;
    mcmmi  : out memory_mm_in_type
    );
end mmu;

architecture rtl of mmu is

constant MMUCTX_BITS 	: integer := M_CTX_SZ;

constant M_TLB_TYPE     : integer range 0 to 1 := conv_integer(conv_std_logic_vector(tlb_type,2) and conv_std_logic_vector(1,2));  -- eather split or combined
constant M_TLB_FASTWRITE : integer range 0 to 3 := conv_integer(conv_std_logic_vector(tlb_type,2) and conv_std_logic_vector(2,2));   -- fast writebuffer
constant M_ENT_I        : integer range 2 to 64 := itlbnum;   -- icache tlb entries: number
constant M_ENT_ILOG     : integer := log2(M_ENT_I);     -- icache tlb entries: address bits
constant M_ENT_D        : integer range 2 to 64 := dtlbnum;   -- dcache tlb entries: number
constant M_ENT_DLOG     : integer := log2(M_ENT_D);     -- dcache tlb entries: address bits
constant M_ENT_C        : integer range 2 to 64 := M_ENT_I;   -- i/dcache tlb entries: number
constant M_ENT_CLOG     : integer := M_ENT_ILOG;     -- i/dcache tlb entries: address bits
  
  type mmu_op is record
    trans_op  : std_logic;
    flush_op  : std_logic;
    diag_op   : std_logic;
  end record;
  
  type mmu_cmbpctrl is record
    tlbowner     : mmu_idcache;
    tlbactive    : std_logic;
    op           : mmu_op;
  end record;

  type mmu_rtype is record
    cmb_s1          : mmu_cmbpctrl; 
    cmb_s2          : mmu_cmbpctrl;
      
    splt_is1          : mmu_cmbpctrl;
    splt_is2          : mmu_cmbpctrl;
    splt_ds1          : mmu_cmbpctrl;
    splt_ds2          : mmu_cmbpctrl;
      
    twactive     : std_logic;        -- split tlb
    twowner      : mmu_idcache;        -- split tlb

    flush         : std_logic;
    mmctrl2       : mmctrl_type2;
  end record;

  signal r, c   : mmu_rtype;
  
  -- tlb
  component mmutlb
    generic ( 
      tech     : integer range 0 to NTECH := 0;
      entries  : integer range 2 to 32 := 8;
      tlb_type  : integer range 0 to 3 := 1;
      tlb_rep   : integer range 0 to 1 := 0
      );
    port (
      rst   : in std_logic;
      clk   : in std_logic;
      tlbi  : in mmutlb_in_type;
      tlbo  : out mmutlb_out_type;
      two  : in mmutw_out_type;
      twi  : out mmutw_in_type
      );
  end component;
  signal tlbi_a0 : mmutlb_in_type;
  signal tlbi_a1 : mmutlb_in_type;
  signal tlbo_a0 : mmutlb_out_type;
  signal tlbo_a1 : mmutlb_out_type;
  signal twi_a : mmutwi_a(1 downto 0);
  signal two_a : mmutwo_a(1 downto 0);

  -- table walk
  component mmutw 
  port (
    rst     : in  std_logic;
    clk     : in  std_logic;
    mmctrl1 : in  mmctrl_type1;
    twi     : in  mmutw_in_type;
    two     : out mmutw_out_type;
    mcmmo   : in  memory_mm_out_type;
    mcmmi   : out memory_mm_in_type
    );
  end component;
  signal twi     : mmutw_in_type;
  signal two     : mmutw_out_type;
  signal mmctrl1 : mmctrl_type1;
    
begin  
    
  p1: process (clk)
  begin if rising_edge(clk) then r <= c; end if;
  end process p1;
  

  p0: process (rst, r, c, mmudci, mmuici, mcmmo, tlbo_a0, tlbo_a1, tlbi_a0, tlbi_a1, two_a, twi_a, two)
    variable cmbtlbin     : mmuidc_data_in_type;
    variable cmbtlbout    : mmutlb_out_type;
    
    variable spltitlbin     : mmuidc_data_in_type;
    variable spltdtlbin     : mmuidc_data_in_type;
    variable spltitlbout    : mmutlb_out_type;
    variable spltdtlbout    : mmutlb_out_type;
    
    
    
    variable mmuico_transdata : mmuidc_data_out_type;
    variable mmudco_transdata : mmuidc_data_out_type;
    variable mmuico_grant : std_logic;
    variable mmudco_grant : std_logic;
    variable v            : mmu_rtype;
    variable twiv         : mmutw_in_type;
    variable twod, twoi   : mmutw_out_type;
    variable fault       : mmutlbfault_out_type;

    variable wbtransdata : mmuidc_data_out_type;
    
    variable fs : mmctrl_fs_type;
    variable fa : std_logic_vector(VA_I_SZ-1 downto 0);
  begin 
    
    v := r;

    wbtransdata.finish := '0';
    wbtransdata.data   := (others => '0');
    wbtransdata.cache  := '0';
    wbtransdata.accexc := '0';
    if (M_TLB_TYPE = 0) and (M_TLB_FASTWRITE /= 0) then
      wbtransdata := tlbo_a1.wbtransdata;
    end if;
    
    cmbtlbin.data := (others => '0');
    cmbtlbin.su := '0';
    cmbtlbin.read := '0';
    cmbtlbin.isid := id_dcache;
    
    cmbtlbout.transdata.finish := '0';
    cmbtlbout.transdata.data := (others => '0');
    cmbtlbout.transdata.cache := '0';
    cmbtlbout.transdata.accexc := '0';
    
    cmbtlbout.fault.fault_pro := '0';
    cmbtlbout.fault.fault_pri := '0';
    cmbtlbout.fault.fault_access := '0';
    cmbtlbout.fault.fault_mexc := '0';
    cmbtlbout.fault.fault_trans := '0';
    cmbtlbout.fault.fault_inv := '0';
    cmbtlbout.fault.fault_lvl := (others => '0');
    cmbtlbout.fault.fault_su  := '0';
    cmbtlbout.fault.fault_read := '0';
    cmbtlbout.fault.fault_isid  := id_dcache;
    cmbtlbout.fault.fault_addr := (others => '0');

    cmbtlbout.nexttrans := '0';
    cmbtlbout.s1finished := '0';
    
    mmuico_transdata.finish := '0';
    mmuico_transdata.data := (others => '0');
    mmuico_transdata.cache := '0';
    mmuico_transdata.accexc := '0';

    mmudco_transdata.finish := '0';
    mmudco_transdata.data := (others => '0');
    mmudco_transdata.cache := '0';
    mmudco_transdata.accexc := '0';
    
    mmuico_grant := '0';
    mmudco_grant := '0';

    twiv.walk_op_ur := '0';
    twiv.areq_ur := '0';
    
    twiv.data := (others => '0');
    twiv.adata := (others => '0');
    twiv.aaddr := (others => '0');
    
    twod.finish := '0';
    twod.data := (others => '0');
    twod.addr := (others => '0');
    twod.lvl := (others => '0');
    twod.fault_mexc := '0';
    twod.fault_trans := '0';
    twod.fault_inv := '0';
    twod.fault_lvl := (others => '0');

    twoi.finish := '0';
    twoi.data := (others => '0');
    twoi.addr := (others => '0');
    twoi.lvl := (others => '0');
    twoi.fault_mexc := '0';
    twoi.fault_trans := '0';
    twoi.fault_inv := '0';
    twoi.fault_lvl := (others => '0');
    
    fault.fault_pro := '0';
    fault.fault_pri := '0';
    fault.fault_access := '0';
    fault.fault_mexc := '0';
    fault.fault_trans := '0';
    fault.fault_inv := '0';
    fault.fault_lvl := (others => '0');
    fault.fault_su := '0';
    fault.fault_read := '0';
    fault.fault_isid := id_dcache;
    fault.fault_addr := (others => '0');

    fs.ow := '0';
    fs.fav := '0';
    fs.ft := (others => '0');
    fs.at_ls := '0';
    fs.at_id := '0';
    fs.at_su := '0';
    fs.l := (others => '0');
    fs.ebe := (others => '0');
    
    fa := (others => '0');
    
    if M_TLB_TYPE = 0 then
      
      spltitlbout := tlbo_a0;
      spltdtlbout := tlbo_a1;
      twod := two; twoi := two;
      twod.finish := '0'; twoi.finish := '0';
      spltdtlbin := mmudci.transdata;
      spltitlbin := mmuici.transdata;
      mmudco_transdata := spltdtlbout.transdata;
      mmuico_transdata := spltitlbout.transdata;

      -- d-tlb
      if ((not r.splt_ds1.tlbactive) or spltdtlbout.s1finished) = '1'  then
        v.splt_ds1.tlbactive := '0';
        v.splt_ds1.op.trans_op := '0';
        v.splt_ds1.op.flush_op := '0';
        if mmudci.trans_op = '1' then
          mmudco_grant := '1';
          v.splt_ds1.tlbactive := '1';
          v.splt_ds1.op.trans_op := '1';
        elsif mmudci.flush_op = '1' then
          v.flush := '1';
          mmudco_grant := '1';
          v.splt_ds1.tlbactive := '1';
          v.splt_ds1.op.flush_op := '1';
        end if;
      end if;
      
      -- i-tlb
      if ((not r.splt_is1.tlbactive) or spltitlbout.s1finished) = '1'  then
        v.splt_is1.tlbactive := '0';
        v.splt_is1.op.trans_op := '0';
        v.splt_is1.op.flush_op := '0';
        if v.flush = '1' then
          v.flush := '0';
          v.splt_is1.tlbactive := '1';
          v.splt_is1.op.flush_op := '1';
        elsif mmuici.trans_op = '1' then
          mmuico_grant := '1';
          v.splt_is1.tlbactive := '1';
          v.splt_is1.op.trans_op := '1';
        end if;
      end if;

      if spltitlbout.transdata.finish = '1' and (r.splt_is2.op.flush_op = '0') then
        fault := spltitlbout.fault;
      end if;
      if spltdtlbout.transdata.finish = '1' and (r.splt_is2.op.flush_op = '0') then
        if (spltdtlbout.fault.fault_mexc or 
            spltdtlbout.fault.fault_trans or
            spltdtlbout.fault.fault_inv or
            spltdtlbout.fault.fault_pro or
            spltdtlbout.fault.fault_pri or
            spltdtlbout.fault.fault_access) = '1' then
          fault := spltdtlbout.fault;     -- overwrite icache fault
        end if;
      end if;
      
      if spltitlbout.s1finished = '1' then
        v.splt_is2 := r.splt_is1;
      end if;
      if spltdtlbout.s1finished = '1' then
        v.splt_ds2 := r.splt_ds1;
      end if;
      
      if ( r.splt_is2.op.flush_op ) = '1' then
        mmuico_transdata.finish := '0';
      end if;
          
      -- share tw
      if two.finish = '1' then
        v.twactive := '0';
      end if;
      
      if r.twowner = id_icache then
        twiv := twi_a(0);
        twoi.finish := two.finish;
      else
        twiv := twi_a(1);
        twod.finish := two.finish;
      end if;
      
      if (v.twactive) = '0'  then
        if (twi_a(1).areq_ur or twi_a(1).walk_op_ur) = '1' then
          v.twactive := '1';
          v.twowner := id_dcache;
        elsif (twi_a(0).areq_ur or twi_a(0).walk_op_ur) = '1' then
          v.twactive := '1';
          v.twowner := id_icache;
        end if;
      end if;
      
    else

      --# combined i/d cache: 1 tlb, 1 tw
      -- share one tlb among i and d cache
      cmbtlbout := tlbo_a0;
      mmuico_grant := '0'; mmudco_grant := '0';
      mmuico_transdata.finish := '0'; mmudco_transdata.finish := '0';
      twiv := twi_a(0);
      twod := two; twoi := two;
      twod.finish := '0'; twoi.finish := '0';
      -- twod.finish := two.finish;
      twoi.finish := two.finish;
    
      if ((not v.cmb_s1.tlbactive) or cmbtlbout.s1finished) = '1'  then
        v.cmb_s1.tlbactive := '0';
        v.cmb_s1.op.trans_op := '0';
        v.cmb_s1.op.flush_op := '0';
        if (mmudci.trans_op or mmudci.flush_op or mmuici.trans_op) = '1' then
          v.cmb_s1.tlbactive := '1';
        end if;
        if mmudci.trans_op = '1' then
          mmudco_grant := '1';
          v.cmb_s1.tlbowner := id_dcache;
          v.cmb_s1.op.trans_op := '1';
        elsif mmudci.flush_op = '1' then
          mmudco_grant := '1';
          v.cmb_s1.tlbowner := id_dcache;
          v.cmb_s1.op.flush_op := '1';
        elsif mmuici.trans_op = '1' then
          mmuico_grant := '1'; 
          v.cmb_s1.tlbowner := id_icache;
          v.cmb_s1.op.trans_op := '1';
        end if;
      end if;
    
      if (r.cmb_s1.tlbactive and not r.cmb_s2.tlbactive)  = '1'  then
      
      end if;
      
      if cmbtlbout.s1finished = '1' then
        v.cmb_s2 := r.cmb_s1;
      end if;
  
      if r.cmb_s1.tlbowner = id_dcache then
        cmbtlbin := mmudci.transdata;
      else
        cmbtlbin := mmuici.transdata;
      end if;
    
      if r.cmb_s2.tlbowner = id_dcache then
        mmudco_transdata := cmbtlbout.transdata;
      else
        mmuico_transdata := cmbtlbout.transdata;
      end if;

      if cmbtlbout.transdata.finish = '1' and (r.cmb_s2.op.flush_op = '0')  then
        fault := cmbtlbout.fault;
      end if;

    end if;
      


    
    -- # fault status register
    if (mmudci.fsread) = '1' then
      v.mmctrl2.valid := '0'; v.mmctrl2.fs.fav := '0';
    end if;
    
    if (fault.fault_mexc) = '1' then
      fs.ft := FS_FT_TRANS;
    elsif (fault.fault_trans) = '1' then
      fs.ft := FS_FT_INV;
    elsif (fault.fault_inv) = '1' then
      fs.ft := FS_FT_INV;
    elsif (fault.fault_pri) = '1' then
      fs.ft := FS_FT_PRI;
    elsif (fault.fault_pro) = '1' then
      fs.ft := FS_FT_PRO;
    elsif (fault.fault_access) = '1' then
      fs.ft := FS_FT_BUS;
    else 
      fs.ft := FS_FT_NONE;
    end if;
    
    fs.ow := '0';
    fs.l := fault.fault_lvl;
    if fault.fault_isid = id_dcache then
      fs.at_id := '0';
    else
      fs.at_id := '1';
    end if;                
    fs.at_su := fault.fault_su;
    fs.at_ls := not fault.fault_read;
    fs.fav := '1';
    fs.ebe := (others => '0');
    
    fa := fault.fault_addr(VA_I_U downto VA_I_D);
    
    if (fault.fault_mexc or 
        fault.fault_trans or
        fault.fault_inv or
        fault.fault_pro or
        fault.fault_pri or
        fault.fault_access) = '1' then
            
      --# priority
      if v.mmctrl2.valid = '1'then
        if (fault.fault_mexc) = '1' then
          v.mmctrl2.fs := fs;
          v.mmctrl2.fa := fa;
        else
          if (r.mmctrl2.fs.ft /= FS_FT_INV) then
            if fault.fault_isid = id_dcache then
            -- dcache
              v.mmctrl2.fs := fs;
              v.mmctrl2.fa := fa;
            else
            -- icache
              if (not r.mmctrl2.fs.at_id) = '0' then
                fs.ow := '1';
                v.mmctrl2.fs := fs;
                v.mmctrl2.fa := fa;
              end if;
            end if;
          end if;
          
        end if;
      else
        v.mmctrl2.fs := fs;
        v.mmctrl2.fa := fa;
        v.mmctrl2.valid := '1';
      end if;

      if (fault.fault_isid) = id_dcache then
        mmudco_transdata.accexc := '1';
      else
        mmuico_transdata.accexc := '1';
      end if;
      
    end if;
    
    -- # reset
    if ( rst = '0' ) then
      if M_TLB_TYPE = 0 then
        v.splt_is1.tlbactive := '0';
        v.splt_is2.tlbactive := '0';
        v.splt_ds1.tlbactive := '0';
        v.splt_ds2.tlbactive := '0';
        v.splt_is1.op.trans_op := '0';
        v.splt_is2.op.trans_op := '0';
        v.splt_ds1.op.trans_op := '0';
        v.splt_ds2.op.trans_op := '0';
        v.splt_is1.op.flush_op := '0';
        v.splt_is2.op.flush_op := '0';
        v.splt_ds1.op.flush_op := '0';
        v.splt_ds2.op.flush_op := '0';
      else
        v.cmb_s1.tlbactive := '0';
        v.cmb_s2.tlbactive := '0';
        v.cmb_s1.op.trans_op := '0';
        v.cmb_s2.op.trans_op := '0';
        v.cmb_s1.op.flush_op := '0';
        v.cmb_s2.op.flush_op := '0';
      end if;
      v.flush := '0';
      v.mmctrl2.valid := '0';
      v.twactive := '0';
      v.twowner := id_icache;
    end if;
    
    -- drive signals
    if M_TLB_TYPE = 0 then
      tlbi_a0.trans_op  <= r.splt_is1.op.trans_op;
      tlbi_a0.flush_op  <= r.splt_is1.op.flush_op;
      tlbi_a0.transdata <= spltitlbin;
      tlbi_a0.s2valid   <= r.splt_is2.tlbactive;
      tlbi_a0.mmctrl1   <= mmudci.mmctrl1;
      tlbi_a0.wb_op     <= '0';
      tlbi_a1.trans_op  <= r.splt_ds1.op.trans_op;
      tlbi_a1.flush_op  <= r.splt_ds1.op.flush_op;
      tlbi_a1.transdata <= spltdtlbin;
      tlbi_a1.s2valid   <= r.splt_ds2.tlbactive;
      tlbi_a1.mmctrl1   <= mmudci.mmctrl1;
      tlbi_a1.wb_op     <= mmudci.wb_op;
    else
      tlbi_a0.trans_op  <= r.cmb_s1.op.trans_op;
      tlbi_a0.flush_op  <= r.cmb_s1.op.flush_op;
      tlbi_a0.transdata <= cmbtlbin;
      tlbi_a0.s2valid   <= r.cmb_s2.tlbactive;
      tlbi_a0.mmctrl1   <= mmudci.mmctrl1;
      tlbi_a0.wb_op     <= '0';
    end if;
    tlbi_a0.tlbcami     <= (others => mmutlbcam_in_type_none);
    tlbi_a1.tlbcami     <= (others => mmutlbcam_in_type_none);
        
    mmudco.transdata <= mmudco_transdata;
    mmuico.transdata <= mmuico_transdata;
    mmudco.grant     <= mmudco_grant;
    mmuico.grant     <= mmuico_grant;
    mmudco.mmctrl2   <= r.mmctrl2;
    mmudco.wbtransdata <= wbtransdata;

    twi      <= twiv;
    two_a(0) <= twoi;
    two_a(1) <= twod;
    mmctrl1 <= mmudci.mmctrl1;
    
    c <= v;
    
  end process p0;
  
  tlbcomb0: if M_TLB_TYPE = 1 generate
    -- i/d tlb
    ctlb0 : mmutlb
      generic map ( tech, M_ENT_C, 0, tlb_rep )
      port map (rst, clk, tlbi_a0, tlbo_a0, two_a(0), twi_a(0));
  end generate tlbcomb0;

  tlbsplit0: if M_TLB_TYPE = 0 generate
    -- i tlb
    itlb0 : mmutlb
      generic map ( tech, M_ENT_I, 0, tlb_rep )
      port map (rst, clk, tlbi_a0, tlbo_a0, two_a(0), twi_a(0));
    -- d tlb
    dtlb0 : mmutlb
      generic map ( tech, M_ENT_D, tlb_type, tlb_rep )
      port map (rst, clk, tlbi_a1, tlbo_a1, two_a(1), twi_a(1));
  end generate tlbsplit0;

  -- table walk component
  tw0 : mmutw
    port map (rst, clk, mmctrl1, twi, two, mcmmo, mcmmi);

-- pragma translate_off
  chk : process
  begin
    assert not ((M_TLB_TYPE = 1) and (M_TLB_FASTWRITE /= 0)) report
	"Fast writebuffer only supported for combined cache"
    severity failure;
    wait;
  end process;
-- pragma translate_on

  
end rtl;
