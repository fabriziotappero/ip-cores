//synth_control_packet.cpp

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

#ifndef SYNTH_CONTROL_PACKET_CPP
#define SYNTH_CONTROL_PACKET_CPP

#include "synth_datatypes.h"

/**
	To parse a cmd vector
*/
PacketCommand getPacketCommand(const sc_bv<6> &cmd){

	//Check the command vector against all known
	//sequences
	sc_uint<6> command_value = cmd;

	PacketCommand return_val;

	switch(command_value){
	case 0:
		return_val = NOP;
		break;
	case 0x3F: //0b111111
		return_val = SYNC;
		break;
	case 0x30: //0b110000
		return_val = RD_RESPONSE;
		break;
	case 0x33: //0b110011
		return_val = TGTDONE;
		break;
	case 0x3A: //0b111010
		return_val = BROADCAST;
		break;
	case 0x3C: //0b111100
		return_val = FENCE;
		break;
	case 0x3D: //0b111101
		return_val = ATOMIC;
		break;
	case 0x37: //0b110111
		return_val = EXTENDED_FLOW;
		break;
	case 0x3E: //0b111110
		return_val = ADDR_EXT;
		break;
	case 0x02: //0b000010
		return_val = FLUSH;
		break;
	default:
		if(command_value.range(4 , 3) == 1){//		if(command_value.range(4 , 3) == "01"){
			return_val = WRITE;
		}
		else if(command_value.range(5 , 4) == 1){//else if(command_value.range(5 , 4) == "01"){
			return_val = READ;
		}
		else{
			return_val = RESERVED_CMD;
		}

	}
	return return_val;
}

/**
	To know the type of packet from a command vector
*/
PacketType getPacketType(const sc_bv<6> &cmd){

	PacketType return_val;

	sc_bv<6> cmd_buf = cmd;//Workaround for a synthesis problem

	//Check the command vector against all known
	//sequences
	if(cmd_buf == "000000" || cmd_buf == "111111" || cmd_buf == "110111"){
		return_val = INFO;
	}
	else if(cmd_buf == "110000" || cmd_buf == "110011"){
		return_val = RESPONSE;		
	}
	else if(cmd_buf.range(5 , 3) == "001" || cmd_buf.range(5 , 3) == "101"
		|| cmd_buf.range(5 , 4) == "01" || cmd_buf == "111010"
		|| cmd_buf == "111100" || cmd_buf == "111101" || cmd_buf == "000010")
	{
		return_val = REQUEST; 	   
	}
	else if(cmd_buf == "111101"){
		return_val = ADDR_EXT_TYPE;
	}
	else{
		return_val = RESERVED_TYPE;
	}
	return return_val;
}

bool isDwordPacket(const sc_bv<64> &pkt, const PacketCommand &cmd){
	bool return_val;

	switch(cmd){
	case WRITE:
	case READ:
	case BROADCAST:
	case ATOMIC:
	case RESERVED_CMD:
		return_val = false;
		break;
	case EXTENDED_FLOW:
		return_val = !(bool)((sc_bit)pkt[6]);
		break;
	//case ADDR_EXT:
	//case FLUSH:
	//case NOP:
	//case SYNC:
	//case RD_RESPONSE:
	//case TGTDONE:
	//case FENCE:
	default:
		return_val = true;

	}
	return return_val;

}

VirtualChannel getVirtualChannel(const sc_bv<64> &pkt, const PacketCommand &cmd){

	VirtualChannel return_val;

	switch(cmd){
	case WRITE:
		if(pkt[5] == true){
			return_val = VC_POSTED;
		}
		else{
			return_val = VC_NON_POSTED;	
		}
		break;
	case ATOMIC:
	case FLUSH:
	case READ:
		return_val = VC_NON_POSTED;
		break;
	case FENCE:
	case BROADCAST:
		return_val = VC_POSTED;
		break;

	case RD_RESPONSE:
	case TGTDONE:
		return_val = VC_RESPONSE;
		break;

	//case SYNC:
	//case RESERVED_CMD:
	//case ADDR_EXT:
	//case NOP:
	//case EXTENDED_FLOW:
	default:
		return_val = VC_NONE;

	}
	return return_val;
}

