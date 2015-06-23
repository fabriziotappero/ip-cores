//csr_l2.h

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
 *   Michel Morneau
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

#ifndef CSR_L2_H
#define CSR_L2_H


#include "../core_synth/synth_datatypes.h"
#include "../core_synth/constants.h"


/// Configuration Space Registers (CSR) of HyperTransport tunnel
/**
	This module contains all Configuration registers required for
	HyperTransport tunnel.  Capabilities block implanted are:
	Device Header, Interface, Error Retry, Direct Route, Revision ID
	and Unit ID Clumping.  It manages registers, receive and send
	required signals to/from other modules, and processes Write and
	Read request packets addressed to CSR.
	
	@author 
		Current implementation: Ami Castonguay
		Original software implementation : Michel Morneau

	Configuration registers -->  
	All registers are implanted using the same hierarchy as the
	HyperTransport specification.  Implanted blocks contain a certain
	number of double-words addresses corresponding to byte addressing.
	Each of those double-words contains a certain number of registers,
	that may contain a set of flags.

	Control signals -->  
	The registers required by other modules are outputed as signals
	and updated at each clock cycle.  CSR reads some state signals
	from other module, and update corresponding signals at each clock
	cycle.

	Request packets -->  
	CSR reads packets from Reordering module.  Valid packets are Write
	and Read.  For a write packet, data is requested in Data Buffer
	module and then written in CSR registers.  1 double-word data is
	processed each clock cycle.  For non-posted write, a Target Done
	packet is sent to Flow Control module.  For a read packet, a Read
	Response packet is sent to Flow Control module, followed by requested
	double-words from CSR.
*/
class csr_l2 : public sc_module
{
	///Sates for the CSR state machine
	enum csr_states {
		CSR_IDLE, /**<The CSR is waiting for requests*/
		CSR_BEGIN_BYTE_WRITE,/**<Send data address to DataBuffer*/
		CSR_BYTE_WRITE_MASK,/**<Get the write mask from the DataBuffer*/
		CSR_BYTE_WRITE,/**<Do the actual byte write*/
		CSR_IDLE_TARGET_DONE_PENDING,/**<TargetDone waiting to be sent, stay in
			this state until it cas be sent*/
		CSR_BEGIN_DWORD_WRITE,/**<Send data address to DataBuffer*/
		CSR_DWORD_WRITE,/**<Do the actual dword write*/
		CSR_BEGIN_READ_WAIT_TGTDONE,/**<Begin a read operation, but first wait
			for the current target done to be sent*/
		CSR_BEGIN_READ,/**<Start the read : send the read command packet*/
		CSR_READ,/**<Continue reading and sending the read data*/
	};

public:

	//*******************
	//  General signals
	//*******************
	
	/// Clock signal
	sc_in_clk clk;

	///Reset signal (active low)
	sc_in<bool> resetx;
	///If the power is stable, (for cold reset)
	sc_in<bool> pwrok;
	///Asserted when the link goes in ldtstop (power saving) mode (active low)
	sc_in<bool> ldtstopx;

	/** asserted when there is a cold reset*/
	sc_signal<bool> coldrstx;

	///If the tunnel is in sync mode
	/**
		When a critical error is detected, sync flood is sent.  When
		a sync flood is received, we also fall in sync mode.  This
		cascades and resyncs the complete HT chain.
	*/
	sc_out<bool>		csr_sync;

	//****************************************************
	//  Signals for communication with User Interface module
	//****************************************************

	/** Access to the databuffer is shared with UI, must request acess*/
	sc_out<bool> csr_request_databuffer0_access_ui;
	/** Access to the databuffer is shared with UI, must request acess*/
	sc_out<bool> csr_request_databuffer1_access_ui;
	/** When the access to databuffer is granted following the assertion of
	::csr_request_databuffer0_access_ui or ::csr_request_databuffer1_access_ui*/
	sc_in<bool> ui_databuffer_access_granted_csr;


	//****************************************************
	//  Signals for communication with Reordering module
	//****************************************************

