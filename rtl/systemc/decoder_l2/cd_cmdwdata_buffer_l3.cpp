// cd_cmdwdata_buffer_l3.cpp

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
 *   Max-Elie Salomon
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


#include "cd_cmdwdata_buffer_l3.h"

cd_cmdwdata_buffer_l3::cd_cmdwdata_buffer_l3(sc_module_name name) : sc_module(name)
{
	SC_METHOD(bufferize);
	sensitive_pos (clk);
	sensitive_neg << resetx;
}

void cd_cmdwdata_buffer_l3::bufferize()
{

	syn_ControlPacketComplete bufferPacket = packet;

	if (resetx.read() == false){
		bufferPacket.packet = 0;		
		bufferPacket.error64BitExtension = false;
		bufferPacket.isPartOfChain = false;
		bufferPacket.data_address = 0;
		cd_data_pending_addr_ro = 0;
	}
	else{

		sc_bv<32> dataVector = dataDword;

		//During enCtl1, store lower 32 bits of packet
		if(enCtl1.read()){
			bufferPacket.packet.range(31,0) = dataVector;
			bufferPacket.packet.range(63,32) = 0;
		}
		//During enCtl2, store higher 32 bits of packet
		else if(enCtl2.read()){
			bufferPacket.packet.range(63,32) = dataVector;
		}

		//During enCtl1, log 64 bit extension error
		if(enCtl1.read()){
			if	(error64BitsCtlwData)
				bufferPacket.error64BitExtension = true;
			else
				bufferPacket.error64BitExtension = false;
		}

		//During enCtl1, log the data address
		if(enCtl1.read()){
			//Both following signals are identical, synthesis tool should merge them
			bufferPacket.data_address = db_address_cd.read();
			cd_data_pending_addr_ro = db_address_cd.read();
		}
	}
	packet.write(bufferPacket);

}