bool isChain(const sc_bv<64> &pkt){
	bool return_val;
	//if(posted && write && bit chain)
	if(pkt.range(5 , 3) == "101" &&
	   pkt[19] == true) return_val = true;
	else return_val = false;
	return return_val;
}

///Packet has data associated
/**
		To know if there is a data packet associated with this control
		packet

		@return If the packet has data associated
*/	
bool hasDataAssociated(const PacketCommand &cmd){
	bool return_val;

	switch(cmd){
	case WRITE:
	case RD_RESPONSE:
	case ATOMIC:
		return_val = true;
		break;

	//case TGTDONE:
	//case SYNC:
	//case RESERVED_CMD:
	//case ADDR_EXT:
	//case NOP:
	//case EXTENDED_FLOW:
	//case FLUSH:
	//case BROADCAST:
	//case FENCE:
	//case READ:
	default:
		return_val = false;
		break;

	}

	return return_val;

}

///Get the length-1 of the data associated
/**
		Gets the number of doublewords of data associated with this ctl packet
		minus 1.  So a returned number of 0 represents 1 doubleWord.
		If there is no data associated, the result is undefined.
		The number returned also includes the doubleword mask in a byte write

		@return Length-1 of data associated with the packet, or undefined
		if the packet has no data associated
*/
sc_uint<4> getDataLengthm1(const sc_bv<64> &pkt){
	sc_uint<4> return_val;
	
	//If a byte read (cmd starts by 01 for read, and pkt[2]=0 for byte
	if(pkt[5] == false && pkt[4] == true && pkt[2] == false){
		//DataLength is Doubleword
		return_val = 0;
	}
	else{
		sc_bv<4> temp = pkt.range(25,22);
		return_val = temp;
	}
	return return_val;
}

bool getPassPW(const sc_bv<64> &pkt){
	return (sc_bit)(pkt[15]);
}

bool getResponsePassPW(const sc_bv<32> &pkt){
	return (sc_bit)(pkt[15]);
}

sc_uint<40> getRequestAddr(const sc_bv<64> &request_pkt, const PacketCommand &cmd){
	sc_uint<40> addr = 0;

	//If the packet only has 32 bits, dont return an address
	//of only zeros, its the job of the caller to check before calling
	//
	//if(!isDwordPacket(request_pkt,cmd)) {

		//Copy the standard range of addresses
		addr.range(39,3) = sc_bv<37>(request_pkt.range(63,27));

		//Copy the last bit of the address.  An exception is made for
		//the ATOMIC packet, that has this bit always at 0
		if(cmd != ATOMIC) addr[2] = sc_bit(request_pkt[26]);
	//}

	//Return the address
	return addr;
}


sc_uint<5> getUnitID(const sc_bv<64> &pkt){
	return sc_bv<5>(pkt.range(12,8));
}

bool request_getCompatOrIsoc(const sc_bv<64> &pkt){
	return sc_bit(pkt[21]);
}



bool isInAddressRange(const sc_bv<64> &pkt,  const PacketCommand &cmd, const sc_uint<32> &low,
										 const sc_uint<32> &high) {
	bool isInAddressRange_val = false;
	if(!isDwordPacket(pkt,cmd)){
		sc_uint<32> addr = getRequestAddr(pkt,cmd).range(39,8);
		isInAddressRange_val = (addr >= low && addr < high);
	}
	return isInAddressRange_val;
}

#ifdef SYSTEMC_SIM

bool isInAddressRange(const sc_bv<64> &pkt,  const PacketCommand &cmd, const sc_uint<40> &low,
										 const sc_uint<40> &high) {
	bool isInAddressRange_val = false;
	if(!isDwordPacket(pkt,cmd)){
		sc_uint<40> addr = getRequestAddr(pkt,cmd);
		isInAddressRange_val = (addr >= low && addr < high);
	}
	return isInAddressRange_val;
}

										 bool isInAddressRange(const sc_bv<64> &pkt,  const PacketCommand &cmd, const sc_bv<40> &low, const sc_bv<40> &high) {
	//Start by converting the strings to uint
	sc_uint<40> low_uint(low);
	sc_uint<40> high_uint(high);

	//Call the function taking uints
	return isInAddressRange(pkt,cmd,low_uint,high_uint);
}
#endif

