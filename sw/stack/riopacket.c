/*******************************************************************************
 * 
 * RapidIO IP Library Core
 * 
 * This file is part of the RapidIO IP library project
 * http://www.opencores.org/cores/rio/
 * 
 * Description:
 * This file contains an "object" that can create and parse RapidIO packets. 
 * It is used in the SW RapidIO stack, riostack.c, but can also be used 
 * stand-alone together with other software, for example to tunnel RapidIO
 * packet over an arbitrary network.
 * More details about the usage can be found in the module tests in 
 * test_riopacket.c.
 * 
 * To Do:
 * - Add packet handlers for 8-bit deviceIds.
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

/*******************************************************************************
 * Includes
 *******************************************************************************/

#include "riopacket.h"

/* Let lint report errors and warnings only. */
/*lint -w2 */


/*******************************************************************************
 * Local macro definitions
 *******************************************************************************/

/* Macros to get entries from a packet in a buffer. */
#define FTYPE_GET(p) (((p)[0] >> 16) & 0xf)
#define DESTID_GET(p) ((p)[0] & 0xffff)
#define SRCID_GET(p) (((p)[1] >> 16) & 0xffff)
#define TRANSACTION_GET(p) (((p)[1] >> 12) & 0xf)
#define MSGLEN_GET(p) TRANSACTION_GET(p)
#define SSIZE_GET(p) (((p)[1] >> 8) & 0xf)
#define LETTER_GET(p) (((p)[1] >> 6) & 0x3)
#define MBOX_GET(p) (((p)[1] >> 4) & 0x3)
#define MSGSEG_GET(p) ((p)[1] & 0xf)
#define XMBOX_GET(p) MSGSEG_GET(p)
#define RDSIZE_GET(p) SSIZE_GET(p)
#define WRSIZE_GET(p) SSIZE_GET(p)
#define STATUS_GET(p) SSIZE_GET(p)
#define TID_GET(p) ((p)[1] & 0xff)
#define HOP_GET(p) (((p)[2] >> 24) & 0xff)
#define CONFIG_OFFSET_GET(p) ((p)[2] & 0x00fffffcul)
#define INFO_GET(p) (((p)[2] >> 16) & 0xffff)
#define ADDRESS_GET(p) ((p)[2] & 0xfffffff8ul)
#define WDPTR_GET(p) (((p)[2] >> 2) & 0x1)
#define XAMBS_GET(p) ((p)[2] & 0x3)
#define DOUBLE_WORD_MSB_GET(p, i) (p)[3+(2*i+0)]
#define DOUBLE_WORD_LSB_GET(p, i) (p)[3+(2*i+1)]



/*******************************************************************************
 * Local function prototypes
 *******************************************************************************/

/* Functions to help get and set payload in the packets. */
static uint16_t getPacketPayload(uint32_t *packet, const uint16_t payloadOffset, 
                                 const uint16_t dataOffset, 
                                 const uint16_t dataSize, uint8_t *data);
static uint16_t setPacketPayload(uint32_t *packet, const uint16_t payloadOffset, 
                                 const uint16_t dataOffset, 
                                 const uint16_t dataSize, const uint8_t *data);

/* Functions to help in conversions between rdsize/wrsize and size/offset. */
static uint16_t rdsizeGet(const uint32_t address, const uint16_t size);
static uint16_t wrsizeGet(const uint32_t address, const uint16_t size);
static void rdsizeToOffset(uint8_t wrsize, uint8_t wdptr, 
                           uint8_t *offset, uint16_t *size);
static void wrsizeToOffset(uint8_t wrsize, uint8_t wdptr, 
                           uint8_t *offset, uint16_t *size);



/*******************************************************************************
 * Global function prototypes
 *******************************************************************************/

/**
 * \brief Initialize a packet to an empty packet.
 *
 * \param[in] packet The packet to operate on.
 *
 * This function sets the size of a packet to zero. 
 *
 * \note Any previous content is NOT purged.
 */
void RIOPACKET_init(RioPacket_t *packet)
{
  packet->size = 0;
}


/**
 * \brief Return the size of a packet.
 *
 * \param[in] packet The packet to operate on.
 * \return The size of the packet.
 *
 * This function gets the size of a packet in words (32-bit).
 */
uint8_t RIOPACKET_size(RioPacket_t *packet)
{
  return packet->size;
}


/**
 * \brief Append data to a packet.
 *
 * \param[in] packet The packet to operate on.
 * \param[in] word The word to append.
 *
 * This function appends a specificed word (32-bit) to the end of a packet.
 */
void RIOPACKET_append(RioPacket_t *packet, uint32_t word)
{
  if(packet->size < RIOPACKET_SIZE_MAX)
  {
    packet->payload[packet->size] = word;
    packet->size++;
  }
}


/**
 * \brief Check if a packet is a valid RapidIO packet.
 *
 * \param[in] packet The packet to operate on.
 * \return The return value is zero if not ok, non-zero otherwise.
 *
 * This function checks if a packet has a correct length and a correct CRC. 
 * Both the embedded crc and the trailing crc are checked. 
 */
int RIOPACKET_valid(RioPacket_t *packet)
{
  int returnValue;
  uint32_t i;
  uint16_t crc;


  /* Check that the size of the packet is ok. */
  if((packet->size >= RIOPACKET_SIZE_MIN) &&
     (packet->size <= RIOPACKET_SIZE_MAX))
  {
    /* The packet has a valid length. */

    /* Calculate CRC on the first word and disregard the ackId. */
    crc = RIOPACKET_Crc32(packet->payload[0] & 0x03fffffful, 0xffffu);

    /* Check if the packet contains an embedded crc. */
    if(packet->size < 20)
    {
      /* The packet contains only one trailing crc. */
      for(i = 1; i < packet->size; i++)
      {
        crc = RIOPACKET_Crc32(packet->payload[i], crc);
      }
      returnValue = (crc == 0x0000u);
    }
    else
    {
      /* The packet contains both a trailing and an embedded crc. */

      /* Read payload to the embedded crc. Include the embedded crc in 
         the crc calculation.*/
      for(i = 1; i < 20; i++)
      {
        crc = RIOPACKET_Crc32(packet->payload[i], crc);
      }

      /* Check the embedded crc. */
      if(crc != ((uint16_t) (packet->payload[i] >> 16)))
      {
        /* The embedded crc is not ok. */
        returnValue = 0;
      }
      else
      {
        /* Read the rest of the payload including the trailing crc. */
        for(i = 20; i < packet->size; i++)
        {
          crc = RIOPACKET_Crc32(packet->payload[i], crc);
        }
        returnValue = (crc == 0x0000u);
      }
    }
  }
  else
  {    
    /* The packet does not have a valid length. */
    returnValue = 0;
  }

  return returnValue;
}


/**
 * \brief Convert (serializes) a packet into an array of bytes.
 *
 * \param[in] packet The packet to operate on.
 * \param[in] size The size of the buffer to write to.
 * \param[out] buffer The address to write the result to.
 * \return The number of bytes that were written. The value 0 will be returned if the 
 * serialized buffer does not fit into the provided buffer.
 *
 * This function serializes a packet into an array of bytes that can be transfered on 
 * a transmission channel.
 */
int RIOPACKET_serialize(RioPacket_t *packet, const uint16_t size, uint8_t *buffer)
{
  int returnValue;
  int i;


  /* Check if the packet fits into the provided buffer. */
  if(size >= ((4*packet->size)+1))
  {
    /* The packet fits. */

    /* Write the size of the packet and the packet content itself to the buffer. */
    buffer[0] = packet->size;
    for(i = 0; i < packet->size; i++)
    {
      buffer[(4*i)+1] = (packet->payload[i] >> 24) & 0xff;
      buffer[(4*i)+2] = (packet->payload[i] >> 16) & 0xff;
      buffer[(4*i)+3] = (packet->payload[i] >> 8) & 0xff;
      buffer[(4*i)+4] = (packet->payload[i] >> 0) & 0xff;
    }
    
    /* Write the number of bytes that were written. */
    returnValue = (4*packet->size)+1;
  }
  else
  {
    /* The packet does not fit into the provided buffer. */
    returnValue = 0;
  }

  return returnValue;
}


/**
 * \brief Convert (deserializes) an array of bytes to a packet.
 *
 * \param[in] packet The packet to operate on.
 * \param[in] size The size of the buffer to read from.
 * \param[in] buffer The address to read from.
 * \return The number of words contained in the resulting packet. The value 0 is 
 * returned if the deserialization was unsuccessfull.
 *
 * This function deserializes a packet from a byte array that was previously created
 *  by RIOPACKET_serialize().
 *
 * \note It is recommended to use RIOPACKET_valid() to verify the integrity of the packet 
 * once it has been deserialized.
 */
int RIOPACKET_deserialize(RioPacket_t *packet, const uint16_t size, const uint8_t *buffer)
{
  int i;
  uint32_t temp = 0;


  /* Check if the buffer contains a valid packet length. */
  if(((buffer[0] >= RIOPACKET_SIZE_MIN) &&
      (buffer[0] <= RIOPACKET_SIZE_MAX)) &&
     ((4*buffer[0]+1) <= size))
  {
    /* The buffer contains a valid packet length. */

    /* Read the size of the packet and the packet content itself from the buffer. */
    packet->size = buffer[0];
    for(i = 0; (i < 4*packet->size); i++)
    {
      temp <<= 8;
      temp |= buffer[i+1];
      if((i%4) == 3)
      {
        packet->payload[i/4] = temp;
      }
    }
  }
  else
  {
    /* The buffer does not contain a valid packet length. */
    packet->size = 0;
  }

  return packet->size;
}


/**
 * \brief Convert a packet into a printable buffer.
 *
 * \param[in] packet The packet to operate on.
 * \param[in] buffer The address to write the string to.
 *
 * This function converts a packet into a human readable '\0'-terminated ASCII-format and 
 * write it to the argument buffer. 
 *
 * \note The caller must guarantee that the destination buffer is large enough to contain 
 * the resulting string.
 */
