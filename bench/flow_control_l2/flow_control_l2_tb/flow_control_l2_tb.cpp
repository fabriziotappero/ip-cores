//flow_control_l2_tb.cpp
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

#include "flow_control_l2_tb.h"
#include <sstream>

using namespace std;

const unsigned flow_control_l2_tb::next_node_databuffers_maximum[3] = {8,8,8};
const unsigned flow_control_l2_tb::next_node_buffers_maximum[3] = {8,8,8};
const int flow_control_l2_tb::nop_counter_delay = NOP_COUNTER_DELAY;

flow_control_l2_tb::flow_control_l2_tb(sc_module_name name){
	SC_THREAD(simulate_memory);
	sensitive_pos(clk);

	SC_THREAD(produce_inputs);
	sensitive_pos(clk);

	//verify_output() MUST run after produce_inputs, 
	//so wait for it to produce an event instead of being sensitive to clock
	SC_THREAD(verify_output);
	sensitive(input_produced);

	SC_THREAD(control_testbench);
	sensitive_pos(clk);

	srand(1987);
	error = false;

	for(int n = 0; n < 10; n++)
		nop_delay[n].nop_received = false;
}

void flow_control_l2_tb::simulate_memory(){
	while(true){
		history_memory_output = history_memory[(int)history_memory_read_address.read()];
		if(history_memory_write.read())
			history_memory[(unsigned)history_memory_write_address.read()] = 
				(unsigned)(sc_uint<32>)history_memory_write_data.read();
		wait();
	}
}

void flow_control_l2_tb::control_testbench(){
	lk_rx_connected = true;
	percent_chance_from_eh = 0;
	percent_chance_from_csr = 0;
	percent_chance_from_fwd = 0;
	percent_chance_from_ui = 0;

	percent_chance_nop_req_db = 0;
	percent_chance_nop_req_ro = 0;

	percent_chance_nop_received = 0;

	ldtstopx = true;
	resetx = false;
	csr_retry = true;
	for(int n = 0; n < 3; n++) wait();
	if(error) return;
	resetx = true;

	percent_chance_from_eh = 20;
	percent_chance_from_csr = 40;
	percent_chance_from_fwd = 60;
	percent_chance_from_ui = 7;

	percent_chance_nop_req_db = 8;
	percent_chance_nop_req_ro = 8;

	percent_chance_nop_received = 15;

	for(int n = 0; n < 65; n++) wait();
	if(error) return;
	cd_initiate_retry_disconnect = true;
	wait();
	cd_initiate_retry_disconnect = false;

	for(int n = 0; n < 20; n++) wait();

	lk_rx_connected = false;
	for(int n = 0; n < 5; n++) wait();
	lk_rx_connected = true;

}

