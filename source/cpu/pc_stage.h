//
// $Id: pc_stage.h,v 1.1 2006-01-25 17:00:01 igorloi Exp $
//
#ifndef _PC_STAGE_H
#define _PC_STAGE_H

#include <systemc.h>
#include "./pc_stage/reg_pc.h"
#include "../constants/constants.h"
#include "../constants/config.h"

SC_MODULE(pc_stage)
{
	
	sc_in<bool> 		in_clk;
	sc_in<bool> 		reset;
	
	sc_in<bool> 		insthold;
	sc_in<bool> 		datahold;
	
	sc_in<sc_logic> 	enable_pc;
	
	sc_in<sc_lv<32> >	pc_in;
	sc_out<sc_lv<32> >	pc_out;
	
	sc_out<sc_uint<32> >	instaddr;
	sc_out<sc_lv<32> >	instdatawrite;
	
	sc_out<sc_logic> 	instreq;
	sc_out<sc_logic> 	instrw;
	
	reg_pc *reg_pc1;
	
	SC_CTOR(pc_stage) 
	{
		reg_pc1 = new reg_pc("reg_pc");
		
		reg_pc1->in_clk(in_clk);
		reg_pc1->reset(reset);
		
		reg_pc1->insthold(insthold);
		reg_pc1->datahold(datahold);
		
		reg_pc1->enable_pc(enable_pc);
		
		reg_pc1->pc_in(pc_in);
		reg_pc1->pc_out(pc_out);
		
		reg_pc1->instaddr(instaddr);
		reg_pc1->instdatawrite(instdatawrite);
		
		reg_pc1->instreq(instreq);
		reg_pc1->instrw(instrw);
	}
};

#endif

