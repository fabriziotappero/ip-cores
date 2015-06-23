//csr_l2.cpp

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
 *   Michel Morneau
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

#include "csr_l2.h"

csr_l2::csr_l2(sc_module_name name) : sc_module(name){
	SC_METHOD(csr_state_machine);
	sensitive_pos << clk;
	sensitive_neg << resetx;

	SC_METHOD(update_registers_warm);
	sensitive_pos << clk;
	sensitive_neg << resetx;

	SC_METHOD(update_registers_cold);
	sensitive_pos << clk;
	sensitive_neg << pwrok;

	SC_METHOD(output_external_register_signals);
	sensitive << read_addr << write << write_addr << write_data << write_mask
			<< state << fc0_ack_csr << fc1_ack_csr;

	/**
		When the registers are changed, output the new values
		of the registers.  In hardware, we trigger on the complete
		register set.
		
		For faster simulation*, we simply trigger on a single software
		induced event.  * : (I think!)
	*/
	SC_METHOD(output_register_values);
	for(int n = 0; n < CSR_SIZE; n++){
		sensitive << config_registers[n];
	}

	SC_METHOD(build_output_values);
	sensitive << command_lsb << command_msb << status_msb 
		<< bar_slots[0] << bar_slots[1] << bar_slots[2] 
		<< bar_slots[3] << bar_slots[4] << bar_slots[5] 
		<< interrupt_scratchpad << interface_command_lsb
		<< interface_command_msb << link_control_0_lsb
		<< link_control_0_lsb_cold4 << link_control_0_msb
		<< link_control_0_msb_cold0
		<< link_config_0_msb
		<< link_control_1_lsb
		<< link_control_1_lsb_cold4
		<< link_control_1_msb
		<< link_control_1_msb_cold0
		<< link_config_1_msb
		<< link_freq_and_error0
		<< reorder_disable
		<< link_freq_and_error1
		<< enum_scratchpad_lsb
		<< enum_scratchpad_msb
		<< protocol_error_flood_en
		<< overflow_error_flood_en
		<< chain_fail
		<< response_error
		<< bus_number

#ifdef ENABLE_DIRECTROUTE
		<< direct_route_index
		<< direct_route_enable
#endif
		<< clumping_enable

		<< error_retry_control0
		<< error_retry_control0_cold0
		<< error_retry_control1
		<< error_retry_control1_cold0
		<< error_retry_status0
		<< error_retry_status1
		<< error_retry_count0
		<< error_retry_count1;


}


