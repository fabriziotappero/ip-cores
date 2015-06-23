////////////////////////////////////////////////////////////////////////////////
//
//  CHIPS-2.0  print.h
//
//  :Author: Jonathan P Dawson
//  :Date: 22/10/2013
//  :email: chips@jondawson.org.uk
//  :license: MIT
//  :Copyright: Copyright (C) Jonathan P Dawson 2013
//
//  Print values to stdout. Before including this file, 
//  void stdout_put_char(unsigned i) must be defined.
//  
//  This task is left to the user so that stdout can be directed to uart/socket
//  as required.
//
////////////////////////////////////////////////////////////////////////////////


//Print a string *string* to stdout
void print_string(unsigned string[]){
	unsigned i=0;
	while(string[i]){
	       	stdout_put_char(string[i]);
		i++;
	}
}

//Print an unsigned int to stdout in hex format
void print_uhex(unsigned uhex){
	unsigned digit_3 = (uhex >> 12) & 0xf;
	unsigned digit_2 = (uhex >> 8) & 0xf;
	unsigned digit_1 = (uhex >> 4) & 0xf;
	unsigned digit_0 = uhex & 0xf;
	if(digit_3 < 9) stdout_put_char(digit_3 | 0x30);
	else stdout_put_char(digit_3 + 87);
	if(digit_2 < 9) stdout_put_char(digit_2 | 0x30);
	else stdout_put_char(digit_2 + 87);
	if(digit_1 < 9) stdout_put_char(digit_1 | 0x30);
	else stdout_put_char(digit_1 + 87);
	if(digit_0 < 9) stdout_put_char(digit_0 | 0x30);
	else stdout_put_char(digit_0 + 87);
}

//Print an unsigned int to stdout in decimal format
//leading 0s will be suppressed
void print_udecimal(unsigned udecimal){
	unsigned digit;
	unsigned significant = 0;
	digit = 0;
	while(udecimal >= 10000){
		udecimal -= 10000;
		digit += 1;
	}
	if(digit | significant){
	      stdout_put_char(digit | 0x30);
	      significant = 1;
	}
	digit = 0;
	while(udecimal >= 1000){
		udecimal -= 1000;
		digit += 1;
	}
	if(digit | significant){
	      stdout_put_char(digit | 0x30);
	      significant = 1;
	}
	digit = 0;
	while(udecimal >= 100){
		udecimal -= 100;
		digit += 1;
	}
	if(digit | significant){
	      stdout_put_char(digit | 0x30);
	      significant = 1;
	}
	digit = 0;
	while(udecimal >= 10){
		udecimal -= 10;
		digit += 1;
	}
	if(digit | significant){
	      stdout_put_char(digit | 0x30);
	      significant = 1;
	}
	stdout_put_char(udecimal | 0x30);
}

//Print a signed int to stdout in hex format
void print_hex(int hex){
	if(hex >= 0){
		print_uhex(hex);
	} else {
		stdout_put_char('-');
		print_uhex(-hex);
	}
}

//Print a signed int to stdout in decimal format
//leading 0s will be suppressed
void print_decimal(int decimal){
	if(decimal >= 0){
		print_udecimal(decimal);
	} else {
		stdout_put_char('-');
		print_udecimal(-decimal);
	}
}
