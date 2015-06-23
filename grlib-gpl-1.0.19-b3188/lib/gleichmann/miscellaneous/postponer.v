//                              -*- Mode: Verilog -*-
// Filename        : postponer.v
// Description     : this module is for generating an adjustable delay for
//                   the AHB signals from the LEON processor
// Author          : Thomas Ameseder
// Created On      : Fri Mar 26 14:20:53 2004
//
// CVS entries:
//   $Author: tame $
//   $Date: 2006/08/14 15:25:09 $
//   $Revision: 1.1 $
//   $State: Exp $



`timescale 1ns / 10ps



module postponer (
   // Outputs
   hsel_d, hready_ba_d, hwrite_d, hmastlock_d, haddr_d, htrans_d, 
   hsize_d, hburst_d, hwdata_d, hmaster_d, 
   // Inputs
   hsel, hready_ba, hwrite, hmastlock, haddr, htrans, hsize, hburst, 
   hwdata, hmaster
   ) ;

   parameter HAMAX  = 32;
   parameter HDMAX  = 32;
   parameter delta  =  1;

   input     hsel, hready_ba, hwrite, hmastlock;
   input [HAMAX-1:0] haddr;
   input [1:0]       htrans;
   input [2:0]       hsize, hburst;
   input [HDMAX-1:0] hwdata;
   input [3:0]       hmaster;

   output            hsel_d, hready_ba_d, hwrite_d, hmastlock_d;
   output [HAMAX-1:0] haddr_d;
   output [1:0]       htrans_d;
   output [2:0]       hsize_d, hburst_d;
   output [HDMAX-1:0] hwdata_d;
   output [3:0]       hmaster_d;

   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg [HAMAX-1:0]      haddr_d;
   reg [2:0]            hburst_d;
   reg [3:0]            hmaster_d;
   reg                  hmastlock_d;
   reg                  hready_ba_d;
   reg                  hsel_d;
   reg [2:0]            hsize_d;
   reg [1:0]            htrans_d;
   reg [HDMAX-1:0]      hwdata_d;
   reg                  hwrite_d;
   // End of automatics

   always @ (/*AUTOSENSE*/haddr or hburst or hmaster or hmastlock
             or hready_ba or hsel or hsize or htrans or hwdata
             or hwrite)
     begin
        hsel_d <= #delta hsel;
        hready_ba_d <= #delta hready_ba;
        hwrite_d <= #delta hwrite;
        hmastlock_d <= #delta hmastlock;
        haddr_d <= #delta haddr;
        htrans_d <= #delta htrans;
        hsize_d <= #delta hsize;
        hburst_d <= #delta hburst;
        hwdata_d <= #delta hwdata;
        hmaster_d <= #delta hmaster;
     end
   
   

endmodule // postponer

