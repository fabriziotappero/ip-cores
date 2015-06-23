#include "spacewar.h"

//************************************************************
// externals
//

extern void reset_rkts(rkt_data *, rkt_data *);
extern void reset_game(rkt_data *);
extern void explode(int, int);
extern void rocket1(rkt_data *);
extern void rocket2(rkt_data *);
extern int bzsin(char);

//************************************************************
//
// chk_shlds
//
//    check rockets shields for game end
//
/* Description:
Checks if shields of first rocket structure is zero.  If zero then draws an
explosion for the first structure rocket and adds a point to the second
structure rocket game score.
*/
void chk_shlds(rkt_data *rkta, rkt_data *rktb)
{

  if(rkta->shield == 0) {             // rkt a dead ?
    explode(rkta->xdisp, rkta->ydisp);  // yes - explode
    rktb->game++;                     // add one rktb's game total
  }
}

//************************************************************
//
// score
//
//    check for game end, show score
//
/* Description:
Checks if shields of rocket 1 the rocket 2.  Explodes and scores if shields 
equal zero.  Sets rocket 1 position to top left and rocket 2 to bottom left.
Starts displaying the number of games won by rocket pictures.
Resets all rocket positions back to inital positions.
*/
void score(rkt_data *rkt1, rkt_data *rkt2)
{
  int i, j;
  
  chk_shlds(rkt1, rkt2);              // rkt1 dead ?
  chk_shlds(rkt2, rkt1);              // rkt2 dead ?
  
  if((rkt1->shield == 0) || (rkt2->shield == 0)) {
    reset_rkts(rkt1, rkt2);           // reset rkt positons                        

    rkt1->xsize = 0;
    rkt1->ysize = rktsiz;
    rkt2->xsize = 0;
    rkt2->ysize = rktsiz; 

    reset_game(rkt1);
    reset_game(rkt2);

    for(i = 0; i < 512; i++) {        // show score
      rkt1->xdisp = rktsiz << 2;      // left side of screen
      rkt2->xdisp = rktsiz << 2;      // left side of screen

      for(j = 0; j < rkt1->game; j++) {
        rocket1(rkt1);
        rkt1->xdisp += rktsiz << 1;
      }
      for(j = 0; j < rkt2->game; j++) {
        rocket2(rkt2);
        rkt2->xdisp += rktsiz << 1;
      }
    }
    reset_rkts(rkt1, rkt2);           // reset rkt positons                        
  }
}
