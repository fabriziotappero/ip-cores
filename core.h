#ifndef CORE_H
#define CORE_H

#include <systemc>
#include "power_model.h"
#include "define.h"
#include "packet_header.h"
using namespace sc_core;
using namespace sc_dt;
using namespace std;

extern double ei_energy;
extern double oi_energy;

class core : public sc_module{
public:
	sc_in<bool>		clk;				//input clock signal.
	sc_in<bool>		reset_n;				//reset signal.
	
	sc_out<bool>        data_out;		//core input data port.
	sc_in<bool>         data_in;		//core output data port.

	//signal associated with FIFO signal.
	sc_out<sc_uint<2> > fifo_to_core_sel;	//fifo select signal when receive data.
	sc_out<sc_uint<2> > core_to_fifo_sel;	//fifo select signal when transfer data. 
	sc_out<bool>        write_n;			//core output data control pin.
	sc_out<bool>        read_n;				//core input data control pin.
	sc_in<sc_uint<3> >  empty;				//State of FIFO is full.
	sc_in<sc_uint<3> >  full;				//State of FIFO is empty.
	
	SC_HAS_PROCESS(core);

	core(sc_module_name nm, int id, int column_num, int row_num):sc_module(nm){
		core_id = id;
		x_num = column_num;
		y_num = row_num;

		SC_THREAD(transfer_data);
		sensitive << clk.pos() << clk.neg() << reset_n.neg();

		SC_THREAD(receive_data);
		sensitive << clk.pos() << clk.neg() << reset_n.neg();

		SC_THREAD(core_handle);
		sensitive << clk.pos() << reset_n.neg();
	}
protected:
	sc_uint<8>			ac;				//address counter.
	sc_uint<6>			core_id;
	sc_uint<6>			x_num;
	sc_uint<6>			y_num;

	//sc_uint<FIFO_DEEP>	memory[100];
	unsigned short		wmemory[100];
	unsigned short		rmemory[100];
	sc_uint<8>			raddress;
	sc_uint<8>			waddress;
	sc_uint<3>			sel_fifo;
	sc_event			write_en;
	sc_event			read_en;
	
	sc_uint<8>			write_state;
	sc_uint<8>			read_state;
	sc_uint<8>			write_address[3];
	sc_uint<8>			read_address[3];

#ifdef CORE_DEBUG
	sc_event			sc_debug;
#endif

	void transfer_data();
	void receive_data();
	char write_data(sc_uint<3> sel, sc_uint<8> addr);
	char read_data(sc_uint<3> sel, sc_uint<8> addr);
	void core_handle();
};

#endif
