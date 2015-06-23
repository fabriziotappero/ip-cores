//************************************************************
//
// spacewar.h
//
//

#define full_shields 6      // 6 hits on rkt to win
#define ammo 2              // # photon torpedos per rocket- only memory for 2
#define rktsiz  128         // size of rockets
#define max_dac 4095        // max value on scrn
#define min_dac 0           // max value on scrn
#define fixed_inc 16        // space between dots in lines
#define center (max_dac / 2)  // center of the display
#define collide 256         // size of rocket for a collision
#define fire_bit 1          // fire button is pressed
#define time_tick 1         // 10 ms timer tick for system time


/* Description:
The structure contain all the data for each rocket.  Two of these structures
are defined in main, rkt1 and rkt2.  The xdisp, ydisp is the 12 bit position of
the rocket.  The xvel, yvel is the velocity if the rocket. xvel, yvel is added
into xdisp, ydisp every 10ms to cause motion.  The xsize, ysize are the scaled
vectors of the rocket size used to draw the rocket.  The angle is the present
angle the rocket is flying.  The angle is 0 - 255 for 0 - 359 degrees.  Flags
contains a single bit to debounce the single firing of torpedos.  The pt_dx[], 
pt_dy[] is the array position for this rockets torpedos.  The pt_vx[], pt_vy[]
is the array velocity for this rockets torpedos.
*/
struct rkt_data {
  int xdisp, ydisp;         // rockets x,y position, 0 <= pos <= 4095
  long xvel, yvel;          // rockets x,y velocity
  int xsize, ysize;         // sine/cosine size of rocket for drawing it
  unsigned char ang;        // rockets angle
  unsigned char shield;     // shield value, if =0 game over
  unsigned char game;       // game points scored
  unsigned char flags;      // bit 1 fire flag if = 1 fire button is down 
  int pt_dx[ammo], pt_dy[ammo]; // torps x,y position
  int pt_vx[ammo], pt_vy[ammo]; // torps x,y velocity
};

typedef struct rkt_data rkt_data;
