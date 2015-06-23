
// ///////////////////////////////////////////////////////////////////
//
// 2 -bit constellation map
//
// ///////////////////////////////////////////////////////////////////
module const_map_2bit;

`include "parameters.vh"

reg signed [CONSTW-1:0] re [0:3];
reg signed [CONSTW-1:0] im [0:3];


initial begin : init_2bit
  re[0] = 1; im[0] = 1;
  re[1] = 1; im[1] = -1;
  re[2] = -1; im[2] = 1;
  re[3] = -1; im[3] = -1;
end

endmodule


// ///////////////////////////////////////////////////////////////////
//
// 3 -bit constellation map
//
// ///////////////////////////////////////////////////////////////////
module const_map_3bit;

`include "parameters.vh"

reg signed [CONSTW-1:0] re [0:7];
reg signed [CONSTW-1:0] im [0:7];


initial begin
  re[0] =  1; im[0] =  1;
  re[1] =  1; im[1] = -1;
  re[2] = -1; im[2] =  1;
  re[3] = -1; im[3] = -1;
  re[4] = -3; im[4] =  1;
  re[5] =  1; im[5] =  3;
  re[6] = -1; im[6] = -3;
  re[7] =  3; im[7] = -1;
end

endmodule

// ///////////////////////////////////////////////////////////////////
//
// 4 -bit constellation map
//
// ///////////////////////////////////////////////////////////////////
module const_map_4bit;

`include "parameters.vh"

reg signed [CONSTW-1:0] re [0:15];
reg signed [CONSTW-1:0] im [0:15];


initial begin
  re[0] =  1; im[0] =  1;
  re[1] =  1; im[1] =  3;
  re[2] =  3; im[2] =  1;
  re[3] =  3; im[3] =  3;
  re[4] =  1; im[4] = -3;
  re[5] =  1; im[5] = -1;
  re[6] =  3; im[6] = -3;
  re[7] =  3; im[7] = -1;
  re[8] = -3; im[8] =  1;
  re[9] =  -3; im[9] =  3;
  re[10] = -1; im[10] =  1;
  re[11] = -1; im[11] =  3;
  re[12] = -3; im[12] = -3;
  re[13] = -3; im[13] = -1;
  re[14] = -1; im[14] = -3;
  re[15] = -1; im[15] = -1;
end

endmodule

// ///////////////////////////////////////////////////////////////////
//
// 5 -bit constellation map
//
// ///////////////////////////////////////////////////////////////////
module const_map_5bit;

`include "parameters.vh"

reg signed [CONSTW-1:0] re [0:31];
reg signed [CONSTW-1:0] im [0:31];


initial begin
  re[0] =  1; im[0] =  1;
  re[1] =  1; im[1] =  3;
  re[2] =  3; im[2] =  1;
  re[3] =  3; im[3] =  3;
  re[4] =  1; im[4] = -3;
  re[5] =  1; im[5] = -1;
  re[6] =  3; im[6] = -3;
  re[7] =  3; im[7] = -1;
  re[8] = -3; im[8] =  1;
  re[9] =  -3; im[9] =  3;
  re[10] = -1; im[10] =  1;
  re[11] = -1; im[11] =  3;
  re[12] = -3; im[12] = -3;
  re[13] = -3; im[13] = -1;
  re[14] = -1; im[14] = -3;
  re[15] = -1; im[15] = -1;
  re[16] =  5; im[16] =  1;
  re[17] =  5; im[17] =  3;
  re[18] = -5; im[18] =  1;
  re[19] = -5; im[19] =  3;
  re[20] =  1; im[20] =  5;
  re[21] =  1; im[21] = -5;
  re[22] =  3; im[22] =  5;
  re[23] =  3; im[23] = -5;
  re[24] = -3; im[24] =  5;
  re[25] = -3; im[25] = -5;
  re[26] = -1; im[26] =  5;
  re[27] = -1; im[27] = -5;
  re[28] =  5; im[28] = -3;
  re[29] =  5; im[29] = -1;
  re[30] = -5; im[30] = -3;
  re[31] = -5; im[31] = -1;
end

endmodule
