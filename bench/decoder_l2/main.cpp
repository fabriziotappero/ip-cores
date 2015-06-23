//main.cpp for decoder_l2 testbench
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

#include "decoder_l2_tb.h"
#include "../../rtl/systemc/decoder_l2/decoder_l2.h"
#include "../../rtl/systemc/decoder_l2/cd_counter_l3.h"
#include "../../rtl/systemc/decoder_l2/cd_packet_crc_l3.h"

#include <iostream>
#include <string>
#include <sstream>
#include <iomanip>
#include <time.h>

using namespace std;

int sc_main( int argc, char* argv[] ){

	//The Design Under Test
	decoder_l2* dut = new decoder_l2("decoder_l2");
	//The TestBench
	decoder_l2_tb* tb = new decoder_l2_tb("decoder_l2_tb");


	//Signals used to link the design to the testbench
	sc_clock clk("clk", 1);  // system clk

	///Warm Reset to initialize module
	sc_signal < bool >			resetx;
	
	//*******************************
	//	Signals for Control Buffer
	//*******************************
	
	/**Packet to be transmitted to control buffer module*/
    sc_signal< syn_ControlPacketComplete > 	cd_packet_ro;
	/**Enables control buffer module to read cd_packet_ro port*/
	sc_signal< bool > 						cd_available_ro;
	/**If we're currently receiving data.  This is used by the ro to know
	if we have finished receiving the data of a packet, so it can know if
	it can send it.*/
	sc_signal<bool>						cd_data_pending_ro;
	/**Where we are storing data.   This is used by the ro to know
	if we have finished receiving the data of a packet, so it can know if
	it can send it.*/
	sc_signal<sc_uint<BUFFERS_ADDRESS_WIDTH> >	cd_data_pending_addr_ro;

	//*******************************
	//	Signals for Data Buffer
	//*******************************	

	///ddress of data in data buffer module
	sc_signal< sc_uint<BUFFERS_ADDRESS_WIDTH> >		db_address_cd;
	///Get an address form data buffer module
	sc_signal< bool >				cd_getaddr_db;
	///Size of data packet to be written
	sc_signal< sc_uint<4> >		cd_datalen_db;
	///Virtual channel where data will be written
	sc_signal< VirtualChannel >	cd_vctype_db;
	///Data to be written in data buffer module
	sc_signal< sc_bv<32> > 		cd_data_db;
	///Enables data buffer to read cd_data_db port
	sc_signal< bool > 				cd_write_db;

#ifdef RETRY_MODE_ENABLED
	///Erase signal for packet stomping
	sc_signal< bool >				cd_drop_db;
#endif

	
	//*************************************
	// Signals to CSR
	//*************************************
	
	///A protocol error has been detected
	sc_signal< bool >			cd_protocol_error_csr;
	///A sync packet has been received
	sc_signal< bool >			cd_sync_detected_csr;
#ifdef RETRY_MODE_ENABLED
	///If retry mode is active
	sc_signal< bool >			csr_retry;
#endif
	
	//*******************************
	//	Signals from link
	//*******************************
	
	///Bit vector input from the FIFO 
	sc_signal< sc_bv<32> > 		lk_dword_cd;
	///Control bit
	sc_signal< bool > 			lk_hctl_cd;
	///Control bit
	sc_signal< bool > 			lk_lctl_cd;
	///FIFO is ready to be read from
	sc_signal< bool > 			lk_available_cd;

#ifdef RETRY_MODE_ENABLED
	///If a retry sequence is initiated by link
	sc_signal< bool > 			lk_initiate_retry_disconnect;
#endif
	//*******************************
	//	Signals for Forwarding module
	//*******************************

#ifdef RETRY_MODE_ENABLED
	///History count
	sc_signal< sc_uint<8> > 		cd_rx_next_pkt_to_ack_fc;
	///rxPacketToAck (retry mode)
	sc_signal< sc_uint<8> > 	cd_nop_ack_value_fc;
#endif

	///Info registered from NOP word
	sc_signal< sc_bv<12> > 	cd_nopinfo_fc;
	///Signal that new nop info are available
	sc_signal< bool >			cd_nop_received_fc;

#ifdef RETRY_MODE_ENABLED
	///Start the sequence for a retry disconnect
	sc_signal< bool >			cd_initiate_retry_disconnect;
	///A stomped packet has been received
	sc_signal<bool>			cd_received_stomped_csr;
	///Let the reordering know we received a non flow control stomped packet
	/**  When this situation happens, packet available bit does not become
		 asserted but the correct packet is sent, which can be used to know
		 from which VC to free a flow control credit.
	*/
	sc_signal<bool> cd_received_non_flow_stomped_ro;
#endif
	///The link can start a sequence for a ldtstop disconnect
	sc_signal< bool >			cd_initiate_nonretry_disconnect_lk;

	////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////
	// DUT connections
	////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////

	//Signals used to link the design to the testbench
	dut->clk(clk);
	dut->resetx(resetx);
    dut->cd_packet_ro(cd_packet_ro);
	dut->cd_available_ro(cd_available_ro);
	dut->cd_data_pending_ro(cd_data_pending_ro);
	dut->cd_data_pending_addr_ro(cd_data_pending_addr_ro);

	dut->db_address_cd(db_address_cd);
	dut->cd_getaddr_db(cd_getaddr_db);
	dut->cd_datalen_db(cd_datalen_db);
	dut->cd_vctype_db(cd_vctype_db);
	dut->cd_data_db(cd_data_db);
	dut->cd_write_db(cd_write_db);

#ifdef RETRY_MODE_ENABLED
	dut->cd_drop_db(cd_drop_db);
#endif

	
	dut->cd_protocol_error_csr(cd_protocol_error_csr);
	dut->cd_sync_detected_csr(cd_sync_detected_csr);
#ifdef RETRY_MODE_ENABLED
	dut->csr_retry(csr_retry);
#endif
	
	dut->lk_dword_cd(lk_dword_cd);
	dut->lk_hctl_cd(lk_hctl_cd);
	dut->lk_lctl_cd(lk_lctl_cd);
	dut->lk_available_cd(lk_available_cd);

#ifdef RETRY_MODE_ENABLED
	dut->lk_initiate_retry_disconnect(lk_initiate_retry_disconnect);
#endif

#ifdef RETRY_MODE_ENABLED
	dut->cd_rx_next_pkt_to_ack_fc(cd_rx_next_pkt_to_ack_fc);
	dut->cd_nop_ack_value_fc(cd_nop_ack_value_fc);
#endif

	dut->cd_nopinfo_fc(cd_nopinfo_fc);
	dut->cd_nop_received_fc(cd_nop_received_fc);

#ifdef RETRY_MODE_ENABLED
	dut->cd_initiate_retry_disconnect(cd_initiate_retry_disconnect);
	dut->cd_received_stomped_csr(cd_received_stomped_csr);
	dut->cd_received_non_flow_stomped_ro(cd_received_non_flow_stomped_ro);
#endif
	dut->cd_initiate_nonretry_disconnect_lk(cd_initiate_nonretry_disconnect_lk);


	////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////
	//  TB connections
	////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////

	tb->clk(clk);
	tb->resetx(resetx);
    tb->cd_packet_ro(cd_packet_ro);
	tb->cd_available_ro(cd_available_ro);
	tb->cd_data_pending_ro(cd_data_pending_ro);
	tb->cd_data_pending_addr_ro(cd_data_pending_addr_ro);

	tb->db_address_cd(db_address_cd);
	tb->cd_getaddr_db(cd_getaddr_db);
	tb->cd_datalen_db(cd_datalen_db);
	tb->cd_vctype_db(cd_vctype_db);
	tb->cd_data_db(cd_data_db);
	tb->cd_write_db(cd_write_db);

#ifdef RETRY_MODE_ENABLED
	tb->cd_drop_db(cd_drop_db);
#endif

	
	tb->cd_protocol_error_csr(cd_protocol_error_csr);
	tb->cd_sync_detected_csr(cd_sync_detected_csr);
#ifdef RETRY_MODE_ENABLED
	tb->csr_retry(csr_retry);
#endif
	
	tb->lk_dword_cd(lk_dword_cd);
	tb->lk_hctl_cd(lk_hctl_cd);
	tb->lk_lctl_cd(lk_lctl_cd);
	tb->lk_available_cd(lk_available_cd);

#ifdef RETRY_MODE_ENABLED
	tb->lk_initiate_retry_disconnect(lk_initiate_retry_disconnect);
#endif

#ifdef RETRY_MODE_ENABLED
	tb->cd_rx_next_pkt_to_ack_fc(cd_rx_next_pkt_to_ack_fc);
	tb->cd_nop_ack_value_fc(cd_nop_ack_value_fc);
#endif

	tb->cd_nopinfo_fc(cd_nopinfo_fc);
	tb->cd_nop_received_fc(cd_nop_received_fc);

#ifdef RETRY_MODE_ENABLED
	tb->cd_initiate_retry_disconnect(cd_initiate_retry_disconnect);
	tb->cd_received_stomped_csr(cd_received_stomped_csr);
	tb->cd_received_non_flow_stomped_ro(cd_received_non_flow_stomped_ro);
#endif
	tb->cd_initiate_nonretry_disconnect_lk(cd_initiate_nonretry_disconnect_lk);

	////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////
	//  Trace signals
	////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////

	sc_trace_file *tf = sc_create_vcd_trace_file("sim_decoder_l2");

	sc_trace(tf,clk,"clk");
	sc_trace(tf,resetx,"resetx");
    sc_trace(tf,cd_packet_ro,"cd_packet_ro");
	sc_trace(tf,cd_available_ro,"cd_available_ro");
	sc_trace(tf,cd_data_pending_ro,"cd_data_pending_ro");
	sc_trace(tf,cd_data_pending_addr_ro,"cd_data_pending_addr_ro");

	sc_trace(tf,db_address_cd,"db_address_cd");
	sc_trace(tf,cd_getaddr_db,"cd_getaddr_db");
	sc_trace(tf,cd_datalen_db,"cd_datalen_db");
	sc_trace(tf,cd_vctype_db,"cd_vctype_db");
	sc_trace(tf,cd_data_db,"cd_data_db");
	sc_trace(tf,cd_write_db,"cd_write_db");

#ifdef RETRY_MODE_ENABLED
	sc_trace(tf,cd_drop_db,"cd_drop_db");
#endif

	
	sc_trace(tf,cd_protocol_error_csr,"cd_protocol_error_csr");
	sc_trace(tf,cd_sync_detected_csr,"cd_sync_detected_csr");
#ifdef RETRY_MODE_ENABLED
	sc_trace(tf,csr_retry,"csr_retry");
#endif
	
	sc_trace(tf,lk_dword_cd,"lk_dword_cd");
	sc_trace(tf,lk_hctl_cd,"lk_hctl_cd");
	sc_trace(tf,lk_lctl_cd,"lk_lctl_cd");
	sc_trace(tf,lk_available_cd,"lk_available_cd");

#ifdef RETRY_MODE_ENABLED
	sc_trace(tf,lk_initiate_retry_disconnect,"lk_initiate_retry_disconnect");
#endif

#ifdef RETRY_MODE_ENABLED
	sc_trace(tf,cd_rx_next_pkt_to_ack_fc,"cd_rx_next_pkt_to_ack_fc");
	sc_trace(tf,cd_nop_ack_value_fc,"cd_nop_ack_value_fc");
#endif

	sc_trace(tf,cd_nopinfo_fc,"cd_nopinfo_fc");
	sc_trace(tf,cd_nop_received_fc,"cd_nop_received_fc");

#ifdef RETRY_MODE_ENABLED
	sc_trace(tf,cd_initiate_retry_disconnect,"cd_initiate_retry_disconnect");
	sc_trace(tf,cd_received_stomped_csr,"cd_received_stomped_csr");
#endif
	sc_trace(tf,cd_initiate_nonretry_disconnect_lk,"cd_initiate_nonretry_disconnect_lk");


	sc_trace(tf,dut->CNT->setCnt,"CNT.setCnt");
	sc_trace(tf,dut->CNT->decrCnt,"CNT.decrCnt");
	sc_trace(tf,dut->CNT->data,"CNT.data");
	sc_trace(tf,dut->CNT->end_of_count,"CNT.end_of_count");

	sc_trace(tf,dut->packet_crc_unit->crc1_enable,"CRC.crc1_enable");
	sc_trace(tf,dut->packet_crc_unit->crc2_enable,"CRC.crc2_enable");
	sc_trace(tf,dut->packet_crc_unit->crc1_reset,"CRC.crc1_reset");
	sc_trace(tf,dut->packet_crc_unit->crc2_reset,"CRC.crc2_reset");

	sc_trace(tf,dut->packet_crc_unit->crc1_good,"CRC.crc1_good");
	sc_trace(tf,dut->packet_crc_unit->crc2_good,"CRC.crc2_good");
	sc_trace(tf,dut->packet_crc_unit->crc1_stomped,"CRC.crc1_stomped");
	sc_trace(tf,dut->packet_crc_unit->crc2_stomped,"CRC.crc2_stomped");


	//------------------------------------------
	// Start simulation
	//------------------------------------------
	cout << "Start of Decoder simulation" << endl;
	
	sc_start(200);

	sc_close_vcd_trace_file(tf);
	cout << "End of simulation" << endl;

	delete dut;
	delete tb;
	return 0;
}

