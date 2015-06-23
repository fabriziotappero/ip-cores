//PacketContainer.cpp

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

#include "InfoPacket.h"
#include "PacketContainer.h"


PacketContainer::PacketContainer() : bufferedBitVector(){
	//Default to nop packet
	defaultPacket = true;
	pkt = new NopPacket();
	
}	

PacketContainer::PacketContainer(ControlPacket* pkt_ref): defaultPacket(false),
								bufferedBitVector(){
	if(pkt_ref == NULL){
		pkt = new NopPacket();
		defaultPacket = true;
		return;
	}
	pkt = pkt_ref;
	bufferedBitVector = pkt->getVector();
}	

bool PacketContainer::isValidPacket() const {return !defaultPacket;}

PacketContainer::PacketContainer(const PacketContainer &container){
	pkt = container->getCopy();
}	


PacketContainer& PacketContainer::operator=(const PacketContainer &container){
	if(pkt == container.pkt) return *this;
	delete pkt;
	pkt = container->getCopy();
	bufferedBitVector = pkt->getVector();
	return *this;
}

PacketContainer& PacketContainer::operator=(const ControlPacket &new_pkt){
	if(pkt == &new_pkt) return *this;
	delete pkt;
	pkt = new_pkt.getCopy();
	bufferedBitVector = pkt->getVector();
	return *this;
}

void PacketContainer::takeControl(ControlPacket *new_pkt){
	if(pkt == new_pkt) return;
	delete pkt;
	pkt = new_pkt;		
	bufferedBitVector = pkt->getVector();
}

ControlPacket* PacketContainer::giveControl(){
	ControlPacket* temp = pkt;
	pkt =  new NopPacket();
	defaultPacket = true;
	return temp;		
}

bool PacketContainer::operator== (const PacketContainer & test) const{
	return (*pkt == *test);
}

//function to allow the ControlPacket to be used as an sc_signal
void sc_trace(sc_trace_file *tf, const PacketContainer& v,
const sc_string& NAME) {
	sc_trace(tf,v.bufferedBitVector, NAME);
}


PacketContainer::~PacketContainer(){
	delete pkt;
}

ostream &operator<<(ostream& out, const PacketContainer & c){
	out << (*c);
	return out;
}
