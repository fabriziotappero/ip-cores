//PacketContainer.h
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


#ifndef PacketContainer_H
#define PacketContainer_H

#ifndef SC_USER_DEFINED_MAX_NUMBER_OF_PROCESSES
#define SC_USER_DEFINED_MAX_NUMBER_OF_PROCESSES
#define SC_VC6_MAX_NUMBER_OF_PROCESSES 20
#endif
#include <systemc.h>

#include "ControlPacket.h"

///Container for ControlPacket pointers
/**
	This class is a safe way to exchange <code>ControlPacket</code>
	over a <code>sc_signal</code>.  It is a modified automatic pointer
	that never releases it's pointer, but instead creates
	a copy of an object unless it is explicitely asked
	to take control.

	Since it never gives control of it's internal pointer,
	the object inside the container always stays valid!
	A NOP packet is constructed by default.

	Caution has to be taken when using this.  When passing
	a pointer to the constructor, the container will take
	control of the packet.  If an object is passed, then
	a copy of the object will be made.

	@see ControlPacket
	@author Ami Castonguay	
*/
class PacketContainer{

	///To output the packet on an <code>ostream</code>
	/**
		Called to output the internal packet to an output stream.

		@param out The stream to output to
		@param c   The container that contains the packet to output
		@return ostream The stream <code>out</code>
	*/
	friend ostream& operator<<(ostream& out, const PacketContainer & c);
	friend void sc_trace(sc_trace_file *tf, const PacketContainer& v,
	const sc_string& NAME);

protected:

	///The actual packet contained
	ControlPacket* pkt;

	///If the packet was constructed by default (nop)
	bool defaultPacket;

	///Initial Packet value
	/**
		sc_trace(...) requires to be called on an object which has a
		lifetime of the complete simulation.  Since the internal pkt
		object is constantly allocated and destroyed, it is not possible
		to trace the object.  Instead, when de PacketContainer is allocated
		with a new packet, the bufferedBitVector is updated with the initial
		value of the packet.  That variable can then be traved without problem.

		Any change to the packet bit vector will not appear in the 
		bufferedBitVector since it is only a snapshot of the initial value.
	*/
	sc_bv<64> bufferedBitVector;

public:

	///Default constructor
	/**
		Default constructor
	*/
	PacketContainer();

	///Constructor to take over packet
	/**
		This constructor will take control of the packet.
		It will take care to free the memory of the pointer
		when the destructor is called.

		@param pkt_ref The packet to take control of
	*/
	PacketContainer(ControlPacket* pkt_ref);

	///Copy constructor
	/**
		The constructor will create a PacketContainer that has an internal packet 
		identical packet (a copy) to the one inside the container passed as parameter
		
		@param container The container to copy
	*/
	PacketContainer(const PacketContainer &container);	

	///Assign a new value to the packet container
	/**
		This operator will delete the internal packet and replace it with an
		identical packet (a copy) to the one inside the container passed as parameter
		
		@param container The container that contains the packet to copy
		@return This packet
	*/
	PacketContainer& operator=(const PacketContainer &container);

	///Assign a new value to the packet container
	/**
		This operator will delete the internal packet and replace it with an
		identical packet (a copy) to the one passed as parameter
		
		@param new_pkt The packet to copy
		@return This packet
	*/
	PacketContainer& operator=(const ControlPacket &new_pkt);

	
	///If packet is valid
	/**
		When a container is created from the default constructor,
		a default NOP packet is created.  This returns wether or not
		it's that default packet that is contained in the container.

		@return If the container was assigned with a packet
	*/
	bool isValidPacket() const;
	

	///Take control of the pointer
	/**
		This will take control of the packet.
		It will take care to free the memory of the pointer
		when the destructor is called.

		@param new_pkt The packet to take control of
	*/
	void takeControl(ControlPacket *new_pkt);

	///Give away control of the internal packet
	/**
		This will returns the pointer to the internal
		packet and creates a new default packet internally.  The returned
		pointer will not be deleted when the destructor is called.

		@return The pointer to the internal packet
	*/
	ControlPacket* giveControl();

	///Get the reference to the internal packet
	/**
		@return The pointer to the internal packet
	*/
	ControlPacket* getPacketRef() const{
		return pkt;
	}

	///Get the packet object
	/**
		@return The internal packet
	*/
	ControlPacket& operator* () const{
		return *pkt;
	}

	///Operator to access the packet members
	/**
		This operator allows to access members on the internal packet
		directly from the the container object.

		Eg :
		<code>
		Container c;//Creates a default NopPacket
		VirtualChannel vc = c->getVirtualChannel();Directly access member method
		</code>

		@return The pointer to the internal packet
	*/
    ControlPacket* operator-> () const{
		return pkt;
	}

	/**
		Deletes the packet stored in the container
	*/
	~PacketContainer();

	///To check if two packets have identical content
	bool operator== (const PacketContainer & test) const;

	///To check if two packets have different content
	inline bool operator!= (const PacketContainer &test) const {return !(*this == test);}

	//Those two operators actually use the underlying ControlPacket equivalent
	//operator, hence why it is as simply as return *pkt.
	/**
		@return The 64 bits vector of the packet
	*/
	inline operator sc_bv<64>() const {return *pkt;}

	/**
		@return The least significant 32 bits of the packet.
	*/
	inline operator sc_bv<32>() const {return *pkt;}


};


#endif
