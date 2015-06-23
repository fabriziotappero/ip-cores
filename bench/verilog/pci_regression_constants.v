//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "pci_regression_constants.v"                      ////
////                                                              ////
////  This file is part of the "PCI bridge" project               ////
////  http://www.opencores.org/cores/pci/                         ////
////                                                              ////
////  Author(s):                                                  ////
////      - Miha Dolenc (mihad@opencores.org)                     ////
////      - Tadej Markovic (tadej@opencores.org)                  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Miha Dolenc, mihad@opencores.org          ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.7  2004/07/07 12:45:02  mihad
// Added SubsystemVendorID, SubsystemID, MAXLatency, MinGnt defines.
// Enabled value loading from serial EEPROM for all of the above + VendorID and DeviceID registers.
//
// Revision 1.6  2004/01/24 11:54:16  mihad
// Update! SPOCI Implemented!
//
// Revision 1.5  2003/12/19 11:11:28  mihad
// Compact PCI Hot Swap support added.
// New testcases added.
// Specification updated.
// Test application changed to support WB B3 cycles.
//
// Revision 1.4  2003/07/29 08:19:46  mihad
// Found and simulated the problem in the synchronization logic.
// Repaired the synchronization logic in the FIFOs.
//
// Revision 1.3  2002/08/13 11:03:51  mihad
// Added a few testcases. Repaired wrong reset value for PCI_AM5 register. Repaired Parity Error Detected bit setting. Changed PCI_AM0 to always enabled(regardles of PCI_AM0 define), if image 0 is used as configuration image
//
// Revision 1.2  2002/02/19 16:32:29  mihad
// Modified testbench and fixed some bugs
//
// Revision 1.1  2002/02/01 13:39:43  mihad
// Initial testbench import. Still under development
//
//

///////////////////////////////////////////////////////////////////////////////
//// ===================================================================== ////
//// Following PCI_USER_CONSTANTS are just for regression testing purposes ////
////   (script for running regression is prepared for NC-Sim)              ////
////                                                                       ////
////   For description of defines see pci_user_constants.v file !          ////
//// ===================================================================== ////
///////////////////////////////////////////////////////////////////////////////

    // Fifo implementation defines:
    // If FPGA and XILINX are defined, Xilinx's BlockSelectRAM+ is instantiated for Fifo storage.
    // 16 bit width is used, so 8 bits of address ( 256 ) locations are available. If RAM_DONT_SHARE is not defined (commented out),
    // then one block RAM is shared between two FIFOs. That means each Fifo can have a maximum address length of 7 - depth of 128 and only 6 block rams are used
    // If RAM_DONT_SHARE is defined ( not commented out ), then 12 block RAMs are used and each Fifo can have a maximum address length of 8 ( 256 locations )
    // If FPGA is not defined, then ASIC RAMs are used. Currently there is only one version of ARTISAN RAM supported. User should generate synchronous RAM with
    // width of 40 and instantiate it in pci_tpram.v. If RAM_DONT_SHARE is defined, then these can be dual port rams ( write port
    // in one clock domain, read in other ), otherwise it must be two port RAM ( read and write ports in both clock domains ).
    // If RAM_DONT_SHARE is defined, then all RAM address lengths must be specified accordingly, otherwise there are two relevant lengths - PCI_FIFO_RAM_ADDR_LENGTH and
    // WB_FIFO_RAM_ADDR_LENGTH.
    
`ifdef REGR_FIFO_SMALL_XILINX // with Xilinx FPGA parameters only
    `define WBW_ADDR_LENGTH 3
    `define WBR_ADDR_LENGTH 4
    `define PCIW_ADDR_LENGTH 4
    `define PCIR_ADDR_LENGTH 3
    
    `define FPGA
    `define XILINX
    
    `define WB_RAM_DONT_SHARE
    `define PCI_RAM_DONT_SHARE
        
    `define PCI_FIFO_RAM_ADDR_LENGTH 4      // PCI target unit fifo storage definition
    `define WB_FIFO_RAM_ADDR_LENGTH 4       // WB slave unit fifo storage definition
    `define PCI_XILINX_DIST_RAM
    `define WB_XILINX_DIST_RAM
`endif        

