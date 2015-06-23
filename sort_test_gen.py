#!/usr/bin/python
#
# This Python script generates the input patterns for the sorter
# It also generates the sys_config.vhd file with constants
# describing structure of data records
#
# You can customize constants below
key_width = 8 # Width of the key part of the record
pay_width = 4 # Width of the payload part of the record
max_dist = 63 # Maximum distance between unsorted records
seq_len = 2000 # Length of the generated sequence
sort_debug = "true" #uncomment this, or the next line
sort_debug = "false" #alwayse set sort_debug to false for synthesis!
#
# The algorithm is very simple - we just generate the sequence
# of records with continuously increasing key numbers
# Then we increase the key number in each record by the random
# number, taken from the range: [0,max_dist]
import math
import sys
# calculate necessary amount of levels in the sorter
sys_nlevels=1
nrec=4
while nrec<max_dist+1:
  sys_nlevels+=1
  nrec*=2
# Sorter capacity and sorter latency is equal to nrec-1
latency=nrec-1
# When checking if the sorter key width is sufficient, we must
# consider, that in the worst key we may need to compare
# samples with keys differing by latency+max_dist
#
# Check if the settings are correct
if max_dist+latency > ((1<<(key_width-1))-1):
   print "Too high maximum distance between unsorted records"
   print "for defined width of the sort key. Please increase"
   print "the key_width value in the sort_test_gen.py file!"
   sys.exit(1)
# Then we prepare the VHDL file with system configuration
sc=open('src/sys_config.vhd','w')
l="library ieee;\n"
l+="use ieee.std_logic_1164.all;\n"
l+="library work;\n"
l+="package sys_config is\n"
l+="  constant SORT_DEBUG              : boolean :="+sort_debug+";\n"
l+="  constant SYS_NLEVELS             : integer :="+str(sys_nlevels)+";\n"
l+="  constant DATA_REC_SORT_KEY_WIDTH : integer :="+str(key_width)+";\n"
l+="  constant DATA_REC_PAYLOAD_WIDTH  : integer :="+str(pay_width)+";\n"
l+="end sys_config;\n"
sc.write(l)
sc.close()
# Generate the input patterns
fo=open('events.in','w')
t=range(1,seq_len+1)
import random
r=random.Random()
r.seed()
t2=[i+r.randint(0,max_dist) for i in t]
# Now let's prepare the input events:
key_format="{0:0"+str(key_width)+"b}"
pay_format="{0:0"+str(pay_width)+"b}"
for i in t2:
  j = i & ((1<<key_width)-1) #Truncate the key to the set width
  l = "01 " + key_format.format(j) + " " + pay_format.format(0)
  fo.write(l+"\n")
# Now let's print necessary number of end records
for i in range(0,nrec):
  l = "11 " + key_format.format(0) + " " + pay_format.format(0)
  fo.write(l+"\n")
fo.close()
