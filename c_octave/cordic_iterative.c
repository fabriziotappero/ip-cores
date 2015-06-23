/***************************************************************************
*                                                                          *
*  File           : cordic_iterative.c                                     *
*  Project        : YAC (Yet Another CORDIC Core)                          *
*  Creation       : Feb. 2014                                              *
*  Limitations    :                                                        *
*  Platform       : Linux, Mac, Windows                                    *
*  Target         : Octave, Matlab, Standalone-Application                 *
*                                                                          *
*  Author(s):     : Christian Haettich                                     *
*  Email          : feddischson@opencores.org                              *
*                                                                          *
*                                                                          *
**                                                                        **
*                                                                          *
*  Description                                                             *
*     C-implementation of an interative cordic.                            *
*     General information about the CORDIC algorithm can be found          *
*     here: - http://en.wikipedia.org/wiki/CORDIC                          *
*           - http://en.wikibooks.org/wiki/Digital_Circuits/CORDIC         *
*                                                                          *
*                                                                          *
**                                                                        **
*                                                                          *
*  TODO                                                                    *
*        Some documentation and function description                       *
*                                                                          *
*                                                                          *
*                                                                          *
*                                                                          *
****************************************************************************
*                                                                          *
*                     Copyright Notice                                     *
*                                                                          *
*    This file is part of YAC - Yet Another CORDIC Core                    *
*    Copyright (c) 2014, Author(s), All rights reserved.                   *
*                                                                          *
*    YAC is free software; you can redistribute it and/or                  *
*    modify it under the terms of the GNU Lesser General Public            *
*    License as published by the Free Software Foundation; either          *
*    version 3.0 of the License, or (at your option) any later version.    *
*                                                                          *
*    YAC is distributed in the hope that it will be useful,                *
*    but WITHOUT ANY WARRANTY; without even the implied warranty of        *
*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU     *
*    Lesser General Public License for more details.                       *
*                                                                          *
*    You should have received a copy of the GNU Lesser General Public      *
*    License along with this library. If not, download it from             *
*    http://www.gnu.org/licenses/lgpl                                      *
*                                                                          *
***************************************************************************/



#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "mex.h"

/* enable debug output */
#define PRINT_DEBUG        0


/* #define CORDIC_ROUNDING    0.5 */
#define CORDIC_ROUNDING    0.0


/* the supported modes */
#define C_FLAG_VEC_ROT     0x08
#define C_FLAG_ATAN_3      0x04
#define C_MODE_MSK         0x03
#define C_MODE_CIR         0x00
#define C_MODE_LIN         0x01
#define C_MODE_HYP         0x02



#define PRINT  mexPrintf



void cordic_int( long long int   x_i, 
                 long long int   y_i,
                 long long int   a_i,
                 long long int * x_o,
                 long long int * y_o,
                 long long int * a_o,
                 int           * it_o,
                 int        mode,
                 int        XY_WIDTH,
                 int        A_WIDTH,
                 int        GUARD_BITS,
                 int        RM_GAIN );
int            cordic_int_dbg    ( long long int x,
                                   long long int y,
                                   long long int a,
                                   int           mode,
                                   int           it,
                                   char*         msg );
int            cordic_int_init   ( long long int *x,
                                   long long int *y,
                                   long long int *a,
                                   int           mode, 
                                   int           A_WIDTH, 
                                   int           XY_WIDTH );
void           cordic_int_rm_gain( long long int *x, 
                                   long long int *y,
                                   int           mode,
                                   int           rm_gain );
int            cordic_int_rotate(  long long int * x, 
                                   long long int * y, 
                                   long long int * a, 
                                   int             mode,
                                   int             A_WIDTH );
long long int  cordic_int_lut    ( int             mode, 
                                   int             it,
                                   int             A_WIDTH );






