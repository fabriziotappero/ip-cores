//---------------------------------------------------------------------------
// keypad_scanner.v  -- Small keypad scanner module
//
//
// Description: See description below (which suffices for IP core
//                                     specification document.)
//
// Copyright (C) 2002 John Clayton and OPENCORES.ORG (this Verilog version)
//
// This source file may be used and distributed without restriction provided
// that this copyright statement is not removed from the file and that any
// derivative work contains the original copyright notice and the associated
// disclaimer.
//
// This source file is free software; you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published
// by the Free Software Foundation;  either version 2.1 of the License, or
// (at your option) any later version.
//
// This source is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
// FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
// License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this source.
// If not, download it from http://www.opencores.org/lgpl.shtml
//
//-----------------------------------------------------------------------------
//
// Author: John Clayton
// Date  : Jan. 30, 2003
// Update: Mar. 24, 2003  Copied this file from "serial_divide_uu.v"
//                        Stripped out extraneous stuff.
// Update: Mar. 31, 2003  Finished coding, added function "one_low_among_z"
//                        and tested in hardware.
//
//-----------------------------------------------------------------------------
// Description:
//
// This module is for reading keypresses on a small matrix-style keypad,
// keyboard or game controller.
//
// In the interest of keeping things simple and generic, this module does not
// attempt to look at multiple keypresses, whether the key is being depressed
// or else released, N-key rollover or any other such complicated ideas.
//
// In fact, with an X-Y matrix of keys if multiple keys are pressed in
// different rows of the matrix, which share the same column(s), a situation
// arises in which it is impossible to detect which keys are pressed...
// These ambiguous cases do not occur with only 2 keys pressed, but can
// always happen with 3 keys pressed simultaneously.  Please be aware of this!
//
// For cases which are not ambiguous, this unit provides a "1" for keys that
// are pressed, and "0" for keys not pressed.  In the ambiguous cases, extra
// "1" bits appear in the output, even though the corresponding key may not
// have been pressed.
//
// So if all the keys are pressed in one whole row and one whole column,
// then the output will consist of all "1" bits.
//
// The module is termed a "keypad_scanner" because the output, while useful
// in real-time, is a sampling of the keypad matrix.  Each scan produces a
// single "snapshot" of data containing a unique bit for each key.  Each
// scan is initiated by providing a pulse on the scan_i input.  When the
// scan is complete, the new sampled data is produced on the dat_o bus,
// and the stb_o output pulses for one clock.  The scan_i input is ignored
// during a scan.  If the stb_o output is tied to the scan_i input, then the
// unit will scan continuously, as fast as it can proceed.  Each full scan
// requires one clock per row scanned.
//
// Although the keys are scanned row-by-row, the row data are stored and the
// results are presented in parallel at a given instant in time.  The speed
// of scanning is programmable by parameters.
//
// If the scan speed is reduced to a low enough rate (say 50 full scans per
// second) then this can also provide a "free" debouncing function.
// Well, honestly it is not a completely fool-proof switch debounce, since
// the scan may happen to pick up a bounce as a reading, but most bounce is
// less than 20ms in duration, so that the chances of anyone caring about this
// are very slim indeed.
//
// In fact, one could launch from here into a full scale discussion of the
// nature of debouncing, flip-flop metastability issues and the like.
// But I will forego such a philosophical discussion in order to concentrate
// on more practical issues.
//
// IN ORDER FOR THIS MODULE TO WORK PROPERLY, the column inputs must have
// pullup resistors on them.  The rows simply provide a "low" output which can
// overcome the pullups and provide for a valid reading at the column inputs.
// Obviously, the value of the pullups is not critical as long as the row
// scanning rate is slow enough that the pullups can charge the parasitic
// capacitance of the keypad column wires in between row scans.
// Many programmable logic families provide built in pullup resistors which
// can be selected in the pin-constraints file.  These will be more than
// adequate for the use of this module.  Just don't forget to add them, or
// you will most likely get all "0" output.
//
// There are parameters provided in order to set the size of the X-Y key
// matrix.  However, the author was envisioning a small sized keyboard for use
// with this module.  Perhaps the number of keys in the matrix would range
// from 8 (min.) to about 64 or so. (max.)
//
// A matrix larger than this might still work, but there would be a very large
// bus of outputs coming from the module... so just be aware of it.
//
// Parameters are:
//
// ROWS_PP        -- The number of rows in the keypad matrix
// COLS_PP        -- The number of columns in the keypad matrix
// ROW_BITS_PP    -- The number of bits needed to hold ROWS_PP-1
// TMR_CLKS_PP    -- The number of clk_i edges before the next
//                   row is scanned.
// TMR_BITS_PP    -- The number of bits needed to hold TMR_CLKS_PP-1
//
//-----------------------------------------------------------------------------


