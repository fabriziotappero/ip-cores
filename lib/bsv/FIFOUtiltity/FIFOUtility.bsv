import FIFO::*;
import FIFOF::*;

function FIFO#(fifo_type) guardedfifofToFifo( FIFOF#(fifo_type) fifo);

 FIFO#(fifo_type) f = interface FIFO#(fifo_type);
                          method first = fifo.first;
                          method enq = fifo.enq;
                          method deq = fifo.deq;
                          method clear = fifo.clear;
                      endinterface;                         
  return f;
endfunction
