AltOR32 OpenRisc Simulator
--------------------------

Details
-------

- Simple simulator for OpenRisc instructions, where only the essentials have been implemented.
- Compiles under Linux (make) or Windows (VS2003+).
- Able to execute OpenRisc 1000 (ORBIS32) code compiled with the following options:
   -msoft-div -msoft-float -msoft-mul -mno-ror -mno-cmov -mno-sext

Usage
-----

-f filename.bin = Executable to load (binary)	[Required]
-t              = Enable program trace          [Optional]
-v 0xX          = Trace Mask                    [Optional]
-b 0xnnnn       = Memory base address           [Optional]
-s 0xnnnn       = Memory size                   [Optional]
-l 0xnnnn       = Executable load address       [Optional]
-c nnnn         = Max instructions to execute   [Optional]

Console Output
--------------

This simulator implements some of the basic l.nop extensions such as NOP_PUTC(4).

Example:

void putc(int c)
{
  register char  t1 asm ("r3") = c;
  asm volatile ("\tl.nop\t%0" : : "K" (4), "r" (t1));
}

Implementing Peripherals
------------------------

Peripherals can be implemented by creating a new class which inherits from 'Peripheral' and overrides the following functions to provide memory mapped I/O extensions;

    // Peripheral access
    virtual void        Reset(void)
    virtual void        Clock(void)
    virtual TRegister   Access(TAddress addr, TRegister data_in, TRegister wr, TRegister rd)
    virtual bool        Interrupt(void)
    virtual TAddress    GetStartAddress()
    virtual TAddress    GetStopAddress()
    
The new peripheral can then be attached to the simulator (using AttachPeripheral).
