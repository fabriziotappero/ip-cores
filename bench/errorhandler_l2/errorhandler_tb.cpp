//errorhandler_tb.cpp
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

#ifndef HT_ERROR_HANDLER_H
#include "../../rtl/systemc/errorhandler_l2/errorhandler_l2.h"
#endif

#ifndef HT_ERROR_HANDLER_SIM_H
#include "errorhandler_sim.h"
#endif

int sc_main( int argc, char* argv[] )
{
	// Create a trace file
	sc_trace_file* trace_file = sc_create_vcd_trace_file("errorHandler_testbench");
  
	// Define signals to plug on ports

	sc_signal< bool >							resetx;
	sc_signal< bool >							pwrok;

	// Reordering signals
    sc_signal< syn_ControlPacketComplete >			ro_command_eh;
	sc_signal< bool >							ro_available_eh;
	sc_signal< bool >							eh_consume_ro;

	// Flow Control signals
	sc_signal< bool >							fc_consume_eh;
	sc_signal< sc_bv<32> >						eh_datacommand_fc;
	sc_signal< bool >							eh_available_fc;

	// Data Buffer signals
	sc_signal< sc_uint<BUFFERS_ADDRESS_WIDTH> >	eh_address_db;
	sc_signal< bool > 							eh_drop_db;
	sc_signal< VirtualChannel >					eh_vctype_db;

	// CSR registries for EOC error
	sc_signal<bool>							csr_eoc;
	sc_signal<bool>							csr_initcomplete;
	sc_signal<bool>							csr_drop_uninit_link;

	sc_signal<sc_bv<5> >						csr_unitid;


	sc_clock clk("clock",10,SC_NS);

    // Instantiate the Data Buffer
	errorhandler_l2 the_EH("error_handler");
	ht_errorHandler_sim the_sim("sim");

	//------------------------------------------
	// Connect signals on ports
	//------------------------------------------	

	the_EH.resetx(resetx);
	the_EH.clk(clk);

    the_EH.ro_packet_fwd(ro_command_eh);
	the_EH.ro_available_fwd(ro_available_eh);
	the_EH.eh_ack_ro(eh_consume_ro);

	the_EH.fc_ack_eh(fc_consume_eh);
	the_EH.eh_cmd_data_fc(eh_datacommand_fc);
	the_EH.eh_available_fc(eh_available_fc);

	the_EH.eh_address_db(eh_address_db);
	the_EH.eh_erase_db(eh_drop_db);
	the_EH.eh_vctype_db(eh_vctype_db);

	the_EH.csr_end_of_chain(csr_eoc);
	the_EH.csr_initcomplete(csr_initcomplete);
	the_EH.csr_drop_uninit_link(csr_drop_uninit_link);
	the_EH.csr_unit_id(csr_unitid);
	
	the_sim.resetx(resetx);
	the_sim.pwrok(pwrok);

    the_sim.ro_command_eh(ro_command_eh);
	the_sim.ro_available_eh(ro_available_eh);

	the_sim.fc_consume_eh(fc_consume_eh);

	the_sim.csr_eoc(csr_eoc);
	the_sim.csr_initcomplete(csr_initcomplete);
	the_sim.csr_drop_uninit_link(csr_drop_uninit_link);


	// Trace internal signals of the Error Handler
	//sc_trace(trace_file,the_EH,"the_EH");
	sc_trace(trace_file,the_EH.resetx,"resetx");
	sc_trace(trace_file,the_EH.clk,"clk");
	sc_trace(trace_file,the_EH.csr_unit_id,"csr_unit_id");
	sc_trace(trace_file,the_EH.ro_packet_fwd,"ro_packet_fwd");
	sc_trace(trace_file,the_EH.ro_available_fwd,"ro_available_fwd");
	sc_trace(trace_file,the_EH.eh_ack_ro,"eh_ack_ro");
	sc_trace(trace_file,the_EH.fc_ack_eh,"fc_ack_eh");
	sc_trace(trace_file,the_EH.eh_cmd_data_fc,"eh_cmd_data_fc");
	sc_trace(trace_file,the_EH.eh_available_fc,"eh_available_fc");
	sc_trace(trace_file,the_EH.eh_address_db,"eh_address_db");
	sc_trace(trace_file,the_EH.eh_erase_db,"eh_erase_db");
	sc_trace(trace_file,the_EH.eh_vctype_db,"eh_vctype_db");
	sc_trace(trace_file,the_EH.csr_end_of_chain,"csr_end_of_chain");
	sc_trace(trace_file,the_EH.csr_initcomplete,"csr_initcomplete");
	sc_trace(trace_file,the_EH.csr_drop_uninit_link,"csr_drop_uninit_link");

	//------------------------------------------
	// Start simulation
	//------------------------------------------

	sc_start(400,SC_NS);
        
	// Close trace file
	sc_close_vcd_trace_file(trace_file);

	printf("end of simulation\n");

	return 0;
}
