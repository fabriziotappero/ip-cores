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
  io_ext_mem_interface_def 
    #( parameter 
      ADDR_WIDTH=8,
      BASE_ADDR=4'h0,
      BASE_WIDTH=4,
      MEM_FRAME=10,
      MEM_WIDTH=23)
     (
 input   wire                 clk,
 input   wire                 cs,
 input   wire                 enable,
 input   wire                 ext_wait,
 input   wire                 mem_cs,
 input   wire                 mem_rd,
 input   wire                 mem_wr,
 input   wire                 rd,
 input   wire                 reset,
 input   wire                 wr,
 input   wire    [ 13 :  0]        mem_addr,
 input   wire    [ 15 :  0]        ext_rdata,
 input   wire    [ 15 :  0]        mem_wdata,
 input   wire    [ 3 :  0]        addr,
 input   wire    [ 7 :  0]        wdata,
 output   reg                 ext_lb,
 output   reg                 ext_rd,
 output   reg                 ext_stb,
 output   reg                 ext_ub,
 output   reg                 ext_wr,
 output   reg    [ 1 :  0]        ext_cs,
 output   reg    [ 15 :  0]        ext_wdata,
 output   reg    [ 23 :  1]        ext_add,
 output   wire                 mem_wait,
 output   wire    [ 15 :  0]        mem_rdata,
 output   wire    [ 7 :  0]        bank,
 output   wire    [ 7 :  0]        rdata,
 output   wire    [ 7 :  0]        wait_st);
