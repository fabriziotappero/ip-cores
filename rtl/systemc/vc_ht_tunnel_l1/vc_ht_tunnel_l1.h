//vc_ht_tunnel_l1.h

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

#ifndef HT_TUNNEL_L1_H
#define HT_TUNNEL_L1_H


#include "../core_synth/synth_datatypes.h"

#include "../decoder_l2/decoder_l2.h"
#include "../reordering_l2/reordering_l2.h"
#include "../databuffer_l2/databuffer_l2.h"
#include "../userinterface_l2/userinterface_l2.h"
#include "../flow_control_l2/flow_control_l2.h"
#include "../link_l2/link_l2.h"
#include "../errorhandler_l2/errorhandler_l2.h"
#include "../csr_l2/csr_l2.h"
#include "misc_logic_l2.h"

///	Top level module of the HyperTransport tunnel.
/**
	HyperTransport is a high performance and low latency chip
	to chip interconnect.  This core handles various aspects of
	the protocol, framing of transmission, packet storing, flow control,
	configuration registers, error handling and retransmission of
	corrupted packet if the retry mode is activated.

	It is called a tunnel because is has two active links with a interface
	for a user to access the core.  The two links are to be connected to
	a serializer/deserializer circuit that output data to a LVDS driver and
	LVDS receiver.  This serdes can simply be a shift register.

    The core can be configured for different bit widths and the clock difference
	between the link and the core must be adjusted accordingly.  The core always
	reads 32 bits at the time. Let's say the link is 8 bit DDR running at 400Mhz,
	it means that the core must run at 200Mhz + delta to be capable of handling
	the data produced by the link.  The delta is necessary if both chips connected
	by the HT link is not running from the same clock source : it will aborb the phase
	shifts from the clocks.

	This design is generic and should be usable with a wide variety of hardware.
	The physical link part (serdes + driver and receiver) must be setup
	outside this core.  The core uses a single clock.  The receive logic or the
	physical layer (not part of this core) should run on the RX clock from the
	HT link.  The transmit logic should run at the speed specified in the configuration
	registers and be phased lock on the RX clock.

	To be generic, the design also does not include embedded memories, although it
	uses them.  IO to these embedded memories are on the IOs of this core.  A top
	level connecting the HT tunnel core to embeded memories is needed.  These memories
	are synchrous with one read and one write ports.
*/
class vc_ht_tunnel_l1 : public sc_module
{
	public:

	//***********************************
	// External ports definition
	//***********************************

	/// Clock driving the design
	sc_in<bool>			clk;
	/// Active low reset signal
	/** The majority of the design uses this as an asynchronous reset.  The CSR uses it
	as a synchronous reset for some registers because the effect of resetx changes
	depending on the value of pwrok, but that this signal is asynchrous should not
	cause a problem to the CSR.	
	
	*** WARNING ***:The core assumes that this input has been properly synchronized 
	        with the clock to avoid problems when the reset is released.*/
	sc_in<bool>			resetx;
	/// If the power of the system is stable
	/** When this is false and resetx is false, it is considered a cold reset and
	everything int the registers are reinitialized.  Clock must be running before
	this becomes asserted to ensure a valid reset of registers.

	*** WARNING ***:The core assumes that this input has been properly synchronized 
	        with the clock to avoid problems when the reset is released.*/
	sc_in<bool>			pwrok;
	/// Signal to stop the links in order to save power.
	/** Can be asynchronous, it is registered inside the design*/
	sc_in<bool>			ldtstopx;

	//Link0 signals
	///If there is data available for the core from the link
	/** If the core runs at a frequency higher than the physical link, sometime
	the link will not have data available for the core.  This does not
	cause problem*/
	sc_in<bool>						phy0_available_lk0;
	///RX CTL Higher is received later (MSB), lower is received first (LSB)
	/** This is the content of a shift register that stored the value
	of the CTL bit on the input.  CAD_IN_DEPTH depends on the PHY to core
	clock ratio.*/
	sc_in<sc_bv<CAD_IN_DEPTH> >		phy0_ctl_lk0;
	///RX CAD Higher is received later (MSB), lower is received first (LSB)
	/** This is the content of a shift register that stored the value
	of the CAD bits on the input.  CAD_IN_DEPTH depends on the PHY to core
	clock ratio.*/
	sc_in<sc_bv<CAD_IN_DEPTH> >		phy0_cad_lk0[CAD_IN_WIDTH];

	///TX CTL Higher is sent later (MSB), lower is sent first (LSB)
	sc_out<sc_bv<CAD_OUT_DEPTH> >	lk0_ctl_phy0;
	///TX CAD Higher is sent later (MSB), lower is sent first (LSB)
	sc_out<sc_bv<CAD_OUT_DEPTH> >	lk0_cad_phy0[CAD_OUT_WIDTH];
	///If the physical layer can consume the data we produce
	/** If the core runs at a frequency higher than the link, sometime
	the link will not be able to consume data produced from the core.  This does not
	cause problem*/
	sc_in<bool>						phy0_consume_lk0;
	
