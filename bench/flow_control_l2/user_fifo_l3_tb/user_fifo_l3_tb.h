//user_fifo_l3_tb.h
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

#ifndef USER_FIFO_L3_TB_H
#define USER_FIFO_L3_TB_H

#include "../../../rtl/systemc/core_synth/synth_datatypes.h"
#include <deque>

///Testbench for the user_fifo_l3 module
class user_fifo_l3_tb : public sc_module{
public:

	struct UserFifoEntry{
		sc_bv<64> packet;
		int tag_number;
	};

	/// signal that indicate the type of packet that the fifo can reveive
	/** 
	This signal indicates if there is more that 2 packets in the buffers,
	which means that steps should be taken to stop sending packets.  The
	buffers are larger than 2, so it can accept more packets.
	
	It's done this way so that the transmission can be pipelined : the signal
	to stop sending packets takes a couple cycles to propagate to the source
	and the buffers can accept the packets in the meanwhile.
	*/
	sc_in<sc_bv<3> >	fc_user_fifo_ge2_ui;
	
	/// Signal that indicate that the user have a packet to transmit to fifo
	sc_out<bool>			ui_available_fc;
	
	/// signal that contain the packet sent by user
	sc_out<sc_bv<64> >		ui_packet_fc;
    
	/// clock signal
    sc_in<bool> clk;
    /// reset signal
	sc_out <bool> resetx;
	
     //If the output buffer packet is consumed, available will take this new value
	//sc_signal<bool> tmp_fifo_user_available;


	/// Output of the packet of the fifo to the FC
    sc_in<sc_bv<64> > fifo_user_packet;
     //indicates that the FIFO has a packet available 
	sc_in<bool> fifo_user_available;
	///Virtual channel of the packet fifo_user_packet
 	sc_in<VirtualChannel> fifo_user_packet_vc;
	///If fifo_user_packet is a dword packet (as opposed to being a quad word packet)
	sc_in<bool> fifo_user_packet_dword;
	///If fifo_user_packet has any data associated to it
	sc_in<bool> fifo_user_packet_data_asociated;

	///If fifo_user_packet has any data associated to it
	sc_in<sc_uint<4> > fifo_user_packet_data_count_m1;
    ///If ::fifo_user_packet has the chain bit on (also checks if it's a posted packet)
	sc_in<bool> fifo_user_packet_isChain;
      
    /// incoming signal on the status of the farend buffer
    sc_out<sc_bv<6> > fwd_next_node_buffer_status_ro;
    	
	///flow control a consummed the packet
	sc_out<bool>  consume_user_fifo;
	///When this is activated, the user_fifo should not change the packet it has at the ouput
	sc_out<bool> hold_user_fifo;

	/**The testbench predicts what packet will be at the output next to see if the circuit does
	 the right thing */
	sc_bv<64> predicted_output;
	///If it is predicted that the user_fifo will have an output
	bool	  predicted_has_output;

	///If during the last cycle, a posted packet blocked a nposted packet (because it arrived first)
	bool last_cycle_posted_blocking_nposted;
	///If during the last cycle, a posted packet blocked a response packet (because it arrived first)
	bool last_cycle_posted_blocking_response;

	///SystemC Macro
	SC_HAS_PROCESS(user_fifo_l3_tb);

	///Testbench constructor
	user_fifo_l3_tb(sc_module_name name);

	///Simulated content of fifo for nposted packets
	std::deque<UserFifoEntry > nposted_fifo;

	///Simulated content of fifo for posted packets
	std::deque<UserFifoEntry > posted_fifo;

	///Simulated content of fifo for response packets
	std::deque<UserFifoEntry > response_fifo;

	///Current tag count for inserted packets
	/** Every packet sent to the fifo is tagged with a unique identifier in the testbench
	    to know the order that it arrived in, in order to verify that the design does the right
		thing.  This is much simply than what the hardware module uses ( a 32 bit tag number
		is a luxury that's not available in hardware!) :)
	*/
	int tag_count;

	///Comes true when an error is detected
	bool error;

	///Generates random packet to be sent to the fifo
	/**
	    Random generator of packets, but respects the rules of what is allowed to be sent
		to the fifo (will not send a packet oc a vc type if the buffers for that vc is full)
	*/
	void generate_packets();

	///Main testbench process
	/**
		This is the main process of the testbench that calls generate_packets to test
		the design.  The name of the function is because it tries to replicate in software
		what the hardware design does and predicts what the output of the module will be,
		and then compares if what was calculated matches the actual output.
	*/
	void maintain_internal_state();

};

#endif


