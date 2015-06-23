//link_l2_tb.cpp
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

#include "link_l2_tb.h"
#include <cstdlib>
#include <iostream>

#include "../link_frame_rx_l3_tb/link_rx_transmitter.h"
#include "../link_frame_tx_l3_tb/link_tx_validator.h"
#include "../../core/require.h"

/**
	Note : this is far from being a full testbench.  The goal of this
	is to verify the basic fonctionnality.  Extensive testing of all
	possibilities is not yet a priority...  
	
	 The goals of this testbench are to check :

	-basic sequence without error (verify the correctness of sent CRC's)
	-basic with error on rx side (verify the correctness of sent CRC's)
	-ldtstop sequence
	-sync error

	-basic with error in CRC and retry mode enabled (should be ignored)
	-basic with error in CTL transition and retry mode
*/


link_l2_tb::link_l2_tb(sc_module_name name) : sc_module(name){
	SC_THREAD(manage_rx_transmission);
	sensitive_pos(clk);

	SC_THREAD(validate_rx_reception);
	sensitive_pos(clk);

	SC_THREAD(stimulus);
	sensitive_pos(clk);

	transmitter = new link_rx_transmitter("link_rx_transmitter");
	transmitter->clk(clk);
	transmitter->phy_ctl_lk(phy_ctl_lk);
	for(int n = 0; n < CAD_IN_WIDTH; n++){
		transmitter->phy_cad_lk[n](phy_cad_lk[n]);
	}
	transmitter->phy_available_lk(phy_available_lk);

#ifndef INTERNAL_SHIFTER_ALIGNMENT
	transmitter->lk_deser_stall_phy(lk_deser_stall_phy);
	transmitter->lk_deser_stall_cycles_phy(lk_deser_stall_cycles_phy);
#endif

	validator = new link_tx_validator("link_tx_validator");
	validator->clk(clk);

	validator->lk_ctl_phy(lk_ctl_phy);
	for(int n = 0; n < CAD_IN_WIDTH; n++){
		validator->lk_cad_phy[n](lk_cad_phy[n]);
	}
	validator->tx_consume_data(lk_consume_fc);

	validator->phy_consume_lk(phy_consume_lk);
	validator->cad_to_frame(fc_dword_lk);
	validator->lctl_to_frame(fc_lctl_lk);
	validator->hctl_to_frame(fc_hctl_lk);

	//A random seed value
	srand(23524);
	reset_rx_connection = false;
	check_rx_dword_reception = true;
	rx_number = 0;
	expecting_rx_crc_error = 0;

	rx_crc = 0xFFFFFFFF;
	tx_crc = 0xFFFFFFFF;
}

link_l2_tb::~link_l2_tb(){
	delete transmitter;
	delete validator;
}

