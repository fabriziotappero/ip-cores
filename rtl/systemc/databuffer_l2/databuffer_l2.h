//databuffer_l2.h

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
 *   Martin Corriveau
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

#ifndef HT_DATABUFFER_H
#define HT_DATABUFFER_H

#include "../core_synth/synth_datatypes.h"
#include "../core_synth/constants.h"



///Buffer to store HyperTransport data packets
/**
	The data buffer is, as it names states, a buffer for the data part
	of the packet.  When a command packet arrives that has data associated,
	the data needs to be stored somewhere while the command packet gets
	decoded, analyzed, stored and sent to the appropriate destination.  Once
	the command packet is sent to a destination (the CSR for example), the
	destination needs to retrieve the data associated with the packet.  There is
	two read ports (accepted and forward) and 3 erase ports (accepted, forward and
	error handler) plus 1 more erase port in retry mode (decoder).

	To allow this, when the command packet is received that has data associated, 
	the "Command decoder" requests a tracking number from the data buffer.
	Then the data starts flowing to the data buffer.  Later, the tracking number
	will allow to retrieve the data when requested by the destination of the
	command packet.The size of the data packet is contained in the command
	packet, so the destination must erase the packet.

	When there is a reset, all the registers tracking the content of the buffers
	and the buffer counts are cleared.  When all the content of a buffer has
	been read from a read port, that entry is also cleared.  Data packets can
	also simply be dropped from the decoder (in retry mode).
	The decoder can activate the drop signal to drop the packet currently being
	received : this can happen when a packet is stomped in retry mode.  Data packets
	can also simply be erased from the accepted and forward ports


	All read ports can  access the databuffer simultaneously, the data
	buffer requires a memory with two read ports and a write port.  In real life, it
	will probably be implemented using two one read port and one write port memory.
	A fast memory might be able to run at higher frequency than the logic.
	if running at 2x the speed of the logic, it could potentialy be done with
	a single one read and one write memory.
*/
class databuffer_l2 : public sc_module
{
	/**Give a number for ports to allow to treat all the ports 
	in for loops*/
	enum InputPorts{ ACCEPTED_PORT = 0, FWD_PORT = 1};


public:
	/// Global system cold reset signal.
	sc_in< bool >								resetx;
	/// LDTSTOP
	sc_in< bool >								ldtstopx;
	/// Global system clock signal.
	sc_in_clk		 							clk;

	/// Command Decoder data.
    sc_in< sc_bv<32> > 							cd_data_db;
	/// Command Decoder data length in dword.
	sc_in< sc_uint<4> > 						cd_datalen_db;
	/// Command Decoder virtual channel of the data
	sc_in< VirtualChannel >						cd_vctype_db;
	/// Command Decoder write request flag
	sc_in< bool > 								cd_write_db;
	/// Command Decoder flag for getting the address of the data
	/**
		This is the signal to start a transfert.  cd_datalen_db is 
		read when this signal is active.  Following the asertion of
		this signal for a single cycle, data can be sent with the use of
		cd_data_db and cd_write_db.
	*/
	sc_in< bool >								cd_getaddr_db;

#ifdef RETRY_MODE_ENABLED
	/// Command Decoder flag for erasing data
	sc_in< bool > 								cd_drop_db;
	///A retry disconnect is initiated by the link
	sc_in< bool > 								lk_initiate_retry_disconnect;
	///A retry disconnect is initiated by the command decoder
	sc_in< bool >								cd_initiate_retry_disconnect;
	///The retry mode is activated
	sc_in< bool >								csr_retry;
#endif
	/// Command Decoder return address of the sent data
	sc_out< sc_uint<BUFFERS_ADDRESS_WIDTH> >	db_address_cd;

	/// Error Handler address of the data to drop
	sc_in< sc_uint<BUFFERS_ADDRESS_WIDTH> >		eh_address_db;
	/// Error Handler virtual channel of the data to drop
	sc_in< VirtualChannel >						eh_vctype_db;
	/// Error Handler flag for erasing data
	sc_in< bool > 								eh_erase_db;

	/// CSR address of data to read
	sc_in< sc_uint<BUFFERS_ADDRESS_WIDTH> >		csr_address_db;
	/// CSR flag to read data
	sc_in< bool > 								csr_read_db;
	/// CSR virtual channel of data to read
	sc_in< VirtualChannel > 					csr_vctype_db;
	/// To erase the packet currently being read
	sc_in< bool >						csr_erase_db;

	/// User Interface address of data to read
	sc_in< sc_uint<BUFFERS_ADDRESS_WIDTH> >		ui_address_db;
	/// User Interface flag to read data
	sc_in< bool > 								ui_read_db;
	/// User Interface virtual channel of data to read
	sc_in< VirtualChannel >						ui_vctype_db;
	/// To erase the packet currently being read
	sc_in< bool >						ui_erase_db;

