`include "../bench/timescale.v"
// this moduel do a decrypt group

module group_decrypt(
                          input                    clk          // clk 
                        , input                    rst          // rst, high active
                        , input                    en           // input enable
                        , input                    init         // the first packet
                        , input                    last         // the last packet
                        , input         [ 8*8-1:0] ck           // ck 
                        , input         [56*8-1:0] kk           // kk 
                        , input         [ 8*8-1:0] group        // packet
                        , output                   valid        // output vaild
                        , output        [ 8*8-1:0] ogroup       // output packet
                );
        wire [8*8-1:0] stream;
        wire [8*8-1:0] block;
        reg  [8*8-1:0] block_d;
        reg  [8*8-1:0] init_d;
        reg  [8*8-1:0] last_d;
        reg  [8*8-1:0] last_dd;
        reg  [8*8-1:0] en_d;
        reg  [8*8-1:0] en_dd;

        reg            busy;
        wire [8*8-1:0] ib;

        stream_cypher stream_cypher(
                            .clk   (clk)
                          , .rst   (rst)
                          , .en    (en)
                          , .init  (init)
                          , .ck    (ck)
                          , .sb    (group)
                          , .cb    (stream)
                        );

        block_decypher block_decypher (
                           .kk (kk)
                         , .ib (ib)
                         , .bd (block)
                        );


        always @(posedge clk)
                if(en_d)
                        block_d<=block;

        always @(posedge clk)
                if(en)
                        init_d<=init;

        always @(posedge clk)
                        last_dd<=last_d;

        always @(posedge clk)
                if(en)
                        last_d<=last;

        always @(posedge clk)
                        en_d<=en;

        always @(posedge clk)
                        en_dd<=en_d;

        assign ogroup=(en_dd&last_dd)?block_d:ib^block_d;

        assign valid=((busy)&en) | (en_dd&last_dd);

        assign ib=(init)?group:group^stream;

        always @(posedge clk )
                if(rst)
                        busy<=1'h0;
                else
                begin
                        if(init_d)
                                busy<=1'h1;
                        if(last_d)
                                busy<=1'h0;
                end
endmodule