void flow_control_l2_tb::produce_inputs(){
	sc_bv<32> cmd;

	////////////////////////////////////////////////
	//Generate a packet from the different sources
	//Output them, but don't make them available yet
	/////////////////////////////////////////////////

	//Output Error handler packet
	generate_random_response(cmd,data_left_eh);
	eh_cmd_data_fc = cmd;
	eh_available_fc = false;

	//Output CSR packet
	generate_random_response(cmd,data_left_csr);
	csr_dword_fc = cmd;
	csr_available_fc = false;

	//Output UI packet
	sc_bv<64> pkt;
	unsigned datalength;
	VirtualChannel ui_vc = VC_NONE;
	ui_packet_fc = 0;
	ui_available_fc = false;


	//OutputFWD packet
	syn_ControlPacketComplete pkt_complete;
	VirtualChannel fwd_vc = generate_random_packet(pkt,datalength);
	//Not used by flow_control_l3, so any value is ok.  The state machine reads
	//the chain bit off of the packet if needed
	pkt_complete.isPartOfChain = false;
	pkt_complete.packet = pkt;
	pkt_complete.error64BitExtension = false;
	pkt_complete.data_address = rand();

	ro_packet_fwd = pkt_complete;
	ro_packet_vc_fwd = fwd_vc;
	ro_available_fwd = false;

	unsigned data_sent_ui = 0;

	crc1 = 0xFFFFFFFF;
	crc2 = 0xFFFFFFFF;

	int retry_sequence_count = 0;


	//////////////////////////////////////
	// Misc init
	//////////////////////////////////////
	current_user_data_vc = VC_NONE;
	current_user_data_vc_output = VC_NONE;
	fc_status = FC_NONE;

	cd_rx_next_pkt_to_ack_fc = 0;
	data_sent_db = 0;

	wait();
	while(!error){

		/////////////////////////////////////////////////////
		// Handle sending packets from the different sources
		/////////////////////////////////////////////////////

		//Randomly set if input data is available
		eh_available_fc = (rand() % 100 < percent_chance_from_eh) || fc_status == FC_SENDING_EH;
		csr_available_fc = (rand() % 100 < percent_chance_from_csr) || fc_status == FC_SENDING_CSR;
		ro_available_fwd = rand() % 100 < percent_chance_from_fwd;

		//If reading data from errorhandler, add it to the queue of expected output dword
		if(fc_ack_eh.read() && resetx.read()){
			if(fc_status != FC_SENDING_EH && fc_status != FC_NONE){
				cout << "ERROR: Reading EH while other task not done" <<endl;
				cout << "fc_status: " << fc_status << endl;
				error = true; continue;
			}

			OutputDword expected;
			expected.dword = eh_cmd_data_fc.read();
			if(fc_status == FC_NONE){
				expected.lctl = true;  expected.hctl = true;
			}
			else{
				expected.lctl = false;  expected.hctl = false;
			}
			expected_output.push_back(expected);

			if(data_left_eh){
				data_left_eh--;
				getRandomVector(cmd);
				eh_cmd_data_fc = cmd;
				fc_status = FC_SENDING_EH;
				
				//In retry mode, calculate the CRC of the packet
				if(csr_retry.read()){
					bool command = (crc2 == 0xFFFFFFFF);
					calculate_crc2(eh_cmd_data_fc.read(),command, command);
				}
			}
			else{
				//In retry mode, expect a following CRC
				if(csr_retry.read()){
					if(crc2 != 0xFFFFFFFF){
						calculate_crc2(eh_cmd_data_fc.read(),false, false);
						expected.dword = ~crc2;
						expected.lctl = false;  expected.hctl = true;
						crc2 = 0xFFFFFFFF;
					}
					else{
						calculate_crc1(eh_cmd_data_fc.read(),true, true);
						expected.dword = ~crc1;
						expected.lctl = true;  expected.hctl = false;
						crc1 = 0xFFFFFFFF;
					}
					expected_output.push_back(expected);
				}

				//When packet done being sent, generate a new one
				generate_random_response(cmd,data_left_eh);
				eh_cmd_data_fc = cmd;
				fc_status = FC_NONE;
			}
		}

		//If reading data from CSR, add it to the queue of expected output dword
		if(fc_ack_csr.read() && resetx.read()){
			if(fc_status != FC_SENDING_CSR && fc_status != FC_NONE){
				cout << "ERROR: Reading CSR while other task not done" <<endl;
				cout << "Current status: " << fc_status << endl;
				error = true; continue;
			}

			OutputDword expected;
			expected.dword = csr_dword_fc.read();
			if(fc_status == FC_NONE){
				expected.lctl = true;  expected.hctl = true;
			}
			else{
				expected.lctl = false;  expected.hctl = false;
			}
			expected_output.push_back(expected);

			if(data_left_csr){
				data_left_csr--;
				getRandomVector(cmd);
				csr_dword_fc = cmd;
				fc_status = FC_SENDING_CSR;

				//In retry mode, calculate the CRC of the packet
				if(csr_retry.read()){
					bool command = (crc2 == 0xFFFFFFFF);
					calculate_crc2(csr_dword_fc.read(),command, command);
				}
			}
			else{
				//In retry mode, expect a following CRC
				if(csr_retry.read()){
					if(crc2 != 0xFFFFFFFF){
						calculate_crc2(csr_dword_fc.read(),false, false);
						expected.dword = ~crc2;
						expected.lctl = false;  expected.hctl = true;
						crc2 = 0xFFFFFFFF;
					}
					else{
						calculate_crc1(csr_dword_fc.read(),true, true);
						expected.dword = ~crc1;
						expected.lctl = true;  expected.hctl = false;
						crc1 = 0xFFFFFFFF;
					}
					expected_output.push_back(expected);
				}
				generate_random_response(cmd,data_left_csr);
				csr_dword_fc = cmd;
				fc_status = FC_NONE;
			}
		}


		//If reading data from command buffers, add it to the queue of expected output dword
		if(fwd_ack_ro.read() && resetx.read()){
			if(fc_status != FC_NONE){
				cout << "ERROR: Reading FWD command while other task not done" <<endl;
				cout << "  - fc_status=" << fc_status << endl;
				error = true; continue;
			}

			OutputDword expected;
			expected.dword = ro_packet_fwd.read().packet.range(31,0);
			expected.lctl = true;  expected.hctl = true;
			expected_output.push_back(expected);

			PacketCommand cmd = getPacketCommand(ro_packet_fwd.read().packet.range(5,0));
			bool current_dword = isDwordPacket(ro_packet_fwd.read().packet,cmd);
			bool current_data = hasDataAssociated(cmd);
			int current_datalength = (int)getDataLengthm1(ro_packet_fwd.read().packet) + 1;
			VirtualChannel current_vc = getVirtualChannel(ro_packet_fwd.read().packet,cmd);

			if(!current_dword){
				expected.dword = ro_packet_fwd.read().packet.range(63,32);
				expected_output.push_back(expected);
			}

			if(current_datalength){
				sc_uint<4> addr = ro_packet_fwd.read().data_address;
				update_databuffer_entry(current_datalength,current_vc,addr);
			}

			fwd_vc = generate_random_packet(pkt,datalength);
			//Not used by flow_control_l3, so any value is ok.  The state machine reads
			//the chain bit off of the packet if needed
			pkt_complete.packet = pkt;
			pkt_complete.data_address = rand();

			//In retry mode, calculate the CRC of the packet
			if(csr_retry.read()){
				//If it is a command packet with associated data, the CRC will also
				//need to be calculated from the data packet, so don't add the CRC to
				//the expected queue just yet
				if(current_data){
					calculate_crc2(ro_packet_fwd.read().packet.range(31,0),true, true);
					if(!current_dword)
						calculate_crc2(ro_packet_fwd.read().packet.range(63,32),true, true);
				}
				else{
					//If it is a command packet without associated data, expect a following CRC
					calculate_crc1(ro_packet_fwd.read().packet.range(31,0),true, true);
					if(!current_dword)
						calculate_crc1(ro_packet_fwd.read().packet.range(63,32),true, true);
					expected.dword = ~crc1;
					expected.lctl = true;  expected.hctl = false;
					crc1 = 0xFFFFFFFF;
					expected_output.push_back(expected);
				}
			}
			if(current_data)
				fc_status = FC_SENDING_FWD;

			ro_packet_fwd = pkt_complete;
			ro_packet_vc_fwd = fwd_vc;
		}


		///////////////////////////////////////////////////////////////////////////////
		//Packets from UI work a bit differently.  It's a write in a FIFO and we must
		//only make a packet available when it CAN be accepted.
		///////////////////////////////////////////////////////////////////////////////
		//Generate a random packet
		ui_vc = generate_random_packet(pkt,datalength);

		//Check that it can be sent
		bool can_send_ui = !(sc_bit)fc_user_fifo_ge2_ui.read()[(unsigned)ui_vc];

		//send if(necessary
		bool send_ui = (rand() % 100 < percent_chance_from_ui) && can_send_ui;

		if(send_ui && resetx.read()){
			ui_available_fc = true;

			if(datalength != 0)
				add_ui_data_packet(datalength,ui_vc,pkt);
			ui_packet_fc = pkt;
			user_packets.push_back(pkt);
			//cout << "SENDING_UI: pkt=" << pkt.to_string(SC_HEX) << " datalength=" << datalength << endl;
		}
		else{
			ui_available_fc = false;
		}


		/////////////////////////////////////////////////////
		// Handle nop related signals
		/////////////////////////////////////////////////////
		db_nop_req_fc =  rand()% 100 < percent_chance_nop_req_db;;
		ro_nop_req_fc =  rand()% 100 < percent_chance_nop_req_ro;;

		ro_buffer_cnt_fc = rand() & 0x3F;
		db_buffer_cnt_fc = rand() & 0x3F;

		//Force to 0 the buffer count as if all buffers were sent during retry sequence
		//(needed to start the retry sequence)
		if(!retry_sequence || !lk_rx_connected.read()) retry_sequence_count = 0;
		if(cd_nop_received_fc.read())retry_sequence_count++;

		if(retry_sequence && retry_sequence_count > 2 && retry_sequence_count < 5){
			ro_buffer_cnt_fc = 0;
			db_buffer_cnt_fc = 0;
		}
			
		cd_nop_received_fc = nop_delay[nop_counter_delay-1].nop_received;
		if(nop_delay[nop_counter_delay-1].nop_received){
			cd_nop_ack_value_fc = nop_delay[nop_counter_delay-1].nop_ack_value;
			cd_nopinfo_fc = nop_delay[nop_counter_delay-1].nop_information;
		}

		//Generate a value that we can check in the received nops.  The 0x20 is just
		//an arbitrary value ored in to make sure that rand() doesn't produce 0.  Having
		//0 is not wanted because receiving 0 *could* also mean that the design isn't working.
		if(resetx.read())
			cd_rx_next_pkt_to_ack_fc = (rand() & 0xFF) | 0x20;
		else
			cd_rx_next_pkt_to_ack_fc = 0;

		//If a nop is sent, tag it as being expected with the correct value
		if(fc_nop_sent.read() && resetx.read()){
			OutputDword expected;
			expected.dword = 0;
			expected.dword.range(19,18) = db_buffer_cnt_fc.read().range(5,4);
			expected.dword.range(17,16) = ro_buffer_cnt_fc.read().range(5,4);
			expected.dword.range(15,14) = db_buffer_cnt_fc.read().range(3,2);
			expected.dword.range(13,12) = ro_buffer_cnt_fc.read().range(3,2);
			expected.dword.range(11,10) = db_buffer_cnt_fc.read().range(1,0);
			expected.dword.range(9,8)   = ro_buffer_cnt_fc.read().range(1,0);

			expected.dword.range(31,24) = cd_rx_next_pkt_to_ack_fc.read();
			expected.lctl = true;
			expected.hctl = true;
			expected_output.push_back(expected);

			if(csr_retry.read()){
				calculate_crc1(expected.dword,true, true);
				expected.dword = ~crc1;
				expected.lctl = true;  expected.hctl = false;
				crc1 = 0xFFFFFFFF;
				expected_output.push_back(expected);
			}
		}

		/////////////////////////////////////////////////////
		// Handle sending data from Databuffer and UI
		/////////////////////////////////////////////////////

		//from databuffer
		if(fwd_address_db.read() == databuffer_data.address &&
			fwd_vctype_db.read() == databuffer_data.vc &&
			data_sent_db < (unsigned)databuffer_data.size)
		{
			db_data_fwd = databuffer_data.dwords[data_sent_db];
		}
		else{
			db_data_fwd = 0;
		}

		if(fwd_read_db.read() && resetx.read()){
			if(fc_status != FC_SENDING_FWD){
				cout << "ERROR: Reading FWD data without having previously read a fwd command" <<endl;
				cout << "  - fc_status=" << fc_status << endl;
				error = true; continue;
			}
			if(databuffer_output_vc != databuffer_data.vc ||
				databuffer_output_addr != databuffer_data.address ||
				data_sent_db == databuffer_data.size)
			{
				cout << "ERROR: Invalid read to databuffer data" << endl;
				if(databuffer_output_vc != databuffer_data.vc) 
					cout << "  -VC expected: " << databuffer_data.vc << " Received: " << databuffer_output_vc << endl;
				if(databuffer_output_addr != databuffer_data.address) 
					cout << "  -address expected: " << databuffer_data.address << " Received: " << databuffer_output_addr << endl;
				if(data_sent_db == databuffer_data.size) cout << "  completed sending data already" << endl;
				error = true; continue;
			}

			OutputDword expected;
			expected.dword = db_data_fwd.read();
			expected.lctl = false;  expected.hctl = false;
			expected_output.push_back(expected);
			if(csr_retry.read())
				calculate_crc2( db_data_fwd.read(),false, false);

			data_sent_db++;

			//cout << "Data sent db: " << data_sent_db <<  "  Data size: " << databuffer_data.size << endl;

			if(data_sent_db == databuffer_data.size){
				db_data_fwd = 0;
				fc_status = FC_NONE;
				data_sent_db = 0;
				if(csr_retry.read()){
					expected.dword = ~crc2;
					expected.lctl = false;  expected.hctl = true;
					crc2 = 0xFFFFFFFF;
					expected_output.push_back(expected);
				}
			}
			else{
				db_data_fwd = databuffer_data.dwords[data_sent_db];
			}
		}

		databuffer_output_vc = fwd_vctype_db.read();
		databuffer_output_addr = (unsigned)fwd_address_db.read();

		//from UI
		if(current_user_data_vc != VC_NONE){
			if(fc_data_vc_ui.read() != current_user_data_vc){
				cout << "ERROR: VC value not held until all UI data read" << endl;
				error = true; continue;
			}

			if(fc_consume_data_ui.read()){
				data_sent_ui++;
				if(data_sent_ui != user_data[current_user_data_vc].front().size){
					ui_data_fc = user_data[current_user_data_vc].front().dwords[data_sent_ui];
				}
				else{
					data_sent_ui = 0;
					current_user_data_vc = VC_NONE;
					fc_status = FC_NONE;
				}

			}
		}
		else{
			if(fc_consume_data_ui.read()){
				if(fc_status != FC_NONE){
					cout << "ERROR: Reading UI data while other task not done" <<endl;
					cout << "  - fc_status=" << fc_status << endl;
					error = true; continue;
				}
				if(user_data[fc_data_vc_ui.read()].empty() ||
					fc_data_vc_ui.read() !=current_user_data_vc_output)
				{
					cout << "ERROR: << Invalid VC when reading UI data" << endl;
					error = true; continue;
				}
				if(user_data[fc_data_vc_ui.read()].front().size != 1){
					data_sent_ui = 1;
					current_user_data_vc = fc_data_vc_ui.read();
					fc_status = FC_SENDING_UI;
					ui_data_fc = user_data[fc_data_vc_ui.read()].front().dwords[data_sent_ui];
				}
			}
			else{
				if(fc_data_vc_ui.read() == VC_NONE){
					ui_data_fc = 0;
				}
				else if(user_data[fc_data_vc_ui.read()].empty())
					ui_data_fc = 0;
				else{
					ui_data_fc = user_data[fc_data_vc_ui.read()].front().dwords[0];
				}
			}
		}

		current_user_data_vc_output = fc_data_vc_ui.read();

		//verify_output() MUST run after produce_inputs, 
		//so when produce_inputs is done, do a notification
		input_produced.notify();
		wait();		
	}
}

