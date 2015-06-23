
// this file 
// led controler

module led_cnt(
                         input              clk             // clock
                       , input              rst             // reset , high active
                       , input              scan            
                       , output reg [7:0]   led
                );

        reg scan_l;

        always @(posedge clk)
                scan_l <= scan;

        always @(posedge clk)
                if(~rst)
                        led <= 8'hfe;
                else if (scan & ~scan_l)
                        led <= {led[0],led[7:1]};
endmodule
