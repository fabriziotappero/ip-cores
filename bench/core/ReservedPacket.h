//ReservedPacket.h
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

#ifndef ReservedPacket_H
#define ReservedPacket_H

#ifndef SC_USER_DEFINED_MAX_NUMBER_OF_PROCESSES
#define SC_USER_DEFINED_MAX_NUMBER_OF_PROCESSES
#define SC_VC6_MAX_NUMBER_OF_PROCESSES 20
#endif
#include <systemc.h>

#include "ControlPacket.h"


///Reserved packet or invalid/unknown packet 
/**
	ReservedPacket is a packet which is not defined by the standard.
*/
class ReservedPacket: public ControlPacket{

public:

	///Constructor with a 32 bit vector
	/**
		@param dWord The least significant 32 bits that represents packet
	*/
	ReservedPacket(const sc_bv<32> &dWord) : ControlPacket(dWord){}

	///Constructor with a 64 bit vector
	/**
		@param qWord The 64 bits that represents packet
	*/
	ReservedPacket(const sc_bv<64> &qWord) : ControlPacket(qWord){}

	///If the packet type is 32 bits
	/**
		Reserved packets are assumed to be 32 bits

		@return true
	*/	
	virtual bool isDwordPacket() const { return true;}

	///If packet has data associated
	/**
		A reserved packet is assumed to not have any data

		@return false
	*/	
	virtual bool hasDataAssociated() const {return false;};

	///Get the <code>VirtualChannel</code> of the packet
	/**
		To get the virtual channel of this packet
		Packet can travel in different channels depending on their function
		and of their attributes.  Since ReservedPacket is not a valide packet,
		VC_NONE	is returned.

		@return The VirtualChannel VC_NONE
	*/	
	virtual VirtualChannel getVirtualChannel() const {return VC_NONE;}

	///Get the type of this packet
	/**
		@return The RESERVED_TYPE PacketType
	*/	
	virtual PacketType getPacketType() const {return RESERVED_TYPE;}

	///To get the command of the packet
	/**
		@return RESERVED_CMD
	*/	
	virtual PacketCommand getPacketCommand() const{return RESERVED_CMD;}

	///If packet part of chain
	/**
		@return false
	*/	
	virtual bool isChain() const { return false;}

	///Get the length-1 of the data associated
	/**
		@return A 0 length.
	*/
	sc_uint<4> getDataLengthm1() const {return 0; }
	
	virtual ControlPacket* getCopy() const {return new ReservedPacket(bv);};

	virtual bool getPassPW() const {return false;}

};

#endif