void flow_control_l2_tb::verify_output(){

	////////////////////////////////////////////////////
	// Initialization
	////////////////////////////////////////////////////

	clear_next_node_information();

	ignore_next_dword_for_ack = false;

	bool receiving_ui_datapacket = false;
	VirtualChannel ui_packet_vc = VC_NONE;
	unsigned ui_data_received = 0;
	bool expected_second_ui_command_dword = false;
	bool expecting_nop_crc = false;
	sc_bv<32> second_ui_command_dword;

	//At the beggining of a connection, we can expect to receive NOP's
	//even though they're not really expected
	bool connection_start = true;

	bool expected_discon_nop = false;
	bool received_discon_nop = false;
	bool retry_discon_nop = false;
	int max_delay_discon_nop = 0;

	retry_sequence = false;

	//Loop while no error is detected
	//Catch any exception
	try	{ while(!error){
		//Under reset, clear some information
		if(!resetx.read()){
			clear_next_node_information();
			connection_start = true;
			retry_sequence = false;
		}

		//////////////////////
		//Analyze disconnect nops
		//////////////////////
		if(expected_discon_nop && !received_discon_nop){
			max_delay_discon_nop--;
			if(max_delay_discon_nop <= 0){
				cout << "ERROR: Disconnect nop expected but never received (timeout)" << endl;
				error = true; continue;
			}
		}

		if((!ldtstopx.read() || 
			lk_initiate_retry_disconnect.read() && csr_retry.read() || 
			cd_initiate_retry_disconnect.read() && csr_retry.read())&& !expected_discon_nop)
		{
			expected_discon_nop = true;
			max_delay_discon_nop = 32;
			retry_discon_nop = csr_retry.read();
		}

		if(!retry_discon_nop && ldtstopx.read()){
			expected_discon_nop = false;
			received_discon_nop = false;
		}
		//////////////////////
		//Validate packet sent
		//////////////////////
		lk_consume_fc = rand() % 10 < 9;
		
		//There is always a first empty nop at the begginning, read it
		if(connection_start && lk_consume_fc.read() && resetx.read()){
			connection_start = false;
			crc1 = 0xFFFFFFFF;
			crc2 = 0xFFFFFFFF;
			//If in retry mode, expect a nop CRC
			OutputDword o; o.dword = 0; o.lctl = true; o.hctl = true;
			expected_output.push_back(o);
			if(csr_retry.read()){
				calculate_crc1(o.dword,true,true);
				o.dword = ~crc1; o.lctl = true; o.hctl = false;
				crc1 = 0xFFFFFFFF;
				expected_output.push_back(o);
			}
		}

		//Stop ignoring output when fc_disconnect_lk returns to false
		/** It is needed to do it here because if it is done in
		    manage_retry_sequence, if there is nothing in the history
			to play back, the first dword would be missed.*/
		if(!fc_disconnect_lk.read()) retry_disconnect = false;


		/**
			In this section, we check if what is received is valid.
			There are two possible correct values : a packet from the
			expected list or a packet that was stored in the UI fifo.
			
			All packets exluding packets from the UI are consumed by
			the Flow Control module so we know that we are expecting
			thos packets.  UI packets on the other hand are stored
			in a buffer before being sent, so we do not know exactly
			when they will be received.

			So we first check if it was from the expected list, and
			then if it's a valid packet that was sent from the UI.
		*/
		if(retry_sequence || retry_disconnect){
			manage_retry_sequence();
		}	
		else if(lk_consume_fc.read() && !connection_start){
			OutputDword expected;
			if(!expected_output.empty())
				expected = expected_output.front();
			/*
				bool receiving_ui_packet = false;
				VirtualChannel ui_packet_vc = VC_NONE;
				unsigned ui_data_received = 0;
			*/
			//If we are currently receiving a UI DATA packet
			if(expected_second_ui_command_dword){
				if(fc_dword_lk.read() != second_ui_command_dword ||
					!fc_lctl_lk.read() || !fc_hctl_lk.read())
				{
					cout << "ERROR: Invalid second UI dword received" << endl;
					cout << "Dword expected: " << second_ui_command_dword.to_string(SC_HEX) <<
						" received: " << fc_dword_lk.read().to_string(SC_HEX) << endl;
					error = true; continue;
				}
				expected_second_ui_command_dword = false;
			}
			//If expecting a nop CRC, just check that it is correct in the expected
			//dwords list
			else if(expecting_nop_crc){
				if(fc_dword_lk.read() == expected.dword &&
					fc_lctl_lk.read() == expected.lctl &&
					fc_hctl_lk.read() == expected.hctl &&
					!expected_output.empty())
				{
					expected_output.pop_front();
					expecting_nop_crc = false;
				}
				else{
					cout << "ERROR: Invalid NOP CRC received while receiving UI data" << endl;
				}
			}
			//If already receiving data packet
			else if(receiving_ui_datapacket){
				//Check if receiving a nop
				if(fc_lctl_lk.read() || fc_hctl_lk.read()){
					if(!(fc_lctl_lk.read()&& fc_hctl_lk.read() &&
						fc_dword_lk.read().range(5,0) == 0))
					{
						cout << "ERROR: Invalid non data packet received while receiving UI data" << endl;
						cout << "Received: " << fc_dword_lk.read().to_string(SC_HEX) << endl;
						error = true; continue;
					}
					if(fc_dword_lk.read() == expected.dword &&
						fc_lctl_lk.read() == expected.lctl &&
						fc_hctl_lk.read() == expected.hctl &&
						!expected_output.empty())
					{
						expected_output.pop_front();
						expecting_nop_crc = csr_retry.read();
					}
					else{
						cout << "ERROR: Unexpected NOP received while receiving UI data" << endl;
						cout << "Received: " << fc_dword_lk.read().to_string(SC_HEX);
						error = true; continue;
					}
				}
				//Check if the correct data is received
				else{
					PacketData& data = user_data[ui_packet_vc].front();
					//cout << "Receiving UI datapacket" << fc_dword_lk.read().to_string(SC_HEX) << endl;
					//cout << "Size of data: " << data.size << " data reveived so far: " << ui_data_received << endl;
					//cout << "Control packet: " << data.associated_control_pkt.to_string(SC_HEX) << endl;

					if(data.dwords[ui_data_received++] != fc_dword_lk.read())
					{
						cout << "ERROR: Invalid data received while reveiving ui data" << endl;
						cout << "Expected: " << sc_uint<32>(data.dwords[ui_data_received-1]).to_string(SC_HEX) << 
							" received: " << fc_dword_lk.read().to_string(SC_HEX) << endl;
						error = true; continue;
					}
					//If retry mode, expect the CRC
					if(data.size == ui_data_received){
						receiving_ui_datapacket = false;
						ui_data_received = 0;
						if(csr_retry.read()){
							add_expected_crc_for_packet(user_data[ui_packet_vc].front());
						}
						user_data[ui_packet_vc].pop_front();
					}
				}
			}
			//If the packet is expected
			else if(fc_dword_lk.read() == expected.dword &&
				fc_lctl_lk.read() == expected.lctl &&
				fc_hctl_lk.read() == expected.hctl &&
				!expected_output.empty())
			{
				expected_output.pop_front();
			}
			//Check for a disconnect nop
			else if(fc_lctl_lk.read() && fc_hctl_lk.read() && fc_dword_lk.read() == 0x00000040){
				if(!expected_discon_nop){
					cout << "ERROR: Unexpected disconnect nop" << endl;
					error = true; continue;
				}
				else{
					if(retry_discon_nop){
						expected_discon_nop = false;
						start_retry_sequence();
					}
					else{
						received_discon_nop = true;
					}
				}
			}
			//Check if it is in the UI fifo
			else if(fc_lctl_lk.read() && fc_hctl_lk.read()){
				//Try to find the packet in the list send from UI
				bool found = false;
				deque<sc_bv<64> >::iterator i;
				PacketCommand cmd = getPacketCommand(fc_dword_lk.read().range(5,0));
				receiving_ui_datapacket = hasDataAssociated(cmd);
				for(i = user_packets.begin(); i != user_packets.end();i++){
					if((*i).range(31,0) == fc_dword_lk.read()){
						expected_second_ui_command_dword = !isDwordPacket((*i),cmd);
						second_ui_command_dword = (*i).range(63,32);
						found = true;

						/**This is a hack to keep the code a bit more simple.  When a 
						CRC is expected for a UI packet without data, add it to the
						expected list.  It is impossible to do this for packets that have
						data because NOPs might get inserted to the expected list, the CRC
						calculation is taken car of in the UI data reception code.*/
						if(csr_retry.read() && !receiving_ui_datapacket){
							unsigned tmp = crc1;
							crc1 = 0xFFFFFFFF;
							calculate_crc1(fc_dword_lk.read(),true,true);
							if(expected_second_ui_command_dword)
								calculate_crc1((*i).range(63,32),true,true);
							
							OutputDword o;
							o.dword = ~crc1;
							o.lctl = true;
							o.hctl = false;
							expected_output.push_front(o);
							
							crc1 = tmp;
						}

						break;
					}
				}



				//If not found, generate an error
				if(!found){
					cout << "ERROR: Packet not found in the packet list sent from fifo" << endl;
					cout << "Dword not found: " << fc_dword_lk.read().to_string(SC_HEX) << endl;
					if(expected_output.empty()){
						cout << "No expected dword" << endl;	
					}
					else{
						cout << "Expected dword: " << expected.dword.to_string(SC_HEX) << endl;
						cout << "Expected LCTL: " << expected.lctl << endl;
						cout << "Expected HCTL: " << expected.hctl << endl;
					}
					error = true; continue;
				}

				//Check if it's legal to send that packet by checking the previous packets
				bool passPW = getPassPW(*i);
				ui_packet_vc = getVirtualChannel(*i,cmd);
				bool illegal = false;
				deque<sc_bv<64> >::iterator n;
				for(n = user_packets.begin(); n != i && !illegal;n++){
					PacketCommand cmd_n = getPacketCommand(n->range(5,0));
					VirtualChannel vc_n = getVirtualChannel(*n,cmd_n);
					bool passPW_n = getPassPW(*n);
					switch(ui_packet_vc){
						case VC_POSTED:
							illegal = vc_n == VC_POSTED && (passPW_n || !passPW);
							break;
						case VC_NON_POSTED:
							illegal = !passPW || passPW_n;
							break;
						case VC_RESPONSE:
							illegal = vc_n == VC_RESPONSE || !passPW && vc_n == VC_POSTED;
							break;
						default:
							cout << "ERROR: Internal error, an invalide packet was received but was expected" << endl;
							error = true; continue;
					}
					if(illegal) break;
				}
				if(illegal){
					cout << "ERROR: Received a packet which broke ordering rules within UI FIFO" << endl;
					cout << "Packet: " << i->to_string(SC_HEX) << " passed: " << n->to_string(SC_HEX) << endl;
					error = true; continue;
				}
				user_packets.erase(i);
			}
			else{
				cout << "ERROR: Unexpected non command packet received" << endl;
				cout << "Received: " << fc_dword_lk.read().to_string(SC_HEX) <<
						" LCTL: " << fc_lctl_lk.read() <<
						" HCTL: " << fc_hctl_lk.read() << endl;
				if(expected_output.empty()){
					cout << "Nothing expected" << endl;
				}
				else{
					cout << "Expected: " << expected_output.front().dword.to_string(SC_HEX) << 
						" LCTL: " << expected_output.front().lctl <<
						" HCTL: " << expected_output.front().hctl << endl;
				}
				error = true; continue;
			}
		}

		manage_ack_buffer_count();
		send_next_node_nops();
		free_buffers();
		if(csr_retry.read()){
			manage_history();
		}
		wait();
	}/* while*/ } // try
	catch(TestbenchError tbe){
		cout << tbe.message << endl;
		error = true;
	}
	resetx = false;
}

