//
// lfsr128.v -- a linear feedback shift register with 128 bits
//              (actually constructed from 4 instances of a 32-bit lfsr)
//


module lfsr128(clk, reset_in_n, s, rs232_txd);
    input clk;
    input reset_in_n;
    output [3:0] s;
    output rs232_txd;

  wire reset;
  reg [23:0] reset_counter;

  reg [31:0] lfsr0;
  reg [31:0] lfsr1;
  reg [31:0] lfsr2;
  reg [31:0] lfsr3;

  wire trigger;
  wire sample;
  wire [127:0] log_data;

  assign reset = (reset_counter == 24'hFFFFFF) ? 0 : 1;
  always @(posedge clk) begin
    if (reset_in_n == 0) begin
      reset_counter <= 24'h000000;
    end else begin
      if (reset_counter != 24'hFFFFFF) begin
        reset_counter <= reset_counter + 1;
      end
    end
  end

  always @(posedge clk) begin
    if (reset == 1) begin
      lfsr0 <= 32'hC70337DB;
      lfsr1 <= 32'h7F4D514F;
      lfsr2 <= 32'h75377599;
      lfsr3 <= 32'h7D5937A3;
    end else begin
      if (lfsr0[0] == 0) begin
        lfsr0 <= lfsr0 >> 1;
      end else begin
        lfsr0 <= (lfsr0 >> 1) ^ 32'hD0000001;
      end
      if (lfsr1[0] == 0) begin
        lfsr1 <= lfsr1 >> 1;
      end else begin
        lfsr1 <= (lfsr1 >> 1) ^ 32'hD0000001;
      end
      if (lfsr2[0] == 0) begin
        lfsr2 <= lfsr2 >> 1;
      end else begin
        lfsr2 <= (lfsr2 >> 1) ^ 32'hD0000001;
      end
      if (lfsr3[0] == 0) begin
        lfsr3 <= lfsr3 >> 1;
      end else begin
        lfsr3 <= (lfsr3 >> 1) ^ 32'hD0000001;
      end
    end
  end

  assign s[3] = lfsr0[27];
  assign s[2] = lfsr1[13];
  assign s[1] = lfsr2[23];
  assign s[0] = lfsr3[11];

  assign trigger = (lfsr0 == 32'h7119C0CD) ? 1 : 0;
  assign sample = 1;
  assign log_data = { lfsr0, lfsr1, lfsr2, lfsr3 };
  LogicProbe lp(clk, reset, trigger, sample, log_data, rs232_txd);

endmodule