	///To disable the drivers to save power
	sc_out<bool> 		lk0_disable_drivers_phy0;
	///To disable the receivers to save power
	sc_out<bool> 		lk0_disable_receivers_phy0;
	///Frequency requested to clocking logic for side 0
	sc_out<sc_bv<4> > link_frequency0_phy;

#ifndef INTERNAL_SHIFTER_ALIGNMENT
	///High speed deserializer should stall shifting bits for lk_deser_stall_cycles_phy cycles
	/** Cannot be asserted with a lk_deser_stall_cycles_phy value of 0*/
	sc_out<bool > lk0_deser_stall_phy0;
	///Number of bit times to stall deserializing incoming data when lk_deser_stall_phy is asserted
	sc_out<sc_uint<LOG2_CAD_IN_DEPTH> > lk0_deser_stall_cycles_phy0;
#endif

	//Link1 signals
	///If there is data available for the core from the link
	/** If the core runs at a frequency higher than the link, sometime
	the link will not have data available for the core.  This does not
	cause problem*/
	sc_in<bool>						phy1_available_lk1;
	///RX CTL Higher is received later (MSB), lower is received first (LSB)
	/** This is the content of a shift register that stored the value
	of the CTL bit on the input.  CAD_IN_DEPTH depends on the PHY to core
	clock ratio.*/
	sc_in<sc_bv<CAD_IN_DEPTH> >		phy1_ctl_lk1;
	///RX CAD Higher is received later (MSB), lower is received first (LSB)
	/** This is the content of a shift register that stored the value
	of the CAD bits on the input.  CAD_IN_DEPTH depends on the PHY to core
	clock ratio.*/
	sc_in<sc_bv<CAD_IN_DEPTH> >		phy1_cad_lk1[CAD_IN_WIDTH];
	///If the physical layer can consume the data we produce
	/** If the core runs at a frequency higher than the link, sometime
	the link will not be able to consume data produced from the core.  This does not
	cause problem*/
	sc_in<bool>						phy1_consume_lk1;

	///TX CTL Higher is sent later (MSB), lower is sent first (LSB)
	sc_out<sc_bv<CAD_OUT_DEPTH> >	lk1_ctl_phy1;
	///TX CAD Higher is sent later (MSB), lower is sent first (LSB)
	sc_out<sc_bv<CAD_OUT_DEPTH> >	lk1_cad_phy1[CAD_OUT_WIDTH];
#ifndef INTERNAL_SHIFTER_ALIGNMENT
	///High speed deserializer should stall shifting bits for lk_deser_stall_cycles_phy cycles
	/** Cannot be asserted with a lk_deser_stall_cycles_phy value of 0*/
	sc_out<bool > lk1_deser_stall_phy1;
	///Number of bit times to stall deserializing incoming data when lk_deser_stall_phy is asserted
	sc_out<sc_uint<LOG2_CAD_IN_DEPTH> > lk1_deser_stall_cycles_phy1;
#endif
	
	///To disable the drivers to save power
	sc_out<bool> 		lk1_disable_drivers_phy1;
	///To disable the receivers to save power
	sc_out<bool> 		lk1_disable_receivers_phy1;

	///Frequency requested to clocking logic for side 1
	sc_out<sc_bv<4> > link_frequency1_phy;

	/////////////////////////////////////////////////////
	// Interface to UserInterface memory - synchronous
	/////////////////////////////////////////////////////

	sc_out<bool> ui_memory_write0;///< Write signal to UI memory 0
	sc_out<bool> ui_memory_write1;///< Write signal to UI memory 1
	sc_out<sc_bv<USER_MEMORY_ADDRESS_WIDTH> > ui_memory_write_address;///< Address where to write in UI mem 0 and 1
	sc_out<sc_bv<32> > ui_memory_write_data;///< Data to write in UI mem 0 and 1

	sc_out<sc_bv<USER_MEMORY_ADDRESS_WIDTH> > ui_memory_read_address0;///< Address where to read in UI mem 0
	sc_out<sc_bv<USER_MEMORY_ADDRESS_WIDTH> > ui_memory_read_address1;///< Address where to read in UI mem 1
	sc_in<sc_bv<32> > ui_memory_read_data0;///< Output of UI mem 0
	sc_in<sc_bv<32> > ui_memory_read_data1;///< Output of UI mem 1

#ifdef RETRY_MODE_ENABLED
	//////////////////////////////////////////
	//	Memory interface flowcontrol0 - synchronous
	/////////////////////////////////////////
	sc_out<bool> history_memory_write0;///< Write signal to history memory 0
	sc_out<sc_uint<LOG2_HISTORY_MEMORY_SIZE> > history_memory_write_address0;///< Address where to write in history memory 0
	sc_out<sc_bv<32> > history_memory_write_data0;///< Data to write in history memory 0
	sc_out<sc_uint<LOG2_HISTORY_MEMORY_SIZE> > history_memory_read_address0;///< Address where to read in history memory 0
	sc_in<sc_bv<32> > history_memory_output0;///< Output of history memory 0
	
