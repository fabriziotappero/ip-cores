//databuffer_l2_tb.h
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

#ifndef DATABUFFER_L2_TB_H
#define DATABUFFER_L2_TB_H

#include "../../rtl/systemc/core_synth/synth_datatypes.h"
#include "../../rtl/systemc/core_synth/constants.h"

///Testbench for the the databuffer_l2 module
/**
	@class databuffer_l2_tb
	@author Ami Castonguay
	@description Testbench for the databuffer.  The testbench is seperated in
		several processes :
		 - Generating random data buffer packets
		 - Randomly read entries from the read ports
		 - Generate nop received signals and verify validity of nop requests
		 - simulate the memories that the databuffer uses
*/
class databuffer_l2_tb : public sc_module {

public:

	/// Global system cold reset signal.
	sc_out< bool >								resetx;
	/// LDTSTOP (power saving mode)
	sc_out< bool >								ldtstopx;
	/// Global system clock signal.
	sc_in_clk		 							clk;

	/// Command Decoder data.
    sc_out< sc_bv<32> > 							cd_data_db;
	/// Command Decoder data length in dword, minus 1.
	sc_out< sc_uint<4> > 						cd_datalen_db;
	/// Command Decoder virtual channel of the data
	sc_out< VirtualChannel >						cd_vctype_db;
	/// Command Decoder write request flag
	sc_out< bool > 								cd_write_db;
	/// Command Decoder flag for getting the address of the data
	sc_out< bool >								cd_getaddr_db;

#ifdef RETRY_MODE_ENABLED
	/// Command Decoder flag for erasing data
	sc_out< bool > 								cd_drop_db;
	///Link initiates retry disconnect (must reset buffer count)
	sc_out< bool > 								lk_initiate_retry_disconnect;
	///Command decoder initiates retry disconnect (must reset buffer count)
	sc_out< bool >								cd_initiate_retry_disconnect;
	///If the retry mode is activated
	sc_out< bool >								csr_retry;
#endif
	/// Command Decoder return address of the sent data
	sc_in< sc_uint<BUFFERS_ADDRESS_WIDTH> >	db_address_cd;

	/// Error Handler address of the data to drop
	sc_out< sc_uint<BUFFERS_ADDRESS_WIDTH> >		eh_address_db;
	/// Error Handler virtual channel of the data to drop
	sc_out< VirtualChannel >						eh_vctype_db;
	/// Error Handler flag for erasing data
	sc_out< bool > 								eh_erase_db;

	/// CSR address of data to read
	sc_out< sc_uint<BUFFERS_ADDRESS_WIDTH> >		csr_address_db;
	/// CSR flag to read data
	sc_out< bool > 								csr_read_db;
	/// CSR virtual channel of data to read
	sc_out< VirtualChannel > 					csr_vctype_db;

	/// User Interface address of data to read
	sc_out< sc_uint<BUFFERS_ADDRESS_WIDTH> >		ui_address_db;
	/// User Interface flag to read data
	sc_out< bool > 								ui_read_db;
	/// User Interface virtual channel of data to read
	sc_out< VirtualChannel >						ui_vctype_db;

	/// Data for the accepted destination (shared CSR and UI output)
	/** The output is selected by the ui_grant_csr_access_db signal*/
	sc_in< sc_bv<32> >							db_data_accepted;
	///CSR has done reading the packet and it can be erased
	sc_out< bool >								csr_erase_db;
	///UI has done reading the packet and it can be erased
	sc_out< bool >								ui_erase_db;


	/// Forward address of data to read
	sc_out< sc_uint<BUFFERS_ADDRESS_WIDTH> >		fwd_address_db;
	/// Forward flag to read data
	sc_out< bool > 								fwd_read_db;
	/// Forward virtual channel of data to read
	sc_out< VirtualChannel >						fwd_vctype_db;
	/// Forward return data 
	sc_in< sc_bv<32> >							db_data_fwd;
	/// Forward return flag meaning the last data forming the packet
	sc_out< bool >								fwd_erase_db;

