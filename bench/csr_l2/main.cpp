//main.cpp - CSR testbench
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

#include "../../rtl/systemc/core_synth/synth_datatypes.h"
#include "../../rtl/systemc/core_synth/constants.h"

#include "../../rtl/systemc/csr_l2/csr_l2.h"
#include "csr_l2_tb.h"

#include <iostream>
#include <string>
#include <sstream>
#include <iomanip>

using namespace std;

int sc_main( int argc, char* argv[] ){
	//The Design Under Test
	csr_l2* dut = new csr_l2("csr_l2");
	//The TestBench
	csr_l2_tb* tb = new csr_l2_tb("csr_l2_tb");


	//Signals used to link the design to the testbench
	sc_clock clk("clk", 1);  // system clk

	/** Warm Reset signal (active low) */
	sc_signal<bool> resetx;
	sc_signal<bool> pwrok;
	sc_signal<bool> ldtstopx;

	///If the tunnel is in sync mode
	/**
		When a critical error is detected, sync flood is sent.  When
		a sync flood is received, we also fall in sync mode.  This
		cascades and resyncs the complete HT chain.
	*/
	sc_signal<bool>		csr_sync;

	//****************************************************
	//  Signals for communication with User Interface module
	//****************************************************

	sc_signal<bool> csr_request_databuffer0_access_ui;
	sc_signal<bool> csr_request_databuffer1_access_ui;
	sc_signal<bool> ui_databuffer_access_granted_csr;


	//****************************************************
	//  Signals for communication with Reordering module
	//****************************************************

	/** @name Reordering
	*  Signals for communication with Reordering module
	*/
	//@{
	/** Packet is ready to read from Reordering module */
	sc_signal<bool> ro0_available_csr;
	/** Packet from Reordering module */
	sc_signal<syn_ControlPacketComplete > ro0_packet_csr;
	/** Packet from Reordering has been read by CSR */
	sc_signal<bool> csr_ack_ro0;

	/** Packet is ready to read from Reordering module */
	sc_signal<bool> ro1_available_csr;
	/** Packet from Reordering module */
	sc_signal<syn_ControlPacketComplete > ro1_packet_csr;
	/** Packet from Reordering has been read by CSR */
	sc_signal<bool> csr_ack_ro1;

	//@}


	//*****************************************************
	//  Signals for communication with Data Buffer module
	//*****************************************************

	/** @name DataBuffer
	*  Signals for communication with Data Buffer module
	*/
	//@{

	/** Consume data from Data Buffer */
	sc_signal<bool> csr_read_db0;
	sc_signal<bool> csr_read_db1;

	/** Address of the data packet requested in Data Buffer */
	sc_signal<sc_uint<BUFFERS_ADDRESS_WIDTH> > csr_address_db0;
	sc_signal<sc_uint<BUFFERS_ADDRESS_WIDTH> > csr_address_db1;

	/** Virtual Channel of the data requested in Data Buffer */
	sc_signal<VirtualChannel > csr_vctype_db0;
	sc_signal<VirtualChannel > csr_vctype_db1;

	/** 32 bit data sent from Data Buffer to CSR */
	sc_signal<sc_bv<32> > db0_data_csr;
	sc_signal<sc_bv<32> > db1_data_csr;

	/** Last dword of data from Data Buffer */
	sc_signal<bool> csr_erase_db0;
	sc_signal<bool> csr_erase_db1;
	//@}
	

	//******************************************************
	//  Signals for communication with Flow Control module
	//******************************************************

	/** @name FlowControl
	*  Signals for communication with Flow Control module
	*/
	//@{

	/** Request to Flow Control to send packet */
	sc_signal<bool> csr_available_fc0;
	/** 32 bit packet or data to Flow Control */
	sc_signal<sc_bv<32> > csr_dword_fc0;
	/** Flow Control has read the last 32 bit packet or data */
	sc_signal<bool> fc0_ack_csr;


	/** Request to Flow Control to send packet */
	sc_signal<bool> csr_available_fc1;
	/** 32 bit packet or data to Flow Control */
	sc_signal<sc_bv<32> > csr_dword_fc1;
	/** Flow Control has read the last 32 bit packet or data */
	sc_signal<bool> fc1_ack_csr;

	//@}



	//************************************************************
	//  Normal input signals from other modules to CSR registers
	//************************************************************

	/* 
	*  Input signals received from other modules to CSR
	*/
	
	///Signals that come from analyzed packet going through the UI	
	//@{
	sc_signal<bool> ui_sendingPostedDataError_csr;
	sc_signal<bool> ui_sendingTargetAbort_csr;
	sc_signal<bool> ui_receivedResponseDataError_csr;
	sc_signal<bool> ui_receivedPostedDataError_csr;
	sc_signal<bool> ui_receivedTargetAbort_csr;
	sc_signal<bool> ui_receivedMasterAbort_csr;
	//@}

	///When the user received a response with an error
	sc_signal<bool> usr_receivedResponseError_csr;

	///Overflow of the buffers of the databuffer0
	sc_signal<bool> db0_overflow_csr;
	///Overflow of the buffers of the reordering0
	sc_signal<bool> ro0_overflow_csr;
	///Overflow of the buffers of the databuffer1
	sc_signal<bool> db1_overflow_csr;
	///Overflow of the buffers of the reordering1
	sc_signal<bool> ro1_overflow_csr;

	///If the Error Handler consumes data, it means that there is an end of chain error
	//@{
	sc_signal<bool> eh0_ack_ro0;
	sc_signal<bool> eh1_ack_ro1;
	//@}

	/// Link0 has completed it's initialization
	sc_signal<bool> lk0_initialization_complete_csr;	
#ifdef RETRY_MODE_ENABLED
	///Link0 asks to initiate a retry disconnect (probably due to a protocol error)
	sc_signal<bool> lk0_initiate_retry_disconnect;
#endif
	/// Link0 has completed it's initialization
	sc_signal<bool > lk0_crc_error_csr;
	/// Link0 detected a sync packet
	//sc_signal<bool>	lk0_sync_detected_csr;
	/// Link0 detected a protocol error
	sc_signal<bool>	lk0_protocol_error_csr;


	/// Link1 has completed it's initialization
	sc_signal<bool> lk1_initialization_complete_csr;
#ifdef RETRY_MODE_ENABLED
	///Link1 asks to initiate a retry disconnect (probably due to a protocol error)
	sc_signal<bool> lk1_initiate_retry_disconnect;
#endif
	/// Link1 has completed it's initialization
	sc_signal<bool > lk1_crc_error_csr;
	/// Link1 detected a sync packet
	//sc_signal<bool>	lk1_sync_detected_csr;
	/// Link1 detected a protocol error
	sc_signal<bool>	lk1_protocol_error_csr;

	/** Signal to register Interface->LinkError_0->ProtocolError_0 */
	sc_signal<bool> cd0_protocol_error_csr;

	///When the command decoder0 detects a sync
	sc_signal<bool> cd0_sync_detected_csr;
	/** Signal to register Interface->LinkError_1->ProtocolError_1 */
	sc_signal<bool> cd1_protocol_error_csr;
#ifdef RETRY_MODE_ENABLED
	/** Signal to register ErrorRetry->Status_0->RetrySent_0 */
	sc_signal<bool> cd0_initiate_retry_disconnect;
	/** Signal to register ErrorRetry->Status_0->StompReceived_0 */
	sc_signal<bool> cd0_received_stomped_csr;
	/** Signal to register ErrorRetry->Status_1->RetrySent_1 */
	sc_signal<bool> cd1_initiate_retry_disconnect;
	/** Signal to register ErrorRetry->Status_1->StompReceived_1 */
	sc_signal<bool> cd1_received_stomped_csr;
#endif

	///When the command decode1r detects a sync
	sc_signal<bool> cd1_sync_detected_csr;



	///Update the registers with the value of "link failure" from the link
	sc_signal<bool>			lk0_update_link_failure_property_csr;
	///Update the registers with the value of "link width" from the link
	sc_signal<bool>			lk0_update_link_width_csr;
	///Detected link width (only valid when lk0_update_link_width_csr)
	sc_signal<sc_bv<3> >	lk0_sampled_link_width_csr;
	///Detected link failure (only valid when lk0_update_link_failure_property_csr)
	sc_signal<bool>			lk0_link_failure_csr;

	///Clear the bit that forces a single CRC error to be sent
	sc_signal<bool>			fc0_clear_single_error_csr;
	///Clear the bit that forces a single CRC stomp to be sent
	sc_signal<bool>			fc0_clear_single_stomp_csr;


	///Update the registers with the value of "link failure" from the link
	sc_signal<bool>			lk1_update_link_failure_property_csr;
	///Update the registers with the value of "link width" from the link
	sc_signal<bool>			lk1_update_link_width_csr;
	///Detected link width (only valid when lk1_update_link_width_csr)
	sc_signal<sc_bv<3> >	lk1_sampled_link_width_csr;
	///Detected link failure (only valid when lk1_update_link_failure_property_csr)
	sc_signal<bool>			lk1_link_failure_csr;

	///Clear the bit that forces a single CRC error to be sent
	sc_signal<bool>			fc1_clear_single_error_csr;
	///Clear the bit that forces a single CRC stomp to be sent
	sc_signal<bool>			fc1_clear_single_stomp_csr;
	

	//***********************************************
	//  Outputs from CSR registers to other modules
	//***********************************************

	/** Signal from register DeviceHeader->Command->csr_io_space_enable */
	sc_signal<bool> csr_io_space_enable;
	/** Signal from register DeviceHeader->Command->csr_memory_space_enable */
	sc_signal<bool> csr_memory_space_enable;
	/** Signal from register DeviceHeader->Command->csr_bus_master_enable */
	sc_signal<bool> csr_bus_master_enable;
	/** Signal from register Interface->Command->Master host */
	sc_signal<bool> csr_master_host;
	/** Signals table containing all 40 bits Base Addresses from BARs implemented */
	sc_signal<sc_bv<40> > csr_bar[NbRegsBars];
	/** Signal from register Interface->Command->csr_unit_id */
	sc_signal<sc_bv<5> > csr_unit_id;
	/** Signal from register Interface->Command->csr_default_dir */
	sc_signal<bool> csr_default_dir;
	/** Signal from register Interface->Command->csr_drop_uninit_link */
	sc_signal<bool> csr_drop_uninit_link;
	/** Signal from register Interface->LinkControl_0->csr_crc_force_error_lk0 */
	sc_signal<bool> csr_crc_force_error_lk0;
	/** Signal from register Interface->LinkControl_0->csr_end_of_chain0 */
	sc_signal<bool> csr_end_of_chain0;
	/** Signal from register Interface->LinkControl_0->csr_transmitter_off_lk0 */
	sc_signal<bool> csr_transmitter_off_lk0;
	/** Signal from register Interface->LinkControl_0->csr_ldtstop_tristate_enable_lk0 */
	sc_signal<bool> csr_ldtstop_tristate_enable_lk0;
	/** Signal from register Interface->LinkControl_0->csr_extented_ctl_lk0 */
	sc_signal<bool> csr_extented_ctl_lk0;
	/** Signal from register Interface->LinkConfiguration_0->csr_rx_link_width_lk0 */
	sc_signal<sc_bv<3> > csr_rx_link_width_lk0;
	/** Signal from register Interface->LinkConfiguration_0->csr_tx_link_width_lk0 */
	sc_signal<sc_bv<3> > csr_tx_link_width_lk0;
	/** Signal from register Interface->Link Freq 0 */
	sc_signal<sc_bv<4> >csr_link_frequency0;
	/** Signal from register Interface->LinkControl_1->csr_crc_force_error_lk1 */
	sc_signal<bool> csr_crc_force_error_lk1;
	/** Signal from register Interface->LinkControl_1->csr_end_of_chain1 */
	sc_signal<bool> csr_end_of_chain1;
	/** Signal from register Interface->LinkControl_1->csr_transmitter_off_lk1 */
	sc_signal<bool> csr_transmitter_off_lk1;
	/** Signal from register Interface->LinkControl_1->csr_ldtstop_tristate_enable_lk1 */
	sc_signal<bool> csr_ldtstop_tristate_enable_lk1;
	/** Signal from register Interface->LinkControl_1->csr_extented_ctl_lk1 */
	sc_signal<bool> csr_extented_ctl_lk1;
	/** Signal from register Interface->LinkConfiguration_1->csr_rx_link_width_lk1 */
	sc_signal<sc_bv<3> > csr_rx_link_width_lk1;
	/** Signal from register Interface->LinkConfiguration_1->csr_tx_link_width_lk1 */
	sc_signal<sc_bv<3> > csr_tx_link_width_lk1;
	/** Signal from register Interface->Link Freq 1 */
	sc_signal<sc_bv<4> >csr_link_frequency1;
	/** Signal from register Interface->LinkError_0->csr_extended_ctl_timeout_lk0 */
	sc_signal<bool> csr_extended_ctl_timeout_lk0;
#ifdef ENABLE_REORDERING
	/** Signal from register Interface->FeatureCapability->csr_unitid_reorder_disable */
	sc_signal<bool> csr_unitid_reorder_disable;
#endif
	/** Signal from register Interface->LinkError_1->csr_extended_ctl_timeout_lk1 */
	sc_signal<bool> csr_extended_ctl_timeout_lk1;
#ifdef RETRY_MODE_ENABLED
	/** Signal from register ErrorRetry->Control_0->LinkRetryEnable_0 */
	sc_signal<bool> csr_retry0;
	/** Signal from register ErrorRetry->Control_0->csr_force_single_error_fc0 */
	sc_signal<bool> csr_force_single_error_fc0;
	/** Signal from register ErrorRetry->Control_0->csr_force_single_stomp_fc0 */
	sc_signal<bool> csr_force_single_stomp_fc0;
	/** Signal from register ErrorRetry->Control_1->LinkRetryEnable_1 */
	sc_signal<bool> csr_retry1;
	/** Signal from register ErrorRetry->Control_1->csr_force_single_error_fc1 */
	sc_signal<bool> csr_force_single_error_fc1;
	/** Signal from register ErrorRetry->Control_1->csr_force_single_stomp_fc1 */
	sc_signal<bool> csr_force_single_stomp_fc1;
#endif
	/** Signal from register DirectRoute->csr_direct_route_enable */
	sc_signal<sc_bv<32> > csr_direct_route_enable;
	/** Signal from register DirectRoute->csr_clumping_configuration */
	sc_signal<sc_bv<32> > csr_clumping_configuration;
	/** Signals table containing all csr_direct_route_oppposite_dir from Direct Route spaces implemented */
	sc_signal<bool> csr_direct_route_oppposite_dir[DirectRoute_NumberDirectRouteSpaces];
	/** Signals table containing all Base Addresses from Direct Route spaces implemented 
		These are the bits 39:8*/
	sc_signal<sc_bv<32> > csr_direct_route_base[DirectRoute_NumberDirectRouteSpaces];
	/** Signals table containing all Limit Addresses from Direct Route spaces implemented
		These are the bits 39:8*/
	sc_signal<sc_bv<32> > csr_direct_route_limit[DirectRoute_NumberDirectRouteSpaces];

	/** If the link has finished it's initialization (is connected)*/
	sc_signal<bool> csr_initcomplete0;
	/** If the link has finished it's initialization (is connected)*/
	sc_signal<bool> csr_initcomplete1;


	sc_signal<sc_uint<6> >	csr_read_addr_usr;
	sc_signal<sc_bv<32> >	usr_read_data_csr;
	sc_signal<bool >	csr_write_usr;
	sc_signal<sc_uint<6> >	csr_write_addr_usr;
	sc_signal<sc_bv<32> >	csr_write_data_usr;
	sc_signal<sc_bv<4> >	csr_write_mask_usr;

	////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////
	//  CSR DUT connections
	////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////

	//Signals used to link the design to the testbench
	dut->clk(clk);

	dut->resetx(resetx);
	dut->pwrok(pwrok);
	dut->ldtstopx(ldtstopx);
	dut->csr_sync(csr_sync);
	dut->csr_request_databuffer0_access_ui(csr_request_databuffer0_access_ui);
	dut->csr_request_databuffer1_access_ui(csr_request_databuffer1_access_ui);
	dut->ui_databuffer_access_granted_csr(ui_databuffer_access_granted_csr);

	dut->ro0_available_csr(ro0_available_csr);
	dut->ro0_packet_csr(ro0_packet_csr);
	dut->csr_ack_ro0(csr_ack_ro0);

	dut->ro1_available_csr(ro1_available_csr);
	dut->ro1_packet_csr(ro1_packet_csr);
	dut->csr_ack_ro1(csr_ack_ro1);

	dut->csr_read_db0(csr_read_db0);
	dut->csr_read_db1(csr_read_db1);

	dut->csr_address_db0(csr_address_db0);
	dut->csr_address_db1(csr_address_db1);

	dut->csr_vctype_db0(csr_vctype_db0);
	dut->csr_vctype_db1(csr_vctype_db1);

	dut->db0_data_csr(db0_data_csr);
	dut->db1_data_csr(db1_data_csr);
	dut->csr_erase_db0(csr_erase_db0);
	dut->csr_erase_db1(csr_erase_db1);
	dut->csr_available_fc0(csr_available_fc0);
	dut->csr_dword_fc0(csr_dword_fc0);
	dut->fc0_ack_csr(fc0_ack_csr);


	dut->csr_available_fc1(csr_available_fc1);
	dut->csr_dword_fc1(csr_dword_fc1);
	dut->fc1_ack_csr(fc1_ack_csr);

	dut->ui_sendingPostedDataError_csr(ui_sendingPostedDataError_csr);
	dut->ui_sendingTargetAbort_csr(ui_sendingTargetAbort_csr);
	dut->ui_receivedResponseDataError_csr(ui_receivedResponseDataError_csr);
	dut->ui_receivedPostedDataError_csr(ui_receivedPostedDataError_csr);
	dut->ui_receivedTargetAbort_csr(ui_receivedTargetAbort_csr);
	dut->ui_receivedMasterAbort_csr(ui_receivedMasterAbort_csr);

	dut->usr_receivedResponseError_csr(usr_receivedResponseError_csr);

	dut->db0_overflow_csr(db0_overflow_csr);
	dut->ro0_overflow_csr(ro0_overflow_csr);
	dut->db1_overflow_csr(db1_overflow_csr);
	dut->ro1_overflow_csr(ro1_overflow_csr);
	dut->eh0_ack_ro0(eh0_ack_ro0);
	dut->eh1_ack_ro1(eh1_ack_ro1);

	dut->lk0_initialization_complete_csr(lk0_initialization_complete_csr);
#ifdef RETRY_MODE_ENABLED
	dut->lk0_initiate_retry_disconnect(lk0_initiate_retry_disconnect);
#endif
	dut->lk0_crc_error_csr(lk0_crc_error_csr);
	dut->lk0_protocol_error_csr(lk0_protocol_error_csr);
	dut->lk1_initialization_complete_csr(lk1_initialization_complete_csr);
#ifdef RETRY_MODE_ENABLED
	dut->lk1_initiate_retry_disconnect(lk1_initiate_retry_disconnect);
#endif
	dut->lk1_crc_error_csr(lk1_crc_error_csr);
	dut->lk1_protocol_error_csr(lk1_protocol_error_csr);
	dut->cd0_protocol_error_csr(cd0_protocol_error_csr);
	dut->cd0_sync_detected_csr(cd0_sync_detected_csr);
	dut->cd1_protocol_error_csr(cd1_protocol_error_csr);
#ifdef RETRY_MODE_ENABLED
	dut->cd0_initiate_retry_disconnect(cd0_initiate_retry_disconnect);
	dut->cd0_received_stomped_csr(cd0_received_stomped_csr);
	dut->cd1_initiate_retry_disconnect(cd1_initiate_retry_disconnect);
	dut->cd1_received_stomped_csr(cd1_received_stomped_csr);
#endif

	dut->cd1_sync_detected_csr(cd1_sync_detected_csr);
	dut->lk0_update_link_failure_property_csr(lk0_update_link_failure_property_csr);
	dut->lk0_update_link_width_csr(lk0_update_link_width_csr);
	dut->lk0_sampled_link_width_csr(lk0_sampled_link_width_csr);
	dut->lk0_link_failure_csr(lk0_link_failure_csr);

	dut->fc0_clear_single_error_csr(fc0_clear_single_error_csr);
	dut->fc0_clear_single_stomp_csr(fc0_clear_single_stomp_csr);


	dut->lk1_update_link_failure_property_csr(lk1_update_link_failure_property_csr);
	dut->lk1_update_link_width_csr(lk1_update_link_width_csr);
	dut->lk1_sampled_link_width_csr(lk1_sampled_link_width_csr);
	dut->lk1_link_failure_csr(lk1_link_failure_csr);
	dut->fc1_clear_single_error_csr(fc1_clear_single_error_csr);
	dut->fc1_clear_single_stomp_csr(fc1_clear_single_stomp_csr);
	dut->csr_io_space_enable(csr_io_space_enable);
	dut->csr_memory_space_enable(csr_memory_space_enable);
	dut->csr_bus_master_enable(csr_bus_master_enable);
	dut->csr_master_host(csr_master_host);
	for(int n = 0; n < NbRegsBars; n++)
		dut->csr_bar[n](csr_bar[n]);
	dut->csr_unit_id(csr_unit_id);
	dut->csr_default_dir(csr_default_dir);
	dut->csr_drop_uninit_link(csr_drop_uninit_link);
	dut->csr_crc_force_error_lk0(csr_crc_force_error_lk0);
	dut->csr_end_of_chain0(csr_end_of_chain0);
	dut->csr_transmitter_off_lk0(csr_transmitter_off_lk0);
	dut->csr_ldtstop_tristate_enable_lk0(csr_ldtstop_tristate_enable_lk0);
	dut->csr_extented_ctl_lk0(csr_extented_ctl_lk0);
	dut->csr_rx_link_width_lk0(csr_rx_link_width_lk0);
	dut->csr_tx_link_width_lk0(csr_tx_link_width_lk0);
	dut->csr_link_frequency0(csr_link_frequency0);
	dut->csr_crc_force_error_lk1(csr_crc_force_error_lk1);
	dut->csr_end_of_chain1(csr_end_of_chain1);
	dut->csr_transmitter_off_lk1(csr_transmitter_off_lk1);
	dut->csr_ldtstop_tristate_enable_lk1(csr_ldtstop_tristate_enable_lk1);
	dut->csr_extented_ctl_lk1(csr_extented_ctl_lk1);
	dut->csr_rx_link_width_lk1(csr_rx_link_width_lk1);
	dut->csr_tx_link_width_lk1(csr_tx_link_width_lk1);
	dut->csr_link_frequency1(csr_link_frequency1);
	dut->csr_extended_ctl_timeout_lk0(csr_extended_ctl_timeout_lk0);
#ifdef ENABLE_REORDERING
	dut->csr_unitid_reorder_disable(csr_unitid_reorder_disable);
#endif
	dut->csr_extended_ctl_timeout_lk1(csr_extended_ctl_timeout_lk1);
#ifdef RETRY_MODE_ENABLED
	dut->csr_retry0(csr_retry0);
	dut->csr_force_single_error_fc0(csr_force_single_error_fc0);
	dut->csr_force_single_stomp_fc0(csr_force_single_stomp_fc0);
	dut->csr_retry1(csr_retry1);
	dut->csr_force_single_error_fc1(csr_force_single_error_fc1);
	dut->csr_force_single_stomp_fc1(csr_force_single_stomp_fc1);
#endif
	dut->csr_direct_route_enable(csr_direct_route_enable);
	dut->csr_clumping_configuration(csr_clumping_configuration);
	for(int n = 0; n < DirectRoute_NumberDirectRouteSpaces; n++){
		dut->csr_direct_route_oppposite_dir[n](csr_direct_route_oppposite_dir[n]);
		dut->csr_direct_route_base[n](csr_direct_route_base[n]);
		dut->csr_direct_route_limit[n](csr_direct_route_limit[n]);
	}
	dut->csr_initcomplete0(csr_initcomplete0);
	dut->csr_initcomplete1(csr_initcomplete1);

	dut->csr_read_addr_usr(csr_read_addr_usr);
	dut->usr_read_data_csr(usr_read_data_csr);
	dut->csr_write_usr(csr_write_usr);
	dut->csr_write_addr_usr(csr_write_addr_usr);
	dut->csr_write_data_usr(csr_write_data_usr);
	dut->csr_write_mask_usr(csr_write_mask_usr);

	////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////
	//  CSR TB connections
	////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////

	tb->clk(clk);
	tb->resetx(resetx);
	tb->pwrok(pwrok);
	tb->ldtstopx(ldtstopx);
	tb->csr_sync(csr_sync);
	tb->csr_request_databuffer0_access_ui(csr_request_databuffer0_access_ui);
	tb->csr_request_databuffer1_access_ui(csr_request_databuffer1_access_ui);
	tb->ui_databuffer_access_granted_csr(ui_databuffer_access_granted_csr);

	tb->ro0_available_csr(ro0_available_csr);
	tb->ro0_packet_csr(ro0_packet_csr);
	tb->csr_ack_ro0(csr_ack_ro0);

	tb->ro1_available_csr(ro1_available_csr);
	tb->ro1_packet_csr(ro1_packet_csr);
	tb->csr_ack_ro1(csr_ack_ro1);

	tb->csr_read_db0(csr_read_db0);
	tb->csr_read_db1(csr_read_db1);

	tb->csr_address_db0(csr_address_db0);
	tb->csr_address_db1(csr_address_db1);

	tb->csr_vctype_db0(csr_vctype_db0);
	tb->csr_vctype_db1(csr_vctype_db1);

	tb->db0_data_csr(db0_data_csr);
	tb->db1_data_csr(db1_data_csr);
	tb->csr_erase_db0(csr_erase_db0);
	tb->csr_erase_db1(csr_erase_db1);
	tb->csr_available_fc0(csr_available_fc0);
	tb->csr_dword_fc0(csr_dword_fc0);
	tb->fc0_ack_csr(fc0_ack_csr);


	tb->csr_available_fc1(csr_available_fc1);
	tb->csr_dword_fc1(csr_dword_fc1);
	tb->fc1_ack_csr(fc1_ack_csr);

	////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////
	//  Trace signals
	////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////

	sc_trace_file *tf = sc_create_vcd_trace_file("sim_csr_l2");

	sc_trace(tf,clk,"clk");
	sc_trace(tf,resetx,"resetx");
	sc_trace(tf,pwrok,"pwrok");
	sc_trace(tf,ldtstopx,"ldtstopx");
	sc_trace(tf,csr_sync,"csr_sync");
	sc_trace(tf,csr_request_databuffer0_access_ui,"csr_request_databuffer0_access_ui");
	sc_trace(tf,csr_request_databuffer1_access_ui,"csr_request_databuffer1_access_ui");
	sc_trace(tf,ui_databuffer_access_granted_csr,"ui_databuffer_access_granted_csr");

	sc_trace(tf,ro0_available_csr,"ro0_available_csr");
	sc_trace(tf,ro0_packet_csr,"ro0_packet_csr");
	sc_trace(tf,csr_ack_ro0,"csr_ack_ro0");

	sc_trace(tf,ro1_available_csr,"ro1_available_csr");
	sc_trace(tf,ro1_packet_csr,"ro1_packet_csr");
	sc_trace(tf,csr_ack_ro1,"csr_ack_ro1");

	sc_trace(tf,csr_read_db0,"csr_read_db0");
	sc_trace(tf,csr_read_db1,"csr_read_db1");

	sc_trace(tf,csr_address_db0,"csr_address_db0");
	sc_trace(tf,csr_address_db1,"csr_address_db1");

	sc_trace(tf,csr_vctype_db0,"csr_vctype_db0");
	sc_trace(tf,csr_vctype_db1,"csr_vctype_db1");

	sc_trace(tf,db0_data_csr,"db0_data_csr");
	sc_trace(tf,db1_data_csr,"db1_data_csr");
	sc_trace(tf,csr_erase_db0,"csr_erase_db0");
	sc_trace(tf,csr_erase_db1,"csr_erase_db1");
	sc_trace(tf,csr_available_fc0,"csr_available_fc0");
	sc_trace(tf,csr_dword_fc0,"csr_dword_fc0");
	sc_trace(tf,fc0_ack_csr,"fc0_ack_csr");


	sc_trace(tf,csr_available_fc1,"csr_available_fc1");
	sc_trace(tf,csr_dword_fc1,"csr_dword_fc1");

	sc_trace(tf,dut->config_registers[19],"bar0(31..24)");
	sc_trace(tf,dut->config_registers[18],"bar0(23..16)");
	sc_trace(tf,dut->config_registers[17],"bar0(15..8)");
	sc_trace(tf,dut->config_registers[16],"bar0(7..0)");

	sc_trace(tf,dut->config_registers[23],"bar1(31..24)");
	sc_trace(tf,dut->config_registers[22],"bar1(23..16)");
	sc_trace(tf,dut->config_registers[21],"bar1(15..8)");
	sc_trace(tf,dut->config_registers[20],"bar1(7..0)");

	sc_trace(tf,dut->config_registers[27],"bar2(31..24)");
	sc_trace(tf,dut->config_registers[26],"bar2(23..16)");
	sc_trace(tf,dut->config_registers[25],"bar2(15..8)");
	sc_trace(tf,dut->config_registers[24],"bar2(7..0)");

	sc_trace(tf,dut->config_registers[31],"bar3(31..24)");
	sc_trace(tf,dut->config_registers[30],"bar3(23..16)");
	sc_trace(tf,dut->config_registers[29],"bar3(15..8)");
	sc_trace(tf,dut->config_registers[28],"bar3(7..0)");

	//------------------------------------------
	// Start simulation
	//------------------------------------------
	cout << "Start of simulation" << endl;
	sc_start(60);


	sc_close_vcd_trace_file(tf);
	cout << "End of simulation" << endl;

	delete dut;
	delete tb;
	return 0;
}

