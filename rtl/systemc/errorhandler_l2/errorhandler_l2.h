//ht_errorHandler.h

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
 *   Martin Corriveau
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

#ifndef ERROR_HANDLER_L2_H
#define ERROR_HANDLER_L2_H

#include "../core_synth/synth_datatypes.h"
#include "../core_synth/constants.h"

///Error handler internal states
enum ErrorHandlerState { IdleState, AnalyzePacketStateOutputFree, AnalyzePacketStateOutputLoaded,
						 SendingDataStateInputFree, SendingDataStateInputLoaded,
						 InputFreeOutputLoaded};


///Error Handler module class definition.
/**
	This class defines the Error Handler (EH) module for a HyperTransport
	tunnel.

	Three interfaces exist:
	
	1- The EH listens for command packets or <code>RequestPacket</code>
	originating from the Reordering module and checks if End Of Chain
	type errors exist.
	
	2- If so, a <code>ResponsePacket</code> packet is sent to the Flow 
	Control	module, following any related data.

	3- Dropped requests can have data associated to them. A drop is sent
	to the Data Buffer module to delete the data.

	@author Martin Corriveau
	@modified Ami castonguay
*/
class errorhandler_l2 : public sc_module
{
public:
	/// Global system  reset signal.
	sc_in< bool >							resetx;
	/// Global system clock signal.
	sc_in< bool >	 						clk;
	///Our UnitID
	sc_in<sc_bv<5> >						csr_unit_id;

	/// Reordering <code>ControlPacketComplete</code> command.
	///	It can contain a <code>RequestPacket</code> packet.
    sc_in< syn_ControlPacketComplete >			ro_packet_fwd;
	/// Reordering flag indicating a request packet is part of the command
	sc_in< bool >							ro_available_fwd;
	/// Reordering flag indicating a packet was consumed.
	sc_out< bool >							eh_ack_ro;

	/// Flow Control flag indicating a response packet was consumed.
	sc_in< bool >							fc_ack_eh;
	/// Flow Control <code>ResponsePacket</code> packet or data.
	sc_out< sc_bv<32> >						eh_cmd_data_fc;
	/// Flow Control flag indicating a response packet is ready.
	sc_out< bool >							eh_available_fc;

	/// Data Buffer address.
	sc_out< sc_uint<BUFFERS_ADDRESS_WIDTH> >  eh_address_db;
	/// Data Buffer flag indicating to drop the data.
	sc_out< bool > 							eh_erase_db;
	/// Data Buffer virtual channel.
	sc_out< VirtualChannel >				eh_vctype_db;

	/// CSR End Of Chain registry.
	sc_in<bool>							csr_end_of_chain;
	/// CSR Initialization Complete registry.
	sc_in<bool>							csr_initcomplete;
	/// CSR Drop On Uninitialized Link registry.
	sc_in<bool>							csr_drop_uninit_link;

	//sc_out<bool>						eh_received_eoc_error_csr;

	///SystemC macro for modules with process
	SC_HAS_PROCESS(errorhandler_l2);

	/// Constructor of the module
	/**
		Constructor of an Error Handler module.

		@param name Name of the module
	*/
	errorhandler_l2( sc_module_name name);


	///Synchronous process : store register values
	void clockAndReset();

	///Combinatory method to find next state and outputs
	void stateMachine();

	/// Method to check the actual EOC error state of the system
	bool checkEOCError() const;

#ifdef SYSTEMC_SIM
	/// Destructor
	virtual ~errorhandler_l2() {};

	/// Traces the EH module in a <code>sc_trace_file</code>
	/**
		Called to trace the internal Error Handler module to an
		<code>sc_trace_file</code>.

		@param tf The sc_trace_file
		@param v  The module to trace
	*/
	friend
	void sc_trace(	sc_trace_file *tf, const errorhandler_l2& v,
					const sc_string& NAME );

#endif

private:

	///The next value the inputRegister will take
	sc_signal<syn_ControlPacketComplete>	next_inputRegister;
	///Error packets are first read in this buffer before being analyzed.
	sc_signal<syn_ControlPacketComplete>	inputRegister;

	///The next value of the output data
	sc_signal<sc_bv<32> >		next_outputData;

	///The next value of outputReq
	sc_signal<bool>				next_outputReq;

	///The next value of next_dataLeftToSendm1
	sc_signal<sc_uint<5> >			next_dataLeftToSendm1;
	sc_signal<sc_uint<5> >			dataLeftToSendm1;

	///The next value of state
	sc_signal<ErrorHandlerState> next_state;
	///The current state of the error handler
	sc_signal<ErrorHandlerState> state;

};

#endif