	/** @name Reordering
	*  Signals for communication with Reordering module
	*/
	//@{
	/** Packet is ready to read from Reordering module */
	sc_in<bool> ro0_available_csr;
	/** Packet from Reordering module */
	sc_in<syn_ControlPacketComplete > ro0_packet_csr;
	/** Packet from Reordering has been read by CSR */
	sc_out<bool> csr_ack_ro0;

	/** Packet is ready to read from Reordering module */
	sc_in<bool> ro1_available_csr;
	/** Packet from Reordering module */
	sc_in<syn_ControlPacketComplete > ro1_packet_csr;
	/** Packet from Reordering has been read by CSR */
	sc_out<bool> csr_ack_ro1;

	//@}


	//*****************************************************
	//  Signals for communication with Data Buffer module
	//*****************************************************

	/** @name DataBuffer
	*  Signals for communication with Data Buffer module
	*/
	//@{

	/** Consume data from Data Buffer 0 */
	sc_out<bool> csr_read_db0;
	/** Consume data from Data Buffer 1 */
	sc_out<bool> csr_read_db1;

	/** Address of the data packet requested in Data Buffer 0 */
	sc_out<sc_uint<BUFFERS_ADDRESS_WIDTH> > csr_address_db0;
	/** Address of the data packet requested in Data Buffer 1 */
	sc_out<sc_uint<BUFFERS_ADDRESS_WIDTH> > csr_address_db1;

	/** Virtual Channel of the data requested in Data Buffer 0 */
	sc_out<VirtualChannel > csr_vctype_db0;
	/** Virtual Channel of the data requested in Data Buffer 1 */
	sc_out<VirtualChannel > csr_vctype_db1;

	/** 32 bit data sent from Data Buffer to CSR */
	sc_in<sc_bv<32> > db0_data_csr;
	/** 32 bit data sent from Data Buffer to CSR */
	sc_in<sc_bv<32> > db1_data_csr;

	/** Last dword of data from Data Buffer 0 */
	sc_out<bool> csr_erase_db0;
	/** Last dword of data from Data Buffer 1 */
	sc_out<bool> csr_erase_db1;
	//@}
	

	//******************************************************
	//  Signals for communication with Flow Control module
	//******************************************************

	/** @name FlowControl
	*  Signals for communication with Flow Control module
	*/
	//@{

	/** Request to Flow Control to send packet */
	sc_out<bool> csr_available_fc0;
	/** 32 bit packet or data to Flow Control */
	sc_out<sc_bv<32> > csr_dword_fc0;
	/** Flow Control has read the last 32 bit packet or data */
	sc_in<bool> fc0_ack_csr;


	/** Request to Flow Control to send packet */
	sc_out<bool> csr_available_fc1;
	/** 32 bit packet or data to Flow Control */
	sc_out<sc_bv<32> > csr_dword_fc1;
	/** Flow Control has read the last 32 bit packet or data */
	sc_in<bool> fc1_ack_csr;

	//@}



	//************************************************************
	//  Normal input signals from other modules to CSR registers
	//************************************************************

	/* 
	*  Input signals received from other modules to CSR
	*/
	
	/** @name Packet analysis from UI
	Signals that come from analyzed packet going through the UI	*/
	//@{
	///Posted packet with a data error detected
	sc_in<bool> ui_sendingPostedDataError_csr;
	///Packet with a TargetAbort detected
	sc_in<bool> ui_sendingTargetAbort_csr;
	///Response packet with a data error detected
	sc_in<bool> ui_receivedResponseDataError_csr;
	///Posted packet with a data error received
	sc_in<bool> ui_receivedPostedDataError_csr;
	///Packet with target abort received
	sc_in<bool> ui_receivedTargetAbort_csr;
	///Packet with master abort received
	sc_in<bool> ui_receivedMasterAbort_csr;
	//@}

	///When the user received a response with an error
	sc_in<bool> usr_receivedResponseError_csr;


	/** @name Register extension interface
		Signals to allow external registers with minimal logic
		Connect usr_read_data_csr to zeroes if not used!
	*/
	//@{
	///Read address into extended registers, addresses dwords (4 bytes)
	sc_out<sc_uint<6> >	csr_read_addr_usr;
	///Read data from extended registers
	sc_in<sc_bv<32> >	usr_read_data_csr;
	///Write in extended registers
	sc_out<bool >	csr_write_usr;
	///Write address in extended registers, addresses dwords (4 bytes)
	sc_out<sc_uint<6> >	csr_write_addr_usr;
	///Write data in extended registers
	sc_out<sc_bv<32> >	csr_write_data_usr;
	///Write byte mask in extended registers
	sc_out<sc_bv<4> >	csr_write_mask_usr;
	//@}



