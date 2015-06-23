----------------------------------------------------------------------
----                                                              ----
----  File name "wb2hpi.vhd"                                      ----
----                                                              ----
----  This file is part of the "WB2HPI" project                   ----
----  http://www.opencores.org/cores/wb2hpi/                      ----
----                                                              ----
----  Author(s):                                                  ----
----      - Gvozden Marinkovic (gvozden@opencores.org)            ----
----      - Dusko Krsmanovic   (dusko@opencores.org)              ----
----                                                              ----
----  All additional information is avaliable in the README       ----
----  file.                                                       ----
----                                                              ----
----                                                              ----
----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2002 Gvozden Marinkovic, gvozden@opencores.org ----
----                                                              ----
---- This source file may be used and distributed without         ----
---- restriction provided that this copyright statement is not    ----
---- removed from the file and that any derivative work contains  ----
---- the original copyright notice and the associated disclaimer. ----
----                                                              ----
---- This source file is free software; you can redistribute it   ----
---- and/or modify it under the terms of the GNU Lesser General   ----
---- Public License as published by the Free Software Foundation; ----
---- either version 2.1 of the License, or (at your option) any   ----
---- later version.                                               ----
----                                                              ----
---- This source is distributed in the hope that it will be       ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied   ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ----
---- PURPOSE.  See the GNU Lesser General Public License for more ----
---- details.                                                     ----
----                                                              ----
---- You should have received a copy of the GNU Lesser General    ----
---- Public License along with this source; if not, download it   ----
---- from http://www.opencores.org/lgpl.shtml                     ----
----                                                              ----
----------------------------------------------------------------------

--==================================================================-- 
-- Design        : wb2hpi_WBmaster 
--                ( entity i architecture ) 
-- 
-- File          : wb2hpi_WBmaster.vhd 
-- 
-- Errors        : 
-- 
-- Library       : ieee.std_logic_1164 
-- 
-- Dependency    : 
-- 
-- Author        : Gvozden Marinkovic 
--                 mgvozden@eunet.yu 
-- 
-- Simulators    : ActiveVHDL 3.5 on a WindowsXP PC   
----------------------------------------------------------------------
-- Description   :  Top module for WB2HPI application
----------------------------------------------------------------------
-- Copyright (c) 2002  Gvozden Marinkovic
-- 
-- This VHDL design file is an open design; you can redistribute it
-- and/or modify it and/or implement it after contacting the author
--==================================================================--                           

--************************** CVS history ***************************--
--$Author: gvozden $
--$Date: 2003-01-16 18:06:19 $
--$Revision: 1.1.1.1 $
--$Name: not supported by cvs2svn $
--************************** CVS history ***************************--

library ieee;
use ieee.std_logic_1164.all;        