	//////////////////////////////////////////
	//	Memory interface flowcontrol1 - synchronous
	/////////////////////////////////////////
	sc_out<bool> history_memory_write1;///< Write signal to history memory 1
	sc_out<sc_uint<LOG2_HISTORY_MEMORY_SIZE> > history_memory_write_address1;///< Address where to write in history memory 1
	sc_out<sc_bv<32> > history_memory_write_data1;///< Data to write in history memory 1
	sc_out<sc_uint<LOG2_HISTORY_MEMORY_SIZE> > history_memory_read_address1;///< Address where to read in history memory 1
	sc_in<sc_bv<32> > history_memory_output1;///< Output of history memory 1

#endif
	
	////////////////////////////////////
	// Memory interface databuffer0 - synchronous
	////////////////////////////////////
	
	sc_out<bool> memory_write0;///< Write signal to databuffer memory 1
	sc_out<sc_uint<2> > memory_write_address_vc0;///< VC to write in databuffer memory 0 (MSB of write address - only 3 VC's)
	sc_out<sc_uint<BUFFERS_ADDRESS_WIDTH> > memory_write_address_buffer0;///< Buffer to write in databuffer memory 0 (center of write address)
	sc_out<sc_uint<4> > memory_write_address_pos0;///< Pos in buffer to write in databuffer memory 0 (LSB of write address)
	sc_out<sc_bv<32> > memory_write_data0;///< Data to write in databuffers memory 0
	
	sc_out<sc_uint<2> > memory_read_address_vc0[2];///< VC to read in databuffer memory 0 (MSB of read address - only 3 VC's)
	sc_out<sc_uint<BUFFERS_ADDRESS_WIDTH> >memory_read_address_buffer0[2];///< Buffer to read in databuffer memory 0 (center of read address)
	sc_out<sc_uint<4> > memory_read_address_pos0[2];///< Pos in buffer to read in databuffer memory 0 (LSB of read address)

	sc_in<sc_bv<32> > memory_output0[2];///< Output of databuffer memory 0
	
	//////////////////////////////////////
	// Memory interface databuffer1 - synchronous
	////////////////////////////////////
	
	sc_out<bool> memory_write1;///< Write signal to databuffer memory 1
	sc_out<sc_uint<2> > memory_write_address_vc1;///< VC to write in databuffer memory 1 (MSB of write address - only 3 VC's)
	sc_out<sc_uint<BUFFERS_ADDRESS_WIDTH> > memory_write_address_buffer1;///< Buffer to write in databuffer memory 1 (center of write address)
	sc_out<sc_uint<4> > memory_write_address_pos1;///< Pos in buffer to write in databuffer memory 1 (LSB of write address)
	sc_out<sc_bv<32> > memory_write_data1;///< Data to write in databuffers memory 1
	
	sc_out<sc_uint<2> > memory_read_address_vc1[2];///< VC to read in databuffer memory 1 (MSB of read address - only 3 VC's)
	sc_out<sc_uint<BUFFERS_ADDRESS_WIDTH> >memory_read_address_buffer1[2];///< Buffer to read in databuffer memory 1 (center of read address)
	sc_out<sc_uint<4> > memory_read_address_pos1[2];///< Pos in buffer to read in databuffer memory 1 (LSB of read address)

	sc_in<sc_bv<32> > memory_output1[2];///< Output of databuffer memory 1

	
	///////////////////////////////////////
	// Interface to command memory 0
	///////////////////////////////////////
	sc_out<sc_bv<CMD_BUFFER_MEM_WIDTH> > ro0_command_packet_wr_data;
	sc_out<bool > ro0_command_packet_write;
	sc_out<sc_uint<LOG2_NB_OF_BUFFERS+2> > ro0_command_packet_wr_addr;
	sc_out<sc_uint<LOG2_NB_OF_BUFFERS+2> > ro0_command_packet_rd_addr[2];
	sc_in<sc_bv<CMD_BUFFER_MEM_WIDTH> > command_packet_rd_data_ro0[2];

	///////////////////////////////////////
	// Interface to command memory 1
	///////////////////////////////////////
	sc_out<sc_bv<CMD_BUFFER_MEM_WIDTH> > ro1_command_packet_wr_data;
	sc_out<bool > ro1_command_packet_write;
	sc_out<sc_uint<LOG2_NB_OF_BUFFERS+2> > ro1_command_packet_wr_addr;
	sc_out<sc_uint<LOG2_NB_OF_BUFFERS+2> > ro1_command_packet_rd_addr[2];
	sc_in<sc_bv<CMD_BUFFER_MEM_WIDTH> > command_packet_rd_data_ro1[2];


	//******************************************
	//			Signals to User
	//******************************************
	//------------------------------------------
	// Signals to send received packets to User
	//------------------------------------------


