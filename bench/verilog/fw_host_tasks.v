// $Id: fw_host_tasks.v,v 1.1 2002-03-10 17:18:07 johnsonw10 Exp $
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// FIREWIRE IP Core                                             ////
////                                                              ////
//// This file is part of the firewire project                    ////
//// http://www.opencores.org/cores/firewire/                     ////
////                                                              ////
//// Description                                                  ////
//// Implementation of firewire IP core according to              ////
//// firewire IP core specification document.                     ////
////                                                              ////
//// To Do:                                                       ////
//// -                                                            ////
////                                                              ////
//// Author(s):                                                   ////
//// - johnsonw10@opencores.org                                   ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2001 Authors and OPENCORES.ORG                 ////
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
//// PURPOSE. See the GNU Lesser General Public License for more  ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
//
//

task host_write_reg;
input [7:0] addr;
input [31:0] data;


begin
    @ (posedge sclk);
    host_cs_n <= 0;
    host_wr_n <= 0;
    host_addr <= addr;
    host_data_out <= data;

    @ (posedge sclk);
    host_cs_n <= 1;
    host_wr_n <= 1;
    host_data_out <= 32'hzzzz_zzzz;
end
endtask // host_write_reg

task host_write_atxf;
input data_num;
integer data_num;

reg [0:31] temp;
integer i;

begin
    i = 0;
    while (i < data_num) begin
	temp <= send_buf[i];
	@ (posedge sclk);
	if (!atxf_ff) begin
	    atxf_wr <= 1;
	    atxf_din <= temp;
	    i = i + 1;  // have to use blocking assignment
	end
    end

    @ (posedge sclk);
    atxf_wr <= 0;
end

endtask // host_write_atxf