	///Overflow of the buffers of the databuffer0
	sc_in<bool> db0_overflow_csr;
	///Overflow of the buffers of the reordering0
	sc_in<bool> ro0_overflow_csr;
	///Overflow of the buffers of the databuffer1
	sc_in<bool> db1_overflow_csr;
	///Overflow of the buffers of the reordering1
	sc_in<bool> ro1_overflow_csr;

	///If the Error Handler consumes data, it means that there is an end of chain error
	sc_in<bool> eh0_ack_ro0;
	///If the Error Handler consumes data, it means that there is an end of chain error
	sc_in<bool> eh1_ack_ro1;

	/// Link0 has completed it's initialization
	sc_in<bool> lk0_initialization_complete_csr;	
#ifdef RETRY_MODE_ENABLED
	///Link0 asks to initiate a retry disconnect (probably due to a protocol error)
	sc_in<bool> lk0_initiate_retry_disconnect;
#endif
	/// Link0 has completed it's initialization
	sc_in<bool > lk0_crc_error_csr;
	/// Link0 detected a protocol error
	sc_in<bool>	lk0_protocol_error_csr;


	/// Link1 has completed it's initialization
	sc_in<bool> lk1_initialization_complete_csr;
#ifdef RETRY_MODE_ENABLED
	///Link1 asks to initiate a retry disconnect (probably due to a protocol error)
	sc_in<bool> lk1_initiate_retry_disconnect;
#endif
	/// Link1 has completed it's initialization
	sc_in<bool > lk1_crc_error_csr;
	/// Link1 detected a protocol error
	sc_in<bool>	lk1_protocol_error_csr;

	/** Signal to register Interface->LinkError_0->ProtocolError_0 */
	sc_in<bool> cd0_protocol_error_csr;

	///When the command decoder0 detects a sync
	sc_in<bool> cd0_sync_detected_csr;
	/** Signal to register Interface->LinkError_1->ProtocolError_1 */
	sc_in<bool> cd1_protocol_error_csr;
#ifdef RETRY_MODE_ENABLED
	/** Signal to register ErrorRetry->Status_0->RetrySent_0 */
	sc_in<bool> cd0_initiate_retry_disconnect;
	/** Signal to register ErrorRetry->Status_0->StompReceived_0 */
	sc_in<bool> cd0_received_stomped_csr;
	/** Signal to register ErrorRetry->Status_1->RetrySent_1 */
	sc_in<bool> cd1_initiate_retry_disconnect;
	/** Signal to register ErrorRetry->Status_1->StompReceived_1 */
	sc_in<bool> cd1_received_stomped_csr;
#endif

	///When the command decode1r detects a sync
	sc_in<bool> cd1_sync_detected_csr;



	///Update the registers with the value of "link failure" from the link
	sc_in<bool>			lk0_update_link_failure_property_csr;
	///Update the registers with the value of "link width" from the link
	sc_in<bool>			lk0_update_link_width_csr;
	///Detected link width (only valid when lk0_update_link_width_csr)
	sc_in<sc_bv<3> >	lk0_sampled_link_width_csr;
	///Detected link failure (only valid when lk0_update_link_failure_property_csr)
	sc_in<bool>			lk0_link_failure_csr;

#ifdef RETRY_MODE_ENABLED
	///Clear the bit that forces a single CRC error to be sent
	sc_in<bool>			fc0_clear_single_error_csr;
	///Clear the bit that forces a single CRC stomp to be sent
	sc_in<bool>			fc0_clear_single_stomp_csr;
	///Clear the bit that forces a single CRC error to be sent
	sc_in<bool>			fc1_clear_single_error_csr;
	///Clear the bit that forces a single CRC stomp to be sent
	sc_in<bool>			fc1_clear_single_stomp_csr;
#endif

