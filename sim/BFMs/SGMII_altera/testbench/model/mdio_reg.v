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
// MDIO Slave's Register Map
// Instantiated in top_mdio_slave (top_mdio_slave.v)
// 
// ALTERA Confidential and Proprietary
// Copyright 2006 (c) Altera Corporation
// All rights reserved
//
// -------------------------------------------------------------------------
// -------------------------------------------------------------------------

`timescale 1 ns / 10 ps
//`include "common_header.verilog" 

module mdio_reg_sim (reset,
   clk,
   reg_addr,
   reg_write,
   reg_read,
   reg_dout,
   reg_din,
   conf_done);
input   reset; 
input   clk; //  MDIO 2.5MHz Clock
input   [4:0] reg_addr; //  Address Register
input   reg_write; //  Write Register       
input   reg_read; //  Read Register         
output   [15:0] reg_dout; //  Data Bus OUT
input   [15:0] reg_din; //  Data Bus IN
output   conf_done; //  PHY Config Done
reg     [15:0] reg_dout; 
//  Status
//  ------
reg     conf_done; 
reg     [15:0] reg_0; 
reg     [15:0] reg_1; 
reg     [15:0] reg_2; 
reg     [15:0] reg_3; 
reg     [15:0] reg_4; 
reg     [15:0] reg_5; 
reg     [15:0] reg_6; 
reg     [15:0] reg_7; 
reg     [15:0] reg_8; 
reg     [15:0] reg_9; 
reg     [15:0] reg_10; 
reg     [15:0] reg_11; 
reg     [15:0] reg_12; 
reg     [15:0] reg_13; 
reg     [15:0] reg_14; 
reg     [15:0] reg_15; 
reg     [15:0] reg_16; 
reg     [15:0] reg_17; 
reg     [15:0] reg_18; 
reg     [15:0] reg_19; 
reg     [15:0] reg_20; 
reg     [15:0] reg_21; 
reg     [15:0] reg_22; 
reg     [15:0] reg_23; 
reg     [15:0] reg_24; 
reg     [15:0] reg_25; 
reg     [15:0] reg_26; 
reg     [15:0] reg_27; 
reg     [15:0] reg_28; 
reg     [15:0] reg_29; 
reg     [15:0] reg_30; 
reg     [15:0] reg_31; 
//  MDIO Registers
//  --------------

