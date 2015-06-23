



----------------------------------------------------------------------------
--  This file is a part of the LEON VHDL model
--  Copyright (C) 2003 Gaisler Research
--
--  This library is free software; you can redistribute it and/or
--  modify it under the terms of the GNU Lesser General Public
--  License as published by the Free Software Foundation; either
--  version 2 of the License, or (at your option) any later version.
--
--  See the file COPYING.LGPL for the full details of the license.


-----------------------------------------------------------------------------
-- Entity: 	target
-- File:	target.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	LEON target configuration package
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

package leon_target is
type targettechs is 
  (gen, virtex, virtex2, atc35, atc25, atc18, fs90, umc18, tsmc25, proasic, axcel);

-- synthesis configuration
type syn_config_type is record
  targettech	: targettechs;
  infer_ram 	: boolean;	-- infer cache and dsu ram automatically 
  infer_regf 	: boolean;	-- infer regfile automatically 
  infer_rom	: boolean;	-- infer boot prom automatically
  infer_pads	: boolean;	-- infer pads automatically
  infer_pci 	: boolean;	-- infer PCI pads automatically
  infer_mult	: boolean;	-- infer multiplier automatically
  rftype   	: integer;	-- regfile implementation option
  targetclk 	: targettechs;  -- use technology specific clock generation
  clk_mul  	: integer;	-- PLL clock multiply factor
  clk_div  	: integer;	-- PLL clock divide factor
  pci_dll   	: boolean;	-- Re-synchronize PCI clock using a DLL
  pci_sysclk	: boolean;	-- Use PCI clock as system clock
end record;

-- processor configuration
type multypes is (none, iterative, m32x8, m16x16, m32x16, m32x32);
type divtypes is (none, radix2);

type iu_config_type is record
  nwindows	: integer;	-- # register windows (2 - 32)
  multiplier	: multypes;	-- multiplier type
  mulpipe	: boolean;	-- m16x16 pipeline register
  divider   	: divtypes;	-- divider type
  mac 		: boolean;	-- multiply/accumulate
  fpuen		: integer range 0 to 1;	-- FPU enable (integer due to synopsys limitations....sigh!)
  cpen		: boolean;	-- co-processor enable 
  fastjump   	: boolean;	-- enable fast jump address generation
  icchold   	: boolean;	-- enable fast branch logic
  lddelay	: integer range 1 to 2; -- # load delay cycles (1-2)
  fastdecode 	: boolean;	-- optimise instruction decoding (FPGA only)
  rflowpow   	: boolean;	-- disable regfile when not accessed
  watchpoints	: integer range 0 to 4; -- # hardware watchpoints (0-4)
  impl   	: integer range 0 to 15; -- IU implementation ID
  version	: integer range 0 to 15; -- IU version ID
end record;

-- FPU configuration
type fpucoretype  is (meiko, lth, grfpu);  		-- FPU core type
type fpuiftype is (none, serial, parallel); 	        -- FPU interface type

type fpu_config_type is record
  core		: fpucoretype;	-- FPU core type
  interface	: fpuiftype;	-- FPU inteface type
  fregs		: integer;	-- 32 for serial interface, 0 for parallel 
  version	: integer range 0 to 7; -- FPU version ID
end record;

-- co-processor configuration
type cptype is (none, cpc); -- CP type

-- cache configuration
type dsnoop_type is (none, slow, fast); -- snoop implementation type
constant PROC_CACHE_MAX	: integer := 4;   -- maximum cacheability ranges
constant PROC_CACHE_ADDR_MSB : integer := 4; -- MSB address bits to decode cacheability
type cache_replace_type is (lru, lrr, rnd);  -- cache replacement algorithm
constant MAXSETS  : integer := 4;

type cache_config_type is record
  isets         : integer range 1 to 4;   -- # of sets in icache
  isetsize	: integer;	-- I-cache size per set in Kbytes
  ilinesize	: integer;	-- # words per I-cache line
  ireplace      : cache_replace_type;         -- icache replacement algorithm
  ilock     	: integer;	-- icache locking
  dsets         : integer range 1 to 4;   -- # of sets in dcache
  dsetsize	: integer;	-- D-cache size per set in Kbytes
  dlinesize	: integer;	-- # words per D-cache line
  dreplace      : cache_replace_type;         -- icache replacement algorithm
  dlock     	: integer;	-- dcache locking
  dsnoop    	: dsnoop_type;	-- data-cache snooping
  drfast    	: boolean;	-- data-cache fast read-data generation
  dwfast    	: boolean;	-- data-cache fast write-data generation
  dlram     	: boolean;	-- local data ram enable
  dlramsize 	: integer;	-- local data ram size in kbytes
  dlramaddr 	: integer;	-- local data ram start address (8 msb)
end record;

-- mmu configuration
type mmu_tlb_type is (splittlb, combinedtlb);
type mmu_tlb_rep is (replruarray, repincrement);  -- cache replacement algorithm
type mmu_config_type is record
  enable        : integer range 0 to 1;
  itlbnum       : integer range 2 to 64;
  dtlbnum       : integer range 2 to 32;
  tlb_type      : mmu_tlb_type;
  tlb_rep       : mmu_tlb_rep;
  tlb_diag      : boolean;