#ifdef ENABLE_TOSTRING
#include <stdio.h>
void RIOPACKET_toString(RioPacket_t *packet, char *buffer)
{
  uint8_t ftype;
  uint8_t transaction;
  uint16_t destId;
  uint16_t srcId;
  uint8_t tid;


  ftype = RIOPACKET_getFtype(packet);
  transaction = RIOPACKET_getTransaction(packet);
  
  /* Check the message type and switch on it. */
  switch(ftype)
  {
    case RIOPACKET_FTYPE_REQUEST:
      /**************************************************************************************
       * A REQUEST has been received.
       **************************************************************************************/
      {
        uint32_t address;
        uint16_t payloadSize;


        if(transaction == RIOPACKET_TRANSACTION_REQUEST_NREAD)
        {
          RIOPACKET_getNread(packet, &destId, &srcId, &tid, &address, &payloadSize);
          sprintf(buffer, 
                  "NREAD: dstid=%04x srcid=%04x tid=%02x address=%08x payloadSize=%04x", 
                  destId, srcId, tid, address, payloadSize);
        }
        else
        {
          sprintf(buffer, "UNKNOWN:ftype=%02x transaction=%02x", ftype, transaction);
        }
      }
      break;

    case RIOPACKET_FTYPE_WRITE:
      /**************************************************************************************
       * An WRITE has been received.
       **************************************************************************************/
      {
        uint32_t address;
        uint16_t payloadSize;
        uint8_t payload[256];
        uint32_t index;
        uint32_t i;


        if(transaction == RIOPACKET_TRANSACTION_WRITE_NWRITE)
        {
          RIOPACKET_getNwrite(packet, &destId, &srcId, &address, &payloadSize, payload);

          index = sprintf(&buffer[0], 
                          "NWRITE: dstid=%04x srcid=%04x address=%08x payloadSize=%04x", 
                          destId, srcId, address, payloadSize);
          for(i = 0; i < payloadSize; i++)
          {
            index += sprintf(&buffer[index], "%02x", payload[i]);
          }
        }
        else if(transaction == RIOPACKET_TRANSACTION_WRITE_NWRITER)
        {
          RIOPACKET_getNwriteR(packet, &destId, &srcId, &tid, &address, &payloadSize, payload);

          index = sprintf(&buffer[0], 
                          "NWRITER: dstid=%04x srcid=%04x tid=%02x address=%08x payloadSize=%04x", 
                          destId, srcId, tid, address, payloadSize);
          for(i = 0; i < payloadSize; i++)
          {
            index += sprintf(&buffer[index], "%02x", payload[i]);
          }
        }
        else
        {
          sprintf(buffer, "UNKNOWN:ftype=%02x transaction=%02x", ftype, transaction);
        }
      }
      break;

    case RIOPACKET_FTYPE_MAINTENANCE:
      /**************************************************************************************
       * A maintenance packet has been received.
       **************************************************************************************/
      {
        uint8_t hop;
        uint32_t offset;
        uint32_t data;


        /* Check the transaction to determine the type. */
        if(transaction == RIOPACKET_TRANSACTION_MAINT_READ_REQUEST)
        {
          /* Maintenance read request. */
          RIOPACKET_getMaintReadRequest(packet, &destId, &srcId, &hop, &tid, &offset);
          sprintf(buffer, 
                  "MAINTREADREQUEST: dstid=%04x srcid=%04x tid=%02x hop=%02x offset=%08x", 
                  destId, srcId, tid, hop, offset);
        }
        else if(transaction == RIOPACKET_TRANSACTION_MAINT_WRITE_REQUEST)
        {
          /* Maintenance write request. */
          RIOPACKET_getMaintWriteRequest(packet, &destId, &srcId, &hop, &tid, &offset, &data);
          sprintf(buffer, 
                  "MAINTWRITEREQUEST: dstid=%04x srcid=%04x tid=%02x hop=%02x offset=%08x data=%08x", 
                  destId, srcId, tid, hop, offset, data);
        }
        else if(transaction == RIOPACKET_TRANSACTION_MAINT_READ_RESPONSE)
        {
          /* Maintenance read response. */
          RIOPACKET_getMaintReadResponse(packet, &destId, &srcId, &tid, &data);
          sprintf(buffer, 
                  "MAINTREADRESPONSE: dstid=%04x srcid=%04x tid=%02x data=%08x", 
                  destId, srcId, tid, data);
        }
        else if(transaction == RIOPACKET_TRANSACTION_MAINT_WRITE_RESPONSE)
        {
          /* Maintenance write repsonse. */
          RIOPACKET_getMaintWriteResponse(packet, &destId, &srcId, &tid);
          sprintf(buffer, 
                  "MAINTWRITERESPONSE: dstid=%04x srcid=%04x tid=%02x", 
                  destId, srcId, tid);
        }
        else if(transaction == RIOPACKET_TRANSACTION_MAINT_PORT_WRITE_REQUEST)
        {
          uint32_t componentTag;
          uint32_t portErrorDetect;
          uint32_t implementationSpecific;
          uint8_t portId;
          uint32_t logicalTransportErrorDetect;
          
          /* Maintenance port write packet. */
          RIOPACKET_getMaintPortWrite(packet, &destId, &srcId, 
                                      &componentTag, &portErrorDetect, &implementationSpecific, 
                                      &portId, &logicalTransportErrorDetect);
          sprintf(buffer, 
                  "MAINTPORTWRITE: dstid=%04x srcid=%04x componentTag=%08x portErrorDetect=%08x"
                  "implementationSpecific=%08x portId=%02x logicalTransportErrorDetect=%08x", 
                  destId, srcId, componentTag, portErrorDetect, implementationSpecific, portId, 
                  logicalTransportErrorDetect);
        }
        else
        {
          sprintf(buffer, "UNKNOWN:ftype=%02x transaction=%02x", ftype, transaction);
        }
      }
      break;

    case RIOPACKET_FTYPE_DOORBELL:
      /**************************************************************************************
       * A doorbell packet has been received.
       **************************************************************************************/
      {
        uint16_t info;


        RIOPACKET_getDoorbell(packet, &destId, &srcId, &tid, &info);
        sprintf(buffer, 
                "DOORBELL: dstid=%04x srcid=%04x tid=%02x info=%04x", 
                destId, srcId, tid, info);
      }
      break;

    case RIOPACKET_FTYPE_MESSAGE:
      /**************************************************************************************
       * A messaget has been received.
       **************************************************************************************/
      {
        uint16_t payloadSize;
        uint8_t payload[256];
        uint32_t index;
        uint32_t i;


        RIOPACKET_getMessage(packet, &destId, &srcId, &tid, &payloadSize, payload);

        index = sprintf(&buffer[0], 
                        "MESSAGE: dstid=%04x srcid=%04x mailbox=%02x payloadSize=%04x", 
                        destId, srcId, tid, payloadSize);
        for(i = 0; i < payloadSize; i++)
        {
          index += sprintf(&buffer[index], "%02x", payload[i]);
        }
      }
      break;

    case RIOPACKET_FTYPE_RESPONSE:
      /**************************************************************************************
       * A response packet has been received.
       **************************************************************************************/
      {
        uint8_t status;
        uint16_t payloadSize;
        uint8_t payload[256];


        if(transaction == RIOPACKET_TRANSACTION_RESPONSE_NO_PAYLOAD)
        {
          RIOPACKET_getResponseNoPayload(packet, &destId, &srcId, &tid, &status);
          sprintf(buffer, 
                  "RESPONSENOPAYLOAD: dstid=%04x srcid=%04x tid=%02x status=%02x", 
                  destId, srcId, tid, status);
        }
        else if(transaction == RIOPACKET_TRANSACTION_RESPONSE_MESSAGE_RESPONSE)
        {
          RIOPACKET_getResponseMessage(packet, &destId, &srcId, &tid, &status);
          sprintf(buffer, 
                  "RESPONSEMESSAGE: dstid=%04x srcid=%04x mailbox=%02x status=%02x", 
                  destId, srcId, tid, status);
        }
        else if(transaction == RIOPACKET_TRANSACTION_RESPONSE_WITH_PAYLOAD)
        {
          uint32_t i;
          uint32_t index;


          RIOPACKET_getResponseWithPayload(packet, &destId, &srcId, &tid, 0, &payloadSize, payload);

          index = sprintf(&buffer[0], 
                          "RESPONSEWITHPAYLOAD: dstid=%04x srcid=%04x tid=%02x payloadSize=%04x ", 
                          destId, srcId, tid, payloadSize);
          for(i = 0; i < payloadSize; i++)
          {
            index += sprintf(&buffer[index], "%02x", payload[i]);
          }
        }
        else
        {
          sprintf(buffer, "UNKNOWN:ftype=%02x transaction=%02x", ftype, transaction);
        }
      }
      break;

    default:
      /**************************************************************************************
       * Unsupported ftype. 
       **************************************************************************************/
      sprintf(buffer, "UNKNOWN:ftype=%02x transaction=%02x", ftype, transaction);
      break;
  }

  return;
}
#endif


/**
 * \brief Return the ftype of a packet.
 *
 * \param[in] packet The packet to operate on.
 * \return The ftype of the packet.
 *
 * This function gets the ftype of a packet.
 */
uint8_t RIOPACKET_getFtype(RioPacket_t *packet)
{
  return FTYPE_GET(packet->payload);
}


/**
 * \brief Return the destination deviceId of a packet.
 *
 * \param[in] packet The packet to operate on.
 * \return The destination deviceId of the packet.
 *
 * This function gets the destination deviceId of a packet.
 */
uint16_t RIOPACKET_getDestination(RioPacket_t *packet)
{
  return DESTID_GET(packet->payload);
}


/**
 * \brief Return the source deviceId of a packet.
 *
 * \param[in] packet The packet to operate on.
 * \return The source deviceId of the packet.
 *
 * This function gets the source deviceId of a packet.
 */
uint16_t RIOPACKET_getSource(RioPacket_t *packet)
{
  return SRCID_GET(packet->payload);
}


/**
 * \brief Return the transaction of a packet.
 *
 * \param[in] packet The packet to operate on.
 * \return The transaction of the packet.
 *
 * This function gets the transaction field of a packet.
 *
 * \note Not all packets contain a transaction field.
 */
uint8_t RIOPACKET_getTransaction(RioPacket_t *packet)
{
  return TRANSACTION_GET(packet->payload);
}


/**
 * \brief Return the transaction identifier of a packet.
 *
 * \param[in] packet The packet to operate on.
 * \return The transaction identifier of the packet.
 *
 * This function gets the transaction identifier field of a packet.
 *
 * \note Not all packets contain a transaction identifier field.
 */
uint8_t RIOPACKET_getTid(RioPacket_t *packet)
{
  return TID_GET(packet->payload);
}


/*******************************************************************************************
 * Logical I/O MAINTENANCE-READ functions.
 *******************************************************************************************/

/**
 * \brief Set the packet to contain a maintenance read request.
 *
 * \param[in] packet The packet to operate on.
 * \param[in] destId The deviceId to use as destination in the packet.
 * \param[in] srcId The deviceId to use as source in the packet.
 * \param[in] hop The hop_count to set in the packet.
 * \param[in] tid The transaction identifier to set in the packet.
 * \param[in] offset The byte address in the configuration space to read.
 *
 * This function sets the content of a packet to a maintenance read request packet containing 
 * a request to read one word in configuration space.
 *
 */
void RIOPACKET_setMaintReadRequest(RioPacket_t *packet,
                                   uint16_t destId, uint16_t srcId, uint8_t hop,
                                   uint8_t tid, uint32_t offset)
{
  uint32_t content;
  uint16_t crc = 0xffffu;


  /* ackId(4:0)|0|vc|crf|prio(1:0)|tt(1:0)|ftype(3:0)|destinationId(15:0) */
  /* ackId is set when the packet is transmitted but must be set to zero. */
  content = 0x00180000ul;
  content |= (uint32_t) destId;
  crc = RIOPACKET_Crc32(content, crc);
  packet->payload[0] = content;

  /* sourceId(15:0)|transaction(3:0)|rdsize(3:0)|srcTID(7:0) */
  content = ((uint32_t) srcId) << 16;
  content |= (uint32_t) RIOPACKET_TRANSACTION_MAINT_READ_REQUEST << 12;
  content |= (uint32_t) 8ul << 8;
  content |= (uint32_t) tid;
  crc = RIOPACKET_Crc32(content, crc);
  packet->payload[1] = content;

  /* hopcount(7:0)|configOffset(20:0)|wdptr|reserved(1:0) */
  content = ((uint32_t) hop) << 24;
  content |= offset & 0x00fffffcul;
  crc = RIOPACKET_Crc32(content, crc);
  packet->payload[2] = content;

  /* crc(15:0)|pad(15:0) */
  content = ((uint32_t) crc) << 16;
  packet->payload[3] = content;

  /* Set the size of the packet. */
  packet->size = 4;
}


/**
 * \brief Get entries from a maintenance read request.
 *
 * \param[in] packet The packet to operate on.
 * \param[out] destId The destination deviceId in this packet.
 * \param[out] srcId The source deviceId in this packet.
 * \param[out] hop The hop_count in this packet.
 * \param[out] tid The transaction id to be returned in the response to this request.
 * \param[out] offset The byte address in the configuration space to read.
 *
 * This function returns the content of a packet as if it contained a maintenance read
 * request packet. 
 *
 * \note Use the ftype and transaction fields to see if the packet is indeed a 
 * maintenance read request.
 * \note If the packet does not contain a maintenance read request, the result 
 * will be undefined.
 */
void RIOPACKET_getMaintReadRequest(RioPacket_t *packet,
                                   uint16_t *destId, uint16_t *srcId, uint8_t *hop,
                                   uint8_t *tid, uint32_t *offset)
{
  *destId = DESTID_GET(packet->payload);
  *srcId = SRCID_GET(packet->payload);
  *tid = TID_GET(packet->payload);
  *hop = HOP_GET(packet->payload);
  *offset = CONFIG_OFFSET_GET(packet->payload);
}


/**
 * \brief Set the packet to contain a maintenance read response.
 *
 * \param[in] packet The packet to operate on.
 * \param[in] destId The deviceId to use as destination in the packet.
 * \param[in] srcId The deviceId to use as source in the packet.
 * \param[in] tid The transaction identifier to set in the packet.
 * \param[in] data The data to send in the packet.
 *
 * This function sets the content of a packet to a maintanance read response packet
 * containing a response to a request reading one word in configuration space.
 */
