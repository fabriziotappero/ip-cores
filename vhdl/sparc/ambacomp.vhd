



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
-- Entity: 	ambacomp
-- File:	ambacomp.vhd
-- Author:	Jiri Gaisler - ESA/ESTEC
-- Description:	Component declarations of AMBA cores
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.amba.all;
use work.leon_target.all;
use work.leon_config.all;
use work.leon_iface.all;
use work.peri_io_comp.all;
use work.peri_mem_comp.all;

package ambacomp is

-- processor core

component proc
  port (
    rst    : in  std_logic;
    clk    : in  clk_type;
    clkn   : in  clk_type;
    apbi   : in  apb_slv_in_type;
    apbo   : out apb_slv_out_type;
    ahbi   : in  ahb_mst_in_type;
    ahbo   : out ahb_mst_out_type;
    ahbsi  : in  ahb_slv_in_type;
    iui    : in  iu_in_type;
    iuo    : out iu_out_type
  );
end component;

-- AMBA/PCI interface for InSilicon (was Phoenix) PCI core
component pci_is 
   port (
      rst_n           : in  std_logic;
      pciresetn       : in  std_logic;
      app_clk         : in  clk_type;
      pci_clk         : in  clk_type;
      pbi             : in  APB_Slv_In_Type;   -- peripheral bus in
      pbo             : out APB_Slv_Out_Type;  -- peripheral bus out
      irq             : out std_logic;         -- interrupt request
      TargetMasterOut : out ahb_mst_out_type;  -- PCI target DMA
      TargetMasterIn  : in  ahb_mst_in_type;
      pci_in          : in  pci_in_type;       -- PCI pad inputs
      pci_out         : out pci_out_type;      -- PCI pad outputs
      InitSlaveOut  : out ahb_slv_out_type;  	-- Direct PCI master access
      InitSlaveIn   : in  ahb_slv_in_type;
      InitMasterOut : out ahb_mst_out_type;  	-- PCI Master DMA
      InitMasterIn  : in  ahb_mst_in_type    
      );
end component;

-- ESA PCI interface
component pci_esa
  port (
      resetn          : in  std_logic;         -- Amba reset signal
      app_clk         : in  clk_type;          -- Application clock
      pci_in          : in  pci_in_type;       -- PCI pad inputs
      pci_out         : out pci_out_type;      -- PCI pad outputs
      ahbmasterin     : in  ahb_mst_in_type;   -- AHB Master inputs
      ahbmasterout    : out ahb_mst_out_type;  -- AHB Master outputs
      ahbslavein      : in  ahb_slv_in_type;   -- AHB Slave inputs
      ahbslaveout     : out ahb_slv_out_type;  -- AHB Slave outputs
      apbslavein      : in  apb_Slv_In_Type;   -- peripheral bus in
      apbslaveout     : out apb_Slv_Out_Type;  -- peripheral bus out
      irq             : out std_logic          -- interrupt request
   );
end component;

-- Non-functional PCI module for testing
component pci_test
  port (
    rst    : in  std_logic;
    clk    : in  std_logic;
    ahbmi  : in  ahb_mst_in_type;
    ahbmo  : out ahb_mst_out_type;
    ahbsi  : in  ahb_slv_in_type;
    ahbso  : out ahb_slv_out_type
  );
end component;

-- PCI arbiter

component pci_arb
 port (
    clk     : in  clk_type ;                              -- clock
    rst_n   : in  std_logic;                           -- async reset active low
    req_n   : in  std_logic_vector(0 to NB_AGENTS-1);  -- bus request
    frame_n : in  std_logic;
    gnt_n   : out std_logic_vector(0 to NB_AGENTS-1);  -- bus grant
    pclk    : in  clk_type;                            -- APB clock
    prst_n  : in  std_logic;                           -- APB reset
    pbi     : in  APB_Slv_In_Type;                     -- APB inputs
    pbo     : out APB_Slv_Out_Type     
  );
end component;


-- APB/AHB bridge

component apbmst 
  port (
    rst     : in  std_logic;
    clk     : in  clk_type;
    ahbi    : in  ahb_slv_in_type;
    ahbo    : out ahb_slv_out_type;
    apbi    : out apb_slv_in_vector(0 to APB_SLV_MAX-1);
    apbo    : in  apb_slv_out_vector(0 to APB_SLV_MAX-1)
  );
end component;

-- AHB arbiter