void csr_l2::csr_state_machine(){
	
	if(!resetx.read()){
		state = CSR_IDLE;
		write_addr = 0;
		csr_address_db0 = 0;
		csr_address_db1 = 0;
		csr_vctype_db0 = VC_POSTED;
		csr_vctype_db1 = VC_POSTED;
		tgtdone_waiting_to_be_sent = false;
		next_response_RqUID = 0;
		next_response_passpw = false;
		next_response_srctag = 0;
		next_response_target_abort = false;
		next_posted = false;
		next_response_side = false;
		counter = 0;
		read_addr = 0;
		write_data = 0;
		read_write_side = false;
		write_mask_vector = 0;
		targetdone_send_side = false;
		write_mask = 0;
		write = false;

		csr_read_db0 = false;
		csr_read_db1 = false;
		csr_erase_db0 = false;
		csr_erase_db1 = false;
		csr_available_fc0 = false;
		csr_available_fc1 = false;
		csr_request_databuffer0_access_ui = false;
		csr_request_databuffer1_access_ui = false;
		csr_ack_ro0 = false;
		csr_ack_ro1 = false;
		csr_available_fc0 = false;
		csr_available_fc1 = false;
		output_packet_buf = 0;
		csr_dword_fc0 = 0;
		csr_dword_fc1 = 0;
	}
	else{

		/**
			By default we don't read anything from the databuffers
		*/
		csr_read_db0 = false;
		csr_read_db1 = false;
		csr_erase_db0 = false;
		csr_erase_db1 = false;
		
		/**
			By default we don't send anything to the flow control
		*/	
		csr_available_fc0 = false;
		csr_available_fc1 = false;

		/**
			By default, do not write anything in CSR
		*/
		write_mask = "0000";
		write = false;

		/**
			By default, do not request acess to the Databuffer
		*/
		csr_request_databuffer0_access_ui = false;
		csr_request_databuffer1_access_ui = false;

		//By default, send an output
		sc_bv<32> output_packet_ack = output_packet_buf.read();
		sc_bv<32> output_packet_noack = output_packet_buf.read();

		//Build a targetdone packet that can be used by the state machine
		sc_bv<32> targetdone_packet = 0;
		sc_bv<6> output_packet_command_tgtdone = "110011";
		sc_bv<6> output_packet_command_read_response = "110000";
		targetdone_packet.range(5,0) = output_packet_command_tgtdone;
		targetdone_packet.range(12,8) = config_registers[Interface_Pointer+2].read().range(4,0);

		csr_ack_ro0 = false;
		csr_ack_ro1 = false;

		csr_available_fc0 = false;
		csr_available_fc1 = false;


		/*
			This code was repeated multiple times in the state machine, so brought it to the beggining
			to clean up the code.  tmp_output_packet is used later in the state machine
		*/
		sc_bv<32> tmp_output_packet_ack;
		sc_bv<32> tmp_output_packet_noack = output_packet_buf.read();

		/*  When in a read state and the flow control acks the dword, the next dword must be
			sent to output.  read_addr holds the address of the next packet to output, so no
			need
		*/
		if(state == CSR_READ || state == CSR_BEGIN_READ){
			if(read_addr.read() < CSR_DWORD_SIZE){
				tmp_output_packet_ack.range(7,0) = config_registers[read_addr.read()*4].read();
				tmp_output_packet_ack.range(15,8) = config_registers[read_addr.read()*4+1].read();
				tmp_output_packet_ack.range(23,16) = config_registers[read_addr.read()*4+2].read();
				tmp_output_packet_ack.range(31,24) = config_registers[read_addr.read()*4+3].read();
			}
			else tmp_output_packet_ack = usr_read_data_csr.read();
		}
		else tmp_output_packet_ack = output_packet_buf.read();


		//By default, keep the same address
		csr_address_db0 = csr_address_db0.read();
		csr_address_db1 = csr_address_db1.read();
		csr_vctype_db0 = csr_vctype_db0.read();
		csr_vctype_db1 = csr_vctype_db1.read();

		/**
			tgtdone_waiting_to_be_sent is to know if there is currently a targetdone packet
			waiting to be sent out.  This can happen so that we can start treating a second
			packet before the response of a first packet is sent out.  The packet is
			defined by all the targetdone_* registers.
			
			If the flow control acks reading the packet, then we can assume the output is
			free.  This is the current_tgtdone_waiting_to_be_sent signal.
		*/

		bool tgtdone_waiting_to_be_sent_ack = false;
		bool tgtdone_waiting_to_be_sent_noack = tgtdone_waiting_to_be_sent.read();

		bool targetdone_send_side_ack = targetdone_send_side.read();
		bool targetdone_send_side_noack = targetdone_send_side.read();

		bool csr_available_fc0_ack = false;
		bool csr_available_fc0_noack = !targetdone_send_side.read() && tgtdone_waiting_to_be_sent.read();
		bool csr_available_fc1_ack = false;
		bool csr_available_fc1_noack = targetdone_send_side.read() && tgtdone_waiting_to_be_sent.read();

		switch(state){
		
		/**
			This BEGIN state is necessary because the databuffer is
			a synchronous memory that needs a delay of one clock cycle
			to output data.
		*/
		case CSR_BEGIN_BYTE_WRITE:
			
			/*
				Keep requesting for the DataBuffer access
			*/
			csr_request_databuffer0_access_ui = !read_write_side.read();
			csr_request_databuffer1_access_ui = read_write_side.read();


			/**
				When Databuffer acces is granted, treat the write packet!
			*/
			if(ui_databuffer_access_granted_csr.read()){
				state = CSR_BYTE_WRITE_MASK;
				/**
					The address is already being sent to the databuffer, so we'll
					get the first data on the next cycle.  So in the next cycle, we
					also output that we read the data and switch to the mask dword.
				*/
				csr_read_db0 = !read_write_side.read();
				csr_read_db1 = read_write_side.read();
			}
			else{
				state = CSR_BEGIN_BYTE_WRITE;
			}

			break;

		
		case CSR_BYTE_WRITE_MASK:
			{
			/*
				Keep requesting for the DataBuffer access
			*/
			csr_request_databuffer0_access_ui = !read_write_side.read();
			csr_request_databuffer1_access_ui = read_write_side.read();

			csr_read_db0 = !read_write_side.read();
			csr_read_db1 = read_write_side.read();
			counter = counter.read() - 1;

			//Should not be a single dword, it is illegal packet (but still possible...)
			bool done = counter.read() == 0;
			csr_erase_db0 = !read_write_side.read() && done;
			csr_erase_db1 = read_write_side.read() && done;

			//Store the byte write mask
			sc_bv<32> write_mask_vector_tmp;
			if(!read_write_side.read()) write_mask_vector_tmp = db0_data_csr;
			else write_mask_vector_tmp = db1_data_csr;
			write_mask_vector = write_mask_vector_tmp;

			//Go to the byte write
			if(!done){
				state = CSR_BYTE_WRITE;
				/*
					Keep requesting for the DataBuffer access
				*/
				csr_request_databuffer0_access_ui = !read_write_side.read();
				csr_request_databuffer1_access_ui = read_write_side.read();
			}
			else{
				state = CSR_IDLE;
			}
			}
			break;

		case CSR_BYTE_WRITE:
			{
			counter = counter.read() - 1;

			bool done = counter.read() == 0;
			csr_erase_db0 = !read_write_side.read() && done;
			csr_erase_db1 = read_write_side.read() && done;

			//Read the data to write from the databuffer
			if(!read_write_side.read()) write_data = db0_data_csr;
			else write_data = db1_data_csr;

			//We don't write and increment if we are at the beyond or at the last memory position
			//and if it crosses over the illegal 32 bytes barrier
			if(write_addr.read() <= (CSR_DWORD_SIZE - 1) && write_addr.read() != 7){
				if(write.read())
					write_addr = write_addr.read() + 1;
				write = true;
			}

			//Choose the correct write mask
			switch(write_addr.read().range(2,0)){
			case 0 : write_mask = write_mask_vector.read().range(3,0); break;
			case 1 : write_mask = write_mask_vector.read().range(7,4); break;
			case 2 : write_mask = write_mask_vector.read().range(11,8); break;
			case 3 : write_mask = write_mask_vector.read().range(15,12); break;
			case 4 : write_mask = write_mask_vector.read().range(19,16); break;
			case 5 : write_mask = write_mask_vector.read().range(23,20); break;
			case 6 : write_mask = write_mask_vector.read().range(27,24); break;
			default : write_mask = write_mask_vector.read().range(31,28); break;
			}

			tgtdone_waiting_to_be_sent = true;

			if(done && !next_posted.read()){

				targetdone_packet[15] = next_response_passpw;
				targetdone_packet.range(20,16) = next_response_srctag.read();
				targetdone_packet.range(31,30) = next_response_RqUID.read();

				output_packet_ack = targetdone_packet;
				targetdone_send_side_ack = next_response_side.read();
				if(next_response_side.read()) csr_available_fc1_ack = true;
				else csr_available_fc0_ack = true;

				if(!tgtdone_waiting_to_be_sent.read()){
					output_packet_noack = targetdone_packet;
					targetdone_send_side_noack = next_response_side.read();
					if(next_response_side.read()) csr_available_fc1_noack = true;
					else csr_available_fc0_noack = true;
				}

			}

			//When not done, keep going
			if(!done){
				state = CSR_BYTE_WRITE;

				/*
					Keep requesting for the DataBuffer access
				*/
				csr_request_databuffer0_access_ui = !read_write_side.read();
				csr_request_databuffer1_access_ui = read_write_side.read();

				csr_read_db0 = !read_write_side.read();
				csr_read_db1 = read_write_side.read();
			}
			//If posted, there is no target done sent
			else if(next_posted.read() || !tgtdone_waiting_to_be_sent.read() 
				|| fc0_ack_csr.read() || fc1_ack_csr.read()){
				state = CSR_IDLE;			
			}
			//If done and output still clobbed by an old targetdone, wait for it to be sent before
			//outputing the new one
			else
				state = CSR_IDLE_TARGET_DONE_PENDING;
			}
			break;


		/**
			This BEGIN state is necessary because the databuffer is
			a synchronous memory that needs a delay of one clock cycle
			to output data
		*/
		case CSR_BEGIN_DWORD_WRITE:
			{
			/**
				When Databuffer acces is granted, treat the write packet!
			*/
			if(ui_databuffer_access_granted_csr.read()){
				state = CSR_DWORD_WRITE;
				/**
					The address is already being sent to the databuffer, so we'll
					get the first data on the next cycle.  So in the next cycle, we
					also output that we read the data and switch to the mask dword.
				*/
				csr_read_db0 = !read_write_side.read();
				csr_read_db1 = read_write_side.read();
			}
			else{
				state = CSR_BEGIN_DWORD_WRITE;
			}
			
			/*
				Request for the DataBuffer access
			*/
			csr_request_databuffer0_access_ui = !read_write_side.read();
			csr_request_databuffer1_access_ui = read_write_side.read();

			}
			break;

		case CSR_DWORD_WRITE:
			{
			counter = counter.read() - 1;

			bool done = counter.read() == 0;
			csr_erase_db0 = !read_write_side.read() && done;
			csr_erase_db1 = read_write_side.read() && done;

			//We don't write and increment if we are at the beyond or at the last memory position
			if(write_addr.read() <= (CSR_DWORD_SIZE - 1)){
				if(write.read())
					write_addr = write_addr.read() + 1;
				write = true;
			}

			write_mask = "1111";

			if(!read_write_side.read()) write_data = db0_data_csr;
			else write_data = db1_data_csr;

			if(done && !next_posted.read()){

				targetdone_packet[15] = next_response_passpw;
				targetdone_packet.range(20,16) = next_response_srctag.read();
				targetdone_packet.range(31,30) = next_response_RqUID.read();

				tgtdone_waiting_to_be_sent_noack = true;
				tgtdone_waiting_to_be_sent_ack = true;

				output_packet_ack = targetdone_packet;
				targetdone_send_side_ack = next_response_side.read();
				if(next_response_side.read()) csr_available_fc1_ack = true;
				else csr_available_fc0_ack = true;

				if(!tgtdone_waiting_to_be_sent.read()){
					output_packet_noack = targetdone_packet;
					targetdone_send_side_noack = next_response_side.read();
					if(next_response_side.read()) csr_available_fc1_noack = true;
					else csr_available_fc0_noack = true;
				}

			}

			if(!done){
				/*
					Keep requesting for the DataBuffer access
				*/
				csr_request_databuffer0_access_ui = !read_write_side.read();
				csr_request_databuffer1_access_ui = read_write_side.read();

				csr_read_db0 = !read_write_side.read();
				csr_read_db1 = read_write_side.read();

				state = CSR_DWORD_WRITE;
			}
			//If posted, there is no target done sent
			else if(next_posted.read() || !tgtdone_waiting_to_be_sent.read() 
				|| fc0_ack_csr.read() || fc1_ack_csr.read()){
				state = CSR_IDLE;			
			}
			//If done and output still clobbed by an old targetdone, wait for it to be sent before
			//outputing the new one
			else
				state = CSR_IDLE_TARGET_DONE_PENDING;
			}
			break;

		case CSR_IDLE_TARGET_DONE_PENDING:
			tgtdone_waiting_to_be_sent = true;
			targetdone_send_side_ack = next_response_side.read();

			targetdone_packet[15] = next_response_passpw;
			targetdone_packet.range(20,16) = next_response_srctag.read();
			targetdone_packet.range(31,30) = next_response_RqUID.read();
			output_packet_ack = targetdone_packet;

			if(next_response_side.read()) csr_available_fc1_ack = true;
			else csr_available_fc0_ack = true;

			if(fc0_ack_csr.read() || fc1_ack_csr.read()){
				state = CSR_IDLE;
			}
			else{
				state = CSR_IDLE_TARGET_DONE_PENDING;
			}
			break;

		/**
			Since read continuously outputs data, we first have to wait
			that any non sent target done actually be sent.  Then we go
			on to the read operation
		*/
		case CSR_BEGIN_READ_WAIT_TGTDONE:

			output_packet_ack = 0;
			output_packet_ack.range(5,0) = output_packet_command_read_response;
			output_packet_ack[15] = next_response_passpw.read();
			output_packet_ack.range(20,16) = next_response_srctag.read();
			output_packet_ack[29] = next_response_target_abort;
			output_packet_ack.range(31,30) = next_response_RqUID.read();
			targetdone_send_side_ack = next_response_side.read();

			if(next_response_side.read()){
				csr_available_fc1_ack = true;
			}
			else{
				csr_available_fc0_ack = true;
			}

			if(fc0_ack_csr.read() || fc1_ack_csr.read()){
				state = CSR_BEGIN_READ;
			}
			else{
				state = CSR_BEGIN_READ_WAIT_TGTDONE;
			}
			break;

		
		/**
			If the flow control reads the header, this will output the first dword of
			data.  If not, it will keep sending the header.
		*/
		case CSR_BEGIN_READ:

			output_packet_ack = tmp_output_packet_ack;
			output_packet_noack = tmp_output_packet_noack;
			csr_available_fc0_ack = !read_write_side.read();
			csr_available_fc0_noack = !read_write_side.read();
			csr_available_fc1_ack = read_write_side.read();
			csr_available_fc1_noack = read_write_side.read();

			if(fc0_ack_csr.read() || fc1_ack_csr.read()){
				state = CSR_READ;
				read_addr = read_addr.read() + 1;
			}
			else{
				state = CSR_BEGIN_READ;
			}

			break;

		/**
			If the flow control reads the packet, this will output the next dword of
			data.  If not, it will keep sending the current dword.  When the last dword
			has been sent, it goes back to the IDLE state
		*/
		case CSR_READ:

			output_packet_ack = tmp_output_packet_ack;
			output_packet_noack = tmp_output_packet_noack;

			csr_available_fc0_noack = !read_write_side.read();
			csr_available_fc1_noack = read_write_side.read();

			if(counter.read() != 0){
				csr_available_fc0_ack = !read_write_side.read();
				csr_available_fc1_ack = read_write_side.read();
			}
			else{
				csr_available_fc0_ack = false;
				csr_available_fc1_ack = false;
			}

			if(fc0_ack_csr.read() || fc1_ack_csr.read()){
				if(counter.read() != 0){
					counter = counter.read() - 1;
					read_addr = read_addr.read() + 1;
					state = CSR_READ;
				}
				else{
					state = CSR_IDLE;
				}
			}
		break;
			

		//CSR_IDLE
		default:
			//If there is a packet available from side 0
			if(ro0_available_csr.read()){
				read_write_side = false;//Store that the request is from side 0
				csr_ack_ro0 = true;//Read the packet from the reordering
				sc_bv<64> ro0_packet_csr_packet = ro0_packet_csr.read().packet;
				PacketCommand cmd = getPacketCommand(ro0_packet_csr_packet.range(5,0));

				bool cmd_is_read = cmd == READ;
				bool cmd_is_write = cmd == WRITE;
				bool cmd_is_atomic = cmd == ATOMIC;
				
				//Use the address for write and read.  Whatever the packet is, we'll have
				//the good address in write or read
				write_addr = sc_bv<6>(ro0_packet_csr_packet.range(31,26));
				read_addr = sc_bv<6>(ro0_packet_csr_packet.range(31,26));
				
				//Atomic not supported, send response with 1 quadword of data
				if(!cmd_is_atomic)
					counter = sc_bv<4>(ro0_packet_csr_packet.range(25,22));
				else
					counter = 1;

				//Send the correct address to the databuffer
				csr_address_db0	= ro0_packet_csr.read().data_address;
				csr_vctype_db0 = getVirtualChannel(ro0_packet_csr.read().packet, cmd);

				if(cmd_is_read || cmd_is_atomic){
					output_packet_ack = 0;
					output_packet_ack.range(5,0) = output_packet_command_read_response;//Read command
					output_packet_ack[15] = sc_bit(ro0_packet_csr_packet[15]);//PassPW
					output_packet_ack.range(20,16) = ro0_packet_csr_packet.range(20,16);//SrcTag
					output_packet_ack.range(25,22) = ro0_packet_csr_packet.range(25,22);//Count
					output_packet_ack[29] = cmd_is_atomic;//Target Abort when atomic
					output_packet_ack.range(31,30) = ro0_packet_csr_packet.range(9,8);//TqUID
					csr_available_fc0_ack = true;

					if(!tgtdone_waiting_to_be_sent.read()){
						output_packet_noack = 0;
						output_packet_noack.range(5,0) = output_packet_command_read_response;//Read command
						output_packet_noack[15] = sc_bit(ro0_packet_csr_packet[15]);//PassPW
						output_packet_noack.range(20,16) = ro0_packet_csr_packet.range(20,16);//SrcTag
						output_packet_noack.range(25,22) = ro0_packet_csr_packet.range(25,22);//Count
						output_packet_noack[29] = cmd_is_atomic;//Target Abort when atomic
						output_packet_noack.range(31,30) = ro0_packet_csr_packet.range(9,8);//TqUID
						csr_available_fc0_noack = true;
					}
				}

				if(cmd_is_read || cmd_is_atomic){
					//If there is a target done on the output, wait for it to be sent
					//before starting the read operation
					if(tgtdone_waiting_to_be_sent.read() && !fc0_ack_csr.read() && !fc1_ack_csr.read()){
						state = CSR_BEGIN_READ_WAIT_TGTDONE;
					}
					//If a read, start by sending out the read header
					else{
						state = CSR_BEGIN_READ;
					}
				}
				else if(cmd_is_write){
					/*
						Request for the DataBuffer access
					*/
					csr_request_databuffer0_access_ui = true;

					if(sc_bit(ro0_packet_csr_packet[2])){
						state = CSR_BEGIN_DWORD_WRITE;
					}
					else{
						state = CSR_BEGIN_BYTE_WRITE;
					}
				}
				//If it's another packet type, simply ignore it.
				else{
					state = CSR_IDLE;
				}

				//Store the next response value.  This will be useful only if the packet is a non posted 
				//write : a target done will be generated with these values
				next_response_RqUID = ro0_packet_csr_packet.range(9,8);
				next_response_passpw = sc_bit(ro0_packet_csr_packet[15]);
				next_response_srctag = ro0_packet_csr_packet.range(20,16);
				next_response_target_abort = cmd_is_atomic;
				next_posted = sc_bit(ro0_packet_csr_packet[5]);
				next_response_side = false;
			}
			//If there is a packet available from side 1
			else if(ro1_available_csr.read()){
				read_write_side = true;//Store that the request is from side 1
				csr_ack_ro1 = true;//Read the packet from the reordering
				sc_bv<64> ro1_packet_csr_packet = ro1_packet_csr.read().packet;
				PacketCommand cmd = getPacketCommand(ro1_packet_csr_packet.range(5,0));

				bool cmd_is_read = cmd == READ;
				bool cmd_is_write = cmd == WRITE;
				bool cmd_is_atomic = cmd == ATOMIC;
				
				//Use the address for write and read.  Whatever the packet is, we'll have
				//the good address in write or read
				write_addr = sc_bv<6>(ro1_packet_csr_packet.range(31,26));
				read_addr = sc_bv<6>(ro1_packet_csr_packet.range(31,26));
				
				//Atomic not supported, send response with 1 quadword of data
				if(!cmd_is_atomic)
					counter = sc_bv<4>(ro1_packet_csr_packet.range(25,22));
				else
					counter = 1;

				//Send the correct address to the databuffer
				csr_address_db1	= ro1_packet_csr.read().data_address;
				csr_vctype_db1 = getVirtualChannel(ro1_packet_csr.read().packet, cmd);

				if(cmd_is_read || cmd_is_atomic){
					output_packet_ack = 0;
					output_packet_ack.range(5,0) = output_packet_command_read_response;
					output_packet_ack[15] = sc_bit(ro1_packet_csr_packet[15]);
					output_packet_ack.range(20,16) = ro1_packet_csr_packet.range(20,16);
					output_packet_ack[29] = cmd_is_atomic;//Target Abort when atomic
					output_packet_ack.range(31,30) = ro1_packet_csr_packet.range(9,8);
					csr_available_fc1_ack = true;

					if(!tgtdone_waiting_to_be_sent.read()){
						output_packet_noack = 0;
						output_packet_noack.range(5,0) = output_packet_command_read_response;
						output_packet_noack[15] = sc_bit(ro1_packet_csr_packet[15]);
						output_packet_noack.range(20,16) = ro1_packet_csr_packet.range(20,16);
						output_packet_noack[29] = cmd_is_atomic;//Target Abort when atomic
						output_packet_noack.range(31,30) = ro1_packet_csr_packet.range(9,8);
						csr_available_fc1_noack = true;
					}
				}

				if(cmd_is_read || cmd_is_atomic){
					//If there is a target done on the output, wait for it to be sent
					//before starting the read operation
					if(tgtdone_waiting_to_be_sent.read() && !fc0_ack_csr.read() && !fc1_ack_csr.read()){
						state = CSR_BEGIN_READ_WAIT_TGTDONE;
					}
					//If a read, start by sending out the read header
					else{
						state = CSR_BEGIN_READ;
					}
				}
				else if(cmd_is_write){
					/*
						Request for the DataBuffer access
					*/
					csr_request_databuffer1_access_ui = true;

					if(sc_bit(ro1_packet_csr_packet[2])){
						state = CSR_BEGIN_DWORD_WRITE;
					}
					else{
						state = CSR_BEGIN_BYTE_WRITE;
					}
				}
				else{
					state = CSR_IDLE;
				}

				next_response_RqUID = ro1_packet_csr_packet.range(9,8);
				next_response_passpw = sc_bit(ro1_packet_csr_packet[15]);
				next_response_srctag = ro1_packet_csr_packet.range(20,16);
				next_response_target_abort = cmd_is_atomic;
				next_posted = sc_bit(ro1_packet_csr_packet[5]);
				next_response_side = true;
			}
			else{
				state = CSR_IDLE;
			}

		}
		//Output the generated data to the flow controls.  They will only read this if
		//we flag it as available
		if(fc0_ack_csr.read() || fc1_ack_csr.read()){
			output_packet_buf = output_packet_ack;
			csr_dword_fc0 = output_packet_ack;
			csr_dword_fc1 = output_packet_ack;
			tgtdone_waiting_to_be_sent = tgtdone_waiting_to_be_sent_ack;
			targetdone_send_side = targetdone_send_side_ack;
			csr_available_fc0 = csr_available_fc0_ack;
			csr_available_fc1 = csr_available_fc1_ack;
		}
		else{
			output_packet_buf = output_packet_noack;
			csr_dword_fc0 = output_packet_noack;
			csr_dword_fc1 = output_packet_noack;
			tgtdone_waiting_to_be_sent = tgtdone_waiting_to_be_sent_noack;
			targetdone_send_side = targetdone_send_side_noack;
			csr_available_fc0 = csr_available_fc0_noack;
			csr_available_fc1 = csr_available_fc1_noack;
		}
	}
}

