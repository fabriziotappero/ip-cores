// the usb controler module

// now this control support 3 endpoint
// ep2, output data
// ep6, input data
// ep8, input data

module usb_cnt  (
                         input               clk
                       , output              pktend  // 
                       , output  reg         sloe    // output enable , high active
                       , output  reg         slwr    // fifo write signal, low active
                       , output              slcs    // fifo chip select, low active
                       , output  reg         slrd    // fifo read , low active
                       , output  reg  [ 1:0] fifoadr // fifo address, 00-ep2 01 -- ep4 10--ep6 11--pe8
                       , inout        [15:0] fd      // data bus
                    // endpoint data ports
                    // ep2
                       , input               ep2_t    // ep2 full flag, low active
                       , output              ep2_busy // ep2 busy, high active
                       , input               ep2_wr   // ep2 write signal
                       , input        [15:0] ep2_data
                    // ep6
                       , input               ep6_t   // ep6 empty flag, low active
                       , output              ep6_f   // ep6 have data coming
                       , output       [15:0] ep6_data
                    // ep8
                       , input               ep8_t   // ep8 empty flag, low active
                       , output              ep8_f   // ep8 have data coming
                       , output       [15:0] ep8_data
                );

`define EP2_W  2'h3
`define EP6_R  2'h2
`define EP8_R  2'h1
`define NO_ACT 2'h0

                reg [1:0] last_action;      // the active in lost clck

                reg [15:0] usb_dat_in;      // the data coming from fd
                reg [15:0] usb_dat_out;     // the data upgoing to fd
                reg        oe;

                assign pktend = 1'h1;
                assign slcs   =1'h0;

                always @(posedge clk)
                        if(ep2_t&ep2_wr)
                        begin
                                sloe <= 1'h0;
                                oe <= 1'h1;
                                slrd<=1'h1;
                                slwr<=1'h0;
                                last_action<=`EP2_W;
                                fifoadr<=2'h0;
                        end
                        else if(ep6_t)
                        begin
                                sloe <= 1'h0;
                                oe <= 1'h0;
                                slrd<=1'h0;
                                slwr<=1'h1;
                                last_action<=`EP6_R;
                                fifoadr<=2'h2;
                        end
                        else if(ep8_t)
                        begin
                                sloe <= 1'h0;
                                oe <= 1'h0;
                                slrd<=1'h0;
                                slwr<=1'h1;
                                last_action<=`EP8_R;
                                fifoadr<=2'h3;
                        end
                        else
                        begin
                                sloe <= 1'h1;
                                oe <= 1'h1;
                                slrd<=1'h1;
                                slwr<=1'h1;
                                last_action<=`NO_ACT;
                                fifoadr<=2'h0;
                        end

                assign ep6_data=fd;
                assign ep6_f=last_action==`EP6_R;
                assign ep8_data=fd;
                assign ep8_f=last_action==`EP8_R;
                assign fd=(oe)?ep2_data:16'hzzzz;
                assign ep2_busy=~ep2_t;

endmodule
