
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
// interpolator implementation
//----------------------------------------------------------------------
//
//

package mkInterpolator;

import H264Types::*;
import IInterpolator::*;
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
 struct { Bit#(2) xFracL; Bit#(2) yFracL; Bit#(2) offset; IPBlockType bt; } IPWLuma;
 struct { Bit#(3) xFracC; Bit#(3) yFracC; Bit#(2) offset; IPBlockType bt; } IPWChroma;
}
InterpolatorWT deriving(Eq,Bits);


//-----------------------------------------------------------
// Helper functions

function Bit#(8) clip1y10to8( Bit#(10) innum );
   if(innum[9] == 1)
      return 0;
   else if(innum[8] == 1)
      return 255;
   else
      return truncate(innum);
endfunction

function Bit#(15) interpolate8to15( Bit#(8) in0, Bit#(8) in1, Bit#(8) in2, Bit#(8) in3, Bit#(8) in4, Bit#(8) in5 );
   return zeroExtend(in0) - 5*zeroExtend(in1) + 20*zeroExtend(in2) + 20*zeroExtend(in3) - 5*zeroExtend(in4) + zeroExtend(in5);
endfunction

function Bit#(8) interpolate15to8( Bit#(15) in0, Bit#(15) in1, Bit#(15) in2, Bit#(15) in3, Bit#(15) in4, Bit#(15) in5 );
   Bit#(20) temp = signExtend(in0) - 5*signExtend(in1) + 20*signExtend(in2) + 20*signExtend(in3) - 5*signExtend(in4) + signExtend(in5) + 512;
   return clip1y10to8(truncate(temp>>10));
endfunction



//-----------------------------------------------------------
// Interpolation Module
//-----------------------------------------------------------


(* synthesize *)
module mkInterpolator( Interpolator );
   
   FIFO#(InterpolatorIT) reqfifoLoad <- mkSizedFIFO(interpolator_reqfifoLoad_size);
   FIFO#(InterpolatorWT) reqfifoWork <- mkSizedFIFO(interpolator_reqfifoWork_size);
   FIFO#(Vector#(4,Bit#(8))) outfifo <- mkFIFO;
   Reg#(Bool) endOfFrameFlag <- mkReg(False);
   FIFO#(InterpolatorLoadReq)  memReqQ  <- mkFIFO;
   FIFO#(InterpolatorLoadResp) memRespQ <- mkSizedFIFO(interpolator_memRespQ_size);

   Reg#(Bit#(PicWidthSz))  picWidth  <- mkReg(maxPicWidthInMB);
   Reg#(Bit#(PicHeightSz)) picHeight <- mkReg(0);

   RFile1#(Bit#(5),Vector#(4,Bit#(15))) workFile  <- mkRFile1Full();
   RFile1#(Bit#(4),Vector#(4,Bit#(8))) resultFile <- mkRFile1Full();

   Reg#(Bit#(1)) loadStage  <- mkReg(0);
   Reg#(Bit#(2)) loadHorNum <- mkReg(0);
   Reg#(Bit#(4)) loadVerNum <- mkReg(0);

   Reg#(Bit#(1)) workStage     <- mkReg(0);
   Reg#(Bit#(2)) workMbPart    <- mkReg(0);//only for Chroma
   Reg#(Bit#(2)) workSubMbPart <- mkReg(0);
   Reg#(Bit#(2)) workHorNum    <- mkReg(0);
   Reg#(Bit#(4)) workVerNum    <- mkReg(0);
   Reg#(Vector#(20,Bit#(8))) workVector8 <- mkRegU;
   Reg#(Vector#(20,Bit#(15))) workVector15 <- mkRegU;
   Reg#(Vector#(4,Bit#(1))) resultReady <- mkRegU;
   Reg#(Bool) workDone <- mkReg(False);

   Reg#(Bit#(2)) outBlockNum <- mkReg(0);
   Reg#(Bit#(2)) outPixelNum <- mkReg(0);
   Reg#(Bool) outDone <- mkReg(False);


   rule sendEndOfFrameReq( endOfFrameFlag );
      endOfFrameFlag <= False;
      memReqQ.enq(IPLoadEndFrame);
   endrule
   
 
   rule loadLuma( reqfifoLoad.first() matches tagged IPLuma .reqdata &&& !endOfFrameFlag );
      Bit#(2) xfracl = reqdata.mvhor[1:0];
      Bit#(2) yfracl = reqdata.mvver[1:0];
      Bool twoStage = (xfracl==1||xfracl==3) && (yfracl==1||yfracl==3);
      Bool horInter = (twoStage ? loadStage==1 : xfracl!=0);
      Bool verInter = (twoStage ? loadStage==0 : yfracl!=0);
      Bit#(1) horOut = 0;
      Bit#(2) offset = reqdata.mvhor[3:2] + ((twoStage&&verInter&&xfracl==3) ? 1 : 0);
      Bit#(TAdd#(PicWidthSz,2)) horAddr;
      Bit#(TAdd#(PicHeightSz,4)) verAddr;
      Bit#(TAdd#(PicWidthSz,12)) horTemp = zeroExtend({reqdata.hor,2'b00}) + zeroExtend({loadHorNum,2'b00}) + (xfracl==3&&(yfracl==1||yfracl==3)&&loadStage==0 ? 1 : 0);
      Bit#(TAdd#(PicHeightSz,10)) verTemp = zeroExtend(reqdata.ver) + zeroExtend(loadVerNum) + (yfracl==3&&(xfracl==1||xfracl==3)&&loadStage==1 ? 1 : 0);
      Bit#(13) mvhortemp = signExtend(reqdata.mvhor[13:2])-(horInter?2:0);
      Bit#(11) mvvertemp = signExtend(reqdata.mvver[11:2])-(verInter?2:0);
      if(mvhortemp[12]==1 && zeroExtend(0-mvhortemp)>horTemp)
	 begin
	    horAddr = 0;
	    horOut = 1;
	 end
      else
	 begin
	    horTemp = horTemp + signExtend(mvhortemp);
	    if(horTemp>=zeroExtend({picWidth,4'b0000}))
	       begin
		  horAddr = {picWidth-1,2'b11};
		  horOut = 1;
	       end
	    else
	       horAddr = truncate(horTemp>>2);
	 end
      if(mvvertemp[10]==1 && zeroExtend(0-mvvertemp)>verTemp)
	 verAddr = 0;
      else
	 begin
	    verTemp = verTemp + signExtend(mvvertemp);
	    if(verTemp>=zeroExtend({picHeight,4'b0000}))
	       verAddr = {picHeight-1,4'b1111};
	    else
	       verAddr = truncate(verTemp);
	 end
      memReqQ.enq(IPLoadLuma {refIdx:reqdata.refIdx,horOutOfBounds:horOut,hor:horAddr,ver:verAddr});
      Bool verFirst = (twoStage&&loadStage==0) || (yfracl==2&&(xfracl==1||xfracl==3));
      Bit#(2) loadHorNumMax = (reqdata.bt==IP8x8||reqdata.bt==IP8x4 ? 1 : 0) + (horInter ? 2 : (offset==0 ? 0 : 1));
      Bit#(4) loadVerNumMax = (reqdata.bt==IP8x8||reqdata.bt==IP4x8 ? 7 : 3) + (verInter ? 5 : 0);
      if(verFirst)
	 begin
	    if(loadVerNum < loadVerNumMax)
	       loadVerNum <= loadVerNum+1;
	    else
	       begin
		  loadVerNum <= 0;
		  if(loadHorNum < loadHorNumMax)
		     loadHorNum <= loadHorNum+1;
		  else
		     begin
			loadHorNum <= 0;
			if(twoStage)
			   loadStage <= 1;
			else
			   reqfifoLoad.deq();
		     end
	       end
	 end
      else
	 begin
	    if(loadHorNum < loadHorNumMax)
	       loadHorNum <= loadHorNum+1;
	    else
	       begin
		  loadHorNum <= 0;
		  if(loadVerNum < loadVerNumMax)
		     loadVerNum <= loadVerNum+1;
		  else
		     begin
			loadVerNum <= 0;
			loadStage <= 0;
			reqfifoLoad.deq();
		     end
	       end
	 end
      if(reqdata.bt==IP16x16 || reqdata.bt==IP16x8 || reqdata.bt==IP8x16)
	 $display( "ERROR Interpolation: loadLuma block sizes > 8x8 not supported");
      //$display( "Trace interpolator: loadLuma %h %h %h %h %h %h %h", xfracl, yfracl, loadHorNum, loadVerNum, reqdata.refIdx, horAddr, verAddr);
   endrule   


   rule loadChroma( reqfifoLoad.first() matches tagged IPChroma .reqdata &&& !endOfFrameFlag );
      Bit#(3) xfracc = reqdata.mvhor[2:0];
      Bit#(3) yfracc = reqdata.mvver[2:0];
      Bit#(2) offset = reqdata.mvhor[4:3]+{reqdata.hor[0],1'b0};
      Bit#(1) horOut = 0;
      Bit#(TAdd#(PicWidthSz,1)) horAddr;
      Bit#(TAdd#(PicHeightSz,3)) verAddr;
      Bit#(TAdd#(PicWidthSz,11)) horTemp = zeroExtend({reqdata.hor,1'b0}) + zeroExtend({loadHorNum,2'b00});
      Bit#(TAdd#(PicHeightSz,9)) verTemp = zeroExtend(reqdata.ver) + zeroExtend(loadVerNum);
      if(reqdata.mvhor[13]==1 && zeroExtend(0-reqdata.mvhor[13:3])>horTemp)
	 begin
	    horAddr = 0;
	    horOut = 1;
	 end
      else
	 begin
	    horTemp = horTemp + signExtend(reqdata.mvhor[13:3]);
	    if(horTemp>=zeroExtend({picWidth,3'b000}))
	       begin
		  horAddr = {picWidth-1,1'b1};
		  horOut = 1;
	       end
	    else
	       horAddr = truncate(horTemp>>2);
	 end
      if(reqdata.mvver[11]==1 && zeroExtend(0-reqdata.mvver[11:3])>verTemp)
	 verAddr = 0;
      else
	 begin
	    verTemp = verTemp + signExtend(reqdata.mvver[11:3]);
	    if(verTemp>=zeroExtend({picHeight,3'b000}))
	       verAddr = {picHeight-1,3'b111};
	    else
	       verAddr = truncate(verTemp);
	 end
      memReqQ.enq(IPLoadChroma {refIdx:reqdata.refIdx,uv:reqdata.uv,horOutOfBounds:horOut,hor:horAddr,ver:verAddr});
      Bit#(2) loadHorNumMax = (reqdata.bt==IP4x8||reqdata.bt==IP4x4 ? (offset[1]==0||(xfracc==0&&offset!=3) ? 0 : 1) : ((reqdata.bt==IP16x16||reqdata.bt==IP16x8 ? 1 : 0) + (xfracc==0&&offset==0 ? 0 : 1)));
      Bit#(4) loadVerNumMax = (reqdata.bt==IP16x16||reqdata.bt==IP8x16 ? 7 : (reqdata.bt==IP16x8||reqdata.bt==IP8x8||reqdata.bt==IP4x8 ? 3 : 1)) + (yfracc==0 ? 0 : 1);
      if(loadHorNum < loadHorNumMax)
	 loadHorNum <= loadHorNum+1;
      else
	 begin
	    loadHorNum <= 0;
	    if(loadVerNum < loadVerNumMax)
	       loadVerNum <= loadVerNum+1;
	    else
	       begin
		  loadVerNum <= 0;
		  reqfifoLoad.deq();
	       end
	 end
      //$display( "Trace interpolator: loadChroma %h %h %h %h %h %h %h", xfracc, yfracc, loadHorNum, loadVerNum, reqdata.refIdx, horAddr, verAddr);
   endrule
   

   rule workLuma ( reqfifoWork.first() matches tagged IPWLuma .reqdata &&& !workDone );
      let xfracl = reqdata.xFracL;
      let yfracl = reqdata.yFracL;
      let offset = reqdata.offset;
      let blockT = reqdata.bt;
      Vector#(20,Bit#(8)) workVector8Next = workVector8;
      Vector#(20,Bit#(15)) workVector15Next = workVector15;
      Vector#(4,Bit#(1)) resultReadyNext = resultReady;
      if(workStage == 0)
	 begin
	    if(memRespQ.first() matches tagged IPLoadResp .tempreaddata)
	       begin
		  memRespQ.deq();
		  Vector#(4,Bit#(8)) readdata = replicate(0);
		  readdata[0] = tempreaddata[7:0];
		  readdata[1] = tempreaddata[15:8];
		  readdata[2] = tempreaddata[23:16];
		  readdata[3] = tempreaddata[31:24];
		  //$display( "Trace interpolator: workLuma stage 0 readdata %h %h %h %h %h %h", workHorNum, workVerNum, readdata[3], readdata[2], readdata[1], readdata[0] );
		  Vector#(4,Bit#(8)) tempResult8 = replicate(0);
		  Vector#(4,Bit#(15)) tempResult15 = replicate(0);
		  if(xfracl==0 || yfracl==0 || xfracl==2)
		     begin
			if(xfracl==0)//reorder
			   begin
			      for(Integer ii=0; ii<4; ii=ii+1)
				 begin
				    Bit#(2) offsetplusii = offset+fromInteger(ii);
				    if(offset <= 3-fromInteger(ii) && offset!=0)
				       tempResult8[ii] = workVector8[offsetplusii];
				    else
				       tempResult8[ii] = readdata[offsetplusii];
				    workVector8Next[ii] = readdata[ii];
				 end
			      for(Integer ii=0; ii<4; ii=ii+1)
				 tempResult15[ii] = zeroExtend({tempResult8[ii],5'b00000});
			   end
			else//horizontal interpolation
			   begin
			      offset = offset-2;
			      for(Integer ii=0; ii<8; ii=ii+1)
				 workVector8Next[ii] = workVector8[ii+4];
			      for(Integer ii=0; ii<4; ii=ii+1)
				 begin
				    Bit#(4) tempIndex = fromInteger(ii) + 8 - zeroExtend(offset);
				    workVector8Next[tempIndex] = readdata[ii];
				 end
			      for(Integer ii=0; ii<4; ii=ii+1)
				 begin
				    tempResult15[ii] = interpolate8to15(workVector8Next[ii],workVector8Next[ii+1],workVector8Next[ii+2],workVector8Next[ii+3],workVector8Next[ii+4],workVector8Next[ii+5]);
				    tempResult8[ii] = clip1y10to8(truncate((tempResult15[ii]+16)>>5));
				    if(xfracl == 1)
				       tempResult8[ii] = truncate(({1'b0,tempResult8[ii]} + {1'b0,workVector8Next[ii+2]} + 1) >> 1);
				    else if(xfracl == 3)
				       tempResult8[ii] = truncate(({1'b0,tempResult8[ii]} + {1'b0,workVector8Next[ii+3]} + 1) >> 1);
				 end
			   end
			Bit#(2) workHorNumOffset = (xfracl!=0 ? 2 : (reqdata.offset==0 ? 0 : 1));
			if(workHorNum >= workHorNumOffset)
			   begin
			      Bit#(1) horAddr = truncate(workHorNum-workHorNumOffset);
			      if(yfracl == 0)//write to resultFile
				 begin
				    Bit#(3) verAddr = truncate(workVerNum);
				    horAddr = horAddr + ((blockT==IP4x8&&workSubMbPart==1)||(blockT==IP4x4&&workSubMbPart[0]==1) ? 1 : 0);
				    verAddr = verAddr + ((blockT==IP8x4&&workSubMbPart==1)||(blockT==IP4x4&&workSubMbPart[1]==1) ? 4 : 0);
				    resultFile.upd({verAddr,horAddr},tempResult8);
				    if(verAddr[1:0] == 3)
				       resultReadyNext[{verAddr[2],horAddr}] = 1;
				 end
			      else//write to workFile
				 workFile.upd({workVerNum,horAddr},tempResult15);
			   end
			Bit#(2) workHorNumMax = (blockT==IP8x8||blockT==IP8x4 ? 1 : 0) + workHorNumOffset;
			Bit#(4) workVerNumMax = (blockT==IP8x8||blockT==IP4x8 ? 7 : 3) + (yfracl!=0 ? 5 : 0);
			if(workHorNum < workHorNumMax)
			   workHorNum <= workHorNum+1;
			else
			   begin
			      workHorNum <= 0;
			      if(workVerNum < workVerNumMax)
				 workVerNum <= workVerNum+1;
			      else
				 begin
				    workVerNum <= 0;
				    if(yfracl!=0)
				       workStage <= 1;
				    else
				       begin
					  if(((blockT==IP4x8 || blockT==IP8x4) && workSubMbPart==0) || (blockT==IP4x4 && workSubMbPart<3))
					     workSubMbPart <= workSubMbPart+1;
					  else
					     begin
						workSubMbPart <= 0;
						workDone <= True;
					     end
					  reqfifoWork.deq();
				       end
				 end
			   end
		     end
		  else//vertical interpolation
		     begin
			offset = offset + (xfracl==3&&(yfracl==1||yfracl==3) ? 1 : 0);
			for(Integer ii=0; ii<4; ii=ii+1)
			   tempResult15[ii] = interpolate8to15(workVector8[ii],workVector8[ii+4],workVector8[ii+8],workVector8[ii+12],workVector8[ii+16],readdata[ii]);
			for(Integer ii=0; ii<16; ii=ii+1)
			   workVector8Next[ii] = workVector8[ii+4];
			for(Integer ii=0; ii<4; ii=ii+1)
			   workVector8Next[ii+16] = readdata[ii];
			Bit#(2) workHorNumMax = (blockT==IP8x8||blockT==IP8x4 ? 1 : 0) + (yfracl==2 ? 2 : (offset==0 ? 0 : 1));
			Bit#(4) workVerNumMax = (blockT==IP8x8||blockT==IP4x8 ? 7 : 3) + 5;
			Bit#(2) horAddr = workHorNum;
			Bit#(3) verAddr = truncate(workVerNum-5);
			if(workVerNum > 4)
			   begin
			      workFile.upd({verAddr,horAddr},tempResult15);
			      //$display( "Trace interpolator: workLuma stage 0 result %h %h %h %h %h %h %h", workHorNum, workVerNum, {verAddr,horAddr}, tempResult15[3], tempResult15[2], tempResult15[1], tempResult15[0]);
			   end
			if(workVerNum < workVerNumMax)
			   workVerNum <= workVerNum+1;
			else
			   begin
			      workVerNum <= 0;
			      if(workHorNum < workHorNumMax)
				 workHorNum <= workHorNum+1;
			      else
				 begin
				    workHorNum <= 0;
				    workStage <= 1;
				 end
			   end
		     end
	       end
	 end
      else
	 begin
	    Vector#(4,Bit#(8)) tempResult8 = replicate(0);
	    Vector#(4,Bit#(15)) readdata = replicate(0);
	    if(yfracl==0)
	       $display( "ERROR Interpolation: workLuma loadStage==1 and yfracl==0");
	    if(xfracl==0 || xfracl==2)//vertical interpolation
	       begin
		  readdata = workFile.sub({workVerNum,workHorNum[0]});
		  for(Integer ii=0; ii<4; ii=ii+1)
		     begin
			tempResult8[ii] = interpolate15to8(workVector15[ii],workVector15[ii+4],workVector15[ii+8],workVector15[ii+12],workVector15[ii+16],readdata[ii]);
			if(yfracl == 1)
			   tempResult8[ii] = truncate(({1'b0,tempResult8[ii]} + {1'b0,clip1y10to8(truncate((workVector15[ii+8]+16)>>5))} + 1) >> 1);
			else if(yfracl == 3)
			   tempResult8[ii] = truncate(({1'b0,tempResult8[ii]} + {1'b0,clip1y10to8(truncate((workVector15[ii+12]+16)>>5))} + 1) >> 1);
		     end
		  for(Integer ii=0; ii<16; ii=ii+1)
		     workVector15Next[ii] = workVector15[ii+4];
		  for(Integer ii=0; ii<4; ii=ii+1)
		     workVector15Next[ii+16] = readdata[ii];
		  Bit#(2) workHorNumMax = 1;
		  Bit#(4) workVerNumMax = (blockT==IP8x8||blockT==IP4x8 ? 7 : 3) + 5;
		  if(workVerNum > 4)				  
		     begin
			Bit#(1) horAddr = truncate(workHorNum);
			Bit#(3) verAddr = truncate(workVerNum-5);
			horAddr = horAddr + ((blockT==IP4x8&&workSubMbPart==1)||(blockT==IP4x4&&workSubMbPart[0]==1) ? 1 : 0);
			verAddr = verAddr + ((blockT==IP8x4&&workSubMbPart==1)||(blockT==IP4x4&&workSubMbPart[1]==1) ? 4 : 0);
			resultFile.upd({verAddr,horAddr},tempResult8);
			if(verAddr[1:0] == 3)
			   resultReadyNext[{verAddr[2],horAddr}] = 1;
		     end
		  if(workVerNum < workVerNumMax)
		     workVerNum <= workVerNum+1;
		  else
		     begin
			workVerNum <= 0;
			if(workHorNum < workHorNumMax)
			   workHorNum <= workHorNum+1;
			else
			   begin
			      workHorNum <= 0;
			      workStage <= 0;
			      if(((blockT==IP4x8 || blockT==IP8x4) && workSubMbPart==0) || (blockT==IP4x4 && workSubMbPart<3))
				 workSubMbPart <= workSubMbPart+1;
			      else
				 begin
				    workSubMbPart <= 0;
				    workDone <= True;
				 end
			      reqfifoWork.deq();
			   end
		     end
	       end
	    else//horizontal interpolation
	       begin
		  offset = offset-2;
		  if(yfracl == 2)
		     begin
			readdata = workFile.sub({workVerNum[2:0],workHorNum});
			for(Integer ii=0; ii<8; ii=ii+1)
			   workVector15Next[ii] = workVector15[ii+4];
			for(Integer ii=0; ii<4; ii=ii+1)
			   begin
			      Bit#(4) tempIndex = fromInteger(ii) + 8 - zeroExtend(offset);
			      workVector15Next[tempIndex] = readdata[ii];
			   end
			for(Integer ii=0; ii<4; ii=ii+1)
			   begin
			      tempResult8[ii] = interpolate15to8(workVector15Next[ii],workVector15Next[ii+1],workVector15Next[ii+2],workVector15Next[ii+3],workVector15Next[ii+4],workVector15Next[ii+5]);
			      if(xfracl == 1)
				 tempResult8[ii] = truncate(({1'b0,tempResult8[ii]} + {1'b0,clip1y10to8(truncate((workVector15Next[ii+2]+16)>>5))} + 1) >> 1);
			      else if(xfracl == 3)
				 tempResult8[ii] = truncate(({1'b0,tempResult8[ii]} + {1'b0,clip1y10to8(truncate((workVector15Next[ii+3]+16)>>5))} + 1) >> 1);
			   end
		     end
		  else
		     begin
			if(memRespQ.first() matches tagged IPLoadResp .tempreaddata8)
			   begin
			      memRespQ.deq();
			      Vector#(4,Bit#(8)) readdata8 = replicate(0);
			      readdata8[0] = tempreaddata8[7:0];
			      readdata8[1] = tempreaddata8[15:8];
			      readdata8[2] = tempreaddata8[23:16];
			      readdata8[3] = tempreaddata8[31:24];
			      for(Integer ii=0; ii<8; ii=ii+1)
				 workVector8Next[ii] = workVector8[ii+4];
			      for(Integer ii=0; ii<4; ii=ii+1)
				 begin
				    Bit#(4) tempIndex = fromInteger(ii) + 8 - zeroExtend(offset);
				    workVector8Next[tempIndex] = readdata8[ii];
				 end
			      Vector#(4,Bit#(15)) tempResult15 = replicate(0);
			      for(Integer ii=0; ii<4; ii=ii+1)
				 begin
				    tempResult15[ii] = interpolate8to15(workVector8Next[ii],workVector8Next[ii+1],workVector8Next[ii+2],workVector8Next[ii+3],workVector8Next[ii+4],workVector8Next[ii+5]);
				    tempResult8[ii] = clip1y10to8(truncate((tempResult15[ii]+16)>>5));
				 end
			      Bit#(2) verOffset;
			      Vector#(4,Bit#(15)) verResult15 = replicate(0);
			      if(xfracl == 1)
				 verOffset = reqdata.offset;
			      else
				 verOffset = reqdata.offset+1;
			      readdata = workFile.sub({workVerNum[2:0],(workHorNum-2+(verOffset==0?0:1))});
			      for(Integer ii=0; ii<4; ii=ii+1)
				 begin
				    Bit#(2) offsetplusii = verOffset+fromInteger(ii);
				    if(verOffset <= 3-fromInteger(ii) && verOffset!=0)
				       verResult15[ii] = workVector15[offsetplusii];
				    else
				       verResult15[ii] = readdata[offsetplusii];
				    workVector15Next[ii] = readdata[ii];
				 end
			      for(Integer ii=0; ii<4; ii=ii+1)
				 begin
				    Bit#(9) tempVal = zeroExtend(clip1y10to8(truncate((verResult15[ii]+16)>>5)));
				    tempResult8[ii] = truncate((tempVal+zeroExtend(tempResult8[ii])+1)>>1);
				 end
			   end
		     end
		  if(workHorNum >= 2)
		     begin
			Bit#(1) horAddr = truncate(workHorNum-2);
			Bit#(3) verAddr = truncate(workVerNum);
			horAddr = horAddr + ((blockT==IP4x8&&workSubMbPart==1)||(blockT==IP4x4&&workSubMbPart[0]==1) ? 1 : 0);
			verAddr = verAddr + ((blockT==IP8x4&&workSubMbPart==1)||(blockT==IP4x4&&workSubMbPart[1]==1) ? 4 : 0);
			resultFile.upd({verAddr,horAddr},tempResult8);
			if(verAddr[1:0] == 3)
			   resultReadyNext[{verAddr[2],horAddr}] = 1;
			//$display( "Trace interpolator: workLuma stage 1 result %h %h %h %h %h %h %h %h", workHorNum, workVerNum, {verAddr,horAddr}, tempResult8[3], tempResult8[2], tempResult8[1], tempResult8[0], pack(resultReadyNext));
		     end
		  Bit#(2) workHorNumMax = (blockT==IP8x8||blockT==IP8x4 ? 1 : 0) + 2;
		  Bit#(4) workVerNumMax = (blockT==IP8x8||blockT==IP4x8 ? 7 : 3);
		  if(workHorNum < workHorNumMax)
		     workHorNum <= workHorNum+1;
		  else
		     begin
			workHorNum <= 0;
			if(workVerNum < workVerNumMax)
			   workVerNum <= workVerNum+1;
			else
			   begin
			      workVerNum <= 0;
			      workStage <= 0;
			      if(((blockT==IP4x8 || blockT==IP8x4) && workSubMbPart==0) || (blockT==IP4x4 && workSubMbPart<3))
				 workSubMbPart <= workSubMbPart+1;
			      else
				 begin
				    workSubMbPart <= 0;
				    workDone <= True;
				 end
			      reqfifoWork.deq();
			   end
		     end
	       end
	 end
      workVector8 <= workVector8Next;
      workVector15 <= workVector15Next;
      resultReady <= resultReadyNext;
      //$display( "Trace interpolator: workLuma %h %h %h %h %h %h", xfracl, yfracl, workHorNum, workVerNum, offset, workStage);
   endrule

   
   rule workChroma ( reqfifoWork.first() matches tagged IPWChroma .reqdata &&& !workDone );
      Bit#(4) xfracc = zeroExtend(reqdata.xFracC);
      Bit#(4) yfracc = zeroExtend(reqdata.yFracC);
      let offset = reqdata.offset;
      let blockT = reqdata.bt;
      Vector#(20,Bit#(8)) workVector8Next = workVector8;
      Vector#(4,Bit#(1)) resultReadyNext = resultReady;
      if(memRespQ.first() matches tagged IPLoadResp .tempreaddata)
	 begin
	    memRespQ.deq();
	    Vector#(4,Bit#(8)) readdata = replicate(0);
	    readdata[0] = tempreaddata[7:0];
	    readdata[1] = tempreaddata[15:8];
	    readdata[2] = tempreaddata[23:16];
	    readdata[3] = tempreaddata[31:24];
	    Vector#(5,Bit#(8)) tempWork8 = replicate(0);
	    Vector#(5,Bit#(8)) tempPrev8 = replicate(0);
	    Vector#(4,Bit#(8)) tempResult8 = replicate(0);
	    Bool resultReadyFlag = False;
	    for(Integer ii=0; ii<4; ii=ii+1)
	       begin
		  Bit#(2) offsetplusii = offset+fromInteger(ii);
		  if(offset <= 3-fromInteger(ii) && !((blockT==IP4x8||blockT==IP4x4)&&(offset[1]==0||(xfracc==0&&offset!=3))) && !(xfracc==0&&offset==0))
		     tempWork8[ii] = workVector8[offsetplusii];
		  else
		     tempWork8[ii] = readdata[offsetplusii];
		  workVector8Next[ii] = readdata[ii];
	       end
	    tempWork8[4] = readdata[offset];
	    if((blockT==IP16x8 || blockT==IP16x16) && workHorNum==(xfracc==0&&offset==0 ? 1 : 2))
	       begin
		  for(Integer ii=0; ii<5; ii=ii+1)
		     begin
			tempPrev8[ii] = workVector8[ii+9];
			workVector8Next[ii+9] = tempWork8[ii];
		     end
	       end
	    else
	       begin
		  for(Integer ii=0; ii<5; ii=ii+1)
		     tempPrev8[ii] = workVector8[ii+4];
		  if(workHorNum==(xfracc==0&&offset==0 ? 0 : 1) || ((blockT==IP4x8||blockT==IP4x4)&&(offset[1]==0||(xfracc==0&&offset!=3))))
		     begin
			for(Integer ii=0; ii<5; ii=ii+1)
			   workVector8Next[ii+4] = tempWork8[ii];
		     end
	       end
	    if(yfracc==0)
	       begin
		  for(Integer ii=0; ii<5; ii=ii+1)
		     tempPrev8[ii] = tempWork8[ii];
	       end
	    for(Integer ii=0; ii<4; ii=ii+1)
	       begin
		  Bit#(14) tempVal = zeroExtend((8-xfracc))*zeroExtend((8-yfracc))*zeroExtend(tempPrev8[ii]);
		  tempVal = tempVal + zeroExtend(xfracc)*zeroExtend((8-yfracc))*zeroExtend(tempPrev8[ii+1]);
		  tempVal = tempVal + zeroExtend((8-xfracc))*zeroExtend(yfracc)*zeroExtend(tempWork8[ii]);
		  tempVal = tempVal + zeroExtend(xfracc)*zeroExtend(yfracc)*zeroExtend(tempWork8[ii+1]);
		  tempResult8[ii] = truncate((tempVal+32)>>6);
	       end
	    if(workVerNum > 0 || yfracc==0)
	       begin
		  if(blockT==IP4x8 || blockT==IP4x4)
		     begin
			Bit#(5) tempIndex = 10 + zeroExtend(workVerNum<<1);
			workVector8Next[tempIndex] = tempResult8[0];
			workVector8Next[tempIndex+1] = tempResult8[1];
			tempResult8[2] = tempResult8[0];
			tempResult8[3] = tempResult8[1];
			tempResult8[0] = workVector8[tempIndex];
			tempResult8[1] = workVector8[tempIndex+1];
			if((workHorNum>0 || offset[1]==0) && workSubMbPart[0]==1)
			   resultReadyFlag = True;
		     end
		  else
		     begin
			if(workHorNum>0 || (xfracc==0 && offset==0))
			   resultReadyFlag = True;
		     end
	       end
	    if(resultReadyFlag)
	       begin
		  Bit#(1) horAddr = ((blockT==IP4x8 || blockT==IP4x4) ? 0 : truncate(((xfracc==0 && offset==0) ? workHorNum : workHorNum-1)));
		  Bit#(3) verAddr = truncate((yfracc==0 ? workVerNum : workVerNum-1));
		  horAddr = horAddr + ((blockT==IP16x8||blockT==IP16x16) ? 0 : workMbPart[0]);
		  verAddr = verAddr + ((blockT==IP8x16||blockT==IP16x16) ? 0 : ((blockT==IP16x8) ? {workMbPart[0],2'b00} : {workMbPart[1],2'b00}));
		  verAddr = verAddr + ((blockT==IP8x4&&workSubMbPart==1)||(blockT==IP4x4&&workSubMbPart[1]==1) ? 2 : 0);
		  resultFile.upd({verAddr,horAddr},tempResult8);
		  if(verAddr[1:0] == 3)
		     resultReadyNext[{verAddr[2],horAddr}] = 1;
	       end
	    Bit#(2) workHorNumMax = (blockT==IP4x8||blockT==IP4x4 ? (offset[1]==0||(xfracc==0&&offset!=3) ? 0 : 1) : ((blockT==IP16x16||blockT==IP16x8 ? 1 : 0) + (xfracc==0&&offset==0 ? 0 : 1)));
	    Bit#(4) workVerNumMax = (blockT==IP16x16||blockT==IP8x16 ? 7 : (blockT==IP16x8||blockT==IP8x8||blockT==IP4x8 ? 3 : 1)) + (yfracc==0 ? 0 : 1);
	    if(workHorNum < workHorNumMax)
	       workHorNum <= workHorNum+1;
	    else
	       begin
		  workHorNum <= 0;
		  if(workVerNum < workVerNumMax)
		     workVerNum <= workVerNum+1;
		  else
		     begin
			workVerNum <= 0;
			if(((blockT==IP4x8 || blockT==IP8x4) && workSubMbPart==0) || (blockT==IP4x4 && workSubMbPart<3))
			   workSubMbPart <= workSubMbPart+1;
			else
			   begin
			      workSubMbPart <= 0;
			      if(((blockT==IP16x8 || blockT==IP8x16) && workMbPart==0) || (!(blockT==IP16x8 || blockT==IP8x16 || blockT==IP16x16) && workMbPart<3))
				 workMbPart <= workMbPart+1;
			      else
				 begin
				    workMbPart <= 0;
				    workDone <= True;
				 end
			   end
			reqfifoWork.deq();
		     end
	       end
	 end
      workVector8 <= workVector8Next;
      resultReady <= resultReadyNext;
      //$display( "Trace interpolator: workChroma %h %h %h %h %h", xfracc, yfracc, workHorNum, workVerNum, offset);
   endrule


   rule outputing( !outDone && resultReady[outBlockNum]==1 );
      outfifo.enq(resultFile.sub({outBlockNum[1],outPixelNum,outBlockNum[0]}));
      outPixelNum <= outPixelNum+1;
      if(outPixelNum == 3)
	 begin
	    outBlockNum <= outBlockNum+1;
	    if(outBlockNum == 3)
	       outDone <= True;
	 end
      //$display( "Trace interpolator: outputing %h %h %h %h %h %h", outBlockNum, outPixelNum, tempVector[3], tempVector[2], tempVector[1], tempVector[0]);
   endrule


   rule switching( outDone && workDone );
      outDone <= False;
      workDone <= False;
      resultReady <= replicate(0);
      //$display( "Trace interpolator: switching %h %h", outBlockNum, outPixelNum);
   endrule
   

   method Action   setPicWidth( Bit#(PicWidthSz) newPicWidth );
      picWidth <= newPicWidth;
   endmethod
   
   method Action   setPicHeight( Bit#(PicHeightSz) newPicHeight );
      picHeight <= newPicHeight;
   endmethod
   
   method Action request( InterpolatorIT inputdata );
      reqfifoLoad.enq(inputdata);
      if(inputdata matches tagged IPLuma .indata)
	 reqfifoWork.enq(IPWLuma {xFracL:indata.mvhor[1:0],yFracL:indata.mvver[1:0],offset:indata.mvhor[3:2],bt:indata.bt});
      else if(inputdata matches tagged IPChroma .indata)
	 reqfifoWork.enq(IPWChroma {xFracC:indata.mvhor[2:0],yFracC:indata.mvver[2:0],offset:indata.mvhor[4:3]+{indata.hor[0],1'b0},bt:indata.bt});
   endmethod

   method Vector#(4,Bit#(8)) first();
      return outfifo.first();
   endmethod
   
   method Action deq();
      outfifo.deq();
   endmethod
   
   method Action endOfFrame();
      endOfFrameFlag <= True;
   endmethod
   
   interface Client mem_client;
      interface Get request  = fifoToGet(memReqQ);
      interface Put response = fifoToPut(memRespQ);
   endinterface


endmodule


endpackage
