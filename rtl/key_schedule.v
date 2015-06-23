`include "../bench/timescale.v"
// this key_schedule module
module key_schedule(clk,rst,start,ck,busy,done,kk);
        input             clk;        // main clock
        input             rst;        // reset , high active
        input             start;      // start key 
        input  [ 8*8-1:0] ck;
        output            busy;
        output            done; // one clck width
        output [56*8-1:0] kk;

        wire   [56*8-1:0] kk;
        reg               busy;

////////////////////////////////////////////////////////////////////////////////
// internal variable
////////////////////////////////////////////////////////////////////////////////
        reg   [56*8-1:0] kk_arry;       // the key array
        reg   [     2:0] cnt;
        wire  [ 8*8-1:0] next_kk;       // the next roundl kk


        always @(posedge clk )
        if(rst)
                cnt<=3'h0;
        else if(start)
                cnt <= 3'h6;
        else if(cnt!=3'h0)
                cnt <= cnt-3'h1;


        always @(posedge clk)
        if(rst)
                busy=1'h0;
        else if(start)
                busy<=1'h1;                
        else if(cnt==3'h0)
                busy<=1'h0;

        assign done=busy & (cnt==3'h0);

        always @(posedge clk )
        if(rst)
                kk_arry<=448'h0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
        else if(start)
                kk_arry<={kk_arry[48*8-1:0],ck};
        else if(cnt!=3'h0)
                kk_arry<={kk_arry[48*8-1:0],next_kk};

        assign kk=kk_arry ^ {
                                64'h0606060606060606,
                                64'h0505050505050505,
                                64'h0404040404040404,
                                64'h0303030303030303,
                                64'h0202020202020202,
                                64'h0101010101010101,
                                64'h0000000000000000
                                };

        key_perm kpi(.i_key(kk_arry[8*8-1:0]), .o_key(next_kk));

endmodule
