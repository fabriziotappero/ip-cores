/*
ORSoC GFX accelerator core
Copyright 2012, ORSoC, Per Lenander, Anton Fosselius.

WBM reader

Loosely based on the vga lcds wishbone reader (LGPL) in orpsocv2 by Julius Baxter, julius@opencores.org

 This file is part of orgfx.

 orgfx is free software: you can redistribute it and/or modify
 it under the terms of the GNU Lesser General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version. 

 orgfx is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Lesser General Public License for more details.

 You should have received a copy of the GNU Lesser General Public License
 along with orgfx.  If not, see <http://www.gnu.org/licenses/>.

*/

//synopsys translate_off
`include "timescale.v"
//synopsys translate_on

module gfx_wbm_read (clk_i, rst_i,
  cyc_o, stb_o, cti_o, bte_o, we_o, adr_o, sel_o, ack_i, err_i, dat_i, sint_o,
  read_request_i,
  texture_addr_i, texture_sel_i, texture_dat_o, texture_data_ack);

  // inputs & outputs

  // wishbone signals
  input             clk_i;    // master clock input
  input             rst_i;    // asynchronous active high reset
  output reg        cyc_o;    // cycle output
  output            stb_o;    // strobe ouput
  output [ 2:0]     cti_o;    // cycle type id
  output [ 1:0]     bte_o;    // burst type extension
  output            we_o;     // write enable output
  output [31:0]     adr_o;    // address output
  output reg [ 3:0] sel_o;    // byte select outputs (only 32bits accesses are supported)
  input             ack_i;    // wishbone cycle acknowledge
  input             err_i;    // wishbone cycle error
  input [31:0]      dat_i;    // wishbone data in

  output        sint_o;     // non recoverable error, interrupt host

  // Request stuff
  input         read_request_i;

  input [31:2]  texture_addr_i;
  input [3:0]   texture_sel_i;
  output [31:0] texture_dat_o;
  output reg    texture_data_ack;

  //
  // variable declarations
  //
  reg busy;

  //
  // module body
  //

  assign adr_o  = {texture_addr_i, 2'b00};
  assign texture_dat_o = dat_i;
  // This interface is read only
  assign we_o   = 1'b0;
  assign stb_o  = 1'b1;
  assign sint_o = err_i;
  assign bte_o  = 2'b00;
  assign cti_o  = 3'b000;

  always @(posedge clk_i or posedge rst_i)
  if (rst_i) // Reset
    begin
      texture_data_ack <= 1'b0;
      cyc_o <= 1'b0;
      sel_o <= 4'b1111;
      busy  <= 1'b0;
    end
  else
  begin
    sel_o <= texture_sel_i;
	
    if(ack_i) // On ack, stop current read, send ack to arbiter
    begin
      cyc_o            <= 1'b0;
      texture_data_ack <= 1'b1;
      busy             <= 1'b0;
    end
    else if(read_request_i & !texture_data_ack) // Else, is there a pending request? Start a read
    begin
      cyc_o            <= 1'b1;
      texture_data_ack <= 1'b0;
      busy             <= 1'b1;
    end
    else if(!busy) // Else, are we done? Zero ack
      texture_data_ack <= 1'b0;
  end

endmodule
