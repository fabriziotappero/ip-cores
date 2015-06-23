//decoder_l2_tb.cpp
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

#include "decoder_l2_tb.h"
#include <iostream>
#include <string>
#include <sstream>

using namespace std;

decoder_l2_tb::decoder_l2_tb(sc_module_name name) : sc_module(name){
	SC_THREAD(stimulate_input);
	sensitive_pos(clk);
	SC_THREAD(nop_info_validation);
	sensitive_pos(clk);
	SC_THREAD(databuffer_validation);
	sensitive_pos(clk);
	SC_THREAD(disconnect_retry_validation);
	sensitive_pos(clk);
	SC_THREAD(reordering_validation);
	sensitive_pos(clk);

	//Seed random generator with any number
	srand(4052);
	error = false;
	crc1 = 0xFFFFFFFF;
	crc2 = 0xFFFFFFFF;
}

void decoder_l2_tb::stimulate_input(){
	resetx = false;
	for(int n = 0; n < 3; n++){
		wait();
	}
	resetx = true;

	//Non-retry tests, normal operation
	send_nop();
	if(error) return;
	send_tgtdone();
	if(error) return;
	send_read();
	if(error) return;
	send_write();
	if(error) return;
	send_ext();
	if(error) return;
	send_ext_fc();
	if(error) return;
	send_ext_fc64();
	if(error) return;
	send_tgtdone_in_data();
	if(error) return;
	send_discon_nop();
	
	//initiated retry mode
	resetx = false;
	csr_retry = true;
	for(int n =0; n < 3; n++)
		wait();
	resetx = true;

	//Retry mode, normal operation
	send_nop();
	if(error) return;
	send_tgtdone();
	if(error) return;
	send_read();
	if(error) return;
	send_write();
	if(error) return;
	send_ext();
	if(error) return;
	send_ext_fc();
	if(error) return;
	send_ext_fc64();
	if(error) return;
	send_tgtdone_in_data();
	if(error) return;
	send_fc_in_data();
	if(error) return;
	send_fc64_in_data();
	if(error) return;
	send_nop_in_data();
	if(error) return;
	send_discon_nop();
	if(error) return;
	cout << endl << endl << "*** TEST SUCCESSFUL! ***" << endl << endl;

	expect_cd_initiate_retry_disconnect = 99999;
	//Retry mode, create errors & stomped packets
	//not done yet
}

void decoder_l2_tb::send_dword(sc_bv<32> dword,bool lctl, bool hctl){
	bool send;
	do{
		//Don't always make the dword available
		send = rand() %10 < 8;
		if(send){
			lk_available_cd = true;
			lk_dword_cd = dword;
			lk_hctl_cd = hctl;
			lk_lctl_cd = lctl;
		}
		wait();
		lk_available_cd = false;
	}while(!send);
}

void decoder_l2_tb::send_nop(){
	//Nop is mostly zeroes
	sc_bv<32> dword = 0;
	
	//Create a random nop entry
	NopEntry entry;
	entry.cd_nopinfo_fc = sc_uint<12>(rand());
	entry.cd_nop_ack_value_fc = rand();

	//Fill the nop bits with the values from entry
	dword.range(19,8) = entry.cd_nopinfo_fc;
	dword.range(31,24) = entry.cd_nop_ack_value_fc;

	//Send then generated nop
	nop_queue.push_back(entry);
	send_dword(dword,true,true);
	if(csr_retry.read()){
		calculate_crc1(dword,true,true);
		send_dword(~crc1,true,false);
		crc1 = 0xFFFFFFFF;
	}
}

void decoder_l2_tb::send_tgtdone(){
	//Generate a target done packet
	sc_bv<32> dword;
	getRandomVector(dword);
	sc_bv<6> command = "110011";
	dword.range(5,0) = command;

	//Send the packet
	send_dword(dword,true,true);
	if(csr_retry.read()){
		calculate_crc1(dword,true,true);
		send_dword(~crc1,true,false);
		crc1 = 0xFFFFFFFF;
	}
	//Add to expected entry
	addReorderingEntry(dword,false);
}

void decoder_l2_tb::send_read(){
	//Generate first dword of read packet
	sc_bv<32> dword;
	sc_bv<32> dword2;
	getRandomVector(dword);
	sc_bv<2> command = "01";
	dword.range(5,4) = command;

	//Send it
	send_dword(dword,true,true);
	if(csr_retry.read()){
		calculate_crc1(dword,true,true);
	}

	//Repeat for second dword
	getRandomVector(dword2);
	send_dword(dword2,true,true);
	if(csr_retry.read()){
		calculate_crc1(dword2,true,true);
		send_dword(~crc1,true,false);
		crc1 = 0xFFFFFFFF;
	}

	//Add to expected entry
	sc_bv<64> qword;
	qword.range(31,0) = dword;
	qword.range(63,32) = dword2;
	addReorderingEntry(qword,false);

}

