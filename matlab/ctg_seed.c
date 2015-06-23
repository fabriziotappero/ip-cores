/*
 * Generate Combined Tausworthe Generator seed
 *
 * The calling syntax is:
 *     z = ctg_seed(s)
 *
 * Input:
 *     s: seed, unsigned 32-bit integer
 *
 * Output:
 *     z: initial internal state, 3 x 1 vector of unsigned 64-bit integer
 */

#include "mex.h"
#include "taus176.h"


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    /* Local variables */
    taus_state_t state;
    double *s;
    unsigned seed;
    unsigned long long *z;
    
    /* Check for proper number of arguments */
    if (nrhs != 1)
        mexErrMsgTxt("One input arguments required.");
    else if (nlhs > 1)
        mexErrMsgTxt("Too many output arguments.");
    
    if (!mxIsDouble(prhs[0]) || mxIsComplex(prhs[0]) ||
            (mxGetM(prhs[0]) != 1) || (mxGetN(prhs[0]) != 1))
        mexErrMsgTxt("ctg_seed requires that s be a unsigned 32-bit integer.");
    
    /* Create a vector for the return argument */
    plhs[0] = mxCreateNumericMatrix(3, 1, mxUINT64_CLASS, 0);
    
    /* Assign pointers to the various parameters */
    s = (unsigned *)mxGetPr(prhs[0]);
    seed = (unsigned)(*s);
    z = (unsigned long long*)mxGetData(plhs[0]);
    
    /* Call function taus_set */
    taus_set(&state, seed);
    
    /* Assign return value */
    z[0] = state.z1;
    z[1] = state.z2;
    z[2] = state.z3;
}
