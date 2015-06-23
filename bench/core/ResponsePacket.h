//ResponsePacket.h
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

#ifndef ResponsePacket_H
#define ResponsePacket_H

#ifndef SC_USER_DEFINED_MAX_NUMBER_OF_PROCESSES
#define SC_USER_DEFINED_MAX_NUMBER_OF_PROCESSES
#define SC_VC6_MAX_NUMBER_OF_PROCESSES 20
#endif
#include <systemc.h>

#include "ControlPacket.h"

///Response packets
/**
	A packet of type response is issued to respond to a request packet
*/
class ResponsePacket: public ControlPacket{

public:

	///Constructor with a 32 bit vector
	/**
		@param dWord The least significant 32 bits that represents packet
	*/
	ResponsePacket(const sc_bv<32> &dWord) : ControlPacket(dWord){}

	///Constructor with a 64 bit vector
	/**
		@param qWord The 64 bits that represents packet
	*/
	ResponsePacket(const sc_bv<64> &qWord) : ControlPacket(qWord){}

	///Constructor with specific parameters for responses
	/**
		This allows to construct a packet with parameters that are generic
		to all response packets

		@param command  The command of the packet, defines the exact type of the
						packet.
		@param unitID	unitID of the device that sent the response
		@param srcTag	srcTag allows to track non-posted packets.  When a non-posted packet
						is sent with a srcTag, another non-posted packet with that same
						srcTag cannot be sent before a response is received for the original
						request.  This is the srcTag of the request paquet that this
						response packet is responding to
		@param rqUID	When bridge == 0, this is the last two bits of the unitID of the device
						that sent the request this response is responding to
		@param bridge	If this packet comes from the host or a bridge
		@param error	Error returned in the packet
		@param passPW	If this packet can pass posted writes (increased priority)
		@param isoc		This bit either represents if the packet travels in isoc channels 
						(increased priority)
	*/
	ResponsePacket(const sc_bv<6> &command,
					   const sc_bv<5> &unitID,
					   const sc_bv<5> &srcTag,
					   const sc_bv<2> &rqUID,
					   bool bridge,
					   ResponseError error = RE_NORMAL,
					   bool passPW = 0,
					   bool isoc = 0);

	///If the packet type is 32 bits
	/**
		All response packets are 32 bits

		@return true
	*/	
	virtual bool isDwordPacket() const {return true;}

	/**
		@return unitID of the device that sent the response
	*/
	sc_bv<5> getUnitID() const;

	virtual bool hasDataAssociated() const;

	///If packet part of chain
	/**
		@return false
	*/	
	virtual bool isChain() const {return false;}

	///Get the SrcTag of the response
	/**
		@return SrcTag of the response
	*/	
	virtual sc_uint<5> getSrcTag() const {return (sc_bv<5>)bv.range(20,16);}

	///Get the <code>VirtualChannel</code> of the packet
	/**
		To get the virtual channel of this packet
		Packet can travel in different channels depending on their function
		and of their attributes.  Responses always travel in the Response
		virtual channel

		@return The VirtualChannel VC_RESPONSE
	*/	
	virtual VirtualChannel getVirtualChannel() const {return VC_RESPONSE;}

	///Get the type of this packet
	/**
		@return The RESPONSE PacketType
	*/	
	virtual PacketType getPacketType() const {return RESPONSE;}

	virtual PacketCommand getPacketCommand() const = 0;

	virtual sc_uint<4> getDataLengthm1() const;

	virtual ControlPacket* getCopy() const = 0;

	virtual bool getPassPW() const;

	/**
		@return The error contained in the packet
	*/	
	ResponseError getResponseError() const;
};


///ReadResponse response packet 
/**
	The ReadResponsePacket is sent in response to a read request.
*/
class ReadResponsePacket: public ResponsePacket{

public:

	///Constructor with a 32 bit vector
	/**
		@param dWord The least significant 32 bits that represents packet
	*/
	ReadResponsePacket(const sc_bv<32> &dWord) : ResponsePacket(dWord){}

