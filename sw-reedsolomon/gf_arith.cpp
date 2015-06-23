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

/*
  Incorporates all GF arithmetic used in various modules
*/
//#include "ac_int.h"
#include "gf_arith.h"
 

unsigned char gfadd_hw(unsigned char a, unsigned char b)
{
    return a^b;
}

unsigned char gfmult_hw(unsigned char a, unsigned char b)
{

   unsigned int temp = 0;

   // Directive: Unroll loop maximally
   for (int i = 0; i < 8; i++)
      if (b & (1 << i))
         temp ^= (unsigned int)(a << i);
         
   // Directive: Unroll loop maximally 
   for (int k = 15; k > 7; k--)
      if (temp & (1 << k)) 
	     temp ^= (unsigned int)(pp_char << (k - 8));
    
   return (temp & 255);
   
}

unsigned char alpha (unsigned char n)
{
    unsigned char alpha_lut[256] = { 
        1,
        2,
        4,
        8,
        16,
        32,
        64,
        128,
        29,
        58,
        116,
        232,
        205,
        135,
        19,
        38,
        76,
        152,
        45,
        90,
        180,
        117,
        234,
        201,
        143,
        3,
        6,
        12,
        24,
        48,
        96,
        192,
        157,
        39,
        78,
        157,
        37,
        74,
        148,
        53,
        106,
        212,181, 119, 238, 193,159,35, 70, 140, 5, 10, 20, 40, 80, 160,
        93, 186, 105,210, 185,111,222,161,95,190,97,194,153,47,94,188,101,202,137,15,30,60,120,240,253,
        231,211,187,107,214,177,127,254,225,223,163,91,182,113,226,217,175,65,134,17,34,68,136,13,26,52,104,
        208,189,103,206,129,31,62,124,248,237,199,147,59,118,236,197,151,51,102,204,133,23,46,92,184,109,218,
        169,79,158,33,66,132,21,42,84,168,77,154,41,82,164,85,170,73,146,57,114,228,213,183,115,230,209,
        191,99,198,145,63,126,252,229,215,179,123,246,241,255,227,219,171,75,150,49,98,196,149,55,110,220,165,87,174,
        65,130,25,50,100,200,141,7,14,28,56,112,224,221,167,83,166,81,162,89,178,121,242,249,239,195,155,43,86,172,
        69,138,9,18,36,72,144,61,122,244,245,247,243,251,235,203,139,11,22,44,88,176,125,250,233,207,131,27,54,108,216,
        173,71,142,0};
        return alpha_lut[n];
}

unsigned char gfinv_lut (unsigned char a)
{

unsigned char lut[256] = {
2
,1
,142
,244
,71
,167
,122
,186
,173
,157
,221
,152
,61
,170
,93
,150
,216
,114
,192
,88
,224
,62
,76
,102
,144
,222
,85
,128
,160
,131
,75
,42
,108
,237
,57
,81
,96
,86
,44
,138
,112
,208
,31
,74
,38
,139
,51
,110
,72
,137
,111
,46
,164
,195
,64
,94
,80
,34
,207
,169
,171
,12
,21
,225
,54
,95
,248
,213
,146
,78
,166
,4
,48
,136
,43
,30
,22
,103
,69
,147
,56
,35
,104
,140
,129
,26
,37
,97
,19
,193
,203
,99
,151
,14
,55
,65
,36
,87
,202
,91
,185
,196
,23
,77
,82
,141
,239
,179
,32
,236
,47
,50
,40
,209
,17
,217
,233
,251
,218
,121
,219
,119
,6
,187
,132
,205
,254
,252
,27
,84
,161
,29
,124
,204
,228
,176
,73
,49
,39
,45
,83
,105
,2
,245
,24
,223
,68
,79
,155
,188
,15
,92
,11
,220
,189
,148
,172
,9
,199
,162
,28
,130
,159
,198
,52
,194
,70
,5
,206
,59
,13
,60
,156
,8
,190
,183
,135
,229
,238
,107
,235
,242
,191
,175
,197
,100
,7
,123
,149
,154
,174
,182
,18
,89
,165
,53
,101
,184
,163
,158
,210
,247
,98
,90
,133
,125
,168
,58
,41
,113
,200
,246
,249
,67
,215
,214
,16
,115
,118
,120
,153
,10
,25
,145
,20
,63
,230
,240
,134
,177
,226
,241
,250
,116
,243
,180
,109
,33
,178
,106
,227
,231
,181
,234
,3
,143
,211
,201
,66
,212
,232
,117
,127
,255
,126
,253};

 return lut[a];
}

unsigned char alphainv_lut (unsigned char n)
{
  if (n == 0) 
     return 1;
   return gfinv_lut( alpha (n) );
}

unsigned char gfdiv_lut (unsigned char dividend, unsigned char divisor)
{
  return gfmult_hw ( dividend, gfinv_lut(divisor));
}   



// Assumption: First bit of Lambda (alpha**0) is not transmitted
void compute_deriv (unsigned char lambda[tt], unsigned char lambda_deriv[tt])
{
   // Directive: Unroll loop maximally
   for (int i = 0; i < tt; i++)
        lambda_deriv[i] = (i % 2 == 0) ? lambda[i] : 0;
}


unsigned char poly_eval (unsigned char poly[tt], unsigned char alpha_inv)
{
   unsigned char val = 0;
   
   // Directive: Unroll loop maximally
   for (int j = tt-1; j >= 0; j--)
   {
      val = gfadd_hw(gfmult_hw(val, alpha_inv), poly[j]);
   }
   return val;
}