void csr_l2::build_output_values(){
	build_device_header_output();
	build_interface_output();
	build_revision_id_output();
	build_unit_id_clumping_output();
#ifdef ENABLE_DIRECTROUTE
	build_direct_route_output();
#endif
#ifdef RETRY_MODE_ENABLED
	build_error_retry_registers_output();
#endif
}

void csr_l2::update_registers_warm(){
	if(!resetx.read()){
		isSyncInitiated_reset();
		manage_device_header_registers_warm_reset();
		manage_interface_registers_warm_reset();
#ifdef ENABLE_DIRECTROUTE
		manage_direct_route_registers_warm_reset();
#endif
#ifdef RETRY_MODE_ENABLED
		manage_error_retry_registers_warm_reset();
#endif
	}
	else{
		isSyncInitiated();
		manage_device_header_registers_warm();
		manage_interface_registers_warm();
#ifdef ENABLE_DIRECTROUTE
		manage_direct_route_registers_warm();
#endif
#ifdef RETRY_MODE_ENABLED
		manage_error_retry_registers_warm();
#endif
	}
	
#ifdef SYSTEMC_SIM
	
	registers_modified_event.notify(SC_ZERO_TIME);
	
#endif

}

void csr_l2::update_registers_cold(){
	if(!pwrok.read()){
		manage_device_header_registers_cold_reset();
		manage_interface_registers_cold_reset();
		manage_unit_id_clumping_registers_cold_reset();
#ifdef ENABLE_DIRECTROUTE
		manage_direct_route_registers_cold_reset();
#endif
#ifdef RETRY_MODE_ENABLED
		manage_error_retry_registers_cold_reset();
#endif
	}
	else{
		manage_device_header_registers_cold();
		manage_interface_registers_cold();
		manage_unit_id_clumping_registers_cold();
#ifdef ENABLE_DIRECTROUTE
		manage_direct_route_registers_cold();
#endif
#ifdef RETRY_MODE_ENABLED
		manage_error_retry_registers_cold();
#endif
	}	
#ifdef SYSTEMC_SIM
	
	registers_modified_event.notify(SC_ZERO_TIME);
	
#endif

}

void csr_l2::build_device_header_output(){
	//VendorID
	config_registers[0] = (sc_uint<8>)Header_VendorID.range(7,0);
	config_registers[1] = (sc_uint<8>)Header_VendorID.range(15,8);

	//DeviceID
	config_registers[2] = (sc_uint<8>)Header_DeviceID.range(7,0);
	config_registers[3] = (sc_uint<8>)Header_DeviceID.range(15,8);

	/***************
	Command register 
	****************/

	config_registers[4] = command_lsb.read();
	config_registers[5] = command_msb.read();

	/*******************************
	Status register
	*******************************/

	//status_lsb : Hardwire- unused bits;
	//Bit 3 is InterruptStatus, also unused
	//Bit 4 is Capabilities List, hardwire to 1
	config_registers[6] = 0x08;
	config_registers[7] = status_msb;
	config_registers[8] = Header_RevisionID;
	config_registers[9] = (sc_uint<8>)Header_ClassCode.range(7,0);
	config_registers[10] = (sc_uint<8>)Header_ClassCode.range(15,8);
	config_registers[11] = (sc_uint<8>)Header_ClassCode.range(23,16);

	//cache line size zero in HT
	config_registers[12] = 0;

	//latency timer register zero in HT
	config_registers[13] = 0;

	//HeaderType : 0x00 for normal, in PCI there is a value for PCI-PCI bridge
	config_registers[14] = Header_HeaderType;

	//BIST - Built-in-self-test, not supported
	config_registers[15] = 0;

	//BARs
	for(int n = 0; n < 6; n++){
		config_registers[16 + 4*n] = bar_slots[n].read().range(7,0);
		config_registers[17 + 4*n] = bar_slots[n].read().range(15,8);
		config_registers[18 + 4*n] = bar_slots[n].read().range(23,16);
		config_registers[19 + 4*n] = bar_slots[n].read().range(31,24);
	}

	/*****************************************
	End of Device Header 
	******************************************/

	// Cardbus CIS pointer - reserved
	config_registers[40] = 0;
	config_registers[41] = 0;
	config_registers[42] = 0;
	config_registers[43] = 0;

	//Subsystem Vendor ID
	config_registers[44] = (sc_uint<8>)Header_SubsystemVendorID.range(7,0);
	config_registers[45] = (sc_uint<8>)Header_SubsystemVendorID.range(15,8);

	//Subsystem ID
	config_registers[46] = (sc_uint<8>)Header_SubsystemID.range(7,0);
	config_registers[47] = (sc_uint<8>)Header_SubsystemID.range(15,8);

	//Expansion ROM - currently not supported
	config_registers[48] = 0;
	config_registers[49] = 0;
	config_registers[50] = 0;
	config_registers[51] = 0;

	//Capabilities Pointer -> points to next block
	config_registers[52] = DeviceHeader_NextPointer;

	//Reserved
	config_registers[53] = 0;
	config_registers[54] = 0;
	config_registers[55] = 0;
	config_registers[56] = 0;
	config_registers[57] = 0;
	config_registers[58] = 0;
	config_registers[59] = 0;

	//Interrupt
	config_registers[60] = interrupt_scratchpad;
	config_registers[61] = 0;
	config_registers[62] = 0;
	config_registers[63] = 0;
}

void csr_l2::manage_device_header_registers_warm_reset(){
	/***************
	Command register 
	****************/
	command_lsb = 0;
	command_msb = 0;

	/*******************************
	BARs
	*******************************/
	sc_bv<32> bar_slots_tmp[6];
	for(int n = 0; n < 6 ; n++){
		bar_slots_tmp[n] = 0;

		// ***  Hard wired bits ***
		bool second_bar_slot = false;
		if(n != 0){
			second_bar_slot = Header_BarSlot64b[n-1];
		}

		if(!second_bar_slot){
			if(Header_BarSlotIOSpace[n]){
				bar_slots_tmp[n][0] = true;
				bar_slots_tmp[n][1] = false;
			}
			else{
				bar_slots_tmp[n][0] = false;
				bar_slots_tmp[n][1] = false;
				bar_slots_tmp[n][2] = Header_BarSlot64b[n];
				bar_slots_tmp[n][3] = Header_BarSlotPrefetchable[n];
			}
		}
		bar_slots[n] = bar_slots_tmp[n];
	}

	//Interrupt line - scratchpad
	interrupt_scratchpad = Header_InterruptLine;
}

