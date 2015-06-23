// cd_state_machine_l3.cpp

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

#include "cd_state_machine_l3.h"

cd_state_machine_l3::cd_state_machine_l3(sc_module_name name) : sc_module(name)
{	
	SC_METHOD(getnextst);
	sensitive << dWordIn  
#ifdef RETRY_MODE_ENABLED
		<< csr_retry << crc1_good << crc2_good 
		<< crc1_stomped << crc2_stomped 
#endif
		<< lk_available_cd << lk_lctl_cd  << lk_hctl_cd  
		<< currentState	<< end_of_count;
	SC_METHOD(setstate);
	sensitive_neg << resetx;
	sensitive_pos << clk;

	SC_METHOD(stateoutputs);
	sensitive 
#ifdef RETRY_MODE_ENABLED
		<< crc1_good << crc2_good << crc1_stomped << crc2_stomped << csr_retry 
		<< sync_count << selCtlPckt
#endif
		<< lk_lctl_cd  << lk_hctl_cd  << currentState << dWordIn
		<< end_of_count<< lk_available_cd;

	SC_METHOD(output_packet_selection);
	sensitive << 
#ifdef RETRY_MODE_ENABLED
				csr_retry << 
#endif
				controlEnable << lk_lctl_cd << lk_available_cd <<
				controlDataEnable;

}

