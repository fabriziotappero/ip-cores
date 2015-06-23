----------------------------------------------------------------------------
----                                                                    ----
----                  Copyright Notice                                  ----
----                                                                    ----
---- This file is part of YAC - Yet Another CORDIC Core                 ----
---- Copyright (c) 2014, Author(s), All rights reserved.                ----
----                                                                    ----
---- YAC is free software; you can redistribute it and/or               ----
---- modify it under the terms of the GNU Lesser General Public         ----
---- License as published by the Free Software Foundation; either       ----
---- version 3.0 of the License, or (at your option) any later version. ----
----                                                                    ----
---- YAC is distributed in the hope that it will be useful,             ----
---- but WITHOUT ANY WARRANTY; without even the implied warranty of     ----
---- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU  ----
---- Lesser General Public License for more details.                    ----
----                                                                    ----
---- You should have received a copy of the GNU Lesser General Public   ----
---- License along with this library. If not, download it from          ----
---- http://www.gnu.org/licenses/lgpl                                   ----
----                                                                    ----
----------------------------------------------------------------------------



         Author(s):  Christian Haettich        
         Email       feddischson@opencores.org 






Description
------------------

CORDIC is the acronym for COordinate Rotation DIgital Computer and 
allows a hardware efficient calculation of various functions 
like - atan, sin, cos - atanh, sinh, cosh, - division, multiplication. 
Hardware efficient means, that only shifting, additions and 
subtractions in combination with table-lookup is required. This makes 
it suitable for a realization in digital hardware. Good 
introductions can be found in [1][2][3][5]. 

 

The following six CORDIC modes are supported: 
- trigonometric rotation
- trigonometric vectoring
- linear rotation
- linear vectoring
- hyperbolic rotation
- hyperbolic vectoring


Furthermore, the CORDIC algorithm is implemented for iterative 
processing which means, that the IP-core is started 
with a set of input data and after a specific amount of 
clock cycles, the result is 
available. No parallel data can be processed. 

In addition to an IP-core written in VHDL, a bit-accurate C-model 
is provided. This C-model can be compiled as mex for a usage with Octave or 
Matlab. Therefore, this C-model allows a bit-accurate analysis 
of the CORDIC performance on a higher level. 


For a more detailed documentation, see ./doc/documentation.pdf





Status
----------------------
- C-model implementation is done
- RTL model implementation is done
- RTL model is verified against C-model





Next-Steps
-----------------------
- Prove of FPGA feasibility
- Circuit optimizations
- Numerical optimizations





Files and folders:
------------------

 ./c_octave :  contains a bit-accurate C-implementation of the YAC.
               This C-implementation is used for analyzing the performance
               and to generate RTL testbench stimulus
               (cordic_iterative_test.m).
               The file cordic_iterative_code.m is used to create some
               VHDL/C-code automatically.

 ./rtl/vhdl :  Contains the VHDL implementation files

 ./doc      :  Will contain a detailed documentation in future.






[1] Andraka, Ray; A survey of CORDIC algorithms for FPGA based computers, 1989 
[2] Hu, Yu Hen; CORDIC-Based VLSI Architectures for Digital Signal Processing, 1992 
[3] CORDIC on wikibook: http://en.wikibooks.org/wiki/Digital_Circuits/CORDIC 
[4] CORDIC on wikipedia:http://en.wikipedia.org/wiki/CORDIC 
[5] David, Herbert; Meyr, Heinricht; CORDIC Algorithms and Architectures 
    http://www.eecs.berkeley.edu/newton/Classes/EE290sp99/lectures/ee290aSp996_1/cordic_chap24.pdf 


