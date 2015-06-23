//----------------------------------------------------------------------
// Author: Guy Hutchison
//
// This block is uncopyrighted and released into the public domain.
//----------------------------------------------------------------------

module behave2p_mem
  #(parameter width=8,
    parameter depth=256,
    parameter addr_sz=$clog2(depth))
  (/*AUTOARG*/
  // Outputs
  d_out,
  // Inputs
  wr_en, rd_en, wr_clk, rd_clk, d_in, rd_addr, wr_addr
  );
  input        wr_en, rd_en, wr_clk;
  input        rd_clk;
  input [width-1:0] d_in;
  input [addr_sz-1:0] rd_addr, wr_addr;

  output [width-1:0]  d_out;

  reg [addr_sz-1:0] r_addr;

  reg [width-1:0]   array[0:depth-1];
  
  always @(posedge wr_clk)
    begin
      if (wr_en)
        begin
          array[wr_addr] <= #1 d_in;
        end
    end

  always @(posedge rd_clk)
    begin
      if (rd_en)
        begin
          r_addr <= #1 rd_addr;
        end
    end // always @ (posedge clk)

  assign d_out = array[r_addr];

endmodule