`ifdef REGR_FIFO_MEDIUM_XILINX
    `define WBW_ADDR_LENGTH 8
    `define WBR_ADDR_LENGTH 8
    `define PCIW_ADDR_LENGTH 8
    `define PCIR_ADDR_LENGTH 8
    
    `define FPGA
    `define XILINX
    
    `define WB_RAM_DONT_SHARE
    `define PCI_RAM_DONT_SHARE
        
    `define PCI_FIFO_RAM_ADDR_LENGTH 8      // PCI target unit fifo storage definition
    `define WB_FIFO_RAM_ADDR_LENGTH 8       // WB slave unit fifo storage definition
    `define PCI_XILINX_RAMB4
    `define WB_XILINX_RAMB4
`endif
        
`ifdef REGR_FIFO_MEDIUM_ARTISAN // with Artisan parameter only
    `define WBW_ADDR_LENGTH 7
    `define WBR_ADDR_LENGTH 6
    `define PCIW_ADDR_LENGTH 7
    `define PCIR_ADDR_LENGTH 8
    
    `define PCI_RAM_DONT_SHARE
    
    `define PCI_FIFO_RAM_ADDR_LENGTH 8      // PCI target unit fifo storage definition when RAM sharing is used ( both pcir and pciw fifo use same instance of RAM )
    `define WB_FIFO_RAM_ADDR_LENGTH 8       // WB slave unit fifo storage definition when RAM sharing is used ( both wbr and wbw fifo use same instance of RAM )
    `define WB_ARTISAN_SDP
    `define PCI_ARTISAN_SDP
`endif

`ifdef REGR_FIFO_SMALL_GENERIC // without any parameters only (generic)
    `define WBW_ADDR_LENGTH 3
    `define WBR_ADDR_LENGTH 4
    `define PCIW_ADDR_LENGTH 4
    `define PCIR_ADDR_LENGTH 3
    
    `define WB_RAM_DONT_SHARE
    `define PCI_RAM_DONT_SHARE
        
    `define PCI_FIFO_RAM_ADDR_LENGTH 4      // PCI target unit fifo storage definition when RAM sharing is used ( both pcir and pciw fifo use same instance of RAM )
    `define WB_FIFO_RAM_ADDR_LENGTH 4       // WB slave unit fifo storage definition when RAM sharing is used ( both wbr and wbw fifo use same instance of RAM )

`endif

`ifdef REGR_FIFO_MEDIUM_GENERIC // without any parameters only (generic)
    `define WBW_ADDR_LENGTH 7
    `define WBR_ADDR_LENGTH 6
    `define PCIW_ADDR_LENGTH 7
    `define PCIR_ADDR_LENGTH 8
    
    `define PCI_RAM_DONT_SHARE
    `define WB_RAM_DONT_SHARE
    
    `define PCI_FIFO_RAM_ADDR_LENGTH 8      // PCI target unit fifo storage definition when RAM sharing is used ( both pcir and pciw fifo use same instance of RAM )
    `define WB_FIFO_RAM_ADDR_LENGTH 7       // WB slave unit fifo storage definition when RAM sharing is used ( both wbr and wbw fifo use same instance of RAM )
`endif

`ifdef REGR_FIFO_LARGE_GENERIC // without any parameters only (generic)
    `define WBW_ADDR_LENGTH 9
    `define WBR_ADDR_LENGTH 9
    `define PCIW_ADDR_LENGTH 9
    `define PCIR_ADDR_LENGTH 9
    
    `define PCI_FIFO_RAM_ADDR_LENGTH 9      // PCI target unit fifo storage definition when RAM sharing is used ( both pcir and pciw fifo use same instance of RAM )
    `define WB_FIFO_RAM_ADDR_LENGTH 9       // WB slave unit fifo storage definition when RAM sharing is used ( both wbr and wbw fifo use same instance of RAM )

    `define PCI_RAM_DONT_SHARE
    `define WB_RAM_DONT_SHARE

