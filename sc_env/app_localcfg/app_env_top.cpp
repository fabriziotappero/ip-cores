#include "systemc.h"
#include "systemperl.h"
//#include "env_memory.h"

//#include "SpTraceVcd.h"
#include "verilated_vcd_sc.h"
#include <unistd.h>
#include "it_cfg_driver.h"
#include "it_cfg_monitor.h"
#include "Vlcfg.h"
#include "load_ihex.h"
#include <assert.h>

extern char *optarg;
extern int optind, opterr, optopt;

#define FILENAME_SZ 80
#define MAX_MEM_SIZE 32768

int sc_main(int argc, char *argv[])
{
  bool dumping = false;
  bool memfile = false;
  int index;
  char dumpfile_name[FILENAME_SZ];
  char mem_src_name[FILENAME_SZ];
  uint8_t memory[MAX_MEM_SIZE];
  VerilatedVcdSc *tfp;
  int run_time = 5; // in microseconds
  //z80_decoder dec0 ("dec0");

  sc_clock clk("clk125", 8, SC_NS, 0.5);

  sc_signal<bool> reset_n;
  sc_signal<bool>  lcfg_init;
  sc_signal<bool>  lcfg_proc_reset;

  sc_signal<bool>      cfgi_irdy;
  sc_signal<bool>      cfgi_trdy;
  sc_signal<uint32_t>  cfgi_addr;
  sc_signal<bool>      cfgi_write;
  sc_signal<uint32_t>  cfgi_wr_data;
  sc_signal<uint32_t>  cfgi_rd_data;

  // outgoing config interface to system
  // configuration bus
  sc_signal<bool>      cfgo_irdy;
  sc_signal<bool>      cfgo_trdy;
  sc_signal<uint32_t>  cfgo_addr;
  sc_signal<bool>      cfgo_write;
  sc_signal<uint32_t>  cfgo_wr_data;
  sc_signal<uint32_t>  cfgo_rd_data;

  // clear program memory
  for (int i=0; i<MAX_MEM_SIZE; i++) memory[i] = 0;

  while ( (index = getopt(argc, argv, "d:i:t:")) != -1) {
    printf ("DEBUG: getopt optind=%d index=%d char=%c\n", optind, index, (char) index);
    if  (index == 'd') {
      strncpy (dumpfile_name, optarg, FILENAME_SZ);
      dumping = true;
      printf ("VCD dump enabled to %s\n", dumpfile_name);
    } else if (index == 'i') {
      strncpy (mem_src_name, optarg, FILENAME_SZ);
      memfile = true;
    } else if (index == 't') {
      run_time = atoi (optarg);
      assert (run_time > 0);
      printf ("Running for %d microseconds\n", run_time);
    } else {
      printf ("Unknown index %c\n", (char) index);
    }
  }

  Vlcfg lcfg ("lcfg");
  lcfg.clk (clk);
  lcfg.reset_n(reset_n);
  lcfg.lcfg_init (lcfg_init);
  lcfg.lcfg_proc_reset (lcfg_proc_reset);

  lcfg.cfgi_irdy(cfgi_irdy);
  lcfg.cfgi_trdy(cfgi_trdy);
  lcfg.cfgi_addr(cfgi_addr);
  lcfg.cfgi_write(cfgi_write);
  lcfg.cfgi_rd_data(cfgi_rd_data);
  lcfg.cfgi_wr_data(cfgi_wr_data);

  lcfg.cfgo_irdy(cfgo_irdy);
  lcfg.cfgo_trdy(cfgo_trdy);
  lcfg.cfgo_addr(cfgo_addr);
  lcfg.cfgo_write(cfgo_write);
  lcfg.cfgo_rd_data(cfgo_rd_data);
  lcfg.cfgo_wr_data(cfgo_wr_data);

  it_cfg_driver driver ("driver");
  driver.clk (clk);
  driver.reset_n(reset_n);

  driver.cfgi_irdy(cfgi_irdy);
  driver.cfgi_trdy(cfgi_trdy);
  driver.cfgi_addr(cfgi_addr);
  driver.cfgi_write(cfgi_write);
  driver.cfgi_rd_data(cfgi_rd_data);
  driver.cfgi_wr_data(cfgi_wr_data);

  it_cfg_monitor monitor ("monitor");
  monitor.clk (clk);
  monitor.reset_n(reset_n);

  monitor.cfgo_irdy(cfgo_irdy);
  monitor.cfgo_trdy(cfgo_trdy);
  monitor.cfgo_addr(cfgo_addr);
  monitor.cfgo_write(cfgo_write);
  monitor.cfgo_rd_data(cfgo_rd_data);
  monitor.cfgo_wr_data(cfgo_wr_data);


  //env_memory env_memory0("env_memory0");

  // Start Verilator traces
  if (dumping) {
    Verilated::traceEverOn(true);
    tfp = new VerilatedVcdSc;
    lcfg.trace (tfp, 99);
    tfp->open (dumpfile_name);
  }

  // check for command line argument
  if (memfile) {
    int max, bused = 0;
    uint32_t cword;
    max = load_ihex (mem_src_name, memory, MAX_MEM_SIZE);
    printf ("Loading IHEX file %s, max addr=%d\n", mem_src_name, max);
    while (bused <= max) {
      cword = 0;
      for (int i=0; i<4; i++) cword |= (memory[bused++] << (i*8));
      //printf ("Queueing %x\n", cword);
      driver.add_queue (cword);
    }
  }

  // set reset to 0 before sim start
  reset_n.write (0);
  lcfg_proc_reset.write(1);

  //sc_time *runtime = new sc_time(100, SC_NS);
  sc_time time100(100, SC_NS);
  sc_start(time100);

  reset_n.write (1);

  //delete runtime; runtime = new sc_time (1000, SC_NS);
  sc_start (sc_time(2500,SC_NS));
  lcfg_proc_reset.write(0);

  sc_start (sc_time(run_time, SC_US));

  /*
  sc_close_vcd_trace_file (trace_file);
  */
  if (dumping)
    tfp->close();

  return 0;
}
