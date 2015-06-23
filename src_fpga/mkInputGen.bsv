
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
// Input Generator implementation
//----------------------------------------------------------------------
//
//

package mkInputGen;

import H264Types::*;
import IInputGen::*;
import RegFile::*;
import FIFO::*;
import IEDKBRAM::*;

import Connectable::*;
import GetPut::*;
//import BypassReg::*;


// Control reg 0 -> bit zero is the flag, bits 4-7 are top bits of the data amount
// Control reg 

`define INPUT_BUFFER_LOG_SIZE 13

typedef enum
{
   READING = 0,
   WAITING_FOR_DATA = 1,
   WAITING_FOR_DATA_BUBBLE = 2,
   OBTAINING_LENGTH = 3,
   OBTAINING_LENGTH_BUBBLE = 4,
   ALTERNATING_BLOCK = 5,
   LAST_BLOCK = 6,
   BLOCK_SWITCH_BUBBLE =7
}
   InputState
            deriving (Eq, Bits);

(* synthesize *)
module mkInputGen( IInputGen );

   Reg#(Bit#(TSub#(`INPUT_BUFFER_LOG_SIZE, 1))) addr <- mkReg(0);
   Reg#(Bit#(TSub#(`INPUT_BUFFER_LOG_SIZE, 1))) addr_last <- mkReg(0);
   Reg#(Bit#(TSub#(`INPUT_BUFFER_LOG_SIZE, 1))) addr_last_last <- mkReg(0);
   Reg#(Bit#(TSub#(`INPUT_BUFFER_LOG_SIZE, 2))) data_counter <- mkReg(0); 
   Reg#(Bit#(1)) target_buffer <- mkReg(0);
   Reg#(InputState) state <- mkReg(WAITING_FOR_DATA);   
   Reg#(Bit#(32)) data_in <- mkReg(0);
   Reg#(Bit#(16)) counter <- mkReg(0);   
   Reg#(Bit#(8))  last_byte <- mkReg(0);
 
   FIFO#(InputGenOT) outfifo <- mkFIFO;

   interface Get ioout = fifoToGet(outfifo);

   interface IEDKBRAM bram_interface;
     method Action data_input(Bit#(32) data);
       data_in <= data;
       addr_last <= addr;
       addr_last_last <= addr_last;
       case (state)
         WAITING_FOR_DATA:
           begin
             if(data_in[7:0] == 0) 
               begin
                 addr <= ~0;
               end
             else
               begin
                 addr <= ~0;  
                 state <= WAITING_FOR_DATA_BUBBLE;  
               end
           end
         WAITING_FOR_DATA_BUBBLE:
           begin
             if(data_in[7:0] == 0)
               begin
                 addr <= ~0;   
                 state <= WAITING_FOR_DATA; 
               end
             else
               begin
                 addr <= ~0;   
                 state <= OBTAINING_LENGTH; 
               end
           end
        OBTAINING_LENGTH: 
          begin
            if(data_in[23:8] == 0)
              begin
                addr <= ~0;  
                state <= LAST_BLOCK;
              end
            else 
              begin
                addr <= 0;
                Bit#(TSub#(`INPUT_BUFFER_LOG_SIZE, 2)) counter_value = truncate(data_in >> 8);
                data_counter <= counter_value;
                state <= OBTAINING_LENGTH_BUBBLE;
              end
         end 
        OBTAINING_LENGTH_BUBBLE: 
          begin
            state <= READING;
            addr <= addr + 1;         
          end
        READING:
          begin 

            if(data_counter > 0)
              begin
                if(addr_last[1:0] == 0)
                  begin
                   last_byte <= data[7:0];
                  end 
                Bit#(8) data_byte = case (addr_last[1:0])
                  2'b11: last_byte;
                  2'b10: data[15:8];
                  2'b01: data[23:16];
                  2'b00: data[31:24];
                endcase;
                counter <= counter + 1;
                outfifo.enq(DataByte (data_byte));
                data_counter <= data_counter - 1;
                addr <= addr + 1;
              end
            else
              begin
                // Check to see if we read less than the full buffer's worth of data.
                if(addr < (1<<(`INPUT_BUFFER_LOG_SIZE-3)))
                  begin 
                    //We read too little data, so we're done.
                    addr <=  ~0;
                    state <= LAST_BLOCK;
                  end
                else 
                  begin
                    addr <= ~0;
                    state <= ALTERNATING_BLOCK;
                  end
             end
          end
        LAST_BLOCK:
          begin      
            target_buffer <= 0;
            addr <= ~0;     
            state <= BLOCK_SWITCH_BUBBLE;
            outfifo.enq(EndOfFile);
          end

        ALTERNATING_BLOCK:
          begin     
            target_buffer <= (target_buffer == 0)? 1 : 0;
            addr <= ~0;     
            state <= BLOCK_SWITCH_BUBBLE;
          end
   
        BLOCK_SWITCH_BUBBLE:
          begin
            state <= WAITING_FOR_DATA;
          end
       endcase
     endmethod
   
     method wen_output();
       return ((state == LAST_BLOCK) || (state == ALTERNATING_BLOCK)) ? ~0 : 0;
     endmethod

     method Bit#(32) addr_output();
       return zeroExtend({target_buffer, addr});
     endmethod

     method Bit#(32) data_output();
       return 0;
     endmethod
  endinterface
endmodule


endpackage
