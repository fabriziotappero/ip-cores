//decoder_l2.cpp

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
 *   Max-Elie Salomon
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

#include "decoder_l2.h"

#include "cd_state_machine_l3.h"
#include "cd_counter_l3.h"
#include "cd_cmd_buffer_l3.h"
#include "cd_cmdwdata_buffer_l3.h"
#include "cd_mux_l3.h"
#include "cd_nop_handler_l3.h"
#include "cd_history_rx_l3.h"
#include "cd_packet_crc_l3.h"

void decoder_l2::set_outputs()
{
	PacketCommand cmd = getPacketCommand(sc_bv<6>(lk_dword_cd.read()));

	cd_data_db = lk_dword_cd;
	cd_getaddr_db = getAddressSetCnt;
	cd_datalen_db = (sc_bv<4>)(lk_dword_cd.read().range(25,22));
	cd_vctype_db = getVirtualChannel(sc_bv<64>(lk_dword_cd.read()),cmd);

}


decoder_l2::decoder_l2( sc_module_name name) : sc_module(name)
{
	
	SC_METHOD(set_outputs);
	sensitive << lk_dword_cd << getAddressSetCnt;
	
	
	SM = new cd_state_machine_l3("SM");
	
	SM->clk(clk);
	SM->dWordIn(lk_dword_cd);
	SM->lk_lctl_cd(lk_lctl_cd);
	SM->lk_hctl_cd(lk_hctl_cd);
	SM->lk_available_cd(lk_available_cd);
	SM->cd_protocol_error_csr(cd_protocol_error_csr);
	SM->resetx(resetx);
	SM->end_of_count(end_of_count);
	SM->getAddressSetCnt(getAddressSetCnt);
	SM->cd_write_db(cd_write_db);
	//SM->decrCnt(decrCnt);
	SM->cd_available_ro(cd_available_ro);
	SM->enCtlwData1(enCtlWdata1);
	SM->enCtlwData2(enCtlWdata2);
#ifdef RETRY_MODE_ENABLED
	SM->selCtlPckt(selCtlPckt);
	SM->enCtl1(enCtl1);
	SM->enCtl2(enCtl2);
#endif
	SM->setNopCnt(setNopCnt);
	SM->cd_sync_detected_csr(cd_sync_detected_csr);
#ifdef RETRY_MODE_ENABLED
	SM->error64Bits(error64Bits);
#endif
	SM->error64BitsCtlwData(error64BitsCtlwData);
	SM->send_nop_notification(send_nop_notification);
	//SM->count_done(count_done);
	SM->cd_initiate_nonretry_disconnect_lk(cd_initiate_nonretry_disconnect_lk);
	SM->cd_data_pending_ro(cd_data_pending_ro);
#ifdef RETRY_MODE_ENABLED
	SM->cd_drop_db(cd_drop_db);
	SM->csr_retry(csr_retry);
	SM->cd_initiate_retry_disconnect(cd_initiate_retry_disconnect);
	SM->crc1_good(crc1_good);
	SM->crc2_good(crc2_good);
	SM->crc1_stomped(crc1_stomped);
	SM->crc2_stomped(crc2_stomped);
	SM->crc1_enable(crc1_enable);
	SM->crc2_enable(crc2_enable);
	SM->crc1_reset(crc1_reset);
	SM->crc2_reset(crc2_reset);
	SM->crc2_if_ctl(crc2_if_ctl);
	SM->cd_received_stomped_csr(cd_received_stomped_csr);
	SM->cd_received_non_flow_stomped_ro(cd_received_non_flow_stomped_ro);
	SM->lk_initiate_retry_disconnect(lk_initiate_retry_disconnect);
#endif

	CNT = new cd_counter_l3("CNT");
	
	CNT->clk(clk);
	CNT->resetx(resetx);
	CNT->setCnt(getAddressSetCnt);
	CNT->decrCnt(cd_write_db);
	CNT->data(lk_dword_cd);
	CNT->end_of_count(end_of_count);
	//CNT->count_done(count_done);
	
#ifdef RETRY_MODE_ENABLED
	CMD_BUF = new cd_cmd_buffer_l3("CMD_BUF");
	
	CMD_BUF->clk(clk);
	CMD_BUF->dataDword(lk_dword_cd);
	CMD_BUF->enCtl1(enCtl1);
	CMD_BUF->enCtl2(enCtl2);
	CMD_BUF->packet(ctlPacket0);
	CMD_BUF->error64Bits(error64Bits);
	CMD_BUF->resetx(resetx);
#endif	

	CMDWDATA_BUF = new cd_cmdwdata_buffer_l3("CMDWDATA_BUF");
	
	CMDWDATA_BUF->clk(clk);
	CMDWDATA_BUF->dataDword(lk_dword_cd);
	CMDWDATA_BUF->db_address_cd(db_address_cd);
	CMDWDATA_BUF->enCtl1(enCtlWdata1);
	CMDWDATA_BUF->enCtl2(enCtlWdata2);
#ifdef RETRY_MODE_ENABLED
	CMDWDATA_BUF->packet(ctlPacket1);
#else
	CMDWDATA_BUF->packet(cd_packet_ro);
#endif
	CMDWDATA_BUF->error64BitsCtlwData(error64BitsCtlwData);
	CMDWDATA_BUF->resetx(resetx);
	CMDWDATA_BUF->cd_data_pending_addr_ro(cd_data_pending_addr_ro);
	
#ifdef RETRY_MODE_ENABLED
	MUX = new cd_mux_l3("MUX");
	
	MUX->ctlPacket0(ctlPacket0);
	MUX->ctlPacket1(ctlPacket1);
	MUX->select(selCtlPckt);
	MUX->cd_packet_ro(cd_packet_ro);
#endif
	
	NOP_HANDLER = new cd_nop_handler_l3("NOP_HANDLER");
	
	NOP_HANDLER->clk(clk);
	NOP_HANDLER->resetx(resetx);
	NOP_HANDLER->lk_dword_cd(lk_dword_cd);
	NOP_HANDLER->setNopCnt(setNopCnt);
	NOP_HANDLER->cd_nopinfo_fc(cd_nopinfo_fc);
	NOP_HANDLER->cd_nop_received_fc(cd_nop_received_fc);
	NOP_HANDLER->send_nop_notification(send_nop_notification);	
#ifdef RETRY_MODE_ENABLED
	NOP_HANDLER->cd_nop_ack_value_fc(cd_nop_ack_value_fc);

	HISTORY = new cd_history_rx_l3("HISTORY");
	
	HISTORY->clk(clk);
	HISTORY->resetx(resetx);
	HISTORY->incrCnt(cd_available_ro);
	HISTORY->cd_rx_next_pkt_to_ack_fc(cd_rx_next_pkt_to_ack_fc);
	
	packet_crc_unit = new cd_packet_crc_l3("CRC");
	
	packet_crc_unit->clk(clk);
	packet_crc_unit->resetx(resetx);
	
	packet_crc_unit->lk_dword_cd(lk_dword_cd);
	packet_crc_unit->lk_hctl_cd(lk_hctl_cd);
	packet_crc_unit->lk_lctl_cd(lk_lctl_cd);
	
	packet_crc_unit->crc1_enable(crc1_enable);
	packet_crc_unit->crc2_enable(crc2_enable);
	packet_crc_unit->crc1_reset(crc1_reset);
	packet_crc_unit->crc2_reset(crc2_reset);
	packet_crc_unit->crc2_if_ctl(crc2_if_ctl);
	
	packet_crc_unit->crc1_good(crc1_good);
	packet_crc_unit->crc2_good(crc2_good);
	packet_crc_unit->crc1_stomped(crc1_stomped);
	packet_crc_unit->crc2_stomped(crc2_stomped);
#endif
}
	
#ifdef SYSTEMC_SIM
decoder_l2::~decoder_l2(){
	delete SM;
	delete CNT;
	delete CMDWDATA_BUF;
	delete NOP_HANDLER;
#ifdef RETRY_MODE_ENABLED
	delete CMD_BUF;
	delete MUX;
	delete HISTORY;
	delete packet_crc_unit;
#endif
}
#endif
	


#ifndef SYSTEMC_SIM
#include "../core_synth/synth_control_packet.cpp"
#endif

