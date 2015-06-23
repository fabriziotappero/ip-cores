
`include "../bench/timescale.v"
// this module will do csa decrypt work

module decrypt(clk,rst,ck,key_en,even_odd,en,encrypted,decrypted,valid);
input             clk;
input             rst;
input             key_en;    // signal high valid,
input             even_odd;  // indiate the input ck is even or odd, 0 --- even odd ---odd
input             en;        // decrypted
input  [8*8-1:0]  ck;        // input ck
input  [  8-1:0]  encrypted; // input ts stream
output [  8-1:0]  decrypted; // decrypt ts stream
output            valid;     // output data is valid

wire [ 8*8-1:0] odd_ck;
wire [ 8*8-1:0] even_ck;
wire [56*8-1:0] odd_kk;
wire [56*8-1:0] even_kk;


// key register 
key_cnt key_cnt(
                  .clk        (clk)
                , .rst        (rst)
                , .en         (key_en)
                , .evenodd    (even_odd)
                , .ck_in      (ck)
                , .busy       ()
                , .odd_ck     (odd_ck)
                , .odd_kk     (odd_kk)
                , .even_ck    (even_ck)
                , .even_kk    (even_kk)
                );

wire  ts_valid;
wire  ts_init;
wire  ts_head;
wire  ts_dec;
wire  ts_evenodd;
wire [8*8-1:0]group;
wire [3:0] bytes;


ts_sync ts_sync(
               . clk      (clk)
             , . rst      (rst)
             , . en       (en) 
             , . datain   (encrypted)
             , . valid    (ts_valid)
             , . head     (ts_head)
             , . dec      (ts_dec)
             , . init     (ts_init)
             , . evenodd  (ts_evenodd)
             , . group    (group)
             , . bytes    (bytes)
        );

wire dec_valid;
wire [8*8-1:0]ogroup;
wire [  4-1:0]obytes;
group_decrypt group_decrypt(
                          .clk     (clk)
                        , .rst     (rst)
                        , .en      (ts_valid)
                        , .dec     (ts_dec)
                        , .init    (ts_init)
                        , .ck      (ts_evenodd?even_ck:odd_ck)
                        , .kk      (ts_evenodd?even_kk:odd_kk)
                        , .group   (group)
                        , .bytes   (bytes)
                        , .valid   (dec_valid)
                        , .ogroup  (ogroup)
                        , .obytes  (obytes)
                );

ts_serial_out ts_serial_out(
                          .clk      (clk)
                        , .rst      (rst)
                        , .group    (ogroup)
                        , .bytes    (obytes)
                        , .en       (dec_valid)
                        , .dec      (decrypted)
                        , .valid    (valid)
                        );


endmodule
