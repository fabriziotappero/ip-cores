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

#include "plb2wb_bridge.h"
#include "xstatus.h"
#include "xparameters.h"
#include "xio.h"



static void WBResetStubHandler( void *CallBackRef )
{
   XASSERT_VOID( FALSE );
}


static void StubHandler( void *CallBackRef )
{

	XASSERT_VOID(CallBackRef != NULL);

	( (PLB2WB_Bridge *) CallBackRef )->UnhandledInterrupts++;
}



//
//  Note,  this handlers MUST be implemented.
//  If no handler is implemented and interrupt is rised,
//  this stubs never return!!
//
//
static void StubWBRstHandler( void *CallBackRef )
{
	XASSERT_VOID( FALSE );

}

static void StubWBWrHandler( void *CallBackRef )
{
	XASSERT_VOID( FALSE );
}


void PLB2WB_Bridge_DeviceInterruptHandler( void* ptr )
{
   
   u32 status_reg;
   u32 irq_reg;
   u32 addr_reg;
   u32 datum_reg;
   u8  i;
   PLB2WB_Bridge_VectorTableEntry *entry;

   PLB2WB_Bridge* InstancePtr = (PLB2WB_Bridge*) ptr;

   
   status_reg = XIo_In32( InstancePtr->StatusBaseAddress + PLB2WB_STATUS );
  


   // call write-error handler
   if ( status_reg & PLB2WB_STATUS_WERR )
   {
      entry = &InstancePtr->WBWrErrorHandler;
      entry->Handler( entry->CallBackRef );
   }
   

   // call irq-handler
   if ( status_reg & PLB2WB_STATUS_WBIRQ )
   {
      irq_reg = XIo_In32( InstancePtr->StatusBaseAddress + PLB2WB_STATUS_IRQ  );
      for( i=0; i<32; i++ )
      {
         if( irq_reg & ( 1 << ( 31 - i ) ) )
         {
            entry = &InstancePtr->HandlerTable[i];
            entry->Handler( entry->CallBackRef );
         }
      }
   }


   // call reset handler
   if ( status_reg & PLB2WB_STATUS_WBRST )
   {
      entry = &InstancePtr->WBRstHandler;
      entry->Handler( entry->CallBackRef );
   }

   // clear bridge-irq
   XIo_Out32( InstancePtr->StatusBaseAddress + PLB2WB_STATUS, 0 );

   // clear mb-irq
   XIntc_Acknowledge( InstancePtr->xintcInstancePtr, InstancePtr->irqID );
}





PLB2WB_Bridge_Config *PLB2WB_Bridge_LookupConfig( u16 DeviceId )
{
	PLB2WB_Bridge_Config *CfgPtr = NULL;

	int i;
	for ( i = 0; i < XPAR_PLB2WB_BRIDGE_NUM_INSTANCES; i++ ) 
   {
		if ( PLB2WB_Bridge_ConfigTable[i].DeviceId == DeviceId ) 
      {
			CfgPtr = &PLB2WB_Bridge_ConfigTable[i];
			break;
		}
	}

	return CfgPtr;
}



int PLB2WB_Bridge_Initialize( PLB2WB_Bridge * InstancePtr, u16 DeviceId, XIntc* xintcInstancePtr, u8 irqID )
{
   u8 i;

   PLB2WB_Bridge_Config *ConfigPtr;
   
   XASSERT_NONVOID( InstancePtr != NULL );
   
   ConfigPtr = PLB2WB_Bridge_LookupConfig( DeviceId );
   
   if ( ConfigPtr == ( PLB2WB_Bridge_Config * ) NULL ) 
   {
   	InstancePtr->IsReady = 0;
   	return ( XST_DEVICE_NOT_FOUND );
   }
  

   InstancePtr->StatusBaseAddress   = ConfigPtr->StatusBaseAddress;
   InstancePtr->BaseAddress         = ConfigPtr->BaseAddress;
   InstancePtr->CfgPtr              = ConfigPtr;

   for( i=0; i < XPAR_PLB2WB_BRIDGE_0_WB_PIC_INTS; i++ )
   {
      InstancePtr->HandlerTable[i].Handler = StubHandler;
		InstancePtr->HandlerTable[i].CallBackRef = InstancePtr;
   }

   InstancePtr->WBWrErrorHandler.Handler = StubWBWrHandler;
   InstancePtr->WBWrErrorHandler.CallBackRef = StubWBWrHandler;

   InstancePtr->WBRstHandler.Handler = StubWBRstHandler;
   InstancePtr->WBRstHandler.CallBackRef = InstancePtr;



   InstancePtr->xintcInstancePtr = xintcInstancePtr;
   InstancePtr->irqID            = irqID;
	InstancePtr->IsReady          = XCOMPONENT_IS_READY;

   return XST_SUCCESS;
}