void csr_l2::manage_device_header_registers_warm(){


	/***************
	Command register 
	****************/
	sc_bv<8> command_lsb_tmp = command_lsb.read(); 
	sc_bv<8> command_msb_tmp = command_msb.read();

	if(write.read() && write_addr.read() == 1){
		if(sc_bit(write_mask.read()[0])){
			command_lsb_tmp = write_data.read().range(7,0);
		}
		if(sc_bit(write_mask.read()[1])){
			command_msb_tmp = write_data.read().range(7,0);
		}
	}
	//Hardwired to zero registers
	command_lsb_tmp[3] = false; command_lsb_tmp[4] = false; 
	command_lsb_tmp[5] = false; command_lsb_tmp[3] = false;
	command_msb_tmp[1] = false; command_msb_tmp[3] = false; 
	command_msb_tmp[4] = false; command_msb_tmp[5] = false; 
	command_msb_tmp[6] = false; command_msb_tmp[7] = false; 

	command_lsb = command_lsb_tmp;
	command_msb = command_msb_tmp;

	/*******************************
	BARs
	*******************************/
	sc_bv<32> bar_slots_tmp[6];
	for(int n = 0; n < 6 ; n++){
		bar_slots_tmp[n] = bar_slots[n].read();
	}

	for(int n = 0; n < 6 ; n++){

		if(write.read() && write_addr.read() == 4 + n){
			if(sc_bit(write_mask.read()[0])) bar_slots_tmp[n].range(7,0) = write_data.read().range(7,0);
			if(sc_bit(write_mask.read()[1])) bar_slots_tmp[n].range(15,8) = write_data.read().range(15,8);
			if(sc_bit(write_mask.read()[2])) bar_slots_tmp[n].range(23,16) = write_data.read().range(23,16);
			if(sc_bit(write_mask.read()[3])) bar_slots_tmp[n].range(31,24) = write_data.read().range(31,24);
		}


		// ***  Hard wired bits ***
		bool second_bar_slot = false;
		if(n != 0){
			second_bar_slot = Header_BarSlot64b[n-1];
		}

		//Brought and unrolled after the for loop because synthesis tool has problem to use
		//a part select based on the iteration counter of the loop
		//if(Header_BarSlotHardwireZeroes[n]){
			//bar_slots[n].range(Header_BarSlotHarwireSize_m1[n],0) = 0;
		//}


		if(!second_bar_slot){
			if(Header_BarSlotIOSpace[n]){
				bar_slots_tmp[n][0] = true;
				bar_slots_tmp[n][1] = false;
			}
			else{
				bar_slots_tmp[n][0] = false;
				bar_slots_tmp[n][1] = false;
				bar_slots_tmp[n][2] = Header_BarSlot64b[n];
				bar_slots_tmp[n][3] = Header_BarSlotPrefetchable[n];
			}
		}
	}

	if(Header_BarSlotHardwireZeroes0) bar_slots_tmp[0].range(Header_BarSlotHarwireSize0_m1,0) = 0;
	if(Header_BarSlotHardwireZeroes1) bar_slots_tmp[1].range(Header_BarSlotHarwireSize1_m1,0) = 0;
	if(Header_BarSlotHardwireZeroes2) bar_slots_tmp[2].range(Header_BarSlotHarwireSize2_m1,0) = 0;
	if(Header_BarSlotHardwireZeroes3) bar_slots_tmp[3].range(Header_BarSlotHarwireSize3_m1,0) = 0;
	if(Header_BarSlotHardwireZeroes4) bar_slots_tmp[4].range(Header_BarSlotHarwireSize4_m1,0) = 0;
	if(Header_BarSlotHardwireZeroes5) bar_slots_tmp[5].range(Header_BarSlotHarwireSize5_m1,0) = 0;

	for(int n = 0; n < 6 ; n++){
		bar_slots[n] = bar_slots_tmp[n];
	}

	//Interrupt line - scratchpad
	if(write.read() && write_addr.read() == 15 && sc_bit(write_mask.read()[0])){
		interrupt_scratchpad = write_data.read().range(7,0);
	}
}

void csr_l2::manage_device_header_registers_cold_reset(){
	/*******************************
	Status register
	*******************************/
	status_msb = 0;

}

void csr_l2::manage_device_header_registers_cold(){
	/*******************************
	Status register
	*******************************/
	sc_bv<8> status_msb_tmp = status_msb.read();

	bool dataErrorResponse = (sc_bit)command_lsb.read()[6];

	//7.3.2.3 Master Data Error
	if(dataErrorResponse && (ui_sendingPostedDataError_csr.read() || ui_receivedResponseDataError_csr.read())){
		status_msb_tmp[0] = true;
	}
	status_msb_tmp[1] = false; 	status_msb_tmp[2] = false;

	//7.3.2.4 Signaled Target Abort
	if(ui_sendingTargetAbort_csr.read()){
		status_msb_tmp[3] = true;
	}

	//7.3.2.5 Received Target Abort
	if(ui_receivedTargetAbort_csr.read()){
		status_msb_tmp[4] = true;
	}

	if(ui_receivedMasterAbort_csr.read()){
		status_msb_tmp[5] = true;
	}

	if(sync_initiated)		
	{
		status_msb_tmp[6] = true;
	}

	if(ui_receivedResponseDataError_csr.read() || ui_receivedPostedDataError_csr.read()){
		status_msb_tmp[7] = true;
	}

	//Clear status MSB on write
	if(write.read() && write_addr.read() == 1 && sc_bit(write_mask.read()[3])){
		status_msb_tmp = status_msb_tmp & ~(write_data.read().range(31,24));
	}

	status_msb = status_msb_tmp;

}

void csr_l2::build_interface_output(){
	//Capability ID
	config_registers[Interface_Pointer] = 0x08;

	//Capability pointer
	config_registers[Interface_Pointer + 1] = Interface_NextPointer;

	//Command register
	config_registers[Interface_Pointer + 2] = interface_command_lsb;
	config_registers[Interface_Pointer + 3] = interface_command_msb;

	//Link control 0
	sc_bv<8> link_control0_lsb_merged = link_control_0_lsb;
	link_control0_lsb_merged[4] = link_control_0_lsb_cold4;
	sc_bv<8> link_control0_msb_merged = link_control_0_msb;
	link_control0_msb_merged[0] = link_control_0_msb_cold0;
	config_registers[Interface_Pointer + 4] = link_control0_lsb_merged;
	config_registers[Interface_Pointer + 5] = link_control0_msb_merged;

	/******************************
	Link configuration register 0
	******************************/

	sc_uint<8> link_config_0_lsb;
	link_config_0_lsb.range(2,0) = Interface_MaxLinkWidthIn0;
	link_config_0_lsb[3] = Interface_DoubleWordFlowControlIn0;
	link_config_0_lsb.range(6,4) = Interface_MaxLinkWidthOut0;
	link_config_0_lsb[3] = Interface_DoubleWordFlowControlOut0;

	config_registers[Interface_Pointer + 6] = link_config_0_lsb;
	config_registers[Interface_Pointer + 7] = link_config_0_msb;

	//Link control 1
	sc_bv<8> link_control1_lsb_merged = link_control_1_lsb;
	link_control1_lsb_merged[4] = link_control_1_lsb_cold4;
	sc_bv<8> link_control1_msb_merged = link_control_1_msb;
	link_control1_msb_merged[0] = link_control_1_msb_cold0;
	config_registers[Interface_Pointer + 8] = link_control0_lsb_merged;
	config_registers[Interface_Pointer + 9] = link_control0_msb_merged;

	/******************************
	Link configuration register 1
	******************************/

	sc_uint<8> link_config_1_lsb;
	link_config_0_lsb.range(2,0) = Interface_MaxLinkWidthIn1;
	link_config_0_lsb[3] = Interface_DoubleWordFlowControlIn1;
	link_config_0_lsb.range(6,4) = Interface_MaxLinkWidthOut1;
	link_config_0_lsb[3] = Interface_DoubleWordFlowControlOut1;

	config_registers[Interface_Pointer + 10] = link_config_1_lsb;
	config_registers[Interface_Pointer + 11] = link_config_1_msb;

	/***************************
	Other registers
	****************************/
	
	config_registers[Interface_Pointer + 12] = Interface_RevisionID;

	config_registers[Interface_Pointer + 13] = link_freq_and_error0;

	config_registers[Interface_Pointer + 14] = (sc_uint<8>)Interface_LinkFrequencyCapability0.range(7,0);
	config_registers[Interface_Pointer + 15] = (sc_uint<8>)Interface_LinkFrequencyCapability0.range(15,8);

	//Feature - We support LDTSOP (bit 1) 
	sc_bv<8> feature_tmp = 1;
	feature_tmp[5] = reorder_disable.read();
	config_registers[Interface_Pointer + 16] = feature_tmp;

	config_registers[Interface_Pointer + 17] = link_freq_and_error1;

	config_registers[Interface_Pointer + 18] = (sc_uint<8>)Interface_LinkFrequencyCapability1.range(7,0);
	config_registers[Interface_Pointer + 19] = (sc_uint<8>)Interface_LinkFrequencyCapability1.range(15,8);

	//Enumeration scratchpad
	config_registers[Interface_Pointer + 20] = enum_scratchpad_lsb;
	config_registers[Interface_Pointer + 21] = enum_scratchpad_msb;

	//Error control
	sc_bv<8> error_lsb = 0;
	error_lsb[0] = protocol_error_flood_en.read();
	error_lsb[1] = overflow_error_flood_en.read();
	//Protocol Error fatal enable (hardwired 0) - bit 2
	//Overflow Error fatal enable (hardwired 0) - bit 3
	//End of chain Error fatal enable (hardwired 0) - bit 4
	//Response Error fatal enable (hardwired 0) - bit 5
	//CRC Error fatal enable (hardwired 0) - bit 6
	//System Error fatal enable (hardwired 0) - bit 7
	//Response Error fatal enable (hardwired 0) - bit 8
	config_registers[Interface_Pointer + 22] = error_lsb;

	sc_bv<8> error_msb = 0;
	error_msb[0] = chain_fail.read();
	error_msb[0] = response_error.read();

	//Protocol error nonfatal enable (hardwire 0) - bit 2
	//Overflow error nonfatal enable (hardwire 0) - bit 3
	//End of chain error nonfatal enable (hardwire 0) - bit 4
	//Response error nonfatal enable (hardwire 0) - bit 5
	//CRC error nonfatal enable (hardwire 0) - bit 6
	//System error nonfatal enable (hardwire 0) - bit 7
	config_registers[Interface_Pointer + 23] = error_msb;

	/************************
	Mem base Upper (for bridges)
	*************************/
	config_registers[Interface_Pointer + 24] = 0;

	/************************
	Mem limit Upper (for bridges)
	*************************/
	config_registers[Interface_Pointer + 25] = 0;

	config_registers[Interface_Pointer + 26] = bus_number;

	//Reserved
	config_registers[Interface_Pointer + 27] = 0;
}

void csr_l2::manage_interface_registers_warm_reset(){
	/*******************************
	Command register
	********************************/
	interface_command_lsb = 0;
	interface_command_msb = 0;

	/**********************************
	Link Control 0
	***********************************/
	link_control_0_lsb = 0;
	link_control_0_msb = 0;

	/**********************************
	Link Control 1
	***********************************/
	link_control_1_lsb = 0;
	link_control_1_msb = 0;

	/***********************
	Link Feature
	************************/
#ifdef ENABLE_REORDERING
	reorder_disable = false;
#else
	//Reordering is always disabled
	reorder_disable = true;
#endif

	/***********************
	Error Handling
	************************/
	protocol_error_flood_en = false;
	overflow_error_flood_en = false;
	chain_fail = false;

}


