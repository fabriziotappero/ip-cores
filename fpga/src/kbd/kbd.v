//
// kbd.v -- PC keyboard interface
//


module kbd(clk, reset,
           en, wr, addr,
           data_in, data_out,
           wt, irq,
           ps2_clk, ps2_data);
    // internal interface
    input clk;
    input reset;
    input en;
    input wr;
    input addr;
    input [7:0] data_in;
    output [7:0] data_out;
    output wt;
    output irq;
    // external interface
    input ps2_clk;
    input ps2_data;

  wire [7:0] keyboard_data;
  wire keyboard_rdy;
  reg [7:0] data;
  reg rdy;
  reg ien;
  reg [7:2] other_bits;

  keyboard keyboard1(
    .ps2_clk(ps2_clk),
    .ps2_data(ps2_data),
    .clk(clk),
    .reset(reset),
    .keyboard_data(keyboard_data[7:0]),
    .keyboard_rdy(keyboard_rdy)
  );

  always @(posedge clk) begin
    if (reset == 1) begin
      data <= 8'h00;
      rdy <= 0;
      ien <= 0;
      other_bits <= 6'b000000;
    end else begin
      if (keyboard_rdy == 1) begin
        data <= keyboard_data;
      end
      if (keyboard_rdy == 1 ||
          (en == 1 && wr == 0 && addr == 1)) begin
        rdy <= keyboard_rdy;
      end
      if (en == 1 && wr == 1 && addr == 0) begin
        rdy <= data_in[0];
        ien <= data_in[1];
        other_bits <= data_in[7:2];
      end
    end
  end

  assign data_out =
    (addr == 0) ? { other_bits[7:2], ien, rdy } : data[7:0];
  assign wt = 1'b0;
  assign irq = ien & rdy;

endmodule
