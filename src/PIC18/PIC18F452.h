// ***************************************
// BoostC Header file for PIC18F452
// Author(s): David Hobday
//
// Copyright (C) 2003-2005 Pavel Baranov
// Copyright (C) 2003-2005 David Hobday
// All Rights Reserved
// ***************************************


// ***************************************
// W and F definitions
// ***************************************
#define W                     0x0000
#define F                     0x0001


////////////////////////////////////////////////////////////////////////////
//
//       Register Definitions
//
////////////////////////////////////////////////////////////////////////////

//----- Register Files -----------------------------------------------------

#define TOSU                  0x00000FFF 
#define TOSH                  0x00000FFE 
#define TOSL                  0x00000FFD 
#define STKPTR                0x00000FFC 
#define PCLATU                0x00000FFB 
#define PCLATH                0x00000FFA 
#define PCL                   0x00000FF9 
#define TBLPTRU               0x00000FF8 
#define TBLPTRH               0x00000FF7 
#define TBLPTRL               0x00000FF6 
#define TABLAT                0x00000FF5 
#define PRODH                 0x00000FF4 
#define PRODL                 0x00000FF3 
#define INTCON                0x00000FF2 
#define INTCON1               0x00000FF2 
#define INTCON2               0x00000FF1 
#define INTCON3               0x00000FF0 
#define INDF0                 0x00000FEF 
#define POSTINC0              0x00000FEE 
#define POSTDEC0              0x00000FED 
#define PREINC0               0x00000FEC 
#define PLUSW0                0x00000FEB 
#define FSR0H                 0x00000FEA 
#define FSR0L                 0x00000FE9 
#define WREG                  0x00000FE8 
#define INDF1                 0x00000FE7 
#define POSTINC1              0x00000FE6 
#define POSTDEC1              0x00000FE5 
#define PREINC1               0x00000FE4 
#define PLUSW1                0x00000FE3 
#define FSR1H                 0x00000FE2 
#define FSR1L                 0x00000FE1 
#define BSR                   0x00000FE0 
#define INDF2                 0x00000FDF 
#define POSTINC2              0x00000FDE 
#define POSTDEC2              0x00000FDD 
#define PREINC2               0x00000FDC 
#define PLUSW2                0x00000FDB 
#define FSR2H                 0x00000FDA 
#define FSR2L                 0x00000FD9 
#define STATUS                0x00000FD8 
#define TMR0H                 0x00000FD7 
#define TMR0L                 0x00000FD6 
#define T0CON                 0x00000FD5 
#define OSCCON                0x00000FD3 
#define LVDCON                0x00000FD2 
#define WDTCON                0x00000FD1 
#define RCON                  0x00000FD0 
#define TMR1H                 0x00000FCF 
#define TMR1L                 0x00000FCE 
#define T1CON                 0x00000FCD 
#define TMR2                  0x00000FCC 
#define PR2                   0x00000FCB 
#define T2CON                 0x00000FCA 
#define SSPBUF                0x00000FC9 
#define SSPADD                0x00000FC8 
#define SSPSTAT               0x00000FC7 
#define SSPCON1               0x00000FC6 
#define SSPCON2               0x00000FC5 
#define ADRESH                0x00000FC4 
#define ADRESL                0x00000FC3 
#define ADCON0                0x00000FC2 
#define ADCON1                0x00000FC1 
#define CCPR1H                0x00000FBF 
#define CCPR1L                0x00000FBE 
#define CCP1CON               0x00000FBD 
#define CCPR2H                0x00000FBC 
#define CCPR2L                0x00000FBB 
#define CCP2CON               0x00000FBA 
#define TMR3H                 0x00000FB3 
#define TMR3L                 0x00000FB2 
#define T3CON                 0x00000FB1 
#define SPBRG                 0x00000FAF 
#define RCREG                 0x00000FAE 
#define TXREG                 0x00000FAD 
#define TXSTA                 0x00000FAC 
#define RCSTA                 0x00000FAB 
#define EEADR                 0x00000FA9 
#define EEDATA                0x00000FA8 
#define EECON2                0x00000FA7 
#define EECON1                0x00000FA6 
#define IPR2                  0x00000FA2 
#define PIR2                  0x00000FA1 
#define PIE2                  0x00000FA0 
#define IPR1                  0x00000F9F 
#define PIR1                  0x00000F9E 
#define PIE1                  0x00000F9D 
#define TRISE                 0x00000F96 
#define TRISD                 0x00000F95 
#define TRISC                 0x00000F94 
#define TRISB                 0x00000F93 
#define TRISA                 0x00000F92 
#define LATE                  0x00000F8D 
#define LATD                  0x00000F8C 
#define LATC                  0x00000F8B 
#define LATB                  0x00000F8A 
#define LATA                  0x00000F89 
#define PORTE                 0x00000F84 
#define PORTD                 0x00000F83 
#define PORTC                 0x00000F82 
#define PORTB                 0x00000F81 
#define PORTA                 0x00000F80 

