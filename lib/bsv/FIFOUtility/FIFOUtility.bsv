import FIFO::*;
import FIFOF::*;
import Clocks::*;
import GetPut::*;

function FIFO#(fifo_type) guardedfifofToFifo( FIFOF#(fifo_type) fifo);

 FIFO#(fifo_type) f = interface FIFO#(fifo_type);
                          method first = fifo.first;
                          method enq = fifo.enq;
                          method deq = fifo.deq;
                          method clear = fifo.clear;
                      endinterface;                         
  return f;
endfunction

function Get#(fifo_type) syncFifoToGet( SyncFIFOIfc#(fifo_type) fifo);
  Get#(fifo_type) f = interface Get#(fifo_type);
                        method ActionValue#(fifo_type) get();
                          fifo.deq;
                          return fifo.first;
                        endmethod
                      endinterface;
  return f; 
endfunction

function Put#(fifo_type) syncFifoToPut( SyncFIFOIfc#(fifo_type) fifo);
  Put#(fifo_type) f = interface Put#(fifo_type);
                        method Action put(fifo_type data);
                          fifo.enq(data);
                        endmethod
                      endinterface; 
  return f;
endfunction