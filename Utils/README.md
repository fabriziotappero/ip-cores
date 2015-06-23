M65C02 Processor Core Utilities
===============================

Copyright (C) 2012, Michael A. Morris <morrisma@mchsi.com>.
All Rights Reserved.

Released under LGPL.

Directory Contents
------------------

This subdirectory provides two utilities to support the M65C02 Microprogrammed
Processor Core:

    (1) Bin2Txt.exe
    (2) SMRTool.exe
    
Bin2Txt.exe
===========

**Bin2Txt.exe** convert binary assembler output files from the Kingswood A65 
6502 Assembler into ASCII hexadecimal memory initialization files as required 
by Xilinx ISE. 

Usage
-----

The utility **bin2txt.exe** and its associated source file, **bin2txt.c**, 
operate as a DOS command line utility. It was compiled using the Borland Turbo 
C/C++ 2.0 compiler.

The utility requires the path and filename of a binary input file and the path 
and filename of an output file.

The input file is opened for reading as binary. The output file is opened for 
writing as a text (ASCII, single byte character set) file. Data is read from 
the input file, converted to ASCII Hexadecimal, and written to the output 
file. Each input byte is written to the output as two ASCII characters on a 
single line. Each line is terminated with a standard newline terminator, "\n".

While reading the input file, a count of the number of bytes processed is 
kept. After all input data has been read from the input file and written to 
the output file, the output file is padded with 0x00 so that the total number 
of lines is equal to a power of two.

Documentation
-------------

If the number of required arguments are not supplied, then before terminating 
the utility will print out a prompt to the user that defines the needed 
arguments.

Status
------

Design and verification is complete.

SMRTool.exe
===========

**SMRTool.exe** is a tool used to convert text source files into VHDL, 
Verilog, or Xilinx memory intialization files. The source files can be used to 
construct simple ROM for a number of usefull purposes. It's particular use in 
the MAM65C02 Microprogrammed Processor Core is to convert the microprogram 
source files provided into two memory initialization files which are loaded 
into the fixed and variable microprogram ROMs.

Usage
-----

The primary use for **SMRTool** is as a tool to convert human-readable 
microprogrammed state machine descriptions into synthesizable VHDL and/or 
Verilog RTL descriptions of ROMs. **SMRTool** also provides memory 
initialization files, and this is its primary method of usage for the MAM65C02 
Microprogrammed Processor Core.

**SMRTool** is a Windows-based tool which provides the user graphical user 
interface specify the input source file, and check boxes and text boxes to 
select various output options and files. It is written in C#, and requires the 
.NET framework to run. 

In the final analysis, **SMRTool** is a text substitution tool. As such, it 
has a number of limitations, but it is invaluable for its intended purpose. 
Extensions are being continually added to the tool as additional functionality 
is required to support more complex state machines, and to improve the 
simulation and testing of the state machines in VHDL/Verilog or SystemVerilog 
verification environment.

Documentation
-------------

A complete description of the tool is not available. The source files provided 
in the sources subdirectory, **M65C02_Decode_ROM.txt** and 
**M65C02_uPgm_V3.txt**, provide an example of the format and syntax that is 
required by **SMRTool**. This section will provide additional information 
about the structure and syntax, but the source files provided are the 
definitive syntax references for the tool; they make use of all of the current 
directives and features of **SMRTool**.

First and foremost, **SMRTool** is a text substitution tool. No provision is 
made for in-line symbolic equations in the publicly released version of the 
tool provided herein.

Each source file must start with a header. The header is marked by the symbol 
**header** in column 1 of the first line of the source file, and demarcated by 
the symbol **endh**. Within the header, the tool presently recognizes four 
fields. Each header field is terminated by a colon, **:**, and followed by a 
string which the tool extracts and places into the appropriate GUI text boxes. 
The currently recognized header fields are:

    (1) Project
    (2) File Revision
    (3) Author(s)
    (4) Description

Comments may be used, and are introduced using the VHDL comment symbol **--**, 
a double hyphen. The comment extents from that point to the end of the line. 
Presently there is no support for multi-line block comments such as is 
avaiable in Verilog and C.

Following the header section, the source file must define all substitution 
symbols. Owing to its intended design and implementation as a microprogram 
source file processor, there are several directives recognized by **SMRTool** 
to aid in this process. 

Each line in the file may be blank, a comment line, or contain symbols to be 
processed. Each source line is divided into at least one or more fields.  With 
the exception of the first and second fields on a source line, fields are 
separated by commas. Each field is specified to have a constant width, and the 
values assigned to the symbols must be defined to fit into the specified 
width. Each field is positionally located in a line of source.

On a line of source, fields may be skipped, and the default value is inserted 
by **SMRTool**, using consecutive commas. From the last used field on a line 
to the end, or to a comment, there is no need to include the commas to skip 
the unused fields. The tool will automatically substitute the default value 
for all skipped fields. **The default value of a field is zero.** A limitation 
of the present tool is that the default value can not be changed.

The current implementation of the tool recognizes the following directives:

    (1) .asm
    (2) .def
    (3) .equ
    (4) .org


The **.asm** directive defines the microprogram controller's instructions. 
Unless a label (described below) is used at the start of a source line, a 
symbol defined by the **.asm** directive must be the first symbol on a source 
line.

The **.def** defines the width of each field in the source file. The first 
field defined by a **.def** directive will be the leftmost field in the 
output, followed by the second field, etc. The sum of all of the widths of all 
defined fields is the total width of the data written to the tool's output. 
There is no limit to the total field width, but with respect to to Block RAMs 
in Xilinx FPGAs, in particular, the maximum practical width of a ROM is 36 or 
72 bits.

The **.equ** directive is used to define all other text substitution symbols 
beyond those defined by the **.asm** directive. A limitation of the present 
implementation is that all symbols must be unique. 

The **.org** directive defines the location counter address of all source 
lines which follow the directive. If multiple **.org** directives are used in 
a source file, then the intervening locations are automatically filled by the 
tool with zeros. In the present implementation there is a limitation that all 
**.org** directives be increasing in magnitude. If an **.org** is placed in 
the source with a lesser value than one already used, the location counter is 
assigned the new value, and the previously defined values may be overwritten 
by any new output lines.

Labels are used to define the symbols to which the **.asm** and **.equ** 
directives assigns values, or labels may used to capture the value of the 
location counter to a symbol. When labels are used to capture the location 
counter value, the labels must always start with an underscore character, 
**_**. All labels in a source file must be unique, and all labels capturing 
the value of the location counter must be terminated by a colon. Location 
counter labels, terminated by a colon, may appear on a source line before a 
**.org** directive, or one of the **.asm** symbols.

The current value of the location counter is the special symbol: **$** or 
dollar sign.

The last line of the source file must be labeled **_end** terminated by colon.

Extensions
----------

At the present time, there are no plans to port the tool to C/C++ and Linux. 
If there is sufficient interest expressed in such a conversion, then 
consideration will be given to that task.

Status
------

Mature. **SMRTool** is in continous usage for a number of FPGA designs, and 
being actively maintained.

Error Reports
-------------

If there are any problems found, please open a GitHub issue. Each reported 
issue with **SMRTool** will be evaluated. In order to evaluate a problem 
report, a description of the problem and the relevant sources are required. 
Without both of these components of a problem report, the likelihood of any 
significant investigation into a reported problem is a low probability.