/////// STKPTR Bits ////////////////////////////////////////////////////////
#define STKFUL                0x00000007 
#define STKUNF                0x00000006 

/////// INTCON Bits ////////////////////////////////////////////////////////
#define GIE                   0x00000007 
#define GIEH                  0x00000007 
#define PEIE                  0x00000006 
#define GIEL                  0x00000006 
#define TMR0IE                0x00000005 
#define T0IE                  0x00000005 // For backward compatibility
#define INT0IE                0x00000004 
#define INT0E                 0x00000004 // For backward compatibility
#define RBIE                  0x00000003 
#define TMR0IF                0x00000002 
#define T0IF                  0x00000002 // For backward compatibility
#define INT0IF                0x00000001 
#define INT0F                 0x00000001 // For backward compatibility
#define RBIF                  0x00000000 

/////// INTCON2 Bits ////////////////////////////////////////////////////////
#define NOT_RBPU              0x00000007 
#define RBPU                  0x00000007 
#define INTEDG0               0x00000006 
#define INTEDG1               0x00000005 
#define INTEDG2               0x00000004 
#define TMR0IP                0x00000002 
#define T0IP                  0x00000002 // For compatibility with T0IE and T0IF
#define RBIP                  0x00000000 

/////// INTCON3 Bits ////////////////////////////////////////////////////////
#define INT2IP                0x00000007 
#define INT1IP                0x00000006 
#define INT2IE                0x00000004 
#define INT1IE                0x00000003 
#define INT2IF                0x00000001 
#define INT1IF                0x00000000 

/////// STATUS Bits ////////////////////////////////////////////////////////
#define N                     0x00000004 
#define OV                    0x00000003 
#define Z                     0x00000002 
#define DC                    0x00000001 
#define C                     0x00000000 

/////// T0CON Bits /////////////////////////////////////////////////////////
#define TMR0ON                0x00000007 
#define T08BIT                0x00000006 
#define T0CS                  0x00000005 
#define T0SE                  0x00000004 
#define PSA                   0x00000003 
#define T0PS2                 0x00000002 
#define T0PS1                 0x00000001 
#define T0PS0                 0x00000000 

/////// OSCCON Bits /////////////////////////////////////////////////////////
#define SCS                   0x00000000 

/////// LVDCON Bits /////////////////////////////////////////////////////////
#define IRVST                 0x00000005 
#define LVDEN                 0x00000004 
#define LVDL3                 0x00000003 
#define LVDL2                 0x00000002 
#define LVDL1                 0x00000001 
#define LVDL0                 0x00000000 

/////// WDTCON Bits /////////////////////////////////////////////////////////
#define SWDTE                 0x00000000 
#define SWDTEN                0x00000000 

/////// RCON Bits ///////////////////////////////////////////////////////////
#define IPEN                  0x00000007 
#define NOT_RI                0x00000004 
#define RI                    0x00000004 
#define NOT_TO                0x00000003 
#define TO                    0x00000003 
#define NOT_PD                0x00000002 
#define PD                    0x00000002 
#define NOT_POR               0x00000001 
#define POR                   0x00000001 
#define NOT_BOR               0x00000000 
#define BOR                   0x00000000 

/////// T1CON Bits /////////////////////////////////////////////////////////
#define RD16                  0x00000007 
#define T1CKPS1               0x00000005 
#define T1CKPS0               0x00000004 
#define T1OSCEN               0x00000003 
#define NOT_T1SYNC            0x00000002 
#define T1SYNC                0x00000002 
#define T1INSYNC              0x00000002 // For backward compatibility
#define TMR1CS                0x00000001 
#define TMR1ON                0x00000000 

/////// T2CON Bits /////////////////////////////////////////////////////////
#define TOUTPS3               0x00000006 
#define TOUTPS2               0x00000005 
#define TOUTPS1               0x00000004 
#define TOUTPS0               0x00000003 
#define TMR2ON                0x00000002 
#define T2CKPS1               0x00000001 
#define T2CKPS0               0x00000000 

/////// SSPSTAT Bits ///////////////////////////////////////////////////////
#define SMP                   0x00000007 
#define CKE                   0x00000006 
#define D                     0x00000005 
#define I2C_DAT               0x00000005 
#define NOT_A                 0x00000005 
#define NOT_ADDRESS           0x00000005 
#define D_A                   0x00000005 
#define DATA_ADDRESS          0x00000005 
#define P                     0x00000004 
#define I2C_STOP              0x00000004 
#define S                     0x00000003 
#define I2C_START             0x00000003 
#define R                     0x00000002 
#define I2C_READ              0x00000002 
#define NOT_W                 0x00000002 
#define NOT_WRITE             0x00000002 
#define R_W                   0x00000002 
#define READ_WRITE            0x00000002 
#define UA                    0x00000001 
#define BF                    0x00000000 