	/**The actual control/data packet to the user*/
	sc_out<sc_bv<64> >		ui_packet_usr;

	/**The virtual channel of the ctl/data packet*/
	sc_out<VirtualChannel>	ui_vc_usr;

	/**The side from which came the packet*/
	sc_out< bool >			ui_side_usr;

#ifdef ENABLE_DIRECTROUTE
	/**If the packet is a direct_route packet - only valid for
	   requests (posted and non-posted) */
	sc_out<bool>			ui_directroute_usr;
#endif
	/**If this is the last part of the packet*/
	sc_out< bool >			ui_eop_usr;
	
	/**If there is another packet available*/
	sc_out< bool >			ui_available_usr;

	/**If what is read is 64 bits or 32 bits*/
	sc_out< bool >			ui_output_64bits_usr;

	/**To allow the user to consume the packets*/
	sc_in< bool >			usr_consume_ui;


	//------------------------------------------
	// Signals to allow the User to send packets
	//------------------------------------------

	/**The actual control/data packet from the user*/
	sc_in<sc_bv<64> >		usr_packet_ui;

	/**If there is another packet available*/
	sc_in< bool >			usr_available_ui;

	/**
	The side to send the packet if it is a response
	This bit is ignored if the packet is not a response
	since the side to send a request is determined automatically
	taking in acount DirectRoute functionnality.
	*/
	sc_in< bool >			usr_side_ui;

	/**Which what type of ctl packets can be sent to side0
	FREE_VC_POSTED_POS = 5
	FREE_VC_POSTED_DATA_POS =  4
	FREE_VC_NPOSTED_POS =  3
	FREE_VC_NPOSTED_DATA_POS = 2
	FREE_VC_RESPONSE_POS = 1
	FREE_VC_RESPONSE_DATA_POS = 0
	*/
	sc_out<sc_bv<6> >		ui_freevc0_usr;
	/**Which what type of ctl packets can be sent to side1*/
	sc_out<sc_bv<6> >		ui_freevc1_usr;

	//-----------------------------------------------
	// Content of CSR that might be useful to user
	//-----------------------------------------------
	/** Signals table containing all 40 bits Base Addresses from BARs implemented */
	sc_out<sc_bv<40> > csr_bar[NbRegsBars];
	/** Signal from register Interface->Command->csr_unit_id */
	sc_out<sc_bv<5> > csr_unit_id;


	//------------------------------------------
	// Signals to affect CSR
	//------------------------------------------
	sc_in<bool> usr_receivedResponseError_csr;

	//--------------------------------------------------------
	// Interface for having registers outside CSR if necessary
	//--------------------------------------------------------

	///Signals to allow external registers with minimal logic
	/**
		Connect usr_read_data_csr to zeroes if not used!
	*/
	//@{
	///addresses dwords (4 bytes)
	sc_out<sc_uint<6> >	csr_read_addr_usr;
	sc_in<sc_bv<32> >	usr_read_data_csr;
	sc_out<bool >	csr_write_usr;
	///addresses dwords (4 bytes)
	sc_out<sc_uint<6> >	csr_write_addr_usr;
	sc_out<sc_bv<32> >	csr_write_data_usr;
	/**Every bit is a byte mask for the dword to write*/
	sc_out<sc_bv<4> >	csr_write_mask_usr;
	//@}



	//******************************************
	// Instanciation of sub-modules
	//******************************************
	

	//Side0
	decoder_l2 *the_decoder0_l2;
	databuffer_l2 *the_databuffer0_l2;
	flow_control_l2 *the_flow_control0_l2;
	link_l2 *the_link0_l2;
	errorhandler_l2 *the_errorhandler0_l2;	
	reordering_l2 *the_reordering0_l2;

	//Side1
	decoder_l2 *the_decoder1_l2;
	databuffer_l2 *the_databuffer1_l2;
	flow_control_l2 *the_flow_control1_l2;
	link_l2 *the_link1_l2;
	errorhandler_l2 *the_errorhandler1_l2;	
	reordering_l2 *the_reordering1_l2;

	//Shared
	csr_l2 *the_csr_l2;
	userinterface_l2 *the_userinterface_l2;
	misc_logic_l2 *the_misc_logic_l2;

	// *********************************
	//  Flow control - UserInterface
	// **********************************
	//Side 0
    sc_signal <sc_bv<64> >			ui_packet_fc0;
	sc_signal <bool>				ui_available_fc0;
	sc_signal <sc_bv<3> >			fc0_user_fifo_ge2_ui;
	
	sc_signal <VirtualChannel>		fc0_data_vc_ui;	
	sc_signal <sc_bv<32> >			ui_data_fc0; 
	sc_signal <bool>				fc0_consume_data_ui;

	//Side 1
    sc_signal <sc_bv<64> >			ui_packet_fc1;
	sc_signal <bool>				ui_available_fc1;
	sc_signal <sc_bv<3> >			fc1_user_fifo_ge2_ui;
	
