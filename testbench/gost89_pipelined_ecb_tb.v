`timescale 1ns / 1ps

module gost89_pipelined_ecb_tb;
  reg clk;
  always
    #1 clk = ~clk;

  reg  [511:0] sbox = 512'h 4a92d80e6b1c7f53eb4c6dfa23810759581da342efc7609b7da1089fe46cb2536c715fd84a9e03b24ba0721d36859cfedb413f590ae7682c1fd057a4923e6b8c;
  reg  [255:0] key  = 256'h 0475f6e05038fbfad2c7c390edb3ca3d1547124291ae1e8a2f79cd9ed2bcefbd;
  reg  [63:0]  in_e, in_d;
  wire [63:0]  out_e, out_d;

  gost89_pipelined_ecb_encrypt
    pipelined_ecb_encrypt(clk, sbox, key, in_e, out_e);
  gost89_pipelined_ecb_decrypt
    pipelined_ecb_decrypt(clk, sbox, key, in_d, out_d);

/*
ECB mode:
d5a8a608f4f115b4 389eb44a391474c4 379e59c3c96bb2ab 3f38ae3b8f541361 
d658a36b11cf46eb 7aea1ed18e604249 c35472c91cd78640 3b5834a000fba066 
*/

  initial begin
    $dumpfile("gost89_pipelined_ecb_tb.vcd");
    $dumpvars(0, gost89_pipelined_ecb_tb);

    clk = 0;

// One vector
    #1;
    in_e = 64'h d5a8a608f4f115b4; in_d = 64'h d658a36b11cf46eb;
    #64;
    if (out_e !== 64'h d658a36b11cf46eb || out_d !== 64'h d5a8a608f4f115b4)
      begin $display("E"); $finish; end
    $display("OK");

// Three vectors
    #4
    in_e = 64'h 389eb44a391474c4; in_d = 64'h 7aea1ed18e604249;
    #2;
    in_e = 64'h 379e59c3c96bb2ab; in_d = 64'h c35472c91cd78640;
    #8;
    in_e = 64'h 3f38ae3b8f541361; in_d = 64'h 3b5834a000fba066;
    #54;
    if (out_e !== 64'h 7aea1ed18e604249 || out_d !== 64'h 389eb44a391474c4)
      begin $display("E"); $finish; end
    $display("OK");
    #2;
    if (out_e !== 64'h c35472c91cd78640 || out_d !== 64'h 379e59c3c96bb2ab)
      begin $display("E"); $finish; end
    $display("OK");
    #8;
    if (out_e !== 64'h 3b5834a000fba066 || out_d !== 64'h 3f38ae3b8f541361)
      begin $display("E"); $finish; end
    $display("OK");

    #10;
    $display("All passed");
    $finish;
  end
endmodule