---------------------------------------------------------------------- 
-- entity wb2hpi 
---------------------------------------------------------------------- 
entity wb2hpi is
    port (
        -- WISHBONE common signals to MASTER and SLAVE
        WB_CLK_I        : in std_logic;                      -- Clock
        WB_RST_I        : in std_logic;                      -- Reset
        
        -- WISHBONE SLAVE signals
        WBS_CYC_I       : in  std_logic;                     -- Cycle in progress
        WBS_STB_I       : in  std_logic;                     -- Strobe
        WBS_WE_I        : in  std_logic;                     -- Write enable
        WBS_CAB_I       : in  std_logic;                      
        WBS_ADR_I       : in  std_logic_vector(31 downto 0); -- Address
        WBS_DAT_I       : in  std_logic_vector(31 downto 0); -- Data input
        WBS_SEL_I       : in  std_logic_vector(3  downto 0); -- Select
        WBS_ACK_O       : out std_logic;                     -- Acknowledge
        WBS_ERR_O       : out std_logic;                     -- Error
        WBS_RTY_O       : out std_logic;                     -- Retry         
        WBS_DAT_O       : out std_logic_vector(31 downto 0); -- Data output 

        -- WISHBONE MASTER signals      
        WBM_ACK_I       : in  std_logic;                     -- Acknowledge
        WBM_ERR_I       : in  std_logic;                     -- Error
        WBM_RTY_I       : in  std_logic;                     -- Retry
        WBM_DAT_I       : in  std_logic_vector(31 downto 0); -- Data input
        WBM_CYC_O       : out std_logic;                     -- Cycle in progress
        WBM_STB_O       : out std_logic;                     -- Strobe
        WBM_WE_O        : out std_logic;                     -- Write enable
        WBM_CAB_O       : out std_logic;                        
        WBM_ADR_O       : out std_logic_vector(31 downto 0); -- Address
        WBM_DAT_O       : out std_logic_vector(31 downto 0); -- Data output 
        WBM_SEL_O       : out std_logic_vector( 3 downto 0); -- Select

        -- to PCI
        INT_REQ         : out std_logic;                     -- Interrupt request
        
        -- To DSP
        DSP_HAD_O       : out std_logic_vector( 7 downto 0); -- HPI Address/Data Output
        DSP_HAD_ENn     : out std_logic;                     -- HPI Address/Data Output Enable
        DSP_RST_PAD_O   : out std_logic;                     -- Reset DSP
        DSP_HCNTL_PAD_O : out std_logic_vector( 1 downto 0); -- HPI Register selection
        DSP_HCS_PAD_O   : out std_logic;                     -- HPI Chip Select
        DSP_HDS1_PAD_O  : out std_logic;                     -- HPI Data Strobe 1
        DSP_HDS2_PAD_O  : out std_logic;                     -- HPI Data Strobe 2
        DSP_HRW_PAD_O   : out std_logic;                     -- HPI Read/Write
        DSP_HBIL_PAD_O  : out std_logic;                     -- HPI Byte High/Low
        DSP_HAS_PAD_O   : out std_logic;                     -- HPI HAS
        DSP_INT2_PAD_O  : out std_logic;                     -- HPI Interrupt request 2
        
        -- From DSP
        DSP_HAD_I       : in  std_logic_vector( 7 downto 0); -- HPI Address/Data Input
        DSP_HRDY_PAD_I  : in  std_logic;                     -- HPI Ready
        DSP_HINT_PAD_I  : in  std_logic;                     -- HPI Host Interrupt
        
        -- To Test LED
        LED             : out std_logic                      -- Led diode
    );
end entity wb2hpi;

--------------------------------------------------------------------- 
-- architecture wb2hpi 
--------------------------------------------------------------------- 
architecture RTL of wb2hpi is

--------------------------------------------------------------------- 
-- component declaration
--------------------------------------------------------------------- 
component wb2hpi_WBslave is
    port (
        -- WISHBONE common signals to MASTER and SLAVE
        WB_CLK_I        : in  std_logic;                     -- Clock
        WB_RST_I        : in  std_logic;                     -- Reset
                 
        -- WISHBONE SLAVE signals
        WBS_CYC_I       : in  std_logic;                     -- Cycle in progress
        WBS_STB_I       : in  std_logic;                     -- Strobe
        WBS_WE_I        : in  std_logic;                     -- Write enable
        WBS_CAB_I       : in  std_logic;                     
        WBS_ADR_I       : in  std_logic_vector(31 downto 0); -- Address
        WBS_DAT_I       : in  std_logic_vector(31 downto 0); -- Data input
        WBS_SEL_I       : in  std_logic_vector(3  downto 0); -- Select
        WBS_ACK_O       : out std_logic;                     -- Acknowledge
        WBS_ERR_O       : out std_logic;                     -- Error
        WBS_RTY_O       : out std_logic;                     -- Retry
        WBS_DAT_O       : out std_logic_vector(31 downto 0); -- Data output       
        
        -- To PCI signals
        int_req         : out std_logic;                     -- Interrupt request

        -- To HPI Interface	
        hpi_data_r      : out std_logic_vector(17 downto 0); -- HPI data (to DSP)
        hpi_address_r   : out std_logic_vector(15 downto 0); -- HPI address (to DSP) 
        hpi_command_r   : out std_logic_vector( 2 downto 0); -- HPI command   
        pci_address_r   : out std_logic_vector(31 downto 1); -- Memory buffrer address
        pci_counter_r   : out std_logic_vector(15 downto 0); -- Number of words for transfer  
        start_hpi_comm  : out std_logic;                     -- Strobe Data
        hpi_reset       : out std_logic;                     -- Reset HPI Logic
        dsp_reset       : out std_logic;                     -- Reset DSP

        -- From HPI Interface
        hpi_data_out    : in  std_logic_vector(15 downto 0); -- Data out (To-WB)
        hpi_ready       : in  std_logic;                     -- Ready for HPI Access
        hpi_counter     : in  std_logic_vector(15 downto 0);    
        hpi_pci_addr    : in  std_logic_vector(31 downto 1);
        hpi_int_req1    : in  std_logic;                     -- Interrupt request 1 (End Block Transfer)
        hpi_int_req2    : in  std_logic;                     -- Interrupt request 2 (from DSP)
        dsp_ready       : in  std_logic;                     -- DSP Ready
        dsp_hint        : in  std_logic;                     -- DSP Host Interrupt
        hpi_end_transfer: in  std_logic;                     -- HPI End Transfer
        hpi_data_is_rdy : in  std_logic;                     -- HPI Data Ready 
        
        -- From WB master
        pci_error       : in  std_logic;                     -- PCI error

        -- To Test LED
        led             : out std_logic                      -- Control LED
    );
