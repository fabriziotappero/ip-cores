//link_frame_tx_l3_tb.cpp
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

#include <cstdlib>

#include "link_frame_tx_l3_tb.h"
#include "../../core/require.h"

using namespace std;

link_frame_tx_l3_tb::link_frame_tx_l3_tb(sc_module_name name): sc_module(name){
	SC_THREAD(stimulate_inputs);
	sensitive_pos	<<	clk;

	validator = new link_tx_validator("link_tx_validator");

	validator->clk(clk);

	validator->lk_ctl_phy(lk_ctl_phy);
	for(int n = 0; n < CAD_OUT_WIDTH; n++){
		validator->lk_cad_phy[n](lk_cad_phy[n]);
	}

	validator->tx_consume_data(tx_consume_data);

	validator->phy_consume_lk(phy_consume_lk);
	validator->cad_to_frame(cad_to_frame);
	validator->lctl_to_frame(lctl_to_frame);
	validator->hctl_to_frame(hctl_to_frame);
}

void link_frame_tx_l3_tb::init(){
	cout << "TB Init" << endl;

	csr_tx_link_width_lk = "000";
	validator->bit_width = 8;
	if(validator->bit_width > CAD_OUT_WIDTH) validator->bit_width = CAD_OUT_WIDTH;

	csr_end_of_chain = false;

	///Link commands a ltdstop disconnect
	ldtstop_disconnect_tx = false;
	rx_waiting_for_ctl_tx = false;


	resetx = false;
	pwrok = false;
	ldtstopx = false;


#ifdef RETRY_MODE_ENABLED
	///The flow control asks us to disconnect the link
	fc_disconnect_lk = false;
#endif

	validator->expect_tx_consume_data = 0;
	srand(389);
}

void link_frame_tx_l3_tb::stimulate_inputs(){
	cout << "TB Stimulate inputs" << endl;
	init();

	for(int n = 0; n < 5; n++) wait();

	//Enable power
	pwrok = true;
	ldtstopx = true;

	for(int n = 0; n < 5; n++) wait();

	//End reset
	resetx = true;

	cout << "Test connection 8 BIT" << endl;
	cout << "TB: Wait for connection" << endl;

	int max_count = 4300/CAD_OUT_DEPTH;

	//Give a first dword before being connected so that it's ready when
	//the link gets connected
	link_tx_validator::LinkTransmission_TX t;
	t.dword = "0x9812ABF4";
	t.lctl = true;
	t.hctl = true;
	validator->expected_transmission.push(t);
	validator->to_transmit.push(t);

	//Wait until the validator says that we are in the normal RUN mode(init is done)
	while(validator->state != link_tx_validator::LinkTBState_RUN){
		max_count--;
		if(max_count == 0)
			cout << "*** ERROR: Link didn't initialize" << endl;
		wait();
	}
	cout << "TB: Connection established" << endl;


	t.dword = "0x94FF32D2";
	t.lctl = true;
	t.hctl = false;
	validator->expected_transmission.push(t);
	validator->to_transmit.push(t);

	t.dword = "0x9DE3AC01";
	t.lctl = false;
	t.hctl = true;
	validator->expected_transmission.push(t);
	validator->to_transmit.push(t);

	validator->expect_tx_consume_data = 50;

	//We are testing for an 8 bit link width, so if link is initialized
	//with full width, it should take 3 cycles to send 3 dwords.  If
	//the link is 4 bits, it will take 6 cycles, and if 2 it will take
	//12 cycles.  The formula is simple : 24/width.  If the link is
	//smaller than 8 bits, there will be an additional delay for the first
	//packet to be output, hence the added 8/width - 1 cycles.
	for(int n = 32 / validator->bit_width - 1; n > 0; n--){
		wait();
	}

	validator->expect_tx_consume_data = -20;
	resetx = false;
	validator->state = link_tx_validator::LinkTBState_INACTIVE;

	for(int n = 0; n < 5; n++) wait();

	csr_tx_link_width_lk = "101";
	validator->bit_width = 4;
	//End reset
	resetx = true;

	cout << "Test connection 4 BIT" << endl;
	cout << "TB: Wait for connection" << endl;

	max_count = 4300/CAD_OUT_DEPTH;

	t.dword = "0x9812ABF4";
	t.lctl = true;
	t.hctl = true;
	validator->expected_transmission.push(t);
	validator->to_transmit.push(t);

	while(validator->state != link_tx_validator::LinkTBState_RUN){
		max_count--;
		if(max_count == 0)
			cout << "*** ERROR: Link didn't initialize" << endl;
		wait();
	}
	cout << "TB: Connection established" << endl;


	t.dword = "0x94FF32D2";
	t.lctl = true;
	t.hctl = false;
	validator->expected_transmission.push(t);
	validator->to_transmit.push(t);

	t.dword = "0x9DE3AC01";
	t.lctl = false;
	t.hctl = true;
	validator->expected_transmission.push(t);
	validator->to_transmit.push(t);

	validator->expect_tx_consume_data = 50;

	//Same as before
	for(int n = 32 / validator->bit_width - 1; n > 0; n--){
		wait();
	}

	validator->expect_tx_consume_data = -20;
	resetx = false;
	validator->state = link_tx_validator::LinkTBState_INACTIVE;

	for(int n = 0; n < 5; n++) wait();

	csr_tx_link_width_lk = "100";
	validator->bit_width = 2;
	//End reset
	resetx = true;

	cout << "Test connection 2 BIT" << endl;
	cout << "TB: Wait for connection" << endl;

	max_count = 4300/CAD_OUT_DEPTH;

	t.dword = "0x9812ABF4";
	t.lctl = true;
	t.hctl = true;
	validator->expected_transmission.push(t);
	validator->to_transmit.push(t);

	while(validator->state != link_tx_validator::LinkTBState_RUN){
		max_count--;
		if(max_count == 0)
			cout << "*** ERROR: Link didn't initialize" << endl;
		wait();
	}
	cout << "TB: Connection established" << endl;


	t.dword = "0x94FF32D2";
	t.lctl = true;
	t.hctl = false;
	validator->expected_transmission.push(t);
	validator->to_transmit.push(t);

	t.dword = "0x9DE3AC01";
	t.lctl = false;
	t.hctl = true;
	validator->expected_transmission.push(t);
	validator->to_transmit.push(t);

	validator->expect_tx_consume_data = 50;

	//Same as before
	for(int n = 32 / validator->bit_width - 1; n > 0; n--){
		wait();
	}

	validator->expect_tx_consume_data = -20;
	resetx = false;
	validator->state = link_tx_validator::LinkTBState_INACTIVE;

	while(true) wait();

}


