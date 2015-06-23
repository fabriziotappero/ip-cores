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
use work.leon_target.all;
use work.leon_device.all;
use work.leon_config.all;

package mmuconfig is

constant M_CTX_SZ       : integer := 8;
constant MMUCTX_BITS 	: integer := M_CTX_SZ * mmu_config.enable;

constant M_EN           : boolean := (mmu_config.enable = 1);   -- enable mmu
constant M_EN_DIAG      : boolean := mmu_config.tlb_diag;  --enable ASI diagnostic access
constant M_TLB_TYPE     : mmu_tlb_type := mmu_config.tlb_type;  -- eather split or combined
constant TLB_REP        : mmu_tlb_rep := mmu_config.tlb_rep;

constant M_ENT_I        : integer range 2 to 64 := mmu_config.itlbnum;   -- icache tlb entries: number
constant M_ENT_ILOG     : integer := log2(M_ENT_I);     -- icache tlb entries: address bits

constant M_ENT_D        : integer range 2 to 64 := mmu_config.dtlbnum;   -- dcache tlb entries: number
constant M_ENT_DLOG     : integer := log2(M_ENT_D);     -- dcache tlb entries: address bits

constant M_ENT_C        : integer range 2 to 64 := M_ENT_I;   -- i/dcache tlb entries: number
constant M_ENT_CLOG     : integer := M_ENT_ILOG;     -- i/dcache tlb entries: address bits

constant M_ENT_MAX : integer := 64;
constant XM_ENT_MAX_LOG : integer := log2(M_ENT_MAX);
constant M_ENT_MAX_LOG : integer := XM_ENT_MAX_LOG;

type mmu_idcache is (id_icache, id_dcache);

-- ##############################################################
--     1.0 virtual address [sparc V8: p.243,Appx.H,Figure H-4]               
--     +--------+--------+--------+---------------+
--  a) | INDEX1 | INDEX2 | INDEX3 |    OFFSET     |  
--     +--------+--------+--------+---------------+
--      31    24 23    18 17    12 11            0

constant VA_I1_SZ : integer := 8;
constant VA_I2_SZ : integer := 6;
constant VA_I3_SZ : integer := 6;
constant VA_I_SZ  : integer := VA_I1_SZ+VA_I2_SZ+VA_I3_SZ;
constant VA_I_MAX : integer := 8;

constant VA_I1_U  : integer := 31;
constant VA_I1_D  : integer := 32-VA_I1_SZ;
constant VA_I2_U  : integer := 31-VA_I1_SZ;
constant VA_I2_D  : integer := 32-VA_I1_SZ-VA_I2_SZ;
constant VA_I3_U  : integer := 31-VA_I1_SZ-VA_I2_SZ;
constant VA_I3_D  : integer := 32-VA_I_SZ;
constant VA_I_U   : integer := 31;
constant VA_I_D   : integer := 32-VA_I_SZ;
constant VA_OFF_U : integer := 31-VA_I_SZ;
constant VA_OFF_D : integer := 0;

constant VA_OFFCTX_U : integer := 31;
constant VA_OFFCTX_D : integer := 0;
constant VA_OFFREG_U : integer := 31-VA_I1_SZ;
constant VA_OFFREG_D : integer := 0;
constant VA_OFFSEG_U : integer := 31-VA_I1_SZ-VA_I2_SZ;
constant VA_OFFSEG_D : integer := 0;
constant VA_OFFPAG_U : integer := 31-VA_I_SZ;
constant VA_OFFPAG_D : integer := 0;

