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
 *   Jean-Francois Belanger
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

#ifndef HISTORY_BUFFER_L3_H
#define HISTORY_BUFFER_L3_H

#include "../core_synth/synth_datatypes.h"	
#include "../core_synth/constants.h"


///Keeps track of the history of sent packets
/**
	@class history_buffer_l3
	@author Ami Castonguay
	@description

	The retry mode allows to attach a CRC to every packet.  If
	a packet is corrupted, the packet can simply be resent.  To
	be able to be resent, sent packets must be stored in a buffer.
	
	This sub-module takes care of managing the content of such
	a buffer.  This buffer is made to be used with a dual-port
	memory (one read port, one write port).
	 
	To keep track of the content of the buffer, a simple read pointer
	and a write pointer is kept.  When a new entry is created, a first
	dword is written in the memory which containes the tracking number
	and the size of the entry : this is the entry header.

	When a ack is received, the read pointer jumps from entry headers to
	the next entry header until either the ack number is reached or
	that the read pointer has reached the write pointer.

	The content of a header is :
		dword[7..0]  : ack value
		dword[12..8] : size of entry

	During retry playback, all that is stored in the history buffer will
	simply be resent.
*/
class history_buffer_l3 : public sc_module
{
	public:

	///The possible internal state of the history buffer
	enum HISTORY_STATES {
		IDLE_STATE,	HISTORY_PLAYBACK};


	///The write pointer in the buffer
	sc_signal<sc_uint<LOG2_HISTORY_MEMORY_SIZE> > write_pointer;
	///Next value of ::write_pointer
	sc_signal<sc_uint<LOG2_HISTORY_MEMORY_SIZE> > next_write_pointer;

	///The write stop pointer is the last position of the current entry.
	/**When the write pointer reaches the write_stop_pointer and the last
		dword is written, the NextPktToAck is incremented*/
	sc_signal<sc_uint<LOG2_HISTORY_MEMORY_SIZE> > write_stop_pointer;
	///Next value of ::write_stop_pointer
	sc_signal<sc_uint<LOG2_HISTORY_MEMORY_SIZE> > next_write_stop_pointer;

	///The begginning of the current entry
	/** If a packet entry is cancelled, it will revert to this pos.*/
	sc_signal<sc_uint<LOG2_HISTORY_MEMORY_SIZE> > entry_write_start_pointer;
	///Next value of ::entry_write_start_pointer
	sc_signal<sc_uint<LOG2_HISTORY_MEMORY_SIZE> > next_entry_write_start_pointer;

	///The pointer to keep track of where to start reading if a playback is started
	/** When acks are received, this read pointer will be updated to a correct position*/
	sc_signal<sc_uint<LOG2_HISTORY_MEMORY_SIZE> > idle_read_pointer;
	///Next value of ::idle_read_pointer
	sc_signal<sc_uint<LOG2_HISTORY_MEMORY_SIZE> > next_idle_read_pointer;

	///Read pointer that will increment during history playback
	/** When history playback is started, it is set at idle_read_pointer value, then it is
		incremented until entry_write_start_pointer is reached */
	sc_signal<sc_uint<LOG2_HISTORY_MEMORY_SIZE> > playback_read_pointer;
	///Next value of ::playback_read_pointer
	sc_signal<sc_uint<LOG2_HISTORY_MEMORY_SIZE> > next_playback_read_pointer;

	///The count value we are waiting to be acknoledged
	/**
		The best way to understand this is to read the HT doc on this.
		This is initialized at 0 at reset, so the first packet to be stored
		in the history is tagged with the value 1 and TxNextPktToAck takes
		on that same value.
		
		So in that example, #1 is the next packet that needs to be acked, hence the
		name TxNextPktToAck.  When we receive an ack value of 1, we can free
		that packet's entry.
	*/
	sc_signal<sc_uint<8> >	TxNextPktToAck;
	///Next value of ::TxNextPktToAck
	sc_signal<sc_uint<8> >	next_TxNextPktToAck;

