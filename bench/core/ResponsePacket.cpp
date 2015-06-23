//ResponsePacket.cpp

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

#include "ResponsePacket.h"

ResponsePacket::ResponsePacket(const sc_bv<6> &command,
									   const sc_bv<5> &unitID,
									   const sc_bv<5> &srcTag,
									   const sc_bv<2> &rqUID,
									   bool bridge,
									   ResponseError error,
									   bool passPW,
									   bool isoc)
{
	bv.range(5,0) = command;
	bv.range(12,8) = unitID;
	bv.range(20,16) = srcTag;
	bv.range(31,30) = rqUID;

	//Error 0 => bv[21]
	//Error 1 => bv[29]

	if(error == RE_NORMAL || error == RE_DATA_ERROR)
		bv[21] = false;
	else
		bv[21] = true;

	if(error == RE_NORMAL || error == RE_TARGET_ABORT)
		bv[29] = false;
	else
		bv[29] = true;

	bv[14] = bridge;
	bv[15] = passPW;
	bv[7] = isoc;
}

	//If the packet has a data packet associated to it
bool ResponsePacket::hasDataAssociated() const{
	if(bv(5 , 0) == "110000") return true;
	return false;
} 

sc_uint<4> ResponsePacket::getDataLengthm1() const {
	sc_bv<4> temp = bv.range(25,22);
	return temp;
}

ResponseError ResponsePacket::getResponseError() const{
	if(bv[21] == false){
		if(bv[29] == false) return RE_NORMAL;
		return RE_DATA_ERROR;
	}
	else{
		if(bv[29] == false) return RE_TARGET_ABORT;
		return RE_MASTER_ABORT;
	}
}

/**
	@return unitID of the device that sent the response
*/
sc_bv<5> ResponsePacket::getUnitID() const{
	return bv.range(12,8);
}

bool ResponsePacket::getPassPW() const{
	return (sc_bit)bv[15];
}


