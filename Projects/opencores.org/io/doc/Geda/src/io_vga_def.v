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
  io_vga_def 
     (
 input   wire                 clk,
 input   wire                 cs,
 input   wire                 enable,
 input   wire                 rd,
 input   wire                 reset,
 input   wire                 wr,
 input   wire    [ 3 :  0]        addr,
 input   wire    [ 7 :  0]        wdata,
 output   wire                 vga_hsync_n_pad_out,
 output   wire                 vga_vsync_n_pad_out,
 output   wire    [ 1 :  0]        vga_blue_pad_out,
 output   wire    [ 2 :  0]        vga_green_pad_out,
 output   wire    [ 2 :  0]        vga_red_pad_out,
 output   wire    [ 7 :  0]        rdata);
reg                        add_h_load;
reg                        add_l_load;
reg                        ascii_load;
reg     [ 7 :  0]              lat_wdata;
wire                        add_h_wr;
wire                        add_l_wr;
wire                        ascii_data_wr;
wire     [ 15 :  0]              vga_address;
wire     [ 7 :  0]              back_color;
wire     [ 7 :  0]              char_color;
wire     [ 7 :  0]              cntrl;
wire     [ 7 :  0]              cursor_color;
vga_char_ctrl_def
vga_char_ctrl 
   (
   .blue_pad_out      ( vga_blue_pad_out[1:0]  ),
   .green_pad_out      ( vga_green_pad_out[2:0]  ),
   .hsync_n_pad_out      ( vga_hsync_n_pad_out  ),
   .red_pad_out      ( vga_red_pad_out[2:0]  ),
   .vsync_n_pad_out      ( vga_vsync_n_pad_out  ),
    .add_h_load      ( add_h_load  ),
    .add_l_load      ( add_l_load  ),
    .address      ( vga_address[13:0] ),
    .ascii_load      ( ascii_load  ),
    .back_color      ( back_color[7:0] ),
    .char_color      ( char_color[7:0] ),
    .clk      ( clk  ),
    .cursor_color      ( cursor_color[7:0] ),
    .reset      ( reset  ),
    .wdata      ( lat_wdata[7:0] ));
