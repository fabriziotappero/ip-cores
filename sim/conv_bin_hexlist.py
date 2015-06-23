#!/usr/bin/python
import struct
import sys

fi = open(sys.argv[1], 'rb')
fo = open(sys.argv[2], 'wt')
fibyte = fi.read()
for i in range(len(fibyte)):
	u = struct.unpack('B', fibyte[i])
	fo.write('{0:02x}\n'.format(u[0]))

#close(fi)
#close(fo)