`endif
    
    // number defined here specifies how many MS bits in PCI address are compared with base address, to decode
    // accesses. Maximum number allows for minimum image size ( number = 20, image size = 4KB ), minimum number
    // allows for maximum image size ( number = 1, image size = 2GB ). If you intend on using different sizes of PCI images,
    // you have to define a number of minimum sized image and enlarge others by specifying different address mask.
    // smaller the number here, faster the decoder operation

    // initial value for PCI image address masks. Address masks can be defined in enabled state,
    // to allow device independent software to detect size of image and map base addresses to
    // memory space. If initial mask for an image is defined as 0, then device independent software
    // won't detect base address implemented and device dependent software will have to configure
    // address masks as well as base addresses!

    // initial value for PCI image maping to MEMORY or IO spaces.  If initial define is set to 0,
    // then IMAGE with that base address points to MEMORY space, othervise it points ti IO space. D
    // Device independent software sets the base addresses acording to MEMORY or IO maping!

`ifdef PCI_DECODE_MIN

	`define PCI_NUM_OF_DEC_ADDR_LINES 3


    // don't disable AM0 if GUEST bridge, otherwise there is no other way of accesing configuration space
    `ifdef HOST
    	`define PCI_AM0 24'h0000_00
    `else
    	`define PCI_AM0 24'hE000_00
    `endif

    `ifdef PCI_SPOCI
        `define PCI_AM1 24'h0000_00
        `define PCI_AM2 24'h0000_00
        `define PCI_AM3 24'h0000_00
        `define PCI_AM4 24'h0000_00
        `define PCI_AM5 24'h0000_00
    `else
        `define PCI_AM1 24'hE000_00
        `define PCI_AM2 24'h0000_00
        `define PCI_AM3 24'hE000_00
        `define PCI_AM4 24'h0000_00
        `define PCI_AM5 24'hE000_00
    `endif

    `define PCI_BA0_MEM_IO 1'b1 // considered only when PCI_IMAGE0 is used as general PCI-WB image!
    `define PCI_BA1_MEM_IO 1'b0
    `define PCI_BA2_MEM_IO 1'b1
    `define PCI_BA3_MEM_IO 1'b0
    `define PCI_BA4_MEM_IO 1'b1
    `define PCI_BA5_MEM_IO 1'b0

    `define TAR0_ADDR_MASK_0    32'hFFFF_F000 // when BA0 is used to access configuration space, this is NOT important!
    `define TAR0_ADDR_MASK_1    32'hFFFF_F000
    `define TAR0_ADDR_MASK_2    32'hFFFF_F000
    `define TAR0_ADDR_MASK_3    32'hFFFF_F000
    `define TAR0_ADDR_MASK_4    32'hFFFF_F000
    `define TAR0_ADDR_MASK_5    32'hFFFF_F000

`endif

`ifdef PCI_DECODE_MED

        `define PCI_NUM_OF_DEC_ADDR_LINES 12

    `ifdef PCI_SPOCI
        `define PCI_AM0 24'hfff0_00
        `define PCI_AM1 24'h0000_00
        `define PCI_AM2 24'h0000_00
        `define PCI_AM3 24'h0000_00
        `define PCI_AM4 24'h0000_00
        `define PCI_AM5 24'h0000_00
    `else
        `define PCI_AM0 24'hfff0_00
        `define PCI_AM1 24'h0000_00
        `define PCI_AM2 24'hfff0_00
        `define PCI_AM3 24'h0000_00
        `define PCI_AM4 24'hfff0_00
        `define PCI_AM5 24'h0000_00
    `endif

        `define PCI_BA0_MEM_IO 1'b1 // considered only when PCI_IMAGE0 is used as general PCI-WB image!
        `define PCI_BA1_MEM_IO 1'b0
        `define PCI_BA2_MEM_IO 1'b1
        `define PCI_BA3_MEM_IO 1'b0
        `define PCI_BA4_MEM_IO 1'b1
        `define PCI_BA5_MEM_IO 1'b0

        `define TAR0_ADDR_MASK_0    32'hFFFF_F000 // when BA0 is used to access configuration space, this is NOT important!
        `define TAR0_ADDR_MASK_1    32'hFFFF_F000
        `define TAR0_ADDR_MASK_2    32'hFFFF_F000
        `define TAR0_ADDR_MASK_3    32'hFFFF_F000
        `define TAR0_ADDR_MASK_4    32'hFFFF_F000
        `define TAR0_ADDR_MASK_5    32'hFFFF_F000
`endif