end component wb2hpi_WBslave; 

component wb2hpi_WBmaster is
    port (
        -- WISHBONE common signals to MASTER and SLAVE
        WB_CLK_I        : in  std_logic;                     -- Clock
        WB_RST_I        : in  std_logic;                     -- Reset
            
        -- WISHBONE MASTER signals      
        WBM_ACK_I       : in  std_logic;                     -- Acknowledge
        WBM_ERR_I       : in  std_logic;                     -- Error
        WBM_RTY_I       : in  std_logic;                     -- Retry
        WBM_DAT_I       : in  std_logic_vector(31 downto 0); -- Data input
        WBM_CYC_O       : out std_logic;                     -- Cycle in progress
        WBM_STB_O       : out std_logic;                     -- Strobe
        WBM_WE_O        : out std_logic;                     -- Write enable
        WBM_CAB_O       : out std_logic;                     -- 
        WBM_ADR_O       : out std_logic_vector(31 downto 0); -- Address
        WBM_DAT_O       : out std_logic_vector(31 downto 0); -- Data output 
        WBM_SEL_O       : out std_logic_vector(3  downto 0); -- Select  
                     
        -- From HPI Interface
        pci_address     : in  std_logic_vector(31 downto 1); -- PCI Address
        pci_counter     : in  std_logic_vector(15 downto 0); -- Number of bytes for transfer
        pci_data_in     : in  std_logic_vector(15 downto 0); -- Data
        start_write     : in  std_logic;                     -- Start PCI write
        start_read      : in  std_logic;                     -- Start PCI read
        
        -- To WB Slave
        pci_error       : out std_logic;                     -- PCI error

        -- To HPI Interface
        ready           : out std_logic;                     -- Ready 	
        pci_data_out    : out std_logic_vector(15 downto 0); -- Data
        pci_get_next    : out std_logic                      -- Get next word
    );
end component wb2hpi_WBmaster;     

