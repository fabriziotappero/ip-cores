



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
-- Entity: 	config
-- File:	config.vhd
-- Author:	Jiri Gaisler - ESA/ESTEC
-- Description:	LEON configuration package. Do NOT edit, all constants are
--		set from the target/device packages.
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use work.leon_target.all;
use work.leon_device.all;
--pragma translate_off
use std.textio.all;
--pragma translate_on

package leon_config is

----------------------------------------------------------------------------
-- log2 tables
----------------------------------------------------------------------------

type log2arr is array(1 to 64) of integer;
constant log2  : log2arr := (0,1,2,2,3,3,3,3,4,4,4,4,4,4,4,4,
				5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,others => 6);
constant log2x : log2arr := (1,1,2,2,3,3,3,3,4,4,4,4,4,4,4,4,
				5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,others => 6);

----------------------------------------------------------------------------
-- IU, FPU and CP implementation and version numbers
----------------------------------------------------------------------------

constant IMPL   : unsigned(3 downto 0) := conv_unsigned(iu_config.impl,4);
constant VER    : unsigned(3 downto 0) := conv_unsigned(iu_config.version,4);
constant FPUVER	: unsigned(2 downto 0) := conv_unsigned(fpu_config.version,3);
constant CPVER	: unsigned(2 downto 0) := (others => '0');--conv_unsigned(conf.cp.version,3);
--pragma translate_off
constant LEON_VERSION : string := "1.0.21-xst";
--pragma translate_on

----------------------------------------------------------------------------
-- debugging
----------------------------------------------------------------------------

constant DEBUGPORT : boolean := debug_config.enable; -- enable iu debug port
constant DEBUGUART : boolean := debug_config.uart;   -- enable UART output to console
constant DEBUGIURF : boolean := debug_config.iureg;  -- write IU results to console
constant DEBUGFPU  : boolean := debug_config.fpureg; -- write FPU results to console
constant DEBUG_UNIT: boolean := debug_config.dsuenable;
constant TBUFABITS : integer := log2(debug_config.tracelines/64) + 6;  -- buffer address bits 
constant DSUTRACE  : boolean := debug_config.dsutrace;
constant DSUMIXED  : boolean := debug_config.dsumixed;
constant DSUDPRAM  : boolean := debug_config.dsudpram;
constant NOHALT    : boolean := debug_config.nohalt; -- dont halt on error
constant PCLOW 	   : integer := debug_config.pclow;

constant XTARGET_TECH: targettechs := syn_config.targettech;
constant TARGET_TECH: targettechs := XTARGET_TECH;
constant TARGET_CLK : targettechs := syn_config.targetclk;
constant PLL_CLK_MUL: integer  := syn_config.clk_mul;
constant PLL_CLK_DIV: integer  := syn_config.clk_div;
constant INFER_RAM  : boolean  := syn_config.infer_ram;
constant INFER_REGF : boolean  := syn_config.infer_regf;
constant INFER_ROM  : boolean  := syn_config.infer_rom;
constant INFER_PADS : boolean  := syn_config.infer_pads;
constant INFER_PCI_PADS : boolean  := syn_config.infer_pci;
constant INFER_MULT : boolean  := syn_config.infer_mult;
constant RFIMPTYPE  : integer  := syn_config.rftype;
constant XNWINDOWS   : integer range 2 to 32 := iu_config.nwindows;
constant NWINDOWS   : integer range 2 to 32 := XNWINDOWS;
constant NWINLOG2   : integer range 1 to 5 := log2(NWINDOWS);
constant RABITS     : integer := log2(NWINDOWS+1) + 4; -- # regfile address bits

constant RDBITS   : integer := 32;	-- data width

constant MULTIPLIER : multypes := iu_config.multiplier;
constant MULPIPE    : boolean := iu_config.mulpipe and (MULTIPLIER = m16x16) and not INFER_MULT;
constant DIVIDER    : divtypes := iu_config.divider;
constant MACEN      : boolean := iu_config.mac and (MULTIPLIER = m16x16) and not MULPIPE;

constant FPEN  : boolean := (fpu_config.interface /= none);
constant FPCORE    : fpucoretype := fpu_config.core;
constant FPIFTYPE  : fpuiftype := fpu_config.interface;
constant FPREG : integer := fpu_config.fregs;
constant CPEN  : boolean := iu_config.cpen;
constant CWPOPT : boolean := (NWINDOWS = (2**NWINLOG2));
constant IREGNUM : integer := NWINDOWS * 16 + FPREG + 8;-- number of registers in regfile