void link_l2_tb::stimulus(){
	init();

	link_tx_validator::LinkTransmission_TX tx_crc_transmission;
	tx_crc_transmission.lctl = true;
	tx_crc_transmission.hctl = true;

	LinkTransmission rx_crc_transmission;
	rx_crc_transmission.error = false;
	rx_crc_transmission.lctl = true;
	rx_crc_transmission.hctl = true;

	//////////////////////////////////////
	// First test, valid and nonvalid CRC
	//////////////////////////////////////
	
	init_fill_queues(272,false);
	tx_crc_transmission.dword = ~last_tx_crc;
	validator->expected_transmission.push(tx_crc_transmission);
	//cout << "Expected TX CRC : " << tx_crc_transmission.dword.to_string(SC_HEX) << endl;

	//rx_crc_transmission.dword = ~last_rx_crc;
	//Generate error!
	rx_crc_transmission.dword = 0x01234567;
	transmit_rx_queue.push(rx_crc_transmission);
	expecting_rx_crc_error++;

	fill_rx_qeues(16, true);
	fill_tx_qeues(16, true);

	link_tx_validator::LinkTransmission_TX nop_transmit;
	nop_transmit.dword = 0;
	nop_transmit.lctl = true;
	nop_transmit.hctl = true;

	validator->expect_tx_consume_data = 600;

	while(!(expected_rx_queue.empty() && validator->expected_transmission.empty())){
		if(validator->to_transmit.size() < 2){
			validator->to_transmit.push(nop_transmit);
			validator->checking_errors = false;
		}
		
		if(lk_crc_error_csr.read()){
			if(!expecting_rx_crc_error)
				cout << "CRC mismatch on reception" << endl;
			else
				expecting_rx_crc_error--;
		}
		wait();
	}

	cout << "Done basic sequence without CTL error " << endl;
	resetx = false;

	if(expecting_rx_crc_error){
		cout << "Some CRC transmission errors were not detected!" << endl;
	}

	//////////////////////////////////////
	// Test : LDTSTOP sequence
	//////////////////////////////////////
	cout << endl << "Start LDTSTOP test" << endl;
	empty_tx_queues(true);
	empty_rx_queues(true);
	init();
	cout << "LDTSTOP init done" << endl;
	init_fill_queues(272,true);
	validator->expect_tx_consume_data = 600;

	//Send part of the data
	while(validator->expected_transmission.size() > 114){
		if(lk_crc_error_csr.read()){
			if(!expecting_rx_crc_error)
				cout << "CRC mismatch on reception" << endl;
			else
				expecting_rx_crc_error--;
		}
		wait();
	}

	cout << "starting LDTSTOP sequence" << endl;

	//Start ldtstop sequence
	ldtstopx = false;
	cd_initiate_nonretry_disconnect_lk = true;

	while(validator->expected_transmission.size() > 0){
		if(lk_crc_error_csr.read()){
			if(!expecting_rx_crc_error)
				cout << "CRC mismatch on reception" << endl;
			else
				expecting_rx_crc_error--;
		}
		wait();
	}

	cout << "Sending disconnect nops" << endl;

	//Disconnect NOPs!
	link_tx_validator::LinkTransmission_TX t_tx;
	t_tx.dword = sc_uint<32>(0x00000020); t_tx.hctl = true; t_tx.lctl = true;
	for(int n = 0; n < 20; n++)
		validator->expected_transmission.push(t_tx);

	while(validator->expected_transmission.size() > 10){
		if(lk_crc_error_csr.read()){
			if(!expecting_rx_crc_error)
				cout << "CRC mismatch on reception" << endl;
			else
				expecting_rx_crc_error--;
		}
		wait();
	}

	cout << "Done LDTSTOP sequence test" << endl;

	//////////////////////////////////////
	// Test : SYNC sequence
	//////////////////////////////////////
	cout << endl << "Start SYNC test" << endl;
	empty_tx_queues(true);
	empty_rx_queues(true);
	init();
	init_fill_queues(400,true);
	validator->expect_tx_consume_data = 600;

	cout << "Start sending data" << endl;
	//Send part of the data
	while(validator->expected_transmission.size() > 1 || !phy_consume_lk.read()){
		if(lk_crc_error_csr.read()){
			if(!expecting_rx_crc_error)
				cout << "CRC mismatch on reception" << endl;
			else
				expecting_rx_crc_error--;
		}
		wait();
	}

	cout << "starting SYNC sequence" << endl;

	//Start sync sequence
	csr_sync = true;

	//Empty all expected packets
	for(int n = expected_rx_queue.size(); n != 0 ;n--)
		expected_rx_queue.pop();

	//Expect disconnect NOPs!
	t_tx.dword = sc_uint<32>(0xFFFFFFFF); t_tx.hctl = true; t_tx.lctl = true;
	for(int n = 0; n < 150; n++)
		validator->expected_transmission.push(t_tx);

	while(validator->expected_transmission.size() > 10){
		if(lk_crc_error_csr.read()){
			cout << "CRC mismatch on reception" << endl;
		}
		wait();
	}

	csr_sync = false;
	cout << "Done SYNC sequence test" << endl;

	//////////////////////////////////////
	// Test : CRC Error in retry mode (should be ignored)
	//////////////////////////////////////
	cout << endl << "Start Retry CRC error test" << endl;
	empty_tx_queues(true);
	empty_rx_queues(true);
	init();
	init_fill_queues(272,false);
	validator->checking_errors = false;

	//rx_crc_transmission.dword = ~last_rx_crc;
	//Generate error!
	transmit_rx_queue.push(rx_crc_transmission);

	fill_rx_qeues(16, true);
	fill_tx_qeues(16, true);

	validator->expect_tx_consume_data = 600;

	csr_retry = true;

	while(!(expected_rx_queue.empty() && validator->expected_transmission.empty())){
		if(validator->to_transmit.size() < 2){
			validator->to_transmit.push(nop_transmit);
		}
		
		if(lk_crc_error_csr.read())
			cout << "ERROR : CRC mismatch signaled in retry mode" << endl;
		if(lk_initiate_retry_disconnect.read())
			cout << "Error, retry sequence started incorrectly!" << endl;
		wait();
	}

	cout << "Done retry sequence with periodic CRC error " << endl;
	resetx = false;
	csr_retry = false;
	//validator->checking_errors = true;


	//////////////////////////////////////
	// Test : CTL transition error in retry mode
	//////////////////////////////////////
	cout << endl << "Start Retry CTL error test" << endl;
	empty_tx_queues(true);
	empty_rx_queues(true);
	init();
	init_fill_queues(50,false);
	csr_retry = true;
	validator->checking_errors = false;

	LinkTransmission rx_ctl_error_t;
	rx_ctl_error_t.error = true;
	rx_ctl_error_t.lctl = true;
	rx_ctl_error_t.hctl = true;
	rx_ctl_error_t.dword = 0x01234567;

	transmit_rx_queue.push(rx_ctl_error_t);

	fill_rx_qeues(16, true);
	fill_tx_qeues(16, true);

	validator->expect_tx_consume_data = 600;

	csr_retry = true;

	while(!expected_rx_queue.empty() && !lk_initiate_retry_disconnect.read())
		wait();

	if(!lk_initiate_retry_disconnect.read())
		cout << "Error, retry sequence not started correctly!" << endl;

	csr_retry = false;
	cout << "Done retry sequence CTL error " << endl;

	//////////////////////////////////////
	// Test : initiate an external retry sequence
	//////////////////////////////////////

	/*cout << "Start initiate Retry test" << endl;
	empty_tx_queues(true);
	empty_rx_queues(true);
	init();
	init_fill_queues(50,false);
	csr_retry = true;

	while(validator->expected_transmission.size() > 10)
		wait();*/

	resetx = false;
	validator->checking_errors = false;
	validator->reset();

	//Inifinite loop
	while(true) wait();
}

