
This component takes the opencores opb_vga_char_display_nodac project and makes it socgen compatible. The original project checked in by Timmothy Pearson in Oct 2007 consisted of a single module that added a asic vga interface to a microblaze system. It had no documentation or test suite and could only work in xilinx spartan parts.

I chose it because it was a useful module and had mostly clean coding. It requires only 5 pins and about 5% of a Nexys2 fpga.The following changes were made:



1) Stripped off the bus interface.

   You never want to create a component and then hard wire it to any particular bus interface. Create the core engine with documentation and test suite. 
   Then you can create another component that instantiates the core along with the bus of the day interface. If the bus registers are created by a tool 
   it will be easy to retarget it to any bus the tool supports  


2) Split out each module into a seperate file with replaceable module names and variants

   There were two variations defined for this component. You can now have two instanciations and use both in a single design
   

3) Removed the spartan 3 clock gen and ported in pixel_clock and reset

   By receiving the clock and reset from a port this code can now go into any fpga or asic design.


4) Replaced the char rom with a cde_sram and moved the font into a sw directory  

   The font is now compiled from an asm file and loaded with a readmemh command. This enables the support of a ascii only font that is 1/2 the size of the full one.  


5) Replaced the char ram with a cde_ram.

   You can now define a starup screen in a asm file 

6) Connected all signals to  instances by name rather than by position

7) cleaned up port width mismatch,latches and undefined memory accesses

8) converted from async to sync reset

9) Combined port i/o and wire/reg declarations

10) Changed configurations and magic numbers into  parameters

11) Added a simplier color mode for more depth and less per character control

    If you need all the bells and blinking characters you can add it on the outside.

12) Inverted h+v sync siganals. Not sure which way is rigth by my other one is active low and it works

13) added test suite with vga_model and micro bus host 

14) Added docs for operating and config modes
