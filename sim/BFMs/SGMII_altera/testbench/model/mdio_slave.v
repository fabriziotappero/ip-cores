// -------------------------------------------------------------------------
// -------------------------------------------------------------------------
//
// Revision Control Information
//
// $RCSfile: $
// $Source: $
//
// $Revision: #1 $
// $Date: 2012/06/21 $
// Check in by : $Author: swbranch $
// Author      : SKNg/TTChong
//
// Project     : Triple Speed Ethernet - 10/100/1000 MAC
//
// Description : (Simulation only)
//
// MDIO slave's register interface controller 
// Instantiated in top_mdio_slave (top_mdio_slave.v)
//
// 
// ALTERA Confidential and Proprietary
// Copyright 2006 (c) Altera Corporation
// All rights reserved
//
// -------------------------------------------------------------------------
// -------------------------------------------------------------------------

`timescale 1 ns / 10 ps
//`include "common_header.verilog" 

module mdio_slave (reset,
   mdc,
   mdio,
   dev_addr,
   reg_addr,
   reg_read,
   reg_write,
   reg_dout,
   reg_din);
input   reset; //  asynch reset
input   mdc; //  system clock
inout   mdio; //  Data Bus
input   [4:0] dev_addr; //  Device address
output   [4:0] reg_addr; //  Address register
output   reg_read; //  Read register         
output   reg_write; //  Write register         
output   [15:0] reg_dout; //  Data Bus OUT
input   [15:0] reg_din; //  Data Bus IN
wire    VHDL2V_mdio; 
wire    mdio; 
wire    [4:0] reg_addr; 
wire    reg_read; 
wire    reg_write; 
wire    [15:0] reg_dout; 
reg     [4:0] phy_add; //  Phy Address
reg     [4:0] reg_add; //  Register Address
reg     [15:0] reg_out; //  Register data out
reg     [15:0] reg_in; //  Register data in
reg     en_phy_add; //  Write phy Address
reg     en_reg_add; //  Write register Address
reg     en_data_out; //  Write register data out
wire    en_data_in; //  Write register data in
wire    shift_data_in; //  Send register data in
wire    phy_add_ok; //  Phy Address correct
reg     [4:0] cnt_32; //  Frame Bit counter
wire    run_cnt_32; //  Run Frame Bit counter
wire    ok_32; //  Preambule length reached
wire    ok_16; //  Data length reached
wire    ok_10; //  Reg address length reach
wire    ok_5; //  Phy address length reach
reg     cd_oe; //  Output Enable command
wire    mux_0; //  Mux zero
reg     mdio_wait; //  Wait state of State machine
reg     [16:0] mdio_run; //  State machine core
// =====================================================================
//  Data logic structure  
// =====================================================================

