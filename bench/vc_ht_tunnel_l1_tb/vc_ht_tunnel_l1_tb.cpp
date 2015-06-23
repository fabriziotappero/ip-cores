//vc_ht_tunnel_l1_tb.cpp

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

#include "vc_ht_tunnel_l1_tb.h"
#include "PhysicalLayer.h"
#include "LogicalLayer.h"
#include "InterfaceLayer.h"

#include "../core/RequestPacket.h"

vc_ht_tunnel_l1_tb::vc_ht_tunnel_l1_tb(sc_module_name name) : sc_module(name){
	SC_THREAD(manage_memories);
	sensitive_pos(clk);

	SC_METHOD(drive_async_outputs);
	sensitive_neg(clk);

	SC_THREAD(run);
	sensitive_pos(clk);

	cout << "Constructing testbench" << endl;

	physicalLayer0 = new PhysicalLayer("physicalLayer0");
	physicalLayer0->clk(clk);
	physicalLayer0->resetx(resetx);
	physicalLayer0->phy_available_lk(phy0_available_lk0_buf);
	physicalLayer0->phy_ctl_lk(phy0_ctl_lk0_buf);
	for(int n = 0; n < CAD_IN_WIDTH; n++){
		physicalLayer0->phy_cad_lk[n](phy0_cad_lk0_buf[n]);
	}
	physicalLayer0->lk_ctl_phy(lk0_ctl_phy0);
	for(int n = 0; n < CAD_OUT_WIDTH; n++){
		physicalLayer0->lk_cad_phy[n](lk0_cad_phy0[n]);
	}
	physicalLayer0->phy_consume_lk(phy0_consume_lk0_buf);
	physicalLayer0->lk_disable_drivers_phy(lk0_disable_drivers_phy0);
	physicalLayer0->lk_disable_receivers_phy(lk0_disable_receivers_phy0);


	logicalLayer0 = new LogicalLayer("logicalLayer0");
	logicalLayer0->clk(clk);
	logicalLayer0->resetx(resetx);


	physicalLayer1= new PhysicalLayer("physicalLayer1");
	physicalLayer1->clk(clk);
	physicalLayer1->resetx(resetx);
	physicalLayer1->phy_available_lk(phy1_available_lk1_buf);
	physicalLayer1->phy_ctl_lk(phy1_ctl_lk1_buf);
	for(int n = 0; n < CAD_IN_WIDTH; n++){
		physicalLayer1->phy_cad_lk[n](phy1_cad_lk1_buf[n]);
	}
	physicalLayer1->lk_ctl_phy(lk1_ctl_phy1);
	for(int n = 0; n < CAD_OUT_WIDTH; n++){
		physicalLayer1->lk_cad_phy[n](lk1_cad_phy1[n]);
	}
	physicalLayer1->phy_consume_lk(phy1_consume_lk1_buf);
	physicalLayer1->lk_disable_drivers_phy(lk1_disable_drivers_phy1);
	physicalLayer1->lk_disable_receivers_phy(lk1_disable_receivers_phy1);


	logicalLayer1 = new LogicalLayer("logicalLayer1");
	logicalLayer1->clk(clk);
	logicalLayer1->resetx(resetx);


	interfaceLayer = new InterfaceLayer("interfaceLayer");
	interfaceLayer->clk(clk);
	interfaceLayer->resetx(resetx);
	interfaceLayer->ui_packet_usr(ui_packet_usr);
	interfaceLayer->ui_vc_usr(ui_vc_usr);
	interfaceLayer->ui_side_usr(ui_side_usr);
	interfaceLayer->ui_directroute_usr(ui_directroute_usr);
	interfaceLayer->ui_eop_usr(ui_eop_usr);
	interfaceLayer->ui_available_usr(ui_available_usr);
	interfaceLayer->ui_output_64bits_usr(ui_output_64bits_usr);
	interfaceLayer->usr_consume_ui(usr_consume_ui_buf);
	interfaceLayer->usr_packet_ui(usr_packet_ui_buf);
	interfaceLayer->usr_available_ui(usr_available_ui_buf);
	interfaceLayer->usr_side_ui(usr_side_ui_buf);
	interfaceLayer->ui_freevc0_usr(ui_freevc0_usr);
	interfaceLayer->ui_freevc1_usr(ui_freevc1_usr);
	interfaceLayer->usr_receivedResponseError_csr(usr_receivedResponseError_csr_buf);

	logicalLayer0->setInterface(this);
	logicalLayer0->setPhysicalLayer(physicalLayer0);
	logicalLayer1->setInterface(this);
	logicalLayer1->setPhysicalLayer(physicalLayer1);
	interfaceLayer->setInterfaceLayerEventHandler(this);

	count_side0 = 0;
	count_side1 = 0;
	count_interface = 0;
}

