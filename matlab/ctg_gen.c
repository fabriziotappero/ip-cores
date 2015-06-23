/*
 * Generate Combined Tausworthe number
 *
 * The calling syntax is:
 *     x = ctg_gen(z, n)
 *     [x, zf] = ctg_gen(z, n)
 *
 * Input:
 *     z: initial internal state, 3 x 1 vector of unsigned 64-bit integer
 *     n: length of pseudorandom numbers
 *
 * Output:
 *     x: pseudorandom values, n x 1 vector of unsigned 64-bit integer
 *     zf: final internal state after output n numbers
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
#include "taus176.h"


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    /* Local variables */
    taus_state_t state;
    unsigned long long *z;
    double *n;
    unsigned len;
    unsigned long long *x;
    unsigned long long *zf;
    unsigned i;

    /* Check for proper number of arguments */
    if (nrhs != 2)
        mexErrMsgTxt("Two input arguments required.");
    else if (nlhs > 2)
        mexErrMsgTxt("Too many output arguments.");

    if (!mxIsUint64(prhs[0]) || (mxGetM(prhs[0]) != 3) || (mxGetN(prhs[0]) != 1))
        mexErrMsgTxt("ctg_gen requires that z be a 3 x 1 vector of unsigned 64-bit integer.");

    if (!mxIsDouble(prhs[1]) || mxIsComplex(prhs[1]) ||
            (mxGetM(prhs[1]) != 1) || (mxGetN(prhs[1]) != 1))
        mexErrMsgTxt("ctg_gen requires that n be a positive integer.");

    n = mxGetPr(prhs[1]);
    len = (unsigned)(*n);
    if (len < 1)
        mexErrMsgTxt("ctg_gen requires that n be a positive integer.");

    /* Create a vector for the return argument */
    plhs[0] = mxCreateNumericMatrix(len, 1, mxUINT64_CLASS, 0);
    if (nlhs == 2)
        plhs[1] = mxCreateNumericMatrix(3, 1, mxUINT64_CLASS, 0);

    /* Assign pointers to the various parameters */
    z = (unsigned long long*)mxGetData(prhs[0]);
    x = (unsigned long long*)mxGetData(plhs[0]);
    if (nlhs == 2)
        zf = (unsigned long long*)mxGetData(plhs[1]);

    /* Call function taus_set and assign return value */
    state.z1 = z[0];
    state.z2 = z[1];
    state.z3 = z[2];
    for (i = 0; i < len; i++)
        x[i] = taus_get(&state);

    if (nlhs == 2) {
        zf[0] = state.z1;
        zf[1] = state.z2;
        zf[2] = state.z3;
    }
}
