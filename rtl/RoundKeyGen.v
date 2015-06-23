/*
Project        : AES
Standard doc.  : FIPS 197
Module name    : RoundKeyGen block
Dependancy     : 
Design doc.    :
References     :
Description    : This module is used to perform the process
                 of round key generation from input key
				 this module is the basic block of key expantion module
Owner          : Amr Salah
*/

`timescale 1 ns/1 ps

module RoundKeyGen
#
(
parameter KEY_L = 128,     //key length
parameter WORD = 32        //a parameter to represent WORD  = 4 bytes = 32 bit
)
(
input clk,                           //system clk
input reset,                         //asynch active low reset
input [WORD-1:0] RCON_Word,          //round constant word       
input valid_in,                      //input valid signal
input [KEY_L-1:0] key,               //input key
output reg [KEY_L-1:0]round_key,     //round key
output reg valid_out                 //output valid signal
);

wire [WORD-1:0] Key_RotWord;              
reg [KEY_L-1:0] Key_FirstStage;      
reg [KEY_L-1:0] Key_SecondStage;     
reg [KEY_L-1:0] round_key_delayed;
reg  valid_FirstStage;
reg  valid_round_key;
wire [WORD-1:0] Key_SubBytes;
wire  subbytes_valid_out;
wire [KEY_L-1:0] temp_round_key;

//The keygeneration stages should be balanced with the 4 round stages(SubBytes-ShiftRows-MixColumns-AddRoundKey)
//in order to let the round key and the data meet at the same time in the AddRoundKey module

/******************************************First Stage Register***********************************************************/
always @(posedge clk or negedge reset)
if(!reset)begin
    valid_FirstStage <= 1'b0;
    Key_FirstStage <= 'b0;
end else begin
 if(valid_in)begin
    Key_FirstStage <= key;
 end
    valid_FirstStage <= valid_in;
end
/***********************************************Second Stage Register*******************************************************/
always @(posedge clk or negedge reset)
if(!reset)begin
    Key_SecondStage <= 'b0;
end else begin
 if(valid_FirstStage)begin 
   Key_SecondStage <= Key_FirstStage;
 end
end      
/*******************************************************RotWord****************************************************************/
assign Key_RotWord = {Key_FirstStage[WORD-9:0],Key_FirstStage[WORD-1:WORD-8]}; //rotation of the least word in key

/**************************************************SubBytes (Parallel to second stage register)*******************************/
//perform subbytes operation on the result word of rotword step
SubBytes #(WORD) SUB_U (clk,reset,valid_FirstStage,Key_RotWord,subbytes_valid_out,Key_SubBytes);

/***************************************************Round Key calculations ***********************************************/
assign temp_round_key[4*WORD-1:3*WORD] =  Key_SecondStage[4*WORD-1:3*WORD]  ^ Key_SubBytes ^ RCON_Word;
assign temp_round_key[3*WORD-1:2*WORD] = Key_SecondStage[3*WORD-1:2*WORD] ^ temp_round_key[4*WORD-1:3*WORD] ;
assign temp_round_key[2*WORD-1:WORD] =  Key_SecondStage[2*WORD-1:WORD] ^   temp_round_key[3*WORD-1:2*WORD];
assign temp_round_key[WORD-1:0] = Key_SecondStage[WORD-1:0] ^ temp_round_key[2*WORD-1:WORD];

/***************************************************Roundkey Register (Third Stage)******************************************/
always @(posedge clk or negedge reset)
if(!reset)begin
    round_key_delayed <= 'b0;
    valid_round_key <= 1'b0;
end else begin
 if(subbytes_valid_out)begin
    round_key_delayed <= temp_round_key;
 end
    valid_round_key <= subbytes_valid_out;
end
/****************************************Out Put Register (Fourth Stage)*********************************************/
always @(posedge clk or negedge reset)
if(!reset)begin
   valid_out <= 1'b0;
   round_key <= 'b0;
end else begin
 if(valid_round_key)begin
   round_key <= round_key_delayed;
 end
   valid_out <= valid_round_key;
end

endmodule