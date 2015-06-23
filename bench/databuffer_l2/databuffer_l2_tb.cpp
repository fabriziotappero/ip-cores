//databuffer_l2_tb.cpp

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

#include "databuffer_l2_tb.h"
#include <cstdlib>

databuffer_l2_tb::databuffer_l2_tb(sc_module_name name) : sc_module(name){
	SC_THREAD(manage_memories);
	sensitive_pos(clk);

	SC_THREAD(store_data);
	sensitive_pos(clk);

	SC_THREAD(read_data);
	sensitive_pos(clk);

	SC_THREAD(manage_nops);
	sensitive_pos(clk);

	SC_THREAD(manage_reset);
	sensitive_pos(clk);

	SC_THREAD(convert_vcs);
	sensitive << cd_vctype_db
	<< eh_vctype_db
	<< csr_vctype_db
	<< ui_vctype_db
	<< fwd_vctype_db;


	//Flag testbench entries as free
	for(int n = 3 * DATABUFFER_NB_BUFFERS - 1; n >= 0; n--)
		((int*)data_packets_size)[n] = 0;

	for(int n = 0; n < 3; n++){
		data_packets_count[n] = 0;
		data_packets_allowed[n] = 0;
	}

	allow_overflow = false;
	srand(11843);
}

void databuffer_l2_tb::store_data(){
	ldtstopx = true;
	//The count of dwords to send to the databuffer
	int data_left_to_send = 0;
	//The total size of the packet being sent
	int current_packet_size = 0;
	//The count of data sent
	int data_sent = 0;
	//The address given by databuffer for packet currently being sent
	int address;
	//The virtual channel of the data packet
	int vc;
	//If we are allowed to drop the packet
	bool droppable = false;
	//This is synchrous process, so when get_addr is driven, the address given must be stored
	//the next cycle.  The cycle store_address_next_cycle is set, address should be read.
	bool store_address_next_cycle = false;;

	cd_write_db = false;
	cd_getaddr_db = false;
	cd_drop_db = false;
	cd_initiate_retry_disconnect = false;

	int clock_cycle = 0;

	
	while(true){
		//Wait until next clock cycle
		wait();
		clock_cycle++;

		//Randomly drop packets
		bool drop = (rand()/((float)RAND_MAX) ) < 0.02;

		//Chance of writing data to the databuffer when packet is started
		bool proceed = (rand()/((float)RAND_MAX) ) < 0.9 ;
		//Chance of starting a packet
		bool proceed2 = (rand()/((float)RAND_MAX) ) < 0.7;

		cd_write_db = false;
		cd_getaddr_db = false;
		cd_drop_db = false;
		cd_initiate_retry_disconnect = false;

		//If the last cycle, we outputed a new packet, store the adress
		//from the databuffer this cycle
		if(store_address_next_cycle){
			store_address_next_cycle = false;
			address = db_address_cd.read();
			//Check if there is already a packet at that address
			if(data_packets_size[vc][address]){
				cout << "Error, data packet stored where it is not allowed" << endl;
				cout  << "VC: " << vc << " address: " << address << " clock_cycle: " << clock_cycle << endl;
			}
		}

		//The dropping the current packet
		if(drop && droppable){
			cd_drop_db = true;
			droppable = false;
			data_packets_size[vc][address] = 0;
			data_packets_count[vc]--;
			data_left_to_send = 0;
		}
		//If a new packet can be started
		else if(proceed2 && !data_left_to_send){

			cd_write_db = false;
			cd_drop_db = false;

			//Start by seing in which VC's packets can be sent
			int vc_available[3];
			int pos = 0;
			int vc_count = 0;
			//Iterate over the three vcs
			for(int n = 0; n < 3; n++){
				//If more data can be sent in that vc (or if overflow is allowed), add the
				//vc to the list of available vcs!
				if(data_packets_allowed[n] != 0 || allow_overflow){
					vc_available[pos++] = n;
					vc_count++;
				}
			}

			//If we found a vc (count is not 0)
			if( (bool)(vc_count)){
				//Randomly select the size
				data_left_to_send = (int)(rand() / (RAND_MAX + 1.0) * 16 + 1);
				current_packet_size = data_left_to_send;

				data_sent = 0;

				//Randomly choose a vc from the list of available vc's
				int vc_to_send = vc_available[(int)(rand() / (RAND_MAX + 1.0) * vc_count)];
				
				vc = vc_to_send;

				//Update the buffer counts
				data_packets_allowed[vc_to_send]--;
				data_packets_count[vc_to_send]++;

				//Request an address for the packet from the databuffer
				cd_datalen_db = data_left_to_send - 1;
				cd_vctype_db = (VirtualChannel)vc_to_send;
				cd_getaddr_db = true;
				droppable = true;
				store_address_next_cycle = true;
			}
			
		}
		//Actually send the data 
		else if(proceed && data_left_to_send){
			//start by generating a random 32-bit integer

			//RAND_MAX may be as low as 32k in some librairies (VC++ for example),
			//so to be uniform, mask the higher 17 bits
			int r  = rand() & 0x7FFF;
			int r1 = rand() & 0x7FFF;
			int r2 = rand() & 0x7FFF;

			r = r | (r1 << 15) | (r2 << 30);

			cd_data_db = sc_uint<32>(r);
			data_packets[vc][address][data_sent] = r;

			cd_write_db = true;
			data_left_to_send--;
			data_sent++;
			if(!data_left_to_send)
				data_packets_size[vc][address] = current_packet_size;
		}

	}
}

