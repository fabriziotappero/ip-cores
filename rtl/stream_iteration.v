`include "../bench/timescale.v"

// this module do a iteration operation for 2 bit

module stream_iteration(init,in1,in2,
                                Ai,Bi,Di,Ei,Fi,Xi,Yi,Zi,pi,qi,ri,
                                Ao,Bo,Do,Eo,Fo,Xo,Yo,Zo,po,qo,ro,
                                op);
input    init;
input [3     :0] in1;
input [3     :0] in2;

input [10*4-1:0] Ai;
input [10*4-1:0] Bi;
input [3     :0] Di;
input [3     :0] Ei;
input [3     :0] Fi;
input [3     :0] Xi;
input [3     :0] Yi;
input [3     :0] Zi;
input            pi;
input            qi;
input            ri;

output [10*4-1:0] Ao;
output [10*4-1:0] Bo;
output [3     :0] Do;
output [3     :0] Eo;
output [3     :0] Fo;
output [3     :0] Xo;
output [3     :0] Yo;
output [3     :0] Zo;
output            po;
output            qo;
output            ro;

output[1     :0] op;

wire [1:0] s1;
wire [1:0] s2;
wire [1:0] s3;
wire [1:0] s4;
wire [1:0] s5;
wire [1:0] s6;
wire [1:0] s7;

wire [3:0] extra_B;
wire [3:0] next_A1;
wire [3:0] _next_B1;
wire [3:0] next_B1;
wire [3:0] next_E;

wire [4:0] total;

sboxes b(
                .A(Ai[9*4-1:0])
               ,.s1(s1)
               ,.s2(s2)
               ,.s3(s3)
               ,.s4(s4)
               ,.s5(s5)
               ,.s6(s6)
               ,.s7(s7)
        );

assign extra_B ={( Bi[(3-1)*4+0] ^ Bi[(6-1)*4+1] ^ Bi[(7-1)*4+2] ^ Bi[(9-1)*4+3]) ,
                 ( Bi[(6-1)*4+0] ^ Bi[(8-1)*4+1] ^ Bi[(3-1)*4+3] ^ Bi[(4-1)*4+2]) ,
                 ( Bi[(5-1)*4+3] ^ Bi[(8-1)*4+2] ^ Bi[(4-1)*4+0] ^ Bi[(5-1)*4+1]) ,
                 ( Bi[(9-1)*4+2] ^ Bi[(6-1)*4+3] ^ Bi[(3-1)*4+1] ^ Bi[(8-1)*4+0]) };

assign next_A1=(init)?   Ai[(10)*4-1:(10-1)*4] ^ Xi ^ Di ^ in2
                        :Ai[(10)*4-1:(10-1)*4] ^ Xi;

assign _next_B1=(init)?  Bi[7*4-1:(7-1)*4] ^ Bi[10*4-1:(10-1)*4] ^ Yi ^ in1
                        :Bi[7*4-1:(7-1)*4] ^ Bi[10*4-1:(10-1)*4] ^ Yi ;

assign next_B1=(pi)?{ _next_B1[2:0], _next_B1[3] }: _next_B1;

assign Do = Ei ^ Zi ^ extra_B;

assign next_E=Fi;

assign total=Zi+Ei+ri;

assign Fo=(qi)? total[3:0]:Ei;
assign ro=(qi)? total[4]:ri;

assign Eo=next_E;

assign Ao[10*4-1:4]=Ai[9*4-1:0];
assign Ao[1*4-1:0] =next_A1;
assign Bo[10*4-1:4]=Bi[9*4-1:0];
assign Bo[1*4-1:0] =next_B1;

assign Xo ={s4[0] , s3[0] , s2[1] , s1[1] };
assign Yo ={s6[0] , s5[0] , s4[1] , s3[1] };
assign Zo ={s2[0] , s1[0] , s6[1] , s5[1] };

assign po=s7[1];
assign qo=s7[0];

assign op = { Do[3] ^ Do[2], Do[1] ^ Do[0]  };
endmodule
