
`include "../bench/timescale.v"

// this module serial output the ts stream
module ts_serial_out(
                          input            clk
                        , input            rst
                        , input [8*8-1:0]  group
                        , input [3:0]      bytes
                        , input            en
                        , output[1*8-1:0]  dec
                        , output           valid
                );

        reg [8*8-1:0]  group_d;
        reg [3:0]      cnt;

        assign valid = cnt != 3'h0;
        assign dec   = group_d[1*8-1:0];

        always@(posedge clk)
                if(en)
                begin
                        group_d<=group;
                        cnt    <=bytes;
                end
                else
                if(cnt!=3'h0)
                begin
                        group_d<={group_d[1*8-1:0],group_d[8*8-1:1*8]};
                        cnt<=cnt-4'h1;
                end

endmodule

