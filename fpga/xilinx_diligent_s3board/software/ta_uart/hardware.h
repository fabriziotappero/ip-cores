#ifndef HARDWARE_H
#define HARDWARE_H

#include <msp430.h>
#include <legacymsp430.h>
#include <iomacros.h>


//PINS
//PORT1
#define TX              BIT1

//PORT2
#define RX              BIT2
#define LED             BIT1

//Port Output Register 'P1OUT, P2OUT':
#define P1OUT_INIT      TX              //Init Output data of port1
#define P2OUT_INIT      0               //Init Output data of port2
#define P3OUT_INIT      0               //Init Output data of port3

//Port Direction Register 'P1DIR, P2DIR':
#define P1DIR_INIT      TX              //Init of Port1 Data-Direction Reg (Out=1 / Inp=0)
#define P2DIR_INIT      ~RX             //Init of Port2 Data-Direction Reg (Out=1 / Inp=0)
#define P3DIR_INIT      0xff            //Init of Port3 Data-Direction Reg (Out=1 / Inp=0)

//Selection of Port or Module -Function on the Pins 'P1SEL, P2SEL'
#define P1SEL_INIT      0               //P1-Modules:
#define P2SEL_INIT      RX              //P2-Modules:
#define P3SEL_INIT      0               //P3-Modules:

//Interrupt capabilities of P1 and P2
#define P1IE_INIT       0               //Interrupt Enable (0=dis 1=enabled)
#define P2IE_INIT       0               //Interrupt Enable (0=dis 1=enabled)
#define P1IES_INIT      0               //Interrupt Edge Select (0=pos 1=neg)
#define P2IES_INIT      0               //Interrupt Edge Select (0=pos 1=neg)

#define IE_INIT         0
#define WDTCTL_INIT     WDTPW|WDTHOLD

#define BCSCTL1_FLL     XT2OFF|DIVA1|RSEL2|RSEL0
#define BCSCTL2_FLL     0
#define TACTL_FLL       TASSEL_2|TACLR
#define CCTL2_FLL       CM0|CCIS0|CAP

#define TACTL_AFTER_FLL TASSEL_2|TACLR|ID_0

//#define BAUD            40              //9600 @3MHz div 8
//#define BAUD            20              //19200 @3MHz div 8
//#define BAUD            20              //9600 @1.5MHz div 8
//#define BAUD            140              //9600 @1.5MHz div 8

//#define BAUD           2083              //9600 @20.0MHz div 1
//#define BAUD           1042              //19200 @20.0MHz div 1
//#define BAUD            521              //38400 @20.0MHz div 1
//#define BAUD            347              //57600 @20.0MHz div 1
#define BAUD            174              //115200 @20.0MHz div 1
//#define BAUD             87              //230400 @20.0MHz div 1

//Selection of 'Digitally Controlled Oszillator' (desired frquency in HZ, 1..3 MHz)
#define DCO_FREQ        1536000         //3072000/2 makes 9600 a bit more precise

//Automatic, do not edit
#define DCO_FSET        (DCO_FREQ/8192) //DCO_FSET = DCO_FREQ / (32768/4)
#define DCOCTL_MAX      0xff            // Used from FLL to check when Rsel must be changed
#define DCOCTL_MIN      0               // Used from FLL to check when Rsel must be changed


#endif //HARDWARE_H