void RIOPACKET_setMaintReadResponse(RioPacket_t *packet,
                                    uint16_t destId, uint16_t srcId, 
                                    uint8_t tid, uint32_t data)
{
  uint32_t content;
  uint16_t crc = 0xffffu;


  /* ackId(4:0)|0|vc|crf|prio(1:0)|tt(1:0)|ftype(3:0)|destinationId(15:0) */
  /* ackId is set when the packet is transmitted. */
  content = 0x00180000ul;
  content |= (uint32_t) destId;
  crc = RIOPACKET_Crc32(content, crc);
  packet->payload[0] = content;

  /* sourceId(15:0)|transaction(3:0)|status(3:0)|srcTID(7:0) */
  content = (uint32_t) srcId << 16;
  content |= (uint32_t) RIOPACKET_TRANSACTION_MAINT_READ_RESPONSE << 12;
  content |= (uint32_t) RIOPACKET_RESPONSE_STATUS_DONE << 8;
  content |= (uint32_t) tid;
  crc = RIOPACKET_Crc32(content, crc);
  packet->payload[1] = content;

  /* hopcount(7:0)|reserved(23:0) */
  /* HopCount should always be set to 0xff in responses. */
  content = 0xff000000ul;
  crc = RIOPACKET_Crc32(content, crc);
  packet->payload[2] = content;

  /* double-word 0 */
  /* Note that both words are filled in to avoid looking at the offset. The receiver will not 
     look at the other part anyway. The standard does not say anything about the value of the padding. */
  content = data;
  crc = RIOPACKET_Crc32(content, crc);
  packet->payload[3] = content;
  content = data;
  crc = RIOPACKET_Crc32(content, crc);
  packet->payload[4] = content;

  /* crc(15:0)|pad(15:0) */
  content = ((uint32_t) crc) << 16;
  packet->payload[5] = content;

  /* Set the size of the packet. */
  packet->size = 6;
}


/**
 * \brief Get entries from a maintenance read response.
 *
 * \param[in] packet The packet to operate on.
 * \param[out] destId The destination deviceId in this packet.
 * \param[out] srcId The source deviceId in this packet.
 * \param[out] tid The transaction identifier in the response.
 * \param[out] data The data in the response.
 *
 * This function returns the content of a packet as if it contained a maintenance 
 * read response packet.
 *
 * \note Use the ftype and transaction fields to see if the packet is indeed a 
 * maintenance read response.
 * \note If the packet does not contain a maintenance read response, the result 
 * will be undefined.
 */
void RIOPACKET_getMaintReadResponse(RioPacket_t *packet,
                                    uint16_t *destId, uint16_t *srcId,
                                    uint8_t *tid, uint32_t *data)
{
  *destId = DESTID_GET(packet->payload);
  *srcId = SRCID_GET(packet->payload);
  *tid = TID_GET(packet->payload);
  *data = DOUBLE_WORD_MSB_GET(packet->payload, 0) | DOUBLE_WORD_LSB_GET(packet->payload, 0);
}


/*******************************************************************************************
 * Logical I/O MAINTENANCE-WRITE functions.
 *******************************************************************************************/

/**
 * \brief Set the packet to contain a maintenance write request.
 *
 * \param[in] packet The packet to operate on.
 * \param[in] destId The deviceId to use as destination in the packet.
 * \param[in] srcId The deviceId to use as source in the packet.
 * \param[in] hop The hop_count to set in the packet.
 * \param[in] tid The transaction identifier to set in the packet.
 * \param[in] offset The byte address in the configuration space to write to.
 * \param[in] data The data to write in configuration space.
 *
 * This function sets the content of a packet to a maintenance write request packet 
 * containing a request to write one word in configuration space.
 */
void RIOPACKET_setMaintWriteRequest(RioPacket_t *packet,
                                    uint16_t destId, uint16_t srcId, uint8_t hop, 
                                    uint8_t tid, uint32_t offset, uint32_t data)
{
  uint32_t content;
  uint16_t crc = 0xffffu;


  /* ackId(4:0)|0|vc|crf|prio(1:0)|tt(1:0)|ftype(3:0)|destinationId(15:0) */
  /* ackId is set when the packet is transmitted. */
  content = 0x00180000ul;
  content |= (uint32_t) destId;
  crc = RIOPACKET_Crc32(content, crc);
  packet->payload[0] = content;

  /* sourceId(15:0)|transaction(3:0)|rdsize(3:0)|srcTID(7:0) */
  content = ((uint32_t) srcId) << 16;
  content |= (uint32_t) RIOPACKET_TRANSACTION_MAINT_WRITE_REQUEST << 12;
  content |= (uint32_t) 8ul << 8;
  content |= (uint32_t) tid;
  crc = RIOPACKET_Crc32(content, crc);
  packet->payload[1] = content;

  /* hopcount(7:0)|configOffset(20:0)|wdptr|reserved(1:0) */
  content = ((uint32_t) hop) << 24;
  content |= offset & 0x00fffffcul;
  crc = RIOPACKET_Crc32(content, crc);
  packet->payload[2] = content;

  /* double-word 0 */
  /* Note that both words are filled in to avoid looking at the offset. The receiver will not 
     look at the other part anyway. The standard does not say anything about the value of the padding. */
  content = data;
  crc = RIOPACKET_Crc32(content, crc);
  packet->payload[3] = content;
  content = data;
  crc = RIOPACKET_Crc32(content, crc);
  packet->payload[4] = content;

  /* crc(15:0)|pad(15:0) */
  content = ((uint32_t) crc) << 16;
  packet->payload[5] = content;

  /* Set the size of the packet. */
  packet->size = 6;
}


/**
 * \brief Get entries from a maintenance write request.
 *
 * \param[in] packet The packet to operate on.
 * \param[out] destId The destination deviceId in this packet.
 * \param[out] srcId The source deviceId in this packet.
 * \param[out] hop The hop_count in this packet.
 * \param[out] tid The transaction id in this packet.
 * \param[out] offset The byte address in the configuration space to read.
 * \param[out] data The data to requested to be written in configuration space.
 *
 * This function returns the content of a packet as if it contained a maintenance write
 * request packet. 
 *
 * \note Use the ftype and transaction fields to see if the packet is indeed a 
 * maintenance write request.
 * \note If the packet does not contain a maintenance write request, the result 
 * will be undefined.
 */
void RIOPACKET_getMaintWriteRequest(RioPacket_t *packet,
                                    uint16_t *destId, uint16_t *srcId, uint8_t *hop, 
                                    uint8_t *tid, uint32_t *offset, uint32_t *data)
{
  *destId = DESTID_GET(packet->payload);
  *srcId = SRCID_GET(packet->payload);
  *tid = TID_GET(packet->payload);
  *hop = HOP_GET(packet->payload);
  *offset = CONFIG_OFFSET_GET(packet->payload);
  *data = DOUBLE_WORD_MSB_GET(packet->payload, 0) | DOUBLE_WORD_LSB_GET(packet->payload, 0);
}


/**
 * \brief Set the packet to contain a maintenance write response.
 *
 * \param[in] packet The packet to operate on.
 * \param[in] destId The deviceId to use as destination in the packet.
 * \param[in] srcId The deviceId to use as source in the packet.
 * \param[in] tid The transaction identifier to set in the packet.
 *
 * This function sets the content of a packet to a maintanance write response packet
 * containing a response to a request writing one word in configuration space.
 */
void RIOPACKET_setMaintWriteResponse(RioPacket_t *packet,
                                     uint16_t destId, uint16_t srcId, 
                                     uint8_t tid)
{
  uint32_t content;
  uint16_t crc = 0xffffu;


  /* ackId(4:0)|0|vc|crf|prio(1:0)|tt(1:0)|ftype(3:0)|destinationId(15:0) */
  /* ackId is set when the packet is transmitted. */
  content = 0x00180000ul;
  content |= (uint32_t) destId;
  crc = RIOPACKET_Crc32(content, crc);
  packet->payload[0] = content;

  /* sourceId(15:0)|transaction(3:0)|status(3:0)|srcTID(7:0) */
  content = ((uint32_t) srcId) << 16;
  content |= (uint32_t) RIOPACKET_TRANSACTION_MAINT_WRITE_RESPONSE << 12;
  content |= (uint32_t) RIOPACKET_RESPONSE_STATUS_DONE << 8;
  content |= (uint32_t) tid;
  crc = RIOPACKET_Crc32(content, crc);
  packet->payload[1] = content;

  /* hopcount(7:0)|reserved(23:0) */
  /* HopCount should always be set to 0xff in responses. */
  content = 0xff000000ul;
  crc = RIOPACKET_Crc32(content, crc);
  packet->payload[2] = content;

  /* crc(15:0)|pad(15:0) */
  content = ((uint32_t) crc) << 16;
  packet->payload[3] = content;

  /* Set the size of the packet. */
  packet->size = 4;
}


/**
 * \brief Get entries from a maintenance write response.
 *
 * \param[in] packet The packet to operate on.
 * \param[out] destId The destination deviceId in this packet.
 * \param[out] srcId The source deviceId in this packet.
 * \param[out] tid The transaction identifier in the response.
 *
 * This function returns the content of a packet as if it contained a maintenance 
 * write response packet.
 *
 * \note Use the ftype and transaction fields to see if the packet is indeed a 
 * maintenance write response.
 * \note If the packet does not contain a maintenance write response, the result 
 * will be undefined.
 */
void RIOPACKET_getMaintWriteResponse(RioPacket_t *packet,
                                     uint16_t *destId, uint16_t *srcId, 
                                     uint8_t *tid)
{
  *destId = DESTID_GET(packet->payload);
  *srcId = SRCID_GET(packet->payload);
  *tid = TID_GET(packet->payload);
}


/*******************************************************************************************
 * Logical I/O MAINTENANCE-PORTWRITE functions.
 *******************************************************************************************/

/**
 * \brief Set the packet to contain a maintenance port-write request.
 *
 * \param[in] packet The packet to operate on.
 * \param[in] destId The deviceId to use as destination in the packet.
 * \param[in] srcId The deviceId to use as source in the packet.
 * \param[in] componentTag The value of the componentTag register to set in the packet.
 * \param[in] portErrorDetect The value of the Port N Error Detect CSR to set in the packet.
 * \param[in] implementationSpecific An implementation specific value to set in the packet.
 * \param[in] portId The port ID of the port to set in the packet.
 * \param[in] logicalTransportErrorDetect The value of the Logical/Transport Layer 
 * Error Detect CSR to set in the packet.
 *
 * This function sets the content of a packet to a maintenance port-write request packet.
 */
void RIOPACKET_setMaintPortWrite(RioPacket_t *packet,
                                 uint16_t destId, uint16_t srcId, 
                                 uint32_t componentTag, uint32_t portErrorDetect,
                                 uint32_t implementationSpecific, uint8_t portId,
                                 uint32_t logicalTransportErrorDetect)
{
  uint32_t content;
  uint16_t crc = 0xffffu;


  /* ackId(4:0)|0|vc|crf|prio(1:0)|tt(1:0)|ftype(3:0)|destinationId(15:0) */
  /* ackId is set when the packet is transmitted. */
  content = 0x00180000ul;
  content |= (uint32_t) destId;
  crc = RIOPACKET_Crc32(content, crc);
  packet->payload[0] = content;

  /* sourceId(15:0)|transaction(3:0)|rdsize(3:0)|srcTID(7:0) */
  content = (uint32_t) srcId << 16;
  content |= (uint32_t) RIOPACKET_TRANSACTION_MAINT_PORT_WRITE_REQUEST << 12;
  crc = RIOPACKET_Crc32(content, crc);
  packet->payload[1] = content;

  /* hopcount(7:0)|reserved(23:0) */
  content = 0x00000000ul;
  crc = RIOPACKET_Crc32(content, crc);
  packet->payload[2] = content;

  /* double-word 0 */
  content = componentTag;
  crc = RIOPACKET_Crc32(content, crc);
  packet->payload[3] = content;
  content = portErrorDetect;
  crc = RIOPACKET_Crc32(content, crc);
  packet->payload[4] = content;

  /* double-word 1 */
  content = implementationSpecific << 8;
  content |= (uint32_t) portId;
  crc = RIOPACKET_Crc32(content, crc);
  packet->payload[5] = content;
  content = logicalTransportErrorDetect;
  crc = RIOPACKET_Crc32(content, crc);
  packet->payload[6] = content;

  /* crc(15:0)|pad(15:0) */
  content = ((uint32_t) crc) << 16;
  packet->payload[7] = content;

  /* Set the size of the packet. */
  packet->size = 8;  
}


/**
 * \brief Get entries from a maintenance port-write request.
 *
 * \param[in] packet The packet to operate on.
 * \param[out] destId The device id of the destination end point.
 * \param[out] srcId The device id of the source end point.
 * \param[out] componentTag The value of the componentTag register in this packet.
 * \param[out] portErrorDetect The value of the Port N Error Detect CSR in this packet.
 * \param[out] implementationSpecific An implementation specific value in this packet.
 * \param[out] portId The port ID of the port in this packet.
 * \param[out] logicalTransportErrorDetect The value of the Logical/Transport Layer 
 * Error Detect CSR in this packet.
 *
 * This function returns the content of a packet as if it contained a maintenance port-write
 * request packet.
 *
 * \note Use the ftype and transaction fields to see if the packet is indeed a 
 * maintenance port-write request.
 * \note If the packet does not contain a maintenance port-write request, the result 
 * will be undefined.
 */
