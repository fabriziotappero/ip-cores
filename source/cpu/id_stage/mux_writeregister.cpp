//Multiplexer per scittura registri
// Stabilisce il registro di destinazione, che puo' essere
// il registro rt, rd o il registro 31!

#include "mux_writeregister.h" 

void mux_writeregister::do_mux_writeregister()
{
	if(regdest.read() == "00")
	   id_writeregister.write(rd);
	else 
	   if(regdest.read() == "01")
	     id_writeregister.write(rt);
	   else 
	      if(regdest.read() == "10")
		id_writeregister.write("11111");
	      else
		id_writeregister.write("00000");
}