vc_ht_tunnel_l1_tb::~vc_ht_tunnel_l1_tb(){
	delete physicalLayer0;
	delete logicalLayer0;
	delete physicalLayer1;
	delete logicalLayer1;
	delete interfaceLayer;
}

void vc_ht_tunnel_l1_tb::manage_memories(){
	while(true){
		//UI memories
		ui_memory_read_data0 = ui_memory0[ui_memory_read_address0.read().to_int()];
		ui_memory_read_data1 = ui_memory1[ui_memory_read_address1.read().to_int()];
		if(ui_memory_write0.read()) ui_memory0[ui_memory_write_address.read().to_int()] = 
			ui_memory_write_data.read().to_int();
		if(ui_memory_write1.read()) ui_memory1[ui_memory_write_address.read().to_int()] = 
			ui_memory_write_data.read().to_int();


#ifdef RETRY_MODE_ENABLED
		//////////////////////////////////////////
		//	History memories
		/////////////////////////////////////////
		history_memory_output0 = history_memory0[history_memory_read_address0.read().to_int()];
		history_memory_output1 = history_memory1[history_memory_read_address1.read().to_int()];
		if(history_memory_write0.read()) history_memory0[history_memory_write_address0.read().to_int()] = 
			history_memory_write_data0.read().to_int();
		if(history_memory_write1.read()) history_memory1[history_memory_write_address1.read().to_int()] = 
			history_memory_write_data1.read().to_int();

#endif
		
		////////////////////////////////////
		// DataBuffer Memories
		////////////////////////////////////
		for(int n = 0; n < 2; n++){
			memory_output0[n] = databuffer_memory0[memory_read_address_vc0[n].read().to_int()]
				[memory_read_address_buffer0[n].read().to_int()]
				[memory_read_address_pos0[n].read().to_int()];
			memory_output1[n] = databuffer_memory1[memory_read_address_vc1[n].read().to_int()]
				[memory_read_address_buffer1[n].read().to_int()]
				[memory_read_address_pos1[n].read().to_int()];

		}

		if(memory_write0) databuffer_memory0[memory_write_address_vc0.read()]
			[memory_write_address_buffer0.read()][memory_write_address_pos0.read()] = 
				memory_write_data0.read().to_int();
		if(memory_write1) databuffer_memory1[memory_write_address_vc1.read()]
			[memory_write_address_buffer1.read()][memory_write_address_pos1.read()] = 
				memory_write_data1.read().to_int();

		////////////////////////////////////
		// CoommandBuffer Memories
		////////////////////////////////////
		for(int n = 0; n < 2; n++){
			command_packet_rd_data_ro0[n] = 
				command_memory0[ro0_command_packet_rd_addr[n].read().to_int()];
			command_packet_rd_data_ro1[n] = 
				command_memory1[ro1_command_packet_rd_addr[n].read().to_int()];

		}

		if(ro0_command_packet_write.read()) 
			command_memory0[ro0_command_packet_wr_addr.read().to_int()] = 
				ro0_command_packet_wr_data.read();
		if(ro1_command_packet_write.read()) 
			command_memory1[ro1_command_packet_wr_addr.read().to_int()] = 
				ro1_command_packet_wr_data.read();

		wait();
	}

}

