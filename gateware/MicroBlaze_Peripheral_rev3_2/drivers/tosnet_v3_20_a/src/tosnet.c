/*****************************************************************************
* Filename:          /drivers/tosnet_v1_00_a/src/tosnet.c
* Version:           3.20.a
* Description:       tosnet Driver Source File
* Date:              Mon Feb 15 11:56:16 2010 (by Create and Import Peripheral Wizard)
*****************************************************************************/


#define NODE_ID_BITS 0xf
#define NODE_ID_OFFSET 8
#define NODE_ADDRESS_BITS 0xf
#define NODE_ADDRESS_OFFSET 12
#define REG_ENABLE_BITS 0xff 
#define REG_ENABLE_OFFSET 16
#define SYSTEM_HALT_BITS 0x1
#define SYSTEM_HALT_OFFSET 4
#define ONLINE_BITS 0x1
#define ONLINE_OFFSET 2
#define IS_MASTER_BITS 0x1
#define IS_MASTER_OFFSET 3
#define ASYNC_VALID_BITS 0x1
#define ASYNC_VALID_OFFSET 7
#define ASYNC_NODE_ID_BITS 0xf
#define ASYNC_NODE_ID_OFFSET 28
#define ASYNC_BE_BITS 0x3
#define ASYNC_BE_OFFSET 26
#define ASYNC_FULL_BITS 0x1
#define ASYNC_FULL_OFFSET 5

/***************************** Include Files *******************************/

#include "tosnet.h"

/************************** Function Definitions ***************************/

XStatus TosNet_Initialize(TosNet *instancePtr, unsigned int *MemBaseAddress, unsigned int *RegBaseAddress)
{
	instancePtr->MemBaseAddress = (volatile unsigned int*) MemBaseAddress;
	instancePtr->RegBaseAddress = (volatile unsigned int*) RegBaseAddress;

	(instancePtr->RegBaseAddress)[0] = 0x00000003;
	(instancePtr->RegBaseAddress)[0] = 0x0;
	
	return XST_SUCCESS;
}

unsigned int TosNet_GetNodeID(TosNet *instancePtr)
{
	return (((instancePtr->RegBaseAddress)[0] >> NODE_ID_OFFSET) & NODE_ID_BITS);
}

unsigned int TosNet_GetNodeAddress(TosNet *instancePtr)
{
	return (((instancePtr->RegBaseAddress)[0] >> NODE_ADDRESS_OFFSET) & NODE_ADDRESS_BITS);
}

unsigned int TosNet_GetRegEnable(TosNet *instancePtr)
{
	return (((instancePtr->RegBaseAddress)[0] >> REG_ENABLE_OFFSET) & REG_ENABLE_BITS);
}

int TosNet_IsOnline(TosNet *instancePtr)
{
	return (((instancePtr->RegBaseAddress)[0] >> ONLINE_OFFSET) & ONLINE_BITS);
}

int TosNet_IsMaster(TosNet *instancePtr)
{
	return (((instancePtr->RegBaseAddress)[0] >> IS_MASTER_OFFSET) & IS_MASTER_BITS);
}

int TosNet_SystemHalted(TosNet *instancePtr)
{
	return (((instancePtr->RegBaseAddress)[0] >> SYSTEM_HALT_OFFSET) & SYSTEM_HALT_BITS);
}

void TosNet_CommitIn(TosNet *instancePtr)
{
	unsigned int regTemp = (instancePtr->RegBaseAddress)[0] & 0xfffffffc;
	(instancePtr->RegBaseAddress)[0] = regTemp + 1;
	(instancePtr->RegBaseAddress)[0] = regTemp;
	
	return;
}

void TosNet_CommitOut(TosNet *instancePtr)
{
	unsigned int regTemp = (instancePtr->RegBaseAddress)[0] & 0xfffffffc;
	(instancePtr->RegBaseAddress)[0] = regTemp + 2;
	(instancePtr->RegBaseAddress)[0] = regTemp;
	
	return;
}

