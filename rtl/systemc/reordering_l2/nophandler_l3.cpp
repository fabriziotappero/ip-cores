//nophandler_l3.cpp

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

#include "nophandler_l3.h"
#include "reordering_l2.h"

nophandler_l3::nophandler_l3( sc_module_name name ) :
	sc_module(name){
	SC_METHOD(clockedProcess);
	sensitive_pos << clk;
	sensitive_neg << resetx;
}

void nophandler_l3::clockedProcess(){
	if(!resetx.read()){
		//On reset, clear all the buffer counds
		for(int n = 0; n < 3; n++){
			bufferCount[n] = 0;
			freeBuffers[n] = NB_OF_BUFFERS;
		}
		ro_buffer_cnt_fc = 0;
		ro_nop_req_fc = false;
		nopRequested = false;
	}
	else{

		sc_uint<LOG2_NB_OF_BUFFERS + 1> buffersThatCanBeFreedWithNop[3];
		sc_uint<LOG2_NB_OF_BUFFERS + 1> buffersThatCanBeFreedWithoutNop[3];

		//Find how many buffers that can be freed in every VC when taking into acount
		//if a nop was just sent.
		for(int vc = 0; vc < 3; vc++){
			
			sc_uint<LOG2_NB_OF_BUFFERS + 1> bufferCountWithNop;
			sc_uint<LOG2_NB_OF_BUFFERS + 1> bufferCountWithoutNop;
			bufferCountWithNop = bufferCount[vc].read() + 
					getBufferFreedNop((VirtualChannel)vc);
			bufferCountWithoutNop = bufferCount[vc].read();
			
			//The number of buffers that can be freed is the difference between the actual
			//number of buffers that are free and the count of how many buffers have been
			//advertised as being free
			buffersThatCanBeFreedWithNop[vc] = freeBuffers[vc].read() - bufferCountWithNop;
			buffersThatCanBeFreedWithoutNop[vc] = freeBuffers[vc].read() - bufferCountWithoutNop;
		}
		
		//Find the new bufferCount
		for(int vc = 0; vc < 3 ; vc++){
			//By default, keep the same number of buffers
			sc_uint<LOG2_NB_OF_BUFFERS + 1> newBufferCount = bufferCount[vc].read();


			//If a packet is received, decrease the count
			if(received_packet[vc]){
				newBufferCount--;
			}

#ifdef RETRY_MODE
			//When a stomped packet is received, the sender consumed a buffer credit and
			//it must be resent
			if(cd_received_non_flow_stomped_ro.read() && input_packet_vc.read() == vc){
				newBufferCount--;
			}
#endif

			//If a nop is sent, add the count sent to the buffer count
			if(fc_nop_sent.read()){
				newBufferCount += getBufferFreedNop((VirtualChannel)vc);
			}
#ifdef RETRY_MODE_ENABLED
			//While a retry sequence, reset buffer count
			if(	csr_retry.read() && !lk_rx_connected.read())
				bufferCount[vc] = 0;
			else
#endif
				bufferCount[vc] = newBufferCount;
		}

		//Find new freeBuffersCount
		for(int vc = 0; vc < 3 ; vc++){
			sc_uint<LOG2_NB_OF_BUFFERS + 1> newFreeBufferCount = freeBuffers[vc].read();
			//Decrease the number of free buffers when one is received
			if(received_packet[vc]){
				newFreeBufferCount--;
			}

			sc_uint<2> num_buffer_cleared;
			num_buffer_cleared[1] = (sc_bit)buffers_cleared[vc].read()[1] && (sc_bit)buffers_cleared[vc].read()[0];
			num_buffer_cleared[0] = (sc_bit)buffers_cleared[vc].read()[1] ^ (sc_bit)buffers_cleared[vc].read()[0];

			//And add the number of buffers that were freed
			newFreeBufferCount += num_buffer_cleared;
			freeBuffers[vc] = newFreeBufferCount;
		}

		//Output the result
		if(nopRequested.read())
			outputNopRequest(buffersThatCanBeFreedWithNop[2],buffersThatCanBeFreedWithNop[1],
				buffersThatCanBeFreedWithNop[0]);
		else
			outputNopRequest(buffersThatCanBeFreedWithoutNop[2],buffersThatCanBeFreedWithoutNop[1],
				buffersThatCanBeFreedWithoutNop[0]);

		sc_bv<6> bufferFreedNopBufWithNop;
		bufferFreedNopBufWithNop.range(1,0) = buffersThatCanBeFreedWithNop[VC_POSTED] <=3 ? sc_uint<2>(buffersThatCanBeFreedWithNop[VC_POSTED].range(1,0)) : sc_uint<2>(3);
		bufferFreedNopBufWithNop.range(5,4) = buffersThatCanBeFreedWithNop[VC_NON_POSTED] <=3 ? sc_uint<2>(buffersThatCanBeFreedWithNop[VC_NON_POSTED].range(1,0)) : sc_uint<2>(3);
		bufferFreedNopBufWithNop.range(3,2) = buffersThatCanBeFreedWithNop[VC_RESPONSE] <=3 ? sc_uint<2>(buffersThatCanBeFreedWithNop[VC_RESPONSE].range(1,0)) : sc_uint<2>(3);

		sc_bv<6> bufferFreedNopBufWithoutNop;
		bufferFreedNopBufWithoutNop.range(1,0) = buffersThatCanBeFreedWithoutNop[VC_POSTED] <=3 ? sc_uint<2>(buffersThatCanBeFreedWithNop[VC_POSTED].range(1,0)) : sc_uint<2>(3);
		bufferFreedNopBufWithoutNop.range(5,4) = buffersThatCanBeFreedWithoutNop[VC_NON_POSTED] <=3 ? sc_uint<2>(buffersThatCanBeFreedWithNop[VC_NON_POSTED].range(1,0)) : sc_uint<2>(3);
		bufferFreedNopBufWithoutNop.range(3,2) = buffersThatCanBeFreedWithoutNop[VC_RESPONSE] <=3 ? sc_uint<2>(buffersThatCanBeFreedWithNop[VC_RESPONSE].range(1,0)) : sc_uint<2>(3);

		if(fc_nop_sent.read()){
			ro_buffer_cnt_fc = bufferFreedNopBufWithNop;
		}
		else{
			ro_buffer_cnt_fc = bufferFreedNopBufWithoutNop;
		}
	}
}