component ahbarb 
  generic (
    masters : integer := 2;		-- number of masters
    defmast : integer := 0 		-- default master
  );
  port (
    rst     : in  std_logic;
    clk     : in  clk_type;
    msti    : out ahb_mst_in_vector(0 to masters-1);
    msto    : in  ahb_mst_out_vector(0 to masters-1);
    slvi    : out ahb_slv_in_vector(0 to AHB_SLV_MAX-1);
    slvo    : in  ahb_slv_out_vector(0 to AHB_SLV_MAX)
  );
end component;

-- PROM/SRAM controller


-- AHB test module

component ahbtest
   port (
      rst  : in  std_logic;
      clk  : in  clk_type;
      ahbi : in  ahb_slv_in_type;
      ahbo : out ahb_slv_out_type
      );
end component;      

-- AHB write-protection module


-- AHB status register

component ahbstat
  port (
    rst    : in  std_logic;
    clk    : in  clk_type;
    ahbmi  : in  ahb_mst_in_type;
    ahbsi  : in  ahb_slv_in_type;
    apbi   : in  apb_slv_in_type;
    apbo   : out apb_slv_out_type;
    ahbsto : out ahbstat_out_type

  );
end component;

-- LEON configuration register

component lconf
  port (
    rst    : in  std_logic;
    apbo   : out apb_slv_out_type
  );
end component; 

-- interrupt controller

component irqctrl
  port (
    rst    : in  std_logic;
    clk    : in  clk_type;
    apbi   : in  apb_slv_in_type;
    apbo   : out apb_slv_out_type;
    irqi   : in  irq_in_type;
    irqo   : out irq_out_type
  );
end component;

-- secondary interrupt controller

component irqctrl2
  port (
    rst    : in  std_logic;
    clk    : in  clk_type;
    apbi   : in  apb_slv_in_type;
    apbo   : out apb_slv_out_type;
    irqi   : in  irq2_in_type;
    irqo   : out irq2_out_type
  );
end component;

-- timers module

component timers 
  port (
    rst    : in  std_logic;
    clk    : in  clk_type;
    apbi   : in  apb_slv_in_type;
    apbo   : out apb_slv_out_type;
    timo   : out timers_out_type;
    dsuo   : in  dsu_out_type
  );
end component;

-- UART


-- I/O port


-- Generic AHB master

component ahbmst
  generic (incaddr : integer := 0);
   port (
      rst  : in  std_logic;
      clk  : in  clk_type;
      dmai : in ahb_dma_in_type;
      dmao : out ahb_dma_out_type;
      ahbi : in  ahb_mst_in_type;
      ahbo : out ahb_mst_out_type 
      );
end component;

-- DMA

component dma
   port (
      rst  : in  std_logic;
      clk  : in  clk_type;
      dirq  : out std_logic;
      apbi   : in  apb_slv_in_type;
      apbo   : out apb_slv_out_type;
      ahbi : in  ahb_mst_in_type;
      ahbo : out ahb_mst_out_type 
      );
end component;

component pci_actel
   generic (
      USER_DEVICE_ID  : integer := 0;
      USER_VENDOR_ID  : integer := 0;
      USER_REVISION_ID: integer := 0;
      USER_BASE_CLASS : integer := 0;
      USER_SUB_CLASS  : integer := 0;
      USER_PROGRAM_IF : integer := 0;
      USER_SUBSYSTEM_ID : integer := 0;
      USER_SUBVENDOR_ID : integer := 0

--      ;BIT_64          : STD_LOGIC := '0';
--      MHZ_66          : STD_LOGIC := '0';
--      DMA_IN_IO       : STD_LOGIC := '1';
--      MADDR_WIDTH     : INTEGER RANGE 4 TO 31 := 22;
--      BAR1_ENABLE     : STD_LOGIC := '0';
--      BAR1_IO_MEMORY  : STD_LOGIC := '0'; 
--      BAR1_ADDR_WIDTH : INTEGER RANGE 2 TO 31 := 12; 
--      BAR1_PREFETCH   : STD_LOGIC := '0'; 
--      HOT_SWAP_ENABLE : STD_LOGIC := '0'
      ); 
   port( 

      clk           : in std_logic;   
      rst           : in std_logic;   
      -- PCI signals

      pcii	: in  pci_in_type;
      pcio	: out pci_out_type;

      ahbmi 	: in  ahb_mst_in_type;
      ahbmo 	: out ahb_mst_out_type;
      ahbsi 	: in  ahb_slv_in_type;
      ahbso 	: out ahb_slv_out_type
);
end component;

