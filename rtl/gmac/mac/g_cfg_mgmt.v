//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Tubo 8051 cores MAC Interface Module                        ////
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
/***************************************************************
  Description:
  cfg_mgmt.v: contains the configuration, register information, Application
              read from any location. But can write to a limited set of locations,
              Please refer to the design data sheets for register locations
***********************************************************************/
//`timescale 1ns/100ps
module g_cfg_mgmt (
		 //List of Inputs

                 // Reg Bus Interface Signal
                 reg_cs,
                 reg_wr,
                 reg_addr,
                 reg_wdata,
                 reg_be,

                 // Outputs
                 reg_rdata,
                 reg_ack,

                 // Rx Status
                 rx_sts_vld,
                 rx_sts,

                 // Rx Status
                 tx_sts_vld,
                 tx_sts,

		 // MDIO READ DATA FROM PHY
		            md2cf_cmd_done,
		            md2cf_status,
		            md2cf_data,
		            
		            app_clk,
		            app_reset_n,

		            //List of Outputs
		            // MII Control
		            cf2mi_loopback_en,
		            cf_mac_mode,
		            cf_chk_rx_dfl,
		            cf2mi_rmii_en,

                 cfg_uni_mac_mode_change_i,

		             //CHANNEL enable
		             cf2tx_ch_en,
		             //CHANNEL CONTROL TX
		             cf_silent_mode,
		             cf2df_dfl_single,
		             cf2df_dfl_single_rx,
		             cf2tx_pad_enable,
		             cf2tx_append_fcs,
		             //CHANNEL CONTROL RX
		             cf2rx_ch_en,
		             cf2rx_strp_pad_en,
		             cf2rx_snd_crc,
		             cf2rx_runt_pkt_en,
		             cf_mac_sa,
                 cfg_ip_sa,
                 cfg_mac_filter,

		             cf2rx_max_pkt_sz,
		             cf2tx_force_bad_fcs,
		 //MDIO CONTROL & DATA
                 cf2md_datain,
                 cf2md_regad,
                 cf2md_phyad,
                 cf2md_op,
                 cf2md_go,

                 rx_buf_base_addr,
                 tx_buf_base_addr,
                 rx_buf_qbase_addr,
                 tx_buf_qbase_addr,

                 tx_qcnt_inc,
                 tx_qcnt_dec,
                 tx_qcnt,

                 rx_qcnt_inc,
                 rx_qcnt_dec,
                 rx_qcnt

     );
  
   parameter mac_mdio_en = 1'b1;


  //pin out definations
   //---------------------------------
   // Reg Bus Interface Signal
   //---------------------------------
   input             reg_cs               ;
   input             reg_wr               ;
   input [3:0]       reg_addr             ;
   input [31:0]      reg_wdata            ;
   input [3:0]       reg_be               ;
   
   // Outputs
   output [31:0]     reg_rdata            ;
   output            reg_ack              ;

   input             rx_sts_vld           ; // rx status valid indication, sync w.r.t app clk
   input [7:0]       rx_sts               ; // rx status bits

   input             tx_sts_vld           ; // tx status valid indication, sync w.r.t app clk
   input             tx_sts               ; // tx status bits

  //List of Inputs

  input		           app_clk              ; 
  input               app_reset_n         ;
  input		            md2cf_cmd_done      ; // Read/Write MDIO completed
  input		            md2cf_status        ; // MDIO transfer error
  input [15:0]	      md2cf_data          ; // Data from PHY for a
                                            // mdio read access
 
 
  //List of Outputs
  output	            cf2mi_rmii_en       ; // Working in RMII when set to 1
  output	            cf_mac_mode         ; // mac mode set this to 1 for 100Mbs/10Mbs
  output	            cf_chk_rx_dfl       ; // Check for RX Deferal 
  output [47:0]	      cf_mac_sa           ;
  output [31:0]	      cfg_ip_sa           ;
  output [31:0]	      cfg_mac_filter      ;
  output	            cf2tx_ch_en         ; //enable the TX channel
  output	            cf_silent_mode      ; //PHY Inactive 
  output [7:0]	      cf2df_dfl_single    ; //number of clk ticks for dfl
  output [7:0]	      cf2df_dfl_single_rx ; //number of clk ticks for dfl
  
  output	            cf2tx_pad_enable    ; //enable padding, < 64 bytes
  output	            cf2tx_append_fcs    ; //append CRC for TX frames
  output	            cf2rx_ch_en         ; //Enable RX channel
  output	            cf2rx_strp_pad_en   ; //strip the padded bytes on RX frame
  output	            cf2rx_snd_crc       ; //send FCS to application, else strip
                                            //the FCS before sending to application
  output	            cf2mi_loopback_en   ; // TX to RX loop back enable
  output	            cf2rx_runt_pkt_en   ; //don't throw packets less than 64 bytes
  output [15:0]	      cf2md_datain        ;
  output [4:0]	      cf2md_regad         ;
  output [4:0]	      cf2md_phyad         ;
  output	            cf2md_op            ;
  output	            cf2md_go            ;

  output [15:0]       cf2rx_max_pkt_sz    ; //max rx packet size
  output      	      cf2tx_force_bad_fcs ; //force bad fcs on tx

  output              cfg_uni_mac_mode_change_i;

  output [3:0]        rx_buf_base_addr;   // Rx Data Buffer Base Address
  output [3:0]        tx_buf_base_addr;   // Tx Data Buffer Base Address
  output [9:0]        rx_buf_qbase_addr;  // Rx Q Base Address
  output [9:0]        tx_buf_qbase_addr;  // Tx Q Base Address

  input               tx_qcnt_inc;
  input               tx_qcnt_dec;
  output [3:0]        tx_qcnt;

  input               rx_qcnt_inc;
  input               rx_qcnt_dec;
  output [3:0]        rx_qcnt;

  
