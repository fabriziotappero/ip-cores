//chain_marker_l4.h
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
 *   Laurent Aubray
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

#include "../core_synth/synth_datatypes.h"
#include "../core_synth/constants.h"

#ifndef CHAIN_MARKER_L4_H
#define CHAIN_MARKER_L4_H

/// Probes the input packet of a VC and determines if it is part of a chain
/** Only used in Posted Channel,Tag packets which belongs to a chain */
class chain_marker_l4: public sc_module
{
private:
	/// = 1 if we are receiving a chain
	/** This signal is equal to the chain bit of the incoming packet.*/
	sc_signal<bool> isReceivingChain;

public:

	/// The clock
	sc_in<bool> clk;
	// Reset Signals
	/** Warm_Reset and Cold_Reset does the same thing*/
	sc_in<bool> resetx;

	/// Input packet
	sc_in<bool> in_packet_chain;
	/// Indicates if a packet is available on the In_Packet signal
	sc_in<bool> in_packet_destination[2];

	/// Output packet
	/** The packet is marked if it is part of a chain*/
	sc_out<bool > input_packet_partofchain;

	/// Marks packets that are part of a chain
	/** a packet is part of a chain if the Chain bit =1 or if Chain bit = 0 and it
	is the last of the chain. This later state is determined by checking the isReceivingChain
	signal.*/
	void chainMarking(void);
	/// Determines if the next packet will also be part of a chain
	/** This is done by setting or clearing isReceivingChain*/
	void stateMachine(void);

	///SystemC Macro
	SC_HAS_PROCESS(chain_marker_l4);

	/// Main Constructor
	chain_marker_l4(sc_module_name name);
};


#endif

