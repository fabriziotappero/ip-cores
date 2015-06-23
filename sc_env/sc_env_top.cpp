#include "systemc.h"
#include "systemperl.h"
#include "verilated_vcd_c.h"
#include "env_memory.h"
#include "tv_responder.h"
#include "Vtv80s.h"
#include "VT16450.h"
#include "SpTraceVcd.h"
#include <unistd.h>
#include "z80_decoder.h"
#include "di_mux.h"

extern char *optarg;
extern int optind, opterr, optopt;

#define FILENAME_SZ 80

int sc_main(int argc, char *argv[])
{
	bool dumping = false;
	bool memfile = false;
	int index;
	char dumpfile_name[FILENAME_SZ];
	char mem_src_name[FILENAME_SZ];
	VerilatedVcdC *tfp;
    z80_decoder dec0 ("dec0");
	
	sc_clock clk("clk125", 8, SC_NS, 0.5);

	sc_signal<bool>	reset_n;
	sc_signal<bool>	wait_n;
	sc_signal<bool>	int_n;
	sc_signal<bool>	nmi_n;
	sc_signal<bool>	busrq_n;
	sc_signal<bool>	m1_n;
	sc_signal<bool>	mreq_n;
	sc_signal<bool>	iorq_n;
	sc_signal<bool>	rd_n;
	sc_signal<bool>	wr_n;
	sc_signal<bool>	rfsh_n;
	sc_signal<bool>	halt_n;
	sc_signal<bool>	busak_n;
	sc_signal<uint32_t>	di;
	sc_signal<uint32_t> di_mem;
	sc_signal<uint32_t> di_resp;
	sc_signal<uint32_t> di_uart;
	sc_signal<uint32_t>	dout;
	sc_signal<uint32_t>	addr;
	
    sc_signal<bool> uart_cs_n, serial, cts_n, dsr_n, ri_n, dcd_n;
    sc_signal<bool> baudout, uart_int;
    
	while ( (index = getopt(argc, argv, "d:i:k")) != -1) {
		printf ("DEBUG: getopt optind=%d index=%d char=%c\n", optind, index, (char) index);
		if  (index == 'd') {
			strncpy (dumpfile_name, optarg, FILENAME_SZ);
			dumping = true;
			printf ("VCD dump enabled to %s\n", dumpfile_name);
		} else if (index == 'i') {
			strncpy (mem_src_name, optarg, FILENAME_SZ);
			memfile = true;
		} else if (index == 'k') {
			printf ("Z80 Instruction decode enabled\n");
			dec0.en_decode = true;
		}
	}

	Vtv80s tv80s ("tv80s");
	tv80s.A (addr);
	tv80s.reset_n (reset_n);
	tv80s.clk (clk);
	tv80s.wait_n (wait_n);
	tv80s.int_n (int_n);
	tv80s.nmi_n (nmi_n);
	tv80s.busrq_n (busrq_n);
	tv80s.m1_n (m1_n);
	tv80s.mreq_n (mreq_n);
	tv80s.iorq_n (iorq_n);
	tv80s.rd_n (rd_n);
	tv80s.wr_n (wr_n);
	tv80s.rfsh_n (rfsh_n);
	tv80s.halt_n (halt_n);
	tv80s.busak_n (busak_n);
	tv80s.di (di);
	tv80s.dout (dout);
	
	di_mux di_mux0("di_mux0");
	di_mux0.mreq_n (mreq_n);
	di_mux0.iorq_n (iorq_n);
	di_mux0.addr   (addr);
	di_mux0.di     (di);
	di_mux0.di_mem (di_mem);
	di_mux0.di_uart (di_uart);
	di_mux0.di_resp (di_resp);
	di_mux0.uart_cs_n (uart_cs_n);
	
    env_memory env_memory0("env_memory0");
    env_memory0.clk (clk);
    env_memory0.wr_data (dout);
    env_memory0.rd_data (di_mem);
    env_memory0.mreq_n (mreq_n);
    env_memory0.rd_n (rd_n);
    env_memory0.wr_n (wr_n);
    env_memory0.addr (addr);
    env_memory0.reset_n (reset_n);
    
    tv_responder tv_resp0("tv_resp0");
    tv_resp0.clk (clk);
    tv_resp0.reset_n (reset_n);
    tv_resp0.wait_n (wait_n);
    tv_resp0.int_n (int_n);
    tv_resp0.nmi_n (nmi_n);
    tv_resp0.busak_n (busak_n);
    tv_resp0.busrq_n (busrq_n);
    tv_resp0.m1_n (m1_n);
    tv_resp0.mreq_n (mreq_n);
    tv_resp0.iorq_n (iorq_n);
    tv_resp0.rd_n (rd_n);
    tv_resp0.wr_n (wr_n);
    tv_resp0.addr (addr);
    tv_resp0.di_resp (di_resp);
    tv_resp0.dout (dout);
    tv_resp0.halt_n (halt_n);
    
    dec0.clk (clk);
    dec0.m1_n (m1_n);
    dec0.addr (addr);
    dec0.mreq_n (mreq_n);
    dec0.rd_n (rd_n);
    dec0.wait_n (wait_n);
    dec0.di (di);
    dec0.reset_n (reset_n);
    
    VT16450 t16450 ("t16450");
    t16450.reset_n (reset_n);
    t16450.clk  (clk);
    t16450.rclk (clk);
    t16450.cs_n (uart_cs_n);
    t16450.rd_n (rd_n);
    t16450.wr_n (wr_n);
    t16450.addr (addr);    
    t16450.wr_data (dout);
    t16450.rd_data (di_uart);
    t16450.sin (serial);
    t16450.cts_n (cts_n);
    t16450.dsr_n (dsr_n);
    t16450.ri_n  (ri_n);
    t16450.dcd_n (dcd_n);
   
    t16450.sout (serial);
    t16450.rts_n (cts_n);
    t16450.dtr_n (dsr_n);
    t16450.out1_n (ri_n);
    t16450.out2_n (dcd_n);
    t16450.baudout (baudout);
    t16450.intr (uart_int);

    // create dumpfile
    /*
    sc_trace_file *trace_file;
    trace_file = sc_create_vcd_trace_file("sc_tv80_env");
    sc_trace (trace_file, clk, "clk");
    sc_trace (trace_file, reset_n, "reset_n");
    sc_trace (trace_file, wait_n, "wait_n");
    sc_trace (trace_file, int_n, "int_n");
    sc_trace (trace_file, nmi_n, "nmi_n");
    sc_trace (trace_file, busrq_n, "busrq_n");
    sc_trace (trace_file, m1_n, "m1_n");
    sc_trace (trace_file, mreq_n, "mreq_n");
    sc_trace (trace_file, iorq_n, "iorq_n");
    sc_trace (trace_file, rd_n, "rd_n");
    sc_trace (trace_file, wr_n, "wr_n");
    sc_trace (trace_file, halt_n, "halt_n");
    sc_trace (trace_file, busak_n, "busak_n");
    sc_trace (trace_file, di, "di");
    sc_trace (trace_file, dout, "dout");
    sc_trace (trace_file, addr, "addr");
    */
    
    // Start Verilator traces
    if (dumping) {
    	Verilated::traceEverOn(true);
    	tfp = new VerilatedVcdC;
    	tv80s.trace (tfp, 99);
    	tfp->open (dumpfile_name);
    }

	// check for command line argument
	if (memfile) {
		printf ("Loading IHEX file %s\n", mem_src_name);
		env_memory0.load_ihex (mem_src_name);
	}
	
	// set reset to 0 before sim start
	reset_n.write (0);

    sc_start();
    /*
    sc_close_vcd_trace_file (trace_file);
    */
    if (dumping)
    	tfp->close();
    
    return 0;
}
