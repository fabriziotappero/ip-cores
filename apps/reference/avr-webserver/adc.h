//********************************************************************************************
//
// File : adc.h implement for on-board temparature sensor and potentiometer.
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
#define ASCII_DEGREE		0xdf
#define ADC_TEMP_CHANNEL	1
#define ADC_TEMP_BUFFER		8

extern BYTE adc_read_temp ( void );
extern WORD adc_read ( BYTE channel );
extern void adc_init ( void );
