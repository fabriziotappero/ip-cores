`timescale 1ns / 1ps

module gost89_mac_tb;
  reg clk;
  always
    #1 clk = ~clk;

  reg  [511:0] sbox = 512'h 4a92d80e6b1c7f53eb4c6dfa23810759581da342efc7609b7da1089fe46cb2536c715fd84a9e03b24ba0721d36859cfedb413f590ae7682c1fd057a4923e6b8c;
  reg  [255:0] key  = 256'h 0475f6e05038fbfad2c7c390edb3ca3d1547124291ae1e8a2f79cd9ed2bcefbd;
  reg          reset, load_data;
  reg  [63:0]  in;
  wire [31:0]  out;
  wire         busy;
  wire [31:0]  result = out[31:0];

  gost89_mac mac1(clk, reset, load_data, sbox, key, in, out, busy);

  initial begin
    $dumpfile("gost89_mac_tb.vcd");
    $dumpvars(0, gost89_mac_tb);

    clk       = 0;
    reset     = 0;
    load_data = 0;

/* Normal usage
4b657e2ef0d2dfa2 af36b591bbd96c85 3569faad243d6fa4 
b4a50c2c00000000
*/
    #1
    reset = 1;
    #2
    reset = 0;
    #2
    in = 64'h 4b657e2ef0d2dfa2;
    load_data = 1;
    #2;
    load_data = 0;

    #34;
    in = 64'h af36b591bbd96c85;
    load_data = 1;
    #2;
    load_data = 0;

    #34;
    in = 64'h 3569faad243d6fa4;
    load_data = 1;
    #2;
    load_data = 0;

    #34;
    if (result !== 32'h b4a50c2c)
      begin $display("E"); $finish; end
    $display("OK");

/* Reset in processing
845fbd32d185bbf2 387172424b8518a3 ba95eadaa69ed200 
7acc77a200000000
*/
    reset = 1;
    #2
    reset = 0;
    #2
    in = 64'h 4b657e2ef0d2dfa2;
    load_data = 1;
    #2;
    load_data = 0;
    #10
    reset = 1;
    #2
    reset = 0;

    #4
    in = 64'h 845fbd32d185bbf2;
    load_data = 1;
    #2;
    load_data = 0;

    #34;
    in = 64'h 387172424b8518a3;
    load_data = 1;
    #2;
    load_data = 0;

    #34;
    in = 64'h ba95eadaa69ed200;
    load_data = 1;
    #2;
    load_data = 0;

    #34;
    if (result !== 32'h 7acc77a2)
      begin $display("E"); $finish; end
    $display("OK");

/* Start with reset
ba3d8a2c8fe0307a c1fe2bf562c45b53 c066169b334014e0 
c9541f2800000000
*/
    #2
    in = 64'h ba3d8a2c8fe0307a;
    load_data = 1;
    reset = 1;
    #2;
    load_data = 0;
    reset = 0;

    #34;
    in = 64'h c1fe2bf562c45b53;
    load_data = 1;
    #2;
    load_data = 0;

    #34;
    in = 64'h c066169b334014e0;
    load_data = 1;
    #2;
    load_data = 0;

    #34;
    if (result !== 32'h c9541f28)
      begin $display("E"); $finish; end
    $display("OK");

    #10;
    $display("All passed");
    $finish;
  end
endmodule
