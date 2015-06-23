//csr_l2_tb.h

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

#ifndef CSR_L2_TB_H
#define CSR_L2_TB_H

#include "../../rtl/systemc/core_synth/synth_datatypes.h"
#include "../../rtl/systemc/core_synth/constants.h"
#include "../core/ht_datatypes.h"
#include <deque>

///Testbench for the csr_l2 module
/**
	@class csr_l2_tb
	@author Ami Castonguay
*/
class csr_l2_tb : public sc_module {

	///Structure that groups both packet complete and it's associated data
	struct PacketContainerWithData{
		ControlPacketComplete pkt_cplt;
		int data[16];
	};

	///Expected response to a request to CSR
	struct ExpectedResponse{
		unsigned int dwords[17];///< The dwords of the response, including data
		unsigned int size_with_data;///< Size of the response, including data
	};

public:

	/// Global system clock signal.
	sc_in_clk		 							clk;


	/** Warm Reset signal (active low) */
	sc_out<bool> resetx;
	///Power is stable (used for cold reset of the design
	sc_out<bool> pwrok;
	///LDSTOP sequence (power saving mode)
	sc_out<bool> ldtstopx;


	///If the tunnel is in sync mode
	/**
		When a critical error is detected, sync flood is sent.  When
		a sync flood is received, we also fall in sync mode.  This
		cascades and resyncs the complete HT chain.
	*/
	sc_in<bool>		csr_sync;

	//****************************************************
	//  Signals for communication with User Interface module
	//****************************************************

	/** Access to the databuffer is shared with UI, must request acess*/
	sc_in<bool> csr_request_databuffer0_access_ui;
	/** Access to the databuffer is shared with UI, must request acess*/
	sc_in<bool> csr_request_databuffer1_access_ui;
	/** When the access to databuffer is granted following the assertion of
	::csr_request_databuffer0_access_ui or ::csr_request_databuffer1_access_ui*/
	sc_out<bool> ui_databuffer_access_granted_csr;


	//****************************************************
	//  Signals for communication with Reordering module
	//****************************************************

	/** @name Reordering
	*  Signals for communication with Reordering module
	*/
	//@{
	/** Packet is ready to read from Reordering module */
	sc_out<bool> ro0_available_csr;
	/** Packet from Reordering module */
	sc_out<syn_ControlPacketComplete > ro0_packet_csr;
	/** Packet from Reordering has been read by CSR */
	sc_in<bool> csr_ack_ro0;

	/** Packet is ready to read from Reordering module */
	sc_out<bool> ro1_available_csr;
	/** Packet from Reordering module */
	sc_out<syn_ControlPacketComplete > ro1_packet_csr;
	/** Packet from Reordering has been read by CSR */
	sc_in<bool> csr_ack_ro1;

	//@}


	//*****************************************************
	//  Signals for communication with Data Buffer module
	//*****************************************************

	/** @name DataBuffer
	*  Signals for communication with Data Buffer module
	*/
	//@{

	/** Consume data from Data Buffer */
	sc_in<bool> csr_read_db0;
	/** Consume data from Data Buffer 1 */
	sc_in<bool> csr_read_db1;

	/** Address of the data packet requested in Data Buffer 0 */
	sc_in<sc_uint<BUFFERS_ADDRESS_WIDTH> > csr_address_db0;
	/** Address of the data packet requested in Data Buffer 1 */
	sc_in<sc_uint<BUFFERS_ADDRESS_WIDTH> > csr_address_db1;

	/** Virtual Channel of the data requested in Data Buffer 0 */
	sc_in<VirtualChannel > csr_vctype_db0;
	/** Virtual Channel of the data requested in Data Buffer 1 */
	sc_in<VirtualChannel > csr_vctype_db1;

	/** 32 bit data sent from Data Buffer to CSR */
	sc_out<sc_bv<32> > db0_data_csr;
	/** 32 bit data sent from Data Buffer to CSR */
	sc_out<sc_bv<32> > db1_data_csr;

