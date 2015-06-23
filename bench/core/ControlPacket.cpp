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

#include "ht_datatypes.h"

bool ControlPacket::outputExtraInformation = false;

PacketContainer ControlPacket::createPacketFromDword(const sc_bv<32> &dWord){
	
	//First start by finding the type of packet
	sc_bv<6> cmd = dWord(5 , 0);
	PacketType pkt_type = getPacketType(cmd); 
	PacketCommand pkt_command = getPacketCommand(cmd); 

	//Create a default packet
	ControlPacket* pkt = NULL;

	//From the packet type, create an object of the appropriate
	//derived class and return it
	if(pkt_type == INFO){
		if(pkt_command == SYNC)		pkt = new SyncPacket(dWord);
		else if(pkt_command == NOP) pkt = new NopPacket(dWord);
	}
	else if(pkt_type == RESPONSE){
		if(pkt_command == RD_RESPONSE)		pkt = new ReadResponsePacket(dWord);
		else if(pkt_command == TGTDONE)		pkt = new TargetDonePacket(dWord);
	}
	else if(pkt_type == REQUEST)
	{
		if(pkt_command == FLUSH)			pkt = new FlushPacket(dWord);
		else if	(pkt_command == FENCE)		pkt = new FencePacket(dWord);
		else if	(pkt_command == READ)		pkt = new ReadPacket(dWord);
		else if	(pkt_command == WRITE)		pkt = new WritePacket(dWord);
		else if	(pkt_command == BROADCAST)	pkt = new BroadcastPacket(dWord);
		else if	(pkt_command == ATOMIC)		pkt = new AtomicPacket(dWord);
	}
	return PacketContainer(pkt);
}

PacketContainer ControlPacket::createPacketFromQuadWord(const sc_bv<64> &qWord){

	//First start by finding the type of packet
	sc_bv<6> cmd = qWord(5 , 0);
	PacketType pkt_type = getPacketType(cmd); 
	PacketCommand pkt_command = getPacketCommand(cmd); 

	//Create a default packet
	ControlPacket *pkt = NULL;

	//From the packet type, create an object of the appropriate
	//derived class and return it
	if(pkt_type == INFO){
		if(pkt_command == SYNC)		pkt = new SyncPacket(qWord);
		else						pkt = new NopPacket(qWord);
	}
	else if(pkt_type == RESPONSE){
		if(pkt_command == RD_RESPONSE)		pkt = new ReadResponsePacket(qWord);
		else if(pkt_command == TGTDONE)		pkt = new TargetDonePacket(qWord);
	}
	else if(pkt_type == REQUEST)
	{
		if(pkt_command == FLUSH)			pkt = new FlushPacket(qWord);
		else if	(pkt_command == FENCE)		pkt = new FencePacket(qWord);
		else if	(pkt_command == READ)		pkt = new ReadPacket(qWord);
		else if	(pkt_command == WRITE)		pkt = new WritePacket(qWord);
		else if	(pkt_command == BROADCAST)	pkt = new BroadcastPacket(qWord);
		else if	(pkt_command == ATOMIC)		pkt = new AtomicPacket(qWord);
	}
	return PacketContainer(pkt);
}

void ControlPacket::setSecondDword(const sc_bv<32> &dWord){
	bv.range(63,32) = dWord;
}

/**
	To know the exact command of the packet
*/
PacketCommand ControlPacket::getPacketCommand() const{
	sc_bv<6> cmd = bv.range(5,0);
	return getPacketCommand(cmd);
}

/**
	To parse a cmd vector
*/
PacketCommand ControlPacket::getPacketCommand(const sc_bv<6> &cmd){

	//Check the command vector against all known
	//sequences
	if(cmd == "000000")
		return NOP;
	else if(cmd == "111111")
		return SYNC;
	else if(cmd == "110000")
		return RD_RESPONSE;
	else if(cmd == "110011")
		return TGTDONE;
	else if(cmd.range(4 , 3) == "01")
		return WRITE;
	else if(cmd.range(5 , 4) == "01")
		return READ;
	else if(cmd == "111010")
		return BROADCAST;
	else if(cmd == "111100")
		return FENCE;
	else if(cmd == "111101")
		return ATOMIC;
	else if(cmd == "110111")
		return EXTENDED_FLOW;
	else if(cmd == "000010")
		return FLUSH;
	else if(cmd == "111110")
		return ADDR_EXT;
	else
		return RESERVED_CMD;
}

/**
	To know the type of packet from a command vector
*/
PacketType ControlPacket::getPacketType(const sc_bv<6> &cmd){

	//Check the command vector against all known
	//sequences
	if(cmd == "000000" || cmd == "111111" || cmd == "110111"){
		return INFO;
	}
	else if(cmd == "110000" || cmd == "110011"){
		return RESPONSE;		
	}
	else if(cmd.range(5 , 3) == "001" || cmd.range(5 , 3) == "101"
			|| cmd.range(5 , 4) == "01" || cmd == "111010"
			|| cmd == "111100" || cmd == "111101" || cmd == "000010")
	{
		return REQUEST; 	   
	}
	else if(cmd == "111101"){
		return ADDR_EXT_TYPE;
	}
	else{
		return RESERVED_TYPE;
	}
}


//extern function to allow the ControlPacket to be used as an sc_signal
void sc_trace(sc_trace_file *tf, const ControlPacket& v,
const sc_string& NAME) {
	sc_trace(tf,v.getVector(), NAME);
}

//To test if the content of another packet is identical
bool ControlPacket::operator== (const ControlPacket &test_pkt) const{
	return test_pkt.bv == bv;
}

//To output the bit content of the packet
ostream &operator<<(ostream &out,const ControlPacket &pkt){
	out << pkt.getVector().to_string(SC_HEX);
	if(ControlPacket::outputExtraInformation){
		out << endl << "Virtual channel : " << pkt.getVirtualChannel() << endl;
		out << "PacketType : " << pkt.getPacketType() << endl;
		out << "PacketCommand : " << pkt.getPacketCommand() << endl;
		out << "HasData : " << pkt.hasDataAssociated() << "  Length : " << ((unsigned)pkt.getDataLengthm1() + 1) << endl;
	}
	return out;
}

sc_bv<32> ControlPacket::createAddressExtensionDoubleWord(sc_bv<24> &addressExtension){
	sc_bv<32> tempVector;
	sc_bv<6> command = "111110";
	tempVector.range(5,0) = command;
	tempVector.range(31,8) = addressExtension;
	return tempVector;
}


