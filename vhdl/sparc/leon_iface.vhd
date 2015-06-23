



----------------------------------------------------------------------------
--  This file is a part of the LEON VHDL model
--  Copyright (C) 1999  European Space Agency (ESA)
--
--  This library is free software; you can redistribute it and/or
--  modify it under the terms of the GNU Lesser General Public
--  License as published by the Free Software Foundation; either
--  version 2 of the License, or (at your option) any later version.
--
--  See the file COPYING.LGPL for the full details of the license.


-----------------------------------------------------------------------------
-- Entity:      iface
-- File:        iface.vhd
-- Author:      Jiri Gaisler - ESA/ESTEC
-- Description: Package with type declarations for module interconnections
------------------------------------------------------------------------------
  
library IEEE;
use IEEE.std_logic_1164.all;
use work.leon_target.all;
use work.leon_config.all;
use work.mmuconfig.all;
use work.sparcv8.all;

package leon_iface is


subtype clk_type is std_logic;


------------------------------------------------------------------------------
-- Add I/Os for custom peripherals in the records below
------------------------------------------------------------------------------
-- peripheral inputs
-- peripheral outputs
type io_out_type is record
  piol             : std_logic_vector(15 downto 0); -- I/O port outputs
  piodir           : std_logic_vector(15 downto 0); -- I/O port direction
  errorn  : std_logic;				    -- CPU in error mode
  wdog 	  : std_logic;				    -- watchdog output

  pci_arb_gnt_n    : std_logic_vector(0 to 3);
end record;
------------------------------------------------------------------------------

-- IU register file signals

type rf_in_type is record
  rd1addr 	: std_logic_vector(RABITS-1 downto 0); -- read address 1
  rd2addr 	: std_logic_vector(RABITS-1 downto 0); -- read address 2
  wraddr 	: std_logic_vector(RABITS-1 downto 0); -- write address
  wrdata 	: std_logic_vector(RDBITS-1 downto 0);     -- write data
  ren1          : std_logic;			     -- read 1 enable
  ren2          : std_logic;			     -- read 2 enable
  wren          : std_logic;			     -- write enable

end record;

type rf_out_type is record
  data1    	: std_logic_vector(RDBITS-1 downto 0); -- read data 1
  data2    	: std_logic_vector(RDBITS-1 downto 0); -- read data 2
end record;

-- co-processor register file signals

type rf_cp_in_type is record
  rd1addr 	: std_logic_vector(3 downto 0); -- read address 1
  rd2addr 	: std_logic_vector(3 downto 0); -- read address 2
  wraddr 	: std_logic_vector(3 downto 0); -- write address
  wrdata 	: std_logic_vector(RDBITS-1 downto 0);     -- write data
  ren1          : std_logic;			     -- read 1 enable
  ren2          : std_logic;			     -- read 2 enable
  wren          : std_logic;			     -- write enable

end record;

type rf_cp_out_type is record
  data1    	: std_logic_vector(RDBITS-1 downto 0); -- read data 1
  data2    	: std_logic_vector(RDBITS-1 downto 0); -- read data 2
end record;

-- instruction cache diagnostic access inputs

type icdiag_in_type is record
  addr             : std_logic_vector(31 downto 0); -- memory stage address
  enable           : std_logic;
  read             : std_logic;
  tag              : std_logic;
  ctx              : std_logic;
  flush            : std_logic;
  pflush           : std_logic;
  pflushaddr       : std_logic_vector(VA_I_U downto VA_I_D); 
  pflushtyp        : std_logic;
end record;

-- data cache controller inputs

type dcache_in_type is record
  asi              : std_logic_vector(7 downto 0); -- ASI for load/store
  maddress         : std_logic_vector(31 downto 0); -- memory stage address
  eaddress         : std_logic_vector(31 downto 0); -- execute stage address
  edata            : std_logic_vector(31 downto 0); -- execute stage data
  size             : std_logic_vector(1 downto 0);
  signed           : std_logic;
  enaddr           : std_logic;
  eenaddr          : std_logic;
  nullify          : std_logic;
  lock             : std_logic;
  read             : std_logic;
  write            : std_logic;
  flush            : std_logic;
  dsuen            : std_logic;
  msu              : std_logic;                   -- memory stage supervisor
  esu              : std_logic;                   -- execution stage supervisor
