// *****************************************************************************************
// 
// Version 0.1
// Modified 03.01.2007
// Designed by Ruslan Lepetenok
// *****************************************************************************************


// package bit_def_pack is

// Bit definitions for use with the IAR Assembler   
// The Register Bit names are represented by their bit number (0-7).

// USART1 Control and Status Register C 
localparam    UMSEL1_bit = 6;
localparam    UPM11_bit  = 5;
localparam    UPM10_bit  = 4;
localparam    USBS1_bit  = 3;
localparam    UCSZ11_bit = 2;
localparam    UCSZ10_bit = 1;
localparam    UCPOL1_bit = 0;

// USART1 Control and Status Register A 
localparam    RXC1_bit  = 7;
localparam    TXC1_bit  = 6;
localparam    UDRE1_bit = 5;
localparam    FE1_bit   = 4;
localparam    DOR1_bit  = 3;
localparam    UPE1_bit  = 2;
localparam    U2X1_bit  = 1;
localparam    MPCM1_bit = 0;

// USART1 Control and Status Register B 
localparam    RXCIE1_bit = 7;
localparam    TXCIE1_bit = 6;
localparam    UDRIE1_bit = 5;
localparam    RXEN1_bit  = 4;
localparam    TXEN1_bit  = 3;
localparam    UCSZ12_bit = 2;
localparam    RXB81_bit  = 1;
localparam    TXB81_bit  = 0;
								 
// USART0 Control and Status Register C 
localparam    UMSEL0_bit = 6;
localparam    UPM01_bit  = 5;
localparam    UPM00_bit  = 4;
localparam    USBS0_bit  = 3;
localparam    UCSZ01_bit = 2;
localparam    UCSZ00_bit = 1;
localparam    UCPOL0_bit = 0;

// USART0 Control and Status Register A 
localparam    RXC0_bit   = 7;
localparam    TXC0_bit   = 6;
localparam    UDRE0_bit  = 5;
localparam    FE0_bit    = 4;
localparam    DOR0_bit   = 3;
localparam    UPE0_bit   = 2;
localparam    U2X0_bit   = 1;
localparam    MPCM0_bit  = 0;

// USART0 Control and Status Register B 
localparam    RXCIE0_bit = 7;
localparam    TXCIE0_bit = 6;
localparam    UDRIE0_bit = 5;
localparam    RXEN0_bit  = 4;
localparam    TXEN0_bit  = 3;
localparam    UCSZ02_bit = 2;
localparam    RXB80_bit  = 1;
localparam    TXB80_bit  = 0;

// Timer/Counter 3 Control Register C 
localparam    FOC3A_bit  = 7;
localparam    FOC3B_bit  = 6;
localparam    FOC3C_bit  = 5;

// Timer/Counter 3 Control Register A 
localparam    COM3A1_bit = 7;
localparam    COM3A0_bit = 6;
localparam    COM3B1_bit = 5;
localparam    COM3B0_bit = 4;
localparam    COM3C1_bit = 3;
localparam    COM3C0_bit = 2;
localparam    WGM31_bit  = 1;
localparam    WGM30_bit  = 0;

// Timer/Counter 3 Control Register B 
localparam    ICNC3_bit = 7;
localparam    ICES3_bit = 6;
localparam    WGM33_bit = 4;
localparam    WGM32_bit = 3;
localparam    CS32_bit  = 2;
localparam    CS31_bit  = 1;
localparam    CS30_bit  = 0;

// Extended Timer/Counter Interrupt Mask Register 
localparam    TICIE3_bit = 5;
localparam    OCIE3A_bit = 4;
localparam    OCIE3B_bit = 3;
localparam    TOIE3_bit  = 2;
localparam    OCIE3C_bit = 1;
localparam    OCIE1C_bit = 0;

// Extended Timer/Counter Interrupt Flag Register 
localparam    ICF3_bit  = 5;
localparam    OCF3A_bit = 4;
localparam    OCF3B_bit = 3;
localparam    TOV3_bit  = 2;
localparam    OCF3C_bit = 1;
localparam    OCF1C_bit = 0;