void RIOPACKET_getMaintPortWrite(RioPacket_t *packet,
                                 uint16_t *destId, uint16_t *srcId, 
                                 uint32_t *componentTag, uint32_t *portErrorDetect,
                                 uint32_t *implementationSpecific, uint8_t *portId,
                                 uint32_t *logicalTransportErrorDetect)
{
  *destId = DESTID_GET(packet->payload);
  *srcId = SRCID_GET(packet->payload);
  *componentTag = packet->payload[3];
  *portErrorDetect = packet->payload[4];
  *implementationSpecific = packet->payload[5] >> 8;
  *portId = (uint8_t) (packet->payload[5] & 0xff);
  *logicalTransportErrorDetect = packet->payload[6];
}


/*******************************************************************************************
 * Logical I/O NWRITE/NWRITER functions.
 *******************************************************************************************/

/**
 * \brief Set a packet to contain an NWRITE.
 *
 * \param[in] packet The packet to operate on.
 * \param[in] destId The deviceId to use as destination in the packet.
 * \param[in] srcId The deviceId to use as source in the packet.
 * \param[in] address The byte address in IO-space to write to.
 * \param[in] payloadSize The number of bytes to write. The largest allowed size is 256 bytes.
 * \param[in] payload A pointer to the array of bytes to write.
 *
 * This function sets the content of a packet to an NWRITE containing a request 
 * to write the number of bytes specified by payloadSize to the address specified by the 
 * address argument.
 *
 * \note The address is a byte address.
 *
 * \note Not all combinations of addresses and sizes are allowed. The packet will be empty 
 * if an unallowed address/payloadSize combination is used. Use RIOPACKET_getWritePacketSize() 
 * to get the maximum size to use based on the address and payloadSize.
 */
void RIOPACKET_setNwrite(RioPacket_t *packet, uint16_t destId, uint16_t srcId,
                         uint32_t address, uint16_t payloadSize, uint8_t *payload)
{
  uint32_t content;
  uint16_t wrsize;

  
  /* Convert the address and size to the wrsize field and check if the combination is valid. */
  wrsize = wrsizeGet(address, payloadSize);
  if(wrsize != 0xffff)
  {
    /* The address and size field combination is valid. */

    /* ackId(4:0)|0|vc|crf|prio(1:0)|tt(1:0)|ftype(3:0)|destinationId(15:0) */
    /* ackId is set when the packet is transmitted. */
    content = 0x00150000ul;
    content |= (uint32_t) destId;
    packet->payload[0] = content;
    
    /* sourceId(15:0)|transaction(3:0)|wrsize(3:0)|srcTID(7:0) */
    content = ((uint32_t) srcId) << 16;
    content |= (uint32_t) RIOPACKET_TRANSACTION_WRITE_NWRITE << 12;
    content |= (uint32_t) (wrsize & 0x0f00); 
    packet->payload[1] = content;
    
    /* address(28:0)|wdptr|xamsbs(1:0) */
    /* wrsize also contains wdptr in the lower nibble. */
    /* REMARK: Note that xamsbs cannot be used if the address is a word. If the 2 msb bits in the 
       34-bit address should be used, another mechanism to set it should be used. */
    content = (address & 0xfffffff8ul);
    content |= ((uint32_t) (wrsize & 0x000f)) << 2;
    packet->payload[2] = content;
    
    /* Place the payload buffer into the payload of the packet. */
    /* This function also calculates the CRC. */
    packet->size = setPacketPayload(&(packet->payload[0]), 12, address & 0x7, payloadSize, payload);
  }
  else
  {
    /* The address and size field combination is not valid. */
    /* Cannot create a packet from these arguments, indicate this by setting the packet size to zero. */
    packet->size = 0;
  }
}


/**
 * \brief Get entries from a NWRITE.
 *
 * \param[in] packet The packet to operate on.
 * \param[out] destId The destination deviceId in this packet.
 * \param[out] srcId The source deviceId in this packet.
 * \param[out] address The byte address into IO-space requested to be written.
 * \param[out] payloadSize The number of bytes requested to be written.
 * \param[out] payload The data requested to be written.
 *
 * This function returns the content of a packet as if it contained an NWRITE. 
 *
 * \note The address is a byte address.
 *
 * \note Any padding contained in double-word0 will be removed and the content 
 * will be placed where the payload pointer is pointing.
 */
void RIOPACKET_getNwrite(RioPacket_t *packet, uint16_t *destId, uint16_t *srcId, 
                         uint32_t *address, uint16_t *payloadSize, uint8_t *payload)
{
  uint8_t wrsize;
  uint8_t wdptr;
  uint8_t offset = 0;
  uint16_t size = 0;


  wrsize = WRSIZE_GET(packet->payload);
  wdptr = WDPTR_GET(packet->payload);
  wrsizeToOffset(wrsize, wdptr, &offset, &size);

  *destId = DESTID_GET(packet->payload);
  *srcId = SRCID_GET(packet->payload);
  *address = ADDRESS_GET(packet->payload) | offset;

  if(size > 16)
  {
    size = 4*(packet->size-4);
  }
  else
  {
    /* The size already contains the correct value. */
  }


  *payloadSize = getPacketPayload(&(packet->payload[0]), 12, offset, size, payload);
}



/**
 * \brief Set a packet to contain an NWRITER.
 *
 * \param[in] packet The packet to operate on.
 * \param[in] destId The deviceId to use as destination in the packet.
 * \param[in] srcId The deviceId to use as source in the packet.
 * \param[in] tid The transaction identifier to set in the packet.
 * \param[in] address The byte address in IO-space to write to.
 * \param[in] payloadSize The number of bytes to write. The largest allowed size is 256 bytes.
 * \param[in] payload A pointer to the array of bytes to write.
 *
 * This function sets the content of a packet to an NWRITER containing a request 
 * to write the number of bytes specified by payloadSize to the address specified by the 
 * address argument. This packet requires a RESPONSE containing the transaction identifier 
 * specified in this packet.
 *
 * \note The address is a byte address.
 *
 * \note Not all combinations of addresses and sizes are allowed. The packet will be empty 
 * if an unallowed address/payloadSize combination is used. Use RIOPACKET_getWritePacketSize() 
 * to get the maximum size to use based on the address and payloadSize.
 */
void RIOPACKET_setNwriteR(RioPacket_t *packet, uint16_t destId, uint16_t srcId, uint8_t tid, 
                          uint32_t address, uint16_t payloadSize, uint8_t *payload)
{
  uint32_t content;
  uint16_t wrsize;

  
  /* Convert the address and size to the wrsize field and check if the combination is valid. */
  wrsize = wrsizeGet(address, payloadSize);
  if(wrsize != 0xffff)
  {
    /* The address and size field combination is valid. */

    /* ackId(4:0)|0|vc|crf|prio(1:0)|tt(1:0)|ftype(3:0)|destinationId(15:0) */
    /* ackId is set when the packet is transmitted. */
    content = 0x00150000ul;
    content |= (uint32_t) destId;
    packet->payload[0] = content;
    
    /* sourceId(15:0)|transaction(3:0)|wrsize(3:0)|srcTID(7:0) */
    content = ((uint32_t) srcId) << 16;
    content |= (uint32_t) RIOPACKET_TRANSACTION_WRITE_NWRITER << 12;
    content |= (uint32_t) (wrsize & 0x0f00); 
    content |= (uint32_t) tid;
    packet->payload[1] = content;
    
    /* address(28:0)|wdptr|xamsbs(1:0) */
    /* wrsize also contains wdptr in the lower nibble. */
    /* REMARK: Note that xamsbs cannot be used if the address is a word. If the 2 msb bits in the 
       34-bit address should be used, another mechanism to set it should be used. */
    content = (address & 0xfffffff8ul);
    content |= ((uint32_t) (wrsize & 0x000f)) << 2;
    packet->payload[2] = content;
    
    /* Place the payload buffer into the payload of the packet. */
    /* This function also calculates the CRC. */
    packet->size = setPacketPayload(&(packet->payload[0]), 12, address & 0x7, payloadSize, payload);
  }
  else
  {
    /* The address and size field combination is not valid. */
    /* Cannot create a packet from these arguments, indicate this by setting the packet size to zero. */
    packet->size = 0;
  }
}


/**
 * \brief Get entries from a NWRITER.
 *
 * \param[in] packet The packet to operate on.
 * \param[out] destId The destination deviceId in this packet.
 * \param[out] srcId The source deviceId in this packet.
 * \param[out] tid The transaction id in this packet.
 * \param[out] address The byte address into IO-space requested to be written.
 * \param[out] payloadSize The number of bytes requested to be written.
 * \param[out] payload The data requested to be written.
 *
 * This function returns the content of a packet as if it contained an NWRITER. 
 *
 * \note The address is a byte address.
 *
 * \note Any padding contained in double-word0 will be removed and the content 
 * will be placed where the payload pointer is pointing.
 */
void RIOPACKET_getNwriteR(RioPacket_t *packet, uint16_t *destId, uint16_t *srcId, uint8_t *tid,
                          uint32_t *address, uint16_t *payloadSize, uint8_t *payload)
{
  uint8_t wrsize;
  uint8_t wdptr;
  uint8_t offset = 0;
  uint16_t size = 0;


  wrsize = WRSIZE_GET(packet->payload);
  wdptr = WDPTR_GET(packet->payload);
  wrsizeToOffset(wrsize, wdptr, &offset, &size);
  
  *destId = DESTID_GET(packet->payload);
  *srcId = SRCID_GET(packet->payload);
  *tid = TID_GET(packet->payload);
  *address = ADDRESS_GET(packet->payload) | offset;
  
  if(size > 16)
  {
    size = 4*(packet->size-4);
  }
  else
  {
    /* The size already contains the correct value. */
  }

  *payloadSize = getPacketPayload(&(packet->payload[0]), 12, offset, size, payload);
}


/*******************************************************************************************
 * Logical I/O NREAD functions.
 *******************************************************************************************/

/**
 * \brief Set a packet to contain an NREAD.
 *
 * \param[in] packet The packet to operate on.
 * \param[in] destId The deviceId to use as destination in the packet.
 * \param[in] srcId The deviceId to use as source in the packet.
 * \param[in] tid The transaction id to set in the response.
 * \param[in] address The byte address to read from.
 * \param[in] payloadSize The number of bytes to read. The largest allowed size is 256 bytes.
 *
 * This function sets the content of a packet to an NREAD containing a request 
 * to read the number of bytes specified by payloadSize from the address specified by the
 * address argument.
 *
 * \note The address is a byte address.
 *
 * \note Not all combinations of address and length are allowed. The packet will be empty
 * if an unallowed address/payloadSize combination is used. Use RIOPACKET_getReadPacketSize() 
 * to get the maximum size to use based on the address and payloadSize.
 */
void RIOPACKET_setNread(RioPacket_t *packet, uint16_t destId, uint16_t srcId, uint8_t tid, 
                        uint32_t address, uint16_t payloadSize)
{
  uint32_t content;
  uint16_t crc = 0xffffu;
  uint16_t rdsize;


  /* Convert the address and size to the rdsize field and check if the combination is valid. */
  rdsize = rdsizeGet(address, payloadSize);
  if(rdsize != 0xffff)
  {
    /* The address and size field combination is valid. */

    /* ackId(4:0)|0|vc|crf|prio(1:0)|tt(1:0)|ftype(3:0)|destinationId(15:0) */
    /* ackId is set when the packet is transmitted. */
    content = 0x00120000ul;
    content |= (uint32_t) destId;
    crc = RIOPACKET_Crc32(content, crc);
    packet->payload[0] = content;

    /* sourceId(15:0)|transaction(3:0)|rdsize(3:0)|srcTID(7:0) */
    content = ((uint32_t) srcId) << 16;
    content |= ((uint32_t) RIOPACKET_TRANSACTION_REQUEST_NREAD) << 12;
    content |= (uint32_t) (rdsize & 0x0f00);
    content |= (uint32_t) tid;
    crc = RIOPACKET_Crc32(content, crc);
    packet->payload[1] = content;

    /* address(28:0)|wdptr|xamsbs(1:0) */
    /* rdsize also contains wdptr in the lower nibble. */
    /* REMARK: Note that xamsbs cannot be used if the address is a word. If the 2 msb bits in the 
       34-bit address should be used, another mechanism to set it should be used. */
    content = address & 0xfffffff8ul;
    content |= ((uint32_t) (rdsize & 0x000f)) << 2;
    crc = RIOPACKET_Crc32(content, crc);
    packet->payload[2] = content;

    /* crc(15:0)|pad(15:0) */
    content = ((uint32_t) crc) << 16;
    packet->payload[3] = content;

    /* Set the size of the packet. */
    packet->size = 4;
  }
  else
  {
    /* The address and size field combination is not valid. */
    /* Cannot create a packet from these arguments, indicate this by setting the packet size to zero. */
    packet->size = 0;
  }
}