end record;

-- data cache controller outputs

type dcache_out_type is record
  data             : std_logic_vector(31 downto 0); -- Data bus address
  mexc             : std_logic;		-- memory exception
  hold             : std_logic;
  mds              : std_logic;
  werr             : std_logic;		-- memory write error
  icdiag           : icdiag_in_type;
  dsudata          : std_logic_vector(31 downto 0);
end record;

type icache_in_type is record
  rpc              : std_logic_vector(31 downto PCLOW); -- raw address (npc)
  fpc              : std_logic_vector(31 downto PCLOW); -- latched address (fpc)
  dpc              : std_logic_vector(31 downto PCLOW); -- latched address (dpc)
  rbranch          : std_logic;			-- Instruction branch
  fbranch          : std_logic;			-- Instruction branch
  nullify          : std_logic;			-- instruction nullify
  su               : std_logic;			-- super-user
  flush            : std_logic;			-- flush icache
end record;

type icache_out_type is record
  data             : std_logic_vector(31 downto 0);
  exception        : std_logic;
  hold             : std_logic;
  flush            : std_logic;			-- flush in progress
  diagrdy          : std_logic;			-- diagnostic access ready
  diagdata         : std_logic_vector(31 downto 0); -- diagnostic data
  mds              : std_logic;			-- memory data strobe
end record;

type memory_ic_in_type is record
  address          : std_logic_vector(31 downto 0); -- memory address
  burst            : std_logic;			-- burst request
  req              : std_logic;			-- memory cycle request
  su               : std_logic;			-- supervisor address space
  flush            : std_logic;			-- flush in progress

end record;

type memory_ic_out_type is record
  data             : std_logic_vector(31 downto 0); -- memory data
  ready            : std_logic;			    -- cycle ready
  grant            : std_logic;			    -- 
  retry            : std_logic;			    -- 
  mexc             : std_logic;			    -- memory exception
  burst            : std_logic;			    -- memory burst enable
  ics              : std_logic_vector(1 downto 0); -- icache state (from CCR)
  cache            : std_logic;		-- cacheable data

end record;

type memory_dc_in_type is record
  address          : std_logic_vector(31 downto 0); 
  data             : std_logic_vector(31 downto 0);
  asi              : std_logic_vector(3 downto 0); -- ASI for load/store
  size             : std_logic_vector(1 downto 0);
  burst            : std_logic;
  read             : std_logic;
  req              : std_logic;
  flush            : std_logic;			-- flush in progress
  lock             : std_logic;
  su               : std_logic;

end record;

type memory_dc_out_type is record
  data             : std_logic_vector(31 downto 0); -- memory data
  ready            : std_logic;			    -- cycle ready
  grant            : std_logic;			    -- 
  retry            : std_logic;			    -- 
  mexc             : std_logic;			    -- memory exception
  werr             : std_logic;			    -- memory write error
  dcs              : std_logic_vector(1 downto 0);
  iflush           : std_logic;		-- flush icache (from CCR)
  dflush           : std_logic;		-- flush dcache (from CCR)
  cache            : std_logic;		-- cacheable data
  dsnoop           : std_logic;		-- snoop enable
  ba               : std_logic;		-- bus active (used for snooping)
  bg               : std_logic;		-- bus grant  (used for snooping)

end record;



type ahbstat_out_type is record
  ahberr           : std_logic;
end record;



type itram_in_type is record
  tag    	: std_logic_vector(ITAG_BITS - ILINE_SIZE - 1 downto 0);
  lrr           : std_logic;
  lock          : std_logic;
  valid  	: std_logic_vector(ILINE_SIZE -1 downto 0);
  enable	: std_logic;
  ctx           : std_logic_vector(M_CTX_SZ-1 downto 0);    --#mmu: ctx number
  write		: std_logic_vector(0 to MAXSETS-1);
  flush  	: std_logic;

end record;

