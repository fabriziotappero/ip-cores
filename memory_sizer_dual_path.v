//----------------------------------------------------------------------------
// Wishbone memory_sizer_dual_path core
//
// This file is part of the "memory_sizer" project.
// http://www.opencores.org/cores/memory_sizer
// 
//
// Description: See description below (which suffices for IP core
//                                     specification document.)
//
// Copyright (C) 2001 John Clayton and OPENCORES.ORG
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
//----------------------------------------------------------------------------
//
// Author: John Clayton
// Date  : November  5, 2001
// Update: 11/05/01 copied this file from rs232_syscon.v (pared down).
// Update: 11/16/01 Continued coding efforts.  Redesigned logic with scalable
//                  "byte sized barrel shifter" and byte reversal blocks (byte
//                  reversal is implemented as a function "byte_reversal").
//                  Changed encoding of memory_width_i and access_width_i.
//                  Implemented new counting and byte enable logic.
// Update: 12/04/01 Realized there was a mistake in the byte enable logic.
//                  Fixed it by using dat_shift to shift the byte enables.
//                  Made "byte_enable_source" twice as wide.
// Update: 12/05/01 Eliminated the "count" in favor of using "dat_shift" along
//                  with new terminal_count logic, in order to fix flaws found
//                  in the terminal_count signal.  Fixed byte steering for
//                  stores.  Tested using N_PP = 4, and LOG2_N_PP = 2 and saw
//                  correct operation for all sizes of store operations.
// Update: 12/13/01 Began testing with read logic.  Found byte enable problem
//                  during writes.  Removed "byte_dirty" bits.
// Update: 12/14/01 Added "latch_be_source" to create byte enables for reading
//                  which are based on the size of the memory (which fixed a
//                  bug in reading.)  The module appears to be fully working,
//                  except for "big_endian" reads.
// Update: 12/17/01 Introduced the "middle_bus" in order to decouple the
//                  byte reverser from the byte steering logic, so that for
//                  writes byte reversing is done first, but for reads then
//                  byte reversing is done last.  Introduced "latch_be_adjust"
//                  to cover big endian reads -- all is now working.
// Update: 12/17/01 Removed "middle_bus" (the two units are still decoupled!)
//                  because it seemed unnecessary.  This freed up Tbuffs, but
//                  had no effect on resource utilization (slices).  Also, the
//                  maximum reported clock speed increased.  Removed debug
//                  port.
// Update: 12/18/01 Copied this from "memory_sizer_tristate_switching.v"
//                  This file will now have duplicate byte steering and byte
//                  swapping logic.  Changed module name to 
//                  "memory_sizer_dual_path"
//
// Description
//-------------------------------------------------------------------------------------
//
// This module is just like "memory_sizer" except that it provides separate
// paths for the writing and the reading of memory.  By avoiding the tri-state
// bus switching, it uses less tri-state buffers, and should operate faster
// than the original "memory_sizer"
//
// ORIGINAL DESCRIPTION:
// This logic module takes care of sizing bus transfers between a small
// microprocessor and its memory.  It enables the microprocessor to
// generate access requests for different widths (read/write BYTE, WORD and
// DWORD, etc.) using memory which is sized independently of the accesses.
//
// Thus, a 32-bit microprocessor using 32-bit wide accesses can use this block
// in order to boot from an 8-bit wide flash device.  This block takes care of 
// generating the four 8-bit memory cycles that are required in order to read
// each DWORD for alimentation of the microprocessor.
//
// Also, if the memory supports byte enables during a write cycle, then this
// block "steers" a smaller data word to the appropriate location within a
// larger memory word, and activates the appropriate byte enables so that only
// the BYTEs which are affected by the write cycle are actually overwritten.
//
// Moreover, the memory_sizer block takes care of translating little-endian
// formats into big-endian formats and vice-versa.  This is accomplished by the
// use of a single input bit "endianness_i"
//
// The memory_sizer block does not latch or store the parameters which it uses
// for operation.  The input signals determine its operation on an ongoing
// basis.  In fact, the only data storage present in this block is the latching
// provided for data which must be held during multiple cycle read operations.
// (There are also some counters, which don't count as data storage...)
//
// Encoding for access_width_i and memory_width_i is as follows:
//
// Bits           Significance
// ------         ------------
// 0001            8-bits wide (1 byte)
// 0010           16-bits wide (2 bytes)
// 0100           32-bits wide (4 bytes)
// 1000           64-bits wide (8 bytes)
//
// (The access_width_i and memory_width_i inputs are sized according to the
// parameter LOG2_N_PP, but the significance is the same, using whatever
// lsbs are present.)
//
// It is envisioned that a designer may include this block for flexibility.
// If all of the memory accesses are of a single width, and the memory matches
// that width, and there is no need for endianness translation, then the user
// could hard-code the "memory_width_i" and "access_width_i" to correspond
// to the same width, hard-code the "endianness_i" input to the desired value
// and then the memory_sizer block would effectively do nothing, or very little.
// Most of its size and resources would be optimized out of the design at
// compile time.  The dat_shift counter and read-storage latches would not be
// used, and so they would not even be synthesized.
//
// On the other hand, if the memory in the SOC (system on a chip) comprises
// various width devices, then the decode logic which selects the blocks of
// memory is ORed (for each like-sized block) and then concatenated in the
// proper order to generate a dynamic "mem_width_i" signal to the
// memory_sizer, so that the different size accesses are accomodated.  The
// processor side, meanwhile (being "access_width_i"), could still be
// hard-wired to a given width, or be connected so that different width loads
// and stores are generated as needed.
//
// This block may generate exceptions to the processor, in the case of a write
// request, for example, to store a BYTE into a DWORD wide memory which doesn't
// support the use of byte enables.  Although this could be done by reading the
// wider memory and masking in the correct BYTE, followed by storing the
// results back into the memory, this was deemed too complex a task for this
// block.  Responsibility for such operations, if desired, would devolve upon
// the microprocessor itself.  Support of byte enables is indicated by a "1" on
// the "memory_has_be_i" line.
//
// The clock used by memory_sizer is not limited to the speed of the clock used
// by the microprocessor.  Since the memory_sizer contains only combinational
// logic, simple counters and some possible latches, it might run much faster
// than the microprocessor.  In that case, generate two clocks which are
// synchronous:  one for the processor, and another for memory_sizer.
// The memory_sizer clock could be 2x, 4x or even 8x that of the processor.
// In this way, the memory_sizer block can complete multiple memory read cycles
// in the same time as a single processor cycle -- assuming the memory is fast
// enough to support it -- and thereby the memory latency can be reduced.
//
// The memory_sizer block is not responsible for implementing wait states for
// the memory, especially since the number of wait states required can vary
// for each type and width of memory used.  Instead, there is an "access_ack_o"
// signal to indicate completion of the entire requested memory access to the
// processor.  On the memory side, there is "memory_ack_i" used to indicate to
// the memory_sizer block that the memory has completed the current cycle in
// progress.  Therefore, in order to implement wait states, the memory sytem
// address decoder logic should generate the "memory_ack_i" signal based on the
// different types of memory present within the system, which can also be
// programmable.  A parameterized watchdog timer inside of the memory sizer block
// indicates when "memory_ack_i" has not been asserted in a reasonable number
// of clock cycles.  When this occurs, an exception is raised.  The timer
// is started when "sel_i" is active (high).  sel_i must remain active
// until the access is completed, otherwise the timer will reset and the
// access is aborted.  If you don't want to use the watchdog portion of this
// block then simply don't connect the exception_watchdog_o line, and the watchdog
// timer will be optimized out of the logic.
//
// If desired, registers can be placed on the memory side of the block.  They
// are treated just like memory of a given width, although access requests for
// misaligned writes, or writes which are smaller than the size of the registers,
// should generate exceptions, unless the registers support byte enables.
//
// Addresses are always assumed to be byte addresses in this unit, since the
// smallest granularity of data used in it is the BYTE.  Also, the data bus
// size used must be a multiple of 8 bits, for the same reason.
//
//-------------------------------------------------------------------------------------


