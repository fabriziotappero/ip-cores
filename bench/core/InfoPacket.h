//InfoPacket.h
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

#ifndef InfoPacket_H
#define InfoPacket_H

#ifndef SC_USER_DEFINED_MAX_NUMBER_OF_PROCESSES
#define SC_USER_DEFINED_MAX_NUMBER_OF_PROCESSES
#define SC_VC6_MAX_NUMBER_OF_PROCESSES 20
#endif
#include <systemc.h>

#include "ControlPacket.h"
#include "../../rtl/systemc/core_synth/ht_type_include.h"


///Base class for all info packets
/**
	An information packet is packet that does not travel through the
	chain but only caries information on a single link.
*/
class InfoPacket: public ControlPacket{

public:

	///Default constructor
	/**
		Creates an empty packet with a vector filled with 0.
	*/
	InfoPacket(){}

	///Constructor with a 32 bit vector
	/**
		@param dWord The least significant 32 bits that represents packet
	*/
	InfoPacket(const sc_bv<32> &dWord) : ControlPacket(dWord){}

	///Constructor with a 64 bit vector
	/**
		@param qWord The 64 bits that represents packet
	*/
	InfoPacket(const sc_bv<64> &qWord) : ControlPacket(qWord){}

	///If the packet type is 32 bits
	/**
		@return true If the packet type is 32 bits.  
	*/	
	virtual bool isDwordPacket() const = 0;

	///If packet has data associated
	/**
		To know if there is a data packet associated with this control
		packet.  No info packet has any data associated.

		@return false
	*/	
	virtual bool hasDataAssociated() const {return false;};


	///Get the <code>VirtualChannel</code> of the packet
	/**
		To get the virtual channel of this packet
		Packet can travel in different channels depending on their function
		and of their attributes.  Since information packets do not travel on
		the chain, they are not part of a virtual channel hence why VC_NONE
		is returned.

		@return The VirtualChannel VC_NONE
	*/	
	virtual VirtualChannel getVirtualChannel() const {return VC_NONE;}

	///Get the type of this packet
	/**
		InfoPacket objects are always of type INFO

		@return The INFO PacketType
	*/	
	virtual PacketType getPacketType() const {return INFO;}

	virtual PacketCommand getPacketCommand() const = 0;

	///If packet part of chain
	/**
		InfoPacket packets are never part of a chain

		@return false
	*/	
	virtual bool isChain() const { return false;}

	///If packet is a NopPacket
	/**
		@return true if this is a nop packet, false otherwise
	*/
	virtual bool isNopPacket() const = 0;

	///If packet is a SyncPacket
	/**
		@return true if this is a sync packet, false otherwise
	*/
	virtual bool isSyncPacket() const = 0;

	///Get the length-1 of the data associated
	/**
		Info packets don't have data associated.

		@return A 0 length.
	*/
	sc_uint<4> getDataLengthm1() const {return 0; }
	
	virtual ControlPacket* getCopy() const = 0;

	virtual bool getPassPW() const{return false;}

};

///Nop info packet 
/**
	A NopPacket has two function : as it names says, it is used when there
	is no data to send on the chain since a packet has to be sent at every
	bit time.  Secondly, it also carries the count of the buffers that
	become available to establish a flow control.  It is a way of making sure
	that buffers never overflow.
*/
class NopPacket: public InfoPacket{

public:

	/**
		Constructor for a nop packet

		@param freeBufResponseCmd	The number of command buffers in the response VC that were freed
		@param freeBufResponseData	The number of data buffers in the response VC that were freed
		@param freeBufPostedCmd		The number of command buffers in the posted VC that were freed
		@param freeBufPostedData	The number of data buffers in the posted VC that were freed
		@param freeBufNonPostedCmd	The number of command buffers in the non-posted VC that were freed
		@param freeBufNonPostedData	The number of data buffers in the non-posted VC that were freed
		@param disCon	To disconnect the link
		@param diag		Indicates the befinning of a CRC testing phase
		@param isoc		If the freed buffers are in isochronous virtual channels
		@param rxNextPacketToAck
	*/
	NopPacket(const sc_uint<2> freeBufResponseCmd = 0,
		      const sc_uint<2> freeBufResponseData = 0,
			  const sc_uint<2> freeBufPostedCmd = 0,
			  const sc_uint<2> freeBufPostedData = 0,
			  const sc_uint<2> freeBufNonPostedCmd = 0,
			  const sc_uint<2> freeBufNonPostedData = 0,
			  const bool disCon = false, bool diag = false,
			  const bool isoc = false,
			  const sc_bv<8> rxNextPacketToAck = "00000000"){
	
		bv[6] = disCon;
		bv.range(9,8)   = freeBufPostedCmd;
		bv.range(11,10) = freeBufPostedData;
		bv.range(13,12) = freeBufResponseCmd;
		bv.range(15,14) = freeBufResponseData;
		bv.range(17,16) = freeBufNonPostedCmd;
		bv.range(19,18) = freeBufNonPostedData;
		bv[21] = isoc;
		bv[22] = diag;
		bv.range(31,24) = rxNextPacketToAck;
	}

	///Constructor with a 32 bit vector
	/**
		@param dWord The least significant 32 bits that represents packet
	*/
	NopPacket(const sc_bv<32> &dWord) : InfoPacket(dWord){}

	///Constructor with a 64 bit vector
	/**
		@param qWord The 64 bits that represents packet
	*/
	NopPacket(const sc_bv<64> &qWord) : InfoPacket(qWord){}

	///If packet is a NopPacket
	/**
		@return true 
	*/
	bool isNopPacket() const {return true;}

	///If packet is a SyncPacket
	/**
		@return false
	*/
	bool isSyncPacket() const {return false;}

	///To get the command of the packet
	/**
		@return NOP
	*/	
	virtual PacketCommand getPacketCommand() const{return NOP;}

	ControlPacket* getCopy() const{
		return new NopPacket(bv);
	}

	/**
		@return The number of command buffers in the posted VC that were freed
	*/
	sc_uint<2> getFreeBufPostedCmd() const{
		return (sc_bv<2>)bv.range(9,8);
	}

	/**
		@return The number of data buffers in the posted VC that were freed
	*/
	sc_uint<2> getFreeBufPostedData() const{
		return (sc_bv<2>)bv.range(11,10);
	}

	/**
		@return The number of command buffers in the response VC that were freed
	*/
	sc_uint<2> freeBufResponseCmd() const{
		return (sc_bv<2>)bv.range(13,12);
	}

	/**
		@return The number of data buffers in the response VC that were freed
	*/
	sc_uint<2> freeBufResponseData() const{
		return (sc_bv<2>)bv.range(15,14);
	}

	/**
		@return The number of command buffers in the non-posted VC that were freed
	*/
	sc_uint<2> freeBufNonPostedCmd() const{
		return (sc_bv<2>)bv.range(17,16);
	}

	/**
		@return The number of data buffers in the non-posted VC that were freed
	*/
	sc_uint<2> freeBufNonPostedData() const{
		return (sc_bv<2>)bv.range(19,18);
	}

	/**
		@return The ack number of the NOP
	*/
	sc_uint<8> getRxNextPacketToAck(){
		return (sc_bv<8>)bv.range(31,24);
	}

	///If the packet type is 32 bits
	/**
		@return If the packet type is 32 bits.  (always true)
	*/	
	virtual bool isDwordPacket() const { return true;}
};

///Sync info packet 
/**
	A SyncPacket is sent on a link to reinitialize the chain
	completely.
*/
class SyncPacket: public InfoPacket{

public:

	///Default constructor
	/**
		Constructs a packet with the lowest 32 bits filled with ones
	*/
	SyncPacket(){
		bv = "11111111111111111111111111111111";
	}

	///Constructor with a 32 bit vector
	/**
		@param dWord The least significant 32 bits that represents packet
	*/
	SyncPacket(const sc_bv<32> &dWord) : InfoPacket(dWord){}

	///Constructor with a 64 bit vector
	/**
		@param qWord The 64 bits that represents packet
	*/
	SyncPacket(const sc_bv<64> &qWord) : InfoPacket(qWord){}

	ControlPacket* getCopy() const{
		return new SyncPacket(bv);
	}