void flow_control_l2_tb::manage_retry_sequence(){
	//Analyze output when data is read, unless we are ignoring output because
	//a retry disconnect sequence was just initiated
	if(lk_consume_fc.read() && !retry_disconnect){
		//A nop was sent on previous cycle, we expect a nop CRC
		if(retry_expect_nop_crc){
			if(retry_playback_history.empty()){
				cout << "*!!!* History playback empty" << endl;
				retry_sequence = false;
			}
			if(expected_output.empty()){
				TestbenchError te;
				te.message = "No nop CRC in expected output (retry sequence)";
				throw te;
			}
			if(expected_output.front().dword != fc_dword_lk.read() ||
				expected_output.front().lctl != fc_lctl_lk.read() ||
				expected_output.front().hctl != fc_hctl_lk.read())
			{
				TestbenchError te;
				ostringstream o;
				o << "Expecting nop CRC (retry sequence), invalid dword received" << endl
					<< "Expected: " << expected_output.front().dword.to_string(SC_HEX) << " Received: " << 
					fc_dword_lk.read().to_string(SC_HEX) << endl
					<< "Expected LCTL: " << expected_output.front().lctl << " xpected HCTL: " << expected_output.front().hctl;
				te.message = o.str();
				throw te;
			}
			expected_output.pop_front();

			retry_expect_nop_crc = false;
		}
		//First dword of a quad word packet sent last cycle, expect the secont dword
		else if(retry_second_dword_next){
			retry_second_dword_next = false;
			if(fc_dword_lk.read() != retry_playback_history.front().pkt.range(63,32) ||
				!fc_lctl_lk.read() || !fc_hctl_lk.read())
			{
				TestbenchError err;
				err.message = "ERROR: Wrong second command dword during history playback\n";
				throw err;
			}
		}
		//Packet was done being sent last cycle, expect the following CRC
		else if(retry_crc_next){
			retry_crc_next = false;
			bool has_data = retry_playback_history.front().data_size != 0;
			if(fc_dword_lk.read() != retry_playback_history.front().crc ||
				fc_lctl_lk.read() == has_data || fc_hctl_lk.read() != has_data)
			{
				TestbenchError err;
				err.message = "ERROR: Wrong crc dword during history playback\n";
				throw err;
			}
			retry_playback_history.pop_front();

			//Retry sequence is over the the playback history is empty
			retry_sequence = !retry_playback_history.empty();
		}
		//Command packet with data associated received last cycle, now expect the following data
		else if(retry_receive_data){
			if(fc_lctl_lk.read() && fc_hctl_lk.read() && !expected_output.empty()){
				if(fc_dword_lk.read() == expected_output.front().dword){
					expected_output.pop_front();
					retry_expect_nop_crc = true;
				}
				else{
					TestbenchError err;
					ostringstream o;
					o << "ERROR: Unexpected command packet received while receiving retry data\n" <<
						"Received: " << fc_dword_lk.read().to_string(SC_HEX) << 
						" Expected: " << expected_output.front().dword.to_string(SC_HEX);
					err.message = o.str();
					throw err;
				}
			}
			else{
				if(fc_dword_lk.read() != retry_playback_history.front().data[retry_data_count++] ||
					fc_lctl_lk.read() || fc_hctl_lk.read())
				{
					TestbenchError err;
					ostringstream o;
					o << "ERROR: Wrong data dword during history playback\nExpected[" << retry_data_count-1 <<"]: " << 
						sc_uint<32>(retry_playback_history.front().data[retry_data_count-1]).to_string(SC_HEX)
						<< " Received: " << fc_dword_lk.read().to_string(SC_HEX);
					err.message = o.str();
					throw err;
				}
				//cout << "Data size: " << retry_playback_history.front().data_size << " retry_data_count: " << retry_data_count << endl;
				retry_receive_data = retry_playback_history.front().data_size != retry_data_count;
				retry_crc_next = !retry_receive_data;
			}
		}
		//Expecting another 
		else{
			if(fc_lctl_lk.read() && fc_hctl_lk.read() && fc_dword_lk.read() == expected_output.front().dword){
				expected_output.pop_front();
				retry_expect_nop_crc = true;
			}
			else{
				if(fc_dword_lk.read() != retry_playback_history.front().pkt.range(31,0) ||
				!fc_lctl_lk.read() || !fc_hctl_lk.read())
				{
					TestbenchError err;
					ostringstream o;
					o << "ERROR: Wrong first command dword during history playback\n" <<
						"Received: " << fc_dword_lk.read().to_string(SC_HEX) << " Expected: " <<
						retry_playback_history.front().pkt.to_string(SC_HEX);
					err.message = o.str();
					throw err;
				}
				retry_receive_data = retry_playback_history.front().data_size;
				retry_data_count = 0;
				PacketCommand cmd = getPacketCommand( retry_playback_history.front().pkt);
				retry_second_dword_next = !isDwordPacket(retry_playback_history.front().pkt,cmd);
				retry_crc_next = !retry_receive_data;
			}
		}
	}

	//Start ignoring output when fc_disconnect_lk is true and output is read
	if(lk_consume_fc.read()){
		retry_disconnect = fc_disconnect_lk.read();
		//If there is no data in playback history, sequence is over
		retry_sequence = !retry_playback_history.empty();
	}
}

