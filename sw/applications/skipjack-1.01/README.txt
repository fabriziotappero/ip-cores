// 45678901234567890123456789012345678901234567890123456789012345678901234567890
Bob Hayes -- August 10, 2010

  SKIPJACK ENCRYPT/DECRYPT for xgate RISC processor core
  
  Version 0.1 Basic SKIPJACK Encrypt and Decrypt modules for the Xgate
   processor. These routines do the basic codebook encrypt and decrypt
   functions, other modes of use such as output feedback,cipher feedback and
   cipher block chaining can be added at the host code level or the routines
   could be expanded to incorporate the required functionality.

  This implementation is believed to be compliant with the SKIPJACK algorithm
   as described in "SKIPJACK and KEA Algorithm Specifications" Version 2.0
   dated 29 May 1998, which is available from the National Institute for
   Standards and Technology: 
     http://csrc.nist.gov/groups/STM/cavp/documents/skipjack/skipjack.pdf
 
  The algorithm encrypts a 64 bit block of data with an 80 bit key running
   through the encryption loop 32 times. The encrypt/decrypt function has been
   verified by running the key and plain text and cypher test given in the
   specification document.(Some have noted that this only verifies about half
   of the entries in the F Table.)
   
  Basic encryption process takes approx. 6468 cycles
  Basic decryption process takes approx. 6786 cycles
  
 The code has several sections that are only needed for the Verilog test bench
  and can be deleted in normal use. There is also some additional initialization
  code that only needs to be done once and could be replaced by the host putting
  the correct values in the appropriate RAM locations. These sections are marked
  in the code. The starting address of the F Table in memory shouldn't be critical
  although starting on a 256 byte boundary is convenient for debugging. The
  algorithm variables use 8 bit address offset calculations so care should be
  taken if the key is saved in a memory range that crosses an 8 bit addressing
  boundary. The G function is coded as a subroutine that is called twice, some
  speed could be gained if this code is placed in-line at the expense of a
  small increase in code size.