	sc_signal <VirtualChannel>		fc1_data_vc_ui;	
	sc_signal <sc_bv<32> >			ui_data_fc1; 
	sc_signal <bool>				fc1_consume_data_ui;

	// *********************************
	//  Flow control - CSR
	// **********************************
	//Side 0
	sc_signal <bool> fc0_ack_csr;	
	sc_signal <bool> csr_available_fc0;
	sc_signal <sc_bv<32> > csr_dword_fc0;

#ifdef RETRY_MODE_ENABLED
	sc_signal<bool>		fc0_clear_single_error_csr;
	sc_signal<bool>		fc0_clear_single_stomp_csr;
	sc_signal<bool>		csr_force_single_stomp_fc0;
	sc_signal<bool>		csr_force_single_error_fc0;
#endif

	

	//Side 1
	sc_signal <bool> fc1_ack_csr;	
	sc_signal <bool> csr_available_fc1;
	sc_signal <sc_bv<32> > csr_dword_fc1;

#ifdef RETRY_MODE_ENABLED
	sc_signal<bool>		fc1_clear_single_error_csr;
	sc_signal<bool>		fc1_clear_single_stomp_csr;
	sc_signal<bool>		csr_force_single_stomp_fc1;
	sc_signal<bool>		csr_force_single_error_fc1;
#endif

	
	// *********************************
	//  Flow control - ErrorHandler
	// *********************************
	//Side 0
	sc_signal <bool> fc0_ack_eh0;
	sc_signal <sc_bv<32> > eh0_cmd_data_fc0;
	sc_signal <bool> eh0_available_fc0;

	//Side 1
	sc_signal <bool> fc1_ack_eh1;
	sc_signal <sc_bv<32> > eh1_cmd_data_fc1;
	sc_signal <bool> eh1_available_fc1;

	// *********************************
	//  Flow control - Link
	// *********************************
	//Side 0
    sc_signal <sc_bv<32> > fc0_dword_lk0;
    sc_signal <bool> fc0_lctl_lk0;
    sc_signal <bool> fc0_hctl_lk0;
    sc_signal  <bool> lk0_consume_fc0;
	sc_signal  <bool> lk0_rx_connected;
#ifdef RETRY_MODE_ENABLED
    sc_signal <bool> fc0_disconnect_lk0;
#endif
	//Side 1
    sc_signal <sc_bv<32> > fc1_dword_lk1;
    sc_signal <bool> fc1_lctl_lk1;
    sc_signal <bool> fc1_hctl_lk1;
    sc_signal  <bool> lk1_consume_fc1;
	sc_signal  <bool> lk1_rx_connected;
#ifdef RETRY_MODE_ENABLED
    sc_signal <bool> fc1_disconnect_lk1;
#endif

	// *********************************
	//  Flow control (Forward) - Reordering
	// *********************************
	//Side 0
    sc_signal <bool> ro1_available_fwd0;		
    sc_signal <syn_ControlPacketComplete > ro1_packet_fwd0;
    sc_signal <VirtualChannel > ro1_packet_vc_fwd0;
	sc_signal <bool> ro0_nop_req_fc0;
	sc_signal <sc_bv<6> > fwd0_next_node_buffer_status_ro1;

	//Side 1
    sc_signal <bool> ro0_available_fwd1;		
    sc_signal <syn_ControlPacketComplete > ro0_packet_fwd1;
    sc_signal <VirtualChannel > ro0_packet_vc_fwd1;
	sc_signal <bool> ro1_nop_req_fc1;
	sc_signal <sc_bv<6> > fwd1_next_node_buffer_status_ro0;
	
	// *********************************
	//  Flow control  - Reordering
	// *********************************
	//Side 0
    sc_signal <sc_bv<6> > ro0_buffer_cnt_fc0;
    sc_signal <bool> fwd0_ack_ro1;			//acknowledge

	//Side1
    sc_signal <sc_bv<6> > ro1_buffer_cnt_fc1;
    sc_signal <bool> fwd1_ack_ro0;			//acknowledge


	// *********************************
	//  Flow control (Forward) - Databuffer
	// *********************************
	//Side 0
    sc_signal <sc_uint<BUFFERS_ADDRESS_WIDTH> > fwd0_address_db1;
    sc_signal <VirtualChannel>  fwd0_vctype_db1;
    sc_signal <bool> fwd0_read_db1;
    sc_signal <sc_bv<32> > db1_data_fwd0;
	sc_signal< bool >	fwd0_erase_db1;

	//Side 1
    sc_signal <sc_uint<BUFFERS_ADDRESS_WIDTH> > fwd1_address_db0;
    sc_signal <VirtualChannel>  fwd1_vctype_db0;
    sc_signal <bool> fwd1_read_db0;
    sc_signal <sc_bv<32> > db0_data_fwd1;
	sc_signal< bool >	fwd1_erase_db0;

	// *********************************
	//  Flow control - Databuffer
	// *********************************
	//Side 0
    sc_signal <sc_bv<6> > db0_buffer_cnt_fc0;
	sc_signal <bool> db0_nop_req_fc0;

