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
  io_pic_def 
    #( parameter 
      IRQ_MODE=8'h00,
      NMI_MODE=8'h00)
     (
 input   wire                 clk,
 input   wire                 cs,
 input   wire                 enable,
 input   wire                 rd,
 input   wire                 reset,
 input   wire                 wr,
 input   wire    [ 3 :  0]        addr,
 input   wire    [ 7 :  0]        int_in,
 input   wire    [ 7 :  0]        wdata,
 output   reg                 irq_out,
 output   reg                 nmi_out,
 output   wire    [ 7 :  0]        rdata);
reg [7:0]                irq_act;
reg [7:0]                nmi_act;
wire [7:0]               irq_enable;
wire [7:0]               nmi_enable;
parameter INT_IN         = 4'h0;
parameter IRQ_ENABLE     = 4'h2;
parameter NMI_ENABLE     = 4'h4;
parameter IRQ_ACT        = 4'h6;
parameter NMI_ACT        = 4'h8;
always@(posedge clk)
if (reset) 
   begin
   irq_act     <= 8'h00;
   nmi_act     <= 8'h00;
   irq_out     <= 1'b0;
   nmi_out     <= 1'b0;
   end
else 
   begin
   irq_act     <=  irq_enable & int_in;
   nmi_act     <=  nmi_enable & int_in;
   irq_out     <=  | irq_act;
   nmi_out     <=  | nmi_act;
   end
