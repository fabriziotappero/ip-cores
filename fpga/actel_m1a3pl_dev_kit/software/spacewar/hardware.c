#include "omsp_system.h"
#include "spacewar.h"

//************************************************************
// externals
//
extern volatile unsigned char flags;

extern void reset_rkts(rkt_data *, rkt_data *);
extern void reset_game(rkt_data *);

//************************************************************
//
// init_hardware
//
//    initalize all the MSP430 hardware before we start
//
/* Description:
Sets up all the hardware in the MSP430 used by the SPACEWAR game.
Stops the watchdog timer.  Sets the internal cpu clock to a maximun.
Sets the timer to cause an interrupt every 10ms.  Sets the SPI interface
to talk to the dual DAC.  Sets the A to D to use an external reference 
and unipolar operation.  Finally initializes all the variable used by the game.
*/
void init_all(rkt_data *rkt1, rkt_data *rkt2)
{
  
  WDTCTL = WDTPW + WDTHOLD;             // Stop watchdog timer

  BCSCTL1 = 0x08;                       // Setup DCO highest range
  DCOCTL = 0xe0;                        // biggest DCO

  P1OUT = 0x04;                         // TLV5618A CS high
  P1DIR |= 0x01+0x04;                   // P1.0=LED, P1.2=TLV5618A_cs
  P1SEL = 0x08;                         // P1.3 = VREF

  //BCSCTL2 = 0x00;                       // SMCLK divider = 1
  //BCSCTL2 = 0x02;                       // SMCLK divider = 2
  //BCSCTL2 = 0x04;                       // SMCLK divider = 4
  BCSCTL2 = 0x06;                       // SMCLK divider = 8
  CCTL0 = CCIE;                         // CCR0 interrupt enabled
  CCR0 = 23500;
  TACTL = TASSEL_2 + MC_1;              // SMCLK, upmode
  _BIS_SR(GIE);                         // enable interrupts
  
  // USICTL0 |= USIPE7+USIPE6+USIPE5+USIMST+USIOE; // Port, SPI master
  // USICKCTL = USIDIV_0+USISSEL_2+USICKPL;  // divide by 1 SMCLK, inactive high
  // USICTL0 &= ~USISWRST;                 // release USI for operation
  // USICTL1 = USICKPH;                    // take data on falling edge

  // SD16CTL = SD16SSEL_1;                 // exter ref, SMCLK
  // SD16CCTL0 = SD16UNI + SD16SNGL;       // 256OSR, unipolar, inter
  // SD16AE = 0;                           // P1.1 A4+, A4- = VSS
  //                                       // P1.4 A2+, A2- = VSS
  // SD16INCTL0 = SD16INCH_4;              // A4+/- start with rocket 1
  // SD16CCTL0 |= SD16SC;                  // Start A2D conversion

  reset_rkts(rkt1, rkt2);               // reset rkt positons                        
  reset_game(rkt1);
  reset_game(rkt2);
  rkt1->game = 0;
  rkt2->game = 0;
  flags |= time_tick;                    // force an update at startup
}


//************************************************************
//
// Timer A0 interrupt service routine
//
/* Description:
Interrupt service routine for the timer.  The function sets a flag for the main
loop to update object positions.
*/
interrupt (TIMERA0_VECTOR) irq_routine(void)
{

//  P1OUT ^= 0x01;                        // Toggle P1.0
  flags |= time_tick;                   // flag a timer tick has occured
}

//************************************************************
//
// read_a2d
//
/* Description:
Waits for present A to D to finish.  Reads 16 bit A to D value.  Switches
A to D mux to a channel passed into function.  Starts another A to D on new
mux input.  Returns int value read from last mux input A to D.
*/
unsigned int read_a2d(unsigned int next_mux)
{
  unsigned int last_a2d;  
  
  if (next_mux==0x0002) {
    last_a2d = MY_CNTRL1;
  } else {
    last_a2d = MY_CNTRL2;
  }

  if (last_a2d & 0x8) {             // CCW
    last_a2d = 0xE000;
  } else if (last_a2d & 0x4) {      // CW
    last_a2d = 0xB000;
  } else if (last_a2d & 0x2) {      // Thrust
    last_a2d = 0x8000;
  } else if (last_a2d & 0x1) {      // Fire
    last_a2d = 0x4000;
  } else {
    last_a2d = 0x0000;
  }

  //while ((SD16CCTL0 & SD16IFG) == 0); // wait for a2d to finish
  //last_a2d = SD16MEM0;                // save results from last a2d
  //SD16INCTL0 = next_mux;              // switch analog mux for next rocket
  //SD16CCTL0 |= SD16SC;                // Start another conversion
  return last_a2d;
}

// ************************************************************
//
//  send one 16 bit value to SPI DAC
//
/* Description:
First put the value into the transmit register.  Chip select the DAC.
Start the automatic SPI transfer.  Wait until the transfer is complete.
Finally remove the chip select.
*/
/*
void set_one(int set_1) 
{

  USISR = set_1;                        // send value to DAC
  P1OUT &= ~0x04;                       // chip select TLV5618A
  USICNT = 0x10 + USI16B;               // start spi
  while ((USIIFG & USICTL1) == 0) ;     // wait until y spi done
  P1OUT |= 0x04;                        // remove chip select
}
*/

// ************************************************************
//
//  Move DAC's to dot position
//
// set_x and set_y enter as 0 to 4095
// Masked to 12 bit dac 0 to 4095
/* Description:
Move DAC to position set_x, set_y.  Write the set_y value into the DAC's
BUFFER.  Write the set_x value to DAC_x and at the same time move the BUFFER
value to DAC_y.  This technique removes the stair steping in lines.
*/
void set_xy(int set_x, int set_y) 
{

  //set_one((set_y & 0x0FFF) | 0x5000);   // send y value to BUFFER
  //set_one((set_x & 0x0FFF) | 0xc000);   // send x DAC_X, BUFFER to DAC_Y

  while (MY_DAC_X_STAT);
  while (MY_DAC_Y_STAT);
  MY_DAC_Y = (set_y & 0x0FFF);
  MY_DAC_X = (set_x & 0x0FFF);

}