	//Side 1
    sc_signal <sc_bv<6> > db1_buffer_cnt_fc1;
	sc_signal <bool> db1_nop_req_fc1;

	// *********************************
	//  Flow control - Command decoder
	// **********************************
	//Side 0
#ifdef RETRY_MODE_ENABLED
	sc_signal <sc_uint<8> >	cd0_rx_next_pkt_to_ack_fc0;
	sc_signal<sc_uint<8> > cd0_nop_ack_value_fc0;
#endif

	sc_signal<sc_bv<12> > cd0_nopinfo_fc0;
    sc_signal<bool>		cd0_nop_received_fc0;

	//Side 1
#ifdef RETRY_MODE_ENABLED
	sc_signal <sc_uint<8> >	cd1_rx_next_pkt_to_ack_fc1;
	sc_signal<sc_uint<8> > cd1_nop_ack_value_fc1;
#endif

	sc_signal<sc_bv<12> > cd1_nopinfo_fc1;
    sc_signal<bool>		cd1_nop_received_fc1;

	//**********************************
	// CSR - Misc signals
	//**********************************
	//General
	//sc_signal<sc_bv<5> > csr_unit_id;

	//sc_signal<sc_bv<40> >	csr_bar[NbRegsBars];

	sc_signal<bool>			csr_memory_space_enable;
	sc_signal<bool>			csr_io_space_enable;

#ifdef ENABLE_DIRECTROUTE
	sc_signal<sc_bv<32> > csr_direct_route_base[DirectRoute_NumberDirectRouteSpaces];
	sc_signal<sc_bv<32> > csr_direct_route_limit[DirectRoute_NumberDirectRouteSpaces];
	sc_signal<sc_bv<32> > csr_direct_route_enable;
	sc_signal< bool >		csr_direct_route_oppposite_dir[DirectRoute_NumberDirectRouteSpaces];
#endif

	sc_signal<sc_bv<32> > csr_clumping_configuration;
#ifdef ENABLE_REORDERING
	sc_signal<bool> csr_unitid_reorder_disable;
#endif

	sc_signal< bool >			csr_default_dir;
	sc_signal< bool >			csr_master_host;
		
	sc_signal<bool>	csr_drop_uninit_link;
	sc_signal<bool>			csr_sync;


	//Side 0
#ifdef RETRY_MODE_ENABLED
	sc_signal <bool> csr_retry0;
#endif
	sc_signal< bool > csr_end_of_chain0;
	sc_signal<bool>	csr_initcomplete0;
	///Frequency set in the CSR for side 0
	sc_signal<sc_bv<4> > csr_link_frequency0;

	//Side 1
#ifdef RETRY_MODE_ENABLED
	sc_signal <bool> csr_retry1;
#endif
	sc_signal< bool > csr_end_of_chain1;
	sc_signal<bool>	csr_initcomplete1;

	sc_signal<bool> csr_bus_master_enable;
	///Frequency set in the CSR for side 1
	sc_signal<sc_bv<4> > csr_link_frequency1;

	//**********************************
	// Flow control - Misc signals
	//**********************************
	sc_signal <bool> fc0_nop_sent;
	sc_signal <bool> fc1_nop_sent;

	//**********************************
	// Link - Command decoder
	//**********************************
	//Side 0
	sc_signal< sc_bv<32> > 		lk0_dword_cd0;
	sc_signal< bool > 			lk0_hctl_cd0;
	sc_signal< bool > 			lk0_lctl_cd0;
	sc_signal< bool > 			lk0_available_cd0;
	sc_signal< bool >			cd0_initiate_nonretry_disconnect_lk0;

	//Side 1
	sc_signal< sc_bv<32> > 		lk1_dword_cd1;
	sc_signal< bool > 			lk1_hctl_cd1;
	sc_signal< bool > 			lk1_lctl_cd1;
	sc_signal< bool > 			lk1_available_cd1;
	sc_signal< bool >			cd1_initiate_nonretry_disconnect_lk1;

	
	//**********************************
	// Command decoder - Data Buffer
	//**********************************
	//Side 0
	sc_signal< sc_uint<BUFFERS_ADDRESS_WIDTH> >		db0_address_cd0;
	sc_signal< bool >				cd0_getaddr_db0;
	sc_signal< sc_uint<4> >		cd0_datalen_db0;
	sc_signal< VirtualChannel >	cd0_vctype_db0;
	sc_signal< sc_bv<32> > 		cd0_data_db0;
	sc_signal< bool > 			cd0_write_db0;
#ifdef RETRY_MODE_ENABLED
	sc_signal< bool >			cd0_drop_db0;
#endif

