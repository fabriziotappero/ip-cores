gcc -std=c99 -Wall -O2 -c fpga_com.c 
g++ -Wall -O2 -o testcase1 testcase1.cpp background_reader.cpp fpga_com.o -lboost_thread
