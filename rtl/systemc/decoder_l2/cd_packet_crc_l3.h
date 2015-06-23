// cd_packet_crc_l3.h

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

#ifndef CD_PACKET_CRC_L3_H
#define CD_PACKET_CRC_L3_H

#define CRC_DECODER_POLY 0x04C11DB7

#include "../core_synth/synth_datatypes.h"
#include "../core_synth/constants.h"

///Generates CRC values for CRC packets and compares them to what is received
/**
	@class cd_packet_crc_l3
	@description This generates the CRC values for the packets that are received to
	detect any errors when in retry mode.  Once the per-packet CRC is
	generated, it is then compared with the CRC sent with the packet.
	
	If the two values are identical, the received packet is (most likely)
	identical to what was sent.  If the CRC is the exact opposite of what
	it is supposed to be (all bits inversed), it means the packet is
	"stomped" and should simply be ignored.  If there is error other
	than the "stomped" case, it means there was an transmission error and
	we should attempt a retry sequence.
	
	The module can keep track of two CRC values, this is necessary because
	control packets can be inserted in a data packet.  Only one CRC value
	can be active at one time
	
	@author Ami Castonguay
*/

class cd_packet_crc_l3 : public sc_module
{	
public:

	//*******************************
	//	Inputs
	//*******************************
	///Clock to synchronize module
	sc_in < bool >			clk;
	///Reset to initialize module
	sc_in < bool >			resetx;

	///Bit vector input from the FIFO
	sc_in< sc_bv<32> > 		lk_dword_cd;
	///Control bit
	sc_in< bool > 			lk_hctl_cd;
	///Control bit
	sc_in< bool > 			lk_lctl_cd;

	///To add the input vector to the calculation of CRC1
	sc_in< bool >			crc1_enable;
	///To add the input vector to the calculation of CRC2
	sc_in< bool >			crc2_enable;
	///Reset the CRC1 value
	sc_in< bool >			crc1_reset;
	///Reset the CRC2 value
	sc_in< bool >			crc2_reset;
	///If CTL is activated, should CRC2 be calculated instead of CRC1
	sc_in< bool >	crc2_if_ctl;

	//*******************************
	//	Outputs
	//*******************************
	///If the input vector is identical to the CRC1
	sc_out< bool >			crc1_good;
	///If the input vector is identical to the CRC2
	sc_out< bool >			crc2_good;
	///If the input vector is the inverse of CRC1
	sc_out< bool >			crc1_stomped;
	///If the input vector is the inverse of CRC2
	sc_out< bool >			crc2_stomped;

	//*******************************
	//  Internal signals
	//*******************************
	///CRC1 value
	sc_signal< sc_uint<32> >	crc1_value;
	///CRC2 value
	sc_signal< sc_uint<32> >  crc2_value;


	//Methods
	///Sychronous process to calculate the new CRC values
	void calculate_outputs();
	///Combinatory process to calculate crc*_good and crc*_stomped
	void clocked_process();

	///SystemC Macro
	SC_HAS_PROCESS(cd_packet_crc_l3);

	///Module constructor
	cd_packet_crc_l3(sc_module_name name);
};

#endif
