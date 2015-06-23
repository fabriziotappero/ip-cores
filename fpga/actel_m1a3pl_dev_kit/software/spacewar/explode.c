//************************************************************
// externals
//
extern volatile int xdisp1, ydisp1;

extern void set_xy(int, int); 

//************************************************************
//
// explode
//
//    make explosion at exp_x, exp_y
//
/* Description:
Generate a visible explosion at position exp_x, exp_y.  This function reads
ints from code space as random numbers to draw points around the exp_x, exp_y
position.  The ints are scaled to 8 bits and added to exp_x, and exp_y to
generate a random position centered on exp_x, exp_y.  A point is displayed at
each position.
*/
void explode(int exp_x, int exp_y)
{
  int i, j, xfin, yfin;
  int *rp;
  
  rp = (int *)0xF880;             // use code space as randon number
  
  for(i = 0; i < 32; i++) {
    xfin = exp_x + (*rp++ >> 8);
    yfin = exp_y + (*rp++ >> 8);
    set_xy(xfin, yfin);
    for(j = 0; j < 16384; j++) {
    }   
  }
  

}
