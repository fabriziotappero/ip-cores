//********************************************************************************************
//
// File : adc.c implement for on-board temparature sensor and ADC0
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
#include "includes.h"
// Thermistor resistance and ADC calculation.
//
// Rntc = R0 * exp B(1/T - 1/T0)
//
// R0 : Zero resistance @ 25 degree celsius.
// B : constant value (see datasheet)
// T0 : Zero temparature in Kevin
//
// constant from TTC05's datasheet : R0 = 10kOhm, B = 4050K, T0 = 25+273.15
// 
//            Rntc
// Vref o-----/\/\/-------
//                        |------o Vout
// 0V   o-----/\/\/-------
//            Rout
// Rout = 10k
// Vout = (2.56 * 10000.0) / (10000.0 + Rntc)
// ADC = (Vout / 2.56) * 1024.0
//
// 2.56 is Internal Vref
//
// below table are ADC values, calculate from T=0 to T=99
prog_uint16_t temp_list[100] = 
{
229, 239, 249, 259, 270, 280, 291, 302, 313, 324,
335, 347, 358, 370, 382, 394, 405, 417, 429, 441,
453, 465, 477, 489, 500, 512, 524, 535, 547, 558,
569, 580, 591, 602, 613, 623, 633, 644, 654, 663,
673, 682, 692, 701, 710, 718, 727, 735, 743, 751,
759, 766, 774, 781, 788, 795, 801, 808, 814, 820,
826, 832, 837, 843, 848, 853, 858, 863, 867, 872,
876, 881, 885, 889, 893, 897, 900, 904, 907, 911,
914, 917, 920, 923, 926, 929, 931, 934, 936, 939,
941, 944, 946, 948, 950, 952, 954, 956, 958, 960,
};
//********************************************************************************************
//
// Function : adc_read
// Description : read ADC value, select ADC channel to read by channel argument
//
//********************************************************************************************
WORD adc_read ( BYTE channel )
{
	// Analog channel selection
	ADMUX = ((ADMUX) & ~0x1f) | (channel & 0x1f);
	
	// Start conversion
	ADCSRA |= _BV(ADSC);

	// Wait until conversion complete
	while( bit_is_set(ADCSRA, ADSC) );
	
	// CAUTION: READ ADCL BEFORE ADCH!!!
	return ((ADCL) | ((ADCH)<<8));
}
//********************************************************************************************
//
// Function : adc_init
// Description : Initial analog to digital convertion
//
//********************************************************************************************
//void adc_init ( void ) __attribute__ ((naked));
void adc_init ( void )
{
	//BYTE i;

	// ADC enable, Prescaler divide by 128, ADC clock = 16MHz/128 = 125kHz
	ADCSRA = _BV(ADEN) | _BV(ADPS2) | _BV(ADPS1) | _BV(ADPS0);

	// Select Vref, internal Vref 2.56V and external capacitor
	ADMUX = _BV(REFS1) | _BV(REFS0);
	
	// reading temparature
	//for ( i=0; i<32; i++ )
	//	adc_read_temp ();
}
//********************************************************************************************
//
// Function : adc_read_temp
// Description : read temparature from ADC1 and convert to real temparature
//
//********************************************************************************************
BYTE adc_read_temp ( void )
{
	static WORD temp_buf[ ADC_TEMP_BUFFER ];
	static BYTE buf_index=0;
	WORD result=0,data;
	BYTE loop;
	
	// Store each sample to buffer
	temp_buf[ buf_index ] = adc_read ( ADC_TEMP_CHANNEL );
	
	// Low pass filter 8 samples by default.
	for ( loop=0; loop<ADC_TEMP_BUFFER; loop++ )
	{
		result += temp_buf [ loop ];
	}
	// reset index
	if( ++buf_index == ADC_TEMP_BUFFER )
	{
		buf_index = 0;
	}
	
	// average result
	result = result / ADC_TEMP_BUFFER;
	
	// look-up for temparature, convert to real temparature
	for ( loop=0; loop<100; loop++ )
	{
		data = pgm_read_word ( temp_list + loop );
		if( result <= data)
			break;
	}

	return loop;
}
