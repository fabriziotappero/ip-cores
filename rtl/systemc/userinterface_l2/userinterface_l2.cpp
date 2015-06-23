//UserInterface.cpp

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

#include "userinterface_l2.h"

userinterface_l2::userinterface_l2(sc_module_name name) : sc_module(name) {
	
	//To handle what hapens on the clk
	SC_METHOD(clocked_process);
	sensitive_pos	<<	clk;
	sensitive_neg	<<	resetx;
	
	SC_METHOD(register_input);
	sensitive_pos	<<	clk;
	sensitive_neg	<<	resetx;

	SC_METHOD(rx_process);
	sensitive << rx_current_state << db0_data_ui << db1_data_ui <<
		usr_consume_ui << rx_rdcount_left << ui_vctype_db0_reg <<
		ui_vctype_db1_reg << ui_address_db0 << ui_address_db1 << 
		ro0_packet_ui << ro1_packet_ui << ro0_available_ui
		<< ro1_available_ui << ui_address_db0_reg << ui_address_db1_reg
		<< csr_request_databuffer0_access_ui << csr_request_databuffer1_access_ui
		<<  ui_available_usr << ui_packet_usr
#ifdef ENABLE_DIRECTROUTE
		<< ui_directroute_usr 
#endif
		 << ui_eop_usr << output_loaded;
	
	SC_METHOD(tx_wr_process);
	sensitive << tx_wrstate /*<< tx_valid_wr*/ << registered_usr_packet_ui << tx_side_wr
		<< registered_usr_available_ui;
	for(int vc = 0; vc < 3; vc++){
		sensitive << tx_wr0pointer[vc];
		sensitive << tx_wr1pointer[vc];
	}	
	
	SC_METHOD(tx_rd0_process);
	sensitive << fc0_data_vc_ui << 
		fc0_consume_data_ui;
	for(int vc = 0; vc < 3; vc++){
		sensitive << tx_rd0pointer[vc];
	}	
	
	SC_METHOD(tx_rd1_process);
	sensitive << fc1_data_vc_ui << 
		fc1_consume_data_ui;
	for(int vc = 0; vc < 3; vc++){
		sensitive << tx_rd1pointer[vc];
	}	
	
	/*SC_METHOD(tx_validate);
	sensitive << tx_wrstate << registered_usr_available_ui << 
		registered_usr_packet_ui << tx_side_wr << freevc0_buf_usr <<
		freevc1_buf_usr << csr_bus_master_enable;
	*/

	SC_METHOD(send_freevc_user);
	sensitive << fc0_user_fifo_ge2_ui << fc1_user_fifo_ge2_ui << csr_bus_master_enable;
	for(int vc = 0; vc < 3; vc++){
		sensitive << tx_count0[vc];
		sensitive << tx_count1[vc];
	}
	
	SC_METHOD(analyzePacketErrors);
	sensitive_pos(clk);
	sensitive_neg << resetx;
	
	SC_METHOD(output_read_data);
	sensitive << ui_memory_read_data0 << ui_memory_read_data1;
}



//see .h for details
void userinterface_l2::clocked_process() {
	if (resetx.read() == false ) {
		//The state machines
		rx_current_state = rx_idle_pref0_st;
		tx_wrstate = tx_wridle_st;

		///////////////////////////////////////
		// DATA FIFO REGISTERS
		///////////////////////////////////////
		//Register the position to write in the posted buffer
		for(int vc = 0; vc < 3; vc++){
			tx_wr0pointer[vc] = 0;
			tx_wr1pointer[vc] = 0;
			tx_count0[vc] = 0;
			tx_count1[vc] = 0;
			tx_rd0pointer[vc] = 0;
			tx_rd1pointer[vc] = 0;
		}	

		ui_vctype_db0_reg = VC_NONE;
		ui_vctype_db1_reg = VC_NONE;
		ui_address_db0_reg = sc_uint<BUFFERS_ADDRESS_WIDTH>(0);
		ui_address_db1_reg = sc_uint<BUFFERS_ADDRESS_WIDTH>(0);
		tx_previous_side_wr = csr_default_dir.read() ^ csr_master_host.read();

		ui_databuffer_access_granted_csr = false;
		ui_grant_csr_access_db0 = false;
		ui_grant_csr_access_db1 = false;

		tx_wrcount_left = 0;
		rx_rdcount_left = 0;
#ifdef REGISTER_USER_TX_FREEVC
	//If REGISTER_USER_TX_FREEVC is defined, register the free_vc variable
		ui_freevc0_usr = 0;
		ui_freevc1_usr = 0;
#endif

		ui_packet_usr = 0;
		ui_vc_usr = VC_NONE;
		ui_side_usr = false;
#ifdef ENABLE_DIRECTROUTE
		ui_directroute_usr = false;
#endif
		ui_eop_usr = false;
		ui_available_usr = false;
		ui_output_64bits_usr = false;

		output_loaded = true;
	} else {

		//Sate machines
		rx_current_state = rx_next_state;
		tx_wrstate = tx_next_wrstate;

		///////////////////////////////////////
		// DATA FIFO REGISTERS
		///////////////////////////////////////
		sc_uint<USER_MEMORY_ADDRESS_WIDTH_PER_VC> wr_pointer_to_increase;
		if(tx_increase_wrpointer_side.read()){
			wr_pointer_to_increase = tx_wr1pointer[tx_increase_wrpointer_vc.read()].read();
		}
		else{
			wr_pointer_to_increase = tx_wr0pointer[tx_increase_wrpointer_vc.read()].read();
		}
		if((wr_pointer_to_increase == USER_MEMORY_SIZE_PER_VC - 1) && tx_increase_wrpointer.read())
			wr_pointer_to_increase = 0;
		else
			wr_pointer_to_increase = wr_pointer_to_increase + sc_uint<1>(tx_increase_wrpointer.read());

		sc_uint<USER_MEMORY_ADDRESS_WIDTH_PER_VC> tx_count_to_increase;
		if(tx_increase_wrpointer_side.read()){
			tx_count_to_increase = tx_count1[tx_increase_wrpointer_vc.read()];
		}
		else{
			tx_count_to_increase = tx_count0[tx_increase_wrpointer_vc.read()];
		}
		if(tx_increase_wrpointer.read()){
			tx_count_to_increase = tx_count_to_increase + 1;
		}

		sc_uint<USER_MEMORY_ADDRESS_WIDTH_PER_VC> tx_count_to_decrease0 = 
			tx_count0[fc0_data_vc_ui.read()].read() - sc_uint<1>(fc0_consume_data_ui.read());
		sc_uint<USER_MEMORY_ADDRESS_WIDTH_PER_VC> tx_count_to_decrease1 = 
			tx_count1[fc1_data_vc_ui.read()].read() - sc_uint<1>(fc1_consume_data_ui.read());



		for(int vc = 0; vc < 3; vc++){
			//Register the position to write in the posted buffer
			//If requested to increase the pointer
			bool tx_increase_wr0pointer_current_vc = tx_increase_wrpointer_vc.read() == vc && 
				!tx_increase_wrpointer_side.read();
			bool tx_increase_wr1pointer_current_vc = tx_increase_wrpointer_vc.read() == vc && 
				tx_increase_wrpointer_side.read();

			if(tx_increase_wr0pointer_current_vc){
				tx_wr0pointer[vc] = wr_pointer_to_increase;
			}
			if(tx_increase_wr1pointer_current_vc){
				tx_wr1pointer[vc] = wr_pointer_to_increase;
			}

			//Register the number of space taken in the buffer
			tx_rd0pointer[vc] = next_tx_rd0pointer[vc].read();
			tx_rd1pointer[vc] = next_tx_rd1pointer[vc].read();

			//Register the position to read in the buffers
			bool tx_increase_rd0pointer = fc0_consume_data_ui.read() && fc0_data_vc_ui.read() == vc;
			bool tx_increase_rd1pointer = fc1_consume_data_ui.read() && fc1_data_vc_ui.read() == vc;

			//Maintain the count of the number of dwords stored in the buffers

			if(tx_increase_wr0pointer_current_vc && !tx_increase_rd0pointer)
				tx_count0[vc] = tx_count_to_increase;
			else if(!tx_increase_wr0pointer_current_vc && tx_increase_rd0pointer)
				tx_count0[vc] = tx_count_to_decrease0;

			if(tx_increase_wr1pointer_current_vc && !tx_increase_rd1pointer)
				tx_count1[vc] = tx_count_to_increase;
			else if(!tx_increase_wr1pointer_current_vc && tx_increase_rd1pointer)
				tx_count1[vc] = tx_count_to_decrease1;
		}

		///////////////////////////////////////
		// Register some values
		///////////////////////////////////////

		ui_vctype_db0_reg = ui_vctype_db0;
		ui_vctype_db1_reg = ui_vctype_db1;


		ui_address_db0_reg = ui_address_db0;
		ui_address_db1_reg = ui_address_db1;
		tx_previous_side_wr = tx_side_wr;

		ui_databuffer_access_granted_csr = next_ui_databuffer_access_granted_csr;
		ui_grant_csr_access_db0 = next_ui_grant_csr_access_db0;
		ui_grant_csr_access_db1 = next_ui_grant_csr_access_db1;

		tx_wrcount_left = next_tx_wrcount_left;
		rx_rdcount_left = next_rx_rdcount_left;
#ifdef REGISTER_USER_TX_FREEVC
	//If REGISTER_USER_TX_FREEVC is defined, register the free_vc variable
		ui_freevc0_usr = ui_freevc0_usr_buf;
		ui_freevc1_usr = ui_freevc1_usr_buf;
#endif

		ui_packet_usr = ui_packet_usr_buf;
		ui_vc_usr = ui_vc_usr_buf;
		ui_side_usr = ui_side_usr_buf;
#ifdef ENABLE_DIRECTROUTE
		ui_directroute_usr = ui_directroute_usr_buf;
#endif
		ui_eop_usr = ui_eop_usr_buf;
		ui_available_usr = ui_available_usr_buf;
		ui_output_64bits_usr = ui_output_64bits_usr_buf;

		output_loaded = next_output_loaded;
	}
}