void decoder_l2_tb::send_write(){
	//Random amount of data following it
	int data_length = rand() % 16;

	///Create and store the data
	DataBufferEntry entry = generate_data_packet(data_length,VC_POSTED);
	databuffer_queue.push_back(entry);

	//Send the write command packet (randomly generated)
	send_write_header(data_length);
	//Then send the data that follows it
	send_data_packet(entry,0,data_length);

	//Then send CRC if in retry mode
	if(csr_retry.read()){
		send_dword(~crc2,false,true);
		crc2 = 0xFFFFFFFF;
	}
}


void decoder_l2_tb::send_write_header(int datalength_m1){
	sc_bv<32> dword;
	sc_bv<64> qword = 0;


	getRandomVector(dword);
	sc_bv<3> command = "101";
	dword.range(5,3) = command;
	dword.range(25,22) = sc_uint<4>(datalength_m1);
	qword.range(31,0) = dword;
	send_dword(dword,true,true);
	if(csr_retry.read()){
		calculate_crc2(dword,true,true);
	}
	getRandomVector(dword);
	qword.range(63,32) = dword;
	addReorderingEntry(qword,false);

	send_dword(dword,true,true);
	if(csr_retry.read()){
		calculate_crc2(dword,true,true);
	}
}

decoder_l2_tb::DataBufferEntry decoder_l2_tb::generate_data_packet(int datalength_m1,
													VirtualChannel vc){
	DataBufferEntry entry;
	entry.size = datalength_m1;
	entry.vc = vc;
	entry.address_requested = false;
	entry.badcrc = false;

	for(int n = 0; n <= datalength_m1; n++){
		entry.data[n] = rand() & 0xFFF |
			rand() & 0xFFF << 12 |
			rand() & 0xFF << 24;
	}

	return entry;
}

void decoder_l2_tb::send_data_packet(DataBufferEntry &entry,
									 int offset,
									 int last){
	for(int n = offset; n <= last; n++){
		send_dword(sc_uint<32>(entry.data[n]),false,false);
		if(csr_retry.read()){
			calculate_crc2(sc_uint<32>(entry.data[n]),false,false);
		}
	}
}

void decoder_l2_tb::send_ext(){
	//Send the 64 bit extension
	sc_bv<32> dword;
	getRandomVector(dword);
	sc_bv<6> command = "111110";
	dword.range(5,0) = command;
	send_dword(dword,true,true);
	if(csr_retry.read()){
		calculate_crc1(dword,true,true);
	}

	//Send a standard read packet
	send_read();

	/** The send_read() function pushed an expected request
		in the queue.  Modify it so that a 64b error is
		expected */
	reordering_queue.back().pkt.error64BitExtension = true;

}

void decoder_l2_tb::send_ext_fc(){
	sc_bv<32> dword;
	getRandomVector(dword);
	sc_bv<7> command = "0110111";
	dword.range(6,0) = command;
	send_dword(dword,true,true);
	if(csr_retry.read()){
		calculate_crc1(dword,true,true);
		send_dword(~crc1,true,false);
		crc1 = 0xFFFFFFFF;
	}
}

void decoder_l2_tb::send_ext_fc64(){
	sc_bv<32> dword;
	getRandomVector(dword);
	sc_bv<7> command = "1110111";
	dword.range(6,0) = command;
	send_dword(dword,true,true);
	if(csr_retry.read()){
		calculate_crc1(dword,true,true);
	}
	getRandomVector(dword);
	send_dword(dword,true,true);
	if(csr_retry.read()){
		calculate_crc1(dword,true,true);
		send_dword(~crc1,true,false);
		crc1 = 0xFFFFFFFF;
	}
}

void decoder_l2_tb::send_tgtdone_in_data(){
	int data_length = rand() % 12 + 4;
	DataBufferEntry entry = generate_data_packet(data_length,VC_POSTED);
	databuffer_queue.push_back(entry);
	send_write_header(data_length);

	send_data_packet(entry,0,1);
	send_tgtdone();

	//Swap packets in retry mode
	if(csr_retry.read()){
		ReorderingEntry tmp = reordering_queue.back();
		reordering_queue.back() = *(reordering_queue.end()-2);
		*(reordering_queue.end()-2) = tmp;
	}

	send_data_packet(entry,2,data_length);

	if(csr_retry.read()){
		send_dword(~crc2,false,true);
		crc2 = 0xFFFFFFFF;
	}
}

