//----------------------------------------------------------------------
// Author: Guy Hutchison
//
// This block is uncopyrighted and released into the public domain.
//----------------------------------------------------------------------

module behave1p_mem
  #(parameter depth=256,
    parameter width=8,
    parameter addr_sz=$clog2(depth))
  (/*AUTOARG*/
  // Outputs
  d_out,
  // Inputs
  wr_en, rd_en, clk, d_in, addr
  );
  input        wr_en, rd_en, clk;
  input [width-1:0] d_in;
  input [addr_sz-1:0]     addr;

  output [width-1:0]     d_out;

  reg [addr_sz-1:0] r_addr;

  reg [width-1:0]            array[0:depth-1];
  
  always @(posedge clk)
    begin
      if (wr_en)
        begin
          array[addr] <= #1 d_in;
        end
      else if (rd_en)
        begin
          r_addr <= #1 addr;
        end
    end // always @ (posedge clk)

  assign d_out = array[r_addr];

`ifndef verilator
  genvar g;

  generate
    for (g=0; g<depth; g=g+1)
      begin : breakout
	wire [width-1:0] brk;

	assign brk=array[g];
      end
  endgenerate
`endif

endmodule
