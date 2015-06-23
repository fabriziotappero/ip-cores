/* Interupt Controller module testbench
   SXP Processor
   Sam Gladstone
*/

`timescale 1ns / 1ns
`include "../src/int_cont.v"

module test_int_cont(); 

reg clk;
reg reset_b;
reg halt;
reg int_req;
reg [15:0] int_num;
reg safe_switch;
reg nop_detect;

wire int_rdy;
wire idle;
wire int_srv_req;
wire jal_req;
wire [15:0] int_srv_num;

integer i;
integer clk_cnt;


initial
  begin
    clk = 1'b 0;
    clk_cnt = 0;
    #10 forever
      begin
        #2.5 clk = ~clk;
        if (clk)
          begin
            clk_cnt = clk_cnt + 1;
            $display ("R Clk");
          end
      end
  end

int_cont i_int_cont(
		.clk(clk),			// system clock
		.reset_b(reset_b),		// system reset
                .halt(halt),			// processor halt signal
                .int_req(int_req),		// signal that an interupt is requested
		.int_num(int_num),		// interupt number that is being requested
		.safe_switch(safe_switch),	// signal that processor is safe to switch
                .nop_detect(nop_detect),	// signal that the processor just executed a NOP instruction

                .int_rdy(int_rdy),		// 1 when int req will be serviced when requested 
                .idle(idle),		// signal to idle processor;
                .jal_req(jal_req),		// signal to fetch to insert the JAL instruction
		.int_srv_req(int_srv_req),	// signal that the interupt was serviced 
                .int_srv_num(int_srv_num));	// interupt number that was serviced

initial
  begin
    $dumpfile("./icarus.vcd");
    $dumpvars(1,i_int_cont);
  end

initial
  begin
    halt = 1'b 0;
    int_req = 1'b 0;
    int_num = 1'b 0;
    safe_switch = 1'b 0;
    nop_detect = 1'b 0;

    reset_b = 1'b 1;
    @(negedge clk);
    reset_b = 1'b 0;
    @(negedge clk);
    reset_b = 1'b 1;
     
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);

    // Start with interupt request
    $display ("Asserting request line");
    int_req = 1'b 1;
    int_num = 16'd 16;
    @(negedge clk);
    int_num = 16'b 0;
    int_req = 1'b 0;
    // Next rdy line should drop and idle goes high
    @(negedge clk);
    $display ("nop_cnt = %d",i_int_cont.nop_cnt);
    @(negedge clk);
    $display ("nop_cnt = %d",i_int_cont.nop_cnt);
    @(negedge clk);
    $display ("nop_cnt = %d",i_int_cont.nop_cnt);
    safe_switch = 1'b 1;
    $display ("Bringing safe switch high");
    @(negedge clk);
    $display ("nop_cnt = %d",i_int_cont.nop_cnt);
    nop_detect = 1'b 1;
    $display ("Bringing nop_detect high");
    @(negedge clk);
    $display ("nop_cnt = %d",i_int_cont.nop_cnt);
    @(negedge clk);
    $display ("nop_cnt = %d",i_int_cont.nop_cnt);
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);
    $finish;
  end

always @(negedge clk)
  begin
    $display ("state = %d, idle = %b, jal_req = %b, int_rdy = %b",i_int_cont.state,idle,jal_req,int_rdy);
  end

endmodule


/*  $Id: test_int_cont.v,v 1.1 2001-10-28 17:02:03 samg Exp $ 
 *  Module : test_int_cont
 *  Author : Sam Gladstone
 *  Function : testbench for SXP interupt controller
 *  $Log: not supported by cvs2svn $
 */
