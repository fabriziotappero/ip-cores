//import Transfer::*;
import Vector::*;
import aesCipherTop::*;

typedef Bit#(128) AES_block;
typedef Bit#(128) AES_key;



import "BVI" aes_cipher_top =  
module mkAESPipeline (AES);
   
   default_clock clk(clk);
   default_reset rst(rst);
   
   method text_out get_result() ready(done);
   method decrypt(text_in, key) ready(ready) enable(ld);
   
   schedule decrypt    CF (get_result);
   schedule get_result CF (decrypt);
      
   schedule decrypt    C decrypt;
   schedule get_result C get_result;

endmodule

/*interface AesTest;
    interface ProcSide procSide;
endinterface

module mkaestest(AesTest);
    Transfer transfer <- mkTransfer();

    AES crypto <- mkAESPipeline();

    Reg#(Bit#(4)) index <- mkReg(0);
    Reg#(Bit#(4)) count <- mkReg(0);
    Reg#(Bit#(6)) trans <- mkReg(0);
    Vector#(8,Reg#(AES_block)) storage <- replicateM(mkReg(0));

    AES_key key = {8'hB0, 8'h1D, 8'hFA, 8'hCE, 8'h0D, 8'hEC, 8'h0D, 8'hED, 
                   8'h0B, 8'hA1, 8'h1A, 8'hDE, 8'h0E, 8'hFF, 8'hEC, 8'h70};

    rule mkreq(index<8);
        crypto.decrypt({28'b0,index,96'b0},key);
        index <= index+1;
    endrule

    rule store(True);
        storage[count[2:0]] <= crypto.get_result();
        count <= count+1;
    endrule

    rule trans0((count>0 && trans==0) || trans==4 || trans==8 || trans==12 || trans==16 || trans==20 || trans==24 || trans==28);
        transfer.put(storage[trans[4:2]][31:0]);
        trans <= trans+1;
    endrule

    rule trans1(trans==1 || trans==5 || trans==9 || trans==13 || trans==17 || trans==21 || trans==25 || trans==29);
        transfer.put(storage[trans[4:2]][63:32]);
        trans <= trans+1;
    endrule

    rule trans2(trans==2 || trans==6 || trans==10 || trans==14 || trans==18 || trans==22 || trans==26 || trans==30);
        transfer.put(storage[trans[4:2]][95:64]);
        trans <= trans+1;
    endrule

    rule trans3(trans==3 || trans==7 || trans==11 || trans==15 || trans==19 || trans==23 || trans==27 || trans==31);
        transfer.put(storage[trans[4:2]][127:96]);
        trans <= trans+1;
    endrule

    interface ProcSide procSide = transfer.procSide;

    rule disp(count==8);
        $display("%x",storage[0]);
        $display("%x",storage[1]);
        $display("%x",storage[2]);
        $display("%x",storage[3]);
        $display("%x",storage[4]);
        $display("%x",storage[5]);
        $display("%x",storage[6]);
        $display("%x",storage[7]);
    endrule

endmodule
*/