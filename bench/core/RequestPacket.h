//RequestPacket.h
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

#ifndef RequestPacket_H
#define RequestPacket_H

#ifndef SC_USER_DEFINED_MAX_NUMBER_OF_PROCESSES
#define SC_USER_DEFINED_MAX_NUMBER_OF_PROCESSES
#define SC_VC6_MAX_NUMBER_OF_PROCESSES 20
#endif
#include <systemc.h>

#include "ControlPacket.h"

//enum VirtualChannel;

///Base class for all request packets
/**
	A request packet is a  packet that is used to send request to the chain.  
	The most used types of RequestPacket are read and write packets.
*/
class RequestPacket: public ControlPacket{

public:

	///Constructor with a 32 bit vector
	/**
		@param dWord The least significant 32 bits that represents packet
	*/
	RequestPacket(const sc_bv<32> &dWord) : ControlPacket(dWord){}

	///Constructor with a 64 bit vector
	/**
		@param qWord The 64 bits that represents packet
	*/
	RequestPacket(const sc_bv<64> &qWord) : ControlPacket(qWord){}

	///Constructor with specific parameters
	/**
		This allows to construct a packet with parameters that are generic
		to all request packets

		@param command  The command of the packet, defines the exact type of the
						packet.
		@param seqID    The sequence ID of the packet.  Packets which have the same
						sequenceID and the same unitID are garantied to stay ordered
		@param unitID	unitID of the device that sent the request
		@param passPW	If this packet can pass posted writes (increased priority)
		@param isocOrCompat	Depending on the packet type, this bit either represents if
						the packet travels in isoc channels (increased priority) or if
						the packet has to be read by the substractive decode device
		@param srcTag	srcTag allows to track non-posted packets.  When a non-posted packet
						is sent with a srcTag, another non-posted packet with that same
						srcTag cannot be sent before a response is received for the original
						request.  When a request is posted, bit 4 represents DataError and bit
						3 Chain if the request is part of a Chain.
		@param count	The count of data for packets that send Dword data packets, a mask for
						packets sending Byte data packets and reserved for other packets
		@param address	The destination addresse of this packet
	*/
	RequestPacket(const sc_bv<6> &command,
		          const sc_bv<4> &seqID,
				  const sc_bv<5> &unitID,
				  bool passPW = false,
				  bool isocOrCompat = false,
				  sc_bv<5> srcTag = sc_bv<5>(),
				  sc_bv<4> count = sc_bv<4>(),
				  sc_bv<38> address = sc_bv<38>());

	///If the packet type is 32 bits
	/**
		To know if the packet type is 32 bits.

		@return True if the packet is of a type that is 32 bits (dword)
			or false otherwise.
	*/	
	virtual bool isDwordPacket() const;

	///Packet has data associated
	/**
		To know if there is a data packet associated with this control
		packet

		@return If the packet has data associated
	*/	
	virtual bool hasDataAssociated() const;

	///Get the <code>VirtualChannel</code> of the packet
	/**
		To get the virtual channel of this packet
		Packet can travel in different channels depending on their function
		and of their attributes.

		@return The VirtualChannel associated to the command
	*/	
	virtual VirtualChannel getVirtualChannel() const;

	///Get the type of this packet
	/**
		RequestPacket objects are always of type REQUEST

		@return The REQUEST PacketType
	*/	
	virtual PacketType getPacketType() const {return REQUEST;}

	/**
		To know if the this packet is in this range of addresses
		
		@param low Character string that can be converted to a 40 bits vector
					that represents the low value of the address range
		@param high Character string that can be converted to a 40 bits vector
					that represents the high value of the address range
		@return If the address of the packet is between high and low
	*/
	bool isInAddressRange(const char * low,const char * high) const;

	/**
		To know if the this packet is in this range of addresses
		
		@param low 40 bits vector that represents the low value of the address range
		@param high 40 bits vector that represents the high value of the address range
		@return If the address of the packet is between high and low
	*/
	bool isInAddressRange(const sc_bv<40> &low,const sc_bv<40> &high) const;

