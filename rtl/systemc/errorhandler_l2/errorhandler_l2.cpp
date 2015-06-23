//ht_errorHandler.cpp

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

#include "errorhandler_l2.h"

errorhandler_l2::errorhandler_l2( sc_module_name name) :sc_module(name)
{
	//This is combinatory to it's sensitive to all the variables read by the process
	SC_METHOD(stateMachine);
	sensitive << csr_end_of_chain << csr_initcomplete << csr_drop_uninit_link << csr_unit_id <<
		ro_available_fwd << ro_packet_fwd << 
		fc_ack_eh << inputRegister << eh_cmd_data_fc << eh_available_fc << dataLeftToSendm1 << state;
	
	//This represents registers, so it's only sensitive to clk and reset
	SC_METHOD(clockAndReset);
	sensitive_neg << resetx;
	sensitive_pos << clk;
	
}


void errorhandler_l2::clockAndReset(){

	if(resetx.read() == false){
		//We have no data to send
		dataLeftToSendm1 = 0;
		//Go back to idle state
		state = IdleState;

		eh_cmd_data_fc = 0;
		eh_available_fc = false;

		syn_ControlPacketComplete defaultPkt;
		initialize_syn_ControlPacketComplete(defaultPkt);
		inputRegister = defaultPkt;
	}
	else{
		eh_available_fc = next_outputReq;
		dataLeftToSendm1 = next_dataLeftToSendm1;
		state = next_state;
		eh_cmd_data_fc = next_outputData;
		inputRegister = next_inputRegister;
	}
}

bool errorhandler_l2::checkEOCError() const
{
	/**
		End of chain can happen for two reasons :
		   - csr_end_of_chain is asserted, either because we truly are
		     the last element of the chain or because it is set by
			 software
		   - The link is not initialized yet and csr_drop_uninit_link is
		     set.
	*/
	if( csr_end_of_chain.read() == true ||
		( csr_initcomplete.read() == false &&
		  csr_drop_uninit_link.read() == true ) )
	{
		return true;
	}
	return false;
}



#ifdef SYSTEMC_SIM
/// Trace external function
void 
sc_trace(	sc_trace_file *tf, const errorhandler_l2& v,
			const sc_string& NAME )
{
	sc_trace(tf,v.clk, NAME + ".clk");
	sc_trace(tf,v.ro_packet_fwd, NAME + ".ro_packet_fwd");
	sc_trace(tf,v.ro_available_fwd, NAME + ".ro_available_fwd");
	sc_trace(tf,v.eh_ack_ro, NAME + ".eh_ack_ro");
	sc_trace(tf,v.fc_ack_eh, NAME + ".fc_ack_eh");
	sc_trace(tf,v.eh_cmd_data_fc, NAME + ".eh_cmd_data_fc");
	sc_trace(tf,v.eh_available_fc, NAME + ".eh_available_fc");
	sc_trace(tf,v.eh_address_db, NAME + ".eh_address_db");
	sc_trace(tf,v.eh_erase_db, NAME + ".eh_erase_db");
	sc_trace(tf,v.eh_vctype_db, NAME + ".eh_vctype_db");
	sc_trace(tf,v.csr_end_of_chain, NAME + ".csr_end_of_chain");
	sc_trace(tf,v.csr_initcomplete, NAME + ".csr_initcomplete");
	sc_trace(tf,v.csr_drop_uninit_link, NAME + ".csr_drop_uninit_link");
	sc_trace(tf,v.resetx, NAME + ".resetx");	
	sc_trace(tf,v.dataLeftToSendm1, NAME + ".dataLeftToSendm1");

}
#endif

