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

#include "chain_marker_l4.h"

chain_marker_l4::chain_marker_l4(sc_module_name name) : sc_module(name)
{
	SC_METHOD(chainMarking);
	sensitive << in_packet_chain << isReceivingChain << 
		in_packet_destination[0] << in_packet_destination[1];

	SC_METHOD(stateMachine);
	sensitive_neg << resetx;
	sensitive_pos << clk;
}


void chain_marker_l4::chainMarking(void)
{
	
	// If the packet has chain bit =1, we tag the packet as belonging to a chain.
	// If not but we are in "Chain mode" then we tag it anyway: the packet is the
	// last of the chain
	if (in_packet_chain.read() || isReceivingChain.read())
	{
		input_packet_partofchain = true;
	}
	else
		input_packet_partofchain = false;
}



// Clocked Process. Determines if we are receiving a chain.
void chain_marker_l4::stateMachine(void)
{
	if (!resetx.read())
		isReceivingChain = false;
	else
	{
		//If there is valid input packet
		if (in_packet_destination[0].read() ||
			in_packet_destination[1].read())
		{
			//If it is a chain, get in the ReceivingChain state so that
			//we tag the last packet of the chain correctly
			if (in_packet_chain.read())
				isReceivingChain = true;
			else
				// The only way to stop being in "chain send mode" is to receive the last packet
				// of the chain (and reset)
				isReceivingChain = false;
		} 
		/*
		else{
			isReceivingChain = isReceivingChain;
		}*/
	}
}

#ifndef SYSTEMC_SIM
#include "../core_synth/synth_control_packet.cpp"
#endif


