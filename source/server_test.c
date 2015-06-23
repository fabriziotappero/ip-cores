void put_eth(unsigned int i){
	file_write(i, "ethernet.resp");
}
void put_socket(unsigned int i){
	file_write(i, "socket.resp");
}
unsigned get_eth(){
	return file_read("ethernet.stim");
}
unsigned rdy_eth(){
	return 1;
}
unsigned get_socket(){
	return file_read("socket.stim");
}

#include "server.h"
