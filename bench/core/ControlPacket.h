//ControlPacket.h
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

#ifndef ControlPacket_H
#define ControlPacket_H

#include "../../rtl/systemc/core_synth/ht_type_include.h"

//Forward declarations
class PacketContainer;


/// Base class for all packets
/**
	Allows to create a packet class from the fisrt dword of a
	Packet.  If the packet is doubleDword packet, functions that
	access the first dword of the data can be accessed.  The seconde
	dword can be added with the <code>setSecondDword(const sc_bv< 32 > &dWord)</code>
	function to complete the packet.	If a function accessing the second
	dword is called before that second dword is available, it should
	make an assertion.

	@author Ami Castonguay
*/
class ControlPacket{

	///To output the packet on an <code>ostream</code>
	/**
		Called to output the packet to an output stream.
		Displays the internal vector of the packet.

		@param out The stream to output to
		@param pkt The packet to output
		@return The stream <code>out</code>
	*/
	friend ostream &operator<<(ostream &out,const ControlPacket &pkt);

protected:

	///The actual data of this packet
	sc_bv<64> bv;

public:

	static bool outputExtraInformation;

	///Default constructor
	/**
		Creates an empty packet with a vector filled with 0.
	*/
	ControlPacket::ControlPacket(){};

	///Constructor with a 32 bit vector
	/**
		@param dWord The least significant 32 bits that represents packet
	*/
	ControlPacket(const sc_bv<32> &dWord){bv(31,0) = dWord;}

	///Constructor with a 64 bit vector
	/**
		@param qWord The least significant 32 bits that represents packet
	*/
	ControlPacket(const sc_bv<64> &qWord){bv(63,0) = qWord;}


	///Creates a packet of the appropriate derived class from 32 bits
	/**
		Creates a packet of the right derived type from the first 32 bits of
		that packet.  For easy memory management, the returned packet is encapsulated
		in a <code>PacketContainer</code>.  If the command is unknown, the packet returned
		is of type ReservedPacket.  If the packet is 64 bits long,
		functions using the last 32 bits will have undefined results until those
		last bits are added through setSecondDword.

		@param dWord The 32 bits containing the least significant bits of a control packet
		@return A packet inside a PacketContainer created from the 32 bits vector
	*/
	static PacketContainer createPacketFromDword(const sc_bv<32> &dWord);

	///Creates a packet of the appropriate derived class from 63 bits
	/**
		Creates a packet of the right derived type from the 64 bits of
		that packet.  For easy memory management, the returned packet is encapsulated
		in a <code>PacketContainer</code>.  If the command is unknown, the packet returned
		is of type ReservedPacket.  If the packet is 32 bits long,
		the last 32 bits will simply be ignored.

		@param qWord The 64 bits containing the bits of the packet.  If the packet type
				is 32 bits long, the most significant 32 bits are stored in the invernal
				vector but ignored by functions
		@return A packet inside a PacketContainer created from the 32 bits vector
	*/
	static PacketContainer createPacketFromQuadWord(const sc_bv<64> &qWord);

	///Complete last 32 bits of a packet
	/**
		To complete a doubleDword packet that was created with the function
		<code>createPacketFromDword(const sc_bv<32> &dWord)</code>.

		@param dWord The second dword of the packet
	*/	
	void setSecondDword(const sc_bv<32> &dWord);

	///If the packet type is 32 bits
	/**
		To know if the packet type is 32 bits.

		@return True if the packet is of a type that is 32 bits (dword)
			or false otherwise.
	*/	
	virtual bool isDwordPacket() const = 0 ;

	///To get the command of the packet
	/**
		To get the command of the packet
		The <code>PacketCommand</code> represents the exact function
		of this packet.

		@return The command of the packet
	*/	
	virtual PacketCommand getPacketCommand() const = 0;

	///To get the command from the 6 bits of command
	/**
		From a 6 bits command vector, returns a PacketCommand type.
		The <code>PacketCommand</code> represents the exact function
		of this packet.

		@return The command corresponding to the 6 bits command
	*/	
	static PacketCommand getPacketCommand(const sc_bv<6> &cmd);

	///Get the type of packet
	/**
		To get the type of the packet.  
		Packet can be categorize in different types depending on their function.

		@return The type of this packet
	*/	
	virtual PacketType getPacketType() const = 0;

	///Get the type from the command
	/**
		To get the type of a command.
		Packet can be categorize in different types depending on their function.
		This returns the <code>PacketType</code> for the command.

		@param cmd The command to analyze
		@return The type associated to the command
	*/	
	static PacketType getPacketType(const sc_bv<6> &cmd);

	///Get the <code>VirtualChannel</code> of the packet
	/**
		To get the virtual channel of this packet
		Packet can travel in different channels depending on their function
		and of their attributes.

		@return The VirtualChannel associated to the command
	*/	
	virtual VirtualChannel getVirtualChannel() const = 0 ;

	///Packet part of chain
	/**
		Some packets are part of chain that can not be interrupted.

		@return If the packet is part a a chain
	*/	
	virtual bool isChain() const = 0;

	///Packet has data associated
	/**
		To know if there is a data packet associated with this control
		packet

		@return If the packet has data associated
	*/	
	virtual bool hasDataAssociated() const = 0 ;

	///Get the length-1 of the data associated
	/**
		Gets the number of doublewords of data associated with this ctl packet
		minus 1.  So a returned number of 0 represents 1 doubleWord.
		If there is no data associated, the result is undefined.
		The number returned also includes the doubleword mask in a byte write

		@return Length-1 of data associated with the packet, or undefined
				if the packet has no data associated
	*/
	virtual sc_uint<4> getDataLengthm1() const = 0 ;

	///Create Address extension doubleWord
	/**
		@param addressExtension The extra 24 bits to add to the standard 40 bits address
			It is illegal to have this all zeros!!!
		@return The 23 bits to prepend to a request to send in the 64 bit format
	*/
	static sc_bv<32> createAddressExtensionDoubleWord(sc_bv<24> &addressExtension);

	///Get the internal data vector (constant version)
	inline const sc_bv<64>& getVector() const {return bv;}
	///Get the internal data vector
	inline sc_bv<64>& getVector()  {return bv;}

	///Get the internal data vector
	inline operator sc_bv<64>() const {return bv;}
	///Get the least significant 32 bits of the internal data vector
	inline operator sc_bv<32>() const {return bv.range(31,0);}

	///To check if two packets have identical content
	bool operator== (const ControlPacket &) const;

	///To check if two packets have different content
	inline bool operator!= (const ControlPacket &test) const {return !(*this == test);}

	///Get a copy of this object
	/**
		To get a new object which is identical to this packet

		@return A packet of the same derived type with the same
			internal vector
	*/
	virtual ControlPacket* getCopy() const = 0;

	/**
		@return If this packet can pass posted writes (increased priority)
	*/
	virtual bool getPassPW() const = 0;

	///Virtual destructor
	virtual ~ControlPacket(){}


};


///To allow this class to be used as a SystemC user data type
extern
void sc_trace(sc_trace_file *tf, const ControlPacket& v,
const sc_string& NAME);


#endif
