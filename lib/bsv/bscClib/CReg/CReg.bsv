
import "BDPI" function Action writeValue(Bit#(64) pointer, Bit#(32) value);
import "BDPI" function ActionValue#(Bit#(64)) resetInit(Bit#(32) value, String str);
import "BDPI" function Bit#(32) readValue(Bit#(64) pointer);


module mkCReg#(dataType initialValue, String str) (Reg#(dataType))
  provisos(Bits#(dataType, dataTypeSize),
           Add#(dataTypeSize,x,32));
  Reg#(Bool) initialized <- mkReg(False);
  Reg#(Bit#(64)) pointer <- mkReg(0); // 0 will def segfault
  Reg#(Bool) hackReg <- mkReg(False);

  /* assume a negative reset, lalala 
   * the first time this function gets called, we'll 
   * set up a pointer.  */
  rule resetRule(!initialized);
    //let str <- $swriteAV("%m");
    let ptr <- resetInit(zeroExtend(pack(initialValue)), str);   
    pointer <= ptr;
    initialized <= True;
    hackReg <= True;
  endrule
  
  method Action _write(dataType x1) if(initialized);
    writeValue(pointer, zeroExtend(pack(x1)));
    hackReg <= True;
  endmethod

  method dataType _read() if(initialized && hackReg);
    dataType retvalue = unpack(truncate(readValue(pointer)));
    return retvalue;
  endmethod
  
endmodule