/**
 * \brief Get entries from an NREAD.
 *
 * \param[in] packet The packet to operate on.
 * \param[out] destId The destination deviceId in this packet.
 * \param[out] srcId The source deviceId in this packet.
 * \param[out] tid The transaction id in this packet.
 * \param[out] address The byte address into IO-space requested to be written.
 * \param[out] payloadSize The number of bytes requested to be read.
 *
 * This function returns the content of a packet as if it contained an NREAD.
 *
 * \note The address is a byte address.
 */
void RIOPACKET_getNread(RioPacket_t *packet, uint16_t *destId, uint16_t *srcId, uint8_t *tid, 
                        uint32_t *address, uint16_t *payloadSize)
{
  uint8_t rdsize;
  uint8_t wdptr;
  uint8_t offset = 0;
  uint16_t size = 0;


  rdsize = WRSIZE_GET(packet->payload);
  wdptr = WDPTR_GET(packet->payload);
  rdsizeToOffset(rdsize, wdptr, &offset, &size);

  *destId = DESTID_GET(packet->payload);
  *srcId = SRCID_GET(packet->payload);
  *tid = TID_GET(packet->payload);
  *address = ADDRESS_GET(packet->payload) | offset;
  *payloadSize = size;
}



/*******************************************************************************************
 * Logical message passing DOORBELL and MESSAGE functions.
 *******************************************************************************************/

/**
 * \brief Set a packet to contain a DOORBELL.
 *
 * \param[in] packet The packet to operate on.
 * \param[in] destId The deviceId to use as destination in the packet.
 * \param[in] srcId The deviceId to use as source in the packet.
 * \param[in] tid The transaction identifier to set in the packet.
 * \param[in] info The information to send with the doorbell.
 *
 * This function sets the content of a packet to a DOORBELL.
 */
void RIOPACKET_setDoorbell(RioPacket_t *packet, uint16_t destId, uint16_t srcId, uint8_t tid, 
                           uint16_t info)
{
  uint32_t content;
  uint16_t crc = 0xffffu;


  /* ackId(4:0)|0|vc|crf|prio(1:0)|tt(1:0)|ftype(3:0)|destinationId(15:0) */
  /* ackId is set when the packet is transmitted. */
  content = 0x001a0000ul;
  content |= (uint32_t) destId;
  crc = RIOPACKET_Crc32(content, crc);
  packet->payload[0] = content;

  /* sourceId(15:0)|rsrv(7:0)|srcTID(7:0) */
  content = ((uint32_t) srcId) << 16;
  content |= (uint32_t) tid;
  crc = RIOPACKET_Crc32(content, crc);
  packet->payload[1] = content;

  /* infoMSB(7:0)|infoLSB(7:0)|crc(15:0) */
  content = ((uint32_t) info) << 16;
  crc = RIOPACKET_Crc16(info, crc);
  content |= crc;
  packet->payload[2] = content;

  /* Set the size of the packet. */
  packet->size = 3;
}


/**
 * \brief Get entries from a DOORBELL.
 *
 * \param[in] packet The packet to operate on.
 * \param[out] destId The destination deviceId in this packet.
 * \param[out] srcId The source deviceId in this packet.
 * \param[out] tid The transaction identifier in this packet.
 * \param[out] info The information field in this packet.
 *
 * This function returns the content of a packet as if it contained a DOORBELL.
 */
void RIOPACKET_getDoorbell(RioPacket_t *packet, uint16_t *destId, uint16_t *srcId, uint8_t *tid, 
                           uint16_t *info)
{
  *destId = DESTID_GET(packet->payload);
  *srcId = SRCID_GET(packet->payload);
  *tid = TID_GET(packet->payload);
  *info = INFO_GET(packet->payload);
}


/**
 * \brief Set a packet to contain a MESSAGE.
 *
 * \param[in] packet The packet to operate on.
 * \param[in] destId The deviceId to use as destination in the packet.
 * \param[in] srcId The deviceId to use as source in the packet.
 * \param[in] mailbox The mailbox to send the message to.
 * \param[in] payloadSize The number of bytes to place into the message.
 * \param[in] payload A pointer to the array of bytes to place into the message.
 *
 * This function sets the content of a packet to contain a MESSAGE.
 *
 * \note The mailbox argument maps to the packet fields as: 
 * {xmbox(3:0), letter(1:0), mbox(1:0)} which means that mailbox 0-15 can support
 * multipacket messages and 16-255 can handle only single packet messages.
 *
 * \note The payload size has to be larger than zero and less than 256.
 *
 * \note Only payloads of even double-words are supported by the protocol itself. Payload 
 * that is shorter will be padded.
 */
void RIOPACKET_setMessage(RioPacket_t *packet, uint16_t destId, uint16_t srcId, uint8_t mailbox, 
                          uint16_t payloadSize, uint8_t *payload)
{
  uint32_t content;


  /* Make sure that the message payload size is larger than zero. */
  if((payloadSize > 0) && (payloadSize <= 256))
  {
    /* The payload size is larger than zero. */

    /* ackId(4:0)|0|vc|crf|prio(1:0)|tt(1:0)|ftype(3:0)|destinationId(15:0) */
    /* ackId is set when the packet is transmitted. */
    content = 0x001b0000ul;
    content |= (uint32_t) destId;
    packet->payload[0] = content;
  
    /* sourceId(15:0)|msglen(3:0)|ssize(3:0)|letter(1:0)|mbox(1:0)|msgseg(3:0)/xmbox(3:0) */
    content = ((uint32_t) srcId) << 16;
    if(payloadSize <= 8u)
    {
      content |= 0x00000900ul;
    }
    else if(payloadSize <= 16u)
    {
      content |= 0x00000a00ul;
    }
    else if(payloadSize <= 32u)
    {
      content |= 0x00000b00ul;
    }
    else if(payloadSize <= 64u)
    {
      content |= 0x00000c00ul;
    }
    else if(payloadSize <= 128u)
    {
      content |= 0x00000d00ul;
    }
    else
    {
      content |= 0x00000e00ul;
    }
    content |= (((uint32_t) mailbox) & 0xful) << 4;
    content |= ((uint32_t) mailbox) >> 4;
    packet->payload[1] = content;

    /* Place data buffer into the payload of the packet and set the size. */
    packet->size = setPacketPayload(&(packet->payload[0]), 8, 0, payloadSize, payload);
  }
  else
  {
    /* The payload size is not allowed. */
    /* Unable to create the new packet. */
    packet->size = 0;
  }
}


/**
 * \brief Get entries from a MESSAGE.
 *
 * \param[in] packet The packet to operate on.
 * \param[out] destId The destination deviceId in this packet.
 * \param[out] srcId The source deviceId in this packet.
 * \param[out] mailbox The mailbox the message is received on.
 * \param[out] payloadSize The number of bytes in the payload.
 * \param[out] payload The payload of the packet.
 *
 * This function returns the content of a packet as if it contained a MESSAGE.
 *
 * \note The mailbox argument maps to the packet fields as: 
 * {xmbox(3:0), letter(1:0), mbox(1:0)} which means that mailbox 0-15 can support
 * multipacket messages and 16-255 can handle only single packet messages.
 *
 * \note Only payloads of even double-words are supported by the protocol itself so the 
 * returned payloadSize is always an even multiple of eight.
 */
void RIOPACKET_getMessage(RioPacket_t *packet, uint16_t *destId, uint16_t *srcId, uint8_t *mailbox, 
                          uint16_t *payloadSize, uint8_t *payload)
{
  *destId = DESTID_GET(packet->payload);
  *srcId = SRCID_GET(packet->payload);
  *mailbox = XMBOX_GET(packet->payload);
  *mailbox <<= 2;
  *mailbox |= LETTER_GET(packet->payload);
  *mailbox <<= 2;
  *mailbox |= MBOX_GET(packet->payload);
  *payloadSize = getPacketPayload(&(packet->payload[0]), 8, 0, (packet->size-3)*4, payload);
}




/*******************************************************************************************
 * Logical I/O RESPONSE-DONE-PAYLOAD, RESPONSE-DONE, RESPONSE-RETRY and RESPONSE-ERROR 
 * functions.
 *******************************************************************************************/

/**
 * \brief Set a packet to contain a RESPONSE without payload.
 *
 * \param[in] packet The packet to operate on.
 * \param[in] destId The deviceId to use as destination in the packet.
 * \param[in] srcId The deviceId to use as source in the packet.
 * \param[in] tid The transaction id to send the response for.
 * \param[in] status The status to send in the packet.
 *
 * This function sets the content of a packet to contain a RESPONSE without payload.
 *
 * \note The tid field must be the same value as the packet contained that this is the 
 * response for.
 *
 * \note The status field should be either of the values RIOPACKET_RESPONSE_STATUS_XXXX.
 */
void RIOPACKET_setResponseNoPayload(RioPacket_t *packet, 
                                    uint16_t destId, uint16_t srcId, 
                                    uint8_t tid, uint8_t status)
{
  uint32_t content;
  uint16_t crc = 0xffffu;


  /* ackId(4:0)|0|vc|crf|prio(1:0)|tt(1:0)|ftype(3:0)|destinationId(15:0) */
  /* ackId is set when the packet is transmitted. */
  content = 0x001d0000ul;
  content |= (uint32_t) destId;
  crc = RIOPACKET_Crc32(content, crc);
  packet->payload[0] = content;

  /* sourceId(15:0)|transaction(3:0)|status(3:0)|targetTID(7:0) */
  content = ((uint32_t) srcId) << 16;
  content |= ((uint32_t) RIOPACKET_TRANSACTION_RESPONSE_NO_PAYLOAD) << 12;
  content |= ((uint32_t) (status & 0xf)) << 8;
  content |= (uint32_t) tid;
  crc = RIOPACKET_Crc32(content, crc);
  packet->payload[1] = content;

  /* crc(15:0)|pad(15:0) */
  content = ((uint32_t) crc) << 16;
  packet->payload[2] = content;

  /* Set the size of the packet. */
  packet->size = 3;
}


/**
 * \brief Get entries from a RESPONSE without payload.
 *
 * \param[in] packet The packet to operate on.
 * \param[out] destId The destination deviceId in this packet.
 * \param[out] srcId The source deviceId in this packet.
 * \param[out] tid The transaction identifier in this packet.
 * \param[out] status The status in this packet.
 *
 * This function returns the content of a packet as if it contained a RESPONSE.
 */
void RIOPACKET_getResponseNoPayload(RioPacket_t *packet, 
                                    uint16_t *destId, uint16_t *srcId, 
                                    uint8_t *tid, uint8_t *status)
{
  *destId = DESTID_GET(packet->payload);
  *srcId = SRCID_GET(packet->payload);
  *tid = TID_GET(packet->payload);
  *status = STATUS_GET(packet->payload);
}



/**
 * \brief Set a packet to contain a RESPONSE also containing payload.
 *
 * \param[in] packet The packet to operate on.
 * \param[in] destId The deviceId to use as destination in the packet.
 * \param[in] srcId The deviceId to use as source in the packet.
 * \param[in] tid The transaction id to send the response for.
 * \param[in] offset The offset into the payload to start to write the input payload to.
 * \param[in] payloadSize The size of the payload to return in the reply.
 * \param[in] payload The payload to return in the reply.
 *
 * This function sets the content of a packet to contain a RESPOSE with payload.
 *
 * \note The tid field must be the same value as the packet contained that this is the 
 * response for.
 *
 * \note The offset field can be used to offset the payload in a response to, for 
 * example, an NREAD.
 *
 * \note The payloadSize must match the size of the packet that this is the
 * response for.
 */
