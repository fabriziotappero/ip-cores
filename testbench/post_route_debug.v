`include "../rtl/inc.v"
/* purpose of this module is ISE post-route simulation */
/* if you don't use Xilinx ISE, please ignore this file :) */
module post_route_debug(clk, reset, x1, y1, x2, y2, done, ok);
    input clk, reset;
    input [`WIDTH:0] x1, y1, x2, y2;
    output done, ok;
    
    wire [`W6:0] out;
    
    tate_pairing
        ins1 (clk, reset, x1, y1, x2, y2, done, out);
    
    assign ok = (out == {{194'h148a60225a14a81189aa09a22848104418aa6505801246205,194'h520094820010a12551069915258a58848501052005a85609},{194'ha484046591204499252009806480198a2549624a5181695,194'h21905848428558a806805a4518844049651812a88955a8868},{194'h5565059245921805891121a95a6949564201a2a068910558,194'ha6298884510610298462582969269a122260a05a8241055a}});
endmodule

