//databuffer_l2.cpp

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
 *   Martin Corriveau
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

#include "databuffer_l2.h"


databuffer_l2::databuffer_l2( sc_module_name name ) :
	sc_module(name){
	SC_METHOD(clockProcess);
	sensitive_neg << resetx;
	sensitive_pos << clk;

	SC_METHOD(sendAddressToCommandDecoder);
	sensitive << cd_vctype_db << firstFreeBuffer[0] << firstFreeBuffer[1] << firstFreeBuffer[2];

	SC_METHOD(write_memory);
	sensitive << cd_write_db << currentWriteVC << currentWriteBuffer << nbWritesInBufferDone
		<< cd_data_db;

	SC_METHOD(read_memory);
	sensitive << csr_read_db << ui_read_db << fwd_read_db
		<< csr_vctype_db << ui_vctype_db << fwd_vctype_db
		<< csr_address_db << ui_address_db << fwd_address_db
		<< currentReadVc[0] << currentReadVc[1]
		<< currentReadAddress[0] << currentReadAddress[1]
		<< nbReadsInBufferDone[0] << nbReadsInBufferDone[1]
		<< currentlyReading[0] << currentlyReading[1]
		<< ui_grant_csr_access_db;

	SC_METHOD(redirect_memory_output);
	sensitive << memory_output[0] << memory_output[1];
	
}

