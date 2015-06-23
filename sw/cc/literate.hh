/* $Id: literate.hh,v 1.5 2008-04-27 16:04:42 sybreon Exp $
** 
** AEMB Function Verification C++ Testbench
** Copyright (C) 2004-2008 Shawn Tan <shawn.tan@aeste.net>
**
** This file is part of AEMB.
**
** AEMB is free software: you can redistribute it and/or modify it
** under the terms of the GNU General Public License as published by
** the Free Software Foundation, either version 3 of the License, or
** (at your option) any later version.
**
** AEMB is distributed in the hope that it will be useful, but WITHOUT
** ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
** or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
** License for more details.
**
** You should have received a copy of the GNU General Public License
** along with AEMB.  If not, see <http://www.gnu.org/licenses/>.
*/
/**
  AEMB Software Verification
  @file literate.hh
  
  Algorithms listed here are extracted from literateprograms.org and
  modified for AEMB testing.
*/

#include <stdlib.h>
#include "simboard.hh"

#ifndef LITERATE_HH
#define LITERATE_HH

/*
FIBONACCI TEST
http://en.literateprograms.org/Fibonacci_numbers_(C)
 
  This tests for the following:
  - Recursion & Iteration
  - 32/16/8-bit data handling
*/

unsigned int fibSlow(unsigned int n)
{
  return n < 2 ? n : fibSlow(n-1) + fibSlow(n-2);
}

unsigned int fibFast(unsigned int n)
{
  unsigned int a[3];
  unsigned int *p=a;
  unsigned int i;
  
  for(i=0; i<=n; ++i) 
    {
      if(i<2) *p=i;
      else 
	{
	  if(p==a) *p=*(a+1)+*(a+2);
	  else if(p==a+1) *p=*a+*(a+2);
	  else *p=*a+*(a+1);
	}
      if(++p>a+2) p=a;
    }
  
  return p==a?*(p+2):*(p-1);
}

int fibonacciTest(int max) {
  unsigned int n;
  unsigned int fast, slow;  
  // 32-bit LUT
  unsigned int fib_lut32[] = {
    0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233
  };  
  // 16-bit LUT
  unsigned short fib_lut16[] = {
    0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233
  };    
  // 8-bit LUT
  unsigned char fib_lut8[] = {
    0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233
  };  
  
  for (n=0;n<max;n++) 
    {
      slow = fibSlow(n);    
      fast = fibFast(n);
      if ((slow != fast) || 
	  (fast != fib_lut32[n]) || 
	  (fast != fib_lut16[n]) || 
	  (fast != fib_lut8[n])) {
	return EXIT_FAILURE;      
      }

    }      
  return EXIT_SUCCESS;  
}

/*
   EUCLIDEAN TEST
   http://en.literateprograms.org/Euclidean_algorithm_(C)
   
   This tests for the following:
   - Modulo arithmetic
   - Goto
*/

int euclidGCD(int a, int b) {
  if (b > a) goto b_larger;
  while (1) {
    a = a % b;
    if (a == 0) return b;
  b_larger:
    b = b % a;
    if (b == 0) return a;
  }
}

int euclideanTest(int max) 
{
  int n;
  int euclid;
  // Random Numbers
  int euclid_a[] = {
    1804289383, 1681692777, 1957747793, 719885386, 596516649,
    1025202362, 783368690, 2044897763, 1365180540, 304089172,
    35005211, 294702567, 336465782, 278722862
  };  
  int euclid_b[] = {
    846930886, 1714636915, 424238335, 1649760492, 1189641421,
    1350490027, 1102520059, 1967513926, 1540383426, 1303455736,
    521595368, 1726956429, 861021530, 233665123
  };
  
  // GCD 
  int euclid_lut[] = {
    1, 1, 1, 2, 1, 1, 1, 1, 6, 4, 1, 3, 2, 1
  };
    
  for (n=0;n<max;n++) 
    {
      euclid = euclidGCD(euclid_a[n],euclid_b[n]);
      if (euclid != euclid_lut[n]) 
	{
	  return EXIT_FAILURE;
	}
    }

  return EXIT_SUCCESS;
}

/**
   NEWTON-RHAPSON
   http://en.literateprograms.org/Newton-Raphson's_method_for_root_finding_(C)

   This tests for the following:
   - Multiplication & Division
   - Barrel Shifts
   - Floating point arithmetic
   - Integer to Float conversion
*/

float newtonSqrt(float n)
{
  float x = 0.0;
  float xn = 0.0;  
  int iters = 0;  
  int i;
  for (i = 0; i <= (int)n; ++i)
    {
      float val = i*i-n;
      if (val == 0.0)
	return i;
      if (val > 0.0)
	{
	  xn = (i+(i-1))/2.0;
	  break;
	}
    }  
  while (!(iters++ >= 10
	   || x == xn))
    {
      x = xn;
      xn = x - (x * x - n) / (2 * x);
    }
  return xn;
}

int newtonTest (int max) {
  int n;
  float newt;
  // 32-bit LUT in IEEE754 hex representation
  float newt_lut[] = {
    0.000000000000000000000000,
    1.000000000000000000000000,
    1.414213538169860839843750,
    1.732050776481628417968750,
    2.000000000000000000000000,
    2.236068010330200195312500,
    2.449489831924438476562500,
    2.645751237869262695312500,
    2.828427076339721679687500,
    3.000000000000000000000000,
    3.162277698516845703125000,
    3.316624879837036132812500,
    3.464101552963256835937500,
    3.605551242828369140625000,
    3.741657495498657226562500
  };

  for (n=0;n<max;n++)
    {
      newt = newtonSqrt(n);    
      if (newt != newt_lut[n]) 
	{	 
	  return EXIT_FAILURE;
	}
    } 

  return EXIT_SUCCESS;
}

#endif

/*
$Log: not supported by cvs2svn $
*/
