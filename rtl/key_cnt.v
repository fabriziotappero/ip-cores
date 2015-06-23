`include "../bench/timescale.v"

// this module manage two keys (odd even)

module key_cnt( 
                  input                    clk
                , input                    rst
                , input                    en
                , input                    evenodd
                , input         [8*8-1:0]  ck_in
                , output                   busy
                , output  reg   [8*8-1:0]  odd_ck
                , output  reg  [56*8-1:0]  odd_kk
                , output  reg   [8*8-1:0]  even_ck
                , output  reg  [56*8-1:0]  even_kk
                 );

        reg           evenodd_d;
        wire          done;
        wire [56*8-1:0] kk;

        always @(posedge clk)
                if(rst)
                begin
                        even_ck <=  64'h0000000000000000;
                        odd_ck <=  64'h0000000000000000;
                end
                else
                if(en & ~busy)
                begin
                        evenodd_d<=evenodd;
                        if(evenodd)
                                odd_ck<=ck_in;
                        else
                                even_ck<=ck_in;
                end

        always @(posedge clk)
                if(rst)
                begin
                        even_kk <=  448'h0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;       
                        odd_kk <=  448'h0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;       
                end
                else
                if(done)
                begin
                        if(evenodd_d)
                                odd_kk<=kk;
                        else
                                even_kk<=kk;
                end


key_schedule key_schedule( 
                        .clk  (clk)
                      , .rst  (rst)
                      , .start(en&~busy)
                      , .busy (busy)
                      , .done (done)
                      , .ck   (ck_in)
                      , .kk   (kk)
               );

endmodule
