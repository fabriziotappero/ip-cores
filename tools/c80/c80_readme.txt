Samll-C compiler adapted for embedded systems by Moti Litcochevski. 
(February 20, 2012)

This compiler is an adapted version of the C80DOS compiler found on 
http://www.cpm.z80.de/small_c.html.

After downloading the compiler I tried to generate some code for my FPGA SOC 
using the light8080 CPU. The generated assembler code presented a few issues:

1. The compiler operates in interactive mode requesting the user to enter 
   filenames step by step. This is very inconvenient when compiling over and over 
   again. 
2. The generated assembly code did not compile using my preferred AS80 assembler.
   Although other assemblers are available, they are not free to be used for all 
   purposes. 
3. The stack pointer was initialized to some constant value.
4. Some coding extras where missing. For example, defining IO ports for CPU 
   peripherals (see below).

The compiler version presented here provides some improvements to the above 
issues:

1. Main routine was changed to enable command line operation of the compiler.
   For command line options just run the compiler without any input options.
2. Assembly code was changed to the syntax used by the Z80. This enables the 
   output assembly file to be compiled using the AS80 tool.
3. Stack pointer initial value may be specified in the command line options.
4. Supporting line comments "//". this is a must for me.
5. Support for hexadecimal values defined with "0x" prefix.
6. Defining IO ports using the following syntax:
      // value in brackets is the port address 
      port (128) UDATA;
   Address may be entered as hexadecimal value.
7. Support for global variable init values either as strings or list. 
   For example:
      // string init value 
      char tstring[10] = "Hello";
      // value list init value 
      int tint[10] = {1,2,3,4,5,6,7,8,9,10};

Note that one of the program source file must include the "c80.lib" assembler file 
which defines the library assembler functions used by the compiler. Currently all 
functions will be added to the output file even if not used. This will increase the 
size of the program memory by about 300 bytes.

Features that are missing from the current release:
1. Add "#ifdef" macro statements.
2. Include only the library functions used by the program. 

Hope you find this application helpful,
Moti 