//see .h for details
void userinterface_l2::rx_process() {

#ifdef ENABLE_DIRECTROUTE
	//By default, directroute stays the same
	ui_directroute_usr_buf = ui_directroute_usr;
#endif
	//A simple temp variable that can be used locally
	sc_bv<64> temp64;
	bool chainIdleState = false;
	ui_vc_usr_buf = ui_vc_usr;

	//Default output values
	next_ui_databuffer_access_granted_csr = false;
	next_ui_grant_csr_access_db0 = false;
	next_ui_grant_csr_access_db1 = false;

	next_rx_rdcount_left = rx_rdcount_left;
	ui_erase_db0 = false;
	ui_erase_db1 = false;

	ui_packet_usr_buf = ui_packet_usr;
	ui_available_usr_buf = ui_available_usr;
	ui_eop_usr_buf = ui_eop_usr;

	//The state machine
	switch (rx_current_state){

	//For receiving data from side 1
	case data0_st :
	case data0_chain_st :

			ui_side_usr_buf = false;						//side0
			next_output_loaded = true;
			temp64.range(63,32) = 0;     //Data only in the low 32 bits
			temp64.range(31,0) = db0_data_ui.read(); //Data to transmit

			//The data coming from the data buffer is always 32 bits
			ui_output_64bits_usr_buf = false;

			//We're not consuming any control packet, we're consuming data
			ui_ack_ro0 = false;  
			ui_ack_ro1 = false;
			
			//If the user consumes the data
			if(usr_consume_ui.read()){
				ui_packet_usr_buf = temp64;
				ui_available_usr_buf = false;				//not a control packet
				next_rx_rdcount_left = rx_rdcount_left.read() - 1;
				ui_eop_usr_buf = rx_rdcount_left.read() == 0;

				//Turn back and consume the data of the data buffer
				ui_read_db0 = true;

				//If it's the end of the data, go back to idle state
				if(rx_rdcount_left.read() == 0){
					ui_erase_db0 = true;
					//Manage the case if we are in chain mode
					if(rx_current_state == data0_st) rx_next_state = rx_idle_pref1_st;
					else rx_next_state = rx_idle_chain0_st;
				}
				//else, keep feeding data
				else
					rx_next_state = rx_current_state;
			}
			else{
				ui_read_db0 = false;
				rx_next_state = rx_current_state;
			}

			//We stay at the same adress for the vc
			ui_vctype_db0 = ui_vctype_db0_reg;
			ui_address_db0 = ui_address_db0_reg;

			//Stuff for side1, we're simply not reading
			ui_read_db1 = false;
			//Don't care for VC!
			ui_vctype_db1 = VC_NONE;
			//Don't care for address!
			ui_address_db1 = sc_uint<BUFFERS_ADDRESS_WIDTH>(0);
			
			//While using the databuffer from side 0, we can grant CSR access to the
			//databuffer from side 1
			next_ui_databuffer_access_granted_csr = csr_request_databuffer1_access_ui;
			next_ui_grant_csr_access_db1 = csr_request_databuffer1_access_ui;
			break;

		case data1_st :
		case data1_chain_st :

			ui_side_usr_buf = true;						//side1
			next_output_loaded = true;
			temp64.range(63,32) = 0;     //Data only in the low 32 bits
			temp64.range(31,0) = db1_data_ui.read(); //Data to transmit


			//The data coming from the data buffer is always 32 bits
			ui_output_64bits_usr_buf = false;

			//We're not consuming any control packet, we're consuming data
			ui_ack_ro0 = false;
			ui_ack_ro1 = false;
			
			//If the user consumes the data
			if(usr_consume_ui.read()){
				next_rx_rdcount_left = rx_rdcount_left.read() - 1;
				ui_eop_usr_buf = rx_rdcount_left.read() == 0;
				ui_packet_usr_buf = temp64;
				ui_available_usr_buf = false;				//not a control packet

				//Turn back and consume the data of the data buffer
				ui_read_db1 = true;

				//If it's the end of the data, go back to idle state
				if(rx_rdcount_left.read() == 0){
					ui_erase_db1 = true;
					//Manage the case if we are in chain mode
					if(rx_current_state == data1_st) rx_next_state = rx_idle_pref0_st;
					else rx_next_state = rx_idle_chain1_st;
				}
				//else, keep feeding data
				else
					rx_next_state = rx_current_state;
			}
			else{
				ui_eop_usr_buf = rx_rdcount_left.read() == 0;
				ui_read_db1 = false;
				rx_next_state = rx_current_state;
			}

			//We stay at the same adress for the vc
			ui_vctype_db1 = ui_vctype_db1_reg;
			ui_address_db1 = ui_address_db1_reg;

			//Stuff for side0, we're simply not reading
			ui_read_db0 = false;
			//Don't care for VC!
			ui_vctype_db0 = VC_NONE;
			//Don't care for address!
			ui_address_db0 = sc_uint<BUFFERS_ADDRESS_WIDTH>(0);

			//While using the databuffer from side 1, we can grant CSR access to the
			//databuffer from side 0
			next_ui_databuffer_access_granted_csr = csr_request_databuffer0_access_ui;
			next_ui_grant_csr_access_db0 = csr_request_databuffer0_access_ui;

			break;

		//Idle states
		case rx_idle_chain0_st:	//Waiting to receive a control packet, only from side 0 (because of a chain)
		case rx_idle_chain1_st:	//Waiting to receive a control packet, only from side 1 (because of a chain)
			chainIdleState = true;

		//case rx_idle_pref0_st:	//Waiting to receive a control packet, preference given to side 0
		//case rx_idle_pref1_st:	//Waiting to receive a control packet, preference given to side 1
		default:

			/**
				Because CSR access should usually be mostly during initialization, we give
				databuffer acess priority to the CSR, effectively stalling traffic to the
				user when CSR receives Data.  Actually, the CSR takes a pause between every
				packet, meaning that at worst, the CSR gets acces one turn to the databuffer,
				followed by acces for the UI.

				The findRxSide takes in consideration if databuffer acces is granted to the
				CSR.
			*/
			next_ui_databuffer_access_granted_csr = 
				csr_request_databuffer0_access_ui.read() || csr_request_databuffer1_access_ui.read();

			//It is assumed here that both request signals will NEVER be activated together
			next_ui_grant_csr_access_db0 = csr_request_databuffer0_access_ui;
			next_ui_grant_csr_access_db1 = csr_request_databuffer1_access_ui;

			/*Do some analysis on packets from side 0 and 1	*/

			sc_bv<64> ro0_packet_ui_bits = ro0_packet_ui.read().packet;
			PacketCommand ro0_packet_ui_cmd = getPacketCommand(ro0_packet_ui_bits.range(5,0));
			VirtualChannel ro0_packet_ui_vc = getVirtualChannel(ro0_packet_ui_bits,ro0_packet_ui_cmd);
			bool ro0_packet_ui_chain = isChain(ro0_packet_ui_bits);
			bool ro0_packet_ui_data_associated = hasDataAssociated(ro0_packet_ui_cmd);

			sc_bv<64> ro1_packet_ui_bits = ro1_packet_ui.read().packet;
			PacketCommand ro1_packet_ui_cmd = getPacketCommand(ro1_packet_ui_bits.range(5,0));
			VirtualChannel ro1_packet_ui_vc = getVirtualChannel(ro1_packet_ui_bits,ro1_packet_ui_cmd);
			bool ro1_packet_ui_chain = isChain(ro1_packet_ui_bits);
			bool ro1_packet_ui_data_associated = hasDataAssociated(ro1_packet_ui_cmd);

			//Find from which side we read a control packet
			sc_uint<2> readSide = findRxSide(ro0_packet_ui_data_associated,ro0_packet_ui_vc,
				ro1_packet_ui_data_associated,ro1_packet_ui_vc);

			//cout << "Find read side : " << readSide << endl;

			sc_bv<64>		output_bits;
			VirtualChannel	output_vc;

			//Read control packet from side 0
			if(readSide == 0 && (usr_consume_ui.read() || !output_loaded.read())){

				ui_side_usr_buf = false;							//side0
				ui_available_usr_buf = true;					//there is a control packet available
				next_output_loaded = true;
				output_bits = ro0_packet_ui_bits;	//send the actual packet
				next_rx_rdcount_left = (sc_bv<4>)ro0_packet_ui_bits.range(25,22);

				//If the user consumes the packet, we consume it from the buffer
				ui_ack_ro0 = true;

				//Not consuming the opposite side!
				ui_ack_ro1 = false;


				//Let the user know if what the packet being sent is 64 bits
				ui_output_64bits_usr_buf = isDwordPacket(ro0_packet_ui_bits,ro0_packet_ui_cmd);
				output_vc = ro0_packet_ui_vc;

				//If there is any data associated with the control packet
				if(ro0_packet_ui_data_associated){
					//Go to a data_state
					/** A chain of posted packets means that posted packets
					not from the chain may not be inserted in the chain.  We stay in
					the chain state if the received packet is part of a chain or if
					the packet is not posted but we are currently receiving a chain
					(a chain can be interrupted by other VC's than poster)*/
					if(ro0_packet_ui_chain || 
							(ro0_packet_ui_vc != VC_POSTED && 
							chainIdleState) ) 
						rx_next_state = data0_chain_st;
					else rx_next_state = data0_st;
					//Not the end of the transmission of the packet/data yet!
					ui_eop_usr_buf = false;


					//Pass packet information to the user
					ui_address_db0 = ro0_packet_ui.read().data_address;
					ui_vctype_db0 = ro0_packet_ui_vc;
				}
				else{
					//If a new packet can be stored in the output register
					/** A chain of posted packets means that posted packets
					not from the chain may not be inserted in the chain.  We stay in
					the chain state if the received packet is part of a chain or if
					the packet is not posted but we are currently receiving a chain
					(a chain can be interrupted by other VC's than poster)*/
					if(ro0_packet_ui_chain || 
						(ro0_packet_ui_vc != VC_POSTED && 
								chainIdleState))
						rx_next_state = rx_idle_chain0_st;
					else rx_next_state = rx_idle_pref1_st;
					ui_eop_usr_buf = true;

					//Don't care for VC!
					//Don't care for address!
					ui_address_db0 = sc_uint<BUFFERS_ADDRESS_WIDTH>(0);
					ui_vctype_db0 = VC_NONE;
				}
				ui_address_db1 = sc_uint<BUFFERS_ADDRESS_WIDTH>(0);
				ui_vctype_db1 = VC_NONE;

			}

			//Read control packet from side 1
			else if(readSide == 1  && (usr_consume_ui.read() || !output_loaded.read())){

				ui_side_usr_buf = true;							//side1
				next_output_loaded = true;
				ui_available_usr_buf = true;					//there is a control packet available
				output_bits = ro1_packet_ui_bits;	//send the actual packet
				next_rx_rdcount_left = (sc_bv<4>)ro1_packet_ui_bits.range(25,22);

				//If the user consumes the packet, we consume it from the buffer
				ui_ack_ro1 = true;

				//Not consuming the opposite side!
				ui_ack_ro0 = false;


				//Let the user know if what the packet being sent is 64 bits
				ui_output_64bits_usr_buf = isDwordPacket(ro1_packet_ui_bits,ro1_packet_ui_cmd);
				output_vc = ro1_packet_ui_vc;

				//If there is any data associated with the control packet
				if(ro1_packet_ui_data_associated){

					/** A chain of posted packets means that posted packets
					not from the chain may not be inserted in the chain.  We stay in
					the chain state if the received packet is part of a chain or if
					the packet is not posted but we are currently receiving a chain
					(a chain can be interrupted by other VC's than poster)*/
					if(ro1_packet_ui_chain || 
							(ro1_packet_ui_vc != VC_POSTED && 
							chainIdleState) ) 
						rx_next_state = data1_chain_st;
					else rx_next_state = data1_st;
					//Not the end of the transmission of the packet/data yet!
					ui_eop_usr_buf = false;


					//Pass packet information to the user
					ui_address_db1 = ro1_packet_ui.read().data_address;
					ui_vctype_db1 = ro1_packet_ui_vc;
				}
				//If there are no data
				else{
					/** A chain of posted packets means that posted packets
					not from the chain may not be inserted in the chain.  We stay in
					the chain state if the received packet is part of a chain or if
					the packet is not posted but we are currently receiving a chain
					(a chain can be interrupted by other VC's than poster)*/
					if(ro1_packet_ui_chain || 
							(ro1_packet_ui_vc && 
							chainIdleState))
						rx_next_state = rx_idle_chain1_st;
					else rx_next_state = rx_idle_pref0_st;

					ui_eop_usr_buf = true;

					//Don't care for VC!
					//Don't care for address!
					ui_address_db1 = sc_uint<BUFFERS_ADDRESS_WIDTH>(0);
					ui_vctype_db1 = VC_NONE;
				}

				ui_address_db0 = sc_uint<BUFFERS_ADDRESS_WIDTH>(0);
				ui_vctype_db0 = VC_NONE;

			}
			//If there are no packets available from either side
			else{
				ui_side_usr_buf = ui_side_usr;
				ui_available_usr_buf = false;
				next_output_loaded = output_loaded.read() && !usr_consume_ui.read();
				ui_eop_usr_buf = output_loaded.read() && !usr_consume_ui.read();

				//Bit vector stays the same (default action)
				rx_next_state = rx_current_state;
				ui_ack_ro0 = false;
				ui_ack_ro1 = false;
				ui_output_64bits_usr_buf = false;

				//Don't care for VC!
				//Don't care for address!
				ui_address_db0 = sc_uint<BUFFERS_ADDRESS_WIDTH>(0);
				ui_address_db1 = sc_uint<BUFFERS_ADDRESS_WIDTH>(0);
				ui_vctype_db0 = VC_NONE;
				ui_vctype_db1 = VC_NONE;
			}

			ui_packet_usr_buf = output_bits;	//send the actual packet
			ui_vc_usr_buf = output_vc;


			
#ifdef ENABLE_DIRECTROUTE
			/**Do the processing as if it's a request.  We'll ignore the result
			  if it's a response or a not a valid packet*/

			/*
			Mux takes a while to calculate and pkt_unidID comes in late, so this
			code is replaced by something bigger but faster
			sc_bv<5> pkt_unidID = output_bits.range(12,8);
			bool from_direct_route_enabled = (sc_bit)csr_direct_route_enable.read()[
				(sc_uint<5>) pkt_unidID];*/
			sc_bv<5> pkt_unidID0 = ro0_packet_ui_bits.range(12,8);
			sc_bv<5> pkt_unidID1 = ro1_packet_ui_bits.range(12,8);
			bool from_direct_route_enabled0 = (sc_bit)csr_direct_route_enable.read()[
				(sc_uint<5>) pkt_unidID0];
			bool from_direct_route_enabled1 = (sc_bit)csr_direct_route_enable.read()[
				(sc_uint<5>) pkt_unidID1];
			bool from_direct_route_enabled = 
				from_direct_route_enabled0 && readSide == 0 ||
				from_direct_route_enabled1 && readSide == 1;

			sc_bv<6> direct_route_interdict_top_addr = "111111";
			//FD_0000_0000_0000h - FF_FFFF_FFFFh
			bool interdict_zone = output_bits.range(63,58) == direct_route_interdict_top_addr &&
				((sc_bit)output_bits[57] || (sc_bit)output_bits[56]);

			ui_directroute_usr_buf = from_direct_route_enabled && !interdict_zone
				&& (output_vc == VC_POSTED || output_vc == VC_NON_POSTED);
#endif

			//We're reading a control packet, not consuming data.
			ui_read_db0 = false;
			ui_read_db1 = false;
	}
}

