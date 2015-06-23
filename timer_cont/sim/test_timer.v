/* Test Timer controller

*/
`include "../src/timer_cont.v"
module test_timer ();

reg clk;
reg reset_b;
reg set_reg;
reg [7:0] reg_num;
 
wire timer_signal;

integer i;
integer k;

timer_cont i_timer_cont(
		  .clk(clk),			// System clock
		  .reset_b(reset_b),		// system reset
		  .set_reg(set_reg),		// signal to set regulator value
		  .reg_num(reg_num),		// value to set regulator to
		  
		  .signal(signal));		// signal that goes to processor

initial
  begin
    $dumpfile("./icarus.vcd");
    $dumpvars(0, i_timer_cont);
  end

initial
  begin
    clk = 1'b 0;
    #10 forever #2.5 clk = ~clk;
  end

initial
  begin
    set_reg = 1'b 0;
    reset_b = 1'b 1;
    @(negedge clk);
    reset_b = 1'b 0;
    @(negedge clk);
    reset_b = 1'b 1;
    @(negedge clk);
 
    for (i=0;i<256;i=i+1)
      begin
        $display ("On set num %d",i);
        set_reg = 1'b 1;
        reg_num = i;
        @(negedge clk);
        set_reg = 1'b 0;
        @(negedge clk);
        for (k=0;k<256;k=k+1)
          @(negedge clk);
      end
    $finish;
  end
endmodule

/*
 *  $Id: test_timer.v,v 1.1 2001-10-29 06:10:18 samg Exp $ 
 *  Module : test_timer
 *  Author : Sam Gladstone
 *  Function : testbench for programable timer cicuit
 *  $Log: not supported by cvs2svn $
 */