	/**
		To know if the this packet is in this range of addresses
		
		@param low 40 bits vector that represents the low value of the address range
		@param high 40 bits vector that represents the high value of the address range
		@return If the address of the packet is between high and low
	*/
	bool isInAddressRange(const sc_uint<40> &low,const sc_uint<40> &high) const;

	/**
		@return The adress of the destination of the packet
			Will return an address of 0 if the packet does not have
			an address (is a Dword packet)
	*/
	sc_uint<40> getRequestAddr() const;

	///Get the length-1 of the data associated
	/**
		Gets the number of doublewords of data associated with this ctl packet
		minus 1.  So a returned number of 0 represents 1 doubleWord.
		If there is no data associated, the result is undefined.
		The number returned also includes the doubleword mask in a byte write

		@return Length-1 of data associated with the packet, or undefined
				if the packet has no data associated
	*/
	sc_uint<4> getDataLengthm1() const;

	///Get a copy of this object
	/**
		To get a new object which is identical to this packet

		@return A packet of the same derived type with the same
			internal vector
	*/
	virtual ControlPacket* getCopy() const = 0;

	/**
		@return The sequence ID of the packet.  Packets which have the same
				sequenceID and the same unitID are garantied to stay ordered
	*/
	sc_bv<4> getSeqID() const;

	/**
		@return If this packet can pass posted writes (increased priority)
	*/
	virtual bool getPassPW() const;

	/**
		@return unitID of the device that sent the request
	*/
	sc_bv<5> getUnitID() const;

	/**
		srcTag allows to track non-posted packets.  When a non-posted packet
		is sent with a srcTag, another non-posted packet with that same
		srcTag cannot be sent before a response is received for the original
		request.  When a request is posted, bit 4 represents DataError and bit
		3 Chain if the request is part of a Chain.

		@return The srcTag of this packet
	*/
	sc_bv<5> getSrcTag() const;

	/**
		@return Depending on the packet type, this bit either represents if
				the packet travels in isoc channels (increased priority) or if
				the packet has to be read by the substractive decode device
	*/
	bool getCompatOrIsoc() const;

	/**
		@return If this packet is part of a Chain
	*/
	virtual bool isChain() const;

};


 
///Flush request packet
/**
	Since a flush packet has passPW false and is posted, it cannot pass other packets.
	When it reaches the host (or it's destination in DirecRoute), it surely
	means that all other posted packets that was sent prior to the flush has also
	reached destination.  A response is then sent by the destination.

	It is a way to assure that all packets sent have reached it's first
	destination.  In the case of a host reflected destination, the flush only
	garanties that all the packets have reached the host.
*/
class FlushPacket: public RequestPacket{

public :

	///Constructor with a 32 bit vector
	/**
		@param dWord The least significant 32 bits that represents packet
	*/
	FlushPacket(const sc_bv<32> &dWord) : RequestPacket(dWord){}

	///Constructor with a 64 bit vector
	/**
		@param qWord The 64 bits that represents packet
	*/
	FlushPacket(const sc_bv<64> &qWord) : RequestPacket(qWord){}

	///Constructor with specific parameters
	/**
		This allows to construct a packet with parameters that are specific to the
		Flush packet

		@param seqID    The sequence ID of the packet.  Packets which have the same
						sequenceID and the same unitID are garantied to stay ordered
		@param unitID	unitID of the device that sent the request
		@param passPW	If this packet can pass posted writes (increased priority)
		@param isoc		If the packet should travel in isochronous channels
		@param srcTag	srcTag allows to track non-posted packets.  Another non-posted 
						packet with that same srcTag cannot be sent before a response is
						received for the original request.
	*/
	FlushPacket(const sc_bv<4> &seqID,
					const sc_bv<5> &unitID,
					bool passPW = false,
					bool isoc = false,
					sc_bv<5> srcTag = sc_bv<5>()) :
		RequestPacket(sc_bv<6>("000010"),
			              seqID,
						  unitID,
						  passPW,
						  isoc,
						  srcTag){};

