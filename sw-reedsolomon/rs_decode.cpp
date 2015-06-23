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
#include "syndrome.h"
#include "berlekamp.h"
#include "chien_search.h"
#include "error_mag.h"
#include "error_correct.h"
#include "rs_fifo.h"


// Top level decoder module
void rs_decode (unsigned char n, unsigned char t, unsigned char in_d[nn], 
                unsigned char *k, unsigned char out_d[kk])
{   
   unsigned char temp_k = n - 2*t;
   unsigned char s[2*tt];
   unsigned char c[tt+2];
   unsigned char w[tt+2];
   unsigned char lambda[tt];
   unsigned char omega[tt];
   unsigned char err_no;
   unsigned char err_loc[kk];
   unsigned char alpha_inv[tt];
   unsigned char err[kk];
   unsigned char in_data[kk];
   unsigned char in_d_2[nn];
   
   // Create copy of input to pass to fifo to error corrector
   // Directive: Unroll loop maximally
Simple_rs1:   for (int i = 0; i < nn; i++)
       in_d_2[i] = in_d[i];

   *k = temp_k;
   rs_fifo(temp_k, in_d, in_data);
   syndrome(temp_k, t, in_d_2, s);
   berlekamp(t, s, lambda, omega);
   chien_search(kk, tt, lambda, &err_no, err_loc, alpha_inv);
   error_mag(kk, lambda, omega, err_no, err_loc, alpha_inv, err);
   error_correct(temp_k, in_data, err, out_d);
    
}
