//PhysicalLayer.cpp

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

#include "PhysicalLayer.h"

#include <iostream>

const int PhysicalLayer::PHYSICAL_LAYER_CRC_POLY = 0x04C11DB7;

PhysicalLayer::PhysicalLayer(sc_module_name name) : sc_module(name){
	SC_THREAD(receiveThread);
	sensitive_pos(clk);

	SC_THREAD(transmitThread);
	sensitive_pos(clk);

	inter = NULL;
	tx_connected = false;
	rx_connected = false;
	retryDisconnectCountTX = 0;
	retryDisconnectCountRX = 0;
	ldtstop_sequence = false;
	ldtstop_sequence_complete = false;

	//Get a vector of all zeros and ones;
	v0 = 0;
	v1 = ~v0;
}

void PhysicalLayer::ldtstopDisconnect(){
	ldtstop_sequence = true;
	ldtstop_sequence_complete = false;
	ltdstop_last_crc_window = false;
}

void PhysicalLayer::ldtstopConnect(){
	ldtstop_sequence = false;
	ldtstop_sequence_complete = false;
}

void PhysicalLayer::retryDisconnectAndReconnect(){
	retryDisconnectCountTX = 60;
	retryDisconnectCountRX = 40;
}

void PhysicalLayer::receiveThread(){
	phy_consume_lk = true;
	while(inter){
		//Do nothing while disconnected
		while(!resetx.read() || ltdstop_rx_received_disconnect || retryDisconnectCountRX){
			if(retryDisconnectCountRX) retryDisconnectCountRX--;
			rx_connected = false;
			wait();
			if(!ldtstop_sequence) ltdstop_rx_received_disconnect = false;
		}
		if(!rx_connected) rx_connect();
		receiveDwordOrCrc();
	}
	cout << "ERROR: No interface connected to the PhysicalLayer" << endl;
}

void PhysicalLayer::transmitThread(){
	phy_available_lk = true;
	while(inter){
		if(!resetx.read() || ldtstop_sequence && ldtstop_sequence_complete || retryDisconnectCountTX)
			holdResetSignaling();
		if(!tx_connected) tx_connect();
		sendNextDwordOrCrc();
	}
}

void PhysicalLayer::holdResetSignaling(){
	tx_connected = false; 
	phy_ctl_lk = v0;
	for(int n = 0; n < CAD_OUT_WIDTH;n++) phy_cad_lk[n] = v1;
	//while reset, LDTSTOP sequence of RETRY disconnect, keep sending reset signaling
	while(!resetx.read() || ldtstop_sequence && ldtstop_sequence_complete  || retryDisconnectCountTX){
		if(retryDisconnectCountTX){
			retryDisconnectCountTX--;
		}
		if(!resetx.read()) ldtstop_sequence = false;
		wait();
	}
}


void PhysicalLayer::tx_connect(){
	cout << "Starting TX Connect" << endl;
	//Connect sequence phase 1
	phy_ctl_lk = v1;

	for(int n = 0; n < CAD_OUT_WIDTH;n++) phy_cad_lk[n] = v1;

	//Wait for RX CTL to be asserted
	while(!(bool)(sc_bit)lk_ctl_phy.read()[0]) wait();

	//Wait a minimum time
	for(int n = 0; n < 4; n++) wait();


	//Connect sequence phase 2
	phy_ctl_lk = v0;
	for(int n = 0; n < CAD_OUT_WIDTH;n++) phy_cad_lk[n] = v0;
	for(int n = 0; n < 128; n++) wait();



	//Connect sequence phase 3
	for(int n = 0; n < CAD_OUT_WIDTH;n++) phy_cad_lk[n] = v1;
	wait();
	cout << "Done TX Connect" << endl;

	tx_firstCrcWindow = true;
	current_tx_crc = 0xFFFFFFFF;
	tx_crc_count = 0;
	tx_connected = true; 
}
	
void PhysicalLayer::calculateCrc(int &crc,int dword,bool lctl,bool hctl){
	//Break loop in 4 because data is bigger than 32 bits
	for(int n=0; n < 4;n++){
		int ctl_or = 0;
		if(((n == 0 || n == 1) && lctl) || (n == 2 || n == 3) && hctl){
			ctl_or = 0x100;
		}

		int data =( (dword >> (n * 8)) & 0xFF) | ctl_or;

		//Code taken from HT spec
		for(int i = 0; i < 9; i++){
			int tmp = crc >> 31;//store highest bit
			crc = (crc << 1) | ((data >> i) & 1);//shift message in
			crc = (tmp) ? crc ^ PHYSICAL_LAYER_CRC_POLY : crc;//substract poly if greater
		}
	}
}