/////// SSPCON1 Bits ////////////////////////////////////////////////////////
#define WCOL                  0x00000007 
#define SSPOV                 0x00000006 
#define SSPEN                 0x00000005 
#define CKP                   0x00000004 
#define SSPM3                 0x00000003 
#define SSPM2                 0x00000002 
#define SSPM1                 0x00000001 
#define SSPM0                 0x00000000 

/////// SSPCON2 Bits ////////////////////////////////////////////////////////
#define GCEN                  0x00000007 
#define ACKSTAT               0x00000006 
#define ACKDT                 0x00000005 
#define ACKEN                 0x00000004 
#define RCEN                  0x00000003 
#define PEN                   0x00000002 
#define RSEN                  0x00000001 
#define SEN                   0x00000000 

/////// ADCON0 Bits ////////////////////////////////////////////////////////
#define ADCS1                 0x00000007 
#define ADCS0                 0x00000006 
#define CHS2                  0x00000005 
#define CHS1                  0x00000004 
#define CHS0                  0x00000003 
#define GO                    0x00000002 
#define NOT_DONE              0x00000002 
#define DONE                  0x00000002 
#define GO_DONE               0x00000002 
#define ADON                  0x00000000 

/////// ADCON1 Bits ////////////////////////////////////////////////////////
#define ADFM                  0x00000007 
#define ADCS2                 0x00000006 
#define PCFG3                 0x00000003 
#define PCFG2                 0x00000002 
#define PCFG1                 0x00000001 
#define PCFG0                 0x00000000 

/////// CCP1CON Bits ///////////////////////////////////////////////////////
#define DC1B1                 0x00000005 
#define CCP1X                 0x00000005 // For backward compatibility
#define DC1B0                 0x00000004 
#define CCP1Y                 0x00000004 // For backward compatibility
#define CCP1M3                0x00000003 
#define CCP1M2                0x00000002 
#define CCP1M1                0x00000001 
#define CCP1M0                0x00000000 

/////// CCP2CON Bits ///////////////////////////////////////////////////////
#define DC2B1                 0x00000005 
#define CCP2X                 0x00000005 // For backward compatibility
#define DC2B0                 0x00000004 
#define CCP2Y                 0x00000004 // For backward compatibility
#define CCP2M3                0x00000003 
#define CCP2M2                0x00000002 
#define CCP2M1                0x00000001 
#define CCP2M0                0x00000000 

/////// T3CON Bits /////////////////////////////////////////////////////////
#define RD16                  0x00000007 
#define T3CCP2                0x00000006 
#define T3CKPS1               0x00000005 
#define T3CKPS0               0x00000004 
#define T3CCP1                0x00000003 
#define NOT_T3SYNC            0x00000002 
#define T3SYNC                0x00000002 
#define T3INSYNC              0x00000002 // For backward compatibility
#define TMR3CS                0x00000001 
#define TMR3ON                0x00000000 

/////// TXSTA Bits /////////////////////////////////////////////////////////
#define CSRC                  0x00000007 
#define TX9                   0x00000006 
#define NOT_TX8               0x00000006 // For backward compatibility
#define TX8_9                 0x00000006 // For backward compatibility
#define TXEN                  0x00000005 
#define SYNC                  0x00000004 
#define BRGH                  0x00000002 
#define TRMT                  0x00000001 
#define TX9D                  0x00000000 
#define TXD8                  0x00000000 // For backward compatibility

/////// RCSTA Bits /////////////////////////////////////////////////////////
#define SPEN                  0x00000007 
#define RX9                   0x00000006 
#define RC9                   0x00000006 // For backward compatibility
#define NOT_RC8               0x00000006 // For backward compatibility
#define RC8_9                 0x00000006 // For backward compatibility
#define SREN                  0x00000005 
#define CREN                  0x00000004 
#define ADDEN                 0x00000003 
#define FERR                  0x00000002 
#define OERR                  0x00000001 
#define RX9D                  0x00000000 
#define RCD8                  0x00000000 // For backward compatibility

/////// IPR2 Bits //////////////////////////////////////////////////////////
#define EEIP                  0x00000004 
#define BCLIP                 0x00000003 
#define LVDIP                 0x00000002 
#define TMR3IP                0x00000001 
#define CCP2IP                0x00000000 

/////// PIR2 Bits //////////////////////////////////////////////////////////
#define EEIF                  0x00000004 
#define BCLIF                 0x00000003 
#define LVDIF                 0x00000002 
#define TMR3IF                0x00000001 
#define CCP2IF                0x00000000 

/////// PIE2 Bits //////////////////////////////////////////////////////////
#define EEIE                  0x00000004 
#define BCLIE                 0x00000003 
#define LVDIE                 0x00000002 
#define TMR3IE                0x00000001 
#define CCP2IE                0x00000000 