void link_l2_tb::init(){
	cout << "TB: Init" << endl;

	/**
		Start reset and initialist internal variables and signals sent
		to the link
	*/
	resetx = false;
	pwrok = false;
	ldtstopx = false;

	csr_rx_link_width_lk = "000";
	csr_tx_link_width_lk = "000";
	csr_sync = false;
	csr_end_of_chain = false;

	csr_crc_force_error_lk = false;
	csr_transmitter_off_lk = false;
	csr_extented_ctl_lk = false;
	csr_extended_ctl_timeout_lk = false;
	csr_ldtstop_tristate_enable_lk = false;
	
#ifdef RETRY_MODE_ENABLED
	cd_initiate_retry_disconnect = false;
	fc_disconnect_lk = false;
	csr_retry = false;
#endif
	cd_initiate_nonretry_disconnect_lk = false;

	//Reset validator to initial state
	validator->reset();
	//Wait some cycles for reset to have effect
	for(int n = 0; n < 5; n++) wait();
	validator->reset();//Not sure this call is necessary...

	//Stop cold reset and make sure no in ldtstop sequence
	pwrok = true;
	ldtstopx = true;
	transmitter->send_initial_value(5);

	for(int n = 0; n < 5; n++) wait();

	//stop reset
	resetx = true;
	//Reset the rx connection (it will reconnect automatically)
	reset_rx_connection = true;
}

