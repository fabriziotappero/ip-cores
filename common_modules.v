//******************************************************//
// This file contains definition of common modules used //
// by higher level modules in RS Decoder                //
//******************************************************//

//*************************//
// Multiplexer 2 to 1 5bit //
//*************************//
module mux2_to_1(in1, in2 , out, sel);

input [4:0] in1, in2;
input sel;
output [4:0] out;
reg [4:0] out;

always@(sel or in1 or in2)
begin
    case(sel)
        0   : out = in1;
        1   : out = in2;
        default: out = in1;
    endcase
end
endmodule

//**********************************************//
//Register 5 bit with synchronous load and hold //
//**********************************************//
module register5_wlh(datain, dataout, load, hold, clock);

input [4:0] datain;
input load, hold;
input clock;
output [4:0] dataout;
reg [4:0] out;

always @(posedge clock)
begin
    if(load)
       out <= datain;
    else if(hold)
       out <= out;
    else
       out <= 5'b0;
end

assign dataout = out;

endmodule


//**************************************//
// Register 5 bit with synchronous load //
//**************************************//
module register5_wl(datain, dataout, clock, load);

input [4:0] datain;
output [4:0] dataout;
input clock, load;
reg [4:0] dataout;

always@(posedge clock)
begin
    if(load)
       dataout <= datain;
    else
       dataout <= 5'b0;
end

endmodule


//**************//
//GF(2^5) Adder //
//**************//
module gfadder(in1, in2, out);
    
input [0:4] in1, in2;
output [0:4] out;
    
assign out[4] = in1[4] ^ in2[4];
assign out[3] = in1[3] ^ in2[3];
assign out[2] = in1[2] ^ in2[2];
assign out[1] = in1[1] ^ in2[1];
assign out[0] = in1[0] ^ in2[0];

endmodule


//*********************************************//
// GF(2^5) parallel multiplier is based on     //
// the design proposed by M. Anwar Hasan &     //
// A. Reyhani-Masoleh in their paper entitled  //
// "Low Complexity Bit Parallel Architectures  //
// for Polynomial Basis Multiplication over    //
// GF(2^m)" published in IEEE Transactions On  //
// Computer August 2004.                       //
//*********************************************//
module lcpmult(in1, in2, out);
   
   input [0:4] in1, in2; //in1[4] & in2[4] is MSB
   output [0:4] out;
   
   wire [4:0] intvald; //intermediate val d
   wire [3:0] intvale; //intermediate val e
   wire intvale_0ax; //intermediate val e'[0]
      
   assign intvald[0] = in1[0] & in2[0];
   assign intvald[1] = (in1[1] & in2[0]) ^ (in1[0] & in2[1]);
   assign intvald[2] = (in1[2] & in2[0]) ^ ((in1[1] & in2[1]) ^ (in1[0] & in2[2]));
   assign intvald[3] = ((in1[3] & in2[0]) ^ (in1[2] & in2[1])) ^ ((in1[1] & in2[2]) ^ (in1[0] & in2[3]));
   assign intvald[4] = (((in1[4] & in2[0]) ^ (in1[3] & in2[1])) ^ (in1[2] & in2[2]))
                        ^ ((in1[1] & in2[3]) ^ (in1[0] & in2[4])); 
   
   assign intvale[0] = ((in1[4] & in2[1]) ^ (in1[3] & in2[2])) ^ ((in1[2] & in2[3]) ^ (in1[1] & in2[4]));
   assign intvale[1] = ((in1[4] & in2[2]) ^ (in1[3] & in2[3])) ^ (in1[2] & in2[4]);
   assign intvale[2] = (in1[4] & in2[3]) ^ (in1[3] & in2[4]);
   assign intvale[3] = in1[4] & in2[4];
   
   assign intvale_0ax = (intvale[0] ^ intvale[3]);
   
   assign out[0] = intvald[0] ^ intvale_0ax;
   assign out[1] = intvald[1] ^ intvale[1];
   assign out[2] = (intvald[2] ^ intvale[2]) ^ intvale_0ax;
   assign out[3] = (intvald[3] ^ intvale[1]) ^ intvale[3];
   assign out[4] = intvald[4] ^ intvale[2];
   
 endmodule
 