
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

//**********************************************************************
// Deblocking Filter
//----------------------------------------------------------------------
//
//

package mkDeblockFilter;

import H264Types::*;

import IDeblockFilter::*;
import FIFO::*;
import Vector::*;

import Connectable::*;
import GetPut::*;
import ClientServer::*;




//-----------------------------------------------------------
// Local Datatypes
//-----------------------------------------------------------


typedef union tagged                
{
 void     Passing;          //not working on anything in particular
 void     Initialize;
 void     Horizontal;
 void     Vertical;
 void     Cleanup;
}
Process deriving(Eq,Bits);



//-----------------------------------------------------------
// Helper functions


function Bit#(8) absdiff8(Bit#(8) in0, Bit#(8) in1);
   return (in1>=in0 ? in1-in0 : in0-in1);
endfunction


function Bool filter_test(Bit#(32) in_pixels, Bit#(8) alpha, Bit#(5) beta);
   Bit#(8) p1 = in_pixels[7:0];
   Bit#(8) p0 = in_pixels[15:8];
   Bit#(8) q0 = in_pixels[23:16];
   Bit#(8) q1 = in_pixels[31:24];
   return((absdiff8(p0,q0) < alpha) && 
          (absdiff8(p0,p1) < zeroExtend(beta))  &&
          (absdiff8(q0,q1) < zeroExtend(beta)));
endfunction


function Bit#(6) clip3symmetric9to6(Bit#(9) val, Bit#(5) bound);
   Int#(9) intval = unpack(val);
   Int#(6) intbound = unpack({1'b0,bound});
   Int#(6) intout = (intval<signExtend(-intbound) ? -intbound : (intval>signExtend(intbound) ? intbound : truncate(intval)));
   return pack(intout);
endfunction


function Bit#(64) filter_input(Bit#(64) in_pixels, Bool chroma_flag, Bit#(3) bs, Bit#(8) alpha, Bit#(5) beta, Vector#(3,Bit#(5)) tc0_vector);
   Bit#(8) p[4];
   Bit#(8) q[4];
   p[3] = in_pixels[7:0];
   p[2] = in_pixels[15:8];
   p[1] = in_pixels[23:16];
   p[0] = in_pixels[31:24];
   q[0] = in_pixels[39:32];
   q[1] = in_pixels[47:40];
   q[2] = in_pixels[55:48];
   q[3] = in_pixels[63:56];
   Bit#(8) p_out[4];
   Bit#(8) q_out[4];
   Bool a_p_test = absdiff8(p[2],p[0]) < zeroExtend(beta);
   Bool a_q_test = absdiff8(q[2],q[0]) < zeroExtend(beta);
   Bit#(9) p0q0 = zeroExtend(p[0])+zeroExtend(q[0]);
   if (bs == 4)
      begin
	 Bool small_gap_test = absdiff8(p[0],q[0]) < (alpha >> 2)+2;
	 Bit#(11) p_outtemp[3];
	 Bit#(11) q_outtemp[3];
	 if (!chroma_flag && a_p_test && small_gap_test)
	    begin
	       Bit#(11) sum = zeroExtend(p[1])+zeroExtend(p0q0);
	       p_outtemp[0] = (zeroExtend(p[2]) + (sum<<1) + zeroExtend(q[1]) + 4) >> 3;
	       p_outtemp[1] = (zeroExtend(p[2]) + sum + 2) >> 2;
	       p_outtemp[2] = (((zeroExtend(p[3])+zeroExtend(p[2]))<<1) + zeroExtend(p[2]) + sum + 4) >> 3;
	    end
	 else
	    begin
	       p_outtemp[0] = ((zeroExtend(p[1])<<1) + zeroExtend(p[0]) + zeroExtend(q[1]) + 2) >> 2;
	       p_outtemp[1] = zeroExtend(p[1]);
	       p_outtemp[2] = zeroExtend(p[2]);
	    end
	 if (!chroma_flag && a_q_test && small_gap_test)
	    begin
	       Bit#(11) sum = zeroExtend(q[1])+zeroExtend(p0q0);
	       q_outtemp[0] = (zeroExtend(p[1]) + (sum<<1) + zeroExtend(q[2]) + 4) >> 3;
	       q_outtemp[1] = (zeroExtend(q[2]) + sum + 2) >> 2;
	       q_outtemp[2] = (((zeroExtend(q[3])+zeroExtend(q[2]))<<1) + zeroExtend(q[2]) + sum + 4) >> 3;
	    end
	 else
	    begin
	       q_outtemp[0] = ((zeroExtend(q[1])<<1) + zeroExtend(q[0]) + zeroExtend(p[1]) + 2) >> 2;
	       q_outtemp[1] = zeroExtend(q[1]);
	       q_outtemp[2] = zeroExtend(q[2]);
	    end
	 p_out[0] = truncate(p_outtemp[0]);
	 p_out[1] = truncate(p_outtemp[1]);
	 p_out[2] = truncate(p_outtemp[2]);
	 q_out[0] = truncate(q_outtemp[0]);
	 q_out[1] = truncate(q_outtemp[1]);
	 q_out[2] = truncate(q_outtemp[2]);
      end
   else if(bs > 0)
      begin
	 Bit#(5) t_c0 = tc0_vector[bs-1];
	 Bit#(5) t_c = chroma_flag ? t_c0+1 : t_c0 + (a_p_test ? 1:0) + (a_q_test ? 1:0);
	 Bit#(12) deltatemp = (((zeroExtend(q[0])-zeroExtend(p[0]))<<2)+zeroExtend(p[1])-zeroExtend(q[1])+4);
	 Bit#(6) delta = clip3symmetric9to6(deltatemp[11:3],t_c);
	 
	 Bit#(10) p_out0temp = zeroExtend(p[0]) + signExtend(delta);
	 p_out[0] = (p_out0temp[9]==1 ? 0 : (p_out0temp[8]==1 ? 255 : p_out0temp[7:0]));
	 Bit#(10) q_out0temp = zeroExtend(q[0]) - signExtend(delta);
	 q_out[0] = (q_out0temp[9]==1 ? 0 : (q_out0temp[8]==1 ? 255 : q_out0temp[7:0]));
	 
	 Bit#(9) p0q0PLUS1 = p0q0+1;
	 Bit#(8) p0q0_av = p0q0PLUS1[8:1];
	 if (!chroma_flag && a_p_test)
	    begin
	       Bit#(10) p_out1temp = zeroExtend(p[2]) + zeroExtend(p0q0_av) - (zeroExtend(p[1])<<1);
	       p_out[1] = p[1]+signExtend(clip3symmetric9to6(p_out1temp[9:1],t_c0));
	    end
	 else
	    p_out[1] = p[1];
	 
	 if (!chroma_flag && a_q_test)
	    begin
	       Bit#(10) q_out1temp = zeroExtend(q[2]) + zeroExtend(p0q0_av) - (zeroExtend(q[1])<<1);
	       q_out[1] = q[1]+signExtend(clip3symmetric9to6(q_out1temp[9:1],t_c0));
	    end
	 else
	    q_out[1] = q[1];
	 
	 p_out[2] = p[2];
	 q_out[2] = q[2];
      end
   else
      begin
	 p_out[0] = p[0];
	 q_out[0] = q[0];
	 p_out[1] = p[1];
	 q_out[1] = q[1];
	 p_out[2] = p[2];
	 q_out[2] = q[2];
      end
   p_out[3] = p[3];
   q_out[3] = q[3];
   return({q_out[3], q_out[2], q_out[1], q_out[0], p_out[0], p_out[1], p_out[2], p_out[3]});
endfunction



//-----------------------------------------------------------
// Deblocking Filter Module
//-----------------------------------------------------------


(* synthesize *)
module mkDeblockFilter( IDeblockFilter );

   FIFO#(EntropyDecOT) infifo     <- mkSizedFIFO(deblockFilter_infifo_size);
   FIFO#(DeblockFilterOT) outfifo <- mkFIFO();

   FIFO#(MemReq#(TAdd#(PicWidthSz,5),32)) dataMemReqQ       <- mkFIFO;
   FIFO#(MemReq#(PicWidthSz,13))          parameterMemReqQ  <- mkFIFO;
   FIFO#(MemResp#(32))                    dataMemRespQ      <- mkFIFO;
   FIFO#(MemResp#(13))                    parameterMemRespQ <- mkFIFO;

   Reg#(Process) process       <- mkReg(Passing);
   Reg#(Bit#(1)) chromaFlag    <- mkReg(0);
   Reg#(Bit#(5)) dataReqCount  <- mkReg(0);
   Reg#(Bit#(5)) dataRespCount <- mkReg(0);
   Reg#(Bit#(4)) blockNum      <- mkReg(0);
   Reg#(Bit#(4)) pixelNum      <- mkReg(0);

   Reg#(Bool) filterTopMbEdgeFlag     <- mkReg(False);
   Reg#(Bool) filterLeftMbEdgeFlag    <- mkReg(False);
   Reg#(Bool) filterInternalEdgesFlag <- mkReg(False);

   Reg#(Bit#(PicWidthSz))  picWidth  <- mkReg(maxPicWidthInMB);
   Reg#(Bit#(PicHeightSz)) picHeight <- mkReg(0);
   Reg#(Bit#(PicAreaSz))   firstMb   <- mkReg(0);
   Reg#(Bit#(PicAreaSz))   currMb    <- mkReg(0);
   Reg#(Bit#(PicAreaSz))   currMbHor <- mkReg(0);//horizontal position of currMb
   Reg#(Bit#(PicHeightSz)) currMbVer <- mkReg(0);//vertical position of currMb

   Reg#(Bit#(2)) disable_deblocking_filter_idc <- mkReg(0);
   Reg#(Bit#(5)) slice_alpha_c0_offset <- mkReg(0);
   Reg#(Bit#(5)) slice_beta_offset <- mkReg(0);

   Reg#(Bit#(6)) curr_qpy   <- mkReg(0);
   Reg#(Bit#(6)) left_qpy   <- mkReg(0);
   Reg#(Bit#(6)) top_qpy    <- mkReg(0);
   Reg#(Bit#(6)) curr_qpc   <- mkReg(0);
   Reg#(Bit#(6)) left_qpc   <- mkReg(0);
   Reg#(Bit#(6)) top_qpc    <- mkReg(0);
   Reg#(Bit#(1)) curr_intra <- mkReg(0);
   Reg#(Bit#(1)) left_intra <- mkReg(0);
   Reg#(Bit#(1)) top_intra  <- mkReg(0);

   Reg#(Bit#(8)) alphaMbEdge    <- mkReg(0);
   Reg#(Bit#(8)) alphaInternal  <- mkReg(0);
   Reg#(Bit#(5)) betaMbEdge     <- mkReg(0);
   Reg#(Bit#(5)) betaInternal   <- mkReg(0);
   Reg#(Vector#(3,Bit#(5))) tc0MbEdge   <- mkRegU();
   Reg#(Vector#(3,Bit#(5))) tc0Internal <- mkRegU();

   Bit#(8) alpha_table[52] = {0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			      0,  0,  0,  0,  0,  0,  4,  4,  5,  6,
			      7,  8,  9, 10, 12, 13, 15, 17, 20, 22,
			     25, 28, 32, 36, 40, 45, 50, 56, 63, 71,
			     80, 90,101,113,127,144,162,182,203,226,
			    255,255};
   Bit#(5) beta_table[52] = {0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			     0,  0,  0,  0,  0,  0,  2,  2,  2,  3,
			     3,  3,  3,  4,  4,  4,  6,  6,  7,  7,
			     8,  8,  9,  9, 10, 10, 11, 11, 12, 12,
			    13, 13, 14, 14, 15, 15, 16, 16, 17, 17,
			    18, 18};
   Bit#(5) tc0_table[52][3] = {{ 0, 0, 0 }, { 0, 0, 0 }, { 0, 0, 0 }, { 0, 0, 0 }, { 0, 0, 0 }, { 0, 0, 0 },
			       { 0, 0, 0 }, { 0, 0, 0 }, { 0, 0, 0 }, { 0, 0, 0 }, { 0, 0, 0 }, { 0, 0, 0 },
			       { 0, 0, 0 }, { 0, 0, 0 }, { 0, 0, 0 }, { 0, 0, 0 }, { 0, 0, 0 }, { 0, 0, 1 },
			       { 0, 0, 1 }, { 0, 0, 1 }, { 0, 0, 1 }, { 0, 1, 1 }, { 0, 1, 1 }, { 1, 1, 1 },
			       { 1, 1, 1 }, { 1, 1, 1 }, { 1, 1, 1 }, { 1, 1, 2 }, { 1, 1, 2 }, { 1, 1, 2 },
			       { 1, 1, 2 }, { 1, 2, 3 }, { 1, 2, 3 }, { 2, 2, 3 }, { 2, 2, 4 }, { 2, 3, 4 },
			       { 2, 3, 4 }, { 3, 3, 5 }, { 3, 4, 6 }, { 3, 4, 6 }, { 4, 5, 7 }, { 4, 5, 8 },
			       { 4, 6, 9 }, { 5, 7,10 }, { 6, 8,11 }, { 6, 8,13 }, { 7,10,14 }, { 8,11,16 },
			       { 9,12,18 }, {10,13,20 }, {11,15,23 }, {13,17,25 }};

   Reg#(Vector#(64,Bit#(32))) workVector <- mkRegU();
   Reg#(Vector#(96,Bit#(32))) leftVector <- mkRegU();
   Reg#(Vector#(16,Bit#(32))) topVector  <- mkRegU();

   Reg#(Bool) startLastOutput <- mkReg(False);
   Reg#(Bool) outputingFinished <- mkReg(False);
   Reg#(Bit#(2)) colNum <- mkReg(0);
   Reg#(Bit#(2)) rowNum <- mkReg(0);

   RFile1#(Bit#(4),Tuple2#(Bit#(3),Bit#(3))) bSfile <- mkRFile1Full();


   //-----------------------------------------------------------
   // Rules
   
   rule passing ( process matches Passing );
      case (infifo.first()) matches
	 tagged NewUnit . xdata :
	    begin
	       infifo.deq();
	       outfifo.enq(EDOT infifo.first());
	       $display("ccl5newunit");
	       $display("ccl5rbspbyte %h", xdata);
	    end
	 tagged SPSpic_width_in_mbs .xdata :
	    begin
	       infifo.deq();
	       outfifo.enq(EDOT infifo.first());
	       picWidth <= xdata;
	    end
	 tagged SPSpic_height_in_map_units .xdata :
	    begin
	       infifo.deq();
	       outfifo.enq(EDOT infifo.first());
	       picHeight <= xdata;
	    end
	 tagged PPSdeblocking_filter_control_present_flag .xdata :
	    begin
	       infifo.deq();
	       if (xdata == 0)
		  begin
		     disable_deblocking_filter_idc <= 0;
		     slice_alpha_c0_offset <= 0;
		     slice_beta_offset <= 0;
		  end
	    end
	 tagged SHfirst_mb_in_slice .xdata :
	    begin
	       infifo.deq();
	       outfifo.enq(EDOT infifo.first());
	       firstMb   <= xdata;
	       currMb    <= xdata;
	       currMbHor <= xdata;
	       currMbVer <= 0;
	    end
	 tagged SHdisable_deblocking_filter_idc .xdata :
	    begin
	       infifo.deq();
	       disable_deblocking_filter_idc <= xdata;
	    end
	 tagged SHslice_alpha_c0_offset .xdata :
	    begin
	       infifo.deq();
	       slice_alpha_c0_offset <= xdata;
	    end
	 tagged SHslice_beta_offset .xdata :
	    begin
	       infifo.deq();
	       slice_beta_offset <= xdata;
	    end
	 tagged IBTmb_qp .xdata :
	    begin
	       infifo.deq();
	       curr_qpy <= xdata.qpy;
	       curr_qpc <= xdata.qpc;
	    end
	 tagged PBbS .xdata :
	    begin
	       process <= Initialize;
	    end
	 tagged PBoutput .xdata :
	    begin
	       $display( "ERROR Deblocking Filter: passing PBoutput");
	    end
	 tagged EndOfFile :
	    begin
	       infifo.deq();
	       outfifo.enq(EDOT infifo.first());
	       $display( "ccl5: EndOfFile reached");
	       //$finish(0);
	    end
	 default:
	    begin
	       infifo.deq();
	       outfifo.enq(EDOT infifo.first());
	    end
      endcase
   endrule


   rule currMbHorUpdate( !(currMbHor<zeroExtend(picWidth)) );
      Bit#(PicAreaSz) temp = zeroExtend(picWidth);
      if((currMbHor >> 3) >= temp)
	 begin
	    currMbHor <= currMbHor - (temp << 3);
	    currMbVer <= currMbVer + 8;
	 end
      else
	 begin
	    currMbHor <= currMbHor - temp;
	    currMbVer <= currMbVer + 1;
	 end
   endrule

   
   rule initialize ( process==Initialize && currMbHor<zeroExtend(picWidth) );
      //$display( "TRACE Deblocking Filter: initialize %0d", currMb);
      process <= Horizontal;
      dataReqCount <= 1;
      dataRespCount <= 1;
      filterTopMbEdgeFlag <= !(currMb<zeroExtend(picWidth) || disable_deblocking_filter_idc==1 || (disable_deblocking_filter_idc==2 && currMb-firstMb<zeroExtend(picWidth)));
      filterLeftMbEdgeFlag <= !(currMbHor==0 || disable_deblocking_filter_idc==1 || (disable_deblocking_filter_idc==2 && currMb==firstMb));
      filterInternalEdgesFlag <= !(disable_deblocking_filter_idc==1);
      blockNum <= 0;
      pixelNum <= 0;
      Bit#(6) curr_qp = (chromaFlag==0 ? curr_qpy : curr_qpc);
      Bit#(6) left_qp = (chromaFlag==0 ? left_qpy : left_qpc);
      Bit#(7) qpavtemp = zeroExtend(curr_qp)+zeroExtend(left_qp)+1;
      Bit#(6) qpav = qpavtemp[6:1];
      Bit#(8) indexAtemp = zeroExtend(qpav)+signExtend(slice_alpha_c0_offset);
      Bit#(8) indexBtemp = zeroExtend(qpav)+signExtend(slice_beta_offset);
      Bit#(6) indexA = (indexAtemp[7]==1 ? 0 : (indexAtemp[6:0]>51 ? 51 : indexAtemp[5:0]));
      Bit#(6) indexB = (indexBtemp[7]==1 ? 0 : (indexBtemp[6:0]>51 ? 51 : indexBtemp[5:0]));
      alphaMbEdge <= alpha_table[indexA];
      betaMbEdge <= beta_table[indexB];
      Vector#(3,Bit#(5)) tc0temp = arrayToVector(tc0_table[indexA]);
      tc0MbEdge <= tc0temp;
   endrule


   rule dataSendReq ( dataReqCount>0 && currMbHor<zeroExtend(picWidth) );
      //$display( "TRACE Deblocking Filter: dataSendReq %0d", dataReqCount);
      Bit#(PicWidthSz) temp = truncate(currMbHor);
      if(currMb<zeroExtend(picWidth))
	 dataReqCount <= 0;
      else
	 begin
	    if(dataReqCount==1)
	       parameterMemReqQ.enq(LoadReq temp);
	    Bit#(4) temp2 = truncate(dataReqCount-1);
	    let temp3 = {temp,chromaFlag,temp2};
	    dataMemReqQ.enq(LoadReq temp3);
	    if(dataReqCount==16)
	       dataReqCount <= 0;
	    else
	       dataReqCount <= dataReqCount+1;
	 end
   endrule


   rule dataReceiveNoResp ( dataRespCount>0 && currMb<zeroExtend(picWidth) && currMb-firstMb<zeroExtend(picWidth) );
      //$display( "TRACE Deblocking Filter: dataReceiveNoResp");
      dataRespCount <= 0;
   endrule

   
   rule dataReceiveResp ( dataRespCount>0 && !(currMb<zeroExtend(picWidth)) && currMbHor<zeroExtend(picWidth) );
      //$display( "TRACE Deblocking Filter: dataReceiveResp %0d", dataRespCount);
      Bit#(4) temp = truncate(dataRespCount-1);
      Vector#(16,Bit#(32)) topVectorNext = topVector;
      if(dataRespCount==1)
	 begin
	    Bit#(13) tempParameters=0;
	    if(parameterMemRespQ.first() matches tagged LoadResp .xdata)
	       tempParameters = xdata;
	    top_qpy <= tempParameters[5:0];
	    top_qpc <= tempParameters[11:6];
	    top_intra <= tempParameters[12];
	    parameterMemRespQ.deq();
	 end
      if(dataRespCount==16)
	 dataRespCount <= 0;
      else
	 dataRespCount <= dataRespCount+1;
      if(dataMemRespQ.first() matches tagged LoadResp .xdata)
	    topVectorNext[temp] = xdata;
      dataMemRespQ.deq();
      topVector <= topVectorNext;
      //$display( "TRACE Deblocking Filter: dataReceiveResp topVector %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h", topVector[0], topVector[1], topVector[2], topVector[3], topVector[4], topVector[5], topVector[6], topVector[7], topVector[8], topVector[9], topVector[10], topVector[11], topVector[12], topVector[13], topVector[14], topVector[15]);
   endrule


   rule horizontal ( process==Horizontal && currMbHor<zeroExtend(picWidth) );
      //$display( "TRACE Deblocking Filter: horizontal %0d %0d %0d", blockNum, pixelNum, infifo.first());
      Bit#(2) blockHor = {blockNum[2],blockNum[0]};
      Bit#(2) blockVer = {blockNum[3],blockNum[1]};
      Bit#(2) pixelVer = {pixelNum[3],pixelNum[2]};
      Vector#(96,Bit#(32)) leftVectorNext = leftVector;
      Vector#(64,Bit#(32)) workVectorNext = workVector;
      Bool leftEdge = (blockNum[0]==0 && (blockNum[2]==0 || chromaFlag==1));
      if(blockNum==0 && pixelNum==0)
	 begin
	    Bit#(6) qpav = (chromaFlag==0 ? curr_qpy : curr_qpc);
	    Bit#(8) indexAtemp = zeroExtend(qpav)+signExtend(slice_alpha_c0_offset);
	    Bit#(8) indexBtemp = zeroExtend(qpav)+signExtend(slice_beta_offset);
	    Bit#(6) indexA = (indexAtemp[7]==1 ? 0 : (indexAtemp[6:0]>51 ? 51 : indexAtemp[5:0]));
	    Bit#(6) indexB = (indexBtemp[7]==1 ? 0 : (indexBtemp[6:0]>51 ? 51 : indexBtemp[5:0]));
	    alphaInternal <= alpha_table[indexA];
	    betaInternal <= beta_table[indexB];
	    Vector#(3,Bit#(5)) tc0temp = arrayToVector(tc0_table[indexA]);
	    tc0Internal <= tc0temp;
	 end
      case (infifo.first()) matches
	 tagged PBbS .xdata :
	    begin
	       infifo.deq();
	       bSfile.upd(blockNum,tuple2(xdata.bShor,xdata.bSver));
	    end
	 tagged PBoutput .xdata :
	    begin
	       infifo.deq();
	       Bit#(6) addrq = {blockHor,blockVer,pixelVer};
	       Bit#(7) addrpLeft = (chromaFlag==0 ? {3'b011,blockVer,pixelVer} : {2'b10,blockHor[1],1'b1,blockVer[0],pixelVer});
	       Bit#(6) addrpCurr = {(blockHor-1),blockVer,pixelVer};
	       Bit#(32) pixelq = {xdata[3],xdata[2],xdata[1],xdata[0]};
	       Bit#(32) pixelp;
	       if(leftEdge)
		  pixelp = leftVector[addrpLeft];
	       else
		  pixelp = workVector[addrpCurr];
	       Bit#(64) result = {pixelq,pixelp};
	       if(leftEdge && filterLeftMbEdgeFlag)
		  begin
		     if(filter_test({pixelq[15:0],pixelp[31:16]},alphaMbEdge,betaMbEdge))
			result = filter_input({pixelq,pixelp},chromaFlag==1,tpl_1(bSfile.sub((chromaFlag==0?blockNum:{blockNum[1:0],pixelVer[1],1'b0}))),alphaMbEdge,betaMbEdge,tc0MbEdge);
		  end
	       else if(!leftEdge && filterInternalEdgesFlag)
		  begin
		     if(filter_test({pixelq[15:0],pixelp[31:16]},alphaInternal,betaInternal))
			result = filter_input({pixelq,pixelp},chromaFlag==1,tpl_1(bSfile.sub((chromaFlag==0?blockNum:{blockNum[1:0],pixelVer[1],1'b0}))),alphaInternal,betaInternal,tc0Internal);
		  end
	       if(leftEdge)
		  leftVectorNext[addrpLeft] = result[31:0];
	       else
		  workVectorNext[addrpCurr] = result[31:0];
	       workVectorNext[addrq] = result[63:32];
	       leftVector <= leftVectorNext;
	       workVector <= workVectorNext;
	       if(pixelNum==12 && (blockNum==15 || (blockNum==7 && chromaFlag==1)))
		  begin
		     blockNum <= 0;
		     process <= Vertical;
		     startLastOutput <= False;
		     outputingFinished <= False;
		     colNum <= 0;
		     if(filterTopMbEdgeFlag)
			rowNum <= 0;
		     else
			rowNum <= 1;
		     Bit#(6) curr_qp = (chromaFlag==0 ? curr_qpy : curr_qpc);
		     Bit#(6) top_qp = (chromaFlag==0 ? top_qpy : top_qpc);
		     Bit#(7) qpavtemp = zeroExtend(curr_qp)+zeroExtend(top_qp)+1;
		     Bit#(6) qpav = qpavtemp[6:1];
		     Bit#(8) indexAtemp = zeroExtend(qpav)+signExtend(slice_alpha_c0_offset);
		     Bit#(8) indexBtemp = zeroExtend(qpav)+signExtend(slice_beta_offset);
		     Bit#(6) indexA = (indexAtemp[7]==1 ? 0 : (indexAtemp[6:0]>51 ? 51 : indexAtemp[5:0]));
		     Bit#(6) indexB = (indexBtemp[7]==1 ? 0 : (indexBtemp[6:0]>51 ? 51 : indexBtemp[5:0]));
		     alphaMbEdge <= alpha_table[indexA];
		     betaMbEdge <= beta_table[indexB];
		     Vector#(3,Bit#(5)) tc0temp = arrayToVector(tc0_table[indexA]);
		     tc0MbEdge <= tc0temp;
		  end
	       else if(pixelNum==12)
		  blockNum <= blockNum+1;
	       pixelNum <= pixelNum+4;
	    end
	 //default: $display( "ERROR Deblocking Filter: horizontal non-PBoutput input");
      endcase
   endrule


   rule vertical ( process==Vertical && !startLastOutput && dataRespCount==0 && currMbHor<zeroExtend(picWidth) );
      //$display( "TRACE Deblocking Filter: vertical %0d %0d", colNum, rowNum);
      //$display( "TRACE Deblocking Filter: vertical topVector %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h", topVector[0], topVector[1], topVector[2], topVector[3], topVector[4], topVector[5], topVector[6], topVector[7], topVector[8], topVector[9], topVector[10], topVector[11], topVector[12], topVector[13], topVector[14], topVector[15]);
      Bool topEdge = (rowNum==0);
      Vector#(64,Bit#(32)) workVectorNext = workVector;
      Vector#(16,Bit#(32)) topVectorNext = topVector;
      Vector#(64,Bit#(32)) workV = workVector;
      Vector#(4,Bit#(32)) tempV = replicate(0);
      Vector#(4,Bit#(64)) resultV = replicate(0);
      Bit#(8) alpha;
      Bit#(5) beta;
      Vector#(3,Bit#(5)) tc0;
      Bit#(4) crNum = {colNum,rowNum};
      if(topEdge)
	 begin
	    tempV[0] = topVector[{colNum,2'b00}];
	    tempV[1] = topVector[{colNum,2'b01}];
	    tempV[2] = topVector[{colNum,2'b10}];
	    tempV[3] = topVector[{colNum,2'b11}];
	    alpha = alphaMbEdge;
	    beta = betaMbEdge;
	    tc0 = tc0MbEdge;
	 end
      else
	 begin
	    tempV[0] = workV[{(crNum-1),2'b00}];
	    tempV[1] = workV[{(crNum-1),2'b01}];
	    tempV[2] = workV[{(crNum-1),2'b10}];
	    tempV[3] = workV[{(crNum-1),2'b11}];
	    alpha = alphaInternal;
	    beta = betaInternal;
	    tc0 = tc0Internal;
	 end
      resultV[0] = {workV[{crNum,2'b11}][7:0],workV[{crNum,2'b10}][7:0],workV[{crNum,2'b01}][7:0],workV[{crNum,2'b00}][7:0],tempV[3][7:0],tempV[2][7:0],tempV[1][7:0],tempV[0][7:0]};
      resultV[1] = {workV[{crNum,2'b11}][15:8],workV[{crNum,2'b10}][15:8],workV[{crNum,2'b01}][15:8],workV[{crNum,2'b00}][15:8],tempV[3][15:8],tempV[2][15:8],tempV[1][15:8],tempV[0][15:8]};
      resultV[2] = {workV[{crNum,2'b11}][23:16],workV[{crNum,2'b10}][23:16],workV[{crNum,2'b01}][23:16],workV[{crNum,2'b00}][23:16],tempV[3][23:16],tempV[2][23:16],tempV[1][23:16],tempV[0][23:16]};
      resultV[3] = {workV[{crNum,2'b11}][31:24],workV[{crNum,2'b10}][31:24],workV[{crNum,2'b01}][31:24],workV[{crNum,2'b00}][31:24],tempV[3][31:24],tempV[2][31:24],tempV[1][31:24],tempV[0][31:24]};
      if(filter_test({workV[{crNum,2'b01}][7:0],workV[{crNum,2'b00}][7:0],tempV[3][7:0],tempV[2][7:0]},alpha,beta))
	 resultV[0] = filter_input(resultV[0],chromaFlag==1,tpl_2(bSfile.sub((chromaFlag==0?{rowNum[1],colNum[1],rowNum[0],colNum[0]}:{rowNum[0],colNum[0],2'b00}))),alpha,beta,tc0);
      if(filter_test({workV[{crNum,2'b01}][15:8],workV[{crNum,2'b00}][15:8],tempV[3][15:8],tempV[2][15:8]},alpha,beta))
	 resultV[1] = filter_input(resultV[1],chromaFlag==1,tpl_2(bSfile.sub((chromaFlag==0?{rowNum[1],colNum[1],rowNum[0],colNum[0]}:{rowNum[0],colNum[0],2'b00}))),alpha,beta,tc0);
      if(filter_test({workV[{crNum,2'b01}][23:16],workV[{crNum,2'b00}][23:16],tempV[3][23:16],tempV[2][23:16]},alpha,beta))
	 resultV[2] = filter_input(resultV[2],chromaFlag==1,tpl_2(bSfile.sub((chromaFlag==0?{rowNum[1],colNum[1],rowNum[0],colNum[0]}:{rowNum[0],colNum[0],2'b01}))),alpha,beta,tc0);
      if(filter_test({workV[{crNum,2'b01}][31:24],workV[{crNum,2'b00}][31:24],tempV[3][31:24],tempV[2][31:24]},alpha,beta))
	 resultV[3] = filter_input(resultV[3],chromaFlag==1,tpl_2(bSfile.sub((chromaFlag==0?{rowNum[1],colNum[1],rowNum[0],colNum[0]}:{rowNum[0],colNum[0],2'b01}))),alpha,beta,tc0);
      if(topEdge)
	 begin
	    topVectorNext[{colNum,2'b00}] = {resultV[3][7:0],resultV[2][7:0],resultV[1][7:0],resultV[0][7:0]};
	    topVectorNext[{colNum,2'b01}] = {resultV[3][15:8],resultV[2][15:8],resultV[1][15:8],resultV[0][15:8]};
	    topVectorNext[{colNum,2'b10}] = {resultV[3][23:16],resultV[2][23:16],resultV[1][23:16],resultV[0][23:16]};
	    topVectorNext[{colNum,2'b11}] = {resultV[3][31:24],resultV[2][31:24],resultV[1][31:24],resultV[0][31:24]};
	 end
      else
	 begin
	    workVectorNext[{(crNum-1),2'b00}] = {resultV[3][7:0],resultV[2][7:0],resultV[1][7:0],resultV[0][7:0]};
	    workVectorNext[{(crNum-1),2'b01}] = {resultV[3][15:8],resultV[2][15:8],resultV[1][15:8],resultV[0][15:8]};
	    workVectorNext[{(crNum-1),2'b10}] = {resultV[3][23:16],resultV[2][23:16],resultV[1][23:16],resultV[0][23:16]};
	    workVectorNext[{(crNum-1),2'b11}] = {resultV[3][31:24],resultV[2][31:24],resultV[1][31:24],resultV[0][31:24]};
	 end
      workVectorNext[{crNum,2'b00}] =  {resultV[3][39:32],resultV[2][39:32],resultV[1][39:32],resultV[0][39:32]};
      workVectorNext[{crNum,2'b01}] =  {resultV[3][47:40],resultV[2][47:40],resultV[1][47:40],resultV[0][47:40]};
      workVectorNext[{crNum,2'b10}] =  {resultV[3][55:48],resultV[2][55:48],resultV[1][55:48],resultV[0][55:48]};
      workVectorNext[{crNum,2'b11}] =  {resultV[3][63:56],resultV[2][63:56],resultV[1][63:56],resultV[0][63:56]};
      if(topEdge)
	 topVector <= topVectorNext;
      workVector <= workVectorNext;
      if(rowNum==3 || (chromaFlag==1 && rowNum==1))
	 begin
	    if(colNum==3)
	       startLastOutput <= True;
	    else
	       begin
		  if(filterTopMbEdgeFlag)
		     rowNum <= 0;
		  else
		     rowNum <= 1;
	       end
	    colNum <= colNum+1;
	 end
      else
	rowNum <= rowNum+1;       
   endrule


   rule outputing ( process==Vertical && !outputingFinished && currMbHor<zeroExtend(picWidth) );
      //$display( "TRACE Deblocking Filter: outputting %0d %0d", blockNum, pixelNum);
      Bit#(2) blockHor = pixelNum[1:0];
      Bit#(2) blockVer = blockNum[1:0];
      Bit#(2) pixelVer = pixelNum[3:2];
      Bit#(PicWidthSz) currMbHorT = truncate(currMbHor);
      Bool stalling = False;
      if(currMb==0)
	 begin
	    if(startLastOutput)
	       outputingFinished <= True;
	 end
      else
	 begin
	    Bit#(7) leftAddr;
	    if(chromaFlag==0)
	       leftAddr = {1'b0,blockHor,blockVer,pixelVer};
	    else
	       leftAddr = {2'b10,blockHor,blockVer[0],pixelVer};
	    Bit#(32) leftData = leftVector[leftAddr];
	    if(!(blockNum==3 || (blockNum==1 && chromaFlag==1)))
	       begin
		  if(chromaFlag==0)
		     outfifo.enq(DFBLuma {ver:{(currMbHorT==0 ? currMbVer-1 : currMbVer),blockVer,pixelVer},hor:{(currMbHorT==0 ? picWidth-1 : currMbHorT-1),blockHor},data:leftData});
		  else
		     outfifo.enq(DFBChroma {uv:blockHor[1],ver:{(currMbHorT==0 ? currMbVer-1 : currMbVer),blockVer[0],pixelVer},hor:{(currMbHorT==0 ? picWidth-1 : currMbHorT-1),blockHor[0]},data:leftData});
	       end
	    else if(startLastOutput)
	       begin
		  Bit#(PicWidthSz) temp = ((currMbHor==0) ? (picWidth-1) : truncate(currMbHor-1));
		  dataMemReqQ.enq(StoreReq {addr:{temp,chromaFlag,blockHor,pixelVer},data:leftData});
		  if(currMbVer > 0)
		     begin
			//$display( "TRACE Deblocking Filter: outputting last output %0d %0d %h", blockHor, pixelVer, topVector[{blockHor,pixelVer}]);
			Bit#(32) topData = topVector[{blockHor,pixelVer}];
			if(chromaFlag==0)
			   outfifo.enq(DFBLuma {ver:{currMbVer-1,2'b11,pixelVer},hor:{currMbHorT,blockHor},data:topData});
			else
			   outfifo.enq(DFBChroma {uv:blockHor[1],ver:{currMbVer-1,1'b1,pixelVer},hor:{currMbHorT,blockHor[0]},data:topData});
		     end
	       end
	    else
	       stalling = True;
	    if(!stalling)
	       begin
		  if(pixelNum==15)
		     begin
			if(blockNum==3 || (chromaFlag==1 && blockNum==1))
			   begin
			      if(currMbVer==picHeight-1)
				 blockNum <= (chromaFlag==0 ? 3 : 1);
			      else
				 blockNum <= 0;
			      outputingFinished <= True;
			   end
			else
			   blockNum <= blockNum+1;
		     end
		  pixelNum <= pixelNum+1;
	       end
	 end
   endrule


   rule verticaltocleanup  ( process==Vertical && startLastOutput && outputingFinished);
      process <= Cleanup;
      startLastOutput <= False;
      outputingFinished <= False;
   endrule


   rule cleanup ( process==Cleanup && currMbHor<zeroExtend(picWidth) );
      //$display( "TRACE Deblocking Filter: cleanup %0d %0d", blockNum, pixelNum);
      Bit#(2) blockHor = pixelNum[1:0];
      Bit#(2) blockVer = blockNum[1:0];
      Bit#(2) pixelVer = pixelNum[3:2];
      Bit#(PicWidthSz) currMbHorT = truncate(currMbHor);
      Vector#(96,Bit#(32)) leftVectorNext = leftVector;
      if(blockNum==0)
	 begin
	    if(chromaFlag==0)
	       begin
		  for(Integer ii=0; ii<64; ii=ii+1)
		     leftVectorNext[fromInteger(ii)] = workVector[fromInteger(ii)];
		  chromaFlag <= 1;
		  process <= Initialize;
	       end
	    else
	       begin
		  for(Integer ii=0; ii<32; ii=ii+1)
		     begin
			Bit#(5) tempAddr = fromInteger(ii);
			leftVectorNext[{2'b10,tempAddr}] = workVector[{tempAddr[4:3],1'b0,tempAddr[2:0]}];
		     end
		  chromaFlag <= 0;
		  process <= Passing;
		  Bit#(PicWidthSz) temp = truncate(currMbHor);
		  parameterMemReqQ.enq(StoreReq {addr:temp,data:{curr_intra,curr_qpc,curr_qpy}});
		  left_intra <= curr_intra;
		  left_qpc <= curr_qpc;
		  left_qpy <= curr_qpy;
		  currMb <= currMb+1;
		  currMbHor <= currMbHor+1;
		  if(currMbVer==picHeight-1 && currMbHor==zeroExtend(picWidth-1))
		     outfifo.enq(EndOfFrame);
	       end
	    leftVector <= leftVectorNext;
	 end
      else if(blockNum < 8)
	 begin
	    Bit#(7) leftAddr;
	    if(chromaFlag==0)
	       leftAddr = {1'b0,blockHor,blockVer,pixelVer};
	    else
	       leftAddr = {2'b10,blockHor,blockVer[0],pixelVer};
	    Bit#(32) leftData = leftVector[leftAddr];
	    if(chromaFlag==0)
	       outfifo.enq(DFBLuma {ver:{(currMbHorT==0 ? currMbVer-1 : currMbVer),blockVer,pixelVer},hor:{(currMbHorT==0 ? picWidth-1 : currMbHorT-1),blockHor},data:leftData});
	    else
	       outfifo.enq(DFBChroma {uv:blockHor[1],ver:{(currMbHorT==0 ? currMbVer-1 : currMbVer),blockVer[0],pixelVer},hor:{(currMbHorT==0 ? picWidth-1 : currMbHorT-1),blockHor[0]},data:leftData});
	    if(pixelNum==15)
	       begin
		  if(currMbHor==zeroExtend(picWidth-1))
		     blockNum <= 8;
		  else
		     blockNum <= 0;
	       end
	    pixelNum <= pixelNum+1;
	 end
      else
	 begin
	    Bit#(6) currAddr = {blockHor,blockVer,pixelVer};
	    Bit#(32) currData = workVector[currAddr];
	    if(chromaFlag==0)
	       outfifo.enq(DFBLuma {ver:{currMbVer,blockVer,pixelVer},hor:{currMbHorT,blockHor},data:currData});
	    else
	       outfifo.enq(DFBChroma {uv:blockHor[1],ver:{currMbVer,blockVer[0],pixelVer},hor:{currMbHorT,blockHor[0]},data:currData});
	    if(pixelNum==15)
	       begin
		  if(blockNum[1:0]==3 || (blockNum[1:0]==1 && chromaFlag==1))
		     blockNum <= 0;
		  else
		     blockNum <= blockNum+1;
	       end
	    pixelNum <= pixelNum+1;
	 end
   endrule
   



   
   
   interface Client mem_client_data;
      interface Get request  = fifoToGet(dataMemReqQ);
      interface Put response = fifoToPut(dataMemRespQ);
   endinterface

   interface Client mem_client_parameter;
      interface Get request  = fifoToGet(parameterMemReqQ);
      interface Put response = fifoToPut(parameterMemRespQ);
   endinterface

   interface Put ioin  = fifoToPut(infifo);
   interface Get ioout = fifoToGet(outfifo);
      
endmodule

endpackage
