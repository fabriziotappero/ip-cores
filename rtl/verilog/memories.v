//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Versatile library, memories                                 ////
////                                                              ////
////  Description                                                 ////
////  memories                                                    ////
////                                                              ////
////                                                              ////
////  To Do:                                                      ////
////   - add more memory types                                    ////
////                                                              ////
////  Author(s):                                                  ////
////      - Michael Unneback, unneback@opencores.org              ////
////        ORSoC AB                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2010 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

`ifdef ROM_INIT
/// ROM
`define MODULE rom_init
module `BASE`MODULE ( adr, q, clk);
`undef MODULE

   parameter data_width = 32;
   parameter addr_width = 8;
   parameter mem_size = 1<<addr_width;
   input [(addr_width-1):0] 	 adr;
   output reg [(data_width-1):0] q;
   input 			 clk;
   reg [data_width-1:0] rom [mem_size-1:0];
   parameter memory_file = "vl_rom.vmem";
   initial
     begin
	$readmemh(memory_file, rom);
     end
   
   always @ (posedge clk)
     q <= rom[adr];

endmodule
`endif

`ifdef RAM
`define MODULE ram
// Single port RAM
module `BASE`MODULE ( d, adr, we, q, clk);
`undef MODULE

   parameter data_width = 32;
   parameter addr_width = 8;
   parameter mem_size = 1<<addr_width;
   parameter debug = 0;
   input [(data_width-1):0]      d;
   input [(addr_width-1):0] 	 adr;
   input 			 we;
   output reg [(data_width-1):0] q;
   input 			 clk;
   reg [data_width-1:0] ram [mem_size-1:0];
   
    parameter memory_init = 0;
    parameter memory_file = "vl_ram.vmem";
    generate
    if (memory_init == 1) begin : init_mem
        initial
            $readmemh(memory_file, ram);
   end else if (memory_init == 2) begin : init_zero
        integer k;
        initial
            for (k = 0; k < mem_size; k = k + 1)
                ram[k] = 0;
   end
   endgenerate 
   
    generate
    if (debug==1) begin : debug_we
        always @ (posedge clk)
        if (we)
            $display ("Value %h written at address %h : time %t", d, adr, $time);
        
    end
    endgenerate
    
   always @ (posedge clk)
   begin
   if (we)
     ram[adr] <= d;
   q <= ram[adr];
   end

endmodule
`endif

`ifdef RAM_BE
`define MODULE ram_be
module `BASE`MODULE ( d, adr, be, we, q, clk);
`undef MODULE

   parameter data_width = 32;
   parameter addr_width = 6;
   parameter mem_size = 1<<addr_width;
   input [(data_width-1):0]      d;
   input [(addr_width-1):0] 	 adr;
   input [(data_width/8)-1:0]    be;
   input 			 we;
   output reg [(data_width-1):0] q;
   input 			 clk;

    
//E2_ifdef SYSTEMVERILOG
    // use a multi-dimensional packed array
    //t o model individual bytes within the word
    logic [data_width/8-1:0][7:0] ram [0:mem_size-1];// # words = 1 << address width
//E2_else
    reg [data_width-1:0] ram [mem_size-1:0];
    wire [data_width/8-1:0] cke;
//E2_endif

    parameter memory_init = 0;
    parameter memory_file = "vl_ram.vmem";
    generate
    if (memory_init == 1) begin : init_mem
        initial
            $readmemh(memory_file, ram);
    end else if (memory_init == 2) begin : init_zero
        integer k;
        initial
            for (k = 0; k < mem_size; k = k + 1)
                ram[k] = 0;
    end
   endgenerate 

//E2_ifdef SYSTEMVERILOG

always_ff@(posedge clk)
begin
    if(we) begin
        if(be[3]) ram[adr][3] <= d[31:24];
        if(be[2]) ram[adr][2] <= d[23:16];
        if(be[1]) ram[adr][1] <= d[15:8];
        if(be[0]) ram[adr][0] <= d[7:0];
    end
        q <= ram[adr];
end

//E2_else

assign cke = {data_width/8{we}} & be;
   genvar i;
   generate for (i=0;i<data_width/8;i=i+1) begin : be_ram
      always @ (posedge clk)
      if (cke[i])
        ram[adr][(i+1)*8-1:i*8] <= d[(i+1)*8-1:i*8];
   end
   endgenerate

   always @ (posedge clk)
      q <= ram[adr];

//E2_endif

//E2_ifdef verilator
   // Function to access RAM (for use by Verilator).
   function [31:0] get_mem;
      // verilator public
      input [addr_width-1:0] 		addr;
      get_mem = ram[addr];
   endfunction // get_mem

   // Function to write RAM (for use by Verilator).
   function set_mem;
      // verilator public
      input [addr_width-1:0] 		addr;
      input [data_width-1:0] 		data;
      ram[addr] = data;
   endfunction // set_mem
//E2_endif

endmodule
`endif