	///Update the registers with the value of "link failure" from the link
	sc_in<bool>			lk1_update_link_failure_property_csr;
	///Update the registers with the value of "link width" from the link
	sc_in<bool>			lk1_update_link_width_csr;
	///Detected link width (only valid when lk1_update_link_width_csr)
	sc_in<sc_bv<3> >	lk1_sampled_link_width_csr;
	///Detected link failure (only valid when lk1_update_link_failure_property_csr)
	sc_in<bool>			lk1_link_failure_csr;

	

	//***********************************************
	//  Outputs from CSR registers to other modules
	//***********************************************

	/** Signal from register DeviceHeader->Command->csr_io_space_enable */
	sc_out<bool> csr_io_space_enable;
	/** Signal from register DeviceHeader->Command->csr_memory_space_enable */
	sc_out<bool> csr_memory_space_enable;
	/** Signal from register DeviceHeader->Command->csr_bus_master_enable */
	sc_out<bool> csr_bus_master_enable;
	/** Signal from register Interface->Command->Master host */
	sc_out<bool> csr_master_host;
	/** Signal derived from register DeviceHeader->Command->Master host */		
	//sc_out<bool> csr_is_upstream0;
	/** Signal derived from register DeviceHeader->Command->Master host */		
	//sc_out<bool> csr_is_upstream1;
	/** Signals table containing all 40 bits Base Addresses from BARs implemented */
	sc_out<sc_bv<40> > csr_bar[NbRegsBars];
	/** Signal from register Interface->Command->csr_unit_id */
	sc_out<sc_bv<5> > csr_unit_id;
	/** Signal from register Interface->Command->csr_default_dir */
	sc_out<bool> csr_default_dir;
	/** Signal from register Interface->Command->csr_drop_uninit_link */
	sc_out<bool> csr_drop_uninit_link;
	/** Signal from register Interface->LinkControl_0->csr_crc_force_error_lk0 */
	sc_out<bool> csr_crc_force_error_lk0;
	/** Signal from register Interface->LinkControl_0->csr_end_of_chain0 */
	sc_out<bool> csr_end_of_chain0;
	/** Signal from register Interface->LinkControl_0->csr_transmitter_off_lk0 */
	sc_out<bool> csr_transmitter_off_lk0;
	/** Signal from register Interface->LinkControl_0->csr_ldtstop_tristate_enable_lk0 */
	sc_out<bool> csr_ldtstop_tristate_enable_lk0;
	/** Signal from register Interface->LinkControl_0->csr_extented_ctl_lk0 */
	sc_out<bool> csr_extented_ctl_lk0;
	/** Signal from register Interface->LinkConfiguration_0->csr_rx_link_width_lk0 */
	sc_out<sc_bv<3> > csr_rx_link_width_lk0;
	/** Signal from register Interface->LinkConfiguration_0->csr_tx_link_width_lk0 */
	sc_out<sc_bv<3> > csr_tx_link_width_lk0;
	/** Signal from register Interface->Link Freq 0 */
	sc_out<sc_bv<4> >csr_link_frequency0;
	/** Signal from register Interface->LinkControl_1->csr_crc_force_error_lk1 */
	sc_out<bool> csr_crc_force_error_lk1;
	/** Signal from register Interface->LinkControl_1->csr_end_of_chain1 */
	sc_out<bool> csr_end_of_chain1;
	/** Signal from register Interface->LinkControl_1->csr_transmitter_off_lk1 */
	sc_out<bool> csr_transmitter_off_lk1;
	/** Signal from register Interface->LinkControl_1->csr_ldtstop_tristate_enable_lk1 */
	sc_out<bool> csr_ldtstop_tristate_enable_lk1;
	/** Signal from register Interface->LinkControl_1->csr_extented_ctl_lk1 */
	sc_out<bool> csr_extented_ctl_lk1;
	/** Signal from register Interface->LinkConfiguration_1->csr_rx_link_width_lk1 */
	sc_out<sc_bv<3> > csr_rx_link_width_lk1;
	/** Signal from register Interface->LinkConfiguration_1->csr_tx_link_width_lk1 */
	sc_out<sc_bv<3> > csr_tx_link_width_lk1;
	/** Signal from register Interface->Link Freq 1 */
	sc_out<sc_bv<4> >csr_link_frequency1;
	/** Signal from register Interface->LinkError_0->csr_extended_ctl_timeout_lk0 */
	sc_out<bool> csr_extended_ctl_timeout_lk0;
#ifdef ENABLE_REORDERING
	/** Signal from register Interface->FeatureCapability->csr_unitid_reorder_disable */
	sc_out<bool> csr_unitid_reorder_disable;
#endif
	/** Signal from register Interface->LinkError_1->csr_extended_ctl_timeout_lk1 */
	sc_out<bool> csr_extended_ctl_timeout_lk1;
#ifdef RETRY_MODE_ENABLED
	/** Signal from register ErrorRetry->Control_0->LinkRetryEnable_0 */
	sc_out<bool> csr_retry0;
	/** Signal from register ErrorRetry->Control_0->csr_force_single_error_fc0 */
	sc_out<bool> csr_force_single_error_fc0;
	/** Signal from register ErrorRetry->Control_0->csr_force_single_stomp_fc0 */
	sc_out<bool> csr_force_single_stomp_fc0;
	/** Signal from register ErrorRetry->Control_1->LinkRetryEnable_1 */
	sc_out<bool> csr_retry1;
	/** Signal from register ErrorRetry->Control_1->csr_force_single_error_fc1 */
	sc_out<bool> csr_force_single_error_fc1;
	/** Signal from register ErrorRetry->Control_1->csr_force_single_stomp_fc1 */
	sc_out<bool> csr_force_single_stomp_fc1;
#endif
#ifdef ENABLE_DIRECTROUTE
	/** Signal from register DirectRoute->csr_direct_route_enable */
	sc_out<sc_bv<32> > csr_direct_route_enable;
	/** Signals table containing all csr_direct_route_oppposite_dir from Direct Route spaces implemented */
	sc_out<bool> csr_direct_route_oppposite_dir[DirectRoute_NumberDirectRouteSpaces];
	/** Signals table containing all Base Addresses from Direct Route spaces implemented 
		These are the bits 39:8*/
	sc_out<sc_bv<32> > csr_direct_route_base[DirectRoute_NumberDirectRouteSpaces];
	/** Signals table containing all Limit Addresses from Direct Route spaces implemented
		These are the bits 39:8*/
	sc_out<sc_bv<32> > csr_direct_route_limit[DirectRoute_NumberDirectRouteSpaces];
#endif
	/** Signal from register Clumping->csr_clumping_configuration */
	sc_out<sc_bv<32> > csr_clumping_configuration;

