`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:       Universidad Pontificia Bolivariana
// Engineer:      Fabio Andres Guzman Figueroa
// 
// Create Date:    11:31:15 05/17/2012 
// Design Name:    
// Module Name:    pong_top_level
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module pong_top_level(
    input clk,
    input rst,
	 input up1, down1, up2, down2,
	 output hs,vs,
	 output r,g,b
    );


wire [7:0] data_in;
wire [7:0] port_addr;
wire [7:0] data_out;
wire write_e;

reg [3:0] sw;
reg rst_ext;
reg [6:0] col;
reg [5:0] row;
reg [2:0] color;
reg we;

wire [12:0] addr_write, addr_read;
wire [3:0] doutb;
wire [2:0] color_out;
wire [7:0] mem_out;


always@(posedge clk)
	if (rst_ext==1 || rst==1)
		sw<=0;
	else
		begin
			if (up1) 	sw[0]<=1'b1;
			if (down1)  sw[1]<=1'b1;
			if (up2)    sw[2]<=1'b1;
			if (down2)  sw[3]<=1'b1;
		end 
		
//col register  (addr=32)
always@(posedge clk or posedge rst)
	if (rst)
		col<=0;
	else
		if (port_addr[7:5]==3'b001 && write_e==1)
			col<=data_out[6:0];
			
			
//row register (addr=64)
always@(posedge clk or posedge rst)
	if (rst)
		row<=0;
	else
		if (port_addr[7:5]==3'b010 && write_e==1)
			row<=data_out[5:0];
			

//color register (addr=96)
always@(posedge clk or posedge rst)
	if (rst)
		color<=0;
	else
		if (port_addr[7:5]==3'b011 && write_e==1)
			color<=data_out[2:0];
			
//we register (addr=160)
always@(posedge clk or posedge rst)
	if (rst)
		we<=0;
	else
		if (port_addr[7:5]==3'b101 && write_e==1)
			we<=data_out[0];			
			
//rst_ext register (addr=128)
always@(posedge clk or posedge rst)
	if (rst)
		rst_ext<=0;
	else
		if (port_addr[7:5]==3'b100 && write_e==1)
			rst_ext<=data_out[0];

assign data_in=(port_addr[7:5]==000) ? mem_out : {4'b0000,sw}; 						

assign addr_write={row, col};

natalius_processor processor(clk,rst,port_addr,read_e,write_e,data_in,data_out);
memram ram_memory(clk,data_out,port_addr[4:0],mem_out,write_e);
mem_video video_mem(clk,we,addr_write,addr_read,{1'b0,color},doutb);
vga_control video_cntrl(clk,rst,doutb[2:0],hs,vs,color_out,addr_read);

assign r=color_out[2];
assign g=color_out[1];
assign b=color_out[0];

endmodule