type itram_out_single_type is record
  tag    	: std_logic_vector(ITAG_BITS - ILINE_SIZE -1 downto 0);
  lrr           : std_logic;
  lock          : std_logic;
  valid  	: std_logic_vector(ILINE_SIZE -1 downto 0);
  ctx           : std_logic_vector(M_CTX_SZ-1 downto 0);    --#mmu: ctx number
end record;

type itram_out_type is  array (0 to MAXSETS-1) of itram_out_single_type;

type idram_in_type is record
  address	: std_logic_vector((IOFFSET_BITS + ILINE_BITS -1) downto 0);
  data   	: std_logic_vector(31 downto 0);
  enable	: std_logic;
  write	        : std_logic_vector(0 to MAXSETS-1);

end record;

type idram_out_single_type is record
  data   	: std_logic_vector(31 downto 0);

end record;

type idram_out_type is array (0 to MAXSETS-1) of idram_out_single_type;

type dtram_in_type is record
  tag    	: std_logic_vector(DTAG_BITS - DLINE_SIZE - 1 downto 0);
  lrr           : std_logic_vector(0 to MAXSETS-1);
  lock          : std_logic_vector(0 to MAXSETS-1);
  valid  	: std_logic_vector(DLINE_SIZE -1 downto 0);
  enable	: std_logic;
  write	        : std_logic_vector(0 to MAXSETS-1);
  ctx           : std_logic_vector(M_CTX_SZ-1 downto 0);  --#mmu: ctx number
  flush  	: std_logic;

end record;

type dtram_out_single_type is record
  tag    	: std_logic_vector(DTAG_BITS - DLINE_SIZE -1 downto 0);
  lrr           : std_logic;
  lock          : std_logic;
  valid  	: std_logic_vector(DLINE_SIZE -1 downto 0);
  ctx           : std_logic_vector(M_CTX_SZ-1 downto 0);  --#mmu: ctx number
end record;

type dtram_out_type is array (0 to MAXSETS-1) of dtram_out_single_type;

type dtramsn_in_type is record
  enable	: std_logic;
  write		: std_logic_vector(0 to MAXSETS-1);
  address	: std_logic_vector((DOFFSET_BITS-1) downto 0);
  tag           : std_logic_vector(DTAG_BITS - DLINE_SIZE -1 downto 0);

end record;

type dtramsn_out_single_type is record
  tag    	: std_logic_vector(DTAG_BITS - DLINE_SIZE -1 downto 0);
end record;

type dtramsn_out_type is array (0 to MAXSETS-1) of dtramsn_out_single_type;

type ddram_in_type is record
  address	: std_logic_vector((DOFFSET_BITS + DLINE_BITS -1) downto 0);
  data   	: std_logic_vector(31 downto 0);
  enable	: std_logic;
  write		: std_logic_vector(0 to MAXSETS-1);

end record;

type ddram_out_single_type is record
  data   	: std_logic_vector(31 downto 0);

end record;

type ddram_out_type is array (0 to MAXSETS-1) of ddram_out_single_type;

type ldram_in_type is record
  address	: std_logic_vector(LOCAL_RAM_BITS + 1 downto 2);
  enable	: std_logic;
  read 		: std_logic;
  write		: std_logic;
end record;

type icram_in_type is record
  itramin	: itram_in_type;
  idramin	: idram_in_type;
end record;

type icram_out_type is record
  itramout	: itram_out_type;
  idramout	: idram_out_type;
end record;

type dcram_in_type is record
  dtramin	: dtram_in_type;
  ddramin	: ddram_in_type;
  ldramin	: ldram_in_type;
  dtraminsn     : dtramsn_in_type;
end record;

type dcram_out_type is record
  dtramout	: dtram_out_type;
  ddramout	: ddram_out_type;
  dtramoutsn    : dtramsn_out_type;
end record;

type cram_in_type is record
  icramin	: icram_in_type;
  dcramin	: dcram_in_type;
end record;

type cram_out_type is record
  icramout	: icram_out_type;
  dcramout	: dcram_out_type;
end record;



-- iu pipeline control type (defined here to be visible to debug and coprocessor)

