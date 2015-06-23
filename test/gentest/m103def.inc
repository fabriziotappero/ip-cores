;***************************************************************************
;* A P P L I C A T I O N   N O T E   F O R   T H E   A V R   F A M I L Y
;* 
;* Number		:AVR000
;* File Name		:"m103def.inc"
;* Title		:Register/Bit Definitions for the ATmega103
;* Date                 :99.01.28
;* Version              :1.30
;* Support telephone	:+47 72 88 43 88 (ATMEL Norway)
;* Support fax		:+47 72 88 43 99 (ATMEL Norway)
;* Support E-mail	:avr@atmel.com
;* Target MCU		:ATmega103
;*
;* DESCRIPTION
;* When including this file in the assembly program file, all I/O register	
;* names and I/O register bit names appearing in the data book can be used.
;* In addition, the six registers forming the three data pointers X, Y and
;* Z have been assigned names XL - ZH. Highest RAM address for Internal 
;* SRAM is also defined 
;*
;* The Register names are represented by their hexadecimal address.
;* 
;* The Register Bit names are represented by their bit number (0-7).
;* 
;* Please observe the difference in using the bit names with instructions
;* such as "sbr"/"cbr" (set/clear bit in register) and "sbrs"/"sbrc" 
;* (skip if bit in register set/cleared). The following example illustrates
;* this:
;* 
;* in	r16,PORTB		;read PORTB latch
;* sbr	r16,(1<<PB6)+(1<<PB5)	;set PB6 and PB5 (use masks, not bit#)
;* out  PORTB,r16		;output to PORTB
;*
;* in	r16,TIFR		;read the Timer Interrupt Flag Register
;* sbrc	r16,TOV0		;test the overflow flag (use bit#)
;* rjmp	TOV0_is_set		;jump if set
;* ...				;otherwise do something else
;***************************************************************************

;***** Specify Device
.device ATmega103

;***** I/O Register Definitions
.equ	SREG	=$3f
.equ	SPH	=$3e
.equ	SPL	=$3d
.equ    XDIV	=$3c
.equ    RAMPZ   =$3b
.equ    EICR    =$3a
.equ	EIMSK	=$39
.equ	EIFR	=$38
.equ	TIMSK	=$37
.equ	TIFR	=$36
.equ	MCUCR	=$35
.equ    MCUSR   =$34

.equ	TCCR0	=$33
.equ	TCNT0	=$32
.equ	OCR0	=$31
.equ    ASSR0   =$30

.equ	TCCR1A	=$2f
.equ	TCCR1B	=$2e
.equ	TCNT1H	=$2d
.equ	TCNT1L	=$2c
.equ	OCR1AH	=$2b
.equ	OCR1AL	=$2a
.equ	OCR1BH	=$29
.equ	OCR1BL	=$28
.equ	ICR1H	=$27
.equ	ICR1L	=$26

.equ    TCCR2   =$25
.equ    TCNT2   =$24
.equ    OCR2    =$23
.equ	WDTCR	=$21

.equ	EEARH	=$1f
.equ	EEARL	=$1e
.equ	EEDR	=$1d
.equ	EECR	=$1c

.equ	PORTA	=$1b
.equ	DDRA	=$1a
.equ	PINA	=$19
.equ	PORTB	=$18
.equ	DDRB	=$17
.equ	PINB	=$16
.equ	PORTC	=$15
.equ	PORTD	=$12
.equ	DDRD	=$11
.equ	PIND	=$10

.equ	SPDR	=$0f
.equ	SPSR	=$0e
.equ	SPCR	=$0d
.equ	UDR	=$0c
.equ	USR	=$0b
.equ	UCR	=$0a
.equ	UBRR	=$09
.equ	ACSR	=$08
.equ    ADMUX   =$07
.equ    ADCSR   =$06
.equ    ADCH    =$05
.equ    ADCL    =$04
.equ    PORTE   =$03
.equ    DDRE    =$02
.equ    PINE    =$01
.equ    PINF    =$00

;***** Bit Definitions

.equ 	RAMPZ0	=0

.equ	SRE	=7
.equ	SRW	=6
.equ	SE	=5
.equ	SM1	=4
.equ	SM0	=3

.equ	XDIVEN	=7
.equ	XDIV6	=6
.equ	XDIV5	=5
.equ	XDIV4	=4
.equ	XDIV3	=3
.equ	XDIV2	=2
.equ	XDIV1	=1
.equ	XDIV0	=0

.equ	EXTRF	=1
.equ	PORF	=0

.equ	INT7	=7
.equ	INT6	=6
.equ	INT5	=5
.equ	INT4	=4
.equ	INT3	=3
.equ	INT2	=2
.equ	INT1	=1
.equ	INT0	=0

.equ	INTF7	=7
.equ	INTF6	=6
.equ	INTF5	=5
.equ	INTF4	=4

.equ	ISC71	=7
.equ	ISC70	=6
.equ	ISC61	=5
.equ	ISC60	=4
.equ	ISC51	=3
.equ	ISC50	=2
.equ	ISC41	=1
.equ	ISC40	=0

.equ	OCIE2	=7
.equ	TOIE2	=6
.equ	TICIE1	=5
.equ	OCIE1A	=4
.equ	OCIE1B	=3
.equ	TOIE1	=2
.equ	OCIE0	=1
.equ	TOIE0	=0

.equ	OCF2	=7
.equ	TOV2	=6
.equ	ICF1	=5
.equ	OCF1A	=4
.equ	OCF1B	=3
.equ	TOV1	=2
.equ	OCF0	=1
.equ	TOV0	=0

.equ    PWM0    =6
.equ	COM01	=5
.equ	COM00	=4
.equ	CTC0	=3
.equ	CS02	=2
.equ	CS01	=1
.equ	CS00	=0

.equ    PWM2    =6
.equ	COM21	=5
.equ	COM20	=4
.equ	CTC2	=3
.equ	CS22	=2
.equ	CS21	=1
.equ	CS20	=0

.equ	AS0	=3
.equ	TCN0UB	=2
.equ	OCR0UB	=1
.equ	TCR0UB	=0

.equ	COM1A1	=7
.equ	COM1A0	=6
.equ	COM1B1	=5
.equ	COM1B0	=4
.equ	PWM11	=1
.equ	PWM10	=0

.equ	ICNC1	=7
.equ	ICES1	=6
.equ	CTC1	=3
.equ	CS12	=2
.equ	CS11	=1
.equ	CS10	=0

.equ	WDTOE	=4
.equ	WDE	=3
.equ	WDP2	=2
.equ	WDP1	=1
.equ	WDP0	=0

.equ    EERIE	=3
.equ	EEMWE	=2
.equ	EEWE	=1
.equ	EERE	=0

.equ	PA7	=7
.equ	PA6	=6
.equ	PA5	=5
.equ	PA4	=4
.equ	PA3	=3
.equ	PA2	=2
.equ	PA1	=1
.equ	PA0	=0

.equ	PINA7	=7
.equ	PINA6	=6
.equ	PINA5	=5
.equ	PINA4	=4
.equ	PINA3	=3
.equ	PINA2	=2
.equ	PINA1	=1
.equ	PINA0	=0

.equ	DDA7	=7
.equ	DDA6	=6
.equ	DDA5	=5
.equ	DDA4	=4
.equ	DDA3	=3
.equ	DDA2	=2
.equ	DDA1	=1
.equ	DDA0	=0

.equ	PB7	=7
.equ	PB6	=6
.equ	PB5	=5
.equ	PB4	=4
.equ	PB3	=3
.equ	PB2	=2
.equ	PB1	=1
.equ	PB0	=0

.equ	DDB7	=7
.equ	DDB6	=6
.equ	DDB5	=5
.equ	DDB4	=4
.equ	DDB3	=3
.equ	DDB2	=2
.equ	DDB1	=1
.equ	DDB0	=0

.equ	PINB7	=7
.equ	PINB6	=6
.equ	PINB5	=5
.equ	PINB4	=4
.equ	PINB3	=3
.equ	PINB2	=2
.equ	PINB1	=1
.equ	PINB0	=0

.equ	PC7	=7
.equ	PC6	=6
.equ	PC5	=5
.equ	PC4	=4
.equ	PC3	=3
.equ	PC2	=2
.equ	PC1	=1
.equ	PC0	=0

.equ	PD7	=7
.equ	PD6	=6
.equ	PD5	=5
.equ	PD4	=4
.equ	PD3	=3
.equ	PD2	=2
.equ	PD1	=1
.equ	PD0	=0

.equ	DDD7	=7
.equ	DDD6	=6
.equ	DDD5	=5
.equ	DDD4	=4
.equ	DDD3	=3
.equ	DDD2	=2
.equ	DDD1	=1
.equ	DDD0	=0

.equ	PIND7	=7
.equ	PIND6	=6
.equ	PIND5	=5
.equ	PIND4	=4
.equ	PIND3	=3
.equ	PIND2	=2
.equ	PIND1	=1
.equ	PIND0	=0

.equ	PE7	=7
.equ	PE6	=6
.equ	PE5	=5
.equ	PE4	=4
.equ	PE3	=3
.equ	PE2	=2
.equ	PE1	=1
.equ	PE0	=0

.equ	DDE7	=7
.equ	DDE6	=6
.equ	DDE5	=5
.equ	DDE4	=4
.equ	DDE3	=3
.equ	DDE2	=2
.equ	DDE1	=1
.equ	DDE0	=0

.equ	PINE7	=7
.equ	PINE6	=6
.equ	PINE5	=5
.equ	PINE4	=4
.equ	PINE3	=3
.equ	PINE2	=2
.equ	PINE1	=1
.equ	PINE0	=0

.Equ	PINF7	=7
.Equ	PINF6	=6
.Equ	PINF5	=5
.Equ	PINF4	=4
.Equ	PINF3	=3
.Equ	PINF2	=2
.Equ	PINF1	=1
.Equ	PINF0	=0

.equ	SPIE	=7
.equ	SPE	=6
.equ	DORD	=5
.equ	MSTR	=4
.equ	CPOL	=3
.equ	CPHA	=2
.equ	SPR1	=1
.equ	SPR0	=0

.equ	SPIF	=7
.equ	WCOL	=6

.equ	RXC	=7
.equ	TXC	=6
.equ	UDRE	=5
.equ	FE	=4
.equ	OR	=3

.equ	RXCIE	=7
.equ	TXCIE	=6
.equ	UDRIE	=5
.equ	RXEN	=4
.equ	TXEN	=3
.equ	CHR9	=2
.equ	RXB8	=1
.equ	TXB8	=0

.equ	ACD	=7
.equ	ACO	=5
.equ	ACI	=4
.equ	ACIE	=3
.equ	ACIC	=2
.equ	ACIS1	=1
.equ	ACIS0	=0

.equ	ADEN	=7
.equ	ADSC	=6
.equ	ADFR	=5
.equ	ADIF	=4
.equ	ADIE	=3
.equ	ADPS2	=2
.equ	ADPS1	=1
.equ	ADPS0	=0

.equ	MUX2	=2
.equ	MUX1	=1
.equ	MUX0	=0

.def	XL	=r26
.def	XH	=r27
.def	YL	=r28
.def	YH	=r29
.def	ZL	=r30
.def	ZH	=r31

.equ 	RAMEND 	=$0FFF	;Last On-Chip SRAM Location
.equ	XRAMEND =$FFFF
.equ	E2END	=$0FFF
.equ	FLASHEND=$FFFF

.equ	INT0addr=$002	;External Interrupt0 Vector Address
.equ	INT1addr=$004	;External Interrupt1 Vector Address
.equ	INT2addr=$006	;External Interrupt2 Vector Address
.equ	INT3addr=$008	;External Interrupt3 Vector Address
.equ	INT4addr=$00a	;External Interrupt4 Vector Address
.equ	INT5addr=$00c	;External Interrupt5 Vector Address
.equ	INT6addr=$00e	;External Interrupt6 Vector Address
.equ	INT7addr=$010	;External Interrupt7 Vector Address
.equ	OC2addr =$012	;Output Compare2 Interrupt Vector Address
.equ	OVF2addr=$014	;Overflow2 Interrupt Vector Address
.equ	ICP1addr=$016	;Input Capture1 Interrupt Vector Address
.equ	OC1Aaddr=$018	;Output Compare1A Interrupt Vector Address
.equ	OC1Baddr=$01a	;Output Compare1B Interrupt Vector Address
.equ	OVF1addr=$01c	;Overflow1 Interrupt Vector Address
.equ	OC0addr =$01e	;Output Compare0 Interrupt Vector Address
.equ	OVF0addr=$020	;Overflow0 Interrupt Vector Address
.equ	SPIaddr =$022	;SPI Interrupt Vector Address
.equ	URXCaddr=$024	;UART Receive Complete Interrupt Vector Address
.equ	UDREaddr=$026	;UART Data Register Empty Interrupt Vector Address
.equ	UTXCaddr=$028	;UART Transmit Complete Interrupt Vector Address
.equ    ADCCaddr=$02a   ;ADC Conversion Complete Handle
.equ    EEWRaddr=$02c   ;EEPROM Write Complete Handle
.equ	ACIaddr =$02e	;Analog Comparator Interrupt Vector Address

