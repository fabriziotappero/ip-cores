// The MIT License

// Copyright (c) 2006-2007 Massachusetts Institute of Technology

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
import GetPut::*;
import ClientServer::*;
import H264Types::*;
import FIFOF::*;
import FIFO::*;
import IDeblockFilter::*;
import mkDeblockFilter::*;
import Connectable::*;


interface ParallelDeblockFilter;

   // Interface for inter-module io
   interface Put#(EntropyDecOT) ioinchroma;
   interface Put#(EntropyDecOT) ioinluma;
   interface Get#(DeblockFilterOT) ioout; 
      
   // Interface for module to memory
   interface Client#(MemReq#(TAdd#(PicWidthSz,5),32),MemResp#(32)) mem_client_data;
   interface Client#(MemReq#(PicWidthSz,13),MemResp#(13)) mem_client_parameter;
     
endinterface


module mkDeblockFilterParallel (ParallelDeblockFilter);
  FIFO#(ChromaFlag) dataTags <- mkFIFO();
  FIFO#(ChromaFlag) parameterTags <- mkFIFO();   
  IDeblockFilter deblockfilterluma <- mkDeblockFilter(Luma);
  IDeblockFilter deblockfilterchroma <- mkDeblockFilter(Chroma); 
  FIFO#(MemReq#(TAdd#(PicWidthSz,5),32)) dataMemReqQ       <- mkFIFO; 
  FIFO#(MemReq#(PicWidthSz,13))          parameterMemReqQ  <- mkFIFO;
  FIFOF#(DeblockFilterOT) outputFIFOLuma <- mkFIFOF;
  FIFOF#(DeblockFilterOT) outputFIFOChroma <- mkFIFOF;
  FIFO#(DeblockFilterOT) outputFIFO <- mkFIFO;

  rule memReqChroma;
    MemReq#(TAdd#(PicWidthSz,5),32) req <- deblockfilterchroma.mem_client_data.request.get;      
     dataMemReqQ.enq(req);
     if(req matches tagged LoadReq .addrt)
       begin 
	  dataTags.enq(Chroma);
       end
  endrule

  rule memReqLuma;
    MemReq#(TAdd#(PicWidthSz,5),32) req <- deblockfilterluma.mem_client_data.request.get;      
     dataMemReqQ.enq(req);
     
     if(req matches tagged LoadReq .addrt)
       begin    
	  dataTags.enq(Luma);
       end				     
  endrule

  rule parameterReqLuma;
     MemReq#(PicWidthSz,13) req <- deblockfilterluma.mem_client_parameter.request.get;      
     parameterMemReqQ.enq(req);
     
     if(req matches tagged LoadReq .addrt)
       begin 
	  parameterTags.enq(Luma);
       end				     
  endrule
   
  rule parameterReqChroma;
     MemReq#(PicWidthSz,13) req <- deblockfilterchroma.mem_client_parameter.request.get;      
     parameterMemReqQ.enq(req);
     if(req matches tagged LoadReq .addrt)
       begin 
	  parameterTags.enq(Chroma);
       end
  endrule

   mkConnection(deblockfilterchroma.ioout, fifoToPut(fifofToFifo(outputFIFOChroma)));
   mkConnection(deblockfilterluma.ioout, fifoToPut(fifofToFifo(outputFIFOLuma)));
   
   rule outMatch (outputFIFOLuma.first == outputFIFOChroma.first);
      outputFIFOLuma.deq;
      outputFIFOChroma.deq;
      outputFIFO.enq(outputFIFOLuma.first);   
   endrule
   
   rule outLuma(outputFIFOLuma.first matches tagged DFBLuma .data);
      outputFIFOLuma.deq;
      outputFIFO.enq(outputFIFOLuma.first);      
   endrule
	
   rule outChroma(outputFIFOChroma.first matches tagged DFBChroma .data);
      outputFIFOChroma.deq;
      outputFIFO.enq(outputFIFOChroma.first);      
   endrule
   
  interface Client mem_client_data;
    interface Get request  = fifoToGet(dataMemReqQ);
    interface Put response;
       method Action put(MemResp#(32) dataIn);
	  if(dataTags.first == Luma)
	     begin
		
		deblockfilterluma.mem_client_data.response.put(dataIn);
                dataTags.deq;	
	     end
	  else
	     begin
		
		deblockfilterchroma.mem_client_data.response.put(dataIn);
                dataTags.deq;	
	     end	   
       endmethod
    endinterface   
  endinterface

  interface Client mem_client_parameter;
    interface Get request  = fifoToGet(parameterMemReqQ);
    interface Put response;   
      method Action put(MemResp#(13) dataIn);
	  if(parameterTags.first == Luma)
	     begin
		
		deblockfilterluma.mem_client_parameter.response.put(dataIn);
                parameterTags.deq;	
	     end
	  else
	     begin
		deblockfilterchroma.mem_client_parameter.response.put(dataIn);
                parameterTags.deq;	
	     end	     
       endmethod
    endinterface 
  endinterface
   
  interface Get ioout = fifoToGet(outputFIFO);

 
  interface Put ioinchroma;
     method Action put(EntropyDecOT dataIn);
      
      case (dataIn) matches
        tagged  PBoutput .xdata: begin 
           match {.chromaFlag, .vec} = xdata;   
           if(chromaFlag == Chroma)
              begin 
                 deblockfilterchroma.ioin.put(dataIn);
              end
	   else
	      begin
		 $display("PARDEBLOCK ERROR! passing luma data to chroma filter");
	      end
        end
       
	 default:   begin
		       deblockfilterchroma.ioin.put(dataIn);
                    end
      endcase  
     endmethod 
  endinterface  


  interface Put ioinluma;
     method Action put(EntropyDecOT dataIn);
      
      case (dataIn) matches
        tagged  PBoutput .xdata: begin 
           match {.chromaFlag, .vec} = xdata;   
           if(chromaFlag == Luma)
              begin
		 
                 deblockfilterluma.ioin.put(dataIn);
              end
	   else
	      begin
		 $display("PARDEBLOCK ERROR! passing chroma data to luma filter");
	      end
        end
       
	 default:   begin
                       deblockfilterluma.ioin.put(dataIn);
                    end
      endcase  
     endmethod 
  endinterface   

 
endmodule
