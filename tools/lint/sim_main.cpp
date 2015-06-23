#include "VTB.h"
#include "verilated.h"

VTB *TB;
unsigned int main_time = 0;
double sc_time_stamp () {
  return main_time;
}

int main(int argc, char **argv) {
Verilated::commandArgs(argc, argv);


TB = new VTB;
TB-> reset = 1;




while (!Verilated::gotFinish()) 

{
if (main_time > 100) {
TB->reset = 0;
// Deassert reset
}
if ((main_time % 10) == 1) {
TB->clk = 1;
// Toggle clock
}
if ((main_time % 10) == 6) {
TB->clk = 0;
}




TB->eval();
// Evaluate model



main_time++;





}


exit(0);
}

