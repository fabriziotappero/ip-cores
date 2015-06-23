//synth_control_packet.h
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

#ifndef SYNTH_CONTROL_PACKET_H
#define SYNTH_CONTROL_PACKET_H

///General functions used by synthesized modules (a toolbox)
/**
	@file synth_control_packet.h
	@author Ami Castonguay
	@description Datatypes that can be used for synthesis
*/

/**
	Transforms the 6 bits of the HT command to an enum
	which is easier to understand in the code
	@param cmd The 6 bits of the command in the packet
	@return The enum of the command associated
*/
PacketCommand getPacketCommand(const sc_bv<6> &cmd);

/**
	To get the packet type (family) from the 6 bits command
	vector.
	@param cmd The 6 bits of the command in the packet
	@return The enum of the packet type.
*/
PacketType getPacketType(const sc_bv<6> &cmd);


///If the packet type is 32 bits
/**
	To know if the packet type is 32 bits.  If not true, the command
	packet is 64 bits.

	@param pkt All the bits of the packet
	@param cmd The decoded command of the packet
	@return True if the packet is of a type that is 32 bits (dword)
	or false otherwise.
*/	
bool isDwordPacket(const sc_bv<64> &pkt, const PacketCommand &cmd);

/**
	To get the virtual channel of the packet.
	@param pkt All the bits of the packet
	@param cmd The decoded command of the packet
	@return the Virtual Channel of the packet
*/
VirtualChannel getVirtualChannel(const sc_bv<64> &pkt, const PacketCommand &cmd);

///Packet part of chain
/**
	Some packets are part of chain that can not be interrupted.  This checks
	if the packet is part of such a chain

	@param pkt All the bits of the packet
	@return If the packet is part a a chain
*/	
bool isChain(const sc_bv<64> &pkt);

///Command packet has a data packet associated to it
/**
	When sending data, a command packet is sent first as the header
	of the data.  This checks if the command packet has data associated
	to it.

	@param cmd The decoded command of the packet
	@return If the packet has data associated
*/	
bool hasDataAssociated(const PacketCommand &cmd);

///Get length of the data packet associated with this command packet
/**
	This gets the length in dwords of the data packet associated to this
	command packet

	@param pkt All the bits of the packet
	@param cmd The decoded command of the packet
	@return The length (minus 1) in dwords
*/	
sc_uint<4> getDataLengthm1(const sc_bv<64> &pkt);

///Get length of the packet, data included
/**
	This gets the length in dwords of the packet with it's data
	packet if any

	@param pkt All the bits of the packet
	@param cmd The decoded command of the packet
	@return The length (minus 1) in dwords
*/	
sc_uint<5> getPacketSizeWithDatam1(const sc_bv<64> &pkt, const PacketCommand &cmd);

//Get length of the packet, data included, when we know the packet is a dword packet
/**
	This gets the length in dwords of the packet with it's data
	packet if any.  This does the same thing as getPacketSizeWithDatam1, except
	it doesn't look up if it is a dword or qword packet, it's only for dword packets.

	@param pkt All the bits of the packet
	@param cmd The decoded command of the packet
	@return The length (minus 1) in dwords
*/	
sc_uint<5> getDwordPacketSizeWithDatam1(const sc_bv<64> &pkt, const PacketCommand &cmd);

///If the packet can pass posted write packets
/**
	If this packet is allowed to pass posted write packets (passPW bit)

	@param pkt All the bits of the packet
	@return If the packet can pass posted write packets
*/	
bool getPassPW(const sc_bv<64> &pkt);

///If the response packet can pass posted write packets
/**
	If this packet is allowed to pass posted write packets (passPW bit)

	@param pkt All the bits of the packet
	@return If the packet can pass posted write packets
*/	
bool getResponsePassPW(const sc_bv<32> &pkt);

///Get target address of packet
/**
	Packet that have action on memory (read, write, atomic) include
	an address to indicate where to do that operation.  This gets
	that particular address.

	@param request_pkt All the bits of the packet
	@param cmd The decoded command of the packet
	@return The 40 bit targe address of the packet
*/	
sc_uint<40> getRequestAddr(const sc_bv<64> &request_pkt, const PacketCommand &cmd);

///Get unitID
/**
	Packet use unitID to identify the source or destination of the packet.  This gets
	that unitID

	@param pkt All the bits of the packet
	@return The unitID of the packet
*/	
sc_uint<5> getUnitID(const sc_bv<64> &pkt);