// TWI Control Register 
localparam    TWINT_bit = 7;
localparam    TWEA_bit  = 6;
localparam    TWSTA_bit = 5;
localparam    TWSTO_bit = 4;
localparam    TWWC_bit  = 3;
localparam    TWEN_bit  = 2;
localparam    TWIE_bit  = 0;

// TWI (slave) Address Register 
localparam    TWA6_bit  = 7;
localparam    TWA5_bit  = 6;
localparam    TWA4_bit  = 5;
localparam    TWA3_bit  = 4;
localparam    TWA2_bit  = 3;
localparam    TWA1_bit  = 2;
localparam    TWA0_bit  = 1;
localparam    TWGCE_bit = 0;

// TWI Status Register 
localparam    TWS7_bit  = 7;
localparam    TWS6_bit  = 6;
localparam    TWS5_bit  = 5;
localparam    TWS4_bit  = 4;
localparam    TWS3_bit  = 3;
localparam    TWPS1_bit = 1;
localparam    TWPS0_bit = 0;

// External Memory Control Register A 
localparam    SRL2_bit  = 6;
localparam    SRL1_bit  = 5;
localparam    SRL0_bit  = 4;
localparam    SRW01_bit = 3;
localparam    SRW00_bit = 2;
localparam    SRW11_bit = 1;

// External Memory Control Register B 
localparam    XMBK_bit  = 7; 
localparam    XMM2_bit  = 2;
localparam    XMM1_bit  = 1;
localparam    XMM0_bit  = 0;

// External Interrupt Control Register A 
localparam    ISC31_bit = 7;
localparam    ISC30_bit = 6;
localparam    ISC21_bit = 5;
localparam    ISC20_bit = 4;
localparam    ISC11_bit = 3;
localparam    ISC10_bit = 2;
localparam    ISC01_bit = 1;
localparam    ISC00_bit = 0;

// Store Program Memory Control and Status Register 
localparam    SPMIE_bit  = 7;
localparam    RWWSB_bit  = 6;
localparam    RWWSRE_bit = 4;
localparam    BLBSET_bit = 3;
localparam    PGWRT_bit  = 2;
localparam    PGERS_bit  = 1;
localparam    SPMEN_bit  = 0;

// Data Register, Port G 
localparam    PG4_bit = 4;
localparam    PG3_bit = 3;
localparam    PG2_bit = 2;
localparam    PG1_bit = 1;
localparam    PG0_bit = 0;

 // Data Register, Port G 
localparam    PORTG4_bit =  4;
localparam    PORTG3_bit =  3;
localparam    PORTG2_bit =  2;
localparam    PORTG1_bit =  1;
localparam    PORTG0_bit =  0;

// Data Direction Register, Port G 
localparam    DDG4_bit = 4;
localparam    DDG3_bit = 3;
localparam    DDG2_bit = 2;
localparam    DDG1_bit = 1;
localparam    DDG0_bit = 0;

// Input Pins, Port G 
localparam    PING4_bit = 4;
localparam    PING3_bit = 3;
localparam    PING2_bit = 2;
localparam    PING1_bit = 1;
localparam    PING0_bit = 0;

// Data Register, Port F 
localparam    PF7_bit = 7;
localparam    PF6_bit = 6;
localparam    PF5_bit = 5;
localparam    PF4_bit = 4;
localparam    PF3_bit = 3;
localparam    PF2_bit = 2;
localparam    PF1_bit = 1;
localparam    PF0_bit = 0;
 
// Data Register, Port F 
localparam    PORTF7_bit = 7;
localparam    PORTF6_bit = 6;
localparam    PORTF5_bit = 5;
localparam    PORTF4_bit = 4;
localparam    PORTF3_bit = 3;
localparam    PORTF2_bit = 2;
localparam    PORTF1_bit = 1;
localparam    PORTF0_bit = 0;
 