	virtual PacketCommand getPacketCommand() const{return FLUSH;}

	virtual ControlPacket* getCopy() const{
		return new FlushPacket(bv);
	}
};


///Fence request packet
/**
	A Fence packet is a way to make a barrier between two groups of
	posted packets that have passPW clear.  Normally, two posted packets
	from the same source with passPW clear can not pass each other.  But
	if two posted packets with passPW clear are from different sources,
	nothing garanties that they will stay ordered.

	The only way to make sure that posted packets with passPW clrea from 
	different sources stay ordered is with a Fence packet since no posted
	packet with passPW clear can pass it.
*/
class FencePacket: public RequestPacket{

public :

	///Constructor with a 32 bit vector
	/**
		@param dWord The least significant 32 bits that represents packet
	*/
	FencePacket(const sc_bv<32> &dWord) : RequestPacket(dWord){}

	///Constructor with a 64 bit vector
	/**
		@param qWord The 64 bits that represents packet
	*/
	FencePacket(const sc_bv<64> &qWord) : RequestPacket(qWord){}


	///Constructor with specific parameters
	/**
		This allows to construct a packet with parameters that are specific to the
		Fence packet

		@param seqID    The sequence ID of the packet.  Packets which have the same
						sequenceID and the same unitID are garantied to stay ordered
		@param unitID	unitID of the device that sent the request
		@param passPW	If this packet can pass posted writes (increased priority)
		@param isoc		If the packet should travel in isochronous channels
	*/
	FencePacket(  const sc_bv<4> &seqID,
					  const sc_bv<5> &unitID,
					  bool passPW = false,
					  bool isoc = false) :
		RequestPacket(sc_bv<6>("111100"),
			              seqID,
						  unitID,
						  passPW,
						  isoc){}

	virtual PacketCommand getPacketCommand() const{return FENCE;}

	virtual ControlPacket* getCopy() const{
		return new FencePacket(bv);
	}
};

///Read request packet
/**
	A ReadPacket is a request to read data.  A responsePacket that contains 
	the data that is at the requested address will be issued upon reception
	of the read packet by the destination, unless an error occurs.
*/
class ReadPacket: public RequestPacket{

public :

	///Constructor with a 32 bit vector
	/**
		@param dWord The least significant 32 bits that represents packet
	*/
	ReadPacket(const sc_bv<32> &dWord) : RequestPacket(dWord){}

	///Constructor with a 64 bit vector
	/**
		@param qWord The 64 bits that represents packet
	*/
	ReadPacket(const sc_bv<64> &qWord) : RequestPacket(qWord){}

	///Constructor with specific parameters
	/**
		This allows to construct a packet with parameters that are specific to 
		Read packets

		@param seqID    The sequence ID of the packet.  Packets which have the same
						sequenceID and the same unitID are garantied to stay ordered
		@param unitID	unitID of the device that sent the request
		@param passPW	If this packet can pass posted writes (increased priority)
		@param srcTag	srcTag allows to track non-posted packets.  When a non-posted packet
						is sent with a srcTag, another non-posted packet with that same
						srcTag cannot be sent before a response is received for the original
						request.
		@param maskCount	The count of data for packets that send Dword data packets, a mask for
						packets sending Byte data packets
		@param address	The destination addresse of this packet
		@param doubleWordDataLength True if it is a dword read of false if it is a Byte read
		@param responsePassPW If the response to this request should have passPW=1
		@param memoryCoherent Indicates whether access requires host cache coherence (reserved and
						set if access is not to host memory)
		@param compat	If the packet should be received by the compatibility decoder
		@param isoc		If the packet should travel in isochronous channels
	*/
	ReadPacket(	  const sc_bv<4> &seqID,
					  const sc_bv<5> &unitID,
					  const sc_bv<5> srcTag,
					  const sc_bv<4> maskCount,
					  const sc_bv<38> address,
					  bool doubleWordDataLength,
					  bool passPW = false,
					  bool responsePassPW = false,
					  bool memoryCoherent = true,
					  bool compat = false,
					  bool isoc = false) :
		RequestPacket(sc_bv<6>("010000"),
			              seqID,
						  unitID,
						  passPW,
						  compat,
						  srcTag,
						  maskCount,
						  address)
	{
			bv[0] = memoryCoherent;
			bv[1] = isoc;
			bv[2] = doubleWordDataLength;
			bv[3] = responsePassPW;
	}

