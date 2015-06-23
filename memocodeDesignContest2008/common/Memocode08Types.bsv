/*
Copyright (c) 2008 MIT

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

Author: Kermin Fleming
*/
import Vector::*;

`define AddrWidth 32
typedef 32 AddrWidth;
typedef Bit#(`AddrWidth) Addr;

`define RecordNum 8
typedef 8 RecordNum;

`define RecordWidth 128
typedef 128 RecordWidth;
typedef Bit#(`RecordWidth) Record;

`define ReadPortNum 1
typedef 1 ReadPortNum;
`define WritePortNum 1
typedef 1 WritePortNum;

//`define RecordsPerMemRequest 4
//typedef 4 RecordsPerMemRequest;
`define RecordsPerMemRequest 8
typedef 8 RecordsPerMemRequest;


// we could get away with 32'h400000, saving one bit on
// RecAddr in mkCtro.bsv (mdk);
typedef 32'h00800000 MemBankSelector;

interface Read;
    method Action readReq(Addr addr);
    method ActionValue#(Record) read();
endinterface

interface Write;
    method Action writeReq(Addr addr);
    method Action write(Record record);
endinterface

interface ExternalMemory;
    method Bool readsPending();
    method Bool writesPending();
    interface Vector#(`ReadPortNum, Read) read;
    interface Vector#(`WritePortNum, Write) write;
endinterface

