This is a simple Bare C Ethernet speed test.

It transmits 2^20 raw Ethernet packets with 1500 bytes payload 
(i.e. 1500 Mbytes of data) and calculates the time and bitrate used.

Note that no upper layer protocol or any flow control is used.

Destination and source MAC addresses as well as the APB address of
the GRETH are specified through #define's in greth.c. 
