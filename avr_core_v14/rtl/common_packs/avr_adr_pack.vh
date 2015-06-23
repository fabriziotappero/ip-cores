// *****************************************************************************************
// AVR address consrtants (localparams) 
// Version 2.1
// Modified 08.01.2007
// Designed by Ruslan Lepetenok
// EIND register address is added
// type ext_mux_din_type and subtype ext_mux_en_type were removed
// LOG2 function was removed
// Verilog-2001
// *****************************************************************************************

// avr_adr_pack

//`ifdef AVR_ADR_PACK

//`else

//`define AVR_ADR_PACK TRUE

`define C_TWI_MAP_REMAP TRUE
`define C_USE_DM_IO     TRUE 

localparam PINF_Address    = 6'h00; // Input Pins           Port F
localparam PINE_Address    = 6'h01; // Input Pins           Port E
localparam DDRE_Address    = 6'h02; // Data Direction Regis Port E
localparam PORTE_Address   = 6'h03; // Data Register        Port E
localparam ADCL_Address    = 6'h04; // ADC Data register(Low)
localparam ADCH_Address    = 6'h05; // ADC Data register(High)
localparam ADCSRA_Address  = 6'h06; // ADC Control and Status Register
localparam ADMUX_Address   = 6'h07; // ADC Multiplexer Selection Register
localparam ACSR_Address    = 6'h08; // Analog Comparator Control and Status Register
localparam UBRR0L_Address  = 6'h09; // USART0 Baud Rate Register Low
localparam UCSR0B_Address  = 6'h0A; // USART0 Control and Status Register B
localparam UCSR0A_Address  = 6'h0B; // USART0 Control and Status Register A
localparam UDR0_Address    = 6'h0C; // USART0 I/O Data Register
localparam SPCR_Address    = 6'h0D; // SPI Control Register
localparam SPSR_Address    = 6'h0E; // SPI Status Register
localparam SPDR_Address    = 6'h0F; // SPI I/O Data Register
localparam PIND_Address    = 6'h10; // Input Pins           Port D
localparam DDRD_Address    = 6'h11; // Data Direction Regis Port D
localparam PORTD_Address   = 6'h12; // Data Register        Port D
localparam PINC_Address    = 6'h13; // Input Pins           Port C
localparam DDRC_Address    = 6'h14; // Data Direction Regis Port C
localparam PORTC_Address   = 6'h15; // Data Register        Port C
localparam PINB_Address    = 6'h16; // Input Pins           Port B
localparam DDRB_Address    = 6'h17; // Data Direction Regis Port B
localparam PORTB_Address   = 6'h18; // Data Register        Port B
localparam PINA_Address    = 6'h19; // Input Pins           Port A
localparam DDRA_Address    = 6'h1A; // Data Direction Regis Port A
localparam PORTA_Address   = 6'h1B; // Data Register        Port A
localparam EECR_Address    = 6'h1C; // EEPROM Control Register
localparam EEDR_Address    = 6'h1D; // EEPROM Data Register
localparam EEARL_Address   = 6'h1E; // EEPROM Address Register(Low)
localparam EEARH_Address   = 6'h1F; // EEPROM Address Register(High)
localparam SFIOR_Address   = 6'h20; // Special Function I/O Register
localparam WDTCR_Address   = 6'h21; // Watchdog Timer Control Register
localparam OCDR_Address    = 6'h22; // On-Chip Debug Register
localparam OCR2_Address    = 6'h23; // Timer/Counter 2 Output Compare Register
localparam TCNT2_Address   = 6'h24; // Timer/Counter 2
localparam TCCR2_Address   = 6'h25; // Timer/Counter 2 Control Register
localparam ICR1L_Address   = 6'h26; // Timer/Counter 1 Input Capture Register(Low)
localparam ICR1H_Address   = 6'h27; // Timer/Counter 1 Input Capture Register(High)
localparam OCR1BL_Address  = 6'h28; // Timer/Counter 1 Output Compare Register B(Low)
localparam OCR1BH_Address  = 6'h29; // Timer/Counter 1 Output Compare Register B(High)
localparam OCR1AL_Address  = 6'h2A; // Timer/Counter 1 Output Compare Register A(Low)
localparam OCR1AH_Address  = 6'h2B; // Timer/Counter 1 Output Compare Register A(High)
localparam TCNT1L_Address  = 6'h2C; // Timer/Counter 1 Register(Low)
localparam TCNT1H_Address  = 6'h2D; // Timer/Counter 1 Register(High)
localparam TCCR1B_Address  = 6'h2E; // Timer/Counter 1 Control Register B
localparam TCCR1A_Address  = 6'h2F; // Timer/Counter 1 Control Register A
localparam ASSR_Address    = 6'h30; // Asynchronous mode Status Register
localparam OCR0_Address    = 6'h31; // Timer/Counter 0 Output Compare Register
localparam TCNT0_Address   = 6'h32; // Timer/Counter 0
localparam TCCR0_Address   = 6'h33; // Timer/Counter 0 Control Register
localparam MCUCSR_Address  = 6'h34; // MCU general Control and Status Register
localparam MCUCR_Address   = 6'h35; // MCU general Control Register
localparam TIFR_Address    = 6'h36; // Timer/Counter Interrupt Flag Register
localparam TIMSK_Address   = 6'h37; // Timer/Counter Interrupt Mask Register
localparam EIFR_Address    = 6'h38; // External Interrupt Flag Register
localparam EIMSK_Address   = 6'h39; // External Interrupt Mask Register
localparam EICRB_Address   = 6'h3A; // External Interrupt Control Register B
localparam RAMPZ_Address   = 6'h3B; // RAM Page Z Select Register
localparam XDIV_Address    = 6'h3C; // XTAL Divide Control Register
localparam SPL_Address     = 6'h3D; // Stack Pointer(Low)
localparam SPH_Address     = 6'h3E; // Stack Pointer(High)
localparam SREG_Address    = 6'h3F; // Status Register

