#include "spacewar.h"

//************************************************************
// externals
//
extern volatile int xinit, yinit;

extern void cline(int, int);
void set_xy(int, int); 
extern void point(rkt_data *);

//************************************************************
//
// rkt2
//
//    draws rocket # 2
//
// pa_x = xd2 + xs2
// pa_y = yd2 + ys2
// pb_x = xd2 - xs2
// pb_y = yd2 - ys2
// pc_x = xd2 - xs2/2
// pc_y = yd2 - ys2/2
// pd_x = (xd2 - xs2) - ys2/2
// pd_y = (yd2 - ys2) + xs2/2
// pf_x = (xd2 - xs2) + ys2/2
// pf_y = (yd2 - ys2) - xs2/2
//
/* Description:
Draws rocket 2 made of five lines.  This rocket looks like an arrowhead
Also draws rocket 2 torpedos as points. On exit leaves the DAC parked at the
center of the screen.
*/
void rocket2(rkt_data *rkt2)
{
int tmp_x, tmp_y;
int half_xs2, half_ys2;

  tmp_x = rkt2->xdisp - rkt2->xsize;    // pb_x = xd2 - xs2
  tmp_y = rkt2->ydisp - rkt2->ysize;    // pb_y = yd2 - ys2

  half_xs2 = rkt2->xsize >> 1;          // xs2/2
  half_ys2 = rkt2->ysize >> 1;          // ys2/2
  
  xinit = tmp_x;                        // start pb_x
  yinit = tmp_y;                        // start pb_y
  cline(rkt2->xdisp + rkt2->xsize, rkt2->ydisp + rkt2->ysize);  // draw line #1 b->a
  cline(tmp_x + half_ys2, tmp_y - half_xs2); // draw line #2 a->f
  cline(rkt2->xdisp - half_xs2, rkt2->ydisp - half_ys2); // draw line #3 f->c
  cline(tmp_x - half_ys2, tmp_y + half_xs2); // draw line #4 c->d
  cline(rkt2->xdisp + rkt2->xsize, rkt2->ydisp + rkt2->ysize); // draw line #5 d->a

  point(rkt2);                          // update and draw rkt2's torpedoes
  set_xy(center, center);               // park dot at center of screen
}