component wb2hpi_control is 
    port(
        clk             : in  std_logic;                     -- Clock
        reset           : in  std_logic;                     -- Reset   

        -- From WB Slave
        hpi_data_r      : in  std_logic_vector(17 downto 0); -- HPI data (to DSP)
        hpi_address_r   : in  std_logic_vector(15 downto 0); -- HPI address (to DSP) 
        hpi_command_r   : in  std_logic_vector( 2 downto 0); -- HPI command   
        pci_address_r   : in  std_logic_vector(31 downto 1); -- Memory buffrer address
        pci_counter_r   : in  std_logic_vector(15 downto 0); -- Number of words for transfer  
        start           : in  std_logic;                     -- Execute command

        -- From WB Master
        from_pci_data   : in  std_logic_vector(15 downto 0); -- From PCI Data (Bus Mastering)
        pci_get_next    : in  std_logic;                     -- Prepare next word
        pci_ready       : in  std_logic;                     -- WB Master is ready for transfer
          
        -- To WB Slave
        counter         : out std_logic_vector(15 downto 0); -- Number of words left for transfer
        ready           : out std_logic;                     -- HPI Interface ready (for status reg)
        end_transfer    : out std_logic;                     -- End block transfer 
        hpi_data_is_rdy : out std_logic;                     -- Data is ready (after HPI read)
        int_req1        : out std_logic;                     -- Interrupt request 1 (End Block Transfer)
        int_req2        : out std_logic;                     -- Interrupt request 2 (from DSP)

        -- To WB Master
        pci_start_write : out std_logic;                     -- Write request
        pci_start_read  : out std_logic;                     -- Read request
        pci_counter     : out std_logic_vector(15 downto 0); -- Number of words
        pci_address     : out std_logic_vector(31 downto 1); -- PCI Address
        to_pci_data     : out std_logic_vector(15 downto 0); -- PCI Data (Bus Mastering)

        -- From DSP     
        hpi_ad_in       : in  std_logic_vector( 7 downto 0); -- Data in (From-HPI)   
        dsp_hint        : in  std_logic;   
        hpi_rdy         : in  std_logic;                     -- HPI Ready

        -- To DSP       
        hpi_ad_out      : out std_logic_vector( 7 downto 0); -- Data in (To-HPI)     
        hpi_ad_en       : out std_logic;                     -- Data out enable (To-HPI)
        dsp_int2        : out std_logic;
        hpi_cntl        : out std_logic_vector( 1 downto 0); -- HPI Control      
        hpi_cs_n        : out std_logic;                     -- HPI Chpi Select      
        hpi_ds_n        : out std_logic;                     -- HPI Data Stobe
        hpi_rw          : out std_logic;                     -- HPI Read/Write
        hpi_bil         : out std_logic                      -- HPI Byte Low/High   
    );                                                 
end component wb2hpi_control;  

--------------------------------------------------------------------- 
-- signal declaration 
---------------------------------------------------------------------
signal pci_address_r    : std_logic_vector(31 downto 1);
signal pci_counter_r    : std_logic_vector(15 downto 0); 
signal hpi_command_r    : std_logic_vector( 2 downto 0);  
signal start_hpi_comm   : std_logic; 
signal hpi_address_r    : std_logic_vector(15 downto 0);  
signal hpi_data_r       : std_logic_vector(17 downto 0);
signal pci_address      : std_logic_vector(31 downto 1);
signal pci_counter      : std_logic_vector(15 downto 0); 
signal hpi_counter      : std_logic_vector(15 downto 0); 
signal to_pci_data      : std_logic_vector(15 downto 0); 
signal from_pci_data    : std_logic_vector(15 downto 0); 
signal pci_start_write  : std_logic;
signal pci_start_read   : std_logic;
signal pci_ready        : std_logic;
signal pci_strobe_data  : std_logic;
signal hpi_data_out     : std_logic_vector(15 downto 0);
signal hpi_ready        : std_logic;
signal dsp_err          : std_logic;
signal int_req1         : std_logic;
signal int_req2         : std_logic;
signal dsp_reset        : std_logic;
signal hpi_reset        : std_logic;
signal hpi_rst          : std_logic;
signal hpi_end_transfer : std_logic;
signal hpi_data_is_rdy  : std_logic; 
signal pci_error        : std_logic;   