void RIOPACKET_setResponseWithPayload(RioPacket_t *packet, 
                                      uint16_t destId, uint16_t srcId, 
                                      uint8_t tid, uint8_t offset, 
                                      uint16_t payloadSize, uint8_t *payload)
{
  uint32_t content;


  /* ackId(4:0)|0|vc|crf|prio(1:0)|tt(1:0)|ftype(3:0)|destinationId(15:0) */
  /* ackId is set when the packet is transmitted. */
  content = 0x001d0000ul;
  content |= (uint32_t) destId;
  packet->payload[0] = content;
    
  /* sourceId(15:0)|transaction(3:0)|status(3:0)|targetTID(7:0) */
  /* status=DONE is 0. */
  content = ((uint32_t) srcId) << 16;
  content |= ((uint32_t) RIOPACKET_TRANSACTION_RESPONSE_WITH_PAYLOAD) << 12;
  content |= (uint32_t) tid;
  packet->payload[1] = content;

  packet->size = setPacketPayload(&(packet->payload[0]), 8, offset & 0x7, payloadSize, payload);
}

/**
 * \brief Get entries from a RESPONSE containing payload.
 *
 * \param[in] packet The packet to operate on.
 * \param[out] destId The destination deviceId in this packet.
 * \param[out] srcId The source deviceId in this packet.
 * \param[out] tid The transaction identifier in this packet.
 * \param[in] offset The offset into the payload to start reading from.
 * \param[out] payloadSize The number of bytes in the payload.
 * \param[out] payload The payload of the packet.
 *
 * This function returns the content of a packet as if it contained a RESPONSE with payload.
 *
 * \note The offset field can be used to read the payload in a response to, for 
 * example, an NREAD.
 */
void RIOPACKET_getResponseWithPayload(RioPacket_t *packet, 
                                      uint16_t *destId, uint16_t *srcId, 
                                      uint8_t *tid, uint8_t offset, 
                                      uint16_t *payloadSize, uint8_t *payload)
{
  *destId = DESTID_GET(packet->payload);
  *srcId = SRCID_GET(packet->payload);
  *tid = TID_GET(packet->payload);
  *payloadSize = getPacketPayload(&(packet->payload[0]), 8, offset & 0x7, (packet->size-3)*4, payload);
}



/**
 * \brief Set a packet to contains a RESPONSE to a message.
 *
 * \param[in] packet The packet to operate on.
 * \param[in] destId The deviceId to use as destination in the packet.
 * \param[in] srcId The deviceId to use as source in the packet.
 * \param[in] mailbox The mailbox to send the message to.
 * \param[in] status The status to send in the packet.
 *
 * This function is used to send a response indicating a successfull
 * completion in reply to a previously received packet.
 *
 * \note The mailbox field should contain the same value as the packet that this is the 
 * response to.
 *
 * \note The status field should be either of the values RIOPACKET_RESPONSE_STATUS_XXXX.
 */
void RIOPACKET_setResponseMessage(RioPacket_t *packet, 
                                  uint16_t destId, uint16_t srcId, 
                                  uint8_t mailbox, uint8_t status)
{
  uint32_t content;
  uint16_t crc = 0xffffu;


  /* ackId(4:0)|0|vc|crf|prio(1:0)|tt(1:0)|ftype(3:0)|destinationId(15:0) */
  /* ackId is set when the packet is transmitted. */
  content = 0x001d0000ul;
  content |= (uint32_t) destId;
  crc = RIOPACKET_Crc32(content, crc);
  packet->payload[0] = content;

  /* sourceId(15:0)|transaction(3:0)|status(3:0)|letter(1:0|mbox(1:0)|msgseg(3:0) */
  content = ((uint32_t) srcId) << 16;
  content |= ((uint32_t) RIOPACKET_TRANSACTION_RESPONSE_MESSAGE_RESPONSE) << 12;
  content |= ((uint32_t) (status & 0xf)) << 8;
  content |= ((uint32_t) (mailbox & 0xf)) << 4;
  content |= ((uint32_t) mailbox) >> 4;
  crc = RIOPACKET_Crc32(content, crc);
  packet->payload[1] = content;

  /* crc(15:0)|pad(15:0) */
  content = ((uint32_t) crc) << 16;
  packet->payload[2] = content;

  /* Set the size of the packet. */
  packet->size = 3;
}

/**
 * \brief Get entries from a RESPONSE to a message.
 *
 * \param[in] packet The packet to operate on.
 * \param[out] destId The destination deviceId in this packet.
 * \param[out] srcId The source deviceId in this packet.
 * \param[out] mailbox The mailbox the response should be sent to.
 * \param[out] status The status in the packet.
 *
 * This function returns the content of a packet as if it contained a RESPONSE to a message.
 */
void RIOPACKET_getResponseMessage(RioPacket_t *packet, 
                                  uint16_t *destId, uint16_t *srcId, 
                                  uint8_t *mailbox, uint8_t *status)
{
  *destId = DESTID_GET(packet->payload);
  *srcId = SRCID_GET(packet->payload);
  *mailbox = XMBOX_GET(packet->payload);
  *mailbox <<= 2;
  *mailbox |= LETTER_GET(packet->payload);
  *mailbox <<= 2;
  *mailbox |= MBOX_GET(packet->payload);
  *status = STATUS_GET(packet->payload);
}


/**
 * \brief Calculate a new CRC16 value.
 *
 * \param[in] data The new data (16-bit) to update the current crc value with.
 * \param[in] crc The old crc value that should be updated.
 * \returns The new crc value based on the input arguments.
 *
 * This function calculates a new crc value using the generator polynom 
 * P(X)=x16+x12+x5+1. It is defined in RapidIO 3.0 part6 chapter 2.4.2.
 */
uint16_t RIOPACKET_Crc16(const uint16_t data, const uint16_t crc)
{
  static const uint16_t crcTable[] = {
    0x0000u, 0x1021u, 0x2042u, 0x3063u, 0x4084u, 0x50a5u, 0x60c6u, 0x70e7u,
    0x8108u, 0x9129u, 0xa14au, 0xb16bu, 0xc18cu, 0xd1adu, 0xe1ceu, 0xf1efu,
    0x1231u, 0x0210u, 0x3273u, 0x2252u, 0x52b5u, 0x4294u, 0x72f7u, 0x62d6u,
    0x9339u, 0x8318u, 0xb37bu, 0xa35au, 0xd3bdu, 0xc39cu, 0xf3ffu, 0xe3deu,
    0x2462u, 0x3443u, 0x0420u, 0x1401u, 0x64e6u, 0x74c7u, 0x44a4u, 0x5485u,
    0xa56au, 0xb54bu, 0x8528u, 0x9509u, 0xe5eeu, 0xf5cfu, 0xc5acu, 0xd58du,
    0x3653u, 0x2672u, 0x1611u, 0x0630u, 0x76d7u, 0x66f6u, 0x5695u, 0x46b4u,
    0xb75bu, 0xa77au, 0x9719u, 0x8738u, 0xf7dfu, 0xe7feu, 0xd79du, 0xc7bcu,
    0x48c4u, 0x58e5u, 0x6886u, 0x78a7u, 0x0840u, 0x1861u, 0x2802u, 0x3823u,
    0xc9ccu, 0xd9edu, 0xe98eu, 0xf9afu, 0x8948u, 0x9969u, 0xa90au, 0xb92bu,
    0x5af5u, 0x4ad4u, 0x7ab7u, 0x6a96u, 0x1a71u, 0x0a50u, 0x3a33u, 0x2a12u,
    0xdbfdu, 0xcbdcu, 0xfbbfu, 0xeb9eu, 0x9b79u, 0x8b58u, 0xbb3bu, 0xab1au,
    0x6ca6u, 0x7c87u, 0x4ce4u, 0x5cc5u, 0x2c22u, 0x3c03u, 0x0c60u, 0x1c41u,
    0xedaeu, 0xfd8fu, 0xcdecu, 0xddcdu, 0xad2au, 0xbd0bu, 0x8d68u, 0x9d49u,
    0x7e97u, 0x6eb6u, 0x5ed5u, 0x4ef4u, 0x3e13u, 0x2e32u, 0x1e51u, 0x0e70u,
    0xff9fu, 0xefbeu, 0xdfddu, 0xcffcu, 0xbf1bu, 0xaf3au, 0x9f59u, 0x8f78u,
    0x9188u, 0x81a9u, 0xb1cau, 0xa1ebu, 0xd10cu, 0xc12du, 0xf14eu, 0xe16fu,
    0x1080u, 0x00a1u, 0x30c2u, 0x20e3u, 0x5004u, 0x4025u, 0x7046u, 0x6067u,
    0x83b9u, 0x9398u, 0xa3fbu, 0xb3dau, 0xc33du, 0xd31cu, 0xe37fu, 0xf35eu,
    0x02b1u, 0x1290u, 0x22f3u, 0x32d2u, 0x4235u, 0x5214u, 0x6277u, 0x7256u,
    0xb5eau, 0xa5cbu, 0x95a8u, 0x8589u, 0xf56eu, 0xe54fu, 0xd52cu, 0xc50du,
    0x34e2u, 0x24c3u, 0x14a0u, 0x0481u, 0x7466u, 0x6447u, 0x5424u, 0x4405u,
    0xa7dbu, 0xb7fau, 0x8799u, 0x97b8u, 0xe75fu, 0xf77eu, 0xc71du, 0xd73cu,
    0x26d3u, 0x36f2u, 0x0691u, 0x16b0u, 0x6657u, 0x7676u, 0x4615u, 0x5634u,
    0xd94cu, 0xc96du, 0xf90eu, 0xe92fu, 0x99c8u, 0x89e9u, 0xb98au, 0xa9abu,
    0x5844u, 0x4865u, 0x7806u, 0x6827u, 0x18c0u, 0x08e1u, 0x3882u, 0x28a3u,
    0xcb7du, 0xdb5cu, 0xeb3fu, 0xfb1eu, 0x8bf9u, 0x9bd8u, 0xabbbu, 0xbb9au,
    0x4a75u, 0x5a54u, 0x6a37u, 0x7a16u, 0x0af1u, 0x1ad0u, 0x2ab3u, 0x3a92u,
    0xfd2eu, 0xed0fu, 0xdd6cu, 0xcd4du, 0xbdaau, 0xad8bu, 0x9de8u, 0x8dc9u,
    0x7c26u, 0x6c07u, 0x5c64u, 0x4c45u, 0x3ca2u, 0x2c83u, 0x1ce0u, 0x0cc1u,
    0xef1fu, 0xff3eu, 0xcf5du, 0xdf7cu, 0xaf9bu, 0xbfbau, 0x8fd9u, 0x9ff8u,
    0x6e17u, 0x7e36u, 0x4e55u, 0x5e74u, 0x2e93u, 0x3eb2u, 0x0ed1u, 0x1ef0u
  };

  uint16_t result;
  uint8_t index;
  
  result = crc;
  index = (uint8_t) ((data >> 8) ^ (result >> 8));
  result = (uint16_t) (crcTable[index] ^ (uint16_t)(result << 8));
  index = (uint8_t) ((data) ^ (result >> 8));
  result = (uint16_t) (crcTable[index] ^ (uint16_t)(result << 8));

  return result;
}


/**
 * \brief Calculate a new CRC16 value.
 *
 * \param[in] data The new data (32-bit) to update the current crc value with.
 * \param[in] crc The old crc value that should be updated.
 * \returns The new crc value based on the input arguments.
 *
 * This function calculates a new crc value using the generator polynom 
 * P(X)=x16+x12+x5+1. It is defined in RapidIO 3.0 part6 chapter 2.4.2.
 */
uint16_t RIOPACKET_Crc32(const uint32_t data, uint16_t crc)
{
  crc = RIOPACKET_Crc16((uint16_t) (data >> 16), crc);
  crc = RIOPACKET_Crc16((uint16_t) (data), crc);
  return crc;
}


/**
 * \brief Get the maximum size of an NWRITE payload.
 *
 * \param[in] address The starting address to write to in the NWRITE.
 * \param[in] size The total size of the access to NWRITE.
 * \returns The maximum number of bytes that are allowed to send in a single 
 * NWRITE packet that conforms to the RapidIO standard.
 *
 * This function calculates the maximum sized NWRITE packet payload that are 
 * possible to send without breaking the limitations in the RapidIO specification. 
 * It is intended to be called repeatedly.
 *
 * Example: An area with address=0x00007 and size=258 needs to be written.
 *          Call RIOPACKET_getWritePacketSize(0x00007, 258)->1.
 *          Send an NWRITE to address=0x00007 and size=1.
 *          Update the address and size with the returned value->
 *          address+=1->address=0x00008 size-=1->size=257.
 *          Call RIOPACKET_getWritePacketSize(0x00008, 257)->256.
 *          Send an NWRITE to address=0x00008 and size=256.
 *          Update the address and size with the returned value->
 *          address+=256->address=0x00108 size-=256->size=1.
 *          Call RIOPACKET_getWritePacketSize(0x00108, 1)->1.
 *          Send an NWRITE to address=0x00108 and size=1.
 *          Update the address and size with the returned value->
 *          address+=1->address=0x00109 size-=1->size=0.
 *          All the data has been written.
 *
 */
