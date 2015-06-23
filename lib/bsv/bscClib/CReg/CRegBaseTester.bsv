import CReg::*;


module mkCRegBaseTester ();

  Reg#(int) counter <- mkReg(0);
  Reg#(int) validRegA <- mkReg(10);
  Reg#(Bit#(5)) validRegB <- mkReg(2);
  Reg#(int) testRegA <- mkCReg(10,"testRegA");
  Reg#(Bit#(5)) testRegB <- mkCReg(2,"testRegB");

  rule count;
    counter <= counter + 1;
    if(counter == 100000000)
      begin
        $display("PASS");
        $finish;
      end
  endrule

  rule checkA;
   if(testRegA != validRegA)
     begin
       $display("Reg A mismatch %d : %h vs. %h", counter, testRegA, validRegA);
       $finish;
     end
  endrule

  rule checkB;
   if(testRegB != validRegB)
     begin
       $display("Reg B mismatch %d : %h vs. %h", counter, testRegB, validRegB);
       $finish;
     end
  endrule

  rule upValidA(counter % 3 == 0);
    validRegA <= validRegA + counter;  
  endrule

  rule upTestA(counter % 3 == 0);
    testRegA <= testRegA + counter;  
  endrule
  
  rule upValidB(counter % 2 == 0);
    validRegB <= validRegB + truncate(pack(counter));  
  endrule

  rule upTestB(counter % 2 == 0);
    testRegB <= testRegB + truncate(pack(counter));  
  endrule


endmodule