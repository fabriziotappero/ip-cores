//********************************************************************************************
//
// File : include.h includes all header file for AVRethernet development board.
//
//********************************************************************************************
//
// Copyright (C) 2007
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation; either version 2 of the License, or (at your option) any later
// version.
// This program is distributed in the hope that it will be useful, but
//
// WITHOUT ANY WARRANTY;
//
// without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
// PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with
// this program; if not, write to the Free Software Foundation, Inc., 51
// Franklin St, Fifth Floor, Boston, MA 02110, USA
//
// http://www.gnu.de/gpl-ger.html
//
//********************************************************************************************
#include <avr/io.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <util/delay.h>
#include <avr/pgmspace.h>
#include <avr/eeprom.h>

// struct.h MUST be include first
#include "struct.h"
#include "enc28j60.h"
#include "ethernet.h"
#include "ip.h"
#include "tcp.h"
#include "icmp.h"
#include "arp.h"
#include "udp.h"
#include "http.h"
#include "lcd.h"
#include "menu.h"
#include "adc.h"

// define I/O interface

#define LED_PIN1_DDR			DDC6
#define LED_PIN1				PC6
#define LED_PIN2_DDR			DDC7
#define LED_PIN2				PC7
#define LED_PORT				PORTC
#define LED_DDR					DDRC

#define LOW(uint) (uint&0xFF)
#define HIGH(uint) ((uint>>8)&0xFF)

#define MAX_RXTX_BUFFER		1518

// global variables
extern MAC_ADDR avr_mac;
extern IP_ADDR avr_ip;

//extern MAC_ADDR client_mac;
//extern IP_ADDR client_ip;

extern MAC_ADDR server_mac;
extern IP_ADDR server_ip;

extern BYTE generic_buf[];
extern BYTE ee_avr_ip[];
extern BYTE ee_server_ip[];
//********************************************************************************************
//
// Prototype function from main.c
//
//********************************************************************************************
extern void initial_system( void );