type pipeline_control_type is record
  inst   : std_logic_vector(31 downto 0);     -- instruction word
  pc     : std_logic_vector(31 downto PCLOW);     -- program counter
  annul  : std_logic;			      -- instruction annul
  cnt    : std_logic_vector(1 downto 0);      -- cycle number (multi-cycle inst)
  ld     : std_logic;			      -- load cycle
  pv     : std_logic;			      -- PC valid
  rett   : std_logic;			      -- RETT indicator
  trap   : std_logic;			      -- trap pending flag
  tt     : std_logic_vector(5 downto 0);      -- trap type
  rd     : std_logic_vector(RABITS-1 downto 0); -- destination register address
end record;
  
-- Stucture for FPU/CP control
type cp_debug_in_type is record
  daddr      : std_logic_vector(4 downto 0);
  dread_fsr  : std_logic;
  dwrite_fsr : std_logic;  
  denable    : std_logic;
  dwrite     : std_logic;
  ddata      : std_logic_vector(31 downto 0);
end record;                           

type cp_debug_out_type is record
  ddata       : std_logic_vector(63 downto 0);
  wr_fp       : std_logic;
  wr2_fp      : std_logic;
  write_fpreg : std_logic_vector(1 downto 0);
  write_fsr   : std_logic;
  fpreg       : std_logic_vector(3 downto 0);
  op          : std_logic_vector(31 downto 0);
  pc          : std_logic_vector(31 downto PCLOW);
end record;

type cp_in_type is record
  flush  	: std_logic;			  -- pipeline flush
  exack    	: std_logic;			  -- CP exception acknowledge
  fdata         : std_logic_vector(31 downto 0);  -- fetch stage data
  frdy          : std_logic;                      -- fetch stage data ready  
  dannul   	: std_logic;			  -- decode stage annul
  dtrap    	: std_logic;			  -- decode stage trap
  dcnt          : std_logic_vector(1 downto 0);     -- decode stage cycle counter
  dinst         : std_logic_vector(31 downto 0);     -- decode stage instruction
  ex       	: pipeline_control_type;	  -- iu pipeline ctrl (ex)
  me       	: pipeline_control_type;	  -- iu pipeline ctrl (me)
  wr       	: pipeline_control_type;	  -- iu pipeline ctrl (wr)
  lddata        : std_logic_vector(31 downto 0);     -- load data
  debug         : cp_debug_in_type;               -- CP debug signals    
end record;

type cp_out_type is record
  data          : std_logic_vector(31 downto 0); -- store data
  exc  	        : std_logic;			 -- CP exception
  cc            : std_logic_vector(1 downto 0);  -- CP condition codes
  ccv  	        : std_logic;			 -- CP condition codes valid
  holdn	        : std_logic;			 -- CP pipeline hold
  ldlock        : std_logic;			 -- CP load/store interlock
  debug         : cp_debug_out_type;             -- CP debug signals
end record;


-- iu debug port
type iu_debug_in_type is record
  dsuen   : std_logic;  -- DSU enable
  dbreak  : std_logic;  -- debug break-in
  btrapa  : std_logic;	-- break on IU trap
  btrape  : std_logic;	-- break on IU trap
  berror  : std_logic;	-- break on IU error mode
  bwatch  : std_logic;	-- break on IU watchpoint
  bsoft   : std_logic;	-- break on software breakpoint (TA 1)
  rerror  : std_logic;	-- reset processor error mode
  step    : std_logic;	-- single step
  denable : std_logic; 	-- diagnostic register access enable
  dwrite   : std_logic;  -- read/write
  daddr   : std_logic_vector(21 downto 2); -- diagnostic address
  ddata   : std_logic_vector(31 downto 0); -- diagnostic data
end record;

type iu_debug_out_type is record
  clk   : std_logic;
  rst   : std_logic;
  holdn : std_logic;
  ex	: pipeline_control_type;
  me	: pipeline_control_type;
  wr	: pipeline_control_type;
  write_reg  : std_logic;
  mresult : std_logic_vector(31 downto 0);
  result  : std_logic_vector(31 downto 0);
  trap    : std_logic;
  error   : std_logic;
  dmode   : std_logic;
  dmode2  : std_logic;
  vdmode  : std_logic;
  dbreak  : std_logic;
  tt      : std_logic_vector(7 downto 0);
  psrtt   : std_logic_vector(7 downto 0);
  psrpil  : std_logic_vector(3 downto 0);
  diagrdy : std_logic;
  ddata   : std_logic_vector(31 downto 0);   -- diagnostic data
  fpdbg   : cp_debug_out_type;
