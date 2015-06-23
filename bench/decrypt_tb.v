
// this is the test bench for decrypt module


`include "../bench/timescale.v"

module decrypt_tb;

reg clk;
reg rst;



integer bytes;
integer out_bytes;
integer offset;

reg      [  8*8-1   : 0]  even_cw;
reg      [  8*8-1   : 0]  odd_cw;
reg      [    8-1   : 0]  encrypted_byte;

reg      [8*8-1:0]    ck;
reg                   even_odd;
reg                   en;
reg                   key_en;
reg      [  8-1:0]    enc;
wire     [  8-1:0]    dec;
wire                  valid;

initial
begin
        $read_data(
                                "../test_dat/decrypt.in"
                               ,even_cw
                  );

        $read_data(
                                "../test_dat/decrypt.in"
                               ,8
                               ,odd_cw
                  );

        encrypted_byte=8'h00; // or can not read data
        out_bytes = 1;

        en=0;
        key_en=0;
        
        repeat(14)@(posedge clk);

        // set even cw 
        @(posedge clk);
        ck=even_cw;
        en=0;
        even_odd=0;
        @(posedge clk);
        key_en=1;
        @(posedge clk);
        key_en=0;
        repeat (11) @(posedge clk);

        // set odd key
        @(posedge clk);
        ck=odd_cw;
        en=0;
        even_odd=1;
        @(posedge clk);
        key_en=1;
        @(posedge clk);
        key_en=0;
        repeat (11)@(posedge clk);

        repeat(4)@(posedge clk);

        // decrypt
        for(bytes=1;bytes<=188;bytes=bytes+1)
        begin
                offset=16+(bytes-1);
                $read_data( 
                                   "../test_dat/decrypt.in"
                                ,  offset
                                ,  encrypted_byte
                        );
                enc=encrypted_byte;
                en=1;
              //  @(posedge clk);
              //  en=0;
                @(posedge clk);
        end

        repeat(44) @(posedge clk);


        $stop;
        
end

always @(posedge clk)
        if(valid)
        begin
                if(out_bytes==1)
                begin
        $write_data(
                                 "../test_dat/decrypt.out.v"
                                ,dec
                   );
                end
                else
                begin
        $write_data(
                                 "../test_dat/decrypt.out.v"
                                ,"a"
                                ,dec
                   );
                end
                out_bytes=out_bytes+1;
        end


decrypt b(
                  .clk        (clk)
                , .rst        (rst)
                , .ck         (ck)
                , .key_en     (key_en)
                , .even_odd   (even_odd)
                , .en         (en)
                , .encrypted  (enc)
                , .decrypted  (dec)
                , .valid      (valid)
                );




initial
begin
        clk<=1'b0;        
        forever #5 clk=~clk;
end

initial
begin
        rst<=1'b1;        
        @(posedge clk);
        @(posedge clk);
        rst=1'h0;
end
endmodule
