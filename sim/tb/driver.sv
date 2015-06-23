/* --------------------------------------------------------------------------------
 This file is part of FPGA Median Filter.

    FPGA Median Filter is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FPGA Median Filter is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FPGA Median Filter.  If not, see <http://www.gnu.org/licenses/>.
-------------------------------------------------------------------------------- */
// +----------------------------------------------------------------------------
// Universidade Federal da Bahia
//------------------------------------------------------------------------------
// PROJECT: FPGA Median Filter
//------------------------------------------------------------------------------
// FILE NAME            : driver.sv
// AUTHOR               : Laue Rami Souza Costa de Jesus
// -----------------------------------------------------------------------------
class driver;

//  localparam MEMORY_WIDTH = 4331;
  localparam NUM_PIXELS = (`IMG_WIDTH * `IMG_HEIGHT) - 1;//102400-1;

  int cnt;
  int addr;
  int i;
  logic [31:0] r_data_bram0;
  logic [31:0] r_data_bram1;
  logic [31:0] r_data_bram2;

  logic [7:0] image [0:NUM_PIXELS];

  virtual interface dut_if dut_if;

  function new (virtual interface dut_if m_dut_if);
  begin
     dut_if = m_dut_if;
  end
  endfunction

  task init();
    begin
        $display("RESET --------");
        dut_if.rst_n    = 1;
        dut_if.start    = 0;
        dut_if.ch_word0 = 0;
        dut_if.ch_word1 = 0;
        dut_if.ch_word2 = 0;
        addr = 0;
        i = 0;
        dut_if.end_of_operation = 0;
        repeat(5)@(negedge dut_if.clk);
        dut_if.rst_n = 0;
        repeat(5)@(negedge dut_if.clk);
        dut_if.rst_n = 1;
        dut_if.start = 1;
        repeat(3)@(negedge dut_if.clk);
    end
  endtask

  task reorganize_lines();
    begin
      wait(dut_if.start);
      @(negedge dut_if.clk);
      while(!(dut_if.end_of_operation))begin
         if(dut_if.window_line_counter == 2'b00)begin
            dut_if.ch_word0 = dut_if.word0;
            dut_if.ch_word1 = dut_if.word1;
            dut_if.ch_word2 = dut_if.word2;
         end
         else if(dut_if.window_line_counter == 2'b01)begin
            dut_if.ch_word0 = dut_if.word1;
            dut_if.ch_word1 = dut_if.word2;
            dut_if.ch_word2 = dut_if.word0;
         end
         else if(dut_if.window_line_counter == 2'b10)begin
            dut_if.ch_word0 = dut_if.word2;
            dut_if.ch_word1 = dut_if.word0;
            dut_if.ch_word2 = dut_if.word1;
         end
         //addr = addr+1;
         //read 4 pixels from all memories
         @(negedge dut_if.clk);
      end
      dut_if.start = 0;
    end
  endtask

  task receive_data();
     fork begin
        while(i<NUM_PIXELS)begin
           //seria bom ter um sinal para saber quando terminou a mediana
           dut_if.result[i] = dut_if.pixel1;
           image[i] = dut_if.pixel1;
           dut_if.result[i+1] = dut_if.pixel2;
           image[i+1] = dut_if.pixel2;
           dut_if.result[i+2] = dut_if.pixel3;
           image[i+2] = dut_if.pixel3;
           dut_if.result[i+3] = dut_if.pixel4;
           image[i+3] = dut_if.pixel4;
           @(negedge dut_if.clk);
           i = i + 4;
        end
        dut_if.end_of_operation = 1;
     end
     join_none
  endtask

  function int write_file();

     integer file_ID = $fopen("./image.hex", "w");

     for(int i=0 ; i<=NUM_PIXELS ; i++ ) begin
        if(image[i] === 8'bx)
           $fdisplay(file_ID,"%x", 8'b0);
        else
           $fdisplay(file_ID,"%x", image[i]);
     end

     $fclose(file_ID);

  endfunction

endclass
