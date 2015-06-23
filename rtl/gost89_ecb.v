module gost89_ecb(
  input              clk,
  input              reset,
  input              mode,
  input              load_data,
  input      [511:0] sbox,
  input      [255:0] key,
  input      [63:0]  in,
  output reg [63:0]  out,
  output reg         busy
);
  reg  [5:0]  round_num;
  reg  [31:0] n1, n2, round_key;
  wire [31:0] out1, out2;

  gost89_round
    rnd(clk, sbox, round_key, n1, n2, out1, out2);

  always @(posedge clk) begin
    if (load_data) begin
      n1 <= in[63:32];
      n2 <= in[31:0];
      busy <= 1;
      round_num <= 0;
    end

    if (reset && !load_data) begin
      busy <= 0;
      round_num <= 32;
    end

    if (!reset && !load_data) begin
      if (round_num < 32)
        round_num <= round_num + 1;
      if (round_num > 0 && round_num < 32) begin
        n1 <= out1;
        n2 <= out2;
      end
      if (round_num == 32) begin
        out[63:32] <= out2;
        out[31:0]  <= out1;
        busy <= 0;
      end
    end
  end

  always @(posedge clk) begin
    if (mode)
      case (round_num)
        0:  round_key <= key[255:224];
        1:  round_key <= key[223:192];
        2:  round_key <= key[191:160];
        3:  round_key <= key[159:128];
        4:  round_key <= key[127:96];
        5:  round_key <= key[95:64];
        6:  round_key <= key[63:32];
        7:  round_key <= key[31:0];
        8:  round_key <= key[31:0];
        9:  round_key <= key[63:32];
        10: round_key <= key[95:64];
        11: round_key <= key[127:96];
        12: round_key <= key[159:128];
        13: round_key <= key[191:160];
        14: round_key <= key[223:192];
        15: round_key <= key[255:224];
        16: round_key <= key[31:0];
        17: round_key <= key[63:32];
        18: round_key <= key[95:64];
        19: round_key <= key[127:96];
        20: round_key <= key[159:128];
        21: round_key <= key[191:160];
        22: round_key <= key[223:192];
        23: round_key <= key[255:224];
        24: round_key <= key[31:0];
        25: round_key <= key[63:32];
        26: round_key <= key[95:64];
        27: round_key <= key[127:96];
        28: round_key <= key[159:128];
        29: round_key <= key[191:160];
        30: round_key <= key[223:192];
        31: round_key <= key[255:224];
      endcase
    else
      case (round_num)
        0:  round_key <= key[255:224];
        1:  round_key <= key[223:192];
        2:  round_key <= key[191:160];
        3:  round_key <= key[159:128];
        4:  round_key <= key[127:96];
        5:  round_key <= key[95:64];
        6:  round_key <= key[63:32];
        7:  round_key <= key[31:0];
        8:  round_key <= key[255:224];
        9:  round_key <= key[223:192];
        10: round_key <= key[191:160];
        11: round_key <= key[159:128];
        12: round_key <= key[127:96];
        13: round_key <= key[95:64];
        14: round_key <= key[63:32];
        15: round_key <= key[31:0];
        16: round_key <= key[255:224];
        17: round_key <= key[223:192];
        18: round_key <= key[191:160];
        19: round_key <= key[159:128];
        20: round_key <= key[127:96];
        21: round_key <= key[95:64];
        22: round_key <= key[63:32];
        23: round_key <= key[31:0];
        24: round_key <= key[31:0];
        25: round_key <= key[63:32];
        26: round_key <= key[95:64];
        27: round_key <= key[127:96];
        28: round_key <= key[159:128];
        29: round_key <= key[191:160];
        30: round_key <= key[223:192];
        31: round_key <= key[255:224];
      endcase
  end
endmodule

