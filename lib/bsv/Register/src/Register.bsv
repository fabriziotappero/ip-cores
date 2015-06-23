import Vector::*;
import ActionSeq::*;
import FIFOF::*;
import FIFO::*;
import GetPut::*;
import ClientServer::*;



function Tuple2#(Reg#(Bit#(aDataSz)),Reg#(Bit#(bDataSz))) splitReg(Reg#(Bit#(wDataSz)) wr)
  provisos(Add#(aDataSz,bDataSz,wDataSz));
  Reg#(Bit#(aDataSz)) areg = interface Reg
    method Action _write(Bit#(aDataSz) newa);
      Tuple2#(Bit#(aDataSz),Bit#(bDataSz)) oldtpl = split(wr);
      match { .olda, .oldb } = oldtpl;
      wr <= { newa, oldb };
    endmethod
    method Bit#(aDataSz) _read();
      Tuple2#(Bit#(aDataSz),Bit#(bDataSz)) oldtpl = split(wr);
      match { .olda, .oldb } = oldtpl;
      return olda;
    endmethod
  endinterface;
  Reg#(Bit#(bDataSz)) breg = interface Reg
    method Action _write(Bit#(bDataSz) newb);
      Tuple2#(Bit#(aDataSz),Bit#(bDataSz)) oldtpl = split(wr);
      match { .olda, .oldb } = oldtpl;
      wr <= { olda, newb };
    endmethod
    method Bit#(bDataSz) _read();
      Tuple2#(Bit#(aDataSz),Bit#(bDataSz)) oldtpl = split(wr);
      match { .olda, .oldb } = oldtpl;
      return oldb;
    endmethod
  endinterface;
  return tuple2(areg,breg);
endfunction

function Reg#(Bit#(dataSz)) invertReg(Reg#(Bit#(dataSz)) oldr);
  Reg#(Bit#(dataSz)) r = interface Reg;
    method Action _write(Bit#(dataSz) v);
      oldr <= ~v;
    endmethod
    method Bit#(dataSz) _read();
      return ~oldr;
    endmethod
  endinterface;
  return r;
endfunction

function Reg#(dataT) mirrorReg(Reg#(dataT) areg, Reg#(dataT) breg);
  Reg#(dataT) r = interface Reg;
    method Action _write(dataT v);
      areg <= v;
      breg <= v;
    endmethod
    method dataT _read();
      dataT aval = areg;
      dataT bval = breg;
      return aval;
    endmethod
  endinterface;
  return r;
endfunction

function Reg#(dataT) mkZeroReg()
  provisos (Literal#(dataT));
  Reg#(dataT) r = interface Reg;
    method Action _write(dataT v);
    endmethod
    method dataT _read();
      return 0;
    endmethod
  endinterface;
  return r;
endfunction

function Reg#(Bit#(1)) pulsewireSendReadReg(PulseWire pulsewire, Reg#(Bit#(1)) rd);
  Reg#(Bit#(1)) r = interface Reg;
    method Action _write(Bit#(1) v);
      if (v == 1) pulsewire.send();
    endmethod
    method Bit#(1) _read();
      return rd;
    endmethod
  endinterface;
  return r;
endfunction

function Reg#(Bit#(1)) rwireSetReadReg(RWire#(Bit#(1)) rwire, Reg#(Bit#(1)) rd);
  Reg#(Bit#(1)) r = interface Reg;
    method Action _write(Bit#(1) v);
      if (v == 1) rwire.wset(1);
    endmethod
    method Bit#(1) _read();
      return rd;
    endmethod
  endinterface;
  return r;
endfunction


function Reg#(Bit#(1)) rwireClearReadReg(RWire#(Bit#(1)) rwire, Reg#(Bit#(1)) rd);
  Reg#(Bit#(1)) r = interface Reg;
    method Action _write(Bit#(1) v);
      if (v == 0) rwire.wset(0);
    endmethod
    method Bit#(1) _read();
      return ~rd;
    endmethod
  endinterface;
  return r;
endfunction

function Reg#(Bit#(1)) mkSetReadReg(Reg#(Bit#(1)) oldr);
  Reg#(Bit#(1)) r = interface Reg;
    method Action _write(Bit#(1) v);
      if (v == 1) oldr <= v;
    endmethod
    method Bit#(1) _read();
      return oldr;
    endmethod
  endinterface;
  return r;
endfunction
function Reg#(Bit#(1)) mkClearReadReg(Reg#(Bit#(1)) oldr);
  Reg#(Bit#(1)) r = interface Reg;
    method Action _write(Bit#(1) v);
      if (v == 0) oldr <= v;
    endmethod
    method Bit#(1) _read();
      return ~oldr;
    endmethod
  endinterface;
  return r;
endfunction

function Reg#(dataT) constantReg(dataT v);
  Reg#(dataT) r = interface Reg;
    method Action _write(dataT v);
    endmethod
    method dataT _read();
      return v;
    endmethod
  endinterface;
  return r;
endfunction

function Reg#(dataT) readOnlyRegFromReg(Reg#(dataT) areg);
  Reg#(dataT) r = interface Reg;
    method Action _write(dataT v);
    endmethod
    method dataT _read();
      return areg;
    endmethod
  endinterface;
  return r;
endfunction

function Reg#(regType) mkRegFromActions(function regType readAction(), function Action writeAction(regType value));
  Reg#(regType) regIfc = interface Reg;
                           method regType _read();
                             return readAction;
                           endmethod
 
                           method Action _write(regType value);
                             writeAction(value);
                           endmethod
                         endinterface;
  return regIfc;
endfunction

function Reg#(Bit#(dataSz)) toBitsReg(Reg#(dataT) areg)
  provisos(Bits#(dataT, dataSz));
  Reg#(Bit#(dataSz)) r = interface Reg;
    method Action _write(Bit#(dataSz) v);
      areg <= unpack(v);
    endmethod
    method Bit#(dataSz) _read();
      return pack(areg);
    endmethod
  endinterface;
  return r;
endfunction

function Reg#(dataT) fromBitsReg(Reg#(Bit#(dataSz)) areg)
  provisos(Bits#(dataT, dataSz));
  Reg#(dataT) r = interface Reg;
    method Action _write(dataT v);
      areg <= pack(v);
    endmethod
    method dataT _read();
      return unpack(areg);
    endmethod
  endinterface;
  return r;
endfunction

function Reg#(Tuple2#(aDataT,bDataT)) zipReg(Reg#(aDataT) areg, Reg#(bDataT) breg);
  Reg#(Tuple2#(aDataT,bDataT)) r = interface Reg;
    method Action _write(Tuple2#(aDataT,bDataT) v);
      match { .av, .bv } = v;
      areg <= av;
      breg <= bv;
    endmethod
    method Tuple2#(aDataT,bDataT) _read();
      return tuple2(areg, breg);
    endmethod
  endinterface;
  return r;
endfunction


function Reg#(Tuple3#(aDataT,bDataT,cDataT)) zipReg3(Reg#(aDataT) areg, 
	 				     	    Reg#(bDataT) breg,
	 				     	    Reg#(cDataT) creg);
  Reg#(Tuple3#(aDataT,bDataT,cDataT)) r = interface Reg;
    method Action _write(Tuple3#(aDataT,bDataT,cDataT) v);
      match { .av, .bv, .cv } = v;
      areg <= av;
      breg <= bv;
      creg <= cv;
    endmethod
    method Tuple3#(aDataT,bDataT,cDataT) _read();
      return tuple3(areg, breg, creg);
    endmethod
  endinterface;
  return r;
endfunction


function Reg#(Tuple4#(aDataT,bDataT,cDataT,dDataT)) zipReg4(Reg#(aDataT) areg, 
	 	 				     	    Reg#(bDataT) breg,
							    Reg#(cDataT) creg,
	 				     	            Reg#(dDataT) dreg);
  Reg#(Tuple4#(aDataT,bDataT,cDataT,dDataT)) r = interface Reg;
    method Action _write(Tuple4#(aDataT,bDataT,cDataT,dDataT) v);
      match { .av, .bv, .cv, .dv } = v;
      areg <= av;
      breg <= bv;
      creg <= cv;
      dreg <= dv;
    endmethod
    method Tuple4#(aDataT,bDataT,cDataT,dDataT) _read();
      return tuple4(areg, breg, creg, dreg);
    endmethod
  endinterface;
  return r;
endfunction


function Reg#(Tuple5#(aDataT,bDataT,cDataT,dDataT,eDataT)) zipReg5(Reg#(aDataT) areg, 
							Reg#(bDataT) breg,
							Reg#(cDataT) creg,
							Reg#(dDataT) dreg,
							Reg#(eDataT) ereg);
  Reg#(Tuple5#(aDataT,bDataT,cDataT,dDataT,eDataT)) r = interface Reg;
    method Action _write(Tuple5#(aDataT,bDataT,cDataT,dDataT,eDataT) v);
      match { .av, .bv, .cv, .dv, .ev } = v;
      areg <= av;
      breg <= bv;
      creg <= cv;
      dreg <= dv;
      ereg <= ev;
    endmethod
    method Tuple5#(aDataT,bDataT,cDataT,dDataT,eDataT) _read();
      return tuple5(areg, breg, creg, dreg, ereg);
    endmethod
  endinterface;
  return r;
endfunction


function Reg#(Tuple6#(aDataT,bDataT,cDataT,dDataT,eDataT,fDataT)) zipReg6(Reg#(aDataT) areg, 
							Reg#(bDataT) breg,
							Reg#(cDataT) creg,
							Reg#(dDataT) dreg,
							Reg#(eDataT) ereg,
							Reg#(fDataT) freg);
  Reg#(Tuple6#(aDataT,bDataT,cDataT,dDataT,eDataT,fDataT)) r = interface Reg;
    method Action _write(Tuple6#(aDataT,bDataT,cDataT,dDataT,eDataT,fDataT) v);
      match { .av, .bv, .cv, .dv, .ev, .fv } = v;
      areg <= av;
      breg <= bv;
      creg <= cv;
      dreg <= dv;
      ereg <= ev;
      freg <= fv;
    endmethod
    method Tuple6#(aDataT,bDataT,cDataT,dDataT,eDataT,fDataT) _read();
      return tuple6(areg, breg, creg, dreg, ereg, freg);
    endmethod
  endinterface;
  return r;
endfunction


function Reg#(Tuple7#(aDataT,bDataT,cDataT,dDataT,eDataT,fDataT,gDataT)) zipReg7(Reg#(aDataT) areg, 
							Reg#(bDataT) breg,
							Reg#(cDataT) creg,
							Reg#(dDataT) dreg,
							Reg#(eDataT) ereg,
							Reg#(fDataT) freg,
							Reg#(gDataT) greg);
  Reg#(Tuple7#(aDataT,bDataT,cDataT,dDataT,eDataT,fDataT,gDataT)) r = interface Reg;
    method Action _write(Tuple7#(aDataT,bDataT,cDataT,dDataT,eDataT,fDataT,gDataT) v);
      match { .av, .bv, .cv, .dv, .ev, .fv, .gv } = v;
      areg <= av;
      breg <= bv;
      creg <= cv;
      dreg <= dv;
      ereg <= ev;
      freg <= fv;
      greg <= gv;
    endmethod
    method Tuple7#(aDataT,bDataT,cDataT,dDataT,eDataT,fDataT,gDataT) _read();
      return tuple7(areg, breg, creg, dreg, ereg, freg, greg);
    endmethod
  endinterface;
  return r;
endfunction
typedef struct {
   aDataT av; bDataT bv; cDataT cv; dDataT dv; eDataT ev; fDataT fv; gDataT gv; hDataT hv;
} Zip8#(type aDataT, type bDataT, type cDataT, type dDataT, type eDataT, type fDataT, type gDataT, type hDataT) deriving (Bits,Eq);


function Reg#(Zip8#(aDataT,bDataT,cDataT,dDataT,eDataT,fDataT,gDataT,hDataT)) zipReg8(Reg#(aDataT) areg, 
							Reg#(bDataT) breg,
							Reg#(cDataT) creg,
							Reg#(dDataT) dreg,
							Reg#(eDataT) ereg,
							Reg#(fDataT) freg,
							Reg#(gDataT) greg,
							Reg#(hDataT) hreg);
  Reg#(Zip8#(aDataT,bDataT,cDataT,dDataT,eDataT,fDataT,gDataT,hDataT)) r = interface Reg;
    method Action _write(Zip8#(aDataT,bDataT,cDataT,dDataT,eDataT,fDataT,gDataT,hDataT) v);
      match tagged Zip8 { av: .av, bv: .bv, cv: .cv, dv: .dv, ev: .ev, fv: .fv, gv: .gv, hv: .hv } = v;
      areg <= av;
      breg <= bv;
      creg <= cv;
      dreg <= dv;
      ereg <= ev;
      freg <= fv;
      greg <= gv;
      hreg <= hv;
    endmethod
    method Zip8#(aDataT,bDataT,cDataT,dDataT,eDataT,fDataT,gDataT,hDataT) _read();
      return Zip8 { av: areg, bv: breg, cv: creg, dv: dreg, ev: ereg, fv: freg, gv: greg, hv: hreg};
    endmethod
  endinterface;
  return r;
endfunction



function Reg#(Bool) eqReg(Reg#(dataT) areg, Reg#(dataT) breg, function Bool eq(dataT a, dataT b))
  provisos (Eq#(dataT));
  Reg#(Bool) r = interface Reg;
    method Action _write(Bool v);
    endmethod
    method Bool _read();
      dataT aval = areg;
      dataT bval = breg;
      return eq(aval,bval);
    endmethod
  endinterface;
  return r;
endfunction
function Reg#(dataT) andReg(Reg#(dataT) areg, Reg#(dataT) breg)
  provisos (Bitwise#(dataT));
  Reg#(dataT) r = interface Reg;
    method Action _write(dataT v);
    endmethod
    method dataT _read();
      dataT aval = areg;
      dataT bval = breg;
      return aval;
    endmethod
  endinterface;
  return r;
endfunction



function Reg#(Bit#(1)) reduceReg(Reg#(Bit#(dataSz)) areg,
	 	       		  function Bit#(1) foldbit(Bit#(dataSz) a))
	 provisos(Add#(1,aaa,dataSz));
  Reg#(Bit#(1)) r = interface Reg;
    method Action _write(dataT v);
    endmethod
    method Bit#(1) _read();
      Bit#(dataSz) bits = areg;
      Bit#(1) r = foldbit(bits);
      return r;
    endmethod
  endinterface;
  return r;
endfunction


function Reg#(Bit#(dataSz)) widenRegLSB(Reg#(Bit#(nDataSz)) ncr)
   provisos (Add#(nDataSz,ddd,dataSz));
   Reg#(Bit#(dataSz)) wr =
   interface Reg;
   method Action _write(Bit#(dataSz) data);
      ncr._write(truncateLSB(data));
   endmethod
   method Bit#(dataSz) _read();
      let data = ncr._read();
      return zeroExtend(data)<<(fromInteger(valueof(ddd)));
   endmethod
   endinterface;
   return wr;
endfunction


function Reg#(Bit#(dataSz)) widenReg(Reg#(Bit#(nDataSz)) ncr)
   provisos (Add#(nDataSz,ddd,dataSz));
   Reg#(Bit#(dataSz)) wr =
   interface Reg;
   method Action _write(Bit#(dataSz) data);
      ncr._write(truncate(data));
   endmethod
   method Bit#(dataSz) _read();
      let data = ncr._read();
      return zeroExtend(data);
   endmethod
   endinterface;
   return wr;
endfunction


function Vector#(wholeRegs,Reg#(dest)) explodeRegister(Reg#(target) regTarget)
  provisos(Bits#(target,targetBits),
           Bits#(dest, destBits), 
           Div#(targetBits,destBits,wholeRegs),
           Add#(targetBits, extraBits, TMul#(wholeRegs, destBits)),
           Add#(otherExtraBits, destBits, TMul#(wholeRegs, destBits)));
  Reg#(Bit#(TMul#(wholeRegs,destBits))) bitTarget = widenReg(toBitsReg(regTarget));
  Vector#(wholeRegs,Reg#(Bit#(destBits))) resultVec = newVector;

  for(Integer i = 0, Integer index = 0; i < valueof(TMul#(wholeRegs,destBits)) ; index = index + 1, i = i + valueof(destBits))
    begin
      // perhaps cut up the reg             
      function Bit#(destBits) readAction(); 
        return bitTarget[i+valueof(destBits)-1:i];
      endfunction

      function Action writeAction(Bit#(destBits) res);
        action
          bitTarget[i+valueof(destBits)-1:i] <= res; // this truncate makes the type checker happy? Introduces a warning 
        endaction
      endfunction
      
      resultVec[index] = mkRegFromActions(readAction,writeAction);
    end  
  return Vector::map(fromBitsReg,resultVec);
endfunction


function ReadOnly#(data_t) readOnly(data_t data);
  ReadOnly#(data_t) ifc = interface ReadOnly#(data_t);
                            method _read = data;
                          endinterface;
  return ifc;
endfunction

function Reg#(data_t) readOnlyToRegister(ReadOnly#(data_t) data);
  Reg#(data_t) ifc = interface Reg#(data_t);
                       method _read = data;
                       method Action _write(data_t data);
                         $display("Read Only method has no write");
                       endmethod 
                     endinterface;
  return ifc;
endfunction