end record;

type iu_in_type is record
  irl              : std_logic_vector(3 downto 0); -- interrupt request level
  debug   : iu_debug_in_type;
end record;

type iu_out_type is record
  error   : std_logic;
  intack  : std_logic;
  irqvec  : std_logic_vector(3 downto 0);
  ipend   : std_logic;
  debug	  : iu_debug_out_type;
end record;

-- Meiko FPU interface
type fpu_in_type is record
    FpInst     : std_logic_vector(9 downto 0);
    FpOp       : std_logic;
    FpLd       : std_logic;
    Reset      : std_logic;
    fprf_dout1 : std_logic_vector(63 downto 0);
    fprf_dout2 : std_logic_vector(63 downto 0);
    RoundingMode : std_logic_vector(1 downto 0);
    ss_scan_mode : std_logic;
    fp_ctl_scan_in : std_logic;
    fpuholdn   : std_logic;
end record;

type fpu_out_type is record
    FpBusy     : std_logic;
    FracResult : std_logic_vector(54 downto 3);
    ExpResult  : std_logic_vector(10 downto 0);
    SignResult : std_logic;
    SNnotDB    : std_logic;
    Excep      : std_logic_vector(5 downto 0);
    ConditionCodes : std_logic_vector(1 downto 0);
    fp_ctl_scan_out : std_logic;
end record;

type cp_unit_in_type is record		-- coprocessor execution unit input
  op1      : std_logic_vector (63 downto 0); -- operand 1
  op2      : std_logic_vector (63 downto 0); -- operand 2
  opcode   : std_logic_vector (9 downto 0);  -- opcode
  start    : std_logic;		             -- start
  load     : std_logic;		             -- load operands
  flush    : std_logic;		             -- cancel operation
end record;

type cp_unit_out_type is record	-- coprocessor execution unit output
  res      : std_logic_vector (63 downto 0); -- result
  cc       : std_logic_vector (1 downto 0);  -- condition codes
  exc      : std_logic_vector (5 downto 0);  -- exception
  busy     : std_logic;		             -- eu busy  
end record;

-- pci_[in|out]_type groups all EXTERNAL pci ports in unidirectional form
-- as well as the required enable signals for the pads
type pci_in_type is record

  pci_rst_in_n 	   : std_logic;
  pci_gnt_in_n 	   : std_logic;
  pci_idsel_in 	   : std_logic;
 
  pci_adin 	   : std_logic_vector(31 downto 0);
  pci_cbein_n 	   : std_logic_vector(3 downto 0);
  pci_frame_in_n   : std_logic;
  pci_irdy_in_n    : std_logic;
  pci_trdy_in_n    : std_logic;
  pci_devsel_in_n  : std_logic;
  pci_stop_in_n    : std_logic;
  pci_lock_in_n    : std_logic;
  pci_perr_in_n    : std_logic;
  pci_serr_in_n    : std_logic;
  pci_par_in 	   : std_logic;
  pci_host   	   : std_logic;
  pci_66       	   : std_logic;
  pme_status   	   : std_logic;

end record;