	/** If the link has finished it's initialization (is connected)*/
	sc_out<bool> csr_initcomplete0;
	/** If the link has finished it's initialization (is connected)*/
	sc_out<bool> csr_initcomplete1;


	//*******************************************
	// Internal signals
	//*******************************************

	///The consolidated signal containing the output of all the registers for
	///easy read operation
	sc_signal<sc_bv<8> >	config_registers[CSR_SIZE];

	///Actual register of the output
	sc_signal<sc_bv<32> > output_packet_buf;

	/////////////////////////////////////////////
	// The CSR registers
	/////////////////////////////////////////////
	sc_signal<sc_bv<8> > command_lsb;
	sc_signal<sc_bv<8> > command_msb;
	sc_signal<sc_bv<8> > status_msb;
	sc_signal<sc_bv<32> > bar_slots[6];
	sc_signal<sc_bv<8> > interrupt_scratchpad;

	sc_signal<sc_bv<8> > interface_command_lsb;
	sc_signal<sc_bv<8> > interface_command_msb;
	sc_signal<sc_bv<8> > link_control_0_lsb;
	sc_signal<bool > link_control_0_lsb_cold4;
	sc_signal<sc_bv<8> > link_control_0_msb;
	sc_signal<bool > link_control_0_msb_cold0;
	sc_signal<sc_bv<8> > link_config_0_msb;
	sc_signal<sc_bv<8> > link_control_1_lsb;
	sc_signal<bool > link_control_1_lsb_cold4;
	sc_signal<sc_bv<8> > link_control_1_msb;
	sc_signal<bool> link_control_1_msb_cold0;
	sc_signal<sc_bv<8> > link_config_1_msb;
	sc_signal<sc_bv<8> > link_freq_and_error0;
	sc_signal<bool> reorder_disable;
	sc_signal<sc_bv<8> > link_freq_and_error1;
	sc_signal<sc_bv<8> > enum_scratchpad_lsb;
	sc_signal<sc_bv<8> > enum_scratchpad_msb;
	sc_signal<bool > protocol_error_flood_en;
	sc_signal<bool > overflow_error_flood_en;
	sc_signal<bool > chain_fail;
	sc_signal<bool > response_error;
	sc_signal<sc_bv<8> > bus_number;

#ifdef ENABLE_DIRECTROUTE
	sc_signal<sc_uint<5> > direct_route_index;
	sc_signal<sc_uint<32> > direct_route_enable;
#endif

