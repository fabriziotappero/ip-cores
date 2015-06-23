# PATLPP Assembler

import sys

if (len(sys.argv) < 2):
	print 'Usage: pasm <input file> [output file]'
	exit()

infilename = sys.argv[1]
if (len(sys.argv) > 2): outfilename = sys.argv[2]
else: outfilename = "out.v"
	
infile = open(sys.argv[1])
pc = 0
labels = dict()

for line in infile:
	line = line.strip()
	
	if line.startswith(('IN(','OUT(','BYP(','CSA(','CSC(','JMP(','RST(','ADD(','SUB(','MOV(','SRAP2R(')):
		pc += 1
	elif line.startswith('#:'):
		print "// ", line
		label = line[2:]
		label = label.strip(' ')
		labels[label] = pc

print "// labels: ", labels
execfile(sys.argv[1], labels)