type pci_out_type is record

  pci_aden_n 	   : std_logic_vector(31 downto 0);
  pci_cbe0_en_n    : std_logic;
  pci_cbe1_en_n    : std_logic;
  pci_cbe2_en_n    : std_logic;
  pci_cbe3_en_n    : std_logic;
  
  pci_frame_en_n   : std_logic;
  pci_irdy_en_n    : std_logic;
  pci_trdy_en_n    : std_logic;
  pci_devsel_en_n    : std_logic;
  pci_stop_en_n    : std_logic;
  pci_ctrl_en_n    : std_logic;
  pci_perr_en_n    : std_logic;
  pci_par_en_n 	   : std_logic;
  pci_req_en_n 	   : std_logic;
  pci_lock_en_n    : std_logic;
  pci_serr_en_n    : std_logic;
  pci_int_en_n     : std_logic;

  pci_req_out_n    : std_logic;
  pci_adout 	   : std_logic_vector(31 downto 0);
  pci_cbeout_n 	   : std_logic_vector(3 downto 0);
  pci_frame_out_n  : std_logic;
  pci_irdy_out_n   : std_logic;
  pci_trdy_out_n   : std_logic;
  pci_devsel_out_n : std_logic;
  pci_stop_out_n   : std_logic;
  pci_perr_out_n   : std_logic;
  pci_serr_out_n   : std_logic;
  pci_par_out 	   : std_logic;
  pci_lock_out_n   : std_logic;
  power_state  	   : std_logic_vector(1 downto 0);
  pme_enable   	   : std_logic;
  pme_clear    	   : std_logic;
  pci_int_out_n	   : std_logic;

end record;

type div_in_type is record
  op1              : std_logic_vector(32 downto 0); -- operand 1
  op2              : std_logic_vector(32 downto 0); -- operand 2
  y                : std_logic_vector(32 downto 0); -- Y (MSB divident)
  flush            : std_logic;
  signed           : std_logic;
  start            : std_logic;
end record;

type div_out_type is record
  ready           : std_logic;
  icc             : std_logic_vector(3 downto 0); -- ICC
  result          : std_logic_vector(31 downto 0); -- div result
end record;

type mul_in_type is record
  op1              : std_logic_vector(32 downto 0); -- operand 1
  op2              : std_logic_vector(32 downto 0); -- operand 2
  flush            : std_logic;
  signed           : std_logic;
  start            : std_logic;
  mac              : std_logic;
  y                : std_logic_vector(7 downto 0); -- Y (MSB MAC register)
  asr18           : std_logic_vector(31 downto 0); -- LSB MAC register
end record;

type mul_out_type is record
  ready           : std_logic;
  icc             : std_logic_vector(3 downto 0); -- ICC
  result          : std_logic_vector(63 downto 0); -- mul result
end record;

type ahb_dma_in_type is record
  address         : std_logic_vector(31 downto 0);
  wdata           : std_logic_vector(31 downto 0);
  start           : std_logic;
  burst           : std_logic;
  write           : std_logic;
  size            : std_logic_vector(1 downto 0);
end record;

type ahb_dma_out_type is record
  start           : std_logic;
  active          : std_logic;
  ready           : std_logic;
  retry           : std_logic;
  mexc            : std_logic;
  haddr           : std_logic_vector(9 downto 0);
  rdata           : std_logic_vector(31 downto 0);
end record;

type actpci_be_in_type is record
  mem_ad_int      : std_logic_vector(31 downto 0);
  mem_data        : std_logic_vector(31 downto 0);
  dp_done         : std_logic;
  dp_start        : std_logic;
  rd_be_now       : std_logic;
  rd_cyc          : std_logic;
  wr_be_now       : std_logic_vector(3 downto 0);
  wr_cyc          : std_logic;
  bar0_mem_cyc    : std_logic;
  busy            : std_logic_vector(3 downto 0);
  master_active   : std_logic;
  be_gnt          : std_logic;
end record;

type actpci_be_out_type is record
  rd_be_rdy       : std_logic;
  wr_be_rdy       : std_logic;
  error           : std_logic;
  busy            : std_logic;
  mem_data        : std_logic_vector(31 downto 0);
  cs_controln     : std_logic;
  rd_controln     : std_logic;
  wr_controln     : std_logic;
  control_add     : std_logic_vector(1 downto 0);
  ext_intn        : std_logic;
  be_req          : std_logic;
end record;

type dsu_in_type is record
  dsuen           : std_logic;
  dsubre          : std_logic;
end record;

type dsu_out_type is record
  dsuact          : std_logic;
  ntrace          : std_logic;
  freezetime      : std_logic;
  lresp           : std_logic;
  dresp           : std_logic;
  dsuen           : std_logic;
  dsubre          : std_logic;
end record;

type dcom_in_type is record
  dsurx           : std_logic;
end record;

type dcom_out_type is record
  dsutx           : std_logic;