void decoder_l2_tb::send_fc_in_data(){
	int data_length = rand() % 12 + 4;
	DataBufferEntry entry = generate_data_packet(data_length,VC_POSTED);
	databuffer_queue.push_back(entry);
	send_write_header(data_length);

	send_data_packet(entry,0,1);
	send_ext_fc();
	send_data_packet(entry,2,data_length);

	if(csr_retry.read()){
		send_dword(~crc2,false,true);
		crc2 = 0xFFFFFFFF;
	}
}

void decoder_l2_tb::send_fc64_in_data(){
	int data_length = rand() % 12 + 4;
	DataBufferEntry entry = generate_data_packet(data_length,VC_POSTED);
	databuffer_queue.push_back(entry);
	send_write_header(data_length);

	send_data_packet(entry,0,1);
	send_ext_fc64();
	send_data_packet(entry,2,data_length);

	if(csr_retry.read()){
		send_dword(~crc2,false,true);
		crc2 = 0xFFFFFFFF;
	}
}

void decoder_l2_tb::send_nop_in_data(){
	int data_length = rand() % 12 + 4;
	DataBufferEntry entry = generate_data_packet(data_length,VC_POSTED);
	databuffer_queue.push_back(entry);
	send_write_header(data_length);

	send_data_packet(entry,0,1);
	send_nop();
	send_data_packet(entry,2,data_length);

	if(csr_retry.read()){
		send_dword(~crc2,false,true);
		crc2 = 0xFFFFFFFF;
	}
}

void decoder_l2_tb::send_discon_nop(){
	sc_bv<32> dword = 0;
	dword[6] = true;
	
	NopEntry entry;
	entry.cd_nopinfo_fc = sc_uint<12>(rand());
	entry.cd_nop_ack_value_fc = rand();
	dword.range(19,8) = entry.cd_nopinfo_fc;
	dword.range(31,24) = entry.cd_nop_ack_value_fc;

	/** After a disconnect nop, the decoder is expected to initiate\
		a disconnect sequence
	*/
	if(csr_retry.read())
		expect_cd_initiate_retry_disconnect = 4;
	else
		expect_cd_initiate_nonretry_disconnect_lk = 4;
	send_dword(dword,true,true);
	if(csr_retry.read()){
		calculate_crc1(dword,true,true);
		send_dword(~crc1,true,false);
		crc1 = 0xFFFFFFFF;
	}
}

void decoder_l2_tb::nop_info_validation(){
	while(!error){
		//Start by checking the standard nop information

		//Check that entries in the queue are not simply being accumulated without
		//ever being used
		if(nop_queue.size() > 4){
			displayError("ERROR: Nop data not sent"); continue;
		}

		//When the command decoder says that nop is received, check the validity of the information
		if(cd_nop_received_fc.read()){
			if(nop_queue.empty()){
				displayError("ERROR: Nop data was not sent"); continue;
			}
			if(cd_nopinfo_fc.read() != nop_queue.front().cd_nopinfo_fc ||
				cd_nop_ack_value_fc.read() != nop_queue.front().cd_nop_ack_value_fc)
			{
				displayError("ERROR: Invalid nop data content"); continue;
			}
			nop_queue.pop_front();
		}

		//Check the next packet to ack value
		if(cd_rx_next_pkt_to_ack_fc.size() > 4){
			displayError("ERROR: next_pkt_to_ack value not udpated correctly"); continue;
		}
		if(!ack_value.empty()){
			if(ack_value.front() == cd_nop_ack_value_fc.read()){
				ack_value.pop_front();
			}
			else if(ack_value.front() != (cd_nop_ack_value_fc.read() + 1)){
				displayError("ERROR: Invalid next_pkt_to_ack value"); continue;
			}
		}

		wait();
	}
}

