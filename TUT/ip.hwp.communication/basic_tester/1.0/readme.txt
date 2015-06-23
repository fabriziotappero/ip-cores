-----------------------
Basic tester component
-----------------------

Purpose: Send and receive simple test data to/from HIBI.
	 It is easy to create basic tests for new HIBI-compliant IP component,
	 e.g. writing and reading a couple registers.

Structure:
	Two components: tx and rx, both using the same
	pkg that defines procedure for reading traffic file.

	Example testbench instantiates tx, rx, and two HIBI (r4) wrappers.


	file --> basic_tester_tx --> hibi2_r4
 	     	 		       |
				       |
				       v	
	file --> basic_tester_rx <-- hibi2_r4
	     	      |
		      |
		      V
		      "Error msg if something went wrong"			       


Usage:
	Go to directory sim.

	Define env variable TMP_DIR
	so that it points to some temporary dir where the compiled
	stuff will be located, e.g. $PWD or /tmp/<username> or similar.
	
	Create VHDL work lib and compile all files by executing:
	./create_makefile 

	Start simulation: 
	vsim tb_basic_tester -novopt -do tb_basic_tester.do

	Traffic examples take only about 600 ns to execute. 
	There will be 3 messagtes after statup
	1) tx reaches the end of its config file
	2) rx detects the intentional data corruption for the last data word
	3) rx reaches the end of its config file

	In addition to violated assertions, rx unit will have internal 
	signal "error_r" that will go upon an error condition.
	However, this might get optimized away if you don't use 
	the flag "-novopt".

Configuration:
	Traffic is configured with ASCII text files that are
	located into same directory where ModelSim is launched
	("sim" in this case). They look pretty much the same
	for both tx and rx.

	There is one line for each transfer.

	Files can have comments (#) and empty lines

	Each transfer has up to 4 parameter:
	delay_in_cycles dst_addr data_value command

	Parameters are separated with space or tab.
	Delay is 4 hexadecimal characters, addr and data 8 char each,
	and command 2 hex characters. Read procedure will
	discard the line if it cannot interpret the line, e.g. if
	there is only "5" and not "0005" for the delay. 

	Command can be omitted and then default write will be used.

	Address 0...0 means that tx does not send a new address,
	whereas  rx assumes that addr does not change:
	a) it receives the same addr as on prev transfers,
	b) or it does not receive addr at all but new data.

	Value F..F  on rx side means that rx don't care about 
	that value. However, it still checks the other parameters.
	E.g. any incoming addr will match but the data will be checked.


Checked cases in rx:

	Next transfer arrives within "delay" clock cycles" after reading the conf file.
	Addr matches the specified value
	Addr does not change
	Data matches
	Command matches
	Some combination of addr/data/cmd matches
	If more data arrives than expected 


Testing your own IP
	For example, send few commands with basic_tester_tx 
        and configure rx according to expected responses.
	
	file --> basic_tester_tx --> hibi2_r4
	file --> basic_tester_rx <-- wrapper
	     	 		       ^
				       |
				       v	
                                    hibi2_r4 --> your IP 
				    wrapper <--	 is here    	      |


---

Erno Salminen, TUT
2010-10-08
