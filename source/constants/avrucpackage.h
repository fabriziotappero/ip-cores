//
// $Id: avrucpackage.h,v 1.1 2006-01-25 17:00:00 igorloi Exp $
//
#ifndef _AVRUCPACKAGE_H
#define _AVRUCPACKAGE_H
#include <systemc.h>

#define ext_mux_in_num 63

/*
type ext_mux_din_type is array(0 to ext_mux_in_num) of std_logic_vector(7 downto 0);
subtype ext_mux_en_type  is std_logic_vector(0 to ext_mux_in_num);
*/

// I/O port addresses
#define IOAdrWidth 6

// I/O register file
#define RAMPZ_Address  "111011"
#define SPL_Address    "111101"
#define SPH_Address    "111110"
#define SREG_Address   "111111"

// UART
#define UDR_Address    "001100"
#define UBRR_Address   "001001"
#define USR_Address    "001011"
#define UCR_Address    "001010"

// Timer/Counter
#define TCCR0_Address  "110011"
#define TCCR1A_Address "101111"
#define TCCR1B_Address "101110"
#define TCCR2_Address  "100101"
#define ASSR_Address   "110000"
#define TIMSK_Address  "110111"
#define TIFR_Address   "110110"
#define TCNT0_Address  "110010"
#define TCNT2_Address  "100100"
#define OCR0_Address   "110001"
#define OCR2_Address   "100011"
#define TCNT1H_Address "101101"
#define TCNT1L_Address "101100"
#define OCR1AH_Address "101011"
#define OCR1AL_Address "101010"
#define OCR1BH_Address "101001"
#define OCR1BL_Address "101000"
#define ICR1AH_Address "100111"
#define ICR1AL_Address "100110"

// Service module
#define MCUCR_Address  "110101"
#define EIMSK_Address  "111001"
#define EIFR_Address   "111000"
#define EICR_Address   "111010"
#define MCUSR_Address  "110100"
#define XDIV_Address   "111100"

// PORTA addresses 
#define PORTA_Address  "011001"
#define DDRA_Address   "011010"
#define PINA_Address   "011001"

// PORTB addresses 
#define PORTB_Address  "011000"
#define DDRB_Address   "010111"
#define PINB_Address   "010110"

// PORTC addresses 
#define PORTC_Address  "010101"

// PORTD addresses 
#define PORTD_Address  "010010"
#define DDRD_Address   "010001"
#define PIND_Address   "010000"

// PORTE addresses 
#define PORTE_Address  "000011"
#define DDRE_Address   "000010"
#define PINE_Address   "000001"

// PORTF addresses
#define PINF_Address   "000000"

// Analog to digital converter
#define ADCL_Address   "000100"
#define ADCH_Address   "000101"
#define ADCSR_Address  "000110"
#define ADMUX_Address  "000111"

// Analog comparator
#define ACSR_Address   "001000"

// For pm_fetch_dec

// LD/LDS/LDD/ST/STS/STD ADDRESSING GENERAL PURPOSE REGISTER (R0-R31) 0x00..0x19
#define const_ram_to_reg  "00000000000"
// LD/LDS/LDD/ST/STS/STD ADDRESSING GENERAL I/O PORT 0x20 0x3F
#define const_ram_to_io_a "00000000001"
// LD/LDS/LDD/ST/STS/STD ADDRESSING GENERAL I/O PORT 0x20 0x3F
#define const_ram_to_io_b "00000000010"

#endif
