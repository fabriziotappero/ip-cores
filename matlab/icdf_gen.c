/*
 * Generate inverse of the normal cumulative distribution function
 *
 * The calling syntax is:
 *     x = icdf_gen(r)
 *
 * Input:
 *     z: pseudorandom numbers
 *
 * Output:
 *     x: Gaussian random numbers, n x 1 vector of 32-bit integer (s<16,11>)
 */

/*
 * Copyright (C) 2014, Guangxi Liu <guangxi.liu@opencores.org>
 *
 * This source file may be used and distributed without restriction provided
 * that this copyright statement is not removed from the file and that any
 * derivative work contains the original copyright notice and the associated
 * disclaimer.
 *
 * This source file is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; either version 2.1 of the License,
 * or (at your option) any later version.
 *
 * This source is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public
 * License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this source; if not, download it from
 * http://www.opencores.org/lgpl.shtml
 */


#include "mex.h"
#include "icdf.h"


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    /* Local variables */
    unsigned long long *r;
    unsigned len;
    long *x;
    unsigned i;

    /* Check for proper number of arguments */
    if (nrhs != 1)
        mexErrMsgTxt("One input arguments required.");

    if (!mxIsUint64(prhs[0]) || (mxGetN(prhs[0]) != 1))
        mexErrMsgTxt("icdf_gen requires that r be a column vector of unsigned 64-bit integer.");

    len = mxGetM(prhs[0]);
    if (len < 1)
        mexErrMsgTxt("icdf_gen requires that vector length be a positive integer.");

    /* Create a vector for the return argument */
    plhs[0] = mxCreateNumericMatrix(len, 1, mxINT32_CLASS, 0);

    /* Assign pointers to the various parameters */
    r = (unsigned long long*)mxGetData(prhs[0]);
    x = (long*)mxGetData(plhs[0]);

    /* Call function icdf and assign return value */
    for (i = 0; i < len; i++)
        x[i] = icdf(r[i]);
}
