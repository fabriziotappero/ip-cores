/*******************************************************************************
 * 
 * RapidIO IP Library Core
 * 
 * This file is part of the RapidIO IP library project
 * http://www.opencores.org/cores/rio/
 * 
 * Description:
 * This file contains the public API for riopacket.
 * 
 * To Do:
 * -
 * 
 * Author(s): 
 * - Magnus Rosenius, magro732@opencores.org 
 * 
 *******************************************************************************
 * 
 * Copyright (C) 2015 Authors and OPENCORES.ORG 
 * 
 * This source file may be used and distributed without 
 * restriction provided that this copyright statement is not 
 * removed from the file and that any derivative work contains 
 * the original copyright notice and the associated disclaimer. 
 * 
 * This source file is free software; you can redistribute it 
 * and/or modify it under the terms of the GNU Lesser General 
 * Public License as published by the Free Software Foundation; 
 * either version 2.1 of the License, or (at your option) any 
 * later version. 
 * 
 * This source is distributed in the hope that it will be 
 * useful, but WITHOUT ANY WARRANTY; without even the implied 
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR 
 * PURPOSE. See the GNU Lesser General Public License for more 
 * details. 
 * 
 * You should have received a copy of the GNU Lesser General 
 * Public License along with this source; if not, download it 
 * from http://www.opencores.org/lgpl.shtml 
 * 
 *******************************************************************************/
 
/** 
 * \file riopacket.c
 */

#ifndef __RIOPACKET_H
#define __RIOPACKET_H

/*******************************************************************************
 * Includes
 *******************************************************************************/

#include "rioconfig.h"


/*******************************************************************************
 * Global typedefs
 *******************************************************************************/

/* The maximum size of a RapidIO packet in words (32-bit). */
#define RIOPACKET_SIZE_MIN 3u
#define RIOPACKET_SIZE_MAX 69u

/* Configuration space offsets. */
#define DEVICE_IDENTITY_CAR ((uint32_t)0x00000000ul)
#define DEVICE_INFORMATION_CAR ((uint32_t)0x00000004ul)
#define ASSEMBLY_IDENTITY_CAR ((uint32_t)0x00000008ul)
#define ASSEMBLY_INFORMATION_CAR ((uint32_t)0x0000000cul)
#define PROCESSING_ELEMENT_FEATURES_CAR ((uint32_t)0x00000010ul)
#define SWITCH_PORT_INFORMATION_CAR ((uint32_t)0x00000014ul)
#define SOURCE_OPERATIONS_CAR ((uint32_t)0x00000018ul)
#define DESTINATION_OPERATIONS_CAR ((uint32_t)0x0000001cul)
#define SWITCH_ROUTE_TABLE_DESTINATION_ID_LIMIT_CAR ((uint32_t)0x00000034ul)
#define PROCESSING_ELEMENT_LOGICAL_LAYER_CONTROL_CSR ((uint32_t)0x0000004cul)
#define BASE_DEVICE_ID_CSR ((uint32_t)0x00000060ul)
#define HOST_BASE_DEVICE_ID_LOCK_CSR ((uint32_t)0x00000068ul)
#define COMPONENT_TAG_CSR ((uint32_t)0x0000006cul)
#define STANDARD_ROUTE_CONFIGURATION_DESTINATION_ID_SELECT_CSR ((uint32_t)0x00000070ul)
#define STANDARD_ROUTE_CONFIGURATION_PORT_SELECT_CSR ((uint32_t)0x00000074ul)
#define STANDARD_ROUTE_DEFAULT_PORT_CSR ((uint32_t)0x00000078ul)
#define EXTENDED_FEATURES_OFFSET ((uint32_t)0x00000100ul)
#define IMPLEMENTATION_DEFINED_OFFSET ((uint32_t)0x00010000ul)
#define LP_SERIAL_REGISTER_BLOCK_HEADER(offset) (offset)
#define PORT_LINK_TIMEOUT_CONTROL_CSR(offset) ((offset) + 0x00000020ul)
#define PORT_RESPONSE_TIMEOUT_CONTROL_CSR(offset) ((offset) + 0x00000024ul)
#define PORT_GENERAL_CONTROL_CSR(offset) ((offset) + 0x0000003cul)
#define PORT_N_LOCAL_ACKID_CSR(offset, n) ((offset) + (0x00000048ul+((n)*0x00000020ul)))
#define PORT_N_ERROR_AND_STATUS_CSR(offset, n) ((offset) + (0x00000058ul+((n)*0x00000020ul)))
#define PORT_N_CONTROL_CSR(offset, n) ((offset) + (0x0000005cul+((n)*0x00000020ul)))