// Data Direction Register, Port F 
localparam    DDF7_bit = 7;
localparam    DDF6_bit = 6;
localparam    DDF5_bit = 5;
localparam    DDF4_bit = 4;
localparam    DDF3_bit = 3;
localparam    DDF2_bit = 2;
localparam    DDF1_bit = 1;
localparam    DDF0_bit = 0;
 
// Input Pins, Port F 
localparam    PINF7_bit = 7;
localparam    PINF6_bit = 6;
localparam    PINF5_bit = 5;
localparam    PINF4_bit = 4;
localparam    PINF3_bit = 3;
localparam    PINF2_bit = 2;
localparam    PINF1_bit = 1;
localparam    PINF0_bit = 0;

// Stack Pointer High 
localparam    SP15_bit = 7;
localparam    SP14_bit = 6;
localparam    SP13_bit = 5;
localparam    SP12_bit = 4;
localparam    SP11_bit = 3;
localparam    SP10_bit = 2;
localparam    SP9_bit = 1;
localparam    SP8_bit = 0;

// Stack Pointer Low 
localparam    SP7_bit = 7;
localparam    SP6_bit = 6;
localparam    SP5_bit = 5;
localparam    SP4_bit = 4;
localparam    SP3_bit = 3;
localparam    SP2_bit = 2;
localparam    SP1_bit = 1;
localparam    SP0_bit = 0;

// XTAL Divide Control Register 
localparam    XDIVEN_bit = 7;
localparam    XDIV6_bit  = 6;
localparam    XDIV5_bit  = 5;
localparam    XDIV4_bit  = 4;
localparam    XDIV3_bit  = 3;
localparam    XDIV2_bit  = 2;
localparam    XDIV1_bit  = 1;
localparam    XDIV0_bit  = 0;

// RAM Page Z Select Register 
localparam    RAMPZ0_bit = 0;

// External Interrupt Control Register B 
localparam    ISC71_bit = 7;
localparam    ISC70_bit = 6;
localparam    ISC61_bit = 5;
localparam    ISC60_bit = 4;
localparam    ISC51_bit = 3;
localparam    ISC50_bit = 2;
localparam    ISC41_bit = 1;
localparam    ISC40_bit = 0;

// External Interrupt Mask Register 
localparam    INT7_bit = 7;
localparam    INT6_bit = 6;
localparam    INT5_bit = 5;
localparam    INT4_bit = 4;
localparam    INT3_bit = 3;
localparam    INT2_bit = 2;
localparam    INT1_bit = 1;
localparam    INT0_bit = 0;

// External Interrupt Flag Register 
localparam    INTF7_bit = 7;
localparam    INTF6_bit = 6;
localparam    INTF5_bit = 5;
localparam    INTF4_bit = 4;
localparam    INTF3_bit = 3;
localparam    INTF2_bit = 2;
localparam    INTF1_bit = 1;
localparam    INTF0_bit = 0;

// Timer/Counter Interrupt Mask Register 
localparam    OCIE2_bit  = 7;
localparam    TOIE2_bit  = 6;
localparam    TICIE1_bit = 5;
localparam    OCIE1A_bit = 4;
localparam    OCIE1B_bit = 3;
localparam    TOIE1_bit  = 2;
localparam    OCIE0_bit  = 1;
localparam    TOIE0_bit  = 0;

// Timer/Counter Interrupt Flag Register 
localparam    OCF2_bit  = 7;
localparam    TOV2_bit  = 6;
localparam    ICF1_bit  = 5;
localparam    OCF1A_bit = 4;
localparam    OCF1B_bit = 3;
localparam    TOV1_bit  = 2;
localparam    OCF0_bit  = 1;
localparam    TOV0_bit  = 0;


// MCU general Control Register 
localparam    SRE_bit   = 7;
localparam    SRW10_bit = 6;
localparam    SE_bit    = 5;
localparam    SM1_bit   = 4;
localparam    SM0_bit   = 3;
localparam    SM2_bit   = 2;
localparam    IVSEL_bit = 1;
localparam    IVCE_bit  = 0;