-- ##############################################################
--     2.0 PAGE TABE DESCRIPTOR (PTD) [sparc V8: p.247,Appx.H,Figure H-7]                             
--                                                                  
--     +-------------------------------------------------+---+---+      
--     |    Page Table Pointer (PTP)                     | 0 | 0 |      
--     +-------------------------------------------------+---+---+      
--      31                                              2  1   0        
--
--     2.1 PAGE TABE ENTRY (PTE) [sparc V8: p.247,Appx.H,Figure H-8]
--                                                                                       
--     +-----------------------------+---+---+---+-----------+---+
--     |Physical Page Number (PPN)   | C | M | R |     ACC   | ET¦   
--     +-----------------------------+---+---+---+-----------+---+
--      31                          8  7   6   5  4         2 1 0
--                                                                     
constant PTD_PTP_U : integer := 31;   -- PTD: page table pointer
constant PTD_PTP_D : integer := 2;    
constant PTD_PTP32_U : integer := 27;   -- PTD: page table pointer 32 bit
constant PTD_PTP32_D : integer := 2;    
constant PTE_PPN_U : integer := 31;   -- PTE: physical page number
constant PTE_PPN_D : integer := 8;     
constant PTE_PPN_S : integer := (PTE_PPN_U+1)-PTE_PPN_D;  -- PTE: pysical page number size
constant PTE_PPN32_U : integer := 27; -- PTE: physical page number 32 bit addr
constant PTE_PPN32_D : integer := 8;    
constant PTE_PPN32_S : integer := (PTE_PPN32_U+1)-PTE_PPN32_D;  -- PTE: pysical page number 32 bit size
constant PTE_PPN32REG_U : integer := PTE_PPN32_U;  -- PTE: pte part of merged result address
constant PTE_PPN32REG_D : integer := PTE_PPN32_U+1-VA_I1_SZ;
constant PTE_PPN32SEG_U : integer := PTE_PPN32_U;
constant PTE_PPN32SEG_D : integer := PTE_PPN32_U+1-VA_I1_SZ-VA_I2_SZ;
constant PTE_PPN32PAG_U : integer := PTE_PPN32_U;
constant PTE_PPN32PAG_D : integer := PTE_PPN32_U+1-VA_I_SZ;

constant PTE_C : integer := 7;        -- PTE: Cacheable bit
constant PTE_M : integer := 6;        -- PTE: Modified bit 
constant PTE_R : integer := 5;        -- PTE: Reference Bit - a "1" indicates an PTE 
                                       
constant PTE_ACC_U : integer := 4;    -- PTE: Access field 
constant PTE_ACC_D : integer := 2;     
constant ACC_W : integer := 2;        -- PTE::ACC : write permission
constant ACC_E : integer := 3;        -- PTE::ACC : exec permission
constant ACC_SU : integer := 4;       -- PTE::ACC : privileged
                                       
constant PT_ET_U : integer := 1;      -- PTD/PTE: PTE Type
constant PT_ET_D : integer := 0;            
constant ET_INV : std_logic_vector(1 downto 0) := "00";  
constant ET_PTD : std_logic_vector(1 downto 0) := "01";
constant ET_PTE : std_logic_vector(1 downto 0) := "10";
constant ET_RVD : std_logic_vector(1 downto 0) := "11";

constant PADDR_PTD_U : integer := 31;   
constant PADDR_PTD_D : integer := 6;

-- ##############################################################
--     3.0 TLBCAM TAG hardware representation (TTG)
--
type tlbcam_reg is record
   ET     : std_logic_vector(1 downto 0);              -- et field 
   ACC    : std_logic_vector(2 downto 0);              -- on flush/probe this will become FPTY
   M      : std_logic;                                 -- modified
   R      : std_logic;                                 -- referenced
   SU     : std_logic;                                 -- equal ACC >= 6
   VALID  : std_logic;                                  
   LVL    : std_logic_vector(1 downto 0);              -- level in pth
   I1     : std_logic_vector(7 downto 0);              -- vaddr
   I2     : std_logic_vector(5 downto 0);               
   I3     : std_logic_vector(5 downto 0);               
   CTX    : std_logic_vector(M_CTX_SZ-1 downto 0);     -- ctx number
   PPN    : std_logic_vector(PTE_PPN_S-1 downto 0);    -- physical page number
   C      : std_logic;                                 -- cachable
end record;

-- tlbcam_reg::LVL 
constant LVL_PAGE    : std_logic_vector(1 downto 0) := "00"; -- equal tlbcam_tfp::TYP FPTY_PAGE
constant LVL_SEGMENT : std_logic_vector(1 downto 0) := "01"; -- equal tlbcam_tfp::TYP FPTY_SEGMENT
constant LVL_REGION  : std_logic_vector(1 downto 0) := "10"; -- equal tlbcam_tfp::TYP FPTY_REGION
constant LVL_CTX     : std_logic_vector(1 downto 0) := "11"; -- equal tlbcam_tfp::TYP FPTY_CTX

-- ##############################################################
--     4.0 TLBCAM tag i/o for translation/flush/(probe)
--
type tlbcam_tfp is record
   TYP    : std_logic_vector(2 downto 0);        -- f/(p) type
   I1     : std_logic_vector(7 downto 0);        -- vaddr
   I2     : std_logic_vector(5 downto 0);
   I3     : std_logic_vector(5 downto 0);
   CTX    : std_logic_vector(M_CTX_SZ-1 downto 0);  -- ctx number
   M      : std_logic;
end record;

