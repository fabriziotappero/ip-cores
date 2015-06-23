// cd_nop_handler_l3.cpp

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

#include "cd_nop_handler_l3.h"

cd_nop_handler_l3::cd_nop_handler_l3(sc_module_name name) : sc_module(name)
{
	
	SC_METHOD(handleNOP);
	sensitive_neg << resetx;
	sensitive_pos<<clk;
}

void cd_nop_handler_l3::handleNOP()
{
	//Inititalize value at reset
	if (!resetx.read()) 
	{
#ifdef RETRY_MODE_ENABLED
		cd_nop_ack_value_fc = 0;
#endif
		cd_nopinfo_fc = "000000000000";
		cd_nop_received_fc = false;
	}
	//Update registers at clock edge
	else
	{
		//Store nop information when asked to do so
		if(setNopCnt.read()){
#ifdef RETRY_MODE_ENABLED
			cd_nop_ack_value_fc = sc_bv<8>(lk_dword_cd.read().range(31,24));
#endif
			cd_nopinfo_fc = lk_dword_cd.read().range(19,8);
		}
		//Store nop received notification when asked to do so
		if(send_nop_notification.read())
			cd_nop_received_fc = true;
		else
			cd_nop_received_fc = false;
	}
	
}