// MCU general Control and Status Register 
localparam    JTD_bit   = 7;
localparam    JTRF_bit  = 4;
localparam    WDRF_bit  = 3;
localparam    BORF_bit  = 2;
localparam    EXTRF_bit = 1;
localparam    PORF_bit  = 0;

// Timer/Counter 0 Control Register 
localparam    FOC0_bit  = 7;
localparam    WGM00_bit = 6;
localparam    COM01_bit = 5;
localparam    COM00_bit = 4;
localparam    WGM01_bit = 3;
localparam    CS02_bit  = 2;
localparam    CS01_bit  = 1;
localparam    CS00_bit  = 0;

// Asynchronous mode Status Register 
localparam    AS0_bit    = 3;
localparam    TCN0UB_bit = 2;
localparam    OCR0UB_bit = 1;
localparam    TCR0UB_bit = 0;

// Timer/Counter 1 Control Register C 
localparam    FOC1A_bit = 7;
localparam    FOC1B_bit = 6;
localparam    FOC1C_bit = 5;

// Timer/Counter 1 Control Register A 
localparam    COM1A1_bit = 7;
localparam    COM1A0_bit = 6;
localparam    COM1B1_bit = 5;
localparam    COM1B0_bit = 4;
localparam    COM1C1_bit = 3;
localparam    COM1C0_bit = 2;
localparam    WGM11_bit  = 1;
localparam    WGM10_bit  = 0;

// Timer/Counter 1 Control Register B 
localparam    ICNC1_bit = 7;
localparam    ICES1_bit = 6;
localparam    WGM13_bit = 4;
localparam    WGM12_bit = 3;
localparam    CS12_bit  = 2;
localparam    CS11_bit  = 1;
localparam    CS10_bit  = 0;

// Timer/Counter 2 Control Register 
localparam    FOC2_bit  = 7;
localparam    WGM20_bit = 6;
localparam    COM21_bit = 5;
localparam    COM20_bit = 4;
localparam    WGM21_bit = 3;
localparam    CS22_bit  = 2;
localparam    CS21_bit  = 1;
localparam    CS20_bit  = 0;

// On-Chip Debug Register 
localparam    IDRD_bit  = 7;
localparam    OCDR7_bit = 7;
localparam    OCDR6_bit = 6;
localparam    OCDR5_bit = 5;
localparam    OCDR4_bit = 4;
localparam    OCDR3_bit = 3;
localparam    OCDR2_bit = 2;
localparam    OCDR1_bit = 1;
localparam    OCDR0_bit = 0;

// Watchdog Timer Control Register 
localparam    WDCE_bit  = 4;
localparam    WDE_bit   = 3;
localparam    WDP2_bit  = 2;
localparam    WDP1_bit  = 1;
localparam    WDP0_bit  = 0;

// Special Function I/O Register 
localparam    TSM_bit    = 7;
localparam    ADHSM_bit  = 4;
localparam    ACME_bit   = 3;
localparam    PUD_bit    = 2;
localparam    PSR0_bit   = 1;
localparam    PSR321_bit = 0;

// EEPROM Control Register 
localparam    EERIE_bit = 3;
localparam    EEMWE_bit = 2;
localparam    EEWE_bit  = 1;
localparam    EERE_bit  = 0;

// Data Register, Port A 
localparam    PA7_bit = 7;
localparam    PA6_bit = 6;
localparam    PA5_bit = 5;
localparam    PA4_bit = 4;
localparam    PA3_bit = 3;
localparam    PA2_bit = 2;
localparam    PA1_bit = 1;
localparam    PA0_bit = 0;
 
// Data Register, Port A 
localparam    PORTA7_bit = 7;
localparam    PORTA6_bit = 6;
localparam    PORTA5_bit = 5;
localparam    PORTA4_bit = 4;
localparam    PORTA3_bit = 3;
localparam    PORTA2_bit = 2;
localparam    PORTA1_bit = 1;
localparam    PORTA0_bit = 0;
 
