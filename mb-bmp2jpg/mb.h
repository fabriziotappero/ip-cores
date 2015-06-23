#ifndef _XUP2PRO_H
#define _XUP2PRO_H

//  Microblaze related declaration

#include <xparameters.h>
#include <sysace_stdio.h>

#include "xio.h"

#define __XUPV2P


// XUP2P board related declaration 

#ifdef __XUPV2P
#define JPG_ADDRESS    0x70000000
#define JPG_MAXSIZE     0x10000
#define BMP_ADDRESS  0x70010000
#define BMP_MAXSIZE   0x10000
#else
#define JPG_MAXSIZE     0x400000
#define BMP_MAXSIZE   0x1c00000
#endif

// JPEG decoder related declaration

extern unsigned char* jpgimage;
extern char* bmpimage;
extern unsigned long jpgsize;
extern int bmpsize;

// function declaration

#define eOPENINPUT_FILE 1
#define eOPENOUTPUT_FILE 2
#define eINVALID_BMP 3
#define eLARGE_INPUTFILE 4

#endif


