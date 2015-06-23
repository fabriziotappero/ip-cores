// Author: Mehdi SEBBANE
// May 2002
// Verilog model
// project: M25P20 25 MHz,
// release: 1.4.1



// These Verilog HDL models are provided "as is" without warranty
// of any kind, included but not limited to, implied warranty
// of merchantability and fitness for a particular purpose.





`timescale  1ns/1ns

`define SIZE               2097152     // 2Mbit
`define PLENGTH            256         // page length
`define SSIZE              524288      // Sector size
`define NB_BPI             2           // number of BPi bits
`define SIGNATURE          8'b00010001 // electronic signature
`define BIT_TO_CODE_MEM    18          // number of bit to code a 2Mbits memory
`define LSB_TO_CODE_PAGE   8           // number of bit to code a PLENGTH page

`define NB_BIT_ADD_MEM              24
`define NB_BIT_ADD                  8
`define NB_BIT_DATA                 8
`define TOP_MEM                     (`SIZE/`NB_BIT_DATA)-1

`define MASK_SECTOR        24'hFF0000   // anded with address to find first sector adress to erase

`define   TRUE    1'b1
`define   FALSE   1'b0


`define TC     40          // Minimum Clock period
`define TR     50          // Minimum Clock period for read instruction
`define TSLCH  10          // notS active setup time (relative to C)
`define TCHSL  10          // notS not active hold time
`define TCH    18          // Clock high time
`define TCL    18          // Clock low time
`define TDVCH  5           // Data in Setup Time
`define TCHDX  5           // Data in Hold Time
`define TCHSH  10          // notS active hold time (relative to C)
`define TSHCH  10          // notS not active setup  time (relative to C)
`define TSHSL  100            // /S deselect time
`define TSHQZ  15          // Output disable Time
`define TCLQV  15          // clock low to output valid
`define THLCH  10          // NotHold active setup time
`define TCHHH  10          // NotHold not active hold time
`define THHCH  10          // NotHold not active setup time
`define TCHHL  10          // NotHold active hold time
`define THHQX  15          // NotHold high to Output Low-Z
`define THLQZ  20          // NotHold low to Output High-Z
`define TDP    3000        // notS high to deep power down mode
`define TRES1  3000        // notS high to Stand-By power mode w-o ID Read
`define TRES2  1800        // notS high to Stand-By power mode with ID Read
//`define TW     15000000    // write status register cycle time (15ms)
//`define TPP    5000000         // page program cycle time (5ms)
//`define TSE    3000000000      // sector erase cycle time (3s)
//`define TBE    6000000000      // bulk erase cycle time (6s)
`define TW     15000         // write status register cycle time (.015ms)
`define TPP    5000         // page program cycle time (.005ms)
`define TSE    30000      // sector erase cycle time (.00003s)
`define TBE    60000      // bulk erase cycle time (.00006s)