void link_l2_tb::init_fill_queues(const unsigned quantity,bool insertLastCrc){
	//First, push a maximum of 128 in
	int q_max128 = quantity > 128 ? 128 : quantity;
	fill_rx_qeues(q_max128, true);
	fill_tx_qeues(q_max128, true);

	//Check how many are to add
	int quantity_remaining = quantity - q_max128;

	//if none, we're done
	if(!quantity_remaining) return;

	//128 is the first window 
	last_rx_crc = rx_crc;
	last_tx_crc = tx_crc;
	rx_crc = 0xFFFFFFFF;
	tx_crc = 0xFFFFFFFF;

	//Transmission object that will hold tx CRC
	link_tx_validator::LinkTransmission_TX tx_crc_transmission;
	tx_crc_transmission.lctl = true;
	tx_crc_transmission.hctl = true;

	//Transmission object that will hold rx CRC
	LinkTransmission rx_crc_transmission;
	rx_crc_transmission.error = false;
	rx_crc_transmission.lctl = true;
	rx_crc_transmission.hctl = true;
	while(true){
		//Send a max of 16 dwords
		int q_max16 = quantity_remaining > 16 ? 16 : quantity_remaining;
		//substract the number sent to the quantity remaining
		quantity_remaining -= q_max16;

		//Fill the queues
		fill_rx_qeues(q_max16, true);
		fill_tx_qeues(q_max16, true);

		//Break if done
		//If less than 16 were pushed in, we reached our quantity
		//If 16 were pushed and none left, we're done if we don't want
		//to add the last CRC
		if(!quantity_remaining && !insertLastCrc || q_max16 != 16) break;

		//Insert the CRC
		tx_crc_transmission.dword = ~last_tx_crc;
		rx_crc_transmission.dword = ~last_rx_crc;
		validator->expected_transmission.push(tx_crc_transmission);
		transmit_rx_queue.push(rx_crc_transmission);
		//cout << "TX CRC inserted : " << tx_crc_transmission.dword.to_string(SC_HEX)
		//	<< " Size now : " << validator->expected_transmission.size() << endl;

		if(!quantity_remaining) break;

		//Insert the next 112 dwords of the window
		int q_max112 = quantity_remaining > 112 ? 112 : quantity_remaining;
		quantity_remaining -= q_max112;

		fill_rx_qeues(q_max112, true);
		fill_tx_qeues(q_max112, true);


		last_rx_crc = rx_crc;
		last_tx_crc = tx_crc;
		rx_crc = 0xFFFFFFFF;
		tx_crc = 0xFFFFFFFF;	

		if(!quantity_remaining) break;
	}
}


void link_l2_tb::fill_tx_qeues(const unsigned quantity, bool updateCRC){
	LinkTransmission t;
	link_tx_validator::LinkTransmission_TX t_tx;

	//Add the requested number of transmissions
	for(unsigned n = 0; n < quantity; n++){
		//Generate a transmission
		generate_random_transmission(t);
		//Simply copy it into a TX transmission
		t_tx.dword = t.dword; t_tx.hctl = t.hctl; t_tx.lctl = t.lctl;

		//Put it in the expected and to_transmit queues
		validator->expected_transmission.push(t_tx);
		validator->to_transmit.push(t_tx);
		if(updateCRC) {
			update_crc(tx_crc,t.dword,t.lctl,t.hctl);
			//cout << "CRC after " << n << " : " << tx_crc << "Hex " << sc_uint<32>(tx_crc).to_string(SC_HEX) << endl;
		}
	}
}

void link_l2_tb::empty_tx_queues(bool reset_crc){
	for(int n = validator->expected_transmission.size(); n > 0; n--)
		validator->expected_transmission.pop();
	for(int n = validator->to_transmit.size(); n > 0; n--)
		validator->to_transmit.pop();
	if(reset_crc){
		last_tx_crc = 0;
		tx_crc = 0xFFFFFFFF;
	}
}

void link_l2_tb::fill_rx_qeues(const unsigned quantity, bool updateCRC){
	LinkTransmission t;
	t.error = false;
	for(int n = quantity; n != 0; n--){
		generate_random_transmission(t);
		transmit_rx_queue.push(t);
		expected_rx_queue.push(t);
		if(updateCRC) 
			update_crc(rx_crc,t.dword,t.lctl,t.hctl);
	}
}

