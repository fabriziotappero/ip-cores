`timescale 1us/1ns

// Vtach - A Verilog implementation of CARDIAC
// Target: Digilent Spartan 3 Board
// Al Williams, DDJ, May 2013

// This is the main CPU module
// inputs are the main clock, external reset, push buttons, and switches
// Outputs are the 7 segment display (segX and dsN) and the 8 discrete LEDs
module top(input clk,input extreset,
	output segA, output segB, output segC, output segD, output segE, output segF, output segG,
	output ds0, output ds1, output ds2, output ds3, output [7:0] led, input pb0, input pb1, input pb2, input [7:0] sw);

   reg addsource;  // pick memory address source
   reg memoe;    // memory output enable 1
   wire memwrite;  // assert to write to memory
	wire clkls;   // low speed clock from DLL (still too high)
	reg reset;    // internal reset signal
	
	
   reg [7:0] bug;   // the program counter
   reg [3:0] clkphase;  // 4 or 5 phase 1 hot counter
   reg [11:0] ir;   // instruction register
   wire [12:0] dbus;  // data bus
   wire [7:0]  memaddr;  // memory address to memory
   wire [7:0]  memadd;  // address from execution unit
   
   wire [7:0]  bugplus1;  // bug + 1
   wire        acsign;  // accumulator sign (for TAC)
	
	 
 // addsource=1 then instruction, 0 then bug
   assign memaddr=addsource?memadd:bug; 

   wire        xmemoe;  // memory output enable to memory
	wire haltflag;  // don't advance clock when halted
	
	// The DLL can only go down to 18MHz which is still too fast
	// This divides by two to allow the DLL to run at 32MHz
	// clk1 should be 1/2 the clk2 (memory clock)
	// Would be better to supply a slower clock or
	// Use clock enables to "tone down" the speed
	// But at these relatively slow speeds this works ok
	reg clkdiv;   
	wire clk1, clk2;
	assign clk1=clkdiv;  // 16 MHz
	assign clk2=clkls;  // 32MHz
	
	always @(posedge clkls) clkdiv<=~clkdiv;  // Divide clock by 2
	
	
	
	
// tell memory to drive the bus unless not memoe or if writing 
// except in phase 2 (instruction fetch)
   assign xmemoe=memoe && (~memwrite  || clkphase==4'b0010) ;
   
// Main memory (100 words)
   memory mem(clk2,memaddr,dbus,xmemoe,memwrite&~haltflag);
// The adder to advance the bug (program counter)
   bcdincr bugadder(bug,bugplus1);
// Exeuction unit/ALU
   alu execunit(clk1,clkphase,bug,dbus,ir,memadd,memwrite,acsign,haltflag, reset,
	    segA, segB, segC, segD, segE, segF, segG, ds0, ds1, ds2, ds3, pb0, pb1, pb2, sw);

		// Instantiate the DLL clock module
mainclock clockdll (
    .CLKIN_IN(clk), 
    .CLKFX_OUT(clkls),
	 .RST_IN(1'b0)    );

	assign led=memaddr;  // output LEDs

   
// Set up for startup   
   initial clkphase=4'b0;
   initial addsource=1'b0;
   initial memoe=1'b0;
   initial bug=0;
   initial reset=1'b1;
   initial ir=12'b100000000000;
   
	



		
// generate clock -- must be sure clkphase is set to 1 or 0 on power up
   always @(posedge clk1)
     begin
	  if (clkphase==4'b0 || (haltflag && ~extreset)) 
		clkphase<=4'b1;
	  else
	  // cycle 0001 -> 1000 
	    clkphase<={clkphase[2:0],clkphase[3]};
		 // sync external reset
		 if (clkphase==4'b0100 && extreset==1'b0 && reset==1'b1) reset<=1'b0;
		 if (clkphase==4'b1000 && extreset==1'b1) reset<=1'b1;
     end
   
// manage each cycle
   always @(posedge clk1)
     begin
	if (reset==1'b0)
	case (clkphase)
	  4'b0001:
	    begin  // get next instruction
	       addsource<=1'b0;
	       memoe<=1'b1;
	       end
	  4'b0010:
	    begin   // store it and get memory operand on bus, bug++
	       ir<=dbus;
	       addsource<=1'b1;
	       bug<=bugplus1;
	    end
	  
	  4'b0100:
	    begin
	       // alu does command so not much to do here now
	    end

	  4'b1000:   // store result
	    begin
// Jump instruction
	       if (ir[11:8]==4'b1000) bug<=ir[7:0];
// TAC instruction
	       if (acsign==1'b1 && ir[11:8]==4'b0011) bug<=ir[7:0];
	    end
	   
	  default:
	    begin
	    end
	endcase
	 else  // in reset
	 begin
      addsource<=1'b0;
      memoe<=1'b0;
      bug<=8'b0;
		ir<=12'b100000000000; 
	 end

  end
   
  

   
endmodule // top


   
   