	/// Data for the accepted destination (shared CSR and UI output)
	/// The output is selected by the ui_grant_csr_access_db signal
	sc_out< sc_bv<32> >							db_data_accepted;

	/// Forward address of data to read
	sc_in< sc_uint<BUFFERS_ADDRESS_WIDTH> >		fwd_address_db;
	/// Forward flag to read data
	sc_in< bool > 								fwd_read_db;
	/// Forward virtual channel of data to read
	sc_in< VirtualChannel >						fwd_vctype_db;
	/// Forward return data 
	sc_out< sc_bv<32> >							db_data_fwd;
	/// Forward return flag meaning the last data forming the packet
	sc_in< bool >								fwd_erase_db;

	/// Flow Control flag meaning a NOP packet was sent
	/**
		Signal activated when db_buffer_cnt_fc is being read.  Should
		probably read fc_sending_nop instead as it is not activated after
		the nop is sent.
	*/
	sc_in< bool >								fc_nop_sent;
	/// Flow Control return free buffers counters since last NOP request
	/// [5,4]: nonposted;  [3,2]: response. [1,0]: posted;
	sc_out< sc_bv<6> >							db_buffer_cnt_fc;
	/// Flow Control return flag for a request of a NOP packet.
	sc_out< bool >								db_nop_req_fc;
	///Activated when we receive more data than we can store
	sc_out< bool >								db_overflow_csr;

	//By default, the accepted port is for the UI.  When the UI grants the right
	//of access to the CSR, it becomes the CSR's right.  The grant signal is read
	//to know what data to output.
	sc_in<bool> ui_grant_csr_access_db;



	////////////////////////////////////
	//Interface to memory - synchronous
	////////////////////////////////////

	sc_out<bool> memory_write;///<Write signal for databuffer memory
	sc_out<sc_uint<2> > memory_write_address_vc;///<MSB address where to write in databuffer memory (values 0 to 2)
	sc_out<sc_uint<BUFFERS_ADDRESS_WIDTH> > 
		memory_write_address_buffer;///< Center address for where to write in databuffer memory
	sc_out<sc_uint<4> > memory_write_address_pos;///<LSB address where to write in databuffer memory
	sc_out<sc_bv<32> > memory_write_data;///<Data to write in databuffer memory
	
	sc_out<sc_uint<2> > memory_read_address_vc[2];///<MSB address where to read in databuffer memory (values 0 to 2)
	sc_out<sc_uint<BUFFERS_ADDRESS_WIDTH> >
		memory_read_address_buffer[2];///< Center address for where to read in databuffer memory
	sc_out<sc_uint<4> > memory_read_address_pos[2];///<LSB address where to write in databuffer memory

	sc_in<sc_bv<32> > memory_output[2];///<Data output from read in databuffer memory
	
	
	
	//Virtual channel that we will be outputed
	sc_signal<sc_uint<2> > outputReadVcIndex_s[2];
	//Virtual buffer that we will be outputed
	sc_signal<sc_uint<BUFFERS_ADDRESS_WIDTH> > outputReadAddress_s[2];
	
	///////////////////////////////////////
	//Global variables read on clock edge
	///////////////////////////////////////


public:	
	/// Constructor of the module
	/**
		Constructor of a Data Buffer module.

		@param name Name of the module
	*/
	databuffer_l2( sc_module_name name);

	///SystemC macro fror modules
	SC_HAS_PROCESS(databuffer_l2);

	///Handles registered operations and outputs of the module
	void clockProcess();
	///Takes care of writing to the memory
	void write_memory();
	///Takes care of reading in the memory
	void read_memory();
	///Redirects the memories output to the output of the module
	void redirect_memory_output();


	/** The number of buffers freed for all the VC's is kept in
		bufferFreedNop.  This function is simply a mux that selects
		the bits correspondif to the correct VC.
	*/
	sc_uint<2> getBufferFreedNop(const VirtualChannel  &vc);

