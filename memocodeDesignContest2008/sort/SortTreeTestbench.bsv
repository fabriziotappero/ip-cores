// import standard librarys
import Connectable::*;
import GetPut::*;
import FIFO::*;
import StmtFSM::*;
import Vector::*;

// import self-made library
import BRAMVLevelFIFO::*;
import VLevelFIFO::*;
import Sort::*;
import LFSR::*;
import Memocode08Types::*;
import SortTree16::*;
import SortTree64::*;


typedef 16 KMerges;

typedef enum{
  Uninitialized,
  Burst,
  Idle,
  FIFOStage,
  FIFOIdle,
  Done
} State deriving (Bits,Eq);

module mkSortTreeTestbench(Empty);

   Vector#(KMerges,FIFO#(Record)) resultFIFOs <- replicateM(mkSizedFIFO(valueof(KMerges)+1)); 

//  SortTree#(KMerges,1,Bit#(7),Bit#(1),Maybe#(Bit#(128))) sortTree <- mkBRAMSort16; 
   let sortTree <- mkSortTree16; 
 
   Reg#(Bit#(TLog#(KMerges))) slabCount <- mkReg(0); 
   
   Reg#(Bit#(TMul#(2,TLog#(KMerges)))) finalCount <- mkReg(0);  
   
   Reg#(State) stateMeta <- mkReg(Burst);
   
   Reg#(Bit#(128)) lastValue <- mkReg(0);
   
   Reg#(Bit#(64)) cycleCnt <- mkReg(0);

   Reg#(Bit#(TLog#(TAdd#(KMerges,1)))) recvCount <- mkReg(0);

   Reg#(Bit#(TLog#(TAdd#(KMerges,1)))) sendCount <- mkReg(0);

   Reg#(Bit#(8)) nextValue <- mkReg(0);
   
   rule incrCycle (True);
      cycleCnt <= cycleCnt + 1;
      
      $display("cycle %d",cycleCnt);
   endrule
   
   rule getTokInfo (True);
      let tokInfo = sortTree.inStream.getTokInfo();
      
      for (Integer i = 0; i < valueOf(KMerges); i = i + 1)
         $display("Instream Tok Info idx %d tok %d",i,tokInfo[i]);
      
   endrule

  for(Integer i = 0; i < valueof(KMerges); i = i + 1) 
    begin 
      Reg#(Bool) initialized <- mkReg(False); 
      Reg#(Bit#(TLog#(KMerges))) count <- mkReg(0);       
      Reg#(State) state <- mkReg(Burst); 

      rule push ((state == Burst) && ((sortTree.inStream.getTokInfo())[i] > 1));
        $display("Sender %d is Bursting", i);
        sortTree.inStream.putDeqTok(fromInteger(i),2);
        sortTree.inStream.putRecord(fromInteger(i),
                                    tagged Valid (zeroExtend(nextValue)));
        nextValue <= nextValue + 101; // 101 is rel. prime to 256, and so will generate the U256 group
        state <= Idle;
      endrule

//      rule endpush ((state == Idle) && ((sortTree.inStream.getTokInfo())[i] > 0));
      rule endpush (state == Idle);
        $display("Sender %d is Idling", i);
        sortTree.inStream.putRecord(fromInteger(i), tagged Invalid);
        count <= count + 1;
        if(count + 1 == 0)
          begin
             state <= FIFOStage;
             sendCount <= sendCount + 1;
          end 
        else
          begin
            state <= Burst;
          end            
      endrule

      rule fifopush ((sendCount == 16) && (state == FIFOStage) && ((sortTree.inStream.getTokInfo())[i] > 0));
        $display("Sender %d is FIFOStage",i);
        sortTree.inStream.putDeqTok(fromInteger(i),1);
        resultFIFOs[i].deq;
        sortTree.inStream.putRecord(fromInteger(i), tagged Valid resultFIFOs[i].first);
        count <= count + 1;
        if(count + 1 == 0)
          begin
             state <= FIFOIdle;
          end 
        else
          begin
            state <= FIFOStage;
          end 
      endrule

      rule endfifo ((state == FIFOIdle)&& ((sortTree.inStream.getTokInfo())[i] > 0));
        $display("Sender %d is FIFOIdle",i);
        sortTree.inStream.putDeqTok(fromInteger(i),1);
        sortTree.inStream.putRecord(fromInteger(i), tagged Invalid);
        state <= Done;
      endrule      
    end
 

  rule readOutResults(stateMeta == Burst);
    let outdata <- sortTree.getRecord();    
    if(outdata matches tagged Valid .data)
      begin
         $display("Getting a slab result %d, recv count %d",data,recvCount);
         resultFIFOs[slabCount].enq(data);
         recvCount <= recvCount + 1;
         if(lastValue > data)
            begin
               $display("%m Error: %d > %d at %d", lastValue, data, finalCount);
               $finish();
            end
         lastValue <= data;
      end
    else
      begin 
        $display("Getting a end of stream token %d",recvCount);
         slabCount <= slabCount + 1;
         lastValue <= 0;
         recvCount <= 0;
         if (recvCount != fromInteger(valueOf(KMerges)))
            begin
               $display("error merge recv token too early %d", recvCount);
               $finish();
            end
         
         if(slabCount + 1 == 0)
            begin
               stateMeta <= FIFOStage;
            end
      end
  endrule

 
  rule readOutResultsFinal(stateMeta == FIFOStage);   
    $display("%m Getting a result");
    let outdata <- sortTree.getRecord();    
    if(outdata matches tagged Valid .data)
      begin
        finalCount <= finalCount + 1;
        if(zeroExtend(finalCount) != data)
          begin
             $display("%m Error: %d != %d at %d", finalCount, data, finalCount);
             $finish();
          end
        if(lastValue > data)
          begin
             $display("%m Error: %d > %d at %d", lastValue, data, finalCount);
             $finish();
          end
        lastValue <= data;
      end
    else
      begin
        if(finalCount != 0)
          begin
             $display("%m Error: final Value: %d", finalCount);
             $finish();
          end
        else
          begin 
            let timeVal <- $time();
            $display("%m PASSES at %d cycle %d", timeVal,cycleCnt); 
            $finish(); 
          end
      end
  endrule


endmodule