unsigned int TosNet_GetPacketCounter(TosNet *instancePtr)
{
	return (instancePtr->RegBaseAddress)[1];
}

unsigned int TosNet_GetErrorCounter(TosNet *instancePtr)
{
	return (instancePtr->RegBaseAddress)[2];
}

unsigned int TosNet_GetResetCounter(TosNet *instancePtr)
{
	return (instancePtr->RegBaseAddress)[3];
}

inline volatile unsigned int *TosNet_CalcInAddress(TosNet *instancePtr, unsigned int nodeId, unsigned int regId, unsigned int index)
{
	return (instancePtr->MemBaseAddress) + (nodeId << 6) + (regId << 3) + (1 << 2) + index;
}

inline volatile unsigned int *TosNet_CalcOutAddress(TosNet *instancePtr, unsigned int nodeId, unsigned int regId, unsigned int index)
{
	return (instancePtr->MemBaseAddress) + (nodeId << 6) + (regId << 3) + index;
}

int TosNet_AsyncDataReady(TosNet *instancePtr)
{
	return ((((instancePtr->RegBaseAddress)[0]) >> ASYNC_VALID_OFFSET) & ASYNC_VALID_BITS);
}

int TosNet_ReadAsync(TosNet *instancePtr, unsigned char *readBuffer, unsigned int maxBytes, unsigned int *nodeId)
{
	int currentNode = ((((instancePtr->RegBaseAddress)[0]) >> ASYNC_NODE_ID_OFFSET) & ASYNC_NODE_ID_BITS);
	unsigned int dataBuffer, beBuffer, byteCount = 0, n, done = 0;
	
	while(TosNet_AsyncDataReady(instancePtr) && (currentNode == (((instancePtr->RegBaseAddress)[0] >> ASYNC_NODE_ID_OFFSET) & ASYNC_NODE_ID_BITS)) && (byteCount < maxBytes) && (done == 0))
	{
		beBuffer = (((instancePtr->RegBaseAddress)[0] >> ASYNC_BE_OFFSET) & ASYNC_BE_BITS);
		dataBuffer = (instancePtr->RegBaseAddress)[4];		//This performs the read, and triggers the core to read out the next value from the FIFO

		if(beBuffer < 3)
		{
			done = 1;
		}
				
		for(n=0; n<(beBuffer+1); n++)
		{
			readBuffer[byteCount++] = ((unsigned char*)(&dataBuffer))[n];
			if(byteCount == maxBytes)
			{
				break;
			}
		}
	}
	
	*nodeId = currentNode;
	
	return byteCount;
}


int TosNet_WriteAsync(TosNet *instancePtr, unsigned char *writeBuffer, unsigned int writeBytes, unsigned nodeId)
{
	unsigned int dataBuffer, beBuffer, n, byteCount = 0;
	unsigned int regTemp = ((instancePtr->RegBaseAddress)[0] & 0x03ffffff) + ((nodeId & ASYNC_NODE_ID_BITS) << ASYNC_NODE_ID_OFFSET);
	
	while(!(((instancePtr->RegBaseAddress)[0] >> ASYNC_FULL_OFFSET) & ASYNC_FULL_BITS) && (byteCount < writeBytes))
	{
		dataBuffer = 0;
		beBuffer = 0;
		
		for(n=0; n<4; n++)
		{
			dataBuffer += (unsigned int)(writeBuffer[byteCount++] << (8*(3-n)));
			beBuffer++;
			if(byteCount == writeBytes)
			{
				break;
			}
		}
		
		(instancePtr->RegBaseAddress)[0] = regTemp + (((beBuffer-1) & ASYNC_BE_BITS) << ASYNC_BE_OFFSET);
		(instancePtr->RegBaseAddress)[4] = dataBuffer;		//This performs the write, and triggers the core to write the value into the FIFO
	}
	
	return byteCount;
}