void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
   double *inx,*iny,*inz,*outx,*outy,*outz,*outi;
   double mode;
   double xy_width;
   double a_width;
   double guard_bits;
   double rm_gain;

   int mrowsx,ncolsx,mrowsy,ncolsy,mrowsz,ncolsz;
   int i;
   int it;
   if(nrhs!=8 )
      mexErrMsgTxt("8 input arguments required");
   if(nlhs!=4)
      mexErrMsgTxt("4 output arguments required");
       
   if (!mxIsDouble(prhs[0]) || mxIsComplex(prhs[0]))
      mexErrMsgTxt("Input x must be double and non-complex");
 
   if (!mxIsDouble(prhs[1]) || mxIsComplex(prhs[1]))
      mexErrMsgTxt("Input y must be double and non-complex");
   
   if (!mxIsDouble(prhs[2]) || mxIsComplex(prhs[2]))
      mexErrMsgTxt("Input a must be double and non-complex");
   
   mrowsx = mxGetM(prhs[0]);
   ncolsx = mxGetN(prhs[0]);
   mrowsy = mxGetM(prhs[1]);
   ncolsy = mxGetN(prhs[1]);
   mrowsz = mxGetM(prhs[2]);
   ncolsz = mxGetN(prhs[2]);
   
   

   if (mrowsx > 1 || mrowsy >1 || mrowsz > 1)
       mexErrMsgTxt("Input vector must have the size Nx1.");

   /* printf("%d %d %d\n", ncolsx, ncolsy, ncolsa); */
   
   if (ncolsx!=ncolsy || ncolsx!=ncolsz || ncolsy!=ncolsz)
       mexErrMsgTxt("Input vectors don't have the same length!");
       
       
   plhs[0] = mxCreateDoubleMatrix(mrowsx,ncolsx,mxREAL);
   plhs[1] = mxCreateDoubleMatrix(mrowsy,ncolsy,mxREAL);
   plhs[2] = mxCreateDoubleMatrix(mrowsz,ncolsz,mxREAL);
   plhs[3] = mxCreateDoubleMatrix(mrowsz,ncolsz,mxREAL);
           
   inx         = mxGetPr(prhs[0]);
   iny         = mxGetPr(prhs[1]);
   inz         = mxGetPr(prhs[2]);
   mode        = mxGetScalar(prhs[3]);
   xy_width    = mxGetScalar(prhs[4]);
   a_width     = mxGetScalar(prhs[5]);
   guard_bits  = mxGetScalar(prhs[6]);
   rm_gain     = mxGetScalar(prhs[7]);

   outx= mxGetPr(plhs[0]);
   outy= mxGetPr(plhs[1]); 
   outz= mxGetPr(plhs[2]);
   outi= mxGetPr(plhs[3]);

   for( i = 0; i < ncolsx; i++ )
   {
        long long int inx_i = inx[ i ];
        long long int iny_i = iny[ i ];
        long long int inz_i = inz[ i ];
        long long int outx_i = 0;
        long long int outy_i = 0;
        long long int outz_i = 0;
/*        PRINT("x: %lld, y: %lld, a: %lld\n", inx_i, iny_i, inz_i ); */

        cordic_int(   inx_i,    iny_i,   inz_i,  
                        &outx_i, &outy_i, &outz_i,
                         &it, mode, 
                         xy_width, a_width, guard_bits, rm_gain );
        outx[i] = outx_i;
        outy[i] = outy_i;
        outz[i] = outz_i;
        outi[i] = it;
        

   }
}






void cordic_int( long long int   x_i, 
                 long long int   y_i,
                 long long int   a_i,
                 long long int * x_o,
                 long long int * y_o,
                 long long int * a_o,
                 int           * it_o,
                 int        mode,
                 int        XY_WIDTH,
                 int        A_WIDTH,
                 int        GUARD_BITS,
                 int        RM_GAIN )
{
   long long int x;
   long long int y;
   long long int a;
   long long int s;
   int ov;
   int it = 0;


   

   /* total with, including guard bits */
   int XY_WIDTH_G = XY_WIDTH + GUARD_BITS;
   
   cordic_int_dbg( x_i, y_i, a_i, mode, 0, "input" );

   if( !cordic_int_init( &x_i, &y_i, &a_i, mode, A_WIDTH, XY_WIDTH ) )
   {

      it = cordic_int_rotate( &x_i, &y_i, &a_i, mode, A_WIDTH );

      cordic_int_rm_gain( &x_i, &y_i, mode, RM_GAIN );
   }

   *x_o  = x_i;
   *y_o  = y_i;
   *a_o  = a_i;
   *it_o = it;

}