	//Side 1
	sc_signal< sc_uint<BUFFERS_ADDRESS_WIDTH> >		db1_address_cd1;
	sc_signal< bool >				cd1_getaddr_db1;
	sc_signal< sc_uint<4> >		cd1_datalen_db1;
	sc_signal< VirtualChannel >	cd1_vctype_db1;
	sc_signal< sc_bv<32> > 		cd1_data_db1;
	sc_signal< bool > 			cd1_write_db1;
#ifdef RETRY_MODE_ENABLED
	sc_signal< bool >			cd1_drop_db1;
#endif


	//**********************************
	// Command decoder - Reordering
	//**********************************
	//Side 0
    sc_signal< syn_ControlPacketComplete > 	cd0_packet_ro0;
	sc_signal< bool > 						cd0_available_ro0;
	sc_signal<bool>							cd0_data_pending_ro0;
	sc_signal<sc_uint<BUFFERS_ADDRESS_WIDTH> >	cd0_data_pending_addr_ro0;

	//Side 1
    sc_signal< syn_ControlPacketComplete > 	cd1_packet_ro1;
	sc_signal< bool > 						cd1_available_ro1;
	sc_signal<bool>							cd1_data_pending_ro1;
	sc_signal<sc_uint<BUFFERS_ADDRESS_WIDTH> >	cd1_data_pending_addr_ro1;

	//**********************************
	// Command decoder - CSR
	//**********************************
	//Side 0
	sc_signal< bool >			cd0_protocol_error_csr;
	sc_signal< bool >			cd0_sync_detected_csr;
#ifdef RETRY_MODE_ENABLED
	sc_signal<bool>				cd0_received_stomped_csr;
	sc_signal<bool>				cd0_received_non_flow_stomped_ro0;
#endif

	//Side 1
	sc_signal< bool >			cd1_protocol_error_csr;
	sc_signal< bool >			cd1_sync_detected_csr;
#ifdef RETRY_MODE_ENABLED
	sc_signal<bool>				cd1_received_stomped_csr;
	sc_signal<bool>				cd1_received_non_flow_stomped_ro1;
#endif

	//**********************************
	// Command decoder - Misc
	//**********************************
#ifdef RETRY_MODE_ENABLED
	sc_signal< bool >			cd0_initiate_retry_disconnect;

	sc_signal< bool >			cd1_initiate_retry_disconnect;
#endif

	//**********************************
	// Data buffer - Error handler
	//**********************************
	//Side 0
	sc_signal< sc_uint<BUFFERS_ADDRESS_WIDTH> >		eh0_address_db0;
	sc_signal< VirtualChannel >						eh0_vctype_db0;
	sc_signal< bool > 								eh0_erase_db0;

	//Side 1
	sc_signal< sc_uint<BUFFERS_ADDRESS_WIDTH> >		eh1_address_db1;
	sc_signal< VirtualChannel >						eh1_vctype_db1;
	sc_signal< bool > 								eh1_erase_db1;

	//**********************************
	// Data buffer - Accepted
	//**********************************
	//Side 0
	sc_signal< sc_bv<32> >							db0_data_accepted;

	//Side 1
	sc_signal< sc_bv<32> >							db1_data_accepted;

	//**********************************
	// Data buffer - CSR
	//**********************************
	//Side 0
	sc_signal< bool >								csr_erase_db0;
	sc_signal< sc_uint<BUFFERS_ADDRESS_WIDTH> >		csr_address_db0;
	sc_signal< bool > 								csr_read_db0;
	sc_signal< VirtualChannel > 					csr_vctype_db0;
	sc_signal< bool >								db0_overflow_csr;

	//Side 1
	sc_signal< bool >								csr_erase_db1;
	sc_signal< sc_uint<BUFFERS_ADDRESS_WIDTH> >		csr_address_db1;
	sc_signal< bool > 								csr_read_db1;
	sc_signal< VirtualChannel > 					csr_vctype_db1;
	sc_signal< bool >								db1_overflow_csr;

	//**********************************
	// Data buffer - User interface
	//**********************************
	//Side 0
	sc_signal< bool >		ui_erase_db0;
	sc_signal< sc_uint<BUFFERS_ADDRESS_WIDTH> >		ui_address_db0;
	sc_signal< bool > 								ui_read_db0;
	sc_signal< VirtualChannel >						ui_vctype_db0;
	sc_signal< sc_bv<32> >							db0_data_ui;
	sc_signal<bool>									ui_grant_csr_access_db0;
	
	//Side 1
	sc_signal< bool >		ui_erase_db1;
	sc_signal< sc_uint<BUFFERS_ADDRESS_WIDTH> >		ui_address_db1;
	sc_signal< bool > 								ui_read_db1;
	sc_signal< VirtualChannel >						ui_vctype_db1;
	sc_signal< sc_bv<32> >							db1_data_ui;
	sc_signal<bool>									ui_grant_csr_access_db1;


	//**********************************
	// Reordering - CSR
	//**********************************
	//Side 0
	sc_signal<syn_ControlPacketComplete> ro0_packet_csr;
	sc_signal<bool> ro0_available_csr;
	sc_signal<bool> csr_ack_ro0;
	sc_signal<bool>	ro0_overflow_csr;