///Synchronous process, contains most of the functionality
void databuffer_l2::clockProcess(){

	if(resetx.read() == false){
		doReset();
	}
	else{
		//----------------
		//Write in memory
		//----------------

		//-------------------------------------------
		//Find new value of nbWritesInBufferDone
		//-------------------------------------------

		//If we are starting a new data packet, reset the number of writes done
		if(cd_getaddr_db.read() == true){
			nbWritesInBufferDone = 0;
		}
		//If we are receiving a data dword from CD, increment the number of writes done
		else if(cd_write_db.read()){
			nbWritesInBufferDone = nbWritesInBufferDone.read() + 1;
		}

		//------------------------------------
		//Find new value of currentWriteBuffer
		//------------------------------------
		
		//New data packet
		if(cd_getaddr_db.read() == true){
			//The new buffer is first buffer that is free
			currentWriteBuffer = firstFreeBuffer[cd_vctype_db.read()].read();
			currentWriteVC = cd_vctype_db.read();
		}

		//-----------------------------
		// Read operation done in own process
		//-----------------------------
	
		/** Start by putting all the input port signals
		in an array format so it can be used easily
		in a for loop.
		*/
		bool inputRead[2];
		if(ui_grant_csr_access_db.read())
			inputRead[ACCEPTED_PORT] = csr_read_db.read();
		else
			inputRead[ACCEPTED_PORT] = ui_read_db.read();
		inputRead[FWD_PORT] = fwd_read_db.read();
		
		VirtualChannel inputReadVC[2];
		if(ui_grant_csr_access_db.read())
			inputReadVC[ACCEPTED_PORT] = csr_vctype_db.read();
		else
			inputReadVC[ACCEPTED_PORT] = ui_vctype_db.read();
		inputReadVC[FWD_PORT] = fwd_vctype_db.read();
		
		sc_uint<BUFFERS_ADDRESS_WIDTH> inputReadAddress[2];
		if(ui_grant_csr_access_db.read())
			inputReadAddress[ACCEPTED_PORT] = csr_address_db.read();
		else
			inputReadAddress[ACCEPTED_PORT] = ui_address_db.read();
		inputReadAddress[FWD_PORT] = fwd_address_db.read();
		
		///If the buffer being outputed should be cleared
		bool clearBuffer[2];
		if(ui_grant_csr_access_db.read())
			clearBuffer[ACCEPTED_PORT] = csr_erase_db.read();
		else
			clearBuffer[ACCEPTED_PORT] = ui_erase_db.read();
		clearBuffer[FWD_PORT] = fwd_erase_db.read();
		
		
		/**
			Manage reading buffers for both read ports (accepted and forward)
			Find the next read state, read address, read VC and read count
		*/
		for(unsigned n = 0; n < 2; n++){
			
			sc_uint<2> currentReadVcIndex = currentReadVc[n];
			
			//If erasing a buffer, stop reading
			if(clearBuffer[n]){
				currentlyReading[n] = false;
				nbReadsInBufferDone[n] = 0;
			}
			else if(inputRead[n] == true){
				nbReadsInBufferDone[n] = nbReadsInBufferDone[n].read() + 1;
				//If not reading, activate reading state
				if(currentlyReading[n].read() == false){
					currentlyReading[n] = true;
				}
				
			}
			//If not currently reading, still store what buffer we are outputing
			if(currentlyReading[n].read() == false){
				currentReadVc[n] = inputReadVC[n];
				currentReadAddress[n] = inputReadAddress[n];
			}
		}

		//********************************
		//Buffer management
		//
		// Set if a buffer is free
		// Set the nextDataBuffer
		//********************************

		//Go through every buffer
		for(unsigned vc = 0; vc < 3; vc++){
			for(unsigned buffer = 0; buffer < DATABUFFER_NB_BUFFERS;buffer++){

#ifdef RETRY_MODE_ENABLED
				//Is it part of a packet dropped from the CD?
				bool drop_from_cd =currentWriteBuffer.read() == buffer &&
					currentWriteVC.read() == vc && cd_drop_db.read();
#endif

				//Is it erase by EH
				bool erase_from_eh = eh_address_db.read() == buffer &&
					eh_vctype_db.read() == vc && eh_erase_db.read();

				//Is it erase by Accepted port
				bool erase_from_accepted = inputReadAddress[ACCEPTED_PORT] == buffer &&
					inputReadVC[ACCEPTED_PORT] == vc && clearBuffer[ACCEPTED_PORT];

				//Is it erase by Forward port
				bool erase_from_forward = fwd_address_db.read() == buffer &&
					fwd_vctype_db.read() == vc && fwd_erase_db.read();

				//If we are starting to write in this buffer, tag is as not free
				if(cd_getaddr_db.read() && 
					vc == cd_vctype_db.read() && 
					buffer == firstFreeBuffer[cd_vctype_db.read()].read())
				{
					bufferFree[vc][buffer] = false;
				}
				//If the buffer is either part of a dropped packet or we are finished reading it's
				//data. mark it as free
				else if(erase_from_eh || erase_from_accepted || erase_from_forward
#ifdef RETRY_MODE_ENABLED
					 ||	drop_from_cd
#endif
				){
					bufferFree[vc][buffer] = true;
				}
				//else stay the same
			}
		}



		/**
			This finds the new value for firstFreeBuffer
			At the same time, it finds if the VC is full, which the only purpose
			is to generate an overflow error if necessary

			The "firstFreeBuffer" is used to know were the next data packet will
			start to be written.
		*/
		bool full[3] = {false,false,false};
		for(unsigned vc = 0; vc < 3; vc++){
			//Create a vector that contains buffer that are free
			sc_bv<DATABUFFER_NB_BUFFERS> vector_to_encode;
			for(unsigned n = 0; n < DATABUFFER_NB_BUFFERS; n++){
				vector_to_encode[n] = bufferFree[vc][n].read();
			}
			
			//Encode it to find the firt buffer that is free
			bool found = true;
			firstFreeBuffer[vc] = priority_encoder(vector_to_encode,found);

			//Log if the buffer is full
			if(!found){
				full[vc] = true;
			}
		}

		//Generate overflow if necessary
		if(	full[cd_vctype_db.read()] && cd_getaddr_db.read() == true){
			db_overflow_csr = true;
		}
		else{
			db_overflow_csr = false;
		}

		//Find the new bufferCount
		//The bufferCountWithNop is useful for the next block where we calculate how
		//many buffers to notify as freed with a nop
		sc_uint<DATABUFFER_LOG2_NB_BUFFERS+1> bufferCountWithNop[3];
        sc_uint<DATABUFFER_LOG2_NB_BUFFERS+1> bufferCountWithoutNop[3];

		//For every VC
		for(unsigned vc = 0; vc < 3 ; vc++){
			//By default, keep the same count
			sc_uint<DATABUFFER_LOG2_NB_BUFFERS+1> newBufferCount = bufferCount[vc].read();

			//If a nop was sent, add to the count what was sent on the nop
			sc_uint<2> buffer_freed_nop = getBufferFreedNop(vc);

			bufferCountWithNop[vc] = bufferCount[vc].read()+buffer_freed_nop;
			bufferCountWithoutNop[vc] = bufferCount[vc].read();

			//When receiving a new packet, buffer count is decreased
			if(cd_getaddr_db.read() == true && vc == cd_vctype_db.read()){
				newBufferCount--;
			}

			if(fc_nop_sent.read()){
				newBufferCount += buffer_freed_nop;
			}

#ifdef RETRY_MODE_ENABLED
			//In retry mode, when the retry sequence is initiated, buffer count is reset
			if(lk_initiate_retry_disconnect.read() || cd_initiate_retry_disconnect.read() ||
				(csr_retry.read() && !ldtstopx.read())){
				bufferCount[vc] = 0;
			}
			else
#endif
			{
				bufferCount[vc] = newBufferCount;
			}
		}

		//Find the new number of free buffers
		sc_uint<DATABUFFER_LOG2_NB_BUFFERS + 1> buffersThatCanBeFreedWithNop[3];
		sc_uint<DATABUFFER_LOG2_NB_BUFFERS + 1> buffersThatCanBeFreedWithoutNop[3];

		for(unsigned vc = 0; vc < 3; vc++){
			//Reduce the number of free buffers everytime a new buffers is requested
			//from CD
			sc_uint<1> substract_one;
			substract_one[0] = cd_getaddr_db.read() && cd_vctype_db.read() == vc;
	
			//Add the number of buffers that are dropped or erased
			sc_uint<1> add_eh,add_accepted,add_forward;
#ifdef RETRY_MODE_ENABLED
			sc_uint<1> add_cd;
			add_cd[0] = cd_drop_db.read() && currentWriteVC.read() == vc;
#endif
			add_eh[0] = eh_erase_db.read() && eh_vctype_db.read() == vc;
			add_accepted[0] = inputReadVC[ACCEPTED_PORT] == vc && clearBuffer[ACCEPTED_PORT];
			add_forward[0] = fwd_erase_db.read() && fwd_vctype_db.read() == vc ;

			//add_forward and add_uicomes in very late, so use it as a mux select 
			//instead of inside the adder
			sc_uint<2> free_buffer_case_selector;
			free_buffer_case_selector[0] = (sc_bit)add_forward[0];
			free_buffer_case_selector[1] = (sc_bit)add_accepted[0];

#ifdef RETRY_MODE_ENABLED
			switch(free_buffer_case_selector){//synopsys infer_mux
			case 3:
				freeBuffers[vc] = freeBuffers[vc].read() + (add_cd + add_eh) - substract_one + 2;
				break;
			case 2:
			case 1:
				freeBuffers[vc] = freeBuffers[vc].read() + (add_cd + add_eh) - substract_one + 1;
				break;
			default:
				freeBuffers[vc] = freeBuffers[vc].read() + (add_cd + add_eh) - substract_one;
			}
#else
			switch(free_buffer_case_selector){//synopsys infer_mux
			case 3:
				freeBuffers[vc] = (freeBuffers[vc].read() + add_eh) - substract_one + 2;
				break;
			case 2:
			case 1:
				freeBuffers[vc] = (freeBuffers[vc].read() + add_eh) - substract_one + 1;
				break;
			default:
				freeBuffers[vc] = (freeBuffers[vc].read() + add_eh) - substract_one;
			}
#endif

			buffersThatCanBeFreedWithNop[vc] = freeBuffers[vc].read() - bufferCountWithNop[vc];
			buffersThatCanBeFreedWithoutNop[vc] = freeBuffers[vc].read() - bufferCountWithoutNop[vc];

		}

		//Finally, output the nop request.  
		if(nopRequested.read())
			outputNopRequest(buffersThatCanBeFreedWithNop[2],buffersThatCanBeFreedWithNop[1],
				buffersThatCanBeFreedWithNop[0],freeBuffers[2],freeBuffers[1],freeBuffers[0]);
		else
			outputNopRequest(buffersThatCanBeFreedWithoutNop[2],buffersThatCanBeFreedWithoutNop[1],
				buffersThatCanBeFreedWithoutNop[0],freeBuffers[2],freeBuffers[1],freeBuffers[0]);

		sc_bv<6> bufferFreedNopBufWithNop;
		bufferFreedNopBufWithNop.range(1,0) = buffersThatCanBeFreedWithNop[VC_POSTED] <= 3 ? buffersThatCanBeFreedWithNop[VC_POSTED].range(1,0) : sc_uint<2>(3);
		bufferFreedNopBufWithNop.range(5,4) = buffersThatCanBeFreedWithNop[VC_NON_POSTED] <= 3 ? buffersThatCanBeFreedWithNop[VC_NON_POSTED].range(1,0) : sc_uint<2>(3);
		bufferFreedNopBufWithNop.range(3,2) = buffersThatCanBeFreedWithNop[VC_RESPONSE] <= 3 ? buffersThatCanBeFreedWithNop[VC_RESPONSE].range(1,0) : sc_uint<2>(3);
		
		sc_bv<6> bufferFreedNopBufWithoutNop;
		bufferFreedNopBufWithoutNop.range(1,0) = buffersThatCanBeFreedWithoutNop[VC_POSTED] <= 3 ? buffersThatCanBeFreedWithoutNop[VC_POSTED].range(1,0) : sc_uint<2>(3);
		bufferFreedNopBufWithoutNop.range(5,4) = buffersThatCanBeFreedWithoutNop[VC_NON_POSTED] <= 3 ? buffersThatCanBeFreedWithoutNop[VC_NON_POSTED].range(1,0) : sc_uint<2>(3);
		bufferFreedNopBufWithoutNop.range(3,2) = buffersThatCanBeFreedWithoutNop[VC_RESPONSE] <= 3 ? buffersThatCanBeFreedWithoutNop[VC_RESPONSE].range(1,0) : sc_uint<2>(3);

		if(fc_nop_sent.read()){
			db_buffer_cnt_fc = bufferFreedNopBufWithNop;
		}
		else{
			db_buffer_cnt_fc = bufferFreedNopBufWithoutNop;
		}
	}
}

