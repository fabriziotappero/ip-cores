package IFPGA_FIFO;

import FIFO::*;

interface IFPGA_FIFO#(type f_type, numeric type size);
   // Interface for memory, input generator
   interface FIFO#(f_type) fifo;
endinterface

endpackage