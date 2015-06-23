//---------------------------------------------------------------------------
// Copyright (C) 2000 Dallas Semiconductor Corporation, All Rights Reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY,  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL DALLAS SEMICONDUCTOR BE LIABLE FOR ANY CLAIM, DAMAGES
// OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//
// Except as contained in this notice, the name of Dallas Semiconductor
// shall not be used except as stated in the Dallas Semiconductor
// Branding Policy.
//---------------------------------------------------------------------------
//
// owerr.c - Library functions for error handling with 1-Wire library
//
// Version: 1.00
//

#include <string.h>
#include <stdio.h>
#include "ownet.h"

#ifndef SIZE_OWERROR_STACK
   #ifdef SOCKIT_OWM_ERR_SMALL
      //for small memory, only hold 1 error
      #define SIZE_OWERROR_STACK 1
   #else
      #define SIZE_OWERROR_STACK 10
   #endif
#endif

//---------------------------------------------------------------------------
// Variables
//---------------------------------------------------------------------------

// Error Struct for holding error information.
// In DEBUG, this will also hold the line number and filename.
typedef struct
{
   int owErrorNum;
#ifdef DEBUG
   int lineno;
   char *filename;
#endif
} owErrorStruct;

// Ring-buffer used for stack.
// In case of overflow, deepest error is over-written.
static owErrorStruct owErrorStack[SIZE_OWERROR_STACK];

// Stack pointer to top-most error.
static int owErrorPointer = 0;


//---------------------------------------------------------------------------
// Functions Definitions
//---------------------------------------------------------------------------
int owGetErrorNum(void);
void owClearError(void);
int owHasErrors(void);
#ifdef DEBUG
   void owRaiseError(int,int,char*);
#else
   void owRaiseError(int);
#endif
#ifndef SOCKIT_OWM_ERR_SMALL
   void owPrintErrorMsg(FILE *);
   void owPrintErrorMsgStd();
   char *owGetErrorMsg(int);
#endif


//--------------------------------------------------------------------------
// The 'owGetErroNum' returns the error code of the top-most error on the
// error stack.  NOTE: This function has the side effect of popping the
// current error off the stack.  All successive calls to 'owGetErrorNum'
// will further clear the error stack.
//
// For list of error codes, see 'ownet.h'
//
// Returns:   int :  The error code of the top-most error on the stack
//
int owGetErrorNum(void)
{
   int i = owErrorStack[ owErrorPointer ].owErrorNum;
   owErrorStack[ owErrorPointer ].owErrorNum = 0;
   if(!owErrorPointer)
      owErrorPointer = SIZE_OWERROR_STACK - 1;
   else
      owErrorPointer = (owErrorPointer - 1);
   return i;
}

//--------------------------------------------------------------------------
// The 'owClearError' clears all the errors.
//
void owClearError(void)
{
   owErrorStack[ owErrorPointer ].owErrorNum = 0;
}

//--------------------------------------------------------------------------
// The 'owHasErrors' is a boolean test function which tests whether or not
// a valid error is waiting on the stack.
//
// Returns:   TRUE (1) : When there are errors on the stack.
//            FALSE (0): When stack's errors are set to 0, or NO_ERROR_SET.
//
int owHasErrors(void)
{
   if(owErrorStack[ owErrorPointer ].owErrorNum)
      return 1; //TRUE
   else
      return 0; //FALSE
}

#ifdef DEBUG
   //--------------------------------------------------------------------------
   // The 'owRaiseError' is the method for raising an error onto the error
   // stack.
   //
   // Arguments:  int err - the error code you wish to raise.
   //             int lineno - DEBUG only - the line number where it was raised
   //             char* filename - DEBUG only - the file name where it occured.
   //
   void owRaiseError(int err, int lineno, char* filename)
   {
      owErrorPointer = (owErrorPointer + 1) % SIZE_OWERROR_STACK;
      owErrorStack[ owErrorPointer ].owErrorNum = err;
      owErrorStack[ owErrorPointer ].lineno = lineno;
      owErrorStack[ owErrorPointer ].filename = filename;
   }
#else
   //--------------------------------------------------------------------------
   // The 'owRaiseError' is the method for raising an error onto the error
   // stack.
   //
   // Arguments:  int err - the error code you wish to raise.
   //
   void owRaiseError(int err)
   {
      owErrorPointer = (owErrorPointer + 1) % SIZE_OWERROR_STACK;
      owErrorStack[ owErrorPointer ].owErrorNum = err;
   }
#endif


