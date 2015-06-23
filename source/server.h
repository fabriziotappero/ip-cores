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


////////////////////////////////////////////////////////////////////////////////
// TCP-IP User Settings
//

const unsigned local_mac_address_hi = 0x0001u;
const unsigned local_mac_address_med = 0x0203u;
const unsigned local_mac_address_lo = 0x0405u;
const unsigned local_ip_address_hi = 0xc0A8u;//192/168
const unsigned local_ip_address_lo = 0x0101u;//1/1
const unsigned local_port = 80u;//http

////////////////////////////////////////////////////////////////////////////////
// TCP-IP GLOBALS
//

unsigned tx_packet[512];

////////////////////////////////////////////////////////////////////////////////
// Checksum calculation routines
//
 
//store checksum in a global variable
//unsigneds are 16 bits, so use an array of 2 to hold a 32 bit number
 
long unsigned checksum;
 
//Reset checksum before calculation
//
 
void reset_checksum(){
  checksum = 0;
}
 
//Add 16 bit data value to 32 bit checksum value
//
 
void add_checksum(unsigned data){
  checksum += data;
  if(checksum & 0x10000ul){
	  checksum &= 0xffffu;
	  checksum += 1;
  }
}
 
//Retrieve the calculated checksum
//
 
unsigned check_checksum(){
  return ~checksum;
}

////////////////////////////////////////////////////////////////////////////////
// UTILITY FUNCTIONS
//

unsigned calc_ack(unsigned ack[], unsigned seq[], unsigned length){
	//given a two word sequence number and a one word length
	//calculate a two word acknowledgement number
	//check whether we have new data or not
	unsigned new_ack_0;
	unsigned new_ack_1;
	unsigned return_value = 0;
	new_ack_0 = seq[0] + length;
	new_ack_1 = seq[1];
	if(new_ack_0 < length) new_ack_1 = new_ack_1 + 1;

	//Is this data we have allready acknowledged?
	if((new_ack_0 != ack[0]) || (new_ack_1 != ack[1])){
		ack[0] = new_ack_0;
		ack[1] = new_ack_1;
		return_value = 1;
	}
	return return_value;
}
			
////////////////////////////////////////////////////////////////////////////////
// Data Link Layer - Ethernet
//

void put_ethernet_packet(
		unsigned packet[], 
		unsigned number_of_bytes,
		unsigned destination_mac_address_hi,
		unsigned destination_mac_address_med,
		unsigned destination_mac_address_lo,
		unsigned protocol){

        unsigned byte, index;
	report(number_of_bytes);

        //set up ethernet header
	packet[0] = destination_mac_address_hi;
	packet[1] = destination_mac_address_med;
	packet[2] = destination_mac_address_lo;
	packet[3] = local_mac_address_hi;
	packet[4] = local_mac_address_med;
	packet[5] = local_mac_address_lo;
	packet[6] = protocol;

	put_eth(number_of_bytes);
	index = 0;
	for(byte=0; byte<number_of_bytes; byte+=2){
		put_eth(packet[index]);
		index ++;
	}
}

//Get a packet from the ethernet interface
//Will reply to arp requests
//returns the number of bytes read which may be 0
unsigned get_ethernet_packet(unsigned packet[]){

        unsigned number_of_bytes, index;
	unsigned byte;

	if(!rdy_eth()) return 0;

	number_of_bytes = get_eth();
	index = 0;
	for(byte=0; byte<number_of_bytes; byte+=2){
		packet[index] = get_eth();
		index ++;
	}

        //Filter out packets not meant for us
	if(packet[0] != local_mac_address_hi && packet[0] != 0xffffu) return 0;
	if(packet[1] != local_mac_address_med && packet[1] != 0xffffu) return 0;
	if(packet[2] != local_mac_address_lo && packet[2] != 0xffffu) return 0;

	//Process ARP requests within the data link layer
	if (packet[6] == 0x0806){ //ARP
		//respond to requests
		if (packet[10] == 0x0001){
			//construct and send an ARP response
			tx_packet[7] = 0x0001; //HTYPE ethernet
			tx_packet[8] = 0x0800; //PTYPE IPV4
			tx_packet[9] = 0x0604; //HLEN, PLEN
			tx_packet[10] = 0x0002; //OPER=REPLY
			tx_packet[11] = local_mac_address_hi; //SENDER_HARDWARE_ADDRESS
			tx_packet[12] = local_mac_address_med; //SENDER_HARDWARE_ADDRESS
			tx_packet[13] = local_mac_address_lo; //SENDER_HARDWARE_ADDRESS
			tx_packet[14] = local_ip_address_hi; //SENDER_PROTOCOL_ADDRESS
			tx_packet[15] = local_ip_address_lo; //SENDER_PROTOCOL_ADDRESS
			tx_packet[16] = packet[11]; //TARGET_HARDWARE_ADDRESS
			tx_packet[17] = packet[12]; //
			tx_packet[18] = packet[13]; //
			tx_packet[19] = packet[14]; //TARGET_PROTOCOL_ADDRESS
			tx_packet[20] = packet[15]; //
			put_ethernet_packet(
				tx_packet, 
				64,
				packet[11],
				packet[12],
				packet[13],
				0x0806);
		}
		return 0;
	}
	return number_of_bytes;
}