// Wire assignments for output signals
  wire [15:0]	cf2md_datain;
  wire [4:0]	cf2md_regad;
  wire [4:0]	cf2md_phyad;
  wire		cf2md_op;
  wire		cf2md_go;
  wire		mdio_cmd_done_sync;

 wire		int_mdio_cmd_done_sync;
 assign mdio_cmd_done_sync = (mac_mdio_en) ? int_mdio_cmd_done_sync : 1'b0;

 s2f_sync U1_s2f_sync ( .sync_out_pulse(int_mdio_cmd_done_sync),
			  .in_pulse(md2cf_cmd_done),
			  .dest_clk(app_clk),
			  .reset_n(app_reset_n));

 

// Wire and Reg assignments for local signals
  reg         int_md2cf_status;
  wire [7:0]  mac_mode_out;
  wire [7:0]  mac_cntrl_out_1, mac_cntrl_out_2;
  wire [7:0]  dfl_params_rx_out;
  wire [7:0]  dfl_params1_out;
  wire [7:0]  slottime_out_1;
  wire [7:0]  slottime_out_2;
  wire [31:0] mdio_cmd_out;
  wire [7:0]  mdio_stat_out_1;
  wire [7:0]  mdio_stat_out_2;
  wire [7:0]  mdio_stat_out_3;  
  wire [7:0]  mdio_stat_out_4;
  wire [7:0]  mdio_cmd_out_1;
  wire [7:0]  mdio_cmd_out_2;
  wire [7:0]  mdio_cmd_out_3;
  wire [7:0]  mdio_cmd_out_4;
  wire [7:0]  mac_sa_out_1;
  wire [7:0]  mac_sa_out_2;
  wire [7:0]  mac_sa_out_3;
  wire [7:0]  mac_sa_out_4;
  wire [7:0]  mac_sa_out_5;
  wire [7:0]  mac_sa_out_6;
  wire [47:0] cf_mac_sa;
  wire [15:0] cf2rx_max_pkt_sz;
  wire       cf2tx_force_bad_fcs;
  reg        force_bad_fcs;
  reg        cont_force_bad_fcs;
  wire [31:0]  mdio_stat_out;
  reg  cf2tx_force_bad_fcs_en;
  reg  cf2tx_cont_force_bad_fcs_en;
  reg [15:0]  int_mdio_stat_out;
   
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
// Internal Logic Starts here
//-----------------------------------------------------------------------
    assign sw_addr       = reg_addr [3:0];
    assign sw_rd_en      = reg_cs & !reg_wr;
    assign sw_wr_en      = reg_cs & reg_wr;
    assign wr_be         = reg_be;
 
   
