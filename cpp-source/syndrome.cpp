//----------------------------------------------------------------------//
// The MIT License 
// 
// Copyright (c) 2010 Abhinav Agarwal, Alfred Man Cheuk Ng
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
#include "syndrome.h"


// Parameters k and t need to be dynamically used for each packet
// However, this version uses static values for simplicity

// Directive: Synthesize independently
void syndrome (unsigned char k, unsigned char t, unsigned char r[nn], unsigned char s[2*tt])
{
   unsigned char r_temp;

   // Directive: Unroll loop maximally
   Syn_Init: for (int j=0; j<2*tt; j++)
      s[j]=0;

   Syn_Outer: for (int i = 0; i < nn; ++ i)
   {
      r_temp = r[i];
       
      // Directive: Unroll loop maximally
      Syn_Inner: for (int j = 0; j < 2*tt; ++ j)
      {
         s[j] = gfmult_hw (s [j], alpha(j+1)) ^ r_temp;
      }    
   }
}
