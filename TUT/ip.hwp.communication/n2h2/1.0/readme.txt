-------------------------------------------------------------
This is readme for compoenent Nios-to-HIBI-version2 aka. N2H2
-------------------------------------------------------------

Purpose : N2H2 connects Nios II CPU to HIBI network and acts as s DMA controller.



Main idea: 
	N2H2 can copy data from Nios's local memory to   HIBI.
	N2H2 can copy data to   Nios's local memory from HIBI.

	SW running on Nios controls N2H2 via a couple of memory-mapped registers.
	Each transfers needs at least 3 parameters: 
		1. address in local memory
		2. address in HIBI
		3. number or transferred words

Directory structure: 

	doc/			Brief documentation
	drv/			SW driver functions
	readme.txt		This file
	tb/			Testbenches for VHDL description and a 3 CPU 
				system.
	vhd/			RTL source codes



History:
	Original design by Ari Kulmala, 2005

	Modified by Lasse Lehtonen, 2011:
	
	Added ability to receive packets that haven't been configured
	before the packet arrives. Also added interrupt to detect lost
	tx packets (may happen when sending "second" packet too soon
	without polling for the completeon of the previous packet).

	Use the TCL file in vhd/ to add the component to SOPC.