//-----------------------------------------------------------------------
// Read path mux
//-----------------------------------------------------------------------

always @ (posedge app_clk or negedge app_reset_n)
begin : preg_out_Seq
   if (app_reset_n == 1'b0)
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
 
    
  //instantiate all the registers

  //========================================================================//
  // TX_CNTRL_REGISTER : Address value 00H
  // BIT[0] = Transmit Channel Enable
  // BIT[1] = DONT CARE 
  // BIT[2] = Retry Packet in case of Collisions
  // BIT[3] = Enable padding
  // BIT[4] = Append CRC
  // BIT[5] = Perform a Two Part Deferral
  // BIT[6] = RMII Enable bit
  // BIT[7] = Force TX FCS Error
 

generic_register #(8,0  ) u_mac_cntrl_reg_1 (
	      .we            ({8{sw_wr_en_0 & 
                                 wr_be[0] }}),		 
	      .data_in       (reg_wdata[7:0]      ),
	      .reset_n       (app_reset_n         ),
	      .clk           (app_clk             ),
	      
	      //List of Outs
	      .data_out      (mac_cntrl_out_1[7:0] )
          );

generic_register #(8,0  ) u_mac_cntrl_reg_2 (
	      .we            ({8{sw_wr_en_0 & 
                                 wr_be[1]}} ),		 
	      .data_in       (reg_wdata[15:8]     ),
	      .reset_n       (app_reset_n         ),
	      .clk           (app_clk             ),
	      
	      //List of Outs
	      .data_out      (mac_cntrl_out_2[7:0] )
          );

 generic_register #(8,0  )  u_mac_cntrl_reg_3 (
	      .we            ({8{sw_wr_en_0 & wr_be[2] }}),		 
	      .data_in       (reg_wdata[23:16]    ),
	      .reset_n       (app_reset_n         ),
	      .clk           (app_clk             ),
	      
	      //List of Outs
	      .data_out      ({tx_buf_base_addr[3:0],
                         rx_buf_base_addr[3:0]} )
          );


  // TX Control Register 
  assign cf2tx_ch_en         = mac_cntrl_out_1[0];
  assign cf2tx_pad_enable    = mac_cntrl_out_1[3];
  assign cf2tx_append_fcs    = mac_cntrl_out_1[4];
  assign cf2tx_force_bad_fcs = mac_cntrl_out_1[7];

  // RX_CNTRL_REGISTER
  // BIT[0] = Receive Channel Enable
  // BIT[1] = Strip Padding from the Receive data
  // BIT[2] = Send CRC along with data to the host
  // BIT[4] = Check RX Deferral
  // BIT[6] = Receive Runt Packet
  assign cf2rx_ch_en         = mac_cntrl_out_2[0];
  assign cf2rx_strp_pad_en   = mac_cntrl_out_2[1];
  assign cf2rx_snd_crc       = mac_cntrl_out_2[2];
  assign cf_chk_rx_dfl       = mac_cntrl_out_2[4];
  assign cf2rx_runt_pkt_en   = mac_cntrl_out_2[6];

assign reg_0[31:0] = {8'h0,tx_buf_base_addr[3:0],
                      rx_buf_base_addr[3:0],
                      mac_cntrl_out_2[7:0],
                      mac_cntrl_out_1[7:0]};


// reg1 free
assign reg_1[31:0] = 32'h0;

