
`include "../bench/timescale.v"
// this module probe the ts sync head,

module ts_sync(
               input                 clk
             , input                 rst
             , input                 en        
             , input         [8-1:0] datain
             , output  reg           valid
             , output  reg           head     // find ts packet head
             , output  reg           init     // the first dec ts packet
             , output  reg           dec      // this ts group need decrypt
             , output  reg           evenodd  // the current key type
             , output  reg [8*8-1:0] group 
             , output  reg     [3:0] bytes    // valid bytes in group
        );
        reg sync; 
        reg need_dec; // current packet need decrypt;
        reg [8*8-1:0] group_d;
        reg [7:0] ts_cnt; // 

        always @(posedge clk)
                if(rst)
                begin
                        valid<=1'h0;
                        head<=1'h0;
                        dec<=1'h0;
                        sync<=1'h0;
                        need_dec<=1'h0;
                        ts_cnt<=8'h0; 
                        init<=1'h0;
                end
                else
                begin
                        head<=1'h0;
                        dec<=1'h0;
                        valid<=1'h0;
                        init<=1'h0;

                        if(en) 
                        begin
                                group_d <= {datain, group_d[8*8-1:1*8] };
                        end
                        if(sync)
                        begin
                                if(ts_cnt==8'h1&&en)
                                begin
                                        need_dec<=1'h0;
                                        sync<=1'h0; // ts packet end

                                end
                                if(ts_cnt[2:0]==3'h1&&en)
                                begin
                                        valid<=1'h1;
                                        dec<=need_dec;
                                        bytes<=4'h8;
                                        group   <={datain, group_d[8*8-1:1*8] } ;

                                end
                                if(ts_cnt==8'hb1&en)
                                        init<=1'h1;
                                if(en)
                                        ts_cnt <= ts_cnt - 8'h1;
                        end
                        if(en)
                        begin
                                if(group_d[6*8-1:5*8]==8'h47)
                                begin
                                        sync<=1'h1;
                                        valid<=1'h1;
                                        head<=1'h1;
                                        bytes<=4'h4;
                                        group <= {32'h000,1'h0,datain[6:0],group_d[8*8-1:5*8]};
                                        evenodd <= datain[6];
                                        need_dec<=datain[7];
                                        ts_cnt <= 8'hb8;
                                end
                        end
                end
endmodule