unsigned arp_ip_hi[16];
unsigned arp_ip_lo[16];
unsigned arp_mac_0[16];
unsigned arp_mac_1[16];
unsigned arp_mac_2[16];
unsigned arp_pounsigneder = 0;

//return the location of the ip address in the arp cache table
unsigned get_arp_cache(unsigned ip_hi, unsigned ip_lo){

        unsigned number_of_bytes;
	unsigned byte;
	unsigned packet[16];
	unsigned i;

	//Is the requested IP in the ARP cache?
	for(i=0; i<16; i++){
		if(arp_ip_hi[i] == ip_hi && arp_ip_lo[i] == ip_lo){
			return i;
		}
	}

        //It is not, so send an arp request
	tx_packet[7] = 0x0001u; //HTYPE ethernet
	tx_packet[8] = 0x0800u; //PTYPE IPV4
	tx_packet[9] = 0x0604u; //HLEN, PLEN
	tx_packet[10] = 0x0001u; //OPER=REQUEST
	tx_packet[11] = local_mac_address_hi; //SENDER_HARDWARE_ADDRESS
	tx_packet[12] = local_mac_address_med; //SENDER_HARDWARE_ADDRESS
	tx_packet[13] = local_mac_address_lo; //SENDER_HARDWARE_ADDRESS
	tx_packet[14] = local_ip_address_hi; //SENDER_PROTOCOL_ADDRESS
	tx_packet[15] = local_ip_address_lo; //SENDER_PROTOCOL_ADDRESS
	tx_packet[19] = ip_hi; //TARGET_PROTOCOL_ADDRESS
	tx_packet[20] = ip_lo; //
	put_ethernet_packet(
		tx_packet, 
		64u,
		0xffffu, //broadcast via ethernet
		0xffffu,
		0xffffu,
		0x0806u);

        //wait for a response
	while(1){

		number_of_bytes = get_eth();
		i = 0;
		for(byte=0; byte<number_of_bytes; byte+=2){
			//only keep the part of the packet we care about
			if(i < 16){
				packet[i] = get_eth();
			} else {
				get_eth();
			}
			i++;
		}

                //Process ARP requests within the data link layer
	        if (packet[6] == 0x0806 && packet[10] == 0x0002){
			if (packet[14] == ip_hi && packet[15] == ip_lo){
				arp_ip_hi[arp_pounsigneder] = ip_hi;
				arp_ip_lo[arp_pounsigneder] = ip_lo;
				arp_mac_0[arp_pounsigneder] = packet[11];
				arp_mac_1[arp_pounsigneder] = packet[12];
				arp_mac_2[arp_pounsigneder] = packet[13];
				i = arp_pounsigneder;
				arp_pounsigneder++;
				if(arp_pounsigneder == 16) arp_pounsigneder = 0;
				return i;
			}
		}
	}
}

////////////////////////////////////////////////////////////////////////////////
// Network Layer - Internet Protocol
//

