module fifotwoflag(clk, reset, push, full, din, pull, empty, dout, addrw, mdin, write, addrr, mdout);

//`timescale 1ns/100ps

input clk, reset, push, pull;
input [7:0] din, mdout;
output full, empty, write;
output[7:0] dout, mdin;
output[15:0] addrw, addrr;

wire full, empty;

wire write;
wire read;
wire [7:0] dout; 
wire [7:0] mdin;
reg [15:0] addrw, addrr;

//write
assign write = (full) ? 1'b0 : push;
assign mdin = din;

//write address
always @(posedge clk or posedge reset)
begin
if(reset) begin
addrw <= 16'h0;
end
else if(write == 1'b1)
addrw <= #1 addrw + 1;
end

//read
assign read = empty ? 1'b0 : pull;
assign dout = mdout;

//read address
always @(posedge clk or posedge reset)
begin
if(reset)
addrr <= 16'h0;
else if(read == 1'b1)
addrr <= #1 addrr + 1;
end

//Full
assign full = ( (addrw+1) == addrr);
//Empty
assign empty = (addrw == addrr);

endmodule  
  
