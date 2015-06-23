#!/usr/bin/python
import sys

from subprocess import call
from time import sleep

if len(sys.argv) < 3:
  print("Usage: ./loopsys ntimes 'command line'")
  exit()

nn = int(sys.argv[1])
ss = sys.argv[2]

for ii in range(nn):
    print(' Executing \"' + ss +'\" ' + str(nn-ii) + ' times')
    call(ss,shell=True)
    sleep(1)	
