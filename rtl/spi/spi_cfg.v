//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Tubo 8051 cores SPI Interface Module                        ////
////                                                              ////
////  This file is part of the Turbo 8051 cores project           ////
////  http://www.opencores.org/cores/turbo8051/                   ////
////                                                              ////
////  Description                                                 ////
////  Turbo 8051 definitions.                                     ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
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



module spi_cfg (

             mclk,
             reset_n,

        // Reg Bus Interface Signal
             reg_cs,
             reg_wr,
             reg_addr,
             reg_wdata,
             reg_be,

            // Outputs
            reg_rdata,
            reg_ack,


           // configuration signal
           cfg_tgt_sel        ,
           cfg_op_req         , // SPI operation request
           cfg_op_type        , // SPI operation type
           cfg_transfer_size  , // SPI transfer size
           cfg_sck_period     , // sck clock period
           cfg_sck_cs_period  , // cs setup/hold period
           cfg_cs_byte        , // cs bit information
           cfg_datain         , // data for transfer
           cfg_dataout        , // data for received
           hware_op_done      // operation done

        );



input         mclk;
input         reset_n;

output [1:0]  cfg_tgt_sel        ;

output        cfg_op_req         ; // SPI operation request
output [1:0]  cfg_op_type        ; // SPI operation type
output [1:0]  cfg_transfer_size  ; // SPI transfer size
output [5:0]  cfg_sck_period     ; // sck clock period
output [4:0]  cfg_sck_cs_period  ; // cs setup/hold period
output [7:0]  cfg_cs_byte        ; // cs bit information
output [31:0] cfg_datain         ; // data for transfer
input  [31:0] cfg_dataout        ; // data for received
input         hware_op_done      ; // operation done

//---------------------------------
// Reg Bus Interface Signal
//---------------------------------
input             reg_cs         ;
input             reg_wr         ;
input [3:0]       reg_addr       ;
input [31:0]      reg_wdata      ;
input [3:0]       reg_be         ;

// Outputs
output [31:0]     reg_rdata      ;
output            reg_ack        ;



//-----------------------------------------------------------------------
// Internal Wire Declarations
//-----------------------------------------------------------------------

wire           sw_rd_en;
wire           sw_wr_en;
wire  [3:0]    sw_addr ; // addressing 16 registers
wire  [3:0]    wr_be   ;

reg   [31:0]  reg_rdata      ;
reg           reg_ack     ;

wire [31:0]    reg_0;  // Software_Reg_0
wire [31:0]    reg_1;  // Software-Reg_1
wire [31:0]    reg_2;  // Software-Reg_2
wire [31:0]    reg_3;  // Software-Reg_3
wire [31:0]    reg_4;  // Software-Reg_4
wire [31:0]    reg_5;  // Software-Reg_5
wire [31:0]    reg_6;  // Software-Reg_6
wire [31:0]    reg_7;  // Software-Reg_7
wire [31:0]    reg_8;  // Software-Reg_8
wire [31:0]    reg_9;  // Software-Reg_9
wire [31:0]    reg_10; // Software-Reg_10
wire [31:0]    reg_11; // Software-Reg_11
wire [31:0]    reg_12; // Software-Reg_12
wire [31:0]    reg_13; // Software-Reg_13
wire [31:0]    reg_14; // Software-Reg_14
wire [31:0]    reg_15; // Software-Reg_15
reg  [31:0]    reg_out;

//-----------------------------------------------------------------------
// Main code starts here
//-----------------------------------------------------------------------

//-----------------------------------------------------------------------
// Internal Logic Starts here
//-----------------------------------------------------------------------
    assign sw_addr       = reg_addr [3:0];
    assign sw_rd_en      = reg_cs & !reg_wr;
    assign sw_wr_en      = reg_cs & reg_wr;
    assign wr_be         = reg_be;


//-----------------------------------------------------------------------
// Read path mux
//-----------------------------------------------------------------------