sc_uint<2> nophandler_l3::getBufferFreedNop(const VirtualChannel vc){
	//A simple mux
	switch(vc){
	case VC_POSTED :
		return sc_bv<2>(ro_buffer_cnt_fc.read().range(1,0));
	case VC_NON_POSTED :
		return sc_bv<2>(ro_buffer_cnt_fc.read().range(5,4));
	case VC_RESPONSE :
		return sc_bv<2>(ro_buffer_cnt_fc.read().range(3,2));
	default :
		return 0;
	}

}

void nophandler_l3::outputNopRequest(const sc_uint<LOG2_NB_OF_BUFFERS + 1> buffersThatCanBeFreedWithNop_2,
		const sc_uint<LOG2_NB_OF_BUFFERS + 1> buffersThatCanBeFreedWithNop_1,
		const sc_uint<LOG2_NB_OF_BUFFERS + 1> buffersThatCanBeFreedWithNop_0){

	//Place the parameters in an array so it can be read from within a loop
	const sc_uint<LOG2_NB_OF_BUFFERS + 1> buffersThatCanBeFreedWithNop[3] = {
		buffersThatCanBeFreedWithNop_0,buffersThatCanBeFreedWithNop_1,buffersThatCanBeFreedWithNop_2};

	//Calculate if we will do a nop request
	bool doNopRequest = false;

	//Calculate the buffer count to send to the flow control

	//Truncate the number of buffers to be freed to a maximum of 3
	for(int vc = 0; vc < 3; vc++){

		/** This next part is a simple algorithm so we that we don't monopolize the link by sending
			nops of buffers being freed.  It is strongly possible that this will need to be
			adjusted with profiling */

		if(
		//If we have a lot of buffers that are free, we can slack and only request a nop
		//when we have at least 3 buffers to free (the maximum a nop can carry)
		//If we have 3 or more buffers even if a nop has just been sent, request another nop
			(freeBuffers[vc].read() > 4 && buffersThatCanBeFreedWithNop[vc] >= 3) ||
		//Same principle, but if we have less buffers free, we get more aggressive about
		//requesting that a nop be sent!
			(freeBuffers[vc].read() <= 4 && buffersThatCanBeFreedWithNop[vc] >= 2) ||
			(freeBuffers[vc].read() <= 2 && buffersThatCanBeFreedWithNop[vc] > 0)
		)
			doNopRequest = true; 
	}

	//Output the results
	
	ro_nop_req_fc = doNopRequest;
	nopRequested = doNopRequest || (nopRequested.read() && !fc_nop_sent.read());
}

#ifndef SYSTEMC_SIM
#include "../core_synth/synth_control_packet.cpp"
#endif