`ifdef DPRAM_1R1W
`define MODULE dpram_1r1w
module `BASE`MODULE ( d_a, adr_a, we_a, clk_a, q_b, adr_b, clk_b );
`undef MODULE
   parameter data_width = 32;
   parameter addr_width = 8;
   parameter mem_size = 1<<addr_width;
   input [(data_width-1):0]      d_a;
   input [(addr_width-1):0] 	 adr_a;
   input [(addr_width-1):0] 	 adr_b;
   input 			 we_a;
   output reg [(data_width-1):0] 	 q_b;
   input 			 clk_a, clk_b;
   reg [data_width-1:0] ram [0:mem_size-1] `SYN_NO_RW_CHECK;

    parameter memory_init = 0;
    parameter memory_file = "vl_ram.vmem";
    parameter debug = 0;
    
    generate
    if (memory_init == 1) begin : init_mem
        initial
            $readmemh(memory_file, ram);
    end else if (memory_init == 2) begin : init_zero
        integer k;
        initial
            for (k = 0; k < mem_size; k = k + 1)
                ram[k] = 0;
    end
   endgenerate 

    generate
    if (debug==1) begin : debug_we
        always @ (posedge clk_a)
        if (we_a)
            $display ("Debug: Value %h written at address %h : time %t", d_a, adr_a, $time);
        
    end
    endgenerate

   always @ (posedge clk_a)
   if (we_a)
     ram[adr_a] <= d_a;

   always @ (posedge clk_b)
      q_b = ram[adr_b];
   
endmodule
`endif

`ifdef DPRAM_2R1W
`define MODULE dpram_2r1w
module `BASE`MODULE ( d_a, q_a, adr_a, we_a, clk_a, q_b, adr_b, clk_b );
`undef MODULE

   parameter data_width = 32;
   parameter addr_width = 8;
   parameter mem_size = 1<<addr_width;
   input [(data_width-1):0]      d_a;
   input [(addr_width-1):0] 	 adr_a;
   input [(addr_width-1):0] 	 adr_b;
   input 			 we_a;
   output [(data_width-1):0] 	 q_b;
   output reg [(data_width-1):0] q_a;
   input 			 clk_a, clk_b;
   reg [(data_width-1):0] 	 q_b;   
   reg [data_width-1:0] ram [0:mem_size-1] `SYN_NO_RW_CHECK;

    parameter memory_init = 0;
    parameter memory_file = "vl_ram.vmem";
    parameter debug = 0;
    
    generate
    if (memory_init == 1) begin : init_mem
        initial
            $readmemh(memory_file, ram);
    end else if (memory_init == 2) begin : init_zero
        integer k;
        initial
            for (k = 0; k < mem_size; k = k + 1)
                ram[k] = 0;
    end
   endgenerate 

    generate
    if (debug==1) begin : debug_we
        always @ (posedge clk_a)
        if (we_a)
            $display ("Debug: Value %h written at address %h : time %t", d_a, adr_a, $time);
        
    end
    endgenerate

   always @ (posedge clk_a)
     begin 
	q_a <= ram[adr_a];
	if (we_a)
	     ram[adr_a] <= d_a;
     end 
   always @ (posedge clk_b)
	  q_b <= ram[adr_b];
endmodule
`endif

`ifdef DPRAM_1R2W
`define MODULE dpram_1r2w
module `BASE`MODULE ( d_a, q_a, adr_a, we_a, clk_a, d_b, adr_b, we_b, clk_b );
`undef MODULE

   parameter data_width = 32;
   parameter addr_width = 8;
   parameter mem_size = 1<<addr_width;
   input [(data_width-1):0]      d_a;
   input [(addr_width-1):0] 	 adr_a;
   input [(addr_width-1):0] 	 adr_b;
   input 			 we_a;
   input [(data_width-1):0] 	 d_b;
   output reg [(data_width-1):0] q_a;
   input 			 we_b;
   input 			 clk_a, clk_b;
   reg [(data_width-1):0] 	 q_b;   
   reg [data_width-1:0] ram [0:mem_size-1] `SYN_NO_RW_CHECK;

    parameter memory_init = 0;
    parameter memory_file = "vl_ram.vmem";
    parameter debug = 0;
    
    generate
    if (memory_init == 1) begin : init_mem
        initial
            $readmemh(memory_file, ram);
    end else if (memory_init == 2) begin : init_zero
        integer k;
        initial
            for (k = 0; k < mem_size; k = k + 1)
                ram[k] = 0;
    end
   endgenerate 

    generate
    if (debug==1) begin : debug_we
        always @ (posedge clk_a)
        if (we_a)
            $display ("Debug: Value %h written at address %h : time %t", d_a, adr_a, $time);
        always @ (posedge clk_b)
        if (we_b)
            $display ("Debug: Value %h written at address %h : time %t", d_b, adr_b, $time);        
    end
    endgenerate

   always @ (posedge clk_a)
     begin 
	q_a <= ram[adr_a];
	if (we_a)
	     ram[adr_a] <= d_a;
     end 
   always @ (posedge clk_b)
     begin 
	if (we_b)
	  ram[adr_b] <= d_b;
     end
