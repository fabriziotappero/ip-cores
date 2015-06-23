//ht_datatypes.cpp

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
#include "../../rtl/systemc/core_synth/synth_datatypes.h"

void sc_trace(sc_trace_file *tf, const ControlPacketComplete& v,
const sc_string& NAME) {
	sc_trace(tf,v.packet, NAME + ".packet");
	sc_trace(tf,v.data_address, NAME + ".data_address");
	sc_trace(tf,v.error64BitExtension, NAME + ".error64BitExtension");
	//sc_trace(tf,v.testingTrackingNumber, NAME + ".testingTrackingNumber");
}

ostream &operator<<(ostream& out, const ControlPacketComplete &pkt){
	out << "Packet: " << pkt.packet << "\n";
	out << "DataAddress: " << pkt.data_address << "\n";
	out << "Error64BitExtension: " << pkt.error64BitExtension << "\n";
	//out << "TestingTrackingNumber: " << pkt.testingTrackingNumber << "\n";
	return out;
}


bool ControlPacketComplete::operator== (const ControlPacketComplete &pkt) const{
	return	(this->packet == pkt.packet && 
		this->error64BitExtension == pkt.error64BitExtension &&
		this->data_address == pkt.data_address /*&&
		this->testingTrackingNumber == pkt.testingTrackingNumber*/);
}

ControlPacketComplete::ControlPacketComplete() : 
	//testingTrackingNumber(0),
	packet(),
	error64BitExtension(false),
	data_address(){
}


ControlPacketComplete::ControlPacketComplete(const ControlPacketComplete &pktCmplt) :
	//testingTrackingNumber(pktCmplt.testingTrackingNumber),
	packet(pktCmplt.packet),
	error64BitExtension(pktCmplt.error64BitExtension),
	data_address(pktCmplt.data_address){
}

ControlPacketComplete& ControlPacketComplete::operator= (const ControlPacketComplete &pktCmplt){
	//testingTrackingNumber = pktCmplt.testingTrackingNumber;
	packet = pktCmplt.packet;
	error64BitExtension = pktCmplt.error64BitExtension;
	data_address = pktCmplt.data_address;
	return *this;
}


ControlPacketComplete::ControlPacketComplete(const syn_ControlPacketComplete &pktCmplt) :
		//testingTrackingNumber(0),
		error64BitExtension(pktCmplt.error64BitExtension),
		data_address(pktCmplt.data_address)
{
	packet = ControlPacket::createPacketFromQuadWord(pktCmplt.packet);
}

///Copy Constructor from synthesis packet
ControlPacketComplete& ControlPacketComplete::operator=(const syn_ControlPacketComplete &pktCmplt){
	//testingTrackingNumber = 0;
	error64BitExtension = pktCmplt.error64BitExtension;
	data_address = pktCmplt.data_address;
	packet = ControlPacket::createPacketFromQuadWord(pktCmplt.packet);
	return *this;
}
		
syn_ControlPacketComplete ControlPacketComplete::generateSynControlPacketComplete(){
	syn_ControlPacketComplete pkt;
	pkt.error64BitExtension = error64BitExtension;
	pkt.data_address = data_address;
	pkt.packet = packet->getVector();
	return pkt;
}

ControlPacketComplete::operator syn_ControlPacketComplete() const{
	syn_ControlPacketComplete pkt;
	pkt.packet = packet->getVector();
	pkt.error64BitExtension = error64BitExtension;
	pkt.data_address = data_address;
	pkt.isPartOfChain = isPartOfChain;
	return pkt;
}