type cache_replalgbits_type is array (cache_replace_type range lru to rnd) of integer;
type lru_bits_type is array(1 to 4) of integer;
constant lru_table  : lru_bits_type := (1,1,3,5);
constant CREPLALG_TBL : cache_replalgbits_type := (lru => 0, lrr => 1, rnd => 0);  -- # of extra bits in

--constant ISETS : integer range 1 to 4 := cache_config.isets;  -- # of icache sets 
constant XISETS : integer range 1 to 4 := cache_config.isets;  -- # of icache sets 
constant ISETS : integer range 1 to 4 := XISETS;  -- # of icache sets 
constant XILINE_SIZE   : integer range 2 to 8 := cache_config.ilinesize;
constant ILINE_SIZE   : integer range 2 to 8 := XILINE_SIZE;
constant ILINE_BITS   : integer := log2(ILINE_SIZE);
constant XISET_SIZE    : integer range 1 to 64 := cache_config.isetsize;
constant ISET_SIZE    : integer range 1 to 64 := XISET_SIZE;
constant IOFFSET_BITS : integer := 8 +log2(ISET_SIZE) - ILINE_BITS;
constant ITAG_HIGH    : integer := 31;
constant ITAG_BITS    : integer := ITAG_HIGH - IOFFSET_BITS - ILINE_BITS - 2 +
				   ILINE_SIZE + 1;
constant ICREPLACE  : cache_replace_type := cache_config.ireplace; -- replacement algorithm
constant ILRUBITS  : integer := lru_table(ISETS);
constant ILRR_BIT      : integer := CREPLALG_TBL(ICREPLACE);
constant ICTAG_LRRPOS  : integer := 9;
constant ICTAG_LOCKPOS : integer := 8;
constant ICLOCK_BIT : integer := cache_config.ilock;

--constant DSETS : integer range 1 to 4 := cache_config.dsets;  -- # of dcache sets 
constant XDSETS : integer range 1 to 4 := cache_config.dsets;  -- # of dcache sets 
constant DSETS : integer range 1 to 4 := XDSETS; -- synopsys bug !!!
constant XDLINE_SIZE   : integer range 2 to 8 := cache_config.dlinesize;
constant DLINE_SIZE   : integer range 2 to 8 := XDLINE_SIZE;
constant DLINE_BITS   : integer := log2(DLINE_SIZE);
constant XDSET_SIZE    : integer range 1 to 64 := cache_config.dsetsize;
constant DSET_SIZE    : integer range 1 to 64 := XDSET_SIZE;
constant DOFFSET_BITS : integer := 8 +log2(DSET_SIZE) - DLINE_BITS;
constant DTAG_HIGH    : integer := 31;
constant DTAG_BITS    : integer := DTAG_HIGH - DOFFSET_BITS - DLINE_BITS - 2 +
				   DLINE_SIZE + 1;
constant LOCAL_RAM    : boolean := cache_config.dlram;
constant LOCAL_RAM_BITS : integer := log2(cache_config.dlramsize) + 8;
constant LOCAL_RAM_START : std_logic_vector(31 downto 24) := 
	std_logic_vector(conv_unsigned(cache_config.dlramaddr, 8));
constant DCREPLACE  : cache_replace_type := cache_config.dreplace; -- replacement algorithm
constant DLRUBITS  : integer := lru_table(DSETS);
constant DLRR_BIT      : integer := CREPLALG_TBL(DCREPLACE);
constant DCTAG_LRRPOS  : integer := 9;
constant DCTAG_LOCKPOS : integer := 8;
constant DCLOCK_BIT : integer := cache_config.dlock;
constant DSNOOP       : boolean := cache_config.dsnoop /= none;
constant DSNOOP_FAST  : boolean := cache_config.dsnoop = fast;
constant DREAD_FAST   : boolean := cache_config.drfast;
constant DWRITE_FAST  : boolean := cache_config.dwfast;
--constant PROC_CACHETABLE   : proc_cache_config_vector(0 to PROC_CACHE_MAX-1) := cachetbl_std;-- conf.cache.cachetable(0 to PROC_CACHE_MAX-1);

