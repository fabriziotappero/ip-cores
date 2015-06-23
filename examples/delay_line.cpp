#include "delay_line.h"

void delay_line::registers()
{

  sc_uint<8> var1,var2;
  
  if( reset.read() == 1 )
  {
    pipe_0.write( 0 );
    pipe_1.write( 0 );
    pipe_2.write( 0 );
    pipe_3.write( 0 );

   var1=0;
   var2=0;

    num_out.write( 0 );
  }
  else
  {
    pipe_0.write( num_in );
    pipe_1.write( pipe_0 );
    pipe_2.write( pipe_1 );
    pipe_3.write( pipe_2 );

    var1=pipe_0.read();
    var2=var1;
    
    num_out.write( pipe_3 );
  }
}