	///Registered value of what is received from nop
	/** This will not be identical to the value coming from the decoder
		since this variable is only updated when the nop is validated, while
		the value from the nop is updated as soon as */
	sc_signal<sc_uint<8> >	received_RxNextPktToAck;
	///Next value of ::received_RxNextPktToAck
	sc_signal<sc_uint<8> >	next_received_RxNextPktToAck;

	///Tracks how many reads are left to an entry during playback
	/** This is necessary to be able to recognize where are the headers and not
		send them as normal data*/
	sc_signal<sc_uint<5> > playback_count;
	///Next value of ::playback_count
	sc_signal<sc_uint<5> > next_playback_count;
	
	
	///The state of the state machine
	sc_signal<HISTORY_STATES>	state;
	///Next value of ::state
	sc_signal<HISTORY_STATES>	next_state;

	///Next value of ::history_playback_ready
	sc_signal<bool>	next_history_playback_ready;
	///Next value of ::history_playback_done
	sc_signal<bool>	next_history_playback_done;

	/**If the data from memory corresponds to the content in memory.
	  It has value false when something is written to memory at the read pointer.*/
	sc_signal<bool>	valid_memory_data;

	sc_signal<bool>	last_cycle_new_history_entry;
	sc_signal<sc_uint<5> >	last_cycle_new_history_entry_size_m1;

	///The output dword when playing back history
	sc_out <sc_bv<32> > history_packet;
	///When the complete history has finished playing back
	sc_out <bool > history_playback_done;
	///To begin the playback of the history from the last acked packet
	sc_in <bool > begin_history_playback;
	///To stop the playback of the history if the retry sequence is aborted
	sc_in <bool > stop_history_playback;
	///If the playback of the history is ready, begin will be ignored when not asserted
	sc_out <bool > history_playback_ready;
	///To consume the data produced by the history buffer
	/**A minimum pause of 1 cycle must be left between entries (to allow
		history entry header to be read) before starting to read a next entry.
		An entry is composed of the command and it's data.  Usually this should
		be natural since the CRC must be sent after an entry is sent.*/
	sc_in <bool > consume_history;
	///If there is enough room left in the history for another maximum size packet
	/*to allow the flow control to know if a packet can be sent, maximum size is 18 dwords*/
	sc_out <bool > room_available_in_history;
	///To add a dword to the history
	sc_in <bool > add_to_history;
#ifdef PERMIT_CANCEL_HISTORY
	///To cancel a history_entry (like when there's an stomped packet sent)
	/** An entry MUST be canceled before a new one can be started.  Since this
		is only necessary in a cut-through implementation, which at the time of
		making this module was not an option for the HT design, it is only enable
		by using a preprocessor define
	*/
	sc_in <bool > cancel_history_entry;
#endif
	///To add a new entry to the history, to be done before starting to add to the history
	sc_in <bool > new_history_entry;
	///The size (minus 1) of the new history entry
	sc_in <sc_uint<5> > new_history_entry_size_m1;
	
	///dword being sent to the link, so it can be stored in the buffer
	sc_in<sc_bv<32> > mux_registered_output;

	///When a nop was received : read the new ack_value
	sc_in<bool>	nop_received;
	///The value acked from the next HT node
	sc_in<sc_uint<8> >	ack_value;

	///Reset
	sc_in<bool>	resetx;
	///Clock
	sc_in<bool> clk;

	//////////////////////////////////////////
	//	Memory interface - synchronous
	/////////////////////////////////////////

	sc_out<bool> history_memory_write;///<Write to history memory
	sc_out<sc_uint<LOG2_HISTORY_MEMORY_SIZE> > history_memory_write_address;///<Address where to write in history memory
	sc_out<sc_bv<32> > history_memory_write_data;///<Data to write to history memory
	sc_out<sc_uint<LOG2_HISTORY_MEMORY_SIZE> > history_memory_read_address;///<Address where to read in history memory
	sc_in<sc_bv<32> > history_memory_output;///<Data read in history memory

	///SystemC Macro
	SC_HAS_PROCESS(history_buffer_l3);

	//Constructor
	history_buffer_l3(sc_module_name name);
	///Everything that is registered
	void clocked_process();

	///Process that handle writing to the memory to store retry entries
	void write_in_memory();
	///Process that handles reading the memory for playback and to delete acked entries
	void read_in_memory();
};

#endif
