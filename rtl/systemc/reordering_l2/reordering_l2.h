//reordering_l3.h
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

#ifndef REORDERING_L2_H
#define REORDERING_L2_H

#include "../core_synth/synth_datatypes.h"
#include "../core_synth/constants.h"

//Forward declerations
class entrance_reordering_l3;
class final_reordering_l3;
class posted_vc_l3;
class nposted_vc_l3;
class response_vc_l3;
class nophandler_l3;
class address_manager_l3;
class fetch_packet_l3;

/// Reordering Module
/** 
	The actual primary use of this module is to buffer command packet that arrives.
	Packets sent from the commande decoder are analyzed to find it's destination
	(user interface, CSR, error-handler/forward).  After that, the packet is stored
	in one of the three buffers, depending on the virtual channel.  The packets
	in the buffers might not come out of the buffers in the same order as they came
	in, hence the name reordering.

	Packets are reordered to allow higher priority packets to pass lower priority
	packets.  The reordering is not mandatory, so it would be possible to reduce
	the size of this module by physically disabling this feature in hardware.  The
	reordering can also be disabled through software in the CSR.

	A last task of the reordering module is to manage it's internal buffer count
	and notify the flow control when buffers are freed so that it can send a nop
	to notify the HT node we are connected to.

	@author Laurent Aubray
	@modified Ami Castonguay
*/

class reordering_l2 : public sc_module
{
public:
	//***********************************
	// Ports definition
	//***********************************

	/// The Clock
	sc_in<bool> clk;
	/// Reset signal 
	sc_in<bool> resetx;

	/// Packet sent to CSR module
	sc_out<syn_ControlPacketComplete> ro_packet_csr;

	/// Packet sent to User module
	sc_out<syn_ControlPacketComplete> ro_packet_ui;
	/// Packet sent to FC module
	sc_out<syn_ControlPacketComplete> ro_packet_fwd;
	sc_out<VirtualChannel> ro_packet_vc_fwd;

	/// Indicates if a packet is available on the RO_ControlPacketComplete_CSR port
	sc_out<bool> ro_available_csr;
	/// Indicates if a packet is available on the RO_ControlPacketComplete_User port
	sc_out<bool> ro_available_ui;
	/// Indicates if a packet is available on the RO_ControlPacketComplete_FC port
	sc_out<bool> ro_available_fwd;

	/// Acknowledge signal from the CSR module
	sc_in<bool> csr_ack_ro;
	/// Acknowledge signal from the User module
	sc_in<bool> ui_ack_ro;	
	/// Acknowledge signal from the FC module
	/** fwd_ack_ro and eh_ack_ro do the same thing*/
	sc_in<bool> fwd_ack_ro;

	/// Acknowledge signal from the Error Handler module
	sc_in<bool> eh_ack_ro;

	/// Indicates that a NOP was sent
	sc_in<bool> fc_nop_sent;

	/// New packet from Command Decode
	sc_in<syn_ControlPacketComplete> cd_packet_ro;

	/// Indicates if a packet is available on the CD_ControlPacketComplete_RO port
	sc_in<bool> cd_available_ro;

	/**If the cd is currently receiving data.  This is used to know if a packet
		that has associated data can be sent*/
	sc_in<bool>						cd_data_pending_ro;

	/**Where the cd is storing data.   This is used to know if a packet
		that has associated data can be sent*/
	sc_in<sc_uint<BUFFERS_ADDRESS_WIDTH> >	cd_data_pending_addr_ro;

	/// UnitID of the current module
	sc_in<sc_bv<5> > csr_unit_id;

	/// Address Range reserved for the module.
	sc_in<sc_bv<40> >	csr_bar[NbRegsBars];

	///If we accept writes or reads to the memory space
	sc_in<bool>			csr_memory_space_enable;

	///If we accept writes or reads to the io space
	sc_in<bool>			csr_io_space_enable;

#ifdef ENABLE_DIRECTROUTE
	/// Indicates which unitID enables DirectRoute
	sc_in<sc_bv<32> > csr_direct_route_enable;
#endif

