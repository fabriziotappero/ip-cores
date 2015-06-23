//entrance_reordering_l3.h
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

///Entrance submodule of the Reordering Module
/** 
	@author Laurent Aubray
	@modified Ami Castonguay
*/

#ifndef ENTRANCE_REORDERING_L3_H
#define ENTRANCE_REORDERING_L3_H

#include "../core_synth/synth_datatypes.h"
#include "../core_synth/constants.h"

/// Redirect input packets to the proper VC
/** This module is the first of the Reordering module. It determines whether the packet
	goes to PC, NPC or R and sends it to that VC.  It also finds out what is the destination
	of the packet.  There are three bits representing all the possible destinations, so a
	broadcast packet can go to both the FWD and UI.

*/
class entrance_reordering_l3: public sc_module
{
public:

	sc_in<bool>	clk;
	sc_in<bool> resetx;

	/// Input packet
	sc_in<syn_ControlPacketComplete> in_packet;

	/// Indicates if a packet is available on the in_packet signal
	sc_in<bool> packet_available;

	///If the packets going through the reordering are going upstream
	//sc_in<bool> isUpstream;

	// UnitID of the current module
	sc_in<sc_bv<5> > unit_id;

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

	sc_out<sc_bv<CMD_BUFFER_MEM_WIDTH> > ro_command_packet_wr_data;

	/// Indicates if a packet is available on the new_packet_pc signal
	sc_out<bool> destination_pc[2];

	/// Indicates if a packet is available on the new_packet_npc signal
	sc_out<bool> destination_npc[2];

	/// Indicates if a packet is available on the new_packet_rc signal
	sc_out<bool> destination_rc[2];
	/// Indicates when a new packet is available for a VC
	/** VC's don't require this as destination_* are sufficient.  This signal
		is used for the buffer count (nophandler)*/
	sc_out<bool> new_packet_available[3];

#ifdef RETRY_MODE_ENABLED
	///Virtual Channel of input VC, only used to clear buffer credit of stomped packet
	sc_out<VirtualChannel> input_packet_vc;
#endif

	//This is the packet
#ifdef ENABLE_REORDERING
	sc_out<sc_uint<5> > new_packet_clumped_unitid;
	sc_out<bool> new_packet_passPW;
	sc_out<bool> new_packet_chain;
	sc_out<sc_uint<4> > new_packet_seqid;

	sc_out<sc_uint<LOG2_NB_OF_BUFFERS+1> >	nposted_refid_rejected;
	sc_out<sc_uint<LOG2_NB_OF_BUFFERS+1> >	response_refid_rejected;
	sc_out<sc_uint<LOG2_NB_OF_BUFFERS+1> >	nposted_refid_accepted;
	sc_out<sc_uint<LOG2_NB_OF_BUFFERS+1> >	response_refid_accepted;

	/// Calculated clumping configuration
	sc_in<sc_bv<5> > clumped_unit_id[32];
#else
	sc_signal<sc_uint<LOG2_NB_OF_BUFFERS+1> >	nposted_refid_rejected;
	sc_signal<sc_uint<LOG2_NB_OF_BUFFERS+1> >	response_refid_rejected;
	sc_signal<sc_uint<LOG2_NB_OF_BUFFERS+1> >	nposted_refid_accepted;
	sc_signal<sc_uint<LOG2_NB_OF_BUFFERS+1> >	response_refid_accepted;

	sc_in<sc_bv<5> > clumped_unit_id[4];
#endif

	///This number allows to identify the order of reception between posted and nposted packets
	/**When posted and nposted have the same number, posted was received before nposted
	   ONLY VALID FOR FORWARD (REJECTED) DESTINATION
	*/
	sc_signal<sc_uint<LOG2_NB_OF_BUFFERS+1> > new_packet_nposted_refid_rejected;
	///This number allows to identify the order of reception between posted and nresponse packets
	/**When posted and response have the same number, posted was received before response
	   ONLY VALID FOR FORWARD (REJECTED DESTINATION
	*/
	sc_signal<sc_uint<LOG2_NB_OF_BUFFERS+1> > new_packet_response_refid_rejected;

	///This number allows to identify the order of reception between posted and nposted packets
	/**When posted and nposted have the same number, posted was received before nposted
	   ONLY VALID FOR FORWARD (REJECTED) DESTINATION
	*/
	sc_signal<sc_uint<LOG2_NB_OF_BUFFERS+1> > new_packet_nposted_refid_accepted;
	///This number allows to identify the order of reception between posted and nresponse packets
	/**When posted and response have the same number, posted was received before response
	   ONLY VALID FOR FORWARD (REJECTED DESTINATION
	*/
	sc_signal<sc_uint<LOG2_NB_OF_BUFFERS+1> > new_packet_response_refid_accepted;

	//Some registers
	sc_signal<bool>								increment_nposted_refid_upon_posted_rejected;
	sc_signal<bool>								increment_response_refid_upon_posted_rejected;
	sc_signal<bool>								increment_nposted_refid_upon_posted_accepted;
	sc_signal<bool>								increment_response_refid_upon_posted_accepted;


	/// Sends the incoming packet to the proper VC.
	/** Entierely combinatorial process*/
	void packet_directing( void );

	/// Determines if the packet goes to the User module
	/** 
		@param pkt The packet being examined
		@param error64BitExtension If there was a 64 bit extension with the received packet
		@param cmd The command of the packet
	*/
	bool request_goes_to_user(sc_bv<64> &pkt, bool error64BitExtension,
		const PacketCommand &cmd);

	/// Determines if the packet goes to the User module
	/** 
		@param pkt The packet being examined
	*/
	bool response_goes_to_user(sc_bv<64> &pkt);

	/// Determines if the packet goes to the CSR module
	/** 
		@param pkt The packet being examined
		@param error64BitExtension If there was a 64 bit extension with the received packet
		@param cmd The command of the packet
	*/
	bool request_goes_to_csr(sc_bv<64> &pkt, bool error64BitExtension, const PacketCommand &cmd);

	/// Determines if the Address belongs to the current module
	/** @param address Address of the current packet
		@return bool true if the address is within the module's reserved address range*/ 
	bool isBarAddress( const sc_bv<40>& address);

	/// Identifies from the packet unitID if the packet is downstream or upstream
	/** @description A request packet is downstream when the clumped UnitID is 0
	    @param pkt_unidID The unitID field from a packet
		@return bool true if the packet is downstream*/ 
	bool request_isDownstream(sc_bv<5> &pkt_unidID);

	void clocked_process();

	SC_HAS_PROCESS(entrance_reordering_l3);

	/// Main constructor
	entrance_reordering_l3(sc_module_name name);

};

#endif

