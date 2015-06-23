////////////////////////////////////////////////////////////
//
// This confidential and proprietary software may be used
// only as authorized by a licensing agreement from
// Bean Digital Ltd
// In the event of publication, the following notice is
// applicable:
//
// (C)COPYRIGHT 2009 BEAN DIGITAL LTD.
// ALL RIGHTS RESERVED
//
// The entire notice above must be reproduced on all
// authorized copies.
//
// File        : mux.v
// Author      : J.Bean
// Date        : Sep 2009
// Description : Multiplexer
////////////////////////////////////////////////////////////

`resetall
`timescale 1ns/10ps

module mux
  #(parameter DATA_BITS  = 16,                // Data bits
    parameter IP_NUM     = 4,                 // Number of inputs
    parameter USE_OP_REG = 0)(                // Enable Register on Output 
  input  wire                        clk,     // Clock
  input  wire [IP_NUM*DATA_BITS-1:0] data_i,  // Data Input
  input  wire [7:0]                  sel_i,   // Input Select
  output wire [DATA_BITS-1:0]        data_o   // Data Output
);

////////////////////////////////////////////////////////////
// Signals
//////////////////////////////////////////////////////////// 

genvar i;
reg  [DATA_BITS-1:0] ip_array [0:IP_NUM-1];
wire [DATA_BITS-1:0] data_c;
reg  [DATA_BITS-1:0] data_r;

////////////////////////////////////////////////////////////
// Comb Assign : Data Output
// Description : 
////////////////////////////////////////////////////////////

assign data_o = (USE_OP_REG == 1) ? data_r : data_c;

////////////////////////////////////////////////////////////
// Comb Assign : Data Comb
// Description : Assign an input vector from the array.
////////////////////////////////////////////////////////////

assign data_c = ip_array[sel_i];

////////////////////////////////////////////////////////////
// Generate    : Input array
// Description : Create an array of input vectors.
////////////////////////////////////////////////////////////

generate
  for(i=0; i<IP_NUM; i=i+1) begin: mux_gen  
    always @(*)
    begin
      ip_array[i] = data_i[(i+1)*DATA_BITS-1:i*DATA_BITS];
    end
  end
endgenerate

////////////////////////////////////////////////////////////
// Seq Block   : Data Registered
// Description : 
// Assign an input vector from the array.
////////////////////////////////////////////////////////////

always @(posedge clk)
begin
  data_r <= ip_array[sel_i];
end

endmodule