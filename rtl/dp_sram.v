/*
  Josh Smith
 
  File: dp_sram.v
  Description: Module for SRAM slice.  This is written
  as a generic dual-port SRAM, so should be inferred as SRAM by
  tool.
*/

`include "ooops_defs.v"

module dp_sram
  #(parameter DW      = `DATA_SZ,
    parameter IW      = `TAG_SZ,
    parameter ENTRIES = (1 << IW)
   )
  (
  input wire            clk,

  // Port A
  input wire  [IW-1:0]  a_addr,
  output wire [DW-1:0]  a_dout,

  // Port B
  input wire  [IW-1:0]  b_addr,
  input wire            b_wren,
  input wire  [DW-1:0]  b_din
  );

  reg [DW-1:0]  rf_data [ENTRIES-1:0];
  reg [IW-1:0]  a_addr_q;
  reg [IW-1:0]  b_addr_q;

  // Port A
  always @(posedge clk) begin
    a_addr_q <= `SD a_addr;
  end
  assign a_dout = rf_data[a_addr_q];

  // Port B
  always @(posedge clk) begin
    if (b_wren) begin
      rf_data[b_addr] <= `SD b_din;
    end
  end
endmodule
  
