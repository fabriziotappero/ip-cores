`include "timescale.v"

//                              -*- Mode: Verilog -*-
// Filename        : wb_master.v
// Description     : Wishbone Master Behavorial
// Author          : Winefred Washington
// Created On      : Thu Jan 11 21:18:41 2001
// Last Modified By: .
// Last Modified On: .
// Update Count    : 0
// Status          : Unknown, Use with caution!

//        Description                   Specification
// General Description:            8, 16, 32-bit WISHBONE Master
// Supported cycles:               MASTER, READ/WRITE
//                                 MASTER, BLOCK READ/WRITE
//                                 MASTER, RMW
// Data port, size:                8, 16, 32-bit
// Data port, granularity          8-bit
// Data port, Max. operand size    32-bit
// Data transfer ordering:         little endian
// Data transfer sequencing:       undefined
//

module wb_master(CLK_I, RST_I, TAG_I, TAG_O,
		   ACK_I, ADR_O, CYC_O, DAT_I, DAT_O, ERR_I, RTY_I, SEL_O, STB_O, WE_O);

   input		CLK_I;
   input		RST_I;
   input [3:0] 		TAG_I;
   output [3:0] 	TAG_O;
   input		ACK_I;
   output [31:0] 	ADR_O;
   output		CYC_O;
   input [31:0] 	DAT_I;
   output [31:0] 	DAT_O;
   input		ERR_I;
   input		RTY_I;
   output [3:0] 	SEL_O;
   output		STB_O;
   output		WE_O;
   
   reg [31:0] 		ADR_O;
   reg [3:0] 		SEL_O;
   reg 			CYC_O;
   reg 			STB_O;
   reg 			WE_O;
   reg [31:0] 		DAT_O;
   
   wire [15:0] 		mem_sizes;      // determines the data width of an address range
   reg [31:0] 		write_burst_buffer[0:7];
   reg [31:0] 		read_burst_buffer[0:7];
   
   reg 			GO;
   integer 		cycle_end;
   integer 		address; 		
   integer 		data;
   integer 		selects;
   integer 		write_flag;
   
   //
   // mem_sizes determines the data widths of memory space
   // The memory space is divided into eight regions. Each
   // region is controlled by a two bit field.
   //
   //    Bits
   //    00 = 8 bit memory space
   //    01 = 16 bit 
   //    10 = 32 bit
   //    11 = 64 bit (not supported in this model
   //
   
   assign 		mem_sizes = 16'b10_01_10_11_00_01_10_11;

   function [1:0] data_width;
      input [31:0] adr;
      begin
	 casex (adr[31:29])
	   3'b000: data_width = mem_sizes[15:14];
	   3'b001: data_width = mem_sizes[13:12];
	   3'b010: data_width = mem_sizes[11:10];
	   3'b011: data_width = mem_sizes[9:8];
	   3'b100: data_width = mem_sizes[7:6];
	   3'b101: data_width = mem_sizes[5:4];
	   3'b110: data_width = mem_sizes[3:2];
	   3'b111: data_width = mem_sizes[1:0];
	   3'bxxx: data_width = 2'bxx;
	 endcase // casex (adr[31:29])
      end
   endfunction
      
   always @(posedge CLK_I or posedge RST_I)
     begin
	if (RST_I)
	  begin
	     GO = 1'b0;
	  end
     end
   
   // read single
   task rd;
      input [31:0] adr;
      output [31:0] result;
      
      begin
	 cycle_end = 1;
	 address = adr;
	 selects = 255;
	 write_flag = 0;
	 
	 GO <= 1;	 
	 @(posedge CLK_I);
//	 GO <= 0;	 

	 // wait for cycle to start
	 while (~CYC_O)
	   @(posedge CLK_I);

	 // wait for cycle to end
	 while (CYC_O)
	   @(posedge CLK_I);

	 result = data;
//	$display(" Reading %h from address %h", result, address);
	 
      end
   endtask // read
   
   task wr;
      input [31:0] adr;
      input [31:0] dat;
      input [3:0] sel;
      begin
	 cycle_end = 1;
	 address = adr;
	 selects = sel;
	 write_flag = 1;
	 data = dat;
	 
	 GO <= 1;	 
	 @(posedge CLK_I);
//	 GO <= 0;	 

	 // wait for cycle to start
	 while (~CYC_O)
	   @(posedge CLK_I);

	 // wait for cycle to end
	 while (CYC_O)
	   @(posedge CLK_I);
//	$display(" Writing %h to address %h", data, address);

      end
   endtask // wr

   // block read
   task blkrd;
      input [31:0] adr;
      input end_flag;
      output [31:0] result;
      
      begin
	 write_flag = 0;
	 cycle_end = end_flag;
	 address = adr;	 
	 GO <= 1;	 
	 @(posedge CLK_I);
//	 GO <= 0;	 

	 while (~(ACK_I & STB_O))
	   @(posedge CLK_I);
	 
	 result = data;
      end
   endtask // blkrd

   // block write
   task blkwr;
      input [31:0] adr;
      input [31:0] dat;
      input [3:0] sel;
      input end_flag;
      begin
	 write_flag = 1;
	 cycle_end = end_flag;
	 address = adr;	 
	 data = dat;
	 selects = sel;
	 GO <= 1;	 
	 @(posedge CLK_I);
//	 GO <= 0;	 

	 while (~(ACK_I & STB_O))
	   @(posedge CLK_I);
	 
      end
   endtask // blkwr

   // RMW
   task rmw;
      input [31:0] adr;
      input [31:0] dat;
      input [3:0] sel;
      output [31:0] result;
      
      begin
	 // read phase
	 write_flag = 0;
	 cycle_end = 0;
	 address = adr;	 
	 GO <= 1;	 
	 @(posedge CLK_I);
//	 GO <= 0;	 

	 while (~(ACK_I & STB_O))
	   @(posedge CLK_I);
	 
	 result = data;

	 // write phase
	 write_flag = 1;
	 address = adr;	 
	 selects = sel;
	 GO <= 1;	 
	 data <= dat;
	 cycle_end <= 1;
	 @(posedge CLK_I);
//	 GO <= 0;	 

	 while (~(ACK_I & STB_O))
	   @(posedge CLK_I);
	 
      end      
   endtask // rmw
   
   always @(posedge CLK_I)
     begin
	if (RST_I)
	  ADR_O <= 32'h0000_0000;
	else
	  ADR_O <= address;	
     end
   
   always @(posedge CLK_I)
     begin
	if (RST_I | ERR_I | RTY_I)
	  CYC_O <= 1'b0;
	else if ((cycle_end == 1) & ACK_I)
	  CYC_O <= 1'b0;
	else if (GO | CYC_O) begin
	  CYC_O <= 1'b1;
	  GO <= 1'b0;
        end
     end

   // stb control
   always @(posedge CLK_I)
     begin
	if (RST_I | ERR_I | RTY_I)
	  STB_O <= 1'b0;
	else if (STB_O & ACK_I)
	  STB_O <= 1'b0;
	else if (GO | STB_O)
	  STB_O <= 1'b1;
     end

   // selects & data
   always @(posedge CLK_I)
     begin
	if (write_flag == 0) begin
	   SEL_O <= 4'b1111;
	   if (STB_O & ACK_I)
	     data <= DAT_I;	   
	end
	else begin
	   case (data_width(address))
	     2'b00: begin
		SEL_O <= {3'b000, selects[0]};
		DAT_O <= {data[7:0], data[7:0], data[7:0], data[7:0]};
	     end
	     2'b01: begin
		SEL_O <= {2'b00, selects[1:0]};
		DAT_O <= {data[15:0], data[15:0]};
	     end
	     2'b10: begin
		SEL_O <= selects;
		DAT_O <= data;
	     end
	   endcase
	end
     end

   always @(posedge CLK_I)
     begin
	if (RST_I)
	  WE_O <= 1'b0;
	else if (GO)
	  WE_O <= write_flag;
     end
   
endmodule





