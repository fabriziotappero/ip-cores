// cd_nop_handler_l3.h

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

#ifndef CD_NOP_HANDLER_L3_H
#define CD_NOP_HANDLER_L3_H

#include "../core_synth/synth_datatypes.h"
#include "../core_synth/constants.h"

///NOP handler sub-module for the decoder module
/**
	@class cd_nop_handler_l3
	@definition Small modules that treats the information received
		by a nop, registers it and sends it to the flowcontrol
	@author Max-Elie Salomon
	        Ami Castonguay
  */

class cd_nop_handler_l3 : public sc_module
{

public:

	//*******************************
	//	Inputs
	//*******************************

	///Clock to synchronize module
	sc_in< bool > clk;
	///Reset signal (active low)
	sc_in< bool > resetx;

	///A nop is being received, store the count in the input vector
	sc_in< bool > setNopCnt;
	///Input bit vector
	sc_in< sc_bv<32> > lk_dword_cd;
	///Notify that the nop has been received
	/**
		This is not always the same as setNopCnt because in the retry mode,
		the nop CRC has to be received and validated before we notify that we
		have new data.
	*/
	sc_in< bool > send_nop_notification;

	//*******************************
	//	Outputs
	//*******************************

	///bits (19,8) of a received NOP packet, represents the freed buffers
	sc_out< sc_bv<12> > cd_nopinfo_fc;
	///A new nop has been received
	sc_out< bool >	cd_nop_received_fc;
#ifdef RETRY_MODE_ENABLED
	///The packet being acked with the nop, 
	sc_out< sc_uint<8> > cd_nop_ack_value_fc;
#endif

	///Synchronous process storing the nop values
	void handleNOP();

	///SystemC Macro
	SC_HAS_PROCESS(cd_nop_handler_l3);

	///Module constructor
	cd_nop_handler_l3(sc_module_name name);
};

#endif