/* Packet ftype constants. */
#define RIOPACKET_FTYPE_REQUEST 0x2
#define RIOPACKET_FTYPE_WRITE 0x5
#define RIOPACKET_FTYPE_MAINTENANCE 0x8
#define RIOPACKET_FTYPE_DOORBELL 0xa
#define RIOPACKET_FTYPE_MESSAGE 0xb
#define RIOPACKET_FTYPE_RESPONSE 0xd

/* Transaction constants. */
#define RIOPACKET_TRANSACTION_MAINT_READ_REQUEST 0ul
#define RIOPACKET_TRANSACTION_MAINT_WRITE_REQUEST 1ul
#define RIOPACKET_TRANSACTION_MAINT_READ_RESPONSE 2ul
#define RIOPACKET_TRANSACTION_MAINT_WRITE_RESPONSE 3ul
#define RIOPACKET_TRANSACTION_MAINT_PORT_WRITE_REQUEST 4ul
#define RIOPACKET_TRANSACTION_WRITE_NWRITE 4ul
#define RIOPACKET_TRANSACTION_WRITE_NWRITER 5ul
#define RIOPACKET_TRANSACTION_REQUEST_NREAD 4ul
#define RIOPACKET_TRANSACTION_RESPONSE_NO_PAYLOAD 0ul
#define RIOPACKET_TRANSACTION_RESPONSE_MESSAGE_RESPONSE 1ul
#define RIOPACKET_TRANSACTION_RESPONSE_WITH_PAYLOAD 8ul

/* Response status constants. */
#define RIOPACKET_RESPONSE_STATUS_DONE 0ul
#define RIOPACKET_RESPONSE_STATUS_RETRY 3ul
#define RIOPACKET_RESPONSE_STATUS_ERROR 7ul


/* The structure containing a RapidIO packet. */
typedef struct
{
  /* Size in words. */
  uint8_t size;
  uint32_t payload[RIOPACKET_SIZE_MAX];
} RioPacket_t;



/*******************************************************************************
 * Global function prototypes
 *******************************************************************************/

void RIOPACKET_init(RioPacket_t *packet);
uint8_t RIOPACKET_size(RioPacket_t *packet);
void RIOPACKET_append(RioPacket_t *packet, uint32_t word);

int RIOPACKET_valid(RioPacket_t *packet);

int RIOPACKET_serialize(RioPacket_t *packet, const uint16_t size, uint8_t *buffer);
int RIOPACKET_deserialize(RioPacket_t *packet, const uint16_t size, const uint8_t *buffer);

#ifdef ENABLE_TOSTRING
#include <stdio.h>
void RIOPACKET_toString(RioPacket_t *packet, char *buffer);
#endif

uint8_t RIOPACKET_getFtype(RioPacket_t *packet);
uint16_t RIOPACKET_getDestination(RioPacket_t *packet);
uint16_t RIOPACKET_getSource(RioPacket_t *packet);
uint8_t RIOPACKET_getTransaction(RioPacket_t *packet);
uint8_t RIOPACKET_getTid(RioPacket_t *packet);

void RIOPACKET_setMaintReadRequest(RioPacket_t *packet,
                                   uint16_t destId, uint16_t srcId, uint8_t hop,
                                   uint8_t tid, uint32_t offset);
void RIOPACKET_getMaintReadRequest(RioPacket_t *packet,
                                   uint16_t *destId, uint16_t *srcId, uint8_t *hop,
                                   uint8_t *tid, uint32_t *offset);

void RIOPACKET_setMaintReadResponse(RioPacket_t *packet,
                                    uint16_t destId, uint16_t srcId,
                                    uint8_t tid, uint32_t data);
void RIOPACKET_getMaintReadResponse(RioPacket_t *packet,
                                    uint16_t *destId, uint16_t *srcId,
                                    uint8_t *tid, uint32_t *data);

void RIOPACKET_setMaintWriteRequest(RioPacket_t *packet,
                                    uint16_t destId, uint16_t srcId, uint8_t hop, 
                                    uint8_t tid, uint32_t offset, uint32_t data);
void RIOPACKET_getMaintWriteRequest(RioPacket_t *packet,
                                    uint16_t *destId, uint16_t *srcId, uint8_t *hop, 
                                    uint8_t *tid, uint32_t *offset, uint32_t *data);

void RIOPACKET_setMaintWriteResponse(RioPacket_t *packet,
                                     uint16_t destId, uint16_t srcId, 
                                     uint8_t tid);