void flow_control_l2_tb::start_retry_sequence(){
	retry_sequence = true;
	retry_disconnect = false;
	retry_second_dword_next = false;
	retry_crc_next = false;
	retry_receive_data = false;

	//Tag the nops in the delay loop so that they're not sent
	for(int n = nop_counter_delay - 1; n != 0; n--)
		nop_delay[n].nop_received = false;

	//Reset the next_node_ack_value to the last sent value
	next_node_ack_value = cd_nop_ack_value_fc.read();
	next_node_ack_value_pending = cd_nop_ack_value_fc.read();

	//Reset buffer counts
	for(int n = 0; n < 3; n++){
		next_node_buffers_advertised[n] = 0;
		next_node_databuffers_advertised[n] = 0;
	}


	//history might get modified while playback so we take a snapshot for the playback
	retry_playback_history = history;

	cout << "First packet in history at retry begin : " << history.front().pkt.to_string(SC_HEX) <<
		" ID: " << history.front().nop_ack_value << endl;

	//We enter retry sequence when receiving a disconnect nop, expect the following crc
	retry_expect_nop_crc = true;
	crc1 = 0xFFFFFFFF;
	calculate_crc1(fc_dword_lk.read(),true,true);
	OutputDword o;
	o.dword = ~crc1; o.lctl = true; o.hctl = false;
	crc1 = 0xFFFFFFFF;
	expected_output.push_back(o);
}