//========================================================================//
  //TRANSMIT DEFFERAL CONTROL REGISTER: Address value 08H
  //BIT[7:0] = Defferal TX
  //BIT[15:8] = Defferal RX

  generic_register #(8,0  ) dfl_params1_en_reg (
	      .we            ({8{sw_wr_en_2 & 
                           wr_be[0]   }}    ),		 
	      .data_in       (reg_wdata[7:0]      ),
	      .reset_n       (app_reset_n         ),
	      .clk           (app_clk             ),
	      
	      //List of Outs
	      .data_out      (dfl_params1_out[7:0] )
          );

  assign cf2df_dfl_single = dfl_params1_out[7:0];

  generic_register #(8,0  ) dfl_params_rx_en_reg (
	      .we            ({8{sw_wr_en_2 & 
                           wr_be[1]   }}    ),		 
	      .data_in       (reg_wdata[15:8]     ),
	      .reset_n       (app_reset_n         ),
	      .clk           (app_clk             ),
	      
	      //List of Outs
	      .data_out      (dfl_params_rx_out[7:0] )
          );
  assign cf2df_dfl_single_rx = dfl_params_rx_out[7:0];
  
assign reg_2[15:0] = {16'h0,dfl_params_rx_out,dfl_params1_out};
  
  //========================================================================//
  // MAC_MODE  REGISTER: Address value 0CH
  // BIT[0] = 10/100 or 1000 1 1000, 0 is 10/100 Channel Enable
  // BIT[1] = Mii/Rmii Default is Mii
  // BIT[2] = MAC used in Loop back Mode 
  // BIT[3] = Burst Enable 
  // BIT[4] = Half Duplex 
  // BIT[5] = Silent Mode (During Loopback the Tx --> RX and NOT to PHY) 
  // BIT[6] = crs based flow control enable
  // BIT[7] = Mac Mode Change
 
  generic_register #(8,0  ) mac_mode_reg (
	      .we            ({8{sw_wr_en_3 & wr_be[0]}}),
	      .data_in       (reg_wdata[7:0]      ),
	      .reset_n       (app_reset_n         ),
	      .clk           (app_clk             ),
	      
	      //List of Outs
	      .data_out      (mac_mode_out[7:0] )
          );

  assign cf_mac_mode                  = mac_mode_out[0];
  assign cf2mi_rmii_en                = mac_mode_out[1];
  assign cf2mi_loopback_en            = mac_mode_out[2];
  assign cf_silent_mode               = mac_mode_out[5];
  assign cfg_uni_mac_mode_change_i    = mac_mode_out[7];


assign reg_3[31:0] = {24'h0,mac_mode_out};
  //========================================================================//
  //MDIO COMMAND REGISTER: ADDRESS 10H
  //BIT[15:0] = MDIO DATA TO PHY
  //BIT[20:16] = MDIO REGISTER ADDR
  //BIT[25:21] = MDIO PHY ADDR
  //BIT[26] = MDIO COMMAND OPCODE READ/WRITE(0:read,1:write)
  //BIT[31] = GO MDIO

  generic_register #(8,0  ) mdio_cmd_reg_1 (
	      .we            ({8{sw_wr_en_4 & 
                                 wr_be[0]}} ),		 
	      .data_in       (reg_wdata[7:0]      ),
	      .reset_n       (app_reset_n         ),
	      .clk           (app_clk             ),
	      
	      //List of Outs
	      .data_out      (mdio_cmd_out_1[7:0] )
          );

  generic_register #(8,0  ) mdio_cmd_reg_2 (
	      .we            ({8{sw_wr_en_4 & 
                                 wr_be[1]}} ),		 
	      .data_in       (reg_wdata[15:8]     ),
	      .reset_n       (app_reset_n         ),
	      .clk           (app_clk             ),
	      
	      //List of Outs
	      .data_out      (mdio_cmd_out_2[7:0] )
          );

  generic_register #(8,0  ) mdio_cmd_reg_3 (
	      .we            ({8{sw_wr_en_4 & 
                                 wr_be[2]}} ),		 
	      .data_in       (reg_wdata[23:16]    ),
	      .reset_n       (app_reset_n         ),
	      .clk           (app_clk             ),
	      
	      //List of Outs
	      .data_out      (mdio_cmd_out_3[7:0] )
          );



  //byte_reg  mdio_cmd_reg_4 (.we({8{mdio_cmd_en_4 && cfg_rw}}), .data_in(reg_wdata),
  //		       .reset_n(app_reset_n), .clk(app_clk), .data_out(mdio_cmd_out_4));


  generic_register #(7,0  ) mdio_cmd_reg_4 (
	      .we            ({7{sw_wr_en_4 & 
                                 wr_be[3]}} ),		 
	      .data_in       (reg_wdata[30:24]    ),
	      .reset_n       (app_reset_n         ),
	      .clk           (app_clk             ),
	      
	      //List of Outs
	      .data_out      (mdio_cmd_out_4[6:0] )
          );

