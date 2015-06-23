`include "../bench/timescale.v"


// this module do a stream_byte opertion


module stream_byte(init,sb,
                                Ai,Bi,Di,Ei,Fi,Xi,Yi,Zi,pi,qi,ri,
                                Ao,Bo,Do,Eo,Fo,Xo,Yo,Zo,po,qo,ro,
                                op
                  );
input            init;
input [7     :0] sb;

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

output[7     :0]  op;

// intermedate result;
wire [10*4-1:0] A1;
wire [10*4-1:0] B1;
wire [3     :0] D1;
wire [3     :0] E1;
wire [3     :0] F1;
wire [3     :0] X1;
wire [3     :0] Y1;
wire [3     :0] Z1;
wire            p1;
wire            q1;
wire            r1;

wire [10*4-1:0] A2;
wire [10*4-1:0] B2;
wire [3     :0] D2;
wire [3     :0] E2;
wire [3     :0] F2;
wire [3     :0] X2;
wire [3     :0] Y2;
wire [3     :0] Z2;
wire            p2;
wire            q2;
wire            r2;

wire [10*4-1:0] A3;
wire [10*4-1:0] B3;
wire [3     :0] D3;
wire [3     :0] E3;
wire [3     :0] F3;
wire [3     :0] X3;
wire [3     :0] Y3;
wire [3     :0] Z3;
wire            p3;
wire            q3;
wire            r3;

wire [7     :0] _op;

wire [3     :0] in1;
wire [3     :0] in2;

assign in1 = sb[7:4];
assign in2 = sb[3:0];

stream_iteration  stream_iteration1 (
                         .init(init)
                        ,.in1 (in2)
                        ,.in2 (in1)
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
                        ,.op  (_op[7:6])
                        );

stream_iteration  stream_iteration2 (
                         .init(init)
                        ,.in1 (in1)
                        ,.in2 (in2)
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
                        ,.op  (_op[5:4])
                        );

stream_iteration  stream_iteration3 (
                         .init(init)
                        ,.in1 (in2)
                        ,.in2 (in1)
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
                        ,.op  (_op[3:2])
                        );

stream_iteration  stream_iteration4 (
                         .init(init)
                        ,.in1 (in1)
                        ,.in2 (in2)
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
                        ,.op  (_op[1:0])
                        );

assign op=(init)?sb:_op;
endmodule
