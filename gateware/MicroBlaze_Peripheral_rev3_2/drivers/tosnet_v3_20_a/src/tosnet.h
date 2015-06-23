/*****************************************************************************
* Filename:          /drivers/tosnet_v1_00_a/src/tosnet.h
* Version:           3.20.a
* Description:       tosnet Driver Header File
* Date:              Mon Feb 15 11:56:16 2010 (by Create and Import Peripheral Wizard)
*****************************************************************************/

#ifndef TOSNET_H
#define TOSNET_H

/***************************** Include Files *******************************/

#include "xbasic_types.h"
#include "xstatus.h"
#include "xio.h"

/************************** Constant Definitions ***************************/

/**************************** Type Definitions *****************************/


typedef struct {
	volatile unsigned int *MemBaseAddress;		/* Base address of memory */
	volatile unsigned int *RegBaseAddress;		/* Base address of registers */
} TosNet;

/***************** Macros (Inline Functions) Definitions *******************/

/************************** Function Prototypes ****************************/

XStatus TosNet_Initialize(TosNet *instancePtr, unsigned int *MemBaseAddress, unsigned int *RegBaseAddress);								//Initializes a TosNet structure with the addresses of the memory and registers
unsigned int TosNet_GetNodeID(TosNet *instancePtr);																						//Returns the id of the node
unsigned int TosNet_GetNodeAddress(TosNet *instancePtr);																				//Returns the current address (that is, its position in the ring, relative to the current master) of the node
unsigned int TosNet_GetRegEnable(TosNet *instancePtr);																					//Returns the reg enables (bit 0 is 1 if register 0 is enabled, bit 1 is 1 if register 1 is enabled, etc, up to bit 7)
int TosNet_IsOnline(TosNet *instancePtr);																								//Returns 1 if the network is online, 0 otherwise
int TosNet_IsMaster(TosNet *instancePtr);																								//Returns 1 if the node is master, 0 if slave
int TosNet_SystemHalted(TosNet *instancePtr);																							//Returns 1 if the system is halted, 0 otherwise
void TosNet_CommitIn(TosNet *instancePtr);																								//Commits the in registers
void TosNet_CommitOut(TosNet *instancePtr);																								//Commits the out registers
unsigned int TosNet_GetPacketCounter(TosNet *instancePtr);																				//Returns the value of the packet counter
unsigned int TosNet_GetErrorCounter(TosNet *instancePtr);																				//Returns the value of the error counter
unsigned int TosNet_GetResetCounter(TosNet *instancePtr);																				//Returns the value of the reset counter
inline volatile unsigned int *TosNet_CalcInAddress(TosNet *instancePtr, unsigned int nodeId, unsigned int regId, unsigned int index);	//Returns a pointer to the shared memory block address of a specified in register at nodeId/regId/index
inline volatile unsigned int *TosNet_CalcOutAddress(TosNet *instancePtr, unsigned int nodeId, unsigned int regId, unsigned int index);	//Returns a pointer to the shared memory block address of a specified out register at nodeId/regId/index

int TosNet_AsyncDataReady(TosNet *instancePtr);																							//Returns 1 if data is available from the asynchronous channel
int TosNet_ReadAsync(TosNet *instancePtr, unsigned char *readBuffer, unsigned int maxBytes, unsigned int *nodeId);						//Reads up to maxBytes of data from the asynchronous channel, data is returned in readBuffer, nodeId holds the sender (if the current node is master), the id of the current node (if the current node is a slave), or 0 (if the data comes from a broadcast)
int TosNet_WriteAsync(TosNet *instancePtr, unsigned char *writeBuffer, unsigned int writeBytes, unsigned int nodeId);					//Writes writeBytes of data from writeBuffer to the asynchronous channel, nodeId should be the id of the target node (if the current node is master), the id of the current node (if the current node is a slave), or 0 (if the current node is master and wants to do a broadcast)

#endif /** TOSNET_H */
