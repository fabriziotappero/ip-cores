// --------------------------------------------------------------------
//
// --------------------------------------------------------------------

`include "timescale.v"


module sync (
              input async_sig,
              output sync_out,
              
              input clk
            );

  reg [1:2] resync;

  always @(posedge clk)
  begin
    // update history shifter.
    resync <= {async_sig , resync[1]};
  end
  
  assign sync_out = resync[2];

endmodule

