/**********************************************************************/
/*                                                                    */
/*             -------                                                */
/*            /   SOC  \                                              */
/*           /    GEN   \                                             */
/*          /  COMPONENT \                                            */
/*          ==============                                            */
/*          |            |                                            */
/*          |____________|                                            */
/*                                                                    */
/*  usb     io interface for Digilent FPGA boards                     */
/*                                                                    */
/*                                                                    */
/*  Author(s):                                                        */
/*      - John Eaton, jt_eaton@opencores.org                          */
/*                                                                    */
/**********************************************************************/
/*                                                                    */
/*    Copyright (C) <2010>  <Ouabache Design Works>                   */
/*                                                                    */
/*  This source file may be used and distributed without              */
/*  restriction provided that this copyright statement is not         */
/*  removed from the file and that any derivative work contains       */
/*  the original copyright notice and the associated disclaimer.      */
/*                                                                    */
/*  This source file is free software; you can redistribute it        */
/*  and/or modify it under the terms of the GNU Lesser General        */
/*  Public License as published by the Free Software Foundation;      */
/*  either version 2.1 of the License, or (at your option) any        */
/*  later version.                                                    */
/*                                                                    */
/*  This source is distributed in the hope that it will be            */
/*  useful, but WITHOUT ANY WARRANTY; without even the implied        */
/*  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR           */
/*  PURPOSE.  See the GNU Lesser General Public License for more      */
/*  details.                                                          */
/*                                                                    */
/*  You should have received a copy of the GNU Lesser General         */
/*  Public License along with this source; if not, download it        */
/*  from http://www.opencores.org/lgpl.shtml                          */
/*                                                                    */
/**********************************************************************/
 module 
  usb_epp_def 
     (
 input   wire                 clk,
 input   wire                 eppastb_in,
 input   wire                 eppdstb_in,
 input   wire                 eppwait_in,
 input   wire                 eppwr_in,
 input   wire                 reset,
 input   wire                 usbclk_in,
 input   wire                 usbdir_in,
 input   wire                 usbflag_in,
 input   wire                 usbmode_in,
 input   wire                 usboe_in,
 input   wire                 usbpktend_in,
 input   wire                 usbrdy_in,
 input   wire                 usbwr_in,
 input   wire    [ 1 :  0]        usbadr_in,
 input   wire    [ 7 :  0]        eppdb_in,
 output   wire                 eppdb_oe,
 output   wire                 eppwait_oe,
 output   wire                 eppwait_out,
 output   wire                 usbadr_oe,
 output   wire                 usbclk_oe,
 output   wire                 usbclk_out,
 output   wire                 usbdir_oe,
 output   wire                 usbdir_out,
 output   wire                 usbmode_oe,
 output   wire                 usbmode_out,
 output   wire                 usboe_oe,
 output   wire                 usboe_out,
 output   wire                 usbpktend_oe,
 output   wire                 usbpktend_out,
 output   wire                 usbwr_oe,
 output   wire                 usbwr_out,
 output   wire    [ 1 :  0]        usbadr_out,
 output   wire    [ 7 :  0]        eppdb_out);
assign        eppwait_out   =  1'b0;      
assign        eppwait_oe    =  1'b0;
assign        usbwr_out     =  1'b0;
assign        usbwr_oe      =  1'b0;
assign        usbmode_out   =  1'b0;
assign        usbmode_oe    =  1'b0;
assign        usboe_out     =  1'b0;
assign        usboe_oe      =  1'b0;
assign        usbadr_out    = 2'b00;
assign        usbadr_oe     =  1'b0;
assign        usbpktend_out =  1'b0;
assign        usbpktend_oe  =  1'b0;
assign        usbdir_out    =  1'b0;
assign        usbdir_oe     =  1'b0;
assign        eppdb_out     = 8'h00;
assign        eppdb_oe      =  1'b0;
assign        usbclk_out    =  1'b0;
assign        usbclk_oe     =  1'b0;
  endmodule