// Data Direction Register, Port A 
localparam    DDA7_bit = 7;
localparam    DDA6_bit = 6;
localparam    DDA5_bit = 5;
localparam    DDA4_bit = 4;
localparam    DDA3_bit = 3;
localparam    DDA2_bit = 2;
localparam    DDA1_bit = 1;
localparam    DDA0_bit = 0;
 
// Input Pins, Port A 
localparam    PINA7_bit = 7;
localparam    PINA6_bit = 6;
localparam    PINA5_bit = 5;
localparam    PINA4_bit = 4;
localparam    PINA3_bit = 3;
localparam    PINA2_bit = 2;
localparam    PINA1_bit = 1;
localparam    PINA0_bit = 0;

// Data Register, Port B 
localparam    PB7_bit = 7;
localparam    PB6_bit = 6;
localparam    PB5_bit = 5;
localparam    PB4_bit = 4;
localparam    PB3_bit = 3;
localparam    PB2_bit = 2;
localparam    PB1_bit = 1;
localparam    PB0_bit = 0;
 
// Data Register, Port B 
localparam    PORTB7_bit = 7;
localparam    PORTB6_bit = 6;
localparam    PORTB5_bit = 5;
localparam    PORTB4_bit = 4;
localparam    PORTB3_bit = 3;
localparam    PORTB2_bit = 2;
localparam    PORTB1_bit = 1;
localparam    PORTB0_bit = 0;
 
// Data Direction Register, Port B 
localparam    DDB7_bit = 7;
localparam    DDB6_bit = 6;
localparam    DDB5_bit = 5;
localparam    DDB4_bit = 4;
localparam    DDB3_bit = 3;
localparam    DDB2_bit = 2;
localparam    DDB1_bit = 1;
localparam    DDB0_bit = 0;
 
// Input Pins, Port B 
localparam    PINB7_bit = 7;
localparam    PINB6_bit = 6;
localparam    PINB5_bit = 5;
localparam    PINB4_bit = 4;
localparam    PINB3_bit = 3;
localparam    PINB2_bit = 2;
localparam    PINB1_bit = 1;
localparam    PINB0_bit = 0;

// Data Register, Port C 
localparam    PC7_bit = 7;
localparam    PC6_bit = 6;
localparam    PC5_bit = 5;
localparam    PC4_bit = 4;
localparam    PC3_bit = 3;
localparam    PC2_bit = 2;
localparam    PC1_bit = 1;
localparam    PC0_bit = 0;
 
// Data Register, Port C 
localparam    PORTC7_bit = 7;
localparam    PORTC6_bit = 6;
localparam    PORTC5_bit = 5;
localparam    PORTC4_bit = 4;
localparam    PORTC3_bit = 3;
localparam    PORTC2_bit = 2;
localparam    PORTC1_bit = 1;
localparam    PORTC0_bit = 0;
 
// Data Direction Register, Port C 
localparam    DDC7_bit = 7;
localparam    DDC6_bit = 6;
localparam    DDC5_bit = 5;
localparam    DDC4_bit = 4;
localparam    DDC3_bit = 3;
localparam    DDC2_bit = 2;
localparam    DDC1_bit = 1;
localparam    DDC0_bit = 0;
 
// Input Pins, Port C 
localparam    PINC7_bit = 7;
localparam    PINC6_bit = 6;
localparam    PINC5_bit = 5;
localparam    PINC4_bit = 4;
localparam    PINC3_bit = 3;
localparam    PINC2_bit = 2;
localparam    PINC1_bit = 1;
localparam    PINC0_bit = 0;

// Data Register, Port D 
localparam    PD7_bit = 7;
localparam    PD6_bit = 6;
localparam    PD5_bit = 5;
localparam    PD4_bit = 4;
localparam    PD3_bit = 3;
localparam    PD2_bit = 2;
localparam    PD1_bit = 1;
localparam    PD0_bit = 0;
 
