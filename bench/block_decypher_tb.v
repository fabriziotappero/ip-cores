// this is the test bench for block_decypher module

`timescale 10ns/1ns
module block_decypher_tb;
       reg      [64*8-1:0] tt;
       reg      [56*8-1:0] kk;
       reg      [8*8-1:0]  ib;
       wire     [8*8-1:0]  bd; 

initial
begin
        $read_data(
                                "../test_dat/block_decypher.in"
                               ,tt
                  );

        kk=tt [64*8-1:8*8];
        ib=tt [8*8-1:0];

        #10;

        $write_data(
                                 "../test_dat/block_decypher.out.v"
                                ,"w"
                                ,bd
                   );
`ifdef DEBUG
        $write_data(
                                 "../test_dat/block_decypher.out.v"
                                ,"a"
                                ,kk
                   );
        $write_data(
                                 "../test_dat/block_decypher.out.v"
                                ,"a"
                                ,ib
                   );
`endif
        
end

block_decypher b(
                         .kk(kk)
                        ,.ib(ib)
                        ,.bd(bd)
                );
endmodule