req_register #(0  ) u_mdio_req (
	      .cpu_we       ({sw_wr_en_4 & 
                             wr_be[3]   } ),		 
	      .cpu_req      (reg_wdata[31]      ),
	      .hware_ack    (mdio_cmd_done_sync ),
	      .reset_n       (app_reset_n       ),
	      .clk           (app_clk           ),
	      
	      //List of Outs
	      .data_out      (mdio_cmd_out_4[7] )
          );


  assign mdio_cmd_out = {mdio_cmd_out_4, mdio_cmd_out_3,mdio_cmd_out_2,mdio_cmd_out_1};
  
  assign reg_4 = {mdio_cmd_out};

  assign cf2md_datain = mdio_cmd_out[15:0];
  assign cf2md_regad = mdio_cmd_out[20:16];
  assign cf2md_phyad = mdio_cmd_out[25:21];
  assign cf2md_op = mdio_cmd_out[26];
  assign cf2md_go = mdio_cmd_out[31];

 
  //========================================================================//
  //MDIO STATUS REGISTER: ADDRESS 14H
  //BIT[15:0] = MDIO DATA FROM PHY
  //BIT[31] = STATUS OF MDIO TRANSFER
  
  always @(posedge app_clk
           or negedge app_reset_n)
    begin
      if(!app_reset_n) begin
	int_mdio_stat_out <= 16'b0;
        int_md2cf_status <= 1'b0;
      end
      else 
        if(mdio_cmd_done_sync)
	  begin
	    int_mdio_stat_out[15:0] <= md2cf_data;
	    // int_mdio_stat_out[30:16] <= int_mdio_stat_out[30:16];
	    int_md2cf_status <= md2cf_status;
	  end // else: !if(reset)
    end // always @ (posedge app_clk...

  assign mdio_stat_out = (mac_mdio_en == 1'b1) ? {int_md2cf_status, 15'b0, int_mdio_stat_out} : 32'b0;


  assign reg_5 = {mdio_stat_out};
 
  //========================================================================//
  //MAC Source Address Register 18-1C

  generic_register #(8,0  ) mac_sa_reg_1 (
	      .we            ({8{sw_wr_en_6 & wr_be[0] }}),		 
	      .data_in       (reg_wdata[7:0]    ),
	      .reset_n       (app_reset_n         ),
	      .clk           (app_clk             ),
	      
	      //List of Outs
	      .data_out      (mac_sa_out_1[7:0] )
          );
  generic_register #(8,0  ) mac_sa_reg_2 (
	      .we            ({8{sw_wr_en_6 & wr_be[1] }}),		 
	      .data_in       (reg_wdata[15:8]    ),
	      .reset_n       (app_reset_n         ),
	      .clk           (app_clk             ),
	      
	      //List of Outs
	      .data_out      (mac_sa_out_2[7:0] )
          );

  generic_register #(8,0  ) mac_sa_reg_3 (
	      .we            ({8{sw_wr_en_6 & wr_be[2] }}),		 
	      .data_in       (reg_wdata[23:16]    ),
	      .reset_n       (app_reset_n         ),
	      .clk           (app_clk             ),
	      
	      //List of Outs
	      .data_out      (mac_sa_out_3[7:0] )
          );

  generic_register #(8,0  ) mac_sa_reg_4 (
	      .we            ({8{sw_wr_en_6 & wr_be[3] }}),		 
	      .data_in       (reg_wdata[31:24]    ),
	      .reset_n       (app_reset_n         ),
	      .clk           (app_clk             ),
	      
	      //List of Outs
	      .data_out      (mac_sa_out_4[7:0] )
          );

  generic_register #(8,0  ) mac_sa_reg_5 (
	      .we            ({8{sw_wr_en_7 & wr_be[0] }}),		 
	      .data_in       (reg_wdata[7:0]    ),
	      .reset_n       (app_reset_n         ),
	      .clk           (app_clk             ),
	      
	      //List of Outs
	      .data_out      (mac_sa_out_5[7:0] )
          );

  generic_register #(8,0  ) mac_sa_reg_6 (
	      .we            ({8{sw_wr_en_7 & wr_be[1] }}),		 
	      .data_in       (reg_wdata[15:8]    ),
	      .reset_n       (app_reset_n         ),
	      .clk           (app_clk             ),
	      
	      //List of Outs
	      .data_out      (mac_sa_out_6[7:0] )
          );

