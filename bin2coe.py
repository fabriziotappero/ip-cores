#!/usr/bin/python

import sys
from array import *
import os

from stat import *

def main():
  print 'memory_initialization_radix=16;'
  print 'memory_initialization_vector='
  
  num = sys.argv[2]
  if num == '': 
    num = '1'

  if num == '4': 
    x = array('L')
  elif num == '2': 
    x = array('H')
  else: 
    x = array('B')

  f = open(sys.argv[1], 'rb')
  x.fromfile(f, os.stat(sys.argv[1])[ST_SIZE]/int(num))

  first = 1
  for el in x:
    if not first: 
      print ','
    else:
      first = 0
    sys.stdout.write('%02x' % el)

  print ';'  

if __name__ == "__main__":
    main()

