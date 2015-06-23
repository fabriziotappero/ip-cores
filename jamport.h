/****************************************************************************/
/*																			*/
/*	Module:			jamport.h												*/
/*																			*/
/*					Copyright (C) Altera Corporation 2000					*/
/*																			*/
/*	Description:	Defines porting macros									*/
/*																			*/
/****************************************************************************/

/****************************************************************************/
/*																			*/
/*	Actel version 1.1             May 2003									*/
/*																			*/
/****************************************************************************/

#ifndef INC_JAMPORT_H
#define INC_JAMPORT_H

/*
*	PORT defines the target platform -- should be DOS, WINDOWS, or UNIX
*
*	PORT = DOS     means a 16-bit DOS console-mode application
*
*	PORT = WINDOWS means a 32-bit WIN32 console-mode application for
*	               Windows 95 or Windows NT.  On NT this will use the
*	               DeviceIoControl() API to access the Parallel Port.
*
*	PORT = UNIX    means any UNIX system.  BitBlaster access is support via
*	               the standard ANSI system calls open(), read(), write().
*	               The ByteBlaster is not supported.
*
*	PORT = EMBEDDED means all DOS, WINDOWS, and UNIX code is excluded. Remaining
*			code supports 16 and 32-bit compilers. Additional porting
*			steps may be necessary. See readme file for more details.
*/

#define DOS      2
#define WINDOWS  3
#define UNIX     4
#define EMBEDDED 5

/* change this line to build a different port */
#define PORT UNIX 

#endif /* INC_JAMPORT_H */
