#!/usr/bin/python
# This is the public domain code written by Wojciech M. Zabolotny
# ( wzab(at)ise.pw.edu.pl )
# The functionality has been inspired by the CRC Tool available
# at http://www.easics.com/webtools/crctool , however the code
# has been written independently.
# In fact I have decided to write this code, when I was not able to
# generate CRC with the crctool for a particular non-typical length
# of data word.
# The program crc_gen.py generates the VHDL code for CRC update for given
# length of the data vector.
# The length of the CRC results from the coefficient of the CRC polynomial.
# The arguments are as follows:
# 1st: Function name. The package name is created by prefixing it with
#        pkg_
# 2nd: L - for data fed LSB first, M for data fed MSB first
# 3rd: the width of the data bus,
# 4th and next: the coefficients of the polynomial (the exponents in fact).
# For example, to generate the expression for CRC7 for 12bit data transmitted LSB first
# you should call:
# crc_gen.py crc7_d12 L 12 7 3 0
# To generate CRC-12 for 16 bit data transmitted MSB first, you should call:
# crc_gen.py crc12_d16 M 16 12 11 3 2 1 0
# The generated code implements a package with the function calculating
# the new value of the CRC from the previous value of the CRC and
# the data word.
import sys
fun_name=sys.argv[1]
pkg_name = "pkg_"+fun_name
data_order=sys.argv[2]
if data_order != 'L' and data_order != 'M':
    print "The second argument must be 'L' or 'M', not the '"+data_order+"'"
    sys.exit(1)
data_len=int(sys.argv[3])
poly=[]
for i in range(4,len(sys.argv)):
    poly.append(int(sys.argv[i]))
crc_len=max(poly)

#The class "xor_result" implements result of xor-ing of multiple
# CRC and DATA bits
# dirty trick: the class relies on global variables crc_len and data_len
class xor_result:
    def __init__(self,c=-1,d=-1):
        self.c=crc_len*[0]
        self.d=data_len*[0]
        if(c>-1):
            self.c[c]=1
        if(d>-1):
            self.d[d]=1
    def copy(self):
        res=xor_result()
        for i in range(0,crc_len):
            res.c[i]=self.c[i]
        for i in range(0,data_len):
            res.d[i]=self.d[i]
        return res
    # The new XOR operator
    def __xor__(self,x):
        res=xor_result()
        for i in range(0,crc_len):
            res.c[i]=self.c[i]^x.c[i]
        for i in range(0,data_len):
            res.d[i]=self.d[i]^x.d[i]
        return res
    def tostr(self):
        res=""
        for i in range(0,crc_len):
            if self.c[i]==1:
                if res=="":
                    res+="c("+str(i)+")"
                else:
                    res+=" xor c("+str(i)+")"
        for i in range(0,data_len):
            if self.d[i]==1:
                if res=="":
                    res+="d("+str(i)+")"
                else:
                    res+=" xor d("+str(i)+")"
        return res


#Now we create the CRC vector, which initially contains only the bits
#of the initial value of the CRC
CRC=[ xor_result(c=i) for i in range(0,crc_len) ]
#And the data vector
DATA=[ xor_result(d=i) for i in range(0,data_len) ]
#Now we pass the data through the CRC polynomial
if data_order == 'L':
    d_range = range(0,data_len)
    ord_name = "LSB"
elif data_order == 'M':
    d_range = range(data_len-1,-1,-1)
    ord_name = "MSB"
else:
    print "Internal error"
    sys.exit(1)
for i in d_range:
    #We create the vector for the new CRC
    NCRC = [ xor_result() for k in range(0,crc_len) ]
    #First - the basic shift operation
    for j in range(1,crc_len):
        NCRC[j]=CRC[j-1].copy()
    #Now we add the feedback
    FB=DATA[i] ^ CRC[crc_len-1]
    for j in poly:
        if j == crc_len:
            # This does not require any action
            pass
        else:
            NCRC[j]=NCRC[j] ^ FB
    CRC=NCRC
pkg_text = '''library ieee;
use ieee.std_logic_1164.all;
package ''' + pkg_name +" is\n"
pkg_text += "  -- CRC update for "+str(crc_len)+"-bit CRC and "+\
    str(data_len)+"-bit data ("+ord_name+" first)\n"
pkg_text += "  -- The CRC polynomial exponents: "+str(poly)+"\n"
fun_decl = '  function ' + fun_name +"(\n" +\
'   din : std_logic_vector('+str(data_len-1)+' downto 0);\n'+\
'   crc : std_logic_vector('+str(crc_len-1)+' downto 0))\n'+\
'  return std_logic_vector'
pkg_text += fun_decl+';\n'
pkg_text += 'end '+pkg_name+';\n\n'
pkg_text +=  "package body " + pkg_name +" is\n"
pkg_text += fun_decl + ' is \n'
pkg_text += '    variable c,n : std_logic_vector(' + str(crc_len-1)+' downto 0);\n'
pkg_text += '    variable d : std_logic_vector(' + str(data_len-1)+' downto 0);\n'
pkg_text += '  begin\n'
pkg_text += '    c := crc;\n    d := din; \n'
for i in range(0,len(CRC)):
    pkg_text += "      n("+str(i)+") := "+CRC[i].tostr()+";\n"
pkg_text += '    return n;\n'
pkg_text += '  end '+fun_name+";\n"
pkg_text += 'end '+pkg_name+";\n"
print pkg_text
