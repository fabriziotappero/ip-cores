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
-- Entity: 	mmutlb
-- File:	mmutlb.vhd
-- Author:	Konrad Eisele, Jiri Gaisler, Gaisler Research
-- Description:	MMU TLB logic
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
library techmap;
use techmap.gencomp.all;
library gaisler;
use gaisler.libiu.all;
use gaisler.libcache.all;
use gaisler.leon3.all;
use gaisler.mmuconfig.all;
use gaisler.mmuiface.all;
use gaisler.libmmu.all;

entity mmutlb is
  generic ( 
    tech     : integer range 0 to NTECH := 0;
    entries  : integer range 2 to 32 := 8;
    tlb_type  : integer range 0 to 3 := 1;
    tlb_rep  : integer range 0 to 1 := 1
  );
  port (
    rst   : in  std_logic;
    clk     : in std_logic;
    tlbi  : in  mmutlb_in_type;
    tlbo  : out mmutlb_out_type;
    two   : in  mmutw_out_type;
    twi   : out mmutw_in_type
    );
end mmutlb;

architecture rtl of mmutlb is

  constant M_TLB_FASTWRITE : integer range 0 to 3 := conv_integer(conv_std_logic_vector(tlb_type,2) and conv_std_logic_vector(2,2));   -- fast writebuffer
  
  constant entries_log : integer := log2(entries);
  constant entries_max : std_logic_vector(entries_log-1 downto 0) := 
	conv_std_logic_vector(entries-1, entries_log);

  type states  is (idle, match, walk, pack, flush, sync, diag, dofault);
  type tlb_rtype is record
      s1_valid    : std_logic;

      s2_tlbstate : states;
      s2_valid    : std_logic;
      s2_entry    : std_logic_vector(entries_log-1 downto 0);
      s2_hm       : std_logic;
      s2_needsync : std_logic;
      s2_data     : std_logic_vector(31 downto 0);
      s2_isid     : mmu_idcache;
      s2_su       : std_logic;
      s2_read     : std_logic;
      s2_flush    : std_logic;
      
      walk_use       : std_logic;
      walk_transdata : mmuidc_data_out_type;
      walk_fault     : mmutlbfault_out_type;
      
      nrep        : std_logic_vector(entries_log-1 downto 0);
      tpos        : std_logic_vector(entries_log-1 downto 0);
      touch       : std_logic;
      sync_isw    : std_logic;
      hold        : std_logic;
  end record;
  signal c,r   : tlb_rtype;

  -- tlb cams
  component mmutlbcam 
    generic ( 
      tlb_type  : integer range 0 to 3 := 1
    );
    port (
      rst     : in std_logic;
      clk     : in std_logic;
      tlbcami : in mmutlbcam_in_type;
      tlbcamo : out mmutlbcam_out_type
      );
  end component;
  signal tlbcami     : mmutlbcami_a (M_ENT_MAX-1 downto 0);
  signal tlbcamo     : mmutlbcamo_a (M_ENT_MAX-1 downto 0);

  -- least recently used
  component mmulru
    generic (
      entries  : integer := 8
    );  
    port (
      clk   : in std_logic;
      rst   : in std_logic;
      lrui  : in mmulru_in_type;
      lruo  : out mmulru_out_type 
    );
  end component;
  signal lrui  : mmulru_in_type;
  signal lruo  : mmulru_out_type;

  -- data-ram syncram signals
  signal dr1_addr         : std_logic_vector(entries_log-1 downto 0);
  signal dr1_datain       : std_logic_vector(29 downto 0);
  signal dr1_dataout      : std_logic_vector(29 downto 0);
  signal dr1_enable       : std_logic;
  signal dr1_write        : std_logic;