uint32_t RIOPACKET_getWritePacketSize(uint32_t address, uint32_t size)
{
  uint32_t returnValue;


  switch(address%8)
  {
    case 0:
      if(size >= 256)
      {
        returnValue = 256;
      }
      else if(size >= 8)
      {
        returnValue = size - (size % 8);
      }
      else
      {
        returnValue = size;
      }
      break;
    case 1:
      if(size >= 7)
      {
        returnValue = 7;
      }
      else
      {
        returnValue = 1;
      }
      break;
    case 2:
      if(size >= 6)
      {
        returnValue = 6;
      }
      else if(size >= 2)
      {
        returnValue = 2;
      }
      else
      {
        returnValue = 1;
      }
      break;
    case 3:
      if(size >= 5)
      {
        returnValue = 5;
      }
      else
      {
        returnValue = 1;
      }
      break;
    case 4:
      if(size >= 4)
      {
        returnValue = 4;
      }
      else if(size >= 2)
      {
        returnValue = 2;
      }
      else
      {
        returnValue = 1;
      }
      break;
    case 5:
      if(size >= 3)
      {
        returnValue = 3;
      }
      else
      {
        returnValue = 1;
      }
      break;
    case 6:
      if(size >= 2)
      {
        returnValue = 2;
      }
      else
      {
        returnValue = 1;
      }
      break;
    default:
      returnValue = 1;
      break;
  }
  
  return returnValue;
}


/**
 * \brief Get the maximum size of an NREAD payload.
 *
 * \param[in] address The starting address to read from in the NREAD.
 * \param[in] size The total size of the access to NREAD.
 * \returns The maximum number of bytes that are allowed to send in a single 
 * NREAD packet that conforms to the RapidIO standard.
 *
 * This function calculates the maximum sized NREAD packet payload that are 
 * possible to send without breaking the limitations in the RapidIO specification. 
 * It is intended to be called repeatedly.
 *
 * Example: An area with address=0x00007 and size=258 needs to be read.
 *          Call RIOPACKET_getReadPacketSize(0x00007, 258)->1.
 *          Send an NREAD to address=0x00007 and size=1.
 *          Update the address and size with the returned value->
 *          address+=1->address=0x00008 size-=1->size=257.
 *          Call RIOPACKET_getReadPacketSize(0x00008, 257)->256.
 *          Send an NREAD to address=0x00008 and size=256.
 *          Update the address and size with the returned value->
 *          address+=256->address=0x00108 size-=256->size=1.
 *          Call RIOPACKET_getReadPacketSize(0x00108, 1)->1.
 *          Send an NREAD to address=0x00108 and size=1.
 *          Update the address and size with the returned value->
 *          address+=1->address=0x00109 size-=1->size=0.
 *          All the data has been read.
 *
 */
uint32_t RIOPACKET_getReadPacketSize(uint32_t address, uint32_t size)
{
  uint32_t returnValue;


  switch(address%8)
  {
    case 0:
      if(size >= 256)
      {
        returnValue = 256;
      }
      else if(size >= 224)
      {
        returnValue = 224;
      }
      else if(size >= 192)
      {
        returnValue = 192;
      }
      else if(size >= 160)
      {
        returnValue = 160;
      }
      else if(size >= 128)
      {
        returnValue = 128;
      }
      else if(size >= 96)
      {
        returnValue = 96;
      }
      else if(size >= 64)
      {
        returnValue = 64;
      }
      else if(size >= 32)
      {
        returnValue = 32;
      }
      else if(size >= 16)
      {
        returnValue = 16;
      }
      else if(size >= 8)
      {
        returnValue = 8;
      }
      else 
      {
        returnValue = size;
      }
      break;
    case 1:
      if(size >= 7)
      {
        returnValue = 7;
      }
      else
      {
        returnValue = 1;
      }
      break;
    case 2:
      if(size >= 6)
      {
        returnValue = 6;
      }
      else if(size >= 2)
      {
        returnValue = 2;
      }
      else
      {
        returnValue = 1;
      }
      break;
    case 3:
      if(size >= 5)
      {
        returnValue = 5;
      }
      else
      {
        returnValue = 1;
      }
      break;
    case 4:
      if(size >= 4)
      {
        returnValue = 4;
      }
      else if(size >= 2)
      {
        returnValue = 2;
      }
      else
      {
        returnValue = 1;
      }
      break;
    case 5:
      if(size >= 3)
      {
        returnValue = 3;
      }
      else
      {
        returnValue = 1;
      }
      break;
    case 6:
      if(size >= 2)
      {
        returnValue = 2;
      }
      else
      {
        returnValue = 1;
      }
      break;
    default:
      returnValue = 1;
      break;
  }
  
  return returnValue;
}



/*******************************************************************************
 * Locally used helper functions.
 *******************************************************************************/

static uint16_t getPacketPayload(uint32_t *packet, const uint16_t payloadOffset, const uint16_t dataOffset, 
                                 const uint16_t dataSize, uint8_t *data)
{
  uint32_t content = 0;
  uint16_t packetIndex;
  uint16_t payloadIndex;
  uint16_t dataIndex;


  /* Move payload bytes from RapidIO packet into a user buffer. */
  /* Long packets contain a CRC in byte 80-81, this is removed when the buffer 
     is copied. */
  packetIndex = payloadOffset;
  payloadIndex = 0;
  dataIndex = 0;
  while(dataIndex < dataSize)
  {
    /* Check if a new word should be read from the inbound queue. */
    if((packetIndex & 0x3) == 0)
    {
      /* Get a new word. */
      content = packet[packetIndex>>2];
    }
    else
    {
      /* Update the current word. Remove the MSB, it has already be moved 
         to the user buffer. */
      content <<= 8;
    }

    /* Check if the current byte is CRC. */
    if((packetIndex != 80) && (packetIndex != 81) && (payloadIndex >= dataOffset))
    {
      /* Not CRC. */
      /* Move the byte to the user buffer. */
      data[dataIndex++] = (content >> 24);
    }

    /* Increment to the next position in the packet. */
    packetIndex++;
    payloadIndex++;
  }

  return dataIndex;
}


static uint16_t setPacketPayload(uint32_t *packet, const uint16_t payloadOffset, const uint16_t dataOffset, 
                                 const uint16_t dataSize, const uint8_t *data)
{
  uint16_t crc = 0xffffu;
  uint32_t content = 0;
  uint16_t packetIndex;
  uint16_t payloadIndex;
  uint16_t dataIndex;


  /***************************************************
   * Calculate the CRC for the packet header.
   ***************************************************/
  for(packetIndex = 0; packetIndex < payloadOffset; packetIndex+=4)
  {
    crc = RIOPACKET_Crc32(packet[packetIndex>>2], crc);
  }

  /***************************************************
   * Pad the data before the actual data is written.
   ***************************************************/
  payloadIndex = 0;
  while(payloadIndex < dataOffset)
  {
    content <<= 8;

    if((packetIndex & 0x3) == 3)
    {
      crc = RIOPACKET_Crc32(content, crc);
      packet[packetIndex>>2] = content;
    }

    payloadIndex++;
    packetIndex++;
  }

  /***************************************************
   * Write content and any embedded CRC.
   ***************************************************/
  dataIndex = 0;
  while(dataIndex < dataSize)
  {
    content <<= 8;

    /* Check if CRC or content should be entered into the packet. */
    if(packetIndex == 80)
    {
      /* CRC MSB. */
      content |= crc >> 8;
    }
    else if(packetIndex == 81)
    {
      /* CRC LSB. */
      content |= crc & 0xff;
    }
    else
    {
      /* Data content. */
      content |= data[dataIndex++];
      payloadIndex++;
    }

    if((packetIndex & 0x3) == 3)
    {
      crc = RIOPACKET_Crc32(content, crc);
      packet[packetIndex>>2] = content;
    }

    packetIndex++;
  }

  /***************************************************
   * Pad the data to an even double word.
   ***************************************************/
  while((payloadIndex & 0x7) != 0)
  {
    content <<= 8;

    if((packetIndex & 0x3) == 3)
    {
      crc = RIOPACKET_Crc32(content, crc);
      packet[packetIndex>>2] = content;
    }

    packetIndex++;
    payloadIndex++;
  }

  /***************************************************
   * Write the CRC into the packet.
   ***************************************************/
  if((packetIndex & 0x3) == 0)
  {
    /* crc(15:0)|pad(15:0) */
    content = ((uint32_t) crc) << 16;
  }
  else
  {
    /* double-wordN-LSB|crc(15:0) */
    content &= 0x0000ffff;
    crc = RIOPACKET_Crc16(content, crc);
    content <<= 16;
    content |= crc;
  }
  packet[packetIndex>>2] = content;

  return (packetIndex>>2)+1;
}



/* \note See the RapidIO standard part1 table 4-4 for details about 
 * {address, size}->{wdptr, wrsize} mapping.
 */
