//-----------------------------------------------------------------------------
//
// Title       : cell1
// Design      : den
// Author      : Ozgur
// Company     : DEÜ
//
//-----------------------------------------------------------------------------
//
// File        : complex1.sc.h
// Generated   : 13:49:50 28 Nisan 2009 Salý
// From        : SystemC Source Wizard
// By          : SystemC Source Wizard ver. 1.0
//
//-----------------------------------------------------------------------------
//
// Description : 
//
//-----------------------------------------------------------------------------

#ifndef __complex1.sc_h__
#define __complex1.sc_h__

#include <systemc.h>
#include "cplxopsphasor.sc.h"

SC_MODULE( cell1 )
{

	sc_in< sc_logic > clk;
	sc_in< sc_uint< 8 > > in1_re;
	sc_in< sc_uint< 8 > > in2_re;
	sc_out< sc_uint< 16 > > out_re;
	sc_in< sc_uint< 8 > > in1_im;
	sc_in< sc_uint< 8 > > in2_im;
	sc_out< sc_uint< 16 > > out_im;

	void cell();
	SC_CTOR( cell1 ):
		clk("clk"),
		in1_re("in1_re"),
		in2_re("in2_re"),
		out_re("out_re"),
		in1_im("in1_im"),
		in2_im("in2_im"),
		out_im("out_im")
	{			
	SC_METHOD(cell)
	sensitive(clk);
	}

	~cell1()
	{

	}

};

SC_MODULE_EXPORT( cell1 )

#endif //__complex1.sc_h__