always @(posedge reset or posedge clk)
   begin : process_1
   if (reset == 1'b 1)
      begin
      reg_0 <= {16{1'b 0}}; 
      reg_1 <= {16{1'b 0}}; 
      reg_2 <= {16{1'b 0}}; 
      reg_3 <= {16{1'b 0}}; 
      reg_4 <= {16{1'b 0}}; 
      reg_5 <= {16{1'b 0}}; 
      reg_6 <= {16{1'b 0}}; 
      reg_7 <= {16{1'b 0}}; 
      reg_8 <= {16{1'b 0}}; 
      reg_9 <= {16{1'b 0}}; 
      reg_10 <= {16{1'b 0}};    
      reg_11 <= {16{1'b 0}};    
      reg_12 <= {16{1'b 0}};    
      reg_13 <= {16{1'b 0}};    
      reg_14 <= {16{1'b 0}};    
      reg_15 <= {16{1'b 0}};    
      reg_16 <= {16{1'b 0}};    
      reg_17 <= {16{1'b 0}};    
      reg_18 <= {16{1'b 0}};    
      reg_19 <= {16{1'b 0}};    
      reg_20 <= {16{1'b 0}};    
      reg_21 <= {16{1'b 0}};    
      reg_22 <= {16{1'b 0}};    
      reg_23 <= {16{1'b 0}};    
      reg_24 <= {16{1'b 0}};    
      reg_25 <= {16{1'b 0}};    
      reg_26 <= {16{1'b 0}};    
      reg_27 <= {16{1'b 0}};    
      reg_28 <= {16{1'b 0}};    
      reg_29 <= {16{1'b 0}};    
      reg_30 <= {16{1'b 0}};    
      reg_31 <= {16{1'b 0}};    
      conf_done <= 1'b 0;   
      end
   else
      begin
      if (reg_write == 1'b 1)
         begin
         if (reg_addr == 5'b 00000)
            begin
            reg_0 <= reg_din;   
            conf_done <= 1'b 1; 
            end
         else if (reg_addr == 5'b 00001 )
            begin
            reg_1 <= reg_din;   
            end
         else if (reg_addr == 5'b 00010 )
            begin
            reg_2 <= reg_din;   
            end
         else if (reg_addr == 5'b 00011 )
            begin
            reg_3 <= reg_din;   
            end
         else if (reg_addr == 5'b 00100 )
            begin
            reg_4 <= reg_din;   
            end
         else if (reg_addr == 5'b 00101 )
            begin
            reg_5 <= reg_din;   
            end
         else if (reg_addr == 5'b 00110 )
            begin
            reg_6 <= reg_din;   
            end
         else if (reg_addr == 5'b 00111 )
            begin
            reg_7 <= reg_din;   
            end
         else if (reg_addr == 5'b 01000 )
            begin
            reg_8 <= reg_din;   
            end
         else if (reg_addr == 5'b 01001 )
            begin
            reg_9 <= reg_din;   
            end
         else if (reg_addr == 5'b 01010 )
            begin
            reg_10 <= reg_din;  
            end
         else if (reg_addr == 5'b 01011 )
            begin
            reg_11 <= reg_din;  
            end
         else if (reg_addr == 5'b 01100 )
            begin
            reg_12 <= reg_din;  
            end
         else if (reg_addr == 5'b 01101 )
            begin
            reg_13 <= reg_din;  
            end
         else if (reg_addr == 5'b 01110 )
            begin
            reg_14 <= reg_din;  
            end
         else if (reg_addr == 5'b 01111 )
            begin
            reg_15 <= reg_din;  
            end
         else if (reg_addr == 5'b 10000 )
            begin
            reg_16 <= reg_din;  
            end
         else if (reg_addr == 5'b 10001 )
            begin
            reg_17 <= reg_din;  
            end
         else if (reg_addr == 5'b 10010 )
            begin
            reg_18 <= reg_din;  
            end
         else if (reg_addr == 5'b 10011 )
            begin
            reg_19 <= reg_din;  
            end
         else if (reg_addr == 5'b 10100 )
            begin
            reg_20 <= reg_din;  
            end
         else if (reg_addr == 5'b 10101 )
            begin
            reg_21 <= reg_din;  
            end
         else if (reg_addr == 5'b 10110 )
            begin
            reg_22 <= reg_din;  
            end
         else if (reg_addr == 5'b 10111 )
            begin
            reg_23 <= reg_din;  
            end
         else if (reg_addr == 5'b 11000 )
            begin
            reg_24 <= reg_din;  
            end
         else if (reg_addr == 5'b 11001 )
            begin
            reg_25 <= reg_din;  
            end
         else if (reg_addr == 5'b 11010 )
            begin
            reg_26 <= reg_din;  
            end
         else if (reg_addr == 5'b 11011 )
            begin
            reg_27 <= reg_din;  
            end
         else if (reg_addr == 5'b 11100 )
            begin
            reg_28 <= reg_din;  
            end
         else if (reg_addr == 5'b 11101 )
            begin
            reg_29 <= reg_din;  
            end
         else if (reg_addr == 5'b 11110 )
            begin
            reg_30 <= reg_din;  
            end
         else if (reg_addr == 5'b 11111 )
            begin
            reg_31 <= reg_din;  
            end
         end
      end
   end
//  Data MUX
//  --------
always @(reg_addr or reg_write)
   begin : process_2
   if (reg_addr == 5'b 00000)
      begin
      reg_dout <= reg_0;    
      end
   else if (reg_addr == 5'b 00001 )
      begin
      reg_dout <= reg_1;    
      end
   else if (reg_addr == 5'b 00010 )
      begin
      reg_dout <= reg_2;    
      end
   else if (reg_addr == 5'b 00011 )
      begin
      reg_dout <= reg_3;    
      end
   else if (reg_addr == 5'b 00100 )
      begin
      reg_dout <= reg_4;    
      end
   else if (reg_addr == 5'b 00101 )
      begin
      reg_dout <= reg_5;    
      end
   else if (reg_addr == 5'b 00110 )
      begin
      reg_dout <= reg_6;    
      end
   else if (reg_addr == 5'b 00111 )
      begin
      reg_dout <= reg_7;    
      end
   else if (reg_addr == 5'b 01000 )
      begin
      reg_dout <= reg_8;    
      end
   else if (reg_addr == 5'b 01001 )
      begin
      reg_dout <= reg_9;    
      end
   else if (reg_addr == 5'b 01010 )
      begin
      reg_dout <= reg_10;   
      end
   else if (reg_addr == 5'b 01011 )
      begin
      reg_dout <= reg_11;   
      end
   else if (reg_addr == 5'b 01100 )
      begin
      reg_dout <= reg_12;   
      end
   else if (reg_addr == 5'b 01101 )
      begin
      reg_dout <= reg_13;   
      end
   else if (reg_addr == 5'b 01110 )
      begin
      reg_dout <= reg_14;   
      end
   else if (reg_addr == 5'b 01111 )
      begin
      reg_dout <= reg_15;   
      end
   else if (reg_addr == 5'b 10000 )
      begin
      reg_dout <= reg_16;   
      end
   else if (reg_addr == 5'b 10001 )
      begin
      reg_dout <= reg_17;   
      end
   else if (reg_addr == 5'b 10010 )
      begin
      reg_dout <= reg_18;   
      end
   else if (reg_addr == 5'b 10011 )
      begin
      reg_dout <= reg_19;   
      end
   else if (reg_addr == 5'b 10100 )
      begin
      reg_dout <= reg_20;   
      end
   else if (reg_addr == 5'b 10101 )
      begin
      reg_dout <= reg_21;   
      end
   else if (reg_addr == 5'b 10110 )
      begin
      reg_dout <= reg_22;   
      end
   else if (reg_addr == 5'b 10111 )
      begin
      reg_dout <= reg_23;   
      end
   else if (reg_addr == 5'b 11000 )
      begin
      reg_dout <= reg_24;   
      end
   else if (reg_addr == 5'b 11001 )
      begin
      reg_dout <= reg_25;   
      end
   else if (reg_addr == 5'b 11010 )
      begin
      reg_dout <= reg_26;   
      end
   else if (reg_addr == 5'b 11011 )
      begin
      reg_dout <= reg_27;   
      end
   else if (reg_addr == 5'b 11100 )
      begin
      reg_dout <= reg_28;   
      end
   else if (reg_addr == 5'b 11101 )
      begin
      reg_dout <= reg_29;   
      end
   else if (reg_addr == 5'b 11110 )
      begin
      reg_dout <= reg_30;   
      end
   else if (reg_addr == 5'b 11111 )
      begin
      reg_dout <= reg_31;   
      end
   end


endmodule // module mdio_reg_sim