void databuffer_l2::write_memory(){
	memory_write = cd_write_db;
	memory_write_address_vc = currentWriteVC;
	memory_write_address_buffer = currentWriteBuffer.read();
	memory_write_address_pos = nbWritesInBufferDone.read();
	memory_write_data = cd_data_db.read();
}

void databuffer_l2::read_memory(){
	//-----------------------------
	// Read operation
	//-----------------------------
	
	/** Start by putting all the input port signals
	in an array format so it can be used easily
	in a for loop.
	*/
	bool inputRead[2];
	if(ui_grant_csr_access_db.read())
		inputRead[ACCEPTED_PORT] = csr_read_db.read();
	else
		inputRead[ACCEPTED_PORT] = ui_read_db.read();
	inputRead[FWD_PORT] = fwd_read_db.read();
	
	VirtualChannel inputReadVC[2];
	if(ui_grant_csr_access_db.read())
		inputReadVC[ACCEPTED_PORT] = csr_vctype_db.read();
	else
		inputReadVC[ACCEPTED_PORT] = ui_vctype_db.read();
	inputReadVC[FWD_PORT] = fwd_vctype_db.read();
	
	sc_uint<BUFFERS_ADDRESS_WIDTH> inputReadAddress[2];
	if(ui_grant_csr_access_db.read())
		inputReadAddress[ACCEPTED_PORT] = csr_address_db.read();
	else
		inputReadAddress[ACCEPTED_PORT] = ui_address_db.read();
	inputReadAddress[FWD_PORT] = fwd_address_db.read();
	
	//Virtual channel that we will be outputed
	sc_uint<2> outputReadVcIndex[2];
	//Virtual buffer that we will be outputed
	sc_uint<BUFFERS_ADDRESS_WIDTH> outputReadAddress[2];
	
	//------------------------
	//For every read port
	//------------------------
	
	for(unsigned n = 0; n < 2; n++){
		
		sc_uint<2> currentReadVcIndex = currentReadVc[n];
		sc_uint<2> inputReadVcIndex = inputReadVC[n];
		
		//Position in buffer that we will be outputed
		/** This variable goes with outputReadVcIndex and outputReadAddress
		but is not declared at the same location simply because this
		variable will not be needed after the for loop
		*/
		sc_uint<4> outputPosInBuffer;
		

		/** In software simulation, if we exceed pointer, it will do an Access violation,
		but in hardware, we don't want to add the logic to prevent this from hapening since
		it has no effect*/
#ifdef SYSTEMC_SIM
		if(currentReadVcIndex == VC_NONE) currentReadVcIndex = 0;
#endif	
		
		//Find what is going to be output
		sc_uint<2> output_sel;
		output_sel[1] = inputRead[n];
		output_sel[0] = currentlyReading[n].read();
		switch(output_sel){
		/**
		If we are reading at the input and are currently in reading mode, just go
		to the next data dword
		*/
		case 3:
		{
			outputPosInBuffer = nbReadsInBufferDone[n].read() + 1;
			outputReadAddress[n] = currentReadAddress[n].read();
			outputReadVcIndex[n] = currentReadVcIndex;
		}
		break;
		/**
		If we get a read message for the first time, it means that the first dword
		has already been read and we are expected to output the next data, hence
		why we output 1 instead of 0.
		*/
		case 2:
		{
			outputPosInBuffer = 1;
			outputReadAddress[n] = currentReadAddress[n].read();
			outputReadVcIndex[n] = currentReadVcIndex;
		}
		break;
		/**
		A simple pos in the reading
		*/
		case 1:
			outputPosInBuffer = nbReadsInBufferDone[n].read();
			outputReadAddress[n] = currentReadAddress[n].read();
			outputReadVcIndex[n] = currentReadVcIndex;
			break;
		/**
		We're not currently reading yet, so simply output the first dword
		of the VC and address that we receive at the inputs.
		*/
		//case 0:
		default:
			outputReadVcIndex[n] = inputReadVcIndex;
			outputReadAddress[n] = inputReadAddress[n];
			outputPosInBuffer = 0;
		}
		
		memory_read_address_vc[n] = outputReadVcIndex[n];
		memory_read_address_buffer[n] = outputReadAddress[n];
		memory_read_address_pos[n] = outputPosInBuffer;
		
		//Store in signal for use in the sychronous method
		outputReadVcIndex_s[n] = outputReadVcIndex[n];
		outputReadAddress_s[n] = outputReadAddress[n];
	}
		
}

