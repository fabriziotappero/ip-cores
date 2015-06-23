#include <systemc.h>
#include "./constants/config.h"
#include "./cpu/sc_risc.h"
#include "./memory/memory2.h"
#include "./embedded_perif/mux.h"
#include "./embedded_perif/decoder.h"
#include "./generators/reset_gen.h"
#include "./generators/timer.h"
//#include "./generators/clock_gen.h"

SC_MODULE(top)
{
	sc_in<bool> in_clk;
	sc_signal<bool> reset;
	
	sc_signal<sc_lv<32> > dataread_m_dec, dataread_dec_cpu, datawrite, instdataread, instdatawrite;
	sc_signal<sc_uint<32> > instaddr, dataaddr;
	sc_signal<sc_logic> instreq, datareq, instrw, datarw;
	sc_signal<sc_lv<2> > databs;
	sc_signal<bool> insthold, datahold;
	sc_signal<sc_lv<2> > instbs;
	sc_signal<sc_logic> data_addrl, data_addrs, inst_addrl, inst_addrs;
	sc_signal<sc_logic> IBUS, DBUS;
	
	sc_signal<sc_lv<3> > selector;
	sc_signal<sc_lv<32> > DUMMY_WIRE;
	sc_signal<bool> interrupt_signal, interrupt_signal_2;
	
	//clock_gen *clock_gen1;
	mux *mux_data;
	decoder *decod;
	reset_gen *reset_gen1;
	sc_risc *risc;
	memory2 *instmem;
	memory2 *datamem;
	sample_clock_generator *s_c_g;
	
	typedef top SC_CURRENT_USER_MODULE;
  	top(sc_module_name name, char *contents_file)
	{
		instbs = "00";
		insthold = false;
		datahold = false;
		DUMMY_WIRE = WORD_ZERO;
		
		reset_gen1 = new reset_gen("reset-blok");
		reset_gen1->in_clk(in_clk);
		reset_gen1->reset(reset);
		
		//clock_gen1 = new clock_gen("clock-generator");
		//clock_gen1->in_clk(in_clk);
		
		mux_data = new mux("Multiplexer_Input");
		mux_data->in_0(dataread_m_dec);
		mux_data->in_1(DUMMY_WIRE); 
		mux_data->in_2(DUMMY_WIRE);
		mux_data->in_3(DUMMY_WIRE);
		mux_data->in_4(DUMMY_WIRE);
		mux_data->in_5(DUMMY_WIRE);
		mux_data->in_6(DUMMY_WIRE);
		mux_data->in_7(DUMMY_WIRE);
		mux_data->sel(selector);
		mux_data->out_mux(dataread_dec_cpu);
		
		
		decod = new decoder("DECODER_input");
		decod->sel(selector);
		decod->dataaddr(dataaddr);
		
		risc = new sc_risc("risc-processor");
		risc->in_clk(in_clk);
		risc->reset(reset);
		risc->instdataread(instdataread);
		risc->instdatawrite(instdatawrite);
		risc->instaddr(instaddr);
		risc->instreq(instreq);
		risc->instrw(instrw);
		risc->insthold(insthold);
		risc->dataread(dataread_dec_cpu);
		risc->datawrite(datawrite);
		risc->dataaddr(dataaddr);
		risc->datareq(datareq);
		risc->datarw(datarw);
		risc->databs(databs);
		risc->datahold(datahold);
		risc->data_addrl(data_addrl);
		risc->data_addrs(data_addrs);
		risc->DBUS(DBUS);
		risc->inst_addrl(inst_addrl);
		risc->IBUS(IBUS);
		risc->interrupt_signal(interrupt_signal);	//commentare questa riga per non generare interrupt
		//risc->interrupt_signal(interrupt_signal_2);	//commentare questa riga per generare interrupt
		
		instmem = new memory2("instruction-memory", contents_file);
		instmem->memoryname = "instruction-memory";
		instmem->in_clk(in_clk);
		instmem->reset(reset);
		instmem->memaddr(instaddr);
		instmem->memdataread(instdataread);
		instmem->memdatawrite(instdatawrite);
		instmem->memreq(instreq);
		instmem->memrw(instrw);
		instmem->membs(instbs);
		instmem->addrl(inst_addrl);
		instmem->addrs(inst_addrs);
		instmem->page_fault(IBUS);
		
		datamem = new memory2("data-memory", contents_file);
		datamem->memoryname = "data-memory";
		datamem->in_clk(in_clk);
		datamem->reset(reset);
		datamem->memaddr(dataaddr);
		datamem->memdataread(dataread_m_dec);
		datamem->memdatawrite(datawrite);
		datamem->memreq(datareq);
		datamem->memrw(datarw);
		datamem->membs(databs);
		datamem->addrl(data_addrl);
		datamem->addrs(data_addrs);
		datamem->page_fault(DBUS);
		
		s_c_g = new sample_clock_generator("sample_clock_generator");
		s_c_g->in_clk(in_clk);
		s_c_g->reset(reset);
		s_c_g->sample_clock(interrupt_signal);
		
		
		interrupt_signal_2.write(false);
	};
};
