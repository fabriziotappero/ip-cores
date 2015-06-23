module debounce #(
  parameter INITIAL_STATE     = 0,
  parameter DEBOUNCE_COUNT    = 100
)(
  input         clk,
  input         in_signal,
  output  reg   out_signal
);

reg [DEBOUNCE_COUNT - 1: 0] debounce;

initial begin
  out_signal    <=  INITIAL_STATE;
  debounce      <=  INITIAL_STATE;
end
always @ (posedge clk) begin

  debounce  <= {debounce[(DEBOUNCE_COUNT - 2) : 0], in_signal};

  if (debounce[0] == 1 && (& debounce)) begin
    out_signal         <=  1;
  end
  else if ((debounce[0] == 0) && (~| debounce)) begin
    out_signal         <=  0;
  end
end

endmodule
