#!/usr/bin/python
# This Python script checks if the records were sorted
# correctly...
import sys
# We read the input records and store them in one vector
fi=open("events.in","r")
ri=fi.read().split("\n")
ri=[i.split(" ") for i in ri]
# Leave only valid records
ri=[i for i in ri if len(i)==3 and i[0]=="01"]
# We read the output vectors and store them in a second vector
fo=open("events.out","r")
ro=fo.read().split("\n")
ro=[i.split(" ") for i in ro ]
# Leave only valid records
ro=[i for i in ro if len(i)==3 and i[0]=="01"]
# We check if the output vectors are correctly sorted
for i in range(1,len(ro)):
  # Theoretically we could simply check the condition:
  # int(ro[i-1][1],2) <= int(ro[i][1],2)
  # However for longer sequences we may need to 
  # consider the fact that sort keys (time stamps)
  # will wrap around.
  # Therefore we need to perform slightly more 
  # complicated test - if we use N bits to store
  # the sort key, then we need to subtract keys modulo
  # 2**N and if the difference is in range (0,2**(N-1)]
  # we consider the difference positive, while in range
  # (2**(N-1),(2**N)-1) we consider it negative.
  k1 = ro[i-1][1]
  k2 = ro[i][1]
  dlim = 1<<len(k1)
  diff=(int(k2,2)-int(k1,2)) % dlim
  if diff > dlim/2: 
     print "Records unsorted!\n"
     print str(i-1)+": "+str(ro[i-1])
     print str(i)+": "+str(ro[i])
     sys.exit(1)
# We check if all input vectors were transferred to the output
# Now we only check size of vectors
if len(ro) != len(ri):
    print "Not all records transferred!\n"
    sys.exit(1)
print "Test passed!\n"
sys.exit(0)

