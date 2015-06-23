`timescale 1ns/1ns
module wbm (
  output [31:0] adr_o,
  output [1:0] bte_o,
  output [2:0] cti_o,
  output [31:0] dat_o,
  output [3:0] sel_o,
  output we_o,
  output cyc_o,
  output stb_o,
  input wire [31:0] dat_i,
  input wire ack_i,
  input wire clk,
  input wire reset,
  output reg OK
);

	parameter [1:0] linear = 2'b00,
               		beat4  = 2'b01,
               		beat8  = 2'b10,
               		beat16 = 2'b11;
                		
    parameter [2:0] classic = 3'b000,
                    inc     = 3'b010,
                    eob		= 3'b111;

	parameter instructions = 32; 

	// {adr_o,bte_o,cti_o,dat_o,sel_o,we_o,cyc_o,stb_o}	
	parameter [32+2+3+32+4+1+1+1:1] inst_rom [0:instructions-1]= {
		{32'h0,linear,classic,32'h0,4'b1111,1'b0,1'b0,1'b0},
		
		{32'h100,linear,classic,32'h12345678,4'b1111,1'b1,1'b1,1'b1}, // write 0x12345678 @ 0x100
		{32'h100,linear,classic,32'h0,4'b1111,1'b0,1'b1,1'b1},        // read  @ 0x100
		
		{32'h0,linear,classic,32'h0,4'b1111,1'b0,1'b0,1'b0},
		
		{32'hA000,beat4,inc,32'h00010002,4'b1111,1'b1,1'b1,1'b1}, // write burst
		{32'hA004,beat4,inc,32'h00030004,4'b1111,1'b1,1'b1,1'b1},
		{32'hA008,beat4,inc,32'h00050006,4'b1111,1'b1,1'b1,1'b1},
		{32'hA00C,beat4,eob,32'h00070008,4'b1111,1'b1,1'b1,1'b1},
		
		{32'hA008,linear,classic,32'hA1FFFFFF,4'b1000,1'b1,1'b1,1'b1},// write byte
		
		{32'hA000,beat4,inc,32'h0,4'b1111,1'b0,1'b1,1'b1}, // read burst
		{32'hA004,beat4,inc,32'h0,4'b1111,1'b0,1'b1,1'b1},
		{32'hA008,beat4,inc,32'h0,4'b1111,1'b0,1'b1,1'b1},
		{32'hA00C,beat4,eob,32'h0,4'b1111,1'b0,1'b1,1'b1},
		
		{32'h1000,linear,inc,32'hdeaddead,4'b1111,1'b1,1'b1,1'b1}, // write
		{32'h1004,linear,eob,32'h55555555,4'b1111,1'b1,1'b1,1'b1}, //
		
		{32'h1000,linear,inc,32'h0,4'b1111,1'b0,1'b1,1'b1}, // read
		{32'h1004,linear,eob,32'h0,4'b1111,1'b0,1'b1,1'b1}, // read
		
		{32'hA008,beat4,inc,32'h0,4'b1111,1'b0,1'b1,1'b1}, // read burst
		{32'hA00C,beat4,inc,32'h0,4'b1111,1'b0,1'b1,1'b1},
		{32'hA000,beat4,inc,32'h0,4'b1111,1'b0,1'b1,1'b1},
		{32'hA004,beat4,eob,32'h0,4'b1111,1'b0,1'b1,1'b1},
		
		{32'h0,linear,classic,32'h0,4'b1111,1'b0,1'b0,1'b0},
		{32'h0,linear,classic,32'h0,4'b1111,1'b0,1'b0,1'b0},
		{32'h0,linear,classic,32'h0,4'b1111,1'b0,1'b0,1'b0},
		{32'h0,linear,classic,32'h0,4'b1111,1'b0,1'b0,1'b0},
		{32'h0,linear,classic,32'h0,4'b1111,1'b0,1'b0,1'b0},
		{32'h0,linear,classic,32'h0,4'b1111,1'b0,1'b0,1'b0},
		{32'h0,linear,classic,32'h0,4'b1111,1'b0,1'b0,1'b0},
		{32'h0,linear,classic,32'h0,4'b1111,1'b0,1'b0,1'b0},
		{32'h0,linear,classic,32'h0,4'b1111,1'b0,1'b0,1'b0},
		{32'h0,linear,classic,32'h0,4'b1111,1'b0,1'b0,1'b0}};
		
	parameter [31:0] dat [0:instructions-1] = {
		32'h0,
		32'h0,
		32'h0,
		32'h12345678,
		32'h0,
		32'h0,
		32'h0,
		32'h0,
		32'h0,
		32'h0,
		32'h00010002,
		32'h00030004,
		32'ha1050006,
		32'h00070008,
		32'h0,
		32'h0,
		32'hdeaddead,
		32'h55555555,
		32'ha1050006,
		32'h00070008,
		32'h00010002,
		32'h00030004,
		32'h0,
		32'h0,
		32'h0,
		32'h0,
		32'h0,
		32'h0,
		32'h0,
		32'h0,
		32'h0,
		32'h0,
		32'h0};
  	
//	parameter idle   = 1'b0;
//	parameter active = 1'b1;
//	
//	reg state;
	
  	integer i;
                
	assign {adr_o,bte_o,cti_o,dat_o,sel_o,we_o,cyc_o,stb_o} = inst_rom[i];
	
	always @ (posedge clk or posedge reset)
	if (reset)
		i = 0;
	else
		if ((!stb_o | ack_i) & i < instructions - 1)
			i = i + 1;

	always @ (posedge clk or posedge reset)
	if (reset)
		OK <= 1'b1;
	else
		if (ack_i & !we_o & (dat_i != dat[i])) begin
			OK <= 1'b0;
			$display ("wrong read value %h @ %h at %t", dat_i, adr_o, $time);
		end else if (ack_i & !we_o & (dat_i == dat[i]))
			$display ("read value  %h      @ %h at %t", dat_i, adr_o, $time);
		else if (ack_i)
			$display ("write value %h %b @ %h at %t", dat_o, sel_o, adr_o, $time);
			
//	always @ (posedge clk or posedge reset)
//	if (reset)
//		state <= idle;
//	else
//		if (state==idle & cyc_o)
//			state <= active;
//		else if ((cti_o==3'b000 | cti_o==3'b111) & cyc_o & stb_o & ack_i)
//			state <= idle;
  
endmodule
