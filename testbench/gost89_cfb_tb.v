`timescale 1ns / 1ps

module gost89_cfb_tb;
  reg clk;
  always
    #1 clk = ~clk;

  reg  [511:0] sbox = 512'h 4a92d80e6b1c7f53eb4c6dfa23810759581da342efc7609b7da1089fe46cb2536c715fd84a9e03b24ba0721d36859cfedb413f590ae7682c1fd057a4923e6b8c;
  reg  [255:0] key  = 256'h 0475f6e05038fbfad2c7c390edb3ca3d1547124291ae1e8a2f79cd9ed2bcefbd;
  wire mode_e = 0, mode_d = 1;
  reg  reset;
  reg  load_data;
  reg  [63:0] in_e1, in_e2, in_d1, in_d2;
  wire [63:0] out_e1, out_e2, out_d1, out_d2;
  wire busy_e1, busy_e2, busy_d1, busy_d2;

  gost89_cfb
    cfb1(clk, reset, mode_e, load_data, sbox, key, in_e1, out_e1, busy_e1),
    cfb2(clk, reset, mode_d, load_data, sbox, key, in_d1, out_d1, busy_d1);
  gost89_cfb_encrypt
    cfb_encrypt1(clk, reset, load_data, sbox, key, in_e2, out_e2, busy_e2);
  gost89_cfb_decrypt
    cfb_decrypt1(clk, reset, load_data, sbox, key, in_d2, out_d2, busy_d2);

/*
CFB mode (gamma: 6aa0379517bb57af):
8d437364581af0da 12911df3eddcc0fb b73369c4b5cf3e7d 
54826055ab718bc7 585ddacf1a45e472 a3ec5a4eb4359095

CFB mode (gamma: fa5679a45f118aed):
419677a6eff07f2f 4f40b75be8e64341 cd02e6ef903d27da 
27d3e781cc4fcf43 9c7480fb9ea9df69 458ff5081b0fd688
*/

  initial begin
    $dumpfile("gost89_cfb_tb.vcd");
    $dumpvars(0, gost89_cfb_tb);

    clk = 0;
    reset = 0;
    load_data = 0;

// Normal usage
    #1;
    in_e1 = 64'h 6aa0379517bb57af; in_d1 = 64'h 6aa0379517bb57af;
    in_e2 = 64'h 6aa0379517bb57af; in_d2 = 64'h 6aa0379517bb57af;
    reset = 1;
    #2;
    reset = 0;
    in_e1 = 64'h 8d437364581af0da; in_d1 = 64'h 54826055ab718bc7;
    in_e2 = 64'h 8d437364581af0da; in_d2 = 64'h 54826055ab718bc7;
    load_data = 1;
    #2;
    load_data = 0;
    #68;
    if (out_e1 != out_e2 || out_e2 != 64'h 54826055ab718bc7 || out_d1 != out_d2 || out_d2 != 64'h 8d437364581af0da)
      begin $display("E"); $finish; end
    $display("OK");
    in_e1 = 64'h 12911df3eddcc0fb; in_d1 = 64'h 585ddacf1a45e472;
    in_e2 = 64'h 12911df3eddcc0fb; in_d2 = 64'h 585ddacf1a45e472;
    load_data = 1;
    #2;
    load_data = 0;
    #68;
    if (out_e1 != out_e2 || out_e2 != 64'h 585ddacf1a45e472 || out_d1 != out_d2 || out_d2 != 64'h 12911df3eddcc0fb)
      begin $display("E"); $finish; end
    $display("OK");

// Change gamma
    #2;
    in_e1 = 64'h fa5679a45f118aed; in_d1 = 64'h fa5679a45f118aed;
    in_e2 = 64'h fa5679a45f118aed; in_d2 = 64'h fa5679a45f118aed;
    reset = 1;
    #2;
    reset = 0;
    in_e1 = 64'h 419677a6eff07f2f; in_d1 = 64'h 27d3e781cc4fcf43;
    in_e2 = 64'h 419677a6eff07f2f; in_d2 = 64'h 27d3e781cc4fcf43;
    load_data = 1;
    #2;
    load_data = 0;
    #68;
    if (out_e1 != out_e2 || out_e2 != 64'h 27d3e781cc4fcf43 || out_d1 != out_d2 || out_d2 != 64'h 419677a6eff07f2f)
      begin $display("E"); $finish; end
    $display("OK");

// Reset in processing
    #2;
    in_e1 = 64'h 6aa0379517bb57af; in_d1 = 64'h 6aa0379517bb57af;
    in_e2 = 64'h 6aa0379517bb57af; in_d2 = 64'h 6aa0379517bb57af;
    reset = 1;
    #2;
    reset = 0;
    in_e1 = 64'h 8d437364581af0da; in_d1 = 64'h 54826055ab718bc7;
    in_e2 = 64'h 8d437364581af0da; in_d2 = 64'h 54826055ab718bc7;
    load_data = 1;
    #2;
    load_data = 0;
    #10;
    in_e1 = 64'h fa5679a45f118aed; in_d1 = 64'h fa5679a45f118aed;
    in_e2 = 64'h fa5679a45f118aed; in_d2 = 64'h fa5679a45f118aed;
    reset = 1;
    #2;
    reset = 0;
    in_e1 = 64'h 419677a6eff07f2f; in_d1 = 64'h 27d3e781cc4fcf43;
    in_e2 = 64'h 419677a6eff07f2f; in_d2 = 64'h 27d3e781cc4fcf43;
    load_data = 1;
    #2;
    load_data = 0;
    #68;
    if (out_e1 != out_e2 || out_e2 != 64'h 27d3e781cc4fcf43 || out_d1 != out_d2 || out_d2 != 64'h 419677a6eff07f2f)
      begin $display("E"); $finish; end
    $display("OK");

    #10;
    $display("All passed");
    $finish;
  end
endmodule
