//history_buffer_l3.cpp

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

#include "history_buffer_l3.h"


history_buffer_l3::history_buffer_l3(sc_module_name name) : sc_module(name)
{
	SC_METHOD(clocked_process);
	sensitive_neg(resetx);
	sensitive_pos(clk);

	SC_METHOD(write_in_memory);
	sensitive <<
		TxNextPktToAck <<
		entry_write_start_pointer <<
		new_history_entry <<
		add_to_history <<
		new_history_entry_size_m1 <<
		write_pointer <<
		mux_registered_output <<
		add_to_history <<
		write_stop_pointer
#ifdef PERMIT_CANCEL_HISTORY
		<< cancel_history_entry
#endif
		;

	SC_METHOD(read_in_memory);
	sensitive <<
		state <<
		idle_read_pointer <<
		playback_read_pointer <<
		valid_memory_data <<
		received_RxNextPktToAck <<
		history_memory_output <<
		entry_write_start_pointer <<
		begin_history_playback <<
		stop_history_playback <<
		consume_history <<
		playback_count;
}

void history_buffer_l3::clocked_process(){
	//Upon reset
	if(resetx.read() == false){
		state = IDLE_STATE;
		idle_read_pointer = 0;
		playback_read_pointer = 0;
		history_playback_ready = false;
		playback_count = 0;
		history_playback_done = true;
		TxNextPktToAck = 0;
		received_RxNextPktToAck = 0;
		entry_write_start_pointer = 0;
		room_available_in_history = true;
		valid_memory_data = false;
		write_pointer = 0;
		write_stop_pointer = 0;

		last_cycle_new_history_entry = false;
		last_cycle_new_history_entry_size_m1 = 0;
	}
	else{
		state = next_state;
		idle_read_pointer = next_idle_read_pointer;
		playback_read_pointer = next_playback_read_pointer;
		history_playback_ready = next_history_playback_ready;
		playback_count = next_playback_count;
		history_playback_done = next_history_playback_done;
		TxNextPktToAck = next_TxNextPktToAck;
		entry_write_start_pointer = next_entry_write_start_pointer;
		write_stop_pointer = next_write_stop_pointer;
		write_pointer = next_write_pointer;

		//When a nop is received, store it's ack value
		if(nop_received)
			received_RxNextPktToAck = ack_value;

		//Look at how much room is available in the memory
		sc_uint<LOG2_HISTORY_MEMORY_SIZE> size = idle_read_pointer.read() - write_pointer.read();

		//The maximum packet size is 16 data + 2 dwords of command = 18.  To advertise that
		//we have room, we check if we have more than 18 dwords in memory.  We check for
		//"MORE" instead of "equal or more" because we need to make sure that we never fill
		//the last position in memory, which would make the write and read pointer equal,
		//which is not handled in the code
		room_available_in_history = (size.range(LOG2_HISTORY_MEMORY_SIZE - 1,0) > 18) ||
			idle_read_pointer.read() == write_pointer.read();

		//Memory output is not valid if a write was just done to it
		valid_memory_data = 
			! (history_memory_read_address.read() == history_memory_write_address.read() 
				&& history_memory_write.read());

		last_cycle_new_history_entry = new_history_entry.read();
		last_cycle_new_history_entry_size_m1 = new_history_entry_size_m1.read();

	}
}
	
		
/**
	When new data is received or a new entry is started, this process handles writing 
	the correct data in the history memory.
 */
void history_buffer_l3::write_in_memory(){
	next_TxNextPktToAck = TxNextPktToAck;
	next_write_stop_pointer = write_stop_pointer;
	next_entry_write_start_pointer = entry_write_start_pointer;

	//Write in the memory if it's a new entry, or if it's a new dword to add to an entry
	bool write = new_history_entry.read() || add_to_history.read();
	history_memory_write = write;

	sc_uint<8> TxNextPktToAck_p1 = TxNextPktToAck.read() + 1;

	//If a new entry, write the HEADER of that entry
	if(new_history_entry.read()){
		sc_uint<32> data_to_write = 0;
		data_to_write.range(7,0) = TxNextPktToAck;

		sc_uint<5> size = new_history_entry_size_m1.read() + 1;
		data_to_write.range(12,8) = size;
		//See next_write_stop_pointer below, commented for freq speedup
		//next_write_stop_pointer = new_history_entry_size_m1.read() + write_pointer.read() + 1;

		history_memory_write_data = data_to_write;
	}
	//else, send the data received at the input.  It will only be written if
	//add_to_history is true.
	else{
		history_memory_write_data = mux_registered_output.read();
	}

	//The adder to find the next value of next_write_stop_pointer is a freq bottleneck,
	//so delay one cycle its calculation
	sc_uint<7> current_write_stop_pointer;
	if(last_cycle_new_history_entry.read()){
		//No + 1 because write_pointer was incremented last cycle
		current_write_stop_pointer = last_cycle_new_history_entry_size_m1.read() + write_pointer.read();
	}
	else{
		current_write_stop_pointer = write_stop_pointer.read();
	}
	next_write_stop_pointer = current_write_stop_pointer;


	//Calculate the value of write_pointer + 1, will be useful later on
	sc_uint<LOG2_HISTORY_MEMORY_SIZE> write_pointer_p1 = write_pointer.read() + 1;

	//If it is the last write of the entry, update the next start write pointer and
	//ack value
	if(add_to_history.read() && current_write_stop_pointer == write_pointer.read()){
		next_TxNextPktToAck = TxNextPktToAck_p1;
		next_entry_write_start_pointer = write_pointer_p1;
	}

#ifdef PERMIT_CANCEL_HISTORY
	//If an entry is canceled, simply bring back the write pointer to the entry start
	if(cancel_history_entry.read())
		next_write_pointer = entry_write_start_pointer;
	else 
#endif
	//Everytime there is a write, increase the write pointer
	if(write)
		next_write_pointer = write_pointer_p1;
	else
		next_write_pointer = write_pointer;

	//Make sure the write address matches the pointer
	history_memory_write_address = write_pointer;
}

