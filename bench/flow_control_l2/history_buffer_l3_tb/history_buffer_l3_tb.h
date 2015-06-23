//history_buffer_l3.h
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
#ifndef HISTORY_BUFFER_L3_TB_H
#define HISTORY_BUFFER_L3_TB_H

#include "../../../rtl/systemc/core_synth/synth_datatypes.h"
#include <deque>
#include <string>



class history_buffer_l3_tb : public sc_module{

	struct RetryEntry{
		int size;
		int identification;
		int	dwords[18];
	};

public:

	///The output dword when playing back history
	sc_in <sc_bv<32> > history_packet;
	///When the complete history has finished playing back
	sc_in <bool > history_playback_done;
	///To begin the playback of the history from the last acked packet
	sc_out <bool > begin_history_playback;
	///If the playback of the history is ready
	sc_in <bool > history_playback_ready;
	///To consume the data produced by the history buffer
	sc_out <bool > consume_history;
	///The room left in the history, to allow the flow control to know if a packet can be sent
	sc_in <bool > room_available_in_history;
	///To add a dword to the history
	sc_out <bool > add_to_history;
	///To add a new entry to the history, to be done before starting to add to the history
	sc_out <bool > new_history_entry;
	///The size (minus 1) of the new history entry
	sc_out <sc_uint<5> > new_history_entry_size_m1;
	
	///dword being sent to the link, so it can be stored in the buffer
	sc_out<sc_bv<32> > fc_dword_lk;

	///When a nop was received : read the new ack_value
	sc_out<bool>	nop_received;
	///The value acked from the next HT node
	sc_out<sc_uint<8> >	ack_value;

	///Reset
	sc_out<bool>	resetx;

	///Clock
	sc_in<bool> clk;

	//////////////////////////////////////////
	//	Memory interface - synchronous
	/////////////////////////////////////////

	sc_in<bool> history_memory_write;
	sc_in<sc_uint<LOG2_HISTORY_MEMORY_SIZE> > history_memory_write_address;
	sc_in<sc_bv<32> > history_memory_write_data;
	sc_in<sc_uint<LOG2_HISTORY_MEMORY_SIZE> > history_memory_read_address;
	sc_out<sc_bv<32> > history_memory_output;

	///SystemC Macro	
	SC_HAS_PROCESS(history_buffer_l3_tb);

	///Consctructor
	history_buffer_l3_tb(sc_module_name name);

	///The memory that is accessed through the synchronous memory interface
	unsigned int history_memory[HISTORY_MEMORY_SIZE];

	///Takes care of writing and reading to memory
	void simulate_memory();

	///This is the main thread that stimulates the design to test it
	/** Other functinos are called from here*/
	void stimulus();

	///Plays back all the history and verifies that it is correct
	void playback_history();

	///Ack a certain number of packets that are in the history
	/** Acked packets are not played back in a replay sequence
		@param number The number of packets to ack
	*/
	void ack_packets(int number);

	///Sends random packet to store in the history buffer
	/** Warning : Does not check for memory overflow
	@param number The number of packets to send in history
	*/
	void send_random_packets(int number);

	///Generate a random entry (packet) to store in the history
	void generateRandomEntry(RetryEntry * e);

	///A software kept version of the history for comparison purpose
	std::deque<RetryEntry> simulated_history;

	///Number of elements stored in the history
	int current_history_size;
	
	///What the ack number for packets being written
	/** Increased whenever a packet is written to the buffer
	*/
	int write_ack_number;
	///What packets have beem acked
	/** Incremented whenever packets are acked
	*/
	int read_ack_number;

	///Simulated position of the write pointer of the history module
	int internal_write_pos;

};

///An exception class thrown when an error is detected
class SimulationException{
public:
	std::string data;
	SimulationException(std::string msg) : data(msg) {}
};

#endif

