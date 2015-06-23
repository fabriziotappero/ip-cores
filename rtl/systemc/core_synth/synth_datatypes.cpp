//synth_datatypes.cpp

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

#include "synth_datatypes.h"

void sc_trace(sc_trace_file *tf, const syn_ControlPacketComplete& v,
const sc_string& NAME) {
	sc_trace(tf,v.packet, NAME + ".packet");
	sc_trace(tf,v.data_address, NAME + ".data_address");
	sc_trace(tf,v.error64BitExtension, NAME + ".error64BitExtension");
	//sc_trace(tf,v.testingTrackingNumber, NAME + ".testingTrackingNumber");
}

ostream &operator<<(ostream& out, const syn_ControlPacketComplete &pkt){
	out << "Packet: " << pkt.packet << "\n";
	out << "DataAddress: " << pkt.data_address << "\n";
	out << "Error64BitExtension: " << pkt.error64BitExtension << "\n";
	//out << "TestingTrackingNumber: " << pkt.testingTrackingNumber << "\n";
	return out;
}

void sc_trace(sc_trace_file *tf, const syn_ResponseControlPacketComplete& v,
const sc_string& NAME) {
	sc_trace(tf,v.packet, NAME + ".packet");
	sc_trace(tf,v.data_address, NAME + ".data_address");
	//sc_trace(tf,v.error64BitExtension, NAME + ".error64BitExtension");
	//sc_trace(tf,v.testingTrackingNumber, NAME + ".testingTrackingNumber");
}

ostream &operator<<(ostream& out, const syn_ResponseControlPacketComplete &pkt){
	out << "Packet: " << pkt.packet << "\n";
	out << "DataAddress: " << pkt.data_address << "\n";
	//out << "Error64BitExtension: " << pkt.error64BitExtension << "\n";
	//out << "TestingTrackingNumber: " << pkt.testingTrackingNumber << "\n";
	return out;
}
/*
ostream &operator<<(ostream &out,const PacketCommand &cmd){
	switch(cmd){
	case FLUSH :
		out << "FLUSH";
		break;
	case WRITE :
		out << "WRITE";
		break;
	case READ :
		out << "READ";
		break;
	case RD_RESPONSE :
		out << "RD_RESPONSE";
		break;
	case BROADCAST :
		out << "BROADCAST";
		break;
	case FENCE :
		out << "FENCE";
		break;
	case ATOMIC :
		out << "ATOMIC";
		break;
	case TGTDONE :
		out << "TGTDONE";
		break;
	case NOP :
		out << "NOP";
		break;
	case SYNC :
		out << "SYNC";
		break;
	default :
		out << "RESERVED_CMD";
	}
	return out;
}


ostream &operator<<(ostream &out,const PacketType &type){
	switch(type){
	case INFO :
		out << "INFO";
		break;
	case REQUEST :
		out << "REQUEST";
		break;
	case RESPONSE :
		out << "RESPONSE";
		break;
	default :
		out << "RESERVED_TYPE";
	}
	return out;
}

ostream &operator<<(ostream &out,const VirtualChannel &vc){
	switch(vc){
	case VC_POSTED :
		out << "VC_POSTED";
		break;
	case VC_NON_POSTED :
		out << "VC_NON_POSTED";
		break;
	case VC_RESPONSE :
		out << "VC_RESPONSE";
		break;
	default :
		out << "VC_NONE";
	}
	return out;
}

ostream &operator<<(ostream &out,const ResponseError &re){
	switch(re){
	case RE_NORMAL :
		out << "RE_NORMAL";
		break;
	case RE_TARGET_ABORT :
		out << "RE_TARGET_ABORT";
		break;
	case RE_DATA_ERROR :
		out << "RE_DATA_ERROR";
		break;
	case RE_MASTER_ABORT :
		out << "RE_MASTER_ABORT";
	}
	return out;
}
*/

bool syn_ControlPacketComplete::operator== (const syn_ControlPacketComplete &pkt) const{
	return	(this->packet == pkt.packet && 
		this->error64BitExtension == pkt.error64BitExtension &&
		this->data_address == pkt.data_address /*&&
		this->testingTrackingNumber == pkt.testingTrackingNumber*/);
}

syn_ControlPacketComplete::syn_ControlPacketComplete() :
	error64BitExtension(0),
	data_address(0),
	packet(0)

{}

bool syn_ResponseControlPacketComplete::operator== (const syn_ResponseControlPacketComplete &pkt) const{
	return	(this->packet == pkt.packet && 
		//this->error64BitExtension == pkt.error64BitExtension &&
		this->data_address == pkt.data_address /*&&
		this->testingTrackingNumber == pkt.testingTrackingNumber*/);
}


syn_ResponseControlPacketComplete::syn_ResponseControlPacketComplete() :
	/*error64BitExtension(0),*/
	data_address(0),
	packet(0)

{}

void initialize_syn_ControlPacketComplete(syn_ControlPacketComplete &pkt){
	pkt.packet = 0;
	pkt.error64BitExtension = false;
	pkt.isPartOfChain = false;
	pkt.data_address = 0;
}

void initialize_syn_ResponseControlPacketComplete(syn_ResponseControlPacketComplete &pkt){
	pkt.packet = 0;
	pkt.data_address = 0;
}
