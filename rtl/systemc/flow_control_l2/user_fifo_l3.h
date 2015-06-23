//user_fifo_l3.h

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
 *   Martin Corriveau
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

#ifndef USER_FIFO_L3_H
#define USER_FIFO_L3_H

#include "../core_synth/synth_datatypes.h"	
#include "../core_synth/constants.h"

enum UserFifoBufferPos {
	  USR_FIFO_VC_P_POS = 0,
      USR_FIFO_VC_P_DATA_POS = 1,
      USR_FIFO_VC_NP_POS = 2,
	  USR_FIFO_VC_NP_DATA_POS = 3,
	  USR_FIFO_VC_R_POS = 4,
	  USR_FIFO_VC_R_DATA_POS = 5};

/// Fifo that contain packet that user want to transmit
/**
	@class user_fifo_l3
	@author Ami Castonguay
	@description Before packets from the user are sent, they are stored in a
		buffer.  To optimize performance, there are actually 6 buffers, one
		for each VC, so that if a VC is blocked, packets of other types can
		still be sent.
		
		The first packet that arrives in the buffer has the highest priority.
		Only if the packet cannot be sent that the next packet will be sent
		if it is legal to make it pass the first packet.  Because of the buffer
		acts a little bit like a fifo, hence the name.
		
		The fifo only contains space for 6 command packets.  The data payload
		associated with a packet, if any, stays in a buffer in the user
		interface.  When we decide to send the command packet, we then go
		retrieve the data in the user interface.
*/		
class user_fifo_l3 : public sc_module
{
	public:

	///Registers containing the packets from the users
	//@{
	sc_signal<sc_bv<64> >		packet_buffer_posted[USER_FIFO_DEPTH];
	sc_signal<sc_bv<64> >		packet_buffer_nposted[USER_FIFO_DEPTH];
	sc_signal<sc_bv<32> >		packet_buffer_response[USER_FIFO_DEPTH];
	//@}

	///Registers containing the number of time a packet from another VC was, bypassing the packet vc
	//@{
	//No need for response count since by default it has the max priority
	//sc_signal<sc_uint<USER_FIFO_SHIFT_PRIORITY_LOG2_COUNT> >	othervc_send_count_response[USER_FIFO_DEPTH];
	sc_signal<sc_uint<USER_FIFO_SHIFT_PRIORITY_LOG2_COUNT> >	othervc_send_count_nposted[USER_FIFO_DEPTH];
	sc_signal<sc_uint<USER_FIFO_SHIFT_PRIORITY_LOG2_COUNT> >	othervc_send_count_posted[USER_FIFO_DEPTH];
	//@}

	/**
		This holds information about the position of the last posted packet that was received
		before response or nposted packet.  Once all posted packets that arrived before
		this packet are sent, this value has no meaning.  response_after_posted and 
		nposted_after_posted are used to store if there is still a packet bofore the posted
		and nposte packets.
    */
	//@{
	sc_signal<sc_uint<USER_FIFO_ADDRESS_WIDTH> >	posted_pointer_when_response_received[USER_FIFO_DEPTH];
	sc_signal<sc_uint<USER_FIFO_ADDRESS_WIDTH> >	posted_pointer_when_nposted_received[USER_FIFO_DEPTH];
	//@{

	/**
		If the packet in every arrived after a posted packet.  Once all posted packet that arrived
		before it are sent out, this is cleared.  The position of the last posted packet that was
		received before the response of nposted packet is stored in posted_pointer_when_response_received
		and posted_pointer_when_nposted_received.
	*/
	//@{
	sc_signal<bool >	response_after_posted[USER_FIFO_DEPTH];
	sc_signal<bool >	nposted_after_posted[USER_FIFO_DEPTH];
	//@{


	///Current position in the buffer where to write the next packet
	//@{
	sc_signal<sc_uint<USER_FIFO_ADDRESS_WIDTH> >	write_pointer_posted;
	sc_signal<sc_uint<USER_FIFO_ADDRESS_WIDTH> >	write_pointer_nposted;
	sc_signal<sc_uint<USER_FIFO_ADDRESS_WIDTH> >	write_pointer_response;
	//@}
	
	///Current position in the buffer where to read the next packet
	sc_signal<sc_uint<USER_FIFO_ADDRESS_WIDTH> >	read_pointer_posted;
	sc_signal<sc_uint<USER_FIFO_ADDRESS_WIDTH> >	read_pointer_nposted;
	sc_signal<sc_uint<USER_FIFO_ADDRESS_WIDTH> >	read_pointer_response;

