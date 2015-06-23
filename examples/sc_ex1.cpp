#include "sc_ex1.h"       // the header for this

#define ROT  0            // NB sc2v 4.2 macros buggy
#define POPX 1


void icu::decoder_io()    // runs once per clock - because .h
{
  sc_uint<8> tmp;
  
  tmp = POPX;
  if( reset.read() == 1 )
  {
    control_out.write( 0 );
  }
  else
  {
    if (alu_ready == 1)
    {
      switch (instr_in)
      {
	// this sort of works!    case (ROT):
      case ROT :                  // this does not work
	control_out.write (0x1);  // neither does this
	break;
      case 1 :
	control_out.write (0x2);
	break;
      default:
      }
    }
    else  // needed?
    {
    }
  }
}