reg [3:0]         enableY;   
reg               wait_n;   
assign mem_rdata = ext_rdata;
always@(posedge clk)
  if(reset)
                      begin
                      ext_add   <=  'b0;
                      ext_wdata <= 16'b0000000000000;
                      ext_rd    <= 1'b0;
                      ext_wr    <= 1'b0;
                      ext_cs    <= 2'b00;
                      ext_stb   <= 1'b0;
                      ext_ub    <= 1'b0;
                      ext_lb    <= 1'b0;
                      end
  else
                      begin
                      ext_add   <= {10'b0000000000, mem_addr[13:1]};
                      ext_wdata <= mem_wdata;
                      ext_rd    <= mem_cs && mem_rd;
                      ext_wr    <= mem_cs && mem_wr;
                      ext_cs    <= {1'b0,mem_cs};
                      ext_stb   <= mem_cs;
                      ext_ub    <= mem_cs &&  mem_addr[0];
                      ext_lb    <= mem_cs && !mem_addr[0];
                      end
always@(posedge clk)
if(reset || enable) 
   begin
   wait_n  <= 1'b0;
   enableY  <= 4'b0000;
   end   
else
if (mem_cs  && (mem_rd || mem_wr))  
   begin
     if(enableY == 4'b0100) wait_n  <= 1'b1;
     else                   enableY  <= enableY +4'b0001;     
   end
else
   wait_n <= 1'b1;  
assign mem_wait = ~ wait_n;
io_ext_mem_interface_def_mb
#(.BANK_RST(8'h00),
  .WAIT_ST_RST(8'h04))
ext_mem_interface_micro_reg
( 
             .clk            ( clk     ),
             .reset          ( reset   ),
             .enable         ( enable  ),
             .cs             ( cs      ),              
             .wr             ( wr      ), 
             .rd             ( rd      ),
             .byte_lanes     ( 1'b1    ),
             .addr           ( addr    ),
             .wdata          ( wdata   ),
             .rdata          ( rdata   ),
             .bank_cs        (         ),
             .bank_dec       (         ),
             .bank_wr_0      (         ),
             .wait_st_cs     (         ),
             .wait_st_dec    (         ),
             .wait_st_wr_0   (         ),
             .next_wait_st   ( wait_st ),
             .next_bank      ( bank    ),
             .wait_st_rdata  ( wait_st ),
             .bank_rdata     ( bank    ),
             .wait_st        ( wait_st ),
             .bank           ( bank    )
);
  endmodule
 /*********************************************/  
 /* Vendor:                  opencores.org    */  
 /* Library:                            io    */  
 /* Component:        io_ext_mem_interface    */  
 /* Version:                           def    */  
 /* MemMap:                             mb    */  
 /* Base:                              0x0    */  
 /* Type:                                     */  
 /* Endian:                         Little    */  
 /*********************************************/  
 /* AddressBlock:                  ext_mem    */  
 /* NumBase:                             0    */  
 /* Range:                            0x10    */  
 /* NumRange:                           16    */  
 /* NumAddBits:                          4    */  
 /* Width:                               8    */  
 /* Byte_lanes:                          1    */  
 /* Byte_size:                           8    */  
 /*********************************************/  
 /* Reg Name:                         bank    */  
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
 /* Reg Name:                      wait_st    */  
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
 /*********************************************/  
 /* Max_dim:                             1    */  
 /* num_add:                             0    */  
 /* mas_has_read:                        1    */  
 /* mas_has_write:                       1    */  
 /* mas_has_create:                      1    */  
 /*********************************************/  
 /*********************************************/  
module io_ext_mem_interface_def_mb
#(  parameter UNSELECTED = {8{1'b1}},
    parameter UNMAPPED   = {8{1'b0}},
    parameter BANK_RST = 8'b0,
    parameter WAIT_ST_RST = 8'b0)
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
 output  wire  bank_cs  ,
 output   reg  bank_dec  ,
 input  wire  [8-1:0]    bank_rdata  ,
 output   reg  bank_wr_0  ,
 output  reg  [8-1:0]    bank  ,
 input  wire  [8-1:0]    next_bank  ,
 output  wire  wait_st_cs  ,
 output   reg  wait_st_dec  ,
 input  wire  [8-1:0]    wait_st_rdata  ,
 output   reg  wait_st_wr_0  ,
 output  reg  [8-1:0]    wait_st  ,
 input  wire  [8-1:0]    next_wait_st  
);
parameter BANK = 4'd2;
parameter BANK_END = 4'd3;
parameter WAIT_ST = 4'd0;
parameter WAIT_ST_END = 4'd1;
 reg  [8-1:0]    rdata_i;
reg  [8-1:0]    bank_wdata;
reg  [8-1:0]    wait_st_wdata;
/*QQQ        Reg_Name     Reg_Access sys_byte_lanes  reg_byte_lanes reg_size  reg_add   ar_base log_byte_lane phy_byte_lane  reg_lane   pad_size        padding     bigend    */  
/*QQQ             bank    read-write           1       1               8        2        0        0                 0           0           8            0          0       */  
/*QQQ          wait_st    read-write           1       1               8        0        0        0                 0           0           8            0          0       */  
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
BANK[4-1:0]:      rdata_i[0*8+8-1:0*8] =  bank_rdata[0*8+8-1:0*8] ;//QQQQ
WAIT_ST[4-1:0]:      rdata_i[0*8+8-1:0*8] =  wait_st_rdata[0*8+8-1:0*8] ;//QQQQ
    default:    rdata_i[0*8+8-1:0*8] = UNMAPPED;
    endcase
always@(*)
    begin
bank_wdata      =  wdata[0*8+8-1:0];//    1
wait_st_wdata      =  wdata[0*8+8-1:0];//    1
    end
always@(*)
    begin
bank_wr_0 = cs && wr && enable && byte_lanes[ 0 ] && ( addr[4-1:0]== BANK[4-1:0] ); //     
wait_st_wr_0 = cs && wr && enable && byte_lanes[ 0 ] && ( addr[4-1:0]== WAIT_ST[4-1:0] ); //     
    end
 always@(*)
     begin
        bank_dec = cs && ( addr[4-1:0]== BANK[4-1:0] );//  1
        wait_st_dec = cs && ( addr[4-1:0]== WAIT_ST[4-1:0] );//  1
     end
  /* verilator lint_off UNSIGNED */           
assign   bank_cs = cs && ( addr >= BANK ) && ( addr < BANK_END );
assign   wait_st_cs = cs && ( addr >= WAIT_ST ) && ( addr < WAIT_ST_END );
  /* verilator lint_on UNSIGNED */           
   always@(posedge clk)
     if(reset)  bank <=  BANK_RST;
        else
       begin
    if(bank_wr_0)    bank[8-1:0]  <=  bank_wdata[8-1:0]  ;
    else    bank[8-1:0]   <=    next_bank[8-1:0];
     end
   always@(posedge clk)
     if(reset)  wait_st <=  WAIT_ST_RST;
        else
       begin
    if(wait_st_wr_0)    wait_st[8-1:0]  <=  wait_st_wdata[8-1:0]  ;
    else    wait_st[8-1:0]   <=    next_wait_st[8-1:0];
     end
endmodule 
