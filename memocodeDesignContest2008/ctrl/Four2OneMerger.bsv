import Memocode08Types ::*;
import StmtFSM         ::*;
import GetPut          ::*;
import Vector          ::*;
import FIFO            ::*;

interface Four2One;
   interface Vector#(4, Put#(Bit#(RecordWidth))) in;
   interface Get#(Bit#(RecordWidth)) out;
endinterface


`define Debug421 False

module mkFour2One (Four2One);
   
   Vector#(4, FIFO#(Bit#(RecordWidth))) top_fifos <- replicateM(mkFIFO());
   Vector#(2, FIFO#(Bit#(RecordWidth))) mid_fifos <- replicateM(mkFIFO());

   Vector#(2, Reg#(Bit#(2))) l1_cnts <- replicateM(mkReg(~0));
   Vector#(2, Reg#(Bit#(2))) l2_cnts <- replicateM(mkReg(2));   
   
   for(Bit#(2) i = 0; i < 2; i = i+1)
      rule l1_cmp (True);
	 
	 let b0 = (l1_cnts[i])[0:0]==1'b1;
	 let b1 = (l1_cnts[i])[1:1]==1'b1;
	 
	 let in0 = top_fifos[(2*i)+0];
	 let in1 = top_fifos[(2*i)+1];
	 let out = mid_fifos[i];
	 
	 let nv = ~0;
	 
	 if(b0&&!b1)
	    begin
	       in0.deq();
	       out.enq(in0.first());
	       if(`Debug421) $display("%d l1_zero", i);
	    end
	 else if(!b0&&b1)
	    begin
	       in1.deq();
	       out.enq(in1.first());
	       if(`Debug421) $display("%d l1_one", i);
	    end
	 else
	    begin
	       if (in0.first > in1.first())
		  begin
		     in0.deq();
		     out.enq(in0.first());
		     nv = 2;
		     if(`Debug421) $display("%d l1_zero (cmp)", i);
		  end
	       else
		  begin
		     in1.deq();
		     out.enq(in1.first());
		     nv = 1;
		     if(`Debug421) $display("%d l1_one (cmp)", i);
		  end
	    end
	
	 l1_cnts[i] <= nv;
	 if(`Debug421) $display("%d l1_cmp nv: %x", i, nv);
	 
      endrule


   interface in = map(fifoToPut, top_fifos);
   interface Get out;
      method ActionValue#(Bit#(RecordWidth)) get();

	 let b0 = (l2_cnts[0]) != 0;
	 let b1 = (l2_cnts[1]) != 0;
	 
	 let in0 = mid_fifos[0];
	 let in1 = mid_fifos[1];

	 let sum = l2_cnts[0] + l2_cnts[1];
	
	 let rv = in1;

	 let nv0 = l2_cnts[0];
	 let nv1 = l2_cnts[1];
	 
 
	 if(b0&&!b1)
	    begin
	       in0.deq();
	       if(sum != 1)
		  nv0 = nv0-1;
	       else
		  begin
		     nv0 = 2;
		     nv1 = 2;
		  end
	       rv = in0;
	       if(`Debug421) $display("l2_zero");
	    end
	 else if(!b0&&b1)
	    begin
	       in1.deq();
	       if(sum != 1)
		  nv1 = nv1-1;
	       else
		  begin
		     nv0 = 2;
		     nv1 = 2;
		  end
	       rv = in1;
	       if(`Debug421) $display("l2_one");
	    end
	 else
	    begin
	       if (in0.first > in1.first())
		  begin
		     in0.deq();
		     nv0 = nv0-1;
		     rv = in0;
		     if(`Debug421) $display("l2_zero (cmp)");
		  end
	       else
		  begin
		     in1.deq();
		     nv1 = nv1-1;
		     rv = in1;
		     if(`Debug421) $display("l2_one (cmp)");
		  end
	    end
	 if(`Debug421) $display("l2_cmp, nv0: %d, nv1: %d, sum: %d", 
				nv0, nv1, sum);
	 l2_cnts[0] <= nv0;
	 l2_cnts[1] <= nv1;
	 return rv.first();
      endmethod
   endinterface
   
endmodule
