// cd_history_rx_l3.h

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
 *   Max-Elie Salomon
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

#ifndef CD_HISTORY_RX_L3_H
#define CD_HISTORY_RX_L3_H

#include "../core_synth/synth_datatypes.h"
#include "../core_synth/constants.h"

///History counter sub-module for the decoder module
/**
	@class cd_history_rx_l3
	@description Counts the number of control packets that have
	been received since last reset.  This value can then be sent
	by the flow control in the nop packets to confirm that packets
	have correctly been received.  This lets the next HT link know
	where to replay the history after a retry disconnect.
	@author Max-Elie Salomon

*/

class cd_history_rx_l3 : public sc_module
{	

public:

	//*******************************
	//	Inputs
	//*******************************

	///Clock to synchronize module
	sc_in< bool > clk;
	///Reset signal (active low)
	sc_in< bool > resetx;
	///Enables the count to be incremented
	sc_in< bool > incrCnt;

	//*******************************
	//	Outputs
	//*******************************

	///History of received packets count
	sc_out< sc_uint<8> >	cd_rx_next_pkt_to_ack_fc;

	/**
		Counting process, clock sensitive
	*/
	void clocked_count_process();

	///SystemC Macro
	SC_HAS_PROCESS(cd_history_rx_l3);

	///Module constructor
	cd_history_rx_l3(sc_module_name name);
};

#endif