	virtual PacketCommand getPacketCommand() const{return READ;}

	virtual ControlPacket* getCopy() const{
		return new ReadPacket(bv);
	}

	inline bool isDoubleWordDataLength() const{
		return (sc_bit)(bv[2]);
	}

	inline bool isIsoc() const{
		return (sc_bit)(bv[1]);
	}

};


///Write request packet
/**
	A WritePacket enable to send a request with data to write
	at a specific address.  It can either be posted or non-posted.
	In the non-posted case, a TargetDone response will be issued by
	the destination of the packet once the write has been done.
*/
class WritePacket: public RequestPacket{

public :

	///Constructor with a 32 bit vector
	/**
		@param dWord The least significant 32 bits that represents packet
	*/
	WritePacket(const sc_bv<32> &dWord) : RequestPacket(dWord){}

	///Constructor with a 64 bit vector
	/**
		@param qWord The 64 bits that represents packet
	*/
	WritePacket(const sc_bv<64> &qWord) : RequestPacket(qWord){}


	///Constructor with specific parameters for posted writes
	/**
		This allows to construct a packet with parameters that are specific to 
		posted Write packets

		@param seqID    The sequence ID of the packet.  Packets which have the same
						sequenceID and the same unitID are garantied to stay ordered
		@param unitID	unitID of the device that sent the request
		@param passPW	If this packet can pass posted writes (increased priority)
		@param count	The count of data for packets, including the byte mask in the case
						of a byte write.
		@param address	The destination addresse of this packet
		@param doubleWordDataLength True if it is a dword read of false if it is a Byte read.
				<br><i>Special note</i> : This is an int instead of a bool because there is no implicit
				cast from const char * to an int, while there is one for a bool.  If someone
				was to create a WritePacket with data from strings instead of sc_bv, the
				compiler can end up using the wrong constructor.  Using the int prevents this.
		@param memoryCoherent Indicates whether access requires host cache coherence (reserved and
						set if acces is not to host memory)
		@param compat	If the packet should be received by the compatibility decoder
		@param isoc		If the packet should travel in isochronous channels
		@param dataError If a data error occured while forwarding the request
		@param chain	If the packet is par of a chain
	*/
	WritePacket(  const sc_bv<4> &seqID,
					  const sc_bv<5> &unitID,
					  const sc_bv<4> &count,
					  const sc_bv<38> &address,
					  bool doubleWordDataLength,
					  bool passPW = false,
					  bool dataError = false,
					  bool chain = false,
					  bool memoryCoherent = true,
					  bool compat = false,
					  bool isoc = false) :
		RequestPacket(sc_bv<6>("101000"),
			              seqID,
						  unitID,
						  passPW,
						  compat,
						  sc_bv<5>(),
						  count,
						  address)
	{
			bv[0] = memoryCoherent;
			bv[1] = isoc;
			bv[2] = doubleWordDataLength;
			bv[20] = dataError;
			bv[19] = chain;
	}