void link_l2_tb::empty_rx_queues(bool reset_crc){
	for(int n = transmit_rx_queue.size();n>0;n--)
		transmit_rx_queue.pop();
	for(int n = expected_rx_queue.size();n>0;n--)
		expected_rx_queue.pop();
	if(reset_crc){
		last_rx_crc = 0;
		rx_crc = 0xFFFFFFFF;
	}
}

void link_l2_tb::generate_random_transmission(LinkTransmission & t){
	//15 bit used for rand because some implementations of rand
	//have a max of 32K
	sc_uint<15> r = rand();
	t.dword.range(31,24) = r.range(7,0);
	r = rand();
	t.dword.range(23,16) = r.range(7,0);
	r = rand();
	t.dword.range(15,8) = r.range(7,0);
	r = rand();
	t.dword.range(7,0) = r.range(7,0);

	t.lctl = (rand() << 1) / (RAND_MAX);
	t.hctl = (rand() << 1) / (RAND_MAX);
}

void link_l2_tb::update_crc(int & crc,const sc_bv<32> &dword, bool lctl, bool hctl){
	//There is a total of 36 bits to throw in CRC.  Since it's higher
	//than 32 bits, do it in two passes of 18 bits
	unsigned dword_int = (unsigned)sc_uint<32>(dword);

	//Put data in integers
	int data[2] = {
		(dword_int & 0xFF) | ((dword_int & 0xFF00) << 1),
		((dword_int & 0xFF0000) >> 16) | ((dword_int & 0xFF000000) >> 15)
	};

	//Add the lctl values to the CRC
	if(lctl) data[0] |= 0x20100;
	if(hctl) data[1] |= 0x20100;

	sc_uint<18> d0 = data[0];
	sc_uint<18> d1 = data[1];

	sc_bv<36> complete_data;
	complete_data.range(17,0) = data[0];
	complete_data.range(35,18) = data[1];

	//cout << "TB CRC DATA " << complete_data.to_string(SC_HEX) << endl;

	//Do the two passes 
	for(int n = 0; n < 2; n++){
		//- taken exactly from the HT spec (10.1.1)
		for(int i = 0; i < 18; i++){
			int tmp = crc >> 31; /* store highest bit */
			crc = (crc << 1) | ((data[n] >> i) & 1); /* shift message in */
			crc = (tmp) ? crc ^ poly : crc; /* substract poly if greater */
		}
	}
}


void link_l2_tb::manage_rx_transmission(){
	while(true){
		if(reset_rx_connection){
			transmitter->send_initial_value(5);
			transmitter->send_init_sequence(0,0);
			reset_rx_connection = false;
		}
		if(!transmit_rx_queue.empty()){
			transmitter->send_dword_link(
				transmit_rx_queue.front().dword,
				transmit_rx_queue.front().lctl,
				transmit_rx_queue.front().hctl,
				transmit_rx_queue.front().error);
			transmit_rx_queue.pop();
		}
		else
			wait();
	}
}


void link_l2_tb::validate_rx_reception(){
	while(true){
		wait();
		//Test reception of data
		if(lk_available_cd.read() && check_rx_dword_reception){
			verify(!(expected_rx_queue.empty()),
				"RX : Unexpected data reception");
			if(!expected_rx_queue.empty()){
				LinkTransmission t = expected_rx_queue.front();

				/*cout << "RX Data in front : L=" << t.lctl << " H=" <<
					t.hctl << " D=" << t.dword.to_string(SC_HEX) << "  Number: " << rx_number++ << endl;
				cout << "RX Data received : L=" << lk_lctl_cd.read() << " H=" <<
					lk_hctl_cd.read() << " D=" << lk_dword_cd.read().to_string(SC_HEX) << endl;*/

				expected_rx_queue.pop();

				verify((t.dword == lk_dword_cd.read() &&
						t.lctl == lk_lctl_cd.read() &&
						t.hctl == lk_hctl_cd.read()),
					"RX Invalid data received");
			}
		}
	}

}
