// cd_mux_l3.h

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

#ifndef CD_MUX_L3_H
#define CD_MUX_L3_H

#include "../core_synth/synth_datatypes.h"
#include "../core_synth/constants.h"

///A 2 input packet multiplexer
/**
	@class cd_mux_l3
	@description Selects which of the two input control packets
	will be propagated to the output
*/
class cd_mux_l3 : public sc_module
{	
public:

	//*******************************
	//	Inputs
	//*******************************

	///Input selection bit
	sc_in< bool >		select;
	///Input 0 of the mux
	sc_in< syn_ControlPacketComplete >	ctlPacket0;
	///Input 1 of the mux
	sc_in< syn_ControlPacketComplete >	ctlPacket1;


	//*******************************
	//	Outputs
	//*******************************

	///Multiplexed output
	sc_out< syn_ControlPacketComplete >	cd_packet_ro;


	/**
		Multiplexing process, sensitive on both the inputs and 
		the selection bit
	*/
	void selection();

	SC_HAS_PROCESS(cd_mux_l3);

	/**
		SystemC Macro
		Module constructor
	*/
	cd_mux_l3(sc_module_name name);
};

#endif
