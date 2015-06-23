/*
Project        : AES
Standard doc.  : FIPS 197
Module name    : AddRoundKey block
Dependancy     :
Design doc.    : 
References     : 
Description    : This module is used for xoring data and round  key 
Owner          : Amr Salah
*/

`timescale 1 ns/1 ps

module AddRoundKey
#
(
parameter DATA_W = 128            //data width
)
(
input clk,                        //system clock
input reset,                      //asynch active low reset
input data_valid_in,              //data valid signal
input key_valid_in,               //key valid signal  
input [DATA_W-1:0] data_in,       //input data
input [DATA_W-1:0] round_key,     //input round key
output reg valid_out,             //output valid signal
output reg [DATA_W-1:0] data_out  //output data
)
;

always@(posedge clk or negedge reset)
if(!reset)begin
    data_out <= 'b0;
    valid_out <= 1'b0;
end
else begin
    if(data_valid_in && key_valid_in) begin
    data_out <=  data_in ^ round_key;      //xoring data and round key       
    end   
    valid_out <=  data_valid_in & key_valid_in;
end
endmodule