//see .h for details
void userinterface_l2::tx_wr_process() {

	//cout << "Write process being called!" << endl;

	//By default, we don't increase any pointer
	tx_increase_wrpointer_side = false;
	tx_increase_wrpointer_vc = 0;
	tx_increase_wrpointer = false;

	//By default, we don't send anything (A nop packet is only 0's)
	//Available signals are false;
	sc_bv<64> nopPacket = 0;
	ui_available_fc0 = false;
	ui_available_fc1 = false;

	tx_next_wrstate = tx_wridle_st;
	ui_memory_write0 = false;
	ui_memory_write1 = false;
	ui_memory_write_address = 0;

	ui_packet_fc0 = registered_usr_packet_ui.read();
	ui_packet_fc1 = registered_usr_packet_ui.read();

	next_tx_wrcount_left = tx_wrcount_left;

	//This is a state machine
	if(tx_wrstate == tx_wridle_st){
		//In the idle state, we wait for the user to write
		
		//If there is a valid packet being written by the user...
		//tx_valid_wr is calculated by a parallel process
		//if(tx_valid_wr){
		if(registered_usr_available_ui.read()){
			//Create a packet object from what is being send by the user
			sc_bv<64> pkt = registered_usr_packet_ui.read();
			PacketCommand cmd = getPacketCommand(pkt.range(5,0));
			VirtualChannel pkt_vc = getVirtualChannel(pkt,cmd);
			sc_uint<4> pkt_datalen_m1 = getDataLengthm1(pkt);

			//Send the packet to the good side
			ui_available_fc0 = !tx_side_wr.read();
			ui_available_fc1 = tx_side_wr;

			//If there is data following the packet, we want to 
			//go in a data state
			if(hasDataAssociated(cmd)){
				//-Go to a different state for every VC
				//-Store the length of the data
				//-Set that there is data in the buffer
				next_tx_wrcount_left = pkt_datalen_m1;
				if(pkt_vc == VC_RESPONSE){
					if(tx_side_wr){
						tx_next_wrstate = tx_wrresponse1_st;
					}
					else{
						tx_next_wrstate = tx_wrresponse0_st;
					}
				}
				else if(pkt_vc == VC_POSTED){
					if(tx_side_wr){
						tx_next_wrstate = tx_wrposted1_st;
					}
					else{
						tx_next_wrstate = tx_wrposted0_st;
					}
				}
				else{ // if(pkt_vc == VC_NON_POSTED){
					if(tx_side_wr){
						tx_next_wrstate = tx_wrnposted1_st;
					}
					else{
						tx_next_wrstate = tx_wrnposted0_st;
					}
				}
			}

		}

	}

	/**
		All the write states fall in the following case categories.
		The common stuff gets done in the default section
	*/
	else{
		//This case starts by selecting the base address where the data
		//will be written.  Il also fetches the size of the data stored
		//previously in the idle state.
		sc_uint<USER_MEMORY_ADDRESS_WIDTH> base_vc_address;
		sc_uint<USER_MEMORY_ADDRESS_WIDTH_PER_VC> pointer_value;

		tx_increase_wrpointer = true;;

		switch(tx_wrstate){
		case tx_wrposted0_st :
			base_vc_address = VC_POSTED * USER_MEMORY_SIZE_PER_VC;
			pointer_value = tx_wr0pointer[VC_POSTED].read();
			ui_memory_write0 = true;

			tx_increase_wrpointer_side = false;
			tx_increase_wrpointer_vc = VC_POSTED;
			break;
		case tx_wrnposted0_st :
			base_vc_address = VC_NON_POSTED * USER_MEMORY_SIZE_PER_VC;
			pointer_value = tx_wr0pointer[VC_NON_POSTED].read();
			ui_memory_write0 = true;

			tx_increase_wrpointer_side = false;
			tx_increase_wrpointer_vc = VC_NON_POSTED;
			break;
		case tx_wrresponse0_st :
			base_vc_address = VC_RESPONSE * USER_MEMORY_SIZE_PER_VC;
			pointer_value = tx_wr0pointer[VC_RESPONSE].read();
			ui_memory_write0 = true;

			tx_increase_wrpointer_side = false;
			tx_increase_wrpointer_vc = VC_RESPONSE;
			break;
		case tx_wrposted1_st :
			base_vc_address = VC_POSTED * USER_MEMORY_SIZE_PER_VC;
			pointer_value = tx_wr1pointer[VC_POSTED].read();
			ui_memory_write1 = true;

			tx_increase_wrpointer_side = true;
			tx_increase_wrpointer_vc = VC_POSTED;
			break;
		case tx_wrnposted1_st :
			base_vc_address = VC_NON_POSTED * USER_MEMORY_SIZE_PER_VC;
			pointer_value = tx_wr1pointer[VC_NON_POSTED].read();
			ui_memory_write1 = true;

			tx_increase_wrpointer_side = true;
			tx_increase_wrpointer_vc = VC_NON_POSTED;
			break;
		//case tx_wrresponse1_st :
		default:
			base_vc_address = VC_RESPONSE * USER_MEMORY_SIZE_PER_VC;
			pointer_value = tx_wr1pointer[VC_RESPONSE].read();
			ui_memory_write1 = true;

			tx_increase_wrpointer_side = true;
			tx_increase_wrpointer_vc = VC_RESPONSE;
		}
		ui_memory_write_address = base_vc_address + pointer_value;
		
		//Increase the write count
		next_tx_wrcount_left = tx_wrcount_left.read() - 1;

		//If we haven't reached the end of the buffer size, we
		//stay in the same state
		if(tx_wrcount_left.read() != 0)
			tx_next_wrstate = tx_wrstate;
	}

	ui_memory_write_data = registered_usr_packet_ui.read().range(31,0);
}


