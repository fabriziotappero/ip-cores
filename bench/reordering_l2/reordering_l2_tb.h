//reordering_l2_tb.h
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
#ifndef REORDERING_L2_TB_H
#define REORDERING_L2_TB_H

#include "../../rtl/systemc/core_synth/synth_datatypes.h"
#include <deque>

///Testbench for reordering_l2 module
class reordering_l2_tb : public sc_module{
	//Structure containing all necessary information about a packet sent to reordering
	/**
		A packet might be for both accepted and forward (broadcast packet).
		A packet for the CSR will have both the csr and accepted set to true
	*/
	struct ReorderTBPacket{
		syn_ControlPacketComplete pkt;//The packet that was sent
		VirtualChannel vc;//It's VirtualChannel
		bool accepted;//If it is for accepted destination
		bool forward;//If it is for forward destination
		bool csr;//If it is for csr destination
	};

	///The different type of posted packet that can be requested
	enum PostedType{
		POSTED_ANY,
		POSTED_ACCEPTED,
		POSTED_FORWARD
	};

	///The different type of non-posted packet that can be requested
	enum NPostedType{
		NPOSTED_ANY,
		NPOSTED_ACCEPTED,
		NPOSTED_FORWARD
	};

	///The different type of response packet that can be requested
	enum ResponseType{
		RESPONSE_ANY,
		RESPONSE_ACCEPTED,
		RESPONSE_FORWARD
	};

	///The different type of destination and type of paccket chain posted packet can go
	enum PostedDestination{
		POSTED_DESTINATION_CSR = 0,
		POSTED_DESTINATION_USER = 1,
		POSTED_DESTINATION_FORWARD = 2,
		POSTED_DESTINATION_USER_DEVICE_MSG = 3
	};

public:

	///clk signal
	sc_in<bool> clk;

	/// Reset signal 
	sc_out<bool> resetx;
	/// Packet sent to CSR module
	sc_in<syn_ControlPacketComplete> ro_packet_csr;

	/// Packet sent to User module
	sc_in<syn_ControlPacketComplete> ro_packet_ui;
	/// Packet sent to FC module
	sc_in<syn_ControlPacketComplete> ro_packet_fwd;

	/// Indicates if a packet is available on the RO_ControlPacketComplete_CSR port
	sc_in<bool> ro_available_csr;
	/// Indicates if a packet is available on the RO_ControlPacketComplete_User port
	sc_in<bool> ro_available_ui;
	/// Indicates if a packet is available on the RO_ControlPacketComplete_FC port
	sc_in<bool> ro_available_fwd;

	/// Acknowledge signal from the CSR module
	sc_out<bool> csr_ack_ro;
	/// Acknowledge signal from the User module
	sc_out<bool> ui_ack_ro;	
	/// Acknowledge signal from the FC module
	/** fwd_ack_ro and eh_ack_ro do the same thing*/
	sc_out<bool> fwd_ack_ro;

	/// Acknowledge signal from the Error Handler module
	sc_out<bool> eh_ack_ro;

	/// Indicates that a NOP was sent
	sc_out<bool> fc_nop_sent;

	/// New packet from Command Decode
	sc_out<syn_ControlPacketComplete> cd_packet_ro;

	/// Indicates if a packet is available on the CD_ControlPacketComplete_RO port
	sc_out<bool> cd_available_ro;

	/**If the cd is currently receiving data.  This is used to know if a packet
		that has associated data can be sent*/
	sc_out<bool>						cd_data_pending_ro;

	/**Where the cd is storing data.   This is used to know if a packet
		that has associated data can be sent*/
	sc_out<sc_uint<BUFFERS_ADDRESS_WIDTH> >	cd_data_pending_addr_ro;

	/// UnitID of the current module
	sc_out<sc_bv<5> > csr_unit_id;

	/// Address Range reserved for the module.
	sc_out<sc_bv<40> >	csr_bar[NbRegsBars];

	///If we accept writes or reads to the memory space
	sc_out<bool>			csr_memory_space_enable;

	///If we accept writes or reads to the io space
	sc_out<bool>			csr_io_space_enable;

	/** Indicates which unitID enables DirectRoute*/
	sc_out<sc_bv<32> > csr_direct_route_enable;

	/// Indicates the clumping configuration
	sc_out<sc_bv<5> > clumped_unit_id[32];

	///If the link is currently sync flooding
	sc_out<bool> csr_sync;

#ifdef ENABLE_REORDERING
	/// this flag disables the reordering.
	/**See chapter 7.5.10.6 of hyperTransport specs 1.10*/
	sc_out<bool> csr_unitid_reorder_disable;
#endif
	/**Indicates whether the VC is upstream(=true) or downstream(=false)*/

	
	/// Contains information about the Command buffers of the upper module. 
	/**A set bit indicates:
	bit 5 = There is space in the PC VC
	bit 4 = There is space in the PC data VC
	bit 3 = There is space in the NPC VC
	bit 2 = There is space in the NPC data VC
	bit 1 = There is space in the R VC
	bit 0 = There is space in the R data VC
	A command packet cannot be sent if there is room in both data and command 
	buffers of the upper module*/
	sc_out<sc_bv <6> > fwd_next_node_buffer_status_ro;
	///Buffers to advertise as free when a nop is sent
	/** [5,4]: nonposted;  [3,2]: response. [1,0]: posted;*/
	sc_in<sc_bv <6> > ro_buffer_cnt_fc;
	/// Asks to send a NOP
	sc_in<bool> ro_nop_req_fc;
	///More packets than can be stored are received
	sc_in<bool> ro_overflow_csr;

#ifdef RETRY_MODE_ENABLED
	/// If the RX link is connected
	sc_out< bool >								lk_rx_connected;
	///If retry mode is active
	sc_out< bool >								csr_retry;
#endif
	
