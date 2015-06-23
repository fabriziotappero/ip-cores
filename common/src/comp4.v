/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 1-of-4 data comparator
 
 History:
 11/05/2010  Initial version. <wsong83@gmail.com>
 01/06/2011  Clean up for opensource. <wsong83@gmail.com>
 
*/

module comp4 (/*AUTOARG*/
   // Outputs
   q,
   // Inputs
   a, b
   );

   input [3:0]   a, b;		// the data inputs to be compared
   output [2:0]  q;		// the comparison result

   // a > b
   assign q[0] = (a[3]&(|b[2:0])) | (a[2]&(|b[1:0])) | (a[1]&(|b[0:0]));

   // a < b
   assign q[1] = (a[2]&(|b[3:3])) | (a[1]&(|b[3:2])) | (a[0]&(|b[3:1]));

   // a = b
   assign q[2] = (a[3]&b[3]) | (a[2]&b[2]) | (a[1]&b[1]) | (a[0]&b[0]);

endmodule // comp4