sc_bv<4> request_getSeqID(const sc_bv<64> &pkt){
	sc_bv<4> temp;
	temp.range(3,2) = pkt.range(7,6);
	temp.range(1,0) = pkt.range(14,13);
	return temp;
}

bool write_getDataError(const sc_bv<64> &pkt) {
	bool dataError;
	if(pkt[5] == true) dataError = sc_bit(pkt[20]);
	else dataError = false;
	return dataError;
}

ResponseError response_getResponseError(const sc_bv<64> &pkt) {
	ResponseError error;
	if(pkt[21] == false){
		if(pkt[29] == false) error = RE_NORMAL;
		error = RE_DATA_ERROR;
	}
	else{
		if(pkt[29] == false) error = RE_TARGET_ABORT;
		error = RE_MASTER_ABORT;
	}
	return error;
}

sc_bv<5> request_getSrcTag(const sc_bv<64> &pkt) {
	return pkt.range(20,16);
}

sc_bv<32> generateReadResponse(const sc_bv<5> &unitID,
						 const sc_bv<5> &srcTag,
						 const sc_bv<2> &rqUID,
						 const sc_bv<4> &count,
						 bool bridge,
						 ResponseError error,
						 bool passPW,
						 bool isoc)
{
	sc_bv<32> packet = 0;
	packet.range(25,22) = count;

	sc_bv<6> packet_command = "110000"; 
	packet.range(5,0) = packet_command;
	packet.range(12,8) = unitID;
	packet.range(20,16) = srcTag;
	packet.range(31,30) = rqUID;

	//Error 0 => bv[21]
	//Error 1 => bv[29]

	if(error == RE_NORMAL || error == RE_DATA_ERROR)
		packet[21] = false;
	else
		packet[21] = true;

	if(error == RE_NORMAL || error == RE_TARGET_ABORT)
		packet[29] = false;
	else
		packet[29] = true;

	packet[14] = bridge;
	packet[15] = passPW;
	packet[7] = isoc;
	
	return packet;
}

sc_bv<32> generateTargetDone(const sc_bv<5> &unitID,
						 const sc_bv<5> &srcTag,
						 const sc_bv<2> &rqUID,
						 bool bridge,
						 ResponseError error,
						 bool passPW,
						 bool isoc){
	sc_bv<32> packet = 0;
	sc_bv<6> packet_command = "110011";
	packet.range(5,0) = packet_command;
	packet.range(12,8) = unitID;
	packet.range(20,16) = srcTag;
	packet.range(31,30) = rqUID;

	//Error 0 => bv[21]
	//Error 1 => bv[29]

	if(error == RE_NORMAL || error == RE_DATA_ERROR)
		packet[21] = false;
	else
		packet[21] = true;

	if(error == RE_NORMAL || error == RE_TARGET_ABORT)
		packet[29] = false;
	else
		packet[29] = true;

	packet[14] = bridge;
	packet[15] = passPW;
	packet[7] = isoc;
	
	return packet;
}


sc_uint<5> getPacketSizeWithDatam1(const sc_bv<64> &pkt, const PacketCommand &cmd){
	sc_uint<5> pkt_size;
	sc_uint<2> packet_size_selector;
	packet_size_selector[1] = isDwordPacket(pkt,cmd);
	packet_size_selector[0] = hasDataAssociated(cmd);

	sc_uint<4> datalength_m1 = getDataLengthm1(pkt);

	switch(packet_size_selector){
		case 3:
			pkt_size = datalength_m1 + 1;
			break;
		case 2:
			pkt_size = 0;
			break;
		case 1:
			pkt_size = datalength_m1 + 2;
			break;
		default:
			pkt_size = 1;
	}
	return pkt_size;
}

sc_uint<5> getDwordPacketSizeWithDatam1(const sc_bv<64> &pkt, const PacketCommand &cmd){
	sc_uint<5> pkt_size;
	if(hasDataAssociated(cmd)){
		pkt_size = getDataLengthm1(pkt) + 1;
	}
	else{
		pkt_size = 0;
	}
	return pkt_size;
}

#endif