void errorhandler_l2::stateMachine(){

	///////////////////////////////////////////////
	// Default outputs
	///////////////////////////////////////////////
	eh_ack_ro = false;
	next_dataLeftToSendm1 = 0;
	//All 1's because response packets for end of chain errors must only contain 1's
	next_outputData = "11111111111111111111111111111111";
	next_outputReq = false;
	next_state = IdleState;
	next_inputRegister = ro_packet_fwd.read();
	eh_address_db.write( 0 );
	eh_vctype_db.write( VC_NONE );
	eh_erase_db = false;
	//No need for this, reading the packet at the input is a signal that we
	//received a eoc packet, so no need for an extra signal.
	//eh_received_eoc_error_csr = false;

	//General variables that can be used in multiple states
	sc_bv<64> input_register_pkt = inputRegister.read().packet;
	PacketCommand input_register_cmd = getPacketCommand(input_register_pkt.range(5,0));
	VirtualChannel input_register_vc = getVirtualChannel(input_register_pkt,input_register_cmd);
	bool dataAssociated = hasDataAssociated(input_register_cmd);

	switch(state){

	///////////////////////////////////////////////
	// IDLE STATE
	///////////////////////////////////////////////
	case IdleState :
		/**If there is a packet and it is a an end of chain error
		   The same packets "signal" goes to both the flow control and
		   the error handler.  What dicates who consumes that packet
		   is if we are currently in a end of chain states
		*/
		if((checkEOCError() || ro_packet_fwd.read().error64BitExtension) 
				&& ro_available_fwd == true){
			next_state = AnalyzePacketStateOutputFree;
			eh_ack_ro = true;
		}
		break;


	///////////////////////////////////////////////
	// AnalyzePacketStateOutputLoaded STATE
	///////////////////////////////////////////////
	/** This state means that we have a new packet to analyze in the
		input buffer but that there is also data in the output buffer
		waiting to be sent
	*/
	case AnalyzePacketStateOutputLoaded :
		next_outputReq = true;
		next_outputData = eh_cmd_data_fc.read();
		next_state = AnalyzePacketStateOutputLoaded;

		//This state does roughly he same thing as the next state, but can only
		//update the output buffers if the FC acks what in the output buffer
		//If there is no ack, we stop right here and wait for the ack.
		if(fc_ack_eh.read() == false) break;

	/** This state means that we have a new packet to analyze in the
		input buffer and that we can output data to the flow control
		immediately.
	*/
	///////////////////////////////////////////////
	// AnalyzePacketStateOutputFree STATE
	///////////////////////////////////////////////
	case AnalyzePacketStateOutputFree :

		//When we reveice non posted packets, we generate a response with
		//the MASTER_ABORT bit on
		if(input_register_vc == VC_NON_POSTED ){
			
			// Construct Response Packet and activate the sending process
			bool passPW = getPassPW(input_register_pkt);
			sc_uint<5> dataLengthm1 = getDataLengthm1(input_register_pkt);
			//sc_uint<5> dataLength = dataLengthm1 + 1;
			sc_bv<5> reqUID = getUnitID(input_register_pkt);
			sc_bv<5> srcTag = request_getSrcTag(input_register_pkt);

			switch( input_register_cmd ){

			case READ:
			case ATOMIC:
				{
					/**
						In the case we received READ or ATOMIC request, we must
						reply with a response that has the right amount of data
						requested.
					*/
					sc_bv<32> readResponse = generateReadResponse( csr_unit_id.read(),
						srcTag,
						reqUID.range(1,0),
						dataLengthm1,
						false,
						RE_MASTER_ABORT,
						passPW,
						false);

					next_outputData = readResponse;
					next_outputReq = true;
					next_dataLeftToSendm1 = dataLengthm1;
					next_state = SendingDataStateInputFree;
				}
				break;
			//case WRITE:
			default:
				{
					/**
						In the case of a WRITE, we simply respond with a
						TargetDone
					*/
					next_outputData = generateTargetDone( csr_unit_id.read(),
						srcTag,
						reqUID.range(1,0),
						false,
						RE_MASTER_ABORT,
						passPW,
						false);
					next_outputReq = true;
					next_state = InputFreeOutputLoaded;
				}
				break;

			}
		}
		//In the case of POSTED and RESPONSE vc's, we can't response
		//We simply flag a bit in the CSR saying that we received an error.
		else if(input_register_cmd != BROADCAST){
			//eh_received_eoc_error_csr = true;
		}

		/** If the received packet contained data, we drop it */
		if(dataAssociated){
			eh_address_db.write( inputRegister.read().data_address );
			eh_vctype_db.write( input_register_vc);
			eh_erase_db = true;
		}
		
		break;


	///////////////////////////////////////////////
	// SendingDataStateInputFree STATE
	///////////////////////////////////////////////
	case SendingDataStateInputFree :
		next_outputReq = true;

		next_dataLeftToSendm1 = dataLeftToSendm1;
		next_state = SendingDataStateInputFree;

		//If there is a new packet at the input
		if((checkEOCError() || ro_packet_fwd.read().error64BitExtension) 
				&& ro_available_fwd == true){
			//If we only have one more data to send and the current data
			//is being read, load the last data and analyze the new packet
			if(dataLeftToSendm1.read() == 0 && fc_ack_eh.read() == true) {
				next_state = AnalyzePacketStateOutputLoaded;
			}
			//If we only have one more data to send and the current data
			//is not being read, we stay
			else if(dataLeftToSendm1.read() == 0){
				next_state = SendingDataStateInputLoaded;
				next_outputData = eh_cmd_data_fc.read();
			}
			else {
				next_state = SendingDataStateInputLoaded;
				if(fc_ack_eh.read() == true){
					next_dataLeftToSendm1 = dataLeftToSendm1.read() - 1;
				}
				else{
					next_outputData = eh_cmd_data_fc.read();
				}
			}
			eh_ack_ro = true;
		}
		else if(fc_ack_eh.read() == true){
			if(dataLeftToSendm1.read() == 0){
				next_state = InputFreeOutputLoaded;
			}
			else{
				next_dataLeftToSendm1 = dataLeftToSendm1.read() - 1;
			}
		}
		else{
			next_outputData = eh_cmd_data_fc.read();
		}

		break;

	///////////////////////////////////////////////
	// SendingDataStateInputLoaded STATE
	///////////////////////////////////////////////
	case SendingDataStateInputLoaded :
		next_outputReq = true;
		next_dataLeftToSendm1 = dataLeftToSendm1;
		next_state = SendingDataStateInputLoaded;
		next_inputRegister = inputRegister;

		if(fc_ack_eh.read() == true){
			if(dataLeftToSendm1.read() == 0) next_state = AnalyzePacketStateOutputLoaded;
			else next_dataLeftToSendm1 = dataLeftToSendm1.read() - 1;
		}
		else{
			next_outputData = eh_cmd_data_fc.read();
		}
		break;
	
	///////////////////////////////////////////////
	// InputFreeOutputLoaded STATE
	///////////////////////////////////////////////
	case InputFreeOutputLoaded :
		next_outputData = eh_cmd_data_fc.read();
		next_outputReq = true;

		if((checkEOCError() || ro_packet_fwd.read().error64BitExtension) 
				&& ro_available_fwd == true){
			if(fc_ack_eh.read() == true){
				next_state = AnalyzePacketStateOutputFree;
				next_outputReq = false;
			}
			else{
				next_state = AnalyzePacketStateOutputLoaded;
				next_outputData = eh_cmd_data_fc.read();
			}
		}
		else if(fc_ack_eh.read() == true){
			next_state = IdleState;
			next_outputReq = false;
		}
		else{
			next_state = InputFreeOutputLoaded;
			next_outputData = eh_cmd_data_fc.read();
		}
		break;

	}
}

#ifndef SYSTEMC_SIM
#include "../core_synth/synth_control_packet.cpp"
#endif


