// Module: altera_tse_xcvr_resync
//
// Description:
//  A general purpose resynchronization module.
//  
//  Parameters:
//    SYNC_CHAIN_LENGTH
//      - Specifies the length of the synchronizer chain for metastability
//        retiming.
//    WIDTH
//      - Specifies the number of bits you want to synchronize. Controls the width of the
//        d and q ports.
//    SLOW_CLOCK - USE WITH CAUTION. 
//      - Leaving this setting at its default will create a standard resynch circuit that
//        merely passes the input data through a chain of flip-flops. This setting assumes
//        that the input data has a pulse width longer than one clock cycle sufficient to
//        satisfy setup and hold requirements on at least one clock edge.
//      - By setting this to 1 (USE CAUTION) you are creating an asynchronous
//        circuit that will capture the input data regardless of the pulse width and 
//        its relationship to the clock. However it is more difficult to apply static
//        timing constraints as it ties the data input to the clock input of the flop.
//        This implementation assumes the data rate is slow enough
//
module altera_tse_xcvr_resync #(
    parameter SYNC_CHAIN_LENGTH = 2,  // Number of flip-flops for retiming
    parameter WIDTH             = 1,  // Number of bits to resync
    parameter SLOW_CLOCK        = 0   // See description above
  ) (
  input   wire              clk,
  input   wire  [WIDTH-1:0] d,
  output  wire  [WIDTH-1:0] q
  );

localparam  INT_LEN   = (SYNC_CHAIN_LENGTH > 0) ? SYNC_CHAIN_LENGTH : 1;

genvar ig;

// Generate a synchronizer chain for each bit
generate begin
  for(ig=0;ig<WIDTH;ig=ig+1) begin : resync_chains
    wire                d_in;   // Input to sychronization chain.
    reg   [INT_LEN-1:0] r = {INT_LEN{1'b0}};
    wire  [INT_LEN  :0] next_r; // One larger real chain

    assign  q[ig]   = r[INT_LEN-1]; // Output signal
    assign  next_r  = {r,d_in};

    always @(posedge clk)
      r <= next_r[INT_LEN-1:0];

    // Generate asynchronous capture circuit if specified.
    if(SLOW_CLOCK == 0) begin
      assign  d_in = d[ig];
    end else begin
      wire  d_clk;
      reg   d_r;
      wire  clr_n;

      assign  d_clk = d[ig];
      assign  d_in  = d_r;
      assign  clr_n = ~q[ig] | d_clk; // Clear when output is logic 1 and input is logic 0

      // Asynchronously latch the input signal.
      always @(posedge d_clk or negedge clr_n)
        if(!clr_n)      d_r <= 1'b0;
        else if(d_clk)  d_r <= 1'b1;
    end // SLOW_CLOCK
  end // for loop
end // generate
endgenerate

endmodule