void flow_control_l2_tb::manage_ack_buffer_count(){
	/////////////////////////////////////////////
	//Calculate Ack value and update buffer count
	/////////////////////////////////////////////
	if(lk_consume_fc.read()){
		///Ignore the second dword of a quad word command packet
		if(ignore_next_dword_for_ack){
			ignore_next_dword_for_ack = false;
		}
		///Check for dwords that are command packets (both CTL asserted)
		else if(fc_lctl_lk.read() && fc_hctl_lk.read()){
			//Set the last ack value (value pending) only when another command packet is sent
			//Meaning that it has been completely sent
			next_node_ack_value = next_node_ack_value_pending;

			sc_bv<64> pkt = fc_dword_lk.read();
			PacketCommand cmd = getPacketCommand(pkt.range(6,0));
			bool dword = isDwordPacket(pkt,cmd);
			VirtualChannel vc = getVirtualChannel(pkt,cmd);
			bool has_data = hasDataAssociated(cmd);

			///Increment the ack value
			if(csr_retry.read() && 
				fc_dword_lk.read().range(5,0) != "000000" && //Unless it's a nop
				fc_dword_lk.read().range(5,0) != "110111" && //A flow control packet
				fc_dword_lk.read().range(5,0) != "111111") next_node_ack_value_pending++;//Or a sync packet

			if(vc != VC_NONE){
				ignore_next_dword_for_ack = !dword;
				if(has_data){
					if(next_node_databuffers_advertised[vc] == 0){
						TestbenchError err;
						err.message = "ERROR: Received a packet for a Virtual channel that did not have available buffers" ;
						throw err;
					}
					next_node_databuffers_advertised[vc]--;
				}
				else{
					if(next_node_buffers_advertised[vc] == 0){
						TestbenchError err;
						err.message = "ERROR: Received a packet for a Virtual channel that did not have available buffers";
						throw err;
					}
					next_node_buffers_advertised[vc]--;
				}
			}
		}
	}
}


void flow_control_l2_tb::send_next_node_nops(){
	//////////////////////
	//Send next node nops
	//////////////////////

	//Take care of the delay
	for(int n = nop_counter_delay - 1; n != 0; n--)
		nop_delay[n] = nop_delay[n-1];

	//Decide if sending nop
	nop_delay[0].nop_received = rand()% 100 < percent_chance_nop_received &&
		!fc_disconnect_lk.read() && lk_rx_connected.read();

	//If sending nop, choose content
	if(nop_delay[0].nop_received){
		//Set the current ack value
		nop_delay[0].nop_ack_value = next_node_ack_value;

		//Randomly set how many buffers are freed
		sc_bv<12> nop_information = 0;
		
		nop_information = rand();

		//If the randomly set value exceeds the maximum value, saturate it.  Repeat for every
		//kind of buffer (3 vcs for data and for command)
		if(((sc_uint<2>)(sc_bv<2>)nop_information.range(1,0) + next_node_buffers_advertised[VC_POSTED])
				> next_node_buffers_free[VC_POSTED])
			nop_information.range(1,0) = next_node_buffers_free[VC_POSTED] - next_node_buffers_advertised[VC_POSTED];
		if(((sc_uint<2>)(sc_bv<2>)nop_information.range(3,2) + next_node_databuffers_advertised[VC_POSTED])
				> next_node_databuffers_free[VC_POSTED])
			nop_information.range(3,2) = next_node_databuffers_free[VC_POSTED] - next_node_databuffers_advertised[VC_POSTED];
		if(((sc_uint<2>)(sc_bv<2>)nop_information.range(5,4) + next_node_buffers_advertised[VC_RESPONSE])
				> next_node_buffers_free[VC_RESPONSE])
			nop_information.range(5,4) = next_node_buffers_free[VC_RESPONSE] - next_node_buffers_advertised[VC_RESPONSE];
		if(((sc_uint<2>)(sc_bv<2>)nop_information.range(7,6) + next_node_databuffers_advertised[VC_RESPONSE])
				> next_node_databuffers_free[VC_RESPONSE])
			nop_information.range(7,6) = next_node_databuffers_free[VC_RESPONSE] - next_node_databuffers_advertised[VC_RESPONSE];
		if(((sc_uint<2>)(sc_bv<2>)nop_information.range(9,8) + next_node_buffers_advertised[VC_NON_POSTED])
				> next_node_buffers_free[VC_NON_POSTED])
			nop_information.range(9,8) = next_node_buffers_free[VC_NON_POSTED] - next_node_buffers_advertised[VC_NON_POSTED];
		if(((sc_uint<2>)(sc_bv<2>)nop_information.range(11,10) + next_node_databuffers_advertised[VC_NON_POSTED])
				> next_node_databuffers_free[VC_NON_POSTED])
			nop_information.range(11,10) = next_node_databuffers_free[VC_NON_POSTED] - next_node_databuffers_advertised[VC_NON_POSTED];

		//Add the advertised value
		next_node_buffers_advertised[VC_POSTED] += (unsigned)(sc_uint<2>)(sc_bv<2>)nop_information.range(1,0);
		next_node_databuffers_advertised[VC_POSTED] += (unsigned)(sc_uint<2>)(sc_bv<2>)nop_information.range(3,2);
		next_node_buffers_advertised[VC_RESPONSE] += (unsigned)(sc_uint<2>)(sc_bv<2>)nop_information.range(5,4);
		next_node_databuffers_advertised[VC_RESPONSE] += (unsigned)(sc_uint<2>)(sc_bv<2>)nop_information.range(7,6);
		next_node_buffers_advertised[VC_NON_POSTED] += (unsigned)(sc_uint<2>)(sc_bv<2>)nop_information.range(9,8);
		next_node_databuffers_advertised[VC_NON_POSTED] += (unsigned)(sc_uint<2>)(sc_bv<2>)nop_information.range(11,10);


		nop_delay[0].nop_information = nop_information;
	}
}