end record;

type dsuif_in_type is record
  dsui            : dsu_in_type;
  dcomi           : dcom_in_type;
end record;

type dsuif_out_type is record
  dsuo            : dsu_out_type;
  dcomo           : dcom_out_type;
end record;

type dcom_uart_in_type is record
  rxd   	: std_logic;
  read    	: std_logic;
  write   	: std_logic;
  data		: std_logic_vector(7 downto 0);
  dsuen   	: std_logic;
end record;

type dcom_uart_out_type is record
  txd   	: std_logic;
  dready 	: std_logic;
  tsempty	: std_logic;
  thempty	: std_logic;
  lock    	: std_logic;
  enable 	: std_logic;
  data		: std_logic_vector(7 downto 0);
end record;

type tracebuf_in_type is record
  addr           : std_logic_vector(TBUFABITS downto 0);
  data           : std_logic_vector(127 downto 0);
  enable         : std_logic;
  write          : std_logic_vector(3 downto 0);
end record;

type tracebuf_out_type is record
  data          : std_logic_vector(127 downto 0);
end record;

type dsumem_in_type is record
  pbufi  : tracebuf_in_type;
  abufi  : tracebuf_in_type;
end record;

type dsumem_out_type is record
  pbufo  : tracebuf_out_type;
  abufo  : tracebuf_out_type;
end record;

type eth_in_type is record
  tx_clk : std_logic;
  rx_clk : std_logic;
  rxd    : std_logic_vector(3 downto 0);   
  rx_dv  : std_logic; 
  rx_er  : std_logic; 
  rx_col : std_logic;
  rx_crs : std_logic;
  mdio_i : std_logic; 
end record;

type eth_out_type is record
  reset   : std_logic;
  txd     : std_logic_vector(3 downto 0);   
  tx_en   : std_logic; 
  tx_er   : std_logic; 
  mdc     : std_logic;    
  mdio_o  : std_logic; 
  mdio_oe : std_logic;
end record;

type clkgen_in_type is record
  pllref  : std_logic;			-- optional reference for PLL
  pllrst  : std_logic;			-- optional reset for PLL
  pllctrl : std_logic_vector(1 downto 0);  -- optional control for PLL
end record;

type clkgen_out_type is record
  clklock : std_logic;
  pcilock : std_logic;
end record;

-- mmu i/o

type mmuidc_data_in_type is record
  data             : std_logic_vector(31 downto 0);
  su               : std_logic;
  read             : std_logic;
  isid             : mmu_idcache;
end record;

type mmuidc_data_out_type is record
  finish           : std_logic;
  data             : std_logic_vector(31 downto 0);
  cache            : std_logic;
  accexc           : std_logic;
end record;

type mmudc_in_type is record
  trans_op         : std_logic; 
  transdata        : mmuidc_data_in_type;
  
  -- dcache extra signals
  flush_op         : std_logic;
  diag_op          : std_logic;

  fsread           : std_logic;
  mmctrl1          : mmctrl_type1;
end record;

type mmudc_out_type is record
  grant            : std_logic;
  transdata        : mmuidc_data_out_type;
  -- dcache extra signals
  mmctrl2          : mmctrl_type2;
end record;

type mmuic_in_type is record
  trans_op         : std_logic; 
  transdata        : mmuidc_data_in_type;
end record;

type mmuic_out_type is record
  grant            : std_logic;
  transdata        : mmuidc_data_out_type;
end record;

type mmutlbcam_in_type is record
  tagin    : tlbcam_tfp;
  tagwrite : tlbcam_reg;
  trans_op : std_logic;
  flush_op : std_logic;
  write_op : std_logic;
  mmuen    : std_logic;
  mset     : std_logic;
end record;
type mmutlbcami_a is array (natural range <>) of mmutlbcam_in_type;

type mmutlbcam_out_type is record
  pteout   : std_logic_vector(31 downto 0);
  LVL      : std_logic_vector(1 downto 0);    -- level in pth
  hit      : std_logic;
  ctx      : std_logic_vector(M_CTX_SZ-1 downto 0);    -- for diagnostic access
  valid    : std_logic;                                -- for diagnostic access
  vaddr    : std_logic_vector(31 downto 0);            -- for diagnostic access
  NEEDSYNC : std_logic;
