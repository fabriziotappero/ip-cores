# Copyright 2013, Sinclair R.F., Inc.
#
# Validate the fetchs from the ROM at bank 2.

/fetch2/ {
  ix = strtonum("0x" $6);
  y  = strtonum("0x" $7);
  if (y != xor(0x5A,xor(ix,ix/2)))
    print;
}
