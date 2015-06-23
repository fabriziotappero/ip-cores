# Copyright 2013, Sinclair R.F., Inc.
#
# Validate the fetchs from the ROM at bank 0.

/fetch0/ {
  ix = strtonum("0x" $6);
  y  = strtonum("0x" $7);
  if (y != xor(0x3C,xor(ix,ix/2)))
    print;
}
