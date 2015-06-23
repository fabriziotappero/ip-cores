/*
Project        : AES
Standard doc.  : FIPS 197
Module name    : SubBytes block
Dependancy     :
Design doc.    : 
References     : 
Description    : uses SBox module to substitute every bytein the 128bit data
Owner          : Amr Salah
*/

`timescale 1 ns/1 ps

module SubBytes
#
(
 parameter DATA_W = 128,       //data width
 parameter NO_BYTES = DATA_W >> 3  //no of bytes = data width / 8
)
(
input clk,                     //system clock
input reset,                   //asynch active low reset
input valid_in,                //input valid signal  
input [DATA_W-1:0] data_in,    //input data
output reg valid_out,          //output valid signal
output [DATA_W-1:0] data_out   //output data
)
;

genvar i;
generate                      //generating sbox roms 
for (i=0; i< NO_BYTES ; i=i+1) begin : ROM
  SBox ROM(clk,reset,valid_in,data_in[(i*8)+7:(i*8)],data_out[(i*8)+7:(i*8)]);   
end
endgenerate

always@(posedge clk or negedge reset)   //valid out register
if(!reset)begin
    valid_out <= 1'b0;
end else begin 
    valid_out <= valid_in;
  end
endmodule