void csr_l2::manage_interface_registers_warm(){

	/*******************************
	Command register
	********************************/
	//int interface_command_lsb = (Interface_Pointer + 2)*8;
	//int command_msb_pos = (Interface_Pointer + 3)*8;
	sc_bv<8> interface_command_lsb_tmp = interface_command_lsb.read();
	sc_bv<8> interface_command_msb_tmp = interface_command_msb.read();

	//Base unitID
	if(write.read() && write_addr.read() == Interface_Pointer/4 && sc_bit(write_mask.read()[2])){
		interface_command_lsb_tmp.range(4,0) = write_data.read().range(20,16);
	}

	//Unit count : for now, hard code it to 0
	interface_command_lsb_tmp[5] = false;
	interface_command_lsb_tmp[6] = false;
	interface_command_lsb_tmp[7] = false;

	if(write.read() && write_addr.read() == Interface_Pointer/4 && 
		(sc_bit(write_mask.read()[3]) || sc_bit(write_mask.read()[2])) ){
		//Master host bit
		interface_command_msb_tmp[2] = write_from_side;
	}
	if(write.read() && write_addr.read() == Interface_Pointer/4 && 
		sc_bit(write_mask.read()[3])){
		//Default direction
		interface_command_msb_tmp[3] = sc_bit(write_data.read()[26]);
		//Drop on Uninitialized Link
		interface_command_msb_tmp[4] = sc_bit(write_data.read()[27]);
	}

	//Capability type : 000 for Slave or Primary Interface
	interface_command_msb_tmp[0] = false;
	interface_command_msb_tmp[1] = false;
	interface_command_msb_tmp[5] = false;
	interface_command_msb_tmp[6] = false;
	interface_command_msb_tmp[7] = false;

	interface_command_lsb = interface_command_lsb_tmp;
	interface_command_msb = interface_command_msb_tmp;

	/**********************************
	Link Control 0
	***********************************/

	sc_bv<8> link_control_0_lsb_tmp = link_control_0_lsb.read();
	sc_bv<8> link_control_0_msb_tmp = link_control_0_msb.read();


	bool write_link_control_0_lsb = write.read() && write_addr.read() == Interface_Pointer/4 + 1 && 
			sc_bit(write_mask.read()[0]);

	if(write_link_control_0_lsb){
		//CRC Flood enable
		link_control_0_lsb_tmp[1] = sc_bit(write_data.read()[1]);
		//Force CRC error
		link_control_0_lsb_tmp[3] = sc_bit(write_data.read()[3]);
		//Transmitter off
		link_control_0_lsb_tmp[7] = sc_bit(write_data.read()[7]);
	}
	//Initialisation complete
	if(lk0_initialization_complete_csr.read())
			link_control_0_lsb_tmp[5] = true;
	//End of chain
	if(lk0_update_link_failure_property_csr.read()){
		link_control_0_lsb_tmp[6] = lk0_link_failure_csr.read();
	}
	else if(write_link_control_0_lsb && sc_bit(write_data.read()[6])){
		link_control_0_lsb_tmp[6] = true;
	}

	link_control_0_lsb_tmp[0] = false;
	//CRC start test - not supported, hardwired to zero
	link_control_0_lsb_tmp[2] = false;
	//config_registers[link_control_0_lsb_pos+4] evaluated in cold reset process
	//Hardwire to zero here, but select right value when building output
	link_control_0_lsb_tmp[4] = false;

	//Ldtstop tristate enable - depends on platform!
	//Extended ctl time
	if(write.read() && write_addr.read() == Interface_Pointer/4 + 1 && 
			sc_bit(write_mask.read()[1])){
		link_control_0_msb_tmp[5] = sc_bit(write_data.read()[13]);
		link_control_0_msb_tmp[6] = sc_bit(write_data.read()[14]);
	}

	//config_registers[link_control_0_msb_pos+0] evaluated int cold reset process
	//Hardwire to zero here, but select right value when building output
	link_control_0_msb_tmp[0] = false;
	link_control_0_msb_tmp[1] = false;
	link_control_0_msb_tmp[2] = false;
	link_control_0_msb_tmp[3] = false;
	//Iso flow enable - not supported
	link_control_0_msb_tmp[4] = false;
	//64 bit addressing enable - not supported, hardwired to 0
	link_control_0_msb_tmp[7] = false;

	link_control_0_lsb = link_control_0_lsb_tmp;
	link_control_0_msb = link_control_0_msb_tmp;


	/**********************************
	Link Control 1
	***********************************/

	sc_bv<8> link_control_1_lsb_tmp = link_control_1_lsb.read();
	sc_bv<8> link_control_1_msb_tmp = link_control_1_msb.read();


	bool write_link_control_1_lsb = write.read() && write_addr.read() == Interface_Pointer/4 + 2 && 
			sc_bit(write_mask.read()[0]);

	if(write_link_control_1_lsb){
		//CRC Flood enable
		link_control_1_lsb_tmp[1] = sc_bit(write_data.read()[1]);
		//Force CRC error
		link_control_1_lsb_tmp[3] = sc_bit(write_data.read()[3]);
		//Transmitter off
		link_control_1_lsb_tmp[7] = sc_bit(write_data.read()[7]);
	}
	//Initialisation complete
	if(lk1_initialization_complete_csr.read())
			link_control_1_lsb_tmp[5] = true;
	//End of chain
	if(lk1_update_link_failure_property_csr.read()){
		link_control_1_lsb_tmp[6] = lk1_link_failure_csr.read();
	}
	else if(write_link_control_1_lsb && sc_bit(write_data.read()[6])){
		link_control_1_lsb_tmp[6] = true;
	}

	link_control_1_lsb_tmp[0] = false;
	//CRC start test - not supported, hardwired to zero
	link_control_1_lsb_tmp[2] = false;
	//config_registers[link_control_0_lsb_pos+4] evaluated in cold reset process
	//Hardwire to zero here, but select right value when building output
	link_control_1_lsb_tmp[4] = false;

	//Ldtstop tristate enable - depends on platform!
	//Extended ctl time
	if(write.read() && write_addr.read() == Interface_Pointer/4 + 2 && 
			sc_bit(write_mask.read()[1])){
		link_control_1_msb_tmp[5] = sc_bit(write_data.read()[13]);
		link_control_1_msb_tmp[6] = sc_bit(write_data.read()[14]);
	}

	//config_registers[link_control_0_msb_pos+0] evaluated int cold reset process
	//Hardwire to zero here, but select right value when building output
	link_control_1_msb_tmp[0] = false;
	link_control_1_msb_tmp[1] = false;
	link_control_1_msb_tmp[2] = false;
	link_control_1_msb_tmp[3] = false;
	//Iso flow enable - not supported
	link_control_1_msb_tmp[4] = false;
	//64 bit addressing enable - not supported, hardwired to 0
	link_control_1_msb_tmp[7] = false;

	link_control_1_lsb = link_control_1_lsb_tmp;
	link_control_1_msb = link_control_1_msb_tmp;


	/***********************
	Link 0 stuff
	************************/

	//In cold reset
	//config_registers[(Interface_Pointer + 13)*8];


	/***********************
	Link Feature
	************************/
#ifdef ENABLE_REORDERING
	//Reorder disable bit
	if(write.read() && write_addr.read() == Interface_Pointer/4 + 4 && 
			sc_bit(write_mask.read()[1])) 
		reorder_disable = (sc_bit)write_data.read()[5];
#else
	//Reordering is always disabled
	reorder_disable = true;
#endif

	/***********************
	Link 1 stuff
	************************/

	//Link ERROR in cold reset process


	/***********************
	Error Handling
	************************/

	//Protocol Error flood enable (RW) - bit 0
	//Overflow Error flood enable (RW) - bit 1
	if(write.read() && write_addr.read() == Interface_Pointer/4 + 5 && sc_bit(write_mask.read()[2])){
		protocol_error_flood_en = sc_bit(write_data.read()[16]);
		overflow_error_flood_en = sc_bit(write_data.read()[17]);
	}


	//Chain fail
	if(sync_initiated.read() || cd0_sync_detected_csr.read() /* || lk0_sync_detected_csr.read()*/
		|| cd1_sync_detected_csr.read() /*|| lk1_sync_detected_csr.read()*/){
		chain_fail = true;
	}
}

void csr_l2::manage_interface_registers_cold_reset(){
	link_control_0_lsb_cold4 = false;
	link_control_1_lsb_cold4 = false;
	link_control_0_msb_cold0 = false;
	link_control_1_msb_cold0 = false;

	//Link width in & out
	link_config_0_msb = 0;
	link_config_1_msb = 0;

	link0WidthIn = 0;
	link0WidthOut = 0;
	link1WidthIn = 0;
	link1WidthOut = 0;

	//******************
	// Link Error 0
	//******************
	link_freq_and_error0 = 0;
	link_freq_and_error1 = 0;

	//scratchpad
	enum_scratchpad_lsb = 0;
	enum_scratchpad_msb = 0;

	//Response error in cold reset process
	response_error = false;

	/************************
	Bus number in cold reset process
	************************/
	bus_number = 0;
}

void csr_l2::manage_interface_registers_cold(){

	bool write_link_control_0_lsb = write.read() && write_addr.read() == Interface_Pointer/4 + 1 && 
			sc_bit(write_mask.read()[0]);

	//Link Failure 0
	if(sync_initiated.read() || lk0_update_link_failure_property_csr.read() && lk0_link_failure_csr.read()){
		link_control_0_lsb_cold4 = true;
	}
	else if(write_link_control_0_lsb && sc_bit(write_data.read()[4])){
		link_control_0_lsb_cold4 = false;
	}

	//Link Failure 1
	bool write_link_control_1_lsb = write.read() && write_addr.read() == Interface_Pointer/4 + 2 && 
			sc_bit(write_mask.read()[0]);

	if(sync_initiated.read() || lk1_update_link_failure_property_csr.read() && lk1_link_failure_csr.read()){
		link_control_1_lsb_cold4 = true;
	}
	else if(write_link_control_1_lsb && sc_bit(write_data.read()[4])){
		link_control_1_lsb_cold4 = false;
	}

	//CRC error - We only have one lane so 3 msb bits are hardwired to 0
	if(lk0_crc_error_csr.read()){
		link_control_0_msb_cold0 = true;
	}

	//CRC error - We only have one lane so 3 msb bits are hardwired to 0
	if(lk1_crc_error_csr.read()){
		link_control_1_msb_cold0 = true;
	}


	//Link width in & out
	if(lk0_update_link_width_csr.read()){
		sc_bv<8> tmp = 0;
		tmp.range(2,0) = lk0_sampled_link_width_csr.read();
		tmp.range(6,4) = lk0_sampled_link_width_csr.read();
		link_config_0_msb = tmp;
	}
	else if(!ldtstopx.read() || !resetx.read()){
		sc_bv<8> tmp = 0;
		tmp.range(2,0) = link0WidthIn.read();
		tmp.range(6,4) = link0WidthOut.read();
		link_config_0_msb = tmp;
	}
	
	if(lk0_update_link_width_csr.read()){
		link0WidthIn = lk0_sampled_link_width_csr.read();
		link0WidthOut = lk0_sampled_link_width_csr.read();
	}
	else if(write.read() && write_addr.read() == Interface_Pointer/4 + 2 && 
		sc_bit(write_mask.read()[3])){
		link0WidthIn = write_data.read().range(26,24);
		link0WidthOut = write_data.read().range(30,28);
	}

	if(lk1_update_link_width_csr.read()){
		sc_bv<8> tmp = 0;
		tmp.range(2,0) = lk1_sampled_link_width_csr.read();
		tmp.range(6,4) = lk1_sampled_link_width_csr.read();
		link_config_1_msb = tmp;
	}
	else if(!ldtstopx.read() || !resetx.read()){
		sc_bv<8> tmp = 0;
		tmp.range(2,0) = link1WidthIn.read();
		tmp.range(6,4) = link1WidthOut.read();
		link_config_1_msb = tmp;
	}
	
	if(lk1_update_link_width_csr.read()){
		link1WidthIn = lk1_sampled_link_width_csr.read();
		link1WidthOut = lk1_sampled_link_width_csr.read();
	}
	else if(write.read() && write_addr.read() == Interface_Pointer/4 + 1 && 
		sc_bit(write_mask.read()[3])){
		link1WidthIn = write_data.read().range(26,24);
		link1WidthOut = write_data.read().range(30,28);
	}

	//***************************
	// Link Frequency and Error 0
	//***************************

	bool write_link_error0 = write.read() && write_addr.read() == Interface_Pointer/4 + 3 && 
		sc_bit(write_mask.read()[1]);


	sc_bv<8> link_freq_and_error0_tmp = link_freq_and_error0;

	//Protocol Error (in cold reset process)
	if((cd0_protocol_error_csr.read() || lk0_protocol_error_csr.read())
#ifdef RETRY_MODE_ENABLED
		&& !csr_retry0.read()
#endif
		) link_freq_and_error0_tmp[4] = true;
	else if(write_link_error0 && sc_bit(write_data.read()[12])) 
		link_freq_and_error0_tmp[4] = false;

	if(db0_overflow_csr.read() || ro0_overflow_csr.read()) 
		link_freq_and_error0_tmp[5] = true;
	else if(write_link_error0 && sc_bit(write_data.read()[13])) 
		link_freq_and_error0_tmp[5] = false;

	//End of Chain Error - If error handler consumes a packet, it means
	//there is an end of chain error.
	if(eh0_ack_ro0.read()) 
		link_freq_and_error0_tmp[6] = true;
	else if(write_link_error0 && sc_bit(write_data.read()[14])) 
		link_freq_and_error0_tmp[6] = false;

	//CTL Timeout
	if(write_link_error0) 
		link_freq_and_error0_tmp[7] = sc_bit(write_data.read()[15]);

	if(write_link_error0) 
		link_freq_and_error0_tmp.range(3,0) = write_data.read().range(11,8);
	link_freq_and_error0 = link_freq_and_error0_tmp;

	//***************************
	// Link Frequency and Error 1
	//***************************

	bool write_link_error1 = write.read() && write_addr.read() == Interface_Pointer/4 + 4 && 
		sc_bit(write_mask.read()[1]);

	sc_bv<8> link_freq_and_error1_tmp = link_freq_and_error1;


	//Protocol Error (in cold reset process)
	if((cd1_protocol_error_csr.read() || lk1_protocol_error_csr.read())
#ifdef RETRY_MODE_ENABLED
		&& !csr_retry1.read()
#endif
		) link_freq_and_error1_tmp[4] = true;
	else if(write_link_error1 && sc_bit(write_data.read()[12])) 
		link_freq_and_error1_tmp[4] = false;

	if(db1_overflow_csr.read() || ro1_overflow_csr.read()) 
		link_freq_and_error1_tmp[5] = true;
	else if(write_link_error1 && sc_bit(write_data.read()[13])) 
		link_freq_and_error1_tmp[5] = false;

	//End of Chain Error - If error handler consumes a packet, it means
	//there is an end of chain error.
	if(eh1_ack_ro1.read()) 
		link_freq_and_error1_tmp[6] = true;
	else if(write_link_error1 && sc_bit(write_data.read()[14])) 
		link_freq_and_error1_tmp[6] = false;

	//CTL Timeout
	if(write_link_error1) 
		link_freq_and_error1_tmp[7] = sc_bit(write_data.read()[15]);

	if(write_link_error1) 
		link_freq_and_error1_tmp.range(3,0) = write_data.read().range(11,8);

	link_freq_and_error1 = link_freq_and_error1_tmp;

	//Enumeration scratchpad in cold reset process
	if(write.read() && write_addr.read() == Interface_Pointer/4 + 5){
		if(sc_bit(write_mask.read()[0]))
			enum_scratchpad_lsb = write_data.read().range(7,0);
		if(sc_bit(write_mask.read()[1]))
			enum_scratchpad_msb = write_data.read().range(15,8);
	}

	//Response error in cold reset process
	if(usr_receivedResponseError_csr.read()){
		response_error = true;
	}
	else if(write.read() && write_addr.read() == Interface_Pointer/4 + 5 
		&& sc_bit(write_mask.read()[3]) && sc_bit(write_data.read()[25])){
		response_error = false;
	}

	/************************
	Bus number in cold reset process
	*************************/
	if(write.read() && write_addr.read() == Interface_Pointer/4 + 6 
		&& sc_bit(write_mask.read()[2])){
		bus_number = write_data.read().range(23,16);
	}

}