/////// IPR1 Bits //////////////////////////////////////////////////////////
#define PSPIP                 0x00000007 
#define ADIP                  0x00000006 
#define RCIP                  0x00000005 
#define TXIP                  0x00000004 
#define SSPIP                 0x00000003 
#define CCP1IP                0x00000002 
#define TMR2IP                0x00000001 
#define TMR1IP                0x00000000 

/////// PIR1 Bits //////////////////////////////////////////////////////////
#define PSPIF                 0x00000007 
#define ADIF                  0x00000006 
#define RCIF                  0x00000005 
#define TXIF                  0x00000004 
#define SSPIF                 0x00000003 
#define CCP1IF                0x00000002 
#define TMR2IF                0x00000001 
#define TMR1IF                0x00000000 

/////// PIE1 Bits //////////////////////////////////////////////////////////
#define PSPIE                 0x00000007 
#define ADIE                  0x00000006 
#define RCIE                  0x00000005 
#define TXIE                  0x00000004 
#define SSPIE                 0x00000003 
#define CCP1IE                0x00000002 
#define TMR2IE                0x00000001 
#define TMR1IE                0x00000000 

/////// TRISE Bits /////////////////////////////////////////////////////////
#define IBF                   0x00000007 
#define OBF                   0x00000006 
#define IBOV                  0x00000005 
#define PSPMODE               0x00000004 
#define TRISE2                0x00000002 
#define TRISE1                0x00000001 
#define TRISE0                0x00000000 

/////// EECON1 Bits /////////////////////////////////////////////////////////
#define EEPGD                 0x00000007 
#define CFGS                  0x00000006 
#define FREE                  0x00000004 
#define WRERR                 0x00000003 
#define WREN                  0x00000002 
#define WR                    0x00000001 
#define RD                    0x00000000 

////////////////////////////////////////////////////////////////////////////
//
//       I/O Pin Name Definitions
//
////////////////////////////////////////////////////////////////////////////

//----- PORTA ------------------------------------------------------------------

#define RA0                   0x00000000 
#define AN0                   0x00000000 
#define RA1                   0x00000001 
#define AN1                   0x00000001 
#define RA2                   0x00000002 
#define AN2                   0x00000002 
#define VREFM                 0x00000002 
#define RA3                   0x00000003 
#define AN3                   0x00000003 
#define VREFP                 0x00000003 
#define RA4                   0x00000004 
#define T0CKI                 0x00000004 
#define RA5                   0x00000005 
#define AN4                   0x00000005 
#define SS                    0x00000005 
#define LVDIN                 0x00000005 
#define RA6                   0x00000006 
#define OSC2                  0x00000006 
#define CLKO                  0x00000006 

/////// PORTB //////////////////////////////////////////////////////////////////
#define RB0                   0x00000000 
#define INT0                  0x00000000 
#define RB1                   0x00000001 
#define INT1                  0x00000001 
#define RB2                   0x00000002 
#define INT2                  0x00000002 
#define RB3                   0x00000003 
#define CCP2A                 0x00000003 
#define RB4                   0x00000004 
#define RB5                   0x00000005 
#define RB6                   0x00000006 
#define RB7                   0x00000007 

/////// PORTC //////////////////////////////////////////////////////////////////
#define RC0                   0x00000000 
#define T1OSO                 0x00000000 
#define T1CKI                 0x00000000 
#define RC1                   0x00000001 
#define T1OSI                 0x00000001 
#define CCP2                  0x00000001 
#define RC2                   0x00000002 
#define CCP1                  0x00000002 
#define RC3                   0x00000003 
#define SCK                   0x00000003 
#define SCL                   0x00000003 
#define RC4                   0x00000004 
#define SDI                   0x00000004 
#define SDA                   0x00000004 
#define RC5                   0x00000005 
#define SDO                   0x00000005 
#define RC6                   0x00000006 
#define TX                    0x00000006 
#define CK                    0x00000006 
#define RC7                   0x00000007 
#define RX                    0x00000007 

//***    Define Table (DT) directive

/////// PORTD //////////////////////////////////////////////////////////////////
#define RD0                   0x00000000 
#define PSP0                  0x00000000 
#define RD1                   0x00000001 
#define PSP1                  0x00000001 
#define RD2                   0x00000002 
#define PSP2                  0x00000002 
#define RD3                   0x00000003 
#define PSP3                  0x00000003 
#define RD4                   0x00000004 
#define PSP4                  0x00000004 
#define RD5                   0x00000005 
#define PSP5                  0x00000005 
#define RD6                   0x00000006 
#define PSP6                  0x00000006 
#define RD7                   0x00000007 
#define PSP7                  0x00000007 