end record;
type mmutlbcamo_a is array (natural range <>) of mmutlbcam_out_type;

--#lrue i/o
type mmulrue_in_type is record
  touch        : std_logic;
  pos          : std_logic_vector(M_ENT_MAX_LOG-1 downto 0);
  clear        : std_logic;
  
  left         : std_logic_vector(M_ENT_MAX_LOG-1 downto 0);
  fromleft     : std_logic;
  right        : std_logic_vector(M_ENT_MAX_LOG-1 downto 0);
  fromright    : std_logic;
end record;
type mmulruei_a is array (natural range <>) of mmulrue_in_type;

type mmulrue_out_type is record
  pos          : std_logic_vector(M_ENT_MAX_LOG-1 downto 0);
  movetop      : std_logic;
end record;
type mmulrueo_a is array (natural range <>) of mmulrue_out_type;

--#lru i/o
type mmulru_in_type is record
  touch     : std_logic;
  touchmin  : std_logic;
  pos       : std_logic_vector(M_ENT_MAX_LOG-1 downto 0);
  mmctrl1   : mmctrl_type1;
end record;

type mmulru_out_type is record
  pos      : std_logic_vector(M_ENT_MAX_LOG-1 downto 0);
end record;

--#mmu: tw i/o
type memory_mm_in_type is record
  address          : std_logic_vector(31 downto 0); 
  data             : std_logic_vector(31 downto 0);
  size             : std_logic_vector(1 downto 0);
  burst            : std_logic;
  read             : std_logic;
  req              : std_logic;
  lock             : std_logic;
end record;

type memory_mm_out_type is record
  data             : std_logic_vector(31 downto 0); -- memory data
  ready            : std_logic;			    -- cycle ready
  grant            : std_logic;			    -- 
  retry            : std_logic;			    -- 
  mexc             : std_logic;			    -- memory exception
  werr             : std_logic;			    -- memory write error
  cache            : std_logic;		            -- cacheable data
end record;

type mmutw_in_type is record
  walk_op_ur       : std_logic;
  areq_ur          : std_logic;
  
  data             : std_logic_vector(31 downto 0);
  adata            : std_logic_vector(31 downto 0);
  aaddr            : std_logic_vector(31 downto 0);
end record;
type mmutwi_a is array (natural range <>) of mmutw_in_type;

type mmutw_out_type is record
  finish           : std_logic;
  data             : std_logic_vector(31 downto 0);
  addr             : std_logic_vector(31 downto 0);
  lvl              : std_logic_vector(1 downto 0);
  fault_mexc       : std_logic;
  fault_trans      : std_logic;
  fault_inv        : std_logic;
  fault_lvl        : std_logic_vector(1 downto 0);
end record;
type mmutwo_a is array (natural range <>) of mmutw_out_type;

-- mmu tlb i/o

type mmutlb_in_type is record
  flush_op    : std_logic;
  diag_op_ur  : std_logic;
  
  trans_op    : std_logic;
  transdata   : mmuidc_data_in_type;
  s2valid     : std_logic;
  
  annul       : std_logic;
  mmctrl1     : mmctrl_type1;
end record;
type mmutlbi_a is array (natural range <>) of mmutlb_in_type;

type mmutlbfault_out_type is record
  fault_pro   : std_logic;
  fault_pri   : std_logic;
  fault_access     : std_logic; 
  fault_mexc       : std_logic;
  fault_trans      : std_logic;
  fault_inv        : std_logic;
  fault_lvl        : std_logic_vector(1 downto 0);
  fault_su         : std_logic;
  fault_read       : std_logic;
  fault_isid       : mmu_idcache;
  fault_addr       : std_logic_vector(31 downto 0);
end record;
  
type mmutlb_out_type is record
  transdata   : mmuidc_data_out_type;
  fault       : mmutlbfault_out_type;
  nexttrans   : std_logic;
  s1finished  : std_logic;
end record; 
type mmutlbo_a is array (natural range <>) of mmutlb_out_type;

end;