	///If the link is currently sync flooding
	sc_in<bool> csr_sync;

#ifdef ENABLE_REORDERING
	/// this flag disables the reordering.
	/**See chapter 7.5.10.6 of hyperTransport specs 1.10*/
	sc_in<bool> csr_unitid_reorder_disable;
#endif

	
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
	sc_in<sc_bv <6> > fwd_next_node_buffer_status_ro;
	
	///Buffers to advertise as free when a nop is sent
	/** [5,4]: nonposted;  [3,2]: response. [1,0]: posted;*/
	sc_out<sc_bv <6> > ro_buffer_cnt_fc;
	/// Asks to send a NOP
	sc_out<bool> ro_nop_req_fc;
	///More packets than can be stored are received
	sc_out<bool> ro_overflow_csr;

#ifdef ENABLE_REORDERING
	/// Calculated clumping configuration
	sc_in<sc_bv<5> > clumped_unit_id[32];
#else
	/// Calculated clumping configuration
	sc_in<sc_bv<5> > clumped_unit_id[4];
#endif


#ifdef RETRY_MODE_ENABLED
	/// If the RX link is connected
	sc_in<bool>			lk_rx_connected;
	///If retry mode is active
	sc_in< bool >		csr_retry;
	///Let the CSR know we received a non flow control stomped packet
	sc_in<bool> cd_received_non_flow_stomped_ro;
#endif

	///////////////////////////////////////
	// Interface to memory
	///////////////////////////////////////
	sc_out<sc_bv<CMD_BUFFER_MEM_WIDTH> > ro_command_packet_wr_data;
	sc_out<bool > ro_command_packet_write;
	sc_out<sc_uint<LOG2_NB_OF_BUFFERS+2> > ro_command_packet_wr_addr;
	sc_out<sc_uint<LOG2_NB_OF_BUFFERS+2> > ro_command_packet_rd_addr[2];
	sc_in<sc_bv<CMD_BUFFER_MEM_WIDTH> > command_packet_rd_data_ro[2];

	
	//***********************************
	// Module Instanciation
	//***********************************

	/// Contains all the posted command packets
	posted_vc_l3* vc_pc_module;
	/// Contains all the non-posted command packets
	nposted_vc_l3* vc_npc_module;
	/// Contains all the response packets
	response_vc_l3* vc_rc_module;

	/// Sends packets to the CSR, User and FC modules
	final_reordering_l3* finalReorderingModule;

	/// Redirect input packets to the proper VC
	entrance_reordering_l3* entranceReorderingModule;

	/// Standalone buffer that manages the buffer count and nop request
	nophandler_l3* nopHandlerModule;


	address_manager_l3* addressManagerModule;
	fetch_packet_l3* fetchPacketModule;

	//***********************************
	// Intern Signals
	//***********************************

	//From EntranceReordering to Buffers

	sc_signal<sc_uint<LOG2_NB_OF_BUFFERS> > new_packet_addr;
#ifdef ENABLE_REORDERING
	/** Packets from Entrance_Reordering to VCs
	*/
	//This is the packet
	sc_signal<sc_uint<5> > new_packet_clumped_unitid;
	sc_signal<bool> new_packet_passpw;
	sc_signal<bool> new_packet_chain;
	sc_signal<sc_uint<4> > new_packet_seqid;
	sc_signal<sc_uint<LOG2_NB_OF_BUFFERS+1> >	nposted_refid_rejected;
	sc_signal<sc_uint<LOG2_NB_OF_BUFFERS+1> >	response_refid_rejected;
	sc_signal<sc_uint<LOG2_NB_OF_BUFFERS+1> >	nposted_refid_accepted;
	sc_signal<sc_uint<LOG2_NB_OF_BUFFERS+1> >	response_refid_accepted;
#endif

	/** This accompanies the packets from the entrance reordering to
		the vc's.  Each bit represent if the packet goes to a destination.
		The response channel only has two bits since the CSR cannot accept
		response packets
	*/
	//@{
	sc_signal<bool>					destination_pc[2];
	sc_signal<bool>					destination_npc[2];
	sc_signal<bool>					destination_rc[2];
	//@}

