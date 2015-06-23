//-------------------------------------------------------------------------
//
// File name    :  ldpc_ram_behav.v
// Title        :
//              :
// Purpose      : RAM behavioral model
//
// ----------------------------------------------------------------------
// Revision History :
// ----------------------------------------------------------------------
//   Ver  :| Author   :| Mod. Date   :| Changes Made:
//   v1.0  | JTC      :| 2008/07/02  :|
// ----------------------------------------------------------------------
`timescale 1ns/10ps

module ldpc_ram_behav #(
  parameter WIDTH     = 4,
  parameter LOG2DEPTH = 4
)(
  input                clk,
  input                we,
  input[WIDTH-1:0]     din,
  input[LOG2DEPTH-1:0] wraddr,
  input[LOG2DEPTH-1:0] rdaddr,
  output[WIDTH-1:0]    dout
);

reg[WIDTH-1:0]     storage[0:2**LOG2DEPTH -1];
reg[LOG2DEPTH-1:0] addr_del;
reg[WIDTH-1:0]     dout_int;

assign dout = dout_int;

always @( posedge clk )
begin
  if( !we )
    storage[wraddr] <= din;
  
  addr_del <= rdaddr;
  
  dout_int <= storage[addr_del];
end

endmodule