	sc_signal<sc_bv<32> > clumping_enable;

	sc_signal<sc_bv<8> > error_retry_control0;
	sc_signal<bool> error_retry_control0_cold0;
	sc_signal<sc_bv<8> > error_retry_control1;
	sc_signal<bool> error_retry_control1_cold0;
	sc_signal<sc_bv<8> > error_retry_status0;
	sc_signal<sc_bv<8> > error_retry_status1;
	sc_signal<sc_uint<16> > error_retry_count0;
	sc_signal<sc_uint<16> > error_retry_count1;


	/////////////////////////////////////////////
	// Misc state registers
	/////////////////////////////////////////////

	
#ifdef ENABLE_DIRECTROUTE
	///Extra registers for DirectRoute
	sc_signal<sc_bv<32> >	direct_route_data[4*DirectRoute_NumberDirectRouteSpaces];
#endif

	///Extra registers for the link width
	sc_signal<sc_bv<3> >	link0WidthIn;
	///Extra registers for the link width
	sc_signal<sc_bv<3> >	link0WidthOut;
	///Extra registers for the link width
	sc_signal<sc_bv<3> >	link1WidthIn;
	///Extra registers for the link width
	sc_signal<sc_bv<3> >	link1WidthOut;

	///Read associated signals - Read is synchronous
	sc_signal<sc_uint<6> >	read_addr;
	///Read associated signals - Read is synchronous
	sc_signal<sc_uint<4> >	counter;
	
	///Write associated signals - Write is synchronous
	sc_signal<sc_uint<6> >	write_addr;
	///Write associated signals - Write is synchronous
	sc_signal<bool>			write;
	///Write associated signals - Write is synchronous
	sc_signal<bool >		write_from_side;
	///Write associated signals - Write is synchronous
	sc_signal<sc_bv<4> >	write_mask;
	///Write associated signals - Write is synchronous
	sc_signal<sc_bv<32> >	write_data;
	///Write associated signals - Write is synchronous
	sc_signal<sc_bv<32> >	write_mask_vector;

	///Side from which the write or read came from
	sc_signal<bool>			read_write_side;

	///If a target done is waiting to be send to the flow control (currently outputed)
	sc_signal<bool>			tgtdone_waiting_to_be_sent;
	///Passpw for the next response
	//sc_signal<bool>			targetdone_passpw;
	///RqUID for the next response
	//sc_signal<sc_bv<2> >	targetdone_RqUID;
	///Passpw for the next response
	//sc_signal<sc_bv<5> >	targetdone_srctag;
	///The side to send the target done, if one has to be send
	sc_signal<bool >		targetdone_send_side;

	
	/** @name Next value of resposne informatino
		A write request can be treated even though a target
		done from the last request has not been sent yet.  So
		the value of the previous targetdone cannot simply
		be overwritten, so we store the "next value" of the
		response information
	*/
	//@{
	///The next side to send a response
	sc_signal<bool>			next_response_side;
	///The value of passpw for the next response
	sc_signal<bool>			next_response_passpw;
	///The value of rqUID for the next response
	sc_signal<sc_bv<2> >	next_response_RqUID;
	///The value of srcTag for the next response
	sc_signal<sc_bv<5> >	next_response_srctag;
	///If the next response should have Target Error on
	sc_signal<bool>			next_response_target_abort;
	///If a request is posted : no response
	sc_signal<bool>			next_posted;
	//@}