void put_ip_packet(unsigned packet[], unsigned total_length, unsigned protocol, unsigned ip_hi, unsigned ip_lo){
	unsigned number_of_bytes, i, arp_cache;

	//see if the requested IP address is in the arp cache
	arp_cache = get_arp_cache(ip_hi, ip_lo);

        //Form IP header
	packet[7] = 0x4500;              //Version 4 header length 5x32
	packet[8] = total_length;        //IP data + header
	packet[9] = 0x0000;              //Identification
	packet[10] = 0x4000;             //don't fragment
	packet[11] = 0xFF00u | protocol;  //ttl|protocol
	packet[12] = 0x0000;             //checksum
	packet[13] = local_ip_address_hi;//source_high
	packet[14] = local_ip_address_lo;//source_low
	packet[15] = ip_hi;              //dest_high
	packet[16] = ip_lo;              //dest_low
	number_of_bytes = total_length + 14;

	//calculate checksum
        reset_checksum();
	for(i=7; i<=16; i++){
		add_checksum(packet[i]);
	}
	packet[12] = check_checksum();

	//enforce minimum ethernet frame size
	if(number_of_bytes < 64){
		number_of_bytes = 64;
	}

	//send packet over ethernet
	put_ethernet_packet(
		packet,                  //packet
		number_of_bytes,         //number_of_bytes
	       	arp_mac_0[arp_cache],    //destination mac address
		arp_mac_1[arp_cache],    //
		arp_mac_2[arp_cache],    //
		0x0800);                 //protocol IPv4
}

unsigned get_ip_packet(unsigned packet[]){
	unsigned ip_payload;
	unsigned total_length;
	unsigned header_length;
	unsigned payload_start;
	unsigned payload_length;
	unsigned i, from, to;
	unsigned payload_end;
	unsigned number_of_bytes;

	number_of_bytes = get_ethernet_packet(packet);

	if(number_of_bytes == 0) return 0;
	if(packet[6] != 0x0800) return 0;
	if(packet[15] != local_ip_address_hi) return 0;
	if(packet[16] != local_ip_address_lo) return 0;
	if((packet[11] & 0xff) == 1){//ICMP
		header_length = ((packet[7] >> 8) & 0xf) << 1;                   //in words
		payload_start = header_length + 7;                               //in words
		total_length = packet[8];                                        //in bytes
		payload_length = ((total_length+1) >> 1) - header_length;        //in words
		payload_end = payload_start + payload_length - 1;                //in words

		if(packet[payload_start] == 0x0800){//ping request

			//copy icmp packet to response
			to = 19;//assume that 17 and 18 are 0
			reset_checksum();
			for(from=payload_start+2; from<=payload_end; from++){
				i = packet[from];
				add_checksum(i);
				tx_packet[to] = i;
				to++;
			}
			tx_packet[17] = 0;//ping response
			tx_packet[18] = check_checksum();

			//send ping response
			put_ip_packet(
				tx_packet,
				total_length,
				1,//icmp
				packet[13], //remote ip
				packet[14]  //remote ip
			);
		}
		return 0;
				
	}
	if((packet[11] & 0xff) != 6) return 0;//TCP
	return number_of_bytes;
}

////////////////////////////////////////////////////////////////////////////////
// Transport Layer - TCP
//

unsigned remote_ip_hi, remote_ip_lo;

unsigned tx_source=0;
unsigned tx_dest=0;
unsigned tx_seq[2];
unsigned next_tx_seq[2];
unsigned tx_ack[2];
unsigned tx_window=1460; //ethernet MTU - 40 bytes for TCP/IP header

unsigned tx_fin_flag=0;
unsigned tx_syn_flag=0;
unsigned tx_rst_flag=0;
unsigned tx_psh_flag=0;
unsigned tx_ack_flag=0;
unsigned tx_urg_flag=0;

unsigned rx_source=0;
unsigned rx_dest=0;
unsigned rx_seq[2];
unsigned rx_ack[2];
unsigned rx_window=0;

unsigned rx_fin_flag=0;
unsigned rx_syn_flag=0;
unsigned rx_rst_flag=0;
unsigned rx_psh_flag=0;
unsigned rx_ack_flag=0;
unsigned rx_urg_flag=0;

