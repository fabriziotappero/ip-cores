//synth_datatypes.h
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

#ifndef SYNTH_DATATYPES_H
#define SYNTH_DATATYPES_H

///Types used in the synthesized design
/**
	@file synth_datatypes.h
	@author Ami Castonguay
	@description Datatypes that can be used for synthesis
*/


#ifndef SC_USER_DEFINED_MAX_NUMBER_OF_PROCESSES
#define SC_USER_DEFINED_MAX_NUMBER_OF_PROCESSES
#define SC_VC6_MAX_NUMBER_OF_PROCESSES 20
#endif

#include <systemc.h>

#include "ht_type_include.h"
#include "constants.h"
#include "synth_control_packet.h"

///Group of often used signal that includes a packet
/**
	Includes the packet, the VC, the adresse of the data buffer,.
	and if there is a data packet associated with the control packet
*/
struct syn_ControlPacketComplete {
	
public:

	///The actual control packet
	sc_bv<64> packet;

	///If the packet was received with a 64 bit address extension
	bool error64BitExtension;

	/// = 1 if the packet belongs to a chain. 
	/**This variable is different from the
	 chain bit in the control packets because it is = 1 if the packet is the 
	 last in the chain, while the chain bit = 0 in that case
	*/
	bool isPartOfChain;

	///The adress of the data packet associated, if any
	sc_uint<BUFFERS_ADDRESS_WIDTH> data_address;

	
#ifdef SYSTEMC_SIM

	///Constructor for the struct
	syn_ControlPacketComplete();

	///Check if two structs have identical content
	bool operator== (const syn_ControlPacketComplete &) const;

	///Check if two structs have different content
	inline bool operator!= (const syn_ControlPacketComplete &test) const {return !(*this == test);}

#endif
};

///Group of often used signal that includes a response packet
/**
	Includes the packet, the VC, the adresse of the data buffer,.
	and if there is a data packet associated with the control packet
*/
struct syn_ResponseControlPacketComplete {
	
public:

	///The actual control packet
	sc_bv<32> packet;

	///The adress of the data packet associated, if any
	sc_uint<BUFFERS_ADDRESS_WIDTH> data_address;

	
#ifdef SYSTEMC_SIM

	///Constructor for the struct
	syn_ResponseControlPacketComplete();

	///Check if two structs have identical content
	bool operator== (const syn_ResponseControlPacketComplete &) const;

	///Check if two structs have different content
	inline bool operator!= (const syn_ResponseControlPacketComplete &test) const {return !(*this == test);}

#endif
};

#ifdef SYSTEMC_SIM

///To initialize (reset content to zeros and falses) the syn_ControlPacketComplete struct
void initialize_syn_ControlPacketComplete(syn_ControlPacketComplete &pkt);
///To initialize (reset content to zeros and falses) the syn_ResponseControlPacketComplete struct
void initialize_syn_ResponseControlPacketComplete(syn_ResponseControlPacketComplete &pkt);

#else

///To initialize (reset content to zeros and falses) the struct
void initialize_syn_ControlPacketComplete(syn_ControlPacketComplete &pkt){
	pkt.packet = sc_bv<64>(0);
	pkt.error64BitExtension = sc_bit(false);
	pkt.isPartOfChain = sc_bit(false);
	pkt.data_address = sc_uint<BUFFERS_ADDRESS_WIDTH>(0);
}

///To initialize (reset content to zeros and falses) the struct
void initialize_syn_ResponseControlPacketComplete(syn_ResponseControlPacketComplete &pkt){
	pkt.packet = sc_bv<32>(0);
	pkt.data_address = sc_uint<BUFFERS_ADDRESS_WIDTH>(0);
}
#endif

/**
	Also, for synthesis, include actual functions
*/
#ifdef SYSTEMC_SIM
///To trace syn_ControlPacketComplete signals
void sc_trace(sc_trace_file *tf, const syn_ControlPacketComplete& v,
const sc_string& NAME);
///To trace syn_ResponseControlPacketComplete signals
void sc_trace(sc_trace_file *tf, const syn_ResponseControlPacketComplete& v,
const sc_string& NAME);

///To output to a stream structures
//@{
ostream &operator<<(ostream& out, const syn_ControlPacketComplete &pkt);
ostream &operator<<(ostream& out, const syn_ResponseControlPacketComplete &pkt);
ostream &operator<<(ostream &out,const PacketCommand &cmd);
ostream &operator<<(ostream &out,const PacketType &type);
ostream &operator<<(ostream &out,const VirtualChannel &vc);
ostream &operator<<(ostream &out,const ResponseError &re);
//@}
#endif

#endif
