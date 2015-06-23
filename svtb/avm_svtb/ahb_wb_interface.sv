//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//*****************************************************************************************************************
// Copyright (c) 2007 TooMuch Semiconductor Solutions Pvt Ltd.
//
//File name		:	ahb_wb_interface.sv	
//Designer		: 	Sanjay kumar	
//Date			: 	3rd Aug'2007		
//Description		: 	ahb_wb_if: System verilog Interface with the AHB side master/slave,
//				Wishbone side master/slave and monitor.		
//Revision		:	1.0
//*****************************************************************************************************************
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// interface for the stimulus generator and DUT
import global::*;
`timescale 1 ns/1 ps
interface ahb_wb_if;
//master to bridge
          logic hclk; 
          logic hresetn; 
          logic [AWIDTH-1:0]haddr; 
          logic [DWIDTH-1:0]hwdata; 
          logic [1:0]htrans; 
          logic [2:0]hburst; 
          logic [2:0]hsize; 
          logic hwrite; 
          logic hsel; 
          logic hready; 
          logic [DWIDTH-1:0]hrdata; 
          logic [1:0]hresp;
//bridge to slave 
          logic clk_i; 
          logic rst_i; 
          logic cyc_o; 
          logic stb_o; 
          logic we_o;
          logic [DWIDTH-1:0]dat_o; 
          logic [AWIDTH-1:0]adr_o; 
          logic ack_i; 
          logic [DWIDTH-1:0]dat_i; 
modport master_ab ( output  hclk,
                    output  hresetn,
                    output  haddr, 
                    output  hwdata, 
                    output  htrans, 
                    output  hburst, 
                    output  hsize, 
                    output  hwrite, 
                    output  hsel, 
                    input   hready, 
                    input   hrdata, 
                    input   hresp 
                  );
modport slave_ab (  input   hclk, 
                    input   hresetn, 
                    input   haddr, 
                    input   hwdata, 
                    input   htrans, 
                    input   hburst, 
                    input   hsize, 
                    input   hwrite, 
                    input   hsel, 
                    output  hready, 
                    output  hrdata, 
                    output  hresp 
                  );
modport master_bw ( output  cyc_o, 
                    output  stb_o, 
                    output  we_o,
                    output  dat_o, 
                    output  adr_o, 
                    input   ack_i, 
                    input   dat_i, 
                    input   clk_i, 
                    input   rst_i 
                  );
modport slave_bw ( input  cyc_o, 
                   input  stb_o, 
                   input  we_o,
                   input  dat_o, 
                   input  adr_o, 
                   output ack_i, 
                   output dat_i,
                   output clk_i, 
                   output rst_i  
                );
modport monitor ( // signals from master to bridge 
                    input  hclk,
                    input  hresetn,
                    input  haddr, 
                    input  hwdata, 
                    input  htrans, 
                    input  hburst, 
                    input  hsize, 
                    input  hwrite, 
                    input  hsel, 
                    input  hready, 
                    input  hrdata, 
                    input  hresp,
                  // signals from bridge to slave 
                    input  cyc_o, 
                    input  stb_o, 
                    input  we_o,
                    input  dat_o, 
                    input  adr_o, 
                    input  ack_i, 
                    input  dat_i, 
                    input  clk_i, 
                    input  rst_i );
endinterface
