//ht_datatypes.h
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

///Includes all types necessary for control packets
/** 
	@file ht_datatypes.h
	@author Ami Castonguay
*/


#ifndef HT_DATATYPES_H
#define HT_DATATYPES_H

#ifndef SC_USER_DEFINED_MAX_NUMBER_OF_PROCESSES
#define SC_USER_DEFINED_MAX_NUMBER_OF_PROCESSES
#define SC_VC6_MAX_NUMBER_OF_PROCESSES 20
#endif
#include <systemc.h>

#include "../../rtl/systemc/core_synth/constants.h"

/**
	The number of spaces for DirectRoute adress are reserved in the CSR
*/
//#define DIRECTROUTE_SPACES 2





#include "ControlPacket.h"
#include "PacketContainer.h"

//Also include all other packet type for
//convenience
#include "RequestPacket.h"
#include "ResponsePacket.h"
#include "InfoPacket.h"
#include "ReservedPacket.h"

struct syn_ControlPacketComplete;

///Group of often used signal that includes a packet
/**
	Includes the packet, the VC, the adresse of the data buffer,.
	and if there is a data packet associated with the control packet
*/
class ControlPacketComplete {
	
public:

	///The actual control packet
	PacketContainer packet;

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

	///Default Constructor
	ControlPacketComplete();

	///Copy Constructor
	ControlPacketComplete(const ControlPacketComplete &pktCmplt);

	///Copy Constructor from synthesis packet
	ControlPacketComplete(const syn_ControlPacketComplete &pktCmplt);

	syn_ControlPacketComplete generateSynControlPacketComplete();

	ControlPacketComplete& operator= (const ControlPacketComplete &pktCmplt);

	ControlPacketComplete& operator= (const syn_ControlPacketComplete &pktCmplt);

	///Default Constructor
	~ControlPacketComplete(){}

	///Check if two structs have identical content
	bool operator== (const ControlPacketComplete &) const;

	operator syn_ControlPacketComplete() const;

	///Check if two structs have different content
	inline bool operator!= (const ControlPacketComplete &test) const {return !(*this == test);}

	///To output the content of the struct
	friend ostream &operator<<(ostream&, const ControlPacketComplete &);
};

/**
	To allow the ht_ctl_pcktcomplete to be traced and be
	used as an sc_signal
*/
extern
void sc_trace(sc_trace_file *tf, const ControlPacketComplete& v,
const sc_string& NAME);

#endif