#ifdef ENABLE_DIRECTROUTE
void csr_l2::build_direct_route_output(){
	//Capability ID
	config_registers[DirectRoute_Pointer] = 0x08;
	//Capability pointer
	config_registers[DirectRoute_Pointer + 1] = DirectRoute_NextPointer;

	//The number of direct route spaces
	sc_uint<8> num_spaces_and_indexlsb;
	num_spaces_and_indexlsb.range(3,0)= DirectRoute_NumberDirectRouteSpaces;
	num_spaces_and_indexlsb.range(7,4)= direct_route_index.read().range(3,0);
	config_registers[DirectRoute_Pointer+2] = num_spaces_and_indexlsb;

	sc_uint<8> indexmsb_and_captype = 0;
	indexmsb_and_captype[0] = direct_route_index.read()[4];
	indexmsb_and_captype.range(7,3) = 0x16;
	config_registers[DirectRoute_Pointer + 3] = indexmsb_and_captype;

	config_registers[DirectRoute_Pointer + 4] = (sc_bv<8>)direct_route_enable.read().range(7,0);
	config_registers[DirectRoute_Pointer + 5] = (sc_bv<8>)direct_route_enable.read().range(15,8);
	config_registers[DirectRoute_Pointer + 6] = (sc_bv<8>)direct_route_enable.read().range(23,16);
	config_registers[DirectRoute_Pointer + 7] = (sc_bv<8>)direct_route_enable.read().range(31,24);

	if(direct_route_index.read() >= 4*DirectRoute_NumberDirectRouteSpaces){
		config_registers[DirectRoute_Pointer + 8] = false;
		config_registers[DirectRoute_Pointer + 9] = false;
		config_registers[DirectRoute_Pointer + 10] = false;
		config_registers[DirectRoute_Pointer + 11] = false;
	}
	else{
		config_registers[DirectRoute_Pointer + 8] = direct_route_data[direct_route_index.read()].read().range(7,0);
		config_registers[DirectRoute_Pointer + 9] = direct_route_data[direct_route_index.read()].read().range(15,8);
		config_registers[DirectRoute_Pointer + 10] = direct_route_data[direct_route_index.read()].read().range(23,16);
		config_registers[DirectRoute_Pointer + 11] = direct_route_data[direct_route_index.read()].read().range(31,24);
	}
}

void csr_l2::manage_direct_route_registers_warm_reset(){
	direct_route_index = 0;
	for(int n = 0; n < 4*DirectRoute_NumberDirectRouteSpaces;n++){
		direct_route_data[n] = 0;
	}
}

void csr_l2::manage_direct_route_registers_warm(){
	//The index
	sc_uint<5> direct_route_index_tmp = direct_route_index.read();
	if(write.read() && write_addr.read() == DirectRoute_Pointer/4
		&& sc_bit(write_mask.read()[2])){
		direct_route_index_tmp.range(3,0) = (sc_bv<4>)write_data.read().range(23,20);
	}
	if(write.read() && write_addr.read() == DirectRoute_Pointer/4
		&& sc_bit(write_mask.read()[3])){
		direct_route_index_tmp[4] = (sc_bit)write_data.read()[24];
	}
	direct_route_index = direct_route_index_tmp;

	//This is for reset and write to the data port
	if(write.read() && write_addr.read() == DirectRoute_Pointer/4+2){
		for(int n = 0 ; n < 4*DirectRoute_NumberDirectRouteSpaces;n++){
			if(n == direct_route_index.read()){
				sc_bv<32> current_direct_route_data = direct_route_data[n];
				if(sc_bit(write_mask.read()[0])) current_direct_route_data.range(7,0) = write_data.read().range(7,0);
				if(sc_bit(write_mask.read()[1])) current_direct_route_data.range(15,8) = write_data.read().range(15,8);
				if(sc_bit(write_mask.read()[2])) current_direct_route_data.range(23,16) = write_data.read().range(23,16);
				if(sc_bit(write_mask.read()[3])) current_direct_route_data.range(31,24) = write_data.read().range(31,24);
				direct_route_data[n] = current_direct_route_data;
			}
		}
	}

}

void csr_l2::manage_direct_route_registers_cold_reset(){
	direct_route_enable = 0;
}

void csr_l2::manage_direct_route_registers_cold(){
	//DirectRoute enable in cold reset process
	if(write.read() && write_addr.read() == DirectRoute_Pointer/4+1){
		sc_bv<32> direct_route_enable_tmp = direct_route_enable.read();
		if(sc_bit(write_mask.read()[0])){
			direct_route_enable_tmp.range(7,0) = write_data.read().range(7,0);
		}
		if(sc_bit(write_mask.read()[1])){
			direct_route_enable_tmp.range(15,8) = write_data.read().range(15,8);
		}
		if(sc_bit(write_mask.read()[2])){
			direct_route_enable_tmp.range(23,16) = write_data.read().range(23,16);
		}
		if(sc_bit(write_mask.read()[3])){
			direct_route_enable_tmp.range(31,24) = write_data.read().range(31,24);
		}
		direct_route_enable = direct_route_enable_tmp;
	}
}
//ENABLE_DIRECTROUTE
#endif

void csr_l2::build_revision_id_output(){
	config_registers[RevisionID_Pointer  ] = 0x08;
	config_registers[RevisionID_Pointer+1] = RevisionID_NextPointer;
	config_registers[RevisionID_Pointer+2] = Header_RevisionID;
	config_registers[RevisionID_Pointer+3] = 0x88;
}

void csr_l2::build_unit_id_clumping_output(){
	config_registers[UnitIDClumping_Pointer] = 0x08;
	config_registers[UnitIDClumping_Pointer+1] = UnitIDClumping_NextPointer;
	config_registers[UnitIDClumping_Pointer+2] = 0;
	config_registers[UnitIDClumping_Pointer+3] = 0x88;

	//By default, we only have a single UnitID, so we don't request clumping
	//UnitID clumping support (clumping between our UnitIDs)
	config_registers[UnitIDClumping_Pointer+4] = 0;
	config_registers[UnitIDClumping_Pointer+5] = 0;
	config_registers[UnitIDClumping_Pointer+6] = 0;
	config_registers[UnitIDClumping_Pointer+7] = 0;

	//UnitID clumping enable
	config_registers[UnitIDClumping_Pointer+8] = clumping_enable.read().range(7,0);
	config_registers[UnitIDClumping_Pointer+9] = clumping_enable.read().range(15,8);
	config_registers[UnitIDClumping_Pointer+10] = clumping_enable.read().range(23,16);
	config_registers[UnitIDClumping_Pointer+11] = clumping_enable.read().range(31,24);

}

void csr_l2::manage_unit_id_clumping_registers_cold_reset(){
	clumping_enable = 0;
}

void csr_l2::manage_unit_id_clumping_registers_cold(){

	//UnitID clumping enable
	if(write.read() && write_addr.read() == UnitIDClumping_Pointer/4+2){
		sc_bv<32> clumping_enable_tmp = clumping_enable;
		if(sc_bit(write_mask.read()[0])){
			clumping_enable_tmp.range(7,0) = write_data.read().range(7,0);		
		}
		if(sc_bit(write_mask.read()[1])){
			clumping_enable_tmp.range(15,8) = write_data.read().range(15,8)	;	
		}
		if(sc_bit(write_mask.read()[2])){
			clumping_enable_tmp.range(23,16) = write_data.read().range(23,16);		
		}
		if(sc_bit(write_mask.read()[3])){
			clumping_enable_tmp.range(31,24) = write_data.read().range(31,24);		
		}
		clumping_enable_tmp[0] = false;
		clumping_enable = clumping_enable_tmp;
	}
}

#ifdef RETRY_MODE_ENABLED

void csr_l2::build_error_retry_registers_output(){
	config_registers[ErrorRetry_Pointer] = 0x08;
	config_registers[ErrorRetry_Pointer+1] = ErrorRetry_NextPointer;
	config_registers[ErrorRetry_Pointer+2] = 0;
	config_registers[ErrorRetry_Pointer+3] = 0xC0;

	sc_bv<8> error_retry_control0_merged = error_retry_control0;
	error_retry_control0_merged[0] = error_retry_control0_cold0;
	config_registers[ErrorRetry_Pointer+4] = error_retry_control0_merged;
	config_registers[ErrorRetry_Pointer+5] = error_retry_status0;

	sc_bv<8> error_retry_control1_merged = error_retry_control1;
	error_retry_control1_merged[0] = error_retry_control1_cold0;
	config_registers[ErrorRetry_Pointer+6] = error_retry_control1_merged;
	config_registers[ErrorRetry_Pointer+7] = error_retry_status1;

	config_registers[ErrorRetry_Pointer+8] = (sc_uint<8>)error_retry_count0.read().range(7,0);
	config_registers[ErrorRetry_Pointer+9] = (sc_uint<8>)error_retry_count0.read().range(15,8);
	config_registers[ErrorRetry_Pointer+10] = (sc_uint<8>)error_retry_count1.read().range(7,0);
	config_registers[ErrorRetry_Pointer+11] = (sc_uint<8>)error_retry_count1.read().range(15,8);

}