//see .h for details
void userinterface_l2::tx_rd0_process() {

	//Use a local variable so that the calculated next read pointer can
	//be used lower to calculate the next read address
	sc_uint<USER_MEMORY_ADDRESS_WIDTH_PER_VC> next_tx_rd0pointer_buf[3];

	//Update the read pointer
	sc_uint<USER_MEMORY_ADDRESS_WIDTH_PER_VC> rd0_pointer_from_selected_vc;
	switch(fc0_data_vc_ui.read()){
		case VC_POSTED:
			rd0_pointer_from_selected_vc = tx_rd0pointer[0].read();
			break;
		case VC_NON_POSTED:
			rd0_pointer_from_selected_vc = tx_rd0pointer[1].read();
			break;
		default:
			rd0_pointer_from_selected_vc = tx_rd0pointer[2].read();
	}

	if(fc0_consume_data_ui.read()){
		if(rd0_pointer_from_selected_vc == USER_MEMORY_SIZE_PER_VC - 1)
			rd0_pointer_from_selected_vc = 0;
		//otherwise simply increment
		else
			rd0_pointer_from_selected_vc = rd0_pointer_from_selected_vc + 1;
	}

	for(int vc = 0; vc < 3; vc++){
		//If data from the VC is consumed, increase the pointer
		if(fc0_data_vc_ui.read() == vc ){
			next_tx_rd0pointer_buf[vc] = rd0_pointer_from_selected_vc;
		}
		//stay the same
		else{
			next_tx_rd0pointer_buf[vc] = tx_rd0pointer[vc].read();
		}
		next_tx_rd0pointer[vc] = next_tx_rd0pointer_buf[vc];
	}

	//Find the correct address using the requested VC and the read pointer
	sc_uint<USER_MEMORY_ADDRESS_WIDTH> ui_memory_base_address;
	switch (fc0_data_vc_ui.read()){
	case VC_POSTED :
		ui_memory_base_address = DATA_POSTED_BUFFER_START;
		break;
	case VC_NON_POSTED:
		ui_memory_base_address = DATA_NPOSTED_BUFFER_START;
		break;
	//case VC_RESPONSE:
	default:
		ui_memory_base_address = DATA_RESPONSE_BUFFER_START;
		break;
	}
	ui_memory_read_address0 = ui_memory_base_address + rd0_pointer_from_selected_vc;
}

