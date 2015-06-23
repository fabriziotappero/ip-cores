//sata_defines.v
/*
Distributed under the MIT license.
Copyright (c) 2011 Dave McCoy (dave.mccoy@cospandesign.com)

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

`ifndef __SATA_DEFINES__
`define __SATA_DEFINES__

//Presuming 75MHz clock
`define CLOCK_RATE            (75000000)
// 1 / 880uS = 1136 times per seconds
`define NORMAL_TIMEOUT        (1000000) / 880

//Input/Output buffer sizes
`define DATA_SIZE             32
//2048 dwords
`define FIFO_ADDRESS_WIDTH    11

//880uS
//`define INITIALIZE_TIMEOUT    ((`CLOCK_RATE) / (`NORMAL_TIMEOUT))
`define INITIALIZE_TIMEOUT    66000
//`define SEND_WAKE_TIMEOUT     4E

`define PRIM_ALIGN            32'h7B4A4ABC
`define PRIM_SYNC             32'hB5B5957C
`define PRIM_R_RDY            32'h4A4A957C
`define PRIM_R_IP             32'h5555B57C
`define PRIM_R_OK             32'h3535B57C
`define PRIM_R_ERR            32'h5656B57C
`define PRIM_SOF              32'h3737B57C
`define PRIM_EOF              32'hD5D5B57C
`define PRIM_X_RDY            32'h5757B57C
`define PRIM_WTRM             32'h5858B57C
`define PRIM_CONT             32'h9999AA7C
`define PRIM_HOLD             32'hD5D5AA7C
`define PRIM_HOLDA            32'h9595AA7C
`define PRIM_PMNACK           32'hF5F5957C
`define PRIM_PMACK            32'h9595957C
`define PRIM_PREQ_P           32'h1717B57C
`define PRIM_PREQ_S           32'h7575957C


`define DIALTONE              32'h4A4A4A4A


//FIS Types
`define FIS_H2D_REG           8'h27
`define FIS_D2H_REG           8'h34
`define FIS_DMA_ACT           8'h39
`define FIS_DMA_SETUP         8'h41
`define FIS_DATA              8'h46
`define FIS_BIST              8'h58
`define FIS_PIO_SETUP         8'h5F
`define FIS_SET_DEV_BITS      8'hA1

//Transport Data Direction
`define DATA_OUT              0
`define DATA_IN               1

//Command Types
`define COMMAND_DMA_READ_EX     8'h25
`define COMMAND_DMA_WRITE_EX    8'h35
`define COMMAND_NOP             8'h00
`define COMMNAD_IDENTIFY_DEVICE 8'hEC

//Sizes
`define FIS_H2D_REG_SIZE        24'h5
`define FIS_D2H_REG_SIZE        24'h5
`define FIS_PIO_SETUP_SIZE      24'h5
`define FIS_DMA_SETUP_SIZE      24'h7
`define FIS_DMA_ACT_SIZE        24'h1
`define FIS_SET_DEV_BITS_SIZE   24'h2

//Register FIS Bits
`define STATUS_BUSY_BIT       7
`define STATUS_DRQ_BIT        3
`define STATUS_ERR_BIT        0


`define CONTROL_SRST_BIT      2

`define H2D_REG_COMMAND       1
`define H2D_REG_CONTROL       0

//Not really sure what to put in the features register
`define D2H_REG_FEATURES      16'h0000
`define D2H_REG_DEVICE        8'h40

`define D2H_REG_DRQ           1
`define D2H_REG_ERR           1


`endif
