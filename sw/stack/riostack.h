/*******************************************************************************
 * 
 * RapidIO IP Library Core
 * 
 * This file is part of the RapidIO IP library project
 * http://www.opencores.org/cores/rio/
 * 
 * Description:
 * This file contains the API of the riostack.c module.
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
 * \file riostack.h
 */

#ifndef _RIOSTACK_H
#define _RIOSTACK_H

/*******************************************************************************
 * Includes
 *******************************************************************************/

#include "rioconfig.h"
#include "riopacket.h"


/*******************************************************************************
 * Global typedefs
 *******************************************************************************/

/* The size of a maximum sized RapidIO packet when stored in memory. */
/* One entry contains a header with the used buffer size. */
#define RIOSTACK_BUFFER_SIZE (RIOPACKET_SIZE_MAX+1u)


/* Define the different types of RioSymbols. */
typedef enum 
  {
    RIOSTACK_SYMBOL_TYPE_IDLE, RIOSTACK_SYMBOL_TYPE_CONTROL, 
    RIOSTACK_SYMBOL_TYPE_DATA, RIOSTACK_SYMBOL_TYPE_ERROR
  } RioSymbolType_t;


/*
 * RapidIO symbol definition.
 * Idle symbol: Sent when nothing else to send. Does not use the data field.
 * Control symbol: Sent when starting, ending and acknowleding a packet. Data 
 * is right aligned, (Unused, C0, C1, C2) where C0 is transmitted/received first.
 * Data symbol: Sent to transfer packets. Uses the full data field, (D0, D1, 
 * D2, D3) where D0 is transmitted/received first.
 * Error symbols are created when a symbols could not be created and the stack 
 * should know about it.
 */
typedef struct
{
  RioSymbolType_t type;
  uint32_t data;
} RioSymbol_t;
 

/* Receiver states. */
typedef enum 
  {
    RX_STATE_UNINITIALIZED, RX_STATE_PORT_INITIALIZED, RX_STATE_LINK_INITIALIZED,
    RX_STATE_INPUT_RETRY_STOPPED, RX_STATE_INPUT_ERROR_STOPPED
  } RioReceiverState_t;


/* Transmitter states. */
typedef enum 
  {
    TX_STATE_UNINITIALIZED, TX_STATE_PORT_INITIALIZED, TX_STATE_LINK_INITIALIZED,
    TX_STATE_SEND_PACKET_RETRY, TX_STATE_SEND_PACKET_NOT_ACCEPTED, TX_STATE_SEND_LINK_RESPONSE, 
    TX_STATE_OUTPUT_RETRY_STOPPED, TX_STATE_OUTPUT_ERROR_STOPPED
  } RioTransmitterState_t;


/* Queue definition. */
typedef struct 
{
  uint8_t size;
  uint8_t available;
  uint8_t windowSize;
  uint8_t windowIndex;
  uint8_t frontIndex;
  uint8_t backIndex;
  uint32_t *buffer_p;
} Queue_t;