void PhysicalLayer::sendNextDwordOrCrc(){
	//Get next dword to send through interface
	sc_bv<32> dword;
	bool lctl;
	bool hctl;
	if(!ldtstop_sequence)
		inter->dwordToSendRequested(dword,lctl,hctl);
	else{
		dword = 64; lctl = true; hctl = true;
	}

	//Calculate the CRC for it
	calculateCrc(current_tx_crc,dword.to_int(),lctl,hctl);

	//Send it
	sendDword(dword,lctl,hctl);

	//Now send crc if at the right position in the window
	tx_crc_count++;
	if(!tx_firstCrcWindow && tx_crc_count == 16){
		sc_bv<32> dword_to_sent = ~current_tx_crc;
		sendDword(dword_to_sent,true,true);
		if(ltdstop_last_crc_window) ldtstop_sequence_complete = true;
	}

	if(tx_crc_count == 128){
		if(ldtstop_sequence) ltdstop_last_crc_window = true;
		tx_firstCrcWindow = false;
		tx_crc_count = 0;
		last_tx_crc = current_tx_crc;
		current_tx_crc = 0xFFFFFFFF;
	}
}

void PhysicalLayer::sendDword(sc_bv<32> &dword,bool lctl,bool hctl){
	sc_bv<CAD_IN_DEPTH> v;

	//Send the ctl bits
	for(int n = 0; n < CAD_IN_DEPTH/2;n++) v[n] = lctl;
	for(int n = CAD_IN_DEPTH/2; n < CAD_IN_DEPTH;n++) v[n] = hctl;
	phy_ctl_lk = v;

	//Send the cad bits
	for(int y = 0; y < CAD_IN_WIDTH;y++){
		for(int x = 0; x < CAD_IN_DEPTH;x++){
			v[x] = dword[x * CAD_IN_WIDTH + y]; 
		}
		phy_cad_lk[y] = v;
	}
	//Send the dword
	wait();
}

void PhysicalLayer::rx_connect(){
	cout << "Begin RX connect" << endl;

	//Phase 1 - reset signaling
	while(lk_ctl_phy.read()[0] == false)wait();

	//Phase 2 - CTL activated
	while(lk_ctl_phy.read()[0] == true)wait();

	//Phase 3 - Wait for CAD to activate
	while(lk_cad_phy[0].read()[0] == false)wait();

	cout << "Done RX connect" << endl;

	//Wait for the next valid data
	wait();
	rx_crc_count = 0;
	current_rx_crc = 0xFFFFFFFF;
	rx_firstCrcWindow = true;
	rx_connected = true;
}

void PhysicalLayer::receiveDwordOrCrc(){
	sc_bv<32> dword;
	bool lctl;
	bool hctl;

	//Receive Dword
	receiveDword(dword,lctl,hctl);
	calculateCrc(current_rx_crc,dword.to_int(),lctl,hctl);
	rx_crc_count++;

	if(dword == 0x40 && lctl && hctl && ldtstop_sequence){
		ltdstop_rx_received_disconnect = true;
		return;
	}

	//cout << "Sending received dword: " << dword << endl;
	inter->receivedDwordEvent(dword,lctl,hctl);

	//Check CRC at the right moment in the windows
	if(!rx_firstCrcWindow && rx_crc_count == 16){
		receiveDword(dword,lctl,hctl);
		if(~last_rx_crc != dword.to_int()){
			//cout << "CRC received: " << dword.to_string(SC_HEX) << endl;
			//cout << "CRC expected: " << sc_uint<32>(last_rx_crc).to_string() << endl;
			inter->crcErrorDetected();
		}
	}

	//Reset window after 128 dwords
	if(rx_crc_count == 128){
		last_rx_crc = current_rx_crc;
		current_rx_crc = 0xFFFFFFFF;
		rx_crc_count = 0;
		rx_firstCrcWindow = false;
	}
}

void PhysicalLayer::receiveDword(sc_bv<32> &dword,bool &lctl,bool &hctl){
	sc_bv<CAD_OUT_DEPTH> v;

	//Receive the CTLS
	lctl = (sc_bit)lk_ctl_phy.read()[0];
	hctl = (sc_bit)lk_ctl_phy.read()[CAD_OUT_DEPTH/2];

	//Receive cad bits
	for(int y = 0; y < CAD_OUT_WIDTH;y++){
		v = lk_cad_phy[y].read();
		for(int x = 0; x < CAD_OUT_DEPTH;x++){
			dword[x * CAD_OUT_WIDTH + y] = v[x]; 
		}
	}

	//Allow to receive next dword
	wait();
}

