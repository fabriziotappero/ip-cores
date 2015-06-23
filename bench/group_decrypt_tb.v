

// this is the test bench for decrypt module


`include "../bench/timescale.v"

module group_decrypt_tb;

reg clk;
reg rst;


reg     [ 8*8-1:0]    ck;
reg                   ks_start;
reg                   init;
reg                   last;
reg                   gd_en;
wire   [ 8*8-1:0]     dec_packet;
reg    [ 8*8-1:0]     enc_packet;
wire   [56*8-1:0]     kk;
wire                  valid;
integer               ii;
integer               jj;
integer               offset;
initial
begin
        $read_data(
                                "../test_dat/group_decrypt.in"
                               ,ck
                  );


        init=1'h0; 

        // calculate kk
        repeat(4) @(posedge clk)
        ks_start=1'h1;
        @(posedge clk);
        ks_start=1'h0;
        repeat(14) @(posedge clk)
        jj=0;
        $display("kk=%x",kk);

        // input encrypt packets
        offset=8+(0)*8;
        $read_data(
                         "../test_dat/group_decrypt.in"
                       , offset
                       , enc_packet);
        init=1'h1; 
        last=1'h0;
        gd_en=1'h1;
        @(posedge clk);

        for(ii=1;ii<23-1;ii=ii+1)
        begin
                init=1'h0; 
                last=1'h0;
                gd_en=1'h1;
                offset=8+(ii)*8;
                $read_data(
                                 "../test_dat/group_decrypt.in"
                               , offset
                               , enc_packet);
                @(posedge clk);
        end

        offset=8+(23-1)*8;
        $read_data(
                         "../test_dat/group_decrypt.in"
                       , offset
                       , enc_packet);
        init=1'h0; 
        last=1'h1;
        gd_en=1'h1;
        @(posedge clk);
        gd_en=1'h0;

        repeat(10)@(posedge clk);

        $stop;
        
end

always @(posedge clk)
        if(valid)
        begin
                if(jj==0)
                begin
                        $write_data(
                                         "../test_dat/group_decrypt.out.v"
                                       , dec_packet);
                        jj=1;
                end
                else
                        $write_data(
                                         "../test_dat/group_decrypt.out.v"
                                       , "a"
                                       , dec_packet);
        end



group_decrypt group_decrypt(
                          . clk     (clk) 
                        , . rst     (rst) 
                        , . en      (gd_en) 
                        , . init    (init) 
                        , . last    (last) 
                        , . ck      (ck) 
                        , . kk      (kk) 
                        , . group   (enc_packet) 
                        , . valid   (valid) 
                        , . ogroup  (dec_packet) 
                );

key_schedule key_schedule(
                  .clk        (clk)
                , .rst        (rst)
                , .start      (ks_start)
                , .ck         (ck)
                , .busy       ()
                , .done       ()
                , .kk         (kk)
                );



initial
begin
        clk=1'b0;        
        forever #5 clk=~clk;
end

initial
begin
        rst=1'b1;        
        @(posedge clk);
        @(posedge clk);
        rst=1'h0;
end
endmodule
