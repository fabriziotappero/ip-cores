//----------------------------------------------------------------------//
// The MIT License 
// 
// Copyright (c) 2008 Alfred Man Cheuk Ng, mcn02@mit.edu 
// 
// Permission is hereby granted, free of charge, to any person 
// obtaining a copy of this software and associated documentation 
// files (the "Software"), to deal in the Software without 
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//----------------------------------------------------------------------//

// import standard librarys
import Connectable::*;
import GetPut::*;
import FIFO::*;
import StmtFSM::*;
import Vector::*;

// import self-made library
import BRAMVLevelFIFO::*;
import EHRReg::*;
import VLevelFIFO::*;
import Sort::*;

import BRAMLevel4Merger::*;
import BRAMLevel3Merger::*;
import BRAMLevel2Merger::*;
import Level1Merger::*;

typedef 4 FIFO_SZ; 
typedef 3 TOK_SZ;

(* synthesize *)
module mkSortTree16 (SortTree#(16,Bit#(TOK_SZ),Maybe#(Bit#(128))));
   
   let level4Merger <- mkBRAMLevel4MergerInstance();
   let level3Merger <- mkBRAMLevel3MergerInstance();
   let level2Merger <- mkBRAMLevel2MergerInstance();
   let level1Merger <- mkLevel1MergerInstance();
   
   mkConnection(level4Merger.outStream,level3Merger.inStream);
   mkConnection(level3Merger.outStream,level2Merger.inStream);
   mkConnection(level2Merger.outStream,level1Merger.inStream);
      
   interface inStream  = level4Merger.inStream;
   method    getRecord = level1Merger.getRecord;    
   
endmodule