`ifdef PCI_DECODE_MAX

    `define PCI_NUM_OF_DEC_ADDR_LINES 24

    `ifdef PCI_SPOCI
        `define PCI_AM0 24'hffff_f0
        `define PCI_AM1 24'h0000_00
        `define PCI_AM2 24'h0000_00
        `define PCI_AM3 24'h0000_00
        `define PCI_AM4 24'h0000_00
        `define PCI_AM5 24'h0000_00
    `else
        `define PCI_AM0 24'hffff_f0
        `define PCI_AM1 24'hffff_ff
        `define PCI_AM2 24'hffff_fe
        `define PCI_AM3 24'hffff_e0
        `define PCI_AM4 24'hffff_c0
        `define PCI_AM5 24'hffff_80
    `endif

    `define PCI_BA0_MEM_IO 1'b0 // considered only when PCI_IMAGE0 is used as general PCI-WB image!
    `define PCI_BA1_MEM_IO 1'b1
    `define PCI_BA2_MEM_IO 1'b1
    `define PCI_BA3_MEM_IO 1'b0
    `define PCI_BA4_MEM_IO 1'b0
    `define PCI_BA5_MEM_IO 1'b0

    `define TAR0_ADDR_MASK_0    32'hFFFF_F000 // when BA0 is used to access configuration space, this is NOT important!
    `define TAR0_ADDR_MASK_1    32'hFFFF_FF00
    `define TAR0_ADDR_MASK_2    32'hFFFF_FE00
    `define TAR0_ADDR_MASK_3    32'hFFFF_F000
    `define TAR0_ADDR_MASK_4    32'hFFFF_F000
    `define TAR0_ADDR_MASK_5    32'hFFFF_F000

`endif        
    
    // number defined here specifies how many MS bits in WB address are compared with base address, to decode
    // accesses. Maximum number allows for minimum image size ( number = 20, image size = 4KB ), minimum number
    // allows for maximum image size ( number = 1, image size = 2GB ). If you intend on using different sizes of WB images,
    // you have to define a number of minimum sized image and enlarge others by specifying different address mask.
    // smaller the number here, faster the decoder operation
`ifdef WB_DECODE_MIN
	`define WB_NUM_OF_DEC_ADDR_LINES 4
`endif

`ifdef WB_DECODE_MED
	`define WB_NUM_OF_DEC_ADDR_LINES 12
`endif
    
`ifdef WB_DECODE_MAX
	`define WB_NUM_OF_DEC_ADDR_LINES 20
`endif
    
// Base address for Configuration space access from WB bus. This value cannot be changed during runtime
`ifdef WB_CNF_BASE_ZERO
    `define WB_CONFIGURATION_BASE 20'h0000_0
`else
    `define WB_CONFIGURATION_BASE 20'hB000_0
`endif
    
    /*-----------------------------------------------------------------------------------------------------------
    [000h-00Ch] First 4 DWORDs (32-bit) of PCI configuration header - the same regardless of the HEADER type !
        Vendor_ID is an ID for a specific vendor defined by PCI_SIG - 2321h does not belong to anyone (e.g.
        Xilinx's Vendor_ID is 10EEh and Altera's Vendor_ID is 1172h). Device_ID and Revision_ID should be used
        together by application.
    -----------------------------------------------------------------------------------------------------------*/
    `define HEADER_VENDOR_ID        16'h1895
    `define HEADER_DEVICE_ID        16'h0001
    `define HEADER_REVISION_ID      8'h01
    `define HEADER_SUBSYS_VENDOR_ID 16'h1895
    `define HEADER_SUBSYS_ID        16'h0001
    `define HEADER_MAX_LAT          8'h1a
    `define HEADER_MIN_GNT          8'h08

    
    // MAX Retry counter value for WISHBONE Master state-machine
    //  This value is 8-bit because of 8-bit retry counter !!!
    `define WB_RTY_CNT_MAX          8'hff
    