end record;

-- memory controller configuration
type mctrl_config_type is record
  bus8en    	: boolean;	-- enable 8-bit bus operation
  bus16en    	: boolean;	-- enable 16-bit bus operation
  wendfb   	: boolean;	-- enable wen feed-back to data bus drivers
  ramsel5    	: boolean;	-- enable 5th ram select
  sdramen    	: boolean;	-- enable sdram controller
  sdinvclk   	: boolean;	-- invert sdram clock
end record;

type boottype is (memory, prom, dual);
type boot_config_type is record
  boot 		: boottype;	-- select boot source
  ramrws   	: integer;	-- ram read waitstates
  ramwws   	: integer;	-- ram write waitstates
  sysclk   	: integer;	-- cpu clock
  baud     	: positive;	-- UART baud rate
  extbaud  	: boolean;	-- use external baud rate setting
  pabits   	: positive;	-- internal boot-prom address bits
end record;

-- PCI configuration
type pcitype is (none, insilicon, target_only, opencores); -- PCI core type
type pci_config_type is record
  pcicore   	: pcitype;	-- PCI core type
  ahbmasters	: integer;	-- number of ahb master interfaces
  ahbslaves 	: integer;	-- number of ahb slave interfaces
  arbiter 	: boolean;	-- enable PCI arbiter
  fixpri  	: boolean;	-- use fixed arbitration priority
  prilevels 	: integer;	-- number of priority levels in arbiter
  pcimasters	: integer;	-- number of PCI masters to be handled by arbiter
  vendorid  	: integer;	-- PCI vendor ID
  deviceid  	: integer;	-- PCI device ID
  subsysid  	: integer;	-- PCI subsystem ID
  revisionid	: integer;	-- PCI revision ID
  classcode 	: integer;	-- PCI class code
  pmepads 	: boolean;	-- enable power down pads
  p66pad  	: boolean;	-- enable PCI66 pad
  pcirstall	: boolean;	-- PCI reset affects complete processor
end record;

-- debug configuration
type debug_config_type is record
  enable    	: boolean;	-- enable debug port
  uart     	: boolean;	-- enable fast uart data to console
  iureg    	: boolean;	-- enable tracing of iu register writes
  fpureg      	: boolean;	-- enable tracing of fpu register writes
  nohalt      	: boolean;	-- dont halt on error
  pclow       	: integer;	-- set to 2 for synthesis, 0 for debug
  dsuenable    	: boolean;	-- enable DSU
  dsutrace     	: boolean;	-- enable trace buffer
  dsumixed     	: boolean;	-- enable mixed-mode trace buffer
  dsudpram     	: boolean;	-- use dual-port ram for trace buffer
  tracelines	: integer range 64 to 1024; -- # trace lines (needs 16 bytes/line)
end record;

-- AMBA configuration types
constant AHB_MST_MAX	: integer := 4;   -- maximum AHB masters
constant AHB_SLV_MAX	: integer := 7;   -- maximum AHB slaves
constant AHB_SLV_ADDR_MSB : integer := 4; -- MSB address bits to decode slaves
subtype ahb_range_addr_type is std_logic_vector(AHB_SLV_ADDR_MSB-1 downto 0);
type ahbslv_addr_type is array (0 to 15) of integer range 0 to AHB_SLV_MAX;

type ahb_config_type is record
  masters	: integer range 1 to AHB_MST_MAX;
  defmst 	: integer range 0 to AHB_MST_MAX-1;
  split  	: boolean;	-- add support for SPLIT reponse
  testmod	: boolean;	-- add AHB test module (not for synthesis!)
end record;

constant APB_SLV_MAX	   : integer := 16;  -- maximum APB slaves
constant APB_SLV_ADDR_BITS : integer := 10;  -- address bits to decode APB slaves
subtype apb_range_addr_type is std_logic_vector(APB_SLV_ADDR_BITS-1 downto 0);

type irq_filter_type is (lvl0, lvl1, edge0, edge1);
type irq_filter_vec is array (0 to 31) of irq_filter_type;

type irq2type is record
  enable   	: boolean;	-- enable chained interrupt controller
  channels 	: integer;	-- number of additional interrupts (1 - 32)
  filter	: irq_filter_vec; -- irq filter definitions
end record;

type peri_config_type is record
  cfgreg   	: boolean;	-- enable LEON configuration register
  ahbstat  	: boolean;	-- enable AHB status register
  wprot  	: boolean;	-- enable RAM write-protection unit
  wdog   	: boolean;	-- enable watchdog
  irq2en      	: boolean;	-- chained interrupt controller enable
  ahbram 	: boolean;	-- enable AHB RAM
  ahbrambits 	: integer;	-- address bits in AHB ram
  ethen  	: boolean;	-- enable ethernet core
end record;

constant irq2none : irq2type := ( enable => false, channels => 32,
  filter => (others => lvl1));
--constant irq2chan4 : irq2type := ( enable => true, channels => 4,
--  filter => (lvl1, lvl1, edge0, edge1, others => lvl0));

end;
