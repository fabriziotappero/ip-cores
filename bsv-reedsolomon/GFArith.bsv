//----------------------------------------------------------------------//
// The MIT License 
// 
// Copyright (c) 2008 Abhinav Agarwal, Alfred Man Cheuk Ng
// Contact: abhiag@gmail.com
// 
// Permission is hereby granted, free of charge, to any person 
// obtaining a copy of this software and associated documentation 
// files (the "Software"), to deal in the Software without 
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//----------------------------------------------------------------------//

//**********************************************************************
// Galois field arithmetic
//----------------------------------------------------------------------
// $Id: GFArith.bsv
//
		 
import GFTypes::*;
import Vector::*;

`include "GFInv.bsv"

// -----------------------------------------------------------
//(* noinline *) 
function Byte gf_mult(Byte left, Byte right);

   Bit#(15) first  = 15'b0;
   Bit#(15) result = 15'b0;
   
   // this function bring back higher degree values back to the field
   function Bit#(15) getNewResult(Integer shift, Bit#(15) res);
      Bit#(15) shiftPoly = zeroExtend(primitive_poly) << shift; 
      Bit#(15) newRes    = res ^ ((res[8+shift] == 1'b1) ? shiftPoly : 0); 
      return newRes;
   endfunction
   
  for (Integer i = 0; i < 8; i = i + 1)
     for (Integer j = 0; j < 8 ; j = j + 1)
        begin
           if (first[i+j] == 0) // initialize result[i+j]
              result[i+j] = (left[i] & right[j]);
           else                 // accumulate
              result[i+j] = result[i+j] ^ (left[i] & right[j]);
           first[i+j] = 1; // only initialize each signal once 
        end
   
  Vector#(7,Integer) shftAmntV = genVector;
  Bit#(15) finalResult = foldr(getNewResult,result,shftAmntV);
   
  return finalResult[7:0];

endfunction

(* noinline *)
function Byte gf_mult_inst(Byte x, Byte y);
   return gf_mult(x,y);
endfunction

// -----------------------------------------------------------
function Byte gf_add(Byte left, Byte right);
   return (left ^ right);
endfunction

(* noinline *)
function Byte gf_add_inst(Byte x, Byte y);
   return gf_add(x,y);
endfunction


// -----------------------------------------------------------
//(* noinline *) 
function Byte alpha_n(Byte n);
	return times_alpha_n(1,n);
endfunction

// -----------------------------------------------------------
//(* noinline *) 
function Byte times_alpha_n(Byte a, Byte n);
//    Byte multVal = 1 << n;
//    return gf_mult(primitive_poly,a,multVal);

   Byte b=a;
   for (Byte i = 0; i < n; i = i + 1)
      b=times_alpha(b);
   return b;
endfunction

// -----------------------------------------------------------
//(* noinline *) 
function Byte times_alpha(Byte a);
//   return gf_mult(primitive_poly, a, 2);

   return (a<<1)^({a[7],a[7],a[7],a[7],a[7],a[7],a[7],a[7]} & primitive_poly);
endfunction

// -----------------------------------------------------------
/*
function Byte gf_inv (Byte a);

   case (a) matches
        0 : return         2;
        1 : return         1;
        2 : return       142;
        3 : return       244;
        4 : return        71;
        5 : return       167;
        6 : return       122;
        7 : return       186;
        8 : return       173;
        9 : return       157;
       10 : return       221;
       11 : return       152;
       12 : return        61;
       13 : return       170;
       14 : return        93;
       15 : return       150;
       16 : return       216;
       17 : return       114;
       18 : return       192;
       19 : return        88;
       20 : return       224;
       21 : return        62;
       22 : return        76;
       23 : return       102;
       24 : return       144;
       25 : return       222;
       26 : return        85;
       27 : return       128;
       28 : return       160;
       29 : return       131;
       30 : return        75;
       31 : return        42;
       32 : return       108;
       33 : return       237;
       34 : return        57;
       35 : return        81;
       36 : return        96;
       37 : return        86;
       38 : return        44;
       39 : return       138;
       40 : return       112;
       41 : return       208;
       42 : return        31;
       43 : return        74;
       44 : return        38;
       45 : return       139;
       46 : return        51;
       47 : return       110;
       48 : return        72;
       49 : return       137;
       50 : return       111;
       51 : return        46;
       52 : return       164;
       53 : return       195;
       54 : return        64;
       55 : return        94;
       56 : return        80;
       57 : return        34;
       58 : return       207;
       59 : return       169;
       60 : return       171;
       61 : return        12;
       62 : return        21;
       63 : return       225;
       64 : return        54;
       65 : return        95;
       66 : return       248;
       67 : return       213;
       68 : return       146;
       69 : return        78;
       70 : return       166;
       71 : return         4;
       72 : return        48;
       73 : return       136;
       74 : return        43;
       75 : return        30;
       76 : return        22;
       77 : return       103;
       78 : return        69;
       79 : return       147;
       80 : return        56;
       81 : return        35;
       82 : return       104;
       83 : return       140;
       84 : return       129;
       85 : return        26;
       86 : return        37;
       87 : return        97;
       88 : return        19;
       89 : return       193;
       90 : return       203;
       91 : return        99;
       92 : return       151;
       93 : return        14;
       94 : return        55;
       95 : return        65;
       96 : return        36;
       97 : return        87;
       98 : return       202;
       99 : return        91;
      100 : return       185;
      101 : return       196;
      102 : return        23;
      103 : return        77;
      104 : return        82;
      105 : return       141;
      106 : return       239;
      107 : return       179;
      108 : return        32;
      109 : return       236;
      110 : return        47;
      111 : return        50;
      112 : return        40;
      113 : return       209;
      114 : return        17;
      115 : return       217;
      116 : return       233;
      117 : return       251;
      118 : return       218;
      119 : return       121;
      120 : return       219;
      121 : return       119;
      122 : return         6;
      123 : return       187;
      124 : return       132;
      125 : return       205;
      126 : return       254;
      127 : return       252;
      128 : return        27;
      129 : return        84;
      130 : return       161;
      131 : return        29;
      132 : return       124;
      133 : return       204;
      134 : return       228;
      135 : return       176;
      136 : return        73;
      137 : return        49;
      138 : return        39;
      139 : return        45;
      140 : return        83;
      141 : return       105;
      142 : return         2;
      143 : return       245;
      144 : return        24;
      145 : return       223;
      146 : return        68;
      147 : return        79;
      148 : return       155;
      149 : return       188;
      150 : return        15;
      151 : return        92;
      152 : return        11;
      153 : return       220;
      154 : return       189;
      155 : return       148;
      156 : return       172;
      157 : return         9;
      158 : return       199;
      159 : return       162;
      160 : return        28;
      161 : return       130;
      162 : return       159;
      163 : return       198;
      164 : return        52;
      165 : return       194;
      166 : return        70;
      167 : return         5;
      168 : return       206;
      169 : return        59;
      170 : return        13;
      171 : return        60;
      172 : return       156;
      173 : return         8;
      174 : return       190;
      175 : return       183;
      176 : return       135;
      177 : return       229;
      178 : return       238;
      179 : return       107;
      180 : return       235;
      181 : return       242;
      182 : return       191;
      183 : return       175;
      184 : return       197;
      185 : return       100;
      186 : return         7;
      187 : return       123;
      188 : return       149;
      189 : return       154;
      190 : return       174;
      191 : return       182;
      192 : return        18;
      193 : return        89;
      194 : return       165;
      195 : return        53;
      196 : return       101;
      197 : return       184;
      198 : return       163;
      199 : return       158;
      200 : return       210;
      201 : return       247;
      202 : return        98;
      203 : return        90;
      204 : return       133;
      205 : return       125;
      206 : return       168;
      207 : return        58;
      208 : return        41;
      209 : return       113;
      210 : return       200;
      211 : return       246;
      212 : return       249;
      213 : return        67;
      214 : return       215;
      215 : return       214;
      216 : return        16;
      217 : return       115;
      218 : return       118;
      219 : return       120;
      220 : return       153;
      221 : return        10;
      222 : return        25;
      223 : return       145;
      224 : return        20;
      225 : return        63;
      226 : return       230;
      227 : return       240;
      228 : return       134;
      229 : return       177;
      230 : return       226;
      231 : return       241;
      232 : return       250;
      233 : return       116;
      234 : return       243;
      235 : return       180;
      236 : return       109;
      237 : return        33;
      238 : return       178;
      239 : return       106;
      240 : return       227;
      241 : return       231;
      242 : return       181;
      243 : return       234;
      244 : return         3;
      245 : return       143;
      246 : return       211;
      247 : return       201;
      248 : return        66;
      249 : return       212;
      250 : return       232;
      251 : return       117;
      252 : return       127;
      253 : return       255;
      254 : return       126;
      255 : return       253;
   endcase
endfunction
*/