void csr_l2::manage_error_retry_registers_warm_reset(){
	//11000000
	error_retry_control0 = 0xC0;
	error_retry_control1 = 0xC0;

	error_retry_count0 = 0;
	error_retry_count1 = 0;
}

void csr_l2::manage_error_retry_registers_warm(){
	/*************************
	Retry control 0
	**************************/


	sc_bv<8> error_retry_control0_tmp = error_retry_control0;

	//Bit0 in cold reset
	//set it to zero here, it will be overriden with correct value at output
	error_retry_control0_tmp[0] = false;

	//Force single error
	if(fc0_clear_single_error_csr.read()){
		error_retry_control0_tmp[1] = false;
	}
	else if(write.read() && write_addr.read() == ErrorRetry_Pointer/4+1 && 
			sc_bit(write_mask.read()[0]) && sc_bit(write_data.read()[1])){
		error_retry_control0_tmp[1] = true;
	}

	//Interrupts not supported, hardwired to 0
	//Rollover Nonfatal Enable
	error_retry_control0_tmp[2] = false;

	//Force single stomp
	if(fc0_clear_single_stomp_csr.read()){
		error_retry_control0_tmp[3] = false;
	}
	else if(write.read() && write_addr.read() == ErrorRetry_Pointer/4+1 && 
			sc_bit(write_mask.read()[0]) && sc_bit(write_data.read()[3])){
		error_retry_control0_tmp[3] = true;
	}

	//Interrupts not supported, hardwired to 0
	//Retry Nonfatal Enable
	error_retry_control0_tmp[4] = false;
	//Retry Fatal Enable
	error_retry_control0_tmp[5] = false;

	//Retry enable
	//Allowed attempts
	if(write.read() && write_addr.read() == ErrorRetry_Pointer/4+1 && 
				sc_bit(write_mask.read()[0])){
		error_retry_control0_tmp[6] = sc_bit(write_data.read()[6]);
		error_retry_control0_tmp[7] = sc_bit(write_data.read()[7]);
	}

	error_retry_control0 = error_retry_control0_tmp;

	/*************************
	Retry status 0 in cold reset
	**************************/

	/*************************
	Retry control 1
	**************************/

	sc_bv<8> error_retry_control1_tmp = error_retry_control1;

	//Bit0 in cold reset
	//set it to zero here, it will be overriden with correct value at output
	error_retry_control1_tmp[0] = false;


	//Force single error
	if(fc1_clear_single_error_csr.read()){
		error_retry_control1_tmp[1] = false;
	}
	else if(write.read() && write_addr.read() == ErrorRetry_Pointer/4+1 && 
			sc_bit(write_mask.read()[2]) && sc_bit(write_data.read()[17])){
		error_retry_control1_tmp[1] = true;
	}

	//Interrupts not supported, hardwired to 0
	//Rollover Nonfatal Enable
	error_retry_control1_tmp[2] = false;

	//Force single stomp
	if(fc1_clear_single_stomp_csr.read()){
		error_retry_control1_tmp[3] = false;
	}
	else if(write.read() && write_addr.read() == ErrorRetry_Pointer/4+1 && 
			sc_bit(write_mask.read()[2]) && sc_bit(write_data.read()[19])){
		error_retry_control1_tmp[3] = true;
	}

	//Interrupts not supported, hardwired to 0
	//Retry Nonfatal Enable
	error_retry_control1_tmp[4] = false;
	//Retry Fatal Enable
	error_retry_control1_tmp[5] = false;

	//Retry enable
	//Allowed attempts
	if(write.read() && write_addr.read() == ErrorRetry_Pointer/4+1 && 
				sc_bit(write_mask.read()[2])){
		error_retry_control1_tmp[6] = sc_bit(write_data.read()[22]);
		error_retry_control1_tmp[7] = sc_bit(write_data.read()[23]);
	}

	error_retry_control1 = error_retry_control1_tmp;

	/*************************
	Retry status 1 in cold reset
	**************************/

	/*******************************
	Retry count 0
	*******************************/
	if(cd0_initiate_retry_disconnect.read() || lk0_initiate_retry_disconnect.read()){
		error_retry_count0 = error_retry_count0.read() + 1;
	}

	/*******************************
	Retry count 1
	*******************************/
	if(cd1_initiate_retry_disconnect.read() || lk1_initiate_retry_disconnect.read()){
		error_retry_count1 = error_retry_count1.read() + 1;
	}
}

void csr_l2::manage_error_retry_registers_cold_reset(){
	error_retry_control0_cold0 = false;
	csr_retry0 = false;
	error_retry_status0 = 0;

	error_retry_control1_cold0 = false;
	csr_retry1 = false;
	error_retry_status1 = 0;
}

void csr_l2::manage_error_retry_registers_cold(){
	//*********************************
	// Retry control 0
	//*********************************

	//Link retry enable
	if(write.read() && write_addr.read() == ErrorRetry_Pointer/4+1 && 
				sc_bit(write_mask.read()[0])){
		error_retry_control0_cold0 = sc_bit(write_data.read()[0]);
	}

	//The actual retry mode as seen from the tunnel
	if(!resetx.read())
		csr_retry0 = sc_bit(config_registers[ErrorRetry_Pointer+4].read()[0]);

	//*********************************
	// Retry status 0
	//*********************************
	sc_bv<8> error_retry_status0_tmp = error_retry_status0;
	//Retry sent
	if(cd0_initiate_retry_disconnect.read() || lk0_initiate_retry_disconnect.read()){
		error_retry_status0_tmp[0] = true;
	}
	else if(write.read() && write_addr.read() == ErrorRetry_Pointer/4+1 && 
			sc_bit(write_mask.read()[1]) && sc_bit(write_data.read()[8])){
		error_retry_status0_tmp[0] = false;
	}

	//Retry rollover
	if((cd0_initiate_retry_disconnect.read() || lk0_initiate_retry_disconnect.read()) 
			&& error_retry_count0.read() == 0xFFFF){
		error_retry_status0_tmp[1] = true;
	}
	else if(write.read() && write_addr.read() == ErrorRetry_Pointer/4+1 && 
			sc_bit(write_mask.read()[1]) && sc_bit(write_data.read()[9])){
		error_retry_status0_tmp[1] = false;
	}

	//Stomp received
	if(cd0_received_stomped_csr.read()){
		error_retry_status0_tmp[2] = true;
	}
	else if(write.read() && write_addr.read() == ErrorRetry_Pointer/4+1 && 
			sc_bit(write_mask.read()[1]) && sc_bit(write_data.read()[10])){
		error_retry_status0_tmp[2] = false;
	}

	error_retry_status0_tmp.range(7,3) = 0;
	error_retry_status0 = error_retry_status0_tmp;

	//*********************************
	// Retry control 1
	//*********************************

	//Link retry enable
	if(write.read() && write_addr.read() == ErrorRetry_Pointer/4+1 && 
				sc_bit(write_mask.read()[2])){
		error_retry_control1_cold0 = sc_bit(write_data.read()[16]);
	}

	//The actual retry mode as seen from the tunnel
	if(!resetx.read())
		csr_retry1 = sc_bit(config_registers[ErrorRetry_Pointer+6].read()[0]);

	//*********************************
	// Retry status 1
	//*********************************

	sc_bv<8> error_retry_status1_tmp = error_retry_status1;
	//Retry sent
	if(cd1_initiate_retry_disconnect.read() || lk1_initiate_retry_disconnect.read()){
		error_retry_status1_tmp[0] = true;
	}
	else if(write.read() && write_addr.read() == ErrorRetry_Pointer/4+1 && 
			sc_bit(write_mask.read()[3]) && sc_bit(write_data.read()[24])){
		error_retry_status1_tmp[0] = false;
	}

	//Retry rollover
	if((cd1_initiate_retry_disconnect.read() || lk1_initiate_retry_disconnect.read()) 
			&& error_retry_count1.read() == 0xFFFF){
		error_retry_status1_tmp[1] = true;
	}
	else if(write.read() && write_addr.read() == ErrorRetry_Pointer/4+1 && 
			sc_bit(write_mask.read()[3]) && sc_bit(write_data.read()[25])){
		error_retry_status1_tmp[1] = false;
	}

	//Stomp received
	if(cd1_received_stomped_csr.read()){
		error_retry_status1_tmp[2] = true;
	}
	else if(write.read() && write_addr.read() == ErrorRetry_Pointer/4+1 && 
			sc_bit(write_mask.read()[3]) && sc_bit(write_data.read()[26])){
		error_retry_status1_tmp[2] = false;
	}

	error_retry_status1_tmp.range(7,3) = 0;
	error_retry_status1 = error_retry_status1_tmp;
}

#endif

void csr_l2::isSyncInitiated_reset(){
	sync_initiated = false;
}

