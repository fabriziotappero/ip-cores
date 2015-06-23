#include <stdlib.h>
#include "spacewar.h"

//************************************************************
// externals
//
extern volatile int xinit, yinit;

extern void set_xy(int, int); 

// ************************************************************
//
// cline
//
//  continue line draw
//
/* Description:
Draws short lines based on fixed size increments so longer lines have more
points.  First calculates the delta x and delta y.  Finds the larger.  Scales
the larger by dividing by 2 until delta is less that fixed_inc.  Scales the
other increment at the same time.  Also generates the loop counter for # of
increments to draw the line.  Finally the function draws the line with points.
*/
void cline(int xfin, int yfin)
{
int delta_x, delta_y, delta_adj;
int i = 1;

  delta_x = (xfin - xinit);
  delta_y = (yfin - yinit);
  // find larger delta_x or delta_y - use the larger to scale
  delta_adj = (abs(delta_y) <= abs(delta_x)) ? abs(delta_x) : abs(delta_y);

  // calc the delta inc
  while(fixed_inc < delta_adj) {
    i += i; ;                     // double loop counter
    delta_x = delta_x >> 1;       // 1/2 inc size x
    delta_y = delta_y >> 1;       // 1/2 inc size y
    delta_adj = delta_adj >> 1;
  }

  // draw the line with dots
  while(i--) {
    set_xy(xinit, yinit);         // move dot 
    xinit += delta_x;
    yinit += delta_y;
  } 
}

