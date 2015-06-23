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
// FILE NAME            : dut_if.sv
// AUTHOR               : Laue Rami Souza Costa de Jesus
// -----------------------------------------------------------------------------

interface dut_if (input bit clk);

//input signals task 

logic rst_n;
logic start;

logic [7:0] pixel1;
logic [7:0] pixel2;
logic [7:0] pixel3;
logic [7:0] pixel4;

logic [31:0] word0;
logic [31:0] word1;
logic [31:0] word2;

logic [9:0] waddr;
logic [1:0] window_line_counter;

//output signals task

logic [31:0] ch_word0;
logic [31:0] ch_word1;
logic [31:0] ch_word2;

logic end_of_operation;

logic [7:0] result [0:51983];

endinterface
