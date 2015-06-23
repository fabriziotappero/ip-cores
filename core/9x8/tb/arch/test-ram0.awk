# Copyright 2013, Sinclair R.F., Inc.
#
# Validate the fetchs from the RAM at bank 0.

/fetch0/ {
  ix = strtonum("0x" $6);
  y  = strtonum("0x" $7);
  if (y != xor(0x5A,ix))
    print;
}
