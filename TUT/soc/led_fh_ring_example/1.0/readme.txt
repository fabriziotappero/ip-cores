-----------------------
led_fh_ring_example
-----------------------

Purpose: Demonstrate Kactus tool, https://sourceforge.net/projects/kactus2/
	 Running this ensures that you have installed the tools
	 and libraries correctly. Pinmaps for Altera/Terasic DE2 FPGA board are included.

HW structure:
	Ring network with 16 terminals.
	8 switches  and 8 leds.


Directories
	ip_xact IP-XACT descriptions (XML) for the demo. These
		are handled by Kactus.

	quartus	Synthesis settings. Run Altera Quartus in this directory.

	sim	Simulation scripts. Run Modelsim in this directory.

	vhd	Incl. top-level VHDL description.

	Note that VHDL for the ring and interfaces to switches/leds are elsewhere.	


Usage in Kactus:
	Start Kactus. 

	Click magnifying glass icon ("Search IP-XACT files") to setup the library.

	Browse the library and locate "TUT::soc::led_fh_ring_example::1.0"

	Open both "design" and "component" with right mouse button.
	
	In Kactus, you can
	    Re-generate top-level VHDL			(exists laready in ./vhd)
	    Re-generate simulation scripts for Modelsim (exists already in ./sim)
	    Generate synthesis project for Quartus	(pinmap for DE2 board exists already in ./sim)
	    Generate HTML documentation
	    Play around with generics			(e.g. which switch controls which led etc.)


Usage after/without Kactus:
	----------
      	Simulating
	----------
	> cd sim
	> vsim &
	> do create_makefile
	> do sim.do
	These scripts compile evertyhing and run a short example (toggle switches
	to light up few leds).



	---------
	Synthesis
	---------
	Kactus creates the synthesis project automatically, so you can select option a), otherwise you
	must select b)

	> quartus &
	
	a) > File -> Open Project -> ./quartus/led_fh_ring_example.qpf
	b) > File -> New project wizard, 
	     add all the files,  
	     Assignments -> Import assignments -> ./quartus/pinmap_cyclone_2_EP2C35F672C6.qsf 

	> Processing -> Start compilation (or siply CTRL+L)
	> Tools -> Programmer and click Start

	You can now use switches 0-7 to control the leds 0-7. Switch 17 is reset.


Voilà!

---

Erno Salminen, TUT
2011-12-13
