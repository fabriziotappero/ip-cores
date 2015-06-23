`include "../bench/timescale.v"


// this module do 8bytes iteration

module stream_8bytes(
                                init,sb,
                                Ai,Bi,Di,Ei,Fi,Xi,Yi,Zi,pi,qi,ri,
                                Ao,Bo,Do,Eo,Fo,Xo,Yo,Zo,po,qo,ro,
                                cb
                        );
input            init;
input [8*8-1 :0] sb;

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

output [8*8-1 :0] cb;

wire  [10*4-1:0] A1;
wire  [10*4-1:0] B1;
wire  [3     :0] D1;
wire  [3     :0] E1;
wire  [3     :0] F1;
wire  [3     :0] X1;
wire  [3     :0] Y1;
wire  [3     :0] Z1;
wire             p1;
wire             q1;
wire             r1;

wire  [10*4-1:0] A2;
wire  [10*4-1:0] B2;
wire  [3     :0] D2;
wire  [3     :0] E2;
wire  [3     :0] F2;
wire  [3     :0] X2;
wire  [3     :0] Y2;
wire  [3     :0] Z2;
wire             p2;
wire             q2;
wire             r2;

wire  [10*4-1:0] A3;
wire  [10*4-1:0] B3;
wire  [3     :0] D3;
wire  [3     :0] E3;
wire  [3     :0] F3;
wire  [3     :0] X3;
wire  [3     :0] Y3;
wire  [3     :0] Z3;
wire             p3;
wire             q3;
wire             r3;

wire  [10*4-1:0] A4;
wire  [10*4-1:0] B4;
wire  [3     :0] D4;
wire  [3     :0] E4; 
wire  [3     :0] F4; 
wire  [3     :0] X4;
wire  [3     :0] Y4;
wire  [3     :0] Z4;
wire             p4;
wire             q4;
wire             r4;

wire  [10*4-1:0] A5;
wire  [10*4-1:0] B5;
wire  [3     :0] D5;
wire  [3     :0] E5;
wire  [3     :0] F5;
wire  [3     :0] X5;
wire  [3     :0] Y5;
wire  [3     :0] Z5;
wire             p5;
wire             q5;
wire             r5;

wire  [10*4-1:0] A6;
wire  [10*4-1:0] B6;
wire  [3     :0] D6;
wire  [3     :0] E6;
wire  [3     :0] F6;
wire  [3     :0] X6;
wire  [3     :0] Y6;
wire  [3     :0] Z6;
wire             p6;
wire             q6;
wire             r6;

wire  [10*4-1:0] A7;
wire  [10*4-1:0] B7;
wire  [3     :0] D7;
wire  [3     :0] E7;
wire  [3     :0] F7;
wire  [3     :0] X7;
wire  [3     :0] Y7;
wire  [3     :0] Z7;
wire             p7;
wire             q7;
wire             r7;

stream_byte stream_byte1(
                         .init(init)
                        ,.sb  (sb[8*1-1:8*0])
                        ,.Ai  (Ai)
                        ,.Bi  (Bi)
                        ,.Di  (Di)
                        ,.Ei  (Ei)
                        ,.Fi  (Fi)
                        ,.Xi  (Xi)
                        ,.Yi  (Yi)
                        ,.Zi  (Zi)
                        ,.pi  (pi)
                        ,.qi  (qi)
                        ,.ri  (ri)
                        ,.Ao  (A1)
                        ,.Bo  (B1)
                        ,.Do  (D1)
                        ,.Eo  (E1)
                        ,.Fo  (F1)
                        ,.Xo  (X1)
                        ,.Yo  (Y1)
                        ,.Zo  (Z1)
                        ,.po  (p1)
                        ,.qo  (q1)
                        ,.ro  (r1)
                        ,.op  (cb[8*1-1:8*0])                        
                );

stream_byte stream_byte2(
                         .init(init)
                        ,.sb  (sb[8*2-1:8*1])
                        ,.Ai  (A1)
                        ,.Bi  (B1)
                        ,.Di  (D1)
                        ,.Ei  (E1)
                        ,.Fi  (F1)
                        ,.Xi  (X1)
                        ,.Yi  (Y1)
                        ,.Zi  (Z1)
                        ,.pi  (p1)
                        ,.qi  (q1)
                        ,.ri  (r1)
                        ,.Ao  (A2)
                        ,.Bo  (B2)
                        ,.Do  (D2)
                        ,.Eo  (E2)
                        ,.Fo  (F2)
                        ,.Xo  (X2)
                        ,.Yo  (Y2)
                        ,.Zo  (Z2)
                        ,.po  (p2)
                        ,.qo  (q2)
                        ,.ro  (r2)
                        ,.op  (cb[8*2-1:8*1])                        
                );

stream_byte stream_byte3(
                         .init(init)
                        ,.sb  (sb[8*3-1:8*2])
                        ,.Ai  (A2)
                        ,.Bi  (B2)
                        ,.Di  (D2)
                        ,.Ei  (E2)
                        ,.Fi  (F2)
                        ,.Xi  (X2)
                        ,.Yi  (Y2)
                        ,.Zi  (Z2)
                        ,.pi  (p2)
                        ,.qi  (q2)
                        ,.ri  (r2)
                        ,.Ao  (A3)
                        ,.Bo  (B3)
                        ,.Do  (D3)
                        ,.Eo  (E3)
                        ,.Fo  (F3)
                        ,.Xo  (X3)
                        ,.Yo  (Y3)
                        ,.Zo  (Z3)
                        ,.po  (p3)
                        ,.qo  (q3)
                        ,.ro  (r3)
                        ,.op  (cb[8*3-1:8*2])                        
                );

stream_byte stream_byte4(
                         .init(init)
                        ,.sb  (sb[8*4-1:8*3])
                        ,.Ai  (A3)
                        ,.Bi  (B3)
                        ,.Di  (D3)
                        ,.Ei  (E3)
                        ,.Fi  (F3)
                        ,.Xi  (X3)
                        ,.Yi  (Y3)
                        ,.Zi  (Z3)
                        ,.pi  (p3)
                        ,.qi  (q3)
                        ,.ri  (r3)
                        ,.Ao  (A4)
                        ,.Bo  (B4)
                        ,.Do  (D4)
                        ,.Eo  (E4)
                        ,.Fo  (F4)
                        ,.Xo  (X4)
                        ,.Yo  (Y4)
                        ,.Zo  (Z4)
                        ,.po  (p4)
                        ,.qo  (q4)
                        ,.ro  (r4)
                        ,.op  (cb[8*4-1:8*3])                        
                );

stream_byte stream_byte5(
                         .init(init)
                        ,.sb  (sb[8*5-1:8*4])
                        ,.Ai  (A4)
                        ,.Bi  (B4)
                        ,.Di  (D4)
                        ,.Ei  (E4)
                        ,.Fi  (F4)
                        ,.Xi  (X4)
                        ,.Yi  (Y4)
                        ,.Zi  (Z4)
                        ,.pi  (p4)
                        ,.qi  (q4)
                        ,.ri  (r4)
                        ,.Ao  (A5)
                        ,.Bo  (B5)
                        ,.Do  (D5)
                        ,.Eo  (E5)
                        ,.Fo  (F5)
                        ,.Xo  (X5)
                        ,.Yo  (Y5)
                        ,.Zo  (Z5)
                        ,.po  (p5)
                        ,.qo  (q5)
                        ,.ro  (r5)
                        ,.op  (cb[8*5-1:8*4])                        
                );

stream_byte stream_byte6(
                         .init(init)
                        ,.sb  (sb[8*6-1:8*5])
                        ,.Ai  (A5)
                        ,.Bi  (B5)
                        ,.Di  (D5)
                        ,.Ei  (E5)
                        ,.Fi  (F5)
                        ,.Xi  (X5)
                        ,.Yi  (Y5)
                        ,.Zi  (Z5)
                        ,.pi  (p5)
                        ,.qi  (q5)
                        ,.ri  (r5)
                        ,.Ao  (A6)
                        ,.Bo  (B6)
                        ,.Do  (D6)
                        ,.Eo  (E6)
                        ,.Fo  (F6)
                        ,.Xo  (X6)
                        ,.Yo  (Y6)
                        ,.Zo  (Z6)
                        ,.po  (p6)
                        ,.qo  (q6)
                        ,.ro  (r6)
                        ,.op  (cb[8*6-1:8*5])                        
                );

stream_byte stream_byte7(
                         .init(init)
                        ,.sb  (sb[8*7-1:8*6])
                        ,.Ai  (A6)
                        ,.Bi  (B6)
                        ,.Di  (D6)
                        ,.Ei  (E6)
                        ,.Fi  (F6)
                        ,.Xi  (X6)
                        ,.Yi  (Y6)
                        ,.Zi  (Z6)
                        ,.pi  (p6)
                        ,.qi  (q6)
                        ,.ri  (r6)
                        ,.Ao  (A7)
                        ,.Bo  (B7)
                        ,.Do  (D7)
                        ,.Eo  (E7)
                        ,.Fo  (F7)
                        ,.Xo  (X7)
                        ,.Yo  (Y7)
                        ,.Zo  (Z7)
                        ,.po  (p7)
                        ,.qo  (q7)
                        ,.ro  (r7)
                        ,.op  (cb[8*7-1:8*6])                        
                );

stream_byte stream_bytes8(
                         .init(init)
                        ,.sb  (sb[8*8-1:8*7])
                        ,.Ai  (A7)
                        ,.Bi  (B7)
                        ,.Di  (D7)
                        ,.Ei  (E7)
                        ,.Fi  (F7)
                        ,.Xi  (X7)
                        ,.Yi  (Y7)
                        ,.Zi  (Z7)
                        ,.pi  (p7)
                        ,.qi  (q7)
                        ,.ri  (r7)
                        ,.Ao  (Ao)
                        ,.Bo  (Bo)
                        ,.Do  (Do)
                        ,.Eo  (Eo)
                        ,.Fo  (Fo)
                        ,.Xo  (Xo)
                        ,.Yo  (Yo)
                        ,.Zo  (Zo)
                        ,.po  (po)
                        ,.qo  (qo)
                        ,.ro  (ro)
                        ,.op  (cb[8*8-1:8*7])                        
                );

endmodule