void flow_control_l2_tb::free_buffers(){
	//////////////////////
	//Free some buffers
	//////////////////////
	for(int n = 0; n < 3; n++){
		//Free command packets

		//Generate a random free value that has a maximum of 3
		unsigned tmp = rand() % 20;
		unsigned free = tmp;
		if(free > 3) free = 0;

		//Add the value to the number of free buffers (and saturated at the maximum)
		if((next_node_buffers_free[n] + free) > next_node_buffers_maximum[n])
			next_node_buffers_free[n] = next_node_buffers_maximum[n];
		else
			next_node_buffers_free[n] += free;

		//Free data packets

		//Generate a random free value that has a maximum of 3
		tmp = rand() % 20;
		free = tmp;
		if(free > 3) free = 0;

		//Add the value to the number of free buffers (and saturated at the maximum)
		if((next_node_databuffers_free[n] + free) > next_node_buffers_maximum[n])
			next_node_databuffers_free[n] = next_node_buffers_maximum[n];
		else
			next_node_databuffers_free[n] += free;
	}
}

void flow_control_l2_tb::manage_history(){
	//Start by erasing packet acked in the history
	bool done = false;

	if(!resetx.read()){
		history_ack_value = 0;
		history_ignore_nop_crc = false;
		history_crc_next = false;
		history_data_count = 0;
		current_history_entry.data_size = 0;
	}

	while(!history.empty() && !done){
		sc_uint<8> current_ack_value = history.front().nop_ack_value;
		int diff = ((int)(cd_nop_ack_value_fc.read() - current_ack_value)+256) % 256;
		if(diff < 128){
			//cout << "Popping history" << endl;
			//cout << "cd_nop_ack_value_fc: " << cd_nop_ack_value_fc.read() << " current_ack_value: " << current_ack_value << endl;
			history.pop_front();
		}
		else done = true;
	}

	//Add entries to the history
	if(!retry_sequence && resetx.read()){
		if(lk_consume_fc.read()){
			if(history_ignore_nop_crc){
				history_ignore_nop_crc = false;
			}
			else if(history_second_dword_next){
				history_second_dword_next = false;
				current_history_entry.pkt.range(63,32) = fc_dword_lk.read();
				if(current_history_entry.data_size == 0) history_crc_next = true;
			}
			else if(history_crc_next){
				history_crc_next = false;
				current_history_entry.crc = (int)(sc_uint<32>)fc_dword_lk.read();
				//cout << "History entry pushed in" << endl;
				history.push_back(current_history_entry);
			}
			else if(history_data_count != current_history_entry.data_size){
				//Means we have a nop
				if(fc_lctl_lk.read()){
					history_ignore_nop_crc = true;
				}
				else{
					current_history_entry.data[history_data_count++] = (int)(sc_uint<32>)fc_dword_lk.read();
					if(history_data_count == current_history_entry.data_size)
						history_crc_next = true;
				}
			}
			else{
				if(fc_dword_lk.read().range(5,0) != 0)
				{
					//cout << "HISTORY: Adding packet: " << fc_dword_lk.read().to_string(SC_HEX) << endl;
					sc_bv<64> pkt = fc_dword_lk.read();
					current_history_entry.pkt = pkt;
					PacketCommand cmd = getPacketCommand(pkt.range(5,0));
					history_second_dword_next = !isDwordPacket(pkt,cmd);
					if(hasDataAssociated(cmd)){
						current_history_entry.data_size = (int)getDataLengthm1(pkt) + 1;
					}
					else{
						current_history_entry.data_size = 0;
					}
					history_crc_next = !history_second_dword_next && current_history_entry.data_size == 0;
					history_ack_value = (history_ack_value + 1) % 256;
					current_history_entry.nop_ack_value = history_ack_value;
					history_data_count = 0;
				}
				else{
					history_ignore_nop_crc = true;
				}
			}
		}
	}
}

void flow_control_l2_tb::clear_next_node_information(){
	//This is the number of buffers that are free (command and data)
	for(int n = 0; n < 3; n++){
		next_node_buffers_free[n] = next_node_buffers_maximum[n];
		next_node_databuffers_free[3] = next_node_databuffers_maximum[n];
	}

	for(int n = 0; n < 3; n++){
		//This is the number of buffers that have been advertised as being free through
		//nops as seen by the next node (does not take into account the nop delay)
		next_node_buffers_advertised[n] = 0;
		next_node_databuffers_advertised[n] = 0;

		//This is the number of buffers that have been advertised as being free through
		//nops as seen by the current node (takes into account the nop delay)
		buffers_available[n] = 0;
		databuffers_available[n] = 0;
	}

	next_node_ack_value = 0;
	next_node_ack_value_pending = 0;
	user_packets.clear();
	user_data[0].clear();user_data[1].clear();user_data[2].clear();
	expected_output.clear();
}

void flow_control_l2_tb::generate_random_response(sc_bv<32> &pkt, unsigned &data_size){
	int type = rand() % 2;
	sc_bv<6> command;
	sc_uint<4> data_size_m1;
	switch(type){
	case 0:
		//RdResponse
		data_size_m1 = rand() % 16;
		data_size = (unsigned)data_size_m1 + 1;
		getRandomVector(pkt);
		command = "110000";
		pkt.range(5,0) = command;
		pkt.range(25,22) = data_size_m1;
		break;
	case 1:
		//TargetDone
		data_size = 0;
		getRandomVector(pkt);
		command = "110011";
		pkt.range(5,0) = command;
	}
}

