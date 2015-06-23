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
  io_uart_tx 
    #( parameter 
      DIV=0,
      PRESCALE=5'b01100,
      PRE_SIZE=5,
      TX_FIFO_SIZE=3,
      TX_FIFO_WORDS=8)
     (
 input   wire                 clk,
 input   wire                 cs,
 input   wire                 cts_pad_in,
 input   wire                 enable,
 input   wire                 rd,
 input   wire                 reset,
 input   wire                 uart_rxd_pad_in,
 input   wire                 wr,
 input   wire    [ 3 :  0]        addr,
 input   wire    [ 7 :  0]        wdata,
 output   reg                 rx_irq,
 output   reg                 tx_irq,
 output   wire                 rts_pad_out,
 output   wire                 uart_txd_pad_out,
 output   wire    [ 7 :  0]        rdata);
reg                        rxd_data_avail_stb;
reg                        txd_load;
reg     [ 7 :  0]              lat_wdata;
wire                        rxd_data_avail;
wire     [ 7 :  0]              cntrl;
wire     [ 7 :  0]              rcv_data;
wire     [ 7 :  0]              status;
uart_tx
#( .DIV (DIV),
   .PRESCALE (PRESCALE),
   .PRE_SIZE (PRE_SIZE),
   .TX_FIFO_SIZE (TX_FIFO_SIZE),
   .TX_FIFO_WORDS (TX_FIFO_WORDS))
