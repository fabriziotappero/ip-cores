//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Tubo 8051 cores UART Interface Module                       ////
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

module uart_cfg (

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


       // configuration
            cfg_tx_enable,
            cfg_rx_enable,
            cfg_stop_bit ,
            cfg_pri_mod  ,

            frm_error_o,
            par_error_o,
            rx_fifo_full_err_o

        );



input         mclk;
input         reset_n;

       // configuration
output        cfg_tx_enable       ; // Tx Enable
output        cfg_rx_enable       ; // Rx Enable
output        cfg_stop_bit        ; // 0 -> 1 Stop, 1 -> 2 Stop
output  [1:0] cfg_pri_mod         ; // priority mode, 0 -> nop, 1 -> Even, 2 -> Odd

input         frm_error_o         ; // framing error
input         par_error_o         ; // par error
input         rx_fifo_full_err_o  ; // rx fifo full error

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
output            reg_ack     ;



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
// Logic for Register 0 : uart Control Register
//-----------------------------------------------------------------------
wire [1:0]   cfg_pri_mod     = reg_0[4:3]; // priority mode, 0 -> nop, 1 -> Even, 2 -> Odd
wire         cfg_stop_bit    = reg_0[2];   // 0 -> 1 Stop, 1 -> 2 Stop
wire         cfg_rx_enable   = reg_0[1];   // Rx Enable
wire         cfg_tx_enable   = reg_0[0];   // Tx Enable

generic_register #(5,0  ) u_uart_ctrl_be0 (
	      .we            ({5{sw_wr_en_0 & 
                                 wr_be[0]   }}  ),		 
	      .data_in       (reg_wdata[4:0]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_0[4:0]        )
          );


assign reg_0[31:5] = 27'h0;

//-----------------------------------------------------------------------
// Logic for Register 1 : uart interrupt status
//-----------------------------------------------------------------------
stat_register u_intr_bit0 (
		 //inputs
		 . clk        (mclk            ),
		 . reset_n    (reset_n         ),
		 . cpu_we     (sw_wr_en_1 &
                               wr_be[0]        ),		 
		 . cpu_ack    (reg_wdata[0]    ),
		 . hware_req  (frm_error_o     ),
		 
		 //outputs
		 . data_out   (reg_1[0]        )
		 );

stat_register u_intr_bit1 (
		 //inputs
		 . clk        (mclk            ),
		 . reset_n    (reset_n         ),
		 . cpu_we     (sw_wr_en_1 &
                               wr_be[0]        ),		 
		 . cpu_ack    (reg_wdata[1]    ),
		 . hware_req  (par_error_o     ),
		 
		 //outputs
		 . data_out   (reg_1[1]        )
		 );

stat_register u_intr_bit2 (
		 //inputs
		 . clk        (mclk                ),
		 . reset_n    (reset_n             ),
		 . cpu_we     (sw_wr_en_1 &
                               wr_be[0]            ),		 
		 . cpu_ack    (reg_wdata[2]        ),
		 . hware_req  (rx_fifo_full_err_o  ),
		 
		 //outputs
		 . data_out   (reg_1[2]            )
		 );

assign reg_1[31:3] = 29'h0;




endmodule
