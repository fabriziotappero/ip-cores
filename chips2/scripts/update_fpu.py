#!/usr/bin/env python
import os.path

divider = open(os.path.join("fpu", "divider", "divider.v")).read()
multiplier = open(os.path.join("fpu", "multiplier", "multiplier.v")).read()
adder = open(os.path.join("fpu", "adder", "adder.v")).read()
int_to_float = open(os.path.join("fpu", "int_to_float", "int_to_float.v")).read()
float_to_int = open(os.path.join("fpu", "float_to_int", "float_to_int.v")).read()
output_file = open(os.path.join("chips", "compiler", "fpu.py"), "w")

output_file.write("divider = \"\"\"%s\"\"\"\n"%divider)
output_file.write("multiplier = \"\"\"%s\"\"\"\n"%multiplier)
output_file.write("adder = \"\"\"%s\"\"\"\n"%adder)
output_file.write("int_to_float = \"\"\"%s\"\"\"\n"%int_to_float)
output_file.write("float_to_int = \"\"\"%s\"\"\"\n"%float_to_int)
