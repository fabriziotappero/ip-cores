//----------------------------------------------------------------------//
// The MIT License 
// 
// Copyright (c) 2008 Kermin Fleming, kfleming@mit.edu 
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
import LFSR::*;
import Vector::*;

import MD6Parameters::*;
import MD6Types::*;
import CompressionFunction::*;
import CompressionFunctionLibrary::*;
import CompressionFunctionTypes::*;
import CompressionFunctionParameters::*;


import "BDPI" function Action testSanityCheck(Bit#(64) md6_w_val, Bit#(64) md6_n_val, Bit#(64) md6_c_val, 
                                              Bit#(64) md6_b_val, Bit#(64) md6_v_val, Bit#(64) md6_u_val,
                                              Bit#(64) md6_k_val, Bit#(64) md6_q_val, Bit#(64) md6_r_val);
import "BDPI" function Action writePlaintextValue(MD6Word value, Bit#(64) index);
import "BDPI" function Action writeControlValue(MD6Word value, Bit#(64) index);
import "BDPI" function Action writeUniqueValue(MD6Word value, Bit#(64) index);
import "BDPI" function Action writeKeyValue(MD6Word value, Bit#(64) index);
import "BDPI" function Action writeQValue(MD6Word value, Bit#(64) index);
import "BDPI" function Action executeDecode();
import "BDPI" function ActionValue#(MD6Word) readHash(Bit#(64) index);



// This function will handle only the MD6 word

typedef enum {
  Initialize,
  Running
} TestState deriving (Bits,Eq);

/*
Vector#(MD6_k,MD6Word) key = replicate(0);
Vector#(MD6_u,MD6Word) identifier = replicate(0);
Round round = 0;
TreeHeight treeHeight = 0;
LastCompression lastCompression = 0; //One if last compression, else zero
PaddingBits paddingBits = 0;
KeyLength keyLength = fromInteger(valueof(MD6_k));
DigestLength digestLength = 0;
*/

module mkCompressionFunctionTestbench();
  CompressionFunction#(16) compressionFunction <- mkMult16CompressionFunction;
  LFSR#(MD6Word) lfsr <- mkFeedLFSR(minBound | 9 ); // This might be random enough, maybe..  
  Reg#(TestState) state <- mkReg(Initialize);  

  Reg#(Bit#(TLog#(MD6_b))) externalData <- mkReg(0);

  Bit#(TLog#(TAdd#(MD6_b,1))) externalDataCountNext = zeroExtend(externalData) + 1;

  Reg#(Bool) failure <- mkReg(False);    

  Reg#(Bit#(10)) testCount <- mkReg(0);

  Reg#(Vector#(MD6_k,MD6Word)) key <- mkReg(replicate(0));
  Reg#(Vector#(MD6_u,MD6Word)) identifier <- mkReg(replicate(0));
  Reg#(Round) round <- mkReg(fromInteger(valueof(MD6_r)));
  Reg#(TreeHeight) treeHeight <- mkReg(0);
  Reg#(LastCompression) lastCompression <- mkReg(0);
  Reg#(KeyLength) keyLength <- mkReg(fromInteger(valueof(MD6_k))); 
  Reg#(DigestLength) digestLength <- mkReg(0);
  Reg#(PaddingBits) paddingBits <- mkReg(0);

  rule initialize(state == Initialize);
    lfsr.seed(~0);
    state <= Running;
    testSanityCheck(fromInteger(valueof(MD6_WordWidth)), fromInteger(valueof(MD6_n)), fromInteger(valueof(MD6_c)), 
                    fromInteger(valueof(MD6_b)), fromInteger(valueof(MD6_v)), fromInteger(valueof(MD6_u)),
                    fromInteger(valueof(MD6_k)), fromInteger(valueof(MD6_q)), fromInteger(valueof(MD6_r)));
   

//    $display("Testbench Init MD6_c: %d MD6_WW: %d MD6_n: %d",valueof(MD6_c), valueof(MD6_WordWidth), valueof(MD6_n));
//    $display("Testbench Taps t0: %d, t1: %d, t2: %d, t3: %d, t4: %d", determineT0, determineT1,  determineT2,  determineT3,  determineT4);
  endrule

  function sub(a,b);
    return a-b;
  endfunction

  rule startDecode(state == Running);
    let controlWord = makeControlWord(round,treeHeight,lastCompression,paddingBits,keyLength,digestLength);
    identifier <= unpack(pack(identifier) + 1);
    key <= zipWith(sub,map(fromInteger,genVector),replicate(lfsr.value));

    compressionFunction.start(round,
                              treeHeight,
                              lastCompression,
                              paddingBits,
                              keyLength,
                              digestLength,
                              identifier,                              
                              key);

    testCount <= testCount + 1;
    if(testCount + 1 == 0) 
      begin
        $display("PASS");
        $finish;
      end
    // Dump stuff into
    for(Integer i = 0; i < valueof(MD6_v); i = i+1)
      begin 
       writeUniqueValue(identifier[fromInteger(i)],fromInteger(i));
      end
    for(Integer i = 0; i < valueof(MD6_u); i = i+1)
      begin 
       writeControlValue(controlWord[fromInteger(i)],fromInteger(i));
      end
    for(Integer i = 0; i < valueof(MD6_k); i = i+1)
      begin 
       writeKeyValue(key[fromInteger(i)],fromInteger(i));
      end
    for(Integer i = 0; i < valueof(MD6_q); i = i+1)
      begin 
       //$display("Writing Q value[%h]: %h", i,getQWord(fromInteger(i))); 
       writeQValue(getQWord(fromInteger(i)),fromInteger(i));
      end

    $display("Testbench Start");
  endrule

  rule sendInData(state == Running);
    writePlaintextValue(lfsr.value, fromInteger(valueof(MD6_b)) - zeroExtend(externalData) - 1);
    if(externalDataCountNext == fromInteger(valueof(MD6_b)))
      begin
        // Kick off something here? Is the ordering okay?
        executeDecode();
        externalData <= 0;
      end
    else
      begin
        externalData <= truncate(externalDataCountNext);
      end
    lfsr.next();
    
    compressionFunction.inputWord(lfsr.value);
  endrule

  rule getOutData(state == Running);
    MD6Word outWord <- compressionFunction.outputWord();
    MD6Word goldenWord <- readHash(fromInteger(valueof(MD6_c)) - zeroExtend(externalData) - 1);
    if(outWord != goldenWord) 
      begin
        $display("Failure - outWord: %h goldenWord: %h", outWord, goldenWord);
        failure <= True;
      end
    if(externalDataCountNext == fromInteger(valueof(MD6_c)))
      begin
        if(failure)
          begin
            $finish;
          end
        externalData <= 0;
      end
    else
      begin
        externalData <= truncate(externalDataCountNext); 
      end
  endrule
endmodule

