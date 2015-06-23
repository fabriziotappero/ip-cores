<!-- comment block 
// Copyright (c) 2005 Guy Hutchison (ghutchis@opencores.org)
//
// Permission is hereby granted, free of charge, to any person obtaining a 
// copy of this software and associated documentation files (the "Software"), 
// to deal in the Software without restriction, including without limitation 
// the rights to use, copy, modify, merge, publish, distribute, sublicense, 
// and/or sell copies of the Software, and to permit persons to whom the 
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included 
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

//  IO-interface:
//    R0  -  Status register
//    R1  -  Control register
//    R2  -  RX Length (low)
//    R3  -  RX Length (high)
//    R4  -  RX Data
//    R5  -  TX Data
//    R6  -  Configuration

//  Status bits:
//    [0]     RX Packet Ready
//    [1]     TX Transmit Complete

//  Control bits:
//    [0]     Send TX Packet
  -->
<tv_registers name="simple_gmii_regs" addr_sz="8" base_addr="8">
  <register name="status"  type="int_fixed" width="2" int_value="8'hcf" default="0">
    Interrupt register, vector is set to "RST 8" instruction
  </register>
  <register name="control" type="soft_set" width="1" default="0"/>
  <register name="rx_len0"  width="8" type="status"/>
  <register name="rx_len1"  width="8" type="status"/>
  <register name="rx_data"  width="8" type="read_stb"/>
  <register name="tx_data"  width="8" type="write_stb"/>
  <register name="config"   width="1" type="config" default="0"/>
</tv_registers>
