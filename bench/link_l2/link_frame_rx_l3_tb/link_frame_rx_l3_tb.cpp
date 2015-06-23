//link_fram_rx_l3_tb.cpp
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

#include "link_frame_rx_l3_tb.h"
#include "../../core/require.h"
#include "link_rx_transmitter.h"

#include <sstream>
#include <string>

using namespace std;

link_frame_rx_l3_tb::link_frame_rx_l3_tb(sc_module_name name): sc_module(name){
	SC_THREAD(stimulate_inputs);
	sensitive_pos	<<	clk;
	SC_THREAD(validate_outputs);
	sensitive_pos	<<	clk;

	///Create and link transmitter submodule
	transmitter = new link_rx_transmitter("link_rx_transmitter");
	transmitter->clk(clk);
	transmitter->phy_ctl_lk(phy_ctl_lk);
	for(int n = 0; n < CAD_IN_WIDTH; n++){
		transmitter->phy_cad_lk[n](phy_cad_lk[n]);
	}
	transmitter->phy_available_lk(phy_available_lk);
	transmitter->lk_deser_stall_phy(lk_deser_stall_phy);
	transmitter->lk_deser_stall_cycles_phy(lk_deser_stall_cycles_phy);
}


link_frame_rx_l3_tb::~link_frame_rx_l3_tb(){ delete transmitter;}

void link_frame_rx_l3_tb::init(){

	/**
		Not much to understand here, just init misc variables
		to an initial state to start new.  You'll notice that
		reset is asserted and pwrok is de-asserted, meaning
		that this is a cold reset and re-initializes the RX
		part of the link.
	*/

	phy_ctl_lk = sc_uint<CAD_IN_DEPTH>(0);
	for(int n = 0; n < CAD_IN_WIDTH; n++){
		phy_cad_lk[n] = sc_uint<CAD_IN_DEPTH>(0);
	}
	phy_available_lk = true;

	resetx = false;
	pwrok = false;
	ldtstopx = false;

	/**
	Link widths
	
	000 8 bits 
	100 2 bits 
	101 4 bits 
	111  Link physically not connected 
	@{
	*/
	csr_rx_link_width_lk = "000";

	csr_end_of_chain = false;
	csr_sync = false;
	csr_extended_ctl_timeout_lk = false;

#ifdef RETRY_MODE_ENABLED
	///If we are in retry mode
	csr_retry = false;
	///Command decoder commands a retry disconnect
	cd_initiate_retry_disconnect = false;
#endif
	

	expect_connected = 0;
	expect_disable_receivers_phy = 0;

	expect_link_width_update = 0;
	expected_link_width = "000";

	expect_link_failure = 0;

	check_dword_reception = true;


}