void csr_l2::isSyncInitiated(){

	//Serr enable : if the link is allowed to start a sync flood
	bool serr_enable = sc_bit(config_registers[5].read()[0]);
	//If a sync flood should be started on a overflow error
	bool overflowErrorFloodEnable = sc_bit(config_registers[16].read()[1]);
	//If a sync flood should be started on a CRC error on side 0
	bool crcFloodEnable_0 = sc_bit(config_registers[Interface_Pointer + 4].read()[1]);
	//If a sync flood should be started on a CRC error on side 1
	bool crcFloodEnable_1 = sc_bit(config_registers[Interface_Pointer + 8].read()[1]);
	//If a sync flood should be started on a protocol error
	bool protocolErrorFloodEnable = sc_bit(config_registers[16].read()[0]);
#ifdef RETRY_MODE_ENABLED
	bool retry_mode_0 = sc_bit(config_registers[ErrorRetry_Pointer + 4].read()[0]);
	bool retry_mode_1 = sc_bit(config_registers[ErrorRetry_Pointer + 6].read()[1]);
#endif

	sync_initiated = false;
	//Check all the conditions that could initiate a protocol error
	if(	serr_enable && (
		((db0_overflow_csr.read() || ro0_overflow_csr.read() ||
		db1_overflow_csr.read() || ro1_overflow_csr.read()) && overflowErrorFloodEnable) ||
		( lk0_crc_error_csr.read() && crcFloodEnable_0) ||
		( lk1_crc_error_csr.read() && crcFloodEnable_1) ||
#ifdef RETRY_MODE_ENABLED
		( (cd0_protocol_error_csr.read() && !retry_mode_0 || 
		cd1_protocol_error_csr.read() && !retry_mode_1 ||
		lk0_protocol_error_csr.read() && !retry_mode_0 ||
		lk1_protocol_error_csr.read() && !retry_mode_1)
#else
		( (cd0_protocol_error_csr.read()  || 
		cd1_protocol_error_csr.read()  ||
		lk0_protocol_error_csr.read()  ||
		lk1_protocol_error_csr.read())
#endif

		&& protocolErrorFloodEnable ) 
		) )
	{
		sync_initiated = true;
	}
}

//***********************************************
//  Outputs from CSR registers to other modules
//***********************************************
void csr_l2::output_register_values(){
	/** Signal from register DeviceHeader->Command->csr_io_space_enable */
	csr_io_space_enable = sc_bit(config_registers[4].read()[0]);
	/** Signal from register DeviceHeader->Command->csr_memory_space_enable */
	csr_memory_space_enable = sc_bit(config_registers[4].read()[1]);
	/** Signal from register DeviceHeader->Command->csr_bus_master_enable */
	csr_bus_master_enable = sc_bit(config_registers[4].read()[2]);

	//Output BAR's (Base address registers)
	for(int n = 0; n < NbRegsBars ; n++){
		sc_bv<40> tmp_bar = 0;
		int lsb_pos = Header_BarLsbPos[n];
		tmp_bar.range(7,0) = config_registers[16 + 4*lsb_pos].read();
		tmp_bar.range(15,8) = config_registers[16 + 4*lsb_pos + 1].read();
		tmp_bar.range(23,16) = config_registers[16 + 4*lsb_pos + 2].read();
		tmp_bar.range(31,24) = config_registers[16 + 4*lsb_pos + 3].read();
	
		if(Header_Bar64b[n]){
			tmp_bar.range(39,32) = config_registers[16 + 4* Header_BarMsbPos[n]].read();
		}
		csr_bar[n] = tmp_bar;
	}

	/** Signal from register Interface->Command->csr_unit_id */
	csr_unit_id =  config_registers[Interface_Pointer + 2].read().range(4,0);
	/** Signal from register Interface->Command->csr_default_dir */
	csr_default_dir = sc_bit(config_registers[Interface_Pointer + 3].read()[3]);
	/** Signal from register Interface->Command->csr_drop_uninit_link */
	csr_drop_uninit_link = sc_bit(config_registers[Interface_Pointer + 3].read()[3]);
	/** Signal from register Interface->LinkControl_0->CRCFloodEnable_0 */
	//CRCFloodEnable_0 = config_registers[Interface_Pointer + 4].read()[1];
	/** Signal from register Interface->LinkControl_0->CRCStartTest_0 */
	//sc_out<bool> CRCStartTest_0;
	/** Signal from register Interface->LinkControl_0->csr_crc_force_error_lk0 */
	csr_crc_force_error_lk0 = sc_bit(config_registers[Interface_Pointer + 4].read()[3]);
	/** Signal from register Interface->LinkControl_0->LinkFailure_0 */
	//sc_out<bool> LinkFailure_0;
	/** Signal from register Interface->LinkControl_0->csr_end_of_chain0 */
	csr_end_of_chain0 = sc_bit(config_registers[Interface_Pointer + 4].read()[6]);
	/** Signal from register Interface->LinkControl_0->csr_transmitter_off_lk0 */
	csr_transmitter_off_lk0 = sc_bit(config_registers[Interface_Pointer + 4].read()[7]);
	/** Signal from register Interface->LinkControl_0->IsochronousFlowControlEnable_0 */
	//sc_out<bool> IsochronousFlowControlEnable_0;
	/** Signal from register Interface->LinkControl_0->csr_ldtstop_tristate_enable_lk0 */
	csr_ldtstop_tristate_enable_lk0 = sc_bit(config_registers[Interface_Pointer + 5].read()[5]);
	/** Signal from register Interface->LinkControl_0->csr_extented_ctl_lk0 */
	csr_extented_ctl_lk0 = sc_bit(config_registers[Interface_Pointer + 5].read()[6]);
	/** Signal from register Interface->LinkControl_0->64BitAddressingEnable_0 */
	//sc_out<bool> _64BitAddressingEnable_0;
	/** Signal from register Interface->LinkConfiguration_0->csr_rx_link_width_lk0 */
	csr_rx_link_width_lk0 = config_registers[Interface_Pointer + 7].read().range(2,0);
	/** Signal from register Interface->LinkConfiguration_0->DoublewordFlowControlInEnable_0 */
	//sc_out<bool> DoublewordFlowControlInEnable_0;
	/** Signal from register Interface->LinkConfiguration_0->csr_tx_link_width_lk0 */
	csr_tx_link_width_lk0 = config_registers[Interface_Pointer + 7].read().range(6,4);
	/** Signal from register Interface->LinkConfiguration_0->DoublewordFlowControlOutEnable_0 */
	//sc_out<bool> DoublewordFlowControlOutEnable_0;
	/** Signal from register Interface->LinkControl_1->CRCFloodEnable_1 */
	//sc_out<bool> CRCFloodEnable_1;
	/** Signal from register Interface->LinkControl_1->CRCStartTest_1 */
	//sc_out<bool> CRCStartTest_1;
	/** Signal from register Interface->LinkControl_1->csr_crc_force_error_lk1 */
	csr_crc_force_error_lk1 = sc_bit(config_registers[Interface_Pointer + 8].read()[3]);
	/** Signal from register Interface->LinkControl_1->LinkFailure_1 */
	//sc_out<bool> LinkFailure_1;
	/** Signal from register Interface->LinkControl_1->csr_end_of_chain1 */
	csr_end_of_chain1 = sc_bit(config_registers[Interface_Pointer + 8].read()[6]);
	/** Signal from register Interface->LinkControl_1->csr_transmitter_off_lk1 */
	csr_transmitter_off_lk1 = sc_bit(config_registers[Interface_Pointer + 8].read()[7]);
	/** Signal from register Interface->LinkControl_1->IsochronousFlowControlEnable_1 */
	//sc_out<bool> IsochronousFlowControlEnable_1;
	/** Signal from register Interface->LinkControl_1->csr_ldtstop_tristate_enable_lk1 */
	csr_ldtstop_tristate_enable_lk1 = sc_bit(config_registers[Interface_Pointer + 9].read()[5]);
	/** Signal from register Interface->LinkControl_1->csr_extented_ctl_lk1 */
	csr_extented_ctl_lk1 = sc_bit(config_registers[Interface_Pointer + 9].read()[6]);
	/** Signal from register Interface->LinkControl_1->64BitAddressingEnable_1 */
	//sc_out<bool> _64BitAddressingEnable_1;
	/** Signal from register Interface->LinkConfiguration_1->csr_rx_link_width_lk1 */
	csr_rx_link_width_lk1 = config_registers[Interface_Pointer + 11].read().range(2,0);
	/** Signal from register Interface->LinkConfiguration_1->DoublewordFlowControlInEnable_1 */
	//sc_out<bool> DoublewordFlowControlInEnable_1;
	/** Signal from register Interface->LinkConfiguration_1->csr_tx_link_width_lk1 */
	csr_tx_link_width_lk1 = config_registers[Interface_Pointer + 11].read().range(6,4);
	/** Signal from register Interface->LinkConfiguration_1->DoublewordFlowControlOutEnable_1 */
	//sc_out<bool> DoublewordFlowControlOutEnable_1;
	/** Signal from register Interface->LinkFrequency_0 */
	csr_link_frequency0 = config_registers[Interface_Pointer + 13].read().range(3,0);
	/** Signal from register Interface->LinkError_0->csr_extended_ctl_timeout_lk0 */
	csr_extended_ctl_timeout_lk0 = sc_bit(config_registers[Interface_Pointer + 13].read()[7]);
#ifdef ENABLE_REORDERING
	/** Signal from register Interface->FeatureCapability->csr_unitid_reorder_disable */
	csr_unitid_reorder_disable = sc_bit(config_registers[Interface_Pointer + 16].read()[5]);
#endif
	/** Signal from register Interface->LinkFrequency_1 */
	csr_link_frequency1  = config_registers[Interface_Pointer + 17].read().range(3,0);
	/** Signal from register Interface->LinkError_1->csr_extended_ctl_timeout_lk1 */
	csr_extended_ctl_timeout_lk1 = sc_bit(config_registers[Interface_Pointer + 13].read()[7]);
	/** Signal from register Interface->ErrorHandling->ProtocolErrorFloodEnable */
	//sc_out<bool> ProtocolErrorFloodEnable;
	/** Signal from register Interface->ErrorHandling->OverflowErrorFloodEnable */
	//sc_out<bool> OverflowErrorFloodEnable;

	//csr_retry0; Output is set in the manage_error_retry_registers

#ifdef RETRY_MODE_ENABLED
	/** Signal from register ErrorRetry->Control_0->csr_force_single_error_fc0 */
	csr_force_single_error_fc0 = sc_bit(config_registers[ErrorRetry_Pointer+4].read()[1]);
	/** Signal from register ErrorRetry->Control_0->csr_force_single_stomp_fc0 */
	csr_force_single_stomp_fc0 = sc_bit(config_registers[ErrorRetry_Pointer+4].read()[3]);
	/** Signal from register ErrorRetry->Control_0->AllowedAttempts_0 */
	//sc_out<bool> AllowedAttempts_0;
	/** Signal from register ErrorRetry->Status_0->CountRollover_0 */
	//sc_out<bool> CountRollover_0;
	
	//csr_retry1; Output is set in the manage_error_retry_registers

	/** Signal from register ErrorRetry->Control_1->csr_force_single_error_fc1 */
	csr_force_single_error_fc1 = sc_bit(config_registers[ErrorRetry_Pointer+6].read()[1]);
	/** Signal from register ErrorRetry->Control_1->csr_force_single_stomp_fc1 */
	csr_force_single_stomp_fc1 = sc_bit(config_registers[ErrorRetry_Pointer+6].read()[3]);
	/** Signal from register ErrorRetry->Control_1->AllowedAttempts_1 */
	//sc_out<bool> AllowedAttempts_1;
	/** Signal from register ErrorRetry->Status_1->CountRollover_1 */
	//sc_out<bool> CountRollover_1;
#endif

#ifdef ENABLE_DIRECTROUTE
	/** Signal from register DirectRoute->csr_direct_route_enable */
	sc_bv<32> directRouteEnable_tmp;
	directRouteEnable_tmp.range(7,0) = config_registers[DirectRoute_Pointer+4].read();
	directRouteEnable_tmp.range(15,8) = config_registers[DirectRoute_Pointer+5].read();
	directRouteEnable_tmp.range(23,16) = config_registers[DirectRoute_Pointer+6].read();
	directRouteEnable_tmp.range(31,24) = config_registers[DirectRoute_Pointer+7].read();
	csr_direct_route_enable = directRouteEnable_tmp;

	/** Signals table containing all csr_direct_route_oppposite_dir from Direct Route spaces implemented */
	for(int n = 0; n < DirectRoute_NumberDirectRouteSpaces; n++){
		csr_direct_route_base[n] = 
			(direct_route_data[4*n+1].read().range(7,0),direct_route_data[4*n+0].read().range(31,8));
		csr_direct_route_limit[n] =
			(direct_route_data[4*n+3].read().range(7,0),direct_route_data[4*n+2].read().range(31,8));
		csr_direct_route_oppposite_dir[n] = sc_bit(direct_route_data[4*n].read()[0]);
	}
#endif

	/** Signal from register DirectRoute->csr_clumping_configuration */
	sc_bv<32> clumpingEnable_tmp;
	clumpingEnable_tmp.range(7,0) = config_registers[UnitIDClumping_Pointer+8].read();
	clumpingEnable_tmp.range(15,8) = config_registers[UnitIDClumping_Pointer+9].read();
	clumpingEnable_tmp.range(23,16) = config_registers[UnitIDClumping_Pointer+10].read();
	clumpingEnable_tmp.range(31,24) = config_registers[UnitIDClumping_Pointer+11].read();
	csr_clumping_configuration = clumpingEnable_tmp;

	/** Signals table containing all Base Addresses from Direct Route spaces implemented */

	csr_sync = sc_bit(config_registers[Interface_Pointer + 23].read()[0]);

	csr_initcomplete0 = sc_bit(config_registers[Interface_Pointer + 4].read()[5]);
	csr_initcomplete1 = sc_bit(config_registers[Interface_Pointer + 8].read()[5]);

	csr_master_host = sc_bit(config_registers[Interface_Pointer + 3].read()[2]);

	//csr_is_upstream0 = !sc_bit(config_registers[Interface_Pointer + 3].read()[2]);
	//csr_is_upstream1 = sc_bit(config_registers[Interface_Pointer + 3].read()[2]);

}
void csr_l2::output_external_register_signals(){
	/*  When in a read state and the flow control acks the dword, the next dword must be
		sent to output, hence why we choose read_addr + 1
	*/
	if(state == CSR_READ && (fc0_ack_csr.read() || fc1_ack_csr.read())) csr_read_addr_usr = read_addr.read() + 1;
	else csr_read_addr_usr = read_addr.read();

	csr_write_usr = write.read();
	csr_write_addr_usr = write_addr.read();
	csr_write_data_usr = write_data.read();
	csr_write_mask_usr = write_mask.read();
}

#ifndef SYSTEMC_SIM

#include "../core_synth/synth_control_packet.cpp"

#endif


