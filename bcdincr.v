`timescale 1us/1ns
// Unsigned increment
// based off bcdadd but assume no negatives
// This is used for the bug (shorter bit length)
// and for BCD adding

module bcdincr(input [16:0] a, output [16:0] z);
/*
// {c3,p,q,r} = a+b
// c1 and c2 are intermediate carrys
// a1, a2, a3 and b1, b2, b3 are
// digits
   wire [3:0] p;
   wire [3:0] p0;
   wire [3:0] a0;
   wire       c1;
   wire [3:0] q;
   wire [3:0] a1;
   wire       c2;
   wire [3:0] r;
   wire [3:0] a2;
   wire       c3,c4;
   wire [3:0] a3;

// split digits
   assign a0=a[3:0];
   assign a1=a[7:4];
   assign a2=a[11:8];
   assign a3=a[15:12];


// Use the digit add block
// and propagate carry
   digitadd add1(a0,4'b1,1'b0,r,c1);  
   digitadd add2(a1,4'b0,c1,q,c2);
   digitadd add3( a2,4'b0 ,c2,p,c3);
   digitadd add4( a3,4'b0 ,c3,p0,c4);
// build up result
   assign z={ a[16]+c4,p0,p,q,r};
	*/
	usum inc(a,13'h1,z);
endmodule