//see .h for details
void userinterface_l2::output_read_data(){
	ui_data_fc0 = ui_memory_read_data0.read();
	ui_data_fc1 = ui_memory_read_data1.read();
}

//see .h for details
void userinterface_l2::tx_rd1_process() {

	//Use a local variable so that the calculated next read pointer can
	//be used lower to calculate the next read address
	sc_uint<USER_MEMORY_ADDRESS_WIDTH_PER_VC> next_tx_rd1pointer_buf[3];

	//Update the read pointer
	sc_uint<USER_MEMORY_ADDRESS_WIDTH_PER_VC> rd1_pointer_from_selected_vc;
	switch(fc0_data_vc_ui.read()){
		case VC_POSTED:
			rd1_pointer_from_selected_vc = tx_rd1pointer[0].read();
			break;
		case VC_NON_POSTED:
			rd1_pointer_from_selected_vc = tx_rd1pointer[1].read();
			break;
		default:
			rd1_pointer_from_selected_vc = tx_rd1pointer[2].read();
	}

	if(fc1_consume_data_ui.read()){
		if(rd1_pointer_from_selected_vc == USER_MEMORY_SIZE_PER_VC - 1)
			rd1_pointer_from_selected_vc = 0;
		//otherwise simply increment
		else
			rd1_pointer_from_selected_vc = rd1_pointer_from_selected_vc + 1;
	}

	for(int vc = 0; vc < 3; vc++){
		//If data from the VC is consumed, increase the pointer
		if(fc1_data_vc_ui.read() == vc ){
			next_tx_rd1pointer_buf[vc] = rd1_pointer_from_selected_vc;
		}
		else{
			next_tx_rd1pointer_buf[vc] = tx_rd1pointer[vc].read();
		}
		next_tx_rd1pointer[vc] = next_tx_rd1pointer_buf[vc];
	}

	//Find the correct address using the requested VC and the read pointer
	sc_uint<USER_MEMORY_ADDRESS_WIDTH> ui_memory_base_address;
	switch (fc1_data_vc_ui.read()){
	case VC_POSTED :
		ui_memory_base_address = DATA_POSTED_BUFFER_START;
		break;
	case VC_NON_POSTED:
		ui_memory_base_address = DATA_NPOSTED_BUFFER_START;
		break;
	//case VC_RESPONSE:
	default:
		ui_memory_base_address = DATA_RESPONSE_BUFFER_START;
		break;
	}
	ui_memory_read_address1 = ui_memory_base_address + rd1_pointer_from_selected_vc;
}