	///Determine when to sent 
	/** Taking into account how many buffers could be freed with a nop and how many
		buffers are free currently, it determines if there is need to send a nop to
		notify that the buffers have been freed.

		This algorithm prevents the link from being flooded with NOPs every
		time a buffer is freed.

		@param buffersThatCanBeFreedWithNop_0 The number of buffers that that we can notify
			as being free with a nop for the vc 0
		@param buffersThatCanBeFreedWithNop_1 The number of buffers that that we can notify
			as being free with a nop for the vc 1
		@param buffersThatCanBeFreedWithNop_2 The number of buffers that that we can notify
			as being free with a nop for the vc 2
		@param freeBuffers_0 The number of free buffers in the VC 0
		@param freeBuffers_1 The number of free buffers in the VC 1
		@param freeBuffers_2 The number of free buffers in the VC 2
	*/
	void outputNopRequest(	
		const sc_uint<DATABUFFER_LOG2_NB_BUFFERS + 1> &buffersThatCanBeFreedWithNop_0,
		const sc_uint<DATABUFFER_LOG2_NB_BUFFERS + 1> &buffersThatCanBeFreedWithNop_1,
		const sc_uint<DATABUFFER_LOG2_NB_BUFFERS + 1> &buffersThatCanBeFreedWithNop_2,
		const sc_uint<DATABUFFER_LOG2_NB_BUFFERS + 1> &freeBuffers_0,
		const sc_uint<DATABUFFER_LOG2_NB_BUFFERS + 1> &freeBuffers_1,
		const sc_uint<DATABUFFER_LOG2_NB_BUFFERS + 1> &freeBuffers_2);

	///Resets the databuffer to an initial starting state
	void doReset();

	///Process which outputs the tag number for a buffer requested by the decoder
	/**
		The process is asynchronous to respond immediately to the decoder when it requests
		a buffer number for a specific VirtualChannel.  Actually, the next buffer number
		for every VC is chosen synchronously, so this process is just a mux of the values
		selected with the VC sent by the decoder
	*/
	void sendAddressToCommandDecoder();

	///A priority encode
	/**
		@description Takes a vector at the input and outputs the positition of the highest bit
			to have the value of 1.
		@param to_encode The vector to encode
		@param found Return value by reference : if there was a value found to encode.  It is false
			is the vector is 0
		@return The encoded value
	*/
	sc_uint<DATABUFFER_LOG2_NB_BUFFERS> priority_encoder(
		sc_bv<DATABUFFER_NB_BUFFERS> to_encode,	bool &found);

	///Tree of or that modifies the input vector
	/**
		@description Takes a vector at the input and modifies it so that if a bit in a vector
			is 1, all lower bits also become 1's.  ie: 00100 becomes 00111, 01010 becomes 01111
		@param or_modify The vector to modify
	*/
	void or_tree_modify(sc_bv<DATABUFFER_NB_BUFFERS> *or_modify);

//private:

	///Internal count of the number of buffers free as seen from the next HT node
	/**
		Used to find out how many buffers to notify as free on the nops.  At reset,
		it is 0.  If we have more free buffers than the bufferCount, it means that
		we can notify that we have freed buffers.

		The count goes up by 0-3 when we send a nop (the value carried on the nop)
		The count goes down by 1 when we receive a data packet
	*/
	sc_signal<sc_uint<DATABUFFER_LOG2_NB_BUFFERS+1> >				bufferCount[3];

	///If the buffer is free
	sc_signal<bool >												bufferFree[3][DATABUFFER_NB_BUFFERS];

	///The first buffer which is free in every VC
	sc_signal<sc_uint<DATABUFFER_LOG2_NB_BUFFERS> >			firstFreeBuffer[3];

	/**
		The number of writes done in the current buffer.  Used to know
		when to switch to a new virtual buffer.
	*/
	sc_signal<sc_uint<4> >	nbWritesInBufferDone;

	/**
		The current buffer we are currently writing in
	*/
	sc_signal<sc_uint<DATABUFFER_LOG2_NB_BUFFERS> >			currentWriteBuffer;
	/**
		The current virtual channel we are currently writing in
	*/
	sc_signal<VirtualChannel>										currentWriteVC;

	/**
		If we are currently reading from the 2 read ports.  Once read has begun, the
		currentReadVc and currentReadAddress are fixed until the buffer is finished reading
	*/
	sc_signal<bool>													currentlyReading[2];

	/**
		If we are currently reading, the virtual channel being read for every read port.
	*/
	sc_signal<VirtualChannel>									currentReadVc[2];
	/**
		If we are currently reading, the address being read for every read port.
	*/
	sc_signal<sc_uint<DATABUFFER_LOG2_NB_BUFFERS> >			currentReadAddress[2];
	/**
		If we are currently reading, the number of reads done in the current virtual buffer
	*/
	sc_signal<sc_uint<4> >	nbReadsInBufferDone[2];

	///Keeps track if a nop was already requested
	sc_signal<bool >												nopRequested;

	//The number of VIRTUAL buffers that are free for each VC
	sc_signal<sc_uint<DATABUFFER_LOG2_NB_BUFFERS + 1> > freeBuffers[3];
};


#ifdef SYSTEMC_SIM
void sc_trace(	sc_trace_file *tf, const databuffer_l2& v,
			const sc_string& NAME );
#endif

#endif