int cordic_int_init( long long int *x,
                     long long int *y,
                     long long int *a,
                     int           mode,
                     int           A_WIDTH,
                     int           XY_WIDTH )
{
   int already_done = 0;


   long long int PI   = ( long long int )( M_PI * pow( 2, A_WIDTH-1 ) + 0.5 );
   long long int PI_H = (long long int)(  M_PI * pow( 2, A_WIDTH-2 ) + 0.5  );
  
   long long int XY_MAX = pow( 2, XY_WIDTH-1 )-1;
   
   cordic_int_dbg( *x, *y, *a, mode, 0, "before init" );


   /* Circular rotation mode */
   if( 0          == ( mode &  C_FLAG_VEC_ROT )    &&
       C_MODE_CIR == ( mode &  C_MODE_MSK     )  )
   {
      /* move from third quadrant to first 
         quadrant if necessary */
      if( *a <  - PI_H )
      {
          if( ! (mode & C_FLAG_ATAN_3) )
             *a += PI;
          *x  = -*x;
          *y  = -*y;
          #if PRINT_DEBUG > 0
          PRINT("move from third quadrand"); 
          #endif
      }
      /* move from second quadrant to fourth 
         quadrant if necessary */
      else if( *a > PI_H )
      {
          if( ! (mode & C_FLAG_ATAN_3) )
             *a -= PI;
          *x  = -*x;
          *y  = -*y;
          #if PRINT_DEBUG > 0
          PRINT("move from second quadrand\n" );
          #endif
      }
   }

   /* circular vector mode */
   else if ( 0          != ( mode &  C_FLAG_VEC_ROT )    &&
             C_MODE_CIR == ( mode &  C_MODE_MSK     )  )
   {

      if( *x == 0 && *y == 0 )
      {
         already_done = 1;
         *a = 0;
         #if PRINT_DEBUG > 0
         PRINT( "Zero input, skipping rotations \n" );
         #endif
      }
      else if( *x == XY_MAX && *y == XY_MAX )
      {
         #if PRINT_DEBUG > 0
         PRINT( "All max, skipping rotations 1\n" );
         #endif
         *a = cordic_int_lut( mode, 0, A_WIDTH );
         *x = sqrt( 2 ) * pow( 2, XY_WIDTH-1 );
         already_done = 1;
      }
      else if( *x == -XY_MAX && *y == -XY_MAX )
      {
         #if PRINT_DEBUG > 0
         PRINT( "All max, skipping rotations 2\n" );
         #endif
         *a = cordic_int_lut( mode, 0, A_WIDTH ) - PI;
         *x = sqrt( 2 ) * pow( 2, XY_WIDTH-1 );
         already_done = 1;
      }
      else if( *x ==  XY_MAX && *y == -XY_MAX )
      {
         #if PRINT_DEBUG > 0
         PRINT( "All max, skipping rotations 3\n" );
         #endif
         *a = -cordic_int_lut( mode, 0, A_WIDTH );
         *x = sqrt( 2 ) * pow( 2, XY_WIDTH-1 );
         already_done = 1;
      }
      else if( *x == -XY_MAX && *y ==  XY_MAX )
      {
         #if PRINT_DEBUG > 0
         PRINT( "All max, skipping rotations 4\n" );
         #endif
         *a = PI - cordic_int_lut( mode, 0, A_WIDTH );
         *x = sqrt( 2 ) * pow( 2, XY_WIDTH-1 );
         already_done = 1;
      }



      else if( *x == 0 && *y > 0 ) 
      {
         *a = PI_H;
         *x = *y;
         already_done = 1;
         #if PRINT_DEBUG > 0
         PRINT( "Fixed value of pi/2, skipping rotations" );
         #endif
         *y = 0;
      }
      else if( *x == 0 && *y < 0 ) 
      {
         *a = -PI_H;
         *x = -*y;
         *y = 0;
         already_done = 1;
         #if PRINT_DEBUG > 0
         PRINT( "Fixed value of -pi/2, skipping rotations" );
         #endif
      }
      else if( *x < 0  && *y >= 0 )
      {
         *x = -*x;
         *y = -*y;
         *a =  PI;
          #if PRINT_DEBUG > 0
          PRINT("pre-rotation from second to the fourth quadrant\n" );
          #endif
      }
      else if( *x < 0 && *y <  0 )
      {
         *x = -*x;
         *y = -*y;
         *a = -PI;
          #if PRINT_DEBUG > 0
          PRINT("pre-rotation from third to first quadrand\n" );
          #endif
      }
      else
         *a = 0;
   }
   /* linear vector mode */
   else if ( 0          != ( mode &  C_FLAG_VEC_ROT )    &&
             C_MODE_LIN == ( mode &  C_MODE_MSK     )  )
   {
      if( *x < 0 )
      {
         *x = -*x;
         *y = -*y;
      }
      *a = 0;
   }

   cordic_int_dbg( *x, *y, *a, mode, 0, "after init" );
   return already_done; 
}



