/*
Project        : AES
Standard doc.  : FIPS 197
Module name    : Top_AES_PipelinedCipher 
Dependancy     :
Design doc.    : 
References     : 
Description    : this is the top module of the design which forms
                 rounds and connects KeyExpantion using pipelined
				 architecture
Owner          : Amr Salah
*/


`timescale 1 ns/1 ps

module Top_PipelinedCipher
#
(
parameter DATA_W = 128,      //data width
parameter KEY_L = 128,       //key length
parameter NO_ROUNDS = 10     //number of rounds
)

(
input clk,                       //system clock
input reset,                     //asynch reset
input data_valid_in,             //data valid signal
input cipherkey_valid_in,        //cipher key valid signal
input [KEY_L-1:0] cipher_key,    //cipher key
input [DATA_W-1:0] plain_text,   //plain text
output valid_out,                //output valid signal
output [DATA_W-1:0] cipher_text  //cipher text
);

wire [NO_ROUNDS-1:0] valid_round_key;            //all round keys valid signals KeyExpantion output
wire [NO_ROUNDS-1:0] valid_round_data;           //all rounds ouput data valid signals
wire [DATA_W-1:0] data_round [0:NO_ROUNDS-1];    //all rounds data
wire valid_sub2shift;                            //for final round connection
wire valid_shift2key;                            //
wire [DATA_W-1:0]data_sub2shift;                 //
wire [DATA_W-1:0]data_shift2key;                 //
wire [(NO_ROUNDS*DATA_W)-1:0] W;                 //all round keys

reg[DATA_W-1:0] data_shift2key_delayed;           //for delay register
reg valid_shift2key_delayed;

//instantiate Key Expantion which will feed every round with round key
KeyExpantion #(DATA_W,KEY_L,NO_ROUNDS) U_KEYEXP(clk,reset,cipherkey_valid_in,cipher_key,W,valid_round_key);

//due to algorithm,first cipher key will be xored witht plain text
AddRoundKey #(DATA_W)U0_ARK(clk,reset,data_valid_in,cipherkey_valid_in,plain_text,cipher_key,valid_round_data[0],data_round[0]);

//instantiate all rounds , connect them with key expantion
genvar i;
generate
for(i=0;i<NO_ROUNDS-1;i=i+1) begin : ROUND
 Round #(DATA_W)U_ROUND(clk,reset,valid_round_data[i],valid_round_key[i],data_round[i],W[(NO_ROUNDS-i)*DATA_W-1:(NO_ROUNDS-i-1)*DATA_W],valid_round_data[i+1],data_round[i+1]);
end
endgenerate

//this is the final round it doesn't contain mixcolumns as declared in fips197 standard document
SubBytes #(DATA_W) U_SUB (clk,reset,valid_round_data[NO_ROUNDS-1],data_round[NO_ROUNDS-1],valid_sub2shift,data_sub2shift);
ShiftRows #(DATA_W) U_SH (clk,reset,valid_sub2shift,data_sub2shift,valid_shift2key,data_shift2key);
AddRoundKey #(DATA_W) U_KEY (clk,reset,valid_shift2key_delayed,valid_round_key[NO_ROUNDS-1],data_shift2key_delayed,W[DATA_W-1:0],valid_out,cipher_text);

/*as the final round has only three stages a delay register should be introduced 
  to be balanced with key  expantion*/
always @(posedge clk or negedge reset)

if(!reset)begin
    valid_shift2key_delayed <= 1'b0;
    data_shift2key_delayed <= 'b0;
end else begin

 if(valid_shift2key)begin
   data_shift2key_delayed <= data_shift2key;
 end
   valid_shift2key_delayed <= valid_shift2key;
end

endmodule