// Data Register, Port D 
localparam    PORTD7_bit = 7;
localparam    PORTD6_bit = 6;
localparam    PORTD5_bit = 5;
localparam    PORTD4_bit = 4;
localparam    PORTD3_bit = 3;
localparam    PORTD2_bit = 2;
localparam    PORTD1_bit = 1;
localparam    PORTD0_bit = 0;
 
// Data Direction Register, Port D 
localparam    DDD7_bit = 7;
localparam    DDD6_bit = 6;
localparam    DDD5_bit = 5;
localparam    DDD4_bit = 4;
localparam    DDD3_bit = 3;
localparam    DDD2_bit = 2;
localparam    DDD1_bit = 1;
localparam    DDD0_bit = 0;
 
// Input Pins, Port D 
localparam    PIND7_bit = 7;
localparam    PIND6_bit = 6;
localparam    PIND5_bit = 5;
localparam    PIND4_bit = 4;
localparam    PIND3_bit = 3;
localparam    PIND2_bit = 2;
localparam    PIND1_bit = 1;
localparam    PIND0_bit = 0;

// SPI Status Register 
localparam    SPIF_bit  = 7;
localparam    WCOL_bit  = 6;
localparam    SPI2X_bit = 0;

// SPI Control Register 
localparam    SPIE_bit = 7;
localparam    SPE_bit  = 6;
localparam    DORD_bit = 5;
localparam    MSTR_bit = 4;
localparam    CPOL_bit = 3;
localparam    CPHA_bit = 2;
localparam    SPR1_bit = 1;
localparam    SPR0_bit = 0;

// Analog Comparator Control and Status Register 
localparam    ACD_bit   = 7;
localparam    ACBG_bit  = 6;
localparam    ACO_bit   = 5;
localparam    ACI_bit   = 4;
localparam    ACIE_bit  = 3;
localparam    ACIC_bit  = 2;
localparam    ACIS1_bit = 1;
localparam    ACIS0_bit = 0;

// ADC Multiplexer Selection Register 
localparam    REFS1_bit = 7;
localparam    REFS0_bit = 6;
localparam    ADLAR_bit = 5;
localparam    MUX4_bit  = 4;
localparam    MUX3_bit  = 3;
localparam    MUX2_bit  = 2;
localparam    MUX1_bit  = 1;
localparam    MUX0_bit  = 0;

// ADC Control and Status Register 
localparam    ADEN_bit  = 7;
localparam    ADSC_bit  = 6;
localparam    ADFR_bit  = 5;
localparam    ADIF_bit  = 4;
localparam    ADIE_bit  = 3;
localparam    ADPS2_bit = 2;
localparam    ADPS1_bit = 1;
localparam    ADPS0_bit = 0;

// Data Register, Port E 
localparam    PE7_bit = 7;
localparam    PE6_bit = 6;
localparam    PE5_bit = 5;
localparam    PE4_bit = 4;
localparam    PE3_bit = 3;
localparam    PE2_bit = 2;
localparam    PE1_bit = 1;
localparam    PE0_bit = 0;
 
// Data Register, Port E 
localparam    PORTE7_bit = 7;
localparam    PORTE6_bit = 6;
localparam    PORTE5_bit = 5;
localparam    PORTE4_bit = 4;
localparam    PORTE3_bit = 3;
localparam    PORTE2_bit = 2;
localparam    PORTE1_bit = 1;
localparam    PORTE0_bit = 0;
 
// Data Direction Register, Port E 
localparam    DDE7_bit = 7;
localparam    DDE6_bit = 6;
localparam    DDE5_bit = 5;
localparam    DDE4_bit = 4;
localparam    DDE3_bit = 3;
localparam    DDE2_bit = 2;
localparam    DDE1_bit = 1;
localparam    DDE0_bit = 0;
 
// Input Pins, Port E 
localparam    PINE7_bit = 7;
localparam    PINE6_bit = 6;
localparam    PINE5_bit = 5;
localparam    PINE4_bit = 4;
localparam    PINE3_bit = 3;
localparam    PINE2_bit = 2;
localparam    PINE1_bit = 1;
localparam    PINE0_bit = 0;	

// end bit_def_pack;
