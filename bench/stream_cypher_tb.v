

// this file is the testbench of stream_cypher module

`timescale 1ns/1ns
module stream_cypher_tb;

reg clk;
reg rst;

reg en;
reg init;


reg [8*8-1:0] ck;
reg [8*8-1:0] sb;

wire [8*8-1:0] cb;

reg [24*8-1:0] tt; // input 

initial
begin
//        $read_data(
//                                "../test_dat/stream_cypher.in"
//                               ,tt
//                  );
        tt=192'b001001110001111100011000000100010000101000000010111110111111010011101101111001101101111011010111110100001100100111000001101110101011001110101100101001001001110110010110100011111000011110000000;
        @(posedge rst);
        ck =tt[ 24* 8-1: 16* 8];
        en=1;
        init=1;
        sb =tt[ 16*8-1:8* 8];
        @(posedge clk);
        en=1;
        init=0;
        sb =tt[ 8*8-1:0* 8];

//        $write_data(
//                                 "../test_dat/stream_cypher.out.v"
//                                ,"w"
//                                ,cb
//                   );

        @(posedge clk);
        $display("\ncb=%b\n",cb);
        $display("b.b.b1.b1.op=%b\n",b.b.b1.b1.op);
        $display("b.b.b1.b1.Do=%b\n",b.b.b1.b1.Do);
        $display("b.b.b1.b1.Ei=%b\n",b.b.b1.b1.Ei);
        $display("b.b.b1.b1.Zi=%b\n",b.b.b1.b1.Zi);
        $display("b.b.b1.b1.extra_B=%b\n",b.b.b1.b1.extra_B);
        $display("b.b.b1.b2.op=%b\n",b.b.b1.b2.op);
        $display("b.b.b1.b3.op=%b\n",b.b.b1.b3.op);
        $display("b.b.b1.b4.op=%b\n",b.b.b1.b4.op);

//        $write_data(
//                                 "../test_dat/stream_cypher.out.v"
//                                ,"a"
//                                ,cb
//                   );
        @(posedge clk);

        $finish;
end

initial
begin
        clk<=1'b0;        
        forever #5 clk=~clk;
end

initial
begin
        rst<=1'b0;        
        @(posedge clk);
        @(posedge clk);
        rst=1'h1;
end

stream_cypher b(
                 .clk   (clk)
                ,.rst   (rst)
                ,.en    (en)
                ,.init  (init)
                ,.ck    (ck)
                ,.sb    (sb)
                ,.cb    (cb)
                );

endmodule