always @ (posedge mclk or negedge reset_n)
begin : preg_out_Seq
   if (reset_n == 1'b0)
   begin
      reg_rdata [31:0]  <= 32'h0000_0000;
      reg_ack           <= 1'b0;
   end
   else if (sw_rd_en && !reg_ack) 
   begin
      reg_rdata [31:0]  <= reg_out [31:0];
      reg_ack           <= 1'b1;
   end
   else if (sw_wr_en && !reg_ack) 
      reg_ack           <= 1'b1;
   else
   begin
      reg_ack        <= 1'b0;
   end
end


//-----------------------------------------------------------------------
// register read enable and write enable decoding logic
//-----------------------------------------------------------------------
wire   sw_wr_en_0 = sw_wr_en & (sw_addr == 4'h0);
wire   sw_rd_en_0 = sw_rd_en & (sw_addr == 4'h0);
wire   sw_wr_en_1 = sw_wr_en & (sw_addr == 4'h1);
wire   sw_rd_en_1 = sw_rd_en & (sw_addr == 4'h1);
wire   sw_wr_en_2 = sw_wr_en & (sw_addr == 4'h2);
wire   sw_rd_en_2 = sw_rd_en & (sw_addr == 4'h2);
wire   sw_wr_en_3 = sw_wr_en & (sw_addr == 4'h3);
wire   sw_rd_en_3 = sw_rd_en & (sw_addr == 4'h3);
wire   sw_wr_en_4 = sw_wr_en & (sw_addr == 4'h4);
wire   sw_rd_en_4 = sw_rd_en & (sw_addr == 4'h4);
wire   sw_wr_en_5 = sw_wr_en & (sw_addr == 4'h5);
wire   sw_rd_en_5 = sw_rd_en & (sw_addr == 4'h5);
wire   sw_wr_en_6 = sw_wr_en & (sw_addr == 4'h6);
wire   sw_rd_en_6 = sw_rd_en & (sw_addr == 4'h6);
wire   sw_wr_en_7 = sw_wr_en & (sw_addr == 4'h7);
wire   sw_rd_en_7 = sw_rd_en & (sw_addr == 4'h7);
wire   sw_wr_en_8 = sw_wr_en & (sw_addr == 4'h8);
wire   sw_rd_en_8 = sw_rd_en & (sw_addr == 4'h8);
wire   sw_wr_en_9 = sw_wr_en & (sw_addr == 4'h9);
wire   sw_rd_en_9 = sw_rd_en & (sw_addr == 4'h9);
wire   sw_wr_en_10 = sw_wr_en & (sw_addr == 4'hA);
wire   sw_rd_en_10 = sw_rd_en & (sw_addr == 4'hA);
wire   sw_wr_en_11 = sw_wr_en & (sw_addr == 4'hB);
wire   sw_rd_en_11 = sw_rd_en & (sw_addr == 4'hB);
wire   sw_wr_en_12 = sw_wr_en & (sw_addr == 4'hC);
wire   sw_rd_en_12 = sw_rd_en & (sw_addr == 4'hC);
wire   sw_wr_en_13 = sw_wr_en & (sw_addr == 4'hD);
wire   sw_rd_en_13 = sw_rd_en & (sw_addr == 4'hD);
wire   sw_wr_en_14 = sw_wr_en & (sw_addr == 4'hE);
wire   sw_rd_en_14 = sw_rd_en & (sw_addr == 4'hE);
wire   sw_wr_en_15 = sw_wr_en & (sw_addr == 4'hF);
wire   sw_rd_en_15 = sw_rd_en & (sw_addr == 4'hF);


always @( *)
begin : preg_sel_Com

  reg_out [31:0] = 32'd0;

  case (sw_addr [3:0])
    4'b0000 : reg_out [31:0] = reg_0 [31:0];     
    4'b0001 : reg_out [31:0] = reg_1 [31:0];    
    4'b0010 : reg_out [31:0] = reg_2 [31:0];     
    4'b0011 : reg_out [31:0] = reg_3 [31:0];    
    4'b0100 : reg_out [31:0] = reg_4 [31:0];    
    4'b0101 : reg_out [31:0] = reg_5 [31:0];    
    4'b0110 : reg_out [31:0] = reg_6 [31:0];    
    4'b0111 : reg_out [31:0] = reg_7 [31:0];    
    4'b1000 : reg_out [31:0] = reg_8 [31:0];    
    4'b1001 : reg_out [31:0] = reg_9 [31:0];    
    4'b1010 : reg_out [31:0] = reg_10 [31:0];   
    4'b1011 : reg_out [31:0] = reg_11 [31:0];   
    4'b1100 : reg_out [31:0] = reg_12 [31:0];   
    4'b1101 : reg_out [31:0] = reg_13 [31:0];
    4'b1110 : reg_out [31:0] = reg_14 [31:0];
    4'b1111 : reg_out [31:0] = reg_15 [31:0]; 
  endcase
end



//-----------------------------------------------------------------------
// Individual register assignments
//-----------------------------------------------------------------------
// Logic for Register 0 : SPI Control Register
//-----------------------------------------------------------------------
wire         cfg_op_req         = reg_0[31];    // cpu request
wire [1:0]   cfg_tgt_sel        = reg_0[24:23]; // target chip select
wire [1:0]   cfg_op_type        = reg_0[22:21]; // SPI operation type
wire [1:0]   cfg_transfer_size  = reg_0[20:19]; // SPI transfer size
wire [5:0]   cfg_sck_period     = reg_0[18:13]; // sck clock period
wire [4:0]   cfg_sck_cs_period  = reg_0[12:8];  // cs setup/hold period
wire [7:0]   cfg_cs_byte        = reg_0[7:0];   // cs bit information

generic_register #(8,0  ) u_spi_ctrl_be0 (
	      .we            ({8{sw_wr_en_0 & 
                                 wr_be[0]   }}  ),		 
	      .data_in       (reg_wdata[7:0]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_0[7:0]        )
          );

generic_register #(8,0  ) u_spi_ctrl_be1 (
	      .we            ({8{sw_wr_en_0 & 
                                wr_be[1]   }}  ),		 
	      .data_in       (reg_wdata[15:8]  ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_0[15:8]       )
          );

generic_register #(8,0  ) u_spi_ctrl_be2 (
	      .we            ({8{sw_wr_en_0 & 
                                wr_be[2]   }}  ),		 
	      .data_in       (reg_wdata[23:16] ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_0[23:16]       )
          );

assign reg_0[30:24] = 7'h0;

req_register #(0  ) u_spi_ctrl_req (
	      .cpu_we       ({sw_wr_en_0 & 
                             wr_be[3]   }       ),		 
	      .cpu_req      (reg_wdata[31]      ),
	      .hware_ack    (hware_op_done      ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_0[31]         )
          );




//-----------------------------------------------------------------------
// Logic for Register 1 : SPI Data In Register
//-----------------------------------------------------------------------
wire [31:0]   cfg_datain        = reg_1[31:0]; 

generic_register #(8,0  ) u_spi_din_be0 (
	      .we            ({8{sw_wr_en_1 & 
                                wr_be[0]   }}  ),		 
	      .data_in       (reg_wdata[7:0]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_1[7:0]        )
          );

generic_register #(8,0  ) u_spi_din_be1 (
	      .we            ({8{sw_wr_en_1 & 
                                wr_be[1]   }}  ),		 
	      .data_in       (reg_wdata[15:8]   ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_1[15:8]       )
          );

generic_register #(8,0  ) u_spi_din_be2 (
	      .we            ({8{sw_wr_en_1 & 
                                wr_be[2]   }}  ),		 
	      .data_in       (reg_wdata[23:16]  ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_1[23:16]      )
          );


generic_register #(8,0  ) u_spi_din_be3 (
	      .we            ({8{sw_wr_en_1 & 
                                wr_be[3]   }}  ),		 
	      .data_in       (reg_wdata[31:24]  ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_1[31:24]      )
          );


//-----------------------------------------------------------------------
// Logic for Register 2 : SPI Data output Register
//-----------------------------------------------------------------------
assign  reg_2 = cfg_dataout; 



endmodule