//see .h for details
void userinterface_l2::send_freevc_user(){

	//By default, it's the same as what is being sent
	//by the forward modules.
	sc_bv<6> freevc0_buf_usr_tmp;
	sc_bv<6> freevc1_buf_usr_tmp;

	//Start by checking the status of the user fifo in the flow_control module.  This is
	//where the command packets are stored
	freevc0_buf_usr_tmp[FREE_VC_POSTED_POS] =  !(sc_bit)(fc0_user_fifo_ge2_ui.read())[VC_POSTED];
	freevc0_buf_usr_tmp[FREE_VC_POSTED_DATA_POS] =  !(sc_bit)(fc0_user_fifo_ge2_ui.read())[VC_POSTED];
	freevc0_buf_usr_tmp[FREE_VC_NPOSTED_POS] =  !(sc_bit)(fc0_user_fifo_ge2_ui.read())[VC_NON_POSTED];
	freevc0_buf_usr_tmp[FREE_VC_NPOSTED_DATA_POS] =  !(sc_bit)(fc0_user_fifo_ge2_ui.read())[VC_NON_POSTED];
	freevc0_buf_usr_tmp[FREE_VC_RESPONSE_POS] =  !(sc_bit)(fc0_user_fifo_ge2_ui.read())[VC_RESPONSE];
	freevc0_buf_usr_tmp[FREE_VC_RESPONSE_DATA_POS] =  !(sc_bit)(fc0_user_fifo_ge2_ui.read())[VC_RESPONSE];

	freevc1_buf_usr_tmp[FREE_VC_POSTED_POS] =  !(sc_bit)(fc1_user_fifo_ge2_ui.read())[VC_POSTED];
	freevc1_buf_usr_tmp[FREE_VC_POSTED_DATA_POS] =  !(sc_bit)(fc1_user_fifo_ge2_ui.read())[VC_POSTED];
	freevc1_buf_usr_tmp[FREE_VC_NPOSTED_POS] =  !(sc_bit)(fc1_user_fifo_ge2_ui.read())[VC_NON_POSTED];
	freevc1_buf_usr_tmp[FREE_VC_NPOSTED_DATA_POS] =  !(sc_bit)(fc1_user_fifo_ge2_ui.read())[VC_NON_POSTED];
	freevc1_buf_usr_tmp[FREE_VC_RESPONSE_POS] =  !(sc_bit)(fc1_user_fifo_ge2_ui.read())[VC_RESPONSE];
	freevc1_buf_usr_tmp[FREE_VC_RESPONSE_DATA_POS] =  !(sc_bit)(fc1_user_fifo_ge2_ui.read())[VC_RESPONSE];

	//The take into account if there is enough room in the ui memory for another data packet
	if(tx_count0[VC_POSTED].read() >= USER_MEMORY_WARN_FULL_SIZE) 
		freevc0_buf_usr_tmp[FREE_VC_POSTED_DATA_POS] = false;
	if(tx_count0[VC_NON_POSTED].read() >= USER_MEMORY_WARN_FULL_SIZE) 
		freevc0_buf_usr_tmp[FREE_VC_NPOSTED_DATA_POS] = false;
	if(tx_count0[VC_RESPONSE].read() >= USER_MEMORY_WARN_FULL_SIZE) 
		freevc0_buf_usr_tmp[FREE_VC_RESPONSE_DATA_POS] = false;
	
	if(tx_count1[VC_POSTED].read() >= USER_MEMORY_WARN_FULL_SIZE) 
		freevc1_buf_usr_tmp[FREE_VC_POSTED_DATA_POS] = false;
	if(tx_count1[VC_NON_POSTED].read() >= USER_MEMORY_WARN_FULL_SIZE) 
		freevc1_buf_usr_tmp[FREE_VC_NPOSTED_DATA_POS] = false;
	if(tx_count1[VC_RESPONSE].read() >= USER_MEMORY_WARN_FULL_SIZE) 
		freevc1_buf_usr_tmp[FREE_VC_RESPONSE_DATA_POS] = false;

	//Don't allow anything to be sent if csr_bus_master_enable is false
	if(!csr_bus_master_enable.read()){
		freevc0_buf_usr_tmp = 0;
		freevc1_buf_usr_tmp = 0;
	}

	//Write to the output signal
#ifdef REGISTER_USER_TX_FREEVC
	//If REGISTER_USER_TX_FREEVC is defined, register the free_vc variable
	ui_freevc0_usr_buf = freevc0_buf_usr_tmp;
	ui_freevc1_usr_buf = freevc1_buf_usr_tmp;
#else
	ui_freevc0_usr = freevc0_buf_usr_tmp;
	ui_freevc1_usr = freevc1_buf_usr_tmp;
#endif
}


