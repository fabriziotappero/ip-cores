

// this file is the test circuit
// author: Simom Panti
//


module csa_fpga(
                          output              bell
                        , input               clk
                        , input               rst
                        , input               flaga
                        , input               flagb
                        , input               flagc
                        , output              slcs
                        , output              pktend
                        , output reg          sloe
                        , output reg          slwr
                        , output reg          slrd
                        , output reg [ 1:0]   fifoadr
                        , inout      [15:0]   fd
                        , input               ifclk
                     //   , output     [ 7:0]   led
                        , output     [ 3:0]   ledseg
                        , output     [ 7:0]   seg_d
             );


        wire usbclk = ifclk;

        assign bell = 1'h1;


        reg [15:0] data_r;
        wire ep2_busy;
        wire ep6_f;
        wire [15:0] ep6_data;

        always @(posedge usbclk)
                if(~ep2_busy)
                        data_r<= data_r + 16'h1;

	////////////////////////////////////////////////////////////////////////////////
        // led segement control
	////////////////////////////////////////////////////////////////////////////////
        
        ledseg_cnt ledseg_cnt(
                         .clk      (usbclk)
                       , .rst      (rst)
                       , .data     (data_r)
                       , .seg      (ledseg)
                       , .segd     (seg_d)
                        );

        ////////////////////////////////////////////////////////////////////////////////
        // usb interface
        ////////////////////////////////////////////////////////////////////////////////

        usb_cnt usb_cnt(
                         .clk     (usbclk)    
                       , .pktend  (pktend)
                       , .sloe    (sloe)
                       , .slwr    (slwr)
                       , .slcs    (slcs)
                       , .slrd    (slrd)
                       , .fifoadr (fifoadr)
                       , .fd      (fd)
                       , .ep2_t   (flagc) 
                       , .ep2_busy(ep2_busy) 
                       , .ep2_wr  (data_r[0]) 
                       , .ep2_data(data_r)
                       , .ep6_t   (flaga)
                       , .ep6_f   (ep6_f)
                       , .ep6_data(ep6_data)
                       , .ep8_t   (flagb)
                       , .ep8_f   ()
                       , .ep8_data()
                        );


        ////////////////////////////////////////////////////////////////////////////////
        // csa decrypt module
        ////////////////////////////////////////////////////////////////////////////////
        decrypt csa_decrypt(
                                 . clk            (usbclk)
                                ,. rst            (rst)
                                ,. ck             (64'h0000000000000000)
                                ,. key_en         (1'h0)
                                ,. even_odd       (1'h0)
                                ,. en             (ep6_f)
                                ,. encrypted      (ep6_data[7:0])
                                ,. decrypted      ()
                                ,. valid        ()
                    );

        
endmodule