/**
	This process handles reading the memory.  When we are not in a retry sequence, it
	will update the read pointer to the latest acked packet from the other side, effectively
	freeing room to write new packets.  When in retry mode, it reads the data in the buffers
	until all packets have been read.
 */
void history_buffer_l3::read_in_memory(){
	next_state = state;
	next_idle_read_pointer = idle_read_pointer;
	next_history_playback_ready = false;
	next_playback_count = 0;

	sc_uint<LOG2_HISTORY_MEMORY_SIZE> next_idle_read_pointer_tmp = idle_read_pointer.read();

	switch(state){
	/** The IDLE_STATE is the normal state when we simply store new packets
		in the history.
	*/
	case IDLE_STATE:

		next_history_playback_done = true;

		//If there is a request to playback history, change state
		//When there is an update to the received RxCounter from the next node, update
		//the read pointer.  While it's updated, we're not ready to start a playback
		if(valid_memory_data){
			if(received_RxNextPktToAck != (sc_uint<8>)(sc_bv<8>)history_memory_output.read().range(7,0) &&
				/* This next part assumes that the write_pointer can NEVER be equal to the
					read pointer when the buffer is full.*/
				idle_read_pointer.read() != entry_write_start_pointer.read())
			{
				next_idle_read_pointer_tmp = idle_read_pointer.read() + 
					(sc_uint<5>)(sc_bv<5>)history_memory_output.read().range(12,8) + 1;
			}
			else if(begin_history_playback.read()){
				//When there is no history to playback, activate both ready and done
				if(playback_read_pointer.read() == entry_write_start_pointer.read())
					next_history_playback_ready = true;
				else{
					next_state = HISTORY_PLAYBACK;
					next_history_playback_done = false;
				}
			}
		}

		history_memory_read_address = next_idle_read_pointer_tmp;
		next_playback_read_pointer = next_idle_read_pointer_tmp;

		break;
	default:
	//case HISTORY_PLAYBACK:
		next_history_playback_ready = true;
		next_history_playback_done = false;

		sc_uint<LOG2_HISTORY_MEMORY_SIZE> next_playback_read_pointer_tmp = playback_read_pointer;

		/** If playback is stopped, for example because an error occured while playing
		back history, go back to idle state*/
		if(stop_history_playback.read()){
			next_history_playback_done = true;
			next_state = IDLE_STATE;
			next_playback_read_pointer_tmp = idle_read_pointer.read();
		}
		/** playback_count is the number of dwords left to send.  When it reaches 0,
			we start playing back another entry, unless we're done*/
		else if(playback_count.read() == 0){
			//If the read pointer reaches the write pointer, we're done and go back to idle state
			if(playback_read_pointer.read() == entry_write_start_pointer.read()){
				next_history_playback_done = true;
				next_state = IDLE_STATE;
				next_playback_read_pointer_tmp = idle_read_pointer.read();
			}
			/** Otherwise, read the entry size to update the playback_count and increase read pointer*/
			else{
				next_playback_count = (sc_uint<8>)(sc_bv<8>)history_memory_output.read().range(12,8);
				next_playback_read_pointer_tmp = playback_read_pointer.read() + 1;
			}
		}
		/** When playing back an entry and the data is consumed, decrease playback_count and
			increas playback_read_pointer*/
		else if(consume_history.read()){
			next_playback_count = playback_count.read() - 1;
			next_playback_read_pointer_tmp = playback_read_pointer.read() + 1;
		}
		else{
			next_playback_count = playback_count.read();
		}

		//Update the addresses to the read pointers
		history_memory_read_address = next_playback_read_pointer_tmp;
		next_playback_read_pointer = next_playback_read_pointer_tmp;
	}

	next_idle_read_pointer = next_idle_read_pointer_tmp;
	history_packet = history_memory_output;
}