//  assign cf_mac_sa = { mac_sa_out_1, mac_sa_out_2, mac_sa_out_3,
//                       mac_sa_out_4, mac_sa_out_5, mac_sa_out_6};
  assign cf_mac_sa = { mac_sa_out_6, mac_sa_out_5, mac_sa_out_4,
                       mac_sa_out_3, mac_sa_out_2, mac_sa_out_1};

  assign reg_6[31:0] = cf_mac_sa[31:0];
  assign reg_7[31:0] = {16'h0,cf_mac_sa[47:32]};
//========================================================================//
//MAC max packet size Register 20

  generic_register #(8,0  ) max_pkt_sz_reg0 (
	      .we            ({8{sw_wr_en_8 & wr_be[0] }}),		 
	      .data_in       (reg_wdata[7:0]    ),
	      .reset_n       (app_reset_n         ),
	      .clk           (app_clk             ),
	      
	      //List of Outs
	      .data_out      (cf2rx_max_pkt_sz[7:0] )
          );

  generic_register #(8,0  ) max_pkt_sz_reg1 (
	      .we            ({8{sw_wr_en_8 & wr_be[1] }}),		 
	      .data_in       (reg_wdata[15:8]    ),
	      .reset_n       (app_reset_n         ),
	      .clk           (app_clk             ),
	      
	      //List of Outs
	      .data_out      (cf2rx_max_pkt_sz[15:8] )
          );

  assign reg_8[31:0] = {16'h0,cf2rx_max_pkt_sz[15:0]};


//========================================================================//
//MAC max packet size Register 20

  generic_register #(2,0  )  m_rx_qbase_addr_1 (
	      .we            ({2{sw_wr_en_9 & wr_be[0] }}),		 
	      .data_in       (reg_wdata[7:6]    ),
	      .reset_n       (app_reset_n         ),
	      .clk           (app_clk             ),
	      
	      //List of Outs
	      .data_out      (rx_buf_qbase_addr[1:0] )
          );

  generic_register #(8,0  )  m_rx_qbase_addr_2 (
	      .we            ({8{sw_wr_en_9 & wr_be[1] }}),		 
	      .data_in       (reg_wdata[15:8]    ),
	      .reset_n       (app_reset_n         ),
	      .clk           (app_clk             ),
	      
	      //List of Outs
	      .data_out      (rx_buf_qbase_addr[9:2] )
          );


  generic_register #(2,0  ) m_tx_qbase_addr_1 (
	      .we            ({2{sw_wr_en_9 & wr_be[2] }}),		 
	      .data_in       (reg_wdata[23:22]    ),
	      .reset_n       (app_reset_n         ),
	      .clk           (app_clk             ),
	      
	      //List of Outs
	      .data_out      (tx_buf_qbase_addr[1:0] )
          );

  generic_register #(8,0  ) m_tx_qbase_addr_2 (
	      .we            ({8{sw_wr_en_9 & wr_be[3] }}),		 
	      .data_in       (reg_wdata[31:24]    ),
	      .reset_n       (app_reset_n         ),
	      .clk           (app_clk             ),
	      
	      //List of Outs
	      .data_out      (tx_buf_qbase_addr[9:2] )
          );


  assign reg_9[15:0]  = {rx_buf_qbase_addr[9:0],6'h0};
  assign reg_9[31:16] = {tx_buf_qbase_addr[9:0],6'h0};



//-----------------------------------------------------------------------
// RX-Clock Static Counter Status Signal
//-----------------------------------------------------------------------
// Note: rx_sts_vld signal is only synchronised w.r.t application clock, and
//       assumption is rx_sts is stable untill next packet received
 assign  rx_good_frm_trig = rx_sts_vld && (rx_sts[7:0] == 'h0);
 assign  rx_bad_frm_trig  = rx_sts_vld && (rx_sts[7:0] != 'h0);


stat_counter #(16) u_stat_rx_good_frm  (
   // Clock and Reset Signals
         . sys_clk          (app_clk         ),
         . s_reset_n        (app_reset_n     ),
  
         . count_inc        (rx_good_frm_trig),
         . count_dec        (1'b0            ),
  
         . reg_sel          (sw_wr_en_10     ),
         . reg_wr_data      (reg_wdata[15:0] ),
         . reg_wr           (wr_be[0]        ),  // Byte write not supported for cntr

         . cntr_intr        (                ),
         . cntrout          (reg_10[15:0]    )
   ); 

stat_counter #(16) u_stat_rx_bad_frm (
   // Clock and Reset Signals
         . sys_clk          (app_clk         ),
         . s_reset_n        (app_reset_n     ),
  
         . count_inc        (rx_bad_frm_trig ),
         . count_dec        (1'b0            ),
  
         . reg_sel          (sw_wr_en_10     ),
         . reg_wr_data      (reg_wdata[31:16] ),
         . reg_wr           (wr_be[0]        ),  // Byte write not supported for cntr

         . cntr_intr        (                ),
         . cntrout          (reg_10[31:16]    )
   ); 


 wire    tx_good_frm_trig = tx_sts_vld ;

stat_counter #(16) u_stat_tx_good_frm (
   // Clock and Reset Signals
         . sys_clk          (app_clk           ),
         . s_reset_n        (app_reset_n       ),
  
         . count_inc        (tx_good_frm_trig  ),
         . count_dec        (1'b0              ),
  
         . reg_sel          (sw_wr_en_11       ),
         . reg_wr_data      (reg_wdata[15:0]   ),
         . reg_wr           (wr_be[0]          ),  // Byte write not supported for cntr

         . cntr_intr        (                  ),
         . cntrout          (reg_11[15:0]      )
   );

assign reg_11[31:16] = 16'h0;
 
// reg_12 & reg_13 

stat_counter #(4) u_rx_qcnt (
   // Clock and Reset Signals
         . sys_clk          (app_clk           ),
         . s_reset_n        (app_reset_n       ),
  
         . count_inc        (rx_qcnt_inc       ),
         . count_dec        (rx_qcnt_dec       ),
  
         . reg_sel          (sw_wr_en_12       ),
         . reg_wr_data      (reg_wdata[3:0]    ),
         . reg_wr           (wr_be[0]          ),  // Byte write not supported for cntr

         . cntr_intr        (                  ),
         . cntrout          (rx_qcnt           )
   ); 

stat_counter #(4) u_tx_qcnt (
   // Clock and Reset Signals
         . sys_clk          (app_clk           ),
         . s_reset_n        (app_reset_n       ),
  
         . count_inc        (tx_qcnt_inc       ),
         . count_dec        (tx_qcnt_dec       ),
  
         . reg_sel          (sw_wr_en_12       ),
         . reg_wr_data      (reg_wdata[11:8]   ),
         . reg_wr           (wr_be[2]          ),  // Byte write not supported for cntr

         . cntr_intr        (                  ),
         . cntrout          (tx_qcnt           )
   ); 

assign reg_12[7:0]   = {4'h0,rx_qcnt[3:0]};
assign reg_12[15:8]  = {4'h0,tx_qcnt[3:0]};
assign reg_12[31:16] = {16'h0};

generic_intr_stat_reg	#(9) u_intr_stat (
		 //inputs
		 . clk              (app_clk                     ),
		 . reset_n          (app_reset_n                 ),
		 . reg_we           ({{1{sw_wr_en_13 & wr_be[1]}},
                                      {8{sw_wr_en_13 & wr_be[0]}}} ),		 
		 . reg_din          (reg_wdata[8:0]              ),
		 . hware_req        ({tx_sts,rx_sts[7:0]}        ),
		 
		 //outputs
		 . data_out         (reg_13[8:0]                 ) 
	      );

assign reg_13[31:9] = 23'h0;

// IP SA [31:0]

  generic_register #(8,0  ) u_ip_sa_0 (
	      .we            ({8{sw_wr_en_14 & wr_be[0] }}),		 
	      .data_in       (reg_wdata[7:0]    ),
	      .reset_n       (app_reset_n         ),
	      .clk           (app_clk             ),
	      
	      //List of Outs
	      .data_out      (cfg_ip_sa[7:0] )
          );

  generic_register #(8,0  ) u_ip_sa_1 (
	      .we            ({8{sw_wr_en_14 & wr_be[1] }}),		 
	      .data_in       (reg_wdata[15:8]    ),
	      .reset_n       (app_reset_n         ),
	      .clk           (app_clk             ),
	      
	      //List of Outs
	      .data_out      (cfg_ip_sa[15:8] )
          );


  generic_register #(8,0  ) u_ip_sa_2 (
	      .we            ({8{sw_wr_en_14 & wr_be[2] }}),		 
	      .data_in       (reg_wdata[23:16]    ),
	      .reset_n       (app_reset_n         ),
	      .clk           (app_clk             ),
	      
	      //List of Outs
	      .data_out      (cfg_ip_sa[23:16] )
          );

  generic_register #(8,0  ) u_ip_sa_3 (
	      .we            ({8{sw_wr_en_14 & wr_be[3] }}),		 
	      .data_in       (reg_wdata[31:24]    ),
	      .reset_n       (app_reset_n         ),
	      .clk           (app_clk             ),
	      
	      //List of Outs
	      .data_out      (cfg_ip_sa[31:24] )
          );