/////////////////////////////////////////////////////////////////////////////////
//// ======================================================================= ////
//// Following PCI_TESTBENC_DEFINES are just for regression testing purposes ////
////   (script for running regression is prepared for NC-Sim)                ////
////                                                                         ////
////   For description of defines see pci_testbench_defines.v file !         ////
//// ======================================================================= ////
/////////////////////////////////////////////////////////////////////////////////

    // wishbone frequncy in GHz
    `ifdef WB_CLK10
        `define WB_PERIOD 100.0
    `endif
    `ifdef WB_CLK66
        `define WB_PERIOD 15.0
    `endif
    `ifdef WB_CLK220
        `define WB_PERIOD 4.5
    `endif
    
    // values of image registers of PCI bridge device - valid are only upper 24 bits, others must be ZERO !
    `define TAR0_BASE_ADDR_0    32'h1000_0000
    `define TAR0_BASE_ADDR_1    32'h2000_0000
    `define TAR0_BASE_ADDR_2    32'h4000_0000
    `define TAR0_BASE_ADDR_3    32'h6000_0000
    `define TAR0_BASE_ADDR_4    32'h8000_0000
    `define TAR0_BASE_ADDR_5    32'hA000_0000
    
    `define TAR0_TRAN_ADDR_0    32'hC000_0000 // when BA0 is used to access configuration space, this is NOT important!
    `define TAR0_TRAN_ADDR_1    32'hA000_0000
    `define TAR0_TRAN_ADDR_2    32'h8000_0000
    `define TAR0_TRAN_ADDR_3    32'h6000_0000
    `define TAR0_TRAN_ADDR_4    32'h4000_0000
    `define TAR0_TRAN_ADDR_5    32'h2000_0000
    
    // values of image registers of PCI behavioral target devices !
    `define BEH_TAR1_MEM_START 32'hC000_0000
    `define BEH_TAR1_MEM_END   32'hC000_0FFF
    `define BEH_TAR1_IO_START  32'hD000_0001
    `define BEH_TAR1_IO_END    32'hD000_0FFF
    
    `define BEH_TAR2_MEM_START 32'hE000_0000
    `define BEH_TAR2_MEM_END   32'hE000_0FFF
    `define BEH_TAR2_IO_START  32'hF000_0001
    `define BEH_TAR2_IO_END    32'hF000_0FFF

    // IDSEL lines of each individual Target is connected to one address line
    // following defines set the address line IDSEL is connected to
    // TAR0 = DUT - bridge
    // TAR1 = behavioral target 1
    // TAR2 = behavioral target 2

    `define TAR0_IDSEL_INDEX    31
    `define TAR1_IDSEL_INDEX    29
    `define TAR2_IDSEL_INDEX    30

    // next 3 defines are derived from previous three defines
    `define TAR0_IDSEL_ADDR     (32'h0000_0001 << `TAR0_IDSEL_INDEX)
    `define TAR1_IDSEL_ADDR     (32'h0000_0001 << `TAR1_IDSEL_INDEX)
    `define TAR2_IDSEL_ADDR     (32'h0000_0001 << `TAR2_IDSEL_INDEX)

    // other initial values
    // PCI Translation addresses
    `define PCI_TA0 24'hffff_f0
    `define PCI_TA1 24'hffff_e0
    `define PCI_TA2 24'hffff_c0
    `define PCI_TA3 24'hffff_80
    `define PCI_TA4 24'hffff_00
    `define PCI_TA5 24'hfffe_00

    `define PCI_AT_EN0 1'b1
    `define PCI_AT_EN1 1'b0
    `define PCI_AT_EN2 1'b1
    `define PCI_AT_EN3 1'b0
    `define PCI_AT_EN4 1'b1
    `define PCI_AT_EN5 1'b0

    // WB Images' base addresses
    `define  WB_BA1	20'hffff_f
    `define  WB_BA2	20'hffff_e
    `define  WB_BA3	20'hffff_c
    `define  WB_BA4	20'hffff_8
    `define  WB_BA5	20'hffff_0

    // WISHBONE Address space mapping
    `define  WB_BA1_MEM_IO  1'b0
    `define  WB_BA2_MEM_IO  1'b0
    `define  WB_BA3_MEM_IO	1'b0
    `define  WB_BA4_MEM_IO	1'b0
    `define  WB_BA5_MEM_IO	1'b0

    // wishbone address masks
    `define  WB_AM1 20'h0000_0
    `define  WB_AM2 20'h0000_0
    `define  WB_AM3 20'h0000_0
    `define  WB_AM4 20'h0000_0
    `define  WB_AM5 20'h0000_0
  
    // wishbone translation addresses
    `define WB_TA1 20'hffff_f
    `define WB_TA2 20'hffff_e
    `define WB_TA3 20'hffff_c
    `define WB_TA4 20'hffff_8
    `define WB_TA5 20'hffff_0
    
    `define WB_AT_EN1 1'b1
    `define WB_AT_EN2 1'b0
    `define WB_AT_EN3 1'b1
    `define WB_AT_EN4 1'b0
    `define WB_AT_EN5 1'b1


/*=======================================================================================
  Following defines are used in a script file for regression testing !!!
=========================================================================================

  REGRESSION
    HOST                        GUEST
    REGR_FIFO_SMALL_XILINX      REGR_FIFO_MEDIUM_ARTISAN        REGR_FIFO_LARGE_GENERIC
    (REGR_FIFO_SMALL_GENERIC)   (REGR_FIFO_MEDIUM_GENERIC)
    ADDR_TRAN_IMPL
    WB_RETRY_MAX
    WB_CNF_BASE_ZERO
    NO_CNF_IMAGE
    PCI_IMAGE0 // `ifdef HOST `ifdef NO_CNF_IMAGE `define PCI_IMAGE0
    PCI_IMAGE2
    PCI_IMAGE3  
    PCI_IMAGE4
    PCI_IMAGE5 
    WB_IMAGE2
    WB_IMAGE3
    WB_IMAGE4
    WB_IMAGE5
    WB_DECODE_FAST              WB_DECODE_MEDIUM                WB_DECODE_SLOW
    REGISTER_WBM_OUTPUTS
    REGISTER_WBS_OUTPUTS
    PCI_DECODE_MIN              PCI_DECODE_MED                  PCI_DECODE_MAX
    WB_DECODE_MIN               WB_DECODE_MED                   WB_DECODE_MAX
    PCI33                       PCI66
    WB_CLK10                    WB_CLK66                        WB_CLK100
    ACTIVE_LOW_OE               ACTIVE_HIGH_OE