void RIOPACKET_getMaintWriteResponse(RioPacket_t *packet,
                                     uint16_t *destId, uint16_t *srcId, 
                                     uint8_t *tid);

void RIOPACKET_setMaintPortWrite(RioPacket_t *packet,
                                 uint16_t destId, uint16_t srcId, 
                                 uint32_t componentTag, uint32_t portErrorDetect,
                                 uint32_t implementationSpecific, uint8_t portId,
                                 uint32_t logicalTransportErrorDetect);
void RIOPACKET_getMaintPortWrite(RioPacket_t *packet,
                                 uint16_t *destId, uint16_t *srcId, 
                                 uint32_t *componentTag, uint32_t *portErrorDetect,
                                 uint32_t *implementationSpecific, uint8_t *portId,
                                 uint32_t *logicalTransportErrorDetect);

void RIOPACKET_setNwrite(RioPacket_t *packet, 
                         uint16_t destId, uint16_t srcId, 
                         uint32_t address, uint16_t payloadSize, uint8_t *payload);
void RIOPACKET_getNwrite(RioPacket_t *packet, 
                         uint16_t *destId, uint16_t *srcId, 
                         uint32_t *address, uint16_t *payloadSize, uint8_t *payload);

void RIOPACKET_setNwriteR(RioPacket_t *packet, 
                          uint16_t destId, uint16_t srcId, 
                          uint8_t tid, 
                          uint32_t address, uint16_t payloadSize, uint8_t *payload);
void RIOPACKET_getNwriteR(RioPacket_t *packet, 
                          uint16_t *destId, uint16_t *srcId, 
                          uint8_t *tid,
                          uint32_t *address, uint16_t *payloadSize, uint8_t *payload);

void RIOPACKET_setNread(RioPacket_t *packet, 
                        uint16_t destId, uint16_t srcId, 
                        uint8_t tid, 
                        uint32_t address, uint16_t payloadSize);
void RIOPACKET_getNread(RioPacket_t *packet, 
                        uint16_t *destId, uint16_t *srcId, 
                        uint8_t *tid, 
                        uint32_t *address, uint16_t *payloadSize);


void RIOPACKET_setDoorbell(RioPacket_t *packet,
                           uint16_t destId, uint16_t srcId, 
                           uint8_t tid, uint16_t info);
void RIOPACKET_getDoorbell(RioPacket_t *packet,
                           uint16_t *destId, uint16_t *srcId, 
                           uint8_t *tid, uint16_t *info);

void RIOPACKET_setMessage(RioPacket_t *packet,
                          uint16_t destId, uint16_t srcId, 
                          uint8_t mailbox, 
                          uint16_t size, uint8_t *payload); 
void RIOPACKET_getMessage(RioPacket_t *packet,
                          uint16_t *destId, uint16_t *srcId, 
                          uint8_t *mailbox, 
                          uint16_t *size, uint8_t *payload); 


void RIOPACKET_setResponseNoPayload(RioPacket_t *packet, 
                                    uint16_t destId, uint16_t srcId, 
                                    uint8_t tid, uint8_t status);
void RIOPACKET_getResponseNoPayload(RioPacket_t *packet, 
                                    uint16_t *destId, uint16_t *srcId, 
                                    uint8_t *tid, uint8_t *status);

void RIOPACKET_setResponseWithPayload(RioPacket_t *packet, 
                                      uint16_t destId, uint16_t srcId, 
                                      uint8_t tid, uint8_t offset,
                                      uint16_t size, uint8_t *payload);
void RIOPACKET_getResponseWithPayload(RioPacket_t *packet, 
                                      uint16_t *destId, uint16_t *srcId, 
                                      uint8_t *tid, uint8_t offset,
                                      uint16_t *size, uint8_t *payload);

void RIOPACKET_setResponseMessage(RioPacket_t *packet, 
                                  uint16_t destId, uint16_t srcId, 
                                  uint8_t mailbox, uint8_t status);
void RIOPACKET_getResponseMessage(RioPacket_t *packet, 
                                  uint16_t *destId, uint16_t *srcId, 
                                  uint8_t *mailbox, uint8_t *status);

uint16_t RIOPACKET_Crc16( const uint16_t data, const uint16_t crc);
uint16_t RIOPACKET_Crc32( const uint32_t data, uint16_t crc);

uint32_t RIOPACKET_getReadPacketSize(uint32_t address, uint32_t size);
uint32_t RIOPACKET_getWritePacketSize(uint32_t address, uint32_t size);

#endif

/*************************** end of file **************************************/
