#!/usr/bin/python
# The script below is written by Wojciech M. Zabolotny
# wzab<at>ise.pw.edu.pl 19.03.2012
# it is published as PUBLIC DOMAIN
import sys
class field:
  last_bit = 0;
  def __init__(self,field_desc):
    fd = field_desc.split(",")
    self.fname = fd[0]
    if not fd[1] in ["signed","unsigned","std_logic_vector"]:
       raise Exception("Wrong field type")
    self.ftype = fd[1]
    if len(fd)==3:
       self.b1=int(fd[2])-1
       self.b2=0
    elif len(fd)==4:
       self.b1=int(fd[2])
       self.b2=int(fd[3])
    else:
       raise Exception("Syntax error in line: "+field_desc)
    #Assign vector bits
    self.v1=field.last_bit
    self.v2=field.last_bit+abs(self.b2-self.b1)
    field.last_bit = self.v2+1
 
if len(sys.argv) != 2:
   print """
The rec_to_pkg scripts creates VHDL package for conversion
between the VHDL records containing "signed" and "unsigned"
fields and std_logic_vectors.
It should be called as: rec_to_pkg.py description_file
where the description file should have the following syntax:

#Optional comment line
record record_name
#optional comment lines
#[...]
field_name,signed_or_unsigned,width
#or
field_name,signed_or_unsigned,left_bit_nr,right_bit_nr
end

The generated package is written to the record_name_pkg.vhd file
"""
   exit(0)
fin=open(sys.argv[1])
#Read the full description of the type
type_desc=[l.strip() for l in fin.readlines() if len(l) > 0 and l[0] != "#" ]
#The first line should contain the record name
l=type_desc[0].split(" ")
if l[0] != "record":
   raise Exception("Syntax error! The first line should have form \"record name_of_type\"")
type_name=l[1]
pkg_name=type_name+"_pkg"
#Prepare for analysis of fields
msb=0
fields=[]
end_found = False
#Find the field definitions
for l in type_desc[1:]:
   if l=="end":
      end_found=True
      break
   fields.append(field(l))
if not end_found:
   raise Exception("Syntax error: no \"end\" found")
#If we got here, probably the syntax was correct
#Lets generate the package
p="""\
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
"""
p+="package "+pkg_name+" is\n\n"
p+="type "+type_name+" is record\n"
for f in fields:
   s="    "+f.fname+" : "+f.ftype+"("
   if f.b1 > f.b2:
      s=s+str(f.b1)+" downto "+str(f.b2)+");\n"
   else:
      s=s+str(f.b1)+" to "+str(f.b2)+");\n"
   p+=s
p+="end record;\n\n"
#Write width of our type
p+="constant "+type_name+"_width : integer := "+str(field.last_bit)+";\n\n"
#Write headers of conversion functions
p+="function "+type_name+"_to_stlv(\n"
p+="  constant din : "+type_name+")\n"
p+="  return std_logic_vector;\n\n"
p+="function stlv_to_"+type_name+"(\n"
p+="  constant din : std_logic_vector)\n"
p+="  return "+type_name+";\n\n"
p+="end "+pkg_name+";\n\n"
#Now the body of the package - the conversion functions
p+="package body "+pkg_name+" is\n\n"
#
p+="function "+type_name+"_to_stlv(\n"
p+="  constant din : "+type_name+")\n"
p+="  return std_logic_vector is\n"
p+="  variable res : std_logic_vector("+str(field.last_bit-1)+" downto 0);\n"
p+="begin\n"
for f in fields:
  p+="  res("+str(f.v2)+" downto "+str(f.v1)+ ") := std_logic_vector(din."+f.fname+");\n"
p+="  return res;\n"
p+="end "+type_name+"_to_stlv;\n\n"
#
p+="function stlv_to_"+type_name+"(\n"
p+="  constant din : std_logic_vector)\n"
p+="  return "+type_name+" is\n"
p+="  variable res : "+type_name+";\n"
p+="begin\n"
for f in fields:
  p+="  res."+f.fname+":="+f.ftype+"(din("+str(f.v2)+" downto "+str(f.v1)+"));\n"
p+="  return res;\n"
p+="end stlv_to_"+type_name+";\n\n"
p+="end "+pkg_name+";\n"

#The output file name
fout_name=type_name+"_pkg.vhd"
fout=open(fout_name,"w")
fout.write(p)
fout.close()