	///To get the command of the packet
	/**
		@return SYNC
	*/	
	virtual PacketCommand getPacketCommand() const{return SYNC;}

	///If packet is a NopPacket
	/**
		@return false
	*/
	bool isNopPacket() const {return false;}

	///If packet is a SyncPacket
	/**
		@return true
	*/
	bool isSyncPacket() const {return true;}


	///If the packet type is 32 bits
	/**
		@return true If the packet type is 32 bits.  (always true)
	*/	
	virtual bool isDwordPacket() const { return true;}

};

///Extended flow control packet 
/**
	A flow control packet used to manage buffers for VCSets 0-7.
	We do not support VCSets 0-7, but we support the extended flow
	control packet
*/
class ExtendedFlowControlPacket: public InfoPacket{

public:

	/**
		Constructor for ExtendedFlowControlPacket

		@param vcSet defines which vcSet this this packet is ontrolling the buffers of
		@param vcSetFree0 Freed buffer data
		@param rxNextPacketToAck used by the retry protocol
		@param vcSetRsv optional for proprietery use between devices
	*/
	ExtendedFlowControlPacket(const sc_bv<3> &vcSet,
			  const sc_bv<8> &vcSetFree0,
			  const sc_bv<8> rxNextPacketToAck = "00000000",
			  const sc_bv<4> vcSetRsv = "0000"){
		
		sc_bv<6> command = "110111";
		bv.range(5,0) = command;
		bv[6] = false;
		bv(10,8) = vcSet;
		bv.range(15,12) = vcSetRsv;
		bv.range(23,16) = vcSetFree0;
		bv.range(31,24) = rxNextPacketToAck;

	}

	/**
		Constructor for ExtendedFlowControlPacket

		@param vcSet defines which vcSet this this packet is ontrolling the buffers of
		@param vcSetFree0 Freed buffer data
		@param vcSetFree1 Freed buffer data
		@param vcSetFree2 Freed buffer data
		@param vcSetFree3 Freed buffer data
		@param rxNextPacketToAck used by the retry protocol
		@param vcSetRsv optional for proprietery use between devices
	*/
	ExtendedFlowControlPacket(const sc_bv<3> &vcSet,
			  const sc_bv<8> &vcSetFree0,
			  const sc_bv<8> &vcSetFree1,
			  const sc_bv<8> &vcSetFree2,
			  const sc_bv<8> &vcSetFree3,
			  const sc_bv<8> rxNextPacketToAck = "00000000",
			  const sc_bv<4> vcSetRsv = "0000"){

		sc_bv<6> command =  "110111";
		bv.range(5,0) = command;
		bv[6] = true;
		bv(10,8) = vcSet;
		bv.range(15,12) = vcSetRsv;
		bv.range(23,16) = vcSetFree0;
		bv.range(31,24) = vcSetFree1;
		bv.range(39,32) = vcSetFree2;
		bv.range(47,40) = vcSetFree3;
		bv.range(63,56) = rxNextPacketToAck;
	
	}

	///Constructor with a 32 bit vector
	/**
		@param dWord The least significant 32 bits that represents packet
	*/
	ExtendedFlowControlPacket(const sc_bv<32> &dWord) : InfoPacket(dWord){}

	///Constructor with a 64 bit vector
	/**
		@param qWord The 64 bits that represents packet
	*/
	ExtendedFlowControlPacket(const sc_bv<64> &qWord) : InfoPacket(qWord){}

	ControlPacket* getCopy() const{
		return new ExtendedFlowControlPacket(bv);
	}

	///To get the command of the packet
	/**
		@return EXTENDED_FLOW
	*/	
	virtual PacketCommand getPacketCommand() const{return EXTENDED_FLOW;}

	///If packet is a NopPacket
	/**
		@return false
	*/
	bool isNopPacket() const {return false;}

	///If packet is a SyncPacket
	/**
		@return false
	*/
	bool isSyncPacket() const {return true;}


	///If the packet type is 32 bits
	/**
		@return If the packet type is 32 bits.  
	*/	
	virtual bool isDwordPacket() const { return !((bool)((sc_bit)bv[6]));}

};

#endif
