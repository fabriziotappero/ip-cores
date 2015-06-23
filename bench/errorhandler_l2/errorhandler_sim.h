//errorhandler_sim.h
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

#ifndef HT_ERROR_HANDLER_SIM_H
#define HT_ERROR_HANDLER_SIM_H

#ifndef HT_DATATYPES_H
#include "../core/ht_datatypes.h"
#endif
#include "../../rtl/systemc/core_synth/synth_datatypes.h"

///Testbench module for error_handler_l2
/**
This is a testbench that was done VERY early in the development
process, so it is not sophisticated at all.  In fact, it only
stimulates a couple of obvious testcases.  Since the errorhandler
is a simple module, doing a more elaborate testbench was not a
priority.

*/
class ht_errorHandler_sim : public sc_module
{
public:
	/// Global reset
	sc_out< bool >							resetx;
	/// Global reset
	sc_out< bool >							pwrok;

	/// Reordering signals
    sc_out< syn_ControlPacketComplete >			ro_command_eh;
	///If reordering module has packet available
	sc_out< bool >							ro_available_eh;

	/// Flow Control consumes error_handler output
	sc_out< bool >							fc_consume_eh;

	/// CSR register for EOC error
	sc_out<bool>							csr_eoc;
	/// CSR register : if the init of the link is complete
	sc_out<bool>							csr_initcomplete;
	/// CSR register : if packets are dropped before link is initialized
	sc_out<bool>							csr_drop_uninit_link;


	///various events
	//@{
	sc_event activate_coldReset;
	sc_event activate_warmReset;
	sc_event activate_sendRequest;
	sc_event activate_receiveResponse;
	//@}

public:
	////Constructor
	ht_errorHandler_sim( sc_module_name name );

	void simulate();
	void coldReset();
	void warmReset();
	void sendRequest();
	void receiveResponse();

	///SystemC Macro
	SC_HAS_PROCESS(ht_errorHandler_sim);

private:
	//Unusable constructor
	ht_errorHandler_sim();

	void dropFlagSignals();
};

#endif
