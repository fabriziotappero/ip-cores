#include "spacewar.h"

//************************************************************
// externals
//

extern void set_xy(int, int); 

//************************************************************
//
// point
//
//    displays the torpedos for one rocket
//    if pt_dx = -1 torp is inactive
//
/* Description:
Display the active torpedos as points from the structure passed into function.
A torpedo is active if its x position is not equal to -1.
*/
void point(rkt_data *rkt)
{
  int i;
  
  for(i = 0; i < ammo; i++) {
    if(rkt->pt_dx[i] != -1) {
      set_xy(rkt->pt_dx[i], rkt->pt_dy[i]);   // move torp to new position
    }
  }
}
