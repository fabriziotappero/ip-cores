module gost89_cfb(
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
  reg  [63:0] gamma;
  reg  [63:0] in_value;
  wire [63:0] out_ecb;
  wire        reset_ecb, load_ecb, busy_ecb;

  assign load_ecb = !reset && load_data;
  assign reset_ecb = load_ecb;

  gost89_ecb_encrypt
    ecb_encrypt(clk, reset_ecb, load_ecb, sbox, key, gamma, out_ecb, busy_ecb);

  always @(posedge clk) begin
    if (reset && !load_data) begin
      gamma <= in;
      busy <= 0;
    end

    if (!reset & load_data) begin
      in_value <= in;
      busy <= 1;
    end

    if (!reset && !load_data && !busy_ecb && busy) begin
      if (mode) gamma <= in_value;
      else      gamma <= out_ecb ^ in_value;
      out   <= out_ecb ^ in_value;
      busy  <= 0;
    end
  end
endmodule

module gost89_cfb_encrypt(
  input              clk,
  input              reset,
  input              load_data,
  input      [511:0] sbox,
  input      [255:0] key,
  input      [63:0]  in,
  output reg [63:0]  out,
  output reg         busy
);
  reg  [63:0] gamma;
  reg  [63:0] in_value;
  wire [63:0] out_ecb;
  wire        load_ecb, busy_ecb;

  assign load_ecb = !reset && load_data;
  assign reset_ecb = load_ecb;

  gost89_ecb_encrypt
    ecb_encrypt(clk, reset_ecb, load_ecb, sbox, key, gamma, out_ecb, busy_ecb);

  always @(posedge clk) begin
    if (reset && !load_data) begin
      gamma <= in;
      busy <= 0;
    end

    if (!reset & load_data) begin
      in_value <= in;
      busy <= 1;
    end

    if (!reset && !load_data && !busy_ecb && busy) begin
      gamma <= out_ecb ^ in_value;
      out   <= out_ecb ^ in_value;
      busy  <= 0;
    end
  end
endmodule

module gost89_cfb_decrypt(
  input              clk,
  input              reset,
  input              load_data,
  input      [511:0] sbox,
  input      [255:0] key,
  input      [63:0]  in,
  output reg [63:0]  out,
  output reg         busy
);
  reg  [63:0] gamma;
  reg  [63:0] in_value;
  wire [63:0] out_ecb;
  wire        load_ecb, busy_ecb;

  assign load_ecb = !reset && load_data;
  assign reset_ecb = load_ecb;

  gost89_ecb_encrypt
    ecb_encrypt(clk, reset_ecb, load_ecb, sbox, key, gamma, out_ecb, busy_ecb);

  always @(posedge clk) begin
    if (reset && !load_data) begin
      gamma <= in;
      busy <= 0;
    end

    if (!reset & load_data) begin
      in_value <= in;
      busy <= 1;
    end

    if (!reset && !load_data && !busy_ecb && busy) begin
      gamma <= in_value;
      out   <= out_ecb ^ in_value;
      busy  <= 0;
    end
  end
endmodule
