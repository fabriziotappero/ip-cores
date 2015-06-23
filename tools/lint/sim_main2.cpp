#include "VTB.h"
#include "verilated.h"
#include "verilated_vcd_c.h"


int main(int argc, char **argv, char **env) {
  int i;
  int clk;

  int  timeout = 10000;
  int  period  = 50;
 
  int  timepassed = 0;
  char result[] ="PASSED          ";
  char fail[]   ="FAILED - TIMEOUT";

  Verilated::commandArgs(argc, argv);
  // init top verilog instance
  VTB* top = new VTB;
  // init trace dump
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace (tfp, 99);
    tfp->open ("TestBench.vcd");
  // initialize simulation inputs
    //    printf("Hello,World %i   \n",argc);

    if(argc == 2)
      {
	timeout = atoi(argv[1]);
      }

    if(argc == 3)
      {
	timeout = atoi(argv[1]);
        period  = atoi(argv[2]);
      }




    printf("Simulating timeout    %i   period  %i    \n",timeout ,period);


  top->clk = 0;
  top->START = 0;
  // run simulation till the end
  i=0;
  while ( !top->FINISH   ) 
      {
      top->START = (i > 12);
      // dump variables into VCD file and toggle clock


          {
	  clk = 0;
          tfp->dump (40*i+clk);
          top->clk = !top->clk;
          top->eval ();

	  clk = 20;
          tfp->dump (40*i+clk);
          top->clk = !top->clk;
          top->eval ();


          }
    if (Verilated::gotFinish())  exit(0);
    timepassed++;
    i++;
    if(timepassed > timeout)
      {
	strcpy(result,fail);
        break;
      }

      }


  printf("Finished   %i  -  %s   \n", timepassed , result);
   tfp->close();
  exit(0);
}



