//rx_farend_cnt.h

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
 *   Jean-Francois Belanger
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

#include "../core_synth/synth_datatypes.h"	
#include "../core_synth/constants.h"

#ifndef RX_FAREND_CNT_L3_H
#define RX_FAREND_CNT_L3_H


/// Count the number of free buffer for each VC of the farend interface
/**
	@class rx_farend_cnt_l3
	@author Jean-Francois Belanger
			Ami Castonguay
			
	@description Keeps track of the buffers in the buffers of the next HT
		node we are connected to.  The count is increased when nops that
		contain flow control information are received, and the count is
		decreased when a non-information packet is sent out.
*/
class rx_farend_cnt_l3 : public sc_module
{
	public:
	
	/// input of the information of the nop (bits 19 downto 8 of a nop packet)
    sc_in<sc_bv<12> > cd_nopinfo_fc;
    /// incomming signal that indicate that a new nop packet has arrive
    sc_in <bool> cd_nop_received_fc;

    /// output of the status of the farend buffer, 1 : there is a free buffer, 0 : no
	//0 - response data
	//1 - response command
	//2 - non-posted data
	//3 - non-posted command
	//4 - posted data
	//5 - posted command
    sc_out<sc_bv<6> > fwd_next_node_buffer_status_ro;
    
    /// incomming signal that indicate the packet type that is send. 
	//one hot encoding, meaning of bits :
	//0 - response data
	//1 - response command
	//2 - non-posted data
	//3 - non-posted command
	//4 - posted data
	//5 - posted command
    sc_in <sc_bv<6> > current_sent_type;  //during first 32 bits transmission of a packet

	///reset signal
    sc_in <bool> resetx;    
    /// clock signal
    sc_in_clk clock;

#ifdef RETRY_MODE_ENABLED
	///To clear the count, like in the event of a retry sequence
	sc_in<bool> clear_farend_count;
#endif
	
	///Register that keeps track of the buffers of the other link
    sc_signal<sc_uint<FAREND_BUFFER_COUNT_SIZE> > buffercount[6] ;
    	
	
	/// Process that keeps count of the buffers
	void compte_buffer( void );

	///SystemC Macro
	SC_HAS_PROCESS(rx_farend_cnt_l3);

	///Module constructor
	rx_farend_cnt_l3(sc_module_name name);
};

#endif