void link_frame_rx_l3_tb::stimulate_inputs(){
	/////////////////////////////////////////////
	// Test link failure
	/////////////////////////////////////////////

	phy_ctl_lk = sc_uint<CAD_IN_DEPTH>(0);
	for(int n = 0; n < CAD_IN_WIDTH; n++){
		phy_cad_lk[n] = sc_uint<CAD_IN_DEPTH>(0);
	}

	phy_available_lk = true;
	resetx = false;
	pwrok = false;
	expect_connected = -4;

	for(int n = 0; n < 5; n++)
		wait();

	resetx = true;
	pwrok = true;
	expect_link_failure = 5;
	expect_link_width_update = 0;

	for(int n = 0; n < 5; n++)
		wait();

	///////////////////////////////////////
	// Do a normal valid cold reset
	///////////////////////////////////////

	cout << "Entered stimulate_inputs" << endl;
	init();
	expect_link_failure = 0;
	cout << "Init done" << endl;

	cout << "Cold reset" << endl;
	//Keep the cold reset
	for(int n = 0; n < 2; n++){
		wait();
	}

	//Clock from other node starts running
	phy_available_lk = true;

	//Keep the cold reset
	for(int n = 0; n < 4; n++){
		wait();
	}

	//Power is stable
	pwrok = true;
	//Not in ldtstop sequence
	ldtstopx = true;


	transmitter->send_initial_value(4);
	

	/////////////////////////////////////////////
	// Test normal 8 bit behavious, offset 1/3
	/////////////////////////////////////////////

	//End cold reset
	expect_link_width_update = 4;
	expected_link_width = "000";
	resetx = true;

	cout << "Init sequence" << endl;
	transmitter->send_init_sequence(1,3);
	expect_connected = 16;

	cout << "Data transmission" << endl;

	LinkTransmission transmit;
	transmit.dword = "0xA417F05B";
	transmit.lctl = true;
	transmit.hctl = true;

	expected_transmission.push(transmit);
	transmitter->send_dword_link(transmit.dword,transmit.lctl,transmit.hctl);

	transmit.dword = "0x11112222";
	transmit.lctl = true;
	transmit.hctl = false;

	expected_transmission.push(transmit);
	transmitter->send_dword_link(transmit.dword,transmit.lctl,transmit.hctl);

	transmit.dword = "0xFFBB3388";
	transmit.lctl = false;
	transmit.hctl = true;

	expected_transmission.push(transmit);
	transmitter->send_dword_link(transmit.dword,transmit.lctl,transmit.hctl);

	transmit.dword = "0x00000000";
	transmit.lctl = false;
	transmit.hctl = false;

	transmitter->send_dword_link(transmit.dword,transmit.lctl,transmit.hctl);

	for(int n = 0; n < 5; n++){
		wait();
	}

	resetx = false;
	expect_connected = -4;

	for(int n = 0; n < 5; n++){
		wait();
	}

	/////////////////////////////////////////////
	// Test normal 8 bit behavious, offset 0/0
	/////////////////////////////////////////////
	resetx = true;

	transmitter->send_init_sequence(0,0);
	expect_connected = 16;

	cout << "Data transmission" << endl;

	transmit.dword = "0xABCDEF01";
	transmit.lctl = true;
	transmit.hctl = true;

	expected_transmission.push(transmit);
	transmitter->send_dword_link(transmit.dword,transmit.lctl,transmit.hctl);

	transmit.dword = "0x55336644";
	transmit.lctl = true;
	transmit.hctl = false;

	expected_transmission.push(transmit);
	transmitter->send_dword_link(transmit.dword,transmit.lctl,transmit.hctl);


	for(int n = 0; n < 5; n++)
		wait();


	////////////////////////////////////////////////////////////////
	// Testing LDTSTOP
	////////////////////////////////////////////////////////////////
	cout << "Testing LDTSTOP" << endl;

	check_dword_reception = false;

	expect_connected = -4;
	expect_disable_receivers_phy = 6;
	ldtstopx = false;
	ldtstop_disconnect_rx = true;

	transmit.dword = "0x00000000";
	transmit.lctl = false;
	transmit.hctl = false;
	for(int n = 0; n < 4; n++)
		transmitter->send_dword_link(transmit.dword,transmit.lctl,transmit.hctl);

	ldtstopx = true;
	ldtstop_disconnect_rx = false;

	expect_disable_receivers_phy = -210;
	transmitter->send_initial_value(210);
	expect_connected = 210;

	transmitter->send_init_sequence(0,0);

	transmit.dword = "0xABCDEF01";
	transmit.lctl = true;
	transmit.hctl = true;


	transmitter->send_dword_link(transmit.dword,transmit.lctl,transmit.hctl);



	for(int n = 0; n < 5; n++)
		wait();

	////////////////////////////////////////////////////////////////
	// Testing protocol error (invalid CTL transition)
	////////////////////////////////////////////////////////////////
	cout << "Testing protocol error" << endl;


	sc_bv<CAD_IN_DEPTH> phy_ctl_lk_buf;
	for(int n = 0; n < CAD_IN_DEPTH; n++){
		phy_ctl_lk_buf[n] = (bool)(n % 2);
	}
	phy_ctl_lk = phy_ctl_lk_buf;

	phy_available_lk = true;
	expect_ctl_transition_error = 5;
	wait();

	transmit.dword = "0x00000000";
	transmit.lctl = true;
	transmit.hctl = true;
	for(int n = 0; n < 5; n++)
		transmitter->send_dword_link(transmit.dword,transmit.lctl,transmit.hctl);

	expect_ctl_transition_error = 0;

	resetx = false;
	expect_connected = -4;

	for(int n = 0; n < 5; n++){
		wait();
	}


	////////////////////////////////////////////////////////////////
	// Testing protocol error (invalid CTL transition) because of reset
	////////////////////////////////////////////////////////////////
	cout << "Testing protocol error because of reset" << endl;

	resetx = true;

	transmitter->send_init_sequence(0,0);
	expect_connected = 16;

	phy_ctl_lk_buf[0] = true;
	for(int n = 1; n < CAD_IN_DEPTH; n++){
		phy_ctl_lk_buf[n] = false;
	}
	phy_ctl_lk = phy_ctl_lk_buf;

	phy_available_lk = true;
	wait();

	expect_connected = -10;

	//Like reset signal
	transmit.dword = "0x00000000";
	transmit.lctl = false;
	transmit.hctl = false;
	for(int n = 0; n < 2; n++)
		transmitter->send_dword_link(transmit.dword,transmit.lctl,transmit.hctl);

	resetx = false;
	for(int n = 0; n < 5; n++){
		wait();
	}

	////////////////////////////////////////////////////////////////
	// Testing Retry mode disconnect from CD
	////////////////////////////////////////////////////////////////

	////////////////////////////////////////////////////////////////
	// Testing Retry mode with protocol error
	////////////////////////////////////////////////////////////////
	cout << "Testing protocol error with retry" << endl;

	resetx = true;
	csr_retry = true;

	transmitter->send_init_sequence(0,0);
	expect_connected = 16;
	for(int n = 0; n < CAD_IN_DEPTH; n++){
		phy_ctl_lk_buf[n] = (bool)(n % 2);
	}
	phy_ctl_lk = phy_ctl_lk_buf;

	phy_available_lk = true;
	expect_ctl_transition_error = 5;
	expect_lk_initiate_retry_disconnect = 5;
	wait();

	transmit.dword = "0x00000000";
	transmit.lctl = true;
	transmit.hctl = true;
	for(int n = 0; n < 3; n++)
		transmitter->send_dword_link(transmit.dword,transmit.lctl,transmit.hctl);
	
	expect_ctl_transition_error = 0;

	resetx = false;
	expect_connected = -4;

	for(int n = 0; n < 5; n++){
		wait();
	}

	////////////////////////////////////////////////////////////////
	// Done
	////////////////////////////////////////////////////////////////
	cout << "Link testbench done" << endl;

	while(true)
		wait();
		
}



