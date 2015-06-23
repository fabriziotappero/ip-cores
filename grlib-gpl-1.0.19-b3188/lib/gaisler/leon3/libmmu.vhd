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
-- Package: 	leon3
-- File:	leon3.vhd
-- Author:	Konrad Eisele, Jiri Gaisler, Gaisler Research
-- Description:	MMU component declaration
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

package libmmu is

  component mmu 
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
  end component;

  
  function TLB_CreateCamWrite( two_data  : std_logic_vector(31 downto 0);
                               read      : std_logic;
                               lvl       : std_logic_vector(1 downto 0);
                               ctx       : std_logic_vector(M_CTX_SZ-1 downto 0);
                               vaddr     : std_logic_vector(31 downto 0)
                               ) return tlbcam_reg;
  
  procedure TLB_CheckFault( ACC        : in  std_logic_vector(2 downto 0);
                            isid       : in  mmu_idcache;
                            su         : in  std_logic;
                            read       : in  std_logic;
                            fault_pro  : out std_logic;
                            fault_pri  : out std_logic );

  procedure TLB_MergeData( LVL         : in  std_logic_vector(1 downto 0);
                           PTE         : in  std_logic_vector(31 downto 0);
                           data        : in  std_logic_vector(31 downto 0);
                           transdata   : out std_logic_vector(31 downto 0));

  function TLB_CreateCamTrans( vaddr     : std_logic_vector(31 downto 0);
                               read      : std_logic;
                               ctx       : std_logic_vector(M_CTX_SZ-1 downto 0)
                             ) return tlbcam_tfp;

  function TLB_CreateCamFlush( data      : std_logic_vector(31 downto 0);
                               ctx       : std_logic_vector(M_CTX_SZ-1 downto 0)
                             ) return tlbcam_tfp;

  
end;

package body libmmu is

procedure TLB_CheckFault( ACC        : in  std_logic_vector(2 downto 0);
                          isid       : in  mmu_idcache;
                          su         : in  std_logic;
                          read       : in  std_logic;
                          fault_pro  : out std_logic;
                          fault_pri  : out std_logic ) is
variable c_isd    : std_logic;
begin
  fault_pro := '0';
  fault_pri := '0';
  
  -- use '0' == icache '1' == dcache
  if isid = id_icache then
    c_isd := '0';
  else
    c_isd := '1';
  end if;
  --# fault, todo: should we flush on a fault?
  case ACC is
    when "000" => fault_pro := (not c_isd) or (not read);    
    when "001" => fault_pro := (not c_isd);
    when "010" => fault_pro := (not read);
    when "011" => null;
    when "100" => fault_pro := (c_isd);
    when "101" => fault_pro := (not c_isd) or ((not read) and (not su));
    when "110" => fault_pri := (not su);
                  fault_pro := (not read);
    when "111" => fault_pri := (not su);
    when others => null;
  end case;
end;
 
procedure TLB_MergeData( LVL         : in  std_logic_vector(1 downto 0);
                         PTE         : in  std_logic_vector(31 downto 0);
                         data        : in  std_logic_vector(31 downto 0);
                         transdata   : out std_logic_vector(31 downto 0) ) is
begin 

  --# merge data
  transdata := (others => '0');
  case LVL is
    when LVL_PAGE    => transdata := PTE(PTE_PPN32PAG_U downto PTE_PPN32PAG_D) & data(VA_OFFPAG_U downto VA_OFFPAG_D);
    when LVL_SEGMENT => transdata := PTE(PTE_PPN32SEG_U downto PTE_PPN32SEG_D) & data(VA_OFFSEG_U downto VA_OFFSEG_D);
    when LVL_REGION  => transdata := PTE(PTE_PPN32REG_U downto PTE_PPN32REG_D) & data(VA_OFFREG_U downto VA_OFFREG_D);
    when LVL_CTX     => transdata :=                                             data(VA_OFFCTX_U downto VA_OFFCTX_D);
    when others      => transdata := (others => 'X');
  end case;
end;

function TLB_CreateCamWrite( two_data  : std_logic_vector(31 downto 0);
                             read      : std_logic;
                             lvl       : std_logic_vector(1 downto 0);
                             ctx       : std_logic_vector(M_CTX_SZ-1 downto 0);
                             vaddr     : std_logic_vector(31 downto 0)
                             ) return tlbcam_reg is
variable tlbcam_tagwrite      : tlbcam_reg;
begin

    tlbcam_tagwrite.ET    := two_data(PT_ET_U downto PT_ET_D);
    tlbcam_tagwrite.ACC   := two_data(PTE_ACC_U downto PTE_ACC_D);
    tlbcam_tagwrite.M     := two_data(PTE_M) or (not read); -- tw : p-update modified
    tlbcam_tagwrite.R     := '1';                         
    case tlbcam_tagwrite.ACC is      -- tw : p-su ACC >= 6
      when "110" | "111" => tlbcam_tagwrite.SU := '1';
      when others =>        tlbcam_tagwrite.SU := '0';
    end case;
    tlbcam_tagwrite.VALID := '1';
    tlbcam_tagwrite.LVL   := lvl;
    tlbcam_tagwrite.I1    := vaddr(VA_I1_U downto VA_I1_D);
    tlbcam_tagwrite.I2    := vaddr(VA_I2_U downto VA_I2_D);
    tlbcam_tagwrite.I3    := vaddr(VA_I3_U downto VA_I3_D);
    tlbcam_tagwrite.CTX   := ctx;
    tlbcam_tagwrite.PPN   := two_data(PTE_PPN_U downto PTE_PPN_D);
    tlbcam_tagwrite.C     := two_data(PTE_C);
    return tlbcam_tagwrite;
end;

function TLB_CreateCamTrans( vaddr     : std_logic_vector(31 downto 0);
                             read      : std_logic;
                             ctx       : std_logic_vector(M_CTX_SZ-1 downto 0)
                             ) return tlbcam_tfp is
variable mtag            : tlbcam_tfp;
begin
    mtag.TYP := (others => '0');
    mtag.I1 := vaddr(VA_I1_U downto VA_I1_D);
    mtag.I2 := vaddr(VA_I2_U downto VA_I2_D);
    mtag.I3 := vaddr(VA_I3_U downto VA_I3_D);
    mtag.CTX :=  ctx;
    mtag.M :=  not (read);
    return mtag;
end;

function TLB_CreateCamFlush( data      : std_logic_vector(31 downto 0);
                             ctx       : std_logic_vector(M_CTX_SZ-1 downto 0)
                             ) return tlbcam_tfp is
variable ftag            : tlbcam_tfp;
begin
    ftag.TYP := data(FPTY_U downto FPTY_D);
    ftag.I1  := data(FPA_I1_U downto FPA_I1_D);
    ftag.I2  := data(FPA_I2_U downto FPA_I2_D);
    ftag.I3  := data(FPA_I3_U downto FPA_I3_D);
    ftag.CTX :=  ctx;
    ftag.M   := '0';
    return ftag;
end;

end;