`ifdef C_USE_DM_IO
// Extended I/O space (located in DM)
localparam DDRF_Address    = 8'h61; // Data Direction Regis Port F
localparam PORTF_Address   = 8'h62; // Data Register        Port F
localparam PING_Address    = 8'h63; // Input Pins           Port G
localparam DDRG_Address    = 8'h64; // Data Direction Regis Port G
localparam PORTG_Address   = 8'h65; // Data Register        Port G
localparam SPMCSR_Address  = 8'h68; // Store Program Memory Control and Status Register
localparam EICRA_Address   = 8'h6A; // External Interrupt Control Register A
localparam XMCRB_Address   = 8'h6C; // External Memory Control Register B
localparam XMCRA_Address   = 8'h6D; // External Memory Control Register A
localparam OSCCAL_Address  = 8'h6F; // Oscillator Calibration Register

`ifndef C_TWI_MAP_REMAP
localparam TWBR_Address    = 8'h70; // TWI Bit Rate Register
localparam TWSR_Address    = 8'h71; // TWI Status Register
localparam TWAR_Address    = 8'h72; // TWI Address Register
localparam TWDR_Address    = 8'h73; // TWI Data Register
localparam TWCR_Address    = 8'h74; // TWI Control Register
`endif

localparam OCR1CL_Address  = 8'h78; // Timer/Counter 1 Output Compare Register C(Low)
localparam OCR1CH_Address  = 8'h79; // Timer/Counter 1 Output Compare Register C(High)
localparam TCCR1C_Address  = 8'h7A; // Timer/Counter 1 Control Register C
localparam ETIFR_Address   = 8'h7C; // Extended Timer/Counter Interrupt Flag Register
localparam ETIMSK_Address  = 8'h7D; // Extended Timer/Counter Interrupt Mask Register
localparam ICR3L_Address   = 8'h80; // Timer/Counter 3 Input Capture Register(Low)
localparam ICR3H_Address   = 8'h81; // Timer/Counter 3 Input Capture Register(High)
localparam OCR3CL_Address  = 8'h82; // Timer/Counter 3 Output Compare Register C(Low)
localparam OCR3CH_Address  = 8'h83; // Timer/Counter 3 Output Compare Register C(High)
localparam OCR3BL_Address  = 8'h84; // Timer/Counter 3 Output Compare Register B(Low)
localparam OCR3BH_Address  = 8'h85; // Timer/Counter 3 Output Compare Register B(High)
localparam OCR3AL_Address  = 8'h86; // Timer/Counter 3 Output Compare Register A(Low)
localparam OCR3AH_Address  = 8'h87; // Timer/Counter 3 Output Compare Register A(High)
localparam TCNT3L_Address  = 8'h88; // Timer/Counter 3 Register Low
localparam TCNT3H_Address  = 8'h89; // Timer/Counter 3 Register Low
localparam TCCR3B_Address  = 8'h8A; // Timer/Counter 3 Control Register B
localparam TCCR3A_Address  = 8'h8B; // Timer/Counter 3 Control Register A
localparam TCCR3C_Address  = 8'h8C; // Timer/Counter 3 Control Register C
localparam UBRR0H_Address  = 8'h90; // USART0 Baud Rate Register High
localparam UCSR0C_Address  = 8'h95; // USART0 Control and Status Register C
localparam UBRR1H_Address  = 8'h98; // USART1 Baud Rate Register High
localparam UBRR1L_Address  = 8'h99; // USART1 Baud Rate Register Low
localparam UCSR1B_Address  = 8'h9A; // USART1 Control and Status Register B
localparam UCSR1A_Address  = 8'h9B; // USART1 Control and Status Register A
localparam UDR1_Address    = 8'h9C; // USART1 I/O Data Register
localparam UCSR1C_Address  = 8'h9D; // USART1 Control and Status Register C
`endif

// Cores with 22 bit PC(I/O)
localparam EIND_Address    = 6'h3C; // !!!TBD!!! Occupated by XDIV in Mega128

//`endif

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
