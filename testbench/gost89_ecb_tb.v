`timescale 1ns / 1ps

module gost89_ecb_tb;
  reg clk;
  always
    #1 clk = ~clk;

  reg  [511:0] sbox = 512'h 4a92d80e6b1c7f53eb4c6dfa23810759581da342efc7609b7da1089fe46cb2536c715fd84a9e03b24ba0721d36859cfedb413f590ae7682c1fd057a4923e6b8c;
  reg  [255:0] key  = 256'h 0475f6e05038fbfad2c7c390edb3ca3d1547124291ae1e8a2f79cd9ed2bcefbd;
  wire mode_e = 0, mode_d = 1;
  reg reset;
  reg load_data;
  reg [63:0] in_e1, in_e2, in_d1, in_d2;
  wire [63:0] out_e1, out_e2, out_d1, out_d2;
  wire busy_e1, busy_e2, busy_d1, busy_d2;

  gost89_ecb
    ecb1(clk, reset, mode_e, load_data, sbox, key, in_e1, out_e1, busy_e1),
    ecb2(clk, reset, mode_d, load_data, sbox, key, in_d1, out_d1, busy_d1);
  gost89_ecb_encrypt
    ecb_encrypt(clk, reset, load_data, sbox, key, in_e2, out_e2, busy_e2);
  gost89_ecb_decrypt
    ecb_decrypt(clk, reset, load_data, sbox, key, in_d2, out_d2, busy_d2);

/*
ECB mode:
d5a8a608f4f115b4 389eb44a391474c4 379e59c3c96bb2ab 3f38ae3b8f541361 
d658a36b11cf46eb 7aea1ed18e604249 c35472c91cd78640 3b5834a000fba066 
*/

  initial begin
    $dumpfile("gost89_ecb_tb.vcd");
    $dumpvars(0, gost89_ecb_tb);

    clk = 0;
    reset = 0;
    load_data = 0;

// Normal usage
    #1;
    in_e1 = 64'h d5a8a608f4f115b4; in_d1 = 64'h d658a36b11cf46eb;
    in_e2 = 64'h d5a8a608f4f115b4; in_d2 = 64'h d658a36b11cf46eb;
    load_data = 1;
    #2;
    load_data = 0;
    #66;
    if (out_e1 != out_e2 || out_e2 != 64'h d658a36b11cf46eb || out_d1 != out_d2 || out_d2 != 64'h d5a8a608f4f115b4)
      begin $display("E"); $finish; end
    $display("OK");

// After reset
    #2;
    reset = 1;
    #2;
    reset = 0;
    #2;
    in_e1 = 64'h 389eb44a391474c4; in_d1 = 64'h 7aea1ed18e604249;
    in_e2 = 64'h 389eb44a391474c4; in_d2 = 64'h 7aea1ed18e604249;
    load_data = 1;
    #2;
    load_data = 0;
    #66;
    if (out_e1 != out_e2 || out_e2 != 64'h 7aea1ed18e604249 || out_d1 != out_d2 || out_d2 != 64'h 389eb44a391474c4)
      begin $display("E"); $finish; end
    $display("OK");

// Reset in processing
    #2;
    in_e1 = 64'h 0123456789abcdef; in_d1 = 64'h 0123456789abcdef;
    in_e2 = 64'h 0123456789abcdef; in_d2 = 64'h 0123456789abcdef;
    load_data = 1;
    #2;
    load_data = 0;
    #12;
    reset = 1;
    #2;
    reset = 0;
    #2;
    in_e1 = 64'h 379e59c3c96bb2ab; in_d1 = 64'h c35472c91cd78640;
    in_e2 = 64'h 379e59c3c96bb2ab; in_d2 = 64'h c35472c91cd78640;
    load_data = 1;
    #2;
    load_data = 0;
    #66;
    if (out_e1 != out_e2 || out_e2 != 64'h c35472c91cd78640 || out_d1 != out_d2 || out_d2 != 64'h 379e59c3c96bb2ab)
      begin $display("E"); $finish; end
    $display("OK");

// Start with reset
    #2;
    in_e1 = 64'h 3f38ae3b8f541361; in_d1 = 64'h 3b5834a000fba066;
    in_e2 = 64'h 3f38ae3b8f541361; in_d2 = 64'h 3b5834a000fba066;
    load_data = 1;
    reset = 1;
    #2;
    load_data = 0;
    reset = 0;
    #66;
    if (out_e1 != out_e2 || out_e2 != 64'h 3b5834a000fba066 || out_d1 != out_d2 || out_d2 != 64'h 3f38ae3b8f541361)
      begin $display("E"); $finish; end
    $display("OK");

    #10;
    $display("All passed");
    $finish;
  end
endmodule