--tlbcam_tfp::TYP
constant FPTY_PAGE    : std_logic_vector(2 downto 0) := "000";  -- level 3 PTE  match I1+I2+I3
constant FPTY_SEGMENT : std_logic_vector(2 downto 0) := "001";  -- level 2/3 PTE/PTD match I1+I2
constant FPTY_REGION  : std_logic_vector(2 downto 0) := "010";  -- level 1/2/3 PTE/PTD match I1
constant FPTY_CTX     : std_logic_vector(2 downto 0) := "011";  -- level 0/1/2/3 PTE/PTD ctx
constant FPTY_N       : std_logic_vector(2 downto 0) := "100";  -- entire tlb

-- ##############################################################
--     5.0 MMU Control Register [sparc V8: p.253,Appx.H,Figure H-10]
--
--     +-------+-----+------------------+-----+-------+--+--+      
--     |  IMPL | VER |        SC        | PSO | resvd |NF|E |      
--     +-------+-----+------------------+-----+-------+--+--+
--      31  28  27 24 23               8   7   6     2  1  0
--      
--     MMU Context Pointer [sparc V8: p.254,Appx.H,Figure H-11]                      
--     +-------------------------------------------+--------+
--     |         Context Table Pointer             |  resvd |      
--     +-------------------------------------------+--------+
--      31                                        2 1      0                
--
--     MMU Context Number [sparc V8: p.255,Appx.H,Figure H-12]                                                          
--     +----------------------------------------------------+
--     |              Context Table Pointer                 |      
--     +----------------------------------------------------+
--      31                                                 0
--      
--     fault status/address register [sparc V8: p.256,Appx.H,Table H-13/14] 
--     +------------+-----+---+----+----+-----+----+
--     |   reserved | EBE | L | AT | FT | FAV | OW |     
--     +------------+-----+---+----+----+-----+----+
--     31         18 17 10 9 8 7  5 4  2   1    0
--
--     +----------------------------------------------------+
--     |              fault address register                |      
--     +----------------------------------------------------+
--      31                                                 0                

constant MMCTRL_CTXP_SZ : integer := 30;
constant MMCTRL_PTP32_U : integer := 25;   
constant MMCTRL_PTP32_D : integer := 0;   

constant MMCTRL_E  : integer := 0;
constant MMCTRL_NF : integer := 1;
constant MMCTRL_PSO : integer := 7;
constant MMCTRL_SC_U : integer := 23;
constant MMCTRL_SC_D : integer := 8;
constant MMCTRL_VER_U : integer := 27;
constant MMCTRL_VER_D : integer := 24;
constant MMCTRL_IMPL_U : integer := 31;
constant MMCTRL_IMPL_D : integer := 28;
constant MMCTRL_TLBDIS : integer := 31;

constant MMCTXP_U : integer := 31;
constant MMCTXP_D : integer := 2;

constant MMCTXNR_U : integer := M_CTX_SZ-1;
constant MMCTXNR_D : integer := 0;

constant FS_SZ : integer := 18;  -- fault status size

constant FS_EBE_U : integer := 17;
constant FS_EBE_D : integer := 10;

constant FS_L_U : integer := 9;
constant FS_L_D : integer := 8;
constant FS_L_CTX : std_logic_vector(1 downto 0) := "00";
constant FS_L_L1 : std_logic_vector(1 downto 0) := "01";
constant FS_L_L2 : std_logic_vector(1 downto 0) := "10";
constant FS_L_L3 : std_logic_vector(1 downto 0) := "11";

constant FS_AT_U : integer := 7;
constant FS_AT_D : integer := 5;
constant FS_AT_LS : natural := 7;       --L=0 S=1
constant FS_AT_ID : natural := 6;       --D=0 I=1
constant FS_AT_SU : natural := 5;       --U=0 SU=1
constant FS_AT_LUDS : std_logic_vector(2 downto 0) := "000";
constant FS_AT_LSDS : std_logic_vector(2 downto 0) := "001";
constant FS_AT_LUIS : std_logic_vector(2 downto 0) := "010";
constant FS_AT_LSIS : std_logic_vector(2 downto 0) := "011";
constant FS_AT_SUDS : std_logic_vector(2 downto 0) := "100";
constant FS_AT_SSDS : std_logic_vector(2 downto 0) := "101";
constant FS_AT_SUIS : std_logic_vector(2 downto 0) := "110";
constant FS_AT_SSIS : std_logic_vector(2 downto 0) := "111";

