
module send_serial (
    // Serial pad signal
    output reg  trx_,

    // Wishbone slave interface
    input       wb_clk_i,
    input       wb_rst_i,
    input [7:0] wb_dat_i,
    input       wb_we_i,
    input       wb_stb_i,
    input       wb_cyc_i,
    output reg  wb_ack_o
  );

  // Registers and nets
  wire       op;
  wire       start;
  reg  [8:0] tr;
  reg        st;
  reg  [7:0] sft;

  // Continuous assignments
  assign op    = wb_we_i & wb_stb_i & wb_cyc_i;
  assign start = !st & op;

  // Behaviour
  // trx_
  always @(posedge wb_clk_i)
    trx_ <= wb_rst_i ? 1'b1 : (start ? 1'b0 : tr[0]);

  // tr
  always @(posedge wb_clk_i)
    tr <= wb_rst_i ? 9'h1ff
        : { 1'b1, (start ? wb_dat_i : tr[8:1]) };

  // sft, wb_ack_o
  always @(posedge wb_clk_i)
    { sft, wb_ack_o } <= wb_rst_i ? 9'h0 : { start, sft };

  // st
  always @(posedge wb_clk_i)
    st <= wb_rst_i ? 1'b0 : (st ? !wb_ack_o : op);
endmodule