	/** Last dword of data from Data Buffer 0 */
	sc_in<bool> csr_erase_db0;
	/** Last dword of data from Data Buffer 1 */
	sc_in<bool> csr_erase_db1;
	//@}
	

	//******************************************************
	//  Signals for communication with Flow Control module
	//******************************************************

	/** @name FlowControl
	*  Signals for communication with Flow Control module
	*/
	//@{

	/** Request to Flow Control to send packet */
	sc_in<bool> csr_available_fc0;
	/** 32 bit packet or data to Flow Control */
	sc_in<sc_bv<32> > csr_dword_fc0;
	/** Flow Control has read the last 32 bit packet or data */
	sc_out<bool> fc0_ack_csr;


	/** Request to Flow Control to send packet */
	sc_in<bool> csr_available_fc1;
	/** 32 bit packet or data to Flow Control */
	sc_in<sc_bv<32> > csr_dword_fc1;
	/** Flow Control has read the last 32 bit packet or data */
	sc_out<bool> fc1_ack_csr;

	//@}

	///SystemC Macro
	SC_HAS_PROCESS(csr_l2_tb);

	///Testbench module constructor
	csr_l2_tb(sc_module_name name);

	///Queue of packets to send from size 0
	std::deque<PacketContainerWithData> to_send0;
	///Queue of packets that are expected to be received on side 0
	std::deque<ExpectedResponse> to_receive0;
	///Queue of packets to send from size 1
	std::deque<PacketContainerWithData> to_send1;
	///Queue of packets that are expected to be received on side 1
	std::deque<ExpectedResponse> to_receive1;
	///Queue of packets to send from any side (
	std::deque<PacketContainerWithData> to_send;
	///Queue of packets that are expected to be received on any side
	std::deque<ExpectedResponse> to_receive;
	
	/**
		When sending a packet from within the queue of packets to send, if
		it contains data, it must then be sent by a process simulating the databuffer.
		The information about the data to be sent from side 0 is store in these variables
	*/
	//@{
	///Actual data to send
	unsigned int data0[16];
	///Number of dwords to send
	unsigned int data_size0;
	///Number of dwords to are currently sent
	unsigned int data_sent0;
	///If the data being sent to CSR is valid (it takes a delay of one cycle)
	sc_signal<bool> valid_output0;
	///The address where the data is stored
	sc_uint<BUFFERS_ADDRESS_WIDTH> data_address0;
	///The virtual channel of the data
	VirtualChannel data_vc0;
	//@}

	/**
		When sending a packet from within the queue of packets to send, if
		it contains data, it must then be sent by a process simulating the databuffer.
		The information about the data to be sent from side 1 is store in these variables
	*/
	//@{
	///Actual data to send
	unsigned int data1[16];
	///Number of dwords to send
	unsigned int data_size1;
	///Number of dwords to are currently sent
	unsigned int data_sent1;
	///If the data being sent to CSR is valid (it takes a delay of one cycle)
	sc_signal<bool> valid_output1;
	///The address where the data is stored
	sc_uint<BUFFERS_ADDRESS_WIDTH> data_address1;
	///The virtual channel of the data
	VirtualChannel data_vc1;
	//@}

	///The number of dword received fomr the CSR response to side 0
	unsigned int received0;
	///The number of dword received fomr the CSR response to side 1
	unsigned int received1;

	///The side from which the request has been sent
	/** to_send queue contains packets that can be sent to any side,
		this stores which side it is sent to so that the response can
		be correctly verified.
	*/
	int side_pkt_sent;

	///Process that sends packets in the queues to the CSR module
	void send_packets_csr();
	///Process that verifies that the responses of the CSR are corerct
	void verify_csr_response();
	///Process that simulates the databuffer so that the CSR can access data
	void simulate_databuffer();
	///Process that generates packets to be sent to CSR
	void generate_csr_requests_and_responses();
	///Randomly acks dwords sent to flow control
	void flow_control_read_signals();
	///Process that takes care of granting access to databuffer when CSR needs data
	void grant_access_databuffer();
};

#endif