/////// PORTE //////////////////////////////////////////////////////////////////
#define RE0                   0x00000000 
#define RD                    0x00000000 
#define AN5                   0x00000000 
#define RE1                   0x00000001 
#define WR                    0x00000001 
#define AN6                   0x00000001 
#define RE2                   0x00000002 
#define CS                    0x00000002 
#define AN7                   0x00000002 

////////////////////////////////////////////////////////////////////////////
//
//   IMPORTANT: For the PIC18 devices, the __CONFIG directive has been
//              superseded by the CONFIG directive.  The following settings
//              are available for this device.
//
//   Oscillator Selection:
//     OSC = LP             LP
//     OSC = XT             XT
//     OSC = HS             HS
//     OSC = RC             RC
//     OSC = EC             EC-OSC2 as Clock Out
//     OSC = ECIO           EC-OSC2 as RA6
//     OSC = HSPLL          HS-PLL Enabled
//     OSC = RCIO           RC-OSC2 as RA6
//
//   Osc. Switch Enable:
//     OSCS = ON            Enabled
//     OSCS = OFF           Disabled
//
//   Power Up Timer:
//     PWRT = ON            Enabled
//     PWRT = OFF           Disabled
//
//   Brown Out Reset:
//     BOR = OFF            Disabled
//     BOR = ON             Enabled
//
//   Brown Out Voltage:
//     BORV = 45            4.5V
//     BORV = 42            4.2V
//     BORV = 27            2.7V
//     BORV = 25            2.5V
//
//   Watchdog Timer:
//     WDT = OFF            Disabled
//     WDT = ON             Enabled
//
//   Watchdog Postscaler:
//     WDTPS = 1            1:1
//     WDTPS = 2            1:2
//     WDTPS = 4            1:4
//     WDTPS = 8            1:8
//     WDTPS = 16           1:16
//     WDTPS = 32           1:32
//     WDTPS = 64           1:64
//     WDTPS = 128          1:128
//
//   CCP2 Mux:
//     CCP2MUX = OFF        Disable (RB3)
//     CCP2MUX = ON         Enable (RC1)
//
//   Stack Overflow Reset:
//     STVR = OFF           Disabled
//     STVR = ON            Enabled
//
//   Low Voltage ICSP:
//     LVP = OFF            Disabled
//     LVP = ON             Enabled
//
//   Background Debugger Enable:
//     DEBUG = ON           Enabled
//     DEBUG = OFF          Disabled
//
//   Code Protection Block 0:
//     CP0 = ON             Enabled
//     CP0 = OFF            Disabled
//
//   Code Protection Block 1:
//     CP1 = ON             Enabled
//     CP1 = OFF            Disabled
//
//   Code Protection Block 2:
//     CP2 = ON             Enabled
//     CP2 = OFF            Disabled
//
//   Code Protection Block 3:
//     CP3 = ON             Enabled
//     CP3 = OFF            Disabled
//
//   Boot Block Code Protection:
//     CPB = ON             Enabled
//     CPB = OFF            Disabled
//
//   Data EEPROM Code Protection:
//     CPD = ON             Enabled
//     CPD = OFF            Disabled
//
//   Write Protection Block 0:
//     WRT0 = ON            Enabled
//     WRT0 = OFF           Disabled
//
//   Write Protection Block 1:
//     WRT1 = ON            Enabled
//     WRT1 = OFF           Disabled
//
//   Write Protection Block 2:
//     WRT2 = ON            Enabled
//     WRT2 = OFF           Disabled
//
//   Write Protection Block 3:
//     WRT3 = ON            Enabled
//     WRT3 = OFF           Disabled
//
//   Boot Block Write Protection:
//     WRTB = ON            Enabled
//     WRTB = OFF           Disabled
//
//   Configuration Register Write Protection:
//     WRTC = ON            Enabled
//     WRTC = OFF           Disabled
//
//   Data EEPROM Write Protection:
//     WRTD = ON            Enabled
//     WRTD = OFF           Disabled
//
//   Table Read Protection Block 0:
//     EBTR0 = ON           Enabled
//     EBTR0 = OFF          Disabled
//
//   Table Read Protection Block 1:
//     EBTR1 = ON           Enabled
//     EBTR1 = OFF          Disabled
//
//   Table Read Protection Block 2:
//     EBTR2 = ON           Enabled
//     EBTR2 = OFF          Disabled
//
//   Table Read Protection Block 3:
//     EBTR3 = ON           Enabled
//     EBTR3 = OFF          Disabled
//
//   Boot Block Table Read Protection:
//     EBTRB = ON           Enabled
//     EBTRB = OFF          Disabled
//
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
//
//       Configuration Bits
//
//     Data Sheet    Include File                  Address
//     CONFIG1L    = Configuration Byte 1L         300000h
//     CONFIG1H    = Configuration Byte 1H         300001h
//     CONFIG2L    = Configuration Byte 2L         300002h
//     CONFIG2H    = Configuration Byte 2H         300003h
//     CONFIG3L    = Configuration Byte 3L         300004h
//     CONFIG3H    = Configuration Byte 3H         300005h
//     CONFIG4L    = Configuration Byte 4L         300006h
//     CONFIG4H    = Configuration Byte 4H         300007h
//     CONFIG5L    = Configuration Byte 5L         300008h
//     CONFIG5H    = Configuration Byte 5H         300009h
//     CONFIG6L    = Configuration Byte 6L         30000ah
//     CONFIG6H    = Configuration Byte 6H         30000bh
//     CONFIG7L    = Configuration Byte 7L         30000ch
//     CONFIG7H    = Configuration Byte 7H         30000dh
//
////////////////////////////////////////////////////////////////////////////

