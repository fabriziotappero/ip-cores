import RegFile::*;

import "BDPI" function Action writeValueCRegFileFull(Bit#(64) pointer, Bit#(32) index, Bit#(32) value);
import "BDPI" function ActionValue#(Bit#(64)) resetInitCRegFileFull(Bit#(32) size, String str);
import "BDPI" function Bit#(32) readValueCRegFileFull(Bit#(64) pointer, Bit#(32) index);


module mkCRegFileFull#(String str) (RegFile#(addrType,dataType))
  provisos(Bits#(dataType, dataTypeSize),
           Add#(dataTypeSize,x,32),
           Bits#(addrType, addrTypeSize),
           Add#(addrTypeSize,y,32));

  Reg#(Bool) initialized <- mkReg(False);
  Reg#(Bit#(64)) pointer <- mkReg(0); // 0 will def segfault
  Reg#(Bool) hackReg <- mkReg(False);

  /* assume a negative reset, lalala 
   * the first time this function gets called, we'll 
   * set up a pointer.  */
  rule resetRule(!initialized);
    //let str <- $swriteAV("%m");
    let ptr <- resetInitCRegFileFull(1<<fromInteger(valueof(addrTypeSize)), str);   
    pointer <= ptr;
    initialized <= True;
    hackReg <= True;
  endrule
  
  method Action upd(addrType addr, dataType data) if(initialized);
    writeValueCRegFileFull(pointer, zeroExtend(pack(addr)), zeroExtend(pack(data)));
    hackReg <= True;
  endmethod

  method dataType sub(addrType addr) if(initialized && hackReg);
    dataType retvalue = unpack(truncate(readValueCRegFileFull(pointer, zeroExtend(pack(addr)))));
    return retvalue;
  endmethod
  
endmodule