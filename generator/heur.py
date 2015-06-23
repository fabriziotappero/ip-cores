#!/usr/bin/python

# heuristics generator, for Othello FPGA Project
# Marius TIVADAR, 2 May 2009

L = [
         '64\'h0000000000000001',
         '64\'h0000000000000103',
         '64\'h0000000000010307',
         '64\'h000000000103070F', 
         '64\'h0000000103070F1F',  
         '64\'h00000103070F1F3F',  
         '64\'h000103070F1F3F7F',  
         '64\'h0103070F1F3F7FFF',
         
         '64\'h0000000000000080',
         '64\'h00000000000080C0',   
         '64\'h000000000080C0E0',   
         '64\'h0000000080C0E0F0',   
         '64\'h00000080C0E0F0F8',   
         '64\'h000080C0E0F0F8FC',   
         '64\'h0080C0E0F0F8FCFE',   
         '64\'h80C0E0F0F8FCFEFF',

         '64\'h8000000000000000',
         '64\'hC080000000000000',
         '64\'hE0C0800000000000',
         '64\'hF0E0C08000000000',
         '64\'hF8F0E0C080000000',
         '64\'hFCF8F0E0C0800000',
         '64\'hFEFCF8F0E0C08000',
         '64\'hFFFEFCF8F0E0C080',

         '64\'h0100000000000000',
         '64\'h0301000000000000',
         '64\'h0703010000000000',
         '64\'h0F07030100000000',
         '64\'h1F0F070301000000',
         '64\'h3F1F0F0703010000',
         '64\'h7F3F1F0F07030100',
         '64\'hFF7F3F1F0F070301',

         '64\'h0101010101010101',
         '64\'h0303030303030303',
         '64\'h0707070707070707',
         '64\'h0F0F0F0F0F0F0F0F',
         '64\'h8080808080808080',
         '64\'hC0C0C0C0C0C0C0C0',
         '64\'hE0E0E0E0E0E0E0E0',
         '64\'hF0F0F0F0F0F0F0F0',

         '64\'h00000000000000FF',
         '64\'h000000000000FFFF',
         '64\'h0000000000FFFFFF',
         '64\'h00000000FFFFFFFF',
         '64\'hFFFFFFFF00000000',
         '64\'hFFFFFF0000000000',
         '64\'hFFFF000000000000',
         '64\'hFF00000000000000'

]

P = []
PN = []

for (i, pattern) in enumerate(L):
#    print """if ( (R[63:0] & %(pat)s) == %(pat)s ) begin
#     %(idx)s = %(scor)d;
#end
#else begin
#     %(idx)s = 0;
#end
#
#""" % {'pat': pattern, 'idx':'pattern' + str(i) + '_d', 'scor':i%8 + 1}


    print 'assign %(idx)s = ((R[63:0] & %(pat)s) == %(pat)s) ?  %(scor)d : 0;' % {'pat': pattern, 'idx':'pattern' + '0'*(2-(len(str(i)))) + str(i) + '_Rd', 'scor':i%8 + 1}
    print 'assign %(idx)s = ((B[63:0] & %(pat)s) == %(pat)s) ? %(scor)d : 0;' % {'pat': pattern, 'idx':'pattern' + '0'*(2-(len(str(i)))) + str(i) + '_Bd', 'scor':-(i%8 + 1)}
    P += ['pattern' + '0'*(2-(len(str(i)))) + str(i) + '_Rd']
    PN += ['pattern' + '0'*(2-(len(str(i)))) + str(i) + '_Bd']

print '\n'
#print 'value_d = '

PART = []
for i in range(len(P)/4):
#    print 'value_p%(idx)d_d = ' % {'idx':i}
    print '\t' + 'value_Rp%(idx)d_d = ' % {'idx':i} + ' + '.join(P[i*4:(i+1)*4]) + '; '
    PART += ['value_Rp%(idx)d_d' % {'idx':i}]

print '\n'

for i in range(len(PN)/4):
    print '\t' + 'value_Bp%(idx)d_d = ' % {'idx':i} + ' + '.join(PN[i*4:(i+1)*4]) + '; '
    PART += ['value_Bp%(idx)d_d' % {'idx':i}]
#    print '\t' + ' + '.join(PN[i*8:(i+1)*8]) + ' + '

print '\n'

PART2 = []
for i in range(len(PART)/4):
#    print 'value_p%(idx)d_d = ' % {'idx':i}
    print '\t' + 'value_pp%(idx)d_d = ' % {'idx':i} + ' + '.join(PART[i*4:(i+1)*4]) + '; '
    PART2 += ['value_pp%(idx)d_d' % {'idx':i}]


print '\n'
#print PART2

print 'value_d = ' + ' + '.join(PART2) + ';'


for p in PART:
    print 'reg signed [5:0] ' + p + ';'

print '\n'

for p in PART2:
    print 'reg signed [6:0] ' + p + ';'

print '\n'

for p in P:
    print 'wire signed [4:0] ' + p + ';'

print '\n'

for p in PN:
    print 'wire signed [4:0] ' + p + ';'


MUT = ['M[' + str(i) + ']' for i in range(64)]

print '\n'

print 'mutability_d = ' + ' + '.join(MUT) + ';'