void cd_state_machine_l3::getnextst()
{
	//Decode the command of the dword at the input as if it
	//was a valid packet (it may also be data or CRC or second dword of packet)
	sc_bv<6> cmdBits;
	cmdBits = dWordIn.read().range(5,0);

	PacketCommand cmdIn =
		getPacketCommand(cmdBits);

	//Main state machine.  To better understand this state machine, it is recommended
	//to view the state diagram.  This part will determine the next state of the system
	//
	//Outputs of the state machine are in another seperate process
	switch (currentState) {
	case PRTCL_ERR_st:
	case PRTCL_ERR_CLR_DATA_st:
#ifdef RETRY_MODE_ENABLED
		if(csr_retry.read()){
			//If in retry mode, we attemp a disconnect and reconnect
			//to reinitialize the link
			nextState = SEND_DISC_st;
		}
		else
#endif
			//This is arbitrary, spec says the link goes to an inderteminate
			//state, we stay in here to not corrupt things further.  Only reset
			//can bring it out of here.
			nextState = PRTCL_ERR_st;
		break;
	case SYNC_st :
			//The only way to leave SYNC is through reset
			nextState = SYNC_st;
		break;

#ifdef RETRY_MODE_ENABLED
	case SEND_DISC_st :
			//Ok, this state is to start a disconnect NOP flood.  Once started, we let
			//the rest of the link do the reconnect sequence.
			nextState = CONTROL_st;
		break;
#endif

	//All other states are standard decode states.  They stay where they are unless
	//there is data at the FIFO input.
	default:

#ifdef RETRY_MODE_ENABLED
		//If link has initiated a disconnect, it is equivalent to having generated one
		//ourselves, so we go to control state and let the link do the reconnect sequence
		if(lk_initiate_retry_disconnect.read()){
			nextState = CONTROL_st;	
		}
		else 
#endif
		     if(lk_available_cd.read())
		{
			bool extended64BitPacketNotAllowed = false;
			
			switch (currentState) {
				
			case CONTROL_st: 
				if(	! (lk_hctl_cd == true && lk_lctl_cd == true)){
					nextState = PRTCL_ERR_st;			
				}
				else{
					switch (cmdIn) {
					case READ:
					case BROADCAST:
						nextState = ADD_st;
						break;
						
					case WRITE:
					case ATOMIC:
						nextState = ADD_WDATA_st;
						break;
						
					case RD_RESPONSE:
						nextState = DATA1_st;
						break;
						
					case FLUSH:
					case FENCE:
					case TGTDONE:
#ifdef RETRY_MODE_ENABLED
						if(csr_retry.read())
							nextState = CRC_st;
						else
#endif
							nextState = CONTROL_st;
						break;
						
					case NOP:
						if(dWordIn.read()[6] == true){
#ifdef RETRY_MODE_ENABLED
							if(csr_retry.read())
								nextState = PRTCL_ERR_st;
							else
#endif
								nextState = CONTROL_st;
						}
						else{
#ifdef RETRY_MODE_ENABLED
							if(csr_retry.read())
								nextState = CRC_NOP_st;
							else
#endif
								nextState = CONTROL_st;
						}
						break;
					case SYNC:
						nextState = SYNC_st;
						break;
						
					case EXTENDED_FLOW:
						if(dWordIn.read()[6] == 1)
							nextState = FC64_st;
#ifdef RETRY_MODE_ENABLED
						else if(csr_retry.read())
							nextState = CRC_EXTFC_st;
#endif
						else
							nextState = CONTROL_st;
						
						break;
						
					case ADDR_EXT :
						nextState = CONTROL_EXT_st;
						break;
						
					default:
						nextState = PRTCL_ERR_st;
					}//Switch on command
				}//else validating that the ctl value is correct
				break;
				
			case CONTROL_EXT_st:
				if(	! (lk_hctl_cd == true && lk_lctl_cd == true)){
					nextState = PRTCL_ERR_st;			
				}
				else{
					switch (cmdIn) {
					case READ:
					case BROADCAST:
						nextState = ADD_st;
						break;
						
					case WRITE:
					case ATOMIC:
						nextState = ADD_WDATA_st;
						break;
						
					default:
						nextState = PRTCL_ERR_st;
					}//Switch on command
				}//else validating that the ctl value is correct
				break;
				
			case ADD_st:
				if(	! (lk_hctl_cd == true && lk_lctl_cd == true)){
					nextState = PRTCL_ERR_st;			
				}
#ifdef RETRY_MODE_ENABLED
				else if (csr_retry.read())
					nextState = CRC_st;
#endif
				else
					nextState = CONTROL_st;
				break;

			case FC64_st:
				if(	! (lk_hctl_cd == true && lk_lctl_cd == true)){
					nextState = PRTCL_ERR_st;			
				}
#ifdef RETRY_MODE_ENABLED
				else if (csr_retry.read())
					nextState = CRC_EXTFC_st;
#endif
				else
					nextState = CONTROL_st;
				break; 
				
			case ADD_WDATA_st:
				if(	! (lk_hctl_cd == true && lk_lctl_cd == true)){
					nextState = PRTCL_ERR_st;			
				}
				else{
					nextState = DATA1_st;
				}
				break;
				
			case CONTROL_EXT2_st:
				extended64BitPacketNotAllowed = true;
				if(!(lk_hctl_cd == true && lk_lctl_cd == true) ) 
					nextState = PRTCL_ERR_CLR_DATA_st;
				else{
					switch(cmdIn){
					case READ:
					case BROADCAST:
						nextState = INS2_st;
						break;
					default:
						nextState = PRTCL_ERR_CLR_DATA_st;
					}
				}
				break;
			case DATA1_st:
				if(lk_hctl_cd == false && lk_lctl_cd == true ||
				   lk_hctl_cd == true && lk_lctl_cd == false){
					nextState = PRTCL_ERR_CLR_DATA_st;
				}
				else if(lk_hctl_cd == true && lk_lctl_cd == true ){
					switch(cmdIn){
					case READ:
					case BROADCAST:
						nextState = INS2_st;
						break;
					case NOP:
						if(dWordIn.read()[6] == true){
#ifdef RETRY_MODE_ENABLED
							if(csr_retry.read())
								nextState = PRTCL_ERR_CLR_DATA_st;
							else
#endif
								nextState = DATA1_st;
						}
#ifdef RETRY_MODE_ENABLED
						else if(csr_retry.read())
							nextState = DATA2_NOP_st;
#endif
						else
							nextState = DATA1_st;
						break;
					case EXTENDED_FLOW:
						if(dWordIn.read()[6] == 1){
							nextState = INS2_FC64_st;						
						}
						else{
#ifdef RETRY_MODE_ENABLED
							if(csr_retry.read()){
								nextState = DATA2_FC_st;						
							}else
#endif
								nextState = DATA1_st;						
						}
						break;
					case SYNC:
						nextState = SYNC_st;
						break;
					case ADDR_EXT:
						nextState = CONTROL_EXT2_st;
						break;
					case FLUSH:
					case FENCE:
					case TGTDONE:
#ifdef RETRY_MODE_ENABLED
						if(csr_retry.read())
							nextState = DATA2_st;
						else
#endif
						{
							nextState = DATA1_st;
						}
						break;
						
					default:
						nextState = PRTCL_ERR_CLR_DATA_st;
					}
				}
				else{
					if(end_of_count.read()){
#ifdef RETRY_MODE_ENABLED
						if(csr_retry.read()){
							nextState = DATACRC_st;
						}
						else
#endif
						{
							nextState = CONTROL_st;
						}
					}
					else{
						nextState = DATA1_st;
					}
				}
				break;
				
			case INS2_st:
				if(!(lk_hctl_cd == true && lk_lctl_cd == true)){
					nextState = PRTCL_ERR_CLR_DATA_st;
				}
#ifdef RETRY_MODE_ENABLED
				else if(csr_retry.read()){
					nextState = DATA2_st;					
				}
#endif
				else{
					nextState = DATA1_st;					
				}	
				break;
				
			case INS2_FC64_st:
				if(!(lk_hctl_cd == true && lk_lctl_cd == true)){
					nextState = PRTCL_ERR_CLR_DATA_st;
				}
#ifdef RETRY_MODE_ENABLED
				else if(csr_retry.read()){
					nextState = DATA2_FC_st;					
				}
#endif
				else{
					nextState = DATA1_st;					
				}	
				break;
				
#ifdef RETRY_MODE_ENABLED
			case CRC_st:
			case CRC_EXTFC_st:
			case CRC_NOP_st:
				if(	! (lk_hctl_cd == false && lk_lctl_cd == true && 
					(crc1_good == true || crc1_stomped == true))){
					nextState = PRTCL_ERR_st;			
				}
				else{
					nextState = CONTROL_st;
				}
				break;
			case DATACRC_st:
				if(	! (lk_hctl_cd == true && lk_lctl_cd == false && 
					(crc1_good == true || crc1_stomped == true))){
					nextState = PRTCL_ERR_st;			
				}
				else{
					nextState = CONTROL_st;
				}
				break;
			case DATA2_st:
			case DATA2_NOP_st:
			case DATA2_FC_st:
				if(lk_hctl_cd == false && lk_lctl_cd == true && 
					(crc2_good.read() || crc2_stomped.read()))
				{
					nextState = DATA1_st;
				}
				else{
					nextState = PRTCL_ERR_CLR_DATA_st;
				}
				break;
				
#endif				
				
			default:
				nextState = CONTROL_st;
			}	
		}
		else{
			nextState = currentState;
		}
	}
} // end method

