//nop_framer_l3.h

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

#ifndef NOP_FRAMER_L3_H
#define NOP_FRAMER_L3_H

///Generates nops to send to next node
/** 
	@author Jean-Francois Belanger
			Ami Castonguay
	@description The nop_framer takes care of generating nop packets.
		When the RO or DB requests that a packet be sent, it makes sure
		that the nop gets sent.
		
		There are many reasons to send nops :
			- To update the number of free buffers in the RO and DB
			- To update the RxNextPacketToAck
			- To disconnect the link
			- When there is nothing else to send
*/
class nop_framer_l3 : public sc_module
{
	public:
	/// Incomoing signal from the reordering about his buffer status
    sc_in<sc_bv<6> > ro_buffer_cnt_fc;
    
	/// Incomoing signal from the data_buffer about his buffer status
    sc_in<sc_bv<6> > db_buffer_cnt_fc;

	///Reordering requests that a nop be sent
    sc_in <bool> ro_nop_req_fc;
	///Databuffer requests that a nop be sent
    sc_in <bool> db_nop_req_fc;

	///When active, the nop_framer will send nop with only the dsconnect bit set
	sc_in<bool>	generate_disconnect_nop;
	///If the RO or DB still have some buffers that can be freed with a nop
	sc_out<bool> has_nop_buffers_to_send;
    
    /// Output of the NOp packet
    sc_out<sc_bv<32> > ht_nop_pkt;
	///A nop is being sent, with the current buffer values from the RO and DB
	sc_in<bool> fc_nop_sent;
	///The next packet to send as soon as possible is a nop
    sc_out <bool> nop_next_to_send;
     
	///Reset
    sc_in <bool> resetx;    
	///Clock
    sc_in_clk clock;

#ifdef RETRY_MODE_ENABLED
	///CD maitains a count of valid packet received, that count is then sent in nops
	sc_in<sc_uint<8> > cd_rx_next_pkt_to_ack_fc;
	///If currently in retry mode
    sc_in <bool> csr_retry;    

#endif

	///Outputs the dword representing the nop
	void framer( void );
	///Decide if nop_next_to_send_tmp should be set by a request or cleared by a sent nop
	void nop_decision( void );
	
	///SystemC Macro
	SC_HAS_PROCESS(nop_framer_l3);

	///Module constructor
	nop_framer_l3(sc_module_name name);
};

#endif
