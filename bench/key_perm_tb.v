
// this is the testbench file for key_perm module

`timescale 10ns/1ns
module key_perm_tb;

integer ofile;

reg  [63:0]i_key;
wire [63:0]o_key;

initial
begin
        // read the input key
        $read_data(
                                "../test_dat/key_perm.in"
                               ,i_key
                  );
        #10;

        // output the permated key
        $write_data(
                        "../test_dat/key_perm.out.v"
                       ,"w"
                       ,o_key
                   );
        $finish;
end

key_perm k(
                 .i_key(i_key)
                ,.o_key(o_key)
        );

endmodule