endmodule
`endif

`ifdef DPRAM_2R2W
`define MODULE dpram_2r2w
module `BASE`MODULE ( d_a, q_a, adr_a, we_a, clk_a, d_b, q_b, adr_b, we_b, clk_b );
`undef MODULE

   parameter data_width = 32;
   parameter addr_width = 8;
   parameter mem_size = 1<<addr_width;
   input [(data_width-1):0]      d_a;
   input [(addr_width-1):0] 	 adr_a;
   input [(addr_width-1):0] 	 adr_b;
   input 			 we_a;
   output [(data_width-1):0] 	 q_b;
   input [(data_width-1):0] 	 d_b;
   output reg [(data_width-1):0] q_a;
   input 			 we_b;
   input 			 clk_a, clk_b;
   reg [(data_width-1):0] 	 q_b;   
   reg [data_width-1:0] ram [0:mem_size-1] `SYN_NO_RW_CHECK;

    parameter memory_init = 0;
    parameter memory_file = "vl_ram.vmem";
    parameter debug = 0;
    
    generate
    if (memory_init) begin : init_mem
        initial
            $readmemh(memory_file, ram);
    end else if (memory_init == 2) begin : init_zero
        integer k;
        initial
            for (k = 0; k < mem_size; k = k + 1)
                ram[k] = 0;
    end
   endgenerate 

    generate
    if (debug==1) begin : debug_we
        always @ (posedge clk_a)
        if (we_a)
            $display ("Debug: Value %h written at address %h : time %t", d_a, adr_a, $time);
        always @ (posedge clk_b)
        if (we_b)
            $display ("Debug: Value %h written at address %h : time %t", d_b, adr_b, $time);        
    end
    endgenerate

   always @ (posedge clk_a)
     begin 
	q_a <= ram[adr_a];
	if (we_a)
	     ram[adr_a] <= d_a;
     end 
   always @ (posedge clk_b)
     begin 
	q_b <= ram[adr_b];
	if (we_b)
	  ram[adr_b] <= d_b;
     end
endmodule
`endif


`ifdef DPRAM_BE_2R2W
`define MODULE dpram_be_2r2w
module `BASE`MODULE ( d_a, q_a, adr_a, be_a, we_a, clk_a, d_b, q_b, adr_b, be_b, we_b, clk_b );
`undef MODULE

   parameter a_data_width = 32;
   parameter a_addr_width = 8;
   parameter b_data_width = 64; //a_data_width;
   //localparam b_addr_width = a_data_width * a_addr_width / b_data_width;
   localparam b_addr_width = 
	(a_data_width==b_data_width) ? a_addr_width : 
	(a_data_width==b_data_width*2) ? a_addr_width+1 : 
	(a_data_width==b_data_width*4) ? a_addr_width+2 : 
	(a_data_width==b_data_width*8) ? a_addr_width+3 : 
	(a_data_width==b_data_width*16) ? a_addr_width+4 : 
	(a_data_width==b_data_width*32) ? a_addr_width+5 : 
	(a_data_width==b_data_width/2) ? a_addr_width-1 : 
	(a_data_width==b_data_width/4) ? a_addr_width-2 : 
	(a_data_width==b_data_width/8) ? a_addr_width-3 : 
	(a_data_width==b_data_width/16) ? a_addr_width-4 : 
	(a_data_width==b_data_width/32) ? a_addr_width-5 : 0;

   localparam ratio = (a_addr_width>b_addr_width) ? (a_addr_width/b_addr_width) : (b_addr_width/a_addr_width);
   parameter mem_size = (a_addr_width>b_addr_width) ? (1<<b_addr_width) : (1<<a_addr_width);

   parameter memory_init = 0;
   parameter memory_file = "vl_ram.vmem";
   parameter debug = 0;
   
   input [(a_data_width-1):0]      d_a;
   input [(a_addr_width-1):0] 	   adr_a;
   input [(a_data_width/8-1):0]    be_a;
   input 			   we_a;
   output reg [(a_data_width-1):0] q_a;
   input [(b_data_width-1):0] 	   d_b;
   input [(b_addr_width-1):0] 	   adr_b;
   input [(b_data_width/8-1):0]    be_b;
   input 			   we_b;
   output reg [(b_data_width-1):0] 	   q_b;
   input 			   clk_a, clk_b;

    generate
    if (debug==1) begin : debug_we
        always @ (posedge clk_a)
        if (we_a)
            $display ("Debug: Value %h written on port A at address %h : time %t", d_a, adr_a, $time);
        always @ (posedge clk_b)
        if (we_b)
            $display ("Debug: Value %h written on port B at address %h : time %t", d_b, adr_b, $time);        
    end
    endgenerate


//E2_ifdef SYSTEMVERILOG
// use a multi-dimensional packed array
//to model individual bytes within the word

generate
if (a_data_width==32 & b_data_width==32) begin : dpram_3232

    logic [0:3][7:0] ram [0:mem_size-1] `SYN_NO_RW_CHECK;
    
    initial
        if (memory_init==1)
            $readmemh(memory_file, ram);
            
    integer k;
    initial
        if (memory_init==2)
            for (k = 0; k < mem_size; k = k + 1)
                ram[k] = 0;

    always_ff@(posedge clk_a)
    begin
        if(we_a) begin
            if(be_a[3]) ram[adr_a][0] <= d_a[31:24];
            if(be_a[2]) ram[adr_a][1] <= d_a[23:16];
            if(be_a[1]) ram[adr_a][2] <= d_a[15:8];
            if(be_a[0]) ram[adr_a][3] <= d_a[7:0];
        end
    end
    
    always@(posedge clk_a)
        q_a = ram[adr_a];
    
    always_ff@(posedge clk_b)
    begin
        if(we_b) begin
            if(be_b[3]) ram[adr_b][0] <= d_b[31:24];
            if(be_b[2]) ram[adr_b][1] <= d_b[23:16];
            if(be_b[1]) ram[adr_b][2] <= d_b[15:8];
            if(be_b[0]) ram[adr_b][3] <= d_b[7:0];
        end
    end
    
    always@(posedge clk_b)
        q_b = ram[adr_b];

