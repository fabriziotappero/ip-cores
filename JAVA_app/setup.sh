#! /bin/sh

# This script sets up the basic network configuration and a 'fake' ARP table 
# entry for the FPGA.
# We assume that the FPGA is connected to the ethernet port eth0.
# The IP adress of the PC is fixed to 192.168.1.2, the IP of the FPGA
# is fixed to 192.168.1.1.
# The ARP table entry will cause every packet sent to 192.168.1.1
# to be routed to the FPGA.

sudo ifconfig eth0 down

sudo ifconfig eth0 -arp
sudo ifconfig eth0 192.168.1.2
sudo arp -i eth0 -s 192.168.1.1 FF:FF:FF:FF:FF:FF
sudo ifconfig eth0 mtu 9000