io_vga_def_mb
    #( .CNTRL_RST        (8'b0),
       .CHAR_COLOR_RST   (8'h1c),
       .BACK_COLOR_RST   (8'h01),
       .CURSOR_COLOR_RST (8'he0))
 vga_micro_reg
 ( 
   .clk                ( clk               ),
   .reset              ( reset             ),
   .enable             ( enable            ),
   .cs                 ( cs                ),      
   .wr                 ( wr                ),
   .rd                 ( rd                ),
   .byte_lanes         ( 1'b1              ),
   .addr               ( addr              ),
   .wdata              ( wdata             ),
   .rdata              ( rdata             ),
     .ascii_data_cs        (),
     .ascii_data_dec       (),
     .ascii_data       (),
     .next_ascii_data       (),
     .add_l_cs       (),
     .add_l_dec       (),
     .add_l       (),
     .next_add_l       (),
     .add_h_cs       (),
     .add_h_dec       (),
     .add_h       (),
     .next_add_h       (),
     .vadd_l_cs       (),
     .vadd_l_dec       (),
     .vadd_h_cs       (),
     .vadd_h_dec       (),
     .cntrl_cs       (),
     .cntrl_dec       (),
     .cntrl_wr_0       (),
     .char_color_cs       (),
     .char_color_dec       (),
     .char_color_wr_0       (),
     .back_color_cs       (),
     .back_color_dec       (),
     .back_color_wr_0       (),
     .cursor_color_cs       (),
     .cursor_color_dec       (),
     .cursor_color_wr_0       (),
   .cntrl              ( cntrl             ),
   .char_color         ( char_color        ),
   .back_color         ( back_color        ),
   .cursor_color       ( cursor_color      ),
   .next_cntrl         ( cntrl             ),
   .next_char_color    ( char_color        ),
   .next_back_color    ( back_color        ),
   .next_cursor_color  ( cursor_color      ),
   .cntrl_rdata         ( cntrl             ),
   .char_color_rdata    ( char_color        ),
   .back_color_rdata    ( back_color        ),
   .cursor_color_rdata  ( cursor_color      ),
   .vadd_l_rdata        ( vga_address[7:0]  ),
   .vadd_h_rdata        ( vga_address[15:8] ),
   .ascii_data_wr_0     ( ascii_data_wr     ),
   .add_l_wr_0          ( add_l_wr          ),
   .add_h_wr_0          ( add_h_wr          ));
always@(posedge clk)
if (reset)     ascii_load          <= 1'b0;
else           ascii_load          <= ascii_data_wr;
always@(posedge clk)
if (reset)      add_l_load         <= 1'b0;
else            add_l_load         <= add_l_wr;
always@(posedge clk)
if (reset)      add_h_load         <= 1'b0;
else            add_h_load         <= add_h_wr;
always@(posedge clk)
if (reset)     lat_wdata  <= 8'h00;   
else           lat_wdata  <= wdata;   
  endmodule
 /*********************************************/  
 /* Vendor:                  opencores.org    */  
 /* Library:                            io    */  
 /* Component:                      io_vga    */  
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
 /* Reg Name:                   ascii_data    */  
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
 /* Reg Name:                        add_l    */  
 /* Reg Offset:                        0x2    */  
 /* Reg numOffset:                       2    */  
 /* Reg size:                            8    */  
 /* Reg Dim:                           0x1    */  
 /* Reg numDim:                          1    */  
 /* Reg DimBits:                         0    */  
 /* Reg Create:                          1    */  
 /* Reg access:                 write-only    */  
 /* Reg has_read:                        0    */  
 /* Reg has_write:                       1    */  
 /*********************************************/  
 /* Reg Name:                        add_h    */  
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
 /* Reg Name:                       vadd_l    */  
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
 /* Reg Name:                       vadd_h    */  
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
 /* Reg Name:                        cntrl    */  
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
 /* Reg Name:                   char_color    */  
 /* Reg Offset:                        0x8    */  
 /* Reg numOffset:                       8    */  
 /* Reg size:                            8    */  
 /* Reg Dim:                           0x1    */  
 /* Reg numDim:                          1    */  
 /* Reg DimBits:                         0    */  
 /* Reg Create:                          1    */  
 /* Reg access:                 read-write    */  
 /* Reg has_read:                        1    */  
 /* Reg has_write:                       1    */  
 /*********************************************/  
 /* Reg Name:                   back_color    */  
 /* Reg Offset:                        0xa    */  
 /* Reg numOffset:                      10    */  
 /* Reg size:                            8    */  
 /* Reg Dim:                           0x1    */  
 /* Reg numDim:                          1    */  
 /* Reg DimBits:                         0    */  
 /* Reg Create:                          1    */  
 /* Reg access:                 read-write    */  
 /* Reg has_read:                        1    */  
 /* Reg has_write:                       1    */  
 /*********************************************/  
 /* Reg Name:                 cursor_color    */  
 /* Reg Offset:                        0xc    */  
 /* Reg numOffset:                      12    */  
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
module io_vga_def_mb
#(  parameter UNSELECTED = {8{1'b1}},
    parameter UNMAPPED   = {8{1'b0}},
    parameter ASCII_DATA_RST = 8'b0,
    parameter ADD_L_RST = 8'b0,
    parameter ADD_H_RST = 8'b0,
    parameter CNTRL_RST = 8'b0,
    parameter CHAR_COLOR_RST = 8'b0,
    parameter BACK_COLOR_RST = 8'b0,
    parameter CURSOR_COLOR_RST = 8'b0)
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
 output  wire  ascii_data_cs  ,
 output   reg  ascii_data_dec  ,
 output   reg  ascii_data_wr_0  ,
 output  reg  [8-1:0]    ascii_data  ,
 input  wire  [8-1:0]    next_ascii_data  ,
 output  wire  add_l_cs  ,
 output   reg  add_l_dec  ,
 output   reg  add_l_wr_0  ,
 output  reg  [8-1:0]    add_l  ,
 input  wire  [8-1:0]    next_add_l  ,
 output  wire  add_h_cs  ,
 output   reg  add_h_dec  ,
 output   reg  add_h_wr_0  ,
 output  reg  [8-1:0]    add_h  ,
 input  wire  [8-1:0]    next_add_h  ,
 output  wire  vadd_l_cs  ,
 output   reg  vadd_l_dec  ,
 input  wire  [8-1:0]    vadd_l_rdata  ,
 output  wire  vadd_h_cs  ,
 output   reg  vadd_h_dec  ,
 input  wire  [8-1:0]    vadd_h_rdata  ,
 output  wire  cntrl_cs  ,
 output   reg  cntrl_dec  ,
 input  wire  [8-1:0]    cntrl_rdata  ,
 output   reg  cntrl_wr_0  ,
 output  reg  [8-1:0]    cntrl  ,
 input  wire  [8-1:0]    next_cntrl  ,
 output  wire  char_color_cs  ,
 output   reg  char_color_dec  ,
 input  wire  [8-1:0]    char_color_rdata  ,
 output   reg  char_color_wr_0  ,
 output  reg  [8-1:0]    char_color  ,
 input  wire  [8-1:0]    next_char_color  ,
 output  wire  back_color_cs  ,
 output   reg  back_color_dec  ,
 input  wire  [8-1:0]    back_color_rdata  ,
 output   reg  back_color_wr_0  ,
 output  reg  [8-1:0]    back_color  ,
 input  wire  [8-1:0]    next_back_color  ,
 output  wire  cursor_color_cs  ,
 output   reg  cursor_color_dec  ,
 input  wire  [8-1:0]    cursor_color_rdata  ,
 output   reg  cursor_color_wr_0  ,
 output  reg  [8-1:0]    cursor_color  ,
 input  wire  [8-1:0]    next_cursor_color  
);
parameter ASCII_DATA = 4'd0;
parameter ASCII_DATA_END = 4'd1;
parameter ADD_L = 4'd2;
parameter ADD_L_END = 4'd3;
parameter ADD_H = 4'd4;
parameter ADD_H_END = 4'd5;
parameter VADD_L = 4'd2;
parameter VADD_L_END = 4'd3;
parameter VADD_H = 4'd4;
parameter VADD_H_END = 4'd5;
parameter CNTRL = 4'd6;
parameter CNTRL_END = 4'd7;
parameter CHAR_COLOR = 4'd8;
parameter CHAR_COLOR_END = 4'd9;
parameter BACK_COLOR = 4'd10;
parameter BACK_COLOR_END = 4'd11;
parameter CURSOR_COLOR = 4'd12;
parameter CURSOR_COLOR_END = 4'd13;
 reg  [8-1:0]    rdata_i;
reg  [8-1:0]    ascii_data_wdata;
reg  [8-1:0]    add_l_wdata;
reg  [8-1:0]    add_h_wdata;
reg  [8-1:0]    cntrl_wdata;
reg  [8-1:0]    char_color_wdata;
reg  [8-1:0]    back_color_wdata;
reg  [8-1:0]    cursor_color_wdata;
/*QQQ        Reg_Name     Reg_Access sys_byte_lanes  reg_byte_lanes reg_size  reg_add   ar_base log_byte_lane phy_byte_lane  reg_lane   pad_size        padding     bigend    */  
/*QQQ       ascii_data    write-only           1       1               8        0        0        0                 0           0           8            0          0       */  
/*QQQ            add_l    write-only           1       1               8        2        0        0                 0           0           8            0          0       */  
/*QQQ            add_h    write-only           1       1               8        4        0        0                 0           0           8            0          0       */  
/*QQQ           vadd_l     read-only           1       1               8        2        0        0                 0           0           8            0          0       */  
/*QQQ           vadd_h     read-only           1       1               8        4        0        0                 0           0           8            0          0       */  
/*QQQ            cntrl    read-write           1       1               8        6        0        0                 0           0           8            0          0       */  
/*QQQ       char_color    read-write           1       1               8        8        0        0                 0           0           8            0          0       */  
/*QQQ       back_color    read-write           1       1               8       10        0        0                 0           0           8            0          0       */  
/*QQQ     cursor_color    read-write           1       1               8       12        0        0                 0           0           8            0          0       */  
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
VADD_L[4-1:0]:      rdata_i[0*8+8-1:0*8] =  vadd_l_rdata[0*8+8-1:0*8] ;//QQQQ
VADD_H[4-1:0]:      rdata_i[0*8+8-1:0*8] =  vadd_h_rdata[0*8+8-1:0*8] ;//QQQQ
CNTRL[4-1:0]:      rdata_i[0*8+8-1:0*8] =  cntrl_rdata[0*8+8-1:0*8] ;//QQQQ
CHAR_COLOR[4-1:0]:      rdata_i[0*8+8-1:0*8] =  char_color_rdata[0*8+8-1:0*8] ;//QQQQ
BACK_COLOR[4-1:0]:      rdata_i[0*8+8-1:0*8] =  back_color_rdata[0*8+8-1:0*8] ;//QQQQ
CURSOR_COLOR[4-1:0]:      rdata_i[0*8+8-1:0*8] =  cursor_color_rdata[0*8+8-1:0*8] ;//QQQQ
    default:    rdata_i[0*8+8-1:0*8] = UNMAPPED;
    endcase
always@(*)
    begin
ascii_data_wdata      =  wdata[0*8+8-1:0];//    1
add_l_wdata      =  wdata[0*8+8-1:0];//    1
add_h_wdata      =  wdata[0*8+8-1:0];//    1
cntrl_wdata      =  wdata[0*8+8-1:0];//    1
char_color_wdata      =  wdata[0*8+8-1:0];//    1
back_color_wdata      =  wdata[0*8+8-1:0];//    1
cursor_color_wdata      =  wdata[0*8+8-1:0];//    1
    end
always@(*)
    begin
ascii_data_wr_0 = cs && wr && enable && byte_lanes[ 0 ] && ( addr[4-1:0]== ASCII_DATA[4-1:0] ); //     
add_l_wr_0 = cs && wr && enable && byte_lanes[ 0 ] && ( addr[4-1:0]== ADD_L[4-1:0] ); //     
add_h_wr_0 = cs && wr && enable && byte_lanes[ 0 ] && ( addr[4-1:0]== ADD_H[4-1:0] ); //     
cntrl_wr_0 = cs && wr && enable && byte_lanes[ 0 ] && ( addr[4-1:0]== CNTRL[4-1:0] ); //     
char_color_wr_0 = cs && wr && enable && byte_lanes[ 0 ] && ( addr[4-1:0]== CHAR_COLOR[4-1:0] ); //     
back_color_wr_0 = cs && wr && enable && byte_lanes[ 0 ] && ( addr[4-1:0]== BACK_COLOR[4-1:0] ); //     
cursor_color_wr_0 = cs && wr && enable && byte_lanes[ 0 ] && ( addr[4-1:0]== CURSOR_COLOR[4-1:0] ); //     
    end
 always@(*)
     begin
        ascii_data_dec = cs && ( addr[4-1:0]== ASCII_DATA[4-1:0] );//  1
        add_l_dec = cs && ( addr[4-1:0]== ADD_L[4-1:0] );//  1
        add_h_dec = cs && ( addr[4-1:0]== ADD_H[4-1:0] );//  1
        vadd_l_dec = cs && ( addr[4-1:0]== VADD_L[4-1:0] );//  1
        vadd_h_dec = cs && ( addr[4-1:0]== VADD_H[4-1:0] );//  1
        cntrl_dec = cs && ( addr[4-1:0]== CNTRL[4-1:0] );//  1
        char_color_dec = cs && ( addr[4-1:0]== CHAR_COLOR[4-1:0] );//  1
        back_color_dec = cs && ( addr[4-1:0]== BACK_COLOR[4-1:0] );//  1
        cursor_color_dec = cs && ( addr[4-1:0]== CURSOR_COLOR[4-1:0] );//  1
     end
  /* verilator lint_off UNSIGNED */           
assign   ascii_data_cs = cs && ( addr >= ASCII_DATA ) && ( addr < ASCII_DATA_END );
assign   add_l_cs = cs && ( addr >= ADD_L ) && ( addr < ADD_L_END );
assign   add_h_cs = cs && ( addr >= ADD_H ) && ( addr < ADD_H_END );
assign   vadd_l_cs = cs && ( addr >= VADD_L ) && ( addr < VADD_L_END );
assign   vadd_h_cs = cs && ( addr >= VADD_H ) && ( addr < VADD_H_END );
assign   cntrl_cs = cs && ( addr >= CNTRL ) && ( addr < CNTRL_END );
assign   char_color_cs = cs && ( addr >= CHAR_COLOR ) && ( addr < CHAR_COLOR_END );
assign   back_color_cs = cs && ( addr >= BACK_COLOR ) && ( addr < BACK_COLOR_END );
assign   cursor_color_cs = cs && ( addr >= CURSOR_COLOR ) && ( addr < CURSOR_COLOR_END );
  /* verilator lint_on UNSIGNED */           
   always@(posedge clk)
     if(reset)  ascii_data <=  ASCII_DATA_RST;
        else
       begin
    if(ascii_data_wr_0)    ascii_data[8-1:0]  <=  ascii_data_wdata[8-1:0]  ;
    else    ascii_data[8-1:0]   <=    next_ascii_data[8-1:0];
     end
   always@(posedge clk)
     if(reset)  add_l <=  ADD_L_RST;
        else
       begin
    if(add_l_wr_0)    add_l[8-1:0]  <=  add_l_wdata[8-1:0]  ;
    else    add_l[8-1:0]   <=    next_add_l[8-1:0];
     end
   always@(posedge clk)
     if(reset)  add_h <=  ADD_H_RST;
        else
       begin
    if(add_h_wr_0)    add_h[8-1:0]  <=  add_h_wdata[8-1:0]  ;
    else    add_h[8-1:0]   <=    next_add_h[8-1:0];
     end
   always@(posedge clk)
     if(reset)  cntrl <=  CNTRL_RST;
        else
       begin
    if(cntrl_wr_0)    cntrl[8-1:0]  <=  cntrl_wdata[8-1:0]  ;
    else    cntrl[8-1:0]   <=    next_cntrl[8-1:0];
     end
   always@(posedge clk)
     if(reset)  char_color <=  CHAR_COLOR_RST;
        else
       begin
    if(char_color_wr_0)    char_color[8-1:0]  <=  char_color_wdata[8-1:0]  ;
    else    char_color[8-1:0]   <=    next_char_color[8-1:0];
     end
   always@(posedge clk)
     if(reset)  back_color <=  BACK_COLOR_RST;
        else
       begin
    if(back_color_wr_0)    back_color[8-1:0]  <=  back_color_wdata[8-1:0]  ;
    else    back_color[8-1:0]   <=    next_back_color[8-1:0];
     end
   always@(posedge clk)
     if(reset)  cursor_color <=  CURSOR_COLOR_RST;
        else
       begin
    if(cursor_color_wr_0)    cursor_color[8-1:0]  <=  cursor_color_wdata[8-1:0]  ;
    else    cursor_color[8-1:0]   <=    next_cursor_color[8-1:0];
     end
endmodule 