end
endgenerate

generate
if (a_data_width==64 & b_data_width==64) begin : dpram_6464

    logic [0:7][7:0] ram [0:mem_size-1] `SYN_NO_RW_CHECK;
    
    initial
        if (memory_init==1)
            $readmemh(memory_file, ram);
            
    integer k;
    initial
        if (memory_init==2)
            for (k = 0; k < mem_size; k = k + 1)
                ram[k] = 0;

    always_ff@(posedge clk_a)
    begin
        if(we_a) begin
            if(be_a[7]) ram[adr_a][7] <= d_a[63:56];
            if(be_a[6]) ram[adr_a][6] <= d_a[55:48];
            if(be_a[5]) ram[adr_a][5] <= d_a[47:40];
            if(be_a[4]) ram[adr_a][4] <= d_a[39:32];
            if(be_a[3]) ram[adr_a][3] <= d_a[31:24];
            if(be_a[2]) ram[adr_a][2] <= d_a[23:16];
            if(be_a[1]) ram[adr_a][1] <= d_a[15:8];
            if(be_a[0]) ram[adr_a][0] <= d_a[7:0];
        end
    end
    
    always@(posedge clk_a)
        q_a = ram[adr_a];
    
    always_ff@(posedge clk_b)
    begin
        if(we_b) begin
            if(be_b[7]) ram[adr_b][7] <= d_b[63:56];
            if(be_b[6]) ram[adr_b][6] <= d_b[55:48];
            if(be_b[5]) ram[adr_b][5] <= d_b[47:40];
            if(be_b[4]) ram[adr_b][4] <= d_b[39:32];
            if(be_b[3]) ram[adr_b][3] <= d_b[31:24];
            if(be_b[2]) ram[adr_b][2] <= d_b[23:16];
            if(be_b[1]) ram[adr_b][1] <= d_b[15:8];
            if(be_b[0]) ram[adr_b][0] <= d_b[7:0];
        end
    end
    
    always@(posedge clk_b)
        q_b = ram[adr_b];

end
endgenerate

generate
if (a_data_width==32 & b_data_width==16) begin : dpram_3216
logic [31:0] temp;
`define MODULE dpram_be_2r2w
`BASE`MODULE # (.a_data_width(32), .b_data_width(32), .a_addr_width(a_addr_width), .mem_size(mem_size), .memory_init(memory_init), .memory_file(memory_file))
`undef MODULE
dpram3232 (
    .d_a(d_a),
    .q_a(q_a),
    .adr_a(adr_a),
    .be_a(be_a),
    .we_a(we_a),
    .clk_a(clk_a),
    .d_b({d_b,d_b}),
    .q_b(temp),
    .adr_b(adr_b[b_addr_width-1:1]),
    .be_b({be_b,be_b} & {{2{!adr_b[0]}},{2{adr_b[0]}}}),
    .we_b(we_b),
    .clk_b(clk_b)
);

always @ (adr_b[0] or temp)
    if (adr_b[0])
        q_b = temp[31:16];
    else
        q_b = temp[15:0];
        
end
endgenerate

generate
if (a_data_width==32 & b_data_width==64) begin : dpram_3264
logic [63:0] temp;
`define MODULE dpram_be_2r2w
`BASE`MODULE # (.a_data_width(32), .b_data_width(64), .a_addr_width(a_addr_width), .mem_size(mem_size), .memory_init(memory_init), .memory_file(memory_file))
`undef MODULE
dpram6464 (
    .d_a({d_a,d_a}),
    .q_a(temp),
    .adr_a(adr_a[a_addr_width-1:1]),
    .be_a({be_a,be_a} & {{4{adr_a[0]}},{4{!adr_a[0]}}}),
    .we_a(we_a),
    .clk_a(clk_a),
    .d_b(d_b),
    .q_b(q_b),
    .adr_b(adr_b),
    .be_b(be_b),
    .we_b(we_b),
    .clk_b(clk_b)
);

always @ (adr_a[0] or temp)
    if (adr_a[0])
        q_a = temp[63:32];
    else
        q_a = temp[31:0];
        
end
endgenerate

//E2_else
    // This modules requires SystemVerilog
    // at this point anyway
//E2_endif
endmodule
`endif

