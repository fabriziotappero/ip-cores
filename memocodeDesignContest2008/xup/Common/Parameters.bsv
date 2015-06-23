/*
Copyright (c) 2007 MIT

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

import Memocode08Types::*;

typedef 1 FunctionalUnitNumber;
typedef TLog#(FunctionalUnitNumber) LogFunctionalUnitNumber;
typedef Bit#(LogFunctionalUnitNumber) FunctionalUnitAddr;
typedef Bit#(FunctionalUnitNumber) FunctionalUnitMask;


typedef 32 BlockSize; // Words per burst (4*RecordsPerMemRequest)
//typedef 16 BlockSize;
typedef 32 WordWidth;
typedef 64 DoubleWordWidth;
typedef Bit#(64) BusWord;
typedef TDiv#(TMul#(BlockSize,WordWidth),RecordWidth)   RecordsPerBlock;
typedef TDiv#(RecordWidth,WordWidth)   WordsPerRecord;
typedef TDiv#(RecordWidth,DoubleWordWidth)   DoubleWordsPerRecord;
typedef TLog#(BlockSize) LogBlockSize;
typedef TMul#(BlockSize, BlockSize) BlockElements; 
typedef TLog#(TMul#(BlockSize, BlockSize)) LogBlockElements;
typedef 1024 MaxBlockSize;
typedef TAdd#(TLog#(MaxBlockSize), 2) LogRowSize;

typedef 32 PLBAddrSize;
typedef Bit#(PLBAddrSize) PLBAddr;
typedef 2 WordsPerBeat;  // PLB bandwidth
//typedef TDiv#(BlockSize,WordsPerBeat) BeatsPerBlock;
typedef 16 BurstSize;  // number of beats per burst
typedef 16 BeatsPerBurst;


typedef Bit#(30) BlockAddr;


