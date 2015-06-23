The .xco files are created by CoreGen for the following FPGA device:

  Xilinx xc3s50an tqg144


To generate an ip-core for other devices, use the following cores and settings:


data_register:
- Core:				Block Memory Generator
- Memory Type:			True Dual Port RAM
- Use Byte Write Enable:	No
- Algorithm:			Minimum Area
- Port A:
  - Write Width:		32
  - Write Depth:		64
  - Operating Mode:		Write First
  - Enable:			Always Enabled
- Port B:
  - Write Width:		32
  - Operating Mode:		Write First
  - Enable:			Always Enabled
- Optional Output Registers:	No
- Memory Initialization:	Fill with 0
- Output Reset Pins:		No
