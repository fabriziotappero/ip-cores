//fairness_l3.h

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
 *   Martin Corriveau
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

#ifndef FAIRNESS_L3_H
#define FAIRNESS_L3_H

#include "../core_synth/synth_datatypes.h"	

///Fairness algorithm for local HyperTransport packets insertion
/**
	@description
	This module implements the fairness priority algorithm needed to ensure
	that the bandwith of the link is rightfully shared between all the
	elements of the chain.  The implementation of this design
	is fairly well described in the section 4.9.5 - "Fairness and
	Forward Progress" of the HT specification.

	@author Ami Castonguay
*/
class fairness_l3 : public sc_module {

	///series of 3-bit counters
	/** 32 counters : one for every unitID.  When a packet is forwarded, the counter
		associated with that unitID is incremented*/
	sc_signal<sc_uint<3> > forward_tracker[32];

	///8-bit counter counting the total of packets sent
	sc_signal<sc_uint<8> > forward_count;

	///Captured value of ::forward_count when a ::forward_tracker overflows
	sc_signal<sc_uint<8> > denominator;

	///Window register to find when to send local packets
	sc_signal<sc_uint<6> > window;

	///A linear feedback shift register to make the insertion rate non-integral
	sc_signal<sc_uint<9> > lfsr;

    sc_signal <bool> last_fwd_ack_ro;
    sc_signal <bool> last_ro_packet_fwd_chain;
    sc_signal <sc_uint<5> > last_ro_packet_fwd_unitid;

public:

	/// The Clock
	sc_in<bool> clk;
	/// Reset signal
	sc_in<bool> resetx;

	
	//If there is a packet to be sent from the reordering from the other side
	sc_in <bool> ro_available_fwd;
	///The packet to sent
    sc_in <syn_ControlPacketComplete > ro_packet_fwd;
	///To acknoledge that the packet has been consumed
    sc_in <bool> fwd_ack_ro;


	///If the local side has priority
	sc_out<bool> local_priority;

	///If a local packet is issued (can be sent or reserved to send when buffers available)
	sc_in<bool> local_packet_issued;

	///SystemC Macro
	SC_HAS_PROCESS(fairness_l3);

	///Module constructor
	fairness_l3(sc_module_name name);

	///All events that can be treated synchrounously
	void clocked_process();
};

#endif

