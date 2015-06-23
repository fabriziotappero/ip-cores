To test the FPU core, do the following:

1)	Build timesoftfloat.exe for your specific platform(read instructions in folder SoftFloat for howto do that). 
	Before you do that, try the already included file.
	
2)	Create the testcases by running maketest.bat in folder test_bench. Default value is 100000 cases for each 
	arithmetic operation and for each rounding mode. This comes up to 2 million test cases. 

3) 	run fpusim.bat to simulate and test the FPU core using modelsim.