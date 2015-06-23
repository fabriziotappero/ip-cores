////////////////////////////////////////////////////////////////////
//     --------------                                             //
//    /      SOC     \                                            //
//   /       GEN      \                                           //
//  /     COMPONENT    \                                          //
//  ====================                                          //
//  |digital done right|                                          //
//  |__________________|                                          //
//                                                                //
//                                                                //
//                                                                //
//    Copyright (C) <2010>  <Ouabache DesignWorks>                //
//                                                                //
//                                                                //  
//   This source file may be used and distributed without         //  
//   restriction provided that this copyright statement is not    //  
//   removed from the file and that any derivative work contains  //  
//   the original copyright notice and the associated disclaimer. //  
//                                                                //  
//   This source file is free software; you can redistribute it   //  
//   and/or modify it under the terms of the GNU Lesser General   //  
//   Public License as published by the Free Software Foundation; //  
//   either version 2.1 of the License, or (at your option) any   //  
//   later version.                                               //  
//                                                                //  
//   This source is distributed in the hope that it will be       //  
//   useful, but WITHOUT ANY WARRANTY; without even the implied   //  
//   warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      //  
//   PURPOSE.  See the GNU Lesser General Public License for more //  
//   details.                                                     //  
//                                                                //  
//   You should have received a copy of the GNU Lesser General    //  
//   Public License along with this source; if not, download it   //  
//   from http://www.opencores.org/lgpl.shtml                     //  
//                                                                //  
////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////									////
//// T6507LP IP Core	 						////
////									////
//// This file is part of the T6507LP project				////
//// http://www.opencores.org/cores/t6507lp/				////
////									////
//// Description							////
//// Implementation of a 6507-compatible microprocessor			////
////									////
//// To Do:								////
//// - Everything							////
////									////
//// Author(s):								////
//// - Gabriel Oshiro Zardo, gabrieloshiro@gmail.com			////
//// - Samuel Nascimento Pagliarini (creep), snpagliarini@gmail.com	////
////									////
////////////////////////////////////////////////////////////////////////////
////									////
//// Copyright (C) 2001 Authors and OPENCORES.ORG			////
////									////
//// This source file may be used and distributed without		////
//// restriction provided that this copyright statement is not		////
//// removed from the file and that any derivative work contains	////
//// the original copyright notice and the associated disclaimer.	////
////									////
//// This source file is free software; you can redistribute it		////
//// and/or modify it under the terms of the GNU Lesser General		////
//// Public License as published by the Free Software Foundation;	////
//// either version 2.1 of the License, or (at your option) any		////
//// later version.							////
////									////
//// This source is distributed in the hope that it will be		////
//// useful, but WITHOUT ANY WARRANTY; without even the implied		////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR		////
//// PURPOSE. See the GNU Lesser General Public License for more	////
//// details.								////
////									////
//// You should have received a copy of the GNU Lesser General		////
//// Public License along with this source; if not, download it		////
//// from http://www.opencores.org/lgpl.shtml				////
////									////
////////////////////////////////////////////////////////////////////////////
 module 
  T6502_ctrl 
    #( parameter 
      PG0_ADDR=7,
      PG0_WIDTH=8,
      PG0_WORDS=128,
      PG0_WRITETHRU=0,
      VEC_TABLE=8'hff)
     (
 input   wire                 clk,
 input   wire                 mem_cs,
 input   wire                 mem_rd,
 input   wire                 mem_wr,
 input   wire                 pg0_rd,
 input   wire                 pg0_wr,
 input   wire                 ps2_data_avail,
 input   wire                 rx_irq,
 input   wire                 tx_irq,
 input   wire    [ 0 :  0]        mem_addr,
 input   wire    [ 1 :  0]        timer_irq,
 input   wire    [ 15 :  0]        mem_wdata,
 input   wire    [ 2 :  0]        ext_irq_in,
 input   wire    [ 7 :  0]        pg0_add,
 output   wire                 pg00_ram_h_wr,
 output   wire                 pg00_ram_l_wr,
 output   wire                 pg00_ram_rd,
 output   wire    [ 15 :  0]        mem_rdata,
 output   wire    [ 7 :  0]        cpu_pg0_data,
 output   wire    [ 7 :  0]        io_module_pic_irq_in,
 output   wire    [ 7 :  0]        io_module_vic_irq_in);
cde_sram_dp
#( .ADDR (PG0_ADDR),
   .WIDTH (PG0_WIDTH),
   .WORDS (PG0_WORDS),
   .WRITETHRU (PG0_WRITETHRU))
pg00_ram_h 
   (
    .clk      ( clk  ),
    .cs      ( 1'b1  ),
    .raddr      ( pg0_add[7:1] ),
    .rd      ( pg00_ram_rd  ),
    .rdata      ( mem_rdata[15:8] ),
    .waddr      ( pg0_add[7:1] ),
    .wdata      ( mem_wdata[15:8] ),
    .wr      ( pg00_ram_h_wr  ));
cde_sram_dp
#( .ADDR (PG0_ADDR),
   .WIDTH (PG0_WIDTH),
   .WORDS (PG0_WORDS),
   .WRITETHRU (PG0_WRITETHRU))
pg00_ram_l 
   (
    .clk      ( clk  ),
    .cs      ( 1'b1  ),
    .raddr      ( pg0_add[7:1] ),
    .rd      ( pg00_ram_rd  ),
    .rdata      ( mem_rdata[7:0] ),
    .waddr      ( pg0_add[7:1] ),
    .wdata      ( mem_wdata[7:0] ),
    .wr      ( pg00_ram_l_wr  ));
//=============================================================================
//    Rtl Glue Logic
//============================================================================= 
   assign cpu_pg0_data             =   pg0_add[0]?mem_rdata[15:8]:mem_rdata[7:0];
   assign pg00_ram_rd              =   pg0_rd||(mem_cs    && mem_rd);
   assign pg00_ram_l_wr            =  (pg0_wr||(mem_cs    && mem_wr)) && (!pg0_add[0]);
   assign pg00_ram_h_wr            =  (pg0_wr||(mem_cs    && mem_wr)) && ( pg0_add[0]);
   assign io_module_pic_irq_in     =  {ext_irq_in[2:0],ps2_data_avail,tx_irq,rx_irq,timer_irq};
   assign io_module_vic_irq_in     =  {ext_irq_in[2:0],ps2_data_avail,tx_irq,rx_irq,timer_irq};
//=============================================================================
//    
//============================================================================= 
  endmodule