//see .h for details
sc_uint<2> userinterface_l2::findRxSide(
			bool ro0_packet_ui_data_associated,VirtualChannel ro0_packet_ui_vc,
			bool ro1_packet_ui_data_associated,VirtualChannel ro1_packet_ui_vc)
{
	//A return value of 2 represents no side

	sc_uint<2> return_val;
	switch(rx_current_state.read()){
		case rx_idle_chain0_st:
			///Send side 0 by default until the chain is over
			if(ro0_available_ui.read() && 
				!(csr_request_databuffer0_access_ui.read() && ro0_packet_ui_data_associated)) return_val = 0;
			///Send from side 1 if a not posted packet is available
			else if(ro1_available_ui.read() && ro1_packet_ui_vc != VC_POSTED &&
				!(csr_request_databuffer1_access_ui.read() && ro1_packet_ui_data_associated)) return_val = 1;
			else
				return_val = 2;
			break;
		case rx_idle_chain1_st:
			///Send side 1 by default until the chain is over
			if(ro1_available_ui.read() && 
				!(csr_request_databuffer1_access_ui.read() && ro1_packet_ui_data_associated)) return_val = 1;
			///Send from side 0 if a not posted packet is available
			else if(ro0_available_ui.read() && ro0_packet_ui_vc != VC_POSTED &&
				!(csr_request_databuffer1_access_ui.read() && ro1_packet_ui_data_associated)) return_val = 0;
			return_val = 2;
			break;
		case rx_idle_pref0_st:
			///Send side 0 by default if we have access to databuffer
			if(ro0_available_ui.read() && 
				!(csr_request_databuffer0_access_ui.read() && ro0_packet_ui_data_associated)) return_val = 0;
			///Then from side 1 if we have access to databuffer
			else if(ro1_available_ui.read() && 
				!(csr_request_databuffer1_access_ui.read() && ro1_packet_ui_data_associated)) return_val = 1;
			else return_val = 2;
			break;
		case rx_idle_pref1_st:
			///Send side 1 by default if we have access to databuffer
			if(ro1_available_ui.read() && 
				!(csr_request_databuffer1_access_ui.read() && ro1_packet_ui_data_associated)) return_val = 1;
			///Then from side 0 if we have access to databuffer
			else if(ro0_available_ui.read() && 
				!(csr_request_databuffer0_access_ui.read() && ro0_packet_ui_data_associated)) return_val = 0;
			else return_val = 2;
			break;
		default:
			return_val = 2;
	}
	return return_val;
}


//see .h for details
void userinterface_l2::analyzePacketErrors(){
	//It is syncronous with asyncronous reset
	if(!resetx.read()){
		//At reset, all output report no errors
		ui_sendingPostedDataError_csr = false;
		ui_sendingTargetAbort_csr = false;

		ui_receivedResponseDataError_csr = false;
		ui_receivedPostedDataError_csr = false;
		ui_receivedTargetAbort_csr = false;
		ui_receivedMasterAbort_csr = false;
	}
	else{

		//Analyze errors in packets being sent by the user
		sc_bv<64> packet_tx = registered_usr_packet_ui.read();
		PacketCommand cmd_tx = getPacketCommand(packet_tx.range(5,0));
		VirtualChannel vc_tx = getVirtualChannel(packet_tx,cmd_tx);

		ui_sendingPostedDataError_csr = 
			registered_usr_available_ui.read() && tx_wrstate == tx_wridle_st &&
			cmd_tx == WRITE && vc_tx == VC_POSTED && write_getDataError(packet_tx);
		ui_sendingTargetAbort_csr = 
			registered_usr_available_ui.read() && tx_wrstate == tx_wridle_st &&
			vc_tx == VC_RESPONSE && (response_getResponseError(packet_tx) == RE_TARGET_ABORT);

		//Analyze errors in packets being reveived from the chain
		sc_bv<64> packet0 = ro0_packet_ui.read().packet;
		PacketCommand cmd0 = getPacketCommand(packet0.range(5,0));
		VirtualChannel vc0 = getVirtualChannel(packet0,cmd0);
		sc_bv<64> packet1 = ro1_packet_ui.read().packet;
		PacketCommand cmd1 = getPacketCommand(packet1.range(5,0));
		VirtualChannel vc1 = getVirtualChannel(packet1,cmd1);

		bool data_error0 = write_getDataError(packet0) || 
			ro0_available_ui.read() && cmd0 == WRITE && vc0 == VC_POSTED;
		bool data_error1 = write_getDataError(packet1) ||
			ro1_available_ui.read() && cmd1 == WRITE && vc1 == VC_POSTED;

		ui_receivedPostedDataError_csr = data_error0 || data_error1;

		//Look if the packet sent has TARGET_ABORT, DATA_ERROR or MASTER_ABORT bit set
		ResponseError error0 = response_getResponseError(packet0);
		ResponseError error1 = response_getResponseError(packet1);

		ui_receivedTargetAbort_csr = 
			error0 == RE_TARGET_ABORT && ro0_available_ui.read() && vc0 == VC_RESPONSE ||
			error1 == RE_TARGET_ABORT && ro1_available_ui.read() && vc1 == VC_RESPONSE;
		ui_receivedResponseDataError_csr = 
			error0 == RE_DATA_ERROR && ro0_available_ui.read() && vc0 == VC_RESPONSE ||
			error1 == RE_DATA_ERROR && ro1_available_ui.read() && vc1 == VC_RESPONSE;
		ui_receivedMasterAbort_csr = 
			error0 == RE_MASTER_ABORT && ro0_available_ui.read() && vc0 == VC_RESPONSE ||
			error1 == RE_MASTER_ABORT && ro1_available_ui.read() && vc1 == VC_RESPONSE;
	}
}

