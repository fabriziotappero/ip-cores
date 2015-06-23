// --------------------------------------------------------------------
//
// --------------------------------------------------------------------

`include "timescale.v"


module sync_edge_detect (
                          input async_sig,
                          output sync_out,
                          
                          input clk,
                          
                          output reg rise,
                          output reg fall
                        );

  reg [1:3] resync;

  always @(posedge clk)
  begin
    // detect rising and falling edges.
    rise <= ~resync[3] & resync[2];
    fall <= ~resync[2] & resync[3];
    // update history shifter.
    resync <= {async_sig , resync[1:2]};
  end
  
  assign sync_out = resync[2];

endmodule