void vc_ht_tunnel_l1_tb::run(){
	cout << "TestBench Running" << endl;
	cout << "Sending reset" << endl;

	pwrok_buf = false;
	resetx_buf = false;
	ldtstopx_buf = true;

	for(int n = 0; n < 4; n++)wait();

	pwrok_buf = true;

	for(int n = 0; n < 4; n++)wait();
	
	resetx_buf = true;

	//////////////////////////////////////////////////
	// Change the UnitID to 1
	//////////////////////////////////////////////////

	sc_bv<38> write_address;
	write_address.range(29,0) = (sc_uint<30>) (sc_uint<32>(0xFE000040).range(31,2));
	write_address.range(37,30) = sc_uint<8>(0xFD);
	int * write_data = new int[1];
	write_data[0] = 0x00010000;


	WritePacket* write = new WritePacket(0/*seqID*/,0 /*unitID*/,0 /*srcTag*/,
					  0/*count*/,write_address,
					  true /*doubleWordDataLength*/);

	logicalLayer0->sendPacket(write,write_data);
	cout << "sending a first write: " << *write << endl;
	cout << "with 1 data: " << write_data[0] << endl;

	//////////////////////////////////////////////////
	// Wait for a response that the UnitID has been changed
	//////////////////////////////////////////////////
	while(!count_side0) wait();

	//////////////////////////////////////////////////
	// Send another write to UID 0, should go through
	//////////////////////////////////////////////////
	cout << "sending a second write" << endl;

	write_data = new int[1];
	write_data[0] = 0x00010000;
	write = new WritePacket(0/*seqID*/,0 /*unitID*/,0 /*srcTag*/,
					  0/*count*/,write_address,
					  true /*doubleWordDataLength*/);

	logicalLayer0->sendPacket(write,write_data);

	//////////////////////////////////////////////////
	// Setup the BAR address and enable memory and io space
	// and bus master enable
	//////////////////////////////////////////////////
	write_address.range(29,0) = (sc_uint<30>) (sc_uint<32>(0xFE000804).range(31,2));
	write_address.range(37,30) = sc_uint<8>(0xFD);
	write_data = new int[4];
	write_data[0] = 7;
	write_data[1] = 0;
	write_data[2] = 0;
	write_data[3] = 0x12345000;
	write = new WritePacket(0/*seqID*/,0 /*unitID*/,0 /*srcTag*/,
					  3/*count*/,write_address,
					  true /*doubleWordDataLength*/);

	received_side0 = false;
	logicalLayer0->sendPacket(write,write_data);

	//////////////////////////////////////////////////
	// Wait for an answer
	//////////////////////////////////////////////////
	while(!received_side0) wait();

	//////////////////////////////////////////////////
	// Send message to the user of the tunnel
	//////////////////////////////////////////////////
	received_side0 = false;
	write_address.range(29,0) = (sc_uint<30>) (sc_uint<32>(0x12345124).range(31,2));
	write_address.range(37,30) = sc_uint<8>(0x00);
	write_data = new int[4];
	write_data[0] = 0x97351728;
	write_data[1] = 0x24762655;
	write_data[2] = 0x22267436;
	write_data[3] = 0x07907544;
	write = new WritePacket(0/*seqID*/,0 /*unitID*/,1 /*srcTag*/,
					  3/*count*/,write_address,
					  true /*doubleWordDataLength*/);
	logicalLayer0->sendPacket(write,write_data);

	//////////////////////////////////////////////////
	// Send a packet that should generate an error
	//////////////////////////////////////////////////
	ReadPacket* read = new ReadPacket(0,0,0,2,0,true);
	AddressExtensionPacket *addrExt = new AddressExtensionPacket(0x121234,read->getVector());
	delete read;
	logicalLayer0->sendPacket(addrExt,NULL);

	while(!received_side0) wait();
	count_side0 = 0;
	//////////////////////////////////////////////////
	// Send a message from the interface
	//////////////////////////////////////////////////

	cout << "Sending packet from interface!" << endl;

	write_address.range(29,0) = (sc_uint<30>) (sc_uint<32>(0x00014230).range(31,2));
	write_address.range(37,30) = sc_uint<8>(0x00);
	write_data = new int[2];
	write_data[1] = 0x76543210;
	write_data[0] = 0x00073360;
	write = new WritePacket(0/*seqID*/,1 /*unitID*/,1/*count*/,
						write_address,
					  true /*doubleWordDataLength*/);
	interfaceLayer->sendPacket(write,write_data,false);

	///////////////////////////////////////////////////
	// Attempting LDTSTOP sequence (without retry mode)
	///////////////////////////////////////////////////

	cout << "Attempting LDTSTOP sequence" << endl;

	logicalLayer0->flush();
	ldtstopx_buf.write(false);
	NopPacket * disconNop = new NopPacket(0,0,0,0,0,0,true);
	logicalLayer0->sendPacket(disconNop,NULL);
	physicalLayer0->ldtstopDisconnect();
	physicalLayer1->ldtstopDisconnect();

	for(int n = 0; n < 150; n++) wait();
	ldtstopx_buf.write(true);
	physicalLayer0->ldtstopConnect();
	physicalLayer1->ldtstopConnect();
	
	cout << "LDTSTOP sequence done" << endl;

#ifdef RETRY_MODE_ENABLED
	//////////////////////////////////////////////////////
	// Set the retry mode in the tunnel for link 1
	//////////////////////////////////////////////////////
	write_address.range(29,0) = (sc_uint<30>) (sc_uint<32>(0xFE000800+ErrorRetry_Pointer+4).range(31,2));
	write_address.range(37,30) = sc_uint<8>(0xFD);
	write_data = new int[1];
	write_data[0] = 0x00C000C1;


	write = new WritePacket(0/*seqID*/,0 /*unitID*/,5 /*srcTag*/,
					  0/*count*/,write_address,
					  true /*doubleWordDataLength*/);

	logicalLayer0->sendPacket(write,write_data);

	while(count_side0 != 2) wait();
	count_side0 = 0;

	logicalLayer0->setRetryMode(true);
	resetx_buf = false;


	//////////////////////////////////////////////////////
	// Enter retry mode
	//////////////////////////////////////////////////////
	
	for(int n = 0; n < 3; n++)wait();
	
	resetx_buf = true;

	count_side1 = 0;

	//////////////////////////////////////////////////
	// Send a write to UID 1, should go through
	//////////////////////////////////////////////////
	cout << "sending a second write" << endl;

	write_address.range(29,0) = (sc_uint<30>) (sc_uint<32>(0xFE000840).range(31,2));
	write_address.range(37,30) = sc_uint<8>(0xFD);
	write_data = new int[1];
	write_data[0] = 1;
	write = new WritePacket(0/*seqID*/,0 /*unitID*/,0 /*srcTag*/,
					  0/*count*/,write_address,
					  true /*doubleWordDataLength*/);

	logicalLayer0->sendPacket(write,write_data);

	while(!count_side1) wait();

	//////////////////////////////////////////////////
	// Setup the BAR address and enable memory and io space
	// and bus master enable
	//////////////////////////////////////////////////
	write_address.range(29,0) = (sc_uint<30>) (sc_uint<32>(0xFE000004).range(31,2));
	write_address.range(37,30) = sc_uint<8>(0xFD);
	write_data = new int[4];
	write_data[0] = 7;
	write_data[1] = 0;
	write_data[2] = 0;
	write_data[3] = 0x12345000;
	write = new WritePacket(0/*seqID*/,0 /*unitID*/,0 /*srcTag*/,
					  3/*count*/,write_address,
					  true /*doubleWordDataLength*/);

	received_side0 = false;
	logicalLayer0->sendPacket(write,write_data);

	//////////////////////////////////////////////////
	// Wait for an answer
	//////////////////////////////////////////////////
	while(!received_side0) wait();

	//////////////////////////////////////////////////
	// Attempt a retry sequence
	// Send multiple packets, but ignore them
	// Then initiate retry sequence
	// Packets should be resent
	//////////////////////////////////////////////////

	cout << "Testing retry sequence!" << endl;

	//Start by sending packets
	for(int n = 0; n < 4; n++){
		write_address.range(29,0) = (sc_uint<30>) (sc_uint<32>(0x00014230).range(31,2));
		write_address.range(37,30) = sc_uint<8>(0x00);
		
		write_data = new int[2];
		write_data[1] = 4635 +56*n;
		write_data[0] = 586955 +12556*n;
		write = new WritePacket(n/*seqID*/,1 /*unitID*/,1/*count*/,
							write_address,
						true /*doubleWordDataLength*/);
		interfaceLayer->sendPacket(write,write_data,false);
	}
	logicalLayer0->setIgnoreIncoming(true);

	//Make sure that all packets are sent
	cout << "Flushing packets sent..." ;
	interfaceLayer->flush();
	cout << "done" << endl;

	cout << "Waiting some cycles." ;
	//Wait some cycles to make sure packets are really sent out
	for(int n = 0; n < 50; n++) wait();

	cout << "Initiate retry sequence" << endl ;
	logicalLayer0->initiateRetrySequence();
	for(int n = 0; n < 5; n++) wait();

	cout << "Stop ignore input" << endl ;
	logicalLayer0->setIgnoreIncoming(false);

	for(int n = 0; n < 150; n++) wait();

#endif

	//logicalLayer0->displayReceivedDword = true;



	//////////////////////////////////////////////////
	// Done
	//////////////////////////////////////////////////
	while(true) wait();
}

