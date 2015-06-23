This is readme.txt file for directory hibi_v3
(heterogeneous IP Block interconnection version 3)



Purpose: Interconnect resources (CPU, mem, accelerator) in a
	 System-on-chip.


Sub-directories:
doc		- Documentation
ip-xact		- Component metadata in IP-XACT format
vhd 		- Vhdl source codes
tb		- Testbenches
		  basic_test - example of how to use
		  sad_test   - more complete testing using SystemC (*)
		  	     

sad= 'simultaneous addr and data'. This is a new feature in HIBI v.3
compared to HIBI v.2. Most verification suites are unable to test
transmitting them in parallel.


---------------------
Erno Salminen 2011-10-03
