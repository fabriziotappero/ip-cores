-============================================================================--
The WildCard FPGA template design is based on the GRLIB VHDL IP core library.

The design can be synthesized using only GRLIB IP cores:

- make ise            Synthesis, place and route using Xilinx ISE

- make ise-synp       Synthesis using Synplify, place and route using Xilinx ISE

- make ise-prom       Generation of wildcard-xcv300e.bin programming file

To simulate the design, one requires access to the VHDL templates that are
delivered with the WildCard device. Set WILDCARD_BASE variable to WildCard VHDL
directory path.

- make vsim           Compile FPGA design with ModelSim

- make vsim-wildcard  Compile WildCard test environment with ModelSim

- vsim system_config  Simulate WildCard design with ModelSim

All information is provided "as is", there is no warranty that the information
is correct or suitable for any purpose, neither implicit nor explicit.
--============================================================================--