begin

  p0: process (clk, rst, r, c, tlbi, two, tlbcamo, dr1_dataout, lruo)
    variable v                    : tlb_rtype;
    variable finish, selstate      : std_logic;

    variable cam_hitaddr          : std_logic_vector(M_ENT_MAX_LOG -1 downto 0);
    variable cam_hit_all          : std_logic;
    variable mtag,ftag            : tlbcam_tfp;

    -- tlb cam input
    variable tlbcam_trans_op      : std_logic;
    variable tlbcam_write_op      : std_logic_vector(entries-1 downto 0);
    variable tlbcam_flush_op      : std_logic;

    -- tw inputs
    variable twi_walk_op_ur       : std_logic;
    variable twi_data             : std_logic_vector(31 downto 0);
    variable twi_areq_ur          : std_logic;
    variable twi_aaddr            : std_logic_vector(31 downto 0);
    variable twi_adata            : std_logic_vector(31 downto 0);

    variable two_error            : std_logic;
      
    -- lru inputs
    variable lrui_touch           : std_logic;
    variable lrui_touchmin        : std_logic;
    variable lrui_pos             : std_logic_vector(entries_log-1 downto 0);

    -- syncram inputs
    variable dr1write             : std_logic;


    -- hit tlbcam's output 
    variable ACC                  : std_logic_vector(2 downto 0);
    variable PTE                  : std_logic_vector(31 downto 0);
    variable LVL                  : std_logic_vector(1 downto 0);
    variable CAC                  : std_logic;
    variable NEEDSYNC             : std_logic;

    -- wb hit tlbcam's output 
    variable wb_i_entry		  : integer range 0 to M_ENT_MAX-1;
    variable wb_ACC               : std_logic_vector(2 downto 0);
    variable wb_PTE               : std_logic_vector(31 downto 0);
    variable wb_LVL               : std_logic_vector(1 downto 0);
    variable wb_CAC               : std_logic;
    variable wb_fault_pro, wb_fault_pri  : std_logic;
    variable wb_WBNEEDSYNC        : std_logic;
    
    variable twACC                : std_logic_vector(2 downto 0);
    variable tWLVL                : std_logic_vector(1 downto 0);
    variable twPTE                : std_logic_vector(31 downto 0);
    variable twNEEDSYNC           : std_logic;
    
    
    variable tlbcam_tagin         : tlbcam_tfp;
    variable tlbcam_tagwrite      : tlbcam_reg;

    variable store                : std_logic;
    
    variable reppos               : std_logic_vector(entries_log-1 downto 0);
    variable i_entry		  : integer range 0 to M_ENT_MAX-1;
    variable i_reppos		  : integer range 0 to M_ENT_MAX-1;
    
    variable fault_pro, fault_pri  : std_logic;
    variable fault_mexc, fault_trans, fault_inv, fault_access  : std_logic;
    
    variable transdata : mmuidc_data_out_type;
    variable fault     : mmutlbfault_out_type;
    variable savewalk  : std_logic;
    variable tlbo_s1finished : std_logic;

    variable wb_transdata : mmuidc_data_out_type;

    variable cam_addr     : std_logic_vector(31 downto 0);
  begin

    v := r;

    cam_addr := tlbi.transdata.data;

    wb_i_entry := 0;
    wb_ACC := (others => '0');
    wb_PTE := (others => '0');
    wb_LVL := (others => '0');
    wb_CAC  := '0';
    wb_fault_pro := '0';
    wb_fault_pri := '0';
    wb_WBNEEDSYNC := '0';
        
    if (M_TLB_FASTWRITE /= 0) and (tlbi.trans_op = '0') then
      cam_addr := tlbi.transdata.wb_data;
    end if;
      
    wb_transdata.finish := '0';
    wb_transdata.data := (others => '0');
    wb_transdata.cache := '0';
    wb_transdata.accexc := '0';

    finish := '0';
    selstate := '0';
    
    cam_hitaddr := (others => '0');
    cam_hit_all := '0';

    mtag.TYP := (others => '0');
    mtag.I1 := (others => '0');
    mtag.I2 := (others => '0');
    mtag.I3 := (others => '0');
    mtag.CTX := (others => '0');
    mtag.M := '0';
    ftag.TYP := (others => '0');
    ftag.I1 := (others => '0');
    ftag.I2 := (others => '0');
    ftag.I3 := (others => '0');
    ftag.CTX := (others => '0');
    ftag.M := '0';

    
    tlbcam_trans_op := '0';
    tlbcam_write_op := (others => '0');
    tlbcam_flush_op := '0';
    
    twi_walk_op_ur := '0';
    twi_data := (others => '0');
    twi_areq_ur := '0';
    twi_aaddr := (others => '0');
    twi_adata := (others => '0');

    two_error := '0';
    lrui_touch:= '0';
    lrui_touchmin:= '0';
    lrui_pos := (others => '0');
    
    dr1write := '0';
    
    ACC := (others => '0');
    PTE := (others => '0');
    LVL := (others => '0');
    CAC := '0';
    NEEDSYNC := '0';

    twACC := (others => '0');
    tWLVL := (others => '0');
    twPTE := (others => '0');
    twNEEDSYNC := '0';
    
    tlbcam_tagin.TYP := (others => '0');
    tlbcam_tagin.I1 := (others => '0');
    tlbcam_tagin.I2 := (others => '0');
    tlbcam_tagin.I3 := (others => '0');
    tlbcam_tagin.CTX := (others => '0');
    tlbcam_tagin.M := '0';
    
    tlbcam_tagwrite.ET := (others => '0');
    tlbcam_tagwrite.ACC := (others => '0');
    tlbcam_tagwrite.M := '0';
    tlbcam_tagwrite.R := '0';
    tlbcam_tagwrite.SU := '0';
    tlbcam_tagwrite.VALID := '0';
    tlbcam_tagwrite.LVL := (others => '0');
    tlbcam_tagwrite.I1 := (others => '0');
    tlbcam_tagwrite.I2 := (others => '0');
    tlbcam_tagwrite.I3 := (others => '0');
    tlbcam_tagwrite.CTX := (others => '0');
    tlbcam_tagwrite.PPN := (others => '0');
    tlbcam_tagwrite.C := '0';
    
    store := '0';
    reppos := (others => '0');
    fault_pro := '0';
    fault_pri := '0';
    fault_mexc := '0';
    fault_trans := '0';
    fault_inv := '0';
    fault_access := '0';

    transdata.finish := '0';
    transdata.data := (others => '0');
    transdata.cache := '0';
    transdata.accexc := '0';

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
                         
    savewalk := '0';
    tlbo_s1finished := '0';
    
    tlbcam_trans_op := '0'; tlbcam_write_op := (others => '0'); tlbcam_flush_op := '0';
    lrui_touch := '0'; lrui_touchmin := '0'; lrui_pos := (others => '0');
    dr1write := '0';
    fault_pro := '0'; fault_pri := '0'; fault_mexc := '0'; fault_trans := '0'; fault_inv := '0'; fault_access := '0';
    twi_walk_op_ur := '0'; twi_areq_ur := '0'; twi_aaddr := dr1_dataout&"00";
    finish := '0';
    store := '0'; v.hold := '0'; savewalk := '0'; tlbo_s1finished := '0';
    selstate := '0'; 
    
    cam_hitaddr := (others => '0');
    cam_hit_all := '0';
    NEEDSYNC := '0';
    for i in entries-1 downto 0 loop
      NEEDSYNC := NEEDSYNC or tlbcamo(i).NEEDSYNC;
      if (tlbcamo(i).hit) = '1' then
        cam_hitaddr(entries_log-1 downto 0) := cam_hitaddr(entries_log-1 downto 0) or conv_std_logic_vector(i, entries_log);
        cam_hit_all := '1';
      end if;
    end loop;
    
    -- tlbcam write operation
    tlbcam_tagwrite := TLB_CreateCamWrite( two.data, r.s2_read, two.lvl, tlbi.mmctrl1.ctx, r.s2_data);
    
    -- replacement position
    reppos := (others => '0');
    if tlb_rep = 0 then
      reppos := lruo.pos(entries_log-1 downto 0);
      v.touch := '0';
    elsif tlb_rep = 1 then
      reppos := r.nrep;
    end if;

    i_reppos := conv_integer(reppos);
    
    -- tw
    two_error := two.fault_mexc or two.fault_trans or two.fault_inv;

    twACC := two.data(PTE_ACC_U downto PTE_ACC_D);
    twLVL := two.lvl;
    twPTE := two.data;
    twNEEDSYNC := (not two.data(PTE_R)) or ((not r.s2_read) and (not two.data(PTE_M))); -- tw : writeback on next flush

    case r.s2_tlbstate is
      
      when idle =>

        if (tlbi.s2valid) = '1' then
          if r.s2_flush = '1' then
            v.s2_tlbstate := pack;
          else
            v.walk_fault.fault_pri := '0';
            v.walk_fault.fault_pro := '0';
            v.walk_fault.fault_access := '0';
            v.walk_fault.fault_trans := '0';
            v.walk_fault.fault_inv := '0';
            v.walk_fault.fault_mexc := '0';
            
            if (r.s2_hm and not tlbi.mmctrl1.tlbdis )  = '1' then
              if r.s2_needsync = '1' then
                v.s2_tlbstate := sync;
              else
                finish := '1';
              end if;
              
              if tlb_rep = 0 then  
                v.tpos := r.s2_entry; v.touch := '1';  -- touch lru
              end if;
              
            else
	      v.s2_entry := reppos;
              v.s2_tlbstate := walk;
              if tlb_rep = 0 then
                lrui_touchmin := '1';             -- lru element consumed
              end if;
            end if;
          end if;
        end if;
        
      when walk =>
        
        if (two.finish = '1') then
          if ( two_error ) = '0' then
            tlbcam_write_op := decode(r.s2_entry);
            dr1write := '1';
            TLB_CheckFault( twACC, r.s2_isid, r.s2_su, r.s2_read, v.walk_fault.fault_pro, v.walk_fault.fault_pri );
          end if;

          TLB_MergeData( two.lvl , two.data, r.s2_data, v.walk_transdata.data );
          v.walk_transdata.cache := two.data(PTE_C);
          v.walk_fault.fault_lvl := two.fault_lvl;
          v.walk_fault.fault_access := '0';
          v.walk_fault.fault_mexc := two.fault_mexc;
          v.walk_fault.fault_trans := two.fault_trans;
          v.walk_fault.fault_inv := two.fault_inv;
          v.walk_use := '1';
          
          if ( twNEEDSYNC = '0' or two_error = '1') then
            v.s2_tlbstate := pack;
          else
            v.s2_tlbstate := sync;
            v.sync_isw := '1';
          end if;
          
          if tlb_rep = 1 then
            if (r.nrep = entries_max) then v.nrep := (others => '0');
            else  v.nrep := r.nrep + 1;
            end if;
          end if;
        else
          twi_walk_op_ur := '1';
        end if;

      when pack =>
        v.s2_flush := '0';
        v.walk_use := '0';
        finish := '1';
        v.s2_tlbstate := idle;
        
      when sync =>
        
        tlbcam_trans_op := '1';
        if ( v.sync_isw = '1') then
          -- pte address is currently written to syncram, wait one cycle before issuing twi_areq_ur
          v.sync_isw := '0';
        else
          if (two.finish = '1') then
            v.s2_tlbstate := pack;
            v.walk_fault.fault_mexc := two.fault_mexc;
            if (two.fault_mexc) = '1' then
              v.walk_use := '1';
            end if;
          else
            twi_areq_ur := '1';
          end if;
        end if;
        

      when others =>
        v .s2_tlbstate := idle;
    end case;

    if selstate = '1' then
      if tlbi.trans_op = '1' then
      elsif tlbi.flush_op = '1' then
      end if;
    end if;
    
    i_entry := conv_integer(r.s2_entry);  
    
    ACC := tlbcamo(i_entry).pteout(PTE_ACC_U downto PTE_ACC_D);
    PTE := tlbcamo(i_entry).pteout;
    LVL := tlbcamo(i_entry).LVL;
    CAC := tlbcamo(i_entry).pteout(PTE_C);
    
    transdata.cache := CAC;

    --# fault, todo: should we flush on a fault?
    TLB_CheckFault( ACC, r.s2_isid, r.s2_su, r.s2_read, fault_pro, fault_pri );
      
    fault.fault_pro    := '0';
    fault.fault_pri    := '0';
    fault.fault_access := '0';
    fault.fault_mexc   := '0';
    fault.fault_trans  := '0';
    fault.fault_inv    := '0';
    if finish = '1' and (r.s2_flush = '0') then  --protect flush path
      fault.fault_pro    := fault_pro;
      fault.fault_pri    := fault_pri;
      fault.fault_access := fault_access;
      fault.fault_mexc   := fault_mexc;
      fault.fault_trans  := fault_trans;
      fault.fault_inv    := fault_inv;
    end if;
    
    if (M_TLB_FASTWRITE /= 0) then
      wb_i_entry := conv_integer(cam_hitaddr(entries_log-1 downto 0));  
    
      wb_ACC := tlbcamo(wb_i_entry).pteout(PTE_ACC_U downto PTE_ACC_D);
      wb_PTE := tlbcamo(wb_i_entry).pteout;
      wb_LVL := tlbcamo(wb_i_entry).LVL;
      wb_CAC := tlbcamo(wb_i_entry).pteout(PTE_C);
      wb_WBNEEDSYNC := tlbcamo(wb_i_entry).WBNEEDSYNC;
        
      wb_transdata.cache := wb_CAC;

      TLB_MergeData( wb_LVL, wb_PTE, tlbi.transdata.data, wb_transdata.data );

      --# fault, todo: should we flush on a fault?
      TLB_CheckFault( wb_ACC, tlbi.transdata.isid, tlbi.transdata.su, tlbi.transdata.read, wb_fault_pro, wb_fault_pri );

      wb_transdata.accexc :=  wb_fault_pro or wb_fault_pri or wb_WBNEEDSYNC or (not cam_hit_all);
      
    end if;
    
    --# merge data
    TLB_MergeData( LVL, PTE, r.s2_data, transdata.data );
    
    --# reset
    if (rst = '0') then
      v.s2_flush := '0';
      v.s2_tlbstate := idle;
      if tlb_rep = 1 then
        v.nrep := (others => '0');
      end if;
      if tlb_rep = 0 then
        v.touch := '0';
      end if;
      v.sync_isw := '0';
    end if;
    
    if (finish = '1') or (tlbi.s2valid = '0') then
      tlbo_s1finished := '1';
      v.s2_hm := cam_hit_all;
      v.s2_entry := cam_hitaddr(entries_log-1 downto 0);
      v.s2_needsync := NEEDSYNC;
      v.s2_data := tlbi.transdata.data;
      v.s2_read := tlbi.transdata.read;
      v.s2_su := tlbi.transdata.su;
      v.s2_isid := tlbi.transdata.isid;
      v.s2_flush := tlbi.flush_op;
    end if;

    -- translation operation tag
    mtag := TLB_CreateCamTrans( cam_addr, tlbi.transdata.read, tlbi.mmctrl1.ctx ); 
    tlbcam_tagin := mtag;
    
    -- flush/(probe) operation tag
    ftag := TLB_CreateCamFlush( r.s2_data, tlbi.mmctrl1.ctx ); 
    if (r.s2_flush = '1') then
      tlbcam_tagin := ftag;
    end if;
    
    if r.walk_use = '1' then
      transdata  := r.walk_transdata;
      fault      := r.walk_fault;
    end if;
    fault.fault_read   := r.s2_read;
    fault.fault_su     := r.s2_su;
    fault.fault_isid   := r.s2_isid;
    fault.fault_addr   := r.s2_data;
    
    transdata.finish := finish;
    transdata.accexc := '0';
    
    
    twi_adata := PTE;
    
    --# drive signals
    tlbo.wbtransdata  <= wb_transdata;
    
    tlbo.transdata    <= transdata;
    tlbo.fault        <= fault;
    tlbo.nexttrans    <= store;
    tlbo.s1finished   <= tlbo_s1finished;

    tlbo.tlbcamo <= (others => mmutlbcam_out_none);
    
    twi.walk_op_ur    <= twi_walk_op_ur;
    twi.data          <= r.s2_data;
    twi.areq_ur       <= twi_areq_ur;
    twi.adata         <= twi_adata;
    twi.aaddr         <= twi_aaddr;

    if tlb_rep = 0 then
      lrui.flush        <= r.s2_flush;
      lrui.touch        <= r.touch;
      lrui.touchmin     <= lrui_touchmin;
      lrui.pos          <= (others => '0');
      lrui.pos(entries_log-1 downto 0)          <= r.tpos;
      lrui.mmctrl1      <= tlbi.mmctrl1;
    end if;
    
    dr1_addr          <= r.s2_entry;
    dr1_datain        <= two.addr(31 downto 2);
    dr1_enable        <= '1';
    dr1_write         <= dr1write;
    
    for i in entries-1 downto 0 loop
      tlbcami(i).tagin     <= tlbcam_tagin;
      tlbcami(i).trans_op  <= tlbi.trans_op; --tlbcam_trans_op;
      tlbcami(i).wb_op     <= tlbi.wb_op; --tlbcam_trans_op;
      tlbcami(i).flush_op  <= r.s2_flush;
      tlbcami(i).mmuen     <= tlbi.mmctrl1.e;
      tlbcami(i).tagwrite  <= tlbcam_tagwrite;
      tlbcami(i).write_op  <= tlbcam_write_op(i);
      tlbcami(i).mset  <= '0';
    end loop;  -- i
    for i in M_ENT_MAX-1 downto entries loop
      tlbcami(i).tagin     <= tlbcam_tfp_none;
      tlbcami(i).trans_op  <= '0';
      tlbcami(i).wb_op     <= '0';
      tlbcami(i).flush_op  <= '0';
      tlbcami(i).mmuen     <= '0';
      tlbcami(i).tagwrite  <= tlbcam_reg_none;
      tlbcami(i).write_op  <= '0';
      tlbcami(i).mset  <= '0';
    end loop;
    
    c <= v;
  end process p0;


  p1: process (clk)
  begin if rising_edge(clk) then r <= c;  end if;
  end process p1;

  -- tag-cam tlb entries
  tlbcam0: for i in entries-1 downto 0 generate
    tag0 : mmutlbcam
      generic map ( tlb_type )
      port map (rst, clk, tlbcami(i), tlbcamo(i));
  end generate tlbcam0;
  tlbcamnone: for i in M_ENT_MAX-1 downto entries generate
    tlbcamo(i) <= mmutlbcam_out_none;
  end generate ;

  -- data-ram syncram 
  dataram : syncram
    generic map ( tech => tech, dbits => 30, abits => entries_log)
    port map ( clk, dr1_addr, dr1_datain, dr1_dataout, dr1_enable, dr1_write);

  -- lru
  lru0: if tlb_rep = 0 generate
    lru : mmulru
      generic map ( entries => entries)
      port map ( clk, rst, lrui, lruo );
  end generate lru0;

end rtl;
