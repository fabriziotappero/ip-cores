//////////////////////////////////////////////////////////////////////
////                                                              ////
////  PLB2WB-Bridge                                               ////
////                                                              ////
////  This file is part of the PLB-to-WB-Bridge project           ////
////  http://opencores.org/project,plb2wbbridge                   ////
////                                                              ////
////  Description                                                 ////
////  Implementation of a PLB-to-WB-Bridge according to           ////
////  PLB-to-WB Bridge specification document.                    ////
////                                                              ////
////  To Do:                                                      ////
////   Nothing                                                    ////
////                                                              ////
////  Author(s):                                                  ////
////      - Christian Haettich                                    ////
////        feddischson@opencores.org                             ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2010 Authors                                   ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////


#ifndef PLB2WB_BRIDGE_H
#define PLB2WB_BRIDGE_H

#include "xparameters.h"
#include "xbasic_types.h"
#include "xintc.h"


//
// PLB2WB-Bridge registers and irq-id
//
#define PLB2WB_STATUS         0x00
#define PLB2WB_STATUS_DAT     0x04
#define PLB2WB_STATUS_ADR     0x08
#define PLB2WB_STATUS_IRQ     0x0c
#define PLB2WB_STATUS_CON     0x04
#define PLB2WB_STATUS_ABO     0x08
#define PLB2WB_STATUS_RST     0x0c

#define PLB2WB_STATUS_WERR    0x20000000
#define PLB2WB_STATUS_WBRST   0x40000000
#define PLB2WB_STATUS_WBIRQ   0x80000000



typedef struct {
	XInterruptHandler Handler;
	void *CallBackRef;
} PLB2WB_Bridge_VectorTableEntry;


typedef struct{

   u32 BaseAddress;
   u32 StatusBaseAddress;
   u16 DeviceId;



} PLB2WB_Bridge_Config;


typedef struct{

   u32 BaseAddress;
   u32 StatusBaseAddress;
   u32 IsReady;
	u32 UnhandledInterrupts;
   PLB2WB_Bridge_Config *CfgPtr;
   u8       irqID;
   XIntc*   xintcInstancePtr;
  
   PLB2WB_Bridge_VectorTableEntry HandlerTable[ XPAR_PLB2WB_BRIDGE_0_WB_PIC_INTS ]; // wishbone peripheral irqs
   PLB2WB_Bridge_VectorTableEntry WBWrErrorHandler;                                 // wishbone write error handler
   PLB2WB_Bridge_VectorTableEntry WBRstHandler;                                     // wishbone reset handler

}PLB2WB_Bridge;

extern PLB2WB_Bridge_Config PLB2WB_Bridge_ConfigTable[];

int   PLB2WB_Bridge_Initialize            ( PLB2WB_Bridge* InstancePtr,    u16 DeviceId, 
                                            XIntc* xintcInstancePtr, u8 irqID             );
int   PLB2WB_Bridge_Connect               ( PLB2WB_Bridge*,  u8, XInterruptHandler, void* );
void  PLB2WB_Bridge_Disconnect            ( PLB2WB_Bridge * InstancePtr, u8 Id            );
void  PLB2WB_Bridge_DeviceInterruptHandler( void* ptr );

int   PLB2WB_Bridge_Connect_WBWrErrHandler( PLB2WB_Bridge* InstancePtr, XInterruptHandler Handler, void* CallBackRef );
int   PLB2WB_Bridge_Connect_WBRstHandler  ( PLB2WB_Bridge* InstancePtr, XInterruptHandler Handler, void* CallBackRef );

void  PLB2WB_Bridge_WBContinue            ( PLB2WB_Bridge* InstancePtr );
void  PLB2WB_Bridge_WBAbort               ( PLB2WB_Bridge* InstancePtr );
void  PLB2WB_Bridge_SoftReset             ( PLB2WB_Bridge* InstancePtr );




#endif
