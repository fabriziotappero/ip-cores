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
#include "error_mag.h"

// Directive: Synthesize independently
unsigned char poly_eval_inst1 (unsigned char poly[tt], unsigned char alpha_inv)
{
   return poly_eval(poly, alpha_inv);
}

// Directive: Synthesize independently
unsigned char poly_eval_inst2 (unsigned char poly[tt], unsigned char alpha_inv)
{
   return poly_eval(poly, alpha_inv);
}

// Directive: Synthesize independently
unsigned char gfdiv_lut_inst (unsigned char dividend, unsigned char divisor)
{
  return gfdiv_lut(dividend, divisor);
}   

// Directive: Synthesize independently
void compute_deriv_inst (unsigned char lambda[tt], unsigned char lambda_deriv[tt])
{
   compute_deriv(lambda, lambda_deriv);
}


// Directive: Synthesize independently
void error_mag(unsigned char k, unsigned char lambda[tt], unsigned char omega[tt], unsigned char err_no, unsigned char err_loc[tt], unsigned char alpha_inv[tt],
               unsigned char err[kk])
{
    int loc_idx = 0; 
    unsigned char lambda_val = 0;
    unsigned char omega_val = 0;
    unsigned char lambda_deriv[tt];
    unsigned char err_temp[tt];

    compute_deriv(lambda, lambda_deriv);
    for (int i = 0; i < tt; i++)
    {
        lambda_val  = poly_eval_inst1(lambda_deriv, alpha_inv[i]);
        omega_val   = poly_eval_inst2(omega, alpha_inv[i]);
        err_temp[i] = gfdiv_lut_inst(omega_val, lambda_val);
    }

    for (int i = 0; i < kk; i++)
    {
        if ((err_loc[loc_idx] == kk-1-i) && (loc_idx < err_no))
        {
            err[i] = err_temp[loc_idx];
            loc_idx++;             
        } 
        else
        {
            err[i] = 0;
        }
    }
}

