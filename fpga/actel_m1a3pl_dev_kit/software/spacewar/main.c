//************************************************************
// 
//      SPACEWAR
//      VERSION 5B
//      BY
//      LARRY BRYANT AND BILL SEILER
//      JULY 21, 1974 for PDP-11
//      July 2006 for MSP430F2013
//
//************************************************************
//
//   SPACEWAR HARWARE
//
//      Master
//   MSP430F2013
//   ------------
//  |         XIN|-        DAC_X_Y   
//  |            |         TLV5618A  
//  |        XOUT|-        -------- 
//  |        P1.0|->LED       |        |
//  |        P1.2|------->|/SYNC   |
//  |  P1.3(VREF)|-3.6V   |    OUTA|-->DAC_X
//  |            |        |        |
//  |    SDI/P1.7|        |    OUTB|-->DAC_Y
//  |    SDO/P1.6|------->|DIN     |
//  |   SCLK/P1.5|<-------|SCLK    |
//   ------------          --------
//
//  B. Seiler
//  July 2006
//************************************************************

#include "omsp_system.h"
#include "spacewar.h"

//************************************************************
// externals
//
extern void init_all(rkt_data *, rkt_data *);
extern unsigned int read_a2d(unsigned int);
extern void update(rkt_data *, unsigned int);
extern void compar(rkt_data *, rkt_data *);
extern void score(rkt_data *, rkt_data *);
extern void rocket1(rkt_data *);
extern void rocket2(rkt_data *);

//************************************************************
//
// globlal variables
//
volatile int xinit, yinit;     // starting point of a lines
volatile unsigned char flags;  // bit 0 = time tick flag

//************************************************************
//
// play_spacewar
//
/* Description:
  Plays a two rocket game of classic MIT SPACEWAR.  First the hardware and game
variables are setup.  An infinite while loop then executes.  The infinite loop
is the main loop that continously draws both rockets and all the torpedos.  
There is a background timer interrupt that occurs every 10ms.  When the timer
interrupt occures extra operations are added to main loop.  The rocket and
torpedo positions are updated every 10ms so animation speed remain constant.  
The player buttons are read every 10ms and if any buttons are pressed player
input is applied.  The rockets and torpedos are checked for collisions every
10ms.  If a collision is detected the correct shield is decremented.  
The shields are checked every 10ms.  If any shield has reached zero the game
is ended.  If the game has ended the score is displayed.  Then the next game
then starts again.
*/
void play_spacewar(rkt_data *rkt1, rkt_data *rkt2)
{

  init_all(rkt1, rkt2);                     // setup MSP430 hardware and variables

  while (1) {
    P1OUT ^= 0x01;                          // Toggle P1.0
    if(flags && time_tick) {                // only104 do updates on time tick
      update(rkt1, read_a2d(0x0002));       // check rkt1's buttons update positions
      update(rkt2, read_a2d(0x0004));       // check rkt2's buttons update positions
      compar(rkt1, rkt2);                   // check for collisions or hits
      score(rkt1, rkt2);                    // check for game end, show score
      flags &= ~time_tick;                  // clear time tick flag
    }
    rocket1(rkt1);                          // draw rocket 1
    rocket2(rkt2);                          // draw rocket 2
  }
}

//************************************************************
//
// main
//
/* Description:
  Calls a function named play_spacewar.  This extra call reduces code size
by using registers as the pointers to the structures rkt1 and rkt2.
*/
int main(void)
{
struct rkt_data rkt1, rkt2;
  
  play_spacewar(&rkt1, &rkt2);              // play the game

  return 1;
}

