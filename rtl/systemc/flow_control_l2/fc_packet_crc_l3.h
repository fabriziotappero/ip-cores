//fc_packet_crc.h

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

#ifndef FC_PACKET_CRC_L3_H
#define FC_PACKET_CRC_L3_H

//The Poly used for the CRC32 encoding
#define CRC_ENCODER_POLY 0x04C11DB7

#include "../core_synth/synth_datatypes.h"
#include "../core_synth/constants.h"

///Caculates per packet CRC for packets being sent out
/**
	@author Ami Castonguay
*/
class fc_packet_crc_l3 : public sc_module
{	
public:

	//*******************************
	//	Inputs
	//*******************************
	///Clock to synchronize module
	sc_in < bool >			clk;
	///Reset to initialize module
	sc_in < bool >			resetx;

	///Bit vector being sent out to link - used to calculate CRC
	sc_in< sc_bv<32> > 		data_in;

	///Control bit sent to link - used to calculate CRC
	sc_in< bool > 			fc_hctl_lk;
	///Control bit sent to link - used to calculate CRC
	sc_in< bool > 			fc_lctl_lk;

	///When set, the CRC is calculated based on what is being sent to the link
	sc_in< bool >			calculate_crc;
	///When set, the nop CRC is calculated based on what is being sent to the link
	sc_in< bool >			calculate_nop_crc;
	///Clears the curent CRC value (to start a new packet)
	sc_in< bool >			clear_crc;
	///Clears the curent nop CRC value (to start a new packet)
	sc_in< bool >			clear_nop_crc;

	///Sent from CSR to force a stomp CRC (inverse of good CRC), it is a test mode
	sc_in<bool> csr_force_single_stomp_fc;
	///Sent from CSR to force a bad CRC, it is a test mode
	sc_in<bool> csr_force_single_error_fc;

	//*******************************
	//  CRC output signals
	//*******************************
	
	///Register that holds the CRC value
	sc_signal< sc_uint<32> >	crc_value;
	///Register that holds the nop CRC value
	sc_signal< sc_uint<32> >	nop_crc_value;

	///Output of the calculated CRC (usually inverse of crc_value)
	sc_out< sc_uint<32> >	crc_output;
	///Output of the calculated nop CRC (usually inverse of nop_crc_value)
	sc_out< sc_uint<32> >	nop_crc_output;

	///Generates the CRC outputs
	void clocked_process();

	///SystemC Macro
	SC_HAS_PROCESS(fc_packet_crc_l3);

	///Module constructor
	fc_packet_crc_l3(sc_module_name name);
};

#endif