constant FS_FT_U : integer := 4;
constant FS_FT_D : integer := 2;
constant FS_FT_NONE : std_logic_vector(2 downto 0) := "000";
constant FS_FT_INV : std_logic_vector(2 downto 0)  := "001";
constant FS_FT_PRO : std_logic_vector(2 downto 0)  := "010";
constant FS_FT_PRI : std_logic_vector(2 downto 0)  := "011";
constant FS_FT_TRANS : std_logic_vector(2 downto 0):= "110";
constant FS_FT_BUS : std_logic_vector(2 downto 0)  := "101";
constant FS_FT_INT : std_logic_vector(2 downto 0)  := "110";
constant FS_FT_RVD : std_logic_vector(2 downto 0)  := "111";

constant FS_FAV : natural := 1;
constant FS_OW : natural := 0;

--# mmu ctrl reg
type mmctrl_type1 is record
  e       : std_logic;				        -- enable
  nf      : std_logic;				        -- no fault
  pso     : std_logic;				        -- partial store order
--  pre     : std_logic;                            -- pretranslation source
--  pri     : std_logic;                            -- i/d priority 
  ctx     : std_logic_vector(M_CTX_SZ-1 downto 0);-- context nr
  ctxp    : std_logic_vector(MMCTRL_CTXP_SZ-1 downto 0);  -- context table pointer
  tlbdis  : std_logic;                            -- tlb disabled
  bar     : std_logic_vector(1 downto 0);         -- preplace barrier
end record;

--# fault status reg
type mmctrl_fs_type is record
  ow    : std_logic;				  
  fav   : std_logic;				  
  ft    : std_logic_vector(2 downto 0);	          -- fault type
  at_ls : std_logic;                              -- access type, load/store
  at_id : std_logic;                              -- access type, i/dcache
  at_su : std_logic;                              -- access type, su/user
  l     : std_logic_vector(1 downto 0);           -- level 
  ebe   : std_logic_vector(7 downto 0);            
end record;

type mmctrl_type2 is record
  fs    : mmctrl_fs_type;
  valid : std_logic;
  fa    : std_logic_vector(VA_I_SZ-1 downto 0);   -- fault address register
end record;

-- ##############################################################
--     6. Virtual Flush/Probe address [sparc V8: p.249,Appx.H,Figure H-9]
--     +---------------------------------------+--------+-------+
--     |   VIRTUAL FLUSH&Probe Address (VFPA)  |  type  |  rvd  |      
--     +---------------------------------------+--------+-------+  
--      31                                   12 11     8 7      0         
--     
--
subtype FPA is natural range  31 downto 12;
constant FPA_I1_U : integer := 31;
constant FPA_I1_D : integer := 24;
constant FPA_I2_U : integer := 23;
constant FPA_I2_D : integer := 18;
constant FPA_I3_U : integer := 17;
constant FPA_I3_D : integer := 12;
constant FPTY_U : integer := 10;        -- only 3 bits
constant FPTY_D : integer := 8;

-- ##############################################################
--     7. control register virtual address [sparc V8: p.253,Appx.H,Table H-5] 
--     +---------------------------------+-----+--------+
--     |                                 | CNR |  rsvd  |      
--     +---------------------------------+-----+--------+  
--      31                                10  8 7      0
      
constant CNR_U        : integer := 10;
constant CNR_D        : integer := 8;    
constant CNR_CTRL     : std_logic_vector(2 downto 0) := "000";
constant CNR_CTXP     : std_logic_vector(2 downto 0) := "001";
constant CNR_CTX      : std_logic_vector(2 downto 0) := "010";
constant CNR_F        : std_logic_vector(2 downto 0) := "011";
constant CNR_FADDR    : std_logic_vector(2 downto 0) := "100";

-- ##############################################################
--     8. Precise flush (ASI 0x10-14) [sparc V8: p.266,Appx.I]
--        supported: ASI_FLUSH_PAGE
--                   ASI_FLUSH_CTX
                     
constant PFLUSH_PAGE : std_logic := '0';
constant PFLUSH_CTX  : std_logic := '1';

-- ##############################################################
--     9. Diagnostic access
--        
constant DIAGF_LVL_U : integer := 1;
constant DIAGF_LVL_D : integer := 0;
constant DIAGF_WR    : integer := 3;
constant DIAGF_HIT   : integer := 4;
constant DIAGF_CTX_U : integer := 12;
constant DIAGF_CTX_D : integer := 5;
constant DIAGF_VALID : integer := 13;
end mmuconfig;                          



-- Konrad Eisele<eiselekd@web.de> ,2002  

library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use work.mmuconfig.all;

package mmulib is
  
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

package body mmulib is

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