	/// Flow Control flag meaning a NOP packet was sent
	sc_out< bool >								fc_nop_sent;
	/// Flow Control return free buffers counters since last NOP request
	/** [5,4]: nonposted; [3,2]: posted; [1,0]: response.*/
	sc_in< sc_bv<6> >							db_buffer_cnt_fc;
	/// Flow Control return flag for a request of a NOP packet.
	sc_in< bool >								db_nop_req_fc;
	///Activated when we receive more data than we can store
	sc_in< bool >								db_overflow_csr;

	///UI grants databuffer access to CSR (accepted port is shared)
	/**By default, the accepted port is for the UI.  When the UI grants the right
	   of access to the CSR, it becomes the CSR's right.  The grant signal is read
	  to know what data to output.*/
	sc_out<bool> ui_grant_csr_access_db;

	///When an error is detected in the testbench
	sc_out<bool> error;

	////////////////////////////////////
	//Interface to memory - synchronous
	////////////////////////////////////

	///Interface to databuffer memories.  See databuffer_l2 documentation for more details
	//@{
	sc_in<bool> memory_write;
	sc_in<sc_uint<2> > memory_write_address_vc;
	sc_in<sc_uint<BUFFERS_ADDRESS_WIDTH> > memory_write_address_buffer;
	sc_in<sc_uint<4> > memory_write_address_pos;
	sc_in<sc_bv<32> > memory_write_data;
	
	sc_in<sc_uint<2> > memory_read_address_vc[2];
	sc_in<sc_uint<BUFFERS_ADDRESS_WIDTH> >memory_read_address_buffer[2];
	sc_in<sc_uint<4> > memory_read_address_pos[2];

	sc_out<sc_bv<32> > memory_output[2];
	//@}

	///SystemC Macro
	SC_HAS_PROCESS(databuffer_l2_tb);

	///This is the memory used by the databuffer
	int memory[3][DATABUFFER_NB_BUFFERS][16];

	///Actual data entries to keep track of what is stored in the databuffers
	int data_packets[3][DATABUFFER_NB_BUFFERS][16];
	///  A size of 0 means no data in the buffer
	int data_packets_size[3][DATABUFFER_NB_BUFFERS];
	///The count of packets in the three virtual channels
	int data_packets_count[3];
	///The number of packets that can be sent to the databuffer for every VirtualChannel
	/**Changes by nops sent, packet sent and received, reset and disconenct sequences*/
	int data_packets_allowed[3];
	///If the testbench is allowed to overflow the databuffer
	bool allow_overflow;

	///Constructor
	databuffer_l2_tb(sc_module_name name);

	///Process to read the data available at the databuffer output
	/**
		Test reading the ports of the databuffer.  Check that the data matches
		what was sent in the databuffer.  There are four read ports tested, the
		port for the FWD, CSR and UI to read data.  The CSR and UI ports are shared,
		meaning that only one can read at the time.  The last port is a "drop" port for
		the error handler, to simply erase a complete packet when it's not needed.
	*/
	void read_data();

	///Process to generate data packets for the databuffer
	/**
		Send data to the databuffer.  Generate data packets, random data and
		sometime drop the data.  The data being pushed in is stored in 
		the variable data_packets so it can be checked at the outout.
	*/
	void store_data();
	///Process that simulates the memories used by the databuffer
	void manage_memories();
	///Process that
	void manage_nops();
	///Drives reset at the beggining of the simulation
	void manage_reset();
	///Convert VC signals to traceable signals
	/** Signals like cd_vctype_db are not traceable by default because they use the
		VirtualChannel enum type.  This process converts thos enums to ints so they
		can be traced.
	*/
	void convert_vcs();

	/** Traceable signals created by ::convert_vcs() */
	///@{
	sc_signal<sc_uint<2> > cd_vctype_db_trace;
	sc_signal<sc_uint<2> > eh_vctype_db_trace;
	sc_signal<sc_uint<2> > csr_vctype_db_trace;
	sc_signal<sc_uint<2> > ui_vctype_db_trace;
	sc_signal<sc_uint<2> > fwd_vctype_db_trace;
	///@}
};

#endif
