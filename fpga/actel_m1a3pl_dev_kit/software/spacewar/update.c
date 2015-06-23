#include "msp430x20x3.h"
#include "spacewar.h"

//************************************************************
// externals
//

extern int bzsin(char);

//************************************************************
//
// update
//
//    checks rockets buttons and fires its torpedoes
//    updates rockets position
//    updates torpedos position
//
/* Description:
Generates the x, y vectors for the rocket at present angle.  Checks the A to D
passed into function for any keys pressed.  The A to D resistors are selected
to generate values in between the ranges checked.  If you push multiple buttons
strange results will occure.  If no keys are pressed the fire flaag clears.  
Rotate counter clockwise increments the angle variable.  Rotate clockwise
decrements the angle variable.  If the thrust key is pressed a scaled
value of xsize and ysize is added into the x and y velocity of the rocket
creating acceleration.  If the fire button is pressed the fire flag is checked.
If no fire flag then a inactive torpedo is searched for.  If a inactive torpedo
is found the torpedo is given the present position of the rocket plus an x,y
offset to get it past the nose of the rocket.  The torpedo is given the present
velocity of the rocket plus additional speed based on xsize, ysize.
The rocket position is updated by adding a scaled velocity into position.
The position is masked to the DAC maximum.  The torpedo positions are updated
by adding a scaled torpedo velocity into torpedo position.  The torpedo
position is masked to the DAC maximum.
*/
void update(rkt_data *rkt, unsigned int new_a2d)
{
  int i;
  
  rkt->xsize = bzsin(rkt->ang + 64);    // this returns the cosine
  rkt->ysize = bzsin(rkt->ang);         // this returns the sine

  if(new_a2d > 0xD000){                 // rkt rotate CCW ?
    rkt->ang++;                         // yes
  } 
  else {                                // no
    if(new_a2d > 0xA000){               // rkt rotate CW ?
      rkt->ang--;                       // yes
    } 
    else {                              // no
      if(new_a2d > 0x6000) {            // is rkt thrusting
        rkt->xvel += ((long) rkt->xsize << 6);  // yes
        rkt->yvel += ((long) rkt->ysize << 6);
    }
      else {                            // no
        if(new_a2d > 0x2000) {          // is rkt firing now ?
          if((rkt->flags & fire_bit) == 0) {  // did rkt fire last loop ?
            for(i = 0; i < ammo; i++) {       // no - look for a torp read to fire
              if(rkt->pt_dx[i] == -1) {
                rkt->flags |= fire_bit;       // set firing flag
                rkt->pt_dx[i] = rkt->xdisp + (rkt->xsize << 1); // load up a new torps data
                rkt->pt_dy[i] = rkt->ydisp + (rkt->ysize << 1);
                rkt->pt_vx[i] = (rkt->xvel >> 16) + (rkt->xsize >> 3);
                rkt->pt_vy[i] = (rkt->yvel >> 16) + (rkt->ysize >> 3);
                break;
              }
            }
          } 
        } else {
          rkt->flags &= ~fire_bit;            // clear fire flag
        }
      }
    }
  }

  rkt->xdisp = (rkt->xdisp + (rkt->xvel >> 16)) & max_dac; // update rkt x position
  rkt->ydisp = (rkt->ydisp + (rkt->yvel >> 16)) & max_dac; // update rkt y position

  for(i = 0; i < ammo; i++) {
    if(rkt->pt_dx[i] != -1) {
      rkt->pt_dx[i] = (rkt->pt_dx[i] + rkt->pt_vx[i]) & max_dac; // move torp x
      rkt->pt_dy[i] = (rkt->pt_dy[i] + rkt->pt_vy[i]) & max_dac; // move torp x
    }
  }
}



