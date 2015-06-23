// ************************************************************
// global variables
//
// sine table 0 - 64 binary degrees
// rocket size of 128 calculated into table
/* Description:
Contains byte values for scaled rocket size values for the first quadrent
of angles.  
*/
const char sintbl[] = {
  0, 3, 6, 9, 12, 15, 18, 21, 
  24, 28, 31, 34, 37, 40, 43, 46, 
  48, 51, 54, 57, 60, 63, 65, 68, 
  71, 73, 76, 78, 81, 83, 85, 88, 
  90, 92, 94, 96, 98, 100, 102, 104, 
  106, 108, 109, 111, 112, 114, 115, 117, 
  118, 119, 120, 121, 122, 123, 124, 124, 
  125, 126, 126, 127, 127, 127, 127, 127, 
  128
  };

// ************************************************************
//
//    blitzkrieg sine routine
//
//    enter angle to be converted
//
/* Description:
Fast lookup table sine routine.  The sine routine uses 256 units for a
complete circle.  
The first  quadrent is 0x00 - 0x3f ->   0 -  89 degrees.
The second quadrent is 0x40 - 0x7f ->  90 - 179 degrees.  
The third  quadrent is 0x80 - 0xbf -> 180 - 269 degrees.  
The fourth quadrent is 0xc0 - 0xff -> 270 - 359 degrees.
This fuction is call as a cosine by adding 64 to the angle to return the x 
vector part of the rocket size.  This fuction is call as a sine to return the y
vector part of the rocket size.
*/
int bzsin(char angle)
{
  int sine;
  
  if(angle & 0x40) angle = angle ^ 0x3F;  // invert angle in second quad
  sine = sintbl[angle & 0x3F];            // convert char to int
  return (angle & 0x80) ? -sine : sine ;  // change sign for 180 - 360 degrees
}