void link_frame_rx_l3_tb::validate_outputs(){
	while(true){
		wait();

		//Test correctness of lk_rx_connected
		if(!expect_connected) verify(
			lk_rx_connected.read() == false,"Link should not be connected yet");
		else if(expect_connected > 0){
			verify(!(expect_connected == 1 && lk_rx_connected.read() == false),
				"Link failed to connect");
			if(!lk_rx_connected.read()) expect_connected--;
			else(expect_connected = 1);
		}
		else{
			verify(!(expect_connected == -1 && lk_rx_connected.read() == true),
				"Link failed to disconnect");
			if(lk_rx_connected.read()) expect_connected++;
			else expect_connected = 0;
		}

		//Test correctness of lk_disable_receivers_phy
		if(!expect_disable_receivers_phy) verify(
			lk_disable_receivers_phy.read() == false,"Link should not be disabled yet");
		else if(expect_disable_receivers_phy > 0){
			verify(!(expect_disable_receivers_phy == 1 && lk_disable_receivers_phy.read() == false),
				"Link failed to disable");
			if(!lk_disable_receivers_phy.read()) expect_disable_receivers_phy--;
			else(expect_disable_receivers_phy = 1);
		}
		else{
			verify(!(expect_disable_receivers_phy == -1 && lk_disable_receivers_phy.read() == true),
				"Link failed to re-enable");
			if(lk_disable_receivers_phy.read()) expect_disable_receivers_phy++;
			else expect_disable_receivers_phy = 0;
		}

		//Test correctness of lk_update_link_width_csr
		if(!lk_link_failure_csr.read()){
			if(!expect_link_width_update) verify(
				lk_update_link_width_csr.read() == false,"Unexpected update of link width");
			else {
				verify(!(expect_link_width_update == 1 && lk_update_link_width_csr.read() == false),
					"Link failed to update link width");
				if(!lk_update_link_width_csr.read()) expect_link_width_update--;
				else{
					ostringstream o;
					o << "Invalid updated link width value, Expected: " << expected_link_width << 
						" Received: " << lk_sampled_link_width_csr.read();
					verify(expected_link_width == lk_sampled_link_width_csr.read(),
						o.str().c_str());
					(expect_link_width_update = 0);
				}
			}
		}

		//Test correctness of lk_link_failure_csr
		if(!expect_link_failure) 
			verify(lk_link_failure_csr.read() == false,"Unexpected link failure");
		else{
			verify(!(expect_link_failure == 1 && lk_link_failure_csr.read() == false),
				"Link failed to fail : the link was supposed to fail and didn't");
			if(!lk_link_failure_csr.read()) expect_link_failure--;
			//else(expect_link_failure = 0);
		}

		//Test correctness of ctl_transition_error
		if(!expect_ctl_transition_error) 
			verify(ctl_transition_error.read() == false,"Unexpected ctl transition error");
		else{
			verify(!(expect_ctl_transition_error == 1 && ctl_transition_error.read() == false),
				"Link failed produce CTL error when it should have");
			if(!ctl_transition_error.read()) expect_ctl_transition_error--;
		}

		//Test correctness of lk_initiate_retry_disconnect
		if(!expect_lk_initiate_retry_disconnect) 
			verify(lk_initiate_retry_disconnect.read() == false,"Unexpected retry sequence initiated");
		else{
			verify(!(expect_lk_initiate_retry_disconnect == 1 && lk_initiate_retry_disconnect.read() == false),
				"Link failed to initiate retry sequence when it should have");
			if(!lk_initiate_retry_disconnect.read()) expect_lk_initiate_retry_disconnect--;
			else(expect_lk_initiate_retry_disconnect = 0);
		}
		

		//Test reception of data
		if(framed_data_available.read() && check_dword_reception){
			verify(!(expected_transmission.empty()),
				"Unexpected data reception");
			if(!expected_transmission.empty()){
				LinkTransmission t = expected_transmission.front();

				cout << "Data in front : L=" << t.lctl << " H=" <<
					t.hctl << " D=" << t.dword.to_string(SC_HEX) << endl;
				cout << "Data received : L=" << framed_lctl.read() << " H=" <<
					framed_hctl.read() << " D=" << framed_cad.read().to_string(SC_HEX) << endl;

				expected_transmission.pop();

				verify((t.dword == framed_cad.read() &&
						t.lctl == framed_lctl.read() &&
						t.hctl == framed_hctl.read()),
					"Invalid data received");
			}
		}
	}
}

