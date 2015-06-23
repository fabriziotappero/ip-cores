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
  io_timer_def 
    #( parameter 
      TIMERS=2)
     (
 input   wire                 clk,
 input   wire                 cs,
 input   wire                 enable,
 input   wire                 rd,
 input   wire                 reset,
 input   wire                 wr,
 input   wire    [ 3 :  0]        addr,
 input   wire    [ 7 :  0]        wdata,
 output   reg    [ TIMERS-1 :  0]        irq,
 output   wire    [ 7 :  0]        rdata);
parameter TIMER_0_START  = 4'h0;
parameter TIMER_0_COUNT  = 4'h2;
parameter TIMER_0_END    = 4'h4;
parameter TIMER_1_START  = 4'h8;
parameter TIMER_1_COUNT  = 4'hA;
parameter TIMER_1_END    = 4'hC;
parameter IDLE         = 3'b001;
parameter RUNNING      = 3'b010;
parameter TRIGGERED    = 3'b100;
reg [7:0] count_0;
reg [2:0] state_0;
reg [7:0] count_1;
reg [2:0] state_1;   
wire [7:0] timer_0;   
wire [7:0] timer_1;   
io_timer_def_mb
io_module_timer_micro_reg
(
  .clk             ( clk           ),
  .reset           ( reset         ),
  .cs              ( cs            ),
  .enable          ( enable        ),       
  .wr              ( wr            ),       
  .rd              ( rd            ),
  .byte_lanes      ( 1'b1          ),
  .addr            ( addr          ),
  .wdata           ( wdata         ),
  .rdata           ( rdata         ),
  .timer_0_end       ( timer_0       ),
  .next_timer_0_end  ( timer_0       ),
  .timer_0_start_cs  (               ),
  .timer_0_start_dec (               ),
  .timer_0_count_cs  (               ),
  .timer_0_count_dec (               ),
  .timer_0_end_cs    (               ),
  .timer_0_end_dec   (               ),
  .timer_0_end_wr_0  (               ),
  .timer_0_start_rdata   ({4'h0,irq[0],state_0[2:0]} ),
  .timer_0_count_rdata   ( count_0                   ),
  .timer_1_end       ( timer_1       ),
  .next_timer_1_end  ( timer_1       ),
  .timer_1_start_cs  (               ),
  .timer_1_start_dec (               ),
  .timer_1_count_cs  (               ),
  .timer_1_count_dec (               ),
  .timer_1_end_cs    (               ),
  .timer_1_end_dec   (               ),
  .timer_1_end_wr_0  (               ),
  .timer_1_start_rdata   ({4'h0,irq[1],state_1[2:0]} ),
  .timer_1_count_rdata   ( count_1                   )   
);
always@(posedge clk)
if(reset)
  begin
  irq <= 2'b00; 
  end
else
  begin
  irq <= {state_1[2],state_0[2]}; 
  end
always@(posedge clk)
if (reset) 
  begin
  state_0 <= IDLE;
  count_0 <= 8'h00;
  end
else 
case (state_0)  
     (IDLE):        
     if(wr && enable  && cs && addr[3:0] == TIMER_0_START) 
         begin
         state_0 <= RUNNING;
         count_0 <= wdata;    
 end
     else 
         begin
         state_0 <= IDLE;
         count_0 <= 8'h00;
 end
     (RUNNING):     
      if( count_0 == 8'h00)      
         begin
         state_0 <= TRIGGERED;
         count_0 <= 8'h00;   
         end
      else     
         begin
         state_0 <= RUNNING;
         count_0 <=  count_0 -8'h01;    
 end
     (TRIGGERED):   
     if(wr && enable && cs && addr[3:0] == TIMER_0_END) 
         begin
         state_0 <= IDLE;
         count_0 <= 8'h00;    
 end
     else   
         begin
         state_0 <= TRIGGERED;
         count_0 <= 8'h00;    
 end
     default: 
          begin
          state_0 <= IDLE;
          count_0 <= 8'h00;     
          end
endcase // case (state_0)
always@(posedge clk)
if (reset) 
  begin
  state_1 <= IDLE;
  count_1 <= 8'h00;
  end
else 
case (state_1)  
     (IDLE):        
     if(wr && enable && cs && addr[3:0] == TIMER_1_START) 
         begin
         state_1 <= RUNNING;
         count_1 <= wdata;    
 end
     else 
         begin
         state_1 <= IDLE;
         count_1 <= 8'h00;
 end
     (RUNNING):     
      if( count_1 == 8'h00)      
         begin
         state_1 <= TRIGGERED;
         count_1 <= 8'h00;   
         end
      else     
         begin
         state_1 <= RUNNING;
         count_1 <=  count_1 -8'h01;    
 end
     (TRIGGERED):   
     if(wr && enable && cs && addr[3:0] == TIMER_1_END) 
         begin
         state_1 <= IDLE;
         count_1 <= 8'h00;    
 end
     else   
         begin
         state_1 <= TRIGGERED;
         count_1 <= 8'h00;    
 end
     default: 
          begin
          state_1 <= IDLE;
          count_1 <= 8'h00;     
          end
endcase
  endmodule
 /*********************************************/  
 /* Vendor:                  opencores.org    */  
 /* Library:                            io    */  
 /* Component:                    io_timer    */  
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
 /* Reg Name:                timer_0_start    */  
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
 /* Reg Name:                timer_0_count    */  
 /* Reg Offset:                        0x2    */  
 /* Reg numOffset:                       2    */  
 /* Reg size:                            8    */  
 /* Reg Dim:                           0x1    */  
 /* Reg numDim:                          1    */  
 /* Reg DimBits:                         0    */  
 /* Reg Create:                          1    */  
 /* Reg access:                  read-only    */  
 /* Reg has_read:                        1    */  
 /* Reg has_write:                       0    */  
 /*********************************************/  
 /* Reg Name:                  timer_0_end    */  
 /* Reg Offset:                        0x4    */  
 /* Reg numOffset:                       4    */  
 /* Reg size:                            8    */  
 /* Reg Dim:                           0x1    */  
 /* Reg numDim:                          1    */  
 /* Reg DimBits:                         0    */  
 /* Reg Create:                          1    */  
 /* Reg access:                 write-only    */  
 /* Reg has_read:                        0    */  
 /* Reg has_write:                       1    */  
 /*********************************************/  
 /* Reg Name:                timer_1_start    */  
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
 /* Reg Name:                timer_1_count    */  
 /* Reg Offset:                        0xa    */  
 /* Reg numOffset:                      10    */  
 /* Reg size:                            8    */  
 /* Reg Dim:                           0x1    */  
 /* Reg numDim:                          1    */  
 /* Reg DimBits:                         0    */  
 /* Reg Create:                          1    */  
 /* Reg access:                  read-only    */  
 /* Reg has_read:                        1    */  
 /* Reg has_write:                       0    */  
 /*********************************************/  
 /* Reg Name:                  timer_1_end    */  
 /* Reg Offset:                        0xc    */  
 /* Reg numOffset:                      12    */  
 /* Reg size:                            8    */  
 /* Reg Dim:                           0x1    */  
 /* Reg numDim:                          1    */  
 /* Reg DimBits:                         0    */  
 /* Reg Create:                          1    */  
 /* Reg access:                 write-only    */  
 /* Reg has_read:                        0    */  
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
module io_timer_def_mb
#(  parameter UNSELECTED = {8{1'b1}},
    parameter UNMAPPED   = {8{1'b0}},
    parameter TIMER_0_END_RST = 8'b0,
    parameter TIMER_1_END_RST = 8'b0)
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
 output  wire  timer_0_start_cs  ,
 output   reg  timer_0_start_dec  ,
 input  wire  [8-1:0]    timer_0_start_rdata  ,
 output  wire  timer_0_count_cs  ,
 output   reg  timer_0_count_dec  ,
 input  wire  [8-1:0]    timer_0_count_rdata  ,
 output  wire  timer_0_end_cs  ,
 output   reg  timer_0_end_dec  ,
 output   reg  timer_0_end_wr_0  ,
 output  reg  [8-1:0]    timer_0_end  ,
 input  wire  [8-1:0]    next_timer_0_end  ,
 output  wire  timer_1_start_cs  ,
 output   reg  timer_1_start_dec  ,
 input  wire  [8-1:0]    timer_1_start_rdata  ,
 output  wire  timer_1_count_cs  ,
 output   reg  timer_1_count_dec  ,
 input  wire  [8-1:0]    timer_1_count_rdata  ,
 output  wire  timer_1_end_cs  ,
 output   reg  timer_1_end_dec  ,
 output   reg  timer_1_end_wr_0  ,
 output  reg  [8-1:0]    timer_1_end  ,
 input  wire  [8-1:0]    next_timer_1_end  
);
parameter TIMER_0_START = 4'd0;
parameter TIMER_0_START_END = 4'd1;
parameter TIMER_0_COUNT = 4'd2;
parameter TIMER_0_COUNT_END = 4'd3;
parameter TIMER_0_END = 4'd4;
parameter TIMER_0_END_END = 4'd5;
parameter TIMER_1_START = 4'd8;
parameter TIMER_1_START_END = 4'd9;
parameter TIMER_1_COUNT = 4'd10;
parameter TIMER_1_COUNT_END = 4'd11;
parameter TIMER_1_END = 4'd12;
parameter TIMER_1_END_END = 4'd13;
 reg  [8-1:0]    rdata_i;
reg  [8-1:0]    timer_0_end_wdata;
reg  [8-1:0]    timer_1_end_wdata;
/*QQQ        Reg_Name     Reg_Access sys_byte_lanes  reg_byte_lanes reg_size  reg_add   ar_base log_byte_lane phy_byte_lane  reg_lane   pad_size        padding     bigend    */  
/*QQQ    timer_0_start     read-only           1       1               8        0        0        0                 0           0           8            0          0       */  
/*QQQ    timer_0_count     read-only           1       1               8        2        0        0                 0           0           8            0          0       */  
/*QQQ      timer_0_end    write-only           1       1               8        4        0        0                 0           0           8            0          0       */  
/*QQQ    timer_1_start     read-only           1       1               8        8        0        0                 0           0           8            0          0       */  
/*QQQ    timer_1_count     read-only           1       1               8       10        0        0                 0           0           8            0          0       */  
/*QQQ      timer_1_end    write-only           1       1               8       12        0        0                 0           0           8            0          0       */  
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
TIMER_0_START[4-1:0]:      rdata_i[0*8+8-1:0*8] =  timer_0_start_rdata[0*8+8-1:0*8] ;//QQQQ
TIMER_0_COUNT[4-1:0]:      rdata_i[0*8+8-1:0*8] =  timer_0_count_rdata[0*8+8-1:0*8] ;//QQQQ
TIMER_1_START[4-1:0]:      rdata_i[0*8+8-1:0*8] =  timer_1_start_rdata[0*8+8-1:0*8] ;//QQQQ
TIMER_1_COUNT[4-1:0]:      rdata_i[0*8+8-1:0*8] =  timer_1_count_rdata[0*8+8-1:0*8] ;//QQQQ
    default:    rdata_i[0*8+8-1:0*8] = UNMAPPED;
    endcase
always@(*)
    begin
timer_0_end_wdata      =  wdata[0*8+8-1:0];//    1
timer_1_end_wdata      =  wdata[0*8+8-1:0];//    1
    end
always@(*)
    begin
timer_0_end_wr_0 = cs && wr && enable && byte_lanes[ 0 ] && ( addr[4-1:0]== TIMER_0_END[4-1:0] ); //     
timer_1_end_wr_0 = cs && wr && enable && byte_lanes[ 0 ] && ( addr[4-1:0]== TIMER_1_END[4-1:0] ); //     
    end
 always@(*)
     begin
        timer_0_start_dec = cs && ( addr[4-1:0]== TIMER_0_START[4-1:0] );//  1
        timer_0_count_dec = cs && ( addr[4-1:0]== TIMER_0_COUNT[4-1:0] );//  1
        timer_0_end_dec = cs && ( addr[4-1:0]== TIMER_0_END[4-1:0] );//  1
        timer_1_start_dec = cs && ( addr[4-1:0]== TIMER_1_START[4-1:0] );//  1
        timer_1_count_dec = cs && ( addr[4-1:0]== TIMER_1_COUNT[4-1:0] );//  1
        timer_1_end_dec = cs && ( addr[4-1:0]== TIMER_1_END[4-1:0] );//  1
     end
  /* verilator lint_off UNSIGNED */           
assign   timer_0_start_cs = cs && ( addr >= TIMER_0_START ) && ( addr < TIMER_0_START_END );
assign   timer_0_count_cs = cs && ( addr >= TIMER_0_COUNT ) && ( addr < TIMER_0_COUNT_END );
assign   timer_0_end_cs = cs && ( addr >= TIMER_0_END ) && ( addr < TIMER_0_END_END );
assign   timer_1_start_cs = cs && ( addr >= TIMER_1_START ) && ( addr < TIMER_1_START_END );
assign   timer_1_count_cs = cs && ( addr >= TIMER_1_COUNT ) && ( addr < TIMER_1_COUNT_END );
assign   timer_1_end_cs = cs && ( addr >= TIMER_1_END ) && ( addr < TIMER_1_END_END );
  /* verilator lint_on UNSIGNED */           
   always@(posedge clk)
     if(reset)  timer_0_end <=  TIMER_0_END_RST;
        else
       begin
    if(timer_0_end_wr_0)    timer_0_end[8-1:0]  <=  timer_0_end_wdata[8-1:0]  ;
    else    timer_0_end[8-1:0]   <=    next_timer_0_end[8-1:0];
     end
   always@(posedge clk)
     if(reset)  timer_1_end <=  TIMER_1_END_RST;
        else
       begin
    if(timer_1_end_wr_0)    timer_1_end[8-1:0]  <=  timer_1_end_wdata[8-1:0]  ;
    else    timer_1_end[8-1:0]   <=    next_timer_1_end[8-1:0];
     end
endmodule 
