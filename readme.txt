Cheap Ethernet interface

Realization of Ethernet interface and protocols optimized for minimal external components and FPGA resources.
FPGA may connecting through transformer or directly to twisted pairs (on your own risk).

Features
- 10BASE-TX interface (10 MBit/sec) full-duplex (thanks to fpga4fun.com).
- Base functional of ARP (reqest, reply), ICMP (reply), UDP protocols (server, client).
- Maximum packet size is 1 kb (fragmentation not supported).

Required 50MHz/48Mhz and 20MHz clocks, 8kbit block memory, ~800 slices.
Tested on Spartan 3E 500 with transformer and direct connection to twisted pair.
