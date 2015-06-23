//LogicalLayer.h

/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is HyperTransport Tunnel IP Core.
 *
 * The Initial Developer of the Original Code is
 * Ecole Polytechnique de Montreal.
 * Portions created by the Initial Developer are Copyright (C) 2005
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *   Ami Castonguay <acastong@grm.polymtl.ca>
 *
 * Alternatively, the contents of this file may be used under the terms
 * of the Polytechnique HyperTransport Tunnel IP Core Source Code License 
 * (the  "PHTICSCL License", see the file PHTICSCL.txt), in which case the
 * provisions of PHTICSCL License are applicable instead of those
 * above. If you wish to allow use of your version of this file only
 * under the terms of the PHTICSCL License and not to allow others to use
 * your version of this file under the MPL, indicate your decision by
 * deleting the provisions above and replace them with the notice and
 * other provisions required by the PHTICSCL License. If you do not delete
 * the provisions above, a recipient may use your version of this file
 * under either the MPL or the PHTICSCL License."
 *
 * ***** END LICENSE BLOCK ***** */

#ifndef LogicalLayer_H
#define LogicalLayer_H

#include "systemc.h"
#include "../../rtl/systemc/core_synth/constants.h"
#include "PhysicalLayer.h"
#include <deque>

//Forward declaration
class ControlPacket;
class LogicalLayer;

///Event handler interface for the LogicalLayer module
class LogicalLayerInterface{
public:
	/**
		@description Called when a packet is received by the
			LogicalLayer
		@param packet The received packet
		@param data The data associated with the packet.  It is an
			array of dwords.  If the packet has data associated with
			it, the size of the array is the number of dwords associated
			with the packet (1-16).  Otherwise, it is NULL.
		@param origin The LogicalLayer that launchde the event
	*/
	virtual void receivedHtPacketEvent(const ControlPacket * packet,
		const int * data,const LogicalLayer* origin)=0;
	/**
		Called when a periodic CRC error is detected
	*/
    virtual void crcErrorDetected()=0;
};

///Module that handles logical level of the HyperTransport link.
/**
	@author Ami Castonguay
	@description	It takes packets and breaks it in
		dwords to send to the Physical layer.  It also handles the retry
		mode : it will send appropriate per-packet CRC's and also store
		a history of sent packet so that packets not sent correctly
		can be reset.  
		
		It also handles NOPs both for transmission and for reception.  When
		nops are received, the buffer count of the next HT node is updated.
		The local buffer count is also maintained and nops are sent when
		necessary.

		When ::sendPacket is called, the packet to be sent it stored in
		a buffer but is not sent immediately.  It will be sent out as
		the simulation progresses.  If the flush function is called, it
		will only return when all packets in the buffer are sent.  If the
		next node does not have the necessary buffers to accept a packet,
		it is not sent unril the buffer is free.  

		When a new packet is received, an event is generated.  A listener
		simply has to implement the LogicalLayerInterface and register
		as the interface to the LogicalLayer to be notified of received
		packets.

		The class also implements the PhysicalLayerInterface to be notified
		by the PhysicalLayer of the link whenever a dword is received.
*/
class LogicalLayer : public sc_module, public PhysicalLayerInterface{

	///List of possible states for receiving packets
	enum ReceiveState{
		RECEIVE_IDLE,
		RECEIVE_SECOND_DWORD,
		RECEIVE_DATA,
		RECEIVE_NOP_CRC,
		RECEIVE_CRC
	};

	///List of possible states to transmit packets
	enum SendState{
		SEND_IDLE,
		SEND_SECOND_DWORD,
		SEND_ADDR_EXT,
		SEND_DATA,
		SEND_NOP_CRC,
		SEND_CRC
	};

	///Structure combining a packet, it's data and it's ack value
	struct PacketAndData{
		///The packet
		ControlPacket * packet;
		///Data associated with the packet (NULL if none)
		int * data;
		///Ack value of the packet (for the retry mode)
		int id;
	};

	///The retry CRC polynomial
	static const int PER_PACKET_CRC_POLY;
	///The number of simulated buffers of thie module
	static const int MAX_BUFFERS;

public:

	///SystemC Macro
	SC_HAS_PROCESS(LogicalLayer);

	///To debug, will display all received dwords
	bool displayReceivedDword;

	///Clock of the system
	sc_in<bool>	clk;
	///reset of the system (negative logic)
	sc_in<bool> resetx;

	///consctructor
	LogicalLayer(sc_module_name name);
	///destructor
	virtual ~LogicalLayer();

	/**
		@description This is a PhysicalLayerInterface function called by the 
		PhysicalLayer when a dword is received.
		@param dword The dword that was received
		@param lctl The CTL value for the lower part of the dword transmission
		@param hctl The CTL value for the higher part of the dword transmission
	*/
	virtual void receivedDwordEvent(sc_bv<32> &dword,bool lctl,bool hctl);

	/**
		@description This is a PhysicalLayerInterface function called by the 
		PhysicalLayer when a dword is needed to be sent out.
		@param dword The dword to send (return by address)
		@param lctl The CTL value for the lower part of the dword transmission (return by address)
		@param hctl The CTL value for the higher part of the dword transmission (return by address)
	*/
    virtual void dwordToSendRequested(sc_bv<32> &dword,bool &lctl,bool &hctl);