void decoder_l2_tb::databuffer_validation(){
	//Some default values
	last_databuffer_address = 0;
	db_address_cd = rand();
	int pos_in_entry = 0;
	delayed_start_writing_data = false;
	delayed_start_writing_data2 = false;
	delayed_start_writing_data3 = false;
	writing_data = false;

	while(!error){
		//Store cd_getaddr_db with different degrees of delay.  It will be used to verify
		//the data pending signal later on
		delayed_start_writing_data = cd_getaddr_db.read();
		delayed_start_writing_data2 = delayed_start_writing_data;
		delayed_start_writing_data3 = delayed_start_writing_data2;

		//Check that entries in the queue are not simply being accumulated without
		//ever being used
		if(databuffer_queue.size() > 2){
			displayError("ERROR: Data not sent to databuffer"); continue;
		}

		//When the command decoder starts writing a data packet to the databuffer
		if(cd_getaddr_db.read()){
			/** Check that this is a correct behavior
			*/
			if(writing_data.read()){
				displayError("ERROR: Last data entry not finished"); continue;
			}
			if(databuffer_queue.empty()){
				displayError("ERROR: Data entry requested"); continue;
			}
			if(databuffer_queue.front().address_requested){
				displayError("ERROR: Data address already requested"); continue;
			}
			if(databuffer_queue.front().vc != cd_vctype_db.read()){
				displayError("ERROR: Wrong VC requested in databuffer"); continue;
			}
			if(databuffer_queue.front().size != cd_datalen_db.read()){
				displayError("ERROR: Wrong data length requested"); continue;
			}
			//modify the entry in the queue so that we know that an address has been requested
			databuffer_queue.front().address_requested = true;
			last_databuffer_address = db_address_cd.read();
			db_address_cd = rand();
			writing_data = true;
			pos_in_entry = 0;
		}
		
		//When command decoder writing to databuffer, check that correct data is written
		if(cd_write_db.read()){
			if(!writing_data.read()){
				displayError("ERROR: Unexpected data write"); continue;
			}
			if(sc_uint<32>(databuffer_queue.front().data[pos_in_entry++]) !=
				cd_data_db.read())
			{
				displayError("ERROR: Wrong data received"); continue;
			}
			if(pos_in_entry > databuffer_queue.front().size){
				databuffer_queue.pop_front();
				writing_data = false;
			}
		}

		wait();
	}
}

void decoder_l2_tb::disconnect_retry_validation(){
	expect_cd_initiate_retry_disconnect = 0;
	expect_cd_received_stomped_csr = 0;
	expect_cd_initiate_nonretry_disconnect_lk = 0;

	while(!error){
		//Check if cd_initiate_retry_disconnect is expected to be asserted
		if(expect_cd_initiate_retry_disconnect > 0){
			//Reduce the count of cycles left before it must be asserted
			expect_cd_initiate_retry_disconnect--;

			//Remove the expected flag if it becomes asserted
			if(cd_initiate_retry_disconnect.read()){
				expect_cd_initiate_retry_disconnect = 0;
			}
			//If the count goes down to 0, give an error (timeout)
			else if(!expect_cd_initiate_retry_disconnect){
				displayError("ERROR: cd_initiate_retry_disconnect not asserted"); continue;				
			}
		}
		//If it is unexpectedly asserted, display error
		else if(cd_initiate_retry_disconnect.read()){
			displayError("ERROR: cd_initiate_retry_disconnect asserted"); continue;
		}

		//Check if cd_received_stomped_csr is expected to be asserted
		if(expect_cd_received_stomped_csr > 0){
			//Reduce the count of cycles left before it must be asserted
			expect_cd_received_stomped_csr--;

			//Remove the expected flag if it becomes asserted
			if(cd_received_stomped_csr.read()){
				expect_cd_received_stomped_csr = 0;
			}
			//If the count goes down to 0, give an error (timeout)
			else if(!expect_cd_received_stomped_csr){
				displayError("ERROR: cd_received_stomped_csr not asserted"); continue;				
			}
		}
		//If it is unexpectedly asserted, display error
		else if(cd_received_stomped_csr.read()){
			displayError("ERROR: cd_received_stomped_csr asserted"); continue;
		}

		//Check if cd_initiate_nonretry_disconnect_lk is expected to be asserted
		if(expect_cd_initiate_nonretry_disconnect_lk > 0){
			//Reduce the count of cycles left before it must be asserted
			expect_cd_initiate_nonretry_disconnect_lk--;

			//Remove the expected flag if it becomes asserted
			if(cd_initiate_nonretry_disconnect_lk.read()){
				expect_cd_initiate_nonretry_disconnect_lk = 0;
			}
			//If the count goes down to 0, give an error (timeout)
			else if(!expect_cd_initiate_nonretry_disconnect_lk){
				displayError("ERROR: cd_initiate_nonretry_disconnect_lk not asserted"); continue;				
			}
		}
		//If it is unexpectedly asserted, display error
		else if(cd_initiate_nonretry_disconnect_lk.read()){
			displayError("ERROR: cd_initiate_nonretry_disconnect_lk asserted"); continue;
		}

		wait();
	}

}