	//Side 1
	sc_signal<syn_ControlPacketComplete> ro1_packet_csr;
	sc_signal<bool> ro1_available_csr;
	sc_signal<bool> csr_ack_ro1;
	sc_signal<bool>	ro1_overflow_csr;

	//*********************************
	// Reordering - User interface
	//*********************************
	//Side0
	sc_signal<syn_ControlPacketComplete> ro0_packet_ui;
	sc_signal<bool> ro0_available_ui;
	sc_signal<bool> ui_ack_ro0;	

	//Side1
	sc_signal<syn_ControlPacketComplete> ro1_packet_ui;
	sc_signal<bool> ro1_available_ui;
	sc_signal<bool> ui_ack_ro1;	

	//*********************************
	// Reordering - Error handler
	//*********************************
	//Side 0
	sc_signal<bool> eh0_ack_ro0;

	//Side 1
	sc_signal<bool> eh1_ack_ro1;

	//**********************************
	// User interface - CSR
	//**********************************
	sc_signal<bool> ui_sendingPostedDataError_csr;
	sc_signal<bool> ui_sendingTargetAbort_csr;

	sc_signal<bool> ui_receivedResponseDataError_csr;
	sc_signal<bool> ui_receivedPostedDataError_csr;
	sc_signal<bool> ui_receivedTargetAbort_csr;
	sc_signal<bool> ui_receivedMasterAbort_csr;

	sc_signal<bool> csr_request_databuffer0_access_ui;
	sc_signal<bool> csr_request_databuffer1_access_ui;
	sc_signal<bool> ui_databuffer_access_granted_csr;

	//**********************************
	// Link - CSR
	//**********************************
	//Side 0
	sc_signal<bool>			lk0_update_link_width_csr;
	sc_signal<sc_bv<3> >	lk0_sampled_link_width_csr;

	sc_signal<bool>			csr_crc_force_error_lk0;
	sc_signal<bool>			csr_transmitter_off_lk0;
	sc_signal<bool>			csr_extented_ctl_lk0;
	sc_signal<bool>			csr_extended_ctl_timeout_lk0;
	sc_signal<bool>			csr_ldtstop_tristate_enable_lk0;


	sc_signal<sc_bv<3> >	csr_rx_link_width_lk0;
	sc_signal<sc_bv<3> >	csr_tx_link_width_lk0;

	sc_signal<bool>			lk0_link_failure_csr;
	//sc_signal<bool>			lk0_sync_detected_csr;

	sc_signal<bool>			lk0_crc_error_csr;
	sc_signal<bool>			lk0_update_link_failure_property_csr;
#ifdef RETRY_MODE_ENABLED
	sc_signal<bool>			lk0_initiate_retry_disconnect;
#endif
	sc_signal<bool>			lk0_protocol_error_csr;

	//Side 1
	sc_signal<bool>			lk1_update_link_width_csr;
	sc_signal<sc_bv<3> >	lk1_sampled_link_width_csr;

	sc_signal<bool>			csr_crc_force_error_lk1;
	sc_signal<bool>			csr_transmitter_off_lk1;
	sc_signal<bool>			csr_extented_ctl_lk1;
	sc_signal<bool>			csr_extended_ctl_timeout_lk1;
	sc_signal<bool>			csr_ldtstop_tristate_enable_lk1;

	sc_signal<sc_bv<3> >	csr_rx_link_width_lk1;
	sc_signal<sc_bv<3> >	csr_tx_link_width_lk1;

	sc_signal<bool>			lk1_link_failure_csr;
	//sc_signal<bool>			lk1_sync_detected_csr;

	sc_signal<bool>			lk1_crc_error_csr;
	sc_signal<bool>			lk1_update_link_failure_property_csr;
#ifdef RETRY_MODE_ENABLED
	sc_signal<bool>			lk1_initiate_retry_disconnect;
#endif
	sc_signal<bool>			lk1_protocol_error_csr;

	//**********************************
	// Misc logic signals
	//**********************************

	///When the link is completely disconnected for LDTSTOP (side 0)
	sc_signal<bool> lk0_ldtstop_disconnected;
	///When the link is completely disconnected for LDTSTOP (side 0)
	sc_signal<bool> lk1_ldtstop_disconnected;


#ifdef ENABLE_REORDERING
	/// Calculated clumping configuration
	sc_signal<sc_bv<5> > clumped_unit_id[32];
#else
	/// Calculated clumping configuration
	sc_signal<sc_bv<5> > clumped_unit_id[4];
#endif

	///Second of two registers to store ldtstopx
	sc_signal<bool> registered_ldtstopx;


	//*****************************************
	//*****************************************
	// END OF COMMUNICATION SIGNAL DECLARATIONS
	//*****************************************
	//*****************************************


	///Constructor of the module
	vc_ht_tunnel_l1(sc_module_name name);

#ifdef SYSTEMC_SIM
	~vc_ht_tunnel_l1();
#endif

};
	
#endif	