	///The current state of the state machine
	sc_signal<csr_states>	state;
	
	///Register that finds if sync sequence has started
	/** Does not need to be a register, but is simpler to code*/
	sc_signal<bool> sync_initiated;

#ifdef SYSTEMC_SIM
	
	sc_event registers_modified_event;
	
#endif
	
	
	//*******************************************
	//  Contructor and destructor of CSR module
	//*******************************************

	SC_HAS_PROCESS(csr_l2);

	/**
		Updates all the internal registers of the CSR that have a warm
		reset, excluding the state machine registers.  It also defines
		some hardwired bits.

		This simply calls others functions.
			
		It is setup as a synchronous process with WARM reset (reset
		on resetx signal)
	*/
	void update_registers_warm();
	
	/**
		Updates all the internal registers of the CSR that have a cold
		reset, excluding the state machine registers.  It also defines
		some hardwired bits.

		This simply calls others functions.
			
		It is setup as a synchronous process with COLD reset (reset
		on coldrstx signal)
	*/
	void update_registers_cold();

	/**
		Process for the CSR state machine
	*/
	void csr_state_machine();
	
	/**
		Updates all the registers of the device header
		register block for registers that have warm reset
	*/
	void manage_device_header_registers_warm();

	/**
		Updates all the registers of the device header
		register block for registers that have cold reset
	*/
	void manage_device_header_registers_cold();
	
	/**
		Updates all the registers of the interface
		register block that have warm reset
	*/
	void manage_interface_registers_warm();

	/**
		Updates all the registers of the interface
		register block that have cold reset
	*/
	void manage_interface_registers_cold();
	
#ifdef ENABLE_DIRECTROUTE
	/**
		Updates all the registers of the direct route
		register block that have warm reset
	*/
	void manage_direct_route_registers_warm();
	
	/**
		Updates all the registers of the direct route
		register block that have cold reset
	*/
	void manage_direct_route_registers_cold();
#endif

	/**
		Updates all the registers of the ID clumpimp
		register block.  It only has cold reset
		registers.
	*/
	void manage_unit_id_clumping_registers_cold();
	
#ifdef RETRY_MODE_ENABLED
	/**
		Updates all the registers of the error retry
		register block that have warm reset
	*/
	void manage_error_retry_registers_warm();

	/**
		Updates all the registers of the error retry
		register block that have cold reset
	*/
	void manage_error_retry_registers_cold();
#endif
	
	/**
		Checks if a sync flood has been initiated
		@return true if a sync flood has been initiated
	*/
	void isSyncInitiated();
	
	/**
		Process that takes care of outputing the content of the internal
		registers to the correct outputs
	*/	
	void output_register_values();

	/// Drives external register interface signals
	void output_external_register_signals();

	void build_output_values();
	void build_device_header_output();
	void build_interface_output();
#ifdef ENABLE_DIRECTROUTE
	void build_direct_route_output();
#endif
	void build_revision_id_output();
	void build_unit_id_clumping_output();
#ifdef RETRY_MODE_ENABLED
	void build_error_retry_registers_output();
#endif

	void isSyncInitiated_reset();
	void manage_device_header_registers_warm_reset();
	void manage_interface_registers_warm_reset();
#ifdef ENABLE_DIRECTROUTE
	void manage_direct_route_registers_warm_reset();
#endif
#ifdef RETRY_MODE_ENABLED
	void manage_error_retry_registers_warm_reset();
#endif

	void manage_device_header_registers_cold_reset();
	void manage_interface_registers_cold_reset();
	void manage_direct_route_registers_cold_reset();
	void manage_unit_id_clumping_registers_cold_reset();
#ifdef RETRY_MODE_ENABLED
	void manage_error_retry_registers_cold_reset();
#endif


	/// Contructor of CSR with sensitivity lists
	/**
		Open the output file, define sensitivity list for each process
	*/
	csr_l2(sc_module_name name);


#ifdef SYSTEMC_SIM

	/// Destructor of CSR
	/** Close output file */
	virtual ~csr_l2() {};

#endif



};


#endif