//Configuration Byte 1H Options

#define _OSCS_ON_1H           0x000000DF // Oscillator Switch enable
#define _OSCS_OFF_1H          0x000000FF 
#define _LP_OSC_1H            0x000000F8 // Oscillator type
#define _XT_OSC_1H            0x000000F9 
#define _HS_OSC_1H            0x000000FA 
#define _RC_OSC_1H            0x000000FB 
#define _EC_OSC_1H            0x000000FC // External Clock w/OSC2 output divide by 4
#define _ECIO_OSC_1H          0x000000FD // w/OSC2 as an IO pin (RA6)
#define _HSPLL_OSC_1H         0x000000FE // HS PLL
#define _RCIO_OSC_1H          0x000000FF // RC w/OSC2 as an IO pin (RA6)

//Configuration Byte 2L Options
#define _BOR_ON_2L            0x000000FF // Brown-Out Reset enable
#define _BOR_OFF_2L           0x000000FD 
#define _PWRT_OFF_2L          0x000000FF // Power-Up Timer enable
#define _PWRT_ON_2L           0x000000FE 
#define _BORV_20_2L           0x000000FF // BOR Voltage - 2.0v
#define _BORV_27_2L           0x000000FB //               2.7v
#define _BORV_42_2L           0x000000F7 //               4.2v
#define _BORV_45_2L           0x000000F3 //               4.5v

//Configuration Byte 2H Options
#define _WDT_ON_2H            0x000000FF // Watch Dog Timer enable
#define _WDT_OFF_2H           0x000000FE 
#define _WDTPS_128_2H         0x000000FF // Watch Dog Timer PostScaler count
#define _WDTPS_64_2H          0x000000FD 
#define _WDTPS_32_2H          0x000000FB 
#define _WDTPS_16_2H          0x000000F9 
#define _WDTPS_8_2H           0x000000F7 
#define _WDTPS_4_2H           0x000000F5 
#define _WDTPS_2_2H           0x000000F3 
#define _WDTPS_1_2H           0x000000F1 

//Configuration Byte 3H Options
#define _CCP2MX_ON_3H         0x000000FF // CCP2 pin Mux enable
#define _CCP2MX_OFF_3H        0x000000FE 

//Configuration Byte 4L Options
#define _STVR_ON_4L           0x000000FF // Stack over/underflow Reset enable
#define _STVR_OFF_4L          0x000000FE 
#define _LVP_ON_4L            0x000000FF // Low-voltage ICSP enable
#define _LVP_OFF_4L           0x000000FB 
#define _DEBUG_ON_4L          0x0000007F // Backgound Debugger enable
#define _DEBUG_OFF_4L         0x000000FF 

//Configuration Byte 5L Options
#define _CP0_ON_5L            0x000000FE // Code protect user block enable
#define _CP0_OFF_5L           0x000000FF 
#define _CP1_ON_5L            0x000000FD 
#define _CP1_OFF_5L           0x000000FF 
#define _CP2_ON_5L            0x000000FB 
#define _CP2_OFF_5L           0x000000FF 
#define _CP3_ON_5L            0x000000F7 
#define _CP3_OFF_5L           0x000000FF 

//Configuration Byte 5H Options
#define _CPB_ON_5H            0x000000BF // Code protect boot block enable
#define _CPB_OFF_5H           0x000000FF 
#define _CPD_ON_5H            0x0000007F // Code protect Data EE enable
#define _CPD_OFF_5H           0x000000FF 

//Configuration Byte 6L Options
#define _WRT0_ON_6L           0x000000FE // Write protect user block enable
#define _WRT0_OFF_6L          0x000000FF 
#define _WRT1_ON_6L           0x000000FD 
#define _WRT1_OFF_6L          0x000000FF 
#define _WRT2_ON_6L           0x000000FB 
#define _WRT2_OFF_6L          0x000000FF 
#define _WRT3_ON_6L           0x000000F7 
#define _WRT3_OFF_6L          0x000000FF 

