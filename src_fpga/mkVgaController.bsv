
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

package mkVgaController;

import BRAM::*;
import RegFile::*;
import FIFOF::*;
import IVgaController::*;
import IMemClient::*;

`define COLUMNS 640
`define ROWS    480

`define   L_HSYNC_TIME 96
`define   L_BACK_PORCH_TIME 48
`define   L_DATA_TIME 640
`define   L_FRONT_PORCH_TIME 16

typedef enum
{
   L_HSYNC = 96, 
   L_BACK_PORCH = 48,
   L_DATA = 640,
   L_FRONT_PORCH = 16
}
   LineState
            deriving (Eq, Bits);

`define   F_VSYNC_TIME  2
`define   F_BACK_PORCH_TIME 29
`define   F_DATA_TIME 480
`define   F_FRONT_PORCH_TIME 9

typedef enum
{
   F_VSYNC = 2, 
   F_BACK_PORCH = 29,
   F_DATA = 480,
   F_FRONT_PORCH = 9
}
   FrameState
            deriving (Eq, Bits);

typedef enum
{
   U_BRAM,
   Y_BRAM,
   V_BRAM
}
   TargetBuffer
            deriving (Eq, Bits);

`define Y0_OFFSET   20'b0
`define U0_OFFSET   `ROWS*`COLUMNS +  20'b0
`define V0_OFFSET   `U0_OFFSET + `ROWS/2*`COLUMNS/2 + 20'b0 
`define Y1_OFFSET   `V0_OFFSET + `ROWS/2*`COLUMNS/2 + 20'b0
`define U1_OFFSET   `Y1_OFFSET + `ROWS*`COLUMNS +  20'b0
`define V1_OFFSET   `U1_OFFSET + `ROWS/2*`COLUMNS/2 + 20'b0
`define HIGH_ADDR  `V1_OFFSET + `ROWS/2*`COLUMNS/2 - 1 