void vc_ht_tunnel_l1_tb::receivedHtPacketEvent(const ControlPacket * packet,
								   const int * data,const LogicalLayer* origin)
{
	cout << "Received HT Packet: " << *packet << endl;
	if(origin == logicalLayer0){ 
		cout << "From side 0" << endl;
		count_side0++;
		received_side0 = true;
	}
	else{
		cout << "From side 1" << endl;
		count_side1++;
	}
	int length = (int)packet->getDataLengthm1()+1;
	if(!packet->hasDataAssociated())length = 0;
	cout << "with " << length << " data: " << endl;
	for(int n = 0; n < length; n++){
		cout << sc_uint<32>(data[n]).to_string(SC_HEX) << endl;
	}

}

void vc_ht_tunnel_l1_tb::crcErrorDetected(){
	cout << "CRC ERROR detected" << endl;
	resetx = false;
}

void vc_ht_tunnel_l1_tb::receivedInterfacePacketEvent(const ControlPacket * packet,const int * data,
										  bool directRoute,bool side,InterfaceLayer* origin)
{
	cout << "Received Interface Packet: " << *packet << endl;
	int length = (int)packet->getDataLengthm1()+1;
	if(!packet->hasDataAssociated())length = 0;
	cout << "with " << length << " data: " << endl;
	for(int n = 0; n < length; n++){
		cout << sc_uint<32>(data[n]).to_string(SC_HEX) << endl;
	}
	count_interface++;
}

void vc_ht_tunnel_l1_tb::drive_async_outputs(){
	resetx = resetx_buf;
	pwrok = pwrok_buf;
	ldtstopx = ldtstopx_buf;
	usr_consume_ui = usr_consume_ui_buf;
	usr_packet_ui = usr_packet_ui_buf;
	usr_available_ui = usr_available_ui_buf;
	usr_side_ui = usr_side_ui_buf;
	usr_receivedResponseError_csr = usr_receivedResponseError_csr_buf;

	phy0_available_lk0 = phy0_available_lk0_buf;
	phy0_ctl_lk0 = phy0_ctl_lk0_buf;
	for(int n = 0; n < CAD_IN_WIDTH; n++){
		phy0_cad_lk0[n] = phy0_cad_lk0_buf[n];
	}
	phy0_consume_lk0 = phy0_consume_lk0_buf;

	phy1_available_lk1 = phy1_available_lk1_buf;
	phy1_ctl_lk1 = phy1_ctl_lk1_buf;
	for(int n = 0; n < CAD_IN_WIDTH; n++){
		phy1_cad_lk1[n] = phy1_cad_lk1_buf[n];
	}
	phy1_consume_lk1 = phy1_consume_lk1_buf;
}


