import Vector::*;
import ActionSeq::*;
import FIFOF::*;
import FIFO::*;
import GetPut::*;
import ClientServer::*;
import Register::*;

interface ControlReg#(type addr_t, type data_t);
   method addr_t getAddr();
   method Action write(data_t x1);
   method ActionValue#(data_t) read();
endinterface      

// function makeControlRegFromRAM(TBDRegisterMap regNum, HSTDEC_OCP_RAM_module_addr_t inc,
//    FIFO#(HSTDEC_OCP_RAM_module_addr_t));
//    begin
//       ControlReg#(HSTDEC_OCP_RAM_addr_t, HSTDEC_OCP_RAM_data_t) cr =
//       interface ControlReg
//       method HSTDEC_OCP_RAM_addr_t getAddr();
// 	 return zeroExtend(pack(regNum));
//       endmethod
//       method Action write(HSTDEC_OCP_RAM_data_t data);
// 	 begin
// 	    tbdRegs.hstRamAddr <= tbdRegs.hstRamAddr + inc;
// 	    (determineMemory(curTBD,tbdRegs)).writeReq.put(tuple2(truncate(tbdRegs.hstRamAddr),data));
// 	 end
//       endmethod
//       method ActionValue#(HSTDEC_OCP_RAM_data_t) read();
// 	 begin
// 	    let mem = (determineMemory(curTBD,tbdRegs));
// 	    debugModule(hstdecDebug, $display("HSTDEC Pushing read request"));
// 	    mem.readReq.put(truncate(tbdRegs.hstRamAddr)); 
// 	    state <= Read;
// 	    read_inc_fifo.enq(inc);
// 	    return ?;
// 	 end
//       endmethod
//       endinterface;
//       return cr;
//    end

//    rule complete_read;
//       let inc = read_inc_fifo.first; read_inc_fifo.deq;
//       let mem = (determineMemory(curTBD,tbdRegs));
//       tbdRegs.hstRamAddr <= tbdRegs.hstRamAddr + signExtend(inc);
//       let data <- mem.readResp().get();
//       resp_fifo.enq(data);
//    endrule
// endfunction



// function ControlReg#(addrT, dataT) mkControlReg(addrT addr,
// 						function regDataT get(),
// 						   function Action put(regDataT))
//    provisos (Bits#(regDataT, regDataSz),
// 	     Bits#(dataT, dataSz),
// 	     Add#(regDataSz,aaa,dataSz));
//    ControlReg#(addrT, dataT) cr =
//    interface ControlReg;
//    method addrT getAddr();
//       return addr;
//    endmethod
//    method Action write(dataT data);
//       let foo <- put(unpack(truncate(pack(data))));
//    endmethod
//    method ActionValue#(dataT) read();
//       let data <- get();
//       return unpack(zeroExtend(pack(data)));
//    endmethod
//    endinterface;
//    return cr;
// endfunction						     



function ControlReg#(addrT, dataT) mkControlRegFromReg(addrT addr,
						       Reg#(dataT) r)
   provisos (//Bits#(regDataT, regDataSz),
	     Bits#(dataT, dataSz)
	     //Add#(regDataSz,aaa,dataSz)
	     );
   ControlReg#(addrT, dataT) cr =
   interface ControlReg;
   method addrT getAddr();
      return addr;
   endmethod
   method Action write(dataT data);
      r._write(data);
   endmethod
   method ActionValue#(dataT) read();
      let data = r._read();
      return data;
   endmethod
   endinterface;
   return cr;
endfunction						     