(* always_ready, always_enabled *)
interface BRAMFrontend;
  method Action   data_input(Bit#(64) data);
  method Bit#(64) data_output();
  method Bit#(32) addr_output();
  method Bit#(1)  enable();
  method Bit#(4)  wenable();
  method Bit#(1)  vsync();
  method Bit#(1)  hsync();
  method Bit#(1)  blank();
  method Bit#(1)  sync_on_green();
  method Bit#(8)  red();
  method Bit#(8)  blue();
  method Bit#(8)  green();
endinterface




//(* synthesize *)
module mkVgaController#(IMemClient#(Bit#(18), Bit#(32)) bram_Y, 
                        IMemClient#(Bit#(18), Bit#(32)) bram_U, 
                        IMemClient#(Bit#(18), Bit#(32)) bram_V) (IVgaController);

  Reg#(Bit#(8)) red_reg <- mkReg(0);
  Reg#(Bit#(8)) blue_reg <- mkReg(0);
  Reg#(Bit#(8)) green_reg <- mkReg(0);
  Reg#(Bit#(1)) target_buffer <- mkReg(0);
  Reg#(Bit#(TLog#(`ROWS))) bram_address_row <- mkReg(0);
  Reg#(Bit#(TLog#(`COLUMNS))) bram_address_col <- mkReg(0);
  Reg#(Bit#(TLog#(`COLUMNS))) bram_resp_col <- mkReg(0);       
  Reg#(FrameState) frame_state <- mkReg(F_VSYNC);
  Reg#(LineState) line_state <- mkReg(L_HSYNC);
  Reg#(Bit#(11)) line_counter <- mkReg(0);
  Reg#(Bit#(11)) tick_counter <- mkReg(0);
  Reg#(Bit#(1)) hsync_buffer <- mkReg(0);
  Reg#(Bit#(1)) vsync_buffer <- mkReg(0);
  Reg#(Bit#(1)) blank_buffer <- mkReg(0);
  Reg#(Bit#(1)) sync_on_green_buffer <- mkReg(0);
  Reg#(Bit#(3)) bram_line_offset <- mkReg(0);
  Reg#(Bool) frame_switch_seen <- mkReg(True);
  Reg#(Bit#(32)) counter <- mkReg(0);
  Reg#(Bit#(32)) y_word_buffer <- mkReg(0);
  Reg#(Bit#(32)) u_word_buffer <- mkReg(0);
  Reg#(Bit#(32)) v_word_buffer <- mkReg(0);   


  function Bit#(8) ybyte (Bit#(32) word);
     return case (bram_line_offset[1:0])
         2'b11: word[31:24];     
         2'b10: word[23:16];  
         2'b01: word[15:8];
         2'b00: word[7:0];
       endcase;
  endfunction: ybyte

  function Bit#(8) uvbyte (Bit#(32) word);
     return case (bram_line_offset[2:1])
         2'b11: word[31:24];     
         2'b10: word[23:16];  
         2'b01: word[15:8];
         2'b00: word[7:0];
       endcase;
  endfunction: uvbyte

// Fix the stupidity here.
  rule black_rgb((line_state == L_DATA) && (bram_resp_col == `COLUMNS));
   red_reg <= 0;
   blue_reg <= 0;
   green_reg <= 0;
  endrule

  rule translate_rgb(line_state == L_DATA);
    Bit#(8) y_wire;
    Bit#(8) u_wire;
    Bit#(8) v_wire;  

    counter <= counter + 1;
    bram_line_offset <= bram_line_offset + 1;
    bram_resp_col <= bram_resp_col + 1;

    if(bram_line_offset[1:0] == 0) 
      begin
        Bit#(32) y_word;
        y_word <- bram_Y.read_resp();
        y_word_buffer <= y_word;
        y_wire = ybyte(y_word);
      end
    else
      begin
        y_wire = ybyte(y_word_buffer);
      end

    if(bram_line_offset[2:0] == 0)
      begin
        Bit#(32)u_word;
        Bit#(32)v_word;
        u_word <- bram_U.read_resp();
        u_word_buffer <= u_word;
        u_wire = uvbyte(u_word);
        v_word <- bram_V.read_resp();
        v_word_buffer <= v_word;
        v_wire = uvbyte(v_word);
      end
    else
      begin
        u_wire = uvbyte(u_word_buffer);
        v_wire = uvbyte(v_word_buffer);
      end

    Int#(18) y_value = unpack(zeroExtend(y_wire));
    Int#(18) u_value = unpack(signExtend(u_wire-128));
    Int#(18) v_value = unpack(signExtend(v_wire-128));
 
    //YRB
    Int#(18) red_reg_next = (( 298 * y_value + 409 * v_value + 128) >> 8);
    Int#(18) green_reg_next = (( 298 * y_value -  100 *  u_value - 209 * v_value + 128) >> 8);
    Int#(18) blue_reg_next = (( 298 * y_value +  516* u_value +128) >> 8);

    Bit#(8) test_red = (red_reg_next < 0) ? 0 : ((red_reg_next >255) ? 255 : truncate(pack(red_reg_next))); 
    Bit#(8) test_blue = (blue_reg_next < 0) ? 0 : ((blue_reg_next >255) ? 255 : truncate(pack(blue_reg_next)));     
    Bit#(8) test_green = (green_reg_next < 0) ? 0 : ((green_reg_next >255) ? 255 : truncate(pack(green_reg_next)));

    red_reg <= (red_reg_next < 0) ? 0 : ((red_reg_next >255) ? 255 : truncate(pack(red_reg_next)));
    blue_reg <= (blue_reg_next < 0) ? 0 : ((blue_reg_next > 255) ? 255 : truncate(pack(blue_reg_next)));
    green_reg <= (green_reg_next < 0) ? 0 : ((green_reg_next > 255) ? 255 : truncate(pack(green_reg_next)));


    $display("RGB %d %d %d", test_red, test_green, test_blue);
  endrule

  rule tick_update(tick_counter > 0); 
    tick_counter <= tick_counter - 1;
  endrule

  rule line_update((line_counter > 0) && (tick_counter == 1) && (line_state == L_HSYNC));
    line_counter <= line_counter - 1; 
  endrule
   
  rule send_req_to_bram((frame_state == F_DATA) && ((line_state == L_BACK_PORCH) || (line_state == L_DATA)) && !(bram_address_col == `COLUMNS) && !(bram_address_row == `ROWS) );
    Bit#(TLog#(`COLUMNS)) adjusted_col_addr = (bram_address_col == `COLUMNS) ? 0 : bram_address_col;
    if(target_buffer == 0)
      begin
        bram_Y.read_req(truncate((`Y0_OFFSET +  `COLUMNS*zeroExtend(bram_address_row) + zeroExtend(adjusted_col_addr))>>2));
       if(bram_address_col[2:0] == 0)
         begin        
           bram_U.read_req(truncate((`U0_OFFSET +  (`COLUMNS/2)*zeroExtend(bram_address_row/2) + zeroExtend(adjusted_col_addr/2))>>2));
           bram_V.read_req(truncate((`V0_OFFSET +  (`COLUMNS/2)*zeroExtend(bram_address_row/2) + zeroExtend(adjusted_col_addr/2))>>2));
         end
      end      
    else
      begin
        bram_Y.read_req(truncate((`Y1_OFFSET +  `COLUMNS*zeroExtend(bram_address_row) + zeroExtend(adjusted_col_addr))>>2));
       if(bram_address_col[2:0] == 0)
         begin
           bram_U.read_req(truncate((`U1_OFFSET +  (`COLUMNS/2)*zeroExtend(bram_address_row/2) + zeroExtend(adjusted_col_addr/2))>>2));
           bram_V.read_req(truncate((`V1_OFFSET +  (`COLUMNS/2)*zeroExtend(bram_address_row/2) + zeroExtend(adjusted_col_addr/2))>>2));
         end
      end       
    bram_address_col <= bram_address_col + 4;
  endrule

  rule line_HSYNC_to_BP ((tick_counter == 0) && (line_state == L_HSYNC));
    tick_counter <= `L_BACK_PORCH_TIME;
    line_state <= L_BACK_PORCH;
    //$display("Back Porch\n");
  endrule

  rule line_BP_to_DATA ((tick_counter == 0) && (line_state == L_BACK_PORCH));
    tick_counter <= `L_DATA_TIME;
    line_state <= L_DATA;
    //$display("Data\n");
    // Need to do something with addressing here
  endrule

  rule line_data_to_FP ((tick_counter == 0) && (line_state == L_DATA));
    tick_counter <= `L_FRONT_PORCH_TIME;
    line_state <= L_FRONT_PORCH;
    //$display("Front Porch\n");
  endrule

  rule line_FP_to_HSYNC_no_deq ((tick_counter == 0) && (line_state == L_FRONT_PORCH));
    if(frame_state == F_DATA && (bram_address_row < `ROWS)) 
      begin 
        bram_address_row <=  bram_address_row + 1; 
      end
    else if (frame_state==F_BACK_PORCH)
      begin
        bram_address_row <=  0;
      end
    else
      begin
        bram_address_row <=  bram_address_row;
      end
    bram_resp_col <= 0;
    bram_address_col <= 0;
    bram_line_offset <=0;
    tick_counter <= `L_HSYNC_TIME;
    line_state <= L_HSYNC;
    //$display("HSYNC\n");
  endrule

  rule frame_HSYNC_to_BP ((line_counter == 0) && (frame_state == F_VSYNC));
    line_counter <= `F_BACK_PORCH_TIME;
    frame_state <= F_BACK_PORCH;
  endrule

  rule frame_BP_to_DATA ((line_counter == 0) && (frame_state == F_BACK_PORCH));
    line_counter <= `F_DATA_TIME;
    frame_state <= F_DATA;
  endrule

  rule frame_data_to_FP ((line_counter == 0) && (frame_state == F_DATA));
    frame_switch_seen <= False;     
    $display("bufferswitch: setdown");
    line_counter <= `F_FRONT_PORCH_TIME;
    frame_state <= F_FRONT_PORCH;
  endrule

  rule frame_FP_to_VSYNC ((line_counter == 0) && (frame_state == F_FRONT_PORCH));
    line_counter <= `F_VSYNC_TIME;
    frame_state <= F_VSYNC;
  endrule

  // hsync and vsync are asserted low.
  rule hsync_delay;
    hsync_buffer <= (line_state == L_HSYNC)? 1 : 0;
  endrule

  rule vsync_delay;
    vsync_buffer <= (frame_state == F_VSYNC)? 1 : 0;
  endrule

  rule blank_delay;
    blank_buffer <= ((frame_state == F_DATA) && (line_state == L_DATA))? 1 : 0;
  endrule

  method  red;
    return red_reg;
  endmethod

  method  blue;
    return blue_reg;
  endmethod

  method  green;
    return green_reg;
  endmethod


  method  sync_on_green;
    return ((hsync_buffer == 0) || (vsync_buffer == 0))? 0 : 1;
  endmethod

  // hsync and vsync are asserted low.
  method  hsync;
    return hsync_buffer;
  endmethod  

  method  vsync;
    return vsync_buffer;
  endmethod

  method blank;
   return blank_buffer;
  endmethod

   method Action  switch_buffer(Bit#(1) buffer) if((frame_state != F_DATA) && (!frame_switch_seen));
    frame_switch_seen <= True;
    $display("bufferswitch: %d", buffer);
    target_buffer <= buffer;
  endmethod

endmodule

endpackage

