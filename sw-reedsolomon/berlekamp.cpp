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

#include "global_rs.h"
#include "gf_arith.h"
#include "berlekamp.h"

// Directive: Synthesize independently
void gfmult_array_array_hw (unsigned char res_vec[tt+2], unsigned char in_vec0[tt+2], unsigned char in_vec1[tt+2])
{
// Directive: Unroll loop maximally
  for (int i = 0; i < tt+2; ++i)
    res_vec[i] = gfmult_hw(in_vec0[i],in_vec1[i]);
}

// Directive: Synthesize independently
void gfmult_scalar_array_hw1 (unsigned char res_vec[tt+2], unsigned char val, unsigned char in_vec[tt+2])
{
// Directive: Unroll loop maximally
  for (int i = 0; i < tt+2; ++i)
    res_vec[i] = gfmult_hw(val,in_vec[i]);
}

// Directive: Synthesize independently
void gfmult_scalar_array_hw2 (unsigned char res_vec[tt+2], unsigned char val, unsigned char in_vec[tt+2])
{
// Directive: Unroll loop maximally
  for (int i = 0; i < tt+2; ++i)
    res_vec[i] = gfmult_hw(val,in_vec[i]);
}

// Directive: Synthesize independently
void gfadd_array_array_hw1 (unsigned char in_vec0[tt+2], unsigned char in_vec1[tt+2])
{
// Directive: Unroll loop maximally
  for (int i = 0; i < tt+2; ++i)
    in_vec0[i] = gfadd_hw(in_vec0[i], in_vec1[i]);
}

// Directive: Synthesize independently
void gfadd_array_array_hw2 (unsigned char in_vec0[tt+2], unsigned char in_vec1[tt+2])
{
// Directive: Unroll loop maximally
  for (int i = 0; i < tt+2; ++i)
    in_vec0[i] = gfadd_hw(in_vec0[i], in_vec1[i]);
}


// Directive: Synthesize independently
unsigned char gfsum_array_hw (unsigned char in_vec[tt+2])
{
  unsigned char res = 0;

  // Directive: Unroll loop maximally
  for (int i = 0; i < tt+2; ++i)
    res = gfadd_hw(res, in_vec[i]);

  return res;
}

#pragma hls_design 
void berlekamp (unsigned char t, unsigned char s[2*tt], unsigned char c_out[tt], unsigned char w_out[tt])
{
  unsigned char l = 0;
  unsigned char p[tt+2];
  unsigned char a[tt+2];
  unsigned char t1[tt+2];
  unsigned char t2[tt+2];
  unsigned char syn_shift_reg[tt+2];
  unsigned char temp[tt+2];
  unsigned char c[tt+2];
  unsigned char w[tt+2];

  c[0] = 1;
  p[0] = 1;
  w[0] = 0;
  a[0] = 1;
  syn_shift_reg[0] = 0;
  temp[0] = 0;

  // Directive: Unroll loop maximally
  BerlInit: for (int i = 1; i < tt+2; i++)
  {
    c [i] = 0;
    w [i] = 0;
    p [i] = 0;
    a [i] = 0;
    t1[i] = 0;
    t2[i] = 0;
    syn_shift_reg[i] = 0;
    temp[i] = 0;
  }
  
  unsigned char dstar = 1;
  unsigned char d = 0;
  unsigned char ddstar = 1;
   BerlOuter:
   for (int i = 0; i < 2*tt; i++ )
   {
      // Directive: Unroll loop maximally 
      BerlShift: for (int k = tt+1; k > 0; --k)
      {
          syn_shift_reg[k] = syn_shift_reg[k-1];
          p[k] = p[k-1];
          a[k] = a[k-1];
      }
      syn_shift_reg[0] = s[i];
      p[0] = 0;
      a[0] = 0;
      
      gfmult_array_array_hw(temp, c, syn_shift_reg);
      d = gfsum_array_hw(temp);

      if (d != 0)
      {
	     ddstar = gfmult_hw(d, dstar);
	     // Directive: Unroll loop maximally
	     BerlSimple1: for (int k = 0; k < tt+2; ++k)
         {
               t1 [k] = p [k];
               t2 [k] = a [k];
         }  
 	     
         if (i + 1 > 2*l)
         {
	        l = i - l + 1;

            // Directive: Unroll loop maximally
            BerlSimple2: for (int k = 0; k < tt+2; ++k)
            {
               p [k] = c [k];
               a [k] = w [k];
            }
            dstar = gfinv_lut ( d );
         }

	 gfmult_scalar_array_hw1(temp, ddstar, t1);
	 gfadd_array_array_hw1(c,temp);
	 gfmult_scalar_array_hw2(temp, ddstar, t2);
	 gfadd_array_array_hw2(w,temp);

      }
   }
   
   // Directive: Unroll loop maximally
   BerlCopy: for (int k = 0; k < tt; ++k)
   {
       c_out[k] = c[k+1];
       w_out[k] = w[k+1];
   } 
}