//Configuration Byte 6H Options
#define _WRTC_ON_6H           0x000000DF // Write protect CONFIG regs enable
#define _WRTC_OFF_6H          0x000000FF 
#define _WRTB_ON_6H           0x000000BF // Write protect boot block enable
#define _WRTB_OFF_6H          0x000000FF 
#define _WRTD_ON_6H           0x0000007F // Write protect Data EE enable
#define _WRTD_OFF_6H          0x000000FF 

//Configuration Byte 7L Options
#define _EBTR0_ON_7L          0x000000FE // Table Read protect user block enable
#define _EBTR0_OFF_7L         0x000000FF 
#define _EBTR1_ON_7L          0x000000FD 
#define _EBTR1_OFF_7L         0x000000FF 
#define _EBTR2_ON_7L          0x000000FB 
#define _EBTR2_OFF_7L         0x000000FF 
#define _EBTR3_ON_7L          0x000000F7 
#define _EBTR3_OFF_7L         0x000000FF 

//Configuration Byte 7H Options
#define _EBTRB_ON_7H          0x000000BF // Table Read protect boot block enable
#define _EBTRB_OFF_7H         0x000000FF 

// To use the Configuration Bits, place the following lines in your source code
//  in the following format, and change the configuration value to the desired
//  setting (such as CP_OFF to CP_ON).  These are currently commented out here
//  and each #pragma DATA line should have the preceding semicolon removed when
//  pasted into your source code.

//  The following is a assignment of address values for all of the configuration
//  registers for the purpose of table reads
#define _CONFIG1L             0x00300000 
#define _CONFIG1H             0x00300001 
#define _CONFIG2L             0x00300002 
#define _CONFIG2H             0x00300003 
#define _CONFIG3L             0x00300004 
#define _CONFIG3H             0x00300005 
#define _CONFIG4L             0x00300006 
#define _CONFIG4H             0x00300007 
#define _CONFIG5L             0x00300008 
#define _CONFIG5H             0x00300009 
#define _CONFIG6L             0x0030000A 
#define _CONFIG6H             0x0030000B 
#define _CONFIG7L             0x0030000C 
#define _CONFIG7H             0x0030000D 
#define _DEVID1               0x003FFFFE 
#define _DEVID2               0x003FFFFF 
#define _IDLOC0               0x00200000 
#define _IDLOC1               0x00200001 
#define _IDLOC2               0x00200002 
#define _IDLOC3               0x00200003 
#define _IDLOC4               0x00200004 
#define _IDLOC5               0x00200005 
#define _IDLOC6               0x00200006 
#define _IDLOC7               0x00200007 

//Program Configuration Register 1H
//		#pragma DATA    _CONFIG1H, _OSCS_OFF_1H & _RCIO_OSC_1H

//Program Configuration Register 2L
//		#pragma DATA    _CONFIG2L, _BOR_ON_2L & _BORV_20_2L & _PWRT_OFF_2L

//Program Configuration Register 2H
//		#pragma DATA    _CONFIG2H, _WDT_ON_2H & _WDTPS_128_2H

//Program Configuration Register 3H
//		#pragma DATA    _CONFIG3H, _CCP2MX_ON_3H

//Program Configuration Register 4L
//		#pragma DATA    _CONFIG4L, _STVR_ON_4L & _LVP_OFF_4L & _DEBUG_OFF_4L

//Program Configuration Register 5L
//		#pragma DATA    _CONFIG5L, _CP0_OFF_5L & _CP1_OFF_5L & _CP2_OFF_5L & _CP3_OFF_5L

//Program Configuration Register 5H
//		#pragma DATA    _CONFIG5H, _CPB_ON_5H & _CPD_OFF_5H

//Program Configuration Register 6L
//		#pragma DATA    _CONFIG6L, _WRT0_OFF_6L & _WRT1_OFF_6L & _WRT2_OFF_6L & _WRT3_OFF_6L

//Program Configuration Register 6H
//		#pragma DATA    _CONFIG6H, _WRTC_OFF_6H & _WRTB_OFF_6H & _WRTD_OFF_6H

//Program Configuration Register 7L
//		#pragma DATA    _CONFIG7L, _EBTR0_OFF_7L & _EBTR1_OFF_7L & _EBTR2_OFF_7L & _EBTR3_OFF_7L

//Program Configuration Register 7H
//		#pragma DATA    _CONFIG7H, _EBTRB_OFF_7H

//ID Locations Register 0
//		pragma DATA    _IDLOC0, <expression>

//ID Locations Register 1
//		pragma DATA    _IDLOC1, <expression>

//ID Locations Register 2
//		pragma DATA    _IDLOC2, <expression>

//ID Locations Register 3
//		pragma DATA    _IDLOC3, <expression>

//ID Locations Register 4
//		pragma DATA    _IDLOC4, <expression>

//ID Locations Register 5
//		pragma DATA    _IDLOC5, <expression>

//ID Locations Register 6
//		pragma DATA    _IDLOC6, <expression>

