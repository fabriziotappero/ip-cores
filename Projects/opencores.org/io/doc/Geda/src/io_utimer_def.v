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
  io_utimer_def 
    #( parameter 
      FREQ=25)
     (
 input   wire                 clk,
 input   wire                 cs,
 input   wire                 enable,
 input   wire                 rd,
 input   wire                 reset,
 input   wire                 wr,
 input   wire    [ 3 :  0]        addr,
 input   wire    [ 7 :  0]        wdata,
 output   wire    [ 7 :  0]        rdata);
parameter TIMER_LATCH  = 4'h0;
parameter TIMER_COUNT  = 4'h2;
wire [7:0]              count;
reg  [7:0]              next_count;
wire [7:0]              latch;
reg [5:0]              u_sec;
always@( posedge clk)
if(reset)                                                                     u_sec <= FREQ-1;
else
if((u_sec == 0) ||   (wr && enable  && cs && addr[3:0] == TIMER_COUNT) )      u_sec <= FREQ-1;
else                                                                          u_sec <= u_sec-1;
always@(*)
if(u_sec == 0)
  begin
  if(count == 8'h00)                                  next_count  = 8'h00;
  else
  if(count == 8'h01)                                  next_count  = latch;
  else                                                next_count  = count-1;
  end
else                                                  next_count  = count;
io_utimer_def_mb
utimer_micro_reg
(
      .clk             ( clk        ),
      .reset           ( reset      ),
      .enable          ( enable     ),
      .cs              ( cs         ),
      .wr              ( wr         ),		       
      .rd              ( rd         ),
      .addr            ( addr       ),
      .byte_lanes      ( 1'b1       ),   
      .wdata           ( wdata      ),
      .rdata           ( rdata      ),
      .latch_cs        (            ),
      .latch_dec       (            ),
      .latch_wr_0      (            ),
      .count_cs        (            ),  
      .count_dec       (            ),
      .count_wr_0      (            ),
      .count           ( count      ),
      .latch           ( latch      ),
      .count_rdata     ( count      ),
      .latch_rdata     ( latch      ),
      .next_count      ( next_count ),
      .next_latch      ( latch      )   
);
  endmodule
 /*********************************************/  
 /* Vendor:                  opencores.org    */  
 /* Library:                            io    */  
 /* Component:                   io_utimer    */  
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
 /* Reg Name:                        latch    */  
 /* Reg Offset:                        0x0    */  
 /* Reg numOffset:                       0    */  
 /* Reg size:                            8    */  
 /* Reg Dim:                           0x1    */  
 /* Reg numDim:                          1    */  
 /* Reg DimBits:                         0    */  
 /* Reg Create:                          1    */  
 /* Reg access:                 read-write    */  
 /* Reg has_read:                        1    */  
 /* Reg has_write:                       1    */  
 /*********************************************/  
 /* Reg Name:                        count    */  
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
 /*********************************************/  
 /* Max_dim:                             1    */  
 /* num_add:                             0    */  
 /* mas_has_read:                        1    */  
 /* mas_has_write:                       1    */  
 /* mas_has_create:                      1    */  
 /*********************************************/  
 /*********************************************/  
module io_utimer_def_mb
#(  parameter UNSELECTED = {8{1'b1}},
    parameter UNMAPPED   = {8{1'b0}},
    parameter LATCH_RST = 8'b0,
    parameter COUNT_RST = 8'b0)
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
 output  wire  latch_cs  ,
 output   reg  latch_dec  ,
 input  wire  [8-1:0]    latch_rdata  ,
 output   reg  latch_wr_0  ,
 output  reg  [8-1:0]    latch  ,
 input  wire  [8-1:0]    next_latch  ,
 output  wire  count_cs  ,
 output   reg  count_dec  ,
 input  wire  [8-1:0]    count_rdata  ,
 output   reg  count_wr_0  ,
 output  reg  [8-1:0]    count  ,
 input  wire  [8-1:0]    next_count  
);
parameter LATCH = 4'd0;
parameter LATCH_END = 4'd1;
parameter COUNT = 4'd2;
parameter COUNT_END = 4'd3;
 reg  [8-1:0]    rdata_i;
reg  [8-1:0]    latch_wdata;
reg  [8-1:0]    count_wdata;
/*QQQ        Reg_Name     Reg_Access sys_byte_lanes  reg_byte_lanes reg_size  reg_add   ar_base log_byte_lane phy_byte_lane  reg_lane   pad_size        padding     bigend    */  
/*QQQ            latch    read-write           1       1               8        0        0        0                 0           0           8            0          0       */  
/*QQQ            count    read-write           1       1               8        2        0        0                 0           0           8            0          0       */  
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
LATCH[4-1:0]:      rdata_i[0*8+8-1:0*8] =  latch_rdata[0*8+8-1:0*8] ;//QQQQ
COUNT[4-1:0]:      rdata_i[0*8+8-1:0*8] =  count_rdata[0*8+8-1:0*8] ;//QQQQ
    default:    rdata_i[0*8+8-1:0*8] = UNMAPPED;
    endcase
always@(*)
    begin
latch_wdata      =  wdata[0*8+8-1:0];//    1
count_wdata      =  wdata[0*8+8-1:0];//    1
    end
always@(*)
    begin
latch_wr_0 = cs && wr && enable && byte_lanes[ 0 ] && ( addr[4-1:0]== LATCH[4-1:0] ); //     
count_wr_0 = cs && wr && enable && byte_lanes[ 0 ] && ( addr[4-1:0]== COUNT[4-1:0] ); //     
    end
 always@(*)
     begin
        latch_dec = cs && ( addr[4-1:0]== LATCH[4-1:0] );//  1
        count_dec = cs && ( addr[4-1:0]== COUNT[4-1:0] );//  1
     end
  /* verilator lint_off UNSIGNED */           
assign   latch_cs = cs && ( addr >= LATCH ) && ( addr < LATCH_END );
assign   count_cs = cs && ( addr >= COUNT ) && ( addr < COUNT_END );
  /* verilator lint_on UNSIGNED */           
   always@(posedge clk)
     if(reset)  latch <=  LATCH_RST;
        else
       begin
    if(latch_wr_0)    latch[8-1:0]  <=  latch_wdata[8-1:0]  ;
    else    latch[8-1:0]   <=    next_latch[8-1:0];
     end
   always@(posedge clk)
     if(reset)  count <=  COUNT_RST;
        else
       begin
    if(count_wr_0)    count[8-1:0]  <=  count_wdata[8-1:0]  ;
    else    count[8-1:0]   <=    next_count[8-1:0];
     end
endmodule 