void cd_state_machine_l3::setstate()
{

	// asynchronous reset

	if(!resetx.read())
	{
		currentState = CONTROL_st;
		controlDataEnable = false;
		cd_data_pending_ro = false;
		controlEnable = false;

#ifdef RETRY_MODE_ENABLED
		cd_initiate_retry_disconnect = false;
		sync_count = 0;
		crc2_if_ctl = false;
#endif
	}	
	else
	{
		currentState = nextState;
		cd_data_pending_ro = (cd_data_pending_ro_buf.read() ||
			(cd_data_pending_ro.read() && 
			!(lk_available_cd.read() && lk_lctl_cd.read()))) 
#ifdef RETRY_MODE_ENABLED
			&& !csr_retry.read()
#endif
			;

		/**
			controlEnable is not equivalent to cd_available_ro because in non retry
			mode, a packet must wait until another control packet is received
			before being commited, because of the possibility of a reset
			corrupting a packet in transmission
		*/

		//If a new packet was put in the control packet output register,
		//remember it
		if(next_controlEnable.read() && !nextSelCtlPckt.read()){
			controlEnable = true;
		}
		//If no new packet, stay with the same value or force 0 if it is sent out
		else{
			controlEnable = controlEnable.read() && 
				!(
#ifdef RETRY_MODE_ENABLED
				!selCtlPckt.read() &&
#endif
				cd_available_ro.read());
		}

		//If a new packet was put in the control packet with data output register,
		//remember it
		if(next_controlEnable.read()
			&& nextSelCtlPckt.read()
			){
			controlDataEnable = true;
		}
		//If no new packet, stay with the same value or force 0 if it is sent out
		else{
			controlDataEnable = controlDataEnable.read() && !(
#ifdef RETRY_MODE_ENABLED
				selCtlPckt.read() && 
#endif
				cd_available_ro.read());
		}

#ifdef RETRY_MODE_ENABLED
		cd_initiate_retry_disconnect = next_cd_initiate_retry_disconnect;
		sync_count = next_sync_count;
		crc2_if_ctl = nextState == 	DATA1_st ||
				nextState == INS2_st ||
				nextState == INS2_FC64_st ||
				nextState == CONTROL_EXT2_st;
#endif
	}

}



