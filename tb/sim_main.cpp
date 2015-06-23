             #include "Vtb_top_gate.h"
             #include "verilated.h"

             vluint64_t main_time = 0;       // Current simulation time

            double sc_time_stamp () {        // Called by $time in Verilog
                 return main_time;           // converts to double, to match
                                             // what SystemC does
            }
	    	     
		     
             int main(int argc, char **argv, char **env) {
                 Verilated::commandArgs(argc, argv);
                 Vtb_top_gate* top = new Vtb_top_gate;
		 top->rstn = 0;
		 top->RXD = 1;
 
            while (!Verilated::gotFinish()) {
                if  (main_time > 30)       { top->rstn = 1; }  // Deassert reset
                if ((main_time % 10) == 1) { top->clk  = 1; }  // Toggle clock
                if ((main_time % 10) == 6) { top->clk  = 0; }
                top->eval();            // Evaluate model
                main_time++;            // Time passes...
            }		 

                 delete top;
                 exit(0);
             }

