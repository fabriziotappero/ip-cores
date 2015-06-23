# Copyright 2013, Sinclair R.F., Inc.
#
# Initialize the ROMs with gray-coded values and slightly altered gray-coded
# values.

BEGIN {
  print ".memory ROM rom_z";
  print ".variable z";
  for (i=0; i<SIZE_Z; ++i)
    printf("  0x%02X\n",xor(i,i/2));
  print ".memory ROM rom_y";
  print ".variable y";
  for (i=0; i<SIZE_Y; ++i)
    printf("  0x%02X\n",xor(0x5A,xor(i,i/2)));
  print ".memory ROM rom_x";
  print ".variable x";
  for (i=0; i<SIZE_X; ++i)
    printf("  0x%02X\n",xor(0x69,xor(i,i/2)));
  print ".memory ROM rom_w";
  print ".variable w";
  for (i=0; i<SIZE_W; ++i)
    printf("  0x%02X\n",xor(0x3C,xor(i,i/2)));
}
