This directory contains support tools meant for software development on the
light8080 SoC.


ihex2vlog: Object code to Verilog constant conversion.

    Reads an Intel HEX file and generates memory Verilog module or Xilinx
    RAMB16/RAMB4 verilog initialization vectors.
    Run 'ihex2vlog' with no arguments to get usage instructions.
    
    Supplied as C source and Windows precompiled binary.

c80: Small C compiler modified to support the light8080 SoC.

    This is a port of the classic Small C compiler, with some new features and
    including support files for the light8080 SoC.

    Supplied as C source and precompiled Windows binary.

obj2hdl: Object code to VHDL

    Reads an Intel HEX file and produces an VHDL package used to initialize
    the SoC internal memory.
    Invoke without arguments to get some usage help.

    Supplied as portable Python source plus helper DOS BATCH script.

hexconv: Insertion of HEX object code into VHDL template.

    Reads an Intel HEX file and inserts the object code into an VHDL test
    bench template whose name is given as parameter.
    
    Invoke without arguments to get some usage help.
    
    This program was used in the early versions of the project to build the
    VHDL test benches from a common template. It is no longer used. The old
    template is included in the hexconv directory; it may be useful as an usage
    example.
    
    Supplied as portable Perl script.
    