constant BUS8EN    : boolean  := mctrl_config.bus8en;
constant BUS16EN   : boolean  := mctrl_config.bus16en;
constant WENDFB    : boolean  := mctrl_config.wendfb;
constant RAMSEL5   : boolean  := mctrl_config.ramsel5;
constant SDRAMEN   : boolean  := mctrl_config.sdramen;
constant SDINVCLK  : boolean  := mctrl_config.sdinvclk;

constant BOOTOPT   : boottype := boot_config.boot;
constant ITPRESC   : integer  := boot_config.sysclk/1000000 -1;
constant TPRESC    : unsigned(15 downto 0) := conv_unsigned(ITPRESC, 16);
constant IUPRESC   : integer  := ((boot_config.sysclk*10)/(boot_config.baud*8)-5)/10;
constant UPRESC    : unsigned(15 downto 0) := conv_unsigned(IUPRESC, 16);
constant BRAMRWS   : unsigned(3 downto 0) := conv_unsigned(boot_config.ramrws, 4);
constant BRAMWWS   : unsigned(3 downto 0) := conv_unsigned(boot_config.ramwws, 4);
constant EXTBAUD   : boolean := boot_config.extbaud;
constant PABITS    : integer := boot_config.pabits;

constant PCIEN       : boolean := (pci_config.pcicore /= none);
constant PCICORE     : pcitype := pci_config.pcicore;
constant PCIPMEEN    : boolean := pci_config.pmepads;
constant PCI66PADEN  : boolean := pci_config.p66pad;
constant PCIRSTALL   : boolean := pci_config.pcirstall;
constant PCIMASTERS  : integer := pci_config.ahbmasters;
constant PCI_CLKDLL  : boolean  := syn_config.pci_dll and PCIEN;
constant PCI_SYSCLK  : boolean  := syn_config.pci_sysclk and PCIEN;

constant ETHEN       : boolean := peri_config.ethen;
constant WPROTEN     : boolean := peri_config.wprot;
constant AHBSTATEN   : boolean := peri_config.ahbstat;
constant AHBRAMEN    : boolean := peri_config.ahbram;
constant AHBRAM_BITS : integer := peri_config.ahbrambits;
constant CFGREG      : boolean := peri_config.cfgreg;
constant WDOGEN      : boolean := peri_config.wdog;
constant IRQ2EN      : boolean := peri_config.irq2en;
constant IRQ2CHAN    : integer range 1 to 32 := 1;--rq2cfg.channels;
constant IRQ2TBL     : irq_filter_vec := irq2none.filter;--conf.peri_config.irq2cfg.filter;

constant FASTJUMP    : boolean := iu_config.fastjump;
constant ICC_HOLD    : boolean := iu_config.icchold;
constant LDDELAY     : integer range 1 to 2 := iu_config.lddelay;
constant FASTDECODE  : boolean := iu_config.fastdecode;
constant RF_LOWPOW   : boolean  := iu_config.rflowpow;
constant XWATCHPOINTS : integer range 0 to 4 := iu_config.watchpoints;
constant WATCHPOINTS : integer range 0 to 4 := XWATCHPOINTS;

type ahbslv_split_type is array (0 to AHB_SLV_MAX-1) of integer range 0 to 1;

constant AHBSLVADDR  : ahbslv_addr_type := ahbrange_config;
constant AHBSLVSPLIT : ahbslv_split_type := (0,0,0,0,0,0,0);
constant XAHB_MASTERS : integer := ahb_config.masters;
constant AHB_MASTERS : integer := XAHB_MASTERS;
constant AHB_SPLIT   : boolean := ahb_config.split;
constant AHB_DEFMST  : integer := ahb_config.defmst;
constant AHBTST      : boolean := ahb_config.testmod;

constant PCIARBEN    : boolean := pci_config.arbiter;
constant XNB_AGENTS   : natural range 3 to 32 := pci_config.pcimasters;
constant NB_AGENTS   : natural range 3 to 32 := XNB_AGENTS;
constant ARB_LEVELS  : positive range 1 to 4 := pci_config.prilevels;
constant APB_PRIOS   : boolean := pci_config.fixpri;
constant ARB_SIZE    : natural range 2 to 5 := log2(NB_AGENTS);  

constant PCI_DEVICE_ID : integer := pci_config.deviceid;
constant PCI_VENDOR_ID : integer := pci_config.vendorid;
constant PCI_SUBSYS_ID : integer := pci_config.subsysid;
constant PCI_REVISION_ID : integer := pci_config.revisionid;
constant PCI_CLASS_CODE  : integer := pci_config.classcode;



end;
