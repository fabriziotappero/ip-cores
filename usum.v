`timescale 1ns / 1ps

/* Unsigned BCD sum */
module usum(input [16:0] a, input [12:0] b, output [16:0] z);
  wire c0, c1, c2, c3;
  digitadd add1(a[3:0],b[3:0],1'b0,z[3:0],c0);
  digitadd add2(a[7:4],b[7:4],c0,z[7:4],c1);
  digitadd add3(a[11:8],b[11:8],c1,z[11:8],c2);
  digitadd add4(a[15:12],b[12]?4'h9:4'h0,c2,z[15:12],c3);
  assign z[16]=a[16]+b[12]+c3;

endmodule