int cordic_int_dbg(  long long int x,
                     long long int y,
                     long long int a,
                     int           mode,
                     int           it,
                     char*         msg )
{
   #if PRINT_DEBUG > 0
   PRINT( "%20s: mode = %d, iteration %d, x = % 10.lld, y = %10.lld, a = %10.lld \n",
           msg,mode,it,x,y,a );
   #endif
}

int cordic_int_repeat( iteration, mode )
{
   int i = 4;
   
   if( C_MODE_HYP != ( mode & C_MODE_MSK ) )
      return 0;
       
    
   while( 1 )
   {
      if( i == iteration )
          return 1;
      else if( i > iteration )
          return 0;
      i = i * 3 + 1;
   }
}




int cordic_int_rotate( long long int * x, 
                       long long int * y, 
                       long long int * a, 
                       int             mode,
                       int             A_WIDTH )
{
   int it = 0;
   long long int xsh, ysh;
   long long int ylst, alst;
   int sign;
   int repeat = 0;

   while( 1 )
   {
      /* get the sign */
      if( 0 == ( mode & C_FLAG_VEC_ROT ) )
          sign =  ( *a >= 0 );
      else
          sign = !( *y >= 0 );

      /* shift operation: hyperbolic case*/
      if( C_MODE_HYP == ( mode & C_MODE_MSK ) )
      {
         xsh = *x >> (it+1);
         ysh = *y >> (it+1);
      }
      /* shift operation: circular and linear case*/
      else
      {
         xsh = *x >> it;
         ysh = *y >> it;
      }

      if( sign == 1 )
      {
         *a -= cordic_int_lut( mode, it, A_WIDTH );

         if( C_MODE_CIR == ( mode & C_MODE_MSK ) )
         {
            *x = *x - ysh;
            *y = *y + xsh;
         }
         else
         if( C_MODE_LIN == ( mode & C_MODE_MSK ) )
         {
            *x = *x;
            *y = *y + xsh;
         }
         else
         {
            *x = *x + ysh;
            *y = *y + xsh;
         }
      }
      else
      {
         *a += cordic_int_lut( mode, it, A_WIDTH );
         if( C_MODE_CIR == ( mode & C_MODE_MSK ) )
         {
            *x = *x + ysh;
            *y = *y - xsh;
         }
         else
         if( C_MODE_LIN == ( mode & C_MODE_MSK ) )
         {
            *x = *x;
            *y = *y - xsh;
         }
         else
         {
            *x = *x - ysh;
            *y = *y - xsh;
         }
      }
      cordic_int_dbg( *x, *y, *a, mode, it, "after rotation" );
      
      /* abort condition */
      if( ( mode & C_FLAG_VEC_ROT  ) == 0 && 
          ( *a == 0 /* || *a == -1 */ ) )
          break;
      if( ( mode & C_FLAG_VEC_ROT  ) == 0 && 
          ( *a == alst ) )
          break;
      
      if( ( mode & C_FLAG_VEC_ROT  ) != 0 && 
          ( *y == 0 /*|| *y == -1 */ ) )
          break;
      if( ( mode & C_FLAG_VEC_ROT  ) != 0 && 
          ( *y == ylst ) )
          break;

      else if( it > 40 )
      {
         PRINT( "ERROR: abort %lld %lld %lld %lld - %d - %d!\n", *a, alst, *y, ylst, mode, *y == ylst );
         it = -1;  
          break;
      }


      ylst = *y;
      alst = *a;
      if( repeat == 0 && cordic_int_repeat( it, mode ) )
      {
         repeat = 1;
         #if PRINT_DEBUG
         mexPrintf( "repeat it %d\n" , it );
         #endif
      }
      else
      {
         repeat = 0;
         it++;
      }
   }
   return it;
}



