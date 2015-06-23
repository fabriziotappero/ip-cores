module but_int (
    input      clk,
    input      rst,
    input      but_,
    output reg intr,
    input      inta
  );

  // Register declaration
  reg old_but;

  // Behaviour
  always @(posedge clk)
    if (rst) intr <= 1'b0;
    else intr <= intr ? !inta : (but_ && !old_but);

  always @(posedge clk) old_but <= but_;

endmodule
