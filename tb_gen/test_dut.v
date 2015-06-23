
module test_mod (

);
//   comment 1
input  rst_n, clk, sel, sig1, sig2,
       sig3,sig4,sig5,
       sig6, sig7, sig8;
output o1, o2,o3,data_valid,o4, o5;
//  comment 2
input [31:0] addr,  dat_in, inv1,
   test_bus, ctl_bus;
input singlei;
output singleo;
output [31:0]  response, dat_out,B1,B2,b3;

input [8:0] singlei1;
output [8:0] singleo1;
inout io1,io2, io3, io4;

endmodule