void cd_state_machine_l3::stateoutputs()
{

	sc_bv<6> cmdBits;
		cmdBits = dWordIn.read().range(5,0);

	PacketCommand cmdIn =
		getPacketCommand(cmdBits);

	//Default value of outputs

#ifdef RETRY_MODE_ENABLED
	//For CRC
	crc1_enable = false;
	crc2_enable = false;
	crc1_reset = false;
	crc2_reset = false;
#endif

#ifdef RETRY_MODE_ENABLED
	//For the non-data command buffer
	enCtl1 = false;
	enCtl2 = false;
	error64Bits = false;
#endif

	//For the data command buffer
	enCtlwData1 = false;
	enCtlwData2 = false;
	getAddressSetCnt = false;
	error64BitsCtlwData = false;

	//History
	//incrHistCnt = false; //same as next_controlEnable

	//For the data buffer
#ifdef RETRY_MODE_ENABLED
	cd_drop_db = false;
#endif
	cd_write_db = false;

	//For the command buffer
	next_controlEnable = false;
	//For the mux selection
	nextSelCtlPckt = false;


	//For the nopHandler
	setNopCnt = false;
	send_nop_notification = false;

	//For link and CSR
	cd_protocol_error_csr = false;
	cd_sync_detected_csr = false;
	cd_initiate_nonretry_disconnect_lk = false;

#ifdef RETRY_MODE_ENABLED
	next_cd_initiate_retry_disconnect = false;
	cd_received_stomped_csr = false;
	cd_received_non_flow_stomped_ro = false;
	next_sync_count = sync_count.read();
#endif

	cd_data_pending_ro_buf = false;

	/**
		Outputs for the states
	*/
	switch (currentState) {
		
	case CONTROL_EXT_st:
		if(lk_available_cd.read()){
#ifdef RETRY_MODE_ENABLED
			if(csr_retry.read())
				crc1_enable = true;
#endif
			if(cmdIn == WRITE || cmdIn == ATOMIC || cmdIn == RD_RESPONSE){
				error64BitsCtlwData = true;
				getAddressSetCnt = true;
				enCtlwData1 = true;
			}
			else /* if(cmdIn == READ || cmdIn == BROADCAST) commented to simplify logic */{
#ifdef RETRY_MODE_ENABLED
				enCtl1 = true;
				error64Bits = true;
#else
				enCtlwData1 = true;
				error64BitsCtlwData = true;
#endif
			}
		}
		break;

	case CONTROL_st:
		
		
		if(lk_available_cd.read()){
#ifdef RETRY_MODE_ENABLED
			if(csr_retry.read())
				crc1_enable = true;
#endif
		/*
		if the input command indicates that data will follow,
		obtain an address, set the data counter and enable 
		the appropriate register and MUX selection bit.
		If not, enable the other register.
			*/
			if(cmdIn == WRITE || cmdIn == ATOMIC || cmdIn == RD_RESPONSE)
			{
				getAddressSetCnt = true;
				enCtlwData1 = true;
			}
			if(cmdIn == FLUSH || cmdIn == FENCE || cmdIn == TGTDONE ||
				cmdIn == READ || cmdIn == BROADCAST)
			{
#ifdef RETRY_MODE_ENABLED
				enCtl1 = true;
#else
				enCtlwData1 = true;
#endif
			}
			
			if((cmdIn == FLUSH || cmdIn == FENCE || cmdIn == TGTDONE) 
#ifdef RETRY_MODE_ENABLED
				&& !csr_retry.read()
#endif
			){
				nextSelCtlPckt = false;
				next_controlEnable = true;
			}
			else if((cmdIn == RD_RESPONSE) 
#ifdef RETRY_MODE_ENABLED
				&& !csr_retry.read()
#endif
			){
				nextSelCtlPckt = true;
				next_controlEnable = true;
			}

			
			/* If the input command is a NOP, set the NOP count*/
			if(cmdIn == NOP){
				setNopCnt = true;
				cd_initiate_nonretry_disconnect_lk = (sc_bit)dWordIn.read()[6]
#ifdef RETRY_MODE_ENABLED
					&& !csr_retry.read();
#endif
					;

#ifdef RETRY_MODE_ENABLED
				next_cd_initiate_retry_disconnect = (sc_bit)dWordIn.read()[6] && csr_retry.read();

				if(csr_retry.read() == false)
#endif
					send_nop_notification = true;
			}
		}
		break; 
	
	case ADD_st:
		if(lk_available_cd.read()){
#ifdef RETRY_MODE_ENABLED
			enCtl2 = true;
			if(csr_retry.read())
				crc1_enable = true;
			else
			{	nextSelCtlPckt = false;
				next_controlEnable = true;
			}
#else
			nextSelCtlPckt = false;
			enCtlwData2 = true;
			next_controlEnable = true;
#endif
			
		}
		break; 
		
	case ADD_WDATA_st:
		if(lk_available_cd.read()){
			enCtlwData2 = true;
#ifdef RETRY_MODE_ENABLED
			if(csr_retry.read())
				crc1_enable = true;
			else
#endif
			{
				nextSelCtlPckt = true;
				next_controlEnable = true;
			}
		}
		break;
			
	case FC64_st:
#ifdef RETRY_MODE_ENABLED
		crc1_enable = lk_available_cd.read() && csr_retry.read();
#endif
		break;

		/*
		In this state, outputs will vary according to the value
		of LCTL and HCTL
		
		*/
	case CONTROL_EXT2_st:
		cd_data_pending_ro_buf	= true;
		
		if(lk_available_cd.read()){
#ifdef RETRY_MODE_ENABLED
			enCtl1 = true;
			error64Bits = true;
			if(csr_retry.read())
				crc2_enable = true;
#else
			enCtlwData1 = true;
			error64BitsCtlwData = true;
#endif
		}
		break;

	case DATA1_st:
		cd_data_pending_ro_buf	= true;
		
		if(lk_available_cd.read()){
			if(lk_lctl_cd.read() && lk_hctl_cd.read()){
#ifdef RETRY_MODE_ENABLED
				if(csr_retry.read())
					crc2_enable = true;
#endif
			
				if((cmdIn == FLUSH || cmdIn == FENCE || cmdIn == TGTDONE) 
#ifdef RETRY_MODE_ENABLED
					&& !csr_retry.read()
#endif
					)
				{
					nextSelCtlPckt = false;
					next_controlEnable = true;
				}
				
				if(cmdIn == FLUSH || cmdIn == FENCE || cmdIn == TGTDONE ||
					cmdIn == READ || cmdIn == BROADCAST)
				{
#ifdef RETRY_MODE_ENABLED
					enCtl1 = true;
#else
					enCtlwData1 = true;
#endif
				}
				
				if(cmdIn == NOP){
					setNopCnt = true;
#ifdef RETRY_MODE_ENABLED
					if(dWordIn.read()[6] == true){
						next_cd_initiate_retry_disconnect = true;
					}
					if(csr_retry.read() == false)
#endif
					{
						send_nop_notification = true;
						if(dWordIn.read()[6] == true){
							cd_initiate_nonretry_disconnect_lk = true;
						}
					}
				}
			}
			
			/*
			LCTL=0 and HCTL=0 corresponds to the reception of a data
			doubleword.  In this case, data transmission is enabled and
			the data count value is decreased upon each reception of
			a doubleword
			*/
			
			else if ( !lk_lctl_cd.read() && !lk_hctl_cd.read() )	//00
			{
				cd_write_db = true;
#ifdef RETRY_MODE_ENABLED
				if(csr_retry.read()){
					crc1_enable = true;
				}
#endif
			}
		}
		break; 

		/* In this state, we enable the second doubleword of inserted command
		to be registered */
	case INS2_st:
		cd_data_pending_ro_buf	= true;

		if(lk_available_cd.read()){
#ifdef RETRY_MODE_ENABLED
			enCtl2 = true;
			if(csr_retry.read())
				crc1_enable = true;
			else
			{
				nextSelCtlPckt = false;
				next_controlEnable = true;
			}
#else
			nextSelCtlPckt = false;
			enCtlwData2 = true;
			next_controlEnable = true;

#endif

		}
		break;

	case INS2_FC64_st:
		cd_data_pending_ro_buf	= true;

#ifdef RETRY_MODE_ENABLED
		crc2_enable = lk_available_cd.read() && csr_retry.read();
#endif
		break;

#ifdef RETRY_MODE_ENABLED
		/*
		State to be used when retry mode is implemented
		*/
	case CRC_st:
		if(lk_available_cd.read()){
			crc1_reset = true;
			if(lk_lctl_cd.read() && !lk_hctl_cd.read()){
				nextSelCtlPckt = false;
				if(crc1_good.read()){
					next_controlEnable = true;
				}
				else if(crc1_stomped.read()){
					cd_received_stomped_csr = true;
					cd_received_non_flow_stomped_ro = true;
				}
			}
		}
		break;

	case DATACRC_st:
		if(lk_available_cd.read()){
			crc1_reset = true;
			if(!lk_lctl_cd.read() && lk_hctl_cd.read()){
				nextSelCtlPckt = true;
				if(crc1_good.read()){
					next_controlEnable = true;
				}
				else if(crc1_stomped.read()){
					cd_received_stomped_csr = true;
					cd_received_non_flow_stomped_ro = true;
				}
			}
		}
		break;

	case CRC_NOP_st:
		if(lk_available_cd.read()){
			crc1_reset = true;
			if(lk_lctl_cd.read() && !lk_hctl_cd.read()){
				if(crc1_good.read()){
					send_nop_notification = true;
				}
				else if(crc1_stomped.read()){
					cd_received_stomped_csr = true;
				}
			}
		}
		break;

	case CRC_EXTFC_st:
		if(lk_available_cd.read()){
			crc1_reset = true;
			if(lk_lctl_cd.read() && !lk_hctl_cd.read() && crc1_stomped.read()){
				cd_received_stomped_csr = true;
			}
		}
		break;
	case DATA2_st:
		
		if(lk_lctl_cd.read() && !lk_hctl_cd.read() )
		{
			crc2_reset = true;
			next_controlEnable = true;
			if(crc2_good.read()){
				nextSelCtlPckt = false;
			}
			else if(crc2_stomped.read()){
				cd_received_stomped_csr = true;
				cd_received_non_flow_stomped_ro = true;
			}
		}
		break;
		
	case DATA2_NOP_st:
		
		if(lk_lctl_cd.read() && !lk_hctl_cd.read() )
		{
			crc2_reset = true;
			if(crc2_good.read()){
				send_nop_notification = true;
			}
			else if(crc2_stomped.read()){
				cd_received_stomped_csr = true;
			}
		}
		break;

	case DATA2_FC_st:
		
		if(lk_lctl_cd.read() && !lk_hctl_cd.read() )
		{
			crc2_reset = true;

			if(crc2_stomped.read()){
				cd_received_stomped_csr = true;
			}
		}
		break;

	case SEND_DISC_st :
		//Ok, this state is to start a disconnect NOP flood.  Once started, we let
		//the rest of the link do the reconnect sequence.
		break;
#endif

	case PRTCL_ERR_st:
#ifdef RETRY_MODE_ENABLED
		crc1_reset = true;
		crc2_reset = true;
		if(csr_retry.read()) next_cd_initiate_retry_disconnect = true;
		else
#endif
			//If in retry mode, we attemp a disconnect and reconnect
			//to reinitialize the link
			cd_protocol_error_csr = true;
		break;
	case PRTCL_ERR_CLR_DATA_st:
#ifdef RETRY_MODE_ENABLED
		cd_drop_db = true;
		crc1_reset = true;
		crc2_reset = true;
		if(csr_retry.read()) next_cd_initiate_retry_disconnect = true;
		else
#endif
			//If in retry mode, we attemp a disconnect and reconnect
			//to reinitialize the link
			cd_protocol_error_csr = true;
		break;
	case SYNC_st :
		//The only way to leave SYNC is through reset
#ifdef RETRY_MODE_ENABLED
		{
			sc_bv<6> sync_command = "111111";
			if(!sync_count.read()[2]){
				if(lk_available_cd.read()){
					if(csr_retry.read() && dWordIn.read().range(5,0) == sync_command)
						next_sync_count = sync_count.read() + 1;
					else
						next_sync_count = 0;
				}
			}
		}

		if(!csr_retry.read() || sync_count.read()[2])
#endif
		{
			cd_sync_detected_csr = true;
		}

		break;

	default:
		//Do nothing
		break;

	} // end of switch loop


}	//end of setOutputs process

void cd_state_machine_l3::output_packet_selection(){
	cd_available_ro = false;
#ifdef RETRY_MODE_ENABLED
	selCtlPckt = false;

	if(csr_retry.read()){
		cd_available_ro = controlEnable.read() || controlDataEnable.read();
		selCtlPckt = controlDataEnable.read();
	}
	else
#endif
	{
		/** Data packets cannot wait for next command packet because of
			ordering rules.  Corruption in case of reset is prevented
			by the command buffers holding the packet because of the
			data pending signal.
		*/
		if(controlDataEnable.read()){
			cd_available_ro = true;
#ifdef RETRY_MODE_ENABLED
			selCtlPckt = true;
#endif
		}
		/** For non data packets, we must wait for another packet to arrive
			before commiting the packet, to prevent corruption if the next
			node receives reset signal before us
		*/
		else if(controlEnable.read() && lk_lctl_cd.read() && lk_available_cd.read()){
			cd_available_ro = true;
#ifdef RETRY_MODE_ENABLED
			selCtlPckt = false;
#endif
		}
	}
}



#ifndef SYSTEMC_SIM
#include "../core_synth/synth_control_packet.cpp"
#endif



