// Author: Hugues CREUSY modified by Xue feng
// June 2004
// Verilog model
// project: M25P16 50 MHz,
// release: 1.2



// These Verilog HDL models are provided "as is" without warranty
// of any kind, included but not limited to, implied warranty
// of merchantability and fitness for a particular purpose.





`timescale  1ns/1ns

`define SIZE               4194304*4   // 16 Mbit
`define PLENGTH            256         // page length 256 bytes
`define SSIZE              524288      // Sector size 512 kbits
`define NB_BPI             3           // number of BPi bits
`define SIGNATURE          8'h14       // electronic signature 14h
`define manufacturerID  8'h20         // Manufacturer ID
`define memtype            8'h20         // memorytype
`define density               8'h15         // memory density 16mbits
`define BIT_TO_CODE_MEM    21          // number of bit to code a 16Mbits memory
`define LSB_TO_CODE_PAGE   8           // number of bit to code a PLENGTH page

`define NB_BIT_ADD_MEM              24
`define NB_BIT_ADD                  8
`define NB_BIT_DATA                 8
`define TOP_MEM                     (`SIZE/`NB_BIT_DATA)-1

`define MASK_SECTOR        24'hFF0000   // anded with address to find first sector adress to erase

`define   TRUE    1'b1
`define   FALSE   1'b0


`define TC     20          // Minimum Clock period
`define TR     50          // Minimum Clock period for read instruction
`define TSLCH  5          // notS active setup time (relative to C)
`define TCHSL  5          // notS not active hold time
`define TCH    9          // Clock high time
`define TCL    9          // Clock low time
`define TDVCH  2           // Data in Setup Time
`define TCHDX  5           // Data in Hold Time
`define TCHSH  5          // notS active hold time (relative to C)
`define TSHCH  5          // notS not active setup  time (relative to C)
`define TSHSL  100            // /S deselect time
`define TSHQZ  8          // Output disable Time
`define TCLQV  8          // clock low to output valid
`define THLCH  5          // NotHold active setup time
`define TCHHH  5          // NotHold not active hold time
`define THHCH  5          // NotHold not active setup time
`define TCHHL  5          // NotHold active hold time
`define THHQX  8          // NotHold high to Output Low-Z
`define THLQZ  8          // NotHold low to Output High-Z
`define TWHSL  20          // Write protect setup time (SRWD=1)
`define TSHWL  100         // Write protect hold time (SRWD=1)
`define TDP    3000        // notS high to deep power down mode
`define TRES1  30000        // notS high to Stand-By power mode w-o ID Read
`define TRES2  30000        // notS high to Stand-By power mode with ID Read
`define TW     15000000    // write status register cycle time (15ms)
`define TPP    5000000     // page program cycle time (5ms)
`define TSE    3      // sector erase cycle time (3s)
`define TBE   40     // bulk erase cycle time (40s)
`define Tbase  1000000000  // time base for Bulk and Sector ERASE, delay function limited to signed 32bits values 