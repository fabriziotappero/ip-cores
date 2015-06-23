//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "mdio_serial_model.v"                             ////
////                                                              ////
////  This file is part of the :                                  ////
////                                                              ////
//// "1000BASE-X IEEE 802.3-2008 Clause 36 - PCS project"         ////
////                                                              ////
////  http://opencores.org/project,1000base-x                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - D.W.Pegler Cambridge Broadband Networks Ltd           ////
////                                                              ////
////      { peglerd@gmail.com, dwp@cambridgebroadand.com }        ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 AUTHORS. All rights reserved.             ////
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
////                                                              ////
//// Model of the  IEEE 802.3-2008 Clause 22 MDIO/MDC management  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////


`include "timescale_tb.v"

module mdio_serial_model #(
  parameter PHY_ADDR    = 5'b00000,
  parameter out_delay   = 5,
  parameter in_delay    = 2
)(
  interface cmd_intf,

  input  mdc,
  input  reset,
  inout  mdio
);

   reg [15:0] tmp_data;
   
   wire  tmp_mdio_data_in;
   reg 	 tmp_mdio_data_out;
   reg 	 tmp_mdio_n_oe;
   
   assign #out_delay mdio_n_oe = tmp_mdio_n_oe;
   
   assign #out_delay mdio = !mdio_n_oe ? tmp_mdio_data_out : 1'bz;
   
   assign #in_delay tmp_mdio_data_in = mdio;
   
   // Reset all registers
  always @ ( posedge mdc or posedge reset )
    begin
    if (reset)
      begin
	 tmp_data <= 16'h0000; tmp_mdio_n_oe <= 1'b0; tmp_mdio_data_out  <= 1'b0;
      end
    end


  //----------------------------------------------------------------------------
  // Write operation
  //----------------------------------------------------------------------------

  task automatic cmd_intf.write(input [4:0] regaddr, input [15:0] data);

     int i;
     
     $display("%m: %02h : %04h", regaddr, data);
     
     // PREAMBLE
     for (i=0; i < 32; i++) begin
	 @(posedge mdc); tmp_mdio_n_oe = 1'b0; tmp_mdio_data_out = 1'b1;
     end
     
     // ST
     for (i=0; i < 2; i++) begin
	 @(posedge mdc); tmp_mdio_n_oe = 1'b0; tmp_mdio_data_out = (i==0) ? 1'b0 : 1'b1;
     end;

     // OP - Write
      for (i=0; i < 2; i++) begin
	 @(posedge mdc); tmp_mdio_n_oe = 1'b0; tmp_mdio_data_out = (i==0) ? 1'b0 : 1'b1;
      end;
     
     // PHYADDR
     for (i=0; i < 5; i++) begin
     	 @(posedge mdc); tmp_mdio_n_oe = 1'b0; tmp_mdio_data_out = PHY_ADDR[4-i];
     end

     // REGADDR
     for (i=0; i < 5; i++) begin
     	 @(posedge mdc); tmp_mdio_n_oe = 1'b0; tmp_mdio_data_out = regaddr[4-i];
     end

     // TA
     for (i=0; i < 2; i++) begin
	 @(posedge mdc); tmp_mdio_n_oe = 1'b0; tmp_mdio_data_out = (i==0) ? 1'b1 : 1'b0;
     end
     
     // DATA
     for (i=0; i < 16; i++) begin
	 @(posedge mdc); tmp_mdio_n_oe = 1'b0; tmp_mdio_data_out = data[15-i];
     end

     // IDLE
     for (i=0; i < 2; i++) @(posedge mdc) tmp_mdio_n_oe = 1'b0;
     
  endtask

 //----------------------------------------------------------------------------
  // Write operation
  //----------------------------------------------------------------------------

  task automatic cmd_intf.read(input [4:0] regaddr, output [15:0] data);

     int i;
     
     tmp_data[15:0] = 16'h0000;

     // PREAMBLE
     for (i=0; i < 32; i++) begin
	 @(posedge mdc); tmp_mdio_n_oe = 1'b0; tmp_mdio_data_out = 1'b1;
     end
     
     // ST
     for (i=0; i < 2; i++) begin
	 @(posedge mdc); tmp_mdio_n_oe = 1'b0; tmp_mdio_data_out = (i==0) ? 1'b0 : 1'b1;
     end;
     
     // OP - Read
      for (i=0; i < 2; i++) begin
	 @(posedge mdc); tmp_mdio_n_oe = 1'b0; tmp_mdio_data_out = (i==0) ? 1'b1 : 1'b0;
      end;
     
     // PHYADDR
     for (i=0; i < 5; i++) begin
     	 @(posedge mdc); tmp_mdio_n_oe = 1'b0; tmp_mdio_data_out = PHY_ADDR[4-i];
     end

     // REGADDR
     for (i=0; i < 5; i++) begin
     	 @(posedge mdc); tmp_mdio_n_oe = 1'b0; tmp_mdio_data_out = regaddr[4-i];
     end

     // TA
      for (i=0; i < 2; i++) begin
	 @(posedge mdc); tmp_mdio_n_oe = 1'b1; 
      end
     
     @(posedge mdc); tmp_mdio_n_oe = 1'b1;
     
     // DATA
     for (i=0; i < 16; i++) begin
	
	@(posedge mdc); tmp_mdio_n_oe = 1'b1; data[15-i] = tmp_mdio_data_in;  tmp_data[15-i] = tmp_mdio_data_in;
	
     end

     // IDLE
     for (i=0; i < 2; i++) @(posedge mdc) tmp_mdio_n_oe = 1'b0;

     $display("%m: Read %04h & %04h from location %02h", tmp_data, data, regaddr);
     
     
  endtask

  function automatic string cmd_intf.whoami();
    string buffer;
    $sformat(buffer, "%m");
    return buffer.substr(0, buffer.len()-17);
  endfunction

endmodule