begin               -- architecture RTL of myTop     
    WB_slave : wb2hpi_WBslave port map (
        WB_CLK_I        =>  WB_CLK_I,
        WB_RST_I        =>  WB_RST_I,
        WBS_CYC_I       =>  WBS_CYC_I,
        WBS_STB_I       =>  WBS_STB_I,
        WBS_WE_I        =>  WBS_WE_I,
        WBS_CAB_I       =>  WBS_CAB_I,
        WBS_ADR_I       =>  WBS_ADR_I,
        WBS_DAT_I       =>  WBS_DAT_I,
        WBS_SEL_I       =>  WBS_SEL_I,
        WBS_ACK_O       =>  WBS_ACK_O,
        WBS_ERR_O       =>  WBS_ERR_O,
        WBS_RTY_O       =>  WBS_RTY_O,
        WBS_DAT_O       =>  WBS_DAT_O,
        int_req         =>  INT_REQ, 
        pci_address_r   =>  pci_address_r,  
        pci_counter_r   =>  pci_counter_r, 
        hpi_command_r   =>  hpi_command_r,  
        hpi_address_r   =>  hpi_address_r,       
        hpi_data_r      =>  hpi_data_r, 
        hpi_data_out    =>  to_pci_data,
        start_hpi_comm  =>  start_hpi_comm,
        hpi_counter     =>  hpi_counter, 
        hpi_pci_addr    =>  pci_address,    
        hpi_int_req1    =>  int_req1,
        hpi_int_req2    =>  int_req2,
        dsp_reset       =>  dsp_reset,
        hpi_reset       =>  hpi_reset,
        dsp_ready       =>  DSP_HRDY_PAD_I,
        dsp_hint        =>  DSP_HINT_PAD_I,
        hpi_ready       =>  hpi_ready,
        hpi_end_transfer=>  hpi_end_transfer,
        hpi_data_is_rdy =>  hpi_data_is_rdy,
        pci_error       =>  pci_error,
        led             =>  LED
    );
    
    WB_master: wb2hpi_WBmaster port map (
        WB_CLK_I        =>  WB_CLK_I,
        WB_RST_I        =>  WB_RST_I,
        WBM_ACK_I       =>  WBM_ACK_I,
        WBM_ERR_I       =>  WBM_ERR_I,
        WBM_RTY_I       =>  WBM_RTY_I,
        WBM_DAT_I       =>  WBM_DAT_I,
        WBM_CYC_O       =>  WBM_CYC_O,
        WBM_STB_O       =>  WBM_STB_O,
        WBM_WE_O        =>  WBM_WE_O,
        WBM_CAB_O       =>  WBM_CAB_O,
        WBM_ADR_O       =>  WBM_ADR_O,
        WBM_DAT_O       =>  WBM_DAT_O,
        WBM_SEL_O       =>  WBM_SEL_O,
        pci_address     =>  pci_address,
        pci_counter     =>  pci_counter,
        pci_data_in     =>  to_pci_data, 
        start_write     =>  pci_start_write,
        start_read      =>  pci_start_read,
        pci_error       =>  pci_error,
        ready           =>  pci_ready, 
		pci_data_out    =>  from_pci_data,
        pci_get_next    =>  pci_strobe_data
    );
    
    hpi_rst <= hpi_reset or WB_RST_I;
    
    DSP: wb2hpi_control port map (
        clk             =>  WB_CLK_I,
        reset           =>  hpi_rst,
        hpi_data_r      =>  hpi_data_r,
        hpi_address_r   =>  hpi_address_r,
        hpi_command_r   =>  hpi_command_r,
        pci_address_r   =>  pci_address_r,
        pci_counter_r   =>  pci_counter_r,
        start           =>  start_hpi_comm,   
		from_pci_data   =>  from_pci_data,
        pci_get_next    =>  pci_strobe_data,
        pci_ready       =>  pci_ready, 
        pci_start_write =>  pci_start_write,
        pci_start_read  =>  pci_start_read,
        pci_counter     =>  pci_counter,
        pci_address     =>  pci_address,
        to_pci_data     =>  to_pci_data,  
        dsp_hint        =>  DSP_HINT_PAD_I,
        dsp_int2        =>  DSP_INT2_PAD_O,
        hpi_ad_in       =>  DSP_HAD_I,
        hpi_ad_out      =>  DSP_HAD_O,
        hpi_ad_en       =>  DSP_HAD_ENn,
        hpi_cntl        =>  DSP_HCNTL_PAD_O,
        hpi_cs_n        =>  DSP_HCS_PAD_O, 
        hpi_ds_n        =>  DSP_HDS1_PAD_O,
        hpi_rdy         =>  DSP_HRDY_PAD_I, 
        hpi_rw          =>  DSP_HRW_PAD_O,
        hpi_bil         =>  DSP_HBIL_PAD_O,
        int_req1        =>  int_req1,
        int_req2        =>  int_req2,
        counter         =>  hpi_counter,
        ready           =>  hpi_ready,
        end_transfer    =>  hpi_end_transfer,
        hpi_data_is_rdy =>  hpi_data_is_rdy
    );	 
	
    DSP_HDS2_PAD_O  <=  '1'; 
    DSP_HAS_PAD_O   <=  '1';
    DSP_RST_PAD_O   <=  dsp_reset; 
    DSP_INT2_PAD_O  <=  DSP_HINT_PAD_I;  
    
end architecture RTL;