/* Define the structure to keep all the RapidIO stack variables. */
typedef struct
{
  /* Receiver variables. */
  RioReceiverState_t rxState;
  uint8_t rxCounter;
  uint16_t rxCrc;
  uint8_t rxStatusReceived;
  uint8_t rxAckId;
  uint8_t rxAckIdAcked;
  uint8_t rxErrorCause;
  Queue_t rxQueue;

  /* Transmitter variables. */
  RioTransmitterState_t txState;
  uint8_t txCounter;
  uint16_t txStatusCounter;
  uint8_t txFrameState;
  uint32_t txFrameTimeout[32];
  uint8_t txAckId;
  uint8_t txAckIdWindow;
  uint8_t txBufferStatus;
  Queue_t txQueue;

  /* Common protocol stack variables. */
  uint32_t portTime;
  uint32_t portTimeout;

  /** The number of successfully received packets. */
  uint32_t statusInboundPacketComplete;

  /** The number of retried received packets. 
      This will happen if the receiver does not have resources available when an inbound packet is received. */
  uint32_t statusInboundPacketRetry;

  /** The number of received erronous control symbols. 
      This may happen if the inbound link has a high bit-error-rate. */
  uint32_t statusInboundErrorControlCrc;

  /** The number of received packets with an unexpected ackId. 
      This may happen if the inbound link has a high bit-error-rate. */
  uint32_t statusInboundErrorPacketAckId;

  /** The number of received packets with a checksum error. 
      This may happen if the inbound link has a high bit-error-rate. */
  uint32_t statusInboundErrorPacketCrc;

  /** The number of received symbols that contains an illegals character. 
      This may happen if the inbound link has a high bit-error-rate or if characters are missing in the 
      inbound character stream. */
  uint32_t statusInboundErrorIllegalCharacter;

  /** The number of general errors encountered at the receiver that does not fit into the other categories. 
      This happens if too short or too long packets are received. */
  uint32_t statusInboundErrorGeneral;

  /** The number of received packets that were discarded since they were unsupported by the stack. 
      This will happen if an inbound packet contains information that cannot be accessed using the function API 
      of the stack. */
  uint32_t statusInboundErrorPacketUnsupported;

  /** The number of successfully transmitted packets. */
  uint32_t statusOutboundPacketComplete;

  /** The maximum time between a completed outbound packet and the reception of its pcakcet-accepted control-symbol. */
  uint32_t statusOutboundLinkLatencyMax;

  /** The number of retried transmitted packets. 
      This will happen if the receiver at the link-partner does not have resources available when an outbound
      packet is received. */
  uint32_t statusOutboundPacketRetry;

  /** The number of outbound packets that has had its retransmission timer expired. 
      This happens if the latency of the system is too high or if a packet is corrupted due to a high 
      bit-error-rate on the outbound link. */
  uint32_t statusOutboundErrorTimeout;

  /** The number of packet-accepted that was received that contained an unexpected ackId. 
      This happens if the transmitter and the link-partner is out of synchronization, probably due 
      to a software error. */
  uint32_t statusOutboundErrorPacketAccepted;

  /** The number of packet-retry that was received that contained an unexpected ackId. 
      This happens if the transmitter and the link-partner is out of synchronization, probably due to
      a software error. */
  uint32_t statusOutboundErrorPacketRetry;

  /** The number of received link-requests. 
      This happens if the link-partner transmitter has found an error and need to resynchronize itself 
      to the receiver. */
  uint32_t statusPartnerLinkRequest;

  /** The number of received erronous control symbols at the link-partner receiver. 
      This may happen if the outbound link has a high bit-error-rate. */
  uint32_t statusPartnerErrorControlCrc;

  /** The number of received packets with an unexpected ackId at the link-partner receiver. 
      This may happen if the outbound link has a high bit-error-rate. */
  uint32_t statusPartnerErrorPacketAckId;

  /** The number of received packets with a checksum error at the link-partner receiver. 
      This may happen if the outbound link has a high bit-error-rate. */
  uint32_t statusPartnerErrorPacketCrc;

  /** The number of received symbols that contains an illegals character at the link-parter receiver. 
      This may happen if the outbound link has a high bit-error-rate or if characters are missing in the 
      outbound character stream. */
  uint32_t statusPartnerErrorIllegalCharacter;

  /** The number of general errors encountered at the receiver that does not fit into the other categories. 
      This happens depending on the link-partner implementation. */
  uint32_t statusPartnerErrorGeneral;

  /* Private user data. */
  void* private;
} RioStack_t;


/*******************************************************************************
 * Global function prototypes
 *******************************************************************************/

/**
 * \brief Open the RapidIO stack for operation.
 *
 * \param[in] stack Stack instance to operate on.
 * \param[in] private Pointer to an opaque data area containing private user data.
 * \param[in] rxPacketBufferSize Number of words to use as reception buffer. This 
 *            argument specifies the size of rxPacketBuffer.
 * \param[in] rxPacketBuffer Pointer to buffer to store inbound packets in.
 * \param[in] txPacketBufferSize Number of words to use as transmission buffer. This 
 *            argument specifies the size of txPacketBuffer.
 * \param[in] txPacketBuffer Pointer to buffer to store outbound packets in.
 *
 * This function initializes all internally used variables in the stack. The stack will 
 * however not be operational until the transcoder has signalled that it is ready for
 * other symbols than idle. This is done using the function RIOSTACK_setPortStatus(). Once 
 * this function has been called it is possible to get and set symbols and to issue
 * requests. The requests will be transmitted once the link initialization has 
 * been completed.
 * 
 * The rxPacket/txPacket arguments are word buffers that are used internally to store the 
 * inbound and outbound packet queues. 
 *
 * The config argument constants are used as identification when maintenance packets 
 * are received and replied to. They should be set to make the device where the stack 
 * is used easily identifiable on the net.
 *
 * \note The reception buffers can only support maximum 31 buffers.
 */
void RIOSTACK_open(RioStack_t *stack, void *private, 
                   const uint32_t rxPacketBufferSize, uint32_t *rxPacketBuffer, 
                   const uint32_t txPacketBufferSize, uint32_t *txPacketBuffer);

/*******************************************************************************************
 * Stack status functions.
 * Note that status counters are access directly in the stack-structure.
 *******************************************************************************************/

/**
 * \brief Get the status of the link.
 *
 * \param[in] stack The stack to operate on.
 * \return Returns the status of the link, zero if link is uninitialized and non-zero if 
 * the link is initialized.
 *
 * This function indicates if the link is up and ready to relay packets. 
 */
int RIOSTACK_getStatus(RioStack_t *stack);

/**
 * \brief Clear outbound queue.
 *
 * \param[in] stack The stack to operate on.
 *
 * This function clears all pending packet in the outbound queue.
 */
void RIOSTACK_clearOutboundQueue(RioStack_t *stack);

/**
 * \brief Get the number of pending outbound packets.
 *
 * \param[in] stack The stack to operate on.
 * \return Returns the number of pending outbound packets.
 *
 * This function checks the outbound queue and returns the number of packets 
 * that are pending to be transmitted onto the link.
 */
