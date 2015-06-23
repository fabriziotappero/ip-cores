


// this file control led segment controler module


module ledseg_cnt(
                         input               clk        // clock
                       , input               rst        // reset , high active
                       , input      [15:0]   data       // the data want output at led segment
                       , output reg [ 3:0]   seg        // led segment scan signal
                       , output     [ 7:0]   segd       // led segment output
                ); 


`define CNT_W 15    // count reg width

        // interival variable
        reg [`CNT_W-1:0] cnt;

        always @(posedge clk)
                cnt<=cnt+`CNT_W'h1;      // up reg
                        
        reg [3:0] h;
        always @(cnt or data)
        begin
                case (cnt[`CNT_W-1:`CNT_W-2])
                        2'b00:h <= data[15:12]; 
                        2'b01:h <= data[11: 8]; 
                        2'b10:h <= data[ 7: 4]; 
                        2'b11:h <= data[ 3: 0]; 
                endcase
        end

        always @(cnt)
        begin
                case (cnt[`CNT_W-1:`CNT_W-2])
                        2'b00:seg = 4'b1110; 
                        2'b01:seg = 4'b1101; 
                        2'b10:seg = 4'b1011; 
                        2'b11:seg = 4'b0111; 
                endcase
        end

        hex2seg h2s(
                  .hex(h)
                , .seg(segd)
                );


endmodule
