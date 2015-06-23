`timescale 1us/1ns
// This is the main execution unit and ALU
// Handles all the instructions except for JMP and TAC
// (note that the JMP return address is here
// but main execution is in the top.v module)

// Inputs: clock, phase, bug (program counter)
// databus (inout), instruction register, reset, input buttons/switches
// Outputs: memory address, memwrite, sign (for TAC), halt, output display

module alu(input clk, input [3:0] phase, input [7:0] bug, inout [12:0] dbus, input [11:0] ir, output [7:0] memadd, output reg memwrite, output sign, output reg halt, input rst,
	output segA, output segB, output segC, output segD, output segE, output segF, output segG,
	output ds0, output ds1, output ds2, output ds3, input _pb0, input _pb1, input _pb2, input [7:0] sw);

   reg [16:0] acc;  // accumulator
   wire [16:0] result; // adder output
	wire pb0, pb1, pb2;  // debounced switches
    
   // select input or output devices
   reg 	       isel, osel;
   
// virtual input and output devices   
   io_input       in(clk, isel,dbus,rst,sw);
   io_output out(clk,osel,dbus, rst, segA, segB, segC, segD, segE, segF, segG, ds0, ds1, ds2, ds3);

// setup for simulation / reset  
   initial memwrite=0;
   initial isel=0;
   initial osel=0;
	initial halt=0;

// send sign for TAC instruction
   assign sign=acc[16];
   
// Location 99 is the one level return stack
// so we have to drive 99 to the address bus on a JMP
// But usually the mem address is the bottom two digits of the instruction   
   assign memadd=(ir[11:8]==4'b1000 && memwrite==1'b1)?8'h99:ir[7:0];

// Drive return address to dbus for JMP
   assign dbus=(ir[11:8]==4'b1000 && memwrite==1'b1)?{ 5'b01000, bug}:13'bz;
   
// Drive accumulator on bus for STO
   assign dbus=(ir[11:8]==4'b0110 && memwrite==1'b1)?{acc[16], acc[11:0]}:13'bz;
   
	// debounce input switches
   debounce swprocess0(clk, rst, _pb0, pb0);
   debounce swprocess1(clk, rst, _pb1, pb1);
	debounce swprocess2(clk, rst, _pb2, pb2);

// Add or subtract
   bcdadd adder(acc,{(ir[11:8]==4'b0111)?~dbus[12]:dbus[12] ,dbus[11:0]},result);

// This is where instructions are actually executed
   always @(posedge clk)
     begin
	if (rst==1'b0)  // do nothing if in reset
	case (ir[11:8])
	  4'b0000:   // INP
	    begin
	       if (phase==4'b0100)
		    begin
		      isel<=1'b1;  // drive input on bus and write
  		      memwrite<=1'b1;
		    end
	       if (phase==4'b1000)
		     begin
		      isel<=1'b0;   // back to normal state
		       memwrite<=1'b0;
		     end
	    end
	  4'b0001:   // CLA (store memory address to accumumlator)
	    begin
	       if (phase==4'b1000)
		       acc<={dbus[12], 4'b0, dbus[11:0]};   // note sign extension NOT needed here! 
	    end
	  4'b0010:     // ADD
	    begin
	       if (phase==4'b1000)  // the adder already did it, just store it
		         acc<=result;
	    end

	  4'b0011:;     // TAC -- all handled in vtach.v
	  4'b0100:     // SFT (extended to do input too)
	    begin
	       case (ir[7:4])
		 4'b0000: ;  // no shift left
		 4'b0001: acc<={acc[16], acc[11:0],4'b0};
		 4'b0010: acc<={acc[16], acc[7:0],8'b0};
		 4'b0011: acc<={acc[16], acc[3:0],12'b0};
		 4'b1000: acc<={ 9'b0, sw };  // load switches
		 4'b1001: acc<={pb0, 16'b1 }; // special instruction - set sign to input button
		 default: acc<={acc[16], 16'b0};
	       endcase // case (ir[7:4])
	       case (ir[3:0])
		 4'b0000: ; // no right shift
		 4'b0001: acc<={acc[16], 4'b0, acc[15:4]};
		 4'b0010: acc<={acc[16], 8'b0, acc[15:8]};
		 4'b0011: acc<={acc[16], 12'b0, acc[15:12]};
		 4'b1000: acc<={ pb1, 16'b1};
		 4'b1001: acc<={pb2, 16'b1 }; 
		 default: acc<={acc[16],16'b0}; 
	       endcase // case (ir[3:0])
	    end
	    
	  4'b0101:   // OUT
	    begin
	       // tell output unit to do its thing
	    if (phase==4'b0100) osel<=1'b1;
  	    if (phase==4'b1000) osel<=1'b0; 
	    end
	  4'b0110:   // STO
	  begin
	  // Set up memory for write cycle
	     if (phase==4'b0100) memwrite<=1'b1;
	     if (phase==4'b1000) memwrite<=1'b0;
	  end
	  4'b0111:   // SUB
	    begin
	       if (phase==4'b1000)
		        acc<=result;  // adder already did it, so just grab the result
	    end

	  4'b1000:  // JMP
	    begin
	       if (phase==4'b0100)
		    begin
		    memwrite<=1'b1;  // save return address
		    end
	       if (phase==4'b1000)
		    begin
		    memwrite<=1'b0;  // done
		    end
// note top actually does the jump
	    end

  // including 9, halt and reset (HRS)
          default: halt<=1'b1;

   endcase
	else    // in reset
	begin
	  memwrite<=1'b0;
     isel<=1'b0;
     osel<=1'b0;
	  halt<=1'b0;
	end
  end
   
endmodule