io_pic_def_mb
#(
  .IRQ_ENABLE_RST     (IRQ_MODE),
  .NMI_ENABLE_RST     (NMI_MODE)
)
pic_micro_reg
( 
   .clk               ( clk    ),
   .reset             ( reset  ),
   .enable            ( enable ),
   .cs                ( cs     ),		      
   .wr                ( wr     ),
   .rd                ( rd     ),
   .byte_lanes        ( 1'b1   ),
   .addr              ( addr   ),
   .wdata             ( wdata  ),
   .rdata             ( rdata  ),
   .int_in_cs         (   ),
   .int_in_dec       (   ),
   .irq_enable_cs       (   ),
   .irq_enable_dec       (   ),
   .irq_enable_wr_0       (   ),
   .nmi_enable_cs       (   ), 
   .nmi_enable_dec       (   ),
   .nmi_enable_wr_0       (   ),
   .irq_act_cs       (   ), 
   .irq_act_dec       (   ),
   .nmi_act_cs       (   ), 
   .nmi_act_dec       (   ),
   .irq_enable        ( irq_enable ),
   .nmi_enable        ( nmi_enable ),
   .irq_enable_rdata        ( irq_enable ),
   .nmi_enable_rdata        ( nmi_enable ),
   .int_in_rdata      ( int_in     ),
   .next_irq_enable   ( irq_enable ),  
   .next_nmi_enable   ( nmi_enable ),
   .irq_act_rdata      ( irq_act    ),
   .nmi_act_rdata      ( nmi_act    )		      
);
  endmodule
 /*********************************************/  
 /* Vendor:                  opencores.org    */  
 /* Library:                            io    */  
 /* Component:                      io_pic    */  
 /* Version:                           def    */  
 /* MemMap:                             mb    */  
 /* Base:                             0x00    */  
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
 /* Reg Name:                       int_in    */  
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
 /* Reg Name:                   irq_enable    */  
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
 /* Reg Name:                   nmi_enable    */  
 /* Reg Offset:                        0x4    */  
 /* Reg numOffset:                       4    */  
 /* Reg size:                            8    */  
 /* Reg Dim:                           0x1    */  
 /* Reg numDim:                          1    */  
 /* Reg DimBits:                         0    */  
 /* Reg Create:                          1    */  
 /* Reg access:                 read-write    */  
 /* Reg has_read:                        1    */  
 /* Reg has_write:                       1    */  
 /*********************************************/  
 /* Reg Name:                      irq_act    */  
 /* Reg Offset:                        0x6    */  
 /* Reg numOffset:                       6    */  
 /* Reg size:                            8    */  
 /* Reg Dim:                           0x1    */  
 /* Reg numDim:                          1    */  
 /* Reg DimBits:                         0    */  
 /* Reg Create:                          1    */  
 /* Reg access:                  read-only    */  
 /* Reg has_read:                        1    */  
 /* Reg has_write:                       0    */  
 /*********************************************/  
 /* Reg Name:                      nmi_act    */  
 /* Reg Offset:                        0x8    */  
 /* Reg numOffset:                       8    */  
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
module io_pic_def_mb
#(  parameter UNSELECTED = {8{1'b1}},
    parameter UNMAPPED   = {8{1'b0}},
    parameter IRQ_ENABLE_RST = 8'b0,
    parameter NMI_ENABLE_RST = 8'b0)
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
 output  wire  int_in_cs  ,
 output   reg  int_in_dec  ,
 input  wire  [8-1:0]    int_in_rdata  ,
 output  wire  irq_enable_cs  ,
 output   reg  irq_enable_dec  ,
 input  wire  [8-1:0]    irq_enable_rdata  ,
 output   reg  irq_enable_wr_0  ,
 output  reg  [8-1:0]    irq_enable  ,
 input  wire  [8-1:0]    next_irq_enable  ,
 output  wire  nmi_enable_cs  ,
 output   reg  nmi_enable_dec  ,
 input  wire  [8-1:0]    nmi_enable_rdata  ,
 output   reg  nmi_enable_wr_0  ,
 output  reg  [8-1:0]    nmi_enable  ,
 input  wire  [8-1:0]    next_nmi_enable  ,
 output  wire  irq_act_cs  ,
 output   reg  irq_act_dec  ,
 input  wire  [8-1:0]    irq_act_rdata  ,
 output  wire  nmi_act_cs  ,
 output   reg  nmi_act_dec  ,
 input  wire  [8-1:0]    nmi_act_rdata  
);
parameter INT_IN = 4'd0;
parameter INT_IN_END = 4'd1;
parameter IRQ_ENABLE = 4'd2;
parameter IRQ_ENABLE_END = 4'd3;
parameter NMI_ENABLE = 4'd4;
parameter NMI_ENABLE_END = 4'd5;
parameter IRQ_ACT = 4'd6;
parameter IRQ_ACT_END = 4'd7;
parameter NMI_ACT = 4'd8;
parameter NMI_ACT_END = 4'd9;
 reg  [8-1:0]    rdata_i;
reg  [8-1:0]    irq_enable_wdata;
reg  [8-1:0]    nmi_enable_wdata;
/*QQQ        Reg_Name     Reg_Access sys_byte_lanes  reg_byte_lanes reg_size  reg_add   ar_base log_byte_lane phy_byte_lane  reg_lane   pad_size        padding     bigend    */  
/*QQQ           int_in     read-only           1       1               8        0        0        0                 0           0           8            0          0       */  
/*QQQ       irq_enable    read-write           1       1               8        2        0        0                 0           0           8            0          0       */  
/*QQQ       nmi_enable    read-write           1       1               8        4        0        0                 0           0           8            0          0       */  
/*QQQ          irq_act     read-only           1       1               8        6        0        0                 0           0           8            0          0       */  
/*QQQ          nmi_act     read-only           1       1               8        8        0        0                 0           0           8            0          0       */  
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
INT_IN[4-1:0]:      rdata_i[0*8+8-1:0*8] =  int_in_rdata[0*8+8-1:0*8] ;//QQQQ
IRQ_ENABLE[4-1:0]:      rdata_i[0*8+8-1:0*8] =  irq_enable_rdata[0*8+8-1:0*8] ;//QQQQ
NMI_ENABLE[4-1:0]:      rdata_i[0*8+8-1:0*8] =  nmi_enable_rdata[0*8+8-1:0*8] ;//QQQQ
IRQ_ACT[4-1:0]:      rdata_i[0*8+8-1:0*8] =  irq_act_rdata[0*8+8-1:0*8] ;//QQQQ
NMI_ACT[4-1:0]:      rdata_i[0*8+8-1:0*8] =  nmi_act_rdata[0*8+8-1:0*8] ;//QQQQ
    default:    rdata_i[0*8+8-1:0*8] = UNMAPPED;
    endcase
always@(*)
    begin
irq_enable_wdata      =  wdata[0*8+8-1:0];//    1
nmi_enable_wdata      =  wdata[0*8+8-1:0];//    1
    end
always@(*)
    begin
irq_enable_wr_0 = cs && wr && enable && byte_lanes[ 0 ] && ( addr[4-1:0]== IRQ_ENABLE[4-1:0] ); //     
nmi_enable_wr_0 = cs && wr && enable && byte_lanes[ 0 ] && ( addr[4-1:0]== NMI_ENABLE[4-1:0] ); //     
    end
 always@(*)
     begin
        int_in_dec = cs && ( addr[4-1:0]== INT_IN[4-1:0] );//  1
        irq_enable_dec = cs && ( addr[4-1:0]== IRQ_ENABLE[4-1:0] );//  1
        nmi_enable_dec = cs && ( addr[4-1:0]== NMI_ENABLE[4-1:0] );//  1
        irq_act_dec = cs && ( addr[4-1:0]== IRQ_ACT[4-1:0] );//  1
        nmi_act_dec = cs && ( addr[4-1:0]== NMI_ACT[4-1:0] );//  1
     end
  /* verilator lint_off UNSIGNED */           
assign   int_in_cs = cs && ( addr >= INT_IN ) && ( addr < INT_IN_END );
assign   irq_enable_cs = cs && ( addr >= IRQ_ENABLE ) && ( addr < IRQ_ENABLE_END );
assign   nmi_enable_cs = cs && ( addr >= NMI_ENABLE ) && ( addr < NMI_ENABLE_END );
assign   irq_act_cs = cs && ( addr >= IRQ_ACT ) && ( addr < IRQ_ACT_END );
assign   nmi_act_cs = cs && ( addr >= NMI_ACT ) && ( addr < NMI_ACT_END );
  /* verilator lint_on UNSIGNED */           
   always@(posedge clk)
     if(reset)  irq_enable <=  IRQ_ENABLE_RST;
        else
       begin
    if(irq_enable_wr_0)    irq_enable[8-1:0]  <=  irq_enable_wdata[8-1:0]  ;
    else    irq_enable[8-1:0]   <=    next_irq_enable[8-1:0];
     end
   always@(posedge clk)
     if(reset)  nmi_enable <=  NMI_ENABLE_RST;
        else
       begin
    if(nmi_enable_wr_0)    nmi_enable[8-1:0]  <=  nmi_enable_wdata[8-1:0]  ;
    else    nmi_enable[8-1:0]   <=    next_nmi_enable[8-1:0];
     end
endmodule 
