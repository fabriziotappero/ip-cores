The component Builder in Quartus 6.0 will not accept include files, so you have to use Quartus to synthesize
the source code into a single .vqm file, then rename this as a .v file, and then import this using component Builder.
There is a make file in this directory that can called from cygwin and used to copy the RTL source to sopcCompProj/src

From cygwin
make
Open Quartus project 'usbHostSlaveAvalonWrap.qpf'
Processing >> Start >> Start Analysis and Synthesis
Processing >> Start >> Start VQM Writer
Copy sopcCompProj/atom_net_list/usbHostSlaveAvalonWrap.vqm to 
sopcCompProj/usbhostslaveavalonwrap/hdl/usbHostSlaveAvalonWrap.v
Copy sopcCompProj/usbhostslaveavalonwrap directory to the Quartus project directory where you wish to use the new component

