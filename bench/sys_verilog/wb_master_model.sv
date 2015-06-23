////////////////////////////////////////////////////////////////////////////////
//
//  WISHBONE rev.B2 Wishbone Master model
//
//  Author: Bob Hayes
//          rehayes@opencores.org
//
//  Downloaded from: http://www.opencores.org/projects/pit.....
//
////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2011, Robert Hayes
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in the
//       documentation and/or other materials provided with the distribution.
//     * Neither the name of the <organization> nor the
//       names of its contributors may be used to endorse or promote products
//       derived from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY Robert Hayes ''AS IS'' AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL Robert Hayes BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
////////////////////////////////////////////////////////////////////////////////
// 45678901234567890123456789012345678901234567890123456789012345678901234567890

`include "timescale.v"

module wb_master_model  #(parameter dwidth = 32,
                          parameter awidth = 32)
(
  // Wishbone Signals
wishbone_if.master           wb_1,          // Define the interface instance name
wishbone_if.master           wb_2,          // Define the interface instance name
wishbone_if.master           wb_3,          // Define the interface instance name
wishbone_if.master           wb_4,          // Define the interface instance name
output logic                 cyc,
output logic                 stb,
output logic                 we,
output logic [dwidth/8 -1:0] sel,
output logic [awidth   -1:0] adr,
output logic [dwidth   -1:0] dout,
input  logic [dwidth   -1:0] din,
input  logic                 clk,
input  logic                 ack,
input  logic                 rst,  // No Connect
input  logic                 err,  // No Connect
input  logic                 rty   // No Connect
);

//////////////////////////////////
//
// Local Wires
//


logic [dwidth-1:0] q;

event cmp_error_detect;

assign wb_1.wb_adr = adr[2:0];
assign wb_1.wb_sel = 2'b11;
assign wb_1.wb_we  = we;
assign wb_1.wb_cyc = cyc;
assign wb_1.wb_dat = dout;

assign wb_2.wb_adr = adr[2:0];
assign wb_2.wb_sel = 2'b11;
assign wb_2.wb_we  = we;
assign wb_2.wb_cyc = cyc;
assign wb_2.wb_dat = dout;

assign wb_3.wb_adr = adr[2:0];
assign wb_3.wb_sel = 2'b11;
assign wb_3.wb_we  = we;
assign wb_3.wb_cyc = cyc;
assign wb_3.wb_dat = dout;

assign wb_4.wb_adr = adr[2:0];
assign wb_4.wb_sel = 2'b11;
assign wb_4.wb_we  = we;
assign wb_4.wb_cyc = cyc;
assign wb_4.wb_dat = dout[7:0];

//////////////////////////////////
//
// Memory Logic
//

initial
  begin
    adr  <= 'x;
    dout <= 'x;
    cyc  <= 1'b0;
    stb  <= 1'bx;
    we   <= 1'hx;
    sel  <= 'x;
    #1;
    $display("\nINFO: WISHBONE MASTER MODEL INSTANTIATED (%m)");
  end

//////////////////////////////////
//
// Wishbone write cycle
//

task wb_write(
  integer delay,
  logic   [awidth -1:0] a,
  logic   [dwidth -1:0] d);

  // wait initial delay
  repeat(delay) @(posedge clk);

  // assert wishbone signal
  #1;
  adr  = a;
  dout = d;
  cyc  = 1'b1;
  stb  = 1'b1;
  we   = 1'b1;
  sel  = '1;
  @(posedge clk);

  // wait for acknowledge from slave
  while(~ack)     @(posedge clk);

  // negate wishbone signals
  #1;
  cyc  = 1'b0;
  stb  = 1'bx;
  adr  = 'x;
  dout = 'x;
  we   = 1'hx;
  sel  = 'x;

endtask

//////////////////////////////////
//
// Wishbone read cycle
//

task wb_read(
  integer delay,
  logic         [awidth -1:0] a,
  output logic  [dwidth -1:0] d);

  // wait initial delay
  repeat(delay) @(posedge clk);

  // assert wishbone signals
  #1;
  adr  = a;
  dout = 'x;
  cyc  = 1'b1;
  stb  = 1'b1;
  we   = 1'b0;
  sel  = '1;
  @(posedge clk);

  // wait for acknowledge from slave
  while(~ack)     @(posedge clk);

  // negate wishbone signals
  d    = din; // Grab the data on the posedge of clock
  #1;         // Delay the clearing (hold time of the control signals
  cyc  = 1'b0;
  stb  = 1'bx;
  adr  = 'x;
  dout = 'x;
  we   = 1'hx;
  sel  = 'x;
  d    = din;

endtask

//////////////////////////////////
//
// Wishbone compare cycle (read data from location and compare with expected data)
//

task wb_cmp(
  integer delay,
  logic [awidth -1:0] a,
  logic [dwidth -1:0] d_exp);

  wb_read (delay, a, q);

  if (d_exp !== q)
    begin
      -> cmp_error_detect;
      $display("Data compare error at address %h. Received %h, expected %h at time %t", a, q, d_exp, $time);
    end
endtask

endmodule : wb_master_model