-----------------------------------------------------------------------------------------
  Follows combinations of defines used in a script file for regression testing !!!
-----------------------------------------------------------------------------------------

  "REGRESSION+HOST+REGR_FIFO_SMALL_XILINX+WB_DECODE_FAST+PCI_DECODE_MAX+WB_DECODE_MIN+PCI33+WB_CLK10+ACTIVE_LOW_OE+REGISTER_WBM_OUTPUTS+REGISTER_WBS_OUTPUTS+ADDR_TRAN_IMPL+WB_RETRY_MAX+PCI_IMAGE0+PCI_IMAGE2"
  "REGRESSION+HOST+REGR_FIFO_MEDIUM_ARTISAN+WB_DECODE_MEDIUM+PCI_DECODE_MED+WB_DECODE_MED+PCI33+WB_CLK66+ACTIVE_LOW_OE+REGISTER_WBM_OUTPUTS+REGISTER_WBS_OUTPUTS+ADDR_TRAN_IMPL+WB_RETRY_MAX+PCI_IMAGE0+PCI_IMAGE2+PCI_IMAGE3+PCI_IMAGE4+PCI_IMAGE5+WB_IMAGE2+WB_IMAGE5"
  "REGRESSION+HOST+REGR_FIFO_LARGE_GENERIC+WB_DECODE_SLOW+PCI_DECODE_MIN+WB_DECODE_MAX+PCI66+WB_CLK66+ACTIVE_LOW_OE+REGISTER_WBM_OUTPUTS+REGISTER_WBS_OUTPUTS+WB_IMAGE5"
  "REGRESSION+GUEST+REGR_FIFO_SMALL_XILINX+WB_DECODE_SLOW+PCI_DECODE_MED+WB_DECODE_MIN+PCI66+WB_CLK100+ACTIVE_LOW_OE+REGISTER_WBM_OUTPUTS+REGISTER_WBS_OUTPUTS+WB_RETRY_MAX+PCI_IMAGE0+PCI_IMAGE5+WB_IMAGE4"
  "REGRESSION+GUEST+REGR_FIFO_MEDIUM_ARTISAN+WB_DECODE_FAST+PCI_DECODE_MIN+WB_DECODE_MAX+PCI33+WB_CLK100+ACTIVE_LOW_OE+REGISTER_WBM_OUTPUTS+REGISTER_WBS_OUTPUTS+ADDR_TRAN_IMPL+PCI_IMAGE0+WB_IMAGE2+WB_IMAGE3+WB_IMAGE4"
  "REGRESSION+GUEST+REGR_FIFO_LARGE_GENERIC+WB_DECODE_MEDIUM+PCI_DECODE_MAX+WB_DECODE_MED+PCI66+WB_CLK10+ACTIVE_LOW_OE+REGISTER_WBM_OUTPUTS+REGISTER_WBS_OUTPUTS+ADDR_TRAN_IMPL"
  "REGRESSION+HOST+REGR_FIFO_SMALL_XILINX+WB_DECODE_FAST+PCI_DECODE_MAX+WB_DECODE_MIN+PCI66+WB_CLK100+ACTIVE_HIGH_OE+WB_CNF_BASE_ZERO+NO_CNF_IMAGE+PCI_IMAGE0+PCI_IMAGE4"
  "REGRESSION+HOST+REGR_FIFO_MEDIUM_ARTISAN+WB_DECODE_MEDIUM+PCI_DECODE_MED+WB_DECODE_MED+PCI66+WB_CLK10+ACTIVE_HIGH_OE+WB_CNF_BASE_ZERO+NO_CNF_IMAGE+PCI_IMAGE0+PCI_IMAGE2+PCI_IMAGE3+PCI_IMAGE4+PCI_IMAGE5+WB_IMAGE2+WB_IMAGE3+WB_IMAGE4+WB_IMAGE5"
  "REGRESSION+HOST+REGR_FIFO_LARGE_GENERIC+WB_DECODE_SLOW+PCI_DECODE_MIN+WB_DECODE_MAX+PCI33+WB_CLK100+ACTIVE_HIGH_OE+ADDR_TRAN_IMPL+WB_RETRY_MAX+WB_CNF_BASE_ZERO+NO_CNF_IMAGE+WB_IMAGE3"
  "REGRESSION+GUEST+REGR_FIFO_SMALL_XILINX+WB_DECODE_SLOW+PCI_DECODE_MED+WB_DECODE_MIN+PCI33+WB_CLK66+ACTIVE_HIGH_OE+ADDR_TRAN_IMPL+WB_CNF_BASE_ZERO+NO_CNF_IMAGE+PCI_IMAGE0+PCI_IMAGE3"
  "REGRESSION+GUEST+REGR_FIFO_MEDIUM_ARTISAN+WB_DECODE_FAST+PCI_DECODE_MIN+WB_DECODE_MAX+PCI66+WB_CLK66+ACTIVE_HIGH_OE+WB_RETRY_MAX+WB_CNF_BASE_ZERO+NO_CNF_IMAGE+PCI_IMAGE0+PCI_IMAGE2+PCI_IMAGE3+PCI_IMAGE4+PCI_IMAGE5+WB_IMAGE2"
  "REGRESSION+GUEST+REGR_FIFO_LARGE_GENERIC+WB_DECODE_MEDIUM+PCI_DECODE_MAX+WB_DECODE_MED+PCI33+WB_CLK10+ACTIVE_HIGH_OE+WB_RETRY_MAX+WB_CNF_BASE_ZERO+NO_CNF_IMAGE+WB_IMAGE2+WB_IMAGE3+WB_IMAGE4+WB_IMAGE5"
  ""

=========================================================================================
*/