#define SCALE_VAL( _W_ )(  (double)( (long long int) 1 << (long long int)( _W_ -1 ) ) ) 

long long int cordic_int_lut( int mode, int it, int A_WIDTH )
{
   long long int lut_val;
   if( C_MODE_CIR == ( mode & C_MODE_MSK ) )
   {
      if( it <= 10 )
         lut_val = (long long int)(   atan(  pow( 2, -it ) ) * pow( 2, A_WIDTH-1 ) );
      else
         lut_val = pow( 2, A_WIDTH-1-it ); /* (long long int)( SCALE_VAL( A_WIDTH-it ) ); */
   }
   else 
   if( C_MODE_LIN == ( mode & C_MODE_MSK ) )
   {
      lut_val =  (long long int)( 1.0 / (double)( ( long long int )1 << (long long int)it ) 
                                *  SCALE_VAL( A_WIDTH ) -1 );
   }
   else
   {
      lut_val = (long long int)( atanh( 1.0 / (double)( (long long int)1 << ( long long int )(it+1)  ) ) 
                                *  SCALE_VAL( A_WIDTH ) );
   }
   return lut_val;
}




/**
 *
 * Cordic gain: 
 *
 *
 *
 */
void cordic_int_rm_gain( long long int *x, 
                         long long int *y,
                         int mode,
                         int rm_gain )
{
   /* for the non-linear case: remove cordic gain if RM_GAIN > 0 */
   if( C_MODE_CIR == ( mode & C_MODE_MSK ) )
   {


      switch( rm_gain )
      {
         case 1: *x = + ( *x >> 1 ) ; break; /* error: 0.1072529350 */ 
         case 2: *x = + ( *x >> 1 ) - ( *x >> 4 ) ; break; /* error: 0.1697529350 */ 
         case 3: *x = + ( *x >> 1 ) + ( *x >> 3 ) - ( *x >> 5 ) ; break; /* error: 0.0135029350 */ 
         case 4: *x = + ( *x >> 1 ) + ( *x >> 3 ) - ( *x >> 6 ) - ( *x >> 8 ) ; break; /* error: 0.0017841850 */ 
         case 5: *x = + ( *x >> 1 ) + ( *x >> 3 ) - ( *x >> 6 ) - ( *x >> 9 ) - ( *x >> 12 ) ; break; /* error: 0.0000752006 */ 
         case 6: *x = + ( *x >> 1 ) + ( *x >> 3 ) - ( *x >> 6 ) - ( *x >> 9 ) - ( *x >> 13 ) - ( *x >> 14 ) ; break; /* error: 0.0000141655 */ 
         case 7: *x = + ( *x >> 1 ) + ( *x >> 3 ) - ( *x >> 6 ) - ( *x >> 9 ) - ( *x >> 13 ) - ( *x >> 14 ) - ( *x >> 17 ) ; break; /* error: 0.0000217949 */ 
         case 8: *x = + ( *x >> 1 ) + ( *x >> 3 ) - ( *x >> 6 ) - ( *x >> 9 ) - ( *x >> 13 ) - ( *x >> 14 ) + ( *x >> 16 ) - ( *x >> 19 ) ; break; /* error: 0.0000008140 */ 
         case 9: *x = + ( *x >> 1 ) + ( *x >> 3 ) - ( *x >> 6 ) - ( *x >> 9 ) - ( *x >> 13 ) - ( *x >> 14 ) + ( *x >> 16 ) - ( *x >> 20 ) - ( *x >> 22 ) ; break; /* error: 0.0000000988 */ 
         case 10: *x = + ( *x >> 1 ) + ( *x >> 3 ) - ( *x >> 6 ) - ( *x >> 9 ) - ( *x >> 13 ) - ( *x >> 14 ) + ( *x >> 16 ) - ( *x >> 20 ) - ( *x >> 23 ) - ( *x >> 25 ) ; break; /* error: 0.0000000094 */ 
         case 11: *x = + ( *x >> 1 ) + ( *x >> 3 ) - ( *x >> 6 ) - ( *x >> 9 ) - ( *x >> 13 ) - ( *x >> 14 ) + ( *x >> 16 ) - ( *x >> 20 ) - ( *x >> 23 ) - ( *x >> 26 ) - ( *x >> 27 ) ; break; /* error: 0.0000000019 */ 
         case 12: *x = + ( *x >> 1 ) + ( *x >> 3 ) - ( *x >> 6 ) - ( *x >> 9 ) - ( *x >> 13 ) - ( *x >> 14 ) + ( *x >> 16 ) - ( *x >> 20 ) - ( *x >> 23 ) - ( *x >> 26 ) - ( *x >> 28 ) - ( *x >> 29 ) ; break; /* error: 0.0000000001 */ 
         default: *x = *x; break;
      }
      switch( rm_gain )
      {
         case 1: *y = + ( *y >> 1 ) ; break; /* error: 0.1072529350 */ 
         case 2: *y = + ( *y >> 1 ) - ( *y >> 4 ) ; break; /* error: 0.1697529350 */ 
         case 3: *y = + ( *y >> 1 ) + ( *y >> 3 ) - ( *y >> 5 ) ; break; /* error: 0.0135029350 */ 
         case 4: *y = + ( *y >> 1 ) + ( *y >> 3 ) - ( *y >> 6 ) - ( *y >> 8 ) ; break; /* error: 0.0017841850 */ 
         case 5: *y = + ( *y >> 1 ) + ( *y >> 3 ) - ( *y >> 6 ) - ( *y >> 9 ) - ( *y >> 12 ) ; break; /* error: 0.0000752006 */ 
         case 6: *y = + ( *y >> 1 ) + ( *y >> 3 ) - ( *y >> 6 ) - ( *y >> 9 ) - ( *y >> 13 ) - ( *y >> 14 ) ; break; /* error: 0.0000141655 */ 
         case 7: *y = + ( *y >> 1 ) + ( *y >> 3 ) - ( *y >> 6 ) - ( *y >> 9 ) - ( *y >> 13 ) - ( *y >> 14 ) - ( *y >> 17 ) ; break; /* error: 0.0000217949 */ 
         case 8: *y = + ( *y >> 1 ) + ( *y >> 3 ) - ( *y >> 6 ) - ( *y >> 9 ) - ( *y >> 13 ) - ( *y >> 14 ) + ( *y >> 16 ) - ( *y >> 19 ) ; break; /* error: 0.0000008140 */ 
         case 9: *y = + ( *y >> 1 ) + ( *y >> 3 ) - ( *y >> 6 ) - ( *y >> 9 ) - ( *y >> 13 ) - ( *y >> 14 ) + ( *y >> 16 ) - ( *y >> 20 ) - ( *y >> 22 ) ; break; /* error: 0.0000000988 */ 
         case 10: *y = + ( *y >> 1 ) + ( *y >> 3 ) - ( *y >> 6 ) - ( *y >> 9 ) - ( *y >> 13 ) - ( *y >> 14 ) + ( *y >> 16 ) - ( *y >> 20 ) - ( *y >> 23 ) - ( *y >> 25 ) ; break; /* error: 0.0000000094 */ 
         case 11: *y = + ( *y >> 1 ) + ( *y >> 3 ) - ( *y >> 6 ) - ( *y >> 9 ) - ( *y >> 13 ) - ( *y >> 14 ) + ( *y >> 16 ) - ( *y >> 20 ) - ( *y >> 23 ) - ( *y >> 26 ) - ( *y >> 27 ) ; break; /* error: 0.0000000019 */ 
         case 12: *y = + ( *y >> 1 ) + ( *y >> 3 ) - ( *y >> 6 ) - ( *y >> 9 ) - ( *y >> 13 ) - ( *y >> 14 ) + ( *y >> 16 ) - ( *y >> 20 ) - ( *y >> 23 ) - ( *y >> 26 ) - ( *y >> 28 ) - ( *y >> 29 ) ; break; /* error: 0.0000000001 */ 
         default: *x = *y; break;
      }

   }
   else 
   if( C_MODE_HYP == ( mode & C_MODE_MSK ) )
   {
      switch( rm_gain )
      {
         case 1: *x = *x - ( *x >> 3 ) ; break; /* error: 0.3324970678 */ 
         case 2: *x = *x + ( *x >> 2 ) - ( *x >> 4 ) ; break; /* error: 0.0199970678 */ 
         case 3: *x = *x + ( *x >> 2 ) - ( *x >> 5 ) - ( *x >> 6 ) ; break; /* error: 0.0043720678 */ 
         case 4: *x = *x + ( *x >> 2 ) - ( *x >> 5 ) - ( *x >> 7 ) - ( *x >> 8 ) ; break; /* error: 0.0004658178 */ 
         case 5: *x = *x + ( *x >> 2 ) - ( *x >> 5 ) - ( *x >> 7 ) - ( *x >> 8 ) - ( *x >> 12 ) ; break; /* error: 0.0007099584 */ 
         case 6: *x = *x + ( *x >> 2 ) - ( *x >> 5 ) - ( *x >> 7 ) - ( *x >> 8 ) + ( *x >> 11 ) - ( *x >> 15 ) ; break; /* error: 0.0000080541 */ 
         case 7: *x = *x + ( *x >> 2 ) - ( *x >> 5 ) - ( *x >> 7 ) - ( *x >> 8 ) + ( *x >> 11 ) - ( *x >> 16 ) - ( *x >> 17 ) ; break; /* error: 0.0000004247 */ 
         case 8: *x = *x + ( *x >> 2 ) - ( *x >> 5 ) - ( *x >> 7 ) - ( *x >> 8 ) + ( *x >> 11 ) - ( *x >> 16 ) - ( *x >> 17 ) - ( *x >> 22 ) ; break; /* error: 0.0000006631 */ 
         case 9: *x = *x + ( *x >> 2 ) - ( *x >> 5 ) - ( *x >> 7 ) - ( *x >> 8 ) + ( *x >> 11 ) - ( *x >> 16 ) - ( *x >> 17 ) + ( *x >> 21 ) - ( *x >> 24 ) ; break; /* error: 0.0000000075 */ 
         case 10: *x = *x + ( *x >> 2 ) - ( *x >> 5 ) - ( *x >> 7 ) - ( *x >> 8 ) + ( *x >> 11 ) - ( *x >> 16 ) - ( *x >> 17 ) + ( *x >> 21 ) - ( *x >> 24 ) + ( *x >> 27 ) ; break; /* error: 0.0000000000 */ 
         case 11: *x = *x + ( *x >> 2 ) - ( *x >> 5 ) - ( *x >> 7 ) - ( *x >> 8 ) + ( *x >> 11 ) - ( *x >> 16 ) - ( *x >> 17 ) + ( *x >> 21 ) - ( *x >> 24 ) + ( *x >> 27 ) - ( *x >> 37 ) ; break; /* error: 0.0000000000 */ 
         case 12: *x = *x + ( *x >> 2 ) - ( *x >> 5 ) - ( *x >> 7 ) - ( *x >> 8 ) + ( *x >> 11 ) - ( *x >> 16 ) - ( *x >> 17 ) + ( *x >> 21 ) - ( *x >> 24 ) + ( *x >> 27 ) + ( *x >> 36 ) - ( *x >> 39 ) ; break; /* error: 0.0000000000 */ 
      }
      switch( rm_gain )
      {
         case 1: *y = *y - ( *y >> 3 ) ; break; /* error: 0.3324970678 */ 
         case 2: *y = *y + ( *y >> 2 ) - ( *y >> 4 ) ; break; /* error: 0.0199970678 */ 
         case 3: *y = *y + ( *y >> 2 ) - ( *y >> 5 ) - ( *y >> 6 ) ; break; /* error: 0.0043720678 */ 
         case 4: *y = *y + ( *y >> 2 ) - ( *y >> 5 ) - ( *y >> 7 ) - ( *y >> 8 ) ; break; /* error: 0.0004658178 */ 
         case 5: *y = *y + ( *y >> 2 ) - ( *y >> 5 ) - ( *y >> 7 ) - ( *y >> 8 ) - ( *y >> 12 ) ; break; /* error: 0.0007099584 */ 
         case 6: *y = *y + ( *y >> 2 ) - ( *y >> 5 ) - ( *y >> 7 ) - ( *y >> 8 ) + ( *y >> 11 ) - ( *y >> 15 ) ; break; /* error: 0.0000080541 */ 
         case 7: *y = *y + ( *y >> 2 ) - ( *y >> 5 ) - ( *y >> 7 ) - ( *y >> 8 ) + ( *y >> 11 ) - ( *y >> 16 ) - ( *y >> 17 ) ; break; /* error: 0.0000004247 */ 
         case 8: *y = *y + ( *y >> 2 ) - ( *y >> 5 ) - ( *y >> 7 ) - ( *y >> 8 ) + ( *y >> 11 ) - ( *y >> 16 ) - ( *y >> 17 ) - ( *y >> 22 ) ; break; /* error: 0.0000006631 */ 
         case 9: *y = *y + ( *y >> 2 ) - ( *y >> 5 ) - ( *y >> 7 ) - ( *y >> 8 ) + ( *y >> 11 ) - ( *y >> 16 ) - ( *y >> 17 ) + ( *y >> 21 ) - ( *y >> 24 ) ; break; /* error: 0.0000000075 */ 
         case 10: *y = *y + ( *y >> 2 ) - ( *y >> 5 ) - ( *y >> 7 ) - ( *y >> 8 ) + ( *y >> 11 ) - ( *y >> 16 ) - ( *y >> 17 ) + ( *y >> 21 ) - ( *y >> 24 ) + ( *y >> 27 ) ; break; /* error: 0.0000000000 */ 
         case 11: *y = *y + ( *y >> 2 ) - ( *y >> 5 ) - ( *y >> 7 ) - ( *y >> 8 ) + ( *y >> 11 ) - ( *y >> 16 ) - ( *y >> 17 ) + ( *y >> 21 ) - ( *y >> 24 ) + ( *y >> 27 ) - ( *y >> 37 ) ; break; /* error: 0.0000000000 */ 
         case 12: *y = *y + ( *y >> 2 ) - ( *y >> 5 ) - ( *y >> 7 ) - ( *y >> 8 ) + ( *y >> 11 ) - ( *y >> 16 ) - ( *y >> 17 ) + ( *y >> 21 ) - ( *y >> 24 ) + ( *y >> 27 ) + ( *y >> 36 ) - ( *y >> 39 ) ; break; /* error: 0.0000000000 */ 
      }
   }
}

