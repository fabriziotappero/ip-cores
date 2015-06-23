# Copyright 2013, Sinclair R.F., Inc.
#
# Initialize the ROM with gray-coded values

BEGIN {
  print ".memory ROM rom_z";
  print ".variable z";
  for (i=0; i<SIZE_Z; ++i) {
    printf("  0x%02X\n",xor(i,i/2));
  }
}
