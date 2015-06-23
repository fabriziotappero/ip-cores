=================================================================================
PC-FPGA COMMUNICATION PLATFORM and VERSATILE UDP/IP CORE IMPLEMENTATION FOR FPGAs 
=================================================================================

Release date: March 21th, 2011


Description
-----------

This package provides an open-source VHDL implementation of a UDP/IP core architecture
and a PC-FPGA interface for transmission of basic C types (chars, 16/32/64-bit integers, floats and doubles).


Package Structure
-----------------

This package contains the following files and folder:

-README 				: This file

-UDP_IP_CORE_FLEX_Spartan3              : This folder contains VHDL, XCO and NGC files for Spartan3 devices.

-UDP_IP_CORE_FLEX_Virtex5               : This folder contains VHDL, XCO and NGC files for Virtex5 devices.

-PC_FPGA_PLATFPORM       	        : This folder contains VHDL, XCO and NGC files for Virtex5 devices as well as C/C++ files.

-PAPER					: This folder contains a paper that describes in detail the design and implementation of the core and the platform.



Verification Details
--------------------

The development board HTG-V5-PCIE by HiTech Global populated with a V5SX95T-1 FPGA was used to verify the correct behavior of the platform and the core.


Citation
--------

By using this component in any architecture design and associated publication, you agree to cite it as: 
"A Versatile UDP/IP based PC-FPGA Communication Platform", by Nikolaos Alachiotis, Simon A. Berger and Alexandros Stamatakis, 
submitted to FPL2011.


Authors and Contact Details 
---------------------------

Nikos Alachiotis			n.alachiotis@gmail.com, nikolaos.alachiotis@h-its.org
Simon A. Berger				simon.berger@h-its.org
Alexandros Stamatakis 			alexandros.stamatakis@h-its.org


Scientific Computing Group (Exelixis Lab)
Heidelberg Institute for Theoretical Studies (HITS gGmbH)

Schloss-Wolfsbrunnenweg 35
D-69118 Heidelberg
Germany


Copyright 
---------

This component is free. In case you use it for any purpose, particularly 
when publishing work relying on this component you must cite it as: N. Alachiotis, S.A. Berger, A. Stamatakis: "A Versatile UDP/IP based PC-FPGA Communication Platform".

You can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This component is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.



Release Notes
-------------

Release date: March 21th, 2011
