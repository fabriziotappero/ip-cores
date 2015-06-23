

Dual-use pins in test mode:


scanin 	 -> dsurx
scanout	 -> dsutx
scanen	 -> dsubre
testrst  -> dsuen
inoutct  -> rxd1
testmode -> test
scanclk  -> clk


Memory tests
------------

All on-chip RAM blocks are tested by writing and checking
the following values: 0x55555555, 0xAAAAAAAA, address pattern.
This will insure that all bits are tested to both 0 and 1,
and that the address decoder is tested. Additional patterns
can be added but will result in increased number of test
vectors.