// SOCKIT_OWM_ERR_SMALL - embedded microcontrollers, where these
// messaging functions might not make any sense.
#ifndef SOCKIT_OWM_ERR_SMALL
   //Array of meaningful error messages to associate with codes.
   //Not used on targets with low memory (i.e. PIC).
   static char *owErrorMsg[125] =
   {
   /*000*/ "No Error Was Set",
   /*001*/ "No Devices found on 1-Wire Network",
   /*002*/ "1-Wire Net Reset Failed",
   /*003*/ "Search ROM Error: Couldn't locate next device on 1-Wire",
   /*004*/ "Access Failed: Could not select device",
   /*005*/ "DS2480B Adapter Not Detected",
   /*006*/ "DS2480B: Wrong Baud",
   /*007*/ "DS2480B: Bad Response",
   /*008*/ "Open COM Failed",
   /*009*/ "Write COM Failed",
   /*010*/ "Read COM Failed",
   /*011*/ "Data Block Too Large",
   /*012*/ "Block Transfer failed",
   /*013*/ "Program Pulse Failed",
   /*014*/ "Program Byte Failed",
   /*015*/ "Write Byte Failed",
   /*016*/ "Read Byte Failed",
   /*017*/ "Write Verify Failed",
   /*018*/ "Read Verify Failed",
   /*019*/ "Write Scratchpad Failed",
   /*020*/ "Copy Scratchpad Failed",
   /*021*/ "Incorrect CRC Length",
   /*022*/ "CRC Failed",
   /*023*/ "Failed to acquire a necessary system resource",
   /*024*/ "Failed to initialize system resource",
   /*025*/ "Data too long to fit on specified device.",
   /*026*/ "Read exceeds memory bank end.",
   /*027*/ "Write exceeds memory bank end.",
   /*028*/ "Device select failed",
   /*029*/ "Read Scratch Pad verify failed.",
   /*030*/ "Copy scratchpad complete not found",
   /*031*/ "Erase scratchpad complete not found",
   /*032*/ "Address read back from scrachpad was incorrect",
   /*033*/ "Read page with extra-info not supported by this memory bank",
   /*034*/ "Read page packet with extra-info not supported by this memory bank",
   /*035*/ "Length of packet requested exceeds page size",
   /*036*/ "Invalid length in packet",
   /*037*/ "Program pulse required but not available",
   /*038*/ "Trying to access a read-only memory bank",
   /*039*/ "Current bank is not general purpose memory",
   /*040*/ "Read back from write compare is incorrect, page may be locked",
   /*041*/ "Invalid page number for this memory bank",
   /*042*/ "Read page with CRC not supported by this memory bank",
   /*043*/ "Read page with CRC and extra-info not supported by this memory bank",
   /*044*/ "Read back from write incorrect, could not lock page",
   /*045*/ "Read back from write incorrect, could not lock redirect byte",
   /*046*/ "The read of the status was not completed.",
   /*047*/ "Page redirection not supported by this memory bank",
   /*048*/ "Lock Page redirection not supported by this memory bank",
   /*049*/ "Read back byte on EPROM programming did not match.",
   /*050*/ "Can not write to a page that is locked.",
   /*051*/ "Can not lock a redirected page that has already been locked.",
   /*052*/ "Trying to redirect a locked redirected page.",
   /*053*/ "Trying to lock a page that is already locked.",
   /*054*/ "Trying to write to a memory bank that is write protected.",
   /*055*/ "Error due to not matching MAC.",
   /*056*/ "Memory Bank is write protected.",
   /*057*/ "Secret is write protected, can not Load First Secret.",
   /*058*/ "Error in Reading Scratchpad after Computing Next Secret.",
   /*059*/ "Load Error from Loading First Secret.",
   /*060*/ "Power delivery required but not available",
   /*061*/ "Not a valid file name.",
   /*062*/ "Unable to Create a Directory in this part.",
   /*063*/ "That file already exists.",
   /*064*/ "The directory is not empty.",
   /*065*/ "The wrong type of part for this operation.",
   /*066*/ "The max len for this file is too small.",
   /*067*/ "This is not a write once bank.",
   /*068*/ "The file can not be found.",
   /*069*/ "There is not enough space available.",
   /*070*/ "There is not a page to match that bit in the bitmap.",
   /*071*/ "There are no jobs for EPROM parts.",
   /*072*/ "Function not supported to modify attributes.",
   /*073*/ "Handle is not in use.",
   /*074*/ "Tring to read a write only file.",
   /*075*/ "There is no handle available for use.",
   /*076*/ "The directory provided is an invalid directory.",
   /*077*/ "Handle does not exist.",
   /*078*/ "Serial Number did not match with current job.",
   /*079*/ "Can not program EPROM because a non-EPROM part on the network.",
   /*080*/ "Write protect redirection byte is set.",
   /*081*/ "There is an inappropriate directory length.",
   /*082*/ "The file has already been terminated.",
   /*083*/ "Failed to read memory page of iButton part.",
   /*084*/ "Failed to match scratchpad of iButton part.",
   /*085*/ "Failed to erase scratchpad of iButton part.",
   /*086*/ "Failed to read scratchpad of iButton part.",
   /*087*/ "Failed to execute SHA function on SHA iButton.",
   /*088*/ "SHA iButton did not return a status completion byte.",
   /*089*/ "Write data page failed.",
   /*090*/ "Copy secret into secret memory pages failed.",
   /*091*/ "Bind unique secret to iButton failed.",
   /*092*/ "Could not install secret into user token.",
   /*093*/ "Transaction Incomplete: signature did not match.",
   /*094*/ "Transaction Incomplete: could not sign service data.",
   /*095*/ "User token did not provide a valid authentication response.",
   /*096*/ "Failed to answer a challenge on the user token.",
   /*097*/ "Failed to create a challenge on the coprocessor.",
   /*098*/ "Transaction Incomplete: service data was not valid.",
   /*099*/ "Transaction Incomplete: service data was not updated.",
   /*100*/ "Unrecoverable, catastrophic service failure occured.",
   /*101*/ "Load First Secret from scratchpad data failed.",
   /*102*/ "Failed to match signature of user's service data.",
   /*103*/ "Subkey out of range for the DS1991.",
   /*104*/ "Block ID out of range for the DS1991",
   /*105*/ "Password is enabled",
   /*106*/ "Password is invalid",
   /*107*/ "This memory bank has no read only password",
   /*108*/ "This memory bank has no read/write password",
   /*109*/ "1-Wire is shorted",
   /*110*/ "Error communicating with 1-Wire adapter",
   /*111*/ "CopyScratchpad failed: Ending Offset must go to end of page",
   /*112*/ "WriteScratchpad failed: Ending Offset must go to end of page",
   /*113*/ "Mission can not be stopped while one is not in progress",
   /*114*/ "Error stopping the mission",
   /*115*/ "Port number is outside (0,MAX_PORTNUM) interval",
   /*116*/ "Level of the 1-Wire was not changed",
   /*117*/ "Both the Read Only and Read Write Passwords must be set",
   /*118*/ "Failure to change latch state."
   /*119*/ "Could not open usb port through libusb",
   /*120*/ "Libusb DS2490 port already opened",
   /*121*/ "Failed to set libusb configuration",
   /*122*/ "Failed to claim libusb interface",
   /*123*/ "Failed to set libusb altinterface",
   /*124*/ "No adapter found at this port number"
   };

   char *owGetErrorMsg(int err)
   {
      return owErrorMsg[err];
   }

   //--------------------------------------------------------------------------
   // The 'owPrintErrorMsg' is the method for printing an error from the stack.
   // The destination for the print is specified by the argument, fileno, which
   // can be stderr, stdout, or a log file.  In non-debug mode, the output is
   // of the form:
   // Error num: Error msg
   //
   // In debug-mode, the output is of the form:
   // Error num: filename line#: Error msg
   //
   // NOTE: This function has the side-effect of popping the error off the stack.
   //
   // Arguments:  FILE*: the destination for printing.
   //
   void owPrintErrorMsg(FILE *filenum)
   {
   #ifdef DEBUG
      int l = owErrorStack[ owErrorPointer ].lineno;
      char *f = owErrorStack[ owErrorPointer ].filename;
      int err = owGetErrorNum();
      fprintf(filenum,"Error %d: %s line %d: %s\r\n",err,f,l,owErrorMsg[err]);
   #else
      int err = owGetErrorNum();
      fprintf(filenum,"Error %d: %s\r\n",err,owErrorMsg[err]);
   #endif
   }

   // Same as above, except uses default printf output
   void owPrintErrorMsgStd()
   {
   #ifdef DEBUG
      int l = owErrorStack[ owErrorPointer ].lineno;
      char *f = owErrorStack[ owErrorPointer ].filename;
      int err = owGetErrorNum();
      printf("Error %d: %s line %d: %s\r\n",err,f,l,owErrorMsg[err]);
   #else
      int err = owGetErrorNum();
      printf("Error %d: %s\r\n",err,owErrorMsg[err]);
   #endif
   }
#endif