`define BYTE_SIZE  8         // Number of bits in one byte


module memory_sizer_dual_path (
  clk_i,
  reset_i,
  sel_i,
  memory_ack_i,
  memory_has_be_i,
  memory_width_i,
  access_width_i,
  access_big_endian_i,
  adr_i,
  we_i,
  dat_io,
  memory_dat_io,
  memory_adr_o,              // Same width as adr_i (only lsbs are modified)
  memory_we_o,
  memory_be_o,
  access_ack_o,
  exception_be_o,
  exception_watchdog_o
  );

// Parameters

// The timer value can be from [0 to (2^WATCHDOG_TIMER_BITS_PP)-1] inclusive.
parameter N_PP                    = 4;   // number of bytes in data bus
parameter LOG2_N_PP               = 2;   // log base 2 of data bus size (bytes)
parameter ADR_BITS_PP             = 32;  // # of bits in adr buses
parameter WATCHDOG_TIMER_VALUE_PP = 12;  // # of sys_clks before ack expected
parameter WATCHDOG_TIMER_BITS_PP  = 4;   // # of bits needed for timer


// I/O declarations
input clk_i;           // Memory sub-system clock input
input reset_i;         // Reset signal for this module
input sel_i;           // Enables watchdog timer, activates memory_sizer
input memory_ack_i;    // Ack from memory (delay for wait states)
input memory_has_be_i; // Indicates memory at current address has byte enables
input [LOG2_N_PP:0] memory_width_i;        // Width code of memory
input [LOG2_N_PP:0] access_width_i;        // Width code of access request
input access_big_endian_i;                 // 0=little endian, 1=big endian
input [ADR_BITS_PP-1:0] adr_i;             // Address bus input
input we_i;                                // type of access
inout [`BYTE_SIZE*N_PP-1:0] dat_io;        // processor data bus
inout [`BYTE_SIZE*N_PP-1:0] memory_dat_io; // data bus to memory
output [ADR_BITS_PP-1:0] memory_adr_o;     // address bus to memory
output memory_we_o;                        // we to memory
output [N_PP-1:0] memory_be_o;             // byte enables to memory
output access_ack_o;         // shows that access is completed
output exception_be_o;       // exception for write to non-byte-enabled memory
output exception_watchdog_o; // exception for memory_ack_i watch dog timeout

// Internal signal declarations
wire [2*N_PP-1:0] memory_be_source;     // Unshifted byte enables for writing
wire [2*N_PP-1:0] latch_be_source;      // Unshifted byte enables for reading
wire [N_PP-1:0] latch_be;               // "latch_be" is like "memory_be_o" 
wire [N_PP-1:0] latch_be_lil_endian;    //    but used internally for reads.
wire [N_PP-1:0] latch_be_big_endian;
wire [LOG2_N_PP-1:0] latch_be_adjust;
wire [LOG2_N_PP+1:0] dat_shift_next;    // Next dat_shift value (extra bit
                                        //   is for terminal count compare.)
wire [LOG2_N_PP-1:0] alignment;         // shows aligment of access
wire terminal_count;                    // signifies last store cycle
 
reg [LOG2_N_PP-1:0] rd_byte_mux_select; // selects which bytes to transfer
reg [LOG2_N_PP-1:0] wr_byte_mux_select; // selects which bytes to transfer
reg [LOG2_N_PP:0] dat_shift;            // shift amt. for data and byte enables
reg [`BYTE_SIZE*N_PP-1:0] wr_steer_dat_o; // data from byte steering logic
reg [`BYTE_SIZE*N_PP-1:0] wr_revrs_dat_o; // data from byte reversing logic
reg [`BYTE_SIZE*N_PP-1:0] rd_revrs_dat_o; // data from byte reversing logic
reg [`BYTE_SIZE*N_PP-1:0] rd_steer_dat_o; // data from byte steering logic
reg [`BYTE_SIZE*N_PP-1:0] read_dat;     // read data (after latch bypassing)
reg [`BYTE_SIZE*N_PP-1:0] latched_read_dat; // read values before latch bypass


reg [WATCHDOG_TIMER_BITS_PP-1:0] watchdog_count;

//--------------------------------------------------------------------------
// Instantiations
//--------------------------------------------------------------------------


//--------------------------------------------------------------------------
// Functions & Tasks
//--------------------------------------------------------------------------

function [`BYTE_SIZE*N_PP-1:0] byte_reversal;
  input [`BYTE_SIZE*N_PP-1:0] din;
  integer k;
  begin
    for (k=0; k<N_PP; k=k+1)
      byte_reversal[`BYTE_SIZE*(N_PP-k)-1:`BYTE_SIZE*(N_PP-k-1)]
        <= din[`BYTE_SIZE*(k+1)-1:`BYTE_SIZE*k];
  end
endfunction

//--------------------------------------------------------------------------
// Module code
//--------------------------------------------------------------------------

// Mask off the address bits that don't matter for alignment
assign alignment = (memory_width_i - 1) & adr_i[LOG2_N_PP-1:0];

// Setting up the basic (alignment shifted) byte enables
assign memory_be_source = ((1<<access_width_i)-1);
assign latch_be_source = ((1<<memory_width_i)-1);

// Assigning the byte enables and latch enables
assign memory_be_o = we_i?((memory_be_source << alignment) >> dat_shift)
                          :{N_PP{1'b1}};
                          // (memory byte enables are all high for reads!)

// For big_endian reads, the latch byte enables (and indeed the data also)
// are shifted using a special mapping, which causes the data to appear at 
// the opposite end of the "read_data" bus.
assign latch_be_lil_endian = ((latch_be_source << dat_shift) >> alignment);
assign latch_be_adjust = ~(access_width_i[LOG2_N_PP-1:0]-1);
assign latch_be_big_endian = latch_be_lil_endian << latch_be_adjust;
assign latch_be = (access_big_endian_i)?latch_be_big_endian
                                       :latch_be_lil_endian;

// Exceptions
assign exception_be_o = (alignment != 0) && ~memory_has_be_i;
assign exception_watchdog_o = (watchdog_count == WATCHDOG_TIMER_VALUE_PP);

// Pass signals to memory
assign memory_we_o = we_i;


// Enable the data bus outputs in each direction
assign dat_io = (sel_i && ~we_i)?rd_revrs_dat_o:{`BYTE_SIZE*N_PP{1'bZ}};
assign memory_dat_io = (sel_i && we_i)?wr_steer_dat_o:{`BYTE_SIZE*N_PP{1'bZ}};



// THIS LOGIC IS FOR THE WRITING PATH
//-------------------------------------
// Byte reversal logic
always @(
         dat_io              or
         access_big_endian_i
         )
begin
  // Reverse the bytes of the data bus, if needed
  if (access_big_endian_i) wr_revrs_dat_o <= byte_reversal(dat_io);
  else wr_revrs_dat_o <= dat_io;
end


// Steering logic
always @(
         wr_revrs_dat_o      or
         dat_shift           or
         alignment           or
         we_i                or
         access_width_i      or
         access_big_endian_i
         )
begin
  // If bytes are reversed, an extra "bit inversion mask" is applied
  // to reflect a new mapping which is correct for reversed bytes.
  if (access_big_endian_i)
    wr_byte_mux_select <= (dat_shift[LOG2_N_PP-1:0] ^ ~(access_width_i-1))
                           - alignment;
  else wr_byte_mux_select <= dat_shift - alignment;

  // Rotate the data bus (byte-sized barrel shifter!)
  wr_steer_dat_o <= (
                     (wr_revrs_dat_o >> `BYTE_SIZE*wr_byte_mux_select)
                    |(wr_revrs_dat_o << `BYTE_SIZE*(N_PP-wr_byte_mux_select))
                     );
end


// THIS LOGIC IS FOR THE READING PATH
//-------------------------------------

// Steering logic
always @(
         memory_dat_io       or
         dat_shift           or
         alignment           or
         we_i                or
         access_width_i      or
         access_big_endian_i
         )
begin
    // For reads, negate the shift amount
  if (access_big_endian_i)
    rd_byte_mux_select <= alignment 
                          - (dat_shift[LOG2_N_PP-1:0] ^ ~(access_width_i-1));
  else rd_byte_mux_select <= alignment - dat_shift;

  // Rotate the data bus (byte-sized barrel shifter!)
  rd_steer_dat_o <= (
                     (memory_dat_io >> `BYTE_SIZE*rd_byte_mux_select)
                    |(memory_dat_io << `BYTE_SIZE*(N_PP-rd_byte_mux_select))
                    );
end


// This logic latches the data bytes which are read during the first cycles
// of an access.  During the final cycle of the access, then "terminal_count"
// is asserted by the counting logic, which causes the latches which are
// "non-dirty" (i.e. which do not yet contain data) to be bypassed by muxes.
// This means that for single cycle accesses, the data will flow directly
// around the latches and an extra clock cycle will not be needed in order
// to latch the data...
always @(posedge clk_i)
begin: BYTE_LATCHES
  integer i;

  if (reset_i || terminal_count || ~sel_i)
  begin
    latched_read_dat <= 0;
  end
  else if (sel_i && ~we_i && memory_ack_i)
  begin
    for (i=0;i<N_PP;i=i+1)
    begin
      if (latch_be[i]) latched_read_dat[`BYTE_SIZE*(i+1)-1:`BYTE_SIZE*i]
                       <= rd_steer_dat_o[`BYTE_SIZE*(i+1)-1:`BYTE_SIZE*i];
    end
  end
end

// This part handles the bypass muxes
always @(
         terminal_count      or
         latch_be            or
         rd_steer_dat_o      or
         latched_read_dat
         )
begin: LATCH_BYPASS
  integer j;

  for (j=0;j<N_PP;j=j+1)
  begin
    if (terminal_count && latch_be[j]) 
         read_dat[`BYTE_SIZE*(j+1)-1:`BYTE_SIZE*j] 
         <= rd_steer_dat_o[`BYTE_SIZE*(j+1)-1:`BYTE_SIZE*j];
    else read_dat[`BYTE_SIZE*(j+1)-1:`BYTE_SIZE*j]
         <= latched_read_dat[`BYTE_SIZE*(j+1)-1:`BYTE_SIZE*j];
  end
end

// Byte reversal logic
always @(
         read_dat            or
         access_big_endian_i
         )
begin
  // Reverse the bytes of the data bus, if needed
  if (access_big_endian_i) rd_revrs_dat_o <= byte_reversal(read_dat);
  else rd_revrs_dat_o <= read_dat;
end


// THIS LOGIC IS GENERAL
//--------------------------
// This is the counting logic.
// It is implemented using "count_next" in order to detect when
// the last cycle is being performed, which is when the "next" count
// equals or exceeds the total size of the access requested in bytes.
// (Using the "next" approach avoids issues relating to different
//  memory sizes!)
always @(posedge clk_i)
begin
  if (reset_i || terminal_count || ~sel_i) dat_shift <= 0;
  else if (memory_ack_i) dat_shift <= dat_shift_next;
end

assign dat_shift_next = dat_shift + memory_width_i;
assign terminal_count = (dat_shift_next >= (access_width_i + alignment));
assign memory_adr_o = adr_i + dat_shift;
assign access_ack_o = terminal_count && sel_i;

// This is the watchdog timer
// It runs whenever the memory_sizer is selected for an access, and the
// memory has not yet responded with an ack signal.
always @(posedge clk_i)
begin
  if (reset_i || ~sel_i || memory_ack_i) watchdog_count <= 0;
  else if (~exception_watchdog_o) watchdog_count <= watchdog_count + 1;
end


endmodule


