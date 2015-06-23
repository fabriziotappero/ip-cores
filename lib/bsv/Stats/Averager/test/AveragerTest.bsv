import Averager::*;


module mkAveragerTest ();

  Averager#(Bit#(32)) average2048 <- mkAverager(2048);
  Averager#(Bit#(32)) average64 <- mkAverager(64);

  Reg#(Bit#(6)) count64 <- mkReg(0);
  Reg#(Bit#(11)) count2048 <- mkReg(0);
  Reg#(Bit#(12)) countDown <- mkReg(~0);  
  Reg#(Bit#(16)) countDownFinal <- mkReg(~0);  

  rule putInput;
    if(countDown != 0)
      begin
        countDown <= countDown - 1;
      end
    count64 <= count64 + 1;
    count2048 <= count2048 + 1;
    average64.inputSample(zeroExtend(count64));
    average2048.inputSample(zeroExtend(count2048));
  endrule

  rule check(countDown == 0);
    if((average64.average != 32'h1f) ||
       (average2048.average != 32'h3ff))
     begin
       $display("FAIL: %h %h", average64.average, average2048.average);
       $finish;
     end
    else if(countDownFinal == 0)
     begin
       $display("PASS");
       $finish;
     end
     
    countDownFinal <= countDownFinal - 1;
  endrule

endmodule