assign reg_14 = cfg_ip_sa[31:0];

// Mac filter

  generic_register #(8,0  ) u_mac_filter_0 (
	      .we            ({8{sw_wr_en_15 & wr_be[0] }}),		 
	      .data_in       (reg_wdata[7:0]    ),
	      .reset_n       (app_reset_n         ),
	      .clk           (app_clk             ),
	      
	      //List of Outs
	      .data_out      (cfg_mac_filter[7:0] )
          );

  generic_register #(8,0  ) u_mac_filter_1 (
	      .we            ({8{sw_wr_en_14 & wr_be[1] }}),		 
	      .data_in       (reg_wdata[15:8]    ),
	      .reset_n       (app_reset_n         ),
	      .clk           (app_clk             ),
	      
	      //List of Outs
	      .data_out      (cfg_mac_filter[15:8] )
          );


  generic_register #(8,0  ) u_mac_filter_2 (
	      .we            ({8{sw_wr_en_14 & wr_be[2] }}),		 
	      .data_in       (reg_wdata[23:16]    ),
	      .reset_n       (app_reset_n         ),
	      .clk           (app_clk             ),
	      
	      //List of Outs
	      .data_out      (cfg_mac_filter[23:16] )
          );

  generic_register #(8,0  ) u_mac_filter_3 (
	      .we            ({8{sw_wr_en_14 & wr_be[3] }}),		 
	      .data_in       (reg_wdata[31:24]    ),
	      .reset_n       (app_reset_n         ),
	      .clk           (app_clk             ),
	      
	      //List of Outs
	      .data_out      (cfg_mac_filter[31:24] )
          );

assign reg_15 = cfg_mac_filter[31:0];
endmodule 