void databuffer_l2::redirect_memory_output(){
	db_data_accepted.write(memory_output[ACCEPTED_PORT]);
	db_data_fwd.write(memory_output[FWD_PORT]);
}


//see .h for description
void databuffer_l2::sendAddressToCommandDecoder(){
	switch(cd_vctype_db.read()){
	case VC_POSTED :
		db_address_cd.write(firstFreeBuffer[0].read());
		break;
	case VC_NON_POSTED :
		db_address_cd.write(firstFreeBuffer[1].read());
		break;
	//case VC_RESPONSE :
	default :
		db_address_cd.write(firstFreeBuffer[2].read());
		break;
	}	
}


//see .h for description
sc_uint<2> databuffer_l2::getBufferFreedNop(const VirtualChannel &vc){
	sc_uint<2> tmp;
	switch(vc){
	case VC_POSTED :
		tmp = sc_bv<2>(db_buffer_cnt_fc.read().range(1,0));
		break;
	case VC_NON_POSTED :
		tmp = sc_bv<2>(db_buffer_cnt_fc.read().range(5,4));
		break;
	case VC_RESPONSE :
		tmp = sc_bv<2>(db_buffer_cnt_fc.read().range(3,2));
		break;
	default :
		tmp = 0;
	}
	return tmp;
}

