//main.cpp - Data buffer testbench
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

#include "../../rtl/systemc/databuffer_l2/databuffer_l2.h"
#include "databuffer_l2_tb.h"

#include <iostream>
#include <string>
#include <sstream>
#include <iomanip>

using namespace std;

int sc_main( int argc, char* argv[] ){
	//The Design Under Test
	databuffer_l2* dut = new databuffer_l2("databuffer_l2");
	//The TestBench
	databuffer_l2_tb* tb = new databuffer_l2_tb("link_l2_tb");


	//Signals used to link the design to the testbench
	sc_clock clk("clk", 1);  // system clk

	sc_signal< bool >								resetx;
	sc_signal< bool >								ldtstopx;
    sc_signal< sc_bv<32> > 							cd_data_db;
	sc_signal< sc_uint<4> > 						cd_datalen_db;
	sc_signal< VirtualChannel >						cd_vctype_db;
	sc_signal< bool > 								cd_write_db;
	sc_signal< bool >								cd_getaddr_db;
#ifdef RETRY_MODE_ENABLED
	sc_signal< bool > 								cd_drop_db;
	sc_signal< bool > 								lk_initiate_retry_disconnect;
	sc_signal< bool >								cd_initiate_retry_disconnect;
	sc_signal< bool >								csr_retry;
#endif
	sc_signal< sc_uint<BUFFERS_ADDRESS_WIDTH> >	db_address_cd;
	sc_signal< sc_uint<BUFFERS_ADDRESS_WIDTH> >		eh_address_db;
	sc_signal< VirtualChannel >						eh_vctype_db;
	sc_signal< bool > 								eh_erase_db;
	sc_signal< sc_uint<BUFFERS_ADDRESS_WIDTH> >		csr_address_db;
	sc_signal< bool > 								csr_read_db;
	sc_signal< VirtualChannel > 					csr_vctype_db;
	sc_signal< sc_uint<BUFFERS_ADDRESS_WIDTH> >		ui_address_db;
	sc_signal< bool > 								ui_read_db;
	sc_signal< VirtualChannel >						ui_vctype_db;
	sc_signal< sc_bv<32> >							db_data_accepted;
	sc_signal< bool >								csr_erase_db;
	sc_signal< bool >								ui_erase_db;
	sc_signal< sc_uint<BUFFERS_ADDRESS_WIDTH> >		fwd_address_db;
	sc_signal< bool > 								fwd_read_db;
	sc_signal< VirtualChannel >						fwd_vctype_db;
	sc_signal< sc_bv<32> >							db_data_fwd;
	sc_signal< bool >								fwd_erase_db;
	sc_signal< bool >								fc_nop_sent;
	sc_signal< sc_bv<6> >							db_buffer_cnt_fc;
	sc_signal< bool >								db_nop_req_fc;
	sc_signal< bool >								db_overflow_csr;
	sc_signal<bool> ui_grant_csr_access_db;

	////////////////////////////////////
	//Interface to memory - synchronous
	////////////////////////////////////

	sc_signal<bool> memory_write;
	sc_signal<sc_uint<2> > memory_write_address_vc;
	sc_signal<sc_uint<BUFFERS_ADDRESS_WIDTH> > memory_write_address_buffer;
	sc_signal<sc_uint<4> > memory_write_address_pos;
	sc_signal<sc_bv<32> > memory_write_data;
	
	sc_signal<sc_uint<2> > memory_read_address_vc[2];
	sc_signal<sc_uint<BUFFERS_ADDRESS_WIDTH> >memory_read_address_buffer[2];
	sc_signal<sc_uint<4> > memory_read_address_pos[2];

	sc_signal<sc_bv<32> > memory_output[2];


	sc_signal<bool>	error;

	//Connect the design
	dut->clk(clk);

	dut->resetx(resetx);
	dut->ldtstopx(ldtstopx);
	dut->cd_data_db(cd_data_db);
	dut->cd_datalen_db(cd_datalen_db);
	dut->cd_vctype_db(cd_vctype_db);
	dut->cd_write_db(cd_write_db);
	dut->cd_getaddr_db(cd_getaddr_db);
#ifdef RETRY_MODE_ENABLED
	dut->cd_drop_db(cd_drop_db);
	dut->lk_initiate_retry_disconnect(lk_initiate_retry_disconnect);
	dut->cd_initiate_retry_disconnect(cd_initiate_retry_disconnect);
	dut->csr_retry(csr_retry);
#endif
	dut->db_address_cd(db_address_cd);
	dut->eh_address_db(eh_address_db);
	dut->eh_vctype_db(eh_vctype_db);
	dut->eh_erase_db(eh_erase_db);
	dut->csr_address_db(csr_address_db);
	dut->csr_read_db(csr_read_db);
	dut->csr_vctype_db(csr_vctype_db);
	dut->ui_address_db(ui_address_db);
	dut->ui_read_db(ui_read_db);
	dut->ui_vctype_db(ui_vctype_db);
	dut->db_data_accepted(db_data_accepted);
	dut->csr_erase_db(csr_erase_db);
	dut->ui_erase_db(ui_erase_db);
	dut->fwd_address_db(fwd_address_db);
	dut->fwd_read_db(fwd_read_db);
	dut->fwd_vctype_db(fwd_vctype_db);
	dut->db_data_fwd(db_data_fwd);
	dut->fwd_erase_db(fwd_erase_db);
	dut->fc_nop_sent(fc_nop_sent);
	dut->db_buffer_cnt_fc(db_buffer_cnt_fc);
	dut->db_nop_req_fc(db_nop_req_fc);
	dut->db_overflow_csr(db_overflow_csr);
	dut->ui_grant_csr_access_db(ui_grant_csr_access_db);

	////////////////////////////////////
	//Interface to memory - synchronous
	////////////////////////////////////

	dut->memory_write(memory_write);
	dut->memory_write_address_vc(memory_write_address_vc);
	dut->memory_write_address_buffer(memory_write_address_buffer);
	dut->memory_write_address_pos(memory_write_address_pos);
	dut->memory_write_data(memory_write_data);
	
	for(int n = 0; n < 2; n++){
		dut->memory_read_address_vc[n](memory_read_address_vc[n]);
		dut->memory_read_address_buffer[n](memory_read_address_buffer[n]);
		dut->memory_read_address_pos[n](memory_read_address_pos[n]);

		dut->memory_output[n](memory_output[n]);
	}

	
	//Connect the testbench
	tb->clk(clk);

	tb->resetx(resetx);
	tb->ldtstopx(ldtstopx);
	tb->cd_data_db(cd_data_db);
	tb->cd_datalen_db(cd_datalen_db);
	tb->cd_vctype_db(cd_vctype_db);
	tb->cd_write_db(cd_write_db);
	tb->cd_getaddr_db(cd_getaddr_db);
#ifdef RETRY_MODE_ENABLED
	tb->cd_drop_db(cd_drop_db);
	tb->lk_initiate_retry_disconnect(lk_initiate_retry_disconnect);
	tb->cd_initiate_retry_disconnect(cd_initiate_retry_disconnect);
	tb->csr_retry(csr_retry);
#endif
	tb->db_address_cd(db_address_cd);
	tb->eh_address_db(eh_address_db);
	tb->eh_vctype_db(eh_vctype_db);
	tb->eh_erase_db(eh_erase_db);
	tb->csr_address_db(csr_address_db);
	tb->csr_read_db(csr_read_db);
	tb->csr_vctype_db(csr_vctype_db);
	tb->ui_address_db(ui_address_db);
	tb->ui_read_db(ui_read_db);
	tb->ui_vctype_db(ui_vctype_db);
	tb->db_data_accepted(db_data_accepted);
	tb->csr_erase_db(csr_erase_db);
	tb->ui_erase_db(ui_erase_db);
	tb->fwd_address_db(fwd_address_db);
	tb->fwd_read_db(fwd_read_db);
	tb->fwd_vctype_db(fwd_vctype_db);
	tb->db_data_fwd(db_data_fwd);
	tb->fwd_erase_db(fwd_erase_db);
	tb->fc_nop_sent(fc_nop_sent);
	tb->db_buffer_cnt_fc(db_buffer_cnt_fc);
	tb->db_nop_req_fc(db_nop_req_fc);
	tb->db_overflow_csr(db_overflow_csr);
	tb->ui_grant_csr_access_db(ui_grant_csr_access_db);

	////////////////////////////////////
	//Interface to memory - synchronous
	////////////////////////////////////

	tb->memory_write(memory_write);
	tb->memory_write_address_vc(memory_write_address_vc);
	tb->memory_write_address_buffer(memory_write_address_buffer);
	tb->memory_write_address_pos(memory_write_address_pos);
	tb->memory_write_data(memory_write_data);
	
	for(int n = 0; n < 2; n++){
		tb->memory_read_address_vc[n](memory_read_address_vc[n]);
		tb->memory_read_address_buffer[n](memory_read_address_buffer[n]);
		tb->memory_read_address_pos[n](memory_read_address_pos[n]);

		tb->memory_output[n](memory_output[n]);
	}

	tb->error(error);

	//Trace signals
	sc_trace_file *tf = sc_create_vcd_trace_file("sim_databuffer_l2");

	sc_trace(tf,clk,"clk");
	sc_trace(tf,resetx,"resetx");
	sc_trace(tf,ldtstopx,"ldtstopx");
    sc_trace(tf,cd_data_db,"cd_data_db");
	sc_trace(tf,cd_datalen_db,"cd_datalen_db");
	sc_trace(tf,tb->cd_vctype_db_trace,"cd_vctype_db");
	sc_trace(tf,cd_write_db,"cd_write_db");
	sc_trace(tf,cd_getaddr_db,"cd_getaddr_db");
#ifdef RETRY_MODE_ENABLED
	sc_trace(tf,cd_drop_db,"cd_drop_db");
	sc_trace(tf,lk_initiate_retry_disconnect,"lk_initiate_retry_disconnect");
	sc_trace(tf,cd_initiate_retry_disconnect,"cd_initiate_retry_disconnect");
	sc_trace(tf,csr_retry,"csr_retry");
#endif
	sc_trace(tf,db_address_cd,"db_address_cd");
	sc_trace(tf,eh_address_db,"eh_address_db");
	sc_trace(tf,tb->eh_vctype_db_trace,"eh_vctype_db");
	sc_trace(tf,eh_erase_db,"eh_erase_db");
	sc_trace(tf,csr_address_db,"csr_address_db");
	sc_trace(tf,csr_read_db,"csr_read_db");
	sc_trace(tf,tb->csr_vctype_db_trace,"csr_vctype_db");
	sc_trace(tf,ui_address_db,"ui_address_db");
	sc_trace(tf,ui_read_db,"ui_read_db");
	sc_trace(tf,tb->ui_vctype_db_trace,"ui_vctype_db");
	sc_trace(tf,db_data_accepted,"db_data_accepted");
	sc_trace(tf,csr_erase_db,"csr_erase_db");
	sc_trace(tf,ui_erase_db,"ui_erase_db");
	sc_trace(tf,fwd_address_db,"fwd_address_db");
	sc_trace(tf,fwd_read_db,"fwd_read_db");
	sc_trace(tf,tb->fwd_vctype_db_trace,"fwd_vctype_db");
	sc_trace(tf,db_data_fwd,"db_data_fwd");
	sc_trace(tf,fwd_erase_db,"fwd_erase_db");
	sc_trace(tf,fc_nop_sent,"fc_nop_sent");
	sc_trace(tf,db_buffer_cnt_fc,"db_buffer_cnt_fc");
	sc_trace(tf,db_nop_req_fc,"db_nop_req_fc");
	sc_trace(tf,db_overflow_csr,"db_overflow_csr");
	sc_trace(tf,ui_grant_csr_access_db,"ui_grant_csr_access_db");

	////////////////////////////////////
	//Interface to memory - synchronous
	////////////////////////////////////

	sc_trace(tf,memory_write,"memory_write");
	sc_trace(tf,memory_write_address_vc,"memory_write_address_vc");
	sc_trace(tf,memory_write_address_buffer,"memory_write_address_buffer");
	sc_trace(tf,memory_write_address_pos,"memory_write_address_pos");
	sc_trace(tf,memory_write_data,"memory_write_data");

	for(int n = 0; n < 2; n++){
	
		std::ostringstream s;
		s << "memory_read_address_vc(" << n << ')';
		sc_trace(tf,memory_read_address_vc[n],s.str().c_str());

		std::ostringstream s2;
		s2 << "memory_read_address_buffer(" << n << ')';
		sc_trace(tf,memory_read_address_buffer[n],s2.str().c_str());

		std::ostringstream s3;
		s3 << "memory_read_address_pos(" << n << ')';
		sc_trace(tf,memory_read_address_pos[n],s3.str().c_str());

		std::ostringstream s4;
		s4 << "memory_output(" << n << ')';
		sc_trace(tf,memory_output[n],s4.str().c_str());
	}

	sc_trace(tf,error,"ERROR");
	sc_trace(tf,dut->bufferCount[0],"DB.bufferCount(0)");
	sc_trace(tf,dut->bufferCount[1],"DB.bufferCount(1)");
	sc_trace(tf,dut->bufferCount[2],"DB.bufferCount(2)");
	sc_trace(tf,dut->freeBuffers[0],"DB.freeBuffers(0)");
	sc_trace(tf,dut->freeBuffers[1],"DB.freeBuffers(1)");
	sc_trace(tf,dut->freeBuffers[2],"DB.freeBuffers(2)");

	//------------------------------------------
	// Start simulation
	//------------------------------------------
	cout << "Begin simulation" << endl;
	sc_start(500);

	sc_close_vcd_trace_file(tf);
	cout << "End simulation" << endl;

	delete dut;
	delete tb;
	return 0;
}

