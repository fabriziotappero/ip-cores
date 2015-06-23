These .xco files are created by CoreGen for the following FPGA device:

  Xilinx xc3s400an fg400


To generate ip-cores for other devices, use the following cores and settings:

network_register:
- Core:				Block Memory Generator
- Memory Type:			True Dual Port RAM
- Use Byte Write Enable:	No
- Algorithm:			Minimum Area
- Port A:
  - Write Width:		8
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



data_reg:
- Core:				Block Memory Generator
- Memory Type:			True Dual Port RAM
- Use Byte Write Enable:	No
- Algorithm:			Minimum Area
- Port A:
  - Write Width:		8
  - Write Depth:		8192
  - Operating Mode:		Write First
  - Enable:			Always Enabled
- Port B:
  - Write Width:		32
  - Operating Mode:		Write First
  - Enable:			Always Enabled
- Optional Output Registers:	No
- Memory Initialization:	Fill with 0
- Output Reset Pins:		No



async_fifo:
- Core:				Fifo Generator
- FIFO Implementation:		Independent Clocks / Block RAM
- Read Mode:			First-Word Fall-Through
- Data Port Parameters:
  - Write Width:		38
  - Write Depth:		128
  - Read Width:			38
- Optional Flags:		No
- Write Port Handshaking:	No
- Read Port Handshaking:
  - Valid Flag:			Yes / Active High
  - Underflow Flag:		No
- Initialization:
  - Reset Pin:			Yes
  - Enable Reset Sync.:		Yes
  - Full Flags Reset Value:	0
  - Use Dout Reset:		Yes / Value: 0
  - Programmable Flags:		No
- Data Count Options:		All off