///Get compatibility bit (which is instead isoc bit in some cases)
/**
	Packets contain a bit to say if the packet should be decoded by
	the compatibility decoder.  Some types of packets use that same
	bit to know if the packet should travel in isochronous channels.

	@param pkt All the bits of the packet
	@return If the compat/isoc bit is '1'
*/	
bool request_getCompatOrIsoc(const sc_bv<64> &pkt);

///If the packet's target address is within that address range
/**
	@param pkt All the bits of the packet
	@param cmd The decoded command of the packet
	@param low The low value of the address to compare to
	@param high The high value of the address to compare to
	@return If the packet targe address is between low and high
*/
bool isInAddressRange(const sc_bv<64> &pkt,  const PacketCommand &cmd, const sc_uint<32> &low,
									 const sc_uint<32> &high);

#ifdef SYSTEMC_SIM
///If the packet's target address is within that address range
/**
	@param pkt All the bits of the packet
	@param cmd The decoded command of the packet
	@param low The low value of the address to compare to
	@param high The high value of the address to compare to
	@return If the packet targe address is between low and high
*/
bool isInAddressRange(const sc_bv<64> &pkt,  const PacketCommand &cmd, const sc_uint<40> &low,
									 const sc_uint<40> &high);

///If the packet's target address is within that address range
/**
	@param pkt All the bits of the packet
	@param cmd The decoded command of the packet
	@param low The low value of the address to compare to
	@param high The high value of the address to compare to
	@return If the packet targe address is between low and high
*/
bool isInAddressRange(const sc_bv<64> &pkt,  const PacketCommand &cmd, const sc_bv<40> &low, 
					  const sc_bv<40> &high) ;
#endif

///Get the sequence ID of a request
/**
	Resquest packets have a sequenceID to indicates if the
	packet is part of sequence (if seqID is other than 0).  This returns
	the sedID of the packet

	@param pkt All the bits of the packet
	@return The seqID bit of the packet
*/	
sc_bv<4> request_getSeqID(const sc_bv<64> &pkt);

///Get data error field of a write packet
/**
	Write packets include an error field to indicate if an error
	occured during transmission (or other, see spec).
	@param pkt All the bits of the packet
	@return The error code in the packet
*/	
bool write_getDataError(const sc_bv<64> &pkt);

///Get data error field of a response packet
/**
	Write packets include an error field to indicate if an error
	occured during transmission or the operation.
	@param pkt All the bits of the packet
	@return The error code in the packet
*/	
ResponseError response_getResponseError(const sc_bv<64> &pkt);

///Get src tag of a non-posted packet
/**
	Non posted packets on the link are all identified by a unique
	number (that number can be re-used once the response to that
	packet has been received).  That number is the srcTag.  This
	retreives thos bits from the command packet

	@param pkt All the bits of the packet
	@return The src tag of the packet
*/	
sc_bv<5> request_getSrcTag(const sc_bv<64> &pkt) ;

///Generate a command read response packet
/**
	@param unitID - UnitID of the HT node
	@param srcTag - srcTag of the request
	@param rqUID - last two bit of the requester's unitID when bridfe = false
	@param count - Size of the data (-1)
	@param bridge - If this comes from the bridge (should be false)
	@param error - Any error code
	@param passPW - If the request was passPW
	@param isoc - If the request was isoc
*/	
sc_bv<32> generateReadResponse(const sc_bv<5> &unitID,
						 const sc_bv<5> &srcTag,
						 const sc_bv<2> &rqUID,
						 const sc_bv<4> &count,
						 bool bridge,
						 ResponseError error,
						 bool passPW,
						 bool isoc);

///Generate a command TargetDone packet
/**
	@param unitID - UnitID of the HT node
	@param srcTag - srcTag of the request
	@param rqUID - last two bit of the requester's unitID when bridfe = false
	@param bridge - If this comes from the bridge (should be false)
	@param error - Any error code
	@param passPW - If the request was passPW
	@param isoc - If the request was isoc
*/	
sc_bv<32> generateTargetDone(const sc_bv<5> &unitID,
						 const sc_bv<5> &srcTag,
						 const sc_bv<2> &rqUID,
						 bool bridge,
						 ResponseError error,
						 bool passPW,
						 bool isoc);

#endif
