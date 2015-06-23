module lcd_display (
    input [63:0] f1,  // 1st row
    input [63:0] f2,  // 2nd row
    input [15:0] m1,  // 1st row mask
    input [15:0] m2,  // 2nd row mask

    input        clk, // 100 Mhz clock
    input        rst,

    // Pad signals
    output reg       lcd_rs_,
    output reg       lcd_rw_,
    output reg       lcd_e_,
    output reg [7:4] lcd_dat_
  );

  // Parameter definitions
  parameter n = 8;
  parameter k = 16;

  // Register declarations
  reg [k+n+1:0] cnt = 0;
  reg [    5:0] lcd;

  // Net declarations
  wire [127:0] f;
  wire [ 31:0] m;
  wire [  4:0] i;
  wire [  3:0] c;

  // Module instantiations
  sel128_4 sel (
    .in  (f),
    .sel (i),
    .out (c)
  );

  // Continuous assignments
  assign f = { f1, f2 };
  assign m = { m1, m2 };
  assign i = cnt[k+7:k+3];

  // Behaviour
  always @(posedge clk)
    if (rst) cnt <= 26'hfffffff;
    else begin
      cnt <= cnt - 1;
      casex (cnt[k+1+n:k+2])
        8'hff: lcd <= 6'b000010; // function set
        8'hfe: lcd <= 6'b000010;
        8'hfd: lcd <= 6'b001000;
        8'hfc: lcd <= 6'b000000; // display on/off control
        8'hfb: lcd <= 6'b001100;
        8'hfa: lcd <= 6'b000000; // display clear
        8'hf9: lcd <= 6'b000001;
        8'hf8: lcd <= 6'b000000; // entry mode set
        8'hf7: lcd <= 6'b000110;
        8'hf6: cnt[k+1+n:k+2] <= 8'b10111111;

        8'b101xxxx1: lcd <= { 2'b10, m[i] ? itoa1(c) : 4'h2 };
        8'b101xxxx0: lcd <= { 2'b10, m[i] ? itoa0(c) : 4'h0 };
        8'b10011111: lcd <= 6'h0c;
        8'b10011110: lcd <= 6'h00;
        8'b10011101: cnt[k+1+n:k+2] <= 8'b01011111;
        8'b010xxxx1: lcd <= { 2'b10, m[i] ? itoa1(c) : 4'h2 };
        8'b010xxxx0: lcd <= { 2'b10, m[i] ? itoa0(c) : 4'h0 };
        8'b00111111: lcd <= 6'h08;
        8'b00111110: lcd <= 6'h00;
        8'b00111101: cnt[k+1+n:k+2] <= 8'b10111111;

        default: lcd <= 6'b010000;
      endcase
      lcd_e_ <= ^cnt[k+1:k+0] & ~lcd_rw_;
      { lcd_rs_, lcd_rw_, lcd_dat_ } <= lcd;
    end

  // Function definitions
  function [3:0] itoa1;
    input [3:0] i;
    begin
      if (i < 8'd10) itoa1 = 4'h3;
      else itoa1 = 4'h6;
    end
  endfunction

  function [3:0] itoa0;
    input [3:0] i;
    begin
      if (i < 8'd10) itoa0 = i + 4'h0;
      else itoa0 = i + 4'h7;
    end
  endfunction
endmodule

module sel128_4 (
    input      [127:0] in,
    input      [  4:0] sel,
    output reg [  3:0] out
  );

  always @(in or sel)
    case (sel)
      5'h00: out <= in[  3:  0];
      5'h01: out <= in[  7:  4];
      5'h02: out <= in[ 11:  8];
      5'h03: out <= in[ 15: 12];
      5'h04: out <= in[ 19: 16];
      5'h05: out <= in[ 23: 20];
      5'h06: out <= in[ 27: 24];
      5'h07: out <= in[ 31: 28];
      5'h08: out <= in[ 35: 32];
      5'h09: out <= in[ 39: 36];
      5'h0a: out <= in[ 43: 40];
      5'h0b: out <= in[ 47: 44];
      5'h0c: out <= in[ 51: 48];
      5'h0d: out <= in[ 55: 52];
      5'h0e: out <= in[ 59: 56];
      5'h0f: out <= in[ 63: 60];
      5'h10: out <= in[ 67: 64];
      5'h11: out <= in[ 71: 68];
      5'h12: out <= in[ 75: 72];
      5'h13: out <= in[ 79: 76];
      5'h14: out <= in[ 83: 80];
      5'h15: out <= in[ 87: 84];
      5'h16: out <= in[ 91: 88];
      5'h17: out <= in[ 95: 92];
      5'h18: out <= in[ 99: 96];
      5'h19: out <= in[103:100];
      5'h1a: out <= in[107:104];
      5'h1b: out <= in[111:108];
      5'h1c: out <= in[115:112];
      5'h1d: out <= in[119:116];
      5'h1e: out <= in[123:120];
      5'h1f: out <= in[127:124];
    endcase
endmodule