function ControlReg#(addrT, dataT) mkControlRegFromGet(addrT addr,
						       Get#(dataT) get)
   provisos (Bits#(dataT, dataSz));
   ControlReg#(addrT, dataT) cr =
   interface ControlReg;
   method addrT getAddr();
      return addr;
   endmethod
   method Action write(dataT data);
      // no write method
   endmethod
   method ActionValue#(dataT) read();
      let data <- get.get();
      return data;
   endmethod
   endinterface;
   return cr;
endfunction						     

function ControlReg#(addrT, dataT) mkControlRegFromGetPut(addrT addr,
							  Get#(dataT) get,
							  Put#(dataT) put)
   provisos (Bits#(dataT, dataSz));
   ControlReg#(addrT, dataT) cr =
   interface ControlReg;
   method addrT getAddr();
      return addr;
   endmethod
   method Action write(dataT data);
      put.put(data);
   endmethod
   method ActionValue#(dataT) read();
      let data <- get.get();
      return data;
   endmethod
   endinterface;
   return cr;
endfunction						     

function ControlReg#(addrT, dataT) mkControlRegFromServer(addrT addr,
							  Server#(dataT, dataT) server)
   provisos (Bits#(dataT, dataSz));
   ControlReg#(addrT, dataT) cr =
   interface ControlReg;
   method addrT getAddr();
      return addr;
   endmethod
   method Action write(dataT data);
      server.request.put(data);
   endmethod
   method ActionValue#(dataT) read();
      let data <- server.response.get();
      return data;
   endmethod
   endinterface;
   return cr;
endfunction						     

function Vector#(n, ControlReg#(addrT, dataT))
	 addControlReg(Vector#(n, ControlReg#(addrT, dataT)) crvec,
			      regNumT regNum,
			      ControlReg#(addrT, dataT) cr)
      provisos (Bits#(regNumT, regNumSz),
		Bits#(addrT, addrSz),
		Bits#(dataT, ramDataSz),
		Add#(regNumSz,aaa,addrSz));
   crvec[zeroExtend(pack(regNum))] = cr;      
   return crvec;
endfunction						     

function Vector#(n, ControlReg#(addrT, dataT))
	 addControlRegFromReg(Vector#(n, ControlReg#(addrT, dataT)) crvec,
			      regNumT regNum,
			      Reg#(dataT) r)
      provisos (Bits#(regNumT, regNumSz),
		Bits#(addrT, addrSz),
		Bits#(dataT, ramDataSz),
		Add#(regNumSz,aaa,addrSz)
		);
   ControlReg#(addrT, dataT) cr = 
      mkControlRegFromReg(unpack(zeroExtend(pack(regNum))), r);
   crvec[zeroExtend(pack(regNum))] = cr;      
   return crvec;
endfunction						     

function Vector#(n, ControlReg#(addrT, dataT))
	 addControlRegFromGet(Vector#(n, ControlReg#(addrT, dataT)) crvec,
			      regNumT regNum,
			      Get#(dataT) g)
      provisos (Bits#(dataT, ramDataSz),
                Bits#(regNumT, regNumSz),
		Bits#(addrT, addrSz),
		Add#(regNumSz,aaa,addrSz));
   ControlReg#(addrT, dataT) cr =
      mkControlRegFromGet(unpack(zeroExtend(pack(regNum))), g);
   crvec[zeroExtend(pack(regNum))] = cr;      
   return crvec;
endfunction						     

function Vector#(n, ControlReg#(addrT, dataT))
	 addControlRegFromGetPut(Vector#(n, ControlReg#(addrT, dataT)) crvec,
			         regNumT regNum,
			         Get#(dataT) g,
			         Put#(dataT) p)
      provisos (Bits#(dataT, ramDataSz),
                Bits#(regNumT, regNumSz),
		Bits#(addrT, addrSz),
		Add#(regNumSz,aaa,addrSz));
   ControlReg#(addrT, dataT) cr =
      mkControlRegFromGetPut(unpack(zeroExtend(pack(regNum))), g, p);
   crvec[pack(regNum)] = cr;      
   return crvec;
endfunction						     

function ControlReg#(addrT, dataT) widenControlReg(ControlReg#(nAddrT, nDataT) ncr)
   provisos (Bits#(addrT, addrSz),
	     Bits#(dataT, dataSz),
	     Bits#(nAddrT, nAddrSz),
	     Bits#(nDataT, nDataSz),
	     Add#(nDataSz,ddd,dataSz),
	     Add#(nAddrSz,aaa,addrSz));
   ControlReg#(addrT, dataT) cr =
   interface ControlReg;
   method addrT getAddr();
      return unpack(zeroExtend(pack(ncr.getAddr())));
   endmethod
   method Action write(dataT data);
      ncr.write(unpack(truncate(pack(data))));
   endmethod
   method ActionValue#(dataT) read();
      let data <- ncr.read();
      return unpack(zeroExtend(pack(data)));
   endmethod
   endinterface;
   return cr;
endfunction						     


