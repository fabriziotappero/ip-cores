How to run the demo:
- create a new project in the ISE project navigator
- add files (Project>Add Source):
	+ lcd16x2_ctrl.vhd
	+ lcd16x2_ctrl_demo.vhd
	+ pin_locations.ucf
- if you use the ML501 board you can leave pin_locations.ucf unchanged, otherwise you
  have to adjust the locations for your board (see your board's schematics)
- open the file lcd16x2_ctrl_demo.vhd and adjust the constant CLK_PERIOD_NS (clock period in nanoseconds) 
  in case your board's oscillator frequency differs from 100MHz. Again, nothing needs to be done for 
  the ML501 board.
- implement the design and program FPGA