`ifdef CAM
// Content addresable memory, CAM
`endif

`ifdef FIFO_1R1W_FILL_LEVEL_SYNC
// FIFO
`define MODULE fifo_1r1w_fill_level_sync
module `BASE`MODULE (
`undef MODULE
    d, wr, fifo_full,
    q, rd, fifo_empty,
    fill_level,
    clk, rst
    );
    
parameter data_width = 18;
parameter addr_width = 4;

// write side
input  [data_width-1:0] d;
input                   wr;
output                  fifo_full;
// read side
output [data_width-1:0] q;
input                   rd;
output                  fifo_empty;
// common
output [addr_width:0]   fill_level;
input rst, clk;

wire [addr_width:1] wadr, radr;

`define MODULE cnt_bin_ce
`BASE`MODULE
    # ( .length(addr_width))
    fifo_wr_adr( .cke(wr), .q(wadr), .rst(rst), .clk(clk));
`BASE`MODULE
    # (.length(addr_width))
    fifo_rd_adr( .cke(rd), .q(radr), .rst(rst), .clk(clk));
`undef MODULE

`define MODULE dpram_1r1w
`BASE`MODULE
    # (.data_width(data_width), .addr_width(addr_width))
    dpram ( .d_a(d), .adr_a(wadr), .we_a(wr), .clk_a(clk), .q_b(q), .adr_b(radr), .clk_b(clk));
`undef MODULE

`define MODULE cnt_bin_ce_rew_q_zq_l1
`BASE`MODULE
    # (.length(addr_width+1), .level1_value(1<<addr_width))
    fill_level_cnt( .cke(rd ^ wr), .rew(rd), .q(fill_level), .zq(fifo_empty), .level1(fifo_full), .rst(rst), .clk(clk));
`undef MODULE
endmodule
`endif

`ifdef FIFO_2R2W_SYNC_SIMPLEX
// Intended use is two small FIFOs (RX and TX typically) in one FPGA RAM resource
// RAM is supposed to be larger than the two FIFOs
// LFSR counters used adr pointers
`define MODULE fifo_2r2w_sync_simplex
module `BASE`MODULE (
`undef MODULE
    // a side
    a_d, a_wr, a_fifo_full,
    a_q, a_rd, a_fifo_empty,
    a_fill_level,
    // b side
    b_d, b_wr, b_fifo_full,
    b_q, b_rd, b_fifo_empty,
    b_fill_level,
    // common
    clk, rst	
    );
parameter data_width = 8;
parameter addr_width = 5;
parameter fifo_full_level = (1<<addr_width)-1;

// a side
input  [data_width-1:0] a_d;
input                   a_wr;
output                  a_fifo_full;
output [data_width-1:0] a_q;
input                   a_rd;
output                  a_fifo_empty;
output [addr_width-1:0] a_fill_level;

// b side
input  [data_width-1:0] b_d;
input                   b_wr;
output                  b_fifo_full;
output [data_width-1:0] b_q;
input                   b_rd;
output                  b_fifo_empty;
output [addr_width-1:0] b_fill_level;

input                   clk;
input                   rst;

// adr_gen
wire [addr_width:1] a_wadr, a_radr;
wire [addr_width:1] b_wadr, b_radr;
// dpram
wire [addr_width:0] a_dpram_adr, b_dpram_adr;

`define MODULE cnt_lfsr_ce
`BASE`MODULE
    # ( .length(addr_width))
    fifo_a_wr_adr( .cke(a_wr), .q(a_wadr), .rst(rst), .clk(clk));
    
`BASE`MODULE
    # (.length(addr_width))
    fifo_a_rd_adr( .cke(a_rd), .q(a_radr), .rst(rst), .clk(clk));

`BASE`MODULE
    # ( .length(addr_width))
    fifo_b_wr_adr( .cke(b_wr), .q(b_wadr), .rst(rst), .clk(clk));
    
`BASE`MODULE
    # (.length(addr_width))
    fifo_b_rd_adr( .cke(b_rd), .q(b_radr), .rst(rst), .clk(clk));
`undef MODULE

// mux read or write adr to DPRAM
assign a_dpram_adr = (a_wr) ? {1'b0,a_wadr} : {1'b1,a_radr};
assign b_dpram_adr = (b_wr) ? {1'b1,b_wadr} : {1'b0,b_radr};

`define MODULE dpram_2r2w
`BASE`MODULE
    # (.data_width(data_width), .addr_width(addr_width+1))
    dpram ( .d_a(a_d), .q_a(a_q), .adr_a(a_dpram_adr), .we_a(a_wr), .clk_a(a_clk), 
            .d_b(b_d), .q_b(b_q), .adr_b(b_dpram_adr), .we_b(b_wr), .clk_b(b_clk));
`undef MODULE

`define MODULE cnt_bin_ce_rew_zq_l1
`BASE`MODULE
    # (.length(addr_width), .level1_value(fifo_full_level))
    a_fill_level_cnt( .cke(a_rd ^ a_wr), .rew(a_rd), .q(a_fill_level), .zq(a_fifo_empty), .level1(a_fifo_full), .rst(rst), .clk(clk));

`BASE`MODULE
    # (.length(addr_width), .level1_value(fifo_full_level))
    b_fill_level_cnt( .cke(b_rd ^ b_wr), .rew(b_rd), .q(b_fill_level), .zq(b_fifo_empty), .level1(b_fifo_full), .rst(rst), .clk(clk));
`undef MODULE

endmodule
`endif

`ifdef FIFO_CMP_ASYNC
`define MODULE fifo_cmp_async
module `BASE`MODULE ( wptr, rptr, fifo_empty, fifo_full, wclk, rclk, rst );
`undef MODULE

   parameter addr_width = 4;   
   parameter N = addr_width-1;

   parameter Q1 = 2'b00;
   parameter Q2 = 2'b01;
   parameter Q3 = 2'b11;
   parameter Q4 = 2'b10;

   parameter going_empty = 1'b0;
   parameter going_full  = 1'b1;
   
   input [N:0]  wptr, rptr;   
   output 	fifo_empty;
   output       fifo_full;
   input 	wclk, rclk, rst;   

`ifndef GENERATE_DIRECTION_AS_LATCH   
   wire direction;
`endif
`ifdef GENERATE_DIRECTION_AS_LATCH
   reg direction;
`endif
   reg 	direction_set, direction_clr;
   
   wire async_empty, async_full;
   wire fifo_full2;
   wire fifo_empty2;   
   
   // direction_set
   always @ (wptr[N:N-1] or rptr[N:N-1])
     case ({wptr[N:N-1],rptr[N:N-1]})
       {Q1,Q2} : direction_set <= 1'b1;
       {Q2,Q3} : direction_set <= 1'b1;
       {Q3,Q4} : direction_set <= 1'b1;
       {Q4,Q1} : direction_set <= 1'b1;
       default : direction_set <= 1'b0;
     endcase

   // direction_clear
   always @ (wptr[N:N-1] or rptr[N:N-1] or rst)
     if (rst)
       direction_clr <= 1'b1;
     else
       case ({wptr[N:N-1],rptr[N:N-1]})
	 {Q2,Q1} : direction_clr <= 1'b1;
	 {Q3,Q2} : direction_clr <= 1'b1;
	 {Q4,Q3} : direction_clr <= 1'b1;
	 {Q1,Q4} : direction_clr <= 1'b1;
	 default : direction_clr <= 1'b0;
       endcase

`define MODULE dff_sr
`ifndef GENERATE_DIRECTION_AS_LATCH
    `BASE`MODULE dff_sr_dir( .aclr(direction_clr), .aset(direction_set), .clock(1'b1), .data(1'b1), .q(direction));
`endif

`ifdef GENERATE_DIRECTION_AS_LATCH
   always @ (posedge direction_set or posedge direction_clr)
     if (direction_clr)
       direction <= going_empty;
     else
       direction <= going_full;
`endif

   assign async_empty = (wptr == rptr) && (direction==going_empty);
   assign async_full  = (wptr == rptr) && (direction==going_full);

    `BASE`MODULE dff_sr_empty0( .aclr(rst), .aset(async_full), .clock(wclk), .data(async_full), .q(fifo_full2));
    `BASE`MODULE dff_sr_empty1( .aclr(rst), .aset(async_full), .clock(wclk), .data(fifo_full2), .q(fifo_full));
`undef MODULE

/*
   always @ (posedge wclk or posedge rst or posedge async_full)
     if (rst)
       {fifo_full, fifo_full2} <= 2'b00;
     else if (async_full)
       {fifo_full, fifo_full2} <= 2'b11;
     else
       {fifo_full, fifo_full2} <= {fifo_full2, async_full};
*/
/*   always @ (posedge rclk or posedge async_empty)
     if (async_empty)
       {fifo_empty, fifo_empty2} <= 2'b11;
     else
       {fifo_empty,fifo_empty2} <= {fifo_empty2,async_empty}; */
`define MODULE dff
    `BASE`MODULE # ( .reset_value(1'b1)) dff0 ( .d(async_empty), .q(fifo_empty2), .clk(rclk), .rst(async_empty));
    `BASE`MODULE # ( .reset_value(1'b1)) dff1 ( .d(fifo_empty2), .q(fifo_empty),  .clk(rclk), .rst(async_empty));
`undef MODULE
endmodule // async_compb
`endif

`ifdef FIFO_1R1W_ASYNC
`define MODULE fifo_1r1w_async
module `BASE`MODULE (
`undef MODULE
    d, wr, fifo_full, wr_clk, wr_rst,
    q, rd, fifo_empty, rd_clk, rd_rst
    );
    
parameter data_width = 18;
parameter addr_width = 4;

// write side
input  [data_width-1:0] d;
input                   wr;
output                  fifo_full;
input                   wr_clk;
input                   wr_rst;
// read side
output [data_width-1:0] q;
input                   rd;
output                  fifo_empty;
input                   rd_clk;
input                   rd_rst;

wire [addr_width:1] wadr, wadr_bin, radr, radr_bin;

`define MODULE cnt_gray_ce_bin
`BASE`MODULE
    # ( .length(addr_width))
    fifo_wr_adr( .cke(wr), .q(wadr), .q_bin(wadr_bin), .rst(wr_rst), .clk(wr_clk));
    
`BASE`MODULE
    # (.length(addr_width))
    fifo_rd_adr( .cke(rd), .q(radr), .q_bin(radr_bin), .rst(rd_rst), .clk(rd_clk));
`undef MODULE

`define MODULE dpram_1r1w
`BASE`MODULE
    # (.data_width(data_width), .addr_width(addr_width))
    dpram ( .d_a(d), .adr_a(wadr_bin), .we_a(wr), .clk_a(wr_clk), .q_b(q), .adr_b(radr_bin), .clk_b(rd_clk));
`undef MODULE

`define MODULE fifo_cmp_async
`BASE`MODULE
    # (.addr_width(addr_width))
    cmp ( .wptr(wadr), .rptr(radr), .fifo_empty(fifo_empty), .fifo_full(fifo_full), .wclk(wr_clk), .rclk(rd_clk), .rst(wr_rst) );
`undef MODULE

endmodule
`endif

`ifdef FIFO_2R2W_ASYNC
`define MODULE fifo_2r2w_async
module `BASE`MODULE (
`undef MODULE
    // a side
    a_d, a_wr, a_fifo_full,
    a_q, a_rd, a_fifo_empty, 
    a_clk, a_rst,
    // b side
    b_d, b_wr, b_fifo_full,
    b_q, b_rd, b_fifo_empty, 
    b_clk, b_rst	
    );
    
parameter data_width = 18;
parameter addr_width = 4;

// a side
input  [data_width-1:0] a_d;
input                   a_wr;
output                  a_fifo_full;
output [data_width-1:0] a_q;
input                   a_rd;
output                  a_fifo_empty;
input                   a_clk;
input                   a_rst;

// b side
input  [data_width-1:0] b_d;
input                   b_wr;
output                  b_fifo_full;
output [data_width-1:0] b_q;
input                   b_rd;
output                  b_fifo_empty;
input                   b_clk;
input                   b_rst;

`define MODULE fifo_1r1w_async
`BASE`MODULE # (.data_width(data_width), .addr_width(addr_width))
vl_fifo_1r1w_async_a (
    .d(a_d), .wr(a_wr), .fifo_full(a_fifo_full), .wr_clk(a_clk), .wr_rst(a_rst),
    .q(b_q), .rd(b_rd), .fifo_empty(b_fifo_empty), .rd_clk(b_clk), .rd_rst(b_rst)
    );

`BASE`MODULE # (.data_width(data_width), .addr_width(addr_width))
vl_fifo_1r1w_async_b (
    .d(b_d), .wr(b_wr), .fifo_full(b_fifo_full), .wr_clk(b_clk), .wr_rst(b_rst),
    .q(a_q), .rd(a_rd), .fifo_empty(a_fifo_empty), .rd_clk(a_clk), .rd_rst(a_rst)
    );
`undef MODULE

endmodule
`endif

`ifdef FIFO_2R2W_ASYNC_SIMPLEX
`define MODULE fifo_2r2w_async_simplex
module `BASE`MODULE (
`undef MODULE
    // a side
    a_d, a_wr, a_fifo_full,
    a_q, a_rd, a_fifo_empty, 
    a_clk, a_rst,
    // b side
    b_d, b_wr, b_fifo_full,
    b_q, b_rd, b_fifo_empty, 
    b_clk, b_rst	
    );
    
parameter data_width = 18;
parameter addr_width = 4;

// a side
input  [data_width-1:0] a_d;
input                   a_wr;
output                  a_fifo_full;
output [data_width-1:0] a_q;
input                   a_rd;
output                  a_fifo_empty;
input                   a_clk;
input                   a_rst;

// b side
input  [data_width-1:0] b_d;
input                   b_wr;
output                  b_fifo_full;
output [data_width-1:0] b_q;
input                   b_rd;
output                  b_fifo_empty;
input                   b_clk;
input                   b_rst;

// adr_gen
wire [addr_width:1] a_wadr, a_wadr_bin, a_radr, a_radr_bin;
wire [addr_width:1] b_wadr, b_wadr_bin, b_radr, b_radr_bin;
// dpram
wire [addr_width:0] a_dpram_adr, b_dpram_adr;

`define MODULE cnt_gray_ce_bin
`BASE`MODULE
    # ( .length(addr_width))
    fifo_a_wr_adr( .cke(a_wr), .q(a_wadr), .q_bin(a_wadr_bin), .rst(a_rst), .clk(a_clk));
    
`BASE`MODULE
    # (.length(addr_width))
    fifo_a_rd_adr( .cke(a_rd), .q(a_radr), .q_bin(a_radr_bin), .rst(a_rst), .clk(a_clk));

`BASE`MODULE
    # ( .length(addr_width))
    fifo_b_wr_adr( .cke(b_wr), .q(b_wadr), .q_bin(b_wadr_bin), .rst(b_rst), .clk(b_clk));
    
`BASE`MODULE
    # (.length(addr_width))
    fifo_b_rd_adr( .cke(b_rd), .q(b_radr), .q_bin(b_radr_bin), .rst(b_rst), .clk(b_clk));
`undef MODULE

// mux read or write adr to DPRAM
assign a_dpram_adr = (a_wr) ? {1'b0,a_wadr_bin} : {1'b1,a_radr_bin};
assign b_dpram_adr = (b_wr) ? {1'b1,b_wadr_bin} : {1'b0,b_radr_bin};

`define MODULE dpram_2r2w
`BASE`MODULE
    # (.data_width(data_width), .addr_width(addr_width+1))
    dpram ( .d_a(a_d), .q_a(a_q), .adr_a(a_dpram_adr), .we_a(a_wr), .clk_a(a_clk), 
            .d_b(b_d), .q_b(b_q), .adr_b(b_dpram_adr), .we_b(b_wr), .clk_b(b_clk));
`undef MODULE

`define MODULE fifo_cmp_async
`BASE`MODULE
    # (.addr_width(addr_width))
    cmp1 ( .wptr(a_wadr), .rptr(b_radr), .fifo_empty(b_fifo_empty), .fifo_full(a_fifo_full), .wclk(a_clk), .rclk(b_clk), .rst(a_rst) );

`BASE`MODULE
    # (.addr_width(addr_width))
    cmp2 ( .wptr(b_wadr), .rptr(a_radr), .fifo_empty(a_fifo_empty), .fifo_full(b_fifo_full), .wclk(b_clk), .rclk(a_clk), .rst(b_rst) );
`undef MODULE

endmodule
`endif

`ifdef REG_FILE
`define MODULE reg_file
module `BASE`MODULE (
`undef MODULE
    a1, a2, a3, wd3, we3, rd1, rd2, clk, rst );
parameter dw = 32;
parameter aw = 5;
parameter debug = 0;
input [aw-1:0] a1, a2, a3;
input [dw-1:0] wd3;
input we3;
output [dw-1:0] rd1, rd2;
input clk, rst;
wire [dw-1:0] rd1mem, rd2mem;
reg [dw-1:0] wreg;
reg sel1, sel2;

generate
if (debug==1) begin : debug_we
    always @ (posedge clk)
        if (we3)
            $display ("Value %h written at register %h : time %t", wd3, a3, $time);
end
endgenerate

`define MODULE dpram_1r1w
`BASE`MODULE
    # ( .data_width(dw), .addr_width(aw))
    ram1 (
        .d_a(wd3),
        .adr_a(a3),
        .we_a(we3),
        .clk_a(clk),
        .q_b(rd1mem),
        .adr_b(a1),
        .clk_b(clk) );
        
`BASE`MODULE
    # ( .data_width(dw), .addr_width(aw))
    ram2 (
        .d_a(wd3),
        .adr_a(a3),
        .we_a(we3),
        .clk_a(clk),
        .q_b(rd2mem),
        .adr_b(a2),
        .clk_b(clk) );
`undef MODULE

always @ (posedge clk or posedge rst)
if (rst)
    {sel1, sel2, wreg} <= {1'b0,1'b0,{dw{1'b0}}};
else
    {sel1,sel2,wreg} <= {we3 & a1==a3, we3 & a2==a3,wd3};
assign rd1 = (sel1) ? wreg : rd1mem;
assign rd2 = (sel2) ? wreg : rd2mem;

endmodule
`endif
