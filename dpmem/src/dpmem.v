/* Behavioral memory verilog module
   SXP Processor
   Sam Gladstone

   This can not be synthesized!
   The purpose is to emmulate standard dual port memories.
*/


module dpmem (  clk,
		reset_b,
		addra,		// address a port
		addrb,		// address b port
	        wea,		// write enable a
	        web,		// write enable b
	        oea,		// output enable a
	        oeb,		// output enable b
		da,		// data input a
		db,		// data input b
		
		qa,		// data output a
		qb);		// data output b

parameter ADDR_WIDTH = 32;
parameter MEM_SIZE = 1024;

input clk;
input reset_b;
input [ADDR_WIDTH-1:0] addra;
input [ADDR_WIDTH-1:0] addrb;
input wea;
input web;
input oea;
input oeb;
input [31:0] da;
input [31:0] db; 


output [31:0] qa;
output [31:0] qb;

reg [31:0] mem [0:MEM_SIZE-1];

wire [31:0] data_a;
wire [31:0] data_b;

reg [31:0] mem_data_a;
reg [31:0] mem_data_b;

integer i;

wire [31:0] mem_limit;

assign mem_limit = MEM_SIZE-1;

assign qa = (oea) ? data_a : {32{1'b z}}; 
assign qb = (oeb) ? data_b : {32{1'b z}}; 

assign data_a = (wea) ? {32{1'b x}} : mem_data_a;
assign data_b = (web) ? {32{1'b x}} : mem_data_b;

// Checking address a
always @(addra)
  begin
    if ((addra > (MEM_SIZE-1)) && wea)
      $display ("address a = %d, out of range of memory limit (%d)",addra,mem_limit);
  end

// Checking address b
always @(addrb)
  begin
    if ((addrb > (MEM_SIZE-1)) && web)
      $display ("address b = %d, out of range of memory limit (%d)",addrb,mem_limit);
  end

// Reading data from memory port a
always @(posedge clk or negedge reset_b)
  begin
    if (!reset_b)
      mem_data_a <= {32{1'b x}};
    else
      if ((addra==addrb)&&(web==1'b1))		// You cannot write b and read a from the same address
        mem_data_a <= #3 {32{1'bx}};
      else
        mem_data_a <= #3 mem[addra];
  end

// Reading data from memory port b
always @(posedge clk or negedge reset_b)
  begin
    if (!reset_b)
      mem_data_b <= {32{1'b x}};
    else
      if ((addra==addrb)&&(wea==1'b1))		// You cannot write a and read b from the same address
        mem_data_b <= #3 {32{1'bx}};
      else
        mem_data_b <= #3 mem[addrb];
  end

// Writing data to memory
always @(posedge clk or negedge reset_b)
  begin
    if (!reset_b)
      for (i=0;i<MEM_SIZE;i=i+1)
        mem[i] <= {32{1'bx}};
    else
      begin
        if (wea === 1'b 1)
          if (addra<MEM_SIZE)
            mem[addra] <= da;
        if (web === 1'b 1)
          if (addrb<MEM_SIZE)
            mem[addrb] <= db;
      end
  end

task mem_display;
integer rnum;
  begin
    for (rnum=0;rnum<MEM_SIZE;rnum=rnum+1)
      $display("Location %d = %h",rnum,mem[rnum]);
  end
endtask    
endmodule

/*
 *  $Id: dpmem.v,v 1.3 2001-12-05 05:46:00 samg Exp $ 
 *  Module : dpmem
 *  Author : Sam Gladstone 
 *  Function : Simple behavioral module for dual port memories
 *  $Log: not supported by cvs2svn $
 *  Revision 1.2  2001/10/28 03:18:17  samg
 *  array range fix
 *
 *  Revision 1.1  2001/10/26 21:49:59  samg
 *  behavioral dual port memory
 *
 */
