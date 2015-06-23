//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "pci_bench_common_tasks.v"                        ////
////                                                              ////
////  This file is part of the "PCI bridge" project               ////
////  http://www.opencores.org/cores/pci/                         ////
////                                                              ////
////  Author(s):                                                  ////
////      - Miha Dolenc (mihad@opencores.org)                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2003 Miha Dolenc, mihad@opencores.org          ////
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
// Revision 1.1  2003/01/21 16:06:50  mihad
// Bug fixes, testcases added.
//
//

task pci_configure_pci_target_image ;
    input [2:0]  image_num ; // image number
    input [31:0] ba ;        // base address
    input [31:0] am ;        // address mask
    input [31:0] ta ;        // translation address
    input        io_nmem ;   // io/mem mapping select
    input        pref_en ;   // prefetch enable
    input        at_en ;     // address translation enable
    output       ok ;        // finished succesfully

    reg          in_use ;
    reg   [11:0] ctrl_offset ;
    reg   [11:0] ba_offset ;
    reg   [11:0] am_offset ;
    reg   [11:0] ta_offset ; 
begin:main
    if (in_use === 1'b1)
    begin
        $display("Time %t", $time) ;
        $display("pci_configure_pci_target_image task re-entered") ;
        ok = 0 ;
        disable main ;
    end

    in_use = 1'b1 ;

    if (image_num === 0)
    begin
        ctrl_offset = {4'h1, `P_IMG_CTRL0_ADDR, 2'b00} ;
        ba_offset   = {4'h1, `P_BA0_ADDR, 2'b00} ;
        am_offset   = {4'h1, `P_AM0_ADDR, 2'b00} ;
        ta_offset   = {4'h1, `P_TA0_ADDR, 2'b00} ;
    end
    else if (image_num === 1)
    begin
        ctrl_offset = {4'h1, `P_IMG_CTRL1_ADDR, 2'b00} ;
        ba_offset   = {4'h1, `P_BA1_ADDR, 2'b00} ;
        am_offset   = {4'h1, `P_AM1_ADDR, 2'b00} ;
        ta_offset   = {4'h1, `P_TA1_ADDR, 2'b00} ;
    end
    else if (image_num === 2)
    begin
        ctrl_offset = {4'h1, `P_IMG_CTRL2_ADDR, 2'b00} ;
        ba_offset   = {4'h1, `P_BA2_ADDR, 2'b00} ;
        am_offset   = {4'h1, `P_AM2_ADDR, 2'b00} ;
        ta_offset   = {4'h1, `P_TA2_ADDR, 2'b00} ;
    end
    else if (image_num === 3)
    begin
        ctrl_offset = {4'h1, `P_IMG_CTRL3_ADDR, 2'b00} ;
        ba_offset   = {4'h1, `P_BA3_ADDR, 2'b00} ;
        am_offset   = {4'h1, `P_AM3_ADDR, 2'b00} ;
        ta_offset   = {4'h1, `P_TA3_ADDR, 2'b00} ;
    end
    else if (image_num === 4)
    begin
        ctrl_offset = {4'h1, `P_IMG_CTRL4_ADDR, 2'b00} ;
        ba_offset   = {4'h1, `P_BA4_ADDR, 2'b00} ;
        am_offset   = {4'h1, `P_AM4_ADDR, 2'b00} ;
        ta_offset   = {4'h1, `P_TA4_ADDR, 2'b00} ;
    end
    else if (image_num === 5)
    begin
        ctrl_offset = {4'h1, `P_IMG_CTRL5_ADDR, 2'b00} ;
        ba_offset   = {4'h1, `P_BA5_ADDR, 2'b00} ;
        am_offset   = {4'h1, `P_AM5_ADDR, 2'b00} ;
        ta_offset   = {4'h1, `P_TA5_ADDR, 2'b00} ;
    end

    // Set Base Address of IMAGE
    config_write( ba_offset, ba | {31'h0, io_nmem}, 4'hF, ok ) ;
    if ( ok !== 1 )
    begin
        in_use = 1'b0 ;
        disable main ;
    end

    // Set Address Mask of IMAGE
    config_write( am_offset, am, 4'hF, ok ) ;
    if ( ok !== 1 )
    begin
        in_use = 1'b0 ;
        disable main ;
    end

    // Set Translation Address of IMAGE
    config_write( ta_offset, ta, 4'hF, ok ) ;
    if ( ok !== 1 )
    begin
        in_use = 1'b0 ;
        disable main ;
    end

    // Set IMAGE Control Register
    config_write( ctrl_offset, {29'd0, at_en, pref_en, 1'b0}, 4'hF, ok ) ;
    if ( ok !== 1 )
    begin
        in_use = 1'b0 ;
        disable main ;
    end
    in_use = 1'b0 ;
end
endtask // pci_configure_pci_target_image

task pci_configure_wb_slave_image ;
    input [2:0]  image_num ; // image number
    input [31:0] ba ;        // base address
    input [31:0] am ;        // address mask
    input [31:0] ta ;        // translation address
    input        io_nmem ;   // io/mem mapping select
    input        pref_en ;   // prefetch enable
    input        at_en ;     // address translation enable
    input        mrl_en ;    // memory read line enable
    output       ok ;        // finished succesfully

    reg          in_use ;
    reg   [11:0] ctrl_offset ;
    reg   [11:0] ba_offset ;
    reg   [11:0] am_offset ;
    reg   [11:0] ta_offset ;
begin:main
    if (in_use === 1'b1)
    begin
        $display("Time %t", $time) ;
        $display("pci_configure_wb_slave_image task re-entered") ;
        ok = 0 ;
        disable main ;
    end

    in_use = 1'b1 ;

    if (image_num === 1)
    begin
        ctrl_offset = {4'h1, `W_IMG_CTRL1_ADDR, 2'b00} ;
        ba_offset   = {4'h1, `W_BA1_ADDR, 2'b00} ;
        am_offset   = {4'h1, `W_AM1_ADDR, 2'b00} ;
        ta_offset   = {4'h1, `W_TA1_ADDR, 2'b00} ;
    end
    else if (image_num === 2)
    begin
        ctrl_offset = {4'h1, `W_IMG_CTRL2_ADDR, 2'b00} ;
        ba_offset   = {4'h1, `W_BA2_ADDR, 2'b00} ;
        am_offset   = {4'h1, `W_AM2_ADDR, 2'b00} ;
        ta_offset   = {4'h1, `W_TA2_ADDR, 2'b00} ;
    end
    else if (image_num === 3)
    begin
        ctrl_offset = {4'h1, `W_IMG_CTRL3_ADDR, 2'b00} ;
        ba_offset   = {4'h1, `W_BA3_ADDR, 2'b00} ;
        am_offset   = {4'h1, `W_AM3_ADDR, 2'b00} ;
        ta_offset   = {4'h1, `W_TA3_ADDR, 2'b00} ;
    end
    else if (image_num === 4)
    begin
        ctrl_offset = {4'h1, `W_IMG_CTRL4_ADDR, 2'b00} ;
        ba_offset   = {4'h1, `W_BA4_ADDR, 2'b00} ;
        am_offset   = {4'h1, `W_AM4_ADDR, 2'b00} ;
        ta_offset   = {4'h1, `W_TA4_ADDR, 2'b00} ;
    end
    else if (image_num === 5)
    begin
        ctrl_offset = {4'h1, `W_IMG_CTRL5_ADDR, 2'b00} ;
        ba_offset   = {4'h1, `W_BA5_ADDR, 2'b00} ;
        am_offset   = {4'h1, `W_AM5_ADDR, 2'b00} ;
        ta_offset   = {4'h1, `W_TA5_ADDR, 2'b00} ;
    end

    // Set Base Address of IMAGE
    config_write( ba_offset, ba | {31'h0, io_nmem}, 4'hF, ok ) ;
    if ( ok !== 1 )
    begin
        in_use = 1'b0 ;
        disable main ;
    end

    // Set Address Mask of IMAGE
    config_write( am_offset, am, 4'hF, ok ) ;
    if ( ok !== 1 )
    begin
        in_use = 1'b0 ;
        disable main ;
    end

    // Set Translation Address of IMAGE
    config_write( ta_offset, ta, 4'hF, ok ) ;
    if ( ok !== 1 )
    begin
        in_use = 1'b0 ;
        disable main ;
    end

    // Set IMAGE Control Register
    config_write( ctrl_offset, {29'd0, at_en, pref_en, 1'b0}, 4'hF, ok ) ;
    if ( ok !== 1 )
    begin
        in_use = 1'b0 ;
        disable main ;
    end

    in_use = 1'b0 ;
end
endtask // pci_configure_wb_slave_image