static uint16_t rdsizeGet(const uint32_t address, const uint16_t size)
{
  uint8_t wdptr;
  uint8_t rdsize;


  switch(size/8)
  {
    case 0:
      /**************************************************************
       * Sub double-word access.
       **************************************************************/
      switch(size%8)
      {
        case 0:
          /* Not supported by protocol. */
          wdptr = 0xff;
          rdsize = 0xff;
          break;
        case 1:
          /* Reading one byte. */
          /* Any address is allowed. */
          wdptr = (address >> 2) & 0x1;
          rdsize = address & 0x3;
          break;
        case 2:
          /* Reading two bytes. */
          /* Address 0, 2, 4, 6 are valid. */
          if((address & 0x1) == 0)
          {
            wdptr = (address >> 2) & 0x1;
            rdsize = (address & 0x7) | 0x4;
          }
          else
          {
            /* Not supported by protocol. */
            wdptr = 0xff;
            rdsize = 0xff;
          }
          break;
        case 3:
          /* Reading 3 bytes. */
          /* Address 0 and 5 are valid. */
          if(((address & 0x7) == 0) ||
             ((address & 0x7) == 5))
          {
            wdptr = (address >> 2) & 0x1;
            rdsize = 0x5ul;
          }
          else
          {
            /* Not supported by protocol. */
            wdptr = 0xff;
            rdsize = 0xff;
          }
          break;
        case 4:
          /* Reading 4 bytes. */
          /* Address 0 and 4 are valid. */
          if(((address & 0x7) == 0) ||
             ((address & 0x7) == 4))
          {
            wdptr = (address >> 2) & 0x1;
            rdsize = 0x8ul;
          }
          else
          {
            /* Not supported by protocol. */
            wdptr = 0xff;
            rdsize = 0xff;
          }
          break;
        case 5:
          /* Reading 5 bytes. */
          /* Address 0 and 3 are valid. */
          if(((address & 0x7) == 0) ||
             ((address & 0x7) == 3))
          {
            wdptr = (address >> 1) & 0x1;
            rdsize = 0x7ul;
          }
          else
          {
            /* Not supported by protocol. */
            wdptr = 0xff;
            rdsize = 0xff;
          }
          break;
        case 6:
          /* Reading 6 bytes. */
          /* Addresses 0 and 2 are valid. */
          if(((address & 0x7) == 0) ||
             ((address & 0x7) == 2))
          {
            wdptr = (address >> 1) & 0x1;
            rdsize = 0x9ul;
          }
          else
          {
            /* Not supported by protocol. */
            wdptr = 0xff;
            rdsize = 0xff;
          }
          break;
        default:
          /* Reading 7 bytes. */
          /* Addresses 0 and 1 are valid. */
          if(((address & 0x7) == 0) ||
             ((address & 0x7) == 1))
          {
            wdptr = address & 0x1;
            rdsize = 0xaul;
          }
          else
          {
            /* Not supported by protocol. */
            wdptr = 0xff;
            rdsize = 0xff;
          }
          break;
      }
      break;
    case 1:
      /* Reading 8 bytes. */
      /* Only even double-word address are valid. */
      if((address % 8) == 0)
      {
        wdptr = 0;
        rdsize = 0xbul;
      }
      else
      {
        /* Not supported by protocol. */
        wdptr = 0xff;
        rdsize = 0xff;
      }
      break;
    case 2:
      /* Reading 16 bytes max. */
      /* Only even double-word address are valid. */
      if((address % 8) == 0)
      {
        wdptr = 1;
        rdsize = 0xbul;
      }
      else
      {
        /* Not supported by protocol. */
        wdptr = 0xff;
        rdsize = 0xff;
      }
      break;
    case 3:
      /* Not supported by protocol. */
      wdptr = 0xff;
      rdsize = 0xff;
      break;
    case 4:
      /* Reading 32 bytes max. */
      /* Only even double-word address are valid. */
      if((address & 0x7) == 0)
      {
        wdptr = 0;
        rdsize = 0xcul;
      }
      else
      {
        /* Not supported by protocol. */
        wdptr = 0xff;
        rdsize = 0xff;
      }
      break;
    case 5:
    case 6:
    case 7:
      /* Not supported by protocol. */
      wdptr = 0xff;
      rdsize = 0xff;
      break;
    case 8:
      /* Reading 64 bytes max. */
      /* Only even double-word address are valid. */
      if((address & 0x7) == 0)
      {
        wdptr = 1;
        rdsize = 0xcul;
      }
      else
      {
        /* Not supported by protocol. */
        wdptr = 0xff;
        rdsize = 0xff;
      }
      break;
    case 9:
    case 10:
    case 11:
      /* Not supported by protocol. */
      wdptr = 0xff;
      rdsize = 0xff;
      break;
    case 12:
      /* Reading 96 bytes. */
      /* Only even double-word address are valid. */
      if((address & 0x7) == 0)
      {
        wdptr = 0;
        rdsize = 0xdul;
      }
      else
      {
        /* Not supported by protocol. */
        wdptr = 0xff;
        rdsize = 0xff;
      }
      break;
    case 13:
    case 14:
    case 15:
      /* Not supported by protocol. */
      wdptr = 0xff;
      rdsize = 0xff;
      break;
    case 16:
      /* Reading 128 bytes max. */
      /* Only even double-word address are valid. */
      if((address & 0x7) == 0)
      {
        wdptr = 1;
        rdsize = 0xdul;
      }
      else
      {
        /* Not supported by protocol. */
        wdptr = 0xff;
        rdsize = 0xff;
      }
      break;
    case 17:
    case 18:
    case 19:
      /* Not supported by protocol. */
      wdptr = 0xff;
      rdsize = 0xff;
      break;
    case 20:
      /* Reading 160 bytes. */
      /* Only even double-word address are valid. */
      if((address & 0x7) == 0)
      {
        wdptr = 0;
        rdsize = 0xeul;
      }
      else
      {
        /* Not supported by protocol. */
        wdptr = 0xff;
        rdsize = 0xff;
      }
      break;
    case 21:
    case 22:
    case 23:
      /* Not supported by protocol. */
      wdptr = 0xff;
      rdsize = 0xff;
      break;
    case 24:
      /* Reading 192 bytes. */
      /* Only even double-word address are valid. */
      if((address & 0x7) == 0)
      {
        wdptr = 1;
        rdsize = 0xeul;
      }
      else
      {
        /* Not supported by protocol. */
        wdptr = 0xff;
        rdsize = 0xff;
      }
      break;
    case 25:
    case 26:
    case 27:
      /* Not supported by protocol. */
      wdptr = 0xff;
      rdsize = 0xff;
      break;
    case 28:
      /* Reading 224 bytes. */
      /* Only even double-word address are valid. */
      if((address & 0x7) == 0)
      {
        wdptr = 0;
        rdsize = 0xful;
      }
      else
      {
        /* Not supported by protocol. */
        wdptr = 0xff;
        rdsize = 0xff;
      }
      break;
    case 29:
    case 30:
    case 31:
      /* Not supported by protocol. */
      wdptr = 0xff;
      rdsize = 0xff;
      break;
    case 32:
      /* Reading 256 bytes max. */
      /* Only even double-word address are valid. */
      if((address & 0x7) == 0)
      {
        wdptr = 1;
        rdsize = 0xful;
      }
      else
      {
        /* Not supported by protocol. */
        wdptr = 0xff;
        rdsize = 0xff;
      }
      break;
    default:
      /* Not supported by protocol. */
      wdptr = 0xff;
      rdsize = 0xff;
      break;
  }
  
  return ((((uint16_t) rdsize) << 8) | ((uint16_t) wdptr));
}


void rdsizeToOffset(uint8_t rdsize, uint8_t wdptr, uint8_t *offset, uint16_t *size)
{
  switch(rdsize)
  {
    case 0:
    case 1:
    case 2:
    case 3:
      *offset = wdptr << 2;
      *offset |= rdsize;
      *size = 1;
      break;
    case 4:
    case 6:
      *offset = wdptr << 2;
      *offset |= rdsize & 0x02;
      *size = 2;
      break;
    case 5:
      *offset = wdptr * 5;
      *size = 3;
      break;
    case 8:
      *offset = wdptr * 4;
      *size = 4;
      break;
    case 7:
      *offset = wdptr * 3;
      *size = 5;
      break;
    case 9:
      *offset = wdptr * 2;
      *size = 6;
      break;
    case 10:
      *offset = wdptr * 1;
      *size = 7;
      break;
    case 11:
      *offset = 0;
      *size = 8 + 8*wdptr;
      break;
    case 12:
      *offset = 0;
      *size = 32 + 32*wdptr;
      break;
    case 13:
      *offset = 0;
      *size = 96 + 32*wdptr;
      break; 
    case 14:
      *offset = 0;
      *size = 160 + 32*wdptr;
      break;
    case 15:
      *offset = 0;
      *size = 224 + 32*wdptr;
      break;
  }
}


static uint16_t wrsizeGet(const uint32_t address, const uint16_t size)
{
  uint8_t wdptr;
  uint8_t wrsize;


  switch(size/8)
  {
    case 0:
      /**************************************************************
       * Sub double-word access.
       **************************************************************/
      switch(size%8)
      {
        case 0:
          /* Not supported by protocol. */
          wdptr = 0xff;
          wrsize = 0xff;
          break;
        case 1:
          /* Writing one byte. */
          /* Any address is allowed. */
          wdptr = (address >> 2) & 0x1;
          wrsize = address & 0x3;
          break;
        case 2:
          /* Writing two bytes. */
          /* Address 0, 2, 4, 6 are valid. */
          if((address & 0x1) == 0)
          {
            wdptr = (address >> 2) & 0x1;
            wrsize = (address & 0x7) | 0x4;
          }
          else
          {
            /* Not supported by protocol. */
            wdptr = 0xff;
            wrsize = 0xff;
          }
          break;
        case 3:
          /* Writing 3 bytes. */
          /* Address 0 and 5 are valid. */
          if(((address & 0x7) == 0) ||
             ((address & 0x7) == 5))
          {
            wdptr = (address >> 2) & 0x1;
            wrsize = 0x5ul;
          }
          else
          {
            /* Not supported by protocol. */
            wdptr = 0xff;
            wrsize = 0xff;
          }
          break;
        case 4:
          /* Writing 4 bytes. */
          /* Address 0 and 4 are valid. */
          if(((address & 0x7) == 0) ||
             ((address & 0x7) == 4))
          {
            wdptr = (address >> 2) & 0x1;
            wrsize = 0x8ul;
          }
          else
          {
            /* Not supported by protocol. */
            wdptr = 0xff;
            wrsize = 0xff;
          }
          break;
        case 5:
          /* Writing 5 bytes. */
          /* Address 0 and 3 are valid. */
          if(((address & 0x7) == 0) ||
             ((address & 0x7) == 3))
          {
            wdptr = (address >> 1) & 0x1;
            wrsize = 0x7ul;
          }
          else
          {
            /* Not supported by protocol. */
            wdptr = 0xff;
            wrsize = 0xff;
          }
          break;
        case 6:
          /* Writing 6 bytes. */
          /* Addresses 0 and 2 are valid. */
          if(((address & 0x7) == 0) ||
             ((address & 0x7) == 2))
          {
            wdptr = (address >> 1) & 0x1;
            wrsize = 0x9ul;
          }
          else
          {
            /* Not supported by protocol. */
            wdptr = 0xff;
            wrsize = 0xff;
          }
          break;
        default:
          /* Writing 7 bytes. */
          /* Addresses 0 and 1 are valid. */
          if(((address & 0x7) == 0) ||
             ((address & 0x7) == 1))
          {
            wdptr = address & 0x1;
            wrsize = 0xaul;
          }
          else
          {
            /* Not supported by protocol. */
            wdptr = 0xff;
            wrsize = 0xff;
          }
          break;
      }
      break;
    case 1:
      /* Writing 8 bytes. */
      /* Only even double-word address are valid. */
      if((address % 8) == 0)
      {
        wdptr = 0;
        wrsize = 0xbul;
      }
      else
      {
        /* Not supported by protocol. */
        wdptr = 0xff;
        wrsize = 0xff;
      }
      break;
    case 2:
      /* Writing 16 bytes max. */
      /* Only even double-word address are valid. */
      if((address % 8) == 0)
      {
        wdptr = 1;
        wrsize = 0xbul;
      }
      else
      {
        /* Not supported by protocol. */
        wdptr = 0xff;
        wrsize = 0xff;
      }
      break;
    case 3:
    case 4:
      /* Writing 32 bytes max. */
      /* Only even double-word address are valid. */
      if((address & 0x7) == 0)
      {
        wdptr = 0;
        wrsize = 0xcul;
      }
      else
      {
        /* Not supported by protocol. */
        wdptr = 0xff;
        wrsize = 0xff;
      }
      break;
    case 5:
    case 6:
    case 7:
    case 8:
      /* Writing 64 bytes max. */
      /* Only even double-word address are valid. */
      if((address & 0x7) == 0)
      {
        wdptr = 1;
        wrsize = 0xcul;
      }
      else
      {
        /* Not supported by protocol. */
        wdptr = 0xff;
        wrsize = 0xff;
      }
      break;
    case 9:
    case 10:
    case 11:
    case 12:
    case 13:
    case 14:
    case 15:
    case 16:
      /* Writing 128 bytes max. */
      /* Only even double-word address are valid. */
      if((address & 0x7) == 0)
      {
        wdptr = 1;
        wrsize = 0xdul;
      }
      else
      {
        /* Not supported by protocol. */
        wdptr = 0xff;
        wrsize = 0xff;
      }
      break;
    case 17:
    case 18:
    case 19:
    case 20:
    case 21:
    case 22:
    case 23:
    case 24:
    case 25:
    case 26:
    case 27:
    case 28:
    case 29:
    case 30:
    case 31:
    case 32:
      /* Writing 256 bytes max. */
      /* Only even double-word address are valid. */
      if((address & 0x7) == 0)
      {
        wdptr = 1;
        wrsize = 0xful;
      }
      else
      {
        /* Not supported by protocol. */
        wdptr = 0xff;
        wrsize = 0xff;
      }
      break;
    default:
      /* Not supported by protocol. */
      wdptr = 0xff;
      wrsize = 0xff;
      break;
  }
  
  return ((((uint16_t) wrsize) << 8) | ((uint16_t) wdptr));
}


void wrsizeToOffset(uint8_t wrsize, uint8_t wdptr, uint8_t *offset, uint16_t *size)
{
  switch(wrsize)
  {
    case 0:
    case 1:
    case 2:
    case 3:
      *offset = wdptr << 2;
      *offset |= wrsize;
      *size = 1;
      break;
    case 4:
    case 6:
      *offset = wdptr << 2;
      *offset |= wrsize & 0x02;
      *size = 2;
      break;
    case 5:
      *offset = wdptr * 5;
      *size = 3;
      break;
    case 8:
      *offset = wdptr * 4;
      *size = 4;
      break;
    case 7:
      *offset = wdptr * 3;
      *size = 5;
      break;
    case 9:
      *offset = wdptr * 2;
      *size = 6;
      break;
    case 10:
      *offset = wdptr * 1;
      *size = 7;
      break;
    case 11:
      *offset = 0;
      *size = 8 + 8*wdptr;
      break;
    case 12:
      *offset = 0;
      *size = 32 + 32*wdptr;
      break;
    case 13:
      *offset = 0;
      *size = 128*wdptr;
      break;
    case 14:
      *offset = 0;
      *size = 0;
      break;
    case 15:
      *offset = 0;
      *size = 256*wdptr;
      break;
  }
}

/*************************** end of file **************************************/
