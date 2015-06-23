//RequestPacket.cpp

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

#include "RequestPacket.h"

RequestPacket::	RequestPacket(const sc_bv<6> &command,
		              const sc_bv<4> &seqID,
					  const sc_bv<5> &unitID,
					  const bool passPW,
					  const bool isocOrCompat,
					  const sc_bv<5> srcTag,
					  const sc_bv<4> count,
					  const sc_bv<38> address)
{
	bv.range(5,0) = command;
	bv.range(7,6) = seqID.range(3,2);
	bv.range(14,13) = seqID.range(1,0);
	bv.range(12,8) = unitID;
	bv[15] = passPW;
	bv[21] = isocOrCompat;
	bv.range(20,16) = srcTag;
	bv.range(25,22) = count;
	bv.range(63,26) = address;
}

//If the packet is a packet that only contains 32 bits
bool RequestPacket::isDwordPacket() const{
	sc_bv<6> cmd = bv(5 , 0);

	if(cmd == "111100" || cmd == "111111" || cmd == "000010"){
		return true;
	}
	return false;
}

//If the packet has a data packet associated to it
bool RequestPacket::hasDataAssociated() const{
	if(bv(5 , 0) == "111101" ||
		bv(5 , 3) == "101" || bv(5 , 3) == "001")
	{
		return true;
	}
	return false;
}

//To get the virtual channel of the packet
VirtualChannel RequestPacket::getVirtualChannel() const{
	if(bv[5] == '1' && bv.range(4,0) != "11101") return VC_POSTED;
	return VC_NON_POSTED;
}

bool RequestPacket::isInAddressRange(const char * low, const char * high) const{
	//Start by converting the strings to uint
	sc_uint<40> low_uint(low);
	sc_uint<40> high_uint(high);

	//Call the function taking uints
	return isInAddressRange(low_uint,high_uint);
}

bool RequestPacket::isInAddressRange(const sc_bv<40> &low, const sc_bv<40> &high) const{
	//Start by converting the strings to uint
	sc_uint<40> low_uint(low);
	sc_uint<40> high_uint(high);

	//Call the function taking uints
	return isInAddressRange(low_uint,high_uint);
}

bool RequestPacket::isInAddressRange(const sc_uint<40> &low,
										 const sc_uint<40> &high) const{
	if(isDwordPacket()) return false;
	sc_uint<40> addr = getRequestAddr();
	return (addr >= low && addr < high);
}

sc_uint<40> RequestPacket::getRequestAddr() const{
	sc_uint<40> addr;

	//If the packet only has 32 bits, return an address
	//of only zeros since it does not have any address
	if(isDwordPacket()) 
		return addr;

	//Copy the standard range of addresses
	sc_bv<37> temp(bv.range(63,27));
	addr.range(39,3) = temp;

	//Copy the last bit of the address.  An exception is made for
	//the ATOMIC packet, that has this bit always at 0
	sc_bit temp2(bv[26]);
	if(bv(5 , 0) != "111101") addr.bit(2) = temp2;

	//Return the address
	return addr;
}

sc_uint<4> RequestPacket::getDataLengthm1() const {
	//If a byte read (cmd starts by 01 for read, and pkt[2] for byte
	if(bv[5] == false && bv[4] == true && bv[2] == true){
		return 0;
	}
	else{
		//DataLength is Doubleword
		return (sc_bv<4>)bv.range(25,22);;
	}
}


sc_bv<4> RequestPacket::getSeqID() const{
	sc_bv<4> temp;
	temp.range(3,2) = bv(7,6);
	temp.range(1,0) = bv(14,13);
	return temp;
}

bool RequestPacket::getPassPW() const{
	return (sc_bit)bv[15];
}

sc_bv<5> RequestPacket::getUnitID() const{
	return bv.range(12,8);
}

sc_bv<5> RequestPacket::getSrcTag() const{
	return bv.range(20,16);
}

bool RequestPacket::getCompatOrIsoc() const{
	return (sc_bit)bv[21];
}

bool RequestPacket::isChain() const{
	//if(posted && write && bit chain)
	if(bv.range(5 , 3) == "101" &&
	   bv[19] == true) return true;
	return false;
}
