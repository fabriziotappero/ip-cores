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
// File        : det_pos_edge.v
// Author      : J.Bean
// Date        : Nov 2009
// Description : Detect a positive edge.
////////////////////////////////////////////////////////////

`resetall
`timescale 1ns/10ps

module det_pos_edge(
  input  wire clk,
  input  wire rst_n,
  input  wire d,
  output wire q
);

////////////////////////////////////////////////////////////
// Signals
//////////////////////////////////////////////////////////// 

reg d_p1;

////////////////////////////////////////////////////////////
// Comb Assign : Q
// Description : 
////////////////////////////////////////////////////////////

assign q = d & ~d_p1;

////////////////////////////////////////////////////////////
// Seq Block   : Data pipeline
// Description : 
////////////////////////////////////////////////////////////

always @(negedge rst_n or posedge clk)
begin
  if (rst_n == 0) begin
    d_p1 <= 0;
  end else begin
    d_p1 <= d;
  end
end 
            
endmodule