	/** These signals are activated when the buffers are full.  Used to
		generate overflow errors.
	*/
	//@{
	sc_signal<bool>					 pc_fullx;
	sc_signal<bool>					 npc_fullx;
	sc_signal<bool>					 rc_fullx;
	//@}

	/** From EntranceReordering to NopHandler,  Used to let the nophandler
		know for each VC if a new packet arrived in the buffer, hence that
		we a have one less buffer available.
	*/
	sc_signal<bool>					new_packet_available[3];

	/** From VCs to NopHandler - how many buffers have been read and can now
		be used for new packets.  There can be 3 buffers cleared - one by the
		CSR, the UI and the FWD/EH
	*/
	sc_signal<sc_bv<2> >			buffers_cleared[3];

	/** From posted VC to fetch_packet
	*/
	//@{
	///The highest priority packet for every destination
	sc_signal<sc_uint<LOG2_NB_OF_BUFFERS> > posted_packet_addr[2];
#ifdef ENABLE_REORDERING
	sc_signal<bool > posted_packet_passpw[2];
	sc_signal<sc_uint<4> > posted_packet_seqid[2];
	sc_signal<bool > posted_packet_chain[2];
	sc_signal<sc_uint<LOG2_NB_OF_BUFFERS+1> >	posted_packet_nposted_refid[2];
	sc_signal<sc_uint<LOG2_NB_OF_BUFFERS+1> >	posted_packet_response_refid[2];
#endif
	///If the packet signal contains a valid packet
	sc_signal<bool>					 posted_available[2];

	///Activated when the packet is read by the destination
	sc_signal<bool>					 ack_posted[2];
	//@}

	/** From non-posted VC to fetch_packet
	*/
	//@{
	///The highest priority packet for every destination
	sc_signal<sc_uint<LOG2_NB_OF_BUFFERS> > nposted_packet_addr[2];
#ifdef ENABLE_REORDERING
	sc_signal<bool > nposted_packet_passpw[2];
	sc_signal<sc_uint<4> > nposted_packet_seqid[2];
#endif
	///If the packet signal contains a valid packet
	sc_signal<bool>					 nposted_available[2];
	///Activated when the packet is read by the destination
	sc_signal<bool>					 ack_nposted[2];
	//@}

	/** From response VC to fetch_packet
	*/
	//@{
	///The highest priority packet for every destination
	sc_signal<sc_uint<LOG2_NB_OF_BUFFERS> > response_packet_addr[2];
#ifdef ENABLE_REORDERING
	sc_signal<bool > response_packet_passpw[2];
#endif
	///If the packet signal contains a valid packet
	sc_signal<bool>					 response_available[2];
	///Activated when the packet is read by the destination
	sc_signal<bool>					 ack_response[2];
	//@}

	/** From fetch_packet to final reordering
	*/
	sc_signal<syn_ControlPacketComplete> fetched_packet[2];
	sc_signal<bool> fetched_packet_available[2];
	sc_signal<VirtualChannel> fetched_packet_vc[2];

	sc_signal<sc_uint<LOG2_NB_OF_BUFFERS+1> > fetched_packet_nposted_refid[2];
	sc_signal<sc_uint<LOG2_NB_OF_BUFFERS+1> > fetched_packet_response_refid[2];

	sc_signal<bool> posted_requested[2];
	sc_signal<bool> nposted_requested[2];
	sc_signal<bool> response_requested[2];

	sc_signal<bool>					vc_overflow[3];

	///Or between the FWD ack and the EH ack
	sc_signal<bool>		orFwdEhAck;

	/// Packet sent to accepted modules
	sc_signal<syn_ControlPacketComplete> ro_packet_accepted;

#ifdef RETRY_MODE_ENABLED
	sc_signal<VirtualChannel> input_packet_vc;
#endif

	///Does the or between the FWD ack and the EH ack
	void doOrFwdEhAck();

	///Or gate between all the possible types of overflows to produce ::ro_overflow_csr
	void or_overflows();
	
	void wire_through();

	///SystemC macro for modules with processes
	SC_HAS_PROCESS(reordering_l2);

	/// Main constructor
	reordering_l2(sc_module_name name);

#ifdef SYSTEMC_SIM
	virtual ~reordering_l2();
#endif

};

#endif