void databuffer_l2_tb::read_data(){
	int fwd_read_left = 0;
	int fwd_address = 0;
	int fwd_vc = 0;

	int accepted_read_left = 0;
	int accepted_address = 0;
	int accepted_vc = 0;
	bool csr_access = false;

	csr_read_db = false;
	ui_read_db = false;
	fwd_read_db = false;
	eh_erase_db = false;
	csr_erase_db = false;
	ui_erase_db = false;
	fwd_erase_db = false;

	int debug_read_count = 0;

	cout << "If there are no error message, test is successful!" << endl;

	while(true){
		wait();


		csr_read_db = false;
		ui_read_db = false;
		fwd_read_db = false;
		eh_erase_db = false;
		csr_erase_db = false;
		ui_erase_db = false;
		fwd_erase_db = false;

		//If the last packet sent from command decoder should be dropped
		bool drop_proceed = (rand()/((float)RAND_MAX) ) < 0.01;
		//If a read should be done from the accepted port
		bool accepted_proceed = (rand()/((float)RAND_MAX) ) < 0.2 ;
		//If a read should be done from the forward port
		bool fwd_proceed = (rand()/((float)RAND_MAX) ) < 0.3;

		//Fin some random packets to extract
		int entries_address[3 * DATABUFFER_NB_BUFFERS];
		int entries_vc[3 * DATABUFFER_NB_BUFFERS];
		
		//Start by finding all valid entries
		int entries_count = 0;
		//for all 3 vc
		for(int x = 0; x < 3; x++){
			//for every packet in the vc
			for(int y = 0 ; y < DATABUFFER_NB_BUFFERS; y++){
				//Check if there is packet (size is non zero) and is not currently being
				//read by the forward of the accepted read ports
				if(data_packets_size[x][y] && !(
					x == fwd_vc && y == fwd_address && (fwd_read_left || fwd_erase_db.read())  ||
					x == accepted_vc && y == accepted_address && (accepted_read_left || csr_erase_db.read() || ui_erase_db.read())))
				{
					entries_address[entries_count] = y;
					entries_vc[entries_count++] = x;
				}
			}
		}

		////////////////////////////////////////////////////////
		//	Test If output is correct
		//
		//	Read signals were set by the randomly set "proceed"
		//  variables on the LAST cycle.  Now we check if the
		//  output from those reads are correct.
		////////////////////////////////////////////////////////



		//Check if the dababuffer output on the Forward port is correct
		if(fwd_read_db.read()){
			//Check if db_data_fwd is correct
			if( data_packets[fwd_vc][fwd_address]
					[data_packets_size[fwd_vc][fwd_address]-fwd_read_left-1] 
				!= (int)((sc_uint<32>)db_data_fwd.read()))
			{
				cout << "Data signal has wrong value on Forward port" << endl;
				cout << "Data VC: "<< (int)fwd_vc  << " Address: " << fwd_address <<
					" Pos: " << data_packets_size[fwd_vc][fwd_address]-fwd_read_left-1 << endl;
				cout << "Data expected: " << ((sc_uint<32>)data_packets[fwd_vc][fwd_address]
					[data_packets_size[fwd_vc][fwd_address]-fwd_read_left-1]).to_string(SC_HEX) << endl;
				cout << "Data received: " << ((sc_uint<32>)db_data_fwd.read()).to_string(SC_HEX) << endl;
			}

			//On last read, clear the value
			if(!fwd_read_left)
				data_packets_size[fwd_vc][fwd_address] = 0;
		}

		//Check if the dababuffer output on the Forward port is correct
		if(csr_read_db.read() || ui_read_db.read()){
			//Check if db_data_fwd is correct
			if( data_packets[accepted_vc][accepted_address]
					[data_packets_size[accepted_vc][accepted_address]-accepted_read_left-1] 
				!= (int)((sc_uint<32>)db_data_accepted.read()))
			{
				cout << "Data signal has wrong value on Accepted port" << endl;
				cout << "Data VC: "<< (int)accepted_vc  << " Address: " << accepted_address <<
					" Pos: " << data_packets_size[accepted_vc][accepted_address]-accepted_read_left-1 << endl;
				cout << "Data expected: " << ((sc_uint<32>)data_packets[accepted_vc][accepted_address]
					[data_packets_size[accepted_vc][accepted_address]-accepted_read_left-1]
					).to_string(SC_HEX) << endl;
				cout << "Data received: " << ((sc_uint<32>)db_data_accepted.read()).to_string(SC_HEX) << endl;
			}

			//On last read, clear the value
			if(!accepted_read_left)
				data_packets_size[accepted_vc][accepted_address] = 0;
		}

		////////////////////////////////////////////////////////
		//	Activate the correct read signals
		////////////////////////////////////////////////////////
		
		//Do the read on the Forward port
		if(fwd_proceed){
			//If no packet has been started
			if(!fwd_read_left && entries_count > 0){
				//Find one in the list of valid entries
				int pos = (int)(rand() / (RAND_MAX + 1.0) * entries_count);
				fwd_address_db = entries_address[pos];
				fwd_vctype_db = (VirtualChannel)entries_vc[pos];
				fwd_read_left = data_packets_size[entries_vc[pos]][entries_address[pos]];
				fwd_address = entries_address[pos];
				fwd_vc = entries_vc[pos];
				
				//Remove that entry
				entries_count--;
				for(int n = pos; n < entries_count;n++){
					entries_address[n] = entries_address[n+1];
					entries_vc[n] = entries_vc[n+1];
				}
			}
			else if(fwd_read_left > 0){
				fwd_read_db = true;
				fwd_read_left--;
				fwd_erase_db = fwd_read_left == 0;
			}
		}

		//Do the read on the Forward port
		if(accepted_proceed){
			//If no packet has been started
			if(!accepted_read_left && entries_count > 0){

				//Decide if it's the CSR or UI reading
				csr_access = (rand()/((float)RAND_MAX) ) < 0.5;

				//Find one in the list of valid entries
				int pos = (int)(rand() / (RAND_MAX + 1.0) * entries_count);
				accepted_read_left = data_packets_size[entries_vc[pos]][entries_address[pos]];

				//Activate the correct address and vc signals depending on if it is the CSR or the
				//UI accessing the data.
				if(csr_access){
					csr_address_db = entries_address[pos];
					csr_vctype_db = (VirtualChannel)entries_vc[pos];
					ui_address_db = 0;
					ui_vctype_db = VC_NONE;
					ui_grant_csr_access_db = true;
				}
				else{
					csr_address_db = 0;
					csr_vctype_db = VC_NONE;
					ui_address_db = entries_address[pos];
					ui_vctype_db = (VirtualChannel)entries_vc[pos];
					ui_grant_csr_access_db = false;
				}
				accepted_address = entries_address[pos];
				accepted_vc = entries_vc[pos];

				
				//Remove that entry
				entries_count--;
				for(int n = pos; n < entries_count;n++){
					entries_address[n] = entries_address[n+1];
					entries_vc[n] = entries_vc[n+1];
				}
			}
			else if(accepted_read_left > 0){
				accepted_read_left--;
				if(csr_access){
					ui_read_db = false;
					csr_read_db = true;
					csr_erase_db = accepted_read_left == 0;
				}
				else{
					ui_read_db = true;
					csr_read_db = false;
					ui_erase_db = accepted_read_left == 0;
				}
			}
		}

		////////////////////////////////////////////////////////
		//	Test the Error drop Port
		////////////////////////////////////////////////////////

		if(drop_proceed && entries_count != 0){
			//Find one in the list of valid entries
			int pos = (int)(rand() / (RAND_MAX + 1.0) * entries_count);
			int address = entries_address[pos];
			int vc = entries_vc[pos];
			data_packets_size[vc][address] = 0;

			eh_address_db = address;
			eh_vctype_db = (VirtualChannel) vc;
			eh_erase_db = true;
		}
	}
}


