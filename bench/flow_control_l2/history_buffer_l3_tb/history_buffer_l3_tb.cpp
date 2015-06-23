//history_buffer_l3_tb.cpp
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

#include "history_buffer_l3_tb.h"
#include "../../../rtl/systemc/flow_control_l2/history_buffer_l3.h"
#include <cstdlib>
#include <sstream>

using namespace std;

history_buffer_l3_tb::history_buffer_l3_tb(sc_module_name name) : sc_module(name){
	SC_THREAD(simulate_memory);
	sensitive_pos(clk);

	SC_THREAD(stimulus);
	sensitive_pos(clk);

	srand(8955);
	write_ack_number = 0;
	read_ack_number = 0;
	current_history_size = 0;
	internal_write_pos = 0;
}

void history_buffer_l3_tb::simulate_memory(){
	while(true){
		wait();
		if(history_memory_read_address.read() >= HISTORY_MEMORY_SIZE){
			cout << "Error, read address outside valid range" << endl;
			break;
		}
		history_memory_output = (sc_uint<32>)history_memory[history_memory_read_address.read()];

		if(history_memory_write.read()){
			if(history_memory_write_address.read() >= HISTORY_MEMORY_SIZE){
				cout << "Error, write address outside valid range" << endl;
				break;
			}
			history_memory[history_memory_write_address.read()] = 
				(unsigned)(sc_uint<32>)history_memory_write_data.read();
		}
	}
}

/*
	sc_in <sc_bv<32> > history_packet;
	sc_in <bool > history_playback_done;
	sc_in <bool > room_available_in_history;
	sc_in <bool > history_playback_ready;
  
	sc_out <bool > consume_history;
	sc_out <bool > begin_history_playback;
	sc_out <bool > add_to_history;
	sc_out <bool > new_history_entry;
	sc_out <sc_uint<5> > new_history_entry_size_m1;
	sc_out<sc_bv<32> > fc_dword_lk;
	sc_out<bool>	nop_received;
	sc_out<sc_uint<8> >	ack_value;

	sc_out<bool>	resetx;
*/

void history_buffer_l3_tb::stimulus(){
	consume_history = false;
	begin_history_playback = false;
	add_to_history = false;
	new_history_entry = false;
	new_history_entry_size_m1 = 0;
	fc_dword_lk = 0;
	nop_received = false;
	write_ack_number = 0;
	read_ack_number = 0;


	///////////////////////////////////
	// Test two short retry sequences
	///////////////////////////////////
	resetx = false;

	for(int n = 0; n < 3; n++) wait();
	resetx = true;

	try{
		send_random_packets(4);
		ack_packets(2);
		send_random_packets(2);
		ack_packets(1);
		send_random_packets(2);
		ack_packets(3);

		playback_history();

		ack_packets(1);
		send_random_packets(4);
		ack_packets(3);

		ack_packets(1);

		while(internal_write_pos > 18){
			send_random_packets(1);
		}

		playback_history();

		///////////////////////////////////
		// Test room_available_in_history
		///////////////////////////////////

		while((HISTORY_MEMORY_SIZE - current_history_size) > 18){
			if(!room_available_in_history.read()){
				cout << "HISTORY_MEMORY_SIZE: " << HISTORY_MEMORY_SIZE << endl;
				cout << "current_history_size: " << current_history_size << endl;
				throw SimulationException(
				"room_available_in_history is false when it should be true");
			}
			send_random_packets(1);
			
		}
		if(room_available_in_history.read())
			throw SimulationException(
			"room_available_in_history is true when it should be false");

		cout << "SIMULATION COMPLETE" << endl;
	}
	catch(SimulationException se){
		cout << se.data << endl;
	}
}

void history_buffer_l3_tb::playback_history(){

	//Begin playback
	begin_history_playback = true;
	wait();

	//Wait for the history to be ready for playback
	int max_time = 32;
	while(!history_playback_ready.read()){
		if(max_time-- == 0){
			throw SimulationException("Error, playback did not get ready");
		}
		wait();
	}
	begin_history_playback = false;

	//Read and check packets in history
	RetryEntry entry;
	for(std::deque<RetryEntry>::iterator i = simulated_history.begin();
		i != simulated_history.end();i++)
	{
		entry = *i;
		int pos = 0;
		while(pos != entry.size){
			if(history_playback_done.read()){
				throw SimulationException(
					"ERROR: History playback done signal asserted before really done");
			}
			if(consume_history.read()){
				if(history_packet.read() != sc_uint<32>(entry.dwords[pos])){
					ostringstream o;
					o << "Error, invalid dword received: " 
						<< history_packet.read().to_string(SC_HEX)
						<< " expected: " << sc_uint<32>(entry.dwords[pos]).to_string(SC_HEX);
					throw SimulationException(o.str());
				}
				pos++;
			}
			consume_history = ((rand() % 10) < 8) && (pos != entry.size);
			wait();
		}
	}

	//Verify the playback done signal
	int max_count = 2;
	while(history_playback_done.read()){
		if(--max_count == 0){
			throw SimulationException(
				"ERROR: History playback done signal not asserted when actually done");
		}
		wait();
	}


}

void history_buffer_l3_tb::ack_packets(int number){
	read_ack_number = (read_ack_number + number) % 256;
	ack_value = read_ack_number;
	nop_received = true;
	wait();
	nop_received = false;
	for(int n = 0; n < number; n++){
		current_history_size -= simulated_history.front().size + 1;
		simulated_history.pop_front();
	}
}


void history_buffer_l3_tb::send_random_packets(int number){
	RetryEntry entry;
	for(int n = 0; n < number; n++){
		generateRandomEntry(&entry);
		simulated_history.push_back(entry);
		new_history_entry = true;
		new_history_entry_size_m1 = entry.size - 1;
		wait();
		new_history_entry = false;

		int dwords_sent = 0;
		while(dwords_sent < entry.size){
			bool send = rand() % 10 < 8;
			add_to_history = send;
			if(send) fc_dword_lk = entry.dwords[dwords_sent++];
			wait();
		}
		add_to_history = false;
		current_history_size += entry.size + 1;
		internal_write_pos = (internal_write_pos + entry.size + 1) % 128;
	}
}


/*
struct RetryEntry{
	int size;
	int identification;
	int	dwords[18];
}

*/
void history_buffer_l3_tb::generateRandomEntry(RetryEntry * e){
	e->size = (rand() % 18) + 1;
	e->identification = ++write_ack_number;
	for(int i = 0; i < e->size; i++){
		//Rand can have a MAX_VALUE as low as 32K on some compilers
		e->dwords[i] = rand() & 0xFFF | 
			((rand() & 0xFFF) << 12) |
			((rand() & 0xFF) << 24);
	}

	//Clear the last to facilitate detecting errors
	for(int i = e->size; i < 18; i++){
		e->dwords[i] = 0;
	}

}
