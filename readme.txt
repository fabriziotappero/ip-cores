TINY8 8-bit microprocessor        March 6th 2002

Ulrich Riedel          riedeltgbx2@cswebmail.com

This is an 8-bit microprocessor in an FPGA
ALTERA EPF10K10LC84-4. Designed with
MAX+plusII BASELINE 10.0 in a mixture of AHDL and
schematic.

The ZIP archive TINY8V01.ZIP contains the complete
develop files ready to make the configuration file.
It also contains a simple assembler in the subdir
ASSEM with C-source code.

Attention:  The microprocessor needs a two phase
clock  CLK, CLKD.  CLKD is derived from CLK with
a delay line of approx 25ns (74HC04). I have tested
with clock speeds up to 10MHz.
This design contains address decoders for ROM, RAM
and 1-bit input, 1-bit output. After configuration
the FPGA it runs from address 0.

Some features are missing:
Waitstate generation
Stack pointer
Interrupts

You are free to use it, also the source code.

Thanks for any remarks, suggestions.

    Ulrich Riedel