	///Constructor with a 64 bit vector
	/**
		@param qWord The 64 bits that represents packet
	*/
	ReadResponsePacket(const sc_bv<64> &qWord) : ResponsePacket(qWord){}

	///Constructor with specific parameters for responses
	/**
		This allows to construct a packet with parameters that are generic
		to all response packets

		@param unitID	unitID of the device that sent the response
		@param srcTag	srcTag allows to track non-posted packets.  When a non-posted packet
						is sent with a srcTag, another non-posted packet with that same
						srcTag cannot be sent before a response is received for the original
						request.  This is the srcTag of the request paquet that this
						response packet is responding to
		@param rqUID	When bridge == 0, this is the last two bits of the unitID of the device
						that sent the request this response is responding to
		@param count	The count of dwords being sent in the data packet associated to this
						ReadResponsePacket
		@param bridge	If this packet comes from the host or a bridge
		@param error	Error returned in the packet
		@param passPW	If this packet can pass posted writes (increased priority)
		@param isoc		This bit either represents if the packet travels in isoc channels 
						(increased priority)
	*/
	ReadResponsePacket(const sc_bv<5> &unitID,
						 const sc_bv<5> &srcTag,
						 const sc_bv<2> &rqUID,
						 const sc_bv<4> &count,
						 bool bridge,
						 ResponseError error = RE_NORMAL,
						 bool passPW = 0,
						 bool isoc = 0) :
		ResponsePacket(sc_bv<6>("110000"),
						  unitID,
						  srcTag,
						  rqUID,
						  bridge,
						  error,
						  passPW,
						  isoc)
	{
		bv.range(25,22) = count;
	}

	///To get the command of the packet
	/**
		@return RD_RESPONSE
	*/	
	virtual PacketCommand getPacketCommand() const{return RD_RESPONSE;}

	ControlPacket* getCopy() const{
		return new ReadResponsePacket(bv);
	}

};

///TargetDone response packet 
/**
	TargetDonePacket is sent to say that something has been completed.
	For example it can be a non-posted write or a flush request.
*/
class TargetDonePacket: public ResponsePacket{

public:

	///Constructor with a 32 bit vector
	/**
		@param dWord The least significant 32 bits that represents packet
	*/
	TargetDonePacket(const sc_bv<32> &dWord) : ResponsePacket(dWord){}

	///Constructor with a 64 bit vector
	/**
		@param qWord The 64 bits that represents packet
	*/
	TargetDonePacket(const sc_bv<64> &qWord) : ResponsePacket(qWord){}

	///Constructor with specific parameters for responses
	/**
		This allows to construct a packet with parameters that are generic
		to all response packets

		@param unitID	unitID of the device that sent the response
		@param srcTag	srcTag allows to track non-posted packets.  When a non-posted packet
						is sent with a srcTag, another non-posted packet with that same
						srcTag cannot be sent before a response is received for the original
						request.  This is the srcTag of the request paquet that this
						response packet is responding to
		@param rqUID	When bridge == 0, this is the last two bits of the unitID of the device
						that sent the request this response is responding to
		@param bridge	If this packet comes from the host or a bridge
		@param error	Error returned in the packet
		@param passPW	If this packet can pass posted writes (increased priority)
		@param isoc		This bit either represents if the packet travels in isoc channels 
						(increased priority)
	*/
	TargetDonePacket(const sc_bv<5> &unitID,
						 const sc_bv<5> &srcTag,
						 const sc_bv<2> &rqUID,
						 bool bridge,
						 ResponseError error = RE_NORMAL,
						 bool passPW = 0,
						 bool isoc = 0) :
		ResponsePacket(sc_bv<6>("110011"),
						  unitID,
						  srcTag,
						  rqUID,
						  bridge,
						  error,
						  passPW,
						  isoc)
	{
	}

	///To get the command of the packet
	/**
		@return TGTDONE
	*/	
	virtual PacketCommand getPacketCommand() const{return TGTDONE;}

	ControlPacket* getCopy() const{
		return new TargetDonePacket(bv);
	}


};

#endif