	/**
		@description This is a PhysicalLayerInterface function called by the PhysicalLayer
		when periodic CRC error occurs
	*/
    virtual void crcErrorDetected();

	///To send a packet (non-blocking, packet is simply buffered)
	/**
		The function will store the packet and send it as soon as it can as the simulation
		advances.  Packets and the data will then be deleted by the LogicalLayer.
		@param packet The packet to send (memory control is given to LogicalLayer)
		@param data The dwords of data associated the the packet (NULL if no data to send)
				(memory control is given to LogicalLayer)
	*/
	void sendPacket(ControlPacket * packet,int * data);

	///Blocks until all packets are sent out
    void flush();

	///Set if the retry mode should be activated.  Will take effect after warm reset
	void setRetryMode(bool retry){retry_mode_after_reset = retry;};
	///This will initiate a retry sequence as soon as the current packet has done sending
	void initiateRetrySequence();

	///Sets the interface handler so that it can be notified of received packets
	void setInterface(LogicalLayerInterface * i){inter = i;};
	///Sets the physical layer to send and receive packet to and from
	/**
		Registers the PhysicalLayer as a the PhysicalLayer to send data to and registers
		this object as PhysicalLayer received dword event listener
	*/
	void setPhysicalLayer(PhysicalLayer * pl){
		physicalLayer = pl;
		physicalLayer->setInterface(this);
	};

	///Allows to ignore incoming packets
	void setIgnoreIncoming(bool ignore){ignoreIncoming = ignore;};

protected:

	///A process that re-initializes things when reset is asserted
	void reset_thread();

private:

	///Updates buffers and ack value contained in a received NOP
	/**
		If in retry mode, acked history entries are deleted
	*/
	void handleNopPacket(sc_bv<32> &dword);

	///Calculate a CRC for the packet and it's data
	int calcultatePacketCrc(ControlPacket * pkt,int * data);

	///Update a CRC with the dword and ctl value
	/**
		@param crc The current CRC value to update
		@param dword The dword to feed as input to the CRC unit
		@param ctl The ctl value to feed as input to the CRC unit
	*/
	void calcultateDwordCrc(int &crc,sc_bv<32> &dword,bool ctl);

	///Verifies the state of advertised buffers and checks if a sending a nop is required
	bool isSendingNopRequired();

	///Update the value of advertised buffers when a packet is received
	void updateRxBufferCount(ControlPacket * receivedPacket);

	///Generates a nop packet with the current ack value
	NopPacket * generateNopPacket();

	///Queue of packets to send
	/**
		When packet are to be sent, they are added to the queue.  When the packet is sent, 
		it is deleted from the packetQueue.  The queue is also cleared when a retry sequence
		is initiated or under a reset
	*/
	std::deque<PacketAndData> packetQueue;

	///History of packet sent (and to send)
	/**
		When packet are to be sent, they are added to the packetHistory (just like with the
		::packetQueue ).  The packet from the history is deleted when it is acked.  It is
		cleared during reset.
	*/
	std::deque<PacketAndData> packetHistory;

	///The interface to notify when packets are received
	LogicalLayerInterface * inter;
	///The physical layer to send dwords to
	PhysicalLayer * physicalLayer;
	///The ID counter for sent packet
	int packetIdCounter;

	///Wether or not to ignore incoming dwords
	bool ignoreIncoming;
	///If we are currently in the retry mode
	bool retry_mode;
	///If we should enter the retry mode after a reset
	bool retry_mode_after_reset;
	///If a retry sequence should be initiated as soon as possible
	bool initiate_retry_disconnect;

	///The first dword of a received packet (useful for calculating inserted NOP CRC's)
	sc_bv<32> firstReceivedDword;
	///Current packet being received.
	/**  NULL at the beggining, it is always deleted before being set to a new value
		Created as soon as a first dword is received.  NOP's inserted in data packets
		are not stored here.
	*/
	ControlPacket * receivedPacket;
	///Data received
	int receivedData[16];
	///The count of received data
	int receivedDataCount;
	///The state for the reception of packets (
	ReceiveState receive_state;
	///The ack value of received packets.  Incremented when packets are received
	int rx_ack_value;
	///If we are currently waiting for a nop to start replaying the history
	bool rx_retry_waiting_for_nop;


	///The state for the transmission of data
	SendState send_state;
	///The packet currently being sent
	PacketAndData currentSendPacket;
	///The nop packet currently being sent
	ControlPacket * nopSendPacket;
	///Where we are in sending data
	int sendDataCount;
	///If what is currently being sent is a disconnect nop
	bool disconNop;

	///The state of the command buffers of the next node
	int nextNodeCommandBuffersFree[3];
	///The state of the data buffers of the next node
	int nextNodeDataBuffersFree[3];

	///The number of command buffers which have been advertised as free
	int commandBuffersAdvertised[3];
	///The number of data buffers which have been advertised as free
	int dataBuffersAdvertised[3];
	///The number of command buffers that are free
	int commandBuffersFree[3];
	///The number of data buffers that are free
	int dataBuffersFree[3];
};


#endif
