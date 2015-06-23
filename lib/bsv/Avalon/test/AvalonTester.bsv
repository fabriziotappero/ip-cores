import AvalonSlave::*;
import AvalonRegisterFile::*;
import StmtFSM::*;



module mkAvalonTester (Empty);
  AvalonSlaveWires#(4,32) regs <- mkSmallAvalonRegisterFile;

  Reg#(Bit#(4)) addr <- mkReg(0); 
  Reg#(Bit#(32)) data <- mkReg(0);
  Reg#(Bit#(32)) expected <- mkReg(0);
  Reg#(Bit#(32)) received <- mkReg(0);
  Reg#(Bit#(1)) read <- mkReg(0);
  Reg#(Bit#(1)) write <- mkReg(0);

  Stmt s = seq
             for(data <= 0; data < 2048; data<=data+1)
               seq                
                 action
                   $display("Testbench issues write");
                   await(regs.waitrequest==0);
                   write <= 1;
                   expected <= data;
                 endaction
                 write <= 0;
                 action
                   $display("Testbench issues read");
                   await(regs.waitrequest==0);                   
                   read <= 1;
                 endaction
                 while(regs.readdatavalid==0)                   
                   action
                     $display("Testbench awaits read resp");
                     read <= 0;                   
                     received <= regs.readdata; 
                   endaction
                 action
                   read <= 0;                   
                   received <= regs.readdata; 
                 endaction
                 if(received != expected)
                   seq
                     $display("Expected: %d, Received: %d", received, expected);
                     $finish;
                   endseq
                 else
                   seq
                     $display("Expected: %d @ %d, Received: %d", received, addr, expected);
                   endseq
                 addr <= addr + 7;                  
               endseq
             $display("PASS");
             $finish; 
           endseq;

  FSM fsm <- mkFSM(s);

  rule drivePins;
    regs.read(read);
    regs.write(write);   
    regs.address(addr);
    regs.writedata(data);
  endrule   
 
 
  rule startFSM;
    fsm.start;
  endrule

endmodule