void databuffer_l2_tb::manage_nops(){
	fc_nop_sent = false;
	bool nop_requested = false;
	error = false;
	bool should_request = false;

	while(true){
		wait();
		
		fc_nop_sent = false;
		if(!resetx.read()){
			for(int n = 0; n < 3; n++){
				data_packets_count[n] = 0;
				data_packets_allowed[n] = 0;
			}
		}
		else{
			//Add a tad bit of randomness, just for fun!
			bool proceed = (rand()/((float)RAND_MAX) ) < 0.2 ;
			bool dont_proceed = (rand()/((float)RAND_MAX) ) < 0.2 ;

			//Remember when a nop is requested
			if(db_nop_req_fc.read()){
				nop_requested = true;
			}

			//When a nop is being sent out, update the free buffers
			if(fc_nop_sent.read()){
				sc_uint<2> nonposted_freed = (sc_bv<2>)db_buffer_cnt_fc.read().range(5,4);
				sc_uint<2> posted_freed = (sc_bv<2>)db_buffer_cnt_fc.read().range(1,0);
				sc_uint<2> response_freed = (sc_bv<2>)db_buffer_cnt_fc.read().range(3,2);
				data_packets_allowed[VC_NON_POSTED] += nonposted_freed;
				data_packets_allowed[VC_POSTED] += posted_freed;
				data_packets_allowed[VC_RESPONSE] += response_freed;
			}


			if(should_request && !nop_requested && !fc_nop_sent.read()){
				cout << "ERROR: Databuffer not correctly requesting nops to be sent" << endl;
				error = true;
			}

			//When there is a request, send a nop
			if(db_nop_req_fc.read() && !dont_proceed || proceed){
				fc_nop_sent = true;
				nop_requested = false;//Reset when sent
			}

			//Verify that the databuffer correctly requests sending nops when
			//necessary.  Do it at the end so that it has a delay of one cycle because
			//the databuffer also takes a cycle to answer
			should_request = false;
			for(int n = 0; n < 3; n++){
				if(data_packets_allowed[n] < (DATABUFFER_NB_BUFFERS - data_packets_count[n] - 2))
					should_request = true;
			}
		}
		
	}	
}


