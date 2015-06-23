//PhysicalLayer.h

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

#ifndef PhysicalLayer_H
#define PhysicalLayer_H

#include "systemc.h"
#include "../../rtl/systemc/core_synth/constants.h"

//Forward decleration
class PhysicalLayer;

///Event handler interface for the PhysicalLayer module
class PhysicalLayerInterface{
public:
	/**
		@description Called by the PhysicalLayer when a dword is received.
		@param dword The dword that was received
		@param lctl The CTL value for the lower part of the dword transmission
		@param hctl The CTL value for the higher part of the dword transmission
	*/
	virtual void receivedDwordEvent(sc_bv<32> &dword,bool lctl,bool hctl)=0;
	/**
		@description Called by the PhysicalLayer when a dword is needed to be sent out.
		@param dword The dword to send (return by address)
		@param lctl The CTL value for the lower part of the dword transmission (return by address)
		@param hctl The CTL value for the higher part of the dword transmission (return by address)
	*/
    virtual void dwordToSendRequested(sc_bv<32> &dword,bool &lctl,bool &hctl)=0;
	/**
		@description This is a PhysicalLayerInterface function called by the PhysicalLayer
		when periodic CRC error occurs
	*/
    virtual void crcErrorDetected()=0;
};

///Handles low level communication with an HT link
/**
	@class PhysicalLayer
	@author Ami Castonguay
	@description This SystemC module handles very low level communication of a HT link.
		It does the initialization of the link, serialization and de-serialization.  It
		also handles periodic CRC insertions.

		When a valid dword is received which is not part of an init sequence or a periodic
		CRC, an event is generated.  Since every cycle, the link must output valid data,
		an event is also generated whenever a dword to send is requested.

		This physical layer is not complete in terms of HT (it would not work with a
		variety of HT links) but is compatible with the current HT core being tested.
*/
class PhysicalLayer : public sc_module{

	///The event handler for when dwords are received and needs to be sent
	PhysicalLayerInterface * inter;

	///The periodic CRC polynomial to use
	static const int PHYSICAL_LAYER_CRC_POLY;

public:
	// ***************************************************
	//  Signals
	// ***************************************************	
	/// Clock signal
	sc_in<bool>			clk;
	///Reset signal
	sc_in<bool>			resetx;

	///When we have data available for the link
	sc_out<bool>						phy_available_lk;
	///TX CTL Higher is sent later (MSB), lower is sent first (LSB)
	sc_out<sc_bv<CAD_IN_DEPTH> >		phy_ctl_lk;
	///TX CAD Higher is sent later (MSB), lower is sent first (LSB)
	sc_out<sc_bv<CAD_IN_DEPTH> >		phy_cad_lk[CAD_IN_WIDTH];

	///RX CTL - Higher is newer (MSB), lower is older (LSB)
	sc_in<sc_bv<CAD_OUT_DEPTH> >	lk_ctl_phy;
	///RX CAD - Higher is newer (MSB), lower is older (LSB)
	sc_in<sc_bv<CAD_OUT_DEPTH> >	lk_cad_phy[CAD_OUT_WIDTH];
	///When there is data available for us
	sc_out<bool>					phy_consume_lk;
	
	///If the tested link wants the drivers to be disabled
	sc_in<bool> 		lk_disable_drivers_phy;
	///If the tested link wants the receivers to be disabled
	sc_in<bool> 		lk_disable_receivers_phy;

	///SystemC Macro
	SC_HAS_PROCESS(PhysicalLayer);

	///Constructor
	PhysicalLayer(sc_module_name name);
	///Destructor
	virtual ~PhysicalLayer(){};

	///Will disconnect when the CRC windows is done
	void ldtstopDisconnect();
	///Reconnect the link ASAP
	void ldtstopConnect();

	///Causes an immediate disconnect, no further dwords are sent out
	void retryDisconnectAndReconnect();

	///The interface to connect to the physical layer
	void setInterface(PhysicalLayerInterface * inter){this->inter = inter;};

private:

	///If the TX side of the link is connected
	bool tx_connected;
	///The current calculated TX periodic CRC
	int current_tx_crc;
	///The value of the TX CRC for the last window of operation
	int last_tx_crc;
	///If the current TX window is the first CRC window since init
	bool tx_firstCrcWindow;
	///The count of where where are in the TX CRC window (in dwords)
	int tx_crc_count;

	///If the RX side of the link is connected
	bool rx_connected;
	///The current calculated RX periodic CRC
	int current_rx_crc;
	///The value of the RX CRC for the last window of operation
	int last_rx_crc;
	///If the current RX window is the first CRC window since init
	bool rx_firstCrcWindow;
	///The count of where where are in the RX CRC window (in dwords)
	int rx_crc_count;

	///Vector of only zeroes
	sc_bv<CAD_IN_DEPTH> v0;
	///Vector of only ones
	sc_bv<CAD_IN_DEPTH> v1;

	///If we are currently in a ldtstop sequence (ignore inputs and output discon nop until end of window)
	bool ldtstop_sequence;
	///If done sending ldtstop packets
	bool ldtstop_sequence_complete;
	///After sending the last CRC, the sequence will be complete
	bool ltdstop_last_crc_window;
	///If a discon nop was received on the rx
	bool ltdstop_rx_received_disconnect;

	///The number of cycles that the TX must stay disconnected for a retry sequence
	int retryDisconnectCountTX;
	///The number of cycles that the RX must stay disconnected for a retry sequence
	int retryDisconnectCountRX;

	///Process that handles receiving the data and generated events
	void receiveThread();
	///Process that handles transmiting data
	void transmitThread();
	///Keeps sending reset signaling until conditions have passed.
	void holdResetSignaling();
	///Initiate the connect sequence for the TX
	void tx_connect();

	///Calculate the periodic CRC for a send dword
	void calculateCrc(int &crc,int dword,bool lctl,bool hctl);
	///Sends next dword, either data or the window CRC if at the correct time
	void sendNextDwordOrCrc();
	///Sends the specified dword and CTL value on the outputs
	void sendDword(sc_bv<32> &dword,bool lctl,bool hctl);
	///Initiate the connect sequence for the RX
	void rx_connect();
	///If at the correct pos in the window, CRC is checked.  Otherwise, data is received
	void receiveDwordOrCrc();
	///IExtracts the dword received from the input
	void receiveDword(sc_bv<32> &dword,bool &lctl,bool &hctl);
};


#endif

