#include <stdlib.h>
#include "spacewar.h"

//************************************************************
// externals
//

extern void reset_rkts(rkt_data *, rkt_data *);

//************************************************************
//
// compare torps
//
//    checks for collisions between rocket and torps
//
/* Description:
The function checks for collisions between a rocket and all the active 
torpedoes for the other player.  The first structure passed is used for the
rocket.  The second structure passed is used for torpedoes.  The array of
torpedoes is scaned for active torpedoes.  If a torpedo's x position is not
equal to -1 it is active.  If active the absolute value of the difference
between torpedo and rocket x positions is compared to a constant collide.
If less the y positions are compared the same way.  If less a collision has
occured.  The rocket shield is decremented.
*/
void comp_torp(rkt_data *rkt, rkt_data *torps)
{
int i;

  for(i = 0 ; i < ammo; i++) {
    if(torps->pt_dx[i] != -1) {             // is this torp active ?
      if(abs(rkt->xdisp - torps->pt_dx[i]) < collide) { // yes - collide between rkt and torps
        if(abs(rkt->ydisp - torps->pt_dy[i]) < collide) {
          torps->pt_dx[i] = -1;             // remove torp from list
          rkt->shield--;                    // rkt loose one shield
        }
      }
    }
  }
}

//************************************************************
//
// compar
//
//    checks for collisions or hits and keeps score
//
/* Description:
Check for collisions between all objects.  First checks for a rocket to rocket
collision.  If rocket to rocket collision then decrement boths rockets shields 
and reset rockets to initial positions.  Next check for rocket 1 to torpedos
of rocket 2 collisions.  If a hit decrement rocket 1 shields.  Finally check
for rocket 2 to torpedos of rocket 1 collisions.  If a hit decrement rocket 2
shields.
*/
void compar(rkt_data *rkt1, rkt_data *rkt2)
{

  if(abs(rkt1->xdisp - rkt2->xdisp) < collide) {  // check rkt1 collide with rkt2
    if(abs(rkt1->ydisp - rkt2->ydisp) < collide) {
      rkt1->shield--;                       // rkt1 loose one shield
      rkt2->shield--;                       // rkt2 loose one shield
      reset_rkts(rkt1, rkt2);               // reset rkt positons                        
    }
  }

  comp_torp(rkt1, rkt2);              // check for hit on rkt1 by tops from rkt2
  comp_torp(rkt2, rkt1);              // check for hit on rkt1 by tops from rkt2

}


