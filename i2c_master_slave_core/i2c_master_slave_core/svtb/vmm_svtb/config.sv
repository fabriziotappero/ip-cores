//////////////////////////////////////////////////////////////////////////////////////////
//																						//
//	Verification Engineer:	Atish Jaiswal												//
//	Company Name		 :	TooMuch Semiconductor Solutions Pvt Ltd.					//
//																						//
//  Description of the Source File:														//
//	This source code is used to configure the test-case.								//
//	This class randmomize the no. of transactions.								  		//
//																						//
//																						//
//////////////////////////////////////////////////////////////////////////////////////////

`include "vmm.sv"

class configuration;

	rand int transaction_count; 	// No. of transaction to be done

	function new();
	endfunction

	constraint valid {
        transaction_count inside {[0:44]};
	}

endclass