void flow_control_l2_tb::generate_random_posted(sc_bv<64> &pkt, unsigned &data_size){
	int type = rand() % 3;
	sc_bv<6> command;
	sc_uint<4> data_size_m1;
	switch(type){
	case 0:
		//Posted write
		data_size_m1 = rand() % 16;
		data_size = (unsigned)data_size_m1 + 1;
		getRandomVector(pkt);
		command = "101";
		pkt.range(5,3) = command;
		pkt.range(25,22) = data_size_m1;

		//Never create a chain packet.  If it is desired to test
		//chains, they must be explicitely generated for the purpose of
		//that test
		pkt[19] = false;
		break;
	case 1:
		//Broadcast
		data_size = 0;
		getRandomVector(pkt);
		command = "111010";
		pkt.range(5,0) = command;
		break;
	case 2:
		//Fence
		data_size = 0;
		getRandomVector(pkt);
		pkt.range(63,32) = 0;
		command = "111100";
		pkt.range(5,0) = command;
	}
}

void flow_control_l2_tb::generate_random_nposted(sc_bv<64> &pkt, unsigned &data_size){
	int type = rand() % 5;

	bool dword_read = true;
	sc_uint<4> data_size_m1 = rand() % 16;
	data_size = (unsigned)data_size_m1 + 1;
	switch(type){
	case 0:
		{
			//NPosted write
			getRandomVector(pkt);
			sc_bv<3> command = "001";
			pkt.range(5,3) = command;
			pkt.range(25,22) = data_size_m1;
		}
		break;
	case 1:
		//Read Byte
		dword_read = false;
	case 2:
		{
			//Read Dword
			getRandomVector(pkt);
			sc_bv<2> command = "01";
			pkt.range(5,4) = command;
			pkt[2] = dword_read;
			pkt.range(25,22) = data_size_m1;
			data_size = 0;
		}
		break;
	case 3:
		{
			//Atomic
			getRandomVector(pkt);
			sc_bv<6> command = "111101";
			pkt.range(5,0) = command;
			pkt.range(25,22) = data_size_m1;
		}
		break;
	case 4:
		{
			//Flush
			data_size = 0;
			getRandomVector(pkt);
			pkt.range(63,32) = 0;
			sc_bv<6> command = "000010";
			pkt.range(5,0) = command;
		}
	}
}

VirtualChannel flow_control_l2_tb::generate_random_packet(sc_bv<64> &pkt, unsigned &data_size){
	
	int vc = rand() % 3;
	switch(vc){
	case VC_POSTED:
		generate_random_posted(pkt,data_size);
		break;
	case VC_NON_POSTED:
		generate_random_nposted(pkt,data_size);
		break;
	default:
		sc_bv<32> r_pkt;
		generate_random_response(r_pkt,data_size);
		pkt = 0;
		pkt.range(31,0) = r_pkt;
	}
	return vc;	
}


void flow_control_l2_tb::getRandomVector(sc_bv<32> &vector){
	vector.range(14,0) = sc_uint<15>(rand());
	vector.range(29,15) = sc_uint<15>(rand());
	vector.range(31,30) = sc_uint<2>(rand());
}

void flow_control_l2_tb::getRandomVector(sc_bv<64> &vector){
	for(int n = 0; n < 4; n++)
		vector.range(15*(n+1) - 1,15*n) = sc_uint<15>(rand());
	vector.range(63,60) = sc_uint<4>(rand());
}

void flow_control_l2_tb::add_ui_data_packet(unsigned datalength,
									   VirtualChannel ui_vc,
									   sc_bv<64> &associated_control_packet){
	PacketData data;
	data.associated_control_pkt = associated_control_packet;
	data.size = datalength;
	for(unsigned n = 0; n < datalength; n++){
		data.dwords[n] = 
			(rand() & 0x7FFF) |  ((rand() & 0x7FFF ) << 15) | ((rand() & 0x3 ) << 30);
	}
	//cout << "ADDED UI DATA ENTRY: " << data.associated_control_pkt.to_string(SC_HEX)
	//	<< " Datalength: " << data.size << endl;
	user_data[ui_vc].push_back(data);
}

void flow_control_l2_tb::update_databuffer_entry(unsigned datalength,
										VirtualChannel ui_vc,
										sc_uint<4> &databuffer_address)
{
	databuffer_data.vc = ui_vc;
	databuffer_data.size = datalength;
	for(unsigned n = 0; n < datalength; n++){
		databuffer_data.dwords[n] = 
			(rand() & 0x7FFF) |  ((rand() & 0x7FFF ) << 15) | ((rand() & 0x3 ) << 30);
	}
	databuffer_data.address = databuffer_address;
}

void flow_control_l2_tb::calculate_crc1(sc_bv<32> dword,bool lctl, bool hctl){
	sc_bv<34> data;
	data[33] = hctl;
	data.range(32,17) = dword.range(31,16);
	data[16] = lctl;
	data.range(15,0) = dword.range(15,0);
	calculate_crc(crc1,data);
}

void flow_control_l2_tb::calculate_crc2(sc_bv<32> dword,bool lctl, bool hctl){
	sc_bv<34> data;
	data[33] = hctl;
	data.range(32,17) = dword.range(31,16);
	data[16] = lctl;
	data.range(15,0) = dword.range(15,0);
	calculate_crc(crc2,data);
}

void flow_control_l2_tb::calculate_crc(unsigned &crc,sc_bv<34> &data){
	static unsigned poly = 0x04C11DB7;

	for(int i = 0; i < 34; i++){
		/* xor highest bit w/ message: */
		unsigned tmp = ((crc >> 31) & 1) ^ ( ((sc_bit)data[i]) ? 1 : 0);

		/* substract poly if greater: */
		crc = (tmp) ? (crc << 1) ^ poly : ((crc << 1) | tmp);
	}
}

ostream &operator<<(ostream &out,const flow_control_l2_tb::FlowControlStatus fc_status){
	switch(fc_status){
		case flow_control_l2_tb::FC_SENDING_CSR:
			out << "FC_SENDING_CSR";
			break;
		case flow_control_l2_tb::FC_SENDING_EH:
			out << "FC_SENDING_EH";
			break;
		case flow_control_l2_tb::FC_SENDING_FWD:
			out << "FC_SENDING_FWD";
			break;
		case flow_control_l2_tb::FC_SENDING_UI:
			out << "FC_SENDING_UI";
			break;
		case flow_control_l2_tb::FC_NONE:
			out << "FC_NONE";
			break;
		default:
			out << "Invalid FlowControlStatus value";
	}
	return out;
}

void flow_control_l2_tb::add_expected_crc_for_packet(PacketData &data){
	unsigned tmp;
	tmp = crc2;
	crc2 = 0xFFFFFFFF;

	calculate_crc2(data.associated_control_pkt.range(31,0),true,true);
	PacketCommand cmd = getPacketCommand(data.associated_control_pkt.range(5,0));
	if(!isDwordPacket(data.associated_control_pkt,cmd))
		calculate_crc2(data.associated_control_pkt.range(63,32),true,true);

	for(int n = 0; n < data.size; n++){
		calculate_crc2(data.dwords[n],false,false);
	}

	OutputDword o;
	o.dword = ~crc2;
	o.lctl = false;
	o.hctl = true;
	expected_output.push_front(o);

	crc2 = tmp;
}