	///Constructor with specific parameters for non-posted writes
	/**
		This allows to construct a packet with parameters that are specific to 
		posted Write packets

		@param seqID    The sequence ID of the packet.  Packets which have the same
						sequenceID and the same unitID are garantied to stay ordered
		@param unitID	unitID of the device that sent the request
		@param srcTag	srcTag allows to track non-posted packets.  When a non-posted packet
						is sent with a srcTag, another non-posted packet with that same
						srcTag cannot be sent before a response is received for the original
						request.
		@param passPW	If this packet can pass posted writes (increased priority)
		@param count	The count of data for packets, including the byte mask in the case
						of a byte write.
		@param address	The destination addresse of this packet
		@param doubleWordDataLength True if it is a dword read of false if it is a Byte read.
				<br><i>Special note</i> : This is an int instead of a bool because there is no implicit
				cast from const char * to an int, while there is one for a bool.  If someone
				was to create a WritePacket with data from strings instead of sc_bv, the
				compiler can end up using the wrong constructor.  Using the int prevents this.
		@param memoryCoherent Indicates whether access requires host cache coherence (reserved and
						set if acces is not to host memory)
		@param compat	If the packet should be received by the compatibility decoder
		@param isoc		If the packet should travel in isochronous channels
	*/
	WritePacket(  const sc_bv<4> &seqID,
					  const sc_bv<5> &unitID,
					  const sc_bv<5> &srcTag,
					  const sc_bv<4> &count,
					  const sc_bv<38> &address,
					  bool doubleWordDataLength,
					  bool passPW = false,
					  bool memoryCoherent = true,
					  bool compat = false,
					  bool isoc = false) :
		RequestPacket(sc_bv<6>("001000"),
			              seqID,
						  unitID,
						  passPW,
						  compat,
						  srcTag,
						  count,
						  address)
	{
			bv[0] = memoryCoherent;
			bv[1] = isoc;
			bv[2] = doubleWordDataLength;
	}

	virtual PacketCommand getPacketCommand() const{return WRITE;}

	///To get if the packet had an error while being forwared
	/**
		@return The data error bit in posted writes.  If the write
		packet is non-posted, false is returned
	*/
	bool getDataError() const {
		if(bv[5] == true) return sc_bit(bv[20]);
		return false;
	}

	virtual ControlPacket* getCopy() const{
		return new WritePacket(bv);
	}

	inline bool isIsoc() const{
		return (sc_bit)(bv[1]);
	}
};

///Broadcast request packet 
/**
	A BroadcastPacket is accepted by all devices on the chain.  It contains
	an address field but it's use is application specific.
*/
class BroadcastPacket: public RequestPacket{

public :

	///Constructor with a 32 bit vector
	/**
		@param dWord The least significant 32 bits that represents packet
	*/
	BroadcastPacket(const sc_bv<32> &dWord) : RequestPacket(dWord){}

	///Constructor with a 64 bit vector
	/**
		@param qWord The 64 bits that represents packet
	*/
	BroadcastPacket(const sc_bv<64> &qWord) : RequestPacket(qWord){}

	///Constructor with specific parameters for broadcast packets
	/**
		This allows to construct a packet with parameters that are specific to 
		Broadcast packets

		@param seqID    The sequence ID of the packet.  Packets which have the same
						sequenceID and the same unitID are garantied to stay ordered
		@param unitID	unitID of the device that sent the request
		@param passPW	If this packet can pass posted writes (increased priority)
		@param address	The destination addresse of this packet
	*/
	BroadcastPacket(const sc_bv<4> &seqID,
						const sc_bv<5> &unitID,
						bool passPW = false,
						sc_bv<38> address = sc_bv<38>()) :
		RequestPacket(sc_bv<6>("111010"),
			              seqID,
						  unitID,
						  passPW,
						  false,
						  sc_bv<5>(),
						  sc_bv<4>(),
						  address){};

	virtual PacketCommand getPacketCommand() const{return BROADCAST;}

	virtual ControlPacket* getCopy() const{
		return new BroadcastPacket(bv);
	}
};

///Atomic request packet 
/**
	An AtomicPacket combines the use of write requests and read requests
	at the same time.  It is an atomic Read-Modify-Write (RMW) request.  It
	has two types of operation which is dictated by the amount of data that
	is associated with the packet :

		- Fetch and add
		- Compare and swap
*/
class AtomicPacket: public RequestPacket{

public :

