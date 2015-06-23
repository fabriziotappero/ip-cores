/*
 * Copyright 2012, Homer Hsing <homer.hsing@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/* FSM: finite state machine 
 * halt if $ctrl == 0$
 */
module FSM(clk, reset, rom_addr, rom_q, ram_a_addr, ram_b_addr, ram_b_w, pe, done);
    input clk;
    input reset;
    output reg [8:0] rom_addr; /* command id. extra bits? */
    input [27:0] rom_q; /* command value */
    output reg [5:0] ram_a_addr;
    output reg [5:0] ram_b_addr;
    output ram_b_w;
    output reg [10:0] pe;
    output reg done;
    
    reg [5:0] state;
    parameter START=0, READ_SRC1=1, READ_SRC2=2, CALC=4, WAIT=8, WRITE=16, DON=32;
	
    wire [5:0] dest, src1, src2; wire [7:0] times; wire [1:0] op;
    assign {dest, src1, op, times, src2} = rom_q;

    reg [7:0] count;
	
    always @ (posedge clk)
       if (reset) 
          state<=START; 
       else 
          case (state)
             START:
                state<=READ_SRC1;
             READ_SRC1:
                state<=READ_SRC2;
             READ_SRC2:
                if (times==0) state<=DON; else state<=CALC;
             CALC:
                if (count==1) state<=WAIT;
             WAIT:
                state<=WRITE;
             WRITE:
                state<=READ_SRC1;
          endcase

    /* we support two loops */
    parameter  LOOP1_START = 9'd21,
               LOOP1_END   = 9'd116,
               LOOP2_START = 9'd290,
               LOOP2_END   = 9'd303;
    reg [249:0] loop1, loop2;
	
	always @ (posedge clk)
	   if (reset) rom_addr<=0;
	   else if (state==WAIT)
          begin
             if(rom_addr == LOOP1_END && loop1[0])
                rom_addr <= LOOP1_START;
             else if(rom_addr == LOOP2_END && loop2[0])
                rom_addr <= LOOP2_START;
             else
                rom_addr <= rom_addr + 1'd1; 
	      end
	
	always @ (posedge clk)
	   if (reset) loop1 <= ~0;
	   else if(state==WAIT && rom_addr==LOOP1_END)
          loop1 <= loop1 >> 1;
	
	always @ (posedge clk)
	   if (reset) loop2 <= ~0;
	   else if(state==WAIT && rom_addr==LOOP2_END)
          loop2 <= loop2 >> 1;

	always @ (posedge clk)
	   if (reset)
          count <= 0;
	   else if (state==READ_SRC1)
          count <= times;
	   else if (state==CALC)
          count <= count - 1'd1;
	
	always @ (posedge clk)
	   if (reset) done<=0;
	   else if (state==DON) done<=1;
	   else done<=0;
	 
    always @ (state, src1, src2)
       case (state)
       READ_SRC1: ram_a_addr=src1;
       READ_SRC2: ram_a_addr=src2;
       default: ram_a_addr=0;
       endcase
    
    parameter CMD_ADD=6'd4, CMD_SUB=6'd8, CMD_CUBIC=6'd16,
              ADD=2'd0, SUB=2'd1, CUBIC=2'd2, MULT=2'd3;

    always @ (posedge clk)
       case (state)
       READ_SRC1:
          case (op)
          ADD:   pe<=11'b11001000000;
          SUB:   pe<=11'b11001000000;
          CUBIC: pe<=11'b11111000000;
          MULT:  pe<=11'b11110000000;
          default: pe<=0;
          endcase
       READ_SRC2:
          case (op)
          ADD:   pe<=11'b00110000000;
          SUB:   pe<=11'b00110000000;
          CUBIC: pe<=0;
          MULT:  pe<=11'b00001000000;
          default: pe<=0;
          endcase
       CALC:
          case (op)
          ADD:   pe<=11'b00000010001;
          SUB:   pe<=11'b00000010001;
          CUBIC: pe<=11'b01010000001;
          MULT:  pe<=11'b00000111111;
          default: pe<=0;
          endcase
       default: 
          pe<=0;
       endcase

    always @ (state, op, src2, dest)
       case (state)
       READ_SRC1: 
          case (op)
          ADD: ram_b_addr=CMD_ADD;
          SUB: ram_b_addr=CMD_SUB;
          CUBIC: ram_b_addr=CMD_CUBIC;
          default: ram_b_addr=0;
          endcase
       READ_SRC2: ram_b_addr=src2;
       WRITE: ram_b_addr=dest;
       default: ram_b_addr=0;
       endcase

    assign ram_b_w = (state==WRITE) ? 1'b1 : 1'b0;
endmodule