void decoder_l2_tb::reordering_validation(){
	//There is no data pending at the beggining
	sc_uint<BUFFERS_ADDRESS_WIDTH> pending_data_address;
	bool data_pending = false;

	while(!error){
		//Check that entries in the queue are not simply being accumulated without
		//ever being used
		if(reordering_queue.size() > 4){
			displayError("ERROR: Packets not sent to reordering"); continue;
		}

		//If packet is sent to reordering
		if(cd_available_ro.read()){
			//Check that there is a packet in the queue to avoid reading from an empty
			//queue if the decoder is not working correctly
			if(reordering_queue.empty()){
				ostringstream o;
				o << "ERROR: Unexpected command packet received: " << 
					cd_packet_ro.read().packet.to_string(SC_HEX);
				displayError(o.str().c_str()); continue;
			}

			//Check that the packet matches the entry in the front of the queue
			if(reordering_queue.front().pkt.packet != cd_packet_ro.read().packet ||
				reordering_queue.front().pkt.error64BitExtension != cd_packet_ro.read().error64BitExtension)
			{
				displayError("ERROR: Invalid command packet received"); continue;
			}

			//Check that the address of the data is correct (if apliccable)
			if(reordering_queue.front().has_data &&
				cd_packet_ro.read().data_address != last_databuffer_address)
			{
				displayError("ERROR: Invalid data address in packet sent to command buffers"); continue;
			}

			//Store what should be the pending data address for this packet
			pending_data_address = last_databuffer_address;
			//Remove it from the queue
			reordering_queue.pop_front();
		}

		if(cd_data_pending_ro.read() != data_pending)
		{
			displayError("ERROR: cd_data_pending_ro has wrong value"); continue;
		}

		/**
			Calculate if the decoder should advertise data pending.
				Rules : 
				 -No data pending when retry mode is active (csr_retry)
				 -It starts after a delay of getting address from
				  databuffer (delayed_start_writing_data2)
				 -It stays pending (data_pending) until a next command
				  packet is received (CTL available from link)
		*/
		data_pending = (data_pending && 
			!(lk_lctl_cd.read() && lk_available_cd.read() && !writing_data.read())
			|| (delayed_start_writing_data2.read())) && !csr_retry.read();

		if(cd_data_pending_ro.read() && 
			pending_data_address != cd_data_pending_addr_ro.read())
		{
			displayError("ERROR: invalid pending data address value"); continue;
		}
		wait();
	}
}

void decoder_l2_tb::displayError(const char * error_message){
	cout << error_message << endl;
	error = true;
	resetx = false;
}

void decoder_l2_tb::getRandomVector(sc_bv<32> &vector){
	vector.range(14,0) = sc_uint<15>(rand());
	vector.range(29,15) = sc_uint<15>(rand());
	vector.range(31,30) = sc_uint<2>(rand());
}

void decoder_l2_tb::getRandomVector(sc_bv<64> &vector){
	for(int n = 0; n < 4; n++)
		vector.range(15*(n+1) - 1,15*n) = sc_uint<15>(rand());
	vector.range(63,60) = sc_uint<4>(rand());
}

void decoder_l2_tb::addReorderingEntry(sc_bv<32> &vector,bool hasData){
	sc_bv<64> qword = 0;
	qword.range(31,0) = vector;
	addReorderingEntry(qword,hasData);
}

void decoder_l2_tb::addReorderingEntry(sc_bv<64> &vector,bool hasData){
	ReorderingEntry entry;
	entry.pkt.error64BitExtension = false;
	entry.pkt.packet = vector;
	entry.has_data = hasData;
	reordering_queue.push_back(entry);
}

void decoder_l2_tb::calculate_crc1(sc_bv<32> dword,bool lctl, bool hctl){
	sc_bv<34> data;
	data[33] = hctl;
	data.range(32,17) = dword.range(31,16);
	data[16] = lctl;
	data.range(15,0) = dword.range(15,0);
	calculate_crc(crc1,data);
}

void decoder_l2_tb::calculate_crc2(sc_bv<32> dword,bool lctl, bool hctl){
	sc_bv<34> data;
	data[33] = hctl;
	data.range(32,17) = dword.range(31,16);
	data[16] = lctl;
	data.range(15,0) = dword.range(15,0);
	calculate_crc(crc2,data);
}

void decoder_l2_tb::calculate_crc(unsigned &crc,sc_bv<34> &data){
	static unsigned poly = 0x04C11DB7;

	for(int i = 0; i < 34; i++){
		/* xor highest bit w/ message: */
		unsigned tmp = ((crc >> 31) & 1) ^ ( ((sc_bit)data[i]) ? 1 : 0);

		/* substract poly if greater: */
		crc = (tmp) ? (crc << 1) ^ poly : ((crc << 1) | tmp);
	}
}