	///Constructor with a 32 bit vector
	/**
		@param dWord The least significant 32 bits that represents packet
	*/
	AtomicPacket(const sc_bv<32> &dWord) : RequestPacket(dWord){}

	///Constructor with a 64 bit vector
	/**
		@param qWord The 64 bits that represents packet
	*/
	AtomicPacket(const sc_bv<64> &qWord) : RequestPacket(qWord){}

	///Constructor with specific parameters for atomics read-modify-write
	/**
		This allows to construct a packet with parameters that are specific to 
		posted Write packest

		@param seqID    The sequence ID of the packet.  Packets which have the same
						sequenceID and the same unitID are garantied to stay ordered
		@param unitID	unitID of the device that sent the request
		@param srcTag	srcTag allows to track non-posted packets.  When a non-posted packet
						is sent with a srcTag, another non-posted packet with that same
						srcTag cannot be sent before a response is received for the original
						request.
		@param passPW	If this packet can pass posted writes (increased priority)
		@param count	The count of data for packets that send Dword data packets, a mask for
						packets sendinf Byte data packets and reserved for other packets
		@param address	The destination addresse of this packet
		@param compat	If the packet should be received by the compatibility decoder
	*/
	AtomicPacket( const sc_bv<4> &seqID,
					  const sc_bv<5> &unitID,
					  const sc_bv<5> srcTag,
					  const sc_bv<4> count,
					  const sc_bv<37> address,
					  bool passPW = false,
					  bool compat = false) :
		RequestPacket(sc_bv<6>("111101"),
			              seqID,
						  unitID,
						  passPW,
						  compat,
						  srcTag,
						  count,
						  address << 1)
	{
	}

	virtual PacketCommand getPacketCommand() const{return ATOMIC;}

	virtual ControlPacket* getCopy() const{
		return new AtomicPacket(bv);
	}
};

///Address extension packet 
/**
	An address extension packet is like a normal request packet, but
	it contains an extra 32 bits of address extension
*/
class AddressExtensionPacket: public RequestPacket{

	sc_bv<32> addrExtension;

public :

	///Constructor with a 32 bit vector
	/**
		@param dWord The least significant 32 bits that represents packet
	*/
	AddressExtensionPacket(const sc_bv<32> &dWord) : RequestPacket(dWord){
		addrExtension.range(5,0) = "111110";
	}

	///Constructor with a 64 bit vector
	/**
		@param qWord The 64 bits that represents packet
	*/
	AddressExtensionPacket(const sc_bv<64> &qWord) : RequestPacket(qWord){
		addrExtension.range(5,0) = "111110";
	}

	///Constructor with specific extended address
	/**
		@param addrExt The 24-bit address extension
		@param dWord The lower 32 bits that represents packet
	*/
	AddressExtensionPacket(const sc_bv<24> &addrExt,const sc_bv<32> &dWord) 
		: RequestPacket(dWord),addrExtension()
	{
		addrExtension.range(5,0) = "111110";
		addrExtension.range(31,8) = addrExtension;
	}

	///Constructor with specific extended address
	/**
		@param qWord The 64 bits that represents packet
		@param addrExt The 32-bit address extension
	*/
	AddressExtensionPacket(const sc_bv<32> &addrExt,const sc_bv<64> &qWord) 
		: RequestPacket(qWord),addrExtension()
	{
		addrExtension.range(5,0) = "111110";
		addrExtension.range(31,8) = addrExtension;
	}

	virtual PacketCommand getPacketCommand() const{return ADDR_EXT;}

	virtual PacketCommand getInternalPacketCommand() const{
		return ControlPacket::getPacketCommand(bv.range(5,0));
	}

	virtual PacketType getPacketType() const{return ADDR_EXT_TYPE;}

	virtual PacketType getInternalPacketType() const{
		return ControlPacket::getPacketType(bv.range(5,0));
	}

	sc_bv<32> getAddressExtension(){ return addrExtension; }

	virtual ControlPacket* getCopy() const{
		return new AddressExtensionPacket(addrExtension,bv);
	}
};


#endif
