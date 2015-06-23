/* Test alu module 
 *
 * Bob Hoffman
 *
 */

`timescale 1ns / 1ns
`include "../src/alu_r.v"
`define a_max 10
`define b_max 100

module test_alu(); 

reg clk;
reg [2:0] opcode;
reg [31:0] a;
reg [31:0] b;
reg [31:0] a_exp;
reg [31:0] b_exp;
reg cin;

wire [31:0] b_se;
wire [31:0] ya;
wire [31:0] yb;
reg [31:0] ya_exp;
reg [31:0] yb_exp;
wire [3:0] cvnz_a;
wire [3:0] cvnz_b;
reg [3:0] cvnz_a_exp;
reg [3:0] cvnz_b_exp;

integer i, j, k;
reg [31:0] expected;

alu  i_alu  ( .opcode(opcode),                        // alu function select 
              .a(a),                                  // a operand 
              .b(b),                                  // b operand 
              .cin(cin),                              // carry input 
              .ya(ya),                                // data output a
              .yb(yb),                                // data output b
              .cvnz_a(cvnz_a),                        // a output flags
              .cvnz_b(cvnz_b)                         // b output flags
              );

assign b_se = {{16{b[15]}}, b[15:0]};

initial
  begin
    $dumpfile("./icarus.vcd");
    $dumpvars(2, i_alu);
  end


initial
  begin
    clk = 1'b 0;
    #10 forever #2.5 clk = ~clk;
  end


initial
  begin
    opcode = 3'd 0;
    a = 32'd 0;
    b = 32'd 0;
    cin = 1'b 0;
    @(negedge clk);


    $display("testing alu pass through...");

    opcode = 3'd 0;

    for (i=0;i<`a_max;i=i+1)
      begin
	a = i;
        for (j=0;j<`b_max;j=j+1)
	  begin
	    b = j;
	    ya_exp = a;
	    yb_exp = b;
            @(negedge clk);
	    if(ya != ya_exp || yb != yb_exp)
	      $display("a=%d, b=%d, ya=%d, ya_exp=%d, yb=%d, yb_exp=%d", a, b, ya, ya_exp, yb, yb_exp);
	  end
      end


    $display("testing alu adder...");

    opcode = 3'd 1;

    for (i=0;i<`a_max;i=i+1)
      begin
	a = i;
        for (j=0;j<`b_max;j=j+1)
	  begin
	    b = j;
	    ya_exp = a + b;
	    yb_exp = a + b_se;
            @(negedge clk);
	    if(ya != ya_exp || yb != yb_exp)
	      $display("a=%d, b=%d, ya=%d, ya_exp=%d, yb=%d, yb_exp=%d", a, b, ya, ya_exp, yb, yb_exp);
	  end
      end
    $display("  checking overflow conditions...");
    a = 32'h 7fff_ffff;
    b = 32'h 0000_0000;
    cin = 1'b 1;
    ya_exp = a + b + cin;
    yb_exp = a + b_se + cin;
    cvnz_a_exp = 4'b 0110;
    cvnz_b_exp = 4'b 0110;
    @(negedge clk);
    if(cvnz_a != cvnz_a_exp || cvnz_b != cvnz_b_exp)
      begin
	$display("a=%h, b=%h, cin=%h, ya=%h, ya_exp=%h", a, b, cin, ya, ya_exp);
	$display("a=%h, b=%h, cin=%h, yb=%h, yb_exp=%h", a, b, cin, yb, yb_exp);
        $display("cvnz_a=%b, exp=%b, cvnz_b=%b, exp=%b", cvnz_a, cvnz_a_exp, cvnz_b, cvnz_b_exp);
      end
    @(negedge clk);

    $display("testing alu subtractor...");

    opcode = 3'd 2;
    cin = 1'b 0;

    for (i=0;i<`a_max;i=i+1)
      begin
	a = i;
        for (j=0;j<`b_max;j=j+1)
	  begin
	    b = j;
	    ya_exp = a - b;
	    yb_exp = a - b_se;
            @(negedge clk);
	    if(ya != ya_exp || yb != yb_exp)
	      $display("a=%d, b=%d, ya=%d, ya_exp=%d, yb=%d, yb_exp=%d", a, b, ya, ya_exp, yb, yb_exp);
	  end
      end

    $display("testing alu mult...");

    opcode = 3'd 3;

    for (i=0;i<`a_max;i=i+1)
      begin
	a = i;
        for (j=0;j<`b_max;j=j+1)
	  begin
	    b = j;
	    {yb_exp, ya_exp} = a * b;
            @(negedge clk);
	    if(ya != ya_exp || yb != yb_exp)
	      $display("a=%d, b=%d, ya=%d, ya_exp=%d, yb=%d, yb_exp=%d", a, b, ya, ya_exp, yb, yb_exp);
	  end
      end

    $display("testing alu and/or...");

    opcode = 3'd 4;

    for (i=0;i<`a_max;i=i+1)
      begin
	a = i;
        for (j=0;j<`b_max;j=j+1)
	  begin
	    b = j;
	    ya_exp = a & b;
	    yb_exp = a | b;
            @(negedge clk);
	    if(ya != ya_exp || yb != yb_exp)
	      $display("a=%d, b=%d, ya=%d, ya_exp=%d, yb=%d, yb_exp=%d", a, b, ya, ya_exp, yb, yb_exp);
	  end
      end

    $display("testing alu xor/xnor...");

    opcode = 3'd 5;

    for (i=0;i<`a_max;i=i+1)
      begin
	a = i;
        for (j=0;j<`b_max;j=j+1)
	  begin
	    b = j;
	    ya_exp = a ^ b;
	    yb_exp = ~ya_exp;
            @(negedge clk);
	    if(ya != ya_exp || yb != yb_exp)
	      $display("a=%d, b=%d, ya=%d, ya_exp=%d, yb=%d, yb_exp=%d", a, b, ya, ya_exp, yb, yb_exp);
	  end
      end

    $display("testing alu flipped pass through...");

    opcode = 3'd 7;

    for (i=0;i<`a_max;i=i+1)
      begin
	a = i;
        for (j=0;j<`b_max;j=j+1)
	  begin
	    b = j;
	    ya_exp = {a[15:0],a[31:16]};
	    yb_exp = {b[15:0],b[31:16]};
            @(negedge clk);
	    if(ya != ya_exp || yb != yb_exp)
	      $display("a=%d, b=%d, ya=%d, ya_exp=%d, yb=%d, yb_exp=%d", a, b, ya, ya_exp, yb, yb_exp);
	  end
      end



    $finish;    
  end

endmodule


/*
 *  $Id: test_alu.v,v 1.1 2001-10-26 21:41:16 bobh Exp $
 *  Module : test_alu.v
 *  Scope : Arithmetic Logic Unit Testbench
 *  Author : Bob Hoffman
 *  Function : Testbench for Arithmetic Logic Unit
 *
 *  Issues :
 *
 *  $Log: not supported by cvs2svn $
 *
 */
