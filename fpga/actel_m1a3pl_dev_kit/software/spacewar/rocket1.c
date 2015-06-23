#include "spacewar.h"

//************************************************************
// externals
//
extern volatile int xinit, yinit;

extern void cline(int, int);
extern void point(rkt_data *);

//************************************************************
//
// rkt1
//
//    draws rocket # 1
//
/* Description:
Draws rocket 1 made of five lines.  This rocket looks like the starship
enterprise.  Also draws rocket 1 torpedos as points.
*/
void rocket1(rkt_data *rkt1)
{
int dif_yx, sum_yx;
int xfin, yfin;

  dif_yx = (rkt1->ysize >> 1) - (rkt1->xsize >> 1);
  sum_yx = (rkt1->ysize >> 1) + (rkt1->xsize >> 1);

  xinit = rkt1->xdisp + rkt1->xsize;
  yinit = rkt1->ydisp + rkt1->ysize;
  xfin = rkt1->xdisp - (rkt1->xsize >> 1);
  yfin = rkt1->ydisp - (rkt1->ysize >> 1);
  cline(xfin, yfin);                      // draw line #1
  
  xfin = xinit - dif_yx;
  yfin = yinit + sum_yx;
  xinit -= sum_yx;
  yinit -= dif_yx;
  cline(xfin, yfin);                      // draw line #2
  
  xfin = xinit + sum_yx;
  yfin = yinit + dif_yx;
  cline(xfin, yfin);                      // draw line #3
  
  xfin = xinit + dif_yx;
  yfin = yinit - sum_yx;
  cline(xfin, yfin);                      // draw line #4
  
  xfin = xinit - sum_yx + dif_yx;
  yfin = yinit - sum_yx - dif_yx;
  cline(xfin, yfin);                      // draw line #5

  point(rkt1);                            // update and draw rkt1's torpedoes
}
