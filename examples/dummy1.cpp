#include "systemc.h"

#define HOLA 1
#define CONCAT 1

sc_uint<2> dummy1::func1(sc_uint<2> a, sc_uint<2> b){
   sc_uint<2> c;
   c=a+b;
   return c+5;
}


void
dummy1::regs ()
{
  if (rst.read ())
    {
      state.write (S0);
    }
  else
    state.write (next_state);
}

void
dummy1::fsm_proc ()
{
/*Verilog begin
	cfsm_proc={a[1:0],b[1:0]};
verilog end*/

  sc_uint < 2 > c;
  sc_uint < 4 > f;
  next_state.write (state.read ());
  a.write (func1(a.read(),b.read()));
  b.write (HOLA);
 
#ifdef CONCAT
  c.write ((a.range (1, 0), b.range (1, 0)));
#else
  c.write ((a, a));
#endif

  switch ((int) state.read ())
    {
    case 0x1:			//Case 0
      if (input1.read ())
	{
	  next_state.write (S1);
	  a.write (true);
	}
      else if (input2.read () < input1.read())
	{
	  next_state.write (S2);
	  a.write (false);
	}
      else
	{
	  next_state.write (S0);
	  a.write (1);
	}
      break;
//   tRaNsLaTe   oFF              
    case S1:
      if (input2.read ())
	{
	  next_state.write (S2);
	  b.write (1);
	}
      break;
//   tRaNsLaTe   oN               
    case S2:
          for(int i=0;i<=10;i++){
	      c.write(i);
	  }
      next_state.write (S0);
      break;
    }
}