-- ACTEL PCI target backend

component pci_be_actel 
   port (
      rst  : in  std_logic;
      clk  : in  std_logic;
      ahbmi : in  ahb_mst_in_type;
      ahbmo : out ahb_mst_out_type;
      ahbsi : in  ahb_slv_in_type;
      ahbso : out ahb_slv_out_type;
      bei  : in  actpci_be_in_type;
      beo  : out actpci_be_out_type
      );
end component;   

-- opencores pci interface

component pci_oc
   port (
      rst  : in  std_logic;
      clk  : in  std_logic;
      pci_clk : in std_logic;
      ahbsi : in  ahb_slv_in_type;
      ahbso : out ahb_slv_out_type;
      ahbmi : in  ahb_mst_in_type;
      ahbmo : out ahb_mst_out_type;
      apbi  : in  apb_slv_in_type;
      apbo  : out apb_slv_out_type;
      pcio  : out pci_out_type;
      pcii  : in  pci_in_type;
      irq   : out std_logic
      );
end component;

-- generic pci interface

component pci
  port (
    resetn : in  std_logic;
    clk    : in  clk_type;
    pciclk : in  clk_type;
    pcirst : in  std_logic;
    pcii   : in  pci_in_type;
    pcio   : out pci_out_type;
    apbi   : in  apb_slv_in_type;
    apbo   : out apb_slv_out_type;
    ahbmi1 : in  ahb_mst_in_type;
    ahbmo1 : out ahb_mst_out_type;
    ahbmi2 : in  ahb_mst_in_type;
    ahbmo2 : out ahb_mst_out_type;
    ahbsi  : in  ahb_slv_in_type;
    ahbso  : out ahb_slv_out_type;
    irq    : out std_logic
  );
end component; 

-- debug support unit

component dsu
  port (
    rst    : in  std_logic;
    clk    : in  clk_type;
    ahbmi  : in  ahb_mst_in_type;
    ahbsi  : in  ahb_slv_in_type;
    ahbso  : out ahb_slv_out_type;
    dsui   : in  dsu_in_type;
    dsuo   : out dsu_out_type;
    dbgi   : in  iu_debug_out_type;
    dbgo   : out iu_debug_in_type;
    irqo   : in  irq_out_type;
    dmi    : out dsumem_in_type;
    dmo    : in  dsumem_out_type
  );
end component; 

component dcom
   port (
      rst    : in  std_logic;
      clk    : in  clk_type;
      dcomi  : in  dcom_in_type;
      dcomo  : out dcom_out_type;
      dsuo   : in  dsu_out_type;
      apbi   : in  apb_slv_in_type;
      apbo   : out apb_slv_out_type;
      ahbi : in  ahb_mst_in_type;
      ahbo : out ahb_mst_out_type 
      );
end component;  

component dcom_uart
  port (
    rst    : in  std_logic;
    clk    : in  clk_type;
    apbi   : in  apb_slv_in_type;
    apbo   : out apb_slv_out_type;
    uarti  : in  dcom_uart_in_type;
    uarto  : out dcom_uart_out_type
  );
end component; 

component ahbram 
  generic ( abits : integer := 10);
  port (
    rst    : in  std_logic;
    clk    : in  clk_type;
    ahbsi  : in  ahb_slv_in_type;
    ahbso  : out ahb_slv_out_type
  );
end component;

component eth_oc
  port (
    rst  : in  std_logic;
    clk  : in  std_logic;
    ahbsi : in  ahb_slv_in_type;
    ahbso : out ahb_slv_out_type;
    ahbmi : in  ahb_mst_in_type;
    ahbmo : out ahb_mst_out_type;
    eneti : in eth_in_type;
    eneto : out eth_out_type;
    irq   : out std_logic
  );
end component;

component pci_gr
   generic (device_id : integer := 0; vendor_id : integer := 0; 
            nsync : integer := 1); 
   port( 
      rst       : in std_logic;   
      pcirst    : in std_logic;   
      clk       : in std_logic;   
      pciclk    : in std_logic;   
      pcii	: in  pci_in_type;
      pcio	: out pci_out_type;
      ahbmi 	: in  ahb_mst_in_type;
      ahbmo 	: out ahb_mst_out_type;
      ahbsi 	: in  ahb_slv_in_type;
      ahbso 	: out ahb_slv_out_type
);
          
end component; 
end;