uint8_t RIOSTACK_getOutboundQueueLength(RioStack_t *stack);

/**
 * \brief Get the number of available outbound packets.
 *
 * \param[in] stack The stack to operate on.
 * \return Returns the number of available outbound packets.
 *
 * This function checks the outbound queue and returns the number of packets 
 * that are available before the queue is full.
 */
uint8_t RIOSTACK_getOutboundQueueAvailable(RioStack_t *stack);

/**
 * \brief Add a packet to the outbound queue.
 *
 * \param[in] stack The stack to operate on.
 * \param[in] packet The packet to send.
 *
 * This function sends a packet.
 *
 * \note The packet CRC is not checked. It must have been checked before it is used as 
 * argument to this function.
 *
 * \note Call RIOSTACK_outboundQueueAvailable() before this function is called to make sure
 * the outbound queue has transmission buffers available.
 *
 * \note Use RIOSTACK_getStatus() to know when a packet is allowed to be transmitted.
 */
void RIOSTACK_setOutboundPacket(RioStack_t *stack, RioPacket_t *packet);

/**
 * \brief Clear inbound queue.
 *
 * \param[in] stack The stack to operate on.
 *
 * This function clears all pending packet in the inbound queue.
 */
void RIOSTACK_clearInboundQueue(RioStack_t *stack);

/**
 * \brief Get the number of pending inbound packets.
 *
 * \param[in] stack The stack to operate on.
 * \return Returns the number of pending inbound packets.
 *
 * This function checks the inbound queue and returns the number of packets 
 * that has been received but not read by the user yet.
 */
uint8_t RIOSTACK_getInboundQueueLength(RioStack_t *stack);

/**
 * \brief Get the number of available inbound packets.
 *
 * \param[in] stack The stack to operate on.
 * \return Returns the number of available inbound packets.
 *
 * This function checks the inbound queue and returns the number of packets 
 * that can be received without the queue is full.
 */
uint8_t RIOSTACK_getInboundQueueAvailable(RioStack_t *stack);

/**
 * \brief Get, remove and return a packet from the inbound queue.
 *
 * \param[in] stack The stack to operate on.
 * \param[in] packet The packet to receive to.
 *
 * This function moves a packet from the inbound packet queue to the location of the packet 
 * in the argument list.
 */
void RIOSTACK_getInboundPacket(RioStack_t *stack, RioPacket_t *packet);

/*******************************************************************************************
 * Port functions (backend API towards physical device)
 *******************************************************************************************/

/**
 * \brief Set a port current time.
 *
 * \param[in] stack The stack to operate on.
 * \param[in] time The current time without unit.
 *
 * This function indicates to the stack the current time and this is used internally 
 * to calculate when a packet timeout should be triggered. Use this together with RIOSTACK_setPortTimeout() 
 * to allow for the stack to handle timeouts.
 */
void RIOSTACK_portSetTime( RioStack_t *stack, const uint32_t time);

/**
 * \brief Set a port timeout limit.
 *
 * \param[in] stack The stack to operate on.
 * \param[in] time The time out threshold.
 *
 * The time to wait for a response from the link partner. The unit of the 
 * timeout value should be the same as the time used in RIOSTACK_setPortTime().
 *
 * This function is used to set a timeout threshold value and is used to know when 
 * an acknowledge should have been received from a link partner.
 */
void RIOSTACK_portSetTimeout( RioStack_t *stack, const uint32_t time);

/**
 * \brief Set a ports status.
 * 
 * \param[in] stack The stack to operate on.
 * \param[in] initialized The state of the port.
 *
 * If set to non-zero, the symbol encoder/decoder indicates to the stack that
 * it is successfully encoding/decoding symbol, i.e. synchronized to the link.
 *
 * This function indicates to the stack if the port that are encoding/decoding
 * symbols are ready to accept other symbols than idle-symbols. If the
 * encoding/decoding loses synchronization then this function should be called
 * with an argument equal to zero to force the stack to resynchronize the link.
 */
void RIOSTACK_portSetStatus( RioStack_t *stack, const uint8_t initialized );

/**
 * \brief Add a new symbol to the RapidIO stack.
 *
 * \param[in] stack The stack to operate on.
 * \param[in] s A symbol received from a port.
 *
 * This function is used to insert new data, read from a port, into the stack. The
 * symbols will be concatenated to form packets that can be accessed using other
 * functions.
 */
void RIOSTACK_portAddSymbol( RioStack_t *stack, const RioSymbol_t s );

/**
 * \brief Get the next symbol to transmit on a port.
 *
 * \param[in] stack The stack to operate on.
 * \return A symbol that should be sent on a port.
 *
 * This function is used to fetch new symbols to transmit on a port. Packets that
 * are inserted are split into symbols that are accessed with this function.
 */
RioSymbol_t RIOSTACK_portGetSymbol( RioStack_t *stack );

#endif /* _RIOSTACK_H */
 
/*************************** end of file **************************************/
