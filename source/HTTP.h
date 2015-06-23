////////////////////////////////////////////////////////////////////////////////
//
//  CHIPS-2.0  HTTP
//
//  :Author: Jonathan P Dawson
//  :Date: 17/10/2013
//  :email: chips@jondawson.org.uk
//  :license: MIT
//  :Copyright: Copyright (C) Jonathan P Dawson 2013
//
//  Constuct an HTTP response for simple web app.
//
////////////////////////////////////////////////////////////////////////////////
unsigned socket_high = 1;
unsigned socket_data;

void socket_put_char(char x){
	if(socket_high){
		socket_high = 0;
		socket_data = x << 8;
	} else {
		socket_high = 1;
		socket_data |= x & 0xff;
		put_socket(socket_data);
	}
}

void socket_flush(){
	if(!socket_high) put_socket(socket_data);
	socket_high = 1;
}

void socket_put_string(unsigned string[]){
	unsigned i;
	while(string[i]){
		socket_put_char(string[i]);
		i++;
	}
}

void socket_put_decimal(unsigned value){
	unsigned digit_0 = 0;
	unsigned digit_1 = 0;
	unsigned digit_2 = 0;
	unsigned digit_3 = 0;
	unsigned digit_4 = 0;
	unsigned significant = 0;

	while(value >= 10000){
		digit_4++;
		value -= 10000;
	}
	if(digit_4 | significant){
	       	socket_put_char(0x30 | digit_4);
		significant = 1;
	}
	while(value >= 1000){
		digit_3++;
		value -= 1000;
	}
	if(digit_3 | significant) {
		socket_put_char(0x30 | digit_3);
		significant = 1;
	}
	while(value >= 100){
		digit_2++;
		value -= 100;
	}
	if(digit_2 | significant){
	       	socket_put_char(0x30 | digit_2);
		significant = 1;
	}
	while(value >= 10){
		digit_1++;
		value -= 10;
	}
	if(digit_1 | significant){
	       	socket_put_char(0x30 | digit_1);
		significant = 1;
	}
	while(value >= 1){
		digit_0++;
		value -= 1;
	}
	socket_put_char(0x30 | digit_0);
}

void HTTP_Not_Found(){
	unsigned header_length;
	unsigned header[] = 
"HTTP/1.1 404 Not Found\r\n\
Date: Thu Oct 31 19:16:00 2013\r\n\
Server: chips-web/0.0\r\n\
Content-Type: text/html\r\n\
Content-Length: 0\r\n\r\n";

	//count header length
	header_length = 0;
	while(header[header_length]) header_length++;
	put_socket(header_length);
	socket_put_string(header);
	socket_flush();
}

void HTTP_OK(int body[]){
	unsigned header_length;
	unsigned body_length;
	unsigned length, index, packet_count;
	unsigned header[] = 
"HTTP/1.1 200 OK\r\n\
Date: Thu Oct 31 19:16:00 2013\r\n\
Server: chips-web/0.0\r\n\
Content-Type: text/html\r\n\
Content-Length: ";

	//count body length
	body_length = 0;
	while(body[body_length]) body_length++;
	//count header length
	header_length = 0;
	while(header[header_length]) header_length++;

	//count total length
	length = header_length + 5;
	//header length depends on body length
	if(body_length > 9) length++;
	if(body_length > 99) length++;
	if(body_length > 999) length++;
	//Send length to server
	put_socket(length);
	//Send header to server
	socket_put_string(header);
	socket_put_decimal(body_length);
	socket_put_string("\r\n\r\n");
	socket_flush();

	length = body_length;
	index = 0;
	packet_count = 0;
	while(length >= 1046){
		length -= 1046;
		put_socket(1046);
		for(packet_count=0; packet_count<1046; packet_count++){
			socket_put_char(body[index]);
			index++;
		}
		socket_flush();
	}
	put_socket(length);
	for(packet_count=0; packet_count<length; packet_count++){
		socket_put_char(body[index]);
		index++;
	}
	socket_flush();
}