always @(posedge mdc or posedge reset)
   begin : p_data
   if (reset == 1'b 1)
      begin
      phy_add <= {5{1'b 0}};    //  Phy Address
      reg_add <= {5{1'b 0}};    //  Register Address
      reg_out <= {16{1'b 0}};   //  Register data out
      reg_in <= {16{1'b 0}};    //  Register data in
// 
      cnt_32 <= {5{1'b 0}}; //  Frame Bit counter
// 
      end
   else
      begin
// ----------------------
//  Phy Address
// ----------------------
      if (en_phy_add == 1'b 1)
         begin
         phy_add[4:0] <= {phy_add[3:0], mdio};  
         end
      else
         begin
         phy_add <= phy_add;    
         end
// ----------------------
// -----------------------
//  Register Address 
// -----------------------  
      if (en_reg_add == 1'b 1)
         begin
         reg_add[4:0] <= {reg_add[3:0], mdio};  
         end
      else
         begin
         reg_add <= reg_add;    
         end
// -----------------------
// -----------------------
//  Register data out 
// -----------------------  
      if (en_data_out == 1'b 1)
         begin
         reg_out[15:0] <= {reg_out[14:0], mdio};    
         end
      else
         begin
         reg_out <= reg_out;    
         end
// -----------------------
// -----------------------------------------
//  Register data in
// -----------------------------------------
      if (en_data_in == 1'b 1)
         begin
         reg_in[15:0] <= reg_din;   
         end
      else if (shift_data_in == 1'b 1 )
         begin
         reg_in[15:1] <= reg_in[14:0];  
         end
      else
         begin
         reg_in <= reg_in;  
         end
//     
// ------------------------------------------
// --------------------
//  Frame Bit counter
// -------------------
      if (run_cnt_32 == 1'b 1)
         begin
         cnt_32 <= cnt_32 + 1'b 1;  
         end
      else
         begin
         cnt_32 <= 5'b 00000;   
         end
// -------------------
      end
   end
// 
// --------------------------
//  Phy Address correct
// --------------------------
assign phy_add_ok = phy_add == dev_addr ? 1'b 1 : 
    1'b 0; 
// 
// ---------------------------
//  Preambule length reached
// ---------------------------
assign ok_32 = cnt_32 == 5'b 11110 ? 1'b 1 : 
    1'b 0; 
//   
// --------------------------
//  Data length reached
// --------------------------
assign ok_16 = cnt_32 == 5'b 01111 ? 1'b 1 : 
    1'b 0; 
//  
// --------------------------
//  Reg address length reach
// --------------------------
assign ok_10 = cnt_32 == 5'b 01010 ? 1'b 1 : 
    1'b 0; 
//   
// --------------------------
//  Phy address length reach
// --------------------------
assign ok_5 = cnt_32 == 5'b 00101 ? 1'b 1 : 
    1'b 0; 
//                       
// ----------------------
//  -- Address register
// ----------------------
assign reg_addr = reg_add; 
// 
// ----------------------
//  Data Bus OUT
// ----------------------
assign reg_dout = reg_out; 
// 
// ----------------------
//  Mux zero
// ----------------------
assign mux_0 = mdio_run[8] == 1'b 1 ? 1'b 0 : 
    reg_in[15]; 
// 
// ----------------------
//  Data Bus
// ----------------------
assign #(5) mdio = cd_oe == 1'b 0 ? mux_0 : 
    1'b Z; 
//         
// =====================================================================
// =====================================================================
//  State machine body  
// =====================================================================
always @(posedge mdc or posedge reset)
   begin : p_state
   if (reset == 1'b 1)
      begin
      mdio_wait <= 1'b 1;   //  Wait state of State machine
      mdio_run <= {17{1'b 0}};  //  State machine core
// 
      cd_oe <= 1'b 1;   //  Output Enable command
// 
      en_phy_add <= 1'b 0;  //  Write phy Address
      en_reg_add <= 1'b 0;  //  Write register Address
      en_data_out <= 1'b 0; //  Write register data out
// 
//  
      end
   else
      begin
// --------------------------------------
//  wait for a frame
// --------------------------------------
      if (mdio_wait == 1'b 1 & mdio == 1'b 0 | 
    mdio_run[0] == 1'b 1 & mdio == 1'b 0 | 
    mdio_run[2] == 1'b 1 & mdio == 1'b 0 | 
    mdio_run[4] == 1'b 1 & mdio == 1'b 1 | 
    mdio_run[6] == 1'b 1 & phy_add_ok == 1'b 0 | 
    mdio_run[7] == 1'b 1 & mdio == 1'b 0 | 
    mdio_run[9] == 1'b 1 & ok_16 == 1'b 1 | 
    mdio_run[10] == 1'b 1 & mdio == 1'b 0 | 
    mdio_run[12] == 1'b 1 & phy_add_ok == 1'b 0 | 
    mdio_run[13] == 1'b 1 & mdio == 1'b 0 | 
    mdio_run[14] == 1'b 1 & mdio == 1'b 1 | 
    mdio_run[16] == 1'b 1 | mdio_run[0] == 1'b 0 & 
    mdio_run[1] == 1'b 0 & mdio_run[2] == 1'b 0 & 
    mdio_run[3] == 1'b 0 & mdio_run[4] == 1'b 0 & 
    mdio_run[5] == 1'b 0 & mdio_run[6] == 1'b 0 & 
    mdio_run[7] == 1'b 0 & mdio_run[8] == 1'b 0 & 
    mdio_run[9] == 1'b 0 & mdio_run[10] == 1'b 0 & 
    mdio_run[11] == 1'b 0 & mdio_run[12] == 1'b 0 & 
    mdio_run[13] == 1'b 0 & mdio_run[14] == 1'b 0 & 
    mdio_run[15] == 1'b 0 & mdio_run[16] == 1'b 0)
         begin
         mdio_wait <= 1'b 1;    
         end
      else
         begin
         mdio_wait <= 1'b 0;    
         end
// 
// --------------------------------------------
//  Check preambule
// --------------------------------------------
      if (mdio_wait == 1'b 1 & mdio == 1'b 1 | 
    mdio_run[0] == 1'b 1 & mdio == 1'b 1 & 
    ok_32 == 1'b 0)
         begin
         mdio_run[0] <= 1'b 1;  
         end
      else
         begin
         mdio_run[0] <= 1'b 0;  
         end
// 
      if (mdio_run[0] == 1'b 1 & mdio == 1'b 1 & 
    ok_32 == 1'b 1 | mdio_run[1] == 1'b 1 & 
    mdio == 1'b 1)
         begin
         mdio_run[1] <= 1'b 1;  
         end
      else
         begin
         mdio_run[1] <= 1'b 0;  
         end
// --------------------------------------------
//  Check ST
// --------------------------------------------
      if (mdio_run[1] == 1'b 1 & mdio == 1'b 0)
         begin
         mdio_run[2] <= 1'b 1;  
         end
      else
         begin
         mdio_run[2] <= 1'b 0;  
         end
//    
      if (mdio_run[2] == 1'b 1 & mdio == 1'b 1)
         begin
         mdio_run[3] <= 1'b 1;  
         end
      else
         begin
         mdio_run[3] <= 1'b 0;  
         end
// --------------------------------------------
//  Check OP
// --------------------------------------------      
      if (mdio_run[3] == 1'b 1 & mdio == 1'b 1)
         begin
         mdio_run[4] <= 1'b 1;  
         end
      else
         begin
         mdio_run[4] <= 1'b 0;  
         end
// --------------------------------------------
//  Read OP
// --------------------------------------------              
      if (mdio_run[4] == 1'b 1 & mdio == 1'b 0 | 
    mdio_run[5] == 1'b 1 & ok_5 == 1'b 0)
         begin
         mdio_run[5] <= 1'b 1;  
         end
      else
         begin
         mdio_run[5] <= 1'b 0;  
         end
//  
      if (mdio_run[5] == 1'b 1 & ok_5 == 1'b 1 | 
    mdio_run[6] == 1'b 1 & ok_10 == 1'b 0 & 
    phy_add_ok == 1'b 1)
         begin
         mdio_run[6] <= 1'b 1;  
         end
      else
         begin
         mdio_run[6] <= 1'b 0;  
         end
// 
      if (mdio_run[6] == 1'b 1 & ok_10 == 1'b 1 & 
    phy_add_ok == 1'b 1)
         begin
         mdio_run[7] <= 1'b 1;  
         end
      else
         begin
         mdio_run[7] <= 1'b 0;  
         end
// 
      if (mdio_run[7] == 1'b 1 & mdio != 1'b 0)
         begin
         mdio_run[8] <= 1'b 1;  
         end
      else
         begin
         mdio_run[8] <= 1'b 0;  
         end
// 
      if (mdio_run[8] == 1'b 1 | mdio_run[9] == 1'b 1 & 
    ok_16 == 1'b 0)
         begin
         mdio_run[9] <= 1'b 1;  
         end
      else
         begin
         mdio_run[9] <= 1'b 0;  
         end
// 
// --------------------------------------------
//  Write OP
// --------------------------------------------                   
      if (mdio_run[3] == 1'b 1 & mdio == 1'b 0)
         begin
         mdio_run[10] <= 1'b 1; 
         end
      else
         begin
         mdio_run[10] <= 1'b 0; 
         end
//  
      if (mdio_run[10] == 1'b 1 & mdio == 1'b 1 | 
    mdio_run[11] == 1'b 1 & ok_5 == 1'b 0)
         begin
         mdio_run[11] <= 1'b 1; 
         end
      else
         begin
         mdio_run[11] <= 1'b 0; 
         end
//  
      if (mdio_run[11] == 1'b 1 & ok_5 == 1'b 1 | 
    mdio_run[12] == 1'b 1 & ok_10 == 1'b 0 & 
    phy_add_ok == 1'b 1)
         begin
         mdio_run[12] <= 1'b 1; 
         end
      else
         begin
         mdio_run[12] <= 1'b 0; 
         end
// 
      if (mdio_run[12] == 1'b 1 & ok_10 == 1'b 1 & 
    phy_add_ok == 1'b 1)
         begin
         mdio_run[13] <= 1'b 1; 
         end
      else
         begin
         mdio_run[13] <= 1'b 0; 
         end
// 
      if (mdio_run[13] == 1'b 1 & mdio == 1'b 1)
         begin
         mdio_run[14] <= 1'b 1; 
         end
      else
         begin
         mdio_run[14] <= 1'b 0; 
         end
//  
      if (mdio_run[14] == 1'b 1 & mdio == 1'b 0 | 
    mdio_run[15] == 1'b 1 & ok_16 == 1'b 0)
         begin
         mdio_run[15] <= 1'b 1; 
         end
      else
         begin
         mdio_run[15] <= 1'b 0; 
         end
// 
      if (mdio_run[15] == 1'b 1 & ok_16 == 1'b 1)
         begin
         mdio_run[16] <= 1'b 1; 
         end
      else
         begin
         mdio_run[16] <= 1'b 0; 
         end
// 
// ----------------------------    
// --------------------
//  Write phy Address    
// --------------------          
      if (mdio_run[4] == 1'b 1 & mdio == 1'b 0 | 
    mdio_run[5] == 1'b 1 & ok_5 == 1'b 0 | 
    mdio_run[10] == 1'b 1 & mdio == 1'b 1 | 
    mdio_run[11] == 1'b 1 & ok_5 == 1'b 0)
         begin
         en_phy_add <= 1'b 1;   
         end
      else
         begin
         en_phy_add <= 1'b 0;   
         end
//             
// -------------------
// --------------------------           
//  Write register Address
// --------------------------
      if (mdio_run[5] == 1'b 1 & ok_5 == 1'b 1 | 
    mdio_run[6] == 1'b 1 & ok_10 == 1'b 0 | 
    mdio_run[11] == 1'b 1 & ok_5 == 1'b 1 | 
    mdio_run[12] == 1'b 1 & ok_10 == 1'b 0)
         begin
         en_reg_add <= 1'b 1;   
         end
      else
         begin
         en_reg_add <= 1'b 0;   
         end
// ---------------------------
// --------------------------           
//  Write register data out
// --------------------------
      if (mdio_run[14] == 1'b 1 & mdio == 1'b 0 | 
    mdio_run[15] == 1'b 1 & ok_16 == 1'b 0)
         begin
         en_data_out <= 1'b 1;  
         end
      else
         begin
         en_data_out <= 1'b 0;  
         end
// ---------------------------
// --------------------------           
//  Output Enable command
// --------------------------
      if (mdio_run[7] == 1'b 1 & mdio != 1'b 0 | 
    mdio_run[8] == 1'b 1 | mdio_run[9] == 1'b 1 & 
    ok_16 == 1'b 0)
         begin
         cd_oe <= 1'b 0;    
         end
      else
         begin
         cd_oe <= 1'b 1;    
         end
// ---------------------------
      end
   end
// 
// -------------------------
//  Write register data in
// -------------------------
assign en_data_in = mdio_run[8]; 
// 
// -------------------------
//  Send register data in   
// -------------------------          
assign shift_data_in = mdio_run[9]; 
//     
// -------------------------          
//  Read register 
// -------------------------          
assign reg_read = mdio_run[7] == 1'b 1 & mdio != 1'b 0 | 
    mdio_run[8] == 1'b 1 ? 1'b 1 : 
    1'b 0; 
//                              
// -------------------------  
//  Write register
// -------------------------
assign reg_write = mdio_run[16]; 
//       
// --------------------------------
//  Run Frame Bit counter
// ---------------------------------
assign run_cnt_32 = mdio_wait == 1'b 1 & mdio == 1'b 1 | 
    mdio_run[0] == 1'b 1 & mdio == 1'b 1 & 
    ok_32 == 1'b 0 | mdio_run[4] == 1'b 1 & 
    mdio == 1'b 0 | mdio_run[5] == 1'b 1 & 
    ok_5 == 1'b 0 | mdio_run[5] == 1'b 1 & 
    ok_5 == 1'b 1 | mdio_run[6] == 1'b 1 & 
    ok_10 == 1'b 0 | mdio_run[9] == 1'b 1 | 
    mdio_run[10] == 1'b 1 & mdio == 1'b 1 | 
    mdio_run[11] == 1'b 1 & ok_5 == 1'b 0 | 
    mdio_run[11] == 1'b 1 & ok_5 == 1'b 1 | 
    mdio_run[12] == 1'b 1 & ok_10 == 1'b 0 | 
    mdio_run[15] == 1'b 1 & ok_16 == 1'b 0 ? 1'b 1 : 
    1'b 0; 
// ---------------------------------
// 
// =====================================================================

endmodule // module mdio_slave