	///The number of packets stored in the buffers
	//@{
	sc_signal<sc_uint<USER_FIFO_COUNT_WIDTH> >	buffer_count_posted;
	sc_signal<sc_uint<USER_FIFO_COUNT_WIDTH> >	buffer_count_nposted;
	sc_signal<sc_uint<USER_FIFO_COUNT_WIDTH> >	buffer_count_response;
	//@}

	

	/// signal that indicate the type of packet that the fifo can reveive
	/** 
	This signal indicates if there is more that 2 packets in the buffers,
	which means that steps should be taken to stop sending packets.  The
	buffers are larger than 2, so it can accept more packets.
	
	It's done this way so that the transmission can be pipelined : the signal
	to stop sending packets takes a couple cycles to propagate to the source
	and the buffers can accept the packets in the meanwhile.
	*/
	sc_out<sc_bv<3> >	fc_user_fifo_ge2_ui;
	
	/// Signal that indicate that the user have a packet to transmit to fifo
	sc_in<bool>			ui_available_fc;
	
	/// signal that contain the packet sent by user
	sc_in<sc_bv<64> >		ui_packet_fc;
    
	/// clock signal
    sc_in<bool> clock;
    /// reset signal
	sc_in <bool> resetx;
	
	/// Output of the packet of the fifo to the FC
    sc_out<sc_bv<64> > fifo_user_packet;
    ///indicates that the FIFO has a packet available 
	sc_out<bool> fifo_user_available;

	/**
		These signals are not necessary, but they are registered in this
		module to accelerate the combinatorial path of the next module.
	*/
	//@{
	///Virtual channel of the ::fifo_user_packet
 	sc_out<VirtualChannel> fifo_user_packet_vc;
	///If ::fifo_user_packet is a double word packet (as opposed to a quad word, word = 16 bits)
	sc_out<bool> fifo_user_packet_dword;
	///If ::fifo_user_packet has any data associated
	sc_out<bool> fifo_user_packet_data_asociated;
#ifdef RETRY_MODE_ENABLED
    ///The command of fifo_user_packet
	sc_out<PacketCommand > fifo_user_packet_command;
#endif

    ///Size of ::fifo_user_packet data in dwords minus 1
	sc_out<sc_uint<4> > fifo_user_packet_data_count_m1;
    ///If ::fifo_user_packet has the chain bit on (also checks if it's a posted packet)
	sc_out<bool> fifo_user_packet_isChain;
    //@}

    /// incoming signal on the status of the farend buffer
    sc_in<sc_bv<6> > fwd_next_node_buffer_status_ro;
    	
	///flow control a consummed the packet
	sc_in<bool>  consume_user_fifo;
	///flow control is currently reading output, do not change it!
	sc_in<bool> hold_user_fifo;

	///All synchronous actions in the module
	void registered_process();
	///Outputs the most important buffer according to the buffers content
	void output_buffer();
	///Scan alls buffer to know which type of packets we can accept
	void output_available_buffers();

	///From the packets given for the different VC's, decide which one to output
	/**
		@description Given a packet from every VC (if there is available), it will
			select the best packet to output to the flow_control to optimize
			performance while respecting reordering rules
		@param posted_loaded If there is a posted packet, otherwise posted_packet is ignored
		@param nposted_loaded If there is a non posted packet, otherwise nposted_packet is ignored
		@param response_loaded If there is a response packet, otherwise response_packet is ignored
		@param posted_packet The posted packet to evaluate
		@param nposted_packet The non posted packet to evaluate
		@param response_packet The response packet to evaluate
		@param nposted_behind_posted If the nposted packet arrived after posted packets in the fifo
		@param response_behind_posted If the response packet arrived after posted packets in the fifo
		@param posted_max_count Packets from other VCs have been sent the maximum number of times
			So priority must be shifter to focus on the posted packet
		@param nposted_max_count Packets from other VCs have been sent the maximum number of times
			So priority must be shifter to focus on the nposted packet

		@param tmp_fifo_user_packet The packet chosen (return by address)
		@param next_vc_output The VC of the chosen packet (return by address)
		@return If a packet was found to output
	*/
	bool getNextPacketToOutput(bool posted_loaded, sc_bv<64> posted_packet,bool posted_max_count_reached,
							   bool nposted_loaded, sc_bv<64> nposted_packet,bool nposted_behind_posted,bool nposed_max_count_reached,
							   bool response_loaded, sc_bv<32> response_packet,bool response_behind_posted,
							   sc_bv<64> & tmp_fifo_user_packet,VirtualChannel &next_vc_output);
	
	///SystemC Macro
	SC_HAS_PROCESS(user_fifo_l3);

	///Constructor of the class
	user_fifo_l3(sc_module_name name);

};

#endif

