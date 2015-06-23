//link_tx_validator.h
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

#ifndef LINK_TX_VALIDATOR_H
#define LINK_TX_VALIDATOR_H

#include <queue>
#include "../../../rtl/systemc/core_synth/synth_datatypes.h"
#include "../../../rtl/systemc/core_synth/constants.h"


///Verfies what is sent by TX part of the link to check it is correct
class link_tx_validator : public sc_module{
public:
	///struct regrouping dword and CTL values to send on link
	struct LinkTransmission_TX{
		sc_bv<32>	dword;
		bool		lctl;
		bool		hctl;
	};

	///Possible values of the state of the link for the testbenches
	enum LinkTBState {
		LinkTBState_INACTIVE,///<Warm reset signaling
		LinkTBState_CTL_ACTIVE,///<CTL has been activated
		LinkTBState_SYNC,///<CTL returns to 0
		LinkTBState_PRERUN,///<Last dword of init before starting normal operation
		LinkTBState_RUN///<Normal operation of the link
	};

	///Main clock of the system
	sc_in<bool >		clk;

	///CTL sent by the link
	sc_in<sc_bv<CAD_OUT_DEPTH> >	lk_ctl_phy;
	///CAD sent by the link
	sc_in<sc_bv<CAD_OUT_DEPTH> >	lk_cad_phy[CAD_OUT_WIDTH];
	///If we consume the CTL and CAD signals
	sc_out<bool>		phy_consume_lk;

	///If the data to frame sent to the TX is consumed
	sc_in<bool>		tx_consume_data;
	///Data to frame and to sent on the link
	sc_out<sc_bv<32> >	cad_to_frame;
	///LCTL to grame and send on the link
	sc_out<bool>		lctl_to_frame;
	///HCTL to grame and send on the link
	sc_out<bool >		hctl_to_frame;

	///Current state of the link
	LinkTBState state;
	///Counter to keep track of how many cycles is spent in each init state
	int counter;
	///The width of the link
	int bit_width;

	///What we are expected to received from the TX
	std::queue< LinkTransmission_TX >	expected_transmission;
	///Next transmissions that we want to pass to the TX
	std::queue< LinkTransmission_TX >	to_transmit;

	///Framed version of what is sent on the link
	/**	When data is sent on the link, it is sent in a serialized
		way.  If the link width is smaller than the physical width,
		then it might take multiple cycles to deserialize a full dword.
		Intermediate result is stored in this variable.  New data is
		shifter from the left into the vector as it arrives.
	*/
	sc_bv<32>	cad_output;
	///Framed version of the CTL that is sent on the link See ::cad_output
	sc_bv<16>	ctl_output;

	///If the TX part of the link is expected to consume data
	int expect_tx_consume_data;
	///If we are checking for invalid behavious and warning when it happens
	bool checking_errors;

	///SystemC Macro
	SC_HAS_PROCESS(link_tx_validator);

	///Constructor
	link_tx_validator(sc_module_name name);

	///Generates data that the TX link can send
	void send_data();

	///Verifies that the output of the TX link is correct
	void validate_outputs();

	///Sets internal state of this class to an initial value
	void reset();
};

#endif
