`include "../bench/timescale.v"


// this file implement the stream cypher module

module stream_cypher(clk,rst,en,init,ck,sb,cb);
input                 clk;
input                 rst;   // hi enable
input                 en;      // hi enable
input                 init;    // hi enable
input  [8 *8-1:0]     ck;
input  [8 *8-1:0]     sb;
output [8 *8-1:0]     cb;



// intermediate variable
reg    [10*4-1 : 0]A;
reg    [10*4-1 : 0]B;
reg    [4-1    : 0]X;
reg    [4-1    : 0]Y;
reg    [4-1    : 0]Z;
reg    [4-1    : 0]D;
reg    [4-1    : 0]E;
reg    [4-1    : 0]F;
reg                p;
reg                q;
reg                r;

wire   [10*4-1 : 0]Ao;
wire   [10*4-1 : 0]Ainit;
wire   [10*4-1 : 0]Bo;
wire   [10*4-1 : 0]Binit;
wire   [4-1    : 0]Xo;
wire   [4-1    : 0]Yo;
wire   [4-1    : 0]Zo;
wire   [4-1    : 0]Do;
wire   [4-1    : 0]Eo;
wire   [4-1    : 0]Fo;
wire               po;
wire               qo;
wire               ro;
wire   [8 *8-1 : 0]cbo;

assign Ainit = { 
                4'b0,         4'b0,
        ck[7*4-1:6*4],ck[8*4-1:7*4], 
        ck[5*4-1:4*4],ck[6*4-1:5*4], 
        ck[3*4-1:2*4],ck[4*4-1:3*4], 
        ck[1*4-1:0*4],ck[2*4-1:1*4] 
};

assign Binit = { 
                   4'b0,           4'b0,
        ck[15*4-1:14*4],ck[16*4-1:15*4], 
        ck[13*4-1:12*4],ck[14*4-1:13*4], 
        ck[11*4-1:10*4],ck[12*4-1:11*4], 
        ck[ 9*4-1: 8*4],ck[10*4-1: 9*4]
};

always @(posedge clk)
begin
        if(rst)
        begin
                A<= 40'h0000000000;
                B<= 40'h0000000000;
                X<=  4'h0;
                Y<=  4'h0;
                Z<=  4'h0;
                D<=  4'h0;
                E<=  4'h0;
                F<=  4'h0;
                p<=  1'h0;
                q<=  1'h0;
                r<=  1'h0;
        end
        else 
        begin
                if(en)
                begin
                        A<=  Ao;
                        B<=  Bo;
                        X<=  Xo;
                        Y<=  Yo;
                        Z<=  Zo;
                        D<=  Do;
                        E<=  Eo;
                        F<=  Fo;
                        p<=  po;
                        q<=  qo;
                        r<=  ro;
                end
        end
end


stream_8bytes stream_8bytes(
                        .init(init)
                       ,.sb(sb)
                       ,.Ai((init)?Ainit:A)
                       ,.Bi((init)?Binit:B)
                       ,.Di((init)?4'b0 :D)
                       ,.Ei((init)?4'b0 :E)
                       ,.Fi((init)?4'b0 :F)
                       ,.Xi((init)?4'b0 :X)
                       ,.Yi((init)?4'b0 :Y)
                       ,.Zi((init)?4'b0 :Z)
                       ,.pi((init)?1'b0 :p)
                       ,.qi((init)?1'b0 :q)
                       ,.ri((init)?1'b0 :r)

                       ,.Ao(Ao)
                       ,.Bo(Bo)
                       ,.Do(Do)
                       ,.Eo(Eo)
                       ,.Fo(Fo)
                       ,.Xo(Xo)
                       ,.Yo(Yo)
                       ,.Zo(Zo)
                       ,.po(po)
                       ,.qo(qo)
                       ,.ro(ro)
                       ,.cb(cbo)
                );

        assign cb=cbo;

endmodule
