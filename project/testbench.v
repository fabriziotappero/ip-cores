`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:25:07 09/20/2006 
// Design Name: 
// Module Name:    testbench 
// Project Name:                            
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments:                                             
//
//////////////////////////////////////////////////////////////////////////////////

module testbench(addr,     // Address out
                 data,     // Data bus
                 readmem,  // Memory read
                 writemem, // Memory write
                 readio,   // Read I/O space
                 writeio,  // Write I/O space
                 intr,     // Interrupt request 
                 inta,     // Interrupt request 
                 waitr,    // Wait request
                 r, g, b,  // vga colors
                 hsync_n,  // vga horizontal sync negative
                 vsync_n,  // vga vertical sync negative
                 ps2_clk,  // keyboard clock
                 ps2_data, // keyboard data
                 reset_n,  // Reset
                 clock,    // System clock
                 diag);    // diagnostic port

   output [15:0] addr;
   inout  [7:0] data;
   output readmem;
   output writemem;
   output readio;
   output writeio;
   output intr;
   output inta;
   output waitr;
   output [2:0] r, g, b; // R,G,B color output buses
   output hsync_n; // horizontal sync pulse
   output vsync_n; // vertical sync pulse
   input  ps2_clk;  // clock from keyboard
   input  ps2_data; // data from keyboard
   input  reset_n;
   input  clock;
   output [7:0] diag; // diagnostic 8 bit port

   //
   // Instantiations
   //

   // selector block, we only use select 1, 2 and 3
   select select1(addr, data, readio, writeio, romsel, ramsel, intsel, 
                  trmsel, bootstrap, clock, reset);

   // 8080 CPU
   cpu8080 cpu(addr, data, readmem, writemem, readio, writeio, intr, inta, waitr,
               reset, clock);

   // Program rom
   rom rom(addr[10:0], data, romsel&readmem); // unclocked rom

   // neg clocked ram
   ram ram(addr[9:0], data, ramsel, readmem, writemem, bootstrap, clock);

   // neg clocked interrupt controller
   intcontrol intc(addr[2:0], data, writeio, readio, intsel, intr, inta, int0, int1,
                   int2, int3, int4, int5, int6, int7, reset, clock);

   // ADM3A dumb terminal
   terminal adm3a(addr[0], data, writeio, readio, trmsel, r, g, b, hsync_n, vsync_n,
                  ps2_clk, ps2_data, reset, clock, diag);

   // generate reset
   assign reset = !reset_n;

   // pull up or down unused lines
   assign int0 = 0;
   assign int1 = 0;
   assign int2 = 0;
   assign int3 = 0;
   assign int4 = 0;
   assign int5 = 0;
   assign int6 = 0;
   assign int7 = 0;
   assign waitr = 0;

endmodule

////////////////////////////////////////////////////////////////////////////////
//
// Peripheral select unit
//
// This block implements a general purpose select generator. It has 4 select
// units, each capable of matching up to 6 bits of address, or 1kb of address
// resolution. The length and base address of each generated select can be
// specified, and each select can be mapped either to memory or I/O. In the case
// of I/O, the match for the select takes place on the lower 8 bits of the
// address, corresponding to the 0-255 addresses in the I/O space.
// Note that the selects must still be qualified with readmem, writemem,
// readio and writeio signals at the selected peripheral.
//
// The selector itself has an I/O address of 0, but this can be moved as well.
// However, the selector must remain in I/O space.
//
// A special "bootstrap" mode is implemented. After power on, and until the
// selector is configured by the processor, both select1 and select2 will be
// active, along with the output signal bootstrap. These should be connected as
// follows:
//
// select1:   Connect to bootstrap ROM
// select2:   Connect to RAM
// bootstrap: Connect to RAM output buffers to disable them when true
//
// In bootstrap mode, ROM and RAM selects are on until the bootstrap mode is
// turned off by a CPU I/O operation. The bootstrap signal indicates that 
// bootstrap mode is active, and should be used to disable the RAM output 
// buffers.
//
// Because the ROM does not perform writes, and the RAM is disabled from reads,
// the RAM will overlay the ROM in memory, with the ROM providing read data,
// and the RAM accepting write data. This is sometimes called "shadow mode".
// What it does is allow the CPU to copy the ROM to RAM by performing a block
// read and write to the same address, ie., it picks up the content at each
// address, then writes it back, effectively copying the ROM contents to the
// RAM. The CPU can then program the selects, exit bootstrap mode, and then
// execute entirely from the RAM copy of the bootstrap ROM.
//
// Bootstrapping this way accomplishes a few ends. First, because memory
// is limited on a 64kb machine, it allows RAM to occupy all of memory, without
// having to reserve a block of space permanently for the boostrap ROM. Second,
// ROM is usually a lot slower than RAM nowdays, so it is common to want to
// run from RAM instead of trying to execute directly from ROM.
//
// The reason that we gate the RAM output buffers with the bootstrap signal,
// instead of trying to gate the select signal with readmem, is that the latter
// would generate glitches, since the readmem signal is enveloped by the 
// address, instead of vice versa. It also gives the RAM logic a chance to cut
// down on the delay of readmem to output drive enable.
//
// The Format of the registers in the select unit are:
//
//    7 6 5 4 3 2 1 0
// 0: C C C C X X X B - Main control register
// 1: X X X X X X X X - Unused
// 2: M M M M M M I E - Select 1 mask
// 3: C C C C C C X X - Select 1 compare
// 4: M M M M M M I E - Select 2 mask
// 5: C C C C C C X X - Select 2 compare
// 6: M M M M M M I E - Select 3 mask
// 7: C C C C C C X X - Select 3 compare
// 8: M M M M M M I E - Select 4 mask
// 9: C C C C C C X X - Select 4 compare
//
// The main control bits 7:4 contain the one of 16 base addresses for the
// select controller. It occupies 16 locations in the address space, of
// which only 9 are actually used. The compare bits reset to 0, so that the
// select unit occupies the I/O addresses $00-$0A on power up. The base address
// can be changed by writing the main control register, and the new address will
// take place on the next access. The select unit can only be addressed in the
// I/O space.
//
// The bootstrap bit is reset to 1, and can be written to 0 to turn off 
// bootstrap mode.
//

module select(addr, data, readio, writeio, select1, select2, select3, select4,
              bootstrap, clock, reset);

   input [15:0] addr;      // CPU address
   inout [7:0]  data;      // CPU data bus
   input        readio;    // I/O read
   input        writeio;   // I/O write
   output       select1;   // select 1
   output       select2;   // select 1
   output       select3;   // select 1
   output       select4;   // select 1
   output       bootstrap; // bootstrap status
   input        clock;     // CPU clock
   input        reset;     // reset
   reg          bootstrap; // bootstrap mode

   reg [7:4]    seladr; // base I/O address of selector
   reg [7:0]    datai; // internal data

   assign selacc = seladr == addr[7:4]; // form selector access
   assign accmain = selacc && (addr[3:1] == 3'b000); // select main
   assign acca = selacc && (addr[3:1] == 3'b001); // select 1
   assign accb = selacc && (addr[3:1] == 3'b010); // select 2
   assign accc = selacc && (addr[3:1] == 3'b011); // select 3
   assign accd = selacc && (addr[3:1] == 3'b100); // select 4

   // Control access to main select unit address. This has to be clocked to
   // activate the address only after the cycle is over.
   always @(posedge clock)
      if (reset) begin

         seladr <= 4'b0; // clear master select
         bootstrap <= 1; // enable bootstrap mode

      end else if (writeio&accmain) begin

         seladr <= data[7:4]; // write master select
         bootstrap <= data[0]; // write bootstrap mode bit

      end else if (readio&accmain) 
         datai <= {seladr, 4'b0}; // read master select
   
   selectone selecta(addr, data, writeio, readio, acca, select1i, reset);
   selectone selectb(addr, data, writeio, readio, accb, select2i, reset);
   selectone selectc(addr, data, writeio, readio, accc, select3, reset);
   selectone selectd(addr, data, writeio, readio, accd, select4, reset);

   assign data = readio&accmain ? datai: 8'bz; // enable output data

   assign select1 = select1i | bootstrap; // enable select 1 via bootstrap
   assign select2 = select2i | bootstrap; // enable select 2 via bootstrap

endmodule

//
// Individual select cell.
//
// This cell contains the mask and compare registers for each address. It
// handles the write and read of these registers, and forms a select signal
// based on them.
//
// Each register pair has the appearance:
//
//    7 6 5 4 3 2 1 0 
//   ================
// 0: M M M M M M I E - Mask register.
// 1: C C C C C C X X - Compare register.
//
// The mask register selects which bits will be used to form the compare
// value. This can be used to select any size from the combinations:
//
// 1 1 1 1 1 1 - Any 1kb block of memory, or 4 I/O address bits.
// 1 1 1 1 1 0 - Any 2kb block of memory, or 8 I/O address bits.
// 1 1 1 1 0 0 - Any 4kb block of memory, or 16 I/O address bits.
// 1 1 1 0 0 0 - Any 8kb block of memory, or 32 I/O address bits.
// 1 1 0 0 0 0 - Any 16kb block of memory, or 64 I/O address bits.
// 1 0 0 0 0 0 - Any 32kb block of memory, or 128 I/O address bits.
// 0 0 0 0 0 0 - All 64kb of memory, or all 256 I/O addresses
//
// Each block must be on its size, so for example, a 16kb block can only
// be on one of 4 positions in memory. If you use a pattern that isn't
// listed above, you are on your own to figure out the consequences.
// The selector does not weed out bad combinations, and you can select
// multiple blocks at once.
//
// Each of the mask and compare bytes can be both read and written.
//
// Note that the lower bits of the compare register aren't used, and always
// return zero.
//
// On reset, the mask and compare registers are both set to zero, which leaves
// the select block disabled.
//

module selectone(addr, data, write, read, selectin, selectout, reset);

   input [15:0] addr;     // address to match, 6 bits
   inout [7:0] data;      // CPU data
   input       write;     // CPU write
   input       read;      // CPU read
   input       selectin;  // select for read/write
   output      selectout; // resulting select
   input       reset;     // reset

   reg  [7:0] mask;  // mask/control, 7:2 is mask, 1: I/O or /mem, 0: on/off
   reg  [7:2] comp;  // Compare value
   wire [5:0] iaddr; // multiplexed address
   reg  [7:0] datai; // data from output selector

   // select what part of address, upper or lower byte, we compare, based on
   // I/O or memory address
   assign iaddr = mask[1] ? addr[7:2]: addr[15:10];

   // Form select based on match
   assign selectout = ((iaddr & mask[7:2]) == comp) & mask[0];

   always @(addr, write, read, reset, selectin, data, comp, mask)
      if (reset) begin

      comp <= 6'b0; // clear registers
      mask <= 8'b0;

   end else if (write&selectin) begin

      if (addr[0]) comp <= data[7:2]; // write comparitor data
      else mask <= data; // write mask data

   end else begin

      if (addr[0]) datai <= {comp, 2'b0}; // read comparitor data
      else datai <= mask; // read mask data

   end

   assign data = read&selectin ? datai: 8'bz; // enable output data

endmodule

////////////////////////////////////////////////////////////////////////////////
//
// INTERRUPT CONTROLLER
//
// Implements an 8 input interrupt controller. Each of the 8 interrupt lines has
// selectable positive edge, negative edge, positive level, and negative level
// triggering. Interrupts can be masked, and can be examined for state even when
// they are masked. Each interrupt can be triggered under software control.
// The priority for interrupts is fixed, with 0 being the highest, and 7 being
// the lowest.
//
// The controller can be connected to I/O or memory addresses. The control
// registers appear as:
//
//     7 6 5 4 3 2 1 0
// 00: M M M M M M M M - Mask register
// 01: S S S S S S S S - Status register
// 02: A A A A A A A A - Active register
// 03: P P P P P P P P - Polarity register
// 04: E E E E E E E E - Edge enable register
// 05: B B B B B B B B - Vector base address
//
// The mask register indicates if the interrupt source is to generate an 
// interrupt. If the associated bit is 1, the interrupt is enabled, otherwise
// disabled.
//
// The status register indicates the current interrupt line status, for direct
// polling purposes.
//
// The active register is a flip/flop that goes to 1 anytime the trigger 
// condition is satisfied. A 1 in this register will cause an interrupt to 
// occur. If the mask for the interrupt is not enabled, the active bit will not
// be set no matter what the trigger states.
//
// The polarity register gives the line polarity that will trigger an interrupt.
// If the edge trigger bit is set, then the polarity indicates the resulting 
// line AFTER the trigger. For example, an edge trigger with a 1 in the polarity
// register indicates that the trigger is a positive edge trigger.
//
// The edge enable register places an edge detector on the line. This will
// cause the interrupt to be triggered when an appropriate edge indicated by the
// polarity occurs. The edge mode is selected by a 1 bit, and the level mode is
// selected by a 0 bit. If the level mode is selected, the interrupt will occur
// anytime the interrupt line matches the state of the polarity bit.
//
// The vector registers each provide the lower 8 bits of a 16 bit vector for 
// each interrupt.
//
// The base register provides the upper 8 bits of a 16 bit vector for each
// interrupt.
//
// An interrupt is generated anytime any bit is true in the active register. 
// The interrupt request line is set true, and the controller will hold until
// an interrupt acknowledge occurs. When an interrupt acknowledge occurs, the
// controller will cycle through a three step sequence, with each sequence
// activated by the interrupt acknowledge signal.
//
// First, a $cd is placed on the data lines, indicating a call instruction.
// Second, the number of the interrupt that is highest priority is multipled 
// * 4, and this is placed on the data lines.
// Third, the vector base address is placed on the data lines.
//
// The net result is that the CPU is vectored to one of 256 pages in the address
// space, with an offset of 4 bytes for each interrupt, as follows:
//
// 00: Vector 0
// 04: Vector 1
// 08: Vector 2
// 0C: Vector 3
// 10: Vector 4
// 14: Vector 5
// 18: Vector 6
// 1C: Vector 7
//

module intcontrol(addr, data, write, read, select, intr, inta, int0, int1, int2,
                  int3, int4, int5, int6, int7, reset, clock);

   input [2:0] addr;   // control register address
   inout [7:0] data;   // CPU data
   input       write;  // CPU write
   input       read;   // CPU read
   input       select; // controller select
   output      intr;   // interrupt request
   input       inta;   // interrupt acknowledge
   input       int0;   // interrupt line 0
   input       int1;   // interrupt line 1
   input       int2;   // interrupt line 2
   input       int3;   // interrupt line 3
   input       int4;   // interrupt line 4
   input       int5;   // interrupt line 5
   input       int6;   // interrupt line 6
   input       int7;   // interrupt line 7
   input       reset;  // CPU reset
   input       clock;  // CPU clock

   reg [7:0] mask;     // interrupt mask register
   reg [7:0] active;   // interrupt active register
   reg [7:0] polarity; // interrupt polarity register
   reg [7:0] edges;    // interrupt edge control
   reg [7:0] vbase;    // vector base
   reg [7:0] intpe;    // positive edge interrupt detection
   reg [7:0] intne;    // negative edge interrupt detection
   reg [7:0] datai; // data from output selector
   reg [3:0] state; // state machine to run vectors
    
   wire [7:0] activep;  // interrupt active pending

   // handle register reads and writes  

   always @(negedge clock)
      if (reset) begin // reset

      mask     <= 8'b0; // clear mask
      active   <= 8'b0; // clear active
      polarity <= 8'b0; // clear polarity
      edges    <= 8'b0; // clear edge
      vbase    <= 8'b0; // clear base
      state    <= 4'b0; // clear state machine

   end else if (write&select) begin // CPU write

      case (addr)

         0: mask     <= data; // set mask register
         2: active   <= data|activep; // set active register
         3: polarity <= data; // set polarity register
         4: edges    <= data; // set edge register
         5: vbase    <= data; // set base register

      endcase

   end else if (read&select) begin // CPU read

      case (addr)

         0: datai <= mask; // get mask register
         // get current line statuses
         1: datai <= { int7, int6, int5, int4, int3, int2, int1, int0 };
         2: datai <= active; // get active register
         3: datai <= polarity; // get polarity register
         4: datai <= edges; // get edge register
         5: datai <= vbase; // get base register

      endcase

   end else if (inta) begin // CPU interrupt acknowledge 

      // run vectoring state machine
      case (state)

         // wait for inta, and assert 1st instruction byte

         0: begin

            datai <= 8'hcd; // place call instruction on datalines
            state <= 1; // advance to low address

         end

         // assert low byte address
         1: begin
         
            // decode priority
            if (active&8'h01)      datai <= 8'h00;
            else if (active&8'h02) datai <= 8'h04;
            else if (active&8'h04) datai <= 8'h08;
            else if (active&8'h08) datai <= 8'h0C;
            else if (active&8'h10) datai <= 8'h10;
            else if (active&8'h20) datai <= 8'h14;
            else if (active&8'h40) datai <= 8'h18;
            else if (active&8'h80) datai <= 8'h1C;
            state <= 2; // advance to high address
         
         end
         
         // assert high address
         2: if (inta) begin
         
            datai <= vbase; // place page to vector
            // reset highest priority interrupt
            if (active&8'h01)      active[0] <= activep[0];
            else if (active&8'h02) active[1] <= activep[1];
            else if (active&8'h04) active[2] <= activep[2];
            else if (active&8'h08) active[3] <= activep[3];
            else if (active&8'h10) active[4] <= activep[4];
            else if (active&8'h20) active[5] <= activep[5];
            else if (active&8'h40) active[6] <= activep[6];
            else if (active&8'h80) active[7] <= activep[7];
            state <= 0; // back to start state
         
         end

      endcase

   end else active <= active|activep; // set active interrupts
      
   // form active interrupt bits
   assign activep = mask & (({ int7, int6, int5, int4, // levels
                               int3, int2, int1, int0 }^polarity & ~edges)|
                           (intpe&polarity&edges)| // positive edges
                           (intne&~polarity&edges)); // negative edges
   
   // form interrupt edges
   always @(posedge int0) intpe[0] <= 1;
   always @(posedge int1) intpe[1] <= 1;
   always @(posedge int2) intpe[2] <= 1;
   always @(posedge int3) intpe[3] <= 1;
   always @(posedge int4) intpe[4] <= 1;
   always @(posedge int5) intpe[5] <= 1;
   always @(posedge int6) intpe[6] <= 1;
   always @(posedge int7) intpe[7] <= 1;
   always @(negedge int0) intne[0] <= 1;
   always @(negedge int1) intne[1] <= 1;
   always @(negedge int2) intne[2] <= 1;
   always @(negedge int3) intne[3] <= 1;
   always @(negedge int4) intne[4] <= 1;
   always @(negedge int5) intne[5] <= 1;
   always @(negedge int6) intne[6] <= 1;
   always @(negedge int7) intne[7] <= 1;

   assign data = read&select|inta ? datai: 8'bz; // enable output data
   assign intr = |active; // request interrupt on any active

endmodule
        
////////////////////////////////////////////////////////////////////////////////
//
// ROM CELL
//
// Hold the test instructions. Forms a simple read only cell, with tri-state
// enable outputs only.
//

module rom(addr, data, dataeno);

   input [10:0] addr;
   inout [7:0] data;
   input dataeno;

   reg [7:0] datao;

   always @(addr) case (addr)

      `include "test.rom" // get contents of memory
     
      default datao = 8'h76; // hlt
   
   endcase

   // Enable drive for data output
   assign data = dataeno ? datao: 8'bz;
   
endmodule

////////////////////////////////////////////////////////////////////////////////
//
// RAM CELL
//
// A clocked ram cell with individual select, read and write signals. Data is
// written on the positive edge when write is true. Data is enabled for output
// by the read signal asyncronously.
//
// A bootstrap mode is implemented that, when true, overrides the read signal
// and keeps the output drivers off.
//

module ram(addr, data, select, read, write, bootstrap, clock);

   input [9:0] addr;
   inout [7:0] data;
   input select;
   input read;
   input write;
   input clock;
   input bootstrap;

   reg [7:0] ramcore [1023:0]; // The ram store
   reg [7:0] datao;
   
   always @(negedge clock) 
      if (select) begin

         if (write) ramcore[addr] <= data;
         datao <= ramcore[addr];

      end

   // Enable drive for data output
   assign data = (select&read&~bootstrap) ? datao: 8'bz;
   
endmodule