void userinterface_l2::register_input(){
	if(!resetx.read()){
		registered_usr_packet_ui = 0;
		tx_side_wr = false;
		registered_usr_available_ui = false;
#ifdef REGISTER_USER_TX_PACKET
		registeredx_usr_packet_ui = 0;
		registeredx_usr_side_ui = false;
		registeredx_usr_available_ui = false;
#endif

	}
	else{
		sc_bv<64> pkt;
		bool input_available;
		bool input_side;
#ifdef REGISTER_USER_TX_PACKET
		registeredx_usr_packet_ui = usr_packet_ui;
		registeredx_usr_side_ui = usr_side_ui;
		registeredx_usr_available_ui = usr_available_ui;

		registered_usr_packet_ui = registeredx_usr_packet_ui;
		registered_usr_available_ui = registeredx_usr_available_ui;

		pkt = registeredx_usr_packet_ui;
		input_available = registeredx_usr_available_ui;
		input_side = registeredx_usr_side_ui;
#else
		registered_usr_packet_ui = usr_packet_ui;
		registered_usr_available_ui = usr_available_ui;

		pkt = usr_packet_ui;
		input_available = usr_available_ui;
		input_side = usr_side_ui;
#endif

		bool defaultDir = csr_default_dir.read() ^ csr_master_host.read();

		//Create a packet object to analyze the data
		PacketCommand  pkt_cmd  = getPacketCommand(pkt.range(5,0));
		PacketType pkt_type = getPacketType(pkt.range(5,0));
		bool dword_packet = isDwordPacket(pkt,pkt_cmd);

#ifdef ENABLE_DIRECTROUTE
		/**Check for conditions where we ignore direct route
			there is the address range and if FENCE or FLUSH packet
		*/
		bool directRouteDisabled = 
			dword_packet && pkt.range(63,58) == "111111" && ((sc_bit)pkt[57] || (sc_bit)pkt[56])
			|| pkt_cmd == FENCE || pkt_cmd == FLUSH;
#endif

		//Variable to know if the address of the packet was found to be
		//In a directConnect range
		bool foundAddress = false;
		
#ifdef ENABLE_DIRECTROUTE
		//Check all DIRECTROUTE_SPACES
		bool opposite_dir = false;
		for(int i = 0 ; i < DirectRoute_NumberDirectRouteSpaces; i++){
			bool is_in_range = isInAddressRange(pkt,pkt_cmd,
				sc_uint<32>(csr_direct_route_base[i].read()),
				sc_uint<32>(csr_direct_route_limit[i].read()));

			opposite_dir = opposite_dir || 
				(csr_direct_route_oppposite_dir[i].read() && is_in_range);
			foundAddress = foundAddress || is_in_range;
		}
#endif

#ifdef ENABLE_DIRECTROUTE
		//If the packet was found in directroute space and supposed to go the opposite side, invers
		//the side we send it to
		bool tmp_side_wr =  opposite_dir ^ defaultDir;
#endif

		if(csr_end_of_chain0.read() || csr_end_of_chain1.read()){
			tx_side_wr = csr_end_of_chain0.read();			
		}
		else if(pkt_type == RESPONSE){
			//Response always go the side the request came from
			//For now, it's the responsibility of the user to
			//remember from which side the request came from
			tx_side_wr = input_side;
		}
#ifdef ENABLE_DIRECTROUTE
		else if(directRouteDisabled){
			//Fence and Flush always go defaultDirection
			tx_side_wr = defaultDir;			
		}
		else if(pkt_type == REQUEST && foundAddress){
			tx_side_wr = tmp_side_wr;
		}
		//If we get here, it means this is an INFO or undefined
		//packet.  Behaviour is undefined
#endif
		else{
			tx_side_wr = defaultDir;
		}
	}
}
#ifdef SYSTEMC_SIM

//	rx_idle_pref0_st,	/**<Waiting to receive a control packet, preference given to side 0 */
//	rx_idle_pref1_st,	/**<Waiting to receive a control packet, preference given to side 1 */
//	rx_idle_chain0_st,	/**<Waiting to receive a control packet, only from side 0 (because of a chain) */
//	rx_idle_chain1_st,	/**<Waiting to receive a control packet, only from side 1 (because of a chain) */
//	data0_st,			/**<Fetching data from side 0, will go to rx_idle_pref1_st once done */
//	data1_st,			/**<Fetching data from side 1, will go to rx_idle_pref0_st once done */
//	data0_chain_st,		/**<Fetching data from side 0, will go to rx_idle_chain0_st once done */
//	data1_chain_st		/**<Fetching data from side 0, will go to rx_idle_chain1_st once done */
ostream& operator<<(ostream& out, const InterfaceRxState & o){
	switch(o){
	case rx_idle_pref0_st :
		out << "rx_idle_pref0_st";
		break;
	case rx_idle_pref1_st :
		out << "rx_idle_pref1_st";
		break;
	case rx_idle_chain0_st :
		out << "rx_idle_chain0_st";
		break;
	case rx_idle_chain1_st :
		out << "rx_idle_chain1_st";
		break;
	case data0_st :
		out << "data0_st";
		break;
	case data1_st :
		out << "data1_st";
		break;
	case data0_chain_st :
		out << "data0_chain_st";
		break;
	case data1_chain_st :
		out << "data1_chain_st";
	}
	return out;
}


ostream& operator<<(ostream& out, const InterfaceTxWriteState & o){
	switch(o){
	case tx_wridle_st :
		out << "tx_wridle_st";
		break;
	case tx_wrposted0_st :
		out << "tx_wrposted0_st";
		break;
	case tx_wrnposted0_st :
		out << "tx_wrnposted0_st";
		break;
	case tx_wrresponse0_st :
		out << "tx_wrresponse0_st";
		break;
	case tx_wrposted1_st :
		out << "tx_wrposted1_st";
		break;
	case tx_wrnposted1_st :
		out << "tx_wrnposted1_st";
		break;
	case tx_wrresponse1_st :
		out << "tx_wrresponse1_st";
	}
	return out;
}


ostream& operator<<(ostream& out, const InterfaceTxReadState & o){
	switch(o){
	case tx_rdidle_st :
		out << "tx_rdidle_st";
		break;
	case tx_rdposted_st :
		out << "tx_rdposted_st";
		break;
	case tx_rdnposted_st :
		out << "tx_rdnposted_st";
		break;
	case tx_rdresponse_st :
		out << "tx_rdresponse_st";
	}
	return out;
}

#endif


//If we are doing synthesis with SystemC Compiler, controlpacket
// functions must be inluded in the same file
#ifndef SYSTEMC_SIM
#include "../core_synth/synth_control_packet.cpp"
#endif


