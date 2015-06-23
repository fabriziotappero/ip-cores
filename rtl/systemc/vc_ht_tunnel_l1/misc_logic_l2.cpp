//misc_logic_l2.cpp

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
 *   Michel Morneau
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

#include "misc_logic_l2.h"

///Module constructor
misc_logic_l2::misc_logic_l2(sc_module_name name) : sc_module(name){
	SC_METHOD(change_frequency_process);
	sensitive_pos(clk);
	sensitive_neg(pwrok);

	SC_METHOD(register_signals);
	sensitive_pos(clk);
	sensitive_neg(resetx);
	
	SC_METHOD(find_clumped_ids);
	sensitive_pos(clk);
	sensitive_neg(resetx);
}

///Process that handles changing frequency
void misc_logic_l2::change_frequency_process(){
	if(!pwrok.read()){
		//Default value is 0 (200 MHz)
		link_frequency0_phy = 0;
		link_frequency1_phy = 0;

		//Also reset counter
		freq_counter = 0;
	}
	else{
		//Increase counter when in reset
		if(!resetx.read()){
			freq_counter = freq_counter.read() + 1;
		}

		//When the counter hits it's maximum (all 1's, detect it with and_reduce) or
		//the link is disconnected with ldtstop, update link frequency)
		if(freq_counter.read().and_reduce() || lk0_ldtstop_disconnected.read()){
			link_frequency0_phy = csr_link_frequency0;
		}
		if(freq_counter.read().and_reduce() || lk1_ldtstop_disconnected.read()){
			link_frequency1_phy = csr_link_frequency1;
		}
	}

}


void misc_logic_l2::register_signals(){
	if(!resetx.read()){
		registered_ldtstopx = true;
		registered1_ldtstopx = true;
	}
	else{
		//Two registers back to back to prevent asynchronous anomalies
		registered1_ldtstopx = ldtstopx;
		registered_ldtstopx = registered1_ldtstopx;
	}
}

// This function calculates to which unitID clump does the unitID belongs.
void misc_logic_l2::find_clumped_ids(){

	if(!resetx.read()){
		clumped_unit_id[0] = 0;
#ifdef ENABLE_REORDERING
		for (int i=1; i <  32;i++)
			clumped_unit_id[i] = i;
#else
		for (int i=1; i < 4;i++)
			clumped_unit_id[i] = i;
#endif
	}
	else{
		clumped_unit_id[0] = 0;
		/**
			We generate a new "Clumped_UnitID", which is not the original
			unique ID, but uniquely identifies in which "clump" the unitID
			is.  Ex., if 1 to 3 are clumped together, the unitID 0 is in
			Clumped_UnitID 0, 1 to 3 are in 1, 4 is in 2, etc.
		*/
		
#ifdef ENABLE_REORDERING
		for (int i=1; i < 32;i++)
#else
		for (int i=1; i < 4;i++)
#endif
		{
			/**
				There is a 32 bits clumping configuration vector : one bit per
				unitID.  If a bit is 1, it means that the unitID is clumped with
				the previous one.  So we simply increase the unitID_Clumped value
				everytime we encounter a 0 bit, until we reach our target unitID.
			*/
			if (csr_clumping_configuration.read()[i] == false)
				clumped_unit_id[i] = i;
			else
				clumped_unit_id[i] = clumped_unit_id[i-1];
		}
	}
}