int PLB2WB_Bridge_Connect_WBRstHandler( PLB2WB_Bridge* InstancePtr, 
                                        XInterruptHandler Handler, void* CallBackRef )
{
   XASSERT_NONVOID( InstancePtr != NULL );
   XASSERT_NONVOID( Handler != NULL );
   XASSERT_NONVOID( InstancePtr->IsReady == XCOMPONENT_IS_READY );

   InstancePtr->WBRstHandler.Handler = Handler;
   InstancePtr->WBRstHandler.CallBackRef = CallBackRef;

   return XST_SUCCESS;
}

int PLB2WB_Bridge_Connect_WBWrErrHandler( PLB2WB_Bridge* InstancePtr, XInterruptHandler Handler, void* CallBackRef )
{
   XASSERT_NONVOID( InstancePtr != NULL );
   XASSERT_NONVOID( Handler != NULL );
   XASSERT_NONVOID( InstancePtr->IsReady == XCOMPONENT_IS_READY );

   InstancePtr->WBWrErrorHandler.Handler = Handler;
   InstancePtr->WBWrErrorHandler.CallBackRef = CallBackRef;

   return XST_SUCCESS;
}


int PLB2WB_Bridge_Connect( PLB2WB_Bridge* InstancePtr, u8 Id, 
                           XInterruptHandler Handler, void* CallBackRef )
{
   XASSERT_NONVOID( InstancePtr != NULL );
   XASSERT_NONVOID( Id < XPAR_PLB2WB_BRIDGE_0_WB_PIC_INTS );
   XASSERT_NONVOID( Handler != NULL );
   XASSERT_NONVOID( InstancePtr->IsReady == XCOMPONENT_IS_READY );

   InstancePtr->HandlerTable[Id].Handler = Handler;
   InstancePtr->HandlerTable[Id].CallBackRef = CallBackRef;

   return XST_SUCCESS;
}



void PLB2WB_Bridge_Disconnect( PLB2WB_Bridge * InstancePtr, u8 Id )
{
   u32 CurrentIER;
   u32 Mask;
   
   XASSERT_VOID(InstancePtr != NULL);
   XASSERT_VOID(Id < XPAR_PLB2WB_BRIDGE_0_WB_PIC_INTS );
   XASSERT_VOID(InstancePtr->IsReady == XCOMPONENT_IS_READY);
   
   InstancePtr->HandlerTable[Id].Handler = StubHandler;
   InstancePtr->HandlerTable[Id].CallBackRef = InstancePtr;
}



void  PLB2WB_Bridge_WBContinue            ( PLB2WB_Bridge* InstancePtr )
{
   XASSERT_VOID(InstancePtr != NULL);

   XIo_Out32( InstancePtr->StatusBaseAddress + PLB2WB_STATUS_CON, 0 );
}



void  PLB2WB_Bridge_WBAbort               ( PLB2WB_Bridge* InstancePtr )
{
   XASSERT_VOID(InstancePtr != NULL);

   XIo_Out32( InstancePtr->StatusBaseAddress + PLB2WB_STATUS_ABO, 0 );
}


void  PLB2WB_Bridge_SoftReset             ( PLB2WB_Bridge* InstancePtr )
{
   XASSERT_VOID(InstancePtr != NULL);

   XIo_Out32( InstancePtr->StatusBaseAddress + PLB2WB_STATUS_RST, 0 );
}


