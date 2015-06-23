// Paul Hartke, phartke@stanford.edu,  Copyright (c)2002
//
// The information and description contained herein is the
// property of Paul Hartke.
//
// Permission is granted for any reuse of this information
// and description as long as this copyright notice is
// preserved.  Modifications may be made as long as this
// notice is preserved.
// This code is made available "as is".  There is no warranty,
// so use it at your own risk.
// Documentation? "Use the source, Luke!"

sha1_readme.txt  version 0.1
Paul Hartke
phartke@stanford.edu
September 28, 2002

SHA-1 is defined in NIST FIPS 180-2, Secure Hash Standard 
(SHS), August 2002. However, William Stalling's 
"Cryptography and Network Security, Principles and Practice, 
2nd Ed." has a very through description and is an all 
around great crypto book.  

Files included in this distribution are: 
sha1_testbench.v
  -- Testbench with vectors from NIST FIPS 180-2
sha1_exec.v
  -- Top level sha1 module
sha1_round.v
  -- primitive sha1 round
dffhr.v
  -- generic parameterizable D-flip flop library

Performance Analysis
Performance equation of core is 
frequency in MHz * (512bits/block) / (81 rounds/block).  The 
cycle time is approximately 9.0ns for Xilinx xc2vp7-ff896-7 
FPGA which results in 700 Mbps processing rate.
Note: This calculation ignores the effect of a partially full 
last block

Finally, Padding, HMAC, and bus interface functionality is not 
provided.  These will vary with the particular system design.

The core size is about 800 Xilinx Virtex II FPGA Family Slices.

I welcome feedback on any aspects of this design.