module keypad_scanner (
  clk_i,
  clk_en_i,
  rst_i,
  scan_i,
  col_i,
  row_o,
  dat_o,
  done_o
  );

parameter ROWS_PP = 4;         // Number of rows to scan
parameter COLS_PP = 4;         // Number of columns to read
parameter ROW_BITS_PP = 2;     // Number of bits needed to hold ROWS_PP-1
parameter TMR_CLKS_PP = 60000; // Set for 200 scans/sec, 4 rows, 48MHz clk_i
parameter TMR_BITS_PP = 16;    // Number of bits needed to hold TMR_CLKS_PP-1

// I/O declarations
input  clk_i;                           // The clock
input  clk_en_i;                        // Used to qualify clk_i input
input  rst_i;                           // synchronous reset
input  scan_i;                          // Used to start a keypad scan
input  [COLS_PP-1:0] col_i;             // The column inputs
output [ROWS_PP-1:0] row_o;             // The row outputs
output [COLS_PP*ROWS_PP-1:0] dat_o;     // The output bus
output done_o;                          // indicates completion of scan

reg  [COLS_PP*ROWS_PP-1:0] dat_o;

// Internal signal declarations
reg  [TMR_BITS_PP-1:0] tmr;
reg  [ROW_BITS_PP-1:0] row;
reg  [COLS_PP*(ROWS_PP-1)-1:0] shift_register;
reg  idle_state;

wire keyscan_row_clk;
wire end_of_scan;
wire [ROWS_PP-1:0] row_output_binary;

//--------------------------------------------------------------------------
// Functions & Tasks
//--------------------------------------------------------------------------

function [ROWS_PP-1:0] one_low_among_z;
  input [ROW_BITS_PP-1:0] row;
  integer k;
  begin
    for (k=0; k<ROWS_PP; k=k+1)
      one_low_among_z[k] = (k == row)?1'b0:1'bZ;
  end
endfunction


//--------------------------------------------------------------------------
// Module code

// This is the inter-row timer.  It advances the row count at a certain rate
always @(posedge clk_i)
begin
  if (rst_i || idle_state) tmr <= 0;
  else if (clk_en_i) tmr <= tmr + 1;
end
assign keyscan_row_clk = (clk_en_i && (tmr == TMR_CLKS_PP-1));

// This is the row counter
always @(posedge clk_i)
begin
  if (rst_i || end_of_scan) row <= 0;
  else if (keyscan_row_clk) row <= row + 1;
end // End of always block
assign end_of_scan = ((row == ROWS_PP-1) && keyscan_row_clk);

// This is the "idle_state" logic
always @(posedge clk_i)
begin
  if (rst_i) idle_state <= 1;     // Begin in idle state
  else if (scan_i && idle_state) idle_state <= 0;
  else if (end_of_scan && ~scan_i) idle_state <= 1;
end
assign done_o = (end_of_scan || idle_state);

// This is the shift register.  Whenever the row count advances, this
// shift register captures row data, except during "final_scan_row."
// When "final_scan_row" is active, then that final row goes directly
// to the output for storage.
always @(posedge clk_i)
begin
  if (keyscan_row_clk && ~end_of_scan)
  begin
    shift_register <= {shift_register,col_i};

    // Alternative coding
    //shift_register[COLS_PP*(ROWS_PP-1)-1:COLS_PP] 
    //               <= shift_register[COLS_PP*(ROWS_PP-2)-1:0];
    //shift_register[COLS_PP-1:0] <= col_i;    
  end
end

// This is the bank of actual output registers.  It captures the column info
// during the final row, and also all of the other column info. stored during
// previous row counts (i.e. what is stored in the shift register)
always @(posedge clk_i)
begin
  if (rst_i) dat_o <= 0;
  else if (keyscan_row_clk && end_of_scan) dat_o <= {shift_register,col_i};
end

// This is the row driver.  It decodes the current row count into a "one low
// of N" output.  The rest of the N outputs are high-impedance (Z).
assign row_o = one_low_among_z(row);

endmodule