uart 
   (
   .rxd_pad_in      ( uart_rxd_pad_in  ),
   .txd_pad_out      ( uart_txd_pad_out  ),
    .clk      ( clk  ),
    .cts_out      ( status[4:4] ),
    .cts_pad_in      ( cts_pad_in  ),
    .divider_in      ( 4'b1011  ),
    .parity_enable      ( cntrl[4:4] ),
    .reset      ( reset  ),
    .rts_in      ( cntrl[3:3] ),
    .rts_pad_out      ( rts_pad_out  ),
    .rxd_data_avail      ( rxd_data_avail  ),
    .rxd_data_avail_stb      ( rxd_data_avail_stb  ),
    .rxd_data_out      ( rcv_data[7:0] ),
    .rxd_force_parity      ( cntrl[1:1] ),
    .rxd_parity      ( cntrl[0:0] ),
    .rxd_parity_error      ( status[3:3] ),
    .rxd_stop_error      ( status[1:1] ),
    .txd_break      ( cntrl[2:2] ),
    .txd_buffer_empty      ( status[5:5] ),
    .txd_buffer_empty_NIRQ      (      ),
    .txd_data_in      ( lat_wdata  ),
    .txd_force_parity      ( cntrl[1:1] ),
    .txd_load      ( txd_load  ),
    .txd_parity      ( cntrl[0:0] ));
wire xmit_data_wr;
wire  rcv_data_rd;
 io_uart_tx_mb
  io_uart_micro_reg
( 
   .clk                ( clk                ),
   .reset              ( reset              ),
   .enable             ( enable             ),
   .cs                 ( cs                 ),	      
   .wr                 ( wr                 ),
   .rd                 ( rd                 ),
   .byte_lanes         ( 1'b1               ),
   .addr               ( addr               ),
   .wdata              ( wdata              ),
   .rdata              ( rdata              ),
   .xmit_data_cs       (),
   .xmit_data_dec      (),
   .xmit_data          (),
   .next_xmit_data     (),
   .rcv_data_cs        (),
   .cntrl_cs           (),
   .cntrl_dec          (), 
   .cntrl_wr_0         (),
   .status_cs          (),
   .status_dec         (),
   .rcv_data_rdata     ( rcv_data           ),
   .status_rdata       ( status             ),
   .cntrl              ( cntrl              ),
   .cntrl_rdata        ( cntrl              ),
   .next_cntrl         ( cntrl              ),
   .xmit_data_wr_0     ( xmit_data_wr       ),
   .rcv_data_dec       ( rcv_data_rd        ));
   always@(posedge clk)
   if (reset)               txd_load <= 1'b0;
   else                     txd_load <= xmit_data_wr;
   always@(posedge clk)
   if (reset)               rx_irq <= 1'b0;
   else                     rx_irq <= cntrl[6] && rxd_data_avail;
   always@(posedge clk)
   if (reset)               tx_irq <= 1'b0;
   else                     tx_irq <= cntrl[7] && status[5];
 assign  status[0] = rxd_data_avail;
 assign  status[2] = 1'b0;
 assign  status[6] = 1'b0;
 assign  status[7] = 1'b0;
always@(posedge clk)
if (reset)     lat_wdata  <= 8'h00;   
else           lat_wdata  <= wdata;   
always@(posedge clk)
if (reset)     rxd_data_avail_stb  <= 1'b0;
else           rxd_data_avail_stb  <= (enable && rcv_data_rd  && rd);
  endmodule
 /*********************************************/  
 /* Vendor:                  opencores.org    */  
 /* Library:                            io    */  
 /* Component:                     io_uart    */  
 /* Version:                            tx    */  
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
 /* Reg Name:                    xmit_data    */  
 /* Reg Offset:                        0x0    */  
 /* Reg numOffset:                       0    */  
 /* Reg size:                            8    */  
 /* Reg Dim:                           0x1    */  
 /* Reg numDim:                          1    */  
 /* Reg DimBits:                         0    */  
 /* Reg Create:                          1    */  
 /* Reg access:                 write-only    */  
 /* Reg has_read:                        0    */  
 /* Reg has_write:                       1    */  
 /*********************************************/  
 /* Reg Name:                     rcv_data    */  
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
 /* Reg Name:                        cntrl    */  
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
 /* Reg Name:                       status    */  
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
 /*********************************************/  
 /* Max_dim:                             1    */  
 /* num_add:                             0    */  
 /* mas_has_read:                        1    */  
 /* mas_has_write:                       1    */  
 /* mas_has_create:                      1    */  
 /*********************************************/  
 /*********************************************/  
module io_uart_tx_mb
#(  parameter UNSELECTED = {8{1'b1}},
    parameter UNMAPPED   = {8{1'b0}},
    parameter XMIT_DATA_RST = 8'b0,
    parameter CNTRL_RST = 8'b0)
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
 output  wire  xmit_data_cs  ,
 output   reg  xmit_data_dec  ,
 output   reg  xmit_data_wr_0  ,
 output  reg  [8-1:0]    xmit_data  ,
 input  wire  [8-1:0]    next_xmit_data  ,
 output  wire  rcv_data_cs  ,
 output   reg  rcv_data_dec  ,
 input  wire  [8-1:0]    rcv_data_rdata  ,
 output  wire  cntrl_cs  ,
 output   reg  cntrl_dec  ,
 input  wire  [8-1:0]    cntrl_rdata  ,
 output   reg  cntrl_wr_0  ,
 output  reg  [8-1:0]    cntrl  ,
 input  wire  [8-1:0]    next_cntrl  ,
 output  wire  status_cs  ,
 output   reg  status_dec  ,
 input  wire  [8-1:0]    status_rdata  
);
parameter XMIT_DATA = 4'd0;
parameter XMIT_DATA_END = 4'd1;
parameter RCV_DATA = 4'd2;
parameter RCV_DATA_END = 4'd3;
parameter CNTRL = 4'd4;
parameter CNTRL_END = 4'd5;
parameter STATUS = 4'd6;
parameter STATUS_END = 4'd7;
 reg  [8-1:0]    rdata_i;
reg  [8-1:0]    xmit_data_wdata;
reg  [8-1:0]    cntrl_wdata;
/*QQQ        Reg_Name     Reg_Access sys_byte_lanes  reg_byte_lanes reg_size  reg_add   ar_base log_byte_lane phy_byte_lane  reg_lane   pad_size        padding     bigend    */  
/*QQQ        xmit_data    write-only           1       1               8        0        0        0                 0           0           8            0          0       */  
/*QQQ         rcv_data     read-only           1       1               8        2        0        0                 0           0           8            0          0       */  
/*QQQ            cntrl    read-write           1       1               8        4        0        0                 0           0           8            0          0       */  
/*QQQ           status     read-only           1       1               8        6        0        0                 0           0           8            0          0       */  
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
RCV_DATA[4-1:0]:      rdata_i[0*8+8-1:0*8] =  rcv_data_rdata[0*8+8-1:0*8] ;//QQQQ
CNTRL[4-1:0]:      rdata_i[0*8+8-1:0*8] =  cntrl_rdata[0*8+8-1:0*8] ;//QQQQ
STATUS[4-1:0]:      rdata_i[0*8+8-1:0*8] =  status_rdata[0*8+8-1:0*8] ;//QQQQ
    default:    rdata_i[0*8+8-1:0*8] = UNMAPPED;
    endcase
always@(*)
    begin
xmit_data_wdata      =  wdata[0*8+8-1:0];//    1
cntrl_wdata      =  wdata[0*8+8-1:0];//    1
    end
always@(*)
    begin
xmit_data_wr_0 = cs && wr && enable && byte_lanes[ 0 ] && ( addr[4-1:0]== XMIT_DATA[4-1:0] ); //     
cntrl_wr_0 = cs && wr && enable && byte_lanes[ 0 ] && ( addr[4-1:0]== CNTRL[4-1:0] ); //     
    end
 always@(*)
     begin
        xmit_data_dec = cs && ( addr[4-1:0]== XMIT_DATA[4-1:0] );//  1
        rcv_data_dec = cs && ( addr[4-1:0]== RCV_DATA[4-1:0] );//  1
        cntrl_dec = cs && ( addr[4-1:0]== CNTRL[4-1:0] );//  1
        status_dec = cs && ( addr[4-1:0]== STATUS[4-1:0] );//  1
     end
  /* verilator lint_off UNSIGNED */           
assign   xmit_data_cs = cs && ( addr >= XMIT_DATA ) && ( addr < XMIT_DATA_END );
assign   rcv_data_cs = cs && ( addr >= RCV_DATA ) && ( addr < RCV_DATA_END );
assign   cntrl_cs = cs && ( addr >= CNTRL ) && ( addr < CNTRL_END );
assign   status_cs = cs && ( addr >= STATUS ) && ( addr < STATUS_END );
  /* verilator lint_on UNSIGNED */           
   always@(posedge clk)
     if(reset)  xmit_data <=  XMIT_DATA_RST;
        else
       begin
    if(xmit_data_wr_0)    xmit_data[8-1:0]  <=  xmit_data_wdata[8-1:0]  ;
    else    xmit_data[8-1:0]   <=    next_xmit_data[8-1:0];
     end
   always@(posedge clk)
     if(reset)  cntrl <=  CNTRL_RST;
        else
       begin
    if(cntrl_wr_0)    cntrl[8-1:0]  <=  cntrl_wdata[8-1:0]  ;
    else    cntrl[8-1:0]   <=    next_cntrl[8-1:0];
     end
endmodule 
