/*
Project        : AES
Standard doc.  : FIPS 197
Module name    : Round block
Dependancy     :
Design doc.    : 
References     : 
Description    : This module is used to connect 
                 SubBytes-ShiftRows-MixColumns-AddRoundKey modules
Owner          : Amr Salah
*/

`timescale 1 ns/1 ps               
 
module Round
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
input [DATA_W-1:0] round_key,     //round  key
output  valid_out,                //output valid signal
output  [DATA_W-1:0] data_out     //output data
)
;
                                 //wires for connection 
wire [DATA_W-1:0] data_sub2shift;  
wire [DATA_W-1:0] data_shift2mix; 
wire [DATA_W-1:0] data_mix2key;

wire valid_sub2shift;
wire valid_shift2mix;
wire valid_mix2key;

///////////////////////////////SubBytes///////////////////////////////////////////////////
SubBytes #(DATA_W) U_SUB (clk,reset,data_valid_in,data_in,valid_sub2shift,data_sub2shift);

//////////////////////////////ShiftRows///////////////////////////////////////////////////////////
ShiftRows #(DATA_W) U_SH (clk,reset,valid_sub2shift,data_sub2shift,valid_shift2mix,data_shift2mix);

//////////////////////////////MixColumns//////////////////////////////////////////////////////////
MixColumns #(DATA_W) U_MIX (clk,reset,valid_shift2mix,data_shift2mix,valid_mix2key,data_mix2key);

/////////////////////////////AddRoundKey/////////////////////////////////////////////////////////////////////
AddRoundKey #(DATA_W) U_KEY (clk,reset,valid_mix2key,key_valid_in,data_mix2key,round_key,valid_out,data_out);

endmodule
