#include "spacewar.h"

//************************************************************
// externals
//

//************************************************************
//
// reset
//
//    reset rkts for restart of program
//
/* Description:
Resets the rocket structure.  The xdisp = ydisp = position, ang = angle
passed into function.  Rockets x and y velocities are set to zero.
*/
void reset_one_rkt(rkt_data *rkt, int position, unsigned char angle)
{
  
  rkt->xdisp = position;    // position rkt in quadrant
  rkt->ydisp = position;
  rkt->xvel = 0;            // no velocity
  rkt->yvel = 0;
  rkt->ang = angle;         // point to angle
}

//************************************************************
//
// reset
//
//    reset rkts for restart of program
//
/* Description:
Reset the position, angle, and velecity of both rockets.
*/
void reset_rkts(rkt_data *rkt1, rkt_data *rkt2)
{
  
// setup rkt1 variables
  reset_one_rkt(rkt1, (max_dac * 3) / 4, 0);  // position rkt1 in quadrant 1
                                              // point to 3 o'clock
// setup rkt2 variables
  reset_one_rkt(rkt2, (max_dac * 1) / 4, 128); // position rkt2 in quadrant 3
                                              // point to 9 o'clock
}

//************************************************************
//
// reset game info for one rocket
//
//
/* Description:
Resets shield to full value, stops the torpedos from firing, and makes all
torpedos inactive for structure passed to function.
*/
void reset_game(rkt_data *rkt)
{
  int i;
  
  rkt->shield = full_shields ;          // restore all shields
  rkt->flags = 0;                       // clear all flags

  for (i=0; i < ammo; i++){             // stop all torps
    rkt->pt_dx[i] = -1;                        
  }
}