	///////////////////////////////////////
	// Interface to memory
	///////////////////////////////////////
	sc_in<sc_bv<CMD_BUFFER_MEM_WIDTH> > ro_command_packet_wr_data;
	sc_in<bool > ro_command_packet_write;
	sc_in<sc_uint<LOG2_NB_OF_BUFFERS+2> > ro_command_packet_wr_addr;
	sc_in<sc_uint<LOG2_NB_OF_BUFFERS+2> > ro_command_packet_rd_addr[2];
	sc_out<sc_bv<CMD_BUFFER_MEM_WIDTH> > command_packet_rd_data_ro[2];

	///Command memory
	sc_bv<CMD_BUFFER_MEM_WIDTH> command_memory[4*NB_OF_BUFFERS];
	
	/** @see ::consume_data()
	*/
	//@{
	///Read packet to configuration space registers if available
	sc_signal<bool>	read_csr;
	///Read packet to forward if available
	sc_signal<bool>	read_fwd;
	///Read packet to user interface if available
	sc_signal<bool>	read_ui;
	//@}

	///Queue of packets sent in the reordering
	std::deque<ReorderTBPacket>	packet_sent;
	///If the packets currently being sent to the reordering are part of a chain
	bool curently_sending_chain;
	///The destination the chain is going so that following packets to the same way
	PostedDestination chain_destination;

	///SystemC Macro
	SC_HAS_PROCESS(reordering_l2_tb);
	///Constructor
	reordering_l2_tb(sc_module_name name);

	///Main testbench control thread
	void simulate();
	/** The testbench is synchronous, so there is no way to know if during the
		next cycle there will be data available from the reordering.  Different
		read signals(::read_csr,::read_fwd,::read_ui) can be read synchronously and 
		this process will read from the destination if there is data available.
	*/
	void consume_data();

	void manage_memories();

	/** @description Generate an random address that is not part of the
			BAR addresses.
		@param addr The generated address returned by address
	*/
	void generate_random_not_bar_address(sc_bv<40> &addr);

	/** @description Generate an random posted packet going to the
			specified destination
		@param tb_pkt The generated packet and associated informations
			returned by address
		@param posted_type The destination where the packet should go
	*/
	void generate_random_posted_pkt(ReorderTBPacket &tb_pkt,
									PostedType posted_type);
	/** @description Generate an random posted packet going to the
			accepted destination
		@param pkt The generated packet returned by address
		@param chain If the packet is part of a chain
	*/
	bool generate_random_accepted_posted_pkt(sc_bv<64> &pkt, 
											 bool chain);

	/** @description Generate an random posted packet going to the
			forward destination
		@param pkt The generated packet returned by address
		@param chain If the packet is part of a chain
	*/
	void generate_random_forward_posted_pkt(sc_bv<64> &pkt, bool chain);

	/** @description Generate an random broadcast packet
		@param tb_pkt The generated packet returned by address
	*/
	void generate_random_broadcast_posted_pkt(sc_bv<64> &tb_pkt);

	/** @description Generate an random 64-bit vector
		@param pkt The generated vector returned by address
	*/
	void generate_random_64b_vector(sc_bv<64> &pkt);

	/** @description Generate an random non posted packet going to the
			specified destination
		@param tb_pkt The generated packet and associated informations
			returned by address
		@param nposted_type The destination where the packet should go
	*/
	void generate_random_nposted_pkt(ReorderTBPacket &tb_pkt,
									NPostedType nposted_type);

	/** @description Generate an random non posted packet going to the
			accepted destination
		@param pkt The generated packet returned by address
	*/
	bool generate_random_accepted_nposted_pkt(sc_bv<64> &pkt);

	/** @description Generate an random non posted packet going to the
			forward destination
		@param pkt The generated packet returned by address
	*/
	void generate_random_forward_nposted_pkt(sc_bv<64> &pkt);

	/** @description Generate an random response packet going to the
			specified destination
		@param tb_pkt The generated packet and associated informations
			returned by address
		@param response_type The destination where the packet should go
	*/
	void generate_random_response_pkt(ReorderTBPacket &tb_pkt,
									ResponseType response_type);

	/** @description Generate an random response packet going to the
			accepted destination
		@param pkt The generated packet returned by address
	*/
	void generate_random_accepted_response_pkt(sc_bv<64> &pkt);

	/** @description Generate an random response packet going to the
			forward destination
		@param pkt The generated packet returned by address
	*/
	void generate_random_forward_response_pkt(sc_bv<64> &pkt);
};

#endif

