#!/sbin/python

# Marius TIVADAR (c) Feb, 2009

RED = 'R'
BLUE = 'B'
INDENT = 4
DIAG = {0: 'ZEROP', 1: 'DOWN45P', 2: 'DOWN', 3: 'DOWN45M', 4: 'ZEROM', 5: 'UP45M', 6:'UP', 7: 'UP45P'}

def write_equations(qq, sq):
	# C squares

	C = [['' for z in range(8)] for q in range(len(qq))]
	axes = [(1, 1), (1, -1), (-1,-1), (-1,1), (0,1), (1,0), (-1,0), (0, -1)]
#	axes = [(0,1)]

	for k in range(len(qq)):                  # pentru toate pozitiile din lista
	  _C = ['']*len(qq)
	  for m in range(len(axes)):              # toate directiile
		 for i in range(0,8):             # dimensiunea tablei de joc
			_C[k] = '';
			x = qq[k][0]
			y = qq[k][1]

			for j in range(0, i):
				 x += axes[m][0]
				 y += axes[m][1]
				 if ((x >= 0 and x < 8) and (y >= 0 and y < 8)):
					  _C[k] += '%(red)s[%(i)d*8 + %(j)d] && ' %{'red':RED, 'i': x,     'j': y}
				 else:
					  _C[k] = ''
	  
			# AND cu player, pentru a flanca
			x += axes[m][0]
			y += axes[m][1]

                        if ((x >= 0 and x < 8) and (y >= 0 and y < 8)):
                             if _C[k]:
				 _C[k] += '%(blue)s[%(i)d*8 + %(j)d]'% {'blue': BLUE, 'i': x,     'j': y}
			# generez SAU
				 C[k][m] += _C[k].join('()') +  ' ||' + '\n'


	for k in range(0,len(qq)):
	   for m in range(len(axes)):
		   if C[k][m]:
			   g  =  ('(\n' + C[k][m].strip('||\n') + '\n);').split('\n')
			   C[k][m] = '\n'.join([' '*(13 + INDENT) + g[i] for i in  range(len(g))])
			   C[k][m] = ' '*INDENT + '%(map)s[%(i)d][%(j)d][%(direction)s] = (!%(red)s[%(i)d*8 + %(j)d] && !%(blue)s[%(i)d*8 + %(j)d]) && \n\n%(expr)s' %{'map':'M', 'i':qq[k][0], 'j':qq[k][1], 'direction':DIAG[m], 'red':RED, 'blue':BLUE, 'expr':C[k][m]}
                   else:
                           C[k][m] = ' '*INDENT + '%(map)s[%(i)d][%(j)d][%(direction)s] = 1\'b0;' %{'map':'M', 'i':qq[k][0], 'j':qq[k][1], 'direction':DIAG[m], 'red':RED, 'blue':BLUE}


        print '\n'
        print '// Expresii generate pentru patrate ' + sq
	for k in range(0,len(qq)):
		for m in range(len(axes)):
			if C[k][m]:
				print C[k][m]


write_equations([(0,0), (0,7), (7,7), (7,0)], 'A') # A
write_equations([(0,1), (0,6), (1,7), (6,7), (7,6), (7,1), (6,0), (1,0)], 'B') # B
write_equations([(0,2), (0,5), (2,7), (5,7), (7,5), (7,2), (5,0), (2,0)], 'C') # C
write_equations([(0,3), (0,4), (3,7), (4,7), (7,4), (7,3), (4,0), (3,0)], 'D') # D
write_equations([(1,1), (1,6), (6,6), (6,1)], 'E')                             # E
write_equations([(1,2), (1,5), (2,6), (5,6), (6,5), (6,2), (5,1), (2,1)], 'F') # F
write_equations([(1,3), (1,4), (3,6), (4,6), (6,4), (6,3), (4,1), (3,1)], 'G') # G
write_equations([(2,2), (2,5), (5,5), (5,2)], 'H')                             # H
write_equations([(2,3), (2,4), (3,5), (4,5), (5,4), (5,3), (4,2), (3,2)], 'I') # I

for c in [(3,3), (3,4), (4,3), (4,4)]:
    print ' '*INDENT + '%(map)s[%(i)d][%(j)d][7:0] = 8\'b00000000;' %{'map':'M', 'i':c[0], 'j':c[1]}

for q in range(8):
     print 'RES_D[%(i)d*7 + %(j)d : %(j)d*7 + %(j)d] = '%{'i':q+1, 'j':q} + ''.join(['|M[' + str(q) + '][' + str(7-i) + '], ' for i in range(8)])[:-2].join('{}') + ';'
