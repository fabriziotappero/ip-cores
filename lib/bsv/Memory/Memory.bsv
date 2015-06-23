import FIFOF::*;
import Vector::*;

// Interfaces for Reading and writing zero latency (called Memory) and multi latency memories (called MemoryServer)
// Each of the interface has an empty method which is to say if there are no pending requests.

// Parameterizable number of read ports

// Implementation of Memory with zero latency Regfile (either the bluesim version appended with Sim or the verilog version, with no Sim)
// Implementation of MemoryServer with exactly 1 latency Bram ( ditto )

// TODO: Parameterized write ports, coming up *soon*

interface ReadReq#(numeric type addrSz);
    method Action read(Bit#(addrSz) addr);
    method Bool empty();
endinterface

interface ReadResp#(type dataT);
    method ActionValue#(dataT) read();
    method Bool empty();
endinterface

interface Read#(numeric type addrSz, type dataT);
    method dataT read(Bit#(addrSz) addr);
endinterface

interface Write#(numeric type addrSz, type dataT);
    method Action write(Bit#(addrSz) addr, dataT data);
    method Bool empty();
endinterface

interface Memory#(numeric type addrSz, type dataT);
    method dataT read(Bit#(addrSz) addr);
    method Action write(Bit#(addrSz) addr, dataT data);
    method Bool writeEmpty();
endinterface

interface MultiReadMemory#(numeric type readNum, numeric type addrSz, type dataT);
    interface Vector#(readNum, Read#(addrSz, dataT)) read;
    method Action write(Bit#(addrSz) addr, dataT data);
    method Bool writeEmpty();
endinterface

interface MemoryServer#(numeric type addrSz, type dataT);
    method Action readReq(Bit#(addrSz) addr);
    method Bool readReqEmpty();
    method ActionValue#(dataT) readResp();
    method Bool readRespEmpty();
    method Action write(Bit#(addrSz) addr, dataT data);
    method Bool writeEmpty();
endinterface

interface MultiReadMemoryServer#(numeric type readNum, numeric type addrSz, type dataT);
    interface Vector#(readNum, ReadReq#(addrSz)) req;
    interface Vector#(readNum, ReadResp#(dataT)) resp;
    method Action write(Bit#(addrSz) addr, dataT data);
    method Bool writeEmpty();
endinterface

import "BVI" RegFile =
module mkRegFileNonZero(Memory#(addrSz, dataT))
    provisos(Bits#(dataT, dataSz));

    parameter addrSize = valueOf(addrSz);
    parameter dataSize = valueOf(dataSz);
    parameter numRows = valueOf(TExp#(addrSz));

    method readData read(readAddr) ready(readReady);
    method write(writeAddr, writeData) enable(writeEnable) ready(writeReady);
    method writeEmpty writeEmpty() ready(writeEmptyReady);

    schedule read C read;
    schedule write C write;
    schedule read CF write;
    schedule writeEmpty CF (read, write, writeEmpty);
endmodule

module mkRegFileZero(Memory#(addrSz, dataT))
    provisos(Bits#(dataT, dataSz));

    method dataT read(Bit#(addrSz) addr);
        return ?;
    endmethod

    method Action write(Bit#(addrSz) addr, dataT data);
        noAction;
    endmethod

    method Bool writeEmpty();
        return True;
    endmethod
endmodule

module mkRegFile(Memory#(addrSz, dataT))
    provisos(Bits#(dataT, dataSz));

    Memory#(addrSz, dataT) mem <- (valueOf(addrSz) == 0 || valueOf(dataSz) == 0)? mkRegFileZero(): mkRegFileNonZero();
    return mem;
endmodule

module mkRegFileSim(Memory#(addrSz, dataT))
    provisos(Bits#(dataT, dataSz));

    Reg#(Vector#(TExp#(addrSz), dataT)) ram <- mkRegU();

    method dataT read(Bit#(addrSz) addr);
        return ram[addr];
    endmethod

    method Action write(Bit#(addrSz) addr, dataT data);
        ram[addr] <= data;
    endmethod

    method Bool writeEmpty();
        return True;
    endmethod
endmodule

module mkMultiReadRegFile(MultiReadMemory#(readNum, addrSz, dataT))
    provisos(Bits#(dataT, dataSz));

    Vector#(readNum, Memory#(addrSz, dataT))    ram <- replicateM(mkRegFile());

    Vector#(readNum, Read#(addrSz, dataT)) readLocal = newVector();

    for(Integer i = 0; i < valueOf(readNum); i = i + 1)
    begin
        readLocal[i] = (interface Read#(addrSz, dataT);
                            method read = ram[i].read;
                        endinterface);
    end

    interface read = readLocal;

    method Action write(Bit#(addrSz) addr, dataT data);
        for(Integer i = 0; i < valueOf(readNum); i = i + 1)
            ram[i].write(addr, data);
    endmethod

    method Bool writeEmpty();
        return True;
    endmethod
endmodule

import "BVI" Bram =
module mkUnguardedBramNonZero#(Integer resetData)(MemoryServer#(addrSz, dataT))
    provisos(Bits#(dataT, dataSz));

    parameter addrSize = valueOf(addrSz);
    parameter dataSize = valueOf(dataSz);
    parameter numRows = valueOf(TExp#(addrSz));
    parameter resetVal = resetData;

    method readReq(readAddr) enable(readEnable) ready(readReady);
    method readReqEmpty readReqEmpty() ready(readReqEmptyReady);
    method readData readResp() enable(readDataEnable) ready(readDataReady);
    method readRespEmpty readRespEmpty() ready(readRespEmptyReady);
    method write(writeAddr, writeData) enable(writeEnable) ready(writeReady);
    method writeEmpty writeEmpty() ready(writeEmptyReady);

    schedule readReq C readReq;
    schedule readResp C readResp;
    schedule write C write;
    schedule readReq CF (readResp, write);
    schedule readResp CF write;
    schedule (readReqEmpty, readRespEmpty, writeEmpty) CF (readReq, readReqEmpty, readResp, readRespEmpty, write, writeEmpty);
endmodule

module mkUnguardedBramZero#(Integer resetData)(MemoryServer#(addrSz, dataT))
    provisos(Bits#(dataT, dataSz));

    method Action readReq(Bit#(addrSz) addr);
        noAction;
    endmethod

    method Bool readReqEmpty();
        return True;
    endmethod

    method ActionValue#(dataT) readResp();
        return ?;
    endmethod

    method Bool readRespEmpty();
        return True;
    endmethod

    method Action write(Bit#(addrSz) addr, dataT data);
        noAction;
    endmethod

    method Bool writeEmpty();
        return True;
    endmethod
endmodule

module mkUnguardedBram#(Integer resetData)(MemoryServer#(addrSz, dataT))
    provisos(Bits#(dataT, dataSz));

    MemoryServer#(addrSz, dataT) mem <- (valueOf(addrSz) == 0 || valueOf(dataSz) == 0)? mkUnguardedBramZero(resetData): mkUnguardedBramNonZero(resetData);
    return mem;
endmodule

module mkUnguardedBramSim#(Integer resetData)(MemoryServer#(addrSz, dataT))
    provisos(Bits#(dataT, dataSz));

    Bit#(dataSz) tempReset = fromInteger(resetData);

    Reg#(Vector#(TExp#(addrSz), dataT)) ram <- mkReg(replicate(unpack(tempReset)));
    Reg#(dataT)                   outputReg <- mkRegU;

    method Action readReq(Bit#(addrSz) addr);
        outputReg <= ram[addr];
    endmethod

    method Bool readReqEmpty();
        return True;
    endmethod

    method ActionValue#(dataT) readResp();
        return outputReg;
    endmethod

    method Bool readRespEmpty();
        return True;
    endmethod

    method Action write(Bit#(addrSz) addr, dataT data);
        ram[addr] <= data;
    endmethod

    method Bool writeEmpty();
        return True;
    endmethod
endmodule

module mkBram#(Integer resetData)(MemoryServer#(addrSz, dataT))
    provisos(Bits#(dataT, dataSz));

    MemoryServer#(addrSz, dataT) ram <- mkUnguardedBram(resetData);
    FIFOF#(void)    completionBuffer <- mkLFIFOF();

    method Action readReq(Bit#(addrSz) addr);
        ram.readReq(addr);
        completionBuffer.enq(?);
    endmethod

    method Bool readReqEmpty();
        return True;
    endmethod

    method ActionValue#(dataT) readResp();
        completionBuffer.deq();
        dataT data <- ram.readResp();
        return data;
    endmethod

    method Bool readRespEmpty();
        return !completionBuffer.notEmpty();
    endmethod

    method Action write(Bit#(addrSz) addr, dataT data);
        ram.write(addr, data);
    endmethod

    method Bool writeEmpty();
        return True;
    endmethod
endmodule

module mkMultiReadBram#(Integer resetData)(MultiReadMemoryServer#(readNum, addrSz, dataT))
    provisos(Bits#(dataT, dataSz));

    Vector#(readNum, MemoryServer#(addrSz, dataT)) ram <- replicateM(mkBram(resetData));

    Vector#(readNum, ReadReq#(addrSz))         reqLocal = newVector();
    Vector#(readNum, ReadResp#(dataT))        respLocal = newVector();

    for(Integer i = 0; i < valueOf(readNum); i = i + 1)
    begin
        reqLocal[i] = (interface ReadReq#(addrSz);
                           method read = ram[i].readReq;
                           method empty = ram[i].readReqEmpty;
                       endinterface);

        respLocal[i] = (interface ReadResp#(dataT);
                            method read = ram[i].readResp;
                            method empty = ram[i].readRespEmpty;
                        endinterface);
    end

    interface req = reqLocal;
    interface resp = respLocal;

    method Action write(Bit#(addrSz) addr, dataT data);
        for(Integer i = 0; i < valueOf(readNum); i = i + 1)
            ram[i].write(addr, data);
    endmethod

    method Bool writeEmpty();
        return True;
    endmethod
endmodule

module mkRegFileTest();
    MultiReadMemory#(2, 8, Bit#(32)) ram <- mkMultiReadRegFile();
    Reg#(Bit#(8)) counter <- mkReg(0);

    rule count(True);
        counter <= counter + 1;
        if(counter == maxBound)
            $finish(0);
    endrule

    rule write(True);
        ram.write(counter, zeroExtend(counter));
        $display("write: %0d %0d %0d", counter, counter, $time);
    endrule

    rule read(counter >= 100);
        let val = ram.read[0].read(counter - 100);
        $display("readReq: %0d %0d %0d", counter-100, val, $time);
    endrule
endmodule

module mkBramTest();
    MultiReadMemoryServer#(2, 8, Bit#(32)) ram <- mkMultiReadBram(23);
    Reg#(Bit#(8)) counter <- mkReg(0);

    rule count(True);
        counter <= counter + 1;
        if(counter == maxBound)
            $finish(0);
    endrule

    rule write(True);
        ram.write(counter, zeroExtend(counter));
        $display("write: %0d %0d %0d", counter, counter, $time);
    endrule

    rule readReq(counter >= 100);
        ram.req[0].read(counter - 100);
        $display("readReq: %0d %0d", counter-100, $time);
    endrule

    rule readResp(counter >= 200);
        Bit#(32) val <- ram.resp[0].read();
        $display("readResp: %0d %0d", val, $time);
    endrule
endmodule
