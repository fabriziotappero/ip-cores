////////////////////////////////////////////////////////////////////////////////
//
//  CHIPS-2.0 TCP/IP SERVER
//
//  :Author: Jonathan P Dawson
//  :Date: 17/10/2013
//  :email: chips@jondawson.org.uk
//  :license: MIT
//  :Copyright: Copyright (C) Jonathan P Dawson 2013
//
//  A TCP/IP stack that supports a single socket connection.
//
////////////////////////////////////////////////////////////////////////////////
void put_eth(unsigned i){
	output_eth_tx(i);
}
void put_socket(unsigned i){
	output_socket(i);
}
unsigned get_eth(){
	return input_eth_rx();
}
unsigned rdy_eth(){
	return ready_eth_rx();
}
unsigned get_socket(){
	return input_socket();
}
#include "server.h"
