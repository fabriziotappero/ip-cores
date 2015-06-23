/* Testbench for memory
   SXP Processor
   Sam Gladstone
*/
`timescale 1ns / 1ns
`include "../src/dpmem.v"

module mem_test();

reg clk;
reg reset_b;
reg [31:0] addra;
reg [31:0] addrb;
reg [31:0] da;
reg [31:0] db;
reg oea;
reg oeb;
reg wea;
reg web;

wire [31:0] qa;
wire [31:0] qb;

integer i;
integer errors;

dpmem #(32,1024) i_dpmem(.clk(clk),
		.reset_b(reset_b),
		.addra(addra),				// address a port
		.addrb(addrb),				// address b port
	        .wea(wea),				// write enable a
	        .web(web),				// write enable b
	        .oea(oea),				// output enable a
	        .oeb(oeb),				// output enable b
		.da(da),				// data input a
		.db(db),				// data input b
		
		.qa(qa),				// data output a
		.qb(qb));				// data output b


initial
  begin
    clk = 1'b 0;
    #10 forever #2.5 clk = ~clk;
  end

initial
  begin
    errors = 0;
    wea = 1'b 0;
    web = 1'b 0;
    oea = 1'b 0;
    oeb = 1'b 0;
    addra = 32'b 0;
    addrb = 32'b 0;
    da = 32'b 0;
    db = 32'b 0;

    @(negedge clk);
    reset_b = 1'b 1;
    @(negedge clk);
    reset_b = 1'b 0;
    @(negedge clk);
    reset_b = 1'b 1;
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);

    // Test out port A functionality

    $display ("Writing 1024 numbers to port A");
    wea = 1'b 1;
    for (i=0;i<1024;i=i+1)
      begin
        addra = i;
        da = i;
        @(negedge clk);
      end

    $display ("Verifying 1024 numbers from port A ");
    wea = 1'b 0;
    oea = 1'b 1;
    for (i=0;i<1024;i=i+1)
      begin
        addra = i;
        @(negedge clk);
        @(posedge clk);
        if (qa!==addra)
          begin
            $display ("Port A: Address %d had a problem, value was %d",addra,qa);
            errors = errors + 1;
          end
      end

    // Test out port B functionality

    $display ("Writing 1024 numbers to port B");
    web = 1'b 1;
    for (i=0;i<1024;i=i+1)
      begin
        addrb = i;
        db = i+i;		// Let's write something different 2*i
        @(negedge clk);
      end

    $display ("Verifying 1024 numbers from port B ");
    web = 1'b 0;
    oeb = 1'b 1;
    for (i=0;i<1024;i=i+1)
      begin
        addrb = i;
        @(negedge clk);
        @(posedge clk);
        if (qb!==(addrb+addrb))
          begin
            $display ("Port B: Address %d had a problem, value was %d",addrb,qb);
            errors = errors + 1;
          end
      end

    oea = 1'b 1;
    oeb = 1'b 1;
    web = 1'b 1;
    wea = 1'b 0;
    addra = 32'd 23;
    addrb = 32'd 23;
    db = 32'd 1234;
    
    @(negedge clk);
      
    $display ("Writing B while reading A at same address"); 
    $display ("addra = %d, qa = %d, addrb = %d, qb = %d",addra,qa,addrb,qb);
 
    $display ("There were %d errors with memory test",errors); 
    $finish; 
  end

endmodule

/*  $Id: test_mem.v,v 1.1 2001-10-28 03:21:06 samg Exp $ 
 *  Module : mem_test 
 *  Author : Sam Gladstone 
 *  Function : testbench for dual port memory behavioral models 
 *  $Log: not supported by cvs2svn $
 */

