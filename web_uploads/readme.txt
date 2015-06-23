
I/O inputs -

Inputs :

datain (8 bits) = serial input where message data is fed. If the message polynomial of form,
         d_nX^n + d_(n-1)X^(n-1) + ......etc., then d_n followed by d_(n-1) in the next 
         clock cyle, .....etc. datain should contain a new message byte at every clock cycle
         as long as the valid is high.

gin0.....gin15 (8 bits each ) = Generator polynomial co-effcients. The generator polynomial
                              is form X^16+gin15X^15+gin14X^14+ ......gin1X+gin0.

valid = Pull high when data becomes available. Pull low when all message bytes (total of 239 
        bytes) has been entered. By pulling valid low the contents of the registers are freezed.
        Pull high when the next block (239 bytes) of message data is available.

clkin = input clock.

rst = reset signal to initialize registers (to all zeros).

Outputs :

q0....q15 (8 bits each) : Parity bytes in the polynomial form, 
                         q15X^15+q14X^14+ ......q0. Latch externally if required. Valid as long
                         as valid signal is low.

 
