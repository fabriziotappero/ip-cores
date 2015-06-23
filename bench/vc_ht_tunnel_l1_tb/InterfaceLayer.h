//InterfaceLayer.h

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

#ifndef InterfaceLayer_H
#define InterfaceLayer_H

#include "systemc.h"
#include <deque>

///forward declaration
class InterfaceLayer;

///Event handler class for received packet from the InterfaceLayer
class InterfaceLayerEventHandler{
public:
	///Called when the InterfaceLayer receives a packet
	/**
		@param packet The received packet
		@param data The data associated with the packet.  If it does not contain data, it is
			null.  Every int represents a dword of data
		@param directRoute If the packet was directRoute traffic
		@param side from which came the packet
		@param origin The InterfaceLayer that fired the event
	*/
	virtual void receivedInterfacePacketEvent(const ControlPacket * packet,const int * data,
		bool directRoute,bool side,InterfaceLayer* origin)=0;
};

///Software interface to communication to HT hardware user interface
/**
	@class InterfaceLayer
	@author Ami Castonguay
	@description A software interface to send and received packets to a HT tunnel
		in hardware.  It breaks down packets queued to be sent into dwords that
		are sent to the tunnel.  Received dwords are reconstructed in packets.
*/
class InterfaceLayer : public sc_module {

	///The packet, it's data and the side it came from 
	struct PacketAndData{
		///Control packet
		ControlPacket * packet;
		///Data associated with that control packet (NULL if none)
		int * data;
		///Side the packet arrived from
		bool side;
	};

	///State for packet transmission
	enum TransmitState{
		TX_SEND_DATA,
		TX_IDLE
	};

	///State for packet reception
	enum ReceiveState{
		RX_RECEIVE_DATA,
		RX_IDLE
	};

public:

	///Main clock of the system
	sc_in<bool>		clk;
	///Main reset of the system (negative logic)
	sc_in<bool>		resetx;

	//******************************************
	//			Signals to User
	//******************************************
	//------------------------------------------
	// Signals to send received packets to User
	//------------------------------------------


	/**The actual control/data packet to the user*/
	sc_in<sc_bv<64> >		ui_packet_usr;

	/**The virtual channel of the ctl/data packet*/
	sc_in<VirtualChannel>	ui_vc_usr;

	/**The side from which came the packet*/
	sc_in< bool >			ui_side_usr;

	/**If the packet is a direct_route packet - only valid for
	   requests (posted and non-posted) */
	sc_in<bool>			ui_directroute_usr;

	/**If this is the last part of the packet*/
	sc_in< bool >			ui_eop_usr;
	
	/**If there is another packet available*/
	sc_in< bool >			ui_available_usr;

	/**If what is read is 64 bits or 32 bits*/
	sc_in< bool >			ui_output_64bits_usr;

	/**To allow the user to consume the packets*/
	sc_out< bool >			usr_consume_ui;


	//------------------------------------------
	// Signals to allow the User to send packets
	//------------------------------------------

	/**The actual control/data packet from the user*/
	sc_out<sc_bv<64> >		usr_packet_ui;

	/**If there is another packet available*/
	sc_out< bool >			usr_available_ui;

	/**
	The side to send the packet if it is a response
	This bit is ignored if the packet is not a response
	since the side to send a request is determined automatically
	taking in acount DirectRoute functionnality.
	*/
	sc_out< bool >			usr_side_ui;

	/*
		Which what type of ctl packets can be sent
		bits.  Thos signals have the same value as
		the outputs, but they are here so that
		these signals can be used internally. 

		5 POSTED,		no data
		4 POSTED,		data
		3 NON_POSTED,	no data
		2 NON_POSTED,	data
		1 RESPONSE, 	no data
		0 RESPONSE, 	data
	*/
	/**Which what type of ctl packets can be sent to side0*/
	sc_in<sc_bv<6> >		ui_freevc0_usr;
	/**Which what type of ctl packets can be sent to side0*/
	sc_in<sc_bv<6> >		ui_freevc1_usr;


	//------------------------------------------
	// Signals to affect CSR
	//------------------------------------------
	///Activated when response error is received
	sc_out<bool> usr_receivedResponseError_csr;

	///SystemC Macro
	SC_HAS_PROCESS(InterfaceLayer);
	///Queue of packet to send on the interface
	std::deque<PacketAndData> packetQueue;

	///Constructor
	InterfaceLayer(sc_module_name name);
	///Destructor
	virtual ~InterfaceLayer();

	///Set the interface handler that will be notified of received packet
	void setInterfaceLayerEventHandler(InterfaceLayerEventHandler *handler){
		this->handler = handler;
	};

	///To send a packet (non-blocking, packet is simply buffered)
	void sendPacket(ControlPacket * packet,int * data,bool side = false);
	///Blocks until all packets are sent out
    void flush();

protected:
	///Process for reception of packets from the tunnel
	void rx_process();
	///Process to send queued data to the tunnel
	void tx_process();

private:

	///Event handler for received packet
	InterfaceLayerEventHandler * handler;
	///The count of data sent
	int tx_data_sent;
	///The count of data received
	int rx_received_data;
	///State of packet transmission
	TransmitState tx_state;
	///State of packet reception
	ReceiveState rx_state;

	///Packet currently being received
	ControlPacket * receivePacket;
	///Buffer for received data
	int receiveData[16];
	///Side from which the packet was received
	bool receiveSide;
	///If the packet is directRoute traffic
	bool receiveDirecRoute;
};

#endif


