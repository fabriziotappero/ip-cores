//link_tx_validator.cpp
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
#include "link_tx_validator.h"
#include "../../core/require.h"

using namespace std;

link_tx_validator::link_tx_validator(sc_module_name name) : sc_module(name){
	SC_THREAD(validate_outputs);
	sensitive_pos(clk);
	SC_THREAD(send_data);
	sensitive_pos(clk);

	reset();
}

void link_tx_validator::reset(){
	counter = 0;
	expect_tx_consume_data = 0;
	state = LinkTBState_INACTIVE;
	bit_width = 8;
	checking_errors = true;
}


void link_tx_validator::validate_outputs(){
	phy_consume_lk = false;
	while(true){
		wait();

		//Don't always read in a random manner
		bool phy_read = (rand()/((float)RAND_MAX) ) < 0.9;
		phy_consume_lk = phy_read;

		//Update the output when the last output was read
		if(phy_consume_lk.read()){
			//By default, continuously increment the counter
			counter++;

			/**
				State machine
			*/
			switch(state){
			case LinkTBState_INACTIVE:
				/**
					When CTL is active, go to next init phase
				*/
				if((sc_bit)lk_ctl_phy.read()[0]){
					state = LinkTBState_CTL_ACTIVE;
					counter = 0;
				}
				break;
			case LinkTBState_CTL_ACTIVE:
				//When CTL goes back to zero, go to next init phase
				if(!(sc_bit)lk_ctl_phy.read()[0]){

					//Check if this part of the sequence was sufficiently long
					if(counter < (128/(bit_width*CAD_OUT_DEPTH))){
						cout << "ERROR : CTL disabled too fast during sequence" << endl;
					}

					state = LinkTBState_SYNC;
					counter = 0;
				}
				break;
			case LinkTBState_SYNC:
				//When CAD becomes one, go to last init phase
				if((sc_bit)lk_cad_phy[0].read()[0]){
					if(counter < (4096/(bit_width*CAD_OUT_DEPTH))){
						cout << "ERROR : CAD enabled too fast during sequence" << endl;
					}
					if(bit_width * CAD_OUT_DEPTH == 8 && (counter % 4 != 0) ||
						bit_width * CAD_OUT_DEPTH == 16 && (counter % 2 != 0)){
						cout << "ERROR : CAD & CTL not disabled for a correct multiple of cycles" << endl;
					}

					state = LinkTBState_PRERUN;
					counter = 1;
				}

				//Go directly to the next state if we detect CAD high
				if(state != LinkTBState_PRERUN)
					break;
			case LinkTBState_PRERUN:
				{
					/**
						Check that CTL bits are always 1 and that CAD
						bit are all 0
					*/
					bool error_ctl = false;
					bool error_cad = false;

					for(int n = 0; n < CAD_OUT_DEPTH; n++){
						if((sc_bit)lk_ctl_phy.read()[n]) error_ctl = true;

						for(int i = 0; i < bit_width; i++){
							if(!(sc_bit)lk_cad_phy[i].read()[n]){
								error_cad = true;
							}
						}
					}
					if(error_ctl)
						cout << "ERROR: Wrong CTL value on last phase" << endl;
					if(error_cad)
						cout << "ERROR: Wrong CAD value on last phase" << endl;
				}

				//When a full dword is received, go to normal operation
				if(counter == (32/(bit_width*CAD_OUT_DEPTH))){
					state = LinkTBState_RUN;
					counter = 0;
				}

				break;
			case LinkTBState_RUN:
				//The number of bits received per clock cycle is the width of
				//link multiplied by the deserialization factor (depth)
				int number_of_bits = bit_width * CAD_OUT_DEPTH;


				//Shift CAD and CTL values in
				cad_output = cad_output >> number_of_bits;
				ctl_output = ctl_output >> CAD_OUT_DEPTH;

				for(int n = 0; n < CAD_OUT_DEPTH; n++){
					for(int i = 0; i < bit_width; i++){
						cad_output[32-(bit_width * CAD_OUT_DEPTH) + n * bit_width + i]
							= (sc_bit)lk_cad_phy[i].read()[n];
					}
				}

				ctl_output.range(15,16-CAD_OUT_DEPTH) = lk_ctl_phy.read();

				//When we reveived a complete dword
				if(counter == 32/number_of_bits){
					bool lctl = (sc_bit)ctl_output[15-16/bit_width];
					bool hctl = (sc_bit)ctl_output[15];

					//Verify that all CTL values are identical for LCTL
					int first_pos = 16 - 32/bit_width;
					for(int n = first_pos + 1; n < 16-16/bit_width; n++){
						if(ctl_output[n] != ctl_output[first_pos])
							cout << "ERROR : Invalid CTL transition" << endl;
					}

					//Verify that all CTL values are identical for HCTL
					first_pos = 16 - 16/bit_width;
					for(int n = first_pos + 1; n < 16; n++){
						if(ctl_output[n] != ctl_output[first_pos])
							cout << "ERROR : Invalid CTL transition" << endl;
					}

					//Check if what was received is correct
					counter = 0;
					if(expected_transmission.empty()){
						if(checking_errors){
							cout << "TX ERROR:Unexpected data received : L=" << lctl << " H=" <<
								hctl << " D=" << cad_output.to_string(SC_HEX) << endl;
						}
					}
					else{
						LinkTransmission_TX t = expected_transmission.front();
						expected_transmission.pop();

						if(checking_errors){
							verify(t.dword == cad_output &&
								t.lctl == lctl &&
								t.hctl == hctl,
								"TX ERROR: Invalid data received");
						}
					}
				}

				break;
			}
			//Test correctness of tx_consume_data
			if(checking_errors){
				if(!expect_tx_consume_data) verify(
					tx_consume_data.read() == false,"Link should not be accepting data");
				else if(expect_tx_consume_data > 0){
					verify(!(expect_tx_consume_data == 1 && tx_consume_data.read() == false),
						"TX: Link failed read data");
					if(!tx_consume_data.read() && phy_read) expect_tx_consume_data--;
					if(tx_consume_data.read()) expect_tx_consume_data = 20;
				}
				else{
					expect_tx_consume_data++;
				}
			}
		}
	}
}

void link_tx_validator::send_data(){
	while(true){
		//When the data to transmit is sent, pop it from queue
		if(tx_consume_data.read() && !to_transmit.empty())
			to_transmit.pop();

		//If empty, send a default value
		if(to_transmit.empty()){
			cad_to_frame = 0;
			lctl_to_frame = false;
			hctl_to_frame = false;
		}
		//Otherwise send what is on the front of the queue
		else{
			LinkTransmission_TX t = to_transmit.front();
			cad_to_frame = t.dword;
			lctl_to_frame = t.lctl;
			hctl_to_frame = t.hctl;
		}
		wait();
	}
	
}