void put_tcp_packet(unsigned tx_packet [], unsigned tx_length){

        unsigned payload_start = 17;
	unsigned packet_length;
	unsigned index;
	unsigned i;

	//encode TCP header
	tx_packet[payload_start + 0] = tx_source;
	tx_packet[payload_start + 1] = tx_dest;
	tx_packet[payload_start + 2] = tx_seq[1];
	tx_packet[payload_start + 3] = tx_seq[0];
	tx_packet[payload_start + 4] = tx_ack[1];
	tx_packet[payload_start + 5] = tx_ack[0];
	tx_packet[payload_start + 6] = 0x5000; //5 long words
	tx_packet[payload_start + 7] = tx_window;
	tx_packet[payload_start + 8] = 0;
	tx_packet[payload_start + 9] = 0;

	//encode flags
	if(tx_fin_flag) tx_packet[payload_start + 6] |= 0x01;
	if(tx_syn_flag) tx_packet[payload_start + 6] |= 0x02;
	if(tx_rst_flag) tx_packet[payload_start + 6] |= 0x04;
	if(tx_psh_flag) tx_packet[payload_start + 6] |= 0x08;
	if(tx_ack_flag) tx_packet[payload_start + 6] |= 0x10;
	if(tx_urg_flag) tx_packet[payload_start + 6] |= 0x20;

	//calculate checksum
	//length of payload + header + pseudo_header in words
        reset_checksum();
        add_checksum(local_ip_address_hi);
        add_checksum(local_ip_address_lo);
        add_checksum(remote_ip_hi);
        add_checksum(remote_ip_lo);
        add_checksum(0x0006);
        add_checksum(tx_length+20);//tcp_header + tcp_payload in bytes

	packet_length = (tx_length + 20 + 1) >> 1; 
	index = payload_start;
	for(i=0; i<packet_length; i++){
		add_checksum(tx_packet[index]);
		index++;
	}
	tx_packet[payload_start + 8] = check_checksum();

	put_ip_packet(
		tx_packet,
		tx_length + 40,
		6,//tcp
		remote_ip_hi, //remote ip
		remote_ip_lo  //remote ip
	);
}

unsigned rx_length, rx_start;

unsigned get_tcp_packet(unsigned rx_packet []){

        unsigned number_of_bytes, header_length, payload_start, total_length, payload_length, payload_end, tcp_header_length;

	number_of_bytes = get_ip_packet(rx_packet);

	//decode lengths from the IP header
	header_length = ((rx_packet[7] >> 8) & 0xf) << 1;                   //in words
	payload_start = header_length + 7;                                  //in words

	total_length = rx_packet[8];                                        //in bytes
	payload_length = total_length - (header_length << 1);               //in bytes
	tcp_header_length = ((rx_packet[payload_start + 6] & 0xf000u)>>10); //in bytes
	rx_length = payload_length - tcp_header_length;                     //in bytes
	rx_start = payload_start + (tcp_header_length >> 1);                //in words

	//decode TCP header
	rx_source = rx_packet[payload_start + 0];
	rx_dest   = rx_packet[payload_start + 1];
	rx_seq[1] = rx_packet[payload_start + 2];
	rx_seq[0] = rx_packet[payload_start + 3];
	rx_ack[1] = rx_packet[payload_start + 4];
	rx_ack[0] = rx_packet[payload_start + 5];
	rx_window = rx_packet[payload_start + 7];

	//decode flags
	rx_fin_flag = rx_packet[payload_start + 6] & 0x01;
	rx_syn_flag = rx_packet[payload_start + 6] & 0x02;
	rx_rst_flag = rx_packet[payload_start + 6] & 0x04;
	rx_psh_flag = rx_packet[payload_start + 6] & 0x08;
	rx_ack_flag = rx_packet[payload_start + 6] & 0x10;
	rx_urg_flag = rx_packet[payload_start + 6] & 0x20;

	return number_of_bytes;
}

void application_put_data(unsigned packet[], unsigned start, unsigned length){
	unsigned i, index;

	index = start;
	put_socket(length);
	for(i=0; i<length; i+=2){
		put_socket(packet[index]);
		index++;
	}
}

unsigned application_get_data(unsigned packet[], unsigned start){
	unsigned i, index, length;

	if(!ready_socket()){
		return 0;
	}

	index = start;
	length = get_socket();
	for(i=0; i<length; i+=2){
		packet[index] = get_socket();
		index++;
	}
	return length;
}

