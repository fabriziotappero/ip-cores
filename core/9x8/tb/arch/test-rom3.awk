# Copyright 2013, Sinclair R.F., Inc.
#
# Validate the fetchs from the ROM at bank 3.

/fetch3/ {
  ix = strtonum("0x" $6);
  y  = strtonum("0x" $7);
  if (y != xor(ix,ix/2))
    print;
}