//ID Locations Register 7
//		pragma DATA    _IDLOC7, <expression>

//Device ID registers hold device ID and revision number and can only be read
//Device ID Register 1
//               DEV2, DEV1, DEV0, REV4, REV3, REV2, REV1, REV0
//Device ID Register 2
//               DEV10, DEV9, DEV8, DEV7, DEV6, DEV5, DEV4, DEV3

////////////////////////////////////////////////
// registers define with @ for direct access
////////////////////////////////////////////////
volatile char porta                  @PORTA;
volatile char portb                  @PORTB;
volatile char portc                  @PORTC;
volatile char portd                  @PORTD;
volatile char porte                  @PORTE;
volatile char lata                   @LATA;
volatile char latb                   @LATB;
volatile char latc                   @LATC;
volatile char latd                   @LATD;
volatile char late                   @LATE;
volatile char trisa                  @TRISA;
volatile char trisb                  @TRISB;
volatile char trisc                  @TRISC;
volatile char trisd                  @TRISD;
volatile char trise                  @TRISE;
volatile char pie1                   @PIE1;
volatile char pir1                   @PIR1;
volatile char ipr1                   @IPR1;
volatile char pie2                   @PIE2;
volatile char pir2                   @PIR2;
volatile char ipr2                   @IPR2;
volatile char eecon1                 @EECON1;
volatile char eecon2                 @EECON2;
volatile char eedata                 @EEDATA;
volatile char eeadr                  @EEADR;
volatile char rcsta                  @RCSTA;
volatile char txsta                  @TXSTA;
volatile char txreg                  @TXREG;
volatile char rcreg                  @RCREG;
volatile char spbrg                  @SPBRG;
volatile char t3con                  @T3CON;
volatile char tmr3l                  @TMR3L;
volatile char tmr3h                  @TMR3H;
volatile char ccp2con                @CCP2CON;
volatile char ccpr2l                 @CCPR2L;
volatile char ccpr2h                 @CCPR2H;
volatile char ccp1con                @CCP1CON;
volatile char ccpr1l                 @CCPR1L;
volatile char ccpr1h                 @CCPR1H;
volatile char adcon1                 @ADCON1;
volatile char adcon0                 @ADCON0;
volatile char adresl                 @ADRESL;
volatile char adresh                 @ADRESH;
volatile char sspcon2                @SSPCON2;
volatile char sspcon1                @SSPCON1;
volatile char sspstat                @SSPSTAT;
volatile char sspadd                 @SSPADD;
volatile char sspbuf                 @SSPBUF;
volatile char t2con                  @T2CON;
volatile char pr2                    @PR2;
volatile char tmr2                   @TMR2;
volatile char t1con                  @T1CON;
volatile char tmr1l                  @TMR1L;
volatile char tmr1h                  @TMR1H;
volatile char rcon                   @RCON;
volatile char wdtcon                 @WDTCON;
volatile char lvdcon                 @LVDCON;
volatile char osccon                 @OSCCON;
volatile char t0con                  @T0CON;
volatile char tmr0l                  @TMR0L;
volatile char tmr0h                  @TMR0H;
volatile char status                 @STATUS;
volatile char fsr2l                  @FSR2L;
volatile char fsr2h                  @FSR2H;
volatile char plusw2                 @PLUSW2;
volatile char preinc2                @PREINC2;
volatile char postdec2               @POSTDEC2;
volatile char postinc2               @POSTINC2;
volatile char indf2                  @INDF2;
volatile char bsr                    @BSR;
volatile char fsr1l                  @FSR1L;
volatile char fsr1h                  @FSR1H;
volatile char plusw1                 @PLUSW1;
volatile char preinc1                @PREINC1;
volatile char postdec1               @POSTDEC1;
volatile char postinc1               @POSTINC1;
volatile char indf1                  @INDF1;
volatile char wreg                   @WREG;
volatile char fsr0l                  @FSR0L;
volatile char fsr0h                  @FSR0H;
volatile char plusw0                 @PLUSW0;
volatile char preinc0                @PREINC0;
volatile char postdec0               @POSTDEC0;
volatile char postinc0               @POSTINC0;
volatile char indf0                  @INDF0;
volatile char intcon3                @INTCON3;
volatile char intcon2                @INTCON2;
volatile char intcon                 @INTCON;
volatile char prodl                  @PRODL;
volatile char prodh                  @PRODH;
volatile char tablat                 @TABLAT;
volatile char tblptrl                @TBLPTRL;
volatile char tblptrh                @TBLPTRH;
volatile char tblptru                @TBLPTRU;
volatile char pcl                    @PCL;
volatile char pclath                 @PCLATH;
volatile char pclatu                 @PCLATU;
volatile char stkptr                 @STKPTR;
volatile char tosl                   @TOSL;
volatile char tosh                   @TOSH;
volatile char tosu                   @TOSU;