void databuffer_l2_tb::manage_memories(){
	//Initialise memory
	for(int n = 3 * DATABUFFER_NB_BUFFERS * 16 - 1
		; n >= 0; n--)
		((int*)memory)[n] = 0;

	while(true){
		wait();
		
		//Manage writing
		if(memory_write.read()){
			if(memory_write_address_vc.read() != 3)
				memory[memory_write_address_vc.read()][memory_write_address_buffer.read()]
				[memory_write_address_pos.read()] = (int)(sc_uint<32>)(memory_write_data.read());
			else
				cout << "Critical ERROR : writing to VC 3 in memory (doesn't exist)" << endl;
		}

		//Manage reading
		for(int port = 0; port < 2; port++){
			memory_output[port] = memory[memory_read_address_vc[port].read()]
				[memory_read_address_buffer[port].read()][memory_read_address_pos[port].read()];
		}

	}
}

void databuffer_l2_tb::manage_reset(){
	resetx = false;
	int count = 0;
	while(count++ < 5)wait();
	resetx = true;
	while(true) wait();
}

void databuffer_l2_tb::convert_vcs(){
	while(true){
		cd_vctype_db_trace = (int)cd_vctype_db.read();
		eh_vctype_db_trace = (int)eh_vctype_db.read();
		csr_vctype_db_trace = (int)csr_vctype_db.read();
		ui_vctype_db_trace = (int)ui_vctype_db.read();
		fwd_vctype_db_trace = (int)fwd_vctype_db.read();
		wait();
	}
}