module gost89_ecb_encrypt(
  input              clk,
  input              reset,
  input              load_data,
  input      [511:0] sbox,
  input      [255:0] key,
  input      [63:0]  in,
  output reg [63:0]  out,
  output reg         busy
);
  reg  [5:0]  round_num;
  reg  [31:0] n1, n2, round_key;
  wire [31:0] out1, out2;

  gost89_round
    rnd(clk, sbox, round_key, n1, n2, out1, out2);

  always @(posedge clk) begin
    if (load_data) begin
      n1 <= in[63:32];
      n2 <= in[31:0];
      busy <= 1;
      round_num <= 0;
    end

    if (reset && !load_data) begin
      busy <= 0;
      round_num <= 32;
    end

    if (!reset && !load_data) begin
      if (round_num < 32)
        round_num <= round_num + 1;
      if (round_num > 0 && round_num < 32) begin
        n1 <= out1;
        n2 <= out2;
      end
      if (round_num == 32) begin
        out[63:32] <= out2;
        out[31:0]  <= out1;
        busy <= 0;
      end
    end
  end

  always @(posedge clk)
    case (round_num)
      0:  round_key <= key[255:224];
      1:  round_key <= key[223:192];
      2:  round_key <= key[191:160];
      3:  round_key <= key[159:128];
      4:  round_key <= key[127:96];
      5:  round_key <= key[95:64];
      6:  round_key <= key[63:32];
      7:  round_key <= key[31:0];
      8:  round_key <= key[255:224];
      9:  round_key <= key[223:192];
      10: round_key <= key[191:160];
      11: round_key <= key[159:128];
      12: round_key <= key[127:96];
      13: round_key <= key[95:64];
      14: round_key <= key[63:32];
      15: round_key <= key[31:0];
      16: round_key <= key[255:224];
      17: round_key <= key[223:192];
      18: round_key <= key[191:160];
      19: round_key <= key[159:128];
      20: round_key <= key[127:96];
      21: round_key <= key[95:64];
      22: round_key <= key[63:32];
      23: round_key <= key[31:0];
      24: round_key <= key[31:0];
      25: round_key <= key[63:32];
      26: round_key <= key[95:64];
      27: round_key <= key[127:96];
      28: round_key <= key[159:128];
      29: round_key <= key[191:160];
      30: round_key <= key[223:192];
      31: round_key <= key[255:224];
    endcase
endmodule

module gost89_ecb_decrypt(
  input              clk,
  input              reset,
  input              load_data,
  input      [511:0] sbox,
  input      [255:0] key,
  input      [63:0]  in,
  output reg [63:0]  out,
  output reg         busy
);
  reg  [5:0]  round_num;
  reg  [31:0] n1, n2, round_key;
  wire [31:0] out1, out2;

  gost89_round
    rnd(clk, sbox, round_key, n1, n2, out1, out2);

  initial begin
    busy = 0;
    round_num = 32;
  end

  always @(posedge clk) begin
    if (load_data) begin
      n1 <= in[63:32];
      n2 <= in[31:0];
      busy <= 1;
      round_num <= 0;
    end

    if (reset && !load_data) begin
      busy <= 0;
      round_num <= 32;
    end

    if (!reset && !load_data) begin
      if (round_num < 32)
        round_num <= round_num + 1;
      if (round_num > 0 && round_num < 32) begin
        n1 <= out1;
        n2 <= out2;
      end
      if (round_num == 32) begin
        out[63:32] = out2;
        out[31:0]  = out1;
        busy <= 0;
      end
    end
  end

  always @(posedge clk)
    case (round_num)
      0:  round_key <= key[255:224];
      1:  round_key <= key[223:192];
      2:  round_key <= key[191:160];
      3:  round_key <= key[159:128];
      4:  round_key <= key[127:96];
      5:  round_key <= key[95:64];
      6:  round_key <= key[63:32];
      7:  round_key <= key[31:0];
      8:  round_key <= key[31:0];
      9:  round_key <= key[63:32];
      10: round_key <= key[95:64];
      11: round_key <= key[127:96];
      12: round_key <= key[159:128];
      13: round_key <= key[191:160];
      14: round_key <= key[223:192];
      15: round_key <= key[255:224];
      16: round_key <= key[31:0];
      17: round_key <= key[63:32];
      18: round_key <= key[95:64];
      19: round_key <= key[127:96];
      20: round_key <= key[159:128];
      21: round_key <= key[191:160];
      22: round_key <= key[223:192];
      23: round_key <= key[255:224];
      24: round_key <= key[31:0];
      25: round_key <= key[63:32];
      26: round_key <= key[95:64];
      27: round_key <= key[127:96];
      28: round_key <= key[159:128];
      29: round_key <= key[191:160];
      30: round_key <= key[223:192];
      31: round_key <= key[255:224];
    endcase
endmodule
