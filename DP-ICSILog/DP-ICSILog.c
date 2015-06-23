/*******************************************************************************************
 *
 * Double-Precision ICSILog algorithm implementation 
 * written by Nikolaos Alchiotis and Alexandros Stamatakis
 *       
 * The Exelixis Lab
 * Bioinformatics Unit (I12)
 * Department of Computer Science
 * Technical University of Munich
 *
 * Emails: alachiot@cs.tum.edu, stamatak@cs.tum.edu
 * WWW:   http://wwwkramer.in.tum.de/exelixis/
 *
 * This code is made available under GNU GPL
 *
 *
*******************************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

/********************************************/
// Union to Access the bits

typedef union
{
  double value;
  
  struct
  {
    unsigned int rght_p;
    unsigned int lft_p;
  } 
    parts;
} 
  ieee_double_shape_type;


/********************************************/

//Constant Value
double con_val;

// Variables used for error checking
double value_minus_inf,
       value_nan,
       value_inf,
       value_inf_inf;

// Prec shows how many MSBs of the mantissa field will be used to index the mantissa LUT
unsigned int prec = 12;

// Lut_entries is the number of entries of the mantissa LUT
int lut_entries;//=pow(2,prec);

//ShiftBits is used by the main function to perform the shifting operation
int shiftBits;//= 12 + 20 - prec;


/********************************************/

// Function to initialize the mantissa LUT . It is the same one that the official ICSILog uses.

static void DP_ICSILog_INIT(const unsigned precision, double* const pTable)
{
  /* 
     step along table elements and x-axis positions
     (start with extra half increment, so the steps intersect at their midpoints.) 
  */
   
  con_val = log(2);
  value_minus_inf = -1.0 / 0.0;
  value_nan = 0.0 / 0.0;
  value_inf = pow(10, 308);
  value_inf_inf = value_inf + value_inf;

	
  double oneToTwo = 1.0f + (1.0f / (double)( 1 << (precision + 1)));
  int i;
 
  for(i = 0;  i < (1 << precision);  ++i )
    {
      // make y-axis value for table element
      pTable[i] = logf(oneToTwo);
      
      oneToTwo += 1.0f / (double)(1 << precision);
    }
}

/********************************************/
// The DP_myICSILog main function.

static inline double DP_myICSILog(const double input , const int num_of_bits, register double * const t)
{  
  register double result;
  	
  if(input < 0.0)    
    result = value_nan;
  else
    {
      if(input == 0.0)
	result = value_minus_inf;	
      else
	{
	  if(input > value_inf)	    
	    result = value_inf_inf;	
	  else
	    {	 
	      ieee_double_shape_type model_input;
	      model_input.value = input;
	      
	      register unsigned int left = model_input.parts.lft_p;
	      
	      register double m1 = ((left << 1) >> 21) - 1023.0;
	      register int index = (left << 12) >> num_of_bits;
	      
	      result = (con_val * m1  + t[index]);				 
	    }
	}
    }
  return result;
}


int main()
{

  double 
    value = 123456789,
    *DP_myICSILog_LUT,
    result;

  /*********************************************************************/
  // How to Initialize the function
  prec = 12; 

  lut_entries = pow(2,prec);
  
  shiftBits = 12 + 20 - prec;
  
  DP_myICSILog_LUT = (double*)malloc(sizeof(double) * lut_entries);

  DP_ICSILog_INIT(prec, DP_myICSILog_LUT);

  /********************************************************************/


  /********************************************************************/

  // How to Call the function
  result = DP_myICSILog(value, shiftBits, DP_myICSILog_LUT);

  printf("\n\nDP_myICSILog(%f) = %f \n",value, result);
  printf("\nLog(%f) = %f \n\n\n", value, log(value));
  return 0;
}