//see .h for description
void databuffer_l2::outputNopRequest(
			const sc_uint<DATABUFFER_LOG2_NB_BUFFERS + 1> &buffersThatCanBeFreedWithNop_2,
			const sc_uint<DATABUFFER_LOG2_NB_BUFFERS + 1> &buffersThatCanBeFreedWithNop_1,
			const sc_uint<DATABUFFER_LOG2_NB_BUFFERS + 1> &buffersThatCanBeFreedWithNop_0,
			const sc_uint<DATABUFFER_LOG2_NB_BUFFERS + 1> &freeCount_2,
			const sc_uint<DATABUFFER_LOG2_NB_BUFFERS + 1> &freeCount_1,
			const sc_uint<DATABUFFER_LOG2_NB_BUFFERS + 1> &freeCount_0){

	//Put the parameters in arrays so it's easier to use it in a loop
	sc_uint<DATABUFFER_LOG2_NB_BUFFERS + 1> buffersThatCanBeFreedWithNop[3] = {
		buffersThatCanBeFreedWithNop_0,buffersThatCanBeFreedWithNop_1,buffersThatCanBeFreedWithNop_2};
	sc_uint<DATABUFFER_LOG2_NB_BUFFERS + 1> freeCount[3] = {freeCount_0,freeCount_1,freeCount_2};

	//If we decide to do a nop request
	bool doNopRequest = false;


	sc_bv<6> bufferFreedNopBuf;
	for(unsigned vc = 0; vc < 3; vc++){
		/** This next part is a simple algorithm so we that we don't monopolize the link by sending
			nops of buffers being freed.  It is strongly possible that this will need to be
			adjusted with profiling */

		//If we have a lot of buffers that are free, we can slack and only request a nop
		//when we have at least 3 buffers to free (the maximum a nop can carry)
		if(
			//If we have 3 or more buffers that can be freed with the hypothesis that a nop was
			//just sent, always request nop : if the flow control is currently sending a nop, 
			//it will see another request immediately
			(freeCount[vc] > 4 && buffersThatCanBeFreedWithNop[vc] >= 3) ||
			//Same principle, but if we have less buffers free, we get more aggressive about
			//requesting that a nop be sent!
			(freeCount[vc] <= 4 && buffersThatCanBeFreedWithNop[vc] >= 2 ) || 
			(freeBuffers[vc].read() <= 2 && buffersThatCanBeFreedWithNop[vc] != 0)
		)
			doNopRequest = true;
	}

	//Output the results

	db_nop_req_fc = doNopRequest;
	nopRequested = doNopRequest || (nopRequested.read() && !fc_nop_sent.read());


}