void server()
{
	unsigned rx_packet[1024];
	unsigned tx_packet[1024];
	unsigned tx_start = 27;

	unsigned new_rx_data = 0;
	unsigned new_tx_data = 0;
	unsigned tx_length;
	unsigned timeout;
	unsigned resend_wait;
	unsigned bytes;
	unsigned last_state;
	unsigned new_rx_data;

	const unsigned listen           = 0;
	const unsigned open             = 1;
	const unsigned send             = 2;
	const unsigned wait_acknowledge = 3;
	const unsigned close            = 4;
	unsigned state = listen;

	tx_seq[0] = 0;
	tx_seq[1] = 0;

	while(1){

		if(timeout){
			timeout--;
		} else {
			timeout = 120; //2 mins @100 MHz
			state = listen;
			tx_syn_flag = 0;
			tx_fin_flag = 0;
			tx_ack_flag = 0;
			tx_rst_flag = 1;
			put_tcp_packet(tx_packet, 0);//send reset packet
		}

		// (optionaly) send something
		switch(state){
		    case listen:
			tx_rst_flag = 0;
			tx_syn_flag = 0;
			tx_fin_flag = 0;
			tx_ack_flag = 0;
			break;
		    case open:
			// set remote ip/port
			remote_ip_hi = rx_packet[13];
			remote_ip_lo = rx_packet[14];
			tx_dest = rx_source;
			tx_source = local_port;
			// send syn_ack
			calc_ack(tx_ack, rx_seq, 1);
			tx_syn_flag = 1;
			tx_ack_flag = 1;
			put_tcp_packet(tx_packet, 0);
			break;
		    case send:
			// application -> tcp
			tx_length = application_get_data(tx_packet, tx_start);
			tx_seq[0] = next_tx_seq[0];
			tx_seq[1] = next_tx_seq[1];
			calc_ack(next_tx_seq, tx_seq, tx_length);
			tx_syn_flag = 0;
			tx_ack_flag = 1;
			put_tcp_packet(tx_packet, tx_length);
			break;
		    case wait_acknowledge:
			// resend until acknowledge recieved
			put_tcp_packet(tx_packet, tx_length);
			break;
		    case close:
			// send fin ack
			tx_fin_flag = 1;
			tx_ack_flag = 1;
			calc_ack(tx_ack, rx_seq, 1);
			put_tcp_packet(tx_packet, 0);
			break;
		}

		// repeatedly check for responses
		for(resend_wait = 10000; resend_wait; resend_wait--){ //1 second @ 100MHz
			bytes = get_tcp_packet(rx_packet);
			if(bytes && (rx_dest == local_port)){
				//Once connection is established ignore other connection attempts
				if(state != listen && rx_source != tx_dest) continue;
				new_rx_data = 0;
				last_state = state;
				switch(state){

				    // If a syn packet is recieved, wait for an ack
				    case listen:
					if(rx_syn_flag) state = open;
					else{
						tx_rst_flag = 1;
						put_tcp_packet(tx_packet, 0);//send reset packet
					}
					break;

				    // If an ack is recieved the connection is established
				    case open:
					if(rx_ack_flag){
						tx_seq[1] = rx_ack[1];
						tx_seq[0] = rx_ack[0];
						next_tx_seq[1] = rx_ack[1];
						next_tx_seq[0] = rx_ack[0];
						state = send;
					}
					break;

				    // Send some data
				    case send:
					new_rx_data = calc_ack(tx_ack, rx_seq, rx_length);
					if(rx_fin_flag){
						state = close;
					} else if( tx_length ){
						state = wait_acknowledge;
					}
					break;

				    // Wait until data is acknowledged before sending some more.
				    case wait_acknowledge:

					new_rx_data = calc_ack(tx_ack, rx_seq, rx_length);
					if(rx_fin_flag){
						state = close;
					} else if(  rx_ack_flag &&
						    (next_tx_seq[1] == rx_ack[1]) && 
						    (next_tx_seq[0] == rx_ack[0])){
						state = send;
					}

					break;

				    // wait for fin/ack.
				    case close:
					if(rx_ack_flag) state = listen;
					break;
				}

				if(rx_rst_flag) state = listen;

				// Transfer any new data to the application
				if(new_rx_data){
					application_put_data(rx_packet, rx_start, rx_length);
					//Ack can go in next transmission.
					if(state == last_state) put_tcp_packet(tx_packet, tx_length);
				}

				if(state == send && ready_socket()){
					break;
				}

				if(state != last_state){
					timeout = 120;
					break;
				}

			} else {
				wait_clocks(10000);//100 us @100 MHz
			}
		}
	}
}
