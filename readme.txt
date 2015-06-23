                           A-Z80
         A conceptual implementation of the Z80 CPU
         ------------------------------------------

This project is described in more details at: www.baltazarstudios.com

Prerequisites:
* Altera Quartus and Modelsim (free web editions)
* Python 2.7

A-Z80 "cpu" consists of several functional blocks and a top-level module:
  alu         contains ALU block, ALU control and flags logic
  bus         contains data bus switches, pin logic, address latch and the
              address incrementer
  register    contains CPU register file and the register control logic
  control     contains PLA, the sequencer and other control blocks
  toplevel    A-Z80 top level core, interfaces and the test code

"host" integrates the A-Z80 into several complete top-level designs:
  "basic" contains a simplified board consisting of A-Z80 CPU, memory
          and UART modules that can run small Z80 programs
  "zxspectrum" contains an implementation of the Sinclair ZX Spectrum

  You probably want to start by loading one of those two designs in Quartus.

"tools" contains various tools related to the project.

Read the 'readme.txt' files in each of the folders for additional information.
Read 'Quick Start' and 'Users Guide' documents in the 'docs' folder.

A-Z80 Logic Design
==================
Each functional block contains a Quartus project file:
./<block>/test_<block>.qpf

Quartus projects are only used as containers for files within individual
modules; complete top-level solutions that use A-Z80 are in the "host" folder.

Majority of sub-modules are designed in the Quartus schematic editor and then
exported to Verilog for simulation and the top-level integration. If you decide
to create a design using the A-Z80, you can either use schematic files as sources
(in Altera Quartus) or corresponding Verilog sources.

Simulation
==========
*** IMPORTANT ***
Before you can load and simulate any module through Modelsim, you need to set up
the environment by running a Python script 'modelsim_setup.py'. It creates
relative file path mapping to source files in all module project folders.

Each functional block, including the top level, contains a Modelsim simulation
profile: ./<block>/simulation/modelsim/test_<block>.mpf

*** IMPORTANT ***
The first time you open any ModelSim session by opening a *.mpf file, you need to
create a library:
ModelSim> vlib work
After that, you can compile sources (Compile->Compile All) and run a simulation
through one of defined configurations.

If you get a message "Unable to compile", you forgot to run 'modelsim_setup.py'.
Exit ModelSim; git revert its changes to ".mpf" file (since it has been rewritten
using absolute paths); delete "work" folder, run 'modelsim_setup.py' and restart.
You will have to recreate the library ('vlib work') and recompile.

Each project also contains a set of predefined waveform scripts that you can
load before running a simulation of a particular module or a test:
./<block>/simulation/modelsim/wave_<test>.do

Email me if you have any questions,
Goran Devic
gdevic@yahoo.com

----------------------------------------------------------------------------------
This complete project and each file therein is covered under the GNU GPL2.0 license.
It basically states that anyone is free to use it and distribute it, but the full
source needs to be available under the same terms:

    This program is free software; you can redistribute it and/or modify it
    under the terms of the GNU General Public License as published by the Free
    Software Foundation; either version 2 of the License, or (at your option)
    any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT
    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
    FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
    more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
