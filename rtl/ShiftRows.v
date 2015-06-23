/*
Project         : AES
Standard doc.   : FIPS 197
Module name     : ShiftRows block
Dependancy      :
Design doc.     : 
References      : 
Description     : this module is used to arrange data in the state array 
                  and shifting rows of this array as declared on the standard document
Owner           : Amr Salah
*/

`timescale 1 ns/1 ps

module ShiftRows
#
(
parameter DATA_W = 128       //data width
)
(
input clk,                  //system clock
input reset,                //asynch active low reset
input valid_in,             //input valid signal   
input [DATA_W-1:0] data_in,  //input data
output reg valid_out,         //output valid signal
output reg [DATA_W-1:0] data_out //output data
)
;

wire [7:0] State [0:15];   //array of wires to form state array     

genvar i ;                                
generate 
// filling state array as each row represents one byte ex: state[0] means first byte and so on
for(i=0;i<=15;i=i+1) begin :STATE 
 assign State[i]= data_in[(((15-i)*8)+7):((15-i)*8)];  
end   
endgenerate  
                   
always @(posedge clk or negedge reset)

if(!reset)begin
    valid_out <= 1'b0;
    data_out <= 'b0;
end else begin  

 if(valid_in)begin   //shifting state rows as delared in fips197 standard document
    data_out[(15*8)+7:(12*8)] <= {State[0],State[5],State[10],State[15]}; 
    data_out[(11*8)+7:(8*8)] <= {State[4],State[9],State[14],State[3]};                            
    data_out[(7*8)+7:(4*8)]  <= {State[8],State[13],State[2],State[7]};                         
    data_out[(3*8)+7:(0*8)]  <=  {State[12],State[1],State[6],State[11]}; 
 end 
    valid_out <= valid_in;                               
end
    
endmodule
    
    