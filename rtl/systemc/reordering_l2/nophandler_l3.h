//nophandler_l3.h
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
 *   Laurent Aubray
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

#ifndef NOPHANDLER_L2_H
#define NOPHANDLER_L2_H

#include "../core_synth/synth_datatypes.h"
#include "../core_synth/constants.h"

///Keeps track of buffer count and requesting that nops are sent
/**
	The nophandler takes care of tracking the number of buffers that
	are used.  It also keeps track of how many buffers the next HT
	node think we have.  When necessary, it makes a request to the
	flow control to send a nop to readjust the difference in count.
*/
class nophandler_l3: public sc_module
{
public:

	//***********************************
	// Ports definition
	//***********************************

	/// The Clock
	sc_in<bool> clk;

	/// Reset signal
	sc_in<bool> resetx;
	//When the flow control sent a nop with buffer information
	sc_in<bool> fc_nop_sent;
	//To notify that packets have been received, one signal per VC
	sc_in<bool> received_packet[3];
	//To notify that packets have been sent and the buffer is free, one signal per VC
	//2 bit vector (one for cleared accepted and one for forward).  If the same packet
	//was sent to both accepted and forward, only one of the bits will be asserted
	sc_in<sc_bv<2> > buffers_cleared[3];

	//To request that a nop be sent
	sc_out<bool> ro_nop_req_fc;
	//The buffer count to send on the nop
	sc_out<sc_bv<6> > ro_buffer_cnt_fc;

#ifdef RETRY_MODE_ENABLED
	///RX link is not connected
	sc_in< bool >								lk_rx_connected;
	///If the retry mode is active
	sc_in< bool >								csr_retry;
	///Let the CSR know we received a non flow control stomped packet
	sc_in<bool> cd_received_non_flow_stomped_ro;
	///Virtual Channel of input VC, only used to clear buffer credit of stomped packet
	sc_in<VirtualChannel> input_packet_vc;
#endif
	//Count of the number of buffers that are advertised as being free to the next node
	sc_signal<sc_uint<LOG2_NB_OF_BUFFERS + 1> > bufferCount[3];
	//The number of free buffers
	sc_signal<sc_uint<LOG2_NB_OF_BUFFERS + 1> > freeBuffers[3];
	//If a nop has already been requested
	sc_signal<bool> nopRequested;


	///All registered signals and outputs are treated here
	void clockedProcess();
	///Get the number of buffers freed in that VC
	sc_uint<2> getBufferFreedNop(const VirtualChannel vc);
	///Outputs the nop request with the correct ro_buffer_cnt_fc value
	void outputNopRequest(
		const sc_uint<LOG2_NB_OF_BUFFERS + 1> buffersThatCanBeFreedWithNop_2,
		const sc_uint<LOG2_NB_OF_BUFFERS + 1> buffersThatCanBeFreedWithNop_1,
		const sc_uint<LOG2_NB_OF_BUFFERS + 1> buffersThatCanBeFreedWithNop_0);

	///SystemC module macro
	SC_HAS_PROCESS(nophandler_l3);
	/// Constructor of the nophandler_l3 module
	/**
		@param name Name of the module
	*/
	nophandler_l3( sc_module_name name);

#ifdef SYSTEMC_SIM
	/// Destructor
	virtual ~nophandler_l3(){}
#endif
};

#endif