//see .h for description
void databuffer_l2::doReset(){
	for(int vc = 0; vc < 3 ; vc++){
		for(int n = 0; n < DATABUFFER_NB_BUFFERS; n++){
			bufferFree[vc][n] = true;
		}
		freeBuffers[vc] = DATABUFFER_NB_BUFFERS;
		firstFreeBuffer[vc] = 0;
		bufferCount[vc] = 0;
	}

	for(int port = 0; port < 2; port++){
		currentlyReading[port] = false;
		currentReadVc[port] = VC_NONE;
		currentReadAddress[port] = 0;
		nbReadsInBufferDone[port] = 0;
	}

	nbWritesInBufferDone = 0;
	currentWriteBuffer = 0;
	currentWriteVC = 0;

	nopRequested = false;
	db_nop_req_fc = false;

	db_buffer_cnt_fc = 0;

	db_overflow_csr = false;
}


sc_uint<DATABUFFER_LOG2_NB_BUFFERS> databuffer_l2::priority_encoder(
		sc_bv<DATABUFFER_NB_BUFFERS> to_encode,	bool &found)
{
	sc_bv<DATABUFFER_NB_BUFFERS> v = to_encode;
	sc_bv<DATABUFFER_LOG2_NB_BUFFERS> output;

	output = 0;
	for(int n = 0; n < DATABUFFER_NB_BUFFERS; n++){
		if((sc_bit)v[n]) output = n;
	}

	found = (sc_bit)v[0];
	for(int n = 0; n < DATABUFFER_LOG2_NB_BUFFERS; n++){
		 found =  found || (sc_bit)output[n];
	}

	return output;
}

