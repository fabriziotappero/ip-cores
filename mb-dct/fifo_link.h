//////////////////////////////////////////////////////////////////////////////
//
// ***************************************************************************
// **                                                                       **
// ** Copyright (c) 1995-2005 Xilinx, Inc.  All rights reserved.            **
// **                                                                       **
// ** You may copy and modify these files for your own internal use solely  **
// ** with Xilinx programmable logic devices and Xilinx EDK system or       **
// ** create IP modules solely for Xilinx programmable logic devices and    **
// ** Xilinx EDK system. No rights are granted to distribute any files      **
// ** unless they are distributed in Xilinx programmable logic devices.     **
// **                                                                       **
// ***************************************************************************
//
//////////////////////////////////////////////////////////////////////////////
// Filename:          D:\thesis\FIFO1\drivers\fifo_link_v1_00_a\src\\fifo_link.h
// Version:           1.00.a
// Description:       fifo_link (FIFO link) Driver Header File
// Date:              Fri Oct 06 17:25:29 2006 (by Create and Import Peripheral Wizard)
//////////////////////////////////////////////////////////////////////////////

#ifndef FIFO_LINK_H
#define FIFO_LINK_H

#ifdef __MICROBLAZE__
	#include "mb_interface.h" 
	#define write_into_fsl(val, id)  microblaze_bwrite_datafsl(val, id)
	#define read_from_fsl(val, id)  microblaze_bread_datafsl(val, id)
#else
	#include "xpseudo_asm_gcc.h" 
	#define write_into_fsl(val, id)  putfsl(val, id)
	#define read_from_fsl(val, id)  getfsl(val, id)
#endif

/*
* A macro for accessing FSL peripheral.
*
* This example driver writes all the data in the input arguments
* into the input FSL bus through blocking wrties. FSL peripheral will
* automatically read from the FSL bus. Once all the inputs
* have been written, the output from the FSL peripheral is read
* into output arguments through blocking reads.
*
* Arguments:
*	 output_slot_id
*		 Compile time constant indicating FSL slot from
*		 which output data is read. Defined in
*		 xparameters.h .
*	 input_slot_id
*		 Compile time constant indicating FSL slot into
*		 which input data is written. Defined in
*		 xparameters.h .
*	 input_0    An array of unsigned integers. Array size is 1
*	 output_0   An array of unsigned integers. Array size is 1
*
* Caveats:
*    The output_slot_id and input_slot_id arguments must be
*    constants available at compile time. Do not pass
*    variables for these arguments.
*
*    Since this is a macro, using it too many times will
*    increase the size of your application. In such cases,
*    or when this macro is too simplistic for your
*    application you may want to create your own instance
*    specific driver function (not a macro) using the 
*    macros defined in this file and the slot
*    identifiers defined in xparameters.h .  Please see the
*    example code (fifo_link_app.c) for details.
*/

#define  fifo_link(\
		 input_slot_id,\
		 output_slot_id,\
		 input_0,      \
		 output_0       \
		 )\
{\
   int i;\
\
   for (i=0; i<1; i++)\
   {\
      write_into_fsl(input_0[i], input_slot_id);\
   }\
\
   for (i=0; i<1; i++)\
   {\
      read_from_fsl(output_0[i], output_slot_id);\
   }\
}

#endif 
