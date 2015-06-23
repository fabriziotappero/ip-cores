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
//    Copyright (C) <2009>  <Ouabache DesignWorks>                //
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
 module 
  io_gpio_def 
     (
 input   wire                 clk,
 input   wire                 cs,
 input   wire                 enable,
 input   wire                 rd,
 input   wire                 reset,
 input   wire                 wr,
 input   wire    [ 3 :  0]        addr,
 input   wire    [ 7 :  0]        gpio_0_in,
 input   wire    [ 7 :  0]        gpio_1_in,
 input   wire    [ 7 :  0]        wdata,
 output   wire    [ 7 :  0]        gpio_0_oe,
 output   wire    [ 7 :  0]        gpio_0_out,
 output   wire    [ 7 :  0]        gpio_1_oe,
 output   wire    [ 7 :  0]        gpio_1_out,
 output   wire    [ 7 :  0]        rdata);
io_gpio_def_mb
gpio_micro_reg
(  
      .clk               ( clk         ),
      .reset             ( reset       ), 
      .enable            ( enable      ),
      .cs                ( cs          ),              
      .wr                ( wr          ),
      .rd                ( rd          ),
      .byte_lanes        ( 1'b1        ),
      .addr              ( addr        ),
      .wdata             ( wdata       ),
      .rdata             ( rdata       ),
      .gpio_0_out_cs         (),
      .gpio_0_out_dec        (),
      .gpio_0_out_wr_0       (),
      .gpio_0_oe_cs          (),
      .gpio_0_oe_dec         (),
      .gpio_0_oe_wr_0        (),
      .gpio_0_in_cs          (),
      .gpio_0_in_dec         (),
      .gpio_1_out_cs         (),
      .gpio_1_out_dec        (),
      .gpio_1_out_wr_0       (),
      .gpio_1_oe_cs          (),
      .gpio_1_oe_dec         (),
      .gpio_1_oe_wr_0        (),
      .gpio_1_in_cs          (),
      .gpio_1_in_dec         (),
      .gpio_0_in_rdata   ( gpio_0_in   ), 
      .gpio_1_in_rdata   ( gpio_1_in   ),
      .next_gpio_0_oe    ( gpio_0_oe   ),
      .next_gpio_1_oe    ( gpio_1_oe   ),
      .next_gpio_0_out   ( gpio_0_out  ),
      .next_gpio_1_out   ( gpio_1_out  ),
      .gpio_0_out_rdata  ( gpio_0_out  ),
      .gpio_1_out_rdata  ( gpio_1_out  ), 
      .gpio_0_oe_rdata   ( gpio_0_oe   ),
      .gpio_1_oe_rdata   ( gpio_1_oe   ),
      .gpio_0_out        ( gpio_0_out  ),
      .gpio_1_out        ( gpio_1_out  ), 
      .gpio_0_oe         ( gpio_0_oe   ),
      .gpio_1_oe         ( gpio_1_oe   )
);
  endmodule
 /*********************************************/  
 /* Vendor:                  opencores.org    */  
 /* Library:                            io    */  
 /* Component:                     io_gpio    */  
 /* Version:                           def    */  
 /* MemMap:                             mb    */  
 /* Base:                           0x0000    */  
 /* Type:                                     */  
 /* Endian:                         Little    */  
 /*********************************************/  
 /* AddressBlock:              mb_microbus    */  
 /* NumBase:                             0    */  
 /* Range:                            0x10    */  
 /* NumRange:                           16    */  
 /* NumAddBits:                          4    */  
 /* Width:                               8    */  
 /* Byte_lanes:                          1    */  
 /* Byte_size:                           8    */  
 /*********************************************/  
 /* Reg Name:                   gpio_0_out    */  
 /* Reg Offset:                        0x2    */  
 /* Reg numOffset:                       2    */  
 /* Reg size:                            8    */  
 /* Reg Dim:                           0x1    */  
 /* Reg numDim:                          1    */  
 /* Reg DimBits:                         0    */  
 /* Reg Create:                          1    */  
 /* Reg access:                 read-write    */  
 /* Reg has_read:                        1    */  
 /* Reg has_write:                       1    */  
 /*********************************************/  
 /* Reg Name:                    gpio_0_oe    */  
 /* Reg Offset:                        0x1    */  
 /* Reg numOffset:                       1    */  
 /* Reg size:                            8    */  
 /* Reg Dim:                           0x1    */  
 /* Reg numDim:                          1    */  
 /* Reg DimBits:                         0    */  
 /* Reg Create:                          1    */  
 /* Reg access:                 read-write    */  
 /* Reg has_read:                        1    */  
 /* Reg has_write:                       1    */  
 /*********************************************/  
 /* Reg Name:                    gpio_0_in    */  
 /* Reg Offset:                        0x0    */  
 /* Reg numOffset:                       0    */  
 /* Reg size:                            8    */  
 /* Reg Dim:                           0x1    */  
 /* Reg numDim:                          1    */  
 /* Reg DimBits:                         0    */  
 /* Reg Create:                          1    */  
 /* Reg access:                  read-only    */  
 /* Reg has_read:                        1    */  
 /* Reg has_write:                       0    */  
 /*********************************************/  
 /* Reg Name:                   gpio_1_out    */  
 /* Reg Offset:                        0x6    */  
 /* Reg numOffset:                       6    */  
 /* Reg size:                            8    */  
 /* Reg Dim:                           0x1    */  
 /* Reg numDim:                          1    */  
 /* Reg DimBits:                         0    */  
 /* Reg Create:                          1    */  
 /* Reg access:                 read-write    */  
 /* Reg has_read:                        1    */  
 /* Reg has_write:                       1    */  
 /*********************************************/  
 /* Reg Name:                    gpio_1_oe    */  
 /* Reg Offset:                        0x5    */  
 /* Reg numOffset:                       5    */  
 /* Reg size:                            8    */  
 /* Reg Dim:                           0x1    */  
 /* Reg numDim:                          1    */  
 /* Reg DimBits:                         0    */  
 /* Reg Create:                          1    */  
 /* Reg access:                 read-write    */  
 /* Reg has_read:                        1    */  
 /* Reg has_write:                       1    */  
 /*********************************************/  
 /* Reg Name:                    gpio_1_in    */  
 /* Reg Offset:                        0x4    */  
 /* Reg numOffset:                       4    */  
 /* Reg size:                            8    */  
 /* Reg Dim:                           0x1    */  
 /* Reg numDim:                          1    */  
 /* Reg DimBits:                         0    */  
 /* Reg Create:                          1    */  
 /* Reg access:                  read-only    */  
 /* Reg has_read:                        1    */  
 /* Reg has_write:                       0    */  
 /*********************************************/  
 /*********************************************/  
 /* Max_dim:                             1    */  
 /* num_add:                             0    */  
 /* mas_has_read:                        1    */  
 /* mas_has_write:                       1    */  
 /* mas_has_create:                      1    */  
 /*********************************************/  
 /*********************************************/  
module io_gpio_def_mb
#(  parameter UNSELECTED = {8{1'b1}},
    parameter UNMAPPED   = {8{1'b0}},
    parameter GPIO_0_OUT_RST = 8'b0,
    parameter GPIO_0_OE_RST = 8'b0,
    parameter GPIO_1_OUT_RST = 8'b0,
    parameter GPIO_1_OE_RST = 8'b0)
 (
 input  wire             clk,
 input  wire             reset,
 input  wire             enable,
 input  wire             cs,
 input  wire             wr,
 input  wire             rd,
 input  wire  [8-1:0]    wdata,
 output  reg  [8-1:0]    rdata,
 input  wire  [1-1:0]    byte_lanes,
 input  wire  [4-1:0]    addr,
 output  wire  gpio_0_out_cs  ,
 output   reg  gpio_0_out_dec  ,
 input  wire  [8-1:0]    gpio_0_out_rdata  ,
 output   reg  gpio_0_out_wr_0  ,
 output  reg  [8-1:0]    gpio_0_out  ,
 input  wire  [8-1:0]    next_gpio_0_out  ,
 output  wire  gpio_0_oe_cs  ,
 output   reg  gpio_0_oe_dec  ,
 input  wire  [8-1:0]    gpio_0_oe_rdata  ,
 output   reg  gpio_0_oe_wr_0  ,
 output  reg  [8-1:0]    gpio_0_oe  ,
 input  wire  [8-1:0]    next_gpio_0_oe  ,
 output  wire  gpio_0_in_cs  ,
 output   reg  gpio_0_in_dec  ,
 input  wire  [8-1:0]    gpio_0_in_rdata  ,
 output  wire  gpio_1_out_cs  ,
 output   reg  gpio_1_out_dec  ,
 input  wire  [8-1:0]    gpio_1_out_rdata  ,
 output   reg  gpio_1_out_wr_0  ,
 output  reg  [8-1:0]    gpio_1_out  ,
 input  wire  [8-1:0]    next_gpio_1_out  ,
 output  wire  gpio_1_oe_cs  ,
 output   reg  gpio_1_oe_dec  ,
 input  wire  [8-1:0]    gpio_1_oe_rdata  ,
 output   reg  gpio_1_oe_wr_0  ,
 output  reg  [8-1:0]    gpio_1_oe  ,
 input  wire  [8-1:0]    next_gpio_1_oe  ,
 output  wire  gpio_1_in_cs  ,
 output   reg  gpio_1_in_dec  ,
 input  wire  [8-1:0]    gpio_1_in_rdata  
);
parameter GPIO_0_OUT = 4'd2;
parameter GPIO_0_OUT_END = 4'd3;
parameter GPIO_0_OE = 4'd1;
parameter GPIO_0_OE_END = 4'd2;
parameter GPIO_0_IN = 4'd0;
parameter GPIO_0_IN_END = 4'd1;
parameter GPIO_1_OUT = 4'd6;
parameter GPIO_1_OUT_END = 4'd7;
parameter GPIO_1_OE = 4'd5;
parameter GPIO_1_OE_END = 4'd6;
parameter GPIO_1_IN = 4'd4;
parameter GPIO_1_IN_END = 4'd5;
 reg  [8-1:0]    rdata_i;
reg  [8-1:0]    gpio_0_out_wdata;
reg  [8-1:0]    gpio_0_oe_wdata;
reg  [8-1:0]    gpio_1_out_wdata;
reg  [8-1:0]    gpio_1_oe_wdata;
/*QQQ        Reg_Name     Reg_Access sys_byte_lanes  reg_byte_lanes reg_size  reg_add   ar_base log_byte_lane phy_byte_lane  reg_lane   pad_size        padding     bigend    */  
/*QQQ       gpio_0_out    read-write           1       1               8        2        0        0                 0           0           8            0          0       */  
/*QQQ        gpio_0_oe    read-write           1       1               8        1        0        0                 0           0           8            0          0       */  
/*QQQ        gpio_0_in     read-only           1       1               8        0        0        0                 0           0           8            0          0       */  
/*QQQ       gpio_1_out    read-write           1       1               8        6        0        0                 0           0           8            0          0       */  
/*QQQ        gpio_1_oe    read-write           1       1               8        5        0        0                 0           0           8            0          0       */  
/*QQQ        gpio_1_in     read-only           1       1               8        4        0        0                 0           0           8            0          0       */  
always@(*)
  if(rd && cs)
    begin
  if(byte_lanes[ 0 ])
   rdata[0*8+8-1:0*8] =  rdata_i[0*8+8-1:0*8];         
  else
                rdata[0*8+8-1:0*8] = UNMAPPED;
    end
  else          rdata[0*8+8-1:0*8] = UNSELECTED;
always@(*)
    case(addr[4-1:0])
GPIO_0_OUT[4-1:0]:      rdata_i[0*8+8-1:0*8] =  gpio_0_out_rdata[0*8+8-1:0*8] ;//QQQQ
GPIO_0_OE[4-1:0]:      rdata_i[0*8+8-1:0*8] =  gpio_0_oe_rdata[0*8+8-1:0*8] ;//QQQQ
GPIO_0_IN[4-1:0]:      rdata_i[0*8+8-1:0*8] =  gpio_0_in_rdata[0*8+8-1:0*8] ;//QQQQ
GPIO_1_OUT[4-1:0]:      rdata_i[0*8+8-1:0*8] =  gpio_1_out_rdata[0*8+8-1:0*8] ;//QQQQ
GPIO_1_OE[4-1:0]:      rdata_i[0*8+8-1:0*8] =  gpio_1_oe_rdata[0*8+8-1:0*8] ;//QQQQ
GPIO_1_IN[4-1:0]:      rdata_i[0*8+8-1:0*8] =  gpio_1_in_rdata[0*8+8-1:0*8] ;//QQQQ
    default:    rdata_i[0*8+8-1:0*8] = UNMAPPED;
    endcase
always@(*)
    begin
gpio_0_out_wdata      =  wdata[0*8+8-1:0];//    1
gpio_0_oe_wdata      =  wdata[0*8+8-1:0];//    1
gpio_1_out_wdata      =  wdata[0*8+8-1:0];//    1
gpio_1_oe_wdata      =  wdata[0*8+8-1:0];//    1
    end
always@(*)
    begin
gpio_0_out_wr_0 = cs && wr && enable && byte_lanes[ 0 ] && ( addr[4-1:0]== GPIO_0_OUT[4-1:0] ); //     
gpio_0_oe_wr_0 = cs && wr && enable && byte_lanes[ 0 ] && ( addr[4-1:0]== GPIO_0_OE[4-1:0] ); //     
gpio_1_out_wr_0 = cs && wr && enable && byte_lanes[ 0 ] && ( addr[4-1:0]== GPIO_1_OUT[4-1:0] ); //     
gpio_1_oe_wr_0 = cs && wr && enable && byte_lanes[ 0 ] && ( addr[4-1:0]== GPIO_1_OE[4-1:0] ); //     
    end
 always@(*)
     begin
        gpio_0_out_dec = cs && ( addr[4-1:0]== GPIO_0_OUT[4-1:0] );//  1
        gpio_0_oe_dec = cs && ( addr[4-1:0]== GPIO_0_OE[4-1:0] );//  1
        gpio_0_in_dec = cs && ( addr[4-1:0]== GPIO_0_IN[4-1:0] );//  1
        gpio_1_out_dec = cs && ( addr[4-1:0]== GPIO_1_OUT[4-1:0] );//  1
        gpio_1_oe_dec = cs && ( addr[4-1:0]== GPIO_1_OE[4-1:0] );//  1
        gpio_1_in_dec = cs && ( addr[4-1:0]== GPIO_1_IN[4-1:0] );//  1
     end
  /* verilator lint_off UNSIGNED */           
assign   gpio_0_out_cs = cs && ( addr >= GPIO_0_OUT ) && ( addr < GPIO_0_OUT_END );
assign   gpio_0_oe_cs = cs && ( addr >= GPIO_0_OE ) && ( addr < GPIO_0_OE_END );
assign   gpio_0_in_cs = cs && ( addr >= GPIO_0_IN ) && ( addr < GPIO_0_IN_END );
assign   gpio_1_out_cs = cs && ( addr >= GPIO_1_OUT ) && ( addr < GPIO_1_OUT_END );
assign   gpio_1_oe_cs = cs && ( addr >= GPIO_1_OE ) && ( addr < GPIO_1_OE_END );
assign   gpio_1_in_cs = cs && ( addr >= GPIO_1_IN ) && ( addr < GPIO_1_IN_END );
  /* verilator lint_on UNSIGNED */           
   always@(posedge clk)
     if(reset)  gpio_0_out <=  GPIO_0_OUT_RST;
        else
       begin
    if(gpio_0_out_wr_0)    gpio_0_out[8-1:0]  <=  gpio_0_out_wdata[8-1:0]  ;
    else    gpio_0_out[8-1:0]   <=    next_gpio_0_out[8-1:0];
     end
   always@(posedge clk)
     if(reset)  gpio_0_oe <=  GPIO_0_OE_RST;
        else
       begin
    if(gpio_0_oe_wr_0)    gpio_0_oe[8-1:0]  <=  gpio_0_oe_wdata[8-1:0]  ;
    else    gpio_0_oe[8-1:0]   <=    next_gpio_0_oe[8-1:0];
     end
   always@(posedge clk)
     if(reset)  gpio_1_out <=  GPIO_1_OUT_RST;
        else
       begin
    if(gpio_1_out_wr_0)    gpio_1_out[8-1:0]  <=  gpio_1_out_wdata[8-1:0]  ;
    else    gpio_1_out[8-1:0]   <=    next_gpio_1_out[8-1:0];
     end
   always@(posedge clk)
     if(reset)  gpio_1_oe <=  GPIO_1_OE_RST;
        else
       begin
    if(gpio_1_oe_wr_0)    gpio_1_oe[8-1:0]  <=  gpio_1_oe_wdata[8-1:0]  ;
    else    gpio_1_oe[8-1:0]   <=    next_gpio_1_oe[8-1:0];
     end
endmodule 