#ifdef SYSTEMC_SIM
void sc_trace(	sc_trace_file *tf, const databuffer_l2& v,
			const sc_string& NAME )
{
	sc_trace(tf,v.clk, /*NAME +*/ ".clk");
	sc_trace(tf,v.fc_nop_sent, /*NAME +*/ ".fc_nop_sent");
	sc_trace(tf,v.db_buffer_cnt_fc, /*NAME +*/ ".db_buffer_cnt_fc");
	sc_trace(tf,v.db_nop_req_fc, /*NAME +*/ ".db_nop_req_fc");
	sc_trace(tf,v.cd_getaddr_db, /*NAME +*/ ".cd_getaddr_db");
	sc_trace(tf,v.cd_write_db, /*NAME +*/ ".cd_write_db");
	sc_trace(tf,v.cd_datalen_db, /*NAME +*/ ".cd_datalen_db");
	sc_trace(tf,v.db_address_cd, /*NAME +*/ ".db_address_cd");

	sc_trace(tf,v.eh_erase_db, /*NAME +*/ ".eh_erase_db");
#ifdef RETRY_MODE_ENABLED
	sc_trace(tf,v.cd_drop_db, /*NAME +*/ ".cd_drop_db");
#endif
	sc_trace(tf,v.csr_read_db, /*NAME +*/ ".csr_read_db");
	sc_trace(tf,v.ui_read_db, /*NAME +*/ ".ui_read_db");
	sc_trace(tf,v.fwd_read_db, /*NAME +*/ ".fwd_read_db");

	sc_trace(tf,v.nbWritesInBufferDone, /*NAME +*/ ".nbWritesInVirtBufferDone");

	sc_trace(tf,v.fwd_erase_db, /*NAME +*/ ".fwd_erase_db");
	sc_trace(tf,v.nbReadsInBufferDone[0], /*NAME +*/ ".nbReadsInVirtBufferDone[0]");
	sc_trace(tf,v.bufferFree[0][0], /*NAME +*/ ".bufferFree0");

	sc_trace(tf,v.cd_data_db, /*NAME +*/ ".cd_data_db");
	sc_trace(tf,v.db_data_fwd, /*NAME +*/ ".db_data_fwd");
	sc_trace(tf,v.db_data_accepted, /*NAME +*/ ".db_data_accepted");

	
	sc_trace(tf,v.bufferCount[0], /*NAME +*/ ".bufferCount(0)");

}
#endif
