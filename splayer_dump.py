#!/usr/bin/python

import sys

ii=0
for pline in sys.stdin:
	try:
		if ii%8 == 0:
			print(hex(ii).zfill(6) + ': '),
        	line = pline.split('HEX ')[1][:8]
		print(line),
		ii += 1
		if ii%8 == 0:
			print('')
	except:
		exit()
